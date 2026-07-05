
-- Allow school users to upload certificate PDFs under certificates/{certificate_number}.pdf
CREATE POLICY "school_assets_certificates_insert" ON storage.objects FOR INSERT
  TO authenticated WITH CHECK (
    bucket_id = 'school-assets'
    AND (storage.foldername(name))[1] = 'certificates'
    AND EXISTS (SELECT 1 FROM schools WHERE profile_id = auth.uid())
  );

CREATE POLICY "school_assets_certificates_update" ON storage.objects FOR UPDATE
  TO authenticated USING (
    bucket_id = 'school-assets'
    AND (storage.foldername(name))[1] = 'certificates'
    AND EXISTS (SELECT 1 FROM schools WHERE profile_id = auth.uid())
  );

-- Allow schools to update pdf_path on their own certificates
CREATE POLICY "school_certs_update" ON school_certificates FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM schools s WHERE s.id = school_id AND s.profile_id = auth.uid()));
