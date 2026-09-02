# Gnuplot: 3D High-Detail Wireframe Snapshot of Boron-11 Nucleus
# Depicts the discrete electromagnetic architecture of the 11B nucleus on G_N:
# - Two coaxial Helium-4 alpha core toroids forming a dumbbell scaffold
# - A planar triangular cluster of three valence nucleons (1 proton, 2 neutrons) at the equatorial waist
# - Triangular symmetry and strong quadrupole moment deformation
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Nuclear Structure Snapshot: Boron-11 (^11B, Z=5, A=11)\n{/*0.85Dual Alpha Core with Trigonal Waist Nucleon Vortex on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 44, 44
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X (fm)" offset -1,-0.5
set ylabel "Y (fm)" offset 1,-0.5
set zlabel "Z: Nuclear Axis (fm)" offset 1,0
set xrange [-2.8:2.8]
set yrange [-2.8:2.8]
set zrange [-3.0:3.0]
set xyplane at -3.0
set view 65, 45, 1.2, 1.0

# 1. Dual Alpha Clusters (+Z and -Z)
R_a = 0.78
r_a = 0.26
z_a = 1.30

x_a1(u, v) = (R_a + r_a * cos(v)) * cos(u)
y_a1(u, v) = (R_a + r_a * cos(v)) * sin(u)
z_a1(u, v) =  z_a + r_a * sin(v)

x_a2(u, v) = (R_a + r_a * cos(v)) * cos(u)
y_a2(u, v) = (R_a + r_a * cos(v)) * sin(u)
z_a2(u, v) = -z_a + r_a * sin(v)

# 2. Trigonal Waist Nucleon Lobes (1 Proton, 2 Neutrons at 120 deg in XY-plane)
R_w_center = 1.35
R_w_maj    = 0.38
r_w_min    = 0.16

# Lobe 1: Proton vortex at phi = 0 deg
x_w1(u, v) = R_w_center + (R_w_maj + r_w_min * cos(v)) * cos(u)
y_w1(u, v) = (R_w_maj + r_w_min * cos(v)) * sin(u)
z_w1(u, v) = r_w_min * sin(v)

# Lobe 2: Neutron vortex at phi = 120 deg
phi_2 = 2.0 * pi / 3.0
x_rot2(x, y) = x * cos(phi_2) - y * sin(phi_2)
y_rot2(x, y) = x * sin(phi_2) + y * cos(phi_2)
x_w2_base(u, v) = R_w_center + (R_w_maj + r_w_min * cos(v)) * cos(u)
y_w2_base(u, v) = (R_w_maj + r_w_min * cos(v)) * sin(u)
x_w2(u, v) = x_rot2(x_w2_base(u, v), y_w2_base(u, v))
y_w2(u, v) = y_rot2(x_w2_base(u, v), y_w2_base(u, v))
z_w2(u, v) = r_w_min * sin(v)

# Lobe 3: Neutron vortex at phi = 240 deg
phi_3 = 4.0 * pi / 3.0
x_rot3(x, y) = x * cos(phi_3) - y * sin(phi_3)
y_rot3(x, y) = x * sin(phi_3) + y * cos(phi_3)
x_w3(u, v) = x_rot3(x_w2_base(u, v), y_w2_base(u, v))
y_w3(u, v) = y_rot3(x_w2_base(u, v), y_w2_base(u, v))
z_w3(u, v) = r_w_min * sin(v)

# 3. 1D Trigonal Magnetic Flux Guide Ring on G_N
set samples 120
set table $TRI_RING
plot [t=0:2*pi] 1.75 * cos(t), 1.75 * sin(t)
unset table

# Wireframe Line Styles
set style line 1 lc rgb "#8b0000" lw 1.5              # Crimson: Upper Alpha
set style line 2 lc rgb "#4a0e4e" lw 1.5              # Purple: Lower Alpha
set style line 3 lc rgb "#6d2800" lw 1.5              # Amber: Valence Proton Toroid (p_5)
set style line 4 lc rgb "#0a369d" lw 1.4              # Blue: Valence Neutron Toroids (n_5, n_6)
set style line 5 lc rgb "#111111" dt (18, 12) lw 1.8   # Distinct Dashed Dark Gray: Equatorial guide ring

set label 1 "Upper \\alpha-Core" at 0, 0, 1.9 center font "Sans-Bold,9.5" tc rgb "#8b0000"
set label 2 "Lower \\alpha-Core" at 0, 0, -1.9 center font "Sans-Bold,9.5" tc rgb "#4a0e4e"
set label 3 "Valence Proton (p_5)" at R_w_center+0.4, 0, 0.55 center font "Sans-Bold,9" tc rgb "#6d2800"
set label 4 "Trigonal Neutrons (2n)" at -1.1, 1.1, 0.55 center font "Sans-Bold,9" tc rgb "#0a369d"
set label 5 "Equatorial Guide Ring (G_N)" at -1.8, 0, -0.25 center font "Sans-Bold,8.5" tc rgb "#111111"

splot x_a1(u, v),       y_a1(u, v),       z_a1(u, v)       with lines ls 1 title "Upper Alpha Core (^4He)", \
      x_a2(u, v),       y_a2(u, v),       z_a2(u, v)       with lines ls 2 title "Lower Alpha Core (^4He)", \
      x_w1(u, v),       y_w1(u, v),       z_w1(u, v)       with lines ls 3 title "Valence Proton Toroid (p)", \
      x_w2(u, v),       y_w2(u, v),       z_w2(u, v)       with lines ls 4 title "Valence Neutron Toroid 1 (n)", \
      x_w3(u, v),       y_w3(u, v),       z_w3(u, v)       with lines ls 4 title "Valence Neutron Toroid 2 (n)", \
      $TRI_RING using 1:2:(0.0) with lines ls 5 title "Equatorial Trigonal Guide Ring"

if (!exists("OUTFILE")) {
    pause mouse close
}
