/*
  Teacher → learner module assignments with 1-month access window.
*/

CREATE TABLE IF NOT EXISTS elearning_module_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid NOT NULL REFERENCES elearning_modules(id) ON DELETE CASCADE,
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  teacher_id uuid NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
  start_date date NOT NULL DEFAULT CURRENT_DATE,
  end_date date GENERATED ALWAYS AS ((start_date + INTERVAL '1 month')::date) STORED,
  created_at timestamptz DEFAULT now(),
  UNIQUE (module_id, learner_id)
);

CREATE INDEX IF NOT EXISTS idx_elearning_module_assignments_learner
  ON elearning_module_assignments (learner_id);
CREATE INDEX IF NOT EXISTS idx_elearning_module_assignments_teacher
  ON elearning_module_assignments (teacher_id);
CREATE INDEX IF NOT EXISTS idx_elearning_module_assignments_module
  ON elearning_module_assignments (module_id);

ALTER TABLE elearning_module_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can read own module assignments"
  ON elearning_module_assignments FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

CREATE POLICY "Teachers can insert own module assignments"
  ON elearning_module_assignments FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
    AND EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id
        AND m.teacher_id = teacher_id
        AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can delete own module assignments"
  ON elearning_module_assignments FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Learners can read own module assignments"
  ON elearning_module_assignments FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM learners l
      WHERE l.id = learner_id AND l.profile_id = auth.uid()
    )
  );
