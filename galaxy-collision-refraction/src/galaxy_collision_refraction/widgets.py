"""Interactive GUI widgets (Sliders, Buttons) for Pyglet controls window."""

from __future__ import annotations

from typing import Callable, List, Optional, Tuple

try:
    import pyglet
    from pyglet import shapes
except ImportError:
    pyglet = None  # type: ignore
    shapes = None  # type: ignore


class SliderWidget:
    """An interactive horizontal slider widget drawn with Pyglet shapes and text."""

    def __init__(
        self,
        x: float,
        y: float,
        width: float,
        height: float,
        label: str,
        min_val: float,
        max_val: float,
        initial_val: float,
        format_spec: str = "{:.2f}",
        unit: str = "",
        step: Optional[float] = None,
        on_change: Optional[Callable[[float], None]] = None,
        batch=None,
    ) -> None:
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.label_text = label
        self.min_val = min_val
        self.max_val = max_val
        self.value = initial_val
        self.format_spec = format_spec
        self.unit = unit
        self.step = step
        self.on_change = on_change
        self.batch = batch

        self.dragging = False
        self.track_height = 4.0
        self.knob_radius = 8.0

        # Text labels
        self.title_label = pyglet.text.Label(
            self.label_text,
            font_name="Sans-Serif",
            font_size=10,
            x=self.x,
            y=self.y + 14,
            color=(210, 220, 235, 255),
            batch=self.batch,
        )

        self.value_label = pyglet.text.Label(
            self._formatted_value(),
            font_name="Monospace",
            font_size=9,
            x=self.x + self.width,
            y=self.y + 14,
            anchor_x="right",
            color=(120, 200, 255, 255),
            batch=self.batch,
        )

    def _formatted_value(self) -> str:
        text = self.format_spec.format(self.value)
        if self.unit:
            text += f" {self.unit}"
        return text

    def set_value(self, new_val: float, trigger_callback: bool = True) -> None:
        clamped = max(self.min_val, min(self.max_val, new_val))
        if self.step is not None and self.step > 0:
            clamped = round((clamped - self.min_val) / self.step) * self.step + self.min_val
        self.value = clamped
        self.value_label.text = self._formatted_value()
        if trigger_callback and self.on_change is not None:
            self.on_change(self.value)

    def _fraction(self) -> float:
        if self.max_val == self.min_val:
            return 0.0
        return (self.value - self.min_val) / (self.max_val - self.min_val)

    def knob_x(self) -> float:
        return self.x + self._fraction() * self.width

    def knob_y(self) -> float:
        return self.y

    def contains(self, px: float, py: float) -> bool:
        """Check if mouse pointer is within interaction zone."""
        pad = 12.0
        return (
            (self.x - pad) <= px <= (self.x + self.width + pad)
            and (self.y - pad) <= py <= (self.y + pad + 20)
        )

    def on_mouse_press(self, x: float, y: float, button: int) -> bool:
        if self.contains(x, y):
            self.dragging = True
            # Update value based on click position
            frac = max(0.0, min(1.0, (x - self.x) / self.width))
            new_val = self.min_val + frac * (self.max_val - self.min_val)
            self.set_value(new_val, trigger_callback=True)
            return True
        return False

    def on_mouse_drag(self, x: float, y: float) -> bool:
        if self.dragging:
            frac = max(0.0, min(1.0, (x - self.x) / self.width))
            new_val = self.min_val + frac * (self.max_val - self.min_val)
            self.set_value(new_val, trigger_callback=True)
            return True
        return False

    def on_mouse_release(self) -> None:
        self.dragging = False

    def draw_elements(self, draw_list: List, batch=None) -> None:
        """Append shape primitives for rendering."""
        target_batch = batch if batch is not None else self.batch
        # Track background
        draw_list.append(
            shapes.Rectangle(
                self.x,
                self.y - self.track_height * 0.5,
                self.width,
                self.track_height,
                color=(50, 60, 75, 255),
                batch=target_batch,
            )
        )
        # Active track highlight
        active_w = max(0.0, self._fraction() * self.width)
        if active_w > 0:
            draw_list.append(
                shapes.Rectangle(
                    self.x,
                    self.y - self.track_height * 0.5,
                    active_w,
                    self.track_height,
                    color=(70, 150, 235, 255),
                    batch=target_batch,
                )
            )
        # Knob
        kx = self.knob_x()
        ky = self.knob_y()
        knob_col = (255, 255, 255, 255) if self.dragging else (200, 225, 255, 255)
        draw_list.append(
            shapes.Circle(
                kx,
                ky,
                self.knob_radius,
                color=knob_col,
                batch=target_batch,
            )
        )
        draw_list.append(
            shapes.Circle(
                kx,
                ky,
                self.knob_radius * 0.45,
                color=(20, 60, 120, 255),
                batch=target_batch,
            )
        )


class ButtonWidget:
    """An interactive push button widget drawn with Pyglet shapes and text."""

    def __init__(
        self,
        x: float,
        y: float,
        width: float,
        height: float,
        label: str,
        on_click: Optional[Callable[[], None]] = None,
        bg_color: Tuple[int, int, int] = (35, 55, 80),
        accent_color: Tuple[int, int, int] = (60, 130, 210),
        batch=None,
    ) -> None:
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.label_text = label
        self.on_click = on_click
        self.bg_color = bg_color
        self.accent_color = accent_color
        self.batch = batch
        self.pressed = False

        self.label = pyglet.text.Label(
            self.label_text,
            font_name="Sans-Serif",
            font_size=9,
            x=self.x + self.width * 0.5,
            y=self.y + self.height * 0.5 - 4,
            anchor_x="center",
            color=(240, 240, 245, 255),
            batch=self.batch,
        )

    def contains(self, px: float, py: float) -> bool:
        return self.x <= px <= self.x + self.width and self.y <= py <= self.y + self.height

    def on_mouse_press(self, x: float, y: float, button: int) -> bool:
        if self.contains(x, y):
            self.pressed = True
            return True
        return False

    def on_mouse_release(self, x: float, y: float) -> bool:
        if self.pressed:
            self.pressed = False
            if self.contains(x, y) and self.on_click is not None:
                self.on_click()
                return True
        return False

    def draw_elements(self, draw_list: List, batch=None) -> None:
        target_batch = batch if batch is not None else self.batch
        col = self.accent_color if self.pressed else self.bg_color
        draw_list.append(
            shapes.Rectangle(
                self.x,
                self.y,
                self.width,
                self.height,
                color=(*col, 255),
                batch=target_batch,
            )
        )
