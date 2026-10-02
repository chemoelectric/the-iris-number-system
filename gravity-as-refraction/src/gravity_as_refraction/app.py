"""Interactive 2D Pyglet simulator for playing with orbital parameters in a wave refractive field."""

from __future__ import annotations

import math
import sys
from typing import List

try:
    import pyglet
    from pyglet import shapes
    from pyglet.window import key
except ImportError:
    pyglet = None  # type: ignore

try:
    from .physics import (
        MatterKnot,
        RefractionField,
        create_circular_orbit,
        create_elliptic_orbit,
        create_rosette_orbit,
        create_scattering_orbit,
    )
except ImportError:
    from physics import (
        MatterKnot,
        RefractionField,
        create_circular_orbit,
        create_elliptic_orbit,
        create_rosette_orbit,
        create_scattering_orbit,
    )


def _make_line(
    x1: float,
    y1: float,
    x2: float,
    y2: float,
    color: tuple,
    batch,
    width: float = 1.0,
):
    """Create a line shape compatible across all pyglet versions."""
    try:
        return shapes.Line(x1, y1, x2, y2, thickness=width, color=color, batch=batch)
    except TypeError:
        try:
            return shapes.Line(x1, y1, x2, y2, width=width, color=color, batch=batch)
        except TypeError:
            return shapes.Line(x1, y1, x2, y2, color=color, batch=batch)


class OrbitSimulatorWindow:
    """Hardware-accelerated orbital parameter simulation window."""

    def __init__(self, width: int = 1000, height: int = 700) -> None:
        if pyglet is None:
            raise RuntimeError(
                "pyglet is required to run the graphical interface. "
                "Install it with: pip install pyglet"
            )

        self.width = width
        self.height = height
        self.window = pyglet.window.Window(
            width=width,
            height=height,
            caption="gravity-as-refraction • Orbital Parameter Simulator",
            resizable=False,
        )

        # Refractive field around central mass
        self.field = RefractionField(
            cx=width * 0.5,
            cy=height * 0.5,
            mass=18000.0,
            c=320.0,
            core_radius=26.0,
        )

        # Active matter knot and simulation settings
        self.preset_id = 1
        self.preset_name = "Circular Orbit"
        self.knot: MatterKnot = create_circular_orbit(self.field, radius=200.0)

        self.paused = False
        self.show_grid = False
        self.sim_speed = 1.0  # Simulation time scale multiplier

        # Graphics batches
        self.batch = pyglet.graphics.Batch()
        self.hud_batch = pyglet.graphics.Batch()

        # HUD labels
        self.title_label = pyglet.text.Label(
            "WAVE-REFRACTIVE GRAVITATIONAL ORBIT SIMULATOR",
            font_name="Sans-Serif",
            font_size=12,
            x=20,
            y=height - 24,
            color=(245, 245, 245, 255),
            batch=self.hud_batch,
        )

        self.equation_label = pyglet.text.Label(
            "G = (c²·Δω² / 4πm) · (15/π⁴) ∫₀^∞ [u³/(eᵘ - 1)] du = c²·Δω² / (4πm)   |   n(r) = 1 + 2GM/(r·c²)",
            font_name="Monospace",
            font_size=10,
            x=20,
            y=height - 46,
            color=(255, 215, 110, 255),
            batch=self.hud_batch,
        )

        self.metrics_label = pyglet.text.Label(
            "",
            font_name="Monospace",
            font_size=10,
            x=20,
            y=height - 68,
            color=(180, 210, 240, 255),
            batch=self.hud_batch,
        )

        self.params_label = pyglet.text.Label(
            "",
            font_name="Monospace",
            font_size=10,
            x=20,
            y=height - 90,
            color=(200, 200, 200, 255),
            batch=self.hud_batch,
        )

        self.help_label = pyglet.text.Label(
            "Presets: [1] Circle [2] Ellipse [3] Rosette [4] Flyby [5] Capture  |  [f/s] Speed  [+/-] Mass  "
            "[a/d] Angle  [[/]] Radius  [c] Clear  [r] Reset  [space] Pause  [q] Quit",
            font_name="Monospace",
            font_size=8,
            x=20,
            y=16,
            color=(140, 140, 140, 255),
            batch=self.hud_batch,
        )

        # Register event handlers
        self.window.push_handlers(
            on_draw=self.on_draw,
            on_key_press=self.on_key_press,
            on_text=self.on_text,
        )

        pyglet.clock.schedule_interval(self.update, 1.0 / 60.0)

    def load_preset(self, preset_id: int) -> None:
        self.preset_id = preset_id
        if preset_id == 1:
            self.preset_name = "Circular Orbit"
            self.knot = create_circular_orbit(self.field, radius=210.0)
        elif preset_id == 2:
            self.preset_name = "Eccentric Ellipse"
            self.knot = create_elliptic_orbit(self.field, periapsis=120.0, eccentricity=0.62)
        elif preset_id == 3:
            self.preset_name = "Precessing Rosette (Wave Delay Perihelion Advance)"
            self.knot = create_rosette_orbit(self.field, periapsis=85.0)
        elif preset_id == 4:
            self.preset_name = "Hyperbolic Flyby (Gravitational Scattering)"
            self.knot = create_scattering_orbit(self.field, impact_param=170.0, v_inf=250.0)
        elif preset_id == 5:
            self.preset_name = "Inspiral Core Capture"
            self.knot = MatterKnot(
                x=self.field.cx,
                y=self.field.cy - 180.0,
                vx=110.0,
                vy=0.0,
                radius=12.0,
            )

    def on_text(self, text: str) -> None:
        """Handle pure ASCII keyboard commands."""
        # Orbital presets
        if text in ("1", "2", "3", "4", "5"):
            self.load_preset(int(text))

        # Velocity magnitude adjustments (Faster / Slower)
        elif text in ("f", "F"):
            # Boost velocity vector by +6%
            self.knot.vx *= 1.06
            self.knot.vy *= 1.06
        elif text in ("s", "S"):
            # Reduce velocity vector by -6%
            self.knot.vx *= 0.94
            self.knot.vy *= 0.94

        # Central mass adjustments (+ / -)
        elif text in ("+", "="):
            self.field.mass = min(self.field.mass + 2500.0, 80000.0)
        elif text in ("-", "_"):
            self.field.mass = max(self.field.mass - 2500.0, 2500.0)

        # Steering velocity vector angle (a / d)
        elif text in ("a", "A"):
            # Rotate velocity vector counterclockwise by 3 degrees
            rad = math.radians(3.0)
            cos_t, sin_t = math.cos(rad), math.sin(rad)
            vx_new = self.knot.vx * cos_t - self.knot.vy * sin_t
            vy_new = self.knot.vx * sin_t + self.knot.vy * cos_t
            self.knot.vx, self.knot.vy = vx_new, vy_new
        elif text in ("d", "D"):
            # Rotate velocity vector clockwise by 3 degrees
            rad = math.radians(-3.0)
            cos_t, sin_t = math.cos(rad), math.sin(rad)
            vx_new = self.knot.vx * cos_t - self.knot.vy * sin_t
            vy_new = self.knot.vx * sin_t + self.knot.vy * cos_t
            self.knot.vx, self.knot.vy = vx_new, vy_new

        # Radial displacement ([ / ])
        elif text == "[":
            dx = self.knot.x - self.field.cx
            dy = self.knot.y - self.field.cy
            r = math.hypot(dx, dy)
            if r > self.field.core_radius + 20.0:
                self.knot.x -= (dx / r) * 15.0
                self.knot.y -= (dy / r) * 15.0
        elif text == "]":
            dx = self.knot.x - self.field.cx
            dy = self.knot.y - self.field.cy
            r = math.hypot(dx, dy)
            if r < min(self.width, self.height) * 0.48:
                self.knot.x += (dx / r) * 15.0
                self.knot.y += (dy / r) * 15.0

        # Utilities
        elif text in ("c", "C"):
            self.knot.path.clear()
        elif text in ("g", "G"):
            self.show_grid = not self.show_grid
        elif text in ("r", "R"):
            self.load_preset(self.preset_id)
        elif text in ("q", "Q"):
            self.window.close()
        elif text == " ":
            self.paused = not self.paused

    def on_key_press(self, symbol: int, modifiers: int) -> None:
        """Handle non-printable or symbol keys (strictly ASCII keys, NO arrow keys)."""
        if symbol == key.ESCAPE or symbol == key.Q:
            self.window.close()
        elif symbol == key.SPACE:
            self.paused = not self.paused
        elif symbol in (key._1, key._2, key._3, key._4, key._5):
            idx = symbol - key._1 + 1
            self.load_preset(idx)
        elif symbol in (key.PLUS, key.EQUAL):
            self.field.mass = min(self.field.mass + 2500.0, 80000.0)
        elif symbol in (key.MINUS, key.UNDERSCORE):
            self.field.mass = max(self.field.mass - 2500.0, 2500.0)
        elif symbol == key.BRACKETLEFT:
            self.on_text("[")
        elif symbol == key.BRACKETRIGHT:
            self.on_text("]")
        elif symbol == key.G:
            self.show_grid = not self.show_grid
        elif symbol == key.C:
            self.knot.path.clear()
        elif symbol == key.R:
            self.load_preset(self.preset_id)

    def update(self, dt: float) -> None:
        if self.paused:
            return

        dt = min(dt, 0.035) * self.sim_speed

        # Sub-step physics for high orbital integration precision
        substeps = 4
        sub_dt = dt / substeps
        for _ in range(substeps):
            self.knot.update(self.field, sub_dt)

        # Update HUD text
        r = self.knot.distance(self.field)
        v = self.knot.speed()
        energy = self.knot.specific_energy(self.field)
        ang_mom = self.knot.angular_momentum(self.field)
        orbit_type = self.knot.orbit_type(self.field)

        self.metrics_label.text = (
            f"Orbit: {self.preset_name}  |  State: {orbit_type.upper()}  |  "
            f"Distance r: {r:.1f}  |  Speed v: {v:.1f}"
        )

        v_wave = self.field.wave_speed(self.knot.x, self.knot.y)
        self.params_label.text = (
            f"Central Mass Energy M: {self.field.mass:.0f}  |  Specific Energy E: {energy:.0f}  |  "
            f"Angular Momentum L: {ang_mom:.0f}  |  Local Wave Speed: {v_wave:.1f} / {self.field.c:.0f} c  |  "
            f"{'PAUSED' if self.paused else 'RUNNING'}"
        )

    def on_draw(self) -> None:
        self.window.clear()
        draw_items = []

        # 1. Discrete multiscale resolution grid G_N
        if self.show_grid:
            grid_step = 40
            for gx in range(0, self.width, grid_step):
                draw_items.append(
                    _make_line(
                        gx,
                        0,
                        gx,
                        self.height,
                        color=(25, 25, 25, 255),
                        batch=self.batch,
                        width=1,
                    )
                )
            for gy in range(0, self.height, grid_step):
                draw_items.append(
                    _make_line(
                        0,
                        gy,
                        self.width,
                        gy,
                        color=(25, 25, 25, 255),
                        batch=self.batch,
                        width=1,
                    )
                )

        # 2. Refractive gradient equipotential rings around central mass knot
        for r_ring in [75, 130, 200, 280, 370, 470]:
            draw_items.append(
                shapes.Circle(
                    self.field.cx,
                    self.field.cy,
                    r_ring,
                    color=(30, 42, 58, 35),
                    batch=self.batch,
                )
            )

        # Central mass knot core
        draw_items.append(
            shapes.Circle(
                self.field.cx,
                self.field.cy,
                self.field.core_radius,
                color=(225, 155, 45, 255),
                batch=self.batch,
            )
        )
        draw_items.append(
            shapes.Circle(
                self.field.cx,
                self.field.cy,
                self.field.core_radius * 0.45,
                color=(255, 240, 190, 255),
                batch=self.batch,
            )
        )

        # 3. Draw orbit trajectory trail
        path = self.knot.path
        p_len = len(path)
        if p_len > 1:
            for i in range(p_len - 1):
                fade = (i + 1) / p_len
                alpha = int(40 + 200 * fade)
                # Color trajectory with subtle energy glow (cyan/amber)
                draw_items.append(
                    _make_line(
                        path[i][0],
                        path[i][1],
                        path[i + 1][0],
                        path[i + 1][1],
                        color=(80, 180, 250, alpha),
                        batch=self.batch,
                        width=2 if fade > 0.8 else 1,
                    )
                )

        # 4. Draw matter knot vortex body
        mk = self.knot
        if not mk.captured:
            # Body circle
            draw_items.append(
                shapes.Circle(
                    mk.x,
                    mk.y,
                    mk.radius,
                    color=(60, 160, 240, 220),
                    batch=self.batch,
                )
            )
            # Internal core
            draw_items.append(
                shapes.Circle(
                    mk.x,
                    mk.y,
                    mk.radius * 0.4,
                    color=(220, 240, 255, 255),
                    batch=self.batch,
                )
            )

            # Internal wave circulation phase indicator
            px = mk.x + mk.radius * 0.85 * math.cos(mk.phase)
            py = mk.y + mk.radius * 0.85 * math.sin(mk.phase)
            draw_items.append(
                _make_line(
                    mk.x,
                    mk.y,
                    px,
                    py,
                    color=(255, 255, 255, 255),
                    batch=self.batch,
                    width=2,
                )
            )

            # Velocity vector arrow (green/teal indicator)
            v_mag = mk.speed()
            if v_mag > 1.0:
                scale = min(35.0, v_mag * 0.12)
                vx_dir = (mk.vx / v_mag) * scale
                vy_dir = (mk.vy / v_mag) * scale
                draw_items.append(
                    _make_line(
                        mk.x,
                        mk.y,
                        mk.x + vx_dir,
                        mk.y + vy_dir,
                        color=(100, 255, 180, 200),
                        batch=self.batch,
                        width=2,
                    )
                )
        else:
            # Captured alert glow
            draw_items.append(
                shapes.Circle(
                    self.field.cx,
                    self.field.cy,
                    self.field.core_radius + 8.0,
                    color=(255, 80, 60, 160),
                    batch=self.batch,
                )
            )

        # Draw batch primitives and HUD
        self.batch.draw()
        self.hud_batch.draw()


def run_app() -> None:
    """Launch the interactive pyglet orbital simulator."""
    if pyglet is None:
        print("Error: pyglet is required to run the graphical window.")
        print("Install it using: pip install pyglet")
        sys.exit(1)

    app = OrbitSimulatorWindow()
    pyglet.app.run()
