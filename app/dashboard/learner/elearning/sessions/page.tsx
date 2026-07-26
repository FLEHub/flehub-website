'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import {
  ArrowLeft,
  Calendar,
  Clock,
  ExternalLink,
  GraduationCap,
  Video,
  VideoOff,
} from 'lucide-react';
import { createClient } from '@/lib/supabase/client';
import {
  canJoinSession,
  getCurrentLearnerId,
} from '@/lib/learner-session';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';

type SessionStatus = 'scheduled' | 'live' | 'completed' | 'cancelled';

interface SessionCard {
  id: string;
  title: string;
  description: string | null;
  scheduled_at: string;
  duration_minutes: number | null;
  cefr_level: string | null;
  status: SessionStatus;
  meeting_url: string | null;
  teacher_name: string;
}

const statusConfig: Record<
  SessionStatus,
  { label: string; badgeClass: string }
> = {
  scheduled: {
    label: 'Planifiée',
    badgeClass: 'bg-blue-100 text-blue-700 border-blue-200',
  },
  live: {
    label: 'En direct',
    badgeClass:
      'bg-flehub-green-light text-flehub-green border-flehub-green',
  },
  completed: {
    label: 'Terminée',
    badgeClass: 'bg-gray-100 text-gray-600 border-gray-300',
  },
  cancelled: {
    label: 'Annulée',
    badgeClass: 'bg-red-100 text-red-600 border-red-200',
  },
};

function nestedTeacherName(row: any): string {
  const teachers = Array.isArray(row.teachers) ? row.teachers[0] : row.teachers;
  const profiles = Array.isArray(teachers?.profiles)
    ? teachers.profiles[0]
    : teachers?.profiles;
  return profiles?.full_name?.trim() || 'Enseignant';
}

export default function LearnerSessionsPage() {
  const supabase = createClient();
  const [loading, setLoading] = useState(true);
  const [hasTeachers, setHasTeachers] = useState(false);
  const [sessions, setSessions] = useState<SessionCard[]>([]);
  const [, setTick] = useState(0);

  const load = useCallback(async () => {
    try {
      const lid = await getCurrentLearnerId(supabase);
      if (!lid) return;

      const { data: links } = await supabase
        .from('learner_teacher_links')
        .select('teacher_id')
        .eq('learner_id', lid);

      const teacherIds = (links ?? []).map((l) => l.teacher_id as string);
      setHasTeachers(teacherIds.length > 0);

      if (teacherIds.length === 0) {
        setSessions([]);
        return;
      }

      const { data: rows } = await supabase
        .from('live_sessions')
        .select(
          `
          id,
          title,
          description,
          scheduled_at,
          duration_minutes,
          cefr_level,
          status,
          meeting_url,
          teachers (
            profiles ( full_name )
          )
        `
        )
        .in('teacher_id', teacherIds)
        .order('scheduled_at', { ascending: true });

      setSessions(
        (rows ?? []).map((r: any) => ({
          id: r.id,
          title: r.title,
          description: r.description,
          scheduled_at: r.scheduled_at,
          duration_minutes: r.duration_minutes,
          cefr_level: r.cefr_level,
          status: r.status as SessionStatus,
          meeting_url: r.meeting_url,
          teacher_name: nestedTeacherName(r),
        }))
      );
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  // Refresh join eligibility every minute
  useEffect(() => {
    const id = window.setInterval(() => setTick((t) => t + 1), 60_000);
    return () => window.clearInterval(id);
  }, []);

  return (
    <div className="p-6 space-y-6 max-w-4xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <Button variant="ghost" size="sm" className="-ml-2 mb-1" asChild>
            <Link href="/dashboard/learner/elearning">
              <ArrowLeft className="mr-1 h-4 w-4" />
              Modules
            </Link>
          </Button>
          <h1 className="text-2xl font-bold text-gray-900">Sessions visio</h1>
          <p className="text-sm text-gray-500 mt-1">
            Lives de vos enseignants — rejoignez 15 min avant le début
          </p>
        </div>
        <Button asChild variant="outline" size="sm">
          <Link href="/dashboard/learner/elearning/teachers">
            <GraduationCap className="w-4 h-4 mr-1" />
            Mes enseignants
          </Link>
        </Button>
      </div>

      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <Skeleton key={i} className="h-28 rounded-xl" />
          ))}
        </div>
      ) : !hasTeachers ? (
        <div className="flex flex-col items-center justify-center py-16 text-gray-400 border border-dashed border-gray-200 rounded-xl">
          <GraduationCap className="w-12 h-12 mb-3 opacity-40" />
          <p className="text-lg font-medium text-gray-700">
            Choisissez d&apos;abord un enseignant
          </p>
          <Button
            asChild
            className="mt-4 bg-flehub-green hover:bg-flehub-green/90 text-white"
          >
            <Link href="/dashboard/learner/elearning/teachers">
              Choisir un enseignant
            </Link>
          </Button>
        </div>
      ) : sessions.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-gray-400 border border-dashed border-gray-200 rounded-xl">
          <VideoOff className="w-12 h-12 mb-3 opacity-40" />
          <p className="text-lg font-medium">Aucune session</p>
          <p className="text-sm">
            Vos enseignants n&apos;ont pas encore planifié de visio
          </p>
        </div>
      ) : (
        <div className="space-y-3">
          {sessions.map((session) => {
            const cfg = statusConfig[session.status] ?? statusConfig.scheduled;
            const joinable =
              !!session.meeting_url &&
              canJoinSession(session.scheduled_at, session.status);
            const when = new Date(session.scheduled_at);

            return (
              <Card key={session.id} className="card-hover">
                <CardContent className="flex flex-col sm:flex-row sm:items-center gap-4 py-4">
                  <div className="p-2.5 rounded-lg bg-flehub-green-light shrink-0 self-start">
                    <Video className="w-5 h-5 text-flehub-green" />
                  </div>
                  <div className="flex-1 min-w-0 space-y-1">
                    <div className="flex flex-wrap items-center gap-2">
                      <h3 className="font-semibold text-gray-900 text-sm">
                        {session.title}
                      </h3>
                      <Badge
                        variant="outline"
                        className={`text-xs ${cfg.badgeClass}`}
                      >
                        {cfg.label}
                      </Badge>
                      {session.cefr_level && (
                        <Badge variant="secondary" className="text-xs">
                          {session.cefr_level}
                        </Badge>
                      )}
                    </div>
                    <p className="text-xs text-gray-400">
                      {session.teacher_name}
                    </p>
                    {session.description && (
                      <p className="text-xs text-gray-600 line-clamp-2">
                        {session.description}
                      </p>
                    )}
                    <div className="flex flex-wrap gap-3 text-xs text-gray-500 pt-1">
                      <span className="inline-flex items-center gap-1">
                        <Calendar className="w-3.5 h-3.5" />
                        {when.toLocaleDateString('fr-FR', {
                          weekday: 'short',
                          day: 'numeric',
                          month: 'short',
                          year: 'numeric',
                        })}{' '}
                        {when.toLocaleTimeString('fr-FR', {
                          hour: '2-digit',
                          minute: '2-digit',
                        })}
                      </span>
                      {session.duration_minutes != null && (
                        <span className="inline-flex items-center gap-1">
                          <Clock className="w-3.5 h-3.5" />
                          {session.duration_minutes} min
                        </span>
                      )}
                    </div>
                  </div>
                  <Button
                    size="sm"
                    className="bg-flehub-green hover:bg-flehub-green/90 text-white shrink-0"
                    disabled={!joinable}
                    onClick={() => {
                      if (session.meeting_url) {
                        window.open(session.meeting_url, '_blank', 'noopener,noreferrer');
                      }
                    }}
                  >
                    <ExternalLink className="w-3.5 h-3.5 mr-1" />
                    Rejoindre
                  </Button>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
