import Link from 'next/link'
import { GraduationCap } from 'lucide-react'
import { BrandMark } from '@/components/brand-mark'

type Props = {
  shortName: string
  tagline: string
  active?:
    | 'home'
    | 'actualites'
    | 'videos'
    | 'reportages'
    | 'galeries'
    | 'webseries'
    | 'podcasts'
  showAppCta?: boolean
}

const NAV: { href: string; label: string; key: NonNullable<Props['active']> }[] = [
  { href: '/actualites', label: 'Actualités', key: 'actualites' },
  { href: '/videos', label: 'Vidéos', key: 'videos' },
  { href: '/reportages', label: 'Reportages', key: 'reportages' },
  { href: '/galeries', label: 'Galerie', key: 'galeries' },
  { href: '/webseries', label: 'Web-séries', key: 'webseries' },
  { href: '/podcasts', label: 'Podcasts', key: 'podcasts' },
]

export function PortalHeader({
  shortName,
  tagline,
  active,
  showAppCta = false,
}: Props) {
  return (
    <header className="border-b-2 border-[#00A550]/20 bg-white/95 backdrop-blur-sm sticky top-0 z-20 shadow-sm">
      <div className="max-w-5xl mx-auto px-6 h-16 flex items-center justify-between gap-3">
        <Link href="/" className="flex items-center gap-2.5 min-w-0">
          <div className="w-9 h-9 rounded-lg bg-[#00A550] flex items-center justify-center flex-shrink-0 shadow-sm">
            <GraduationCap className="w-5 h-5 text-white" />
          </div>
          <BrandMark shortName={shortName} tagline={tagline} size="md" />
        </Link>
        <nav className="flex items-center gap-2 sm:gap-3 lg:gap-4 text-xs sm:text-sm font-medium flex-wrap justify-end">
          {NAV.map((item) => (
            <Link
              key={item.key}
              href={item.href}
              className={
                active === item.key
                  ? 'text-[#00A550] font-semibold'
                  : 'text-gray-600 hover:text-[#00A550] transition-colors'
              }
            >
              {item.label}
            </Link>
          ))}
          {showAppCta && (
            <Link
              href="/app"
              className="hidden sm:inline-flex items-center px-3.5 py-1.5 rounded-lg bg-[#F59E0B] hover:bg-[#D97706] text-gray-900 text-xs sm:text-sm font-bold shadow-sm transition-colors"
            >
              {shortName} App
            </Link>
          )}
          <Link
            href="/login"
            className="inline-flex items-center px-3 py-1.5 rounded-lg border border-[#00A550]/30 text-[#00A550] hover:bg-[#E6F5EE] font-semibold transition-colors"
          >
            Connexion
          </Link>
        </nav>
      </div>
    </header>
  )
}
