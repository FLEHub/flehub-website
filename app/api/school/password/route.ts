import { NextRequest, NextResponse } from 'next/server';
import { jsonError, requireSchool, SchoolApiError } from '@/lib/school/server';

export async function POST(request: NextRequest) {
  try {
    const { supabase } = await requireSchool({ approved: true });
    const body = await request.json();
    const password = String(body.password ?? '');
    if (password.length < 8) {
      throw new SchoolApiError('Le mot de passe doit contenir au moins 8 caractères.', 400);
    }

    const { error } = await supabase.auth.updateUser({ password });
    if (error) throw error;

    return NextResponse.json({ success: true });
  } catch (error) {
    return jsonError(error);
  }
}
