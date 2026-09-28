import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createAdminClient } from '@/lib/supabase/admin'
import { promoteProfileAfterEmailConfirmation } from '@/lib/ensure-profile'

/**
 * Called by the "email confirmed" page when the session arrives in the browser
 * (link that ends with #access_token). Moves the profile to admin review.
 * Never activates the account.
 */
export async function POST() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user?.id || !user.email_confirmed_at) {
    return NextResponse.json({ ok: false }, { status: 401 })
  }

  try {
    const admin = createAdminClient()
    await promoteProfileAfterEmailConfirmation(admin, user.id, user.email_confirmed_at)
  } catch (err) {
    console.error('[sync-email-confirmation]', err)
    return NextResponse.json({ ok: false }, { status: 500 })
  }

  return NextResponse.json({ ok: true })
}
