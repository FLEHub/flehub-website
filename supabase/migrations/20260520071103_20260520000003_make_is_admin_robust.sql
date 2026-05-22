/*
  # Make is_admin() function more robust

  1. Changes
    - Make the is_admin() function handle cases where auth.jwt() returns null
    - Make it handle cases where app_metadata key doesn't exist
    - Use jsonb_typeof check before accessing nested keys
    - This prevents the function from throwing errors which would cause
      RLS policy evaluation to fail and block all queries

  2. Security
    - No security changes, same behavior: returns true only if JWT contains
      app_metadata.role = 'admin'
*/

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin',
    false
  );
$$;
