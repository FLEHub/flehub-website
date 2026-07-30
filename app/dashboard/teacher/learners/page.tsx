'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import type { CefrLevel, ElearningLevelExamScore } from '@/lib/types';
import { CEFR_LEVELS } from '@/lib/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Label } from '@/components/ui/label';
import { Input } from '@/components/ui/input';
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
  ClipboardList,
  Save,
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

interface ScoreForm {
  level: CefrLevel | '';
  score_po: string;
  score_pe: string;
  score_co: string;
  score_ce: string;
  score_langue: string;
}

interface LearnerRow {
  id: string;
  full_name: string;
  email: string;
  assignments: AssignmentRow[];
  selectedModuleId: string;
  examScores: ElearningLevelExamScore[];
  scoreForm: ScoreForm;
}

const EMPTY_SCORE_FORM: ScoreForm = {
  level: '',
  score_po: '',
  score_pe: '',
  score_co: '',
  score_ce: '',
  score_langue: '',
};

const EXAM_COMPS: {
  key: keyof Pick<
    ScoreForm,
    'score_po' | 'score_pe' | 'score_co' | 'score_ce' | 'score_langue'
  >;
  label: string;
  title: string;
}[] = [
  { key: 'score_po', label: 'PO', title: 'Production Orale' },
  { key: 'score_pe', label: 'PE', title: 'Production Écrite' },
  { key: 'score_co', label: 'CO', title: 'Compréhension Orale' },
  { key: 'score_ce', label: 'CE', title: 'Compréhension Écrite' },
  { key: 'score_langue', label: 'Langue', title: 'Étude de la Langue' },
];

const CEFR_COLORS: Record<CefrLevel, string> = {
  A1: 'bg-slate-100 text-slate-600',
  A2: 'bg-blue-50 text-blue-600',
  B1: 'bg-teal-50 text-teal-600',
  B2: 'bg-[#E6F5EE] text-[#00A550]',
  C1: 'bg-orange-50 text-orange-600',
  C2: 'bg-purple-50 text-purple-700',
};

const CEFR_ORDER: Record<CefrLevel, number> = {
  A1: 0,
  A2: 1,
  B1: 2,
  B2: 3,
  C1: 4,
  C2: 5,
};

function unwrapOne<T>(value: T | T[] | null | undefined): T | null {
  if (value == null) return null;
  return Array.isArray(value) ? (value[0] ?? null) : value;
}

function profileFromLearner(row: {
  profiles?:
    | { full_name?: string | null; email?: string | null }
    | { full_name?: string | null; email?: string | null }[]
    | null;
}): { full_name: string; email: string } {
  const profile = unwrapOne(row.profiles);
  return {
    full_name: profile?.full_name?.trim() || '',
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

function parseScore(value: string): number | null {
  const trimmed = value.trim();
  if (!trimmed) return null;
  const n = parseFloat(trimmed);
  if (Number.isNaN(n)) return null;
  return Math.min(20, Math.max(0, n));
}

function calcFormTotal(form: ScoreForm) {
  return EXAM_COMPS.reduce((sum, c) => sum + (parseFloat(form[c.key]) || 0), 0);
}

function scoreToForm(
  score: ElearningLevelExamScore | undefined,
  level: CefrLevel | ''
): ScoreForm {
  if (!score) {
    return { ...EMPTY_SCORE_FORM, level };
  }
  return {
    level: score.level,
    score_po: score.score_po?.toString() ?? '',
    score_pe: score.score_pe?.toString() ?? '',
    score_co: score.score_co?.toString() ?? '',
    score_ce: score.score_ce?.toString() ?? '',
    score_langue: score.score_langue?.toString() ?? '',
  };
}

function sortExamScores(scores: ElearningLevelExamScore[]) {
  return [...scores].sort(
    (a, b) => CEFR_ORDER[a.level] - CEFR_ORDER[b.level]
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
  const [successByLearner, setSuccessByLearner] = useState<
    Record<string, string>
  >({});
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
            .select('learner_id')
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
        const mod = unwrapOne(row.elearning_modules);
        const item: AssignmentRow = {
          id: row.id,
          module_id: row.module_id,
          module_title:
            typeof mod?.title === 'string' && mod.title.trim()
              ? mod.title.trim()
              : 'Module',
          start_date: row.start_date,
          end_date: row.end_date,
        };
        const list = assignmentsByLearner.get(row.learner_id) ?? [];
        list.push(item);
        assignmentsByLearner.set(row.learner_id, list);
      });

      const learnerIds = new Set<string>();
      (links ?? []).forEach((link: { learner_id: string }) => {
        if (link.learner_id) learnerIds.add(link.learner_id);
      });
      assignmentsByLearner.forEach((_, learnerId) => {
        learnerIds.add(learnerId);
      });

      const learnerIdList = Array.from(learnerIds);
      const identityByLearner = new Map<
        string,
        { full_name: string; email: string }
      >();

      if (learnerIdList.length > 0) {
        // Authoritative: SECURITY DEFINER join learners.profile_id → profiles.full_name
        // (avoids nested RLS that silently nulls PostgREST embeds)
        const { data: rpcRows, error: rpcErr } = await supabase.rpc(
          'teacher_learner_identities',
          { p_learner_ids: learnerIdList }
        );
        if (rpcErr) {
          console.error('teacher_learner_identities failed:', rpcErr);
        }
        ((rpcRows as { learner_id: string; full_name: string; email: string }[]) ??
          []).forEach((row) => {
          const name = row.full_name?.trim() || '';
          const email = row.email?.trim() || '';
          if (!name && !email) return;
          identityByLearner.set(row.learner_id, { full_name: name, email });
        });

        // Also select via PostgREST embed (same join) for any ids the RPC missed
        const missingIds = learnerIdList.filter(
          (id) => !identityByLearner.get(id)?.full_name
        );
        if (missingIds.length > 0) {
          const { data: learnerRows, error: learnerErr } = await supabase
            .from('learners')
            .select(
              `
              id,
              profile_id,
              profiles (
                full_name,
                email
              )
            `
            )
            .in('id', missingIds);

          if (learnerErr) {
            console.error('learners/profiles join failed:', learnerErr);
          }

          (learnerRows ?? []).forEach((row: any) => {
            const fromJoin = profileFromLearner(row);
            if (fromJoin.full_name || fromJoin.email) {
              identityByLearner.set(row.id, fromJoin);
            }
          });
        }
      }

      const learnerMap = new Map<string, LearnerRow>();
      learnerIdList.forEach((learnerId) => {
        const identity = identityByLearner.get(learnerId);
        const fullName = identity?.full_name?.trim() || '';
        learnerMap.set(learnerId, {
          id: learnerId,
          full_name: fullName || 'Apprenant',
          email: identity?.email || '',
          assignments: assignmentsByLearner.get(learnerId) ?? [],
          selectedModuleId: '',
          examScores: [],
          scoreForm: { ...EMPTY_SCORE_FORM },
        });
      });

      const scoresByLearner = new Map<string, ElearningLevelExamScore[]>();
      if (learnerIdList.length > 0) {
        const { data: scoreRows } = await supabase
          .from('elearning_level_exam_scores')
          .select(
            'id, learner_id, teacher_id, level, score_po, score_pe, score_co, score_ce, score_langue, total_score, created_at, updated_at'
          )
          .in('learner_id', learnerIdList)
          .order('level', { ascending: true });
        ((scoreRows as ElearningLevelExamScore[]) ?? []).forEach((row) => {
          const list = scoresByLearner.get(row.learner_id) ?? [];
          list.push(row);
          scoresByLearner.set(row.learner_id, list);
        });
      }

      scoresByLearner.forEach((scores, learnerId) => {
        const existing = learnerMap.get(learnerId);
        if (!existing) return;
        learnerMap.set(learnerId, {
          ...existing,
          examScores: sortExamScores(scores),
        });
      });

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

  function setScoreField(
    learnerId: string,
    field: keyof ScoreForm,
    value: string
  ) {
    setLearners((prev) =>
      prev.map((l) => {
        if (l.id !== learnerId) return l;
        if (field === 'level') {
          const level = value as CefrLevel | '';
          const existing = level
            ? l.examScores.find((s) => s.level === level)
            : undefined;
          return { ...l, scoreForm: scoreToForm(existing, level) };
        }
        return {
          ...l,
          scoreForm: { ...l.scoreForm, [field]: value },
        };
      })
    );
    setSuccessByLearner((prev) => {
      const next = { ...prev };
      delete next[learnerId];
      return next;
    });
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

  async function saveExamScores(learner: LearnerRow) {
    if (!teacherId || !learner.scoreForm.level) return;

    setBusyKey(`scores-${learner.id}`);
    setInfoByLearner((prev) => {
      const next = { ...prev };
      delete next[learner.id];
      return next;
    });
    setSuccessByLearner((prev) => {
      const next = { ...prev };
      delete next[learner.id];
      return next;
    });

    try {
      const level = learner.scoreForm.level;
      const payload = {
        learner_id: learner.id,
        teacher_id: teacherId,
        level,
        score_po: parseScore(learner.scoreForm.score_po),
        score_pe: parseScore(learner.scoreForm.score_pe),
        score_co: parseScore(learner.scoreForm.score_co),
        score_ce: parseScore(learner.scoreForm.score_ce),
        score_langue: parseScore(learner.scoreForm.score_langue),
        updated_at: new Date().toISOString(),
      };

      const { data, error: upsertErr } = await supabase
        .from('elearning_level_exam_scores')
        .upsert(payload, { onConflict: 'learner_id,level' })
        .select(
          'id, learner_id, teacher_id, level, score_po, score_pe, score_co, score_ce, score_langue, total_score, created_at, updated_at'
        )
        .maybeSingle();

      if (upsertErr) throw upsertErr;
      if (!data) {
        throw new Error('Enregistrement impossible — aucune donnée retournée.');
      }

      const saved = data as ElearningLevelExamScore;
      setLearners((prev) =>
        prev.map((l) => {
          if (l.id !== learner.id) return l;
          const without = l.examScores.filter((s) => s.level !== saved.level);
          return {
            ...l,
            examScores: sortExamScores([...without, saved]),
            scoreForm: scoreToForm(saved, saved.level),
          };
        })
      );
      setSuccessByLearner((prev) => ({
        ...prev,
        [learner.id]: `Notes ${saved.level} enregistrées — total ${(saved.total_score ?? 0).toFixed(1)}/100`,
      }));
    } catch (err) {
      console.error(err);
      setInfoByLearner((prev) => ({
        ...prev,
        [learner.id]:
          err instanceof Error
            ? err.message
            : 'Impossible d’enregistrer les notes',
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
          Assignez vos modules eLearning et saisissez les notes d’examen papier
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
          {modules.length === 0 && (
            <div className="flex items-center gap-2 rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-800">
              <BookOpen className="w-4 h-4 shrink-0" />
              Aucun module eLearning — vous pouvez tout de même saisir les notes
              d’examen papier.
            </div>
          )}
          {learners.map((learner) => {
            const available = availableModulesFor(learner);
            const formTotal = calcFormTotal(learner.scoreForm);
            const selectedScore = learner.scoreForm.level
              ? learner.examScores.find(
                  (s) => s.level === learner.scoreForm.level
                )
              : undefined;
            const savingScores = busyKey === `scores-${learner.id}`;

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
                        <p className="text-xs text-gray-400 mt-1">
                          {learner.email}
                        </p>
                      )}
                    </div>
                    <div className="flex flex-wrap gap-1.5 justify-end">
                      <Badge variant="secondary">
                        {learner.assignments.length} module
                        {learner.assignments.length !== 1 ? 's' : ''}
                      </Badge>
                      {learner.examScores.length > 0 && (
                        <Badge className="bg-[#E6F5EE] text-[#00A550] hover:bg-[#E6F5EE]">
                          {learner.examScores.length} niveau
                          {learner.examScores.length !== 1 ? 'x' : ''} noté
                          {learner.examScores.length !== 1 ? 's' : ''}
                        </Badge>
                      )}
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="space-y-5">
                  {/* Module assignments — always separate from the learner title */}
                  <div className="space-y-3">
                    <p className="text-xs font-semibold uppercase tracking-wide text-gray-500">
                      Modules assignés
                    </p>
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

                    {modules.length > 0 && (
                      <div className="flex flex-col sm:flex-row gap-2 sm:items-end">
                        <div className="flex-1 space-y-1.5">
                          <Label>Assigner un module</Label>
                          <Select
                            value={learner.selectedModuleId || undefined}
                            onValueChange={(v) =>
                              setSelectedModule(learner.id, v)
                            }
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
                    )}
                  </div>

                  {/* Paper exam scores */}
                  <div className="border-t border-gray-100 pt-4 space-y-3">
                    <div className="flex items-center gap-2">
                      <div className="w-7 h-7 rounded-lg bg-[#E6F5EE] flex items-center justify-center">
                        <ClipboardList className="w-3.5 h-3.5 text-[#00A550]" />
                      </div>
                      <div>
                        <p className="text-sm font-semibold text-gray-900">
                          Notes d’examen papier
                        </p>
                        <p className="text-xs text-gray-400">
                          5 compétences sur 20 — total sur 100
                        </p>
                      </div>
                    </div>

                    {learner.examScores.length > 0 && (
                      <div className="flex flex-wrap gap-2">
                        {learner.examScores.map((s) => (
                          <button
                            key={s.id}
                            type="button"
                            onClick={() =>
                              setScoreField(learner.id, 'level', s.level)
                            }
                            className={`inline-flex items-center gap-1.5 rounded-md border px-2.5 py-1 text-xs transition-colors ${
                              learner.scoreForm.level === s.level
                                ? 'border-[#00A550] bg-[#E6F5EE]'
                                : 'border-gray-200 bg-white hover:border-gray-300'
                            }`}
                          >
                            <span
                              className={`font-bold px-1.5 py-0.5 rounded ${CEFR_COLORS[s.level]}`}
                            >
                              {s.level}
                            </span>
                            <span className="font-semibold text-gray-800">
                              {(s.total_score ?? 0).toFixed(1)}
                            </span>
                            <span className="text-gray-400">/100</span>
                          </button>
                        ))}
                      </div>
                    )}

                    <div className="space-y-3 rounded-lg border border-gray-100 bg-gray-50/60 p-3">
                      <div className="space-y-1.5 max-w-xs">
                        <Label>
                          Niveau <span className="text-red-500">*</span>
                        </Label>
                        <Select
                          value={learner.scoreForm.level || undefined}
                          onValueChange={(v) =>
                            setScoreField(learner.id, 'level', v)
                          }
                        >
                          <SelectTrigger className="bg-white border-gray-200">
                            <SelectValue placeholder="Choisir un niveau…" />
                          </SelectTrigger>
                          <SelectContent>
                            {CEFR_LEVELS.map((lvl) => {
                              const existing = learner.examScores.find(
                                (s) => s.level === lvl
                              );
                              return (
                                <SelectItem key={lvl} value={lvl}>
                                  {lvl}
                                  {existing
                                    ? ` — ${(existing.total_score ?? 0).toFixed(1)}/100`
                                    : ''}
                                </SelectItem>
                              );
                            })}
                          </SelectContent>
                        </Select>
                      </div>

                      <div>
                        <p className="text-xs font-medium text-gray-600 mb-2">
                          Notes par compétence (0–20)
                        </p>
                        <div className="grid grid-cols-5 gap-2">
                          {EXAM_COMPS.map((c) => (
                            <div key={c.key} className="space-y-1">
                              <Label
                                className="text-xs font-semibold text-gray-600 text-center block"
                                title={c.title}
                              >
                                {c.label}
                              </Label>
                              <Input
                                type="number"
                                min={0}
                                max={20}
                                step={0.5}
                                placeholder="0"
                                disabled={!learner.scoreForm.level}
                                value={learner.scoreForm[c.key]}
                                onChange={(e) =>
                                  setScoreField(
                                    learner.id,
                                    c.key,
                                    e.target.value
                                  )
                                }
                                className="text-center px-1 bg-white border-gray-200 focus:border-[#00A550]"
                              />
                            </div>
                          ))}
                        </div>
                        <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-200/80">
                          <span className="text-sm text-gray-600">Total</span>
                          <div className="flex items-center gap-2">
                            <span className="text-lg font-bold text-gray-900">
                              {formTotal.toFixed(1)}
                              <span className="text-sm font-normal text-gray-400">
                                /100
                              </span>
                            </span>
                            {selectedScore && (
                              <span className="text-xs text-gray-400">
                                enregistré :{' '}
                                {(selectedScore.total_score ?? 0).toFixed(1)}
                                /100
                              </span>
                            )}
                          </div>
                        </div>
                      </div>

                      <Button
                        className="w-full sm:w-auto bg-[#00A550] hover:bg-[#008040] text-white"
                        disabled={!learner.scoreForm.level || savingScores}
                        onClick={() => void saveExamScores(learner)}
                      >
                        <Save className="w-3.5 h-3.5 mr-1.5" />
                        {savingScores
                          ? 'Enregistrement…'
                          : selectedScore
                            ? 'Mettre à jour les notes'
                            : 'Enregistrer les notes'}
                      </Button>
                    </div>
                  </div>

                  {successByLearner[learner.id] && (
                    <p className="text-sm text-[#008040] bg-[#E6F5EE] border border-[#00A550]/30 rounded-md px-3 py-2">
                      {successByLearner[learner.id]}
                    </p>
                  )}
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
