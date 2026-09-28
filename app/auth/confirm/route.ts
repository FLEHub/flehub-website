import { NextRequest, NextResponse } from 'next/server'
import type { EmailOtpType } from '@supabase/supabase-js'
import { createClient } from '@/lib/supabase/server'
import { createAdminClient } from '@/lib/supabase/admin'
import { promoteProfileAfterEmailConfirmation } from '@/lib/ensure-profile'
import { appUrl } from '@/lib/site-url'

const OTP_TYPES = new Set<EmailOtpType>(['signup', 'email', 'invite', 'recovery', 'magiclink', 'email_change'])

/**
 * Lands the Supabase confirmation link (token_hash or PKCE code),
 * then drops the session: the account still needs an admin.
 */
export async function GET(request: NextRequest) {
  const url = new URL(request.url)
  const tokenHash = url.searchParams.get('token_hash')
  const type = url.searchParams.get('type')
  const code = url.searchParams.get('code')
  const confirmed = appUrl('/auth/confirmed', url.origin)
  const failed = appUrl('/login', url.origin)
  failed.searchParams.set('reason', 'pending_email_confirmation')

  const supabase = await createClient()
  let verified = false

  if (tokenHash && type && OTP_TYPES.has(type as EmailOtpType)) {
    const { error } = await supabase.auth.verifyOtp({
      token_hash: tokenHash,
      type: type as EmailOtpType,
    })
    if (error) {
      console.error('[auth/confirm] verifyOtp', error.message)
      return NextResponse.redirect(failed)
    }
    verified = true
  } else if (code) {
    const { error } = await supabase.auth.exchangeCodeForSession(code)
    if (error) {
      console.error('[auth/confirm] exchangeCode', error.message)
      return NextResponse.redirect(failed)
    }
    verified = true
  }

  if (!verified) {
    return NextResponse.redirect(failed)
  }

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (user?.id) {
    try {
      const admin = createAdminClient()
      await promoteProfileAfterEmailConfirmation(admin, user.id, user.email_confirmed_at)
    } catch (err) {
      console.error('[auth/confirm] promote profile', err)
    }
  }

  await supabase.auth.signOut()
  return NextResponse.redirect(confirmed)
}
