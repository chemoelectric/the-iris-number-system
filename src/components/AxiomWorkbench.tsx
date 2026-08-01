import React, { useState } from 'react';
import { IrisAxiom, IrisDomain } from '../types';
import { DEFAULT_IRIS_AXIOMS } from '../lib/irisEngine';
import { ShieldAlert, Plus, CheckCircle2, Search, Layers, Lock } from 'lucide-react';

export const AxiomWorkbench: React.FC = () => {
  const [axioms, setAxioms] = useState<IrisAxiom[]>(DEFAULT_IRIS_AXIOMS);
  const [selectedCategory, setSelectedCategory] = useState<string>('All');
  const [isAdding, setIsAdding] = useState<boolean>(false);

  // New Axiom form
  const [name, setName] = useState('');
  const [latex, setLatex] = useState('');
  const [domain, setDomain] = useState<IrisDomain>('Number Theory');
  const [category, setCategory] = useState<IrisAxiom['category']>('Fundamental');
  const [description, setDescription] = useState('');

  const handleAddAxiom = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !latex.trim()) return;

    const newAxiom: IrisAxiom = {
      id: `ax-custom-${Date.now()}`,
      name,
      latex,
      domain,
      category,
      description: description || 'Custom Iris Number System axiom.',
    };

    setAxioms([...axioms, newAxiom]);
    setName('');
    setLatex('');
    setDescription('');
    setIsAdding(false);
  };

  const filteredAxioms = axioms.filter(
    (ax) => selectedCategory === 'All' || ax.category === selectedCategory
  );

  return (
    <div className="space-y-6">
      {/* Banner */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 relative overflow-hidden">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <div className="flex items-center space-x-2">
              <ShieldAlert className="w-6 h-6 text-indigo-400" />
              <h2 className="text-xl font-bold text-white">Iris System Axiom Workbench</h2>
            </div>
            <p className="text-slate-400 text-sm mt-1 max-w-2xl">
              Inspect and extend fundamental axioms governing algebraic relations, spectral norms, and discrete operators in the Iris framework.
            </p>
          </div>

          <button
            onClick={() => setIsAdding(true)}
            className="flex items-center space-x-1.5 px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-xl text-xs font-medium shadow-lg transition shrink-0"
          >
            <Plus className="w-4 h-4" />
            <span>Register Custom Axiom</span>
          </button>
        </div>
      </div>

      {/* Category Pills */}
      <div className="flex items-center space-x-1.5 overflow-x-auto pb-1 scrollbar-none">
        {['All', 'Fundamental', 'Duality', 'Convergence', 'Modular', 'Differential'].map((cat) => (
          <button
            key={cat}
            onClick={() => setSelectedCategory(cat)}
            className={`px-3.5 py-1.5 text-xs font-mono rounded-lg transition whitespace-nowrap ${
              selectedCategory === cat
                ? 'bg-indigo-600 text-white shadow'
                : 'bg-slate-900 text-slate-400 hover:bg-slate-800'
            }`}
          >
            {cat}
          </button>
        ))}
      </div>

      {/* Add Form */}
      {isAdding && (
        <form onSubmit={handleAddAxiom} className="p-5 bg-slate-900 border border-indigo-500/40 rounded-2xl space-y-4 shadow-2xl">
          <div className="flex items-center justify-between border-b border-slate-800 pb-3">
            <h4 className="font-bold text-white text-sm">Register Custom Iris Axiom</h4>
            <button
              type="button"
              onClick={() => setIsAdding(false)}
              className="text-xs text-slate-400 hover:text-white"
            >
              Cancel
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-mono text-slate-300 mb-1">Axiom Name:</label>
              <input
                type="text"
                placeholder="e.g. Axiom of Non-commutative Spectrum Shift"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-lg text-sm text-white font-mono focus:outline-none focus:border-indigo-500"
                required
              />
            </div>

            <div>
              <label className="block text-xs font-mono text-slate-300 mb-1">LaTeX Formulation:</label>
              <input
                type="text"
                placeholder="e.g. \iota \cdot \varpi = -\varpi \cdot \iota + \tau"
                value={latex}
                onChange={(e) => setLatex(e.target.value)}
                className="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-lg text-sm text-white font-mono focus:outline-none focus:border-indigo-500"
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-mono text-slate-300 mb-1">Category:</label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value as any)}
                className="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-lg text-xs text-white font-mono focus:outline-none focus:border-indigo-500"
              >
                <option value="Fundamental">Fundamental</option>
                <option value="Duality">Duality</option>
                <option value="Convergence">Convergence</option>
                <option value="Modular">Modular</option>
                <option value="Differential">Differential</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-mono text-slate-300 mb-1">Domain:</label>
              <select
                value={domain}
                onChange={(e) => setDomain(e.target.value as IrisDomain)}
                className="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-lg text-xs text-white font-mono focus:outline-none focus:border-indigo-500"
              >
                <option value="Number Theory">Number Theory</option>
                <option value="Discrete Spectrum Algebra">Discrete Spectrum Algebra</option>
                <option value="Abstract Algebra">Abstract Algebra</option>
                <option value="Spectral Topology">Spectral Topology</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-mono text-slate-300 mb-1">Description / Physical Interpretation:</label>
            <textarea
              rows={2}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Provide mathematical intuition or physical context..."
              className="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-lg text-sm text-white font-sans focus:outline-none focus:border-indigo-500"
            />
          </div>

          <div className="flex justify-end space-x-2 pt-2">
            <button
              type="button"
              onClick={() => setIsAdding(false)}
              className="px-4 py-2 bg-slate-800 text-slate-300 rounded-lg text-xs font-medium"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 bg-indigo-600 text-white rounded-lg text-xs font-medium shadow"
            >
              Save Axiom
            </button>
          </div>
        </form>
      )}

      {/* Axioms Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {filteredAxioms.map((ax) => (
          <div
            key={ax.id}
            className="p-5 bg-slate-900 border border-slate-800 hover:border-slate-700 rounded-2xl space-y-3 shadow-xl transition"
          >
            <div className="flex items-center justify-between">
              <span className="text-[10px] uppercase font-mono tracking-wider px-2 py-0.5 rounded bg-indigo-500/20 text-indigo-300 border border-indigo-500/30">
                {ax.category}
              </span>
              <span className="text-[10px] font-mono text-slate-500">{ax.domain}</span>
            </div>

            <h3 className="text-sm font-bold text-white">{ax.name}</h3>

            <div className="p-3 bg-slate-950 rounded-xl border border-slate-800 font-mono text-amber-300 text-xs text-center overflow-x-auto">
              ${ax.latex}$
            </div>

            <p className="text-xs text-slate-400">{ax.description}</p>
          </div>
        ))}
      </div>
    </div>
  );
};
