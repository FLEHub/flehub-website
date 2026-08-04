import { notFound, redirect } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import {
  ReportageEditor,
  type ReportageEditorInitial,
} from '@/components/reportages/reportage-editor'
import {
  getJournalistIdForProfile,
  type ArticleCategory,
} from '@/lib/articles'
import type { ReportageStatus } from '@/lib/reportages'
import { ArrowLeft } from 'lucide-react'

export const dynamic = 'force-dynamic'

type Props = { params: { id: string } }

export default async function EditReportagePage({ params }: Props) {
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
  if (!journalistId) redirect('/dashboard/journalist/reportages')

  const [{ data: reportage }, { data: categories }] = await Promise.all([
    supabase
      .from('reportages')
      .select(
        'id, title, slug, description, audio_url, cover_image_url, category_id, status, published_at'
      )
      .eq('id', id)
      .eq('journalist_id', journalistId)
      .maybeSingle(),
    supabase.from('article_categories').select('id, name, slug').order('name'),
  ])

  if (!reportage) notFound()

  const initial: ReportageEditorInitial = {
    id: reportage.id,
    title: reportage.title,
    slug: reportage.slug,
    description: reportage.description,
    audio_url: reportage.audio_url,
    cover_image_url: reportage.cover_image_url,
    category_id: reportage.category_id,
    status: reportage.status as ReportageStatus,
    published_at: reportage.published_at,
  }

  return (
    <div className="p-6 space-y-6 max-w-3xl mx-auto">
      <div>
        <Link
          href="/dashboard/journalist/reportages"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-[#00A550] mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour aux reportages
        </Link>
        <h1 className="text-2xl font-bold text-gray-900">Modifier le reportage</h1>
        <p className="text-sm text-gray-500 mt-1">
          Statut actuel :{' '}
          {initial.status === 'published' ? 'publié' : 'brouillon'}
        </p>
      </div>
      <ReportageEditor
        initial={initial}
        categories={(categories ?? []) as ArticleCategory[]}
      />
    </div>
  )
}
