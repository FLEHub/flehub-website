import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { getServiceClient } from '@/lib/supabase/service';

export class SchoolApiError extends Error {
  status: number;

  constructor(message: string, status = 400) {
    super(message);
    this.status = status;
  }
}

export function jsonError(error: unknown) {
  if (error instanceof SchoolApiError) {
    return NextResponse.json({ error: error.message }, { status: error.status });
  }

  const message = error instanceof Error ? error.message : 'Une erreur inattendue est survenue.';
  return NextResponse.json({ error: message }, { status: 500 });
}

export async function requireSchool(options: { approved?: boolean } = {}) {
  const supabase = await createClient();
  const service = getServiceClient();

  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser();

  if (userError || !user) {
    throw new SchoolApiError('Vous devez être connecté.', 401);
  }

  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select('id, email, full_name, phone, role, status')
    .eq('id', user.id)
    .maybeSingle();

  if (profileError || !profile || profile.role !== 'school') {
    throw new SchoolApiError("Votre compte école est introuvable.", 403);
  }

  const { data: school, error: schoolError } = await supabase
    .from('schools')
    .select(
      'id, profile_id, school_name, name, address, district, province, sector, cell, village, type, director_name, email, phone, logo_url, signature_url, status, created_at'
    )
    .eq('profile_id', user.id)
    .maybeSingle();

  if (schoolError || !school) {
    throw new SchoolApiError("Le profil de votre établissement n'est pas encore configuré.", 403);
  }

  const accountStatus = school.status ?? profile.status;
  if (options.approved && (profile.status !== 'approved' || accountStatus !== 'approved')) {
    throw new SchoolApiError("Votre établissement doit être approuvé avant d'effectuer cette action.", 403);
  }

  return { supabase, service, user, profile, school };
}

export async function requireAdmin() {
  const supabase = await createClient();
  const service = getServiceClient();
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser();

  if (userError || !user) {
    throw new SchoolApiError('Vous devez être connecté.', 401);
  }

  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select('id, email, full_name, role, status')
    .eq('id', user.id)
    .maybeSingle();

  if (profileError || !profile || profile.role !== 'admin') {
    throw new SchoolApiError('Accès administrateur requis.', 403);
  }

  return { supabase, service, user, profile };
}

export async function signedSchoolAssetUrl(path?: string | null, expiresIn = 60 * 30) {
  if (!path) return null;
  if (/^https?:\/\//.test(path)) return path;

  const service = getServiceClient();
  if (!service) return null;

  const { data } = await service.storage.from('school-assets').createSignedUrl(path, expiresIn);
  return data?.signedUrl ?? null;
}
