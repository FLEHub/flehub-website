import { cn } from '@/lib/utils'
import { MFK_LOGO_SRC } from '@/lib/org-branding'

type BrandLogoProps = {
  /** Pixel size of the square logo (keeps 1:1 ratio). */
  size?: number
  className?: string
  alt?: string
}

/**
 * Official circular MFK emblem. Always rendered square so the round logo is not stretched.
 */
export function BrandLogo({
  size = 36,
  className,
  alt = 'Maison de la Francophonie de Kigali',
}: BrandLogoProps) {
  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      src={MFK_LOGO_SRC}
      alt={alt}
      width={size}
      height={size}
      className={cn('aspect-square flex-shrink-0 object-contain', className)}
      style={{ width: size, height: size }}
    />
  )
}
