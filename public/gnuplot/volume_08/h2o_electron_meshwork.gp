# Gnuplot script: 3D High-Detail Close-Up Wireframe of Electron Interactions in Water (H2O)
# Depicts the instantaneous electromagnetic orbital vortex meshwork on G_N:
# - Two O-H polar covalent bonding electron tubes bridging the oxygen and protons
# - Two expansive trigonal oxygen lone-pair lobes in the rear hemisphere
# - Concentric Oxygen 1s^2 core current toroid
# Pure wireframe meshwork with hidden-line removal. No surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Electromagnetic Architecture of Water (H_2O)\n{/*0.85Bent Dipole Geometry and Lone-Pair Lobes on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

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
set xrange [-2.0:2.0]
set yrange [-2.0:2.0]
set zrange [-1.8:2.2]
set xyplane at -1.8
set view 60, 45, 1.25, 1.0

# Oxygen nucleus at origin (0, 0, 0)
# Equilibrium bond length d_OH = 1.81 a_0 (~0.958 Angstrom), bond angle = 104.5 deg
d_OH    = 1.81
th_half = 52.25 * pi / 180.0

# Proton coordinates in XZ plane
x_H1 =  d_OH * sin(th_half)
y_H1 =  0.0
z_H1 =  d_OH * cos(th_half)

x_H2 = -d_OH * sin(th_half)
y_H2 =  0.0
z_H2 =  d_OH * cos(th_half)

# Lone-pair centers in YZ plane (pointing backwards at -Z)
th_lp_half = 55.0 * pi / 180.0
d_lp       = 1.20
x_lp1 =  0.0
y_lp1 =  d_lp * sin(th_lp_half)
z_lp1 = -d_lp * cos(th_lp_half)

x_lp2 =  0.0
y_lp2 = -d_lp * sin(th_lp_half)
z_lp2 = -d_lp * cos(th_lp_half)

# ----------------------------------------------------------------------------
# 1. O-H Polar Covalent Bonding Tubes (Parametric 3D Cylinders in XZ plane)
# Bond vectors: ( +/- d_OH*sin(th_half), 0, d_OH*cos(th_half) )
# Orthonormal transverse basis for Bond 1 (+X):
#   e_axial = ( sin(th_half), 0,  cos(th_half) )
#   e_perp1 = ( cos(th_half), 0, -sin(th_half) )  (in XZ plane)
#   e_perp2 = ( 0,            1,  0            )  (in Y direction)
# ----------------------------------------------------------------------------
u_norm(u) = u / (2.0 * pi)
r_tube(u) = 0.34 * (sin(u_norm(u)*pi)**0.70) * (1.0 + 0.20*(1.0 - u_norm(u)))

x_b1(u, v) = u_norm(u)*x_H1 + r_tube(u)*(cos(v)*cos(th_half))
y_b1(u, v) = r_tube(u)*sin(v)
z_b1(u, v) = u_norm(u)*z_H1 - r_tube(u)*(cos(v)*sin(th_half))

x_b2(u, v) = u_norm(u)*x_H2 - r_tube(u)*(cos(v)*cos(th_half))
y_b2(u, v) = r_tube(u)*sin(v)
z_b2(u, v) = u_norm(u)*z_H2 - r_tube(u)*(cos(v)*sin(th_half))

# ----------------------------------------------------------------------------
# 2. Oxygen 1s^2 Inner Core Current Toroid at Origin (0, 0, 0)
# ----------------------------------------------------------------------------
r_O_core_maj = 0.24
r_O_core_min = 0.08
x_O_core(u, v) = (r_O_core_maj + r_O_core_min*cos(v))*cos(u)
y_O_core(u, v) = (r_O_core_maj + r_O_core_min*cos(v))*sin(u)
z_O_core(u, v) = r_O_core_min*sin(v)

# ----------------------------------------------------------------------------
# 3. Oxygen 2p Lone-Pair Teardrop Lobes (in YZ plane, tilted backwards at -Z)
# Lobe axes: ( 0, +/- d_lp*sin(th_lp_half), -d_lp*cos(th_lp_half) )
# Orthonormal transverse basis for Lone Pair 1 (+Y):
#   e_axial = ( 0,  sin(th_lp_half), -cos(th_lp_half) )
#   e_perp1 = ( 1,  0,                0               ) (in X direction)
#   e_perp2 = ( 0,  cos(th_lp_half),  sin(th_lp_half) ) (in YZ plane)
# ----------------------------------------------------------------------------
r_lp(u) = 0.38 * sin(u_norm(u)*pi) * (1.0 - 0.22*cos(u_norm(u)*pi))

x_lp_m1(u, v) = r_lp(u)*sin(v)
y_lp_m1(u, v) = u_norm(u)*y_lp1 + r_lp(u)*(cos(v)*cos(th_lp_half))
z_lp_m1(u, v) = u_norm(u)*z_lp1 + r_lp(u)*(cos(v)*sin(th_lp_half))

x_lp_m2(u, v) = r_lp(u)*sin(v)
y_lp_m2(u, v) = u_norm(u)*y_lp2 - r_lp(u)*(cos(v)*cos(th_lp_half))
z_lp_m2(u, v) = u_norm(u)*z_lp2 + r_lp(u)*(cos(v)*sin(th_lp_half))

# ----------------------------------------------------------------------------
# 4. Hydrogen Proton Screening Spheres (at x_H1 and x_H2)
# ----------------------------------------------------------------------------
r_p = 0.15
x_p1(u, v) = x_H1 + r_p*sin(u/2.0)*cos(v)
y_p1(u, v) = y_H1 + r_p*sin(u/2.0)*sin(v)
z_p1(u, v) = z_H1 + r_p*cos(u/2.0)

x_p2(u, v) = x_H2 + r_p*sin(u/2.0)*cos(v)
y_p2(u, v) = y_H2 + r_p*sin(u/2.0)*sin(v)
z_p2(u, v) = z_H2 + r_p*cos(u/2.0)

# Wireframe Line Styles
set style line 1 lc rgb "#185a9d" lw 1.5 # Deep Blue: O-H polar covalent bond pairs
set style line 2 lc rgb "#d35400" lw 1.3 # Orange: Oxygen 2p lone pairs
set style line 3 lc rgb "#c0392b" lw 1.6 # Red: Oxygen 1s^2 core toroid
set style line 4 lc rgb "#27ae60" lw 1.4 # Green: Hydrogen protons

# Key / Legend Configuration
set key top right spacing 1.25 font "Sans,9.5"

# In-Graph Annotations
set label 1 "Oxygen Nucleus (Z=8)" at 0, 0, -0.35 center font "Sans-Bold,10" tc rgb "#c0392b"
set label 2 "Proton H_1^+" at x_H1, y_H1, z_H1+0.28 center font "Sans-Bold,10" tc rgb "#27ae60"
set label 3 "Proton H_2^+" at x_H2, y_H2, z_H2+0.28 center font "Sans-Bold,10" tc rgb "#27ae60"
set label 4 "Bond Angle: 104.5^\\circ" at 0, 0, 1.95 center font "Sans,9" tc rgb "#555555"

# 3D Parametric Wireframe Splot
splot x_b1(u, v),    y_b1(u, v),    z_b1(u, v)    with lines ls 1 title "O-H Polar Covalent Bond Tubes (2x)", \
      x_b2(u, v),    y_b2(u, v),    z_b2(u, v)    with lines ls 1 notitle, \
      x_lp_m1(u, v), y_lp_m1(u, v), z_lp_m1(u, v) with lines ls 2 title "Oxygen 2p Lone-Pair Lobes (2x)", \
      x_lp_m2(u, v), y_lp_m2(u, v), z_lp_m2(u, v) with lines ls 2 notitle, \
      x_O_core(u, v),y_O_core(u, v),z_O_core(u, v)with lines ls 3 title "Oxygen 1s^2 Core Toroid", \
      x_p1(u, v),    y_p1(u, v),    z_p1(u, v)    with lines ls 4 title "Hydrogen Protons (H_1^+, H_2^+)", \
      x_p2(u, v),    y_p2(u, v),    z_p2(u, v)    with lines ls 4 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
