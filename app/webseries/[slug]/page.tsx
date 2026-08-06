import { SeriesDetailPageForType } from '@/components/series/series-detail-page'

export const dynamic = 'force-dynamic'

type Props = { params: { slug: string } }

export default async function WebseriesDetailPage({ params }: Props) {
  return (
    <SeriesDetailPageForType
      slug={params.slug}
      expectedType="webseries"
      listHref="/webseries"
      listLabel="Toutes les web-séries"
      active="webseries"
    />
  )
}
