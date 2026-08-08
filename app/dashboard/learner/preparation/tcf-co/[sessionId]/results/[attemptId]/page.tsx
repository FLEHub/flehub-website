'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { ArrowLeft, CheckCircle2, Trophy } from 'lucide-react';

interface AttemptSummary {
  id: string;
  score: number | null;
  niveau_obtenu: string | null;
  temps_utilise_secondes: number | null;
  completed_at: string | null;
  session_id: string;
}

/**
 * BLOC 6 — page de résultats (version minimale pour la redirection
 * après fin de test ; le détail complet pourra être enrichi ensuite).
 */
export default function LearnerTcfCoResultsPage() {
  const params = useParams();
  const sessionId = params.sessionId as string;
  const attemptId = params.attemptId as string;
  const supabase = createClient();

  const [attempt, setAttempt] = useState<AttemptSummary | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      try {
        const { data, error } = await supabase
          .from('student_co_attempts')
          .select(
            'id, score, niveau_obtenu, temps_utilise_secondes, completed_at, session_id'
          )
          .eq('id', attemptId)
          .maybeSingle();
        if (error) throw error;
        setAttempt((data as AttemptSummary) ?? null);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    if (attemptId) load();
  }, [attemptId]);

  return (
    <div className="p-6 space-y-6 max-w-2xl mx-auto">
      <Link
        href="/dashboard/learner/preparation"
        className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green"
      >
        <ArrowLeft className="w-4 h-4" />
        Retour à Préparation
      </Link>

      <Card>
        <CardContent className="flex flex-col items-center justify-center py-14 text-center space-y-4">
          <div className="p-3 rounded-lg bg-flehub-green-light">
            <Trophy className="w-7 h-7 text-flehub-green" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">
              Test terminé
            </h1>
            <p className="text-sm text-gray-500 mt-1">
              Vos réponses ont été enregistrées.
            </p>
          </div>

          {loading ? (
            <Skeleton className="h-16 w-48" />
          ) : attempt ? (
            <div className="space-y-2">
              <div className="inline-flex items-center gap-2 text-flehub-green font-semibold">
                <CheckCircle2 className="w-5 h-5" />
                Score : {attempt.score ?? '—'} / 40
              </div>
              {attempt.niveau_obtenu && (
                <p className="text-sm text-gray-700">
                  Niveau obtenu :{' '}
                  <span className="font-semibold">{attempt.niveau_obtenu}</span>
                </p>
              )}
              {attempt.temps_utilise_secondes != null && (
                <p className="text-xs text-gray-500">
                  Temps utilisé : {Math.floor(attempt.temps_utilise_secondes / 60)}{' '}
                  min {attempt.temps_utilise_secondes % 60} s
                </p>
              )}
            </div>
          ) : (
            <p className="text-sm text-gray-500">Résultat indisponible.</p>
          )}

          <Button
            asChild
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
          >
            <Link href={`/dashboard/learner/preparation/tcf-co/${sessionId}`}>
              Refaire la séance
            </Link>
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
