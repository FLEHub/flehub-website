import { redirect } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import { VideoEditor } from '@/components/videos/video-editor'
import type { ArticleCategory } from '@/lib/articles'
import { ArrowLeft } from 'lucide-react'

export const dynamic = 'force-dynamic'

export default async function NewVideoPage() {
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
          href="/dashboard/journalist/videos"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-[#00A550] mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour aux vidéos
        </Link>
        <h1 className="text-2xl font-bold text-gray-900">Nouvelle vidéo</h1>
        <p className="text-sm text-gray-500 mt-1">
          Ajoutez une vidéo YouTube en brouillon ou publiez-la sur le portail.
        </p>
      </div>
      <VideoEditor categories={(categories ?? []) as ArticleCategory[]} />
    </div>
  )
}
