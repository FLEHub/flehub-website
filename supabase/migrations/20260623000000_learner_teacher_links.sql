/*
  Learner ↔ teacher links (learner chooses teachers)
  + RLS so learners can browse teachers and their profiles
*/

CREATE TABLE IF NOT EXISTS learner_teacher_links (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  teacher_id uuid NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE (learner_id, teacher_id)
);

ALTER TABLE learner_teacher_links ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can read own teacher links"
  ON learner_teacher_links FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Learners can insert own teacher links"
  ON learner_teacher_links FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Learners can delete own teacher links"
  ON learner_teacher_links FOR DELETE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can read links to themselves"
  ON learner_teacher_links FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE INDEX IF NOT EXISTS idx_learner_teacher_links_learner ON learner_teacher_links(learner_id);
CREATE INDEX IF NOT EXISTS idx_learner_teacher_links_teacher ON learner_teacher_links(teacher_id);

-- Learners need to browse the teachers directory
DROP POLICY IF EXISTS "Learners can read teachers" ON teachers;
CREATE POLICY "Learners can read teachers"
  ON teachers FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('learner', 'admin'))
  );

-- Learners need teacher names (profiles.role = teacher)
DROP POLICY IF EXISTS "Learners can read teacher profiles" ON profiles;
CREATE POLICY "Learners can read teacher profiles"
  ON profiles FOR SELECT TO authenticated
  USING (
    role = 'teacher'
    AND EXISTS (
      SELECT 1 FROM profiles me
      WHERE me.id = auth.uid() AND me.role = 'learner'
    )
  );
