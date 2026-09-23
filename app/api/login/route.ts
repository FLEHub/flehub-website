import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { createClient as createSupabaseClient } from '@supabase/supabase-js';
import { isActiveAccountStatus, loginBlockForStatus } from '@/lib/account-status';

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
    const message = error.message.toLowerCase();
    if (message.includes('email not confirmed') || message.includes('email_not_confirmed')) {
      const block = loginBlockForStatus('pending_email_confirmation');
      return NextResponse.json(
        { error: block?.message, blocked: 'pending_email_confirmation' },
        { status: 403 }
      );
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

  // Utiliser la service role key pour bypasser RLS sur la lecture du profil
  const adminSupabase = createSupabaseClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  );

  const { data: profile, error: profileError } = await adminSupabase
    .from('profiles')
    .select('role, status, rejection_reason')
    .eq('id', data.user.id)
    .maybeSingle();

  if (profileError || !profile) {
    await supabase.auth.signOut();
    return NextResponse.json(
      {
        error:
          "Votre compte existe mais le profil n'a pas été créé. Réessayez l'inscription avec la même adresse e-mail, ou contactez l'administrateur.",
      },
      { status: 403 }
    );
  }

  if (!isActiveAccountStatus(profile.status)) {
    await supabase.auth.signOut();
    const block = loginBlockForStatus(profile.status, profile.rejection_reason);
    return NextResponse.json(
      {
        error: block?.message,
        blocked: profile.status,
        pending:
          profile.status === 'pending_admin_validation' || profile.status === 'pending',
      },
      { status: 403 }
    );
  }

  const roleRedirects: Record<string, string> = {
    admin: '/dashboard/admin',
    school: '/dashboard/school',
    teacher: '/dashboard/teacher',
    learner: '/dashboard/learner',
    journalist: '/dashboard/journalist',
    creator: '/dashboard/creator',
  };

  return NextResponse.json(
    { redirect: roleRedirects[profile.role] ?? '/dashboard' },
    { status: 200 }
  );
}
