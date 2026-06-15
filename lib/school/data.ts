import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { signedSchoolAssetUrl } from '@/lib/school/server';
import { COMPETENCIES, type ScoreKey } from '@/lib/school/constants';

export type SchoolData = Awaited<ReturnType<typeof getSchoolSpaceData>>;

export async function getSchoolSpaceData() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('profiles')
    .select('id, email, full_name, phone, role, status')
    .eq('id', user.id)
    .maybeSingle();

  if (!profile || profile.role !== 'school') redirect('/dashboard');
  if (profile.status === 'pending') redirect('/login?reason=account_pending');
  if (profile.status === 'rejected' || profile.status === 'suspended') {
    redirect('/login?reason=account_inactive');
  }

  const { data: school } = await supabase
    .from('schools')
    .select(
      'id, profile_id, school_name, name, address, district, province, sector, cell, village, type, director_name, email, phone, logo_url, signature_url, status, created_at'
    )
    .eq('profile_id', user.id)
    .maybeSingle();

  if (!school) redirect('/dashboard');

  const [
    studentsResponse,
    sessionsResponse,
    enrollmentsResponse,
    resultsResponse,
    papersResponse,
    downloadsResponse,
    certificatesResponse,
  ] = await Promise.all([
    supabase
      .from('students')
      .select('id, school_id, first_name, last_name, date_of_birth, gender, grade, created_at, updated_at')
      .eq('school_id', school.id)
      .order('last_name', { ascending: true }),
    supabase
      .from('exam_sessions')
      .select(
        'id, title, cefr_level, exam_date, registration_deadline, status, venue, pass_threshold, competency_threshold'
      )
      .order('exam_date', { ascending: false }),
    supabase
      .from('student_enrollments')
      .select(
        'id, student_id, exam_session_id, cefr_level, status, enrolled_at, students(id, first_name, last_name, grade, gender), exam_sessions(id, title, cefr_level, exam_date, status)'
      )
      .order('enrolled_at', { ascending: false }),
    supabase
      .from('student_results')
      .select(
        'id, student_id, school_id, exam_session_id, score_eo, score_ee, score_co, score_ce, score_langue, overall_pass, submitted, validated_by_admin, status, admin_feedback, submitted_at, validated_at, created_at, updated_at, students(id, first_name, last_name, grade, gender), exam_sessions(id, title, cefr_level, exam_date, status)'
      )
      .eq('school_id', school.id)
      .order('updated_at', { ascending: false }),
    supabase
      .from('exam_papers')
      .select('id, exam_session_id, competency, created_at'),
    supabase
      .from('exam_downloads')
      .select('id, school_id, exam_id, competency, downloaded_at')
      .eq('school_id', school.id)
      .order('downloaded_at', { ascending: false }),
    supabase
      .from('certificates')
      .select('id, student_id, school_id, level, issue_date, certificate_uuid, pdf_url, verified_url, created_at')
      .eq('school_id', school.id)
      .order('created_at', { ascending: false }),
  ]);

  const students = studentsResponse.data ?? [];
  const sessions = sessionsResponse.data ?? [];
  const enrollments = enrollmentsResponse.data ?? [];
  const results = resultsResponse.data ?? [];
  const certificates = certificatesResponse.data ?? [];

  const validatedPassingResults = results.filter(
    (result: any) => result.overall_pass && result.validated_by_admin
  );

  const passRate =
    results.length > 0
      ? Math.round((results.filter((result: any) => result.overall_pass).length / results.length) * 100)
      : 0;

  const competencyAverages = COMPETENCIES.map((competency) => {
    const values = results
      .map((result: any) => Number(result[competency.scoreKey as ScoreKey] ?? 0))
      .filter((score) => Number.isFinite(score));
    const average =
      values.length > 0
        ? Math.round((values.reduce((sum, score) => sum + score, 0) / values.length) * 10) / 10
        : 0;
    return { ...competency, average };
  });

  return {
    profile,
    school: {
      ...school,
      display_name: school.name ?? school.school_name,
      logo_signed_url: await signedSchoolAssetUrl(school.logo_url),
      signature_signed_url: await signedSchoolAssetUrl(school.signature_url),
    },
    students,
    sessions,
    enrollments,
    results,
    papers: papersResponse.data ?? [],
    downloads: downloadsResponse.data ?? [],
    certificates,
    metrics: {
      totalStudents: students.length,
      activeEnrollments: enrollments.filter((enrollment: any) => enrollment.status === 'active').length,
      pendingResults: results.filter((result: any) => result.status === 'draft' || result.status === 'rejected').length,
      submittedResults: results.filter((result: any) => result.status === 'submitted').length,
      validatedCertificates: certificates.length,
      eligibleCertificates: validatedPassingResults.length,
      passRate,
      competencyAverages,
    },
  };
}
