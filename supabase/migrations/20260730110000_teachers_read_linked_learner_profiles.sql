/*
  Allow teachers to read full_name/email of learners they are linked to
  or have assigned a module to. Without this, nested profiles embeds
  return null and the UI falls back to the generic label "Apprenant".
*/

DROP POLICY IF EXISTS "Teachers can read linked learner profiles" ON profiles;

CREATE POLICY "Teachers can read linked learner profiles"
  ON profiles FOR SELECT TO authenticated
  USING (
    role = 'learner'
    AND EXISTS (
      SELECT 1
      FROM teachers t
      JOIN learners l ON l.profile_id = profiles.id
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
  );
