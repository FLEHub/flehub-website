'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/client';
import { getCurrentLearnerId } from '@/lib/learner-session';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  BookOpen,
  GraduationCap,
  Layers,
  Play,
  UserPlus,
  Video,
} from 'lucide-react';

interface ModuleCard {
  id: string;
  title: string;
  description: string | null;
  cefr_level: string | null;
  teacher_name: string;
  enrolled: boolean;
  progress_percent: number;
}

const cefrColors: Record<string, string> = {
  A1: 'bg-green-100 text-green-700',
  A2: 'bg-lime-100 text-lime-700',
  B1: 'bg-yellow-100 text-yellow-700',
  B2: 'bg-orange-100 text-orange-700',
  C1: 'bg-red-100 text-red-700',
  C2: 'bg-rose-100 text-rose-700',
};

export default function LearnerElearningModulesPage() {
  const supabase = createClient();
  const [loading, setLoading] = useState(true);
  const [learnerId, setLearnerId] = useState<string | null>(null);
  const [hasTeachers, setHasTeachers] = useState(false);
  const [modules, setModules] = useState<ModuleCard[]>([]);
  const [busyId, setBusyId] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      const lid = await getCurrentLearnerId(supabase);
      if (!lid) return;
      setLearnerId(lid);

      const { data: links } = await supabase
        .from('learner_teacher_links')
        .select('teacher_id')
        .eq('learner_id', lid);

      const teacherIds = (links ?? []).map((l) => l.teacher_id as string);

      const { data: assignmentRows } = await supabase
        .from('elearning_module_assignments')
        .select('module_id')
        .eq('learner_id', lid);

      const assignedIds = [
        ...new Set((assignmentRows ?? []).map((a) => a.module_id as string)),
      ];

      setHasTeachers(teacherIds.length > 0 || assignedIds.length > 0);

      let moduleQuery = supabase
        .from('elearning_modules')
        .select(
          `
          id,
          title,
          description,
          cefr_level,
          teacher_id,
          teachers (
            profiles ( full_name )
          )
        `
        )
        .order('title', { ascending: true });

      if (teacherIds.length > 0 && assignedIds.length > 0) {
        moduleQuery = moduleQuery.or(
          `and(published.eq.true,teacher_id.in.(${teacherIds.join(',')})),id.in.(${assignedIds.join(',')})`
        );
      } else if (teacherIds.length > 0) {
        moduleQuery = moduleQuery.eq('published', true).in('teacher_id', teacherIds);
      } else if (assignedIds.length > 0) {
        moduleQuery = moduleQuery.in('id', assignedIds);
      } else {
        setModules([]);
        return;
      }

      const { data: moduleRows } = await moduleQuery;

      const moduleList = moduleRows ?? [];
      const moduleIds = moduleList.map((m: any) => m.id as string);

      const [{ data: enrollments }, { data: sequences }] = await Promise.all([
        moduleIds.length
          ? supabase
              .from('elearning_enrollments')
              .select('module_id')
              .eq('learner_id', lid)
              .in('module_id', moduleIds)
          : Promise.resolve({ data: [] as { module_id: string }[] }),
        moduleIds.length
          ? supabase
              .from('elearning_sequences')
              .select('id, module_id')
              .in('module_id', moduleIds)
          : Promise.resolve({ data: [] as { id: string; module_id: string }[] }),
      ]);

      const enrolledSet = new Set((enrollments ?? []).map((e) => e.module_id));
      assignedIds.forEach((id) => enrolledSet.add(id));
      const sequenceIds = (sequences ?? []).map((s) => s.id);
      const seqByModule = new Map<string, string[]>();
      (sequences ?? []).forEach((s) => {
        const list = seqByModule.get(s.module_id) ?? [];
        list.push(s.id);
        seqByModule.set(s.module_id, list);
      });

      let lessons: { id: string; sequence_id: string }[] = [];
      if (sequenceIds.length > 0) {
        const { data: lessonRows } = await supabase
          .from('elearning_lessons')
          .select('id, sequence_id')
          .in('sequence_id', sequenceIds);
        lessons = (lessonRows as { id: string; sequence_id: string }[]) ?? [];
      }

      const lessonIds = lessons.map((l) => l.id);
      let completedLessonIds = new Set<string>();
      if (lessonIds.length > 0) {
        const { data: progress } = await supabase
          .from('elearning_progress')
          .select('lesson_id')
          .eq('learner_id', lid)
          .in('lesson_id', lessonIds)
          .not('completed_at', 'is', null);
        completedLessonIds = new Set((progress ?? []).map((p) => p.lesson_id as string));
      }

      const seqToModule = new Map<string, string>();
      (sequences ?? []).forEach((s) => {
        seqToModule.set(s.id, s.module_id);
      });

      const lessonsByModule = new Map<string, string[]>();
      lessons.forEach((l) => {
        const moduleId = seqToModule.get(l.sequence_id);
        if (!moduleId) return;
        const list = lessonsByModule.get(moduleId) ?? [];
        list.push(l.id);
        lessonsByModule.set(moduleId, list);
      });

      setModules(
        moduleList.map((m: any) => {
          const teachers = Array.isArray(m.teachers) ? m.teachers[0] : m.teachers;
          const profiles = Array.isArray(teachers?.profiles)
            ? teachers.profiles[0]
            : teachers?.profiles;
          const lessonList = lessonsByModule.get(m.id) ?? [];
          const completed = lessonList.filter((id) => completedLessonIds.has(id)).length;
          const progress_percent =
            lessonList.length === 0
              ? 0
              : Math.round((completed / lessonList.length) * 100);

          return {
            id: m.id,
            title: m.title,
            description: m.description,
            cefr_level: m.cefr_level,
            teacher_name: profiles?.full_name ?? 'Enseignant',
            enrolled: enrolledSet.has(m.id),
            progress_percent,
          };
        })
      );
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  async function enroll(moduleId: string) {
    if (!learnerId) return;
    setBusyId(moduleId);
    try {
      const { error } = await supabase.from('elearning_enrollments').insert({
        module_id: moduleId,
        learner_id: learnerId,
      });
      if (error) throw error;
      setModules((prev) =>
        prev.map((m) => (m.id === moduleId ? { ...m, enrolled: true } : m))
      );
    } catch (err) {
      console.error(err);
    } finally {
      setBusyId(null);
    }
  }

  return (
    <div className="p-6 space-y-6 max-w-6xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Modules eLearning</h1>
          <p className="text-sm text-gray-500 mt-1">
            Modules publiés par vos enseignants et modules qui vous sont assignés
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button asChild variant="outline" size="sm">
            <Link href="/dashboard/learner/elearning/teachers">
              <GraduationCap className="w-4 h-4 mr-1" />
              Mes enseignants
            </Link>
          </Button>
          <Button asChild variant="outline" size="sm">
            <Link href="/dashboard/learner/elearning/sessions">
              <Video className="w-4 h-4 mr-1" />
              Sessions
            </Link>
          </Button>
        </div>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 6 }).map((_, i) => (
            <Skeleton key={i} className="h-52 rounded-xl" />
          ))}
        </div>
      ) : !hasTeachers ? (
        <div className="flex flex-col items-center justify-center py-16 text-gray-400 border border-dashed border-gray-200 rounded-xl">
          <UserPlus className="w-12 h-12 mb-3 opacity-40" />
          <p className="text-lg font-medium text-gray-700">Choisissez d&apos;abord un enseignant</p>
          <p className="text-sm mb-4 text-center px-4">
            Les modules apparaissent après avoir sélectionné un ou plusieurs enseignants.
          </p>
          <Button
            asChild
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
          >
            <Link href="/dashboard/learner/elearning/teachers">Choisir un enseignant</Link>
          </Button>
        </div>
      ) : modules.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-gray-400 border border-dashed border-gray-200 rounded-xl">
          <BookOpen className="w-12 h-12 mb-3 opacity-40" />
          <p className="text-lg font-medium">Aucun module eLearning pour l&apos;instant</p>
          <p className="text-sm text-center px-4">
            Les modules publiés par vos enseignants et ceux qui vous sont assignés
            apparaîtront ici.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {modules.map((mod) => (
            <Card key={mod.id} className="card-hover flex flex-col">
              <CardHeader className="pb-2">
                <div className="flex items-start justify-between gap-2">
                  <div className="p-2 rounded-lg bg-flehub-green-light">
                    <Layers className="w-5 h-5 text-flehub-green" />
                  </div>
                  {mod.cefr_level && (
                    <Badge
                      variant="secondary"
                      className={`text-xs ${cefrColors[mod.cefr_level] ?? ''}`}
                    >
                      {mod.cefr_level}
                    </Badge>
                  )}
                </div>
                <h3 className="font-semibold text-gray-900 text-sm mt-2 leading-snug line-clamp-2">
                  {mod.title}
                </h3>
                <p className="text-xs text-gray-400">{mod.teacher_name}</p>
              </CardHeader>
              <CardContent className="flex flex-col flex-1 justify-between gap-3">
                <div>
                  <p className="text-[11px] uppercase tracking-wide text-gray-400 mb-0.5">
                    Thème
                  </p>
                  <p className="text-xs text-gray-600 line-clamp-2">
                    {mod.description || 'Aucun thème renseigné'}
                  </p>
                </div>

                {mod.enrolled && (
                  <div>
                    <div className="flex items-center justify-between text-xs text-gray-500 mb-1">
                      <span>Progression</span>
                      <span>{mod.progress_percent}%</span>
                    </div>
                    <div className="h-1.5 rounded-full bg-gray-200 overflow-hidden">
                      <div
                        className="h-full bg-flehub-green rounded-full"
                        style={{ width: `${mod.progress_percent}%` }}
                      />
                    </div>
                  </div>
                )}

                {mod.enrolled ? (
                  <Button
                    asChild
                    size="sm"
                    className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                  >
                    <Link href={`/dashboard/learner/elearning/${mod.id}`}>
                      <Play className="w-3.5 h-3.5 mr-1" />
                      Continuer
                    </Link>
                  </Button>
                ) : (
                  <Button
                    size="sm"
                    className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                    disabled={busyId === mod.id}
                    onClick={() => enroll(mod.id)}
                  >
                    S&apos;inscrire
                  </Button>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
