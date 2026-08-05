#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <omp.h>
#include "prime_c.h"

#define P6_VAL 30030LL
#define PHI6_P6_VAL 5760LL
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

static int64_t phi6_tbl[30030];
static bool phi6_done = false;

static cache_entry_t *cache_tbl = NULL;

static void init_phi6_table(void) {
  int64_t count = 0;
  int64_t i = 1;
  int64_t rem;

  if (phi6_done == false) {
    phi6_tbl[0] = 0;
    while (i < P6_VAL) {
      rem = i % 2;
      if (rem != 0) {
        rem = i % 3;
        if (rem != 0) {
          rem = i % 5;
          if (rem != 0) {
            rem = i % 7;
            if (rem != 0) {
              rem = i % 11;
              if (rem != 0) {
                rem = i % 13;
                if (rem != 0) {
                  count = count + 1;
                }
              }
            }
          }
        }
      }
      phi6_tbl[i] = count;
      i = i + 1;
    }
    phi6_done = true;
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
    uint64_t word = bitset[k / 64];
    uint64_t mask = 1ULL << (k % 64);
    if ((word & mask) != 0ULL) {
      p = 2 * k + 1;
      start_idx = (p * p - 1) / 2;
      step = p;
      idx = start_idx;
      while (idx < num_odds) {
        uint64_t bit_mask = 1ULL << (idx % 64);
        bitset[idx / 64] = bitset[idx / 64] & ~bit_mask;
        idx = idx + step;
      }
    }
    k = k + 1;
  }

  i = 0;
  while (i < words) {
    pi_samples[i] = running_count;
    int pop = __builtin_popcountll(bitset[i]);
    running_count = running_count + (uint32_t)pop;
    i = i + 1;
  }

  global_num_primes_c = 1 + (int64_t)running_count;
  sz_primes = (size_t)global_num_primes_c;
  sz_primes = sz_primes * sizeof(int64_t);
  global_primes_c = (int64_t *)malloc(sz_primes);
  global_primes_c[0] = 0;
  global_primes_c[1] = 2;

  int64_t prime_idx = 2;
  int64_t odd_i = 1;
  while (odd_i < num_odds) {
    uint64_t w = bitset[odd_i / 64];
    uint64_t m = 1ULL << (odd_i % 64);
    if ((w & m) != 0ULL) {
      global_primes_c[prime_idx] = 2 * odd_i + 1;
      prime_idx = prime_idx + 1;
    }
    odd_i = odd_i + 1;
  }
}

int64_t c_pi_small(int64_t y) {
  int64_t res = 0;

  if (y < 2) {
    res = 0;
  } else if (y == 2) {
    res = 1;
  } else if (y <= max_sieve_limit) {
    int64_t y_odd = (y - 1) / 2;
    int64_t block = y_odd / 64;
    int64_t offset = y_odd % 64;
    uint64_t word = bitset[block];
    uint64_t mask = 0ULL;
    if (offset == 63) {
      mask = ~0ULL;
    } else {
      mask = (1ULL << (offset + 1)) - 1ULL;
    }
    uint64_t masked = word & mask;
    int pop = __builtin_popcountll(masked);
    int64_t base_cnt = (int64_t)pi_samples[block];
    res = base_cnt + 1 + (int64_t)pop;
  } else if (global_num_primes_c > 0) {
    int64_t p_max = global_primes_c[global_num_primes_c - 1];
    if (y >= p_max) {
      res = global_num_primes_c - 1;
    } else {
      int64_t low = 1;
      int64_t high = global_num_primes_c - 1;
      int64_t ans = 0;
      int64_t mid;
      int64_t p_mid;
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
  } else if (a == 6) {
    q_val = x / P6_VAL;
    r_val = x % P6_VAL;
    term_q = q_val * PHI6_P6_VAL;
    term_r = phi6_tbl[r_val];
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

  if (x < 2) {
    res = 0;
  } else if (x <= max_sieve_limit) {
    res = c_pi_small(x);
  } else {
    clear_cache_tbl();

    double rx = (double)x;
    x_cbrt = (int64_t)cbrt(rx);
    x_sqrt = (int64_t)sqrt(rx);

    a_idx = c_pi_small(x_cbrt);
    b_idx = c_pi_small(x_sqrt);

    #pragma omp parallel for reduction(+:p2_sum) schedule(static, 256)
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
  size_t sz_seg = (size_t)seg_len;
  bool *seg = (bool *)malloc(sz_seg * sizeof(bool));
  int64_t i;
  int64_t idx;
  int64_t p;
  int64_t p_sq;
  int64_t start_val;
  int64_t current_count;
  int64_t cand;

  *found = false;
  *result_prime = high_val;

  i = 0;
  while (i < seg_len) {
    seg[i] = true;
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
        seg[idx] = false;
        idx = idx + p;
      }
      i = i + 1;
    }
  }

  current_count = base_count;
  idx = 0;
  while (idx < seg_len) {
    cand = low_val + idx;
    if (cand > 1) {
      if (seg[idx] == true) {
        current_count = current_count + 1;
        if (current_count == target_offset) {
          *result_prime = cand;
          *found = true;
          idx = seg_len;
        }
      }
    }
    idx = idx + 1;
  }

  free(seg);
}

void init_c_prime_counter(int64_t max_limit) {
  init_phi6_table();
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
}
