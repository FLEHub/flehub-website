import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { getProfileForUser } from '@/lib/supabase/get-profile';

export default async function DashboardPage() {
  const supabase = await createClient();

  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser();

  if (userError || !user) {
    redirect('/login');
  }

  const { profile } = await getProfileForUser(user.id);

  if (!profile) {
    redirect('/login?reason=profile_missing');
  }

  if (profile.status === 'pending') {
    redirect('/login?pending=true');
  }

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
