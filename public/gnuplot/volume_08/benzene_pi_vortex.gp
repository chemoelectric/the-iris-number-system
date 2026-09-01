# Gnuplot script: 3D High-Detail Close-Up Wireframe of Benzene (C6H6) Pi-Electron Vortex Sheets
# Depicts the instantaneous electromagnetic architecture on G_N:
# - Hexagonal Carbon-Carbon sigma bonding framework
# - Upper and Lower Delocalized Pi-Electron Toroidal Current Vortex Sheets
# - Six peripheral Carbon-Hydrogen sigma bond spines
# Pure wireframe meshwork with hidden-line removal. No surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Delocalized \\pi-Electron Ring Currents in Benzene (C_6H_6)\n{/*0.85Toroidal Vortex Sheets and Hexagonal \\sigma-Framework on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 44, 44
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X (a_0)" offset -1,-0.5
set ylabel "Y (a_0)" offset 1,-0.5
set zlabel "Z: Perpendicular to Ring (a_0)" offset 1,0
set xrange [-3.5:3.5]
set yrange [-3.5:3.5]
set zrange [-2.2:2.2]
set xyplane at -2.2
set view 64, 40, 1.15, 1.0

# Geometry Constants (Atomic Units: 1 a_0 ~ 0.529 A)
# C-C bond length = 2.64 a_0 (1.397 A) -> Ring radius R_C = 2.64 a_0
# C-H bond length = 2.05 a_0 (1.084 A) -> Total radius R_H = 4.69 a_0
R_C = 2.64
R_H = 4.69
z_pi = 0.75  # Height of pi-electron cloud maxima above/below the ring plane

# 1. Delocalized Pi-Electron Toroid (Upper Layer at +z_pi)
r_pi_maj = 2.64
r_pi_min = 0.55
x_pi_up(u, v) = (r_pi_maj + r_pi_min * cos(v)) * cos(u)
y_pi_up(u, v) = (r_pi_maj + r_pi_min * cos(v)) * sin(u)
z_pi_up(u, v) = z_pi + r_pi_min * sin(v)

# 2. Delocalized Pi-Electron Toroid (Lower Layer at -z_pi)
x_pi_dn(u, v) = (r_pi_maj + r_pi_min * cos(v)) * cos(u)
y_pi_dn(u, v) = (r_pi_maj + r_pi_min * cos(v)) * sin(u)
z_pi_dn(u, v) = -z_pi + r_pi_min * sin(v)

# 3. Hexagonal Carbon Frame Tube (Continuous parametric toroid framing the 6 vertices)
r_sig = 0.22
# Modulation creating hexagonal corners
r_hex(u) = R_C * (cos(pi/6.0) / cos(u - (2.0*pi/6.0)*floor((6.0*u + pi)/(2.0*pi))))

x_frame(u, v) = (r_hex(u) + r_sig*cos(v)) * cos(u)
y_frame(u, v) = (r_hex(u) + r_sig*cos(v)) * sin(u)
z_frame(u, v) = r_sig*sin(v)

# 4. Six Peripheral C-H Radial Sigma Bonds
u_n(u) = u / (2.0 * pi)
r_ch_tube(u) = 0.16 * sin(u_n(u)*pi)

x_ch(u, v, k) = (R_C + (R_H - R_C)*u_n(u)) * cos(k*pi/3.0) - r_ch_tube(u)*sin(v)*sin(k*pi/3.0)
y_ch(u, v, k) = (R_C + (R_H - R_C)*u_n(u)) * sin(k*pi/3.0) + r_ch_tube(u)*sin(v)*cos(k*pi/3.0)
z_ch(u, v)    = r_ch_tube(u)*cos(v)

# Line Styles
set style line 1 lc rgb "#8e44ad" lw 1.2 # Purple: Upper Pi-Electron Vortex Sheet
set style line 2 lc rgb "#2980b9" lw 1.2 # Blue: Lower Pi-Electron Vortex Sheet
set style line 3 lc rgb "#2c3e50" lw 1.5 # Dark Slate: Carbon-Carbon Sigma Hexagonal Frame
set style line 4 lc rgb "#27ae60" lw 1.1 # Green: C-H Radial Bonds

set label 1 "Upper \\pi-Vortex Ring (+z)" at 0, 0,  z_pi+0.85 center font "Sans-Bold,10" tc rgb "#8e44ad"
set label 2 "Lower \\pi-Vortex Ring (-z)" at 0, 0, -z_pi-0.85 center font "Sans-Bold,10" tc rgb "#2980b9"

splot x_pi_up(u, v), y_pi_up(u, v), z_pi_up(u, v) with lines ls 1 title "Upper \\pi-Electron Toroidal Vortex", \
      x_pi_dn(u, v), y_pi_dn(u, v), z_pi_dn(u, v) with lines ls 2 title "Lower \\pi-Electron Toroidal Vortex", \
      x_frame(u, v), y_frame(u, v), z_frame(u, v) with lines ls 3 title "C_6 Hexagonal \\sigma-Framework", \
      x_ch(u, v, 0), y_ch(u, v, 0), z_ch(u, v)   with lines ls 4 title "C-H \\sigma-Bond Spines", \
      x_ch(u, v, 1), y_ch(u, v, 1), z_ch(u, v)   with lines ls 4 notitle, \
      x_ch(u, v, 2), y_ch(u, v, 2), z_ch(u, v)   with lines ls 4 notitle, \
      x_ch(u, v, 3), y_ch(u, v, 3), z_ch(u, v)   with lines ls 4 notitle, \
      x_ch(u, v, 4), y_ch(u, v, 4), z_ch(u, v)   with lines ls 4 notitle, \
      x_ch(u, v, 5), y_ch(u, v, 5), z_ch(u, v)   with lines ls 4 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
