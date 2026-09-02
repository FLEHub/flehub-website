export const dynamic = 'force-dynamic'

import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { Sidebar } from '@/components/dashboard/sidebar'
import { Header } from '@/components/dashboard/header'
import { MobileViewport } from '@/components/dashboard/mobile-viewport'
import { normalizeOrgBranding } from '@/lib/org-branding'

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

  const { data: orgSettings } = await supabase
    .from('org_settings')
    .select('org_name, org_short_name, org_tagline')
    .limit(1)
    .maybeSingle()
  const branding = normalizeOrgBranding(orgSettings)

  const safeProfile = {
    full_name: profile.full_name ?? '',
    email: profile.email ?? user.email ?? '',
    role: (profile.role as 'admin' | 'school' | 'teacher' | 'learner' | 'journalist' | 'creator') ?? 'learner',
  }

  return (
    <div className="min-h-screen overflow-x-clip bg-gray-50">
      <MobileViewport />
      {/* Sidebar */}
      <Sidebar
        role={safeProfile.role}
        profile={safeProfile}
        orgShortName={branding.orgShortName}
        orgTagline={branding.orgTagline}
      />

      {/* Main area — full width on mobile (no persistent sidebar gutter) */}
      <div className="flex min-h-screen min-w-0 flex-col transition-all duration-200 lg:ml-60">
        {/* Top header */}
        <Header title="" profile={safeProfile} />

        {/* Page content */}
        <main className="min-w-0 flex-1 overflow-x-clip pt-16 pb-[var(--kb-inset,0px)]">
          {children}
        </main>
      </div>
    </div>
  )
}
