"""Command-line interface and terminal ANSI simulation mode."""

from __future__ import annotations

import argparse
import math
import sys
import time
from typing import Optional

try:
    from .physics import MatterKnot, RefractionField
except ImportError:
    from physics import MatterKnot, RefractionField


def run_terminal_orbit_simulation(
    duration: Optional[float] = None, fps: float = 24.0
) -> None:
    """Run an ASCII/ANSI terminal visualization of a matter knot orbiting in the field."""
    width = 72
    height = 24
    field = RefractionField(
        cx=width * 0.5,
        cy=height * 0.5,
        mass=140.0,
        c=24.0,
        core_radius=2.0,
    )

    # Launch matter knot in a smooth precessing orbit
    knot = MatterKnot(
        x=field.cx,
        y=field.cy - 7.5,
        vx=36.0,
        vy=0.0,
        radius=1.2,
        max_path_points=120,
    )

    print("\033[2J\033[H", end="")
    print("=" * width)
    print(" GRAVITATION AS WAVE REFRACTION • TERMINAL ORBIT SIMULATOR")
    print(" Press Ctrl+C to stop simulation.")
    print("=" * width)
    time.sleep(0.6)

    dt = 1.0 / fps
    frame_count = 0
    max_frames = int(duration * fps) if duration is not None else None

    try:
        while True:
            if max_frames is not None and frame_count >= max_frames:
                break
            frame_count += 1

            # Sub-step physics
            substeps = 4
            for _ in range(substeps):
                knot.update(field, dt / substeps)

            # Build ASCII buffer
            grid = [[" " for _ in range(width)] for _ in range(height)]

            # Draw central mass knot
            cx, cy = int(round(field.cx)), int(round(field.cy))
            if 0 <= cy < height and 0 <= cx < width:
                grid[cy][cx] = "●"
                if 0 <= cx - 1 < width:
                    grid[cy][cx - 1] = "("
                if 0 <= cx + 1 < width:
                    grid[cy][cx + 1] = ")"

            # Draw gradient rings
            for ang in range(0, 360, 24):
                rad = math.radians(ang)
                rx = int(round(field.cx + 8.5 * math.cos(rad)))
                ry = int(round(field.cy + 4.2 * math.sin(rad)))
                if 0 <= ry < height and 0 <= rx < width and grid[ry][rx] == " ":
                    grid[ry][rx] = "·"

            # Draw orbit path trail
            path = knot.path
            p_len = len(path)
            for i, (px, py) in enumerate(path):
                ix, iy = int(round(px)), int(round(py))
                if 0 <= iy < height and 0 <= ix < width:
                    if grid[iy][ix] == " ":
                        grid[iy][ix] = "·" if i < p_len // 2 else "*"

            # Draw orbiting matter knot
            kx, ky = int(round(knot.x)), int(round(knot.y))
            if 0 <= ky < height and 0 <= kx < width:
                grid[ky][kx] = "@"

            # Render frame (clean, no equation text)
            out = ["\033[H\033[?25l"]
            out.append(f"  Orbiting Matter Knot Spirograph Simulation [Ctrl+C to stop]")
            out.append("-" * width)
            for row in grid:
                out.append("".join(row))
            out.append("-" * width)
            out.append("  [@] Matter Knot  [*] Orbit Trail  [(●)] Central Mass  [·] Gradient")
            sys.stdout.write("\n".join(out) + "\n")
            sys.stdout.flush()

            time.sleep(dt)

    except KeyboardInterrupt:
        pass
    finally:
        print("\033[?25h")  # Restore terminal cursor
        print("\nTerminal simulation stopped.")


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="gravity-as-refraction",
        description="Visualizing gravitation as wave refraction in the universal electromagnetic field.",
    )
    parser.add_argument(
        "--cli",
        "--text",
        action="store_true",
        help="Run terminal ANSI simulation mode (for headless / SSH environments)",
    )
    parser.add_argument(
        "--duration",
        type=float,
        default=None,
        help="Optional duration in seconds (default: continuous until Ctrl+C)",
    )

    args = parser.parse_args()

    if args.cli:
        run_terminal_orbit_simulation(duration=args.duration)
        return

    # Attempt to launch hardware-accelerated Pyglet window
    try:
        from .app import run_app

        run_app()
    except Exception as exc:
        print(f"\nUnable to open graphical window: {exc}", file=sys.stderr)
        print("Launching terminal simulation instead...\n", file=sys.stderr)
        time.sleep(1.0)
        run_terminal_orbit_simulation(duration=args.duration)


if __name__ == "__main__":
    main()
