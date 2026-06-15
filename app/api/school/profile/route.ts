import { NextRequest, NextResponse } from 'next/server';
import { jsonError, requireSchool } from '@/lib/school/server';

const SCHOOL_TYPES = ['primary', 'secondary', 'both'];

export async function PATCH(request: NextRequest) {
  try {
    const { supabase, profile, school } = await requireSchool({ approved: true });
    const body = await request.json();

    const name = String(body.name ?? '').trim();
    const address = String(body.address ?? '').trim();
    const district = String(body.district ?? '').trim();
    const type = String(body.type ?? '').trim();
    const directorName = String(body.director_name ?? '').trim();
    const email = String(body.email ?? '').trim().toLowerCase();
    const phone = String(body.phone ?? '').trim();

    if (!name || !address || !district || !directorName || !email || !phone) {
      return NextResponse.json({ error: 'Tous les champs obligatoires doivent être renseignés.' }, { status: 400 });
    }
    if (!SCHOOL_TYPES.includes(type)) {
      return NextResponse.json({ error: "Type d'établissement invalide." }, { status: 400 });
    }

    const { error: schoolError } = await supabase
      .from('schools')
      .update({
        name,
        school_name: name,
        address,
        district,
        type,
        director_name: directorName,
        email,
        phone,
        updated_at: new Date().toISOString(),
      })
      .eq('id', school.id);

    if (schoolError) throw schoolError;

    const { error: profileError } = await supabase
      .from('profiles')
      .update({ full_name: profile.full_name, email, phone })
      .eq('id', profile.id);

    if (profileError) throw profileError;

    return NextResponse.json({ success: true });
  } catch (error) {
    return jsonError(error);
  }
}
