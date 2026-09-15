import React, { useState } from 'react';
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
  mresDownarrowGrid,
  mresDownarrowRate,
  simulateStiffSystem,
  Mjet3
} from '../lib/mresAnalysis';
import {
  Layers,
  ArrowDownCircle,
  Activity,
  Calculator,
  ChevronRight,
  TrendingDown
} from 'lucide-react';
import {
  ResponsiveContainer,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend
} from 'recharts';

export const MresNumericalWorkbench: React.FC = () => {
  // Graded Arithmetic state
  const [valA, setValA] = useState<number>(3.0);
  const [valB, setValB] = useState<number>(4.0);

  const grade1A = mres1(valA);
  const grade1B = mres1(valB);
  const prodGrade2 = mres1MulMres1(grade1A, grade1B);
  const prodGrade3 = mres1MulMres2(grade1A, prodGrade2);

  // Composite Jet State
  const [jetC0, setJetC0] = useState<number>(2.0);
  const [jetC1, setJetC1] = useState<number>(1.5);
  const [jetC2, setJetC2] = useState<number>(-0.5);
  const [jetC3, setJetC3] = useState<number>(0.25);

  const sampleJet: Mjet3 = mjet3(
    jetC0,
    mres1(jetC1),
    mres2(jetC2),
    mres3(jetC3)
  );

  let invJet: Mjet3 | null = null;
  let invError = '';
  try {
    invJet = mjetInv(sampleJet);
  } catch (err: unknown) {
    invError = err instanceof Error ? err.message : String(err);
  }

  // Downarrow Operations on sampleJet
  const down0 = mresDownarrow0(sampleJet);
  const downGrid01 = mresDownarrowGrid(sampleJet, 0.1);
  const rate1 = mresDownarrowRate(sampleJet, 1);
  const rate2 = mresDownarrowRate(sampleJet, 2);

  // Stiff System State
  const [lambda, setLambda] = useState<number>(1000);
  const [stepSize, setStepSize] = useState<number>(0.01);
  const [initialY, setInitialY] = useState<number>(1.0);
  const [sourceType, setSourceType] = useState<'none' | 'constant' | 'sine'>('none');

  const getSourceFn = () => {
    if (sourceType === 'constant') return () => 5.0;
    if (sourceType === 'sine') return (t: number) => Math.sin(10 * t);
    return undefined;
  };

  const stiffData = simulateStiffSystem(
    lambda,
    initialY,
    stepSize,
    20,
    getSourceFn()
  );

  const eulerThreshold = 2.0 / lambda;
  const isEulerUnstable = stepSize > eulerThreshold;

  return (
    <div className="space-y-8 text-slate-100">
      {/* Overview Card */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
        <div className="flex items-center space-x-3 mb-2">
          <Layers className="w-6 h-6 text-emerald-400" />
          <h2 className="text-xl font-bold text-white tracking-tight">
            m-Resolution Graded Numerical Analysis
          </h2>
        </div>
        <p className="text-slate-400 text-sm max-w-4xl leading-relaxed">
          Unlike remainder-term interval tracking, genuine m-res numerical analysis operates on
          distinct, typed algebraic grades: <code className="text-emerald-300 font-mono">real_t</code> (Grade 0),{' '}
          <code className="text-emerald-300 font-mono">mres1_t</code> (Grade 1, pure \(\mu\)),{' '}
          <code className="text-emerald-300 font-mono">mres2_t</code> (Grade 2, pure \(\mu^2\)), and{' '}
          <code className="text-emerald-300 font-mono">mres3_t</code> (Grade 3, pure \(\mu^3\)).
          Composite multi-grade objects are designated <code className="text-amber-300 font-mono">mjet_t</code> and are
          never called m-res numbers. Macroscopic observables and grid values are extracted strictly
          via typed <code className="text-indigo-300 font-mono">\downarrow</code> downarrow operations.
        </p>
      </div>

      {/* Grid: Graded Typing + Composite Jet Inversion */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Graded Multiplication (Fontijne Style) */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 space-y-4">
          <div className="flex items-center justify-between border-b border-slate-800 pb-3">
            <div className="flex items-center space-x-2">
              <Calculator className="w-4 h-4 text-emerald-400" />
              <h3 className="font-semibold text-slate-200 text-sm">
                Pure Graded Multiplications (Fontijne Separation)
              </h3>
            </div>
            <span className="text-xs font-mono text-emerald-400 bg-emerald-950/60 px-2 py-0.5 rounded border border-emerald-800">
              Grade j × Grade k → Grade (j+k)
            </span>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="text-xs text-slate-400 block mb-1">
                Grade 1 Coefficient a (val · μ):
              </label>
              <input
                type="number"
                value={valA}
                onChange={(e) => setValA(parseFloat(e.target.value) || 0)}
                className="w-full bg-slate-950 border border-slate-800 rounded px-3 py-1.5 font-mono text-sm text-emerald-400 focus:outline-none focus:border-emerald-500"
              />
            </div>
            <div>
              <label className="text-xs text-slate-400 block mb-1">
                Grade 1 Coefficient b (val · μ):
              </label>
              <input
                type="number"
                value={valB}
                onChange={(e) => setValB(parseFloat(e.target.value) || 0)}
                className="w-full bg-slate-950 border border-slate-800 rounded px-3 py-1.5 font-mono text-sm text-emerald-400 focus:outline-none focus:border-emerald-500"
              />
            </div>
          </div>

          <div className="bg-slate-950 border border-slate-800/80 rounded-xl p-4 font-mono text-xs space-y-2">
            <div className="flex justify-between items-center text-slate-300">
              <span>Input a:</span>
              <span className="text-emerald-400">mres1_t({valA.toFixed(2)} · μ)</span>
            </div>
            <div className="flex justify-between items-center text-slate-300">
              <span>Input b:</span>
              <span className="text-emerald-400">mres1_t({valB.toFixed(2)} · μ)</span>
            </div>
            <div className="h-px bg-slate-800 my-1" />
            <div className="flex justify-between items-center text-slate-200">
              <span className="flex items-center gap-1 text-slate-400">
                <ChevronRight className="w-3 h-3 text-emerald-400" />
                mres1_mul_mres1(a, b):
              </span>
              <span className="text-amber-400 font-bold">
                mres2_t({prodGrade2.val.toFixed(2)} · μ²)
              </span>
            </div>
            <div className="flex justify-between items-center text-slate-200">
              <span className="flex items-center gap-1 text-slate-400">
                <ChevronRight className="w-3 h-3 text-emerald-400" />
                mres1_mul_mres2(a, prodGrade2):
              </span>
              <span className="text-cyan-400 font-bold">
                mres3_t({prodGrade3.val.toFixed(2)} · μ³)
              </span>
            </div>
            <div className="flex justify-between items-center text-slate-400 text-[11px] pt-1 border-t border-slate-800">
              <span>Product above Grade 3:</span>
              <span className="text-slate-500">Truncated (μ⁴ ≡ 0 on discrete grid)</span>
            </div>
          </div>
        </div>

        {/* Composite Jet & Exact Nilpotent Inversion */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 space-y-4">
          <div className="flex items-center justify-between border-b border-slate-800 pb-3">
            <div className="flex items-center space-x-2">
              <Activity className="w-4 h-4 text-amber-400" />
              <h3 className="font-semibold text-slate-200 text-sm">
                Composite Jet Inversion (Nilpotent Series)
              </h3>
            </div>
            <span className="text-xs font-mono text-amber-400 bg-amber-950/60 px-2 py-0.5 rounded border border-amber-800">
              mjet3_t Ring
            </span>
          </div>

          <div className="grid grid-cols-4 gap-2">
            <div>
              <label className="text-[11px] text-slate-400 block mb-1">c0 (real)</label>
              <input
                type="number"
                value={jetC0}
                onChange={(e) => setJetC0(parseFloat(e.target.value) || 0)}
                className="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 font-mono text-xs text-slate-200"
              />
            </div>
            <div>
              <label className="text-[11px] text-slate-400 block mb-1">c1 (μ)</label>
              <input
                type="number"
                value={jetC1}
                onChange={(e) => setJetC1(parseFloat(e.target.value) || 0)}
                className="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 font-mono text-xs text-emerald-400"
              />
            </div>
            <div>
              <label className="text-[11px] text-slate-400 block mb-1">c2 (μ²)</label>
              <input
                type="number"
                value={jetC2}
                onChange={(e) => setJetC2(parseFloat(e.target.value) || 0)}
                className="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 font-mono text-xs text-amber-400"
              />
            </div>
            <div>
              <label className="text-[11px] text-slate-400 block mb-1">c3 (μ³)</label>
              <input
                type="number"
                value={jetC3}
                onChange={(e) => setJetC3(parseFloat(e.target.value) || 0)}
                className="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 font-mono text-xs text-cyan-400"
              />
            </div>
          </div>

          <div className="bg-slate-950 border border-slate-800/80 rounded-xl p-3 font-mono text-xs space-y-1.5">
            <div className="text-slate-400 text-[11px] mb-1">
              Jet: X = {jetC0} + ({jetC1})μ + ({jetC2})μ² + ({jetC3})μ³
            </div>
            {invError ? (
              <div className="text-rose-400">{invError}</div>
            ) : invJet ? (
              <div>
                <div className="text-emerald-400 font-semibold mb-1">
                  Exact Inversion X⁻¹ (Closed-form Neumann Expansion):
                </div>
                <div className="text-slate-300">
                  {invJet.c0.toFixed(4)} + ({invJet.c1.val.toFixed(4)})μ + ({invJet.c2.val.toFixed(4)})μ² + ({invJet.c3.val.toFixed(4)})μ³
                </div>
              </div>
            ) : null}
          </div>

          {/* Downarrow Projections */}
          <div className="border-t border-slate-800 pt-3">
            <div className="text-xs font-semibold text-slate-300 flex items-center gap-1 mb-2">
              <ArrowDownCircle className="w-3.5 h-3.5 text-indigo-400" />
              Typed Downarrow Projections (↓):
            </div>
            <div className="grid grid-cols-2 gap-2 text-xs font-mono">
              <div className="bg-slate-950/60 p-2 rounded border border-slate-800/80">
                <span className="text-slate-400 block text-[10px]">Observable Extract:</span>
                <span className="text-indigo-400 font-bold">↓₀(X) = {down0.toFixed(4)}</span>
              </div>
              <div className="bg-slate-950/60 p-2 rounded border border-slate-800/80">
                <span className="text-slate-400 block text-[10px]">Grid Project (dx=0.1):</span>
                <span className="text-indigo-400 font-bold">↓_grid(X) = {downGrid01.toFixed(4)}</span>
              </div>
              <div className="bg-slate-950/60 p-2 rounded border border-slate-800/80">
                <span className="text-slate-400 block text-[10px]">Rate 1 (1!·c1):</span>
                <span className="text-emerald-400 font-bold">↓_rate1 = {rate1.toFixed(4)}</span>
              </div>
              <div className="bg-slate-950/60 p-2 rounded border border-slate-800/80">
                <span className="text-slate-400 block text-[10px]">Rate 2 (2!·c2):</span>
                <span className="text-amber-400 font-bold">↓_rate2 = {rate2.toFixed(4)}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Stiff Differential Equation Simulator */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-6">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-3 border-b border-slate-800 pb-4">
          <div>
            <div className="flex items-center space-x-2">
              <TrendingDown className="w-5 h-5 text-indigo-400" />
              <h3 className="text-lg font-bold text-white">
                Stiff System Resolution: Classical Explosion vs. m-res Jet Stability
              </h3>
            </div>
            <p className="text-slate-400 text-xs mt-1">
              System: <code className="text-indigo-300 font-mono">dy/dt = -λ·y + g(t)</code>. Classical Euler explodes when <code className="text-rose-400 font-mono">Δt &gt; 2/λ</code>.
              The m-res jet solves the fast boundary layer and slow manifold algebraically without tiny sub-stepping!
            </p>
          </div>

          <div className="flex items-center gap-2">
            <span
              className={`px-2.5 py-1 text-xs font-mono rounded border ${
                isEulerUnstable
                  ? 'bg-rose-950/70 border-rose-800 text-rose-300'
                  : 'bg-emerald-950/70 border-emerald-800 text-emerald-300'
              }`}
            >
              {isEulerUnstable
                ? `Classical Euler: UNSTABLE (Δt > ${eulerThreshold.toFixed(4)})`
                : 'Classical Euler: Stable'}
            </span>
          </div>
        </div>

        {/* Controls */}
        <div className="grid grid-cols-1 sm:grid-cols-4 gap-4 bg-slate-950/70 p-4 rounded-xl border border-slate-800">
          <div>
            <label className="text-xs text-slate-400 block mb-1">
              Stiffness Parameter λ: <span className="font-mono text-indigo-300">{lambda}</span>
            </label>
            <input
              type="range"
              min="100"
              max="5000"
              step="100"
              value={lambda}
              onChange={(e) => setLambda(parseInt(e.target.value))}
              className="w-full accent-indigo-500"
            />
          </div>

          <div>
            <label className="text-xs text-slate-400 block mb-1">
              Macroscopic Step Δt: <span className="font-mono text-indigo-300">{stepSize}</span>
            </label>
            <input
              type="range"
              min="0.001"
              max="0.05"
              step="0.001"
              value={stepSize}
              onChange={(e) => setStepSize(parseFloat(e.target.value))}
              className="w-full accent-indigo-500"
            />
          </div>

          <div>
            <label className="text-xs text-slate-400 block mb-1">
              Initial State y(0): <span className="font-mono text-indigo-300">{initialY}</span>
            </label>
            <input
              type="number"
              value={initialY}
              onChange={(e) => setInitialY(parseFloat(e.target.value) || 0)}
              className="w-full bg-slate-900 border border-slate-800 rounded px-2 py-1 font-mono text-xs text-white"
            />
          </div>

          <div>
            <label className="text-xs text-slate-400 block mb-1">Driving Source g(t):</label>
            <select
              value={sourceType}
              onChange={(e) => setSourceType(e.target.value as any)}
              className="w-full bg-slate-900 border border-slate-800 rounded px-2 py-1 font-mono text-xs text-white"
            >
              <option value="none">Zero Source (Pure Decay)</option>
              <option value="constant">Constant Source (g=5.0)</option>
              <option value="sine">Harmonic Wave (g=sin(10t))</option>
            </select>
          </div>
        </div>

        {/* Simulation Chart */}
        <div className="h-72 w-full bg-slate-950/60 p-3 rounded-xl border border-slate-800">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={stiffData} margin={{ top: 10, right: 30, left: 10, bottom: 5 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#262626" />
              <XAxis
                dataKey="t"
                stroke="#737373"
                tick={{ fontSize: 11 }}
                tickFormatter={(t) => t.toFixed(3)}
              />
              <YAxis
                stroke="#737373"
                tick={{ fontSize: 11 }}
                domain={[-2, Math.max(initialY * 1.2, 6)]}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: '#0f172a',
                  borderColor: '#334155',
                  borderRadius: '8px',
                  fontSize: '12px'
                }}
                formatter={(value: any) => [
                  typeof value === 'number' ? value.toFixed(4) : value,
                  ''
                ]}
                labelFormatter={(t: any) => `t = ${Number(t).toFixed(3)}`}
              />
              <Legend wrapperStyle={{ fontSize: '12px' }} />
              <Line
                type="monotone"
                dataKey="yMres"
                name="m-res Jet Solver (Stable)"
                stroke="#10b981"
                strokeWidth={2.5}
                dot={{ r: 3, fill: '#10b981' }}
              />
              <Line
                type="monotone"
                dataKey="yEuler"
                name="Classical Forward Euler"
                stroke="#f43f5e"
                strokeWidth={1.5}
                strokeDasharray="4 4"
                dot={{ r: 2, fill: '#f43f5e' }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Readout Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-xs font-mono text-left border-collapse">
            <thead>
              <tr className="border-b border-slate-800 text-slate-400">
                <th className="py-2 px-3">Step</th>
                <th className="py-2 px-3">Time t</th>
                <th className="py-2 px-3 text-emerald-400">m-res Solution (y)</th>
                <th className="py-2 px-3 text-rose-400">Classical Euler</th>
                <th className="py-2 px-3 text-slate-400">Euler Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/60">
              {stiffData.slice(0, 8).map((pt, idx) => (
                <tr key={idx} className="hover:bg-slate-800/30">
                  <td className="py-1.5 px-3 text-slate-500">{idx}</td>
                  <td className="py-1.5 px-3 text-slate-300">{pt.t.toFixed(3)}</td>
                  <td className="py-1.5 px-3 text-emerald-400 font-semibold">
                    {pt.yMres.toFixed(6)}
                  </td>
                  <td className="py-1.5 px-3 text-rose-400">
                    {pt.eulerExploded ? '±∞ (Exploded)' : pt.yEuler.toFixed(6)}
                  </td>
                  <td className="py-1.5 px-3">
                    {pt.eulerExploded ? (
                      <span className="text-rose-500 font-bold">Diverged</span>
                    ) : (
                      <span className="text-slate-400">Bounded</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
