'use client'

import { useCallback, useEffect, useState } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import {
  formatArticleDate,
  getJournalistIdForProfile,
  type ArticleListItem,
  type ArticleStatus,
} from '@/lib/articles'
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

const STATUS_CLASS: Record<ArticleStatus, string> = {
  draft: 'bg-yellow-50 text-yellow-700 border-yellow-200',
  published: 'bg-[#E6F5EE] text-[#00A550] border-green-200',
}

const STATUS_LABEL: Record<ArticleStatus, string> = {
  draft: 'Brouillon',
  published: 'Publié',
}

export default function JournalistArticlesPage() {
  const supabase = createClient()
  const [rows, setRows] = useState<ArticleListItem[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [actionId, setActionId] = useState<string | null>(null)

  const fetchArticles = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser()
      if (!user) throw new Error('Session expirée.')

      const journalistId = await getJournalistIdForProfile(supabase, user.id)
      if (!journalistId) {
        throw new Error(
          'Aucun profil journaliste associé. Contactez un administrateur.'
        )
      }

      const { data, error: qErr } = await supabase
        .from('articles')
        .select(
          'id, title, slug, excerpt, cover_image_url, status, published_at, created_at, updated_at, category_id, category:article_categories(id, name, slug)'
        )
        .eq('journalist_id', journalistId)
        .order('updated_at', { ascending: false })

      if (qErr) throw qErr

      const mapped = (data ?? []).map((row) => {
        const cat = row.category as
          | { id: string; name: string; slug: string }
          | { id: string; name: string; slug: string }[]
          | null
        return {
          ...row,
          status: row.status as ArticleStatus,
          category: Array.isArray(cat) ? cat[0] ?? null : cat,
        } as ArticleListItem
      })
      setRows(mapped)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setLoading(false)
    }
  }, [supabase])

  useEffect(() => {
    void fetchArticles()
  }, [fetchArticles])

  const unpublish = async (id: string) => {
    setActionId(id)
    setError(null)
    try {
      const { error: updErr } = await supabase
        .from('articles')
        .update({
          status: 'draft',
          published_at: null,
          updated_at: new Date().toISOString(),
        })
        .eq('id', id)
      if (updErr) throw updErr
      await fetchArticles()
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
          <h1 className="text-2xl font-bold text-gray-900">Mes articles</h1>
          <p className="text-sm text-gray-500 mt-1">
            Brouillons et articles publiés sur le portail MFK
          </p>
        </div>
        <div className="flex gap-2">
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={() => void fetchArticles()}
            disabled={loading}
          >
            <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Actualiser
          </Button>
          <Button asChild size="sm" className="bg-[#00A550] hover:bg-[#008040]">
            <Link href="/dashboard/journalist/articles/new">
              <Plus className="w-4 h-4 mr-2" />
              Nouvel article
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
            <p className="text-sm text-gray-500">Aucun article pour le moment.</p>
            <Button asChild className="bg-[#00A550] hover:bg-[#008040]">
              <Link href="/dashboard/journalist/articles/new">
                <Plus className="w-4 h-4 mr-2" />
                Écrire un article
              </Link>
            </Button>
          </div>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Titre</TableHead>
                <TableHead>Catégorie</TableHead>
                <TableHead>Statut</TableHead>
                <TableHead>Date</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {rows.map((row) => (
                <TableRow key={row.id}>
                  <TableCell className="font-medium text-gray-900 max-w-[240px]">
                    <span className="line-clamp-2">{row.title}</span>
                  </TableCell>
                  <TableCell className="text-sm text-gray-600">
                    {row.category?.name ?? '—'}
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
                        <Link href={`/dashboard/journalist/articles/${row.id}`}>
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
