import { NextRequest, NextResponse } from 'next/server';
import { normalizeCompetency, sanitizeFileName } from '@/lib/school/constants';
import { jsonError, requireAdmin, SchoolApiError } from '@/lib/school/server';

export async function POST(request: NextRequest) {
  try {
    const { supabase, profile } = await requireAdmin();
    const form = await request.formData();
    const examSessionId = String(form.get('exam_session_id') ?? '');
    const competency = normalizeCompetency(form.get('competency'));
    const file = form.get('file');

    if (!examSessionId || !competency) {
      throw new SchoolApiError('Session examen et compétence sont obligatoires.', 400);
    }
    if (!(file instanceof File) || file.type !== 'application/pdf') {
      throw new SchoolApiError('Le sujet officiel doit être un fichier PDF.', 400);
    }

    const path = `${examSessionId}/${competency}-${Date.now()}-${sanitizeFileName(file.name || 'sujet.pdf')}`;
    const { error: uploadError } = await supabase.storage.from('exam-papers').upload(path, file, {
      contentType: 'application/pdf',
      upsert: true,
    });
    if (uploadError) throw uploadError;

    const { error } = await supabase.from('exam_papers').upsert(
      {
        exam_session_id: examSessionId,
        competency,
        file_path: path,
        uploaded_by: profile.id,
      },
      { onConflict: 'exam_session_id,competency' }
    );
    if (error) throw error;

    return NextResponse.json({ success: true });
  } catch (error) {
    return jsonError(error);
  }
}
