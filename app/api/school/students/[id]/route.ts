import { NextRequest, NextResponse } from 'next/server';
import { jsonError, requireSchool, SchoolApiError } from '@/lib/school/server';

function studentPatch(body: any) {
  const first_name = String(body.first_name ?? '').trim();
  const last_name = String(body.last_name ?? '').trim();
  const date_of_birth = body.date_of_birth ? String(body.date_of_birth) : null;
  const gender = String(body.gender ?? '').trim().toUpperCase();
  const grade = String(body.grade ?? '').trim();

  if (!first_name || !last_name || !gender || !grade) {
    throw new SchoolApiError('Prénom, nom, genre et classe sont obligatoires.', 400);
  }
  if (!['M', 'F'].includes(gender)) {
    throw new SchoolApiError('Le genre doit être M ou F.', 400);
  }

  return { first_name, last_name, date_of_birth, gender, grade, updated_at: new Date().toISOString() };
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { supabase, school } = await requireSchool({ approved: true });
    const { error } = await supabase
      .from('students')
      .update(studentPatch(await request.json()))
      .eq('id', params.id)
      .eq('school_id', school.id);

    if (error) throw error;
    return NextResponse.json({ success: true });
  } catch (error) {
    return jsonError(error);
  }
}

export async function DELETE(
  _request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { supabase, school } = await requireSchool({ approved: true });
    const { error } = await supabase
      .from('students')
      .delete()
      .eq('id', params.id)
      .eq('school_id', school.id);

    if (error) throw error;
    return NextResponse.json({ success: true });
  } catch (error) {
    return jsonError(error);
  }
}
