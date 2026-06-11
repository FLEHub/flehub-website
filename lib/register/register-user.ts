import type { SupabaseClient } from '@supabase/supabase-js';
import { createClient as createServerClient } from '@/lib/supabase/server';
import { getServiceClient } from '@/lib/supabase/service';
import {
  mapRegisterError,
  validateRegisterPayload,
  type RegisterPayload,
} from '@/lib/register/validation';

type AdminClient = SupabaseClient;

function isDuplicateEmailError(message: string) {
  const normalized = message.toLowerCase();
  return (
    normalized.includes('déjà utilisée') ||
    normalized.includes('already registered') ||
    normalized.includes('already exists') ||
    normalized.includes('duplicate key')
  );
}

async function rollbackRegistration(supabase: AdminClient, userId: string) {
  await supabase.from('teachers').delete().eq('profile_id', userId);
  await supabase.from('learners').delete().eq('profile_id', userId);
  await supabase.from('schools').delete().eq('profile_id', userId);
  await supabase.from('profiles').delete().eq('id', userId);

  try {
    await supabase.auth.admin.deleteUser(userId);
  } catch {
    // Ignore cleanup errors
  }
}

async function insertRoleRecord(
  supabase: SupabaseClient,
  body: RegisterPayload,
  userId: string
) {
  if (body.role === 'learner') {
    return supabase.from('learners').insert({
      profile_id: userId,
      subtype: body.subtype ?? 'independent',
      cefr_level: body.cefr_level,
    });
  }

  if (body.role === 'teacher') {
    const primaryInsert = await supabase.from('teachers').insert({
      profile_id: userId,
      bio: body.bio!.trim(),
      qualifications: body.qualifications!.trim(),
    });

    if (!primaryInsert.error) {
      return primaryInsert;
    }

    return supabase.from('teachers').insert({
      id: userId,
      profile_id: userId,
      bio: body.bio!.trim(),
      qualifications: body.qualifications!.trim(),
    });
  }

  return supabase.from('schools').insert({
    profile_id: userId,
    school_name: body.school_name!.trim(),
    province: body.province,
    district: body.district,
    sector: body.sector,
    cell: body.cell,
    village: body.village || null,
  });
}

async function saveProfileAndRole(
  dbClient: SupabaseClient,
  body: RegisterPayload,
  userId: string,
  canRollback: boolean,
  adminClient?: AdminClient
) {
  const email = body.email.trim().toLowerCase();
  const status = body.role === 'learner' ? 'approved' : 'pending';

  const { error: profileError } = await dbClient.from('profiles').upsert(
    {
      id: userId,
      full_name: body.full_name.trim(),
      email,
      phone: body.phone.trim(),
      role: body.role,
      status,
    },
    { onConflict: 'id' }
  );

  if (profileError) {
    if (canRollback && adminClient) {
      await rollbackRegistration(adminClient, userId);
    }
    return { ok: false as const, error: mapRegisterError(profileError.message) };
  }

  const { error: roleError } = await insertRoleRecord(dbClient, body, userId);

  if (roleError) {
    if (canRollback && adminClient) {
      await rollbackRegistration(adminClient, userId);
    }
    return { ok: false as const, error: mapRegisterError(roleError.message) };
  }

  return { ok: true as const };
}

async function registerWithServiceRole(body: RegisterPayload, supabase: AdminClient) {
  try {
    const email = body.email.trim().toLowerCase();

    const { data: authData, error: signUpError } = await supabase.auth.admin.createUser({
      email,
      password: body.password,
      email_confirm: true,
      user_metadata: {
        full_name: body.full_name.trim(),
        role: body.role,
        phone: body.phone.trim(),
      },
    });

    if (signUpError) {
      return { ok: false as const, error: mapRegisterError(signUpError.message) };
    }

    if (!authData.user) {
      return {
        ok: false as const,
        error: "L'inscription a échoué. Veuillez réessayer.",
      };
    }

    return saveProfileAndRole(supabase, body, authData.user.id, true, supabase);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return { ok: false as const, error: message };
  }
}

async function registerWithPublicAuth(body: RegisterPayload) {
  try {
    const authClient = await createServerClient();
    const email = body.email.trim().toLowerCase();

    const { data: authData, error: signUpError } = await authClient.auth.signUp({
      email,
      password: body.password,
      options: {
        data: {
          full_name: body.full_name.trim(),
          role: body.role,
          phone: body.phone.trim(),
        },
      },
    });

    if (signUpError) {
      return { ok: false as const, error: mapRegisterError(signUpError.message) };
    }

    if (!authData.user) {
      return {
        ok: false as const,
        error: "L'inscription a échoué. Veuillez réessayer.",
      };
    }

    const dbClient = getServiceClient() ?? authClient;
    const adminClient = getServiceClient() ?? undefined;

    return saveProfileAndRole(
      dbClient,
      body,
      authData.user.id,
      Boolean(adminClient),
      adminClient
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return { ok: false as const, error: mapRegisterError(message) };
  }
}

export async function registerUser(body: RegisterPayload) {
  const validationError = validateRegisterPayload(body);
  if (validationError) {
    return { ok: false as const, error: validationError, status: 400 };
  }

  const serviceClient = getServiceClient();

  if (serviceClient) {
    const serviceResult = await registerWithServiceRole(body, serviceClient);
    if (serviceResult.ok) {
      return { ok: true as const };
    }
    if (isDuplicateEmailError(serviceResult.error)) {
      return { ok: false as const, error: serviceResult.error, status: 400 };
    }
  }

  const publicResult = await registerWithPublicAuth(body);
  return publicResult.ok
    ? { ok: true as const }
    : { ok: false as const, error: publicResult.error, status: 400 };
}
