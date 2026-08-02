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
    <header className="sticky top-0 z-40 bg-[#161616] text-slate-100 shadow-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo & Brand */}
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-amber-500/20 p-0.5 flex items-center justify-center">
              <div className="w-full h-full bg-[#121212] flex items-center justify-center">
                <Sparkles className="w-5 h-5 text-amber-400" />
              </div>
            </div>
            <div>
              <div className="flex items-center space-x-2">
                <h1 className="font-bold text-lg text-amber-200">
                  Iris Number System
                </h1>
                <span className="text-[10px] uppercase font-mono tracking-widest px-2 py-0.5 bg-[#222222] text-amber-300">
                  Inference Engine v2.5
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
                  className={`flex items-center space-x-2 px-3 py-2 text-sm font-medium transition-colors ${
                    isActive
                      ? 'bg-[#262626] text-amber-300'
                      : 'text-slate-400 hover:text-slate-100 hover:bg-[#202020]'
                  }`}
                >
                  <Icon className={`w-4 h-4 ${isActive ? 'text-amber-400' : 'text-slate-500'}`} />
                  <span>{item.label}</span>
                  {item.badge && (
                    <span
                      className={`text-[9px] px-1.5 py-0.2 font-semibold ${
                        item.badge === 'Infer'
                          ? 'bg-amber-500/20 text-amber-300'
                          : 'bg-indigo-500/20 text-indigo-300'
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
              className="p-2 bg-[#222222] hover:bg-[#2a2a2a] text-slate-300 hover:text-white transition"
            >
              <Info className="w-4 h-4" />
            </button>
            <button
              onClick={onExportWorkspace}
              title="Export Workspace Data"
              className="flex items-center space-x-1.5 px-3 py-1.5 bg-[#282828] hover:bg-[#333333] text-amber-200 text-xs font-medium transition"
            >
              <Download className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Export Proof</span>
            </button>
          </div>
        </div>

        {/* Mobile Nav Drawer Bar */}
        <div className="lg:hidden flex items-center space-x-1 py-2 overflow-x-auto scrollbar-none bg-[#141414]">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                className={`flex items-center space-x-1.5 whitespace-nowrap px-3 py-1.5 text-xs font-medium ${
                  isActive
                    ? 'bg-[#2a2a2a] text-amber-300'
                    : 'text-slate-400 hover:bg-[#202020]'
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
