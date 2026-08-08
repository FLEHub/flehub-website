'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Headphones, Plus, Clock, ChevronRight } from 'lucide-react';

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';
type SessionStatut = 'brouillon' | 'publiee';

interface TcfCoSession {
  id: string;
  titre: string;
  niveau: CEFR;
  duree_minuteur: number;
  statut: SessionStatut;
  created_at: string;
}

const cefrColors: Record<CEFR, string> = {
  A1: 'bg-green-100 text-green-700',
  A2: 'bg-lime-100 text-lime-700',
  B1: 'bg-yellow-100 text-yellow-700',
  B2: 'bg-orange-100 text-orange-700',
  C1: 'bg-red-100 text-red-700',
  C2: 'bg-rose-100 text-rose-700',
};

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

export default function TeacherPreparationPage() {
  const supabase = createClient();
  const [sessions, setSessions] = useState<TcfCoSession[]>([]);
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

      const { data } = await supabase
        .from('tcf_co_sessions')
        .select('id, titre, niveau, duree_minuteur, statut, created_at')
        .eq('created_by', user.id)
        .order('created_at', { ascending: false });

      setSessions((data as TcfCoSession[]) ?? []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Préparation</h1>
          <p className="text-gray-500 text-sm mt-1">
            Créez et gérez vos séances TCF Compréhension Orale
          </p>
        </div>
        <Button
          asChild
          className="bg-flehub-green hover:bg-flehub-green/90 text-white"
        >
          <Link href="/dashboard/teacher/preparation/tcf-co/new">
            <Plus className="w-4 h-4 mr-1.5" />
            Nouvelle séance TCF CO
          </Link>
        </Button>
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
            <div className="p-3 rounded-lg bg-flehub-green-light mb-4">
              <Headphones className="w-6 h-6 text-flehub-green" />
            </div>
            <h2 className="text-lg font-semibold text-gray-900">
              Aucune séance TCF CO
            </h2>
            <p className="text-sm text-gray-500 mt-1 max-w-sm">
              Créez votre première séance de compréhension orale, puis ajoutez les
              questions audio.
            </p>
            <Button
              asChild
              className="mt-6 bg-flehub-green hover:bg-flehub-green/90 text-white"
            >
              <Link href="/dashboard/teacher/preparation/tcf-co/new">
                <Plus className="w-4 h-4 mr-1.5" />
                Créer une séance
              </Link>
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {sessions.map((session) => {
            const statut = statutConfig[session.statut] ?? statutConfig.brouillon;
            return (
              <Card key={session.id} className="card-hover">
                <CardContent className="p-5 space-y-3">
                  <div className="flex items-start justify-between gap-2">
                    <div className="p-2 rounded-lg bg-flehub-green-light">
                      <Headphones className="w-4 h-4 text-flehub-green" />
                    </div>
                    <Badge variant="outline" className={statut.badgeClass}>
                      {statut.label}
                    </Badge>
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 line-clamp-2">
                      {session.titre}
                    </h3>
                    <div className="flex items-center gap-2 mt-2 flex-wrap">
                      <Badge className={cefrColors[session.niveau]}>
                        {session.niveau}
                      </Badge>
                      <span className="inline-flex items-center gap-1 text-xs text-gray-500">
                        <Clock className="w-3.5 h-3.5" />
                        {session.duree_minuteur} min
                      </span>
                    </div>
                  </div>
                  <Button
                    asChild
                    variant="ghost"
                    size="sm"
                    className="w-full text-flehub-green hover:bg-flehub-green-light"
                  >
                    <Link
                      href={`/dashboard/teacher/preparation/tcf-co/${session.id}/questions`}
                    >
                      Gérer les questions
                      <ChevronRight className="w-4 h-4 ml-1" />
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
