import React from 'react';
import katex from 'katex';
import { IrisApertureDiagram } from './IrisApertureDiagram';

interface AsciiDocViewerProps {
  content: string;
  className?: string;
  onNavigate?: (anchorId: string) => void;
}

export const AsciiDocViewer: React.FC<AsciiDocViewerProps> = ({ content, className = '', onNavigate }) => {
  // Normalize downarrow operator spacing after equals signs across all content
  const normalizeMathSpacing = (mathStr: string): string => {
    return mathStr
      .replace(/=\s*\(\\downarrow\)/g, '= (\\downarrow)')
      .replace(/=\s*\\downarrow/g, '= (\\downarrow)')
      .replace(/=\s*\(↓\)/g, '= (↓)')
      .replace(/=\s*↓/g, '= (↓)');
  };

  // Tokenizer for inline math & text that respects nested brackets in latexmath:[...] and stem:[...]
  const extractInlineMathAndText = (text: string): { type: 'text' | 'math'; content: string }[] => {
    const tokens: { type: 'text' | 'math'; content: string }[] = [];
    let i = 0;
    let textBuffer = '';

    while (i < text.length) {
      // 1. Check for \( ... \)
      if (text.startsWith('\\(', i)) {
        const endIdx = text.indexOf('\\)', i + 2);
        if (endIdx !== -1) {
          if (textBuffer) {
            tokens.push({ type: 'text', content: textBuffer });
            textBuffer = '';
          }
          tokens.push({ type: 'math', content: text.substring(i + 2, endIdx) });
          i = endIdx + 2;
          continue;
        }
      }

      // 2. Check for latexmath:[ ... ] or stem:[ ... ] with nested bracket depth tracking
      const lmMatch = text.substring(i).match(/^(latexmath|stem):\[/);
      if (lmMatch) {
        const prefixLen = lmMatch[0].length;
        let depth = 1;
        let j = i + prefixLen;
        while (j < text.length && depth > 0) {
          if (text[j] === '[') depth++;
          else if (text[j] === ']') depth--;
          j++;
        }
        if (depth === 0) {
          if (textBuffer) {
            tokens.push({ type: 'text', content: textBuffer });
            textBuffer = '';
          }
          tokens.push({ type: 'math', content: text.substring(i + prefixLen, j - 1) });
          i = j;
          continue;
        }
      }

      // 3. Check for $ ... $
      if (text[i] === '$' && (i === 0 || text[i - 1] !== '\\')) {
        const endIdx = text.indexOf('$', i + 1);
        if (endIdx !== -1 && endIdx > i + 1) {
          if (textBuffer) {
            tokens.push({ type: 'text', content: textBuffer });
            textBuffer = '';
          }
          tokens.push({ type: 'math', content: text.substring(i + 1, endIdx) });
          i = endIdx + 1;
          continue;
        }
      }

      textBuffer += text[i];
      i++;
    }

    if (textBuffer) {
      tokens.push({ type: 'text', content: textBuffer });
    }

    return tokens;
  };

  // Render LaTeX math strings cleanly using KaTeX
  const renderMathInline = (text: string): React.ReactNode[] => {
    // 1. First split out block math delimiters \[ ... \] or $$ ... $$
    const blockMathRegex = /\\\[([\s\S]*?)\\\]|\$\$([\s\S]*?)\$\$/g;
    const blocks: { type: 'text' | 'math-block'; content: string }[] = [];
    
    let currentIdx = 0;
    let bMatch;

    while ((bMatch = blockMathRegex.exec(text)) !== null) {
      if (bMatch.index > currentIdx) {
        blocks.push({ type: 'text', content: text.substring(currentIdx, bMatch.index) });
      }
      const mathCode = bMatch[1] || bMatch[2];
      blocks.push({ type: 'math-block', content: mathCode });
      currentIdx = bMatch.index + bMatch[0].length;
    }
    if (currentIdx < text.length) {
      blocks.push({ type: 'text', content: text.substring(currentIdx) });
    }

    return blocks.map((block, idx) => {
      if (block.type === 'math-block') {
        try {
          const html = katex.renderToString(normalizeMathSpacing(block.content.trim()), { displayMode: true, throwOnError: false });
          return (
            <div
              key={`block-${idx}`}
              className="my-4 p-3 bg-slate-950/80 rounded-xl border border-slate-800/80 overflow-x-auto text-amber-200 text-center text-sm sm:text-base font-mono"
              dangerouslySetInnerHTML={{ __html: html }}
            />
          );
        } catch {
          return (
            <div key={`block-err-${idx}`} className="my-2 p-2 bg-rose-950/40 text-rose-300 font-mono text-xs rounded">
              \[{block.content}\]
            </div>
          );
        }
      }

      // Inline math parsing inside text blocks using balanced bracket extraction
      const tokens = extractInlineMathAndText(block.content);
      const inlineElements: React.ReactNode[] = tokens.map((token, tIdx) => {
        if (token.type === 'text') {
          return <span key={`txt-${tIdx}`}>{formatInlineText(token.content)}</span>;
        }
        try {
          const html = katex.renderToString(normalizeMathSpacing(token.content.trim()), { displayMode: false, throwOnError: false });
          return (
            <span
              key={`inmath-${tIdx}`}
              className="inline-block px-1 text-amber-300 font-mono"
              dangerouslySetInnerHTML={{ __html: html }}
            />
          );
        } catch {
          return <code key={`inmath-err-${tIdx}`} className="text-amber-400 font-mono">\( {token.content} \)</code>;
        }
      });

      return <span key={`inline-container-${idx}`}>{inlineElements}</span>;
    });
  };

  // Helper for bold, italic, code, and xref hyperlinking formatting
  const formatInlineText = (text: string): React.ReactNode[] => {
    const parts: React.ReactNode[] = [];
    // Regex matches xref:anchorId[label], <<anchorId,label>>, <<anchorId>>, **bold**, *bold*, _italic_, `code`
    const fmtRegex = /(xref:([a-zA-Z0-9_-]+)\[(.*?)\]|<<([a-zA-Z0-9_-]+),(.*?)>>|<<([a-zA-Z0-9_-]+)>>|\*\*(.*?)\*\*|(?<=\s|^)\*([^\s\*].*?[^\s\*]|\S)\*(?=\s|$|[.,!?;:]|\))|(?<=\s|^)_([^\s_].*?[^\s_]|\S)_(?=\s|$|[.,!?;:]|\))|`([^`]+)`)/g;
    let lastIdx = 0;
    let match;

    while ((match = fmtRegex.exec(text)) !== null) {
      if (match.index > lastIdx) {
        parts.push(text.substring(lastIdx, match.index));
      }

      // Check if match is a cross-reference link
      const linkTarget = match[2] || match[4] || match[6];
      const linkLabel = match[3] || match[5] || match[6];

      if (linkTarget) {
        parts.push(
          <a
            key={`xref-${match.index}`}
            href={`#${linkTarget}`}
            onClick={(e) => {
              e.preventDefault();
              if (onNavigate) {
                onNavigate(linkTarget);
              } else {
                const el = document.getElementById(linkTarget);
                if (el) {
                  el.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }
            }}
            className="text-amber-400 hover:text-amber-300 underline decoration-amber-500/50 hover:decoration-amber-300 font-semibold transition cursor-pointer"
          >
            {formatInlineText(linkLabel)}
          </a>
        );
      } else if (match[7] || match[8]) {
        // Bold
        parts.push(
          <strong key={`b-${match.index}`} className="font-semibold text-slate-100">
            {match[7] || match[8]}
          </strong>
        );
      } else if (match[9]) {
        // Italic
        parts.push(
          <em key={`i-${match.index}`} className="italic text-slate-300">
            {match[9]}
          </em>
        );
      } else if (match[10]) {
        // Code
        parts.push(
          <code key={`c-${match.index}`} className="px-1.5 py-0.5 bg-slate-900 border border-slate-800 text-indigo-300 rounded font-mono text-xs">
            {match[10]}
          </code>
        );
      }

      lastIdx = match.index + match[0].length;
    }

    if (lastIdx < text.length) {
      parts.push(text.substring(lastIdx));
    }

    return parts;
  };

  // Parse lines into AsciiDoc blocks
  const parseAsciiDoc = (docText: string): React.ReactNode[] => {
    const lines = docText.split('\n');
    const nodes: React.ReactNode[] = [];
    let i = 0;
    let pendingAnchorId: string | null = null;

    while (i < lines.length) {
      const line = lines[i].trim();

      if (!line || line === '\\]' || line === '\\]\\]' || line === '\\\\]' || line === '\\\\\\\]') {
        i++;
        continue;
      }

      // Anchor tag check e.g. [#postulate-1] or [[postulate-1]]
      const anchorMatch = line.match(/^\[#([a-zA-Z0-9_-]+)\]$/) || line.match(/^\[\[([a-zA-Z0-9_-]+)\]\]$/);
      if (anchorMatch) {
        pendingAnchorId = anchorMatch[1];
        i++;
        continue;
      }

      // Standalone LaTeX math line auto-detection (e.g., \mathbb{Z} = ..., |\epsilon^*| < ..., x^* = ...)
      const isStandaloneMathLine =
        !line.startsWith('=') &&
        !line.startsWith('[') &&
        !line.startsWith('* ') &&
        !line.startsWith('- ') &&
        !line.match(/^\d+\.\s+\*\*/) &&
        /(\\mathbb|\\mathcal|\\frac|\\sum|\\int|\\iota|\\varpi|\\vartheta|\\mathbf|\\nabla|\\operatorname|\\left|\\right|\\equiv|\\in|\\forall|\\exists|\\partial|\\epsilon|\\[a-zA-Z]+|\^\*)/.test(line) &&
        !line.includes(' represents ') &&
        !line.includes(' is an active ') &&
        !line.includes(' operates as ') &&
        !line.includes(' decomposes ');

      if (isStandaloneMathLine && !line.startsWith('\\[')) {
        const mathCode = line.replace(/^\\\[\s*/, '').replace(/\s*\\\]$/, '').trim();
        const currentAnchor = pendingAnchorId;
        pendingAnchorId = null;
        try {
          const html = katex.renderToString(normalizeMathSpacing(mathCode), { displayMode: true, throwOnError: false });
          nodes.push(
            <div
              id={currentAnchor || undefined}
              key={`standalone-math-${i}`}
              className="my-4 p-3 bg-slate-950/80 rounded-xl border border-slate-800/80 overflow-x-auto text-amber-200 text-center text-sm sm:text-base font-mono"
              dangerouslySetInnerHTML={{ __html: html }}
            />
          );
        } catch {
          nodes.push(
            <div key={`standalone-math-err-${i}`} className="my-2 p-2 bg-rose-950/40 text-rose-300 font-mono text-xs rounded">
              {line}
            </div>
          );
        }
        i++;
        continue;
      }

      // Multi-line / Single-line display math blocks starting with \[ or $$
      if (line.startsWith('\\[') || line.startsWith('$$')) {
        const isDoubleDollar = line.startsWith('$$');
        const endDelimiter = isDoubleDollar ? '$$' : '\\]';

        // Check if single-line block math e.g. \[ x = y \] or $$ x = y $$
        if (line.length > 2 && line.endsWith(endDelimiter)) {
          const mathCode = line.substring(2, line.length - endDelimiter.length).trim().replace(/\\+$/, '').trim();
          const currentAnchor = pendingAnchorId;
          pendingAnchorId = null;
          try {
            const html = katex.renderToString(normalizeMathSpacing(mathCode), { displayMode: true, throwOnError: false });
            nodes.push(
              <div
                id={currentAnchor || undefined}
                key={`math-block-${i}`}
                className="my-4 p-3 bg-slate-950/80 rounded-xl border border-slate-800/80 overflow-x-auto text-amber-200 text-center text-sm sm:text-base font-mono"
                dangerouslySetInnerHTML={{ __html: html }}
              />
            );
          } catch {
            nodes.push(
              <div key={`math-err-${i}`} className="my-2 p-2 bg-rose-950/40 text-rose-300 font-mono text-xs rounded">
                {line}
              </div>
            );
          }
          i++;
          continue;
        }

        // Multi-line block math
        const mathLines: string[] = [];
        // First line after delimiter if any text remains on line
        const firstLineText = line.substring(2).trim();
        if (firstLineText && firstLineText !== endDelimiter) {
          mathLines.push(firstLineText);
        }

        i++;
        while (i < lines.length) {
          const currLine = lines[i].trim();
          if (currLine === endDelimiter || currLine.endsWith(endDelimiter)) {
            if (currLine !== endDelimiter) {
              const lastLineText = currLine.substring(0, currLine.length - endDelimiter.length).trim();
              if (lastLineText) mathLines.push(lastLineText);
            }
            i++; // skip closing delimiter
            break;
          }
          mathLines.push(lines[i]);
          i++;
        }

        let mathCode = mathLines.join('\n').trim();
        mathCode = mathCode.replace(/^\\\[\s*/, '').replace(/\s*\\\]$/, '').replace(/\\+$/, '').trim();
        const currentAnchor = pendingAnchorId;
        pendingAnchorId = null;

        try {
          const html = katex.renderToString(normalizeMathSpacing(mathCode), { displayMode: true, throwOnError: false });
          nodes.push(
            <div
              id={currentAnchor || undefined}
              key={`math-multiline-${i}`}
              className="my-4 p-3 bg-slate-950/80 rounded-xl border border-slate-800/80 overflow-x-auto text-amber-200 text-center text-sm sm:text-base font-mono"
              dangerouslySetInnerHTML={{ __html: html }}
            />
          );
        } catch {
          nodes.push(
            <div key={`math-err-${i}`} className="my-2 p-2 bg-rose-950/40 text-rose-300 font-mono text-xs rounded">
              \[{mathCode}\]
            </div>
          );
        }
        continue;
      }

      // AsciiDoc [latexmath] or [stem] blocks
      if (line === '[latexmath]' || line === '[stem]') {
        i++;
        let delimiter = '';
        if (i < lines.length && (lines[i].trim() === '++++' || lines[i].trim() === '--')) {
          delimiter = lines[i].trim();
          i++;
        }

        const mathLines: string[] = [];
        while (i < lines.length) {
          const curr = lines[i].trim();
          if (delimiter && curr === delimiter) {
            i++;
            break;
          }
          if (!delimiter && (!curr || curr.startsWith('['))) {
            break;
          }
          mathLines.push(lines[i]);
          i++;
        }

        const mathCode = mathLines.join('\n').trim();
        const currentAnchor = pendingAnchorId;
        pendingAnchorId = null;

        try {
          const html = katex.renderToString(normalizeMathSpacing(mathCode), { displayMode: true, throwOnError: false });
          nodes.push(
            <div
              id={currentAnchor || undefined}
              key={`latexmath-block-${i}`}
              className="my-4 p-3 bg-slate-950/80 rounded-xl border border-slate-800/80 overflow-x-auto text-amber-200 text-center text-sm sm:text-base font-mono"
              dangerouslySetInnerHTML={{ __html: html }}
            />
          );
        } catch {
          nodes.push(
            <div key={`latexmath-err-${i}`} className="my-2 p-2 bg-rose-950/40 text-rose-300 font-mono text-xs rounded">
              {mathCode}
            </div>
          );
        }
        continue;
      }

      // LaTeX \begin{...} ... \end{...} environments
      if (line.startsWith('\\begin{')) {
        const mathLines: string[] = [line];
        i++;
        while (i < lines.length) {
          const curr = lines[i].trim();
          mathLines.push(lines[i]);
          i++;
          if (curr.startsWith('\\end{')) {
            break;
          }
        }

        const mathCode = mathLines.join('\n').trim();
        const currentAnchor = pendingAnchorId;
        pendingAnchorId = null;

        try {
          const html = katex.renderToString(normalizeMathSpacing(mathCode), { displayMode: true, throwOnError: false });
          nodes.push(
            <div
              id={currentAnchor || undefined}
              key={`latex-env-${i}`}
              className="my-4 p-3 bg-slate-950/80 rounded-xl border border-slate-800/80 overflow-x-auto text-amber-200 text-center text-sm sm:text-base font-mono"
              dangerouslySetInnerHTML={{ __html: html }}
            />
          );
        } catch {
          nodes.push(
            <div key={`latex-env-err-${i}`} className="my-2 p-2 bg-rose-950/40 text-rose-300 font-mono text-xs rounded">
              {mathCode}
            </div>
          );
        }
        continue;
      }

      // H1 Header (e.g. = Title)
      if (line.startsWith('= ')) {
        const title = line.replace(/^=\s+/, '');
        const currentAnchor = pendingAnchorId;
        pendingAnchorId = null;
        nodes.push(
          <h1
            id={currentAnchor || undefined}
            key={`h1-${i}`}
            className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight border-b border-slate-800 pb-3 mt-6 mb-4"
          >
            {renderMathInline(title)}
          </h1>
        );
        i++;
        continue;
      }

      // H2 Header (e.g. == Chapter/Section Title)
      if (line.startsWith('== ')) {
        const title = line.replace(/^==\s+/, '');
        const currentAnchor = pendingAnchorId;
        pendingAnchorId = null;
        nodes.push(
          <h2
            id={currentAnchor || undefined}
            key={`h2-${i}`}
            className="text-xl sm:text-2xl font-bold text-amber-200 tracking-tight border-b border-slate-800/80 pb-2 mt-8 mb-4"
          >
            {renderMathInline(title)}
          </h2>
        );
        i++;
        continue;
      }

      // H3 Header (e.g. === Subsection Title)
      if (line.startsWith('=== ')) {
        const title = line.replace(/^===\s+/, '');
        const currentAnchor = pendingAnchorId;
        pendingAnchorId = null;
        nodes.push(
          <h3
            id={currentAnchor || undefined}
            key={`h3-${i}`}
            className="text-lg font-semibold text-indigo-300 mt-6 mb-3"
          >
            {renderMathInline(title)}
          </h3>
        );
        i++;
        continue;
      }

      // Custom Visualization Block: [IRIS_VISUALIZATION] or [IRIS_DIAGRAM] or [VISUALIZATION]
      if (line.startsWith('[IRIS_VISUALIZATION]') || line.startsWith('[IRIS_DIAGRAM]') || line.startsWith('[VISUALIZATION]')) {
        nodes.push(<IrisApertureDiagram key={`iris-vis-${i}`} />);
        i++;
        continue;
      }

      // Callout Blocks: [NOTE], [IMPORTANT], [POSTULATE], [DEFINITION], [THEOREM]
      if (line.startsWith('[NOTE]') || line.startsWith('[IMPORTANT]') || line.startsWith('[POSTULATE]') || line.startsWith('[DEFINITION]') || line.startsWith('[THEOREM]')) {
        const blockType = line.match(/\[(.*?)\]/)?.[1] || 'NOTE';
        let blockTitle = '';
        let blockContentLines: string[] = [];
        
        i++;
        // Check optional block title line starting with . Title
        if (i < lines.length && lines[i].trim().startsWith('.')) {
          blockTitle = lines[i].trim().substring(1).trim();
          i++;
        }

        // Check if delimited block starts with ====
        if (i < lines.length && lines[i].trim() === '====') {
          i++;
          while (i < lines.length && lines[i].trim() !== '====') {
            blockContentLines.push(lines[i]);
            i++;
          }
          if (i < lines.length && lines[i].trim() === '====') {
            i++; // skip closing ====
          }
        } else {
          // single line or paragraph block
          while (i < lines.length && lines[i].trim() !== '') {
            blockContentLines.push(lines[i]);
            i++;
          }
        }

        const blockContent = blockContentLines.join('\n');

        // Styles based on blockType
        let boxStyles = 'bg-slate-900/90 border-slate-800 text-slate-200';
        let badgeStyles = 'bg-slate-800 text-slate-300';
        let titleColor = 'text-white';

        if (blockType === 'POSTULATE') {
          boxStyles = 'bg-amber-950/20 border-amber-500/40 text-amber-100 shadow-lg shadow-amber-950/20';
          badgeStyles = 'bg-amber-500/20 text-amber-300 border border-amber-500/30';
          titleColor = 'text-amber-300';
        } else if (blockType === 'DEFINITION') {
          boxStyles = 'bg-indigo-950/20 border-indigo-500/40 text-indigo-100 shadow-lg shadow-indigo-950/20';
          badgeStyles = 'bg-indigo-500/20 text-indigo-300 border border-indigo-500/30';
          titleColor = 'text-indigo-300';
        } else if (blockType === 'THEOREM') {
          boxStyles = 'bg-purple-950/20 border-purple-500/40 text-purple-100 shadow-lg shadow-purple-950/20';
          badgeStyles = 'bg-purple-500/20 text-purple-300 border border-purple-500/30';
          titleColor = 'text-purple-300';
        } else if (blockType === 'IMPORTANT') {
          boxStyles = 'bg-rose-950/20 border-rose-500/40 text-rose-100';
          badgeStyles = 'bg-rose-500/20 text-rose-300 border border-rose-500/30';
          titleColor = 'text-rose-300';
        } else if (blockType === 'NOTE') {
          boxStyles = 'bg-sky-950/20 border-sky-500/40 text-sky-100';
          badgeStyles = 'bg-sky-500/20 text-sky-300 border border-sky-500/30';
          titleColor = 'text-sky-300';
        }

        const currentAnchor = pendingAnchorId;
        pendingAnchorId = null;

        nodes.push(
          <div
            id={currentAnchor || undefined}
            key={`callout-${i}`}
            className={`my-6 p-5 rounded-2xl border ${boxStyles} space-y-3 font-sans transition-all duration-500`}
          >
            <div className="flex items-center space-x-2">
              <span className={`px-2.5 py-0.5 rounded-md text-[10px] font-mono font-bold tracking-wider uppercase ${badgeStyles}`}>
                {blockType}
              </span>
              {blockTitle && (
                <h4 className={`text-sm font-bold ${titleColor}`}>
                  {renderMathInline(blockTitle)}
                </h4>
              )}
            </div>
            <div className="text-xs sm:text-sm leading-relaxed space-y-2">
              {parseAsciiDoc(blockContent)}
            </div>
          </div>
        );
        continue;
      }

      // Unordered list items starting with *, -, or **
      if (line.startsWith('* ') || line.startsWith('- ') || line.startsWith('** ')) {
        const listItems: string[] = [];
        while (i < lines.length && (lines[i].trim().startsWith('* ') || lines[i].trim().startsWith('- ') || lines[i].trim().startsWith('** '))) {
          listItems.push(lines[i].trim().replace(/^(\*\*|\*|\-)\s+/, ''));
          i++;
        }
        const currentAnchor = pendingAnchorId;
        pendingAnchorId = null;

        nodes.push(
          <ul
            id={currentAnchor || undefined}
            key={`ul-${i}`}
            className="my-4 space-y-2 list-disc list-outside pl-6 text-xs sm:text-sm text-slate-300"
          >
            {listItems.map((li, liIdx) => (
              <li key={`li-${liIdx}`} className="leading-relaxed pl-1">
                {renderMathInline(li)}
              </li>
            ))}
          </ul>
        );
        continue;
      }

      // Ordered list items starting with . or 1.
      const isOrderedItem = line.startsWith('. ') || /^\d+\.\s+/.test(line);
      if (isOrderedItem) {
        const listItems: { text: string; extraNodes?: React.ReactNode[] }[] = [];
        
        while (i < lines.length) {
          const curr = lines[i].trim();
          if (!curr) {
            // Empty line: check if next non-empty line continues list or ends it
            let nextIdx = i + 1;
            while (nextIdx < lines.length && !lines[nextIdx].trim()) nextIdx++;
            if (nextIdx < lines.length) {
              const nextLine = lines[nextIdx].trim();
              if (nextLine.startsWith('. ') || /^\d+\.\s+/.test(nextLine)) {
                i = nextIdx;
                continue;
              }
            }
            break;
          }

          if (curr.startsWith('. ') || /^\d+\.\s+/.test(curr)) {
            const itemText = curr.replace(/^(\.|\d+\.)\s+/, '');
            listItems.push({ text: itemText });
            i++;
          } else if (listItems.length > 0 && (curr.startsWith('\\[') || curr.startsWith('$$'))) {
            // Display math block inside or between list items
            const mathLines: string[] = [];
            const isDoubleDollar = curr.startsWith('$$');
            const endDelimiter = isDoubleDollar ? '$$' : '\\]';
            if (curr.length > 2 && curr.endsWith(endDelimiter)) {
              mathLines.push(curr.substring(2, curr.length - endDelimiter.length).trim());
              i++;
            } else {
              if (curr.substring(2).trim()) mathLines.push(curr.substring(2).trim());
              i++;
              while (i < lines.length) {
                const ml = lines[i].trim();
                if (ml === endDelimiter || ml.endsWith(endDelimiter)) {
                  if (ml !== endDelimiter) {
                    const lastText = ml.substring(0, ml.length - endDelimiter.length).trim();
                    if (lastText) mathLines.push(lastText);
                  }
                  i++;
                  break;
                }
                mathLines.push(lines[i]);
                i++;
              }
            }
            const mathCode = mathLines.join('\n').trim();
            try {
              const html = katex.renderToString(normalizeMathSpacing(mathCode), { displayMode: true, throwOnError: false });
              const mathNode = (
                <div
                  key={`ol-math-${i}`}
                  className="my-3 p-3 bg-slate-950/80 rounded-xl border border-slate-800/80 overflow-x-auto text-amber-200 text-center text-sm sm:text-base font-mono"
                  dangerouslySetInnerHTML={{ __html: html }}
                />
              );
              const lastItem = listItems[listItems.length - 1];
              lastItem.extraNodes = [...(lastItem.extraNodes || []), mathNode];
            } catch {
              // fallback
            }
          } else if (listItems.length > 0 && !curr.startsWith('=') && !curr.startsWith('[') && !curr.startsWith('* ') && !curr.startsWith('- ')) {
            // Continuation line for last list item
            const lastItem = listItems[listItems.length - 1];
            lastItem.text += ' ' + curr;
            i++;
          } else {
            break;
          }
        }

        const currentAnchor = pendingAnchorId;
        pendingAnchorId = null;

        nodes.push(
          <ol
            id={currentAnchor || undefined}
            key={`ol-${i}`}
            className="my-4 space-y-3 list-decimal list-outside pl-6 text-xs sm:text-sm text-slate-300"
          >
            {listItems.map((li, liIdx) => (
              <li key={`ol-li-${liIdx}`} className="leading-relaxed pl-1">
                <div>{renderMathInline(li.text)}</div>
                {li.extraNodes}
              </li>
            ))}
          </ol>
        );
        continue;
      }

      // Standard paragraph
      const currentAnchor = pendingAnchorId;
      pendingAnchorId = null;

      nodes.push(
        <p
          id={currentAnchor || undefined}
          key={`p-${i}`}
          className="my-3 text-xs sm:text-sm leading-relaxed text-slate-300"
        >
          {renderMathInline(line)}
        </p>
      );
      i++;
    }

    return nodes;
  };

  return <div className={`prose prose-invert max-w-none font-sans ${className}`}>{parseAsciiDoc(content)}</div>;
};

