'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import {
  ArrowLeft,
  BookOpen,
  CheckCircle2,
  ChevronRight,
  Loader2,
  Mic,
  Play,
  Video,
} from 'lucide-react';
import { createClient } from '@/lib/supabase/client';
import { getCurrentLearnerId } from '@/lib/learner-session';
import { MEDIA_BUCKET, normalizeContentType } from '@/lib/elearning-content';
import type { ExerciseType } from '@/lib/elearning-exercises';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Progress } from '@/components/ui/progress';
import { Textarea } from '@/components/ui/textarea';
import { LessonContentView } from '@/components/dashboard/lesson-content-view';
import {
  ElearningExercisePlayer,
  type PlayableExercise,
} from '@/components/dashboard/elearning-exercise-player';

type ModuleRow = {
  id: string;
  title: string;
  description: string | null;
  cefr_level: string | null;
  published: boolean;
};

type SequenceRow = {
  id: string;
  title: string;
  order_index: number;
};

type LessonRow = {
  id: string;
  sequence_id: string;
  title: string;
  content: string | null;
  content_type: string | null;
  competency: string | null;
  order_index: number;
};

type ExerciseRow = {
  id: string;
  lesson_id: string;
  title: string;
  exercise_type: ExerciseType;
  content: Record<string, unknown>;
  order_index: number;
};

type ProgressRow = {
  lesson_id: string;
  completed_at: string | null;
};

export default function LearnerModulePage() {
  const params = useParams();
  const moduleId = params.moduleId as string;
  const supabase = useMemo(() => createClient(), []);

  const [learnerId, setLearnerId] = useState<string | null>(null);
  const [module, setModule] = useState<ModuleRow | null>(null);
  const [sequences, setSequences] = useState<SequenceRow[]>([]);
  const [lessons, setLessons] = useState<LessonRow[]>([]);
  const [exercises, setExercises] = useState<ExerciseRow[]>([]);
  const [progressMap, setProgressMap] = useState<Record<string, ProgressRow>>({});
  const [selectedLessonId, setSelectedLessonId] = useState<string | null>(null);
  const [activeExerciseIndex, setActiveExerciseIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [enrolled, setEnrolled] = useState(false);
  const [peText, setPeText] = useState('');
  const [poFile, setPoFile] = useState<File | null>(null);
  const [submissionStatus, setSubmissionStatus] = useState<{
    content: string;
    validated: boolean;
    teacher_feedback: string | null;
  } | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const lid = await getCurrentLearnerId(supabase);
      if (!lid) {
        setError('Profil apprenant introuvable.');
        return;
      }
      setLearnerId(lid);

      const { data: mod, error: modErr } = await supabase
        .from('elearning_modules')
        .select('id, title, description, cefr_level, published')
        .eq('id', moduleId)
        .single();
      if (modErr) throw modErr;
      setModule(mod as ModuleRow);

      const { data: enrollment } = await supabase
        .from('elearning_enrollments')
        .select('id')
        .eq('learner_id', lid)
        .eq('module_id', moduleId)
        .maybeSingle();

      if (!enrollment) {
        setEnrolled(false);
        setError("Vous n'êtes pas inscrit à ce module.");
        return;
      }
      setEnrolled(true);

      const { data: seqs, error: seqErr } = await supabase
        .from('elearning_sequences')
        .select('id, title, order_index')
        .eq('module_id', moduleId)
        .order('order_index', { ascending: true });
      if (seqErr) throw seqErr;
      const sequenceList = (seqs ?? []) as SequenceRow[];
      setSequences(sequenceList);

      const seqIds = sequenceList.map((s) => s.id);
      if (seqIds.length === 0) {
        setLessons([]);
        setExercises([]);
        setProgressMap({});
        return;
      }

      const { data: lessonRows, error: lessonErr } = await supabase
        .from('elearning_lessons')
        .select(
          'id, sequence_id, title, content, content_type, competency, order_index'
        )
        .in('sequence_id', seqIds)
        .order('order_index', { ascending: true });
      if (lessonErr) throw lessonErr;
      const lessonList = (lessonRows ?? []) as LessonRow[];
      setLessons(lessonList);

      const lessonIds = lessonList.map((l) => l.id);
      let progMap: Record<string, ProgressRow> = {};
      if (lessonIds.length > 0) {
        const [{ data: exRows }, { data: progRows }] = await Promise.all([
          supabase
            .from('elearning_exercises')
            .select('id, lesson_id, title, exercise_type, content, order_index')
            .in('lesson_id', lessonIds)
            .order('order_index', { ascending: true }),
          supabase
            .from('elearning_progress')
            .select('lesson_id, completed_at')
            .eq('learner_id', lid)
            .in('lesson_id', lessonIds),
        ]);
        setExercises(
          ((exRows ?? []) as ExerciseRow[]).map((e) => {
            const raw = e.content as unknown;
            let content: Record<string, unknown> = {};
            if (typeof raw === 'string') {
              try {
                const parsed = JSON.parse(raw);
                if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
                  content = parsed as Record<string, unknown>;
                }
              } catch {
                content = {};
              }
            } else if (raw && typeof raw === 'object' && !Array.isArray(raw)) {
              content = raw as Record<string, unknown>;
            }
            return { ...e, content };
          })
        );
        for (const p of progRows ?? []) {
          progMap[p.lesson_id as string] = p as ProgressRow;
        }
        setProgressMap(progMap);
      }

      const bySeq = new Map(sequenceList.map((s) => [s.id, s.order_index]));
      const ordered = [...lessonList].sort((a, b) => {
        const sa = bySeq.get(a.sequence_id) ?? 0;
        const sb = bySeq.get(b.sequence_id) ?? 0;
        if (sa !== sb) return sa - sb;
        return a.order_index - b.order_index;
      });

      setSelectedLessonId((prev) => {
        if (prev && ordered.some((l) => l.id === prev)) return prev;
        const firstIncomplete =
          ordered.find((l) => !progMap[l.id]?.completed_at) ?? ordered[0];
        return firstIncomplete?.id ?? null;
      });
    } catch (err) {
      const message =
        err instanceof Error
          ? err.message
          : typeof err === 'object' &&
              err !== null &&
              'message' in err &&
              typeof (err as { message: unknown }).message === 'string'
            ? (err as { message: string }).message
            : 'Erreur de chargement';
      setError(message);
    } finally {
      setLoading(false);
    }
  }, [moduleId, supabase]);

  useEffect(() => {
    void load();
  }, [load]);

  const orderedLessons = useMemo(() => {
    const bySeq = new Map(sequences.map((s) => [s.id, s.order_index]));
    return [...lessons].sort((a, b) => {
      const sa = bySeq.get(a.sequence_id) ?? 0;
      const sb = bySeq.get(b.sequence_id) ?? 0;
      if (sa !== sb) return sa - sb;
      return a.order_index - b.order_index;
    });
  }, [lessons, sequences]);

  const selectedLesson =
    orderedLessons.find((l) => l.id === selectedLessonId) ?? null;

  const lessonExercises = useMemo(
    () =>
      exercises
        .filter((e) => e.lesson_id === selectedLessonId)
        .sort((a, b) => a.order_index - b.order_index),
    [exercises, selectedLessonId]
  );

  const completedCount = orderedLessons.filter(
    (l) => progressMap[l.id]?.completed_at
  ).length;
  const progressPct =
    orderedLessons.length > 0
      ? Math.round((completedCount / orderedLessons.length) * 100)
      : 0;

  const isPePo =
    selectedLesson?.competency === 'PE' || selectedLesson?.competency === 'PO';

  useEffect(() => {
    if (!learnerId || !selectedLesson || !isPePo) {
      setSubmissionStatus(null);
      setPeText('');
      setPoFile(null);
      return;
    }

    let cancelled = false;
    (async () => {
      const { data } = await supabase
        .from('elearning_submissions')
        .select('content, validated, teacher_feedback')
        .eq('learner_id', learnerId)
        .eq('lesson_id', selectedLesson.id)
        .maybeSingle();
      if (cancelled) return;
      if (data) {
        setSubmissionStatus({
          content: data.content ?? '',
          validated: !!data.validated,
          teacher_feedback: data.teacher_feedback,
        });
        if (selectedLesson.competency === 'PE') {
          setPeText(data.content ?? '');
        }
      } else {
        setSubmissionStatus(null);
        setPeText('');
      }
      setPoFile(null);
    })();

    return () => {
      cancelled = true;
    };
  }, [learnerId, selectedLesson, isPePo, supabase]);

  async function markLessonComplete(lessonId: string) {
    if (!learnerId) return;
    setSaving(true);
    setError(null);
    try {
      const now = new Date().toISOString();
      const { error: upsertErr } = await supabase.from('elearning_progress').upsert(
        {
          learner_id: learnerId,
          lesson_id: lessonId,
          completed_at: now,
        },
        { onConflict: 'learner_id,lesson_id' }
      );
      if (upsertErr) throw upsertErr;

      setProgressMap((prev) => ({
        ...prev,
        [lessonId]: { lesson_id: lessonId, completed_at: now },
      }));

      const nextIncomplete = orderedLessons.find(
        (l) => l.id !== lessonId && !progressMap[l.id]?.completed_at
      );
      if (nextIncomplete) {
        setSelectedLessonId(nextIncomplete.id);
        setActiveExerciseIndex(0);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur de sauvegarde');
    } finally {
      setSaving(false);
    }
  }

  async function handleExerciseResult(result: {
    correct: boolean | null;
    detail?: string;
  }) {
    if (!selectedLesson) return;
    // short_answer: teacher-style free answer — still advance / complete
    if (result.correct === false) return;

    if (activeExerciseIndex < lessonExercises.length - 1) {
      setActiveExerciseIndex((i) => i + 1);
      return;
    }
    await markLessonComplete(selectedLesson.id);
  }

  async function submitPePo() {
    if (!learnerId || !selectedLesson) return;
    setSaving(true);
    setError(null);
    try {
      let content = '';
      if (selectedLesson.competency === 'PE') {
        content = peText.trim();
        if (!content) throw new Error('Rédigez votre production écrite.');
      } else {
        if (!poFile && !submissionStatus?.content) {
          throw new Error('Choisissez un fichier audio.');
        }
        if (poFile) {
          const ext = poFile.name.split('.').pop()?.toLowerCase() || 'webm';
          const path = `submissions/${learnerId}/${selectedLesson.id}/${Date.now()}.${ext}`;
          const { error: upErr } = await supabase.storage
            .from(MEDIA_BUCKET)
            .upload(path, poFile, {
              upsert: true,
              contentType: poFile.type || undefined,
            });
          if (upErr) throw upErr;
          if (
            submissionStatus?.content &&
            submissionStatus.content !== path
          ) {
            await supabase.storage
              .from(MEDIA_BUCKET)
              .remove([submissionStatus.content]);
          }
          content = path;
        } else {
          content = submissionStatus!.content;
        }
      }

      const now = new Date().toISOString();
      if (submissionStatus) {
        const { error: updErr } = await supabase
          .from('elearning_submissions')
          .update({
            content,
            validated: false,
            teacher_feedback: null,
            submitted_at: now,
            validated_at: null,
          })
          .eq('learner_id', learnerId)
          .eq('lesson_id', selectedLesson.id);
        if (updErr) throw updErr;
      } else {
        const { error: insErr } = await supabase
          .from('elearning_submissions')
          .insert({
            learner_id: learnerId,
            lesson_id: selectedLesson.id,
            content,
            submitted_at: now,
          });
        if (insErr) throw insErr;
      }

      setSubmissionStatus({
        content,
        validated: false,
        teacher_feedback: null,
      });
      await markLessonComplete(selectedLesson.id);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur d’envoi');
    } finally {
      setSaving(false);
    }
  }

  if (loading) {
    return (
      <div className="space-y-6 p-6 max-w-6xl mx-auto">
        <Skeleton className="h-8 w-64" />
        <Skeleton className="h-4 w-full max-w-md" />
        <div className="grid gap-4 lg:grid-cols-[280px_1fr]">
          <Skeleton className="h-64" />
          <Skeleton className="h-96" />
        </div>
      </div>
    );
  }

  if (!module || !enrolled) {
    return (
      <div className="space-y-4 p-6 max-w-6xl mx-auto">
        <p className="text-destructive">{error ?? 'Module introuvable'}</p>
        <Button variant="outline" asChild>
          <Link href="/dashboard/learner/elearning">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Retour aux modules
          </Link>
        </Button>
      </div>
    );
  }

  const currentExercise = lessonExercises[activeExerciseIndex] ?? null;
  const playerData: PlayableExercise | null = currentExercise
    ? {
        id: currentExercise.id,
        title: currentExercise.title,
        exercise_type: currentExercise.exercise_type,
        content: currentExercise.content ?? {},
      }
    : null;

  return (
    <div className="space-y-6 p-6 max-w-6xl mx-auto">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div className="space-y-2">
          <Button variant="ghost" size="sm" className="-ml-2" asChild>
            <Link href="/dashboard/learner/elearning">
              <ArrowLeft className="mr-1 h-4 w-4" />
              Modules
            </Link>
          </Button>
          <div className="flex flex-wrap items-center gap-2">
            <h1 className="text-2xl font-bold tracking-tight text-gray-900">
              {module.title}
            </h1>
            {module.cefr_level && (
              <Badge variant="secondary">{module.cefr_level}</Badge>
            )}
          </div>
          {module.description && (
            <p className="max-w-2xl text-sm text-muted-foreground">
              {module.description}
            </p>
          )}
        </div>
        <Button variant="outline" asChild>
          <Link href={`/dashboard/learner/elearning/${moduleId}/capsule`}>
            <Video className="mr-2 h-4 w-4" />
            Capsule vidéo
          </Link>
        </Button>
      </div>

      <div className="space-y-2">
        <div className="flex items-center justify-between text-sm">
          <span className="text-muted-foreground">Progression du module</span>
          <span className="font-medium">{progressPct}%</span>
        </div>
        <Progress value={progressPct} className="h-2" />
      </div>

      {error && (
        <div className="rounded-lg border border-destructive/30 bg-destructive/5 px-4 py-3 text-sm text-destructive">
          {error}
        </div>
      )}

      <div className="grid gap-6 lg:grid-cols-[280px_1fr]">
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-base">Parcours</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {sequences.length === 0 ? (
              <p className="text-sm text-muted-foreground">
                Aucune séquence pour l&apos;instant.
              </p>
            ) : (
              sequences.map((seq) => {
                const seqLessons = orderedLessons.filter(
                  (l) => l.sequence_id === seq.id
                );
                return (
                  <div key={seq.id} className="space-y-1">
                    <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                      {seq.title}
                    </p>
                    {seqLessons.map((lesson) => {
                      const done = !!progressMap[lesson.id]?.completed_at;
                      const active = lesson.id === selectedLessonId;
                      return (
                        <button
                          key={lesson.id}
                          type="button"
                          onClick={() => {
                            setSelectedLessonId(lesson.id);
                            setActiveExerciseIndex(0);
                            setError(null);
                          }}
                          className={`flex w-full items-center gap-2 rounded-md px-2 py-2 text-left text-sm transition-colors ${
                            active
                              ? 'bg-flehub-green/10 font-medium text-flehub-green'
                              : 'hover:bg-muted'
                          }`}
                        >
                          {done ? (
                            <CheckCircle2 className="h-4 w-4 shrink-0 text-flehub-green" />
                          ) : (
                            <Play className="h-4 w-4 shrink-0 text-muted-foreground" />
                          )}
                          <span className="truncate">{lesson.title}</span>
                          {active && (
                            <ChevronRight className="ml-auto h-4 w-4 shrink-0" />
                          )}
                        </button>
                      );
                    })}
                  </div>
                );
              })
            )}
          </CardContent>
        </Card>

        <div className="space-y-4">
          {!selectedLesson ? (
            <Card>
              <CardContent className="flex flex-col items-center py-16 text-center">
                <BookOpen className="mb-3 h-10 w-10 text-muted-foreground/40" />
                <p className="text-muted-foreground">
                  Sélectionnez une leçon pour commencer.
                </p>
              </CardContent>
            </Card>
          ) : (
            <>
              <Card>
                <CardHeader className="flex flex-row items-center justify-between gap-2 space-y-0">
                  <CardTitle className="text-lg">{selectedLesson.title}</CardTitle>
                  {selectedLesson.competency && (
                    <Badge variant="outline">{selectedLesson.competency}</Badge>
                  )}
                </CardHeader>
                <CardContent>
                  <LessonContentView
                    content={selectedLesson.content ?? ''}
                    contentType={normalizeContentType(selectedLesson.content_type)}
                  />
                </CardContent>
              </Card>

              {isPePo ? (
                <Card>
                  <CardHeader>
                    <CardTitle className="text-base">
                      {selectedLesson.competency === 'PE'
                        ? 'Production écrite'
                        : 'Production orale'}
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    {submissionStatus?.validated && (
                      <div className="rounded-md border border-flehub-green/30 bg-flehub-green-light/40 px-3 py-2 text-sm text-flehub-green">
                        Validée par l&apos;enseignant
                        {submissionStatus.teacher_feedback
                          ? ` — ${submissionStatus.teacher_feedback}`
                          : ''}
                      </div>
                    )}
                    {submissionStatus && !submissionStatus.validated && (
                      <p className="text-sm text-muted-foreground">
                        Déjà envoyée — en attente de correction.
                      </p>
                    )}
                    {selectedLesson.competency === 'PE' ? (
                      <Textarea
                        value={peText}
                        onChange={(e) => setPeText(e.target.value)}
                        rows={8}
                        placeholder="Écrivez votre texte…"
                        disabled={submissionStatus?.validated}
                      />
                    ) : (
                      <div className="space-y-2">
                        <label className="flex items-center gap-2 text-sm text-muted-foreground">
                          <Mic className="h-4 w-4" />
                          Fichier audio (mp3, wav, webm…)
                        </label>
                        <input
                          type="file"
                          accept="audio/*"
                          disabled={submissionStatus?.validated}
                          onChange={(e) =>
                            setPoFile(e.target.files?.[0] ?? null)
                          }
                        />
                        {submissionStatus?.content && !poFile && (
                          <p className="text-xs text-muted-foreground">
                            Audio déjà déposé. Choisissez un nouveau fichier pour
                            remplacer.
                          </p>
                        )}
                      </div>
                    )}
                    {!submissionStatus?.validated && (
                      <Button
                        className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                        disabled={saving}
                        onClick={() => void submitPePo()}
                      >
                        {saving && (
                          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        )}
                        Envoyer
                      </Button>
                    )}
                  </CardContent>
                </Card>
              ) : lessonExercises.length === 0 ? (
                <Card>
                  <CardContent className="flex flex-col items-center gap-3 py-10 text-center">
                    <p className="text-sm text-muted-foreground">
                      Pas d&apos;exercice sur cette leçon.
                    </p>
                    {!progressMap[selectedLesson.id]?.completed_at ? (
                      <Button
                        className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                        disabled={saving}
                        onClick={() => void markLessonComplete(selectedLesson.id)}
                      >
                        {saving && (
                          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        )}
                        Marquer comme terminée
                      </Button>
                    ) : (
                      <Badge className="bg-flehub-green hover:bg-flehub-green">
                        Terminée
                      </Badge>
                    )}
                  </CardContent>
                </Card>
              ) : playerData ? (
                <div className="space-y-3">
                  <div className="flex items-center justify-between text-sm text-muted-foreground">
                    <span>
                      Exercice {activeExerciseIndex + 1} /{' '}
                      {lessonExercises.length}
                    </span>
                    {progressMap[selectedLesson.id]?.completed_at && (
                      <Badge variant="secondary">Leçon déjà terminée</Badge>
                    )}
                  </div>
                  <Card>
                    <CardContent className="pt-6">
                      <ElearningExercisePlayer
                        key={playerData.id}
                        exercise={playerData}
                        onResult={(r) => void handleExerciseResult(r)}
                      />
                    </CardContent>
                  </Card>
                </div>
              ) : null}
            </>
          )}
        </div>
      </div>
    </div>
  );
}
