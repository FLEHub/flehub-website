import type { SupabaseClient } from "@supabase/supabase-js";
import { slugifyTitle, type ArticleCategory, type ArticleStatus } from "@/lib/articles";
import { getYoutubeEmbedUrl, getYoutubeVideoId } from "@/lib/elearning-content";

export type VideoStatus = ArticleStatus;
export type VideoCategory = ArticleCategory;

export type VideoListItem = {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  youtube_url: string;
  youtube_video_id: string;
  thumbnail_url: string;
  status: VideoStatus;
  published_at: string | null;
  created_at: string;
  updated_at: string;
  category_id: string | null;
  category: { id: string; name: string; slug: string } | null;
};

export type PublicVideo = {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  youtube_video_id: string;
  thumbnail_url: string;
  published_at: string | null;
  category: { id: string; name: string; slug: string } | null;
  author_name: string;
};

/** Build the YouTube hqdefault thumbnail URL from a video id. */
export function youtubeThumbnailUrl(videoId: string): string {
  return `https://img.youtube.com/vi/${videoId}/hqdefault.jpg`;
}

/**
 * Parse a pasted YouTube link (or bare id) into video id + thumbnail URL.
 * Returns null if the input is not a valid YouTube reference.
 */
export function parseYoutubeLink(urlOrId: string): {
  videoId: string;
  thumbnailUrl: string;
  embedUrl: string;
} | null {
  const videoId = getYoutubeVideoId(urlOrId);
  if (!videoId) return null;
  const embedUrl = getYoutubeEmbedUrl(videoId);
  if (!embedUrl) return null;
  return {
    videoId,
    thumbnailUrl: youtubeThumbnailUrl(videoId),
    embedUrl,
  };
}

/**
 * Garantit un slug unique dans `videos`.
 * Même logique que pour les articles (`-2`, `-3`, …).
 */
export async function ensureUniqueVideoSlug(
  supabase: SupabaseClient,
  title: string,
  excludeId?: string | null
): Promise<string> {
  const raw = slugifyTitle(title);
  const base = raw === "article" && !title.trim() ? "video" : raw;
  let candidate = base;
  let n = 2;

  for (;;) {
    let q = supabase.from("videos").select("id").eq("slug", candidate).limit(1);
    if (excludeId) q = q.neq("id", excludeId);
    const { data } = await q.maybeSingle();
    if (!data) return candidate;
    candidate = `${base}-${n}`;
    n += 1;
  }
}

export { getYoutubeVideoId, getYoutubeEmbedUrl };
