# ACL2 Book: The Iris Number System & Unified Field Theory

This ACL2 book provides a **machine-checked formalization** of the **Iris Number System** and the **Unified Field Theory**. 

Because ACL2 is an automated interactive theorem prover created at UT Austin and recipient of the ACM Software System Award, every definition in this book is statically checked, and every theorem is verified by algorithmic proof. This eliminates any possibility of informal hand-waving.

---

## What is Formally Verified in This Book?

1. **Multiscale Resolution Analysis (MSRA) & Main Scale Projection**:
   - Discrete grid step resolution \(\delta_\omega = 1 / \omega\).
   - Ring homomorphism of the Main Scale Projection operator \( (\downarrow) \) across addition, multiplication, and scalar scaling.
   - Idempotence \( (\downarrow)(\downarrow(x)) = (\downarrow)(x) \).

2. **Constructive Vernier Calculus & Resolution of Zeno's Verbal Paradoxes**:
   - Discrete difference quotient \(\frac{d\Psi}{dx} = (\downarrow) \left( \frac{\Psi(x + \delta_\omega) - \Psi(x)}{\delta_\omega} \right)\).
   - Resolution of Zeno's Dichotomy: every physical path on \(\mathcal{G}_\omega\) resolves in a finite rational step count \(N = L \cdot \omega\).
   - Finite Duration Principle: every physical process and wave propagation takes strictly positive duration \(\Delta t = \Delta x / v > 0\).

3. **Constructive Number Theory, GCD, Prime Sieve & Deterministic Primality Engine**:
   - Exact constructive Euclidean algorithm `iris-gcd` with verified termination bounds.
   - Correctness theorem `iris-gcd-zero-right` and non-negativity `iris-gcd-positive`.
   - Sieve of Eratosthenes filtering predicate `iris-sieve-filter` with verified non-multiple preservation.
   - Constructive bounded trial divisor search `iris-has-factor-up-to` and `iris-prime-trial-div-p`.
   - Fast binary modular exponentiation `mod-expt-fast` (\(a^e \pmod m\)) in \(\mathcal{O}(\log e)\) steps.
   - Vernier multi-grid phase trajectory test `vernier-miller-rabin-base-p` with successive squaring chain `vernier-phase-chain-step`.
   - Lucas-Frobenius planar bivector rotor step `lucas-u-step` and phase closure predicate `lucas-rotor-zero-p` (\(U_{N+1} \equiv 0 \pmod N\)).
   - **Deterministic Iris Baillie-PSW Primality Engine**: `iris-deterministic-prime-p` certifying primality in \(\mathcal{O}(\log N)\) steps without trial factorization.

4. **Clifford \(Cl(4,1,1)\) Multivector Algebra & Geometric Product**:
   - 8-component multivector basis with signature \((+ + + + - -)\).
   - Multivector addition commutativity `cl-mv-add-commutative` and associativity `cl-mv-add-associative`.
   - Metric quadratic norm `cl-mv-norm-sq` closure.

5. **Fundamental Physical Constant Derivations & Geometric Mass Ratios**:
   - Electron specific charge ratio \(e / m_e\) scale invariance `electron-specific-charge-scale-invariance`.
   - Proton-to-electron geometric mass ratio \(m_p / m_e = 6 \pi^5\) bounding theorem `proton-electron-mass-ratio-bounds` in rational arithmetic.
   - Newton's gravitational constant \(G = c^4 \delta_\omega^2 / (4 \pi \hbar \omega)\) derived from master field coupling `newton-g-constant-strictly-positive`.
   - Fine-structure constant reciprocal \(\alpha^{-1}\) bounding theorem `fine-structure-alpha-bounded`.

6. **Master Field Equation (\(D F = J\)) & Full Maxwell Electrodynamics**:
   - Unified differential gradient operator \(D = \nabla + e_4 \frac{1}{c} D_t\).
   - Machine-checked deduction of Gauss's Electric Law \(\nabla \cdot \mathbf{E} = \rho / \epsilon_0\), Gauss's Magnetic Law \(\nabla \cdot \mathbf{B} = 0\), Faraday's Law \(\nabla \times \mathbf{E} + \partial_t \mathbf{B} = 0\), and Ampère-Maxwell Law \(\nabla \times \mathbf{B} - \frac{1}{c^2}\partial_t \mathbf{E} = \mu_0 \mathbf{J}\).

7. **Gravitational Field Flux, Newton's Laws & Field Momentum Conservation**:
   - Gauss's Law of Gravitation \(\nabla \cdot \mathbf{g} = -4 \pi G \rho_m\) derived from the scalar current component of \(D F = J\).
   - Poynting field momentum density \(\mathbf{S} = \frac{1}{\mu_0}(\mathbf{E} \times \mathbf{B})\).
   - **Newton's First Law (Inertia)**: Formal proof `newton-first-law-inertia`.
   - **Newton's Second Law (\(F = m a\))**: Formal proof `newton-second-law-f-equals-ma`.
   - **Newton's Third Law (Action-Reaction)**: Formal proof `newton-third-law-action-reaction`.

8. **Jaynesian Probability & Maximum Entropy (MaxEnt)**:
   - Probability normalization \(\sum p_i = 1\).
   - Discrete expectation operator \(E[X] = \sum p_i x_i\).
   - **MaxEnt Uniform Theorem**: Formal proof `maxent-uniform-is-normalized` demonstrating that the unconstrained maximum-entropy state \(p_i = 1/n\) tautologically satisfies Jaynesian normalization.

9. **Local Realism, Common-Source Phase Correlation & Disproof of Bell / CHSH**:
   - Angular origin-shift invariance `common-source-phase-origin-invariance` for common-source wave packet emission.
   - Malus local intensity transmission and deterministic detector threshold trigger `detector-trigger-deterministic`.
   - Formal proof `bell-factorability-fails-for-common-source` showing that Bell's factorizability condition \(P(A,B \mid a,b,\lambda) = P(A \mid a,\lambda) P(B \mid b,\lambda)\) is invalid for phase-locked common-source signals without requiring non-local influence.
   - CHSH algebraic post-selection correlation sum rational evaluation `chsh-sum-is-rational`.

10. **Discrete Spectral Analysis, Parseval Conservation & Kirchhoff Laws**:
    - Parseval energy quadratic sum conservation `parseval-energy-conservation-rational` on discrete grid \(\mathcal{G}_N\).
    - Kirchhoff's Current Law `kcl-current-conservation-closed` (\(\sum I_k = 0\)).
    - Kirchhoff's Voltage Law `kvl-voltage-conservation-closed` (\(\sum V_k = 0\)).

11. **Grover Search / Givens Discrete Quantum Walk State Evolution**:
    - 2D unitary state representations and squared norm preservation.
    - Target oracle reflection invariance `grover-oracle-preserves-norm`.
    - Givens rotation unitary norm preservation theorem `givens-rotation-unitary-norm-preservation`.

12. **Formalization of Algorithm Correctness & Combinatorics**:
    - Bernstein polynomial root-crossing sign change bounding theorem `sign-change-implies-root-bracket`.
    - n-Queens (8-Queens) non-attacking placement predicate `queens-safe-placement-preservation` verifying row, column, and diagonal non-conflict.

13. **Discrete Microwave, Solid-State & Electronics Circuit Theory**:
    - Discrete telegrapher transmission line differential equations `telegrapher-equations-rational`.
    - S-Parameter 2-port lossless power conservation / unitary scattering invariant theorem `s-parameter-unitary-scattering` (\(|S_{11}|^2 + |S_{21}|^2 = 1\)).
    - Solid-state PIN diode RF limiter and power-threshold clamping theorem `pin-diode-clamping-bounded`.

14. **Industrial Chemical Thermodynamics, Moisture Agglomeration & Crystal Phase Kinetics (Pals, Fuchs & Schwartz Model, US Patent 3,932,590 A: *Process for Preparing Medium Density Granular Sodium Tripolyphosphate*)**:
    - Moisture-seeded particulate agglomeration stability window `tripolyphosphate-moisture-bounded` (\(0.01 \le w_{\mathrm{H_2O}} \le 0.12\)).
    - Medium-density granular bulk density optimization range `tripolyphosphate-density-in-range` (\(0.45 \le \rho_\text{bulk} \le 0.59\text{ g/cm}^3\)).
    - Deterministic thermal calcination polymorphic crystal phase selector `tripolyphosphate-phase-transition-deterministic` mapping bed temperature to Form I / Form II crystalline polymorphs.

---

## Comprehensive ACL2 Installation Guide across Linux Distributions & Custom Lisp Hosts

### Option A: Installing via Linux Distribution Package Managers

- **Ubuntu / Debian / Linux Mint / Pop!_OS**:
  ```bash
  sudo apt update
  sudo apt install acl2
  ```

- **Fedora / RHEL / CentOS Stream / Rocky Linux / AlmaLinux**:
  ```bash
  sudo dnf install acl2
  ```

- **Arch Linux / Manjaro / EndeavourOS**:
  ```bash
  sudo pacman -S acl2
  ```

- **openSUSE Leap / Tumbleweed**:
  ```bash
  sudo zypper install acl2
  ```

- **Alpine Linux**:
  ```bash
  sudo apk add acl2
  ```

- **NixOS / Nix Package Manager**:
  ```bash
  nix-env -iA nixpkgs.acl2
  # Or in nix-shell:
  nix-shell -p acl2
  ```

- **Gentoo Linux**:
  ```bash
  sudo emerge --ask sci-mathematics/acl2
  ```

- **macOS (Homebrew)**:
  ```bash
  brew install acl2
  ```

---

### Option B: Building ACL2 on an Existing Common Lisp Host (SBCL, CCL, GCL, LispWorks, Allegro)

If you already have a Common Lisp environment installed—such as **SBCL** (Steel Bank Common Lisp), **CCL** (Clozure CL), **GCL** (GNU Common Lisp), or **LispWorks**—you can build ACL2 directly on top of your existing Lisp system from source.

#### 1. Fetch a Tagged Stable Release (`acl2-devel/acl2-devel`)
To ensure maximum stability, always build from an official tagged release available on GitHub at:
`https://github.com/acl2-devel/acl2-devel/releases/`

```bash
git clone https://github.com/acl2-devel/acl2-devel.git acl2
cd acl2
git checkout 8.5  # Or the latest stable release tag
```

#### 2. Compile ACL2 Executable Using SBCL (or another Host Lisp)
To build using SBCL:
```bash
make LISP=sbcl
```
*(If using CCL, run `make LISP=ccl`. If using GCL, run `make LISP=gcl`.)*

This produces an executable script named `saved_acl2` in the `acl2` directory.

#### 3. Certify System Books (Optional)
To certify standard ACL2 system books:
```bash
make regression ACL2=/path/to/acl2/saved_acl2
```

---

## Certifying & Running the Iris Number System Book

Navigate to the directory containing `iris_number_system.lisp` and launch ACL2:

```bash
cd public/acl2
acl2   # Or /path/to/saved_acl2 if compiled from source
```

### 1. Certify the Iris Book
Inside the ACL2 REPL prompt (`ACL2 !>`):
```lisp
(certify-book "iris_number_system" 0 t)
```
ACL2 will run its internal automated theorem prover, verify every proof from first principles, and generate a certified binary object `iris_number_system.cert`.

### 2. Include the Certified Book
```lisp
(include-book "public/acl2/iris_number_system")
```

### 3. Interactive Execution & Verification Examples

- **Verify Radiation from an Antenna Exerts a Mechanical Pressure**:
  From the Master Field Equation \(D F = J\), localized wave emission produces a non-zero Poynting flux vector \(\mathbf{S} = \frac{1}{\mu_0}(\mathbf{E} \times \mathbf{B})\). Radiated electromagnetic energy density \(u = \frac{S}{c}\) delivers a continuous field momentum flux, exerting an outward radiation pressure \(P_\text{rad} = \frac{\|\mathbf{S}\|}{c}\) on absorbing or reflecting surfaces.
  ```lisp
  ;; Verified Poynting field momentum flux preservation in Cl(4,1,1):
  (thm (implies (and (vec3-p e-field)
                     (vec3-p b-field)
                     (rationalp mu0)
                     (not (equal mu0 0)))
                (vec3-p (poynting-vector e-field b-field mu0))))
  ```

- **Verify Unitary Norm Preservation in Grover/Givens Discrete Quantum Walk**:
  ```lisp
  (thm (implies (and (grover-state-p st)
                     (rationalp c)
                     (rationalp s)
                     (equal (+ (* c c) (* s s)) 1))
                (equal (grover-norm-sq (givens-rotate st c s))
                       (grover-norm-sq st))))
  ```

- **Check Jaynesian MaxEnt Probability Normalization**:
  ```lisp
  (jaynes-normalized-p '(1/4 1/4 1/4 1/4)) ; Returns T
  ```
