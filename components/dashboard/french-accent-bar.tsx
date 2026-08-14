'use client';

import {
  useLayoutEffect,
  useRef,
  useState,
  type SyntheticEvent,
} from 'react';
import { Input, type InputProps } from '@/components/ui/input';
import { Textarea, type TextareaProps } from '@/components/ui/textarea';
import { cn } from '@/lib/utils';

const LOWERCASE_CHARS = [
  'à',
  'â',
  'ä',
  'é',
  'è',
  'ê',
  'ë',
  'î',
  'ï',
  'ô',
  'ö',
  'ù',
  'û',
  'ü',
  'ÿ',
  'ç',
  'œ',
  'æ',
] as const;

const UPPERCASE_CHARS = [
  'À',
  'Â',
  'Ä',
  'É',
  'È',
  'Ê',
  'Ë',
  'Î',
  'Ï',
  'Ô',
  'Ö',
  'Ù',
  'Û',
  'Ü',
  'Ÿ',
  'Ç',
  'Œ',
  'Æ',
] as const;

const TYPOGRAPHIC_APOSTROPHE = '\u2019';

export type AccentFieldElement = HTMLInputElement | HTMLTextAreaElement;

interface FrenchAccentBarProps {
  inputRef: { current: AccentFieldElement | null };
  value: string;
  onChange: (value: string) => void;
  disabled?: boolean;
  className?: string;
}

const CHAR_BTN =
  'h-7 min-w-7 touch-manipulation select-none rounded bg-white px-1.5 text-sm font-medium text-gray-800 ring-1 ring-inset ring-gray-200 hover:bg-flehub-green-light hover:text-flehub-green active:bg-flehub-green-light';

export function FrenchAccentBar({
  inputRef,
  value,
  onChange,
  disabled = false,
  className,
}: FrenchAccentBarProps) {
  const [uppercase, setUppercase] = useState(false);
  const caretRef = useRef<number | null>(null);
  const chars = uppercase ? UPPERCASE_CHARS : LOWERCASE_CHARS;

  useLayoutEffect(() => {
    const pos = caretRef.current;
    if (pos == null) return;
    caretRef.current = null;
    const el = inputRef.current;
    if (!el || el.disabled) return;
    el.focus();
    try {
      el.setSelectionRange(pos, pos);
    } catch {
      // some input types do not support a selection range
    }
  }, [value, inputRef]);

  function insertChar(char: string) {
    if (disabled) return;
    const el = inputRef.current;
    const start = el?.selectionStart ?? value.length;
    const end = el?.selectionEnd ?? value.length;
    caretRef.current = start + char.length;
    onChange(value.slice(0, start) + char + value.slice(end));
    el?.focus();
  }

  function press(event: SyntheticEvent, action: () => void) {
    event.preventDefault();
    action();
  }

  return (
    <div
      role="toolbar"
      aria-label="Caractères accentués français"
      className={cn(
        'flex flex-wrap items-center gap-0.5 rounded-md border border-gray-200 bg-gray-50/90 p-1',
        disabled && 'pointer-events-none opacity-50',
        className
      )}
    >
      <button
        type="button"
        tabIndex={-1}
        aria-pressed={uppercase}
        aria-label={uppercase ? 'Minuscules' : 'Majuscules'}
        title={uppercase ? 'Minuscules' : 'Majuscules'}
        disabled={disabled}
        onMouseDown={(e) => e.preventDefault()}
        onPointerDown={(e) => press(e, () => setUppercase((v) => !v))}
        className={cn(
          'h-7 min-w-7 touch-manipulation select-none rounded px-1.5 text-[11px] font-semibold tracking-wide',
          uppercase
            ? 'bg-flehub-green text-white'
            : 'bg-white text-gray-600 ring-1 ring-inset ring-gray-200 hover:bg-gray-100'
        )}
      >
        Maj
      </button>
      {chars.map((char) => (
        <button
          key={char}
          type="button"
          tabIndex={-1}
          disabled={disabled}
          aria-label={`Insérer ${char}`}
          title={char}
          onMouseDown={(e) => e.preventDefault()}
          onPointerDown={(e) => press(e, () => insertChar(char))}
          className={CHAR_BTN}
        >
          {char}
        </button>
      ))}
      <button
        type="button"
        tabIndex={-1}
        disabled={disabled}
        aria-label="Insérer une apostrophe typographique"
        title="Apostrophe ’"
        onMouseDown={(e) => e.preventDefault()}
        onPointerDown={(e) =>
          press(e, () => insertChar(TYPOGRAPHIC_APOSTROPHE))
        }
        className={CHAR_BTN}
      >
        {TYPOGRAPHIC_APOSTROPHE}
      </button>
    </div>
  );
}

type AccentTextareaProps = Omit<TextareaProps, 'onChange' | 'value'> & {
  value: string;
  onChange: (value: string) => void;
};

export function FrenchAccentTextarea({
  value,
  onChange,
  disabled,
  className,
  ...props
}: AccentTextareaProps) {
  const inputRef = useRef<HTMLTextAreaElement>(null);
  return (
    <div className="space-y-1.5">
      <FrenchAccentBar
        inputRef={inputRef}
        value={value}
        onChange={onChange}
        disabled={disabled}
      />
      <Textarea
        {...props}
        ref={inputRef}
        value={value}
        disabled={disabled}
        className={className}
        onChange={(e) => onChange(e.target.value)}
      />
    </div>
  );
}

type AccentInputProps = Omit<InputProps, 'onChange' | 'value' | 'type'> & {
  value: string;
  onChange: (value: string) => void;
};

export function FrenchAccentInput({
  value,
  onChange,
  disabled,
  className,
  ...props
}: AccentInputProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  return (
    <div className="space-y-1.5">
      <FrenchAccentBar
        inputRef={inputRef}
        value={value}
        onChange={onChange}
        disabled={disabled}
      />
      <Input
        {...props}
        ref={inputRef}
        type="text"
        value={value}
        disabled={disabled}
        className={className}
        onChange={(e) => onChange(e.target.value)}
      />
    </div>
  );
}
