
CREATE POLICY "school_assets_select" ON storage.objects FOR SELECT
  TO authenticated USING (bucket_id = 'school-assets');

CREATE POLICY "school_assets_insert" ON storage.objects FOR INSERT
  TO authenticated WITH CHECK (
    bucket_id = 'school-assets'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM schools WHERE profile_id = auth.uid()
    )
  );

CREATE POLICY "school_assets_update" ON storage.objects FOR UPDATE
  TO authenticated USING (
    bucket_id = 'school-assets'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM schools WHERE profile_id = auth.uid()
    )
  );

CREATE POLICY "school_assets_delete" ON storage.objects FOR DELETE
  TO authenticated USING (
    bucket_id = 'school-assets'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM schools WHERE profile_id = auth.uid()
    )
  );
