% MetaPost program: 3D depiction of the Proton in Cl(4,1,1)
% Iris Number System - Dense Knotted Tri-Vortex Core and Positive Charge Distribution

prologues := 3;
outputtemplate := "proton.mps";

verbatimtex
\documentclass{article}
\usepackage{amsmath,amssymb}
\begin{document}
etex;

beginfig(1);
  numeric u;
  u := 1.2cm;

  primarycolor := (0.85, 0.15, 0.15); % Deep red for positive proton core
  secondarycolor := (0.95, 0.55, 0.1); % Gold/orange for inner field knots
  accentcolor := (0.1, 0.4, 0.85);    % Blue for field circulation

  vardef proj(expr x, y, z) =
    (-0.707*x + 0.866*y)*u, (-0.408*x - 0.5*y + 0.913*z)*u
  enddef;

  % Coordinate axes
  drawarrow proj(0,0,0) -- proj(3.5,0,0) withpen pencircle scaled 0.7pt withcolor (0.6,0.6,0.6);
  label.llft(btex $x$ etex, proj(3.5,0,0));
  drawarrow proj(0,0,0) -- proj(0,3.5,0) withpen pencircle scaled 0.7pt withcolor (0.6,0.6,0.6);
  label.rt(btex $y$ etex, proj(0,3.5,0));
  drawarrow proj(0,0,0) -- proj(0,0,3.8) withpen pencircle scaled 1.3pt withcolor primarycolor;
  label.top(btex $\mathbf{S} = \frac{1}{2}\hbar \, \mathbf{e}_3$ etex, proj(0,0,3.8));

  % Outer spherical boundary / shell
  numeric r_core, r_outer;
  r_core := 1.2;
  r_outer := 2.5;

  % Draw outer field shell contours
  path equator;
  equator := proj(r_outer*cosd(0), r_outer*sind(0), 0);
  for phi = 10 step 10 until 360:
    equator := equator -- proj(r_outer*cosd(phi), r_outer*sind(phi), 0);
  endfor;
  draw equator withpen pencircle scaled 0.8pt withcolor secondarycolor;

  path meridian_front;
  meridian_front := proj(0, r_outer*cosd(-90), r_outer*sind(-90));
  for theta = -80 step 10 until 90:
    meridian_front := meridian_front -- proj(0, r_outer*cosd(theta), r_outer*sind(theta));
  endfor;
  draw meridian_front withpen pencircle scaled 0.8pt withcolor secondarycolor;

  % Inner Dense Nucleonic Core (Knotted Tri-Vortex)
  path core_knot;
  core_knot := proj(r_core*cosd(0), r_core*sind(0), 0.3*sind(0));
  for t = 10 step 10 until 360:
    core_knot := core_knot -- proj(r_core*cosd(t) + 0.4*sind(3*t), r_core*sind(t) + 0.4*cosd(3*t), 0.5*sind(2*t));
  endfor;
  fill core_knot withcolor (1.0, 0.85, 0.85);
  draw core_knot withpen pencircle scaled 1.5pt withcolor primarycolor;

  % Recirculating magnetic bivector field loops
  for ang = 30 step 120 until 300:
    path loop_b;
    loop_b := proj(0,0,0);
    for t = 0 step 15 until 180:
      numeric rad, z_val;
      rad := r_outer * sind(t);
      z_val := r_outer * cosd(t);
      loop_b := loop_b -- proj(rad*cosd(ang), rad*sind(ang), z_val);
    endfor;
    draw loop_b withpen pencircle scaled 0.7pt withcolor accentcolor;
  endfor;

  % Central high-density marker
  fill fullcircle scaled 8pt shifted proj(0,0,0) withcolor primarycolor;
  label.rt(btex $p^+$ ($q = +1$) etex, proj(0.2, 0.2, 0.3));
  label.bot(btex \textbf{Proton Knotted Tri-Vortex Core} ($m_p/m_e \approx 1836.15$) etex, proj(0, -3.2, -2.2));

endfig;
end.
