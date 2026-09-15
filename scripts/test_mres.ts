/**
 * scripts/test_mres.ts: Verification script for m-res numerical analysis.
 * Run with: bun scripts/test_mres.ts
 */

import {
  mres1,
  mres2,
  mres3,
  mjet3,
  mres1MulMres1,
  mres1MulMres2,
  mjetMul,
  mjetInv,
  mresGeneratorMu,
  mjetExp,
  mresDownarrow0,
  simulateStiffSystem
} from '../src/lib/mresAnalysis';

console.log('=== Verifying m-Resolution Numerical Analysis (TypeScript / Bun) ===');

let allPass = true;

// 1. Graded Multiplication
const a = mres1(3.0);
const b = mres1(4.0);
const c = mres1MulMres1(a, b);
if (Math.abs(c.val - 12.0) > 1e-12 || c.tag !== 'mres2') {
  console.error('FAIL: mres1 * mres1 failed');
  allPass = false;
} else {
  console.log('PASS: Graded multiplication (mres1 * mres1 -> mres2)');
}

const d = mres1MulMres2(a, c);
if (Math.abs(d.val - 36.0) > 1e-12 || d.tag !== 'mres3') {
  console.error('FAIL: mres1 * mres2 failed');
  allPass = false;
} else {
  console.log('PASS: Graded multiplication (mres1 * mres2 -> mres3)');
}

// 2. Nilpotent Inversion
const j = mjet3(2.0, mres1(3.0), mres2(-1.0), mres3(0.5));
const invJ = mjetInv(j);
const prod = mjetMul(j, invJ);

if (
  Math.abs(prod.c0 - 1.0) > 1e-12 ||
  Math.abs(prod.c1.val) > 1e-12 ||
  Math.abs(prod.c2.val) > 1e-12 ||
  Math.abs(prod.c3.val) > 1e-12
) {
  console.error('FAIL: Nilpotent inversion product:', prod);
  allPass = false;
} else {
  console.log('PASS: Exact Nilpotent series inversion in mjet3 ring');
}

// 3. Indeterminate 0/0 Cancellation
const mu = mresGeneratorMu();
const expMu = mjetExp(mu);
// (exp(mu) - 1) / mu:
const numC1 = expMu.c1.val;
const numC2 = expMu.c2.val;
const numC3 = expMu.c3.val;
const quotient = mjet3(numC1, mres1(numC2), mres2(numC3), mres3(0));
const val0 = mresDownarrow0(quotient);

if (Math.abs(val0 - 1.0) > 1e-12) {
  console.error('FAIL: Indeterminate 0/0 limit:', val0);
  allPass = false;
} else {
  console.log('PASS: Indeterminate 0/0 cancellation via graded jet (val0 = 1.0)');
}

// 4. Stiff System Simulation
const sim = simulateStiffSystem(10000.0, 1.0, 0.005, 5);
const lastStep = sim[sim.length - 1];
if (!lastStep.eulerExploded) {
  console.error('FAIL: Expected Euler to explode');
  allPass = false;
} else {
  console.log(`PASS: Classical Euler exploded (yEuler = ${lastStep.yEuler})`);
}

if (Math.abs(lastStep.yMres) > 1.0 || lastStep.yMres < -0.1) {
  console.error('FAIL: m-res stiff step unstable:', lastStep.yMres);
  allPass = false;
} else {
  console.log(`PASS: m-res Padé jet step stable: y(0.025) = ${lastStep.yMres}`);
}

if (allPass) {
  console.log('ALL VERIFICATION CHECKS PASSED.');
  process.exit(0);
} else {
  console.error('SOME CHECKS FAILED.');
  process.exit(1);
}
