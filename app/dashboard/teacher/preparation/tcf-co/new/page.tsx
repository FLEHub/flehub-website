'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent } from '@/components/ui/card';
import { AlertTriangle, ArrowLeft, Loader2, X } from 'lucide-react';

export default function NewTcfCoSessionPage() {
  const router = useRouter();
  const supabase = createClient();

  const [titre, setTitre] = useState('');
  const [dureeMinuteur, setDureeMinuteur] = useState<string>('25');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);

    const trimmedTitre = titre.trim();
    const duree = Number.parseInt(dureeMinuteur, 10);

    if (!trimmedTitre) {
      setError('Le titre de la séance est obligatoire.');
      return;
    }
    if (!Number.isFinite(duree) || duree <= 0) {
      setError('La durée du minuteur doit être un nombre entier positif (en minutes).');
      return;
    }

    setSaving(true);
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) {
        setError('Session expirée. Reconnectez-vous.');
        return;
      }

      const { data, error: insertError } = await supabase
        .from('tcf_co_sessions')
        .insert({
          titre: trimmedTitre,
          duree_minuteur: duree,
          statut: 'brouillon',
          created_by: user.id,
        })
        .select('id')
        .single();

      if (insertError) throw insertError;
      if (!data?.id) throw new Error('La séance n’a pas pu être créée.');

      router.push(
        `/dashboard/teacher/preparation/tcf-co/${data.id}/questions`
      );
    } catch (err) {
      console.error(err);
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible de créer la séance. Réessayez.'
      );
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="p-6 space-y-6 max-w-2xl mx-auto">
      <div>
        <Link
          href="/dashboard/teacher/preparation"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour à Préparation
        </Link>
        <h1 className="text-2xl font-bold text-gray-900">
          Nouvelle séance TCF CO
        </h1>
        <p className="text-sm text-gray-500 mt-1">
          Définissez le titre et la durée, puis ajoutez les questions (chaque
          question aura son propre niveau).
        </p>
      </div>

      <Card>
        <CardContent className="p-6">
          <form onSubmit={handleSubmit} className="space-y-5">
            {error && (
              <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
                <AlertTriangle className="w-4 h-4 flex-shrink-0" />
                <span className="flex-1">{error}</span>
                <button type="button" onClick={() => setError(null)}>
                  <X className="w-4 h-4" />
                </button>
              </div>
            )}

            <div className="space-y-2">
              <Label htmlFor="titre">Titre de la séance</Label>
              <Input
                id="titre"
                value={titre}
                onChange={(e) => setTitre(e.target.value)}
                placeholder="Ex. TCF CO — Entraînement complet"
                disabled={saving}
                required
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="duree">Durée du minuteur (minutes)</Label>
              <Input
                id="duree"
                type="number"
                min={1}
                step={1}
                value={dureeMinuteur}
                onChange={(e) => setDureeMinuteur(e.target.value)}
                placeholder="25"
                disabled={saving}
                required
              />
              <p className="text-xs text-gray-400">
                Temps imparti à l’apprenant pour passer la séance.
              </p>
            </div>

            <div className="flex items-center justify-end gap-3 pt-2">
              <Button
                type="button"
                variant="outline"
                disabled={saving}
                onClick={() => router.push('/dashboard/teacher/preparation')}
              >
                Annuler
              </Button>
              <Button
                type="submit"
                className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                disabled={saving || !titre.trim()}
              >
                {saving ? (
                  <>
                    <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
                    Création…
                  </>
                ) : (
                  'Créer la séance'
                )}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
