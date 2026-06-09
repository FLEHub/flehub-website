'use client';

import { useState } from 'react';
import Link from 'next/link';
import { AlertCircle, ArrowLeft, CheckCircle, GraduationCap } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { AUTH_RATE_LIMIT_MESSAGE, isAuthRateLimitError } from '@/lib/auth-errors';
import { createClient } from '@/lib/supabase/client';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError(null);
    setMessage(null);

    const normalizedEmail = email.trim().toLowerCase();
    if (!normalizedEmail) {
      setError('Veuillez saisir votre adresse e-mail.');
      return;
    }

    setLoading(true);

    try {
      const supabase = createClient();
      const { error: resetError } = await supabase.auth.resetPasswordForEmail(normalizedEmail, {
        redirectTo: `${window.location.origin}/login`,
      });

      if (resetError) {
        if (isAuthRateLimitError(resetError)) {
          setError(AUTH_RATE_LIMIT_MESSAGE);
        } else {
          setError(resetError.message);
        }
        return;
      }

      setMessage(
        'Si un compte existe avec cette adresse, vous recevrez un e-mail de réinitialisation dans quelques minutes.'
      );
    } catch {
      setError('Une erreur réseau est survenue. Veuillez réessayer.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-6 py-12">
      <div className="w-full max-w-md">
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-8">
          <div className="flex items-center justify-center gap-2.5 mb-8">
            <div className="w-10 h-10 bg-flehub-green rounded-xl flex items-center justify-center">
              <GraduationCap className="w-6 h-6 text-white" />
            </div>
            <span className="text-2xl font-bold text-gray-900">
              FLE<span className="text-flehub-green">Hub</span>
            </span>
          </div>

          <div className="mb-6">
            <h1 className="text-2xl font-bold text-gray-900 mb-2">Mot de passe oublié ?</h1>
            <p className="text-sm text-gray-500 leading-relaxed">
              Entrez votre adresse e-mail et nous vous enverrons un lien pour réinitialiser votre
              mot de passe.
            </p>
          </div>

          {error && (
            <div className="mb-5 bg-red-50 border border-red-200 rounded-xl p-4 flex gap-3">
              <AlertCircle className="w-5 h-5 text-red-500 flex-shrink-0 mt-0.5" />
              <p className="text-sm text-red-700">{error}</p>
            </div>
          )}

          {message && (
            <div className="mb-5 bg-green-50 border border-green-200 rounded-xl p-4 flex gap-3">
              <CheckCircle className="w-5 h-5 text-flehub-green flex-shrink-0 mt-0.5" />
              <p className="text-sm text-green-700">{message}</p>
            </div>
          )}

          <form method="post" onSubmit={handleSubmit} className="space-y-5" noValidate>
            <div className="space-y-1.5">
              <Label htmlFor="email" className="text-sm font-medium text-gray-700">
                Adresse e-mail
              </Label>
              <Input
                id="email"
                name="email"
                type="email"
                autoComplete="email"
                placeholder="vous@exemple.com"
                value={email}
                onChange={(event) => {
                  setEmail(event.target.value);
                  setError(null);
                  setMessage(null);
                }}
                disabled={loading}
                className="h-11 border-gray-300 focus:border-flehub-green focus:ring-flehub-green/20 rounded-xl"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full h-11 flex items-center justify-center gap-2 bg-flehub-green text-white font-semibold rounded-xl hover:bg-flehub-green-dark transition-colors disabled:opacity-60 disabled:cursor-not-allowed shadow-sm"
            >
              {loading ? 'Envoi en cours...' : 'Envoyer le lien'}
            </button>
          </form>

          <Link
            href="/login"
            className="mt-6 inline-flex items-center justify-center gap-2 text-sm text-gray-500 hover:text-flehub-green transition-colors"
          >
            <ArrowLeft className="w-4 h-4" />
            Retour à la connexion
          </Link>
        </div>
      </div>
    </div>
  );
}
