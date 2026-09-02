'use client';

import { useEffect, useRef, useState } from 'react';
import { cn } from '@/lib/utils';

export interface DnDToken {
  id: string;
  label: string;
}

const DND_TYPE = 'application/x-flehub-dnd';

const TOKEN_CLASS =
  'dnd-token inline-flex min-h-11 min-w-11 items-center justify-center px-3 py-2.5 rounded-md text-sm font-medium shadow-sm select-none cursor-grab active:cursor-grabbing';

function lockPageScroll(lock: boolean) {
  document.documentElement.classList.toggle('dnd-dragging', lock);
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
 * Drag-and-drop sorter using HTML5 DnD (mouse) + pointer fallback (touch).
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
  const dragLabelRef = useRef<string>('');
  const pointerDragRef = useRef<{
    id: string;
    active: boolean;
  } | null>(null);
  const [ghost, setGhost] = useState<{ x: number; y: number; label: string } | null>(
    null
  );

  function findToken(id: string): DnDToken | undefined {
    return bank.find((t) => t.id === id) ?? answer.find((t) => t.id === id);
  }

  function placeOnAnswer(tokenId: string, index?: number) {
    const token = findToken(tokenId);
    if (!token) return;
    const nextBank = bank.filter((t) => t.id !== tokenId);
    const without = answer.filter((t) => t.id !== tokenId);
    const insertAt = typeof index === 'number' ? index : without.length;
    onBankChange(nextBank);
    onAnswerChange([
      ...without.slice(0, insertAt),
      token,
      ...without.slice(insertAt),
    ]);
  }

  function placeOnBank(tokenId: string) {
    const token = findToken(tokenId);
    if (!token) return;
    if (bank.some((t) => t.id === tokenId)) return;
    onAnswerChange(answer.filter((t) => t.id !== tokenId));
    onBankChange([...bank, token]);
  }

  function clearDrag() {
    setDraggingId(null);
    setGhost(null);
    pointerDragRef.current = null;
    dragLabelRef.current = '';
    lockPageScroll(false);
  }

  function onHtmlDragStart(e: React.DragEvent, tokenId: string, label: string) {
    e.dataTransfer.setData(DND_TYPE, tokenId);
    e.dataTransfer.setData('text/plain', tokenId);
    e.dataTransfer.effectAllowed = 'move';
    setDraggingId(tokenId);
    dragLabelRef.current = label;
  }

  function allowDrop(e: React.DragEvent) {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
  }

  function tokenIdFromEvent(e: React.DragEvent): string | null {
    return e.dataTransfer.getData(DND_TYPE) || e.dataTransfer.getData('text/plain') || draggingId;
  }

  // Pointer / touch fallback: follow finger and drop via elementFromPoint
  useEffect(() => {
    function onMove(e: PointerEvent) {
      const drag = pointerDragRef.current;
      if (!drag?.active) return;
      setGhost({
        x: e.clientX,
        y: e.clientY,
        label: dragLabelRef.current,
      });
    }

    function onUp(e: PointerEvent) {
      const drag = pointerDragRef.current;
      if (!drag?.active) return;

      const el = document.elementFromPoint(e.clientX, e.clientY);
      const dropZone = el?.closest('[data-dnd-drop]') as HTMLElement | null;
      const zone = dropZone?.dataset.dndDrop;
      const indexRaw = dropZone?.dataset.dndIndex;
      const index =
        typeof indexRaw === 'string' && indexRaw !== ''
          ? Number(indexRaw)
          : undefined;

      if (zone === 'answer') placeOnAnswer(drag.id, index);
      else if (zone === 'bank') placeOnBank(drag.id);

      clearDrag();
    }

    window.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup', onUp);
    window.addEventListener('pointercancel', clearDrag);
    return () => {
      window.removeEventListener('pointermove', onMove);
      window.removeEventListener('pointerup', onUp);
      window.removeEventListener('pointercancel', clearDrag);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [bank, answer]);

  function startPointerDrag(e: React.PointerEvent, tokenId: string, label: string) {
    // Mouse uses HTML5 DnD; pointer path is for touch / pen
    if (e.pointerType === 'mouse') return;
    e.preventDefault();
    e.stopPropagation();
    try {
      e.currentTarget.setPointerCapture(e.pointerId);
    } catch {
      /* ignore */
    }
    pointerDragRef.current = { id: tokenId, active: true };
    dragLabelRef.current = label;
    setDraggingId(tokenId);
    setGhost({ x: e.clientX, y: e.clientY, label });
    lockPageScroll(true);
  }

  return (
    <div className={cn('space-y-4', className)}>
      <div>
        <p className="text-xs font-medium text-gray-500 mb-2">{answerLabel}</p>
        <div
          data-dnd-drop="answer"
          className={cn(
            'min-h-[56px] flex flex-wrap gap-2 rounded-lg border-2 border-dashed p-3 transition-colors',
            draggingId
              ? 'border-flehub-green bg-flehub-green-light/40'
              : 'border-gray-200 bg-gray-50'
          )}
          onDragOver={allowDrop}
          onDrop={(e) => {
            e.preventDefault();
            const id = tokenIdFromEvent(e);
            if (id) placeOnAnswer(id);
            clearDrag();
          }}
        >
          {answer.length === 0 ? (
            <p className="text-xs text-gray-400 self-center">
              Glissez les éléments ici
            </p>
          ) : (
            answer.map((token, index) => (
              <div
                key={token.id}
                data-dnd-drop="answer"
                data-dnd-index={String(index)}
                draggable
                role="button"
                tabIndex={0}
                className={cn(
                  TOKEN_CLASS,
                  'bg-white border border-gray-200 text-gray-800',
                  draggingId === token.id && 'opacity-40'
                )}
                onDragStart={(e) => onHtmlDragStart(e, token.id, token.label)}
                onDragEnd={clearDrag}
                onDragOver={allowDrop}
                onDrop={(e) => {
                  e.preventDefault();
                  e.stopPropagation();
                  const id = tokenIdFromEvent(e);
                  if (id) placeOnAnswer(id, index);
                  clearDrag();
                }}
                onPointerDown={(e) => startPointerDrag(e, token.id, token.label)}
              >
                {token.label}
              </div>
            ))
          )}
        </div>
      </div>

      <div>
        <p className="text-xs font-medium text-gray-500 mb-2">{bankLabel}</p>
        <div
          data-dnd-drop="bank"
          className="min-h-[56px] flex flex-wrap gap-2 rounded-lg border border-gray-100 bg-white p-3"
          onDragOver={allowDrop}
          onDrop={(e) => {
            e.preventDefault();
            const id = tokenIdFromEvent(e);
            if (id) placeOnBank(id);
            clearDrag();
          }}
        >
          {bank.length === 0 ? (
            <p className="text-xs text-gray-400 self-center">
              Tous les éléments sont placés
            </p>
          ) : (
            bank.map((token) => (
              <div
                key={token.id}
                draggable
                role="button"
                tabIndex={0}
                className={cn(
                  TOKEN_CLASS,
                  'bg-flehub-green-light border border-flehub-green/30 text-flehub-green',
                  draggingId === token.id && 'opacity-40'
                )}
                onDragStart={(e) => onHtmlDragStart(e, token.id, token.label)}
                onDragEnd={clearDrag}
                onPointerDown={(e) => startPointerDrag(e, token.id, token.label)}
              >
                {token.label}
              </div>
            ))
          )}
        </div>
      </div>

      {ghost && (
        <div
          className="pointer-events-none fixed z-[100] px-3 py-2.5 rounded-md bg-flehub-green text-white text-sm font-medium shadow-lg -translate-x-1/2 -translate-y-[120%]"
          style={{ left: ghost.x, top: ghost.y }}
        >
          {ghost.label}
        </div>
      )}
    </div>
  );
}

interface MatchBoardProps {
  targets: { id: string; label: string; imageUrl?: string | null }[];
  sources: DnDToken[];
  /** Map targetId -> sourceId */
  assignments: Record<string, string | null>;
  onAssign: (targetId: string, sourceId: string | null) => void;
  /**
   * When true, left column always renders an image slot (img or placeholder).
   * Never falls back to showing the word label as the target visual.
   */
  imageMode?: boolean;
  imagePlaceholder?: string;
  className?: string;
}

/** Drag source chips onto target slots (text or image). HTML5 DnD + touch fallback. */
export function MatchBoard({
  targets,
  sources,
  assignments,
  onAssign,
  imageMode = false,
  imagePlaceholder = 'Image…',
  className,
}: MatchBoardProps) {
  const [draggingId, setDraggingId] = useState<string | null>(null);
  const dragLabelRef = useRef<string>('');
  const pointerDragRef = useRef<{ id: string; active: boolean } | null>(null);
  const [ghost, setGhost] = useState<{ x: number; y: number; label: string } | null>(
    null
  );
  const assignmentsRef = useRef(assignments);
  assignmentsRef.current = assignments;

  const usedSourceIds = new Set(
    Object.values(assignments).filter((v): v is string => !!v)
  );
  const available = sources.filter((s) => !usedSourceIds.has(s.id));

  function sourceLabel(id: string | null | undefined) {
    if (!id) return null;
    return sources.find((s) => s.id === id)?.label ?? null;
  }

  function clearDrag() {
    setDraggingId(null);
    setGhost(null);
    pointerDragRef.current = null;
    dragLabelRef.current = '';
    lockPageScroll(false);
  }

  function assignToTarget(targetId: string, sourceId: string) {
    Object.entries(assignmentsRef.current).forEach(([tid, sid]) => {
      if (sid === sourceId && tid !== targetId) onAssign(tid, null);
    });
    onAssign(targetId, sourceId);
  }

  function onHtmlDragStart(e: React.DragEvent, sourceId: string, label: string) {
    e.dataTransfer.setData(DND_TYPE, sourceId);
    e.dataTransfer.setData('text/plain', sourceId);
    e.dataTransfer.effectAllowed = 'move';
    setDraggingId(sourceId);
    dragLabelRef.current = label;
  }

  function allowDrop(e: React.DragEvent) {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
  }

  function tokenIdFromEvent(e: React.DragEvent): string | null {
    return (
      e.dataTransfer.getData(DND_TYPE) ||
      e.dataTransfer.getData('text/plain') ||
      draggingId
    );
  }

  useEffect(() => {
    function onMove(e: PointerEvent) {
      const drag = pointerDragRef.current;
      if (!drag?.active) return;
      setGhost({
        x: e.clientX,
        y: e.clientY,
        label: dragLabelRef.current,
      });
    }

    function onUp(e: PointerEvent) {
      const drag = pointerDragRef.current;
      if (!drag?.active) return;

      const el = document.elementFromPoint(e.clientX, e.clientY);
      const dropZone = el?.closest('[data-dnd-drop="target"]') as HTMLElement | null;
      const targetId = dropZone?.dataset.dndTargetId;
      if (targetId) assignToTarget(targetId, drag.id);

      clearDrag();
    }

    window.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup', onUp);
    window.addEventListener('pointercancel', clearDrag);
    return () => {
      window.removeEventListener('pointermove', onMove);
      window.removeEventListener('pointerup', onUp);
      window.removeEventListener('pointercancel', clearDrag);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [onAssign]);

  function startPointerDrag(e: React.PointerEvent, sourceId: string, label: string) {
    if (e.pointerType === 'mouse') return;
    e.preventDefault();
    e.stopPropagation();
    try {
      e.currentTarget.setPointerCapture(e.pointerId);
    } catch {
      /* ignore */
    }
    pointerDragRef.current = { id: sourceId, active: true };
    dragLabelRef.current = label;
    setDraggingId(sourceId);
    setGhost({ x: e.clientX, y: e.clientY, label });
    lockPageScroll(true);
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
              data-dnd-drop="target"
              data-dnd-target-id={target.id}
              className={cn(
                'flex flex-col xs:flex-row sm:flex-row items-stretch sm:items-center gap-3 rounded-lg border-2 border-dashed p-3 transition-colors',
                draggingId
                  ? 'border-flehub-green bg-flehub-green-light/30'
                  : 'border-gray-200 bg-gray-50'
              )}
              onDragOver={allowDrop}
              onDrop={(e) => {
                e.preventDefault();
                const sourceId = tokenIdFromEvent(e);
                if (sourceId) assignToTarget(target.id, sourceId);
                clearDrag();
              }}
            >
              <div className="flex-1 min-w-0">
                {imageMode || target.imageUrl ? (
                  target.imageUrl ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img
                      src={target.imageUrl}
                      alt={target.label || 'Image'}
                      className="h-20 w-20 max-w-full object-cover rounded-md border border-gray-100 bg-white pointer-events-none"
                      draggable={false}
                    />
                  ) : (
                    <div
                      className="h-20 w-20 rounded-md border border-dashed border-gray-200 bg-white flex items-center justify-center"
                      aria-label="Image en cours de chargement"
                    >
                      <span className="text-[10px] text-gray-400 text-center px-1">
                        {imagePlaceholder}
                      </span>
                    </div>
                  )
                ) : (
                  <p className="text-sm font-medium text-gray-800">{target.label}</p>
                )}
              </div>
              <div className="min-w-0 sm:min-w-[120px] sm:text-right">
                {label && assigned ? (
                  <div className="inline-flex items-center gap-1">
                    <div
                      draggable
                      role="button"
                      tabIndex={0}
                      className={cn(
                        TOKEN_CLASS,
                        'bg-white border border-flehub-green text-flehub-green'
                      )}
                      onDragStart={(e) => onHtmlDragStart(e, assigned, label)}
                      onDragEnd={clearDrag}
                      onPointerDown={(e) => startPointerDrag(e, assigned, label)}
                    >
                      {label}
                    </div>
                    <button
                      type="button"
                      className="flex h-11 w-11 items-center justify-center rounded-md text-gray-400 hover:text-red-500"
                      onClick={() => onAssign(target.id, null)}
                      aria-label="Retirer"
                    >
                      ✕
                    </button>
                  </div>
                ) : (
                  <span className="inline-flex min-h-11 items-center text-xs text-gray-400">
                    Déposer ici
                  </span>
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
            <div
              key={source.id}
              draggable
              role="button"
              tabIndex={0}
              className={cn(
                TOKEN_CLASS,
                'bg-flehub-green-light border border-flehub-green/30 text-flehub-green',
                draggingId === source.id && 'opacity-40'
              )}
              onDragStart={(e) => onHtmlDragStart(e, source.id, source.label)}
              onDragEnd={clearDrag}
              onPointerDown={(e) => startPointerDrag(e, source.id, source.label)}
            >
              {source.label}
            </div>
          ))
        )}
      </div>

      {ghost && (
        <div
          className="pointer-events-none fixed z-[100] px-3 py-2.5 rounded-md bg-flehub-green text-white text-sm font-medium shadow-lg -translate-x-1/2 -translate-y-[120%]"
          style={{ left: ghost.x, top: ghost.y }}
        >
          {ghost.label}
        </div>
      )}
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
