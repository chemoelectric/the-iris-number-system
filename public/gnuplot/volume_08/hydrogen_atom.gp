# Gnuplot script: 3D High-Detail Wireframe Snapshot of Hydrogen Atom (1s Orbit)
# Depicts the discrete electromagnetic architecture of the ground-state Hydrogen atom on G_N:
# - Central proton potential well / toroidal locus at origin
# - Localized 1s electron current vortex (soliton) at the Bohr radius r = 1.0 a_0
# - Mutually interlocking magnetic flux lines linking electron and proton
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Electromagnetic Snapshot of Ground-State Hydrogen Atom (^1H)\n{/*0.851s Electron Vortex Soliton and Central Proton Well on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

set parametric
set hidden3d
unset pm3d
set surface

set isosamples 44, 44
set urange [0:2*pi]
set vrange [0:2*pi]

set xlabel "X (a_0)" offset -1,-0.5
set ylabel "Y (a_0)" offset 1,-0.5
set zlabel "Z (a_0)" offset 1,0
set xrange [-1.8:1.8]
set yrange [-1.8:1.8]
set zrange [-1.5:1.5]
set xyplane at -1.5
set view 68, 325, 1.25, 1.0

# Fundamental length unit: Bohr radius a_0 = 1.0
r_bohr = 1.0

# 1. Central Proton Core Potential Well at Origin (r = 0.18 a_0)
r_prot = 0.18
x_prot(u, v) = r_prot * sin(u/2.0) * cos(v)
y_prot(u, v) = r_prot * sin(u/2.0) * sin(v)
z_prot(u, v) = r_prot * cos(u/2.0)

# 2. Localized 1s Electron Vortex Soliton (Toroid centered at x = r_bohr, y = 0, z = 0)
R_e = 0.32
r_e = 0.14
x_elec(u, v) = r_bohr + (R_e + r_e * cos(v)) * cos(u)
y_elec(u, v) = (R_e + r_e * cos(v)) * sin(u)
z_elec(u, v) = r_e * sin(v)

# 3. 1D 1s Circular Bohr Orbit Track in the XY-Plane (r = 1.0 a_0)
set samples 120
set table $BOHR_TRACK
plot [t=0:2*pi] r_bohr * cos(t), r_bohr * sin(t)
unset table

# 4. Interlocking Dipolar Magnetic Flux Lines Connecting Proton and Electron
u_n(u) = u / (2.0 * pi)

x_f1(u, v) = r_bohr * u_n(u)
y_f1(u, v) = 0.38 * sin(u_n(u) * pi) * cos(v)
z_f1(u, v) = 0.38 * sin(u_n(u) * pi) * sin(v)

x_f2(u, v) = r_bohr * u_n(u)
y_f2(u, v) = -0.38 * sin(u_n(u) * pi) * cos(v)
z_f2(u, v) = -0.38 * sin(u_n(u) * pi) * sin(v)

x_f3(u, v) = r_bohr * u_n(u)
y_f3(u, v) = 0.0
z_f3(u, v) = 0.45 * sin(u_n(u) * pi)

x_f4(u, v) = r_bohr * u_n(u)
y_f4(u, v) = 0.0
z_f4(u, v) = -0.45 * sin(u_n(u) * pi)

r_loop(u) = 0.60 * sin(u_n(u) * pi)
x_f5(u, v) = r_bohr + (0.50 * (1.0 - cos(u_n(u) * pi))) * 0.65
y_f5(u, v) = r_loop(u) * cos(pi/3.0)
z_f5(u, v) = r_loop(u) * sin(pi/3.0)

x_f6(u, v) = r_bohr + (0.50 * (1.0 - cos(u_n(u) * pi))) * 0.65
y_f6(u, v) = -r_loop(u) * cos(pi/3.0)
z_f6(u, v) = -r_loop(u) * sin(pi/3.0)

# Wireframe Line Styles
set style line 1 lc rgb "#185a9d" lw 1.5              # Deep blue: 1s electron current vortex
set style line 2 lc rgb "#c0392b" lw 1.5              # Red: Central proton locus
set style line 3 lc rgb "#444444" dt (18, 12) lw 1.8   # Distinct Dashed Dark Gray: 1s orbital track
set style line 4 lc rgb "#d35400" lw 1.2              # Orange: Electromagnetic flux filaments

set label 1 "Proton (p^+, Z=1)" at 0, 0, -0.28 center font "Sans-Bold,10" tc rgb "#c0392b"
set label 2 "Electron Vortex (e^-)" at r_bohr, 0, 0.42 center font "Sans-Bold,10" tc rgb "#185a9d"
set label 3 "Bohr Radius: a_0 = 0.529 {\305}" at 0.5, -0.2, -0.15 center font "Sans,9" tc rgb "#555555"
set label 4 "1s Orbit Track (r = a_0)" at -1.1, 0, -0.25 center font "Sans-Bold,8.5" tc rgb "#444444"

splot x_elec(u, v),  y_elec(u, v),  z_elec(u, v)  with lines ls 1 title "1s Electron Vortex Soliton (e^-)", \
      x_prot(u, v),  y_prot(u, v),  z_prot(u, v)  with lines ls 2 title "Proton Nuclear Locus (p^+)", \
      $BOHR_TRACK using 1:2:(0.0) with lines ls 3 title "1s Bohr Orbit Track (r = 1 a_0)", \
      x_f1(u, v),    y_f1(u, v),    z_f1(u, v)    with lines ls 4 title "Electromagnetic Flux Filaments", \
      x_f2(u, v),    y_f2(u, v),    z_f2(u, v)    with lines ls 4 notitle, \
      x_f3(u, v),    y_f3(u, v),    z_f3(u, v)    with lines ls 4 notitle, \
      x_f4(u, v),    y_f4(u, v),    z_f4(u, v)    with lines ls 4 notitle, \
      x_f5(u, v),    y_f5(u, v),    z_f5(u, v)    with lines ls 4 notitle, \
      x_f6(u, v),    y_f6(u, v),    z_f6(u, v)    with lines ls 4 notitle

if (!exists("OUTFILE")) {
    pause mouse close
}
