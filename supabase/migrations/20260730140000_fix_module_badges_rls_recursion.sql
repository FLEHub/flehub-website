/*
  Fix infinite RLS recursion between elearning_modules and elearning_module_badges.

  PR #52 added policy "Learners can read modules with own badges" which SELECTs
  elearning_module_badges. Badge SELECT/INSERT policies in turn SELECT
  elearning_modules. Postgres evaluates ALL SELECT policies → cycle →
  "infinite recursion detected in policy for relation elearning_modules"
  which makes every UI module list return empty (caught as failed queries).

  Break the cycle with SECURITY DEFINER helpers (same pattern as
  teacher_owns_elearning_exercise).
*/

CREATE OR REPLACE FUNCTION public.learner_has_module_badge(p_module_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM elearning_module_badges b
    JOIN learners l ON l.id = b.learner_id
    WHERE b.module_id = p_module_id
      AND l.profile_id = auth.uid()
  );
$$;

REVOKE ALL ON FUNCTION public.learner_has_module_badge(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.learner_has_module_badge(uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.teacher_owns_elearning_module(p_module_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM elearning_modules m
    JOIN teachers t ON t.id = m.teacher_id
    WHERE m.id = p_module_id
      AND t.profile_id = auth.uid()
  );
$$;

REVOKE ALL ON FUNCTION public.teacher_owns_elearning_module(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.teacher_owns_elearning_module(uuid) TO authenticated;

-- Rewrite module policy: no direct SELECT on badges under RLS
DROP POLICY IF EXISTS "Learners can read modules with own badges" ON elearning_modules;
CREATE POLICY "Learners can read modules with own badges"
  ON elearning_modules FOR SELECT TO authenticated
  USING (public.learner_has_module_badge(id));

-- Rewrite badge policies: no direct SELECT on modules under RLS
DROP POLICY IF EXISTS "Teachers can insert module badges for own modules"
  ON elearning_module_badges;
CREATE POLICY "Teachers can insert module badges for own modules"
  ON elearning_module_badges FOR INSERT TO authenticated
  WITH CHECK (public.teacher_owns_elearning_module(module_id));

DROP POLICY IF EXISTS "Teachers can read module badges of own modules"
  ON elearning_module_badges;
CREATE POLICY "Teachers can read module badges of own modules"
  ON elearning_module_badges FOR SELECT TO authenticated
  USING (
    public.teacher_owns_elearning_module(module_id)
    OR EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );
