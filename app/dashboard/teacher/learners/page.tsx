'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Label } from '@/components/ui/label';
import {
  Dialog,
  DialogContent,
  DialogFooter,
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
  AlertTriangle,
  BookOpen,
  Calendar,
  Trash2,
  UserCheck,
  Users,
} from 'lucide-react';

interface ModuleOption {
  id: string;
  title: string;
  published: boolean;
}

interface AssignmentRow {
  id: string;
  module_id: string;
  module_title: string;
  start_date: string;
  end_date: string;
}

interface LearnerRow {
  id: string;
  full_name: string;
  email: string;
  assignments: AssignmentRow[];
  selectedModuleId: string;
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

function formatDate(iso: string) {
  if (!iso) return '—';
  return new Date(iso).toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  });
}

function isUniqueViolation(err: unknown): boolean {
  if (!err || typeof err !== 'object') return false;
  const e = err as { code?: string; message?: string };
  return (
    e.code === '23505' ||
    (typeof e.message === 'string' &&
      e.message.toLowerCase().includes('duplicate'))
  );
}

export default function TeacherLearnersPage() {
  const supabase = createClient();

  const [loading, setLoading] = useState(true);
  const [teacherId, setTeacherId] = useState<string | null>(null);
  const [modules, setModules] = useState<ModuleOption[]>([]);
  const [learners, setLearners] = useState<LearnerRow[]>([]);
  const [busyKey, setBusyKey] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [infoByLearner, setInfoByLearner] = useState<Record<string, string>>({});
  const [deleteTarget, setDeleteTarget] = useState<{
    assignmentId: string;
    learnerId: string;
    moduleTitle: string;
  } | null>(null);

  const moduleMap = useMemo(
    () => new Map(modules.map((m) => [m.id, m.title])),
    [modules]
  );

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
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

      if (!teacher) {
        setError('Profil enseignant introuvable.');
        return;
      }
      setTeacherId(teacher.id);

      const [{ data: moduleRows }, { data: links }, { data: assignmentRows }] =
        await Promise.all([
          supabase
            .from('elearning_modules')
            .select('id, title, published')
            .eq('teacher_id', teacher.id)
            .order('title', { ascending: true }),
          supabase
            .from('learner_teacher_links')
            .select(
              `
              learner_id,
              learners (
                id,
                profiles ( full_name, email )
              )
            `
            )
            .eq('teacher_id', teacher.id),
          supabase
            .from('elearning_module_assignments')
            .select(
              `
              id,
              module_id,
              learner_id,
              start_date,
              end_date,
              elearning_modules ( title )
            `
            )
            .eq('teacher_id', teacher.id)
            .order('start_date', { ascending: false }),
        ]);

      const moduleList = (moduleRows as ModuleOption[]) ?? [];
      setModules(moduleList);

      const assignmentsByLearner = new Map<string, AssignmentRow[]>();
      (assignmentRows ?? []).forEach((row: any) => {
        const mod = Array.isArray(row.elearning_modules)
          ? row.elearning_modules[0]
          : row.elearning_modules;
        const item: AssignmentRow = {
          id: row.id,
          module_id: row.module_id,
          module_title: mod?.title ?? 'Module',
          start_date: row.start_date,
          end_date: row.end_date,
        };
        const list = assignmentsByLearner.get(row.learner_id) ?? [];
        list.push(item);
        assignmentsByLearner.set(row.learner_id, list);
      });

      const learnerMap = new Map<string, LearnerRow>();

      (links ?? []).forEach((link: any) => {
        const learner = Array.isArray(link.learners)
          ? link.learners[0]
          : link.learners;
        if (!learner?.id) return;
        const profile = nestedProfile(learner);
        learnerMap.set(learner.id, {
          id: learner.id,
          full_name: profile.full_name,
          email: profile.email,
          assignments: assignmentsByLearner.get(learner.id) ?? [],
          selectedModuleId: '',
        });
      });

      // Include learners who have assignments even if the link was removed.
      assignmentsByLearner.forEach((assignments, learnerId) => {
        if (learnerMap.has(learnerId)) return;
        learnerMap.set(learnerId, {
          id: learnerId,
          full_name: 'Apprenant',
          email: '',
          assignments,
          selectedModuleId: '',
        });
      });

      // Enrich names for assignment-only learners.
      const orphanIds = Array.from(learnerMap.values())
        .filter((l) => l.full_name === 'Apprenant' && !l.email)
        .map((l) => l.id);
      if (orphanIds.length > 0) {
        const { data: orphanLearners } = await supabase
          .from('learners')
          .select('id, profiles ( full_name, email )')
          .in('id', orphanIds);
        (orphanLearners ?? []).forEach((row: any) => {
          const profile = nestedProfile(row);
          const existing = learnerMap.get(row.id);
          if (!existing) return;
          learnerMap.set(row.id, {
            ...existing,
            full_name: profile.full_name,
            email: profile.email,
          });
        });
      }

      setLearners(
        Array.from(learnerMap.values()).sort((a, b) =>
          a.full_name.localeCompare(b.full_name, 'fr')
        )
      );
    } catch (err) {
      console.error(err);
      setError('Impossible de charger les apprenants.');
    } finally {
      setLoading(false);
    }
  }, [supabase]);

  useEffect(() => {
    void load();
  }, [load]);

  function setSelectedModule(learnerId: string, moduleId: string) {
    setLearners((prev) =>
      prev.map((l) =>
        l.id === learnerId ? { ...l, selectedModuleId: moduleId } : l
      )
    );
    setInfoByLearner((prev) => {
      const next = { ...prev };
      delete next[learnerId];
      return next;
    });
  }

  async function assignModule(learner: LearnerRow) {
    if (!teacherId || !learner.selectedModuleId) return;

    const already = learner.assignments.some(
      (a) => a.module_id === learner.selectedModuleId
    );
    if (already) {
      setInfoByLearner((prev) => ({
        ...prev,
        [learner.id]: 'Ce module est déjà assigné à cet apprenant.',
      }));
      return;
    }

    setBusyKey(`assign-${learner.id}`);
    setInfoByLearner((prev) => {
      const next = { ...prev };
      delete next[learner.id];
      return next;
    });

    try {
      const { data, error: insErr } = await supabase
        .from('elearning_module_assignments')
        .insert({
          module_id: learner.selectedModuleId,
          learner_id: learner.id,
          teacher_id: teacherId,
        })
        .select('id, module_id, start_date, end_date')
        .maybeSingle();

      if (insErr) {
        if (isUniqueViolation(insErr)) {
          setInfoByLearner((prev) => ({
            ...prev,
            [learner.id]: 'Ce module est déjà assigné à cet apprenant.',
          }));
          return;
        }
        throw insErr;
      }

      if (data) {
        const title =
          moduleMap.get(data.module_id) ??
          modules.find((m) => m.id === data.module_id)?.title ??
          'Module';
        setLearners((prev) =>
          prev.map((l) =>
            l.id === learner.id
              ? {
                  ...l,
                  selectedModuleId: '',
                  assignments: [
                    {
                      id: data.id,
                      module_id: data.module_id,
                      module_title: title,
                      start_date: data.start_date,
                      end_date: data.end_date,
                    },
                    ...l.assignments,
                  ],
                }
              : l
          )
        );
      } else {
        await load();
      }
    } catch (err) {
      console.error(err);
      setInfoByLearner((prev) => ({
        ...prev,
        [learner.id]:
          err instanceof Error ? err.message : 'Échec de l’assignation',
      }));
    } finally {
      setBusyKey(null);
    }
  }

  async function confirmRemove() {
    if (!deleteTarget) return;
    const { assignmentId, learnerId } = deleteTarget;
    setBusyKey(`del-${assignmentId}`);
    try {
      const { error: delErr } = await supabase
        .from('elearning_module_assignments')
        .delete()
        .eq('id', assignmentId);
      if (delErr) throw delErr;

      setLearners((prev) =>
        prev.map((l) =>
          l.id === learnerId
            ? {
                ...l,
                assignments: l.assignments.filter((a) => a.id !== assignmentId),
              }
            : l
        )
      );
      setDeleteTarget(null);
    } catch (err) {
      console.error(err);
      setError(
        err instanceof Error ? err.message : 'Impossible de retirer l’assignation'
      );
    } finally {
      setBusyKey(null);
    }
  }

  const availableModulesFor = (learner: LearnerRow) => {
    const assigned = new Set(learner.assignments.map((a) => a.module_id));
    return modules.filter((m) => !assigned.has(m.id));
  };

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Apprenants</h1>
        <p className="text-sm text-gray-500 mt-1">
          Assignez vos modules eLearning à vos apprenants (accès 1 mois)
        </p>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 shrink-0" />
          {error}
        </div>
      )}

      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <Skeleton key={i} className="h-40 w-full rounded-xl" />
          ))}
        </div>
      ) : modules.length === 0 ? (
        <Card>
          <CardContent className="py-12 flex flex-col items-center text-gray-400">
            <BookOpen className="w-10 h-10 mb-3 opacity-40" />
            <p className="font-medium text-gray-700">Aucun module</p>
            <p className="text-sm">Créez d’abord un module eLearning.</p>
          </CardContent>
        </Card>
      ) : learners.length === 0 ? (
        <Card>
          <CardContent className="py-12 flex flex-col items-center text-gray-400">
            <Users className="w-10 h-10 mb-3 opacity-40" />
            <p className="font-medium text-gray-700">Aucun apprenant lié</p>
            <p className="text-sm text-center max-w-md">
              Les apprenants qui vous choisissent comme enseignant apparaîtront
              ici.
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          {learners.map((learner) => {
            const available = availableModulesFor(learner);
            return (
              <Card key={learner.id}>
                <CardHeader className="pb-3">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <CardTitle className="text-base flex items-center gap-2">
                        <UserCheck className="w-4 h-4 text-flehub-green" />
                        {learner.full_name}
                      </CardTitle>
                      {learner.email && (
                        <p className="text-xs text-gray-400 mt-1">{learner.email}</p>
                      )}
                    </div>
                    <Badge variant="secondary">
                      {learner.assignments.length} module
                      {learner.assignments.length !== 1 ? 's' : ''}
                    </Badge>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  {learner.assignments.length > 0 ? (
                    <ul className="space-y-2">
                      {learner.assignments.map((a) => (
                        <li
                          key={a.id}
                          className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 rounded-lg border border-gray-100 bg-gray-50 px-3 py-2"
                        >
                          <div className="min-w-0">
                            <p className="text-sm font-medium text-gray-900 truncate">
                              {a.module_title}
                            </p>
                            <p className="text-xs text-gray-500 flex items-center gap-1 mt-0.5">
                              <Calendar className="w-3 h-3" />
                              Fin d’accès : {formatDate(a.end_date)}
                              <span className="text-gray-300">·</span>
                              Début : {formatDate(a.start_date)}
                            </p>
                          </div>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-red-500 hover:bg-red-50 shrink-0"
                            disabled={busyKey === `del-${a.id}`}
                            onClick={() =>
                              setDeleteTarget({
                                assignmentId: a.id,
                                learnerId: learner.id,
                                moduleTitle: a.module_title,
                              })
                            }
                          >
                            <Trash2 className="w-3.5 h-3.5 mr-1" />
                            Retirer
                          </Button>
                        </li>
                      ))}
                    </ul>
                  ) : (
                    <p className="text-sm text-gray-400">
                      Aucun module assigné pour le moment.
                    </p>
                  )}

                  <div className="flex flex-col sm:flex-row gap-2 sm:items-end">
                    <div className="flex-1 space-y-1.5">
                      <Label>Assigner un module</Label>
                      <Select
                        value={learner.selectedModuleId || undefined}
                        onValueChange={(v) => setSelectedModule(learner.id, v)}
                        disabled={available.length === 0}
                      >
                        <SelectTrigger>
                          <SelectValue
                            placeholder={
                              available.length === 0
                                ? 'Tous vos modules sont déjà assignés'
                                : 'Choisir un module'
                            }
                          />
                        </SelectTrigger>
                        <SelectContent>
                          {available.map((m) => (
                            <SelectItem key={m.id} value={m.id}>
                              {m.title}
                              {!m.published ? ' (brouillon)' : ''}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                    <Button
                      className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                      disabled={
                        !learner.selectedModuleId ||
                        busyKey === `assign-${learner.id}`
                      }
                      onClick={() => void assignModule(learner)}
                    >
                      {busyKey === `assign-${learner.id}`
                        ? 'Assignation…'
                        : 'Assigner'}
                    </Button>
                  </div>

                  {infoByLearner[learner.id] && (
                    <p className="text-sm text-amber-700 bg-amber-50 border border-amber-200 rounded-md px-3 py-2">
                      {infoByLearner[learner.id]}
                    </p>
                  )}
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}

      <Dialog
        open={!!deleteTarget}
        onOpenChange={(open) => {
          if (!open) setDeleteTarget(null);
        }}
      >
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Retirer cette assignation ?</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-gray-500">
            Le module « {deleteTarget?.moduleTitle} » ne sera plus assigné à cet
            apprenant. Les données du module ne sont pas supprimées.
          </p>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteTarget(null)}>
              Annuler
            </Button>
            <Button
              variant="destructive"
              disabled={!!busyKey?.startsWith('del-')}
              onClick={() => void confirmRemove()}
            >
              Retirer
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
