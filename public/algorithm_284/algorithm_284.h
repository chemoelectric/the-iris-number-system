#ifndef ALGORITHM_284_H
#define ALGORITHM_284_H

/*
 * Algorithm 284: Interchange of Two Blocks of Data
 * Original Algorithm: B. Boothroyd (CACM, May 1966)
 * C25 Clean-Room Structured Implementation
 * Author: Frédéric Blondin Custer
 *
 * Interchanges two adjacent contiguous blocks A (length p)
 * and B (length q) in-place within an array of total length
 * n = p + q in O(n) operations and O(1) auxiliary space:
 *
 *   Initial: [ A_0, A_1, ..., A_{p-1}, B_0, B_1, ..., B_{q-1} ]
 *   Final:   [ B_0, B_1, ..., B_{q-1}, A_0, A_1, ..., A_{p-1} ]
 *
 * Complies with strict C25 structured coding guidelines:
 * - Line length <= 72 characters
 * - McCabe cyclomatic complexity <= 10
 * - No ++ / -- increment or decrement operators
 * - Single operation per statement
 */

#include <stddef.h>
#include <stdint.h>
#include <string.h>

/*
 * In-place byte reversal helper for generic memory buffers.
 */
static inline void alg284_reverse_bytes(
    unsigned char *base,
    size_t length
)
{
    size_t i;
    size_t j;

    if (base != NULL && length > 1) {
        i = 0;
        j = length - 1;
        while (i < j) {
            unsigned char tmp;
            tmp = base[i];
            base[i] = base[j];
            base[j] = tmp;
            i = i + 1;
            j = j - 1;
        }
    }
}

/*
 * In-place element reversal for generic arrays of elem_size.
 */
static inline void alg284_reverse_generic(
    void *base,
    size_t count,
    size_t elem_size
)
{
    unsigned char *raw;
    size_t left;
    size_t right;

    if (base != NULL && count > 1 && elem_size > 0) {
        raw = (unsigned char *)base;
        left = 0;
        right = count - 1;

        while (left < right) {
            size_t left_offset;
            size_t right_offset;
            unsigned char *p_left;
            unsigned char *p_right;
            size_t b;

            left_offset = left * elem_size;
            right_offset = right * elem_size;
            p_left = raw + left_offset;
            p_right = raw + right_offset;

            b = 0;
            while (b < elem_size) {
                unsigned char tmp;
                tmp = p_left[b];
                p_left[b] = p_right[b];
                p_right[b] = tmp;
                b = b + 1;
            }

            left = left + 1;
            right = right - 1;
        }
    }
}

/*
 * In-place element reversal for uintmax_t word arrays.
 */
static inline void alg284_reverse_uintmax(
    uintmax_t *arr,
    size_t count
)
{
    size_t i;
    size_t j;

    if (arr != NULL && count > 1) {
        i = 0;
        j = count - 1;
        while (i < j) {
            uintmax_t tmp;
            tmp = arr[i];
            arr[i] = arr[j];
            arr[j] = tmp;
            i = i + 1;
            j = j - 1;
        }
    }
}

/*
 * In-place element reversal for pointer (void *) arrays.
 */
static inline void alg284_reverse_ptr(
    void **arr,
    size_t count
)
{
    size_t i;
    size_t j;

    if (arr != NULL && count > 1) {
        i = 0;
        j = count - 1;
        while (i < j) {
            void *tmp;
            tmp = arr[i];
            arr[i] = arr[j];
            arr[j] = tmp;
            i = i + 1;
            j = j - 1;
        }
    }
}

/*
 * Algorithm 284: In-place block interchange on uintmax_t arrays.
 * Interchanges block A (length p) and block B (length q).
 * Total elements n = p + q.
 * Performs (A^R B^R)^R = B A in 3 reversals.
 */
static inline void alg284_interchange_uintmax(
    uintmax_t *arr,
    size_t p,
    size_t q
)
{
    size_t total_n;
    uintmax_t *b_start;

    if (arr != NULL && p > 0 && q > 0) {
        total_n = p + q;
        b_start = arr + p;

        /* Reverse block A: A -> A^R */
        alg284_reverse_uintmax(arr, p);

        /* Reverse block B: B -> B^R */
        alg284_reverse_uintmax(b_start, q);

        /* Reverse entire buffer: (A^R B^R)^R -> B A */
        alg284_reverse_uintmax(arr, total_n);
    }
}

/*
 * Algorithm 284: In-place block interchange on pointer arrays.
 */
static inline void alg284_interchange_ptr(
    void **arr,
    size_t p,
    size_t q
)
{
    size_t total_n;
    void **b_start;

    if (arr != NULL && p > 0 && q > 0) {
        total_n = p + q;
        b_start = arr + p;

        alg284_reverse_ptr(arr, p);
        alg284_reverse_ptr(b_start, q);
        alg284_reverse_ptr(arr, total_n);
    }
}

/*
 * Algorithm 284: In-place generic block interchange.
 * base: pointer to the start of array
 * p: number of elements in block A
 * q: number of elements in block B
 * elem_size: size of each element in bytes
 */
static inline void alg284_interchange(
    void *base,
    size_t p,
    size_t q,
    size_t elem_size
)
{
    unsigned char *raw;
    size_t total_n;
    size_t offset_b;
    unsigned char *b_start;

    if (base != NULL && p > 0 && q > 0 && elem_size > 0) {
        raw = (unsigned char *)base;
        total_n = p + q;
        offset_b = p * elem_size;
        b_start = raw + offset_b;

        alg284_reverse_generic(raw, p, elem_size);
        alg284_reverse_generic(b_start, q, elem_size);
        alg284_reverse_generic(raw, total_n, elem_size);
    }
}

/*
 * Array rotation helper: rotates array of length n left by k places.
 * Interchanges block A (length k) and block B (length n-k).
 */
static inline void alg284_rotate_left(
    void *base,
    size_t n,
    size_t k,
    size_t elem_size
)
{
    if (base != NULL && n > 1 && elem_size > 0) {
        size_t eff_k;
        size_t p;
        size_t q;

        eff_k = k % n;
        if (eff_k > 0) {
            p = eff_k;
            q = n - eff_k;
            alg284_interchange(base, p, q, elem_size);
        }
    }
}

/*
 * Array rotation helper: rotates array of length n right by k places.
 */
static inline void alg284_rotate_right(
    void *base,
    size_t n,
    size_t k,
    size_t elem_size
)
{
    if (base != NULL && n > 1 && elem_size > 0) {
        size_t eff_k;

        eff_k = k % n;
        if (eff_k > 0) {
            size_t left_rot;
            left_rot = n - eff_k;
            alg284_rotate_left(base, n, left_rot, elem_size);
        }
    }
}

#endif /* ALGORITHM_284_H */
