import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { AdminSettingsForm } from './settings-form'

export default async function AdminSettingsPage() {
  const supabase = await createClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { data: adminProfile } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle()
  if (adminProfile?.role !== 'admin') redirect('/dashboard')

  const { data: settings } = await supabase
    .from('org_settings')
    .select('*')
    .limit(1)
    .maybeSingle()

  return (
    <div className="p-6 space-y-6 max-w-3xl">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Organization Settings</h1>
        <p className="text-sm text-gray-500 mt-1">
          Manage FLEHub branding and contact information used across certificates and documents.
        </p>
      </div>
      <AdminSettingsForm initialSettings={settings} />
    </div>
  )
}
