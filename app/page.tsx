import Link from 'next/link'
import { GraduationCap, Newspaper, ArrowRight } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { normalizeOrgBranding, DEFAULT_ORG_SHORT_NAME, DEFAULT_ORG_TAGLINE } from '@/lib/org-branding'

export const dynamic = 'force-dynamic'

export default async function HomePage() {
  let branding = normalizeOrgBranding(null)
  try {
    const supabase = await createClient()
    const { data } = await supabase
      .from('org_settings')
      .select('org_name, org_short_name, org_tagline')
      .limit(1)
      .maybeSingle()
    branding = normalizeOrgBranding(data)
  } catch {
    // Fallbacks already set.
  }

  const shortName = branding.orgShortName || DEFAULT_ORG_SHORT_NAME
  const tagline = branding.orgTagline || DEFAULT_ORG_TAGLINE

  return (
    <div className="min-h-screen flex flex-col bg-gradient-to-b from-[#E8F8F0] via-white to-gray-50">
      <header className="border-b border-gray-100 bg-white/80 backdrop-blur-sm">
        <div className="max-w-5xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-lg bg-[#00A550] flex items-center justify-center">
              <GraduationCap className="w-5 h-5 text-white" />
            </div>
            <div>
              <p className="font-bold text-lg text-gray-900 leading-none">{shortName}</p>
              <p className="text-[11px] text-gray-500 leading-tight mt-0.5">{tagline}</p>
            </div>
          </div>
          <Link
            href="/login"
            className="text-sm font-medium text-gray-600 hover:text-[#00A550] transition-colors"
          >
            Connexion
          </Link>
        </div>
      </header>

      <main className="flex-1 flex items-center justify-center px-6 py-16">
        <div className="max-w-xl w-full text-center space-y-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-[#00A550]/10 text-[#00A550]">
            <Newspaper className="w-8 h-8" />
          </div>

          <div className="space-y-3">
            <h1 className="text-4xl sm:text-5xl font-extrabold tracking-tight text-gray-900">
              Bienvenue sur {shortName}
            </h1>
            <p className="text-base sm:text-lg text-gray-600 leading-relaxed">
              {tagline}. Portail actualités — le contenu sera bientôt disponible.
            </p>
          </div>

          <div className="rounded-2xl border border-dashed border-[#00A550]/30 bg-white/70 px-6 py-8 text-sm text-gray-500">
            Espace actualités MFK (placeholder). Les articles et annonces seront publiés ici.
          </div>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
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
        </div>
      </main>

      <footer className="border-t border-gray-100 py-6 text-center text-xs text-gray-400">
        © {new Date().getFullYear()} {shortName} — {tagline}
      </footer>
    </div>
  )
}
