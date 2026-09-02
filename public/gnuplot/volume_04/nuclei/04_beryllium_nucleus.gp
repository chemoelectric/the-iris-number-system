# Gnuplot: 3D High-Detail Wireframe Snapshot of Beryllium-9 Nucleus
# Depicts the discrete electromagnetic architecture of the 9Be nucleus on G_N:
# - Two coaxial Helium-4 alpha core toroids separated along the Z-axis
# - A central bridging neutron current ring nestled at the mid-plane waist (Z = 0)
# - Inter-alpha magnetic flux sheaths holding the dumbbell-like nuclear molecule together
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Nuclear Structure Snapshot: Beryllium-9 (^9Be, Z=4, A=9)\n{/*0.85Dual Alpha Toroids with Bridging Neutron Ring on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

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
set xrange [-2.6:2.6]
set yrange [-2.6:2.6]
set zrange [-3.0:3.0]
set xyplane at -3.0
set view 68, 335, 1.2, 1.0

# 1. Upper Alpha Toroid (+Z)
R_a = 0.80
r_a = 0.28
z_a1 = 1.35

x_a1_top(u, v) = (R_a + r_a * cos(v)) * cos(u)
y_a1_top(u, v) = (R_a + r_a * cos(v)) * sin(u)
z_a1_top(u, v) =  z_a1 + 0.25 + r_a * sin(v)

x_a1_bot(u, v) = (R_a + r_a * cos(v)) * cos(u)
y_a1_bot(u, v) = (R_a + r_a * cos(v)) * sin(u)
z_a1_bot(u, v) =  z_a1 - 0.25 + r_a * sin(v)

# 2. Lower Alpha Toroid (-Z)
z_a2 = -1.35

x_a2_top(u, v) = (R_a + r_a * cos(v)) * cos(u)
y_a2_top(u, v) = (R_a + r_a * cos(v)) * sin(u)
z_a2_top(u, v) =  z_a2 + 0.25 + r_a * sin(v)

x_a2_bot(u, v) = (R_a + r_a * cos(v)) * cos(u)
y_a2_bot(u, v) = (R_a + r_a * cos(v)) * sin(u)
z_a2_bot(u, v) =  z_a2 - 0.25 + r_a * sin(v)

# 3. Bridging Neutron Current Ring at Mid-Plane (Z = 0)
R_neut = 0.55
r_neut = 0.22
x_neut(u, v) = (R_neut + r_neut * cos(v)) * cos(u)
y_neut(u, v) = (R_neut + r_neut * cos(v)) * sin(u)
z_neut(u, v) = r_neut * sin(v)

# 4. Inter-Alpha Magnetic Cinch / Flux Sheath
u_n(u) = u / (2.0 * pi)
z_span(u) = -z_a1 + 2.0 * z_a1 * u_n(u)
r_sheath(u) = 0.95 * (1.0 - 0.35 * sin(u_n(u) * pi))
x_sheath(u, v) = r_sheath(u) * cos(v)
y_sheath(u, v) = r_sheath(u) * sin(v)
z_sheath(u, v) = z_span(u)

# Wireframe Line Styles
set style line 1 lc rgb "#c0392b" lw 1.5   # Crimson: Upper Alpha Toroids
set style line 2 lc rgb "#8e44ad" lw 1.5   # Purple: Lower Alpha Toroids
set style line 3 lc rgb "#2980b9" lw 1.6   # Deep Blue: Central Bridging Neutron Ring
set style line 4 lc rgb "#27ae60" dt 2 lw 0.9 # Green dashed: Magnetic confinement sheath

set label 1 "Upper \\alpha-Cluster" at 0, 0, 2.1 center font "Sans-Bold,9.5" tc rgb "#c0392b"
set label 2 "Lower \\alpha-Cluster" at 0, 0, -2.1 center font "Sans-Bold,9.5" tc rgb "#8e44ad"
set label 3 "Bridging Neutron Ring (Z=0)" at 0, -1.35, 0.0 center font "Sans-Bold,9.5" tc rgb "#2980b9"
set label 4 "Inter-Alpha Bond Axis" at 1.4, 0, 0.0 center font "Sans,8.5" tc rgb "#555555"

splot x_a1_top(u, v), y_a1_top(u, v), z_a1_top(u, v) with lines ls 1 title "Upper Alpha Cluster (2p-2n)", \
      x_a1_bot(u, v), y_a1_bot(u, v), z_a1_bot(u, v) with lines ls 1 notitle, \
      x_a2_top(u, v), y_a2_top(u, v), z_a2_top(u, v) with lines ls 2 title "Lower Alpha Cluster (2p-2n)", \
      x_a2_bot(u, v), y_a2_bot(u, v), z_a2_bot(u, v) with lines ls 2 notitle, \
      x_neut(u, v),   y_neut(u, v),   z_neut(u, v)   with lines ls 3 title "Bridging Neutron Toroid (n)", \
      x_sheath(u, v), y_sheath(u, v), z_sheath(u, v) with lines ls 4 title "Inter-Cluster Magnetic Sheath"

if (!exists("OUTFILE")) {
    pause mouse close
}
