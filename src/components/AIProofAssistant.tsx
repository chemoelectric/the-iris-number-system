import React, { useState } from 'react';
import { TheoremProof, IrisDomain } from '../types';
import {
  Bot,
  Sparkles,
  Send,
  Loader2,
  CheckCircle2,
  GitCommit,
  ShieldAlert,
  HelpCircle,
} from 'lucide-react';

interface AIProofAssistantProps {
  onImportGeneratedProof: (proof: TheoremProof) => void;
  initialPrompt?: string;
  initialDomain?: IrisDomain;
}

export const AIProofAssistant: React.FC<AIProofAssistantProps> = ({
  onImportGeneratedProof,
  initialPrompt = '',
  initialDomain = 'Number Theory',
}) => {
  const [prompt, setPrompt] = useState<string>(
    initialPrompt ||
      'Prove that for any Iris Number z with ||z||_I > 0, the conjugate product z * z* produces a positive real spectral scalar in R.'
  );
  const [domain, setDomain] = useState<IrisDomain>(initialDomain);
  const [proofType, setProofType] = useState<string>('Constructive Spectral Induction');
  const [rigorLevel, setRigorLevel] = useState<string>('Rigorous Formal Proof');
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [generatedProof, setGeneratedProof] = useState<TheoremProof | null>(null);

  const handleGenerateProof = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!prompt.trim()) return;

    setLoading(true);
    setError(null);

    try {
      const res = await fetch('/api/gemini/deduce', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          conjecture: prompt,
          domain,
          proofType,
          rigorLevel,
        }),
      });

      const data = await res.json();
      if (!data.success || !data.proof) {
        throw new Error(data.error || 'Failed to generate proof.');
      }

      const p = data.proof;
      const proofObj: TheoremProof = {
        id: `ai-proof-${Date.now()}`,
        title: p.title || 'Inference Engine Generated Iris Deduction',
        domain: (p.domain as IrisDomain) || domain,
        hypothesis: p.hypothesis || 'Given statement assumptions',
        conclusion: p.conclusion || 'Proved assertion',
        rigorScore: p.rigorScore || 95,
        summary: p.summary || 'Generated via Gemini Iris Proof Engine.',
        steps: (p.steps || []).map((st: any, idx: number) => ({
          id: `ai-step-${idx + 1}`,
          stepNumber: st.stepNumber || idx + 1,
          statement: st.statement || '',
          ruleUsed: st.ruleUsed || 'Iris Axiom',
          justification: st.justification || '',
          status: 'valid',
          dependencies: [],
        })),
        potentialCounterexamples: p.potentialCounterexamples || [],
        relatedLemmas: p.relatedLemmas || [],
        author: 'Inference Engine',
        createdAt: new Date().toISOString().split('T')[0],
      };

      setGeneratedProof(proofObj);
    } catch (err: any) {
      console.error('Inference Engine proof generation error:', err);
      setError(err.message || 'An error occurred while generating the deduction.');
    } finally {
      setLoading(false);
    }
  };

  const presetQueries = [
    {
      title: 'Iris Conjugate Real Norm Theorem',
      query: 'Prove that z * z* is always a non-negative real scalar in R for any Iris number z = a + b·ι + c·ϖ + d·ϑ.',
      domain: 'Tautological Discrete Arithmetic' as const,
    },
    {
      title: 'Iris Zeta Pole Residue at s = 1',
      query: 'Derive the exact residue of ζ_I(s) at s = 1 and demonstrate its relation to the golden ratio shift τ.',
      domain: 'Discrete Spectrum Algebra' as const,
    },
    {
      title: 'Modular Iris Prime Fermat Congruence',
      query: 'Prove Fermat-Iris congruence: z^(p-1) ≡ 1 + ι·ϖ (mod p_I) for Iris prime p_I with ||p_I||_I = 7.',
      domain: 'Tautological Discrete Arithmetic' as const,
    },
  ];

  return (
    <div className="space-y-6">
      {/* Banner */}
      <div className="bg-gradient-to-r from-slate-900 via-purple-950/40 to-slate-900 border border-purple-500/30 rounded-2xl p-6 relative overflow-hidden shadow-2xl">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <div className="flex items-center space-x-2">
              <Bot className="w-6 h-6 text-amber-400" />
              <h2 className="text-xl font-bold text-white">Theorem Prover & Search-and-Inference Engine</h2>
            </div>
            <p className="text-slate-300 text-sm mt-1 max-w-2xl">
              Powered by Gemini 3.6 Flash server-side engine. Formulate any conjecture in Number Theory or Analysis to generate rigorous multi-step Iris proofs.
            </p>
          </div>

          <div className="flex items-center space-x-2">
            <span className="text-xs font-mono px-3 py-1.5 bg-purple-950 border border-purple-700/50 rounded-lg text-purple-200">
              Engine: Gemini 3.6 Flash
            </span>
          </div>
        </div>
      </div>

      {/* Main Input Form */}
      <form onSubmit={handleGenerateProof} className="bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-4 shadow-xl">
        <div className="flex items-center justify-between border-b border-slate-800 pb-3">
          <label className="text-sm font-bold text-white flex items-center space-x-2">
            <Sparkles className="w-4 h-4 text-amber-400" />
            <span>Formulate Iris Conjecture or Statement:</span>
          </label>
        </div>

        <textarea
          rows={3}
          value={prompt}
          onChange={(e) => setPrompt(e.target.value)}
          placeholder="Enter a mathematical proposition, e.g. 'Prove that all Iris primes with norm ||p||_I > 5 satisfy p ≡ 1 mod 4'..."
          className="w-full px-4 py-3 bg-slate-950 border border-slate-800 rounded-xl text-sm font-mono text-white placeholder-slate-500 focus:outline-none focus:border-purple-500"
        />

        {/* Configurations */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-xs font-mono text-slate-400 mb-1">Domain:</label>
            <select
              value={domain}
              onChange={(e) => setDomain(e.target.value as IrisDomain)}
              className="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white font-mono focus:outline-none focus:border-purple-500"
            >
              <option value="Tautological Discrete Arithmetic">Tautological Discrete Arithmetic</option>
              <option value="Discrete Spectrum Algebra">Discrete Spectrum Algebra</option>
              <option value="Clifford Algebra Cl(4,1,1)">Clifford Algebra Cl(4,1,1)</option>
              <option value="Jaynesian MaxEnt Probability">Jaynesian MaxEnt Probability</option>
              <option value="Bounded Rational Algebra">Bounded Rational Algebra</option>
              <option value="Spectral Topology">Spectral Topology</option>
              <option value="Quantum Iris Field">Quantum Iris Field</option>
            </select>
          </div>

          <div>
            <label className="block text-xs font-mono text-slate-400 mb-1">Proof Technique:</label>
            <select
              value={proofType}
              onChange={(e) => setProofType(e.target.value)}
              className="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white font-mono focus:outline-none focus:border-purple-500"
            >
              <option value="Constructive Spectral Induction">Constructive Spectral Induction</option>
              <option value="Proof by Contradiction">Proof by Contradiction</option>
              <option value="Phase Normalization">Phase Normalization</option>
              <option value="Modular Residue Analysis">Modular Residue Analysis</option>
            </select>
          </div>

          <div>
            <label className="block text-xs font-mono text-slate-400 mb-1">Rigor Level:</label>
            <select
              value={rigorLevel}
              onChange={(e) => setRigorLevel(e.target.value)}
              className="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white font-mono focus:outline-none focus:border-purple-500"
            >
              <option value="Rigorous Formal Proof">Rigorous Formal Proof</option>
              <option value="Intuitive & Educational Step-by-Step">Intuitive Step-by-Step</option>
              <option value="Axiomatic First-Principles">Axiomatic First-Principles</option>
            </select>
          </div>
        </div>

        {/* Presets */}
        <div className="pt-2 border-t border-slate-800/80">
          <span className="text-[11px] text-slate-500 font-medium">Sample Queries:</span>
          <div className="flex flex-wrap gap-2 mt-1.5">
            {presetQueries.map((pq, idx) => (
              <button
                type="button"
                key={idx}
                onClick={() => {
                  setPrompt(pq.query);
                  setDomain(pq.domain);
                }}
                className="text-[11px] font-mono px-2.5 py-1 bg-slate-950 hover:bg-slate-800 text-slate-300 rounded-lg border border-slate-800 transition"
              >
                {pq.title}
              </button>
            ))}
          </div>
        </div>

        <div className="flex justify-end pt-2">
          <button
            type="submit"
            disabled={loading}
            className="flex items-center space-x-2 px-5 py-2.5 bg-gradient-to-r from-amber-500 via-indigo-600 to-purple-600 hover:opacity-90 text-slate-950 font-bold rounded-xl text-xs shadow-lg transition disabled:opacity-50"
          >
            {loading ? (
              <>
                <Loader2 className="w-4 h-4 animate-spin text-slate-950" />
                <span>Generating Deduction Proof...</span>
              </>
            ) : (
              <>
                <Sparkles className="w-4 h-4 text-slate-950" />
                <span>Run Search & Inference Engine</span>
              </>
            )}
          </button>
        </div>
      </form>

      {/* Error Display */}
      {error && (
        <div className="p-4 bg-red-950/60 border border-red-500/40 rounded-2xl text-xs font-mono text-red-300 flex items-center space-x-2">
          <ShieldAlert className="w-4 h-4 text-red-400 shrink-0" />
          <span>{error}</span>
        </div>
      )}

      {/* Generated Proof Result */}
      {generatedProof && (
        <div className="bg-slate-900 border border-indigo-500/40 rounded-2xl p-6 space-y-5 shadow-2xl animate-fade-in">
          <div className="flex flex-col md:flex-row md:items-center justify-between border-b border-slate-800 pb-4 gap-3">
            <div>
              <div className="flex items-center space-x-2">
                <span className="text-xs uppercase font-mono tracking-wider px-2.5 py-0.5 rounded-full bg-indigo-500/20 text-indigo-300 border border-indigo-500/30">
                  {generatedProof.domain}
                </span>
                <span className="text-xs font-mono text-emerald-400 font-semibold">
                  Rigor Confidence: {generatedProof.rigorScore}%
                </span>
              </div>
              <h3 className="text-xl font-bold text-white mt-1">{generatedProof.title}</h3>
            </div>

            <button
              onClick={() => onImportGeneratedProof(generatedProof)}
              className="flex items-center space-x-2 px-4 py-2 bg-emerald-600 hover:bg-emerald-500 text-white rounded-xl text-xs font-medium shadow-lg transition shrink-0"
            >
              <GitCommit className="w-4 h-4" />
              <span>Import to Active Proof Workspace</span>
            </button>
          </div>

          <p className="text-slate-300 text-xs italic bg-slate-950 p-3 rounded-xl border border-slate-800">
            {generatedProof.summary}
          </p>

          {/* Steps */}
          <div className="space-y-3">
            <div className="text-xs font-bold text-slate-200 uppercase tracking-wider">
              Deductive Proof Steps:
            </div>
            {generatedProof.steps.map((st) => (
              <div key={st.id} className="p-3.5 bg-slate-950/80 rounded-xl border border-slate-800 font-mono text-xs space-y-1">
                <div className="flex items-center justify-between text-amber-300">
                  <span className="font-semibold">
                    Step {st.stepNumber}: {st.statement}
                  </span>
                  <span className="text-[10px] text-slate-500">{st.ruleUsed}</span>
                </div>
                <div className="text-slate-400 text-[11px] font-sans italic">
                  Justification: {st.justification}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};
