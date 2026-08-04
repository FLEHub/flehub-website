import Link from 'next/link'
import { formatArticleDate } from '@/lib/articles'

export type VideoCardData = {
  title: string
  slug: string
  description: string | null
  thumbnail_url: string | null
  published_at: string | null
  category_name?: string | null
}

type Props = {
  video: VideoCardData
}

export function VideoCardLink({ video }: Props) {
  return (
    <Link
      href={`/videos/${video.slug}`}
      className="group block border-b border-gray-100 last:border-0 py-6 first:pt-0 last:pb-0"
    >
      <div className="flex flex-col sm:flex-row gap-4 sm:gap-6">
        {video.thumbnail_url ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={video.thumbnail_url}
            alt=""
            className="w-full sm:w-44 h-40 sm:h-28 object-cover rounded-lg flex-shrink-0"
          />
        ) : (
          <div className="w-full sm:w-44 h-40 sm:h-28 rounded-lg bg-[#E6F5EE] flex-shrink-0" />
        )}
        <div className="min-w-0 flex-1 space-y-1.5">
          <div className="flex flex-wrap items-center gap-x-2 gap-y-1 text-xs text-gray-500">
            {video.category_name && (
              <span className="text-[#00A550] font-medium">
                {video.category_name}
              </span>
            )}
            {video.published_at && (
              <span>{formatArticleDate(video.published_at)}</span>
            )}
          </div>
          <h2 className="text-lg font-semibold text-gray-900 group-hover:text-[#00A550] transition-colors leading-snug">
            {video.title}
          </h2>
          {video.description && (
            <p className="text-sm text-gray-600 line-clamp-2 leading-relaxed">
              {video.description}
            </p>
          )}
        </div>
      </div>
    </Link>
  )
}
