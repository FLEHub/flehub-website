import type { SupabaseClient } from '@supabase/supabase-js'
import { seriesPublicBasePath, type SeriesType } from '@/lib/series'

export type HomeContentKind =
  | 'article'
  | 'video'
  | 'reportage'
  | 'gallery'
  | 'webseries'
  | 'podcast'

export type HomeFeedItem = {
  id: string
  kind: HomeContentKind
  title: string
  slug: string
  href: string
  excerpt: string | null
  image_url: string | null
  category_name: string | null
  published_at: string | null
}

export const KIND_LABEL: Record<HomeContentKind, string> = {
  article: 'Article',
  video: 'Vidéo',
  reportage: 'Reportage',
  gallery: 'Galerie',
  webseries: 'Web-série',
  podcast: 'Podcast',
}

/** Badges vifs et distincts par type de contenu (vert MFK + accents). */
export const KIND_BADGE_CLASS: Record<HomeContentKind, string> = {
  article: 'bg-[#00A550] text-white',
  video: 'bg-[#1D7AFC] text-white',
  reportage: 'bg-[#F59E0B] text-gray-900',
  gallery: 'bg-[#F97316] text-white',
  webseries: 'bg-[#0EA5E9] text-white',
  podcast: 'bg-[#0D9488] text-white',
}

export const KIND_ACCENT_BORDER: Record<HomeContentKind, string> = {
  article: 'group-hover:border-[#00A550]',
  video: 'group-hover:border-[#1D7AFC]',
  reportage: 'group-hover:border-[#F59E0B]',
  gallery: 'group-hover:border-[#F97316]',
  webseries: 'group-hover:border-[#0EA5E9]',
  podcast: 'group-hover:border-[#0D9488]',
}

function categoryName(
  category:
    | { id: string; name: string; slug: string }
    | { id: string; name: string; slug: string }[]
    | null
    | undefined
): string | null {
  if (!category) return null
  const cat = Array.isArray(category) ? category[0] ?? null : category
  return cat?.name ?? null
}

function byPublishedDesc(a: HomeFeedItem, b: HomeFeedItem) {
  const ta = a.published_at ? new Date(a.published_at).getTime() : 0
  const tb = b.published_at ? new Date(b.published_at).getTime() : 0
  return tb - ta
}

export async function fetchHomeFeed(supabase: SupabaseClient): Promise<{
  hero: HomeFeedItem | null
  featured: HomeFeedItem[]
  articles: HomeFeedItem[]
  videos: HomeFeedItem[]
  reportages: HomeFeedItem[]
  series: HomeFeedItem[]
  galleries: HomeFeedItem[]
}> {
  const empty = {
    hero: null as HomeFeedItem | null,
    featured: [] as HomeFeedItem[],
    articles: [] as HomeFeedItem[],
    videos: [] as HomeFeedItem[],
    reportages: [] as HomeFeedItem[],
    series: [] as HomeFeedItem[],
    galleries: [] as HomeFeedItem[],
  }

  const [
    articlesRes,
    videosRes,
    reportagesRes,
    seriesRes,
    galleriesRes,
  ] = await Promise.all([
    supabase
      .from('articles')
      .select(
        'id, title, slug, excerpt, cover_image_url, published_at, category:article_categories(id, name, slug)'
      )
      .eq('status', 'published')
      .order('published_at', { ascending: false })
      .limit(12),
    supabase
      .from('videos')
      .select(
        'id, title, slug, description, thumbnail_url, published_at, category:article_categories(id, name, slug)'
      )
      .eq('status', 'published')
      .order('published_at', { ascending: false })
      .limit(8),
    supabase
      .from('reportages')
      .select(
        'id, title, slug, description, cover_image_url, published_at, category:article_categories(id, name, slug)'
      )
      .eq('status', 'published')
      .order('published_at', { ascending: false })
      .limit(8),
    supabase
      .from('series')
      .select(
        'id, type, title, slug, description, cover_image_url, published_at, category:article_categories(id, name, slug)'
      )
      .eq('status', 'published')
      .order('published_at', { ascending: false })
      .limit(8),
    supabase
      .from('galleries')
      .select(
        'id, title, slug, description, cover_image_url, published_at, category:article_categories(id, name, slug), gallery_photos(id)'
      )
      .eq('status', 'published')
      .order('published_at', { ascending: false })
      .limit(8),
  ])

  const articles: HomeFeedItem[] = (articlesRes.data ?? []).map((row) => ({
    id: row.id,
    kind: 'article' as const,
    title: row.title,
    slug: row.slug,
    href: `/actualites/${row.slug}`,
    excerpt: row.excerpt,
    image_url: row.cover_image_url,
    category_name: categoryName(row.category as never),
    published_at: row.published_at,
  }))

  const videos: HomeFeedItem[] = (videosRes.data ?? []).map((row) => ({
    id: row.id,
    kind: 'video' as const,
    title: row.title,
    slug: row.slug,
    href: `/videos/${row.slug}`,
    excerpt: row.description,
    image_url: row.thumbnail_url,
    category_name: categoryName(row.category as never),
    published_at: row.published_at,
  }))

  const reportages: HomeFeedItem[] = (reportagesRes.data ?? []).map((row) => ({
    id: row.id,
    kind: 'reportage' as const,
    title: row.title,
    slug: row.slug,
    href: `/reportages/${row.slug}`,
    excerpt: row.description,
    image_url: row.cover_image_url,
    category_name: categoryName(row.category as never),
    published_at: row.published_at,
  }))

  const series: HomeFeedItem[] = (seriesRes.data ?? []).map((row) => {
    const type = row.type as SeriesType
    const kind: HomeContentKind =
      type === 'podcast' ? 'podcast' : 'webseries'
    return {
      id: row.id,
      kind,
      title: row.title,
      slug: row.slug,
      href: `${seriesPublicBasePath(type)}/${row.slug}`,
      excerpt: row.description,
      image_url: row.cover_image_url,
      category_name: categoryName(row.category as never),
      published_at: row.published_at,
    }
  })

  const galleries: HomeFeedItem[] = (galleriesRes.data ?? []).map((row) => ({
    id: row.id,
    kind: 'gallery' as const,
    title: row.title,
    slug: row.slug,
    href: `/galeries/${row.slug}`,
    excerpt: row.description,
    image_url: row.cover_image_url,
    category_name: categoryName(row.category as never),
    published_at: row.published_at,
  }))

  // Hero + À la une: mix articles / vidéos / reportages only
  const mixed = [...articles, ...videos, ...reportages].sort(byPublishedDesc)
  const hero = mixed[0] ?? null
  const featured = mixed.slice(1, 7)

  // Articles list excludes the hero if it was an article, to reduce duplication
  const articleList = articles
    .filter((a) => !(hero?.kind === 'article' && hero.id === a.id))
    .slice(0, 8)

  const videoList = videos
    .filter((v) => !(hero?.kind === 'video' && hero.id === v.id))
    .slice(0, 6)

  const reportageList = reportages
    .filter((r) => !(hero?.kind === 'reportage' && hero.id === r.id))
    .slice(0, 6)

  if (
    articlesRes.error ||
    videosRes.error ||
    reportagesRes.error ||
    seriesRes.error ||
    galleriesRes.error
  ) {
    // Partial data still OK; surface what we have
  }

  return {
    hero,
    featured,
    articles: articleList.length > 0 ? articleList : empty.articles,
    videos: videoList,
    reportages: reportageList,
    series: series.slice(0, 6),
    galleries: galleries.slice(0, 6),
  }
}
