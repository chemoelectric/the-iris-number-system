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
  "  Express \\( x [ n ] \\) in terms of its orthogonal spectral expansion \\( x [ n ] = \\frac { 1 } { \\sqrt { N } } \\sum _ { k = 0 } ^ { N - 1 } \\hat { X } [ k ] \\mathcal { E } _ k [ n ] \\). Computing the sum of squares \\( \\sum _ { n = 0 } ^ { N - 1 } ( x [ n ] ) ^ 2 \\) and substituting the basis orthogonality relation directly yields \\( \\frac { 1 } { N } \\sum _ { k = 0 } ^ { N - 1 } \\| \\hat { X } [ k ] \\| ^ 2 \\). This proves exact Parseval-Plancherel energy conservation strictly within finite discrete sums on \\( \\mathcal { G } _ N \\). \\( \\square \\)",
  "====",
  "",
  "[#theorem-z-laplace-isomorphism-discrete-decay]",
  "[THEOREM]",
  ".Theorem: Isomorphism of Discrete Z-Transform and Damped Bivector Phase Precession Theorem",
  "====",
  "Let \\( s = \\sigma + \\mathbf { I } \\omega \\) be the continuous-domain damped bivector Laplace operator in \\( Cl ( 0 , 1 ) \\), where \\( \\sigma \\in \\mathbb { R } \\) is the lattice attenuation coefficient and \\( \\omega \\in \\mathbb { R } \\) is the angular phase velocity.",
  "",
  "Under spatial-temporal sampling on discrete resolution grid \\( \\mathcal { G } _ N \\) with step spacing \\( \\delta \\), the Laplace transform operator \\( e ^ { - s n \\delta } \\) is algebraically isomorphic to the discrete Z-transform operator \\( z ^ { - n } \\) under the exact discrete mapping:",
  "",
  "\\[ z = e ^ { s \\delta } = r e ^ { \\mathbf { I } \\theta } \\]",
  "where the discrete radial expansion factor is \\( r = e ^ { \\sigma \\delta } \\) and the discrete phase step angle is \\( \\theta = \\omega \\delta \\).",
  "",
  "*Proof:*",
  ". **Expansion of Laplace Kernel**:",
  "  Evaluate the Laplace kernel at discrete time step \\( t_n = n \\delta \\):",
  "  \\[ e ^ { - s t_n } = e ^ { - ( \\sigma + \\mathbf { I } \\omega ) n \\delta } = e ^ { - \\sigma n \\delta } e ^ { - \\mathbf { I } \\omega n \\delta } \\]",
  "  Applying real Euler bivector decomposition:",
  "  \\[ = ( e ^ { \\sigma \\delta } ) ^ { - n } \\left( \\cos ( n \\omega \\delta ) - \\mathbf { I } \\sin ( n \\omega \\delta ) \\right) \\]",
  "",
  ". **Algebraic Substitution**:",
  "  Define \\( r = e ^ { \\sigma \\delta } > 0 \\) and \\( \\theta = \\omega \\delta \\in [ - \\pi , \\pi ) \\). The bivector number \\( z \\in Cl ( 0 , 1 ) \\) is:",
  "  \\[ z = r e ^ { \\mathbf { I } \\theta } = r ( \\cos \\theta + \\mathbf { I } \\sin \\theta ) \\]",
  "  Raising \\( z \\) to the negative power \\( - n \\) by De Moivre's real bivector theorem yields:",
  "  \\[ z ^ { - n } = r ^ { - n } ( \\cos ( n \\theta ) - \\mathbf { I } \\sin ( n \\theta ) ) = e ^ { - \\sigma n \\delta } e ^ { - \\mathbf { I } \\omega n \\delta } = e ^ { - s n \\delta } \\]",
  "  This establishes an exact, bijective algebraic isomorphism between the damped bivector Laplace operator and the discrete Z-transform operator on grid \\( \\mathcal { G } _ N \\). \\( \\square \\)",
  "===="
].join("\n");

const sec4Content = [
  "=== Completely Worked Textbook Examples",
  "",
  "==== Example 1: Real Bivector Discrete Fourier Spectrum and Energy Conservation on \\( \\mathcal { G } _ 4 \\)",
  "",
  "**Problem Statement:**",
  "Given a real digital spatial-temporal signal sequence \\( x [ n ] = [ 1 , 1 , 0 , 0 ] ^ T \\) defined on the 4-point resolution grid \\( \\mathcal { G } _ 4 = \\{ 0 , 1 , 2 , 3 \\} \\) with grid spacing \\( \\delta = 1 \\):",
  "1. Compute the multivector Discrete Fourier Spectrum \\( \\hat { X } [ k ] \\) for all harmonic modes \\( k \\in \\{ 0 , 1 , 2 , 3 \\} \\) using the real bivector rotor kernel:",
  "   \\[ \\mathcal { K } _ \\text{DFT} [ n , k ] = \\cos \\left( \\frac { 2 \\pi n k } { 4 } \\right) - \\mathbf { I } \\sin \\left( \\frac { 2 \\pi n k } { 4 } \\right) \\]",
  "   where \\( \\mathbf { I } \\) is the unit bivector in \\( Cl ( 0 , 1 ) \\) satisfying \\( \\mathbf { I } ^ 2 = - 1 \\).",
  "2. Explicitly verify the Parseval-Plancherel energy conservation theorem between physical space and real bivector phase space.",
  "",
  "**Step-by-Step Solution:**",
  "* **Harmonic Mode \\( k = 0 \\)**:",
  "  The kernel evaluates to \\( \\mathcal { K } _ \\text{DFT} [ n , 0 ] = \\cos ( 0 ) - \\mathbf { I } \\sin ( 0 ) = 1 \\) for all \\( n \\).",
  "  \\[ \\hat { X } [ 0 ] = \\sum _ { n = 0 } ^ { 3 } x [ n ] ( 1 ) = 1 + 1 + 0 + 0 = 2 \\]",
  "  This is a pure scalar grade multivector (\\( \\operatorname { Sc } = 2, \\operatorname { Biv } = 0 \\)), representing the DC bias / total spatial field sum.",
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
  "Linear circuit theory is the lumped-parameter projection of the Master Field Equation \\( D F = J \\) on discrete spatial-temporal resolution grids \\( \\mathcal { G } _ N \\). When physical circuit dimensions are small relative to the wavelength of field oscillations, electric and magnetic field energy distributions compress into lumped nodes and branches.",
  "",
  "==== Derivation of Kirchhoff’s Voltage Law (KVL)",
  "In a quasi-static multivector field configuration, the electric vector field \\( \\mathbf { E } \\) is the gradient of a discrete scalar potential field \\( \\Phi \\) on \\( \\mathcal { G } _ N \\) (\\( \\mathbf { E } = - \\nabla \\Phi \\)). Integrating the electric field along any closed loop aperture \\( \\mathcal { C } \\) composed of discrete circuit branches yields:",
  "\\[ \\oint _ { \\mathcal { C } } \\mathbf { E } \\cdot d \\mathbf { l } = - \\oint _ { \\mathcal { C } } \\nabla \\Phi \\cdot d \\mathbf { l } = 0 \\]",
  "On a discrete mesh composed of \\( M \\) branches, this field loop integral maps directly to **Kirchhoff’s Voltage Law (KVL)**:",
  "\\[ \\sum _ { k = 1 } ^ { M } V _ k = 0 \\]",
  "stating that the sum of potential differences around any closed circuit loop is identically zero.",
  "",
  "==== Derivation of Kirchhoff’s Current Law (KCL)",
  "The current density vector \\( \\mathbf { J } \\) satisfies local charge conservation governed by the field continuity equation \\( \\nabla \\cdot \\mathbf { J } + \\frac { \\partial \\rho } { \\partial t } = 0 \\). Integrating this continuity relation over a closed spatial boundary \\( \\mathcal { S } \\) enclosing a circuit junction node yields:",
  "\\[ \\int _ { \\mathcal { S } } \\mathbf { J } \\cdot d \\mathbf { A } = - \\frac { d Q _ \\text{node} } { d t } \\]",
  "In quasi-static lumped circuits, no net electric charge accumulates at an ideal node (\\( \\frac { d Q _ \\text{node} } { d t } = 0 \\)), yielding **Kirchhoff’s Current Law (KCL)**:",
  "\\[ \\sum _ { k = 1 } ^ { K } I _ k = 0 \\]",
  "stating that the sum of electric currents entering any circuit node equals the sum of currents leaving that node."
].join("\n");

const circuitSec2Content = [
  "=== Resistors, Capacitors (Condensers), and Inductors (Coils)",
  "",
  "Physical lumped circuit elements represent localized energy dissipation, electric field energy storage, or magnetic field energy storage in the m-resolution field medium.",
  "",
  "==== Resistors and Ohmic Dissipation",
  "A resistor of resistance \\( R \\) represents the irreversible conversion of electrodynamic field energy into lattice thermal phonons via microscopic electron-lattice collision scattering. Ohm’s law is the localized constitutive relation \\( \\mathbf { J } = \\sigma \\mathbf { E } \\), mapping in lumped terms to:",
  "\\[ V = I R \\]",
  "The rate of irreversible thermal energy dissipation into the grid lattice is given by Joule's law: \\( P = I V = I ^ 2 R = \\frac { V ^ 2 } { R } \\).",
  "",
  "==== Capacitors (Condensers)",
  "Capacitors—historically and traditionally designated as **condensers** in early electrical engineering—store electric field energy within a dielectric volume between conductive plates. Charge accumulation \\( Q \\) on condenser plates generates a terminal potential difference:",
  "\\[ Q = C V \\]",
  "where \\( C = \\varepsilon \\frac { A } { d } \\) is the capacitance. The time variation of terminal voltage drives a physical displacement current \\( I _ C = C \\frac { d V } { d t } \\) through the dielectric medium. The total electric field energy stored in the condenser dielectric is:",
  "\\[ W _ E = \\frac { 1 } { 2 } C V ^ 2 = \\frac { 1 } { 2 } \\frac { Q ^ 2 } { C } \\]",
  "",
  "==== Inductors (Coils)",
  "Inductors—traditionally designated as **coils**—store magnetic field energy within the bivector magnetic field generated by current flowing through wound wire turns. Total magnetic flux linkage \\( \\Phi \\) through the coil turns is proportional to the current:",
  "\\[ \\Phi = L I \\]",
  "where \\( L = \\mu \\frac { N ^ 2 A } { l } \\) is the coil inductance. By Faraday’s law of induction, a time-varying magnetic flux induces a counter-electromotive force (back-EMF) across coil terminals:",
  "\\[ V _ L = L \\frac { d I } { d t } \\]",
  "The total magnetic field energy stored within the coil turns is: \\( W _ B = \\frac { 1 } { 2 } L I ^ 2 \\)."
].join("\n");

const circuitSec3Content = [
  "=== Transformers, Antennas, and Impedance Matching",
  "",
  "==== Transformers and Mutual Inductance",
  "When two or more inductors (coils) share a common magnetic flux path through a high-permeability core, time-varying current in the primary coil induces a voltage in the secondary coil via mutual inductance \\( M = k \\sqrt { L _ 1 L _ 2 } \\) (where \\( k \\le 1 \\) is the magnetic coupling coefficient). For an ideal transformer with primary turns \\( N _ 1 \\) and secondary turns \\( N _ 2 \\):",
  "\\[ \\frac { V _ 2 } { V _ 1 } = \\frac { N _ 2 } { N _ 1 } , \\quad \\frac { I _ 2 } { I _ 1 } = \\frac { N _ 1 } { N _ 2 } \\]",
  "A load impedance \\( Z _ L \\) connected to the secondary terminals reflects back to the primary terminals as an equivalent input impedance:",
  "\\[ Z _ \\text{in} = \\left( \\frac { N _ 1 } { N _ 2 } \\right) ^ 2 Z _ L \\]",
  "enabling complete impedance matching between power sources and loads.",
  "",
  "==== Antennas as Circuit-Field Launching Elements",
  "An antenna serves as an electrodynamic transducer between lumped guided currents in a circuit and propagating wave fields in the spatial grid \\( \\mathcal { G } _ N \\). Characterized by its radiation resistance \\( R _ \\text{rad} \\), an antenna converts terminal current \\( I_0 \\) into launched electromagnetic wave power \\( P _ \\text{rad} = \\frac { 1 } { 2 } I _ 0 ^ 2 R _ \\text{rad} \\)."
].join("\n");

const circuitSec4Content = [
  "=== Earth Grounds, Grounded Chassis, Electrostatic Shielding, and Faraday Enclosures",
  "",
  "==== Earth Grounds and Terrestrial Reference Planes",
  "An **earth ground** connects electrical systems directly to the physical conductive mass of planet Earth via buried copper rods or plates. The terrestrial earth acts as an unbounded, zero-potential electric charge sink, stabilizing system reference potentials and providing a safe discharge path for lightning and fault surges.",
  "",
  "==== Grounded Chassis and Signal Return Paths",
  "A **grounded chassis** uses the metallic enclosure or structural frame of an electronic device as a common zero-volts reference plane and return path for power and signal currents. It is vital to distinguish safety earth ground from chassis signal ground to prevent spurious **ground loops**, where circulating noise currents induce hum and interference across sensitive signal channels.",
  "",
  "==== Electrostatic and Electromagnetic Shielding",
  "A **Faraday cage** or conductive metallic shield encloses sensitive circuits to exclude external electric fields. Free charges inside the conductive shield realign under external fields, establishing an equal and opposite surface charge density that completely cancels interior electrostatic fields. At high frequencies, electromagnetic wave fields penetrate conductive shields only to the finite **skin depth** \\( \\delta _ s = \\sqrt { \\frac { 2 } { \\omega \\mu \\sigma } } \\), providing exponential field attenuation \\( E ( z ) = E_0 e ^ { - z / \\delta _ s } \\) through the chassis metal."
].join("\n");

const circuitSec5Content = [
  "=== Formal Postulates and Theorems of Circuit Theory",
  "",
  "[#theorem-kirchhoff-laws-derivation-master-field-equation]",
  "[THEOREM]",
  ".Theorem: Derivation of Kirchhoff's Circuit Laws from the Master Field Equation",
  "====",
  "On discrete resolution grid \\( \\mathcal { G } _ N \\), under quasi-static lumped field approximations, the Master Field Equation \\( D F = J \\) strictly implies Kirchhoff’s Voltage Law (\\( \\sum V_k = 0 \\)) around closed circuit loops and Kirchhoff’s Current Law (\\( \\sum I_k = 0 \\)) at circuit node junctions.",
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
  "===="
].join("\n");

const circuitSec6Content = [
  "=== Completely Worked Technical Examples",
  "",
  "==== Example 1: Multivector Nodal Analysis of an RLC Bridged Network",
  "**Problem Statement:** An AC source \\( V_s ( t ) = 120 \\cos ( 2 \\pi f t ) \\) at \\( f = 60 \\text{ Hz} \\) drives an RLC circuit with resistor \\( R = 10 \\ \\Omega \\), condenser \\( C = 100 \\ \\mu \\text{F} \\), and coil \\( L = 50 \\text{ mH} \\) connected in series. Calculate coil reactance \\( X_L \\), condenser reactance \\( X_C \\), net impedance \\( Z \\), current amplitude \\( I_0 \\), and total stored field energy.",
  "",
  "**Solution:**",
  "1. **Coil Reactance \\( X_L \\)**: \\( X_L = 2 \\pi f L = 2 \\pi ( 60 ) ( 0.050 ) \\approx 18.85 \\ \\Omega \\).",
  "2. **Condenser Reactance \\( X_C \\)**: \\( X_C = \\frac { 1 } { 2 \\pi f C } = \\frac { 1 } { 2 \\pi ( 60 ) ( 100 \\times 10 ^ { - 6 } ) } \\approx 26.53 \\ \\Omega \\).",
  "3. **Net Bivector Impedance \\( Z \\)**: \\( Z = R + \\mathbf { I } ( X_L - X_C ) = 10 + \\mathbf { I } ( 18.85 - 26.53 ) = 10 - 7.68 \\mathbf { I } \\ \\Omega \\).",
  "   Magnitude: \\( | Z | = \\sqrt { 10 ^ 2 + ( - 7.68 ) ^ 2 } = \\sqrt { 100 + 58.98 } = \\sqrt { 158.98 } \\approx 12.61 \\ \\Omega \\).",
  "4. **Current Amplitude \\( I_0 \\)**: \\( I_0 = \\frac { V_s } { | Z | } = \\frac { 120 } { 12.61 } \\approx 9.52 \\text{ A} \\).",
  "5. **Peak Stored Energies**: Coil peak energy \\( W _ { B , \\text{peak} } = \\frac { 1 } { 2 } L I_0 ^ 2 = \\frac { 1 } { 2 } ( 0.050 ) ( 9.52 ) ^ 2 \\approx 2.26 \\text{ J} \\)."
].join("\n");

// NEW CHAPTER 3: TRANSMISSION THEORY, POWER ENGINEERING, AND ELECTRICAL MACHINERY
const transmissionSec1Content = [
  "=== Guided Wave Dynamics in Transmission Lines and Dielectric Energy Transport",
  "",
  "A transmission line—whether a coaxial cable, parallel wire pair, or microstrip trace—is a guided wave structure. Electric and magnetic field wave packets are guided through the dielectric medium bounded by the conductive surfaces.",
  "",
  "==== Demolition of the Physics Classroom Poynting Vector Fallacy",
  "In conventional physics education, students were frequently subjected to a demonstration where the professor raised his voice to proclaim as a “shocking surprise” that the Poynting vector \\( \\mathbf { S } = \\mathbf { E } \\times \\mathbf { H } \\) carrying electromagnetic power resides inside the **dielectric insulating medium** between coaxial conductors, rather than inside the metal copper wires. This was presented as an inexplicable, mind-bending paradox.",
  "",
  "The Iris Number System removes this artificial surprise through clear, first-principles reasoning: A transmission line is fundamentally a **waveguide**. The power **OBVIOUSLY** travels through the dielectric medium as a guided electromagnetic wave packet. The conductors do not carry electrical power inside their metal crystal lattice; rather, the conductors exist to **DRIVE** and guide the surrounding electromagnetic fields, establishing boundary conditions that force wave energy to travel smoothly from source to destination.",
  "",
  "==== Telegrapher’s Equations and Wave Parameters",
  "Let a transmission line have distributed resistance \\( R' \\) (\\( \\Omega / \\text{m} \\)), inductance \\( L' \\) (\\( \\text{H} / \\text{m} \\)), conductance \\( G' \\) (\\( \\text{S} / \\text{m} \\)), and capacitance \\( C' \\) (\\( \\text{F} / \\text{m} \\)). The voltage and current wave equations derived from the Master Field Equation are:",
  "\\[ \\frac { \\partial V } { \\partial z } = - R' I - L' \\frac { \\partial I } { \\partial t } , \\quad \\frac { \\partial I } { \\partial z } = - G' V - C' \\frac { \\partial V } { \\partial t } \\]",
  "For lossless dielectrics (\\( R' = 0, G' = 0 \\)), the **characteristic impedance** \\( Z_0 \\) and **phase velocity** \\( v_p \\) are:",
  "\\[ Z_0 = \\sqrt { \\frac { L' } { C' } } , \\quad v_p = \\frac { 1 } { \\sqrt { L' C' } } = \\frac { c } { \\sqrt { \\varepsilon_r \\mu_r } } \\]",
  "When terminated in a load impedance \\( Z_L \\), the reflection coefficient \\( \\Gamma \\) and Standing Wave Ratio (SWR) \\( S \\) are:",
  "\\[ \\Gamma = \\frac { Z_L - Z_0 } { Z_L + Z_0 } , \\quad S = \\frac { 1 + | \\Gamma | } { 1 - | \\Gamma | } \\]"
].join("\n");

const transmissionSec2Content = [
  "=== High-Voltage Power Grids, Telephone, Cable TV, and High-Speed Internet Transmission",
  "",
  "==== High-Voltage Power Transmission Grids",
  "Bulk electrical power transmission across continents uses 3-phase Alternating Current (AC) networks at voltages exceeding 500 kV, or High-Voltage Direct Current (HVDC) lines exceeding 800 kV. High voltages minimize line current \\( I = P / ( \\sqrt{3} V ) \\), reducing conductor ohmic heat losses \\( I^2 R' \\) exponentially.",
  "",
  "==== Telephone, Cable TV, and High-Speed Data Lines",
  "High-frequency information channels—including twisted-pair telephone lines, 75-ohm coaxial Cable TV (CATV) lines, and shielded Ethernet cables—rely on controlled characteristic impedance \\( Z_0 \\) to prevent line reflections and signal attenuation across broad frequency bands."
].join("\n");

const transmissionSec3Content = [
  "=== Electrodynamic Generators and AC/DC Electric Motors",
  "",
  "Electric machines convert mechanical kinetic energy into electrodynamic field energy (generators) or field energy into mechanical torque (motors) via magnetic flux cutting \\( \\mathcal { E } = - \\frac { d \\Phi } { d t } \\) and Lorentz field forces \\( \\mathbf { F } = q ( \\mathbf { E } + \\mathbf { v } \\times \\mathbf { B } ) \\).",
  "",
  "==== Three Classic Motor Types",
  "1. **Induction Motors**: Polyphase AC currents in stator windings generate a rotating magnetic field in the air gap. This field induces circulating currents in a conductive squirrel-cage rotor. The speed difference between the rotating field (synchronous speed \\( n_s = \\frac { 120 f } { p } \\)) and rotor speed \\( n_r \\) defines the **slip** \\( s = \\frac { n_s - n_r } { n_s } \\), producing high torque without sliding electrical contacts.",
  "2. **Synchronous Motors**: The rotor contains DC-excited field coils or permanent magnets that lock in exact phase synchrony with the stator rotating field (\\( n_r = n_s \\)), running at perfectly constant speed under varying mechanical loads.",
  "3. **Brushed DC Motors**: A stationary magnetic field (stator) surrounds a rotating armature (rotor). A mechanical commutator and carbon brushes physically reverse armature coil currents every half-revolution to maintain unidirectional electrodynamic torque."
].join("\n");

const transmissionSec4Content = [
  "=== Brushless DC (BLDC) Motors: Electronic Commutation, Permanent Magnets, and Inverter Driving",
  "",
  "==== Physical Construction and Operating Principle",
  "A **Brushless DC (BLDC) Motor** inverts the roles of traditional DC motor components: high-coercivity permanent magnets (such as Neodymium-Iron-Boron NdFeB) are mounted on the rotating rotor, while multi-phase copper windings are placed on the stationary stator. This eliminates mechanical commutators, carbon brushes, spark erosion, friction, and maintenance.",
  "",
  "==== Electronic Commutation and Inverter Driving",
  "Instead of mechanical brushes, BLDC motors use a solid-state 3-phase **H-bridge inverter** consisting of six power MOSFETs or IGBTs. Rotor position is sensed continuously using embedded Hall-effect sensors or back-EMF zero-crossing detection. The inverter controller switches stator phase currents electronically in trapezoidal (6-step) or sinusoidal sequence, maintaining an optimal \\( 90 ^ \\circ \\) angle between stator magnetic flux and rotor magnet poles for maximum torque generation, achieving efficiencies exceeding 90%."
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
  "2. **Phase Velocity \\( v_p \\)**: \\( v_p = \\frac { c } { \\sqrt{2.25} } = \\frac { 3.0 \\times 10^8 } { 1.50 } = 2.0 \\times 10^8 \\text{ m/s} \\) (66.7% speed of light).",
  "3. **Poynting Power Density at \\( r = a \\)**: \\( S ( a ) = \\frac { V I } { 2 \\pi \\ln(b/a) a^2 } = \\frac { ( 100 ) ( 2.0 ) } { 2 \\pi ( 1.1411 ) ( 1.15 \\times 10^{-3} )^2 } = \\frac { 200 } { 7.170 \\times 10^{-6} ( 1.3225 \\times 10^{-6} ) } \\approx 2.11 \\times 10^7 \\text{ W/m}^2 \\).",
  "4. **Total Power in Dielectric**: \\( P = V I = ( 100 \\text{ V} ) ( 2.0 \\text{ A} ) = 200 \\text{ W} \\). Power inside inner copper conductor is exactly zero."
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
  "Cat's whisker point-contact rectifiers, Galena (PbS), Pyrite (FeS2), and WWII foxhole radios with oxidized steel razor blades."
].join("\n");

const chap4Sec2Content = [
  "=== P-N Junction Physics, Built-in Potential, Shockley Diode Equation, and Schottky Barriers",
  "P-N junction depletion layer dynamics, built-in potential \\( V_{bi} \\), Shockley diode equation \\( I = I_s ( e^{V/V_t} - 1 ) \\), Schottky majority-carrier barriers."
].join("\n");

const chap4Sec3Content = [
  "=== Specialized Solid-State Diodes: Zener, Avalanche, Varactor, Tunnel, PIN, LEDs, and Photodiodes",
  "Zener breakdown, avalanche multiplication, varactor variable capacitance, Esaki tunnel diode negative resistance, PIN RF switches, LEDs, photodiodes."
].join("\n");

const chap4Sec4Content = [
  "=== Integrated Diode Arrays, Rectifier Bridges, and Logic Switching Matrices",
  "Full-wave Graetz bridge rectifiers, capacitor smoothing, monolithic ESD protection arrays, and historical Diode Logic (DL) ROM matrices."
].join("\n");

const chap4Sec5Content = [
  "=== Formal Postulates and Theorems of Solid-State Diode Mechanics",
  "[#theorem-shockley-diode-equation-m-res-derivation]\n[THEOREM]\n.Theorem: Derivation of the Shockley Diode Equation from the Master Field Equation"
].join("\n");

const chap4Sec6Content = [
  "=== Completely Worked Technical Examples\n==== Example 1: Varactor Diode Frequency Tuning and Voltage Sweep in RF Oscillators"
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
      summary: "This chapter establishes the theory of transmission lines as electromagnetic waveguides where power travels in the dielectric, demystifying Poynting vector transport and deconstructing physics classroom misconceptions. It covers telephone, cable TV, internet cables, high-voltage AC/DC power transmission grids, electrodynamic generators, induction motors, synchronous motors, brushed DC motors, and brushless DC (BLDC) motors.",
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
      summary: "This chapter establishes the physical, mathematical, and field-theoretic foundations of solid-state rectifiers and semiconductor diodes within the m-resolution framework of the Master Field Equation in Cl(4,1,1). Beginning with point-contact metal-semiconductor interfaces (galena crystal radios and oxidized razor-blade foxhole detectors), the exposition develops p-n homojunction and heterojunction barrier physics, the Shockley diode equation, Schottky barrier Schottky-Mott band bending, Zener and avalanche breakdown dynamics, varactor voltage-variable capacitance, tunnel (Esaki) quantum-like bivector negative differential resistance, PIN RF attenuation switches, light-emitting diodes (LEDs) and photodiodes, and integrated diode arrays and switching matrices.",
      sections: [
        {
          id: "sec-point-contact-crystal-detectors-makeshift-rectifiers",
          title: "Point-Contact Crystal Detectors and Makeshift Rectifiers: Galena, Pyrite, and Foxhole Radios",
          contentAsciiDoc: chap4Sec1Content
        },
        {
          id: "sec-pn-junction-physics-shockley-schottky",
          title: "P-N Junction Physics, Built-in Potential, Shockley Diode Equation, and Schottky Barriers",
          contentAsciiDoc: chap4Sec2Content
        },
        {
          id: "sec-specialized-solid-state-diodes",
          title: "Specialized Solid-State Diodes: Zener, Avalanche, Varactor, Tunnel, PIN, LEDs, and Photodiodes",
          contentAsciiDoc: chap4Sec3Content
        },
        {
          id: "sec-integrated-diode-arrays-rectifier-bridges-matrices",
          title: "Integrated Diode Arrays, Rectifier Bridges, and Logic Switching Matrices",
          contentAsciiDoc: chap4Sec4Content
        },
        {
          id: "sec-proofs-and-field-theorems-solid-state-diodes",
          title: "Formal Postulates and Theorems of Solid-State Diode Mechanics",
          contentAsciiDoc: chap4Sec5Content
        },
        {
          id: "sec-worked-examples-solid-state-diodes",
          title: "Completely Worked Technical Examples",
          contentAsciiDoc: chap4Sec6Content
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
