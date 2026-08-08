'use client';

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
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
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
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
  Headphones,
  Loader2,
  Pencil,
  Trash2,
  Upload,
  X,
} from 'lucide-react';
import { cn } from '@/lib/utils';

const MAX_QUESTIONS = 40;
const AUDIO_BUCKET = 'tcf-co-audios';
const MAX_AUDIO_BYTES = 10 * 1024 * 1024;
const ACCEPTED_AUDIO_EXT = ['mp3', 'wav', 'm4a'];
const ACCEPTED_AUDIO_MIME = [
  'audio/mpeg',
  'audio/mp3',
  'audio/wav',
  'audio/x-wav',
  'audio/wave',
  'audio/mp4',
  'audio/m4a',
  'audio/x-m4a',
];

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';
type BonneReponse = 'a' | 'b' | 'c' | 'd';

interface TcfCoSession {
  id: string;
  titre: string;
  duree_minuteur: number;
  statut: 'brouillon' | 'publiee';
}

interface TcfCoQuestion {
  id: string;
  session_id: string;
  ordre: number;
  niveau: CEFR;
  audio_url: string;
  question_texte: string;
  choix_a: string;
  choix_b: string;
  choix_c: string;
  choix_d: string;
  bonne_reponse: BonneReponse;
  created_at: string;
}

interface QuestionFormState {
  niveau: CEFR | '';
  questionTexte: string;
  choixA: string;
  choixB: string;
  choixC: string;
  choixD: string;
  bonneReponse: BonneReponse | '';
  audioPath: string;
  audioPreviewUrl: string;
}

const emptyForm = (): QuestionFormState => ({
  niveau: '',
  questionTexte: '',
  choixA: '',
  choixB: '',
  choixC: '',
  choixD: '',
  bonneReponse: '',
  audioPath: '',
  audioPreviewUrl: '',
});

const cefrLevels: CEFR[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

function isAcceptedAudio(file: File): boolean {
  const ext = file.name.split('.').pop()?.toLowerCase() ?? '';
  if (ACCEPTED_AUDIO_EXT.includes(ext)) return true;
  return ACCEPTED_AUDIO_MIME.includes(file.type);
}

function truncate(text: string, max = 72): string {
  const clean = text.trim().replace(/\s+/g, ' ');
  if (clean.length <= max) return clean;
  return `${clean.slice(0, max - 1)}…`;
}

export default function TcfCoQuestionsEditor() {
  const params = useParams();
  const router = useRouter();
  const sessionId = params.sessionId as string;
  const supabase = useMemo(() => createClient(), []);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [session, setSession] = useState<TcfCoSession | null>(null);
  const [questions, setQuestions] = useState<TcfCoQuestion[]>([]);
  const [loading, setLoading] = useState(true);
  const [pageError, setPageError] = useState<string | null>(null);

  const [form, setForm] = useState<QuestionFormState>(emptyForm);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [formError, setFormError] = useState<string | null>(null);
  const [formSuccess, setFormSuccess] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [publishing, setPublishing] = useState(false);
  const [dragOver, setDragOver] = useState(false);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [deleting, setDeleting] = useState(false);

  const loadSignedUrl = useCallback(
    async (path: string): Promise<string> => {
      if (!path) return '';
      if (path.startsWith('blob:') || path.startsWith('http')) return path;
      const { data, error } = await supabase.storage
        .from(AUDIO_BUCKET)
        .createSignedUrl(path, 3600);
      if (error) throw error;
      return data.signedUrl;
    },
    [supabase]
  );

  const loadData = useCallback(async () => {
    try {
      setPageError(null);
      const { data: sessionData, error: sessionError } = await supabase
        .from('tcf_co_sessions')
        .select('id, titre, duree_minuteur, statut')
        .eq('id', sessionId)
        .maybeSingle();

      if (sessionError) throw sessionError;
      if (!sessionData) {
        setPageError('Séance introuvable.');
        setSession(null);
        setQuestions([]);
        return;
      }

      setSession(sessionData as TcfCoSession);

      const { data: questionsData, error: questionsError } = await supabase
        .from('tcf_co_questions')
        .select(
          'id, session_id, ordre, niveau, audio_url, question_texte, choix_a, choix_b, choix_c, choix_d, bonne_reponse, created_at'
        )
        .eq('session_id', sessionId)
        .order('ordre', { ascending: true });

      if (questionsError) throw questionsError;
      setQuestions((questionsData as TcfCoQuestion[]) ?? []);
    } catch (err) {
      console.error(err);
      setPageError('Impossible de charger la séance.');
    } finally {
      setLoading(false);
    }
  }, [sessionId, supabase]);

  useEffect(() => {
    if (sessionId) loadData();
  }, [sessionId, loadData]);

  const nextOrdre = questions.length + 1;
  const isFull = questions.length >= MAX_QUESTIONS;
  const counterLabel = editingId
    ? questions.find((q) => q.id === editingId)?.ordre ?? nextOrdre
    : Math.min(nextOrdre, MAX_QUESTIONS);

  function resetForm() {
    if (form.audioPreviewUrl.startsWith('blob:')) {
      URL.revokeObjectURL(form.audioPreviewUrl);
    }
    setForm(emptyForm());
    setEditingId(null);
    setFormError(null);
    if (fileInputRef.current) fileInputRef.current.value = '';
  }

  async function handleAudioFile(file: File | null | undefined) {
    if (!file) return;
    setFormError(null);
    setFormSuccess(null);

    if (!isAcceptedAudio(file)) {
      setFormError('Formats acceptés : mp3, wav, m4a.');
      return;
    }
    if (file.size > MAX_AUDIO_BYTES) {
      setFormError('Le fichier audio ne doit pas dépasser 10 Mo.');
      return;
    }

    const localUrl = URL.createObjectURL(file);
    if (form.audioPreviewUrl.startsWith('blob:')) {
      URL.revokeObjectURL(form.audioPreviewUrl);
    }
    setForm((prev) => ({ ...prev, audioPreviewUrl: localUrl }));
    setUploading(true);

    try {
      const ext = file.name.split('.').pop()?.toLowerCase() || 'mp3';
      const path = `${sessionId}/${crypto.randomUUID()}.${ext}`;
      const { error: uploadError } = await supabase.storage
        .from(AUDIO_BUCKET)
        .upload(path, file, {
          upsert: false,
          contentType: file.type || undefined,
        });
      if (uploadError) throw uploadError;

      const signed = await loadSignedUrl(path);
      if (localUrl.startsWith('blob:')) URL.revokeObjectURL(localUrl);
      setForm((prev) => ({
        ...prev,
        audioPath: path,
        audioPreviewUrl: signed,
      }));
    } catch (err) {
      console.error(err);
      setFormError(
        err instanceof Error
          ? err.message
          : 'Échec de l’upload audio. Réessayez.'
      );
      setForm((prev) => ({ ...prev, audioPath: '', audioPreviewUrl: '' }));
    } finally {
      setUploading(false);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  }

  async function startEdit(question: TcfCoQuestion) {
    setFormError(null);
    setFormSuccess(null);
    setEditingId(question.id);
    let preview = '';
    try {
      preview = await loadSignedUrl(question.audio_url);
    } catch (err) {
      console.error(err);
    }
    setForm({
      niveau: question.niveau,
      questionTexte: question.question_texte,
      choixA: question.choix_a,
      choixB: question.choix_b,
      choixC: question.choix_c,
      choixD: question.choix_d,
      bonneReponse: question.bonne_reponse,
      audioPath: question.audio_url,
      audioPreviewUrl: preview,
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  async function renumberQuestions(list: TcfCoQuestion[]) {
    const sorted = [...list].sort((a, b) => a.ordre - b.ordre);
    // Deux passes pour éviter les conflits sur UNIQUE(session_id, ordre)
    for (let i = 0; i < sorted.length; i++) {
      const { error } = await supabase
        .from('tcf_co_questions')
        .update({ ordre: 1000 + i })
        .eq('id', sorted[i].id);
      if (error) throw error;
    }
    for (let i = 0; i < sorted.length; i++) {
      const { error } = await supabase
        .from('tcf_co_questions')
        .update({ ordre: i + 1 })
        .eq('id', sorted[i].id);
      if (error) throw error;
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setFormError(null);
    setFormSuccess(null);

    const questionTexte = form.questionTexte.trim();
    const choixA = form.choixA.trim();
    const choixB = form.choixB.trim();
    const choixC = form.choixC.trim();
    const choixD = form.choixD.trim();

    if (!form.audioPath) {
      setFormError('Uploadez un fichier audio avant de valider.');
      return;
    }
    if (!form.niveau) {
      setFormError('Choisissez le niveau de la question.');
      return;
    }
    if (!questionTexte) {
      setFormError('Le texte de la question est obligatoire.');
      return;
    }
    if (!choixA || !choixB || !choixC || !choixD) {
      setFormError('Les quatre choix de réponse sont obligatoires.');
      return;
    }
    if (!form.bonneReponse) {
      setFormError('Indiquez la bonne réponse.');
      return;
    }
    if (!editingId && isFull) {
      setFormError('Cette séance contient déjà 40 questions.');
      return;
    }

    setSaving(true);
    try {
      if (editingId) {
        const { error } = await supabase
          .from('tcf_co_questions')
          .update({
            niveau: form.niveau,
            audio_url: form.audioPath,
            question_texte: questionTexte,
            choix_a: choixA,
            choix_b: choixB,
            choix_c: choixC,
            choix_d: choixD,
            bonne_reponse: form.bonneReponse,
          })
          .eq('id', editingId)
          .eq('session_id', sessionId);
        if (error) throw error;
        setFormSuccess('Question mise à jour.');
      } else {
        const ordre =
          questions.reduce((max, q) => Math.max(max, q.ordre), 0) + 1;
        if (ordre > MAX_QUESTIONS) {
          throw new Error('Cette séance contient déjà 40 questions.');
        }
        const { error } = await supabase.from('tcf_co_questions').insert({
          session_id: sessionId,
          ordre,
          niveau: form.niveau,
          audio_url: form.audioPath,
          question_texte: questionTexte,
          choix_a: choixA,
          choix_b: choixB,
          choix_c: choixC,
          choix_d: choixD,
          bonne_reponse: form.bonneReponse,
        });
        if (error) throw error;
        setFormSuccess(`Question ${ordre} ajoutée.`);
      }

      resetForm();
      await loadData();
    } catch (err) {
      console.error(err);
      setFormError(
        err instanceof Error
          ? err.message
          : 'Impossible d’enregistrer la question.'
      );
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete() {
    if (!deleteId) return;
    setDeleting(true);
    try {
      const target = questions.find((q) => q.id === deleteId);
      const { error } = await supabase
        .from('tcf_co_questions')
        .delete()
        .eq('id', deleteId)
        .eq('session_id', sessionId);
      if (error) throw error;

      if (target?.audio_url && !target.audio_url.startsWith('http')) {
        await supabase.storage.from(AUDIO_BUCKET).remove([target.audio_url]);
      }

      if (editingId === deleteId) resetForm();

      const remaining = questions.filter((q) => q.id !== deleteId);
      await renumberQuestions(remaining);
      setDeleteId(null);
      await loadData();
      setFormSuccess('Question supprimée.');
    } catch (err) {
      console.error(err);
      setFormError(
        err instanceof Error
          ? err.message
          : 'Impossible de supprimer la question.'
      );
    } finally {
      setDeleting(false);
    }
  }

  async function handlePublish() {
    if (questions.length < MAX_QUESTIONS) return;
    setPublishing(true);
    setFormError(null);
    try {
      const { error } = await supabase
        .from('tcf_co_sessions')
        .update({ statut: 'publiee' })
        .eq('id', sessionId);
      if (error) throw error;
      setSession((prev) => (prev ? { ...prev, statut: 'publiee' } : prev));
      setFormSuccess('Séance publiée. Les apprenants peuvent y accéder.');
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

  const showForm = Boolean(session) && (!isFull || editingId);

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
              <div className="rounded-lg bg-flehub-green-light px-3 py-1.5 text-sm font-semibold text-flehub-green">
                Question {counterLabel}/{MAX_QUESTIONS}
              </div>
            </div>
            <p className="text-sm text-gray-500 mt-1">
              {session.duree_minuteur} min · {questions.length} question
              {questions.length === 1 ? '' : 's'} enregistrée
              {questions.length === 1 ? '' : 's'}
            </p>
          </>
        ) : (
          <h1 className="text-2xl font-bold text-gray-900">Questions TCF CO</h1>
        )}
      </div>

      {pageError && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {pageError}
        </div>
      )}

      {(formError || formSuccess) && (
        <div
          className={cn(
            'flex items-center gap-2 rounded-lg border px-4 py-3 text-sm',
            formError
              ? 'bg-red-50 border-red-200 text-red-700'
              : 'bg-flehub-green-light border-flehub-green/30 text-flehub-green'
          )}
        >
          {formError ? (
            <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          ) : (
            <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
          )}
          <span className="flex-1">{formError ?? formSuccess}</span>
          <button
            type="button"
            onClick={() => {
              setFormError(null);
              setFormSuccess(null);
            }}
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {showForm && (
        <Card>
          <CardContent className="p-6">
            <form onSubmit={handleSubmit} className="space-y-5">
              <div className="flex items-center justify-between gap-2">
                <h2 className="text-lg font-semibold text-gray-900">
                  {editingId
                    ? `Modifier la question ${counterLabel}`
                    : `Nouvelle question ${counterLabel}`}
                </h2>
                {editingId && (
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={resetForm}
                    disabled={saving || uploading}
                  >
                    Annuler la modification
                  </Button>
                )}
              </div>

              <div className="space-y-2">
                <Label>Fichier audio</Label>
                <div
                  className={cn(
                    'rounded-xl border-2 border-dashed px-4 py-8 text-center transition-colors cursor-pointer',
                    dragOver
                      ? 'border-flehub-green bg-flehub-green-light/50'
                      : 'border-gray-200 bg-gray-50 hover:border-flehub-green/50'
                  )}
                  onClick={() => !uploading && fileInputRef.current?.click()}
                  onDragEnter={(e) => {
                    e.preventDefault();
                    setDragOver(true);
                  }}
                  onDragOver={(e) => {
                    e.preventDefault();
                    setDragOver(true);
                  }}
                  onDragLeave={(e) => {
                    e.preventDefault();
                    setDragOver(false);
                  }}
                  onDrop={(e) => {
                    e.preventDefault();
                    setDragOver(false);
                    void handleAudioFile(e.dataTransfer.files?.[0]);
                  }}
                >
                  <input
                    ref={fileInputRef}
                    type="file"
                    accept=".mp3,.wav,.m4a,audio/mpeg,audio/wav,audio/mp4,audio/m4a,audio/x-m4a"
                    className="hidden"
                    onChange={(e) => void handleAudioFile(e.target.files?.[0])}
                  />
                  <div className="mx-auto mb-3 flex h-10 w-10 items-center justify-center rounded-lg bg-white border border-gray-200">
                    {uploading ? (
                      <Loader2 className="w-5 h-5 animate-spin text-flehub-green" />
                    ) : (
                      <Upload className="w-5 h-5 text-flehub-green" />
                    )}
                  </div>
                  <p className="text-sm font-medium text-gray-800">
                    {uploading
                      ? 'Upload en cours…'
                      : 'Glisser-déposer un audio, ou cliquer pour choisir'}
                  </p>
                  <p className="text-xs text-gray-400 mt-1">
                    mp3, wav, m4a · max 10 Mo
                  </p>
                </div>

                {form.audioPreviewUrl && (
                  <div className="rounded-lg border border-gray-100 bg-white p-3 space-y-2">
                    <div className="flex items-center gap-2 text-xs text-gray-500">
                      <Headphones className="w-3.5 h-3.5 text-flehub-green" />
                      Aperçu — réécoutez avant de valider
                    </div>
                    <audio
                      key={form.audioPreviewUrl}
                      controls
                      src={form.audioPreviewUrl}
                      className="w-full"
                    />
                  </div>
                )}
              </div>

              <div className="space-y-2">
                <Label>Niveau de la question</Label>
                <Select
                  value={form.niveau}
                  onValueChange={(v) =>
                    setForm((prev) => ({ ...prev, niveau: v as CEFR }))
                  }
                  disabled={saving || uploading}
                >
                  <SelectTrigger className="bg-white">
                    <SelectValue placeholder="Choisir un niveau" />
                  </SelectTrigger>
                  <SelectContent>
                    {cefrLevels.map((level) => (
                      <SelectItem key={level} value={level}>
                        {level}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="question_texte">Texte de la question</Label>
                <Textarea
                  id="question_texte"
                  value={form.questionTexte}
                  onChange={(e) =>
                    setForm((prev) => ({
                      ...prev,
                      questionTexte: e.target.value,
                    }))
                  }
                  rows={3}
                  placeholder="Énoncé entendu / consigne pour l’apprenant"
                  disabled={saving || uploading}
                  required
                />
              </div>

              <div className="grid gap-4 sm:grid-cols-2">
                {(
                  [
                    ['choixA', 'Choix A', 'a'],
                    ['choixB', 'Choix B', 'b'],
                    ['choixC', 'Choix C', 'c'],
                    ['choixD', 'Choix D', 'd'],
                  ] as const
                ).map(([key, label]) => (
                  <div key={key} className="space-y-2">
                    <Label htmlFor={key}>{label}</Label>
                    <Input
                      id={key}
                      value={form[key]}
                      onChange={(e) =>
                        setForm((prev) => ({ ...prev, [key]: e.target.value }))
                      }
                      disabled={saving || uploading}
                      required
                    />
                  </div>
                ))}
              </div>

              <div className="space-y-2">
                <Label>Bonne réponse</Label>
                <RadioGroup
                  value={form.bonneReponse}
                  onValueChange={(v) =>
                    setForm((prev) => ({
                      ...prev,
                      bonneReponse: v as BonneReponse,
                    }))
                  }
                  className="grid grid-cols-2 sm:grid-cols-4 gap-3"
                  disabled={saving || uploading}
                >
                  {(['a', 'b', 'c', 'd'] as const).map((letter) => (
                    <label
                      key={letter}
                      htmlFor={`bonne-${letter}`}
                      className={cn(
                        'flex items-center gap-2 rounded-lg border px-3 py-2 cursor-pointer',
                        form.bonneReponse === letter
                          ? 'border-flehub-green bg-flehub-green-light'
                          : 'border-gray-200 bg-white'
                      )}
                    >
                      <RadioGroupItem
                        value={letter}
                        id={`bonne-${letter}`}
                        style={{ accentColor: '#00A550' }}
                      />
                      <span className="text-sm font-medium uppercase">
                        {letter}
                      </span>
                    </label>
                  ))}
                </RadioGroup>
              </div>

              <div className="flex justify-end pt-1">
                <Button
                  type="submit"
                  className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                  disabled={saving || uploading}
                >
                  {saving ? (
                    <>
                      <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
                      Enregistrement…
                    </>
                  ) : editingId ? (
                    'Enregistrer les modifications'
                  ) : (
                    'Ajouter cette question et continuer'
                  )}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {!loading && session && isFull && !editingId && (
        <Card>
          <CardContent className="p-6 flex flex-col sm:flex-row sm:items-center gap-4 justify-between">
            <div>
              <h2 className="text-lg font-semibold text-gray-900">
                40 questions atteintes
              </h2>
              <p className="text-sm text-gray-500 mt-1">
                {session.statut === 'publiee'
                  ? 'Cette séance est déjà publiée. Vous pouvez encore modifier une question depuis la liste.'
                  : 'Vous pouvez publier la séance pour la rendre accessible aux apprenants.'}
              </p>
            </div>
            {session.statut !== 'publiee' && (
              <Button
                className="bg-flehub-green hover:bg-flehub-green/90 text-white shrink-0"
                onClick={() => void handlePublish()}
                disabled={publishing}
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
      )}

      <Card>
        <CardContent className="p-6 space-y-4">
          <div className="flex items-center justify-between gap-2">
            <h2 className="text-lg font-semibold text-gray-900">
              Questions ajoutées
            </h2>
            <span className="text-sm text-gray-500">
              {questions.length}/{MAX_QUESTIONS}
            </span>
          </div>

          {loading ? (
            <div className="space-y-2">
              <Skeleton className="h-12 w-full" />
              <Skeleton className="h-12 w-full" />
            </div>
          ) : questions.length === 0 ? (
            <div className="rounded-lg border border-dashed border-gray-200 px-4 py-10 text-center text-sm text-gray-500">
              Aucune question pour l’instant. Ajoutez la première ci-dessus.
            </div>
          ) : (
            <ul className="divide-y divide-gray-100 rounded-lg border border-gray-100">
              {questions.map((q) => (
                <li
                  key={q.id}
                  className={cn(
                    'flex items-center gap-3 px-3 py-3',
                    editingId === q.id && 'bg-flehub-green-light/40'
                  )}
                >
                  <button
                    type="button"
                    className="flex-1 min-w-0 text-left"
                    onClick={() => void startEdit(q)}
                  >
                    <div className="flex items-center gap-2">
                      <span className="inline-flex h-7 w-7 items-center justify-center rounded-md bg-gray-100 text-xs font-semibold text-gray-700">
                        {q.ordre}
                      </span>
                      <Badge variant="outline" className="text-xs">
                        {q.niveau}
                      </Badge>
                      <span className="text-sm text-gray-800 truncate">
                        {truncate(q.question_texte)}
                      </span>
                    </div>
                  </button>
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="text-flehub-green hover:bg-flehub-green-light"
                    onClick={() => void startEdit(q)}
                  >
                    <Pencil className="w-4 h-4" />
                  </Button>
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="text-red-500 hover:bg-red-50"
                    onClick={() => setDeleteId(q.id)}
                  >
                    <Trash2 className="w-4 h-4" />
                  </Button>
                </li>
              ))}
            </ul>
          )}
        </CardContent>
      </Card>

      <Dialog open={!!deleteId} onOpenChange={() => !deleting && setDeleteId(null)}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Supprimer cette question ?</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-gray-500">
            L’audio associé sera aussi retiré du stockage. Les numéros d’ordre
            seront recalculés.
          </p>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setDeleteId(null)}
              disabled={deleting}
            >
              Annuler
            </Button>
            <Button
              variant="destructive"
              onClick={() => void handleDelete()}
              disabled={deleting}
            >
              {deleting ? 'Suppression…' : 'Supprimer'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
