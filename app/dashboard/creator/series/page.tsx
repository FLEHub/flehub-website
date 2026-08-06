'use client'

import { useCallback, useEffect, useState } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { formatArticleDate } from '@/lib/articles'
import {
  getCreatorIdForProfile,
  seriesTypeLabel,
  type SeriesListItem,
  type SeriesStatus,
  type SeriesType,
} from '@/lib/series'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  AlertTriangle,
  Loader2,
  Pencil,
  Plus,
  RefreshCw,
  X,
} from 'lucide-react'

const STATUS_CLASS: Record<SeriesStatus, string> = {
  draft: 'bg-yellow-50 text-yellow-700 border-yellow-200',
  published: 'bg-[#E6F5EE] text-[#00A550] border-green-200',
}

const STATUS_LABEL: Record<SeriesStatus, string> = {
  draft: 'Brouillon',
  published: 'Publié',
}

export default function CreatorSeriesListPage() {
  const supabase = createClient()
  const [rows, setRows] = useState<SeriesListItem[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [actionId, setActionId] = useState<string | null>(null)

  const fetchSeries = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser()
      if (!user) throw new Error('Session expirée.')

      const creatorId = await getCreatorIdForProfile(supabase, user.id)
      if (!creatorId) {
        throw new Error(
          'Aucun profil créateur associé. Contactez un administrateur.'
        )
      }

      const { data, error: qErr } = await supabase
        .from('series')
        .select(
          'id, type, title, slug, description, cover_image_url, status, published_at, created_at, updated_at, category_id, category:article_categories(id, name, slug), series_episodes(id)'
        )
        .eq('creator_id', creatorId)
        .order('updated_at', { ascending: false })

      if (qErr) throw qErr

      const mapped = (data ?? []).map((row) => {
        const cat = row.category as
          | { id: string; name: string; slug: string }
          | { id: string; name: string; slug: string }[]
          | null
        const eps = row.series_episodes as { id: string }[] | null
        return {
          id: row.id,
          type: row.type as SeriesType,
          title: row.title,
          slug: row.slug,
          description: row.description,
          cover_image_url: row.cover_image_url,
          status: row.status as SeriesStatus,
          published_at: row.published_at,
          created_at: row.created_at,
          updated_at: row.updated_at,
          category_id: row.category_id,
          category: Array.isArray(cat) ? cat[0] ?? null : cat,
          episode_count: eps?.length ?? 0,
        } as SeriesListItem
      })
      setRows(mapped)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setLoading(false)
    }
  }, [supabase])

  useEffect(() => {
    void fetchSeries()
  }, [fetchSeries])

  const unpublish = async (id: string) => {
    setActionId(id)
    setError(null)
    try {
      const { error: updErr } = await supabase
        .from('series')
        .update({
          status: 'draft',
          published_at: null,
          updated_at: new Date().toISOString(),
        })
        .eq('id', id)
      if (updErr) throw updErr
      await fetchSeries()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setActionId(null)
    }
  }

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Mes séries</h1>
          <p className="text-sm text-gray-500 mt-1">
            Web-séries et podcasts (brouillons et publiés)
          </p>
        </div>
        <div className="flex gap-2">
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={() => void fetchSeries()}
            disabled={loading}
          >
            <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Actualiser
          </Button>
          <Button asChild size="sm" className="bg-[#00A550] hover:bg-[#008040]">
            <Link href="/dashboard/creator/series/new">
              <Plus className="w-4 h-4 mr-2" />
              Nouvelle série
            </Link>
          </Button>
        </div>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          <span className="flex-1">{error}</span>
          <button type="button" onClick={() => setError(null)}>
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      <div className="rounded-xl border border-gray-100 bg-white overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center py-16 text-gray-400">
            <Loader2 className="w-5 h-5 animate-spin mr-2" />
            Chargement…
          </div>
        ) : rows.length === 0 ? (
          <div className="py-16 text-center space-y-3">
            <p className="text-sm text-gray-500">Aucune série pour le moment.</p>
            <Button asChild className="bg-[#00A550] hover:bg-[#008040]">
              <Link href="/dashboard/creator/series/new">
                <Plus className="w-4 h-4 mr-2" />
                Créer une série
              </Link>
            </Button>
          </div>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Titre</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Catégorie</TableHead>
                <TableHead>Épisodes</TableHead>
                <TableHead>Statut</TableHead>
                <TableHead>Date</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {rows.map((row) => (
                <TableRow key={row.id}>
                  <TableCell className="font-medium text-gray-900 max-w-[220px]">
                    <div className="flex items-center gap-3">
                      {row.cover_image_url ? (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img
                          src={row.cover_image_url}
                          alt=""
                          className="w-12 h-12 object-cover rounded border border-gray-100 flex-shrink-0"
                        />
                      ) : (
                        <div className="w-12 h-12 rounded bg-[#E6F5EE] flex-shrink-0" />
                      )}
                      <span className="line-clamp-2">{row.title}</span>
                    </div>
                  </TableCell>
                  <TableCell className="text-sm text-gray-600">
                    {seriesTypeLabel(row.type)}
                  </TableCell>
                  <TableCell className="text-sm text-gray-600">
                    {row.category?.name ?? '—'}
                  </TableCell>
                  <TableCell className="text-sm text-gray-600">
                    {row.episode_count ?? 0}
                  </TableCell>
                  <TableCell>
                    <Badge
                      variant="outline"
                      className={STATUS_CLASS[row.status]}
                    >
                      {STATUS_LABEL[row.status]}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-sm text-gray-500 whitespace-nowrap">
                    {row.status === 'published'
                      ? formatArticleDate(row.published_at)
                      : formatArticleDate(row.updated_at)}
                  </TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-2">
                      <Button asChild size="sm" variant="outline">
                        <Link href={`/dashboard/creator/series/${row.id}`}>
                          <Pencil className="w-3.5 h-3.5 mr-1.5" />
                          Modifier
                        </Link>
                      </Button>
                      {row.status === 'published' && (
                        <Button
                          size="sm"
                          variant="ghost"
                          disabled={actionId === row.id}
                          onClick={() => void unpublish(row.id)}
                        >
                          {actionId === row.id ? (
                            <Loader2 className="w-3.5 h-3.5 animate-spin" />
                          ) : (
                            'Dépublier'
                          )}
                        </Button>
                      )}
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </div>
    </div>
  )
}
