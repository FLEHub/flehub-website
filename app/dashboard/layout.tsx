export const dynamic = 'force-dynamic';

import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { Sidebar } from '@/components/dashboard/sidebar'
import { Header } from '@/components/dashboard/header'

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

  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select('full_name, email, role, status')
    .eq('id', user.id)
    .maybeSingle()

  if (profileError || !profile) {
    redirect('/login')
  }

  // Block suspended/rejected users
  if (profile.status === 'suspended' || profile.status === 'rejected') {
    redirect('/login?reason=account_inactive')
  }

  const safeProfile = {
    full_name: profile.full_name ?? '',
    email: profile.email ?? user.email ?? '',
    role: (profile.role as 'admin' | 'school' | 'teacher' | 'learner') ?? 'learner',
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Sidebar */}
      <Sidebar role={safeProfile.role} profile={safeProfile} />

      {/* Main area */}
      <div className="lg:ml-60 flex flex-col min-h-screen transition-all duration-200">
        {/* Top header */}
        <Header title="" profile={safeProfile} />

        {/* Page content */}
        <main className="flex-1 pt-16">
          {children}
        </main>
      </div>
    </div>
  )
}
