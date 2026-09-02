'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Menu, X } from 'lucide-react'
import { BrandMark } from '@/components/brand-mark'
import { BrandLogo } from '@/components/brand-logo'
import { cn } from '@/lib/utils'

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

function navClass(isActive: boolean) {
  return isActive
    ? 'text-[#1E5FA8] font-semibold'
    : 'text-gray-600 hover:text-[#1E5FA8] transition-colors'
}

export function PortalHeader({
  shortName,
  tagline,
  active,
  showAppCta = false,
}: Props) {
  const [open, setOpen] = useState(false)

  return (
    <header className="border-b-2 border-[#1E5FA8]/20 bg-white/95 backdrop-blur-sm sticky top-0 z-20 shadow-sm">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between gap-3">
        <Link
          href="/"
          className="flex items-center gap-2 min-w-0 bg-transparent shadow-none"
          style={{ backgroundColor: 'transparent' }}
          onClick={() => setOpen(false)}
        >
          <BrandLogo size={36} />
          <BrandMark
            shortName={shortName}
            tagline={tagline}
            size="sm"
            className="lg:hidden"
          />
          <BrandMark
            shortName={shortName}
            tagline={tagline}
            size="md"
            className="hidden lg:block"
          />
        </Link>

        <nav className="hidden lg:flex items-center gap-4 text-sm font-medium">
          {NAV.map((item) => (
            <Link
              key={item.key}
              href={item.href}
              className={navClass(active === item.key)}
            >
              {item.label}
            </Link>
          ))}
          {showAppCta && (
            <Link
              href="/app"
              className="inline-flex min-h-11 items-center px-3.5 py-1.5 rounded-lg bg-[#F2B705] hover:bg-[#C99404] text-[#0B1F3A] text-sm font-bold shadow-sm transition-colors"
            >
              {shortName} App
            </Link>
          )}
          <Link
            href="/login"
            className="inline-flex min-h-11 items-center px-3 py-1.5 rounded-lg border border-[#1E5FA8]/30 text-[#1E5FA8] hover:bg-[#E8F1FA] font-semibold transition-colors"
          >
            Connexion
          </Link>
        </nav>

        <button
          type="button"
          className="lg:hidden flex h-11 w-11 shrink-0 items-center justify-center rounded-lg border border-gray-200 text-gray-700"
          aria-label={open ? 'Fermer le menu' : 'Ouvrir le menu'}
          aria-expanded={open}
          onClick={() => setOpen((v) => !v)}
        >
          {open ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
        </button>
      </div>

      {open && (
        <div className="lg:hidden border-t border-gray-100 bg-white px-4 pb-4 pt-2 shadow-sm">
          <nav className="flex flex-col">
            {NAV.map((item) => (
              <Link
                key={item.key}
                href={item.href}
                onClick={() => setOpen(false)}
                className={cn(
                  'flex min-h-11 items-center text-sm font-medium',
                  navClass(active === item.key)
                )}
              >
                {item.label}
              </Link>
            ))}
            {showAppCta && (
              <Link
                href="/app"
                onClick={() => setOpen(false)}
                className="mt-2 inline-flex min-h-11 items-center justify-center rounded-lg bg-[#F2B705] hover:bg-[#C99404] text-[#0B1F3A] text-sm font-bold"
              >
                {shortName} App
              </Link>
            )}
            <Link
              href="/login"
              onClick={() => setOpen(false)}
              className="mt-2 inline-flex min-h-11 items-center justify-center rounded-lg border border-[#1E5FA8]/30 text-[#1E5FA8] font-semibold"
            >
              Connexion
            </Link>
          </nav>
        </div>
      )}
    </header>
  )
}
