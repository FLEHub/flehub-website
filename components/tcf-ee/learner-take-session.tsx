'use client';

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Skeleton } from '@/components/ui/skeleton';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import {
  AlertTriangle,
  ArrowLeft,
  Clock,
  Loader2,
  Maximize,
  PenLine,
} from 'lucide-react';
import { cn } from '@/lib/utils';

const AUTOSAVE_MS = 10_000;

interface TcfEeSession {
  id: string;
  titre: string;
  duree_minuteur: number;
  statut: 'brouillon' | 'publiee';
}

interface TcfEeTache {
  id: string;
  session_id: string;
  numero: number;
  consigne: string;
  mots_min: number;
  mots_max: number;
}

type Drafts = Record<string, string>;

function countWords(text: string): number {
  const trimmed = text.trim();
  if (!trimmed) return 0;
  return trimmed.split(/\s+/).filter(Boolean).length;
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

async function requestFullscreen(): Promise<void> {
  const el = document.documentElement;
  if (document.fullscreenElement) return;
  if (el.requestFullscreen) {
    await el.requestFullscreen();
  }
}

async function exitFullscreenSafe(): Promise<void> {
  try {
    if (document.fullscreenElement && document.exitFullscreen) {
      await document.exitFullscreen();
    }
  } catch {
    // ignore — certains navigateurs refusent hors geste utilisateur
  }
}

export default function LearnerTakeTcfEeSession() {
  const params = useParams();
  const router = useRouter();
  const sessionId = params.sessionId as string;
  const supabase = useMemo(() => createClient(), []);

  const [loading, setLoading] = useState(true);
  const [starting, setStarting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [session, setSession] = useState<TcfEeSession | null>(null);
  const [taches, setTaches] = useState<TcfEeTache[]>([]);
  const [phase, setPhase] = useState<'intro' | 'test' | 'done'>('intro');
  const [alreadySubmitted, setAlreadySubmitted] = useState(false);

  const [attemptId, setAttemptId] = useState<string | null>(null);
  const [startedAtMs, setStartedAtMs] = useState<number | null>(null);
  const [durationSeconds, setDurationSeconds] = useState(0);
  const [remainingSeconds, setRemainingSeconds] = useState(0);

  const [activeNumero, setActiveNumero] = useState(1);
  const [drafts, setDrafts] = useState<Drafts>({});
  const [finishing, setFinishing] = useState(false);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [exitWarning, setExitWarning] = useState(false);
  const [savingHint, setSavingHint] = useState(false);

  const draftsRef = useRef<Drafts>({});
  const dirtyRef = useRef(false);
  const attemptIdRef = useRef<string | null>(null);
  const startedAtMsRef = useRef<number | null>(null);
  const finishingRef = useRef(false);
  const testActiveRef = useRef(false);
  const sortiesRef = useRef(0);
  const exitWarningTimerRef = useRef<number | null>(null);
  const finishTestRef = useRef<(() => Promise<void>) | null>(null);
  const tachesRef = useRef<TcfEeTache[]>([]);

  useEffect(() => {
    draftsRef.current = drafts;
  }, [drafts]);

  useEffect(() => {
    attemptIdRef.current = attemptId;
  }, [attemptId]);

  useEffect(() => {
    startedAtMsRef.current = startedAtMs;
  }, [startedAtMs]);

  useEffect(() => {
    tachesRef.current = taches;
  }, [taches]);

  useEffect(() => {
    testActiveRef.current = phase === 'test' && !finishing;
  }, [phase, finishing]);

  // Chargement initial : séance + tâches + tentative existante
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
          .from('tcf_ee_sessions')
          .select('id, titre, duree_minuteur, statut')
          .eq('id', sessionId)
          .maybeSingle();

        if (sessionError) throw sessionError;
        if (!sessionData || sessionData.statut !== 'publiee') {
          setError('Cette séance n’est pas disponible.');
          return;
        }
        if (cancelled) return;
        setSession(sessionData as TcfEeSession);
        setDurationSeconds(Math.max(1, sessionData.duree_minuteur) * 60);

        const { data: tachesData, error: tachesError } = await supabase
          .from('tcf_ee_taches')
          .select('id, session_id, numero, consigne, mots_min, mots_max')
          .eq('session_id', sessionId)
          .order('numero', { ascending: true });

        if (tachesError) throw tachesError;
        const list = ((tachesData as TcfEeTache[]) ?? []).filter(
          (t) => t.numero >= 1 && t.numero <= 3
        );
        if (list.length < 3) {
          setError('Cette séance n’est pas encore prête (3 tâches requises).');
          return;
        }
        if (cancelled) return;
        setTaches(list);

        const { data: existing, error: attemptError } = await supabase
          .from('student_ee_attempts')
          .select('id, statut, started_at, nb_sorties_onglet, completed_at')
          .eq('session_id', sessionId)
          .eq('student_id', user.id)
          .order('started_at', { ascending: false })
          .limit(1)
          .maybeSingle();

        if (attemptError) throw attemptError;

        if (
          existing &&
          (existing.statut === 'a_corriger' || existing.statut === 'corrige')
        ) {
          if (!cancelled) setAlreadySubmitted(true);
          return;
        }

        if (existing && existing.statut === 'en_cours') {
          const { data: reponses } = await supabase
            .from('student_ee_reponses')
            .select('tache_id, texte')
            .eq('attempt_id', existing.id);

          const nextDrafts: Drafts = {};
          for (const t of list) {
            const found = (reponses ?? []).find((r) => r.tache_id === t.id);
            nextDrafts[t.id] = found?.texte ?? '';
          }

          if (cancelled) return;
          setAttemptId(existing.id);
          attemptIdRef.current = existing.id;
          sortiesRef.current = existing.nb_sorties_onglet ?? 0;
          setDrafts(nextDrafts);
          draftsRef.current = nextDrafts;
          const startedMs = new Date(existing.started_at).getTime();
          setStartedAtMs(startedMs);
          startedAtMsRef.current = startedMs;
          // L’intro reste affichée ; « Commencer » reprendra en plein écran
        } else {
          const nextDrafts: Drafts = {};
          for (const t of list) nextDrafts[t.id] = '';
          if (!cancelled) {
            setDrafts(nextDrafts);
            draftsRef.current = nextDrafts;
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

  const persistDrafts = useCallback(async () => {
    const id = attemptIdRef.current;
    if (!id || finishingRef.current) return;

    const currentDrafts = draftsRef.current;
    const rows = tachesRef.current.map((t) => {
      const texte = currentDrafts[t.id] ?? '';
      return {
        attempt_id: id,
        tache_id: t.id,
        texte,
        nombre_mots: countWords(texte),
      };
    });

    setSavingHint(true);
    try {
      const { error: upsertError } = await supabase
        .from('student_ee_reponses')
        .upsert(rows, { onConflict: 'attempt_id,tache_id' });
      if (upsertError) throw upsertError;
      dirtyRef.current = false;
    } catch (err) {
      console.error(err);
    } finally {
      setSavingHint(false);
    }
  }, [supabase]);

  const finishTest = useCallback(async () => {
    if (finishingRef.current) return;
    const id = attemptIdRef.current;
    if (!id) return;

    finishingRef.current = true;
    setFinishing(true);
    setConfirmOpen(false);
    setError(null);
    testActiveRef.current = false;

    try {
      await persistDrafts();

      const { error: updateError } = await supabase
        .from('student_ee_attempts')
        .update({
          statut: 'a_corriger',
          completed_at: new Date().toISOString(),
        })
        .eq('id', id);
      if (updateError) throw updateError;

      await exitFullscreenSafe();
      setPhase('done');
      router.replace(
        `/dashboard/learner/preparation/tcf-ee/${sessionId}/confirmation`
      );
    } catch (err) {
      console.error(err);
      finishingRef.current = false;
      setFinishing(false);
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible d’envoyer votre copie. Réessayez.'
      );
    }
  }, [persistDrafts, router, sessionId, supabase]);

  useEffect(() => {
    finishTestRef.current = finishTest;
  }, [finishTest]);

  // Autosave ~10s
  useEffect(() => {
    if (phase !== 'test' || finishing) return;
    const id = window.setInterval(() => {
      if (dirtyRef.current) void persistDrafts();
    }, AUTOSAVE_MS);
    return () => window.clearInterval(id);
  }, [phase, finishing, persistDrafts]);

  // Minuteur
  useEffect(() => {
    if (phase !== 'test' || !startedAtMs || !durationSeconds || finishing) {
      return;
    }

    const tick = () => {
      const elapsed = Math.floor((Date.now() - startedAtMs) / 1000);
      const remaining = durationSeconds - elapsed;
      setRemainingSeconds(Math.max(0, remaining));
      if (remaining <= 0) {
        void finishTestRef.current?.();
      }
    };

    tick();
    const id = window.setInterval(tick, 250);
    return () => window.clearInterval(id);
  }, [phase, startedAtMs, durationSeconds, finishing]);

  // Anti-triche : visibility + sortie plein écran
  useEffect(() => {
    if (phase !== 'test') return;

    const recordExit = () => {
      if (!testActiveRef.current || finishingRef.current) return;
      const id = attemptIdRef.current;
      if (!id) return;

      sortiesRef.current += 1;
      const next = sortiesRef.current;
      void supabase
        .from('student_ee_attempts')
        .update({ nb_sorties_onglet: next })
        .eq('id', id);

      setExitWarning(true);
      if (exitWarningTimerRef.current) {
        window.clearTimeout(exitWarningTimerRef.current);
      }
      exitWarningTimerRef.current = window.setTimeout(() => {
        setExitWarning(false);
      }, 4000);
    };

    const onVisibility = () => {
      if (document.hidden) recordExit();
    };

    const onFullscreen = () => {
      if (!document.fullscreenElement) recordExit();
    };

    document.addEventListener('visibilitychange', onVisibility);
    document.addEventListener('fullscreenchange', onFullscreen);
    return () => {
      document.removeEventListener('visibilitychange', onVisibility);
      document.removeEventListener('fullscreenchange', onFullscreen);
      if (exitWarningTimerRef.current) {
        window.clearTimeout(exitWarningTimerRef.current);
      }
    };
  }, [phase, supabase]);

  async function handleStart() {
    if (!session || taches.length < 3) return;
    setStarting(true);
    setError(null);

    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) {
        setError('Session expirée. Reconnectez-vous.');
        return;
      }

      try {
        await requestFullscreen();
      } catch (err) {
        console.warn('Fullscreen refusé ou indisponible', err);
      }

      let id = attemptId;
      let startedMs = startedAtMs;

      if (!id) {
        const startedIso = new Date().toISOString();
        const { data: created, error: insertError } = await supabase
          .from('student_ee_attempts')
          .insert({
            session_id: sessionId,
            student_id: user.id,
            statut: 'en_cours',
            nb_sorties_onglet: 0,
            started_at: startedIso,
          })
          .select('id, started_at')
          .single();
        if (insertError) throw insertError;
        id = created.id;
        startedMs = new Date(created.started_at).getTime();
        setAttemptId(id);
        attemptIdRef.current = id;
        setStartedAtMs(startedMs);
        startedAtMsRef.current = startedMs;
        sortiesRef.current = 0;
      } else if (!startedMs) {
        startedMs = Date.now();
        setStartedAtMs(startedMs);
        startedAtMsRef.current = startedMs;
      }

      const duration = Math.max(1, session.duree_minuteur) * 60;
      const elapsed = Math.floor((Date.now() - (startedMs ?? Date.now())) / 1000);
      if (elapsed >= duration) {
        setPhase('test');
        await finishTestRef.current?.();
        return;
      }

      setRemainingSeconds(duration - elapsed);
      setPhase('test');
    } catch (err) {
      console.error(err);
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible de démarrer le test. Réessayez.'
      );
    } finally {
      setStarting(false);
    }
  }

  function handleDraftChange(tacheId: string, value: string) {
    setDrafts((prev) => {
      const next = { ...prev, [tacheId]: value };
      draftsRef.current = next;
      return next;
    });
    dirtyRef.current = true;
  }

  const activeTache =
    taches.find((t) => t.numero === activeNumero) ?? taches[0] ?? null;
  const activeText = activeTache ? (drafts[activeTache.id] ?? '') : '';
  const activeWordCount = countWords(activeText);
  const wordCountOk =
    activeTache != null &&
    activeWordCount >= activeTache.mots_min &&
    activeWordCount <= activeTache.mots_max;
  const timerUrgent = remainingSeconds <= 60;

  if (loading) {
    return (
      <div className="p-6 space-y-6 max-w-3xl mx-auto">
        <Skeleton className="h-8 w-64" />
        <Skeleton className="h-12 w-full" />
        <Skeleton className="h-64 w-full" />
      </div>
    );
  }

  if (alreadySubmitted) {
    return (
      <div className="p-6 space-y-4 max-w-xl mx-auto">
        <Link
          href="/dashboard/learner/preparation"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour à Préparation
        </Link>
        <Card>
          <CardContent className="py-12 text-center space-y-3">
            <div className="mx-auto p-3 rounded-lg bg-blue-50 w-fit">
              <PenLine className="w-6 h-6 text-blue-700" />
            </div>
            <h1 className="text-xl font-bold text-gray-900">
              Copie déjà envoyée
            </h1>
            <p className="text-sm text-gray-500">
              Vous avez déjà soumis cette séance. La correction arrivera
              bientôt.
            </p>
            <Button
              asChild
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
            >
              <Link
                href={`/dashboard/learner/preparation/tcf-ee/${sessionId}/confirmation`}
              >
                Voir la confirmation
              </Link>
            </Button>
          </CardContent>
        </Card>
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

  if (phase === 'intro' && session) {
    return (
      <div className="p-6 space-y-6 max-w-2xl mx-auto">
        <div>
          <Link
            href="/dashboard/learner/preparation"
            className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green mb-3"
          >
            <ArrowLeft className="w-4 h-4" />
            Retour à Préparation
          </Link>
          <div className="flex items-center gap-2 flex-wrap">
            <h1 className="text-2xl font-bold text-gray-900">{session.titre}</h1>
            <span className="inline-flex items-center rounded-md border border-blue-200 bg-blue-100 px-2 py-0.5 text-xs font-medium text-blue-800">
              EE
            </span>
          </div>
          <p className="text-sm text-gray-500 mt-1">
            Expression écrite — lisez les consignes avant de commencer
          </p>
        </div>

        {error && (
          <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
            <AlertTriangle className="w-4 h-4 flex-shrink-0" />
            {error}
          </div>
        )}

        <Card>
          <CardContent className="p-6 space-y-4">
            <div className="flex items-center gap-2 text-blue-800">
              <Maximize className="w-4 h-4" />
              <h2 className="font-semibold">Règles de la séance</h2>
            </div>
            <ul className="space-y-2 text-sm text-gray-700 list-disc pl-5">
              <li>
                Durée totale :{' '}
                <strong>{session.duree_minuteur} minutes</strong> (minuteur
                global).
              </li>
              <li>
                Vous devez rédiger <strong>3 tâches</strong>. Vous pouvez
                naviguer librement entre elles.
              </li>
              <li>
                Respectez la fourchette de mots indiquée pour chaque tâche.
              </li>
              <li>
                Le test se déroule en <strong>plein écran</strong>. Restez sur
                cette page jusqu’à l’envoi de votre copie.
              </li>
              <li>
                À la fin du temps ou lorsque vous validez, votre copie est
                envoyée pour correction (irréversible).
              </li>
            </ul>

            {attemptId && (
              <p className="text-xs text-blue-800 bg-blue-50 border border-blue-100 rounded-lg px-3 py-2">
                Une rédaction en cours a été trouvée. En cliquant sur Commencer,
                vous reprendrez là où vous vous étiez arrêté.
              </p>
            )}

            <Button
              className="w-full bg-blue-700 hover:bg-blue-800 text-white"
              onClick={() => void handleStart()}
              disabled={starting}
            >
              {starting ? (
                <>
                  <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
                  Démarrage…
                </>
              ) : (
                <>
                  <PenLine className="w-4 h-4 mr-1.5" />
                  Commencer
                </>
              )}
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-4 max-w-3xl mx-auto">
      <div className="sticky top-0 z-10 -mx-6 px-6 py-3 bg-gray-50/95 backdrop-blur border-b border-gray-100">
        <div className="flex items-center justify-between gap-3 flex-wrap">
          <div className="min-w-0">
            <p className="text-xs text-gray-500">TCF Expression Écrite</p>
            <h1 className="text-lg font-bold text-gray-900 truncate">
              {session?.titre ?? 'Séance'}
            </h1>
          </div>
          <div
            className={cn(
              'inline-flex items-center gap-2 rounded-lg px-3 py-2 text-sm font-semibold tabular-nums',
              timerUrgent
                ? 'bg-red-50 text-red-700 border border-red-200'
                : 'bg-blue-50 text-blue-800 border border-blue-200'
            )}
            aria-live="polite"
          >
            <Clock className="w-4 h-4" />
            {formatCountdown(remainingSeconds)}
          </div>
        </div>

        <div className="mt-3 flex flex-wrap gap-2">
          {taches.map((t) => {
            const words = countWords(drafts[t.id] ?? '');
            const ok = words >= t.mots_min && words <= t.mots_max;
            const active = t.numero === activeNumero;
            return (
              <button
                key={t.id}
                type="button"
                onClick={() => setActiveNumero(t.numero)}
                disabled={finishing}
                className={cn(
                  'rounded-lg px-3 py-1.5 text-sm font-medium border transition-colors',
                  active
                    ? 'bg-blue-700 text-white border-blue-700'
                    : 'bg-white text-gray-700 border-gray-200 hover:border-blue-300',
                  !active && words > 0 && ok && 'border-flehub-green/40',
                  !active && words > 0 && !ok && 'border-red-200'
                )}
              >
                Tâche {t.numero}
              </button>
            );
          })}
        </div>

        {exitWarning && (
          <div className="mt-2 text-xs text-amber-800 bg-amber-50 border border-amber-200 rounded-md px-3 py-1.5">
            Sortie détectée : merci de rester sur cette page
          </div>
        )}
        {savingHint && (
          <p className="mt-1 text-xs text-gray-400">Sauvegarde…</p>
        )}
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
            <Loader2 className="w-8 h-8 animate-spin text-blue-700 mb-3" />
            <p className="text-sm text-gray-600">Envoi de votre copie…</p>
          </CardContent>
        </Card>
      ) : activeTache ? (
        <Card>
          <CardContent className="p-6 space-y-4">
            <div>
              <div className="flex items-center justify-between gap-2 flex-wrap">
                <h2 className="text-lg font-semibold text-gray-900">
                  Tâche {activeTache.numero}
                </h2>
                <span className="text-xs text-gray-500">
                  {activeTache.mots_min}–{activeTache.mots_max} mots attendus
                </span>
              </div>
              <p className="mt-3 text-sm text-gray-800 whitespace-pre-wrap rounded-lg bg-blue-50/60 border border-blue-100 px-4 py-3">
                {activeTache.consigne}
              </p>
            </div>

            <div className="space-y-2">
              <div className="flex items-center justify-between gap-2">
                <Label htmlFor="ee-draft">Votre rédaction</Label>
                <span
                  className={cn(
                    'text-sm font-semibold tabular-nums',
                    wordCountOk ? 'text-flehub-green' : 'text-red-600'
                  )}
                >
                  {activeWordCount} mot{activeWordCount === 1 ? '' : 's'}
                </span>
              </div>
              <Textarea
                id="ee-draft"
                value={activeText}
                onChange={(e) =>
                  handleDraftChange(activeTache.id, e.target.value)
                }
                rows={16}
                className="min-h-[280px] bg-white text-base leading-relaxed"
                placeholder="Rédigez votre réponse ici…"
                disabled={finishing}
              />
            </div>

            <div className="flex justify-end pt-2">
              <Button
                type="button"
                className="bg-blue-700 hover:bg-blue-800 text-white"
                onClick={() => setConfirmOpen(true)}
                disabled={finishing}
              >
                Terminer et envoyer
              </Button>
            </div>
          </CardContent>
        </Card>
      ) : null}

      <AlertDialog open={confirmOpen} onOpenChange={setConfirmOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Envoyer votre copie ?</AlertDialogTitle>
            <AlertDialogDescription>
              Cette action est irréversible. Vous ne pourrez plus modifier vos
              réponses après l’envoi.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={finishing}>Annuler</AlertDialogCancel>
            <AlertDialogAction
              className="bg-blue-700 hover:bg-blue-800 text-white"
              disabled={finishing}
              onClick={(e) => {
                e.preventDefault();
                void finishTest();
              }}
            >
              Confirmer l’envoi
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
