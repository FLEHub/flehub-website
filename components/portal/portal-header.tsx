import Link from 'next/link'
import { GraduationCap } from 'lucide-react'
import { BrandMark } from '@/components/brand-mark'

type Props = {
  shortName: string
  tagline: string
  active?: 'home' | 'actualites' | 'videos'
}

export function PortalHeader({ shortName, tagline, active }: Props) {
  return (
    <header className="border-b border-gray-100 bg-white/80 backdrop-blur-sm sticky top-0 z-20">
      <div className="max-w-5xl mx-auto px-6 h-16 flex items-center justify-between gap-4">
        <Link href="/" className="flex items-center gap-2.5 min-w-0">
          <div className="w-9 h-9 rounded-lg bg-[#00A550] flex items-center justify-center flex-shrink-0">
            <GraduationCap className="w-5 h-5 text-white" />
          </div>
          <BrandMark shortName={shortName} tagline={tagline} size="md" />
        </Link>
        <nav className="flex items-center gap-4 sm:gap-6 text-sm font-medium">
          <Link
            href="/actualites"
            className={
              active === 'actualites'
                ? 'text-[#00A550]'
                : 'text-gray-600 hover:text-[#00A550] transition-colors'
            }
          >
            Actualités
          </Link>
          <Link
            href="/videos"
            className={
              active === 'videos'
                ? 'text-[#00A550]'
                : 'text-gray-600 hover:text-[#00A550] transition-colors'
            }
          >
            Vidéos
          </Link>
          <Link
            href="/login"
            className="text-gray-600 hover:text-[#00A550] transition-colors"
          >
            Connexion
          </Link>
        </nav>
      </div>
    </header>
  )
}
