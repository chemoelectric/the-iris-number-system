#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <omp.h>
#include "prime_c.h"

#if defined(__x86_64__) || defined(_M_X64)
#  include <immintrin.h>
#endif

#define P6_VAL 30030LL
#define PHI6_P6_VAL 5760LL

#define P7_VAL 510510LL
#define PHI7_P7_VAL 92160LL

#define HASH_SIZE 16777216LL

typedef struct {
  int64_t x;
  int64_t a;
  int64_t v;
} cache_entry_t;

static uint64_t *bitset = NULL;
static uint32_t *pi_samples = NULL;
static int64_t max_sieve_limit = 0;
static int64_t num_odds_glob = 0;

static int64_t *global_primes_c = NULL;
static int64_t global_num_primes_c = 0;

static int64_t *phi7_tbl = NULL;
static bool phi7_done = false;

static cache_entry_t *cache_tbl = NULL;

static inline bool is_coprime_p7(int64_t v) {
  bool ok = true;
  int64_t m2 = v % 2;
  int64_t m3 = v % 3;
  int64_t m5 = v % 5;
  int64_t m7 = v % 7;
  int64_t m11 = v % 11;
  int64_t m13 = v % 13;
  int64_t m17 = v % 17;

  if (m2 == 0 || m3 == 0 || m5 == 0) {
    ok = false;
  } else if (m7 == 0 || m11 == 0) {
    ok = false;
  } else if (m13 == 0 || m17 == 0) {
    ok = false;
  }
  return ok;
}

static void init_phi7_table(void) {
  int64_t count = 0;
  int64_t i = 1;
  size_t sz;

  if (phi7_done == false) {
    sz = (size_t)P7_VAL * sizeof(int64_t);
    phi7_tbl = (int64_t *)malloc(sz);
    phi7_tbl[0] = 0;
    while (i < P7_VAL) {
      if (is_coprime_p7(i) == true) {
        count = count + 1;
      }
      phi7_tbl[i] = count;
      i = i + 1;
    }
    phi7_done = true;
  }
}

static void clear_cache_tbl(void) {
  int64_t i = 0;

  if (cache_tbl != NULL) {
    while (i < HASH_SIZE) {
      cache_tbl[i].x = -1;
      cache_tbl[i].a = -1;
      cache_tbl[i].v = -1;
      i = i + 1;
    }
  }
}

static void sieve_c_primes(int64_t limit) {
  int64_t num_odds = limit / 2;
  int64_t words = (num_odds + 63) / 64;
  int64_t i = 0;
  double rlim = (double)limit;
  int64_t sq_lim = (int64_t)sqrt(rlim);
  int64_t k = 1;
  int64_t p;
  int64_t start_idx;
  int64_t step;
  int64_t idx;
  size_t sz_words;
  size_t sz_primes;
  uint32_t running_count = 0;
  uint64_t word;
  uint64_t mask;
  uint64_t bit_mask;
  uint64_t w;
  uint64_t m;
  int pop;
  int64_t prime_idx;
  int64_t odd_i;

  if (bitset != NULL) {
    free(bitset);
  }
  if (pi_samples != NULL) {
    free(pi_samples);
  }
  if (global_primes_c != NULL) {
    free(global_primes_c);
  }

  max_sieve_limit = limit;
  num_odds_glob = num_odds;

  sz_words = (size_t)words;
  bitset = (uint64_t *)calloc(sz_words, sizeof(uint64_t));
  pi_samples = (uint32_t *)calloc(sz_words, sizeof(uint32_t));

  i = 0;
  while (i < words) {
    bitset[i] = ~0ULL;
    i = i + 1;
  }

  bitset[0] = bitset[0] & ~1ULL;

  while (k <= sq_lim / 2) {
    word = bitset[k / 64];
    mask = 1ULL << (k % 64);
    if ((word & mask) != 0ULL) {
      p = 2 * k + 1;
      start_idx = (p * p - 1) / 2;
      step = p;
      idx = start_idx;
      while (idx < num_odds) {
        bit_mask = 1ULL << (idx % 64);
        bitset[idx / 64] = bitset[idx / 64] & ~bit_mask;
        idx = idx + step;
      }
    }
    k = k + 1;
  }

  i = 0;
  while (i < words) {
    pi_samples[i] = running_count;
    pop = __builtin_popcountll(bitset[i]);
    running_count = running_count + (uint32_t)pop;
    i = i + 1;
  }

  global_num_primes_c = 1 + (int64_t)running_count;
  sz_primes = (size_t)global_num_primes_c;
  sz_primes = sz_primes * sizeof(int64_t);
  global_primes_c = (int64_t *)malloc(sz_primes);
  global_primes_c[0] = 0;
  global_primes_c[1] = 2;

  prime_idx = 2;
  odd_i = 1;
  while (odd_i < num_odds) {
    w = bitset[odd_i / 64];
    m = 1ULL << (odd_i % 64);
    if ((w & m) != 0ULL) {
      global_primes_c[prime_idx] = 2 * odd_i + 1;
      prime_idx = prime_idx + 1;
    }
    odd_i = odd_i + 1;
  }
}

int64_t c_pi_small(int64_t y) {
  int64_t res = 0;
  int64_t y_odd;
  int64_t block;
  int64_t offset;
  uint64_t word;
  uint64_t mask = 0ULL;
  uint64_t masked;
  int pop;
  int64_t base_cnt;
  int64_t p_max;
  int64_t low;
  int64_t high;
  int64_t ans;
  int64_t mid;
  int64_t p_mid;

  if (y < 2) {
    res = 0;
  } else if (y == 2) {
    res = 1;
  } else if (y <= max_sieve_limit) {
    y_odd = (y - 1) / 2;
    block = y_odd / 64;
    offset = y_odd % 64;
    word = bitset[block];
    if (offset == 63) {
      mask = ~0ULL;
    } else {
      mask = (1ULL << (offset + 1)) - 1ULL;
    }
    masked = word & mask;
    pop = __builtin_popcountll(masked);
    base_cnt = (int64_t)pi_samples[block];
    res = base_cnt + 1 + (int64_t)pop;
  } else if (global_num_primes_c > 0) {
    p_max = global_primes_c[global_num_primes_c - 1];
    if (y >= p_max) {
      res = global_num_primes_c - 1;
    } else {
      low = 1;
      high = global_num_primes_c - 1;
      ans = 0;
      while (low <= high) {
        mid = (low + high) / 2;
        p_mid = global_primes_c[mid];
        if (p_mid <= y) {
          ans = mid;
          low = mid + 1;
        } else {
          high = mid - 1;
        }
      }
      res = ans;
    }
  }
  return res;
}

static bool check_cache_c(int64_t x, int64_t a, int64_t *val,
                          int64_t *h_idx) {
  bool found = false;
  int64_t key;
  int64_t idx;
  int64_t probe = 0;
  int64_t first_empty = -1;

  *val = 0;
  *h_idx = -1;

  key = x * 3141592653589793238LL;
  key = key + a * 2718281828459045235LL;
  idx = (key ^ (key >> 22)) % HASH_SIZE;
  if (idx < 0) {
    idx = -idx;
  }

  while (probe < 64) {
    if (cache_tbl[idx].x == x) {
      if (cache_tbl[idx].a == a) {
        *val = cache_tbl[idx].v;
        found = true;
        *h_idx = idx;
        probe = 64;
      }
    } else if (cache_tbl[idx].x == -1) {
      if (first_empty == -1) {
        first_empty = idx;
      }
      probe = 64;
    }
    if (found == false) {
      if (probe < 64) {
        idx = (idx + 1) % HASH_SIZE;
        probe = probe + 1;
      }
    }
  }

  if (found == false) {
    if (first_empty != -1) {
      *h_idx = first_empty;
    } else {
      *h_idx = idx;
    }
  }

  return found;
}

static void store_cache_c(int64_t x, int64_t a, int64_t val,
                          int64_t h_idx) {
  if (h_idx >= 0) {
    cache_tbl[h_idx].x = x;
    cache_tbl[h_idx].a = a;
    cache_tbl[h_idx].v = val;
  }
}

int64_t c_phi_recursive(int64_t x, int64_t a) {
  int64_t res = 0;
  int64_t h_idx = -1;
  int64_t p_a;
  int64_t p_a_sq;
  int64_t v1;
  int64_t v2;
  int64_t q_val;
  int64_t r_val;
  int64_t term_q;
  int64_t term_r;
  int64_t pi_x;
  bool found = false;

  if (x == 0) {
    res = 0;
  } else if (a == 0) {
    res = x;
  } else if (a == 1) {
    res = x - (x / 2);
  } else if (a == 7) {
    q_val = x / P7_VAL;
    r_val = x % P7_VAL;
    term_q = q_val * PHI7_P7_VAL;
    term_r = phi7_tbl[r_val];
    res = term_q + term_r;
  } else {
    p_a = global_primes_c[a];
    if (x < p_a) {
      res = 1;
    } else {
      p_a_sq = p_a * p_a;
      if (x < p_a_sq) {
        pi_x = c_pi_small(x);
        res = pi_x - a + 1;
      } else {
        found = check_cache_c(x, a, &res, &h_idx);
        if (found == false) {
          v1 = c_phi_recursive(x, a - 1);
          v2 = c_phi_recursive(x / p_a, a - 1);
          res = v1 - v2;
          store_cache_c(x, a, res, h_idx);
        }
      }
    }
  }
  return res;
}

int64_t c_pi_count(int64_t x) {
  int64_t res = 0;
  int64_t x_cbrt;
  int64_t x_sqrt;
  int64_t a_idx;
  int64_t b_idx;
  int64_t p2_sum = 0;
  int64_t phi_val;
  double rx;

  if (x < 2) {
    res = 0;
  } else if (x <= max_sieve_limit) {
    res = c_pi_small(x);
  } else {
    clear_cache_tbl();

    rx = (double)x;
    x_cbrt = (int64_t)cbrt(rx);
    x_sqrt = (int64_t)sqrt(rx);

    a_idx = c_pi_small(x_cbrt);
    b_idx = c_pi_small(x_sqrt);

    #pragma omp parallel for reduction(+:p2_sum) schedule(guided)
    for (int64_t i = a_idx + 1; i <= b_idx; i = i + 1) {
      int64_t p_i = global_primes_c[i];
      int64_t y = x / p_i;
      int64_t pi_y = c_pi_small(y);
      int64_t term = pi_y - i + 1;
      p2_sum = p2_sum + term;
    }

    phi_val = c_phi_recursive(x, a_idx);
    res = phi_val + a_idx - 1 - p2_sum;
  }
  return res;
}

int64_t c_pi_val(int64_t y) {
  int64_t res = 0;
  if (y < 2) {
    res = 0;
  } else if (y <= max_sieve_limit) {
    res = c_pi_small(y);
  } else {
    res = c_pi_count(y);
  }
  return res;
}

void c_segmented_sieve_count(int64_t low_val, int64_t high_val,
                             int64_t num_small, int64_t target_offset,
                             int64_t base_count, int64_t *result_prime,
                             bool *found) {
  int64_t seg_len = high_val - low_val + 1;
  int64_t num_words = (seg_len + 63) / 64;
  size_t sz_words = (size_t)num_words;
  uint64_t *seg = (uint64_t *)malloc(sz_words * sizeof(uint64_t));
  int64_t i = 0;
  int64_t p;
  int64_t p_sq;
  int64_t start_val;
  int64_t idx;
  int64_t current_count = base_count;
  int64_t w;
  int64_t cand;
  int64_t bit_idx;
  uint64_t word;
  int pop;

  *found = false;
  *result_prime = high_val;

  while (i < num_words) {
    seg[i] = ~0ULL;
    i = i + 1;
  }

  i = 1;
  while (i <= num_small) {
    p = global_primes_c[i];
    p_sq = p * p;
    if (p_sq > high_val) {
      i = num_small + 1;
    } else {
      start_val = (low_val + p - 1) / p * p;
      if (start_val < p_sq) {
        start_val = p_sq;
      }
      idx = start_val - low_val;
      while (idx < seg_len) {
        seg[idx / 64] = seg[idx / 64] & ~(1ULL << (idx % 64));
        idx = idx + p;
      }
      i = i + 1;
    }
  }

  w = 0;
  while (w < num_words) {
    word = seg[w];
    if (w == 0) {
      if (low_val <= 1) {
        if (low_val == 0) {
          word = word & ~3ULL;
        } else if (low_val == 1) {
          word = word & ~1ULL;
        }
      }
    }
    pop = __builtin_popcountll(word);
    if (current_count + (int64_t)pop < target_offset) {
      current_count = current_count + (int64_t)pop;
    } else {
      bit_idx = 0;
      while (bit_idx < 64) {
        cand = w * 64 + bit_idx;
        if (cand < seg_len) {
          if ((word & (1ULL << bit_idx)) != 0ULL) {
            current_count = current_count + 1;
            if (current_count == target_offset) {
              *result_prime = low_val + cand;
              *found = true;
              bit_idx = 64;
              w = num_words;
            }
          }
        }
        bit_idx = bit_idx + 1;
      }
    }
    w = w + 1;
  }

  free(seg);
}

void init_c_prime_counter(int64_t max_limit) {
  init_phi7_table();
  if (cache_tbl == NULL) {
    size_t sz = (size_t)HASH_SIZE * sizeof(cache_entry_t);
    cache_tbl = (cache_entry_t *)malloc(sz);
  }
  sieve_c_primes(max_limit);
}

void free_c_prime_counter(void) {
  if (bitset != NULL) {
    free(bitset);
    bitset = NULL;
  }
  if (pi_samples != NULL) {
    free(pi_samples);
    pi_samples = NULL;
  }
  if (global_primes_c != NULL) {
    free(global_primes_c);
    global_primes_c = NULL;
  }
  if (cache_tbl != NULL) {
    free(cache_tbl);
    cache_tbl = NULL;
  }
  if (phi7_tbl != NULL) {
    free(phi7_tbl);
    phi7_tbl = NULL;
  }
}
