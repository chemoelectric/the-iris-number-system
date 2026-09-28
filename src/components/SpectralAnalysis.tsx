import React, { useState, useMemo } from 'react';
import {
  ResponsiveContainer,
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  ScatterChart,
  Scatter,
  ZAxis,
  Legend,
} from 'recharts';
import { computeIrisZeta, generateIrisPrimes, TAU } from '../lib/irisEngine';
import { Activity, Sliders, Sparkles, Filter, Info } from 'lucide-react';

export const SpectralAnalysis: React.FC = () => {
  const [sigma, setSigma] = useState<number>(0.5); // Re(s) = 0.5 (Critical line)
  const [maxT, setMaxT] = useState<number>(40);
  const [primeCount, setPrimeCount] = useState<number>(120);

  // Compute Zeta points along the line Re(s) = sigma
  const zetaData = useMemo(() => {
    const points = [];
    const step = 0.5;
    for (let t = 0; t <= maxT; t += step) {
      const zPoint = computeIrisZeta(sigma, t, 100);
      points.push({
        t: parseFloat(t.toFixed(1)),
        realPart: parseFloat(zPoint.realPart.toFixed(3)),
        imagPart: parseFloat(zPoint.imagPart.toFixed(3)),
        irisNorm: parseFloat(zPoint.irisNorm.toFixed(3)),
        isZeroCandidate: zPoint.isZeroCandidate,
      });
    }
    return points;
  }, [sigma, maxT]);

  // Generate Iris primes
  const primeData = useMemo(() => {
    return generateIrisPrimes(primeCount);
  }, [primeCount]);

  return (
    <div className="space-y-6">
      {/* Banner */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 relative overflow-hidden">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <div className="flex items-center space-x-2">
              <Activity className="w-6 h-6 text-cyan-400" />
              <h2 className="text-xl font-bold text-white">Zeta & Prime Spectral Visualizer</h2>
            </div>
            <p className="text-slate-400 text-sm mt-1 max-w-2xl">
              Examine the critical zeros of the Iris Zeta Function{' '}
              <span className="font-mono text-amber-300">{'ζ_I(s)'}</span> and golden ratio prime distribution over the Iris metric.
            </p>
          </div>

          <div className="flex items-center space-x-2">
            <span className="text-xs font-mono px-3 py-1.5 bg-slate-800 border border-slate-700 rounded-lg text-slate-300">
              Critical Line: Re(s) = {sigma}
            </span>
          </div>
        </div>
      </div>

      {/* Grid: Zeta Chart & Control (Full Width) */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-4 shadow-xl">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between border-b border-slate-800 pb-4 gap-3">
          <div>
            <h3 className="font-bold text-white text-base flex items-center space-x-2">
              <Sparkles className="w-4 h-4 text-amber-400" />
              <span>Iris Zeta Spectrum ζ_I(σ + i·t) Along Critical Line</span>
            </h3>
            <p className="text-xs text-slate-400">
              Plotting Real Part, Imaginary Part, and Iris Norm ||ζ_I|| over frequency range t ∈ [0, {maxT}]
            </p>
          </div>

          {/* Controls */}
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <span className="text-xs font-mono text-slate-400">Re(s) [σ]:</span>
              <input
                type="range"
                min="0.1"
                max="1.5"
                step="0.05"
                value={sigma}
                onChange={(e) => setSigma(parseFloat(e.target.value))}
                className="w-24 accent-amber-400 cursor-pointer"
              />
              <span className="text-xs font-mono text-amber-300 w-8">{sigma}</span>
            </div>

            <div className="flex items-center space-x-2">
              <span className="text-xs font-mono text-slate-400">Max t:</span>
              <input
                type="range"
                min="20"
                max="80"
                step="5"
                value={maxT}
                onChange={(e) => setMaxT(parseInt(e.target.value))}
                className="w-24 accent-cyan-400 cursor-pointer"
              />
              <span className="text-xs font-mono text-cyan-300 w-6">{maxT}</span>
            </div>
          </div>
        </div>

        {/* Recharts Line Chart */}
        <div className="w-full h-72 bg-slate-950 rounded-xl p-3 border border-slate-800">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={zetaData} margin={{ top: 10, right: 20, left: -10, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" />
              <XAxis dataKey="t" stroke="#64748b" tick={{ fontSize: 11, fill: '#94a3b8' }} label={{ value: 't (Frequency)', position: 'insideBottomRight', offset: -5, fill: '#94a3b8', fontSize: 10 }} />
              <YAxis stroke="#64748b" tick={{ fontSize: 11, fill: '#94a3b8' }} />
              <Tooltip
                contentStyle={{ backgroundColor: '#020617', borderColor: '#334155', borderRadius: '0.75rem', fontSize: '12px' }}
                itemStyle={{ fontFamily: 'monospace' }}
              />
              <Legend wrapperStyle={{ fontSize: '11px', fontFamily: 'monospace', paddingTop: '8px' }} />
              <Line type="monotone" dataKey="realPart" name="Re(ζ_I)" stroke="#f59e0b" strokeWidth={2} dot={false} />
              <Line type="monotone" dataKey="imagPart" name="Im(ζ_I)" stroke="#38bdf8" strokeWidth={2} dot={false} />
              <Line type="monotone" dataKey="irisNorm" name="Iris Norm ||ζ_I||" stroke="#10b981" strokeWidth={2.5} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Iris Primes Golden Spiral / Density */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-4 shadow-xl">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between border-b border-slate-800 pb-4 gap-3">
          <div>
            <h3 className="font-bold text-white text-base flex items-center space-x-2">
              <Filter className="w-4 h-4 text-indigo-400" />
              <span>Iris Prime Distribution & Golden Spiral Map</span>
            </h3>
            <p className="text-xs text-slate-400">
              Prime coordinates in the Iris ring ℤ[ι] organized by spectral density and modular residue mod 7
            </p>
          </div>

          <div className="flex items-center space-x-2">
            <span className="text-xs font-mono text-slate-400">Prime Count:</span>
            <input
              type="range"
              min="50"
              max="250"
              step="10"
              value={primeCount}
              onChange={(e) => setPrimeCount(parseInt(e.target.value))}
              className="w-28 accent-indigo-400 cursor-pointer"
            />
            <span className="text-xs font-mono text-indigo-300 w-8">{primeCount}</span>
          </div>
        </div>

        {/* Scatter Chart for Iris Primes Spiral */}
        <div className="w-full h-80 bg-slate-950 rounded-xl p-3 border border-slate-800 flex items-center justify-center">
          <ResponsiveContainer width="100%" height="100%">
            <ScatterChart margin={{ top: 20, right: 20, bottom: 20, left: 20 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" />
              <XAxis type="number" dataKey="a" name="Scalar Basis (a)" stroke="#64748b" tick={{ fontSize: 11, fill: '#94a3b8' }} />
              <YAxis type="number" dataKey="b" name="Iris Imaginary Basis (b)" stroke="#64748b" tick={{ fontSize: 11, fill: '#94a3b8' }} />
              <ZAxis type="number" dataKey="spectralDensity" range={[40, 200]} name="Density" />
              <Tooltip
                cursor={{ strokeDasharray: '3 3' }}
                contentStyle={{ backgroundColor: '#020617', borderColor: '#334155', borderRadius: '0.75rem', fontSize: '12px' }}
                formatter={(val: any, name: string) => [val, name]}
              />
              <Scatter name="Iris Primes" data={primeData} fill="#818cf8" />
            </ScatterChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
};
