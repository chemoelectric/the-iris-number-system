# Gnuplot: 3D High-Detail Wireframe Snapshot of Helium-4 Nucleus (Alpha Particle)
# Depicts the discrete electromagnetic architecture of the 4He nucleus on G_N:
# - Two coaxial, counter-circulating proton-neutron toroidal pairs in tight magnetic contact
# - Interlocking toroidal geometry forming an extraordinarily stable, closed-flux magnetic plasmoid kernel
# - Zero external magnetic dipole moment due to exact antiparallel flux cancellation
# Pure wireframe meshwork with hidden-line removal; no surface shading.

reset

if (exists("OUTFILE")) {
    set terminal pngcairo size 1800,1400 font "Sans,12"
    set output OUTFILE
}

set title "Nuclear Structure Snapshot: Helium-4 (^4He Alpha Kernel, Z=2, A=4)\n{/*0.85Coaxial Interlocking Toroidal Magnetic Plasmoid on Discrete Grid G_N}" font "Sans-Bold,13" offset 0,-0.5

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
set zrange [-2.2:2.2]
set xyplane at -2.2
set view 64, 330, 1.25, 1.0

# Dual Coaxial Toroids (Protonic Ring and Neutronic Screening Sheath)
R_maj = 0.95
r_min = 0.32
z_sep = 0.45

# Upper Ring (Proton-Neutron Pair 1, +Z offset)
x_top(u, v) = (R_maj + r_min * cos(v)) * cos(u)
y_top(u, v) = (R_maj + r_min * cos(v)) * sin(u)
z_top(u, v) =  z_sep + r_min * sin(v)

# Lower Ring (Proton-Neutron Pair 2, -Z offset, counter-circulating)
x_bot(u, v) = (R_maj + r_min * cos(v)) * cos(u)
y_bot(u, v) = (R_maj + r_min * cos(v)) * sin(u)
z_bot(u, v) = -z_sep + r_min * sin(v)

# Interlocking Central Magnetic Vortex Throat (Connecting both rings)
r_throat(u) = 0.42 + 0.12 * cos(u)
u_n(u) = u / (2.0 * pi)
z_th(u) = -z_sep + 2.0 * z_sep * u_n(u)

x_throat(u, v) = (0.45 * (1.0 + 0.3*cos(v))) * cos(u)
y_throat(u, v) = (0.45 * (1.0 + 0.3*cos(v))) * sin(u)
z_throat(u, v) = 0.85 * sin(v)

# Inter-ring Magnetic Binding Flux Tube (Equatorial Cinch)
R_cinch = 1.35
r_cinch = 0.12
x_cinch(u, v) = (R_cinch + r_cinch * cos(v)) * cos(u)
y_cinch(u, v) = (R_cinch + r_cinch * cos(v)) * sin(u)
z_cinch(u, v) = r_cinch * sin(v)

# Wireframe Line Styles
set style line 1 lc rgb "#c0392b" lw 1.5   # Crimson: Upper proton-neutron current toroid
set style line 2 lc rgb "#2980b9" lw 1.5   # Blue: Lower counter-circulating toroid
set style line 3 lc rgb "#27ae60" lw 1.3   # Green: Interlocking axial vortex throat
set style line 4 lc rgb "#e67e22" dt 2 lw 1.0 # Amber dashed: Equatorial magnetic cinch sheath

set label 1 "Upper Toroid (+Z)" at 0, 0, 1.15 center font "Sans-Bold,9.5" tc rgb "#c0392b"
set label 2 "Lower Toroid (-Z)" at 0, 0, -1.15 center font "Sans-Bold,9.5" tc rgb "#2980b9"
set label 3 "Axial Vortex Throat" at 0, 1.1, 0.0 center font "Sans,9" tc rgb "#27ae60"
set label 4 "Equatorial Magnetic Cinch" at 1.4, -0.6, -0.2 center font "Sans,8.5" tc rgb "#e67e22"

splot x_top(u, v),    y_top(u, v),    z_top(u, v)    with lines ls 1 title "Upper Toroidal Sub-Ring (p_1-n_1)", \
      x_bot(u, v),    y_bot(u, v),    z_bot(u, v)    with lines ls 2 title "Lower Toroidal Sub-Ring (p_2-n_2)", \
      x_throat(u, v), y_throat(u, v), z_throat(u, v) with lines ls 3 title "Axial Recirculating Vortex Throat", \
      x_cinch(u, v),  y_cinch(u, v),  z_cinch(u, v)  with lines ls 4 title "Equatorial Magnetic Confinement Cinch"

if (!exists("OUTFILE")) {
    pause mouse close
}
