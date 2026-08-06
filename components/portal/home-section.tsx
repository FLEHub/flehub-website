import Link from 'next/link'
import { ArrowRight } from 'lucide-react'
import type { ReactNode } from 'react'

type Props = {
  title: string
  href?: string
  linkLabel?: string
  children: ReactNode
  /** Applied to the outer full-bleed wrapper */
  className?: string
  /** Accent bar color under the title */
  accentClassName?: string
}

export function HomeSection({
  title,
  href,
  linkLabel = 'Voir tout',
  children,
  className = '',
  accentClassName = 'bg-[#00A550]',
}: Props) {
  return (
    <section className={className}>
      <div className="max-w-5xl mx-auto px-6 py-10 sm:py-12">
        <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-3 mb-7">
          <div>
            <h2 className="text-xl sm:text-2xl font-extrabold text-gray-900 tracking-tight">
              {title}
            </h2>
            <div className={`mt-2 h-1 w-14 rounded-full ${accentClassName}`} />
          </div>
          {href && (
            <Link
              href={href}
              className="inline-flex items-center gap-1.5 self-start sm:self-auto px-3.5 py-2 rounded-lg bg-[#00A550] hover:bg-[#008040] text-white text-sm font-semibold shadow-sm transition-colors"
            >
              {linkLabel}
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          )}
        </div>
        {children}
      </div>
    </section>
  )
}
