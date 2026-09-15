/**
 * mresAnalysis.ts: Graded m-resolution numerical analysis engine.
 * Implements Fontijne-style graded separation between pure m-res numbers
 * and composite m-res jets, exact Cauchy discrete convolution,
 * nilpotent closed-form inversion, and typed downarrow projections.
 */

export interface Mres1 {
  readonly tag: 'mres1';
  readonly val: number;
}

export interface Mres2 {
  readonly tag: 'mres2';
  readonly val: number;
}

export interface Mres3 {
  readonly tag: 'mres3';
  readonly val: number;
}

/**
 * Composite jet structure aggregating distinct homogeneous grades.
 * Strictly distinguished from pure m-res numbers.
 */
export interface Mjet3 {
  readonly tag: 'mjet3';
  readonly c0: number;
  readonly c1: Mres1;
  readonly c2: Mres2;
  readonly c3: Mres3;
}

/* --- Pure Grade Constructors --- */

export function mres1(val: number): Mres1 {
  return { tag: 'mres1', val };
}

export function mres2(val: number): Mres2 {
  return { tag: 'mres2', val };
}

export function mres3(val: number): Mres3 {
  return { tag: 'mres3', val };
}

/* --- Composite Jet Constructor --- */

export function mjet3(
  c0: number,
  c1: Mres1 = mres1(0),
  c2: Mres2 = mres2(0),
  c3: Mres3 = mres3(0)
): Mjet3 {
  return { tag: 'mjet3', c0, c1, c2, c3 };
}

export function mjetFromReal(x: number): Mjet3 {
  return mjet3(x, mres1(0), mres2(0), mres3(0));
}

export function mresGeneratorMu(): Mjet3 {
  return mjet3(0, mres1(1), mres2(0), mres3(0));
}

/* --- Pure Graded Multiplications (Fontijne Style) --- */

export function realMulMres1(s: number, a: Mres1): Mres1 {
  return mres1(s * a.val);
}

export function realMulMres2(s: number, a: Mres2): Mres2 {
  return mres2(s * a.val);
}

export function realMulMres3(s: number, a: Mres3): Mres3 {
  return mres3(s * a.val);
}

/**
 * Grade 1 * Grade 1 yields Grade 2!
 */
export function mres1MulMres1(a: Mres1, b: Mres1): Mres2 {
  return mres2(a.val * b.val);
}

/**
 * Grade 1 * Grade 2 yields Grade 3!
 */
export function mres1MulMres2(a: Mres1, b: Mres2): Mres3 {
  return mres3(a.val * b.val);
}

/* --- Composite Jet Arithmetic --- */

export function mjetAdd(a: Mjet3, b: Mjet3): Mjet3 {
  return mjet3(
    a.c0 + b.c0,
    mres1(a.c1.val + b.c1.val),
    mres2(a.c2.val + b.c2.val),
    mres3(a.c3.val + b.c3.val)
  );
}

export function mjetSub(a: Mjet3, b: Mjet3): Mjet3 {
  return mjet3(
    a.c0 - b.c0,
    mres1(a.c1.val - b.c1.val),
    mres2(a.c2.val - b.c2.val),
    mres3(a.c3.val - b.c3.val)
  );
}

export function mjetScale(a: Mjet3, s: number): Mjet3 {
  return mjet3(
    a.c0 * s,
    mres1(a.c1.val * s),
    mres2(a.c2.val * s),
    mres3(a.c3.val * s)
  );
}

/**
 * Graded Cauchy Discrete Convolution in the truncated ring R[mu]/(mu^4).
 */
export function mjetMul(a: Mjet3, b: Mjet3): Mjet3 {
  const c0 = a.c0 * b.c0;
  const c1 = a.c0 * b.c1.val + a.c1.val * b.c0;
  const c2 = a.c0 * b.c2.val + a.c1.val * b.c1.val + a.c2.val * b.c0;
  const c3 =
    a.c0 * b.c3.val +
    a.c1.val * b.c2.val +
    a.c2.val * b.c1.val +
    a.c3.val * b.c0;

  return mjet3(c0, mres1(c1), mres2(c2), mres3(c3));
}

/**
 * Exact Inversion via Nilpotent Series Expansion.
 * Inverts X = x0 * (1 + delta) algebraically in closed form.
 */
export function mjetInv(a: Mjet3): Mjet3 {
  if (Math.abs(a.c0) < 1e-15) {
    throw new Error('Singular m-res jet: constant term is zero.');
  }

  const inv0 = 1.0 / a.c0;
  const d1 = a.c1.val * inv0;
  const d2 = a.c2.val * inv0;
  const d3 = a.c3.val * inv0;

  const r1 = -d1;
  const r2 = -d2 + d1 * d1;
  const r3 = -d3 + 2.0 * d1 * d2 - d1 * d1 * d1;

  return mjet3(
    inv0,
    mres1(r1 * inv0),
    mres2(r2 * inv0),
    mres3(r3 * inv0)
  );
}

export function mjetDiv(a: Mjet3, b: Mjet3): Mjet3 {
  return mjetMul(a, mjetInv(b));
}

export function mjetExp(a: Mjet3): Mjet3 {
  const e0 = Math.exp(a.c0);
  const e1 = e0 * a.c1.val;
  const e2 = e0 * (a.c2.val + 0.5 * a.c1.val * a.c1.val);
  const e3 =
    e0 *
    (a.c3.val +
      a.c1.val * a.c2.val +
      (a.c1.val * a.c1.val * a.c1.val) / 6.0);

  return mjet3(e0, mres1(e1), mres2(e2), mres3(e3));
}

/* --- Typed Downarrow Operations (Downarrow Projections) --- */

/**
 * Mode 1: Observable Projection (Extracts macroscopic Grade 0).
 */
export function mresDownarrow0(j: Mjet3): number {
  return j.c0;
}

/**
 * Mode 2: Discrete Lattice Projection down to grid G_N with step dx.
 */
export function mresDownarrowGrid(j: Mjet3, dx: number): number {
  const val =
    j.c0 +
    j.c1.val * dx +
    j.c2.val * dx * dx +
    j.c3.val * dx * dx * dx;
  return Math.round(val / dx) * dx;
}

/**
 * Mode 3: Differential Rate Extraction:
 * Extracts exact k-th order rate of change without dividing by any step size.
 */
export function mresDownarrowRate(j: Mjet3, order: 0 | 1 | 2 | 3): number {
  switch (order) {
    case 0:
      return j.c0;
    case 1:
      return j.c1.val;
    case 2:
      return 2.0 * j.c2.val;
    case 3:
      return 6.0 * j.c3.val;
  }
}

/* --- Stiff System Numerical Solver --- */

export interface StiffStepResult {
  t: number;
  yMres: number;
  yEuler: number;
  eulerExploded: boolean;
}

/**
 * Steps dy/dt = -lambda * y + s(t) across nSteps with macroscopic step dt.
 * Compares classical Euler vs m-res Padé jet stepping.
 */
export function simulateStiffSystem(
  lambda: number,
  y0: number,
  dt: number,
  steps: number,
  sourceFn?: (t: number) => number
): StiffStepResult[] {
  const results: StiffStepResult[] = [];
  let t = 0;
  let yMres = y0;
  let yEuler = y0;
  let eulerExploded = false;

  results.push({ t, yMres, yEuler, eulerExploded });

  for (let s = 0; s < steps; s += 1) {
    const sVal = sourceFn ? sourceFn(t + 0.5 * dt) : 0;

    // Classical Euler
    if (!eulerExploded) {
      const dy = -lambda * yEuler + (sourceFn ? sourceFn(t) : 0);
      yEuler = yEuler + dt * dy;
      if (!Number.isFinite(yEuler) || Math.abs(yEuler) > 1e8) {
        eulerExploded = true;
        yEuler = yEuler > 0 ? 1e9 : -1e9;
      }
    }

    // m-res Singular Perturbation Jet Solver:
    // eps = 1 / lambda is the 1st-order m-res parameter.
    // The transient decays as exp(-lambda * dt), exactly bounded on G_N.
    // The slow manifold is algebraic in powers of eps = 1/lambda.
    const eps = 1.0 / lambda;
    const decay = lambda * dt >= 700 ? 0 : Math.exp(-lambda * dt);
    const transient = yMres * decay;

    let manifold = 0;
    if (sourceFn) {
      // Jet expansion of source g(t)
      const g0 = sourceFn(t + dt);
      const g1 = (sourceFn(t + dt + 1e-6) - sourceFn(t + dt - 1e-6)) / 2e-6;
      const g2 =
        (sourceFn(t + dt + 1e-6) - 2 * g0 + sourceFn(t + dt - 1e-6)) / 1e-12;

      // Algebraic manifold jet: g0 - eps*g1 + eps^2*g2
      const gJet = mjet3(g0, mres1(-g1), mres2(g2), mres3(0));
      manifold = mresDownarrowGrid(gJet, eps);
    }

    yMres = transient + manifold;
    t += dt;

    results.push({ t, yMres, yEuler, eulerExploded });
  }

  return results;
}
