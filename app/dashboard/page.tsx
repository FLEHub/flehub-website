import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

export default async function DashboardPage() {
  const supabase = await createClient();

  // Get the authenticated user
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser();

  if (userError || !user) {
    redirect('/login');
  }

  // Fetch the user's profile to determine role
  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select('role, status')
    .eq('id', user.id)
    .maybeSingle();

  if (profileError || !profile) {
    redirect('/login');
  }

  // Redirect pending accounts back to login
  if (profile.status === 'pending') {
    redirect('/login?pending=true');
  }

  // Role-based redirect
  switch (profile.role) {
    case 'admin':
      redirect('/dashboard/admin');
    case 'school':
      redirect('/dashboard/school');
    case 'teacher':
      redirect('/dashboard/teacher');
    case 'learner':
      redirect('/dashboard/learner');
    default:
      redirect('/login');
  }
}
