-- Create the admin-assets bucket (logo + signature uploads) if it does not exist.
-- Public so getPublicUrl() works for certificate branding assets.
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'admin-assets',
  'admin-assets',
  true,
  NULL,
  ARRAY['image/png', 'image/jpeg']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Idempotent RLS: admin can INSERT / UPDATE / SELECT on this bucket.
-- (DROP + CREATE so this file is safe to re-run in the SQL editor.)
DROP POLICY IF EXISTS "admin_assets_select" ON storage.objects;
DROP POLICY IF EXISTS "admin_assets_insert" ON storage.objects;
DROP POLICY IF EXISTS "admin_assets_update" ON storage.objects;
DROP POLICY IF EXISTS "admin_assets_delete" ON storage.objects;

CREATE POLICY "admin_assets_select" ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'admin-assets'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "admin_assets_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'admin-assets'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "admin_assets_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'admin-assets'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  )
  WITH CHECK (
    bucket_id = 'admin-assets'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "admin_assets_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'admin-assets'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
