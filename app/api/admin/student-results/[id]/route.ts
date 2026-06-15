import { NextRequest, NextResponse } from 'next/server';
import { jsonError, requireAdmin, SchoolApiError } from '@/lib/school/server';

export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { supabase } = await requireAdmin();
    const body = await request.json();
    const action = body.action === 'reject' ? 'reject' : body.action === 'validate' ? 'validate' : null;
    if (!action) throw new SchoolApiError('Action invalide.', 400);

    const payload =
      action === 'validate'
        ? {
            status: 'validated',
            submitted: true,
            validated_by_admin: true,
            validated_at: new Date().toISOString(),
            admin_feedback: null,
            updated_at: new Date().toISOString(),
          }
        : {
            status: 'rejected',
            submitted: false,
            validated_by_admin: false,
            admin_feedback: String(body.admin_feedback ?? 'Corrections demandées.'),
            updated_at: new Date().toISOString(),
          };

    const { error } = await supabase.from('student_results').update(payload).eq('id', params.id);
    if (error) throw error;

    return NextResponse.json({ success: true });
  } catch (error) {
    return jsonError(error);
  }
}
