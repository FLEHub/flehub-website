/*
  Simple school-managed student roster.

  School admins register pupils in this table with first and last name only.
  These records are intentionally separate from auth users and do not require
  email addresses or passwords.
*/

CREATE OR REPLACE FUNCTION public.current_school_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT s.id
  FROM public.schools s
  WHERE s.profile_id = auth.uid()
  LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.current_school_id() TO authenticated;

CREATE TABLE IF NOT EXISTS public.school_students (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  first_name text NOT NULL CHECK (char_length(btrim(first_name)) > 0),
  last_name text NOT NULL CHECK (char_length(btrim(last_name)) > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_school_students_school_id
  ON public.school_students(school_id);

CREATE INDEX IF NOT EXISTS idx_school_students_school_name
  ON public.school_students(school_id, last_name, first_name);

ALTER TABLE public.school_students ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "School admins can read own school students" ON public.school_students;
CREATE POLICY "School admins can read own school students"
  ON public.school_students FOR SELECT TO authenticated
  USING (school_id = public.current_school_id());

DROP POLICY IF EXISTS "School admins can insert own school students" ON public.school_students;
CREATE POLICY "School admins can insert own school students"
  ON public.school_students FOR INSERT TO authenticated
  WITH CHECK (school_id = public.current_school_id());

DROP POLICY IF EXISTS "School admins can update own school students" ON public.school_students;
CREATE POLICY "School admins can update own school students"
  ON public.school_students FOR UPDATE TO authenticated
  USING (school_id = public.current_school_id())
  WITH CHECK (school_id = public.current_school_id());

DROP POLICY IF EXISTS "School admins can delete own school students" ON public.school_students;
CREATE POLICY "School admins can delete own school students"
  ON public.school_students FOR DELETE TO authenticated
  USING (school_id = public.current_school_id());
