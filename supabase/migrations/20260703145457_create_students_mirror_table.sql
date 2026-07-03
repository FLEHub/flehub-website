
CREATE TABLE IF NOT EXISTS students (
  id uuid PRIMARY KEY,
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  first_name text NOT NULL,
  last_name text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE students ENABLE ROW LEVEL SECURITY;

CREATE POLICY "students_select" ON students FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM schools sc WHERE sc.id = school_id AND sc.profile_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "students_insert" ON students FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM schools sc WHERE sc.id = school_id AND sc.profile_id = auth.uid())
  );

CREATE POLICY "students_update" ON students FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM schools sc WHERE sc.id = school_id AND sc.profile_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM schools sc WHERE sc.id = school_id AND sc.profile_id = auth.uid()));
