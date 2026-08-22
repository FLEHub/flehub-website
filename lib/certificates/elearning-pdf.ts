import { jsPDF } from 'jspdf'
import type { CefrLevel } from '@/lib/types'
import {
  DEFAULT_ORG_SHORT_NAME,
  DEFAULT_ORG_TAGLINE,
  adminOrgLabel,
} from '@/lib/org-branding'

const CEFR_LABELS: Record<CefrLevel, string> = {
  A1: 'Débutant',
  A2: 'Élémentaire',
  B1: 'Intermédiaire',
  B2: 'Intermédiaire supérieur',
  C1: 'Avancé',
  C2: 'Maîtrise',
}

export function formatScore(value: number | null | undefined): string {
  if (value == null || Number.isNaN(Number(value))) return '—'
  return Number(value).toFixed(Number.isInteger(Number(value)) ? 0 : 1)
}

export function imageFormatFromDataUrl(dataUrl: string): 'PNG' | 'JPEG' {
  if (dataUrl.startsWith('data:image/jpeg') || dataUrl.startsWith('data:image/jpg')) {
    return 'JPEG'
  }
  return 'PNG'
}

export async function loadImageAsDataUrl(src: string): Promise<string | null> {
  try {
    const response = await fetch(src)
    if (!response.ok) return null
    const blob = await response.blob()
    return await new Promise((resolve) => {
      const reader = new FileReader()
      reader.onloadend = () =>
        resolve(typeof reader.result === 'string' ? reader.result : null)
      reader.onerror = () => resolve(null)
      reader.readAsDataURL(blob)
    })
  } catch {
    return null
  }
}

/** Unique certificate number: FLE-{year}-{6 alphanumeric chars} */
export function generateElearningCertificateNumber(): string {
  const year = new Date().getFullYear()
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  let suffix = ''
  const arr = new Uint8Array(6)
  if (typeof crypto !== 'undefined' && crypto.getRandomValues) {
    crypto.getRandomValues(arr)
    for (let i = 0; i < 6; i++) suffix += chars[arr[i]! % chars.length]
  } else {
    for (let i = 0; i < 6; i++) {
      suffix += chars[Math.floor(Math.random() * chars.length)]
    }
  }
  return `FLE-${year}-${suffix}`
}

export interface ElearningCertificatePdfParams {
  studentName: string
  cefrLevel: CefrLevel
  certificateNumber: string
  issueDate: string
  scores: {
    score_po: number | null
    score_pe: number | null
    score_co: number | null
    score_ce: number | null
    score_langue: number | null
    total_score: number
  }
  orgName: string
  orgShortName?: string | null
  orgTagline?: string | null
  adminSignatoryName: string | null
  adminLogoDataUrl: string | null
  adminSignatureDataUrl: string | null
  adminStampDataUrl?: string | null
  teacherName: string | null
  teacherSignatureDataUrl: string | null
}

/**
 * Level certificate for the individual (teacher-followed) path.
 * Layout based on school certificates:
 * - Admin logo top-left
 * - Admin name + signature bottom-left
 * - Teacher name + signature bottom-right
 */
export async function generateElearningCertificatePdf(
  params: ElearningCertificatePdfParams
): Promise<Blob> {
  const doc = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' })
  const pageW = doc.internal.pageSize.getWidth()
  const pageH = doc.internal.pageSize.getHeight()

  doc.setDrawColor(11, 31, 58)
  doc.setLineWidth(1.5)
  doc.rect(10, 10, pageW - 20, pageH - 20)
  doc.setLineWidth(0.5)
  doc.rect(14, 14, pageW - 28, pageH - 28)

  // Official circular MFK emblem — keep a square box so the round logo is not stretched
  const topLogoSize = 16
  const topLogoY = 20
  const leftLogoX = 20

  if (params.adminLogoDataUrl) {
    try {
      doc.addImage(
        params.adminLogoDataUrl,
        imageFormatFromDataUrl(params.adminLogoDataUrl),
        leftLogoX,
        topLogoY,
        topLogoSize,
        topLogoSize
      )
    } catch {
      // Continue without admin logo.
    }
  }

  const shortName = params.orgShortName?.trim() || DEFAULT_ORG_SHORT_NAME
  const tagline = params.orgTagline?.trim() || DEFAULT_ORG_TAGLINE
  const brandName = params.orgName.trim() || shortName
  const adminLabel = adminOrgLabel(shortName)
  doc.setFont('helvetica', 'bold')
  doc.setFontSize(26)
  doc.setTextColor(11, 31, 58)
  doc.text(brandName, pageW / 2, 32, { align: 'center' })

  doc.setFontSize(11)
  doc.setTextColor(100, 100, 100)
  doc.setFont('helvetica', 'normal')
  doc.text(
    "Plateforme d'examen de français langue étrangère",
    pageW / 2,
    40,
    { align: 'center' }
  )

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
  doc.text(
    'a obtenu avec succès le niveau CECRL',
    pageW / 2,
    bodyStartY + 26,
    { align: 'center' }
  )

  doc.setFontSize(18)
  doc.setTextColor(30, 95, 168)
  doc.setFont('helvetica', 'bold')
  doc.text(
    `${params.cefrLevel} — ${CEFR_LABELS[params.cefrLevel]}`,
    pageW / 2,
    bodyStartY + 38,
    { align: 'center' }
  )

  doc.setFont('helvetica', 'normal')
  doc.setFontSize(12)
  doc.setTextColor(80, 80, 80)
  const teacherLabel = params.teacherName?.trim()
  doc.text(
    teacherLabel
      ? `Parcours individuel — Enseignant : ${teacherLabel}`
      : 'Parcours individuel',
    pageW / 2,
    bodyStartY + 50,
    { align: 'center' }
  )

  const scoreLine = [
    `PO : ${formatScore(params.scores.score_po)}/20`,
    `PE : ${formatScore(params.scores.score_pe)}/20`,
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
  doc.text(
    `N° de certificat : ${params.certificateNumber}`,
    pageW / 2,
    bodyStartY + 74,
    { align: 'center' }
  )
  doc.text(
    `Date de délivrance : ${formattedDate}`,
    pageW / 2,
    bodyStartY + 80,
    { align: 'center' }
  )

  // Dual signature zones: admin (left) + teacher (right)
  const leftX = pageW * 0.28
  const rightX = pageW * 0.72
  const lineY = pageH - 42
  const lineHalfW = 40
  const stampSize = 16

  // Admin stamp above admin signature (left block)
  if (params.adminStampDataUrl) {
    try {
      doc.addImage(
        params.adminStampDataUrl,
        imageFormatFromDataUrl(params.adminStampDataUrl),
        leftX - stampSize / 2,
        lineY - 40,
        stampSize,
        stampSize
      )
    } catch {
      // Continue without admin stamp.
    }
  }

  if (params.adminSignatureDataUrl) {
    try {
      doc.addImage(
        params.adminSignatureDataUrl,
        imageFormatFromDataUrl(params.adminSignatureDataUrl),
        leftX - 18,
        lineY - 22,
        36,
        18
      )
    } catch {
      // Continue without admin signature.
    }
  }

  if (params.teacherSignatureDataUrl) {
    try {
      doc.addImage(
        params.teacherSignatureDataUrl,
        imageFormatFromDataUrl(params.teacherSignatureDataUrl),
        rightX - 18,
        lineY - 22,
        36,
        18
      )
    } catch {
      // Continue without teacher signature.
    }
  }

  doc.setDrawColor(80, 80, 80)
  doc.setLineWidth(0.4)
  doc.line(leftX - lineHalfW, lineY, leftX + lineHalfW, lineY)
  doc.line(rightX - lineHalfW, lineY, rightX + lineHalfW, lineY)

  doc.setFont('helvetica', 'bold')
  doc.setFontSize(10)
  doc.setTextColor(40, 40, 40)
  doc.text(
    params.adminSignatoryName?.trim() || adminLabel,
    leftX,
    lineY + 6,
    { align: 'center' }
  )
  doc.text(
    params.teacherName?.trim() || 'Enseignant',
    rightX,
    lineY + 6,
    { align: 'center' }
  )

  doc.setFont('helvetica', 'normal')
  doc.setFontSize(8)
  doc.setTextColor(100, 100, 100)
  doc.text(adminLabel, leftX, lineY + 12, { align: 'center' })
  doc.text('Enseignant', rightX, lineY + 12, { align: 'center' })

  // Full organization name at the very bottom
  doc.setFontSize(7)
  doc.setTextColor(120, 120, 120)
  doc.text(tagline, pageW / 2, pageH - 14, { align: 'center' })

  return doc.output('blob')
}
