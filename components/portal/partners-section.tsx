import type { Partner } from '@/lib/partners'

type Props = {
  partners: Partner[]
}

export function PartnersSection({ partners }: Props) {
  if (partners.length === 0) {
    // Bandeau de transition colorée même sans partenaires, pour éviter une coupure blanche
    return (
      <section
        className="h-10 bg-gradient-to-b from-[#4ADE80]/60 to-[#005c2e]"
        aria-hidden
      />
    )
  }

  return (
    <section className="bg-gradient-to-b from-[#4ADE80] via-[#00A550] to-[#005c2e]">
      <div className="max-w-5xl mx-auto px-6 py-12 sm:py-14">
        <div className="text-center mb-8">
          <h2 className="text-xl sm:text-2xl font-extrabold text-white drop-shadow-sm">
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
                    className="flex items-center justify-center h-20 w-[150px] rounded-xl bg-[#E2F6EA] border-[2.5px] border-[#F59E0B]/70 shadow-md hover:shadow-lg hover:border-[#F59E0B] transition-all p-3"
                  >
                    {logo}
                  </a>
                ) : (
                  <div className="flex items-center justify-center h-20 w-[150px] rounded-xl bg-[#E2F6EA] border-[2.5px] border-white/40 shadow-md p-3">
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
