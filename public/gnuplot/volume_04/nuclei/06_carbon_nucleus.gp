# Gnuplot: 3D High-Detail Wireframe Snapshot of Carbon-12 Nucleus (Hoyle State Scaffold)
# Depicts the discrete electromagnetic architecture of the 12C nucleus on G_N:
# - Three Helium-4 alpha core toroids arranged in an equilateral triangular ring (planar D3h cluster)
# - Interlocking magnetic flux recirculation funnels linking the three vortex vertices
# - Ground state and Hoyle state resonant geometry on the discrete grid G_N
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Nuclear Structure Snapshot: Carbon-12 (^12C, Z=6, A=12)\n{/*0.85Triangular 3-Alpha Toroidal Resonant Cluster on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

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
set xrange [-3.2:3.2]
set yrange [-3.2:3.2]
set zrange [-2.2:2.2]
set xyplane at -2.2
set view 62, 335, 1.25, 1.0

# Three Alpha Toroids at Equilateral Triangle Vertices (R_tri = 1.65 fm from origin)
R_tri = 1.65
R_a   = 0.65
r_a   = 0.24

# Alpha 1: Vertex at (R_tri, 0, 0)
x_a1(u, v) = R_tri + (R_a + r_a * cos(v)) * cos(u)
y_a1(u, v) = (R_a + r_a * cos(v)) * sin(u)
z_a1(u, v) = r_a * sin(v)

# Alpha 2: Vertex at phi = 120 deg
phi_2 = 2.0 * pi / 3.0
x_rot2(x, y) = x * cos(phi_2) - y * sin(phi_2)
y_rot2(x, y) = x * sin(phi_2) + y * cos(phi_2)
x_a2(u, v) = x_rot2(x_a1(u, v), y_a1(u, v))
y_a2(u, v) = y_rot2(x_a1(u, v), y_a1(u, v))
z_a2(u, v) = r_a * sin(v)

# Alpha 3: Vertex at phi = 240 deg
phi_3 = 4.0 * pi / 3.0
x_rot3(x, y) = x * cos(phi_3) - y * sin(phi_3)
y_rot3(x, y) = x * sin(phi_3) + y * cos(phi_3)
x_a3(u, v) = x_rot3(x_a1(u, v), y_a1(u, v))
y_a3(u, v) = y_rot3(x_a1(u, v), y_a1(u, v))
z_a3(u, v) = r_a * sin(v)

# Central Magnetic Vortex Core (Recirculating Aperture at origin)
R_cent = 0.55
r_cent = 0.16
x_cent(u, v) = (R_cent + r_cent * cos(v)) * cos(u)
y_cent(u, v) = (R_cent + r_cent * cos(v)) * sin(u)
z_cent(u, v) = r_cent * sin(v)

# Triangular Outer Flux Boundary
R_outer = 2.45
r_out_tube = 0.03
x_out(u, v) = (R_outer + r_out_tube * cos(v)) * cos(u)
y_out(u, v) = (R_outer + r_out_tube * cos(v)) * sin(u)
z_out(u, v) = r_out_tube * sin(v)

# Wireframe Line Styles
set style line 1 lc rgb "#c0392b" lw 1.5   # Crimson: Alpha Cluster 1
set style line 2 lc rgb "#185a9d" lw 1.5   # Blue: Alpha Cluster 2
set style line 3 lc rgb "#27ae60" lw 1.5   # Green: Alpha Cluster 3
set style line 4 lc rgb "#e67e22" lw 1.3   # Amber: Central Recirculating Vortex
set style line 5 lc rgb "#7f8c8d" dt 2 lw 0.9 # Dashed gray: Outer boundary

set label 1 "\\alpha_1 Cluster" at R_tri+0.4, 0, 0.65 center font "Sans-Bold,9.5" tc rgb "#c0392b"
set label 2 "\\alpha_2 Cluster" at -0.9, 1.6, 0.65 center font "Sans-Bold,9.5" tc rgb "#185a9d"
set label 3 "\\alpha_3 Cluster" at -0.9, -1.6, 0.65 center font "Sans-Bold,9.5" tc rgb "#27ae60"
set label 4 "Central Vortex Hole" at 0, 0, -0.6 center font "Sans,9" tc rgb "#e67e22"

splot x_a1(u, v),   y_a1(u, v),   z_a1(u, v)   with lines ls 1 title "Helium-4 Alpha Toroid 1 (2p-2n)", \
      x_a2(u, v),   y_a2(u, v),   z_a2(u, v)   with lines ls 2 title "Helium-4 Alpha Toroid 2 (2p-2n)", \
      x_a3(u, v),   y_a3(u, v),   z_a3(u, v)   with lines ls 3 title "Helium-4 Alpha Toroid 3 (2p-2n)", \
      x_cent(u, v), y_cent(u, v), z_cent(u, v) with lines ls 4 title "Central Recirculating Vortex Aperture", \
      x_out(u, v),  y_out(u, v),  z_out(u, v)  with lines ls 5 title "Triangular Magnetic Outer Boundary"

if (!exists("OUTFILE")) {
    pause mouse close
}
