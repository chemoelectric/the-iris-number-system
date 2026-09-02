# Gnuplot: 3D High-Detail Wireframe Snapshot of Neon-20 Nucleus (5-Alpha Bipyramid)
# Depicts the discrete electromagnetic architecture of the 20Ne nucleus on G_N:
# - Five Helium-4 alpha core toroids arranged in a trigonal bipyramid (D3h point group)
# - Three equatorial alpha clusters at 120 deg and two polar alpha clusters along the +/- Z axis
# - Exceptionally symmetrical closed magnetic plasmoid with zero ground state spin and parity J=0+
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Nuclear Structure Snapshot: Neon-20 (^20Ne, Z=10, A=20)\n{/*0.85Trigonal Bipyramidal 5-Alpha Toroidal Cluster on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 44, 44
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X (fm)" offset -1,-0.5
set ylabel "Y (fm)" offset 1,-0.5
set zlabel "Z: Principal Axis (fm)" offset 1,0
set xrange [-3.4:3.4]
set yrange [-3.4:3.4]
set zrange [-3.4:3.4]
set xyplane at -3.4
set view 64, 335, 1.25, 1.0

# 1. Three Equatorial Alpha Toroids (R_eq = 1.75 fm at 120 deg in XY-plane)
R_eq = 1.75
R_a  = 0.58
r_a  = 0.20

# Equatorial Alpha 1: phi = 0 deg
x_eq1(u, v) = R_eq + (R_a + r_a * cos(v)) * cos(u)
y_eq1(u, v) = (R_a + r_a * cos(v)) * sin(u)
z_eq1(u, v) = r_a * sin(v)

# Equatorial Alpha 2: phi = 120 deg
phi_2 = 2.0 * pi / 3.0
x_rot2(x, y) = x * cos(phi_2) - y * sin(phi_2)
y_rot2(x, y) = x * sin(phi_2) + y * cos(phi_2)
x_eq2(u, v) = x_rot2(x_eq1(u, v), y_eq1(u, v))
y_eq2(u, v) = y_rot2(x_eq1(u, v), y_eq1(u, v))
z_eq2(u, v) = r_a * sin(v)

# Equatorial Alpha 3: phi = 240 deg
phi_3 = 4.0 * pi / 3.0
x_rot3(x, y) = x * cos(phi_3) - y * sin(phi_3)
y_rot3(x, y) = x * sin(phi_3) + y * cos(phi_3)
x_eq3(u, v) = x_rot3(x_eq1(u, v), y_eq1(u, v))
y_eq3(u, v) = y_rot3(x_eq1(u, v), y_eq1(u, v))
z_eq3(u, v) = r_a * sin(v)

# 2. Two Polar Alpha Toroids (+Z and -Z at Z_pol = +/- 1.80 fm)
z_pol = 1.80
x_pol_top(u, v) = (R_a + r_a * cos(v)) * cos(u)
y_pol_top(u, v) = (R_a + r_a * cos(v)) * sin(u)
z_pol_top(u, v) =  z_pol + r_a * sin(v)

x_pol_bot(u, v) = (R_a + r_a * cos(v)) * cos(u)
y_pol_bot(u, v) = (R_a + r_a * cos(v)) * sin(u)
z_pol_bot(u, v) = -z_pol + r_a * sin(v)

# 3. Equatorial Trigonal Confinement Ring
R_eq_ring = 2.65
r_ring_tube = 0.03
x_ring(u, v) = (R_eq_ring + r_ring_tube * cos(v)) * cos(u)
y_ring(u, v) = (R_eq_ring + r_ring_tube * cos(v)) * sin(u)
z_ring(u, v) = r_ring_tube * sin(v)

# Wireframe Line Styles
set style line 1 lc rgb "#c0392b" lw 1.5   # Crimson: Equatorial Alpha 1
set style line 2 lc rgb "#185a9d" lw 1.5   # Blue: Equatorial Alpha 2
set style line 3 lc rgb "#27ae60" lw 1.5   # Green: Equatorial Alpha 3
set style line 4 lc rgb "#8e44ad" lw 1.6   # Purple: North Polar Alpha (+Z)
set style line 5 lc rgb "#d35400" lw 1.6   # Orange: South Polar Alpha (-Z)
set style line 6 lc rgb "#7f8c8d" dt 2 lw 0.9 # Dashed gray: Equatorial guide

set label 1 "Equatorial \\alpha_1" at R_eq+0.4, 0, 0.55 center font "Sans-Bold,9" tc rgb "#c0392b"
set label 2 "North Pole \\alpha"   at 0, 0, z_pol+0.65 center font "Sans-Bold,9.5" tc rgb "#8e44ad"
set label 3 "South Pole \\alpha"   at 0, 0, -z_pol-0.65 center font "Sans-Bold,9.5" tc rgb "#d35400"

splot x_eq1(u, v),     y_eq1(u, v),     z_eq1(u, v)     with lines ls 1 title "Equatorial Alpha Toroid 1 (XY)", \
      x_eq2(u, v),     y_eq2(u, v),     z_eq2(u, v)     with lines ls 2 title "Equatorial Alpha Toroid 2 (XY)", \
      x_eq3(u, v),     y_eq3(u, v),     z_eq3(u, v)     with lines ls 3 title "Equatorial Alpha Toroid 3 (XY)", \
      x_pol_top(u, v), y_pol_top(u, v), z_pol_top(u, v) with lines ls 4 title "North Polar Alpha Toroid (+Z)", \
      x_pol_bot(u, v), y_pol_bot(u, v), z_pol_bot(u, v) with lines ls 5 title "South Polar Alpha Toroid (-Z)", \
      x_ring(u, v),    y_ring(u, v),    z_ring(u, v)    with lines ls 6 title "Equatorial Confinement Belt"

if (!exists("OUTFILE")) {
    pause mouse close
}
