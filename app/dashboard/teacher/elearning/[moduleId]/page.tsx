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
import {
  ArrowLeft,
  Plus,
  Trash2,
  BookOpen,
  Layers,
  ChevronRight,
  Pencil,
  CheckCircle2,
} from 'lucide-react';

type Competency = 'CO' | 'CE' | 'PE' | 'PO' | 'EL';

interface Sequence {
  id: string;
  title: string;
  order_index: number;
}

interface Lesson {
  id: string;
  sequence_id: string;
  title: string;
  competency: Competency | null;
  order_index: number;
}

interface ModuleInfo {
  id: string;
  title: string;
  description: string | null;
  cefr_level: string | null;
  published: boolean;
  teacher_id: string;
}

const COMPETENCIES: Competency[] = ['CO', 'CE', 'PE', 'PO', 'EL'];
const MAX_SEQUENCES = 9;

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

export default function TeacherModuleDetailPage() {
  const supabase = createClient();
  const router = useRouter();
  const params = useParams();
  const moduleId = typeof params.moduleId === 'string' ? params.moduleId : '';

  const [loading, setLoading] = useState(true);
  const [module, setModule] = useState<ModuleInfo | null>(null);
  const [sequences, setSequences] = useState<Sequence[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [busy, setBusy] = useState(false);

  const [sequenceDialogOpen, setSequenceDialogOpen] = useState(false);
  const [editingSequence, setEditingSequence] = useState<Sequence | null>(null);
  const [sequenceTitle, setSequenceTitle] = useState('');

  const [lessonDialogOpen, setLessonDialogOpen] = useState(false);
  const [lessonSequenceId, setLessonSequenceId] = useState<string | null>(null);
  const [lessonTitle, setLessonTitle] = useState('');
  const [lessonCompetency, setLessonCompetency] = useState<Competency | ''>('');

  const [deleteTarget, setDeleteTarget] = useState<
    | { type: 'sequence'; id: string }
    | { type: 'lesson'; id: string }
    | null
  >(null);

  const loadData = useCallback(async () => {
    if (!moduleId) return;
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

      const { data: mod, error: modErr } = await supabase
        .from('elearning_modules')
        .select('id, title, description, cefr_level, published, teacher_id')
        .eq('id', moduleId)
        .eq('teacher_id', teacher.id)
        .maybeSingle();

      if (modErr || !mod) {
        router.replace('/dashboard/teacher/elearning');
        return;
      }

      setModule(mod as ModuleInfo);

      const { data: seqRows } = await supabase
        .from('elearning_sequences')
        .select('id, title, order_index')
        .eq('module_id', moduleId)
        .order('order_index', { ascending: true });

      const seqList = (seqRows as Sequence[]) ?? [];
      setSequences(seqList);

      if (seqList.length > 0) {
        const { data: lessonRows } = await supabase
          .from('elearning_lessons')
          .select('id, sequence_id, title, competency, order_index')
          .in(
            'sequence_id',
            seqList.map((s) => s.id)
          )
          .order('order_index', { ascending: true });

        setLessons((lessonRows as Lesson[]) ?? []);
      } else {
        setLessons([]);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [moduleId, router]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  function openAddSequence() {
    setEditingSequence(null);
    setSequenceTitle(`Séquence ${sequences.length + 1}`);
    setSequenceDialogOpen(true);
  }

  function openEditSequence(seq: Sequence) {
    setEditingSequence(seq);
    setSequenceTitle(seq.title);
    setSequenceDialogOpen(true);
  }

  async function saveSequence() {
    if (!moduleId || !sequenceTitle.trim()) return;
    if (!editingSequence && sequences.length >= MAX_SEQUENCES) return;

    setBusy(true);
    try {
      if (editingSequence) {
        const { error } = await supabase
          .from('elearning_sequences')
          .update({ title: sequenceTitle.trim() })
          .eq('id', editingSequence.id);
        if (error) throw error;
      } else {
        const nextIndex =
          sequences.length === 0
            ? 0
            : Math.max(...sequences.map((s) => s.order_index)) + 1;
        const { error } = await supabase.from('elearning_sequences').insert({
          module_id: moduleId,
          title: sequenceTitle.trim(),
          order_index: nextIndex,
        });
        if (error) throw error;
      }
      setSequenceDialogOpen(false);
      await loadData();
    } catch (err) {
      console.error(err);
    } finally {
      setBusy(false);
    }
  }

  function openAddLesson(sequenceId: string) {
    setLessonSequenceId(sequenceId);
    setLessonTitle('');
    setLessonCompetency('');
    setLessonDialogOpen(true);
  }

  async function saveLesson() {
    if (!lessonSequenceId || !lessonTitle.trim() || !lessonCompetency) return;
    setBusy(true);
    try {
      const seqLessons = lessons.filter((l) => l.sequence_id === lessonSequenceId);
      const nextIndex =
        seqLessons.length === 0
          ? 0
          : Math.max(...seqLessons.map((l) => l.order_index)) + 1;

      const { error } = await supabase.from('elearning_lessons').insert({
        sequence_id: lessonSequenceId,
        title: lessonTitle.trim(),
        competency: lessonCompetency,
        content_type: 'text',
        content: '',
        order_index: nextIndex,
      });
      if (error) throw error;

      setLessonDialogOpen(false);
      await loadData();
    } catch (err) {
      console.error(err);
    } finally {
      setBusy(false);
    }
  }

  async function confirmDelete() {
    if (!deleteTarget) return;
    setBusy(true);
    try {
      if (deleteTarget.type === 'sequence') {
        const { error } = await supabase
          .from('elearning_sequences')
          .delete()
          .eq('id', deleteTarget.id);
        if (error) throw error;
      } else {
        const { error } = await supabase
          .from('elearning_lessons')
          .delete()
          .eq('id', deleteTarget.id);
        if (error) throw error;
      }
      setDeleteTarget(null);
      await loadData();
    } catch (err) {
      console.error(err);
    } finally {
      setBusy(false);
    }
  }

  async function publishModule() {
    if (!module) return;
    setBusy(true);
    try {
      const { error } = await supabase
        .from('elearning_modules')
        .update({ published: true, updated_at: new Date().toISOString() })
        .eq('id', module.id);
      if (error) throw error;
      setModule({ ...module, published: true });
    } catch (err) {
      console.error(err);
    } finally {
      setBusy(false);
    }
  }

  if (loading) {
    return (
      <div className="p-6 space-y-6 max-w-5xl mx-auto">
        <Skeleton className="h-8 w-64" />
        <Skeleton className="h-4 w-96" />
        <Skeleton className="h-40 w-full rounded-xl" />
        <Skeleton className="h-40 w-full rounded-xl" />
      </div>
    );
  }

  if (!module) return null;

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
        <div className="space-y-2">
          <Button
            asChild
            variant="ghost"
            size="sm"
            className="text-gray-500 hover:text-gray-800 -ml-2"
          >
            <Link href="/dashboard/teacher/elearning">
              <ArrowLeft className="w-4 h-4 mr-1" />
              Retour aux modules
            </Link>
          </Button>
          <div className="flex items-center gap-2 flex-wrap">
            <h1 className="text-2xl font-bold text-gray-900">{module.title}</h1>
            <Badge
              variant="outline"
              className={
                module.published
                  ? 'border-flehub-green text-flehub-green bg-flehub-green-light'
                  : 'border-gray-300 text-gray-400'
              }
            >
              {module.published ? 'Publié' : 'Brouillon'}
            </Badge>
            {module.cefr_level && (
              <Badge variant="secondary" className="text-xs">
                {module.cefr_level}
              </Badge>
            )}
          </div>
          <p className="text-sm text-gray-500">
            {module.description || 'Gérez les séquences et leçons de ce module'}
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button
            variant="outline"
            disabled={sequences.length >= MAX_SEQUENCES || busy}
            onClick={openAddSequence}
          >
            <Plus className="w-4 h-4 mr-1" />
            Ajouter une séquence
            <span className="ml-1 text-xs text-gray-400">
              ({sequences.length}/{MAX_SEQUENCES})
            </span>
          </Button>
          <Button
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
            disabled={busy || module.published}
            onClick={publishModule}
          >
            <CheckCircle2 className="w-4 h-4 mr-1" />
            {module.published ? 'Déjà publié' : 'Publier le module'}
          </Button>
        </div>
      </div>

      {sequences.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-gray-400 border border-dashed border-gray-200 rounded-xl">
          <Layers className="w-12 h-12 mb-3 opacity-40" />
          <p className="text-lg font-medium">Aucune séquence</p>
          <p className="text-sm mb-4">Ajoutez jusqu&apos;à {MAX_SEQUENCES} séquences pour structurer le module</p>
          <Button
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
            onClick={openAddSequence}
          >
            <Plus className="w-4 h-4 mr-1" />
            Ajouter une séquence
          </Button>
        </div>
      ) : (
        <div className="space-y-4">
          {sequences.map((seq, seqIdx) => {
            const seqLessons = lessons.filter((l) => l.sequence_id === seq.id);
            return (
              <Card key={seq.id}>
                <CardHeader className="pb-3">
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="p-2 rounded-lg bg-flehub-green-light shrink-0">
                        <Layers className="w-5 h-5 text-flehub-green" />
                      </div>
                      <div className="min-w-0">
                        <CardTitle className="text-base font-semibold truncate">
                          {seq.title || `Séquence ${seqIdx + 1}`}
                        </CardTitle>
                        <p className="text-xs text-gray-400 mt-0.5">
                          {seqLessons.length} leçon{seqLessons.length !== 1 ? 's' : ''}
                        </p>
                      </div>
                    </div>
                    <div className="flex gap-1 shrink-0">
                      <Button
                        variant="ghost"
                        size="sm"
                        className="text-flehub-green hover:bg-flehub-green-light"
                        onClick={() => openEditSequence(seq)}
                      >
                        <Pencil className="w-3.5 h-3.5" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="text-red-500 hover:bg-red-50"
                        onClick={() => setDeleteTarget({ type: 'sequence', id: seq.id })}
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        className="border-flehub-green text-flehub-green hover:bg-flehub-green-light"
                        onClick={() => openAddLesson(seq.id)}
                      >
                        <Plus className="w-3.5 h-3.5 mr-1" />
                        Ajouter une leçon
                      </Button>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="space-y-2">
                  {seqLessons.length === 0 ? (
                    <p className="text-sm text-gray-400 py-3 text-center">
                      Aucune leçon dans cette séquence
                    </p>
                  ) : (
                    seqLessons.map((lesson) => {
                      const comp = lesson.competency as Competency | null;
                      return (
                        <div
                          key={lesson.id}
                          className="flex items-center justify-between gap-3 p-3 rounded-lg border border-gray-100 bg-gray-50 hover:bg-flehub-green-light/40 hover:border-flehub-green/30 transition-colors group"
                        >
                          <Link
                            href={`/dashboard/teacher/elearning/${moduleId}/lesson/${lesson.id}`}
                            className="flex items-center gap-3 min-w-0 flex-1"
                          >
                            <BookOpen className="w-4 h-4 text-gray-400 group-hover:text-flehub-green shrink-0" />
                            <p className="text-sm font-medium text-gray-800 truncate">
                              {lesson.title || 'Sans titre'}
                            </p>
                            {comp && (
                              <Badge
                                variant="secondary"
                                className={`text-xs shrink-0 ${competencyColors[comp]}`}
                                title={competencyLabels[comp]}
                              >
                                {comp}
                              </Badge>
                            )}
                            <ChevronRight className="w-4 h-4 text-gray-300 group-hover:text-flehub-green ml-auto shrink-0" />
                          </Link>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-red-400 hover:text-red-600 hover:bg-red-50 h-8 w-8 p-0 shrink-0"
                            onClick={() =>
                              setDeleteTarget({ type: 'lesson', id: lesson.id })
                            }
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </Button>
                        </div>
                      );
                    })
                  )}
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}

      <Dialog open={sequenceDialogOpen} onOpenChange={setSequenceDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>
              {editingSequence ? 'Modifier la séquence' : 'Ajouter une séquence'}
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-2 py-2">
            <Label htmlFor="seq-title">Titre</Label>
            <Input
              id="seq-title"
              value={sequenceTitle}
              onChange={(e) => setSequenceTitle(e.target.value)}
              placeholder="Ex. Séquence 1 — Découverte"
            />
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setSequenceDialogOpen(false)}>
              Annuler
            </Button>
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              disabled={busy || !sequenceTitle.trim()}
              onClick={saveSequence}
            >
              {busy ? 'Enregistrement…' : 'Enregistrer'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={lessonDialogOpen} onOpenChange={setLessonDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Ajouter une leçon</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-2">
              <Label htmlFor="lesson-title">Titre</Label>
              <Input
                id="lesson-title"
                value={lessonTitle}
                onChange={(e) => setLessonTitle(e.target.value)}
                placeholder="Ex. Comprendre un dialogue"
              />
            </div>
            <div className="space-y-2">
              <Label>Compétence</Label>
              <Select
                value={lessonCompetency}
                onValueChange={(v) => setLessonCompetency(v as Competency)}
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
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setLessonDialogOpen(false)}>
              Annuler
            </Button>
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              disabled={busy || !lessonTitle.trim() || !lessonCompetency}
              onClick={saveLesson}
            >
              {busy ? 'Enregistrement…' : 'Créer la leçon'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={!!deleteTarget} onOpenChange={() => setDeleteTarget(null)}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>
              {deleteTarget?.type === 'sequence'
                ? 'Supprimer cette séquence ?'
                : 'Supprimer cette leçon ?'}
            </DialogTitle>
          </DialogHeader>
          <p className="text-sm text-gray-500">
            {deleteTarget?.type === 'sequence'
              ? 'Toutes les leçons et exercices de cette séquence seront également supprimés.'
              : 'Les exercices liés à cette leçon seront également supprimés.'}
          </p>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteTarget(null)}>
              Annuler
            </Button>
            <Button variant="destructive" disabled={busy} onClick={confirmDelete}>
              Supprimer
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
