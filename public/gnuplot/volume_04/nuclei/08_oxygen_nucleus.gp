# Gnuplot: 3D High-Detail Wireframe Snapshot of Oxygen-16 Nucleus (Doubly Magic Kernel)
# Depicts the discrete electromagnetic architecture of the 16O nucleus on G_N:
# - Four Helium-4 alpha core toroids arranged at the vertices of a regular tetrahedron (Td point group)
# - Closed tetrahedral magnetic flux cages enforcing complete, isotropic scalar/bivector cancellation
# - The exceptionally stable "doubly magic" 4-alpha tetrahedral plasmoid architecture
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Nuclear Structure Snapshot: Oxygen-16 (^16O Doubly Magic Kernel, Z=8, A=16)\n{/*0.85Regular Tetrahedral 4-Alpha Toroidal Cluster on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

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
set xrange [-3.0:3.0]
set yrange [-3.0:3.0]
set zrange [-3.0:3.0]
set xyplane at -3.0
set view 60, 45, 1.25, 1.0

# Tetrahedral Vertices for 4 Alpha Clusters (d_tet = 1.65 fm from origin)
d_t = 1.65 / sqrt(3.0)
R_a = 0.58
r_a = 0.20

# Alpha 1: (+d_t, +d_t, +d_t)
x_a1(u, v) =  d_t + (R_a + r_a * cos(v)) * cos(u)
y_a1(u, v) =  d_t + (R_a + r_a * cos(v)) * sin(u)
z_a1(u, v) =  d_t + r_a * sin(v)

# Alpha 2: (+d_t, -d_t, -d_t)
x_a2(u, v) =  d_t + (R_a + r_a * cos(v)) * cos(u)
y_a2(u, v) = -d_t + (R_a + r_a * cos(v)) * sin(u)
z_a2(u, v) = -d_t + r_a * sin(v)

# Alpha 3: (-d_t, +d_t, -d_t)
x_a3(u, v) = -d_t + (R_a + r_a * cos(v)) * cos(u)
y_a3(u, v) =  d_t + (R_a + r_a * cos(v)) * sin(u)
z_a3(u, v) = -d_t + r_a * sin(v)

# Alpha 4: (-d_t, -d_t, +d_t)
x_a4(u, v) = -d_t + (R_a + r_a * cos(v)) * cos(u)
y_a4(u, v) = -d_t + (R_a + r_a * cos(v)) * sin(u)
z_a4(u, v) =  d_t + r_a * sin(v)

# Tetrahedral Core Magnetic Cage Guide Envelope
R_cage = 2.45
r_cage_tube = 0.03
x_cage(u, v) = (R_cage + r_cage_tube * cos(v)) * cos(u)
y_cage(u, v) = (R_cage + r_cage_tube * cos(v)) * sin(u)
z_cage(u, v) = r_cage_tube * sin(v)

# Wireframe Line Styles
set style line 1 lc rgb "#c0392b" lw 1.5   # Crimson: Alpha Cluster 1
set style line 2 lc rgb "#185a9d" lw 1.5   # Blue: Alpha Cluster 2
set style line 3 lc rgb "#27ae60" lw 1.5   # Green: Alpha Cluster 3
set style line 4 lc rgb "#e67e22" lw 1.5   # Amber: Alpha Cluster 4
set style line 5 lc rgb "#7f8c8d" dt 2 lw 0.9 # Dashed gray: Spheroidal cage guide

set label 1 "\\alpha_1 (+,+,+)" at  d_t+0.3,  d_t,  d_t+0.65 center font "Sans-Bold,9" tc rgb "#c0392b"
set label 2 "\\alpha_2 (+,-,-)" at  d_t+0.3, -d_t, -d_t-0.65 center font "Sans-Bold,9" tc rgb "#185a9d"
set label 3 "\\alpha_3 (-,+,-)" at -d_t-0.3,  d_t, -d_t-0.65 center font "Sans-Bold,9" tc rgb "#27ae60"
set label 4 "\\alpha_4 (-,-,+)" at -d_t-0.3, -d_t,  d_t+0.65 center font "Sans-Bold,9" tc rgb "#e67e22"

splot x_a1(u, v),   y_a1(u, v),   z_a1(u, v)   with lines ls 1 title "Helium-4 Alpha Toroid 1 (Td)", \
      x_a2(u, v),   y_a2(u, v),   z_a2(u, v)   with lines ls 2 title "Helium-4 Alpha Toroid 2 (Td)", \
      x_a3(u, v),   y_a3(u, v),   z_a3(u, v)   with lines ls 3 title "Helium-4 Alpha Toroid 3 (Td)", \
      x_a4(u, v),   y_a4(u, v),   z_a4(u, v)   with lines ls 4 title "Helium-4 Alpha Toroid 4 (Td)", \
      x_cage(u, v), y_cage(u, v), z_cage(u, v) with lines ls 5 title "Equatorial Tetrahedral Envelope"

if (!exists("OUTFILE")) {
    pause mouse close
}
