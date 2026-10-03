"""Interactive Pyglet application for galaxy collision refraction simulation."""

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
    shapes = None  # type: ignore

try:
    from .physics import GalaxyCollisionSimulation
    from .widgets import ButtonWidget, SliderWidget
except ImportError:
    from physics import GalaxyCollisionSimulation
    from widgets import ButtonWidget, SliderWidget


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


class GalaxyCollisionApp:
    """Manages the simulation and unified window (Simulation Viewport + Controls Sidebar)."""

    def __init__(self) -> None:
        if pyglet is None:
            raise RuntimeError(
                "pyglet is required to run the graphical interface. "
                "Install it with: pip install pyglet"
            )

        self.sim_width = 1020
        self.sim_height = 800

        self.ctrl_width = 380
        self.ctrl_height = 800

        # Total window dimensions (Unified Viewport + Sidebar)
        self.window_width = self.sim_width + self.ctrl_width
        self.window_height = self.sim_height
        self.sidebar_x = self.sim_width

        # Create unified window
        self.window = pyglet.window.Window(
            width=self.window_width,
            height=self.window_height,
            caption="Galaxy Collision • Wave Refraction Simulation",
            resizable=False,
        )

        # Simulation engine
        self.sim = GalaxyCollisionSimulation(
            center_x=self.sim_width * 0.5,
            center_y=self.sim_height * 0.5,
            m1=1.0,
            m2=0.7,
            separation=520.0,
            impact_param=120.0,
            rel_velocity=46.0,
            tilt1_deg=15.0,
            tilt2_deg=-45.0,
            softening=34.0,
            num_stars_per_galaxy=750,
            trail_length=28,
        )

        self.show_contours = True
        self.show_trails = True

        # Persistent HUD and Controls batches in single OpenGL context
        self.hud_batch = pyglet.graphics.Batch()
        self.ctrl_batch = pyglet.graphics.Batch()

        # Simulation HUD labels (Viewport on left)
        self.title_label = pyglet.text.Label(
            "WAVE-REFRACTIVE GALAXY INTERACTION",
            font_name="Sans-Serif",
            font_size=11,
            x=20,
            y=self.sim_height - 25,
            color=(230, 240, 255, 255),
            batch=self.hud_batch,
        )

        self.status_label = pyglet.text.Label(
            "",
            font_name="Monospace",
            font_size=9,
            x=20,
            y=self.sim_height - 48,
            color=(170, 190, 215, 255),
            batch=self.hud_batch,
        )

        self.help_label = pyglet.text.Label(
            "[Space] Pause/Play  [r] Reset  [c] Toggle Contours  [t] Toggle Trails  [q] Quit",
            font_name="Monospace",
            font_size=8,
            x=20,
            y=16,
            color=(130, 140, 155, 255),
            batch=self.hud_batch,
        )

        # Initialize controls in sidebar
        self.sliders: List[SliderWidget] = []
        self.buttons: List[ButtonWidget] = []
        self._init_controls_ui()

        # Register event handlers for unified window
        self.window.push_handlers(
            on_draw=self.on_draw,
            on_key_press=self.on_key_press,
            on_mouse_press=self.on_mouse_press,
            on_mouse_drag=self.on_mouse_drag,
            on_mouse_release=self.on_mouse_release,
            on_close=self.on_app_close,
        )

        pyglet.clock.schedule_interval(self.update, 1.0 / 60.0)

    def _init_controls_ui(self) -> None:
        """Construct the slider controls and preset buttons in the sidebar."""
        pad_x = 24.0
        width = self.ctrl_width - pad_x * 2.0
        start_x = self.sidebar_x + pad_x
        cur_y = self.ctrl_height - 40.0

        # Header labels
        self.ctrl_title = pyglet.text.Label(
            "REFRACTION SIMULATION CONTROLS",
            font_name="Sans-Serif",
            font_size=11,
            x=start_x,
            y=cur_y,
            color=(240, 245, 255, 255),
            batch=self.ctrl_batch,
        )
        cur_y -= 18.0

        self.ctrl_subtitle = pyglet.text.Label(
            "Energy Density Clouds & Tidal Refraction",
            font_name="Sans-Serif",
            font_size=8,
            x=start_x,
            y=cur_y,
            color=(140, 165, 195, 255),
            batch=self.ctrl_batch,
        )
        cur_y -= 42.0

        # Sliders configuration
        slider_configs = [
            ("Galaxy 1 Mass (M1)", 0.2, 2.5, self.sim.m1, "{:.2f}", "M₀", self._on_m1_change),
            ("Galaxy 2 Mass (M2)", 0.1, 2.5, self.sim.m2, "{:.2f}", "M₀", self._on_m2_change),
            ("Initial Separation", 200.0, 750.0, self.sim.separation, "{:.0f}", "px", self._on_sep_change),
            ("Impact Parameter", -250.0, 250.0, self.sim.impact_param, "{:.0f}", "px", self._on_impact_change),
            ("Initial Velocity", 10.0, 95.0, self.sim.rel_velocity, "{:.1f}", "km/s*", self._on_vel_change),
            ("Galaxy 1 Tilt Angle", -90.0, 90.0, self.sim.tilt1_deg, "{:.0f}", "°", self._on_tilt1_change),
            ("Galaxy 2 Tilt Angle", -90.0, 90.0, self.sim.tilt2_deg, "{:.0f}", "°", self._on_tilt2_change),
            ("Cloud Softening (ε)", 15.0, 70.0, self.sim.softening, "{:.0f}", "px", self._on_soft_change),
            ("Simulation Speed", 0.2, 2.5, self.sim.speed_multiplier, "{:.1f}", "x", self._on_speed_change),
            ("Trail Persistence", 0.0, 50.0, float(self.sim.trail_length), "{:.0f}", "pts", self._on_trail_change),
        ]

        slider_spacing = 42.0
        for label, min_v, max_v, init_v, fmt, unit, cb in slider_configs:
            s = SliderWidget(
                x=start_x,
                y=cur_y,
                width=width,
                height=18.0,
                label=label,
                min_val=min_v,
                max_val=max_v,
                initial_val=init_v,
                format_spec=fmt,
                unit=unit,
                on_change=cb,
                batch=self.ctrl_batch,
            )
            self.sliders.append(s)
            cur_y -= slider_spacing

        cur_y -= 10.0

        # Action Buttons
        btn_h = 28.0
        self.btn_reset = ButtonWidget(
            x=start_x,
            y=cur_y,
            width=width,
            height=btn_h,
            label="RESET & RELAUNCH SIMULATION",
            on_click=self.on_reset_clicked,
            bg_color=(35, 75, 125),
            accent_color=(55, 130, 220),
            batch=self.ctrl_batch,
        )
        self.buttons.append(self.btn_reset)
        cur_y -= (btn_h + 8.0)

        half_w = (width - 8.0) * 0.5
        self.btn_pause = ButtonWidget(
            x=start_x,
            y=cur_y,
            width=half_w,
            height=btn_h,
            label="PAUSE / PLAY",
            on_click=self.on_pause_clicked,
            bg_color=(45, 55, 70),
            accent_color=(75, 95, 125),
            batch=self.ctrl_batch,
        )
        self.buttons.append(self.btn_pause)

        self.btn_contours = ButtonWidget(
            x=start_x + half_w + 8.0,
            y=cur_y,
            width=half_w,
            height=btn_h,
            label="CONTOURS ON/OFF",
            on_click=self.on_contours_clicked,
            bg_color=(45, 55, 70),
            accent_color=(75, 95, 125),
            batch=self.ctrl_batch,
        )
        self.buttons.append(self.btn_contours)
        cur_y -= (btn_h + 16.0)

        # Preset Buttons Header
        self.preset_label = pyglet.text.Label(
            "INTERACTIVE ENCOUNTER PRESETS",
            font_name="Sans-Serif",
            font_size=9,
            x=start_x,
            y=cur_y,
            color=(180, 200, 225, 255),
            batch=self.ctrl_batch,
        )
        cur_y -= 26.0

        presets = [
            ("Antennae Prograde Flyby", self._preset_antennae),
            ("Direct Penetrating Merger", self._preset_merger),
            ("Retrograde Collision", self._preset_retrograde),
            ("Milky Way & Andromeda Infall", self._preset_milky_andromeda),
        ]

        preset_btn_h = 24.0
        for p_label, p_cb in presets:
            btn = ButtonWidget(
                x=start_x,
                y=cur_y,
                width=width,
                height=preset_btn_h,
                label=p_label,
                on_click=p_cb,
                bg_color=(30, 42, 58),
                accent_color=(45, 90, 145),
                batch=self.ctrl_batch,
            )
            self.buttons.append(btn)
            cur_y -= (preset_btn_h + 6.0)

    # Slider callback handlers
    def _on_m1_change(self, val: float) -> None:
        self.sim.m1 = val

    def _on_m2_change(self, val: float) -> None:
        self.sim.m2 = val

    def _on_sep_change(self, val: float) -> None:
        self.sim.separation = val

    def _on_impact_change(self, val: float) -> None:
        self.sim.impact_param = val

    def _on_vel_change(self, val: float) -> None:
        self.sim.rel_velocity = val

    def _on_tilt1_change(self, val: float) -> None:
        self.sim.tilt1_deg = val

    def _on_tilt2_change(self, val: float) -> None:
        self.sim.tilt2_deg = val

    def _on_soft_change(self, val: float) -> None:
        self.sim.softening = val
        if self.sim.g1 and self.sim.g2:
            self.sim.g1.softening = val
            self.sim.g2.softening = val * 0.9

    def _on_speed_change(self, val: float) -> None:
        self.sim.speed_multiplier = val

    def _on_trail_change(self, val: float) -> None:
        self.sim.trail_length = int(val)
        for s in self.sim.stars:
            s.trail = type(s.trail)(s.trail, maxlen=self.sim.trail_length)

    def on_reset_clicked(self) -> None:
        self.sim.reset()

    def on_pause_clicked(self) -> None:
        self.sim.paused = not self.sim.paused

    def on_contours_clicked(self) -> None:
        self.show_contours = not self.show_contours

    # Presets
    def _apply_preset(
        self,
        m1: float,
        m2: float,
        sep: float,
        imp: float,
        vel: float,
        t1: float,
        t2: float,
        soft: float,
    ) -> None:
        self.sliders[0].set_value(m1, trigger_callback=False)
        self.sliders[1].set_value(m2, trigger_callback=False)
        self.sliders[2].set_value(sep, trigger_callback=False)
        self.sliders[3].set_value(imp, trigger_callback=False)
        self.sliders[4].set_value(vel, trigger_callback=False)
        self.sliders[5].set_value(t1, trigger_callback=False)
        self.sliders[6].set_value(t2, trigger_callback=False)
        self.sliders[7].set_value(soft, trigger_callback=False)

        self.sim.m1 = m1
        self.sim.m2 = m2
        self.sim.separation = sep
        self.sim.impact_param = imp
        self.sim.rel_velocity = vel
        self.sim.tilt1_deg = t1
        self.sim.tilt2_deg = t2
        self.sim.softening = soft
        self.sim.reset()

    def _preset_antennae(self) -> None:
        # Classic tidal bridge and long curving antenna tails
        self._apply_preset(
            m1=1.0, m2=0.85, sep=540.0, imp=135.0, vel=44.0, t1=25.0, t2=-55.0, soft=32.0
        )

    def _preset_merger(self) -> None:
        # Penetrating head-on collision leading to rapid coalescent merger
        self._apply_preset(
            m1=1.2, m2=1.0, sep=480.0, imp=20.0, vel=35.0, t1=0.0, t2=0.0, soft=36.0
        )

    def _preset_retrograde(self) -> None:
        # Retrograde encounter: spins counter to orbital motion, suppressing tidal tails
        self._apply_preset(
            m1=1.0, m2=0.6, sep=520.0, imp=-140.0, vel=48.0, t1=-70.0, t2=110.0, soft=30.0
        )

    def _preset_milky_andromeda(self) -> None:
        # Milky Way & Andromeda analog
        self._apply_preset(
            m1=1.0, m2=1.3, sep=600.0, imp=75.0, vel=38.0, t1=35.0, t2=-25.0, soft=38.0
        )

    def on_key_press(self, symbol: int, modifiers: int) -> None:
        if symbol == key.ESCAPE or symbol == key.Q:
            self.on_app_close()
        elif symbol == key.SPACE:
            self.sim.paused = not self.sim.paused
        elif symbol == key.R:
            self.sim.reset()
        elif symbol == key.C:
            self.show_contours = not self.show_contours
        elif symbol == key.T:
            self.show_trails = not self.show_trails

    def on_mouse_press(self, x: float, y: float, button: int, modifiers: int) -> None:
        if x >= self.sidebar_x:
            for s in self.sliders:
                if s.on_mouse_press(x, y, button):
                    break
            for b in self.buttons:
                if b.on_mouse_press(x, y, button):
                    break

    def on_mouse_drag(self, x: float, y: float, dx: float, dy: float, buttons: int, modifiers: int) -> None:
        for s in self.sliders:
            if s.dragging:
                s.on_mouse_drag(x, y)

    def on_mouse_release(self, x: float, y: float, button: int, modifiers: int) -> None:
        for s in self.sliders:
            s.on_mouse_release()
        for b in self.buttons:
            b.on_mouse_release(x, y)

    def on_app_close(self) -> None:
        try:
            self.window.close()
        except Exception:
            pass
        pyglet.app.exit()

    def update(self, dt: float) -> None:
        dt = min(dt, 0.035)
        self.sim.step(dt)

        # Update HUD text
        dist = self.sim.distance_between_cores()
        v_rel = self.sim.relative_velocity()
        status_text = "PAUSED" if self.sim.paused else "RUNNING"
        self.status_label.text = (
            f"T = {self.sim.time_elapsed:.2f} s | Separation: {dist:.0f} px | "
            f"V_rel: {v_rel:.1f} | Stars: {len(self.sim.stars)} | State: {status_text}"
        )

    def on_draw(self) -> None:
        """Render the simulation viewport and sidebar controls."""
        self.window.clear()

        frame_batch = pyglet.graphics.Batch()
        draw_items = []

        g1 = self.sim.g1
        g2 = self.sim.g2

        # 1. Refraction equipotential contour rings
        if self.show_contours and g1 and g2:
            for r in [50, 95, 150, 220, 310, 420]:
                draw_items.append(
                    shapes.Circle(
                        g1.x, g1.y, r, color=(25, 45, 75, 24), batch=frame_batch
                    )
                )
                draw_items.append(
                    shapes.Circle(
                        g2.x, g2.y, r * (g2.mass / g1.mass) ** 0.5,
                        color=(65, 45, 25, 24),
                        batch=frame_batch,
                    )
                )

        # 2. Galaxy core trajectory trails
        if g1 and len(g1.trail) > 1:
            for i in range(len(g1.trail) - 1):
                p1 = g1.trail[i]
                p2 = g1.trail[i + 1]
                alpha = int(140 * ((i + 1) / len(g1.trail)))
                draw_items.append(
                    _make_line(p1[0], p1[1], p2[0], p2[1], (100, 190, 255, alpha), frame_batch, 2)
                )

        if g2 and len(g2.trail) > 1:
            for i in range(len(g2.trail) - 1):
                p1 = g2.trail[i]
                p2 = g2.trail[i + 1]
                alpha = int(140 * ((i + 1) / len(g2.trail)))
                draw_items.append(
                    _make_line(p1[0], p1[1], p2[0], p2[1], (255, 180, 90, alpha), frame_batch, 2)
                )

        # 3. Stars (Matter Knots) and their tidal stream trails
        for star in self.sim.stars:
            r_c, g_c, b_c = star.base_color

            # Star trail
            if self.show_trails and len(star.trail) > 1:
                t_len = len(star.trail)
                for ti in range(0, t_len - 1, 2):
                    tp1 = star.trail[ti]
                    tp2 = star.trail[min(ti + 2, t_len - 1)]
                    fade = (ti + 1) / t_len
                    alpha = int(85 * fade)
                    draw_items.append(
                        _make_line(
                            tp1[0], tp1[1], tp2[0], tp2[1],
                            (r_c, g_c, b_c, alpha),
                            frame_batch,
                            1,
                        )
                    )

            # Star point
            draw_items.append(
                shapes.Circle(
                    star.x,
                    star.y,
                    1.6,
                    color=(r_c, g_c, b_c, 240),
                    batch=frame_batch,
                )
            )

        # 4. Dense Galaxy Cores (Energy concentrations)
        if g1:
            draw_items.append(
                shapes.Circle(g1.x, g1.y, g1.softening * 0.75, color=(35, 75, 130, 75), batch=frame_batch)
            )
            draw_items.append(
                shapes.Circle(g1.x, g1.y, 8.0, color=(140, 215, 255, 230), batch=frame_batch)
            )
            draw_items.append(
                shapes.Circle(g1.x, g1.y, 4.0, color=(255, 255, 255, 255), batch=frame_batch)
            )

        if g2:
            draw_items.append(
                shapes.Circle(g2.x, g2.y, g2.softening * 0.75, color=(130, 85, 35, 75), batch=frame_batch)
            )
            draw_items.append(
                shapes.Circle(g2.x, g2.y, 7.5, color=(255, 195, 100, 230), batch=frame_batch)
            )
            draw_items.append(
                shapes.Circle(g2.x, g2.y, 3.5, color=(255, 255, 255, 255), batch=frame_batch)
            )

        # 5. Sidebar background panel
        draw_items.append(
            shapes.Rectangle(
                self.sidebar_x,
                0,
                self.ctrl_width,
                self.ctrl_height,
                color=(14, 18, 26, 255),
                batch=frame_batch,
            )
        )

        # Vertical divider border between viewport and sidebar
        draw_items.append(
            _make_line(
                self.sidebar_x,
                0,
                self.sidebar_x,
                self.window_height,
                (35, 45, 60, 255),
                frame_batch,
                2,
            )
        )

        # 6. Controls interactive visual elements (sliders, buttons)
        for s in self.sliders:
            s.draw_elements(draw_items, batch=frame_batch)

        for b in self.buttons:
            b.draw_elements(draw_items, batch=frame_batch)

        # Draw dynamic frame geometry
        frame_batch.draw()

        # Draw persistent text batches (HUD and sidebar text)
        self.hud_batch.draw()
        self.ctrl_batch.draw()


def main() -> None:
    """Launch the interactive galaxy collision simulator."""
    app = GalaxyCollisionApp()
    pyglet.app.run()


if __name__ == "__main__":
    main()
