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
  PenLine,
  Trophy,
} from 'lucide-react';
import { cn } from '@/lib/utils';

const SCORE_TOTAL_MAX = 60;

interface TaskResult {
  tacheId: string;
  numero: number;
  consigne: string;
  motsMin: number;
  motsMax: number;
  texte: string;
  nombreMots: number;
  scoreFond: number | null;
  commentaireFond: string | null;
  scoreForme: number | null;
  commentaireForme: string | null;
  correctedAt: string | null;
}

interface ResultsView {
  sessionTitre: string;
  correctedAt: string | null;
  tasks: TaskResult[];
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

function countWords(text: string): number {
  const trimmed = text.trim();
  if (!trimmed) return 0;
  return trimmed.split(/\s+/).filter(Boolean).length;
}

export default function LearnerTcfEeResults() {
  const params = useParams();
  const attemptId = params.attemptId as string;
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

        const { data: attempt, error: attemptError } = await supabase
          .from('student_ee_attempts')
          .select('id, session_id, student_id, statut, completed_at')
          .eq('id', attemptId)
          .maybeSingle();

        if (attemptError) throw attemptError;

        if (!attempt || attempt.student_id !== user.id) {
          if (!cancelled) setPending(true);
          return;
        }

        if (attempt.statut !== 'corrige') {
          if (!cancelled) setPending(true);
          return;
        }

        const { data: session, error: sessionError } = await supabase
          .from('tcf_ee_sessions')
          .select('id, titre')
          .eq('id', attempt.session_id)
          .maybeSingle();
        if (sessionError) throw sessionError;

        const { data: taches, error: tachesError } = await supabase
          .from('tcf_ee_taches')
          .select('id, numero, consigne, mots_min, mots_max')
          .eq('session_id', attempt.session_id)
          .order('numero', { ascending: true });
        if (tachesError) throw tachesError;

        const { data: reponses, error: reponsesError } = await supabase
          .from('student_ee_reponses')
          .select('tache_id, texte, nombre_mots')
          .eq('attempt_id', attemptId);
        if (reponsesError) throw reponsesError;

        const { data: corrections, error: correctionsError } = await supabase
          .from('ee_corrections')
          .select(
            'tache_id, score_fond, commentaire_fond, score_forme, commentaire_forme, corrected_at'
          )
          .eq('attempt_id', attemptId);
        if (correctionsError) throw correctionsError;

        // Les apprenants ne voient que les corrections publiées (corrected_at rempli)
        const published = (corrections ?? []).filter((c) => c.corrected_at);
        if (published.length === 0) {
          if (!cancelled) setPending(true);
          return;
        }

        const reponseByTache = new Map(
          (reponses ?? []).map((r) => [r.tache_id, r])
        );
        const correctionByTache = new Map(
          published.map((c) => [c.tache_id, c])
        );

        const tasks: TaskResult[] = (taches ?? []).map((t) => {
          const reponse = reponseByTache.get(t.id);
          const correction = correctionByTache.get(t.id);
          const texte = reponse?.texte ?? '';
          const nombreMots =
            typeof reponse?.nombre_mots === 'number'
              ? reponse.nombre_mots
              : countWords(texte);
          return {
            tacheId: t.id,
            numero: t.numero,
            consigne: t.consigne,
            motsMin: t.mots_min,
            motsMax: t.mots_max,
            texte,
            nombreMots,
            scoreFond: correction?.score_fond ?? null,
            commentaireFond: correction?.commentaire_fond ?? null,
            scoreForme: correction?.score_forme ?? null,
            commentaireForme: correction?.commentaire_forme ?? null,
            correctedAt: correction?.corrected_at ?? null,
          };
        });

        let scoreTotal = 0;
        let correctedAt: string | null = null;
        for (const task of tasks) {
          if (typeof task.scoreFond === 'number') scoreTotal += task.scoreFond;
          if (typeof task.scoreForme === 'number') scoreTotal += task.scoreForme;
          if (
            task.correctedAt &&
            (!correctedAt ||
              new Date(task.correctedAt).getTime() >
                new Date(correctedAt).getTime())
          ) {
            correctedAt = task.correctedAt;
          }
        }

        if (!cancelled) {
          setResults({
            sessionTitre: session?.titre ?? 'Séance TCF EE',
            correctedAt,
            tasks,
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
              : 'Impossible de charger la correction.'
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
            Correction TCF EE
          </h1>
          <Badge
            variant="outline"
            className="bg-blue-100 text-blue-800 border-blue-200"
          >
            EE
          </Badge>
        </div>
        <p className="text-sm text-gray-500 mt-1">
          Retour détaillé sur votre expression écrite
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
          <Skeleton className="h-40 w-full rounded-xl" />
          <Skeleton className="h-40 w-full rounded-xl" />
        </div>
      ) : pending ? (
        <Card className="border-dashed">
          <CardContent className="flex flex-col items-center justify-center py-16 text-center space-y-3">
            <div className="p-3 rounded-lg bg-blue-50">
              <Hourglass className="w-6 h-6 text-blue-700" />
            </div>
            <h2 className="text-lg font-semibold text-gray-900">
              Votre copie n’a pas encore été corrigée
            </h2>
            <p className="text-sm text-gray-500 max-w-sm">
              Votre préparateur n’a pas encore publié la correction. Revenez
              plus tard — vous pourrez consulter les scores Fond et Forme ici.
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
                  <div className="p-3 rounded-lg bg-blue-50">
                    <Trophy className="w-6 h-6 text-blue-700" />
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
                  Corrigée le {formatDate(results.correctedAt)}
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
                Détail des tâches
              </h2>
              <span className="text-sm text-gray-500">
                {results.tasks.length} tâche
                {results.tasks.length === 1 ? '' : 's'}
              </span>
            </div>

            <ul className="space-y-3">
              {results.tasks.map((task) => {
                const wordOk =
                  task.nombreMots >= task.motsMin &&
                  task.nombreMots <= task.motsMax;
                const taskScore =
                  (task.scoreFond ?? 0) + (task.scoreForme ?? 0);
                return (
                  <li key={task.tacheId}>
                    <Card className="border border-blue-100">
                      <CardContent className="p-4 sm:p-5 space-y-4">
                        <div className="flex items-start justify-between gap-3">
                          <div className="flex items-start gap-2 min-w-0">
                            <span className="inline-flex h-7 w-7 shrink-0 items-center justify-center rounded-md bg-blue-50 border border-blue-100 text-xs font-semibold text-blue-800">
                              {task.numero}
                            </span>
                            <div className="min-w-0">
                              <p className="text-sm font-semibold text-gray-900">
                                Tâche {task.numero}
                              </p>
                              <p className="text-xs text-gray-500 mt-0.5">
                                {task.motsMin}–{task.motsMax} mots attendus
                              </p>
                            </div>
                          </div>
                          <Badge
                            variant="outline"
                            className="bg-blue-50 text-blue-800 border-blue-200 shrink-0"
                          >
                            {taskScore}/20
                          </Badge>
                        </div>

                        <div className="rounded-lg bg-blue-50/60 border border-blue-100 px-3 py-2">
                          <p className="text-xs font-medium text-blue-800 mb-1">
                            Consigne
                          </p>
                          <p className="text-sm text-gray-800 whitespace-pre-wrap">
                            {task.consigne}
                          </p>
                        </div>

                        <div className="rounded-lg border border-gray-100 bg-gray-50 px-3 py-2 space-y-2">
                          <div className="flex items-center justify-between gap-2">
                            <p className="text-xs font-medium text-gray-500">
                              Votre texte
                            </p>
                            <span
                              className={cn(
                                'text-xs font-semibold tabular-nums',
                                wordOk ? 'text-flehub-green' : 'text-red-600'
                              )}
                            >
                              {task.nombreMots} mot
                              {task.nombreMots === 1 ? '' : 's'} /{' '}
                              {task.motsMin}–{task.motsMax}
                            </span>
                          </div>
                          <p className="text-sm text-gray-900 whitespace-pre-wrap leading-relaxed">
                            {task.texte.trim()
                              ? task.texte
                              : 'Aucun texte rédigé pour cette tâche.'}
                          </p>
                        </div>

                        <div className="grid gap-3 sm:grid-cols-2">
                          <div className="rounded-lg border border-gray-200 bg-white px-3 py-3 space-y-1.5">
                            <div className="flex items-center justify-between gap-2">
                              <p className="text-xs font-medium text-gray-500">
                                Fond
                              </p>
                              <p className="text-sm font-bold text-gray-900">
                                {task.scoreFond ?? '—'}/10
                              </p>
                            </div>
                            <p className="text-sm text-gray-700 whitespace-pre-wrap">
                              {task.commentaireFond?.trim()
                                ? task.commentaireFond
                                : 'Aucun commentaire.'}
                            </p>
                          </div>
                          <div className="rounded-lg border border-gray-200 bg-white px-3 py-3 space-y-1.5">
                            <div className="flex items-center justify-between gap-2">
                              <p className="text-xs font-medium text-gray-500">
                                Forme
                              </p>
                              <p className="text-sm font-bold text-gray-900">
                                {task.scoreForme ?? '—'}/10
                              </p>
                            </div>
                            <p className="text-sm text-gray-700 whitespace-pre-wrap">
                              {task.commentaireForme?.trim()
                                ? task.commentaireForme
                                : 'Aucun commentaire.'}
                            </p>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  </li>
                );
              })}
            </ul>
          </div>

          <Card>
            <CardContent className="p-6 flex flex-col sm:flex-row sm:items-center gap-4 justify-between">
              <div className="flex items-center gap-3">
                <div className="p-2 rounded-lg bg-blue-50">
                  <PenLine className="w-4 h-4 text-blue-700" />
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
