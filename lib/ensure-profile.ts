import { createAdminClient } from '@/lib/supabase/admin'
import { ACCOUNT_STATUS, type AccountStatus } from '@/lib/account-status'
import { mapRegisterDbError } from '@/lib/register-errors'

export type AppRole = 'admin' | 'school' | 'teacher' | 'learner' | 'journalist' | 'creator'

export type EnsureProfileInput = {
  email: string
  full_name: string
  phone?: string | null
  role: AppRole
  subtype?: 'independent' | 'pupil' | null
  cefr_level?: string | null
  bio?: string | null
  qualifications?: string | null
  school_name?: string | null
  province?: string | null
  district?: string | null
  sector?: string | null
  cell?: string | null
  village?: string | null
  /** Auth user already has email_confirmed_at (orphan recovery or confirmations off). */
  emailConfirmedAt?: string | null
}

type AdminClient = ReturnType<typeof createAdminClient>

function isDuplicate(code?: string | null, message?: string | null) {
  const msg = (message || '').toLowerCase()
  return code === '23505' || msg.includes('duplicate key') || msg.includes('unique constraint')
}

/** Public signup waits for email, then for an admin. Staff accounts are active. */
export function initialAccountStatus(
  role: AppRole,
  emailConfirmed: boolean
): AccountStatus {
  if (role === 'admin' || role === 'journalist' || role === 'creator') {
    return ACCOUNT_STATUS.ACTIVE
  }
  return emailConfirmed ? ACCOUNT_STATUS.PENDING_ADMIN : ACCOUNT_STATUS.PENDING_EMAIL
}

async function upsertRoleRow(
  admin: AdminClient,
  userId: string,
  body: EnsureProfileInput
): Promise<{ error: string | null }> {
  if (body.role === 'admin') return { error: null }

  if (body.role === 'learner') {
    const { data: existing } = await admin
      .from('learners')
      .select('id')
      .eq('profile_id', userId)
      .maybeSingle()
    if (existing) {
      if (body.cefr_level || body.subtype) {
        await admin
          .from('learners')
          .update({
            ...(body.subtype ? { subtype: body.subtype } : {}),
            ...(body.cefr_level ? { cefr_level: body.cefr_level } : {}),
          })
          .eq('id', existing.id)
      }
      return { error: null }
    }

    const { error } = await admin.from('learners').insert({
      profile_id: userId,
      subtype: body.subtype || 'independent',
      cefr_level: body.cefr_level || null,
    })
    if (error && !isDuplicate(error.code, error.message)) {
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
    if (error && !isDuplicate(error.code, error.message)) {
      return { error: mapRegisterDbError(error.message, error.code) }
    }
    return { error: null }
  }

  if (body.role === 'journalist') {
    const { data: existing } = await admin
      .from('journalists')
      .select('id')
      .eq('profile_id', userId)
      .maybeSingle()
    if (existing) return { error: null }

    const { error } = await admin.from('journalists').insert({
      profile_id: userId,
      bio: body.bio?.trim() || null,
    })
    if (error && !isDuplicate(error.code, error.message)) {
      return { error: mapRegisterDbError(error.message, error.code) }
    }
    return { error: null }
  }

  if (body.role === 'creator') {
    const { data: existing } = await admin
      .from('creators')
      .select('id')
      .eq('profile_id', userId)
      .maybeSingle()
    if (existing) return { error: null }

    const { error } = await admin.from('creators').insert({
      profile_id: userId,
      bio: body.bio?.trim() || null,
    })
    if (error && !isDuplicate(error.code, error.message)) {
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
    school_name: body.school_name?.trim() || body.full_name || 'Établissement',
    province: body.province || null,
    district: body.district || null,
    sector: body.sector || null,
    cell: body.cell || null,
    village: body.village || null,
  })
  if (error && !isDuplicate(error.code, error.message)) {
    return { error: mapRegisterDbError(error.message, error.code) }
  }
  return { error: null }
}

/**
 * Insert (or reuse) the profiles row and the matching role table row.
 * Safe to call more than once for the same Auth user (retry / trigger race).
 */
export async function ensureProfileAndRole(
  admin: AdminClient,
  userId: string,
  body: EnsureProfileInput
): Promise<{ error: string | null }> {
  const emailConfirmed = Boolean(body.emailConfirmedAt)
  const status = initialAccountStatus(body.role, emailConfirmed)

  const { data: existing } = await admin
    .from('profiles')
    .select('id')
    .eq('id', userId)
    .maybeSingle()

  if (!existing) {
    const { error } = await admin.from('profiles').upsert(
      {
        id: userId,
        full_name: body.full_name,
        email: body.email,
        phone: body.phone || null,
        role: body.role,
        status,
        email_confirmed_at: body.emailConfirmedAt || null,
      },
      { onConflict: 'id', ignoreDuplicates: true }
    )
    if (error && !isDuplicate(error.code, error.message)) {
      console.error('[register] profiles insert', {
        email: body.email,
        userId,
        code: error.code,
        message: error.message,
        details: error.details,
      })
      return { error: mapRegisterDbError(error.message, error.code) }
    }
    if (error) {
      const { data: created } = await admin
        .from('profiles')
        .select('id')
        .eq('id', userId)
        .maybeSingle()
      if (!created) {
        return { error: mapRegisterDbError(error.message, error.code) }
      }
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
