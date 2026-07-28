'use client';

import { useCallback, useEffect, useRef, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Skeleton } from '@/components/ui/skeleton';
import {
  AlertTriangle,
  CheckCircle2,
  ImageIcon,
  Loader2,
  PenLine,
  Settings,
  Upload,
  X,
} from 'lucide-react';

const SIGNATURE_BUCKET = 'teacher-signatures';

export default function TeacherSettingsPage() {
  const supabase = createClient();

  const [teacherId, setTeacherId] = useState<string | null>(null);
  const [certificateName, setCertificateName] = useState('');
  const [signaturePath, setSignaturePath] = useState<string | null>(null);
  const [signatureUrl, setSignatureUrl] = useState<string | null>(null);
  const [pendingFile, setPendingFile] = useState<File | null>(null);
  const [pendingPreview, setPendingPreview] = useState<string | null>(null);

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const fileInputRef = useRef<HTMLInputElement>(null);

  const loadPreview = useCallback(
    async (path: string | null) => {
      if (!path) {
        setSignatureUrl(null);
        return;
      }
      const { data } = await supabase.storage
        .from(SIGNATURE_BUCKET)
        .createSignedUrl(path, 3600);
      setSignatureUrl(data?.signedUrl ?? null);
    },
    [supabase]
  );

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return;

      const [{ data: teacher }, { data: profile }] = await Promise.all([
        supabase
          .from('teachers')
          .select('id, certificate_name, signature_path')
          .eq('profile_id', user.id)
          .maybeSingle(),
        supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle(),
      ]);

      if (!teacher) {
        setError('Profil enseignant introuvable.');
        return;
      }

      setTeacherId(teacher.id);
      const name =
        (teacher.certificate_name as string | null)?.trim() ||
        (profile?.full_name as string | null)?.trim() ||
        '';
      setCertificateName(name);
      setSignaturePath((teacher.signature_path as string | null) ?? null);
      await loadPreview((teacher.signature_path as string | null) ?? null);
    } catch (err) {
      console.error(err);
      setError('Impossible de charger les paramètres.');
    } finally {
      setLoading(false);
    }
  }, [supabase, loadPreview]);

  useEffect(() => {
    void load();
  }, [load]);

  useEffect(() => {
    return () => {
      if (pendingPreview) URL.revokeObjectURL(pendingPreview);
    };
  }, [pendingPreview]);

  function onFileChange(file: File | null) {
    if (pendingPreview) URL.revokeObjectURL(pendingPreview);
    if (!file) {
      setPendingFile(null);
      setPendingPreview(null);
      return;
    }
    const okTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/webp'];
    if (!okTypes.includes(file.type)) {
      setError('Format non supporté. Utilisez PNG ou JPG (fond transparent recommandé).');
      return;
    }
    setError(null);
    setPendingFile(file);
    setPendingPreview(URL.createObjectURL(file));
  }

  async function handleSave() {
    if (!teacherId) return;
    setSaving(true);
    setError(null);
    setSuccess(false);
    try {
      let nextPath = signaturePath;

      if (pendingFile) {
        const path = `${teacherId}/signature.png`;
        const { error: upErr } = await supabase.storage
          .from(SIGNATURE_BUCKET)
          .upload(path, pendingFile, {
            upsert: true,
            contentType: pendingFile.type || 'image/png',
          });
        if (upErr) throw upErr;
        nextPath = path;
      }

      const { error: updErr } = await supabase
        .from('teachers')
        .update({
          certificate_name: certificateName.trim() || null,
          signature_path: nextPath,
        })
        .eq('id', teacherId);
      if (updErr) throw updErr;

      setSignaturePath(nextPath);
      if (pendingPreview) URL.revokeObjectURL(pendingPreview);
      setPendingFile(null);
      setPendingPreview(null);
      await loadPreview(nextPath);

      setSuccess(true);
      setTimeout(() => setSuccess(false), 3000);
    } catch (err) {
      console.error(err);
      setError(err instanceof Error ? err.message : 'Échec de l’enregistrement');
    } finally {
      setSaving(false);
    }
  }

  const previewSrc = pendingPreview || signatureUrl;

  return (
    <div className="p-6 space-y-6 max-w-2xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
        <p className="text-sm text-gray-500 mt-1">
          Nom et signature utilisés sur les certificats
        </p>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          <span className="flex-1">{error}</span>
          <button type="button" onClick={() => setError(null)}>
            <X className="w-4 h-4 text-red-400 hover:text-red-600" />
          </button>
        </div>
      )}

      {success && (
        <div className="flex items-center gap-2 rounded-lg bg-flehub-green-light border border-flehub-green/30 px-4 py-3 text-sm text-flehub-green">
          <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
          Paramètres enregistrés.
        </div>
      )}

      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-flehub-green-light flex items-center justify-center">
              <Settings className="w-4 h-4 text-flehub-green" />
            </div>
            <CardTitle className="text-base font-semibold">
              Certificat
            </CardTitle>
          </div>
        </CardHeader>
        <CardContent className="space-y-5">
          {loading ? (
            <div className="space-y-3">
              <Skeleton className="h-10 w-full" />
              <Skeleton className="h-32 w-full" />
            </div>
          ) : (
            <>
              <div className="space-y-1.5">
                <Label htmlFor="certificate-name">Nom pour le certificat</Label>
                <Input
                  id="certificate-name"
                  value={certificateName}
                  onChange={(e) => setCertificateName(e.target.value)}
                  placeholder="Ex. Marie Uwase"
                />
                <p className="text-xs text-gray-400">
                  Pré-rempli avec votre nom de profil si aucun nom certificat n’est
                  encore défini.
                </p>
              </div>

              <div className="space-y-2">
                <Label>Signature</Label>
                <div className="rounded-lg border border-dashed border-gray-200 bg-gray-50 p-4 space-y-3">
                  {previewSrc ? (
                    <div className="flex items-center justify-center rounded-md bg-white border border-gray-100 p-4 min-h-[120px]">
                      {/* eslint-disable-next-line @next/next/no-img-element */}
                      <img
                        src={previewSrc}
                        alt="Aperçu de la signature"
                        className="max-h-28 object-contain"
                      />
                    </div>
                  ) : (
                    <div className="flex flex-col items-center justify-center py-8 text-gray-400">
                      <ImageIcon className="w-8 h-8 mb-2 opacity-50" />
                      <p className="text-sm">Aucune signature uploadée</p>
                    </div>
                  )}

                  <input
                    ref={fileInputRef}
                    type="file"
                    accept="image/png,image/jpeg,image/jpg,image/webp"
                    className="hidden"
                    onChange={(e) =>
                      onFileChange(e.target.files?.[0] ?? null)
                    }
                  />

                  <div className="flex flex-wrap gap-2">
                    <Button
                      type="button"
                      variant="outline"
                      onClick={() => fileInputRef.current?.click()}
                    >
                      <Upload className="w-4 h-4 mr-1" />
                      {previewSrc ? 'Remplacer la signature' : 'Choisir une image'}
                    </Button>
                    {pendingFile && (
                      <Button
                        type="button"
                        variant="ghost"
                        className="text-gray-500"
                        onClick={() => onFileChange(null)}
                      >
                        Annuler le fichier
                      </Button>
                    )}
                  </div>
                  <p className="text-xs text-gray-400 flex items-start gap-1.5">
                    <PenLine className="w-3.5 h-3.5 mt-0.5 shrink-0" />
                    PNG ou JPG — fond transparent recommandé. Enregistré sous{' '}
                    <code className="bg-white border px-1 rounded">
                      {'{teacherId}/signature.png'}
                    </code>
                    .
                  </p>
                </div>
              </div>

              <Button
                className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                disabled={saving || !teacherId}
                onClick={() => void handleSave()}
              >
                {saving && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
                Enregistrer
              </Button>
            </>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
