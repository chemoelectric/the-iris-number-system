import React, { useState } from 'react';
import {
  IrisNumber,
  Cl411Multivector,
  NonstandardNumber,
  MaxEntState
} from '../types';
import {
  irisNorm,
  irisConjugate,
  irisAdd,
  irisSub,
  irisMultiply,
  irisScale,
  irisPhase,
  createZeroCl411,
  createQuaternionCl411,
  createComplexCl411,
  multiplyCl411,
  addCl411,
  scaleCl411,
  cl411Norm,
  createNonstandardNumber,
  standardPart,
  addNonstandardNumber,
  multiplyNonstandardNumber,
  computeMaxEntDistribution,
  computeJaynesianEntropy,
  TAU,
  IOTA_SQ,
  PI_7,
} from '../lib/irisEngine';
import {
  Calculator,
  Compass,
  Zap,
  Layers,
  Sliders,
  Activity,
  Box,
  Binary,
  Cpu
} from 'lucide-react';

export const IrisSandbox: React.FC = () => {
  const [activeSubTab, setActiveSubTab] = useState<'4d' | 'cl411' | 'nonstandard' | 'maxent'>('4d');

  // ================= 4D IRIS STATE =================
  const [z1, setZ1] = useState<IrisNumber>({ a: 2, b: 1, c: 0.5, d: 0, label: 'Z₁' });
  const [z2, setZ2] = useState<IrisNumber>({ a: 1, b: -0.5, c: 1, d: 0.25, label: 'Z₂' });
  const [selectedOp, setSelectedOp] = useState<'mul' | 'add' | 'sub' | 'scale'>('mul');
  const [scaleFactor, setScaleFactor] = useState<number>(2);

  // Computed 4D
  const norm1 = irisNorm(z1);
  const norm2 = irisNorm(z2);
  const phase1 = irisPhase(z1);
  let result4D: IrisNumber = { a: 0, b: 0, c: 0, d: 0, label: 'Result' };
  if (selectedOp === 'add') result4D = irisAdd(z1, z2);
  else if (selectedOp === 'sub') result4D = irisSub(z1, z2);
  else if (selectedOp === 'mul') result4D = irisMultiply(z1, z2);
  else if (selectedOp === 'scale') result4D = irisScale(z1, scaleFactor);
  const resultNorm = irisNorm(result4D);
  const resultPhase = irisPhase(result4D);

  // ================= Cl(4,1,1) STATE =================
  const [clType, setClType] = useState<'quaternion' | 'complex' | 'multivector'>('quaternion');
  // Quaternions Q1, Q2
  const [q1, setQ1] = useState({ w: 1, i: 2, j: -1, k: 0.5 });
  const [q2, setQ2] = useState({ w: 0.5, i: 1, j: 1, k: -1 });

  const mvA = createQuaternionCl411(q1.w, q1.i, q1.j, q1.k);
  const mvB = createQuaternionCl411(q2.w, q2.i, q2.j, q2.k);
  const mvProd = multiplyCl411(mvA, mvB);
  const mvNormProd = cl411Norm(mvProd);

  // ================= NONSTANDARD STATE =================
  const [hr1, setHr1] = useState<NonstandardNumber>({ st: 5, eps: 2, omega: 0 });
  const [hr2, setHr2] = useState<NonstandardNumber>({ st: 3, eps: -1, omega: 0 });

  const hrSum = addNonstandardNumber(hr1, hr2);
  const hrProd = multiplyNonstandardNumber(hr1, hr2);

  // ================= MAXENT STATE =================
  const [lambda1, setLambda1] = useState<number>(0.5);
  const [lambda2, setLambda2] = useState<number>(0.2);

  const maxEntStates = computeMaxEntDistribution(40, lambda1, lambda2);
  const totalEntropy = computeJaynesianEntropy(maxEntStates);

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 relative overflow-hidden">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 relative z-10">
          <div>
            <div className="flex items-center space-x-2">
              <Calculator className="w-6 h-6 text-indigo-400" />
              <h2 className="text-xl font-bold text-white">Counting-Iris Multi-Algebra Calculator</h2>
            </div>
            <p className="text-slate-400 text-sm mt-1 max-w-2xl">
              Compute over 4D basis, Clifford Algebra Cl(4,1,1) multivectors, exact discrete spectrum grids, and Jaynesian MaxEnt probability fields.
            </p>
          </div>

          {/* SubTab Selector */}
          <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800 shrink-0">
            <button
              onClick={() => setActiveSubTab('4d')}
              className={`px-3 py-1.5 text-xs font-mono font-medium rounded-lg transition ${
                activeSubTab === '4d'
                  ? 'bg-indigo-600 text-white shadow'
                  : 'text-slate-400 hover:text-slate-200'
              }`}
            >
              4D Basis {`{1,ι,ϖ,ϑ}`}
            </button>
            <button
              onClick={() => setActiveSubTab('cl411')}
              className={`px-3 py-1.5 text-xs font-mono font-medium rounded-lg transition ${
                activeSubTab === 'cl411'
                  ? 'bg-indigo-600 text-white shadow'
                  : 'text-slate-400 hover:text-slate-200'
              }`}
            >
              Clifford Cl(4,1,1)
            </button>
            <button
              onClick={() => setActiveSubTab('nonstandard')}
              className={`px-3 py-1.5 text-xs font-mono font-medium rounded-lg transition ${
                activeSubTab === 'nonstandard'
                  ? 'bg-indigo-600 text-white shadow'
                  : 'text-slate-400 hover:text-slate-200'
              }`}
            >
              Discrete Spectrum
            </button>
            <button
              onClick={() => setActiveSubTab('maxent')}
              className={`px-3 py-1.5 text-xs font-mono font-medium rounded-lg transition ${
                activeSubTab === 'maxent'
                  ? 'bg-indigo-600 text-white shadow'
                  : 'text-slate-400 hover:text-slate-200'
              }`}
            >
              Jaynesian MaxEnt
            </button>
          </div>
        </div>
      </div>

      {/* 4D BASIS SECTION */}
      {activeSubTab === '4d' && (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-5 space-y-6">
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 space-y-4 shadow-xl">
              <div className="flex items-center justify-between border-b border-slate-800 pb-3">
                <div className="flex items-center space-x-2">
                  <div className="w-3 h-3 rounded-full bg-amber-400" />
                  <h3 className="font-semibold text-slate-200">Iris Number Z₁</h3>
                </div>
                <div className="text-xs font-mono text-slate-400">
                  ||Z₁|| = <span className="text-amber-300 font-bold">{norm1.toFixed(3)}</span>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-xs font-mono text-slate-400 flex justify-between">
                    <span>Scalar (a):</span>
                    <span className="text-slate-200">{z1.a}</span>
                  </label>
                  <input
                    type="range" min="-5" max="5" step="0.1" value={z1.a}
                    onChange={(e) => setZ1({ ...z1, a: parseFloat(e.target.value) })}
                    className="w-full accent-amber-400 mt-1 cursor-pointer"
                  />
                </div>
                <div>
                  <label className="text-xs font-mono text-slate-400 flex justify-between">
                    <span>Iris ι (b):</span>
                    <span className="text-slate-200">{z1.b}</span>
                  </label>
                  <input
                    type="range" min="-5" max="5" step="0.1" value={z1.b}
                    onChange={(e) => setZ1({ ...z1, b: parseFloat(e.target.value) })}
                    className="w-full accent-amber-400 mt-1 cursor-pointer"
                  />
                </div>
                <div>
                  <label className="text-xs font-mono text-slate-400 flex justify-between">
                    <span>Phase ϖ (c):</span>
                    <span className="text-slate-200">{z1.c}</span>
                  </label>
                  <input
                    type="range" min="-5" max="5" step="0.1" value={z1.c}
                    onChange={(e) => setZ1({ ...z1, c: parseFloat(e.target.value) })}
                    className="w-full accent-amber-400 mt-1 cursor-pointer"
                  />
                </div>
                <div>
                  <label className="text-xs font-mono text-slate-400 flex justify-between">
                    <span>Measure ϑ (d):</span>
                    <span className="text-slate-200">{z1.d}</span>
                  </label>
                  <input
                    type="range" min="-5" max="5" step="0.1" value={z1.d}
                    onChange={(e) => setZ1({ ...z1, d: parseFloat(e.target.value) })}
                    className="w-full accent-amber-400 mt-1 cursor-pointer"
                  />
                </div>
              </div>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-4 flex items-center justify-between gap-2 shadow-lg">
              <span className="text-xs font-semibold text-slate-400">Operation:</span>
              <div className="flex items-center space-x-1.5">
                {[
                  { id: 'mul', label: 'Z₁ × Z₂' },
                  { id: 'add', label: 'Z₁ + Z₂' },
                  { id: 'sub', label: 'Z₁ - Z₂' },
                  { id: 'scale', label: 'k · Z₁' },
                ].map((op) => (
                  <button
                    key={op.id}
                    onClick={() => setSelectedOp(op.id as any)}
                    className={`px-3 py-1.5 text-xs font-mono font-medium rounded-lg transition ${
                      selectedOp === op.id
                        ? 'bg-indigo-600 text-white shadow'
                        : 'bg-slate-800 text-slate-400 hover:bg-slate-700'
                    }`}
                  >
                    {op.label}
                  </button>
                ))}
              </div>
            </div>

            {selectedOp !== 'scale' && (
              <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 space-y-4 shadow-xl">
                <div className="flex items-center justify-between border-b border-slate-800 pb-3">
                  <div className="flex items-center space-x-2">
                    <div className="w-3 h-3 rounded-full bg-indigo-400" />
                    <h3 className="font-semibold text-slate-200">Iris Number Z₂</h3>
                  </div>
                  <div className="text-xs font-mono text-slate-400">
                    ||Z₂|| = <span className="text-indigo-300 font-bold">{norm2.toFixed(3)}</span>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="text-xs font-mono text-slate-400 flex justify-between">
                      <span>Scalar (a):</span>
                      <span className="text-slate-200">{z2.a}</span>
                    </label>
                    <input
                      type="range" min="-5" max="5" step="0.1" value={z2.a}
                      onChange={(e) => setZ2({ ...z2, a: parseFloat(e.target.value) })}
                      className="w-full accent-indigo-400 mt-1 cursor-pointer"
                    />
                  </div>
                  <div>
                    <label className="text-xs font-mono text-slate-400 flex justify-between">
                      <span>Iris ι (b):</span>
                      <span className="text-slate-200">{z2.b}</span>
                    </label>
                    <input
                      type="range" min="-5" max="5" step="0.1" value={z2.b}
                      onChange={(e) => setZ2({ ...z2, b: parseFloat(e.target.value) })}
                      className="w-full accent-indigo-400 mt-1 cursor-pointer"
                    />
                  </div>
                  <div>
                    <label className="text-xs font-mono text-slate-400 flex justify-between">
                      <span>Phase ϖ (c):</span>
                      <span className="text-slate-200">{z2.c}</span>
                    </label>
                    <input
                      type="range" min="-5" max="5" step="0.1" value={z2.c}
                      onChange={(e) => setZ2({ ...z2, c: parseFloat(e.target.value) })}
                      className="w-full accent-indigo-400 mt-1 cursor-pointer"
                    />
                  </div>
                  <div>
                    <label className="text-xs font-mono text-slate-400 flex justify-between">
                      <span>Measure ϑ (d):</span>
                      <span className="text-slate-200">{z2.d}</span>
                    </label>
                    <input
                      type="range" min="-5" max="5" step="0.1" value={z2.d}
                      onChange={(e) => setZ2({ ...z2, d: parseFloat(e.target.value) })}
                      className="w-full accent-indigo-400 mt-1 cursor-pointer"
                    />
                  </div>
                </div>
              </div>
            )}
          </div>

          <div className="lg:col-span-7 space-y-6">
            <div className="bg-slate-900 border border-indigo-500/30 rounded-2xl p-6 shadow-2xl space-y-4">
              <div className="flex items-center justify-between border-b border-slate-800 pb-3">
                <div className="flex items-center space-x-2">
                  <Zap className="w-5 h-5 text-amber-400" />
                  <h3 className="font-bold text-white text-lg">Evaluation Result</h3>
                </div>
                <span className="text-xs font-mono text-indigo-300 bg-indigo-500/20 px-2.5 py-1 rounded border border-indigo-500/30">
                  Norm: {resultNorm.toFixed(4)}
                </span>
              </div>

              <div className="p-4 bg-slate-950 rounded-xl border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-slate-400 uppercase">Target Result Z:</div>
                <div className="font-mono text-lg md:text-xl text-amber-200 font-bold break-all">
                  {result4D.a.toFixed(2)} + ({result4D.b.toFixed(2)})·ι + ({result4D.c.toFixed(2)})·ϖ + ({result4D.d.toFixed(2)})·ϑ
                </div>
                <div className="text-xs font-mono text-slate-400 pt-2 border-t border-slate-800">
                  Spectral Phase Angle θ = <span className="text-cyan-400 font-bold">{resultPhase.toFixed(2)}°</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* CLIFFORD Cl(4,1,1) SECTION */}
      {activeSubTab === 'cl411' && (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-6 space-y-6">
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 space-y-4 shadow-xl">
              <div className="flex items-center justify-between border-b border-slate-800 pb-3">
                <h3 className="font-bold text-white text-sm">Quaternion Subalgebra H ⊂ Cl(4,1,1)</h3>
                <span className="text-xs font-mono text-indigo-400">bivectors {`{e23, e31, e12}`}</span>
              </div>

              <div className="space-y-3">
                <div className="text-xs font-mono text-slate-300">Quaternion Q₁ = w₁ + i₁·e₂₃ + j₁·e₃₁ + k₁·e₁₂</div>
                <div className="grid grid-cols-4 gap-2">
                  {['w', 'i', 'j', 'k'].map((comp) => (
                    <div key={comp}>
                      <label className="text-[10px] font-mono text-slate-400 uppercase">{comp}1:</label>
                      <input
                        type="number" step="0.1" value={(q1 as any)[comp]}
                        onChange={(e) => setQ1({ ...q1, [comp]: parseFloat(e.target.value) || 0 })}
                        className="w-full px-2 py-1 bg-slate-950 border border-slate-800 rounded text-xs text-white font-mono"
                      />
                    </div>
                  ))}
                </div>
              </div>

              <div className="space-y-3 pt-3 border-t border-slate-800">
                <div className="text-xs font-mono text-slate-300">Quaternion Q₂ = w₂ + i₂·e₂₃ + j₂·e₃₁ + k₂·e₁₂</div>
                <div className="grid grid-cols-4 gap-2">
                  {['w', 'i', 'j', 'k'].map((comp) => (
                    <div key={comp}>
                      <label className="text-[10px] font-mono text-slate-400 uppercase">{comp}2:</label>
                      <input
                        type="number" step="0.1" value={(q2 as any)[comp]}
                        onChange={(e) => setQ2({ ...q2, [comp]: parseFloat(e.target.value) || 0 })}
                        className="w-full px-2 py-1 bg-slate-950 border border-slate-800 rounded text-xs text-white font-mono"
                      />
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          <div className="lg:col-span-6 space-y-6">
            <div className="bg-slate-900 border border-indigo-500/30 rounded-2xl p-6 shadow-2xl space-y-4">
              <div className="flex items-center justify-between border-b border-slate-800 pb-3">
                <h3 className="font-bold text-white text-base">Clifford Geometric Product Q₁ · Q₂</h3>
                <span className="text-xs font-mono text-emerald-400">Norm: {mvNormProd.toFixed(4)}</span>
              </div>

              <div className="p-4 bg-slate-950 rounded-xl border border-slate-800 space-y-2 font-mono text-xs">
                <div className="text-amber-300 font-bold text-sm">
                  Scalar: {mvProd.scalar.toFixed(3)}
                </div>
                <div className="text-indigo-300">
                  Bivector e₂₃ (i): {mvProd.e23.toFixed(3)}
                </div>
                <div className="text-indigo-300">
                  Bivector e₃₁ (j): {mvProd.e31.toFixed(3)}
                </div>
                <div className="text-indigo-300">
                  Bivector e₁₂ (k): {mvProd.e12.toFixed(3)}
                </div>
              </div>

              <p className="text-xs text-slate-400 leading-relaxed">
                Notice that i² = (e₂₃)² = e₂₃ e₂₃ = -e₂ e₃ e₃ e₂ = -1, validating standard quaternion Hamilton dynamics within the 6-dimensional Clifford algebra Cl(4,1,1).
              </p>
            </div>
          </div>
        </div>
      )}

      {/* DISCRETE SPECTRUM & RATIONAL GRID SECTION */}
      {activeSubTab === 'nonstandard' && (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-6 space-y-6">
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 space-y-4 shadow-xl">
              <div className="border-b border-slate-800 pb-3">
                <h3 className="font-bold text-white text-sm">Discrete Spectrum Number x = st(x) + ε · a + δ · b</h3>
                <p className="text-xs text-slate-400 mt-1">Nilpotent boundary residual ε = ϖ ϑ and discrete partition grid step size δ = 1/N.</p>
              </div>

              <div className="space-y-3">
                <div className="text-xs font-mono text-slate-300">Discrete Element D₁ = {hr1.st} + {hr1.eps}·ε + {hr1.omega}·δ</div>
                <div className="grid grid-cols-3 gap-2">
                  <div>
                    <label className="text-[10px] font-mono text-slate-400">Scalar Part:</label>
                    <input
                      type="number" value={hr1.st} onChange={(e) => setHr1({ ...hr1, st: parseFloat(e.target.value) || 0 })}
                      className="w-full px-2 py-1 bg-slate-950 border border-slate-800 rounded text-xs text-white font-mono"
                    />
                  </div>
                  <div>
                    <label className="text-[10px] font-mono text-slate-400">Nilpotent ε:</label>
                    <input
                      type="number" value={hr1.eps} onChange={(e) => setHr1({ ...hr1, eps: parseFloat(e.target.value) || 0 })}
                      className="w-full px-2 py-1 bg-slate-950 border border-slate-800 rounded text-xs text-white font-mono"
                    />
                  </div>
                  <div>
                    <label className="text-[10px] font-mono text-slate-400">Grid Step δ:</label>
                    <input
                      type="number" value={hr1.omega} onChange={(e) => setHr1({ ...hr1, omega: parseFloat(e.target.value) || 0 })}
                      className="w-full px-2 py-1 bg-slate-950 border border-slate-800 rounded text-xs text-white font-mono"
                    />
                  </div>
                </div>
              </div>

              <div className="space-y-3 pt-3 border-t border-slate-800">
                <div className="text-xs font-mono text-slate-300">Discrete Element D₂ = {hr2.st} + {hr2.eps}·ε + {hr2.omega}·δ</div>
                <div className="grid grid-cols-3 gap-2">
                  <div>
                    <label className="text-[10px] font-mono text-slate-400">Scalar Part:</label>
                    <input
                      type="number" value={hr2.st} onChange={(e) => setHr2({ ...hr2, st: parseFloat(e.target.value) || 0 })}
                      className="w-full px-2 py-1 bg-slate-950 border border-slate-800 rounded text-xs text-white font-mono"
                    />
                  </div>
                  <div>
                    <label className="text-[10px] font-mono text-slate-400">Nilpotent ε:</label>
                    <input
                      type="number" value={hr2.eps} onChange={(e) => setHr2({ ...hr2, eps: parseFloat(e.target.value) || 0 })}
                      className="w-full px-2 py-1 bg-slate-950 border border-slate-800 rounded text-xs text-white font-mono"
                    />
                  </div>
                  <div>
                    <label className="text-[10px] font-mono text-slate-400">Grid Step δ:</label>
                    <input
                      type="number" value={hr2.omega} onChange={(e) => setHr2({ ...hr2, omega: parseFloat(e.target.value) || 0 })}
                      className="w-full px-2 py-1 bg-slate-950 border border-slate-800 rounded text-xs text-white font-mono"
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="lg:col-span-6 space-y-6">
            <div className="bg-slate-900 border border-indigo-500/30 rounded-2xl p-6 shadow-2xl space-y-4">
              <h3 className="font-bold text-white text-base border-b border-slate-800 pb-3">Discrete Spectrum Algebra Evaluation</h3>

              <div className="space-y-3">
                <div className="p-3 bg-slate-950 rounded-xl border border-slate-800 font-mono text-xs">
                  <div className="text-indigo-400 font-bold">N₁ + N₂:</div>
                  <div className="text-white text-sm font-bold mt-1">
                    {hrSum.st} + ({hrSum.eps})·ε + ({hrSum.omega})·ω
                  </div>
                  <div className="text-slate-400 text-[11px] mt-1">
                    st(N₁ + N₂) = <span className="text-emerald-400 font-bold">{standardPart(hrSum)}</span>
                  </div>
                </div>

                <div className="p-3 bg-slate-950 rounded-xl border border-slate-800 font-mono text-xs">
                  <div className="text-indigo-400 font-bold">N₁ · N₂ (using ε · ω = 1):</div>
                  <div className="text-white text-sm font-bold mt-1">
                    {hrProd.st} + ({hrProd.eps})·ε + ({hrProd.omega})·ω
                  </div>
                  <div className="text-slate-400 text-[11px] mt-1">
                    st(N₁ · N₂) = <span className="text-emerald-400 font-bold">{standardPart(hrProd)}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* JAYNESIAN MAXENT SECTION */}
      {activeSubTab === 'maxent' && (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-5 space-y-6">
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 space-y-4 shadow-xl">
              <div className="border-b border-slate-800 pb-3">
                <h3 className="font-bold text-white text-sm">Jaynesian MaxEnt Lagrange Multipliers</h3>
                <p className="text-xs text-slate-400 mt-1">P(x) = (1/Z) exp(- λ₁·x - λ₂·x²)</p>
              </div>

              <div className="space-y-3">
                <div>
                  <label className="text-xs font-mono text-slate-400 flex justify-between">
                    <span>Linear Constraint λ₁:</span>
                    <span className="text-indigo-300 font-bold">{lambda1.toFixed(2)}</span>
                  </label>
                  <input
                    type="range" min="0.01" max="2" step="0.05" value={lambda1}
                    onChange={(e) => setLambda1(parseFloat(e.target.value))}
                    className="w-full accent-indigo-400 cursor-pointer"
                  />
                </div>

                <div>
                  <label className="text-xs font-mono text-slate-400 flex justify-between">
                    <span>Quadratic Constraint λ₂:</span>
                    <span className="text-indigo-300 font-bold">{lambda2.toFixed(2)}</span>
                  </label>
                  <input
                    type="range" min="0.01" max="1" step="0.02" value={lambda2}
                    onChange={(e) => setLambda2(parseFloat(e.target.value))}
                    className="w-full accent-indigo-400 cursor-pointer"
                  />
                </div>
              </div>

              <div className="pt-3 border-t border-slate-800">
                <div className="text-xs font-mono text-slate-400">
                  Total Information Entropy S[P]:{' '}
                  <span className="text-amber-300 font-bold text-sm">{totalEntropy.toFixed(4)} nats</span>
                </div>
              </div>
            </div>
          </div>

          <div className="lg:col-span-7 space-y-6">
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-2xl space-y-4">
              <h3 className="font-bold text-white text-sm">MaxEnt Probability Density P(x) Curve</h3>

              <div className="w-full h-52 bg-slate-950 rounded-xl border border-slate-800 p-2 relative flex items-end justify-between overflow-hidden">
                {maxEntStates.map((st, i) => {
                  const heightPct = Math.min(100, Math.max(2, st.prob * 500));
                  return (
                    <div
                      key={i}
                      style={{ height: `${heightPct}%` }}
                      className="w-2 bg-indigo-500 hover:bg-amber-400 transition-all rounded-t"
                      title={`x=${st.x.toFixed(2)}, P(x)=${st.prob.toFixed(4)}`}
                    />
                  );
                })}
              </div>

              <p className="text-xs text-slate-400 leading-relaxed">
                Objective Jaynesian distribution maximizes Shannon entropy S[P] = -∑ P_i ln P_i subject to mean energy constraints, guaranteeing tautological non-biased priors in Iris number theory.
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
