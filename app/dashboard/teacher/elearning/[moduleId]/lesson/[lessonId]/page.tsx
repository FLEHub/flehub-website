'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Checkbox } from '@/components/ui/checkbox';
import {
  ArrowLeft,
  Plus,
  Trash2,
  Pencil,
  ListChecks,
  Save,
  Upload,
  ImageIcon,
  Headphones,
  FileText,
} from 'lucide-react';
import {
  getYoutubeEmbedUrl,
  isStorageContentType,
  LESSON_CONTENT_TYPES,
  MEDIA_BUCKET,
  normalizeContentType,
  type LessonContentType,
} from '@/lib/elearning-content';
import { LessonContentView } from '@/components/dashboard/lesson-content-view';

type Competency = 'CO' | 'CE' | 'PE' | 'PO' | 'EL';
type ExerciseType = 'qcm' | 'matching' | 'fill_blank' | 'short_answer';

interface Lesson {
  id: string;
  sequence_id: string;
  title: string;
  competency: Competency | null;
  content_type: LessonContentType;
  content: string | null;
  order_index: number;
}

interface Exercise {
  id: string;
  title: string;
  exercise_type: ExerciseType;
  content: Record<string, unknown>;
  order_index: number;
}

const COMPETENCIES: Competency[] = ['CO', 'CE', 'PE', 'PO', 'EL'];
const EXERCISE_TYPES: ExerciseType[] = ['qcm', 'matching', 'fill_blank', 'short_answer'];

const competencyLabels: Record<Competency, string> = {
  CO: 'Compréhension Orale',
  CE: 'Compréhension Écrite',
  PE: 'Production Écrite',
  PO: 'Production Orale',
  EL: 'Éléments Linguistiques',
};

const competencyColors: Record<Competency, string> = {
  CO: 'bg-teal-100 text-teal-700',
  CE: 'bg-rose-100 text-rose-700',
  PE: 'bg-orange-100 text-orange-700',
  PO: 'bg-blue-100 text-blue-700',
  EL: 'bg-amber-100 text-amber-700',
};

const exerciseTypeLabels: Record<ExerciseType, string> = {
  qcm: 'QCM',
  matching: 'Association',
  fill_blank: 'Texte à trous',
  short_answer: 'Réponse libre',
};

interface QcmOption {
  text: string;
  correct: boolean;
}

interface MatchingPair {
  left: string;
  right: string;
}

interface ExerciseFormState {
  question: string;
  options: QcmOption[];
  explanation: string;
  pairs: MatchingPair[];
  prompt: string;
  answer: string;
}

function emptyExerciseForm(): ExerciseFormState {
  return {
    question: '',
    options: [
      { text: '', correct: true },
      { text: '', correct: false },
      { text: '', correct: false },
      { text: '', correct: false },
    ],
    explanation: '',
    pairs: [
      { left: '', right: '' },
      { left: '', right: '' },
    ],
    prompt: '',
    answer: '',
  };
}

function parseExerciseForm(
  type: ExerciseType,
  raw: Record<string, unknown> | null | undefined
): ExerciseFormState {
  const base = emptyExerciseForm();
  if (!raw || typeof raw !== 'object') return base;

  if (type === 'qcm') {
    const question = typeof raw.question === 'string' ? raw.question : '';
    const explanation = typeof raw.explanation === 'string' ? raw.explanation : '';
    let options: QcmOption[] = base.options;

    if (Array.isArray(raw.options)) {
      const optionsList = raw.options as unknown[];
      if (optionsList.every((o) => typeof o === 'string')) {
        const correctIndex =
          typeof raw.correct_index === 'number' ? raw.correct_index : 0;
        const texts = optionsList as string[];
        options = [0, 1, 2, 3].map((i) => ({
          text: texts[i] ?? '',
          correct: i === correctIndex,
        }));
      } else {
        options = [0, 1, 2, 3].map((i) => {
          const item = optionsList[i] as Record<string, unknown> | undefined;
          return {
            text: typeof item?.text === 'string' ? item.text : '',
            correct: Boolean(item?.correct ?? item?.is_correct),
          };
        });
        if (!options.some((o) => o.correct)) options[0].correct = true;
      }
    }

    return { ...base, question, options, explanation };
  }

  if (type === 'matching') {
    const pairsRaw = Array.isArray(raw.pairs) ? raw.pairs : [];
    const pairs: MatchingPair[] =
      pairsRaw.length > 0
        ? pairsRaw.map((p) => {
            const pair = p as Record<string, unknown>;
            return {
              left: typeof pair?.left === 'string' ? pair.left : '',
              right: typeof pair?.right === 'string' ? pair.right : '',
            };
          })
        : base.pairs;
    return { ...base, pairs };
  }

  if (type === 'fill_blank') {
    return {
      ...base,
      prompt: typeof raw.prompt === 'string' ? raw.prompt : '',
      answer: typeof raw.answer === 'string' ? raw.answer : '',
    };
  }

  // short_answer
  const prompt =
    typeof raw.prompt === 'string'
      ? raw.prompt
      : typeof raw.question === 'string'
        ? raw.question
        : '';
  return { ...base, prompt };
}

function buildExerciseContent(
  type: ExerciseType,
  form: ExerciseFormState
): Record<string, unknown> {
  switch (type) {
    case 'qcm':
      return {
        question: form.question.trim(),
        options: form.options.map((o) => ({
          text: o.text.trim(),
          correct: o.correct,
        })),
        explanation: form.explanation.trim(),
      };
    case 'matching':
      return {
        pairs: form.pairs.map((p) => ({
          left: p.left.trim(),
          right: p.right.trim(),
        })),
      };
    case 'fill_blank':
      return {
        prompt: form.prompt.trim(),
        answer: form.answer.trim(),
      };
    case 'short_answer':
      return {
        prompt: form.prompt.trim(),
      };
    default:
      return {};
  }
}

function validateExerciseForm(type: ExerciseType, form: ExerciseFormState): string | null {
  if (type === 'qcm') {
    if (!form.question.trim()) return 'La question est obligatoire';
    if (form.options.some((o) => !o.text.trim())) return 'Remplissez les 4 réponses';
    if (!form.options.some((o) => o.correct)) return 'Cochez la bonne réponse';
    return null;
  }
  if (type === 'matching') {
    if (form.pairs.length < 1) return 'Ajoutez au moins une paire';
    if (form.pairs.some((p) => !p.left.trim() || !p.right.trim())) {
      return 'Remplissez toutes les paires';
    }
    return null;
  }
  if (type === 'fill_blank') {
    if (!form.prompt.trim()) return 'La phrase est obligatoire';
    if (!form.answer.trim()) return 'La réponse attendue est obligatoire';
    return null;
  }
  if (type === 'short_answer') {
    if (!form.prompt.trim()) return 'La consigne est obligatoire';
    return null;
  }
  return null;
}

export default function TeacherLessonEditPage() {
  const supabase = createClient();
  const router = useRouter();
  const params = useParams();
  const moduleId = typeof params.moduleId === 'string' ? params.moduleId : '';
  const lessonId = typeof params.lessonId === 'string' ? params.lessonId : '';

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [moduleTitle, setModuleTitle] = useState('');
  const [lesson, setLesson] = useState<Lesson | null>(null);
  const [exercises, setExercises] = useState<Exercise[]>([]);

  const [title, setTitle] = useState('');
  const [competency, setCompetency] = useState<Competency | ''>('');
  const [contentType, setContentType] = useState<LessonContentType>('text');
  const [content, setContent] = useState('');
  const [uploading, setUploading] = useState(false);
  const [uploadError, setUploadError] = useState<string | null>(null);

  const [exerciseDialogOpen, setExerciseDialogOpen] = useState(false);
  const [editingExercise, setEditingExercise] = useState<Exercise | null>(null);
  const [exTitle, setExTitle] = useState('');
  const [exType, setExType] = useState<ExerciseType>('qcm');
  const [exForm, setExForm] = useState<ExerciseFormState>(emptyExerciseForm());
  const [exFormError, setExFormError] = useState<string | null>(null);
  const [deleteExerciseId, setDeleteExerciseId] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    if (!moduleId || !lessonId) return;
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return;

      const { data: teacher } = await supabase
        .from('teachers')
        .select('id')
        .eq('profile_id', user.id)
        .maybeSingle();

      if (!teacher) return;

      const { data: mod } = await supabase
        .from('elearning_modules')
        .select('id, title, teacher_id')
        .eq('id', moduleId)
        .eq('teacher_id', teacher.id)
        .maybeSingle();

      if (!mod) {
        router.replace('/dashboard/teacher/elearning');
        return;
      }
      setModuleTitle(mod.title);

      const { data: lessonRow, error: lessonErr } = await supabase
        .from('elearning_lessons')
        .select('id, sequence_id, title, competency, content_type, content, order_index')
        .eq('id', lessonId)
        .maybeSingle();

      if (lessonErr || !lessonRow) {
        router.replace(`/dashboard/teacher/elearning/${moduleId}`);
        return;
      }

      // Ensure lesson belongs to this module
      const { data: seq } = await supabase
        .from('elearning_sequences')
        .select('id, module_id')
        .eq('id', lessonRow.sequence_id)
        .eq('module_id', moduleId)
        .maybeSingle();

      if (!seq) {
        router.replace(`/dashboard/teacher/elearning/${moduleId}`);
        return;
      }

      const typed: Lesson = {
        ...(lessonRow as Lesson),
        content_type: normalizeContentType((lessonRow as Lesson).content_type),
      };
      setLesson(typed);
      setTitle(typed.title ?? '');
      setCompetency((typed.competency as Competency) ?? '');
      setContentType(typed.content_type);
      setContent(typed.content ?? '');
      setUploadError(null);

      const { data: exRows } = await supabase
        .from('elearning_exercises')
        .select('id, title, exercise_type, content, order_index')
        .eq('lesson_id', lessonId)
        .order('order_index', { ascending: true });

      setExercises(
        ((exRows ?? []) as Exercise[]).map((e) => ({
          ...e,
          content:
            e.content && typeof e.content === 'object' && !Array.isArray(e.content)
              ? (e.content as Record<string, unknown>)
              : {},
        }))
      );
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [moduleId, lessonId, router]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  function handleContentTypeChange(next: LessonContentType) {
    if (next === contentType) return;
    setContentType(next);
    setContent('');
    setUploadError(null);
  }

  async function handleMediaUpload(file: File | null, kind: 'image' | 'audio' | 'pdf') {
    if (!file || !lesson) return;
    setUploading(true);
    setUploadError(null);
    try {
      const ext = file.name.split('.').pop()?.toLowerCase() || kind;
      const path = `lessons/${lesson.id}/${Date.now()}.${ext}`;

      const { error: upErr } = await supabase.storage
        .from(MEDIA_BUCKET)
        .upload(path, file, { upsert: true, contentType: file.type || undefined });

      if (upErr) throw upErr;

      // Remove previous file if it was stored in the same bucket
      if (isStorageContentType(contentType) && content && content !== path) {
        await supabase.storage.from(MEDIA_BUCKET).remove([content]);
      }

      setContent(path);
    } catch (err) {
      console.error(err);
      const hints: Record<'image' | 'audio' | 'pdf', string> = {
        image: 'JPG, PNG, WebP, GIF',
        audio: 'MP3, WAV, M4A',
        pdf: 'PDF',
      };
      setUploadError(`Échec de l'upload. Vérifiez le type de fichier (${hints[kind]}).`);
    } finally {
      setUploading(false);
    }
  }

  async function saveLesson() {
    if (!lesson || !title.trim() || !competency) return;
    setSaving(true);
    try {
      const { error } = await supabase
        .from('elearning_lessons')
        .update({
          title: title.trim(),
          competency,
          content_type: contentType,
          content,
        })
        .eq('id', lesson.id);
      if (error) throw error;
      setLesson({
        ...lesson,
        title: title.trim(),
        competency,
        content_type: contentType,
        content,
      });
    } catch (err) {
      console.error(err);
    } finally {
      setSaving(false);
    }
  }

  function openCreateExercise() {
    setEditingExercise(null);
    setExTitle('');
    setExType('qcm');
    setExForm(emptyExerciseForm());
    setExFormError(null);
    setExerciseDialogOpen(true);
  }

  function openEditExercise(ex: Exercise) {
    setEditingExercise(ex);
    setExTitle(ex.title);
    setExType(ex.exercise_type);
    setExForm(parseExerciseForm(ex.exercise_type, ex.content));
    setExFormError(null);
    setExerciseDialogOpen(true);
  }

  function handleTypeChange(type: ExerciseType) {
    setExType(type);
    setExForm(emptyExerciseForm());
    setExFormError(null);
  }

  function setCorrectOption(index: number) {
    setExForm((prev) => ({
      ...prev,
      options: prev.options.map((o, i) => ({ ...o, correct: i === index })),
    }));
  }

  async function saveExercise() {
    if (!lesson || !exTitle.trim()) return;

    const validationError = validateExerciseForm(exType, exForm);
    if (validationError) {
      setExFormError(validationError);
      return;
    }

    const contentPayload = buildExerciseContent(exType, exForm);
    setExFormError(null);
    setSaving(true);
    try {
      if (editingExercise) {
        const { error } = await supabase
          .from('elearning_exercises')
          .update({
            title: exTitle.trim(),
            exercise_type: exType,
            content: contentPayload,
          })
          .eq('id', editingExercise.id);
        if (error) throw error;
      } else {
        const nextIndex =
          exercises.length === 0
            ? 0
            : Math.max(...exercises.map((e) => e.order_index)) + 1;
        const { error } = await supabase.from('elearning_exercises').insert({
          lesson_id: lesson.id,
          title: exTitle.trim(),
          exercise_type: exType,
          content: contentPayload,
          order_index: nextIndex,
        });
        if (error) throw error;
      }
      setExerciseDialogOpen(false);
      await loadData();
    } catch (err) {
      console.error(err);
    } finally {
      setSaving(false);
    }
  }

  async function deleteExercise() {
    if (!deleteExerciseId) return;
    setSaving(true);
    try {
      const { error } = await supabase
        .from('elearning_exercises')
        .delete()
        .eq('id', deleteExerciseId);
      if (error) throw error;
      setDeleteExerciseId(null);
      await loadData();
    } catch (err) {
      console.error(err);
    } finally {
      setSaving(false);
    }
  }

  if (loading) {
    return (
      <div className="p-6 space-y-6 max-w-3xl mx-auto">
        <Skeleton className="h-8 w-64" />
        <Skeleton className="h-40 w-full rounded-xl" />
        <Skeleton className="h-40 w-full rounded-xl" />
      </div>
    );
  }

  if (!lesson) return null;

  return (
    <div className="p-6 space-y-6 max-w-3xl mx-auto">
      <div className="space-y-2">
        <Button
          asChild
          variant="ghost"
          size="sm"
          className="text-gray-500 hover:text-gray-800 -ml-2"
        >
          <Link href={`/dashboard/teacher/elearning/${moduleId}`}>
            <ArrowLeft className="w-4 h-4 mr-1" />
            Retour au module
          </Link>
        </Button>
        <div className="flex items-center gap-2 flex-wrap">
          <h1 className="text-2xl font-bold text-gray-900">Éditer la leçon</h1>
          {competency && (
            <Badge
              variant="secondary"
              className={`text-xs ${competencyColors[competency]}`}
            >
              {competency} — {competencyLabels[competency]}
            </Badge>
          )}
        </div>
        <p className="text-sm text-gray-500 truncate">{moduleTitle}</p>
      </div>

      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-base font-semibold">Contenu de la leçon</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="lesson-title">Titre</Label>
            <Input
              id="lesson-title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label>Compétence</Label>
            <Select
              value={competency}
              onValueChange={(v) => setCompetency(v as Competency)}
            >
              <SelectTrigger>
                <SelectValue placeholder="Choisir une compétence" />
              </SelectTrigger>
              <SelectContent>
                {COMPETENCIES.map((c) => (
                  <SelectItem key={c} value={c}>
                    {c} — {competencyLabels[c]}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label>Type de contenu</Label>
            <Select
              value={contentType}
              onValueChange={(v) => handleContentTypeChange(v as LessonContentType)}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {LESSON_CONTENT_TYPES.map((t) => (
                  <SelectItem key={t.value} value={t.value}>
                    {t.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {contentType === 'youtube' && (
            <div className="space-y-3">
              <div className="space-y-2">
                <Label htmlFor="youtube-url">URL YouTube</Label>
                <Input
                  id="youtube-url"
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  placeholder="https://www.youtube.com/watch?v=…"
                />
              </div>
              {content && getYoutubeEmbedUrl(content) ? (
                <LessonContentView contentType="youtube" content={content} />
              ) : content ? (
                <p className="text-xs text-amber-600">
                  Collez une URL YouTube valide pour afficher la prévisualisation.
                </p>
              ) : null}
            </div>
          )}

          {contentType === 'image' && (
            <div className="space-y-3">
              <div className="space-y-2">
                <Label htmlFor="lesson-image">Image</Label>
                <div className="flex flex-wrap items-center gap-2">
                  <Button
                    type="button"
                    variant="outline"
                    className="border-flehub-green text-flehub-green hover:bg-flehub-green-light"
                    disabled={uploading}
                    onClick={() => document.getElementById('lesson-image')?.click()}
                  >
                    {uploading ? (
                      'Upload…'
                    ) : (
                      <>
                        <Upload className="w-4 h-4 mr-1" />
                        {content ? "Remplacer l'image" : 'Uploader une image'}
                      </>
                    )}
                  </Button>
                  <input
                    id="lesson-image"
                    type="file"
                    accept="image/jpeg,image/png,image/webp,image/gif"
                    className="hidden"
                    onChange={(e) =>
                      handleMediaUpload(e.target.files?.[0] ?? null, 'image')
                    }
                  />
                  {content && (
                    <span className="text-xs text-gray-400 truncate max-w-[220px]" title={content}>
                      <ImageIcon className="w-3.5 h-3.5 inline mr-1" />
                      {content}
                    </span>
                  )}
                </div>
                {uploadError && <p className="text-xs text-red-500">{uploadError}</p>}
                <p className="text-xs text-gray-400">
                  Stocké dans le bucket{' '}
                  <code className="bg-gray-100 px-1 rounded">{MEDIA_BUCKET}</code>
                  {' '}(chemin dans <code className="bg-gray-100 px-1 rounded">content</code>).
                </p>
              </div>
              {content && <LessonContentView contentType="image" content={content} />}
            </div>
          )}

          {contentType === 'audio' && (
            <div className="space-y-3">
              <div className="space-y-2">
                <Label htmlFor="lesson-audio">Audio</Label>
                <div className="flex flex-wrap items-center gap-2">
                  <Button
                    type="button"
                    variant="outline"
                    className="border-flehub-green text-flehub-green hover:bg-flehub-green-light"
                    disabled={uploading}
                    onClick={() => document.getElementById('lesson-audio')?.click()}
                  >
                    {uploading ? (
                      'Upload…'
                    ) : (
                      <>
                        <Upload className="w-4 h-4 mr-1" />
                        {content ? "Remplacer l'audio" : 'Uploader un audio'}
                      </>
                    )}
                  </Button>
                  <input
                    id="lesson-audio"
                    type="file"
                    accept="audio/mpeg,audio/mp3,audio/wav,audio/x-m4a,audio/mp4,.mp3,.wav,.m4a"
                    className="hidden"
                    onChange={(e) =>
                      handleMediaUpload(e.target.files?.[0] ?? null, 'audio')
                    }
                  />
                  {content && (
                    <span className="text-xs text-gray-400 truncate max-w-[220px]" title={content}>
                      <Headphones className="w-3.5 h-3.5 inline mr-1" />
                      {content}
                    </span>
                  )}
                </div>
                {uploadError && <p className="text-xs text-red-500">{uploadError}</p>}
                <p className="text-xs text-gray-400">
                  Formats acceptés : MP3, WAV, M4A — bucket{' '}
                  <code className="bg-gray-100 px-1 rounded">{MEDIA_BUCKET}</code>.
                </p>
              </div>
              {content && <LessonContentView contentType="audio" content={content} />}
            </div>
          )}

          {contentType === 'pdf' && (
            <div className="space-y-3">
              <div className="space-y-2">
                <Label htmlFor="lesson-pdf">PDF</Label>
                <div className="flex flex-wrap items-center gap-2">
                  <Button
                    type="button"
                    variant="outline"
                    className="border-flehub-green text-flehub-green hover:bg-flehub-green-light"
                    disabled={uploading}
                    onClick={() => document.getElementById('lesson-pdf')?.click()}
                  >
                    {uploading ? (
                      'Upload…'
                    ) : (
                      <>
                        <Upload className="w-4 h-4 mr-1" />
                        {content ? 'Remplacer le PDF' : 'Uploader un PDF'}
                      </>
                    )}
                  </Button>
                  <input
                    id="lesson-pdf"
                    type="file"
                    accept="application/pdf,.pdf"
                    className="hidden"
                    onChange={(e) =>
                      handleMediaUpload(e.target.files?.[0] ?? null, 'pdf')
                    }
                  />
                  {content && (
                    <span className="text-xs text-gray-400 truncate max-w-[220px]" title={content}>
                      <FileText className="w-3.5 h-3.5 inline mr-1" />
                      {content}
                    </span>
                  )}
                </div>
                {uploadError && <p className="text-xs text-red-500">{uploadError}</p>}
                <p className="text-xs text-gray-400">
                  Stocké dans le bucket{' '}
                  <code className="bg-gray-100 px-1 rounded">{MEDIA_BUCKET}</code>
                  {' '}(chemin dans <code className="bg-gray-100 px-1 rounded">content</code>).
                </p>
              </div>
              {content && <LessonContentView contentType="pdf" content={content} />}
            </div>
          )}

          {contentType === 'text' && (
            <div className="space-y-2">
              <Label htmlFor="lesson-content">Contenu</Label>
              <Textarea
                id="lesson-content"
                rows={10}
                value={content}
                onChange={(e) => setContent(e.target.value)}
                placeholder="Instructions, texte de la leçon, consignes pour l'apprenant…"
                className="text-sm"
              />
            </div>
          )}

          <div className="flex justify-end">
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              disabled={saving || uploading || !title.trim() || !competency}
              onClick={saveLesson}
            >
              <Save className="w-4 h-4 mr-1" />
              {saving ? 'Enregistrement…' : 'Enregistrer la leçon'}
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="pb-3 flex flex-row items-center justify-between gap-3">
          <div>
            <CardTitle className="text-base font-semibold">Exercices</CardTitle>
            <p className="text-xs text-gray-400 mt-1">
              Table <code className="bg-gray-100 px-1 rounded">elearning_exercises</code>
              {' '}— <code className="bg-gray-100 px-1 rounded">exercise_type</code> +{' '}
              <code className="bg-gray-100 px-1 rounded">content</code> (jsonb)
            </p>
          </div>
          <Button
            size="sm"
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
            onClick={openCreateExercise}
          >
            <Plus className="w-4 h-4 mr-1" />
            Ajouter un exercice
          </Button>
        </CardHeader>
        <CardContent className="space-y-2">
          {exercises.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-10 text-gray-400">
              <ListChecks className="w-10 h-10 mb-2 opacity-40" />
              <p className="text-sm font-medium">Aucun exercice</p>
              <p className="text-xs">Ajoutez un QCM, association, texte à trous…</p>
            </div>
          ) : (
            exercises.map((ex) => (
              <div
                key={ex.id}
                className="flex items-center justify-between gap-3 p-3 rounded-lg border border-gray-100 bg-gray-50"
              >
                <div className="min-w-0">
                  <p className="text-sm font-medium text-gray-800 truncate">{ex.title}</p>
                  <Badge variant="secondary" className="text-xs mt-1">
                    {exerciseTypeLabels[ex.exercise_type] ?? ex.exercise_type}
                  </Badge>
                </div>
                <div className="flex gap-1 shrink-0">
                  <Button
                    variant="ghost"
                    size="sm"
                    className="text-flehub-green hover:bg-flehub-green-light"
                    onClick={() => openEditExercise(ex)}
                  >
                    <Pencil className="w-3.5 h-3.5" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    className="text-red-500 hover:bg-red-50"
                    onClick={() => setDeleteExerciseId(ex.id)}
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </Button>
                </div>
              </div>
            ))
          )}
        </CardContent>
      </Card>

      <Dialog open={exerciseDialogOpen} onOpenChange={setExerciseDialogOpen}>
        <DialogContent className="max-w-xl max-h-[90vh] overflow-y-auto bg-white">
          <DialogHeader>
            <DialogTitle>
              {editingExercise ? "Modifier l'exercice" : 'Ajouter un exercice'}
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-2">
              <Label htmlFor="ex-title">Titre</Label>
              <Input
                id="ex-title"
                value={exTitle}
                onChange={(e) => setExTitle(e.target.value)}
                placeholder="Ex. QCM — Vocabulaire"
              />
            </div>
            <div className="space-y-2">
              <Label>Type</Label>
              <Select
                value={exType}
                onValueChange={(v) => handleTypeChange(v as ExerciseType)}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-white">
                  {EXERCISE_TYPES.map((t) => (
                    <SelectItem key={t} value={t}>
                      {exerciseTypeLabels[t]}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {exType === 'qcm' && (
              <div className="space-y-4 rounded-lg border border-gray-100 bg-gray-50 p-4">
                <div className="space-y-2">
                  <Label htmlFor="qcm-question">Question</Label>
                  <Textarea
                    id="qcm-question"
                    rows={2}
                    value={exForm.question}
                    onChange={(e) =>
                      setExForm((prev) => ({ ...prev, question: e.target.value }))
                    }
                    placeholder="Posez votre question…"
                  />
                </div>
                <div className="space-y-3">
                  <Label>Réponses</Label>
                  {exForm.options.map((opt, index) => (
                    <div key={index} className="flex items-center gap-3">
                      <Input
                        value={opt.text}
                        onChange={(e) =>
                          setExForm((prev) => ({
                            ...prev,
                            options: prev.options.map((o, i) =>
                              i === index ? { ...o, text: e.target.value } : o
                            ),
                          }))
                        }
                        placeholder={`Réponse ${index + 1}`}
                        className="bg-white"
                      />
                      <label className="flex items-center gap-2 text-xs text-gray-600 whitespace-nowrap cursor-pointer">
                        <Checkbox
                          checked={opt.correct}
                          onCheckedChange={() => setCorrectOption(index)}
                        />
                        Bonne réponse
                      </label>
                    </div>
                  ))}
                </div>
                <div className="space-y-2">
                  <Label htmlFor="qcm-explanation">Explication</Label>
                  <Textarea
                    id="qcm-explanation"
                    rows={2}
                    value={exForm.explanation}
                    onChange={(e) =>
                      setExForm((prev) => ({ ...prev, explanation: e.target.value }))
                    }
                    placeholder="Pourquoi c'est la bonne réponse…"
                  />
                </div>
              </div>
            )}

            {exType === 'matching' && (
              <div className="space-y-3 rounded-lg border border-gray-100 bg-gray-50 p-4">
                <Label>Paires d&apos;association</Label>
                {exForm.pairs.map((pair, index) => (
                  <div key={index} className="flex items-center gap-2">
                    <Input
                      value={pair.left}
                      onChange={(e) =>
                        setExForm((prev) => ({
                          ...prev,
                          pairs: prev.pairs.map((p, i) =>
                            i === index ? { ...p, left: e.target.value } : p
                          ),
                        }))
                      }
                      placeholder="Colonne gauche"
                      className="bg-white"
                    />
                    <span className="text-gray-300">↔</span>
                    <Input
                      value={pair.right}
                      onChange={(e) =>
                        setExForm((prev) => ({
                          ...prev,
                          pairs: prev.pairs.map((p, i) =>
                            i === index ? { ...p, right: e.target.value } : p
                          ),
                        }))
                      }
                      placeholder="Colonne droite"
                      className="bg-white"
                    />
                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      className="text-red-500 hover:bg-red-50 shrink-0"
                      disabled={exForm.pairs.length <= 1}
                      onClick={() =>
                        setExForm((prev) => ({
                          ...prev,
                          pairs: prev.pairs.filter((_, i) => i !== index),
                        }))
                      }
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </Button>
                  </div>
                ))}
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  className="border-flehub-green text-flehub-green hover:bg-flehub-green-light"
                  onClick={() =>
                    setExForm((prev) => ({
                      ...prev,
                      pairs: [...prev.pairs, { left: '', right: '' }],
                    }))
                  }
                >
                  <Plus className="w-3.5 h-3.5 mr-1" />
                  Ajouter une paire
                </Button>
              </div>
            )}

            {exType === 'fill_blank' && (
              <div className="space-y-4 rounded-lg border border-gray-100 bg-gray-50 p-4">
                <div className="space-y-2">
                  <Label htmlFor="fb-prompt">Phrase avec le mot manquant</Label>
                  <Textarea
                    id="fb-prompt"
                    rows={3}
                    value={exForm.prompt}
                    onChange={(e) =>
                      setExForm((prev) => ({ ...prev, prompt: e.target.value }))
                    }
                    placeholder="Exemple : Je ___ français tous les jours."
                    className="bg-white"
                  />
                  <p className="text-xs text-gray-400">
                    Utilisez <code className="bg-white px-1 rounded border">___</code>{' '}
                    pour indiquer l&apos;emplacement du trou.
                  </p>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="fb-answer">Réponse attendue</Label>
                  <Input
                    id="fb-answer"
                    value={exForm.answer}
                    onChange={(e) =>
                      setExForm((prev) => ({ ...prev, answer: e.target.value }))
                    }
                    placeholder="parle"
                    className="bg-white"
                  />
                </div>
              </div>
            )}

            {exType === 'short_answer' && (
              <div className="space-y-2 rounded-lg border border-gray-100 bg-gray-50 p-4">
                <Label htmlFor="sa-prompt">Consigne</Label>
                <Textarea
                  id="sa-prompt"
                  rows={4}
                  value={exForm.prompt}
                  onChange={(e) =>
                    setExForm((prev) => ({ ...prev, prompt: e.target.value }))
                  }
                  placeholder="Question posée à l'apprenant (correction manuelle)…"
                  className="bg-white"
                />
              </div>
            )}

            {exFormError && <p className="text-xs text-red-500">{exFormError}</p>}
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setExerciseDialogOpen(false)}>
              Annuler
            </Button>
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              disabled={saving || !exTitle.trim()}
              onClick={saveExercise}
            >
              {saving ? 'Enregistrement…' : 'Enregistrer'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={!!deleteExerciseId} onOpenChange={() => setDeleteExerciseId(null)}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Supprimer cet exercice ?</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-gray-500">Cette action est irréversible.</p>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteExerciseId(null)}>
              Annuler
            </Button>
            <Button variant="destructive" disabled={saving} onClick={deleteExercise}>
              Supprimer
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
