import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { getProfileForUser } from '@/lib/supabase/get-profile';

type Competency = 'EO' | 'EE' | 'CO' | 'CE' | 'LANGUE';
const COMPETENCIES: Competency[] = ['EO', 'EE', 'CO', 'CE', 'LANGUE'];

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

  const [sessions, papers] = await Promise.all([
    supabase
      .from('exam_sessions')
      .select('id, title, cefr_level, exam_date, status')
      .order('exam_date', { ascending: false }),
    supabase.from('exam_papers').select('*').order('created_at', { ascending: false }),
  ]);

  if (sessions.error) return NextResponse.json({ error: sessions.error.message }, { status: 500 });
  if (papers.error) return NextResponse.json({ error: papers.error.message }, { status: 500 });

  return NextResponse.json({ sessions: sessions.data ?? [], papers: papers.data ?? [] });
}

export async function POST(request: Request) {
  const context = await requireAdmin();
  if ('error' in context) return context.error;
  const { supabase, user } = context;
  const formData = await request.formData();
  const examSessionId = String(formData.get('exam_session_id') ?? '');
  const competency = String(formData.get('competency') ?? '') as Competency;
  const file = formData.get('file');

  if (!examSessionId || !COMPETENCIES.includes(competency)) {
    return NextResponse.json({ error: 'Session ou compétence invalide.' }, { status: 400 });
  }
  if (!(file instanceof File) || file.type !== 'application/pdf') {
    return NextResponse.json({ error: 'Le sujet doit être un PDF.' }, { status: 400 });
  }

  const path = `${examSessionId}/${competency}-${Date.now()}.pdf`;
  const { error: uploadError } = await supabase.storage
    .from('exam-papers')
    .upload(path, file, { contentType: 'application/pdf', upsert: true });
  if (uploadError) return NextResponse.json({ error: uploadError.message }, { status: 500 });

  const { error } = await supabase.from('exam_papers').upsert(
    {
      exam_session_id: examSessionId,
      competency,
      file_path: path,
      uploaded_by: user.id,
    },
    { onConflict: 'exam_session_id,competency' }
  );
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });

  return NextResponse.json({ ok: true });
}
