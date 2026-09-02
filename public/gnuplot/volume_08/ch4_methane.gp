# Gnuplot script: 3D High-Detail Wireframe Snapshot of Methane (CH4)
# Depicts the discrete electromagnetic architecture of the tetrahedral CH4 molecule on G_N:
# - Central Carbon-12 nucleus with 1s^2 core current toroid
# - Four sp3-hybridized tetrahedral C-H covalent bonding tubes (bond angle = 109.47 deg)
# - Four peripheral Hydrogen proton screening wells
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Tetrahedral Architecture of Methane (CH_4)\n{/*0.85sp^3 Covalent Vortex Tubes and Carbon Core on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 40, 40
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X (a_0)" offset -1,-0.5
set ylabel "Y (a_0)" offset 1,-0.5
set zlabel "Z (a_0)" offset 1,0
set xrange [-2.4:2.4]
set yrange [-2.4:2.4]
set zrange [-2.4:2.4]
set xyplane at -2.4
set view 62, 50, 1.2, 1.0

# Physical constants in atomic units (a_0 ~ 0.529177 Angstrom)
# C-H bond length d_CH = 2.06 a_0 (~1.09 Angstrom)
d_CH = 2.06
inv_sqrt3 = 1.0 / sqrt(3.0)

# Tetrahedral vertex coordinates for 4 Protons
# H1: (+1, +1, +1)
x_H1 = d_CH * inv_sqrt3 *  1.0
y_H1 = d_CH * inv_sqrt3 *  1.0
z_H1 = d_CH * inv_sqrt3 *  1.0

# H2: (+1, -1, -1)
x_H2 = d_CH * inv_sqrt3 *  1.0
y_H2 = d_CH * inv_sqrt3 * -1.0
z_H2 = d_CH * inv_sqrt3 * -1.0

# H3: (-1, +1, -1)
x_H3 = d_CH * inv_sqrt3 * -1.0
y_H3 = d_CH * inv_sqrt3 *  1.0
z_H3 = d_CH * inv_sqrt3 * -1.0

# H4: (-1, -1, +1)
x_H4 = d_CH * inv_sqrt3 * -1.0
y_H4 = d_CH * inv_sqrt3 * -1.0
z_H4 = d_CH * inv_sqrt3 *  1.0

# 1. Carbon 1s^2 Inner Core Current Toroid at Origin
r_C_core_maj = 0.22
r_C_core_min = 0.08
x_C_core(u, v) = (r_C_core_maj + r_C_core_min * cos(v)) * cos(u)
y_C_core(u, v) = (r_C_core_maj + r_C_core_min * cos(v)) * sin(u)
z_C_core(u, v) = r_C_core_min * sin(v)

# 2. Parametric Tetrahedral C-H Covalent Bonding Tubes
u_norm(u) = u / (2.0 * pi)
# Tapered bond radius: narrower near nuclei, bulging at intermediate valence zone
r_tube(u) = 0.30 * (sin(u_norm(u) * pi)**0.70) * (1.0 + 0.18 * (1.0 - u_norm(u)))

# Normal vector basis for tube 1 (along +1, +1, +1)
# Orthogonal unit vectors in transverse plane of bond 1
x_t1(u, v) = u_norm(u)*x_H1 + r_tube(u)*(cos(v)*(-inv_sqrt3*sqrt(2.0)) + sin(v)*(0.0))
y_t1(u, v) = u_norm(u)*y_H1 + r_tube(u)*(cos(v)*(inv_sqrt3/sqrt(2.0)) + sin(v)*(1.0/sqrt(2.0)))
z_t1(u, v) = u_norm(u)*z_H1 + r_tube(u)*(cos(v)*(inv_sqrt3/sqrt(2.0)) - sin(v)*(1.0/sqrt(2.0)))

x_t2(u, v) = u_norm(u)*x_H2 + r_tube(u)*(cos(v)*(-inv_sqrt3*sqrt(2.0)) + sin(v)*(0.0))
y_t2(u, v) = u_norm(u)*y_H2 + r_tube(u)*(cos(v)*(-inv_sqrt3/sqrt(2.0)) + sin(v)*(1.0/sqrt(2.0)))
z_t2(u, v) = u_norm(u)*z_H2 + r_tube(u)*(cos(v)*(-inv_sqrt3/sqrt(2.0)) - sin(v)*(1.0/sqrt(2.0)))

x_t3(u, v) = u_norm(u)*x_H3 + r_tube(u)*(cos(v)*(inv_sqrt3*sqrt(2.0)) + sin(v)*(0.0))
y_t3(u, v) = u_norm(u)*y_H3 + r_tube(u)*(cos(v)*(inv_sqrt3/sqrt(2.0)) + sin(v)*(1.0/sqrt(2.0)))
z_t3(u, v) = u_norm(u)*z_H3 + r_tube(u)*(cos(v)*(-inv_sqrt3/sqrt(2.0)) - sin(v)*(1.0/sqrt(2.0)))

x_t4(u, v) = u_norm(u)*x_H4 + r_tube(u)*(cos(v)*(inv_sqrt3*sqrt(2.0)) + sin(v)*(0.0))
y_t4(u, v) = u_norm(u)*y_H4 + r_tube(u)*(cos(v)*(-inv_sqrt3/sqrt(2.0)) + sin(v)*(1.0/sqrt(2.0)))
z_t4(u, v) = u_norm(u)*z_H4 + r_tube(u)*(cos(v)*(inv_sqrt3/sqrt(2.0)) - sin(v)*(1.0/sqrt(2.0)))

# 3. Four Proton Screening Spheres
r_p = 0.14
x_p(u, v, x0) = x0 + r_p * sin(u/2.0) * cos(v)
y_p(u, v, y0) = y0 + r_p * sin(u/2.0) * sin(v)
z_p(u, v, z0) = z0 + r_p * cos(u/2.0)

# Wireframe Line Styles
set style line 1 lc rgb "#002855" lw 1.3   # Deep blue: Tetrahedral C-H covalent bonding tubes
set style line 2 lc rgb "#8b0000" lw 1.5   # Red: Carbon core 1s^2 toroid
set style line 3 lc rgb "#004d20" lw 1.2   # Green: Hydrogen proton loci

# Labels
set label 1 "Carbon-12 Core (Z=6)" at 0, 0, -0.35 center font "Sans-Bold,10" tc rgb "#8b0000"
set label 2 "H_1^+" at x_H1, y_H1, z_H1+0.25 center font "Sans-Bold,9" tc rgb "#004d20"
set label 3 "H_2^+" at x_H2, y_H2, z_H2+0.25 center font "Sans-Bold,9" tc rgb "#004d20"
set label 4 "H_3^+" at x_H3, y_H3, z_H3+0.25 center font "Sans-Bold,9" tc rgb "#004d20"
set label 5 "H_4^+" at x_H4, y_H4, z_H4+0.25 center font "Sans-Bold,9" tc rgb "#004d20"
set label 6 "Tetrahedral Angle: 109.47^\circ" at 0, -1.5, -1.8 center font "Sans,9" tc rgb "#111111"

splot x_t1(u, v), y_t1(u, v), z_t1(u, v) with lines ls 1 title "Tetrahedral C-H \\sigma-Bonds", \
      x_t2(u, v), y_t2(u, v), z_t2(u, v) with lines ls 1 notitle, \
      x_t3(u, v), y_t3(u, v), z_t3(u, v) with lines ls 1 notitle, \
      x_t4(u, v), y_t4(u, v), z_t4(u, v) with lines ls 1 notitle, \
      x_C_core(u, v), y_C_core(u, v), z_C_core(u, v) with lines ls 2 title "Carbon 1s^2 Core Toroid", \
      x_p(u, v, x_H1), y_p(u, v, y_H1), z_p(u, v, z_H1) with lines ls 3 title "Hydrogen Protons (4x)", \
      x_p(u, v, x_H2), y_p(u, v, y_H2), z_p(u, v, z_H2) with lines ls 3 notitle, \
      x_p(u, v, x_H3), y_p(u, v, y_H3), z_p(u, v, z_H3) with lines ls 3 notitle, \
      x_p(u, v, x_H4), y_p(u, v, y_H4), z_p(u, v, z_H4) with lines ls 3 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
