import Link from 'next/link'
import { cn } from '@/lib/utils'
import { MFK_LOGO_SRC } from '@/lib/org-branding'

type BrandLogoProps = {
  /** Pixel size of the square logo (keeps 1:1 ratio). */
  size?: number
  className?: string
  alt?: string
  /**
   * When set, wrap the image in a Next.js Link.
   * Pass `false` when the logo is already inside a parent Link (avoid nested <a>).
   */
  href?: string | false
}

/**
 * Official circular MFK emblem. Always rendered square so the round logo is not stretched.
 * No background is applied so a transparent PNG can show through.
 */
export function BrandLogo({
  size = 36,
  className,
  alt = 'Maison de la Francophonie de Kigali',
  href,
}: BrandLogoProps) {
  const img = (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      src={MFK_LOGO_SRC}
      alt={href ? '' : alt}
      width={size}
      height={size}
      className={cn(
        'block aspect-square flex-shrink-0 rounded-full bg-transparent object-contain',
        className
      )}
      style={{
        width: size,
        height: size,
        backgroundColor: 'transparent',
        backgroundImage: 'none',
      }}
    />
  )

  if (!href) {
    return img
  }

  return (
    <Link
      href={href}
      aria-label={alt}
      className="inline-flex flex-shrink-0 overflow-hidden rounded-full bg-transparent"
      style={{ backgroundColor: 'transparent' }}
    >
      {img}
    </Link>
  )
}
