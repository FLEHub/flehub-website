'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Skeleton } from '@/components/ui/skeleton';
import { Slider } from '@/components/ui/slider';
import {
  AlertTriangle,
  ArrowLeft,
  CheckCircle2,
  EyeOff,
  Loader2,
  PenLine,
  X,
} from 'lucide-react';
import { cn } from '@/lib/utils';

interface AttemptInfo {
  id: string;
  session_id: string;
  student_id: string;
  student_name: string;
  statut: 'en_cours' | 'a_corriger' | 'corrige';
  nb_sorties_onglet: number;
  completed_at: string | null;
  session_titre: string;
}

interface TaskBlock {
  tacheId: string;
  numero: number;
  consigne: string;
  motsMin: number;
  motsMax: number;
  texte: string;
  nombreMots: number;
  scoreFond: string;
  commentaireFond: string;
  scoreForme: string;
  commentaireForme: string;
  correctedAt: string | null;
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

function parseScore(raw: string): number | null {
  if (raw.trim() === '') return null;
  const n = Number.parseInt(raw, 10);
  if (!Number.isFinite(n)) return null;
  return Math.min(10, Math.max(0, n));
}

function countWords(text: string): number {
  const trimmed = text.trim();
  if (!trimmed) return 0;
  return trimmed.split(/\s+/).filter(Boolean).length;
}

export default function TcfEeCorrectionEditor() {
  const params = useParams();
  const router = useRouter();
  const attemptId = params.attemptId as string;
  const supabase = useMemo(() => createClient(), []);

  const [attempt, setAttempt] = useState<AttemptInfo | null>(null);
  const [tasks, setTasks] = useState<TaskBlock[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [publishing, setPublishing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    try {
      setError(null);
      const { data: attemptData, error: attemptError } = await supabase
        .from('student_ee_attempts')
        .select(
          'id, session_id, student_id, statut, nb_sorties_onglet, completed_at'
        )
        .eq('id', attemptId)
        .maybeSingle();

      if (attemptError) throw attemptError;
      if (!attemptData) {
        setError('Tentative introuvable.');
        setAttempt(null);
        return;
      }

      if (
        attemptData.statut !== 'a_corriger' &&
        attemptData.statut !== 'corrige'
      ) {
        setError('Cette copie n’est pas encore envoyée pour correction.');
        return;
      }

      const { data: sessionData, error: sessionError } = await supabase
        .from('tcf_ee_sessions')
        .select('id, titre')
        .eq('id', attemptData.session_id)
        .maybeSingle();
      if (sessionError) throw sessionError;

      let studentName = 'Apprenant';
      const { data: profile } = await supabase
        .from('profiles')
        .select('full_name')
        .eq('id', attemptData.student_id)
        .maybeSingle();
      if (profile?.full_name?.trim()) {
        studentName = profile.full_name.trim();
      }

      setAttempt({
        id: attemptData.id,
        session_id: attemptData.session_id,
        student_id: attemptData.student_id,
        student_name: studentName,
        statut: attemptData.statut,
        nb_sorties_onglet: attemptData.nb_sorties_onglet ?? 0,
        completed_at: attemptData.completed_at,
        session_titre: sessionData?.titre ?? 'Séance EE',
      });

      const { data: tachesData, error: tachesError } = await supabase
        .from('tcf_ee_taches')
        .select('id, numero, consigne, mots_min, mots_max')
        .eq('session_id', attemptData.session_id)
        .order('numero', { ascending: true });
      if (tachesError) throw tachesError;

      const { data: reponsesData, error: reponsesError } = await supabase
        .from('student_ee_reponses')
        .select('tache_id, texte, nombre_mots')
        .eq('attempt_id', attemptId);
      if (reponsesError) throw reponsesError;

      const { data: correctionsData, error: correctionsError } = await supabase
        .from('ee_corrections')
        .select(
          'tache_id, score_fond, commentaire_fond, score_forme, commentaire_forme, corrected_at'
        )
        .eq('attempt_id', attemptId);
      if (correctionsError) throw correctionsError;

      const reponseByTache = new Map(
        (reponsesData ?? []).map((r) => [r.tache_id, r])
      );
      const correctionByTache = new Map(
        (correctionsData ?? []).map((c) => [c.tache_id, c])
      );

      const blocks: TaskBlock[] = (tachesData ?? []).map((t) => {
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
          scoreFond:
            correction?.score_fond === null ||
            correction?.score_fond === undefined
              ? ''
              : String(correction.score_fond),
          commentaireFond: correction?.commentaire_fond ?? '',
          scoreForme:
            correction?.score_forme === null ||
            correction?.score_forme === undefined
              ? ''
              : String(correction.score_forme),
          commentaireForme: correction?.commentaire_forme ?? '',
          correctedAt: correction?.corrected_at ?? null,
        };
      });

      setTasks(blocks);
    } catch (err) {
      console.error(err);
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible de charger la correction.'
      );
    } finally {
      setLoading(false);
    }
  }, [attemptId, supabase]);

  useEffect(() => {
    if (attemptId) void loadData();
  }, [attemptId, loadData]);

  function updateTask(tacheId: string, patch: Partial<TaskBlock>) {
    setTasks((prev) =>
      prev.map((t) => (t.tacheId === tacheId ? { ...t, ...patch } : t))
    );
    setSuccess(null);
  }

  const allScoresFilled = useMemo(
    () =>
      tasks.length === 3 &&
      tasks.every(
        (t) => parseScore(t.scoreFond) !== null && parseScore(t.scoreForme) !== null
      ),
    [tasks]
  );

  async function buildRows(options: {
    publish: boolean;
    userId: string;
  }) {
    const now = new Date().toISOString();
    return tasks.map((t) => ({
      attempt_id: attemptId,
      tache_id: t.tacheId,
      score_fond: parseScore(t.scoreFond),
      commentaire_fond: t.commentaireFond.trim() || null,
      score_forme: parseScore(t.scoreForme),
      commentaire_forme: t.commentaireForme.trim() || null,
      corrected_by: options.userId,
      corrected_at: options.publish ? now : null,
    }));
  }

  async function handleSaveDraft() {
    setSaving(true);
    setError(null);
    setSuccess(null);
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) {
        setError('Session expirée. Reconnectez-vous.');
        return;
      }

      for (const t of tasks) {
        const fond = t.scoreFond.trim() === '' ? null : parseScore(t.scoreFond);
        const forme =
          t.scoreForme.trim() === '' ? null : parseScore(t.scoreForme);
        if (t.scoreFond.trim() !== '' && fond === null) {
          throw new Error(
            `Score Fond invalide pour la tâche ${t.numero} (0 à 10).`
          );
        }
        if (t.scoreForme.trim() !== '' && forme === null) {
          throw new Error(
            `Score Forme invalide pour la tâche ${t.numero} (0 à 10).`
          );
        }
      }

      const rows = await buildRows({ publish: false, userId: user.id });
      const { error: upsertError } = await supabase
        .from('ee_corrections')
        .upsert(rows, { onConflict: 'attempt_id,tache_id' });
      if (upsertError) throw upsertError;

      setSuccess(
        'Brouillon enregistré. L’apprenant ne voit pas encore cette correction.'
      );
      await loadData();
    } catch (err) {
      console.error(err);
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible d’enregistrer le brouillon.'
      );
    } finally {
      setSaving(false);
    }
  }

  async function handlePublish() {
    if (!attempt || !allScoresFilled) return;
    setPublishing(true);
    setError(null);
    setSuccess(null);
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) {
        setError('Session expirée. Reconnectez-vous.');
        return;
      }

      const rows = await buildRows({ publish: true, userId: user.id });
      if (rows.some((r) => r.score_fond === null || r.score_forme === null)) {
        throw new Error(
          'Remplissez les scores Fond et Forme des 3 tâches avant de publier.'
        );
      }

      const { error: upsertError } = await supabase
        .from('ee_corrections')
        .upsert(rows, { onConflict: 'attempt_id,tache_id' });
      if (upsertError) throw upsertError;

      const { error: attemptError } = await supabase
        .from('student_ee_attempts')
        .update({ statut: 'corrige' })
        .eq('id', attemptId);
      if (attemptError) throw attemptError;

      router.push(
        `/dashboard/teacher/preparation/tcf-ee/${attempt.session_id}/corrections?published=1`
      );
    } catch (err) {
      console.error(err);
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible de publier la correction.'
      );
    } finally {
      setPublishing(false);
    }
  }

  if (loading) {
    return (
      <div className="p-6 space-y-6 max-w-4xl mx-auto">
        <Skeleton className="h-8 w-72" />
        <Skeleton className="h-24 w-full" />
        <Skeleton className="h-64 w-full" />
      </div>
    );
  }

  if (!attempt) {
    return (
      <div className="p-6 space-y-4 max-w-3xl mx-auto">
        <Link
          href="/dashboard/teacher/preparation"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour à Préparation
        </Link>
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {error || 'Tentative introuvable.'}
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6 max-w-4xl mx-auto">
      <div>
        <Link
          href={`/dashboard/teacher/preparation/tcf-ee/${attempt.session_id}/corrections`}
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour aux copies
        </Link>
        <div className="flex items-center gap-2 flex-wrap">
          <h1 className="text-2xl font-bold text-gray-900">
            Correction — {attempt.student_name}
          </h1>
          <Badge
            variant="outline"
            className="bg-blue-100 text-blue-800 border-blue-200"
          >
            EE
          </Badge>
          <Badge
            variant="outline"
            className={
              attempt.statut === 'corrige'
                ? 'bg-flehub-green-light text-flehub-green border-flehub-green'
                : 'bg-orange-50 text-orange-700 border-orange-200'
            }
          >
            {attempt.statut === 'corrige' ? 'Corrigé' : 'À corriger'}
          </Badge>
        </div>
        <p className="text-sm text-gray-500 mt-1">
          {attempt.session_titre} · Envoyée le{' '}
          {formatDate(attempt.completed_at)}
        </p>
      </div>

      <Card className="border-amber-200 bg-amber-50/40">
        <CardContent className="p-4 flex items-start gap-3">
          <div className="p-2 rounded-lg bg-amber-100 shrink-0">
            <EyeOff className="w-4 h-4 text-amber-800" />
          </div>
          <div>
            <p className="text-sm font-semibold text-amber-900">
              Sorties d’onglet détectées : {attempt.nb_sorties_onglet}
            </p>
            <p className="text-xs text-amber-800/80 mt-0.5">
              Compteur anti-triche (visibilité / sortie du plein écran). À titre
              indicatif — le test n’a pas été bloqué.
            </p>
          </div>
        </CardContent>
      </Card>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          <span className="flex-1">{error}</span>
          <button type="button" onClick={() => setError(null)}>
            <X className="w-4 h-4" />
          </button>
        </div>
      )}
      {success && (
        <div className="flex items-center gap-2 rounded-lg bg-flehub-green-light border border-flehub-green/30 px-4 py-3 text-sm text-flehub-green">
          <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
          <span className="flex-1">{success}</span>
          <button type="button" onClick={() => setSuccess(null)}>
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {tasks.map((task) => {
        const wordOk =
          task.nombreMots >= task.motsMin && task.nombreMots <= task.motsMax;
        const fondValue = parseScore(task.scoreFond);
        const formeValue = parseScore(task.scoreForme);
        return (
          <Card key={task.tacheId}>
            <CardContent className="p-6 space-y-5">
              <div className="flex items-center gap-2">
                <div className="p-2 rounded-lg bg-blue-50">
                  <PenLine className="w-4 h-4 text-blue-700" />
                </div>
                <h2 className="text-lg font-semibold text-gray-900">
                  Tâche {task.numero}
                </h2>
                <span className="text-xs text-gray-400">
                  {task.motsMin}–{task.motsMax} mots attendus
                </span>
              </div>

              <div className="rounded-lg bg-blue-50/60 border border-blue-100 px-4 py-3">
                <p className="text-xs font-medium text-blue-800 mb-1">
                  Consigne
                </p>
                <p className="text-sm text-gray-800 whitespace-pre-wrap">
                  {task.consigne}
                </p>
              </div>

              <div className="rounded-lg border border-gray-100 bg-gray-50 px-4 py-3 space-y-2">
                <div className="flex items-center justify-between gap-2">
                  <p className="text-xs font-medium text-gray-500">
                    Texte de l’apprenant
                  </p>
                  <span
                    className={cn(
                      'text-xs font-semibold tabular-nums',
                      wordOk ? 'text-flehub-green' : 'text-red-600'
                    )}
                  >
                    {task.nombreMots} mot{task.nombreMots === 1 ? '' : 's'}
                  </span>
                </div>
                <p className="text-sm text-gray-900 whitespace-pre-wrap leading-relaxed">
                  {task.texte.trim()
                    ? task.texte
                    : 'Aucun texte rédigé pour cette tâche.'}
                </p>
              </div>

              <div className="grid gap-5 sm:grid-cols-2">
                <div className="space-y-3 rounded-lg border border-gray-100 p-4">
                  <Label className="text-sm font-semibold text-gray-900">
                    Fond
                  </Label>
                  <div className="space-y-2">
                    <div className="flex items-center justify-between gap-2">
                      <span className="text-xs text-gray-500">Score / 10</span>
                      <Input
                        type="number"
                        min={0}
                        max={10}
                        step={1}
                        value={task.scoreFond}
                        onChange={(e) =>
                          updateTask(task.tacheId, {
                            scoreFond: e.target.value,
                          })
                        }
                        className="w-20 h-8 text-center"
                        disabled={saving || publishing}
                      />
                    </div>
                    <Slider
                      min={0}
                      max={10}
                      step={1}
                      value={[fondValue ?? 0]}
                      onValueChange={(v) =>
                        updateTask(task.tacheId, {
                          scoreFond: String(v[0] ?? 0),
                        })
                      }
                      disabled={saving || publishing}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor={`fond-c-${task.tacheId}`}>
                      Commentaire fond
                    </Label>
                    <Textarea
                      id={`fond-c-${task.tacheId}`}
                      value={task.commentaireFond}
                      onChange={(e) =>
                        updateTask(task.tacheId, {
                          commentaireFond: e.target.value,
                        })
                      }
                      rows={3}
                      placeholder="Points forts / axes d’amélioration (contenu, adéquation à la consigne…)"
                      disabled={saving || publishing}
                    />
                  </div>
                </div>

                <div className="space-y-3 rounded-lg border border-gray-100 p-4">
                  <Label className="text-sm font-semibold text-gray-900">
                    Forme
                  </Label>
                  <div className="space-y-2">
                    <div className="flex items-center justify-between gap-2">
                      <span className="text-xs text-gray-500">Score / 10</span>
                      <Input
                        type="number"
                        min={0}
                        max={10}
                        step={1}
                        value={task.scoreForme}
                        onChange={(e) =>
                          updateTask(task.tacheId, {
                            scoreForme: e.target.value,
                          })
                        }
                        className="w-20 h-8 text-center"
                        disabled={saving || publishing}
                      />
                    </div>
                    <Slider
                      min={0}
                      max={10}
                      step={1}
                      value={[formeValue ?? 0]}
                      onValueChange={(v) =>
                        updateTask(task.tacheId, {
                          scoreForme: String(v[0] ?? 0),
                        })
                      }
                      disabled={saving || publishing}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor={`forme-c-${task.tacheId}`}>
                      Commentaire forme
                    </Label>
                    <Textarea
                      id={`forme-c-${task.tacheId}`}
                      value={task.commentaireForme}
                      onChange={(e) =>
                        updateTask(task.tacheId, {
                          commentaireForme: e.target.value,
                        })
                      }
                      rows={3}
                      placeholder="Grammaire, orthographe, structure, registre…"
                      disabled={saving || publishing}
                    />
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        );
      })}

      <Card>
        <CardContent className="p-6 flex flex-col sm:flex-row sm:items-center gap-3 justify-between">
          <div>
            <p className="text-sm font-medium text-gray-900">
              {allScoresFilled
                ? 'Les 3 tâches sont notées — vous pouvez publier.'
                : 'Remplissez Fond et Forme (0–10) pour les 3 tâches afin de publier.'}
            </p>
            <p className="text-xs text-gray-500 mt-1">
              Le brouillon n’est pas visible par l’apprenant tant que la
              correction n’est pas publiée.
            </p>
          </div>
          <div className="flex flex-col sm:flex-row gap-2 shrink-0">
            <Button
              type="button"
              variant="outline"
              onClick={() => void handleSaveDraft()}
              disabled={saving || publishing}
            >
              {saving ? (
                <>
                  <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
                  Enregistrement…
                </>
              ) : (
                'Enregistrer le brouillon'
              )}
            </Button>
            <Button
              type="button"
              className="bg-blue-700 hover:bg-blue-800 text-white"
              onClick={() => void handlePublish()}
              disabled={!allScoresFilled || saving || publishing}
            >
              {publishing ? (
                <>
                  <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
                  Publication…
                </>
              ) : (
                'Publier la correction'
              )}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
