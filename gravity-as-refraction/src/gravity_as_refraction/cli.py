"""Command-line interface and terminal ANSI simulation mode."""

from __future__ import annotations

import argparse
import math
import sys
import time

try:
    from .physics import RefractionField, WaveFront, MatterKnot, maxent_gravitational_constant
except ImportError:
    from physics import RefractionField, WaveFront, MatterKnot, maxent_gravitational_constant


def run_terminal_simulation(duration: float = 8.0, fps: float = 15.0) -> None:
    """Run an ASCII/ANSI terminal visualization of wave front refraction."""
    width = 68
    height = 24
    field = RefractionField(cx=width * 0.5, cy=height * 0.5, mass=120.0, c=16.0, core_radius=3.0)

    # Wavefront starting on the left
    wave = WaveFront(start_x=4.0, y_min=2.0, y_max=height - 2.0, num_points=21)

    print("\033[2J\033[H", end="")
    print("=" * width)
    print(" GRAVITATION AS WAVE REFRACTION • TERMINAL SIMULATION")
    print("=" * width)
    print("Matter Knot at center alters propagation speed of electromagnetic waves.")
    print("Wavefronts retard near mass, continuously tilting toward the knot.")
    print("=" * width)
    time.sleep(1.2)

    dt = 1.0 / fps
    total_frames = int(duration * fps)

    for _ in range(total_frames):
        wave.update(field, dt)

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

        # Draw refractive field influence boundary
        for ang in range(0, 360, 30):
            rad = math.radians(ang)
            rx = int(round(field.cx + 9.0 * math.cos(rad)))
            ry = int(round(field.cy + 4.5 * math.sin(rad)))
            if 0 <= ry < height and 0 <= rx < width and grid[ry][rx] == " ":
                grid[ry][rx] = "·"

        # Draw wavefront points
        for pt in wave.points:
            px, py = int(round(pt.x)), int(round(pt.y))
            if 0 <= py < height and 0 <= px < width:
                grid[py][px] = "#"

        # Render frame
        out = ["\033[H\033[?25l"]
        out.append(f"  Field Mass: {field.mass:.1f} | Base c: {field.c:.1f} | Wave Refraction Active")
        out.append("-" * width)
        for row in grid:
            out.append("".join(row))
        out.append("-" * width)
        out.append("  [#] Wavefront  [●] Central Mass Knot  [·] Refractive Gradient Zone")
        sys.stdout.write("\n".join(out) + "\n")
        sys.stdout.flush()

        time.sleep(dt)

        # Loop wavefront if it passed the screen
        if all(pt.x > width - 2 for pt in wave.points):
            wave = WaveFront(start_x=4.0, y_min=2.0, y_max=height - 2.0, num_points=21)

    print("\033[?25h")  # Restore cursor
    print("Simulation finished. Run without --cli to launch the full graphical window.")


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
        run_terminal_simulation()
        return

    # Attempt to run Pyglet graphical window
    try:
        from .app import run_app

        run_app()
    except Exception as exc:
        print(f"\nUnable to open graphical window: {exc}", file=sys.stderr)
        print("Launching terminal simulation instead...\n", file=sys.stderr)
        time.sleep(1.0)
        run_terminal_simulation()


if __name__ == "__main__":
    main()
