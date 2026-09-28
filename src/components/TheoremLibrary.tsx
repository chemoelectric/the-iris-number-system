import React, { useState } from 'react';
import { PRESET_THEOREMS } from '../lib/irisEngine';
import { TheoremProof, IrisDomain } from '../types';
import {
  BookOpen,
  Search,
  Filter,
  CheckCircle2,
  ArrowRight,
  ShieldCheck,
  Bot,
  ExternalLink,
  GitCommit,
} from 'lucide-react';

interface TheoremLibraryProps {
  onLoadTheorem: (proof: TheoremProof) => void;
  onOpenAiAssistantWithPrompt: (prompt: string, domain: IrisDomain) => void;
}

export const TheoremLibrary: React.FC<TheoremLibraryProps> = ({
  onLoadTheorem,
  onOpenAiAssistantWithPrompt,
}) => {
  const [selectedDomain, setSelectedDomain] = useState<string>('All');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [expandedId, setExpandedId] = useState<string | null>(PRESET_THEOREMS[0].id);

  const filteredTheorems = PRESET_THEOREMS.filter((thm) => {
    const matchesDomain = selectedDomain === 'All' || thm.domain === selectedDomain;
    const matchesQuery =
      thm.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      thm.summary.toLowerCase().includes(searchQuery.toLowerCase()) ||
      thm.hypothesis.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesDomain && matchesQuery;
  });

  return (
    <div className="space-y-6">
      {/* Banner */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 relative overflow-hidden">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <div className="flex items-center space-x-2">
              <BookOpen className="w-6 h-6 text-amber-400" />
              <h2 className="text-xl font-bold text-white">Iris System Theorem Library</h2>
            </div>
            <p className="text-slate-400 text-sm mt-1 max-w-2xl">
              Foundational theorems, lemmas, and proved propositions across Number Theory, Discrete Analysis, and Spectral Topology.
            </p>
          </div>

          <div className="flex items-center space-x-2">
            <span className="text-xs font-mono px-3 py-1.5 bg-slate-800 border border-slate-700 rounded-lg text-slate-300">
              {PRESET_THEOREMS.length} Active Theorems
            </span>
          </div>
        </div>
      </div>

      {/* Filter and Search Controls */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-4 flex flex-col md:flex-row items-center justify-between gap-4 shadow-lg">
        {/* Search */}
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
          <input
            type="text"
            placeholder="Search theorems, formulas, or lemmas..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:border-indigo-500 font-mono"
          />
        </div>

        {/* Domain Filter Pills */}
        <div className="flex items-center space-x-1.5 overflow-x-auto w-full md:w-auto scrollbar-none">
          {['All', 'Number Theory', 'Discrete Analysis', 'Abstract Algebra'].map((dom) => (
            <button
              key={dom}
              onClick={() => setSelectedDomain(dom)}
              className={`px-3 py-1.5 text-xs font-mono rounded-lg transition whitespace-nowrap ${
                selectedDomain === dom
                  ? 'bg-indigo-600 text-white shadow'
                  : 'bg-slate-800 text-slate-400 hover:bg-slate-700'
              }`}
            >
              {dom}
            </button>
          ))}
        </div>
      </div>

      {/* Theorems Cards Grid */}
      <div className="space-y-4">
        {filteredTheorems.map((thm) => {
          const isExpanded = expandedId === thm.id;
          return (
            <div
              key={thm.id}
              className={`bg-slate-900 border rounded-2xl p-6 transition-all duration-200 shadow-xl ${
                isExpanded ? 'border-indigo-500/50 bg-slate-900/90' : 'border-slate-800 hover:border-slate-700'
              }`}
            >
              <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="space-y-1">
                  <div className="flex items-center space-x-2">
                    <span className="text-[10px] uppercase font-mono tracking-wider px-2.5 py-0.5 rounded-full bg-indigo-500/20 text-indigo-300 border border-indigo-500/30">
                      {thm.domain}
                    </span>
                    <span className="text-xs font-mono text-emerald-400 font-semibold flex items-center space-x-1">
                      <ShieldCheck className="w-3.5 h-3.5" />
                      <span>Formal Rigor: {thm.rigorScore}%</span>
                    </span>
                  </div>
                  <h3 className="text-lg font-bold text-white mt-1">{thm.title}</h3>
                  <p className="text-slate-300 text-xs italic">{thm.summary}</p>
                </div>

                <div className="flex items-center space-x-2 shrink-0">
                  <button
                    onClick={() => onLoadTheorem(thm as TheoremProof)}
                    className="flex items-center space-x-1.5 px-3 py-1.5 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg text-xs font-medium transition shadow"
                  >
                    <GitCommit className="w-3.5 h-3.5" />
                    <span>Load into Proof Builder</span>
                  </button>

                  <button
                    onClick={() =>
                      onOpenAiAssistantWithPrompt(
                        `Extend theorem: ${thm.title}. Explore potential extensions or generalizations in ${thm.domain}.`,
                        thm.domain
                      )
                    }
                    className="p-1.5 bg-slate-800 hover:bg-slate-700 text-amber-300 rounded-lg text-xs font-medium transition"
                    title="Explore with Inference Engine Prover"
                  >
                    <Bot className="w-4 h-4" />
                  </button>

                  <button
                    onClick={() => setExpandedId(isExpanded ? null : thm.id)}
                    className="px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-lg text-xs font-mono"
                  >
                    {isExpanded ? 'Hide Steps' : 'View Steps'}
                  </button>
                </div>
              </div>

              {/* Expanded Proof Details */}
              {isExpanded && (
                <div className="mt-5 pt-5 border-t border-slate-800 space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    <div className="p-3 bg-slate-950 rounded-xl border border-slate-800 font-mono text-xs">
                      <span className="text-slate-400 uppercase tracking-wider block text-[10px] mb-1">
                        Hypothesis:
                      </span>
                      <span className="text-slate-200">{thm.hypothesis}</span>
                    </div>
                    <div className="p-3 bg-slate-950 rounded-xl border border-indigo-900/50 font-mono text-xs">
                      <span className="text-indigo-400 uppercase tracking-wider block text-[10px] mb-1">
                        Conclusion:
                      </span>
                      <span className="text-indigo-200">{thm.conclusion}</span>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <div className="text-xs font-semibold text-slate-300">Deductive Proof Steps:</div>
                    <div className="space-y-2">
                      {thm.steps.map((step) => (
                        <div key={step.id} className="p-3 bg-slate-950/70 rounded-xl border border-slate-800 text-xs font-mono space-y-1">
                          <div className="flex items-center justify-between text-amber-300">
                            <span>
                              Step {step.stepNumber}: {step.statement}
                            </span>
                            <span className="text-[10px] text-slate-500">{step.ruleUsed}</span>
                          </div>
                          <div className="text-slate-400 text-[11px] font-sans italic">
                            Justification: {step.justification}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
};
