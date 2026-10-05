import Link from 'next/link'
import { BrandLogo } from '@/components/brand-logo'

const ELEARNING_CTA_HREF = '/app'
const ELEARNING_CTA_LABEL = 'J’apprends le français'

type Props = {
  shortName: string
  tagline: string
  variant?: 'light' | 'dark'
}

export function PortalFooter({
  shortName,
  tagline,
  variant = 'light',
}: Props) {
  const year = new Date().getFullYear()
  const copy = `© ${year} ${shortName} — ${tagline}`

  const elearningLink = (
    <Link
      href={ELEARNING_CTA_HREF}
      title={ELEARNING_CTA_LABEL}
      aria-label={ELEARNING_CTA_LABEL}
      className={
        variant === 'dark'
          ? 'inline-flex min-h-[44px] items-center justify-center whitespace-nowrap px-2 text-sm font-semibold text-[#F2B705] hover:text-white transition-colors'
          : 'inline-flex min-h-[44px] items-center justify-center whitespace-nowrap px-2 text-sm font-semibold text-[#1E5FA8] hover:text-[#0B1F3A] transition-colors'
      }
    >
      {ELEARNING_CTA_LABEL}
    </Link>
  )

  if (variant === 'dark') {
    return (
      <footer className="bg-[#0B1F3A] py-7 text-center text-xs text-[#C8CCD1]">
        <div className="flex flex-col items-center gap-2.5">
          <BrandLogo size={44} href="/" />
          {elearningLink}
          <p>{copy}</p>
        </div>
      </footer>
    )
  }

  return (
    <footer className="border-t border-[#0B1F3A]/10 py-6 text-center text-xs text-[#0B1F3A]/55">
      <div className="flex flex-col items-center gap-2">
        <BrandLogo size={32} href="/" />
        {elearningLink}
        <p>{copy}</p>
      </div>
    </footer>
  )
}
