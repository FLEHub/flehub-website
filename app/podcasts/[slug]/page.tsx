import { SeriesDetailPageForType } from '@/components/series/series-detail-page'

export const dynamic = 'force-dynamic'

type Props = { params: { slug: string } }

export default async function PodcastDetailPage({ params }: Props) {
  return (
    <SeriesDetailPageForType
      slug={params.slug}
      expectedType="podcast"
      listHref="/podcasts"
      listLabel="Tous les podcasts"
      active="podcasts"
    />
  )
}
