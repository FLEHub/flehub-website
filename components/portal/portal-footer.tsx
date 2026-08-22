import { BrandLogo } from '@/components/brand-logo'

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

  if (variant === 'dark') {
    return (
      <footer className="bg-[#0B1F3A] py-7 text-center text-xs text-[#C8CCD1]">
        <div className="flex flex-col items-center gap-2.5">
          <BrandLogo size={44} href="/" />
          <p>{copy}</p>
        </div>
      </footer>
    )
  }

  return (
    <footer className="border-t border-[#0B1F3A]/10 py-6 text-center text-xs text-[#0B1F3A]/55">
      <div className="flex flex-col items-center gap-2">
        <BrandLogo size={32} href="/" />
        <p>{copy}</p>
      </div>
    </footer>
  )
}
