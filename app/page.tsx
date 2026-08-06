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
    <div className="min-h-screen flex flex-col mfk-home-canvas">
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
          <section className="bg-gradient-to-br from-[#00A550] via-[#008040] to-[#F59E0B] text-white">
            <div className="max-w-5xl mx-auto px-6 py-16 sm:py-20 text-center space-y-3">
              <p className="text-sm font-bold uppercase tracking-wide text-[#FDE68A]">
                {shortName}
              </p>
              <h1 className="text-3xl sm:text-4xl font-extrabold tracking-tight">
                Portail actualités
              </h1>
              <p className="text-white/90 max-w-xl mx-auto">
                Les contenus publiés apparaîtront ici dès qu’ils seront en ligne.
              </p>
            </div>
          </section>
        )}

        {/* App CTA strip — bandeau vibrant */}
        <section className="bg-gradient-to-r from-[#00A550] via-[#00B85C] to-[#F59E0B]">
          <div className="max-w-5xl mx-auto px-6 py-5 flex flex-col sm:flex-row items-center justify-between gap-4">
            <p className="text-sm sm:text-base text-white font-medium text-center sm:text-left">
              Accédez à la plateforme e-learning et aux services {shortName}.
            </p>
            <div className="flex items-center gap-2">
              <Link
                href="/app"
                className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-white hover:bg-[#FFFBEB] text-[#007A3D] text-sm font-bold shadow-md transition-colors"
              >
                Accéder à {shortName} App
                <ArrowRight className="w-4 h-4" />
              </Link>
              <Link
                href="/login"
                className="inline-flex items-center px-4 py-2.5 rounded-xl border-2 border-white/70 bg-transparent text-white text-sm font-semibold hover:bg-white/15 transition-colors"
              >
                Se connecter
              </Link>
            </div>
          </div>
        </section>

        {!hasAnyContent && (
          <p className="max-w-5xl mx-auto px-6 py-16 text-center text-sm text-gray-700 font-medium">
            Aucun contenu publié pour le moment.
          </p>
        )}

        {feed.featured.length > 0 && (
          <HomeSection
            title="À la une"
            className="bg-[#9DD9B5]/90"
            accentClassName="bg-[#F59E0B]"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 sm:gap-6">
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
            className="bg-[#6FCF97]/85"
            accentClassName="bg-[#007A3D]"
          >
            <div className="rounded-2xl bg-[#E2F6EA]/90 border-[2.5px] border-[#00A550]/40 shadow-sm p-2 sm:p-3 space-y-2">
              {feed.articles.map((item) => (
                <HomeContentCard key={item.id} item={item} variant="list" />
              ))}
            </div>
          </HomeSection>
        )}

        {feed.videos.length > 0 && (
          <HomeSection
            title="Vidéos à la une"
            href="/videos"
            linkLabel="Voir toutes les vidéos"
            className="bg-[#93C5FD]/80"
            accentClassName="bg-[#1D7AFC]"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 sm:gap-6">
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
            className="bg-[#FCD34D]/75"
            accentClassName="bg-[#D97706]"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 sm:gap-6">
              {feed.reportages.map((item) => (
                <HomeContentCard key={item.id} item={item} />
              ))}
            </div>
          </HomeSection>
        )}

        {feed.series.length > 0 && (
          <HomeSection
            title="Web-séries & Podcasts"
            className="bg-[#5EEAD4]/75"
            accentClassName="bg-[#0D9488]"
          >
            <div className="flex flex-wrap gap-2 mb-6 -mt-1">
              <Link
                href="/webseries"
                className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-lg bg-[#0EA5E9] hover:bg-[#0284C7] text-white text-sm font-semibold shadow-sm transition-colors"
              >
                Voir les web-séries
                <ArrowRight className="w-3.5 h-3.5" />
              </Link>
              <Link
                href="/podcasts"
                className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-lg bg-[#0D9488] hover:bg-[#0F766E] text-white text-sm font-semibold shadow-sm transition-colors"
              >
                Voir les podcasts
                <ArrowRight className="w-3.5 h-3.5" />
              </Link>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 sm:gap-6">
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
            className="bg-[#FDBA74]/80"
            accentClassName="bg-[#EA580C]"
          >
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4 sm:gap-5">
              {feed.galleries.map((item) => (
                <HomeContentCard key={item.id} item={item} variant="thumb" />
              ))}
            </div>
          </HomeSection>
        )}

        <PartnersSection partners={partners} />
      </main>

      <footer className="bg-[#003d1f] py-7 text-center text-xs text-white/75">
        © {new Date().getFullYear()} {shortName} — {tagline}
      </footer>
    </div>
  )
}
