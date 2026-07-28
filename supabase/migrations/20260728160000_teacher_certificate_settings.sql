/*
  Teacher certificate settings:
  - teachers.certificate_name
  - teachers.signature_path
  - storage bucket teacher-signatures
*/

ALTER TABLE teachers
  ADD COLUMN IF NOT EXISTS certificate_name text;

ALTER TABLE teachers
  ADD COLUMN IF NOT EXISTS signature_path text;

COMMENT ON COLUMN teachers.certificate_name IS 'Display name used on certificates issued by this teacher';
COMMENT ON COLUMN teachers.signature_path IS 'Path in teacher-signatures bucket, e.g. {teacherId}/signature.png';

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'teacher-signatures',
  'teacher-signatures',
  false,
  5242880,
  ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "teacher_signatures_select" ON storage.objects;
DROP POLICY IF EXISTS "teacher_signatures_insert" ON storage.objects;
DROP POLICY IF EXISTS "teacher_signatures_update" ON storage.objects;
DROP POLICY IF EXISTS "teacher_signatures_delete" ON storage.objects;

-- Teachers can read their own folder; admins can read all (for future cert generation).
CREATE POLICY "teacher_signatures_select" ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'teacher-signatures'
    AND (
      (storage.foldername(name))[1] IN (
        SELECT id::text FROM teachers WHERE profile_id = auth.uid()
      )
      OR EXISTS (
        SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
      )
    )
  );

CREATE POLICY "teacher_signatures_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'teacher-signatures'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM teachers WHERE profile_id = auth.uid()
    )
  );

CREATE POLICY "teacher_signatures_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'teacher-signatures'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM teachers WHERE profile_id = auth.uid()
    )
  )
  WITH CHECK (
    bucket_id = 'teacher-signatures'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM teachers WHERE profile_id = auth.uid()
    )
  );

CREATE POLICY "teacher_signatures_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'teacher-signatures'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM teachers WHERE profile_id = auth.uid()
    )
  );
