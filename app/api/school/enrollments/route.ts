import { NextRequest, NextResponse } from 'next/server';
import { jsonError, requireSchool, SchoolApiError } from '@/lib/school/server';
import { normalizeCefrLevel } from '@/lib/school/constants';

export async function POST(request: NextRequest) {
  try {
    const { supabase, school } = await requireSchool({ approved: true });
    const body = await request.json();
    const studentId = String(body.student_id ?? '');
    const examSessionId = String(body.exam_session_id ?? '');
    const cefrLevel = normalizeCefrLevel(body.cefr_level);

    if (!studentId || !examSessionId || !cefrLevel) {
      throw new SchoolApiError('Élève, session et niveau CECRL sont requis.', 400);
    }

    const { data: student } = await supabase
      .from('students')
      .select('id')
      .eq('id', studentId)
      .eq('school_id', school.id)
      .maybeSingle();
    if (!student) throw new SchoolApiError('Élève introuvable.', 404);

    const { data: session } = await supabase
      .from('exam_sessions')
      .select('id, cefr_level')
      .eq('id', examSessionId)
      .maybeSingle();
    if (!session || session.cefr_level !== cefrLevel) {
      throw new SchoolApiError('La session ne correspond pas au niveau choisi.', 400);
    }

    const { error } = await supabase.from('student_enrollments').insert({
      student_id: studentId,
      exam_session_id: examSessionId,
      cefr_level: cefrLevel,
    });

    if (error) throw error;
    return NextResponse.json({ success: true });
  } catch (error) {
    return jsonError(error);
  }
}
