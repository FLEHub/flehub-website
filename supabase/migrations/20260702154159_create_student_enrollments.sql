
CREATE TABLE IF NOT EXISTS student_enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES school_students(id) ON DELETE CASCADE,
  exam_session_id uuid NOT NULL REFERENCES exam_sessions(id) ON DELETE CASCADE,
  active boolean NOT NULL DEFAULT true,
  cefr_level text CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  enrolled_at timestamptz DEFAULT now(),
  UNIQUE(student_id, exam_session_id)
);

ALTER TABLE student_enrollments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "student_enroll_select" ON student_enrollments FOR SELECT
  TO authenticated USING (
    EXISTS (
      SELECT 1 FROM school_students ss
      JOIN schools sc ON sc.id = ss.school_id
      WHERE ss.id = student_id AND sc.profile_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "student_enroll_insert" ON student_enrollments FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (
      SELECT 1 FROM school_students ss
      JOIN schools sc ON sc.id = ss.school_id
      WHERE ss.id = student_id AND sc.profile_id = auth.uid()
    )
  );

CREATE POLICY "student_enroll_update" ON student_enrollments FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM school_students ss
      JOIN schools sc ON sc.id = ss.school_id
      WHERE ss.id = student_id AND sc.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM school_students ss
      JOIN schools sc ON sc.id = ss.school_id
      WHERE ss.id = student_id AND sc.profile_id = auth.uid()
    )
  );
