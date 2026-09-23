import { NextRequest, NextResponse } from 'next/server'
import type { EmailOtpType } from '@supabase/supabase-js'
import { createClient } from '@/lib/supabase/server'

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
  const confirmed = new URL('/auth/confirmed', url.origin)
  const failed = new URL('/login', url.origin)
  failed.searchParams.set('reason', 'pending_email_confirmation')

  const supabase = await createClient()

  if (tokenHash && type && OTP_TYPES.has(type as EmailOtpType)) {
    const { error } = await supabase.auth.verifyOtp({
      token_hash: tokenHash,
      type: type as EmailOtpType,
    })
    if (error) {
      console.error('[auth/confirm] verifyOtp', error.message)
      return NextResponse.redirect(failed)
    }
  } else if (code) {
    const { error } = await supabase.auth.exchangeCodeForSession(code)
    if (error) {
      console.error('[auth/confirm] exchangeCode', error.message)
      return NextResponse.redirect(failed)
    }
  } else {
    return NextResponse.redirect(confirmed)
  }

  await supabase.auth.signOut()
  return NextResponse.redirect(confirmed)
}
