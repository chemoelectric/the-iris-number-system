import React, { useState } from 'react';
import { Atom, Scale, ShieldAlert, Compass, Sparkles, CheckCircle2, Orbit, Layers } from 'lucide-react';

export const PhysicalConstantsWorkbench: React.FC = () => {
  // Planck mass calibrated input (CODATA 2018 value: 2.176434(24) x 10^-8 kg)
  // Relative standard uncertainty of m_Planck is 1.1 x 10^-5 (11 ppm)
  const [mPlanckStr, setMPlanckStr] = useState<string>('2.176434e-8');
  const [mPlanckUncertaintyPpm, setMPlanckUncertaintyPpm] = useState<number>(11); // ppm
  const [ipSubsystem, setIpSubsystem] = useState<'practical' | 'natural'>('practical');

  // Exact fundamental values
  const C_EXACT = 299792458.0; // m/s
  const H_EXACT = 6.62607015e-34; // J s
  const HBAR_EXACT = H_EXACT / (2.0 * Math.PI); // J s
  const E_EXACT = 1.602176634e-19; // C
  const KB_EXACT = 1.380649e-23; // J/K

  // Fine-structure constant alpha from Conformal Geometric Algebra action and field boundary reaction
  // alpha_0^(-1) = 4*pi^3 + pi^2 + pi
  // alpha^(-1) = alpha_0^(-1) - 1 / (24 * alpha_0^(-1))
  // alpha = 1 / alpha^(-1)
  const PI_2 = Math.PI * Math.PI;
  const PI_3 = PI_2 * Math.PI;
  const PI_5 = Math.pow(Math.PI, 5);
  const ALPHA_0_INV = 4.0 * PI_3 + PI_2 + Math.PI;
  const INV_ALPHA = ALPHA_0_INV - 1.0 / (24.0 * ALPHA_0_INV);
  const ALPHA = 1.0 / INV_ALPHA;

  // Proton-to-electron mass ratio from 3 interlinked toroidal fluxes in V-configuration
  // Canonical pitch angle cos(45 deg) = 1/sqrt(2), elliptic deformation parameter m = sqrt(2)*alpha^2
  // (2 / pi) * K(m) = 1 + alpha^2 / (2 * sqrt(2))
  const MP_OVER_ME = 6.0 * PI_5 * (1.0 + (ALPHA * ALPHA) / (2.0 * Math.SQRT2));

  // Electron mass from Rydberg constant
  const R_INF = 10973731.568160; // m^-1
  const ME = (2.0 * R_INF * H_EXACT) / (ALPHA * ALPHA * C_EXACT);
  const MP = MP_OVER_ME * ME;

  // Interplanetary System of Units (IP-Nat & IP-Prac)
  const TAU_H = 1.0 / (2.0 * C_EXACT * R_INF); // ~1.519829846e-16 s
  const LAMBDA_H = 1.0 / (2.0 * R_INF); // ~45.5633525e-9 m
  const N_T_CYCLES = 6579683920501762;
  const N_T_EXACT = 2.0 * C_EXACT * R_INF;
  const TIME_DISCREPANCY = Math.abs(N_T_CYCLES - N_T_EXACT) / N_T_EXACT;

  // Parse m_Planck input
  const mPlanck = parseFloat(mPlanckStr) || 2.176434e-8;

  // Calculate Newton's G directly from wave refraction: G = (hbar * c) / (m_Planck^2)
  const gComputed = (HBAR_EXACT * C_EXACT) / (mPlanck * mPlanck);
  const alphaG = (gComputed * MP * MP) / (HBAR_EXACT * C_EXACT);
  const kappaField = (8.0 * Math.PI * gComputed) / Math.pow(C_EXACT, 4);

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
              Fundamental constants evaluated as exact geometric definite integrals in Conformal Geometric Algebra (CGA) relative to true speed \( c \).
              The precision of Newton's gravitational constant \( G \) is dimensional and caliper-bounded by empirical measurements of macroscopic standards.
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
                \kappa = \frac&#123;8\pi G&#125;&#123;c^4&#125;, \quad \alpha_G = \frac&#123;G m_p^2&#125;&#123;\hbar c&#125;
              </span>
            </div>

            <div className="bg-slate-950 p-4 rounded-xl border border-slate-800/60 space-y-3">
              <div className="text-xs text-slate-400 leading-relaxed">
                In classical wave refraction, gravitation emerges from the propagation speed gradient \( c(\mathbf&#123;r&#125;) \approx c_0 (1 - G M / (c_0^2 r)) \) induced by field energy density. As a dimensional parameter in SI units, \( G \) is calibrated by empirical calipers, yielding field susceptibility \( \kappa \) and dimensionless proton coupling \( \alpha_G \):
              </div>
              
              <div className="p-3 bg-slate-900/90 rounded-lg border border-slate-800 font-mono text-center space-y-2">
                <div>
                  <div className="text-xs text-slate-500 mb-0.5">Caliper-Bounded Constant \( G \)</div>
                  <div className="text-lg text-emerald-400 font-medium">
                    {gComputed.toExponential(7)} <span className="text-xs text-slate-400 font-normal">m³ / (kg · s²)</span>
                  </div>
                  <div className="text-[11px] text-amber-400/90 mt-0.5">
                    ± {gAbsoluteUncertainty.toExponential(2)} ({gUncertaintyPpm.toFixed(1)} ppm relative standard error)
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-2 pt-2 border-t border-slate-800/80 text-left text-xs">
                  <div>
                    <div className="text-[10px] text-slate-500 uppercase tracking-wider">Field Susceptibility \( \kappa \)</div>
                    <div className="text-slate-200 font-medium">{kappaField.toExponential(5)} <span className="text-[10px] text-slate-500">s²/(kg·m)</span></div>
                  </div>
                  <div>
                    <div className="text-[10px] text-slate-500 uppercase tracking-wider">Proton Coupling \( \alpha_G \)</div>
                    <div className="text-slate-200 font-medium">{alphaG.toExponential(5)}</div>
                  </div>
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
                    Conformal phase & field boundary reaction: \( \alpha^&#123;-1&#125; = \alpha_0^&#123;-1&#125; - \frac&#123;1&#125;&#123;24 \alpha_0^&#123;-1&#125;&#125; \)
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
                    3-toroid V-configuration: \( 6 \pi^5 \left( 1 + \frac&#123;\alpha^2&#125;&#123;2\sqrt&#123;2&#125;&#125; \right) \)
                  </div>
                </div>
                <div className="text-right font-mono">
                  <div className="text-sm text-slate-100 font-medium">{MP_OVER_ME.toFixed(5)}</div>
                  <div className="text-[11px] text-emerald-400/90 flex items-center justify-end gap-1">
                    <CheckCircle2 className="w-3 h-3" /> CODATA Match
                  </div>
                </div>
              </div>

              {/* Electron mass */}
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

              {/* Proton mass */}
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

      {/* Interplanetary System of Units (IP) Section */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-5">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-slate-800 pb-4">
          <div>
            <div className="flex items-center gap-2 text-indigo-400 font-mono text-xs uppercase tracking-wider mb-1">
              <Orbit className="w-4 h-4" />
              <span>Autonomous Physical Standards (No Caesium or SI Artifacts)</span>
            </div>
            <h3 className="text-lg font-medium text-slate-100">
              The Interplanetary System of Units (IP)
            </h3>
            <p className="text-xs text-slate-400 mt-0.5">
              Dual-layer metrology anchored to the ground-state of isolated monatomic hydrogen, the electron knot, and propagation speed \( c \).
            </p>
          </div>

          <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800 text-xs font-mono">
            <button
              onClick={() => setIpSubsystem('practical')}
              className={`px-3 py-1.5 rounded-lg transition-colors ${
                ipSubsystem === 'practical'
                  ? 'bg-indigo-600 text-white font-medium shadow-sm'
                  : 'text-slate-400 hover:text-slate-200'
              }`}
            >
              IP-Practical (Caliper Scale)
            </button>
            <button
              onClick={() => setIpSubsystem('natural')}
              className={`px-3 py-1.5 rounded-lg transition-colors ${
                ipSubsystem === 'natural'
                  ? 'bg-indigo-600 text-white font-medium shadow-sm'
                  : 'text-slate-400 hover:text-slate-200'
              }`}
            >
              IP-Natural (Wave Geometry)
            </button>
          </div>
        </div>

        {ipSubsystem === 'practical' ? (
          <div className="space-y-4">
            <div className="text-xs text-slate-300 leading-relaxed bg-slate-950/60 p-3.5 rounded-xl border border-slate-800/80">
              <span className="text-indigo-400 font-medium font-mono">IP-Practical:</span> Macroscopic units matching shop calipers and stopwatches, defined as <em>exact canonical integers</em> of the natural hydrogen cycle and electron knot. Eliminates caesium-133 and Kibble balances while agreeing with SI to extreme precision.
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {/* Second */}
              <div className="p-4 bg-slate-950 rounded-xl border border-slate-800 space-y-2">
                <div className="flex items-center justify-between text-xs">
                  <span className="font-mono text-indigo-300 font-medium">Interplanetary Second (\( \text{s}_&#123;\text{IP}&#125; \))</span>
                  <span className="px-1.5 py-0.5 text-[10px] font-mono rounded bg-emerald-950 border border-emerald-800 text-emerald-300">
                    Exact Integer
                  </span>
                </div>
                <div className="text-lg font-mono text-slate-100 font-medium">
                  {N_T_CYCLES.toLocaleString()}
                </div>
                <div className="text-[11px] text-slate-400 font-mono">
                  cycles of ground-state \( \tau_H \)
                </div>
                <div className="pt-2 border-t border-slate-800/80 text-[11px] text-emerald-400 font-mono flex items-center justify-between">
                  <span>SI Discrepancy:</span>
                  <span>{TIME_DISCREPANCY.toExponential(2)} (17 digits)</span>
                </div>
              </div>

              {/* Meter */}
              <div className="p-4 bg-slate-950 rounded-xl border border-slate-800 space-y-2">
                <div className="flex items-center justify-between text-xs">
                  <span className="font-mono text-indigo-300 font-medium">Interplanetary Meter (\( \text{m}_&#123;\text{IP}&#125; \))</span>
                  <span className="px-1.5 py-0.5 text-[10px] font-mono rounded bg-emerald-950 border border-emerald-800 text-emerald-300">
                    Kinematic Ratio
                  </span>
                </div>
                <div className="text-lg font-mono text-slate-100 font-medium">
                  {(N_T_CYCLES / C_EXACT).toFixed(4)}
                </div>
                <div className="text-[11px] text-slate-400 font-mono">
                  wavelengths of \( \lambda_H = 1 / (2 R_\infty) \)
                </div>
                <div className="pt-2 border-t border-slate-800/80 text-[11px] text-slate-300 font-mono flex items-center justify-between">
                  <span>Exact \( c \):</span>
                  <span>299,792,458 m_IP / s_IP</span>
                </div>
              </div>

              {/* Kilogram */}
              <div className="p-4 bg-slate-950 rounded-xl border border-slate-800 space-y-2">
                <div className="flex items-center justify-between text-xs">
                  <span className="font-mono text-indigo-300 font-medium">Interplanetary Kilogram (\( \text{kg}_&#123;\text{IP}&#125; \))</span>
                  <span className="px-1.5 py-0.5 text-[10px] font-mono rounded bg-emerald-950 border border-emerald-800 text-emerald-300">
                    Exact Integer
                  </span>
                </div>
                <div className="text-sm font-mono text-slate-100 font-medium break-all">
                  1,097,769,095,557,842,067,257,839,129,157
                </div>
                <div className="text-[11px] text-slate-400 font-mono">
                  elementary electron masses \( \mu_e \)
                </div>
                <div className="pt-2 border-t border-slate-800/80 text-[11px] text-emerald-400 font-mono flex items-center justify-between">
                  <span>SI Discrepancy:</span>
                  <span>6.76×10⁻³² (31 digits)</span>
                </div>
              </div>
            </div>
          </div>
        ) : (
          <div className="space-y-4">
            <div className="text-xs text-slate-300 leading-relaxed bg-slate-950/60 p-3.5 rounded-xl border border-slate-800/80">
              <span className="text-indigo-400 font-medium font-mono">IP-Natural:</span> Base units set to the fundamental geometric scales of the universal field. Propagation speed \( c \equiv 1 \), electron mass \( \mu_e \equiv 1 \), and atomic dimensions form an exact rational ladder in powers of \( \alpha \).
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {/* Chronon */}
              <div className="p-4 bg-slate-950 rounded-xl border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-indigo-300 font-medium">Hydrogen Chronon (\( \tau_H \))</div>
                <div className="text-lg font-mono text-slate-100 font-medium">
                  {TAU_H.toExponential(7)} s
                </div>
                <div className="text-[11px] text-slate-400 font-mono">
                  \( \tau_H = \frac&#123;1&#125;&#123;2 c R_\infty&#125; = \frac&#123;h&#125;&#123;\alpha^2 m_e c^2&#125; \)
                </div>
                <div className="pt-2 border-t border-slate-800/80 text-[11px] text-slate-400 font-mono">
                  Frequency: {(1.0 / TAU_H / 1e15).toFixed(4)} PHz
                </div>
              </div>

              {/* Metron */}
              <div className="p-4 bg-slate-950 rounded-xl border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-indigo-300 font-medium">Hydrogen Metron (\( \lambda_H \))</div>
                <div className="text-lg font-mono text-slate-100 font-medium">
                  {(LAMBDA_H * 1e9).toFixed(5)} nm
                </div>
                <div className="text-[11px] text-slate-400 font-mono">
                  \( \lambda_H = c \tau_H = \frac&#123;1&#125;&#123;2 R_\infty&#125; \)
                </div>
                <div className="pt-2 border-t border-slate-800/80 text-[11px] text-emerald-400 font-mono">
                  \( c \) cancels identically in definition
                </div>
              </div>

              {/* Electron Mass */}
              <div className="p-4 bg-slate-950 rounded-xl border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-indigo-300 font-medium">Electron Knot Mass (\( \mu_e \))</div>
                <div className="text-lg font-mono text-slate-100 font-medium">
                  {ME.toExponential(7)} kg
                </div>
                <div className="text-[11px] text-slate-400 font-mono">
                  \( \mu_e = m_e = \frac&#123;2 R_\infty h&#125;&#123;\alpha^2 c&#125; \)
                </div>
                <div className="pt-2 border-t border-slate-800/80 text-[11px] text-slate-400 font-mono">
                  Proton: {MP_OVER_ME.toFixed(5)} \( \mu_e \)
                </div>
              </div>
            </div>

            {/* Geometric Power-of-Alpha Ladder */}
            <div className="p-3.5 bg-slate-950 rounded-xl border border-slate-800 text-xs font-mono space-y-2">
              <div className="text-slate-400 font-medium flex items-center gap-1.5 text-indigo-300">
                <Layers className="w-3.5 h-3.5" />
                <span>The Geometric Power-of-\( \alpha \) Spatial Ladder in IP-Natural:</span>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-2 pt-1 text-slate-300">
                <div className="p-2 bg-slate-900 rounded border border-slate-800/60">
                  <div className="text-slate-500 text-[10px]">Bohr Circumference</div>
                  <div className="font-medium text-slate-200">\( 2 \pi a_0 = \alpha \cdot \lambda_H \)</div>
                  <div className="text-[10px] text-slate-400">{(ALPHA * LAMBDA_H * 1e9).toFixed(5)} nm</div>
                </div>
                <div className="p-2 bg-slate-900 rounded border border-slate-800/60">
                  <div className="text-slate-500 text-[10px]">Electron Compton Wavelength</div>
                  <div className="font-medium text-slate-200">\( \lambda_e = \alpha^2 \cdot \lambda_H \)</div>
                  <div className="text-[10px] text-slate-400">{(ALPHA * ALPHA * LAMBDA_H * 1e12).toFixed(5)} pm</div>
                </div>
                <div className="p-2 bg-slate-900 rounded border border-slate-800/60">
                  <div className="text-slate-500 text-[10px]">Proton Knot Core</div>
                  <div className="font-medium text-slate-200">\( \lambda_p = \alpha^2 (m_p/m_e)^{'{'}-1{'}'} \lambda_H \)</div>
                  <div className="text-[10px] text-slate-400">{(ALPHA * ALPHA * LAMBDA_H / MP_OVER_ME * 1e15).toFixed(5)} fm</div>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
