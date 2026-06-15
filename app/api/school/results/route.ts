import { NextRequest, NextResponse } from 'next/server';
import { calculateOverallPass, COMPETENCIES, type ScoreKey } from '@/lib/school/constants';
import { jsonError, requireSchool, SchoolApiError } from '@/lib/school/server';

function scoreFrom(body: any, key: ScoreKey) {
  const value = Number(body[key]);
  if (!Number.isFinite(value) || value < 0 || value > 100) {
    throw new SchoolApiError('Chaque score doit être compris entre 0 et 100.', 400);
  }
  return value;
}

export async function POST(request: NextRequest) {
  try {
    const { supabase, school } = await requireSchool({ approved: true });
    const body = await request.json();
    const studentId = String(body.student_id ?? '');
    const examSessionId = String(body.exam_session_id ?? '');
    const action = body.action === 'submit' ? 'submit' : 'draft';

    if (!studentId || !examSessionId) {
      throw new SchoolApiError('Élève et session examen sont obligatoires.', 400);
    }

    const scores = Object.fromEntries(
      COMPETENCIES.map((competency) => [competency.scoreKey, scoreFrom(body, competency.scoreKey)])
    ) as Record<ScoreKey, number>;

    const { data: enrollment } = await supabase
      .from('student_enrollments')
      .select('id, cefr_level')
      .eq('student_id', studentId)
      .eq('exam_session_id', examSessionId)
      .eq('status', 'active')
      .maybeSingle();
    if (!enrollment) {
      throw new SchoolApiError("Cet élève n'est pas inscrit à cette session.", 400);
    }

    const { data: session, error: sessionError } = await supabase
      .from('exam_sessions')
      .select('id, pass_threshold, competency_threshold')
      .eq('id', examSessionId)
      .maybeSingle();
    if (sessionError) throw sessionError;
    if (!session) throw new SchoolApiError('Session introuvable.', 404);

    const { data: existing } = await supabase
      .from('student_results')
      .select('id, status')
      .eq('school_id', school.id)
      .eq('student_id', studentId)
      .eq('exam_session_id', examSessionId)
      .maybeSingle();

    if (existing && !['draft', 'rejected'].includes(existing.status)) {
      throw new SchoolApiError('Ce résultat est déjà soumis et verrouillé.', 409);
    }

    const { passed } = calculateOverallPass(
      scores,
      Number(session.pass_threshold ?? 60),
      Number(session.competency_threshold ?? 0)
    );

    const payload = {
      student_id: studentId,
      school_id: school.id,
      exam_session_id: examSessionId,
      ...scores,
      overall_pass: passed,
      submitted: action === 'submit',
      status: action === 'submit' ? 'submitted' : 'draft',
      submitted_at: action === 'submit' ? new Date().toISOString() : null,
      validated_by_admin: false,
      updated_at: new Date().toISOString(),
    };

    const query = existing
      ? supabase.from('student_results').update(payload).eq('id', existing.id)
      : supabase.from('student_results').insert(payload);
    const { error } = await query;
    if (error) throw error;

    return NextResponse.json({ success: true, passed, status: payload.status });
  } catch (error) {
    return jsonError(error);
  }
}
