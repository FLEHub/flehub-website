'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/client';
import { getCurrentLearnerId } from '@/lib/learner-session';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { ArrowLeft, Check, GraduationCap, UserMinus, UserPlus } from 'lucide-react';

interface TeacherCard {
  id: string;
  full_name: string;
  email: string;
  bio: string | null;
  specializations: string[];
}

function nestedProfile(row: any): { full_name: string; email: string } {
  const profiles = row.profiles;
  const profile = Array.isArray(profiles) ? profiles[0] : profiles;
  return {
    full_name: profile?.full_name?.trim() || 'Enseignant',
    email: profile?.email?.trim() || '',
  };
}

export default function LearnerChooseTeachersPage() {
  const supabase = createClient();
  const [loading, setLoading] = useState(true);
  const [learnerId, setLearnerId] = useState<string | null>(null);
  const [teachers, setTeachers] = useState<TeacherCard[]>([]);
  const [chosenIds, setChosenIds] = useState<Set<string>>(new Set());
  const [busyId, setBusyId] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      const lid = await getCurrentLearnerId(supabase);
      if (!lid) return;
      setLearnerId(lid);

      const [{ data: teacherRows }, { data: links }] = await Promise.all([
        supabase
          .from('teachers')
          .select('id, bio, specializations, profiles ( full_name, email )')
          .order('created_at', { ascending: true }),
        supabase
          .from('learner_teacher_links')
          .select('teacher_id')
          .eq('learner_id', lid),
      ]);

      setChosenIds(new Set((links ?? []).map((l) => l.teacher_id as string)));

      setTeachers(
        (teacherRows ?? []).map((t: any) => {
          const p = nestedProfile(t);
          return {
            id: t.id,
            full_name: p.full_name,
            email: p.email,
            bio: t.bio,
            specializations: Array.isArray(t.specializations) ? t.specializations : [],
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

  async function chooseTeacher(teacherId: string) {
    if (!learnerId) return;
    setBusyId(teacherId);
    try {
      const { error } = await supabase.from('learner_teacher_links').insert({
        learner_id: learnerId,
        teacher_id: teacherId,
      });
      if (error) throw error;
      setChosenIds((prev) => new Set(prev).add(teacherId));
    } catch (err) {
      console.error(err);
    } finally {
      setBusyId(null);
    }
  }

  async function removeTeacher(teacherId: string) {
    if (!learnerId) return;
    setBusyId(teacherId);
    try {
      const { error } = await supabase
        .from('learner_teacher_links')
        .delete()
        .eq('learner_id', learnerId)
        .eq('teacher_id', teacherId);
      if (error) throw error;
      setChosenIds((prev) => {
        const next = new Set(prev);
        next.delete(teacherId);
        return next;
      });
    } catch (err) {
      console.error(err);
    } finally {
      setBusyId(null);
    }
  }

  return (
    <div className="p-6 space-y-6 max-w-6xl mx-auto">
      <div className="space-y-2">
        <Button
          asChild
          variant="ghost"
          size="sm"
          className="text-gray-500 hover:text-gray-800 -ml-2"
        >
          <Link href="/dashboard/learner/elearning">
            <ArrowLeft className="w-4 h-4 mr-1" />
            Retour aux modules
          </Link>
        </Button>
        <h1 className="text-2xl font-bold text-gray-900">Choisir un enseignant</h1>
        <p className="text-sm text-gray-500">
          Sélectionnez un ou plusieurs enseignants pour accéder à leurs modules et
          sessions.
        </p>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 6 }).map((_, i) => (
            <Skeleton key={i} className="h-44 rounded-xl" />
          ))}
        </div>
      ) : teachers.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-gray-400 border border-dashed border-gray-200 rounded-xl">
          <GraduationCap className="w-12 h-12 mb-3 opacity-40" />
          <p className="text-lg font-medium">Aucun enseignant disponible</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {teachers.map((teacher) => {
            const chosen = chosenIds.has(teacher.id);
            return (
              <Card key={teacher.id} className="card-hover flex flex-col">
                <CardHeader className="pb-2">
                  <div className="flex items-start gap-3">
                    <div className="p-2 rounded-lg bg-flehub-green-light">
                      <GraduationCap className="w-5 h-5 text-flehub-green" />
                    </div>
                    <div className="min-w-0">
                      <h3 className="font-semibold text-gray-900 text-sm truncate">
                        {teacher.full_name}
                      </h3>
                      <p className="text-xs text-gray-400 truncate">{teacher.email}</p>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="flex flex-col flex-1 justify-between gap-3">
                  <p className="text-xs text-gray-500 line-clamp-3">
                    {teacher.bio || 'Aucune biographie'}
                  </p>
                  {teacher.specializations.length > 0 && (
                    <div className="flex flex-wrap gap-1">
                      {teacher.specializations.slice(0, 4).map((s) => (
                        <Badge key={s} variant="secondary" className="text-xs">
                          {s}
                        </Badge>
                      ))}
                    </div>
                  )}
                  {chosen ? (
                    <div className="flex gap-2">
                      <Button
                        variant="outline"
                        size="sm"
                        className="flex-1 border-flehub-green text-flehub-green"
                        disabled
                      >
                        <Check className="w-3.5 h-3.5 mr-1" />
                        Déjà choisi
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="text-red-500 hover:bg-red-50"
                        disabled={busyId === teacher.id}
                        onClick={() => removeTeacher(teacher.id)}
                      >
                        <UserMinus className="w-3.5 h-3.5" />
                      </Button>
                    </div>
                  ) : (
                    <Button
                      size="sm"
                      className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                      disabled={busyId === teacher.id}
                      onClick={() => chooseTeacher(teacher.id)}
                    >
                      <UserPlus className="w-3.5 h-3.5 mr-1" />
                      Choisir
                    </Button>
                  )}
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
