# Gnuplot script: 3D High-Detail Wireframe Snapshot of an Alpha-Helix Protein Backbone Segment
# Depicts the discrete electromagnetic architecture on G_N:
# - Helical peptide backbone locus with characteristic pitch (P = 10.2 a_0, ~5.4 Angstrom) and 3.6 residues/turn
# - Oriented C=O ... H-N longitudinal hydrogen-bonding electrostatic flux tubes bridging turn i and turn i+4
# - Side-chain beta-carbon projection points
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Electromagnetic Snapshot of \\alpha-Helix Peptide Backbone\n{/*0.85Helical Main Chain and Longitudinal C=O\\cdots H-N Hydrogen-Bond Lattice on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 44, 44
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X (a_0)" offset -1,-0.5
set ylabel "Y (a_0)" offset 1,-0.5
set zlabel "Z: Helical Axis (a_0)" offset 1,0
set xrange [-5.5:5.5]
set yrange [-5.5:5.5]
set zrange [-8.0:8.0]
set xyplane at -8.0
set view 68, 45, 1.15, 1.0

# Alpha helix geometry in atomic units
R_helix = 4.35  # ~2.3 Angstrom backbone radius
pitch   = 10.2  # ~5.4 Angstrom per turn
z_total = 14.0  # Height of two complete turns

# 1. Helical Backbone Main Chain Tube
# u sweeps over parameter t in [0, 4*pi] (two turns)
u_norm(u) = u / (2.0 * pi) # 0 to 1
t_helix(u) = 4.0 * pi * (u_norm(u) - 0.5) # -2pi to +2pi
z_main(u)  = (pitch / (2.0 * pi)) * t_helix(u)
x_center(u) = R_helix * cos(t_helix(u))
y_center(u) = R_helix * sin(t_helix(u))

r_tube = 0.38
x_backbone(u, v) = x_center(u) + r_tube * cos(v) * cos(t_helix(u))
y_backbone(u, v) = y_center(u) + r_tube * cos(v) * sin(t_helix(u))
z_backbone(u, v) = z_main(u) + r_tube * sin(v)

# 2. Longitudinal Hydrogen Bond Flux Bridges (i -> i+4)
# Between turn 1 (t ~ -pi) and turn 2 (t ~ +pi)
x_hb1(u, v) = R_helix * 0.82 * cos(-pi/2.0) + 0.22 * sin(u_norm(u)*pi) * cos(v)
y_hb1(u, v) = R_helix * 0.82 * sin(-pi/2.0) + 0.22 * sin(u_norm(u)*pi) * sin(v)
z_hb1(u, v) = -pitch/2.0 + u_norm(u) * pitch

x_hb2(u, v) = R_helix * 0.82 * cos(pi/2.0) + 0.22 * sin(u_norm(u)*pi) * cos(v)
y_hb2(u, v) = R_helix * 0.82 * sin(pi/2.0) + 0.22 * sin(u_norm(u)*pi) * sin(v)
z_hb2(u, v) = -pitch/2.0 + u_norm(u) * pitch + pitch/3.6

set style line 1 lc rgb "#185a9d" lw 1.6   # Blue: Helical peptide backbone
set style line 2 lc rgb "#d35400" dt 2 lw 1.4 # Dashed orange: C=O ... H-N hydrogen bond tubes

set label 1 "Peptide Main Chain (\\alpha-Helix)" at 0, 4.8, 5.0 center font "Sans-Bold,10" tc rgb "#185a9d"
set label 2 "C=O\\cdots H-N Hydrogen Bond Bridges (i \\rightarrow i+4)" at 0, -4.5, 0 center font "Sans-Bold,9" tc rgb "#d35400"

set key top right spacing 1.25 font "Sans,9.5"

splot x_backbone(u, v), y_backbone(u, v), z_backbone(u, v) with lines ls 1 title "Peptide Backbone (2 Turns)", \
      x_hb1(u, v), y_hb1(u, v), z_hb1(u, v) with lines ls 2 title "Longitudinal H-Bond Bridges (i \\rightarrow i+4)", \
      x_hb2(u, v), y_hb2(u, v), z_hb2(u, v) with lines ls 2 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
