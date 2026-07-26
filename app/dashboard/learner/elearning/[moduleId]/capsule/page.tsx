'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import {
  ArrowLeft,
  CheckCircle2,
  Loader2,
  Upload,
  Video,
} from 'lucide-react';
import { createClient } from '@/lib/supabase/client';
import { getCurrentLearnerId } from '@/lib/learner-session';
import { MEDIA_BUCKET } from '@/lib/elearning-content';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';

type CapsuleRow = {
  id: string;
  content: string;
  validated: boolean;
  submitted_at: string | null;
  validated_at: string | null;
};

export default function LearnerCapsulePage() {
  const params = useParams();
  const moduleId = params.moduleId as string;
  const supabase = useMemo(() => createClient(), []);

  const [learnerId, setLearnerId] = useState<string | null>(null);
  const [moduleTitle, setModuleTitle] = useState('');
  const [capsule, setCapsule] = useState<CapsuleRow | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [file, setFile] = useState<File | null>(null);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [enrolled, setEnrolled] = useState(false);

  const loadPreview = useCallback(
    async (path: string) => {
      if (!path) {
        setPreviewUrl(null);
        return;
      }
      const { data } = await supabase.storage
        .from(MEDIA_BUCKET)
        .createSignedUrl(path, 3600);
      setPreviewUrl(data?.signedUrl ?? null);
    },
    [supabase]
  );

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const lid = await getCurrentLearnerId(supabase);
      if (!lid) {
        setError('Profil apprenant introuvable.');
        return;
      }
      setLearnerId(lid);

      const { data: mod } = await supabase
        .from('elearning_modules')
        .select('id, title')
        .eq('id', moduleId)
        .maybeSingle();
      setModuleTitle(mod?.title ?? 'Module');

      const { data: enrollment } = await supabase
        .from('elearning_enrollments')
        .select('id')
        .eq('learner_id', lid)
        .eq('module_id', moduleId)
        .maybeSingle();

      if (!enrollment) {
        setEnrolled(false);
        setError("Vous n'êtes pas inscrit à ce module.");
        return;
      }
      setEnrolled(true);

      const { data: cap } = await supabase
        .from('elearning_capsules')
        .select('id, content, validated, submitted_at, validated_at')
        .eq('learner_id', lid)
        .eq('module_id', moduleId)
        .maybeSingle();

      setCapsule((cap as CapsuleRow) ?? null);
      if (cap?.content) await loadPreview(cap.content);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur de chargement');
    } finally {
      setLoading(false);
    }
  }, [moduleId, supabase, loadPreview]);

  useEffect(() => {
    void load();
  }, [load]);

  async function uploadCapsule() {
    if (!learnerId || !file) return;
    setUploading(true);
    setError(null);
    try {
      const ext = file.name.split('.').pop()?.toLowerCase() || 'mp4';
      const path = `capsules/${learnerId}/${moduleId}/${Date.now()}.${ext}`;

      const { error: upErr } = await supabase.storage
        .from(MEDIA_BUCKET)
        .upload(path, file, {
          upsert: true,
          contentType: file.type || undefined,
        });
      if (upErr) throw upErr;

      if (capsule?.content && capsule.content !== path) {
        await supabase.storage.from(MEDIA_BUCKET).remove([capsule.content]);
      }

      const payload = {
        module_id: moduleId,
        learner_id: learnerId,
        content: path,
        validated: false,
        submitted_at: new Date().toISOString(),
        validated_at: null as string | null,
      };

      if (capsule?.id) {
        const { data, error: updErr } = await supabase
          .from('elearning_capsules')
          .update(payload)
          .eq('id', capsule.id)
          .select('id, content, validated, submitted_at, validated_at')
          .single();
        if (updErr) throw updErr;
        setCapsule(data as CapsuleRow);
      } else {
        const { data, error: insErr } = await supabase
          .from('elearning_capsules')
          .insert(payload)
          .select('id, content, validated, submitted_at, validated_at')
          .single();
        if (insErr) throw insErr;
        setCapsule(data as CapsuleRow);
      }

      setFile(null);
      await loadPreview(path);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Échec de l'upload");
    } finally {
      setUploading(false);
    }
  }

  if (loading) {
    return (
      <div className="space-y-6 p-6 max-w-3xl mx-auto">
        <Skeleton className="h-8 w-64" />
        <Skeleton className="h-64 w-full" />
      </div>
    );
  }

  if (!enrolled) {
    return (
      <div className="space-y-4 p-6 max-w-3xl mx-auto">
        <p className="text-destructive">{error ?? 'Accès refusé'}</p>
        <Button variant="outline" asChild>
          <Link href="/dashboard/learner/elearning">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Retour
          </Link>
        </Button>
      </div>
    );
  }

  return (
    <div className="space-y-6 p-6 max-w-3xl mx-auto">
      <div className="space-y-2">
        <Button variant="ghost" size="sm" className="-ml-2" asChild>
          <Link href={`/dashboard/learner/elearning/${moduleId}`}>
            <ArrowLeft className="mr-1 h-4 w-4" />
            Retour au module
          </Link>
        </Button>
        <div className="flex flex-wrap items-center gap-2">
          <h1 className="text-2xl font-bold text-gray-900">Capsule vidéo</h1>
          {capsule?.validated ? (
            <Badge className="bg-flehub-green hover:bg-flehub-green">
              Validée
            </Badge>
          ) : capsule ? (
            <Badge variant="secondary">En attente de validation</Badge>
          ) : null}
        </div>
        <p className="text-sm text-muted-foreground">
          Production finale pour « {moduleTitle} »
        </p>
      </div>

      {error && (
        <div className="rounded-lg border border-destructive/30 bg-destructive/5 px-4 py-3 text-sm text-destructive">
          {error}
        </div>
      )}

      <Card>
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <Video className="h-4 w-4 text-flehub-green" />
            Votre vidéo
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {previewUrl ? (
            <video
              src={previewUrl}
              controls
              className="w-full rounded-lg border bg-black max-h-[420px]"
            />
          ) : (
            <div className="flex flex-col items-center justify-center py-12 text-gray-400 border border-dashed rounded-xl">
              <Video className="w-10 h-10 mb-2 opacity-40" />
              <p className="text-sm">Aucune vidéo déposée</p>
            </div>
          )}

          {capsule?.validated ? (
            <div className="flex items-center gap-2 text-sm text-flehub-green">
              <CheckCircle2 className="h-4 w-4" />
              Capsule validée
              {capsule.validated_at
                ? ` le ${new Date(capsule.validated_at).toLocaleDateString('fr-FR')}`
                : ''}
            </div>
          ) : (
            <div className="space-y-3">
              <input
                type="file"
                accept="video/mp4,video/webm,video/quicktime"
                onChange={(e) => setFile(e.target.files?.[0] ?? null)}
              />
              <p className="text-xs text-muted-foreground">
                Formats acceptés : MP4, WebM, MOV (max. 100 Mo)
              </p>
              <Button
                className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                disabled={!file || uploading}
                onClick={() => void uploadCapsule()}
              >
                {uploading ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                ) : (
                  <Upload className="mr-2 h-4 w-4" />
                )}
                {capsule ? 'Remplacer la vidéo' : 'Déposer la capsule'}
              </Button>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
