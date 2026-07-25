'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  BookOpen,
  Users,
  Video,
  PenSquare,
  Plus,
  Calendar,
  ArrowRight,
  Clock,
} from 'lucide-react';

interface TeacherStats {
  publishedModules: number;
  totalLearners: number;
  upcomingSessions: number;
  pendingCorrections: number;
}

interface LiveSession {
  id: string;
  title: string;
  scheduled_at: string;
  duration_minutes: number;
  cefr_level: string;
  max_participants: number;
}

interface LearnerActivity {
  id: string;
  learner_name: string;
  module_title: string;
  lesson_title: string;
  completed_at: string;
}

export default function TeacherDashboard() {
  const supabase = createClient();

  const [stats, setStats] = useState<TeacherStats | null>(null);
  const [sessions, setSessions] = useState<LiveSession[]>([]);
  const [activity, setActivity] = useState<LearnerActivity[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchDashboard() {
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

        const { data: modules } = await supabase
          .from('elearning_modules')
          .select('id, published')
          .eq('teacher_id', teacher.id);

        const moduleIds = (modules ?? []).map((m) => m.id);
        const publishedModules = (modules ?? []).filter((m) => m.published).length;

        let totalLearners = 0;
        let pendingSubmissions = 0;
        let pendingCapsules = 0;

        if (moduleIds.length > 0) {
          const { data: enrollments } = await supabase
            .from('elearning_enrollments')
            .select('learner_id')
            .in('module_id', moduleIds);

          totalLearners = new Set((enrollments ?? []).map((e) => e.learner_id)).size;

          const { data: sequences } = await supabase
            .from('elearning_sequences')
            .select('id')
            .in('module_id', moduleIds);

          const sequenceIds = (sequences ?? []).map((s) => s.id);

          if (sequenceIds.length > 0) {
            const { data: lessons } = await supabase
              .from('elearning_lessons')
              .select('id')
              .in('sequence_id', sequenceIds);

            const lessonIds = (lessons ?? []).map((l) => l.id);

            if (lessonIds.length > 0) {
              const { count } = await supabase
                .from('elearning_submissions')
                .select('*', { count: 'exact', head: true })
                .eq('validated', false)
                .in('lesson_id', lessonIds);

              pendingSubmissions = count ?? 0;
            }
          }

          const { count: capsulesCount } = await supabase
            .from('elearning_capsules')
            .select('*', { count: 'exact', head: true })
            .eq('validated', false)
            .in('module_id', moduleIds);

          pendingCapsules = capsulesCount ?? 0;
        }

        const now = new Date().toISOString();
        const { count: sessionsCount } = await supabase
          .from('live_sessions')
          .select('*', { count: 'exact', head: true })
          .eq('teacher_id', teacher.id)
          .gte('scheduled_at', now)
          .eq('status', 'scheduled');

        setStats({
          publishedModules,
          totalLearners,
          upcomingSessions: sessionsCount ?? 0,
          pendingCorrections: pendingSubmissions + pendingCapsules,
        });

        const { data: upcomingSessions } = await supabase
          .from('live_sessions')
          .select('id, title, scheduled_at, duration_minutes, cefr_level, max_participants')
          .eq('teacher_id', teacher.id)
          .gte('scheduled_at', now)
          .order('scheduled_at', { ascending: true })
          .limit(3);

        setSessions(upcomingSessions ?? []);

        if (moduleIds.length > 0) {
          const { data: progressData } = await supabase
            .from('elearning_progress')
            .select(
              `
              id,
              completed_at,
              learners (
                profiles ( full_name )
              ),
              elearning_lessons (
                title,
                elearning_sequences (
                  module_id,
                  elearning_modules (
                    id,
                    title,
                    teacher_id
                  )
                )
              )
            `
            )
            .not('completed_at', 'is', null)
            .order('completed_at', { ascending: false })
            .limit(30);

          const activityMapped: LearnerActivity[] = (progressData ?? [])
            .filter((p: any) => {
              const modules =
                p.elearning_lessons?.elearning_sequences?.elearning_modules;
              const mod = Array.isArray(modules) ? modules[0] : modules;
              return mod?.teacher_id === teacher.id;
            })
            .slice(0, 8)
            .map((p: any) => {
              const learners = Array.isArray(p.learners) ? p.learners[0] : p.learners;
              const profiles = Array.isArray(learners?.profiles)
                ? learners.profiles[0]
                : learners?.profiles;
              const lessons = Array.isArray(p.elearning_lessons)
                ? p.elearning_lessons[0]
                : p.elearning_lessons;
              const sequences = Array.isArray(lessons?.elearning_sequences)
                ? lessons.elearning_sequences[0]
                : lessons?.elearning_sequences;
              const modules = Array.isArray(sequences?.elearning_modules)
                ? sequences.elearning_modules[0]
                : sequences?.elearning_modules;

              return {
                id: p.id,
                learner_name: profiles?.full_name ?? 'Apprenant',
                module_title: modules?.title ?? 'Module',
                lesson_title: lessons?.title ?? 'Leçon',
                completed_at: p.completed_at,
              };
            });

          setActivity(activityMapped);
        } else {
          setActivity([]);
        }
      } catch (err) {
        console.error('Dashboard fetch error:', err);
      } finally {
        setLoading(false);
      }
    }

    fetchDashboard();
  }, []);

  const formatDateTime = (iso: string) => {
    const d = new Date(iso);
    return d.toLocaleString('fr-FR', {
      weekday: 'short',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const statCards = [
    {
      title: 'Mes modules',
      value: stats?.publishedModules ?? 0,
      icon: BookOpen,
      color: 'text-flehub-green',
      bg: 'bg-flehub-green-light',
      href: '/dashboard/teacher/elearning',
    },
    {
      title: 'Mes apprenants',
      value: stats?.totalLearners ?? 0,
      icon: Users,
      color: 'text-blue-600',
      bg: 'bg-blue-50',
      href: null,
    },
    {
      title: 'Sessions à venir',
      value: stats?.upcomingSessions ?? 0,
      icon: Video,
      color: 'text-orange-600',
      bg: 'bg-orange-50',
      href: '/dashboard/teacher/sessions',
    },
    {
      title: 'Corrections en attente',
      value: stats?.pendingCorrections ?? 0,
      icon: PenSquare,
      color: 'text-purple-600',
      bg: 'bg-purple-50',
      href: '/dashboard/teacher/corrections',
    },
  ];

  return (
    <div className="p-6 space-y-8 max-w-7xl mx-auto">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Espace enseignant</h1>
          <p className="text-gray-500 text-sm mt-1">
            Gérez vos modules eLearning, sessions et corrections
          </p>
        </div>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => (window.location.href = '/dashboard/teacher/sessions')}
          >
            <Calendar className="w-4 h-4 mr-1" />
            Planifier une session
          </Button>
          <Button
            size="sm"
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
            onClick={() => (window.location.href = '/dashboard/teacher/elearning')}
          >
            <Plus className="w-4 h-4 mr-1" />
            Créer un module
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {statCards.map((card) => (
          <Card
            key={card.title}
            className="card-hover cursor-pointer"
            onClick={() => card.href && (window.location.href = card.href)}
          >
            <CardContent className="pt-6">
              {loading ? (
                <div className="space-y-2">
                  <Skeleton className="h-8 w-16" />
                  <Skeleton className="h-4 w-24" />
                </div>
              ) : (
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-3xl font-bold text-gray-900">{card.value}</p>
                    <p className="text-sm text-gray-500 mt-1">{card.title}</p>
                  </div>
                  <div className={`p-3 rounded-full ${card.bg}`}>
                    <card.icon className={`w-6 h-6 ${card.color}`} />
                  </div>
                </div>
              )}
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-1">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-base font-semibold">Sessions à venir</CardTitle>
            <Button
              variant="ghost"
              size="sm"
              className="text-flehub-green text-xs"
              onClick={() => (window.location.href = '/dashboard/teacher/sessions')}
            >
              Voir tout <ArrowRight className="w-3 h-3 ml-1" />
            </Button>
          </CardHeader>
          <CardContent className="space-y-3">
            {loading ? (
              Array.from({ length: 3 }).map((_, i) => (
                <div key={i} className="space-y-1">
                  <Skeleton className="h-4 w-full" />
                  <Skeleton className="h-3 w-2/3" />
                </div>
              ))
            ) : sessions.length === 0 ? (
              <p className="text-sm text-gray-400 py-4 text-center">Aucune session à venir</p>
            ) : (
              sessions.map((session) => (
                <div
                  key={session.id}
                  className="flex flex-col gap-1 p-3 rounded-lg border border-gray-100 bg-gray-50"
                >
                  <div className="flex items-center justify-between">
                    <span className="font-medium text-sm text-gray-800 truncate max-w-[60%]">
                      {session.title}
                    </span>
                    <Badge variant="secondary" className="text-xs">
                      {session.cefr_level}
                    </Badge>
                  </div>
                  <div className="flex items-center gap-1 text-xs text-gray-500">
                    <Clock className="w-3 h-3" />
                    {formatDateTime(session.scheduled_at)}
                  </div>
                  <div className="flex items-center justify-between mt-1">
                    <span className="text-xs text-gray-400">
                      {session.duration_minutes} min · max {session.max_participants}
                    </span>
                    <Button
                      size="sm"
                      variant="outline"
                      className="h-6 text-xs text-flehub-green border-flehub-green hover:bg-flehub-green-light"
                    >
                      Rejoindre
                    </Button>
                  </div>
                </div>
              ))
            )}
          </CardContent>
        </Card>

        <Card className="lg:col-span-2">
          <CardHeader className="pb-2">
            <CardTitle className="text-base font-semibold">Activité récente</CardTitle>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="space-y-3">
                {Array.from({ length: 5 }).map((_, i) => (
                  <Skeleton key={i} className="h-8 w-full" />
                ))}
              </div>
            ) : activity.length === 0 ? (
              <p className="text-sm text-gray-400 py-4 text-center">
                Aucune activité récente
              </p>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-gray-100">
                      <th className="text-left pb-2 text-gray-500 font-medium">Apprenant</th>
                      <th className="text-left pb-2 text-gray-500 font-medium">Module</th>
                      <th className="text-left pb-2 text-gray-500 font-medium">Leçon</th>
                      <th className="text-left pb-2 text-gray-500 font-medium">Complétée</th>
                    </tr>
                  </thead>
                  <tbody>
                    {activity.map((a) => (
                      <tr key={a.id} className="border-b border-gray-50 hover:bg-gray-50">
                        <td className="py-2 font-medium text-gray-800">{a.learner_name}</td>
                        <td className="py-2 text-gray-600 max-w-[140px] truncate">
                          {a.module_title}
                        </td>
                        <td className="py-2 text-gray-600 max-w-[140px] truncate">
                          {a.lesson_title}
                        </td>
                        <td className="py-2 text-xs text-gray-400">
                          {new Date(a.completed_at).toLocaleDateString('fr-FR')}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base font-semibold">Actions rapides</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <Button
              variant="outline"
              className="h-16 flex flex-col gap-1 text-flehub-green border-flehub-green hover:bg-flehub-green-light"
              onClick={() => (window.location.href = '/dashboard/teacher/elearning')}
            >
              <BookOpen className="w-5 h-5" />
              <span className="text-sm font-medium">Créer un module</span>
            </Button>
            <Button
              variant="outline"
              className="h-16 flex flex-col gap-1 text-orange-600 border-orange-200 hover:bg-orange-50"
              onClick={() => (window.location.href = '/dashboard/teacher/sessions')}
            >
              <Calendar className="w-5 h-5" />
              <span className="text-sm font-medium">Planifier une session</span>
            </Button>
            <Button
              variant="outline"
              className="h-16 flex flex-col gap-1 text-purple-600 border-purple-200 hover:bg-purple-50"
              onClick={() => (window.location.href = '/dashboard/teacher/corrections')}
            >
              <PenSquare className="w-5 h-5" />
              <span className="text-sm font-medium">Voir les corrections</span>
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
