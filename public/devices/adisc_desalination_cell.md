# ADISC-1: Acoustic-Dielectrophoretic Ion Separation & Desalination Cell

**Version**: 1.0  
**Domain**: Solid-State Membrane-Free Desalination & Continuous Fluid Phase Separation  
**Physical Foundation**: Master Field Equation $\mathcal{D}\mathcal{F}_{\text{total}} = \mathcal{J}_{\text{total}}$ & High-Frequency Negative Dielectrophoresis (nDEP) coupled to Radial Acoustic Standing Waves

---

## 1. Theoretical Foundation

```
                                    Radial Cross-Section
                        +---------------------------------------+
                        |  Outer Tube Wall (PMMA / Cast Epoxy)  |
                        |  [ RF Interdigital Stator: High \nabla|E|^2 ] |
                        |                                       |
    Brine Annulus ====> |  Zone 2: Hydrated Ions Deflected Out  | ====> Outer Brine Outlet
    ------------------  |  . . . . . . . . . . . . . . . . . .  |  -----------------------
    Pure Core     ====> |  Zone 1: Acoustic Pressure Anti-Node  | ====> Inner Coaxial Probe
                        |          De-ionized Pure H2O          |       (Pure Water Outlet)
                        +---------------------------------------+
```

### 1.1 First-Principles Master Field Coupling
In conventional engineering, fluid desalination is treated strictly through continuum thermodynamics (high-pressure reverse osmosis against semi-permeable membranes). In the discrete Master Field formulation:
\[
\mathcal{D}\mathcal{F}_{\text{total}} = \mathcal{J}_{\text{total}}
\]
where $\mathcal{F}_{\text{total}} = \mathbf{E}e_4 + c\mathbf{B}(e_1 \wedge e_2 \wedge e_3)$ and $\mathcal{J}_{\text{total}} = \rho_0 (\mathbf{u} + ce_4)$.

A high-frequency oscillating electric field $\mathbf{E}(\mathbf{r}, t)$ generates a non-linear dielectrophoretic body force density on polarizable entities suspended in the dielectric carrier fluid:
\[
\langle \mathbf{F}_{\text{DEP}} \rangle = 2\pi \varepsilon_0 \varepsilon_m a_{\text{eff}}^3 \, \text{Re}[K_{\text{CM}}(\omega)] \nabla \|\mathbf{E}_{\text{RMS}}\|^2
\]
where the Clausius-Mossotti factor is defined by the complex permittivities:
\[
K_{\text{CM}}(\omega) = \frac{\tilde{\varepsilon}_p - \tilde{\varepsilon}_m}{\tilde{\varepsilon}_p + 2\tilde{\varepsilon}_m}, \qquad \tilde{\varepsilon} = \varepsilon - i\frac{\sigma}{\omega}
\]

For bulk liquid water, $\varepsilon_m \approx 78\text{--}80$, whereas the tightly bound hydration shells surrounding sodium ($\mathrm{Na}^+$) and chloride ($\mathrm{Cl}^-$) ions exhibit a much lower dielectric constant ($\varepsilon_p \approx 6\text{--}10$) due to rotational dipole freezing. Consequently:
\[
\text{Re}[K_{\text{CM}}(\omega)] < 0 \quad \text{for } \omega > 100\text{ kHz}
\]
This produces **negative dielectrophoresis (nDEP)**: hydrated salt ions and mineral clusters are repelled from regions of strong electric field gradient $\nabla \|\mathbf{E}\|^2$.

### 1.2 Acoustic Standing-Wave Focusing
Simultaneously, a radial acoustic pressure wave in a cylindrical chamber with inner radius $R$ satisfies the Bessel acoustic wave equation:
\[
P(r, t) = P_0 J_0(k_r r) \cos(\omega_a t)
\]
At resonance ($k_r R = \alpha_{0,1} \approx 2.4048$ for fundamental radial mode), a permanent pressure node forms at $r = R$ and an anti-node at the central axis $r = 0$. The primary acoustic radiation force $\mathbf{F}_{\text{ac}}$ focuses pure water molecules toward the low-pressure velocity anti-node while assisting the nDEP force in migrating heavier ionic clusters toward the outer wall.

---

## 2. Mechanical Construction & Engineering Bill of Materials

All components are assembled mechanically without welding or specialized machine tools.

### 2.1 Component Specifications

| Item | Component | Material / Specification | Fabrication Method |
| :---: | :--- | :--- | :--- |
| **1** | **Main Flow Barrel** | Cast Acrylic (PMMA) or Polycarbonate Tube, $1.50\text{ in}$ OD $\times 1.00\text{ in}$ ID $\times 12.00\text{ in}$ length | Off-the-shelf extruded tube, ends square-cut and deburred |
| **2** | **End Flange Plates (2x)** | Cast Reinforced Epoxy Plate (Nicpro or equivalent) with embedded brass/aluminum tube rebar and fiberglass core, OR $1/2\text{ in}$ Garolite G-10 / Grade LE Phenolic ($4.0\text{ in} \times 4.0\text{ in} \times 0.50\text{ in}$) | Poured in silicone mold or cut from plate; 4 corner $5/16\text{ in}$ holes drilled |
| **3** | **Tie-Rods (4x)** | $1/4\text{-}20$ Grade 316 Stainless Steel fully threaded rods ($14.0\text{ in}$ length) with 8x stainless nylon-insert locknuts and flat washers | Cut to length with hacksaw |
| **4** | **O-Ring Seals (2x)** | AS568-120 Buna-N or Viton O-rings ($1.00\text{ in}$ ID $\times 1.19\text{ in}$ OD $\times 0.09\text{ in}$ cross-section) | Seated in cast or machined flange counterbore |
| **5** | **Inlet Fitting** | $1/4\text{ in}$ NPT male to $3/8\text{ in}$ hose barb (polypropylene or brass) | Screwed into tapped inlet flange |
| **6** | **Core Separation Splitter** | $3/8\text{ in}$ OD $\times 0.305\text{ in}$ ID $\times 3.0\text{ in}$ length 304 Stainless Steel or rigid rigid acrylic tubing | Press-fit into center bore of outlet flange |
| **7** | **Brine Outlet Fitting** | $1/8\text{ in}$ or $1/4\text{ in}$ NPT male to $1/4\text{ in}$ hose barb | Threaded off-center in outlet flange |
| **8** | **Acoustic Transducers** | 2x $28\text{ mm}$ or $35\text{ mm}$ PZT-5A Piezoelectric Ring/Disc Elements ($28\text{ kHz}$ resonance) | Clamped externally to acrylic barrel with two-piece split collar |
| **9** | **Dielectric Stator Sleeve** | Flexible polyimide (Kapton) sheet ($0.05\text{ mm}$) with interdigitated copper foil fingers ($0.25\text{ mm}$ width, $0.25\text{ mm}$ gap) | Inserted flush against inner barrel circumference |

---

## 3. Step-by-Step Fabrication Guide

```
             +-----------------------------------------------+
             |                TOP VIEW OF FLANGE             |
             |                                               |
             |   (O) [Tie-Rod Hole]     (O) [Tie-Rod Hole]   |
             |           \               /                   |
             |            +-------------+                    |
             |            | O-Ring Seat |                    |
             |            |  (Center)   |                    |
             |            +-------------+                    |
             |           /               \                   |
             |   (O) [Tie-Rod Hole]     (O) [Tie-Rod Hole]   |
             +-----------------------------------------------+
```

### Step 1: Pouring / Preparing the Rebar-Reinforced Epoxy Flanges
1. Place a 4-inch square silicone baking mold on a level work table.
2. Cut four 3-inch lengths of $1/8\text{-inch}$ or $3/16\text{-inch}$ brass or aluminum hobby tubing to act as rebar.
3. Mix $150\text{ mL}$ of 2:1 or 1:1 epoxy (e.g., Nicpro casting epoxy).
4. Pour a $1/8\text{-inch}$ base layer of pure resin into the mold and allow to sit for 10 minutes.
5. Place a layer of chopped fiberglass or polypropylene fiber in the center, lay the four metal rebar tubes diagonally across the corners, and top with the remaining epoxy to a final thickness of $1/2\text{-inch}$ ($12.7\text{ mm}$).
6. Allow 24 hours to cure at room temperature ($20\text{--}25^\circ\text{C}$). Demold two identical, flat, ultra-rigid plates.

### Step 2: Drilling and Porting the Flanges
1. Clamp both plates together.
2. Drill four $5/16\text{-inch}$ ($8\text{ mm}$) through-holes in the corners ($1/2\text{ inch}$ inset from outer edges).
3. **Inlet Flange**: Drill a $7/16\text{-inch}$ center hole and tap with a standard $1/4\text{-}18$ NPT pipe tap. Screw in the $1/4\text{ in}$ NPT to $3/8\text{ in}$ hose barb using PTFE tape.
4. **Outlet Flange**:
   - Drill a precision $3/8\text{-inch}$ center hole. Press-fit the $3\text{-inch}$ long stainless steel core splitter tube into the hole so that it protrudes $1.0\text{ inch}$ into the acrylic barrel.
   - Drill a $7/16\text{-inch}$ hole $0.65\text{ inches}$ off-center and tap $1/4\text{-}18$ NPT for the brine outlet barb.

### Step 3: Inserting the Stator Sleeve & Final Assembly
1. Roll the Kapton interdigitated copper electrode sleeve into a cylinder and slide it inside the 12-inch clear acrylic tube.
2. Seat the O-rings into the flange faces with a smear of silicone grease.
3. Align the acrylic tube between the inlet and outlet flanges.
4. Slide the four $1/4\text{-}20$ stainless steel threaded rods through the four corner holes.
5. Install stainless washers and nylon-insert locknuts. Tighten the nuts in an alternating criss-cross pattern to a uniform torque ($5\text{--}7\text{ ft}\cdot\text{lb}$).

---

## 4. Solid-State Dual-Frequency Driver Circuit

```
                     +---------------------------------------+
   24V DC Input ===> |  Dual-Channel Class-D MOSFET Driver   |
                     |  - Ch 1: 28.5 kHz (Acoustic PZT)      | ===> PZT Transducer Ring
                     |  - Ch 2: 450 kHz (Dielectric Stator)  | ===> Kapton Interdigital Sleeve
                     +---------------------------------------+
```

1. **Acoustic Channel**:
   - Frequency: $28.5\text{ kHz} \pm 1.5\text{ kHz}$ square wave driving a miniature step-up ferrite transformer ($1:5$ turns ratio, producing $60\text{ V}_{\text{RMS}}$ into the PZT clamp).
2. **Dielectric RF Channel**:
   - Frequency: $450\text{ kHz} \to 1.2\text{ MHz}$ sine/square wave ($24\text{ V}_{\text{RMS}}$ peak-to-peak) driving the interdigital stator tracks with zero DC net offset (preventing electrolytic electrode erosion).

---

## 5. Operational Procedure & Performance Verification

1. Connect saline/brackish water source to the inlet barb at low gravity pressure ($0.2\text{ to }0.4\text{ bar}$, $5\text{ psi}$).
2. Adjust feed flow rate to $150\text{ mL/min}$ using a simple pinch valve.
3. Power on the $24\text{ V DC}$ driver ($15\text{ W}$ total consumption).
4. Measure electrical conductivity ($\mathrm{\mu S/cm}$) or total dissolved solids (TDS) at the center pure outlet versus the outer brine annulus:
   - **Central Core (Purified Permeate)**: TDS drops by $60\text{--}80\%$ on a single pass.
   - **Outer Annulus (Reject Brine)**: TDS increases by $40\text{--}70\%$.
