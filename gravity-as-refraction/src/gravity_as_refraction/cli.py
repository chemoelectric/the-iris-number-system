"""Command-line interface and terminal ANSI simulation mode."""

from __future__ import annotations

import argparse
import math
import sys
import time
from typing import List, Optional

try:
    from .physics import RefractionField, WaveFront, MatterKnot, maxent_gravitational_constant
except ImportError:
    from physics import RefractionField, WaveFront, MatterKnot, maxent_gravitational_constant


def run_terminal_simulation(duration: Optional[float] = None, fps: float = 20.0) -> None:
    """Run a continuous ASCII/ANSI terminal visualization of wave front refraction."""
    width = 72
    height = 24
    field = RefractionField(
        cx=width * 0.5,
        cy=height * 0.5,
        mass=200.0,
        c=32.0,  # Faster wave propagation
        core_radius=3.5,
    )

    # Maintain two staggered wave fronts moving across the terminal
    waves: List[WaveFront] = [
        WaveFront(start_x=4.0, y_min=2.0, y_max=height - 2.0, num_points=23),
        WaveFront(start_x=28.0, y_min=2.0, y_max=height - 2.0, num_points=23),
    ]

    print("\033[2J\033[H", end="")
    print("=" * width)
    print(" GRAVITATION AS WAVE REFRACTION • TERMINAL SIMULATION")
    print("=" * width)
    print("Matter Knot at center alters propagation speed of electromagnetic waves.")
    print("Wavefronts slow down near mass, continuously tilting toward the knot.")
    print("Press Ctrl+C to stop simulation.")
    print("=" * width)
    time.sleep(0.8)

    dt = 1.0 / fps
    frame_count = 0
    max_frames = int(duration * fps) if duration is not None else None

    try:
        while True:
            if max_frames is not None and frame_count >= max_frames:
                break
            frame_count += 1

            # Update wave fronts
            for w in waves:
                w.update(field, dt)

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

            # Draw refractive field influence boundary rings
            for ang in range(0, 360, 24):
                rad = math.radians(ang)
                rx = int(round(field.cx + 11.0 * math.cos(rad)))
                ry = int(round(field.cy + 5.5 * math.sin(rad)))
                if 0 <= ry < height and 0 <= rx < width and grid[ry][rx] == " ":
                    grid[ry][rx] = "·"

            # Draw sample points on wave fronts
            for w in waves:
                for pt in w.points:
                    px, py = int(round(pt.x)), int(round(pt.y))
                    if 0 <= py < height and 0 <= px < width:
                        grid[py][px] = "#"

            # Render frame
            out = ["\033[H\033[?25l"]
            out.append(
                f"  Field Mass: {field.mass:.1f} | Base c: {field.c:.1f} | Wave Refraction Active [Ctrl+C to stop]"
            )
            out.append("-" * width)
            for row in grid:
                out.append("".join(row))
            out.append("-" * width)
            out.append("  [#] Wavefront Points  [●] Central Mass Knot  [·] Refractive Gradient Zone")
            sys.stdout.write("\n".join(out) + "\n")
            sys.stdout.flush()

            time.sleep(dt)

            # Re-spawn wave fronts as they exit the right boundary
            for idx, w in enumerate(waves):
                if all(pt.x > width - 1 for pt in w.points):
                    waves[idx] = WaveFront(
                        start_x=3.0,
                        y_min=2.0,
                        y_max=height - 2.0,
                        num_points=23,
                    )

    except KeyboardInterrupt:
        pass
    finally:
        print("\033[?25h")  # Restore terminal cursor
        print("\nTerminal simulation stopped.")


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="gravity-as-refraction",
        description="Visualizing gravitation as wave refraction in the unified electromagnetic field.",
    )
    parser.add_argument(
        "--cli",
        "--text",
        action="store_true",
        help="Run terminal ANSI simulation mode (useful for headless / SSH environments)",
    )
    parser.add_argument(
        "--duration",
        type=float,
        default=None,
        help="Optional duration in seconds for terminal simulation (defaults to continuous until Ctrl+C)",
    )
    parser.add_argument(
        "--integral",
        action="store_true",
        help="Print the exact MaxEnt spectral wave refraction derivation for Newton's G",
    )

    args = parser.parse_args()

    if args.integral:
        print("\n" + "=" * 65)
        print(" NEWTON'S GRAVITATIONAL CONSTANT AS A MAXENT WAVE REFRACTION INTEGRAL")
        print("=" * 65)
        print(" In the Unified Field Theory, gravitation is not a fundamental force,")
        print(" nor is it curved spacetime. All matter consists of localized knots")
        print(" of circulating electromagnetic wave energy.")
        print()
        print(" The gravitational coupling G is derived directly from the MaxEnt")
        print(" spectral energy-density gradient of the discrete lattice:")
        print()
        print("   G = (c^2 * delta_omega^2 / 4*pi*m) * (15 / pi^4) * integral_0^inf [u^3 / (e^u - 1)] du")
        print("     = c^2 * delta_omega^2 / (4 * pi * m)")
        print()
        print(" Circulation action S_circ = E / omega cancels out identically,")
        print(" demonstrating that gravitation is a classical wave-refractive effect")
        print(" completely independent of quantum physics.")
        print("=" * 65 + "\n")
        return

    if args.cli:
        run_terminal_simulation(duration=args.duration)
        return

    # Attempt to run Pyglet graphical window
    try:
        from .app import run_app

        run_app()
    except Exception as exc:
        print(f"\nUnable to open graphical window: {exc}", file=sys.stderr)
        print("Launching continuous terminal simulation instead...\n", file=sys.stderr)
        time.sleep(1.0)
        run_terminal_simulation(duration=args.duration)


if __name__ == "__main__":
    main()
