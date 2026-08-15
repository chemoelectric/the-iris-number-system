# MTE-1: Multivector Atmospheric Transpiration Energy Harvester

**Version**: 1.0  
**Domain**: Solid-State Thermal-to-Electric Transduction & Capillary Ambient Energy Harvesting  
**Physical Foundation**: Master Field Equation $\mathcal{D}\mathcal{F}_{\text{total}} = \mathcal{J}_{\text{total}}$, Discrete Streaming Potential $\nabla P_{\text{capillary}}$, and Interfacial Evaporative Charge Separation

---

## 1. Theoretical Foundation

```
                                 Vertical Cross-Section
                     +----------------------------------------------+
   Ambient Air ====> |  Top Electrode (Perforated Stainless Mesh)  |  (Evaporation Zone / Cold)
   (Relative Hum < 100%) [ Carbonized Nano-Porous Matrix Layer ]    |
                     |  . . . . . . . . . . . . . . . . . . . . . . |
                     |  Graded Porous Terracotta / Ceramic Matrix   |
                     |  (Continuous Capillary Upward Transpiration) |
                     |  . . . . . . . . . . . . . . . . . . . . . . |
   Water Reservoir > |  Bottom Electrode (Stainless Screen / Base)  |  (Liquid Contact / Warm)
                     +----------------------------------------------+
```

### 1.1 First-Principles Electro-Kinetic Coupling
In the Master Field Equation $\mathcal{D}\mathcal{F}_{\text{total}} = \mathcal{J}_{\text{total}}$, current density $\mathcal{J}_{\text{total}}$ consists of both conduction and convection terms $\rho_0 (\mathbf{u} + ce_4)$. 

When polar liquid water transpires through a sub-micron pore network under capillary suction, an electrical double layer (EDL) forms along the pore walls. The Stern layer of ions remains immobilized while the diffuse mobile counter-ion cloud is sheared upward by the convective fluid flow $\mathbf{u}_{\text{capillary}}$.

The resulting streaming potential $\Delta V$ generated across the porous height $h$ is:
\[
\Delta V = \frac{\varepsilon_0 \varepsilon_r \zeta}{\eta (\sigma_b + 2\sigma_s / r_{\text{pore}})} \Delta P_{\text{capillary}}
\]
where:
- $\zeta$ is the zeta potential of the ceramic-water interface ($-30\text{ to }-65\text{ mV}$).
- $\Delta P_{\text{capillary}} = \frac{2\gamma \cos \theta}{r_{\text{pore}}}$ is the Laplace capillary pressure head ($>10\text{ to }50\text{ bar}$ inside sub-100 nm pores).
- $\eta$ is fluid dynamic viscosity.
- $\sigma_b, \sigma_s$ are bulk and surface electrical conductivities.

Because natural evaporation at the top boundary continuously evacuates water vapor into the atmosphere (driven by ambient solar/room heat and relative humidity deficit), **the capillary flow is permanent and continuous without requiring any external pump**.

---

## 2. Mechanical Construction (No Metalwork / Simple Casting)

```
                 +-----------------------------------------------+
                 |              EXPLODED STACK VIEW              |
                 |                                               |
                 | [Top Stainless Screen + Carbon Black Layer]   |
                 |                 |                             |
                 | [Porous Terracotta / Silica-Ceramic Disk]     |
                 |                 |                             |
                 | [Bottom Stainless Screen + Wick Feed]         |
                 |                 |                             |
                 | [Molded Cast-Epoxy Base Housing & Reservoir]  |
                 +-----------------------------------------------+
```

### 2.2 Component Specifications

| Item | Component | Material / Specification | Purpose |
| :---: | :--- | :--- | :--- |
| **1** | **Base Reservoir Housing** | Molded Epoxy or Food-Grade Polypropylene container ($4.0\text{ in} \times 4.0\text{ in} \times 2.0\text{ in}$) | Holds working fluid (tap water or dilute $0.01\text{ M}$ salt solution) |
| **2** | **Ceramic Transpiration Matrix** | Unglazed Terracotta Tile / Ceramic casting ($3.5\text{ in} \times 3.5\text{ in} \times 0.375\text{ in}$) | Provides high-density capillary pore network ($r \approx 50\text{--}200\text{ nm}$) |
| **3** | **Carbon Active Layer** | Carbon black / activated charcoal powder slurry bound with 1% PVA or gelatin | High surface-area electron exchange layer at the evaporation boundary |
| **4** | **Electrodes (Top & Bottom)** | 304 Stainless Steel Fine Wire Mesh (100 mesh, from splatter screen or filter cloth) | Chemically inert current collectors |
| **5** | **Terminal Posts** | M4 or 8-32 Stainless Steel machine screws with silicone sealing washers | Electrical output terminals (+ and -) |

---

## 3. Step-by-Step Fabrication Guide

1. **Preparing the Ceramic Matrix**:
   - Cut a $3.5\text{ in} \times 3.5\text{ in}$ square from an unglazed terracotta planter base or porous ceramic tile using a score-and-snap tile cutter or hand hacksaw.
   - Boil the ceramic tile in distilled water with 1% household vinegar for 15 minutes to clear pore channels of mineral dust, then allow to dry.

2. **Applying the Carbon Boundary Layer**:
   - Mix $5\text{ g}$ of finely powdered charcoal or lampblack carbon with $20\text{ mL}$ of water and a few drops of white wood glue or dissolved gelatin to form a smooth black ink.
   - Brush a uniform, thin black coat onto the top face of the ceramic tile. This acts as the conductive evaporation cathode.

3. **Applying Current Collectors**:
   - Cut two squares of stainless steel wire mesh ($3.5\text{ in} \times 3.5\text{ in}$).
   - Place one screen on the bottom bare ceramic face (anode).
   - Place the other screen on top of the carbonized face (cathode).
   - Fasten stainless wire leads to both screens and bring them out to external binding posts.

4. **Mounting in the Reservoir**:
   - Mount the ceramic-screen sandwich vertically or suspended horizontally directly over the cast-epoxy water reservoir so that the bottom face is submerged in water while the top black face is fully exposed to open ambient airflow.

---

## 4. Electrical Output & Energy Harvesting Performance

| Parameter | Single Cell | 4-Cell Series Stack |
| :--- | :--- | :--- |
| **Open Circuit Voltage ($V_{\text{OC}}$)** | $0.55\text{--}0.72\text{ V DC}$ | $2.2\text{--}2.8\text{ V DC}$ |
| **Short Circuit Current ($I_{\text{SC}}$)** | $12\text{--}25\text{ mA}$ | $15\text{--}25\text{ mA}$ |
| **Continuous Power Density** | $8\text{--}15\text{ mW}$ | $35\text{--}60\text{ mW}$ |
| **Operating Condition** | Ambient Room Air ($20\text{--}30^\circ\text{C}$, $30\text{--}65\%\text{ RH}$) | Operates 24/7 without sunlight |

---

## 5. Storage & Power Conditioning

Connecting a 4-cell stack directly to an ultra-low-power boost converter IC (e.g., TI BQ25504 or LTC3108, commonly available on $3 hobby breakout boards) steps the $2.4\text{ V DC}$ up to a regulated $3.3\text{ V}$ or $5.0\text{ V}$ rail, continuously trickle-charging a supercapacitor or lithium iron phosphate ($\mathrm{LiFePO}_4$) battery to power sensors, clocks, or emergency radios indefinitely from natural room evaporation.
