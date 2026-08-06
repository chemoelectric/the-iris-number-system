% MetaPost program: 3D depiction of the Neutron in Cl(4,1,1)
% Iris Number System - Composite Neutral Aperture (Proton Core + Electronic Ring-Sheath)

prologues := 3;
outputtemplate := "neutron.mps";

verbatimtex
\documentclass{article}
\usepackage{amsmath,amssymb}
\begin{document}
etex;

beginfig(1);
  numeric u;
  u := 1.2cm;

  corecolor := (0.85, 0.15, 0.15);    % Red for inner proton core
  sheathcolor := (0.2, 0.4, 0.9);     % Blue for tightly bound electronic sheath
  spincolor := (0.1, 0.7, 0.2);       % Green for total spin axis
  dipolecolor := (0.7, 0.1, 0.8);     % Purple for magnetic dipole moment

  vardef proj(expr x, y, z) =
    (-0.707*x + 0.866*y)*u, (-0.408*x - 0.5*y + 0.913*z)*u
  enddef;

  % Reference coordinate axes
  drawarrow proj(0,0,0) -- proj(3.5,0,0) withpen pencircle scaled 0.7pt withcolor (0.6,0.6,0.6);
  label.llft(btex $x$ etex, proj(3.5,0,0));
  drawarrow proj(0,0,0) -- proj(0,3.5,0) withpen pencircle scaled 0.7pt withcolor (0.6,0.6,0.6);
  label.rt(btex $y$ etex, proj(0,3.5,0));

  % Spin vector S (upward)
  drawarrow proj(0,0,0) -- proj(0,0,3.5) withpen pencircle scaled 1.3pt withcolor spincolor;
  label.top(btex $\mathbf{S} = \frac{1}{2}\hbar \, \mathbf{e}_3$ etex, proj(0,0,3.5));

  % Magnetic Dipole Moment mu_n (downward, anti-parallel to spin)
  drawarrow proj(0,0,0) -- proj(0,0,-3.0) withpen pencircle scaled 1.3pt withcolor dipolecolor;
  label.bot(btex $\boldsymbol{\mu}_n = -1.913 \, \mu_N \, \mathbf{e}_3$ etex, proj(0,0,-3.0));

  % Inner Proton Core (Sphere/Knot)
  numeric r_p;
  r_p := 1.1;
  path p_core;
  p_core := proj(r_p*cosd(0), r_p*sind(0), 0);
  for phi = 10 step 10 until 360:
    p_core := p_core -- proj(r_p*cosd(phi), r_p*sind(phi), 0);
  endfor;
  fill p_core withcolor (1.0, 0.85, 0.85);
  draw p_core withpen pencircle scaled 1.2pt withcolor corecolor;

  % Outer Electronic Ring-Sheath (Tight Subatomic Torus)
  numeric R_sheath, r_sheath;
  R_sheath := 1.8;
  r_sheath := 0.45;

  % Front sheath ring
  for phi = -80 step 20 until 80:
    path c_ring;
    c_ring := proj( (R_sheath + r_sheath*cosd(0))*cosd(phi), (R_sheath + r_sheath*cosd(0))*sind(phi), r_sheath*sind(0) );
    for theta = 15 step 15 until 360:
      c_ring := c_ring -- proj( (R_sheath + r_sheath*cosd(theta))*cosd(phi), (R_sheath + r_sheath*cosd(theta))*sind(phi), r_sheath*sind(theta) );
    endfor;
    draw c_ring withpen pencircle scaled 0.6pt withcolor sheathcolor;
  endfor;

  % Labels for components
  fill fullcircle scaled 6pt shifted proj(0,0,0) withcolor corecolor;
  label.rt(btex Proton Core ($+e$) etex, proj(0.1, 0.1, 0.4));
  label.lft(btex Electronic Sheath ($-e$) etex, proj(-1.6, 1.2, 0.2));

  label.bot(btex \textbf{Neutron Composite Aperture} ($q = +e - e = 0$) etex, proj(0, -3.2, -2.2));

endfig;
end.
