#ifndef GIVENS_GROVER_H
#define GIVENS_GROVER_H

/*
 * Portable Parallel C25 Givens Grover Search Engine
 * Author: Frédéric Blondin Custer
 *
 * Implements digital Grover search dynamics using Givens rotations
 * and high-throughput vector-parallel scanning for unique uintmax_t.
 * Designed for thread-free FFI embedding (CHICKEN 6, Python, Ada).
 */

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

/* Structure for Givens rotation operator parameters */
typedef struct {
    double theta;
    double cos_theta;
    double sin_theta;
} givens_rotation_t;

/* Structure for 2D invariant subspace amplitudes */
typedef struct {
    double ortho_amp;
    double target_amp;
} givens_state_2d_t;

/*
 * Computes the Givens rotation step angle theta for a search space
 * of size n: theta = 2 * asin(1 / sqrt(n)).
 */
double givens_angle_compute(size_t search_space_size);

/*
 * Computes the optimal Grover step count: k = floor(pi / (2 * theta)).
 */
size_t givens_optimal_steps(size_t search_space_size);

/*
 * Initializes a Givens rotation operator for a given search space.
 */
void givens_rotation_init(
    givens_rotation_t *rot,
    size_t search_space_size
);

/*
 * Applies a single 2D Givens rotation step to the amplitude state.
 */
void givens_rotation_apply_2d(
    const givens_rotation_t *rot,
    givens_state_2d_t *state
);

/*
 * Simulates complete Givens Grover subspace evolution over k steps.
 */
void givens_grover_simulate(
    size_t search_space_size,
    size_t steps,
    double *out_target_prob
);

/*
 * High-throughput parallel vector search for unique uintmax_t key.
 * Executes on 512-bit / 8-way unrolled vector pipes without threads.
 * Returns true if key is found and assigns the zero-based index.
 */
bool givens_grover_search_array(
    const uintmax_t *keys,
    size_t count,
    uintmax_t target,
    size_t *out_index
);

#endif /* GIVENS_GROVER_H */
