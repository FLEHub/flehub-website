
-- School students table (pupils enrolled by a school directly, name only)
CREATE TABLE IF NOT EXISTS school_students (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  first_name text NOT NULL,
  last_name text NOT NULL,
  date_of_birth date,
  cefr_level text CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE school_students ENABLE ROW LEVEL SECURITY;

CREATE POLICY "school_students_select" ON school_students FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "school_students_insert" ON school_students FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid())
  );

CREATE POLICY "school_students_update" ON school_students FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid()));

CREATE POLICY "school_students_delete" ON school_students FOR DELETE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid())
  );

-- Exam result drafts: school enters scores per student per competency
CREATE TABLE IF NOT EXISTS exam_result_drafts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  school_student_id uuid NOT NULL REFERENCES school_students(id) ON DELETE CASCADE,
  exam_session_id uuid NOT NULL REFERENCES exam_sessions(id) ON DELETE CASCADE,
  score_eo numeric(5,2),
  score_ee numeric(5,2),
  score_co numeric(5,2),
  score_ce numeric(5,2),
  score_langue numeric(5,2),
  total_score numeric(5,2) GENERATED ALWAYS AS (
    COALESCE(score_eo, 0) + COALESCE(score_ee, 0) +
    COALESCE(score_co, 0) + COALESCE(score_ce, 0) +
    COALESCE(score_langue, 0)
  ) STORED,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'validated', 'rejected')),
  admin_notes text,
  submitted_at timestamptz,
  validated_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(school_student_id, exam_session_id)
);

ALTER TABLE exam_result_drafts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "result_drafts_select" ON exam_result_drafts FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "result_drafts_insert" ON exam_result_drafts FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid())
  );

CREATE POLICY "result_drafts_update" ON exam_result_drafts FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid()));

CREATE POLICY "result_drafts_delete" ON exam_result_drafts FOR DELETE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid())
  );

-- School settings (examiner name, signature, logo paths)
CREATE TABLE IF NOT EXISTS school_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL UNIQUE REFERENCES schools(id) ON DELETE CASCADE,
  examiner_name text,
  examiner_signature_path text,
  school_logo_path text,
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE school_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "school_settings_select" ON school_settings FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "school_settings_insert" ON school_settings FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid())
  );

CREATE POLICY "school_settings_update" ON school_settings FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid()));

-- School certificates (for school_students who passed + admin validated)
CREATE TABLE IF NOT EXISTS school_certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  school_student_id uuid NOT NULL REFERENCES school_students(id) ON DELETE CASCADE,
  exam_result_draft_id uuid NOT NULL REFERENCES exam_result_drafts(id) ON DELETE CASCADE,
  certificate_number text UNIQUE NOT NULL,
  cefr_level text NOT NULL CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  issue_date date DEFAULT CURRENT_DATE,
  pdf_path text,
  created_at timestamptz DEFAULT now(),
  UNIQUE(school_student_id, exam_result_draft_id)
);

ALTER TABLE school_certificates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "school_certs_select" ON school_certificates FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "school_certs_insert" ON school_certificates FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid())
  );
