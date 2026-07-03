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
  Users,
  UserPlus,
  Pencil,
  Trash2,
  GraduationCap,
  AlertTriangle,
  X,
  RefreshCw,
  CalendarDays,
  UserMinus,
  CheckCircle2,
} from 'lucide-react'

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2'

interface Student {
  id: string
  first_name: string
  last_name: string
  date_of_birth: string | null
  cefr_level: CEFR | null
  created_at: string
}

const CEFR_LEVELS: CEFR[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
const CEFR_COLORS: Record<CEFR, string> = {
  A1: 'bg-slate-100 text-slate-600',
  A2: 'bg-blue-50 text-blue-600',
  B1: 'bg-teal-50 text-teal-600',
  B2: 'bg-[#E6F5EE] text-[#00A550]',
  C1: 'bg-orange-50 text-orange-600',
  C2: 'bg-purple-50 text-purple-700',
}

interface FormData {
  first_name: string
  last_name: string
  date_of_birth: string
  cefr_level: CEFR | ''
}

const EMPTY_FORM: FormData = { first_name: '', last_name: '', date_of_birth: '', cefr_level: '' }

interface ExamSession {
  id: string
  title: string
  cefr_level: string
  exam_date: string
}

interface StudentEnrollment {
  id: string
  exam_session_id: string
  active: boolean
  cefr_level: string | null
  session: ExamSession | null
}

export default function SchoolStudentsPage() {
  const supabase = createClient()

  const [schoolId, setSchoolId] = useState<string | null>(null)
  const [students, setStudents] = useState<Student[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const [formOpen, setFormOpen] = useState(false)
  const [deleteOpen, setDeleteOpen] = useState(false)
  const [editing, setEditing] = useState<Student | null>(null)
  const [deleting, setDeleting] = useState<Student | null>(null)
  const [form, setForm] = useState<FormData>(EMPTY_FORM)
  const [saving, setSaving] = useState(false)

  // Enrollment section state
  const [allSessions, setAllSessions] = useState<ExamSession[]>([])
  const [enrollments, setEnrollments] = useState<StudentEnrollment[]>([])
  const [selectedSessionId, setSelectedSessionId] = useState('')
  const [enrolling, setEnrolling] = useState(false)
  const [unenrollingId, setUnenrollingId] = useState<string | null>(null)

  const getSchoolId = useCallback(async () => {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return null
    const { data } = await supabase.from('schools').select('id').eq('profile_id', user.id).maybeSingle()
    return data?.id ?? null
  }, [supabase])

  const fetchStudents = useCallback(async (sid: string) => {
    const { data, error: err } = await supabase
      .from('school_students')
      .select('id, first_name, last_name, date_of_birth, cefr_level, created_at')
      .eq('school_id', sid)
      .order('last_name', { ascending: true })
    if (err) throw err
    setStudents(data ?? [])
  }, [supabase])

  const loadAll = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const sid = schoolId ?? await getSchoolId()
      if (!sid) { setLoading(false); return }
      if (!schoolId) setSchoolId(sid)
      await fetchStudents(sid)
    } catch {
      setError('Failed to load students. Please refresh.')
    } finally {
      setLoading(false)
    }
  }, [schoolId, getSchoolId, fetchStudents])

  useEffect(() => { loadAll() }, [loadAll])

  const openCreate = () => { setEditing(null); setForm(EMPTY_FORM); setFormOpen(true) }
  const openEdit = async (s: Student) => {
    setEditing(s)
    setForm({ first_name: s.first_name, last_name: s.last_name, date_of_birth: s.date_of_birth ?? '', cefr_level: s.cefr_level ?? '' })
    setSelectedSessionId('')
    setEnrollments([])
    setAllSessions([])
    setFormOpen(true)

    // Load exam sessions and student enrollments in parallel
    const [sessRes, enrollRes] = await Promise.all([
      supabase
        .from('exam_sessions')
        .select('id, title, cefr_level, exam_date')
        .in('status', ['upcoming', 'ongoing'])
        .order('exam_date', { ascending: true }),
      supabase
        .from('student_enrollments')
        .select('id, exam_session_id, active, cefr_level')
        .eq('student_id', s.id),
    ])
    const sessions = sessRes.data ?? []
    const rawEnrolls = enrollRes.data ?? []

    setAllSessions(sessions)
    setEnrollments(
      rawEnrolls.map((e: any) => ({
        ...e,
        session: sessions.find((ses) => ses.id === e.exam_session_id) ?? null,
      }))
    )
  }

  const ensureStudentMirror = async (student: Student, sid: string) => {
    const { data: existing } = await supabase
      .from('students')
      .select('id')
      .eq('id', student.id)
      .maybeSingle()
    if (!existing) {
      const { error: mirrorError } = await supabase.from('students').insert({
        id: student.id,
        school_id: sid,
        first_name: student.first_name,
        last_name: student.last_name,
        date_of_birth: student.date_of_birth,
        grade: student.cefr_level ?? 'unspecified',
      })
      if (mirrorError) {
        throw new Error(`Impossible de créer la fiche étudiant : ${mirrorError.message}`)
      }
    }
  }

  const handleEnrollInSession = async () => {
    if (!editing || !selectedSessionId || !schoolId) return
    const alreadyActive = enrollments.some(
      (e) => e.exam_session_id === selectedSessionId && e.active
    )
    if (alreadyActive) return
    setEnrolling(true)
    setError(null)
    try {
      // Ensure the student exists in the `students` table before enrolling
      await ensureStudentMirror(editing, schoolId)

      const existing = enrollments.find((e) => e.exam_session_id === selectedSessionId)
      if (existing) {
        // Re-activate
        const { error: updateError } = await supabase
          .from('student_enrollments')
          .update({ active: true })
          .eq('id', existing.id)
        if (updateError) throw new Error(updateError.message)
      } else {
        const { error: insertError } = await supabase.from('student_enrollments').insert({
          student_id: editing.id,
          exam_session_id: selectedSessionId,
          active: true,
          cefr_level: form.cefr_level || editing.cefr_level || null,
        })
        if (insertError) throw new Error(insertError.message)
      }
      // Refresh enrollments
      const { data } = await supabase
        .from('student_enrollments')
        .select('id, exam_session_id, active, cefr_level')
        .eq('student_id', editing.id)
      setEnrollments(
        (data ?? []).map((e: any) => ({
          ...e,
          session: allSessions.find((s) => s.id === e.exam_session_id) ?? null,
        }))
      )
      setSelectedSessionId('')
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setEnrolling(false)
    }
  }

  const handleUnenroll = async (enrollmentId: string) => {
    setUnenrollingId(enrollmentId)
    try {
      await supabase.from('student_enrollments').update({ active: false }).eq('id', enrollmentId)
      setEnrollments((prev) =>
        prev.map((e) => (e.id === enrollmentId ? { ...e, active: false } : e))
      )
    } finally {
      setUnenrollingId(null)
    }
  }

  const handleSave = async () => {
    if (!schoolId || !form.first_name.trim() || !form.last_name.trim()) return
    setSaving(true)
    setError(null)
    try {
      const payload = {
        school_id: schoolId,
        first_name: form.first_name.trim(),
        last_name: form.last_name.trim(),
        date_of_birth: form.date_of_birth || null,
        cefr_level: form.cefr_level || null,
      }
      if (editing) {
        const { error: err } = await supabase.from('school_students').update(payload).eq('id', editing.id)
        if (err) throw err
      } else {
        const { data: newRow, error: err } = await supabase
          .from('school_students')
          .insert(payload)
          .select('id, first_name, last_name')
          .single()
        if (err) throw err
        // Mirror into `students` so enrollment RLS passes for this student
        if (newRow) {
          await supabase.from('students').insert({
            id: newRow.id,
            school_id: schoolId,
            first_name: newRow.first_name,
            last_name: newRow.last_name,
          })
        }
      }
      setFormOpen(false)
      await fetchStudents(schoolId)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async () => {
    if (!deleting || !schoolId) return
    setSaving(true)
    try {
      const { error: err } = await supabase.from('school_students').delete().eq('id', deleting.id)
      if (err) throw err
      setDeleteOpen(false)
      setDeleting(null)
      await fetchStudents(schoolId)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Students</h1>
          <p className="text-sm text-gray-500 mt-1">Manage students registered at your school.</p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" onClick={loadAll} disabled={loading}>
            <RefreshCw className={`w-4 h-4 mr-1.5 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </Button>
          <Button size="sm" className="bg-[#00A550] hover:bg-[#008040] text-white" onClick={openCreate}>
            <UserPlus className="w-4 h-4 mr-1.5" />
            Add Student
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
              <Users className="w-4 h-4 text-[#00A550]" />
            </div>
            <CardTitle className="text-base font-semibold">
              Enrolled Students
              {!loading && <span className="ml-2 text-sm font-normal text-gray-400">({students.length})</span>}
            </CardTitle>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow className="border-gray-100">
                {['Last Name', 'First Name', 'Date of Birth', 'Level', 'Enrolled', 'Actions'].map((h) => (
                  <TableHead key={h} className="text-xs text-gray-500 font-medium first:pl-6 last:pr-6 last:text-right">{h}</TableHead>
                ))}
              </TableRow>
            </TableHeader>
            <TableBody>
              {loading ? (
                Array.from({ length: 4 }).map((_, i) => (
                  <TableRow key={i}>
                    {Array.from({ length: 6 }).map((_, j) => (
                      <TableCell key={j}><div className="h-4 bg-gray-100 rounded animate-pulse w-4/5" /></TableCell>
                    ))}
                  </TableRow>
                ))
              ) : students.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-16">
                    <div className="flex flex-col items-center gap-3">
                      <div className="w-12 h-12 rounded-xl bg-[#E6F5EE] flex items-center justify-center">
                        <GraduationCap className="w-6 h-6 text-[#00A550]" />
                      </div>
                      <p className="text-sm font-medium text-gray-700">No students yet</p>
                      <p className="text-xs text-gray-400">Click "Add Student" to register your first student.</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : (
                students.map((s) => (
                  <TableRow key={s.id} className="border-gray-50 hover:bg-gray-50/60 transition-colors">
                    <TableCell className="pl-6 py-3 font-semibold text-gray-900">{s.last_name}</TableCell>
                    <TableCell className="py-3 text-gray-700">{s.first_name}</TableCell>
                    <TableCell className="py-3 text-gray-500 text-sm">
                      {s.date_of_birth ? new Date(s.date_of_birth).toLocaleDateString('en-RW', { day: 'numeric', month: 'short', year: 'numeric' }) : '—'}
                    </TableCell>
                    <TableCell className="py-3">
                      {s.cefr_level
                        ? <span className={`text-xs px-2.5 py-0.5 rounded font-bold ${CEFR_COLORS[s.cefr_level]}`}>{s.cefr_level}</span>
                        : <span className="text-gray-300 text-xs">—</span>}
                    </TableCell>
                    <TableCell className="py-3 text-xs text-gray-400">
                      {new Date(s.created_at).toLocaleDateString('en-RW', { day: 'numeric', month: 'short', year: 'numeric' })}
                    </TableCell>
                    <TableCell className="py-3 pr-6 text-right">
                      <div className="flex items-center justify-end gap-1.5">
                        <Button size="sm" variant="outline" onClick={() => openEdit(s)}
                          className="h-7 w-7 p-0 border-gray-200 hover:border-[#00A550] hover:text-[#00A550]">
                          <Pencil className="w-3.5 h-3.5" />
                        </Button>
                        <Button size="sm" variant="outline"
                          onClick={() => { setDeleting(s); setDeleteOpen(true) }}
                          className="h-7 w-7 p-0 border-gray-200 text-red-400 hover:border-red-300 hover:text-red-600 hover:bg-red-50">
                          <Trash2 className="w-3.5 h-3.5" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Add / Edit Dialog */}
      <Dialog open={formOpen} onOpenChange={setFormOpen}>
        <DialogContent className={editing ? 'sm:max-w-lg' : 'sm:max-w-md'}>
          <DialogHeader>
            <DialogTitle>{editing ? 'Edit Student' : 'Add New Student'}</DialogTitle>
            <DialogDescription className="text-sm text-gray-500">
              {editing ? 'Update student details.' : 'Register a new student at your school.'}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <Label>Last Name <span className="text-red-500">*</span></Label>
                <Input placeholder="UWIMANA" value={form.last_name}
                  onChange={(e) => setForm((p) => ({ ...p, last_name: e.target.value }))}
                  className="border-gray-200 focus:border-[#00A550] uppercase" />
              </div>
              <div className="space-y-1.5">
                <Label>First Name <span className="text-red-500">*</span></Label>
                <Input placeholder="Marie" value={form.first_name}
                  onChange={(e) => setForm((p) => ({ ...p, first_name: e.target.value }))}
                  className="border-gray-200 focus:border-[#00A550]" />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <Label>Date of Birth</Label>
                <Input type="date" value={form.date_of_birth}
                  onChange={(e) => setForm((p) => ({ ...p, date_of_birth: e.target.value }))}
                  className="border-gray-200 focus:border-[#00A550]" />
              </div>
              <div className="space-y-1.5">
                <Label>CEFR Level</Label>
                <Select value={form.cefr_level} onValueChange={(v) => setForm((p) => ({ ...p, cefr_level: v as CEFR }))}>
                  <SelectTrigger className="border-gray-200"><SelectValue placeholder="Select…" /></SelectTrigger>
                  <SelectContent>
                    {CEFR_LEVELS.map((l) => <SelectItem key={l} value={l}>{l}</SelectItem>)}
                  </SelectContent>
                </Select>
              </div>
            </div>

            {/* ── Exam Session Enrollment ── only shown when editing */}
            {editing && (
              <div className="border-t border-gray-100 pt-4 space-y-3">
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 rounded bg-[#E6F5EE] flex items-center justify-center flex-shrink-0">
                    <CalendarDays className="w-3.5 h-3.5 text-[#00A550]" />
                  </div>
                  <p className="text-sm font-semibold text-gray-800">Exam Session Enrollment</p>
                </div>

                {/* Enroll row */}
                <div className="flex gap-2 items-end">
                  <div className="flex-1 space-y-1.5">
                    <Label className="text-xs text-gray-600">Available Sessions</Label>
                    <Select value={selectedSessionId} onValueChange={setSelectedSessionId}>
                      <SelectTrigger className="border-gray-200 text-sm">
                        <SelectValue placeholder={allSessions.length ? 'Select a session…' : 'No sessions available'} />
                      </SelectTrigger>
                      <SelectContent>
                        {allSessions.map((s) => {
                          const isActive = enrollments.some(
                            (e) => e.exam_session_id === s.id && e.active
                          )
                          return (
                            <SelectItem key={s.id} value={s.id} disabled={isActive}>
                              <span className="flex items-center gap-2">
                                {s.title} —{' '}
                                {new Date(s.exam_date).toLocaleDateString('en-RW', { day: 'numeric', month: 'short', year: 'numeric' })}
                                {isActive && (
                                  <span className="text-[10px] text-[#00A550] font-medium bg-[#E6F5EE] px-1.5 py-0.5 rounded">enrolled</span>
                                )}
                              </span>
                            </SelectItem>
                          )
                        })}
                      </SelectContent>
                    </Select>
                  </div>
                  <Button
                    size="sm"
                    disabled={
                      !selectedSessionId ||
                      enrolling ||
                      enrollments.some((e) => e.exam_session_id === selectedSessionId && e.active)
                    }
                    onClick={handleEnrollInSession}
                    className="bg-[#00A550] hover:bg-[#008040] text-white h-9 px-3 text-xs flex-shrink-0"
                  >
                    {enrolling ? <RefreshCw className="w-3.5 h-3.5 animate-spin" /> : 'Enroll in this session'}
                  </Button>
                </div>

                {/* Current enrollments list */}
                {enrollments.filter((e) => e.active).length > 0 ? (
                  <div className="space-y-1.5">
                    <p className="text-xs font-medium text-gray-500">Currently enrolled:</p>
                    <div className="space-y-1">
                      {enrollments
                        .filter((e) => e.active)
                        .map((e) => (
                          <div key={e.id}
                            className="flex items-center justify-between px-3 py-2 rounded-lg bg-[#E6F5EE]/60 border border-green-100">
                            <div className="flex items-center gap-2 min-w-0">
                              <CheckCircle2 className="w-3.5 h-3.5 text-[#00A550] flex-shrink-0" />
                              <span className="text-xs text-gray-700 truncate">
                                {e.session
                                  ? `${e.session.title} — ${new Date(e.session.exam_date).toLocaleDateString('en-RW', { day: 'numeric', month: 'short', year: 'numeric' })}`
                                  : e.exam_session_id}
                              </span>
                            </div>
                            <button
                              type="button"
                              disabled={unenrollingId === e.id}
                              onClick={() => handleUnenroll(e.id)}
                              className="flex items-center gap-1 text-xs text-red-500 hover:text-red-700 ml-2 flex-shrink-0 disabled:opacity-50"
                            >
                              {unenrollingId === e.id
                                ? <RefreshCw className="w-3 h-3 animate-spin" />
                                : <UserMinus className="w-3 h-3" />}
                              Unenroll
                            </button>
                          </div>
                        ))}
                    </div>
                  </div>
                ) : (
                  <p className="text-xs text-gray-400 italic">Not enrolled in any session yet.</p>
                )}
              </div>
            )}
          </div>
          <DialogFooter className="gap-2">
            <Button variant="outline" onClick={() => setFormOpen(false)} disabled={saving} className="border-gray-200">Cancel</Button>
            <Button onClick={handleSave} disabled={saving || !form.first_name.trim() || !form.last_name.trim()}
              className="bg-[#00A550] hover:bg-[#008040] text-white min-w-[90px]">
              {saving ? 'Saving…' : editing ? 'Save Changes' : 'Add Student'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Confirm */}
      <Dialog open={deleteOpen} onOpenChange={setDeleteOpen}>
        <DialogContent className="sm:max-w-sm">
          <DialogHeader>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-red-50 flex items-center justify-center">
                <AlertTriangle className="w-5 h-5 text-red-600" />
              </div>
              <DialogTitle>Delete Student</DialogTitle>
            </div>
            <DialogDescription className="mt-2 text-sm text-gray-500">
              Remove <span className="font-semibold text-gray-700">{deleting?.last_name} {deleting?.first_name}</span>? This cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter className="gap-2">
            <Button variant="outline" onClick={() => setDeleteOpen(false)} disabled={saving} className="border-gray-200">Cancel</Button>
            <Button onClick={handleDelete} disabled={saving} className="bg-red-600 hover:bg-red-700 text-white">
              {saving ? 'Deleting…' : 'Delete'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
