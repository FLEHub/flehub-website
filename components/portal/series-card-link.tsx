import Link from 'next/link'
import { formatArticleDate } from '@/lib/articles'
import { seriesPublicBasePath, type SeriesType } from '@/lib/series'

export type SeriesCardData = {
  title: string
  slug: string
  description: string | null
  cover_image_url: string | null
  published_at: string | null
  category_name?: string | null
  episode_count?: number
  type: SeriesType
}

type Props = {
  series: SeriesCardData
}

export function SeriesCardLink({ series }: Props) {
  const base = seriesPublicBasePath(series.type)
  return (
    <Link
      href={`${base}/${series.slug}`}
      className="group block rounded-xl overflow-hidden border border-gray-100 bg-white hover:border-[#00A550]/40 transition-colors"
    >
      {series.cover_image_url ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={series.cover_image_url}
          alt=""
          className="w-full aspect-[4/3] object-cover transition-transform duration-300 group-hover:scale-[1.02]"
        />
      ) : (
        <div className="w-full aspect-[4/3] bg-[#E6F5EE]" />
      )}
      <div className="p-4 space-y-1.5">
        <div className="flex flex-wrap items-center gap-x-2 gap-y-1 text-xs text-gray-500">
          {series.category_name && (
            <span className="text-[#00A550] font-medium">
              {series.category_name}
            </span>
          )}
          {series.published_at && (
            <span>{formatArticleDate(series.published_at)}</span>
          )}
          {typeof series.episode_count === 'number' && (
            <span>
              {series.episode_count} épisode
              {series.episode_count > 1 ? 's' : ''}
            </span>
          )}
        </div>
        <h2 className="text-base sm:text-lg font-semibold text-gray-900 group-hover:text-[#00A550] transition-colors leading-snug">
          {series.title}
        </h2>
        {series.description && (
          <p className="text-sm text-gray-600 line-clamp-2 leading-relaxed">
            {series.description}
          </p>
        )}
      </div>
    </Link>
  )
}
