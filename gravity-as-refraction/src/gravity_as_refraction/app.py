"""Interactive 2D Pyglet visualization of gravitation as wave refraction."""

from __future__ import annotations

import math
import sys
from typing import List, Optional

try:
    import pyglet
    from pyglet import shapes
    from pyglet.window import key
except ImportError:
    pyglet = None  # type: ignore

try:
    from .physics import MatterKnot, RayBeam, RefractionField, WaveFront
except ImportError:
    from physics import MatterKnot, RayBeam, RefractionField, WaveFront


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
            caption="gravity-as-refraction • Wave Optics Gravitational Simulator",
            resizable=False,
        )

        # Physics simulation state
        self.field = RefractionField(
            cx=width * 0.5, cy=height * 0.5, mass=12000.0, c=200.0, core_radius=30.0
        )
        self.mode = 1  # 1: Wavefronts, 2: Matter Knot, 3: Ray Lensing
        self.paused = False
        self.show_grid = False

        # Mode 1: Multiple successive wave fronts
        self.wavefronts: List[WaveFront] = []
        self.wave_spawn_timer = 0.0
        self.wave_interval = 0.65

        # Mode 2: Orbiting / deflected matter knot
        self.matter_knot = MatterKnot(
            x=80.0, y=height * 0.78, vx=170.0, vy=0.0, radius=12.0
        )

        # Mode 3: Parallel rays for gravitational lensing
        self.ray_beam = RayBeam(
            start_x=50.0,
            y_min=height * 0.15,
            y_max=height * 0.85,
            count=19,
            speed=200.0,
        )

        # Batches for efficient rendering
        self.batch = pyglet.graphics.Batch()
        self.hud_batch = pyglet.graphics.Batch()

        # Set up HUD text labels
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
            "[1] Wavefronts  [2] Matter Knot  [3] Ray Lensing  |  [↑/↓] Mass  [Space] Pause  [G] Grid  [R] Reset",
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
        )

        self.reset_mode(self.mode)
        pyglet.clock.schedule_interval(self.update, 1.0 / 60.0)

    def reset_mode(self, mode: int) -> None:
        self.mode = mode
        if mode == 1:
            self.wavefronts = []
            for start_x in [100.0, 220.0, 340.0]:
                self.wavefronts.append(
                    WaveFront(start_x=start_x, y_min=20.0, y_max=self.height - 20.0, num_points=90)
                )
            self.wave_spawn_timer = 0.0
        elif mode == 2:
            self.matter_knot = MatterKnot(
                x=80.0, y=self.height * 0.78, vx=170.0, vy=0.0, radius=12.0
            )
        elif mode == 3:
            self.ray_beam = RayBeam(
                start_x=50.0,
                y_min=self.height * 0.15,
                y_max=self.height * 0.85,
                count=19,
                speed=200.0,
            )

    def on_key_press(self, symbol: int, modifiers: int) -> None:
        if symbol == key.ESCAPE or symbol == key.Q:
            self.window.close()
        elif symbol == key.SPACE:
            self.paused = not self.paused
        elif symbol == key._1:
            self.reset_mode(1)
        elif symbol == key._2:
            self.reset_mode(2)
        elif symbol == key._3:
            self.reset_mode(3)
        elif symbol == key.G:
            self.show_grid = not self.show_grid
        elif symbol == key.R:
            self.reset_mode(self.mode)
        elif symbol == key.UP:
            self.field.mass = min(self.field.mass + 2000.0, 30000.0)
        elif symbol == key.DOWN:
            self.field.mass = max(self.field.mass - 2000.0, 2000.0)
        elif symbol == key.RIGHT:
            if self.mode == 2:
                self.matter_knot.y = min(self.matter_knot.y + 20.0, self.height - 40.0)
                self.matter_knot.path.clear()
        elif symbol == key.LEFT:
            if self.mode == 2:
                self.matter_knot.y = max(self.matter_knot.y - 20.0, 40.0)
                self.matter_knot.path.clear()

    def update(self, dt: float) -> None:
        if self.paused:
            return

        dt = min(dt, 0.05)

        if self.mode == 1:
            # Advance existing wave fronts
            for wf in self.wavefronts:
                wf.update(self.field, dt)

            # Spawn new wave fronts periodically
            self.wave_spawn_timer += dt
            if self.wave_spawn_timer >= self.wave_interval:
                self.wave_spawn_timer = 0.0
                self.wavefronts.append(
                    WaveFront(start_x=30.0, y_min=20.0, y_max=self.height - 20.0, num_points=90)
                )

            # Remove wave fronts that have left the right boundary
            self.wavefronts = [
                wf for wf in self.wavefronts if any(pt.x < self.width + 50.0 for pt in wf.points)
            ]

        elif self.mode == 2:
            self.matter_knot.update(self.field, dt)
            # Loop if matter knot exits window bounds
            if (
                self.matter_knot.x > self.width + 60
                or self.matter_knot.x < -60
                or self.matter_knot.y > self.height + 60
                or self.matter_knot.y < -60
            ):
                self.matter_knot.x = 80.0
                self.matter_knot.y = self.height * 0.78
                self.matter_knot.vx = 170.0
                self.matter_knot.vy = 0.0
                self.matter_knot.path.clear()

        elif self.mode == 3:
            self.ray_beam.update(self.field, dt)
            if not any(ray.active for ray in self.ray_beam.rays):
                self.reset_mode(3)

        # Update HUD status text
        mode_names = {
            1: "Mode: Huygens Wave Front Refraction",
            2: "Mode: Circulating Matter Knot Orbit",
            3: "Mode: Ray Lensing & Snell Caustics",
        }
        v_edge = self.field.wave_speed(self.field.cx + self.field.core_radius, self.field.cy)
        self.status_label.text = (
            f"{mode_names[self.mode]} | Mass Knot Energy: {self.field.mass:.0f} | "
            f"Wave Speed: {v_edge:.1f} / {self.field.c:.1f} c | "
            f"State: {'PAUSED' if self.paused else 'RUNNING'}"
        )

    def on_draw(self) -> None:
        self.window.clear()

        # Temporary drawing objects list to keep references alive during render
        draw_items = []

        # 1. Discrete multiscale resolution grid G_N
        if self.show_grid:
            grid_step = 40
            for gx in range(0, self.width, grid_step):
                draw_items.append(
                    _make_line(
                        gx, 0, gx, self.height, color=(25, 25, 25, 255), batch=self.batch, width=1
                    )
                )
            for gy in range(0, self.height, grid_step):
                draw_items.append(
                    _make_line(
                        0, gy, self.width, gy, color=(25, 25, 25, 255), batch=self.batch, width=1
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

        # 3. Render active mode
        if self.mode == 1:
            # Draw wave fronts
            for wf in self.wavefronts:
                pts = wf.points
                for i in range(len(pts) - 1):
                    # Color wave front based on local wave speed (slower = more amber/red)
                    v_local = self.field.wave_speed(pts[i].x, pts[i].y)
                    ratio = min(max(v_local / self.field.c, 0.0), 1.0)
                    r_col = int(255 - 100 * ratio)
                    g_col = int(180 * ratio + 40)
                    b_col = int(240 * ratio)
                    draw_items.append(
                        _make_line(
                            pts[i].x,
                            pts[i].y,
                            pts[i + 1].x,
                            pts[i + 1].y,
                            color=(r_col, g_col, b_col, 220),
                            batch=self.batch,
                            width=2,
                        )
                    )

        elif self.mode == 2:
            # Draw matter knot trajectory history
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

            # Draw matter knot vortex body
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

        elif self.mode == 3:
            # Draw rays and ray paths
            for ray in self.ray_beam.rays:
                path = ray.path
                for i in range(len(path) - 1):
                    draw_items.append(
                        _make_line(
                            path[i][0],
                            path[i][1],
                            path[i + 1][0],
                            path[i + 1][1],
                            color=(120, 210, 180, 180),
                            batch=self.batch,
                            width=1,
                        )
                    )
                if ray.active:
                    draw_items.append(
                        shapes.Circle(
                            ray.x,
                            ray.y,
                            2.5,
                            color=(200, 255, 230, 255),
                            batch=self.batch,
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
