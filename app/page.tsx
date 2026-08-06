import Link from 'next/link'
import { ArrowRight } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import {
  normalizeOrgBranding,
  DEFAULT_ORG_SHORT_NAME,
  DEFAULT_ORG_TAGLINE,
} from '@/lib/org-branding'
import { PortalHeader } from '@/components/portal/portal-header'
import { PartnersSection } from '@/components/portal/partners-section'
import { HomeHero } from '@/components/portal/home-hero'
import { HomeContentCard } from '@/components/portal/home-content-card'
import { HomeSection } from '@/components/portal/home-section'
import { fetchHomeFeed } from '@/lib/home-feed'
import type { Partner } from '@/lib/partners'

export const dynamic = 'force-dynamic'

export default async function HomePage() {
  let branding = normalizeOrgBranding(null)
  let partners: Partner[] = []
  let feed = {
    hero: null as Awaited<ReturnType<typeof fetchHomeFeed>>['hero'],
    featured: [] as Awaited<ReturnType<typeof fetchHomeFeed>>['featured'],
    articles: [] as Awaited<ReturnType<typeof fetchHomeFeed>>['articles'],
    videos: [] as Awaited<ReturnType<typeof fetchHomeFeed>>['videos'],
    reportages: [] as Awaited<ReturnType<typeof fetchHomeFeed>>['reportages'],
    series: [] as Awaited<ReturnType<typeof fetchHomeFeed>>['series'],
    galleries: [] as Awaited<ReturnType<typeof fetchHomeFeed>>['galleries'],
  }

  try {
    const supabase = await createClient()
    const { data } = await supabase
      .from('org_settings')
      .select('org_name, org_short_name, org_tagline')
      .limit(1)
      .maybeSingle()
    branding = normalizeOrgBranding(data)

    feed = await fetchHomeFeed(supabase)

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

  const hasAnyContent =
    feed.hero ||
    feed.featured.length > 0 ||
    feed.articles.length > 0 ||
    feed.videos.length > 0 ||
    feed.reportages.length > 0 ||
    feed.series.length > 0 ||
    feed.galleries.length > 0

  return (
    <div className="min-h-screen flex flex-col bg-white">
      <PortalHeader
        shortName={shortName}
        tagline={tagline}
        active="home"
        showAppCta
      />

      <main className="flex-1">
        {feed.hero ? (
          <HomeHero item={feed.hero} />
        ) : (
          <section className="bg-gradient-to-br from-[#E8F8F0] via-white to-gray-50 border-b border-gray-100">
            <div className="max-w-5xl mx-auto px-6 py-16 sm:py-20 text-center space-y-3">
              <p className="text-sm font-semibold uppercase tracking-wide text-[#00A550]">
                {shortName}
              </p>
              <h1 className="text-3xl sm:text-4xl font-extrabold text-gray-900 tracking-tight">
                Portail actualités
              </h1>
              <p className="text-gray-600 max-w-xl mx-auto">
                Les contenus publiés apparaîtront ici dès qu’ils seront en ligne.
              </p>
            </div>
          </section>
        )}

        {/* App CTA strip */}
        <section className="border-b border-gray-100 bg-[#E6F5EE]/60">
          <div className="max-w-5xl mx-auto px-6 py-4 flex flex-col sm:flex-row items-center justify-between gap-3">
            <p className="text-sm text-gray-700 text-center sm:text-left">
              Accédez à la plateforme e-learning et aux services {shortName}.
            </p>
            <div className="flex items-center gap-2">
              <Link
                href="/app"
                className="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-[#00A550] hover:bg-[#008040] text-white text-sm font-semibold transition-colors"
              >
                Accéder à {shortName} App
                <ArrowRight className="w-4 h-4" />
              </Link>
              <Link
                href="/login"
                className="inline-flex items-center px-4 py-2 rounded-lg border border-gray-200 bg-white text-gray-700 text-sm font-medium hover:border-[#00A550] hover:text-[#00A550] transition-colors"
              >
                Se connecter
              </Link>
            </div>
          </div>
        </section>

        {!hasAnyContent && (
          <p className="max-w-5xl mx-auto px-6 py-16 text-center text-sm text-gray-500">
            Aucun contenu publié pour le moment.
          </p>
        )}

        {feed.featured.length > 0 && (
          <HomeSection title="À la une">
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 sm:gap-7">
              {feed.featured.map((item) => (
                <HomeContentCard key={`${item.kind}-${item.id}`} item={item} />
              ))}
            </div>
          </HomeSection>
        )}

        {feed.articles.length > 0 && (
          <HomeSection
            title="Dernières actualités"
            href="/actualites"
            linkLabel="Voir toutes les actualités"
            className="bg-gradient-to-b from-gray-50/80 to-white"
          >
            <div className="bg-white border-y border-gray-100 sm:border sm:rounded-xl overflow-hidden px-4 sm:px-6">
              {feed.articles.map((item) => (
                <HomeContentCard
                  key={item.id}
                  item={item}
                  variant="list"
                />
              ))}
            </div>
          </HomeSection>
        )}

        {feed.videos.length > 0 && (
          <HomeSection
            title="Vidéos à la une"
            href="/videos"
            linkLabel="Voir toutes les vidéos"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {feed.videos.map((item) => (
                <HomeContentCard key={item.id} item={item} />
              ))}
            </div>
          </HomeSection>
        )}

        {feed.reportages.length > 0 && (
          <HomeSection
            title="Reportages"
            href="/reportages"
            linkLabel="Voir tous les reportages"
            className="bg-gradient-to-b from-[#E8F8F0]/40 to-white"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {feed.reportages.map((item) => (
                <HomeContentCard key={item.id} item={item} />
              ))}
            </div>
          </HomeSection>
        )}

        {feed.series.length > 0 && (
          <HomeSection title="Web-séries & Podcasts">
            <div className="flex flex-wrap gap-3 mb-6 -mt-2">
              <Link
                href="/webseries"
                className="text-sm font-medium text-[#00A550] hover:underline inline-flex items-center gap-1"
              >
                Voir les web-séries
                <ArrowRight className="w-3.5 h-3.5" />
              </Link>
              <span className="text-gray-300">·</span>
              <Link
                href="/podcasts"
                className="text-sm font-medium text-[#00A550] hover:underline inline-flex items-center gap-1"
              >
                Voir les podcasts
                <ArrowRight className="w-3.5 h-3.5" />
              </Link>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {feed.series.map((item) => (
                <HomeContentCard key={item.id} item={item} />
              ))}
            </div>
          </HomeSection>
        )}

        {feed.galleries.length > 0 && (
          <HomeSection
            title="Galerie photo"
            href="/galeries"
            linkLabel="Voir toutes les galeries"
          >
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4 sm:gap-5">
              {feed.galleries.map((item) => (
                <HomeContentCard
                  key={item.id}
                  item={item}
                  variant="thumb"
                />
              ))}
            </div>
          </HomeSection>
        )}

        <PartnersSection partners={partners} />
      </main>

      <footer className="border-t border-gray-100 py-6 text-center text-xs text-gray-400">
        © {new Date().getFullYear()} {shortName} — {tagline}
      </footer>
    </div>
  )
}
