
CREATE TABLE IF NOT EXISTS school_exam_access (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  exam_session_id uuid NOT NULL REFERENCES exam_sessions(id) ON DELETE CASCADE,
  payment_id uuid REFERENCES payments(id),
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  paid_at timestamptz,
  UNIQUE (school_id, exam_session_id)
);

ALTER TABLE school_exam_access ENABLE ROW LEVEL SECURITY;

CREATE POLICY "school_exam_access_school_select" ON school_exam_access FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid())
  );

CREATE POLICY "school_exam_access_admin_select" ON school_exam_access FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "school_exam_access_admin_insert" ON school_exam_access FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "school_exam_access_admin_update" ON school_exam_access FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE INDEX IF NOT EXISTS idx_school_exam_access_school ON school_exam_access(school_id);
CREATE INDEX IF NOT EXISTS idx_school_exam_access_session ON school_exam_access(exam_session_id);
