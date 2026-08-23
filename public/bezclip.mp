% MetaPost illustration of the s-Power Bézier Clipping Algorithm
%
% This program demonstrates the constructive s-power Bézier clipping
% algorithm on two light curving Bézier segments crossing at ~20 degrees:
%   1. S-power basis curve representation and deviation vector derivation
%   2. Affine skeleton transformation mapping chord to the standard baseline
%   3. Optimal parallel fat-line slab construction
%   4. Algebraic quadratic boundary crossing solution (solving A*t^2 + B*t + C = 0)
%   5. Parameter interval pruning and quadratic deviation contraction:
%      P1_delta_new = (t_max - t_min)^2 * P1_delta
%   6. Deterministic convergence to the exact intersection point (x*, y*)
%
% To compile:
%   mpost --tex=lualatex bezclip.mp
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
col_clippehend := (0.10, 0.55, 0.20); % Forest Green
col_skel       := (0.15, 0.35, 0.85); % Royal Blue
col_fatline    := (0.88, 0.93, 1.00); % Soft Blue Fat-Line Band
col_fatline_q  := (0.88, 0.97, 0.90); % Soft Green Fat-Line Band
col_inter      := (0.05, 0.05, 0.05); % Pure Black

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
% FIGURE 1: Gently Curving Segments Crossing at ~20° with Fat-Lines
% ======================================================================
beginfig(1);
  save u, P, Q, P_delta, Q_delta;
  u := 2.0cm;

  % Clipper Curve P: Gently curving upward, chord along horizontal
  pair P[];
  P0 := (-3.0u,  0.0u);
  P1 := ( 0.0u,  1.2u);
  P2 := ( 3.0u,  0.0u);

  % Clippehend Curve Q: Gently curving upward-right, chord inclined at ~20°
  % Crossing near center at ~20 degrees
  pair Q[];
  Q0 := (-3.0u, -0.63u);
  Q1 := ( 0.0u,  0.75u);
  Q2 := ( 3.0u,  1.53u);

  % Exact s-Power Deviation Vectors:
  %   P1^Delta = 2*P1 - P0 - P2 = (0, 2.4u)
  %   Q1^Delta = 2*Q1 - Q0 - Q2 = (0, 0.6u)
  pair P_delta, Q_delta;
  P_delta := 2 * P1 - P0 - P2;  % = (0, 2.4u)
  Q_delta := 2 * Q1 - Q0 - Q2;  % = (0, 0.6u)

  % Optimal Fat-Line bounds for Clipper P:
  % Skeleton is y = 0. Apex displacement is (1/4)*2.4u = 0.6u.
  % Bound is y in [0, 0.6u].
  path fatline_P_slab;
  fatline_P_slab := (-3.6u, 0.0u) -- (3.6u, 0.0u) -- (3.6u, 0.6u) -- (-3.6u, 0.6u) -- cycle;
  fill fatline_P_slab withcolor col_fatline;

  % Optimal Fat-Line bounds for Clippehend Q:
  % Skeleton chord vector v_Q = Q2 - Q0 = (6.0u, 2.16u)  (slope = 0.360 => 19.8 degrees)
  % Deviation apex offset from chord is (1/4)*Q_delta = (0, 0.15u)
  path fatline_Q_slab;
  fatline_Q_slab := (Q0 - 0.2*(Q2-Q0)) -- (Q2 + 0.2*(Q2-Q0))
                 -- (Q2 + 0.2*(Q2-Q0) + 0.25*Q_delta)
                 -- (Q0 - 0.2*(Q2-Q0) + 0.25*Q_delta) -- cycle;
  fill fatline_Q_slab withcolor col_fatline_q;

  % Draw Boundary Lines for P Fat-Line:
  draw (-3.6u, 0.0u) -- (3.6u, 0.0u) withpen pencircle scaled 0.6pt withcolor col_skel;
  draw (-3.6u, 0.6u) -- (3.6u, 0.6u) dashed evenly withpen pencircle scaled 0.8pt withcolor col_clipper;

  % Draw Boundary Lines for Q Fat-Line:
  draw (Q0 - 0.2*(Q2-Q0)) -- (Q2 + 0.2*(Q2-Q0)) withpen pencircle scaled 0.6pt withcolor col_clippehend;
  draw (Q0 - 0.2*(Q2-Q0) + 0.25*Q_delta) -- (Q2 + 0.2*(Q2-Q0) + 0.25*Q_delta)
       dashed evenly withpen pencircle scaled 0.8pt withcolor col_clippehend;

  % Draw Skeletons:
  draw P0 -- P2 withpen pencircle scaled 1.2pt withcolor col_skel;
  draw Q0 -- Q2 withpen pencircle scaled 1.2pt withcolor (0.1, 0.4, 0.1);

  % Draw Deviation Vectors (s-power arrows from midpoint):
  pair midP, midQ;
  midP := 0.5[P0, P2];
  midQ := 0.5[Q0, Q2];
  drawarrow midP -- (midP + 0.25 * P_delta) withpen pencircle scaled 1.2pt withcolor (0.75, 0, 0);
  drawarrow midQ -- (midQ + 0.25 * Q_delta) withpen pencircle scaled 1.2pt withcolor (0, 0.5, 0);

  % Draw Quadratic Bézier Curves using s-power evaluator:
  path pathP, pathQ;
  pathP := spower_path(P0, P2, P_delta, 50);
  pathQ := spower_path(Q0, Q2, Q_delta, 50);

  draw pathP withpen pencircle scaled 1.8pt withcolor col_clipper;
  draw pathQ withpen pencircle scaled 1.8pt withcolor col_clippehend;

  % Draw Control Points:
  fill fullcircle scaled 4.5pt shifted P0 withcolor col_skel;
  fill fullcircle scaled 4.5pt shifted P2 withcolor col_skel;
  fill fullcircle scaled 4.5pt shifted P1 withcolor col_clipper;
  fill fullcircle scaled 4.5pt shifted Q0 withcolor col_clippehend;
  fill fullcircle scaled 4.5pt shifted Q2 withcolor col_clippehend;
  fill fullcircle scaled 4.5pt shifted Q1 withcolor col_clippehend;

  % Intersection Point: exactly at (0, 0.6u) at t_P = 0.5, t_Q = 0.5
  pair P_inter;
  P_inter := (0.0u, 0.6u);
  fill fullcircle scaled 6.5pt shifted P_inter withcolor col_inter;
  draw fullcircle scaled 8.5pt shifted P_inter withpen pencircle scaled 0.8pt withcolor white;

  % Text Labels:
  label.bot(btex $P_0(-3,0)$ etex, P0 shifted (0, -3pt));
  label.bot(btex $P_2(3,0)$ etex, P2 shifted (0, -3pt));
  label.top(btex $P_1(0, 1.2)$ etex, P1 shifted (0, 2pt));
  label.bot(btex $Q_0(-3,-0.63)$ etex, Q0 shifted (0, -3pt));
  label.top(btex $Q_2(3,1.53)$ etex, Q2 shifted (0, 3pt));

  label.top(btex $\mathbf{P}(t)$ [Clipper] etex, eval_spower(P0, P2, P_delta, 0.20) shifted (-16pt, 6pt));
  label.bot(btex $\mathbf{Q}(t)$ [Clippehend] etex, eval_spower(Q0, Q2, Q_delta, 0.85) shifted (16pt, -6pt));

  label.rt(btex $\frac{1}{4} P_1^\Delta = (0, 0.6)$ etex, (midP + 0.25 * P_delta) shifted (4pt, -2pt));
  label.lft(btex $\frac{1}{4} Q_1^\Delta$ etex, (midQ + 0.25 * Q_delta) shifted (-4pt, 4pt));

  label.top(btex $(x^*, y^*) = (0, 0.6)$ [Crossing Angle $\approx 20^\circ$] etex, P_inter shifted (0, 8pt));
  label.lft(btex \small $\text{Fat-Line } F_P: y \in [0, 0.6]$ etex, (-3.6u, 0.3u));

  currentpicture := currentpicture scaled 1.0;
endfig;

% ======================================================================
% FIGURE 2: Skeleton Coordinate Projection & Parameter Clipping
% ======================================================================
beginfig(2);
  save w, h, y_max_val, y_scale, t_scale;
  w := 8.5cm;
  h := 4.5cm;

  % Parameter space: t in [0, 1] on X-axis, y'(t) on Y-axis
  y_max_val := 0.20;
  y_scale   := h / y_max_val;
  t_scale   := w;

  % Fat-Line Band [d_min, d_max] = [0.0, 0.10] in transformed coordinates
  path fatline_strip;
  fatline_strip := (0, 0) -- (w, 0) -- (w, 0.10 * y_scale) -- (0, 0.10 * y_scale) -- cycle;
  fill fatline_strip withcolor col_fatline;

  % Draw Coordinate Axes:
  drawarrow (-0.5cm, 0) -- (w + 0.8cm, 0) withpen pencircle scaled 1.0pt;
  drawarrow (0, -0.5cm) -- (0, h + 0.5cm) withpen pencircle scaled 1.0pt;

  label.rt(btex Parameter $t \in [0, 1]$ etex, (w + 0.8cm, 0));
  label.top(btex Transformed Distance $y'(t)$ etex, (0, h + 0.5cm));

  % Fat-Line Boundary threshold lines:
  draw (0, 0.10 * y_scale) -- (w, 0.10 * y_scale) dashed evenly withpen pencircle scaled 0.9pt withcolor col_clipper;
  label.rt(btex $d_{\max} = \frac{d_y}{4} = 0.10$ etex, (w, 0.10 * y_scale));
  label.lft(btex $d_{\min} = 0.0$ etex, (0, 0));

  % Plot Clipper Parabola d_P(t) = 0.40 * t * (1 - t) in skeleton coordinates
  path plot_P;
  plot_P := (0, 0)
    for i = 1 upto 50:
      hide(numeric tt, yy; tt := i / 50; yy := 0.40 * tt * (1.0 - tt);)
      -- (tt * t_scale, yy * y_scale)
    endfor;
  draw plot_P withpen pencircle scaled 1.5pt withcolor col_clipper;
  label.top(btex $d_P(t) = (1-t)t d_y$ etex, (0.5 * t_scale, 0.10 * y_scale + 4pt));

  % Plot Clippehend Distance Polynomial Q_y'(t) = -0.105(1-t) + 0.255t + 0.10t(1-t)
  path plot_Q;
  plot_Q := (0, -0.105 * y_scale)
    for i = 1 upto 50:
      hide(numeric tt, yy; tt := i / 50; yy := -0.105 * (1 - tt) + 0.255 * tt + 0.10 * tt * (1 - tt);)
      -- (tt * t_scale, yy * y_scale)
    endfor;
  draw plot_Q withpen pencircle scaled 1.6pt withcolor col_clippehend;
  label.rt(btex $Q_y'(t)$ etex, (w, ( -0.105*(0) + 0.255*(1) ) * y_scale));

  % Clipping boundaries on Q: Q_y'(t) = 0 => t_min ≈ 0.28, Q_y'(t) = 0.10 => t_max ≈ 0.50
  numeric t_enter, t_exit;
  t_enter := 0.28;
  t_exit  := 0.50;

  draw (t_enter * w, -4pt) -- (t_enter * w, 0.10 * y_scale) dashed withdots scaled 0.8 withpen pencircle scaled 0.9pt withcolor col_skel;
  draw (t_exit * w, -4pt) -- (t_exit * w, 0.10 * y_scale) dashed withdots scaled 0.8 withpen pencircle scaled 0.9pt withcolor col_skel;

  label.bot(btex $t_{\min} \approx 0.28$ etex, (t_enter * w, -4pt));
  label.bot(btex $t_{\max} \approx 0.50$ etex, (t_exit * w, -16pt));

  % Highlight the pruned parameter sub-interval [0.28, 0.50]
  draw (t_enter * w, 0) -- (t_exit * w, 0) withpen pencircle scaled 3.0pt withcolor (0.1, 0.7, 0.2);
  label.top(btex \small Active Clipped Interval $[\,t_{\min}, t_{\max}\,]$ etex, (0.5*(t_enter + t_exit) * w, 4pt));

  % Exact root point:
  fill fullcircle scaled 5.5pt shifted (0.5 * w, 0.10 * y_scale) withcolor col_inter;
  label.top(btex Exact Crossing $t_P^* = 0.5, t_Q^* = 0.5$ etex, (0.5 * w, 0.10 * y_scale + 12pt));

  currentpicture := currentpicture scaled 1.0;
endfig;

% ======================================================================
% FIGURE 3: Sub-interval Reparameterization & Quadratic Contraction
% ======================================================================
beginfig(3);
  save u, Pzero, Ptwo, Pdelta, tzero, tone, Dt;
  u := 2.0cm;

  % Original Curve Endpoints (Light Curving Arc)
  pair Pzero, Ptwo, Pdelta;
  Pzero  := (-3.0u, 0.0u);
  Ptwo   := ( 3.0u, 0.0u);
  Pdelta := ( 0.0u, 2.4u);

  % Draw full original curve (faint)
  path path_full;
  path_full := spower_path(Pzero, Ptwo, Pdelta, 50);
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
  P_sub_delta := (Dt * Dt) * Pdelta; % Deviation shrinks by (0.30)^2 = 0.09 (91% reduction!)

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
  draw path_sub withpen pencircle scaled 2.2pt withcolor col_clipper;

  % Endpoints of Sub-curve:
  fill fullcircle scaled 4.5pt shifted P_sub_zero withcolor col_skel;
  fill fullcircle scaled 4.5pt shifted P_sub_two withcolor col_skel;

  label.bot(btex $P(t_0)$ etex, P_sub_zero shifted (-4pt, -3pt));
  label.bot(btex $P(t_1)$ etex, P_sub_two shifted (4pt, -3pt));

  % Annotations illustrating Quadratic Convergence:
  label.top(btex \bfseries Quadratic Deviation Contraction in $s$-Power Basis etex, (0, 1.2u));
  label.bot(btex $\Delta t = t_1 - t_0 = 0.30 \implies (\Delta t)^2 = 0.09 \implies 91\%$ Flattening Reduction etex, (0, -0.5u));

  currentpicture := currentpicture scaled 1.0;
endfig;

end.
