import Link from 'next/link'
import { formatArticleDate } from '@/lib/articles'

export type ArticleCardData = {
  title: string
  slug: string
  excerpt: string | null
  cover_image_url: string | null
  published_at: string | null
  category_name?: string | null
}

type Props = {
  article: ArticleCardData
}

export function ArticleCardLink({ article }: Props) {
  return (
    <Link
      href={`/actualites/${article.slug}`}
      className="group block border-b border-gray-100 last:border-0 py-6 first:pt-0 last:pb-0"
    >
      <div className="flex flex-col sm:flex-row gap-4 sm:gap-6">
        {article.cover_image_url ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={article.cover_image_url}
            alt=""
            className="w-full sm:w-44 h-40 sm:h-28 object-cover rounded-lg flex-shrink-0"
          />
        ) : (
          <div className="w-full sm:w-44 h-40 sm:h-28 rounded-lg bg-[#E6F5EE] flex-shrink-0" />
        )}
        <div className="min-w-0 flex-1 space-y-1.5">
          <div className="flex flex-wrap items-center gap-x-2 gap-y-1 text-xs text-gray-500">
            {article.category_name && (
              <span className="text-[#00A550] font-medium">
                {article.category_name}
              </span>
            )}
            {article.published_at && (
              <span>{formatArticleDate(article.published_at)}</span>
            )}
          </div>
          <h2 className="text-lg font-semibold text-gray-900 group-hover:text-[#00A550] transition-colors leading-snug">
            {article.title}
          </h2>
          {article.excerpt && (
            <p className="text-sm text-gray-600 line-clamp-2 leading-relaxed">
              {article.excerpt}
            </p>
          )}
        </div>
      </div>
    </Link>
  )
}
