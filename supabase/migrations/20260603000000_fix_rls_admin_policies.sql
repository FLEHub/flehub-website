/*
  Fix RLS infinite recursion on profiles table.

  Policies that subquery profiles from within profiles (or any table) trigger
  recursive RLS evaluation. Use SECURITY DEFINER helpers instead.
*/

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
$$;

CREATE OR REPLACE FUNCTION public.has_role(roles text[])
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = ANY(roles)
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_role(text[]) TO authenticated;

-- profiles
DROP POLICY IF EXISTS "Admins can read all profiles" ON profiles;
CREATE POLICY "Admins can read all profiles"
  ON profiles FOR SELECT TO authenticated
  USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can update all profiles" ON profiles;
CREATE POLICY "Admins can update all profiles"
  ON profiles FOR UPDATE TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- schools
DROP POLICY IF EXISTS "Admins can read all schools" ON schools;
CREATE POLICY "Admins can read all schools"
  ON schools FOR SELECT TO authenticated
  USING (public.is_admin());

-- teachers
DROP POLICY IF EXISTS "Admins can read all teachers" ON teachers;
CREATE POLICY "Admins can read all teachers"
  ON teachers FOR SELECT TO authenticated
  USING (public.is_admin());

-- learners
DROP POLICY IF EXISTS "Admins and teachers can read learners" ON learners;
CREATE POLICY "Admins and teachers can read learners"
  ON learners FOR SELECT TO authenticated
  USING (public.has_role(ARRAY['admin', 'teacher', 'school']));

-- teacher_assignments
DROP POLICY IF EXISTS "Admins can manage assignments" ON teacher_assignments;
CREATE POLICY "Admins can manage assignments"
  ON teacher_assignments FOR SELECT TO authenticated
  USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can insert assignments" ON teacher_assignments;
CREATE POLICY "Admins can insert assignments"
  ON teacher_assignments FOR INSERT TO authenticated
  WITH CHECK (public.is_admin());

-- courses
DROP POLICY IF EXISTS "Learners can read published courses" ON courses;
CREATE POLICY "Learners can read published courses"
  ON courses FOR SELECT TO authenticated
  USING (is_published = true AND public.has_role(ARRAY['learner']));

-- exercises
DROP POLICY IF EXISTS "Learners can read published exercises" ON exercises;
CREATE POLICY "Learners can read published exercises"
  ON exercises FOR SELECT TO authenticated
  USING (is_published = true AND public.has_role(ARRAY['learner']));

-- exercise_questions
DROP POLICY IF EXISTS "Learners can read questions for published exercises" ON exercise_questions;
CREATE POLICY "Learners can read questions for published exercises"
  ON exercise_questions FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM exercises e
      WHERE e.id = exercise_id AND e.is_published = true
    )
    AND public.has_role(ARRAY['learner'])
  );

-- exam_sessions
DROP POLICY IF EXISTS "Admins can manage exam sessions" ON exam_sessions;
CREATE POLICY "Admins can manage exam sessions"
  ON exam_sessions FOR INSERT TO authenticated
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can update exam sessions" ON exam_sessions;
CREATE POLICY "Admins can update exam sessions"
  ON exam_sessions FOR UPDATE TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- exam_registrations
DROP POLICY IF EXISTS "Admins can read all registrations" ON exam_registrations;
CREATE POLICY "Admins can read all registrations"
  ON exam_registrations FOR SELECT TO authenticated
  USING (public.is_admin());

-- exam_results
DROP POLICY IF EXISTS "Schools can insert results for their pupils" ON exam_results;
CREATE POLICY "Schools can insert results for their pupils"
  ON exam_results FOR INSERT TO authenticated
  WITH CHECK (public.has_role(ARRAY['school', 'admin']));

DROP POLICY IF EXISTS "Admins can manage all results" ON exam_results;
CREATE POLICY "Admins can manage all results"
  ON exam_results FOR SELECT TO authenticated
  USING (public.has_role(ARRAY['admin', 'school', 'teacher']));

-- certificates
DROP POLICY IF EXISTS "Admins and schools can manage certificates" ON certificates;
CREATE POLICY "Admins and schools can manage certificates"
  ON certificates FOR SELECT TO authenticated
  USING (public.has_role(ARRAY['admin', 'school']));

DROP POLICY IF EXISTS "Admins can insert certificates" ON certificates;
CREATE POLICY "Admins can insert certificates"
  ON certificates FOR INSERT TO authenticated
  WITH CHECK (public.has_role(ARRAY['admin', 'school']));

-- live_sessions
DROP POLICY IF EXISTS "Learners can read sessions" ON live_sessions;
CREATE POLICY "Learners can read sessions"
  ON live_sessions FOR SELECT TO authenticated
  USING (public.has_role(ARRAY['learner']));

-- payments
DROP POLICY IF EXISTS "Admins can read all payments" ON payments;
CREATE POLICY "Admins can read all payments"
  ON payments FOR SELECT TO authenticated
  USING (public.is_admin());

-- notifications
DROP POLICY IF EXISTS "System can insert notifications" ON notifications;
CREATE POLICY "System can insert notifications"
  ON notifications FOR INSERT TO authenticated
  WITH CHECK (
    public.has_role(ARRAY['admin', 'teacher', 'school'])
    OR user_id = auth.uid()
  );

-- calendar_events
DROP POLICY IF EXISTS "Admins can manage events" ON calendar_events;
CREATE POLICY "Admins can manage events"
  ON calendar_events FOR INSERT TO authenticated
  WITH CHECK (public.is_admin());

-- learner_progress
DROP POLICY IF EXISTS "Teachers can read learner progress" ON learner_progress;
CREATE POLICY "Teachers can read learner progress"
  ON learner_progress FOR SELECT TO authenticated
  USING (public.has_role(ARRAY['teacher', 'admin']));
