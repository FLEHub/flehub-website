-- Diagnostic queries for certificate PDF Storage RLS.
-- Run in Supabase SQL Editor while logged in as a school user is NOT possible;
-- instead use "role simulation" below with a real school profile UUID.
--
-- Replace :school_profile_id with the auth.users.id of a school account.

-- 1) Inspect active storage policies on school-assets
SELECT policyname, cmd, roles, qual, with_check
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND (
    policyname ILIKE '%school_asset%'
    OR policyname ILIKE '%certificate%'
    OR with_check ILIKE '%school-assets%'
    OR qual ILIKE '%school-assets%'
  )
ORDER BY policyname;

-- 2) Bucket mime allow-list (PDF must be present)
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets
WHERE id IN ('school-assets', 'certificates');

-- 3) Simulate authenticated school JWT claims
--    (paste a real school profile UUID)
-- BEGIN;
-- SELECT set_config('request.jwt.claim.sub', '<school_profile_uuid>', true);
-- SELECT set_config('request.jwt.claim.role', 'authenticated', true);
-- SET LOCAL ROLE authenticated;
--
-- SELECT auth.uid() AS uid,
--        public.current_school_id() AS school_id,
--        public.is_admin() AS is_admin,
--        EXISTS (SELECT 1 FROM schools WHERE profile_id = auth.uid()) AS exists_school_as_invoker;
--
-- -- Legacy path (should pass NEW certificates policies / fail old school_id-only policies)
-- EXPLAIN (FORMAT TEXT)
-- INSERT INTO storage.objects (bucket_id, name, owner, metadata)
-- VALUES ('school-assets', 'certificates/DIAG-TEST.pdf', auth.uid(), '{}'::jsonb);
--
-- -- Preferred path (should pass school_id-scoped policies)
-- EXPLAIN (FORMAT TEXT)
-- INSERT INTO storage.objects (bucket_id, name, owner, metadata)
-- VALUES (
--   'school-assets',
--   public.current_school_id()::text || '/certificates/DIAG-TEST.pdf',
--   auth.uid(),
--   '{}'::jsonb
-- );
-- ROLLBACK;

-- 4) Confirm school_certificates UPDATE policy exists
SELECT policyname, cmd, roles, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'school_certificates'
ORDER BY policyname;
