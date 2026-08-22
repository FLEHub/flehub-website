import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import {
  normalizeOrgBranding,
  DEFAULT_ORG_SHORT_NAME,
  DEFAULT_ORG_TAGLINE,
} from '@/lib/org-branding'
import { PortalHeader } from '@/components/portal/portal-header'
import { PortalFooter } from '@/components/portal/portal-footer'
import { GalleryCardLink } from '@/components/portal/gallery-card-link'

export const dynamic = 'force-dynamic'

type Props = {
  searchParams?: { categorie?: string }
}

export default async function GaleriesPage({ searchParams }: Props) {
  const categorySlug = searchParams?.categorie?.trim() || null
  let branding = normalizeOrgBranding(null)
  let categories: { id: string; name: string; slug: string }[] = []
  let galleries: {
    id: string
    title: string
    slug: string
    description: string | null
    cover_image_url: string | null
    published_at: string | null
    category_name: string | null
    photo_count: number
  }[] = []

  try {
    const supabase = await createClient()
    const { data: org } = await supabase
      .from('org_settings')
      .select('org_name, org_short_name, org_tagline')
      .limit(1)
      .maybeSingle()
    branding = normalizeOrgBranding(org)

    const { data: cats } = await supabase
      .from('article_categories')
      .select('id, name, slug')
      .order('name')
    categories = cats ?? []

    let query = supabase
      .from('galleries')
      .select(
        'id, title, slug, description, cover_image_url, published_at, category:article_categories(id, name, slug), gallery_photos(id)'
      )
      .eq('status', 'published')
      .order('published_at', { ascending: false })

    if (categorySlug) {
      const cat = categories.find((c) => c.slug === categorySlug)
      if (cat) query = query.eq('category_id', cat.id)
    }

    const { data } = await query
    galleries = (data ?? []).map((row) => {
      const cat = row.category as
        | { id: string; name: string; slug: string }
        | { id: string; name: string; slug: string }[]
        | null
      const category = Array.isArray(cat) ? cat[0] ?? null : cat
      const photoRows = row.gallery_photos as { id: string }[] | null
      return {
        id: row.id,
        title: row.title,
        slug: row.slug,
        description: row.description,
        cover_image_url: row.cover_image_url,
        published_at: row.published_at,
        category_name: category?.name ?? null,
        photo_count: photoRows?.length ?? 0,
      }
    })
  } catch {
    // Empty list if tables are unavailable.
  }

  const shortName = branding.orgShortName || DEFAULT_ORG_SHORT_NAME
  const tagline = branding.orgTagline || DEFAULT_ORG_TAGLINE

  return (
    <div className="min-h-screen flex flex-col bg-gradient-to-b from-[#E8F1FA] via-white to-gray-50">
      <PortalHeader shortName={shortName} tagline={tagline} active="galeries" />

      <main className="flex-1 max-w-5xl w-full mx-auto px-6 py-10 sm:py-14">
        <div className="mb-8 space-y-2">
          <h1 className="text-3xl sm:text-4xl font-extrabold text-gray-900 tracking-tight">
            Galerie
          </h1>
          <p className="text-gray-600 max-w-2xl">
            Les albums photos publiés par {shortName}.
          </p>
        </div>

        <div className="flex flex-wrap gap-2 mb-8">
          <Link
            href="/galeries"
            className={
              !categorySlug
                ? 'text-sm font-medium px-3 py-1.5 rounded-lg bg-[#1E5FA8] text-white'
                : 'text-sm font-medium px-3 py-1.5 rounded-lg bg-white border border-gray-200 text-gray-600 hover:border-[#1E5FA8] hover:text-[#1E5FA8] transition-colors'
            }
          >
            Toutes
          </Link>
          {categories.map((c) => (
            <Link
              key={c.id}
              href={`/galeries?categorie=${c.slug}`}
              className={
                categorySlug === c.slug
                  ? 'text-sm font-medium px-3 py-1.5 rounded-lg bg-[#1E5FA8] text-white'
                  : 'text-sm font-medium px-3 py-1.5 rounded-lg bg-white border border-gray-200 text-gray-600 hover:border-[#1E5FA8] hover:text-[#1E5FA8] transition-colors'
              }
            >
              {c.name}
            </Link>
          ))}
        </div>

        {galleries.length === 0 ? (
          <p className="text-sm text-gray-500 py-12 text-center">
            {categorySlug
              ? 'Aucune galerie publiée dans cette catégorie.'
              : 'Aucune galerie publiée pour le moment.'}
          </p>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 sm:gap-6">
            {galleries.map((gallery) => (
              <GalleryCardLink key={gallery.id} gallery={gallery} />
            ))}
          </div>
        )}
      </main>

      <PortalFooter shortName={shortName} tagline={tagline} />
    </div>
  )
}
