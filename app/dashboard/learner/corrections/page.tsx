'use client';

import { useCallback, useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { resolveElearningMediaUrl } from '@/lib/elearning-content';
import {
  PeHighlightViewer,
  type TextHighlight,
} from '@/components/dashboard/pe-highlight-editor';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Calendar,
  CheckCheck,
  FileText,
  Mic,
  MessageSquareText,
} from 'lucide-react';

type CorrectionType = 'PE' | 'PO' | 'Audio';

interface CorrectionItem {
  id: string;
  source: 'lesson' | 'exercise_audio';
  type: CorrectionType;
  title: string;
  moduleTitle: string;
  lessonTitle: string;
  exerciseTitle?: string;
  teacherFeedback: string | null;
  validatedAt: string;
  content: string;
  highlights: TextHighlight[];
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

function formatDate(iso: string) {
  if (!iso) return '—';
  return new Date(iso).toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });
}

function typeBadgeClass(type: CorrectionType) {
  if (type === 'PE') return 'bg-blue-50 text-blue-700 border-blue-200';
  if (type === 'PO') return 'bg-violet-50 text-violet-700 border-violet-200';
  return 'bg-amber-50 text-amber-700 border-amber-200';
}

function CorrectionCard({ item }: { item: CorrectionItem }) {
  const [audioUrl, setAudioUrl] = useState<string | null>(null);
  const [audioLoading, setAudioLoading] = useState(false);

  const needsAudio = item.type === 'PO' || item.type === 'Audio';

  useEffect(() => {
    if (!needsAudio || !item.content) {
      setAudioUrl(null);
      setAudioLoading(false);
      return;
    }
    let cancelled = false;
    setAudioLoading(true);
    const supabase = createClient();
    void (async () => {
      const url = await resolveElearningMediaUrl(supabase, item.content);
      if (!cancelled) {
        setAudioUrl(url);
        setAudioLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [needsAudio, item.content]);

  const subtitleParts = [item.moduleTitle, item.lessonTitle];
  if (item.exerciseTitle) subtitleParts.push(item.exerciseTitle);

  return (
    <Card className="border-0 shadow-sm overflow-hidden">
      <CardContent className="p-5 space-y-4">
        <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-3">
          <div className="min-w-0 space-y-1">
            <div className="flex flex-wrap items-center gap-2">
              <Badge
                variant="outline"
                className={`text-xs font-bold ${typeBadgeClass(item.type)}`}
              >
                {item.type === 'Audio' ? (
                  <Mic className="w-3 h-3 mr-1" />
                ) : (
                  <FileText className="w-3 h-3 mr-1" />
                )}
                {item.type}
              </Badge>
              <h2 className="text-base font-semibold text-gray-900 truncate">
                {item.title}
              </h2>
            </div>
            <p className="text-xs text-gray-500 truncate">
              {subtitleParts.filter(Boolean).join(' · ')}
            </p>
          </div>
          <div className="flex items-center gap-1.5 text-xs text-gray-500 shrink-0">
            <Calendar className="w-3.5 h-3.5" />
            <span>Validée le {formatDate(item.validatedAt)}</span>
          </div>
        </div>

        {item.type === 'PE' && (
          <div className="space-y-2">
            <p className="text-xs font-medium uppercase tracking-wide text-gray-400">
              Votre texte
            </p>
            <PeHighlightViewer
              content={item.content || ''}
              highlights={item.highlights}
            />
          </div>
        )}

        {needsAudio && (
          <div className="space-y-2">
            <p className="text-xs font-medium uppercase tracking-wide text-gray-400">
              Votre enregistrement
            </p>
            {audioLoading ? (
              <Skeleton className="h-10 w-full rounded-md" />
            ) : audioUrl ? (
              <audio controls className="w-full" src={audioUrl}>
                Votre navigateur ne prend pas en charge l&apos;audio.
              </audio>
            ) : (
              <p className="text-sm text-gray-400">
                Impossible de charger l&apos;audio.
              </p>
            )}
          </div>
        )}

        <div className="rounded-lg border border-gray-100 bg-gray-50 px-3 py-3 space-y-1">
          <p className="text-xs font-medium uppercase tracking-wide text-gray-400 flex items-center gap-1.5">
            <MessageSquareText className="w-3.5 h-3.5" />
            Commentaire de l&apos;enseignant
          </p>
          <p className="text-sm text-gray-800 whitespace-pre-wrap">
            {item.teacherFeedback?.trim()
              ? item.teacherFeedback
              : 'Aucun commentaire.'}
          </p>
        </div>
      </CardContent>
    </Card>
  );
}

export default function LearnerCorrectionsPage() {
  const supabase = createClient();
  const [loading, setLoading] = useState(true);
  const [corrections, setCorrections] = useState<CorrectionItem[]>([]);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return;

      const { data: learner } = await supabase
        .from('learners')
        .select('id')
        .eq('profile_id', user.id)
        .maybeSingle();

      if (!learner) {
        setCorrections([]);
        return;
      }

      const [{ data: lessonSubs, error: lessonErr }, { data: audioSubs, error: audioErr }] =
        await Promise.all([
          supabase
            .from('elearning_submissions')
            .select(
              'id, content, teacher_feedback, highlights, validated_at, submitted_at, lesson_id'
            )
            .eq('learner_id', learner.id)
            .eq('validated', true)
            .order('validated_at', { ascending: false }),
          supabase
            .from('exercise_audio_submissions')
            .select(
              'id, audio_path, teacher_feedback, validated_at, submitted_at, exercise_id'
            )
            .eq('learner_id', learner.id)
            .eq('validated', true)
            .order('validated_at', { ascending: false }),
        ]);

      if (lessonErr) throw lessonErr;
      if (audioErr) throw audioErr;

      const lessonIds = Array.from(
        new Set(
          (lessonSubs ?? [])
            .map((s) => s.lesson_id as string)
            .filter(Boolean)
        )
      );
      const exerciseIds = Array.from(
        new Set(
          (audioSubs ?? [])
            .map((s) => s.exercise_id as string)
            .filter(Boolean)
        )
      );

      const lessonMeta = new Map<
        string,
        { title: string; competency: string; moduleTitle: string }
      >();
      const exerciseMeta = new Map<
        string,
        {
          title: string;
          lessonTitle: string;
          moduleTitle: string;
        }
      >();

      if (lessonIds.length > 0) {
        const { data: lessons } = await supabase
          .from('elearning_lessons')
          .select(
            `
            id,
            title,
            competency,
            sequence_id,
            elearning_sequences (
              module_id,
              elearning_modules ( title )
            )
          `
          )
          .in('id', lessonIds);

        (lessons ?? []).forEach((l: any) => {
          const seq = Array.isArray(l.elearning_sequences)
            ? l.elearning_sequences[0]
            : l.elearning_sequences;
          const mod = Array.isArray(seq?.elearning_modules)
            ? seq?.elearning_modules[0]
            : seq?.elearning_modules;
          lessonMeta.set(l.id, {
            title: (l.title as string) || 'Leçon',
            competency: (l.competency as string) || '',
            moduleTitle:
              typeof mod?.title === 'string' && mod.title.trim()
                ? mod.title.trim()
                : 'Module',
          });
        });
      }

      if (exerciseIds.length > 0) {
        const { data: exercises } = await supabase
          .from('elearning_exercises')
          .select(
            `
            id,
            title,
            lesson_id,
            elearning_lessons (
              title,
              elearning_sequences (
                elearning_modules ( title )
              )
            )
          `
          )
          .in('id', exerciseIds);

        (exercises ?? []).forEach((ex: any) => {
          const lesson = Array.isArray(ex.elearning_lessons)
            ? ex.elearning_lessons[0]
            : ex.elearning_lessons;
          const seq = Array.isArray(lesson?.elearning_sequences)
            ? lesson?.elearning_sequences[0]
            : lesson?.elearning_sequences;
          const mod = Array.isArray(seq?.elearning_modules)
            ? seq?.elearning_modules[0]
            : seq?.elearning_modules;
          exerciseMeta.set(ex.id, {
            title: (ex.title as string) || 'Exercice audio',
            lessonTitle:
              typeof lesson?.title === 'string' && lesson.title.trim()
                ? lesson.title.trim()
                : 'Leçon',
            moduleTitle:
              typeof mod?.title === 'string' && mod.title.trim()
                ? mod.title.trim()
                : 'Module',
          });
        });
      }

      const fromLessons: CorrectionItem[] = (lessonSubs ?? []).map((s: any) => {
        const meta = lessonMeta.get(s.lesson_id) ?? {
          title: 'Leçon',
          competency: '',
          moduleTitle: 'Module',
        };
        const competency = meta.competency.toUpperCase();
        const type: CorrectionType =
          competency === 'PO' ? 'PO' : competency === 'PE' ? 'PE' : 'PE';
        return {
          id: `lesson-${s.id}`,
          source: 'lesson' as const,
          type,
          title: meta.title,
          moduleTitle: meta.moduleTitle,
          lessonTitle: meta.title,
          teacherFeedback: s.teacher_feedback,
          validatedAt: s.validated_at || s.submitted_at,
          content: s.content ?? '',
          highlights: parseHighlights(s.highlights),
        };
      });

      const fromAudio: CorrectionItem[] = (audioSubs ?? []).map((s: any) => {
        const meta = exerciseMeta.get(s.exercise_id) ?? {
          title: 'Exercice audio',
          lessonTitle: 'Leçon',
          moduleTitle: 'Module',
        };
        return {
          id: `audio-${s.id}`,
          source: 'exercise_audio' as const,
          type: 'Audio' as const,
          title: meta.title,
          moduleTitle: meta.moduleTitle,
          lessonTitle: meta.lessonTitle,
          exerciseTitle: meta.title,
          teacherFeedback: s.teacher_feedback,
          validatedAt: s.validated_at || s.submitted_at,
          content: s.audio_path ?? '',
          highlights: [],
        };
      });

      const merged = [...fromLessons, ...fromAudio].sort(
        (a, b) =>
          new Date(b.validatedAt).getTime() - new Date(a.validatedAt).getTime()
      );

      setCorrections(merged);
    } catch (err) {
      console.error(err);
      setError('Impossible de charger vos corrections.');
    } finally {
      setLoading(false);
    }
  }, [supabase]);

  useEffect(() => {
    void load();
  }, [load]);

  return (
    <div className="p-6 space-y-6 max-w-3xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Corrections</h1>
        <p className="text-sm text-gray-500 mt-1">
          Retrouvez les retours de votre enseignant sur vos productions PE, PO et
          exercices audio
        </p>
      </div>

      {error && (
        <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {error}
        </div>
      )}

      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Skeleton key={i} className="h-48 w-full rounded-xl" />
          ))}
        </div>
      ) : corrections.length === 0 ? (
        <Card className="border-0 shadow-sm">
          <CardContent className="py-16 flex flex-col items-center text-gray-400">
            <div className="w-14 h-14 rounded-full bg-gray-100 flex items-center justify-center mb-4">
              <CheckCheck className="w-7 h-7 opacity-40" />
            </div>
            <p className="text-base font-medium text-gray-600">
              Aucune correction disponible pour le moment
            </p>
            <p className="text-sm text-center max-w-sm mt-1">
              Lorsque votre enseignant validera une production écrite, orale ou un
              exercice audio, elle apparaîtra ici.
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          <p className="text-xs text-gray-400">
            {corrections.length} correction
            {corrections.length !== 1 ? 's' : ''}
          </p>
          {corrections.map((item) => (
            <CorrectionCard key={item.id} item={item} />
          ))}
        </div>
      )}
    </div>
  );
}
