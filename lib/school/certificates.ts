import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';
import QRCode from 'qrcode';
import { getServiceClient } from '@/lib/supabase/service';
import { COMPETENCIES, sanitizeFileName } from '@/lib/school/constants';

type GenerateCertificateOptions = {
  schoolId: string;
  resultId?: string;
  certificateId?: string;
  origin: string;
};

async function embedStorageImage(pdf: PDFDocument, path?: string | null) {
  if (!path || /^https?:\/\//.test(path)) return null;

  const service = getServiceClient();
  if (!service) return null;

  const { data, error } = await service.storage.from('school-assets').download(path);
  if (error || !data) return null;

  const bytes = new Uint8Array(await data.arrayBuffer());
  const lower = path.toLowerCase();
  try {
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return pdf.embedJpg(bytes);
    }
    return pdf.embedPng(bytes);
  } catch {
    return null;
  }
}

async function findResult(service: NonNullable<ReturnType<typeof getServiceClient>>, options: GenerateCertificateOptions) {
  if (options.resultId) {
    const { data, error } = await service
      .from('student_results')
      .select(
        '*, students(id, first_name, last_name, grade), exam_sessions(id, title, cefr_level, exam_date)'
      )
      .eq('school_id', options.schoolId)
      .eq('id', options.resultId)
      .maybeSingle();
    if (error) throw error;
    return data;
  }

  if (!options.certificateId) return null;

  const { data: certificate, error: certificateError } = await service
    .from('certificates')
    .select('id, student_id, level')
    .eq('school_id', options.schoolId)
    .eq('id', options.certificateId)
    .maybeSingle();

  if (certificateError) throw certificateError;
  if (!certificate) return null;

  const { data, error } = await service
    .from('student_results')
    .select(
      '*, students(id, first_name, last_name, grade), exam_sessions(id, title, cefr_level, exam_date)'
    )
    .eq('school_id', options.schoolId)
    .eq('student_id', certificate.student_id)
    .eq('validated_by_admin', true)
    .eq('overall_pass', true)
    .order('validated_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error) throw error;
  return data;
}

export async function generateCertificatePdf(options: GenerateCertificateOptions) {
  const service = getServiceClient();
  if (!service) throw new Error('Configuration Supabase service role manquante.');

  const result: any = await findResult(service, options);
  if (!result) throw new Error('Résultat introuvable.');
  if (!result.validated_by_admin || !result.overall_pass) {
    throw new Error("Le certificat n'est disponible qu'après validation admin d'un résultat réussi.");
  }

  const { data: school, error: schoolError } = await service
    .from('schools')
    .select('id, school_name, name, director_name, logo_url, signature_url')
    .eq('id', options.schoolId)
    .maybeSingle();

  if (schoolError) throw schoolError;
  if (!school) throw new Error('Établissement introuvable.');

  const level = result.exam_sessions?.cefr_level ?? 'A1';
  const studentName = `${result.students?.first_name ?? ''} ${result.students?.last_name ?? ''}`.trim();

  let { data: certificate, error: certificateLookupError } = await service
    .from('certificates')
    .select('*')
    .eq('school_id', options.schoolId)
    .eq('student_id', result.student_id)
    .eq('level', level)
    .maybeSingle();

  if (certificateLookupError) throw certificateLookupError;

  if (!certificate) {
    const certificateUuid =
      typeof crypto !== 'undefined' && 'randomUUID' in crypto
        ? crypto.randomUUID()
        : `${Date.now()}-${Math.random().toString(36).slice(2)}`;

    const { data: inserted, error: insertError } = await service
      .from('certificates')
      .insert({
        student_id: result.student_id,
        school_id: options.schoolId,
        level,
        cefr_level: level,
        issue_date: new Date().toISOString().split('T')[0],
        certificate_uuid: certificateUuid,
        certificate_number: `FLE-${certificateUuid.slice(0, 8).toUpperCase()}`,
        verification_code: certificateUuid,
        verified_url: `${options.origin}/certificats/verifier/${certificateUuid}`,
      })
      .select('*')
      .single();

    if (insertError) throw insertError;
    certificate = inserted;
  }

  const certificateUuid = certificate.certificate_uuid ?? certificate.verification_code;
  const verifiedUrl =
    certificate.verified_url ?? `${options.origin}/certificats/verifier/${certificateUuid}`;

  const pdf = await PDFDocument.create();
  const page = pdf.addPage([842, 595]);
  const { width, height } = page.getSize();
  const font = await pdf.embedFont(StandardFonts.Helvetica);
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
  const green = rgb(0, 0.647, 0.314);
  const dark = rgb(0.08, 0.09, 0.11);
  const grey = rgb(0.35, 0.37, 0.4);

  page.drawRectangle({ x: 0, y: height - 18, width, height: 18, color: green });
  page.drawText('FLEHub', { x: 54, y: height - 72, size: 26, font: bold, color: green });
  page.drawText('Certification officielle de français', {
    x: 54,
    y: height - 94,
    size: 11,
    font,
    color: grey,
  });

  const schoolLogo = await embedStorageImage(pdf, school.logo_url);
  if (schoolLogo) {
    const logoDims = schoolLogo.scaleToFit(92, 64);
    page.drawImage(schoolLogo, {
      x: width - 54 - logoDims.width,
      y: height - 108,
      width: logoDims.width,
      height: logoDims.height,
    });
  } else {
    page.drawText(school.name ?? school.school_name ?? 'Établissement', {
      x: width - 290,
      y: height - 76,
      size: 13,
      font: bold,
      color: dark,
    });
  }

  page.drawText('CERTIFICAT DE RÉUSSITE', {
    x: 230,
    y: height - 165,
    size: 28,
    font: bold,
    color: dark,
  });

  page.drawText('Décerné à', { x: 380, y: height - 210, size: 13, font, color: grey });
  page.drawText(studentName, {
    x: 120,
    y: height - 252,
    size: 34,
    font: bold,
    color: green,
  });
  page.drawText(`pour l'obtention du Niveau ${level}`, {
    x: 280,
    y: height - 286,
    size: 17,
    font,
    color: dark,
  });

  const startX = 90;
  const startY = height - 350;
  page.drawText('Résultats par compétence', { x: startX, y: startY + 28, size: 12, font: bold, color: dark });

  COMPETENCIES.forEach((competency, index) => {
    const x = startX + index * 135;
    const score = Number(result[competency.scoreKey] ?? 0);
    page.drawRectangle({
      x,
      y: startY - 20,
      width: 112,
      height: 58,
      borderColor: rgb(0.88, 0.9, 0.92),
      borderWidth: 1,
      color: rgb(0.97, 0.97, 0.97),
    });
    page.drawText(competency.key === 'LANGUE' ? 'Langue' : competency.key, {
      x: x + 12,
      y: startY + 14,
      size: 10,
      font: bold,
      color: grey,
    });
    page.drawText(`${score}/100`, { x: x + 12, y: startY - 8, size: 16, font: bold, color: dark });
  });

  const qrDataUrl = await QRCode.toDataURL(verifiedUrl, { margin: 1, width: 96 });
  const qrBytes = Uint8Array.from(Buffer.from(qrDataUrl.split(',')[1], 'base64'));
  const qrImage = await pdf.embedPng(qrBytes);
  page.drawImage(qrImage, { x: width - 155, y: 58, width: 82, height: 82 });
  page.drawText(`ID: ${certificateUuid}`, { x: width - 245, y: 42, size: 8, font, color: grey });

  const signature = await embedStorageImage(pdf, school.signature_url);
  if (signature) {
    const signatureDims = signature.scaleToFit(150, 56);
    page.drawImage(signature, {
      x: 100,
      y: 76,
      width: signatureDims.width,
      height: signatureDims.height,
    });
  }
  page.drawLine({ start: { x: 90, y: 72 }, end: { x: 285, y: 72 }, thickness: 1, color: grey });
  page.drawText(school.director_name ?? 'Directeur', { x: 100, y: 52, size: 10, font: bold, color: dark });
  page.drawText('Signature du directeur', { x: 100, y: 38, size: 8, font, color: grey });

  page.drawText(`Date d'émission : ${new Date(certificate.issue_date).toLocaleDateString('fr-FR')}`, {
    x: 340,
    y: 64,
    size: 10,
    font,
    color: grey,
  });

  const pdfBytes = await pdf.save();
  const path = `${options.schoolId}/${certificateUuid}.pdf`;
  const { error: uploadError } = await service.storage.from('certificates').upload(path, pdfBytes, {
    contentType: 'application/pdf',
    upsert: true,
  });

  if (uploadError) throw uploadError;

  const { data: publicUrl } = service.storage.from('certificates').getPublicUrl(path);
  await service
    .from('certificates')
    .update({
      pdf_url: publicUrl.publicUrl,
      verified_url: verifiedUrl,
      certificate_uuid: certificateUuid,
      verification_code: certificateUuid,
      certificate_number: certificate.certificate_number ?? `FLE-${String(certificateUuid).slice(0, 8).toUpperCase()}`,
    })
    .eq('id', certificate.id);

  return {
    bytes: pdfBytes,
    certificate,
    filename: `${sanitizeFileName(studentName || 'certificat')}-${level}.pdf`,
  };
}
