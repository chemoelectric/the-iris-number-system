#ifndef GIVENS_GROVER_TABLE_H
#define GIVENS_GROVER_TABLE_H

/*
 * Portable Parallel C25 Unique uintmax_t Table Engine
 * Author: Frédéric Blondin Custer
 *
 * Implements high-performance associative table with direct sentinel
 * slot recycling (GIVENS_KEY_UNUSED) using vector-parallel Givens
 * Grover scanning. Eliminates auxiliary free lists.
 */

#include "givens_grover.h"
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* Structure for a unique uintmax_t key-value slot */
typedef struct {
    uintmax_t key;
    uintmax_t value;
} givens_slot_t;

/* Structure for contiguous table with sentinel unused recycling */
typedef struct {
    givens_slot_t *slots;
    uintmax_t *key_cache;
    size_t capacity;
    size_t count;
    uintmax_t unused_sentinel;
} givens_table_t;

/*
 * Allocates and initializes table with given capacity and sentinel.
 */
bool givens_table_init_sentinel(
    givens_table_t *table,
    size_t initial_capacity,
    uintmax_t unused_sentinel
);

/*
 * Allocates and initializes table with default GIVENS_KEY_UNUSED.
 */
bool givens_table_init(
    givens_table_t *table,
    size_t initial_capacity
);

/*
 * Deallocates all memory associated with the table.
 */
void givens_table_destroy(givens_table_t *table);

/*
 * Inserts or updates a unique key. Empty slots are located via
 * high-multiplicity vector search for unused_sentinel.
 */
bool givens_table_insert(
    givens_table_t *table,
    uintmax_t key,
    uintmax_t value
);

/*
 * Looks up unique key using vector-parallel Givens Grover scan.
 * Stores value in out_val if found.
 */
bool givens_table_lookup(
    const givens_table_t *table,
    uintmax_t key,
    uintmax_t *out_val
);

/*
 * Deletes unique key by rewriting its slot key to unused_sentinel.
 * Returns true if key was present and deleted.
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
