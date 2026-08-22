import { redirect } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import { ArticleEditor } from '@/components/articles/article-editor'
import type { ArticleCategory } from '@/lib/articles'
import { ArrowLeft } from 'lucide-react'

export const dynamic = 'force-dynamic'

export default async function NewArticlePage() {
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

  const { data: categories } = await supabase
    .from('article_categories')
    .select('id, name, slug')
    .order('name')

  return (
    <div className="p-6 space-y-6 max-w-3xl mx-auto">
      <div>
        <Link
          href="/dashboard/journalist/articles"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-[#1E5FA8] mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour aux articles
        </Link>
        <h1 className="text-2xl font-bold text-gray-900">Nouvel article</h1>
        <p className="text-sm text-gray-500 mt-1">
          Rédigez un brouillon ou publiez directement sur le portail.
        </p>
      </div>
      <ArticleEditor categories={(categories ?? []) as ArticleCategory[]} />
    </div>
  )
}
