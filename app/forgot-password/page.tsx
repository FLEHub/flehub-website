'use client';

import { useRef, useState } from 'react';
import Link from 'next/link';
import { GraduationCap, AlertCircle, CheckCircle2, ArrowLeft, ArrowRight } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { createClient } from '@/lib/supabase/client';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);
  const submittingRef = useRef(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (loading || submittingRef.current) return;

    const trimmedEmail = email.trim().toLowerCase();
    if (!trimmedEmail || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmedEmail)) {
      setError('Veuillez saisir une adresse e-mail valide.');
      return;
    }

    submittingRef.current = true;
    setLoading(true);
    setError(null);

    try {
      const supabase = createClient();
      const redirectTo = `${window.location.origin}/auth/callback?next=/reset-password`;

      const { error: resetError } = await supabase.auth.resetPasswordForEmail(trimmedEmail, {
        redirectTo,
      });

      if (resetError) {
        const message = resetError.message.toLowerCase();
        if (message.includes('rate limit')) {
          setError(
            'Trop de demandes. Veuillez patienter quelques minutes avant de réessayer.'
          );
        } else {
          setError(
            'Impossible d\'envoyer l\'e-mail pour le moment. Vérifiez l\'adresse saisie et réessayez.'
          );
        }
        return;
      }

      setSuccess(true);
    } catch {
      setError('Une erreur réseau est survenue. Veuillez réessayer.');
    } finally {
      submittingRef.current = false;
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex">
      <div className="hidden lg:flex lg:w-1/2 gradient-hero flex-col items-center justify-center p-12 text-white relative overflow-hidden">
        <div className="relative z-10 max-w-md text-center">
          <div className="flex items-center justify-center gap-3 mb-10">
            <div className="w-14 h-14 bg-white/20 rounded-2xl flex items-center justify-center backdrop-blur-sm">
              <GraduationCap className="w-8 h-8 text-white" />
            </div>
            <span className="text-3xl font-extrabold">FLEHub</span>
          </div>
          <h2 className="text-3xl font-bold mb-4 leading-snug">Réinitialiser votre mot de passe</h2>
          <p className="text-white/75 text-base leading-relaxed">
            Nous vous enverrons un lien sécurisé pour choisir un nouveau mot de passe.
          </p>
        </div>
      </div>

      <div className="flex-1 flex flex-col items-center justify-center px-6 py-12 bg-white">
        <div className="w-full max-w-md">
          <Link
            href="/login"
            className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green transition-colors mb-6"
          >
            <ArrowLeft className="w-4 h-4" />
            Retour à la connexion
          </Link>

          <div className="mb-8">
            <h1 className="text-2xl font-bold text-gray-900 mb-1.5">Mot de passe oublié</h1>
            <p className="text-gray-500 text-sm">
              Saisissez votre adresse e-mail et nous vous enverrons un lien de réinitialisation.
            </p>
          </div>

          {success ? (
            <div className="bg-green-50 border border-green-200 rounded-xl p-5">
              <div className="flex gap-3">
                <CheckCircle2 className="w-5 h-5 text-flehub-green flex-shrink-0 mt-0.5" />
                <div>
                  <p className="text-sm font-semibold text-gray-900">E-mail envoyé</p>
                  <p className="text-sm text-gray-600 mt-1">
                    Si un compte existe pour <span className="font-medium">{email}</span>, vous
                    recevrez un lien pour réinitialiser votre mot de passe. Vérifiez aussi vos
                    spams.
                  </p>
                  <Link
                    href="/login"
                    className="inline-flex items-center gap-1 text-sm text-flehub-green font-semibold hover:underline mt-4"
                  >
                    Retour à la connexion
                    <ArrowRight className="w-3.5 h-3.5" />
                  </Link>
                </div>
              </div>
            </div>
          ) : (
            <>
              {error && (
                <div className="mb-6 bg-red-50 border border-red-200 rounded-xl p-4 flex gap-3">
                  <AlertCircle className="w-5 h-5 text-red-500 flex-shrink-0 mt-0.5" />
                  <p className="text-sm text-red-700">{error}</p>
                </div>
              )}

              <form onSubmit={handleSubmit} className="space-y-5" noValidate>
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
                    onChange={(e) => {
                      setEmail(e.target.value);
                      setError(null);
                    }}
                    disabled={loading}
                    required
                    className="h-11 border-gray-300 focus:border-flehub-green focus:ring-flehub-green/20 rounded-xl"
                  />
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  aria-busy={loading}
                  className="w-full h-11 flex items-center justify-center gap-2 bg-flehub-green text-white font-semibold rounded-xl hover:bg-flehub-green-dark transition-colors disabled:opacity-60 disabled:cursor-not-allowed shadow-sm"
                >
                  {loading ? 'Envoi en cours…' : 'Envoyer le lien'}
                </button>
              </form>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
