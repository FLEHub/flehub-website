export const dynamic = 'force-dynamic';

import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { getProfileForUser } from '@/lib/supabase/get-profile'
import { Sidebar } from '@/components/dashboard/sidebar'
import { DashboardHeader } from '@/components/dashboard/dashboard-header'
import { ProfileSetupError } from '@/components/dashboard/profile-setup-error'
import { Toaster } from '@/components/ui/toaster'

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const supabase = await createClient()

  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser()

  if (userError || !user) {
    redirect('/login')
  }

  const { profile, error: profileError } = await getProfileForUser(user.id)

  if (!profile) {
    return (
      <ProfileSetupError
        title="Profile not available"
        message={
          profileError
            ? `We could not load your profile (${profileError}). Please contact an administrator or sign in again.`
            : 'Your account profile has not been set up yet. Please contact an administrator.'
        }
      />
    )
  }

  if (profile.status === 'pending') {
    redirect('/login?pending=true')
  }

  if (profile.status === 'suspended' || profile.status === 'rejected') {
    redirect('/login?reason=account_inactive')
  }

  const safeProfile = {
    full_name: profile.full_name ?? '',
    email: profile.email ?? user.email ?? '',
    role: profile.role ?? 'learner',
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Sidebar role={safeProfile.role} profile={safeProfile} />
      <div className="lg:ml-60 flex flex-col min-h-screen transition-all duration-200">
        <DashboardHeader profile={safeProfile} />
        <main className="flex-1 pt-16">{children}</main>
      </div>
      <Toaster />
    </div>
  )
}
