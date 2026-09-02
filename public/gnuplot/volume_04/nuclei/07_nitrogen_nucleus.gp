# Gnuplot: 3D High-Detail Wireframe Snapshot of Nitrogen-14 Nucleus
# Depicts the discrete electromagnetic architecture of the 14N nucleus on G_N:
# - A planar triangular Carbon-12 3-alpha core scaffold in the XY-plane
# - An axial valence deuteron (p-n) toroidal vortex positioned along the central Z-axis
# - Axial magnetic coupling generating spin J=1 and non-zero electric quadrupole moment
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Nuclear Structure Snapshot: Nitrogen-14 (^14N, Z=7, A=14)\n{/*0.85Triangular 3-Alpha Core with Axial Deuteron Toroid on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 44, 44
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X (fm)" offset -1,-0.5
set ylabel "Y (fm)" offset 1,-0.5
set zlabel "Z: Axial Vector (fm)" offset 1,0
set xrange [-3.2:3.2]
set yrange [-3.2:3.2]
set zrange [-2.6:2.6]
set xyplane at -2.6
set view 64, 335, 1.25, 1.0

# 1. Three Alpha Clusters in XY-Plane (R_tri = 1.60 fm)
R_tri = 1.60
R_a   = 0.62
r_a   = 0.22

x_a1(u, v) = R_tri + (R_a + r_a * cos(v)) * cos(u)
y_a1(u, v) = (R_a + r_a * cos(v)) * sin(u)
z_a1(u, v) = r_a * sin(v)

phi_2 = 2.0 * pi / 3.0
x_rot2(x, y) = x * cos(phi_2) - y * sin(phi_2)
y_rot2(x, y) = x * sin(phi_2) + y * cos(phi_2)
x_a2(u, v) = x_rot2(x_a1(u, v), y_a1(u, v))
y_a2(u, v) = y_rot2(x_a1(u, v), y_a1(u, v))
z_a2(u, v) = r_a * sin(v)

phi_3 = 4.0 * pi / 3.0
x_rot3(x, y) = x * cos(phi_3) - y * sin(phi_3)
y_rot3(x, y) = x * sin(phi_3) + y * cos(phi_3)
x_a3(u, v) = x_rot3(x_a1(u, v), y_a1(u, v))
y_a3(u, v) = y_rot3(x_a1(u, v), y_a1(u, v))
z_a3(u, v) = r_a * sin(v)

# 2. Axial Valence Deuteron Toroid at +Z (+1.35 fm)
R_d_axial = 0.55
r_d_axial = 0.20
z_d_pos   = 1.35

x_deut_ax(u, v) = (R_d_axial + r_d_axial * cos(v)) * cos(u)
y_deut_ax(u, v) = (R_d_axial + r_d_axial * cos(v)) * sin(u)
z_deut_ax(u, v) = z_d_pos + r_d_axial * sin(v)

# 3. 1D Axial Magnetic Flux Filaments connecting Deuteron to 3-Alpha Core
set samples 80
set table $AX_F1
plot [t=0:1] (R_tri * (1.0 - t)), (z_d_pos * t)
unset table

# Rotated filaments for alpha 2 and alpha 3
set table $AX_F2
plot [t=0:1] (R_tri * (1.0 - t) * cos(phi_2)), (R_tri * (1.0 - t) * sin(phi_2))
unset table

set table $AX_F3
plot [t=0:1] (R_tri * (1.0 - t) * cos(phi_3)), (R_tri * (1.0 - t) * sin(phi_3))
unset table

# Wireframe Line Styles
set style line 1 lc rgb "#c0392b" lw 1.5              # Crimson: Core Alpha 1
set style line 2 lc rgb "#185a9d" lw 1.5              # Blue: Core Alpha 2
set style line 3 lc rgb "#27ae60" lw 1.5              # Green: Core Alpha 3
set style line 4 lc rgb "#e67e22" lw 1.6              # Amber: Axial Deuteron Toroid (p_7-n_7)
set style line 5 lc rgb "#8e44ad" dt (18, 12) lw 1.8   # Distinct Dashed Purple: Axial Magnetic Couplers

set label 1 "\\alpha_1 Cluster" at R_tri+0.4, 0, -0.45 center font "Sans-Bold,9" tc rgb "#c0392b"
set label 2 "\\alpha_2 Cluster" at -0.9, 1.6, -0.45 center font "Sans-Bold,9" tc rgb "#185a9d"
set label 3 "\\alpha_3 Cluster" at -0.9, -1.6, -0.45 center font "Sans-Bold,9" tc rgb "#27ae60"
set label 4 "Axial Deuteron (p_7-n_7)" at 0, 0, z_d_pos+0.55 center font "Sans-Bold,9.5" tc rgb "#e67e22"
set label 5 "Tri-Vortex Axial Coupler" at 0.7, 0.7, 0.7 center font "Sans-Bold,8.5" tc rgb "#8e44ad"

splot x_a1(u, v),      y_a1(u, v),      z_a1(u, v)      with lines ls 1 title "12C Core Alpha Toroid 1", \
      x_a2(u, v),      y_a2(u, v),      z_a2(u, v)      with lines ls 2 title "12C Core Alpha Toroid 2", \
      x_a3(u, v),      y_a3(u, v),      z_a3(u, v)      with lines ls 3 title "12C Core Alpha Toroid 3", \
      x_deut_ax(u, v), y_deut_ax(u, v), z_deut_ax(u, v) with lines ls 4 title "Axial Valence Deuteron Toroid (p-n)", \
      $AX_F1 using 1:(0.0):2 with lines ls 5 title "Tri-Vortex Axial Coupling Filaments", \
      $AX_F2 using 1:2:((sqrt($1*$1+$2*$2) == 0) ? z_d_pos : (z_d_pos * (1.0 - sqrt($1*$1+$2*$2)/R_tri))) with lines ls 5 notitle, \
      $AX_F3 using 1:2:((sqrt($1*$1+$2*$2) == 0) ? z_d_pos : (z_d_pos * (1.0 - sqrt($1*$1+$2*$2)/R_tri))) with lines ls 5 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
