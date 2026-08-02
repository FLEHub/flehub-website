import type { SupabaseClient } from "@supabase/supabase-js";

export type ArticleStatus = "draft" | "published";

export type ArticleCategory = {
  id: string;
  name: string;
  slug: string;
};

export type ArticleListItem = {
  id: string;
  title: string;
  slug: string;
  excerpt: string | null;
  cover_image_url: string | null;
  status: ArticleStatus;
  published_at: string | null;
  created_at: string;
  updated_at: string;
  category_id: string | null;
  category: { id: string; name: string; slug: string } | null;
};

export type PublicArticle = {
  id: string;
  title: string;
  slug: string;
  excerpt: string | null;
  content: string;
  cover_image_url: string | null;
  published_at: string | null;
  category: { id: string; name: string; slug: string } | null;
  author_name: string;
};

/** Convertit un titre en slug kebab-case. */
export function slugifyTitle(title: string): string {
  const base = title
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .replace(/-{2,}/g, "-");

  return base || "article";
}

/**
 * Garantit un slug unique dans `articles`.
 * Si le slug existe déjà (hors `excludeId`), ajoute `-2`, `-3`, etc.
 */
export async function ensureUniqueSlug(
  supabase: SupabaseClient,
  title: string,
  excludeId?: string | null
): Promise<string> {
  const base = slugifyTitle(title);
  let candidate = base;
  let n = 2;

  for (;;) {
    let q = supabase.from("articles").select("id").eq("slug", candidate).limit(1);
    if (excludeId) q = q.neq("id", excludeId);
    const { data } = await q.maybeSingle();
    if (!data) return candidate;
    candidate = `${base}-${n}`;
    n += 1;
  }
}

export function formatArticleDate(iso: string | null | undefined): string {
  if (!iso) return "";
  try {
    return new Intl.DateTimeFormat("fr-FR", {
      day: "numeric",
      month: "long",
      year: "numeric",
    }).format(new Date(iso));
  } catch {
    return "";
  }
}

export async function getJournalistIdForProfile(
  supabase: SupabaseClient,
  profileId: string
): Promise<string | null> {
  const { data } = await supabase
    .from("journalists")
    .select("id")
    .eq("profile_id", profileId)
    .maybeSingle();
  return data?.id ?? null;
}
