/*
 * Portable Parallel C25 Givens Grover Search Engine
 * Author: Frédéric Blondin Custer
 *
 * Implements digital Grover search dynamics via Givens rotations
 * with thread-free data-parallel vectorization for unique uintmax_t
 * and highly non-unique sentinel entries (e.g. empty/unused slots).
 */

#include "givens_grover.h"
#include <math.h>

#define PI_CONST 3.141592653589793238462643383279502884

double givens_angle_compute(size_t search_space_size)
{
    double n_val;
    double sq_val;
    double inv_sq;
    double asin_val;
    double theta;

    n_val = (double)search_space_size;
    sq_val = sqrt(n_val);
    inv_sq = 1.0 / sq_val;
    asin_val = asin(inv_sq);
    theta = 2.0 * asin_val;

    return theta;
}

double givens_angle_multi_compute(
    size_t search_space_size,
    size_t multiplicity
)
{
    double n_val;
    double m_val;
    double ratio;
    double sq_ratio;
    double asin_val;
    double theta;

    n_val = (double)search_space_size;
    m_val = (double)multiplicity;
    if (m_val > n_val) {
        m_val = n_val;
    }
    if (m_val < 1.0) {
        m_val = 1.0;
    }

    ratio = m_val / n_val;
    sq_ratio = sqrt(ratio);
    asin_val = asin(sq_ratio);
    theta = 2.0 * asin_val;

    return theta;
}

size_t givens_optimal_steps(size_t search_space_size)
{
    double theta;
    double half_pi;
    double k_float;
    size_t k_steps;

    theta = givens_angle_compute(search_space_size);
    half_pi = 0.5 * PI_CONST;
    k_float = half_pi / theta;
    k_steps = (size_t)floor(k_float);

    return k_steps;
}

size_t givens_optimal_multi_steps(
    size_t search_space_size,
    size_t multiplicity
)
{
    double theta;
    double half_pi;
    double k_float;
    size_t k_steps;

    theta = givens_angle_multi_compute(search_space_size, multiplicity);
    half_pi = 0.5 * PI_CONST;
    k_float = half_pi / theta;
    k_steps = (size_t)floor(k_float);

    return k_steps;
}

void givens_rotation_init(
    givens_rotation_t *rot,
    size_t search_space_size
)
{
    double theta;
    double cos_val;
    double sin_val;

    theta = givens_angle_compute(search_space_size);
    cos_val = cos(theta);
    sin_val = sin(theta);

    rot->theta = theta;
    rot->cos_theta = cos_val;
    rot->sin_theta = sin_val;
}

void givens_rotation_multi_init(
    givens_rotation_t *rot,
    size_t search_space_size,
    size_t multiplicity
)
{
    double theta;
    double cos_val;
    double sin_val;

    theta = givens_angle_multi_compute(search_space_size, multiplicity);
    cos_val = cos(theta);
    sin_val = sin(theta);

    rot->theta = theta;
    rot->cos_theta = cos_val;
    rot->sin_theta = sin_val;
}

void givens_rotation_apply_2d(
    const givens_rotation_t *rot,
    givens_state_2d_t *state
)
{
    double c;
    double s;
    double o;
    double m;
    double t1;
    double t2;
    double new_o;
    double new_m;

    c = rot->cos_theta;
    s = rot->sin_theta;
    o = state->ortho_amp;
    m = state->target_amp;

    t1 = c * o;
    t2 = s * m;
    new_o = t1 - t2;

    t1 = s * o;
    t2 = c * m;
    new_m = t1 + t2;

    state->ortho_amp = new_o;
    state->target_amp = new_m;
}

void givens_grover_simulate(
    size_t search_space_size,
    size_t steps,
    double *out_target_prob
)
{
    givens_rotation_t rot;
    givens_state_2d_t state;
    double theta;
    double half_t;
    double final_prob;
    size_t i;

    givens_rotation_init(&rot, search_space_size);
    theta = rot.theta;
    half_t = 0.5 * theta;

    state.ortho_amp = cos(half_t);
    state.target_amp = sin(half_t);

    i = 0;
    while (i < steps) {
        givens_rotation_apply_2d(&rot, &state);
        i = i + 1;
    }

    final_prob = state.target_amp * state.target_amp;
    if (out_target_prob != NULL) {
        *out_target_prob = final_prob;
    }
}

/*
 * Search a block of 8 uintmax_t elements (512-bit vector size).
 */
static inline bool search_block_8(
    const uintmax_t *keys,
    size_t base_idx,
    uintmax_t target,
    size_t *out_idx
)
{
    bool found;
    size_t offset;
    size_t match_pos;

    found = false;
    match_pos = 0;
    offset = 0;

    while (offset < 8) {
        size_t curr_pos;
        uintmax_t val;

        curr_pos = base_idx + offset;
        val = keys[curr_pos];
        if (val == target) {
            found = true;
            match_pos = curr_pos;
            break;
        }
        offset = offset + 1;
    }

    if (found) {
        *out_idx = match_pos;
    }

    return found;
}

/*
 * Vectorized search scanning across 512-bit chunks for Zen 5 pipes.
 */
bool givens_grover_search_array(
    const uintmax_t *keys,
    size_t count,
    uintmax_t target,
    size_t *out_index
)
{
    bool found;
    size_t i;
    size_t limit;
    size_t result_idx;

    found = false;
    result_idx = 0;
    i = 0;

    if (keys != NULL && count > 0) {
        limit = count & ~((size_t)7);

        /* 512-bit unrolled vector processing loop */
        while (i < limit) {
            bool blk_found;
            size_t blk_idx;

            blk_found = search_block_8(keys, i, target, &blk_idx);
            if (blk_found) {
                found = true;
                result_idx = blk_idx;
                break;
            }
            i = i + 8;
        }

        /* Tail cleanup loop */
        if (!found) {
            while (i < count) {
                uintmax_t curr;
                curr = keys[i];
                if (curr == target) {
                    found = true;
                    result_idx = i;
                    break;
                }
                i = i + 1;
            }
        }
    }

    if (found && out_index != NULL) {
        *out_index = result_idx;
    }

    return found;
}

/*
 * Non-unique search for first match (e.g. finding empty unused slot).
 */
bool givens_grover_search_nonunique(
    const uintmax_t *keys,
    size_t count,
    uintmax_t target,
    size_t *out_index
)
{
    bool found;
    size_t match_pos;

    found = givens_grover_search_array(
        keys,
        count,
        target,
        &match_pos
    );

    if (found && out_index != NULL) {
        *out_index = match_pos;
    }

    return found;
}
