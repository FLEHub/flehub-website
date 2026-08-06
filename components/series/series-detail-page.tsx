import Link from 'next/link'
import { notFound } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import {
  normalizeOrgBranding,
  DEFAULT_ORG_SHORT_NAME,
  DEFAULT_ORG_TAGLINE,
} from '@/lib/org-branding'
import { PortalHeader } from '@/components/portal/portal-header'
import { SeriesEpisodePlayer } from '@/components/series/series-episode-player'
import { formatArticleDate } from '@/lib/articles'
import type { SeriesEpisode, SeriesType } from '@/lib/series'
import { ArrowLeft } from 'lucide-react'

type Props = {
  slug: string
  expectedType: SeriesType
  listHref: string
  listLabel: string
  active: 'webseries' | 'podcasts'
}

export async function SeriesDetailPageForType({
  slug,
  expectedType,
  listHref,
  listLabel,
  active,
}: Props) {
  const supabase = await createClient()

  let branding = normalizeOrgBranding(null)
  try {
    const { data: org } = await supabase
      .from('org_settings')
      .select('org_name, org_short_name, org_tagline')
      .limit(1)
      .maybeSingle()
    branding = normalizeOrgBranding(org)
  } catch {
    // fallbacks
  }

  const shortName = branding.orgShortName || DEFAULT_ORG_SHORT_NAME
  const tagline = branding.orgTagline || DEFAULT_ORG_TAGLINE

  const { data: seriesRow } = await supabase
    .from('series')
    .select(
      `
      id,
      type,
      title,
      slug,
      description,
      cover_image_url,
      published_at,
      creator_id,
      category:article_categories(id, name, slug)
    `
    )
    .eq('slug', slug)
    .eq('status', 'published')
    .eq('type', expectedType)
    .maybeSingle()

  if (!seriesRow) notFound()

  const cat = seriesRow.category as
    | { id: string; name: string; slug: string }
    | { id: string; name: string; slug: string }[]
    | null
  const category = Array.isArray(cat) ? cat[0] ?? null : cat

  const { data: episodeRows } = await supabase
    .from('series_episodes')
    .select(
      'id, series_id, episode_number, title, description, youtube_url, youtube_video_id, thumbnail_url, audio_url, status, published_at'
    )
    .eq('series_id', seriesRow.id)
    .eq('status', 'published')
    .order('episode_number', { ascending: true })

  const episodes = (episodeRows ?? []) as SeriesEpisode[]

  let authorName = 'Créateur MFK'
  const { data: creator } = await supabase
    .from('creators')
    .select('profile_id')
    .eq('id', seriesRow.creator_id)
    .maybeSingle()
  if (creator?.profile_id) {
    const { data: authorProfile } = await supabase
      .from('profiles')
      .select('full_name')
      .eq('id', creator.profile_id)
      .maybeSingle()
    if (authorProfile?.full_name?.trim()) {
      authorName = authorProfile.full_name.trim()
    }
  }

  return (
    <div className="min-h-screen flex flex-col bg-gradient-to-b from-[#E8F8F0] via-white to-gray-50">
      <PortalHeader shortName={shortName} tagline={tagline} active={active} />

      <main className="flex-1 max-w-3xl w-full mx-auto px-6 py-10 sm:py-14">
        <Link
          href={listHref}
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-[#00A550] mb-6"
        >
          <ArrowLeft className="w-4 h-4" />
          {listLabel}
        </Link>

        <article className="space-y-8">
          <header className="space-y-3">
            <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-sm text-gray-500">
              {category && (
                <Link
                  href={`${listHref}?categorie=${category.slug}`}
                  className="text-[#00A550] font-medium hover:underline"
                >
                  {category.name}
                </Link>
              )}
              {seriesRow.published_at && (
                <time dateTime={seriesRow.published_at}>
                  {formatArticleDate(seriesRow.published_at)}
                </time>
              )}
              <span>
                {episodes.length} épisode{episodes.length > 1 ? 's' : ''}
              </span>
            </div>
            <h1 className="text-3xl sm:text-4xl font-extrabold text-gray-900 tracking-tight leading-tight">
              {seriesRow.title}
            </h1>
            <p className="text-sm text-gray-600">
              Par <span className="font-medium text-gray-800">{authorName}</span>
            </p>
            {seriesRow.description && (
              <p className="text-base text-gray-700 leading-relaxed whitespace-pre-wrap">
                {seriesRow.description}
              </p>
            )}
          </header>

          {seriesRow.cover_image_url && (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={seriesRow.cover_image_url}
              alt=""
              className="w-full max-h-[360px] object-cover rounded-xl"
            />
          )}

          <SeriesEpisodePlayer
            seriesType={seriesRow.type as SeriesType}
            episodes={episodes}
          />
        </article>
      </main>

      <footer className="border-t border-gray-100 py-6 text-center text-xs text-gray-400">
        © {new Date().getFullYear()} {shortName} — {tagline}
      </footer>
    </div>
  )
}
