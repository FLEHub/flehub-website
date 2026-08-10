'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  AlertTriangle,
  ArrowLeft,
  CheckCircle2,
  Loader2,
  Mic,
  Pencil,
  Plus,
  Trash2,
  X,
} from 'lucide-react';

type TacheNumero = 2 | 3;

interface TcfEoSession {
  id: string;
  titre: string;
  statut: 'brouillon' | 'publiee';
}

interface EoSujet {
  id: string;
  session_id: string;
  tache: TacheNumero;
  enonce: string;
  created_at: string;
}

export default function TcfEoSujetsEditor() {
  const params = useParams();
  const router = useRouter();
  const sessionId = params.sessionId as string;
  const supabase = useMemo(() => createClient(), []);

  const [session, setSession] = useState<TcfEoSession | null>(null);
  const [sujets, setSujets] = useState<EoSujet[]>([]);
  const [loading, setLoading] = useState(true);
  const [pageError, setPageError] = useState<string | null>(null);
  const [formError, setFormError] = useState<string | null>(null);
  const [formSuccess, setFormSuccess] = useState<string | null>(null);

  const [draft2, setDraft2] = useState('');
  const [draft3, setDraft3] = useState('');
  const [addingTache, setAddingTache] = useState<TacheNumero | null>(null);
  const [publishing, setPublishing] = useState(false);

  const [editingId, setEditingId] = useState<string | null>(null);
  const [editText, setEditText] = useState('');
  const [savingEdit, setSavingEdit] = useState(false);

  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [deleting, setDeleting] = useState(false);

  const loadData = useCallback(async () => {
    try {
      setPageError(null);
      const { data: sessionData, error: sessionError } = await supabase
        .from('tcf_eo_sessions')
        .select('id, titre, statut')
        .eq('id', sessionId)
        .maybeSingle();

      if (sessionError) throw sessionError;
      if (!sessionData) {
        setPageError('Séance introuvable.');
        setSession(null);
        return;
      }
      setSession(sessionData as TcfEoSession);

      const { data: sujetsData, error: sujetsError } = await supabase
        .from('tcf_eo_sujets')
        .select('id, session_id, tache, enonce, created_at')
        .eq('session_id', sessionId)
        .order('created_at', { ascending: true });

      if (sujetsError) throw sujetsError;
      setSujets((sujetsData as EoSujet[]) ?? []);
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

  const sujetsTache2 = useMemo(
    () => sujets.filter((s) => s.tache === 2),
    [sujets]
  );
  const sujetsTache3 = useMemo(
    () => sujets.filter((s) => s.tache === 3),
    [sujets]
  );

  const canPublish =
    Boolean(session) &&
    session?.statut !== 'publiee' &&
    sujetsTache2.length >= 1 &&
    sujetsTache3.length >= 1;

  async function handleAdd(tache: TacheNumero) {
    const enonce = (tache === 2 ? draft2 : draft3).trim();
    setFormError(null);
    setFormSuccess(null);

    if (!enonce) {
      setFormError(`L’énoncé du sujet (tâche ${tache}) est obligatoire.`);
      return;
    }

    setAddingTache(tache);
    try {
      const { error } = await supabase.from('tcf_eo_sujets').insert({
        session_id: sessionId,
        tache,
        enonce,
      });
      if (error) throw error;

      if (tache === 2) setDraft2('');
      else setDraft3('');
      setFormSuccess(`Sujet ajouté à la tâche ${tache}.`);
      await loadData();
    } catch (err) {
      console.error(err);
      setFormError(
        err instanceof Error
          ? err.message
          : 'Impossible d’ajouter le sujet.'
      );
    } finally {
      setAddingTache(null);
    }
  }

  function startEdit(sujet: EoSujet) {
    setEditingId(sujet.id);
    setEditText(sujet.enonce);
    setFormError(null);
    setFormSuccess(null);
  }

  async function handleSaveEdit() {
    if (!editingId) return;
    const enonce = editText.trim();
    if (!enonce) {
      setFormError('L’énoncé ne peut pas être vide.');
      return;
    }

    setSavingEdit(true);
    setFormError(null);
    try {
      const { error } = await supabase
        .from('tcf_eo_sujets')
        .update({ enonce })
        .eq('id', editingId)
        .eq('session_id', sessionId);
      if (error) throw error;

      setEditingId(null);
      setEditText('');
      setFormSuccess('Sujet mis à jour.');
      await loadData();
    } catch (err) {
      console.error(err);
      setFormError(
        err instanceof Error
          ? err.message
          : 'Impossible de modifier le sujet.'
      );
    } finally {
      setSavingEdit(false);
    }
  }

  async function handleDelete() {
    if (!deleteId) return;
    setDeleting(true);
    setFormError(null);
    try {
      const { error } = await supabase
        .from('tcf_eo_sujets')
        .delete()
        .eq('id', deleteId)
        .eq('session_id', sessionId);
      if (error) throw error;

      if (editingId === deleteId) {
        setEditingId(null);
        setEditText('');
      }
      setDeleteId(null);
      setFormSuccess('Sujet supprimé.');
      await loadData();
    } catch (err) {
      console.error(err);
      setFormError(
        err instanceof Error
          ? err.message
          : 'Impossible de supprimer le sujet.'
      );
    } finally {
      setDeleting(false);
    }
  }

  async function handlePublish() {
    if (!canPublish) return;
    setPublishing(true);
    setFormError(null);
    try {
      const { error } = await supabase
        .from('tcf_eo_sessions')
        .update({ statut: 'publiee' })
        .eq('id', sessionId);
      if (error) throw error;

      setSession((prev) => (prev ? { ...prev, statut: 'publiee' } : prev));
      setFormSuccess(
        'Séance publiée. Les apprenants peuvent consulter les sujets.'
      );
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

  function renderSection(tache: TacheNumero) {
    const list = tache === 2 ? sujetsTache2 : sujetsTache3;
    const draft = tache === 2 ? draft2 : draft3;
    const setDraft = tache === 2 ? setDraft2 : setDraft3;
    const adding = addingTache === tache;

    return (
      <Card className="h-full">
        <CardContent className="p-5 space-y-4">
          <div className="flex items-center justify-between gap-2">
            <div className="flex items-center gap-2">
              <div className="p-2 rounded-lg bg-violet-50">
                <Mic className="w-4 h-4 text-violet-700" />
              </div>
              <div>
                <h2 className="text-lg font-semibold text-gray-900">
                  Sujets — Tâche {tache}
                </h2>
                <p className="text-xs text-gray-500">
                  {list.length} sujet{list.length === 1 ? '' : 's'}
                </p>
              </div>
            </div>
          </div>

          <ul className="space-y-2">
            {list.length === 0 ? (
              <li className="rounded-lg border border-dashed border-gray-200 px-3 py-4 text-sm text-gray-400 text-center">
                Aucun sujet pour la tâche {tache}
              </li>
            ) : (
              list.map((sujet, index) => (
                <li
                  key={sujet.id}
                  className="rounded-lg border border-gray-100 bg-gray-50/80 px-3 py-3 space-y-2"
                >
                  {editingId === sujet.id ? (
                    <>
                      <Textarea
                        value={editText}
                        onChange={(e) => setEditText(e.target.value)}
                        rows={4}
                        disabled={savingEdit}
                        className="bg-white"
                      />
                      <div className="flex gap-2 justify-end">
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          disabled={savingEdit}
                          onClick={() => {
                            setEditingId(null);
                            setEditText('');
                          }}
                        >
                          Annuler
                        </Button>
                        <Button
                          type="button"
                          size="sm"
                          className="bg-violet-700 hover:bg-violet-800 text-white"
                          disabled={savingEdit || !editText.trim()}
                          onClick={() => void handleSaveEdit()}
                        >
                          {savingEdit ? (
                            <Loader2 className="w-4 h-4 animate-spin" />
                          ) : (
                            'Enregistrer'
                          )}
                        </Button>
                      </div>
                    </>
                  ) : (
                    <div className="flex items-start gap-2">
                      <span className="inline-flex h-6 w-6 shrink-0 items-center justify-center rounded-md bg-white border border-violet-100 text-xs font-semibold text-violet-800">
                        {index + 1}
                      </span>
                      <p className="flex-1 text-sm text-gray-800 whitespace-pre-wrap">
                        {sujet.enonce}
                      </p>
                      <div className="flex gap-1 shrink-0">
                        <Button
                          type="button"
                          variant="ghost"
                          size="icon"
                          className="h-8 w-8 text-gray-500 hover:text-violet-700"
                          onClick={() => startEdit(sujet)}
                          disabled={addingTache !== null || publishing}
                        >
                          <Pencil className="w-3.5 h-3.5" />
                        </Button>
                        <Button
                          type="button"
                          variant="ghost"
                          size="icon"
                          className="h-8 w-8 text-gray-500 hover:text-red-600"
                          onClick={() => setDeleteId(sujet.id)}
                          disabled={addingTache !== null || publishing}
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </Button>
                      </div>
                    </div>
                  )}
                </li>
              ))
            )}
          </ul>

          <div className="space-y-2 pt-1 border-t border-gray-100">
            <Label htmlFor={`enonce-${tache}`}>Nouveau sujet</Label>
            <Textarea
              id={`enonce-${tache}`}
              value={draft}
              onChange={(e) => setDraft(e.target.value)}
              rows={4}
              placeholder={`Énoncé complet du sujet (tâche ${tache})`}
              disabled={adding || publishing}
              className="bg-white"
            />
            <Button
              type="button"
              className="w-full bg-violet-700 hover:bg-violet-800 text-white"
              disabled={adding || publishing || !draft.trim()}
              onClick={() => void handleAdd(tache)}
            >
              {adding ? (
                <>
                  <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
                  Ajout…
                </>
              ) : (
                <>
                  <Plus className="w-4 h-4 mr-1.5" />
                  Ajouter
                </>
              )}
            </Button>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="p-6 space-y-6 max-w-6xl mx-auto">
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
                  className="bg-violet-100 text-violet-800 border-violet-200"
                >
                  EO
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
              <div className="rounded-lg bg-violet-50 px-3 py-1.5 text-sm font-semibold text-violet-800">
                {sujetsTache2.length} + {sujetsTache3.length} sujets
              </div>
            </div>
            <p className="text-sm text-gray-500 mt-1">
              Banque de sujets pour préparer un rendez-vous d’expression orale
              (tâches 2 et 3)
            </p>
          </>
        ) : (
          <h1 className="text-2xl font-bold text-gray-900">Séance TCF EO</h1>
        )}
      </div>

      {pageError && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {pageError}
        </div>
      )}

      {!loading && session && (
        <>
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

          <div className="grid gap-4 lg:grid-cols-2">
            {renderSection(2)}
            {renderSection(3)}
          </div>

          <Card>
            <CardContent className="p-6 flex flex-col sm:flex-row sm:items-center gap-4 justify-between">
              <div>
                <h2 className="text-lg font-semibold text-gray-900">
                  {session.statut === 'publiee'
                    ? 'Séance publiée'
                    : canPublish
                      ? 'Prêt à publier'
                      : 'Publication'}
                </h2>
                <p className="text-sm text-gray-500 mt-1">
                  {session.statut === 'publiee'
                    ? 'Les apprenants peuvent consulter les sujets. Vous pouvez encore en ajouter.'
                    : canPublish
                      ? 'Au moins 1 sujet par tâche — vous pouvez publier la séance.'
                      : `Ajoutez au moins 1 sujet en tâche 2 et 1 en tâche 3 (actuellement ${sujetsTache2.length} / ${sujetsTache3.length}).`}
                </p>
              </div>
              {session.statut !== 'publiee' && (
                <Button
                  type="button"
                  className="bg-violet-700 hover:bg-violet-800 text-white shrink-0"
                  disabled={!canPublish || publishing || addingTache !== null}
                  onClick={() => void handlePublish()}
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
              )}
            </CardContent>
          </Card>
        </>
      )}

      <Dialog
        open={Boolean(deleteId)}
        onOpenChange={(open) => !open && setDeleteId(null)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Supprimer ce sujet ?</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-gray-500">
            Cette action est définitive. Le sujet sera retiré de la banque.
          </p>
          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              disabled={deleting}
              onClick={() => setDeleteId(null)}
            >
              Annuler
            </Button>
            <Button
              type="button"
              className="bg-red-600 hover:bg-red-700 text-white"
              disabled={deleting}
              onClick={() => void handleDelete()}
            >
              {deleting ? (
                <>
                  <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
                  Suppression…
                </>
              ) : (
                'Supprimer'
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
