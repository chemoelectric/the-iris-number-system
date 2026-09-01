# Gnuplot script: 3D High-Detail Wireframe Temporal Snapshot of Monatomic Hydrogen (H)
# Depicts the discrete electromagnetic structure of a ground-state hydrogen atom on G_N:
# - The localized toroidal current vortex of the single 1s electron orbiting at the Bohr radius (r = 1.0 a_0)
# - The localized positive potential well / screening vortex of the central proton
# - The dipolar electromagnetic flux filaments bridging the electron and proton
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

# 1. Output terminal handling (PNG export or interactive window with persistent mouse control)
if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Temporal Snapshot of Monatomic Hydrogen (H, Z=1)\n{/*0.85Electron Vortex and Proton Locus on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

# 2. 3D Wireframe rendering configuration
set parametric
set hidden3d
unset pm3d
set surface

# Mesh sampling density
set isosamples 44, 44
set urange [0:2*pi]
set vrange [0:2*pi]

# 3. Coordinate axes and viewing angles
set xlabel "X (a_0)" offset -1,-0.5
set ylabel "Y (a_0)" offset 1,-0.5
set zlabel "Z (a_0)" offset 1,0
set xrange [-1.8:1.8]
set yrange [-1.8:1.8]
set zrange [-1.8:1.8]
set xyplane at -1.8
set view 62, 325, 1.25, 1.0

# Physical constants and coordinates in atomic units (a_0 ~ 0.529177 Angstrom)
# Proton located at the origin (0, 0, 0)
# Discrete electron centroid located at the Bohr radius on the X-axis: (r_0 = 1.0 a_0, 0, 0)
r_bohr = 1.0

# ----------------------------------------------------------------------------
# A. Localized Toroidal Current Vortex of the 1s Electron
# The single electron possesses finite spatial extent (m-res scale) as a toroidal vortex
# with major radius R_e ~ 0.28 a_0 and minor cross-section r_e ~ 0.12 a_0
# ----------------------------------------------------------------------------
R_e_maj = 0.28
r_e_min = 0.12

# Electron torus centered at (r_bohr, 0, 0), oriented with normal along +Z (orbital angular momentum)
x_elec(u, v) = r_bohr + (R_e_maj + r_e_min * cos(v)) * cos(u)
y_elec(u, v) = (R_e_maj + r_e_min * cos(v)) * sin(u)
z_elec(u, v) = r_e_min * sin(v)

# ----------------------------------------------------------------------------
# B. Central Proton Potential Core Locus (Positive Charge Well at Origin)
# ----------------------------------------------------------------------------
r_proton = 0.16
x_prot(u, v) = r_proton * sin(u/2.0) * cos(v)
y_prot(u, v) = r_proton * sin(u/2.0) * sin(v)
z_prot(u, v) = r_proton * cos(u/2.0)

# ----------------------------------------------------------------------------
# C. Orbital Track (The 1s Trajectory Circle on G_N)
# ----------------------------------------------------------------------------
r_track_tube = 0.03
x_track(u, v) = (r_bohr + r_track_tube * cos(v)) * cos(u)
y_track(u, v) = (r_bohr + r_track_tube * cos(v)) * sin(u)
z_track(u, v) = r_track_tube * sin(v)

# ----------------------------------------------------------------------------
# D. Dipolar Electromagnetic Flux Filaments (Lines of Force)
# Curved field lines connecting the positive proton to the negative electron vortex
# ----------------------------------------------------------------------------
u_n(u) = u / (2.0 * pi)

# Filament 1: Direct planar equatorial arc
x_f1(u, v) = r_bohr * u_n(u)
y_f1(u, v) = 0.35 * sin(u_n(u) * pi)
z_f1(u, v) = 0.0

# Filament 2: Opposing planar equatorial arc
x_f2(u, v) = r_bohr * u_n(u)
y_f2(u, v) = -0.35 * sin(u_n(u) * pi)
z_f2(u, v) = 0.0

# Filament 3: Upper polar meridian arc (+Z loop)
x_f3(u, v) = r_bohr * u_n(u)
y_f3(u, v) = 0.0
z_f3(u, v) = 0.45 * sin(u_n(u) * pi)

# Filament 4: Lower polar meridian arc (-Z loop)
x_f4(u, v) = r_bohr * u_n(u)
y_f4(u, v) = 0.0
z_f4(u, v) = -0.45 * sin(u_n(u) * pi)

# Filament 5: Outer screening return loop in the rear of the electron
r_loop(u) = 0.60 * sin(u_n(u) * pi)
x_f5(u, v) = r_bohr + (0.50 * (1.0 - cos(u_n(u) * pi))) * 0.65
y_f5(u, v) = r_loop(u) * cos(pi/3.0)
z_f5(u, v) = r_loop(u) * sin(pi/3.0)

x_f6(u, v) = r_bohr + (0.50 * (1.0 - cos(u_n(u) * pi))) * 0.65
y_f6(u, v) = -r_loop(u) * cos(pi/3.0)
z_f6(u, v) = -r_loop(u) * sin(pi/3.0)

# Wireframe Line Styles
set style line 1 lc rgb "#185a9d" lw 1.5   # Deep blue: 1s electron current vortex
set style line 2 lc rgb "#c0392b" lw 1.5   # Red: Central proton locus
set style line 3 lc rgb "#95a5a6" dt 2 lw 0.9 # Dashed gray: 1s orbital track
set style line 4 lc rgb "#d35400" lw 1.1   # Orange: Electromagnetic flux filaments

# Labels for atomic loci
set label 1 "Proton (p^+, Z=1)" at 0, 0, -0.28 center font "Sans-Bold,10" tc rgb "#c0392b"
set label 2 "Electron Vortex (e^-)" at r_bohr, 0, 0.42 center font "Sans-Bold,10" tc rgb "#185a9d"
set label 3 "Bohr Radius: a_0 = 0.529 {\305}" at 0.5, -0.2, -0.15 center font "Sans,9" tc rgb "#555555"

# Plot all interacting wireframe components
splot x_elec(u, v),  y_elec(u, v),  z_elec(u, v)  with lines ls 1 title "1s Electron Vortex Soliton (e^-)", \
      x_prot(u, v),  y_prot(u, v),  z_prot(u, v)  with lines ls 2 title "Proton Nuclear Locus (p^+)", \
      x_track(u, v), y_track(u, v), z_track(u, v) with lines ls 3 title "1s Bohr Orbit Track (r = 1 a_0)", \
      x_f1(u, v),    y_f1(u, v),    z_f1(u, v)    with lines ls 4 title "Electromagnetic Flux Filaments", \
      x_f2(u, v),    y_f2(u, v),    z_f2(u, v)    with lines ls 4 notitle, \
      x_f3(u, v),    y_f3(u, v),    z_f3(u, v)    with lines ls 4 notitle, \
      x_f4(u, v),    y_f4(u, v),    z_f4(u, v)    with lines ls 4 notitle, \
      x_f5(u, v),    y_f5(u, v),    z_f5(u, v)    with lines ls 4 notitle, \
      x_f6(u, v),    y_f6(u, v),    z_f6(u, v)    with lines ls 4 notitle

# Keep interactive window open until mouse click or key press
if (!exists("OUTFILE")) {
    pause mouse close
}
