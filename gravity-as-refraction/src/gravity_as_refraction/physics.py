"""Physics engine for circulating matter knots drawing spirographs in a refractive field."""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import List, Tuple


def maxent_gravitational_constant(
    c: float, delta_omega: float, mass: float
) -> float:
    """Compute Newton's gravitational constant G from the MaxEnt wave refraction integral."""
    if mass <= 0.0:
        return 0.0
    return (c * c * delta_omega * delta_omega) / (4.0 * math.pi * mass)


@dataclass
class RefractionField:
    """Represents the refractive gradient around a central mass knot."""

    cx: float = 500.0
    cy: float = 350.0
    mass: float = 16000.0
    c: float = 300.0  # Base propagation speed of electromagnetic waves
    core_radius: float = 24.0

    def distance_from_center(self, x: float, y: float) -> float:
        dx = x - self.cx
        dy = y - self.cy
        return math.hypot(dx, dy)

    def refractive_index(self, x: float, y: float) -> float:
        r = self.distance_from_center(x, y)
        r_soft = math.hypot(r, self.core_radius)
        return 1.0 + (2.0 * self.mass) / r_soft

    def wave_speed(self, x: float, y: float) -> float:
        n = self.refractive_index(x, y)
        return self.c / n

    @property
    def mu(self) -> float:
        """Effective gravitational coupling parameter mu = G*M = 2 * mass * c."""
        return 2.0 * self.mass * self.c


@dataclass
class MatterKnot:
    """A localized circulating wave packet (matter knot) with finite radius R.

    Steered smoothly by the refractive gradient. Uses a softened core so it never
    crashes or halts, smoothly drawing precessing rosette spirograph patterns.
    """

    x: float = 80.0
    y: float = 520.0
    vx: float = 195.0
    vy: float = 0.0
    radius: float = 12.0
    phase: float = 0.0
    spin_freq: float = 16.0  # Internal wave circulation frequency
    path: List[Tuple[float, float]] = field(default_factory=list)
    max_path_points: int = 4000

    def distance(self, field: RefractionField) -> float:
        return field.distance_from_center(self.x, self.y)

    def speed(self) -> float:
        return math.hypot(self.vx, self.vy)

    def update(self, field: RefractionField, dt: float) -> None:
        # Vector from central mass knot
        dx = self.x - field.cx
        dy = self.y - field.cy
        r = math.hypot(dx, dy)

        # Softened distance ensures smooth swing through pericenter without collision
        r_soft = math.hypot(r, field.core_radius)

        # Refractive wave delay steering acceleration:
        # a = -(mu / r_soft^2) * (1 + 3 * mu / (r_soft * c^2)) * (r_vec / r_soft)
        inv_r_soft = 1.0 / r_soft
        inv_r_soft2 = inv_r_soft * inv_r_soft
        corr = 1.0 + (3.0 * field.mu) / (r_soft * field.c * field.c)
        accel_mag = field.mu * inv_r_soft2 * corr

        dir_x = (dx / r) if r > 1e-6 else 0.0
        dir_y = (dy / r) if r > 1e-6 else 0.0

        ax = -accel_mag * dir_x
        ay = -accel_mag * dir_y

        # Numerical integration step
        self.vx += ax * dt
        self.vy += ay * dt
        self.x += self.vx * dt
        self.y += self.vy * dt

        # Update internal wave phase rotation
        self.phase = (self.phase + self.spin_freq * dt * 2.0 * math.pi) % (2.0 * math.pi)

        # Record spirograph trajectory history
        self.path.append((self.x, self.y))
        if len(self.path) > self.max_path_points:
            self.path.pop(0)
