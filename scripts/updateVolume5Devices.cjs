const fs = require('fs');
const path = require('path');

const targetFile = path.join(process.cwd(), 'src/data/textbookData.ts');
let content = fs.readFileSync(targetFile, 'utf8');

// Chapter 6 updated sections (already created, keep clean reference)
const chap6Sections = [
  {
    "id": "sec-point-contact-crystal-detectors-and-makeshift-rectifiers-galena-pyrite-and-foxhole-radios",
    "title": "Point-Contact Crystal Detectors and Makeshift Rectifiers: Galena, Pyrite, and Foxhole Radios",
    "contentAsciiDoc": `=== Point-Contact Crystal Detectors and Makeshift Rectifiers: Galena, Pyrite, and Foxhole Radios

Long before the formal industrial development of monocrystalline silicon and germanium p-n junction diodes, practical high-frequency signal rectification was achieved through point-contact metal-semiconductor interfaces.

==== Early Point-Contact Crystal Detectors
In the early era of radio communication, crystal detectors utilized a fine phosphor-bronze or tungsten wire—popularly known as a “cat’s whisker”—lightly pressed against the surface of a natural crystalline mineral. Prominent semiconductors included galena (lead sulfide, \\( \\text{PbS} \\)), iron pyrite (fool’s gold, \\( \\text{FeS}_2 \\)), carborundum (silicon carbide, \\( \\text{SiC} \\)), and chalcopyrite.

When a metal wire contacts a natural semiconductor crystal, the disparity between the metal work function \\( \\Phi_m \\) and the semiconductor electron affinity \\( \\chi_s \\) creates a localized asymmetric electric potential barrier on the discrete lattice grid \\( \\mathcal { G } _ N \\). When an alternating high-frequency radio-frequency (RF) signal is applied, charge carriers easily cross the barrier in one bias direction while experiencing high impedance in the opposite direction. This non-linear current-voltage characteristic rectifies amplitude-modulated (AM) carrier waves, extracting the low-frequency audio envelope without requiring external electrical power.

==== World War II ‘Foxhole Radios’ and Makeshift Oxide Rectifiers
A remarkable demonstration of point-contact rectification occurred during World War II, where soldier prisoners and frontline troops constructed emergency radio receivers known as **foxhole radios**. Lacking access to commercial vacuum tubes or batteries, troops constructed makeshift crystal detectors using discarded materials: a rusty steel razor blade, a pencil lead (graphite rod) or safety pin, a hand-wound antenna coil around a cardboard tube, and an earphone.

The rectification mechanism in a foxhole radio relies on the thin, non-uniform layer of iron oxides (primarily magnetite, \\( \\text{Fe}_3 \\text{O}_4 \\), and hematite, \\( \\text{Fe}_2 \\text{O}_3 \\)) formed on the heat-treated surface of the steel razor blade. When the graphite pencil point contacts the oxide coating, it forms a metal-semiconductor point-contact junction. The localized work-function step between graphite and iron oxide establishes a Schottky-like rectifying barrier. The non-linear current response rectifies ambient AM radio signals, converting RF wave energy directly into acoustic vibrations in the high-impedance earphone.

==== Antenna and Terrestrial Ground Counterpoise Architecture in Passive Crystal Receivers
Because passive crystal and foxhole radio receivers contain no active amplifying transistors, vacuum tubes, or external power sources, all acoustic sound output power must be extracted directly from the intercepted radio-frequency wave field. To maximize intercepted signal power, crystal radios employ an elevated long-wire monopole antenna paired with a direct connection to an earth ground.

In this asymmetric reception topology, the earth ground connection does not act merely as a passive voltage reference; it functions as an active RF counterpoise and supplementary antenna element. Incoming AM wave fields induce image charges and surface displacement currents in the conductive soil. The physical ground connection completes the resonant LC circuit loop, allowing the conductive mass of the earth to act as a secondary field-capturing reflector that drives RF current through the cat’s whisker or razor-blade rectifying junction.

These makeshift devices demonstrated that semiconductor rectification is an intrinsic physical property of asymmetric material boundary interfaces under electromagnetic field excitation, requiring neither artificial vacuum tubes nor speculative 'quantum' mechanisms.`
  },
  {
    "id": "sec-epistemology-of-solid-state-physics-deconstruction-of-the-quantum-semiconductor-fallacy-term-co-ptation-and-empirical-law",
    "title": "Epistemology of Solid-State Physics: Deconstruction of the ‘Quantum’ Semiconductor Fallacy, Term Coöptation, and Empirical Law",
    "contentAsciiDoc": `=== Epistemology of Solid-State Physics: Deconstruction of the ‘Quantum’ Semiconductor Fallacy, Term Coöptation, and Empirical Law

The chapter on semiconductor diodes, being the foundational entry into solid-state electronic devices, is precisely where physical science must dismantle the persistent epistemological fallacy that misleads the public and engineering students into believing that solid-state devices are intrinsically 'quantum' devices.

==== The Giveaway of ‘Solid State’ and the Mislabeling of Empirical Facts
The very designation **'solid state'** provides the immediate giveaway: solid-state electronics concerns the physical, structural electrodynamics of charge currents and wave packets propagating within a solid, discrete crystalline material lattice. Yet twentieth-century mainstream literature routinely asserts that solid-state devices—such as p-n junction diodes, transistors, and integrated circuits—are proof of 'quantum mechanics' and cannot be understood through classical field principles.

In truth, the observed facts regarding semiconductors—such as discrete energy band gaps, carrier drift mobilities, built-in contact potentials, rectifying barrier junctions, and tunneling current dynamics—were, prior to the discovery of the Master Field Equation \\( D F = J \\), known **strictly from experiment**. These experimental findings were empirical laws governing the electrodynamics of bound atomic lattices.

However, twentieth-century physics engaged in a fraudulent **term coöptation of 'fundamental principle'**. Facts that were discovered experimentally and awaited derivation from first principles were mislabeled as 'fundamental quantum principles'. What was actually meant by these observed facts was **empirical law**.

==== The Myth of the 'Quantum Model of a Transistor' and Practical Engineering Reality
A ubiquitous artifact of this verbal trickery is the popular claim that solid-state transistors—such as Junction Field-Effect Transistors (JFETs), Bipolar Junction Transistors (BJTs), and Metal-Oxide-Semiconductor Field-Effect Transistors (MOSFETs)—depend upon or are designed using a 'quantum model'. In popular discourse, commentators frequently challenge skeptics by asking: “How do you explain the quantum model of a transistor?”

The rigorous answer from electrical engineering is simple and direct: **there is no such model**. Practical semiconductor devices are not designed, modeled, or analyzed using 'quantum' models. In actual engineering practice, a transistor—such as an n-channel JFET—is modeled strictly as a beam of charge carriers (electrons or holes) moving through a solid semiconductor crystal lattice under the influence of classical electric and magnetic fields, governed by Poisson's equation, carrier drift, diffusion, and charge conservation balance equations:
\\[ \\nabla^2 V = - \\frac { \\rho } { \\varepsilon }, \\quad \\mathbf { J }_n = q n \\mu_n \\mathbf { E } + q D_n \\nabla n, \\quad \\frac { \\partial n } { \\partial t } = \\frac { 1 } { q } \\nabla \\cdot \\mathbf { J }_n + G_n - R_n \\]

In an n-channel JFET, for example, a reverse-biased p-n junction gate controls the effective cross-sectional channel width through classical electrostatic depletion layer expansion. The pinch-off voltage \\( V_P \\) and drain saturation current \\( I_{DSS} \\) follow directly from boundary electrostatic potential analysis across the physical channel width:
\\[ V_P = \\frac { q N_D a^2 } { 2 \\varepsilon }, \\quad I_D = I_{DSS} \\left( 1 - \\frac { V_{GS} } { V_P } \\right)^2 \\]

Where experimental parameters appear—such as effective carrier masses, scattering relaxation times, or energy band gaps—they were historically known **strictly from experiment**. These empirical parameters were facts discovered in the laboratory and mislabeled as 'quantum' through term coöptation, despite being nothing more than empirical laws governing discrete crystalline lattices.

==== Niels Bohr, the Solvay Conference of 1927, and Verbal Trickery
This systematic term coöptation originated formally with **Niels Bohr** and his so-called **'complementarity principle'**—the anti-rational doctrine asserting that a physical scientist must simultaneously believe mutually contradictory propositions (such as asserting that an entity is simultaneously an uncountably infinite wave and a zero-volume point particle, or that physical transitions occur as uncaused 'quantum jumps' without finite duration).

At the Fifth Solvay International Conference of 1927, this doctrine was dogmatized into standard physics terminology. When Bohr insisted that physical reality is defined strictly by the specific experimental arrangement set up by an observer and the instrumental measurements recorded within that arrangement, he was, in an obfuscated way, proclaiming: “We should abandon theoretical physics. Let us merely collect empirical laws.”

As a result of this historical inversion, the very term **'theoretical physics'** was coöpted to mean, in practice, the **abandonment of theoretical physics**. Rather than seeking first-principles electrodynamic causes for physical phenomena, twentieth-century 'theoretical physics' became an enterprise of constructing mathematical curves to fit empirical observations, asserting that the underlying mechanisms were intrinsically unknowable.

==== Neuro-Physiological Consequences of Phase-Reversed Terminology
Prolonged living under the influence of phase-reversed terminology—where fundamental terms are inverted to signify their “opposites” and contradictions are dogmatized as fundamental principles—creates a persistent, subconscious nervous tension that is unhealthy for the human organism. The human central nervous system requires similarity of structure between symbolic and objective realities, to evaluate facts calmly and rationally without cognitive dissonance. Consequently, absorbing, mastering, and employing correct theoretical physics—which replaces mystical verbal evasions with transparent, deterministic multivector field dynamics—eliminates this unnecessary nervous strain, restoring intellectual tranquility and improving neuro-physiological health.footnote:[This is not a claim that diseases will be cured. Any relief from unnecessary tension, however, is an improvement.]

Before 1927, an unexplained experimental observation was correctly designated as an **empirical law**—a physical regularity whose underlying first-principles cause remained to be discovered through rigorous field analysis. After 1927, through systematic verbal trickery, empirical laws were rebranded as 'fundamental quantum principles', transforming physical regularities into inexplicable, uncaused mysteries that were forbidden to be questioned or derived.

==== Restoration of First Principles via the Master Field Equation
The Master Field Equation \\( D F = J \\) in Clifford algebra \\( Cl ( 4 , 1 , 1 ) \\) on discrete multiscale resolution grid \\( \\mathcal { G } _ N \\) changes that completely. Semiconductor phenomena are not uncaused 'quantum magic'; they are explicit, deterministic multivector field stress-energy dynamics occurring within discrete atomic crystal lattices.

By replacing unphysical continuum point-particle singularities with non-singular Clifford multivector wave packets co-propagating across discrete lattice grid cells, the facts of solid-state physics are restored to their proper status: empirical laws that are later rigorously derived from first principles. The 'quantum' semiconductor fallacy is eliminated, re-establishing solid-state engineering on a firm, transparent electrodynamic foundation.`
  },
  {
    "id": "sec-first-principles-physical-definition-of-a-hole-valence-band-vacancy-wave-packets-and-topological-charge-defect-dynamics",
    "title": "First-Principles Physical Definition of a Hole: Valence Band Vacancy Wave Packets, Effective Mass Tensor, Hall Effect, and Topological Charge Defect Dynamics",
    "contentAsciiDoc": `=== First-Principles Physical Definition of a Hole: Valence Band Vacancy Wave Packets, Effective Mass Tensor, Hall Effect, and Topological Charge Defect Dynamics

To establish solid-state device mechanics on a firm electrodynamic foundation, physical science must first resolve a foundational question: **what, precisely, is a “hole” in a semiconductor?**

Twentieth-century popular accounts frequently portrayed a hole as an actual elementary physical particle—a “positive electron” or “positron-like entity” floating inside solid silicon or germanium. In the Iris number system, we discard all such mystical reifications. A hole is not a physical elementary particle; it is a **topological charge defect and vacant wave packet state within an otherwise populated valence band**.

==== 1. Valence Band Wave Packets and Vacancy Multivector States
In a solid semiconductor crystal (such as Silicon or Germanium), the periodic lattice of atomic nuclei and core electron shells creates a discrete periodic potential grid \\( \\mathcal { G } _ N \\). Under the Master Field Equation \\( D F = J \\) in Clifford algebra \\( Cl ( 4 , 1 , 1 ) \\), valence electrons occupy a dense set of single-particle multivector field states forming the valence energy band.

At absolute zero temperature (\\( T = 0 \\text{ K} \\)), the valence band is completely full: every single-particle state across the symmetric Brillouin zone grid is occupied by a valence electron. Because the Brillouin zone is symmetric around the origin in wavevector space (\\( \\mathbf { k } \\)), for every valence electron moving with wavevector \\( \\mathbf { k } _ i \\) and group velocity \\( \\mathbf { v } _ i = \\frac { 1 } { \\hbar } \\nabla_{\\mathbf { k }} E ( \\mathbf { k } ) \\), there exists an oppositely moving valence electron at \\( - \\mathbf { k } _ i \\) with velocity \\( - \\mathbf { v } _ i \\). Summing the current density over all \\( N \\) states in a completely filled valence band yields exactly zero net current:
\\[ \\mathbf { J }_\\text{full} = \\sum_{i=1}^N ( - q ) \\mathbf { v } _ i = 0 \\]

When thermal agitation, optical field absorption, or an external electric bias promotes a single valence electron out of the valence band into the conduction band (or extracts it at an ohmic contact), it leaves an **empty state** (a vacancy) at wavevector \\( \\mathbf { k } _ e \\).

==== 2. Mathematical Equivalence of Valence Current and Positive Charge Motion
With one valence electron missing from state \\( \\mathbf { k } _ e \\), the net electrical current density contributed by the remaining \\( N - 1 \\) valence electrons is given by subtracting the missing electron's current contribution from the full-band zero sum:
\\[ \\mathbf { J }_\\text{val} = \\sum_{i \\neq e} ( - q ) \\mathbf { v } _ i = \\sum_{i=1}^N ( - q ) \\mathbf { v } _ i - ( - q ) \\mathbf { v } _ e = 0 + q \\mathbf { v } _ e = ( + q ) \\mathbf { v } _ h \\]
where \\( \\mathbf { v } _ h = \\mathbf { v } _ e \\) and \\( \\mathbf { k } _ h = - \\mathbf { k } _ e \\).

This mathematical identity is profound: the collective, coordinated motion of \\( N - 1 \\) negative valence electrons moving through a crystal lattice with one vacancy produces an electric current density **identically equal to that of a single fictive particle possessing positive charge \\( + q = + 1.602 \\times 10^{-19} \\text{ C} \\)** moving at velocity \\( \\mathbf { v } _ h \\)!

==== 3. Negative Band Curvature, Negative Electron Mass, and Positive Hole Mass
The dynamical response of carriers to an applied electric field \\( \\mathbf { E } \\) depends on the curvature of the dispersion relation \\( E ( \\mathbf { k } ) \\) on discrete grid \\( \\mathcal { G } _ N \\), defined by the effective mass tensor:
\\[ ( m^* )^{-1}_{ij} = \\frac { 1 } { \\hbar^2 } \\frac { \\partial^2 E ( \\mathbf { k } ) } { \\partial k_i \\partial k_j } \\]

Near the top of the valence band (the valence band maximum \\( E_v \\)), the band curves downward, so the second derivative is strictly negative:
\\[ \\frac { d^2 E_v } { d k^2 } < 0 \\implies m_e^* = \\frac { \\hbar^2 } { \\frac { d^2 E_v } { d k^2 } } < 0 \\]

A valence electron located near the top of the valence band therefore possesses a **negative effective mass** (\\( m_e^* < 0 \\)). Under an applied electric vector field \\( \\mathbf { E } \\), the force on this valence electron produces an acceleration:
\\[ \\mathbf { a } _ e = \\frac { - q \\mathbf { E } } { m_e^* } = \\frac { - q \\mathbf { E } } { - | m_e^* | } = \\frac { + q \\mathbf { E } } { | m_e^* | } = \\frac { + q \\mathbf { E } } { m_h^* } \\]

Because the electron effective mass near the top of the valence band is negative, the electron accelerates in a direction *opposite* to the electrostatic force \\( - q \\mathbf { E } \\). Consequently, the vacant state (the hole) accelerates in the **same direction as the electric field \\( \\mathbf { E } \\)**, behaving in every dynamical aspect as if it were a pseudo-particle with **positive charge \\( + q \\)** and **positive effective mass \\( m_h^* = | m_e^* | > 0 \\)**!

==== 4. The Hall Effect Anomaly and Empirical Proof
The physical reality of hole current transport is conclusively demonstrated by the **Hall Effect**. When a magnetic field \\( \\mathbf { B } = B_z \\hat{\\mathbf{z}} \\) is applied perpendicular to a longitudinal current density \\( J_x \\) flowing through a semiconductor slab of width \\( W \\) and thickness \\( t \\), the transverse Lorentz force \\( \\mathbf { F } = q ( \\mathbf { v } \\times \\mathbf { B } ) \\) deflects carriers laterally, generating a transverse Hall electric field \\( E_y \\) and Hall voltage \\( V_H = E_y W \\).

* In **n-type semiconductors** (dominated by conduction-band electrons), electrons moving at velocity \\( v_x < 0 \\) are deflected toward the lateral edge \\( y = 0 \\), accumulating negative charge and establishing a **negative Hall coefficient**:
  \\[ R_H = - \\frac { 1 } { q n } \\]
* In **p-type semiconductors** (dominated by valence-band holes), experimental measurements reveal a **positive Hall voltage** and **positive Hall coefficient**:
  \\[ R_H = + \\frac { 1 } { q p } \\]

Twentieth-century commentators frequently marveled at this positive Hall sign as a "quantum mystery". In truth, it follows directly from classical electrodynamics under \\( D F = J \\): because valence band electrons near \\( E_v \\) have negative effective mass \\( m_e^* < 0 \\), the Lorentz force deflects them toward the same side of the slab as conduction electrons, leaving an uncompensated positive space-charge accumulation (the vacancy accumulation) on the opposite side. The resulting transverse electric field points in the positive direction, yielding \\( R_H = + 1 / ( q p ) \\) without requiring physical positive particles inside the crystal.

==== 5. Jaynes MaxEnt State Partitioning and Mass-Action Balance
Under thermal equilibrium at temperature \\( T \\), Jaynes Maximum Entropy (MaxEnt) partitioning on discrete grid \\( \\mathcal { G } _ N \\) sets the probability that a valence state at energy \\( E \\) is vacant (occupied by a hole):
\\[ f_h ( E ) = 1 - f_e ( E ) = 1 - \\frac { 1 } { 1 + \\exp \\left( \\frac { E - E_F } { V_t } \\right) } = \\frac { 1 } { 1 + \\exp \\left( \\frac { E_F - E } { V_t } \\right) } \\]

Integrating over the valence band density of states \\( \\rho_v ( E ) = \\frac { 1 } { 2 \\pi^2 } \\left( \\frac { 2 m_h^* } { \\hbar^2 } \\right) ^ { 3/2 } \\sqrt { E_v - E } \\) yields the equilibrium thermal hole concentration \\( p \\):
\\[ p = N_v \\exp \\left( - \\frac { E_F - E_v } { V_t } \\right) \\]
where \\( N_v = 2 \\left( \\frac { 2 \\pi m_h^* k_B T } { h^2 } \\right) ^ { 3/2 } \\) is the effective density of states in the valence band.

Multiplying the MaxEnt electron density \\( n = N_c \\exp [ - ( E_c - E_F ) / V_t ] \\) by the hole density \\( p \\) eliminates the Fermi potential \\( E_F \\), yielding the fundamental **mass-action law**:
\\[ n \\cdot p = N_c N_v \\exp \\left( - \\frac { E_g } { V_t } \\right) = n_i^2 \\]
where \\( E_g = E_c - E_v \\) is the energy bandgap of the crystal lattice.`
  },
  {
    "id": "sec-p-n-junction-physics-built-in-potential-shockley-diode-equation-and-schottky-barriers",
    "title": "P-N Junction Physics, Built-in Potential, Shockley Diode Equation, and Schottky Barriers",
    "contentAsciiDoc": `=== P-N Junction Physics, Built-in Potential, Shockley Diode Equation, and Schottky Barriers

==== Doped Semiconductors and Depletion Layer Dynamics
A semiconductor crystal (such as Silicon, \\( \\text{Si} \\), or Germanium, \\( \\text{Ge} \\)) consists of a periodic atomic lattice. Doping the lattice with group-V donor atoms (e.g., Phosphorus) yields n-type material with excess mobile electron current density, while doping with group-III acceptor atoms (e.g., Boron) yields p-type material with excess hole current density.

When p-type and n-type regions meet at a metallurgical junction, major carrier diffusion drives electrons into the p-region and holes into the n-region. This exposure of uncompensated ionized donor cores (\\( N_D^+ \\)) and acceptor cores (\\( N_A^- \\)) creates a localized **depletion region** (space-charge region) devoid of mobile carriers. The exposed space charge generates an internal built-in electric vector field \\( \\mathbf { E } _ 0 \\) directed from the n-side to the p-side.

==== Built-in Potential and Equilibrium Field Balance
At thermal equilibrium, the outward diffusion current density \\( J_\\text{diff} = q D_n \\frac { d n } { d x } \\) is exactly balanced by the inward drift current density \\( J_\\text{drift} = q n \\mu_n E_0 \\), yielding zero net current \\( J_\\text{total} = 0 \\). Integrating the built-in electric field across the depletion width \\( W = x_n + x_p \\) yields the **built-in potential** \\( V_{bi} \\):
\\[ V_{bi} = \\frac { k_B T } { q } \\ln \\left( \\frac { N_A N_D } { n_i ^ 2 } \\right) = V_t \\ln \\left( \\frac { N_A N_D } { n_i ^ 2 } \\right) \\]
where \\( V_t = k_B T / q \\approx 25.85 \\text{ mV} \\) at 300 K, and \\( n_i \\) is the intrinsic carrier density.

The total depletion width \\( W \\) under an applied reverse or forward voltage \\( V \\) follows directly from integrating Poisson's equation across the uncompensated donor and acceptor space-charge layers:
\\[ W = \\sqrt { \\frac { 2 \\varepsilon ( N_A + N_D ) ( V_{bi} - V ) } { q N_A N_D } } \\]

==== Derivation of the Shockley Diode Equation
Applying an external forward bias voltage \\( V \\) lowers the potential barrier to \\( V_{bi} - V \\), allowing exponential carrier diffusion across the junction. Applying a reverse bias voltage \\( V = - V_R \\) widens the barrier to \\( V_{bi} + V_R \\), choking off diffusion and leaving only a minute minority carrier thermal generation current \\( I_s \\).

Solving the discrete charge-conservation balance equation for minority carrier diffusion in the neutral regions:
\\[ D_n \\frac { d^2 n_p } { d x^2 } - \\frac { n_p - n_{p0} } { \\tau_n } = 0 \\]
yields the minority carrier concentration profiles \\( n_p ( x ) = n_{p0} + n_{p0} ( e^{V / V_t} - 1 ) e^{- x / L_n} \\). Evaluating the diffusion current at the depletion boundaries yields the celebrated **Shockley Diode Equation**:
\\[ I ( V ) = I_s \\left( e ^ { \\frac { V } { n V_t } } - 1 \\right) \\]
where \\( I_s = q A \\left( \\frac { D_p p_{n0} } { L_p } + \\frac { D_n n_{p0} } { L_n } \\right) \\) is the reverse saturation current, and \\( n \\approx 1.0 \\text{--} 2.0 \\) is the diode ideality factor.

==== Metal-Semiconductor Schottky Barriers
A **Schottky diode** consists of a direct metal-semiconductor interface (e.g., Platinum on n-type Silicon). The Schottky barrier height \\( \\Phi_{BN} = \\Phi_m - \\chi_s \\) governs current transport via majority-carrier thermionic emission:
\\[ I = A^* A T^2 e ^ { - \\frac { \\Phi_{BN} } { V_t } } \\left( e ^ { \\frac { V } { n V_t } } - 1 \\right) \\]
Because Schottky diodes rely strictly on majority carrier transport, they exhibit zero minority-carrier storage delay, enabling ultra-fast reverse recovery times (< 100 ps) and lower forward voltage drops (0.2–0.3 V compared to 0.6–0.7 V for silicon p-n diodes).`
  },
  {
    "id": "sec-specialized-solid-state-diodes-zener-avalanche-varactor-tunnel-pin-leds-and-photodiodes",
    "title": "Specialized Solid-State Diodes: Zener, Avalanche, Varactor, Tunnel, PIN, LEDs, and Photodiodes",
    "contentAsciiDoc": `=== Specialized Solid-State Diodes: Zener, Avalanche, Varactor, Tunnel, PIN, LEDs, and Photodiodes

==== Zener and Avalanche Breakdown Diodes
Under reverse bias, a p-n junction eventually undergoes electrical breakdown at voltage \\( V_{BR} \\):
* **Zener Breakdown (< 5 V)**: In heavily doped junctions (\\( N_A, N_D > 10^{18} \\text{ cm}^{-3} \\)), the depletion layer width is extremely thin (\\( W < 10 \\text{ nm} \\)). High reverse electric fields (\\( E > 10^6 \\text{ V/cm} \\)) induce direct internal field emission across the narrow lattice barrier.
* **Avalanche Breakdown (> 6 V)**: In moderately doped junctions, thermally generated carriers accelerating through the high reverse field acquire sufficient kinetic energy to impact-ionize lattice atoms, liberating secondary electron-hole pairs in a multiplying avalanche cascade governed by multiplication factor \\( M = \\frac { 1 } { 1 - ( V / V_{BR} )^n } \\).

==== Varactor (Varicap) Diodes
A **varactor diode** exploits the voltage-variable junction capacitance \\( C_j \\) of a reverse-biased p-n junction. The depletion layer acts as a dielectric gap between conductive neutral regions:
\\[ C_j ( V_R ) = \\frac { C_0 } { \\left( 1 + \\frac { V_R } { V_{bi} } \\right) ^ m } \\]
where \\( m = 0.5 \\) for abrupt junctions and \\( m = 0.33 \\) for hyperabrupt junctions. Varactors serve as solid-state voltage-controlled capacitors in RF voltage-controlled oscillators (VCOs) and frequency synthesizers.

==== Esaki Tunnel Diodes: Degenerate Doping, Jaynes MaxEnt, and Wave Packet Resonance
Discovered empirically by Reona Esaki in 1957, the **Esaki tunnel diode** is a heavily doped p-n homojunction operating entirely outside the classical Shockley diffusion regime. Its operating mechanism illustrates how solid-state boundary transport follows deterministically from Jaynes Maximum Entropy (MaxEnt) partitioning and bivector wave packet propagation under the Master Field Equation \\( D F = J \\) in Clifford algebra \\( Cl ( 4 , 1 , 1 ) \\).

1. **Degenerate Semiconductor Doping and MaxEnt State Distribution**:
In standard p-n diodes, acceptor and donor doping levels (\\( N_A, N_D \\approx 10^{15} \\text{--} 10^{17} \\text{ cm}^{-3} \\)) remain non-degenerate, placing the equilibrium Fermi potential \\( E_F \\) deep within the forbidden energy bandgap \\( E_g \\). In an Esaki diode, both sides of the metallurgical junction are doped degenerately to extreme concentrations (\\( N_A, N_D > 10^{19} \\text{ cm}^{-3} \\)), exceeding the effective density of states.
Under Jaynes MaxEnt partitioning on the discrete crystal grid \\( \\mathcal { G } _ N \\), maximizing entropy subject to local energy and charge conservation constraints yields the Fermi-Dirac occupation probability for carrier states at energy \\( E \\):
\\[ f ( E ) = \\frac { 1 } { 1 + \\exp \\left( \\frac { E - E_F } { V_t } \\right) } \\]
Because of degenerate doping, the Fermi potential on the n-side (\\( E_{Fn} \\)) penetrates above the conduction band edge (\\( E_{Fn} > E_c \\)), filling the lower conduction band states with a dense sea of mobile electrons. Simultaneously, the Fermi potential on the p-side (\\( E_{Fp} \\)) penetrates below the valence band edge (\\( E_{Fp} < E_v \\)), leaving the upper valence band states empty (a dense concentration of holes).

2. **Ultra-Thin Depletion Barrier and Multivector Field Transmission**:
Integrating Poisson’s electrostatic divergence \\( \\nabla \\cdot \\mathbf { E } = \\frac { \\rho } { \\varepsilon } \\) across the space-charge region reveals that degenerate doping contracts the depletion layer width \\( W \\) to sub-10-nanometer dimensions:
\\[ W = \\sqrt { \\frac { 2 \\varepsilon ( N_A + N_D ) V_{bi} } { q N_A N_D } } < 10 \\text{ nm} \\quad ( 5 \\text{--} 8 \\text{ nm} ) \\]
This produces an intense built-in electric vector field exceeding \\( \\mathbf { E } _ \\text{max} > 10^6 \\text{ V/cm} \\).
In twentieth-century physics, carrier transit across this sub-10 nm gap was asserted to be an uncaused “quantum mechanical tunneling jump”. In the Iris number system, electrons are non-singular multivector wave packets \\( F \\in Cl ( 4 , 1 , 1 ) \\) satisfying \\( D F = J \\). Across a sub-10 nm lattice barrier, the bivector field tail preserves deterministic phase coherence. The multivector transmission coefficient \\( T_B ( E ) \\) across the discrete space-charge gap is derived from the WKB-like field action integral over grid cells \\( \\mathcal { G } _ N \\):
\\[ T_B ( E ) \\approx \\exp \\left( - \\frac { 4 \\sqrt { 2 m^* } } { 3 q \\hbar \\mathbf { E } _ \\text{max} } E_g ^ { 3 / 2 } \\right) \\]
Because \\( W \\) is under 10 nm, \\( T_B ( E ) \\) is extraordinarily large (\\( 10^{-3} \\text{--} 10^{-1} \\)), enabling immense field transmission current densities (\\( 10^3 \\text{--} 10^5 \\text{ A/cm}^2 \\)).

3. **Voltage-Dependent Energy Band Alignment and Negative Differential Resistance (NDR)**:
The net field transmission current density \\( I_\\text{tunnel} ( V ) \\) under applied forward bias voltage \\( V \\) is governed by the energy state overlap integral between filled n-side conduction states and empty p-side valence states:
\\[ I_\\text{tunnel} ( V ) = \\frac { A q m^* } { 2 \\pi^2 \\hbar^3 } \\int _ { E_c } ^ { E_v } \\rho_c ( E ) \\rho_v ( E ) \\left[ f_c ( E ) - f_v ( E ) \\right] T_B ( E ) \, d E \\]

The resulting current-voltage (\\( I \\text{--} V \\)) curve traces three distinct physical operational regimes:
* **Reverse Bias (\\( V < 0 \\))**: Applied reverse bias pulls the n-side energy levels downward relative to the p-side, aligning filled valence band states on the p-side directly opposite empty conduction band states on the n-side. Field transmission current rises rapidly without saturation, causing the Esaki diode to act as a highly conductive “backward diode” in reverse bias.
* **Zero Bias (\\( V = 0 \\))**: At thermal equilibrium, the filled n-side conduction states align exactly with filled p-side valence states, while empty states align with empty states. Forward wave packet transmission balances reverse wave packet transmission identically (\\( I_{n \\to p} = I_{p \\to n} \\)), yielding zero net current (\\( I = 0 \\)).
* **Peak Current Regime (\\( 0 < V \\le V_p \\))**: Applying a small forward bias \\( V \\) raises the n-side energy levels upward by \\( q V \\). Filled n-side conduction band states now face empty p-side valence band states across a broad overlapping energy window \\( \\Delta E = ( E_v - E_c ) + q V \\). Current increases rapidly with voltage, reaching a maximum **peak current** \\( I_p \\) at **peak voltage** \\( V_p \\approx 50 \\text{--} 100 \\text{ mV} \\).
* **Negative Differential Resistance (NDR) Regime (\\( V_p < V < V_v \\))**: As forward bias increases beyond \\( V_p \\), the bottom of the n-side conduction band \\( E_c \\) is pushed above the top of the p-side valence band \\( E_v \\). Filled n-side conduction states are now forced to face the unpopulated forbidden energy bandgap \\( E_g \\) on the p-side, where zero energy states exist. The overlapping state window shrinks continuously. Consequently, despite the increase in applied voltage, the net current drops precipitously toward a minimum **valley current** \\( I_v \\) at **valley voltage** \\( V_v \\approx 350 \\text{--} 500 \\text{ mV} \\). In this interval, the incremental slope is negative:
  \\[ R_N = \\left( \\frac { d I } { d V } \\right) ^ { - 1 } < 0 \\]
  establishing a true physical **Negative Differential Resistance (NDR)**.
* **Thermal Diffusion and Excess Current Regime (\\( V > V_v \\))**: Beyond valley voltage \\( V_v \\), direct band-to-band overlap collapses to zero. Current is maintained at a small non-zero valley value \\( I_v \\) by localized defect-state “excess current”. As forward bias increases further (\\( V > 0.6 \\text{ V} \\)), conventional thermionic injection over the reduced depletion barrier takes over, and current rises exponentially according to the standard Shockley diode equation.

4. **High-Frequency Microwave Oscillation and Equivalent Circuit**:
Because NDR relies on ultra-fast bivector wave packet transmission across a 5–8 nm lattice gap rather than slow minority carrier diffusion, response times are on the order of picoseconds. Connected across a tuned LC resonant tank, the negative conductance \\( - G_N = - 1 / | R_N | \\) cancels the positive resistance loss of the tank, converting DC power into sustained microwave oscillations up to hundreds of gigahertz.
The maximum resistive cutoff frequency \\( f_x \\) of an Esaki diode is given by:
\\[ f_x = \\frac { 1 } { 2 \\pi | R_N | C_j } \\sqrt { \\frac { | R_N | } { R_s } - 1 } \\]
where \\( C_j \\) is the junction capacitance and \\( R_s \\) is the parasitic series lead resistance.

==== PIN Diodes, LEDs, and Photodiodes
* **PIN Diodes**: An undoped intrinsic (I) layer is sandwiched between P and N regions. At RF frequencies, the injected charge in the I-layer acts as a linear voltage-variable RF resistor \\( R_i = \\frac { W^2 } { ( \\mu_n + \\mu_p ) Q } \\), used in high-power RF switches and attenuators.
* **Light-Emitting Diodes (LEDs)**: Forward bias injects carriers across direct-bandgap heterojunctions (e.g., GaN, GaAs), where radiative recombination \\( R = B n p \\) transduces electrical current directly into coherent or incoherent optical field energy of photon energy \\( h \\nu = E_g \\).
* **Photodiodes**: Reverse-biased junctions where incident optical wave packets generate electron-hole pairs in the depletion region, generating a photocurrent \\( I_{ph} = \\mathcal{R} P_{opt} \\) proportional to optical power, with responsivity \\( \\mathcal{R} = \\frac { \\eta q } { h \\nu } \\).`
  },
  {
    "id": "sec-integrated-diode-arrays-rectifier-bridges-and-logic-switching-matrices",
    "title": "Integrated Diode Arrays, Rectifier Bridges, and Logic Switching Matrices",
    "contentAsciiDoc": `=== Integrated Diode Arrays, Rectifier Bridges, and Logic Switching Matrices

==== Full-Wave Bridge Rectifiers and Filtering
Power rectification converts AC utility lines into stable DC voltage using a 4-diode Graetz bridge rectifier. The full-wave rectified output voltage \\( V_{dc} = \\frac { 2 V_m } { \\pi } \\) feeds a reservoir condenser filter \\( C \\). The peak-to-peak ripple voltage under load current \\( I_L \\) is:
\\[ V_r = \\frac { I_L } { 2 f C } \\]

==== Monolithic TVS Diode Arrays
Modern high-speed digital interfaces (USB4, HDMI 2.1) employ monolithic Transient Voltage Suppression (TVS) diode arrays. Low-capacitance (< 0.2 pF) steering diodes divert electrostatic discharge (ESD) transients into zener clamping diodes, protecting sensitive micro-scale integrated circuits from kilovolt spikes.

==== Historical Diode Logic (DL) and ROM Switching Matrices
Before transistor-transistor logic (TTL), early digital computing employed **Diode Logic (DL)** matrices. Diode AND gates and OR gates formed boolean logic networks. Monolithic diode matrix arrays served as read-only memories (ROMs), where presence or absence of a diode at row-column intersections defined permanent bit patterns.`
  },
  {
    "id": "sec-formal-postulates-and-theorems-of-solid-state-diode-mechanics",
    "title": "Formal Postulates and Theorems of Solid-State Diode Mechanics",
    "contentAsciiDoc": `=== Formal Postulates and Theorems of Solid-State Diode Mechanics

[#theorem-hole-charge-equivalence-and-hall-effect-m-res-derivation]
[THEOREM]
.Theorem: First-Principles Derivation of Hole Charge Equivalence and Positive Hall Effect
====
In a solid semiconductor lattice \\( \\mathcal { G } _ N \\), a vacant state (a hole) at wavevector \\( \\mathbf { k } _ e \\) in a valence band near maximum \\( E_v \\) produces a net electric current density \\( \\mathbf { J }_\\text{val} = ( + q ) \\mathbf { v } _ h \\). Because the dispersion relation has negative curvature \\( \\frac { d^2 E_v } { d k^2 } < 0 \\), the effective mass of the missing electron is negative \\( m_e^* < 0 \\), forcing the vacancy to accelerate under electric field \\( \\mathbf { E } \\) as a particle with positive effective mass \\( m_h^* = | m_e^* | > 0 \\) and positive charge \\( + q \\). Under magnetic field \\( \\mathbf { B } \\), the resulting Hall coefficient is strictly positive:
\\[ R_H = + \\frac { 1 } { q p } \\]
proving positive Hall voltage without physical positive elementary particles.

*Proof:*
. **Current Summation over Brillouin Zone**: Summing over all \\( N \\) states of a full valence band gives \\( \\sum_{i=1}^N ( - q ) \\mathbf { v } _ i = 0 \\). Subtracting the vacant state \\( \\mathbf { k } _ e \\) yields \\( \\mathbf { J }_\\text{val} = 0 - ( - q ) \\mathbf { v } _ e = ( + q ) \\mathbf { v } _ h \\).

. **Acceleration and Negative Curvature**: Evaluating the force equation \\( \\mathbf { a } _ e = \\frac { - q \\mathbf { E } } { m_e^* } \\) with \\( m_e^* = - | m_e^* | \\) gives \\( \\mathbf { a } _ e = \\frac { + q \\mathbf { E } } { | m_e^* | } = \\frac { + q \\mathbf { E } } { m_h^* } \\).

. **Lorentz Force Deflection and Positive Hall Coefficient**: Under transverse magnetic field \\( B_z \\), negative valence electrons with \\( m_e^* < 0 \\) are deflected toward \\( y = 0 \\), creating a positive space-charge accumulation on the opposite boundary, establishing positive Hall field \\( E_y = + \\frac { 1 } { q p } J_x B_z \\) and positive Hall coefficient \\( R_H = + 1 / ( q p ) \\). \\( \\square \\)
====

[#theorem-deconstruction-quantum-semiconductor-fallacy]
[THEOREM]
.Theorem: Epistemological Demolition of the ‘Quantum’ Semiconductor Fallacy and Derivation of Solid-State Empirical Laws
====
Solid-state semiconductor devices—including point-contact rectifiers, p-n junction diodes, and Schottky barriers—are classical physical electrodynamic structures governed by multivector field stress-energy tensor states \\( T \\in Cl ( 4 , 1 , 1 ) \\) co-propagating on discrete atomic crystal lattices \\( \\mathcal { G } _ N \\). The assertion that solid-state devices rely on uncaused 'quantum principles' or Bohr's 'complementarity' is an epistemological defect arising from term coöptation. Facts previously cataloged as empirical laws are derived directly from the Master Field Equation \\( D F = J \\) without 'quantum' mysticism.

*Proof:*
. **Solid-State Lattice Field Structure**: In a solid crystal, atomic nuclei and electron shell clouds form a discrete periodic field grid \\( \\mathcal { G } _ N \\). The local charge density \\( \\rho ( \\mathbf { r } ) \\) and current density \\( \\mathbf { J } ( \\mathbf { r } ) \\) satisfy the Master Field Equation \\( D F = J \\).

. **Demolition of Term Coöptation**: Prior to the Master Field Equation, experimental observations regarding energy band gaps, built-in potential barriers, and junction currents were empirical regularities awaiting first-principles derivation. Mislabeling these empirical laws as 'fundamental quantum principles' through Bohr's complementarity principle substituted verbal trickery for physical causality. In \\( Cl ( 4 , 1 , 1 ) \\), all carrier transport (drift, diffusion, barrier transmission) is proven to be deterministic multivector wave packet propagation across finite spatial grid boundaries.

. **First-Principles Consistency**: Because all solid-state boundary transport equations follow strictly from \\( D F = J \\) on discrete grid \\( \\mathcal { G } _ N \\), solid-state devices are established as classical electrodynamic field engines, completely eliminating the 'quantum' semiconductor fallacy. \\( \\square \\)
====

[#theorem-shockley-diode-equation-m-res-derivation]
[THEOREM]
.Theorem: Derivation of the Shockley Diode Equation from the Master Field Equation
====
On a discrete lattice grid \\( \\mathcal { G } _ N \\), the total current density \\( J \\) across a p-n junction under applied bias \\( V \\) obeys the exact field relation:
\\[ I ( V ) = I_s \\left( e ^ { \\frac { V } { V_t } } - 1 \\right) \\]
where saturation current \\( I_s \\) is determined by minority carrier diffusion length and thermal generation rate.

*Proof:*
. **Space Charge and Built-in Potential**: The divergence of the electric field in the depletion layer \\( \\nabla \\cdot \\mathbf { E } = \\frac { \\rho } { \\varepsilon } \\) establishes built-in potential \\( V_{bi} = V_t \\ln ( N_A N_D / n_i^2 ) \\).

. **Barrier Lowering and Carrier Injection**: An applied forward bias \\( V \\) reduces the potential step to \\( V_{bi} - V \\). Minority carrier concentrations at the boundary edges of the depletion region scale exponentially according to the Boltzmann multivector factor \\( n ( x_p ) = n_{p0} e^{V / V_t} \\).

. **Diffusion Current Integration**: Integrating the minority carrier diffusion conservation equation \\( D_n \\frac { d^2 n } { d x^2 } - \\frac { n - n_{p0} } { \\tau_n } = 0 \\) over the neutral p and n regions yields exact exponential current \\( I = I_s ( e^{V / V_t} - 1 ) \\). \\( \\square \\)
====

[#theorem-esaki-ndr-maxent-derivation]
[THEOREM]
.Theorem: First-Principles Derivation of Esaki Tunneling Mechanics and Negative Differential Resistance
====
In a degenerately doped p-n junction on discrete lattice grid \\( \\mathcal { G } _ N \\), carrier state distribution follows Jaynes MaxEnt partitioning. Under applied forward bias \\( V \\), net bivector wave packet transmission current across the sub-10 nm space-charge barrier obeys:
\\[ I ( V ) = C_0 \\int _ { E_c } ^ { E_v } \\rho_c ( E ) \\rho_v ( E ) \\left[ f_c ( E ) - f_v ( E ) \\right] T_B ( E ) \, d E \\]
In the voltage range \\( V_p < V < V_v \\), the derivative of current with respect to voltage is strictly negative:
\\[ \\frac { d I } { d V } < 0 \\]
proving the existence of deterministic Negative Differential Resistance (NDR) from first principles.

*Proof:*
. **MaxEnt Degenerate State Occupation**: For degenerate acceptor doping \\( N_A > 10^{19} \\text{ cm}^{-3} \\) and donor doping \\( N_D > 10^{19} \\text{ cm}^{-3} \\), Jaynes MaxEnt subject to energy and particle constraints sets Fermi level \\( E_{Fn} > E_c \\) on the n-side and \\( E_{Fp} < E_v \\) on the p-side, filling conduction states and emptying valence states near the junction.

. **Bivector Wave Packet Barrier Transmission**: Integration of Poisson's field equation yields a sub-10 nm depletion width \\( W = \\sqrt{ 2 \\varepsilon ( N_A + N_D ) V_{bi} / ( q N_A N_D ) } \\). Across this ultra-thin space-charge region, multivector wave packet field solutions \\( F \\in Cl ( 4 , 1 , 1 ) \\) of \\( D F = J \\) retain bivector phase coherence, yielding finite transmission factor \\( T_B ( E ) \\approx \\exp ( - \\frac { 4 \\sqrt{2 m^*} } { 3 q \\hbar \\mathbf{E}_{max} } E_g^{3/2} ) > 0 \\).

. **Band-to-Band Overlap Integration**: Applying forward bias \\( V \\) shifts n-side energy levels upward by \\( q V \\). Overlapping energy states exist only in the band overlap window \\( \\Delta E = E_v - ( E_c - q V ) \\). Integrating state densities over this window gives total transmission current \\( I ( V ) \\).

. **Derivative Evaluation for NDR**: Differentiating \\( I ( V ) \\) with respect to \\( V \\) in the interval where \\( q V > E_{Fn} - E_c \\):
  \\[ \\frac { d I } { d V } = C_0 \\frac { d } { d V } \\left[ \\int _ { E_c - q V } ^ { E_v } \\rho_c ( E + q V ) \\rho_v ( E ) [ f_c ( E + q V ) - f_v ( E ) ] T_B \, d E \\right] \\]
  As \\( V \\) increases past peak voltage \\( V_p \\), the upper energy limit of available valence states \\( E_v \\) is exceeded by the shifting conduction band edge \\( E_c - q V \\), forcing n-side electrons to face the unpopulated bandgap \\( E_g \\). The reduction in available overlap area dominates the integrand, forcing \\( \\frac { d I } { d V } < 0 \\) in the interval \\( V_p < V < V_v \\), proving deterministic NDR. \\( \\square \\)
====`
  },
  {
    "id": "sec-completely-worked-technical-examples",
    "title": "Completely Worked Technical Examples",
    "contentAsciiDoc": `=== Completely Worked Technical Examples

==== Example 1: Cat’s Whisker Point-Contact Rectifier Work Function and Junction Resistance
**Problem Statement:** A phosphor-bronze wire point contact (work function \\( \\Phi_m = 4.50 \\text{ eV} \\)) is pressed against an n-type galena (\\( \\text{PbS} \\)) crystal (electron affinity \\( \\chi_s = 3.80 \\text{ eV} \\)). Calculate the built-in barrier height \\( \\Phi_{BN} \\) and the reverse saturation current density \\( J_s \\) at \\( T = 300 \\text{ K} \\) assuming Richardson constant \\( A^* = 120 \\text{ A/(cm}^2 \\text{K}^2) \\).

**Solution:**

1. **Schottky Barrier Height**: \\( \\Phi_{BN} = \\Phi_m - \\chi_s = 4.50 \\text{ eV} - 3.80 \\text{ eV} = 0.70 \\text{ eV} \\).
2. **Reverse Saturation Current Density**: \\( J_s = A^* T^2 e^{ - \\frac { \\Phi_{BN} } { V_t } } = 120 \\times ( 300 )^2 e^{ - \\frac { 0.70 } { 0.02585 } } = 1.08 \\times 10^7 \\times e^{-27.08} \\approx 1.08 \\times 10^7 \\times 1.74 \\times 10^{-12} \\approx 1.88 \\times 10^{-5} \\text{ A/cm}^2 \\) (\\( 18.8 \\ \\mu\\text{A/cm}^2 \\)).

==== Example 2: P-N Junction Built-in Potential, Depletion Width, and Bias Current
**Problem Statement:** A silicon p-n junction diode has acceptor doping \\( N_A = 10^{17} \\text{ cm}^{-3} \\), donor doping \\( N_D = 10^{16} \\text{ cm}^{-3} \\), intrinsic carrier density \\( n_i = 1.5 \\times 10^{10} \\text{ cm}^{-3} \\), cross-sectional area \\( A = 1.0 \\text{ mm}^2 \\), and reverse saturation current \\( I_s = 1.0 \\text{ pA} \\) at 300 K. Calculate built-in potential \\( V_{bi} \\) and forward current at \\( V = 0.65 \\text{ V} \\).

**Solution:**

1. **Built-in Potential \\( V_{bi} \\)**: \\( V_{bi} = ( 0.02585 ) \\ln \\left( \\frac { 10^{17} \\times 10^{16} } { ( 1.5 \\times 10^{10} )^2 } \\right) = 0.02585 \\ln \\left( \\frac { 10^{33} } { 2.25 \\times 10^{20} } \\right) = 0.02585 \\ln ( 4.444 \\times 10^{12} ) = 0.02585 \\times ( 29.12 ) \\approx 0.753 \\text{ V} \\).
2. **Forward Bias Current at \\( V = 0.65 \\text{ V} \\)**: \\( I = I_s e^{V / V_t} = 1.0 \\times 10^{-12} e^{0.65 / 0.02585} = 1.0 \\times 10^{-12} e^{25.145} \\approx 1.0 \\times 10^{-12} \\times ( 8.32 \\times 10^{10} ) = 83.2 \\text{ mA} \\).

==== Example 3: Degenerate Germanium Esaki Tunnel Diode Characterization, NDR, and Microwave Cutoff Frequency
**Problem Statement:** A degenerate germanium (\\( \\text{Ge} \\)) Esaki tunnel diode has acceptor doping \\( N_A = 2.0 \\times 10^{19} \\text{ cm}^{-3} \\), donor doping \\( N_D = 2.0 \\times 10^{19} \\text{ cm}^{-3} \\), bandgap \\( E_g = 0.66 \\text{ eV} \\), dielectric permittivity \\( \\varepsilon = 1.42 \\times 10^{-10} \\text{ F/m} \\), and junction area \\( A = 1.0 \\times 10^{-5} \\text{ cm}^2 \\) (\\( 1.0 \\times 10^{-9} \\text{ m}^2 \\)). Measured DC characteristics at 300 K are peak current \\( I_p = 10.0 \\text{ mA} \\) at peak voltage \\( V_p = 50.0 \\text{ mV} \\), and valley current \\( I_v = 1.0 \\text{ mA} \\) at valley voltage \\( V_v = 350.0 \\text{ mV} \\). Parasitic series resistance is \\( R_s = 1.5 \\ \\Omega \\).

1. Calculate the built-in potential \\( V_{bi} \\) and zero-bias depletion width \\( W \\).
2. Calculate the Peak-to-Valley Current Ratio (PVCR), the average Negative Differential Resistance \\( R_N \\), and the small-signal negative conductance \\( - G_N \\).
3. Calculate the junction capacitance \\( C_j \\) at zero bias.
4. Compute the maximum resistive cutoff frequency \\( f_x \\) above which the diode cannot amplify or oscillate.

**Solution:**

1. **Built-in Potential \\( V_{bi} \\) and Depletion Width \\( W \\)**:
   * For germanium at 300 K, intrinsic density is \\( n_i = 2.4 \\times 10^{13} \\text{ cm}^{-3} \\). Built-in potential is:
     \\[ V_{bi} = V_t \\ln \\left( \\frac { N_A N_D } { n_i^2 } \\right) = ( 0.02585 ) \\ln \\left( \\frac { ( 2.0 \\times 10^{19} )^2 } { ( 2.4 \\times 10^{13} )^2 } \\right) = 0.02585 \\ln ( 6.944 \\times 10^{11} ) \\approx \\mathbf { 0.705 \\text{ V} } \\]
   * Depletion width \\( W \\):
     \\[ W = \\sqrt { \\frac { 2 \\varepsilon ( N_A + N_D ) V_{bi} } { q N_A N_D } } \\]
     Using \\( N_A = N_D = 2.0 \\times 10^{25} \\text{ m}^{-3} \\):
     \\[ W = \\sqrt { \\frac { 2 ( 1.42 \\times 10^{-10} ) ( 4.0 \\times 10^{25} ) ( 0.705 ) } { ( 1.602 \\times 10^{-19} ) ( 2.0 \\times 10^{25} )^2 } } = \\sqrt { \\frac { 8.009 \\times 10^{-15} } { 6.408 \\times 10^{31} } } = \\sqrt { 1.2498 \\times 10^{-16} } \\approx \\mathbf { 1.118 \\times 10^{-8} \\text{ m} } \\quad ( 11.2 \\text{ nm} ) \\]

2. **Peak-to-Valley Ratio (PVCR), NDR \\( R_N \\), and Conductance \\( -G_N \\)**:
   * Peak-to-Valley Current Ratio:
     \\[ \\text{PVCR} = \\frac { I_p } { I_v } = \\frac { 10.0 \\text{ mA} } { 1.0 \\text{ mA} } = \\mathbf { 10.0 } \\]
   * Average Negative Differential Resistance \\( R_N \\):
     \\[ R_N = \\frac { V_v - V_p } { I_v - I_p } = \\frac { 0.350 - 0.050 } { 0.001 - 0.010 } = \\frac { 0.300 } { -0.009 } = \\mathbf { -33.33 \\ \\Omega } \\]
   * Small-signal negative conductance:
     \\[ - G_N = \\frac { 1 } { R_N } = \\frac { 1 } { -33.33 } \\approx \\mathbf { -0.030 \\text{ S} } \\quad ( -30.0 \\text{ mS} ) \\]

3. **Junction Capacitance \\( C_j \\)**:
   \\[ C_j = \\frac { \\varepsilon A } { W } = \\frac { ( 1.42 \\times 10^{-10} \\text{ F/m} ) ( 1.0 \\times 10^{-9} \\text{ m}^2 ) } { 1.118 \\times 10^{-8} \\text{ m} } = \\frac { 1.42 \\times 10^{-19} } { 1.118 \\times 10^{-8} } \\approx \\mathbf { 1.27 \\times 10^{-11} \\text{ F} } \\quad ( 12.7 \\text{ pF} ) \\]

4. **Maximum Resistive Cutoff Frequency \\( f_x \\)**:
   Applying the resistive cutoff frequency formula:
   \\[ f_x = \\frac { 1 } { 2 \\pi | R_N | C_j } \\sqrt { \\frac { | R_N | } { R_s } - 1 } \\]
   Substitute \\( | R_N | = 33.33 \\ \\Omega \\), \\( C_j = 12.7 \\text{ pF} \\), and \\( R_s = 1.5 \\ \\Omega \\):
   \\[ \\frac { | R_N | } { R_s } - 1 = \\frac { 33.33 } { 1.5 } - 1 = 22.22 - 1 = 21.22 \\implies \\sqrt { 21.22 } \\approx 4.606 \\]
   \\[ 2 \\pi | R_N | C_j = 2 \\times 3.14159 \\times 33.33 \\times ( 12.7 \\times 10^{-12} ) \\approx 2.660 \\times 10^{-9} \\text{ s} \\]
   \\[ f_x = \\frac { 4.606 } { 2.660 \\times 10^{-9} \\text{ s} } \\approx 1.731 \\times 10^9 \\text{ Hz} = \\mathbf { 1.731 \\text{ GHz} } \\]
   The diode provides negative resistance amplification and self-oscillation up to its resistive cutoff limit of \\( 1.731 \\text{ GHz} \\).

==== Example 4: Hole Effective Mass, Mobility, and Positive Hall Coefficient in P-Type Silicon
**Problem Statement:** A p-type silicon sample with acceptor concentration \\( N_A = 2.5 \\times 10^{16} \\text{ cm}^{-3} \\) has thickness \\( t = 0.50 \\text{ mm} \\) and width \\( W = 2.0 \\text{ mm} \\). The valence band effective mass of holes is \\( m_h^* = 0.38 m_0 \\) (where \\( m_0 = 9.109 \\times 10^{-31} \\text{ kg} \\)), and hole drift mobility is \\( \\mu_p = 450 \\text{ cm}^2 / ( \\text{V} \\cdot \\text{s} ) \\). A longitudinal current \\( I_x = 5.0 \\text{ mA} \\) flows through the sample under a perpendicular magnetic field \\( B_z = 0.40 \\text{ T} \\).

1. Calculate the positive Hall coefficient \\( R_H \\).
2. Calculate the transverse Hall electric field \\( E_y \\) and total Hall voltage \\( V_H \\).
3. Compute the drift velocity \\( v_x \\) and average relaxation time \\( \\tau_p \\) of the valence band vacancies.

**Solution:**

1. **Positive Hall Coefficient \\( R_H \\)**:
   Assuming complete acceptor ionization at 300 K (\\( p = N_A = 2.5 \\times 10^{16} \\text{ cm}^{-3} = 2.5 \\times 10^{22} \\text{ m}^{-3} \\)):
   \\[ R_H = + \\frac { 1 } { q p } = + \\frac { 1 } { ( 1.602 \\times 10^{-19} \\text{ C} ) ( 2.5 \\times 10^{22} \\text{ m}^{-3} ) } = + \\frac { 1 } { 4005 } \\approx \\mathbf { + 2.497 \\times 10^{-4} \\text{ m}^3 / \\text{C} } \\quad ( + 249.7 \\text{ cm}^3 / \\text{C} ) \\]

2. **Transverse Hall Field \\( E_y \\) and Hall Voltage \\( V_H \\)**:
   Cross-sectional area \\( A = W t = ( 2.0 \\times 10^{-3} \\text{ m} ) ( 0.50 \\times 10^{-3} \\text{ m} ) = 1.0 \\times 10^{-6} \\text{ m}^2 \\).
   Longitudinal current density \\( J_x = \\frac { I_x } { A } = \\frac { 5.0 \\times 10^{-3} \\text{ A} } { 1.0 \\times 10^{-6} \\text{ m}^2 } = 5000 \\text{ A/m}^2 \\).
   Transverse Hall electric field \\( E_y \\):
   \\[ E_y = R_H J_x B_z = ( + 2.497 \\times 10^{-4} ) ( 5000 ) ( 0.40 ) = \\mathbf { + 0.4994 \\text{ V/m} } \\]
   Total transverse Hall voltage \\( V_H = E_y W \\):
   \\[ V_H = ( 0.4994 \\text{ V/m} ) ( 2.0 \\times 10^{-3} \\text{ m} ) = \\mathbf { + 0.9988 \\text{ mV} } \\approx \\mathbf { + 1.00 \\text{ mV} } \\]

3. **Drift Velocity \\( v_x \\) and Relaxation Time \\( \\tau_p \\)**:
   Hole drift velocity \\( v_x \\):
   \\[ v_x = \\frac { J_x } { q p } = R_H J_x = ( 2.497 \\times 10^{-4} ) ( 5000 ) = \\mathbf { 1.2485 \\text{ m/s} } \\]
   Hole relaxation time \\( \\tau_p \\):
   Using \\( \\mu_p = 0.045 \\text{ m}^2 / ( \\text{V} \\cdot \\text{s} ) \\) and \\( m_h^* = 0.38 \\times 9.109 \\times 10^{-31} \\text{ kg} = 3.4614 \\times 10^{-31} \\text{ kg} \\):
   \\[ \\tau_p = \\frac { m_h^* \\mu_p } { q } = \\frac { ( 3.4614 \\times 10^{-31} \\text{ kg} ) ( 0.045 \\text{ m}^2 / ( \\text{V} \\cdot \\text{s} ) ) } { 1.602 \\times 10^{-19} \\text{ C} } = \\frac { 1.5576 \\times 10^{-32} } { 1.602 \\times 10^{-19} } \\approx \\mathbf { 9.72 \\times 10^{-14} \\text{ s} } \\quad ( 97.2 \\text{ fs} ) \\]
   This proves that valence band vacancies scatter every ~97 femtoseconds while collectively maintaining a positive Hall voltage of +1.00 mV across the sample.`
  }
];

// Replace Chapter 6
const ch6Pattern = /"id":\s*"chap-theory-of-solid-state-diodes-and-semiconductor-rectifiers[^"]*",[\s\S]*?"sections":\s*\[[\s\S]*?\]\s*\}/;

const newCh6JSON = `"id": "chap-theory-of-solid-state-diodes-and-semiconductor-rectifiers-point-contact-crystals-junction-dynamics-and-integrated-diode-matrices",
      "title": "Theory of Solid-State Diodes and Semiconductor Rectifiers: Point-Contact Crystals, Junction Dynamics, and Integrated Diode Matrices",
      "summary": "This chapter establishes the physical, mathematical, and field-theoretic foundations of solid-state rectifiers and semiconductor diodes within the m-resolution framework of the Master Field Equation in Cl(4,1,1). Beginning with point-contact metal-semiconductor interfaces (galena crystal radios and oxidized razor-blade foxhole detectors), the exposition deconstructs the popular misconception that solid-state devices are 'quantum' magic by revealing how facts known strictly from experiment were historically mislabeled as 'fundamental quantum principles'—a term coöptation initiated by Niels Bohr and Solvay 1927 that replaced empirical law with inexplicable mystery. The chapter establishes the first-principles physical definition of a hole as a valence band vacancy wave packet and topological charge defect, and then rigorously derives p-n homojunction and heterojunction barrier physics, the Shockley diode equation, Schottky barriers, breakdown dynamics, varactors, tunnel (Esaki) negative differential resistance, PIN switches, LEDs, photodiodes, and integrated diode matrices directly from the Master Field Equation.",
      "sections": ${JSON.stringify(chap6Sections, null, 10)}`;

content = content.replace(ch6Pattern, newCh6JSON);
console.log("Updated Chapter 6!");

fs.writeFileSync(targetFile, content, 'utf8');
console.log("Successfully updated textbookData.ts!");
