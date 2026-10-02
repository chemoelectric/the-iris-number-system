"""Physics engine for circulating matter knots in the refractive gravitational field."""

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
    """Represents the refractive gradient around a central matter knot."""

    cx: float = 480.0
    cy: float = 320.0
    mass: float = 16000.0
    c: float = 300.0  # Base propagation speed of electromagnetic waves
    core_radius: float = 24.0

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

    @property
    def mu(self) -> float:
        """Effective gravitational coupling parameter mu = G*M = 2 * mass * c."""
        return 2.0 * self.mass * self.c


@dataclass
class MatterKnot:
    """A localized circulating wave packet (matter knot) with finite radius R.

    The differential wave speed across its diameter steers its center-of-mass
    momentum, producing exact Newtonian and precessing Keplerian orbits.
    """

    x: float = 480.0
    y: float = 120.0
    vx: float = 210.0
    vy: float = 0.0
    radius: float = 12.0
    phase: float = 0.0
    spin_freq: float = 16.0  # Internal wave circulation frequency
    path: List[Tuple[float, float]] = field(default_factory=list)
    max_path_points: int = 1500
    captured: bool = False

    def distance(self, field: RefractionField) -> float:
        return field.distance_from_center(self.x, self.y)

    def speed(self) -> float:
        return math.hypot(self.vx, self.vy)

    def angular_momentum(self, field: RefractionField) -> float:
        dx = self.x - field.cx
        dy = self.y - field.cy
        return dx * self.vy - dy * self.vx

    def specific_energy(self, field: RefractionField) -> float:
        r = self.distance(field)
        if r < 1e-4:
            return 0.0
        v = self.speed()
        return 0.5 * v * v - (field.mu / r)

    def orbit_type(self, field: RefractionField) -> str:
        if self.captured:
            return "Captured in Core"
        e_spec = self.specific_energy(field)
        if e_spec < -100.0:
            return "Bound (Elliptic)"
        elif abs(e_spec) <= 100.0:
            return "Parabolic (Escape Boundary)"
        else:
            return "Unbound (Hyperbolic)"

    def update(self, field: RefractionField, dt: float) -> None:
        if self.captured:
            return

        # Vector from central mass knot
        dx = self.x - field.cx
        dy = self.y - field.cy
        r = math.hypot(dx, dy)

        # Check for core collision / capture
        if r <= field.core_radius:
            self.captured = True
            self.vx = 0.0
            self.vy = 0.0
            return

        # Differential wave speed across vortex diameter produces acceleration:
        # a = - mu / r^2 * r_hat with higher-order refractive delay term:
        # a = -(mu / r^2) * (1 + 3 * mu / (r * c^2))
        inv_r = 1.0 / r
        inv_r2 = inv_r * inv_r
        # Refractive precession correction
        corr = 1.0 + (3.0 * field.mu) / (r * field.c * field.c)
        accel_mag = field.mu * inv_r2 * corr

        ax = -accel_mag * (dx * inv_r)
        ay = -accel_mag * (dy * inv_r)

        # Symplectic Verlet integration step
        self.vx += ax * dt
        self.vy += ay * dt
        self.x += self.vx * dt
        self.y += self.vy * dt

        # Update internal circulation phase
        self.phase = (self.phase + self.spin_freq * dt * 2.0 * math.pi) % (2.0 * math.pi)

        # Record orbit path history
        self.path.append((self.x, self.y))
        if len(self.path) > self.max_path_points:
            self.path.pop(0)


def create_circular_orbit(field: RefractionField, radius: float = 190.0) -> MatterKnot:
    """Initialize a matter knot in a stable circular orbit."""
    v_circ = math.sqrt(field.mu / radius)
    return MatterKnot(
        x=field.cx,
        y=field.cy - radius,
        vx=v_circ,
        vy=0.0,
        radius=12.0,
    )


def create_elliptic_orbit(
    field: RefractionField, periapsis: float = 120.0, eccentricity: float = 0.55
) -> MatterKnot:
    """Initialize a matter knot in an eccentric Keplerian ellipse."""
    # For ellipse: v_peri = sqrt(mu * (1 + e) / r_peri)
    v_peri = math.sqrt((field.mu * (1.0 + eccentricity)) / periapsis)
    return MatterKnot(
        x=field.cx,
        y=field.cy - periapsis,
        vx=v_peri,
        vy=0.0,
        radius=12.0,
    )


def create_scattering_orbit(
    field: RefractionField, impact_param: float = 160.0, v_inf: float = 230.0
) -> MatterKnot:
    """Initialize a matter knot in a hyperbolic flyby trajectory."""
    return MatterKnot(
        x=field.cx - 380.0,
        y=field.cy + impact_param,
        vx=v_inf,
        vy=0.0,
        radius=12.0,
    )


def create_rosette_orbit(
    field: RefractionField, periapsis: float = 75.0
) -> MatterKnot:
    """Initialize a close-in orbit demonstrating perihelion advance (rosette pattern)."""
    # High eccentricity and close periapsis to showcase wave-delay precession
    v_peri = math.sqrt((field.mu * 1.65) / periapsis)
    return MatterKnot(
        x=field.cx,
        y=field.cy - periapsis,
        vx=v_peri,
        vy=0.0,
        radius=12.0,
        max_path_points=2400,
    )
