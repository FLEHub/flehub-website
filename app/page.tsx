import Link from 'next/link'
import { GraduationCap, ArrowRight } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import {
  normalizeOrgBranding,
  DEFAULT_ORG_SHORT_NAME,
  DEFAULT_ORG_TAGLINE,
} from '@/lib/org-branding'
import { BrandMark } from '@/components/brand-mark'
import { PortalHeader } from '@/components/portal/portal-header'
import { ArticleCardLink } from '@/components/portal/article-card-link'
import { PartnersSection } from '@/components/portal/partners-section'
import type { Partner } from '@/lib/partners'

export const dynamic = 'force-dynamic'

export default async function HomePage() {
  let branding = normalizeOrgBranding(null)
  let recent: {
    id: string
    title: string
    slug: string
    excerpt: string | null
    cover_image_url: string | null
    published_at: string | null
    category_name: string | null
  }[] = []
  let partners: Partner[] = []

  try {
    const supabase = await createClient()
    const { data } = await supabase
      .from('org_settings')
      .select('org_name, org_short_name, org_tagline')
      .limit(1)
      .maybeSingle()
    branding = normalizeOrgBranding(data)

    const { data: articles } = await supabase
      .from('articles')
      .select(
        'id, title, slug, excerpt, cover_image_url, published_at, category:article_categories(id, name, slug)'
      )
      .eq('status', 'published')
      .order('published_at', { ascending: false })
      .limit(4)

    recent = (articles ?? []).map((row) => {
      const cat = row.category as
        | { id: string; name: string; slug: string }
        | { id: string; name: string; slug: string }[]
        | null
      const category = Array.isArray(cat) ? cat[0] ?? null : cat
      return {
        id: row.id,
        title: row.title,
        slug: row.slug,
        excerpt: row.excerpt,
        cover_image_url: row.cover_image_url,
        published_at: row.published_at,
        category_name: category?.name ?? null,
      }
    })

    const { data: partnerRows } = await supabase
      .from('partners')
      .select('id, name, logo_url, website_url, sort_order, created_at, updated_at')
      .order('sort_order', { ascending: true })
      .order('created_at', { ascending: true })
    partners = (partnerRows ?? []) as Partner[]
  } catch {
    // Fallbacks already set.
  }

  const shortName = branding.orgShortName || DEFAULT_ORG_SHORT_NAME
  const tagline = branding.orgTagline || DEFAULT_ORG_TAGLINE

  return (
    <div className="min-h-screen flex flex-col bg-gradient-to-b from-[#E8F8F0] via-white to-gray-50">
      <PortalHeader shortName={shortName} tagline={tagline} active="home" />

      <main className="flex-1">
        <section className="max-w-5xl mx-auto px-6 pt-12 sm:pt-16 pb-8 text-center">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-[#00A550]/10 text-[#00A550] mb-5">
            <GraduationCap className="w-7 h-7" />
          </div>
          <BrandMark
            shortName={shortName}
            tagline={tagline}
            size="lg"
            align="center"
            className="[&>p:first-child]:text-4xl sm:[&>p:first-child]:text-5xl [&>p:first-child]:tracking-tight [&>p:last-child]:text-sm sm:[&>p:last-child]:text-base [&>p:last-child]:text-gray-600 [&>p:last-child]:mt-2"
          />
          <p className="mt-4 text-base sm:text-lg text-gray-600 leading-relaxed max-w-xl mx-auto">
            Portail actualités et accès à la plateforme e-learning.
          </p>
        </section>

        <section className="max-w-5xl mx-auto px-6 pb-14">
          <div className="flex items-end justify-between gap-4 mb-4">
            <h2 className="text-xl sm:text-2xl font-bold text-gray-900">
              Dernières actualités
            </h2>
            <Link
              href="/actualites"
              className="text-sm font-medium text-[#00A550] hover:underline inline-flex items-center gap-1"
            >
              Voir toutes les actualités
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>

          {recent.length === 0 ? (
            <p className="text-sm text-gray-500 py-10 text-center bg-white/70 rounded-2xl border border-dashed border-[#00A550]/25">
              Les articles publiés apparaîtront ici.
            </p>
          ) : (
            <div className="bg-white/80 rounded-2xl border border-gray-100 px-5 sm:px-8 py-2">
              {recent.map((article) => (
                <ArticleCardLink key={article.id} article={article} />
              ))}
            </div>
          )}

          <div className="flex flex-col sm:flex-row items-center justify-center gap-3 mt-10">
            <Link
              href="/app"
              className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl bg-[#00A550] hover:bg-[#008040] text-white font-semibold shadow-sm transition-colors"
            >
              Accéder à {shortName} App
              <ArrowRight className="w-4 h-4" />
            </Link>
            <Link
              href="/login"
              className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl border border-gray-200 bg-white text-gray-700 font-medium hover:border-[#00A550] hover:text-[#00A550] transition-colors"
            >
              Se connecter
            </Link>
          </div>
        </section>

        <PartnersSection partners={partners} />
      </main>

      <footer className="border-t border-gray-100 py-6 text-center text-xs text-gray-400">
        © {new Date().getFullYear()} {shortName} — {tagline}
      </footer>
    </div>
  )
}
