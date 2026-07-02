'use client'

import { useState, useEffect, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
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
  Award,
  Download,
  RefreshCw,
  AlertTriangle,
  ShieldCheck,
  CheckCircle2,
  FilePlus2,
} from 'lucide-react'

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2'

interface Certificate {
  id: string
  certificate_number: string
  school_student_id: string
  cefr_level: CEFR
  issue_date: string
  pdf_path: string | null
}

interface StudentRow {
  id: string
  first_name: string
  last_name: string
  cefr_level: CEFR | null
}

interface ValidatedResult {
  id: string
  school_student_id: string
  exam_session_id: string
  total_score: number
  status: string
}

interface ExamSession {
  id: string
  title: string
  cefr_level: CEFR
}

const CEFR_COLORS: Record<CEFR, string> = {
  A1: 'bg-slate-100 text-slate-600', A2: 'bg-blue-50 text-blue-600',
  B1: 'bg-teal-50 text-teal-600', B2: 'bg-[#E6F5EE] text-[#00A550]',
  C1: 'bg-orange-50 text-orange-600', C2: 'bg-purple-50 text-purple-700',
}

const CEFR_LABELS: Record<CEFR, string> = {
  A1: 'Beginner', A2: 'Elementary', B1: 'Intermediate',
  B2: 'Upper-Intermediate', C1: 'Advanced', C2: 'Mastery',
}

export default function SchoolCertificatesPage() {
  const supabase = createClient()

  const [schoolId, setSchoolId] = useState<string | null>(null)
  const [certificates, setCertificates] = useState<Certificate[]>([])
  const [validatedResults, setValidatedResults] = useState<ValidatedResult[]>([])
  const [students, setStudents] = useState<StudentRow[]>([])
  const [sessions, setSessions] = useState<ExamSession[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [generating, setGenerating] = useState<string | null>(null)

  const getSchoolId = useCallback(async () => {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return null
    const { data } = await supabase.from('schools').select('id').eq('profile_id', user.id).maybeSingle()
    return data?.id ?? null
  }, [supabase])

  const fetchAll = useCallback(async (sid: string) => {
    const [studs, sess, certs, validated] = await Promise.all([
      supabase.from('school_students').select('id, first_name, last_name, cefr_level').eq('school_id', sid),
      supabase.from('exam_sessions').select('id, title, cefr_level'),
      supabase.from('school_certificates').select('id, certificate_number, school_student_id, cefr_level, issue_date, pdf_path').eq('school_id', sid).order('issue_date', { ascending: false }),
      supabase.from('exam_result_drafts')
        .select('id, school_student_id, exam_session_id, total_score, status')
        .eq('school_id', sid)
        .eq('status', 'validated'),
    ])
    if (studs.error) throw studs.error
    if (certs.error) throw certs.error
    setStudents(studs.data ?? [])
    setSessions(sess.data ?? [])
    setCertificates(certs.data ?? [])
    setValidatedResults(validated.data ?? [])
  }, [supabase])

  const loadAll = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const sid = schoolId ?? await getSchoolId()
      if (!sid) { setLoading(false); return }
      if (!schoolId) setSchoolId(sid)
      await fetchAll(sid)
    } catch { setError('Failed to load certificates. Please refresh.') }
    finally { setLoading(false) }
  }, [schoolId, getSchoolId, fetchAll])

  useEffect(() => { loadAll() }, [loadAll])

  const getStudentName = (id: string) => {
    const s = students.find((st) => st.id === id)
    return s ? `${s.last_name} ${s.first_name}` : '—'
  }
  const getSession = (id: string) => sessions.find((s) => s.id === id)

  // Results that passed (>=60) and validated but don't have a certificate yet
  const pendingGeneration = validatedResults.filter((r) => {
    if (r.total_score < 60) return false
    return !certificates.some((c) => c.school_student_id === r.school_student_id)
  })

  const handleGenerate = async (result: ValidatedResult) => {
    if (!schoolId) return
    setGenerating(result.id)
    setError(null)
    try {
      const session = getSession(result.exam_session_id)
      const certNumber = `CERT-${Date.now().toString(36).toUpperCase()}-${Math.random().toString(36).substring(2, 5).toUpperCase()}`
      const { error: err } = await supabase.from('school_certificates').insert({
        school_id: schoolId,
        school_student_id: result.school_student_id,
        exam_result_draft_id: result.id,
        certificate_number: certNumber,
        cefr_level: session?.cefr_level ?? 'A1',
        issue_date: new Date().toISOString().split('T')[0],
      })
      if (err) throw err
      await fetchAll(schoolId)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setGenerating(null)
    }
  }

  const handleDownload = async (path: string, certNumber: string) => {
    const { data } = await supabase.storage.from('school-assets').createSignedUrl(path, 3600)
    if (data?.signedUrl) {
      const a = document.createElement('a')
      a.href = data.signedUrl
      a.download = `${certNumber}.pdf`
      a.click()
    }
  }

  const levelCounts = certificates.reduce<Partial<Record<CEFR, number>>>((acc, c) => {
    acc[c.cefr_level] = (acc[c.cefr_level] ?? 0) + 1
    return acc
  }, {})

  return (
    <div className="p-6 space-y-6 max-w-6xl mx-auto">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Certificates</h1>
          <p className="text-sm text-gray-500 mt-1">Generate and download certificates for validated passing students.</p>
        </div>
        <Button variant="outline" size="sm" onClick={loadAll} disabled={loading}>
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

      {/* Pending generation */}
      {!loading && pendingGeneration.length > 0 && (
        <Card className="border-0 shadow-sm border-l-4 border-l-[#00A550]">
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-[#E6F5EE] flex items-center justify-center">
                <FilePlus2 className="w-4 h-4 text-[#00A550]" />
              </div>
              <CardTitle className="text-sm font-semibold text-[#00A550]">
                Ready to Generate ({pendingGeneration.length})
              </CardTitle>
            </div>
          </CardHeader>
          <CardContent className="pt-0">
            <p className="text-xs text-gray-500 mb-3">These students passed and their results were validated by the admin. Generate their certificates now.</p>
            <div className="space-y-2">
              {pendingGeneration.map((r) => {
                const session = getSession(r.exam_session_id)
                return (
                  <div key={r.id} className="flex items-center justify-between p-3 rounded-lg bg-[#E6F5EE]/60 border border-green-100">
                    <div>
                      <p className="text-sm font-semibold text-gray-900">{getStudentName(r.school_student_id)}</p>
                      <p className="text-xs text-gray-500">{session?.title} — {session?.cefr_level} — Score: {r.total_score}/100</p>
                    </div>
                    <Button size="sm" className="bg-[#00A550] hover:bg-[#008040] text-white"
                      onClick={() => handleGenerate(r)} disabled={generating === r.id}>
                      {generating === r.id ? <RefreshCw className="w-3.5 h-3.5 animate-spin mr-1" /> : <Award className="w-3.5 h-3.5 mr-1" />}
                      Generate
                    </Button>
                  </div>
                )
              })}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Level breakdown */}
      {!loading && certificates.length > 0 && (
        <div className="flex flex-wrap items-center gap-2">
          <span className="text-xs text-gray-500 mr-1">By Level:</span>
          {(Object.entries(levelCounts) as [CEFR, number][]).map(([level, count]) => (
            <span key={level} className={`text-xs px-2.5 py-1 rounded-full font-semibold ${CEFR_COLORS[level]}`}>
              {level}: {count}
            </span>
          ))}
        </div>
      )}

      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-amber-50 flex items-center justify-center">
              <Award className="w-4 h-4 text-amber-600" />
            </div>
            <CardTitle className="text-base font-semibold">
              Issued Certificates
              {!loading && <span className="ml-2 text-sm font-normal text-gray-400">({certificates.length})</span>}
            </CardTitle>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow className="border-gray-100">
                {['Student', 'Certificate Number', 'Level', 'Issue Date', 'Verification', 'Actions'].map((h) => (
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
              ) : certificates.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-16">
                    <div className="flex flex-col items-center gap-3">
                      <div className="w-12 h-12 rounded-xl bg-amber-50 flex items-center justify-center">
                        <Award className="w-6 h-6 text-amber-500" />
                      </div>
                      <p className="text-sm font-medium text-gray-700">No certificates yet</p>
                      <p className="text-xs text-gray-400">Certificates appear here after admin validates a passing result.</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : (
                certificates.map((cert) => (
                  <TableRow key={cert.id} className="border-gray-50 hover:bg-gray-50/60 transition-colors">
                    <TableCell className="pl-6 py-3 font-semibold text-gray-900">
                      {getStudentName(cert.school_student_id)}
                    </TableCell>
                    <TableCell className="py-3">
                      <span className="font-mono text-xs text-gray-700 bg-gray-100 px-2 py-0.5 rounded">
                        {cert.certificate_number}
                      </span>
                    </TableCell>
                    <TableCell className="py-3">
                      <div>
                        <span className={`text-xs px-2.5 py-0.5 rounded font-bold ${CEFR_COLORS[cert.cefr_level] ?? 'bg-gray-100 text-gray-600'}`}>
                          {cert.cefr_level}
                        </span>
                        <p className="text-xs text-gray-400 mt-0.5">{CEFR_LABELS[cert.cefr_level]}</p>
                      </div>
                    </TableCell>
                    <TableCell className="py-3 text-sm text-gray-600">
                      {new Date(cert.issue_date).toLocaleDateString('en-RW', { day: 'numeric', month: 'long', year: 'numeric' })}
                    </TableCell>
                    <TableCell className="py-3">
                      <div className="flex items-center gap-1.5">
                        <ShieldCheck className="w-3.5 h-3.5 text-[#00A550] flex-shrink-0" />
                        <span className="font-mono text-xs text-gray-600">{cert.certificate_number.slice(-8)}</span>
                      </div>
                    </TableCell>
                    <TableCell className="py-3 pr-6 text-right">
                      {cert.pdf_path ? (
                        <Button variant="ghost" size="sm"
                          className="h-7 text-xs text-amber-600 hover:bg-amber-50"
                          onClick={() => handleDownload(cert.pdf_path!, cert.certificate_number)}>
                          <Download className="w-3.5 h-3.5 mr-1" />
                          Download
                        </Button>
                      ) : (
                        <span className="flex items-center justify-end gap-1 text-xs text-[#00A550]">
                          <CheckCircle2 className="w-3.5 h-3.5" /> Issued
                        </span>
                      )}
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  )
}
