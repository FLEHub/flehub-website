/*
  Create a public.profiles row in the same transaction as auth.users insert.

  Registration used to create the Auth user first, then insert the profile from
  the application. If that second step never ran (no session + RLS, timeout,
  ignored error), the user could confirm their email and still have no profile.

  handle_new_user() is SECURITY DEFINER so it bypasses RLS. Invalid or missing
  metadata.role falls back to learner so Auth signup cannot fail the check
  constraint. ON CONFLICT (id) keeps this compatible with app-level upserts.
*/

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  meta_role text;
  profile_role text;
  profile_status text;
BEGIN
  meta_role := lower(btrim(coalesce(NEW.raw_user_meta_data->>'role', '')));

  IF meta_role IN ('admin', 'school', 'teacher', 'learner', 'journalist', 'creator') THEN
    profile_role := meta_role;
  ELSE
    profile_role := 'learner';
  END IF;

  IF profile_role IN ('learner', 'admin', 'journalist', 'creator') THEN
    profile_status := 'approved';
  ELSE
    profile_status := 'pending';
  END IF;

  INSERT INTO public.profiles (id, email, full_name, phone, role, status)
  VALUES (
    NEW.id,
    coalesce(NEW.email, ''),
    coalesce(NEW.raw_user_meta_data->>'full_name', ''),
    nullif(NEW.raw_user_meta_data->>'phone', ''),
    profile_role,
    profile_status
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM anon;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM authenticated;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_new_user();

-- Admin tool: Auth users that have no matching profiles row.
CREATE OR REPLACE FUNCTION public.list_auth_users_without_profiles()
RETURNS TABLE (
  id uuid,
  email text,
  created_at timestamptz,
  last_sign_in_at timestamptz,
  email_confirmed_at timestamptz,
  full_name text,
  meta_role text,
  phone text
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    u.id,
    u.email::text,
    u.created_at,
    u.last_sign_in_at,
    u.email_confirmed_at,
    u.raw_user_meta_data->>'full_name',
    u.raw_user_meta_data->>'role',
    u.raw_user_meta_data->>'phone'
  FROM auth.users u
  LEFT JOIN public.profiles p ON p.id = u.id
  WHERE p.id IS NULL
  ORDER BY u.created_at DESC;
$$;

REVOKE ALL ON FUNCTION public.list_auth_users_without_profiles() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.list_auth_users_without_profiles() FROM anon;
REVOKE ALL ON FUNCTION public.list_auth_users_without_profiles() FROM authenticated;
GRANT EXECUTE ON FUNCTION public.list_auth_users_without_profiles() TO service_role;
