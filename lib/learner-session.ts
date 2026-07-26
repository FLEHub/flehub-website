import type { SupabaseClient } from '@supabase/supabase-js';

export async function getCurrentLearnerId(
  supabase: SupabaseClient
): Promise<string | null> {
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: learner } = await supabase
    .from('learners')
    .select('id')
    .eq('profile_id', user.id)
    .maybeSingle();

  return learner?.id ?? null;
}

export function canJoinSession(
  scheduledAt: string,
  status: string,
  windowMinutes = 15
): boolean {
  if (status === 'live') return true;
  if (status !== 'scheduled') return false;
  const start = new Date(scheduledAt).getTime();
  const now = Date.now();
  const windowMs = windowMinutes * 60 * 1000;
  return now >= start - windowMs && now <= start + 3 * 60 * 60 * 1000;
}
