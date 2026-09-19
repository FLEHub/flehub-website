import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createAdminClient } from '@/lib/supabase/admin'
import { listAuthUsersWithoutProfiles } from '@/lib/find-auth-user'
import { ensureProfileAndRole, type AppRole } from '@/lib/ensure-profile'

const ROLES: AppRole[] = ['learner', 'teacher', 'school', 'admin', 'journalist', 'creator']

async function requireAdmin() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return null

  const { data: profile } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle()

  if (profile?.role !== 'admin') return null
  return user
}

function parseRole(value: unknown): AppRole | null {
  if (typeof value !== 'string') return null
  return ROLES.includes(value as AppRole) ? (value as AppRole) : null
}

/** List Auth users that have no matching profiles row. */
export async function GET() {
  const adminUser = await requireAdmin()
  if (!adminUser) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })
  }

  let admin: ReturnType<typeof createAdminClient>
  try {
    admin = createAdminClient()
  } catch (err) {
    console.error('[admin orphan-accounts] missing credentials', err)
    return NextResponse.json(
      { error: "Configuration serveur incomplète. Veuillez contacter l'administrateur." },
      { status: 500 }
    )
  }

  const { accounts, error } = await listAuthUsersWithoutProfiles(admin)
  if (error) {
    return NextResponse.json({ error: `Impossible de lister les comptes : ${error}` }, { status: 500 })
  }

  return NextResponse.json({ accounts })
}

/** Create the missing profile (and role row) for an existing Auth user. */
export async function POST(request: NextRequest) {
  const adminUser = await requireAdmin()
  if (!adminUser) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })
  }

  let body: {
    userId?: string
    role?: string
    full_name?: string
    phone?: string
    school_name?: string
  }
  try {
    body = await request.json()
  } catch {
    return NextResponse.json({ error: 'Requête invalide.' }, { status: 400 })
  }

  const userId = String(body.userId ?? '').trim()
  if (!userId) {
    return NextResponse.json({ error: "L'identifiant du compte Auth est requis." }, { status: 400 })
  }

  let admin: ReturnType<typeof createAdminClient>
  try {
    admin = createAdminClient()
  } catch (err) {
    console.error('[admin orphan-accounts] missing credentials', err)
    return NextResponse.json(
      { error: "Configuration serveur incomplète. Veuillez contacter l'administrateur." },
      { status: 500 }
    )
  }

  const { data: existingProfile } = await admin
    .from('profiles')
    .select('id')
    .eq('id', userId)
    .maybeSingle()
  if (existingProfile) {
    return NextResponse.json({ ok: true, alreadyExisted: true })
  }

  const { data: authData, error: authError } = await admin.auth.admin.getUserById(userId)
  if (authError || !authData.user) {
    return NextResponse.json(
      { error: authError?.message || 'Compte Auth introuvable.' },
      { status: 404 }
    )
  }

  const user = authData.user
  const meta = (user.user_metadata ?? {}) as Record<string, unknown>
  const metaRole = parseRole(meta.role)
  const role = parseRole(body.role) ?? metaRole ?? 'learner'
  const fullName =
    String(body.full_name ?? '').trim() ||
    (typeof meta.full_name === 'string' ? meta.full_name.trim() : '') ||
    user.email?.split('@')[0] ||
    'Utilisateur'
  const phone =
    String(body.phone ?? '').trim() ||
    (typeof meta.phone === 'string' ? meta.phone.trim() : '') ||
    null
  const email = (user.email ?? '').trim().toLowerCase()
  if (!email) {
    return NextResponse.json(
      { error: "Ce compte Auth n'a pas d'adresse e-mail." },
      { status: 400 }
    )
  }

  const { error: metaUpdateError } = await admin.auth.admin.updateUserById(userId, {
    user_metadata: { ...meta, full_name: fullName, role, phone },
  })
  if (metaUpdateError) {
    console.error('[admin orphan-accounts] metadata update failed', metaUpdateError.message)
  }

  const completed = await ensureProfileAndRole(admin, userId, {
    email,
    full_name: fullName,
    phone,
    role,
    school_name: body.school_name?.trim() || fullName,
  })
  if (completed.error) {
    return NextResponse.json({ error: completed.error }, { status: 500 })
  }

  return NextResponse.json({ ok: true, role, full_name: fullName, email })
}
