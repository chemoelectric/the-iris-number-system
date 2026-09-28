/* mres_stiff_solver.c: Implementation of m-res stiff solver.
 * Strictly adheres to 72-character line limit and C23.
 */

#include "mres_stiff_solver.h"

double classical_euler_step(mres_stiff_system_t *sys,
                            double (*source)(double t)) {
  double s_val;
  double dy;
  double y_next;

  s_val = 0.0;
  if (source != NULL) {
    s_val = source(sys->t);
  }
  dy = (-sys->lambda * sys->y) + s_val;
  y_next = sys->y + (sys->dt_macro * dy);
  sys->y = y_next;
  sys->t = sys->t + sys->dt_macro;
  return y_next;
}

double mres_stiff_step(mres_stiff_system_t *sys,
                       double (*source)(double t)) {
  double lam;
  double dt;
  double eps;
  double decay;
  double transient;
  double manifold;
  double y_next;

  lam = sys->lambda;
  dt = sys->dt_macro;
  eps = 1.0 / lam;

  /* Fast transient decay onto discrete lattice */
  decay = 0.0;
  if ((lam * dt) < 700.0) {
    decay = exp(-lam * dt);
  }
  transient = sys->y * decay;

  /* Slow manifold evaluation via m-res jet in eps = 1/lambda */
  manifold = 0.0;
  if (source != NULL) {
    double t_target;
    double g0;
    double g1;
    double g2;
    mjet3_t g_jet;

    t_target = sys->t + dt;
    g0 = source(t_target);
    g1 = (source(t_target + 1e-6) - source(t_target - 1e-6)) / 2e-6;
    g2 = (source(t_target + 1e-6) - (2.0 * g0) +
          source(t_target - 1e-6)) / 1e-12;

    /*
     * Manifold jet: g0 - eps * g1 + eps^2 * g2
     * Algebraic evaluation in mjet3
     */
    g_jet = mjet3_make(g0,
                       mres1_make(-g1),
                       mres2_make(g2),
                       mres3_make(0.0));

    manifold = mres_downarrow_grid(g_jet, eps);
  }

  y_next = transient + manifold;
  sys->y = y_next;
  sys->t = sys->t + dt;
  return y_next;
}
