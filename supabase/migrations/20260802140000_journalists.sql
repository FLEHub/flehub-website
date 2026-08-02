-- Widen profiles.role to include journalist
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles
  ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('admin', 'school', 'teacher', 'learner', 'journalist'));

-- Journalists extension table (mirrors teachers pattern)
CREATE TABLE IF NOT EXISTS journalists (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  bio text,
  avatar_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE journalists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Journalists can read own data"
  ON journalists FOR SELECT
  TO authenticated
  USING (profile_id = auth.uid());

CREATE POLICY "Journalists can update own data"
  ON journalists FOR UPDATE
  TO authenticated
  USING (profile_id = auth.uid())
  WITH CHECK (profile_id = auth.uid());

CREATE POLICY "Admins can manage journalists"
  ON journalists FOR ALL
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE INDEX IF NOT EXISTS idx_journalists_profile ON journalists(profile_id);

-- Public bucket for journalist avatars (same pattern as admin-assets)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'journalist-assets',
  'journalist-assets',
  true,
  5242880,
  ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "journalist_assets_select" ON storage.objects;
DROP POLICY IF EXISTS "journalist_assets_insert" ON storage.objects;
DROP POLICY IF EXISTS "journalist_assets_update" ON storage.objects;
DROP POLICY IF EXISTS "journalist_assets_delete" ON storage.objects;

CREATE POLICY "journalist_assets_select" ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'journalist-assets'
    AND (
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
      OR (storage.foldername(name))[1] = auth.uid()::text
    )
  );

CREATE POLICY "journalist_assets_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'journalist-assets'
    AND (
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
      OR (storage.foldername(name))[1] = auth.uid()::text
    )
  );

CREATE POLICY "journalist_assets_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'journalist-assets'
    AND (
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
      OR (storage.foldername(name))[1] = auth.uid()::text
    )
  )
  WITH CHECK (
    bucket_id = 'journalist-assets'
    AND (
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
      OR (storage.foldername(name))[1] = auth.uid()::text
    )
  );

CREATE POLICY "journalist_assets_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'journalist-assets'
    AND (
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
      OR (storage.foldername(name))[1] = auth.uid()::text
    )
  );
