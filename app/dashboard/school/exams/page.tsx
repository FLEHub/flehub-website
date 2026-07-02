'use client'

import { useState, useEffect, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  FileText,
  Music,
  Download,
  ChevronDown,
  ChevronUp,
  RefreshCw,
  AlertTriangle,
  CheckCircle2,
  XCircle,
  BookOpen,
} from 'lucide-react'

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2'
type Competency = 'EO' | 'EE' | 'CO' | 'CE' | 'LANGUE'

interface ExamSession {
  id: string
  title: string
  cefr_level: CEFR
  exam_date: string
  status: string
}

interface ExamPaper {
  id: string
  exam_session_id: string
  competency: Competency
  file_path: string | null
  audio_path: string | null
}

const COMPETENCIES: { key: Competency; label: string; hasAudio: boolean }[] = [
  { key: 'EO', label: 'Expression Orale', hasAudio: false },
  { key: 'EE', label: 'Expression Écrite', hasAudio: false },
  { key: 'CO', label: 'Compréhension Orale', hasAudio: true },
  { key: 'CE', label: 'Compréhension Écrite', hasAudio: true },
  { key: 'LANGUE', label: 'Étude de la Langue', hasAudio: false },
]

const CEFR_COLORS: Record<CEFR, string> = {
  A1: 'bg-slate-100 text-slate-600',
  A2: 'bg-blue-50 text-blue-600',
  B1: 'bg-teal-50 text-teal-600',
  B2: 'bg-[#E6F5EE] text-[#00A550]',
  C1: 'bg-orange-50 text-orange-600',
  C2: 'bg-purple-50 text-purple-700',
}

const STATUS_COLORS: Record<string, string> = {
  upcoming: 'bg-blue-50 text-blue-700 border border-blue-200',
  ongoing: 'bg-[#E6F5EE] text-[#00A550] border border-green-200',
  completed: 'bg-gray-100 text-gray-600 border border-gray-200',
  cancelled: 'bg-red-50 text-red-600 border border-red-200',
}

export default function SchoolExamsPage() {
  const supabase = createClient()

  const [sessions, setSessions] = useState<ExamSession[]>([])
  const [papers, setPapers] = useState<Record<string, ExamPaper[]>>({})
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [expanded, setExpanded] = useState<string | null>(null)
  const [loadingUrl, setLoadingUrl] = useState<string | null>(null)

  const fetchData = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const { data: sess, error: sessErr } = await supabase
        .from('exam_sessions')
        .select('id, title, cefr_level, exam_date, status')
        .in('status', ['upcoming', 'ongoing'])
        .order('exam_date', { ascending: true })
      if (sessErr) throw sessErr
      setSessions(sess ?? [])

      if ((sess ?? []).length > 0) {
        const ids = (sess ?? []).map((s) => s.id)
        const { data: papersData, error: papersErr } = await supabase
          .from('exam_papers')
          .select('id, exam_session_id, competency, file_path, audio_path')
          .in('exam_session_id', ids)
        if (papersErr) throw papersErr
        const grouped: Record<string, ExamPaper[]> = {}
        for (const p of papersData ?? []) {
          if (!grouped[p.exam_session_id]) grouped[p.exam_session_id] = []
          grouped[p.exam_session_id].push(p as ExamPaper)
        }
        setPapers(grouped)
      }
    } catch {
      setError('Failed to load exam papers. Please refresh.')
    } finally {
      setLoading(false)
    }
  }, [supabase])

  useEffect(() => { fetchData() }, [fetchData])

  const getPaper = (sessionId: string, competency: Competency) =>
    papers[sessionId]?.find((p) => p.competency === competency)

  const getSignedUrl = async (bucket: string, path: string) => {
    const { data } = await supabase.storage.from(bucket).createSignedUrl(path, 3600)
    return data?.signedUrl ?? null
  }

  const handleDownload = async (bucket: string, path: string, filename: string) => {
    setLoadingUrl(path)
    try {
      const url = await getSignedUrl(bucket, path)
      if (url) {
        const a = document.createElement('a')
        a.href = url
        a.download = filename
        a.target = '_blank'
        a.click()
      }
    } finally {
      setLoadingUrl(null)
    }
  }

  const [audioUrls, setAudioUrls] = useState<Record<string, string>>({})

  const loadAudio = async (path: string) => {
    if (audioUrls[path]) return
    const url = await getSignedUrl('exam-audio', path)
    if (url) setAudioUrls((prev) => ({ ...prev, [path]: url }))
  }

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Exam Papers</h1>
          <p className="text-sm text-gray-500 mt-1">Download exam papers and audio files sent by the admin.</p>
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

      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="h-16 bg-gray-100 rounded-xl animate-pulse" />
          ))}
        </div>
      ) : sessions.length === 0 ? (
        <Card className="border-0 shadow-sm">
          <CardContent className="flex flex-col items-center py-16">
            <div className="w-12 h-12 rounded-xl bg-[#E6F5EE] flex items-center justify-center mb-3">
              <BookOpen className="w-6 h-6 text-[#00A550]" />
            </div>
            <p className="text-sm font-medium text-gray-700">No exam sessions available</p>
            <p className="text-xs text-gray-400 mt-1">Exam papers will appear here once published by the admin.</p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-3">
          {sessions.map((session) => {
            const isOpen = expanded === session.id
            const sessionPapers = papers[session.id] ?? []
            const pdfCount = sessionPapers.filter((p) => p.file_path).length
            const audioCount = sessionPapers.filter((p) => p.audio_path).length
            const audioExpected = COMPETENCIES.filter((c) => c.hasAudio).length

            return (
              <Card key={session.id} className="border-0 shadow-sm overflow-hidden">
                <button
                  type="button"
                  onClick={() => setExpanded(isOpen ? null : session.id)}
                  className="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-gray-50/70 transition-colors"
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <span className={`text-xs px-2.5 py-1 rounded font-bold flex-shrink-0 ${CEFR_COLORS[session.cefr_level] ?? 'bg-gray-100 text-gray-600'}`}>
                      {session.cefr_level}
                    </span>
                    <div className="min-w-0">
                      <p className="text-sm font-semibold text-gray-900 truncate">{session.title}</p>
                      <p className="text-xs text-gray-400 mt-0.5">
                        {new Date(session.exam_date).toLocaleDateString('en-RW', { weekday: 'short', day: 'numeric', month: 'long', year: 'numeric' })}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3 flex-shrink-0 ml-4">
                    <span className={`text-xs px-2.5 py-0.5 rounded-full font-medium capitalize ${STATUS_COLORS[session.status] ?? ''}`}>
                      {session.status}
                    </span>
                    <div className="hidden sm:flex items-center gap-2 text-xs">
                      <span className={`flex items-center gap-1 px-2 py-0.5 rounded-full font-medium ${pdfCount === COMPETENCIES.length ? 'bg-[#E6F5EE] text-[#00A550]' : 'bg-gray-100 text-gray-500'}`}>
                        <FileText className="w-3 h-3" />
                        {pdfCount}/{COMPETENCIES.length} PDFs
                      </span>
                      <span className={`flex items-center gap-1 px-2 py-0.5 rounded-full font-medium ${audioCount === audioExpected ? 'bg-[#E6F5EE] text-[#00A550]' : 'bg-gray-100 text-gray-500'}`}>
                        <Music className="w-3 h-3" />
                        {audioCount}/{audioExpected} Audio
                      </span>
                    </div>
                    {isOpen ? <ChevronUp className="w-4 h-4 text-gray-400" /> : <ChevronDown className="w-4 h-4 text-gray-400" />}
                  </div>
                </button>

                {isOpen && (
                  <div className="border-t border-gray-100">
                    <Table>
                      <TableHeader>
                        <TableRow className="border-gray-100">
                          <TableHead className="text-xs text-gray-500 font-medium pl-6">Competency</TableHead>
                          <TableHead className="text-xs text-gray-500 font-medium">PDF Paper</TableHead>
                          <TableHead className="text-xs text-gray-500 font-medium pr-6">Audio</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {COMPETENCIES.map((comp) => {
                          const paper = getPaper(session.id, comp.key)
                          const hasPdf = Boolean(paper?.file_path)
                          const hasAudio = Boolean(paper?.audio_path)
                          const audioPath = paper?.audio_path ?? ''

                          return (
                            <TableRow key={comp.key} className="border-gray-50 hover:bg-gray-50/50">
                              <TableCell className="pl-6 py-3">
                                <div className="flex items-center gap-2">
                                  <span className="text-xs font-bold bg-gray-100 text-gray-600 px-2 py-0.5 rounded">{comp.key}</span>
                                  <span className="text-sm text-gray-700">{comp.label}</span>
                                </div>
                              </TableCell>
                              <TableCell className="py-3">
                                {hasPdf ? (
                                  <Button size="sm" variant="outline"
                                    disabled={loadingUrl === paper?.file_path}
                                    onClick={() => handleDownload('exam-papers', paper!.file_path!, `${comp.key}.pdf`)}
                                    className="h-7 text-xs border-[#00A550] text-[#00A550] hover:bg-[#E6F5EE]">
                                    {loadingUrl === paper?.file_path
                                      ? <RefreshCw className="w-3 h-3 animate-spin mr-1" />
                                      : <Download className="w-3 h-3 mr-1" />}
                                    Download PDF
                                  </Button>
                                ) : (
                                  <span className="flex items-center gap-1.5 text-xs text-gray-400">
                                    <XCircle className="w-3.5 h-3.5" /> Not uploaded
                                  </span>
                                )}
                              </TableCell>
                              <TableCell className="py-3 pr-6">
                                {comp.hasAudio ? (
                                  hasAudio ? (
                                    <div className="space-y-1.5">
                                      {audioUrls[audioPath] ? (
                                        <audio controls src={audioUrls[audioPath]} className="h-8 w-full max-w-xs" />
                                      ) : (
                                        <Button size="sm" variant="outline"
                                          onClick={() => loadAudio(audioPath)}
                                          className="h-7 text-xs border-[#00A550] text-[#00A550] hover:bg-[#E6F5EE]">
                                          <Music className="w-3 h-3 mr-1" />
                                          Load Audio
                                        </Button>
                                      )}
                                    </div>
                                  ) : (
                                    <span className="flex items-center gap-1.5 text-xs text-gray-400">
                                      <XCircle className="w-3.5 h-3.5" /> Not uploaded
                                    </span>
                                  )
                                ) : (
                                  <span className="text-xs text-gray-300">N/A</span>
                                )}
                              </TableCell>
                            </TableRow>
                          )
                        })}
                      </TableBody>
                    </Table>
                  </div>
                )}
              </Card>
            )
          })}
        </div>
      )}
    </div>
  )
}
