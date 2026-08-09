'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Clock, Headphones, Play } from 'lucide-react';

interface PublishedSession {
  id: string;
  titre: string;
  duree_minuteur: number;
  created_at: string;
}

export default function LearnerPreparationPage() {
  const supabase = createClient();
  const [sessions, setSessions] = useState<PublishedSession[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      try {
        const { data, error } = await supabase
          .from('tcf_co_sessions')
          .select('id, titre, duree_minuteur, created_at')
          .eq('statut', 'publiee')
          .order('created_at', { ascending: false });
        if (error) throw error;
        setSessions((data as PublishedSession[]) ?? []);
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
        <h1 className="text-2xl font-bold text-gray-900">Préparation TCF CO</h1>
        <p className="text-gray-500 text-sm mt-1">
          Entraînez-vous à la compréhension orale avec des séances publiées
        </p>
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
              Aucune séance disponible
            </h2>
            <p className="text-sm text-gray-500 mt-1 max-w-sm">
              Les séances publiées par vos préparateurs apparaîtront ici.
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {sessions.map((session) => (
            <Card key={session.id} className="card-hover">
              <CardContent className="p-5 space-y-3">
                <div className="flex items-start justify-between gap-2">
                  <div className="p-2 rounded-lg bg-flehub-green-light">
                    <Headphones className="w-4 h-4 text-flehub-green" />
                  </div>
                  <Badge
                    variant="outline"
                    className="bg-flehub-green-light text-flehub-green border-flehub-green"
                  >
                    Publiée
                  </Badge>
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900 line-clamp-2">
                    {session.titre}
                  </h3>
                  <span className="inline-flex items-center gap-1 text-xs text-gray-500 mt-2">
                    <Clock className="w-3.5 h-3.5" />
                    {session.duree_minuteur} min · 39 questions
                  </span>
                </div>
                <Button
                  asChild
                  className="w-full bg-flehub-green hover:bg-flehub-green/90 text-white"
                >
                  <Link
                    href={`/dashboard/learner/preparation/tcf-co/${session.id}`}
                  >
                    <Play className="w-4 h-4 mr-1.5" />
                    Commencer
                  </Link>
                </Button>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
