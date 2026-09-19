import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'
import { createAdminClient } from '@/lib/supabase/admin'
import { findAuthUserByEmail } from '@/lib/find-auth-user'
import { ensureProfileAndRole, type AppRole } from '@/lib/ensure-profile'
import {
  EMAIL_ALREADY_USED,
  ORPHAN_LOOKUP_FAILED,
  isAuthEmailTakenError,
  mapRegisterAuthError,
} from '@/lib/register-errors'

type Role = Extract<AppRole, 'learner' | 'teacher' | 'school'>
type LearnerSubtype = 'independent' | 'pupil'
type CEFRLevel = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2'

interface RegisterBody {
  full_name?: string
  email?: string
  password?: string
  phone?: string
  role?: Role
  subtype?: LearnerSubtype
  cefr_level?: CEFRLevel | ''
  bio?: string
  qualifications?: string
  school_name?: string
  province?: string
  district?: string
  sector?: string
  cell?: string
  village?: string
}

function jsonError(error: string, status: number, debug?: unknown) {
  if (debug !== undefined) {
    console.error('[register]', error, debug)
  } else {
    console.error('[register]', error)
  }
  return NextResponse.json({ error }, { status })
}

async function recoverOrphan(
  admin: ReturnType<typeof createAdminClient>,
  userId: string,
  body: RegisterBody & { email: string; role: Role; full_name: string; phone: string; password: string }
): Promise<{ error: string | null }> {
  const { error: updateErr } = await admin.auth.admin.updateUserById(userId, {
    password: body.password,
    user_metadata: { full_name: body.full_name, role: body.role, phone: body.phone },
  })
  if (updateErr) {
    console.error('[register] orphan password/metadata update failed', {
      email: body.email,
      userId,
      message: updateErr.message,
    })
  }

  return ensureProfileAndRole(admin, userId, {
    email: body.email,
    full_name: body.full_name,
    phone: body.phone,
    role: body.role,
    subtype: body.subtype,
    cefr_level: body.cefr_level || null,
    bio: body.bio,
    qualifications: body.qualifications,
    school_name: body.school_name,
    province: body.province,
    district: body.district,
    sector: body.sector,
    cell: body.cell,
    village: body.village,
  })
}

export async function POST(request: NextRequest) {
  let body: RegisterBody
  try {
    body = await request.json()
  } catch {
    return jsonError('Requête invalide.', 400)
  }

  const email = body.email?.trim().toLowerCase() ?? ''
  const password = body.password ?? ''
  const full_name = body.full_name?.trim() ?? ''
  const phone = body.phone?.trim() ?? ''
  const role = body.role

  if (!role || !['learner', 'teacher', 'school'].includes(role)) {
    return jsonError('Veuillez choisir un rôle.', 400)
  }
  if (!full_name) return jsonError('Le nom complet est requis.', 400)
  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return jsonError('Veuillez saisir une adresse e-mail valide.', 400)
  }
  if (password.length < 8) {
    return jsonError('Le mot de passe doit contenir au moins 8 caractères.', 400)
  }
  if (!phone) return jsonError('Le numéro de téléphone est requis.', 400)
  if (role === 'learner' && !body.cefr_level) {
    return jsonError('Veuillez sélectionner votre niveau CECRL.', 400)
  }
  if (role === 'teacher' && (!body.bio?.trim() || !body.qualifications?.trim())) {
    return jsonError('La biographie et les qualifications sont requises.', 400)
  }
  if (role === 'school') {
    if (!body.school_name?.trim()) {
      return jsonError("Le nom de l'établissement est requis.", 400)
    }
    if (!body.province || !body.district || !body.sector || !body.cell || !body.village) {
      return jsonError("Veuillez renseigner l'adresse complète de l'établissement.", 400)
    }
  }

  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
  if (!url || !anonKey) {
    return jsonError("Configuration serveur incomplète. Veuillez contacter l'administrateur.", 500)
  }

  let admin: ReturnType<typeof createAdminClient>
  try {
    admin = createAdminClient()
  } catch (err) {
    return jsonError(
      "Configuration serveur incomplète. Veuillez contacter l'administrateur.",
      500,
      err
    )
  }

  const payload = { ...body, email, role, full_name, phone, password }

  const { data: existingProfile } = await admin
    .from('profiles')
    .select('id')
    .eq('email', email)
    .maybeSingle()

  if (existingProfile) {
    console.error('[register] email already has a profile', { email })
    return jsonError(EMAIL_ALREADY_USED, 409)
  }

  const tryRecover = async (reason: string, exhaustive: boolean) => {
    const existingAuth = await findAuthUserByEmail(admin, email, { exhaustive })
    if (!existingAuth) return null

    const { data: profile } = await admin
      .from('profiles')
      .select('id')
      .eq('id', existingAuth.id)
      .maybeSingle()

    if (profile) {
      console.error('[register] email already has a profile (auth id)', {
        email,
        userId: existingAuth.id,
      })
      return jsonError(EMAIL_ALREADY_USED, 409)
    }

    console.error('[register] orphan auth user without profile — completing', {
      reason,
      email,
      userId: existingAuth.id,
    })
    const completed = await recoverOrphan(admin, existingAuth.id, payload)
    if (completed.error) {
      return jsonError(completed.error, 500, {
        email,
        userId: existingAuth.id,
      })
    }
    return NextResponse.json({
      ok: true,
      pending: role !== 'learner',
      recovered: true,
    })
  }

  const recoveredBeforeSignUp = await tryRecover('pre-signup lookup', false)
  if (recoveredBeforeSignUp) return recoveredBeforeSignUp

  const anon = createClient(url, anonKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  })

  const { data: authData, error: signUpError } = await anon.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name,
        role,
        phone,
      },
    },
  })

  if (signUpError) {
    console.error('[register] auth.signUp error', {
      email,
      message: signUpError.message,
      status: signUpError.status,
      name: signUpError.name,
    })

    if (isAuthEmailTakenError(signUpError.message)) {
      const recovered = await tryRecover('signup already-registered', true)
      if (recovered) return recovered
      return jsonError(ORPHAN_LOOKUP_FAILED, 409, { email })
    }

    const status =
      signUpError.status === 429 ? 429 : signUpError.status === 422 ? 409 : 400
    return jsonError(mapRegisterAuthError(signUpError.message, signUpError.status), status)
  }

  const signedUpUser = authData.user
  const identities = signedUpUser?.identities
  const isDuplicateHidden =
    !signedUpUser || (Array.isArray(identities) && identities.length === 0)

  if (isDuplicateHidden) {
    const recovered = await tryRecover('signup hidden duplicate', true)
    if (recovered) return recovered

    console.error('[register] signUp returned no usable user (likely existing email)', {
      email,
      hasUser: Boolean(signedUpUser),
      identityCount: identities?.length ?? null,
    })
    return jsonError(ORPHAN_LOOKUP_FAILED, 409, { email })
  }

  const userId = signedUpUser.id
  const completed = await ensureProfileAndRole(admin, userId, {
    email,
    full_name,
    phone,
    role,
    subtype: body.subtype,
    cefr_level: body.cefr_level || null,
    bio: body.bio,
    qualifications: body.qualifications,
    school_name: body.school_name,
    province: body.province,
    district: body.district,
    sector: body.sector,
    cell: body.cell,
    village: body.village,
  })
  if (completed.error) {
    return jsonError(completed.error, 500, { email, userId })
  }

  console.info('[register] success', { email, role, userId })
  return NextResponse.json({
    ok: true,
    pending: role !== 'learner',
  })
}
