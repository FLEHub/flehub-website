import { createAdminClient } from '@/lib/supabase/admin'

export type AuthUserHit = {
  id: string
  email?: string | null
  created_at?: string
  last_sign_in_at?: string | null
  email_confirmed_at?: string | null
  user_metadata?: Record<string, unknown> | null
}

type AdminClient = ReturnType<typeof createAdminClient>

function matchEmail(users: AuthUserHit[] | undefined, email: string): AuthUserHit | undefined {
  const normalized = email.trim().toLowerCase()
  return (users ?? []).find((u) => u.email?.toLowerCase() === normalized)
}

async function lookupAuthUsers(
  url: string,
  key: string,
  query: string
): Promise<AuthUserHit[] | null> {
  try {
    const res = await fetch(`${url}/auth/v1/admin/users?${query}`, {
      headers: {
        Authorization: `Bearer ${key}`,
        apikey: key,
      },
      cache: 'no-store',
    })
    if (!res.ok) {
      console.error('[register] auth admin users lookup HTTP', res.status, query)
      return null
    }
    const json = (await res.json()) as { users?: AuthUserHit[] }
    return json.users ?? []
  } catch (err) {
    console.error('[register] auth admin users lookup failed', query, err)
    return null
  }
}

async function listUsersPage(
  admin: AdminClient,
  page: number,
  perPage: number
): Promise<{ users: AuthUserHit[]; error: string | null; done: boolean }> {
  const { data, error } = await admin.auth.admin.listUsers({ page, perPage })
  if (error) {
    return { users: [], error: error.message, done: true }
  }
  const users = (data?.users ?? []) as AuthUserHit[]
  return { users, error: null, done: users.length < perPage }
}

/**
 * Look up an Auth user by email. supabase-js has no getUserByEmail — try the
 * GoTrue admin `email` then `filter` query, then (if exhaustive) paginated
 * listUsers. Skip the full scan on the happy path so registration stays fast.
 */
export async function findAuthUserByEmail(
  admin: AdminClient,
  email: string,
  options?: { exhaustive?: boolean }
): Promise<AuthUserHit | null> {
  const normalized = email.trim().toLowerCase()
  if (!normalized) return null

  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY
  const encoded = encodeURIComponent(normalized)

  if (url && key) {
    const exact = await lookupAuthUsers(url, key, `page=1&per_page=5&email=${encoded}`)
    const exactMatch = matchEmail(exact ?? undefined, normalized)
    if (exactMatch) return exactMatch

    const filtered = await lookupAuthUsers(url, key, `page=1&per_page=50&filter=${encoded}`)
    const filterMatch = matchEmail(filtered ?? undefined, normalized)
    if (filterMatch) return filterMatch
  }

  if (!options?.exhaustive) return null

  const perPage = 200
  for (let page = 1; page <= 50; page++) {
    const { users, error, done } = await listUsersPage(admin, page, perPage)
    if (error) {
      console.error('[register] listUsers failed', { page, message: error })
      break
    }
    const match = matchEmail(users, normalized)
    if (match) return match
    if (done) break
  }

  return null
}

export async function listAuthUsersWithoutProfiles(
  admin: AdminClient
): Promise<{ accounts: OrphanAuthAccount[]; error: string | null }> {
  const { data, error } = await admin.rpc('list_auth_users_without_profiles')
  if (!error && Array.isArray(data)) {
    return {
      accounts: (data as RpcOrphanRow[]).map(mapRpcOrphan),
      error: null,
    }
  }
  if (error) {
    console.error('[admin] list_auth_users_without_profiles rpc', error.message)
  }

  const profileIds = new Set<string>()
  const pageSize = 1000
  for (let from = 0; from < 100_000; from += pageSize) {
    const { data: rows, error: profileError } = await admin
      .from('profiles')
      .select('id')
      .range(from, from + pageSize - 1)
    if (profileError) {
      return { accounts: [], error: profileError.message }
    }
    for (const row of rows ?? []) profileIds.add(row.id)
    if ((rows?.length ?? 0) < pageSize) break
  }

  const accounts: OrphanAuthAccount[] = []
  const perPage = 200
  for (let page = 1; page <= 50; page++) {
    const { users, error: listError, done } = await listUsersPage(admin, page, perPage)
    if (listError) {
      return { accounts: [], error: listError }
    }
    for (const user of users) {
      if (profileIds.has(user.id)) continue
      accounts.push(authUserToOrphan(user))
    }
    if (done) break
  }

  accounts.sort((a, b) => (a.created_at < b.created_at ? 1 : -1))
  return { accounts, error: null }
}

type RpcOrphanRow = {
  id: string
  email: string | null
  created_at: string
  last_sign_in_at: string | null
  email_confirmed_at: string | null
  full_name: string | null
  meta_role: string | null
  phone: string | null
}

export type OrphanAuthAccount = {
  id: string
  email: string | null
  created_at: string
  last_sign_in_at: string | null
  email_confirmed_at: string | null
  full_name: string | null
  meta_role: string | null
  phone: string | null
}

function mapRpcOrphan(row: RpcOrphanRow): OrphanAuthAccount {
  return {
    id: row.id,
    email: row.email,
    created_at: row.created_at,
    last_sign_in_at: row.last_sign_in_at,
    email_confirmed_at: row.email_confirmed_at,
    full_name: row.full_name,
    meta_role: row.meta_role,
    phone: row.phone,
  }
}

function metaString(meta: Record<string, unknown> | null | undefined, key: string): string | null {
  const value = meta?.[key]
  return typeof value === 'string' && value.trim() ? value.trim() : null
}

function authUserToOrphan(user: AuthUserHit): OrphanAuthAccount {
  const meta = user.user_metadata ?? null
  return {
    id: user.id,
    email: user.email ?? null,
    created_at: user.created_at ?? '',
    last_sign_in_at: user.last_sign_in_at ?? null,
    email_confirmed_at: user.email_confirmed_at ?? null,
    full_name: metaString(meta, 'full_name'),
    meta_role: metaString(meta, 'role'),
    phone: metaString(meta, 'phone'),
  }
}
