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

# Bonding Tubes Parameterization
u_norm(u) = u / (2.0 * pi)
r_tube(u) = 0.32 * (sin(u_norm(u)*pi)**0.75) * (1.0 + 0.20*(1.0 - u_norm(u)))

x_b1(u, v) = u_norm(u)*x_H1 + r_tube(u)*cos(v)
y_b1(u, v) = u_norm(u)*y_H1 + r_tube(u)*sin(v)
z_b1(u, v) = u_norm(u)*z_H1

x_b2(u, v) = u_norm(u)*x_H2 + r_tube(u)*cos(v)
y_b2(u, v) = u_norm(u)*y_H2 + r_tube(u)*sin(v)
z_b2(u, v) = u_norm(u)*z_H2

# Oxygen 1s^2 Core Toroid
r_O_core_maj = 0.24
r_O_core_min = 0.08
x_O_core(u, v) = (r_O_core_maj + r_O_core_min*cos(v))*cos(u)
y_O_core(u, v) = (r_O_core_maj + r_O_core_min*cos(v))*sin(u)
z_O_core(u, v) = r_O_core_min*sin(v)

# Oxygen Lone-Pair Teardrop Lobes
r_lp(u) = 0.36 * sin(u_norm(u)*pi) * (1.0 - 0.20*cos(u_norm(u)*pi))

x_lp_m1(u, v) = r_lp(u)*cos(v)
y_lp_m1(u, v) = u_norm(u)*y_lp1 + r_lp(u)*sin(v)
z_lp_m1(u, v) = u_norm(u)*z_lp1

x_lp_m2(u, v) = r_lp(u)*cos(v)
y_lp_m2(u, v) = u_norm(u)*y_lp2 + r_lp(u)*sin(v)
z_lp_m2(u, v) = u_norm(u)*z_lp2

# Hydrogen Proton Screening Spheres
r_p = 0.14
x_p1(u, v) = x_H1 + r_p*sin(u/2.0)*cos(v)
y_p1(u, v) = y_H1 + r_p*sin(u/2.0)*sin(v)
z_p1(u, v) = z_H1 + r_p*cos(u/2.0)

x_p2(u, v) = x_H2 + r_p*sin(u/2.0)*cos(v)
y_p2(u, v) = y_H2 + r_p*sin(u/2.0)*sin(v)
z_p2(u, v) = z_H2 + r_p*cos(u/2.0)

# Wireframe Styles
set style line 1 lc rgb "#185a9d" lw 1.3 # Blue: O-H bond pairs
set style line 2 lc rgb "#d35400" lw 1.1 # Orange: Oxygen lone pairs
set style line 3 lc rgb "#c0392b" lw 1.4 # Red: Oxygen core toroid
set style line 4 lc rgb "#27ae60" lw 1.2 # Green: Hydrogen protons

set label 1 "Oxygen Nucleus (Z=8)" at 0, 0, -0.32 center font "Sans-Bold,10" tc rgb "#c0392b"
set label 2 "Proton H_1^+" at x_H1, y_H1, z_H1+0.25 center font "Sans-Bold,10" tc rgb "#27ae60"
set label 3 "Proton H_2^+" at x_H2, y_H2, z_H2+0.25 center font "Sans-Bold,10" tc rgb "#27ae60"

splot x_b1(u, v),    y_b1(u, v),    z_b1(u, v)    with lines ls 1 title "O-H Bonding Pair 1", \
      x_b2(u, v),    y_b2(u, v),    z_b2(u, v)    with lines ls 1 title "O-H Bonding Pair 2", \
      x_lp_m1(u, v), y_lp_m1(u, v), z_lp_m1(u, v) with lines ls 2 title "Oxygen Lone Pair 1", \
      x_lp_m2(u, v), y_lp_m2(u, v), z_lp_m2(u, v) with lines ls 2 title "Oxygen Lone Pair 2", \
      x_O_core(u, v),y_O_core(u, v),z_O_core(u, v)with lines ls 3 title "Oxygen 1s^2 Core Toroid", \
      x_p1(u, v),    y_p1(u, v),    z_p1(u, v)    with lines ls 4 notitle, \
      x_p2(u, v),    y_p2(u, v),    z_p2(u, v)    with lines ls 4 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
