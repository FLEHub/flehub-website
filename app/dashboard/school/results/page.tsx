'use client'

import { useState, useEffect, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
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
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  ClipboardList,
  Plus,
  Pencil,
  RefreshCw,
  AlertTriangle,
  X,
  Send,
  Save,
  CheckCircle2,
  Clock,
  XCircle,
} from 'lucide-react'

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2'

interface Student {
  id: string
  first_name: string
  last_name: string
  cefr_level: CEFR | null
}

interface ExamSession {
  id: string
  title: string
  cefr_level: CEFR
  exam_date: string
}

type DraftStatus = 'draft' | 'submitted' | 'validated' | 'rejected'

interface ResultDraft {
  id: string
  school_student_id: string
  exam_session_id: string
  score_eo: number | null
  score_ee: number | null
  score_co: number | null
  score_ce: number | null
  score_langue: number | null
  total_score: number | null
  status: DraftStatus
  admin_notes: string | null
  submitted_at: string | null
}

interface ScoreForm {
  student_id: string
  session_id: string
  score_eo: string
  score_ee: string
  score_co: string
  score_ce: string
  score_langue: string
}

const EMPTY_SCORES: ScoreForm = {
  student_id: '', session_id: '',
  score_eo: '', score_ee: '', score_co: '', score_ce: '', score_langue: '',
}

const COMPS: { key: keyof ScoreForm; label: string; col: string }[] = [
  { key: 'score_eo', label: 'EO', col: 'Expression Orale' },
  { key: 'score_ee', label: 'EE', col: 'Expression Écrite' },
  { key: 'score_co', label: 'CO', col: 'Compréhension Orale' },
  { key: 'score_ce', label: 'CE', col: 'Compréhension Écrite' },
  { key: 'score_langue', label: 'LANGUE', col: 'Étude de la Langue' },
]

const STATUS_CONFIG: Record<DraftStatus, { label: string; className: string; icon: React.ElementType }> = {
  draft: { label: 'Draft', className: 'bg-gray-100 text-gray-600', icon: Save },
  submitted: { label: 'Submitted', className: 'bg-blue-50 text-blue-700', icon: Clock },
  validated: { label: 'Validated', className: 'bg-[#E6F5EE] text-[#00A550]', icon: CheckCircle2 },
  rejected: { label: 'Rejected', className: 'bg-red-50 text-red-600', icon: XCircle },
}

const CEFR_COLORS: Record<CEFR, string> = {
  A1: 'bg-slate-100 text-slate-600', A2: 'bg-blue-50 text-blue-600',
  B1: 'bg-teal-50 text-teal-600', B2: 'bg-[#E6F5EE] text-[#00A550]',
  C1: 'bg-orange-50 text-orange-600', C2: 'bg-purple-50 text-purple-700',
}

function calcTotal(form: ScoreForm) {
  return ['score_eo', 'score_ee', 'score_co', 'score_ce', 'score_langue'].reduce(
    (s, k) => s + (parseFloat((form as any)[k]) || 0), 0
  )
}

export default function SchoolResultsPage() {
  const supabase = createClient()

  const [schoolId, setSchoolId] = useState<string | null>(null)
  const [students, setStudents] = useState<Student[]>([])
  const [sessions, setSessions] = useState<ExamSession[]>([])
  const [drafts, setDrafts] = useState<ResultDraft[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const [formOpen, setFormOpen] = useState(false)
  const [editing, setEditing] = useState<ResultDraft | null>(null)
  const [form, setForm] = useState<ScoreForm>(EMPTY_SCORES)
  const [saving, setSaving] = useState(false)
  const [submitAction, setSubmitAction] = useState<'draft' | 'submit'>('draft')

  const getSchoolId = useCallback(async () => {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return null
    const { data } = await supabase.from('schools').select('id').eq('profile_id', user.id).maybeSingle()
    return data?.id ?? null
  }, [supabase])

  const fetchAll = useCallback(async (sid: string) => {
    const [studs, sess, drs] = await Promise.all([
      supabase.from('school_students').select('id, first_name, last_name, cefr_level').eq('school_id', sid).order('last_name'),
      supabase.from('exam_sessions').select('id, title, cefr_level, exam_date').in('status', ['upcoming', 'ongoing']).order('exam_date'),
      supabase.from('exam_result_drafts').select('id, school_student_id, exam_session_id, score_eo, score_ee, score_co, score_ce, score_langue, total_score, status, admin_notes, submitted_at').eq('school_id', sid).order('created_at', { ascending: false }),
    ])
    if (studs.error) throw studs.error
    if (drs.error) throw drs.error
    setStudents(studs.data ?? [])
    setSessions(sess.data ?? [])
    setDrafts(drs.data ?? [])
  }, [supabase])

  const loadAll = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const sid = schoolId ?? await getSchoolId()
      if (!sid) { setLoading(false); return }
      if (!schoolId) setSchoolId(sid)
      await fetchAll(sid)
    } catch { setError('Failed to load results. Please refresh.') }
    finally { setLoading(false) }
  }, [schoolId, getSchoolId, fetchAll])

  useEffect(() => { loadAll() }, [loadAll])

  const openCreate = () => { setEditing(null); setForm(EMPTY_SCORES); setFormOpen(true) }
  const openEdit = (d: ResultDraft) => {
    if (d.status === 'submitted' || d.status === 'validated') return
    setEditing(d)
    setForm({
      student_id: d.school_student_id,
      session_id: d.exam_session_id,
      score_eo: d.score_eo?.toString() ?? '',
      score_ee: d.score_ee?.toString() ?? '',
      score_co: d.score_co?.toString() ?? '',
      score_ce: d.score_ce?.toString() ?? '',
      score_langue: d.score_langue?.toString() ?? '',
    })
    setFormOpen(true)
  }

  const handleSave = async (action: 'draft' | 'submit') => {
    if (!schoolId || !form.student_id || !form.session_id) return
    setSaving(true)
    setError(null)
    setSubmitAction(action)
    try {
      const payload: Record<string, unknown> = {
        school_id: schoolId,
        school_student_id: form.student_id,
        exam_session_id: form.session_id,
        score_eo: parseFloat(form.score_eo) || null,
        score_ee: parseFloat(form.score_ee) || null,
        score_co: parseFloat(form.score_co) || null,
        score_ce: parseFloat(form.score_ce) || null,
        score_langue: parseFloat(form.score_langue) || null,
        status: action === 'submit' ? 'submitted' : 'draft',
        submitted_at: action === 'submit' ? new Date().toISOString() : null,
        updated_at: new Date().toISOString(),
      }
      if (editing) {
        const { error: err } = await supabase.from('exam_result_drafts').update(payload).eq('id', editing.id)
        if (err) throw err
      } else {
        const { error: err } = await supabase.from('exam_result_drafts').insert(payload)
        if (err) throw err
      }
      setFormOpen(false)
      await fetchAll(schoolId)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setSaving(false)
    }
  }

  const getStudentName = (id: string) => {
    const s = students.find((st) => st.id === id)
    return s ? `${s.last_name} ${s.first_name}` : '—'
  }
  const getSessionTitle = (id: string) => sessions.find((s) => s.id === id)?.title ?? '—'
  const getSessionLevel = (id: string) => sessions.find((s) => s.id === id)?.cefr_level

  return (
    <div className="p-6 space-y-6 max-w-6xl mx-auto">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Exam Results</h1>
          <p className="text-sm text-gray-500 mt-1">Enter and submit scores per student per competency.</p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" onClick={loadAll} disabled={loading}>
            <RefreshCw className={`w-4 h-4 mr-1.5 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </Button>
          <Button size="sm" className="bg-[#00A550] hover:bg-[#008040] text-white" onClick={openCreate}>
            <Plus className="w-4 h-4 mr-1.5" />
            Enter Results
          </Button>
        </div>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          <span className="flex-1">{error}</span>
          <button onClick={() => setError(null)}><X className="w-4 h-4 text-red-400 hover:text-red-600" /></button>
        </div>
      )}

      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-[#E6F5EE] flex items-center justify-center">
              <ClipboardList className="w-4 h-4 text-[#00A550]" />
            </div>
            <CardTitle className="text-base font-semibold">
              All Results
              {!loading && <span className="ml-2 text-sm font-normal text-gray-400">({drafts.length})</span>}
            </CardTitle>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow className="border-gray-100">
                {['Student', 'Exam Session', 'EO', 'EE', 'CO', 'CE', 'LANGUE', 'Total', 'Status', 'Actions'].map((h) => (
                  <TableHead key={h} className="text-xs text-gray-500 font-medium first:pl-6 last:pr-6 last:text-right">{h}</TableHead>
                ))}
              </TableRow>
            </TableHeader>
            <TableBody>
              {loading ? (
                Array.from({ length: 4 }).map((_, i) => (
                  <TableRow key={i}>
                    {Array.from({ length: 10 }).map((_, j) => (
                      <TableCell key={j}><div className="h-4 bg-gray-100 rounded animate-pulse w-4/5" /></TableCell>
                    ))}
                  </TableRow>
                ))
              ) : drafts.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={10} className="text-center py-16">
                    <div className="flex flex-col items-center gap-3">
                      <div className="w-12 h-12 rounded-xl bg-[#E6F5EE] flex items-center justify-center">
                        <ClipboardList className="w-6 h-6 text-[#00A550]" />
                      </div>
                      <p className="text-sm font-medium text-gray-700">No results entered yet</p>
                      <p className="text-xs text-gray-400">Click "Enter Results" to add scores for a student.</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : (
                drafts.map((d) => {
                  const cfg = STATUS_CONFIG[d.status]
                  const Icon = cfg.icon
                  const level = getSessionLevel(d.exam_session_id)
                  const total = d.total_score ?? 0
                  const editable = d.status === 'draft' || d.status === 'rejected'

                  return (
                    <TableRow key={d.id} className="border-gray-50 hover:bg-gray-50/50 transition-colors">
                      <TableCell className="pl-6 py-3 font-semibold text-gray-900 whitespace-nowrap">
                        {getStudentName(d.school_student_id)}
                      </TableCell>
                      <TableCell className="py-3 text-sm text-gray-700">
                        <div>
                          <p className="max-w-[140px] truncate">{getSessionTitle(d.exam_session_id)}</p>
                          {level && <span className={`text-xs px-1.5 py-0.5 rounded font-bold mt-0.5 inline-block ${CEFR_COLORS[level]}`}>{level}</span>}
                        </div>
                      </TableCell>
                      {(['score_eo', 'score_ee', 'score_co', 'score_ce', 'score_langue'] as const).map((k) => (
                        <TableCell key={k} className="py-3 text-sm text-gray-700 font-medium">
                          {(d as any)[k] !== null ? (d as any)[k] : <span className="text-gray-300">—</span>}
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
                          <span className={`inline-flex items-center gap-1 text-xs px-2 py-0.5 rounded-full font-medium w-fit ${cfg.className}`}>
                            <Icon className="w-3 h-3" />
                            {cfg.label}
                          </span>
                          {d.admin_notes && d.status === 'rejected' && (
                            <p className="text-xs text-red-500 max-w-[120px] truncate">{d.admin_notes}</p>
                          )}
                        </div>
                      </TableCell>
                      <TableCell className="py-3 pr-6 text-right">
                        {editable && (
                          <Button size="sm" variant="outline" onClick={() => openEdit(d)}
                            className="h-7 w-7 p-0 border-gray-200 hover:border-[#00A550] hover:text-[#00A550]">
                            <Pencil className="w-3.5 h-3.5" />
                          </Button>
                        )}
                      </TableCell>
                    </TableRow>
                  )
                })
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Score Entry Dialog */}
      <Dialog open={formOpen} onOpenChange={setFormOpen}>
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>{editing ? 'Edit Results' : 'Enter Exam Results'}</DialogTitle>
            <DialogDescription className="text-sm text-gray-500">
              Enter scores per competency (0–20 each, total /100). Save as draft or submit to admin for validation.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <Label>Student <span className="text-red-500">*</span></Label>
                <Select value={form.student_id} onValueChange={(v) => setForm((p) => ({ ...p, student_id: v }))}
                  disabled={!!editing}>
                  <SelectTrigger className="border-gray-200"><SelectValue placeholder="Select student…" /></SelectTrigger>
                  <SelectContent>
                    {students.map((s) => (
                      <SelectItem key={s.id} value={s.id}>{s.last_name} {s.first_name}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-1.5">
                <Label>Exam Session <span className="text-red-500">*</span></Label>
                <Select value={form.session_id} onValueChange={(v) => setForm((p) => ({ ...p, session_id: v }))}
                  disabled={!!editing}>
                  <SelectTrigger className="border-gray-200"><SelectValue placeholder="Select session…" /></SelectTrigger>
                  <SelectContent>
                    {sessions.map((s) => (
                      <SelectItem key={s.id} value={s.id}>{s.title} ({s.cefr_level})</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="border-t border-gray-100 pt-3">
              <p className="text-sm font-medium text-gray-700 mb-3">Scores per Competency (0–20 each)</p>
              <div className="grid grid-cols-5 gap-2">
                {COMPS.map((c) => (
                  <div key={c.key} className="space-y-1">
                    <Label className="text-xs font-semibold text-gray-600 text-center block">{c.label}</Label>
                    <Input
                      type="number" min={0} max={20} step={0.5} placeholder="0"
                      value={(form as any)[c.key]}
                      onChange={(e) => setForm((p) => ({ ...p, [c.key]: e.target.value }))}
                      className="text-center px-1 border-gray-200 focus:border-[#00A550]"
                    />
                  </div>
                ))}
              </div>
              <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-100">
                <span className="text-sm text-gray-600">Total</span>
                <div className="flex items-center gap-2">
                  <span className="text-xl font-bold text-gray-900">{calcTotal(form).toFixed(1)}/100</span>
                  <span className={`text-xs px-2.5 py-0.5 rounded-full font-medium ${calcTotal(form) >= 60 ? 'bg-[#E6F5EE] text-[#00A550]' : 'bg-red-50 text-red-600'}`}>
                    {calcTotal(form) >= 60 ? 'Pass' : 'Fail'}
                  </span>
                </div>
              </div>
              <p className="text-xs text-gray-400 mt-1.5">Pass threshold: 60/100. Certificates are generated after admin validation.</p>
            </div>
          </div>
          <DialogFooter className="gap-2">
            <Button variant="outline" onClick={() => setFormOpen(false)} disabled={saving} className="border-gray-200">Cancel</Button>
            <Button variant="outline"
              onClick={() => handleSave('draft')}
              disabled={saving || !form.student_id || !form.session_id}
              className="border-gray-200 text-gray-700">
              <Save className="w-3.5 h-3.5 mr-1.5" />
              {saving && submitAction === 'draft' ? 'Saving…' : 'Save Draft'}
            </Button>
            <Button onClick={() => handleSave('submit')}
              disabled={saving || !form.student_id || !form.session_id}
              className="bg-[#00A550] hover:bg-[#008040] text-white">
              <Send className="w-3.5 h-3.5 mr-1.5" />
              {saving && submitAction === 'submit' ? 'Submitting…' : 'Submit to Admin'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
