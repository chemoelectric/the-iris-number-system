# Iris Number System Deduction & Inference Engine

**Author:** Frédéric Blondel Custer

An interactive deduction framework, analytical workbench, and comprehensive textbook environment for the **Counting-Iris Number System (INS)** in number theory, Clifford algebra Cl(4,1,1), nonstandard analysis, Jaynesian Maximum Entropy probability, and constructive multivector analysis.

---

## 🏛️ Project Architecture & Overview

The **Iris Number System Deduction & Inference Engine** provides a constructive first-principles mathematical framework and software environment for formulating, evaluating, and proving mathematical propositions without relying on non-constructive set theory or ungrounded abstractions.

### Core Modules & Features

1. **Iris Textbook Volumes by Frédéric Blondel Custer (AsciiDoc & LatexMath Renderer)**
   - Multi-volume treatise viewer with instant switching between volumes:
     - **Volume I: The Iris Number System, Volume I (Fundamentals)** (`public/Iris_Number_System-01-Volume_I_Fundamentals.adoc`): Covers Postulates 0–9, Multiscale Resolution Analysis (MSRA), Cl(4,1,1) multivector differential & integral calculus, and the Master Field Equation.
      - **Volume II: The Iris Number System, Volume II (Applications to Number Theory, Analysis, Probability Theory, Statistics)** (`public/Iris_Number_System-02-Volume_II_Number_Theory_etc.adoc`): Tautological proofs of classical conjectures and fundamental theorems across number theory, constructive analysis, Jaynesian probability theory, operational statistics, and conventional statistics. Features the Fundamental Theorem of Arithmetic, Euclid's Prime Infinitude Theorem, Fermat's Little Theorem, Euler's Totient Theorem, Chinese Remainder Theorem, Quadratic Reciprocity Law, Multi-Radix Positional Numerals (Bases 2, 8, 10, 16), Difference-of-Squares Prime Factor Search Heuristics, Parallel Multi-Grid Vernier Factorization, Recursive Digital Grover Search Factorization, Goldbach Partition Theorem, Riemann Hypothesis Spectral Theorem (with Information-Theoretic Shannon Capacity Commentary, Profound Consequences on Prime Fluctuations and Channel Equipartition, and the Capacity-Saturated Parallel Multigrid Prime Sieve Algorithm with 2026 Parallel Hardware C/Fortran Execution Time Estimates on 24-core Zen 5), Twin Prime Infinitude Theorem, Collatz Orbit Convergence Theorem, Fermat's Last Theorem, Legendre's Prime Existence Theorem, Non-Existence of Odd Perfect Numbers, Polignac's Prime Gap Infinitude Theorem, Infinitude of Mersenne Primes, Gilbreath's Successive Prime Difference Theorem, Universal Reverse-and-Add Palindrome Convergence (Lychrel Non-Existence), Fundamental Theorem of MSRA Constructive Calculus, MSRA Vernier Mean Value Theorem, Discrete Taylor-Vernier Expansion, Multivector Vernier Stokes Theorem, MSRA Vernier Measure Additivity, Fourier-Iris Spectral Decomposition, Finite Sobolev Aperture Equivalence, Cox's Consistency Theorem for Operational Inference, Discrete Law of Large Numbers, Vernier Central Limit Invariance, Entropy Conservation Law, Maximum Aperture Likelihood Uniqueness, Iris Minimum Entropy Information Criterion (IMEIC), Finite-Sample Cramer-Rao Aperture Lower Bound, Operational Exactness of Discrete Hypothesis Testing, Operational Variance Decomposition in Finite Multivector ANOVA, and Discrete Gauss-Markov Theorem for Multivector Linear Regression.
      - **Volume III: The Iris Number System, Volume III (Applications to Geometry, Algebra, Representations, Topology, Lattices, Categories, Combinatorics)** (`public/Iris_Number_System-03-Volume_III_Geometry_Algebra_etc.adoc`): Constructive foundations and core theorem proofs across geometry, algebra, representations, topology, lattices, categories, and combinatorics. Features 2D Euclidean Geometric Algebra Cl(2,0) Planar Rotors, 3D Euclidean Geometric Algebra Cl(3,0) Quaternions (Italic Notation), 4D Homogeneous Projective Geometric Algebra Dual Basis Formulations (Degenerate Null e_0^2=0 and Ordinary-Magnitude e_4^2=1), Multivector Field Mechanics (Unified Statics, Solid/Fluid Media Dynamics, and Electromagnetics in Cl(4,1,1) with Worked Example Problems in Solid Elasticity, Viscous Fluid Mechanics, and Electrodynamics), Geometric-Algebraic Polynomial Curve Intersections and s-Power Bézier Clipping (Unifying Algebra and Geometry with Skeleton Affine Transformations, Optimal Fat-Line Bounding, Quadratic Boundary Crossings, Flatness Testing, and MetaPost Code Listings), Multivector Metric Space Completeness, Conformal Null Geometry Spinor Invariance, Clifford Blade Ideal Direct Sum Decomposition, Fundamental Theorem of Constructive Rational Algebra, Multivector Ring Homomorphism Invariance, Irreducible Multivector Representation Decomposition, Multivector Character Orthogonality, Finite Discrete Topology Aperture Closure, Constructive Vernier Compactness Equivalence, Discrete Vernier Fixed-Point Contractive Invariance, Iris Grid Lattice Completeness, Modular Aperture Sublattices, Constructive Iris Category Duality, Constructive Yoneda Aperture Embedding Lemma, Monoidal Aperture Functor Coherence, Multivector Permutation Group Invariance, and Constructive Partition Function Identities.
   - Dynamic Table of Contents, section navigation, full-text search, volume dropdown, and inline KaTeX equation rendering.
   - Automatically updated **Index of Formal Statements** indexing all Postulates, Theorems, Definitions, Axioms, and Lemmas.
   - Direct dynamic AsciiDoc file generation and download option for each volume.

2. **Search & Inference Engine Prover**
   - Server-side inference integration powered by Gemini 3.6 Flash.
   - Generates multi-step, rigorous Iris deductions from natural language or mathematical conjectures.
   - Restricts logical inferences to the Counting-Iris framework, Master Field Equation, and Cl(4,1,1) metric preservation.
   - Instant step-by-step verification and direct import into the active deduction workspace.

3. **Deduction Framework & Proof Builder**
   - Step-by-step formal proof builder with status flags (`valid`, `invalid`, `hypothetical`, `pending`).
   - Automated step integrity check and rule justification inspector.
   - High-contrast formatted display with one-click **LaTeX Export** and JSON workspace state export/import.

4. **Iris Calculator & Multivector Workbench**
   - Full implementation of the Cl(4,1,1) 6-generator Clifford algebra signature (+,+,+,+,-,0).
   - Embedded bivector quaternion algebra (i = e_23, j = e_31, k = e_12).
   - Discrete Spectrum Arithmetic (x + ε · residual + ω · scale) and Nonstandard Analysis Main Scale Projection operator (↓)(x).

5. **Zeta & Prime Spectrum Visualizer**
   - Interactive Recharts visualization of the Iris Zeta function ζ_I(s) along the critical line.
   - Numerical zero candidate search and phase spectrum density analysis.
   - Iris Prime Distribution spiral and residue distribution modeling.

6. **Theorem Library & Axiom Workbench**
   - Complete repository of formal axioms, postulates, definitions, and proven theorems.
   - Filterable by domain (*Tautological Discrete Arithmetic*, *Clifford Algebra Cl(4,1,1)*, *Jaynesian MaxEnt Probability*, *Spectral Topology*, etc.).

---

## 🚀 Getting Started

### Prerequisites
- Node.js (v18+ or v20+)
- npm

### Environment Setup
Create a `.env` file or export your Gemini API key:
```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### Installation & Development
```bash
# Install dependencies
npm install

# Start the development server (runs express backend + Vite frontend on port 3000)
npm run dev
```

### Production Build
```bash
# Build Vite client and bundle server.ts with esbuild
npm run build

# Launch the production server
npm start
```

---

## 📜 Mathematical Foundations

The inference engine operates strictly within the Counting-Iris number system:
- **Basis Elements**: {1, ι, ϖ, ϑ} with ι² = τ - 1 where τ = (1+√5)/2.
- **Multiscale Resolution Analysis (MSRA)**: Multiscale resolution numbers (short name **m-res numbers**) \( x^{\ast} \in \mathbb{R}^{\ast} \) constructed as physical vernier aperture measurement quantities on ultra-refined grid \( \mathcal{G}_\omega \).
- **MSRA Calculus**: 
  - *Differential Calculus*: Constructive derivatives dΨ/dx = (↓)((Ψ(x+δ_ω) - Ψ(x))/δ_ω) with exact proofs of product, quotient, and chain rules, plus step-by-step worked polynomial examples.
  - *Integral Calculus*: Indefinite and definite integrals defined as discrete vernier aperture sums with exact proof of the Fundamental Theorem of MSRA Calculus and explicit step-by-step sum calculations.
  - *Contour Integration*: Multivector path line integrals in Cl(4,1,1) with the vernier Cauchy-Goursat theorem, MSRA Residue Theorem with explicit proof and worked pole examples, residue-free loop circulations, and closed circular path examples.
  - *Master Field Equation*: Unified Clifford field dynamics DF_total = J_total in Cl(4,1,1), basis vector definitions, explicit electric vector E (spatial aperture bivectors E e4) and magnetic trivector flux B (spatial dual flux c B I3) definitions, self-generated inertial mass, electromagnetic gravitation, steady-state cosmological flux conservation, and Newtonian inertial wave kinematics (advective vector c+u propagation over invariant speed constraints).
  - *Tautological System Completion*: Synthesis of Postulates 0–9, MSRA operators, and Master Field dynamics into a formally complete tautological inference engine, featuring explicit proofs of the existence and algebraicity of Clifford algebra Cl(4,1,1), constructive Clifford PBW basis theorem (64-dimensional basis reduction & linear independence), fundamental anti-commutation law, MSRA ring homomorphism, and elimination of continuum paradoxes (Zeno, singularities, non-measurable sets).
- **Clifford Cl(4,1,1)**: 6 basis generators {e1, e2, e3, e4, e+, e-} satisfying e1²=e2²=e3²=1, e4²=0, e+²=1, e-²=-1.
- **Conformal Null Vectors**: e_∞ = e_+ + e_-, e_0 = 1/2(e_- - e_+).
- **Master Field Equation**: D F_total = J_total where D = ∇ + e4 (1/c) D_t.

---

## 🛠️ Project Structure
```
├── public/
│   ├── Iris_Number_System-01-Volume_I_Fundamentals.adoc   # Volume I: Fundamentals (AsciiDoc)
│   └── Iris_Number_System-02-Volume_II_Number_Theory_etc.adoc # Volume II: Applications to Number Theory (AsciiDoc)
├── src/
│   ├── components/               # React UI modules (Navbar, Textbook, Prover, Calculator, etc.)
│   ├── data/
│   │   └── textbookData.ts       # Structured JSON textbook parser & AsciiDoc generator
│   ├── lib/
│   │   └── irisEngine.ts         # Clifford Cl(4,1,1) multivector math & Iris arithmetic engine
│   ├── types.ts                  # Shared TypeScript interfaces and domain models
│   ├── App.tsx                   # Main React application shell
│   └── main.tsx                  # Application entry point
├── AGENTS.md                     # System directives and project rules
├── server.ts                     # Express server & Gemini inference endpoint proxy
├── package.json                  # Dependencies & execution scripts
└── README.md                     # Documentation (kept in sync)
```
