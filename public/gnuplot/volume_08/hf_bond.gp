# Gnuplot: 3D High-Detail Close-Up Wireframe of HF Electron Interactions
# Depicts the instantaneous electromagnetic vortex meshwork of interacting electrons on G_N:
# - Shared polar covalent bonding electron pair bridging H and F
# - Three fluorine 2p lone-pair lobes in trigonal back-lobe orientation
# - Localized 1s^2 fluorine core toroid and proton screening locus
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Instantaneous Electron Interactions in Hydrogen Fluoride (HF)\n{/*0.85High-Magnification 3D Wireframe Meshwork on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 44, 44
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X (a_0)" offset -1,-0.5
set ylabel "Y (a_0)" offset 1,-0.5
set zlabel "Z: Internuclear Axis (a_0)" offset 1,0
set xrange [-1.3:1.3]
set yrange [-1.3:1.3]
set zrange [-1.4:1.6]
set xyplane at -1.4
set view 68, 330, 1.25, 1.0

z_F = -0.52
z_H =  1.21

# 1. Shared Polar Covalent Bonding Electron Pair (Bridge Vortex)
u_norm(u)    = u / (2.0 * pi)
z_bond(u, v) = z_F + 0.15 + (z_H - z_F - 0.25) * u_norm(u)
r_bond(u)    = 0.44 * (sin(u_norm(u)*pi)**0.75) * (1.0 + 0.25*(1.0 - u_norm(u)))
x_bond(u, v) = r_bond(u) * cos(v)
y_bond(u, v) = r_bond(u) * sin(v)

# 2. Three Fluorine 2p Lone Pairs (Trigonal Back-Lobe Meshworks)
theta_lp = 1.9548  # 112 degrees (pointing backward from bond axis)
phi_1    = 0.0
phi_2    = 2.0944  # 120 degrees
phi_3    = 4.1888  # 240 degrees

L_lp = 0.72
R_lp = 0.34

z_lobe_base(u, v) = L_lp * (0.5 * (1.0 - cos(u/2.0)))
r_lobe_base(u, v) = R_lp * sin(u/2.0) * (1.0 - 0.20 * cos(u/2.0))
x_lobe_base(u, v) = r_lobe_base(u, v) * cos(v)
y_lobe_base(u, v) = r_lobe_base(u, v) * sin(v)

x_rot(x, y, z, th, ph) = (x*cos(th) + z*sin(th))*cos(ph) - y*sin(ph)
y_rot(x, y, z, th, ph) = (x*cos(th) + z*sin(th))*sin(ph) + y*cos(ph)
z_rot(x, y, z, th, ph) = -x*sin(th) + z*cos(th)

x_lp1(u, v) = x_rot(x_lobe_base(u, v), y_lobe_base(u, v), z_lobe_base(u, v), theta_lp, phi_1)
y_lp1(u, v) = y_rot(x_lobe_base(u, v), y_lobe_base(u, v), z_lobe_base(u, v), theta_lp, phi_1)
z_lp1(u, v) = z_F + z_rot(x_lobe_base(u, v), y_lobe_base(u, v), z_lobe_base(u, v), theta_lp, phi_1)

x_lp2(u, v) = x_rot(x_lobe_base(u, v), y_lobe_base(u, v), z_lobe_base(u, v), theta_lp, phi_2)
y_lp2(u, v) = y_rot(x_lobe_base(u, v), y_lobe_base(u, v), z_lobe_base(u, v), theta_lp, phi_2)
z_lp2(u, v) = z_F + z_rot(x_lobe_base(u, v), y_lobe_base(u, v), z_lobe_base(u, v), theta_lp, phi_2)

x_lp3(u, v) = x_rot(x_lobe_base(u, v), y_lobe_base(u, v), z_lobe_base(u, v), theta_lp, phi_3)
y_lp3(u, v) = y_rot(x_lobe_base(u, v), y_lobe_base(u, v), z_lobe_base(u, v), theta_lp, phi_3)
z_lp3(u, v) = z_F + z_rot(x_lobe_base(u, v), y_lobe_base(u, v), z_lobe_base(u, v), theta_lp, phi_3)

# 3. Fluorine 1s^2 Core Toroid
R_core_major = 0.20
r_core_minor = 0.07
x_core(u, v) = (R_core_major + r_core_minor * cos(v)) * cos(u)
y_core(u, v) = (R_core_major + r_core_minor * cos(v)) * sin(u)
z_core(u, v) = z_F + r_core_minor * sin(v)

# 4. Proton (H) Screening Locus
r_H_vortex = 0.16
x_H_well(u, v) = r_H_vortex * sin(u/2.0) * cos(v)
y_H_well(u, v) = r_H_vortex * sin(u/2.0) * sin(v)
z_H_well(u, v) = z_H + r_H_vortex * cos(u/2.0)

# Wireframe Line Styles
set style line 1 lc rgb "#002855" lw 1.3  # Blue: Shared bonding electron pair
set style line 2 lc rgb "#78281f" lw 1.1  # Orange: Fluorine 2p lone pairs
set style line 3 lc rgb "#8b0000" lw 1.4  # Red: Fluorine 1s^2 core toroid
set style line 4 lc rgb "#004d20" lw 1.2  # Green: Proton screening locus

set label 1 "Fluorine Core (Z=9)" at 0, 0, z_F-0.35 center font "Sans-Bold,9" tc rgb "#8b0000"
set label 2 "Proton Locus (H^+)"  at 0, 0, z_H+0.30 center font "Sans-Bold,9" tc rgb "#004d20"
set label 3 "Polar Covalent Axis" at 0, -1.0, 0 center font "Sans,9" tc rgb "#111111"

set key top right spacing 1.2 font "Sans,9.5"

splot x_bond(u, v),   y_bond(u, v),   z_bond(u, v)   with lines ls 1 title "Shared Polar Covalent Bonding Sheath", \
      x_lp1(u, v),    y_lp1(u, v),    z_lp1(u, v)    with lines ls 2 title "Fluorine 2p Lone-Pair Lobes (3x)", \
      x_lp2(u, v),    y_lp2(u, v),    z_lp2(u, v)    with lines ls 2 notitle, \
      x_lp3(u, v),    y_lp3(u, v),    z_lp3(u, v)    with lines ls 2 notitle, \
      x_core(u, v),   y_core(u, v),   z_core(u, v)   with lines ls 3 title "Fluorine 1s^2 Core Toroid", \
      x_H_well(u, v), y_H_well(u, v), z_H_well(u, v) with lines ls 4 title "Proton (H) Screening Locus"

if (!exists("OUTFILE")) {
    pause mouse close
}
