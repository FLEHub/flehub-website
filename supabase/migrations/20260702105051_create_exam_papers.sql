
CREATE TABLE IF NOT EXISTS exam_papers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_session_id uuid NOT NULL REFERENCES exam_sessions(id) ON DELETE CASCADE,
  competency text NOT NULL CHECK (competency IN ('EO', 'EE', 'CO', 'CE', 'LANGUE')),
  file_path text,
  audio_path text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE (exam_session_id, competency)
);

ALTER TABLE exam_papers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "select_exam_papers" ON exam_papers FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "insert_exam_papers" ON exam_papers FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "update_exam_papers" ON exam_papers FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "delete_exam_papers" ON exam_papers FOR DELETE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
