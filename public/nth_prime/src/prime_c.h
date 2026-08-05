#ifndef PRIME_C_H
#define PRIME_C_H

#include <stdint.h>
#include <stdbool.h>

void init_c_prime_counter(int64_t max_limit);
int64_t c_pi_small(int64_t y);
int64_t c_pi_count(int64_t x);
int64_t c_pi_val(int64_t y);
void c_segmented_sieve_count(int64_t low_val, int64_t high_val,
                             int64_t num_small, int64_t target_offset,
                             int64_t base_count, int64_t *result_prime,
                             bool *found);
void free_c_prime_counter(void);

#endif
