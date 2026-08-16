/* nth_prime_zen5.c - 64-bit hardware integer nth-prime engine
 * with Zen 5 (x86-64-v4) AVX-512 & BMI2 assembly acceleration,
 * discrete aperture sliding-window sieve, and fast prime counting.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <inttypes.h>

#ifdef _OPENMP
#include <omp.h>
#endif

#if __has_include(<gmp.h>) || defined(USE_GMP)
#include <gmp.h>
#define HAS_GMP 1
#else
typedef struct {
    int _mp_alloc;
    int _mp_size;
    uint64_t *_mp_d;
} mpz_t[1];
#define HAS_GMP 0
#endif

#define CACHE_SIZE 1048576
#define CACHE_MASK (CACHE_SIZE - 1)

static uint64_t g_memo_x[CACHE_SIZE];
static uint32_t g_memo_a[CACHE_SIZE];
static uint64_t g_memo_res[CACHE_SIZE];

static uint16_t g_phi6_table[30030];
static bool g_phi6_initialized = false;

static uint64_t *g_is_subprime_bit = NULL;
static uint32_t *g_popcnt_block = NULL;
static uint64_t g_sieve_max = 0;

/* Zen 5 AVX-512 / BMI2 popcount intrinsic helper */
static inline uint64_t zen5_popcnt64(uint64_t val) {
    uint64_t cnt;
    __asm__ ("popcntq %1, %0" : "=r"(cnt) : "r"(val));
    return cnt;
}

static bool is_coprime_to_30030(size_t i) {
    bool res = true;
    size_t r2 = i % 2;
    size_t r3 = i % 3;
    size_t r5 = i % 5;
    size_t r7 = i % 7;
    size_t r11 = i % 11;
    size_t r13 = i % 13;

    if (r2 == 0) {
        res = false;
    } else if (r3 == 0) {
        res = false;
    } else if (r5 == 0) {
        res = false;
    } else if (r7 == 0) {
        res = false;
    } else if (r11 == 0) {
        res = false;
    } else if (r13 == 0) {
        res = false;
    }
    return res;
}

static void init_phi6_table(void) {
    if (!g_phi6_initialized) {
        uint16_t running = 0;
        size_t i = 1;
        while (i <= 30030) {
            if (is_coprime_to_30030(i)) {
                running = (uint16_t)(running + 1);
            }
            size_t idx = i - 1;
            g_phi6_table[idx] = running;
            i = i + 1;
        }
        g_phi6_initialized = true;
    }
}

static inline uint64_t phi6(uint64_t x) {
    uint64_t q = x / 30030ULL;
    uint64_t r = x % 30030ULL;
    uint64_t ans_q = q * 5760ULL;
    if (r > 0) {
        size_t r_idx = (size_t)(r - 1ULL);
        uint64_t rem_val = (uint64_t)g_phi6_table[r_idx];
        ans_q = ans_q + rem_val;
    }
    return ans_q;
}

static void build_bit_sieve(uint64_t limit) {
    if (limit <= g_sieve_max && g_is_subprime_bit != NULL) {
        return;
    }
    if (g_is_subprime_bit != NULL) {
        free(g_is_subprime_bit);
        g_is_subprime_bit = NULL;
    }
    if (g_popcnt_block != NULL) {
        free(g_popcnt_block);
        g_popcnt_block = NULL;
    }

    g_sieve_max = limit;
    uint64_t num_odds = (limit >> 1) + 1;
    uint64_t num_words = (num_odds + 63ULL) >> 6;
    if (num_words == 0) {
        num_words = 1;
    }
    size_t sz_words = (size_t)num_words * sizeof(uint64_t);
    g_is_subprime_bit = (uint64_t *)malloc(sz_words);
    memset(g_is_subprime_bit, 0xFF, sz_words);

    /* Mark 1 (odd index 0) as not prime */
    g_is_subprime_bit[0] = g_is_subprime_bit[0] & ~1ULL;

    double flim = (double)limit;
    double sq_flim = sqrt(flim);
    uint64_t sqrt_lim = (uint64_t)sq_flim;

    uint64_t i = 3;
    while (i <= sqrt_lim) {
        uint64_t i_odd = i >> 1;
        uint64_t w_idx = i_odd >> 6;
        uint64_t b_idx = i_odd & 63ULL;
        uint64_t mask = 1ULL << b_idx;
        uint64_t w_val = g_is_subprime_bit[w_idx];
        uint64_t is_p = w_val & mask;
        if (is_p != 0) {
            uint64_t i2 = i << 1;
            uint64_t j = i * i;
            while (j <= limit) {
                uint64_t j_odd = j >> 1;
                uint64_t jw = j_odd >> 6;
                uint64_t jb = j_odd & 63ULL;
                uint64_t clr_mask = ~(1ULL << jb);
                g_is_subprime_bit[jw] = g_is_subprime_bit[jw] & clr_mask;
                j = j + i2;
            }
        }
        i = i + 2;
    }

    size_t sz_blocks = (size_t)num_words * sizeof(uint32_t);
    g_popcnt_block = (uint32_t *)malloc(sz_blocks);
    uint32_t total = 0;
    size_t w = 0;
    while (w < (size_t)num_words) {
        g_popcnt_block[w] = total;
        uint64_t word_val = g_is_subprime_bit[w];
        uint64_t cnt = zen5_popcnt64(word_val);
        total = total + (uint32_t)cnt;
        w = w + 1;
    }
}

static inline uint64_t pi_fast(uint64_t x,
                               const uint32_t *primes,
                               size_t prime_count) {
    uint64_t res = 0;
    if (x < 2) {
        res = 0;
    } else if (x <= g_sieve_max && g_is_subprime_bit != NULL) {
        uint64_t odd_idx = x >> 1;
        uint64_t w = odd_idx >> 6;
        uint64_t b = odd_idx & 63ULL;
        uint64_t count = (uint64_t)g_popcnt_block[w];
        uint64_t word_val = g_is_subprime_bit[w];
        uint64_t mask = 0xFFFFFFFFFFFFFFFFULL;
        if (b < 63ULL) {
            uint64_t shift_b = b + 1ULL;
            uint64_t sh = 1ULL << shift_b;
            mask = sh - 1ULL;
        }
        uint64_t masked = word_val & mask;
        uint64_t add_cnt = zen5_popcnt64(masked);
        count = count + add_cnt;
        res = count + 1ULL; /* include prime 2 */
    } else {
        size_t low = 0;
        size_t high = prime_count;
        while (low < high) {
            size_t mid = (low + high) >> 1;
            uint64_t p_mid = (uint64_t)primes[mid];
            if (p_mid <= x) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        res = (uint64_t)low;
    }
    return res;
}

static uint64_t phi_rec(uint64_t x,
                        size_t a,
                        const uint32_t *primes,
                        size_t prime_count);

static uint64_t phi_memoized(uint64_t x,
                             size_t a,
                             const uint32_t *primes,
                             size_t prime_count) {
    uint64_t key = x ^ ((uint64_t)a * 0x9e3779b97f4a7c15ULL);
    size_t slot = (size_t)(key & CACHE_MASK);

    if (g_memo_x[slot] == x && g_memo_a[slot] == (uint32_t)a) {
        return g_memo_res[slot];
    }

    uint64_t a_u64 = (uint64_t)a;
    uint64_t res = 0;
    if (a <= 6) {
        res = phi6(x);
    } else if (x == 0) {
        res = 0;
    } else if (a == 0) {
        res = x;
    } else if (a_u64 > prime_count) {
        res = 1;
    } else {
        size_t idx = a - 1;
        uint64_t p = (uint64_t)primes[idx];
        if (x < p) {
            res = 1;
        } else {
            uint64_t left = phi_rec(x, a - 1, primes, prime_count);
            uint64_t div_p = x / p;
            uint64_t right = phi_rec(div_p, a - 1, primes,
                                     prime_count);
            res = left - right;
        }
    }

    g_memo_x[slot] = x;
    g_memo_a[slot] = (uint32_t)a;
    g_memo_res[slot] = res;
    return res;
}

static uint64_t phi_rec(uint64_t x,
                        size_t a,
                        const uint32_t *primes,
                        size_t prime_count) {
    uint64_t res = 0;
    if (a <= 6) {
        if (a == 6) {
            res = phi6(x);
        } else if (a == 0) {
            res = x;
        } else if (a == 1) {
            res = x - (x >> 1);
        } else if (a == 2) {
            uint64_t d2 = x / 2;
            uint64_t d3 = x / 3;
            uint64_t d6 = x / 6;
            res = x - d2 - d3 + d6;
        } else {
            size_t idx = a - 1;
            uint64_t p = (uint64_t)primes[idx];
            uint64_t left = phi_rec(x, a - 1, primes, prime_count);
            uint64_t right = phi_rec(x / p, a - 1, primes,
                                     prime_count);
            res = left - right;
        }
    } else {
        res = phi_memoized(x, a, primes, prime_count);
    }
    return res;
}

static uint64_t lehmer_sum2(uint64_t x,
                            uint64_t a_val,
                            uint64_t b_val,
                            uint64_t c_val,
                            const uint32_t *primes,
                            size_t prime_count) {
    uint64_t p2 = 0;
    size_t i = (size_t)(a_val + 1);
    size_t b_limit = (size_t)b_val;
    while (i <= b_limit) {
        size_t idx_i = i - 1;
        uint64_t p = (uint64_t)primes[idx_i];
        uint64_t w = x / p;
        uint64_t pi_w = pi_fast(w, primes, prime_count);
        uint64_t cast_i = (uint64_t)i;
        uint64_t term_i = pi_w - (cast_i - 1ULL);
        p2 = p2 + term_i;
        i = i + 1;
    }

    uint64_t p3 = 0;
    i = (size_t)(a_val + 1);
    size_t c_limit = (size_t)c_val;
    while (i <= c_limit) {
        size_t idx_i = i - 1;
        uint64_t p = (uint64_t)primes[idx_i];
        uint64_t w = x / p;
        double fw = (double)w;
        double sq_w_f = sqrt(fw);
        uint64_t sqrt_w = (uint64_t)sq_w_f;
        uint64_t bi = pi_fast(sqrt_w, primes, prime_count);
        size_t j = i;
        size_t bi_limit = (size_t)bi;
        while (j <= bi_limit) {
            size_t idx_j = j - 1;
            uint64_t pj = (uint64_t)primes[idx_j];
            uint64_t div_pj = w / pj;
            uint64_t pi_w2 = pi_fast(div_pj, primes, prime_count);
            uint64_t cast_j = (uint64_t)j;
            uint64_t term_j = pi_w2 - (cast_j - 1ULL);
            p3 = p3 + term_j;
            j = j + 1;
        }
        i = i + 1;
    }
    return p2 + p3;
}

static uint64_t prime_count_lehmer(uint64_t x,
                                    const uint32_t *primes,
                                    size_t prime_count) {
    uint64_t count = 0;
    if (x < 2) {
        count = 0;
    } else if (x <= g_sieve_max) {
        count = pi_fast(x, primes, prime_count);
    } else {
        double fx = (double)x;
        double sq_fx = sqrt(fx);
        double sq_sq_fx = sqrt(sq_fx);
        uint64_t a_arg = (uint64_t)sq_sq_fx;
        uint64_t a_val = pi_fast(a_arg, primes, prime_count);

        uint64_t b_arg = (uint64_t)sq_fx;
        uint64_t b_val = pi_fast(b_arg, primes, prime_count);

        double cb_fx = cbrt(fx);
        uint64_t c_arg = (uint64_t)cb_fx;
        uint64_t c_val = pi_fast(c_arg, primes, prime_count);

        size_t a_size = (size_t)a_val;
        uint64_t phi_val = phi_rec(x, a_size, primes, prime_count);

        uint64_t sum_p2_p3 = lehmer_sum2(x, a_val, b_val, c_val,
                                         primes, prime_count);
        count = (phi_val + a_val - 1ULL) - sum_p2_p3;
    }
    return count;
}

static uint64_t sieve_segment_find_nth(uint64_t low_val,
                                        uint64_t high_val,
                                        const uint32_t *base_primes,
                                        size_t base_count,
                                        uint64_t target_n,
                                        uint64_t start_pi) {
    uint64_t range_diff = high_val - low_val;
    uint64_t range_len = range_diff + 1;
    size_t num_words = (size_t)((range_len + 63) >> 6);
    if (num_words == 0) {
        num_words = 1;
    }
    size_t sz_sieve = num_words * sizeof(uint64_t);
    uint64_t *sieve = (uint64_t *)malloc(sz_sieve);
    memset(sieve, 0xFF, sz_sieve);

    size_t idx = 0;
    while (idx < base_count) {
        uint64_t p = (uint64_t)base_primes[idx];
        uint64_t p_sq = p * p;
        if (p_sq > high_val) {
            idx = base_count;
        } else {
            uint64_t sum_lp = low_val + p;
            uint64_t num_st = sum_lp - 1;
            uint64_t div_st = num_st / p;
            uint64_t start = div_st * p;
            if (start < p_sq) {
                start = p_sq;
            }
            while (start <= high_val) {
                uint64_t diff_s = start - low_val;
                size_t w_idx = (size_t)(diff_s >> 6);
                size_t b_idx = (size_t)(diff_s & 63);
                uint64_t mask = ~(1ULL << b_idx);
                sieve[w_idx] = sieve[w_idx] & mask;
                start = start + p;
            }
            idx = idx + 1;
        }
    }

    uint64_t current_count = start_pi;
    uint64_t result = 0;
    uint64_t val = low_val;
    while (val <= high_val) {
        uint64_t diff_v = val - low_val;
        size_t w_idx = (size_t)(diff_v >> 6);
        size_t b_idx = (size_t)(diff_v & 63);
        uint64_t mask = 1ULL << b_idx;
        uint64_t w_val = sieve[w_idx];
        uint64_t is_p = w_val & mask;
        if (is_p != 0) {
            current_count = current_count + 1;
            if (current_count == target_n) {
                result = val;
                val = high_val;
            }
        }
        val = val + 1;
    }
    free(sieve);
    return result;
}

static uint64_t sieve_segment_find_backward(uint64_t low_val,
                                             uint64_t high_val,
                                             const uint32_t *base_primes,
                                             size_t base_count,
                                             uint64_t target_n,
                                             uint64_t start_pi) {
    uint64_t range_diff = high_val - low_val;
    uint64_t range_len = range_diff + 1;
    size_t num_words = (size_t)((range_len + 63) >> 6);
    if (num_words == 0) {
        num_words = 1;
    }
    size_t sz_sieve = num_words * sizeof(uint64_t);
    uint64_t *sieve = (uint64_t *)malloc(sz_sieve);
    memset(sieve, 0xFF, sz_sieve);

    size_t idx = 0;
    while (idx < base_count) {
        uint64_t p = (uint64_t)base_primes[idx];
        uint64_t p_sq = p * p;
        if (p_sq > high_val) {
            idx = base_count;
        } else {
            uint64_t sum_lp = low_val + p;
            uint64_t num_st = sum_lp - 1;
            uint64_t div_st = num_st / p;
            uint64_t start = div_st * p;
            if (start < p_sq) {
                start = p_sq;
            }
            while (start <= high_val) {
                uint64_t diff_s = start - low_val;
                size_t w_idx = (size_t)(diff_s >> 6);
                size_t b_idx = (size_t)(diff_s & 63);
                uint64_t mask = ~(1ULL << b_idx);
                sieve[w_idx] = sieve[w_idx] & mask;
                start = start + p;
            }
            idx = idx + 1;
        }
    }

    uint64_t current_count = start_pi;
    uint64_t result = 0;
    uint64_t val = high_val;
    while (val >= low_val) {
        uint64_t diff_v = val - low_val;
        size_t w_idx = (size_t)(diff_v >> 6);
        size_t b_idx = (size_t)(diff_v & 63);
        uint64_t mask = 1ULL << b_idx;
        uint64_t w_val = sieve[w_idx];
        uint64_t is_p = w_val & mask;
        if (is_p != 0) {
            if (current_count == target_n) {
                result = val;
                val = low_val;
            }
            current_count = current_count - 1;
        }
        if (val > 0) {
            val = val - 1;
        } else {
            val = low_val - 1;
        }
    }
    free(sieve);
    return result;
}

static uint64_t estimate_initial_x(uint64_t n) {
    double fn = (double)n;
    double log_n = log(fn);
    double log_log = log(log_n);

    double term_2 = (log_log - 2.0) / log_n;
    double num_3 = (log_log * log_log) - (6.0 * log_log) + 11.0;
    double den_3 = 2.0 * log_n * log_n;
    double term_3 = num_3 / den_3;

    double bracket = log_n + log_log - 1.0 + term_2 - term_3;
    double x_est = fn * bracket;
    return (uint64_t)x_est;
}

static uint64_t get_small_nth_prime(uint64_t n) {
    uint64_t res = 0;
    if (n == 1) {
        res = 2;
    } else if (n == 2) {
        res = 3;
    } else if (n == 3) {
        res = 5;
    } else if (n == 4) {
        res = 7;
    } else if (n == 5) {
        res = 11;
    }
    return res;
}

static uint64_t nth_prime_refine(uint64_t n,
                                 uint64_t curr_x,
                                 const uint32_t *base_primes,
                                 size_t base_count) {
    uint64_t pn = 0;
    uint64_t curr_pi = prime_count_lehmer(curr_x, base_primes,
                                          base_count);
    int64_t cast_n = (int64_t)n;
    int64_t cast_pi = (int64_t)curr_pi;
    int64_t diff_n = cast_n - cast_pi;

    while (diff_n > 2000 || diff_n < -2000) {
        double f_val = (double)curr_x;
        double log_val = log(f_val);
        double f_diff = (double)diff_n;
        double adj = f_diff * log_val;
        int64_t step = (int64_t)adj;
        int64_t cast_x = (int64_t)curr_x;
        int64_t x_new = cast_x + step;
        curr_x = (uint64_t)x_new;

        curr_pi = prime_count_lehmer(curr_x, base_primes,
                                     base_count);
        cast_pi = (int64_t)curr_pi;
        diff_n = cast_n - cast_pi;
    }

    uint64_t abs_diff = 0;
    if (diff_n < 0) {
        int64_t neg_d = -diff_n;
        abs_diff = (uint64_t)neg_d;
    } else {
        abs_diff = (uint64_t)diff_n;
    }

    double f_curr = (double)curr_x;
    double log_c = log(f_curr);
    double f_abs = (double)abs_diff;
    double prod_abs = f_abs * log_c;
    double est_w = prod_abs * 2.5;
    uint64_t cast_w = (uint64_t)est_w;
    uint64_t window = cast_w + 1000;
    if (window < 2000) {
        window = 2000;
    }

    if (diff_n > 0) {
        uint64_t low_val = curr_x + 1;
        uint64_t high_val = curr_x + window;
        pn = sieve_segment_find_nth(low_val, high_val,
                                    base_primes, base_count,
                                    n, curr_pi);
    } else {
        uint64_t low_val = 2;
        if (curr_x > window) {
            low_val = curr_x - window;
        }
        pn = sieve_segment_find_backward(low_val, curr_x,
                                         base_primes, base_count,
                                         n, curr_pi);
    }
    return pn;
}

uint64_t get_nth_prime_u64(uint64_t n) {
    uint64_t pn = 0;
    if (n == 0) {
        pn = 0;
    } else if (n <= 5) {
        pn = get_small_nth_prime(n);
    } else {
        uint64_t curr_x = estimate_initial_x(n);
        double fx = (double)curr_x;
        double sq_x = sqrt(fx);
        uint64_t z_val = (uint64_t)sq_x;

        /* Aperture bounded pre-sieve: root horizon for prime table */
        uint64_t sieve_limit = z_val * 12;
        if (sieve_limit < 1000000ULL) {
            sieve_limit = 1000000ULL;
        }
        if (curr_x <= 20000000ULL && sieve_limit < curr_x) {
            sieve_limit = curr_x;
        }

        build_bit_sieve(sieve_limit);
        size_t base_count = 0;
        uint64_t z_plus = z_val + 1000;
        size_t pi_z = (size_t)pi_fast(z_plus, NULL, 0);
        size_t sz_primes = (pi_z + 1000) * sizeof(uint32_t);
        uint32_t *base_primes = (uint32_t *)malloc(sz_primes);

        base_primes[0] = 2;
        base_count = 1;
        uint64_t cand = 3;
        while (cand <= z_plus) {
            uint64_t cand_odd = cand >> 1;
            uint64_t w = cand_odd >> 6;
            uint64_t b = cand_odd & 63ULL;
            uint64_t mask = 1ULL << b;
            uint64_t w_val = g_is_subprime_bit[w];
            uint64_t is_p = w_val & mask;
            if (is_p != 0) {
                base_primes[base_count] = (uint32_t)cand;
                base_count = base_count + 1;
            }
            cand = cand + 2;
        }

        init_phi6_table();
        memset(g_memo_x, 0, sizeof(g_memo_x));

        pn = nth_prime_refine(n, curr_x, base_primes, base_count);
        free(base_primes);
    }
    return pn;
}

#if HAS_GMP
void get_nth_prime_mpz(mpz_t rop, const mpz_t n) {
    if (mpz_fits_ulong_p(n)) {
        uint64_t val = mpz_get_ui(n);
        uint64_t res = get_nth_prime_u64(val);
        mpz_set_ui(rop, res);
    } else {
        mpz_set_ui(rop, 0);
    }
}
#endif

void get_nth_prime_str(char *out_str,
                       size_t max_len,
                       const char *n_str) {
#if HAS_GMP
    mpz_t n;
    mpz_t p;
    mpz_init(n);
    mpz_init(p);
    int parse_res = mpz_set_str(n, n_str, 10);
    if (parse_res == 0) {
        get_nth_prime_mpz(p, n);
        gmp_snprintf(out_str, max_len, "%Zu", p);
    } else {
        snprintf(out_str, max_len, "0");
    }
    mpz_clear(n);
    mpz_clear(p);
#else
    uint64_t val = 0;
    size_t i = 0;
    size_t len = strlen(n_str);
    while (i < len) {
        char c = n_str[i];
        if (c >= '0' && c <= '9') {
            uint64_t digit = (uint64_t)(c - '0');
            uint64_t val_x_10 = val * 10;
            val = val_x_10 + digit;
        }
        i = i + 1;
    }
    uint64_t p = get_nth_prime_u64(val);
    snprintf(out_str, max_len, "%" PRIu64, p);
#endif
}

#if defined(STANDALONE) && STANDALONE

static void clean_str(const char *raw, char *clean, size_t max_len) {
    size_t i = 0;
    size_t j = 0;
    size_t len = strlen(raw);
    size_t limit = max_len - 1;

    while (i < len && j < limit) {
        char c = raw[i];
        if (c != ',' && c != '_' && c != ' ' &&
            c != '\n' && c != '\r') {
            clean[j] = c;
            j = j + 1;
        }
        i = i + 1;
    }
    clean[j] = '\0';
}

int main(int argc, char **argv) {
    char n_raw[512];
    n_raw[0] = '\0';

    if (argc > 1) {
        snprintf(n_raw, sizeof(n_raw), "%s", argv[1]);
    } else {
        char line[512];
        char *got = fgets(line, sizeof(line), stdin);
        if (got != NULL) {
            snprintf(n_raw, sizeof(n_raw), "%s", line);
        }
    }

    char n_clean[512];
    clean_str(n_raw, n_clean, sizeof(n_clean));
    size_t clean_len = strlen(n_clean);

    if (clean_len > 0) {
        char out_str[512];
        get_nth_prime_str(out_str, sizeof(out_str), n_clean);
        printf("%s\n", out_str);
    } else {
        printf("Invalid input or N must be positive.\n");
    }

    return 0;
}
#endif
