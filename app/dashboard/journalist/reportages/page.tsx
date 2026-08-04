'use client'

import { useCallback, useEffect, useState } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import {
  formatArticleDate,
  getJournalistIdForProfile,
} from '@/lib/articles'
import type { ReportageListItem, ReportageStatus } from '@/lib/reportages'
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

const STATUS_CLASS: Record<ReportageStatus, string> = {
  draft: 'bg-yellow-50 text-yellow-700 border-yellow-200',
  published: 'bg-[#E6F5EE] text-[#00A550] border-green-200',
}

const STATUS_LABEL: Record<ReportageStatus, string> = {
  draft: 'Brouillon',
  published: 'Publié',
}

export default function JournalistReportagesPage() {
  const supabase = createClient()
  const [rows, setRows] = useState<ReportageListItem[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [actionId, setActionId] = useState<string | null>(null)

  const fetchReportages = useCallback(async () => {
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
        .from('reportages')
        .select(
          'id, title, slug, description, audio_url, cover_image_url, status, published_at, created_at, updated_at, category_id, category:article_categories(id, name, slug)'
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
          status: row.status as ReportageStatus,
          category: Array.isArray(cat) ? cat[0] ?? null : cat,
        } as ReportageListItem
      })
      setRows(mapped)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setLoading(false)
    }
  }, [supabase])

  useEffect(() => {
    void fetchReportages()
  }, [fetchReportages])

  const unpublish = async (id: string) => {
    setActionId(id)
    setError(null)
    try {
      const { error: updErr } = await supabase
        .from('reportages')
        .update({
          status: 'draft',
          published_at: null,
          updated_at: new Date().toISOString(),
        })
        .eq('id', id)
      if (updErr) throw updErr
      await fetchReportages()
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
          <h1 className="text-2xl font-bold text-gray-900">Mes reportages</h1>
          <p className="text-sm text-gray-500 mt-1">
            Brouillons et reportages audio publiés sur le portail MFK
          </p>
        </div>
        <div className="flex gap-2">
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={() => void fetchReportages()}
            disabled={loading}
          >
            <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Actualiser
          </Button>
          <Button asChild size="sm" className="bg-[#00A550] hover:bg-[#008040]">
            <Link href="/dashboard/journalist/reportages/new">
              <Plus className="w-4 h-4 mr-2" />
              Nouveau reportage
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
            <p className="text-sm text-gray-500">Aucun reportage pour le moment.</p>
            <Button asChild className="bg-[#00A550] hover:bg-[#008040]">
              <Link href="/dashboard/journalist/reportages/new">
                <Plus className="w-4 h-4 mr-2" />
                Ajouter un reportage
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
                        <Link href={`/dashboard/journalist/reportages/${row.id}`}>
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
