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
  Clock,
  Headphones,
  Mic,
  PenLine,
  Play,
} from 'lucide-react';

type SessionKind = 'co' | 'ce' | 'ee' | 'eo';

interface PublishedSession {
  id: string;
  kind: SessionKind;
  titre: string;
  duree_minuteur: number | null;
  created_at: string;
}

const kindConfig: Record<
  SessionKind,
  {
    label: string;
    badgeClass: string;
    iconWrapClass: string;
    iconClass: string;
    Icon: typeof Headphones;
    metaLabel: string;
    href: (id: string) => string;
  }
> = {
  co: {
    label: 'CO',
    badgeClass: 'bg-sky-100 text-sky-700 border-sky-200',
    iconWrapClass: 'bg-flehub-green-light',
    iconClass: 'text-flehub-green',
    Icon: Headphones,
    metaLabel: '39 questions',
    href: (id) => `/dashboard/learner/preparation/tcf-co/${id}`,
  },
  ce: {
    label: 'CE',
    badgeClass: 'bg-amber-100 text-amber-800 border-amber-200',
    iconWrapClass: 'bg-amber-50',
    iconClass: 'text-amber-700',
    Icon: BookOpenText,
    metaLabel: '39 questions',
    href: (id) => `/dashboard/learner/preparation/tcf-ce/${id}`,
  },
  ee: {
    label: 'EE',
    badgeClass: 'bg-blue-100 text-blue-800 border-blue-200',
    iconWrapClass: 'bg-blue-50',
    iconClass: 'text-blue-700',
    Icon: PenLine,
    metaLabel: '3 tâches',
    href: (id) => `/dashboard/learner/preparation/tcf-ee/${id}`,
  },
  eo: {
    label: 'EO',
    badgeClass: 'bg-violet-100 text-violet-800 border-violet-200',
    iconWrapClass: 'bg-violet-50',
    iconClass: 'text-violet-700',
    Icon: Mic,
    metaLabel: 'Entraînement oral',
    href: (id) => `/dashboard/learner/preparation/tcf-eo/${id}`,
  },
};

export default function LearnerPreparationPage() {
  const supabase = createClient();
  const [sessions, setSessions] = useState<PublishedSession[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      try {
        const [coRes, ceRes, eeRes, eoRes] = await Promise.all([
          supabase
            .from('tcf_co_sessions')
            .select('id, titre, duree_minuteur, created_at')
            .eq('statut', 'publiee'),
          supabase
            .from('tcf_ce_sessions')
            .select('id, titre, duree_minuteur, created_at')
            .eq('statut', 'publiee'),
          supabase
            .from('tcf_ee_sessions')
            .select('id, titre, duree_minuteur, created_at')
            .eq('statut', 'publiee'),
          supabase
            .from('tcf_eo_sessions')
            .select('id, titre, created_at')
            .eq('statut', 'publiee'),
        ]);

        if (coRes.error) throw coRes.error;
        if (ceRes.error) throw ceRes.error;
        if (eeRes.error) throw eeRes.error;
        if (eoRes.error) throw eoRes.error;

        const coSessions: PublishedSession[] = (coRes.data ?? []).map((s) => ({
          id: s.id as string,
          titre: s.titre as string,
          duree_minuteur: s.duree_minuteur as number,
          created_at: s.created_at as string,
          kind: 'co' as const,
        }));
        const ceSessions: PublishedSession[] = (ceRes.data ?? []).map((s) => ({
          id: s.id as string,
          titre: s.titre as string,
          duree_minuteur: s.duree_minuteur as number,
          created_at: s.created_at as string,
          kind: 'ce' as const,
        }));
        const eeSessions: PublishedSession[] = (eeRes.data ?? []).map((s) => ({
          id: s.id as string,
          titre: s.titre as string,
          duree_minuteur: s.duree_minuteur as number,
          created_at: s.created_at as string,
          kind: 'ee' as const,
        }));
        const eoSessions: PublishedSession[] = (eoRes.data ?? []).map((s) => ({
          id: s.id as string,
          titre: s.titre as string,
          duree_minuteur: null,
          created_at: s.created_at as string,
          kind: 'eo' as const,
        }));

        setSessions(
          [...coSessions, ...ceSessions, ...eeSessions, ...eoSessions].sort(
            (a, b) =>
              new Date(b.created_at).getTime() -
              new Date(a.created_at).getTime()
          )
        );
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Préparation</h1>
        <p className="text-gray-500 text-sm mt-1">
          Révision générale et entraînements TCF (CO/CE/EE/EO)
        </p>
      </div>

      <Card className="border-flehub-green/30 bg-flehub-green-light/30">
        <CardContent className="p-5 flex flex-col sm:flex-row sm:items-center gap-4">
          <div className="p-3 rounded-lg bg-flehub-green-light">
            <BookOpen className="w-6 h-6 text-flehub-green" />
          </div>
          <div className="flex-1 min-w-0">
            <h2 className="font-semibold text-gray-900">Révision</h2>
            <p className="text-sm text-gray-500 mt-0.5">
              Fiches et questionnaires de grammaire / vocabulaire (hors TCF)
            </p>
          </div>
          <Button
            asChild
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
          >
            <Link href="/dashboard/learner/preparation/revision">
              <Play className="w-4 h-4 mr-1.5" />
              Ouvrir
            </Link>
          </Button>
        </CardContent>
      </Card>

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
              Aucune séance disponible
            </h2>
            <p className="text-sm text-gray-500 mt-1 max-w-sm">
              Les séances publiées par vos préparateurs apparaîtront ici.
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {sessions.map((session) => {
            const kind = kindConfig[session.kind];
            const KindIcon = kind.Icon;
            return (
              <Card
                key={`${session.kind}-${session.id}`}
                className="card-hover"
              >
                <CardContent className="p-5 space-y-3">
                  <div className="flex items-start justify-between gap-2">
                    <div className={`p-2 rounded-lg ${kind.iconWrapClass}`}>
                      <KindIcon className={`w-4 h-4 ${kind.iconClass}`} />
                    </div>
                    <div className="flex items-center gap-1.5">
                      <Badge variant="outline" className={kind.badgeClass}>
                        {kind.label}
                      </Badge>
                      <Badge
                        variant="outline"
                        className="bg-flehub-green-light text-flehub-green border-flehub-green"
                      >
                        Publiée
                      </Badge>
                    </div>
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 line-clamp-2">
                      {session.titre}
                    </h3>
                    <span className="inline-flex items-center gap-1 text-xs text-gray-500 mt-2">
                      {session.duree_minuteur != null ? (
                        <>
                          <Clock className="w-3.5 h-3.5" />
                          {session.duree_minuteur} min · {kind.metaLabel}
                        </>
                      ) : (
                        <>
                          <Mic className="w-3.5 h-3.5" />
                          {kind.metaLabel}
                        </>
                      )}
                    </span>
                  </div>
                  <Button
                    asChild
                    className="w-full bg-flehub-green hover:bg-flehub-green/90 text-white"
                  >
                    <Link href={kind.href(session.id)}>
                      <Play className="w-4 h-4 mr-1.5" />
                      Commencer
                    </Link>
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
