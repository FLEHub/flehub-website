import { NextRequest, NextResponse } from 'next/server';
import { jsonError, requireSchool } from '@/lib/school/server';
import { normalizeCefrLevel } from '@/lib/school/constants';

function cleanStudent(body: any) {
  const first_name = String(body.first_name ?? '').trim();
  const last_name = String(body.last_name ?? '').trim();
  const date_of_birth = body.date_of_birth ? String(body.date_of_birth) : null;
  const gender = String(body.gender ?? '').trim().toUpperCase();
  const grade = String(body.grade ?? '').trim();
  const cefr_level = normalizeCefrLevel(body.cefr_level);
  const exam_session_id = body.exam_session_id ? String(body.exam_session_id) : null;

  if (!first_name || !last_name || !gender || !grade || !cefr_level) {
    throw new Error('Prénom, nom, genre, classe et niveau CECRL sont obligatoires.');
  }
  if (!['M', 'F'].includes(gender)) {
    throw new Error('Le genre doit être M ou F.');
  }

  return { first_name, last_name, date_of_birth, gender, grade, cefr_level, exam_session_id };
}

export async function POST(request: NextRequest) {
  try {
    const { supabase, school } = await requireSchool({ approved: true });
    const payload = cleanStudent(await request.json());

    if (payload.exam_session_id) {
      const { data: session, error: sessionError } = await supabase
        .from('exam_sessions')
        .select('id, cefr_level, status')
        .eq('id', payload.exam_session_id)
        .maybeSingle();
      if (sessionError) throw sessionError;
      if (!session || session.cefr_level !== payload.cefr_level) {
        return NextResponse.json(
          { error: 'La session choisie ne correspond pas au niveau CECRL.' },
          { status: 400 }
        );
      }
    }

    const { data: student, error: studentError } = await supabase
      .from('students')
      .insert({
        school_id: school.id,
        first_name: payload.first_name,
        last_name: payload.last_name,
        date_of_birth: payload.date_of_birth,
        gender: payload.gender,
        grade: payload.grade,
      })
      .select('*')
      .single();

    if (studentError) throw studentError;

    if (payload.exam_session_id) {
      const { error: enrollmentError } = await supabase.from('student_enrollments').insert({
        student_id: student.id,
        exam_session_id: payload.exam_session_id,
        cefr_level: payload.cefr_level,
      });
      if (enrollmentError) throw enrollmentError;
    }

    return NextResponse.json({ success: true, student });
  } catch (error) {
    return jsonError(error);
  }
}
