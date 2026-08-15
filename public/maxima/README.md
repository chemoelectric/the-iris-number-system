# Maxima Package for the Iris Number System and \(\mathrm{Cl}(4,1,1)\) Unified Field Theory

This directory contains the native Maxima package `iris.mac` and verification scripts for performing symbolic and constructive calculations within the **Iris Number System** and the **\(\mathrm{Cl}(4,1,1)\) Master Field Equation**.

---

## 1. Features

- **Strict Rational Arithmetic**: Automatic configuration of `keepfloat: false`, `ratmx: true`, and `algebraic: true` to prevent continuum floating-point approximations.
- **\(\mathrm{Cl}(4,1,1)\) Clifford Geometric Algebra**: Full non-commutative symbolic algebra with signature \((+,+,+,+,-,-)\):
  - Space-time aperture generators: \(e_1^2 = 1, e_2^2 = 1, e_3^2 = 1, e_4^2 = 1\).
  - Mass-energy and charge flux generators: \(e_5^2 = -1, e_6^2 = -1\).
  - Canonical blade sorting and anti-commutation rules \(e_a e_b = -e_b e_a\) for \(a \neq b\).
- **MSRA Discrete Calculus**:
  - `iris_downarrow(expr)`: Main Scale Projection mapping.
  - `msra_diff(f, x, omega)`: Exact discrete vernier difference quotient \(\omega \cdot [f(x + 1/\omega) - f(x)]\).
- **Electrodynamics & Radiation Pressure**:
  - `make_electric_field(Ex, Ey, Ez)` and `make_magnetic_field(Bx, By, Bz, c)` constructors.
  - `poynting_vector(...)`: Evaluates Poynting field momentum density \(\mathbf{S} = \frac{1}{\mu_0}(\mathbf{E} \times \mathbf{B})\).
  - `radiation_pressure(S, c)`: Calculates wave radiation pressure \(P_\text{rad} = S / c\).
- **Fundamental Physical Constant Derivations**:
  - `proton_electron_mass_ratio()`: Exact geometric calculation of \(m_p / m_e = 6\pi^5\).
  - `electron_specific_charge(q, m)`: Scale-invariant charge-to-mass coupling ratio.
  - `newton_g_constant(c, delta_omega, hbar, omega)`: Derives Newton's gravitational constant \(G\) from discrete field cell flux.

---

## 2. Usage Instructions

### Loading in an Interactive Maxima Session

Start `maxima` and load the package:

```maxima
(%i1) load("public/maxima/iris.mac")$
```

### Running the Demonstration Script

Execute the demo in batch mode from the terminal:

```bash
maxima -b public/maxima/demo_constants.mac
```

---

## 3. Example Maxima Commands

```maxima
/* Compute Clifford wedge product of e1 and e2 */
cl_wedge(e[1], e[2]);
/* Returns: e[1] . e[2] */

/* Calculate discrete derivative of x^3 on grid of resolution omega */
msra_diff(x^3, x, omega);
/* Returns: 3*x^2 + (3*x)/omega + 1/omega^2 */

/* Evaluate exact rational proton-to-electron mass ratio */
proton_electron_mass_ratio();
/* Returns: 30920208/16807 (approx 1839.72) using pi = 22/7 */
```
