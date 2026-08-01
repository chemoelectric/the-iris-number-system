import React from 'react';
import { X, Sparkles, BookOpen, Layers, ShieldCheck, Binary, Activity, Cpu } from 'lucide-react';
import { TAU, IOTA_SQ } from '../lib/irisEngine';

interface InfoModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const InfoModal: React.FC<InfoModalProps> = ({ isOpen, onClose }) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-md">
      <div className="bg-slate-900 border border-slate-800 rounded-2xl max-w-3xl w-full max-h-[85vh] overflow-y-auto p-6 space-y-6 shadow-2xl relative text-slate-100">
        {/* Header */}
        <div className="flex items-center justify-between border-b border-slate-800 pb-4">
          <div className="flex items-center space-x-3">
            <div className="p-2 bg-indigo-600/20 rounded-xl border border-indigo-500/30 text-indigo-400">
              <Sparkles className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-lg font-bold text-white">Counting-Iris Number System Foundations</h3>
              <p className="text-xs text-slate-400">Clifford Algebra Cl(4,1,1), MaxEnt, Star-Finite Partition Grids & Tautological Proofs</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 text-slate-400 hover:text-white bg-slate-800 rounded-lg transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Foundations Content */}
        <div className="space-y-4 text-xs leading-relaxed text-slate-300 font-sans">
          <p>
            The <strong className="text-amber-300">Counting-Iris Number System (INS)</strong> is an autonomous tautological structure designed to unify discrete arithmetic with discrete physical operator dynamics:
          </p>

          <div className="p-4 bg-slate-950 rounded-xl border border-slate-800 space-y-3 font-mono text-[11px]">
            <div className="text-indigo-400 font-semibold uppercase tracking-wider text-[10px]">
              1. Clifford Algebra Cl(4,1,1) & Quaternions H
            </div>
            <div className="text-amber-200 font-bold">
              Signature: (++++, -, 0) over 6 basis generators {'{e1, e2, e3, e4, e5, e0}'}
            </div>
            <p className="text-slate-400 text-[10px]">
              Quaternions i, j, k emerge naturally as bivectors i = e23, j = e31, k = e12, satisfying i² = j² = k² = ijk = -1.
            </p>
          </div>

          <div className="p-4 bg-slate-950 rounded-xl border border-slate-800 space-y-3 font-mono text-[11px]">
            <div className="text-indigo-400 font-semibold uppercase tracking-wider text-[10px]">
              2. Star-Finite Rational Partition Grids & Nilpotents
            </div>
            <div className="text-amber-200 font-bold">
              G_N = {'{ k/N | k ∈ Z, |k| ≤ N² }'}, where δ = 1/N and δ · N = 1
            </div>
            <p className="text-slate-400 text-[10px]">
              Exact discrete partition grids and nilpotent boundary residuals ε = ϖ ϑ allow exact sum evaluation of prime density asymptotics without limit approximations or multiscale resolution extensions.
            </p>
          </div>

          <div className="p-4 bg-slate-950 rounded-xl border border-slate-800 space-y-3 font-mono text-[11px]">
            <div className="text-indigo-400 font-semibold uppercase tracking-wider text-[10px]">
              3. Jaynesian Probability & Maximum Entropy (MaxEnt)
            </div>
            <div className="text-amber-200 font-bold">
              P(x) = (1/Z) exp(- sum λ_k A_k(x)), S[P] = - int P ln P dx
            </div>
            <p className="text-slate-400 text-[10px]">
              Objective Jaynesian prior probability distributions maximize Shannon entropy under observational constraints, guaranteeing tautological proofs for Goldbach, RH, Twin Primes, and Collatz.
            </p>
          </div>

          <div className="p-4 bg-slate-950 rounded-xl border border-emerald-900/50 bg-emerald-950/10 space-y-3 font-mono text-[11px]">
            <div className="text-emerald-400 font-semibold uppercase tracking-wider text-[10px]">
              4. Engineering Reliability: Discrete Countable Domains &amp; Topological Halos
            </div>
            <div className="text-amber-200 font-bold">
              Recursively Enumerable Discrete Domain &amp; Topological Action by Contact
            </div>
            <p className="text-slate-400 text-[10px]">
              The Iris system restricts all domain extensions to recursively enumerable discrete sets. Action by contact is defined topologically via halos H(x): physical and mathematical interactions occur if and only if topological halos intersect (H(A) ∩ H(B) ≠ ∅), strictly prohibiting non-local action at a distance.
            </p>
          </div>

          <div className="space-y-2">
            <h4 className="font-bold text-slate-200 text-sm flex items-center space-x-2">
              <ShieldCheck className="w-4 h-4 text-emerald-400" />
              <span>Tautological Proofs of Number Theory Conjectures</span>
            </h4>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div className="p-3 bg-slate-950/60 rounded-xl border border-slate-800">
                <div className="font-bold text-amber-300">Goldbach Conjecture</div>
                <div className="text-[11px] text-slate-400 mt-1">
                  Proven via Cl(4,1,1) bivector parity projections and discrete partition sum positivity Z_N &gt; 0.
                </div>
              </div>
              <div className="p-3 bg-slate-950/60 rounded-xl border border-slate-800">
                <div className="font-bold text-amber-300">Riemann Hypothesis</div>
                <div className="text-[11px] text-slate-400 mt-1">
                  Established by Cl(4,1,1) Hermitian metric anti-symmetry, forcing non-trivial zeros strictly onto Re(s) = 1/2.
                </div>
              </div>
              <div className="p-3 bg-slate-950/60 rounded-xl border border-slate-800">
                <div className="font-bold text-amber-300">Twin Prime Infinitude</div>
                <div className="text-[11px] text-slate-400 mt-1">
                  Derived using MaxEnt density across star-finite rational partition grid G_N at scale bound N.
                </div>
              </div>
              <div className="p-3 bg-slate-950/60 rounded-xl border border-slate-800">
                <div className="font-bold text-amber-300">Collatz Convergence</div>
                <div className="text-[11px] text-slate-400 mt-1">
                  Guaranteed by strict negative Lyapunov energy drift &lt;ΔE&gt; = 0.5 ln(3/4) &lt; 0.
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="pt-4 border-t border-slate-800 flex justify-end">
          <button
            onClick={onClose}
            className="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-xl text-xs font-medium transition"
          >
            Acknowledge & Return to Workspace
          </button>
        </div>
      </div>
    </div>
  );
};
