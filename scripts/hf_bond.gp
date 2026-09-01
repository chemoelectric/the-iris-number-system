# Gnuplot script: 3D Wireframe Meshwork of Hydrogen Fluoride (HF) Chemical Bond
# Depicts the asymmetric polar covalent valence envelope and core structures on discrete grid G_N.
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

# Output terminal configuration: interactive window or file export
if (exists("OUTFILE")) {
    set terminal pngcairo size 1200,900 enhanced font "Sans,11"
    set output OUTFILE
} else {
    set terminal qt size 1000,800 enhanced font "Sans,11" persist
}

set title "Electromagnetic Structure of the Chemical Bond in Hydrogen Fluoride (HF)\n{/*0.85Asymmetric Polar Covalent Envelope and Nuclear Core Shells on Discrete Grid G_N}" font "Sans-Bold,12" offset 0,-0.5

# Enable 3D parametric plotting and wireframe meshwork
set parametric
set hidden3d
unset pm3d
set surface

# Mesh sampling density across parameter intervals
set isosamples 42, 54
set urange [0:pi]
set vrange [0:2*pi]

# Coordinate axes and ranges (in atomic units a_0: 1 a_0 ~ 0.529177 Angstrom)
set xlabel "X (a_0)" offset -1,-0.5
set ylabel "Y (a_0)" offset 1,-0.5
set zlabel "Z: Internuclear Axis (a_0)" offset 1,0
set xrange [-2.4:2.4]
set yrange [-2.4:2.4]
set zrange [-2.5:2.5]
set xyplane at -2.5

# Viewing angle for perspective along and across the bond axis
set view 68, 335, 1.15, 1.0

# Physical molecular parameters in atomic units:
# Equilibrium bond length R_e = 1.733 a_0 (~0.917 Angstrom)
z_F = -0.60    # Axial position of the Fluorine nucleus
z_H =  1.13    # Axial position of the Hydrogen proton
R_F =  1.32    # Fluorine valence radius (electronegative lobe and 2p lone-pair concentration)
R_H =  0.64    # Hydrogen valence screening radius

# Interpolation weight along the polar axis (u = 0 at H terminus, u = pi at F terminus)
w(u) = 0.5 * (1.0 - cos(u))

# Axial center of curvature across the bonding corridor
z_center(u) = z_H * (1.0 - w(u)) + z_F * w(u)

# Radial envelope function incorporating the covalent bonding waist
waist(u) = 1.0 - 0.14 * (sin(u)**2) * (1.0 - w(u))
R_eff(u) = (R_H * (1.0 - w(u)) + R_F * w(u)) * waist(u)

# 1. Outer polarized valence bonding envelope
x_val(u, v) = R_eff(u) * sin(u) * cos(v)
y_val(u, v) = R_eff(u) * sin(u) * sin(v)
z_val(u, v) = z_center(u) + R_eff(u) * cos(u)

# 2. Inner core electron shell at Fluorine (1s^2 tight localization)
r_F_core = 0.35
x_core_F(u, v) = r_F_core * sin(u) * cos(v)
y_core_F(u, v) = r_F_core * sin(u) * sin(v)
z_core_F(u, v) = z_F + r_F_core * cos(u)

# 3. Proton locus at Hydrogen
r_H_core = 0.15
x_core_H(u, v) = r_H_core * sin(u) * cos(v)
y_core_H(u, v) = r_H_core * sin(u) * sin(v)
z_core_H(u, v) = z_H + r_H_core * cos(u)

# Distinct wireframe mesh styles (no surface shading)
set style line 1 lc rgb "#1b4d89" lw 1.0  # Blue mesh: Valence bonding envelope
set style line 2 lc rgb "#c0392b" lw 1.2  # Red mesh: Fluorine core shell
set style line 3 lc rgb "#27ae60" lw 1.2  # Green mesh: Hydrogen proton locus

# Molecular annotations and physical properties
set label 1 "F (Z=9, {/Symbol d}^-)" at 0, 0, z_F-0.55 center font "Sans-Bold,10" tc rgb "#1b4d89"
set label 2 "H (Z=1, {/Symbol d}^+)" at 0, 0, z_H+0.45 center font "Sans-Bold,10" tc rgb "#27ae60"
set label 3 "Dipole Moment: {/Symbol m} = 1.82 D\nEquilibrium Bond Length: R_e = 0.917 {\305} (1.733 a_0)" at -2.1, 1.8, 2.0 font "Sans,9" tc rgb "#333333"

# Render 3D wireframe meshworks
splot x_val(u, v), y_val(u, v), z_val(u, v) with lines ls 1 title "Valence Bond Envelope (Polar Covalent)", \
      x_core_F(u, v), y_core_F(u, v), z_core_F(u, v) with lines ls 2 title "Fluorine Core Shell (1s^2)", \
      x_core_H(u, v), y_core_H(u, v), z_core_H(u, v) with lines ls 3 title "Hydrogen Proton Locus"
