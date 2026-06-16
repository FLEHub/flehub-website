import { NextResponse } from 'next/server';
import JSZip from 'jszip';
import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';
import QRCode from 'qrcode';
import { createClient } from '@/lib/supabase/server';
import { getProfileForUser } from '@/lib/supabase/get-profile';

type CefrLevel = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';
type Competency = 'EO' | 'EE' | 'CO' | 'CE' | 'LANGUE';

const COMPETENCIES: Competency[] = ['EO', 'EE', 'CO', 'CE', 'LANGUE'];
const COMPETENCY_LABELS: Record<Competency, string> = {
  EO: 'Expression Orale',
  EE: 'Expression Écrite',
  CO: 'Compréhension Orale',
  CE: 'Compréhension Écrite',
  LANGUE: 'Étude de la Langue',
};

type SchoolRecord = {
  id: string;
  profile_id: string;
  name: string | null;
  school_name: string | null;
  type: 'primary' | 'secondary' | 'both' | null;
  address: string | null;
  district: string | null;
  province: string | null;
  sector: string | null;
  cell: string | null;
  village: string | null;
  logo_url: string | null;
  signature_url: string | null;
  director_name: string | null;
  contact_person: string | null;
  email: string | null;
  phone: string | null;
  status: string | null;
  created_at: string;
};

type StudentRecord = {
  id: string;
  school_id: string;
  first_name: string;
  last_name: string;
  date_of_birth: string;
  gender: 'M' | 'F';
  grade: string;
  created_at: string;
};

type SchoolStudentRecord = {
  id: string;
  school_id: string;
  first_name: string;
  last_name: string;
  created_at: string;
};

type ExamSessionRecord = {
  id: string;
  title: string;
  cefr_level: CefrLevel;
  exam_date: string;
  registration_deadline: string | null;
  venue: string | null;
  status: string;
};

type ResultPayload = {
  student_id: string;
  exam_session_id: string;
  score_eo: number | null;
  score_ee: number | null;
  score_co: number | null;
  score_ce: number | null;
  score_langue: number | null;
};

async function requireApprovedSchool() {
  const supabase = await createClient();
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser();

  if (userError || !user) {
    return { error: NextResponse.json({ error: 'Non authentifié.' }, { status: 401 }) };
  }

  const { profile } = await getProfileForUser(user.id);
  if (!profile || profile.role !== 'school') {
    return { error: NextResponse.json({ error: 'Accès réservé aux écoles.' }, { status: 403 }) };
  }

  if (profile.status !== 'approved') {
    return {
      error: NextResponse.json(
        { error: "Votre compte école doit être approuvé avant d'accéder à cet espace." },
        { status: 403 }
      ),
    };
  }

  const { data: school, error: schoolError } = await supabase
    .from('schools')
    .select(
      'id, profile_id, name, school_name, type, address, district, province, sector, cell, village, logo_url, signature_url, director_name, contact_person, email, phone, status, created_at'
    )
    .eq('profile_id', user.id)
    .maybeSingle();

  if (schoolError || !school) {
    return {
      error: NextResponse.json(
        { error: "Profil institutionnel introuvable. Contactez l'administrateur." },
        { status: 404 }
      ),
    };
  }

  return { supabase, user, profile, school: school as SchoolRecord };
}

function jsonError(message: string, status = 400) {
  return NextResponse.json({ error: message }, { status });
}

function toNumber(value: unknown) {
  if (value === null || value === undefined || value === '') return null;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function calculateResult(payload: ResultPayload, threshold = 60) {
  const scores = [
    payload.score_eo,
    payload.score_ee,
    payload.score_co,
    payload.score_ce,
    payload.score_langue,
  ].map((score) => score ?? 0);
  const total = scores.reduce((sum, score) => sum + score, 0) / scores.length;
  return { total_score: Number(total.toFixed(2)), overall_pass: total >= threshold };
}

async function signedAssetUrl(
  supabase: Awaited<ReturnType<typeof createClient>>,
  path: string | null | undefined,
  bucket = 'school-assets'
) {
  if (!path) return null;
  if (/^https?:\/\//.test(path)) return path;
  const { data } = await supabase.storage.from(bucket).createSignedUrl(path, 60 * 60);
  return data?.signedUrl ?? null;
}

function fileExtension(file: File, fallback: string) {
  const namePart = file.name.split('.').pop()?.toLowerCase();
  if (namePart) return namePart;
  if (file.type === 'image/png') return 'png';
  if (file.type === 'image/jpeg') return 'jpg';
  return fallback;
}

async function uploadSchoolAsset(
  supabase: Awaited<ReturnType<typeof createClient>>,
  schoolId: string,
  file: File | null,
  kind: 'logo' | 'signature'
) {
  if (!file || file.size === 0) return null;
  const allowed = kind === 'signature' ? ['image/png'] : ['image/png', 'image/jpeg'];
  if (!allowed.includes(file.type)) {
    throw new Error(
      kind === 'signature'
        ? 'La signature doit être une image PNG.'
        : 'Le logo doit être une image PNG ou JPG.'
    );
  }

  const ext = fileExtension(file, kind === 'signature' ? 'png' : 'jpg');
  const path = `${schoolId}/${kind}-${Date.now()}.${ext}`;
  const { error } = await supabase.storage
    .from('school-assets')
    .upload(path, file, { contentType: file.type, upsert: true });

  if (error) throw error;
  return path;
}

async function getOverview(context: Awaited<ReturnType<typeof requireApprovedSchool>>) {
  if (!('school' in context) || !context.supabase) return null;
  const { supabase, school } = context;

  const [
    schoolStudentsRes,
    studentsRes,
    enrollmentsRes,
    sessionsRes,
    papersRes,
    downloadsRes,
    resultsRes,
    certificatesRes,
  ] = await Promise.all([
    supabase
      .from('school_students')
      .select('id, school_id, first_name, last_name, created_at')
      .eq('school_id', school.id)
      .order('last_name', { ascending: true })
      .order('first_name', { ascending: true }),
    supabase
      .from('students')
      .select('id, school_id, first_name, last_name, date_of_birth, gender, grade, created_at')
      .eq('school_id', school.id)
      .order('last_name', { ascending: true }),
    supabase
      .from('student_enrollments')
      .select('id, student_id, exam_session_id, cefr_level, active, enrolled_at')
      .eq('active', true)
      .order('enrolled_at', { ascending: false }),
    supabase
      .from('exam_sessions')
      .select('id, title, cefr_level, exam_date, registration_deadline, venue, status')
      .order('exam_date', { ascending: false }),
    supabase
      .from('exam_papers')
      .select('id, exam_session_id, competency, file_path, created_at'),
    supabase
      .from('exam_downloads')
      .select('id, school_id, exam_id, competency, downloaded_at')
      .eq('school_id', school.id)
      .order('downloaded_at', { ascending: false }),
    supabase
      .from('student_results')
      .select(
        'id, student_id, school_id, exam_session_id, score_eo, score_ee, score_co, score_ce, score_langue, total_score, overall_pass, submitted, submitted_at, validated_by_admin, validation_status, admin_feedback, validated_at, created_at, updated_at'
      )
      .eq('school_id', school.id)
      .order('updated_at', { ascending: false }),
    supabase
      .from('certificates')
      .select(
        'id, student_id, school_id, level, cefr_level, issue_date, certificate_uuid, certificate_number, verification_code, pdf_url, verified_url, created_at'
      )
      .eq('school_id', school.id)
      .order('created_at', { ascending: false }),
  ]);

  for (const response of [
    schoolStudentsRes,
    studentsRes,
    enrollmentsRes,
    sessionsRes,
    papersRes,
    downloadsRes,
    resultsRes,
    certificatesRes,
  ]) {
    if (response.error) throw response.error;
  }

  const schoolStudents = (schoolStudentsRes.data ?? []) as SchoolStudentRecord[];
  const students = (studentsRes.data ?? []) as StudentRecord[];
  const enrollments = enrollmentsRes.data ?? [];
  const sessions = (sessionsRes.data ?? []) as ExamSessionRecord[];
  const results = resultsRes.data ?? [];

  const enrolledSessionIds = new Set(enrollments.map((e: any) => e.exam_session_id));
  const validatedPassResults = results.filter(
    (r: any) => r.validated_by_admin && r.overall_pass
  ).length;

  return {
    school: {
      ...school,
      display_name: school.name ?? school.school_name,
      logo_signed_url: await signedAssetUrl(supabase, school.logo_url),
      signature_signed_url: await signedAssetUrl(supabase, school.signature_url),
    },
    schoolStudents,
    students,
    enrollments,
    sessions,
    examPapers: papersRes.data ?? [],
    downloads: downloadsRes.data ?? [],
    results,
    certificates: certificatesRes.data ?? [],
    stats: {
      students: schoolStudents.length,
      activeEnrollments: enrollments.length,
      activeSessions: sessions.filter((s) => enrolledSessionIds.has(s.id)).length,
      submittedResults: results.filter((r: any) => r.submitted).length,
      validatedPassResults,
      certificates: certificatesRes.data?.length ?? 0,
      passRate:
        results.length > 0
          ? Math.round(
              (results.filter((r: any) => r.validated_by_admin && r.overall_pass).length /
                results.filter((r: any) => r.validated_by_admin).length || 0) * 100
            )
          : 0,
    },
  };
}

async function fetchBytes(url: string | null) {
  if (!url) return null;
  try {
    const response = await fetch(url);
    if (!response.ok) return null;
    return new Uint8Array(await response.arrayBuffer());
  } catch {
    return null;
  }
}

async function drawImageIfPossible(
  pdfDoc: PDFDocument,
  page: ReturnType<PDFDocument['addPage']>,
  bytes: Uint8Array | null,
  x: number,
  y: number,
  maxWidth: number,
  maxHeight: number
) {
  if (!bytes) return;
  try {
    const image = await pdfDoc.embedPng(bytes).catch(() => pdfDoc.embedJpg(bytes));
    const scaled = image.scale(Math.min(maxWidth / image.width, maxHeight / image.height));
    page.drawImage(image, { x, y, width: scaled.width, height: scaled.height });
  } catch {
    // Image preview remains optional; a bad upload should not block certificate issuance.
  }
}

async function buildCertificatePdf(params: {
  school: SchoolRecord;
  student: StudentRecord;
  result: any;
  certificateUuid: string;
  verifiedUrl: string;
  logoUrl: string | null;
  signatureUrl: string | null;
}) {
  const pdfDoc = await PDFDocument.create();
  const page = pdfDoc.addPage([842, 595]);
  const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
  const bold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);
  const green = rgb(0, 0.647, 0.314);
  const gray = rgb(0.35, 0.35, 0.35);

  page.drawRectangle({ x: 0, y: 0, width: 842, height: 595, color: rgb(1, 1, 1) });
  page.drawRectangle({ x: 24, y: 24, width: 794, height: 547, borderColor: green, borderWidth: 2 });
  page.drawText('FLEHub', { x: 60, y: 518, size: 28, font: bold, color: green });
  page.drawText('Certification officielle de français', {
    x: 60,
    y: 498,
    size: 10,
    font,
    color: gray,
  });

  await drawImageIfPossible(pdfDoc, page, await fetchBytes(params.logoUrl), 690, 488, 90, 60);

  page.drawText('CERTIFICAT DE RÉUSSITE', {
    x: 248,
    y: 438,
    size: 24,
    font: bold,
    color: green,
  });
  page.drawText('Décerné à', { x: 385, y: 398, size: 12, font, color: gray });
  page.drawText(`${params.student.first_name} ${params.student.last_name}`.toUpperCase(), {
    x: 235,
    y: 360,
    size: 28,
    font: bold,
    color: rgb(0.08, 0.08, 0.08),
  });
  page.drawText(`Niveau ${params.result.level ?? params.result.cefr_level ?? ''}`, {
    x: 365,
    y: 328,
    size: 18,
    font: bold,
    color: green,
  });

  const scores: Array<[Competency, number | null]> = [
    ['EO', params.result.score_eo],
    ['EE', params.result.score_ee],
    ['CO', params.result.score_co],
    ['CE', params.result.score_ce],
    ['LANGUE', params.result.score_langue],
  ];

  let x = 145;
  scores.forEach(([key, value]) => {
    page.drawText(key, { x, y: 268, size: 12, font: bold, color: green });
    page.drawText(`${value ?? 0}/100`, { x: x - 12, y: 247, size: 11, font, color: gray });
    x += 115;
  });

  page.drawText(`Score global : ${params.result.total_score ?? 0}/100`, {
    x: 338,
    y: 215,
    size: 13,
    font: bold,
    color: rgb(0.12, 0.12, 0.12),
  });
  page.drawText(`Date d'émission : ${new Date().toLocaleDateString('fr-RW')}`, {
    x: 60,
    y: 128,
    size: 11,
    font,
    color: gray,
  });
  page.drawText(`ID certificat : ${params.certificateUuid}`, {
    x: 60,
    y: 108,
    size: 9,
    font,
    color: gray,
  });

  await drawImageIfPossible(pdfDoc, page, await fetchBytes(params.signatureUrl), 346, 112, 150, 55);
  page.drawLine({ start: { x: 320, y: 102 }, end: { x: 520, y: 102 }, thickness: 0.7, color: gray });
  page.drawText(params.school.director_name ?? params.school.contact_person ?? 'Directeur / Directrice', {
    x: 334,
    y: 84,
    size: 11,
    font: bold,
    color: rgb(0.1, 0.1, 0.1),
  });

  const qrDataUrl = await QRCode.toDataURL(params.verifiedUrl, { margin: 1, width: 128 });
  const qrBytes = Uint8Array.from(Buffer.from(qrDataUrl.split(',')[1], 'base64'));
  const qrImage = await pdfDoc.embedPng(qrBytes);
  page.drawImage(qrImage, { x: 695, y: 68, width: 80, height: 80 });
  page.drawText('Vérification en ligne', { x: 688, y: 54, size: 8, font, color: gray });

  return pdfDoc.save();
}

async function ensureCertificate(
  supabase: Awaited<ReturnType<typeof createClient>>,
  school: SchoolRecord,
  resultId: string
) {
  const { data: result, error: resultError } = await supabase
    .from('student_results')
    .select('*')
    .eq('id', resultId)
    .eq('school_id', school.id)
    .maybeSingle();

  if (resultError || !result) throw resultError ?? new Error('Résultat introuvable.');
  if (!result.validated_by_admin || !result.overall_pass) {
    throw new Error('Le certificat est disponible uniquement après validation admin et réussite.');
  }

  const { data: session } = await supabase
    .from('exam_sessions')
    .select('cefr_level')
    .eq('id', result.exam_session_id)
    .maybeSingle();

  const level = (session?.cefr_level ?? 'A1') as CefrLevel;

  const { data: existing } = await supabase
    .from('certificates')
    .select('*')
    .eq('student_id', result.student_id)
    .eq('school_id', school.id)
    .eq('level', level)
    .maybeSingle();

  if (existing?.pdf_url) return existing;

  const { data: student, error: studentError } = await supabase
    .from('students')
    .select('id, school_id, first_name, last_name, date_of_birth, gender, grade, created_at')
    .eq('id', result.student_id)
    .eq('school_id', school.id)
    .maybeSingle();

  if (studentError || !student) throw studentError ?? new Error('Élève introuvable.');

  const certificateUuid = existing?.certificate_uuid ?? crypto.randomUUID();
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL ?? 'https://flehub.rw';
  const verifiedUrl = `${baseUrl}/verify/${certificateUuid}`;
  const certificateNumber = existing?.certificate_number ?? `FLE-${Date.now().toString(36).toUpperCase()}`;

  const certificate =
    existing ??
    (
      await supabase
        .from('certificates')
        .insert({
          student_id: result.student_id,
          school_id: school.id,
          level,
          cefr_level: level,
          issue_date: new Date().toISOString().split('T')[0],
          certificate_uuid: certificateUuid,
          certificate_number: certificateNumber,
          verification_code: certificateUuid,
          verified_url: verifiedUrl,
        })
        .select()
        .maybeSingle()
    ).data;

  if (!certificate) throw new Error("Impossible de créer l'enregistrement du certificat.");

  const [logoUrl, signatureUrl] = await Promise.all([
    signedAssetUrl(supabase, school.logo_url),
    signedAssetUrl(supabase, school.signature_url),
  ]);

  const pdfBytes = await buildCertificatePdf({
    school,
    student: student as StudentRecord,
    result: { ...result, level },
    certificateUuid,
    verifiedUrl,
    logoUrl,
    signatureUrl,
  });

  const pdfPath = `${school.id}/${certificate.id}.pdf`;
  const { error: uploadError } = await supabase.storage
    .from('certificates')
    .upload(pdfPath, pdfBytes, { contentType: 'application/pdf', upsert: true });

  if (uploadError) throw uploadError;

  const { data: updated, error: updateError } = await supabase
    .from('certificates')
    .update({ pdf_url: pdfPath, verified_url: verifiedUrl })
    .eq('id', certificate.id)
    .select()
    .maybeSingle();

  if (updateError) throw updateError;
  return updated ?? certificate;
}

export async function GET() {
  const context = await requireApprovedSchool();
  if ('error' in context) return context.error;

  try {
    const overview = await getOverview(context);
    return NextResponse.json(overview);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Chargement impossible.';
    return jsonError(message, 500);
  }
}

export async function POST(request: Request) {
  const context = await requireApprovedSchool();
  if ('error' in context) return context.error;
  const { supabase, school, user } = context;

  try {
    const contentType = request.headers.get('content-type') ?? '';
    let action = '';
    let payload: any = {};
    let formData: FormData | null = null;

    if (contentType.includes('multipart/form-data')) {
      formData = await request.formData();
      action = String(formData.get('action') ?? '');
    } else {
      payload = await request.json();
      action = payload.action;
    }

    if (action === 'updateProfile') {
      if (!formData) return jsonError('Formulaire invalide.');
      const logoPath = await uploadSchoolAsset(
        supabase,
        school.id,
        formData.get('logo') instanceof File ? (formData.get('logo') as File) : null,
        'logo'
      );
      const signaturePath = await uploadSchoolAsset(
        supabase,
        school.id,
        formData.get('signature') instanceof File ? (formData.get('signature') as File) : null,
        'signature'
      );

      const schoolPayload: Record<string, string | null> = {
        name: String(formData.get('name') ?? '').trim(),
        school_name: String(formData.get('name') ?? '').trim(),
        type: String(formData.get('type') ?? 'both'),
        address: String(formData.get('address') ?? '').trim(),
        district: String(formData.get('district') ?? '').trim(),
        director_name: String(formData.get('director_name') ?? '').trim(),
        contact_person: String(formData.get('director_name') ?? '').trim(),
        email: String(formData.get('email') ?? '').trim().toLowerCase(),
        phone: String(formData.get('phone') ?? '').trim(),
      };

      if (logoPath) schoolPayload.logo_url = logoPath;
      if (signaturePath) schoolPayload.signature_url = signaturePath;

      const { error: updateError } = await supabase
        .from('schools')
        .update(schoolPayload)
        .eq('id', school.id);
      if (updateError) throw updateError;

      await supabase
        .from('profiles')
        .update({
          full_name: schoolPayload.director_name,
          phone: schoolPayload.phone,
        })
        .eq('id', user.id);

      return NextResponse.json({ ok: true });
    }

    if (action === 'changePassword') {
      if (!payload.password || String(payload.password).length < 8) {
        return jsonError('Le mot de passe doit contenir au moins 8 caractères.');
      }
      const { error } = await supabase.auth.updateUser({ password: String(payload.password) });
      if (error) throw error;
      return NextResponse.json({ ok: true });
    }

    if (action === 'createStudent' || action === 'createSchoolStudent') {
      const studentPayload = {
        school_id: school.id,
        first_name: String(payload.first_name ?? '').trim(),
        last_name: String(payload.last_name ?? '').trim(),
      };
      if (!studentPayload.first_name || !studentPayload.last_name) {
        return jsonError('Prénom et nom sont requis.');
      }

      const { data: student, error } = await supabase
        .from('school_students')
        .insert(studentPayload)
        .select()
        .maybeSingle();
      if (error) throw error;

      return NextResponse.json({ ok: true, student });
    }

    if (action === 'deleteStudent' || action === 'deleteSchoolStudent') {
      const { error } = await supabase
        .from('school_students')
        .delete()
        .eq('id', payload.student_id)
        .eq('school_id', school.id);
      if (error) throw error;
      return NextResponse.json({ ok: true });
    }

    if (action === 'saveResult' || action === 'submitResult') {
      const resultPayload: ResultPayload = {
        student_id: payload.student_id,
        exam_session_id: payload.exam_session_id,
        score_eo: toNumber(payload.score_eo),
        score_ee: toNumber(payload.score_ee),
        score_co: toNumber(payload.score_co),
        score_ce: toNumber(payload.score_ce),
        score_langue: toNumber(payload.score_langue),
      };
      const { data: session } = await supabase
        .from('exam_sessions')
        .select('pass_threshold')
        .eq('id', resultPayload.exam_session_id)
        .maybeSingle();
      const calculated = calculateResult(resultPayload, Number(session?.pass_threshold ?? 60));
      const submitted = action === 'submitResult';

      const { error } = await supabase
        .from('student_results')
        .upsert(
          {
            ...resultPayload,
            school_id: school.id,
            ...calculated,
            submitted,
            submitted_at: submitted ? new Date().toISOString() : null,
            validation_status: submitted ? 'submitted' : 'draft',
            validated_by_admin: false,
            admin_feedback: null,
          },
          { onConflict: 'student_id,exam_session_id' }
        );
      if (error) throw error;
      return NextResponse.json({ ok: true, submitted });
    }

    if (action === 'downloadPaper') {
      const examId = String(payload.exam_id ?? '');
      const competency = String(payload.competency ?? '') as Competency;
      if (!COMPETENCIES.includes(competency)) return jsonError('Compétence invalide.');

      const { count, error: countError } = await supabase
        .from('student_enrollments')
        .select('id, students!inner(school_id)', { count: 'exact', head: true })
        .eq('exam_session_id', examId)
        .eq('active', true)
        .eq('students.school_id', school.id);
      if (countError) throw countError;
      if (!count) return jsonError("Aucun élève de votre école n'est inscrit à cette session.", 403);

      const { data: paper, error: paperError } = await supabase
        .from('exam_papers')
        .select('file_path')
        .eq('exam_session_id', examId)
        .eq('competency', competency)
        .maybeSingle();
      if (paperError || !paper) throw paperError ?? new Error('Sujet indisponible.');

      const { data: signed, error: signedError } = await supabase.storage
        .from('exam-papers')
        .createSignedUrl(paper.file_path, 10 * 60);
      if (signedError || !signed?.signedUrl) throw signedError ?? new Error('Lien indisponible.');

      await supabase.from('exam_downloads').insert({
        school_id: school.id,
        exam_id: examId,
        competency,
      });

      return NextResponse.json({ ok: true, url: signed.signedUrl });
    }

    if (action === 'generateCertificate') {
      const certificate = await ensureCertificate(supabase, school, payload.result_id);
      const url = certificate.pdf_url
        ? supabase.storage.from('certificates').getPublicUrl(certificate.pdf_url).data.publicUrl
        : null;
      return NextResponse.json({ ok: true, certificate, url });
    }

    if (action === 'generateCertificatesZip') {
      const { data: results, error } = await supabase
        .from('student_results')
        .select('id')
        .eq('school_id', school.id)
        .eq('validated_by_admin', true)
        .eq('overall_pass', true);
      if (error) throw error;

      const zip = new JSZip();
      for (const result of results ?? []) {
        const certificate = await ensureCertificate(supabase, school, result.id);
        if (!certificate?.pdf_url) continue;
        const publicUrl = supabase.storage.from('certificates').getPublicUrl(certificate.pdf_url).data.publicUrl;
        const response = await fetch(publicUrl);
        if (!response.ok) continue;
        zip.file(`${certificate.certificate_number ?? certificate.id}.pdf`, await response.arrayBuffer());
      }

      const content = await zip.generateAsync({ type: 'uint8array' });
      const path = `${school.id}/certificats-${Date.now()}.zip`;
      const { error: uploadError } = await supabase.storage
        .from('certificates')
        .upload(path, content, { contentType: 'application/zip', upsert: true });
      if (uploadError) throw uploadError;
      const url = supabase.storage.from('certificates').getPublicUrl(path).data.publicUrl;
      return NextResponse.json({ ok: true, url });
    }

    return jsonError('Action inconnue.', 404);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Action impossible.';
    return jsonError(message, 500);
  }
}
