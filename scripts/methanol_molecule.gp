# Gnuplot script: 3D High-Detail Wireframe Snapshot of Methanol (CH3OH)
# Depicts the discrete electromagnetic architecture of Methanol on G_N:
# - Methyl group (-CH3): Central Carbon nucleus with 1s^2 core toroid and 3 C-H covalent bonding tubes
# - Central C-O polar covalent bonding tube bridging Carbon and Oxygen
# - Hydroxyl group (-OH): Oxygen nucleus with 1s^2 core toroid, bent O-H covalent bond, and 2 rear lone-pair lobes
# - Proton screening spheres for all 4 hydrogens
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Molecular Architecture of Methanol (CH_3OH)\n{/*0.85Methyl-Hydroxyl Junction, C-O/O-H Covalent Tubes, and Lone Pairs on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 40, 40
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X: C-O Axis (a_0)" offset -1,-0.5
set ylabel "Y (a_0)" offset 1,-0.5
set zlabel "Z (a_0)" offset 1,0
set xrange [-2.6:4.8]
set yrange [-2.6:2.6]
set zrange [-2.4:2.6]
set xyplane at -2.4
set view 62, 320, 1.15, 1.0

# Physical constants in atomic units (a_0 ~ 0.529177 Angstrom)
# C nucleus at (0, 0, 0)
# C-O bond length d_CO = 2.70 a_0 (~1.43 Angstrom)
# C-H bond length d_CH = 2.06 a_0 (~1.09 Angstrom)
# O-H bond length d_OH = 1.81 a_0 (~0.96 Angstrom)
d_CO = 2.70
d_CH = 2.06
d_OH = 1.81

# Oxygen nucleus at (d_CO, 0, 0)
x_O = d_CO
y_O = 0.0
z_O = 0.0

# Hydroxyl Hydrogen (bent at 108.9 deg relative to C-O axis in XZ plane)
th_COH = 108.9 * pi / 180.0
x_HO = x_O - d_OH * cos(th_COH)
y_HO = 0.0
z_HO = d_OH * sin(th_COH)

# Methyl Hydrogens (pointing backwards at X < 0, 109.5 deg tetrahedral umbrella)
th_CH = 109.5 * pi / 180.0
x_hc_back = -d_CH * cos(pi - th_CH) # ~ -0.68 a_0
r_hc_perp = d_CH * sin(pi - th_CH)  # ~ 1.94 a_0

x_H1 = x_hc_back
y_H1 = 0.0
z_H1 = -r_hc_perp

x_H2 = x_hc_back
y_H2 = r_hc_perp * sin(pi/3.0)
z_H2 = r_hc_perp * cos(pi/3.0)

x_H3 = x_hc_back
y_H3 = -r_hc_perp * sin(pi/3.0)
z_H3 = r_hc_perp * cos(pi/3.0)

# Oxygen Lone-Pair Lobes (pointing in +/- Y with -Z tilt)
d_lp = 1.15
th_lp = 54.0 * pi / 180.0
x_lp1 = x_O - 0.35
y_lp1 = d_lp * sin(th_lp)
z_lp1 = -d_lp * cos(th_lp)

x_lp2 = x_O - 0.35
y_lp2 = -d_lp * sin(th_lp)
z_lp2 = -d_lp * cos(th_lp)

# 1. Carbon and Oxygen 1s^2 Core Current Toroids
r_C_core_maj = 0.22
r_C_core_min = 0.08
x_C_core(u, v) = (r_C_core_maj + r_C_core_min * cos(v)) * cos(u)
y_C_core(u, v) = (r_C_core_maj + r_C_core_min * cos(v)) * sin(u)
z_C_core(u, v) = r_C_core_min * sin(v)

r_O_core_maj = 0.20
r_O_core_min = 0.07
x_O_core(u, v) = x_O + r_O_core_min * sin(v)
y_O_core(u, v) = (r_O_core_maj + r_O_core_min * cos(v)) * cos(u)
z_O_core(u, v) = (r_O_core_maj + r_O_core_min * cos(v)) * sin(u)

# 2. C-O Covalent Bonding Tube
u_n(u) = u / (2.0 * pi)
r_tube_CO(u) = 0.35 * (sin(u_n(u) * pi)**0.65) * (1.0 + 0.15 * (1.0 - u_n(u)))
x_b_CO(u, v) = u_n(u) * d_CO
y_b_CO(u, v) = r_tube_CO(u) * cos(v)
z_b_CO(u, v) = r_tube_CO(u) * sin(v)

# 3. O-H Covalent Bonding Tube
r_tube_OH(u) = 0.28 * (sin(u_n(u) * pi)**0.70)
x_b_OH(u, v) = x_O + u_n(u) * (x_HO - x_O) + r_tube_OH(u) * cos(v) * 0.5
y_b_OH(u, v) = r_tube_OH(u) * sin(v)
z_b_OH(u, v) = z_O + u_n(u) * (z_HO - z_O) + r_tube_OH(u) * cos(v) * 0.86

# 4. Three Methyl C-H Bonding Tubes
r_tube_CH(u) = 0.26 * (sin(u_n(u) * pi)**0.70)
x_b_CH1(u, v) = u_n(u) * x_H1 + r_tube_CH(u) * cos(v)
y_b_CH1(u, v) = u_n(u) * y_H1 + r_tube_CH(u) * sin(v)
z_b_CH1(u, v) = u_n(u) * z_H1

x_b_CH2(u, v) = u_n(u) * x_H2 + r_tube_CH(u) * cos(v)
y_b_CH2(u, v) = u_n(u) * y_H2 + r_tube_CH(u) * sin(v)
z_b_CH2(u, v) = u_n(u) * z_H2

x_b_CH3(u, v) = u_n(u) * x_H3 + r_tube_CH(u) * cos(v)
y_b_CH3(u, v) = u_n(u) * y_H3 + r_tube_CH(u) * sin(v)
z_b_CH3(u, v) = u_n(u) * z_H3

# 5. Oxygen Lone-Pair Lobes
r_lp(u) = 0.32 * sin(u_n(u) * pi) * (1.0 - 0.20 * cos(u_n(u) * pi))
x_lp_1(u, v) = x_O + u_n(u) * (x_lp1 - x_O) + r_lp(u) * cos(v)
y_lp_1(u, v) = u_n(u) * y_lp1 + r_lp(u) * sin(v)
z_lp_1(u, v) = u_n(u) * z_lp1

x_lp_2(u, v) = x_O + u_n(u) * (x_lp2 - x_O) + r_lp(u) * cos(v)
y_lp_2(u, v) = u_n(u) * y_lp2 + r_lp(u) * sin(v)
z_lp_2(u, v) = u_n(u) * z_lp2

# 6. Hydrogen Proton Screening Spheres
r_p = 0.13
x_p(u, v, x0) = x0 + r_p * sin(u/2.0) * cos(v)
y_p(u, v, y0) = y0 + r_p * sin(u/2.0) * sin(v)
z_p(u, v, z0) = z0 + r_p * cos(u/2.0)

# Wireframe Line Styles
set style line 1 lc rgb "#185a9d" lw 1.4   # Deep blue: C-O and C-H sigma bonds
set style line 2 lc rgb "#2980b9" lw 1.3   # Light blue: O-H bond
set style line 3 lc rgb "#c0392b" lw 1.5   # Red: Carbon core toroid
set style line 4 lc rgb "#e67e22" lw 1.4   # Amber: Oxygen core toroid
set style line 5 lc rgb "#8e44ad" lw 1.1   # Purple: Oxygen lone-pair lobes
set style line 6 lc rgb "#27ae60" lw 1.2   # Green: Hydrogen protons

# Labels
set label 1 "Carbon (Z=6)" at 0, 0, -0.38 center font "Sans-Bold,10" tc rgb "#c0392b"
set label 2 "Oxygen (Z=8)" at x_O, 0, -0.38 center font "Sans-Bold,10" tc rgb "#e67e22"
set label 3 "Hydroxyl H^+" at x_HO, 0, z_HO+0.22 center font "Sans-Bold,9" tc rgb "#27ae60"

splot x_b_CO(u, v),  y_b_CO(u, v),  z_b_CO(u, v)  with lines ls 1 title "C-O Covalent Bond Tube", \
      x_b_OH(u, v),  y_b_OH(u, v),  z_b_OH(u, v)  with lines ls 2 title "O-H Covalent Bond Tube", \
      x_b_CH1(u, v), y_b_CH1(u, v), z_b_CH1(u, v) with lines ls 1 title "Methyl C-H Bonds (3x)", \
      x_b_CH2(u, v), y_b_CH2(u, v), z_b_CH2(u, v) with lines ls 1 notitle, \
      x_b_CH3(u, v), y_b_CH3(u, v), z_b_CH3(u, v) with lines ls 1 notitle, \
      x_C_core(u, v),y_C_core(u, v),z_C_core(u, v)with lines ls 3 title "Carbon 1s^2 Core", \
      x_O_core(u, v),y_O_core(u, v),z_O_core(u, v)with lines ls 4 title "Oxygen 1s^2 Core", \
      x_lp_1(u, v),  y_lp_1(u, v),  z_lp_1(u, v)  with lines ls 5 title "Oxygen Lone Pairs", \
      x_lp_2(u, v),  y_lp_2(u, v),  z_lp_2(u, v)  with lines ls 5 notitle, \
      x_p(u, v, x_HO), y_p(u, v, y_HO), z_p(u, v, z_HO) with lines ls 6 title "Hydrogen Protons (4x)", \
      x_p(u, v, x_H1), y_p(u, v, y_H1), z_p(u, v, z_H1) with lines ls 6 notitle, \
      x_p(u, v, x_H2), y_p(u, v, y_H2), z_p(u, v, z_H2) with lines ls 6 notitle, \
      x_p(u, v, x_H3), y_p(u, v, y_H3), z_p(u, v, z_H3) with lines ls 6 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
