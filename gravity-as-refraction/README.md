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

* **Interactive Orbital Mechanics**: Explore circular orbits, eccentric ellipses, precessing rosette orbits, hyperbolic flybys, and core capture.
* **Real-Time Parameter Adjustment**: Dynamically alter velocity magnitude, launch angle, orbital radius, and central mass energy using pure ASCII keyboard controls.
* **Continuous Trajectory History**: Visualize the complete path of the matter knot with a glowing historical trail.
* **Internal Vortex Circulation**: Watch the internal wave-phase vector rotate within the matter knot as it orbits.
* **Live Orbital Diagnostics**: Real-time HUD showing distance \( r \), velocity \( v \), specific orbital energy \( \mathcal{E} \), angular momentum \( L \), and bound/unbound state.
* **Headless Terminal Mode**: Includes an interactive terminal ANSI rendering mode (`--cli`) that loops smoothly until `Ctrl+C`.
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
| **1** | Preset: Circular Orbit (\( e = 0 \)) |
| **2** | Preset: Eccentric Ellipse (\( e \approx 0.62 \)) |
| **3** | Preset: Precessing Rosette (Wave-delay perihelion advance) |
| **4** | Preset: Hyperbolic Flyby (Gravitational scattering) |
| **5** | Preset: Inspiral Core Capture |
| **f** | Boost velocity magnitude (+6%) |
| **s** | Reduce velocity magnitude (-6%) |
| **a** | Rotate velocity vector counterclockwise (+3°) |
| **d** | Rotate velocity vector clockwise (-3°) |
| **+** / **=** | Increase central mass knot energy |
| **-** / **_** | Decrease central mass knot energy |
| **[** | Contract orbital radius toward center |
| **]** | Expand orbital radius away from center |
| **c** | Clear trajectory path history |
| **g** | Toggle discrete resolution grid overlay |
| **Space** | Pause / Resume simulation |
| **r** | Reset current orbit preset |
| **q** / **Esc** | Exit application |

## License

MIT License. Copyright (c) 2026 Barry Schwartz.
