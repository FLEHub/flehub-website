'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  BookOpen,
  BookOpenText,
  ChevronRight,
  Clock,
  Headphones,
  Mic,
  PenLine,
  Plus,
} from 'lucide-react';

type SessionStatut = 'brouillon' | 'publiee';
type SessionKind = 'co' | 'ce' | 'ee' | 'eo';

interface PrepSession {
  id: string;
  kind: SessionKind;
  titre: string;
  duree_minuteur: number | null;
  statut: SessionStatut;
  created_at: string;
}

const statutConfig: Record<SessionStatut, { label: string; badgeClass: string }> = {
  brouillon: {
    label: 'Brouillon',
    badgeClass: 'bg-gray-100 text-gray-600 border-gray-300',
  },
  publiee: {
    label: 'Publiée',
    badgeClass: 'bg-flehub-green-light text-flehub-green border-flehub-green',
  },
};

const kindConfig: Record<
  SessionKind,
  {
    label: string;
    fullLabel: string;
    badgeClass: string;
    iconWrapClass: string;
    iconClass: string;
    manageLabel: string;
    Icon: typeof Headphones;
    manageHref: (id: string) => string;
  }
> = {
  co: {
    label: 'CO',
    fullLabel: 'Compréhension orale',
    badgeClass: 'bg-sky-100 text-sky-700 border-sky-200',
    iconWrapClass: 'bg-flehub-green-light',
    iconClass: 'text-flehub-green',
    manageLabel: 'Gérer les questions',
    Icon: Headphones,
    manageHref: (id) =>
      `/dashboard/teacher/preparation/tcf-co/${id}/questions`,
  },
  ce: {
    label: 'CE',
    fullLabel: 'Compréhension écrite',
    badgeClass: 'bg-amber-100 text-amber-800 border-amber-200',
    iconWrapClass: 'bg-amber-50',
    iconClass: 'text-amber-700',
    manageLabel: 'Gérer les questions',
    Icon: BookOpenText,
    manageHref: (id) =>
      `/dashboard/teacher/preparation/tcf-ce/${id}/questions`,
  },
  ee: {
    label: 'EE',
    fullLabel: 'Expression écrite',
    badgeClass: 'bg-blue-100 text-blue-800 border-blue-200',
    iconWrapClass: 'bg-blue-50',
    iconClass: 'text-blue-700',
    manageLabel: 'Gérer les tâches',
    Icon: PenLine,
    manageHref: (id) =>
      `/dashboard/teacher/preparation/tcf-ee/${id}/taches`,
  },
  eo: {
    label: 'EO',
    fullLabel: 'Expression orale',
    badgeClass: 'bg-violet-100 text-violet-800 border-violet-200',
    iconWrapClass: 'bg-violet-50',
    iconClass: 'text-violet-700',
    manageLabel: 'Gérer les sujets',
    Icon: Mic,
    manageHref: (id) =>
      `/dashboard/teacher/preparation/tcf-eo/${id}/sujets`,
  },
};

export default function TeacherPreparationPage() {
  const supabase = createClient();
  const [sessions, setSessions] = useState<PrepSession[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return;

      const [coRes, ceRes, eeRes, eoRes] = await Promise.all([
        supabase
          .from('tcf_co_sessions')
          .select('id, titre, duree_minuteur, statut, created_at')
          .eq('created_by', user.id),
        supabase
          .from('tcf_ce_sessions')
          .select('id, titre, duree_minuteur, statut, created_at')
          .eq('created_by', user.id),
        supabase
          .from('tcf_ee_sessions')
          .select('id, titre, duree_minuteur, statut, created_at')
          .eq('created_by', user.id),
        supabase
          .from('tcf_eo_sessions')
          .select('id, titre, statut, created_at')
          .eq('created_by', user.id),
      ]);

      const coSessions: PrepSession[] = (coRes.data ?? []).map((s) => ({
        ...(s as Omit<PrepSession, 'kind' | 'duree_minuteur'>),
        duree_minuteur: s.duree_minuteur as number,
        kind: 'co' as const,
      }));
      const ceSessions: PrepSession[] = (ceRes.data ?? []).map((s) => ({
        ...(s as Omit<PrepSession, 'kind' | 'duree_minuteur'>),
        duree_minuteur: s.duree_minuteur as number,
        kind: 'ce' as const,
      }));
      const eeSessions: PrepSession[] = (eeRes.data ?? []).map((s) => ({
        ...(s as Omit<PrepSession, 'kind' | 'duree_minuteur'>),
        duree_minuteur: s.duree_minuteur as number,
        kind: 'ee' as const,
      }));
      const eoSessions: PrepSession[] = (eoRes.data ?? []).map((s) => ({
        id: s.id as string,
        titre: s.titre as string,
        statut: s.statut as SessionStatut,
        created_at: s.created_at as string,
        duree_minuteur: null,
        kind: 'eo' as const,
      }));

      const merged = [
        ...coSessions,
        ...ceSessions,
        ...eeSessions,
        ...eoSessions,
      ].sort(
        (a, b) =>
          new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
      );
      setSessions(merged);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Préparation</h1>
          <p className="text-gray-500 text-sm mt-1">
            Révision (grammaire / vocabulaire) et séances TCF (CO, CE, EE, EO)
          </p>
        </div>
        <div className="flex flex-col sm:flex-row sm:flex-wrap gap-2">
          <Button
            asChild
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
          >
            <Link href="/dashboard/teacher/preparation/revision">
              <BookOpen className="w-4 h-4 mr-1.5" />
              Module Révision
            </Link>
          </Button>
          <Button
            asChild
            variant="outline"
            className="border-flehub-green text-flehub-green hover:bg-flehub-green-light"
          >
            <Link href="/dashboard/teacher/preparation/tcf-co/new">
              <Plus className="w-4 h-4 mr-1.5" />
              Nouvelle séance TCF CO
            </Link>
          </Button>
          <Button
            asChild
            variant="outline"
            className="border-amber-300 text-amber-800 hover:bg-amber-50"
          >
            <Link href="/dashboard/teacher/preparation/tcf-ce/new">
              <Plus className="w-4 h-4 mr-1.5" />
              Nouvelle séance TCF CE
            </Link>
          </Button>
          <Button
            asChild
            variant="outline"
            className="border-blue-300 text-blue-800 hover:bg-blue-50"
          >
            <Link href="/dashboard/teacher/preparation/tcf-ee/new">
              <Plus className="w-4 h-4 mr-1.5" />
              Nouvelle séance TCF EE
            </Link>
          </Button>
          <Button
            asChild
            variant="outline"
            className="border-violet-300 text-violet-800 hover:bg-violet-50"
          >
            <Link href="/dashboard/teacher/preparation/tcf-eo/new">
              <Plus className="w-4 h-4 mr-1.5" />
              Nouvelle séance TCF EO
            </Link>
          </Button>
        </div>
      </div>

      {loading ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Skeleton key={i} className="h-36 rounded-xl" />
          ))}
        </div>
      ) : sessions.length === 0 ? (
        <Card className="border-dashed">
          <CardContent className="flex flex-col items-center justify-center py-16 text-center">
            <div className="flex items-center gap-2 mb-4 flex-wrap justify-center">
              <div className="p-3 rounded-lg bg-flehub-green-light">
                <Headphones className="w-6 h-6 text-flehub-green" />
              </div>
              <div className="p-3 rounded-lg bg-amber-50">
                <BookOpenText className="w-6 h-6 text-amber-700" />
              </div>
              <div className="p-3 rounded-lg bg-blue-50">
                <PenLine className="w-6 h-6 text-blue-700" />
              </div>
              <div className="p-3 rounded-lg bg-violet-50">
                <Mic className="w-6 h-6 text-violet-700" />
              </div>
            </div>
            <h2 className="text-lg font-semibold text-gray-900">
              Aucune séance TCF
            </h2>
            <p className="text-sm text-gray-500 mt-1 max-w-sm">
              Créez une séance CO, CE, EE ou EO pour préparer vos apprenants.
            </p>
            <div className="mt-6 flex flex-col sm:flex-row sm:flex-wrap gap-2 justify-center">
              <Button
                asChild
                className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              >
                <Link href="/dashboard/teacher/preparation/tcf-co/new">
                  <Plus className="w-4 h-4 mr-1.5" />
                  Séance TCF CO
                </Link>
              </Button>
              <Button
                asChild
                variant="outline"
                className="border-amber-300 text-amber-800 hover:bg-amber-50"
              >
                <Link href="/dashboard/teacher/preparation/tcf-ce/new">
                  <Plus className="w-4 h-4 mr-1.5" />
                  Séance TCF CE
                </Link>
              </Button>
              <Button
                asChild
                variant="outline"
                className="border-blue-300 text-blue-800 hover:bg-blue-50"
              >
                <Link href="/dashboard/teacher/preparation/tcf-ee/new">
                  <Plus className="w-4 h-4 mr-1.5" />
                  Séance TCF EE
                </Link>
              </Button>
              <Button
                asChild
                variant="outline"
                className="border-violet-300 text-violet-800 hover:bg-violet-50"
              >
                <Link href="/dashboard/teacher/preparation/tcf-eo/new">
                  <Plus className="w-4 h-4 mr-1.5" />
                  Séance TCF EO
                </Link>
              </Button>
            </div>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {sessions.map((session) => {
            const statut = statutConfig[session.statut] ?? statutConfig.brouillon;
            const kind = kindConfig[session.kind];
            const KindIcon = kind.Icon;
            return (
              <Card key={`${session.kind}-${session.id}`} className="card-hover">
                <CardContent className="p-5 space-y-3">
                  <div className="flex items-start justify-between gap-2">
                    <div className={`p-2 rounded-lg ${kind.iconWrapClass}`}>
                      <KindIcon className={`w-4 h-4 ${kind.iconClass}`} />
                    </div>
                    <div className="flex items-center gap-1.5">
                      <Badge variant="outline" className={kind.badgeClass}>
                        {kind.label}
                      </Badge>
                      <Badge variant="outline" className={statut.badgeClass}>
                        {statut.label}
                      </Badge>
                    </div>
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 line-clamp-2">
                      {session.titre}
                    </h3>
                    <div className="flex items-center gap-2 mt-2 flex-wrap">
                      {session.duree_minuteur != null && (
                        <span className="inline-flex items-center gap-1 text-xs text-gray-500">
                          <Clock className="w-3.5 h-3.5" />
                          {session.duree_minuteur} min
                        </span>
                      )}
                      <span className="text-xs text-gray-400">
                        {kind.fullLabel}
                      </span>
                    </div>
                  </div>
                  <Button
                    asChild
                    variant="ghost"
                    size="sm"
                    className="w-full text-flehub-green hover:bg-flehub-green-light"
                  >
                    <Link href={kind.manageHref(session.id)}>
                      {kind.manageLabel}
                      <ChevronRight className="w-4 h-4 ml-1" />
                    </Link>
                  </Button>
                  {session.kind === 'ee' && session.statut === 'publiee' && (
                    <Button
                      asChild
                      variant="ghost"
                      size="sm"
                      className="w-full text-blue-700 hover:bg-blue-50"
                    >
                      <Link
                        href={`/dashboard/teacher/preparation/tcf-ee/${session.id}/corrections`}
                      >
                        Corriger les copies
                        <ChevronRight className="w-4 h-4 ml-1" />
                      </Link>
                    </Button>
                  )}
                  {session.kind === 'eo' && session.statut === 'publiee' && (
                    <Button
                      asChild
                      variant="ghost"
                      size="sm"
                      className="w-full text-violet-700 hover:bg-violet-50"
                    >
                      <Link
                        href={`/dashboard/teacher/preparation/tcf-eo/${session.id}/evaluations`}
                      >
                        Évaluer les passages
                        <ChevronRight className="w-4 h-4 ml-1" />
                      </Link>
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
