# Gnuplot script: 3D High-Detail Wireframe Snapshot of Carbon Dioxide (CO2)
# Depicts the discrete linear electromagnetic architecture of CO2 on G_N:
# - Linear O=C=O geometry (bond angle = 180 deg, d_CO = 2.19 a_0)
# - Central Carbon 1s^2 core toroid at origin
# - Two dual double-bond cylinders (interlocking sigma bond and orthogonal pi_y / pi_z vortex sheets)
# - Terminal Oxygen nuclei with 1s^2 core toroids and outward lone-pair lobes
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Linear Double-Bond Architecture of Carbon Dioxide (CO_2)\n{/*0.85Linear \\sigma-\\pi Double-Bond Cylinders and Lone-Pair Lobes on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 44, 44
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X: Molecular Axis (a_0)" offset -1,-0.5
set ylabel "Y (a_0)" offset 1,-0.5
set zlabel "Z (a_0)" offset 1,0
set xrange [-3.6:3.6]
set yrange [-2.2:2.2]
set zrange [-2.2:2.2]
set xyplane at -2.2
set view 65, 340, 1.15, 1.0

# Physical constants in atomic units (a_0 ~ 0.529177 Angstrom)
# C=O double bond length d_CO = 2.19 a_0 (~1.16 Angstrom)
d_CO = 2.19
x_O1 = -d_CO
x_O2 =  d_CO

# 1. Central Carbon 1s^2 Core Current Toroid at Origin (x = 0)
r_C_core_maj = 0.22
r_C_core_min = 0.08
x_C_core(u, v) = r_C_core_min * sin(v)
y_C_core(u, v) = (r_C_core_maj + r_C_core_min * cos(v)) * cos(u)
z_C_core(u, v) = (r_C_core_maj + r_C_core_min * cos(v)) * sin(u)

# 2. Oxygen 1s^2 Core Current Toroids at x = +/- d_CO
r_O_core_maj = 0.20
r_O_core_min = 0.07
x_O1_core(u, v) = x_O1 + r_O_core_min * sin(v)
y_O1_core(u, v) = (r_O_core_maj + r_O_core_min * cos(v)) * cos(u)
z_O1_core(u, v) = (r_O_core_maj + r_O_core_min * cos(v)) * sin(u)

x_O2_core(u, v) = x_O2 + r_O_core_min * sin(v)
y_O2_core(u, v) = (r_O_core_maj + r_O_core_min * cos(v)) * cos(u)
z_O2_core(u, v) = (r_O_core_maj + r_O_core_min * cos(v)) * sin(u)

# 3. Interlocking C=O Double Bond Cylinders (Combined sigma-core and orthogonal pi-vortices)
u_norm(u) = u / (2.0 * pi)

# Left C=O bond (-d_CO to 0)
x_b_left(u) = x_O1 + u_norm(u) * d_CO
r_sig(u)    = 0.36 * (sin(u_norm(u) * pi)**0.60) * (1.0 + 0.15 * cos(u_norm(u) * pi))
# pi-modulation in Y and Z planes
r_pi_y(u)   = 0.22 * sin(u_norm(u) * pi)
r_pi_z(u)   = 0.22 * sin(u_norm(u) * pi)

x_db1(u, v) = x_b_left(u)
y_db1(u, v) = (r_sig(u) + r_pi_y(u)*cos(2.0*v)) * cos(v)
z_db1(u, v) = (r_sig(u) + r_pi_z(u)*sin(2.0*v)) * sin(v)

# Right C=O bond (0 to +d_CO)
x_b_right(u) = 0.0 + u_norm(u) * d_CO
x_db2(u, v)  = x_b_right(u)
y_db2(u, v)  = (r_sig(u) + r_pi_y(u)*sin(2.0*v)) * cos(v)
z_db2(u, v)  = (r_sig(u) + r_pi_z(u)*cos(2.0*v)) * sin(v)

# 4. Terminal Oxygen Lone-Pair Lobes (Outward-directed at the ends)
d_lp_len = 0.85
r_lp(u)  = 0.28 * sin(u_norm(u) * pi)

# Left Oxygen Lone Pairs (pointing towards -X)
x_lp_L1(u, v) = x_O1 - u_norm(u) * d_lp_len
y_lp_L1(u, v) = 0.45 * u_norm(u) + r_lp(u) * cos(v)
z_lp_L1(u, v) = r_lp(u) * sin(v)

x_lp_L2(u, v) = x_O1 - u_norm(u) * d_lp_len
y_lp_L2(u, v) = -0.45 * u_norm(u) + r_lp(u) * cos(v)
z_lp_L2(u, v) = r_lp(u) * sin(v)

# Right Oxygen Lone Pairs (pointing towards +X)
x_lp_R1(u, v) = x_O2 + u_norm(u) * d_lp_len
y_lp_R1(u, v) = r_lp(u) * cos(v)
z_lp_R1(u, v) = 0.45 * u_norm(u) + r_lp(u) * sin(v)

x_lp_R2(u, v) = x_O2 + u_norm(u) * d_lp_len
y_lp_R2(u, v) = r_lp(u) * cos(v)
z_lp_R2(u, v) = -0.45 * u_norm(u) + r_lp(u) * sin(v)

# Wireframe Line Styles
set style line 1 lc rgb "#185a9d" lw 1.5   # Deep blue: C=O double-bond vortex cylinders
set style line 2 lc rgb "#c0392b" lw 1.5   # Red: Carbon core toroid
set style line 3 lc rgb "#e67e22" lw 1.3   # Amber: Oxygen core toroids
set style line 4 lc rgb "#8e44ad" lw 1.1   # Purple: Terminal oxygen lone-pair lobes

# Labels
set label 1 "Carbon (Z=6)" at 0, 0, -0.45 center font "Sans-Bold,10" tc rgb "#c0392b"
set label 2 "Oxygen O_1 (Z=8)" at x_O1, 0, -0.45 center font "Sans-Bold,10" tc rgb "#e67e22"
set label 3 "Oxygen O_2 (Z=8)" at x_O2, 0, -0.45 center font "Sans-Bold,10" tc rgb "#e67e22"
set label 4 "Linear Angle: 180^\circ" at 0, -1.2, -1.4 center font "Sans,9" tc rgb "#555555"

splot x_db1(u, v),    y_db1(u, v),    z_db1(u, v)    with lines ls 1 title "C=O \\sigma-\\pi Double-Bond Cylinders (4e^- each)", \
      x_db2(u, v),    y_db2(u, v),    z_db2(u, v)    with lines ls 1 notitle, \
      x_C_core(u, v), y_C_core(u, v), z_C_core(u, v) with lines ls 2 title "Carbon 1s^2 Core Toroid", \
      x_O1_core(u, v),y_O1_core(u, v),z_O1_core(u, v)with lines ls 3 title "Oxygen 1s^2 Core Toroids", \
      x_O2_core(u, v),y_O2_core(u, v),z_O2_core(u, v)with lines ls 3 notitle, \
      x_lp_L1(u, v),  y_lp_L1(u, v),  z_lp_L1(u, v)  with lines ls 4 title "Terminal Oxygen Lone-Pair Lobes", \
      x_lp_L2(u, v),  y_lp_L2(u, v),  z_lp_L2(u, v)  with lines ls 4 notitle, \
      x_lp_R1(u, v),  y_lp_R1(u, v),  z_lp_R1(u, v)  with lines ls 4 notitle, \
      x_lp_R2(u, v),  y_lp_R2(u, v),  z_lp_R2(u, v)  with lines ls 4 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
