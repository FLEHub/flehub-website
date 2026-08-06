import type { Partner } from '@/lib/partners'

type Props = {
  partners: Partner[]
}

export function PartnersSection({ partners }: Props) {
  if (partners.length === 0) return null

  return (
    <section className="border-t border-gray-100 bg-gray-50/80">
      <div className="max-w-5xl mx-auto px-6 py-12 sm:py-14">
        <h2 className="text-center text-xl sm:text-2xl font-bold text-gray-900 mb-8">
          Nos partenaires
        </h2>
        <ul className="flex flex-wrap items-center justify-center gap-6 sm:gap-8">
          {partners.map((partner) => {
            const logo = (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                src={partner.logo_url}
                alt={partner.name}
                title={partner.name}
                className="h-12 sm:h-14 w-auto max-w-[140px] object-contain opacity-80 hover:opacity-100 transition-opacity"
              />
            )

            return (
              <li key={partner.id} className="flex items-center justify-center">
                {partner.website_url ? (
                  <a
                    href={partner.website_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    aria-label={partner.name}
                    className="block"
                  >
                    {logo}
                  </a>
                ) : (
                  logo
                )}
              </li>
            )
          })}
        </ul>
      </div>
    </section>
  )
}
