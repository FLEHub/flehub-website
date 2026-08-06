import { notFound, redirect } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import {
  SeriesEditor,
  type SeriesEditorInitial,
} from '@/components/series/series-editor'
import { EpisodeManager } from '@/components/series/episode-manager'
import {
  getCreatorIdForProfile,
  seriesTypeLabel,
  type SeriesEpisode,
  type SeriesStatus,
  type SeriesType,
} from '@/lib/series'
import type { ArticleCategory } from '@/lib/articles'
import { ArrowLeft } from 'lucide-react'

export const dynamic = 'force-dynamic'

type Props = { params: { id: string } }

export default async function EditSeriesPage({ params }: Props) {
  const { id } = params
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { data: profile } = await supabase
    .from('profiles')
    .select('role, status')
    .eq('id', user.id)
    .maybeSingle()

  if (!profile || profile.role !== 'creator') redirect('/dashboard')
  if (profile.status === 'suspended' || profile.status === 'rejected') {
    redirect('/login?reason=account_inactive')
  }

  const creatorId = await getCreatorIdForProfile(supabase, user.id)
  if (!creatorId) redirect('/dashboard/creator/series')

  const [{ data: seriesRow }, { data: categories }, { data: episodeRows }] =
    await Promise.all([
      supabase
        .from('series')
        .select(
          'id, type, title, slug, description, cover_image_url, category_id, status, published_at'
        )
        .eq('id', id)
        .eq('creator_id', creatorId)
        .maybeSingle(),
      supabase.from('article_categories').select('id, name, slug').order('name'),
      supabase
        .from('series_episodes')
        .select(
          'id, series_id, episode_number, title, description, youtube_url, youtube_video_id, thumbnail_url, audio_url, status, published_at, created_at, updated_at'
        )
        .eq('series_id', id)
        .order('episode_number', { ascending: true }),
    ])

  if (!seriesRow) notFound()

  const initial: SeriesEditorInitial = {
    id: seriesRow.id,
    type: seriesRow.type as SeriesType,
    title: seriesRow.title,
    slug: seriesRow.slug,
    description: seriesRow.description,
    cover_image_url: seriesRow.cover_image_url,
    category_id: seriesRow.category_id,
    status: seriesRow.status as SeriesStatus,
    published_at: seriesRow.published_at,
  }

  return (
    <div className="p-6 space-y-10 max-w-3xl mx-auto">
      <div>
        <Link
          href="/dashboard/creator/series"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-[#00A550] mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour aux séries
        </Link>
        <h1 className="text-2xl font-bold text-gray-900">Modifier la série</h1>
        <p className="text-sm text-gray-500 mt-1">
          {seriesTypeLabel(initial.type)} — statut :{' '}
          {initial.status === 'published' ? 'publié' : 'brouillon'}
        </p>
      </div>

      <SeriesEditor
        initial={initial}
        categories={(categories ?? []) as ArticleCategory[]}
        lockType
      />

      <div className="border-t border-gray-100 pt-8">
        <EpisodeManager
          seriesId={initial.id}
          seriesType={initial.type}
          initialEpisodes={(episodeRows ?? []) as SeriesEpisode[]}
        />
      </div>
    </div>
  )
}
