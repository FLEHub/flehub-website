'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { CheckCircle2, PenLine } from 'lucide-react';

export default function LearnerTcfEeConfirmationPage() {
  const params = useParams();
  const sessionId = params.sessionId as string;
  const supabase = useMemo(() => createClient(), []);

  const [loading, setLoading] = useState(true);
  const [attemptId, setAttemptId] = useState<string | null>(null);
  const [isCorrected, setIsCorrected] = useState(false);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      try {
        const {
          data: { user },
        } = await supabase.auth.getUser();
        if (!user) return;

        const { data } = await supabase
          .from('student_ee_attempts')
          .select('id, statut')
          .eq('session_id', sessionId)
          .eq('student_id', user.id)
          .in('statut', ['a_corriger', 'corrige'])
          .order('completed_at', { ascending: false })
          .limit(1)
          .maybeSingle();

        if (!cancelled && data) {
          setAttemptId(data.id);
          setIsCorrected(data.statut === 'corrige');
        }
      } catch (err) {
        console.error(err);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    if (sessionId) void load();
    else setLoading(false);

    return () => {
      cancelled = true;
    };
  }, [sessionId, supabase]);

  return (
    <div className="p-6 max-w-xl mx-auto">
      <Card>
        <CardContent className="flex flex-col items-center justify-center py-16 text-center space-y-4">
          <div className="p-3 rounded-lg bg-blue-50">
            <PenLine className="w-6 h-6 text-blue-700" />
          </div>
          <div className="inline-flex items-center gap-2 rounded-lg bg-flehub-green-light px-3 py-1.5 text-sm font-medium text-flehub-green">
            <CheckCircle2 className="w-4 h-4" />
            {isCorrected ? 'Correction disponible' : 'Copie envoyée'}
          </div>
          <h1 className="text-2xl font-bold text-gray-900">
            {isCorrected
              ? 'Votre correction est prête'
              : 'Votre copie a été envoyée'}
          </h1>
          <p className="text-sm text-gray-500 max-w-sm">
            {isCorrected
              ? 'Consultez les scores Fond et Forme pour chacune des 3 tâches.'
              : 'Vous recevrez votre correction bientôt. Merci d’avoir terminé les 3 tâches d’expression écrite.'}
          </p>
          {loading ? (
            <Skeleton className="h-10 w-48" />
          ) : (
            <div className="flex flex-col sm:flex-row gap-2 mt-2">
              {isCorrected && attemptId && (
                <Button
                  asChild
                  className="bg-blue-700 hover:bg-blue-800 text-white"
                >
                  <Link
                    href={`/dashboard/learner/preparation/tcf-ee/results/${attemptId}`}
                  >
                    Voir ma correction
                  </Link>
                </Button>
              )}
              <Button
                asChild
                className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              >
                <Link href="/dashboard/learner/preparation">
                  Retour à Préparation
                </Link>
              </Button>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
