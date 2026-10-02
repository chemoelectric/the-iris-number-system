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

    cx: float = 480.0
    cy: float = 320.0
    mass: float = 18000.0
    c: float = 460.0  # Base propagation speed of electromagnetic waves
    core_radius: float = 28.0

    def distance_from_center(self, x: float, y: float) -> float:
        dx = x - self.cx
        dy = y - self.cy
        return math.hypot(dx, dy)

    def refractive_index(self, x: float, y: float) -> float:
        r = self.distance_from_center(x, y)
        effective_r = max(r, self.core_radius)
        # Gradient index n(r) = 1 + 2*G*M / (r * c^2)
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
        dndr = -(2.0 * self.mass) / (effective_r * effective_r)
        dn_dx = dndr * (dx / r)
        dn_dy = dndr * (dy / r)
        return dn_dx, dn_dy


@dataclass
class WaveFrontPoint:
    """A discrete sample point on a propagating wave front with its historical trail."""

    x: float
    y: float
    nx: float = 1.0
    ny: float = 0.0
    trail: List[Tuple[float, float]] = field(default_factory=list)


class WaveFront:
    """A propagating wavefront line advancing along its local normal vectors."""

    def __init__(
        self,
        start_x: float,
        y_min: float,
        y_max: float,
        num_points: int = 90,
    ) -> None:
        self.points: List[WaveFrontPoint] = []
        step = (y_max - y_min) / max(num_points - 1, 1)
        for i in range(num_points):
            py = y_min + i * step
            self.points.append(
                WaveFrontPoint(
                    x=start_x,
                    y=py,
                    nx=1.0,
                    ny=0.0,
                    trail=[(start_x, py)],
                )
            )
        self._trail_step_counter = 0

    def update(self, field: RefractionField, dt: float) -> None:
        """Advance each point on the wavefront according to local wave speed and normal."""
        n_points = len(self.points)
        if n_points < 2:
            return

        self._trail_step_counter += 1
        record_trail = (self._trail_step_counter % 2 == 0)

        # 1. Update point positions along current normals
        for pt in self.points:
            v = field.wave_speed(pt.x, pt.y)
            pt.x += pt.nx * v * dt
            pt.y += pt.ny * v * dt
            if record_trail:
                pt.trail.append((pt.x, pt.y))
                if len(pt.trail) > 100:
                    pt.trail.pop(0)

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
                nx = dy / tangent_len
                ny = -dx / tangent_len
                if nx < 0:
                    nx = -nx
                    ny = -ny
                self.points[i].nx = nx
                self.points[i].ny = ny


@dataclass
class MatterKnot:
    """A localized circulating wave packet (matter knot) with finite radius R.

    The differential wave speed across its diameter steers its center-of-mass
    momentum, producing the exact inverse-square gravitational trajectory.
    """

    x: float = 100.0
    y: float = 240.0
    vx: float = 340.0
    vy: float = 0.0
    radius: float = 14.0
    phase: float = 0.0
    spin_freq: float = 18.0  # Internal wave circulation frequency
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

        # Steering acceleration via differential propagation delay across vortex diameter
        accel_mag = (field.mass * 2.0 * field.c) / (effective_r * effective_r)

        ax = -accel_mag * (dx / r)
        ay = -accel_mag * (dy / r)

        self.vx += ax * dt
        self.vy += ay * dt
        self.x += self.vx * dt
        self.y += self.vy * dt
