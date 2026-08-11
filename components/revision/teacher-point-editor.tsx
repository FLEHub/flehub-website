'use client';

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
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
  Download,
  FileText,
  Loader2,
  Pencil,
  Trash2,
  Upload,
  X,
} from 'lucide-react';
import { cn } from '@/lib/utils';

const MAX_QUESTIONS = 10;
const PDF_BUCKET = 'revision-pdfs';
const MAX_PDF_BYTES = 10 * 1024 * 1024;

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';
type BonneReponse = 'a' | 'b' | 'c' | 'd';

interface RevisionPoint {
  id: string;
  numero: number;
  titre: string;
  unite_id: string;
  unite_titre?: string;
  unite_numero?: number;
}

interface RevisionQuestion {
  id: string;
  point_id: string;
  ordre: number;
  niveau: CEFR;
  question_texte: string;
  choix_a: string;
  choix_b: string;
  choix_c: string;
  choix_d: string;
  bonne_reponse: BonneReponse;
  created_at: string;
}

interface RevisionRessource {
  id: string;
  point_id: string;
  pdf_url: string;
  titre: string | null;
}

interface QuestionFormState {
  niveau: CEFR | '';
  questionTexte: string;
  choixA: string;
  choixB: string;
  choixC: string;
  choixD: string;
  bonneReponse: BonneReponse | '';
}

const emptyForm = (): QuestionFormState => ({
  niveau: '',
  questionTexte: '',
  choixA: '',
  choixB: '',
  choixC: '',
  choixD: '',
  bonneReponse: '',
});

const cefrLevels: CEFR[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

function isAcceptedPdf(file: File): boolean {
  const ext = file.name.split('.').pop()?.toLowerCase() ?? '';
  return ext === 'pdf' || file.type === 'application/pdf';
}

function truncate(text: string, max = 72): string {
  const clean = text.trim().replace(/\s+/g, ' ');
  if (clean.length <= max) return clean;
  return `${clean.slice(0, max - 1)}…`;
}

export default function TeacherRevisionPointEditor() {
  const params = useParams();
  const pointId = params.pointId as string;
  const supabase = useMemo(() => createClient(), []);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [point, setPoint] = useState<RevisionPoint | null>(null);
  const [questions, setQuestions] = useState<RevisionQuestion[]>([]);
  const [ressource, setRessource] = useState<RevisionRessource | null>(null);
  const [pdfPreviewUrl, setPdfPreviewUrl] = useState('');
  const [loading, setLoading] = useState(true);
  const [pageError, setPageError] = useState<string | null>(null);

  const [form, setForm] = useState<QuestionFormState>(emptyForm);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [formError, setFormError] = useState<string | null>(null);
  const [formSuccess, setFormSuccess] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [uploadingPdf, setUploadingPdf] = useState(false);
  const [dragOver, setDragOver] = useState(false);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [deleting, setDeleting] = useState(false);

  const loadSignedUrl = useCallback(
    async (path: string): Promise<string> => {
      if (!path) return '';
      if (path.startsWith('blob:') || path.startsWith('http')) return path;
      const { data, error } = await supabase.storage
        .from(PDF_BUCKET)
        .createSignedUrl(path, 3600);
      if (error) throw error;
      return data.signedUrl;
    },
    [supabase]
  );

  const loadData = useCallback(async () => {
    try {
      setPageError(null);
      const { data: pointData, error: pointError } = await supabase
        .from('revision_points')
        .select('id, numero, titre, unite_id')
        .eq('id', pointId)
        .maybeSingle();

      if (pointError) throw pointError;
      if (!pointData) {
        setPageError('Point de révision introuvable.');
        setPoint(null);
        setQuestions([]);
        setRessource(null);
        return;
      }

      const { data: uniteData } = await supabase
        .from('revision_unites')
        .select('numero, titre')
        .eq('id', pointData.unite_id)
        .maybeSingle();

      setPoint({
        ...(pointData as RevisionPoint),
        unite_titre: uniteData?.titre as string | undefined,
        unite_numero: uniteData?.numero as number | undefined,
      });

      const [{ data: questionsData, error: questionsError }, { data: resData }] =
        await Promise.all([
          supabase
            .from('revision_questions')
            .select(
              'id, point_id, ordre, niveau, question_texte, choix_a, choix_b, choix_c, choix_d, bonne_reponse, created_at'
            )
            .eq('point_id', pointId)
            .order('ordre', { ascending: true }),
          supabase
            .from('revision_ressources')
            .select('id, point_id, pdf_url, titre')
            .eq('point_id', pointId)
            .maybeSingle(),
        ]);

      if (questionsError) throw questionsError;
      setQuestions((questionsData as RevisionQuestion[]) ?? []);

      const res = (resData as RevisionRessource | null) ?? null;
      setRessource(res);
      if (res?.pdf_url) {
        try {
          setPdfPreviewUrl(await loadSignedUrl(res.pdf_url));
        } catch (err) {
          console.error(err);
          setPdfPreviewUrl('');
        }
      } else {
        setPdfPreviewUrl('');
      }
    } catch (err) {
      console.error(err);
      setPageError('Impossible de charger le point de révision.');
    } finally {
      setLoading(false);
    }
  }, [pointId, supabase, loadSignedUrl]);

  useEffect(() => {
    if (pointId) void loadData();
  }, [pointId, loadData]);

  const nextOrdre = questions.length + 1;
  const isFull = questions.length >= MAX_QUESTIONS;
  const counterLabel = editingId
    ? questions.find((q) => q.id === editingId)?.ordre ?? nextOrdre
    : Math.min(nextOrdre, MAX_QUESTIONS);

  function resetForm() {
    setForm(emptyForm());
    setEditingId(null);
    setFormError(null);
  }

  async function handlePdfFile(file: File | null | undefined) {
    if (!file || !point) return;
    setFormError(null);
    setFormSuccess(null);

    if (!isAcceptedPdf(file)) {
      setFormError('Seuls les fichiers PDF sont acceptés.');
      return;
    }
    if (file.size > MAX_PDF_BYTES) {
      setFormError('Le PDF ne doit pas dépasser 10 Mo.');
      return;
    }

    setUploadingPdf(true);
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error('Session expirée. Reconnectez-vous.');

      const safeName = file.name
        .replace(/[^a-zA-Z0-9._-]/g, '-')
        .replace(/-+/g, '-');
      const path = `${pointId}/${safeName.endsWith('.pdf') ? safeName : `${safeName}.pdf`}`;

      if (ressource?.pdf_url && !ressource.pdf_url.startsWith('http')) {
        await supabase.storage.from(PDF_BUCKET).remove([ressource.pdf_url]);
      }

      const { error: uploadError } = await supabase.storage
        .from(PDF_BUCKET)
        .upload(path, file, {
          upsert: true,
          contentType: 'application/pdf',
        });
      if (uploadError) throw uploadError;

      const titre = file.name.replace(/\.pdf$/i, '') || 'Trace écrite';

      if (ressource) {
        const { error } = await supabase
          .from('revision_ressources')
          .update({
            pdf_url: path,
            titre,
            uploaded_by: user.id,
          })
          .eq('id', ressource.id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from('revision_ressources').insert({
          point_id: pointId,
          pdf_url: path,
          titre,
          uploaded_by: user.id,
        });
        if (error) throw error;
      }

      const signed = await loadSignedUrl(path);
      setPdfPreviewUrl(signed);
      setFormSuccess(
        ressource ? 'PDF remplacé.' : 'Trace écrite uploadée.'
      );
      await loadData();
    } catch (err) {
      console.error(err);
      setFormError(
        err instanceof Error
          ? err.message
          : 'Échec de l’upload PDF. Réessayez.'
      );
    } finally {
      setUploadingPdf(false);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  }

  function startEdit(question: RevisionQuestion) {
    setFormError(null);
    setFormSuccess(null);
    setEditingId(question.id);
    setForm({
      niveau: question.niveau,
      questionTexte: question.question_texte,
      choixA: question.choix_a,
      choixB: question.choix_b,
      choixC: question.choix_c,
      choixD: question.choix_d,
      bonneReponse: question.bonne_reponse,
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  async function renumberQuestions(list: RevisionQuestion[]) {
    const sorted = [...list].sort((a, b) => a.ordre - b.ordre);
    for (let i = 0; i < sorted.length; i++) {
      const { error } = await supabase
        .from('revision_questions')
        .update({ ordre: 1000 + i })
        .eq('id', sorted[i].id);
      if (error) throw error;
    }
    for (let i = 0; i < sorted.length; i++) {
      const { error } = await supabase
        .from('revision_questions')
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
      setFormError('Ce point contient déjà 10 questions.');
      return;
    }

    setSaving(true);
    try {
      if (editingId) {
        const { error } = await supabase
          .from('revision_questions')
          .update({
            niveau: form.niveau,
            question_texte: questionTexte,
            choix_a: choixA,
            choix_b: choixB,
            choix_c: choixC,
            choix_d: choixD,
            bonne_reponse: form.bonneReponse,
          })
          .eq('id', editingId)
          .eq('point_id', pointId);
        if (error) throw error;
        setFormSuccess('Question mise à jour.');
      } else {
        const ordre =
          questions.reduce((max, q) => Math.max(max, q.ordre), 0) + 1;
        if (ordre > MAX_QUESTIONS) {
          throw new Error('Ce point contient déjà 10 questions.');
        }
        const { error } = await supabase.from('revision_questions').insert({
          point_id: pointId,
          ordre,
          niveau: form.niveau,
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
      const { error } = await supabase
        .from('revision_questions')
        .delete()
        .eq('id', deleteId)
        .eq('point_id', pointId);
      if (error) throw error;

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

  const showForm = Boolean(point) && (!isFull || editingId);

  return (
    <div className="p-6 space-y-6 max-w-4xl mx-auto">
      <div>
        <Link
          href="/dashboard/teacher/preparation/revision"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour aux unités
        </Link>
        {loading ? (
          <div className="space-y-2">
            <Skeleton className="h-8 w-72" />
            <Skeleton className="h-4 w-48" />
          </div>
        ) : point ? (
          <>
            <div className="flex items-center justify-between gap-3 flex-wrap">
              <div className="flex items-center gap-2 flex-wrap">
                <h1 className="text-2xl font-bold text-gray-900">
                  {point.numero}. {point.titre}
                </h1>
                <Badge
                  variant="outline"
                  className="bg-flehub-green-light text-flehub-green border-flehub-green"
                >
                  Révision
                </Badge>
              </div>
              <div className="rounded-lg bg-flehub-green-light px-3 py-1.5 text-sm font-semibold text-flehub-green">
                Question {counterLabel}/{MAX_QUESTIONS}
              </div>
            </div>
            <p className="text-sm text-gray-500 mt-1">
              {point.unite_numero != null && point.unite_titre
                ? `Unité ${point.unite_numero} — ${point.unite_titre}`
                : 'Révision'}{' '}
              · {questions.length} question
              {questions.length === 1 ? '' : 's'}
            </p>
          </>
        ) : (
          <h1 className="text-2xl font-bold text-gray-900">
            Point de révision
          </h1>
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

      {point && (
        <Card>
          <CardContent className="p-6 space-y-4">
            <div>
              <h2 className="text-lg font-semibold text-gray-900">
                Trace écrite (PDF)
              </h2>
              <p className="text-sm text-gray-500 mt-1">
                Un seul PDF par point — les apprenants pourront le télécharger.
              </p>
            </div>

            {ressource && pdfPreviewUrl ? (
              <div className="rounded-lg border border-gray-200 bg-gray-50 p-4 flex flex-col sm:flex-row sm:items-center gap-3">
                <div className="flex items-center gap-3 flex-1 min-w-0">
                  <div className="p-2 rounded-lg bg-white border border-gray-200">
                    <FileText className="w-5 h-5 text-flehub-green" />
                  </div>
                  <div className="min-w-0">
                    <p className="text-sm font-medium text-gray-900 truncate">
                      {ressource.titre || 'Trace écrite'}
                    </p>
                    <p className="text-xs text-gray-500 truncate">
                      {ressource.pdf_url}
                    </p>
                  </div>
                </div>
                <div className="flex gap-2 flex-wrap">
                  <Button asChild size="sm" variant="outline">
                    <a
                      href={pdfPreviewUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      <Download className="w-4 h-4 mr-1.5" />
                      Télécharger
                    </a>
                  </Button>
                  <Button
                    type="button"
                    size="sm"
                    variant="outline"
                    className="border-flehub-green text-flehub-green hover:bg-flehub-green-light"
                    disabled={uploadingPdf}
                    onClick={() => fileInputRef.current?.click()}
                  >
                    {uploadingPdf ? (
                      <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
                    ) : (
                      <Upload className="w-4 h-4 mr-1.5" />
                    )}
                    Remplacer le PDF
                  </Button>
                </div>
              </div>
            ) : (
              <div
                className={cn(
                  'rounded-xl border-2 border-dashed px-4 py-8 text-center transition-colors cursor-pointer',
                  dragOver
                    ? 'border-flehub-green bg-flehub-green-light/70'
                    : 'border-gray-200 bg-gray-50 hover:border-flehub-green/50'
                )}
                onClick={() => !uploadingPdf && fileInputRef.current?.click()}
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
                  void handlePdfFile(e.dataTransfer.files?.[0]);
                }}
              >
                <div className="mx-auto mb-3 flex h-10 w-10 items-center justify-center rounded-lg bg-white border border-gray-200">
                  {uploadingPdf ? (
                    <Loader2 className="w-5 h-5 animate-spin text-flehub-green" />
                  ) : (
                    <Upload className="w-5 h-5 text-gray-400" />
                  )}
                </div>
                <p className="text-sm font-medium text-gray-700">
                  {uploadingPdf
                    ? 'Upload en cours…'
                    : 'Déposez le PDF de la trace écrite'}
                </p>
                <p className="text-xs text-gray-500 mt-1">
                  PDF uniquement · max 10 Mo
                </p>
              </div>
            )}

            <input
              ref={fileInputRef}
              type="file"
              accept=".pdf,application/pdf"
              className="hidden"
              onChange={(e) => void handlePdfFile(e.target.files?.[0])}
            />
          </CardContent>
        </Card>
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
                    disabled={saving}
                  >
                    Annuler la modification
                  </Button>
                )}
              </div>

              <div className="space-y-2">
                <Label>Niveau</Label>
                <Select
                  value={form.niveau}
                  onValueChange={(v) =>
                    setForm((prev) => ({ ...prev, niveau: v as CEFR }))
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Choisir un niveau" />
                  </SelectTrigger>
                  <SelectContent>
                    {cefrLevels.map((lvl) => (
                      <SelectItem key={lvl} value={lvl}>
                        {lvl}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="question_texte">Question (phrase à trou)</Label>
                <Textarea
                  id="question_texte"
                  rows={3}
                  placeholder="Ex. : Il faut que tu ___ (venir) demain."
                  value={form.questionTexte}
                  onChange={(e) =>
                    setForm((prev) => ({
                      ...prev,
                      questionTexte: e.target.value,
                    }))
                  }
                />
              </div>

              <div className="grid gap-3 sm:grid-cols-2">
                {(
                  [
                    ['choixA', 'A', 'choixA'],
                    ['choixB', 'B', 'choixB'],
                    ['choixC', 'C', 'choixC'],
                    ['choixD', 'D', 'choixD'],
                  ] as const
                ).map(([key, letter]) => (
                  <div key={key} className="space-y-2">
                    <Label htmlFor={key}>Choix {letter}</Label>
                    <Input
                      id={key}
                      value={form[key]}
                      onChange={(e) =>
                        setForm((prev) => ({
                          ...prev,
                          [key]: e.target.value,
                        }))
                      }
                      placeholder={`Réponse ${letter}`}
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
                  className="flex flex-wrap gap-4"
                >
                  {(['a', 'b', 'c', 'd'] as const).map((letter) => (
                    <div key={letter} className="flex items-center gap-2">
                      <RadioGroupItem value={letter} id={`bonne-${letter}`} />
                      <Label
                        htmlFor={`bonne-${letter}`}
                        className="font-normal cursor-pointer"
                      >
                        {letter.toUpperCase()}
                      </Label>
                    </div>
                  ))}
                </RadioGroup>
              </div>

              <Button
                type="submit"
                disabled={saving}
                className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              >
                {saving && <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />}
                {editingId ? 'Enregistrer' : 'Ajouter la question'}
              </Button>
            </form>
          </CardContent>
        </Card>
      )}

      {point && (
        <Card>
          <CardContent className="p-6 space-y-3">
            <h2 className="text-lg font-semibold text-gray-900">
              Questions ({questions.length}/{MAX_QUESTIONS})
            </h2>
            {questions.length === 0 ? (
              <p className="text-sm text-gray-500">
                Aucune question pour l’instant. Ajoutez-en jusqu’à 10.
              </p>
            ) : (
              <ul className="space-y-2">
                {questions.map((q) => (
                  <li
                    key={q.id}
                    className="flex items-start gap-3 rounded-lg border border-gray-100 px-3 py-3"
                  >
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 flex-wrap">
                        <span className="text-xs font-semibold text-gray-500">
                          Q{q.ordre}
                        </span>
                        <Badge variant="outline" className="text-xs">
                          {q.niveau}
                        </Badge>
                        <Badge
                          variant="outline"
                          className="text-xs bg-flehub-green-light text-flehub-green border-flehub-green"
                        >
                          {q.bonne_reponse.toUpperCase()}
                        </Badge>
                      </div>
                      <p className="text-sm text-gray-800 mt-1">
                        {truncate(q.question_texte)}
                      </p>
                    </div>
                    <div className="flex gap-1 flex-shrink-0">
                      <Button
                        type="button"
                        size="icon"
                        variant="ghost"
                        onClick={() => startEdit(q)}
                      >
                        <Pencil className="w-4 h-4" />
                      </Button>
                      <Button
                        type="button"
                        size="icon"
                        variant="ghost"
                        className="text-red-600 hover:text-red-700 hover:bg-red-50"
                        onClick={() => setDeleteId(q.id)}
                      >
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </div>
                  </li>
                ))}
              </ul>
            )}
            {isFull && !editingId && (
              <p className="text-sm text-flehub-green font-medium">
                Ce point est complet (10/10). Les apprenants peuvent
                s’entraîner.
              </p>
            )}
          </CardContent>
        </Card>
      )}

      <Dialog
        open={Boolean(deleteId)}
        onOpenChange={(open) => !open && setDeleteId(null)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Supprimer cette question ?</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-gray-500">
            Les questions restantes seront renumérotées automatiquement.
          </p>
          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={() => setDeleteId(null)}
              disabled={deleting}
            >
              Annuler
            </Button>
            <Button
              type="button"
              variant="destructive"
              onClick={() => void handleDelete()}
              disabled={deleting}
            >
              {deleting && (
                <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
              )}
              Supprimer
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
