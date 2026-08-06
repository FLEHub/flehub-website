import Link from 'next/link'
import { formatArticleDate } from '@/lib/articles'
import { KIND_LABEL, type HomeFeedItem } from '@/lib/home-feed'
import { Mic, Play } from 'lucide-react'

type CardProps = {
  item: HomeFeedItem
  variant?: 'grid' | 'list' | 'thumb'
}

export function HomeContentCard({ item, variant = 'grid' }: CardProps) {
  if (variant === 'list') {
    return (
      <Link
        href={item.href}
        className="group flex gap-4 py-4 border-b border-gray-100 last:border-0"
      >
        {item.image_url ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={item.image_url}
            alt=""
            className="w-28 sm:w-36 h-20 sm:h-24 object-cover flex-shrink-0"
          />
        ) : (
          <div className="w-28 sm:w-36 h-20 sm:h-24 bg-[#E6F5EE] flex-shrink-0" />
        )}
        <div className="min-w-0 flex-1 space-y-1">
          <div className="flex flex-wrap items-center gap-x-2 gap-y-0.5 text-xs text-gray-500">
            {item.category_name && (
              <span className="text-[#00A550] font-medium">
                {item.category_name}
              </span>
            )}
            {item.published_at && (
              <span>{formatArticleDate(item.published_at)}</span>
            )}
          </div>
          <h3 className="text-base sm:text-lg font-semibold text-gray-900 group-hover:text-[#00A550] transition-colors leading-snug line-clamp-2">
            {item.title}
          </h3>
          {item.excerpt && (
            <p className="text-sm text-gray-600 line-clamp-2 hidden sm:block">
              {item.excerpt}
            </p>
          )}
        </div>
      </Link>
    )
  }

  if (variant === 'thumb') {
    return (
      <Link href={item.href} className="group block space-y-2">
        <div className="relative aspect-[4/3] overflow-hidden bg-[#E6F5EE]">
          {item.image_url ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={item.image_url}
              alt=""
              className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-[1.03]"
            />
          ) : null}
        </div>
        <h3 className="text-sm font-semibold text-gray-900 group-hover:text-[#00A550] transition-colors leading-snug line-clamp-2">
          {item.title}
        </h3>
      </Link>
    )
  }

  const showPlay = item.kind === 'video' || item.kind === 'webseries'
  const showMic = item.kind === 'reportage' || item.kind === 'podcast'

  return (
    <Link href={item.href} className="group block space-y-2.5">
      <div className="relative aspect-[16/10] overflow-hidden bg-[#E6F5EE]">
        {item.image_url ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={item.image_url}
            alt=""
            className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-[1.03]"
          />
        ) : null}
        {(showPlay || showMic) && (
          <span className="absolute bottom-2 left-2 inline-flex items-center justify-center w-8 h-8 rounded-full bg-black/60 text-white">
            {showPlay ? (
              <Play className="w-3.5 h-3.5 fill-current" />
            ) : (
              <Mic className="w-3.5 h-3.5" />
            )}
          </span>
        )}
      </div>
      <div className="space-y-1">
        <div className="flex flex-wrap items-center gap-x-2 gap-y-0.5 text-[11px] sm:text-xs text-gray-500">
          <span className="font-semibold uppercase tracking-wide text-[#00A550]">
            {KIND_LABEL[item.kind]}
          </span>
          {item.category_name && <span>{item.category_name}</span>}
        </div>
        <h3 className="text-sm sm:text-base font-semibold text-gray-900 group-hover:text-[#00A550] transition-colors leading-snug line-clamp-2">
          {item.title}
        </h3>
        {item.published_at && (
          <p className="text-xs text-gray-400">
            {formatArticleDate(item.published_at)}
          </p>
        )}
      </div>
    </Link>
  )
}
