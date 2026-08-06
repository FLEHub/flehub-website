import { notFound, redirect } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import {
  GalleryEditor,
  type GalleryEditorInitial,
} from '@/components/galleries/gallery-editor'
import {
  getJournalistIdForProfile,
  type ArticleCategory,
} from '@/lib/articles'
import type { GalleryPhoto, GalleryStatus } from '@/lib/galleries'
import { ArrowLeft } from 'lucide-react'

export const dynamic = 'force-dynamic'

type Props = { params: { id: string } }

export default async function EditGalleryPage({ params }: Props) {
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
  if (!journalistId) redirect('/dashboard/journalist/galleries')

  const [{ data: gallery }, { data: categories }, { data: photoRows }] =
    await Promise.all([
      supabase
        .from('galleries')
        .select(
          'id, title, slug, description, cover_image_url, category_id, status, published_at'
        )
        .eq('id', id)
        .eq('journalist_id', journalistId)
        .maybeSingle(),
      supabase.from('article_categories').select('id, name, slug').order('name'),
      supabase
        .from('gallery_photos')
        .select('id, gallery_id, photo_url, caption, sort_order, created_at')
        .eq('gallery_id', id)
        .order('sort_order', { ascending: true }),
    ])

  if (!gallery) notFound()

  const initial: GalleryEditorInitial = {
    id: gallery.id,
    title: gallery.title,
    slug: gallery.slug,
    description: gallery.description,
    cover_image_url: gallery.cover_image_url,
    category_id: gallery.category_id,
    status: gallery.status as GalleryStatus,
    published_at: gallery.published_at,
    photos: (photoRows ?? []) as GalleryPhoto[],
  }

  return (
    <div className="p-6 space-y-6 max-w-3xl mx-auto">
      <div>
        <Link
          href="/dashboard/journalist/galleries"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-[#00A550] mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour aux galeries
        </Link>
        <h1 className="text-2xl font-bold text-gray-900">Modifier la galerie</h1>
        <p className="text-sm text-gray-500 mt-1">
          Statut actuel :{' '}
          {initial.status === 'published' ? 'publié' : 'brouillon'}
        </p>
      </div>
      <GalleryEditor
        initial={initial}
        categories={(categories ?? []) as ArticleCategory[]}
      />
    </div>
  )
}
