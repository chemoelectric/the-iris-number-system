# gravity-as-refraction

Visualizing gravitation as wave refraction in the universal electromagnetic field.

## Physical Foundation

In the Unified Field Theory, gravitation is not an independent fundamental force, nor is it “curved space-time.” We do not appeal to “rubber sheet physics” but instead to the optics of waves.

The universe is represented as a single electromagnetic field, defined by the Master Field Equation \( D F = J \). What we observe as matter consists of localized, tightly knotted topological regions within this field.

Near a dense knot, the concentration of field energy alters the local propagation speed of electromagnetic influences:

\[ v(r) = c \sqrt{1 - \frac{2 G M}{r c^2}} \approx c \left(1 - \frac{G M}{r c^2}\right) \]

or equivalently establishes an optical refractive index gradient:

\[ n(r) = \frac{c}{v(r)} \approx 1 + \frac{G M}{r c^2} \]

When wave packets, light rays, or orbiting matter knots travel through this gradient, the portion closer to the mass moves through a region of higher delay. This differential phase delay continuously tilts the wave fronts toward the energy concentration:

* **Electromagnetic Waves**: Wave fronts continuously refract around the mass, creating the observed gravitational deflection and lensing.
* **Matter Knots**: Matter itself consists of circulating wave vortices. The differential delay across the physical aperture of the vortex continuously rotates its momentum vector, producing the familiar inverse-square gravitational acceleration without any external downward pull or geometric curvature.

All gravity is, in the most direct physical sense, wave refraction.

## Features

* **Real-Time Wave Front Refraction**: Watch plane wave fronts propagate across the field and visibly bend around the mass knot via differential phase delay.
* **Circulating Matter Knot Dynamics**: Observe an orbiting or falling matter vortex steered entirely by the refractive gradient across its finite diameter.
* **Ray Tracing & Gravitational Lensing**: Visualize multiple Poynting-flux trajectories undergoing Snell gradient refraction to form caustics and focal lines.
* **Interactive Controls**: Dynamically change the central mass, launch coordinates, impact parameter, and simulation speed.
* **Completely Silent**: Zero audio code, zero audio drivers, and zero sound.
* **Headless Terminal Mode**: Includes a terminal ANSI rendering mode (`--cli`) for headless or remote SSH servers.

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

To run the terminal ANSI simulation in a text-only or remote environment:

```bash
gravity-as-refraction --cli
```

## Interactive Keyboard Controls

| Key | Action |
| :--- | :--- |
| **Space** | Pause / Resume simulation |
| **1** | Mode 1: Plane Wave Fronts (Huygens wave front tilt) |
| **2** | Mode 2: Circulating Matter Knot (Orbiting/falling vortex) |
| **3** | Mode 3: Optical Ray Lensing & Caustics |
| **Up** / **Down** | Increase / Decrease central mass energy |
| **Left** / **Right** | Adjust launch position / impact parameter |
| **G** | Toggle discrete resolution grid overlay |
| **R** | Reset simulation to initial state |
| **Q** / **Esc** | Exit application |

## License

MIT License. Copyright (c) 2026 Barry Schwartz.
