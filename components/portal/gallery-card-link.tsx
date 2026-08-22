import Link from 'next/link'
import { formatArticleDate } from '@/lib/articles'

export type GalleryCardData = {
  title: string
  slug: string
  description: string | null
  cover_image_url: string | null
  published_at: string | null
  category_name?: string | null
  photo_count?: number
}

type Props = {
  gallery: GalleryCardData
}

export function GalleryCardLink({ gallery }: Props) {
  return (
    <Link
      href={`/galeries/${gallery.slug}`}
      className="group block rounded-xl overflow-hidden border border-gray-100 bg-white hover:border-[#1E5FA8]/40 transition-colors"
    >
      {gallery.cover_image_url ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={gallery.cover_image_url}
          alt=""
          className="w-full aspect-[4/3] object-cover transition-transform duration-300 group-hover:scale-[1.02]"
        />
      ) : (
        <div className="w-full aspect-[4/3] bg-[#E8F1FA]" />
      )}
      <div className="p-4 space-y-1.5">
        <div className="flex flex-wrap items-center gap-x-2 gap-y-1 text-xs text-gray-500">
          {gallery.category_name && (
            <span className="text-[#1E5FA8] font-medium">
              {gallery.category_name}
            </span>
          )}
          {gallery.published_at && (
            <span>{formatArticleDate(gallery.published_at)}</span>
          )}
          {typeof gallery.photo_count === 'number' && (
            <span>
              {gallery.photo_count} photo
              {gallery.photo_count > 1 ? 's' : ''}
            </span>
          )}
        </div>
        <h2 className="text-base sm:text-lg font-semibold text-gray-900 group-hover:text-[#1E5FA8] transition-colors leading-snug">
          {gallery.title}
        </h2>
        {gallery.description && (
          <p className="text-sm text-gray-600 line-clamp-2 leading-relaxed">
            {gallery.description}
          </p>
        )}
      </div>
    </Link>
  )
}
