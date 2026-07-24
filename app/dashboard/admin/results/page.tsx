'use client'

import { useState, useEffect, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
} from '@/components/ui/dialog'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  ClipboardList,
  RefreshCw,
  AlertTriangle,
  X,
  CheckCircle2,
  Clock,
  XCircle,
} from 'lucide-react'

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2'
type DraftStatus = 'submitted' | 'validated' | 'rejected'
type StatusFilter = DraftStatus | 'all'

interface ResultDraftRow {
  id: string
  score_eo: number | null
  score_ee: number | null
  score_co: number | null
  score_ce: number | null
  score_langue: number | null
  total_score: number | null
  status: DraftStatus
  admin_notes: string | null
  submitted_at: string | null
  validated_at: string | null
  schools: { school_name: string } | null
  school_students: { first_name: string; last_name: string } | null
  exam_sessions: { title: string; cefr_level: CEFR; exam_date: string } | null
}

const STATUS_CONFIG: Record<
  DraftStatus,
  { label: string; className: string; icon: React.ElementType }
> = {
  submitted: { label: 'Submitted', className: 'bg-blue-50 text-blue-700', icon: Clock },
  validated: { label: 'Validated', className: 'bg-[#E6F5EE] text-[#00A550]', icon: CheckCircle2 },
  rejected: { label: 'Rejected', className: 'bg-red-50 text-red-600', icon: XCircle },
}

const CEFR_COLORS: Record<CEFR, string> = {
  A1: 'bg-slate-100 text-slate-600',
  A2: 'bg-blue-50 text-blue-600',
  B1: 'bg-teal-50 text-teal-600',
  B2: 'bg-[#E6F5EE] text-[#00A550]',
  C1: 'bg-orange-50 text-orange-600',
  C2: 'bg-purple-50 text-purple-700',
}

const SCORE_KEYS = ['score_eo', 'score_ee', 'score_co', 'score_ce', 'score_langue'] as const

export default function AdminResultsPage() {
  const supabase = createClient()

  const [drafts, setDrafts] = useState<ResultDraftRow[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('submitted')
  const [actionId, setActionId] = useState<string | null>(null)

  const [rejectOpen, setRejectOpen] = useState(false)
  const [rejecting, setRejecting] = useState<ResultDraftRow | null>(null)
  const [rejectNotes, setRejectNotes] = useState('')

  const fetchDrafts = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      let query = supabase
        .from('exam_result_drafts')
        .select(`
          id,
          score_eo, score_ee, score_co, score_ce, score_langue,
          total_score,
          status,
          admin_notes,
          submitted_at,
          validated_at,
          schools ( school_name ),
          school_students ( first_name, last_name ),
          exam_sessions ( title, cefr_level, exam_date )
        `)
        .in('status', ['submitted', 'validated', 'rejected'])

      if (statusFilter !== 'all') {
        query = query.eq('status', statusFilter)
      }

      if (statusFilter === 'submitted') {
        query = query.order('submitted_at', { ascending: false })
      } else if (statusFilter === 'validated') {
        query = query.order('validated_at', { ascending: false })
      } else {
        query = query.order('submitted_at', { ascending: false })
      }

      const { data, error: fetchError } = await query
      if (fetchError) throw fetchError

      let rows = (data ?? []) as ResultDraftRow[]
      if (statusFilter === 'all') {
        const priority: Record<DraftStatus, number> = {
          submitted: 0,
          validated: 1,
          rejected: 2,
        }
        rows = [...rows].sort((a, b) => {
          const byStatus = priority[a.status] - priority[b.status]
          if (byStatus !== 0) return byStatus
          const dateA = a.submitted_at ? new Date(a.submitted_at).getTime() : 0
          const dateB = b.submitted_at ? new Date(b.submitted_at).getTime() : 0
          return dateB - dateA
        })
      }

      setDrafts(rows)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load exam results. Please refresh.')
    } finally {
      setLoading(false)
    }
  }, [supabase, statusFilter])

  useEffect(() => {
    fetchDrafts()
  }, [fetchDrafts])

  const handleValidate = async (draft: ResultDraftRow) => {
    setActionId(draft.id)
    setError(null)
    try {
      const { error: updateError } = await supabase
        .from('exam_result_drafts')
        .update({
          status: 'validated',
          validated_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq('id', draft.id)

      if (updateError) throw updateError
      await fetchDrafts()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to validate result.')
    } finally {
      setActionId(null)
    }
  }

  const openReject = (draft: ResultDraftRow) => {
    setRejecting(draft)
    setRejectNotes('')
    setRejectOpen(true)
  }

  const handleReject = async () => {
    if (!rejecting) return
    setActionId(rejecting.id)
    setError(null)
    try {
      const { error: updateError } = await supabase
        .from('exam_result_drafts')
        .update({
          status: 'rejected',
          admin_notes: rejectNotes.trim() || null,
          updated_at: new Date().toISOString(),
        })
        .eq('id', rejecting.id)

      if (updateError) throw updateError
      setRejectOpen(false)
      setRejecting(null)
      setRejectNotes('')
      await fetchDrafts()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to reject result.')
    } finally {
      setActionId(null)
    }
  }

  const getStudentName = (draft: ResultDraftRow) => {
    const s = draft.school_students
    return s ? `${s.last_name} ${s.first_name}` : '—'
  }

  const getSchoolName = (draft: ResultDraftRow) => draft.schools?.school_name ?? '—'

  const renderTable = (rows: ResultDraftRow[]) => (
    <Table>
      <TableHeader>
        <TableRow className="border-gray-100">
          {['School', 'Student', 'Exam Session', 'EO', 'EE', 'CO', 'CE', 'LANGUE', 'Total', 'Status', 'Actions'].map(
            (h) => (
              <TableHead
                key={h}
                className="text-xs text-gray-500 font-medium first:pl-6 last:pr-6 last:text-right"
              >
                {h}
              </TableHead>
            )
          )}
        </TableRow>
      </TableHeader>
      <TableBody>
        {loading ? (
          Array.from({ length: 4 }).map((_, i) => (
            <TableRow key={i}>
              {Array.from({ length: 11 }).map((_, j) => (
                <TableCell key={j}>
                  <div className="h-4 bg-gray-100 rounded animate-pulse w-4/5" />
                </TableCell>
              ))}
            </TableRow>
          ))
        ) : rows.length === 0 ? (
          <TableRow>
            <TableCell colSpan={11} className="text-center py-16">
              <div className="flex flex-col items-center gap-3">
                <div className="w-12 h-12 rounded-xl bg-[#E6F5EE] flex items-center justify-center">
                  <ClipboardList className="w-6 h-6 text-[#00A550]" />
                </div>
                <p className="text-sm font-medium text-gray-700">No results in this category</p>
                <p className="text-xs text-gray-400">
                  {statusFilter === 'submitted'
                    ? 'No exam results are awaiting validation.'
                    : 'Results will appear here once schools submit scores.'}
                </p>
              </div>
            </TableCell>
          </TableRow>
        ) : (
          rows.map((draft) => {
            const cfg = STATUS_CONFIG[draft.status]
            const Icon = cfg.icon
            const session = draft.exam_sessions
            const total = draft.total_score ?? 0
            const isPending = draft.status === 'submitted'
            const busy = actionId === draft.id

            return (
              <TableRow key={draft.id} className="border-gray-50 hover:bg-gray-50/60 transition-colors">
                <TableCell className="pl-6 py-3 text-sm text-gray-700 max-w-[140px] truncate">
                  {getSchoolName(draft)}
                </TableCell>
                <TableCell className="py-3 font-semibold text-gray-900 whitespace-nowrap">
                  {getStudentName(draft)}
                </TableCell>
                <TableCell className="py-3 text-sm text-gray-700">
                  <div>
                    <p className="max-w-[140px] truncate">{session?.title ?? '—'}</p>
                    {session?.cefr_level && (
                      <span
                        className={`text-xs px-1.5 py-0.5 rounded font-bold mt-0.5 inline-block ${CEFR_COLORS[session.cefr_level]}`}
                      >
                        {session.cefr_level}
                      </span>
                    )}
                  </div>
                </TableCell>
                {SCORE_KEYS.map((k) => (
                  <TableCell key={k} className="py-3 text-sm text-gray-700 font-medium">
                    {draft[k] !== null ? draft[k] : <span className="text-gray-300">—</span>}
                  </TableCell>
                ))}
                <TableCell className="py-3">
                  <span className={`text-sm font-bold ${total >= 60 ? 'text-[#00A550]' : 'text-red-600'}`}>
                    {total.toFixed(1)}
                  </span>
                  <span className="text-xs text-gray-400">/100</span>
                </TableCell>
                <TableCell className="py-3">
                  <div className="flex flex-col gap-0.5">
                    <span
                      className={`inline-flex items-center gap-1 text-xs px-2 py-0.5 rounded-full font-medium w-fit ${cfg.className}`}
                    >
                      <Icon className="w-3 h-3" />
                      {cfg.label}
                    </span>
                    {draft.admin_notes && draft.status === 'rejected' && (
                      <p className="text-xs text-red-500 max-w-[140px] truncate" title={draft.admin_notes}>
                        {draft.admin_notes}
                      </p>
                    )}
                  </div>
                </TableCell>
                <TableCell className="py-3 pr-6 text-right">
                  {isPending ? (
                    <div className="flex items-center justify-end gap-1.5">
                      <Button
                        size="sm"
                        disabled={busy}
                        onClick={() => handleValidate(draft)}
                        className="h-7 px-2.5 text-xs bg-[#00A550] hover:bg-[#008040] text-white"
                      >
                        {busy ? <RefreshCw className="w-3 h-3 animate-spin" /> : 'Valider'}
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        disabled={busy}
                        onClick={() => openReject(draft)}
                        className="h-7 px-2.5 text-xs border-gray-200 text-red-500 hover:border-red-300 hover:text-red-600 hover:bg-red-50"
                      >
                        Rejeter
                      </Button>
                    </div>
                  ) : (
                    <span className="text-xs text-gray-400">—</span>
                  )}
                </TableCell>
              </TableRow>
            )
          })
        )}
      </TableBody>
    </Table>
  )

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Exam Results</h1>
          <p className="text-sm text-gray-500 mt-1">
            Review and validate exam scores submitted by schools.
          </p>
        </div>
        <Button variant="outline" size="sm" onClick={fetchDrafts} disabled={loading}>
          <RefreshCw className={`w-4 h-4 mr-1.5 ${loading ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          <span className="flex-1">{error}</span>
          <button onClick={() => setError(null)}>
            <X className="w-4 h-4 text-red-400 hover:text-red-600" />
          </button>
        </div>
      )}

      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-[#E6F5EE] flex items-center justify-center">
              <ClipboardList className="w-4 h-4 text-[#00A550]" />
            </div>
            <CardTitle className="text-base font-semibold">
              Submitted Results
              {!loading && statusFilter === 'submitted' && (
                <span className="ml-2 text-sm font-normal text-gray-400">({drafts.length})</span>
              )}
            </CardTitle>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          <Tabs
            value={statusFilter}
            onValueChange={(v) => setStatusFilter(v as StatusFilter)}
            className="w-full"
          >
            <div className="px-6 pb-3">
              <TabsList className="bg-gray-100">
                <TabsTrigger value="submitted">Pending Review</TabsTrigger>
                <TabsTrigger value="validated">Validated</TabsTrigger>
                <TabsTrigger value="rejected">Rejected</TabsTrigger>
                <TabsTrigger value="all">All</TabsTrigger>
              </TabsList>
            </div>

            <TabsContent value={statusFilter} className="mt-0">
              {renderTable(drafts)}
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>

      <Dialog open={rejectOpen} onOpenChange={setRejectOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Reject Exam Results</DialogTitle>
            <DialogDescription className="text-sm text-gray-500">
              {rejecting && (
                <>
                  Reject results for{' '}
                  <span className="font-semibold text-gray-700">{getStudentName(rejecting)}</span>
                  {' '}at{' '}
                  <span className="font-semibold text-gray-700">{getSchoolName(rejecting)}</span>.
                  The school will be able to revise and resubmit.
                </>
              )}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-2 py-2">
            <Label htmlFor="admin_notes" className="text-sm text-gray-700">
              Reason for rejection <span className="text-gray-400 font-normal">(optional)</span>
            </Label>
            <Textarea
              id="admin_notes"
              placeholder="e.g., Score mismatch on CO component…"
              value={rejectNotes}
              onChange={(e) => setRejectNotes(e.target.value)}
              className="border-gray-200 focus:border-[#00A550] min-h-[90px]"
            />
          </div>
          <DialogFooter className="gap-2">
            <Button
              variant="outline"
              onClick={() => setRejectOpen(false)}
              disabled={actionId === rejecting?.id}
              className="border-gray-200"
            >
              Cancel
            </Button>
            <Button
              onClick={handleReject}
              disabled={actionId === rejecting?.id}
              className="bg-red-600 hover:bg-red-700 text-white"
            >
              {actionId === rejecting?.id ? 'Rejecting…' : 'Confirm Rejection'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
