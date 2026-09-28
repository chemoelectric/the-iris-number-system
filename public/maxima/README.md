# Maxima Package for the Iris Number System and the Master Field Equation

This directory contains the native Maxima package `iris.mac` and verification scripts for performing symbolic and constructive calculations within the **Iris Number System** and the **Master Field Equation**.

---

## 1. Mathematical Formulation

### Basis Vectors & Metric
The basis set is given by:
\[
\{e_1, e_2, e_3, e_4, e_+, e_-\}
\]
with quadratic metric constraints:
\[
e_1^2 = e_2^2 = e_3^2 = 1, \qquad e_4^2 = 0, \qquad e_+^2 = 1, \qquad e_-^2 = -1
\]
and conformal / null coordinates:
\[
e_\infty = e_+ + e_-, \qquad e_0 = \frac{1}{2}(e_- - e_+)
\]
\[
e_\infty^2 = 0, \qquad e_0^2 = 0, \qquad e_0 \cdot e_\infty = -1
\]

### Master Field Equation
\[
\mathcal{D}\mathcal{F}_{\text{total}} = \mathcal{J}_{\text{total}}
\]
where:
\[
\mathcal{D} = \nabla + e_4 \frac{1}{c} D_t, \qquad D_t = \frac{\partial}{\partial t} - \mathbf{u} \cdot \nabla
\]
\[
\mathcal{F}_{\text{total}} = \mathbf{E} e_4 + c \mathbf{B} (e_1 \wedge e_2 \wedge e_3)
\]
\[
\mathcal{J}_{\text{total}} = \rho_0 \mathbf{U}, \qquad \mathbf{U} = \mathbf{u} + c e_4
\]

---

## 2. Features in `iris.mac`

- **Strict Rational Arithmetic**: Automatic configuration of `keepfloat: false`, `ratmx: true`, and `algebraic: true` to prevent continuum floating-point approximations.
- **Basis & Null Algebra**:
  - Non-commutative symbolic rules with $e_4^2 = 0$ (degenerate/null temporal aperture), $e_+^2 = 1$, $e_-^2 = -1$.
  - Canonical anti-commutation rules $e_a e_b = -e_b e_a$ for $a \neq b$.
  - Exact evaluations of $e_\infty^2 = 0$, $e_0^2 = 0$, and $e_0 \cdot e_\infty = -1$.
- **Field & Current Constructors**:
  - `make_electric_field(Ex, Ey, Ez)`: Creates $\mathbf{E} e_4$.
  - `make_magnetic_field(Bx, By, Bz, c)`: Creates $c \mathbf{B} (e_1 \wedge e_2 \wedge e_3)$.
  - `make_F_total(...)`: Creates $\mathcal{F}_{\text{total}} = \mathbf{E}e_4 + c\mathbf{B}(e_1 \wedge e_2 \wedge e_3)$.
  - `make_velocity_4vector(ux, uy, uz, c)`: Creates $\mathbf{U} = \mathbf{u} + ce_4$.
  - `make_J_total(rho_0, ux, uy, uz, c)`: Creates $\mathcal{J}_{\text{total}} = \rho_0 \mathbf{U}$.
- **Electrodynamics & Momentum Flux**:
  - `poynting_vector(Ex, Ey, Ez, Bx, By, Bz, mu0)`: Calculates $\mathbf{S} = \frac{1}{\mu_0}(\mathbf{E} \times \mathbf{B})$.
  - `radiation_pressure(S, c)`: Calculates wave radiation pressure $P_\text{rad} = \frac{S}{c}$.
- **MSRA Discrete Calculus**:
  - `iris_downarrow(expr)`: Main Scale Projection mapping.
  - `iris_grid_val(k, omega)`: Rational coordinate $k/\omega$ on discrete resolution grid $\mathcal{G}_\Omega$.
  - `msra_diff(f, x, omega)`: Exact discrete vernier difference quotient $\omega \cdot [f(x + 1/\omega) - f(x)]$.
- **Fundamental Physical Constant Derivations**:
  - `proton_electron_mass_ratio()`: Exact rational geometric volume calculation of $m_p / m_e = 6\pi^5$.
  - `electron_specific_charge(q, m)`: Scale-invariant charge-to-mass coupling ratio.
  - `newton_g_constant(c, delta_omega, hbar, omega)`: Derives Newton's gravitational constant $G$ from discrete field cell flux.

---

## 3. Usage Instructions

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

## 4. Example Maxima Commands

```maxima
/* Null property of e4 (temporal aperture generator) */
ratsimp(e4 . e4);
/* Returns: 0 */

/* Null infinity property */
ratsimp(e_inf . e_inf);
/* Returns: 0 */

/* Inner product of null origin e0 and null infinity e_inf */
cl_dot(e_0, e_inf);
/* Returns: -1 */

/* Construct unified field */
make_F_total(Ex, Ey, Ez, Bx, By, Bz, c);

/* Calculate discrete derivative of x^3 on grid of resolution omega */
msra_diff(x^3, x, omega);
/* Returns: 3*x^2 + (3*x)/omega + 1/omega^2 */

/* Evaluate exact rational proton-to-electron mass ratio */
proton_electron_mass_ratio();
/* Returns: 30920208/16807 (approx 1839.72) using pi = 22/7 */
```
