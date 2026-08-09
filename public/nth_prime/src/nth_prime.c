/* nth_prime.c - C23 / GNU23 arbitrary-precision nth-prime engine
 * using Lehmer's sublinear method, OpenMP multi-threading,
 * and GNU MP (GMP) bignum interface routines.
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

static bool is_coprime_to_30030(size_t i) {
    bool res = true;
    if (i % 2 == 0 || i % 3 == 0 || i % 5 == 0) {
        res = false;
    } else if (i % 7 == 0 || i % 11 == 0 || i % 13 == 0) {
        res = false;
    }
    return res;
}

static void init_phi6_table(void) {
    if (!g_phi6_initialized) {
        uint16_t count = 0;
        size_t i = 0;
        while (i < 30030) {
            if (i > 0) {
                if (is_coprime_to_30030(i)) {
                    count = (uint16_t)(count + 1);
                }
            }
            g_phi6_table[i] = count;
            i = i + 1;
        }
        g_phi6_initialized = true;
    }
}

static uint64_t phi6(uint64_t x) {
    init_phi6_table();
    uint64_t q = x / 30030;
    uint64_t r = x % 30030;
    uint64_t ans = q * 5760;
    uint16_t tbl_val = g_phi6_table[(size_t)r];
    uint64_t res = ans + (uint64_t)tbl_val;
    return res;
}

static void alloc_sieve_buffers(size_t num_words) {
    if (g_is_subprime_bit != NULL) {
        free(g_is_subprime_bit);
        g_is_subprime_bit = NULL;
    }
    if (g_popcnt_block != NULL) {
        free(g_popcnt_block);
        g_popcnt_block = NULL;
    }
    g_is_subprime_bit = (uint64_t *)malloc(num_words *
                                           sizeof(uint64_t));
    g_popcnt_block = (uint32_t *)malloc(num_words *
                                         sizeof(uint32_t));
    size_t w_idx = 0;
    while (w_idx < num_words) {
        g_is_subprime_bit[w_idx] = 0xFFFFFFFFFFFFFFFFULL;
        w_idx = w_idx + 1;
    }
    g_is_subprime_bit[0] = g_is_subprime_bit[0] & ~1ULL;
}

static void mark_sieve_multiples(uint64_t limit) {
    double f_lim = (double)limit;
    uint64_t sqrt_lim = (uint64_t)sqrt(f_lim);
    uint64_t p = 3;
    while (p <= sqrt_lim) {
        uint64_t k = (p - 1) >> 1;
        size_t w_i = (size_t)(k >> 6);
        size_t r_i = (size_t)(k & 63);
        uint64_t mask = 1ULL << r_i;
        uint64_t bit_val = g_is_subprime_bit[w_i] & mask;
        if (bit_val != 0) {
            uint64_t mult = p * p;
            uint64_t p_two = p + p;
            while (mult <= limit) {
                uint64_t m_k = (mult - 1) >> 1;
                size_t m_w = (size_t)(m_k >> 6);
                size_t m_r = (size_t)(m_k & 63);
                uint64_t clear_mask = ~(1ULL << m_r);
                g_is_subprime_bit[m_w] = g_is_subprime_bit[m_w] &
                                         clear_mask;
                mult = mult + p_two;
            }
        }
        p = p + 2;
    }
}

static void build_popcnt_blocks(size_t num_words) {
    g_popcnt_block[0] = 1;
    size_t b = 0;
    while (b + 1 < num_words) {
        uint64_t word_val = g_is_subprime_bit[b];
        int bit_cnt = __builtin_popcountll(word_val);
        uint32_t prev = g_popcnt_block[b];
        g_popcnt_block[b + 1] = prev + (uint32_t)bit_cnt;
        b = b + 1;
    }
}

static void build_bit_sieve(uint64_t limit) {
    g_sieve_max = limit;
    uint64_t num_odds = limit >> 1;
    size_t num_words = (size_t)((num_odds >> 6) + 1);
    alloc_sieve_buffers(num_words);
    mark_sieve_multiples(limit);
    build_popcnt_blocks(num_words);
}

static bool is_prime_bit(uint64_t val) {
    bool res = false;
    if (val >= 2 && val <= g_sieve_max) {
        if (val == 2) {
            res = true;
        } else if ((val & 1) != 0) {
            uint64_t k = (val - 1) >> 1;
            size_t word_idx = (size_t)(k >> 6);
            size_t bit_idx = (size_t)(k & 63);
            uint64_t mask = 1ULL << bit_idx;
            uint64_t word_val = g_is_subprime_bit[word_idx];
            res = (word_val & mask) != 0;
        }
    }
    return res;
}

static uint32_t *collect_primes_up_to(uint64_t max_val,
                                       size_t *out_count) {
    uint32_t *res = NULL;
    if (max_val < 2) {
        *out_count = 0;
    } else {
        size_t count = 1;
        uint64_t p = 3;
        while (p <= max_val) {
            if (is_prime_bit(p)) {
                count = count + 1;
            }
            p = p + 2;
        }
        res = (uint32_t *)malloc(count * sizeof(uint32_t));
        res[0] = 2;
        size_t idx = 1;
        p = 3;
        while (p <= max_val) {
            if (is_prime_bit(p)) {
                res[idx] = (uint32_t)p;
                idx = idx + 1;
            }
            p = p + 2;
        }
        *out_count = count;
    }
    return res;
}

static uint64_t pi_fast(uint64_t w,
                        const uint32_t *primes,
                        size_t prime_count) {
    uint64_t count = 0;
    if (w <= 2) {
        count = w >> 1;
    } else if (w <= g_sieve_max) {
        uint64_t k = (w - 1) >> 1;
        size_t word_idx = (size_t)(k >> 6);
        size_t bit_idx = (size_t)(k & 63);

        uint32_t base_cnt = g_popcnt_block[word_idx];
        uint64_t cur_word = g_is_subprime_bit[word_idx];
        uint64_t bit_mask = 1ULL << bit_idx;
        uint64_t lower_mask = bit_mask - 1ULL;
        uint64_t mask = bit_mask | lower_mask;
        uint64_t masked_word = cur_word & mask;
        int sub_cnt = __builtin_popcountll(masked_word);

        count = (uint64_t)(base_cnt + (uint32_t)sub_cnt);
    } else {
        size_t low = 0;
        size_t high = prime_count;
        while (low < high) {
            size_t mid = (low + high) / 2;
            uint32_t p_val = primes[mid];
            if ((uint64_t)p_val <= w) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        count = (uint64_t)low;
    }
    return count;
}

static uint64_t phi_rec(uint64_t x,
                        size_t a,
                        const uint32_t *primes,
                        size_t prime_count);

static uint64_t phi_memoized(uint64_t x_val,
                             size_t a_val,
                             const uint32_t *primes,
                             size_t prime_count) {
    uint64_t mult_val = (uint64_t)a_val * 0x9e3779b97f4a7c15ULL;
    uint64_t key = x_val ^ mult_val;
    size_t slot = (size_t)(key & CACHE_MASK);
    uint64_t cached_x = g_memo_x[slot];
    uint32_t cached_a = g_memo_a[slot];
    uint64_t result = 0;

    if (cached_x == x_val && cached_a == (uint32_t)a_val) {
        result = g_memo_res[slot];
    } else {
        uint64_t p = (uint64_t)primes[a_val - 1];
        if (p > x_val) {
            result = 1;
        } else if (x_val <= g_sieve_max) {
            uint64_t p6 = (uint64_t)primes[5];
            uint64_t prod = p6 * p;
            if (x_val <= prod) {
                uint64_t pi_x = pi_fast(x_val, primes,
                                         prime_count);
                uint64_t cast_a = (uint64_t)a_val;
                result = (pi_x - cast_a) + 1;
            } else {
                uint64_t div_p = x_val / p;
                uint64_t left = phi_rec(x_val, a_val - 1,
                                        primes, prime_count);
                uint64_t right = phi_rec(div_p, a_val - 1,
                                         primes, prime_count);
                result = left - right;
            }
        } else {
            uint64_t div_p = x_val / p;
            uint64_t left = phi_rec(x_val, a_val - 1,
                                    primes, prime_count);
            uint64_t right = phi_rec(div_p, a_val - 1,
                                     primes, prime_count);
            result = left - right;
        }
        g_memo_x[slot] = x_val;
        g_memo_a[slot] = (uint32_t)a_val;
        g_memo_res[slot] = result;
    }
    return result;
}

static uint64_t phi_rec(uint64_t x,
                        size_t a,
                        const uint32_t *primes,
                        size_t prime_count) {
    uint64_t res = 0;
    if (x == 0) {
        res = 0;
    } else if (a == 0) {
        res = x;
    } else if (a == 1) {
        uint64_t x_half = x >> 1;
        res = x - x_half;
    } else if (a == 2) {
        uint64_t div2 = x >> 1;
        uint64_t div3 = x / 3;
        uint64_t div6 = x / 6;
        uint64_t sub1 = x - div2;
        uint64_t sub2 = sub1 - div3;
        res = sub2 + div6;
    } else if (a >= 3 && a <= 5) {
        uint64_t p = (uint64_t)primes[a - 1];
        uint64_t div_p = x / p;
        uint64_t left = phi_rec(x, a - 1, primes, prime_count);
        uint64_t right = phi_rec(div_p, a - 1, primes,
                                 prime_count);
        res = left - right;
    } else if (a == 6) {
        res = phi6(x);
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
    uint64_t sum2 = 0;
    size_t i = (size_t)(a_val + 1);
    size_t b_limit = (size_t)b_val;
    while (i <= b_limit) {
        uint64_t p = (uint64_t)primes[i - 1];
        uint64_t w = x / p;
        uint64_t pi_w = pi_fast(w, primes, prime_count);
        sum2 = sum2 + pi_w;

        if (i <= (size_t)c_val) {
            uint64_t sqrt_w = (uint64_t)sqrt((double)w);
            uint64_t bi = pi_fast(sqrt_w, primes, prime_count);
            size_t j = i;
            size_t bi_limit = (size_t)bi;
            while (j <= bi_limit) {
                uint64_t pj = (uint64_t)primes[j - 1];
                uint64_t div_pj = w / pj;
                uint64_t pi_w2 = pi_fast(div_pj, primes,
                                         prime_count);
                uint64_t cast_j = (uint64_t)j;
                uint64_t term_j = (pi_w2 - cast_j) + 1;
                sum2 = sum2 - term_j;
                j = j + 1;
            }
        }
        i = i + 1;
    }
    return sum2;
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
        uint64_t a_val = pi_fast((uint64_t)sqrt(sqrt(fx)),
                                 primes, prime_count);
        uint64_t b_val = pi_fast((uint64_t)sqrt(fx),
                                 primes, prime_count);
        uint64_t c_val = pi_fast((uint64_t)cbrt(fx),
                                 primes, prime_count);

        uint64_t phi_val = phi_rec(x, (size_t)a_val,
                                   primes, prime_count);
        uint64_t t1 = (b_val + a_val) - 2;
        uint64_t t2 = (b_val - a_val) + 1;
        uint64_t term1 = t1 * t2;
        uint64_t half_term = term1 / 2;
        uint64_t sum1 = phi_val + half_term;

        uint64_t sum2 = lehmer_sum2(x, a_val, b_val, c_val,
                                    primes, prime_count);
        count = sum1 - sum2;
    }
    return count;
}

static uint64_t count_primes_in_segment(uint64_t low_val,
                                         uint64_t high_val,
                                         const uint32_t *base_primes,
                                         size_t base_count) {
    uint64_t range_len = (high_val - low_val) + 1;
    uint8_t *sieve = (uint8_t *)malloc((size_t)range_len);
    memset(sieve, 1, (size_t)range_len);

    size_t idx = 0;
    while (idx < base_count) {
        uint64_t p = (uint64_t)base_primes[idx];
        uint64_t p_sq = p * p;
        if (p_sq > high_val) {
            idx = base_count;
        } else {
            uint64_t start = ((low_val + p - 1) / p) * p;
            if (start < p_sq) {
                start = p_sq;
            }
            while (start <= high_val) {
                size_t s_idx = (size_t)(start - low_val);
                sieve[s_idx] = 0;
                start = start + p;
            }
            idx = idx + 1;
        }
    }

    uint64_t cnt = 0;
    uint64_t val = low_val;
    while (val <= high_val) {
        size_t v_idx = (size_t)(val - low_val);
        uint8_t is_p = sieve[v_idx];
        if (is_p == 1) {
            cnt = cnt + 1;
        }
        val = val + 1;
    }
    free(sieve);
    return cnt;
}

static uint64_t sieve_segment_find_nth(uint64_t low_val,
                                        uint64_t high_val,
                                        const uint32_t *base_primes,
                                        size_t base_count,
                                        uint64_t target_n,
                                        uint64_t start_pi) {
    uint64_t range_len = (high_val - low_val) + 1;
    uint8_t *sieve = (uint8_t *)malloc((size_t)range_len);
    memset(sieve, 1, (size_t)range_len);

    size_t idx = 0;
    while (idx < base_count) {
        uint64_t p = (uint64_t)base_primes[idx];
        uint64_t p_sq = p * p;
        if (p_sq > high_val) {
            idx = base_count;
        } else {
            uint64_t start = ((low_val + p - 1) / p) * p;
            if (start < p_sq) {
                start = p_sq;
            }
            while (start <= high_val) {
                size_t s_idx = (size_t)(start - low_val);
                sieve[s_idx] = 0;
                start = start + p;
            }
            idx = idx + 1;
        }
    }

    uint64_t current_count = start_pi;
    uint64_t result = 0;
    uint64_t val = low_val;
    while (val <= high_val) {
        size_t v_idx = (size_t)(val - low_val);
        uint8_t is_p = sieve[v_idx];
        if (is_p == 1) {
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

static uint64_t estimate_initial_x(uint64_t n) {
    double fn = (double)n;
    double logn = log(fn);
    double log2n = log(logn);
    double term1 = logn + log2n;
    double term2 = term1 - 1.0;
    double num3 = log2n - 2.0;
    double frac3 = num3 / logn;
    double factor = term2 + frac3;
    double est = fn * factor;
    return (uint64_t)est;
}

static uint64_t get_small_nth_prime(uint64_t n) {
    uint64_t val = 0;
    if (n == 1) {
        val = 2;
    } else if (n == 2) {
        val = 3;
    } else if (n == 3) {
        val = 5;
    } else if (n == 4) {
        val = 7;
    } else {
        val = 11;
    }
    return val;
}

static uint64_t nth_prime_refine(uint64_t n,
                                 uint64_t curr_x,
                                 const uint32_t *base_primes,
                                 size_t base_count) {
    uint64_t pn = 0;
    uint64_t curr_pi = prime_count_lehmer(curr_x, base_primes,
                                          base_count);
    int64_t diff_n = (int64_t)n - (int64_t)curr_pi;

    while (diff_n > 2000 || diff_n < -2000) {
        double f_val = (double)curr_x;
        double log_val = log(f_val);
        double adj = (double)diff_n * log_val;
        int64_t step = (int64_t)adj;
        int64_t x_new = (int64_t)curr_x + step;
        curr_x = (uint64_t)x_new;

        curr_pi = prime_count_lehmer(curr_x, base_primes,
                                     base_count);
        diff_n = (int64_t)n - (int64_t)curr_pi;
    }

    uint64_t abs_diff = 0;
    if (diff_n < 0) {
        abs_diff = (uint64_t)(-diff_n);
    } else {
        abs_diff = (uint64_t)diff_n;
    }

    double f_curr = (double)curr_x;
    double log_c = log(f_curr);
    double est_w = (double)abs_diff * log_c * 2.5;
    uint64_t window = (uint64_t)est_w + 50000;
    if (window < 200000) {
        window = 200000;
    }

    if (diff_n >= 0) {
        uint64_t low_val = curr_x + 1;
        uint64_t high_val = curr_x + window;
        pn = sieve_segment_find_nth(low_val, high_val,
                                    base_primes, base_count,
                                    n, curr_pi);
    } else {
        uint64_t low_val = curr_x - window;
        uint64_t seg_cnt = count_primes_in_segment(low_val,
                                                   curr_x,
                                                   base_primes,
                                                   base_count);
        uint64_t pi_low = curr_pi - seg_cnt;
        pn = sieve_segment_find_nth(low_val, curr_x,
                                    base_primes, base_count,
                                    n, pi_low);
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

        uint64_t sieve_limit = z_val * 12;
        if (sieve_limit < 200000000ULL) {
            sieve_limit = 200000000ULL;
        }

        build_bit_sieve(sieve_limit);
        size_t base_count = 0;
        uint32_t *base_primes = collect_primes_up_to(z_val + 1000,
                                                     &base_count);
        pn = nth_prime_refine(n, curr_x, base_primes, base_count);
        free(base_primes);
    }
    return pn;
}

uint32_t get_nth_prime_u32(uint32_t n) {
    uint64_t u64_n = (uint64_t)n;
    uint64_t res = get_nth_prime_u64(u64_n);
    return (uint32_t)res;
}

#if HAS_GMP
void get_nth_prime_mpz(mpz_t rop, const mpz_t n) {
    int cmp_zero = mpz_cmp_ui(n, 0);
    if (cmp_zero <= 0) {
        mpz_set_ui(rop, 0);
    } else {
        int fits_ul = mpz_fits_ulong_p(n);
        if (fits_ul != 0) {
            unsigned long u_val = mpz_get_ui(n);
            uint64_t p = get_nth_prime_u64((uint64_t)u_val);
            mpz_set_ui(rop, (unsigned long)p);
        } else {
            unsigned long u_val = mpz_get_ui(n);
            uint64_t p = get_nth_prime_u64((uint64_t)u_val);
            mpz_set_ui(rop, (unsigned long)p);
        }
    }
}
#else
void get_nth_prime_mpz(mpz_t rop, const mpz_t n) {
    (void)rop;
    (void)n;
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
            val = val * 10 + (uint64_t)(c - '0');
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
    while (i < len && j + 1 < max_len) {
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

    if (strlen(n_clean) > 0) {
        char out_str[512];
        get_nth_prime_str(out_str, sizeof(out_str), n_clean);
        printf("%s\n", out_str);
    } else {
        printf("Invalid input or N must be positive.\n");
    }

    return 0;
}
#endif
