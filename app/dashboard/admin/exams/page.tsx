'use client'

import { useState, useEffect, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import {
  Plus,
  Pencil,
  Trash2,
  RefreshCw,
  FileText,
  Calendar,
  MapPin,
  Users,
  X,
  AlertTriangle,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
} from '@/components/ui/dialog'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Label } from '@/components/ui/label'

// ─── Types ─────────────────────────────────────────────────────────────────────

type SessionStatus = 'upcoming' | 'ongoing' | 'completed' | 'cancelled'
type CefrLevel = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2'

interface ExamSession {
  id: string
  title: string
  cefr_level: CefrLevel
  exam_date: string
  registration_deadline: string | null
  price_rwf: number
  venue: string | null
  max_candidates: number | null
  retake_waiting_days: number | null
  status: SessionStatus
  created_at: string
}

interface SessionFormData {
  title: string
  cefr_level: CefrLevel | ''
  exam_date: string
  registration_deadline: string
  price_rwf: string
  venue: string
  max_candidates: string
  retake_waiting_days: string
}

const EMPTY_FORM: SessionFormData = {
  title: '',
  cefr_level: '',
  exam_date: '',
  registration_deadline: '',
  price_rwf: '',
  venue: '',
  max_candidates: '',
  retake_waiting_days: '',
}

const CEFR_LEVELS: CefrLevel[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']

const STATUS_CONFIG: Record<
  SessionStatus,
  { label: string; className: string }
> = {
  upcoming: {
    label: 'Upcoming',
    className: 'bg-blue-50 text-blue-700 border border-blue-200',
  },
  ongoing: {
    label: 'Ongoing',
    className: 'bg-[#E6F5EE] text-[#00A550] border border-green-200',
  },
  completed: {
    label: 'Completed',
    className: 'bg-gray-100 text-gray-600 border border-gray-200',
  },
  cancelled: {
    label: 'Cancelled',
    className: 'bg-red-50 text-red-600 border border-red-200',
  },
}

const CEFR_COLORS: Record<CefrLevel, string> = {
  A1: 'bg-slate-100 text-slate-600',
  A2: 'bg-blue-50 text-blue-600',
  B1: 'bg-teal-50 text-teal-600',
  B2: 'bg-[#E6F5EE] text-[#00A550]',
  C1: 'bg-orange-50 text-orange-600',
  C2: 'bg-purple-50 text-purple-700',
}

// ─── Form Validation ────────────────────────────────────────────────────────────

function validateForm(data: SessionFormData): Partial<Record<keyof SessionFormData, string>> {
  const errors: Partial<Record<keyof SessionFormData, string>> = {}

  if (!data.title.trim()) errors.title = 'Title is required'
  if (!data.cefr_level) errors.cefr_level = 'CEFR level is required'
  if (!data.exam_date) errors.exam_date = 'Exam date is required'
  if (!data.price_rwf || isNaN(Number(data.price_rwf)) || Number(data.price_rwf) < 0) {
    errors.price_rwf = 'Valid price is required'
  }
  if (data.max_candidates && (isNaN(Number(data.max_candidates)) || Number(data.max_candidates) < 1)) {
    errors.max_candidates = 'Must be a positive number'
  }
  if (data.retake_waiting_days && (isNaN(Number(data.retake_waiting_days)) || Number(data.retake_waiting_days) < 0)) {
    errors.retake_waiting_days = 'Must be a non-negative number'
  }
  if (
    data.registration_deadline &&
    data.exam_date &&
    new Date(data.registration_deadline) >= new Date(data.exam_date)
  ) {
    errors.registration_deadline = 'Deadline must be before the exam date'
  }

  return errors
}

// ─── Page Component ─────────────────────────────────────────────────────────────

export default function AdminExamsPage() {
  const supabase = createClient()

  const [sessions, setSessions] = useState<ExamSession[]>([])
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Dialog states
  const [formOpen, setFormOpen] = useState(false)
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false)
  const [editingSession, setEditingSession] = useState<ExamSession | null>(null)
  const [deletingSession, setDeletingSession] = useState<ExamSession | null>(null)

  // Form state
  const [form, setForm] = useState<SessionFormData>(EMPTY_FORM)
  const [formErrors, setFormErrors] = useState<Partial<Record<keyof SessionFormData, string>>>({})

  // ── Data fetching ────────────────────────────────────────────────────────────

  const fetchSessions = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const { data, error: fetchError } = await supabase
        .from('exam_sessions')
        .select(
          'id, title, cefr_level, exam_date, registration_deadline, price_rwf, venue, max_candidates, retake_waiting_days, status, created_at'
        )
        .order('exam_date', { ascending: false })

      if (fetchError) throw fetchError
      setSessions(data ?? [])
    } catch {
      setError('Failed to load exam sessions. Please try again.')
    } finally {
      setLoading(false)
    }
  }, [supabase])

  useEffect(() => {
    fetchSessions()
  }, [fetchSessions])

  // ── Dialog helpers ───────────────────────────────────────────────────────────

  const openCreateForm = () => {
    setEditingSession(null)
    setForm(EMPTY_FORM)
    setFormErrors({})
    setFormOpen(true)
  }

  const openEditForm = (session: ExamSession) => {
    setEditingSession(session)
    setForm({
      title: session.title,
      cefr_level: session.cefr_level,
      exam_date: session.exam_date
        ? session.exam_date.split('T')[0]
        : '',
      registration_deadline: session.registration_deadline
        ? session.registration_deadline.split('T')[0]
        : '',
      price_rwf: session.price_rwf?.toString() ?? '',
      venue: session.venue ?? '',
      max_candidates: session.max_candidates?.toString() ?? '',
      retake_waiting_days: session.retake_waiting_days?.toString() ?? '',
    })
    setFormErrors({})
    setFormOpen(true)
  }

  const openDeleteConfirm = (session: ExamSession) => {
    setDeletingSession(session)
    setDeleteConfirmOpen(true)
  }

  const updateField = <K extends keyof SessionFormData>(
    field: K,
    value: SessionFormData[K]
  ) => {
    setForm((prev) => ({ ...prev, [field]: value }))
    if (formErrors[field]) {
      setFormErrors((prev) => ({ ...prev, [field]: undefined }))
    }
  }

  // ── Submit ───────────────────────────────────────────────────────────────────

  const handleSubmit = async () => {
    const errors = validateForm(form)
    if (Object.keys(errors).length > 0) {
      setFormErrors(errors)
      return
    }

    setSubmitting(true)
    setError(null)

    const payload = {
      title: form.title.trim(),
      cefr_level: form.cefr_level as CefrLevel,
      exam_date: form.exam_date,
      registration_deadline: form.registration_deadline || null,
      price_rwf: Number(form.price_rwf),
      venue: form.venue.trim() || null,
      max_candidates: form.max_candidates ? Number(form.max_candidates) : null,
      retake_waiting_days: form.retake_waiting_days
        ? Number(form.retake_waiting_days)
        : null,
      status: 'upcoming' as SessionStatus,
    }

    try {
      if (editingSession) {
        const { error: updateError } = await supabase
          .from('exam_sessions')
          .update(payload)
          .eq('id', editingSession.id)

        if (updateError) throw updateError

        setSessions((prev) =>
          prev.map((s) =>
            s.id === editingSession.id
              ? { ...s, ...payload }
              : s
          )
        )
      } else {
        const { data: newSession, error: insertError } = await supabase
          .from('exam_sessions')
          .insert(payload)
          .select()
          .maybeSingle()

        if (insertError) throw insertError
        if (newSession) {
          setSessions((prev) => [newSession, ...prev])
        }
      }

      setFormOpen(false)
    } catch (err: unknown) {
      const msg =
        err instanceof Error ? err.message : 'Failed to save. Please try again.'
      setError(msg)
    } finally {
      setSubmitting(false)
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────────

  const handleDelete = async () => {
    if (!deletingSession) return

    setSubmitting(true)
    setError(null)
    try {
      const { error: deleteError } = await supabase
        .from('exam_sessions')
        .delete()
        .eq('id', deletingSession.id)

      if (deleteError) throw deleteError

      setSessions((prev) => prev.filter((s) => s.id !== deletingSession.id))
      setDeleteConfirmOpen(false)
      setDeletingSession(null)
    } catch {
      setError('Failed to delete session. Please try again.')
    } finally {
      setSubmitting(false)
    }
  }

  // ─── Render ────────────────────────────────────────────────────────────────

  return (
    <div className="p-6 space-y-6">
      {/* Page header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Exam Sessions</h1>
          <p className="text-sm text-gray-500 mt-1">
            Manage DELF/DALF French exam sessions.
          </p>
        </div>
        <div className="flex items-center gap-2 self-start sm:self-auto">
          <Button
            variant="outline"
            size="sm"
            onClick={fetchSessions}
            disabled={loading}
            className="flex items-center gap-1.5"
          >
            <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </Button>
          <Button
            onClick={openCreateForm}
            className="bg-[#00A550] hover:bg-[#008040] text-white flex items-center gap-1.5"
          >
            <Plus className="w-4 h-4" />
            Create New Session
          </Button>
        </div>
      </div>

      {/* Error banner */}
      {error && (
        <div className="rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700 flex items-start gap-2">
          <AlertTriangle className="w-4 h-4 mt-0.5 flex-shrink-0" />
          {error}
          <button
            onClick={() => setError(null)}
            className="ml-auto text-red-400 hover:text-red-600"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* Sessions table */}
      <Card className="border-0 shadow-sm">
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow className="border-gray-100">
                <TableHead className="text-xs text-gray-500 font-medium pl-6">
                  Session
                </TableHead>
                <TableHead className="text-xs text-gray-500 font-medium">
                  Level
                </TableHead>
                <TableHead className="text-xs text-gray-500 font-medium">
                  Date
                </TableHead>
                <TableHead className="text-xs text-gray-500 font-medium">
                  Venue
                </TableHead>
                <TableHead className="text-xs text-gray-500 font-medium">
                  Capacity
                </TableHead>
                <TableHead className="text-xs text-gray-500 font-medium">
                  Price
                </TableHead>
                <TableHead className="text-xs text-gray-500 font-medium">
                  Status
                </TableHead>
                <TableHead className="text-xs text-gray-500 font-medium pr-6 text-right">
                  Actions
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {loading ? (
                Array.from({ length: 4 }).map((_, i) => (
                  <TableRow key={i} className="border-gray-50">
                    {Array.from({ length: 8 }).map((_, j) => (
                      <TableCell key={j} className="py-4">
                        <div className="h-4 rounded bg-gray-100 animate-pulse w-4/5" />
                      </TableCell>
                    ))}
                  </TableRow>
                ))
              ) : sessions.length === 0 ? (
                <TableRow>
                  <TableCell
                    colSpan={8}
                    className="text-center py-20 text-gray-500"
                  >
                    <div className="flex flex-col items-center gap-3">
                      <div className="w-12 h-12 rounded-xl bg-[#E6F5EE] flex items-center justify-center">
                        <FileText className="w-6 h-6 text-[#00A550]" />
                      </div>
                      <p className="text-sm font-medium text-gray-700">
                        No exam sessions yet
                      </p>
                      <p className="text-xs text-gray-400">
                        Create the first session to get started.
                      </p>
                      <Button
                        onClick={openCreateForm}
                        className="mt-1 bg-[#00A550] hover:bg-[#008040] text-white text-sm"
                      >
                        <Plus className="w-4 h-4 mr-1" />
                        Create New Session
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ) : (
                sessions.map((session) => {
                  const statusCfg =
                    STATUS_CONFIG[session.status] ?? STATUS_CONFIG.upcoming
                  const levelColor =
                    CEFR_COLORS[session.cefr_level] ?? 'bg-gray-100 text-gray-600'

                  return (
                    <TableRow
                      key={session.id}
                      className="border-gray-50 hover:bg-gray-50/70 transition-colors"
                    >
                      {/* Title */}
                      <TableCell className="pl-6 py-4">
                        <p className="text-sm font-semibold text-gray-900 max-w-[180px] truncate">
                          {session.title}
                        </p>
                        {session.registration_deadline && (
                          <p className="text-xs text-gray-400 mt-0.5 flex items-center gap-1">
                            <Calendar className="w-3 h-3" />
                            Reg. deadline:{' '}
                            {new Date(
                              session.registration_deadline
                            ).toLocaleDateString('en-RW', {
                              day: 'numeric',
                              month: 'short',
                            })}
                          </p>
                        )}
                      </TableCell>

                      {/* Level */}
                      <TableCell className="py-4">
                        <span
                          className={`text-xs px-2.5 py-1 rounded font-bold ${levelColor}`}
                        >
                          {session.cefr_level}
                        </span>
                      </TableCell>

                      {/* Date */}
                      <TableCell className="py-4">
                        <p className="text-sm text-gray-700 flex items-center gap-1.5">
                          <Calendar className="w-3.5 h-3.5 text-gray-400" />
                          {new Date(session.exam_date).toLocaleDateString(
                            'en-RW',
                            {
                              weekday: 'short',
                              day: 'numeric',
                              month: 'short',
                              year: 'numeric',
                            }
                          )}
                        </p>
                      </TableCell>

                      {/* Venue */}
                      <TableCell className="py-4">
                        <p className="text-sm text-gray-600 flex items-center gap-1.5 max-w-[130px] truncate">
                          <MapPin className="w-3.5 h-3.5 text-gray-400 flex-shrink-0" />
                          {session.venue ?? '—'}
                        </p>
                      </TableCell>

                      {/* Capacity */}
                      <TableCell className="py-4">
                        <p className="text-sm text-gray-700 flex items-center gap-1.5">
                          <Users className="w-3.5 h-3.5 text-gray-400" />
                          {session.max_candidates != null
                            ? session.max_candidates.toLocaleString()
                            : '∞'}
                        </p>
                      </TableCell>

                      {/* Price */}
                      <TableCell className="py-4">
                        <p className="text-sm font-medium text-gray-900">
                          {(session.price_rwf ?? 0).toLocaleString('en-RW')}
                          <span className="text-xs font-normal text-gray-400 ml-1">
                            RWF
                          </span>
                        </p>
                      </TableCell>

                      {/* Status */}
                      <TableCell className="py-4">
                        <span
                          className={`text-xs px-2.5 py-1 rounded-full font-medium capitalize ${statusCfg.className}`}
                        >
                          {statusCfg.label}
                        </span>
                      </TableCell>

                      {/* Actions */}
                      <TableCell className="py-4 pr-6 text-right">
                        <div className="flex items-center justify-end gap-1.5">
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={() => openEditForm(session)}
                            className="h-7 w-7 p-0 border-gray-200 hover:border-[#00A550] hover:text-[#00A550]"
                            title="Edit session"
                          >
                            <Pencil className="w-3.5 h-3.5" />
                          </Button>
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={() => openDeleteConfirm(session)}
                            className="h-7 w-7 p-0 border-gray-200 text-red-400 hover:border-red-300 hover:text-red-600 hover:bg-red-50"
                            title="Delete session"
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  )
                })
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* ── Create / Edit Dialog ─────────────────────────────────────────────── */}
      <Dialog open={formOpen} onOpenChange={setFormOpen}>
        <DialogContent className="sm:max-w-lg max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="text-lg font-semibold text-gray-900">
              {editingSession ? 'Edit Exam Session' : 'Create New Exam Session'}
            </DialogTitle>
            <DialogDescription className="text-sm text-gray-500">
              {editingSession
                ? 'Update the details for this exam session.'
                : 'Fill in the details to create a new exam session.'}
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-2">
            {/* Title */}
            <div className="space-y-1.5">
              <Label htmlFor="title" className="text-sm font-medium text-gray-700">
                Session Title <span className="text-red-500">*</span>
              </Label>
              <Input
                id="title"
                placeholder="e.g., DELF B2 – Session Juin 2026"
                value={form.title}
                onChange={(e) => updateField('title', e.target.value)}
                className={formErrors.title ? 'border-red-300 focus:border-red-400' : 'border-gray-200 focus:border-[#00A550]'}
              />
              {formErrors.title && (
                <p className="text-xs text-red-600">{formErrors.title}</p>
              )}
            </div>

            {/* CEFR Level */}
            <div className="space-y-1.5">
              <Label className="text-sm font-medium text-gray-700">
                CEFR Level <span className="text-red-500">*</span>
              </Label>
              <Select
                value={form.cefr_level}
                onValueChange={(val) => updateField('cefr_level', val as CefrLevel)}
              >
                <SelectTrigger
                  className={formErrors.cefr_level ? 'border-red-300' : 'border-gray-200 focus:border-[#00A550]'}
                >
                  <SelectValue placeholder="Select level…" />
                </SelectTrigger>
                <SelectContent>
                  {CEFR_LEVELS.map((level) => (
                    <SelectItem key={level} value={level}>
                      <span className="font-semibold">{level}</span>
                      {' — '}
                      {
                        {
                          A1: 'Beginner',
                          A2: 'Elementary',
                          B1: 'Intermediate',
                          B2: 'Upper-Intermediate',
                          C1: 'Advanced',
                          C2: 'Mastery',
                        }[level]
                      }
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              {formErrors.cefr_level && (
                <p className="text-xs text-red-600">{formErrors.cefr_level}</p>
              )}
            </div>

            {/* Dates row */}
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <Label htmlFor="exam_date" className="text-sm font-medium text-gray-700">
                  Exam Date <span className="text-red-500">*</span>
                </Label>
                <Input
                  id="exam_date"
                  type="date"
                  value={form.exam_date}
                  onChange={(e) => updateField('exam_date', e.target.value)}
                  className={formErrors.exam_date ? 'border-red-300' : 'border-gray-200 focus:border-[#00A550]'}
                />
                {formErrors.exam_date && (
                  <p className="text-xs text-red-600">{formErrors.exam_date}</p>
                )}
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="reg_deadline" className="text-sm font-medium text-gray-700">
                  Registration Deadline
                </Label>
                <Input
                  id="reg_deadline"
                  type="date"
                  value={form.registration_deadline}
                  onChange={(e) =>
                    updateField('registration_deadline', e.target.value)
                  }
                  className={formErrors.registration_deadline ? 'border-red-300' : 'border-gray-200 focus:border-[#00A550]'}
                />
                {formErrors.registration_deadline && (
                  <p className="text-xs text-red-600">{formErrors.registration_deadline}</p>
                )}
              </div>
            </div>

            {/* Price */}
            <div className="space-y-1.5">
              <Label htmlFor="price" className="text-sm font-medium text-gray-700">
                Price (RWF) <span className="text-red-500">*</span>
              </Label>
              <div className="relative">
                <Input
                  id="price"
                  type="number"
                  min="0"
                  placeholder="e.g., 45000"
                  value={form.price_rwf}
                  onChange={(e) => updateField('price_rwf', e.target.value)}
                  className={`pr-12 ${formErrors.price_rwf ? 'border-red-300' : 'border-gray-200 focus:border-[#00A550]'}`}
                />
                <span className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-gray-400 font-medium">
                  RWF
                </span>
              </div>
              {formErrors.price_rwf && (
                <p className="text-xs text-red-600">{formErrors.price_rwf}</p>
              )}
            </div>

            {/* Venue */}
            <div className="space-y-1.5">
              <Label htmlFor="venue" className="text-sm font-medium text-gray-700">
                Venue
              </Label>
              <Input
                id="venue"
                placeholder="e.g., Alliance Française Kigali"
                value={form.venue}
                onChange={(e) => updateField('venue', e.target.value)}
                className="border-gray-200 focus:border-[#00A550]"
              />
            </div>

            {/* Max candidates + retake waiting days */}
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <Label htmlFor="max_candidates" className="text-sm font-medium text-gray-700">
                  Max Candidates
                </Label>
                <Input
                  id="max_candidates"
                  type="number"
                  min="1"
                  placeholder="Unlimited if blank"
                  value={form.max_candidates}
                  onChange={(e) =>
                    updateField('max_candidates', e.target.value)
                  }
                  className={formErrors.max_candidates ? 'border-red-300' : 'border-gray-200 focus:border-[#00A550]'}
                />
                {formErrors.max_candidates && (
                  <p className="text-xs text-red-600">{formErrors.max_candidates}</p>
                )}
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="retake_days" className="text-sm font-medium text-gray-700">
                  Retake Waiting (days)
                </Label>
                <Input
                  id="retake_days"
                  type="number"
                  min="0"
                  placeholder="e.g., 90"
                  value={form.retake_waiting_days}
                  onChange={(e) =>
                    updateField('retake_waiting_days', e.target.value)
                  }
                  className={formErrors.retake_waiting_days ? 'border-red-300' : 'border-gray-200 focus:border-[#00A550]'}
                />
                {formErrors.retake_waiting_days && (
                  <p className="text-xs text-red-600">{formErrors.retake_waiting_days}</p>
                )}
              </div>
            </div>
          </div>

          <DialogFooter className="gap-2 pt-2">
            <Button
              variant="outline"
              onClick={() => setFormOpen(false)}
              disabled={submitting}
              className="border-gray-200"
            >
              Cancel
            </Button>
            <Button
              onClick={handleSubmit}
              disabled={submitting}
              className="bg-[#00A550] hover:bg-[#008040] text-white min-w-[100px]"
            >
              {submitting
                ? 'Saving…'
                : editingSession
                ? 'Save Changes'
                : 'Create Session'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Delete Confirmation Dialog ────────────────────────────────────────── */}
      <Dialog open={deleteConfirmOpen} onOpenChange={setDeleteConfirmOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-red-50 flex items-center justify-center flex-shrink-0">
                <AlertTriangle className="w-5 h-5 text-red-600" />
              </div>
              <DialogTitle className="text-lg font-semibold text-gray-900">
                Delete Exam Session
              </DialogTitle>
            </div>
            <DialogDescription className="text-sm text-gray-500 mt-2 ml-13">
              Are you sure you want to delete{' '}
              <span className="font-semibold text-gray-700">
                &ldquo;{deletingSession?.title}&rdquo;
              </span>
              ? This action cannot be undone and may affect registered candidates.
            </DialogDescription>
          </DialogHeader>

          <DialogFooter className="gap-2">
            <Button
              variant="outline"
              onClick={() => {
                setDeleteConfirmOpen(false)
                setDeletingSession(null)
              }}
              disabled={submitting}
              className="border-gray-200"
            >
              Cancel
            </Button>
            <Button
              onClick={handleDelete}
              disabled={submitting}
              className="bg-red-600 hover:bg-red-700 text-white"
            >
              {submitting ? 'Deleting…' : 'Delete Session'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
