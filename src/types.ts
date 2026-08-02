// Iris Number System Core Types

export interface IrisNumber {
  a: number; // Real scalar component (1)
  b: number; // Iris imaginary component (ι)
  c: number; // Phase spectrum component (ϖ)
  d: number; // Discrete measure component (ϑ)
  label?: string;
}

// Clifford Algebra Cl(4,1,1) Multivector
// Signature: 4 positive basis (e1, e2, e3, e4), 1 negative basis (e5), 1 null basis (e0)
export interface Cl411Multivector {
  scalar: number; // Grade 0
  e0: number; e1: number; e2: number; e3: number; e4: number; e5: number; // Grade 1
  e12: number; e23: number; e31: number; e14: number; e24: number; e34: number; e15: number; e25: number; e35: number; e45: number; e01: number; e05: number; // Grade 2 (Bivectors / Quaternions)
  e123: number; e125: number; e124: number; e234: number; e314: number; // Grade 3
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
  | 'Clifford Algebra Cl(4,1,1)'
  | 'Jaynesian MaxEnt Probability'
  | 'Bounded Rational Algebra'
  | 'Spectral Topology'
  | 'Quantum Iris Field';

export interface IrisAxiom {
  id: string;
  name: string;
  latex: string;
  domain: IrisDomain;
  description: string;
  category: 'Fundamental' | 'Clifford' | 'Jaynesian' | 'Bounded Rational' | 'Duality' | 'Convergence' | 'Modular' | 'Differential';
}

export interface DeductionStep {
  id: string;
  stepNumber: number;
  statement: string; // Plain math or LaTeX notation
  ruleUsed: string; // e.g. "Clifford Cl(4,1,1) Geometric Product Tautology"
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
  tab: 'textbook' | 'deduction' | 'sandbox' | 'spectral' | 'assistant' | 'library' | 'axioms';
}

