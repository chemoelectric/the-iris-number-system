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

# 3. Deuteron Orbital Equilibrium Ring on G_N
r_orbit_tube = 0.03
x_orbit(u, v) = (R_d_center + r_orbit_tube * cos(v)) * cos(u)
y_orbit(u, v) = (R_d_center + r_orbit_tube * cos(v)) * sin(u)
z_orbit(u, v) = r_orbit_tube * sin(v)

# 4. Magnetic Flux Bridges between Core and Deuteron
u_n(u) = u / (2.0 * pi)
x_bridge1(u, v) = (R_alpha + (R_d_center - R_d_maj - R_alpha) * u_n(u)) * cos(0.0)
y_bridge1(u, v) = 0.25 * sin(u_n(u) * pi) * cos(v)
z_bridge1(u, v) = 0.25 * sin(u_n(u) * pi) * sin(v)

x_bridge2(u, v) = (R_alpha + (R_d_center - R_d_maj - R_alpha) * u_n(u)) * cos(0.0)
y_bridge2(u, v) = -0.25 * sin(u_n(u) * pi) * cos(v)
z_bridge2(u, v) = -0.25 * sin(u_n(u) * pi) * sin(v)

# Wireframe Line Styles
set style line 1 lc rgb "#c0392b" lw 1.5   # Crimson: Core alpha toroids
set style line 2 lc rgb "#185a9d" lw 1.5   # Blue: Peripheral deuteron toroid
set style line 3 lc rgb "#7f8c8d" dt 2 lw 0.9 # Dashed gray: Deuteron orbital guide ring
set style line 4 lc rgb "#e67e22" lw 1.2   # Amber: Inter-vortex magnetic flux bridge

set label 1 "Alpha Kernel (^4He)" at 0, 0, 0.95 center font "Sans-Bold,9.5" tc rgb "#c0392b"
set label 2 "Valence Deuteron (p-n)" at R_d_center, 0, 0.75 center font "Sans-Bold,9.5" tc rgb "#185a9d"
set label 3 "Magnetic Flux Bridge" at 1.15, -0.4, 0.35 center font "Sans,8.5" tc rgb "#e67e22"

splot x_a_top(u, v),   y_a_top(u, v),   z_a_top(u, v)   with lines ls 1 title "Helium-4 Core Upper Toroid", \
      x_a_bot(u, v),   y_a_bot(u, v),   z_a_bot(u, v)   with lines ls 1 title "Helium-4 Core Lower Toroid", \
      x_deut(u, v),    y_deut(u, v),    z_deut(u, v)    with lines ls 2 title "Peripheral Deuteron Vortex (p-n)", \
      x_orbit(u, v),   y_orbit(u, v),   z_orbit(u, v)   with lines ls 3 title "Valence Deuteron Orbit Track", \
      x_bridge1(u, v), y_bridge1(u, v), z_bridge1(u, v) with lines ls 4 title "Inter-Vortex Magnetic Flux Bridge", \
      x_bridge2(u, v), y_bridge2(u, v), z_bridge2(u, v) with lines ls 4 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
