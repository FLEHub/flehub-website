'use client';

import { useEffect, useMemo, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Button } from '@/components/ui/button';
import {
  FrenchAccentInput,
  FrenchAccentTextarea,
} from '@/components/dashboard/french-accent-bar';
import { Label } from '@/components/ui/label';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { pickImageMatchPath, resolveElearningMediaUrl } from '@/lib/elearning-content';
import {
  exerciseTypeLabels,
  splitLetters,
  type ExerciseType,
} from '@/lib/elearning-exercises';
import {
  MatchBoard,
  TokenSorter,
  shuffleArray,
  type DnDToken,
} from '@/components/dashboard/dnd-tokens';
import { AudioRecorder } from '@/components/dashboard/audio-recorder';
import { MEDIA_BUCKET } from '@/lib/elearning-content';
import { CheckCircle2, Loader2, RotateCcw, XCircle } from 'lucide-react';

export interface PlayableExercise {
  id: string;
  title: string;
  exercise_type: ExerciseType;
  content: Record<string, unknown>;
}

interface ElearningExercisePlayerProps {
  exercise: PlayableExercise;
  learnerId?: string | null;
  onResult?: (result: { correct: boolean | null; detail?: string }) => void;
}

function asStringArray(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value.filter((v): v is string => typeof v === 'string');
}

export function ElearningExercisePlayer({
  exercise,
  learnerId,
  onResult,
}: ElearningExercisePlayerProps) {
  const type = exercise.exercise_type;
  const content = exercise.content ?? {};

  return (
    <div className="space-y-4">
      <div>
        <p className="text-xs text-gray-400">{exerciseTypeLabels[type] ?? type}</p>
        <h3 className="text-base font-semibold text-gray-900">{exercise.title}</h3>
      </div>

      {type === 'word_order' && (
        <WordOrderPlayer content={content} onResult={onResult} />
      )}
      {type === 'anagram' && <AnagramPlayer content={content} onResult={onResult} />}
      {type === 'matching' && <MatchingPlayer content={content} onResult={onResult} />}
      {type === 'image_match' && (
        <ImageMatchPlayer content={content} onResult={onResult} />
      )}
      {type === 'true_false' && (
        <TrueFalsePlayer content={content} onResult={onResult} />
      )}
      {type === 'find_error' && (
        <FindErrorPlayer content={content} onResult={onResult} />
      )}
      {type === 'qcm' && <QcmPlayer content={content} onResult={onResult} />}
      {type === 'fill_blank' && (
        <FillBlankPlayer content={content} onResult={onResult} />
      )}
      {type === 'short_answer' && (
        <ShortAnswerPlayer content={content} onResult={onResult} />
      )}
      {type === 'audio_record' && (
        <AudioRecordPlayer
          exerciseId={exercise.id}
          learnerId={learnerId}
          content={content}
          onResult={onResult}
        />
      )}
    </div>
  );
}

function ResultBanner({
  correct,
  explanation,
}: {
  correct: boolean | null;
  explanation?: string;
}) {
  if (correct === null) return null;
  return (
    <div
      className={`rounded-lg p-3 text-sm flex items-start gap-2 ${
        correct
          ? 'bg-flehub-green-light text-flehub-green'
          : 'bg-red-50 text-red-600'
      }`}
    >
      {correct ? (
        <CheckCircle2 className="w-4 h-4 mt-0.5 shrink-0" />
      ) : (
        <XCircle className="w-4 h-4 mt-0.5 shrink-0" />
      )}
      <div>
        <p className="font-medium">{correct ? 'Bonne réponse' : 'Pas tout à fait'}</p>
        {explanation && <p className="text-xs mt-1 opacity-80">{explanation}</p>}
      </div>
    </div>
  );
}

function WordOrderPlayer({
  content,
  onResult,
}: {
  content: Record<string, unknown>;
  onResult?: ElearningExercisePlayerProps['onResult'];
}) {
  const words = asStringArray(content.words);
  const initial = useMemo(
    () =>
      shuffleArray(
        words.map((label, i) => ({ id: `w-${i}-${label}`, label }))
      ),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [words.join('|')]
  );
  const [bank, setBank] = useState<DnDToken[]>(initial);
  const [answer, setAnswer] = useState<DnDToken[]>([]);
  const [correct, setCorrect] = useState<boolean | null>(null);

  function reset() {
    setBank(shuffleArray(initial));
    setAnswer([]);
    setCorrect(null);
  }

  function check() {
    const ok =
      answer.length === words.length &&
      answer.every((t, i) => t.label === words[i]);
    setCorrect(ok);
    onResult?.({ correct: ok });
  }

  return (
    <div className="space-y-4">
      <TokenSorter
        bank={bank}
        answer={answer}
        onBankChange={setBank}
        onAnswerChange={setAnswer}
        bankLabel="Mots mélangés"
        answerLabel="Reconstituez la phrase"
      />
      <div className="flex gap-2">
        <Button
          className="bg-flehub-green hover:bg-flehub-green/90 text-white"
          onClick={check}
          disabled={answer.length === 0}
        >
          Vérifier
        </Button>
        <Button variant="outline" onClick={reset}>
          <RotateCcw className="w-3.5 h-3.5 mr-1" />
          Recommencer
        </Button>
      </div>
      <ResultBanner correct={correct} />
    </div>
  );
}

function AnagramPlayer({
  content,
  onResult,
}: {
  content: Record<string, unknown>;
  onResult?: ElearningExercisePlayerProps['onResult'];
}) {
  const word = typeof content.word === 'string' ? content.word : '';
  const hint = typeof content.hint === 'string' ? content.hint : '';
  const letters = splitLetters(word);
  const initial = useMemo(
    () =>
      shuffleArray(
        letters.map((label, i) => ({ id: `l-${i}-${label}`, label }))
      ),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [word]
  );
  const [bank, setBank] = useState<DnDToken[]>(initial);
  const [answer, setAnswer] = useState<DnDToken[]>([]);
  const [correct, setCorrect] = useState<boolean | null>(null);

  function reset() {
    setBank(shuffleArray(initial));
    setAnswer([]);
    setCorrect(null);
  }

  function check() {
    const ok =
      answer.length === letters.length &&
      answer.every((t, i) => t.label === letters[i]);
    setCorrect(ok);
    onResult?.({ correct: ok });
  }

  return (
    <div className="space-y-4">
      {hint && (
        <p className="text-sm text-gray-500">
          Indice : <span className="italic">{hint}</span>
        </p>
      )}
      <TokenSorter
        bank={bank}
        answer={answer}
        onBankChange={setBank}
        onAnswerChange={setAnswer}
        bankLabel="Lettres mélangées"
        answerLabel="Reconstituez le mot"
      />
      <div className="flex gap-2">
        <Button
          className="bg-flehub-green hover:bg-flehub-green/90 text-white"
          onClick={check}
          disabled={answer.length === 0}
        >
          Vérifier
        </Button>
        <Button variant="outline" onClick={reset}>
          <RotateCcw className="w-3.5 h-3.5 mr-1" />
          Recommencer
        </Button>
      </div>
      <ResultBanner correct={correct} />
    </div>
  );
}

function MatchingPlayer({
  content,
  onResult,
}: {
  content: Record<string, unknown>;
  onResult?: ElearningExercisePlayerProps['onResult'];
}) {
  const pairs = Array.isArray(content.pairs) ? content.pairs : [];
  const targets = pairs.map((p, i) => {
    const pair = p as Record<string, unknown>;
    return {
      id: `t-${i}`,
      label: typeof pair.left === 'string' ? pair.left : `Élément ${i + 1}`,
      right: typeof pair.right === 'string' ? pair.right : '',
    };
  });
  const sources = useMemo(
    () =>
      shuffleArray(
        targets.map((t, i) => ({
          id: `s-${i}`,
          label: t.right,
          targetId: t.id,
        }))
      ),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [JSON.stringify(targets.map((t) => t.right))]
  );

  const [assignments, setAssignments] = useState<Record<string, string | null>>(
    () => Object.fromEntries(targets.map((t) => [t.id, null]))
  );
  const [correct, setCorrect] = useState<boolean | null>(null);

  function onAssign(targetId: string, sourceId: string | null) {
    setAssignments((prev) => ({ ...prev, [targetId]: sourceId }));
    setCorrect(null);
  }

  function check() {
    const ok = targets.every((t, i) => {
      const sourceId = assignments[t.id];
      const source = sources.find((s) => s.id === sourceId);
      return source?.label === t.right;
    });
    setCorrect(ok);
    onResult?.({ correct: ok });
  }

  return (
    <div className="space-y-4">
      <MatchBoard
        targets={targets.map((t) => ({ id: t.id, label: t.label }))}
        sources={sources}
        assignments={assignments}
        onAssign={onAssign}
      />
      <Button
        className="bg-flehub-green hover:bg-flehub-green/90 text-white"
        onClick={check}
      >
        Vérifier
      </Button>
      <ResultBanner correct={correct} />
    </div>
  );
}

function ImageMatchPlayer({
  content,
  onResult,
}: {
  content: Record<string, unknown>;
  onResult?: ElearningExercisePlayerProps['onResult'];
}) {
  const supabase = useMemo(() => createClient(), []);
  const pairs = Array.isArray(content.pairs) ? content.pairs : [];
  const [imageUrls, setImageUrls] = useState<Record<string, string>>({});
  const [imagesReady, setImagesReady] = useState(false);
  const [correct, setCorrect] = useState<boolean | null>(null);

  const targets = useMemo(
    () =>
      pairs.map((p, i) => {
        const pair =
          p && typeof p === 'object' && !Array.isArray(p)
            ? (p as Record<string, unknown>)
            : {};
        const word = typeof pair.word === 'string' ? pair.word.trim() : '';
        return {
          id: `img-${i}`,
          label: word || `Image ${i + 1}`,
          image_path: pickImageMatchPath(pair),
          word,
        };
      }),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [JSON.stringify(pairs)]
  );

  const sources = useMemo(
    () =>
      shuffleArray(
        targets.map((t, i) => ({
          id: `word-${i}`,
          label: t.word,
        }))
      ),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [targets.map((t) => t.word).join('|')]
  );

  const [assignments, setAssignments] = useState<Record<string, string | null>>(
    () => Object.fromEntries(targets.map((t) => [t.id, null]))
  );

  useEffect(() => {
    setAssignments(Object.fromEntries(targets.map((t) => [t.id, null])));
  }, [targets]);

  useEffect(() => {
    let cancelled = false;
    async function load() {
      setImagesReady(false);
      const entries: Record<string, string> = {};
      await Promise.all(
        targets.map(async (t) => {
          if (!t.image_path) return;
          const url = await resolveElearningMediaUrl(supabase, t.image_path);
          if (url) entries[t.id] = url;
        })
      );
      if (!cancelled) {
        setImageUrls(entries);
        setImagesReady(true);
      }
    }
    void load();
    return () => {
      cancelled = true;
    };
  }, [supabase, targets]);

  function check() {
    const ok = targets.every((t) => {
      const sourceId = assignments[t.id];
      const source = sources.find((s) => s.id === sourceId);
      return source?.label === t.word;
    });
    setCorrect(ok);
    onResult?.({ correct: ok });
  }

  return (
    <div className="space-y-4">
      <p className="text-sm text-gray-500">
        Glissez chaque mot vers l&apos;image correspondante
      </p>
      <MatchBoard
        imageMode
        imagePlaceholder={imagesReady ? 'Indispo.' : 'Image…'}
        targets={targets.map((t) => ({
          id: t.id,
          label: t.word,
          imageUrl: imageUrls[t.id] ?? null,
        }))}
        sources={sources}
        assignments={assignments}
        onAssign={(targetId, sourceId) => {
          setAssignments((prev) => ({ ...prev, [targetId]: sourceId }));
          setCorrect(null);
        }}
      />
      {imagesReady &&
        targets.some((t) => t.image_path && !imageUrls[t.id]) && (
          <p className="text-xs text-amber-600">
            Certaines images n&apos;ont pas pu être chargées. Vérifiez qu&apos;elles
            sont bien enregistrées dans le bucket elearning-media.
          </p>
        )}
      <Button
        className="bg-flehub-green hover:bg-flehub-green/90 text-white"
        onClick={check}
      >
        Vérifier
      </Button>
      <ResultBanner correct={correct} />
    </div>
  );
}

function TrueFalsePlayer({
  content,
  onResult,
}: {
  content: Record<string, unknown>;
  onResult?: ElearningExercisePlayerProps['onResult'];
}) {
  const statement = typeof content.statement === 'string' ? content.statement : '';
  const expected = Boolean(content.correct);
  const explanation =
    typeof content.explanation === 'string' ? content.explanation : '';
  const [choice, setChoice] = useState<'true' | 'false' | ''>('');
  const [correct, setCorrect] = useState<boolean | null>(null);

  function check() {
    if (!choice) return;
    const ok = (choice === 'true') === expected;
    setCorrect(ok);
    onResult?.({ correct: ok, detail: explanation });
  }

  return (
    <div className="space-y-4">
      <p className="text-sm text-gray-800 font-medium">{statement}</p>
      <RadioGroup
        value={choice}
        onValueChange={(v) => {
          setChoice(v as 'true' | 'false');
          setCorrect(null);
        }}
        className="flex gap-4"
      >
        <label className="flex items-center gap-2 text-sm cursor-pointer">
          <RadioGroupItem value="true" id="tf-true" />
          Vrai
        </label>
        <label className="flex items-center gap-2 text-sm cursor-pointer">
          <RadioGroupItem value="false" id="tf-false" />
          Faux
        </label>
      </RadioGroup>
      <Button
        className="bg-flehub-green hover:bg-flehub-green/90 text-white"
        disabled={!choice}
        onClick={check}
      >
        Vérifier
      </Button>
      <ResultBanner
        correct={correct}
        explanation={correct === false || correct === true ? explanation : undefined}
      />
    </div>
  );
}

function FindErrorPlayer({
  content,
  onResult,
}: {
  content: Record<string, unknown>;
  onResult?: ElearningExercisePlayerProps['onResult'];
}) {
  const withError =
    typeof content.sentence_with_error === 'string'
      ? content.sentence_with_error
      : '';
  const expected =
    typeof content.correct_sentence === 'string' ? content.correct_sentence : '';
  const explanation =
    typeof content.explanation === 'string' ? content.explanation : '';
  const [answer, setAnswer] = useState('');
  const [correct, setCorrect] = useState<boolean | null>(null);

  function normalize(s: string) {
    return s.trim().replace(/\s+/g, ' ').toLowerCase();
  }

  function check() {
    const ok = normalize(answer) === normalize(expected);
    setCorrect(ok);
    onResult?.({ correct: ok, detail: explanation });
  }

  return (
    <div className="space-y-4">
      <div className="rounded-lg border border-amber-200 bg-amber-50 p-3">
        <p className="text-xs text-amber-700 mb-1">Phrase avec erreur</p>
        <p className="text-sm font-medium text-gray-900">{withError}</p>
      </div>
      <div className="space-y-2">
        <Label htmlFor="find-error-answer">Corrigez la phrase</Label>
        <FrenchAccentTextarea
          id="find-error-answer"
          rows={2}
          value={answer}
          onChange={(next) => {
            setAnswer(next);
            setCorrect(null);
          }}
          placeholder="Écrivez la phrase corrigée…"
        />
      </div>
      <Button
        className="bg-flehub-green hover:bg-flehub-green/90 text-white"
        disabled={!answer.trim()}
        onClick={check}
      >
        Vérifier
      </Button>
      <ResultBanner
        correct={correct}
        explanation={
          correct === false
            ? `${explanation ? explanation + ' — ' : ''}Correction : ${expected}`
            : explanation
        }
      />
    </div>
  );
}

function QcmPlayer({
  content,
  onResult,
}: {
  content: Record<string, unknown>;
  onResult?: ElearningExercisePlayerProps['onResult'];
}) {
  const question = typeof content.question === 'string' ? content.question : '';
  const explanation =
    typeof content.explanation === 'string' ? content.explanation : '';
  const options = Array.isArray(content.options) ? content.options : [];
  const [selected, setSelected] = useState<number | null>(null);
  const [correct, setCorrect] = useState<boolean | null>(null);

  function check() {
    if (selected === null) return;
    const opt = options[selected] as Record<string, unknown> | string | undefined;
    const ok =
      typeof opt === 'object' && opt
        ? Boolean(opt.correct ?? opt.is_correct)
        : false;
    setCorrect(ok);
    onResult?.({ correct: ok, detail: explanation });
  }

  return (
    <div className="space-y-4">
      <p className="text-sm font-medium text-gray-900">{question}</p>
      <RadioGroup
        value={selected === null ? '' : String(selected)}
        onValueChange={(v) => {
          setSelected(Number(v));
          setCorrect(null);
        }}
      >
        {options.map((opt, i) => {
          const text =
            typeof opt === 'string'
              ? opt
              : typeof (opt as Record<string, unknown>)?.text === 'string'
                ? String((opt as Record<string, unknown>).text)
                : `Option ${i + 1}`;
          return (
            <label
              key={i}
              className="flex items-center gap-2 text-sm cursor-pointer rounded-md border border-gray-100 bg-gray-50 px-3 py-2"
            >
              <RadioGroupItem value={String(i)} />
              {text}
            </label>
          );
        })}
      </RadioGroup>
      <Button
        className="bg-flehub-green hover:bg-flehub-green/90 text-white"
        disabled={selected === null}
        onClick={check}
      >
        Vérifier
      </Button>
      <ResultBanner correct={correct} explanation={explanation} />
    </div>
  );
}

function FillBlankPlayer({
  content,
  onResult,
}: {
  content: Record<string, unknown>;
  onResult?: ElearningExercisePlayerProps['onResult'];
}) {
  const prompt = typeof content.prompt === 'string' ? content.prompt : '';
  const expected = typeof content.answer === 'string' ? content.answer : '';
  const [answer, setAnswer] = useState('');
  const [correct, setCorrect] = useState<boolean | null>(null);

  function check() {
    const ok = answer.trim().toLowerCase() === expected.trim().toLowerCase();
    setCorrect(ok);
    onResult?.({ correct: ok });
  }

  return (
    <div className="space-y-4">
      <p className="text-sm text-gray-800 whitespace-pre-wrap">{prompt}</p>
      <FrenchAccentInput
        value={answer}
        onChange={(next) => {
          setAnswer(next);
          setCorrect(null);
        }}
        placeholder="Votre réponse…"
      />
      <Button
        className="bg-flehub-green hover:bg-flehub-green/90 text-white"
        disabled={!answer.trim()}
        onClick={check}
      >
        Vérifier
      </Button>
      <ResultBanner correct={correct} />
    </div>
  );
}

function ShortAnswerPlayer({
  content,
  onResult,
}: {
  content: Record<string, unknown>;
  onResult?: ElearningExercisePlayerProps['onResult'];
}) {
  const prompt =
    typeof content.prompt === 'string'
      ? content.prompt
      : typeof content.question === 'string'
        ? content.question
        : '';
  const [answer, setAnswer] = useState('');

  return (
    <div className="space-y-4">
      <p className="text-sm text-gray-800 whitespace-pre-wrap">{prompt}</p>
      <FrenchAccentTextarea
        rows={4}
        value={answer}
        onChange={setAnswer}
        placeholder="Votre réponse libre…"
      />
      <Button
        className="bg-flehub-green hover:bg-flehub-green/90 text-white"
        disabled={!answer.trim()}
        onClick={() => onResult?.({ correct: null, detail: answer.trim() })}
      >
        Envoyer (correction manuelle)
      </Button>
      <p className="text-xs text-gray-400">
        Cette réponse sera corrigée manuellement par l&apos;enseignant.
      </p>
    </div>
  );
}

function AudioRecordPlayer({
  exerciseId,
  learnerId,
  content,
  onResult,
}: {
  exerciseId: string;
  learnerId?: string | null;
  content: Record<string, unknown>;
  onResult?: ElearningExercisePlayerProps['onResult'];
}) {
  const supabase = useMemo(() => createClient(), []);
  const instructions =
    typeof content.instructions === 'string'
      ? content.instructions
      : typeof content.prompt === 'string'
        ? content.prompt
        : '';

  const [blob, setBlob] = useState<Blob | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function submit() {
    if (!blob || !learnerId) {
      setError(
        !learnerId
          ? 'Profil apprenant introuvable.'
          : 'Enregistrez un audio avant de soumettre.'
      );
      return;
    }
    setSubmitting(true);
    setError(null);
    try {
      const path = `exercise-audio/${exerciseId}/${learnerId}.webm`;
      const { error: upErr } = await supabase.storage
        .from(MEDIA_BUCKET)
        .upload(path, blob, {
          upsert: true,
          contentType: blob.type || 'audio/webm',
        });
      if (upErr) throw upErr;

      const now = new Date().toISOString();
      const { data: existing } = await supabase
        .from('exercise_audio_submissions')
        .select('id')
        .eq('exercise_id', exerciseId)
        .eq('learner_id', learnerId)
        .maybeSingle();

      if (existing) {
        const { error: updErr } = await supabase
          .from('exercise_audio_submissions')
          .update({
            audio_path: path,
            teacher_feedback: null,
            validated: false,
            submitted_at: now,
            validated_at: null,
          })
          .eq('id', existing.id);
        if (updErr) throw updErr;
      } else {
        const { error: insErr } = await supabase
          .from('exercise_audio_submissions')
          .insert({
            exercise_id: exerciseId,
            learner_id: learnerId,
            audio_path: path,
            submitted_at: now,
          });
        if (insErr) throw insErr;
      }

      setSubmitted(true);
      onResult?.({ correct: null, detail: path });
    } catch (err) {
      console.error(err);
      setError(err instanceof Error ? err.message : 'Échec de l’envoi audio');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="space-y-4">
      <p className="text-sm text-gray-800 whitespace-pre-wrap">{instructions}</p>
      <AudioRecorder
        disabled={submitting || submitted}
        onBlobChange={setBlob}
      />
      <Button
        className="bg-flehub-green hover:bg-flehub-green/90 text-white"
        disabled={!blob || submitting || submitted || !learnerId}
        onClick={() => void submit()}
      >
        {submitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
        {submitted ? 'Soumis à l’enseignant' : 'Soumettre à l’enseignant'}
      </Button>
      {submitted && (
        <p className="text-xs text-flehub-green">
          Audio envoyé. Votre enseignant pourra l’écouter et commenter.
        </p>
      )}
      {error && <p className="text-sm text-red-600">{error}</p>}
    </div>
  );
}
