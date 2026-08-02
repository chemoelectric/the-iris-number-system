import React, { useState } from 'react';
import {
  BookOpen,
  ChevronRight,
  Code,
  Download,
  FileText,
  Search,
  Sparkles,
  Layers,
  Plus,
  CheckCircle,
  HelpCircle,
  Hash,
  Bookmark
} from 'lucide-react';
import { INITIAL_TEXTBOOK, TEXTBOOK_VOLUMES, generateFullAsciiDoc } from '../data/textbookData';
import { TextbookChapter, TextbookSection } from '../types';
import { AsciiDocViewer } from './AsciiDocViewer';

export const IrisTextbook: React.FC = () => {
  const [selectedVolumeId, setSelectedVolumeId] = useState<string>(INITIAL_TEXTBOOK.id);
  const textbook = TEXTBOOK_VOLUMES.find((v) => v.id === selectedVolumeId) || INITIAL_TEXTBOOK;

  const [selectedChapterId, setSelectedChapterId] = useState<string>(textbook.chapters[0].id);
  const [selectedSectionId, setSelectedSectionId] = useState<string>(textbook.chapters[0].sections[0].id);
  
  // View mode: 'rendered' or 'source'
  const [viewMode, setViewMode] = useState<'rendered' | 'source'>('rendered');
  
  // Search query for TOC or textbook content
  const [searchQuery, setSearchQuery] = useState<string>('');

  const handleSelectVolume = (volId: string) => {
    setSelectedVolumeId(volId);
    const targetVol = TEXTBOOK_VOLUMES.find((v) => v.id === volId) || INITIAL_TEXTBOOK;
    if (targetVol.chapters.length > 0) {
      setSelectedChapterId(targetVol.chapters[0].id);
      if (targetVol.chapters[0].sections.length > 0) {
        setSelectedSectionId(targetVol.chapters[0].sections[0].id);
      }
    }
  };

  // Active chapter and section objects
  const activeChapter = textbook.chapters.find((c) => c.id === selectedChapterId) || textbook.chapters[0];
  const activeSection = activeChapter.sections.find((s) => s.id === selectedSectionId) || activeChapter.sections[0];

  // Navigate to target anchor across chapters/sections
  const handleNavigateToAnchor = (anchorId: string) => {
    for (const chap of textbook.chapters) {
      for (const sec of chap.sections) {
        if (sec.contentAsciiDoc.includes(`[#${anchorId}]`) || sec.contentAsciiDoc.includes(anchorId)) {
          setSelectedChapterId(chap.id);
          setSelectedSectionId(sec.id);
          
          setTimeout(() => {
            const el = document.getElementById(anchorId);
            if (el) {
              el.scrollIntoView({ behavior: 'smooth', block: 'center' });
              el.classList.add('ring-2', 'ring-amber-400', 'ring-offset-2', 'ring-offset-slate-900');
              setTimeout(() => {
                el.classList.remove('ring-2', 'ring-amber-400', 'ring-offset-2', 'ring-offset-slate-900');
              }, 2500);
            }
          }, 150);
          return;
        }
      }
    }
  };

  // Export full textbook as raw AsciiDoc file (.adoc)
  const handleExportAsciiDoc = () => {
    const adoc = generateFullAsciiDoc(textbook);
    const blob = new Blob([adoc], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `Iris_Number_System.adoc`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  // Filtered TOC based on search query
  const filteredChapters = textbook.chapters.map((chap) => {
    if (!searchQuery.trim()) return chap;
    const q = searchQuery.toLowerCase();
    const matchesChap = chap.title.toLowerCase().includes(q) || (chap.summary && chap.summary.toLowerCase().includes(q));
    const matchingSections = chap.sections.filter(
      (sec) => sec.title.toLowerCase().includes(q) || sec.contentAsciiDoc.toLowerCase().includes(q)
    );
    if (matchesChap || matchingSections.length > 0) {
      return {
        ...chap,
        sections: matchingSections.length > 0 ? matchingSections : chap.sections,
      };
    }
    return null;
  }).filter(Boolean) as TextbookChapter[];

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="bg-[#181818] p-6 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div className="flex items-center space-x-4">
          <div className="p-3 bg-[#222222] text-slate-200">
            <BookOpen className="w-7 h-7" />
          </div>
          <div>
            <div className="flex items-center space-x-2 flex-wrap gap-y-1">
              <h1 className="text-xl font-extrabold text-white tracking-tight">
                {textbook.title}
                {textbook.subtitle && <span className="text-slate-300 font-semibold ml-2">: {textbook.subtitle}</span>}
              </h1>
              <span className="text-[10px] font-mono px-2 py-0.5 bg-[#222222] text-slate-300 uppercase tracking-widest">
                AsciiDoc • Unnumbered
              </span>
            </div>
            <p className="text-xs text-slate-400 mt-1 max-w-2xl">
              Official Treatise on the Counting-Iris Number System — {textbook.subtitle || 'Fundamentals'}. Chapters and sections are named without ordinal numbers.
            </p>
          </div>
        </div>

        {/* Action Controls */}
        <div className="flex flex-wrap items-center gap-3 w-full md:w-auto justify-end">
          {/* Volume Switcher Dropdown */}
          <div className="flex items-center space-x-2 bg-[#121212] px-3 py-1.5 font-mono text-xs text-slate-300">
            <Bookmark className="w-3.5 h-3.5 text-slate-400" />
            <select
              value={selectedVolumeId}
              onChange={(e) => handleSelectVolume(e.target.value)}
              className="bg-transparent text-xs text-slate-200 focus:outline-none cursor-pointer font-sans"
            >
              {TEXTBOOK_VOLUMES.map((vol) => (
                <option key={vol.id} value={vol.id} className="bg-[#181818] text-slate-200">
                  Volume: {vol.subtitle} ({vol.author})
                </option>
              ))}
            </select>
          </div>

          {/* Mode Switcher */}
          <div className="flex items-center p-1 bg-[#121212] font-mono text-xs">
            <button
              onClick={() => setViewMode('rendered')}
              className={`flex items-center space-x-1.5 px-3 py-1.5 transition ${
                viewMode === 'rendered'
                  ? 'bg-[#282828] text-white font-bold'
                  : 'text-slate-400 hover:text-slate-200'
              }`}
            >
              <FileText className="w-3.5 h-3.5" />
              <span>Rendered</span>
            </button>
            <button
              onClick={() => setViewMode('source')}
              className={`flex items-center space-x-1.5 px-3 py-1.5 transition ${
                viewMode === 'source'
                  ? 'bg-[#282828] text-white font-bold'
                  : 'text-slate-400 hover:text-slate-200'
              }`}
            >
              <Code className="w-3.5 h-3.5" />
              <span>AsciiDoc Source</span>
            </button>
          </div>

          <a
            href="/Iris_Number_System.adoc"
            download="Iris_Number_System.adoc"
            title="Download Public AsciiDoc File (/Iris_Number_System.adoc)"
            className="flex items-center space-x-1.5 px-3.5 py-2 bg-[#222222] hover:bg-[#2a2a2a] text-slate-200 text-xs font-medium transition"
          >
            <Download className="w-3.5 h-3.5 text-slate-300" />
            <span className="hidden sm:inline">Download .adoc</span>
          </a>
        </div>
      </div>

      {/* Main Grid: Left Sidebar Table of Contents + Right Content Stage */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* LEFT SIDEBAR: Table of Contents */}
        <aside className="lg:col-span-4 bg-[#181818] p-4 space-y-4 sticky top-20">
          <div className="flex items-center justify-between pb-3">
            <div className="flex items-center space-x-2">
              <Layers className="w-4 h-4 text-slate-300" />
              <h2 className="text-sm font-bold text-white uppercase tracking-wider font-mono">
                Table of Contents
              </h2>
            </div>
            <span className="text-[10px] text-slate-500 font-mono">Unnumbered</span>
          </div>

          {/* Search Bar */}
          <div className="relative">
            <Search className="w-3.5 h-3.5 absolute left-3 top-2.5 text-slate-500" />
            <input
              type="text"
              placeholder="Search chapters or sections..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-[#121212] pl-8 pr-3 py-1.5 text-xs text-slate-200 placeholder-slate-500 focus:outline-none transition font-mono"
            />
          </div>

          {/* TOC Chapter List */}
          <div className="space-y-3 max-h-[600px] overflow-y-auto pr-1 scrollbar-thin">
            {filteredChapters.length === 0 ? (
              <div className="p-4 text-center text-xs text-slate-500">
                No matching chapters or sections found.
              </div>
            ) : (
              filteredChapters.map((chapter) => {
                const isChapterActive = chapter.id === selectedChapterId;
                return (
                  <div key={chapter.id} className="space-y-1">
                    {/* Chapter Header (Unnumbered, Named Only) */}
                    <button
                      onClick={() => {
                        setSelectedChapterId(chapter.id);
                        if (chapter.sections.length > 0) {
                          setSelectedSectionId(chapter.sections[0].id);
                        }
                      }}
                      className={`w-full flex items-center justify-between p-2.5 text-left transition font-semibold text-xs ${
                        isChapterActive
                          ? 'bg-[#262626] text-white font-bold'
                          : 'text-slate-300 hover:bg-[#202020] hover:text-white'
                      }`}
                    >
                      <div className="flex items-center space-x-2 truncate">
                        <Bookmark className={`w-3.5 h-3.5 shrink-0 ${isChapterActive ? 'text-slate-200' : 'text-slate-500'}`} />
                        <span className="truncate">{chapter.title}</span>
                      </div>
                      <ChevronRight className={`w-3.5 h-3.5 shrink-0 transition-transform ${isChapterActive ? 'rotate-90 text-slate-200' : 'text-slate-600'}`} />
                    </button>

                    {/* Sections under active Chapter */}
                    {isChapterActive && (
                      <div className="ml-3 pl-3 space-y-1 py-1 bg-[#141414]">
                        {chapter.sections.map((section) => {
                          const isSectionActive = section.id === selectedSectionId;
                          return (
                            <button
                              key={section.id}
                              onClick={() => setSelectedSectionId(section.id)}
                              className={`w-full text-left px-2.5 py-1.5 text-xs font-medium transition flex items-center justify-between ${
                                isSectionActive
                                  ? 'bg-[#2a2a2a] text-slate-100 font-bold'
                                  : 'text-slate-400 hover:text-slate-200 hover:bg-[#1f1f1f]'
                              }`}
                            >
                              <span className="truncate">{section.title}</span>
                              {isSectionActive && <CheckCircle className="w-3 h-3 text-slate-300 shrink-0 ml-1" />}
                            </button>
                          );
                        })}
                      </div>
                    )}
                  </div>
                );
              })
            )}
          </div>

          <div className="pt-3 text-[11px] text-slate-500 leading-snug">
            <p className="font-mono text-slate-400 font-semibold mb-1">Directives Active:</p>
            • Chapters and sections are strictly unnumbered.<br />
            • LatexMath formulas rendered via KaTeX.<br />
            • Directives ready for subsequent user additions.
          </div>
        </aside>

        {/* RIGHT CONTENT STAGE */}
        <main className="lg:col-span-8 space-y-6">
          {/* Chapter & Section Header Card */}
          <div className="bg-[#181818] p-6 space-y-3">
            <div className="flex items-center justify-between pb-3">
              <div className="flex items-center space-x-2 text-xs font-mono text-slate-300">
                <span>Chapter</span>
                <ChevronRight className="w-3 h-3 text-slate-600" />
                <span className="text-slate-100 font-bold">{activeChapter.title}</span>
              </div>
              <span className="text-[10px] font-mono text-slate-500 bg-[#121212] px-2.5 py-0.5">
                Unnumbered Section
              </span>
            </div>

            <h2 className="text-2xl font-extrabold text-white">{activeSection.title}</h2>
            {activeChapter.summary && (
              <div className="text-xs sm:text-sm text-slate-400 leading-relaxed italic bg-[#141414] p-3">
                <AsciiDocViewer content={activeChapter.summary} onNavigate={handleNavigateToAnchor} />
              </div>
            )}
          </div>

          {/* Textbook Main Content Display */}
          <div className="bg-[#181818] p-6 sm:p-8 min-h-[500px]">
            {viewMode === 'rendered' ? (
              <AsciiDocViewer content={activeSection.contentAsciiDoc} onNavigate={handleNavigateToAnchor} />
            ) : (
              <div className="space-y-4">
                <div className="flex items-center justify-between pb-2 text-xs font-mono text-slate-400">
                  <span>Raw AsciiDoc / LatexMath Source</span>
                  <span>{activeSection.id}.adoc</span>
                </div>
                <textarea
                  readOnly
                  value={activeSection.contentAsciiDoc.trim()}
                  rows={20}
                  className="w-full bg-[#121212] p-4 text-xs font-mono text-slate-200 leading-relaxed focus:outline-none scrollbar-thin"
                />
              </div>
            )}
          </div>

          {/* Section Navigation Footer */}
          <div className="flex items-center justify-between pt-2">
            {/* Find previous section */}
            {(() => {
              const allSections: { chapId: string; sec: TextbookSection }[] = [];
              textbook.chapters.forEach((chap) => {
                chap.sections.forEach((sec) => {
                  allSections.push({ chapId: chap.id, sec });
                });
              });
              const currentIdx = allSections.findIndex(
                (item) => item.chapId === selectedChapterId && item.sec.id === selectedSectionId
              );
              const prevItem = currentIdx > 0 ? allSections[currentIdx - 1] : null;
              const nextItem = currentIdx < allSections.length - 1 ? allSections[currentIdx + 1] : null;

              return (
                <>
                  {prevItem ? (
                    <button
                      onClick={() => {
                        setSelectedChapterId(prevItem.chapId);
                        setSelectedSectionId(prevItem.sec.id);
                      }}
                      className="px-4 py-2 bg-[#222222] hover:bg-[#2a2a2a] text-slate-300 text-xs font-medium transition flex items-center space-x-1.5"
                    >
                      <ChevronRight className="w-3.5 h-3.5 rotate-180 text-slate-400" />
                      <span>{prevItem.sec.title}</span>
                    </button>
                  ) : (
                    <div />
                  )}

                  {nextItem ? (
                    <button
                      onClick={() => {
                        setSelectedChapterId(nextItem.chapId);
                        setSelectedSectionId(nextItem.sec.id);
                      }}
                      className="px-4 py-2 bg-[#282828] hover:bg-[#333333] text-slate-200 text-xs font-medium transition flex items-center space-x-1.5"
                    >
                      <span>{nextItem.sec.title}</span>
                      <ChevronRight className="w-3.5 h-3.5 text-slate-400" />
                    </button>
                  ) : (
                    <div />
                  )}
                </>
              );
            })()}
          </div>
        </main>
      </div>
    </div>
  );
};
