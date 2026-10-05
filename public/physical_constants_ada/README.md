# Physical Constants in Ada 2022 (A Latter-Day ALGOL 60)

This directory contains standalone, human-readable Ada 2022 packages for computing the fundamental physical constants to a given relative tolerance.

## Design Philosophy

1. **A Latter-Day ALGOL 60**:
   - The code is crafted to serve as an international, transparent, human-readable algorithmic specification.
   - It is readily translatable by humans into any programming language—such as Scheme/Lisp with exact rationals and arbitrary-precision reals, C using GMP/MPFR, Python using `decimal`/`fractions`, Julia, or Fortran.

2. **Modular Decomposition**:
   - Each constant is isolated into its own dedicated package pair (`.ads` specification and `.adb` implementation body) to ensure maximum reading clarity without monolithic clutter.

3. **Generic Real Precision (`bigreal` Ready)**:
   - Every package is parameterized over `generic type real_type is digits <>;`.
   - It works seamlessly with `Standard.Float`, `Standard.Long_Float`, or arbitrary-precision real types like `Ada.Numerics.Big_Numbers.Big_Reals.Big_Real`.
   - Functions accept an explicit `relative_tolerance` parameter, terminating iterative series when the fractional step falls below the threshold.

4. **Purely Structural and Geometric Relations**:
   - Constants like the fine-structure constant \( \alpha \) are computed from the complete elliptic aspect-ratio series of the toroidal vortex in \( Cl(4,1,1) \).
   - The proton-to-electron mass ratio \( m_p / m_e \) is computed from the conformal \( 5 \)-sphere volume with discrete lattice boundary recoil.
   - Field standards (\( Z_0, \mu_0, \varepsilon_0 \)) are computed in closed form relative to true \( c \).
   - SI fundamental conversion constants (\( c, e, h, k_B \)) are provided in their exact defined integer/fractional metrological form.

## Package Inventory

| Package File | Constant / Observable | Form / Derivation |
|:---|:---|:---|
| `speed_of_light.ads/.adb` | \( c \) | Exact speed of electromagnetic influences (\( 299\,792\,458 \text{ m/s} \)) |
| `circle_constant_pi.ads/.adb` | \( \pi \) | Brent-Salamin (Gauss-Legendre AGM) algorithm |
| `fine_structure_constant.ads/.adb` | \( \alpha \) & \( 1/\alpha \) | Complete elliptic aspect-ratio series of toroidal vortex in \( Cl(4,1,1) \) |
| `proton_electron_mass_ratio.ads/.adb` | \( m_p / m_e \) | Conformal 5-sphere volume \( 6\pi^5(1 - \alpha/24 + \alpha^2/\pi) \) |
| `elementary_charge.ads/.adb` | \( e \) | Exact SI elementary charge (\( 1.602176634 \times 10^{-19} \text{ C} \)) |
| `planck_constant.ads/.adb` | \( h \) & \( \hbar \) | Exact SI Planck constant (\( 6.62607015 \times 10^{-34} \text{ J}\cdot\text{s} \)) |
| `electron_mass.ads/.adb` | \( m_e \) | Metrological rest mass from Rydberg constant \( 2 R_\infty h / (\alpha^2 c) \) |
| `electron_charge_to_mass_ratio.ads/.adb` | \( e / m_e \) | Specific charge \( e / m_e \) |
| `proton_mass.ads/.adb` | \( m_p \) | Rest mass from \( (m_p / m_e) \times m_e \) |
| `gravitational_constant.ads/.adb` | \( G \) | Wave refraction coupling from energy conservation & Planck lattice aperture |
| `boltzmann_constant.ads/.adb` | \( k_B \) | Exact SI energy-to-temperature conversion factor (\( 1.380649 \times 10^{-23} \text{ J/K} \)) |
| `molar_gas_constant.ads/.adb` | \( R \) | Exact molar momentum flux constant \( N_A k_B \) |
| `vacuum_impedance.ads/.adb` | \( Z_0 \) | Transverse wave impedance \( 2 \alpha R_K \) |
| `vacuum_permeability.ads/.adb` | \( \mu_0 \) | Magnetic permeability \( Z_0 / c \) |
| `vacuum_permittivity.ads/.adb` | \( \varepsilon_0 \) | Electric permittivity \( 1 / (Z_0 c) \) |
| `demo_constants.adb` | Driver | Comprehensive demonstration of package instantiations |
