import type { createAdminClient } from '@/lib/supabase/admin'
import { ACCOUNT_STATUS } from '@/lib/account-status'
import { sendAccountEmail } from '@/lib/send-account-email'

type AdminClient = ReturnType<typeof createAdminClient>

export type PendingValidationRow = {
  id: string
  full_name: string
  email: string
  phone: string | null
  role: string
  created_at: string
  email_confirmed_at: string | null
  role_details: string | null
}

const AWAITING_STATUSES = ['pending_admin_validation', 'pending']

function isAwaitingValidation(status: string | null | undefined): boolean {
  return status === 'pending_admin_validation' || status === 'pending'
}

function roleDetails(input: {
  role: string
  school?: { school_name?: string | null; province?: string | null; district?: string | null } | null
  teacher?: { qualifications?: string | null; bio?: string | null } | null
  learner?: { subtype?: string | null; cefr_level?: string | null } | null
}): string | null {
  if (input.role === 'school' && input.school) {
    const place = [input.school.province, input.school.district].filter(Boolean).join(', ')
    const name = input.school.school_name?.trim() || 'Établissement'
    return place ? `${name} — ${place}` : name
  }
  if (input.role === 'teacher' && input.teacher) {
    return input.teacher.qualifications?.trim() || input.teacher.bio?.trim() || null
  }
  if (input.role === 'learner' && input.learner) {
    const kind = input.learner.subtype === 'pupil' ? 'Élève' : 'Indépendant'
    const level = input.learner.cefr_level?.trim()
    return level ? `${kind} · niveau ${level}` : kind
  }
  return null
}

export async function listPendingValidations(
  admin: AdminClient
): Promise<{ rows: PendingValidationRow[]; error: string | null }> {
  const { data: profiles, error } = await admin
    .from('profiles')
    .select('id, full_name, email, phone, role, created_at, email_confirmed_at, status')
    .in('status', AWAITING_STATUSES)
    .order('email_confirmed_at', { ascending: true, nullsFirst: false })

  if (error) {
    console.error('[validations] list', error)
    return { rows: [], error: 'Impossible de charger les comptes en attente.' }
  }

  const list = profiles ?? []
  const ids = list.map((p) => p.id)
  if (ids.length === 0) return { rows: [], error: null }

  const [schools, teachers, learners] = await Promise.all([
    admin
      .from('schools')
      .select('profile_id, school_name, province, district')
      .in('profile_id', ids),
    admin.from('teachers').select('profile_id, qualifications, bio').in('profile_id', ids),
    admin.from('learners').select('profile_id, subtype, cefr_level').in('profile_id', ids),
  ])

  const schoolByProfile = new Map(
    (schools.data ?? []).map((row) => [row.profile_id as string, row])
  )
  const teacherByProfile = new Map(
    (teachers.data ?? []).map((row) => [row.profile_id as string, row])
  )
  const learnerByProfile = new Map(
    (learners.data ?? []).map((row) => [row.profile_id as string, row])
  )

  return {
    error: null,
    rows: list.map((profile) => ({
      id: profile.id,
      full_name: profile.full_name || '',
      email: profile.email || '',
      phone: profile.phone,
      role: profile.role,
      created_at: profile.created_at,
      email_confirmed_at: profile.email_confirmed_at,
      role_details: roleDetails({
        role: profile.role,
        school: schoolByProfile.get(profile.id),
        teacher: teacherByProfile.get(profile.id),
        learner: learnerByProfile.get(profile.id),
      }),
    })),
  }
}

async function loadAwaitingProfile(admin: AdminClient, userId: string) {
  const { data, error } = await admin
    .from('profiles')
    .select('id, email, full_name, status')
    .eq('id', userId)
    .maybeSingle()

  if (error || !data) return { profile: null, error: 'Compte introuvable.' }
  if (!isAwaitingValidation(data.status)) {
    return { profile: null, error: "Ce compte n'est plus en attente de validation." }
  }
  return { profile: data, error: null }
}

async function notify(
  admin: AdminClient,
  userId: string,
  title: string,
  body: string,
  type: 'success' | 'error'
) {
  const { error } = await admin.from('notifications').insert({
    user_id: userId,
    title,
    body,
    type,
    action_url: '/login',
  })
  if (error) console.error('[validations] notification', error.message)
}

export async function validatePendingAccount(
  admin: AdminClient,
  input: { userId: string; adminId: string }
): Promise<{ ok: boolean; error: string | null; emailSent: boolean; emailError?: string }> {
  const { profile, error } = await loadAwaitingProfile(admin, input.userId)
  if (!profile) return { ok: false, error, emailSent: false }

  const now = new Date().toISOString()
  const { error: updateError } = await admin
    .from('profiles')
    .update({
      status: ACCOUNT_STATUS.ACTIVE,
      validated_by: input.adminId,
      validated_at: now,
      rejection_reason: null,
      updated_at: now,
    })
    .eq('id', profile.id)
    .in('status', AWAITING_STATUSES)

  if (updateError) {
    console.error('[validations] activate', updateError)
    return { ok: false, error: "La validation a échoué.", emailSent: false }
  }

  const emailResult = profile.email
    ? await sendAccountEmail({
        kind: 'activated',
        to: profile.email,
        fullName: profile.full_name || '',
      })
    : { sent: false, error: 'Adresse e-mail manquante.' }

  await notify(
    admin,
    profile.id,
    'Compte activé',
    'Votre compte MFK est activé, vous pouvez vous connecter.',
    'success'
  )

  return {
    ok: true,
    error: null,
    emailSent: emailResult.sent,
    emailError: emailResult.error,
  }
}

export async function rejectPendingAccount(
  admin: AdminClient,
  input: { userId: string; adminId: string; reason?: string | null }
): Promise<{ ok: boolean; error: string | null; emailSent: boolean; emailError?: string }> {
  const { profile, error } = await loadAwaitingProfile(admin, input.userId)
  if (!profile) return { ok: false, error, emailSent: false }

  const reason = input.reason?.trim() || null
  const now = new Date().toISOString()
  const { error: updateError } = await admin
    .from('profiles')
    .update({
      status: ACCOUNT_STATUS.REJECTED,
      rejection_reason: reason,
      validated_by: input.adminId,
      validated_at: now,
      updated_at: now,
    })
    .eq('id', profile.id)
    .in('status', AWAITING_STATUSES)

  if (updateError) {
    console.error('[validations] reject', updateError)
    return { ok: false, error: 'Le refus a échoué.', emailSent: false }
  }

  const emailResult = profile.email
    ? await sendAccountEmail({
        kind: 'rejected',
        to: profile.email,
        fullName: profile.full_name || '',
        reason,
      })
    : { sent: false, error: 'Adresse e-mail manquante.' }

  const body = reason
    ? `Votre inscription n'a pas été acceptée. Motif : ${reason}`
    : "Votre inscription n'a pas été acceptée."

  await notify(admin, profile.id, 'Inscription refusée', body, 'error')

  return {
    ok: true,
    error: null,
    emailSent: emailResult.sent,
    emailError: emailResult.error,
  }
}
