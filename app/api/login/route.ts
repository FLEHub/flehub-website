import { NextRequest, NextResponse } from 'next/server';
import { AUTH_RATE_LIMIT_MESSAGE, isAuthRateLimitError } from '@/lib/auth-errors';
import { createClient } from '@/lib/supabase/server';
import { createClient as createSupabaseClient } from '@supabase/supabase-js';

export async function POST(request: NextRequest) {
  let body: unknown;

  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: 'Requête invalide.' }, { status: 400 });
  }

  if (!body || typeof body !== 'object') {
    return NextResponse.json({ error: 'Requête invalide.' }, { status: 400 });
  }

  const { email, password } = body as { email?: string; password?: string };

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
    if (isAuthRateLimitError(error)) {
      return NextResponse.json({ error: AUTH_RATE_LIMIT_MESSAGE }, { status: 429 });
    }
    if (error.message.includes('Invalid login credentials')) {
      return NextResponse.json(
        { error: 'Email ou mot de passe incorrect. Veuillez réessayer.' },
        { status: 401 }
      );
    }
    return NextResponse.json({ error: error.message }, { status: 401 });
  }

  if (!data.user) {
    return NextResponse.json(
      { error: 'Une erreur inattendue est survenue. Veuillez réessayer.' },
      { status: 500 }
    );
  }

  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!serviceRoleKey) {
    await supabase.auth.signOut();
    return NextResponse.json(
      { error: 'Configuration serveur incomplète.' },
      { status: 500 }
    );
  }

  const adminSupabase = createSupabaseClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    serviceRoleKey,
    {
      auth: { autoRefreshToken: false, persistSession: false },
    }
  );

  const { data: profile, error: profileError } = await adminSupabase
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

export function GET() {
  return NextResponse.json(
    { error: 'Méthode non autorisée. Utilisez POST pour vous connecter.' },
    { status: 405, headers: { Allow: 'POST' } }
  );
}
