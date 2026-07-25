'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import {
  getYoutubeEmbedUrl,
  MEDIA_BUCKET,
  type LessonContentType,
} from '@/lib/elearning-content';
import { Skeleton } from '@/components/ui/skeleton';

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
  const [imageUrl, setImageUrl] = useState<string | null>(null);
  const [loadingImage, setLoadingImage] = useState(contentType === 'image' && !!content);

  useEffect(() => {
    let cancelled = false;

    async function loadImage() {
      if (contentType !== 'image' || !content) {
        setImageUrl(null);
        setLoadingImage(false);
        return;
      }

      setLoadingImage(true);
      const { data } = await supabase.storage
        .from(MEDIA_BUCKET)
        .createSignedUrl(content, 3600);

      if (!cancelled) {
        setImageUrl(data?.signedUrl ?? null);
        setLoadingImage(false);
      }
    }

    loadImage();
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
        <p className={`text-sm text-red-500 ${className}`}>
          URL YouTube invalide
        </p>
      );
    }
    return (
      <div className={`relative w-full aspect-video rounded-lg overflow-hidden bg-black ${className}`}>
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
    if (loadingImage) {
      return <Skeleton className={`w-full h-48 rounded-lg ${className}`} />;
    }
    if (!imageUrl) {
      return (
        <p className={`text-sm text-gray-400 ${className}`}>
          Impossible de charger l&apos;image
        </p>
      );
    }
    return (
      // eslint-disable-next-line @next/next/no-img-element
      <img
        src={imageUrl}
        alt="Contenu de la leçon"
        className={`w-full max-h-[480px] object-contain rounded-lg border border-gray-100 bg-gray-50 ${className}`}
      />
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
