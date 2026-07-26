'use client';

import { useRef, useState } from 'react';
import { cn } from '@/lib/utils';

export interface DnDToken {
  id: string;
  label: string;
}

interface TokenSorterProps {
  /** Correct order labels (used only for validation by parent). */
  bank: DnDToken[];
  answer: DnDToken[];
  onBankChange: (bank: DnDToken[]) => void;
  onAnswerChange: (answer: DnDToken[]) => void;
  bankLabel?: string;
  answerLabel?: string;
  className?: string;
}

/**
 * Touch-friendly drag-and-drop sorter (pointer events).
 * Drag tokens from the bank into the answer row, reorder, or drag back.
 */
export function TokenSorter({
  bank,
  answer,
  onBankChange,
  onAnswerChange,
  bankLabel = 'Éléments mélangés',
  answerLabel = 'Votre réponse',
  className,
}: TokenSorterProps) {
  const [draggingId, setDraggingId] = useState<string | null>(null);
  const dragSource = useRef<'bank' | 'answer' | null>(null);

  function findToken(id: string): DnDToken | undefined {
    return bank.find((t) => t.id === id) ?? answer.find((t) => t.id === id);
  }

  function onPointerDown(
    e: React.PointerEvent,
    tokenId: string,
    source: 'bank' | 'answer'
  ) {
    (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
    setDraggingId(tokenId);
    dragSource.current = source;
  }

  function dropOnAnswer(index?: number) {
    if (!draggingId) return;
    const token = findToken(draggingId);
    if (!token) return;

    const nextBank = bank.filter((t) => t.id !== draggingId);
    const without = answer.filter((t) => t.id !== draggingId);
    const insertAt = typeof index === 'number' ? index : without.length;
    const nextAnswer = [
      ...without.slice(0, insertAt),
      token,
      ...without.slice(insertAt),
    ];

    onBankChange(nextBank);
    onAnswerChange(nextAnswer);
    setDraggingId(null);
    dragSource.current = null;
  }

  function dropOnBank() {
    if (!draggingId) return;
    const token = findToken(draggingId);
    if (!token) return;

    const nextAnswer = answer.filter((t) => t.id !== draggingId);
    if (bank.some((t) => t.id === draggingId)) {
      setDraggingId(null);
      dragSource.current = null;
      return;
    }
    onAnswerChange(nextAnswer);
    onBankChange([...bank, token]);
    setDraggingId(null);
    dragSource.current = null;
  }

  function endDrag() {
    setDraggingId(null);
    dragSource.current = null;
  }

  return (
    <div className={cn('space-y-4', className)}>
      <div>
        <p className="text-xs font-medium text-gray-500 mb-2">{answerLabel}</p>
        <div
          className={cn(
            'min-h-[56px] flex flex-wrap gap-2 rounded-lg border-2 border-dashed p-3 transition-colors',
            draggingId ? 'border-flehub-green bg-flehub-green-light/40' : 'border-gray-200 bg-gray-50'
          )}
          onPointerUp={() => dropOnAnswer()}
        >
          {answer.length === 0 ? (
            <p className="text-xs text-gray-400 self-center">
              Glissez les éléments ici
            </p>
          ) : (
            answer.map((token, index) => (
              <button
                key={token.id}
                type="button"
                className={cn(
                  'px-3 py-1.5 rounded-md bg-white border border-gray-200 text-sm font-medium text-gray-800 shadow-sm touch-none select-none',
                  draggingId === token.id && 'opacity-40'
                )}
                onPointerDown={(e) => onPointerDown(e, token.id, 'answer')}
                onPointerUp={(e) => {
                  e.stopPropagation();
                  if (draggingId && draggingId !== token.id) dropOnAnswer(index);
                  else endDrag();
                }}
              >
                {token.label}
              </button>
            ))
          )}
        </div>
      </div>

      <div>
        <p className="text-xs font-medium text-gray-500 mb-2">{bankLabel}</p>
        <div
          className="min-h-[56px] flex flex-wrap gap-2 rounded-lg border border-gray-100 bg-white p-3"
          onPointerUp={dropOnBank}
        >
          {bank.length === 0 ? (
            <p className="text-xs text-gray-400 self-center">Tous les éléments sont placés</p>
          ) : (
            bank.map((token) => (
              <button
                key={token.id}
                type="button"
                className={cn(
                  'px-3 py-1.5 rounded-md bg-flehub-green-light border border-flehub-green/30 text-sm font-medium text-flehub-green touch-none select-none',
                  draggingId === token.id && 'opacity-40'
                )}
                onPointerDown={(e) => onPointerDown(e, token.id, 'bank')}
                onPointerUp={(e) => {
                  e.stopPropagation();
                  endDrag();
                }}
              >
                {token.label}
              </button>
            ))
          )}
        </div>
      </div>
    </div>
  );
}

interface MatchBoardProps {
  targets: { id: string; label: string; imageUrl?: string }[];
  sources: DnDToken[];
  /** Map targetId -> sourceId */
  assignments: Record<string, string | null>;
  onAssign: (targetId: string, sourceId: string | null) => void;
  className?: string;
}

/** Drag source chips onto target slots (text or image). Touch-friendly. */
export function MatchBoard({
  targets,
  sources,
  assignments,
  onAssign,
  className,
}: MatchBoardProps) {
  const [draggingId, setDraggingId] = useState<string | null>(null);

  const usedSourceIds = new Set(
    Object.values(assignments).filter((v): v is string => !!v)
  );
  const available = sources.filter((s) => !usedSourceIds.has(s.id));

  function sourceLabel(id: string | null | undefined) {
    if (!id) return null;
    return sources.find((s) => s.id === id)?.label ?? null;
  }

  return (
    <div className={cn('space-y-4', className)}>
      <div className="space-y-2">
        {targets.map((target) => {
          const assigned = assignments[target.id] ?? null;
          const label = sourceLabel(assigned);
          return (
            <div
              key={target.id}
              className={cn(
                'flex items-center gap-3 rounded-lg border-2 border-dashed p-3 transition-colors',
                draggingId
                  ? 'border-flehub-green bg-flehub-green-light/30'
                  : 'border-gray-200 bg-gray-50'
              )}
              onPointerUp={() => {
                if (draggingId) {
                  // Clear previous assignment of this source
                  Object.entries(assignments).forEach(([tid, sid]) => {
                    if (sid === draggingId && tid !== target.id) onAssign(tid, null);
                  });
                  onAssign(target.id, draggingId);
                  setDraggingId(null);
                }
              }}
            >
              <div className="flex-1 min-w-0">
                {target.imageUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={target.imageUrl}
                    alt={target.label}
                    className="h-16 w-16 object-cover rounded-md border border-gray-100 bg-white"
                  />
                ) : (
                  <p className="text-sm font-medium text-gray-800">{target.label}</p>
                )}
              </div>
              <div className="min-w-[120px] text-right">
                {label ? (
                  <button
                    type="button"
                    className="px-3 py-1.5 rounded-md bg-white border border-flehub-green text-sm text-flehub-green"
                    onClick={() => onAssign(target.id, null)}
                  >
                    {label} ✕
                  </button>
                ) : (
                  <span className="text-xs text-gray-400">Déposer ici</span>
                )}
              </div>
            </div>
          );
        })}
      </div>

      <div className="flex flex-wrap gap-2 rounded-lg border border-gray-100 bg-white p-3 min-h-[52px]">
        {available.length === 0 ? (
          <p className="text-xs text-gray-400">Tous les éléments sont associés</p>
        ) : (
          available.map((source) => (
            <button
              key={source.id}
              type="button"
              className={cn(
                'px-3 py-1.5 rounded-md bg-flehub-green-light border border-flehub-green/30 text-sm font-medium text-flehub-green touch-none select-none',
                draggingId === source.id && 'opacity-40'
              )}
              onPointerDown={(e) => {
                (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
                setDraggingId(source.id);
              }}
              onPointerUp={() => setDraggingId(null)}
            >
              {source.label}
            </button>
          ))
        )}
      </div>
    </div>
  );
}

export function shuffleArray<T>(items: T[]): T[] {
  const arr = [...items];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}
