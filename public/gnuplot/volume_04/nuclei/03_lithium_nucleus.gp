# Gnuplot: 3D High-Detail Wireframe Snapshot of Lithium-6 Nucleus
# Depicts the discrete electromagnetic architecture of the 6Li nucleus on G_N:
# - A central, tightly bound Helium-4 alpha core toroid (coaxial dual-vortex)
# - An external equatorial deuteron (p-n) toroidal vortex orbiting the core in the XY-plane
# - Poloidal magnetic flux bridges anchoring the deuteron to the alpha kernel
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Nuclear Structure Snapshot: Lithium-6 (^6Li, Z=3, A=6)\n{/*0.85Helium-4 Core Toroid with Peripheral Deuteron Vortex on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 44, 44
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X (fm)" offset -1,-0.5
set ylabel "Y (fm)" offset 1,-0.5
set zlabel "Z (fm)" offset 1,0
set xrange [-2.8:2.8]
set yrange [-2.8:2.8]
set zrange [-2.2:2.2]
set xyplane at -2.2
set view 65, 335, 1.2, 1.0

# 1. Central Helium-4 Core (Alpha Toroid)
R_alpha = 0.75
r_alpha = 0.28
z_alpha = 0.35

x_a_top(u, v) = (R_alpha + r_alpha * cos(v)) * cos(u)
y_a_top(u, v) = (R_alpha + r_alpha * cos(v)) * sin(u)
z_a_top(u, v) =  z_alpha + r_alpha * sin(v)

x_a_bot(u, v) = (R_alpha + r_alpha * cos(v)) * cos(u)
y_a_bot(u, v) = (R_alpha + r_alpha * cos(v)) * sin(u)
z_a_bot(u, v) = -z_alpha + r_alpha * sin(v)

# 2. Peripheral Deuteron Toroidal Vortex (Valence p-n pair at R_d = 1.75 fm)
R_d_center = 1.75
R_d_maj = 0.45
r_d_min = 0.20

# Valence Deuteron Toroid centered on X-axis at (R_d_center, 0, 0)
x_deut(u, v) = R_d_center + (R_d_maj + r_d_min * cos(v)) * cos(u)
y_deut(u, v) = (R_d_maj + r_d_min * cos(v)) * sin(u)
z_deut(u, v) = r_d_min * sin(v)

# 3. 1D Deuteron Orbital Equilibrium Ring on G_N
set samples 120
set table $ORBIT_TRACK
plot [t=0:2*pi] R_d_center * cos(t), R_d_center * sin(t)
unset table

# 4. 1D Magnetic Flux Bridges between Core and Deuteron
set samples 80
set table $BRIDGE_TOP
plot [t=0:1] (R_alpha + (R_d_center - R_d_maj - R_alpha) * t), (0.28 * sin(t * pi))
unset table

# Wireframe Line Styles
set style line 1 lc rgb "#c0392b" lw 1.5              # Crimson: Core alpha toroids
set style line 2 lc rgb "#185a9d" lw 1.5              # Blue: Peripheral deuteron toroid
set style line 3 lc rgb "#444444" dt (18, 12) lw 1.8   # Distinct Dashed Dark Gray: Deuteron orbital guide ring
set style line 4 lc rgb "#e67e22" lw 1.6              # Amber: Inter-vortex magnetic flux bridge

set label 1 "Alpha Kernel (^4He)" at 0, 0, 0.95 center font "Sans-Bold,9.5" tc rgb "#c0392b"
set label 2 "Valence Deuteron (p-n)" at R_d_center, 0, 0.75 center font "Sans-Bold,9.5" tc rgb "#185a9d"
set label 3 "Magnetic Flux Bridge" at 1.15, -0.4, 0.35 center font "Sans,8.5" tc rgb "#e67e22"
set label 4 "Deuteron Orbit Track (G_N)" at -1.8, 0, -0.25 center font "Sans-Bold,8.5" tc rgb "#444444"

splot x_a_top(u, v),   y_a_top(u, v),   z_a_top(u, v)   with lines ls 1 title "Helium-4 Core Upper Toroid", \
      x_a_bot(u, v),   y_a_bot(u, v),   z_a_bot(u, v)   with lines ls 1 title "Helium-4 Core Lower Toroid", \
      x_deut(u, v),    y_deut(u, v),    z_deut(u, v)    with lines ls 2 title "Peripheral Deuteron Vortex (p-n)", \
      $ORBIT_TRACK using 1:2:(0.0) with lines ls 3 title "Valence Deuteron Orbit Track", \
      $BRIDGE_TOP  using 1:(0.0):2 with lines ls 4 title "Inter-Vortex Magnetic Flux Bridge", \
      $BRIDGE_TOP  using 1:(0.0):(-$2) with lines ls 4 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
