/*
 * Algorithm 284: Test Harness & Benchmark
 * Author: Frédéric Blondin Custer
 */

#include "algorithm_284.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

static void test_uintmax_interchange(void)
{
    uintmax_t arr[8];
    size_t i;
    size_t p;
    size_t q;
    bool match;

    p = 3;
    q = 5;

    i = 0;
    while (i < 8) {
        arr[i] = (uintmax_t)(i + 1);
        i = i + 1;
    }

    printf("=== Test uintmax_t Block Interchange ===\n");
    printf("Initial array: ");
    i = 0;
    while (i < 8) {
        printf("%ju ", arr[i]);
        i = i + 1;
    }
    printf("\nInterchanging block A (size %zu) and B (size %zu)...\n",
           p, q);

    alg284_interchange_uintmax(arr, p, q);

    printf("Interchanged : ");
    i = 0;
    while (i < 8) {
        printf("%ju ", arr[i]);
        i = i + 1;
    }
    printf("\n");

    /* Expected: [4, 5, 6, 7, 8, 1, 2, 3] */
    match = true;
    if (arr[0] != 4 || arr[1] != 5 || arr[2] != 6 || arr[3] != 7) {
        match = false;
    }
    if (arr[4] != 8 || arr[5] != 1 || arr[6] != 2 || arr[7] != 3) {
        match = false;
    }
    printf("Verification : %s\n\n", match ? "PASSED" : "FAILED");
}

static void test_generic_rotate(void)
{
    int vals[10];
    size_t i;
    size_t n;
    size_t k;
    bool match;

    n = 10;
    k = 4;

    i = 0;
    while (i < n) {
        vals[i] = (int)(i * 10);
        i = i + 1;
    }

    printf("=== Test Generic Rotate Left ===\n");
    printf("Initial array: ");
    i = 0;
    while (i < n) {
        printf("%d ", vals[i]);
        i = i + 1;
    }
    printf("\nRotating left by %zu elements...\n", k);

    alg284_rotate_left(vals, n, k, sizeof(int));

    printf("Rotated      : ");
    i = 0;
    while (i < n) {
        printf("%d ", vals[i]);
        i = i + 1;
    }
    printf("\n");

    match = true;
    if (vals[0] != 40 || vals[5] != 90) {
        match = false;
    }
    if (vals[6] != 0 || vals[9] != 30) {
        match = false;
    }
    printf("Verification : %s\n\n", match ? "PASSED" : "FAILED");
}

int main(void)
{
    printf("=================================================\n");
    printf("   Algorithm 284: Block Interchange Engine       \n");
    printf("   Author: Frédéric Blondin Custer               \n");
    printf("=================================================\n\n");

    test_uintmax_interchange();
    test_generic_rotate();

    return 0;
}
