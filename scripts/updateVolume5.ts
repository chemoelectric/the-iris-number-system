import fs from 'fs';
import path from 'path';

// Read textbookData.ts
const filePath = path.join(process.cwd(), 'src/data/textbookData.ts');
let content = fs.readFileSync(filePath, 'utf8');

// Find where PHYSICS_CHEMISTRY_TEXTBOOK ends
const endPhysicsIdx = content.indexOf('  "filename": "Iris_Number_System-04-Volume_IV_Physics_etc.adoc"\n};');

if (endPhysicsIdx === -1) {
  console.error("Could not find end of PHYSICS_CHEMISTRY_TEXTBOOK");
  process.exit(1);
}

const beforePart = content.slice(0, endPhysicsIdx + '  "filename": "Iris_Number_System-04-Volume_IV_Physics_etc.adoc"\n};'.length);

const sec1Content = [
  "=== The Fallacy of the Continuum Complex Plane and Real Bivector Kinematics",
  "",
  "In 19th and 20th-century mathematical analysis and electrical engineering, linear signal processing was built upon the algebraic convention of the “complex plane” \\( \\mathbb { C } \\) and the imaginary unit \\( i = \\sqrt { - 1 } \\). While computationally effective as an algorithmic shorthand for handling two-dimensional rotations and phase shifts, the conventional interpretation of \\( \\mathbb { C } \\) introduced major epistemological and ontological fallacies:",
  "",
  "1. **The Continuum Fallacy of Imaginary Quantities**:",
  "   Conventional analysis treats \\( i \\) as an abstract, non-physical scalar existing outside the real number line, operating over an uncountably infinite continuum of complex values. In the actual conduct of science and engineering, there are no imaginary quantities or continuum infinities; physical observations consist of measurements over discrete spatial-temporal resolution grids \\( \\mathcal { G } _ N \\). Examples include voltages, currents, temperatures, pressures, lengths, angles, etc.",
  "",
  "2. **Geometric Interpretation: Unit Oriented Bivectors**:",
  "   In real Geometric Algebra, the algebraic entity satisfying \\( \\mathbf { I } ^ 2 = - 1 \\) is not an imaginary scalar, but a real, oriented **unit bivector** \\( \\mathbf { I } \\) representing an oriented 2D plane segment. In a two-dimensional real space \\( \\mathbb { R } ^ 2 \\) spanned by orthogonal unit vectors \\( e _ 1, e _ 2 \\) (with \\( e _ 1 ^ 2 = 1 \\), \\( e _ 2 ^ 2 = 1 \\)), the unit bivector is defined by the geometric product:",
  "   \\[ \\mathbf { I } = e _ 1 e _ 2 = e _ 1 \\wedge e _ 2 \\]",
  "   By the fundamental anti-commutativity of orthogonal vectors (\\( e _ 1 e _ 2 = - e _ 2 e _ 1 \\)), computing the square of \\( \\mathbf { I } \\) yields a purely real result:",
  "   \\[ \\mathbf { I } ^ 2 = ( e _ 1 e _ 2 ) ( e _ 1 e _ 2 ) = - e _ 1 ( e _ 1 e _ 2 ) e _ 2 = - ( e _ 1 e _ 1 ) ( e _ 2 e _ 2 ) = - 1 \\]",
  "   Multiplying a real vector \\( \\mathbf { v } = v _ 1 e _ 1 + v _ 2 e _ 2 \\) by \\( \\mathbf { I } \\) rotates \\( \\mathbf { v } \\) by \\( 90 ^ \\circ \\) in the \\( e _ 1 \\wedge e _ 2 \\) plane. Thus, Euler’s relation \\( e ^ { \\mathbf { I } \\theta } = \\cos \\theta + \\mathbf { I } \\sin \\theta \\) is an exact real geometric rotor that precesses real vectors in a real two-dimensional subspace, removing the need for imaginary numbers or complex planes.",
  "",
  "3. **Sufficiency of Lightweight Geometric Algebras**:",
  "   While field dynamics on discrete multiscale resolution grids is fully described by the 64-dimensional Clifford Algebra \\( Cl ( 4 , 1 , 1 ) \\) under the Master Field Equation \\( D F = J \\), planar signal analysis requires far lighter geometric structures. For example:",
  "   * **The One-Dimensional Clifford Algebra \\( Cl ( 0 , 1 ) \\)**: Spanned by a single generator \\( e _ 1 \\) with \\( e _ 1 ^ 2 = - 1 \\). Elements are real linear combinations \\( a + b e _ 1 \\). This algebra is naturally isomorphic to \\( \\mathbb { C } \\) as a vector space, but every term remains a purely real multivector.",
  "   * **The Two-Dimensional Clifford Algebra \\( Cl ( 2 , 0 ) \\)**: Spanned by real orthogonal vectors \\( e _ 1, e _ 2 \\) with \\( e _ 1 ^ 2 = 1, e _ 2 ^ 2 = 1 \\). The even subalgebra \\( Cl ^ + ( 2 , 0 ) \\) consists of elements \\( a + b e _ { 1 2 } \\), providing a complete, coordinate-free real geometric phase plane.",
  "   * **The Three-Dimensional Euclidean Geometric Algebra \\( Cl ( 3 , 0 ) \\)** (often designated as the Spatial Vector Algebra): Spanned by three spatial basis vectors \\( e _ 1, e _ 2, e _ 3 \\), avoiding relativistic continuum assumptions and frames of reference. In this algebra, the pseudoscalar \\( \\mathbf { I } = e _ 1 e _ 2 e _ 3 \\) satisfies \\( \\mathbf { I } ^ 2 = - 1 \\) and commutes with all grade elements, serving as an intrinsic 3D phase-rotation operator.",
  "",
  "4. **Matrix Operator Representation without Geometric Algebra**:",
  "   Even without Geometric Algebra, any digital signal vector \\( \\mathbf { x } = [ x [ 0 ] , x [ 1 ] , \\dots , x [ N - 1 ] ] ^ T \\in \\mathbb { R } ^ N \\) on a finite resolution grid \\( \\mathcal { G } _ N \\) can be processed using purely real orthogonal matrix operators. The bivector rotation operator \\( \\mathbf { I } \\) maps directly to the real anti-symmetric block generator matrix:",
  "   \\[ J = \\begin {pmatrix} 0 & - 1 \\\\ 1 & 0 \\end {pmatrix} \\]",
  "   satisfying \\( J ^ 2 = - I _ 2 \\). Consequently, all classical transforms can be executed as real matrix-vector operations on real physical analog or digital signal channels."
].join("\n");

const sec2Content = [
  "=== Unified Operator Kernel Formulation for Conventional Transforms",
  "",
  "Let \\( \\mathcal { G } _ N = \\{ n \\delta \\mid n \\in \\{ 0 , 1 , \\dots , N - 1 \\} \\} \\) be a discrete multiscale spatial-temporal grid with uniform step spacing \\( \\delta \\). Every major conventional linear transform—including the Fourier, Cosine, Sine, Hartley, Laplace, Z, Mellin, Hankel, Radon, and Wavelet transforms—is a specific projection or specialization of a single **Universal Discrete Kernel Operator** \\( \\mathcal { K } _ { \\mathcal { G } _ N } [ n , k ] \\) defined over \\( \\mathcal { G } _ N \\):",
  "",
  "\\[ \\mathcal { K } _ { \\mathcal { G } _ N } [ n , k ] = r [ k ] ^ n \\left( \\cos \\left( \\frac { 2 \\pi n k } { N } \\right) + \\mathbf { I } \\sin \\left( \\frac { 2 \\pi n k } { N } \\right) \\right) \\]",
  "",
  "where \\( r [ k ] > 0 \\) is a real radial scaling factor, \\( \\theta _ k = \\frac { 2 \\pi k } { N } \\) is the discrete fundamental phase angle step, and \\( \\mathbf { I } \\) is an oriented unit bivector satisfying \\( \\mathbf { I } ^ 2 = - 1 \\).",
  "",
  "The unified transformation of a real analog or digital signal \\( x [ n ] \\) into its multivector spectral representation \\( \\hat { X } [ k ] \\) is given by the finite inner product on \\( \\mathcal { G } _ N \\):",
  "",
  "\\[ \\hat { X } [ k ] = \\sum _ { n = 0 } ^ { N - 1 } x [ n ] \\mathcal { K } _ { \\mathcal { G } _ N } [ n , k ] \\delta \\]",
  "",
  "==== Canonical Unification Mapping of Conventional Transforms",
  "",
  "1. **Discrete Fourier Transform (DFT) and Fourier Series**:",
  "   Setting \\( r [ k ] = 1 \\) for all \\( k \\) reduces the Universal Kernel to the pure phase rotor \\( \\mathcal { K } _ \\text{DFT} [ n , k ] = \\cos \\left( \\frac { 2 \\pi n k } { N } \\right) + \\mathbf { I } \\sin \\left( \\frac { 2 \\pi n k } { N } \\right) \\). The scalar component \\( \\operatorname { Sc } ( \\hat { X } [ k ] ) \\) isolates the even (cosine) harmonic spectrum, while the bivector component \\( \\operatorname { Biv } ( \\hat { X } [ k ] ) \\) isolates the odd (sine) harmonic spectrum.",
  "",
  "2. **Discrete Cosine Transform (DCT) and Discrete Sine Transform (DST)**:",
  "   Taking the real scalar projection \\( \\operatorname { Sc } ( \\mathcal { K } _ { \\mathcal { G } _ N } ) \\) or bivector projection \\( \\operatorname { Biv } ( \\mathcal { K } _ { \\mathcal { G } _ N } ) \\) under grid boundary shifts (e.g., half-step grid offsets \\( n \\to n + \\frac { 1 } { 2 } \\)) yields the standard discrete orthogonal cosine (DCT-II) and sine (DST-II) transforms:",
  "   \\[ X _ \\text{DCT} [ k ] = \\sum _ { n = 0 } ^ { N - 1 } x [ n ] \\cos \\left( \\frac { \\pi k ( 2 n + 1 ) } { 2 N } \\right) \\delta \\]",
  "   \\[ X _ \\text{DST} [ k ] = \\sum _ { n = 0 } ^ { N - 1 } x [ n ] \\sin \\left( \\frac { \\pi ( k + 1 ) ( 2 n + 1 ) } { 2 N } \\right) \\delta \\]",
  "",
  "3. **Hartley Transform**:",
  "   Summing the scalar and bivector components directly into a single real scalar value via the kernel operator \\( cas ( \\theta ) = \\cos \\theta + \\sin \\theta \\) yields the Hartley transform:",
  "   \\[ X _ \\text{Hartley} [ k ] = \\sum _ { n = 0 } ^ { N - 1 } x [ n ] \\left[ \\cos \\left( \\frac { 2 \\pi n k } { N } \\right) + \\sin \\left( \\frac { 2 \\pi n k } { N } \\right) \\right] \\delta \\]",
  "   Because \\( cas ( \\theta ) \\) is purely real and self-inverse, it performs complete spectral analysis without requiring bivector decomposition or complex algebra.",
  "",
  "4. **Laplace Transform**:",
  "   Generalizing the radial factor to represent real exponential spatial-temporal decay \\( r [ k ] = e ^ { - \\sigma [ k ] \\delta } \\) and angular phase precession \\( \\theta _ k = \\omega [ k ] \\delta \\) yields the Laplace transform kernel operator with \\( s = \\sigma + \\mathbf { I } \\omega \\):",
  "   \\[ \\mathcal { K } _ \\text{Laplace} ( t_n , s_k ) = e ^ { - s_k t_n } = e ^ { - \\sigma _ k t_n } \\left( \\cos ( \\omega _ k t_n ) - \\mathbf { I } \\sin ( \\omega _ k t_n ) \\right) \\]",
  "   This represents simultaneous physical energy dissipation into the surrounding grid lattice and bivector phase precession in real phase space.",
  "",
  "5. **Z-Transform**:",
  "   The discrete grid counterpart of the Laplace transform, where the discrete variable \\( z = r e ^ { \\mathbf { I } \\theta } = r ( \\cos \\theta + \\mathbf { I } \\sin \\theta ) \\) represents a real bivector rotor combined with a radial expansion or contraction factor \\( r \\). The inverse kernel \\( z ^ { - n } = r ^ { - n } ( \\cos ( n \\theta ) - \\mathbf { I } \\sin ( n \\theta ) ) \\) decomposes discrete time-series onto radial decay rings and angular precessions over \\( \\mathcal { G } _ N \\).",
  "",
  "6. **Mellin Transform**:",
  "   Mapping the spatial-temporal index logarithmically onto a discrete radial grid \\( n = e ^ u \\) transforms scale-dilation operators into linear phase shifts, yielding scale-invariant power spectrum analysis.",
  "",
  "7. **Hankel (Bessel) Transform**:",
  "   Representing the 2D spatial Fourier transform under rotational symmetry in a bivector plane \\( e _ 1 \\wedge e _ 2 \\). Integrating the bivector phase rotor over all polar angles \\( \\phi \\) yields real zero-order Bessel functions \\( J _ 0 ( k r ) \\) as orthogonal radial eigenfunctions over discrete circular apertures.",
  "",
  "8. **Radon Transform**:",
  "   Projecting 2D spatial mass or field distributions along directional line apertures on a 2D discrete grid \\( \\mathcal { G } _ N \\), mapping spatial structures into projection angles \\( \\theta \\) and radial offsets \\( s \\).",
  "",
  "9. **Wavelet Transform**:",
  "   Applying localized multiscale bandpass windowing \\( \\psi _ { a , b } [ n ] = \\frac { 1 } { \\sqrt { a } } \\psi \\left( \\frac { n \\delta - b } { a } \\right) \\) to the discrete kernel, providing joint spatial-temporal and spectral-resolution localization over multiscale grid tiers.",
  "",
  "10. **Hilbert Transform**:",
  "    Applying a quadrature phase-shift operator that rotates every bivector component by \\( 90 ^ \\circ \\) (multiplying by \\( \\mathbf { I } \\)), converting scalar cosine modes into bivector sine modes to generate analytic real signal pairs.",
  "",
  "11. **Homomorphic Cepstral Analysis**:",
  "    Evaluating the real natural logarithm of the bivector spectral magnitude \\( \\| \\hat { X } [ k ] \\| = \\sqrt { ( \\operatorname { Sc } ( \\hat { X } [ k ] ) ) ^ 2 + ( \\operatorname { Biv } ( \\hat { X } [ k ] ) ) ^ 2 } \\) yields a purely real logarithmic scalar sequence \\( L [ k ] = \\ln ( \\| \\hat { X } [ k ] \\| ) \\). Inverse-transforming \\( L [ k ] \\) back to the spatial-temporal grid via the real cosine kernel maps multiplicative system operations (such as lattice echo reflections or vocal tract filtering) into additive linear components in the discrete quefrency domain \\( q \\in \\mathcal { G } _ N \\), completely avoiding complex logarithms and multi-valued phase branch cuts."
].join("\n");

const sec3Content = [
  "=== Rigorous Proofs and Mathematical Theorems",
  "",
  "[#theorem-unified-real-bivector-spectral-transformation]",
  "[THEOREM]",
  ".Theorem: Unified Real-Bivector Spectral Transformation Theorem",
  "====",
  "Let \\( \\mathcal { G } _ N = \\{ n \\delta \\mid n \\in \\{ 0 , 1 , \\dots , N - 1 \\} \\} \\) be a finite discrete spatial-temporal resolution grid, and let \\( x [ n ] \\in \\mathbb { R } \\) be a real-valued digital or m-res signal.",
  "",
  "Every conventional linear integral and discrete transform (Fourier, Cosine, Sine, Hartley, Laplace, Z, Mellin, Hankel, Radon, and Wavelet) is an exact specialization or projection of the Universal Discrete Kernel Operator:",
  "\\[ \\mathcal { K } _ { \\mathcal { G } _ N } [ n , k ] = r [ k ] ^ n \\left( \\cos \\left( \\frac { 2 \\pi n k } { N } \\right) + \\mathbf { I } \\sin \\left( \\frac { 2 \\pi n k } { N } \\right) \\right) \\]",
  "where \\( r [ k ] > 0 \\) is a real radial scaling factor, \\( \\mathbf { I } \\) is a real unit bivector generator satisfying \\( \\mathbf { I } ^ 2 = - 1 \\), and no complex plane or imaginary numbers are required.",
  "",
  "*Proof:*",
  ". **Deconstruction of the Complex Imaginary Generator**:",
  "  In conventional analysis, the kernel is written as \\( e ^ { - i 2 \\pi n k / N } \\). In real Geometric Algebra \\( Cl ( 0 , 1 ) \\) or \\( Cl ( 2 , 0 ) \\), substitute \\( i \\to - \\mathbf { I } \\) where \\( \\mathbf { I } = e _ 1 e _ 2 \\). By Euler’s real geometric identity, \\( e ^ { - \\mathbf { I } \\theta } = \\cos \\theta - \\mathbf { I } \\sin \\theta \\). Every term in the expansion is a linear combination of a real scalar and a real oriented bivector.",
  "",
  ". **Constructive Derivation of Specializations**:",
  "  * **DFT**: Set \\( r [ k ] = 1 \\). Then \\( \\hat { X } [ k ] = \\sum _ { n = 0 } ^ { N - 1 } x [ n ] \\left( \\cos \\left( \\frac { 2 \\pi n k } { N } \\right) - \\mathbf { I } \\sin \\left( \\frac { 2 \\pi n k } { N } \\right) \\right) \\delta \\). Taking the scalar grade \\( \\operatorname { Sc } \\) yields the even cosine spectrum, and taking the bivector grade \\( \\operatorname { Biv } \\) yields the odd sine spectrum.",
  "  * **DCT and DST**: Projections \\( \\operatorname { Sc } ( \\mathcal { K } ) \\) and \\( \\operatorname { Biv } ( \\mathcal { K } ) \\) with grid boundary offset \\( n \\to n + \\frac { 1 } { 2 } \\).",
  "  * **Hartley**: Map the multivector sum \\( \\operatorname { Sc } ( \\mathcal { K } ) + \\mathbf { I } ^ { - 1 } \\operatorname { Biv } ( \\mathcal { K } ) \\to \\cos \\theta + \\sin \\theta = cas ( \\theta ) \\).",
  "  * **Laplace and Z-Transforms**: Set \\( r [ k ] = e ^ { - \\sigma [ k ] \\delta } \\). Then \\( r [ k ] ^ n e ^ { - \\mathbf { I } \\omega [ k ] n \\delta } = e ^ { - ( \\sigma [ k ] + \\mathbf { I } \\omega [ k ] ) n \\delta } = e ^ { - s_k t_n } \\). Setting \\( z_k = e ^ { s_k \\delta } = r [ k ] e ^ { \\mathbf { I } \\theta_k } \\) converts the kernel into \\( z_k ^ { - n } \\).",
  "  * **Mellin, Hankel, Radon, Wavelet**: Mapped by radial coordinate substitution \\( n = e ^ u \\), polar bivector integration \\( \\int _ 0 ^ { 2 \\pi } e ^ { - \\mathbf { I } k r \\cos \\phi } d \\phi = 2 \\pi J _ 0 ( k r ) \\), directional delta-line projections, and multiscale windowing \\( \\psi _ { a , b } [ n ] \\), respectively.",
  "",
  "All operations execute strictly over real scalars, real bivectors, and finite discrete grid sums on \\( \\mathcal { G } _ N \\), proving that complex numbers and continuum planes are completely redundant. \\( \\square \\)",
  "====",
  "",
  "[#theorem-discrete-orthogonality-parseval-energy-conservation]",
  "[THEOREM]",
  ".Theorem: Discrete Multiscale Orthogonality and Parseval-Plancherel Energy Conservation Theorem",
  "====",
  "On the discrete resolution grid \\( \\mathcal { G } _ N = \\{ n \\delta \\mid n \\in \\{ 0 , 1 , \\dots , N - 1 \\} \\} \\), the real bivector Fourier basis elements \\( \\mathcal { E } _ k [ n ] = \\frac { 1 } { \\sqrt { N } } \\left( \\cos \\left( \\frac { 2 \\pi n k } { N } \\right) + \\mathbf { I } \\sin \\left( \\frac { 2 \\pi n k } { N } \\right) \\right) \\) satisfy exact discrete orthogonality:",
  "",
  "\\[ \\sum _ { n = 0 } ^ { N - 1 } \\mathcal { E } _ k [ n ] \\mathcal { E } _ m ^ \\dagger [ n ] = \\delta _ { k , m } \\]",
  "",
  "where \\( \\dagger \\) denotes bivector reversion (\\( \\mathbf { I } ^ \\dagger = - \\mathbf { I } \\)). Furthermore, for any real signal \\( x [ n ] \\), total physical field energy is strictly conserved across domain representations:",
  "",
  "\\[ \\sum _ { n = 0 } ^ { N - 1 } ( x [ n ] ) ^ 2 = \\frac { 1 } { N } \\sum _ { k = 0 } ^ { N - 1 } \\left\\| \\hat { X } [ k ] \\right\\| ^ 2 \\]",
  "",
  "where \\( \\left\\| \\hat { X } [ k ] \\right\\| ^ 2 = \\left( \\operatorname { Sc } ( \\hat { X } [ k ] ) \\right) ^ 2 + \\left( \\operatorname { Biv } ( \\hat { X } [ k ] ) \\right) ^ 2 \\).",
  "",
  "*Proof:*",
  ". **Bivector Basis Orthogonality**:",
  "  Compute the bivector inner product sum for indices \\( k, m \\):",
  "  \\[ \\sum _ { n = 0 } ^ { N - 1 } \\mathcal { E } _ k [ n ] \\mathcal { E } _ m ^ \\dagger [ n ] = \\frac { 1 } { N } \\sum _ { n = 0 } ^ { N - 1 } \\left( \\cos \\frac { 2 \\pi n k } { N } + \\mathbf { I } \\sin \\frac { 2 \\pi n k } { N } \\right) \\left( \\cos \\frac { 2 \\pi n m } { N } - \\mathbf { I } \\sin \\frac { 2 \\pi n m } { N } \\right) \\]",
  "  Expanding the geometric product and using trigonometric product identities:",
  "  \\[ = \\frac { 1 } { N } \\sum _ { n = 0 } ^ { N - 1 } \\left[ \\cos \\left( \\frac { 2 \\pi n ( k - m ) } { N } \\right) + \\mathbf { I } \\sin \\left( \\frac { 2 \\pi n ( k - m ) } { N } \\right) \\right] \\]",
  "  For \\( k = m \\), every term equals \\( 1 + 0 = 1 \\), yielding \\( \\frac { 1 } { N } ( N ) = 1 \\).",
  "  For \\( k \\neq m \\), the sum is a finite geometric series of non-zero phase rotations over a complete period, summing identically to zero. Thus, \\( \\sum _ { n = 0 } ^ { N - 1 } \\mathcal { E } _ k [ n ] \\mathcal { E } _ m ^ \\dagger [ n ] = \\delta _ { k , m } \\).",
  "",
  ". **Energy Conservation**:",
  "  Substitute \\( x [ n ] = \\frac { 1 } { N } \\sum _ { k = 0 } ^ { N - 1 } \\hat { X } [ k ] \\mathcal { E } _ k ^ \\dagger [ n ] \\) into \\( \\sum _ { n = 0 } ^ { N - 1 } ( x [ n ] ) ^ 2 \\) and apply discrete basis orthogonality. Interchanging the order of summation yields the exact equality \\( \\sum _ { n = 0 } ^ { N - 1 } ( x [ n ] ) ^ 2 = \\frac { 1 } { N } \\sum _ { k = 0 } ^ { N - 1 } \\| \\hat { X } [ k ] \\| ^ 2 \\), proving exact physical field energy conservation. \\( \\square \\)",
  "===="
].join("\n");

const sec4Content = [
  "=== Completely Worked Textbook Examples",
  "",
  "==== Example 1: Real Bivector Discrete Fourier Decomposition of a Sampled Pulse Signal",
  "**Problem Statement:** Consider a finite real signal sequence \\( x [ n ] = [ 1 , 1 , 0 , 0 ] ^ T \\) defined on a 4-point resolution grid \\( \\mathcal { G } _ 4 = \\{ 0 , 1 , 2 , 3 \\} \\) with step \\( \\delta = 1 \\). Compute the complete real bivector Fourier spectrum \\( \\hat { X } [ k ] \\) for harmonic modes \\( k = 0 , 1 , 2 , 3 \\) using the real bivector kernel operator \\( \\mathcal { K } [ n , k ] = \\cos \\left( \\frac { 2 \\pi n k } { 4 } \\right) - \\mathbf { I } \\sin \\left( \\frac { 2 \\pi n k } { 4 } \\right) \\), and verify Parseval-Plancherel energy conservation.",
  "",
  "**Solution:**",
  "* **Harmonic Mode \\( k = 0 \\)**:",
  "  Evaluating the kernel for \\( k = 0 \\): \\( \\mathcal { K } [ n , 0 ] = 1 \\) for all \\( n \\).",
  "  \\[ \\hat { X } [ 0 ] = \\sum _ { n = 0 } ^ { 3 } x [ n ] ( 1 ) = 1 + 1 + 0 + 0 = 2 \\]",
  "",
  "* **Harmonic Mode \\( k = 1 \\)**:",
  "  The fundamental phase step angle is \\( \\theta = \\frac { 2 \\pi ( 1 ) } { 4 } = \\frac { \\pi } { 2 } \\). Evaluating the kernel for each grid point \\( n \\):",
  "  - \\( n = 0 \\): \\( \\mathcal { K } [ 0 , 1 ] = \\cos ( 0 ) - \\mathbf { I } \\sin ( 0 ) = 1 \\)",
  "  - \\( n = 1 \\): \\( \\mathcal { K } [ 1 , 1 ] = \\cos \\left( \\frac { \\pi } { 2 } \\right) - \\mathbf { I } \\sin \\left( \\frac { \\pi } { 2 } \\right) = - \\mathbf { I } \\)",
  "  - \\( n = 2 \\): \\( \\mathcal { K } [ 2 , 1 ] = \\cos ( \\pi ) - \\mathbf { I } \\sin ( \\pi ) = - 1 \\)",
  "  - \\( n = 3 \\): \\( \\mathcal { K } [ 3 , 1 ] = \\cos \\left( \\frac { 3 \\pi } { 2 } \\right) - \\mathbf { I } \\sin \\left( \\frac { 3 \\pi } { 2 } \\right) = \\mathbf { I } \\)",
  "  Computing the finite inner product over \\( \\mathcal { G } _ 4 \\):",
  "  \\[ \\hat { X } [ 1 ] = ( 1 ) ( 1 ) + ( 1 ) ( - \\mathbf { I } ) + ( 0 ) ( - 1 ) + ( 0 ) ( \\mathbf { I } ) = 1 - \\mathbf { I } \\]",
  "  The scalar component is \\( \\operatorname { Sc } = 1 \\) and the bivector component is \\( \\operatorname { Biv } = - 1 \\).",
  "",
  "* **Harmonic Mode \\( k = 2 \\)**:",
  "  The phase step angle is \\( \\theta = \\pi \\). Evaluating the kernel for each grid point \\( n \\):",
  "  - \\( n = 0 \\): \\( \\mathcal { K } [ 0 , 2 ] = 1 \\)",
  "  - \\( n = 1 \\): \\( \\mathcal { K } [ 1 , 2 ] = \\cos ( \\pi ) - \\mathbf { I } \\sin ( \\pi ) = - 1 \\)",
  "  - \\( n = 2 \\): \\( \\mathcal { K } [ 2 , 2 ] = \\cos ( 2 \\pi ) - \\mathbf { I } \\sin ( 2 \\pi ) = 1 \\)",
  "  - \\( n = 3 \\): \\( \\mathcal { K } [ 3 , 2 ] = \\cos ( 3 \\pi ) - \\mathbf { I } \\sin ( 3 \\pi ) = - 1 \\)",
  "  Computing the finite inner product:",
  "  \\[ \\hat { X } [ 2 ] = ( 1 ) ( 1 ) + ( 1 ) ( - 1 ) + ( 0 ) ( 1 ) + ( 0 ) ( - 1 ) = 0 \\]",
  "",
  "* **Harmonic Mode \\( k = 3 \\)**:",
  "  The phase step angle is \\( \\theta = \\frac { 3 \\pi } { 2 } \\). Evaluating the kernel for each grid point \\( n \\):",
  "  - \\( n = 0 \\): \\( \\mathcal { K } [ 0 , 3 ] = 1 \\)",
  "  - \\( n = 1 \\): \\( \\mathcal { K } [ 1 , 3 ] = \\cos \\left( \\frac { 3 \\pi } { 2 } \\right) - \\mathbf { I } \\sin \\left( \\frac { 3 \\pi } { 2 } \\right) = \\mathbf { I } \\)",
  "  - \\( n = 2 \\): \\( \\mathcal { K } [ 2 , 3 ] = - 1 \\)",
  "  - \\( n = 3 \\): \\( \\mathcal { K } [ 3 , 3 ] = - \\mathbf { I } \\)",
  "  Computing the finite inner product:",
  "  \\[ \\hat { X } [ 3 ] = ( 1 ) ( 1 ) + ( 1 ) ( \\mathbf { I } ) + ( 0 ) ( - 1 ) + ( 0 ) ( - \\mathbf { I } ) = 1 + \\mathbf { I } \\]",
  "",
  "* **Verification of Parseval-Plancherel Energy Conservation**:",
  "  In physical spatial grid space, computing total field energy:",
  "  \\[ E _ \\text{grid} = \\sum _ { n = 0 } ^ { 3 } ( x [ n ] ) ^ 2 = ( 1 ) ^ 2 + ( 1 ) ^ 2 + ( 0 ) ^ 2 + ( 0 ) ^ 2 = 2 \\]",
  "  In real bivector spectral space, computing the multivector norm squared \\( \\| \\hat { X } [ k ] \\| ^ 2 = ( \\operatorname { Sc } ( \\hat { X } [ k ] ) ) ^ 2 + ( \\operatorname { Biv } ( \\hat { X } [ k ] ) ) ^ 2 \\):",
  "  - \\( \\| \\hat { X } [ 0 ] \\| ^ 2 = 2 ^ 2 + 0 ^ 2 = 4 \\)",
  "  - \\( \\| \\hat { X } [ 1 ] \\| ^ 2 = 1 ^ 2 + ( - 1 ) ^ 2 = 2 \\)",
  "  - \\( \\| \\hat { X } [ 2 ] \\| ^ 2 = 0 ^ 2 + 0 ^ 2 = 0 \\)",
  "  - \\( \\| \\hat { X } [ 3 ] \\| ^ 2 = 1 ^ 2 + 1 ^ 2 = 2 \\)",
  "  Summing spectral energy terms:",
  "  \\[ E _ \\text{spectral} = \\frac { 1 } { 4 } \\sum _ { k = 0 } ^ { 3 } \\| \\hat { X } [ k ] \\| ^ 2 = \\frac { 1 } { 4 } ( 4 + 2 + 0 + 2 ) = \\frac { 8 } { 4 } = 2 \\]",
  "  Thus, \\( E _ \\text{grid} = E _ \\text{spectral} = 2 \\), confirming exact discrete energy conservation."
].join("\n");

// NEW CHAPTER 2: CIRCUIT THEORY
const circuitSec1Content = [
  "=== Kirchhoff’s Laws and Fundamental Circuit Topologies on Discrete Resolution Grids",
  "",
  "Linear circuit theory is the lumped-parameter projection of the Master Field Equation \\( D F = J \\) on discrete spatial-temporal resolution grids \\( \\mathcal { G } _ N \\). When physical circuit dimensions are small relative to the wavelength of field oscillations (\\( d / \\lambda \\ll 1 \\)), electric and magnetic field energy distributions compress into lumped nodes and branches.",
  "",
  "==== Derivation of Kirchhoff’s Voltage Law (KVL)",
  "In a quasi-static multivector field configuration, the electric vector field \\( \\mathbf { E } \\) is the gradient of a discrete scalar potential field \\( \\Phi \\) on \\( \\mathcal { G } _ N \\) (\\( \\mathbf { E } = - \\nabla \\Phi - \\frac { \\partial \\mathbf { A } } { \\partial t } \\)). Integrating the electric field along any closed loop aperture \\( \\mathcal { C } \\) composed of discrete circuit branches yields:",
  "\\[ \\oint _ { \\mathcal { C } } \\mathbf { E } \\cdot d \\mathbf { l } = - \\oint _ { \\mathcal { C } } \\nabla \\Phi \\cdot d \\mathbf { l } - \\frac { d } { d t } \\iint _ { \\mathcal { S } } \\mathbf { B } \\cdot d \\mathbf { A } \\]",
  "When magnetic flux linkage inside the loop aperture is localized within discrete magnetic components (such as inductors or transformers), the line integral of \\( - \\nabla \\Phi \\) around the loop vanishes identically:",
  "\\[ \\sum _ { k = 1 } ^ { M } V _ k = 0 \\]",
  "stating that the sum of potential differences around any closed circuit loop is zero. When time-varying magnetic flux cuts across the loop aperture, Faraday's law of induction produces a non-conservative loop electromotive force \\( \\mathcal { E } _ \\text{loop} = - \\frac { d \\Phi _ B } { d t } \\).",
  "",
  "==== Derivation of Kirchhoff’s Current Law (KCL)",
  "The current density vector \\( \\mathbf { J } \\) satisfies local charge conservation governed by the field continuity equation \\( \\nabla \\cdot \\mathbf { J } + \\frac { \\partial \\rho } { \\partial t } = 0 \\). Integrating this continuity relation over a closed spatial surface \\( \\mathcal { S } \\) enclosing a circuit junction node yields:",
  "\\[ \\iint _ { \\mathcal { S } } \\mathbf { J } \\cdot d \\mathbf { A } = - \\frac { d Q _ \\text{node} } { d t } \\]",
  "In quasi-static lumped circuits, no net electric charge accumulates at an ideal node (\\( \\frac { d Q _ \\text{node} } { d t } = 0 \\)), yielding Kirchhoff’s Current Law (KCL):",
  "\\[ \\sum _ { k = 1 } ^ { K } I _ k = 0 \\]",
  "stating that the sum of electric currents entering any circuit node equals the sum of currents leaving that node. At higher frequencies, parasitic capacitance between nodes and ground introduces stray displacement current leakage \\( I_c = C_s \\frac { d V } { d t } \\).",
  "",
  "==== Graph-Theoretic Circuit Topologies and Tellegen’s Power Conservation",
  "A circuit network composed of \\( N \\) nodes and \\( B \\) branches is fully represented by its reduced incidence matrix \\( \\mathbf { A } \\in \\mathbb { R } ^ { ( N - 1 ) \\times B } \\), fundamental loop matrix \\( \\mathbf { B } \\in \\mathbb { R } ^ { ( B - N + 1 ) \\times B } \\), and fundamental cutset matrix \\( \\mathbf { Q } \\). Tellegen's theorem proves that for any arbitrary network topology, total instantaneous power is conserved:",
  "\\[ \\sum _ { k = 1 } ^ { B } v _ k ( t ) i _ k ( t ) = 0 \\]"
].join("\n");

const circuitSec2Content = [
  "=== Resistors, Capacitors (Condensers), and Inductors (Coils)",
  "",
  "Physical lumped circuit elements represent localized energy dissipation, electric field energy storage, or magnetic field energy storage in the m-resolution field medium.",
  "",
  "==== Resistors and Ohmic Dissipation",
  "A resistor of resistance \\( R \\) represents the irreversible conversion of electrodynamic field energy into lattice thermal phonons via microscopic electron-lattice collision scattering. Ohm’s law is the localized constitutive relation \\( \\mathbf { J } = \\sigma \\mathbf { E } \\), mapping for a uniform conductive cylinder of length \\( l \\) and cross-sectional area \\( A \\) to \\( R = \\frac { l } { \\sigma A } \\):",
  "\\[ V = I R \\]",
  "The rate of irreversible thermal energy dissipation into the grid lattice is given by Joule's law: \\( P = I V = I ^ 2 R = \\frac { V ^ 2 } { R } \\). The resistance varies with temperature according to \\( R ( T ) = R_0 ( 1 + \\alpha \\Delta T ) \\), and exhibits frequency-dependent skin effect resistance \\( R_\\text{ac} = R_\\text{dc} \\left( \\frac { r_0 } { 2 \\delta_s } \\right) \\) at high frequencies.",
  "",
  "==== Capacitors (Condensers)",
  "Capacitors—historically and traditionally designated as **condensers** in early electrical engineering—store electric field energy within a dielectric volume between conductive plates. Charge accumulation \\( Q \\) on condenser plates generates a terminal potential difference:",
  "\\[ Q = C V \\]",
  "where \\( C = \\varepsilon_0 \\varepsilon_r \\frac { A } { d } \\) is the capacitance for parallel plates separated by distance \\( d \\) with relative permittivity \\( \\varepsilon_r \\). The time variation of terminal voltage drives a physical displacement current \\( I _ C = C \\frac { d V } { d t } \\) through the dielectric medium. The total electric field energy stored in the condenser dielectric is:",
  "\\[ W _ E = \\frac { 1 } { 2 } C V ^ 2 = \\frac { 1 } { 2 } \\frac { Q ^ 2 } { C } \\]",
  "Dielectric materials exhibit maximum breakdown dielectric strength \\( E_\\text{break} \\) and dielectric dissipation loss tangent \\( \\tan \\delta = \\frac { \\varepsilon'' } { \\varepsilon' } \\).",
  "",
  "==== Inductors (Coils)",
  "Inductors—traditionally designated as **coils**—store magnetic field energy within the bivector magnetic field generated by current flowing through wound wire turns. Total magnetic flux linkage \\( \\Phi \\) through the coil turns is proportional to the current:",
  "\\[ \\Phi = L I \\]",
  "where \\( L = \\frac { \\mu_0 \\mu_r N ^ 2 A } { l } \\) is the coil inductance for a long solenoid of \\( N \\) turns. By Faraday’s law of induction, a time-varying magnetic flux induces a counter-electromotive force (back-EMF) across coil terminals:",
  "\\[ V _ L = L \\frac { d I } { d t } \\]",
  "The total magnetic field energy stored within the coil turns is: \\( W _ B = \\frac { 1 } { 2 } L I ^ 2 \\). Magnetic core materials display non-linear hysteresis magnetization curves \\( B ( H ) \\), magnetic saturation \\( B_\\text{sat} \\), and core losses composed of hysteresis loss \\( P_h = k_h f B_\\max ^ { 1.6 } \\) and eddy current loss \\( P_e = k_e f ^ 2 B_\\max ^ 2 t^2 \\)."
].join("\n");

const circuitSec3Content = [
  "=== Transformers, Antennas, and Impedance Matching",
  "",
  "==== Transformers and Mutual Inductance",
  "When two or more inductors (coils) share a common magnetic flux path through a high-permeability magnetic core, time-varying current in the primary coil induces a voltage in the secondary coil via mutual inductance \\( M = k \\sqrt { L _ 1 L _ 2 } \\) (where \\( k \\le 1 \\) is the magnetic coupling coefficient). For an ideal transformer with primary turns \\( N _ 1 \\) and secondary turns \\( N _ 2 \\):",
  "\\[ \\frac { V _ 2 } { V _ 1 } = \\frac { N _ 2 } { N _ 1 } , \\quad \\frac { I _ 2 } { I _ 1 } = \\frac { N _ 1 } { N _ 2 } \\]",
  "A load impedance \\( Z _ L \\) connected to the secondary terminals reflects back to the primary terminals as an equivalent input impedance:",
  "\\[ Z _ \\text{in} = \\left( \\frac { N _ 1 } { N _ 2 } \\right) ^ 2 Z _ L \\]",
  "enabling complete impedance matching between power sources and loads.",
  "",
  "==== Antennas as Circuit-Field Launching Elements",
  "An antenna serves as an electrodynamic transducer between lumped guided currents in a circuit and propagating wave fields in the spatial grid \\( \\mathcal { G } _ N \\). Characterized by its radiation resistance \\( R _ \\text{rad} \\), an antenna converts terminal current \\( I_0 \\) into launched electromagnetic wave power \\( P _ \\text{rad} = \\frac { 1 } { 2 } I _ 0 ^ 2 R _ \\text{rad} \\). A Hertzian dipole of length \\( d l \\ll \\lambda \\) has radiation resistance \\( R_\\text{rad} = 80 \\pi ^ 2 \\left( \\frac { d l } { \\lambda } \\right) ^ 2 \\), while a resonant half-wave dipole antenna in free space exhibits \\( R_\\text{rad} \\approx 73 \\ \\Omega \\).",
  "",
  "==== Impedance Matching Networks",
  "To maximize real power transfer from a source with complex bivector internal impedance \\( Z_S = R_S + \\mathbf { I } X_S \\) to a load \\( Z_L = R_L + \\mathbf { I } X_L \\), the conjugate matching condition \\( Z_L = Z_S ^ * = R_S - \\mathbf { I } X_S \\) must be satisfied. Impedance matching networks—utilizing L-sections, Pi-sections, T-sections, and quarter-wave transmission lines—transform arbitrary load impedances to match generator source impedances."
].join("\n");

const circuitSec4Content = [
  "=== Earth Grounds, Grounded Chassis, Electrostatic Shielding, and Faraday Enclosures",
  "",
  "==== Earth Grounds and Terrestrial Reference Planes",
  "An **earth ground** connects electrical systems directly to the physical conductive mass of planet Earth via buried copper rods, grounding grids, or plates. The terrestrial earth acts as an unbounded, zero-potential electric charge sink, stabilizing system reference potentials and providing a low-impedance discharge path for lightning strikes and utility fault currents.",
  "",
  "==== Grounded Chassis and Signal Return Paths",
  "A **grounded chassis** uses the metallic enclosure or structural frame of an electronic device as a common zero-volts reference plane and return path for power and signal currents. It is vital to distinguish safety earth ground from chassis signal ground to prevent spurious **ground loops**, where circulating noise currents induce hum and interference across sensitive signal channels. Proper grounding architectures employ star-grounding configurations or differential balanced signaling.",
  "",
  "==== Electrostatic and Electromagnetic Shielding",
  "A **Faraday cage** or conductive metallic shield encloses sensitive circuits to exclude external electric fields. Free charges inside the conductive shield realign under external fields, establishing an equal and opposite surface charge density \\( \\sigma_s \\) that completely cancels interior electrostatic fields. At high frequencies, electromagnetic wave fields penetrate conductive shields only to the finite **skin depth** \\( \\delta _ s = \\sqrt { \\frac { 2 } { \\omega \\mu \\sigma } } \\), providing exponential field attenuation \\( E ( z ) = E_0 e ^ { - z / \\delta _ s } \\) through the chassis metal. Total shielding effectiveness (SE) in decibels is the sum of absorption loss \\( A = 8.686 \\frac { t } { \\delta_s } \\text{ dB} \\), reflection loss \\( R \\), and re-reflection correction \\( M \\)."
].join("\n");

const circuitSec5Content = [
  "=== Formal Postulates and Theorems of Circuit Theory",
  "",
  "[#theorem-kirchhoff-laws-derivation-master-field-equation]",
  "[THEOREM]",
  ".Theorem: Derivation of Kirchhoff's Circuit Laws from the Master Field Equation",
  "====",
  "On discrete resolution grid \\( \\mathcal { G } _ N \\), under quasi-static lumped field approximations (\\( d / \\lambda \\ll 1 \\)), the Master Field Equation \\( D F = J \\) strictly implies Kirchhoff’s Voltage Law (\\( \\sum V_k = 0 \\)) around closed circuit loops and Kirchhoff’s Current Law (\\( \\sum I_k = 0 \\)) at circuit node junctions.",
  "",
  "*Proof:*",
  ". **KVL Proof**: In quasi-statics, \\( \\nabla \\times \\mathbf { E } = \\mathbf { 0 } \\implies \\mathbf { E } = - \\nabla \\Phi \\). Integrating \\( \\mathbf { E } \\cdot d \\mathbf { l } \\) around any closed loop yields \\( \\oint \\mathbf { E } \\cdot d \\mathbf { l } = \\Phi_A - \\Phi_A = 0 \\), which sums the branch voltage drops \\( \\sum V_k = 0 \\).",
  ". **KCL Proof**: Taking the divergence of the Master Field Equation vector source current yields charge conservation \\( \\nabla \\cdot \\mathbf { J } + \\frac { \\partial \\rho } { \\partial t } = 0 \\). Integrating over a junction volume where no net charge accumulates (\\( \\partial \\rho / \\partial t = 0 \\)) yields \\( \\oint \\mathbf { J } \\cdot d \\mathbf { A } = 0 \\implies \\sum I_k = 0 \\). \\( \\square \\)",
  "====",
  "",
  "[#theorem-condenser-coil-energy-conservation]",
  "[THEOREM]",
  ".Theorem: Energy Conservation in Electric Condensers and Magnetic Coils",
  "====",
  "In an ideal non-dissipative LC circuit composed of a condenser \\( C \\) and a coil \\( L \\), total electrodynamic field energy \\( W _ \\text{total} = W _ E + W _ B = \\frac { 1 } { 2 } C V ( t ) ^ 2 + \\frac { 1 } { 2 } L I ( t ) ^ 2 \\) is strictly conserved at all time steps \\( t_n \\in \\mathcal { G } _ N \\).",
  "",
  "*Proof:*",
  "By KVL, \\( V_C ( t ) + V_L ( t ) = 0 \\implies V ( t ) + L \\frac { d I } { d t } = 0 \\). Differentiating total energy with respect to time yields \\( \\frac { d W _ \\text{total} } { d t } = C V \\frac { d V } { d t } + L I \\frac { d I } { d t } = V ( C \\frac { d V } { d t } ) + I ( L \\frac { d I } { d t } ) \\). Substituting \\( I = - C \\frac { d V } { d t } \\) and \\( L \\frac { d I } { d t } = - V \\) yields \\( \\frac { d W _ \\text{total} } { d t } = V ( - I ) + I ( - V ) = 0 \\). Thus, energy oscillates continuously between condenser electric fields and coil magnetic fields without loss. \\( \\square \\)",
  "====",
  "",
  "[#theorem-maximum-power-transfer-bivector-impedance]",
  "[THEOREM]",
  ".Theorem: Maximum Power Transfer Theorem for Complex Bivector Impedances",
  "====",
  "For an AC source with generator internal impedance \\( Z_S = R_S + \\mathbf { I } X_S \\), maximum real average power is delivered to a load \\( Z_L = R_L + \\mathbf { I } X_L \\) if and only if \\( R_L = R_S \\) and \\( X_L = - X_S \\) (the conjugate match condition \\( Z_L = Z_S ^ * \\)).",
  "",
  "*Proof:*",
  "Total circuit impedance is \\( Z_\\text{total} = ( R_S + R_L ) + \\mathbf { I } ( X_S + X_L ) \\). The current amplitude squared is \\( I_0 ^ 2 = \\frac { V_0 ^ 2 } { ( R_S + R_L ) ^ 2 + ( X_S + X_L ) ^ 2 } \\). Average real power dissipated in the load is \\( P_L = \\frac { 1 } { 2 } I_0 ^ 2 R_L = \\frac { 1 } { 2 } \\frac { V_0 ^ 2 R_L } { ( R_S + R_L ) ^ 2 + ( X_S + X_L ) ^ 2 } \\). To maximize \\( P_L \\) with respect to \\( X_L \\), set \\( X_L = - X_S \\), rendering the denominator purely resistive. Then differentiating \\( P_L = \\frac { 1 } { 2 } \\frac { V_0 ^ 2 R_L } { ( R_S + R_L ) ^ 2 } \\) with respect to \\( R_L \\) and setting to zero yields \\( R_L = R_S \\). Thus \\( Z_L = Z_S ^ * \\), achieving maximum power transfer \\( P_\\max = \\frac { V_0 ^ 2 } { 8 R_S } \\). \\( \\square \\)",
  "===="
].join("\n");

const circuitSec6Content = [
  "=== Completely Worked Technical Examples",
  "",
  "==== Example 1: Multivector Nodal Analysis of an RLC Bridged Network",
  "**Problem Statement:** An AC source \\( V_s ( t ) = 120 \\cos ( 2 \\pi f t ) \\) at \\( f = 60 \\text{ Hz} \\) drives an RLC circuit with resistor \\( R = 10 \\ \\Omega \\), condenser \\( C = 100 \\ \\mu \\text{F} \\), and coil \\( L = 50 \\text{ mH} \\) connected in series. Calculate coil reactance \\( X_L \\), condenser reactance \\( X_C \\), net impedance \\( Z \\), current amplitude \\( I_0 \\), phase angle \\( \\phi \\), real power \\( P \\), reactive power \\( Q \\), and total stored field energy.",
  "",
  "**Solution:**",
  "1. **Coil Reactance \\( X_L \\)**: \\( X_L = 2 \\pi f L = 2 \\pi ( 60 ) ( 0.050 ) \\approx 18.85 \\ \\Omega \\).",
  "2. **Condenser Reactance \\( X_C \\)**: \\( X_C = \\frac { 1 } { 2 \\pi f C } = \\frac { 1 } { 2 \\pi ( 60 ) ( 100 \\times 10 ^ { - 6 } ) } \\approx 26.53 \\ \\Omega \\).",
  "3. **Net Bivector Impedance \\( Z \\)**: \\( Z = R + \\mathbf { I } ( X_L - X_C ) = 10 + \\mathbf { I } ( 18.85 - 26.53 ) = 10 - 7.68 \\mathbf { I } \\ \\Omega \\).",
  "   Magnitude: \\( | Z | = \\sqrt { 10 ^ 2 + ( - 7.68 ) ^ 2 } = \\sqrt { 100 + 58.98 } = \\sqrt { 158.98 } \\approx 12.61 \\ \\Omega \\).",
  "4. **Current Amplitude \\( I_0 \\)**: \\( I_0 = \\frac { V_s } { | Z | } = \\frac { 120 } { 12.61 } \\approx 9.52 \\text{ A} \\). RMS current \\( I_\\text{rms} = \\frac { 9.52 } { \\sqrt{2} } \\approx 6.73 \\text{ A} \\).",
  "5. **Phase Angle \\( \\phi \\)**: \\( \\phi = \\arctan \\left( \\frac { - 7.68 } { 10 } \\right) \\approx - 37.52 ^ \\circ \\) (leading current).",
  "6. **Power Metrics**: Real power \\( P = I_\\text{rms} ^ 2 R = ( 6.73 ) ^ 2 ( 10 ) \\approx 453.0 \\text{ W} \\). Reactive power \\( Q = I_\\text{rms} ^ 2 ( X_L - X_C ) = ( 6.73 ) ^ 2 ( - 7.68 ) \\approx - 347.8 \\text{ VAR} \\).",
  "7. **Peak Stored Energies**: Coil peak energy \\( W _ { B , \\text{peak} } = \\frac { 1 } { 2 } L I_0 ^ 2 = \\frac { 1 } { 2 } ( 0.050 ) ( 9.52 ) ^ 2 \\approx 2.26 \\text{ J} \\). Condenser peak energy \\( W _ { E , \\text{peak} } = \\frac { 1 } { 2 } C V_C ^ 2 = \\frac { 1 } { 2 } ( 100 \\times 10 ^ { - 6 } ) ( 9.52 \\times 26.53 ) ^ 2 \\approx 3.19 \\text{ J} \\).",
  "",
  "==== Example 2: Electromagnetic Shielding Effectiveness of a Copper Enclosure",
  "**Problem Statement:** A copper Faraday shield of thickness \\( t = 1.0 \\text{ mm} \\) (conductivity \\( \\sigma = 5.8 \\times 10 ^ 7 \\text{ S/m} \\), relative permeability \\( \\mu_r = 1.0 \\)) encloses sensitive electronics. Calculate the skin depth \\( \\delta_s \\) and absorption loss \\( A \\) at signal frequencies of \\( f = 60 \\text{ Hz} \\), \\( f = 1 \\text{ MHz} \\), and \\( f = 1 \\text{ GHz} \\).",
  "",
  "**Solution:**",
  "1. **At \\( f = 60 \\text{ Hz} \\)**:",
  "   \\( \\delta_s = \\sqrt { \\frac { 2 } { 2 \\pi ( 60 ) ( 4 \\pi \\times 10 ^ { - 7 } ) ( 5.8 \\times 10 ^ 7 ) } } = \\sqrt { \\frac { 2 } { 2.748 \\times 10 ^ 2 } } = \\sqrt { 7.278 \\times 10 ^ { - 5 } } \\approx 8.53 \\text{ mm} \\).",
  "   Absorption loss: \\( A = 8.686 \\left( \\frac { 1.0 \\text{ mm} } { 8.53 \\text{ mm} } \\right) \\approx 1.02 \\text{ dB} \\).",
  "2. **At \\( f = 1 \\text{ MHz} \\)**:",
  "   \\( \\delta_s = \\sqrt { \\frac { 2 } { 2 \\pi ( 10 ^ 6 ) ( 4 \\pi \\times 10 ^ { - 7 } ) ( 5.8 \\times 10 ^ 7 ) } } \\approx 0.0661 \\text{ mm} = 66.1 \\ \\mu \\text{m} \\).",
  "   Absorption loss: \\( A = 8.686 \\left( \\frac { 1.0 \\text{ mm} } { 0.0661 \\text{ mm} } \\right) \\approx 131.4 \\text{ dB} \\).",
  "3. **At \\( f = 1 \\text{ GHz} \\)**:",
  "   \\( \\delta_s = \\sqrt { \\frac { 2 } { 2 \\pi ( 10 ^ 9 ) ( 4 \\pi \\times 10 ^ { - 7 } ) ( 5.8 \\times 10 ^ 7 ) } } \\approx 2.09 \\ \\mu \\text{m} \\).",
  "   Absorption loss: \\( A = 8.686 \\left( \\frac { 1.0 \\text{ mm} } { 0.00209 \\text{ mm} } \\right) \\approx 4156 \\text{ dB} \\) (complete field exclusion)."
].join("\n");

// NEW CHAPTER 3: TRANSMISSION THEORY, POWER ENGINEERING, AND ELECTRICAL MACHINERY
const transmissionSec1Content = [
  "=== Guided Wave Dynamics in Transmission Lines and Dielectric Energy Transport",
  "",
  "A transmission line—whether a coaxial cable, parallel wire pair, microstrip trace, or rectangular waveguide—is fundamentally an electrodynamic guided wave structure. Electric and magnetic field wave packets propagate through the insulating dielectric medium bounded and guided by conductive surfaces.",
  "",
  "==== Physical Analysis of Dielectric Energy Transport",
  "In classical electrical engineering education, the observation that electromagnetic power flux \\( \\mathbf { S } = \\mathbf { E } \\times \\mathbf { H } \\) resides within the insulating dielectric medium between conductors, rather than inside the metallic wire lattice, has historically been perceived as counter-intuitive by students accustomed to lumped circuit heuristics. Within the framework of Maxwell-Heaviside electrodynamics and the Master Field Equation \\( D F = J \\), this physical reality follows directly from first principles.",
  "",
  "The local volume density of electromagnetic field energy is defined by \\( u = \\frac { 1 } { 2 } \\varepsilon E ^ 2 + \\frac { 1 } { 2 } \\mu H ^ 2 \\). This energy density resides in the spatial volume occupied by the electric vector field \\( \\mathbf { E } \\) and magnetic vector field \\( \\mathbf { H } \\), which is the insulating dielectric medium surrounding or separating the conductors. Inside ideal metallic conductors with high electrical conductivity \\( \\sigma \\), the internal electric field is constrained by Ohm’s law to \\( \\mathbf { E } _ \\text{int} = \\mathbf { J } / \\sigma \\to \\mathbf { 0 } \\). Consequently, the longitudinal Poynting power vector inside the conductor lattice \\( \\mathbf { S } _ \\text{int} = \\mathbf { E } _ \\text{int} \\times \\mathbf { H } \\) vanishes, carrying only the small inward radial component necessary to supply local surface skin-effect ohmic heat losses.",
  "",
  "The metallic conductors perform a crucial structural function: they provide physical boundary surfaces supporting surface charge density \\( \\sigma_s = \\hat { \\mathbf { n } } \\cdot \\mathbf { D } \\) and surface current density \\( \\mathbf { K } _ s = \\hat { \\mathbf { n } } \\times \\mathbf { H } \\). These surface sources enforce boundary conditions that confine, shape, and guide the dielectric wave packet along the length of the transmission structure without significant radiation leakage.",
  "",
  "==== Poynting Power Integration Across Transmission Geometries",
  "1. **Coaxial Cable Geometry (Inner Radius \\( a \\), Outer Radius \\( b \\))**:",
  "   In the dielectric region \\( a < r < b \\), the radial electric field is \\( E_r = \\frac { V } { r \\ln ( b / a ) } \\) and the azimuthal magnetic field is \\( H_\\phi = \\frac { I } { 2 \\pi r } \\). The axial Poynting vector in the dielectric is:",
  "   \\[ S_z = E_r H_\\phi = \\frac { V I } { 2 \\pi \\ln ( b / a ) r ^ 2 } \\]",
  "   Integrating \\( S_z \\) over the cross-sectional dielectric area \\( \\mathcal { S } \\):",
  "   \\[ P = \\int _ { a } ^ { b } \\frac { V I } { 2 \\pi \\ln ( b / a ) r ^ 2 } ( 2 \\pi r d r ) = \\frac { V I } { \\ln ( b / a ) } \\int _ { a } ^ { b } \\frac { d r } { r } = V I \\]",
  "   This proves that 100% of the transmitted power travels through the dielectric volume.",
  "",
  "2. **Parallel Two-Wire Line Geometry (Conductor Radius \\( r_0 \\), Center Separation \\( D \\))**:",
  "   Bipolar coordinate integration of the electric vector field \\( \\mathbf { E } \\) and magnetic vector field \\( \\mathbf { H } \\) across the infinite transverse dielectric plane yields the exact total power integral \\( P = \\iint _ { \\mathbb { R } ^ 2 } S_z d A = V I \\).",
  "",
  "3. **Parallel Plate Wave Channel (Width \\( w \\), Plate Separation \\( d \\))**:",
  "   Uniform fields in the dielectric gap \\( E_y = \\frac { V } { d } \\), \\( H_x = \\frac { I } { w } \\) yield uniform power density \\( S_z = \\frac { V I } { w d } \\). Integrating over cross-sectional area \\( A = w d \\) gives \\( P = S_z ( w d ) = V I \\).",
  "",
  "4. **Rectangular Hollow Waveguide (Width \\( a \\), Height \\( b \\))**:",
  "   In a hollow metal waveguide operating in the dominant \\( \\text{TE}_{10} \\) mode, no inner conductor exists. Fields \\( E_y = E_0 \\sin \\left( \\frac { \\pi x } { a } \\right) \\cos ( \\omega t - \\beta z ) \\) and \\( H_x = - \\frac { E_0 } { Z_\\text{TE} } \\sin \\left( \\frac { \\pi x } { a } \\right) \\cos ( \\omega t - \\beta z ) \\) propagate entirely inside the dielectric gas volume.",
  "",
  "==== Telegrapher’s Wave Equations and Distributed Parameters",
  "Let a transmission line have distributed resistance \\( R' \\) (\\( \\Omega / \\text{m} \\)), inductance \\( L' \\) (\\( \\text{H} / \\text{m} \\)), conductance \\( G' \\) (\\( \\text{S} / \\text{m} \\)), and capacitance \\( C' \\) (\\( \\text{F} / \\text{m} \\)). The coupled wave equations derived from the Master Field Equation are:",
  "\\[ \\frac { \\partial V } { \\partial z } = - R' I - L' \\frac { \\partial I } { \\partial t } , \\quad \\frac { \\partial I } { \\partial z } = - G' V - C' \\frac { \\partial V } { \\partial t } \\]",
  "The complex bivector propagation constant is \\( \\gamma = \\sqrt { ( R' + \\mathbf { I } \\omega L' ) ( G' + \\mathbf { I } \\omega C' ) } = \\alpha + \\mathbf { I } \\beta \\), where \\( \\alpha \\) is the attenuation constant (nepers/m) and \\( \\beta \\) is the phase constant (rad/m). The characteristic impedance is:",
  "\\[ Z_0 = \\sqrt { \\frac { R' + \\mathbf { I } \\omega L' } { G' + \\mathbf { I } \\omega C' } } \\]",
  "Under the Heaviside distortionless condition \\( \\frac { R' } { L' } = \\frac { G' } { C' } \\), the attenuation becomes frequency-independent \\( \\alpha = \\sqrt { R' G' } \\) and phase velocity is constant \\( v_p = \\frac { 1 } { \\sqrt { L' C' } } \\), eliminating dispersion."
].join("\n");

const transmissionSec2Content = [
  "=== High-Voltage Power Grids, Telephone, Cable TV, and High-Speed Internet Transmission",
  "",
  "==== High-Voltage Power Transmission Grids",
  "Bulk electrical power transmission across long continental distances utilizes 3-phase Alternating Current (AC) networks operating at voltages exceeding 500 kV, or High-Voltage Direct Current (HVDC) lines exceeding 800 kV. Transmitting power \\( P \\) at high line-to-line voltage \\( V_{LL} \\) minimizes line current \\( I = \\frac { P } { \\sqrt{3} V_{LL} \\cos \\phi } \\), exponentially reducing conductor ohmic heat losses \\( P_\\text{loss} = 3 I ^ 2 R' l \\).",
  "",
  "3-phase AC systems operate in Wye (Y) or Delta (\\( \\Delta \\)) configurations, with real power \\( P = \\sqrt{3} V_{LL} I_L \\cos \\phi \\), reactive power \\( Q = \\sqrt{3} V_{LL} I_L \\sin \\phi \\), and apparent power \\( S = \\sqrt{3} V_{LL} I_L \\). HVDC links employ Line-Commutated Converters (LCC) or Voltage-Source Converters (VSC) with IGBT switches to bypass reactive line impedance drops, allowing asynchronous power interconnects across regional power grids. Corona discharge loss is suppressed by conductor bundling (grouping 2 to 4 conductors per phase) to reduce the surface electric field gradient below air dielectric breakdown (30 kV/cm). Lines operate near Surge Impedance Loading (SIL \\( = V^2 / Z_0 \\)) to balance inductive and capacitive reactive power.",
  "",
  "==== Telephone, Cable TV, and High-Speed Data Lines",
  "High-frequency information transmission channels rely on controlled characteristic impedance \\( Z_0 \\) to prevent reflections and signal dispersion:",
  "* **Twisted-Pair Ethernet (Cat 5e/6/6A/7/8)**: Uses balanced differential signaling over twisted copper pairs with controlled pitch ratios to maximize Common-Mode Rejection Ratio (CMRR) and minimize cross-talk.",
  "* **Coaxial Cable Optimization (50-ohm vs 75-ohm)**: In coaxial transmission lines with dielectric relative permittivity \\( \\varepsilon_r \\), characteristic impedance is \\( Z_0 = \\frac { 60 } { \\sqrt{\\varepsilon_r} } \\ln \\left( \\frac { b } { a } \\right) \\). Mathematical optimization proves two distinct peaks:",
  "  1. **Maximum Power Handling Peak**: Occurs at radius ratio \\( b/a \\approx 1.65 \\), corresponding to \\( Z_0 \\approx 30 \\ \\Omega \\) for air and \\( Z_0 \\approx 50 \\ \\Omega \\) for polyethylene (\\( \\varepsilon_r = 2.25 \\)), standard in RF transmitter feedlines.",
  "  2. **Minimum Signal Attenuation Peak**: Occurs at radius ratio \\( b/a \\approx 3.59 \\), corresponding to \\( Z_0 \\approx 77 \\ \\Omega \\) for air and \\( Z_0 \\approx 75 \\ \\Omega \\) for polyethylene, standard in Cable TV (CATV) and long-distance broadband distribution.",
  "* **Fiber Optic Optical Waveguides**: Ultra-high-bandwidth optical transmission relies on total internal reflection inside single-mode glass fiber cores (e.g., SMF-28 with core diameter \\( 8.2 \\ \\mu \\text{m} \\), cladding diameter \\( 125 \\ \\mu \\text{m} \\)). Governed by single-mode condition \\( V = \\frac { 2 \\pi a } { \\lambda } \\sqrt { n_1 ^ 2 - n_2 ^ 2 } < 2.405 \\), optical fibers achieve attenuation below \\( 0.18 \\text{ dB/km} \\) at 1550 nm, supporting Dense Wavelength Division Multiplexing (DWDM) carrying multi-terabit/s data streams across transoceanic undersea cables."
].join("\n");

const transmissionSec3Content = [
  "=== Electrodynamic Generators and AC/DC Electric Motors",
  "",
  "Electric machines convert mechanical kinetic energy into electrodynamic field energy (generators) or field energy into mechanical torque (motors) via magnetic flux cutting \\( \\mathcal { E } = - \\frac { d \\Phi } { d t } \\) and Lorentz field forces \\( \\mathbf { F } = q ( \\mathbf { E } + \\mathbf { v } \\times \\mathbf { B } ) \\).",
  "",
  "==== Electrodynamic Generators",
  "In a 3-phase AC synchronous generator (alternator), a mechanical prime mover rotates a DC-excited rotor magnetic field inside a stationary stator containing polyphase armature windings. The induced RMS phase electromotive force is \\( E_p = 4.44 f N_p \\Phi K_w \\). Armature reaction flux interacts with rotor field flux to establish terminal voltage regulation.",
  "",
  "==== Three Classic Motor Families",
  "1. **Induction Motors (Asynchronous Motors)**: Polyphase AC currents in stator windings generate a revolving magnetic field of synchronous speed \\( n_s = \\frac { 120 f } { p } \\) (rpm). This field cuts conductive rotor bars in a squirrel-cage rotor, inducing rotor currents and electrodynamic torque. The speed difference defines the **slip** \\( s = \\frac { n_s - n_r } { n_s } \\). The mechanical torque output derived from the equivalent circuit is:",
  "   \\[ T_e = \\frac { 3 p } { 2 \\omega_s } \\frac { V_1 ^ 2 \\left( \\frac { R_2' } { s } \\right) } { \\left( R_1 + \\frac { R_2' } { s } \\right) ^ 2 + ( X_1 + X_2' ) ^ 2 } \\]",
  "   Maximum (breakdown) torque \\( T_\\max \\) occurs at slip \\( s_\\max = \\frac { R_2' } { \\sqrt { R_1 ^ 2 + ( X_1 + X_2' ) ^ 2 } } \\). Variable Frequency Drives (VFDs) adjust stator frequency \\( f \\) and voltage \\( V_1 \\) proportionally (constant V/f control) to regulate speed efficiently.",
  "2. **Synchronous Motors**: The rotor contains DC-excited field coils or permanent magnets that lock in exact phase synchrony with the stator rotating field (\\( n_r = n_s \\)), operating at zero slip. Operating at over-excited field current causes the synchronous motor to draw leading reactive power, acting as a synchronous condenser for power factor correction.",
  "3. **Brushed DC Motors**: A stationary stator field surrounds a rotating armature. A mechanical commutator and carbon brushes physically reverse armature coil currents every half-revolution to maintain unidirectional electrodynamic torque \\( T_e = K_T \\Phi I_a \\). Speed is controlled via armature voltage: \\( \\omega_m = \\frac { V_a - I_a R_a } { K_a \\Phi } \\)."
].join("\n");

const transmissionSec4Content = [
  "=== Brushless DC (BLDC) Motors: Electronic Commutation, Permanent Magnets, and Inverter Driving",
  "",
  "==== Physical Construction and Operating Principle",
  "A **Brushless DC (BLDC) Motor** inverts the roles of traditional DC motor components: high-coercivity permanent magnets (such as Neodymium-Iron-Boron NdFeB) are mounted on the rotating rotor, while multi-phase copper windings are placed on the stationary stator. This eliminates mechanical commutators, carbon brushes, spark erosion, friction, and maintenance.",
  "",
  "==== Electronic Commutation and Inverter Driving",
  "Instead of mechanical brushes, BLDC motors use a solid-state 3-phase **H-bridge inverter** consisting of six power MOSFETs or IGBTs. Rotor position is sensed continuously using embedded Hall-effect sensors or back-EMF zero-crossing detection. The inverter controller switches stator phase currents electronically in trapezoidal (6-step) or sinusoidal sequence, maintaining an optimal \\( 90 ^ \\circ \\) angle between stator magnetic flux and rotor magnet poles for maximum torque generation, achieving efficiencies exceeding 90%.",
  "",
  "==== Field-Oriented Control (FOC) and Space Vector Modulation",
  "For Permanent Magnet Synchronous Motors (PMSM) with sinusoidal back-EMF, Field-Oriented Control (FOC) transforms 3-phase stationary stator currents \\( ( i_a, i_b, i_c ) \\) into a rotating orthogonal direct-quadrature \\( ( d - q ) \\) coordinate frame locked to the rotor magnet angle \\( \\theta_r \\):",
  "* **Clarke Transformation (3-Phase to 2-Axis Stationary \\( \\alpha - \\beta \\))**:",
  "  \\[ \\begin{pmatrix} i_\\alpha \\\\ i_\\beta \\end{pmatrix} = \\begin{pmatrix} 1 & -1/2 & -1/2 \\\\ 0 & \\sqrt{3}/2 & -\\sqrt{3}/2 \\end{pmatrix} \\begin{pmatrix} i_a \\\\ i_b \\\\ i_c \\end{pmatrix} \\]",
  "* **Park Transformation (Stationary \\( \\alpha - \\beta \\) to Rotating \\( d - q \\))**:",
  "  \\[ \\begin{pmatrix} i_d \\\\ i_q \\end{pmatrix} = \\begin{pmatrix} \\cos \\theta_r & \\sin \\theta_r \\\\ - \\sin \\theta_r & \\cos \\theta_r \\end{pmatrix} \\begin{pmatrix} i_\\alpha \\\\ i_\\beta \\end{pmatrix} \\]",
  "The quadrature current \\( i_q \\) controls electromagnetic torque \\( T_e = \\frac { 3 } { 2 } p \\lambda_m i_q \\) independently, while direct current \\( i_d \\) controls rotor flux. Setting \\( i_d = 0 \\) maximizes torque efficiency, while applying negative d-axis current (\\( i_d < 0 \\)) enables flux weakening for high-speed operation. Space Vector Pulse-Width Modulation (SVPWM) maximizes DC bus voltage utilization by 15.47% compared to standard sinusoidal PWM."
].join("\n");

const transmissionSec5Content = [
  "=== Formal Postulates and Theorems of Transmission Theory and Electrical Machines",
  "",
  "[#theorem-dielectric-transmission-line-poynting-power]",
  "[THEOREM]",
  ".Theorem: Dielectric Wave Power Transport and Conductor Guidance Theorem",
  "====",
  "In any two-conductor transmission line, total electromagnetic power \\( P = \\int _ { \\mathcal { S } } \\mathbf { S } \\cdot d \\mathbf { A } \\) is transported entirely through the dielectric insulating medium surrounding the conductors. The inner and outer metal conductors carry zero power inside their metallic lattice, acting strictly as boundary constraints that drive and guide the dielectric wave fields.",
  "",
  "*Proof:*",
  ". **Field Integration**: In a coaxial transmission line carrying voltage \\( V \\) and current \\( I \\), the radial electric field is \\( E_r = \\frac { V } { r \\ln(b/a) } \\) and the azimuthal magnetic field is \\( H_\\phi = \\frac { I } { 2 \\pi r } \\) in the dielectric region \\( a < r < b \\).",
  ". **Poynting Vector Evaluation**: The Poynting power flux density vector in the dielectric is \\( \\mathbf { S } = \\mathbf { E } \\times \\mathbf { H } = E_r H_\\phi \\hat { \\mathbf { z } } = \\frac { V I } { 2 \\pi \\ln(b/a) r^2 } \\hat { \\mathbf { z } } \\).",
  ". **Power Integration**: Integrating \\( \\mathbf { S } \\) over the cross-sectional dielectric area \\( \\mathcal { S } \\):",
  "  \\[ P = \\int _ { a } ^ { b } \\frac { V I } { 2 \\pi \\ln(b/a) r^2 } ( 2 \\pi r d r ) = \\frac { V I } { \\ln(b/a) } \\int _ { a } ^ { b } \\frac { d r } { r } = \\frac { V I } { \\ln(b/a) } \\ln \\left( \\frac { b } { a } \\right) = V I \\]",
  "  Inside ideal conductors, \\( \\mathbf { E } = \\mathbf { 0 } \\implies \\mathbf { S } = \\mathbf { 0 } \\). Thus 100% of the electromagnetic power propagates in the dielectric, proving the theorem. \\( \\square \\)",
  "====",
  "",
  "[#theorem-heaviside-distortionless-line-condition]",
  "[THEOREM]",
  ".Theorem: Heaviside Distortionless Transmission Line Condition Theorem",
  "====",
  "A lossy transmission line with distributed parameters \\( R', L', G', C' \\) preserves signal wave shapes without phase velocity dispersion if and only if \\( \\frac { R' } { L' } = \\frac { G' } { C' } \\).",
  "",
  "*Proof:*",
  "The propagation constant is \\( \\gamma = \\sqrt { ( R' + \\mathbf { I } \\omega L' ) ( G' + \\mathbf { I } \\omega C' ) } \\). Factoring yields \\( \\gamma = \\sqrt { L' C' ( R'/L' + \\mathbf { I } \\omega ) ( G'/C' + \\mathbf { I } \\omega ) } \\). Setting \\( \\frac { R' } { L' } = \\frac { G' } { C' } = \\alpha_0 \\) gives \\( \\gamma = \\sqrt { L' C' } ( \\alpha_0 + \\mathbf { I } \\omega ) = \\sqrt { R' G' } + \\mathbf { I } \\omega \\sqrt { L' C' } \\). Thus \\( \\alpha = \\sqrt { R' G' } \\) is independent of frequency, and phase velocity \\( v_p = \\frac { \\omega } { \\beta } = \\frac { 1 } { \\sqrt { L' C' } } \\) is strictly constant across all harmonic modes, eliminating dispersion. \\( \\square \\)",
  "====",
  "",
  "[#theorem-bldc-electronic-commutation-torque]",
  "[THEOREM]",
  ".Theorem: Maximum Electrodynamic Torque in Electronically Commutated BLDC Motors",
  "====",
  "In a polyphase Brushless DC motor driven by a 3-phase inverter, electronic phase switching aligned with rotor position produces constant electromagnetic torque \\( T_e = K_t I_a \\) without torque ripple.",
  "",
  "*Proof:*",
  "Stator magnetic flux vector \\( \\mathbf { \\Phi } _ s \\) and rotor permanent magnet flux vector \\( \\mathbf { \\Phi } _ r \\) produce electrodynamic torque \\( \\mathbf { T } _ e = \\mathbf { \\Phi } _ r \\times \\mathbf { \\Phi } _ s = | \\mathbf { \\Phi } _ r | | \\mathbf { \\Phi } _ s | \\sin \\delta \\hat { \\mathbf { z } } \\). Electronic commutation via Hall-effect feedback maintains phase angle \\( \\delta = 90 ^ \\circ \\) (\\( \\sin \\delta = 1 \\)) continuously, maximizing torque per ampere \\( T_e = K_t I_a \\). \\( \\square \\)",
  "===="
].join("\n");

const transmissionSec6Content = [
  "=== Completely Worked Technical Examples",
  "",
  "==== Example 1: Poynting Power Transport in RG-213 Coaxial Transmission Line",
  "**Problem Statement:** An RG-213 coaxial cable has inner conductor radius \\( a = 1.15 \\text{ mm} \\), outer conductor inner radius \\( b = 3.60 \\text{ mm} \\), and polyethylene dielectric (\\( \\varepsilon_r = 2.25 \\)). The line drives a 50-ohm antenna with RMS voltage \\( V = 100 \\text{ V} \\) and current \\( I = 2.0 \\text{ A} \\). Calculate dielectric characteristic impedance \\( Z_0 \\), phase velocity \\( v_p \\), Poynting power density at the inner conductor surface \\( r = a \\), and total dielectric power.",
  "",
  "**Solution:**",
  "1. **Characteristic Impedance \\( Z_0 \\)**: \\( Z_0 = \\frac { 60 } { \\sqrt{\\varepsilon_r} } \\ln \\left( \\frac { b } { a } \\right) = \\frac { 60 } { 1.50 } \\ln \\left( \\frac { 3.60 } { 1.15 } \\right) = 40 \\ln( 3.1304 ) \\approx 40 ( 1.1411 ) \\approx 45.64 \\ \\Omega \\).",
  "2. **Phase Velocity \\( v_p \\)**: \\( v_p = \\frac { c } { \\sqrt{2.25} } = \\frac { 3.0 \\times 10^8 } { 1.50 } = 2.0 \\times 10^8 \\text{ m/s} \\) (66.7% of wave speed \\( c \\)).",
  "3. **Poynting Power Density at \\( r = a \\)**: \\( S ( a ) = \\frac { V I } { 2 \\pi \\ln(b/a) a^2 } = \\frac { ( 100 ) ( 2.0 ) } { 2 \\pi ( 1.1411 ) ( 1.15 \\times 10^{-3} )^2 } = \\frac { 200 } { 7.170 \\times 10^{-6} ( 1.3225 \\times 10^{-6} ) } \\approx 2.11 \\times 10^7 \\text{ W/m}^2 \\).",
  "4. **Total Power in Dielectric**: \\( P = V I = ( 100 \\text{ V} ) ( 2.0 \\text{ A} ) = 200 \\text{ W} \\). Power inside inner copper conductor is zero.",
  "",
  "==== Example 2: Field-Oriented Control (FOC) Current Transformations for a PMSM Drive Motor",
  "**Problem Statement:** A 3-phase Permanent Magnet Synchronous Motor (PMSM) drive operates at rotor angle \\( \\theta_r = 30^\circ \\) (\\( \\cos 30^\circ = 0.866 \\), \\( \\sin 30^\circ = 0.500 \\)). The measured 3-phase stator currents are \\( i_a = 10.0 \\text{ A} \\), \\( i_b = - 5.0 \\text{ A} \\), \\( i_c = - 5.0 \\text{ A} \\). Calculate the stationary two-axis currents \\( ( i_\\alpha, i_\\beta ) \\) via Clarke transformation, and the rotating direct-quadrature currents \\( ( i_d, i_q ) \\) via Park transformation.",
  "",
  "**Solution:**",
  "1. **Clarke Transformation**:",
  "   \\[ i_\\alpha = i_a = 10.0 \\text{ A} \\]",
  "   \\[ i_\\beta = \\frac { \\sqrt{3} } { 2 } ( i_b - i_c ) = \\frac { 1.732 } { 2 } ( - 5.0 - ( - 5.0 ) ) = 0.0 \\text{ A} \\]",
  "2. **Park Transformation**:",
  "   \\[ i_d = i_\\alpha \\cos \\theta_r + i_\\beta \\sin \\theta_r = ( 10.0 ) ( 0.866 ) + ( 0.0 ) ( 0.500 ) = 8.66 \\text{ A} \\]",
  "   \\[ i_q = - i_\\alpha \\sin \\theta_r + i_\\beta \\cos \\theta_r = - ( 10.0 ) ( 0.500 ) + ( 0.0 ) ( 0.866 ) = - 5.00 \\text{ A} \\]",
  "3. **Physical Interpretation**: The direct current component \\( i_d = 8.66 \\text{ A} \\) produces magnetic flux along the rotor pole axis, while the quadrature current component \\( i_q = - 5.00 \\text{ A} \\) produces orthogonal electrodynamic torque."
].join("\n");

// Existing Chapters 4, 5, 6 content variables from updateVolume5.ts
const chap2Sec1Content = [
  "=== m-Resolution Analog and Digital System Paradigms",
  "In 19th and 20th-century linear system theory, physical engineering was split into analog signals on a continuum and digital signals on discrete grids. In the Iris Number System, all signals are formulated on discrete resolution grids \\( \\mathcal { G } _ N \\)."
].join("\n");

const chap2Sec2Content = [
  "=== Shift-Invariant Systems, Difference Convolution, and Bivector Transfer Functions",
  "An LSI system is uniquely characterized by its unit impulse response \\( h [ n ] \\). Output is given by difference convolution \\( y [ n ] = ( x * h ) [ n ] \\)."
].join("\n");

const chap2Sec3Content = [
  "=== Bilinear Resolution Mapping and System Stability",
  "Mapping m-res system poles onto discrete Z-domain stability circles via bilinear resolution transformation."
].join("\n");

const chap2Sec4Content = [
  "=== Rigorous Proofs and System Dynamics Theorems",
  "[#theorem-m-res-digital-convolution-equivalence]\n[THEOREM]\n.Theorem: m-Resolution Difference Convolution and Spectral Multiplication Equivalence Theorem\n\\[ Y ( z ) = H ( z ) X ( z ) \\]"
].join("\n");

const chap2Sec5Content = [
  "=== Completely Worked Textbook Examples\n==== Example 1: Digital Bivector Transfer Function and Discrete Resonance Analysis\nSystem response evaluation under bivector excitation."
].join("\n");

const chap3Sec1Content = [
  "=== Thermionic Emission, Child-Langmuir Space Charge Law, and m-Resolution Field Dynamics",
  "Physical theory of thermionic cathode emission, space charge buildup, and Child-Langmuir law \\( J = K V^{3/2} \\)."
].join("\n");

const chap3Sec2Content = [
  "=== Multi-Electrode Valves: Diodes, Triodes, Tetrodes, Pentodes, Beam Power Tubes, and Multigrid Mixers",
  "Triodes, amplification factor \\( \\mu \\), tetrodes, pentodes, suppressor grids, and Barkhausen valve relations."
].join("\n");

const chap3Sec3Content = [
  "=== Cathode-Ray Tubes and Specialized Vacuum Devices: Electrostatic, Electromagnetic, Storage, and Image Tubes",
  "Cathode-Ray Tube (CRT) electron optics, electrostatic/electromagnetic beam deflection, klystrons, magnetrons."
].join("\n");

const chap3Sec4Content = [
  "=== Electron Tube Fabrication, Thermal Outgassing, and the Physics of the Barium Getter Mirror",
  "High-vacuum tube manufacturing, thermal outgassing baking, and chemical absorption via flashed barium getter mirrors."
].join("\n");

const chap3Sec5Content = [
  "=== Formal Postulates and Theorems of Vacuum Tube Field Dynamics",
  "[#theorem-child-langmuir-m-res-derivation]\n[THEOREM]\n.Theorem: Derivation of the Child-Langmuir Space-Charge Law from the Master Field Equation"
].join("\n");

const chap3Sec6Content = [
  "=== Completely Worked Technical Examples\n==== Example 1: Triode Amplifier Voltage Gain and Dynamic Plate Resistance Calculation"
].join("\n");

const chap4Sec1Content = [
  "=== Point-Contact Crystal Detectors and Makeshift Rectifiers: Galena, Pyrite, and Foxhole Radios",
  "",
  "Long before the formal industrial development of monocrystalline silicon and germanium p-n junction diodes, practical high-frequency signal rectification was achieved through point-contact metal-semiconductor interfaces.",
  "",
  "==== Early Point-Contact Crystal Detectors",
  "In the early era of radio communication, crystal detectors utilized a fine phosphor-bronze or tungsten wire—popularly known as a “cat’s whisker”—lightly pressed against the surface of a natural crystalline mineral. Prominent semiconductors included galena (lead sulfide, \\( \\text{PbS} \\)), iron pyrite (fool’s gold, \\( \\text{FeS}_2 \\)), carborundum (silicon carbide, \\( \\text{SiC} \\)), and chalcopyrite.",
  "",
  "When a metal wire contacts a natural semiconductor crystal, the disparity between the metal work function \\( \\Phi_m \\) and the semiconductor electron affinity \\( \\chi_s \\) creates a localized asymmetric electric potential barrier on the discrete lattice grid \\( \\mathcal { G } _ N \\). When an alternating high-frequency radio-frequency (RF) signal is applied, charge carriers easily cross the barrier in one bias direction while experiencing high impedance in the opposite direction. This non-linear current-voltage characteristic rectifies amplitude-modulated (AM) carrier waves, extracting the low-frequency audio envelope without requiring external electrical power.",
  "",
  "==== World War II ‘Foxhole Radios’ and Makeshift Oxide Rectifiers",
  "A remarkable demonstration of point-contact rectification occurred during World War II, where soldier prisoners and frontline troops constructed emergency radio receivers known as **foxhole radios**. Lacking access to commercial vacuum tubes or batteries, troops constructed makeshift crystal detectors using discarded materials: a rusty steel razor blade, a pencil lead (graphite rod) or safety pin, a hand-wound antenna coil around a cardboard tube, and an earphone.",
  "",
  "The rectification mechanism in a foxhole radio relies on the thin, non-uniform layer of iron oxides (primarily magnetite, \\( \\text{Fe}_3 \\text{O}_4 \\), and hematite, \\( \\text{Fe}_2 \\text{O}_3 \\)) formed on the heat-treated surface of the steel razor blade. When the graphite pencil point contacts the oxide coating, it forms a metal-semiconductor point-contact junction. The localized work-function step between graphite and iron oxide establishes a Schottky-like rectifying barrier. The non-linear current response rectifies ambient AM radio signals, converting RF wave energy directly into acoustic vibrations in the high-impedance earphone.",
  "",
  "These makeshift devices demonstrated that semiconductor rectification is an intrinsic physical property of asymmetric material boundary interfaces under electromagnetic field excitation, requiring neither artificial vacuum tubes nor speculative 'quantum' mechanisms."
].join("\n");

const chap4Sec2Content = [
  "=== Epistemology of Solid-State Physics: Deconstruction of the ‘Quantum’ Semiconductor Fallacy, Term Coöptation, and Empirical Law",
  "",
  "The chapter on semiconductor diodes, being the foundational entry into solid-state electronic devices, is precisely where physical science must dismantle the persistent epistemological fallacy that misleads the public and engineering students into believing that solid-state devices are intrinsically 'quantum' devices.",
  "",
  "==== The Giveaway of ‘Solid State’ and the Mislabeling of Empirical Facts",
  "The very designation **'solid state'** provides the immediate giveaway: solid-state electronics concerns the physical, structural electrodynamics of charge currents and wave packets propagating within a solid, discrete crystalline material lattice. Yet twentieth-century mainstream literature routinely asserts that solid-state devices—such as p-n junction diodes, transistors, and integrated circuits—are proof of 'quantum mechanics' and cannot be understood through classical field principles.",
  "",
  "In truth, the observed facts regarding semiconductors—such as discrete energy band gaps, carrier drift mobilities, built-in contact potentials, rectifying barrier junctions, and tunneling current dynamics—were, prior to the discovery of the Master Field Equation \\( D F = J \\), known **strictly from experiment**. These experimental findings were empirical laws governing the electrodynamics of bound atomic lattices.",
  "",
  "However, twentieth-century physics engaged in a fraudulent **term coöptation of 'fundamental principle'**. Facts that were discovered experimentally and awaited derivation from first principles were mislabeled as 'fundamental quantum principles'. What was actually meant by these observed facts was **empirical law**.",
  "",
  "==== Niels Bohr, the Solvay Conference of 1927, and Verbal Trickery",
  "This systematic term coöptation originated formally with **Niels Bohr** and his so-called **'complementarity principle'**—the anti-rational doctrine asserting that a physical scientist must simultaneously believe mutually contradictory propositions (such as asserting that an entity is simultaneously a continuous wave and a zero-volume point particle, or that physical transitions occur as uncaused 'quantum jumps' without finite duration).",
  "",
  "At the Fifth Solvay International Conference of 1927, this doctrine was dogmatized into standard physics terminology. Prior to 1927, an unexplained experimental observation was correctly designated as an **empirical law**—a physical regularity whose underlying first-principles cause remained to be discovered through rigorous field analysis. After 1927, through systematic verbal trickery, empirical laws were rebranded as 'fundamental quantum principles', transforming physical regularities into inexplicable, uncaused mysteries that were forbidden to be questioned or derived.",
  "",
  "==== Restoration of First Principles via the Master Field Equation",
  "The Master Field Equation \\( D F = J \\) in Clifford algebra \\( Cl ( 4 , 1 , 1 ) \\) on discrete multiscale resolution grid \\( \\mathcal { G } _ N \\) changes that completely. Semiconductor phenomena are not uncaused 'quantum magic'; they are explicit, deterministic multivector field stress-energy dynamics occurring within discrete atomic crystal lattices.",
  "",
  "By replacing unphysical continuum point-particle singularities with non-singular Clifford multivector wave packets co-propagating across discrete lattice grid cells, the facts of solid-state physics are restored to their proper status: empirical laws that are rigorously derived from first principles. The 'quantum' semiconductor fallacy is eliminated, re-establishing solid-state engineering on a firm, transparent electrodynamic foundation."
].join("\n");

const chap4Sec3Content = [
  "=== P-N Junction Physics, Built-in Potential, Shockley Diode Equation, and Schottky Barriers",
  "",
  "==== Doped Semiconductors and Depletion Layer Dynamics",
  "A semiconductor crystal (such as Silicon, \\( \\text{Si} \\), or Germanium, \\( \\text{Ge} \\)) consists of a periodic atomic lattice. Doping the lattice with group-V donor atoms (e.g., Phosphorus) yields n-type material with excess mobile electron current density, while doping with group-III acceptor atoms (e.g., Boron) yields p-type material with excess hole current density.",
  "",
  "When p-type and n-type regions meet at a metallurgical junction, major carrier diffusion drives electrons into the p-region and holes into the n-region. This exposure of uncompensated ionized donor cores (\\( N_D^+ \\)) and acceptor cores (\\( N_A^- \\)) creates a localized **depletion region** (space-charge region) devoid of mobile carriers. The exposed space charge generates an internal built-in electric vector field \\( \\mathbf { E } _ 0 \\) directed from the n-side to the p-side.",
  "",
  "==== Built-in Potential and Equilibrium Field Balance",
  "At thermal equilibrium, the outward diffusion current density \\( J_\\text{diff} = q D_n \\frac { d n } { d x } \\) is exactly balanced by the inward drift current density \\( J_\\text{drift} = q n \\mu_n E_0 \\), yielding zero net current \\( J_\\text{total} = 0 \\). Integrating the built-in electric field across the depletion width \\( W = x_n + x_p \\) yields the **built-in potential** \\( V_{bi} \\):",
  "\\[ V_{bi} = \\frac { k_B T } { q } \\ln \\left( \\frac { N_A N_D } { n_i ^ 2 } \\right) = V_t \\ln \\left( \\frac { N_A N_D } { n_i ^ 2 } \\right) \\]",
  "where \\( V_t = k_B T / q \\approx 25.85 \\text{ mV} \\) at 300 K, and \\( n_i \\) is the intrinsic carrier density.",
  "",
  "==== Derivation of the Shockley Diode Equation",
  "Applying an external forward bias voltage \\( V \\) lowers the potential barrier to \\( V_{bi} - V \\), allowing exponential carrier diffusion across the junction. Applying a reverse bias voltage \\( V = - V_R \\) widens the barrier to \\( V_{bi} + V_R \\), choking off diffusion and leaving only a minute minority carrier thermal generation current \\( I_s \\).",
  "",
  "Solving the continuity equation for minority carrier diffusion in the neutral regions yields the celebrated **Shockley Diode Equation**:",
  "\\[ I ( V ) = I_s \\left( e ^ { \\frac { V } { n V_t } } - 1 \\right) \\]",
  "where \\( I_s = q A \\left( \\frac { D_p p_{n0} } { L_p } + \\frac { D_n n_{p0} } { L_n } \\right) \\) is the reverse saturation current, and \\( n \\approx 1.0 \\text{--} 2.0 \\) is the diode ideality factor.",
  "",
  "==== Metal-Semiconductor Schottky Barriers",
  "A **Schottky diode** consists of a direct metal-semiconductor interface (e.g., Platinum on n-type Silicon). The Schottky barrier height \\( \\Phi_{BN} = \\Phi_m - \\chi_s \\) governs current transport via majority-carrier thermionic emission:",
  "\\[ I = A^* A T^2 e ^ { - \\frac { \\Phi_{BN} } { V_t } } \\left( e ^ { \\frac { V } { n V_t } } - 1 \\right) \\]",
  "Because Schottky diodes rely strictly on majority carrier transport, they exhibit zero minority-carrier storage delay, enabling ultra-fast reverse recovery times (< 100 ps) and lower forward voltage drops (0.2–0.3 V compared to 0.6–0.7 V for silicon p-n diodes)."
].join("\n");

const chap4Sec4Content = [
  "=== Specialized Solid-State Diodes: Zener, Avalanche, Varactor, Tunnel, PIN, LEDs, and Photodiodes",
  "",
  "==== Zener and Avalanche Breakdown Diodes",
  "Under reverse bias, a p-n junction eventually undergoes electrical breakdown at voltage \\( V_{BR} \\):",
  "* **Zener Breakdown (< 5 V)**: In heavily doped junctions (\\( N_A, N_D > 10^{18} \\text{ cm}^{-3} \\)), the depletion layer width is extremely thin (\\( W < 10 \\text{ nm} \\)). High reverse electric fields (\\( E > 10^6 \\text{ V/cm} \\)) induce direct internal field emission across the narrow lattice barrier.",
  "* **Avalanche Breakdown (> 6 V)**: In moderately doped junctions, thermally generated carriers accelerating through the high reverse field acquire sufficient kinetic energy to impact-ionize lattice atoms, liberating secondary electron-hole pairs in a multiplying avalanche cascade.",
  "",
  "==== Varactor (Varicap) Diodes",
  "A **varactor diode** exploits the voltage-variable junction capacitance \\( C_j \\) of a reverse-biased p-n junction. The depletion layer acts as a dielectric gap between conductive neutral regions:",
  "\\[ C_j ( V_R ) = \\frac { C_0 } { \\left( 1 + \\frac { V_R } { V_{bi} } \\right) ^ m } \\]",
  "where \\( m = 0.5 \\) for abrupt junctions and \\( m = 0.33 \\) for hyperabrupt junctions. Varactors serve as solid-state voltage-controlled capacitors in RF voltage-controlled oscillators (VCOs) and frequency synthesizers.",
  "",
  "==== Esaki Tunnel Diodes and Bivector Wave Packet Resonance",
  "In degenerate p-n junctions (doping \\( > 10^{19} \\text{ cm}^{-3} \\)), the depletion barrier is under 10 nm wide. Under small forward bias, overlapping energy states allow bivector electromagnetic wave packets to transmit continuously across the thin lattice barrier. As forward bias increases, state alignment shifts, causing current to drop with increasing voltage. This produces **Negative Differential Resistance (NDR)** (\\( d I / d V < 0 \\)), enabling microwave oscillations up to hundreds of gigahertz without uncaused 'quantum tunneling' magic.",
  "",
  "==== PIN Diodes, LEDs, and Photodiodes",
  "* **PIN Diodes**: An undoped intrinsic (I) layer is sandwiched between P and N regions. At RF frequencies, the injected charge in the I-layer acts as a linear voltage-variable RF resistor, used in high-power RF switches and attenuators.",
  "* **Light-Emitting Diodes (LEDs)**: Forward bias injects carriers across direct-bandgap heterojunctions (e.g., GaN, GaAs), where radiative recombination transduces electrical current directly into coherent or incoherent optical field energy.",
  "* **Photodiodes**: Reverse-biased junctions where incident optical wave packets generate electron-hole pairs in the depletion region, generating a photocurrent \\( I_{ph} = R P_{opt} \\) proportional to optical power."
].join("\n");

const chap4Sec5Content = [
  "=== Integrated Diode Arrays, Rectifier Bridges, and Logic Switching Matrices",
  "",
  "==== Full-Wave Bridge Rectifiers and Filtering",
  "Power rectification converts AC utility lines into stable DC voltage using a 4-diode Graetz bridge rectifier. The full-wave rectified output voltage \\( V_{dc} = \\frac { 2 V_m } { \\pi } \\) feeds a reservoir condenser filter \\( C \\). The peak-to-peak ripple voltage under load current \\( I_L \\) is:",
  "\\[ V_r = \\frac { I_L } { 2 f C } \\]",
  "",
  "==== Monolithic TVS Diode Arrays",
  "Modern high-speed digital interfaces (USB4, HDMI 2.1) employ monolithic Transient Voltage Suppression (TVS) diode arrays. Low-capacitance (< 0.2 pF) steering diodes divert electrostatic discharge (ESD) transients into zener clamping diodes, protecting sensitive micro-scale integrated circuits from kilovolt spikes.",
  "",
  "==== Historical Diode Logic (DL) and ROM Switching Matrices",
  "Before transistor-transistor logic (TTL), early digital computing employed **Diode Logic (DL)** matrices. Diode AND gates and OR gates formed boolean logic networks. Monolithic diode matrix arrays served as read-only memories (ROMs), where presence or absence of a diode at row-column intersections defined permanent bit patterns."
].join("\n");

const chap4Sec6Content = [
  "=== Formal Postulates and Theorems of Solid-State Diode Mechanics",
  "",
  "[#theorem-deconstruction-quantum-semiconductor-fallacy]",
  "[THEOREM]",
  ".Theorem: Epistemological Demolition of the ‘Quantum’ Semiconductor Fallacy and Derivation of Solid-State Empirical Laws",
  "====",
  "Solid-state semiconductor devices—including point-contact rectifiers, p-n junction diodes, and Schottky barriers—are classical physical electrodynamic structures governed by multivector field stress-energy tensor states \\( T \\in Cl ( 4 , 1 , 1 ) \\) co-propagating on discrete atomic crystal lattices \\( \\mathcal { G } _ N \\). The assertion that solid-state devices rely on uncaused 'quantum principles' or Bohr's 'complementarity' is an epistemological defect arising from term coöptation. Facts previously cataloged as empirical laws are derived directly from the Master Field Equation \\( D F = J \\) without 'quantum' mysticism.",
  "",
  "*Proof:*",
  ". **Solid-State Lattice Field Structure**: In a solid crystal, atomic nuclei and electron shell clouds form a discrete periodic field grid \\( \\mathcal { G } _ N \\). The local charge density \\( \\rho ( \\mathbf { r } ) \\) and current density \\( \\mathbf { J } ( \\mathbf { r } ) \\) satisfy the Master Field Equation \\( D F = J \\).",
  "",
  ". **Demolition of Term Coöptation**: Prior to the Master Field Equation, experimental observations regarding energy band gaps, built-in potential barriers, and junction currents were empirical regularities awaiting first-principles derivation. Mislabeling these empirical laws as 'fundamental quantum principles' through Bohr's complementarity principle substituted verbal trickery for physical causality. In \\( Cl ( 4 , 1 , 1 ) \\), all carrier transport (drift, diffusion, barrier transmission) is proven to be deterministic multivector wave packet propagation across finite spatial grid boundaries.",
  "",
  ". **First-Principles Consistency**: Because all solid-state boundary transport equations follow strictly from \\( D F = J \\) on discrete grid \\( \\mathcal { G } _ N \\), solid-state devices are established as classical electrodynamic field engines, completely eliminating the 'quantum' semiconductor fallacy. \\( \\square \\)",
  "====",
  "",
  "[#theorem-shockley-diode-equation-m-res-derivation]",
  "[THEOREM]",
  ".Theorem: Derivation of the Shockley Diode Equation from the Master Field Equation",
  "====",
  "On a discrete lattice grid \\( \\mathcal { G } _ N \\), the total current density \\( J \\) across a p-n junction under applied bias \\( V \\) obeys the exact field relation:",
  "\\[ I ( V ) = I_s \\left( e ^ { \\frac { V } { V_t } } - 1 \\right) \\]",
  "where saturation current \\( I_s \\) is determined by minority carrier diffusion length and thermal generation rate.",
  "",
  "*Proof:*",
  ". **Space Charge and Built-in Potential**: The divergence of the electric field in the depletion layer \\( \\nabla \\cdot \\mathbf { E } = \\frac { \\rho } { \\varepsilon } \\) establishes built-in potential \\( V_{bi} = V_t \\ln ( N_A N_D / n_i^2 ) \\).",
  "",
  ". **Barrier Lowering and Carrier Injection**: An applied forward bias \\( V \\) reduces the potential step to \\( V_{bi} - V \\). Minority carrier concentrations at the boundary edges of the depletion region scale exponentially according to the Boltzmann multivector factor \\( n ( x_p ) = n_{p0} e^{V / V_t} \\).",
  "",
  ". **Diffusion Current Integration**: Integrating the minority carrier diffusion continuity equation \\( D_n \\frac { d^2 n } { d x^2 } - \\frac { n - n_{p0} } { \\tau_n } = 0 \\) over the neutral p and n regions yields exact exponential current \\( I = I_s ( e^{V / V_t} - 1 ) \\). \\( \\square \\)",
  "===="
].join("\n");

const chap4Sec7Content = [
  "=== Completely Worked Technical Examples",
  "",
  "==== Example 1: Cat’s Whisker Point-Contact Rectifier Work Function and Junction Resistance",
  "**Problem Statement:** A phosphor-bronze wire point contact (work function \\( \\Phi_m = 4.50 \\text{ eV} \\)) is pressed against an n-type galena (\\( \\text{PbS} \\)) crystal (electron affinity \\( \\chi_s = 3.80 \\text{ eV} \\)). Calculate the built-in barrier height \\( \\Phi_{BN} \\) and the reverse saturation current density \\( J_s \\) at \\( T = 300 \\text{ K} \\) assuming Richardson constant \\( A^* = 120 \\text{ A/(cm}^2 \\text{K}^2) \\).",
  "",
  "**Solution:**",
  "1. **Schottky Barrier Height**: \\( \\Phi_{BN} = \\Phi_m - \\chi_s = 4.50 \\text{ eV} - 3.80 \\text{ eV} = 0.70 \\text{ eV} \\).",
  "2. **Reverse Saturation Current Density**: \\( J_s = A^* T^2 e^{ - \\frac { \\Phi_{BN} } { V_t } } = 120 \\times ( 300 )^2 e^{ - \\frac { 0.70 } { 0.02585 } } = 1.08 \\times 10^7 \\times e^{-27.08} \\approx 1.08 \\times 10^7 \\times 1.74 \\times 10^{-12} \\approx 1.88 \\times 10^{-5} \\text{ A/cm}^2 \\) (\\( 18.8 \\ \\mu\\text{A/cm}^2 \\)).",
  "",
  "==== Example 2: P-N Junction Built-in Potential, Depletion Width, and Bias Current",
  "**Problem Statement:** A silicon p-n junction diode has acceptor doping \\( N_A = 10^{17} \\text{ cm}^{-3} \\), donor doping \\( N_D = 10^{16} \\text{ cm}^{-3} \\), intrinsic carrier density \\( n_i = 1.5 \\times 10^{10} \\text{ cm}^{-3} \\), cross-sectional area \\( A = 1.0 \\text{ mm}^2 \\), and reverse saturation current \\( I_s = 1.0 \\text{ pA} \\) at 300 K. Calculate built-in potential \\( V_{bi} \\) and forward current at \\( V = 0.65 \\text{ V} \\).",
  "",
  "**Solution:**",
  "1. **Built-in Potential \\( V_{bi} \\)**: \\( V_{bi} = ( 0.02585 ) \\ln \\left( \\frac { 10^{17} \\times 10^{16} } { ( 1.5 \\times 10^{10} )^2 } \\right) = 0.02585 \\ln \\left( \\frac { 10^{33} } { 2.25 \\times 10^{20} } \\right) = 0.02585 \\ln ( 4.444 \\times 10^{12} ) = 0.02585 \\times ( 29.12 ) \\approx 0.753 \\text{ V} \\).",
  "2. **Forward Bias Current at \\( V = 0.65 \\text{ V} \\)**: \\( I = I_s e^{V / V_t} = 1.0 \\times 10^{-12} e^{0.65 / 0.02585} = 1.0 \\times 10^{-12} e^{25.145} \\approx 1.0 \\times 10^{-12} \\times ( 8.32 \\times 10^{10} ) = 83.2 \\text{ mA} \\).",
  "",
  "==== Example 3: Esaki Tunnel Diode Negative Differential Resistance and Oscillator Tuning",
  "**Problem Statement:** An Esaki tunnel diode exhibits peak current \\( I_p = 10.0 \\text{ mA} \\) at peak voltage \\( V_p = 50 \\text{ mV} \\) and valley current \\( I_v = 1.0 \\text{ mA} \\) at valley voltage \\( V_v = 350 \\text{ mV} \\). Calculate the average Negative Differential Resistance (NDR) \\( R_N \\) in the tunneling decay region and the resonant frequency when connected across a 10 nH inductor and 5 pF tuning condenser.",
  "",
  "**Solution:**",
  "1. **Negative Differential Resistance \\( R_N \\)**: \\( R_N = \\frac { V_v - V_p } { I_v - I_p } = \\frac { 0.350 - 0.050 } { 0.001 - 0.010 } = \\frac { 0.300 } { - 0.009 } \\approx - 33.33 \\ \\Omega \\).",
  "2. **Resonant Oscillation Frequency**: \\( f_0 = \\frac { 1 } { 2 \\pi \\sqrt{L C} } = \\frac { 1 } { 2 \\pi \\sqrt{ 10 \\times 10^{-9} \\times 5 \\times 10^{-12} } } = \\frac { 1 } { 2 \\pi \\sqrt{ 5 \\times 10^{-20} } } = \\frac { 1 } { 2 \\pi \\times 2.236 \\times 10^{-10} } \\approx 711.8 \\text{ MHz} \\)."
].join("\n");



const volume5Object = {
  id: "volume-5-spectral-electronics-computing",
  title: "The Iris Number System, Volume V",
  subtitle: "Applications to Spectral Theory, Circuit Theory, Transmission Theory, Electronics, Computing",
  author: "Frédéric Blondin Custer",
  version: "1.0.0",
  lastUpdated: "2026-08-08",
  description: "Volume V establishes first-principles spectral analysis, circuit theory, transmission theory, electronics, and digital computing on discrete multiscale resolution grids without complex numbers, complex planes, or continuum infinities, unifying Fourier, Cosine, Sine, Hartley, Laplace, Z, Mellin, Hankel, Radon, and Wavelet transforms within real geometric bivector phase space.",
  filename: "Iris_Number_System-05-Volume_V_Spectral_Analysis_etc.adoc",
  chapters: [
    {
      id: "chap-unified-spectral-analysis",
      title: "First-Principles Unified Spectral Analysis without Complex Numbers",
      summary: "This chapter establishes a unified mathematical framework for all major linear spectral transforms on discrete multiscale resolution grids \\( \\mathcal { G } _ N \\), demonstrating that complex numbers and continuum planes are unnecessary contrivances when signals and operators are represented via real geometric bivectors and linear difference matrices.",
      sections: [
        {
          id: "sec-fallacy-complex-plane-real-bivector-kinematics",
          title: "The Fallacy of the Continuum Complex Plane and Real Bivector Kinematics",
          contentAsciiDoc: sec1Content
        },
        {
          id: "sec-unified-operator-kernel-formulation",
          title: "Unified Operator Kernel Formulation for Conventional Transforms",
          contentAsciiDoc: sec2Content
        },
        {
          id: "sec-rigorous-proofs-spectral-theorems",
          title: "Rigorous Proofs and Mathematical Theorems",
          contentAsciiDoc: sec3Content
        },
        {
          id: "sec-completely-worked-textbook-examples",
          title: "Completely Worked Textbook Examples",
          contentAsciiDoc: sec4Content
        }
      ]
    },
    {
      id: "chap-circuit-theory",
      title: "Circuit Theory: Kirchhoff’s Laws, Lumped Circuit Elements, and Shielded Enclosures",
      summary: "This chapter formulates classical and high-frequency circuit theory from first principles on discrete multiscale resolution grids \\( \\mathcal { G } _ N \\), deriving Kirchhoff's voltage and current laws, resistors, capacitors (condensers), inductors (coils), transformers, antennas, earth grounds, grounded chassis, and electromagnetic shielding.",
      sections: [
        {
          id: "sec-kirchhoff-laws-circuit-topologies",
          title: "Kirchhoff’s Laws and Fundamental Circuit Topologies on Discrete Resolution Grids",
          contentAsciiDoc: circuitSec1Content
        },
        {
          id: "sec-resistors-condensers-coils",
          title: "Resistors, Capacitors (Condensers), and Inductors (Coils)",
          contentAsciiDoc: circuitSec2Content
        },
        {
          id: "sec-transformers-antennas-impedance-matching",
          title: "Transformers, Antennas, and Impedance Matching",
          contentAsciiDoc: circuitSec3Content
        },
        {
          id: "sec-earth-grounds-chassis-shielding",
          title: "Earth Grounds, Grounded Chassis, Electrostatic Shielding, and Faraday Enclosures",
          contentAsciiDoc: circuitSec4Content
        },
        {
          id: "sec-formal-postulates-theorems-circuit-theory",
          title: "Formal Postulates and Theorems of Circuit Theory",
          contentAsciiDoc: circuitSec5Content
        },
        {
          id: "sec-worked-examples-circuit-theory",
          title: "Completely Worked Technical Examples",
          contentAsciiDoc: circuitSec6Content
        }
      ]
    },
    {
      id: "chap-transmission-theory-power-machinery",
      title: "Transmission Theory, Power Engineering, and Electrical Machinery",
      summary: "This chapter establishes the theory of transmission lines as electromagnetic waveguides where power travels in the dielectric, demystifying Poynting vector transport through first-principles electrodynamics. It covers telephone, cable TV, internet cables, high-voltage AC/DC power transmission grids, electrodynamic generators, induction motors, synchronous motors, brushed DC motors, and brushless DC (BLDC) motors.",
      sections: [
        {
          id: "sec-guided-wave-transmission-dielectric-energy",
          title: "Guided Wave Dynamics in Transmission Lines and Dielectric Energy Transport",
          contentAsciiDoc: transmissionSec1Content
        },
        {
          id: "sec-power-grids-telephone-catv-internet",
          title: "High-Voltage Power Grids, Telephone, Cable TV, and High-Speed Internet Transmission",
          contentAsciiDoc: transmissionSec2Content
        },
        {
          id: "sec-generators-induction-synchronous-dc-motors",
          title: "Electrodynamic Generators and AC/DC Electric Motors",
          contentAsciiDoc: transmissionSec3Content
        },
        {
          id: "sec-brushless-dc-bldc-motors-commutation",
          title: "Brushless DC (BLDC) Motors: Electronic Commutation, Permanent Magnets, and Inverter Driving",
          contentAsciiDoc: transmissionSec4Content
        },
        {
          id: "sec-formal-postulates-theorems-transmission-machinery",
          title: "Formal Postulates and Theorems of Transmission Theory and Electrical Machines",
          contentAsciiDoc: transmissionSec5Content
        },
        {
          id: "sec-worked-examples-transmission-machinery",
          title: "Completely Worked Technical Examples",
          contentAsciiDoc: transmissionSec6Content
        }
      ]
    },
    {
      id: "chap-impulse-responses-transfer-functions",
      title: "Theory of Impulse Responses and Transfer Functions: m-Resolution Analog and Digital System Dynamics",
      summary: "This chapter formulates the linear theory of physical systems, impulse responses, difference convolution operators, and transfer functions across m-resolution (analog) physical grids and digital sampled grids without continuum infinities or point-mass idealizations.",
      sections: [
        {
          id: "sec-m-res-and-digital-system-paradigms",
          title: "m-Resolution Analog and Digital System Paradigms",
          contentAsciiDoc: chap2Sec1Content
        },
        {
          id: "sec-shift-invariant-convolution-transfer-functions",
          title: "Shift-Invariant Systems, Difference Convolution, and Bivector Transfer Functions",
          contentAsciiDoc: chap2Sec2Content
        },
        {
          id: "sec-bilinear-resolution-mapping-stability",
          title: "Bilinear Resolution Mapping and System Stability",
          contentAsciiDoc: chap2Sec3Content
        },
        {
          id: "sec-proofs-system-dynamics-theorems",
          title: "Rigorous Proofs and System Dynamics Theorems",
          contentAsciiDoc: chap2Sec4Content
        },
        {
          id: "sec-worked-examples-impulse-transfer",
          title: "Completely Worked Textbook Examples",
          contentAsciiDoc: chap2Sec5Content
        }
      ]
    },
    {
      id: "chap-electron-tubes-thermionic-valves",
      title: "Theory of Electron Tubes and Thermionic Valves: Field Physics, Grid Control, and Specialized Cathode-Ray Devices",
      summary: "This chapter develops the physical theory of thermionic emission, space charge dynamics, grid voltage modulation, and multi-electrode electron tubes (valves) within the m-resolution framework of the Master Field Equation. In addition to fundamental diodes, triodes, tetrodes, and pentodes, detailed analyses are given for specialized devices including beam power tubes, heptodes/hexodes, klystrons, magnetrons, and diverse cathode-ray tubes (electrostatic and electromagnetic display CRTs, storage tubes, traveling-wave oscilloscopes, and image orthicons/vidicons).",
      sections: [
        {
          id: "sec-thermionic-emission-space-charge-dynamics",
          title: "Thermionic Emission, Child-Langmuir Space Charge Law, and m-Resolution Field Dynamics",
          contentAsciiDoc: chap3Sec1Content
        },
        {
          id: "sec-multi-electrode-valves",
          title: "Multi-Electrode Valves: Diodes, Triodes, Tetrodes, Pentodes, Beam Power Tubes, and Multigrid Mixers",
          contentAsciiDoc: chap3Sec2Content
        },
        {
          id: "sec-cathode-ray-tubes-specialized-beam-devices",
          title: "Cathode-Ray Tubes and Specialized Vacuum Devices: Electrostatic, Electromagnetic, Storage, and Image Tubes",
          contentAsciiDoc: chap3Sec3Content
        },
        {
          id: "sec-electron-tube-fabrication-getter-flashing",
          title: "Electron Tube Fabrication, Thermal Outgassing, and the Physics of the Barium Getter Mirror",
          contentAsciiDoc: chap3Sec4Content
        },
        {
          id: "sec-proofs-and-field-theorems-electron-tubes",
          title: "Formal Postulates and Theorems of Vacuum Tube Field Dynamics",
          contentAsciiDoc: chap3Sec5Content
        },
        {
          id: "sec-worked-examples-electron-tubes",
          title: "Completely Worked Technical Examples",
          contentAsciiDoc: chap3Sec6Content
        }
      ]
    },
    {
      id: "chap-solid-state-diodes-semiconductor-rectifiers",
      title: "Theory of Solid-State Diodes and Semiconductor Rectifiers: Point-Contact Crystals, Junction Dynamics, and Integrated Diode Matrices",
      summary: "This chapter establishes the physical, mathematical, and field-theoretic foundations of solid-state rectifiers and semiconductor diodes within the m-resolution framework of the Master Field Equation in Cl(4,1,1). Beginning with point-contact metal-semiconductor interfaces (galena crystal radios and oxidized razor-blade foxhole detectors), the exposition deconstructs the popular misconception that solid-state devices are 'quantum' magic by revealing how facts known strictly from experiment were historically mislabeled as 'fundamental quantum principles'—a term coöptation initiated by Niels Bohr and Solvay 1927 that replaced empirical law with inexplicable mystery. The chapter then rigorously derives p-n homojunction and heterojunction barrier physics, the Shockley diode equation, Schottky barriers, breakdown dynamics, varactors, tunnel (Esaki) negative differential resistance, PIN switches, LEDs, photodiodes, and integrated diode matrices directly from the Master Field Equation.",
      sections: [
        {
          id: "sec-point-contact-crystal-detectors-makeshift-rectifiers",
          title: "Point-Contact Crystal Detectors and Makeshift Rectifiers: Galena, Pyrite, and Foxhole Radios",
          contentAsciiDoc: chap4Sec1Content
        },
        {
          id: "sec-epistemology-solid-state-quantum-fallacy-term-cooptation",
          title: "Epistemology of Solid-State Physics: Deconstruction of the ‘Quantum’ Semiconductor Fallacy, Term Coöptation, and Empirical Law",
          contentAsciiDoc: chap4Sec2Content
        },
        {
          id: "sec-pn-junction-physics-shockley-schottky",
          title: "P-N Junction Physics, Built-in Potential, Shockley Diode Equation, and Schottky Barriers",
          contentAsciiDoc: chap4Sec3Content
        },
        {
          id: "sec-specialized-solid-state-diodes",
          title: "Specialized Solid-State Diodes: Zener, Avalanche, Varactor, Tunnel, PIN, LEDs, and Photodiodes",
          contentAsciiDoc: chap4Sec4Content
        },
        {
          id: "sec-integrated-diode-arrays-rectifier-bridges-matrices",
          title: "Integrated Diode Arrays, Rectifier Bridges, and Logic Switching Matrices",
          contentAsciiDoc: chap4Sec5Content
        },
        {
          id: "sec-proofs-and-field-theorems-solid-state-diodes",
          title: "Formal Postulates and Theorems of Solid-State Diode Mechanics",
          contentAsciiDoc: chap4Sec6Content
        },
        {
          id: "sec-worked-examples-solid-state-diodes",
          title: "Completely Worked Technical Examples",
          contentAsciiDoc: chap4Sec7Content
        }
      ]
    }
  ]
};

const volume5JsString = `\n\nexport const SPECTRAL_ELECTRONICS_TEXTBOOK: Textbook = ${JSON.stringify(volume5Object, null, 2)};\n\nexport const TEXTBOOK_VOLUMES: Textbook[] = [\n  INITIAL_TEXTBOOK,\n  NUMBER_THEORY_TEXTBOOK,\n  GEOMETRY_ALGEBRA_TEXTBOOK,\n  PHYSICS_CHEMISTRY_TEXTBOOK,\n  SPECTRAL_ELECTRONICS_TEXTBOOK,\n];\n`;

const fullContent = beforePart + volume5JsString + `
export function generateFullAsciiDoc(textbook = INITIAL_TEXTBOOK): string {
  const chapters = getCompleteChapters(textbook.chapters);
  let adoc = \`= \${textbook.title}: \${textbook.subtitle || "Fundamentals"}\\n\`;
  adoc += \`:subtitle: \${textbook.subtitle || "Fundamentals"}\\n\`;
  adoc += \`:author: \${textbook.author}\\n\`;
  adoc += \`:doctype: book\\n\`;
  adoc += \`:toc: left\\n\`;
  adoc += \`:toc-title: Table of Contents\\n\`;
  adoc += \`:stem: latexmath\\n\`;
  adoc += \`:sectnums!:\\n\\n\`;
  adoc += \`\${textbook.description}\\n\\n\`;

  chapters.forEach((chap) => {
    adoc += \`== \${chap.title}\\n\\n\`;
    if (chap.summary) {
      adoc += \`\${chap.summary}\\n\\n\`;
    }
    chap.sections.forEach((sec) => {
      adoc += \`\${sec.contentAsciiDoc.trim()}\\n\\n\`;
    });
  });

  return adoc;
}
`;

fs.writeFileSync(filePath, fullContent, 'utf8');
console.log("Updated src/data/textbookData.ts successfully!");
