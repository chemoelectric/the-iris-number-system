# ACL2 Book: The Iris Number System & Unified Field Theory

This ACL2 book provides a **machine-checked formalization** of the **Iris Number System** and the **Unified Field Theory**. 

Because ACL2 is an automated interactive theorem prover created at UT Austin and recipient of the ACM Software System Award, every definition in this book is statically checked, and every theorem is verified by algorithmic proof. This eliminates any possibility of "AI hallucinations" or informal hand-waving.

---

## What is Formally Verified in This Book?

1. **Multiscale Resolution Analysis (MSRA)**:
   - Discrete grid step resolution $\delta_\omega = 1 / \omega$.
   - Ring homomorphism of the Main Scale Projection operator $(\downarrow)$.
   - Discrete vernier differential operator $\frac{d\Psi}{dx} = (\downarrow) \left( \frac{\Psi(x + \delta_\omega) - \Psi(x)}{\delta_\omega} \right)$.

2. **Clifford $Cl(4,1,1)$ Master Field Equation ($D F = J$)**:
   - Master Field gradient operator $D = \nabla + e_4 \frac{1}{c} D_t$.
   - Linearity and componentwise structural closure.

3. **Gauss's Gravitational Field Law & Newton's Gravity**:
   - Machine-checked deduction showing that the scalar field current component of $D F = J$ exacts Gauss's gravitational flux law: $\nabla \cdot \mathbf{g} = 4 \pi G \rho$.

4. **Newton's Laws of Motion**:
   - Discrete momentum formulation $p = m \cdot v$.
   - **Newton's First Law (Inertia)**: Formal proof `newton-first-law-inertia` demonstrating that zero net force implies constant velocity.
   - **Newton's Second Law ($F = m a$)**: Formal proof `newton-second-law-f-equals-ma` deriving $F = m \cdot \frac{v_2 - v_1}{\Delta t}$.

5. **Euclidean Geometry Tautologies**:
   - Squared metric distance on discrete rational grids $\mathcal{G}_\omega$.
   - **Pythagorean Theorem**: Formal proof `pythagorean-theorem-grid` establishing $c^2 = a^2 + b^2$ algebraically without continuum assumptions.

6. **Jaynesian Probability & Maximum Entropy (MaxEnt)**:
   - Probability normalization $\sum p_i = 1$.
   - Discrete expectation operator $E[X] = \sum p_i x_i$.
   - **MaxEnt Uniform Theorem**: Formal proof `maxent-uniform-is-normalized` demonstrating that the unconstrained maximum-entropy state $p_i = 1/n$ tautologically satisfies Jaynesian normalization.

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

You can either download a tarball from the releases page or clone and checkout a release tag directly:

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

#### 3. Certify System Books (Optional, Long Process)
To certify all standard ACL2 system books using SBCL (note: certifying the entire system library is comprehensive and takes significant compute time):
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

- **Verify Newton's First Law of Motion (Inertia)**:
  ```lisp
  (thm (implies (and (rationalp mass)
                     (not (equal mass 0))
                     (rationalp v1)
                     (rationalp v2)
                     (rationalp dt)
                     (not (equal dt 0))
                     (equal (force-from-momentum-change mass v1 v2 dt) 0))
                (equal v1 v2)))
  ```
  ACL2 outputs `Q.E.D.`, proving the theorem mechanically.

- **Check Jaynesian MaxEnt Probability Normalization**:
  ```lisp
  (jaynes-normalized-p '(1/4 1/4 1/4 1/4)) ; Returns T
  ```
