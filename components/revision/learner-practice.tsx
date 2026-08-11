'use client';

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Label } from '@/components/ui/label';
import { Skeleton } from '@/components/ui/skeleton';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import {
  AlertTriangle,
  ArrowLeft,
  CheckCircle2,
  Loader2,
  RotateCcw,
  Trophy,
  XCircle,
} from 'lucide-react';
import { cn } from '@/lib/utils';

const TOTAL_QUESTIONS = 10;

type Choice = 'a' | 'b' | 'c' | 'd';

interface SafeQuestion {
  id: string;
  point_id: string;
  ordre: number;
  niveau: string;
  question_texte: string;
  choix_a: string;
  choix_b: string;
  choix_c: string;
  choix_d: string;
}

interface QuestionResult {
  question_id: string;
  ordre: number;
  niveau: string;
  question_texte: string;
  choix_a: string;
  choix_b: string;
  choix_c: string;
  choix_d: string;
  reponse_donnee: string | null;
  bonne_reponse: Choice;
  correct: boolean;
}

interface AttemptResults {
  attempt_id: string;
  point_id: string;
  score: number;
  total: number;
  details: QuestionResult[];
}

function choiceText(q: SafeQuestion | QuestionResult, letter: Choice): string {
  const map: Record<Choice, string> = {
    a: q.choix_a,
    b: q.choix_b,
    c: q.choix_c,
    d: q.choix_d,
  };
  return map[letter];
}

function choiceLabel(
  q: QuestionResult,
  letter: string | null | undefined
): string {
  if (!letter) return 'Aucune réponse';
  const key = letter.toLowerCase() as Choice;
  if (!['a', 'b', 'c', 'd'].includes(key)) return letter.toUpperCase();
  return `${key.toUpperCase()}. ${choiceText(q, key)}`;
}

export default function LearnerRevisionPractice() {
  const params = useParams();
  const pointId = params.pointId as string;
  const supabase = useMemo(() => createClient(), []);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [pointTitre, setPointTitre] = useState('');
  const [questions, setQuestions] = useState<SafeQuestion[]>([]);
  const [attemptId, setAttemptId] = useState<string | null>(null);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [answers, setAnswers] = useState<Record<string, Choice>>({});
  const [selected, setSelected] = useState<Choice | ''>('');
  const [finishing, setFinishing] = useState(false);
  const [results, setResults] = useState<AttemptResults | null>(null);

  const answersRef = useRef(answers);
  const finishingRef = useRef(false);

  useEffect(() => {
    answersRef.current = answers;
  }, [answers]);

  const currentQuestion = questions[currentIndex] ?? null;
  const answeredCount = Object.keys(answers).length;
  const allAnswered =
    questions.length > 0 && answeredCount >= questions.length;
  const isLastQuestion =
    questions.length > 0 && currentIndex >= questions.length - 1;

  const startAttempt = useCallback(async () => {
    setLoading(true);
    setError(null);
    setResults(null);
    setAnswers({});
    setSelected('');
    setCurrentIndex(0);
    finishingRef.current = false;

    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error('Session expirée. Reconnectez-vous.');

      const { data: pointData, error: pointError } = await supabase
        .from('revision_points')
        .select('id, titre, numero')
        .eq('id', pointId)
        .maybeSingle();
      if (pointError) throw pointError;
      if (!pointData) throw new Error('Point de révision introuvable.');

      setPointTitre(`${pointData.numero}. ${pointData.titre}`);

      const { data: questionsData, error: questionsError } = await supabase
        .from('revision_questions_pour_apprenants')
        .select(
          'id, point_id, ordre, niveau, question_texte, choix_a, choix_b, choix_c, choix_d'
        )
        .eq('point_id', pointId)
        .order('ordre', { ascending: true });
      if (questionsError) throw questionsError;

      const list = (questionsData as SafeQuestion[]) ?? [];
      if (list.length !== TOTAL_QUESTIONS) {
        throw new Error(
          'Ce questionnaire n’est pas encore disponible (10 questions requises).'
        );
      }
      setQuestions(list);

      const { data: openAttempt } = await supabase
        .from('student_revision_attempts')
        .select('id, reponses')
        .eq('point_id', pointId)
        .eq('student_id', user.id)
        .is('completed_at', null)
        .order('started_at', { ascending: false })
        .limit(1)
        .maybeSingle();

      if (openAttempt) {
        setAttemptId(openAttempt.id as string);
        const saved = (openAttempt.reponses ?? {}) as Record<string, Choice>;
        setAnswers(saved);
        const firstUnanswered = list.findIndex((q) => !saved[q.id]);
        const idx = firstUnanswered === -1 ? list.length - 1 : firstUnanswered;
        setCurrentIndex(idx);
        setSelected(saved[list[idx]?.id] ?? '');
      } else {
        const { data: created, error: createError } = await supabase
          .from('student_revision_attempts')
          .insert({
            point_id: pointId,
            student_id: user.id,
            reponses: {},
          })
          .select('id')
          .single();
        if (createError) throw createError;
        setAttemptId(created.id as string);
      }
    } catch (err) {
      console.error(err);
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible de démarrer l’entraînement.'
      );
    } finally {
      setLoading(false);
    }
  }, [pointId, supabase]);

  useEffect(() => {
    if (pointId) void startAttempt();
  }, [pointId, startAttempt]);

  async function persistAnswers(next: Record<string, Choice>) {
    if (!attemptId) return;
    const { error: updateError } = await supabase
      .from('student_revision_attempts')
      .update({ reponses: next })
      .eq('id', attemptId);
    if (updateError) throw updateError;
  }

  async function selectAnswer(choice: Choice) {
    if (!currentQuestion || finishing || results) return;
    setSelected(choice);
    const next = { ...answersRef.current, [currentQuestion.id]: choice };
    setAnswers(next);
    try {
      await persistAnswers(next);
    } catch (err) {
      console.error(err);
      setError('Impossible d’enregistrer la réponse.');
    }
  }

  async function finishQuiz(finalAnswers: Record<string, Choice>) {
    if (finishingRef.current || !attemptId) return;
    finishingRef.current = true;
    setFinishing(true);
    setError(null);

    try {
      const { data, error: rpcError } = await supabase.rpc(
        'correct_student_revision_attempt',
        {
          p_attempt_id: attemptId,
          p_reponses: finalAnswers,
        }
      );
      if (rpcError) throw rpcError;
      setResults(data as AttemptResults);
    } catch (err) {
      console.error(err);
      finishingRef.current = false;
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible de corriger la tentative.'
      );
    } finally {
      setFinishing(false);
    }
  }

  function goNext() {
    if (!currentQuestion) return;
    if (isLastQuestion) {
      if (allAnswered) void finishQuiz(answersRef.current);
      return;
    }
    const nextIndex = currentIndex + 1;
    setCurrentIndex(nextIndex);
    setSelected(answers[questions[nextIndex]?.id] ?? '');
  }

  function goPrev() {
    if (currentIndex <= 0) return;
    const prevIndex = currentIndex - 1;
    setCurrentIndex(prevIndex);
    setSelected(answers[questions[prevIndex]?.id] ?? '');
  }

  if (results) {
    const wrong = results.details.filter((d) => !d.correct);
    return (
      <div className="p-6 space-y-6 max-w-3xl mx-auto">
        <Link
          href="/dashboard/learner/preparation/revision"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour à Révision
        </Link>

        <div>
          <h1 className="text-2xl font-bold text-gray-900">Correction</h1>
          <p className="text-sm text-gray-500 mt-1">{pointTitre}</p>
        </div>

        <Card>
          <CardContent className="p-6 flex flex-col sm:flex-row sm:items-center gap-4">
            <div className="p-3 rounded-lg bg-flehub-green-light">
              <Trophy className="w-6 h-6 text-flehub-green" />
            </div>
            <div className="flex-1">
              <p className="text-sm text-gray-500">Score</p>
              <p className="text-3xl font-bold text-gray-900">
                {results.score}/{results.total || TOTAL_QUESTIONS}
              </p>
            </div>
            <Button
              type="button"
              variant="outline"
              onClick={() => void startAttempt()}
            >
              <RotateCcw className="w-4 h-4 mr-1.5" />
              Recommencer
            </Button>
          </CardContent>
        </Card>

        {wrong.length === 0 ? (
          <div className="flex items-center gap-2 rounded-lg bg-flehub-green-light border border-flehub-green/30 px-4 py-3 text-sm text-flehub-green">
            <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
            Bravo — toutes les réponses sont correctes.
          </div>
        ) : (
          <div className="space-y-3">
            <h2 className="text-lg font-semibold text-gray-900">
              Corrigé des réponses fausses
            </h2>
            {wrong.map((q) => (
              <Card key={q.question_id}>
                <CardContent className="p-5 space-y-3">
                  <div className="flex items-center gap-2 flex-wrap">
                    <Badge variant="outline">Q{q.ordre}</Badge>
                    <Badge variant="outline">{q.niveau}</Badge>
                    <XCircle className="w-4 h-4 text-red-500" />
                  </div>
                  <p className="text-sm font-medium text-gray-900">
                    {q.question_texte}
                  </p>
                  <div className="space-y-1 text-sm">
                    <p className="text-red-700">
                      Votre réponse : {choiceLabel(q, q.reponse_donnee)}
                    </p>
                    <p className="text-flehub-green">
                      Bonne réponse : {choiceLabel(q, q.bonne_reponse)}
                    </p>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}

        <details className="rounded-lg border border-gray-200 p-4">
          <summary className="cursor-pointer text-sm font-medium text-gray-700">
            Voir toutes les questions
          </summary>
          <div className="mt-4 space-y-3">
            {results.details.map((q) => (
              <div
                key={q.question_id}
                className={cn(
                  'rounded-lg border px-3 py-3 text-sm',
                  q.correct
                    ? 'border-flehub-green/30 bg-flehub-green-light/40'
                    : 'border-red-200 bg-red-50/50'
                )}
              >
                <div className="flex items-center gap-2 mb-1">
                  <span className="font-semibold">Q{q.ordre}</span>
                  {q.correct ? (
                    <CheckCircle2 className="w-4 h-4 text-flehub-green" />
                  ) : (
                    <XCircle className="w-4 h-4 text-red-500" />
                  )}
                </div>
                <p className="text-gray-800">{q.question_texte}</p>
                <p className="text-xs text-gray-500 mt-1">
                  Vous : {choiceLabel(q, q.reponse_donnee)} · Correct :{' '}
                  {choiceLabel(q, q.bonne_reponse)}
                </p>
              </div>
            ))}
          </div>
        </details>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6 max-w-3xl mx-auto">
      <Link
        href="/dashboard/learner/preparation/revision"
        className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green"
      >
        <ArrowLeft className="w-4 h-4" />
        Retour à Révision
      </Link>

      <div className="flex items-start justify-between gap-3 flex-wrap">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Entraînement</h1>
          <p className="text-sm text-gray-500 mt-1">
            {pointTitre || 'Révision'}
          </p>
        </div>
        {!loading && questions.length > 0 && (
          <div className="rounded-lg bg-flehub-green-light px-3 py-1.5 text-sm font-semibold text-flehub-green">
            Question {currentIndex + 1}/{questions.length}
          </div>
        )}
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {error}
        </div>
      )}

      {loading ? (
        <div className="space-y-3">
          <Skeleton className="h-8 w-48" />
          <Skeleton className="h-40 rounded-xl" />
        </div>
      ) : currentQuestion ? (
        <>
          <div className="h-2 rounded-full bg-gray-100 overflow-hidden">
            <div
              className="h-full bg-flehub-green transition-all"
              style={{
                width: `${Math.round(
                  (answeredCount / Math.max(questions.length, 1)) * 100
                )}%`,
              }}
            />
          </div>

          <Card>
            <CardContent className="p-6 space-y-5">
              <div className="flex items-center gap-2">
                <Badge variant="outline">{currentQuestion.niveau}</Badge>
                <span className="text-xs text-gray-500">
                  {answeredCount}/{questions.length} répondues
                </span>
              </div>
              <p className="text-base font-medium text-gray-900">
                {currentQuestion.question_texte}
              </p>

              <RadioGroup
                value={selected}
                onValueChange={(v) => void selectAnswer(v as Choice)}
                className="space-y-3"
              >
                {(['a', 'b', 'c', 'd'] as const).map((letter) => (
                  <label
                    key={letter}
                    htmlFor={`choice-${letter}`}
                    className={cn(
                      'flex items-start gap-3 rounded-lg border px-4 py-3 cursor-pointer transition-colors',
                      selected === letter
                        ? 'border-flehub-green bg-flehub-green-light/50'
                        : 'border-gray-200 hover:border-gray-300'
                    )}
                  >
                    <RadioGroupItem
                      value={letter}
                      id={`choice-${letter}`}
                      className="mt-0.5"
                    />
                    <div>
                      <Label
                        htmlFor={`choice-${letter}`}
                        className="font-semibold cursor-pointer"
                      >
                        {letter.toUpperCase()}
                      </Label>
                      <p className="text-sm text-gray-700 mt-0.5">
                        {choiceText(currentQuestion, letter)}
                      </p>
                    </div>
                  </label>
                ))}
              </RadioGroup>
            </CardContent>
          </Card>

          <div className="flex items-center justify-between gap-2">
            <Button
              type="button"
              variant="outline"
              onClick={goPrev}
              disabled={currentIndex === 0 || finishing}
            >
              Précédent
            </Button>
            <Button
              type="button"
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              onClick={goNext}
              disabled={
                finishing ||
                !selected ||
                (isLastQuestion && !allAnswered)
              }
            >
              {finishing && (
                <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
              )}
              {isLastQuestion ? 'Terminer' : 'Suivant'}
            </Button>
          </div>
        </>
      ) : null}
    </div>
  );
}
