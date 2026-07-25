'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import {
  getYoutubeEmbedUrl,
  isStorageContentType,
  MEDIA_BUCKET,
  type LessonContentType,
} from '@/lib/elearning-content';
import { Skeleton } from '@/components/ui/skeleton';
import { Button } from '@/components/ui/button';
import { ExternalLink, FileText } from 'lucide-react';

interface LessonContentViewProps {
  contentType: LessonContentType;
  content: string;
  className?: string;
}

export function LessonContentView({
  contentType,
  content,
  className = '',
}: LessonContentViewProps) {
  const supabase = createClient();
  const [signedUrl, setSignedUrl] = useState<string | null>(null);
  const [loadingMedia, setLoadingMedia] = useState(
    isStorageContentType(contentType) && !!content
  );

  useEffect(() => {
    let cancelled = false;

    async function loadSignedUrl() {
      if (!isStorageContentType(contentType) || !content) {
        setSignedUrl(null);
        setLoadingMedia(false);
        return;
      }

      setLoadingMedia(true);
      const { data } = await supabase.storage
        .from(MEDIA_BUCKET)
        .createSignedUrl(content, 3600);

      if (!cancelled) {
        setSignedUrl(data?.signedUrl ?? null);
        setLoadingMedia(false);
      }
    }

    loadSignedUrl();
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [contentType, content]);

  if (!content) {
    return (
      <p className={`text-sm text-gray-400 ${className}`}>Aucun contenu pour cette leçon</p>
    );
  }

  if (contentType === 'youtube') {
    const embed = getYoutubeEmbedUrl(content);
    if (!embed) {
      return (
        <p className={`text-sm text-red-500 ${className}`}>URL YouTube invalide</p>
      );
    }
    return (
      <div
        className={`relative w-full aspect-video rounded-lg overflow-hidden bg-black ${className}`}
      >
        <iframe
          src={embed}
          title="Vidéo YouTube"
          className="absolute inset-0 w-full h-full"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
        />
      </div>
    );
  }

  if (contentType === 'image') {
    if (loadingMedia) {
      return <Skeleton className={`w-full h-48 rounded-lg ${className}`} />;
    }
    if (!signedUrl) {
      return (
        <p className={`text-sm text-gray-400 ${className}`}>
          Impossible de charger l&apos;image
        </p>
      );
    }
    return (
      // eslint-disable-next-line @next/next/no-img-element
      <img
        src={signedUrl}
        alt="Contenu de la leçon"
        className={`w-full max-h-[480px] object-contain rounded-lg border border-gray-100 bg-gray-50 ${className}`}
      />
    );
  }

  if (contentType === 'audio') {
    if (loadingMedia) {
      return <Skeleton className={`w-full h-12 rounded-lg ${className}`} />;
    }
    if (!signedUrl) {
      return (
        <p className={`text-sm text-gray-400 ${className}`}>
          Impossible de charger l&apos;audio
        </p>
      );
    }
    return (
      <div
        className={`rounded-lg border border-gray-100 bg-gray-50 p-4 ${className}`}
      >
        <audio controls className="w-full" src={signedUrl}>
          Votre navigateur ne prend pas en charge l&apos;audio.
        </audio>
      </div>
    );
  }

  if (contentType === 'pdf') {
    if (loadingMedia) {
      return <Skeleton className={`w-full h-64 rounded-lg ${className}`} />;
    }
    if (!signedUrl) {
      return (
        <p className={`text-sm text-gray-400 ${className}`}>
          Impossible de charger le PDF
        </p>
      );
    }
    return (
      <div className={`space-y-3 ${className}`}>
        <div className="w-full h-[420px] rounded-lg overflow-hidden border border-gray-100 bg-gray-50">
          <iframe
            src={signedUrl}
            title="Aperçu PDF"
            className="w-full h-full"
          />
        </div>
        <Button asChild variant="outline" size="sm" className="gap-1">
          <a href={signedUrl} target="_blank" rel="noopener noreferrer">
            <FileText className="w-3.5 h-3.5" />
            Voir le PDF
            <ExternalLink className="w-3 h-3" />
          </a>
        </Button>
      </div>
    );
  }

  return (
    <div
      className={`rounded-lg border border-gray-100 bg-gray-50 p-4 text-sm text-gray-800 whitespace-pre-wrap leading-relaxed ${className}`}
    >
      {content}
    </div>
  );
}
