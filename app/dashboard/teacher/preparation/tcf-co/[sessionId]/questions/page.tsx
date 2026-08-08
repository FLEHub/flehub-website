'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { ArrowLeft, Headphones } from 'lucide-react';

interface TcfCoSession {
  id: string;
  titre: string;
  duree_minuteur: number;
  statut: 'brouillon' | 'publiee';
}

/**
 * BLOC 4 — page d'ajout des questions (placeholder UI pour la redirection
 * après création de séance ; l'éditeur de questions arrivera ensuite).
 */
export default function TcfCoQuestionsPage() {
  const params = useParams();
  const sessionId = params.sessionId as string;
  const supabase = createClient();

  const [session, setSession] = useState<TcfCoSession | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function load() {
      try {
        const { data, error: fetchError } = await supabase
          .from('tcf_co_sessions')
          .select('id, titre, duree_minuteur, statut')
          .eq('id', sessionId)
          .maybeSingle();

        if (fetchError) throw fetchError;
        if (!data) {
          setError('Séance introuvable.');
          return;
        }
        setSession(data as TcfCoSession);
      } catch (err) {
        console.error(err);
        setError('Impossible de charger la séance.');
      } finally {
        setLoading(false);
      }
    }

    if (sessionId) load();
  }, [sessionId]);

  return (
    <div className="p-6 space-y-6 max-w-4xl mx-auto">
      <div>
        <Link
          href="/dashboard/teacher/preparation"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour à Préparation
        </Link>
        {loading ? (
          <div className="space-y-2">
            <Skeleton className="h-8 w-72" />
            <Skeleton className="h-4 w-48" />
          </div>
        ) : session ? (
          <>
            <div className="flex items-center gap-2 flex-wrap">
              <h1 className="text-2xl font-bold text-gray-900">{session.titre}</h1>
              <Badge className="bg-gray-100 text-gray-600 border-gray-300" variant="outline">
                {session.statut === 'publiee' ? 'Publiée' : 'Brouillon'}
              </Badge>
            </div>
            <p className="text-sm text-gray-500 mt-1">
              {session.duree_minuteur} min · Ajout des questions (BLOC 4) — chaque
              question a son propre niveau
            </p>
          </>
        ) : (
          <h1 className="text-2xl font-bold text-gray-900">Questions TCF CO</h1>
        )}
      </div>

      <Card>
        <CardContent className="flex flex-col items-center justify-center py-16 text-center">
          <div className="p-3 rounded-lg bg-flehub-green-light mb-4">
            <Headphones className="w-6 h-6 text-flehub-green" />
          </div>
          {error ? (
            <p className="text-sm text-red-600">{error}</p>
          ) : (
            <>
              <h2 className="text-lg font-semibold text-gray-900">
                Éditeur de questions à venir
              </h2>
              <p className="text-sm text-gray-500 mt-1 max-w-md">
                La séance a bien été créée. Vous pourrez bientôt ajouter jusqu’à
                40 questions audio (fichier, énoncé, choix et bonne réponse).
              </p>
            </>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
