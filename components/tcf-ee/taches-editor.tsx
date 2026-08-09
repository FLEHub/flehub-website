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
import {
  AlertTriangle,
  ArrowLeft,
  CheckCircle2,
  Loader2,
  PenLine,
  X,
} from 'lucide-react';

const TASK_COUNT = 3;

const DEFAULT_WORD_RANGES: Record<
  1 | 2 | 3,
  { motsMin: string; motsMax: string }
> = {
  1: { motsMin: '60', motsMax: '120' },
  2: { motsMin: '120', motsMax: '150' },
  3: { motsMin: '150', motsMax: '180' },
};

interface TcfEeSession {
  id: string;
  titre: string;
  duree_minuteur: number;
  statut: 'brouillon' | 'publiee';
}

interface TacheForm {
  id?: string;
  numero: 1 | 2 | 3;
  consigne: string;
  motsMin: string;
  motsMax: string;
}

function emptyTasks(): TacheForm[] {
  return ([1, 2, 3] as const).map((numero) => ({
    numero,
    consigne: '',
    motsMin: DEFAULT_WORD_RANGES[numero].motsMin,
    motsMax: DEFAULT_WORD_RANGES[numero].motsMax,
  }));
}

export default function TcfEeTachesEditor() {
  const params = useParams();
  const router = useRouter();
  const sessionId = params.sessionId as string;
  const supabase = useMemo(() => createClient(), []);

  const [session, setSession] = useState<TcfEeSession | null>(null);
  const [tasks, setTasks] = useState<TacheForm[]>(emptyTasks);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [publishing, setPublishing] = useState(false);
  const [pageError, setPageError] = useState<string | null>(null);
  const [formError, setFormError] = useState<string | null>(null);
  const [formSuccess, setFormSuccess] = useState<string | null>(null);
  const [savedCount, setSavedCount] = useState(0);

  const loadData = useCallback(async () => {
    try {
      setPageError(null);
      const { data: sessionData, error: sessionError } = await supabase
        .from('tcf_ee_sessions')
        .select('id, titre, duree_minuteur, statut')
        .eq('id', sessionId)
        .maybeSingle();

      if (sessionError) throw sessionError;
      if (!sessionData) {
        setPageError('Séance introuvable.');
        setSession(null);
        return;
      }
      setSession(sessionData as TcfEeSession);

      const { data: tachesData, error: tachesError } = await supabase
        .from('tcf_ee_taches')
        .select('id, numero, consigne, mots_min, mots_max')
        .eq('session_id', sessionId)
        .order('numero', { ascending: true });

      if (tachesError) throw tachesError;

      const next = emptyTasks();
      for (const row of tachesData ?? []) {
        const numero = row.numero as 1 | 2 | 3;
        if (numero < 1 || numero > 3) continue;
        const idx = numero - 1;
        next[idx] = {
          id: row.id,
          numero,
          consigne: row.consigne ?? '',
          motsMin: String(row.mots_min ?? DEFAULT_WORD_RANGES[numero].motsMin),
          motsMax: String(row.mots_max ?? DEFAULT_WORD_RANGES[numero].motsMax),
        };
      }
      setTasks(next);
      setSavedCount(
        (tachesData ?? []).filter(
          (t) => t.consigne && String(t.consigne).trim().length > 0
        ).length
      );
    } catch (err) {
      console.error(err);
      setPageError(
        err instanceof Error
          ? err.message
          : 'Impossible de charger la séance.'
      );
    } finally {
      setLoading(false);
    }
  }, [sessionId, supabase]);

  useEffect(() => {
    if (sessionId) void loadData();
  }, [sessionId, loadData]);

  function updateTask(
    numero: 1 | 2 | 3,
    patch: Partial<Omit<TacheForm, 'numero'>>
  ) {
    setTasks((prev) =>
      prev.map((t) => (t.numero === numero ? { ...t, ...patch } : t))
    );
    setFormSuccess(null);
  }

  function validateTasks():
    | { ok: true; rows: Array<{
        session_id: string;
        numero: number;
        consigne: string;
        mots_min: number;
        mots_max: number;
      }> }
    | { ok: false; message: string } {
    const rows = [];
    for (const task of tasks) {
      const consigne = task.consigne.trim();
      const motsMin = Number.parseInt(task.motsMin, 10);
      const motsMax = Number.parseInt(task.motsMax, 10);

      if (!consigne) {
        return {
          ok: false,
          message: `La consigne de la tâche ${task.numero} est obligatoire.`,
        };
      }
      if (!Number.isFinite(motsMin) || motsMin <= 0) {
        return {
          ok: false,
          message: `Le nombre de mots minimum de la tâche ${task.numero} doit être un entier positif.`,
        };
      }
      if (!Number.isFinite(motsMax) || motsMax <= 0) {
        return {
          ok: false,
          message: `Le nombre de mots maximum de la tâche ${task.numero} doit être un entier positif.`,
        };
      }
      if (motsMax < motsMin) {
        return {
          ok: false,
          message: `Pour la tâche ${task.numero}, le maximum de mots doit être ≥ au minimum.`,
        };
      }

      rows.push({
        session_id: sessionId,
        numero: task.numero,
        consigne,
        mots_min: motsMin,
        mots_max: motsMax,
      });
    }
    return { ok: true, rows };
  }

  const allTasksReady = useMemo(() => {
    return tasks.every((t) => {
      const consigne = t.consigne.trim();
      const motsMin = Number.parseInt(t.motsMin, 10);
      const motsMax = Number.parseInt(t.motsMax, 10);
      return (
        consigne.length > 0 &&
        Number.isFinite(motsMin) &&
        motsMin > 0 &&
        Number.isFinite(motsMax) &&
        motsMax >= motsMin
      );
    });
  }, [tasks]);

  const canPublish =
    Boolean(session) &&
    session?.statut !== 'publiee' &&
    savedCount >= TASK_COUNT &&
    allTasksReady;

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setFormError(null);
    setFormSuccess(null);

    const validated = validateTasks();
    if (!validated.ok) {
      setFormError(validated.message);
      return;
    }

    setSaving(true);
    try {
      const { error } = await supabase.from('tcf_ee_taches').upsert(
        validated.rows,
        { onConflict: 'session_id,numero' }
      );
      if (error) throw error;

      setFormSuccess('Les 3 tâches ont été enregistrées.');
      await loadData();
      router.refresh();
    } catch (err) {
      console.error(err);
      setFormError(
        err instanceof Error
          ? err.message
          : 'Impossible d’enregistrer les tâches.'
      );
    } finally {
      setSaving(false);
    }
  }

  async function handlePublish() {
    if (!canPublish) return;
    setPublishing(true);
    setFormError(null);
    try {
      // S’assurer que le dernier état du formulaire est bien en base
      const validated = validateTasks();
      if (!validated.ok) {
        setFormError(validated.message);
        return;
      }
      const { error: upsertError } = await supabase
        .from('tcf_ee_taches')
        .upsert(validated.rows, { onConflict: 'session_id,numero' });
      if (upsertError) throw upsertError;

      const { error } = await supabase
        .from('tcf_ee_sessions')
        .update({ statut: 'publiee' })
        .eq('id', sessionId);
      if (error) throw error;

      setSession((prev) => (prev ? { ...prev, statut: 'publiee' } : prev));
      setFormSuccess('Séance publiée. Les apprenants peuvent y accéder.');
      await loadData();
      router.refresh();
    } catch (err) {
      console.error(err);
      setFormError(
        err instanceof Error
          ? err.message
          : 'Impossible de publier la séance.'
      );
    } finally {
      setPublishing(false);
    }
  }

  return (
    <div className="p-6 space-y-6 max-w-4xl mx-auto">
      <div>
        <Link
          href="/dashboard/teacher/preparation"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour à Préparation
        </Link>
        {loading ? (
          <div className="space-y-2">
            <Skeleton className="h-8 w-72" />
            <Skeleton className="h-4 w-48" />
          </div>
        ) : session ? (
          <>
            <div className="flex items-center justify-between gap-3 flex-wrap">
              <div className="flex items-center gap-2 flex-wrap">
                <h1 className="text-2xl font-bold text-gray-900">
                  {session.titre}
                </h1>
                <Badge
                  variant="outline"
                  className="bg-blue-100 text-blue-800 border-blue-200"
                >
                  EE
                </Badge>
                <Badge
                  className={
                    session.statut === 'publiee'
                      ? 'bg-flehub-green-light text-flehub-green border-flehub-green'
                      : 'bg-gray-100 text-gray-600 border-gray-300'
                  }
                  variant="outline"
                >
                  {session.statut === 'publiee' ? 'Publiée' : 'Brouillon'}
                </Badge>
              </div>
              <div className="rounded-lg bg-blue-50 px-3 py-1.5 text-sm font-semibold text-blue-800">
                {savedCount}/{TASK_COUNT} tâches
              </div>
            </div>
            <p className="text-sm text-gray-500 mt-1">
              {session.duree_minuteur} min · 3 tâches d’expression écrite
            </p>
          </>
        ) : (
          <h1 className="text-2xl font-bold text-gray-900">Séance TCF EE</h1>
        )}
      </div>

      {pageError && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {pageError}
        </div>
      )}

      {!loading && session && (
        <form onSubmit={handleSave} className="space-y-4">
          {formError && (
            <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
              <AlertTriangle className="w-4 h-4 flex-shrink-0" />
              <span className="flex-1">{formError}</span>
              <button type="button" onClick={() => setFormError(null)}>
                <X className="w-4 h-4" />
              </button>
            </div>
          )}
          {formSuccess && (
            <div className="flex items-center gap-2 rounded-lg bg-flehub-green-light border border-flehub-green/30 px-4 py-3 text-sm text-flehub-green">
              <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
              <span className="flex-1">{formSuccess}</span>
              <button type="button" onClick={() => setFormSuccess(null)}>
                <X className="w-4 h-4" />
              </button>
            </div>
          )}

          {tasks.map((task) => (
            <Card key={task.numero}>
              <CardContent className="p-6 space-y-4">
                <div className="flex items-center gap-2">
                  <div className="p-2 rounded-lg bg-blue-50">
                    <PenLine className="w-4 h-4 text-blue-700" />
                  </div>
                  <h2 className="text-lg font-semibold text-gray-900">
                    Tâche {task.numero}
                  </h2>
                  <span className="text-xs text-gray-400">
                    Suggestion TCF : {DEFAULT_WORD_RANGES[task.numero].motsMin}–
                    {DEFAULT_WORD_RANGES[task.numero].motsMax} mots
                  </span>
                </div>

                <div className="space-y-2">
                  <Label htmlFor={`consigne-${task.numero}`}>Consigne</Label>
                  <Textarea
                    id={`consigne-${task.numero}`}
                    value={task.consigne}
                    onChange={(e) =>
                      updateTask(task.numero, { consigne: e.target.value })
                    }
                    rows={5}
                    placeholder={`Sujet / consigne complète de la tâche ${task.numero}`}
                    disabled={saving || publishing}
                    required
                  />
                </div>

                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor={`mots-min-${task.numero}`}>
                      Nombre de mots minimum
                    </Label>
                    <Input
                      id={`mots-min-${task.numero}`}
                      type="number"
                      min={1}
                      step={1}
                      value={task.motsMin}
                      onChange={(e) =>
                        updateTask(task.numero, { motsMin: e.target.value })
                      }
                      disabled={saving || publishing}
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor={`mots-max-${task.numero}`}>
                      Nombre de mots maximum
                    </Label>
                    <Input
                      id={`mots-max-${task.numero}`}
                      type="number"
                      min={1}
                      step={1}
                      value={task.motsMax}
                      onChange={(e) =>
                        updateTask(task.numero, { motsMax: e.target.value })
                      }
                      disabled={saving || publishing}
                      required
                    />
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}

          <div className="flex flex-col sm:flex-row sm:items-center gap-3 justify-between">
            <Button
              type="submit"
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              disabled={saving || publishing}
            >
              {saving ? (
                <>
                  <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
                  Enregistrement…
                </>
              ) : (
                'Enregistrer les tâches'
              )}
            </Button>

            {session.statut === 'publiee' ? (
              <p className="text-sm text-gray-500">
                Cette séance est déjà publiée. Vous pouvez encore modifier les
                consignes.
              </p>
            ) : canPublish ? (
              <Button
                type="button"
                className="bg-blue-700 hover:bg-blue-800 text-white"
                onClick={() => void handlePublish()}
                disabled={publishing || saving}
              >
                {publishing ? (
                  <>
                    <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
                    Publication…
                  </>
                ) : (
                  'Publier la séance'
                )}
              </Button>
            ) : (
              <p className="text-sm text-gray-500">
                Enregistrez les 3 tâches (consignes + plages de mots) pour
                pouvoir publier.
              </p>
            )}
          </div>
        </form>
      )}
    </div>
  );
}
