-- Allow teachers to manage enrollments on their own modules
-- and to read learner profiles (name/email) for the Learners page.

CREATE POLICY "Teachers can insert enrollments on own modules"
  ON elearning_enrollments FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Teachers can delete enrollments on own modules"
  ON elearning_enrollments FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Teachers/schools need learner names & emails for enrollment UI
DROP POLICY IF EXISTS "Teachers and schools can read learner profiles" ON profiles;
CREATE POLICY "Teachers and schools can read learner profiles"
  ON profiles FOR SELECT TO authenticated
  USING (
    role = 'learner'
    AND EXISTS (
      SELECT 1 FROM profiles me
      WHERE me.id = auth.uid()
        AND me.role IN ('teacher', 'school')
    )
  );
