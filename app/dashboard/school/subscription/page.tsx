'use client';

import { Suspense, useCallback, useEffect, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { SCHOOL_ANNUAL_SUBSCRIPTION_RWF } from '@/lib/payments/constants';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  AlertTriangle,
  CheckCircle2,
  CreditCard,
  Loader2,
  RefreshCw,
} from 'lucide-react';

interface ActiveSubscription {
  id: string;
  status: string;
  period_start: string | null;
  period_end: string | null;
  amount_rwf: number;
  paid_at: string | null;
}

function formatDate(iso: string | null) {
  if (!iso) return '—';
  return new Date(iso).toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });
}

function SubscriptionContent() {
  const supabase = createClient();
  const searchParams = useSearchParams();
  const txRef = searchParams.get('tx_ref') || searchParams.get('txRef');
  const transactionId =
    searchParams.get('transaction_id') || searchParams.get('transactionId');

  const [schoolId, setSchoolId] = useState<string | null>(null);
  const [schoolName, setSchoolName] = useState<string>('');
  const [subscription, setSubscription] = useState<ActiveSubscription | null>(null);
  const [loading, setLoading] = useState(true);
  const [paying, setPaying] = useState(false);
  const [confirming, setConfirming] = useState(!!txRef);
  const [error, setError] = useState<string | null>(null);
  const [paymentNotice, setPaymentNotice] = useState<string | null>(null);

  const loadSubscription = useCallback(
    async (sid: string) => {
      const now = new Date().toISOString();
      const { data: active } = await supabase
        .from('school_subscriptions')
        .select('id, status, period_start, period_end, amount_rwf, paid_at')
        .eq('school_id', sid)
        .eq('status', 'active')
        .gte('period_end', now)
        .order('period_end', { ascending: false })
        .limit(1)
        .maybeSingle();

      if (active) {
        setSubscription(active as ActiveSubscription);
        return;
      }

      // Fall back to most recent row (expired / failed / pending)
      const { data: latest } = await supabase
        .from('school_subscriptions')
        .select('id, status, period_start, period_end, amount_rwf, paid_at')
        .eq('school_id', sid)
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle();

      if (latest?.status === 'active' && latest.period_end && latest.period_end < now) {
        setSubscription({ ...latest, status: 'expired' } as ActiveSubscription);
      } else {
        setSubscription((latest as ActiveSubscription) ?? null);
      }
    },
    [supabase]
  );

  const loadAll = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return;

      const { data: school } = await supabase
        .from('schools')
        .select('id, school_name')
        .eq('profile_id', user.id)
        .maybeSingle();

      if (!school) {
        setError('École introuvable.');
        return;
      }

      setSchoolId(school.id);
      setSchoolName(school.school_name);
      await loadSubscription(school.id);
    } catch {
      setError('Impossible de charger l’abonnement.');
    } finally {
      setLoading(false);
    }
  }, [supabase, loadSubscription]);

  useEffect(() => {
    loadAll();
  }, [loadAll]);

  // After Flutterwave redirect, poll status until active.
  useEffect(() => {
    if (!txRef || !schoolId) return;

    let cancelled = false;
    let attempts = 0;

    async function confirm() {
      setConfirming(true);
      setPaymentNotice('Confirmation du paiement en cours…');
      try {
        const params = new URLSearchParams({ tx_ref: txRef! });
        if (transactionId) params.set('transaction_id', transactionId);
        const res = await fetch(`/api/payments/school/status?${params.toString()}`);
        const json = await res.json();
        if (cancelled) return;

        if (json.status === 'active') {
          setPaymentNotice('Abonnement activé avec succès.');
          setConfirming(false);
          await loadSubscription(schoolId!);
          return;
        }

        if (json.status === 'failed') {
          setPaymentNotice('Le paiement a échoué.');
          setConfirming(false);
          await loadSubscription(schoolId!);
          return;
        }

        attempts += 1;
        if (attempts < 20) {
          setTimeout(confirm, 2500);
        } else {
          setPaymentNotice(
            'Paiement en attente de confirmation. Actualisez la page dans quelques instants.'
          );
          setConfirming(false);
        }
      } catch {
        if (!cancelled) {
          setPaymentNotice('Erreur lors de la confirmation du paiement.');
          setConfirming(false);
        }
      }
    }

    confirm();
    return () => {
      cancelled = true;
    };
  }, [txRef, transactionId, schoolId, loadSubscription]);

  async function handlePay() {
    setPaying(true);
    setError(null);
    try {
      const res = await fetch('/api/payments/school/initiate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount_rwf: SCHOOL_ANNUAL_SUBSCRIPTION_RWF }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json?.error || 'Échec du paiement');
      if (json.checkout_url) {
        window.location.href = json.checkout_url as string;
        return;
      }
      throw new Error('Lien de paiement manquant');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Échec du paiement');
      setPaying(false);
    }
  }

  const isActive =
    subscription?.status === 'active' &&
    !!subscription.period_end &&
    new Date(subscription.period_end) > new Date();

  const isExpired =
    subscription?.status === 'expired' ||
    (subscription?.period_end != null &&
      new Date(subscription.period_end) <= new Date() &&
      subscription.status === 'active');

  return (
    <div className="p-6 space-y-6 max-w-3xl mx-auto">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Abonnement</h1>
          <p className="text-sm text-gray-500 mt-1">
            Abonnement annuel de l’école{schoolName ? ` — ${schoolName}` : ''}
          </p>
        </div>
        <Button variant="outline" size="sm" onClick={loadAll} disabled={loading}>
          <RefreshCw className={`w-4 h-4 mr-1 ${loading ? 'animate-spin' : ''}`} />
          Actualiser
        </Button>
      </div>

      {paymentNotice && (
        <div className="flex items-center gap-2 rounded-lg border border-flehub-green/30 bg-flehub-green-light px-4 py-3 text-sm text-gray-800">
          {confirming ? (
            <Loader2 className="w-4 h-4 animate-spin text-flehub-green" />
          ) : (
            <CheckCircle2 className="w-4 h-4 text-flehub-green" />
          )}
          {paymentNotice}
        </div>
      )}

      {error && (
        <div className="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4" />
          {error}
        </div>
      )}

      {loading ? (
        <Skeleton className="h-48 rounded-xl" />
      ) : (
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0">
            <CardTitle className="text-base">Statut de l’abonnement</CardTitle>
            {isActive ? (
              <Badge className="bg-flehub-green-light text-flehub-green border-flehub-green">
                Actif
              </Badge>
            ) : isExpired ? (
              <Badge variant="outline" className="border-amber-400 text-amber-700">
                Expiré
              </Badge>
            ) : (
              <Badge variant="outline" className="text-gray-500">
                Aucun abonnement actif
              </Badge>
            )}
          </CardHeader>
          <CardContent className="space-y-4">
            {isActive ? (
              <div className="space-y-1 text-sm text-gray-700">
                <p>
                  Actif jusqu’au{' '}
                  <span className="font-semibold">{formatDate(subscription!.period_end)}</span>
                </p>
                <p className="text-gray-500">
                  Début de période : {formatDate(subscription!.period_start)}
                </p>
                {subscription!.amount_rwf != null && (
                  <p className="text-gray-500">
                    Montant : {Number(subscription!.amount_rwf).toLocaleString('fr-RW')} RWF
                  </p>
                )}
              </div>
            ) : isExpired ? (
              <p className="text-sm text-gray-700">
                Votre abonnement a expiré le{' '}
                <span className="font-semibold">{formatDate(subscription!.period_end)}</span>.
                Renouvelez pour continuer à utiliser l’espace école.
              </p>
            ) : (
              <p className="text-sm text-gray-700">
                Aucun abonnement annuel actif. Souscrivez pour activer l’accès complet de
                l’école.
              </p>
            )}

            <div className="rounded-lg border border-gray-100 bg-gray-50 px-4 py-3 text-sm">
              <p className="font-medium text-gray-900">Abonnement annuel</p>
              <p className="text-gray-600 mt-0.5">
                {SCHOOL_ANNUAL_SUBSCRIPTION_RWF.toLocaleString('fr-RW')} RWF / an
              </p>
            </div>

            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              disabled={paying || confirming}
              onClick={handlePay}
            >
              {paying ? (
                <>
                  <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  Redirection…
                </>
              ) : (
                <>
                  <CreditCard className="w-4 h-4 mr-2" />
                  {isActive ? 'Renouveler l’abonnement annuel' : 'Payer l’abonnement annuel'}
                </>
              )}
            </Button>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

export default function SchoolSubscriptionPage() {
  return (
    <Suspense
      fallback={
        <div className="p-6 max-w-3xl mx-auto">
          <Skeleton className="h-48 rounded-xl" />
        </div>
      }
    >
      <SubscriptionContent />
    </Suspense>
  );
}
