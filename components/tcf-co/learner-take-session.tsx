'use client';

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Skeleton } from '@/components/ui/skeleton';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import {
  AlertTriangle,
  ArrowLeft,
  Clock,
  Headphones,
  Loader2,
} from 'lucide-react';
import { cn } from '@/lib/utils';

const AUDIO_BUCKET = 'tcf-co-audios';
const TOTAL_QUESTIONS = 40;

type Choice = 'a' | 'b' | 'c' | 'd';

interface TcfCoSession {
  id: string;
  titre: string;
  duree_minuteur: number;
  statut: 'brouillon' | 'publiee';
}

/** Colonnes de la vue tcf_co_questions_pour_apprenants (sans bonne_reponse). */
interface SafeQuestion {
  id: string;
  session_id: string;
  ordre: number;
  niveau: string;
  audio_url: string;
  question_texte: string;
  choix_a: string;
  choix_b: string;
  choix_c: string;
  choix_d: string;
}

function formatCountdown(totalSeconds: number): string {
  const safe = Math.max(0, totalSeconds);
  const h = Math.floor(safe / 3600);
  const m = Math.floor((safe % 3600) / 60);
  const s = safe % 60;
  if (h > 0) {
    return `${h}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  }
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
}

export default function LearnerTakeTcfCoSession() {
  const params = useParams();
  const router = useRouter();
  const sessionId = params.sessionId as string;
  const supabase = useMemo(() => createClient(), []);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [session, setSession] = useState<TcfCoSession | null>(null);
  const [questions, setQuestions] = useState<SafeQuestion[]>([]);
  const [attemptId, setAttemptId] = useState<string | null>(null);
  const [startedAtMs, setStartedAtMs] = useState<number | null>(null);
  const [durationSeconds, setDurationSeconds] = useState(0);
  const [remainingSeconds, setRemainingSeconds] = useState(0);

  const [currentIndex, setCurrentIndex] = useState(0);
  const [answers, setAnswers] = useState<Record<string, Choice>>({});
  const [selected, setSelected] = useState<Choice | ''>('');
  const [audioUrl, setAudioUrl] = useState<string>('');
  const [audioLoading, setAudioLoading] = useState(false);
  const [finishing, setFinishing] = useState(false);

  const answersRef = useRef(answers);
  const finishingRef = useRef(false);
  const attemptIdRef = useRef<string | null>(null);
  const startedAtMsRef = useRef<number | null>(null);
  const finishTestRef = useRef<
    ((finalAnswers: Record<string, Choice>) => Promise<void>) | null
  >(null);

  useEffect(() => {
    answersRef.current = answers;
  }, [answers]);

  useEffect(() => {
    attemptIdRef.current = attemptId;
  }, [attemptId]);

  useEffect(() => {
    startedAtMsRef.current = startedAtMs;
  }, [startedAtMs]);

  const currentQuestion = questions[currentIndex] ?? null;
  const answeredCount = Object.keys(answers).length;
  const allAnswered =
    questions.length > 0 && answeredCount >= questions.length;
  const isLastQuestion =
    questions.length > 0 && currentIndex >= questions.length - 1;

  const finishTest = useCallback(
    async (finalAnswers: Record<string, Choice>) => {
      if (finishingRef.current) return;
      const id = attemptIdRef.current;
      const started = startedAtMsRef.current;
      if (!id || !started) return;

      finishingRef.current = true;
      setFinishing(true);
      setError(null);

      try {
        const elapsed = Math.max(
          0,
          Math.round((Date.now() - started) / 1000)
        );

        const { error: rpcError } = await supabase.rpc(
          'correct_student_co_attempt',
          {
            p_attempt_id: id,
            p_reponses: finalAnswers,
            p_temps_utilise_secondes: elapsed,
          }
        );

        if (rpcError) {
          // Fallback si le RPC échoue : au moins clôturer la tentative
          const { error: updateError } = await supabase
            .from('student_co_attempts')
            .update({
              reponses: finalAnswers,
              temps_utilise_secondes: elapsed,
              completed_at: new Date().toISOString(),
            })
            .eq('id', id);
          if (updateError) throw rpcError;
        }

        router.replace(
          `/dashboard/learner/preparation/tcf-co/${sessionId}/results/${id}`
        );
      } catch (err) {
        console.error(err);
        finishingRef.current = false;
        setFinishing(false);
        setError(
          err instanceof Error
            ? err.message
            : 'Impossible de terminer le test. Réessayez.'
        );
      }
    },
    [router, sessionId, supabase]
  );

  useEffect(() => {
    finishTestRef.current = finishTest;
  }, [finishTest]);

  // Initialisation : session + attempt + questions (vue sans bonne_reponse)
  useEffect(() => {
    let cancelled = false;

    async function init() {
      try {
        setLoading(true);
        setError(null);

        const {
          data: { user },
        } = await supabase.auth.getUser();
        if (!user) {
          setError('Session expirée. Reconnectez-vous.');
          return;
        }

        const { data: sessionData, error: sessionError } = await supabase
          .from('tcf_co_sessions')
          .select('id, titre, duree_minuteur, statut')
          .eq('id', sessionId)
          .maybeSingle();

        if (sessionError) throw sessionError;
        if (!sessionData || sessionData.statut !== 'publiee') {
          setError('Cette séance n’est pas disponible.');
          return;
        }
        if (cancelled) return;
        setSession(sessionData as TcfCoSession);

        const duration = Math.max(1, sessionData.duree_minuteur) * 60;
        setDurationSeconds(duration);

        const { data: questionsData, error: questionsError } = await supabase
          .from('tcf_co_questions_pour_apprenants')
          .select(
            'id, session_id, ordre, niveau, audio_url, question_texte, choix_a, choix_b, choix_c, choix_d'
          )
          .eq('session_id', sessionId)
          .order('ordre', { ascending: true });

        if (questionsError) throw questionsError;
        const list = (questionsData as SafeQuestion[]) ?? [];
        if (list.length === 0) {
          setError('Cette séance ne contient aucune question.');
          return;
        }
        if (cancelled) return;
        setQuestions(list);

        // Reprendre une tentative non terminée, sinon en créer une
        const { data: existing } = await supabase
          .from('student_co_attempts')
          .select('id, reponses, started_at, completed_at')
          .eq('session_id', sessionId)
          .eq('student_id', user.id)
          .is('completed_at', null)
          .order('started_at', { ascending: false })
          .limit(1)
          .maybeSingle();

        let attempt = existing;

        if (!attempt) {
          const startedIso = new Date().toISOString();
          const { data: created, error: insertError } = await supabase
            .from('student_co_attempts')
            .insert({
              session_id: sessionId,
              student_id: user.id,
              reponses: {},
              started_at: startedIso,
            })
            .select('id, reponses, started_at, completed_at')
            .single();
          if (insertError) throw insertError;
          attempt = created;
        }

        if (cancelled || !attempt) return;

        setAttemptId(attempt.id);
        attemptIdRef.current = attempt.id;

        const startedMs = new Date(attempt.started_at).getTime();
        setStartedAtMs(startedMs);
        startedAtMsRef.current = startedMs;

        const saved =
          (attempt.reponses as Record<string, Choice> | null) ?? {};
        setAnswers(saved);
        answersRef.current = saved;

        // Reprendre à la première question sans réponse
        const resumeIndex = list.findIndex((q) => !saved[q.id]);
        setCurrentIndex(resumeIndex === -1 ? 0 : resumeIndex);

        const elapsed = Math.floor((Date.now() - startedMs) / 1000);
        const remaining = duration - elapsed;
        if (remaining <= 0) {
          setRemainingSeconds(0);
          await finishTestRef.current?.(saved);
          return;
        }
        setRemainingSeconds(remaining);
      } catch (err) {
        console.error(err);
        if (!cancelled) {
          setError(
            err instanceof Error
              ? err.message
              : 'Impossible de démarrer la séance.'
          );
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    if (sessionId) void init();
    return () => {
      cancelled = true;
    };
  }, [sessionId, supabase]);

  // Minuteur global (indépendant de la navigation entre questions)
  useEffect(() => {
    if (!startedAtMs || !durationSeconds || finishing) return;

    const tick = () => {
      const elapsed = Math.floor((Date.now() - startedAtMs) / 1000);
      const remaining = durationSeconds - elapsed;
      setRemainingSeconds(Math.max(0, remaining));
      if (remaining <= 0) {
        void finishTestRef.current?.(answersRef.current);
      }
    };

    tick();
    const id = window.setInterval(tick, 250);
    return () => window.clearInterval(id);
  }, [startedAtMs, durationSeconds, finishing]);

  // Charger l'audio de la question courante (URL signée, jamais bonne_reponse)
  useEffect(() => {
    let cancelled = false;
    async function loadAudio() {
      if (!currentQuestion) {
        setAudioUrl('');
        return;
      }
      setAudioLoading(true);
      setSelected(answers[currentQuestion.id] ?? '');
      try {
        const path = currentQuestion.audio_url;
        if (path.startsWith('http') || path.startsWith('blob:')) {
          if (!cancelled) setAudioUrl(path);
          return;
        }
        const { data, error: signedError } = await supabase.storage
          .from(AUDIO_BUCKET)
          .createSignedUrl(path, 3600);
        if (signedError) throw signedError;
        if (!cancelled) setAudioUrl(data.signedUrl);
      } catch (err) {
        console.error(err);
        if (!cancelled) {
          setAudioUrl('');
          setError('Impossible de charger l’audio de cette question.');
        }
      } finally {
        if (!cancelled) setAudioLoading(false);
      }
    }
    void loadAudio();
    return () => {
      cancelled = true;
    };
  }, [currentQuestion, answers, supabase]);

  function persistAnswersLocally(next: Record<string, Choice>) {
    setAnswers(next);
    answersRef.current = next;
    // Sauvegarde progressive (sans correction) pour reprise / fin de minuteur
    if (attemptId) {
      void supabase
        .from('student_co_attempts')
        .update({ reponses: next })
        .eq('id', attemptId);
    }
  }

  function handleSelect(value: Choice) {
    if (!currentQuestion || finishing) return;
    setSelected(value);
    persistAnswersLocally({
      ...answersRef.current,
      [currentQuestion.id]: value,
    });
  }

  function handleNext() {
    if (!currentQuestion || !selected || finishing) return;
    const nextAnswers = {
      ...answersRef.current,
      [currentQuestion.id]: selected,
    };
    persistAnswersLocally(nextAnswers);

    if (isLastQuestion) {
      void finishTest(nextAnswers);
      return;
    }
    setCurrentIndex((i) => Math.min(i + 1, questions.length - 1));
  }

  function handlePrevious() {
    if (currentIndex <= 0 || finishing) return;
    setCurrentIndex((i) => Math.max(0, i - 1));
  }

  const timerUrgent = remainingSeconds <= 60;
  const progressLabel = `Question ${Math.min(currentIndex + 1, questions.length || 1)}/${questions.length || TOTAL_QUESTIONS}`;

  if (loading) {
    return (
      <div className="p-6 space-y-6 max-w-3xl mx-auto">
        <Skeleton className="h-8 w-64" />
        <Skeleton className="h-12 w-full" />
        <Skeleton className="h-64 w-full" />
      </div>
    );
  }

  if (error && !session) {
    return (
      <div className="p-6 space-y-4 max-w-3xl mx-auto">
        <Link
          href="/dashboard/learner/preparation"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour à Préparation
        </Link>
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {error}
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-4 max-w-3xl mx-auto">
      <div className="sticky top-0 z-10 -mx-6 px-6 py-3 bg-gray-50/95 backdrop-blur border-b border-gray-100">
        <div className="flex items-center justify-between gap-3 flex-wrap">
          <div className="min-w-0">
            <p className="text-xs text-gray-500">TCF Compréhension Orale</p>
            <h1 className="text-lg font-bold text-gray-900 truncate">
              {session?.titre ?? 'Séance'}
            </h1>
          </div>
          <div
            className={cn(
              'inline-flex items-center gap-2 rounded-lg px-3 py-2 text-sm font-semibold tabular-nums',
              timerUrgent
                ? 'bg-red-50 text-red-700 border border-red-200'
                : 'bg-flehub-green-light text-flehub-green border border-flehub-green/30'
            )}
            aria-live="polite"
          >
            <Clock className="w-4 h-4" />
            {formatCountdown(remainingSeconds)}
          </div>
        </div>
        <div className="mt-2 flex items-center justify-between gap-2 text-sm">
          <span className="font-medium text-gray-700">{progressLabel}</span>
          <span className="text-gray-500">
            {answeredCount}/{questions.length} réponses
          </span>
        </div>
        <div className="mt-2 h-1.5 rounded-full bg-gray-200 overflow-hidden">
          <div
            className="h-full bg-flehub-green transition-all"
            style={{
              width: `${questions.length ? ((currentIndex + 1) / questions.length) * 100 : 0}%`,
            }}
          />
        </div>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {error}
        </div>
      )}

      {finishing ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-16 text-center">
            <Loader2 className="w-8 h-8 animate-spin text-flehub-green mb-3" />
            <p className="text-sm text-gray-600">
              Enregistrement de vos réponses…
            </p>
          </CardContent>
        </Card>
      ) : currentQuestion ? (
        <Card>
          <CardContent className="p-6 space-y-5">
            <div className="flex items-center gap-2 text-xs text-gray-500">
              <Headphones className="w-3.5 h-3.5 text-flehub-green" />
              Écoutez l’audio, puis choisissez une réponse
            </div>

            <div className="rounded-lg border border-gray-100 bg-gray-50 p-3">
              {audioLoading ? (
                <div className="flex items-center gap-2 text-sm text-gray-500 py-2">
                  <Loader2 className="w-4 h-4 animate-spin" />
                  Chargement de l’audio…
                </div>
              ) : audioUrl ? (
                <audio
                  key={audioUrl}
                  controls
                  src={audioUrl}
                  className="w-full"
                  controlsList="nodownload"
                />
              ) : (
                <p className="text-sm text-red-600 py-2">Audio indisponible</p>
              )}
            </div>

            <div>
              <p className="text-base font-medium text-gray-900 whitespace-pre-wrap">
                {currentQuestion.question_texte}
              </p>
            </div>

            <RadioGroup
              value={selected}
              onValueChange={(v) => handleSelect(v as Choice)}
              className="space-y-2"
              disabled={finishing}
            >
              {(
                [
                  ['a', currentQuestion.choix_a],
                  ['b', currentQuestion.choix_b],
                  ['c', currentQuestion.choix_c],
                  ['d', currentQuestion.choix_d],
                ] as const
              ).map(([letter, text]) => (
                <label
                  key={letter}
                  htmlFor={`choice-${letter}`}
                  className={cn(
                    'flex items-start gap-3 rounded-lg border px-3 py-3 cursor-pointer transition-colors',
                    selected === letter
                      ? 'border-flehub-green bg-flehub-green-light'
                      : 'border-gray-200 bg-white hover:border-flehub-green/40'
                  )}
                >
                  <RadioGroupItem
                    value={letter}
                    id={`choice-${letter}`}
                    className="mt-0.5"
                    style={{ accentColor: '#00A550' }}
                  />
                  <div className="min-w-0">
                    <Label
                      htmlFor={`choice-${letter}`}
                      className="cursor-pointer font-semibold uppercase text-gray-800"
                    >
                      {letter}.
                    </Label>
                    <p className="text-sm text-gray-700 mt-0.5">{text}</p>
                  </div>
                </label>
              ))}
            </RadioGroup>

            <div className="flex items-center justify-between gap-3 pt-2">
              <Button
                type="button"
                variant="outline"
                onClick={handlePrevious}
                disabled={currentIndex === 0 || finishing}
              >
                Précédente
              </Button>

              <div className="flex items-center gap-2">
                {allAnswered && !isLastQuestion && (
                  <Button
                    type="button"
                    variant="outline"
                    className="border-flehub-green text-flehub-green hover:bg-flehub-green-light"
                    onClick={() => void finishTest(answersRef.current)}
                    disabled={finishing}
                  >
                    Terminer le test
                  </Button>
                )}
                <Button
                  type="button"
                  className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                  onClick={handleNext}
                  disabled={!selected || finishing}
                >
                  {isLastQuestion ? 'Terminer le test' : 'Question suivante'}
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      ) : null}
    </div>
  );
}
