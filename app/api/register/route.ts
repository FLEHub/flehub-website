import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'
import { createAdminClient } from '@/lib/supabase/admin'
import {
  EMAIL_ALREADY_USED,
  mapRegisterAuthError,
  mapRegisterDbError,
} from '@/lib/register-errors'

type Role = 'learner' | 'teacher' | 'school'
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

async function findAuthUserByEmail(
  admin: ReturnType<typeof createAdminClient>,
  email: string
): Promise<{ id: string } | null> {
  const adminAuth = admin.auth.admin as typeof admin.auth.admin & {
    getUserByEmail?: (email: string) => Promise<{
      data: { user: { id: string } | null }
      error: { message: string } | null
    }>
  }

  if (typeof adminAuth.getUserByEmail === 'function') {
    const { data, error } = await adminAuth.getUserByEmail(email)
    if (error || !data?.user) return null
    return { id: data.user.id }
  }

  return null
}

async function upsertRoleRow(
  admin: ReturnType<typeof createAdminClient>,
  userId: string,
  body: Required<Pick<RegisterBody, 'role'>> & RegisterBody
): Promise<{ error: string | null }> {
  if (body.role === 'learner') {
    const { data: existing } = await admin
      .from('learners')
      .select('id')
      .eq('profile_id', userId)
      .maybeSingle()
    if (existing) return { error: null }

    const { error } = await admin.from('learners').insert({
      profile_id: userId,
      subtype: body.subtype || 'independent',
      cefr_level: body.cefr_level || null,
    })
    if (error) {
      return { error: mapRegisterDbError(error.message, error.code) }
    }
    return { error: null }
  }

  if (body.role === 'teacher') {
    const { data: existing } = await admin
      .from('teachers')
      .select('id')
      .eq('profile_id', userId)
      .maybeSingle()
    if (existing) return { error: null }

    const { error } = await admin.from('teachers').insert({
      profile_id: userId,
      bio: body.bio?.trim() || null,
      qualifications: body.qualifications?.trim() || null,
    })
    if (error) {
      return { error: mapRegisterDbError(error.message, error.code) }
    }
    return { error: null }
  }

  const { data: existing } = await admin
    .from('schools')
    .select('id')
    .eq('profile_id', userId)
    .maybeSingle()
  if (existing) return { error: null }

  const { error } = await admin.from('schools').insert({
    profile_id: userId,
    school_name: body.school_name?.trim(),
    province: body.province,
    district: body.district,
    sector: body.sector,
    cell: body.cell,
    village: body.village || null,
  })
  if (error) {
    return { error: mapRegisterDbError(error.message, error.code) }
  }
  return { error: null }
}

async function ensureProfileAndRole(
  admin: ReturnType<typeof createAdminClient>,
  userId: string,
  body: RegisterBody & { email: string; role: Role; full_name: string; phone: string }
): Promise<{ error: string | null }> {
  const status = body.role === 'learner' ? 'approved' : 'pending'

  const { data: existing } = await admin
    .from('profiles')
    .select('id')
    .eq('id', userId)
    .maybeSingle()

  if (!existing) {
    const { error } = await admin.from('profiles').insert({
      id: userId,
      full_name: body.full_name,
      email: body.email,
      phone: body.phone,
      role: body.role,
      status,
    })
    if (error) {
      console.error('[register] profiles insert', {
        email: body.email,
        userId,
        code: error.code,
        message: error.message,
        details: error.details,
      })
      return { error: mapRegisterDbError(error.message, error.code) }
    }
  }

  const roleResult = await upsertRoleRow(admin, userId, body)
  if (roleResult.error) {
    console.error('[register] role row insert', {
      email: body.email,
      userId,
      role: body.role,
      message: roleResult.error,
    })
  }
  return roleResult
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

  const { data: existingProfile } = await admin
    .from('profiles')
    .select('id')
    .eq('email', email)
    .maybeSingle()

  if (existingProfile) {
    console.error('[register] email already has a profile', { email })
    return jsonError(EMAIL_ALREADY_USED, 409)
  }

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
    const status =
      signUpError.status === 429 ? 429 : signUpError.status === 422 ? 409 : 400
    return jsonError(mapRegisterAuthError(signUpError.message, signUpError.status), status)
  }

  const identities = authData.user?.identities
  const isDuplicateHidden =
    !authData.user || (Array.isArray(identities) && identities.length === 0)

  if (isDuplicateHidden) {
    // Supabase hides "email already exists" (no error, user=null or empty identities).
    const existingAuth = await findAuthUserByEmail(admin, email)
    if (existingAuth) {
      const { data: profile } = await admin
        .from('profiles')
        .select('id')
        .eq('id', existingAuth.id)
        .maybeSingle()

      if (!profile) {
        console.error('[register] orphan auth user without profile — completing', {
          email,
          userId: existingAuth.id,
        })
        const completed = await ensureProfileAndRole(admin, existingAuth.id, {
          ...body,
          email,
          role,
          full_name,
          phone,
        })
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
    }

    console.error('[register] signUp returned no usable user (likely existing email)', {
      email,
      hasUser: Boolean(authData.user),
      identityCount: identities?.length ?? null,
    })
    return jsonError(EMAIL_ALREADY_USED, 409)
  }

  const userId = authData.user.id
  const completed = await ensureProfileAndRole(admin, userId, {
    ...body,
    email,
    role,
    full_name,
    phone,
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
