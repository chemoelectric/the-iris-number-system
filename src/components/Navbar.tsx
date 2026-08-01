import React from 'react';
import {
  Sparkles,
  Calculator,
  GitCommit,
  Activity,
  BookOpen,
  Bot,
  ShieldAlert,
  Download,
  Info
} from 'lucide-react';
import { ActiveView } from '../types';

interface NavbarProps {
  activeTab: ActiveView['tab'];
  setActiveTab: (tab: ActiveView['tab']) => void;
  onOpenInfoModal: () => void;
  onExportWorkspace: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({
  activeTab,
  setActiveTab,
  onOpenInfoModal,
  onExportWorkspace,
}) => {
  const navItems = [
    {
      id: 'textbook' as const,
      label: 'Iris Textbook',
      icon: BookOpen,
      badge: 'AsciiDoc',
    },
    {
      id: 'deduction' as const,
      label: 'Deduction Framework',
      icon: GitCommit,
      badge: 'Core',
    },
    {
      id: 'sandbox' as const,
      label: 'Iris Calculator',
      icon: Calculator,
    },
    {
      id: 'spectral' as const,
      label: 'Zeta & Prime Spectrum',
      icon: Activity,
    },
    {
      id: 'assistant' as const,
      label: 'Inference Engine Prover',
      icon: Bot,
      badge: 'Infer',
    },
    {
      id: 'library' as const,
      label: 'Theorem Library',
      icon: BookOpen,
    },
    {
      id: 'axioms' as const,
      label: 'Axiom Workbench',
      icon: ShieldAlert,
    },
  ];

  return (
    <header className="sticky top-0 z-40 bg-slate-900/90 backdrop-blur-md border-b border-slate-800 text-slate-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo & Brand */}
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-indigo-600 via-purple-600 to-amber-500 p-0.5 flex items-center justify-center shadow-lg shadow-indigo-500/20">
              <div className="w-full h-full bg-slate-950 rounded-[10px] flex items-center justify-center">
                <Sparkles className="w-5 h-5 text-amber-400 animate-pulse" />
              </div>
            </div>
            <div>
              <div className="flex items-center space-x-2">
                <h1 className="font-bold text-lg bg-gradient-to-r from-amber-200 via-indigo-200 to-purple-300 bg-clip-text text-transparent">
                  Iris Number System
                </h1>
                <span className="text-[10px] uppercase font-mono tracking-widest px-2 py-0.5 rounded-full bg-indigo-950/80 text-indigo-300 border border-indigo-700/50">
                  Deduction Framework v2.5
                </span>
              </div>
              <p className="text-xs text-slate-400 hidden sm:block">
                Number Theory & Discrete Analysis Analytical Engine
              </p>
            </div>
          </div>

          {/* Navigation Items */}
          <nav className="hidden lg:flex items-center space-x-1">
            {navItems.map((item) => {
              const Icon = item.icon;
              const isActive = activeTab === item.id;
              return (
                <button
                  key={item.id}
                  onClick={() => setActiveTab(item.id)}
                  className={`flex items-center space-x-2 px-3 py-2 rounded-lg text-sm font-medium transition-all duration-200 ${
                    isActive
                      ? 'bg-indigo-600/20 text-indigo-300 border border-indigo-500/30 shadow-inner'
                      : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/60'
                  }`}
                >
                  <Icon className={`w-4 h-4 ${isActive ? 'text-indigo-400' : 'text-slate-500'}`} />
                  <span>{item.label}</span>
                  {item.badge && (
                    <span
                      className={`text-[9px] px-1.5 py-0.2 rounded font-semibold ${
                        item.badge === 'Infer'
                          ? 'bg-amber-500/20 text-amber-300 border border-amber-500/30'
                          : 'bg-indigo-500/20 text-indigo-300 border border-indigo-500/30'
                      }`}
                    >
                      {item.badge}
                    </span>
                  )}
                </button>
              );
            })}
          </nav>

          {/* Quick Actions */}
          <div className="flex items-center space-x-2">
            <button
              onClick={onOpenInfoModal}
              title="Iris Number System Foundations"
              className="p-2 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white transition"
            >
              <Info className="w-4 h-4" />
            </button>
            <button
              onClick={onExportWorkspace}
              title="Export Workspace Data"
              className="flex items-center space-x-1.5 px-3 py-1.5 rounded-lg bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-medium transition shadow-md shadow-indigo-600/20"
            >
              <Download className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Export Proof</span>
            </button>
          </div>
        </div>

        {/* Mobile Nav Drawer Bar */}
        <div className="lg:hidden flex items-center space-x-1 py-2 overflow-x-auto scrollbar-none border-t border-slate-800">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                className={`flex items-center space-x-1.5 whitespace-nowrap px-3 py-1.5 rounded-md text-xs font-medium ${
                  isActive
                    ? 'bg-indigo-600/30 text-indigo-300 border border-indigo-500/30'
                    : 'text-slate-400 hover:bg-slate-800'
                }`}
              >
                <Icon className="w-3.5 h-3.5" />
                <span>{item.label}</span>
              </button>
            );
          })}
        </div>
      </div>
    </header>
  );
};
