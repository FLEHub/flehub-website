/*
  Learners assigned a module (elearning_module_assignments) could see it on
  the dashboard but not open it:

  - elearning_modules / sequences / lessons / exercises SELECT for learners
    required published = true
  - learner catalog listed only published modules of linked teachers
  - module page used .single() → PGRST116 when RLS returned 0 rows
  - assignment did not create elearning_enrollments (teachers had no INSERT)

  Assigned learners may read that module's content even as a draft, and
  teachers may enroll the learner when assigning.
*/

CREATE OR REPLACE FUNCTION public.learner_has_module_assignment(p_module_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM elearning_module_assignments a
    JOIN learners l ON l.id = a.learner_id
    WHERE a.module_id = p_module_id
      AND l.profile_id = auth.uid()
  );
$$;

REVOKE ALL ON FUNCTION public.learner_has_module_assignment(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.learner_has_module_assignment(uuid) TO authenticated;

DROP POLICY IF EXISTS "Learners can read assigned elearning modules" ON elearning_modules;
CREATE POLICY "Learners can read assigned elearning modules"
  ON elearning_modules FOR SELECT TO authenticated
  USING (public.learner_has_module_assignment(id));

DROP POLICY IF EXISTS "Learners can read sequences of assigned modules" ON elearning_sequences;
CREATE POLICY "Learners can read sequences of assigned modules"
  ON elearning_sequences FOR SELECT TO authenticated
  USING (public.learner_has_module_assignment(module_id));

DROP POLICY IF EXISTS "Learners can read lessons of assigned modules" ON elearning_lessons;
CREATE POLICY "Learners can read lessons of assigned modules"
  ON elearning_lessons FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM elearning_sequences s
      WHERE s.id = sequence_id
        AND public.learner_has_module_assignment(s.module_id)
    )
  );

DROP POLICY IF EXISTS "Learners can read exercises of assigned modules" ON elearning_exercises;
CREATE POLICY "Learners can read exercises of assigned modules"
  ON elearning_exercises FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM elearning_lessons l
      JOIN elearning_sequences s ON s.id = l.sequence_id
      WHERE l.id = lesson_id
        AND public.learner_has_module_assignment(s.module_id)
    )
  );

DROP POLICY IF EXISTS "Learners can enroll in assigned modules" ON elearning_enrollments;
CREATE POLICY "Learners can enroll in assigned modules"
  ON elearning_enrollments FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
    AND public.learner_has_module_assignment(module_id)
  );

DROP POLICY IF EXISTS "Teachers can enroll learners on own modules" ON elearning_enrollments;
CREATE POLICY "Teachers can enroll learners on own modules"
  ON elearning_enrollments FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id
        AND t.profile_id = auth.uid()
    )
  );

-- Existing assignments were created without an enrollment row.
INSERT INTO elearning_enrollments (module_id, learner_id)
SELECT a.module_id, a.learner_id
FROM elearning_module_assignments a
ON CONFLICT (module_id, learner_id) DO NOTHING;
