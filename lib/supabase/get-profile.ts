import { createClient } from '@/lib/supabase/server'
import { createServiceClient } from '@/lib/supabase/service'

export type DashboardProfile = {
  full_name: string
  email: string
  role: 'admin' | 'school' | 'teacher' | 'learner'
  status: 'pending' | 'approved' | 'rejected' | 'suspended'
}

export async function getProfileForUser(userId: string): Promise<{
  profile: DashboardProfile | null
  error: string | null
}> {
  const supabase = await createClient()

  const { data: profile, error } = await supabase
    .from('profiles')
    .select('full_name, email, role, status')
    .eq('id', userId)
    .maybeSingle()

  if (profile) {
    return { profile: profile as DashboardProfile, error: null }
  }

  if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
    return {
      profile: null,
      error: error?.message ?? 'Profile not found',
    }
  }

  try {
    const service = createServiceClient()
    const { data: serviceProfile, error: serviceError } = await service
      .from('profiles')
      .select('full_name, email, role, status')
      .eq('id', userId)
      .maybeSingle()

    if (serviceProfile) {
      return { profile: serviceProfile as DashboardProfile, error: null }
    }

    return {
      profile: null,
      error: serviceError?.message ?? error?.message ?? 'Profile not found',
    }
  } catch (serviceErr) {
    const message =
      serviceErr instanceof Error ? serviceErr.message : 'Failed to load profile'
    return { profile: null, error: message }
  }
}
