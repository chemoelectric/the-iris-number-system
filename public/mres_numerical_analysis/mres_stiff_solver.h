/* mres_stiff_solver.h: Stiff system solver via m-res analysis.
 * Solves stiff boundary layers and differential systems using
 * graded jet progression and downarrow projection.
 * Strictly adheres to 72-character line limit and C23.
 */

#ifndef MRES_STIFF_SOLVER_H
#define MRES_STIFF_SOLVER_H

#include "mres_types.h"

/*
 * State of a stiff scalar system:
 * dy/dt = -lambda * y + source(t)
 */
typedef struct {
  double lambda;      /* Stiffness parameter (e.g. 1e4) */
  double t;           /* Current time */
  double y;           /* Current state */
  double dt_macro;    /* Macroscopic step size */
} mres_stiff_system_t;

/*
 * Step using graded m-res jet algebra:
 * Generates exact jet expansion, applies Padé rational
 * resolution operator in mjet3, and projects via downarrow.
 * Unconditionally stable for large macroscopic steps dt.
 */
double mres_stiff_step(mres_stiff_system_t *sys,
                       double (*source)(double t));

/*
 * Classical forward Euler step for explicit comparison.
 * Unstable when dt > 2 / lambda.
 */
double classical_euler_step(mres_stiff_system_t *sys,
                            double (*source)(double t));

#endif /* MRES_STIFF_SOLVER_H */
