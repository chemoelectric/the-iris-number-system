# Gnuplot script: 3D High-Detail Wireframe Snapshot of Diatomic Hydrogen (H2)
# Depicts the discrete electromagnetic architecture of the covalent H-H bond on G_N:
# - Two positive proton potential wells at internuclear equilibrium separation d_HH = 1.40 a_0
# - The interlocking cylindrical dual-vortex sigma bonding tube confining the shared electron pair
# - Diamagnetic screening current toroids and bridging flux filaments
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Electromagnetic Snapshot of Diatomic Hydrogen (H_2)\n{/*0.85Covalent Bond Vortex Sheath and Nuclear Wells on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 44, 44
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X: Bond Axis (a_0)" offset -1,-0.5
set ylabel "Y (a_0)" offset 1,-0.5
set zlabel "Z (a_0)" offset 1,0
set xrange [-2.2:2.2]
set yrange [-2.0:2.0]
set zrange [-2.0:2.0]
set xyplane at -2.0
set view 65, 335, 1.2, 1.0

# Physical constants in atomic units (a_0 ~ 0.529177 Angstrom)
# Equilibrium bond length d_HH = 1.40 a_0 (~0.741 Angstrom)
d_HH = 1.40
x_p1 = -d_HH / 2.0
x_p2 =  d_HH / 2.0

# 1. Proton Nuclear Core Wells
r_p = 0.15
x_prot1(u, v) = x_p1 + r_p * sin(u/2.0) * cos(v)
y_prot1(u, v) = r_p * sin(u/2.0) * sin(v)
z_prot1(u, v) = r_p * cos(u/2.0)

x_prot2(u, v) = x_p2 + r_p * sin(u/2.0) * cos(v)
y_prot2(u, v) = r_p * sin(u/2.0) * sin(v)
z_prot2(u, v) = r_p * cos(u/2.0)

# 2. Interlocking Covalent Sigma Bonding Electron Tube (Shared Pair Vortex)
# Spans from x_p1 to x_p2 with maximum bulge at the internuclear midpoint (x = 0)
u_norm(u) = u / (2.0 * pi)
x_pos(u)  = x_p1 + u_norm(u) * d_HH
r_bond(u) = 0.48 * (sin(u_norm(u) * pi)**0.65) * (1.0 + 0.15 * cos(2.0 * u_norm(u) * pi))

x_bond(u, v) = x_pos(u)
y_bond(u, v) = r_bond(u) * cos(v)
z_bond(u, v) = r_bond(u) * sin(v)

# 3. Outer Diamagnetic Screening Toroid at Mid-plane (x = 0)
R_mid = 0.62
r_mid = 0.14
x_mid(u, v) = r_mid * cos(v)
y_mid(u, v) = (R_mid + r_mid * sin(v)) * cos(u)
z_mid(u, v) = (R_mid + r_mid * sin(v)) * sin(u)

# 4. 1D Longitudinal Electromagnetic Flux Filaments (Screening Lines of Force)
set samples 100
set table $FLUX_BOUND1
plot [t=0:1] (1.6 * (t - 0.5) * d_HH), (0.82 * sin(t * pi))
unset table

# Wireframe Line Styles
set style line 1 lc rgb "#185a9d" lw 1.5              # Deep blue: Shared covalent electron pair sheath
set style line 2 lc rgb "#c0392b" lw 1.5              # Red: Proton nuclear loci
set style line 3 lc rgb "#27ae60" lw 1.2              # Green: Mid-plane diamagnetic screening toroid
set style line 4 lc rgb "#d35400" dt (18, 12) lw 1.8  # Distinct Dashed Orange: Outer flux boundary

# Labels for atomic loci
set label 1 "Proton H_1^+ (-0.70 a_0)" at x_p1, 0, -0.32 center font "Sans-Bold,10" tc rgb "#c0392b"
set label 2 "Proton H_2^+ (+0.70 a_0)" at x_p2, 0, -0.32 center font "Sans-Bold,10" tc rgb "#c0392b"
set label 3 "Covalent Bond Sheath (2e^-)" at 0, 0, 0.72 center font "Sans-Bold,10" tc rgb "#185a9d"
set label 4 "Bond Length: d_{HH} = 1.40 a_0 (0.74 {\305})" at 0, -0.9, -0.15 center font "Sans,9" tc rgb "#555555"

# Plot components
splot x_bond(u, v),  y_bond(u, v),  z_bond(u, v)  with lines ls 1 title "Shared \\sigma-Bonding Vortex Sheath (2e^-)", \
      x_prot1(u, v), y_prot1(u, v), z_prot1(u, v) with lines ls 2 title "Proton Nuclear Wells (p^+)", \
      x_prot2(u, v), y_prot2(u, v), z_prot2(u, v) with lines ls 2 notitle, \
      x_mid(u, v),   y_mid(u, v),   z_mid(u, v)   with lines ls 3 title "Mid-Plane Diamagnetic Toroid", \
      $FLUX_BOUND1 using 1:2:(0.0) with lines ls 4 title "Electromagnetic Flux Sheath", \
      $FLUX_BOUND1 using 1:(-$2):(0.0) with lines ls 4 notitle, \
      $FLUX_BOUND1 using 1:(0.0):2 with lines ls 4 notitle, \
      $FLUX_BOUND1 using 1:(0.0):(-$2) with lines ls 4 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
