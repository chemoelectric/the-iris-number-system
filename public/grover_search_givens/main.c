/*
 * Portable Parallel C25 Givens Grover Search Engine - Test Harness
 * Author: Frédéric Blondin Custer
 *
 * Demonstrates Givens Grover search, vectorized unique uintmax_t
 * scanning, and free-list associative table slot management.
 */

#include "givens_grover.h"
#include "givens_grover_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define BENCHMARK_SIZE 65536

static void test_givens_subspace(void)
{
    size_t space_n;
    double theta;
    size_t opt_k;
    double prob;

    space_n = 1048576;
    theta = givens_angle_compute(space_n);
    opt_k = givens_optimal_steps(space_n);
    prob = 0.0;

    givens_grover_simulate(space_n, opt_k, &prob);

    printf("=== Givens Grover Invariant Subspace ===\n");
    printf("Search Space Size N      : %zu\n", space_n);
    printf("Givens Step Angle Theta  : %.8f rad\n", theta);
    printf("Optimal Givens Steps k   : %zu\n", opt_k);
    printf("Target State Probability : %.6f\n\n", prob);
}

static void test_vectorized_search(void)
{
    uintmax_t *keys;
    size_t count;
    size_t target_idx;
    uintmax_t target_val;
    size_t found_idx;
    bool found;
    size_t i;

    count = BENCHMARK_SIZE;
    keys = (uintmax_t *)malloc(count * sizeof(uintmax_t));
    if (keys == NULL) {
        printf("Memory allocation failure in benchmark.\n");
    } else {
        i = 0;
        while (i < count) {
            keys[i] = (uintmax_t)(i * 37 + 101);
            i = i + 1;
        }

        target_idx = 42100;
        target_val = keys[target_idx];
        found_idx = 0;

        found = givens_grover_search_array(
            keys,
            count,
            target_val,
            &found_idx
        );

        printf("=== Vector-Parallel Array Search ===\n");
        printf("Dataset Size (uintmax_t) : %zu\n", count);
        printf("Searched Key (uintmax_t) : %ju\n", target_val);
        printf("Target Found             : %s\n", found ? "YES" : "NO");
        printf("Reported Match Index     : %zu (Expected: %zu)\n\n",
               found_idx, target_idx);

        free(keys);
    }
}

static void test_associative_table(void)
{
    givens_table_t tbl;
    bool init_ok;
    uintmax_t val_out;
    bool found;
    bool ins_ok;
    bool del_ok;

    init_ok = givens_table_init(&tbl, 32);
    if (!init_ok) {
        printf("Failed to initialize Givens table.\n");
    } else {
        printf("=== Unique uintmax_t Associative Table ===\n");

        ins_ok = givens_table_insert(&tbl, 1001, 5555);
        ins_ok = givens_table_insert(&tbl, 2002, 7777);
        ins_ok = givens_table_insert(&tbl, 3003, 9999);

        printf("Inserted 3 items. Current count: %zu\n",
               givens_table_count(&tbl));

        val_out = 0;
        found = givens_table_lookup(&tbl, 2002, &val_out);
        printf("Lookup Key 2002 -> Found: %s, Value: %ju\n",
               found ? "YES" : "NO", val_out);

        del_ok = givens_table_delete(&tbl, 2002);
        printf("Deleted Key 2002 -> Status: %s\n",
               del_ok ? "SUCCESS" : "FAILED");
        printf("Count after deletion: %zu\n",
               givens_table_count(&tbl));

        ins_ok = givens_table_insert(&tbl, 4004, 1234);
        printf("Recycled free slot for Key 4004. Count: %zu\n",
               givens_table_count(&tbl));

        val_out = 0;
        found = givens_table_lookup(&tbl, 4004, &val_out);
        printf("Lookup Key 4004 -> Found: %s, Value: %ju\n\n",
               found ? "YES" : "NO", val_out);

        givens_table_destroy(&tbl);
    }
}

int main(void)
{
    int exit_code;

    printf("=================================================\n");
    printf("   C25 Givens Grover Search & Table Engine       \n");
    printf("   Author: Frédéric Blondin Custer               \n");
    printf("=================================================\n\n");

    test_givens_subspace();
    test_vectorized_search();
    test_associative_table();

    exit_code = 0;
    return exit_code;
}
