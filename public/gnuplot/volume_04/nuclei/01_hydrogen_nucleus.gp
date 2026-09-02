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

# 2. 1D Poloidal Recirculating Magnetic Flux Lines through Core Aperture
set samples 120
set table $FLUX_LOOP
plot [t=0:2*pi] (0.75 * sin(t/2.0)), (1.25 * cos(t/2.0))
unset table

# 3. 1D Outer Equatorial Flux Boundary Ring (G_N)
set table $ENV_RING
plot [t=0:2*pi] 1.65 * cos(t), 1.65 * sin(t)
unset table

# Wireframe Line Styles
set style line 1 lc rgb "#c0392b" lw 1.6                    # Crimson: Proton toroidal current vortex
set style line 2 lc rgb "#185a9d" lw 1.5                    # Deep blue: Axial recirculating flux filaments
set style line 3 lc rgb "#444444" dt (18, 12) lw 1.8        # Distinct Dashed Dark Gray: Equatorial flux boundary on G_N

set label 1 "Proton Toroid (p^+)" at 0, 0, 0.75 center font "Sans-Bold,10" tc rgb "#c0392b"
set label 2 "Major Radius R = 0.85 fm\nMinor Radius r = 0.35 fm" at 0, -1.3, -1.4 center font "Sans,9" tc rgb "#555555"
set label 3 "Recirculating Magnetic Flux" at 0, 1.2, 0.9 center font "Sans,9" tc rgb "#185a9d"
set label 4 "Equatorial Flux Boundary (G_N)" at 1.7, 0, -0.25 center font "Sans-Bold,8.5" tc rgb "#444444"

splot x_p(u, v), y_p(u, v), z_p(u, v) with lines ls 1 title "Proton Current Toroid (p^+)", \
      $FLUX_LOOP using 1:(0.0):2 with lines ls 2 title "Poloidal Magnetic Recirculation Lines", \
      $FLUX_LOOP using (-$1):(0.0):2 with lines ls 2 notitle, \
      $FLUX_LOOP using (0.0):1:2 with lines ls 2 notitle, \
      $FLUX_LOOP using (0.0):(-$1):2 with lines ls 2 notitle, \
      $ENV_RING  using 1:2:(0.0) with lines ls 3 title "Equatorial Flux Boundary (G_N)"

if (!exists("OUTFILE")) {
    pause mouse close
}
