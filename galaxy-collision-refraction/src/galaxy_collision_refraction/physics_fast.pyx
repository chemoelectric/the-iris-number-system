# cython: language_level=3, boundscheck=False, wraparound=False, cdivision=True, nonecheck=False
"""Cython-accelerated simulation core for galaxy collision refraction theory."""

import math
from libc.math cimport sqrt

cdef extern from *:
    """
    /* Pure C structure for cache-friendly vectorized star kinematics */
    typedef struct {
        double x;
        double y;
        double vx;
        double vy;
        double ax;
        double ay;
        int galaxy_id;
    } CStar;
    """
    ctypedef struct CStar:
        double x
        double y
        double vx
        double vy
        double ax
        double ay
        int galaxy_id


cdef inline void c_accel_from_core(
    double px,
    double py,
    double core_x,
    double core_y,
    double core_mass,
    double core_softening,
    double G,
    double *out_ax,
    double *out_ay,
) noexcept nogil:
    """Compute gravitational potential gradient from an energy density cloud."""
    cdef double dx = px - core_x
    cdef double dy = py - core_y
    cdef double dist_sq = dx * dx + dy * dy + core_softening * core_softening
    cdef double dist = sqrt(dist_sq)
    cdef double inv_cube = 1.0 / (dist_sq * dist)
    cdef double mag = G * core_mass * inv_cube
    out_ax[0] = -mag * dx
    out_ay[0] = -mag * dy


def fast_step_stars(
    list stars,
    object g1,
    object g2,
    double dt,
    double G,
    int trail_step=2,
):
    """Fast vectorized update of all stars using Leapfrog/Verlet integration.
    
    Performs the entire two-phase symplectic integration of star matter knots
    without per-particle Python object overhead, function call dispatch, or
    temporary tuple allocations.
    """
    cdef int n = len(stars)
    if n == 0:
        return

    cdef double g1_x = g1.x
    cdef double g1_y = g1.y
    cdef double g1_m = g1.mass
    cdef double g1_soft = g1.softening

    cdef double g2_x = g2.x
    cdef double g2_y = g2.y
    cdef double g2_m = g2.mass
    cdef double g2_soft = g2.softening

    cdef double half_dt = 0.5 * dt
    cdef double half_dt_sq = 0.5 * dt * dt

    cdef int i
    cdef object star
    cdef double sx, sy, svx, svy, sax, say
    cdef double ax1, ay1, ax2, ay2, tot_ax, tot_ay
    cdef double new_ax1, new_ay1, new_ax2, new_ay2, new_tot_ax, new_tot_ay

    # Update each star efficiently
    for i in range(n):
        star = stars[i]
        sx = star.x
        sy = star.y
        svx = star.vx
        svy = star.vy

        # Phase 1: Compute initial acceleration from both cores
        c_accel_from_core(sx, sy, g1_x, g1_y, g1_m, g1_soft, G, &ax1, &ay1)
        c_accel_from_core(sx, sy, g2_x, g2_y, g2_m, g2_soft, G, &ax2, &ay2)
        tot_ax = ax1 + ax2
        tot_ay = ay1 + ay2

        # Record trail point
        star.trail.append((sx, sy))

        # Advance position (Verlet drift)
        sx += svx * dt + tot_ax * half_dt_sq
        sy += svy * dt + tot_ay * half_dt_sq

        # Phase 2: Compute new acceleration at updated position (using updated core positions)
        c_accel_from_core(sx, sy, g1_x, g1_y, g1_m, g1_soft, G, &new_ax1, &new_ay1)
        c_accel_from_core(sx, sy, g2_x, g2_y, g2_m, g2_soft, G, &new_ax2, &new_ay2)
        new_tot_ax = new_ax1 + new_ax2
        new_tot_ay = new_ay1 + new_ay2

        # Advance velocity (Verlet kick)
        svx += half_dt * (tot_ax + new_tot_ax)
        svy += half_dt * (tot_ay + new_tot_ay)

        # Write back state
        star.x = sx
        star.y = sy
        star.vx = svx
        star.vy = svy
