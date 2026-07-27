'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  PeHighlightEditor,
  type TextHighlight,
} from '@/components/dashboard/pe-highlight-editor';
import {
  CheckCheck,
  FileText,
  Mic,
  PenSquare,
  Trash2,
  Video,
  Award,
} from 'lucide-react';

const MEDIA_BUCKET = 'elearning-media';

interface PendingSubmission {
  id: string;
  kind: 'lesson' | 'exercise_audio';
  content: string;
  teacher_feedback: string | null;
  highlights: TextHighlight[];
  submitted_at: string;
  learner_id: string;
  learner_name: string;
  module_id: string;
  module_title: string;
  competency: 'PE' | 'PO' | 'AUDIO' | string;
  lesson_title: string;
  exercise_title?: string;
}

interface PendingCapsule {
  id: string;
  content: string;
  submitted_at: string;
  learner_id: string;
  learner_name: string;
  module_id: string;
  module_title: string;
}

function parseHighlights(raw: unknown): TextHighlight[] {
  if (!Array.isArray(raw)) return [];
  return raw
    .filter(
      (h): h is TextHighlight =>
        !!h &&
        typeof h === 'object' &&
        typeof (h as TextHighlight).start === 'number' &&
        typeof (h as TextHighlight).end === 'number'
    )
    .map((h) => ({ start: h.start, end: h.end }));
}

function nestedName(row: { learners?: unknown }): string {
  const learners = row.learners as
    | { profiles?: { full_name?: string } | { full_name?: string }[] }
    | { profiles?: { full_name?: string } | { full_name?: string }[] }[]
    | null
    | undefined;

  const learner = Array.isArray(learners) ? learners[0] : learners;
  const profiles = learner?.profiles;
  const profile = Array.isArray(profiles) ? profiles[0] : profiles;
  return profile?.full_name ?? 'Apprenant';
}

export default function TeacherCorrectionsClient() {
  const supabase = createClient();
  const searchParams = useSearchParams();

  const initialModule = searchParams.get('module') ?? 'all';
  const initialTab = searchParams.get('tab') === 'capsules' ? 'capsules' : 'copies';

  const [tab, setTab] = useState(initialTab);
  const [moduleFilter, setModuleFilter] = useState(initialModule);
  const [loading, setLoading] = useState(true);
  const [submissions, setSubmissions] = useState<PendingSubmission[]>([]);
  const [capsules, setCapsules] = useState<PendingCapsule[]>([]);
  const [modules, setModules] = useState<{ id: string; title: string }[]>([]);

  const [activeSubmission, setActiveSubmission] = useState<PendingSubmission | null>(null);
  const [feedback, setFeedback] = useState('');
  const [highlights, setHighlights] = useState<TextHighlight[]>([]);
  const [audioUrl, setAudioUrl] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  const [activeCapsule, setActiveCapsule] = useState<PendingCapsule | null>(null);
  const [videoUrl, setVideoUrl] = useState<string | null>(null);
  const [capsuleBusy, setCapsuleBusy] = useState(false);

  const loadData = useCallback(async () => {
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

      const { data: moduleRows } = await supabase
        .from('elearning_modules')
        .select('id, title')
        .eq('teacher_id', teacher.id)
        .order('title', { ascending: true });

      const moduleList = (moduleRows ?? []) as { id: string; title: string }[];
      setModules(moduleList);
      const moduleIds = moduleList.map((m) => m.id);

      if (moduleIds.length === 0) {
        setSubmissions([]);
        setCapsules([]);
        return;
      }

      const { data: sequences } = await supabase
        .from('elearning_sequences')
        .select('id, module_id')
        .in('module_id', moduleIds);

      const sequenceIds = (sequences ?? []).map((s) => s.id);
      const sequenceModuleMap = new Map(
        (sequences ?? []).map((s) => [s.id, s.module_id as string])
      );
      const moduleTitleMap = new Map(moduleList.map((m) => [m.id, m.title]));

      let pendingSubs: PendingSubmission[] = [];

      if (sequenceIds.length > 0) {
        const { data: lessons } = await supabase
          .from('elearning_lessons')
          .select('id, title, competency, sequence_id')
          .in('sequence_id', sequenceIds);

        const lessonIds = (lessons ?? []).map((l) => l.id);
        const lessonMap = new Map(
          (lessons ?? []).map((l) => [
            l.id,
            {
              title: l.title as string,
              competency: (l.competency as string) ?? '',
              module_id: sequenceModuleMap.get(l.sequence_id as string) ?? '',
            },
          ])
        );

        if (lessonIds.length > 0) {
          const { data: subs } = await supabase
            .from('elearning_submissions')
            .select(
              `
              id,
              content,
              teacher_feedback,
              highlights,
              submitted_at,
              learner_id,
              lesson_id,
              learners (
                profiles ( full_name )
              )
            `
            )
            .eq('validated', false)
            .in('lesson_id', lessonIds)
            .order('submitted_at', { ascending: true });

          pendingSubs = (subs ?? []).map((s: any) => {
            const lesson = lessonMap.get(s.lesson_id) ?? {
              title: '',
              competency: '',
              module_id: '',
            };
            return {
              id: s.id,
              kind: 'lesson' as const,
              content: s.content ?? '',
              teacher_feedback: s.teacher_feedback,
              highlights: parseHighlights(s.highlights),
              submitted_at: s.submitted_at,
              learner_id: s.learner_id,
              learner_name: nestedName(s),
              module_id: lesson.module_id,
              module_title: moduleTitleMap.get(lesson.module_id) ?? 'Module',
              competency: lesson.competency,
              lesson_title: lesson.title,
            };
          });

          const { data: audioExercises } = await supabase
            .from('elearning_exercises')
            .select('id, title, lesson_id')
            .eq('exercise_type', 'audio_record')
            .in('lesson_id', lessonIds);

          const audioExerciseList = audioExercises ?? [];
          const audioExerciseIds = audioExerciseList.map((e) => e.id);
          const audioExerciseMap = new Map(
            audioExerciseList.map((e) => [
              e.id,
              {
                title: e.title as string,
                lesson_id: e.lesson_id as string,
              },
            ])
          );

          if (audioExerciseIds.length > 0) {
            const { data: audioSubs } = await supabase
              .from('exercise_audio_submissions')
              .select(
                `
                id,
                audio_path,
                teacher_feedback,
                submitted_at,
                learner_id,
                exercise_id,
                learners (
                  profiles ( full_name )
                )
              `
              )
              .eq('validated', false)
              .in('exercise_id', audioExerciseIds)
              .order('submitted_at', { ascending: true });

            const audioPending: PendingSubmission[] = (audioSubs ?? []).map(
              (s: any) => {
                const ex = audioExerciseMap.get(s.exercise_id) ?? {
                  title: '',
                  lesson_id: '',
                };
                const lesson = lessonMap.get(ex.lesson_id) ?? {
                  title: '',
                  competency: '',
                  module_id: '',
                };
                return {
                  id: s.id,
                  kind: 'exercise_audio' as const,
                  content: s.audio_path ?? '',
                  teacher_feedback: s.teacher_feedback,
                  highlights: [],
                  submitted_at: s.submitted_at,
                  learner_id: s.learner_id,
                  learner_name: nestedName(s),
                  module_id: lesson.module_id,
                  module_title: moduleTitleMap.get(lesson.module_id) ?? 'Module',
                  competency: 'AUDIO',
                  lesson_title: lesson.title,
                  exercise_title: ex.title,
                };
              }
            );

            pendingSubs = [...pendingSubs, ...audioPending].sort(
              (a, b) =>
                new Date(a.submitted_at).getTime() -
                new Date(b.submitted_at).getTime()
            );
          }
        }
      }

      const { data: capsuleRows } = await supabase
        .from('elearning_capsules')
        .select(
          `
          id,
          content,
          submitted_at,
          learner_id,
          module_id,
          learners (
            profiles ( full_name )
          )
        `
        )
        .eq('validated', false)
        .in('module_id', moduleIds)
        .order('submitted_at', { ascending: true });

      const pendingCapsules: PendingCapsule[] = (capsuleRows ?? []).map((c: any) => ({
        id: c.id,
        content: c.content ?? '',
        submitted_at: c.submitted_at,
        learner_id: c.learner_id,
        learner_name: nestedName(c),
        module_id: c.module_id,
        module_title: moduleTitleMap.get(c.module_id) ?? 'Module',
      }));

      setSubmissions(pendingSubs);
      setCapsules(pendingCapsules);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  useEffect(() => {
    setTab(initialTab);
    setModuleFilter(initialModule);
  }, [initialTab, initialModule]);

  const filteredSubmissions = useMemo(
    () =>
      moduleFilter === 'all'
        ? submissions
        : submissions.filter((s) => s.module_id === moduleFilter),
    [submissions, moduleFilter]
  );

  const filteredCapsules = useMemo(
    () =>
      moduleFilter === 'all'
        ? capsules
        : capsules.filter((c) => c.module_id === moduleFilter),
    [capsules, moduleFilter]
  );

  async function openSubmission(sub: PendingSubmission) {
    setActiveSubmission(sub);
    setFeedback(sub.teacher_feedback ?? '');
    setHighlights(sub.highlights);
    setAudioUrl(null);

    if (
      (sub.competency === 'PO' || sub.kind === 'exercise_audio') &&
      sub.content
    ) {
      const { data } = await supabase.storage
        .from(MEDIA_BUCKET)
        .createSignedUrl(sub.content, 3600);
      setAudioUrl(data?.signedUrl ?? null);
    }
  }

  async function validateSubmission() {
    if (!activeSubmission) return;
    setSaving(true);
    try {
      if (activeSubmission.kind === 'exercise_audio') {
        const { error } = await supabase
          .from('exercise_audio_submissions')
          .update({
            teacher_feedback: feedback.trim() || null,
            validated: true,
            validated_at: new Date().toISOString(),
          })
          .eq('id', activeSubmission.id);
        if (error) throw error;
      } else {
        const payload: Record<string, unknown> = {
          teacher_feedback: feedback.trim() || null,
          validated: true,
          validated_at: new Date().toISOString(),
        };

        if (activeSubmission.competency === 'PE') {
          payload.highlights = highlights;
        }

        const { error } = await supabase
          .from('elearning_submissions')
          .update(payload)
          .eq('id', activeSubmission.id);

        if (error) throw error;
      }

      setActiveSubmission(null);
      setAudioUrl(null);
      await loadData();
    } catch (err) {
      console.error(err);
    } finally {
      setSaving(false);
    }
  }

  async function openCapsule(cap: PendingCapsule) {
    setActiveCapsule(cap);
    setVideoUrl(null);
    if (cap.content) {
      const { data } = await supabase.storage
        .from(MEDIA_BUCKET)
        .createSignedUrl(cap.content, 3600);
      setVideoUrl(data?.signedUrl ?? null);
    }
  }

  async function validateCapsule(cap: PendingCapsule) {
    setCapsuleBusy(true);
    try {
      const now = new Date().toISOString();
      const { error: updateErr } = await supabase
        .from('elearning_capsules')
        .update({ validated: true, validated_at: now })
        .eq('id', cap.id);

      if (updateErr) throw updateErr;

      const { error: badgeErr } = await supabase.from('elearning_badges').insert({
        capsule_id: cap.id,
        module_id: cap.module_id,
        learner_id: cap.learner_id,
        awarded_at: now,
      });

      if (badgeErr) throw badgeErr;

      setActiveCapsule(null);
      setVideoUrl(null);
      await loadData();
    } catch (err) {
      console.error(err);
    } finally {
      setCapsuleBusy(false);
    }
  }

  async function deleteCapsuleMedia(cap: PendingCapsule) {
    setCapsuleBusy(true);
    try {
      if (cap.content) {
        await supabase.storage.from(MEDIA_BUCKET).remove([cap.content]);
      }
      const { error } = await supabase.from('elearning_capsules').delete().eq('id', cap.id);
      if (error) throw error;
      setActiveCapsule(null);
      setVideoUrl(null);
      await loadData();
    } catch (err) {
      console.error(err);
    } finally {
      setCapsuleBusy(false);
    }
  }

  const formatDate = (iso: string) =>
    new Date(iso).toLocaleString('fr-FR', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Corrections</h1>
          <p className="text-gray-500 text-sm mt-1">
            Corrigez les copies PE/PO, les enregistrements audio et validez les
            capsules vidéo
          </p>
        </div>
        {!loading && (
          <div className="flex gap-2">
            <Badge variant="secondary" className="bg-flehub-green-light text-flehub-green">
              {filteredSubmissions.length} copie
              {filteredSubmissions.length !== 1 ? 's' : ''}
            </Badge>
            <Badge variant="secondary" className="bg-orange-50 text-orange-700">
              {filteredCapsules.length} capsule
              {filteredCapsules.length !== 1 ? 's' : ''}
            </Badge>
          </div>
        )}
      </div>

      {modules.length > 1 && (
        <div className="flex flex-wrap gap-2 items-center">
          <span className="text-sm text-gray-500 mr-1">Module :</span>
          <Button
            variant={moduleFilter === 'all' ? 'default' : 'outline'}
            size="sm"
            className={moduleFilter === 'all' ? 'bg-flehub-green text-white' : ''}
            onClick={() => setModuleFilter('all')}
          >
            Tous
          </Button>
          {modules.map((m) => (
            <Button
              key={m.id}
              variant={moduleFilter === m.id ? 'default' : 'outline'}
              size="sm"
              className={moduleFilter === m.id ? 'bg-flehub-green text-white' : ''}
              onClick={() => setModuleFilter(m.id)}
            >
              {m.title}
            </Button>
          ))}
        </div>
      )}

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="copies" className="gap-1.5">
            <PenSquare className="w-3.5 h-3.5" />
            Copies à corriger
          </TabsTrigger>
          <TabsTrigger value="capsules" className="gap-1.5">
            <Video className="w-3.5 h-3.5" />
            Capsules à valider
          </TabsTrigger>
        </TabsList>

        <TabsContent value="copies" className="mt-4 space-y-3">
          {loading ? (
            Array.from({ length: 5 }).map((_, i) => (
              <Skeleton key={i} className="h-20 w-full rounded-xl" />
            ))
          ) : filteredSubmissions.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-gray-400">
              <CheckCheck className="w-12 h-12 mb-3 opacity-40" />
              <p className="text-lg font-medium">Aucune copie en attente</p>
              <p className="text-sm">
                Les soumissions PE, PO et audio d&apos;exercice apparaîtront ici
              </p>
            </div>
          ) : (
            filteredSubmissions.map((sub) => (
              <Card key={sub.id} className="card-hover">
                <CardContent className="py-4 flex flex-col sm:flex-row sm:items-center gap-3 justify-between">
                  <div className="min-w-0 space-y-1">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="font-medium text-gray-900">{sub.learner_name}</span>
                      <Badge
                        variant="secondary"
                        className={
                          sub.competency === 'PE'
                            ? 'bg-orange-100 text-orange-700'
                            : sub.competency === 'AUDIO'
                              ? 'bg-violet-100 text-violet-700'
                              : 'bg-teal-100 text-teal-700'
                        }
                      >
                        {sub.competency === 'PE' ? (
                          <FileText className="w-3 h-3 mr-1 inline" />
                        ) : (
                          <Mic className="w-3 h-3 mr-1 inline" />
                        )}
                        {sub.competency === 'AUDIO'
                          ? 'Audio'
                          : sub.competency || '—'}
                      </Badge>
                    </div>
                    <p className="text-sm text-gray-600 truncate">
                      {sub.module_title}
                      {sub.lesson_title ? ` · ${sub.lesson_title}` : ''}
                      {sub.exercise_title ? ` · ${sub.exercise_title}` : ''}
                    </p>
                    <p className="text-xs text-gray-400">
                      Soumise le {formatDate(sub.submitted_at)}
                    </p>
                  </div>
                  <Button
                    className="bg-flehub-green hover:bg-flehub-green/90 text-white shrink-0"
                    onClick={() => openSubmission(sub)}
                  >
                    Corriger
                  </Button>
                </CardContent>
              </Card>
            ))
          )}
        </TabsContent>

        <TabsContent value="capsules" className="mt-4 space-y-3">
          {loading ? (
            Array.from({ length: 4 }).map((_, i) => (
              <Skeleton key={i} className="h-20 w-full rounded-xl" />
            ))
          ) : filteredCapsules.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-gray-400">
              <Video className="w-12 h-12 mb-3 opacity-40" />
              <p className="text-lg font-medium">Aucune capsule à valider</p>
              <p className="text-sm">Les vidéos finales des apprenants apparaîtront ici</p>
            </div>
          ) : (
            filteredCapsules.map((cap) => (
              <Card key={cap.id} className="card-hover">
                <CardContent className="py-4 flex flex-col sm:flex-row sm:items-center gap-3 justify-between">
                  <div className="min-w-0 space-y-1">
                    <span className="font-medium text-gray-900">{cap.learner_name}</span>
                    <p className="text-sm text-gray-600 truncate">{cap.module_title}</p>
                    <p className="text-xs text-gray-400">
                      Soumise le {formatDate(cap.submitted_at)}
                    </p>
                  </div>
                  <div className="flex flex-wrap gap-2 shrink-0">
                    <Button
                      variant="outline"
                      className="border-flehub-green text-flehub-green hover:bg-flehub-green-light"
                      onClick={() => openCapsule(cap)}
                    >
                      <Video className="w-4 h-4 mr-1" />
                      Voir la vidéo
                    </Button>
                    <Button
                      className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                      disabled={capsuleBusy}
                      onClick={() => validateCapsule(cap)}
                    >
                      <Award className="w-4 h-4 mr-1" />
                      Valider → Badge
                    </Button>
                    <Button
                      variant="ghost"
                      className="text-red-500 hover:bg-red-50"
                      disabled={capsuleBusy}
                      onClick={() => deleteCapsuleMedia(cap)}
                    >
                      <Trash2 className="w-4 h-4" />
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ))
          )}
        </TabsContent>
      </Tabs>

      <Dialog
        open={!!activeSubmission}
        onOpenChange={(open) => {
          if (!open) {
            setActiveSubmission(null);
            setAudioUrl(null);
          }
        }}
      >
        <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              Corriger — {activeSubmission?.learner_name}
              {activeSubmission?.competency === 'AUDIO'
                ? ' (Audio)'
                : activeSubmission?.competency
                  ? ` (${activeSubmission.competency})`
                  : ''}
            </DialogTitle>
          </DialogHeader>

          {activeSubmission && (
            <div className="space-y-4 py-2">
              <p className="text-sm text-gray-500">
                {activeSubmission.module_title}
                {activeSubmission.lesson_title
                  ? ` · ${activeSubmission.lesson_title}`
                  : ''}
                {activeSubmission.exercise_title
                  ? ` · ${activeSubmission.exercise_title}`
                  : ''}
              </p>

              {activeSubmission.competency === 'PE' ? (
                <div className="space-y-2">
                  <Label>Texte de l&apos;apprenant</Label>
                  <PeHighlightEditor
                    content={activeSubmission.content}
                    highlights={highlights}
                    onChange={setHighlights}
                  />
                </div>
              ) : (
                <div className="space-y-2">
                  <Label>
                    {activeSubmission.kind === 'exercise_audio'
                      ? 'Enregistrement audio'
                      : 'Enregistrement oral'}
                  </Label>
                  {audioUrl ? (
                    <audio controls className="w-full" src={audioUrl}>
                      Votre navigateur ne prend pas en charge l&apos;audio.
                    </audio>
                  ) : (
                    <p className="text-sm text-gray-400">
                      Impossible de charger l&apos;audio
                      {activeSubmission.content
                        ? ` (${activeSubmission.content})`
                        : ' — fichier manquant'}
                    </p>
                  )}
                </div>
              )}

              <div className="space-y-2">
                <Label htmlFor="feedback">
                  {activeSubmission.competency === 'PE'
                    ? 'Commentaire général'
                    : 'Commentaire'}
                </Label>
                <Textarea
                  id="feedback"
                  rows={4}
                  value={feedback}
                  onChange={(e) => setFeedback(e.target.value)}
                  placeholder="Votre correction et conseils pour l'apprenant…"
                />
              </div>
            </div>
          )}

          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setActiveSubmission(null);
                setAudioUrl(null);
              }}
            >
              Annuler
            </Button>
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              disabled={saving}
              onClick={validateSubmission}
            >
              {saving
                ? 'Validation…'
                : activeSubmission?.kind === 'exercise_audio'
                  ? 'Valider'
                  : 'Valider la correction'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog
        open={!!activeCapsule}
        onOpenChange={(open) => {
          if (!open) {
            setActiveCapsule(null);
            setVideoUrl(null);
          }
        }}
      >
        <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Capsule — {activeCapsule?.learner_name}</DialogTitle>
          </DialogHeader>
          {activeCapsule && (
            <div className="space-y-4 py-2">
              <p className="text-sm text-gray-500">{activeCapsule.module_title}</p>
              {videoUrl ? (
                <video
                  controls
                  className="w-full rounded-lg bg-black max-h-[50vh]"
                  src={videoUrl}
                >
                  Votre navigateur ne prend pas en charge la vidéo.
                </video>
              ) : (
                <p className="text-sm text-gray-400 py-8 text-center">
                  Impossible de charger la vidéo
                </p>
              )}
            </div>
          )}
          <DialogFooter className="flex-col sm:flex-row gap-2">
            <Button
              variant="ghost"
              className="text-red-500 hover:bg-red-50"
              disabled={capsuleBusy || !activeCapsule}
              onClick={() => activeCapsule && deleteCapsuleMedia(activeCapsule)}
            >
              <Trash2 className="w-4 h-4 mr-1" />
              Supprimer la vidéo du stockage
            </Button>
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              disabled={capsuleBusy || !activeCapsule}
              onClick={() => activeCapsule && validateCapsule(activeCapsule)}
            >
              <Award className="w-4 h-4 mr-1" />
              Valider → Badge
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
