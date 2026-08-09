'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useParams, useSearchParams } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  AlertTriangle,
  ArrowLeft,
  CheckCircle2,
  ChevronRight,
  Clock,
  EyeOff,
  PenLine,
  X,
} from 'lucide-react';

type AttemptStatut = 'a_corriger' | 'corrige';

interface AttemptRow {
  id: string;
  student_id: string;
  student_name: string;
  statut: AttemptStatut;
  nb_sorties_onglet: number;
  completed_at: string | null;
}

interface SessionInfo {
  id: string;
  titre: string;
  statut: string;
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

export default function TcfEeCorrectionsListPage() {
  const params = useParams();
  const searchParams = useSearchParams();
  const sessionId = params.sessionId as string;
  const supabase = useMemo(() => createClient(), []);

  const [session, setSession] = useState<SessionInfo | null>(null);
  const [attempts, setAttempts] = useState<AttemptRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [successBanner, setSuccessBanner] = useState(
    searchParams.get('published') === '1'
  );

  const loadData = useCallback(async () => {
    try {
      setError(null);
      const { data: sessionData, error: sessionError } = await supabase
        .from('tcf_ee_sessions')
        .select('id, titre, statut')
        .eq('id', sessionId)
        .maybeSingle();

      if (sessionError) throw sessionError;
      if (!sessionData) {
        setError('Séance introuvable.');
        setSession(null);
        setAttempts([]);
        return;
      }
      setSession(sessionData as SessionInfo);

      const { data: attemptsData, error: attemptsError } = await supabase
        .from('student_ee_attempts')
        .select(
          'id, student_id, statut, nb_sorties_onglet, completed_at, started_at'
        )
        .eq('session_id', sessionId)
        .in('statut', ['a_corriger', 'corrige'])
        .order('completed_at', { ascending: false });

      if (attemptsError) throw attemptsError;

      const rows = (attemptsData ?? []) as Array<{
        id: string;
        student_id: string;
        statut: AttemptStatut;
        nb_sorties_onglet: number;
        completed_at: string | null;
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
          if (name) nameById.set(p.id, name);
        }
      }

      setAttempts(
        rows.map((r) => ({
          id: r.id,
          student_id: r.student_id,
          student_name: nameById.get(r.student_id) || 'Apprenant',
          statut: r.statut,
          nb_sorties_onglet: r.nb_sorties_onglet ?? 0,
          completed_at: r.completed_at,
        }))
      );
    } catch (err) {
      console.error(err);
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible de charger les copies.'
      );
    } finally {
      setLoading(false);
    }
  }, [sessionId, supabase]);

  useEffect(() => {
    if (sessionId) void loadData();
  }, [sessionId, loadData]);

  const pendingCount = attempts.filter((a) => a.statut === 'a_corriger').length;

  return (
    <div className="p-6 space-y-6 max-w-4xl mx-auto">
      <div>
        <Link
          href={`/dashboard/teacher/preparation/tcf-ee/${sessionId}/taches`}
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour aux tâches
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
                Copies à corriger
              </h1>
              <Badge
                variant="outline"
                className="bg-blue-100 text-blue-800 border-blue-200"
              >
                EE
              </Badge>
            </div>
            <p className="text-sm text-gray-500 mt-1">
              {session?.titre ?? 'Séance'}
              {attempts.length > 0
                ? ` · ${pendingCount} à corriger / ${attempts.length} reçue${attempts.length > 1 ? 's' : ''}`
                : ''}
            </p>
          </>
        )}
      </div>

      {successBanner && (
        <div className="flex items-center gap-2 rounded-lg bg-flehub-green-light border border-flehub-green/30 px-4 py-3 text-sm text-flehub-green">
          <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
          <span className="flex-1">
            Correction publiée. L’apprenant peut maintenant la consulter.
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

      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Skeleton key={i} className="h-20 rounded-xl" />
          ))}
        </div>
      ) : attempts.length === 0 ? (
        <Card className="border-dashed">
          <CardContent className="flex flex-col items-center justify-center py-16 text-center">
            <div className="p-3 rounded-lg bg-blue-50 mb-4">
              <PenLine className="w-6 h-6 text-blue-700" />
            </div>
            <h2 className="text-lg font-semibold text-gray-900">
              Aucune copie pour le moment
            </h2>
            <p className="text-sm text-gray-500 mt-1 max-w-sm">
              Les copies apparaîtront ici dès qu’un apprenant aura terminé et
              envoyé sa séance.
            </p>
            <Button asChild variant="outline" className="mt-6">
              <Link href="/dashboard/teacher/preparation">
                Retour à Préparation
              </Link>
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-3">
          {attempts.map((attempt) => {
            const isDone = attempt.statut === 'corrige';
            return (
              <Link
                key={attempt.id}
                href={`/dashboard/teacher/preparation/tcf-ee/corrections/${attempt.id}`}
                className="block"
              >
                <Card className="card-hover">
                  <CardContent className="p-4 sm:p-5 flex items-center gap-3 sm:gap-4">
                    <div className="p-2 rounded-lg bg-blue-50 shrink-0">
                      <PenLine className="w-4 h-4 text-blue-700" />
                    </div>
                    <div className="min-w-0 flex-1 space-y-1">
                      <div className="flex items-center gap-2 flex-wrap">
                        <h3 className="font-semibold text-gray-900 truncate">
                          {attempt.student_name}
                        </h3>
                        <Badge
                          variant="outline"
                          className={
                            isDone
                              ? 'bg-flehub-green-light text-flehub-green border-flehub-green'
                              : 'bg-orange-50 text-orange-700 border-orange-200'
                          }
                        >
                          {isDone ? 'Corrigé' : 'À corriger'}
                        </Badge>
                      </div>
                      <div className="flex items-center gap-3 flex-wrap text-xs text-gray-500">
                        <span className="inline-flex items-center gap-1">
                          <Clock className="w-3.5 h-3.5" />
                          Envoyée le {formatDate(attempt.completed_at)}
                        </span>
                        <span className="inline-flex items-center gap-1">
                          <EyeOff className="w-3.5 h-3.5" />
                          {attempt.nb_sorties_onglet} sortie
                          {attempt.nb_sorties_onglet === 1 ? '' : 's'}{' '}
                          d’onglet
                        </span>
                      </div>
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
