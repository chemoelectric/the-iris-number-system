"""Interactive 2D Pyglet simulation of matter knots in the refractive gravitational field."""

from __future__ import annotations

import math
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
    """Main visualization window powered by pyglet."""

    def __init__(self, width: int = 960, height: int = 640) -> None:
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
            caption="gravity-as-refraction • Wave Refraction Gravitational Simulator",
            resizable=False,
        )

        # Physics simulation state
        self.field = RefractionField(
            cx=width * 0.5,
            cy=height * 0.5,
            mass=22000.0,
            c=460.0,
            core_radius=32.0,
        )

        self.paused = False
        self.show_grid = False

        # Matter knot launched from the left
        self.matter_knot = MatterKnot(
            x=60.0, y=self.height * 0.76, vx=340.0, vy=0.0, radius=14.0
        )

        # Batches for rendering
        self.batch = pyglet.graphics.Batch()
        self.hud_batch = pyglet.graphics.Batch()

        # HUD labels
        self.title_label = pyglet.text.Label(
            "GRAVITATION AS WAVE REFRACTION",
            font_name="Sans-Serif",
            font_size=12,
            x=20,
            y=height - 25,
            color=(240, 240, 240, 255),
            batch=self.hud_batch,
        )

        self.status_label = pyglet.text.Label(
            "",
            font_name="Monospace",
            font_size=10,
            x=20,
            y=height - 50,
            color=(180, 180, 180, 255),
            batch=self.hud_batch,
        )

        self.help_label = pyglet.text.Label(
            "[+/-] Mass  [f/s] Speed  [[/]] Launch Y  [g] Grid  [space] Pause  [r] Reset  [q] Quit",
            font_name="Monospace",
            font_size=9,
            x=20,
            y=18,
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

    def on_text(self, text: str) -> None:
        """Handle pure ASCII character commands."""
        if text in ("+", "="):
            self.field.mass = min(self.field.mass + 3000.0, 60000.0)
        elif text in ("-", "_"):
            self.field.mass = max(self.field.mass - 3000.0, 3000.0)
        elif text == "[":
            self.matter_knot.y = max(self.matter_knot.y - 25.0, 50.0)
            self.matter_knot.path.clear()
        elif text == "]":
            self.matter_knot.y = min(self.matter_knot.y + 25.0, self.height - 50.0)
            self.matter_knot.path.clear()
        elif text in ("f", "F"):
            self.field.c = min(self.field.c + 50.0, 900.0)
        elif text in ("s", "S"):
            self.field.c = max(self.field.c - 50.0, 100.0)
        elif text in ("g", "G"):
            self.show_grid = not self.show_grid
        elif text in ("q", "Q"):
            self.window.close()
        elif text in ("r", "R"):
            self.matter_knot.x = 60.0
            self.matter_knot.y = self.height * 0.76
            self.matter_knot.vx = 340.0
            self.matter_knot.vy = 0.0
            self.matter_knot.path.clear()
        elif text == " ":
            self.paused = not self.paused

    def on_key_press(self, symbol: int, modifiers: int) -> None:
        """Handle non-printable or symbol keys (strictly ASCII keys, NO arrow keys)."""
        if symbol == key.ESCAPE or symbol == key.Q:
            self.window.close()
        elif symbol == key.SPACE:
            self.paused = not self.paused
        elif symbol in (key.PLUS, key.EQUAL):
            self.field.mass = min(self.field.mass + 3000.0, 60000.0)
        elif symbol in (key.MINUS, key.UNDERSCORE):
            self.field.mass = max(self.field.mass - 3000.0, 3000.0)
        elif symbol == key.BRACKETLEFT:
            self.matter_knot.y = max(self.matter_knot.y - 25.0, 50.0)
            self.matter_knot.path.clear()
        elif symbol == key.BRACKETRIGHT:
            self.matter_knot.y = min(self.matter_knot.y + 25.0, self.height - 50.0)
            self.matter_knot.path.clear()
        elif symbol == key.G:
            self.show_grid = not self.show_grid
        elif symbol == key.R:
            self.matter_knot.x = 60.0
            self.matter_knot.y = self.height * 0.76
            self.matter_knot.vx = 340.0
            self.matter_knot.vy = 0.0
            self.matter_knot.path.clear()

    def update(self, dt: float) -> None:
        if self.paused:
            return

        dt = min(dt, 0.035)

        self.matter_knot.update(self.field, dt)

        # Loop if matter knot exits window bounds
        if (
            self.matter_knot.x > self.width + 80
            or self.matter_knot.x < -80
            or self.matter_knot.y > self.height + 80
            or self.matter_knot.y < -80
        ):
            self.matter_knot.x = 60.0
            self.matter_knot.y = self.height * 0.76
            self.matter_knot.vx = 340.0
            self.matter_knot.vy = 0.0
            self.matter_knot.path.clear()

        # Update HUD status text
        v_edge = self.field.wave_speed(
            self.field.cx + self.field.core_radius, self.field.cy
        )
        self.status_label.text = (
            f"Mass Knot Energy: {self.field.mass:.0f} | "
            f"Speed Parameter c: {self.field.c:.0f} | "
            f"Wave Speed: {v_edge:.1f} | "
            f"State: {'PAUSED' if self.paused else 'RUNNING'}"
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

        # 2. Refraction field gradient rings around central mass knot
        for r_ring in [60, 110, 170, 240, 320]:
            draw_items.append(
                shapes.Circle(
                    self.field.cx,
                    self.field.cy,
                    r_ring,
                    color=(35, 45, 60, 40),
                    batch=self.batch,
                )
            )

        # Central mass knot core
        draw_items.append(
            shapes.Circle(
                self.field.cx,
                self.field.cy,
                self.field.core_radius,
                color=(220, 160, 60, 255),
                batch=self.batch,
            )
        )
        draw_items.append(
            shapes.Circle(
                self.field.cx,
                self.field.cy,
                self.field.core_radius * 0.5,
                color=(255, 235, 180, 255),
                batch=self.batch,
            )
        )

        # 3. Draw matter knot trajectory history
        path = self.matter_knot.path
        for i in range(len(path) - 1):
            draw_items.append(
                _make_line(
                    path[i][0],
                    path[i][1],
                    path[i + 1][0],
                    path[i + 1][1],
                    color=(100, 180, 240, 160),
                    batch=self.batch,
                    width=1,
                )
            )

        # 4. Draw matter knot vortex body
        mk = self.matter_knot
        draw_items.append(
            shapes.Circle(
                mk.x,
                mk.y,
                mk.radius,
                color=(70, 150, 230, 200),
                batch=self.batch,
            )
        )

        # Internal wave circulation indicator
        px = mk.x + mk.radius * 0.8 * math.cos(mk.phase)
        py = mk.y + mk.radius * 0.8 * math.sin(mk.phase)
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

        # Draw batch primitives and HUD
        self.batch.draw()
        self.hud_batch.draw()


def run_app() -> None:
    """Launch the interactive pyglet visualization."""
    if pyglet is None:
        print("Error: pyglet is required to run the graphical window.")
        print("Install it using: pip install pyglet")
        sys.exit(1)

    app = WaveGravityWindow()
    pyglet.app.run()
