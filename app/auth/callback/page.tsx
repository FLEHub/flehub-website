'use client';

import { Suspense, useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { GraduationCap } from 'lucide-react';
import { createClient } from '@/lib/supabase/client';

function AuthCallbackContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function handleCallback() {
      const supabase = createClient();
      const next = searchParams.get('next') ?? '/dashboard';
      const code = searchParams.get('code');

      try {
        if (code) {
          const { error: exchangeError } = await supabase.auth.exchangeCodeForSession(code);
          if (exchangeError) {
            setError(exchangeError.message);
            return;
          }
        }

        const {
          data: { session },
          error: sessionError,
        } = await supabase.auth.getSession();

        if (sessionError || !session) {
          setError('session_missing');
          return;
        }

        router.replace(next);
      } catch {
        setError('network');
      }
    }

    handleCallback();
  }, [router, searchParams]);

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 px-6">
        <div className="max-w-md w-full bg-white rounded-2xl border border-gray-100 shadow-sm p-8 text-center">
          <p className="text-sm text-red-600 mb-4">
            {error === 'session_missing'
              ? 'Le lien de confirmation est invalide ou a expiré.'
              : 'Une erreur est survenue lors de la connexion.'}
          </p>
          <div className="flex flex-col gap-2">
            <Link
              href="/forgot-password"
              className="text-sm text-flehub-green font-semibold hover:underline"
            >
              Demander un nouveau lien
            </Link>
            <Link href="/login" className="text-sm text-gray-500 hover:underline">
              Retour à la connexion
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gray-50 gap-4">
      <div className="w-10 h-10 bg-flehub-green rounded-lg flex items-center justify-center">
        <GraduationCap className="w-5 h-5 text-white" />
      </div>
      <div className="h-8 w-8 animate-spin rounded-full border-2 border-[#00A550] border-t-transparent" />
      <p className="text-sm text-gray-500">Connexion en cours…</p>
    </div>
  );
}

export default function AuthCallbackPage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
          <p className="text-sm text-gray-500">Chargement…</p>
        </div>
      }
    >
      <AuthCallbackContent />
    </Suspense>
  );
}
