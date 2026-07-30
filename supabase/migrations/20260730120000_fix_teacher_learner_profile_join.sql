/*
  Fix teachers reading learner profiles.full_name.

  The previous profiles RLS policy joined teachers/learners/links under RLS,
  which re-enters profiles policies and can silently yield null embeds —
  the UI then falls back to the generic label "Apprenant".

  Pattern: SECURITY DEFINER helper (see teacher_owns_elearning_exercise)
  so role/link checks do not recurse through profiles RLS.
*/

CREATE OR REPLACE FUNCTION public.current_profile_role()
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$;

REVOKE ALL ON FUNCTION public.current_profile_role() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.current_profile_role() TO authenticated;

CREATE OR REPLACE FUNCTION public.teacher_can_read_learner_profile(p_profile_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM teachers t
    JOIN learners l ON l.profile_id = p_profile_id
    WHERE t.profile_id = auth.uid()
      AND (
        EXISTS (
          SELECT 1
          FROM learner_teacher_links ltl
          WHERE ltl.teacher_id = t.id
            AND ltl.learner_id = l.id
        )
        OR EXISTS (
          SELECT 1
          FROM elearning_module_assignments a
          WHERE a.teacher_id = t.id
            AND a.learner_id = l.id
        )
      )
  )
  OR public.current_profile_role() IN ('admin', 'school');
$$;

REVOKE ALL ON FUNCTION public.teacher_can_read_learner_profile(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.teacher_can_read_learner_profile(uuid) TO authenticated;

-- Also expose identities in one call (authoritative source for the teacher UI)
CREATE OR REPLACE FUNCTION public.teacher_learner_identities(p_learner_ids uuid[])
RETURNS TABLE (
  learner_id uuid,
  full_name text,
  email text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    l.id AS learner_id,
    COALESCE(p.full_name, '') AS full_name,
    COALESCE(p.email, '') AS email
  FROM learners l
  JOIN profiles p ON p.id = l.profile_id
  WHERE l.id = ANY (p_learner_ids)
    AND (
      public.teacher_can_read_learner_profile(p.id)
      OR public.current_profile_role() = 'admin'
    );
$$;

REVOKE ALL ON FUNCTION public.teacher_learner_identities(uuid[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.teacher_learner_identities(uuid[]) TO authenticated;

DROP POLICY IF EXISTS "Teachers can read linked learner profiles" ON profiles;

CREATE POLICY "Teachers can read linked learner profiles"
  ON profiles FOR SELECT TO authenticated
  USING (
    role = 'learner'
    AND public.teacher_can_read_learner_profile(id)
  );
