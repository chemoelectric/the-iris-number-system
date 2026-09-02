#ifndef GIVENS_GROVER_TABLE_H
#define GIVENS_GROVER_TABLE_H

/*
 * Portable Parallel C25 Unique uintmax_t Table & Free List Engine
 * Author: Frédéric Blondin Custer
 *
 * Implements high-performance unique key storage with free list
 * slot recycling and vector-parallel Givens Grover lookup.
 */

#include "givens_grover.h"
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* Structure for a unique uintmax_t key-value slot */
typedef struct {
    uintmax_t key;
    uintmax_t value;
    bool occupied;
} givens_slot_t;

/* Structure for the table with free-list recycling */
typedef struct {
    givens_slot_t *slots;
    size_t *free_stack;
    size_t free_count;
    size_t capacity;
    size_t count;
} givens_table_t;

/*
 * Allocates and initializes a new table with given initial capacity.
 */
bool givens_table_init(
    givens_table_t *table,
    size_t initial_capacity
);

/*
 * Deallocates all resources associated with the table.
 */
void givens_table_destroy(givens_table_t *table);

/*
 * Inserts or updates a unique key with an associated value.
 * Uses free-list slot recycling for deleted positions.
 */
bool givens_table_insert(
    givens_table_t *table,
    uintmax_t key,
    uintmax_t value
);

/*
 * Looks up a unique key in the table using vector-parallel search.
 * Returns true if key is found and stores associated value in out_val.
 */
bool givens_table_lookup(
    const givens_table_t *table,
    uintmax_t key,
    uintmax_t *out_val
);

/*
 * Deletes a unique key and recycles its slot into the free list.
 * Returns true if the key was found and removed.
 */
bool givens_table_delete(
    givens_table_t *table,
    uintmax_t key
);

/*
 * Returns the number of occupied entries in the table.
 */
size_t givens_table_count(const givens_table_t *table);

/*
 * Returns the current total allocated capacity of the table.
 */
size_t givens_table_capacity(const givens_table_t *table);

#endif /* GIVENS_GROVER_TABLE_H */
