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
  Dialog,
  DialogContent,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  AlertTriangle,
  ArrowLeft,
  BookOpenText,
  Clock,
  Loader2,
  ZoomIn,
} from 'lucide-react';
import { cn } from '@/lib/utils';

const IMAGE_BUCKET = 'tcf-ce-images';
const TOTAL_QUESTIONS = 39;

type Choice = 'a' | 'b' | 'c' | 'd';

interface TcfCeSession {
  id: string;
  titre: string;
  duree_minuteur: number;
  statut: 'brouillon' | 'publiee';
}

/** Colonnes de la vue tcf_ce_questions_pour_apprenants (sans bonne_reponse). */
interface SafeQuestion {
  id: string;
  session_id: string;
  ordre: number;
  niveau: string;
  image_url: string;
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

export default function LearnerTakeTcfCeSession() {
  const params = useParams();
  const router = useRouter();
  const sessionId = params.sessionId as string;
  const supabase = useMemo(() => createClient(), []);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [session, setSession] = useState<TcfCeSession | null>(null);
  const [questions, setQuestions] = useState<SafeQuestion[]>([]);
  const [attemptId, setAttemptId] = useState<string | null>(null);
  const [startedAtMs, setStartedAtMs] = useState<number | null>(null);
  const [durationSeconds, setDurationSeconds] = useState(0);
  const [remainingSeconds, setRemainingSeconds] = useState(0);

  const [currentIndex, setCurrentIndex] = useState(0);
  const [answers, setAnswers] = useState<Record<string, Choice>>({});
  const [visited, setVisited] = useState<Set<number>>(() => new Set([0]));
  const [selected, setSelected] = useState<Choice | ''>('');
  const [imageUrl, setImageUrl] = useState('');
  const [imageLoading, setImageLoading] = useState(false);
  const [zoomOpen, setZoomOpen] = useState(false);
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
          'correct_student_ce_attempt',
          {
            p_attempt_id: id,
            p_reponses: finalAnswers,
            p_temps_utilise_secondes: elapsed,
          }
        );

        if (rpcError) {
          const { error: updateError } = await supabase
            .from('student_ce_attempts')
            .update({
              reponses: finalAnswers,
              temps_utilise_secondes: elapsed,
              completed_at: new Date().toISOString(),
            })
            .eq('id', id);
          if (updateError) throw rpcError;
        }

        router.replace(
          `/dashboard/learner/preparation/tcf-ce/results/${id}`
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
    [router, supabase]
  );

  useEffect(() => {
    finishTestRef.current = finishTest;
  }, [finishTest]);

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
          .from('tcf_ce_sessions')
          .select('id, titre, duree_minuteur, statut')
          .eq('id', sessionId)
          .maybeSingle();

        if (sessionError) throw sessionError;
        if (!sessionData || sessionData.statut !== 'publiee') {
          setError('Cette séance n’est pas disponible.');
          return;
        }
        if (cancelled) return;
        setSession(sessionData as TcfCeSession);

        const duration = Math.max(1, sessionData.duree_minuteur) * 60;
        setDurationSeconds(duration);

        const { data: questionsData, error: questionsError } = await supabase
          .from('tcf_ce_questions_pour_apprenants')
          .select(
            'id, session_id, ordre, niveau, image_url, question_texte, choix_a, choix_b, choix_c, choix_d'
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

        const { data: existing } = await supabase
          .from('student_ce_attempts')
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
            .from('student_ce_attempts')
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

        const resumeIndex = list.findIndex((q) => !saved[q.id]);
        const startIndex = resumeIndex === -1 ? 0 : resumeIndex;
        setCurrentIndex(startIndex);
        setVisited(new Set([startIndex]));

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

  useEffect(() => {
    let cancelled = false;
    async function loadImage() {
      if (!currentQuestion) {
        setImageUrl('');
        return;
      }
      setImageLoading(true);
      setSelected(answers[currentQuestion.id] ?? '');
      setVisited((prev) => {
        if (prev.has(currentIndex)) return prev;
        const next = new Set(prev);
        next.add(currentIndex);
        return next;
      });
      try {
        const path = currentQuestion.image_url;
        if (path.startsWith('http') || path.startsWith('blob:')) {
          if (!cancelled) setImageUrl(path);
          return;
        }
        const { data, error: signedError } = await supabase.storage
          .from(IMAGE_BUCKET)
          .createSignedUrl(path, 3600);
        if (signedError) throw signedError;
        if (!cancelled) setImageUrl(data.signedUrl);
      } catch (err) {
        console.error(err);
        if (!cancelled) {
          setImageUrl('');
          setError('Impossible de charger l’image de cette question.');
        }
      } finally {
        if (!cancelled) setImageLoading(false);
      }
    }
    void loadImage();
    return () => {
      cancelled = true;
    };
  }, [currentQuestion, currentIndex, answers, supabase]);

  function persistAnswersLocally(next: Record<string, Choice>) {
    setAnswers(next);
    answersRef.current = next;
    if (attemptId) {
      void supabase
        .from('student_ce_attempts')
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

  function goToIndex(index: number) {
    if (finishing) return;
    if (index < 0 || index >= questions.length) return;
    setCurrentIndex(index);
  }

  function handleNext() {
    if (finishing) return;
    if (currentIndex >= questions.length - 1) return;
    goToIndex(currentIndex + 1);
  }

  function handlePrevious() {
    if (finishing) return;
    if (currentIndex <= 0) return;
    goToIndex(currentIndex - 1);
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
      <div className="sticky top-0 z-10 -mx-6 px-6 py-3 bg-gray-50/95 backdrop-blur border-b border-gray-100 space-y-3">
        <div className="flex items-center justify-between gap-3 flex-wrap">
          <div className="min-w-0">
            <p className="text-xs text-gray-500">TCF Compréhension Écrite</p>
            <h1 className="text-lg font-bold text-gray-900 truncate">
              {session?.titre ?? 'Séance'}
            </h1>
          </div>
          <div
            className={cn(
              'inline-flex items-center gap-2 rounded-lg px-3 py-2 text-sm font-semibold tabular-nums',
              timerUrgent
                ? 'bg-red-50 text-red-700 border border-red-200'
                : 'bg-amber-50 text-amber-800 border border-amber-200'
            )}
            aria-live="polite"
          >
            <Clock className="w-4 h-4" />
            {formatCountdown(remainingSeconds)}
          </div>
        </div>
        <div className="flex items-center justify-between gap-2 text-sm">
          <span className="font-medium text-gray-700">{progressLabel}</span>
          <span className="text-gray-500">
            {answeredCount}/{questions.length} réponses
          </span>
        </div>
        <div className="flex flex-wrap gap-1.5">
          {questions.map((q, index) => {
            const isCurrent = index === currentIndex;
            const isAnswered = Boolean(answers[q.id]);
            const wasVisited = visited.has(index);
            return (
              <button
                key={q.id}
                type="button"
                disabled={finishing}
                onClick={() => goToIndex(index)}
                className={cn(
                  'h-8 min-w-8 px-1.5 rounded-md text-xs font-semibold border transition-colors',
                  isCurrent && 'bg-amber-700 text-white border-amber-700',
                  !isCurrent &&
                    isAnswered &&
                    'bg-flehub-green-light text-flehub-green border-flehub-green/40',
                  !isCurrent &&
                    !isAnswered &&
                    wasVisited &&
                    'bg-white text-gray-700 border-amber-200 hover:border-amber-400',
                  !isCurrent &&
                    !isAnswered &&
                    !wasVisited &&
                    'bg-white text-gray-500 border-gray-200 hover:border-amber-300'
                )}
                aria-label={`Question ${index + 1}`}
              >
                {index + 1}
              </button>
            );
          })}
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
            <Loader2 className="w-8 h-8 animate-spin text-amber-700 mb-3" />
            <p className="text-sm text-gray-600">
              Enregistrement de vos réponses…
            </p>
          </CardContent>
        </Card>
      ) : currentQuestion ? (
        <Card>
          <CardContent className="p-6 space-y-5">
            <div className="flex items-center gap-2 text-xs text-gray-500">
              <BookOpenText className="w-3.5 h-3.5 text-amber-700" />
              Lisez le texte, puis choisissez une réponse — vous pouvez revenir
              en arrière à tout moment
            </div>

            <div className="rounded-lg border border-gray-100 bg-gray-50 p-3 space-y-2">
              {imageLoading ? (
                <div className="flex items-center gap-2 text-sm text-gray-500 py-8 justify-center">
                  <Loader2 className="w-4 h-4 animate-spin" />
                  Chargement de l’image…
                </div>
              ) : imageUrl ? (
                <>
                  <button
                    type="button"
                    onClick={() => setZoomOpen(true)}
                    className="block w-full group relative"
                  >
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      key={imageUrl}
                      src={imageUrl}
                      alt="Texte à lire"
                      className="w-full max-h-[420px] object-contain rounded-md bg-white border border-gray-100"
                    />
                    <span className="absolute bottom-2 right-2 inline-flex items-center gap-1 rounded-md bg-black/60 text-white text-xs px-2 py-1 opacity-90 group-hover:opacity-100">
                      <ZoomIn className="w-3.5 h-3.5" />
                      Agrandir
                    </span>
                  </button>
                </>
              ) : (
                <p className="text-sm text-red-600 py-2">Image indisponible</p>
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
                  htmlFor={`ce-choice-${letter}`}
                  className={cn(
                    'flex items-start gap-3 rounded-lg border px-3 py-3 cursor-pointer transition-colors',
                    selected === letter
                      ? 'border-flehub-green bg-flehub-green-light'
                      : 'border-gray-200 bg-white hover:border-flehub-green/40'
                  )}
                >
                  <RadioGroupItem
                    value={letter}
                    id={`ce-choice-${letter}`}
                    className="mt-0.5"
                    style={{ accentColor: '#00A550' }}
                  />
                  <div className="min-w-0">
                    <Label
                      htmlFor={`ce-choice-${letter}`}
                      className="cursor-pointer font-semibold uppercase text-gray-800"
                    >
                      {letter}.
                    </Label>
                    <p className="text-sm text-gray-700 mt-0.5">{text}</p>
                  </div>
                </label>
              ))}
            </RadioGroup>

            <div className="flex items-center justify-between gap-3 pt-2 flex-wrap">
              <Button
                type="button"
                variant="outline"
                onClick={handlePrevious}
                disabled={currentIndex === 0 || finishing}
              >
                Question précédente
              </Button>

              <div className="flex items-center gap-2">
                <Button
                  type="button"
                  variant={allAnswered ? 'default' : 'outline'}
                  className={
                    allAnswered
                      ? 'bg-flehub-green hover:bg-flehub-green/90 text-white'
                      : 'border-amber-300 text-amber-800 hover:bg-amber-50'
                  }
                  onClick={() => void finishTest(answersRef.current)}
                  disabled={finishing}
                >
                  Terminer le test
                </Button>
                <Button
                  type="button"
                  className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                  onClick={handleNext}
                  disabled={
                    currentIndex >= questions.length - 1 || finishing
                  }
                >
                  Question suivante
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      ) : null}

      <Dialog open={zoomOpen} onOpenChange={setZoomOpen}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-auto p-3">
          <DialogTitle className="sr-only">Aperçu agrandi du texte</DialogTitle>
          {imageUrl && (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={imageUrl}
              alt="Texte à lire (agrandi)"
              className="w-full h-auto object-contain"
            />
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
