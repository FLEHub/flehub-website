import type { Partner } from '@/lib/partners'

type Props = {
  partners: Partner[]
}

export function PartnersSection({ partners }: Props) {
  if (partners.length === 0) return null

  return (
    <section className="border-t border-[#00A550]/15 bg-gradient-to-b from-white to-[#E6F5EE]">
      <div className="max-w-5xl mx-auto px-6 py-12 sm:py-14">
        <div className="text-center mb-8">
          <h2 className="text-xl sm:text-2xl font-extrabold text-gray-900">
            Nos partenaires
          </h2>
          <div className="mx-auto mt-2 h-1 w-14 rounded-full bg-[#F59E0B]" />
        </div>
        <ul className="flex flex-wrap items-center justify-center gap-5 sm:gap-8">
          {partners.map((partner) => {
            const logo = (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                src={partner.logo_url}
                alt={partner.name}
                title={partner.name}
                className="h-12 sm:h-14 w-auto max-w-[140px] object-contain"
              />
            )

            return (
              <li key={partner.id}>
                {partner.website_url ? (
                  <a
                    href={partner.website_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    aria-label={partner.name}
                    className="flex items-center justify-center h-20 w-[150px] rounded-xl bg-white border border-[#00A550]/15 shadow-sm hover:shadow-md hover:border-[#00A550]/40 transition-all p-3"
                  >
                    {logo}
                  </a>
                ) : (
                  <div className="flex items-center justify-center h-20 w-[150px] rounded-xl bg-white border border-[#00A550]/15 shadow-sm p-3">
                    {logo}
                  </div>
                )}
              </li>
            )
          })}
        </ul>
      </div>
    </section>
  )
}
