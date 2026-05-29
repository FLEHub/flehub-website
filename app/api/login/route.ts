import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { createClient as createSupabaseClient } from '@supabase/supabase-js';

export async function POST(request: NextRequest) {
  const { email, password } = await request.json();

  if (!email?.trim()) {
    return NextResponse.json({ error: 'Veuillez saisir votre adresse e-mail.' }, { status: 400 });
  }
  if (!password) {
    return NextResponse.json({ error: 'Veuillez saisir votre mot de passe.' }, { status: 400 });
  }

  const supabase = await createClient();

  const { data, error } = await supabase.auth.signInWithPassword({
    email: email.trim().toLowerCase(),
    password,
  });

  if (error) {
    if (error.message.includes('Invalid login credentials')) {
      return NextResponse.json(
        { error: 'Email ou mot de passe incorrect. Veuillez réessayer.' },
        { status: 401 }
      );
    }
    return NextResponse.json({ error: error.message }, { status: 401 });
  }

  if (!data.user || !data.session) {
    return NextResponse.json(
      { error: 'Une erreur inattendue est survenue. Veuillez réessayer.' },
      { status: 500 }
    );
  }

  // Utiliser le token d'accès pour contourner le problème RLS dans la même requête
  const authedSupabase = createSupabaseClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      global: {
        headers: { Authorization: `Bearer ${data.session.access_token}` },
      },
    }
  );

  const { data: profile, error: profileError } = await authedSupabase
    .from('profiles')
    .select('role, status')
    .eq('id', data.user.id)
    .maybeSingle();

  if (profileError || !profile) {
    await supabase.auth.signOut();
    return NextResponse.json(
      { error: "Profil introuvable. Veuillez contacter l'administrateur." },
      { status: 403 }
    );
  }

  if (profile.status === 'pending') {
    await supabase.auth.signOut();
    return NextResponse.json({ pending: true }, { status: 200 });
  }

  if (profile.status === 'suspended' || profile.status === 'rejected') {
    await supabase.auth.signOut();
    return NextResponse.json(
      { error: "Votre compte est inactif. Veuillez contacter l'administrateur." },
      { status: 403 }
    );
  }

  const roleRedirects: Record<string, string> = {
    admin: '/dashboard/admin',
    school: '/dashboard/school',
    teacher: '/dashboard/teacher',
    learner: '/dashboard/learner',
  };

  return NextResponse.json(
    { redirect: roleRedirects[profile.role] ?? '/dashboard' },
    { status: 200 }
  );
}
