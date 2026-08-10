'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useParams, useRouter, useSearchParams } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  AlertTriangle,
  ArrowLeft,
  CheckCircle2,
  ChevronRight,
  Loader2,
  Mic,
  X,
} from 'lucide-react';

interface SessionInfo {
  id: string;
  titre: string;
  statut: string;
}

interface EvaluationRow {
  id: string;
  student_id: string;
  student_name: string;
  evaluated_at: string | null;
  created_at: string;
}

interface LearnerOption {
  profileId: string;
  fullName: string;
}

function formatDate(iso: string | null): string {
  if (!iso) return '—';
  try {
    return new Date(iso).toLocaleString('fr-FR', {
      dateStyle: 'medium',
      timeStyle: 'short',
    });
  } catch {
    return iso;
  }
}

export default function TcfEoEvaluationsListPage() {
  const params = useParams();
  const router = useRouter();
  const searchParams = useSearchParams();
  const sessionId = params.sessionId as string;
  const supabase = useMemo(() => createClient(), []);

  const [session, setSession] = useState<SessionInfo | null>(null);
  const [evaluations, setEvaluations] = useState<EvaluationRow[]>([]);
  const [learners, setLearners] = useState<LearnerOption[]>([]);
  const [selectedProfileId, setSelectedProfileId] = useState('');
  const [loading, setLoading] = useState(true);
  const [creating, setCreating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successBanner, setSuccessBanner] = useState(
    searchParams.get('published') === '1'
  );

  const loadData = useCallback(async () => {
    try {
      setError(null);

      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) {
        setError('Session expirée. Reconnectez-vous.');
        return;
      }

      const { data: sessionData, error: sessionError } = await supabase
        .from('tcf_eo_sessions')
        .select('id, titre, statut')
        .eq('id', sessionId)
        .maybeSingle();

      if (sessionError) throw sessionError;
      if (!sessionData) {
        setError('Séance introuvable.');
        setSession(null);
        setEvaluations([]);
        return;
      }
      setSession(sessionData as SessionInfo);

      const { data: evaluationsData, error: evaluationsError } = await supabase
        .from('student_eo_evaluations')
        .select('id, student_id, evaluated_at, created_at')
        .eq('session_id', sessionId)
        .order('created_at', { ascending: false });

      if (evaluationsError) throw evaluationsError;

      const rows = (evaluationsData ?? []) as Array<{
        id: string;
        student_id: string;
        evaluated_at: string | null;
        created_at: string;
      }>;

      const studentIds = Array.from(new Set(rows.map((r) => r.student_id)));
      const nameById = new Map<string, string>();

      if (studentIds.length > 0) {
        const { data: profiles } = await supabase
          .from('profiles')
          .select('id, full_name')
          .in('id', studentIds);

        for (const p of profiles ?? []) {
          const name = (p.full_name as string | null)?.trim();
          if (name) nameById.set(p.id as string, name);
        }
      }

      setEvaluations(
        rows.map((r) => ({
          id: r.id,
          student_id: r.student_id,
          student_name: nameById.get(r.student_id) || 'Apprenant',
          evaluated_at: r.evaluated_at,
          created_at: r.created_at,
        }))
      );

      // Apprenants liés au préparateur (pour en évaluer de nouveaux)
      const { data: teacher } = await supabase
        .from('teachers')
        .select('id')
        .eq('profile_id', user.id)
        .maybeSingle();

      const learnerOptions: LearnerOption[] = [];
      if (teacher) {
        const [{ data: links }, { data: assignments }] = await Promise.all([
          supabase
            .from('learner_teacher_links')
            .select('learner_id')
            .eq('teacher_id', teacher.id),
          supabase
            .from('elearning_module_assignments')
            .select('learner_id')
            .eq('teacher_id', teacher.id),
        ]);

        const learnerIdSet = new Set<string>();
        for (const link of links ?? []) {
          if (link.learner_id) learnerIdSet.add(link.learner_id as string);
        }
        for (const row of assignments ?? []) {
          if (row.learner_id) learnerIdSet.add(row.learner_id as string);
        }

        const learnerIds = Array.from(learnerIdSet);
        if (learnerIds.length > 0) {
          const { data: rpcRows } = await supabase.rpc(
            'teacher_learner_identities',
            { p_learner_ids: learnerIds }
          );

          const nameByLearnerId = new Map<string, string>();
          for (const row of (rpcRows as Array<{
            learner_id: string;
            full_name: string;
          }>) ?? []) {
            const name = row.full_name?.trim();
            if (name) nameByLearnerId.set(row.learner_id, name);
          }

          const { data: learnerRows } = await supabase
            .from('learners')
            .select('id, profile_id')
            .in('id', learnerIds);

          for (const learner of learnerRows ?? []) {
            const profileId = learner.profile_id as string | null;
            if (!profileId) continue;
            learnerOptions.push({
              profileId,
              fullName:
                nameByLearnerId.get(learner.id as string) || 'Apprenant',
            });
          }
        }
      }

      learnerOptions.sort((a, b) =>
        a.fullName.localeCompare(b.fullName, 'fr')
      );
      setLearners(learnerOptions);
    } catch (err) {
      console.error(err);
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible de charger les évaluations.'
      );
    } finally {
      setLoading(false);
    }
  }, [sessionId, supabase]);

  useEffect(() => {
    if (sessionId) void loadData();
  }, [sessionId, loadData]);

  const evaluatedProfileIds = useMemo(
    () => new Set(evaluations.map((e) => e.student_id)),
    [evaluations]
  );

  const availableLearners = useMemo(
    () => learners.filter((l) => !evaluatedProfileIds.has(l.profileId)),
    [learners, evaluatedProfileIds]
  );

  async function handleCreateEvaluation() {
    if (!selectedProfileId) return;
    setCreating(true);
    setError(null);
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) {
        setError('Session expirée. Reconnectez-vous.');
        return;
      }

      const existing = evaluations.find(
        (e) => e.student_id === selectedProfileId
      );
      if (existing) {
        router.push(
          `/dashboard/teacher/preparation/tcf-eo/evaluations/${existing.id}`
        );
        return;
      }

      const { data, error: insertError } = await supabase
        .from('student_eo_evaluations')
        .insert({
          session_id: sessionId,
          student_id: selectedProfileId,
          evaluated_by: user.id,
        })
        .select('id')
        .single();

      if (insertError) throw insertError;
      if (!data?.id) throw new Error('Évaluation introuvable après création.');

      router.push(
        `/dashboard/teacher/preparation/tcf-eo/evaluations/${data.id}`
      );
    } catch (err) {
      console.error(err);
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible de créer l’évaluation.'
      );
    } finally {
      setCreating(false);
    }
  }

  const draftCount = evaluations.filter((e) => !e.evaluated_at).length;
  const publishedCount = evaluations.filter((e) => e.evaluated_at).length;

  return (
    <div className="p-6 space-y-6 max-w-4xl mx-auto">
      <div>
        <Link
          href={`/dashboard/teacher/preparation/tcf-eo/${sessionId}/sujets`}
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour aux sujets
        </Link>
        {loading ? (
          <div className="space-y-2">
            <Skeleton className="h-8 w-72" />
            <Skeleton className="h-4 w-48" />
          </div>
        ) : (
          <>
            <div className="flex items-center gap-2 flex-wrap">
              <h1 className="text-2xl font-bold text-gray-900">
                Évaluations EO
              </h1>
              <Badge
                variant="outline"
                className="bg-violet-100 text-violet-800 border-violet-200"
              >
                EO
              </Badge>
            </div>
            <p className="text-sm text-gray-500 mt-1">
              {session?.titre ?? 'Séance'}
              {evaluations.length > 0
                ? ` · ${draftCount} brouillon${draftCount === 1 ? '' : 's'} · ${publishedCount} publiée${publishedCount === 1 ? '' : 's'}`
                : ''}
            </p>
          </>
        )}
      </div>

      {successBanner && (
        <div className="flex items-center gap-2 rounded-lg bg-flehub-green-light border border-flehub-green/30 px-4 py-3 text-sm text-flehub-green">
          <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
          <span className="flex-1">
            Évaluation publiée. L’apprenant peut maintenant la consulter.
          </span>
          <button type="button" onClick={() => setSuccessBanner(false)}>
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {error}
        </div>
      )}

      {!loading && (
        <Card>
          <CardContent className="p-5 space-y-3">
            <div>
              <h2 className="text-base font-semibold text-gray-900">
                Évaluer un nouvel apprenant
              </h2>
              <p className="text-sm text-gray-500 mt-0.5">
                Après le passage en visioconférence, créez la grille de notation
                pour un apprenant inscrit.
              </p>
            </div>
            <div className="flex flex-col sm:flex-row gap-3 sm:items-end">
              <div className="flex-1 space-y-2">
                <Label>Apprenant</Label>
                <Select
                  value={selectedProfileId}
                  onValueChange={setSelectedProfileId}
                  disabled={creating || availableLearners.length === 0}
                >
                  <SelectTrigger className="bg-white">
                    <SelectValue
                      placeholder={
                        availableLearners.length === 0
                          ? 'Aucun apprenant disponible'
                          : 'Choisir un apprenant'
                      }
                    />
                  </SelectTrigger>
                  <SelectContent>
                    {availableLearners.map((learner) => (
                      <SelectItem
                        key={learner.profileId}
                        value={learner.profileId}
                      >
                        {learner.fullName}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <Button
                type="button"
                className="bg-violet-700 hover:bg-violet-800 text-white shrink-0"
                disabled={!selectedProfileId || creating}
                onClick={() => void handleCreateEvaluation()}
              >
                {creating ? (
                  <>
                    <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
                    Création…
                  </>
                ) : (
                  'Évaluer cet apprenant'
                )}
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Skeleton key={i} className="h-20 rounded-xl" />
          ))}
        </div>
      ) : evaluations.length === 0 ? (
        <Card className="border-dashed">
          <CardContent className="flex flex-col items-center justify-center py-16 text-center">
            <div className="p-3 rounded-lg bg-violet-50 mb-4">
              <Mic className="w-6 h-6 text-violet-700" />
            </div>
            <h2 className="text-lg font-semibold text-gray-900">
              Aucune évaluation pour le moment
            </h2>
            <p className="text-sm text-gray-500 mt-1 max-w-sm">
              Sélectionnez un apprenant ci-dessus pour démarrer une notation
              après le rendez-vous en visio.
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-3">
          {evaluations.map((evaluation) => {
            const isPublished = Boolean(evaluation.evaluated_at);
            return (
              <Link
                key={evaluation.id}
                href={`/dashboard/teacher/preparation/tcf-eo/evaluations/${evaluation.id}`}
                className="block"
              >
                <Card className="card-hover">
                  <CardContent className="p-4 sm:p-5 flex items-center gap-3 sm:gap-4">
                    <div className="p-2 rounded-lg bg-violet-50 shrink-0">
                      <Mic className="w-4 h-4 text-violet-700" />
                    </div>
                    <div className="min-w-0 flex-1 space-y-1">
                      <div className="flex items-center gap-2 flex-wrap">
                        <h3 className="font-semibold text-gray-900 truncate">
                          {evaluation.student_name}
                        </h3>
                        <Badge
                          variant="outline"
                          className={
                            isPublished
                              ? 'bg-flehub-green-light text-flehub-green border-flehub-green'
                              : 'bg-gray-100 text-gray-600 border-gray-300'
                          }
                        >
                          {isPublished ? 'Publiée' : 'Brouillon'}
                        </Badge>
                      </div>
                      <p className="text-xs text-gray-500">
                        {isPublished
                          ? `Publiée le ${formatDate(evaluation.evaluated_at)}`
                          : `Créée le ${formatDate(evaluation.created_at)}`}
                      </p>
                    </div>
                    <ChevronRight className="w-5 h-5 text-gray-400 shrink-0" />
                  </CardContent>
                </Card>
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}
