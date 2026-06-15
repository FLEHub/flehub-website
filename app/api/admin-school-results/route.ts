import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { getProfileForUser } from '@/lib/supabase/get-profile';

async function requireAdmin() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: NextResponse.json({ error: 'Non authentifié.' }, { status: 401 }) };
  const { profile } = await getProfileForUser(user.id);
  if (!profile || profile.role !== 'admin') {
    return { error: NextResponse.json({ error: 'Accès admin requis.' }, { status: 403 }) };
  }
  return { supabase, user };
}

export async function GET() {
  const context = await requireAdmin();
  if ('error' in context) return context.error;

  const { supabase } = context;
  const [results, students, schools, sessions] = await Promise.all([
    supabase.from('student_results').select('*').order('updated_at', { ascending: false }),
    supabase.from('students').select('*'),
    supabase.from('schools').select('id, name, school_name, district'),
    supabase.from('exam_sessions').select('id, title, cefr_level, exam_date'),
  ]);

  for (const response of [results, students, schools, sessions]) {
    if (response.error) {
      return NextResponse.json({ error: response.error.message }, { status: 500 });
    }
  }

  return NextResponse.json({
    results: results.data ?? [],
    students: students.data ?? [],
    schools: schools.data ?? [],
    sessions: sessions.data ?? [],
  });
}

export async function POST(request: Request) {
  const context = await requireAdmin();
  if ('error' in context) return context.error;
  const { supabase, user } = context;
  const body = await request.json();

  if (!['validate', 'reject'].includes(body.action)) {
    return NextResponse.json({ error: 'Action inconnue.' }, { status: 400 });
  }

  const status = body.action === 'validate' ? 'validated' : 'rejected';
  const { error } = await supabase
    .from('student_results')
    .update({
      validated_by_admin: body.action === 'validate',
      validation_status: status,
      admin_feedback: body.action === 'reject' ? String(body.feedback ?? '') : null,
      validated_by: user.id,
      validated_at: new Date().toISOString(),
    })
    .eq('id', body.result_id)
    .eq('submitted', true);

  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ ok: true });
}
