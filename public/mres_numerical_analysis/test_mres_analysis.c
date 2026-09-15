/* test_mres_analysis.c: Test suite for m-resolution analysis.
 * Strictly adheres to 72-character line limit and C23.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "mres_types.h"
#include "mres_stiff_solver.h"

static int test_graded_multiplication(void) {
  mres1_t a;
  mres1_t b;
  mres2_t c;
  mres3_t d;
  int pass;

  pass = 1;
  a = mres1_make(3.0);
  b = mres1_make(4.0);

  /* Grade 1 * Grade 1 yields Grade 2 */
  c = mres1_mul_mres1(a, b);
  if (fabs(c.val - 12.0) > 1e-12) {
    printf("FAIL: mres1_mul_mres1 expected 12.0, got %f\n", c.val);
    pass = 0;
  }

  /* Grade 1 * Grade 2 yields Grade 3 */
  d = mres1_mul_mres2(a, c);
  if (fabs(d.val - 36.0) > 1e-12) {
    printf("FAIL: mres1_mul_mres2 expected 36.0, got %f\n", d.val);
    pass = 0;
  }

  if (pass != 0) {
    printf("PASS: Graded multiplication (Fontijne-style types)\n");
  }
  return pass;
}

static int test_nilpotent_inversion(void) {
  mjet3_t a;
  mjet3_t inv_a;
  mjet3_t prod;
  int pass;

  pass = 1;
  /* a = 2.0 + 3.0*mu - 1.0*mu^2 + 0.5*mu^3 */
  a = mjet3_make(2.0,
                 mres1_make(3.0),
                 mres2_make(-1.0),
                 mres3_make(0.5));

  inv_a = mjet3_inv(a);
  prod = mjet3_mul(a, inv_a);

  if (fabs(prod.c0 - 1.0) > 1e-12) {
    printf("FAIL: Nilpotent inv c0 = %f (expected 1.0)\n", prod.c0);
    pass = 0;
  }
  if (fabs(prod.c1.val) > 1e-12) {
    printf("FAIL: Nilpotent inv c1 = %e (expected 0.0)\n",
           prod.c1.val);
    pass = 0;
  }
  if (fabs(prod.c2.val) > 1e-12) {
    printf("FAIL: Nilpotent inv c2 = %e (expected 0.0)\n",
           prod.c2.val);
    pass = 0;
  }
  if (fabs(prod.c3.val) > 1e-12) {
    printf("FAIL: Nilpotent inv c3 = %e (expected 0.0)\n",
           prod.c3.val);
    pass = 0;
  }

  if (pass != 0) {
    printf("PASS: Exact nilpotent inversion in mjet3 ring\n");
  }
  return pass;
}

static int test_indeterminate_cancellation(void) {
  /*
   * Evaluate f(x) = (exp(x) - 1) / x at the origin x = 0.
   * In floating point, this is 0/0.
   * In m-res, x = 0 + 1 * mu.
   */
  mjet3_t x;
  mjet3_t exp_x;
  mjet3_t num;
  mjet3_t quotient;
  real_t res0;
  int pass;

  pass = 1;
  x = mres_generator_mu();
  exp_x = mjet3_exp(x);

  /* exp(x) - 1 */
  num = exp_x;
  num.c0 = num.c0 - 1.0;

  /*
   * Factoring mu out of num:
   * num has c0 == 0, c1 == 1, c2 == 1/2, c3 == 1/6.
   * num / mu = 1 + (1/2)*mu + (1/6)*mu^2.
   */
  quotient = mjet3_make(num.c1.val,
                        mres1_make(num.c2.val),
                        mres2_make(num.c3.val),
                        mres3_make(0.0));

  res0 = mres_downarrow_0(quotient);
  if (fabs(res0 - 1.0) > 1e-12) {
    printf("FAIL: f(0) expected 1.0, got %f\n", res0);
    pass = 0;
  }

  if (pass != 0) {
    printf("PASS: Indeterminate 0/0 cancellation via graded jet\n");
  }
  return pass;
}

static int test_stiff_system_stability(void) {
  mres_stiff_system_t sys_euler;
  mres_stiff_system_t sys_mres;
  int pass;
  int step;

  pass = 1;
  /*
   * lambda = 10000.0, stability limit for Euler is dt < 0.0002.
   * We pick macroscopic step dt = 0.005 (25x beyond Euler limit).
   */
  sys_euler.lambda = 10000.0;
  sys_euler.t = 0.0;
  sys_euler.y = 1.0;
  sys_euler.dt_macro = 0.005;

  sys_mres.lambda = 10000.0;
  sys_mres.t = 0.0;
  sys_mres.y = 1.0;
  sys_mres.dt_macro = 0.005;

  step = 0;
  while (step < 5) {
    classical_euler_step(&sys_euler, NULL);
    mres_stiff_step(&sys_mres, NULL);
    step = step + 1;
  }

  /* Euler must have exploded: |y| >> 1e6 */
  if (fabs(sys_euler.y) < 1e5) {
    printf("FAIL: Expected Euler to explode, got %e\n", sys_euler.y);
    pass = 0;
  } else {
    printf("INFO: Classical Euler exploded to %e as predicted\n",
           sys_euler.y);
  }

  /* mres_stiff_step must remain bounded and decaying */
  if (fabs(sys_mres.y) > 1.0 || sys_mres.y < -0.1) {
    printf("FAIL: m-res stiff step unstable: %e\n", sys_mres.y);
    pass = 0;
  } else {
    printf("PASS: m-res stiff step stable: y(0.025) = %e\n",
           sys_mres.y);
  }

  return pass;
}

int main(void) {
  int all_pass;
  all_pass = 1;

  printf("=== m-Resolution Numerical Analysis Verification ===\n");

  if (test_graded_multiplication() == 0) {
    all_pass = 0;
  }
  if (test_nilpotent_inversion() == 0) {
    all_pass = 0;
  }
  if (test_indeterminate_cancellation() == 0) {
    all_pass = 0;
  }
  if (test_stiff_system_stability() == 0) {
    all_pass = 0;
  }

  if (all_pass != 0) {
    printf("ALL TESTS PASSED.\n");
    return 0;
  }
  printf("SOME TESTS FAILED.\n");
  return 1;
}
