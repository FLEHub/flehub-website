'use client';

import { useCallback, useEffect, useRef, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Highlighter } from 'lucide-react';

export interface TextHighlight {
  start: number;
  end: number;
}

interface PeHighlightEditorProps {
  content: string;
  highlights: TextHighlight[];
  onChange: (highlights: TextHighlight[]) => void;
}

function normalizeHighlights(highlights: TextHighlight[], contentLength: number): TextHighlight[] {
  return [...highlights]
    .map((h) => ({
      start: Math.max(0, Math.min(h.start, contentLength)),
      end: Math.max(0, Math.min(h.end, contentLength)),
    }))
    .filter((h) => h.end > h.start)
    .sort((a, b) => a.start - b.start);
}

function mergeOverlaps(highlights: TextHighlight[]): TextHighlight[] {
  if (highlights.length === 0) return [];
  const sorted = [...highlights].sort((a, b) => a.start - b.start);
  const merged: TextHighlight[] = [{ ...sorted[0] }];
  for (let i = 1; i < sorted.length; i++) {
    const last = merged[merged.length - 1];
    const curr = sorted[i];
    if (curr.start <= last.end) {
      last.end = Math.max(last.end, curr.end);
    } else {
      merged.push({ ...curr });
    }
  }
  return merged;
}

function getSelectionOffsets(container: HTMLElement): TextHighlight | null {
  const selection = window.getSelection();
  if (!selection || selection.rangeCount === 0 || selection.isCollapsed) return null;

  const range = selection.getRangeAt(0);
  if (!container.contains(range.commonAncestorContainer)) return null;

  const preRange = range.cloneRange();
  preRange.selectNodeContents(container);
  preRange.setEnd(range.startContainer, range.startOffset);
  const start = preRange.toString().length;
  const end = start + range.toString().length;

  if (end <= start) return null;
  return { start, end };
}

export function PeHighlightEditor({ content, highlights, onChange }: PeHighlightEditorProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [floating, setFloating] = useState<{
    top: number;
    left: number;
    range: TextHighlight;
  } | null>(null);

  const normalized = normalizeHighlights(highlights, content.length);

  const handleMouseUp = useCallback(() => {
    const container = containerRef.current;
    if (!container) return;

    const offsets = getSelectionOffsets(container);
    if (!offsets) {
      setFloating(null);
      return;
    }

    const selection = window.getSelection();
    if (!selection || selection.rangeCount === 0) {
      setFloating(null);
      return;
    }

    const rect = selection.getRangeAt(0).getBoundingClientRect();
    const containerRect = container.getBoundingClientRect();
    setFloating({
      top: rect.top - containerRect.top - 36,
      left: Math.max(0, rect.left - containerRect.left + rect.width / 2 - 80),
      range: offsets,
    });
  }, []);

  useEffect(() => {
    const clear = () => {
      const selection = window.getSelection();
      if (!selection || selection.isCollapsed) setFloating(null);
    };
    document.addEventListener('selectionchange', clear);
    return () => document.removeEventListener('selectionchange', clear);
  }, []);

  function addHighlight(range: TextHighlight) {
    const next = mergeOverlaps(
      normalizeHighlights([...normalized, range], content.length)
    );
    onChange(next);
    setFloating(null);
    window.getSelection()?.removeAllRanges();
  }

  function removeHighlight(index: number) {
    onChange(normalized.filter((_, i) => i !== index));
  }

  const segments: Array<{ text: string; highlightIndex: number | null }> = [];
  let cursor = 0;
  normalized.forEach((h, index) => {
    if (h.start > cursor) {
      segments.push({ text: content.slice(cursor, h.start), highlightIndex: null });
    }
    segments.push({ text: content.slice(h.start, h.end), highlightIndex: index });
    cursor = h.end;
  });
  if (cursor < content.length) {
    segments.push({ text: content.slice(cursor), highlightIndex: null });
  }
  if (segments.length === 0) {
    segments.push({ text: content, highlightIndex: null });
  }

  return (
    <div className="relative">
      {floating && (
        <div
          className="absolute z-20"
          style={{ top: floating.top, left: floating.left }}
        >
          <Button
            type="button"
            size="sm"
            className="h-8 shadow-md bg-red-600 hover:bg-red-700 text-white"
            onMouseDown={(e) => e.preventDefault()}
            onClick={() => addHighlight(floating.range)}
          >
            <Highlighter className="w-3.5 h-3.5 mr-1" />
            Surligner comme erreur
          </Button>
        </div>
      )}

      <div
        ref={containerRef}
        onMouseUp={handleMouseUp}
        className="rounded-lg border border-gray-200 bg-gray-50 p-4 text-sm text-gray-800 whitespace-pre-wrap leading-relaxed select-text"
      >
        {segments.map((seg, i) =>
          seg.highlightIndex === null ? (
            <span key={i}>{seg.text}</span>
          ) : (
            <mark
              key={i}
              role="button"
              tabIndex={0}
              title="Cliquer pour retirer le surlignage"
              onClick={() => removeHighlight(seg.highlightIndex!)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' || e.key === ' ') {
                  e.preventDefault();
                  removeHighlight(seg.highlightIndex!);
                }
              }}
              className="bg-red-100 text-red-900 cursor-pointer rounded-sm px-0.5 underline decoration-wavy decoration-red-400"
            >
              {seg.text}
            </mark>
          )
        )}
      </div>
      <p className="text-xs text-gray-400 mt-2">
        Sélectionnez une portion de texte pour la marquer comme erreur. Cliquez un
        surlignage pour le retirer.
      </p>
    </div>
  );
}

/** Read-only PE text with teacher error highlights (learner view). */
export function PeHighlightViewer({
  content,
  highlights,
}: {
  content: string;
  highlights: TextHighlight[];
}) {
  const normalized = normalizeHighlights(highlights, content.length);
  const segments: Array<{ text: string; highlighted: boolean }> = [];
  let cursor = 0;
  normalized.forEach((h) => {
    if (h.start > cursor) {
      segments.push({ text: content.slice(cursor, h.start), highlighted: false });
    }
    segments.push({ text: content.slice(h.start, h.end), highlighted: true });
    cursor = h.end;
  });
  if (cursor < content.length) {
    segments.push({ text: content.slice(cursor), highlighted: false });
  }
  if (segments.length === 0) {
    segments.push({ text: content, highlighted: false });
  }

  return (
    <div className="rounded-lg border border-gray-200 bg-gray-50 p-4 text-sm text-gray-800 whitespace-pre-wrap leading-relaxed">
      {segments.map((seg, i) =>
        seg.highlighted ? (
          <mark
            key={i}
            className="bg-red-100 text-red-900 rounded-sm px-0.5 underline decoration-wavy decoration-red-400"
          >
            {seg.text}
          </mark>
        ) : (
          <span key={i}>{seg.text}</span>
        )
      )}
    </div>
  );
}
