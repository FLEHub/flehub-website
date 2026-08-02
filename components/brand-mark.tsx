import { cn } from '@/lib/utils'
import {
  DEFAULT_ORG_SHORT_NAME,
  DEFAULT_ORG_TAGLINE,
} from '@/lib/org-branding'

type BrandMarkProps = {
  shortName?: string
  tagline?: string
  /** Visual size of the short-name line */
  size?: 'sm' | 'md' | 'lg'
  /** Text color variant for dark panels (login/register left side) */
  variant?: 'default' | 'onDark'
  className?: string
  align?: 'left' | 'center'
}

const shortNameClass: Record<NonNullable<BrandMarkProps['size']>, string> = {
  sm: 'text-base font-bold leading-tight',
  md: 'text-xl font-extrabold leading-tight',
  lg: 'text-3xl font-extrabold leading-tight',
}

const taglineClass: Record<NonNullable<BrandMarkProps['size']>, string> = {
  sm: 'text-[10px] leading-snug mt-0.5',
  md: 'text-[11px] leading-snug mt-0.5',
  lg: 'text-xs leading-snug mt-1',
}

/**
 * Displays org short name with full tagline underneath:
 *   MFK
 *   Maison de la Francophonie Kigali
 */
export function BrandMark({
  shortName = DEFAULT_ORG_SHORT_NAME,
  tagline = DEFAULT_ORG_TAGLINE,
  size = 'md',
  variant = 'default',
  className,
  align = 'left',
}: BrandMarkProps) {
  const nameColor = variant === 'onDark' ? 'text-white' : 'text-gray-900'
  const taglineColor = variant === 'onDark' ? 'text-white/75' : 'text-gray-500'

  return (
    <div
      className={cn(
        'min-w-0',
        align === 'center' && 'text-center',
        className
      )}
    >
      <p className={cn(shortNameClass[size], nameColor, 'truncate')}>
        {shortName}
      </p>
      <p className={cn(taglineClass[size], taglineColor, 'truncate')}>
        {tagline}
      </p>
    </div>
  )
}
