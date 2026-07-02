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
  const openEdit = (s: Student) => {
    setEditing(s)
    setForm({ first_name: s.first_name, last_name: s.last_name, date_of_birth: s.date_of_birth ?? '', cefr_level: s.cefr_level ?? '' })
    setFormOpen(true)
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
        const { error: err } = await supabase.from('school_students').insert(payload)
        if (err) throw err
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
        <DialogContent className="sm:max-w-md">
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
