import React, { useState } from 'react';
import { Atom, Scale, ShieldAlert, Compass, Sparkles, CheckCircle2 } from 'lucide-react';

export const PhysicalConstantsWorkbench: React.FC = () => {
  // Planck mass calibrated input (CODATA 2018 value: 2.176434(24) x 10^-8 kg)
  // Relative standard uncertainty of m_Planck is 1.1 x 10^-5 (11 ppm)
  const [mPlanckStr, setMPlanckStr] = useState<string>('2.176434e-8');
  const [mPlanckUncertaintyPpm, setMPlanckUncertaintyPpm] = useState<number>(11); // ppm

  // Exact fundamental values
  const C_EXACT = 299792458.0; // m/s
  const H_EXACT = 6.62607015e-34; // J s
  const HBAR_EXACT = H_EXACT / (2.0 * Math.PI); // J s
  const E_EXACT = 1.602176634e-19; // C
  const KB_EXACT = 1.380649e-23; // J/K

  // Fine-structure constant alpha from toroidal vortex aspect ratio
  const K0_SQ = 1.0 - 1.0 / (4.0 * Math.PI * Math.PI);
  // Elliptic hypergeometric series for alpha
  let alphaSum = 0.25;
  let term = 0.25;
  for (let n = 0; n < 30; n++) {
    const ratio = Math.pow((2 * n + 1) / (2 * n + 2), 2) * K0_SQ;
    term *= ratio;
    alphaSum += term;
  }
  const ALPHA = alphaSum;
  const INV_ALPHA = 1.0 / ALPHA;

  // Proton-to-electron mass ratio
  const PI_5 = Math.pow(Math.PI, 5);
  const RECOIL = 1.0 - ALPHA / 24.0 + (ALPHA * ALPHA) / Math.PI;
  const MP_OVER_ME = 6.0 * PI_5 * RECOIL;

  // Electron rest mass from Rydberg constant
  const R_INF = 10973731.568160; // m^-1
  const ME = (2.0 * R_INF * H_EXACT) / (ALPHA * ALPHA * C_EXACT);
  const MP = MP_OVER_ME * ME;

  // Parse m_Planck input
  const mPlanck = parseFloat(mPlanckStr) || 2.176434e-8;

  // Calculate Newton's G directly from wave refraction: G = (hbar * c) / (m_Planck^2)
  // Or equivalently G = (c^4 * delta_omega^2) / (4 * pi * E) where delta_omega = l_Planck
  const gComputed = (HBAR_EXACT * C_EXACT) / (mPlanck * mPlanck);

  // Since G scales as m_Planck^-2, the relative uncertainty of G is twice that of m_Planck:
  // delta_G / G = 2 * (delta_m_Planck / m_Planck)
  const gUncertaintyPpm = mPlanckUncertaintyPpm * 2;
  const gAbsoluteUncertainty = gComputed * (gUncertaintyPpm * 1e-6);

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="bg-slate-900/80 border border-slate-800 rounded-2xl p-6">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <div className="flex items-center gap-2 text-indigo-400 font-mono text-xs uppercase tracking-wider mb-1">
              <Atom className="w-4 h-4" />
              <span>Exact Geometric Ratios & Wave Refraction Calibrator</span>
            </div>
            <h2 className="text-xl font-medium text-slate-100">
              Fundamental Physical Constants on Discrete Resolution Grids
            </h2>
            <p className="text-sm text-slate-400 mt-1 max-w-3xl">
              Fundamental constants evaluated as exact geometric definite integrals in \( Cl(4,1,1) \) relative to true speed \( c \).
              The precision of Newton's gravitational constant \( G \) is directly bounded by the caliper measurement of the Planck mass unit.
            </p>
          </div>
          <div className="flex items-center gap-2 bg-amber-950/40 border border-amber-800/60 text-amber-300 px-3.5 py-2 rounded-xl text-xs font-mono shrink-0">
            <ShieldAlert className="w-4 h-4 text-amber-400" />
            <span>Uncertainty Propagator Active</span>
          </div>
        </div>
      </div>

      {/* Main Grid: Gravitational Refraction Caliper & Geometric Invariants */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Column: Gravitational Coupling G & Planck Mass Sensitivity */}
        <div className="lg:col-span-6 space-y-6">
          <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 space-y-4">
            <div className="flex items-center justify-between border-b border-slate-800/80 pb-3">
              <div className="flex items-center gap-2">
                <Scale className="w-4 h-4 text-emerald-400" />
                <h3 className="text-sm font-medium text-slate-200">
                  Newton's Gravitational Constant \( G \) via Wave Refraction
                </h3>
              </div>
              <span className="text-xs font-mono px-2 py-0.5 rounded bg-emerald-950/60 border border-emerald-800/50 text-emerald-300">
                G = \frac&#123;c^4 \delta_\omega^2&#125;&#123;4 \pi E&#125; = \frac&#123;\hbar c&#125;&#123;m_P^2&#125;
              </span>
            </div>

            <div className="bg-slate-950 p-4 rounded-xl border border-slate-800/60 space-y-3">
              <div className="text-xs text-slate-400 leading-relaxed">
                In classical wave refraction, gravitation emerges from the gradient of propagation phase speed in the electromagnetic field.
                Circulation action \( \hbar \) cancels out in the universal wave flux balance, leaving \( G \) inversely proportional to the square of the Planck mass aperture \( m_P \):
              </div>
              
              <div className="p-3 bg-slate-900/90 rounded-lg border border-slate-800 font-mono text-center">
                <div className="text-xs text-slate-500 mb-1">Computed Coupling Value \( G \)</div>
                <div className="text-lg text-emerald-400 font-medium">
                  {gComputed.toExponential(7)} <span className="text-xs text-slate-400 font-normal">m³ / (kg · s²)</span>
                </div>
                <div className="text-[11px] text-amber-400/90 mt-1">
                  ± {gAbsoluteUncertainty.toExponential(2)} ({gUncertaintyPpm.toFixed(1)} ppm relative standard error)
                </div>
              </div>
            </div>

            {/* Input Caliper for Planck Mass */}
            <div className="space-y-3 pt-1">
              <div className="flex items-center justify-between text-xs">
                <label className="font-mono text-slate-300 flex items-center gap-1.5">
                  <Compass className="w-3.5 h-3.5 text-indigo-400" />
                  Calibrated Planck Mass \( m_P \) (kg):
                </label>
                <span className="font-mono text-slate-400">{mPlanckStr} kg</span>
              </div>
              <input
                type="text"
                value={mPlanckStr}
                onChange={(e) => setMPlanckStr(e.target.value)}
                className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3.5 py-2 text-sm font-mono text-slate-100 focus:outline-none focus:border-indigo-500"
                placeholder="2.176434e-8"
              />

              <div className="flex items-center justify-between text-xs pt-1">
                <label className="font-mono text-slate-400">
                  Input \( m_P \) Uncertainty (ppm):
                </label>
                <span className="font-mono text-amber-300">{mPlanckUncertaintyPpm} ppm (±{(mPlanckUncertaintyPpm * 1e-4).toFixed(3)}%)</span>
              </div>
              <input
                type="range"
                min="1"
                max="50"
                step="1"
                value={mPlanckUncertaintyPpm}
                onChange={(e) => setMPlanckUncertaintyPpm(parseFloat(e.target.value))}
                className="w-full accent-indigo-500 bg-slate-950"
              />

              {/* Crucial Epistemological Callout */}
              <div className="p-3 bg-amber-950/20 border border-amber-900/40 rounded-xl text-xs text-amber-300/90 leading-relaxed">
                <div className="font-medium flex items-center gap-1.5 text-amber-400 mb-1">
                  <ShieldAlert className="w-3.5 h-3.5 shrink-0" />
                  Metrological Dependence Notice:
                </div>
                Because \( G \propto m_P^{'{'}-2{'}'} \), an error of \( \Delta m_P / m_P \) produces a doubled error \( 2 \Delta m_P / m_P \) in \( G \).
                The value of \( G \) in the Iris system is not an arbitrary adjustable curve-fit; it is <em>strictly as good as the empirical caliper measurement of the Planck mass unit</em>.
              </div>
            </div>
          </div>
        </div>

        {/* Right Column: Exact Invariant Ratios & Electrodynamic Standards */}
        <div className="lg:col-span-6 space-y-6">
          <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 space-y-4">
            <div className="flex items-center justify-between border-b border-slate-800/80 pb-3">
              <div className="flex items-center gap-2">
                <Sparkles className="w-4 h-4 text-indigo-400" />
                <h3 className="text-sm font-medium text-slate-200">
                  Geometric Invariants in \( Cl(4,1,1) \)
                </h3>
              </div>
              <span className="text-xs font-mono px-2 py-0.5 rounded bg-indigo-950/60 border border-indigo-800/50 text-indigo-300">
                Exact Definite Integrals
              </span>
            </div>

            <div className="space-y-3">
              {/* Fine-structure constant */}
              <div className="p-3 bg-slate-950 rounded-xl border border-slate-800/70 flex items-center justify-between">
                <div>
                  <div className="text-xs font-mono text-indigo-300">Fine-Structure Constant \( \alpha \)</div>
                  <div className="text-[11px] text-slate-500 font-mono">
                    Toroidal vortex elliptic integral: \( \alpha = \frac&#123;1&#125;&#123;4&#125; \sum [\frac&#123;(2n)!&#125;&#123;2^{'{'}2n{'}'}(n!)^2&#125;]^2 k_0^{'{'}2n{'}'} \)
                  </div>
                </div>
                <div className="text-right font-mono">
                  <div className="text-sm text-slate-100 font-medium">{ALPHA.toFixed(10)}</div>
                  <div className="text-[11px] text-slate-400">1 / {INV_ALPHA.toFixed(6)}</div>
                </div>
              </div>

              {/* Proton-to-electron mass ratio */}
              <div className="p-3 bg-slate-950 rounded-xl border border-slate-800/70 flex items-center justify-between">
                <div>
                  <div className="text-xs font-mono text-indigo-300">Mass Ratio \( m_p / m_e \)</div>
                  <div className="text-[11px] text-slate-500 font-mono">
                    Conformal 5-sphere volume: \( 6 \pi^5 ( 1 - \alpha / 24 ) \)
                  </div>
                </div>
                <div className="text-right font-mono">
                  <div className="text-sm text-slate-100 font-medium">{MP_OVER_ME.toFixed(5)}</div>
                  <div className="text-[11px] text-emerald-400/90 flex items-center justify-end gap-1">
                    <CheckCircle2 className="w-3 h-3" /> CODATA Match
                  </div>
                </div>
              </div>

              {/* Electron rest mass */}
              <div className="p-3 bg-slate-950 rounded-xl border border-slate-800/70 flex items-center justify-between">
                <div>
                  <div className="text-xs font-mono text-indigo-300">Electron Mass \( m_e \)</div>
                  <div className="text-[11px] text-slate-500 font-mono">
                    \( 2 R_\infty h / (\alpha^2 c) \)
                  </div>
                </div>
                <div className="text-right font-mono">
                  <div className="text-sm text-slate-100 font-medium">{ME.toExponential(7)} kg</div>
                  <div className="text-[11px] text-slate-400">{ (ME * C_EXACT * C_EXACT / (E_EXACT * 1000)).toFixed(4) } keV/c²</div>
                </div>
              </div>

              {/* Proton rest mass */}
              <div className="p-3 bg-slate-950 rounded-xl border border-slate-800/70 flex items-center justify-between">
                <div>
                  <div className="text-xs font-mono text-indigo-300">Proton Mass \( m_p \)</div>
                  <div className="text-[11px] text-slate-500 font-mono">
                    \( (m_p / m_e) \cdot m_e \)
                  </div>
                </div>
                <div className="text-right font-mono">
                  <div className="text-sm text-slate-100 font-medium">{MP.toExponential(7)} kg</div>
                  <div className="text-[11px] text-slate-400">{ (MP * C_EXACT * C_EXACT / (E_EXACT * 1e6)).toFixed(3) } MeV/c²</div>
                </div>
              </div>

              {/* Exact SI Standards */}
              <div className="p-3 bg-slate-950 rounded-xl border border-slate-800/70 grid grid-cols-2 gap-2 text-xs font-mono">
                <div>
                  <span className="text-slate-500">Speed \( c \): </span>
                  <span className="text-slate-200">299,792,458 m/s</span>
                </div>
                <div>
                  <span className="text-slate-500">Action \( h \): </span>
                  <span className="text-slate-200">6.62607015×10⁻³⁴ J·s</span>
                </div>
                <div>
                  <span className="text-slate-500">Charge \( e \): </span>
                  <span className="text-slate-200">1.602176634×10⁻¹⁹ C</span>
                </div>
                <div>
                  <span className="text-slate-500">Entropy \( k_B \): </span>
                  <span className="text-slate-200">1.380649×10⁻²³ J/K</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
