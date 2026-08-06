% MetaPost program: 3D depiction of the Electron in Cl(4,1,1)
% Iris Number System - Toroidal Plasmoid Field Topology and Spin Bivector

prologues := 3;
outputtemplate := "electron.mps";

verbatimtex
\documentclass{article}
\usepackage{amsmath,amssymb}
\begin{document}
etex;

beginfig(1);
  numeric u;
  u := 1.2cm;

  % 3D Projection parameters: (x, y, z) -> 2D plane
  primarycolor := (0.2, 0.4, 0.9); % Electric blue for electron
  secondarycolor := (0.8, 0.1, 0.1); % Red for spin/field vectors
  accentcolor := (0.1, 0.7, 0.3); % Green for bivector flux

  vardef proj(expr x, y, z) =
    (-0.707*x + 0.866*y)*u, (-0.408*x - 0.5*y + 0.913*z)*u
  enddef;

  % Torus parameters
  numeric R_major, r_minor;
  R_major := 2.2;
  r_minor := 0.7;

  % Draw background grid / reference coordinate axes
  drawarrow proj(0,0,0) -- proj(3.5,0,0) withpen pencircle scaled 0.7pt withcolor (0.6,0.6,0.6);
  label.llft(btex $x$ etex, proj(3.5,0,0));
  drawarrow proj(0,0,0) -- proj(0,3.5,0) withpen pencircle scaled 0.7pt withcolor (0.6,0.6,0.6);
  label.rt(btex $y$ etex, proj(0,3.5,0));
  drawarrow proj(0,0,0) -- proj(0,0,3.5) withpen pencircle scaled 1.2pt withcolor secondarycolor;
  label.top(btex $\mathbf{S} = \frac{1}{2}\hbar \, \mathbf{e}_3$ etex, proj(0,0,3.5));

  % Draw Torus latitudinal rings (cross sections)
  % Inner / rear torus loops (dashed)
  for phi = 90 step 22.5 until 270:
    path c_ring;
    c_ring := proj( (R_major + r_minor*cosd(0))*cosd(phi), (R_major + r_minor*cosd(0))*sind(phi), r_minor*sind(0) );
    for theta = 15 step 15 until 360:
      c_ring := c_ring -- proj( (R_major + r_minor*cosd(theta))*cosd(phi), (R_major + r_minor*cosd(theta))*sind(phi), r_minor*sind(theta) );
    endfor;
    draw c_ring dashed withdots scaled 0.6 withpen pencircle scaled 0.5pt withcolor (0.5,0.5,0.7);
  endfor;

  % Front torus loops (solid)
  for phi = -78.75 step 22.5 until 78.75:
    path c_ring;
    c_ring := proj( (R_major + r_minor*cosd(0))*cosd(phi), (R_major + r_minor*cosd(0))*sind(phi), r_minor*sind(0) );
    for theta = 15 step 15 until 360:
      c_ring := c_ring -- proj( (R_major + r_minor*cosd(theta))*cosd(phi), (R_major + r_minor*cosd(theta))*sind(phi), r_minor*sind(theta) );
    endfor;
    draw c_ring withpen pencircle scaled 0.6pt withcolor primarycolor;
  endfor;

  % Longitudinal ring circles (parallel to x-y plane)
  for theta = 0 step 45 until 315:
    path phi_ring_back, phi_ring_front;
    phi_ring_back := proj( (R_major + r_minor*cosd(theta))*cosd(90), (R_major + r_minor*cosd(theta))*sind(90), r_minor*sind(theta) );
    for phi = 105 step 15 until 270:
      phi_ring_back := phi_ring_back -- proj( (R_major + r_minor*cosd(theta))*cosd(phi), (R_major + r_minor*cosd(theta))*sind(phi), r_minor*sind(theta) );
    endfor;
    draw phi_ring_back dashed withdots scaled 0.6 withpen pencircle scaled 0.5pt withcolor (0.5,0.5,0.7);

    phi_ring_front := proj( (R_major + r_minor*cosd(theta))*cosd(-90), (R_major + r_minor*cosd(theta))*sind(-90), r_minor*sind(theta) );
    for phi = -75 step 15 until 90:
      phi_ring_front := phi_ring_front -- proj( (R_major + r_minor*cosd(theta))*cosd(phi), (R_major + r_minor*cosd(theta))*sind(phi), r_minor*sind(theta) );
    endfor;
    draw phi_ring_front withpen pencircle scaled 0.8pt withcolor primarycolor;
  endfor;

  % Draw circulating Bivector Field Circulation Arrow
  path b_circ;
  b_circ := proj( (R_major+1.1)*cosd(-60), (R_major+1.1)*sind(-60), 0 );
  for phi = -45 step 15 until 60:
    b_circ := b_circ -- proj( (R_major+1.1)*cosd(phi), (R_major+1.1)*sind(phi), 0 );
  endfor;
  drawarrow b_circ withpen pencircle scaled 1.2pt withcolor accentcolor;
  label.rt(btex $\mathbf{B} = \nabla \times \mathbf{A}$ etex, proj((R_major+1.2)*cosd(30), (R_major+1.2)*sind(30), 0));

  % Center node and charge annotation
  fill fullcircle scaled 6pt shifted proj(0,0,0) withcolor primarycolor;
  label.lft(btex $e^-$ ($q = -1$) etex, proj(-0.3, -0.3, 0.2));
  label.bot(btex \textbf{Electron Toroidal Plasmoid} ($Cl(4,1,1)$) etex, proj(0, -3.2, -2.2));

endfig;
end.
