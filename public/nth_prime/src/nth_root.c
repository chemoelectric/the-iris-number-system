/* nth_root.c - Arbitrary-precision integer n-th root implementation
 * targeting C23 / GNU23 with OpenMP, multi-limb arithmetic,
 * and standalone executable support.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

#ifdef _OPENMP
#include <omp.h>
#endif

#if defined(LIMBS_128)
#define NUM_LIMBS 2
#elif defined(LIMBS_256)
#define NUM_LIMBS 4
#elif defined(LIMBS_512)
#define NUM_LIMBS 8
#elif defined(LIMBS_1024)
#define NUM_LIMBS 16
#elif defined(LIMBS_2048)
#define NUM_LIMBS 32
#elif defined(LIMBS_4096)
#define NUM_LIMBS 64
#elif defined(LIMBS_8192)
#define NUM_LIMBS 128
#else
#define NUM_LIMBS 128
#endif

typedef struct {
    uint64_t limbs[NUM_LIMBS];
} LimbNumber;

void limb_zero(LimbNumber *a) {
    size_t i = 0;
    while (i < NUM_LIMBS) {
        a->limbs[i] = 0;
        i = i + 1;
    }
}

LimbNumber limb_from_u64(uint64_t val) {
    LimbNumber res;
    limb_zero(&res);
    res.limbs[0] = val;
    return res;
}

bool limb_is_zero(const LimbNumber *a) {
    bool is_z = true;
    size_t i = 0;
    while (i < NUM_LIMBS) {
        uint64_t v = a->limbs[i];
        if (v != 0) {
            is_z = false;
            i = NUM_LIMBS;
        } else {
            i = i + 1;
        }
    }
    return is_z;
}

int limb_cmp(const LimbNumber *a, const LimbNumber *b) {
    int cmp = 0;
    size_t i = NUM_LIMBS;
    while (i > 0) {
        i = i - 1;
        uint64_t va = a->limbs[i];
        uint64_t vb = b->limbs[i];
        if (va > vb) {
            cmp = 1;
            i = 0;
        } else if (va < vb) {
            cmp = -1;
            i = 0;
        }
    }
    return cmp;
}

void limb_add(LimbNumber *res,
              const LimbNumber *a,
              const LimbNumber *b) {
    uint64_t carry = 0;
    size_t i = 0;
    while (i < NUM_LIMBS) {
        uint64_t va = a->limbs[i];
        uint64_t vb = b->limbs[i];
        uint64_t sum = va + vb;
        uint64_t c1 = 0;
        if (sum < va) {
            c1 = 1;
        }
        uint64_t total = sum + carry;
        uint64_t c2 = 0;
        if (total < sum) {
            c2 = 1;
        }
        res->limbs[i] = total;
        carry = c1 + c2;
        i = i + 1;
    }
}

void limb_sub(LimbNumber *res,
              const LimbNumber *a,
              const LimbNumber *b) {
    uint64_t borrow = 0;
    size_t i = 0;
    while (i < NUM_LIMBS) {
        uint64_t va = a->limbs[i];
        uint64_t vb = b->limbs[i];
        uint64_t diff = va - vb;
        uint64_t b1 = 0;
        if (va < vb) {
            b1 = 1;
        }
        uint64_t total = diff - borrow;
        uint64_t b2 = 0;
        if (diff < borrow) {
            b2 = 1;
        }
        res->limbs[i] = total;
        borrow = b1 + b2;
        i = i + 1;
    }
}

void limb_mul(LimbNumber *res,
              const LimbNumber *a,
              const LimbNumber *b) {
    LimbNumber temp;
    limb_zero(&temp);
    size_t i = 0;
    while (i < NUM_LIMBS) {
        uint64_t va = a->limbs[i];
        if (va != 0) {
            uint64_t carry = 0;
            size_t j = 0;
            while (j < NUM_LIMBS) {
                size_t idx = i + j;
                if (idx < NUM_LIMBS) {
                    uint64_t vb = b->limbs[j];
                    unsigned __int128 p1 = va;
                    unsigned __int128 p2 = vb;
                    unsigned __int128 prod = p1 * p2;
                    uint64_t cur_val = temp.limbs[idx];
                    unsigned __int128 cur128 = cur_val;
                    unsigned __int128 c128 = carry;
                    unsigned __int128 s1 = prod + cur128;
                    unsigned __int128 tot = s1 + c128;
                    uint64_t low = (uint64_t)tot;
                    temp.limbs[idx] = low;
                    unsigned __int128 hi = tot >> 64;
                    carry = (uint64_t)hi;
                }
                j = j + 1;
            }
        }
        i = i + 1;
    }
    *res = temp;
}

void limb_shift_left(LimbNumber *res,
                     const LimbNumber *a,
                     size_t bits) {
    LimbNumber temp;
    limb_zero(&temp);
    size_t w_shift = bits / 64;
    size_t b_shift = bits % 64;
    if (w_shift < NUM_LIMBS) {
        if (b_shift == 0) {
            size_t i = 0;
            while (i + w_shift < NUM_LIMBS) {
                size_t target = i + w_shift;
                temp.limbs[target] = a->limbs[i];
                i = i + 1;
            }
        } else {
            size_t comp_shift = 64 - b_shift;
            uint64_t carry = 0;
            size_t i = 0;
            while (i + w_shift < NUM_LIMBS) {
                size_t target = i + w_shift;
                uint64_t val = a->limbs[i];
                uint64_t shifted = val << b_shift;
                uint64_t new_val = shifted | carry;
                temp.limbs[target] = new_val;
                carry = val >> comp_shift;
                i = i + 1;
            }
        }
    }
    *res = temp;
}

void limb_shift_right(LimbNumber *res,
                      const LimbNumber *a,
                      size_t bits) {
    LimbNumber temp;
    limb_zero(&temp);
    size_t w_shift = bits / 64;
    size_t b_shift = bits % 64;
    if (w_shift < NUM_LIMBS) {
        if (b_shift == 0) {
            size_t i = w_shift;
            while (i < NUM_LIMBS) {
                size_t target = i - w_shift;
                temp.limbs[target] = a->limbs[i];
                i = i + 1;
            }
        } else {
            size_t comp_shift = 64 - b_shift;
            uint64_t carry = 0;
            size_t i = NUM_LIMBS;
            while (i > w_shift) {
                i = i - 1;
                size_t target = i - w_shift;
                uint64_t val = a->limbs[i];
                uint64_t shifted = val >> b_shift;
                uint64_t new_val = shifted | carry;
                temp.limbs[target] = new_val;
                carry = val << comp_shift;
            }
        }
    }
    *res = temp;
}

size_t limb_bit_length(const LimbNumber *a) {
    size_t len = 0;
    size_t i = NUM_LIMBS;
    while (i > 0) {
        i = i - 1;
        uint64_t val = a->limbs[i];
        if (val != 0) {
            size_t b = 64;
            while (b > 0) {
                b = b - 1;
                uint64_t mask = (uint64_t)1 << b;
                uint64_t test = val & mask;
                if (test != 0) {
                    size_t w_bits = i * 64;
                    size_t b_pos = b + 1;
                    len = w_bits + b_pos;
                    i = 0;
                    b = 0;
                }
            }
        }
    }
    return len;
}

void limb_div(LimbNumber *q,
              LimbNumber *r,
              const LimbNumber *a,
              const LimbNumber *b) {
    LimbNumber quotient;
    LimbNumber remainder;
    limb_zero(&quotient);
    limb_zero(&remainder);

    LimbNumber one = limb_from_u64(1);
    int cmp = limb_cmp(a, b);
    if (cmp < 0) {
        remainder = *a;
    } else if (cmp == 0) {
        quotient = one;
        limb_zero(&remainder);
    } else {
        size_t bit_a = limb_bit_length(a);
        size_t bit_b = limb_bit_length(b);
        size_t diff_bits = bit_a - bit_b;

        LimbNumber cur_rem = *a;
        size_t step = diff_bits + 1;
        while (step > 0) {
            step = step - 1;
            LimbNumber shifted_b;
            limb_shift_left(&shifted_b, b, step);
            if (limb_cmp(&cur_rem, &shifted_b) >= 0) {
                LimbNumber next_rem;
                limb_sub(&next_rem, &cur_rem, &shifted_b);
                cur_rem = next_rem;

                LimbNumber bit_mask;
                limb_shift_left(&bit_mask, &one, step);
                LimbNumber next_q;
                limb_add(&next_q, &quotient, &bit_mask);
                quotient = next_q;
            }
        }
        remainder = cur_rem;
    }

    if (q != NULL) {
        *q = quotient;
    }
    if (r != NULL) {
        *r = remainder;
    }
}

void limb_pow_u32(LimbNumber *res,
                  const LimbNumber *base,
                  uint32_t exp) {
    LimbNumber result = limb_from_u64(1);
    LimbNumber b = *base;
    uint32_t e = exp;
    while (e > 0) {
        if ((e & 1) != 0) {
            LimbNumber next_res;
            limb_mul(&next_res, &result, &b);
            result = next_res;
        }
        e = e >> 1;
        if (e > 0) {
            LimbNumber next_b;
            limb_mul(&next_b, &b, &b);
            b = next_b;
        }
    }
    *res = result;
}

LimbNumber get_nth_root_limb(LimbNumber a, uint64_t n) {
    LimbNumber root;
    limb_zero(&root);

    if (n == 0) {
        limb_zero(&root);
    } else if (limb_is_zero(&a)) {
        limb_zero(&root);
    } else if (n == 1) {
        root = a;
    } else {
        size_t bit_len = limb_bit_length(&a);
        size_t init_bits = (bit_len + n - 1) / n;
        LimbNumber one = limb_from_u64(1);
        LimbNumber x;
        limb_shift_left(&x, &one, init_bits);

        LimbNumber n_limb = limb_from_u64(n);
        uint32_t n_sub = (uint32_t)(n - 1);
        LimbNumber n_sub_limb = limb_from_u64(n_sub);

        bool done = false;
        size_t max_iter = 1000;
        size_t iter = 0;

        while (!done && iter < max_iter) {
            iter = iter + 1;
            LimbNumber x_pow;
            limb_pow_u32(&x_pow, &x, n_sub);

            LimbNumber div_res;
            limb_div(&div_res, NULL, &a, &x_pow);

            LimbNumber term1;
            limb_mul(&term1, &x, &n_sub_limb);

            LimbNumber sum_val;
            limb_add(&sum_val, &term1, &div_res);

            LimbNumber x_next;
            limb_div(&x_next, NULL, &sum_val, &n_limb);

            if (limb_cmp(&x_next, &x) >= 0) {
                done = true;
            } else {
                x = x_next;
            }
        }

        LimbNumber test_pow;
        limb_pow_u32(&test_pow, &x, (uint32_t)n);
        while (limb_cmp(&test_pow, &a) > 0) {
            LimbNumber next_x;
            limb_sub(&next_x, &x, &one);
            x = next_x;
            limb_pow_u32(&test_pow, &x, (uint32_t)n);
        }

        LimbNumber x_plus1;
        limb_add(&x_plus1, &x, &one);
        LimbNumber next_pow;
        limb_pow_u32(&next_pow, &x_plus1, (uint32_t)n);
        while (limb_cmp(&next_pow, &a) <= 0) {
            x = x_plus1;
            limb_add(&x_plus1, &x, &one);
            limb_pow_u32(&next_pow, &x_plus1, (uint32_t)n);
        }

        root = x;
    }
    return root;
}

uint64_t get_nth_root_u64(uint64_t x, uint64_t n) {
    uint64_t res = 0;
    if (n == 0) {
        res = 0;
    } else if (x == 0) {
        res = 0;
    } else if (n == 1) {
        res = x;
    } else if (n >= 64) {
        res = 1;
    } else {
        LimbNumber lx = limb_from_u64(x);
        LimbNumber lr = get_nth_root_limb(lx, n);
        res = lr.limbs[0];
    }
    return res;
}

LimbNumber limb_from_string(const char *str) {
    LimbNumber res = limb_from_u64(0);
    LimbNumber ten = limb_from_u64(10);
    size_t i = 0;
    size_t len = strlen(str);
    while (i < len) {
        char c = str[i];
        if (c >= '0' && c <= '9') {
            uint64_t digit = (uint64_t)(c - '0');
            LimbNumber d_limb = limb_from_u64(digit);
            LimbNumber temp;
            limb_mul(&temp, &res, &ten);
            limb_add(&res, &temp, &d_limb);
        }
        i = i + 1;
    }
    return res;
}

void limb_to_string(char *buf, size_t buf_size, const LimbNumber *a) {
    if (limb_is_zero(a)) {
        if (buf_size > 1) {
            buf[0] = '0';
            buf[1] = '\0';
        }
    } else {
        char temp_buf[2500];
        size_t idx = 0;
        LimbNumber cur = *a;
        LimbNumber ten = limb_from_u64(10);
        while (!limb_is_zero(&cur) && idx < 2490) {
            LimbNumber q;
            LimbNumber r;
            limb_div(&q, &r, &cur, &ten);
            uint64_t digit = r.limbs[0];
            temp_buf[idx] = (char)('0' + digit);
            idx = idx + 1;
            cur = q;
        }
        size_t out_idx = 0;
        while (idx > 0 && out_idx + 1 < buf_size) {
            idx = idx - 1;
            buf[out_idx] = temp_buf[idx];
            out_idx = out_idx + 1;
        }
        buf[out_idx] = '\0';
    }
}

void get_nth_roots_parallel(const LimbNumber *inputs,
                            LimbNumber *outputs,
                            size_t count,
                            uint64_t n) {
#ifdef _OPENMP
    #pragma omp parallel for schedule(dynamic)
#endif
    for (size_t i = 0; i < count; i += 1)
        outputs[i] = get_nth_root_limb(inputs[i], n);
}

void clean_input_str(const char *raw, char *clean, size_t max_len) {
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

uint64_t parse_u64_str(const char *str) {
    uint64_t val = 0;
    size_t i = 0;
    size_t len = strlen(str);
    while (i < len) {
        char c = str[i];
        if (c >= '0' && c <= '9') {
            val = val * 10 + (uint64_t)(c - '0');
        }
        i = i + 1;
    }
    return val;
}

LimbNumber parse_special_input(const char *str) {
    LimbNumber res = limb_from_u64(0);
    if (strcmp(str, "1e6") == 0 || strcmp(str, "10^6") == 0) {
        res = limb_from_u64(1000000ULL);
    } else if (strcmp(str, "1e9") == 0 || strcmp(str, "10^9") == 0) {
        res = limb_from_u64(1000000000ULL);
    } else if (strcmp(str, "1e12") == 0 || strcmp(str, "10^12") == 0) {
        res = limb_from_u64(1000000000000ULL);
    } else if (strcmp(str, "1e15") == 0 || strcmp(str, "10^15") == 0) {
        res = limb_from_u64(1000000000000000ULL);
    } else {
        const char *p_star = strstr(str, "**");
        const char *p_caret = strchr(str, '^');
        if (p_star != NULL) {
            uint64_t base_val = parse_u64_str(str);
            uint64_t exp_val = parse_u64_str(p_star + 2);
            LimbNumber b_limb = limb_from_u64(base_val);
            limb_pow_u32(&res, &b_limb, (uint32_t)exp_val);
        } else if (p_caret != NULL) {
            uint64_t base_val = parse_u64_str(str);
            uint64_t exp_val = parse_u64_str(p_caret + 1);
            LimbNumber b_limb = limb_from_u64(base_val);
            limb_pow_u32(&res, &b_limb, (uint32_t)exp_val);
        } else {
            res = limb_from_string(str);
        }
    }
    return res;
}

#if defined(STANDALONE) && STANDALONE
int main(int argc, char **argv) {
    char x_raw[512];
    char n_raw[128];
    x_raw[0] = '\0';
    n_raw[0] = '\0';

    if (argc > 1) {
        snprintf(x_raw, sizeof(x_raw), "%s", argv[1]);
        if (argc > 2) {
            snprintf(n_raw, sizeof(n_raw), "%s", argv[2]);
        }
    } else {
        char line[512];
        if (fgets(line, sizeof(line), stdin) != NULL) {
            sscanf(line, "%511s %127s", x_raw, n_raw);
        }
    }

    char x_clean[512];
    char n_clean[128];
    clean_input_str(x_raw, x_clean, sizeof(x_clean));
    clean_input_str(n_raw, n_clean, sizeof(n_clean));

    uint64_t n_val = 2;
    if (strlen(n_clean) > 0) {
        n_val = parse_u64_str(n_clean);
        if (n_val == 0) {
            n_val = 2;
        }
    }

    if (strlen(x_clean) > 0) {
        LimbNumber x_limb = parse_special_input(x_clean);
        LimbNumber r_limb = get_nth_root_limb(x_limb, n_val);
        char out_str[2500];
        limb_to_string(out_str, sizeof(out_str), &r_limb);
        printf("%s\n", out_str);
    } else {
        printf("Invalid input or N must be positive.\n");
    }

    return 0;
}
#endif
