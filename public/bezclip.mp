% MetaPost illustration of the s-Power Bézier Clipping Algorithm
%
% This program demonstrates the constructive s-power Bézier clipping
% algorithm:
%   1. S-power basis curve representation and deviation vector derivation
%   2. Affine skeleton transformation mapping chord to the standard baseline
%   3. Optimal parallel fat-line slab construction
%   4. Algebraic quadratic boundary crossing solution (solving A*t^2 + B*t + C = 0)
%   5. Parameter interval pruning and quadratic deviation contraction:
%      P1_delta_new = (t_max - t_min)^2 * P1_delta
%   6. Deterministic convergence to the exact intersection point (x*, y*)
%
% To compile:
%   mpost --tex=latex bezclip.mp
%
% To convert figures to PNG:
%   magick bezclip-1.mps -flatten -bordercolor white -border 20 bezclip-1.png
%   magick bezclip-2.mps -flatten -bordercolor white -border 20 bezclip-2.png
%   magick bezclip-3.mps -flatten -bordercolor white -border 20 bezclip-3.png

filenametemplate "%j-%c.mps";
prologues := 3;

verbatimtex
\documentclass{article}
\usepackage{fouriernc}
\usepackage{amsmath,amssymb}
\begin{document}
etex;

% ======================================================================
% Color Palette & Styling Constants
% ======================================================================
color col_clipper, col_clippehend, col_skel, col_fatline, col_fatline_q;
color col_inter, col_box, col_discard;

col_clipper    := (0.80, 0.15, 0.15); % Deep Red
col_clippehend := (0.10, 0.55, 0.20); % Emerald Green
col_skel       := (0.15, 0.35, 0.85); % Royal Blue
col_fatline    := (0.88, 0.93, 1.00); % Faint Blue Fat-Line Band
col_fatline_q  := (0.88, 0.97, 0.90); % Faint Green Fat-Line Band
col_inter      := (0.05, 0.05, 0.05); % Pure Black
col_box        := (0.75, 0.60, 0.90); % Mutual Intersection Region
col_discard    := (0.75, 0.75, 0.75); % Discarded Region

% ======================================================================
% Helper Functions for s-Power Arithmetic in MetaPost
% ======================================================================

% Evaluate quadratic Bézier curve at parameter t in s-power basis:
% P(t) = (1-t)*P0 + t*P2 + (1-t)*t*P1_delta
vardef eval_spower(expr Pzero, Ptwo, Pdelta, t) =
  ((1 - t) * Pzero + t * Ptwo + (1 - t) * t * Pdelta)
enddef;

% Construct smooth MetaPost path from s-power representation
vardef spower_path(expr Pzero, Ptwo, Pdelta, steps) =
  eval_spower(Pzero, Ptwo, Pdelta, 0)
  for i = 1 upto steps:
    -- eval_spower(Pzero, Ptwo, Pdelta, i / steps)
  endfor
enddef;

% Affine Skeleton Transformation: Maps P0 -> (0,0) and P2 -> (1,0)
% For any point Q = (x, y):
%   v = P2 - P0 = (dx, dy)
%   L^2 = dx^2 + dy^2
%   x' = (dx*(x - x0) + dy*(y - y0)) / L^2
%   y' = (-dy*(x - x0) + dx*(y - y0)) / L^2
vardef skel_transform(expr Pzero, Ptwo, Q) =
  save dx, dy, Lsq, rx, ry;
  dx := xpart(Ptwo - Pzero);
  dy := ypart(Ptwo - Pzero);
  Lsq := dx * dx + dy * dy;
  rx := xpart(Q - Pzero);
  ry := ypart(Q - Pzero);
  ((dx * rx + dy * ry) / Lsq, (-dy * rx + dx * ry) / Lsq)
enddef;

% ======================================================================
% FIGURE 1: Global Geometry & Optimal Fat-Line Slabs
% ======================================================================
beginfig(1);
  save u, P, Q, P_delta, Q_delta;
  u := 1.6cm;

  % Control points for Clipper P (Degree 2)
  pair P[];
  P0 := (-1u, 0u);
  P1 := (0u, 10u);
  P2 := (1u, 0u);

  % Control points for Clippehend Q (Degree 2)
  pair Q[];
  Q0 := (2u, 1u);
  Q1 := (-8u, 2u);
  Q2 := (2u, 3u);

  % Compute exact s-Power Deviation Vectors:
  %   P1^Delta = 2*P1 - P0 - P2
  %   Q1^Delta = 2*Q1 - Q0 - Q2
  pair P_delta, Q_delta;
  P_delta := 2 * P1 - P0 - P2;  % = (0, 20u)
  Q_delta := 2 * Q1 - Q0 - Q2;  % = (-20u, 0)

  % Optimal Fat-Line bounds for Clipper P:
  % In world coordinates, P0--P2 is along y=0. Apex is at y = 5u (d_y / 4 = 20u / 4).
  % Band spans y in [0, 5u], extended horizontally across the viewport:
  path fatline_P_slab;
  fatline_P_slab := (-3.5u, 0u) -- (3.5u, 0u) -- (3.5u, 5u) -- (-3.5u, 5u) -- cycle;
  fill fatline_P_slab withcolor col_fatline;

  % Optimal Fat-Line bounds for Clippehend Q:
  % Skeleton Q0--Q2 is along x = 2u. Apex is at x = -3u (d_x / 4 = -20u / 4 = -5u).
  % Band spans x in [-3u, 2u], extended vertically:
  path fatline_Q_slab;
  fatline_Q_slab := (-3u, -0.5u) -- (2u, -0.5u) -- (2u, 5.5u) -- (-3u, 5.5u) -- cycle;
  fill fatline_Q_slab withcolor col_fatline_q;

  % Mutual Fat-Line Overlap Region: [-3u, 2u] x [0u, 5u]
  path overlap_slab;
  overlap_slab := (-3u, 0u) -- (2u, 0u) -- (2u, 5u) -- (-3u, 5u) -- cycle;
  fill overlap_slab withcolor 0.5[col_fatline, col_fatline_q];
  draw overlap_slab dashed evenly scaled 0.7 withpen pencircle scaled 0.8pt withcolor (0.4, 0.4, 0.4);

  % Draw Fat-Line Boundary Lines for P:
  draw (-3.5u, 0u) -- (3.5u, 0u) withpen pencircle scaled 0.6pt withcolor col_skel;
  draw (-3.5u, 5u) -- (3.5u, 5u) dashed evenly withpen pencircle scaled 0.8pt withcolor col_clipper;

  % Draw Fat-Line Boundary Lines for Q:
  draw (2u, -0.5u) -- (2u, 5.5u) withpen pencircle scaled 0.6pt withcolor col_clippehend;
  draw (-3u, -0.5u) -- (-3u, 5.5u) dashed evenly withpen pencircle scaled 0.8pt withcolor col_clippehend;

  % Draw Skeletons:
  draw P0 -- P2 withpen pencircle scaled 1.2pt withcolor col_skel;
  draw Q0 -- Q2 withpen pencircle scaled 1.2pt withcolor (0.1, 0.4, 0.1);

  % Draw Deviation Vectors (s-power arrows from midpoint):
  pair midP, midQ;
  midP := 0.5[P0, P2];
  midQ := 0.5[Q0, Q2];
  drawarrow midP -- (midP + 0.25 * P_delta) withpen pencircle scaled 1.1pt withcolor (0.7, 0, 0);
  drawarrow midQ -- (midQ + 0.25 * Q_delta) withpen pencircle scaled 1.1pt withcolor (0, 0.5, 0);

  % Draw Quadratic Bézier Curves using s-power evaluator:
  path pathP, pathQ;
  pathP := spower_path(P0, P2, P_delta, 40);
  pathQ := spower_path(Q0, Q2, Q_delta, 40);

  draw pathP withpen pencircle scaled 1.6pt withcolor col_clipper;
  draw pathQ withpen pencircle scaled 1.6pt withcolor col_clippehend;

  % Draw Control Points:
  fill fullcircle scaled 4pt shifted P0 withcolor col_skel;
  fill fullcircle scaled 4pt shifted P2 withcolor col_skel;
  fill fullcircle scaled 4pt shifted P1 withcolor col_clipper;
  fill fullcircle scaled 4pt shifted Q0 withcolor col_clippehend;
  fill fullcircle scaled 4pt shifted Q2 withcolor col_clippehend;
  fill fullcircle scaled 4pt shifted Q1 withcolor col_clippehend;

  % Intersection Point: (x*, y*) = (0, 5u)
  pair P_inter;
  P_inter := (0u, 5u);
  fill fullcircle scaled 6pt shifted P_inter withcolor col_inter;
  draw fullcircle scaled 8pt shifted P_inter withpen pencircle scaled 0.8pt withcolor white;

  % Text Labels:
  label.bot(btex $P_0(-1,0)$ etex, P0 shifted (0, -2pt));
  label.bot(btex $P_2(1,0)$ etex, P2 shifted (0, -2pt));
  label.top(btex $P_1(0,10)$ etex, P1 shifted (0, 2pt));
  label.rt(btex $Q_0(2,1)$ etex, Q0 shifted (3pt, 0));
  label.rt(btex $Q_2(2,3)$ etex, Q2 shifted (3pt, 0));
  label.lft(btex $Q_1(-8,2)$ etex, Q1 shifted (-3pt, 0));

  label.top(btex $\mathbf{P}(t)$ [Clipper] etex, eval_spower(P0, P2, P_delta, 0.25) shifted (-14pt, 6pt));
  label.bot(btex $\mathbf{Q}(t)$ [Clippehend] etex, eval_spower(Q0, Q2, Q_delta, 0.8) shifted (18pt, -6pt));

  label.rt(btex $\frac{1}{4} P_1^\Delta = (0, 5)$ etex, (midP + 0.25 * P_delta) shifted (4pt, -4pt));
  label.top(btex $\frac{1}{4} Q_1^\Delta = (-5, 0)$ etex, (midQ + 0.25 * Q_delta) shifted (-8pt, 3pt));

  label.top(btex $(x^*, y^*) = (0, 5)$ etex, P_inter shifted (0, 6pt));
  label.lft(btex \small $\text{Fat-Line } F_P: y \in [0, 5]$ etex, (-3.5u, 2.5u));
  label.bot(btex \small $\text{Fat-Line } F_Q: x \in [-3, 2]$ etex, (-0.5u, -0.5u));

  currentpicture := currentpicture scaled 1.0;
endfig;

% ======================================================================
% FIGURE 2: Skeleton Coordinate Projection & Distance Polynomial
% ======================================================================
beginfig(2);
  save u, w, h, origin_pt;
  w := 8.0cm;
  h := 4.5cm;

  % Axes for Parameter Space: t in [0, 1] on X-axis, d_y'(t) on Y-axis
  pair origin_pt;
  origin_pt := (0, 0);

  % Draw background Fat-Line Band [d_min, d_max] = [0, 2.5]
  % Scale: t=0 -> x=0, t=1 -> x=w. d=0 -> y=0, d=2.5 -> y=h*(2.5/3.0)
  numeric y_max_val, y_scale, t_scale;
  y_max_val := 3.0;
  y_scale   := h / y_max_val;
  t_scale   := w;

  path fatline_strip;
  fatline_strip := (0, 0) -- (w, 0) -- (w, 2.5 * y_scale) -- (0, 2.5 * y_scale) -- cycle;
  fill fatline_strip withcolor col_fatline;

  % Draw Coordinate Axes:
  drawarrow (-0.5cm, 0) -- (w + 0.8cm, 0) withpen pencircle scaled 1.0pt;
  drawarrow (0, -0.5cm) -- (0, h + 0.5cm) withpen pencircle scaled 1.0pt;

  label.rt(btex Parameter $t \in [0, 1]$ etex, (w + 0.8cm, 0));
  label.top(btex Transformed Distance $y'(t)$ etex, (0, h + 0.5cm));

  % Fat-Line Boundary threshold lines:
  draw (0, 2.5 * y_scale) -- (w, 2.5 * y_scale) dashed evenly withpen pencircle scaled 0.9pt withcolor col_clipper;
  label.rt(btex $d_{\max} = \frac{d_y}{4} = 2.5$ etex, (w, 2.5 * y_scale));
  label.lft(btex $d_{\min} = 0.0$ etex, (0, 0));

  % Plot Clipper Parabola d_P(t) = 10 * t * (1 - t) in skeleton coordinates
  path plot_P;
  plot_P := (0, 0)
    for i = 1 upto 50:
      hide(numeric tt, yy; tt := i / 50; yy := 10.0 * tt * (1.0 - tt);)
      -- (tt * t_scale, yy * y_scale)
    endfor;
  draw plot_P withpen pencircle scaled 1.4pt withcolor col_clipper;
  label.top(btex $d_P(t) = (1-t)t d_y$ etex, (0.5 * t_scale, 2.5 * y_scale + 4pt));

  % Plot Clippehend Distance Polynomial Q_y'(t) = 0.5 + 1.0*t
  path plot_Q;
  plot_Q := (0, 0.5 * y_scale) -- (w, 1.5 * y_scale);
  draw plot_Q withpen pencircle scaled 1.5pt withcolor col_clippehend;
  label.rt(btex $Q_y'(t) = (1-t)Q_{0,y}' + t Q_{2,y}' + (1-t)t {Q_{1,y}'}^\Delta = 0.5 + t$ etex, (w, 1.5 * y_scale));

  % Quadratic Root Intersections:
  % Q_y'(t) enters at t = -0.5 (outside [0,1]) and exits at t = 2.0 (outside [0,1])
  % For all t in [0,1], Q_y'(t) in [0.5, 1.5] subset [0, 2.5]
  % Highlight the active parameter range [0, 1] preserved without trimming:
  draw (0, -4pt) -- (0, 4pt) withpen pencircle scaled 1.2pt;
  draw (w, -4pt) -- (w, 4pt) withpen pencircle scaled 1.2pt;
  label.bot(btex $t=0$ etex, (0, -4pt));
  label.bot(btex $t=1$ etex, (w, -4pt));

  % Draw tick for apex at t = 0.5
  draw (0.5 * w, -3pt) -- (0.5 * w, 3pt) withpen pencircle scaled 0.8pt;
  label.bot(btex $t = \frac{1}{2}$ etex, (0.5 * w, -3pt));

  % Mark Intersection Point Parameter on Clipper at t = 0.5, d = 2.5
  fill fullcircle scaled 5pt shifted (0.5 * w, 2.5 * y_scale) withcolor col_inter;
  label.top(btex Exact Apex Crossing $t_P^* = 0.5$ etex, (0.5 * w, 2.5 * y_scale + 12pt));

  currentpicture := currentpicture scaled 1.0;
endfig;

% ======================================================================
% FIGURE 3: s-Power Reparameterization & Quadratic Contraction
% ======================================================================
beginfig(3);
  save u, P, Q, P_sub_zero, P_sub_two, P_sub_delta;
  u := 1.8cm;

  % Original Curve Endpoints
  pair Pzero, Ptwo, Pdelta;
  Pzero  := (-1.5u, 0u);
  Ptwo   := (1.5u, 0u);
  Pdelta := (0u, 16u);

  % Draw full original curve (faint)
  path path_full;
  path_full := spower_path(Pzero, Ptwo, Pdelta, 40);
  draw path_full dashed evenly withpen pencircle scaled 0.8pt withcolor (0.7, 0.7, 0.7);
  draw Pzero -- Ptwo dashed withdots scaled 0.8 withpen pencircle scaled 0.6pt withcolor (0.6, 0.6, 0.6);

  % Sub-interval [t0, t1] = [0.35, 0.65] (Span Delta_t = 0.30)
  numeric tzero, tone, Dt;
  tzero := 0.35;
  tone  := 0.65;
  Dt    := tone - tzero; % = 0.30

  % New s-Power Control Parameters for Subdivided Segment:
  %   P0_new = P(t0)
  %   P2_new = P(t1)
  %   P1_delta_new = (Delta_t)^2 * P1_delta
  pair P_sub_zero, P_sub_two, P_sub_delta;
  P_sub_zero  := eval_spower(Pzero, Ptwo, Pdelta, tzero);
  P_sub_two   := eval_spower(Pzero, Ptwo, Pdelta, tone);
  P_sub_delta := (Dt * Dt) * Pdelta; % Deviation shrinks by (0.3)^2 = 0.09 !

  % Subdivided Skeleton:
  draw P_sub_zero -- P_sub_two withpen pencircle scaled 1.2pt withcolor col_skel;

  % Subdivided Fat-Line Slab:
  pair skel_mid, sub_apex;
  skel_mid := 0.5[P_sub_zero, P_sub_two];
  sub_apex := skel_mid + 0.25 * P_sub_delta;

  drawarrow skel_mid -- sub_apex withpen pencircle scaled 1.1pt withcolor (0.8, 0.1, 0.1);
  label.rt(btex \small $P_1^{\Delta,\text{new}} = (\Delta t)^2 P_1^\Delta$ etex, sub_apex shifted (4pt, 0));

  % Draw Subdivided Curve (active clipped portion):
  path path_sub;
  path_sub := spower_path(P_sub_zero, P_sub_two, P_sub_delta, 30);
  draw path_sub withpen pencircle scaled 2.0pt withcolor col_clipper;

  % Endpoints of Sub-curve:
  fill fullcircle scaled 4pt shifted P_sub_zero withcolor col_skel;
  fill fullcircle scaled 4pt shifted P_sub_two withcolor col_skel;

  label.bot(btex $P(t_0)$ etex, P_sub_zero shifted (-4pt, -3pt));
  label.bot(btex $P(t_1)$ etex, P_sub_two shifted (4pt, -3pt));

  % Annotations illustrating Quadratic Convergence:
  label.top(btex \bfseries Quadratic Deviation Contraction in $s$-Power Basis etex, (0, 4.5u));
  label.bot(btex $\Delta t = t_1 - t_0 = 0.30 \implies (\Delta t)^2 = 0.09 \implies 91\%$ Flattening Reduction etex, (0, -0.6u));

  currentpicture := currentpicture scaled 1.0;
endfig;

end.
