import Link from 'next/link'
import { formatArticleDate } from '@/lib/articles'
import {
  KIND_BADGE_CLASS,
  KIND_LABEL,
  type HomeFeedItem,
} from '@/lib/home-feed'
import { ArrowRight } from 'lucide-react'

type Props = {
  item: HomeFeedItem
}

export function HomeHero({ item }: Props) {
  return (
    <section className="relative w-full min-h-[52vh] sm:min-h-[62vh] bg-[#0B1F3A] overflow-hidden">
      {item.image_url ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={item.image_url}
          alt=""
          className="absolute inset-0 w-full h-full object-cover scale-105 animate-in fade-in duration-700"
        />
      ) : (
        <div className="absolute inset-0 bg-gradient-to-br from-[#0B1F3A] via-[#1E5FA8] to-[#F2B705]" />
      )}
      {/* Overlay : bleu nuit + azur + or du logo */}
      <div className="absolute inset-0 bg-gradient-to-t from-[#0B1F3A]/95 via-[#1E5FA8]/45 to-[#F2B705]/25" />
      <div className="absolute inset-0 bg-gradient-to-r from-[#0B1F3A]/70 via-transparent to-transparent" />

      <div className="relative max-w-5xl mx-auto px-6 pb-10 pt-28 sm:pt-36 sm:pb-14 flex flex-col justify-end min-h-[52vh] sm:min-h-[62vh]">
        <div className="max-w-3xl space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-500">
          <div className="flex flex-wrap items-center gap-2 text-sm">
            <span
              className={`inline-flex items-center px-2.5 py-1 rounded-md text-xs font-bold uppercase tracking-wide shadow-sm ${KIND_BADGE_CLASS[item.kind]}`}
            >
              {KIND_LABEL[item.kind]}
            </span>
            {item.category_name && (
              <span className="inline-flex items-center px-2.5 py-1 rounded-md text-xs font-semibold bg-white/20 text-white backdrop-blur-sm">
                {item.category_name}
              </span>
            )}
            {item.published_at && (
              <time
                dateTime={item.published_at}
                className="text-white/85 text-xs sm:text-sm"
              >
                {formatArticleDate(item.published_at)}
              </time>
            )}
          </div>
          <h1 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-white tracking-tight leading-tight drop-shadow-sm">
            <Link href={item.href} className="hover:underline decoration-white/40">
              {item.title}
            </Link>
          </h1>
          {item.excerpt && (
            <p className="text-base sm:text-lg text-white/90 leading-relaxed line-clamp-3 max-w-2xl">
              {item.excerpt}
            </p>
          )}
          <Link
            href={item.href}
            className="inline-flex min-h-11 items-center gap-2 px-5 py-2.5 rounded-xl bg-[#F2B705] hover:bg-[#C99404] text-[#0B1F3A] text-sm font-bold shadow-md transition-colors"
          >
            Lire la suite
            <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </div>
    </section>
  )
}
