import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient } from '@/lib/supabase/admin'
import { requireActiveAdmin } from '@/lib/require-admin'
import {
  listPendingValidations,
  rejectPendingAccount,
  validatePendingAccount,
} from '@/lib/account-validation'

const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i

export async function GET() {
  const adminUser = await requireActiveAdmin()
  if (!adminUser) {
    return NextResponse.json({ error: 'Accès réservé aux administrateurs.' }, { status: 403 })
  }

  let admin: ReturnType<typeof createAdminClient>
  try {
    admin = createAdminClient()
  } catch {
    return NextResponse.json({ error: 'Configuration serveur incomplète.' }, { status: 500 })
  }

  const result = await listPendingValidations(admin)
  if (result.error) {
    return NextResponse.json({ error: result.error }, { status: 500 })
  }

  return NextResponse.json({ accounts: result.rows })
}

export async function POST(request: NextRequest) {
  const adminUser = await requireActiveAdmin()
  if (!adminUser) {
    return NextResponse.json({ error: 'Accès réservé aux administrateurs.' }, { status: 403 })
  }

  let body: { userId?: string; action?: string; rejectionReason?: string }
  try {
    body = await request.json()
  } catch {
    return NextResponse.json({ error: 'Requête invalide.' }, { status: 400 })
  }

  const userId = body.userId?.trim() ?? ''
  if (!UUID_RE.test(userId)) {
    return NextResponse.json({ error: 'Compte invalide.' }, { status: 400 })
  }
  if (body.action !== 'validate' && body.action !== 'reject') {
    return NextResponse.json({ error: 'Action invalide.' }, { status: 400 })
  }

  const reason = body.rejectionReason?.trim() ?? ''
  if (reason.length > 500) {
    return NextResponse.json({ error: 'Le motif ne peut pas dépasser 500 caractères.' }, { status: 400 })
  }

  let admin: ReturnType<typeof createAdminClient>
  try {
    admin = createAdminClient()
  } catch {
    return NextResponse.json({ error: 'Configuration serveur incomplète.' }, { status: 500 })
  }

  const result =
    body.action === 'validate'
      ? await validatePendingAccount(admin, { userId, adminId: adminUser.id })
      : await rejectPendingAccount(admin, {
          userId,
          adminId: adminUser.id,
          reason,
        })

  if (!result.ok) {
    return NextResponse.json({ error: result.error }, { status: 409 })
  }

  return NextResponse.json({
    ok: true,
    emailSent: result.emailSent,
    emailError: result.emailError ?? null,
  })
}
