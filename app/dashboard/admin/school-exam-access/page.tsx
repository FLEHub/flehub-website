'use client'

import { useState, useEffect, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Label } from '@/components/ui/label'
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
import { AlertTriangle, CheckCircle2, RefreshCw, School } from 'lucide-react'

interface SchoolOption {
  id: string
  school_name: string
}

interface SessionOption {
  id: string
  title: string
  cefr_level: string
  exam_date: string
}

interface AccessRow {
  id: string
  school_id: string
  exam_session_id: string
  status: string
  paid_at: string | null
  schools: { school_name: string } | null
  exam_sessions: { title: string; cefr_level: string; exam_date: string } | null
}

const STATUS_COLORS: Record<string, string> = {
  pending: 'bg-amber-50 text-amber-700',
  completed: 'bg-[#E6F5EE] text-[#00A550]',
  failed: 'bg-red-50 text-red-600',
  refunded: 'bg-blue-50 text-blue-600',
}

export default function AdminSchoolExamAccessPage() {
  const supabase = createClient()

  const [schools, setSchools] = useState<SchoolOption[]>([])
  const [sessions, setSessions] = useState<SessionOption[]>([])
  const [accessRows, setAccessRows] = useState<AccessRow[]>([])
  const [selectedSchoolId, setSelectedSchoolId] = useState('')
  const [selectedSessionId, setSelectedSessionId] = useState('')
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)

  const fetchData = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const [schoolsRes, sessionsRes, accessRes] = await Promise.all([
        supabase.from('schools').select('id, school_name').order('school_name'),
        supabase
          .from('exam_sessions')
          .select('id, title, cefr_level, exam_date')
          .order('exam_date', { ascending: false }),
        supabase
          .from('school_exam_access')
          .select(
            'id, school_id, exam_session_id, status, paid_at, schools(school_name), exam_sessions(title, cefr_level, exam_date)'
          )
          .order('paid_at', { ascending: false, nullsFirst: false }),
      ])

      if (schoolsRes.error) throw schoolsRes.error
      if (sessionsRes.error) throw sessionsRes.error
      if (accessRes.error) throw accessRes.error

      setSchools(schoolsRes.data ?? [])
      setSessions(sessionsRes.data ?? [])
      setAccessRows((accessRes.data as AccessRow[]) ?? [])
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setLoading(false)
    }
  }, [supabase])

  useEffect(() => {
    fetchData()
  }, [fetchData])

  const handleMarkCompleted = async () => {
    if (!selectedSchoolId || !selectedSessionId) return
    setSaving(true)
    setError(null)
    setSuccess(null)
    try {
      const paidAt = new Date().toISOString()
      const { error: upsertError } = await supabase.from('school_exam_access').upsert(
        {
          school_id: selectedSchoolId,
          exam_session_id: selectedSessionId,
          status: 'completed',
          paid_at: paidAt,
        },
        { onConflict: 'school_id,exam_session_id' }
      )
      if (upsertError) throw upsertError

      setSuccess('Access granted — school can now see this exam session.')
      setSelectedSchoolId('')
      setSelectedSessionId('')
      await fetchData()
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
          <h1 className="text-2xl font-bold text-gray-900">School Exam Access</h1>
          <p className="text-sm text-gray-500 mt-1">
            Manually mark a school as paid for an exam session (Phase 1 — no MoMo/Flutterwave yet).
          </p>
        </div>
        <Button variant="outline" size="sm" onClick={fetchData} disabled={loading}>
          <RefreshCw className={`w-4 h-4 mr-1.5 ${loading ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {error}
        </div>
      )}

      {success && (
        <div className="flex items-center gap-2 rounded-lg bg-[#E6F5EE] border border-green-200 px-4 py-3 text-sm text-[#00A550]">
          <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
          {success}
        </div>
      )}

      <Card className="border-0 shadow-sm">
        <CardHeader>
          <CardTitle className="text-base font-semibold flex items-center gap-2">
            <School className="w-4 h-4" />
            Grant exam access
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <Label>School</Label>
              <Select value={selectedSchoolId} onValueChange={setSelectedSchoolId}>
                <SelectTrigger>
                  <SelectValue placeholder="Select a school" />
                </SelectTrigger>
                <SelectContent>
                  {schools.map((s) => (
                    <SelectItem key={s.id} value={s.id}>
                      {s.school_name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-1.5">
              <Label>Exam session</Label>
              <Select value={selectedSessionId} onValueChange={setSelectedSessionId}>
                <SelectTrigger>
                  <SelectValue placeholder="Select an exam session" />
                </SelectTrigger>
                <SelectContent>
                  {sessions.map((s) => (
                    <SelectItem key={s.id} value={s.id}>
                      {s.title} — {s.cefr_level} (
                      {new Date(s.exam_date).toLocaleDateString('en-RW')})
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
          <Button
            onClick={handleMarkCompleted}
            disabled={saving || !selectedSchoolId || !selectedSessionId}
            className="bg-[#00A550] hover:bg-[#00A550]/90 text-white"
          >
            {saving ? 'Saving…' : 'Mark as completed (paid today)'}
          </Button>
        </CardContent>
      </Card>

      <Card className="border-0 shadow-sm">
        <CardHeader>
          <CardTitle className="text-base font-semibold">Existing access records</CardTitle>
        </CardHeader>
        <CardContent>
          {loading ? (
            <p className="text-sm text-gray-400">Loading…</p>
          ) : accessRows.length === 0 ? (
            <p className="text-sm text-gray-400">No access records yet.</p>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>School</TableHead>
                  <TableHead>Session</TableHead>
                  <TableHead>Level</TableHead>
                  <TableHead>Exam date</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Paid at</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {accessRows.map((row) => (
                  <TableRow key={row.id}>
                    <TableCell className="font-medium">
                      {row.schools?.school_name ?? row.school_id}
                    </TableCell>
                    <TableCell>{row.exam_sessions?.title ?? row.exam_session_id}</TableCell>
                    <TableCell>{row.exam_sessions?.cefr_level ?? '—'}</TableCell>
                    <TableCell>
                      {row.exam_sessions?.exam_date
                        ? new Date(row.exam_sessions.exam_date).toLocaleDateString('en-RW')
                        : '—'}
                    </TableCell>
                    <TableCell>
                      <Badge
                        variant="secondary"
                        className={`text-xs capitalize ${STATUS_COLORS[row.status] ?? ''}`}
                      >
                        {row.status}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-xs text-gray-500">
                      {row.paid_at
                        ? new Date(row.paid_at).toLocaleDateString('en-RW')
                        : '—'}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
