# Gnuplot script: 3D Wireframe Temporal Snapshot of Electron Interactions in HF
# Depicts the instantaneous electromagnetic vortex meshwork of interacting electrons:
# - The shared polar covalent bonding electron pair bridging H and F
# - The three fluorine 2p lone-pair lobes oriented in trigonal symmetry
# - The localized 1s^2 fluorine core toroid
# Pure 3D wireframe meshwork; no surface shading.

reset

# Output handling: default interactive terminal or PNG export if OUTFILE is defined
if (exists("OUTFILE")) {
    set terminal pngcairo size 1200,900 font "Sans,10"
    set output OUTFILE
}

set title "Temporal Snapshot of Electron Interactions in Hydrogen Fluoride (HF)\n{/*0.85Interlocking Electromagnetic Flux Meshwork on Discrete Grid G_N}" font "Sans-Bold,12" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

# Mesh resolution
set isosamples 36, 36
set urange [0:2*pi]
set vrange [0:2*pi]

# Coordinate axes and viewing geometry
set xlabel "X (a_0)" offset -1,-0.5
set ylabel "Y (a_0)" offset 1,-0.5
set zlabel "Z: Internuclear Axis (a_0)" offset 1,0
set xrange [-2.2:2.2]
set yrange [-2.2:2.2]
set zrange [-2.2:2.2]
set xyplane at -2.2
set view 65, 325, 1.1, 1.0

# Physical coordinates along internuclear axis (in atomic units a_0)
z_F = -0.55   # Fluorine nucleus locus
z_H =  1.18   # Hydrogen proton locus

# ----------------------------------------------------------------------------
# 1. Shared Polar Covalent Bonding Electron Pair (Bridge Meshwork)
# Modeled as a dual-vortex pinched flux tube along the internuclear corridor
# ----------------------------------------------------------------------------
z_bond_c = 0.35
L_bond   = 0.75
R_bond_0 = 0.42

z_bond(u, v) = z_bond_c + L_bond * cos(u)
# Radius bulges near center, tapers at nuclear contacts
r_bond(u)    = R_bond_0 * (sin(u)**0.8 + 0.15 * cos(u))
x_bond(u, v) = r_bond(u) * cos(v)
y_bond(u, v) = r_bond(u) * sin(v)

# ----------------------------------------------------------------------------
# 2. Fluorine 1s^2 Core Electron Pair (Localized Toroidal Current Loop)
# ----------------------------------------------------------------------------
R_core = 0.22
r_core = 0.08
x_core(u, v) = (R_core + r_core * cos(v)) * cos(u)
y_core(u, v) = (R_core + r_core * cos(v)) * sin(u)
z_core(u, v) = z_F + r_core * sin(v)

# ----------------------------------------------------------------------------
# 3. Three Fluorine 2p Lone-Pair Electron Lobes (Trigonal Back-Lobe Meshworks)
# Inclined at theta_lp = 112 deg relative to the +Z bond axis, spaced at 120 deg
# ----------------------------------------------------------------------------
theta_lp = 1.95  # ~112 degrees (pointing backward from bond axis)
phi_1    = 0.0
phi_2    = 2.0 * pi / 3.0
phi_3    = 4.0 * pi / 3.0

L_lp = 0.70
R_lp = 0.32

# Generic teardrop lobe centered at origin, directed along +Z
z_lobe_local(u, v) = L_lp * (0.5 * (1.0 - cos(u)))
r_lobe_local(u, v) = R_lp * sin(u) * (1.0 - 0.25 * cos(u))
x_lobe_local(u, v) = r_lobe_local(u, v) * cos(v)
y_lobe_local(u, v) = r_lobe_local(u, v) * sin(v)

# Rotation into (theta, phi) orientation and translation to z_F
x_rot(x, y, z, th, ph) = (x*cos(th) + z*sin(th))*cos(ph) - y*sin(ph)
y_rot(x, y, z, th, ph) = (x*cos(th) + z*sin(th))*sin(ph) + y*cos(ph)
z_rot(x, y, z, th, ph) = -x*sin(th) + z*cos(th)

# Lone pair 1
x_lp1(u, v) = x_rot(x_lobe_local(u, v), y_lobe_local(u, v), z_lobe_local(u, v), theta_lp, phi_1)
y_lp1(u, v) = y_rot(x_lobe_local(u, v), y_lobe_local(u, v), z_lobe_local(u, v), theta_lp, phi_1)
z_lp1(u, v) = z_F + z_rot(x_lobe_local(u, v), y_lobe_local(u, v), z_lobe_local(u, v), theta_lp, phi_1)

# Lone pair 2
x_lp2(u, v) = x_rot(x_lobe_local(u, v), y_lobe_local(u, v), z_lobe_local(u, v), theta_lp, phi_2)
y_lp2(u, v) = y_rot(x_lobe_local(u, v), y_lobe_local(u, v), z_lobe_local(u, v), theta_lp, phi_2)
z_lp2(u, v) = z_F + z_rot(x_lobe_local(u, v), y_lobe_local(u, v), z_lobe_local(u, v), theta_lp, phi_2)

# Lone pair 3
x_lp3(u, v) = x_rot(x_lobe_local(u, v), y_lobe_local(u, v), z_lobe_local(u, v), theta_lp, phi_3)
y_lp3(u, v) = y_rot(x_lobe_local(u, v), y_lobe_local(u, v), z_lobe_local(u, v), theta_lp, phi_3)
z_lp3(u, v) = z_F + z_rot(x_lobe_local(u, v), y_lobe_local(u, v), z_lobe_local(u, v), theta_lp, phi_3)

# ----------------------------------------------------------------------------
# 4. Discrete Internuclear Polarization Field Filaments (Lines of Force)
# ----------------------------------------------------------------------------
r_fil(u) = 0.65 * sin(u)
z_fil(u) = 0.5 * (z_H + z_F) + 0.5 * (z_H - z_F) * cos(u)

x_fil1(u, v) = r_fil(u) * cos(0.0)
y_fil1(u, v) = r_fil(u) * sin(0.0)
z_fil1(u, v) = z_fil(u)

x_fil2(u, v) = r_fil(u) * cos(pi/2.0)
y_fil2(u, v) = r_fil(u) * sin(pi/2.0)
z_fil2(u, v) = z_fil(u)

x_fil3(u, v) = r_fil(u) * cos(pi)
y_fil3(u, v) = r_fil(u) * sin(pi)
z_fil3(u, v) = z_fil(u)

x_fil4(u, v) = r_fil(u) * cos(3.0*pi/2.0)
y_fil4(u, v) = r_fil(u) * sin(3.0*pi/2.0)
z_fil4(u, v) = z_fil(u)

# Wireframe line styling
set style line 1 lc rgb "#1b4d89" lw 1.2  # Blue: Shared bonding pair
set style line 2 lc rgb "#d35400" lw 1.0  # Orange: Lone pair electron lobes
set style line 3 lc rgb "#c0392b" lw 1.3  # Red: 1s^2 core electron toroid
set style line 4 lc rgb "#7f8c8d" dt 2 lw 0.9 # Dashed gray: Polarization lines of force

# Nuclear coordinate labels
set label 1 "F Nucleus (Z=9)" at 0, 0, z_F-0.25 center font "Sans-Bold,9" tc rgb "#c0392b"
set label 2 "Proton (H^+)"    at 0, 0, z_H+0.25 center font "Sans-Bold,9" tc rgb "#1b4d89"

# Render wireframe meshes
splot x_bond(u, v), y_bond(u, v), z_bond(u, v) with lines ls 1 title "Shared Bonding Electron Pair (Bridge Vortex)", \
      x_lp1(u, v),  y_lp1(u, v),  z_lp1(u, v)  with lines ls 2 title "Fluorine 2p Lone Pair 1", \
      x_lp2(u, v),  y_lp2(u, v),  z_lp2(u, v)  with lines ls 2 title "Fluorine 2p Lone Pair 2", \
      x_lp3(u, v),  y_lp3(u, v),  z_lp3(u, v)  with lines ls 2 title "Fluorine 2p Lone Pair 3", \
      x_core(u, v), y_core(u, v), z_core(u, v) with lines ls 3 title "Fluorine 1s^2 Core Electron Toroid", \
      x_fil1(u, v), y_fil1(u, v), z_fil1(u, v) with lines ls 4 notitle, \
      x_fil2(u, v), y_fil2(u, v), z_fil2(u, v) with lines ls 4 notitle, \
      x_fil3(u, v), y_fil3(u, v), z_fil3(u, v) with lines ls 4 notitle, \
      x_fil4(u, v), y_fil4(u, v), z_fil4(u, v) with lines ls 4 notitle
