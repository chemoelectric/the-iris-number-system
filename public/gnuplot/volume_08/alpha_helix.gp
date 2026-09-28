# Gnuplot script: 3D High-Detail Wireframe Snapshot of Alpha-Helix Protein Backbone
# Depicts the discrete electromagnetic architecture of the polypeptide alpha-helix on G_N:
# - Helical peptide backbone cylindrical tube (radius R = 2.3 Angstrom, pitch = 5.4 Angstrom)
# - Longitudinal hydrogen bond electromagnetic flux bridges (i -> i+4 bonding network)
# - Axial electrostatic dipole moment alignment along the helical axis
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Electromagnetic Snapshot of Polypeptide \\alpha-Helix Secondary Structure\n{/*0.85Helical Main Chain and Longitudinal i \\rightarrow i+4 H-Bond Flux Bridges on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 44, 44
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X ({\305})" offset -1,-0.5
set ylabel "Y ({\305})" offset 1,-0.5
set zlabel "Z: Helix Axis ({\305})" offset 1,0
set xrange [-5.5:5.5]
set yrange [-5.5:5.5]
set zrange [-5.5:5.5]
set xyplane at -5.5
set view 68, 330, 1.15, 1.0

# Physical dimensions of standard alpha-helix (in Angstroms)
R_helix = 2.30
pitch   = 5.40
turns   = 2.2

# 1. Helical Backbone Main Chain Tube
u_norm(u)   = u / (2.0 * pi)
t_helix(u)  = (u_norm(u) - 0.5) * turns * 2.0 * pi
z_main(u)   = t_helix(u) * pitch / (2.0 * pi)
x_center(u) = R_helix * cos(t_helix(u))
y_center(u) = R_helix * sin(t_helix(u))

r_tube = 0.55
x_backbone(u, v) = x_center(u) + r_tube * cos(v) * cos(t_helix(u))
y_backbone(u, v) = y_center(u) + r_tube * cos(v) * sin(t_helix(u))
z_backbone(u, v) = z_main(u) + r_tube * sin(v)

# 2. 1D Longitudinal Hydrogen Bond Flux Bridges (i -> i+4)
set samples 80
set table $HB1
plot [t=0:1] (R_helix * 0.85 * cos(-pi/2.0)), (-pitch/2.0 + t * pitch)
unset table

set table $HB2
plot [t=0:1] (R_helix * 0.85 * cos(pi/2.0)), (-pitch/2.0 + t * pitch + pitch/3.6)
unset table

set table $HB3
plot [t=0:1] (R_helix * 0.85 * cos(0.0)), (-pitch/2.0 + t * pitch - pitch/3.6)
unset table

set style line 1 lc rgb "#002855" lw 1.6              # Blue: Helical peptide backbone
set style line 2 lc rgb "#78281f" dt (18, 12) lw 2.0  # Distinct Dashed Orange: C=O ... H-N hydrogen bond filaments

set label 1 "Peptide Main Chain (\\alpha-Helix)" at 0, 4.8, 5.0 center font "Sans-Bold,10" tc rgb "#002855"
set label 2 "C=O\\cdots H-N Hydrogen Bond Bridges (i \\rightarrow i+4)" at 0, -4.5, 0 center font "Sans-Bold,9" tc rgb "#78281f"

set key top right spacing 1.25 font "Sans,9.5"

splot x_backbone(u, v), y_backbone(u, v), z_backbone(u, v) with lines ls 1 title "Peptide Backbone (2 Turns)", \
      $HB1 using 1:(R_helix*0.85*sin(-pi/2.0)):2 with lines ls 2 title "Longitudinal H-Bond Bridges (i \\rightarrow i+4)", \
      $HB2 using 1:(R_helix*0.85*sin(pi/2.0)):2 with lines ls 2 notitle, \
      $HB3 using 1:(R_helix*0.85*sin(0.0)):2 with lines ls 2 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
