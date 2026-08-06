import { redirect } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import { SeriesEditor } from '@/components/series/series-editor'
import type { ArticleCategory } from '@/lib/articles'
import { ArrowLeft } from 'lucide-react'

export const dynamic = 'force-dynamic'

export default async function NewSeriesPage() {
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

  const { data: categories } = await supabase
    .from('article_categories')
    .select('id, name, slug')
    .order('name')

  return (
    <div className="p-6 space-y-6 max-w-3xl mx-auto">
      <div>
        <Link
          href="/dashboard/creator/series"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-[#00A550] mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour aux séries
        </Link>
        <h1 className="text-2xl font-bold text-gray-900">Nouvelle série</h1>
        <p className="text-sm text-gray-500 mt-1">
          Choisissez web-série ou podcast, puis ajoutez des épisodes.
        </p>
      </div>
      <SeriesEditor categories={(categories ?? []) as ArticleCategory[]} />
    </div>
  )
}
