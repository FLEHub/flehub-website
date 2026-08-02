import { notFound, redirect } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import { ArticleEditor, type ArticleEditorInitial } from '@/components/articles/article-editor'
import {
  getJournalistIdForProfile,
  type ArticleCategory,
  type ArticleStatus,
} from '@/lib/articles'
import { ArrowLeft } from 'lucide-react'

export const dynamic = 'force-dynamic'

type Props = { params: { id: string } }

export default async function EditArticlePage({ params }: Props) {
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
  if (!journalistId) redirect('/dashboard/journalist/articles')

  const [{ data: article }, { data: categories }] = await Promise.all([
    supabase
      .from('articles')
      .select(
        'id, title, slug, excerpt, content, cover_image_url, category_id, status, published_at'
      )
      .eq('id', id)
      .eq('journalist_id', journalistId)
      .maybeSingle(),
    supabase.from('article_categories').select('id, name, slug').order('name'),
  ])

  if (!article) notFound()

  const initial: ArticleEditorInitial = {
    id: article.id,
    title: article.title,
    slug: article.slug,
    excerpt: article.excerpt,
    content: article.content ?? '',
    cover_image_url: article.cover_image_url,
    category_id: article.category_id,
    status: article.status as ArticleStatus,
    published_at: article.published_at,
  }

  return (
    <div className="p-6 space-y-6 max-w-3xl mx-auto">
      <div>
        <Link
          href="/dashboard/journalist/articles"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-[#00A550] mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour aux articles
        </Link>
        <h1 className="text-2xl font-bold text-gray-900">Modifier l’article</h1>
        <p className="text-sm text-gray-500 mt-1">
          Statut actuel :{' '}
          {initial.status === 'published' ? 'publié' : 'brouillon'}
        </p>
      </div>
      <ArticleEditor
        initial={initial}
        categories={(categories ?? []) as ArticleCategory[]}
      />
    </div>
  )
}
