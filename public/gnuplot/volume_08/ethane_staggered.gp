# Gnuplot script: 3D High-Detail Wireframe Snapshot of Ethane (C2H6) Staggered Conformation
# Depicts the discrete electromagnetic architecture on G_N:
# - Central Carbon-Carbon sigma bond vortex tube (d_CC = 2.91 a_0)
# - Two tetrahedral CH3 methyl caps in minimum-repulsion staggered 60-degree dihedral alignment
# - Six discrete Carbon-Hydrogen sigma bond vortex sheaths
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Electromagnetic Snapshot of Staggered Ethane (C_2H_6)\n{/*0.85Tetrahedral Methyl Caps and C-C \\sigma-Bond Sheath on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 44, 44
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X: C-C Bond Axis (a_0)" offset -1,-0.5
set ylabel "Y (a_0)" offset 1,-0.5
set zlabel "Z (a_0)" offset 1,0
set xrange [-3.5:3.5]
set yrange [-3.0:3.0]
set zrange [-3.0:3.0]
set xyplane at -3.0
set view 68, 320, 1.15, 1.0

d_CC = 2.91
x_C1 = -d_CC / 2.0
x_C2 =  d_CC / 2.0

r_core = 0.28
r_H_core = 0.14
d_CH = 2.06
theta_tet = 109.4712 * pi / 180.0
r_perp = d_CH * sin(theta_tet - pi/2.0)
dx_H = d_CH * cos(theta_tet - pi/2.0)

# 1. Carbon Nuclear Cores (Z=6)
x_carb1(u, v) = x_C1 + r_core * sin(u/2.0) * cos(v)
y_carb1(u, v) = r_core * sin(u/2.0) * sin(v)
z_carb1(u, v) = r_core * cos(u/2.0)

x_carb2(u, v) = x_C2 + r_core * sin(u/2.0) * cos(v)
y_carb2(u, v) = r_core * sin(u/2.0) * sin(v)
z_carb2(u, v) = r_core * cos(u/2.0)

# 2. Central C-C Sigma Bond Tube
u_norm(u) = u / (2.0 * pi)
x_cc(u)   = x_C1 + u_norm(u) * d_CC
r_cc(u)   = 0.52 * (sin(u_norm(u) * pi)**0.65) * (1.0 + 0.12 * cos(2.0*u_norm(u)*pi))

x_bond_cc(u, v) = x_cc(u)
y_bond_cc(u, v) = r_cc(u) * cos(v)
z_bond_cc(u, v) = r_cc(u) * sin(v)

# 3. Methyl Cap 1 (at C1, x = -1.455 a_0, pointing -x): 3 C-H bonds at 0, 120, 240 deg
phi_1(k) = k * 2.0 * pi / 3.0
x_h1(u, k) = x_C1 - u_norm(u) * dx_H
y_h1(u, v, k) = u_norm(u) * r_perp * cos(phi_1(k)) + 0.32 * sin(u_norm(u)*pi) * cos(v)
z_h1(u, v, k) = u_norm(u) * r_perp * sin(phi_1(k)) + 0.32 * sin(u_norm(u)*pi) * sin(v)

# 4. Methyl Cap 2 (at C2, x = +1.455 a_0, pointing +x): 3 C-H bonds at 60, 180, 300 deg (Staggered)
phi_2(k) = pi/3.0 + k * 2.0 * pi / 3.0
x_h2(u, k) = x_C2 + u_norm(u) * dx_H
y_h2(u, v, k) = u_norm(u) * r_perp * cos(phi_2(k)) + 0.32 * sin(u_norm(u)*pi) * cos(v)
z_h2(u, v, k) = u_norm(u) * r_perp * sin(phi_2(k)) + 0.32 * sin(u_norm(u)*pi) * sin(v)

set style line 1 lc rgb "#185a9d" lw 1.5   # Blue: C-C central sigma bond
set style line 2 lc rgb "#2c3e50" lw 1.6   # Slate dark: Carbon nuclear cores (Z=6)
set style line 3 lc rgb "#27ae60" lw 1.2   # Green: C-H covalent bond tubes
set style line 4 lc rgb "#c0392b" lw 1.3   # Red: Hydrogen protons

set label 1 "Carbon C_1" at x_C1, 0, 0.45 center font "Sans-Bold,9" tc rgb "#2c3e50"
set label 2 "Carbon C_2" at x_C2, 0, 0.45 center font "Sans-Bold,9" tc rgb "#2c3e50"
set label 3 "Staggered Dihedral: \\Delta\\phi = 60^\\circ" at 0, 0, -2.4 center font "Sans-Bold,10" tc rgb "#185a9d"

set key top right spacing 1.25 font "Sans,9.5"

splot x_bond_cc(u, v), y_bond_cc(u, v), z_bond_cc(u, v) with lines ls 1 title "C-C \\sigma-Bond Sheath (2e^-)", \
      x_carb1(u, v), y_carb1(u, v), z_carb1(u, v) with lines ls 2 title "Carbon Cores (Z=6)", \
      x_carb2(u, v), y_carb2(u, v), z_carb2(u, v) with lines ls 2 notitle, \
      x_h1(u, 0), y_h1(u, v, 0), z_h1(u, v, 0) with lines ls 3 title "C-H \\sigma-Bonds (6x, Staggered 60^\\circ)", \
      x_h1(u, 1), y_h1(u, v, 1), z_h1(u, v, 1) with lines ls 3 notitle, \
      x_h1(u, 2), y_h1(u, v, 2), z_h1(u, v, 2) with lines ls 3 notitle, \
      x_h2(u, 0), y_h2(u, v, 0), z_h2(u, v, 0) with lines ls 3 notitle, \
      x_h2(u, 1), y_h2(u, v, 1), z_h2(u, v, 1) with lines ls 3 notitle, \
      x_h2(u, 2), y_h2(u, v, 2), z_h2(u, v, 2) with lines ls 3 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
