import type { SupabaseClient } from "@supabase/supabase-js";
import { slugifyTitle, type ArticleCategory, type ArticleStatus } from "@/lib/articles";

export type GalleryStatus = ArticleStatus;
export type GalleryCategory = ArticleCategory;

export const GALLERY_PHOTOS_BUCKET = "gallery-photos";

export const GALLERY_PHOTO_ACCEPT =
  "image/jpeg,image/jpg,image/png,image/webp,image/gif,.jpg,.jpeg,.png,.webp,.gif";

export type GalleryPhoto = {
  id: string;
  gallery_id: string;
  photo_url: string;
  caption: string | null;
  sort_order: number;
  created_at?: string;
};

export type GalleryListItem = {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  cover_image_url: string | null;
  status: GalleryStatus;
  published_at: string | null;
  created_at: string;
  updated_at: string;
  category_id: string | null;
  category: { id: string; name: string; slug: string } | null;
  photo_count?: number;
};

export type PublicGallery = {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  cover_image_url: string | null;
  published_at: string | null;
  category: { id: string; name: string; slug: string } | null;
  author_name: string;
  photos: GalleryPhoto[];
};

/**
 * Garantit un slug unique dans `galleries`.
 * Même logique que pour les articles / vidéos / reportages (`-2`, `-3`, …).
 */
export async function ensureUniqueGallerySlug(
  supabase: SupabaseClient,
  title: string,
  excludeId?: string | null
): Promise<string> {
  const raw = slugifyTitle(title);
  const base = raw === "article" && !title.trim() ? "galerie" : raw;
  let candidate = base;
  let n = 2;

  for (;;) {
    let q = supabase.from("galleries").select("id").eq("slug", candidate).limit(1);
    if (excludeId) q = q.neq("id", excludeId);
    const { data } = await q.maybeSingle();
    if (!data) return candidate;
    candidate = `${base}-${n}`;
    n += 1;
  }
}

/** Extrait le chemin storage depuis une URL publique gallery-photos (si possible). */
export function galleryPhotoStoragePath(publicUrl: string): string | null {
  const marker = `/storage/v1/object/public/${GALLERY_PHOTOS_BUCKET}/`;
  const idx = publicUrl.indexOf(marker);
  if (idx === -1) return null;
  const path = publicUrl.slice(idx + marker.length).split("?")[0];
  return path || null;
}
