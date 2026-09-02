/*
 * Portable Parallel C25 Unique uintmax_t Table & Free List Engine
 * Author: Frédéric Blondin Custer
 *
 * Implements high-performance unique key storage with free list
 * slot recycling and vector-parallel Givens Grover lookup.
 */

#include "givens_grover_table.h"
#include <stdlib.h>
#include <string.h>

#define DEFAULT_CAPACITY 16

bool givens_table_init(
    givens_table_t *table,
    size_t initial_capacity
)
{
    bool success;
    size_t cap;
    givens_slot_t *slots_mem;
    size_t *free_mem;
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
        free_mem = (size_t *)malloc(
            cap * sizeof(size_t)
        );

        if (slots_mem != NULL && free_mem != NULL) {
            i = 0;
            while (i < cap) {
                slots_mem[i].key = 0;
                slots_mem[i].value = 0;
                slots_mem[i].occupied = false;
                free_mem[i] = (cap - 1) - i;
                i = i + 1;
            }

            table->slots = slots_mem;
            table->free_stack = free_mem;
            table->free_count = cap;
            table->capacity = cap;
            table->count = 0;
            success = true;
        } else {
            if (slots_mem != NULL) {
                free(slots_mem);
            }
            if (free_mem != NULL) {
                free(free_mem);
            }
        }
    }

    return success;
}

void givens_table_destroy(givens_table_t *table)
{
    if (table != NULL) {
        if (table->slots != NULL) {
            free(table->slots);
            table->slots = NULL;
        }
        if (table->free_stack != NULL) {
            free(table->free_stack);
            table->free_stack = NULL;
        }
        table->free_count = 0;
        table->capacity = 0;
        table->count = 0;
    }
}

/*
 * Internal helper to find an existing key's slot index.
 */
static bool table_find_slot(
    const givens_table_t *table,
    uintmax_t key,
    size_t *out_slot
)
{
    bool found;
    size_t cap;
    size_t i;

    found = false;
    cap = table->capacity;
    i = 0;

    while (i < cap) {
        bool is_occ;
        is_occ = table->slots[i].occupied;
        if (is_occ) {
            uintmax_t k;
            k = table->slots[i].key;
            if (k == key) {
                found = true;
                if (out_slot != NULL) {
                    *out_slot = i;
                }
                break;
            }
        }
        i = i + 1;
    }

    return found;
}

/*
 * Internal helper to expand the table capacity when full.
 */
static bool table_expand(givens_table_t *table)
{
    bool success;
    size_t old_cap;
    size_t new_cap;
    givens_slot_t *new_slots;
    size_t *new_free;
    size_t i;

    success = false;
    old_cap = table->capacity;
    new_cap = old_cap * 2;

    new_slots = (givens_slot_t *)realloc(
        table->slots,
        new_cap * sizeof(givens_slot_t)
    );
    new_free = (size_t *)realloc(
        table->free_stack,
        new_cap * sizeof(size_t)
    );

    if (new_slots != NULL && new_free != NULL) {
        table->slots = new_slots;
        table->free_stack = new_free;

        i = old_cap;
        while (i < new_cap) {
            table->slots[i].key = 0;
            table->slots[i].value = 0;
            table->slots[i].occupied = false;

            table->free_stack[table->free_count] = i;
            table->free_count = table->free_count + 1;
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

    if (table != NULL) {
        exists = table_find_slot(table, key, &existing_slot);
        if (exists) {
            table->slots[existing_slot].value = value;
            success = true;
        } else {
            bool ready_for_alloc;
            ready_for_alloc = true;
            if (table->free_count == 0) {
                ready_for_alloc = table_expand(table);
            }

            if (ready_for_alloc && table->free_count > 0) {
                size_t slot_idx;
                size_t top_idx;

                top_idx = table->free_count - 1;
                slot_idx = table->free_stack[top_idx];
                table->free_count = top_idx;

                table->slots[slot_idx].key = key;
                table->slots[slot_idx].value = value;
                table->slots[slot_idx].occupied = true;

                table->count = table->count + 1;
                success = true;
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
        found = table_find_slot(table, key, &slot_idx);
        if (found && out_val != NULL) {
            *out_val = table->slots[slot_idx].value;
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

    found = false;

    if (table != NULL && table->count > 0) {
        found = table_find_slot(table, key, &slot_idx);
        if (found) {
            table->slots[slot_idx].occupied = false;
            table->slots[slot_idx].key = 0;
            table->slots[slot_idx].value = 0;

            table->free_stack[table->free_count] = slot_idx;
            table->free_count = table->free_count + 1;
            table->count = table->count - 1;
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
