'use client';

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
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
  ArrowRight,
  CheckCircle2,
  Clock,
  Loader2,
  Mic,
  RefreshCw,
  Shuffle,
  Video,
} from 'lucide-react';
import { cn } from '@/lib/utils';

const LEARNER_SESSIONS_HREF = '/dashboard/learner/elearning/sessions';

const PREP_SECONDS = 2 * 60;
const SPEAK_SECONDS: Record<2 | 3, number> = {
  2: 3 * 60 + 30, // 3 min 30
  3: 4 * 60 + 30, // 4 min 30 (fourchette officielle 4–5 min)
};

type TacheNumero = 2 | 3;
type TimerPhase = 'idle' | 'prep' | 'speak' | 'done';

interface TcfEoSession {
  id: string;
  titre: string;
  statut: 'brouillon' | 'publiee';
}

interface EoSujet {
  id: string;
  tache: TacheNumero;
  enonce: string;
}

function formatCountdown(totalSeconds: number): string {
  const safe = Math.max(0, totalSeconds);
  const m = Math.floor(safe / 60);
  const s = safe % 60;
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
}

function formatDurationLabel(seconds: number): string {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  if (s === 0) return `${m} min`;
  return `${m} min ${String(s).padStart(2, '0')}`;
}

function pickRandom<T>(items: T[]): T | null {
  if (items.length === 0) return null;
  return items[Math.floor(Math.random() * items.length)] ?? null;
}

export default function LearnerPrepTcfEoSession() {
  const params = useParams();
  const sessionId = params.sessionId as string;
  const supabase = useMemo(() => createClient(), []);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [session, setSession] = useState<TcfEoSession | null>(null);
  const [sujets, setSujets] = useState<EoSujet[]>([]);
  const [evaluationId, setEvaluationId] = useState<string | null>(null);

  const [drawing, setDrawing] = useState(false);
  const [activeTache, setActiveTache] = useState<TacheNumero | null>(null);
  const [activeSujet, setActiveSujet] = useState<EoSujet | null>(null);
  const [timerPhase, setTimerPhase] = useState<TimerPhase>('idle');
  const [remainingSeconds, setRemainingSeconds] = useState(0);
  const [phaseTotalSeconds, setPhaseTotalSeconds] = useState(0);

  const phaseEndAtRef = useRef<number | null>(null);
  const timerPhaseRef = useRef<TimerPhase>('idle');
  const activeTacheRef = useRef<TacheNumero | null>(null);

  useEffect(() => {
    timerPhaseRef.current = timerPhase;
  }, [timerPhase]);

  useEffect(() => {
    activeTacheRef.current = activeTache;
  }, [activeTache]);

  useEffect(() => {
    let cancelled = false;

    async function init() {
      try {
        setLoading(true);
        setError(null);

        const {
          data: { user },
        } = await supabase.auth.getUser();

        const { data: sessionData, error: sessionError } = await supabase
          .from('tcf_eo_sessions')
          .select('id, titre, statut')
          .eq('id', sessionId)
          .maybeSingle();

        if (sessionError) throw sessionError;
        if (!sessionData || sessionData.statut !== 'publiee') {
          setError('Cette séance n’est pas disponible.');
          return;
        }
        if (cancelled) return;
        setSession(sessionData as TcfEoSession);

        const { data: sujetsData, error: sujetsError } = await supabase
          .from('tcf_eo_sujets')
          .select('id, tache, enonce')
          .eq('session_id', sessionId)
          .in('tache', [2, 3]);

        if (sujetsError) throw sujetsError;
        if (cancelled) return;
        setSujets((sujetsData as EoSujet[]) ?? []);

        if (user) {
          const { data: evaluation } = await supabase
            .from('student_eo_evaluations')
            .select('id, evaluated_at')
            .eq('session_id', sessionId)
            .eq('student_id', user.id)
            .not('evaluated_at', 'is', null)
            .order('evaluated_at', { ascending: false })
            .limit(1)
            .maybeSingle();

          if (!cancelled && evaluation?.id) {
            setEvaluationId(evaluation.id);
          }
        }
      } catch (err) {
        console.error(err);
        if (!cancelled) {
          setError(
            err instanceof Error
              ? err.message
              : 'Impossible de charger la séance.'
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

  const startPhase = useCallback((phase: 'prep' | 'speak', tache: TacheNumero) => {
    const total =
      phase === 'prep' ? PREP_SECONDS : SPEAK_SECONDS[tache];
    phaseEndAtRef.current = Date.now() + total * 1000;
    setPhaseTotalSeconds(total);
    setRemainingSeconds(total);
    setTimerPhase(phase);
    timerPhaseRef.current = phase;
  }, []);

  // Minuteur
  useEffect(() => {
    if (timerPhase !== 'prep' && timerPhase !== 'speak') return;

    const tick = () => {
      const endAt = phaseEndAtRef.current;
      if (!endAt) return;
      const remaining = Math.ceil((endAt - Date.now()) / 1000);
      setRemainingSeconds(Math.max(0, remaining));

      if (remaining <= 0) {
        const tache = activeTacheRef.current;
        if (timerPhaseRef.current === 'prep' && tache) {
          startPhase('speak', tache);
          return;
        }
        if (timerPhaseRef.current === 'speak') {
          setTimerPhase('done');
          timerPhaseRef.current = 'done';
          phaseEndAtRef.current = null;
        }
      }
    };

    tick();
    const id = window.setInterval(tick, 200);
    return () => window.clearInterval(id);
  }, [timerPhase, startPhase]);

  function drawSujet(tache: TacheNumero, excludeId?: string) {
    setDrawing(true);
    setError(null);
    try {
      const pool = sujets.filter(
        (s) => s.tache === tache && (!excludeId || s.id !== excludeId)
      );
      const source = pool.length > 0 ? pool : sujets.filter((s) => s.tache === tache);
      const picked = pickRandom(source);
      if (!picked) {
        setError(
          `Aucun sujet disponible pour la tâche ${tache}. Contactez votre préparateur.`
        );
        setActiveSujet(null);
        setActiveTache(null);
        setTimerPhase('idle');
        return;
      }

      setActiveTache(tache);
      setActiveSujet(picked);
      startPhase('prep', tache);
    } finally {
      setDrawing(false);
    }
  }

  function handleDrawAnother() {
    if (!activeTache) return;
    drawSujet(activeTache, activeSujet?.id);
  }

  const countTache2 = sujets.filter((s) => s.tache === 2).length;
  const countTache3 = sujets.filter((s) => s.tache === 3).length;
  const progress =
    phaseTotalSeconds > 0
      ? Math.min(100, ((phaseTotalSeconds - remainingSeconds) / phaseTotalSeconds) * 100)
      : 0;
  const timerUrgent = remainingSeconds <= 15 && (timerPhase === 'prep' || timerPhase === 'speak');

  if (loading) {
    return (
      <div className="p-6 space-y-6 max-w-3xl mx-auto">
        <Skeleton className="h-8 w-64" />
        <Skeleton className="h-32 w-full" />
        <Skeleton className="h-40 w-full" />
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
    <div className="p-6 space-y-6 max-w-3xl mx-auto">
      <div>
        <Link
          href="/dashboard/learner/preparation"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour à Préparation
        </Link>
        <div className="flex items-center gap-2 flex-wrap">
          <h1 className="text-2xl font-bold text-gray-900">
            {session?.titre ?? 'Séance TCF EO'}
          </h1>
          <Badge
            variant="outline"
            className="bg-violet-100 text-violet-800 border-violet-200"
          >
            EO
          </Badge>
        </div>
        <p className="text-sm text-gray-500 mt-1">
          Préparez votre rendez-vous d’expression orale
        </p>
      </div>

      {evaluationId && (
        <Card className="border-violet-200 bg-violet-50/40">
          <CardContent className="p-4 flex flex-col sm:flex-row sm:items-center gap-3 justify-between">
            <div className="flex items-start gap-3">
              <div className="p-2 rounded-lg bg-violet-100 shrink-0">
                <CheckCircle2 className="w-4 h-4 text-violet-700" />
              </div>
              <div>
                <p className="text-sm font-semibold text-violet-900">
                  Votre évaluation est disponible
                </p>
                <p className="text-xs text-violet-800/80 mt-0.5">
                  Votre formateur a publié les scores de votre passage oral.
                </p>
              </div>
            </div>
            <Button
              asChild
              className="bg-violet-700 hover:bg-violet-800 text-white shrink-0"
            >
              <Link
                href={`/dashboard/learner/preparation/tcf-eo/results/${evaluationId}`}
              >
                Voir mes résultats
                <ArrowRight className="w-4 h-4 ml-1.5" />
              </Link>
            </Button>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardContent className="p-6 space-y-3">
          <h2 className="text-lg font-semibold text-gray-900">
            Structure de l’épreuve officielle
          </h2>
          <ul className="space-y-3 text-sm text-gray-700">
            <li className="rounded-lg border border-gray-100 bg-gray-50 px-4 py-3">
              <p className="font-semibold text-gray-900">
                Tâche 1 (2 min, sans préparation)
              </p>
              <p className="mt-1">
                Entretien dirigé : présentez-vous et répondez aux questions de
                l’examinateur.
              </p>
            </li>
            <li className="rounded-lg border border-gray-100 bg-gray-50 px-4 py-3">
              <p className="font-semibold text-gray-900">
                Tâche 2 (2 min de préparation + 3 min 30)
              </p>
              <p className="mt-1">
                Posez des questions à l’examinateur sur un sujet donné.
              </p>
            </li>
            <li className="rounded-lg border border-gray-100 bg-gray-50 px-4 py-3">
              <p className="font-semibold text-gray-900">
                Tâche 3 (2 min de préparation + 4 à 5 min)
              </p>
              <p className="mt-1">
                Exprimez votre opinion seul sur un sujet donné, sans relance.
              </p>
            </li>
          </ul>
        </CardContent>
      </Card>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {error}
        </div>
      )}

      <Card>
        <CardContent className="p-6 space-y-4">
          <div>
            <h2 className="text-lg font-semibold text-gray-900">
              S’entraîner seul
            </h2>
            <p className="text-sm text-gray-500 mt-1">
              Tirez un sujet au hasard et chronométrez votre préparation puis
              votre prise de parole. Rien n’est enregistré ni envoyé.
            </p>
            <p className="text-xs text-gray-400 mt-1">
              Banque : {countTache2} sujet{countTache2 === 1 ? '' : 's'} (tâche
              2) · {countTache3} sujet{countTache3 === 1 ? '' : 's'} (tâche 3)
            </p>
          </div>

          <div className="grid gap-2 sm:grid-cols-2">
            <Button
              type="button"
              className="bg-violet-700 hover:bg-violet-800 text-white"
              disabled={drawing || countTache2 === 0}
              onClick={() => drawSujet(2)}
            >
              {drawing && activeTache === 2 ? (
                <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
              ) : (
                <Shuffle className="w-4 h-4 mr-1.5" />
              )}
              Tirer un sujet — Tâche 2
            </Button>
            <Button
              type="button"
              variant="outline"
              className="border-violet-300 text-violet-800 hover:bg-violet-50"
              disabled={drawing || countTache3 === 0}
              onClick={() => drawSujet(3)}
            >
              {drawing && activeTache === 3 ? (
                <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
              ) : (
                <Shuffle className="w-4 h-4 mr-1.5" />
              )}
              Tirer un sujet — Tâche 3
            </Button>
          </div>

          {activeSujet && activeTache && (
            <div className="rounded-xl border border-violet-100 bg-violet-50/40 p-4 space-y-4">
              <div className="flex items-center justify-between gap-2 flex-wrap">
                <Badge
                  variant="outline"
                  className="bg-violet-100 text-violet-800 border-violet-200"
                >
                  Tâche {activeTache}
                </Badge>
                <span className="text-xs text-violet-800/80">
                  Préparation {formatDurationLabel(PREP_SECONDS)} · Parole{' '}
                  {formatDurationLabel(SPEAK_SECONDS[activeTache])}
                  {activeTache === 3 ? ' (fourchette 4–5 min)' : ''}
                </span>
              </div>

              <div className="rounded-lg bg-white border border-violet-100 px-4 py-3">
                <p className="text-xs font-medium text-violet-800 mb-1">
                  Sujet tiré
                </p>
                <p className="text-sm text-gray-900 whitespace-pre-wrap leading-relaxed">
                  {activeSujet.enonce}
                </p>
              </div>

              <div className="space-y-2">
                <div className="flex items-center justify-between gap-2">
                  <p className="text-sm font-medium text-gray-800">
                    {timerPhase === 'prep' && 'Temps de préparation'}
                    {timerPhase === 'speak' && 'Temps de parole'}
                    {timerPhase === 'done' && 'Entraînement terminé'}
                    {timerPhase === 'idle' && 'Minuteur'}
                  </p>
                  <div
                    className={cn(
                      'inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-sm font-semibold tabular-nums',
                      timerUrgent
                        ? 'bg-red-50 text-red-700 border border-red-200'
                        : timerPhase === 'done'
                          ? 'bg-flehub-green-light text-flehub-green border border-flehub-green/30'
                          : 'bg-white text-violet-800 border border-violet-200'
                    )}
                    aria-live="polite"
                  >
                    <Clock className="w-4 h-4" />
                    {timerPhase === 'done'
                      ? '00:00'
                      : formatCountdown(remainingSeconds)}
                  </div>
                </div>
                <div className="h-2 rounded-full bg-violet-100 overflow-hidden">
                  <div
                    className={cn(
                      'h-full transition-all duration-200',
                      timerUrgent ? 'bg-red-500' : 'bg-violet-600'
                    )}
                    style={{
                      width: `${timerPhase === 'done' ? 100 : progress}%`,
                    }}
                  />
                </div>
                <p className="text-xs text-gray-500">
                  {timerPhase === 'prep' &&
                    'Préparez-vous en silence. Le temps de parole démarrera automatiquement.'}
                  {timerPhase === 'speak' &&
                    'Parlez à voix haute. Rien n’est enregistré — c’est un entraînement libre.'}
                  {timerPhase === 'done' &&
                    'Bravo. Vous pouvez tirer un autre sujet pour recommencer.'}
                </p>
              </div>

              <Button
                type="button"
                variant="outline"
                className="w-full border-violet-300 text-violet-800 hover:bg-violet-50"
                onClick={handleDrawAnother}
                disabled={drawing}
              >
                <RefreshCw className="w-4 h-4 mr-1.5" />
                Tirer un autre sujet
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-6 space-y-4">
          <div className="flex items-start gap-3">
            <div className="p-2 rounded-lg bg-violet-50 shrink-0">
              <Video className="w-4 h-4 text-violet-700" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-gray-900">
                Passer l’épreuve avec votre formateur
              </h2>
              <p className="text-sm text-gray-500 mt-1">
                Une fois prêt, prenez rendez-vous avec votre formateur pour
                passer l’épreuve en direct par visioconférence.
              </p>
            </div>
          </div>
          <Button
            asChild
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
          >
            <Link href={LEARNER_SESSIONS_HREF}>
              <Mic className="w-4 h-4 mr-1.5" />
              Aller à Sessions
              <ArrowRight className="w-4 h-4 ml-1.5" />
            </Link>
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
