import { NextRequest, NextResponse } from 'next/server';
import { normalizeCompetency } from '@/lib/school/constants';
import { jsonError, requireSchool, SchoolApiError } from '@/lib/school/server';

export async function GET(
  _request: NextRequest,
  { params }: { params: { examId: string; competency: string } }
) {
  try {
    const { supabase, service, school } = await requireSchool({ approved: true });
    const competency = normalizeCompetency(params.competency);
    if (!competency) throw new SchoolApiError('Compétence invalide.', 400);

    const { data: eligible } = await supabase
      .from('student_enrollments')
      .select('id, students!inner(id, school_id)')
      .eq('exam_session_id', params.examId)
      .eq('status', 'active')
      .eq('students.school_id', school.id)
      .limit(1)
      .maybeSingle();

    if (!eligible) {
      throw new SchoolApiError("Téléchargement réservé aux écoles approuvées avec des élèves inscrits à cette session.", 403);
    }

    const paperClient = service ?? supabase;
    const { data: paper, error: paperError } = await paperClient
      .from('exam_papers')
      .select('file_path')
      .eq('exam_session_id', params.examId)
      .eq('competency', competency)
      .maybeSingle();

    if (paperError) throw paperError;
    if (!paper) throw new SchoolApiError("Le sujet officiel n'est pas encore disponible.", 404);

    await supabase.from('exam_downloads').insert({
      school_id: school.id,
      exam_id: params.examId,
      competency,
    });

    const { data: signed, error: signedError } = await paperClient.storage
      .from('exam-papers')
      .createSignedUrl(paper.file_path, 60 * 5);
    if (signedError || !signed?.signedUrl) throw signedError ?? new Error('URL signée indisponible.');

    return NextResponse.redirect(signed.signedUrl);
  } catch (error) {
    return jsonError(error);
  }
}
