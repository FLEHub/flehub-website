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
import { ArrowLeft, Plus, Trash2, Pencil, ListChecks, Save } from 'lucide-react';

type Competency = 'CO' | 'CE' | 'PE' | 'PO' | 'EL';
type ExerciseType = 'qcm' | 'matching' | 'fill_blank' | 'short_answer';

interface Lesson {
  id: string;
  sequence_id: string;
  title: string;
  competency: Competency | null;
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
  short_answer: 'Réponse courte',
};

function defaultContent(type: ExerciseType): Record<string, unknown> {
  switch (type) {
    case 'qcm':
      return {
        question: '',
        options: ['', '', '', ''],
        correct_index: 0,
      };
    case 'fill_blank':
      return { prompt: '', answer: '' };
    case 'short_answer':
      return { question: '', sample_answer: '' };
    case 'matching':
      return {
        pairs: [
          { left: '', right: '' },
          { left: '', right: '' },
        ],
      };
    default:
      return {};
  }
}

function contentToEditorString(content: unknown): string {
  try {
    return JSON.stringify(content ?? {}, null, 2);
  } catch {
    return '{}';
  }
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
  const [content, setContent] = useState('');

  const [exerciseDialogOpen, setExerciseDialogOpen] = useState(false);
  const [editingExercise, setEditingExercise] = useState<Exercise | null>(null);
  const [exTitle, setExTitle] = useState('');
  const [exType, setExType] = useState<ExerciseType>('qcm');
  const [exContentJson, setExContentJson] = useState('{}');
  const [exJsonError, setExJsonError] = useState<string | null>(null);
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
        .select('id, sequence_id, title, competency, content, order_index')
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

      const typed = lessonRow as Lesson;
      setLesson(typed);
      setTitle(typed.title ?? '');
      setCompetency((typed.competency as Competency) ?? '');
      setContent(typed.content ?? '');

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

  async function saveLesson() {
    if (!lesson || !title.trim() || !competency) return;
    setSaving(true);
    try {
      const { error } = await supabase
        .from('elearning_lessons')
        .update({
          title: title.trim(),
          competency,
          content,
        })
        .eq('id', lesson.id);
      if (error) throw error;
      setLesson({ ...lesson, title: title.trim(), competency, content });
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
    setExContentJson(contentToEditorString(defaultContent('qcm')));
    setExJsonError(null);
    setExerciseDialogOpen(true);
  }

  function openEditExercise(ex: Exercise) {
    setEditingExercise(ex);
    setExTitle(ex.title);
    setExType(ex.exercise_type);
    setExContentJson(contentToEditorString(ex.content));
    setExJsonError(null);
    setExerciseDialogOpen(true);
  }

  function handleTypeChange(type: ExerciseType) {
    setExType(type);
    if (!editingExercise) {
      setExContentJson(contentToEditorString(defaultContent(type)));
      setExJsonError(null);
    }
  }

  async function saveExercise() {
    if (!lesson || !exTitle.trim()) return;

    let parsed: Record<string, unknown>;
    try {
      const value = JSON.parse(exContentJson);
      if (!value || typeof value !== 'object' || Array.isArray(value)) {
        setExJsonError('Le contenu doit être un objet JSON');
        return;
      }
      parsed = value as Record<string, unknown>;
      setExJsonError(null);
    } catch {
      setExJsonError('JSON invalide');
      return;
    }

    setSaving(true);
    try {
      if (editingExercise) {
        const { error } = await supabase
          .from('elearning_exercises')
          .update({
            title: exTitle.trim(),
            exercise_type: exType,
            content: parsed,
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
          content: parsed,
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
            <Label htmlFor="lesson-content">Contenu</Label>
            <Textarea
              id="lesson-content"
              rows={10}
              value={content}
              onChange={(e) => setContent(e.target.value)}
              placeholder="Instructions, texte de la leçon, consignes pour l'apprenant…"
              className="font-mono text-sm"
            />
            <p className="text-xs text-gray-400">
              Champ <code className="bg-gray-100 px-1 rounded">content</code> de la
              leçon (texte libre).
            </p>
          </div>
          <div className="flex justify-end">
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              disabled={saving || !title.trim() || !competency}
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
        <DialogContent className="max-w-xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              {editingExercise ? 'Modifier l’exercice' : 'Ajouter un exercice'}
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
                <SelectContent>
                  {EXERCISE_TYPES.map((t) => (
                    <SelectItem key={t} value={t}>
                      {exerciseTypeLabels[t]}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label htmlFor="ex-content">Contenu (JSON)</Label>
              <Textarea
                id="ex-content"
                rows={12}
                value={exContentJson}
                onChange={(e) => {
                  setExContentJson(e.target.value);
                  setExJsonError(null);
                }}
                className="font-mono text-xs"
              />
              {exJsonError ? (
                <p className="text-xs text-red-500">{exJsonError}</p>
              ) : (
                <p className="text-xs text-gray-400">
                  Stocké dans la colonne{' '}
                  <code className="bg-gray-100 px-1 rounded">content</code> (jsonb).
                  Un modèle est prérempli selon le type.
                </p>
              )}
            </div>
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
