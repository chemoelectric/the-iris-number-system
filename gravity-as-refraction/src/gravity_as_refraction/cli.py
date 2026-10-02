"""Command-line interface and terminal ANSI orbital simulation mode."""

from __future__ import annotations

import argparse
import math
import sys
import time
from typing import Optional

try:
    from .physics import (
        MatterKnot,
        RefractionField,
        create_circular_orbit,
        create_elliptic_orbit,
        create_rosette_orbit,
        maxent_gravitational_constant,
    )
except ImportError:
    from physics import (
        MatterKnot,
        RefractionField,
        create_circular_orbit,
        create_elliptic_orbit,
        create_rosette_orbit,
        maxent_gravitational_constant,
    )


def run_terminal_orbit_simulation(
    preset: str = "ellipse", duration: Optional[float] = None, fps: float = 24.0
) -> None:
    """Run an ASCII/ANSI terminal visualization of an orbiting matter knot."""
    width = 72
    height = 24
    field = RefractionField(
        cx=width * 0.5,
        cy=height * 0.5,
        mass=140.0,
        c=24.0,
        core_radius=2.2,
    )

    if preset == "circle":
        knot = create_circular_orbit(field, radius=8.0)
    elif preset == "rosette":
        knot = create_rosette_orbit(field, periapsis=4.2)
    else:  # ellipse
        knot = create_elliptic_orbit(field, periapsis=4.8, eccentricity=0.55)

    print("\033[2J\033[H", end="")
    print("=" * width)
    print(" GRAVITATION AS WAVE REFRACTION • ORBITAL SIMULATOR")
    print("=" * width)
    print(" G = (c²·Δω² / 4πm) · (15/π⁴) ∫₀^∞ [u³/(eᵘ - 1)] du = c²·Δω² / (4πm)")
    print(" Refractive Index: n(r) = 1 + 2GM/(r·c²)   |   a = -GM/r²")
    print(" Press Ctrl+C to stop simulation.")
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

            # Draw equipotential gradient rings
            for ang in range(0, 360, 20):
                rad = math.radians(ang)
                rx = int(round(field.cx + 8.5 * math.cos(rad)))
                ry = int(round(field.cy + 4.2 * math.sin(rad)))
                if 0 <= ry < height and 0 <= rx < width and grid[ry][rx] == " ":
                    grid[ry][rx] = "·"

            # Draw orbit path trail (with fading characters)
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

            # Compute real-time orbital metrics
            r = knot.distance(field)
            v = knot.speed()
            energy = knot.specific_energy(field)
            ang_mom = knot.angular_momentum(field)
            state = knot.orbit_type(field)

            # Render frame
            out = ["\033[H\033[?25l"]
            out.append(
                "  Eq: G = (c²·Δω² / 4πm) · (15/π⁴) ∫₀^∞ [u³/(eᵘ - 1)] du = c²·Δω² / (4πm)"
            )
            out.append(
                f"  Orbit: {preset.upper()} | State: {state.upper()} | [Ctrl+C to stop]"
            )
            out.append(
                f"  r: {r:4.1f} | v: {v:4.1f} | E: {energy:6.1f} | L: {ang_mom:6.1f}"
            )
            out.append("-" * width)
            for row in grid:
                out.append("".join(row))
            out.append("-" * width)
            out.append("  [@] Matter Knot  [*] Orbit Trail  [(●)] Central Mass  [·] Field Gradient")
            sys.stdout.write("\n".join(out) + "\n")
            sys.stdout.flush()

            time.sleep(dt)

            # Reset if captured or escaped far away
            if knot.captured or r > 45.0:
                time.sleep(0.5)
                if preset == "circle":
                    knot = create_circular_orbit(field, radius=8.0)
                elif preset == "rosette":
                    knot = create_rosette_orbit(field, periapsis=4.2)
                else:
                    knot = create_elliptic_orbit(field, periapsis=4.8, eccentricity=0.55)

    except KeyboardInterrupt:
        pass
    finally:
        print("\033[?25h")  # Restore terminal cursor
        print("\nTerminal orbital simulation stopped.")


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="gravity-as-refraction",
        description="Interactive orbital simulator of circulating wave packets in a refractive gravitational field.",
    )
    parser.add_argument(
        "--cli",
        "--text",
        action="store_true",
        help="Run terminal ANSI orbital simulation mode (for headless / SSH environments)",
    )
    parser.add_argument(
        "--orbit",
        choices=["circle", "ellipse", "rosette"],
        default="ellipse",
        help="Initial orbit type for terminal simulation (default: ellipse)",
    )
    parser.add_argument(
        "--duration",
        type=float,
        default=None,
        help="Optional duration in seconds (default: continuous until Ctrl+C)",
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
        print(" Refractive Index Gradient:")
        print("   n(r) = 1 + 2*G*M / (r * c^2)")
        print("   v(r) = c / n(r)")
        print("   a    = - (dv/dr) * 2*R_vortex = - (G*M / r^2) * r_hat")
        print("=" * 65 + "\n")
        return

    if args.cli:
        run_terminal_orbit_simulation(preset=args.orbit, duration=args.duration)
        return

    # Attempt to launch hardware-accelerated Pyglet window
    try:
        from .app import run_app

        run_app()
    except Exception as exc:
        print(f"\nUnable to open graphical window: {exc}", file=sys.stderr)
        print("Launching continuous terminal orbital simulation instead...\n", file=sys.stderr)
        time.sleep(1.0)
        run_terminal_orbit_simulation(preset=args.orbit, duration=args.duration)


if __name__ == "__main__":
    main()
