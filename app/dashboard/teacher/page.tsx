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
  publishedCourses: number;
  totalLearners: number;
  upcomingSessions: number;
  exercisesCreated: number;
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
  course_title: string;
  progress_percent: number;
  last_activity: string;
}

export default function TeacherDashboard() {
  const supabase = createClient();

  const [teacherId, setTeacherId] = useState<string | null>(null);
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

        // Get teacher record
        const { data: teacher } = await supabase
          .from('teachers')
          .select('*')
          .eq('profile_id', user.id)
          .maybeSingle();

        if (!teacher) return;
        setTeacherId(teacher.id);

        // Published courses count
        const { count: coursesCount } = await supabase
          .from('courses')
          .select('*', { count: 'exact', head: true })
          .eq('teacher_id', teacher.id)
          .eq('is_published', true);

        // Exercises count
        const { count: exercisesCount } = await supabase
          .from('exercises')
          .select('*', { count: 'exact', head: true })
          .eq('teacher_id', teacher.id);

        // Upcoming sessions count
        const now = new Date().toISOString();
        const { count: sessionsCount } = await supabase
          .from('live_sessions')
          .select('*', { count: 'exact', head: true })
          .eq('teacher_id', teacher.id)
          .gte('scheduled_at', now)
          .eq('status', 'scheduled');

        // Learners assigned (via enrollments linked to teacher's courses)
        const { count: learnersCount } = await supabase
          .from('course_enrollments')
          .select('learner_id', { count: 'exact', head: true })
          .in(
            'course_id',
            (
              await supabase
                .from('courses')
                .select('id')
                .eq('teacher_id', teacher.id)
            ).data?.map((c) => c.id) ?? []
          );

        setStats({
          publishedCourses: coursesCount ?? 0,
          totalLearners: learnersCount ?? 0,
          upcomingSessions: sessionsCount ?? 0,
          exercisesCreated: exercisesCount ?? 0,
        });

        // Upcoming live sessions (next 3)
        const { data: upcomingSessions } = await supabase
          .from('live_sessions')
          .select('id, title, scheduled_at, duration_minutes, cefr_level, max_participants')
          .eq('teacher_id', teacher.id)
          .gte('scheduled_at', now)
          .order('scheduled_at', { ascending: true })
          .limit(3);

        setSessions(upcomingSessions ?? []);

        // Recent learner activity
        const { data: progressData } = await supabase
          .from('learner_progress')
          .select(
            `
            id,
            progress_percent,
            updated_at,
            courses (title),
            profiles (full_name)
          `
          )
          .order('updated_at', { ascending: false })
          .limit(8);

        const activityMapped: LearnerActivity[] = (progressData ?? []).map((p: any) => ({
          id: p.id,
          learner_name: p.profiles?.full_name ?? 'Unknown',
          course_title: p.courses?.title ?? 'Unknown Course',
          progress_percent: p.progress_percent ?? 0,
          last_activity: p.updated_at,
        }));

        setActivity(activityMapped);
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
    return d.toLocaleString('en-RW', {
      weekday: 'short',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const statCards = [
    {
      title: 'My Courses',
      value: stats?.publishedCourses ?? 0,
      icon: BookOpen,
      color: 'text-flehub-green',
      bg: 'bg-flehub-green-light',
      href: '/dashboard/teacher/courses',
    },
    {
      title: 'My Learners',
      value: stats?.totalLearners ?? 0,
      icon: Users,
      color: 'text-blue-600',
      bg: 'bg-blue-50',
      href: null,
    },
    {
      title: 'Upcoming Sessions',
      value: stats?.upcomingSessions ?? 0,
      icon: Video,
      color: 'text-orange-600',
      bg: 'bg-orange-50',
      href: '/dashboard/teacher/sessions',
    },
    {
      title: 'Exercises',
      value: stats?.exercisesCreated ?? 0,
      icon: PenSquare,
      color: 'text-purple-600',
      bg: 'bg-purple-50',
      href: '/dashboard/teacher/exercises',
    },
  ];

  return (
    <div className="p-6 space-y-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Teacher Dashboard</h1>
          <p className="text-gray-500 text-sm mt-1">Manage your courses, exercises, and sessions</p>
        </div>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => (window.location.href = '/dashboard/teacher/sessions')}
          >
            <Calendar className="w-4 h-4 mr-1" />
            Schedule Session
          </Button>
          <Button
            size="sm"
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
            onClick={() => (window.location.href = '/dashboard/teacher/courses')}
          >
            <Plus className="w-4 h-4 mr-1" />
            Create Course
          </Button>
        </div>
      </div>

      {/* Stat Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {statCards.map((card) => (
          <Card key={card.title} className="card-hover cursor-pointer" onClick={() => card.href && (window.location.href = card.href)}>
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
        {/* Upcoming Sessions */}
        <Card className="lg:col-span-1">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-base font-semibold">Upcoming Live Sessions</CardTitle>
            <Button
              variant="ghost"
              size="sm"
              className="text-flehub-green text-xs"
              onClick={() => (window.location.href = '/dashboard/teacher/sessions')}
            >
              View all <ArrowRight className="w-3 h-3 ml-1" />
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
              <p className="text-sm text-gray-400 py-4 text-center">No upcoming sessions</p>
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
                      Join
                    </Button>
                  </div>
                </div>
              ))
            )}
          </CardContent>
        </Card>

        {/* Recent Learner Activity */}
        <Card className="lg:col-span-2">
          <CardHeader className="pb-2">
            <CardTitle className="text-base font-semibold">Recent Learner Activity</CardTitle>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="space-y-3">
                {Array.from({ length: 5 }).map((_, i) => (
                  <Skeleton key={i} className="h-8 w-full" />
                ))}
              </div>
            ) : activity.length === 0 ? (
              <p className="text-sm text-gray-400 py-4 text-center">No learner activity yet</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-gray-100">
                      <th className="text-left pb-2 text-gray-500 font-medium">Learner</th>
                      <th className="text-left pb-2 text-gray-500 font-medium">Course</th>
                      <th className="text-left pb-2 text-gray-500 font-medium">Progress</th>
                      <th className="text-left pb-2 text-gray-500 font-medium">Last Active</th>
                    </tr>
                  </thead>
                  <tbody>
                    {activity.map((a) => (
                      <tr key={a.id} className="border-b border-gray-50 hover:bg-gray-50">
                        <td className="py-2 font-medium text-gray-800">{a.learner_name}</td>
                        <td className="py-2 text-gray-600 max-w-[140px] truncate">{a.course_title}</td>
                        <td className="py-2">
                          <div className="flex items-center gap-2">
                            <div className="flex-1 bg-gray-200 rounded-full h-1.5 w-20">
                              <div
                                className="bg-flehub-green h-1.5 rounded-full"
                                style={{ width: `${a.progress_percent}%` }}
                              />
                            </div>
                            <span className="text-xs text-gray-500">{a.progress_percent}%</span>
                          </div>
                        </td>
                        <td className="py-2 text-xs text-gray-400">
                          {new Date(a.last_activity).toLocaleDateString('en-RW')}
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

      {/* Quick Actions */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base font-semibold">Quick Actions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <Button
              variant="outline"
              className="h-16 flex flex-col gap-1 text-flehub-green border-flehub-green hover:bg-flehub-green-light"
              onClick={() => (window.location.href = '/dashboard/teacher/courses')}
            >
              <BookOpen className="w-5 h-5" />
              <span className="text-sm font-medium">Create Course</span>
            </Button>
            <Button
              variant="outline"
              className="h-16 flex flex-col gap-1 text-blue-600 border-blue-200 hover:bg-blue-50"
              onClick={() => (window.location.href = '/dashboard/teacher/exercises')}
            >
              <PenSquare className="w-5 h-5" />
              <span className="text-sm font-medium">Add Exercise</span>
            </Button>
            <Button
              variant="outline"
              className="h-16 flex flex-col gap-1 text-orange-600 border-orange-200 hover:bg-orange-50"
              onClick={() => (window.location.href = '/dashboard/teacher/sessions')}
            >
              <Calendar className="w-5 h-5" />
              <span className="text-sm font-medium">Schedule Session</span>
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
