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
  Clock,
  Hourglass,
  Mic,
  Trophy,
} from 'lucide-react';

const SCORE_TOTAL_MAX = 60;

const CRITERIA = [
  {
    key: 'score_interaction',
    label: 'Interaction / spontanéité',
  },
  {
    key: 'score_fluidite',
    label: 'Aisance et fluidité',
  },
  {
    key: 'score_structure',
    label: 'Structuration du discours',
  },
  {
    key: 'score_vocabulaire',
    label: 'Richesse du vocabulaire',
  },
  {
    key: 'score_grammaire',
    label: 'Correction grammaticale',
  },
  {
    key: 'score_prononciation',
    label: 'Prononciation',
  },
] as const;

type ScoreKey = (typeof CRITERIA)[number]['key'];

interface ResultsView {
  sessionTitre: string;
  evaluatedAt: string;
  scores: Record<ScoreKey, number | null>;
  commentaireGeneral: string | null;
  scoreTotal: number;
  pourcentage: number;
}

function formatDate(iso: string | null): string {
  if (!iso) return '—';
  try {
    return new Date(iso).toLocaleString('fr-FR', {
      dateStyle: 'medium',
      timeStyle: 'short',
    });
  } catch {
    return iso;
  }
}

export default function LearnerTcfEoResults() {
  const params = useParams();
  const evaluationId = params.evaluationId as string;
  const supabase = useMemo(() => createClient(), []);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [pending, setPending] = useState(false);
  const [results, setResults] = useState<ResultsView | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      try {
        setLoading(true);
        setError(null);
        setPending(false);
        setResults(null);

        const {
          data: { user },
        } = await supabase.auth.getUser();
        if (!user) {
          setError('Session expirée. Reconnectez-vous.');
          return;
        }

        const { data: evaluation, error: evaluationError } = await supabase
          .from('student_eo_evaluations')
          .select(
            `
            id,
            session_id,
            student_id,
            evaluated_at,
            commentaire_general,
            score_interaction,
            score_fluidite,
            score_structure,
            score_vocabulaire,
            score_grammaire,
            score_prononciation
          `
          )
          .eq('id', evaluationId)
          .maybeSingle();

        if (evaluationError) throw evaluationError;

        if (
          !evaluation ||
          evaluation.student_id !== user.id ||
          !evaluation.evaluated_at
        ) {
          if (!cancelled) setPending(true);
          return;
        }

        const { data: session, error: sessionError } = await supabase
          .from('tcf_eo_sessions')
          .select('id, titre')
          .eq('id', evaluation.session_id)
          .maybeSingle();
        if (sessionError) throw sessionError;

        const scores: Record<ScoreKey, number | null> = {
          score_interaction: evaluation.score_interaction,
          score_fluidite: evaluation.score_fluidite,
          score_structure: evaluation.score_structure,
          score_vocabulaire: evaluation.score_vocabulaire,
          score_grammaire: evaluation.score_grammaire,
          score_prononciation: evaluation.score_prononciation,
        };

        const scoreTotal = CRITERIA.reduce(
          (sum, c) => sum + (typeof scores[c.key] === 'number' ? scores[c.key]! : 0),
          0
        );

        if (!cancelled) {
          setResults({
            sessionTitre: session?.titre ?? 'Séance TCF EO',
            evaluatedAt: evaluation.evaluated_at,
            scores,
            commentaireGeneral: evaluation.commentaire_general,
            scoreTotal,
            pourcentage: Math.round((scoreTotal / SCORE_TOTAL_MAX) * 100),
          });
        }
      } catch (err) {
        console.error(err);
        if (!cancelled) {
          setError(
            err instanceof Error
              ? err.message
              : 'Impossible de charger l’évaluation.'
          );
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    if (evaluationId) void load();
    return () => {
      cancelled = true;
    };
  }, [evaluationId, supabase]);

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
        <div className="flex items-center gap-2 flex-wrap">
          <h1 className="text-2xl font-bold text-gray-900">
            Résultats TCF EO
          </h1>
          <Badge
            variant="outline"
            className="bg-violet-100 text-violet-800 border-violet-200"
          >
            EO
          </Badge>
        </div>
        <p className="text-sm text-gray-500 mt-1">
          Évaluation de votre passage d’expression orale
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
          <Skeleton className="h-48 w-full rounded-xl" />
          <Skeleton className="h-24 w-full rounded-xl" />
        </div>
      ) : pending ? (
        <Card className="border-dashed">
          <CardContent className="flex flex-col items-center justify-center py-16 text-center space-y-3">
            <div className="p-3 rounded-lg bg-violet-50">
              <Hourglass className="w-6 h-6 text-violet-700" />
            </div>
            <h2 className="text-lg font-semibold text-gray-900">
              Votre évaluation n’est pas encore disponible
            </h2>
            <p className="text-sm text-gray-500 max-w-sm">
              Votre formateur n’a pas encore publié la notation de votre
              passage oral. Revenez plus tard pour consulter vos scores.
            </p>
            <Button
              asChild
              className="mt-2 bg-flehub-green hover:bg-flehub-green/90 text-white"
            >
              <Link href="/dashboard/learner/preparation">
                Retour à Préparation
              </Link>
            </Button>
          </CardContent>
        </Card>
      ) : results ? (
        <>
          <Card>
            <CardContent className="p-6 space-y-5">
              <div className="flex flex-col sm:flex-row sm:items-center gap-4 justify-between">
                <div className="flex items-center gap-3">
                  <div className="p-3 rounded-lg bg-violet-50">
                    <Trophy className="w-6 h-6 text-violet-700" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Score total</p>
                    <p className="text-2xl font-bold text-gray-900">
                      {results.scoreTotal}/{SCORE_TOTAL_MAX}{' '}
                      <span className="text-base font-semibold text-flehub-green">
                        ({results.pourcentage}%)
                      </span>
                    </p>
                  </div>
                </div>
                <Badge
                  variant="outline"
                  className="bg-white text-gray-700 border-gray-200 gap-1.5 w-fit"
                >
                  <Clock className="w-3.5 h-3.5" />
                  Évaluée le {formatDate(results.evaluatedAt)}
                </Badge>
              </div>
              <div>
                <p className="text-xs text-gray-500">Séance</p>
                <p className="font-semibold text-gray-900">
                  {results.sessionTitre}
                </p>
              </div>
            </CardContent>
          </Card>

          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-900">
                Détail des critères
              </h2>
              <span className="text-sm text-gray-500">6 critères</span>
            </div>

            <ul className="space-y-3">
              {CRITERIA.map((criterion) => {
                const score = results.scores[criterion.key];
                return (
                  <li key={criterion.key}>
                    <Card className="border border-violet-100">
                      <CardContent className="p-4 flex items-center justify-between gap-3">
                        <div className="flex items-center gap-3 min-w-0">
                          <div className="p-2 rounded-lg bg-violet-50 shrink-0">
                            <Mic className="w-4 h-4 text-violet-700" />
                          </div>
                          <p className="text-sm font-medium text-gray-900">
                            {criterion.label}
                          </p>
                        </div>
                        <p className="text-lg font-bold text-gray-900 tabular-nums shrink-0">
                          {score ?? '—'}/10
                        </p>
                      </CardContent>
                    </Card>
                  </li>
                );
              })}
            </ul>
          </div>

          <Card>
            <CardContent className="p-6 space-y-2">
              <p className="text-xs font-medium text-gray-500">
                Commentaire général
              </p>
              <p className="text-sm text-gray-800 whitespace-pre-wrap leading-relaxed">
                {results.commentaireGeneral?.trim()
                  ? results.commentaireGeneral
                  : 'Aucun commentaire.'}
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6 flex flex-col sm:flex-row sm:items-center gap-4 justify-between">
              <div className="flex items-center gap-3">
                <div className="p-2 rounded-lg bg-violet-50">
                  <Trophy className="w-4 h-4 text-violet-700" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Résumé global</p>
                  <p className="text-lg font-bold text-gray-900">
                    {results.scoreTotal}/{SCORE_TOTAL_MAX}{' '}
                    <span className="text-sm font-semibold text-flehub-green">
                      ({results.pourcentage}%)
                    </span>
                  </p>
                </div>
              </div>
              <Button
                asChild
                className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              >
                <Link href="/dashboard/learner/preparation">
                  Retour à Préparation
                </Link>
              </Button>
            </CardContent>
          </Card>
        </>
      ) : null}
    </div>
  );
}
