# Gnuplot: 3D High-Detail Wireframe Snapshot of Neon-20 Nucleus
# Depicts the discrete electromagnetic architecture of the 20Ne nucleus on G_N:
# - Five Helium-4 alpha core toroids arranged in a trigonal bipyramid (D3h point group)
# - Three equatorial alphas in a triangular plane with two polar locking alphas (+Z and -Z)
# - Closed-shell magnetic flux cage achieving ground state spin J=0+ and zero dipole moment
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
set xrange [-3.2:3.2]
set yrange [-3.2:3.2]
set zrange [-3.2:3.2]
set xyplane at -3.2
set view 64, 45, 1.25, 1.0

# 1. Three Equatorial Alpha Toroids in XY-Plane (R_eq = 1.65 fm, 120 deg apart)
R_eq = 1.65
R_a  = 0.58
r_a  = 0.20

x_eq1(u, v) = R_eq + (R_a + r_a * cos(v)) * cos(u)
y_eq1(u, v) = (R_a + r_a * cos(v)) * sin(u)
z_eq1(u, v) = r_a * sin(v)

phi_2 = 2.0 * pi / 3.0
x_rot2(x, y) = x * cos(phi_2) - y * sin(phi_2)
y_rot2(x, y) = x * sin(phi_2) + y * cos(phi_2)
x_eq2(u, v) = x_rot2(x_eq1(u, v), y_eq1(u, v))
y_eq2(u, v) = y_rot2(x_eq1(u, v), y_eq1(u, v))
z_eq2(u, v) = r_a * sin(v)

phi_3 = 4.0 * pi / 3.0
x_rot3(x, y) = x * cos(phi_3) - y * sin(phi_3)
y_rot3(x, y) = x * sin(phi_3) + y * cos(phi_3)
x_eq3(u, v) = x_rot3(x_eq1(u, v), y_eq1(u, v))
y_eq3(u, v) = y_rot3(x_eq1(u, v), y_eq1(u, v))
z_eq3(u, v) = r_a * sin(v)

# 2. Two Polar Locking Alpha Toroids (+Z and -Z, Z = +/- 1.45 fm)
z_pol = 1.45
R_pol = 0.62
r_pol = 0.20

x_pol_top(u, v) = (R_pol + r_pol * cos(v)) * cos(u)
y_pol_top(u, v) = (R_pol + r_pol * cos(v)) * sin(u)
z_pol_top(u, v) =  z_pol + r_pol * sin(v)

x_pol_bot(u, v) = (R_pol + r_pol * cos(v)) * cos(u)
y_pol_bot(u, v) = (R_pol + r_pol * cos(v)) * sin(u)
z_pol_bot(u, v) = -z_pol + r_pol * sin(v)

# 3. 1D Equatorial Confinement Guide Ring on G_N
set samples 120
set table $NEON_RING
plot [t=0:2*pi] 2.55 * cos(t), 2.55 * sin(t)
unset table

# Wireframe Line Styles
set style line 1 lc rgb "#c0392b" lw 1.4              # Crimson: Equatorial Alpha 1
set style line 2 lc rgb "#185a9d" lw 1.4              # Blue: Equatorial Alpha 2
set style line 3 lc rgb "#27ae60" lw 1.4              # Green: Equatorial Alpha 3
set style line 4 lc rgb "#8e44ad" lw 1.6              # Purple: North Polar Alpha (+Z)
set style line 5 lc rgb "#d35400" lw 1.6              # Amber: South Polar Alpha (-Z)
set style line 6 lc rgb "#444444" dt (18, 12) lw 1.8   # Distinct Dashed Dark Gray: Equatorial guide ring

set label 1 "Equatorial \\alpha_1" at R_eq+0.3, 0, -0.45 center font "Sans-Bold,8.5" tc rgb "#c0392b"
set label 2 "Equatorial \\alpha_2" at -0.9, 1.6, -0.45 center font "Sans-Bold,8.5" tc rgb "#185a9d"
set label 3 "Equatorial \\alpha_3" at -0.9, -1.6, -0.45 center font "Sans-Bold,8.5" tc rgb "#27ae60"
set label 4 "North Polar \\alpha (+Z)" at 0, 0, z_pol+0.55 center font "Sans-Bold,9" tc rgb "#8e44ad"
set label 5 "South Polar \\alpha (-Z)" at 0, 0, -z_pol-0.55 center font "Sans-Bold,9" tc rgb "#d35400"
set label 6 "Equatorial Confinement Belt (G_N)" at 2.6, 0, -0.25 center font "Sans-Bold,8.5" tc rgb "#444444"

splot x_eq1(u, v),     y_eq1(u, v),     z_eq1(u, v)     with lines ls 1 title "Equatorial Alpha 1", \
      x_eq2(u, v),     y_eq2(u, v),     z_eq2(u, v)     with lines ls 2 title "Equatorial Alpha 2", \
      x_eq3(u, v),     y_eq3(u, v),     z_eq3(u, v)     with lines ls 3 title "Equatorial Alpha 3", \
      x_pol_top(u, v), y_pol_top(u, v), z_pol_top(u, v) with lines ls 4 title "North Polar Alpha (+Z)", \
      x_pol_bot(u, v), y_pol_bot(u, v), z_pol_bot(u, v) with lines ls 5 title "South Polar Alpha (-Z)", \
      $NEON_RING using 1:2:(0.0) with lines ls 6 title "Equatorial Confinement Belt"

if (!exists("OUTFILE")) {
    pause mouse close
}
