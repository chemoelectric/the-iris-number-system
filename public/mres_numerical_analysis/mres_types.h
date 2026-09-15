/* mres_types.h: Graded m-resolution types and operations.
 * Part of the Iris Number System Foundations.
 * Strictly adheres to 72-character line limit and C23.
 */

#ifndef MRES_TYPES_H
#define MRES_TYPES_H

#include <math.h>
#include <stdbool.h>
#include <stddef.h>

/*
 * Fontijne-style graded typing for m-resolution analysis.
 * Pure grades are kept strictly separate from composite jets.
 * An m-res number of order k contains ONLY grade-k components.
 * A composite structure containing mixed orders is an mjet_t,
 * NEVER called an m-res number.
 */

/* Grade 0: Macroscopic scalar (Real) */
typedef double real_t;

/* Grade 1: Pure first-order m-res number (x1 * mu) */
typedef struct {
  double val;
} mres1_t;

/* Grade 2: Pure second-order m-res number (x2 * mu^2) */
typedef struct {
  double val;
} mres2_t;

/* Grade 3: Pure third-order m-res number (x3 * mu^3) */
typedef struct {
  double val;
} mres3_t;

/*
 * Composite structure: mjet3_t.
 * Aggregates distinct homogeneous grades up to order 3.
 * Truncation condition: mu^4 == 0 (discrete lattice cutoff).
 */
typedef struct {
  real_t c0;
  mres1_t c1;
  mres2_t c2;
  mres3_t c3;
} mjet3_t;

/* --- Constructors for Pure Grades --- */

static inline mres1_t mres1_make(double v) {
  mres1_t r;
  r.val = v;
  return r;
}

static inline mres2_t mres2_make(double v) {
  mres2_t r;
  r.val = v;
  return r;
}

static inline mres3_t mres3_make(double v) {
  mres3_t r;
  r.val = v;
  return r;
}

/* --- Constructor for Composite Jet --- */

static inline mjet3_t mjet3_make(real_t c0,
                                 mres1_t c1,
                                 mres2_t c2,
                                 mres3_t c3) {
  mjet3_t j;
  j.c0 = c0;
  j.c1 = c1;
  j.c2 = c2;
  j.c3 = c3;
  return j;
}

static inline mjet3_t mjet3_from_real(real_t x) {
  mjet3_t j;
  j.c0 = x;
  j.c1 = mres1_make(0.0);
  j.c2 = mres2_make(0.0);
  j.c3 = mres3_make(0.0);
  return j;
}

static inline mjet3_t mjet3_from_mres1(mres1_t x) {
  mjet3_t j;
  j.c0 = 0.0;
  j.c1 = x;
  j.c2 = mres2_make(0.0);
  j.c3 = mres3_make(0.0);
  return j;
}

/* Canonical first-order resolution generator mu */
static inline mjet3_t mres_generator_mu(void) {
  mjet3_t j;
  j.c0 = 0.0;
  j.c1 = mres1_make(1.0);
  j.c2 = mres2_make(0.0);
  j.c3 = mres3_make(0.0);
  return j;
}

/* --- Graded Homogeneous Addition --- */

static inline mres1_t mres1_add(mres1_t a, mres1_t b) {
  mres1_t r;
  r.val = a.val + b.val;
  return r;
}

static inline mres1_t mres1_sub(mres1_t a, mres1_t b) {
  mres1_t r;
  r.val = a.val - b.val;
  return r;
}

static inline mres2_t mres2_add(mres2_t a, mres2_t b) {
  mres2_t r;
  r.val = a.val + b.val;
  return r;
}

static inline mres2_t mres2_sub(mres2_t a, mres2_t b) {
  mres2_t r;
  r.val = a.val - b.val;
  return r;
}

static inline mres3_t mres3_add(mres3_t a, mres3_t b) {
  mres3_t r;
  r.val = a.val + b.val;
  return r;
}

static inline mres3_t mres3_sub(mres3_t a, mres3_t b) {
  mres3_t r;
  r.val = a.val - b.val;
  return r;
}

/* --- Pure Graded Multiplications (Fontijne Style) --- */

/* real * mres1 -> mres1 */
static inline mres1_t real_mul_mres1(real_t s, mres1_t a) {
  mres1_t r;
  r.val = s * a.val;
  return r;
}

/* real * mres2 -> mres2 */
static inline mres2_t real_mul_mres2(real_t s, mres2_t a) {
  mres2_t r;
  r.val = s * a.val;
  return r;
}

/* real * mres3 -> mres3 */
static inline mres3_t real_mul_mres3(real_t s, mres3_t a) {
  mres3_t r;
  r.val = s * a.val;
  return r;
}

/* mres1 * mres1 -> mres2 (Grade 1 * Grade 1 yields Grade 2!) */
static inline mres2_t mres1_mul_mres1(mres1_t a, mres1_t b) {
  mres2_t r;
  r.val = a.val * b.val;
  return r;
}

/* mres1 * mres2 -> mres3 (Grade 1 * Grade 2 yields Grade 3!) */
static inline mres3_t mres1_mul_mres2(mres1_t a, mres2_t b) {
  mres3_t r;
  r.val = a.val * b.val;
  return r;
}

/* Higher products vanish by truncation: mu^4 == 0 */

/* --- Composite Jet Arithmetic --- */

static inline mjet3_t mjet3_add(mjet3_t a, mjet3_t b) {
  mjet3_t r;
  r.c0 = a.c0 + b.c0;
  r.c1 = mres1_add(a.c1, b.c1);
  r.c2 = mres2_add(a.c2, b.c2);
  r.c3 = mres3_add(a.c3, b.c3);
  return r;
}

static inline mjet3_t mjet3_sub(mjet3_t a, mjet3_t b) {
  mjet3_t r;
  r.c0 = a.c0 - b.c0;
  r.c1 = mres1_sub(a.c1, b.c1);
  r.c2 = mres2_sub(a.c2, b.c2);
  r.c3 = mres3_sub(a.c3, b.c3);
  return r;
}

/* Graded discrete Cauchy convolution */
static inline mjet3_t mjet3_mul(mjet3_t a, mjet3_t b) {
  mjet3_t r;
  double c0_val;
  double c1_val;
  double c2_val;
  double c3_val;

  c0_val = a.c0 * b.c0;
  c1_val = (a.c0 * b.c1.val) + (a.c1.val * b.c0);
  c2_val = (a.c0 * b.c2.val) + (a.c1.val * b.c1.val) +
           (a.c2.val * b.c0);
  c3_val = (a.c0 * b.c3.val) + (a.c1.val * b.c2.val) +
           (a.c2.val * b.c1.val) + (a.c3.val * b.c0);

  r.c0 = c0_val;
  r.c1 = mres1_make(c1_val);
  r.c2 = mres2_make(c2_val);
  r.c3 = mres3_make(c3_val);
  return r;
}

static inline mjet3_t mjet3_scale(mjet3_t a, real_t s) {
  mjet3_t r;
  r.c0 = a.c0 * s;
  r.c1 = real_mul_mres1(s, a.c1);
  r.c2 = real_mul_mres2(s, a.c2);
  r.c3 = real_mul_mres3(s, a.c3);
  return r;
}

/*
 * Exact Inversion via Nilpotent Series:
 * X = x0 * (1 + delta), where delta is strictly nilpotent.
 * X^{-1} = (1 / x0) * (1 - delta + delta^2 - delta^3)
 * Exact algebraic closed form without limits or roundoff.
 */
static inline mjet3_t mjet3_inv(mjet3_t a) {
  mjet3_t r;
  double inv0;
  double d1;
  double d2;
  double d3;
  double r1;
  double r2;
  double r3;

  inv0 = 1.0 / a.c0;
  d1 = a.c1.val * inv0;
  d2 = a.c2.val * inv0;
  d3 = a.c3.val * inv0;

  /* Series expansion:
   * term 1: -d1 - d2 - d3
   * term 2: d1^2 + 2*d1*d2
   * term 3: -d1^3
   */
  r1 = -d1;
  r2 = -d2 + (d1 * d1);
  r3 = -d3 + (2.0 * d1 * d2) - (d1 * d1 * d1);

  r.c0 = inv0;
  r.c1 = mres1_make(r1 * inv0);
  r.c2 = mres2_make(r2 * inv0);
  r.c3 = mres3_make(r3 * inv0);
  return r;
}

static inline mjet3_t mjet3_div(mjet3_t a, mjet3_t b) {
  mjet3_t inv_b;
  inv_b = mjet3_inv(b);
  return mjet3_mul(a, inv_b);
}

/*
 * Transcendental Functions:
 * Analytical propagation through the graded jet.
 */
static inline mjet3_t mjet3_exp(mjet3_t a) {
  mjet3_t r;
  double e0;
  double e1;
  double e2;
  double e3;

  e0 = exp(a.c0);
  e1 = e0 * a.c1.val;
  e2 = e0 * (a.c2.val + (0.5 * a.c1.val * a.c1.val));
  e3 = e0 * (a.c3.val + (a.c1.val * a.c2.val) +
             (a.c1.val * a.c1.val * a.c1.val / 6.0));

  r.c0 = e0;
  r.c1 = mres1_make(e1);
  r.c2 = mres2_make(e2);
  r.c3 = mres3_make(e3);
  return r;
}

/* --- Typed Downarrow Operations (Downarrow Projections) --- */

/* Mode 1: Observable Projection (Extracts macroscopic Grade 0) */
static inline real_t mres_downarrow_0(mjet3_t j) {
  return j.c0;
}

/* Mode 2: Discrete Lattice Projection down to grid G_N with step dx */
static inline real_t mres_downarrow_grid(mjet3_t j, double dx) {
  double val;
  double rounded;

  val = j.c0 + (j.c1.val * dx) + (j.c2.val * dx * dx) +
        (j.c3.val * dx * dx * dx);
  rounded = round(val / dx) * dx;
  return rounded;
}

/*
 * Mode 3: Differential Rate Extraction:
 * Extracts the exact k-th order rate of change without dividing
 * by any step size!
 * order 0 -> c0
 * order 1 -> 1! * c1 = c1
 * order 2 -> 2! * c2 = 2 * c2
 * order 3 -> 3! * c3 = 6 * c3
 */
static inline double mres_downarrow_rate(mjet3_t j, int order) {
  double result;
  result = 0.0;
  if (order == 0) {
    result = j.c0;
  } else if (order == 1) {
    result = j.c1.val;
  } else if (order == 2) {
    result = 2.0 * j.c2.val;
  } else if (order == 3) {
    result = 6.0 * j.c3.val;
  }
  return result;
}

/* External declarations for addressable copies */
real_t mres_addr_downarrow_0(mjet3_t j);
real_t mres_addr_downarrow_grid(mjet3_t j, double dx);
double mres_addr_downarrow_rate(mjet3_t j, int order);
mjet3_t mres_addr_mjet3_add(mjet3_t a, mjet3_t b);
mjet3_t mres_addr_mjet3_mul(mjet3_t a, mjet3_t b);
mjet3_t mres_addr_mjet3_inv(mjet3_t a);

#endif /* MRES_TYPES_H */
