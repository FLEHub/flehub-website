-- Fix certificate PDF uploads to bucket school-assets.
--
-- Root causes:
-- 1) Upload path was `certificates/{number}.pdf`, but the working school-assets
--    write policies require the FIRST folder to be the school UUID
--    (see "Schools manage own school assets" / school_assets_insert).
-- 2) Policies that used EXISTS (SELECT 1 FROM schools WHERE profile_id = auth.uid())
--    are fragile under Storage RLS because the subquery is subject to schools RLS;
--    prefer public.current_school_id() (SECURITY DEFINER).
-- 3) school-assets may only allow image MIME types; PDFs must be permitted.
-- 4) school_certificates lacked a reliable UPDATE policy for saving pdf_path.

-- ---------------------------------------------------------------------------
-- Bucket: allow PDF (and keep existing image types for logos/signatures)
-- ---------------------------------------------------------------------------
UPDATE storage.buckets
SET allowed_mime_types = ARRAY[
  'image/png',
  'image/jpeg',
  'image/webp',
  'application/pdf'
]::text[],
file_size_limit = GREATEST(COALESCE(file_size_limit, 0), 10485760)
WHERE id = 'school-assets';

-- ---------------------------------------------------------------------------
-- Storage policies for certificate PDFs
-- ---------------------------------------------------------------------------
-- Preferred path (app code): {school_id}/certificates/{certificate_number}.pdf
-- Already covered by school_id-scoped policies. Keep a robust fallback for the
-- legacy prefix certificates/{certificate_number}.pdf as well.

DROP POLICY IF EXISTS "school_assets_certificates_insert" ON storage.objects;
CREATE POLICY "school_assets_certificates_insert"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'school-assets'
    AND public.current_school_id() IS NOT NULL
    AND (
      (storage.foldername(name))[1] = 'certificates'
      OR (
        (storage.foldername(name))[1] = public.current_school_id()::text
        AND (storage.foldername(name))[2] = 'certificates'
      )
    )
  );

DROP POLICY IF EXISTS "school_assets_certificates_update" ON storage.objects;
CREATE POLICY "school_assets_certificates_update"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'school-assets'
    AND public.current_school_id() IS NOT NULL
    AND (
      (storage.foldername(name))[1] = 'certificates'
      OR (
        (storage.foldername(name))[1] = public.current_school_id()::text
        AND (storage.foldername(name))[2] = 'certificates'
      )
    )
  )
  WITH CHECK (
    bucket_id = 'school-assets'
    AND public.current_school_id() IS NOT NULL
    AND (
      (storage.foldername(name))[1] = 'certificates'
      OR (
        (storage.foldername(name))[1] = public.current_school_id()::text
        AND (storage.foldername(name))[2] = 'certificates'
      )
    )
  );

-- ---------------------------------------------------------------------------
-- Allow schools to persist pdf_path after a successful upload
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "school_certs_update" ON public.school_certificates;
CREATE POLICY "school_certs_update"
  ON public.school_certificates
  FOR UPDATE
  TO authenticated
  USING (
    school_id = public.current_school_id()
    OR EXISTS (
      SELECT 1 FROM public.schools s
      WHERE s.id = school_id AND s.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    school_id = public.current_school_id()
    OR EXISTS (
      SELECT 1 FROM public.schools s
      WHERE s.id = school_id AND s.profile_id = auth.uid()
    )
  );
