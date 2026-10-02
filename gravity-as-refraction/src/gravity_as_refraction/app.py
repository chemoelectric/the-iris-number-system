"""Interactive 2D Pyglet simulation of matter knots drawing spirographs in a refractive field."""

from __future__ import annotations

import math
import os
import sys

try:
    import pyglet
    from pyglet import shapes
    from pyglet.window import key
except ImportError:
    pyglet = None  # type: ignore

try:
    from .physics import MatterKnot, RefractionField
except ImportError:
    from physics import MatterKnot, RefractionField


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


class WaveGravityWindow:
    """Clean, uncluttered spirograph orbital simulation window."""

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
            caption="gravity-as-refraction • Wave Refraction Spirograph Simulator",
            resizable=False,
        )

        # Refractive field around central mass knot
        self.field = RefractionField(
            cx=width * 0.5,
            cy=height * 0.5,
            mass=16000.0,
            c=300.0,
            core_radius=22.0,
        )

        # Launch parameters for matter knot
        self.launch_x = 80.0
        self.launch_y = height * 0.74
        self.launch_vx = 195.0

        # Matter knot with softened core (never crashes into core)
        self.knot = MatterKnot(
            x=self.launch_x,
            y=self.launch_y,
            vx=self.launch_vx,
            vy=0.0,
            radius=12.0,
            max_path_points=4000,
        )

        self.paused = False
        self.show_grid = False

        # Batches for rendering
        self.batch = pyglet.graphics.Batch()
        self.hud_batch = pyglet.graphics.Batch()

        # Load transparent PNG of the wave refraction equation
        self.equation_sprite = None
        eq_path = os.path.join(os.path.dirname(__file__), "equation.png")
        if os.path.exists(eq_path):
            try:
                eq_image = pyglet.image.load(eq_path)
                self.equation_sprite = pyglet.sprite.Sprite(
                    eq_image,
                    x=26,
                    y=height - eq_image.height - 22,
                    batch=self.hud_batch,
                )
            except Exception:
                self.equation_sprite = None

        # Minimalist fallback label if PNG is unavailable
        self.fallback_label = None
        if self.equation_sprite is None:
            self.fallback_label = pyglet.text.Label(
                "G = (c²·Δω² / 4πm) · (15/π⁴) ∫₀^∞ [u³/(eᵘ - 1)] du = c²·Δω² / (4πm)",
                font_name="Monospace",
                font_size=10,
                x=26,
                y=height - 30,
                color=(226, 232, 240, 240),
                batch=self.hud_batch,
            )

        # Single discreet line of controls at the bottom
        self.controls_label = pyglet.text.Label(
            "[f/s] Speed   [+/-] Mass   [[/]] Launch Y   [c] Clear   [r] Relaunch   [space] Pause   [q] Quit",
            font_name="Monospace",
            font_size=9,
            x=26,
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

    def relaunch(self) -> None:
        """Relaunch the matter knot from the launch line."""
        self.knot.x = self.launch_x
        self.knot.y = self.launch_y
        self.knot.vx = self.launch_vx
        self.knot.vy = 0.0

    def on_text(self, text: str) -> None:
        """Handle pure ASCII keyboard commands."""
        # Speed adjustments: smoothly scale current velocity
        if text in ("f", "F"):
            self.knot.vx *= 1.05
            self.knot.vy *= 1.05
            self.launch_vx *= 1.05
        elif text in ("s", "S"):
            self.knot.vx *= 0.95
            self.knot.vy *= 0.95
            self.launch_vx *= 0.95

        # Central mass strength
        elif text in ("+", "="):
            self.field.mass = min(self.field.mass + 2000.0, 70000.0)
        elif text in ("-", "_"):
            self.field.mass = max(self.field.mass - 2000.0, 2000.0)

        # Launch position height (impact parameter)
        elif text == "[":
            self.launch_y = max(self.launch_y - 20.0, 60.0)
        elif text == "]":
            self.launch_y = min(self.launch_y + 20.0, self.height - 60.0)

        # Clear spirograph trail
        elif text in ("c", "C"):
            self.knot.path.clear()

        # Toggle grid
        elif text in ("g", "G"):
            self.show_grid = not self.show_grid

        # Relaunch from start
        elif text in ("r", "R"):
            self.relaunch()

        # Quit
        elif text in ("q", "Q"):
            self.window.close()

        # Pause / Resume
        elif text == " ":
            self.paused = not self.paused

    def on_key_press(self, symbol: int, modifiers: int) -> None:
        """Handle non-printable or symbol keys (strictly ASCII keys, NO arrow keys)."""
        if symbol == key.ESCAPE or symbol == key.Q:
            self.window.close()
        elif symbol == key.SPACE:
            self.paused = not self.paused
        elif symbol in (key.PLUS, key.EQUAL):
            self.field.mass = min(self.field.mass + 2000.0, 70000.0)
        elif symbol in (key.MINUS, key.UNDERSCORE):
            self.field.mass = max(self.field.mass - 2000.0, 2000.0)
        elif symbol == key.BRACKETLEFT:
            self.on_text("[")
        elif symbol == key.BRACKETRIGHT:
            self.on_text("]")
        elif symbol == key.C:
            self.knot.path.clear()
        elif symbol == key.R:
            self.relaunch()
        elif symbol == key.G:
            self.show_grid = not self.show_grid

    def update(self, dt: float) -> None:
        if self.paused:
            return

        dt = min(dt, 0.035)

        # High-precision sub-stepping for smooth, beautiful spirograph curves
        substeps = 4
        sub_dt = dt / substeps
        for _ in range(substeps):
            self.knot.update(self.field, sub_dt)

        # If it escapes completely past the screen boundary, wrap it back to launch
        if (
            self.knot.x > self.width + 120
            or self.knot.x < -120
            or self.knot.y > self.height + 120
            or self.knot.y < -120
        ):
            self.relaunch()

    def on_draw(self) -> None:
        self.window.clear()
        draw_items = []

        # 1. Discrete multiscale resolution grid G_N (optional)
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

        # 2. Subtle field gradient rings around central mass knot
        for r_ring in [80, 140, 220, 310, 420]:
            draw_items.append(
                shapes.Circle(
                    self.field.cx,
                    self.field.cy,
                    r_ring,
                    color=(28, 38, 52, 35),
                    batch=self.batch,
                )
            )

        # Central mass knot core
        draw_items.append(
            shapes.Circle(
                self.field.cx,
                self.field.cy,
                self.field.core_radius,
                color=(230, 160, 50, 255),
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

        # 3. Draw continuous spirograph trajectory history
        path = self.knot.path
        p_len = len(path)
        if p_len > 1:
            for i in range(p_len - 1):
                fade = (i + 1) / p_len
                alpha = int(35 + 210 * fade)
                # Cyan / teal spirograph path with luminous fade
                draw_items.append(
                    _make_line(
                        path[i][0],
                        path[i][1],
                        path[i + 1][0],
                        path[i + 1][1],
                        color=(90, 190, 255, alpha),
                        batch=self.batch,
                        width=2 if fade > 0.85 else 1,
                    )
                )

        # 4. Draw orbiting matter knot
        mk = self.knot
        # Body
        draw_items.append(
            shapes.Circle(
                mk.x,
                mk.y,
                mk.radius,
                color=(60, 160, 245, 220),
                batch=self.batch,
            )
        )
        # Inner core
        draw_items.append(
            shapes.Circle(
                mk.x,
                mk.y,
                mk.radius * 0.4,
                color=(230, 245, 255, 255),
                batch=self.batch,
            )
        )

        # Internal wave circulation indicator
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

        # Draw batches
        self.batch.draw()
        self.hud_batch.draw()


def run_app() -> None:
    """Launch the interactive spirograph simulation."""
    if pyglet is None:
        print("Error: pyglet is required to run the graphical window.")
        print("Install it using: pip install pyglet")
        sys.exit(1)

    app = WaveGravityWindow()
    pyglet.app.run()
