import Link from 'next/link'
import { formatArticleDate } from '@/lib/articles'
import {
  KIND_LABEL,
  type HomeFeedItem,
} from '@/lib/home-feed'
import { ArrowRight } from 'lucide-react'

type Props = {
  item: HomeFeedItem
}

export function HomeHero({ item }: Props) {
  return (
    <section className="relative w-full min-h-[52vh] sm:min-h-[60vh] bg-gray-900 overflow-hidden">
      {item.image_url ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={item.image_url}
          alt=""
          className="absolute inset-0 w-full h-full object-cover animate-in fade-in duration-700"
        />
      ) : (
        <div className="absolute inset-0 bg-gradient-to-br from-[#004d28] via-[#00A550] to-[#1a1a1a]" />
      )}
      <div className="absolute inset-0 bg-gradient-to-t from-black/85 via-black/45 to-black/20" />

      <div className="relative max-w-5xl mx-auto px-6 pb-10 pt-28 sm:pt-36 sm:pb-14 flex flex-col justify-end min-h-[52vh] sm:min-h-[60vh]">
        <div className="max-w-3xl space-y-3 sm:space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-500">
          <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-sm text-white/80">
            <span className="font-semibold uppercase tracking-wide text-[#7dffa8]">
              {KIND_LABEL[item.kind]}
            </span>
            {item.category_name && (
              <span className="text-white/70">{item.category_name}</span>
            )}
            {item.published_at && (
              <time dateTime={item.published_at}>
                {formatArticleDate(item.published_at)}
              </time>
            )}
          </div>
          <h1 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-white tracking-tight leading-tight">
            <Link href={item.href} className="hover:underline decoration-white/40">
              {item.title}
            </Link>
          </h1>
          {item.excerpt && (
            <p className="text-base sm:text-lg text-white/85 leading-relaxed line-clamp-3 max-w-2xl">
              {item.excerpt}
            </p>
          )}
          <Link
            href={item.href}
            className="inline-flex items-center gap-2 text-sm font-semibold text-white hover:text-[#7dffa8] transition-colors pt-1"
          >
            Lire la suite
            <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </div>
    </section>
  )
}
