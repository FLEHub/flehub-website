import Link from 'next/link'
import { notFound } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import {
  normalizeOrgBranding,
  DEFAULT_ORG_SHORT_NAME,
  DEFAULT_ORG_TAGLINE,
} from '@/lib/org-branding'
import { PortalHeader } from '@/components/portal/portal-header'
import { PortalFooter } from '@/components/portal/portal-footer'
import { formatArticleDate } from '@/lib/articles'
import { ArrowLeft } from 'lucide-react'

export const dynamic = 'force-dynamic'

type Props = { params: { slug: string } }

export default async function ArticleDetailPage({ params }: Props) {
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

  const { data: article } = await supabase
    .from('articles')
    .select(
      `
      id,
      title,
      slug,
      excerpt,
      content,
      cover_image_url,
      published_at,
      journalist_id,
      category:article_categories(id, name, slug)
    `
    )
    .eq('slug', params.slug)
    .eq('status', 'published')
    .maybeSingle()

  if (!article) notFound()

  const cat = article.category as
    | { id: string; name: string; slug: string }
    | { id: string; name: string; slug: string }[]
    | null
  const category = Array.isArray(cat) ? cat[0] ?? null : cat

  let authorName = 'Journaliste MFK'
  const { data: journalist } = await supabase
    .from('journalists')
    .select('profile_id')
    .eq('id', article.journalist_id)
    .maybeSingle()
  if (journalist?.profile_id) {
    const { data: authorProfile } = await supabase
      .from('profiles')
      .select('full_name')
      .eq('id', journalist.profile_id)
      .maybeSingle()
    if (authorProfile?.full_name?.trim()) {
      authorName = authorProfile.full_name.trim()
    }
  }

  return (
    <div className="min-h-screen flex flex-col bg-gradient-to-b from-[#E8F1FA] via-white to-gray-50">
      <PortalHeader shortName={shortName} tagline={tagline} active="actualites" />

      <main className="flex-1 max-w-3xl w-full mx-auto px-6 py-10 sm:py-14">
        <Link
          href="/actualites"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-[#1E5FA8] mb-6"
        >
          <ArrowLeft className="w-4 h-4" />
          Toutes les actualités
        </Link>

        <article className="space-y-6">
          <header className="space-y-3">
            <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-sm text-gray-500">
              {category && (
                <Link
                  href={`/actualites?categorie=${category.slug}`}
                  className="text-[#1E5FA8] font-medium hover:underline"
                >
                  {category.name}
                </Link>
              )}
              {article.published_at && (
                <time dateTime={article.published_at}>
                  {formatArticleDate(article.published_at)}
                </time>
              )}
            </div>
            <h1 className="text-3xl sm:text-4xl font-extrabold text-gray-900 tracking-tight leading-tight">
              {article.title}
            </h1>
            <p className="text-sm text-gray-600">
              Par <span className="font-medium text-gray-800">{authorName}</span>
            </p>
          </header>

          {article.cover_image_url && (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={article.cover_image_url}
              alt=""
              className="w-full max-h-[420px] object-cover rounded-xl"
            />
          )}

          {article.excerpt && (
            <p className="text-lg text-gray-700 leading-relaxed border-l-4 border-[#1E5FA8] pl-4">
              {article.excerpt}
            </p>
          )}

          <div className="text-base text-gray-800 leading-relaxed whitespace-pre-wrap">
            {article.content || ''}
          </div>
        </article>
      </main>

      <PortalFooter shortName={shortName} tagline={tagline} />
    </div>
  )
}
