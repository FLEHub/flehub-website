import type { SupabaseClient } from "@supabase/supabase-js";
import { slugifyTitle, type ArticleCategory, type ArticleStatus } from "@/lib/articles";

export type ReportageStatus = ArticleStatus;
export type ReportageCategory = ArticleCategory;

export const REPORTAGE_AUDIO_BUCKET = "reportage-audio";

export const REPORTAGE_AUDIO_ACCEPT =
  "audio/mpeg,audio/mp3,audio/wav,audio/x-wav,audio/mp4,audio/m4a,audio/x-m4a,.mp3,.wav,.m4a";

export type ReportageListItem = {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  audio_url: string;
  cover_image_url: string | null;
  status: ReportageStatus;
  published_at: string | null;
  created_at: string;
  updated_at: string;
  category_id: string | null;
  category: { id: string; name: string; slug: string } | null;
};

export type PublicReportage = {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  audio_url: string;
  cover_image_url: string | null;
  published_at: string | null;
  category: { id: string; name: string; slug: string } | null;
  author_name: string;
};

/**
 * Garantit un slug unique dans `reportages`.
 * Même logique que pour les articles / vidéos (`-2`, `-3`, …).
 */
export async function ensureUniqueReportageSlug(
  supabase: SupabaseClient,
  title: string,
  excludeId?: string | null
): Promise<string> {
  const raw = slugifyTitle(title);
  const base = raw === "article" && !title.trim() ? "reportage" : raw;
  let candidate = base;
  let n = 2;

  for (;;) {
    let q = supabase.from("reportages").select("id").eq("slug", candidate).limit(1);
    if (excludeId) q = q.neq("id", excludeId);
    const { data } = await q.maybeSingle();
    if (!data) return candidate;
    candidate = `${base}-${n}`;
    n += 1;
  }
}
