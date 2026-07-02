
-- Storage RLS for admin-assets bucket
CREATE POLICY "admin_assets_select" ON storage.objects FOR SELECT
  TO authenticated USING (bucket_id = 'admin-assets');

CREATE POLICY "admin_assets_insert" ON storage.objects FOR INSERT
  TO authenticated WITH CHECK (
    bucket_id = 'admin-assets'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "admin_assets_update" ON storage.objects FOR UPDATE
  TO authenticated USING (
    bucket_id = 'admin-assets'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "admin_assets_delete" ON storage.objects FOR DELETE
  TO authenticated USING (
    bucket_id = 'admin-assets'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
