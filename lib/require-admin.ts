import { createClient } from '@/lib/supabase/server'
import { isActiveAccountStatus } from '@/lib/account-status'

/** Signed-in admin with an active account, or null. */
export async function requireActiveAdmin(): Promise<{ id: string } | null> {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return null

  const { data: profile } = await supabase
    .from('profiles')
    .select('role, status')
    .eq('id', user.id)
    .maybeSingle()

  if (!profile || profile.role !== 'admin' || !isActiveAccountStatus(profile.status)) {
    return null
  }

  return { id: user.id }
}
