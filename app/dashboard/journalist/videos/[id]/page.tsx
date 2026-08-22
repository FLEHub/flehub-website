import { notFound, redirect } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import { VideoEditor, type VideoEditorInitial } from '@/components/videos/video-editor'
import {
  getJournalistIdForProfile,
  type ArticleCategory,
} from '@/lib/articles'
import type { VideoStatus } from '@/lib/videos'
import { ArrowLeft } from 'lucide-react'

export const dynamic = 'force-dynamic'

type Props = { params: { id: string } }

export default async function EditVideoPage({ params }: Props) {
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

  if (!profile || profile.role !== 'journalist') redirect('/dashboard')
  if (profile.status === 'suspended' || profile.status === 'rejected') {
    redirect('/login?reason=account_inactive')
  }

  const journalistId = await getJournalistIdForProfile(supabase, user.id)
  if (!journalistId) redirect('/dashboard/journalist/videos')

  const [{ data: video }, { data: categories }] = await Promise.all([
    supabase
      .from('videos')
      .select(
        'id, title, slug, description, youtube_url, youtube_video_id, thumbnail_url, category_id, status, published_at'
      )
      .eq('id', id)
      .eq('journalist_id', journalistId)
      .maybeSingle(),
    supabase.from('article_categories').select('id, name, slug').order('name'),
  ])

  if (!video) notFound()

  const initial: VideoEditorInitial = {
    id: video.id,
    title: video.title,
    slug: video.slug,
    description: video.description,
    youtube_url: video.youtube_url,
    youtube_video_id: video.youtube_video_id,
    thumbnail_url: video.thumbnail_url,
    category_id: video.category_id,
    status: video.status as VideoStatus,
    published_at: video.published_at,
  }

  return (
    <div className="p-6 space-y-6 max-w-3xl mx-auto">
      <div>
        <Link
          href="/dashboard/journalist/videos"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-[#1E5FA8] mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour aux vidéos
        </Link>
        <h1 className="text-2xl font-bold text-gray-900">Modifier la vidéo</h1>
        <p className="text-sm text-gray-500 mt-1">
          Statut actuel :{' '}
          {initial.status === 'published' ? 'publié' : 'brouillon'}
        </p>
      </div>
      <VideoEditor
        initial={initial}
        categories={(categories ?? []) as ArticleCategory[]}
      />
    </div>
  )
}
