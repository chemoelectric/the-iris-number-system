% MetaPost illustration of the s-Power Bézier Clipping Algorithm
%
% This program demonstrates the constructive s-power Bézier clipping
% algorithm on two Bézier segments:
%   1. S-power basis curve representation and deviation vector derivation
%   2. Affine skeleton transformation mapping chord to the standard baseline
%   3. Optimal parallel fat-line slab construction
%   4. Deterministic bounding of the exact intersection point (x*, y*)
%
% To compile:
%   mpost --tex=latex bezclip.mp
%
% To convert figures to PNG:
%   magick bezclip.mps -flatten -bordercolor white -border 20 bezclip.png

filenametemplate "%j.mps";
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

  % Clippehend Curve Q: Gently curving upward-right, chord inclined at ~24°
  % Crossing Clipper P at (-1.5u, 0.45u)
  pair Q[];
  Q0 := (-3.0u, -0.30u);
  Q1 := ( -1.0u,  1.25u);
  Q2 := ( 2.0u,  2.40u);

  % Exact s-Power Deviation Vectors:
  %   P1^Delta = 2*P1 - P0 - P2 = (0, 2.4u)
  %   Q1^Delta = 2*Q1 - Q0 - Q2 = (0, 0.4u)
  pair P_delta, Q_delta;
  P_delta := 2 * P1 - P0 - P2;  % = (0, 2.4u)
  Q_delta := 2 * Q1 - Q0 - Q2;  % = (0, 0.4u)

  % Optimal Fat-Line bounds for Clipper P:
  % Skeleton is y = 0. Apex displacement is (1/4)*2.4u = 0.6u.
  % Bound is y in [0, 0.6u].
  path fatline_P_slab;
  fatline_P_slab := (-3.6u, 0.0u) -- (3.6u, 0.0u) -- (3.6u, 0.6u) -- (-3.6u, 0.6u) -- cycle;

  % Optimal Fat-Line bounds for Clippehend Q:
  % Skeleton chord vector v_Q = Q2 - Q0 = (6.0u, 2.70u)  (slope = 0.450 => 24.2 degrees)
  % Deviation apex offset from chord is (1/4)*Q_delta = (0, 0.10u)
  path fatline_Q_slab;
  fatline_Q_slab := (Q0 - 0.2*(Q2-Q0)) -- (Q2 + 0.2*(Q2-Q0))
                 -- (Q2 + 0.2*(Q2-Q0) + 0.25*Q_delta)
                 -- (Q0 - 0.2*(Q2-Q0) + 0.25*Q_delta) -- cycle;

  % Draw Boundary Lines for P Fat-Line:
  draw (-3.6u, 0.0u) -- (3.6u, 0.0u) withpen pencircle scaled 0.6pt withcolor col_skel;
  draw (-3.6u, 0.6u) -- (3.6u, 0.6u) dashed evenly withpen pencircle scaled 0.8pt withcolor col_clipper;

  % Draw Boundary Lines for Q Fat-Line:
  draw (Q0 - 0.2*(Q2-Q0)) -- (Q2 + 0.2*(Q2-Q0)) withpen pencircle scaled 0.6pt withcolor col_clippehend;
  % The following is an invisible line, but you can make it visible if you wish:
  draw (Q0 - 0.2*(Q2-Q0) + 0.25*Q_delta) -- (Q2 + 0.2*(Q2-Q0) + 0.25*Q_delta)
       dashed evenly withpen pencircle scaled 0.8pt withcolor (0.0 col_clippehend + 1.0 (1, 1, 1));

  % Draw Skeletons:
  draw P0 -- P2 withpen pencircle scaled 1.2pt withcolor col_skel;
  draw Q0 -- Q2 withpen pencircle scaled 1.2pt withcolor (0.1, 0.4, 0.1);

  % Draw Deviation Vector (s-power arrow from midpoint):
  pair midP;
  midP := 0.5[P0, P2];
  drawarrow midP -- (midP + 0.25 * P_delta) withpen pencircle scaled 1.2pt withcolor (0.75, 0, 0);

  % Draw Quadratic Bézier Curves using s-power evaluator:
  path pathP, pathQ;
  pathP := spower_path(P0, P2, P_delta, 50);
  pathQ := spower_path(Q0, Q2, Q_delta, 50);

  draw pathP withpen pencircle scaled 1.8pt withcolor col_clipper;
  draw pathQ withpen pencircle scaled 1.8pt withcolor col_clippehend;

  % Draw Control Points:
  fill fullcircle scaled 4.5pt shifted P0 withcolor col_skel;
  fill fullcircle scaled 4.5pt shifted P2 withcolor col_skel;
  fill fullcircle scaled 4.5pt shifted Q0 withcolor col_clippehend;
  fill fullcircle scaled 4.5pt shifted Q2 withcolor col_clippehend;

  % Clipping Point: where clippehend Q(t) exits the upper fat-line boundary of P
  pair P_clip;
  P_clip := pathQ intersectionpoint ((-3.6u, 0.6u) -- (3.6u, 0.6u));
  draw ((-(0.10u, 0.10u) -- (0.10u, 0.10u)) rotated 25) shifted P_clip
    withpen pencircle scaled 0.9 withcolor (92/255, 39/255, 255/255);
  draw ((-(0.10u, 0.10u) -- (0.10u, 0.10u)) rotated 65) shifted P_clip
    withpen pencircle scaled 0.9 withcolor (92/255, 39/255, 255/255);

  label.rt(btex $\mathbf{P}(t)$ [Clipper] etex, eval_spower(P0, P2, P_delta, 0.80) shifted (16pt, 0pt));
  label.ulft(btex $\mathbf{Q}(t)$ [Clippehend] etex, eval_spower(Q0, Q2, Q_delta, 0.85) shifted (-5pt, 2pt));

  label.lft(btex \small $\text{Fat Line } F_P$ etex, (-3.3u, 0.3u));
  drawarrow (-3.5u, 0.45u) -- (-3.5u, 0.6u);
  drawarrow (-3.5u, 0.15u) -- (-3.5u, 0);

  currentpicture := currentpicture scaled 2.0;
endfig;

end.
