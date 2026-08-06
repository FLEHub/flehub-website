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
}

export function HomeSection({
  title,
  href,
  linkLabel = 'Voir tout',
  children,
  className = '',
}: Props) {
  return (
    <section className={className}>
      <div className="max-w-5xl mx-auto px-6 py-10 sm:py-12">
        <div className="flex items-end justify-between gap-4 mb-6 border-b border-gray-200 pb-3">
          <h2 className="text-xl sm:text-2xl font-extrabold text-gray-900 tracking-tight">
            {title}
          </h2>
          {href && (
            <Link
              href={href}
              className="text-sm font-medium text-[#00A550] hover:underline inline-flex items-center gap-1 flex-shrink-0"
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
