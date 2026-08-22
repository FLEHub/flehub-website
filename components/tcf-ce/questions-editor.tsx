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
  ImageIcon,
  Loader2,
  Pencil,
  Trash2,
  Upload,
  X,
} from 'lucide-react';
import { cn } from '@/lib/utils';

const MAX_QUESTIONS = 39;
const IMAGE_BUCKET = 'tcf-ce-images';
const MAX_IMAGE_BYTES = 5 * 1024 * 1024;
const ACCEPTED_IMAGE_EXT = ['jpg', 'jpeg', 'png'];
const ACCEPTED_IMAGE_MIME = ['image/jpeg', 'image/jpg', 'image/png'];

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';
type BonneReponse = 'a' | 'b' | 'c' | 'd';

interface TcfCeSession {
  id: string;
  titre: string;
  duree_minuteur: number;
  statut: 'brouillon' | 'publiee';
}

interface TcfCeQuestion {
  id: string;
  session_id: string;
  ordre: number;
  niveau: CEFR;
  image_url: string;
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
  imagePath: string;
  imagePreviewUrl: string;
}

const emptyForm = (): QuestionFormState => ({
  niveau: '',
  questionTexte: '',
  choixA: '',
  choixB: '',
  choixC: '',
  choixD: '',
  bonneReponse: '',
  imagePath: '',
  imagePreviewUrl: '',
});

const cefrLevels: CEFR[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

function isAcceptedImage(file: File): boolean {
  const ext = file.name.split('.').pop()?.toLowerCase() ?? '';
  if (ACCEPTED_IMAGE_EXT.includes(ext)) return true;
  return ACCEPTED_IMAGE_MIME.includes(file.type);
}

function truncate(text: string, max = 72): string {
  const clean = text.trim().replace(/\s+/g, ' ');
  if (clean.length <= max) return clean;
  return `${clean.slice(0, max - 1)}…`;
}

export default function TcfCeQuestionsEditor() {
  const params = useParams();
  const router = useRouter();
  const sessionId = params.sessionId as string;
  const supabase = useMemo(() => createClient(), []);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [session, setSession] = useState<TcfCeSession | null>(null);
  const [questions, setQuestions] = useState<TcfCeQuestion[]>([]);
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
        .from(IMAGE_BUCKET)
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
        .from('tcf_ce_sessions')
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

      setSession(sessionData as TcfCeSession);

      const { data: questionsData, error: questionsError } = await supabase
        .from('tcf_ce_questions')
        .select(
          'id, session_id, ordre, niveau, image_url, question_texte, choix_a, choix_b, choix_c, choix_d, bonne_reponse, created_at'
        )
        .eq('session_id', sessionId)
        .order('ordre', { ascending: true });

      if (questionsError) throw questionsError;
      setQuestions((questionsData as TcfCeQuestion[]) ?? []);
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
    if (form.imagePreviewUrl.startsWith('blob:')) {
      URL.revokeObjectURL(form.imagePreviewUrl);
    }
    setForm(emptyForm());
    setEditingId(null);
    setFormError(null);
    if (fileInputRef.current) fileInputRef.current.value = '';
  }

  async function handleImageFile(file: File | null | undefined) {
    if (!file) return;
    setFormError(null);
    setFormSuccess(null);

    if (!isAcceptedImage(file)) {
      setFormError('Formats acceptés : jpg, jpeg, png.');
      return;
    }
    if (file.size > MAX_IMAGE_BYTES) {
      setFormError('Le fichier image ne doit pas dépasser 5 Mo.');
      return;
    }

    const localUrl = URL.createObjectURL(file);
    if (form.imagePreviewUrl.startsWith('blob:')) {
      URL.revokeObjectURL(form.imagePreviewUrl);
    }
    setForm((prev) => ({ ...prev, imagePreviewUrl: localUrl }));
    setUploading(true);

    try {
      const ext = file.name.split('.').pop()?.toLowerCase() || 'jpg';
      const path = `${sessionId}/${crypto.randomUUID()}.${ext}`;
      const { error: uploadError } = await supabase.storage
        .from(IMAGE_BUCKET)
        .upload(path, file, {
          upsert: false,
          contentType: file.type || undefined,
        });
      if (uploadError) throw uploadError;

      const signed = await loadSignedUrl(path);
      if (localUrl.startsWith('blob:')) URL.revokeObjectURL(localUrl);
      setForm((prev) => ({
        ...prev,
        imagePath: path,
        imagePreviewUrl: signed,
      }));
    } catch (err) {
      console.error(err);
      setFormError(
        err instanceof Error
          ? err.message
          : 'Échec de l’upload image. Réessayez.'
      );
      setForm((prev) => ({ ...prev, imagePath: '', imagePreviewUrl: '' }));
    } finally {
      setUploading(false);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  }

  async function startEdit(question: TcfCeQuestion) {
    setFormError(null);
    setFormSuccess(null);
    setEditingId(question.id);
    let preview = '';
    try {
      preview = await loadSignedUrl(question.image_url);
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
      imagePath: question.image_url,
      imagePreviewUrl: preview,
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  async function renumberQuestions(list: TcfCeQuestion[]) {
    const sorted = [...list].sort((a, b) => a.ordre - b.ordre);
    // Deux passes pour éviter les conflits sur UNIQUE(session_id, ordre)
    for (let i = 0; i < sorted.length; i++) {
      const { error } = await supabase
        .from('tcf_ce_questions')
        .update({ ordre: 1000 + i })
        .eq('id', sorted[i].id);
      if (error) throw error;
    }
    for (let i = 0; i < sorted.length; i++) {
      const { error } = await supabase
        .from('tcf_ce_questions')
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

    if (!form.imagePath) {
      setFormError('Uploadez une image du texte avant de valider.');
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
      setFormError('Cette séance contient déjà 39 questions.');
      return;
    }

    setSaving(true);
    try {
      if (editingId) {
        const { error } = await supabase
          .from('tcf_ce_questions')
          .update({
            niveau: form.niveau,
            image_url: form.imagePath,
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
          throw new Error('Cette séance contient déjà 39 questions.');
        }
        const { error } = await supabase.from('tcf_ce_questions').insert({
          session_id: sessionId,
          ordre,
          niveau: form.niveau,
          image_url: form.imagePath,
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
        .from('tcf_ce_questions')
        .delete()
        .eq('id', deleteId)
        .eq('session_id', sessionId);
      if (error) throw error;

      if (target?.image_url && !target.image_url.startsWith('http')) {
        await supabase.storage.from(IMAGE_BUCKET).remove([target.image_url]);
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
        .from('tcf_ce_sessions')
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
                  variant="outline"
                  className="bg-amber-100 text-amber-800 border-amber-200"
                >
                  CE
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
              <div className="rounded-lg bg-amber-50 px-3 py-1.5 text-sm font-semibold text-amber-800">
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
          <h1 className="text-2xl font-bold text-gray-900">Questions TCF CE</h1>
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
                <Label>Image du texte à lire</Label>
                <div
                  className={cn(
                    'rounded-xl border-2 border-dashed px-4 py-8 text-center transition-colors cursor-pointer',
                    dragOver
                      ? 'border-amber-400 bg-amber-50/70'
                      : 'border-gray-200 bg-gray-50 hover:border-amber-300'
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
                    void handleImageFile(e.dataTransfer.files?.[0]);
                  }}
                >
                  <input
                    ref={fileInputRef}
                    type="file"
                    accept=".jpg,.jpeg,.png,image/jpeg,image/png"
                    className="hidden"
                    onChange={(e) => void handleImageFile(e.target.files?.[0])}
                  />
                  <div className="mx-auto mb-3 flex h-10 w-10 items-center justify-center rounded-lg bg-white border border-gray-200">
                    {uploading ? (
                      <Loader2 className="w-5 h-5 animate-spin text-amber-700" />
                    ) : (
                      <Upload className="w-5 h-5 text-amber-700" />
                    )}
                  </div>
                  <p className="text-sm font-medium text-gray-800">
                    {uploading
                      ? 'Upload en cours…'
                      : 'Glisser-déposer une image, ou cliquer pour choisir'}
                  </p>
                  <p className="text-xs text-gray-400 mt-1">
                    jpg, jpeg, png · max 5 Mo
                  </p>
                </div>

                {form.imagePreviewUrl && (
                  <div className="rounded-lg border border-gray-100 bg-white p-3 space-y-2">
                    <div className="flex items-center gap-2 text-xs text-gray-500">
                      <ImageIcon className="w-3.5 h-3.5 text-amber-700" />
                      Aperçu — vérifiez que le texte est lisible avant de
                      valider
                    </div>
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      key={form.imagePreviewUrl}
                      src={form.imagePreviewUrl}
                      alt="Aperçu du texte à lire"
                      className="w-full max-h-[420px] object-contain rounded-md border border-gray-100 bg-gray-50"
                    />
                  </div>
                )}
              </div>

              <div className="space-y-2">
                <Label>Niveau</Label>
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
                  placeholder="Consigne / question relative au texte affiché"
                  disabled={saving || uploading}
                  required
                />
              </div>

              <div className="grid gap-4 sm:grid-cols-2">
                {(
                  [
                    ['choixA', 'Choix A'],
                    ['choixB', 'Choix B'],
                    ['choixC', 'Choix C'],
                    ['choixD', 'Choix D'],
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
                      htmlFor={`ce-bonne-${letter}`}
                      className={cn(
                        'flex items-center gap-2 rounded-lg border px-3 py-2 cursor-pointer',
                        form.bonneReponse === letter
                          ? 'border-flehub-green bg-flehub-green-light'
                          : 'border-gray-200 bg-white'
                      )}
                    >
                      <RadioGroupItem
                        value={letter}
                        id={`ce-bonne-${letter}`}
                        style={{ accentColor: '#1E5FA8' }}
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
                39 questions atteintes
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
                    editingId === q.id && 'bg-amber-50/70'
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

      <Dialog
        open={!!deleteId}
        onOpenChange={() => !deleting && setDeleteId(null)}
      >
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Supprimer cette question ?</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-gray-500">
            L’image associée sera aussi retirée du stockage. Les numéros
            d’ordre seront recalculés.
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
