"""Physics engine for wave refraction in the unified electromagnetic field."""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import List, Tuple


def maxent_gravitational_constant(
    c: float, delta_omega: float, mass: float
) -> float:
    """Compute Newton's gravitational constant G from the MaxEnt wave refraction integral.

    G = (c^2 * delta_omega^2 / (4 * pi * m)) * (15 / pi^4) * integral_0^inf [u^3 / (e^u - 1)] du
      = c^2 * delta_omega^2 / (4 * pi * m)
    """
    if mass <= 0.0:
        return 0.0
    return (c * c * delta_omega * delta_omega) / (4.0 * math.pi * mass)


@dataclass
class RefractionField:
    """Represents the refractive gradient around a localized mass knot."""

    cx: float = 400.0
    cy: float = 300.0
    mass: float = 8000.0
    c: float = 240.0  # Base propagation speed of electromagnetic waves
    core_radius: float = 24.0

    def distance_from_center(self, x: float, y: float) -> float:
        dx = x - self.cx
        dy = y - self.cy
        return math.hypot(dx, dy)

    def refractive_index(self, x: float, y: float) -> float:
        r = self.distance_from_center(x, y)
        effective_r = max(r, self.core_radius)
        # Gradient index n(r) = 1 + 2*G*M / (r * c^2)
        # The factor of 2 reproduces the full deflection of electromagnetic waves
        strength = (2.0 * self.mass) / effective_r
        return 1.0 + strength

    def wave_speed(self, x: float, y: float) -> float:
        n = self.refractive_index(x, y)
        return self.c / n

    def grad_n(self, x: float, y: float) -> Tuple[float, float]:
        """Gradient of the refractive index vector (dn/dx, dn/dy)."""
        dx = x - self.cx
        dy = y - self.cy
        r = math.hypot(dx, dy)
        if r < 1e-4:
            return 0.0, 0.0
        effective_r = max(r, self.core_radius)
        # d/dr (1 + 2*M/r) = -2*M / r^2
        dndr = -(2.0 * self.mass) / (effective_r * effective_r)
        dn_dx = dndr * (dx / r)
        dn_dy = dndr * (dy / r)
        return dn_dx, dn_dy


@dataclass
class WaveFrontPoint:
    x: float
    y: float
    nx: float = 1.0
    ny: float = 0.0


class WaveFront:
    """A single propagating wavefront line advancing along its local normals."""

    def __init__(
        self,
        start_x: float,
        y_min: float,
        y_max: float,
        num_points: int = 80,
    ) -> None:
        self.points: List[WaveFrontPoint] = []
        step = (y_max - y_min) / max(num_points - 1, 1)
        for i in range(num_points):
            py = y_min + i * step
            self.points.append(WaveFrontPoint(x=start_x, y=py, nx=1.0, ny=0.0))

    def update(self, field: RefractionField, dt: float) -> None:
        """Advance each point on the wavefront according to local wave speed and normal."""
        n_points = len(self.points)
        if n_points < 2:
            return

        # 1. Update point positions along current normals
        for pt in self.points:
            v = field.wave_speed(pt.x, pt.y)
            pt.x += pt.nx * v * dt
            pt.y += pt.ny * v * dt

        # 2. Recompute local normals perpendicular to the wavefront line
        for i in range(n_points):
            if i == 0:
                dx = self.points[1].x - self.points[0].x
                dy = self.points[1].y - self.points[0].y
            elif i == n_points - 1:
                dx = self.points[-1].x - self.points[-2].x
                dy = self.points[-1].y - self.points[-2].y
            else:
                dx = self.points[i + 1].x - self.points[i - 1].x
                dy = self.points[i + 1].y - self.points[i - 1].y

            tangent_len = math.hypot(dx, dy)
            if tangent_len > 1e-6:
                # Normal is perpendicular to tangent vector (dy, -dx)
                # Ensure normal points generally in +x direction
                nx = dy / tangent_len
                ny = -dx / tangent_len
                if nx < 0:
                    nx = -nx
                    ny = -ny
                self.points[i].nx = nx
                self.points[i].ny = ny


@dataclass
class Ray:
    """A single optical ray / Poynting energy trajectory."""

    x: float
    y: float
    vx: float
    vy: float
    path: List[Tuple[float, float]] = field(default_factory=list)
    active: bool = True

    def update(self, field: RefractionField, dt: float) -> None:
        if not self.active:
            return

        self.path.append((self.x, self.y))
        if len(self.path) > 300:
            self.path.pop(0)

        # Hamiltonian ray optics in inhomogeneous refractive index n(r)
        # dr/dt = (c/n) * u
        # du/dt = (c/n) * [grad(n)/n - (u . grad(n)/n) * u]
        n = field.refractive_index(self.x, self.y)
        dn_dx, dn_dy = field.grad_n(self.x, self.y)

        v_mag = math.hypot(self.vx, self.vy)
        if v_mag < 1e-6:
            return

        ux = self.vx / v_mag
        uy = self.vy / v_mag

        u_dot_grad = ux * (dn_dx / n) + uy * (dn_dy / n)
        acc_x = (field.c / n) * ((dn_dx / n) - u_dot_grad * ux)
        acc_y = (field.c / n) * ((dn_dy / n) - u_dot_grad * uy)

        speed = field.c / n
        ux += acc_x * dt
        uy += acc_y * dt
        u_norm = math.hypot(ux, uy)
        if u_norm > 1e-6:
            ux /= u_norm
            uy /= u_norm

        self.vx = ux * speed
        self.vy = uy * speed
        self.x += self.vx * dt
        self.y += self.vy * dt

        # Terminate if ray leaves bounds or gets absorbed in core
        r = field.distance_from_center(self.x, self.y)
        if r < field.core_radius * 0.7 or self.x > 900 or self.x < -100 or self.y > 700 or self.y < -100:
            self.active = False


class RayBeam:
    """A collection of parallel rays demonstrating gravitational lensing."""

    def __init__(
        self,
        start_x: float = 60.0,
        y_min: float = 120.0,
        y_max: float = 480.0,
        count: int = 15,
        speed: float = 220.0,
    ) -> None:
        self.rays: List[Ray] = []
        step = (y_max - y_min) / max(count - 1, 1)
        for i in range(count):
            ry = y_min + i * step
            self.rays.append(Ray(x=start_x, y=ry, vx=speed, vy=0.0))

    def update(self, field: RefractionField, dt: float) -> None:
        for ray in self.rays:
            ray.update(field, dt)


@dataclass
class MatterKnot:
    """A localized circulating wave packet (matter knot) with finite radius R.

    The differential wave speed across its diameter steers its center-of-mass
    momentum, producing the exact inverse-square gravitational trajectory.
    """

    x: float = 150.0
    y: float = 120.0
    vx: float = 160.0
    vy: float = 0.0
    radius: float = 14.0
    phase: float = 0.0
    spin_freq: float = 12.0  # Internal wave circulation frequency
    path: List[Tuple[float, float]] = field(default_factory=list)

    def update(self, field: RefractionField, dt: float) -> None:
        self.path.append((self.x, self.y))
        if len(self.path) > 400:
            self.path.pop(0)

        # Internal circulation phase
        self.phase = (self.phase + self.spin_freq * dt * 2.0 * math.pi) % (2.0 * math.pi)

        # Vector from central mass knot to matter knot
        dx = self.x - field.cx
        dy = self.y - field.cy
        r = math.hypot(dx, dy)
        effective_r = max(r, field.core_radius)

        # Wave refraction mechanism:
        # Differential propagation delay across the vortex diameter d = 2*radius
        # Delta_v = (dv/dr) * 2*radius
        # Steering acceleration = - G * M / r^2 along radial direction
        accel_mag = (field.mass * 2.0 * field.c) / (effective_r * effective_r)

        ax = -accel_mag * (dx / r)
        ay = -accel_mag * (dy / r)

        self.vx += ax * dt
        self.vy += ay * dt
        self.x += self.vx * dt
        self.y += self.vy * dt
