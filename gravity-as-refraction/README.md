# gravity-as-refraction

Interactive orbital simulator of circulating wave packets in a refractive gravitational field.

## Physical Foundation

In the Unified Field Theory, gravitation is not an independent fundamental force, nor is it “curved space-time.” We do not appeal to “rubber sheet physics” but instead to the optics of waves.

The universe is represented as a single electromagnetic field, defined by the Master Field Equation \( D F = J \). What we observe as matter consists of localized, tightly knotted topological regions within this field.

Near a dense knot, the concentration of field energy alters the local propagation speed of electromagnetic influences:

\[ v(r) = c \sqrt{1 - \frac{2 G M}{r c^2}} \approx c \left(1 - \frac{G M}{r c^2}\right) \]

or equivalently establishes an optical refractive index gradient:

\[ n(r) = \frac{c}{v(r)} \approx 1 + \frac{G M}{r c^2} \]

When circulating wave packets (matter knots) travel through this gradient, the portion of the vortex closer to the mass moves through a region of higher delay. This differential phase delay continuously tilts the vortex momentum vector:

\[ \Delta v = \frac{\mathrm{d} v}{\mathrm{d} r} \cdot 2 R \]

producing the exact inverse-square gravitational acceleration:

\[ \vec{a} = -\frac{G M}{r^2} \hat{r} \]

Furthermore, higher-order refractive delay terms naturally reproduce the classical perihelion advance (precessing rosette orbits) without curved space-time.

All gravity is, in the most direct physical sense, wave refraction.

## Features

* **Spirograph & Rosette Orbits**: Smooth, continuous orbital simulation where the circulating wave vortex draws multi-loop precessing spirograph patterns without crashing or halting into the central core.
* **Effortless Capture**: Launching from the left allows you to easily capture the matter knot into stable or precessing orbits by tuning speed with `f` / `s`.
* **Transparent PNG Equation Display**: The wave-refractive gravitational derivation equation is seamlessly embedded in the open space as a transparent PNG asset (`equation.png`).
* **Minimalist, Spare Interface**: No clutter or complex readouts—just the mass, the orbiting vortex, the spirograph trail, and the equation.
* **Interactive ASCII Controls**: Simple keyboard controls for speed, mass, launch height, and trail clearing.
* **Clean Terminal CLI Mode**: A quiet, minimal ANSI terminal orbit visualizer (`--cli`) without equation text.
* **Completely Silent**: Zero audio code, zero audio drivers, and zero sound.

## Installation

```bash
pip install gravity-as-refraction
```

## Usage

Launch the hardware-accelerated 2D graphical window:

```bash
gravity-as-refraction
```

Or run via Python module:

```bash
python3 -m gravity_as_refraction
```

To run the continuous terminal ANSI simulation in a text-only or remote environment:

```bash
gravity-as-refraction --cli
```

## Interactive Keyboard Controls (Pure ASCII Keys Only)

| Key | Action |
| :--- | :--- |
| **f** | Speed up (boost velocity +5%) |
| **s** | Slow down (reduce velocity -5% to easily capture into orbit) |
| **+** / **=** | Increase central mass knot energy |
| **-** / **_** | Decrease central mass knot energy |
| **[** | Lower launch height / impact parameter |
| **]** | Raise launch height / impact parameter |
| **c** | Clear spirograph trajectory trail |
| **r** | Relaunch from starting line |
| **g** | Toggle discrete resolution grid overlay |
| **Space** | Pause / Resume simulation |
| **q** / **Esc** | Exit application |

## License

MIT License. Copyright (c) 2026 Barry Schwartz.
