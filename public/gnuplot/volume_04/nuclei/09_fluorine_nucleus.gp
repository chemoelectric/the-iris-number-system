# Gnuplot: 3D High-Detail Wireframe Snapshot of Fluorine-19 Nucleus
# Depicts the discrete electromagnetic architecture of the 19F nucleus on G_N:
# - A tetrahedral Oxygen-16 4-alpha core scaffold
# - An external trineutron/proton polar cap cluster (1 proton + 2 neutrons forming a triton vortex)
# - Net spin J=1/2+ and large magnetic moment from the unshielded triton cap
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Nuclear Structure Snapshot: Fluorine-19 (^19F, Z=9, A=19)\n{/*0.85Tetrahedral 4-Alpha Core with Polar Triton Cap on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

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
set zrange [-3.2:3.2]
set xyplane at -3.2
set view 60, 45, 1.25, 1.0

# 1. Tetrahedral 4-Alpha Core (Oxygen-16 base shifted slightly along -Z)
d_t = 1.45 / sqrt(3.0)
z_shift = -0.35
R_a = 0.54
r_a = 0.18

# Alpha 1: (+d_t, +d_t, +d_t + z_shift)
x_a1(u, v) =  d_t + (R_a + r_a * cos(v)) * cos(u)
y_a1(u, v) =  d_t + (R_a + r_a * cos(v)) * sin(u)
z_a1(u, v) =  d_t + z_shift + r_a * sin(v)

# Alpha 2: (+d_t, -d_t, -d_t + z_shift)
x_a2(u, v) =  d_t + (R_a + r_a * cos(v)) * cos(u)
y_a2(u, v) = -d_t + (R_a + r_a * cos(v)) * sin(u)
z_a2(u, v) = -d_t + z_shift + r_a * sin(v)

# Alpha 3: (-d_t, +d_t, -d_t + z_shift)
x_a3(u, v) = -d_t + (R_a + r_a * cos(v)) * cos(u)
y_a3(u, v) =  d_t + (R_a + r_a * cos(v)) * sin(u)
z_a3(u, v) = -d_t + z_shift + r_a * sin(v)

# Alpha 4: (-d_t, -d_t, +d_t + z_shift)
x_a4(u, v) = -d_t + (R_a + r_a * cos(v)) * cos(u)
y_a4(u, v) = -d_t + (R_a + r_a * cos(v)) * sin(u)
z_a4(u, v) =  d_t + z_shift + r_a * sin(v)

# 2. Polar Triton Cap at +Z apex (Z = +1.85 fm)
z_triton = 1.85
R_tri_cap = 0.48
r_tri_cap = 0.16

x_triton(u, v) = (R_tri_cap + r_tri_cap * cos(v)) * cos(u)
y_triton(u, v) = (R_tri_cap + r_tri_cap * cos(v)) * sin(u)
z_triton(u, v) = z_triton + r_tri_cap * sin(v)

# 3. Polar Magnetic Flux Sheaths Connecting Cap to Alpha Core
u_n(u) = u / (2.0 * pi)
r_f_tube = 0.03
x_cap_f1(u, v) = (d_t * (1.0 - u_n(u)) + r_f_tube * cos(v))
y_cap_f1(u, v) = (d_t * (1.0 - u_n(u)) + r_f_tube * sin(v))
z_cap_f1(u, v) = (d_t + z_shift) + (z_triton - (d_t + z_shift)) * u_n(u)

# Wireframe Line Styles
set style line 1 lc rgb "#c0392b" lw 1.4   # Crimson: Core Alpha 1
set style line 2 lc rgb "#185a9d" lw 1.4   # Blue: Core Alpha 2
set style line 3 lc rgb "#27ae60" lw 1.4   # Green: Core Alpha 3
set style line 4 lc rgb "#e67e22" lw 1.4   # Amber: Core Alpha 4
set style line 5 lc rgb "#8e44ad" lw 1.6   # Purple: Polar Triton Cap (p_9-2n)
set style line 6 lc rgb "#7f8c8d" dt 2 lw 0.9 # Dashed gray: Flux coupler

set label 1 "16O \\alpha_4 Core" at 0, 0, -1.5 center font "Sans-Bold,9.5" tc rgb "#555555"
set label 2 "Polar Triton Cap (^3H cluster)" at 0, 0, z_triton+0.55 center font "Sans-Bold,9.5" tc rgb "#8e44ad"
set label 3 "Apex Coupling Flux" at 0.8, 0.8, 1.2 center font "Sans,8.5" tc rgb "#7f8c8d"

splot x_a1(u, v),     y_a1(u, v),     z_a1(u, v)     with lines ls 1 title "16O Core Alpha 1", \
      x_a2(u, v),     y_a2(u, v),     z_a2(u, v)     with lines ls 2 title "16O Core Alpha 2", \
      x_a3(u, v),     y_a3(u, v),     z_a3(u, v)     with lines ls 3 title "16O Core Alpha 3", \
      x_a4(u, v),     y_a4(u, v),     z_a4(u, v)     with lines ls 4 title "16O Core Alpha 4", \
      x_triton(u, v), y_triton(u, v), z_triton(u, v) with lines ls 5 title "Polar Triton Cap (p_9 + 2n)", \
      x_cap_f1(u, v), y_cap_f1(u, v), z_cap_f1(u, v) with lines ls 6 title "Polar Core Flux Coupler"

if (!exists("OUTFILE")) {
    pause mouse close
}
