'use client';

import { Suspense, useCallback, useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { CheckCircle2, Loader2, XCircle } from 'lucide-react';

type Status = 'waiting' | 'success' | 'failed' | 'error';

function PaymentCallbackContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const txRef = searchParams.get('tx_ref') || searchParams.get('txRef');
  const transactionId =
    searchParams.get('transaction_id') || searchParams.get('transactionId');
  const flwStatus = searchParams.get('status');

  const [status, setStatus] = useState<Status>('waiting');
  const [moduleId, setModuleId] = useState<string | null>(null);
  const [message, setMessage] = useState('Confirmation du paiement en cours…');

  const poll = useCallback(async () => {
    if (!txRef) {
      setStatus('error');
      setMessage('Référence de paiement manquante.');
      return;
    }

    if (flwStatus && flwStatus !== 'successful' && flwStatus !== 'completed') {
      setStatus('failed');
      setMessage(
        'Le paiement n’a pas abouti. Vous pouvez réessayer depuis la liste des modules.'
      );
      return;
    }

    try {
      const params = new URLSearchParams({ tx_ref: txRef });
      if (transactionId) params.set('transaction_id', transactionId);

      const res = await fetch(`/api/payments/module/status?${params.toString()}`);
      const json = await res.json();

      if (!res.ok) {
        setStatus('error');
        setMessage(json?.error || 'Impossible de vérifier le paiement.');
        return;
      }

      setModuleId(json.module_id ?? null);

      if (json.status === 'successful' && json.enrolled) {
        setStatus('success');
        setMessage('Paiement confirmé. Inscription réussie.');
        return;
      }

      if (json.status === 'failed' || json.status === 'cancelled') {
        setStatus('failed');
        setMessage('Le paiement a échoué ou a été annulé.');
        return;
      }

      setStatus('waiting');
      setMessage('Paiement reçu. Nous confirmons votre inscription…');
    } catch {
      setStatus('error');
      setMessage('Erreur réseau lors de la vérification.');
    }
  }, [txRef, transactionId, flwStatus]);

  useEffect(() => {
    poll();
  }, [poll]);

  useEffect(() => {
    if (status !== 'waiting') return;
    const id = setInterval(poll, 2500);
    return () => clearInterval(id);
  }, [status, poll]);

  useEffect(() => {
    if (status === 'success' && moduleId) {
      const t = setTimeout(() => {
        router.replace(`/dashboard/learner/elearning/${moduleId}`);
      }, 1500);
      return () => clearTimeout(t);
    }
  }, [status, moduleId, router]);

  return (
    <div className="p-6 max-w-lg mx-auto">
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Paiement du module</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-start gap-3">
            {status === 'waiting' && (
              <Loader2 className="w-6 h-6 text-flehub-green animate-spin shrink-0 mt-0.5" />
            )}
            {status === 'success' && (
              <CheckCircle2 className="w-6 h-6 text-flehub-green shrink-0 mt-0.5" />
            )}
            {(status === 'failed' || status === 'error') && (
              <XCircle className="w-6 h-6 text-red-500 shrink-0 mt-0.5" />
            )}
            <p className="text-sm text-gray-700">{message}</p>
          </div>

          {status === 'success' && moduleId && (
            <Button
              asChild
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
            >
              <Link href={`/dashboard/learner/elearning/${moduleId}`}>
                Accéder au module
              </Link>
            </Button>
          )}

          {(status === 'failed' || status === 'error') && (
            <Button asChild variant="outline">
              <Link href="/dashboard/learner/elearning">Retour aux modules</Link>
            </Button>
          )}
        </CardContent>
      </Card>
    </div>
  );
}

export default function ModulePaymentCallbackPage() {
  return (
    <Suspense
      fallback={
        <div className="p-6 max-w-lg mx-auto">
          <Skeleton className="h-40 rounded-xl" />
        </div>
      }
    >
      <PaymentCallbackContent />
    </Suspense>
  );
}
