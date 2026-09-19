import { createAdminClient } from '@/lib/supabase/admin'

type AuthUserHit = { id: string; email?: string | null }

function matchEmail(users: AuthUserHit[] | undefined, email: string): AuthUserHit | undefined {
  const normalized = email.trim().toLowerCase()
  return (users ?? []).find((u) => u.email?.toLowerCase() === normalized)
}

/**
 * Look up an Auth user by email. supabase-js has no getUserByEmail — use the
 * GoTrue admin `filter` query, then fall back to paginated listUsers.
 */
export async function findAuthUserByEmail(
  admin: ReturnType<typeof createAdminClient>,
  email: string
): Promise<{ id: string } | null> {
  const normalized = email.trim().toLowerCase()
  if (!normalized) return null

  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY

  if (url && key) {
    try {
      const res = await fetch(
        `${url}/auth/v1/admin/users?page=1&per_page=50&filter=${encodeURIComponent(normalized)}`,
        {
          headers: {
            Authorization: `Bearer ${key}`,
            apikey: key,
          },
          cache: 'no-store',
        }
      )
      if (res.ok) {
        const json = (await res.json()) as { users?: AuthUserHit[] }
        const match = matchEmail(json.users, normalized)
        if (match) return { id: match.id }
      } else {
        console.error('[register] auth admin filter lookup HTTP', res.status)
      }
    } catch (err) {
      console.error('[register] auth admin filter lookup failed', err)
    }
  }

  const perPage = 200
  for (let page = 1; page <= 25; page++) {
    const { data, error } = await admin.auth.admin.listUsers({ page, perPage })
    if (error) {
      console.error('[register] listUsers failed', { page, message: error.message })
      break
    }
    const match = matchEmail(data?.users, normalized)
    if (match) return { id: match.id }
    if ((data?.users?.length ?? 0) < perPage) break
  }

  return null
}
