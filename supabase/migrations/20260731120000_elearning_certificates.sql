/*
  Level certificates for the individual (teacher-followed) learning path.
  Separate from school certificates / exam_results-linked certificates.
*/

CREATE TABLE IF NOT EXISTS elearning_certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  teacher_id uuid NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
  exam_score_id uuid NOT NULL REFERENCES elearning_level_exam_scores(id) ON DELETE CASCADE,
  level text NOT NULL CHECK (level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  certificate_number text UNIQUE NOT NULL,
  pdf_path text,
  issue_date date NOT NULL DEFAULT CURRENT_DATE,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (learner_id, level)
);

CREATE INDEX IF NOT EXISTS idx_elearning_certificates_learner
  ON elearning_certificates (learner_id);
CREATE INDEX IF NOT EXISTS idx_elearning_certificates_teacher
  ON elearning_certificates (teacher_id);
CREATE INDEX IF NOT EXISTS idx_elearning_certificates_exam_score
  ON elearning_certificates (exam_score_id);

COMMENT ON TABLE elearning_certificates IS
  'Level certificates for teacher-followed learners (outside school exam flow)';

ALTER TABLE elearning_certificates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can read own elearning certificates" ON elearning_certificates;
DROP POLICY IF EXISTS "Learners can read own elearning certificates" ON elearning_certificates;
DROP POLICY IF EXISTS "Teachers can insert elearning certificates" ON elearning_certificates;
DROP POLICY IF EXISTS "Teachers can update elearning certificates" ON elearning_certificates;
DROP POLICY IF EXISTS "Teachers can delete elearning certificates" ON elearning_certificates;
DROP POLICY IF EXISTS "Admins can manage elearning certificates" ON elearning_certificates;

CREATE POLICY "Teachers can read own elearning certificates"
  ON elearning_certificates FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM teachers t
      JOIN learner_teacher_links ltl ON ltl.teacher_id = t.id
      WHERE t.profile_id = auth.uid()
        AND ltl.learner_id = elearning_certificates.learner_id
    )
    OR EXISTS (
      SELECT 1 FROM teachers t
      JOIN elearning_module_assignments a ON a.teacher_id = t.id
      WHERE t.profile_id = auth.uid()
        AND a.learner_id = elearning_certificates.learner_id
    )
  );

CREATE POLICY "Learners can read own elearning certificates"
  ON elearning_certificates FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM learners l
      WHERE l.id = learner_id AND l.profile_id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage elearning certificates"
  ON elearning_certificates FOR ALL TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Teachers can insert elearning certificates"
  ON elearning_certificates FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
    AND (
      EXISTS (
        SELECT 1 FROM learner_teacher_links ltl
        WHERE ltl.teacher_id = teacher_id
          AND ltl.learner_id = elearning_certificates.learner_id
      )
      OR EXISTS (
        SELECT 1 FROM elearning_module_assignments a
        WHERE a.teacher_id = teacher_id
          AND a.learner_id = elearning_certificates.learner_id
      )
    )
  );

CREATE POLICY "Teachers can update elearning certificates"
  ON elearning_certificates FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM teachers t
      JOIN learner_teacher_links ltl ON ltl.teacher_id = t.id
      WHERE t.profile_id = auth.uid()
        AND ltl.learner_id = elearning_certificates.learner_id
    )
    OR EXISTS (
      SELECT 1 FROM teachers t
      JOIN elearning_module_assignments a ON a.teacher_id = t.id
      WHERE t.profile_id = auth.uid()
        AND a.learner_id = elearning_certificates.learner_id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can delete elearning certificates"
  ON elearning_certificates FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
  );

-- Storage bucket for PDFs: path {learnerId}/{level}.pdf
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'elearning-certificates',
  'elearning-certificates',
  false,
  10485760,
  ARRAY['application/pdf']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "elearning_certificates_select" ON storage.objects;
DROP POLICY IF EXISTS "elearning_certificates_insert" ON storage.objects;
DROP POLICY IF EXISTS "elearning_certificates_update" ON storage.objects;
DROP POLICY IF EXISTS "elearning_certificates_delete" ON storage.objects;

CREATE POLICY "elearning_certificates_select" ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'elearning-certificates'
    AND (
      (storage.foldername(name))[1] IN (
        SELECT l.id::text FROM learners l WHERE l.profile_id = auth.uid()
      )
      OR EXISTS (
        SELECT 1 FROM teachers t
        JOIN learner_teacher_links ltl ON ltl.teacher_id = t.id
        WHERE t.profile_id = auth.uid()
          AND ltl.learner_id::text = (storage.foldername(name))[1]
      )
      OR EXISTS (
        SELECT 1 FROM teachers t
        JOIN elearning_module_assignments a ON a.teacher_id = t.id
        WHERE t.profile_id = auth.uid()
          AND a.learner_id::text = (storage.foldername(name))[1]
      )
      OR EXISTS (
        SELECT 1 FROM elearning_certificates ec
        JOIN teachers t ON t.id = ec.teacher_id
        WHERE t.profile_id = auth.uid()
          AND ec.pdf_path = name
      )
      OR EXISTS (
        SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
      )
    )
  );

CREATE POLICY "elearning_certificates_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'elearning-certificates'
    AND (
      EXISTS (
        SELECT 1 FROM teachers t
        JOIN learner_teacher_links ltl ON ltl.teacher_id = t.id
        WHERE t.profile_id = auth.uid()
          AND ltl.learner_id::text = (storage.foldername(name))[1]
      )
      OR EXISTS (
        SELECT 1 FROM teachers t
        JOIN elearning_module_assignments a ON a.teacher_id = t.id
        WHERE t.profile_id = auth.uid()
          AND a.learner_id::text = (storage.foldername(name))[1]
      )
      OR EXISTS (
        SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
      )
    )
  );

CREATE POLICY "elearning_certificates_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'elearning-certificates'
    AND (
      EXISTS (
        SELECT 1 FROM teachers t
        JOIN learner_teacher_links ltl ON ltl.teacher_id = t.id
        WHERE t.profile_id = auth.uid()
          AND ltl.learner_id::text = (storage.foldername(name))[1]
      )
      OR EXISTS (
        SELECT 1 FROM teachers t
        JOIN elearning_module_assignments a ON a.teacher_id = t.id
        WHERE t.profile_id = auth.uid()
          AND a.learner_id::text = (storage.foldername(name))[1]
      )
      OR EXISTS (
        SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
      )
    )
  )
  WITH CHECK (
    bucket_id = 'elearning-certificates'
    AND (
      EXISTS (
        SELECT 1 FROM teachers t
        JOIN learner_teacher_links ltl ON ltl.teacher_id = t.id
        WHERE t.profile_id = auth.uid()
          AND ltl.learner_id::text = (storage.foldername(name))[1]
      )
      OR EXISTS (
        SELECT 1 FROM teachers t
        JOIN elearning_module_assignments a ON a.teacher_id = t.id
        WHERE t.profile_id = auth.uid()
          AND a.learner_id::text = (storage.foldername(name))[1]
      )
      OR EXISTS (
        SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
      )
    )
  );

CREATE POLICY "elearning_certificates_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'elearning-certificates'
    AND (
      EXISTS (
        SELECT 1 FROM teachers t
        JOIN learner_teacher_links ltl ON ltl.teacher_id = t.id
        WHERE t.profile_id = auth.uid()
          AND ltl.learner_id::text = (storage.foldername(name))[1]
      )
      OR EXISTS (
        SELECT 1 FROM teachers t
        JOIN elearning_module_assignments a ON a.teacher_id = t.id
        WHERE t.profile_id = auth.uid()
          AND a.learner_id::text = (storage.foldername(name))[1]
      )
      OR EXISTS (
        SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
      )
    )
  );

NOTIFY pgrst, 'reload schema';
