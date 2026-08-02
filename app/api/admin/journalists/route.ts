import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createAdminClient } from '@/lib/supabase/admin'

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

/** Create a journalist account (auth + profiles + journalists). */
export async function POST(request: NextRequest) {
  const adminUser = await requireAdmin()
  if (!adminUser) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })
  }

  const body = await request.json()
  const fullName = String(body.full_name ?? '').trim()
  const email = String(body.email ?? '').trim().toLowerCase()
  const password = String(body.password ?? '')
  const bio = body.bio != null ? String(body.bio).trim() : ''

  if (!fullName) {
    return NextResponse.json({ error: 'Full name is required.' }, { status: 400 })
  }
  if (!email || !email.includes('@')) {
    return NextResponse.json({ error: 'A valid email is required.' }, { status: 400 })
  }
  if (password.length < 8) {
    return NextResponse.json(
      { error: 'Password must be at least 8 characters.' },
      { status: 400 }
    )
  }

  const admin = createAdminClient()

  const { data: created, error: createError } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: {
      full_name: fullName,
      role: 'journalist',
    },
  })

  if (createError || !created.user) {
    return NextResponse.json(
      { error: createError?.message || 'Failed to create auth user.' },
      { status: 400 }
    )
  }

  const userId = created.user.id

  const { error: profileError } = await admin.from('profiles').upsert(
    {
      id: userId,
      email,
      full_name: fullName,
      role: 'journalist',
      status: 'approved',
      updated_at: new Date().toISOString(),
    },
    { onConflict: 'id' }
  )

  if (profileError) {
    await admin.auth.admin.deleteUser(userId)
    return NextResponse.json(
      { error: `Profile create failed: ${profileError.message}` },
      { status: 500 }
    )
  }

  const { data: journalist, error: journalistError } = await admin
    .from('journalists')
    .insert({
      profile_id: userId,
      bio: bio || null,
    })
    .select('id, profile_id, bio, avatar_url, created_at')
    .single()

  if (journalistError) {
    await admin.from('profiles').delete().eq('id', userId)
    await admin.auth.admin.deleteUser(userId)
    return NextResponse.json(
      { error: `Journalist row create failed: ${journalistError.message}` },
      { status: 500 }
    )
  }

  return NextResponse.json(
    {
      journalist: {
        ...journalist,
        full_name: fullName,
        email,
        status: 'approved',
      },
    },
    { status: 201 }
  )
}
