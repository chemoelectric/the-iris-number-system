% MetaPost illustration of s-Power Bézier Curve Intersections

filenametemplate "%j-%3c.mps";
prologues := 3;

verbatimtex
  \documentclass{article}
  \begin{document}
  etex;

beginfig(1);

  u := 1.5cm;

% Define control points for Clipper Curve P
  pair P[], Q[];
  P0 := (-1u, 0u);
  P1 := (0u, 10u);
  P2 := (1u, 0u);

% Define control points for Clippehend Curve Q
  Q0 := (2u, 1u);
  Q1 := (-8u, 2u);
  Q2 := (2u, 3u);

% Draw Clipper Curve P (quadratic Bezier)
  path pathP, pathQ;
  pathP := P0 .. controls (2/3[P0,P1]) and (2/3[P2,P1]) .. P2;
  pathQ := Q0 .. controls (2/3[Q0,Q1]) and (2/3[Q2,Q1]) .. Q2;

% Draw Skeleton line P0--P2
  draw P0--P2 dashed withdots scaled 0.8 withcolor blue;

% Draw Curves
  draw pathP withpen pencircle scaled 1.2pt withcolor red;
  draw pathQ withpen pencircle scaled 1.2pt withcolor (0, 0.6, 0);

% Compute and draw Intersection Point using MetaPost intersectiontimes
  pair t_pair;
  t_pair := pathP intersectiontimes pathQ;
  pair inter_pt;
  inter_pt := point xpart(t_pair) of pathP;
  fill fullcircle scaled 5pt shifted inter_pt withcolor black;
  label.top(btex $(x^*,y^*) = (0,5)$ etex, inter_pt shifted (0, 4pt));

% Labels
  label.bot(btex $P_0(-1,0)$ etex, P0);
  label.bot(btex $P_2(1,0)$ etex, P2);
  label.rt(btex $Q_2(2,3)$ etex, Q2);
  label.rt(btex $Q_0(2,1)$ etex, Q0);

endfig;
end.
