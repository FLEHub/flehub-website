import type { Partner } from '@/lib/partners'

type Props = {
  partners: Partner[]
}

export function PartnersSection({ partners }: Props) {
  if (partners.length === 0) {
    // Bandeau de transition colorée même sans partenaires, pour éviter une coupure blanche
    return (
      <section
        className="h-10 bg-gradient-to-b from-[#3A92D1]/60 to-[#0B1F3A]"
        aria-hidden
      />
    )
  }

  return (
    <section className="bg-gradient-to-b from-[#3A92D1] via-[#1E5FA8] to-[#0B1F3A]">
      <div className="max-w-5xl mx-auto px-6 py-12 sm:py-14">
        <div className="text-center mb-8">
          <h2 className="text-xl sm:text-2xl font-extrabold text-white drop-shadow-sm">
            Nos partenaires
          </h2>
          <div className="mx-auto mt-2 h-1 w-14 rounded-full bg-[#F2B705]" />
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
                    className="flex items-center justify-center h-20 w-[150px] rounded-xl bg-[#E3EEF7] border-[2.5px] border-[#F2B705]/70 shadow-md hover:shadow-lg hover:border-[#F2B705] transition-all p-3"
                  >
                    {logo}
                  </a>
                ) : (
                  <div className="flex items-center justify-center h-20 w-[150px] rounded-xl bg-[#E3EEF7] border-[2.5px] border-white/40 shadow-md p-3">
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
