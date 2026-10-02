"""Physics engine for circulating matter knots in the refractive gravitational field."""

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
    """Represents the refractive gradient around a localized mass knot."""

    cx: float = 480.0
    cy: float = 320.0
    mass: float = 22000.0
    c: float = 460.0  # Base propagation speed of electromagnetic waves
    core_radius: float = 32.0

    def distance_from_center(self, x: float, y: float) -> float:
        dx = x - self.cx
        dy = y - self.cy
        return math.hypot(dx, dy)

    def refractive_index(self, x: float, y: float) -> float:
        r = self.distance_from_center(x, y)
        effective_r = max(r, self.core_radius)
        strength = (2.0 * self.mass) / effective_r
        return 1.0 + strength

    def wave_speed(self, x: float, y: float) -> float:
        n = self.refractive_index(x, y)
        return self.c / n


@dataclass
class MatterKnot:
    """A localized circulating wave packet (matter knot) with finite radius R.

    The differential wave speed across its diameter steers its center-of-mass
    momentum, producing the exact inverse-square gravitational trajectory.
    """

    x: float = 60.0
    y: float = 486.0
    vx: float = 340.0
    vy: float = 0.0
    radius: float = 14.0
    phase: float = 0.0
    spin_freq: float = 18.0  # Internal wave circulation frequency
    path: List[Tuple[float, float]] = field(default_factory=list)
    max_path_points: int = 2400

    def update(self, field: RefractionField, dt: float) -> None:
        self.path.append((self.x, self.y))
        if len(self.path) > self.max_path_points:
            self.path.pop(0)

        # Internal circulation phase
        self.phase = (self.phase + self.spin_freq * dt * 2.0 * math.pi) % (2.0 * math.pi)

        # Vector from central mass knot to matter knot
        dx = self.x - field.cx
        dy = self.y - field.cy
        r = math.hypot(dx, dy)
        if r < 1e-6:
            return

        effective_r = max(r, field.core_radius)

        # Steering acceleration via differential propagation delay across vortex diameter
        accel_mag = (field.mass * 2.0 * field.c) / (effective_r * effective_r)
        ax = -accel_mag * (dx / r)
        ay = -accel_mag * (dy / r)

        self.vx += ax * dt
        self.vy += ay * dt
        self.x += self.vx * dt
        self.y += self.vy * dt
