import type { SupabaseClient } from "@supabase/supabase-js";
import {
  slugifyTitle,
  type ArticleCategory,
  type ArticleStatus,
} from "@/lib/articles";
import {
  getYoutubeEmbedUrl,
  parseYoutubeLink,
  youtubeThumbnailUrl,
} from "@/lib/videos";

export type SeriesStatus = ArticleStatus;
export type EpisodeStatus = ArticleStatus;
export type SeriesType = "webseries" | "podcast";
export type SeriesCategory = ArticleCategory;

export const CREATOR_ASSETS_BUCKET = "creator-assets";
export const EPISODE_AUDIO_BUCKET = "episode-audio";

export const EPISODE_AUDIO_ACCEPT =
  "audio/mpeg,audio/mp3,audio/wav,audio/x-wav,audio/mp4,audio/m4a,audio/x-m4a,.mp3,.wav,.m4a";

export type SeriesListItem = {
  id: string;
  type: SeriesType;
  title: string;
  slug: string;
  description: string | null;
  cover_image_url: string | null;
  status: SeriesStatus;
  published_at: string | null;
  created_at: string;
  updated_at: string;
  category_id: string | null;
  category: { id: string; name: string; slug: string } | null;
  episode_count?: number;
};

export type SeriesEpisode = {
  id: string;
  series_id: string;
  episode_number: number;
  title: string;
  description: string | null;
  youtube_url: string | null;
  youtube_video_id: string | null;
  thumbnail_url: string | null;
  audio_url: string | null;
  status: EpisodeStatus;
  published_at: string | null;
  created_at?: string;
  updated_at?: string;
};

export async function getCreatorIdForProfile(
  supabase: SupabaseClient,
  profileId: string
): Promise<string | null> {
  const { data } = await supabase
    .from("creators")
    .select("id")
    .eq("profile_id", profileId)
    .maybeSingle();
  return data?.id ?? null;
}

/**
 * Garantit un slug unique dans `series`.
 */
export async function ensureUniqueSeriesSlug(
  supabase: SupabaseClient,
  title: string,
  excludeId?: string | null
): Promise<string> {
  const raw = slugifyTitle(title);
  const base = raw === "article" && !title.trim() ? "serie" : raw;
  let candidate = base;
  let n = 2;

  for (;;) {
    let q = supabase.from("series").select("id").eq("slug", candidate).limit(1);
    if (excludeId) q = q.neq("id", excludeId);
    const { data } = await q.maybeSingle();
    if (!data) return candidate;
    candidate = `${base}-${n}`;
    n += 1;
  }
}

export function seriesTypeLabel(type: SeriesType): string {
  return type === "webseries" ? "Web-série" : "Podcast";
}

export function seriesPublicBasePath(type: SeriesType): string {
  return type === "webseries" ? "/webseries" : "/podcasts";
}

export { parseYoutubeLink, youtubeThumbnailUrl, getYoutubeEmbedUrl };
