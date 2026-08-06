import Link from 'next/link'
import { formatArticleDate } from '@/lib/articles'
import {
  KIND_ACCENT_BORDER,
  KIND_BADGE_CLASS,
  KIND_LABEL,
  type HomeFeedItem,
} from '@/lib/home-feed'
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
        className={`group flex gap-4 p-3 sm:p-4 rounded-xl border border-transparent bg-white/80 hover:bg-white hover:shadow-md ${KIND_ACCENT_BORDER[item.kind]} hover:border transition-all duration-200`}
      >
        <div className="relative flex-shrink-0 overflow-hidden rounded-lg">
          {item.image_url ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={item.image_url}
              alt=""
              className="w-28 sm:w-36 h-20 sm:h-24 object-cover transition-transform duration-500 group-hover:scale-[1.04]"
            />
          ) : (
            <div className="w-28 sm:w-36 h-20 sm:h-24 bg-gradient-to-br from-[#E6F5EE] to-[#FDE68A]/40" />
          )}
        </div>
        <div className="min-w-0 flex-1 space-y-1.5">
          <div className="flex flex-wrap items-center gap-2 text-xs">
            <span
              className={`inline-flex px-2 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-wide ${KIND_BADGE_CLASS[item.kind]}`}
            >
              {KIND_LABEL[item.kind]}
            </span>
            {item.category_name && (
              <span className="inline-flex px-2 py-0.5 rounded-md text-[10px] font-semibold bg-[#E6F5EE] text-[#007A3D]">
                {item.category_name}
              </span>
            )}
            {item.published_at && (
              <span className="text-gray-500">
                {formatArticleDate(item.published_at)}
              </span>
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
      <Link
        href={item.href}
        className={`group block rounded-xl overflow-hidden bg-white border border-gray-100 shadow-sm hover:shadow-md ${KIND_ACCENT_BORDER[item.kind]} hover:border transition-all duration-200`}
      >
        <div className="relative aspect-[4/3] overflow-hidden bg-gradient-to-br from-[#E6F5EE] to-[#FDE68A]/30">
          {item.image_url ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={item.image_url}
              alt=""
              className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-[1.05]"
            />
          ) : null}
          <span
            className={`absolute top-2 left-2 inline-flex px-2 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-wide shadow-sm ${KIND_BADGE_CLASS[item.kind]}`}
          >
            {KIND_LABEL[item.kind]}
          </span>
        </div>
        <div className="p-2.5 sm:p-3">
          <h3 className="text-sm font-semibold text-gray-900 group-hover:text-[#00A550] transition-colors leading-snug line-clamp-2">
            {item.title}
          </h3>
        </div>
      </Link>
    )
  }

  const showPlay = item.kind === 'video' || item.kind === 'webseries'
  const showMic = item.kind === 'reportage' || item.kind === 'podcast'

  return (
    <Link
      href={item.href}
      className={`group block rounded-xl overflow-hidden bg-white border border-gray-100 shadow-sm hover:shadow-lg ${KIND_ACCENT_BORDER[item.kind]} hover:border transition-all duration-200`}
    >
      <div className="relative aspect-[16/10] overflow-hidden bg-gradient-to-br from-[#E6F5EE] to-[#BAE6FD]/40">
        {item.image_url ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={item.image_url}
            alt=""
            className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-[1.05]"
          />
        ) : null}
        <span
          className={`absolute top-2.5 left-2.5 inline-flex px-2 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-wide shadow-sm ${KIND_BADGE_CLASS[item.kind]}`}
        >
          {KIND_LABEL[item.kind]}
        </span>
        {(showPlay || showMic) && (
          <span className="absolute bottom-2.5 right-2.5 inline-flex items-center justify-center w-9 h-9 rounded-full bg-[#00A550] text-white shadow-md group-hover:bg-[#F59E0B] group-hover:text-gray-900 transition-colors">
            {showPlay ? (
              <Play className="w-3.5 h-3.5 fill-current" />
            ) : (
              <Mic className="w-3.5 h-3.5" />
            )}
          </span>
        )}
      </div>
      <div className="p-3.5 sm:p-4 space-y-1.5">
        <div className="flex flex-wrap items-center gap-2 text-[11px] sm:text-xs">
          {item.category_name && (
            <span className="inline-flex px-2 py-0.5 rounded-md font-semibold bg-[#E6F5EE] text-[#007A3D]">
              {item.category_name}
            </span>
          )}
          {item.published_at && (
            <span className="text-gray-500">
              {formatArticleDate(item.published_at)}
            </span>
          )}
        </div>
        <h3 className="text-sm sm:text-base font-semibold text-gray-900 group-hover:text-[#00A550] transition-colors leading-snug line-clamp-2">
          {item.title}
        </h3>
      </div>
    </Link>
  )
}
