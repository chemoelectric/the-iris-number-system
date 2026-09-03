/*
 * Portable Parallel C25 Unique uintmax_t Table Engine
 * Author: Frédéric Blondin Custer
 *
 * Implements high-performance associative table with direct sentinel
 * slot recycling (GIVENS_KEY_UNUSED) using vector-parallel Givens
 * Grover scanning. Eliminates auxiliary free lists and pointers.
 */

#include "givens_grover_table.h"
#include <stdlib.h>
#include <string.h>

#define DEFAULT_CAPACITY 16

bool givens_table_init_sentinel(
    givens_table_t *table,
    size_t initial_capacity,
    uintmax_t unused_sentinel
)
{
    bool success;
    size_t cap;
    givens_slot_t *slots_mem;
    uintmax_t *keys_mem;
    size_t i;

    success = false;
    cap = initial_capacity;

    if (table != NULL) {
        if (cap < DEFAULT_CAPACITY) {
            cap = DEFAULT_CAPACITY;
        }

        slots_mem = (givens_slot_t *)malloc(
            cap * sizeof(givens_slot_t)
        );
        keys_mem = (uintmax_t *)malloc(
            cap * sizeof(uintmax_t)
        );

        if (slots_mem != NULL && keys_mem != NULL) {
            i = 0;
            while (i < cap) {
                slots_mem[i].key = unused_sentinel;
                slots_mem[i].value = 0;
                keys_mem[i] = unused_sentinel;
                i = i + 1;
            }

            table->slots = slots_mem;
            table->key_cache = keys_mem;
            table->capacity = cap;
            table->count = 0;
            table->unused_sentinel = unused_sentinel;
            success = true;
        } else {
            if (slots_mem != NULL) {
                free(slots_mem);
            }
            if (keys_mem != NULL) {
                free(keys_mem);
            }
        }
    }

    return success;
}

bool givens_table_init(
    givens_table_t *table,
    size_t initial_capacity
)
{
    bool res;
    res = givens_table_init_sentinel(
        table,
        initial_capacity,
        GIVENS_KEY_UNUSED
    );
    return res;
}

void givens_table_destroy(givens_table_t *table)
{
    if (table != NULL) {
        if (table->slots != NULL) {
            free(table->slots);
            table->slots = NULL;
        }
        if (table->key_cache != NULL) {
            free(table->key_cache);
            table->key_cache = NULL;
        }
        table->capacity = 0;
        table->count = 0;
    }
}

/*
 * Internal helper to expand table capacity when full.
 */
static bool table_expand(givens_table_t *table)
{
    bool success;
    size_t old_cap;
    size_t new_cap;
    givens_slot_t *new_slots;
    uintmax_t *new_keys;
    uintmax_t sent;
    size_t i;

    success = false;
    old_cap = table->capacity;
    new_cap = old_cap * 2;
    sent = table->unused_sentinel;

    new_slots = (givens_slot_t *)realloc(
        table->slots,
        new_cap * sizeof(givens_slot_t)
    );
    new_keys = (uintmax_t *)realloc(
        table->key_cache,
        new_cap * sizeof(uintmax_t)
    );

    if (new_slots != NULL && new_keys != NULL) {
        table->slots = new_slots;
        table->key_cache = new_keys;

        i = old_cap;
        while (i < new_cap) {
            table->slots[i].key = sent;
            table->slots[i].value = 0;
            table->key_cache[i] = sent;
            i = i + 1;
        }

        table->capacity = new_cap;
        success = true;
    }

    return success;
}

bool givens_table_insert(
    givens_table_t *table,
    uintmax_t key,
    uintmax_t value
)
{
    bool success;
    bool exists;
    size_t existing_slot;

    success = false;

    if (table != NULL && key != table->unused_sentinel) {
        exists = givens_grover_search_array(
            table->key_cache,
            table->capacity,
            key,
            &existing_slot
        );

        if (exists) {
            table->slots[existing_slot].value = value;
            success = true;
        } else {
            bool ready;
            size_t free_slot;
            bool found_free;

            ready = true;
            if (table->count >= table->capacity) {
                ready = table_expand(table);
            }

            if (ready) {
                found_free = givens_grover_search_nonunique(
                    table->key_cache,
                    table->capacity,
                    table->unused_sentinel,
                    &free_slot
                );

                if (!found_free) {
                    ready = table_expand(table);
                    if (ready) {
                        found_free = givens_grover_search_nonunique(
                            table->key_cache,
                            table->capacity,
                            table->unused_sentinel,
                            &free_slot
                        );
                    }
                }

                if (found_free) {
                    table->slots[free_slot].key = key;
                    table->slots[free_slot].value = value;
                    table->key_cache[free_slot] = key;
                    table->count = table->count + 1;
                    success = true;
                }
            }
        }
    }

    return success;
}

bool givens_table_lookup(
    const givens_table_t *table,
    uintmax_t key,
    uintmax_t *out_val
)
{
    bool found;
    size_t slot_idx;

    found = false;

    if (table != NULL && table->count > 0) {
        if (key != table->unused_sentinel) {
            found = givens_grover_search_array(
                table->key_cache,
                table->capacity,
                key,
                &slot_idx
            );

            if (found && out_val != NULL) {
                *out_val = table->slots[slot_idx].value;
            }
        }
    }

    return found;
}

bool givens_table_delete(
    givens_table_t *table,
    uintmax_t key
)
{
    bool found;
    size_t slot_idx;
    uintmax_t sent;

    found = false;

    if (table != NULL && table->count > 0) {
        sent = table->unused_sentinel;
        if (key != sent) {
            found = givens_grover_search_array(
                table->key_cache,
                table->capacity,
                key,
                &slot_idx
            );

            if (found) {
                table->slots[slot_idx].key = sent;
                table->slots[slot_idx].value = 0;
                table->key_cache[slot_idx] = sent;
                table->count = table->count - 1;
            }
        }
    }

    return found;
}

size_t givens_table_count(const givens_table_t *table)
{
    size_t res;
    res = 0;
    if (table != NULL) {
        res = table->count;
    }
    return res;
}

size_t givens_table_capacity(const givens_table_t *table)
{
    size_t res;
    res = 0;
    if (table != NULL) {
        res = table->capacity;
    }
    return res;
}
