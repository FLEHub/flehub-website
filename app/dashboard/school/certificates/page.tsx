'use client'

import { useState, useEffect, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import { jsPDF } from 'jspdf'
import {
  DEFAULT_ORG_SHORT_NAME,
  DEFAULT_ORG_TAGLINE,
  adminOrgLabel,
  MFK_LOGO_SRC,
} from '@/lib/org-branding'
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
  score_eo: number | null
  score_ee: number | null
  score_co: number | null
  score_ce: number | null
  score_langue: number | null
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
  B1: 'bg-teal-50 text-teal-600', B2: 'bg-[#E8F1FA] text-[#1E5FA8]',
  C1: 'bg-orange-50 text-orange-600', C2: 'bg-purple-50 text-purple-700',
}

const CEFR_LABELS: Record<CEFR, string> = {
  A1: 'Débutant', A2: 'Élémentaire', B1: 'Intermédiaire',
  B2: 'Intermédiaire supérieur', C1: 'Avancé', C2: 'Maîtrise',
}

function formatScore(value: number | null | undefined): string {
  if (value == null || Number.isNaN(Number(value))) return '—'
  return Number(value).toFixed(Number.isInteger(Number(value)) ? 0 : 1)
}

function imageFormatFromDataUrl(dataUrl: string): 'PNG' | 'JPEG' {
  if (dataUrl.startsWith('data:image/jpeg') || dataUrl.startsWith('data:image/jpg')) return 'JPEG'
  return 'PNG'
}

async function loadImageAsDataUrl(src: string): Promise<string | null> {
  try {
    const response = await fetch(src)
    if (!response.ok) return null
    const blob = await response.blob()
    return await new Promise((resolve) => {
      const reader = new FileReader()
      reader.onloadend = () => resolve(typeof reader.result === 'string' ? reader.result : null)
      reader.onerror = () => resolve(null)
      reader.readAsDataURL(blob)
    })
  } catch {
    return null
  }
}

async function generateCertificatePdf(params: {
  studentName: string
  cefrLevel: CEFR
  schoolName: string
  certificateNumber: string
  issueDate: string
  verificationCode: string
  scores: {
    score_eo: number | null
    score_ee: number | null
    score_co: number | null
    score_ce: number | null
    score_langue: number | null
    total_score: number
  }
  examinerName: string | null
  examinerGender: 'M' | 'F' | null
  schoolLogoDataUrl: string | null
  examinerSignatureDataUrl: string | null
  schoolStampDataUrl: string | null
  orgName: string
  orgShortName: string
  orgTagline: string
  adminSignatoryName: string | null
  adminGender: 'M' | 'F' | null
  adminLogoDataUrl: string | null
  adminSignatureDataUrl: string | null
  adminStampDataUrl: string | null
}): Promise<Blob> {
  const doc = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' })
  const pageW = doc.internal.pageSize.getWidth()
  const pageH = doc.internal.pageSize.getHeight()

  doc.setDrawColor(11, 31, 58)
  doc.setLineWidth(1.5)
  doc.rect(10, 10, pageW - 20, pageH - 20)
  doc.setLineWidth(0.5)
  doc.rect(14, 14, pageW - 28, pageH - 28)

  // Header logos: school (partner) top-left, official MFK emblem top-right (square, circular asset)
  const schoolLogoW = 24
  const schoolLogoH = 16
  const mfkLogoSize = 16
  const topLogoY = 20
  const leftLogoX = 20
  const rightLogoX = pageW - 20 - mfkLogoSize

  if (params.schoolLogoDataUrl) {
    try {
      doc.addImage(
        params.schoolLogoDataUrl,
        imageFormatFromDataUrl(params.schoolLogoDataUrl),
        leftLogoX,
        topLogoY,
        schoolLogoW,
        schoolLogoH,
      )
    } catch {
      // Image load/format failure: continue without school logo.
    }
  }

  if (params.adminLogoDataUrl) {
    try {
      doc.addImage(
        params.adminLogoDataUrl,
        imageFormatFromDataUrl(params.adminLogoDataUrl),
        rightLogoX,
        topLogoY,
        mfkLogoSize,
        mfkLogoSize,
      )
    } catch {
      // Continue without admin logo.
    }
  }

  const shortName = params.orgShortName.trim() || DEFAULT_ORG_SHORT_NAME
  const tagline = params.orgTagline.trim() || DEFAULT_ORG_TAGLINE
  const brandName = params.orgName.trim() || shortName
  const adminLabel = adminOrgLabel(shortName)
  doc.setFont('helvetica', 'bold')
  doc.setFontSize(26)
  doc.setTextColor(11, 31, 58)
  doc.text(brandName, pageW / 2, 32, { align: 'center' })

  doc.setFontSize(11)
  doc.setTextColor(100, 100, 100)
  doc.setFont('helvetica', 'normal')
  doc.text('Plateforme d\'examen de français langue étrangère', pageW / 2, 40, { align: 'center' })

  doc.setFontSize(22)
  doc.setTextColor(30, 30, 30)
  doc.setFont('helvetica', 'bold')
  doc.text('Certificat de Réussite', pageW / 2, 54, { align: 'center' })

  const bodyStartY = 70

  doc.setFont('helvetica', 'normal')
  doc.setFontSize(13)
  doc.setTextColor(80, 80, 80)
  doc.text('Nous certifions que', pageW / 2, bodyStartY, { align: 'center' })

  doc.setFontSize(24)
  doc.setTextColor(20, 20, 20)
  doc.setFont('helvetica', 'bold')
  doc.text(params.studentName, pageW / 2, bodyStartY + 13, { align: 'center' })

  doc.setFont('helvetica', 'normal')
  doc.setFontSize(13)
  doc.setTextColor(80, 80, 80)
  doc.text('a obtenu avec succès le niveau CECRL', pageW / 2, bodyStartY + 26, { align: 'center' })

  doc.setFontSize(18)
  doc.setTextColor(30, 95, 168)
  doc.setFont('helvetica', 'bold')
  doc.text(`${params.cefrLevel} — ${CEFR_LABELS[params.cefrLevel]}`, pageW / 2, bodyStartY + 38, { align: 'center' })

  doc.setFont('helvetica', 'normal')
  doc.setFontSize(12)
  doc.setTextColor(80, 80, 80)
  doc.text(`Délivré par : ${params.schoolName}`, pageW / 2, bodyStartY + 50, { align: 'center' })

  const scoreLine = [
    `EO : ${formatScore(params.scores.score_eo)}/20`,
    `EE : ${formatScore(params.scores.score_ee)}/20`,
    `CO : ${formatScore(params.scores.score_co)}/20`,
    `CE : ${formatScore(params.scores.score_ce)}/20`,
    `LANGUE : ${formatScore(params.scores.score_langue)}/20`,
    `Total : ${formatScore(params.scores.total_score)}/100`,
  ].join('   ')

  doc.setFontSize(10)
  doc.setTextColor(60, 60, 60)
  doc.setFont('helvetica', 'bold')
  doc.text(scoreLine, pageW / 2, bodyStartY + 62, { align: 'center' })

  const formattedDate = new Date(params.issueDate).toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  })

  doc.setFont('helvetica', 'normal')
  doc.setFontSize(9)
  doc.setTextColor(100, 100, 100)
  doc.text(`N° de certificat : ${params.certificateNumber}`, pageW / 2, bodyStartY + 74, { align: 'center' })
  doc.text(`Date de délivrance : ${formattedDate}`, pageW / 2, bodyStartY + 80, { align: 'center' })
  doc.text(`Code de vérification : ${params.verificationCode}`, pageW / 2, bodyStartY + 86, { align: 'center' })

  // Dual signature zones at the bottom (A4 landscape ≈ 297×210 mm)
  // Vertical order (top → bottom): signature → stamp (overlap ~10mm) → line → name/title
  // Signature has smaller y; stamp has larger y; signature drawn last so it sits on top.
  const leftX = pageW * 0.28 // ≈ 83.2
  const rightX = pageW * 0.72 // ≈ 213.8
  const lineY = pageH - 38 // ≈ 172
  const lineHalfW = 40
  const sigW = 36
  const sigH = 16
  const stampSize = 22
  const stampOverlap = 10
  // Stamp just above the line; signature higher, overlapping stamp top by ~10 mm
  const stampY = lineY - stampSize - 2 // ≈ 148
  const sigY = stampY - sigH + stampOverlap // ≈ 142

  // Stamps first (underneath)
  if (params.schoolStampDataUrl) {
    try {
      doc.addImage(
        params.schoolStampDataUrl,
        imageFormatFromDataUrl(params.schoolStampDataUrl),
        leftX - stampSize / 2, // ≈ 72.2
        stampY,
        stampSize,
        stampSize,
      )
    } catch {
      // Continue without school stamp.
    }
  }

  if (params.adminStampDataUrl) {
    try {
      doc.addImage(
        params.adminStampDataUrl,
        imageFormatFromDataUrl(params.adminStampDataUrl),
        rightX - stampSize / 2, // ≈ 202.8
        stampY,
        stampSize,
        stampSize,
      )
    } catch {
      // Continue without admin stamp.
    }
  }

  // Signatures on top of stamps
  if (params.examinerSignatureDataUrl) {
    try {
      doc.addImage(
        params.examinerSignatureDataUrl,
        imageFormatFromDataUrl(params.examinerSignatureDataUrl),
        leftX - sigW / 2, // ≈ 65.2
        sigY,
        sigW,
        sigH,
      )
    } catch {
      // Continue without signature image.
    }
  }

  if (params.adminSignatureDataUrl) {
    try {
      doc.addImage(
        params.adminSignatureDataUrl,
        imageFormatFromDataUrl(params.adminSignatureDataUrl),
        rightX - sigW / 2, // ≈ 195.8
        sigY,
        sigW,
        sigH,
      )
    } catch {
      // Continue without admin signature image.
    }
  }

  doc.setDrawColor(80, 80, 80)
  doc.setLineWidth(0.4)
  doc.line(leftX - lineHalfW, lineY, leftX + lineHalfW, lineY)
  doc.line(rightX - lineHalfW, lineY, rightX + lineHalfW, lineY)

  const schoolDirectorTitle =
    params.examinerGender === 'F'
      ? "Directrice de l'École"
      : params.examinerGender === 'M'
        ? "Directeur de l'École"
        : "Directeur de l'École"

  const adminDirectorTitle =
    params.adminGender === 'F' ? 'Directrice' : params.adminGender === 'M' ? 'Directeur' : null
  const adminName = params.adminSignatoryName?.trim() || adminLabel
  const adminNameLine = adminDirectorTitle ? `${adminDirectorTitle}, ${adminName}` : adminName

  doc.setFont('helvetica', 'bold')
  doc.setFontSize(10)
  doc.setTextColor(40, 40, 40)
  if (params.examinerName?.trim()) {
    doc.text(params.examinerName.trim(), leftX, lineY + 6, { align: 'center' })
  }
  doc.text(adminNameLine, rightX, lineY + 6, { align: 'center' })

  doc.setFont('helvetica', 'normal')
  doc.setFontSize(8)
  doc.setTextColor(100, 100, 100)
  doc.text(schoolDirectorTitle, leftX, lineY + 12, { align: 'center' })
  doc.text(adminLabel, rightX, lineY + 12, { align: 'center' })

  // Full organization name at the very bottom
  doc.setFontSize(7)
  doc.setTextColor(120, 120, 120)
  doc.text(tagline, pageW / 2, pageH - 14, { align: 'center' })

  return doc.output('blob')
}

export default function SchoolCertificatesPage() {
  const supabase = createClient()

  const [schoolId, setSchoolId] = useState<string | null>(null)
  const [schoolName, setSchoolName] = useState<string>('')
  const [certificates, setCertificates] = useState<Certificate[]>([])
  const [validatedResults, setValidatedResults] = useState<ValidatedResult[]>([])
  const [students, setStudents] = useState<StudentRow[]>([])
  const [sessions, setSessions] = useState<ExamSession[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [generating, setGenerating] = useState<string | null>(null)

  const getSchoolContext = useCallback(async () => {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return null
    const { data } = await supabase
      .from('schools')
      .select('id, school_name')
      .eq('profile_id', user.id)
      .maybeSingle()
    if (!data) return null
    return { id: data.id, name: data.school_name }
  }, [supabase])

  const fetchAll = useCallback(async (sid: string) => {
    const [studs, sess, certs, validated] = await Promise.all([
      supabase.from('school_students').select('id, first_name, last_name, cefr_level').eq('school_id', sid),
      supabase.from('exam_sessions').select('id, title, cefr_level'),
      supabase.from('school_certificates').select('id, certificate_number, school_student_id, cefr_level, issue_date, pdf_path').eq('school_id', sid).order('issue_date', { ascending: false }),
      supabase.from('exam_result_drafts')
        .select('id, school_student_id, exam_session_id, score_eo, score_ee, score_co, score_ce, score_langue, total_score, status')
        .eq('school_id', sid)
        .in('status', ['draft', 'submitted', 'validated']),
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
      const context = schoolId
        ? { id: schoolId, name: schoolName }
        : await getSchoolContext()
      if (!context) { setLoading(false); return }
      if (!schoolId) setSchoolId(context.id)
      if (!schoolName) setSchoolName(context.name)
      await fetchAll(context.id)
    } catch { setError('Failed to load certificates. Please refresh.') }
    finally { setLoading(false) }
  }, [schoolId, schoolName, getSchoolContext, fetchAll])

  useEffect(() => { loadAll() }, [loadAll])

  const getStudentName = (id: string) => {
    const s = students.find((st) => st.id === id)
    return s ? `${s.last_name} ${s.first_name}` : '—'
  }
  const getSession = (id: string) => sessions.find((s) => s.id === id)

  const pendingGeneration = validatedResults.filter((r) => {
    if (r.total_score < 50) return false
    return !certificates.some((c) => c.school_student_id === r.school_student_id)
  })

  const resolveAssetDataUrl = async (path: string | null | undefined): Promise<string | null> => {
    if (!path) return null
    try {
      const { data } = await supabase.storage.from('school-assets').createSignedUrl(path, 3600)
      if (!data?.signedUrl) return null
      return await loadImageAsDataUrl(data.signedUrl)
    } catch {
      return null
    }
  }

  const handleGenerate = async (result: ValidatedResult) => {
    if (!schoolId) return
    setGenerating(result.id)
    setError(null)

    const session = getSession(result.exam_session_id)
    const studentName = getStudentName(result.school_student_id)
    const cefrLevel = session?.cefr_level ?? 'A1'
    const certNumber = `CERT-${Date.now().toString(36).toUpperCase()}-${Math.random().toString(36).substring(2, 5).toUpperCase()}`
    const issueDate = new Date().toISOString().split('T')[0]
    const verificationCode = certNumber.slice(-8)
    const resolvedSchoolName = schoolName || 'School'

    let certificateId: string | null = null

    try {
      const { data: inserted, error: insertErr } = await supabase
        .from('school_certificates')
        .insert({
          school_id: schoolId,
          school_student_id: result.school_student_id,
          exam_result_draft_id: result.id,
          certificate_number: certNumber,
          cefr_level: cefrLevel,
          issue_date: issueDate,
        })
        .select('id')
        .single()

      if (insertErr) throw new Error(`Failed to create certificate record: ${insertErr.message}`)
      certificateId = inserted.id

      // Fetch examiner / branding assets from school_settings (non-blocking on missing data)
      let examinerName: string | null = null
      let examinerGender: 'M' | 'F' | null = null
      let schoolLogoDataUrl: string | null = null
      let examinerSignatureDataUrl: string | null = null
      let schoolStampDataUrl: string | null = null
      try {
        const { data: settings } = await supabase
          .from('school_settings')
          .select('examiner_name, examiner_gender, examiner_signature_path, school_logo_path, stamp_path')
          .eq('school_id', schoolId)
          .maybeSingle()
        examinerName = settings?.examiner_name?.trim() || null
        examinerGender =
          settings?.examiner_gender === 'M' || settings?.examiner_gender === 'F'
            ? settings.examiner_gender
            : null
        const [logoUrl, signatureUrl, stampUrl] = await Promise.all([
          resolveAssetDataUrl(settings?.school_logo_path),
          resolveAssetDataUrl(settings?.examiner_signature_path),
          resolveAssetDataUrl(settings?.stamp_path),
        ])
        schoolLogoDataUrl = logoUrl
        examinerSignatureDataUrl = signatureUrl
        schoolStampDataUrl = stampUrl
      } catch {
        // Continue PDF generation without school branding assets.
      }

      // Fetch global admin org branding (non-blocking on missing data)
      let orgName = DEFAULT_ORG_SHORT_NAME
      let orgShortName = DEFAULT_ORG_SHORT_NAME
      let orgTagline = DEFAULT_ORG_TAGLINE
      let adminSignatoryName: string | null = null
      let adminGender: 'M' | 'F' | null = null
      let adminLogoDataUrl: string | null = null
      let adminSignatureDataUrl: string | null = null
      let adminStampDataUrl: string | null = null
      try {
        const { data: orgSettings } = await supabase
          .from('org_settings')
          .select('org_name, org_short_name, org_tagline, logo_url, signature_url, stamp_url, admin_signatory_name, admin_gender')
          .limit(1)
          .maybeSingle()
        if (orgSettings) {
          orgShortName = orgSettings.org_short_name?.trim() || DEFAULT_ORG_SHORT_NAME
          orgTagline = orgSettings.org_tagline?.trim() || DEFAULT_ORG_TAGLINE
          orgName = orgSettings.org_name?.trim() || orgShortName
          adminSignatoryName = orgSettings.admin_signatory_name?.trim() || null
          adminGender =
            orgSettings.admin_gender === 'M' || orgSettings.admin_gender === 'F'
              ? orgSettings.admin_gender
              : null
          const [adminLogo, adminSig, adminStamp] = await Promise.all([
            loadImageAsDataUrl(MFK_LOGO_SRC),
            orgSettings.signature_url ? loadImageAsDataUrl(orgSettings.signature_url) : Promise.resolve(null),
            orgSettings.stamp_url ? loadImageAsDataUrl(orgSettings.stamp_url) : Promise.resolve(null),
          ])
          adminLogoDataUrl = adminLogo
          adminSignatureDataUrl = adminSig
          adminStampDataUrl = adminStamp
        }
      } catch {
        // Continue PDF generation without admin branding assets.
      }
      if (!adminLogoDataUrl) {
        adminLogoDataUrl = await loadImageAsDataUrl(MFK_LOGO_SRC)
      }

      let pdfBlob: Blob
      try {
        pdfBlob = await generateCertificatePdf({
          studentName,
          cefrLevel,
          schoolName: resolvedSchoolName,
          certificateNumber: certNumber,
          issueDate,
          verificationCode,
          scores: {
            score_eo: result.score_eo,
            score_ee: result.score_ee,
            score_co: result.score_co,
            score_ce: result.score_ce,
            score_langue: result.score_langue,
            total_score: result.total_score,
          },
          examinerName,
          examinerGender,
          schoolLogoDataUrl,
          examinerSignatureDataUrl,
          schoolStampDataUrl,
          orgName,
          orgShortName,
          orgTagline,
          adminSignatoryName,
          adminGender,
          adminLogoDataUrl,
          adminSignatureDataUrl,
          adminStampDataUrl,
        })
      } catch {
        throw new Error('Failed to generate certificate PDF.')
      }

      // Path must start with school UUID so it matches school-assets RLS
      // ("Schools manage own school assets" / school_assets_insert).
      const pdfPath = `${schoolId}/certificates/${certNumber}.pdf`
      const { error: uploadErr } = await supabase.storage
        .from('school-assets')
        .upload(pdfPath, pdfBlob, { contentType: 'application/pdf', upsert: true })

      if (uploadErr) throw new Error(`Failed to upload PDF: ${uploadErr.message}`)

      const { error: updateErr } = await supabase
        .from('school_certificates')
        .update({ pdf_path: pdfPath })
        .eq('id', certificateId)

      if (updateErr) throw new Error(`Failed to save PDF path: ${updateErr.message}`)

      await fetchAll(schoolId)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Certificate generation failed.')
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
          <p className="text-sm text-gray-500 mt-1">Generate and download certificates for students who scored 50 or above.</p>
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

      {!loading && pendingGeneration.length > 0 && (
        <Card className="border-0 shadow-sm border-l-4 border-l-[#1E5FA8]">
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-[#E8F1FA] flex items-center justify-center">
                <FilePlus2 className="w-4 h-4 text-[#1E5FA8]" />
              </div>
              <CardTitle className="text-sm font-semibold text-[#1E5FA8]">
                Ready to Generate ({pendingGeneration.length})
              </CardTitle>
            </div>
          </CardHeader>
          <CardContent className="pt-0">
            <p className="text-xs text-gray-500 mb-3">These students passed (score ≥ 50). Generate their certificates now.</p>
            <div className="space-y-2">
              {pendingGeneration.map((r) => {
                const session = getSession(r.exam_session_id)
                return (
                  <div key={r.id} className="flex items-center justify-between p-3 rounded-lg bg-[#E8F1FA]/60 border border-green-100">
                    <div>
                      <p className="text-sm font-semibold text-gray-900">{getStudentName(r.school_student_id)}</p>
                      <p className="text-xs text-gray-500">{session?.title} — {session?.cefr_level} — Score: {r.total_score}/100</p>
                    </div>
                    <Button size="sm" className="bg-[#1E5FA8] hover:bg-[#164A82] text-white"
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
                      <p className="text-xs text-gray-400">Certificates appear here after you generate them for a passing result.</p>
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
                        <ShieldCheck className="w-3.5 h-3.5 text-[#1E5FA8] flex-shrink-0" />
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
                        <span className="flex items-center justify-end gap-1 text-xs text-[#1E5FA8]">
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
