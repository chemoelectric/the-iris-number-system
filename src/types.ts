// Iris Number System Core Types

export interface IrisNumber {
  a: number; // Real scalar component (1)
  b: number; // Iris imaginary component (ι)
  c: number; // Phase spectrum component (ϖ)
  d: number; // Discrete measure component (ϑ)
  label?: string;
}

// 6D Conformal Geometric Algebra (CGA) Multivector
// Canonical generators: {e_1, e_2, e_3, e_4, e_⊙, e_∞}
// Metric: e_1^2 = e_2^2 = e_3^2 = 1, e_4^2 = 0, e_⊙^2 = e_∞^2 = 0, e_⊙ · e_∞ = -1
export interface CgaMultivector {
  scalar: number; // Grade 0
  e1: number; e2: number; e3: number; e4: number; eOdot: number; eInf: number; // Grade 1
  e12: number; e23: number; e31: number; e14: number; e24: number; e34: number;
  e1Odot: number; e2Odot: number; e3Odot: number; e1Inf: number; e2Inf: number; e3Inf: number;
  e4Odot: number; e4Inf: number; eOdotInf: number; // Grade 2 (Bivectors / Quaternions)
  e123: number; e124: number; e234: number; e314: number; // Grade 3
  pseudoscalar: number; // Grade 6
  label?: string;
}

// Discrete Spectrum Number: x + ε * nilpotent_boundary_residual + δ * discrete_grid_step
export interface DiscreteSpectrumNumber {
  st: number; // Primary scalar component
  eps: number; // Nilpotent boundary residual coefficient ε (ϖ ϑ)
  omega: number; // Discrete partition scale coefficient δ
  label?: string;
}
export type MultiscaleResolutionNumber = DiscreteSpectrumNumber;
export type NonstandardNumber = MultiscaleResolutionNumber;
export type HyperrealNumber = DiscreteSpectrumNumber;

// Jaynesian MaxEnt Probability Distribution Point
export interface MaxEntState {
  x: number;
  prob: number; // P(x) = (1/Z) exp(- sum lambda_k A_k(x))
  entropy: number; // - P(x) ln P(x)
  irisPhase: number;
  energy: number;
}

export type IrisDomain =
  | 'Tautological Discrete Arithmetic'
  | 'Discrete Spectrum Algebra'
  | 'Conformal Geometric Algebra (CGA)'
  | 'Jaynesian MaxEnt Probability'
  | 'Bounded Rational Algebra'
  | 'Spectral Topology'
  | 'Unified Field Theory (D F = J)'
  | 'Number Theory'
  | 'Discrete Analysis'
  | 'Abstract Algebra';

export interface IrisAxiom {
  id: string;
  name: string;
  latex: string;
  domain: IrisDomain;
  description: string;
  category: 'Fundamental' | 'CGA' | 'Jaynesian' | 'Bounded Rational' | 'Duality' | 'Convergence' | 'Modular' | 'Differential';
}

export interface DeductionStep {
  id: string;
  stepNumber: number;
  statement: string; // Plain math or LaTeX notation
  ruleUsed: string; // e.g. "6D CGA Geometric Product Tautology"
  justification: string;
  status: 'valid' | 'invalid' | 'hypothetical' | 'pending';
  dependencies: number[]; // Step numbers this step depends on
  notes?: string;
}

export interface TheoremProof {
  id: string;
  title: string;
  domain: IrisDomain;
  hypothesis: string;
  conclusion: string;
  rigorScore: number; // 0 - 100
  summary: string;
  steps: DeductionStep[];
  potentialCounterexamples?: string[];
  relatedLemmas?: string[];
  author?: 'System' | 'Inference Engine' | 'User';
  createdAt: string;
}

export interface IrisZetaPoint {
  t: number; // Im(s) parameter
  realPart: number;
  imagPart: number;
  irisNorm: number;
  phaseAngle: number; // in degrees or rad
  isZeroCandidate?: boolean;
}

export interface IrisPrimePoint {
  n: number;
  a: number;
  b: number;
  isPrime: boolean;
  radius: number;
  angle: number; // Spiral angle
  residueMod7: number;
  spectralDensity: number;
}

export interface TextbookSection {
  id: string;
  title: string;
  contentAsciiDoc: string; // AsciiDoc + LatexMath content
  subsections?: { id: string; title: string; contentAsciiDoc: string }[];
}

export interface TextbookChapter {
  id: string;
  title: string;
  summary?: string;
  sections: TextbookSection[];
}

export interface Textbook {
  id: string;
  title: string;
  subtitle?: string;
  author: string;
  version: string;
  lastUpdated: string;
  description: string;
  filename?: string;
  chapters: TextbookChapter[];
}

export interface ActiveView {
  tab: 'textbook' | 'deduction' | 'sandbox' | 'spectral' | 'assistant' | 'library' | 'axioms' | 'aerodynamics';
}

