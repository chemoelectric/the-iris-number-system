# Gnuplot: 3D High-Detail Wireframe Snapshot of Hydrogen-1 Nucleus (Proton)
# Depicts the discrete electromagnetic kernel of the 1H nucleus (solitary proton) on G_N:
# - A primary toroidal positive charge-current vortex (major radius R = 0.85 fm, minor radius r = 0.35 fm)
# - Poloidal and toroidal magnetic flux recirculating filaments through the central aperture
# - Dipolar multivector field boundary sheath on the discrete grid G_N
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Nuclear Structure Snapshot: Hydrogen-1 (^1H, Z=1, A=1)\n{/*0.85Single Proton Toroidal Current Vortex on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

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
set xrange [-2.2:2.2]
set yrange [-2.2:2.2]
set zrange [-2.0:2.0]
set xyplane at -2.0
set view 62, 325, 1.25, 1.0

# 1. Proton Toroidal Current Ring (R_maj = 0.85 fm, r_min = 0.35 fm)
R_p = 0.85
r_p = 0.35

x_p(u, v) = (R_p + r_p * cos(v)) * cos(u)
y_p(u, v) = (R_p + r_p * cos(v)) * sin(u)
z_p(u, v) = r_p * sin(v)

# 2. Central Poloidal Recirculating Flux Loop through Core Aperture
u_n(u) = u / (2.0 * pi)
r_flux_tube = 0.04

x_f1(u, v) = (0.75 * sin(u_n(u) * pi) + r_flux_tube * cos(v)) * cos(0.0)
y_f1(u, v) = r_flux_tube * sin(v)
z_f1(u, v) = 1.25 * cos(u_n(u) * pi)

x_f2(u, v) = (0.75 * sin(u_n(u) * pi) + r_flux_tube * cos(v)) * cos(pi/2.0)
y_f2(u, v) = (0.75 * sin(u_n(u) * pi) + r_flux_tube * cos(v)) * sin(pi/2.0)
z_f2(u, v) = 1.25 * cos(u_n(u) * pi)

x_f3(u, v) = (0.75 * sin(u_n(u) * pi) + r_flux_tube * cos(v)) * cos(pi)
y_f3(u, v) = (0.75 * sin(u_n(u) * pi) + r_flux_tube * cos(v)) * sin(pi)
z_f3(u, v) = 1.25 * cos(u_n(u) * pi)

x_f4(u, v) = (0.75 * sin(u_n(u) * pi) + r_flux_tube * cos(v)) * cos(3.0*pi/2.0)
y_f4(u, v) = (0.75 * sin(u_n(u) * pi) + r_flux_tube * cos(v)) * sin(3.0*pi/2.0)
z_f4(u, v) = 1.25 * cos(u_n(u) * pi)

# 3. Outer Dipolar Return Flux Envelope
R_env = 1.65
r_env = 0.03
x_env(u, v) = (R_env + r_env * cos(v)) * cos(u)
y_env(u, v) = (R_env + r_env * cos(v)) * sin(u)
z_env(u, v) = r_env * sin(v)

# Wireframe Line Styles
set style line 1 lc rgb "#c0392b" lw 1.6   # Crimson: Proton toroidal current vortex
set style line 2 lc rgb "#185a9d" lw 1.1   # Deep blue: Axial/poloidal recirculating flux filaments
set style line 3 lc rgb "#7f8c8d" dt 2 lw 0.9 # Dashed gray: Outer magnetic flux boundary

set label 1 "Proton Toroid (p^+)" at 0, 0, 0.75 center font "Sans-Bold,10" tc rgb "#c0392b"
set label 2 "Major Radius R = 0.85 fm\nMinor Radius r = 0.35 fm" at 0, -1.3, -1.4 center font "Sans,9" tc rgb "#555555"
set label 3 "Recirculating Magnetic Flux" at 0, 1.2, 0.9 center font "Sans,9" tc rgb "#185a9d"

splot x_p(u, v),   y_p(u, v),   z_p(u, v)   with lines ls 1 title "Proton Current Toroid (p^+)", \
      x_f1(u, v),  y_f1(u, v),  z_f1(u, v)  with lines ls 2 title "Poloidal Magnetic Recirculation Lines", \
      x_f2(u, v),  y_f2(u, v),  z_f2(u, v)  with lines ls 2 notitle, \
      x_f3(u, v),  y_f3(u, v),  z_f3(u, v)  with lines ls 2 notitle, \
      x_f4(u, v),  y_f4(u, v),  z_f4(u, v)  with lines ls 2 notitle, \
      x_env(u, v), y_env(u, v), z_env(u, v) with lines ls 3 title "Equatorial Flux Boundary (G_N)"

if (!exists("OUTFILE")) {
    pause mouse close
}
