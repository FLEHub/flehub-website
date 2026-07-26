'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
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
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  BookOpen,
  Plus,
  Search,
  UserMinus,
  UserPlus,
  Users,
} from 'lucide-react';

interface ModuleOption {
  id: string;
  title: string;
  published: boolean;
}

interface EnrolledLearner {
  enrollment_id: string;
  learner_id: string;
  full_name: string;
  email: string;
  enrolled_at: string;
}

interface AvailableLearner {
  id: string;
  full_name: string;
  email: string;
}

function nestedProfile(row: {
  profiles?:
    | { full_name?: string; email?: string }
    | { full_name?: string; email?: string }[]
    | null;
}): { full_name: string; email: string } {
  const profiles = row.profiles;
  const profile = Array.isArray(profiles) ? profiles[0] : profiles;
  return {
    full_name: profile?.full_name?.trim() || 'Apprenant',
    email: profile?.email?.trim() || '',
  };
}

export default function TeacherLearnersPage() {
  const supabase = createClient();

  const [loading, setLoading] = useState(true);
  const [enrollmentsLoading, setEnrollmentsLoading] = useState(false);
  const [busyId, setBusyId] = useState<string | null>(null);

  const [modules, setModules] = useState<ModuleOption[]>([]);
  const [selectedModuleId, setSelectedModuleId] = useState<string>('');
  const [enrolled, setEnrolled] = useState<EnrolledLearner[]>([]);
  const [allLearners, setAllLearners] = useState<AvailableLearner[]>([]);

  const [dialogOpen, setDialogOpen] = useState(false);
  const [search, setSearch] = useState('');
  const [candidatesLoading, setCandidatesLoading] = useState(false);

  const loadModules = useCallback(async () => {
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
        .select('id, title, published')
        .eq('teacher_id', teacher.id)
        .order('title', { ascending: true });

      const list = (moduleRows as ModuleOption[]) ?? [];
      setModules(list);
      if (list.length > 0) {
        setSelectedModuleId((prev) => prev || list[0].id);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const loadEnrollments = useCallback(async (moduleId: string) => {
    if (!moduleId) {
      setEnrolled([]);
      return;
    }
    setEnrollmentsLoading(true);
    try {
      const { data, error } = await supabase
        .from('elearning_enrollments')
        .select(
          `
          id,
          enrolled_at,
          learner_id,
          learners (
            id,
            profiles ( full_name, email )
          )
        `
        )
        .eq('module_id', moduleId)
        .order('enrolled_at', { ascending: false });

      if (error) throw error;

      const mapped: EnrolledLearner[] = (data ?? []).map((row: any) => {
        const learner = Array.isArray(row.learners) ? row.learners[0] : row.learners;
        const profile = nestedProfile(learner ?? {});
        return {
          enrollment_id: row.id,
          learner_id: row.learner_id,
          full_name: profile.full_name,
          email: profile.email,
          enrolled_at: row.enrolled_at,
        };
      });

      setEnrolled(mapped);
    } catch (err) {
      console.error(err);
      setEnrolled([]);
    } finally {
      setEnrollmentsLoading(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const loadAllLearners = useCallback(async () => {
    setCandidatesLoading(true);
    try {
      const { data, error } = await supabase
        .from('learners')
        .select(
          `
          id,
          profiles ( full_name, email )
        `
        )
        .order('created_at', { ascending: false });

      if (error) throw error;

      const mapped: AvailableLearner[] = (data ?? []).map((row: any) => {
        const profile = nestedProfile(row);
        return {
          id: row.id,
          full_name: profile.full_name,
          email: profile.email,
        };
      });

      setAllLearners(mapped);
    } catch (err) {
      console.error(err);
      setAllLearners([]);
    } finally {
      setCandidatesLoading(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    loadModules();
  }, [loadModules]);

  useEffect(() => {
    if (selectedModuleId) {
      loadEnrollments(selectedModuleId);
    }
  }, [selectedModuleId, loadEnrollments]);

  const enrolledIds = useMemo(
    () => new Set(enrolled.map((e) => e.learner_id)),
    [enrolled]
  );

  const candidates = useMemo(() => {
    const q = search.trim().toLowerCase();
    return allLearners
      .filter((l) => !enrolledIds.has(l.id))
      .filter((l) => {
        if (!q) return true;
        return (
          l.full_name.toLowerCase().includes(q) ||
          l.email.toLowerCase().includes(q)
        );
      });
  }, [allLearners, enrolledIds, search]);

  async function openAddDialog() {
    setSearch('');
    setDialogOpen(true);
    if (allLearners.length === 0) {
      await loadAllLearners();
    }
  }

  async function enrollLearner(learnerId: string) {
    if (!selectedModuleId) return;
    setBusyId(learnerId);
    try {
      const { error } = await supabase.from('elearning_enrollments').insert({
        module_id: selectedModuleId,
        learner_id: learnerId,
      });
      if (error) throw error;

      const learner = allLearners.find((l) => l.id === learnerId);
      setEnrolled((prev) => [
        {
          enrollment_id: `tmp-${learnerId}`,
          learner_id: learnerId,
          full_name: learner?.full_name ?? 'Apprenant',
          email: learner?.email ?? '',
          enrolled_at: new Date().toISOString(),
        },
        ...prev,
      ]);

      // Refresh to get real enrollment id
      await loadEnrollments(selectedModuleId);
    } catch (err) {
      console.error(err);
    } finally {
      setBusyId(null);
    }
  }

  async function removeAccess(enrollmentId: string, learnerId: string) {
    setBusyId(learnerId);
    try {
      const { error } = await supabase
        .from('elearning_enrollments')
        .delete()
        .eq('id', enrollmentId);
      if (error) throw error;
      setEnrolled((prev) => prev.filter((e) => e.enrollment_id !== enrollmentId));
    } catch (err) {
      console.error(err);
    } finally {
      setBusyId(null);
    }
  }

  const selectedModule = modules.find((m) => m.id === selectedModuleId);

  if (loading) {
    return (
      <div className="p-6 space-y-6 max-w-5xl mx-auto">
        <Skeleton className="h-8 w-56" />
        <Skeleton className="h-10 w-72" />
        <Skeleton className="h-40 w-full rounded-xl" />
      </div>
    );
  }

  if (modules.length === 0) {
    return (
      <div className="p-6 max-w-5xl mx-auto">
        <div className="flex flex-col items-center justify-center py-20 text-gray-400 border border-dashed border-gray-200 rounded-xl">
          <BookOpen className="w-12 h-12 mb-3 opacity-40" />
          <p className="text-lg font-medium text-gray-700 text-center px-4">
            Crée d&apos;abord un module dans Modules avant de pouvoir y inscrire
            des apprenants
          </p>
          <p className="text-sm mt-1 mb-4 text-center px-4">
            Une fois un module créé, tu pourras lui attribuer l&apos;accès ici.
          </p>
          <Button
            asChild
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
          >
            <Link href="/dashboard/teacher/elearning">Aller aux Modules</Link>
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Apprenants</h1>
          <p className="text-gray-500 text-sm mt-1">
            Attribue l&apos;accès à tes modules eLearning
          </p>
        </div>
        <div className="space-y-2 w-full sm:w-80">
          <Label>Module</Label>
          <Select value={selectedModuleId} onValueChange={setSelectedModuleId}>
            <SelectTrigger>
              <SelectValue placeholder="Choisir un module" />
            </SelectTrigger>
            <SelectContent className="bg-white">
              {modules.map((m) => (
                <SelectItem key={m.id} value={m.id}>
                  {m.title}
                  {!m.published ? ' (brouillon)' : ''}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      <Card>
        <CardHeader className="pb-3 flex flex-row items-center justify-between gap-3">
          <div>
            <CardTitle className="text-base font-semibold flex items-center gap-2">
              <Users className="w-4 h-4 text-flehub-green" />
              Inscrits
              {selectedModule && (
                <span className="font-normal text-gray-400 text-sm">
                  — {selectedModule.title}
                </span>
              )}
            </CardTitle>
            <p className="text-xs text-gray-400 mt-1">
              {enrolled.length} apprenant{enrolled.length !== 1 ? 's' : ''} avec accès
            </p>
          </div>
          <Button
            size="sm"
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
            onClick={openAddDialog}
            disabled={!selectedModuleId}
          >
            <Plus className="w-4 h-4 mr-1" />
            Ajouter un apprenant
          </Button>
        </CardHeader>
        <CardContent className="space-y-2">
          {enrollmentsLoading ? (
            Array.from({ length: 4 }).map((_, i) => (
              <Skeleton key={i} className="h-16 w-full rounded-lg" />
            ))
          ) : enrolled.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-gray-400">
              <UserPlus className="w-10 h-10 mb-2 opacity-40" />
              <p className="text-sm font-medium">Aucun apprenant inscrit</p>
              <p className="text-xs">Ajoutez des apprenants pour leur donner accès</p>
            </div>
          ) : (
            enrolled.map((row) => (
              <div
                key={row.enrollment_id}
                className="flex items-center justify-between gap-3 p-3 rounded-lg border border-gray-100 bg-gray-50"
              >
                <div className="min-w-0">
                  <p className="text-sm font-medium text-gray-900 truncate">
                    {row.full_name}
                  </p>
                  <p className="text-xs text-gray-500 truncate">{row.email}</p>
                  <p className="text-[11px] text-gray-400 mt-0.5">
                    Inscrit le{' '}
                    {new Date(row.enrolled_at).toLocaleDateString('fr-FR')}
                  </p>
                </div>
                <Button
                  variant="outline"
                  size="sm"
                  className="text-red-600 border-red-200 hover:bg-red-50 shrink-0"
                  disabled={busyId === row.learner_id}
                  onClick={() => removeAccess(row.enrollment_id, row.learner_id)}
                >
                  <UserMinus className="w-3.5 h-3.5 mr-1" />
                  Retirer l&apos;accès
                </Button>
              </div>
            ))
          )}
        </CardContent>
      </Card>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto bg-white">
          <DialogHeader>
            <DialogTitle>Ajouter un apprenant</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="relative">
              <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
              <Input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Rechercher par nom ou email…"
                className="pl-9"
              />
            </div>

            {candidatesLoading ? (
              <div className="space-y-2">
                {Array.from({ length: 5 }).map((_, i) => (
                  <Skeleton key={i} className="h-14 w-full rounded-lg" />
                ))}
              </div>
            ) : candidates.length === 0 ? (
              <p className="text-sm text-gray-400 text-center py-8">
                {search.trim()
                  ? 'Aucun apprenant ne correspond à la recherche'
                  : 'Tous les apprenants sont déjà inscrits à ce module'}
              </p>
            ) : (
              <div className="space-y-2 max-h-[50vh] overflow-y-auto pr-1">
                {candidates.map((learner) => (
                  <button
                    key={learner.id}
                    type="button"
                    disabled={busyId === learner.id}
                    onClick={() => enrollLearner(learner.id)}
                    className="w-full flex items-center justify-between gap-3 p-3 rounded-lg border border-gray-100 bg-gray-50 hover:bg-flehub-green-light/50 hover:border-flehub-green/30 transition-colors text-left disabled:opacity-60"
                  >
                    <div className="min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">
                        {learner.full_name}
                      </p>
                      <p className="text-xs text-gray-500 truncate">{learner.email}</p>
                    </div>
                    <Badge
                      variant="outline"
                      className="shrink-0 border-flehub-green text-flehub-green bg-white"
                    >
                      {busyId === learner.id ? '…' : 'Inscrire'}
                    </Badge>
                  </button>
                ))}
              </div>
            )}
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
