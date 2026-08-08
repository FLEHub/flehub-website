'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  AlertTriangle,
  ArrowLeft,
  CheckCircle2,
  Clock,
  RotateCcw,
  Trophy,
  XCircle,
} from 'lucide-react';
import { cn } from '@/lib/utils';

type Choice = 'a' | 'b' | 'c' | 'd';

interface QuestionResult {
  question_id: string;
  ordre: number;
  niveau: string | null;
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
  session_id: string;
  score: number;
  total: number;
  pourcentage: number;
  niveau_obtenu: string | null;
  temps_utilise_secondes: number | null;
  completed_at: string | null;
  questions: QuestionResult[];
}

function formatMmSs(totalSeconds: number | null | undefined): string {
  if (totalSeconds == null || !Number.isFinite(totalSeconds)) return '—';
  const safe = Math.max(0, Math.floor(totalSeconds));
  const m = Math.floor(safe / 60);
  const s = safe % 60;
  return `${m}:${String(s).padStart(2, '0')}`;
}

function choiceLabel(
  q: QuestionResult,
  letter: string | null | undefined
): string {
  if (!letter) return 'Aucune réponse';
  const key = letter.toLowerCase() as Choice;
  const map: Record<Choice, string> = {
    a: q.choix_a,
    b: q.choix_b,
    c: q.choix_c,
    d: q.choix_d,
  };
  const text = map[key];
  if (!text) return letter.toUpperCase();
  return `${letter.toUpperCase()}. ${text}`;
}

export default function LearnerTcfCoResults() {
  const params = useParams();
  const sessionIdParam = params.sessionId as string | undefined;
  const attemptId = params.attemptId as string;
  const supabase = useMemo(() => createClient(), []);

  const [results, setResults] = useState<AttemptResults | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      try {
        setLoading(true);
        setError(null);

        const { data, error: rpcError } = await supabase.rpc(
          'get_student_co_attempt_results',
          { p_attempt_id: attemptId }
        );

        if (rpcError) throw rpcError;
        if (!data) throw new Error('Résultats introuvables.');

        const parsed = data as AttemptResults;
        if (!cancelled) setResults(parsed);
      } catch (err) {
        console.error(err);
        if (!cancelled) {
          setError(
            err instanceof Error
              ? err.message
              : 'Impossible de charger les résultats.'
          );
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    if (attemptId) void load();
    return () => {
      cancelled = true;
    };
  }, [attemptId, supabase]);

  const sessionId = results?.session_id ?? sessionIdParam ?? '';
  const total = results?.total || 40;
  const score = results?.score ?? 0;
  const percent =
    results?.pourcentage ??
    (total > 0 ? Math.round((score / total) * 100) : 0);

  return (
    <div className="p-6 space-y-6 max-w-3xl mx-auto">
      <Link
        href="/dashboard/learner/preparation"
        className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green"
      >
        <ArrowLeft className="w-4 h-4" />
        Retour à Préparation
      </Link>

      <div>
        <h1 className="text-2xl font-bold text-gray-900">Résultats TCF CO</h1>
        <p className="text-sm text-gray-500 mt-1">
          Correction détaillée de votre tentative
        </p>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {error}
        </div>
      )}

      {loading ? (
        <div className="space-y-4">
          <Skeleton className="h-36 w-full rounded-xl" />
          <Skeleton className="h-24 w-full rounded-xl" />
          <Skeleton className="h-24 w-full rounded-xl" />
        </div>
      ) : results ? (
        <>
          <Card>
            <CardContent className="p-6 space-y-5">
              <div className="flex flex-col sm:flex-row sm:items-center gap-4 justify-between">
                <div className="flex items-center gap-3">
                  <div className="p-3 rounded-lg bg-flehub-green-light">
                    <Trophy className="w-6 h-6 text-flehub-green" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Score final</p>
                    <p className="text-2xl font-bold text-gray-900">
                      {score}/{total}{' '}
                      <span className="text-base font-semibold text-flehub-green">
                        ({percent}%)
                      </span>
                    </p>
                  </div>
                </div>
                <div className="flex flex-wrap gap-2">
                  <Badge
                    variant="outline"
                    className="bg-white text-gray-700 border-gray-200 gap-1.5"
                  >
                    <Clock className="w-3.5 h-3.5" />
                    Temps : {formatMmSs(results.temps_utilise_secondes)}
                  </Badge>
                  {results.niveau_obtenu && (
                    <Badge className="bg-flehub-green-light text-flehub-green border-flehub-green">
                      Niveau {results.niveau_obtenu}
                    </Badge>
                  )}
                </div>
              </div>

              <Button
                asChild
                className="w-full sm:w-auto bg-flehub-green hover:bg-flehub-green/90 text-white"
              >
                <Link
                  href={`/dashboard/learner/preparation/tcf-co/${sessionId}`}
                >
                  <RotateCcw className="w-4 h-4 mr-1.5" />
                  Recommencer une nouvelle tentative
                </Link>
              </Button>
            </CardContent>
          </Card>

          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-900">
                Détail des questions
              </h2>
              <span className="text-sm text-gray-500">
                {results.questions.length} question
                {results.questions.length === 1 ? '' : 's'}
              </span>
            </div>

            <ul className="space-y-3">
              {results.questions.map((q) => (
                <li key={q.question_id}>
                  <Card
                    className={cn(
                      'border',
                      q.correct
                        ? 'border-flehub-green/40 bg-flehub-green-light/20'
                        : 'border-red-200 bg-red-50/40'
                    )}
                  >
                    <CardContent className="p-4 space-y-3">
                      <div className="flex items-start justify-between gap-3">
                        <div className="flex items-start gap-2 min-w-0">
                          <span className="inline-flex h-7 w-7 shrink-0 items-center justify-center rounded-md bg-white border border-gray-200 text-xs font-semibold text-gray-700">
                            {q.ordre}
                          </span>
                          <div className="min-w-0">
                            <p className="text-sm font-medium text-gray-900 whitespace-pre-wrap">
                              {q.question_texte}
                            </p>
                            {q.niveau && (
                              <Badge
                                variant="outline"
                                className="mt-1.5 text-xs"
                              >
                                {q.niveau}
                              </Badge>
                            )}
                          </div>
                        </div>
                        {q.correct ? (
                          <CheckCircle2 className="w-5 h-5 text-flehub-green shrink-0" />
                        ) : (
                          <XCircle className="w-5 h-5 text-red-500 shrink-0" />
                        )}
                      </div>

                      <div className="grid gap-2 sm:grid-cols-2 text-sm">
                        <div
                          className={cn(
                            'rounded-lg border px-3 py-2',
                            q.correct
                              ? 'border-flehub-green/30 bg-white'
                              : 'border-red-200 bg-white'
                          )}
                        >
                          <p className="text-xs text-gray-500 mb-0.5">
                            Votre réponse
                          </p>
                          <p
                            className={cn(
                              'font-medium',
                              q.correct ? 'text-flehub-green' : 'text-red-600'
                            )}
                          >
                            {choiceLabel(q, q.reponse_donnee)}
                          </p>
                        </div>
                        <div className="rounded-lg border border-gray-200 bg-white px-3 py-2">
                          <p className="text-xs text-gray-500 mb-0.5">
                            Bonne réponse
                          </p>
                          <p className="font-medium text-gray-900">
                            {choiceLabel(q, q.bonne_reponse)}
                          </p>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                </li>
              ))}
            </ul>
          </div>

          <div className="flex justify-center pt-2">
            <Button
              asChild
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
            >
              <Link href={`/dashboard/learner/preparation/tcf-co/${sessionId}`}>
                <RotateCcw className="w-4 h-4 mr-1.5" />
                Recommencer une nouvelle tentative
              </Link>
            </Button>
          </div>
        </>
      ) : null}
    </div>
  );
}
