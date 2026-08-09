/*
  # TCF CO — 39 questions + image optionnelle

  1. ordre : CHECK BETWEEN 1 AND 39
  2. tcf_co_questions.image_url (nullable)
  3. barème C2 : score_max 40 → 39
  4. Vue tcf_co_questions_pour_apprenants : + image_url (DROP + CREATE)
  5. Bucket privé tcf-co-images (jpg/png, 5 Mo)
*/

-- ---------------------------------------------------------------------------
-- 1. Contrainte ordre (1–39)
-- ---------------------------------------------------------------------------
ALTER TABLE public.tcf_co_questions
  DROP CONSTRAINT IF EXISTS tcf_co_questions_ordre_check;

ALTER TABLE public.tcf_co_questions
  ADD CONSTRAINT tcf_co_questions_ordre_check
  CHECK (ordre BETWEEN 1 AND 39);

-- ---------------------------------------------------------------------------
-- 2. image_url optionnelle
-- ---------------------------------------------------------------------------
ALTER TABLE public.tcf_co_questions
  ADD COLUMN IF NOT EXISTS image_url text;

-- ---------------------------------------------------------------------------
-- 3. Barème C2 : 32–39
-- ---------------------------------------------------------------------------
UPDATE public.tcf_co_baremes
SET score_max = 39
WHERE niveau = 'C2'
  AND score_min = 32
  AND score_max = 40;

-- ---------------------------------------------------------------------------
-- 4. Vue apprenants (+ image_url, sans bonne_reponse)
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS public.tcf_co_questions_pour_apprenants;

CREATE VIEW public.tcf_co_questions_pour_apprenants
WITH (security_invoker = false) AS
SELECT
  q.id,
  q.session_id,
  q.ordre,
  q.niveau,
  q.audio_url,
  q.image_url,
  q.question_texte,
  q.choix_a,
  q.choix_b,
  q.choix_c,
  q.choix_d,
  q.created_at
FROM public.tcf_co_questions q
INNER JOIN public.tcf_co_sessions s ON s.id = q.session_id
WHERE s.statut = 'publiee';

REVOKE ALL ON public.tcf_co_questions_pour_apprenants FROM PUBLIC;
GRANT SELECT ON public.tcf_co_questions_pour_apprenants TO authenticated;

-- ---------------------------------------------------------------------------
-- 5. Bucket Storage tcf-co-images (privé, images, 5 Mo)
--    Chemin : {session_id}/{filename}.jpg|jpeg|png
-- ---------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'tcf-co-images',
  'tcf-co-images',
  false,
  5242880, -- 5 Mo
  ARRAY[
    'image/jpeg',
    'image/jpg',
    'image/png'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "tcf_co_images_select" ON storage.objects;
DROP POLICY IF EXISTS "tcf_co_images_insert" ON storage.objects;
DROP POLICY IF EXISTS "tcf_co_images_update" ON storage.objects;
DROP POLICY IF EXISTS "tcf_co_images_delete" ON storage.objects;

CREATE POLICY "tcf_co_images_select" ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'tcf-co-images'
    AND (
      EXISTS (
        SELECT 1
        FROM public.tcf_co_sessions s
        WHERE s.id::text = (storage.foldername(name))[1]
          AND (
            s.statut = 'publiee'
            OR s.created_by = auth.uid()
            OR EXISTS (
              SELECT 1 FROM public.profiles p
              WHERE p.id = auth.uid() AND p.role = 'admin'
            )
          )
      )
    )
  );

CREATE POLICY "tcf_co_images_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'tcf-co-images'
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
      )
      OR EXISTS (
        SELECT 1
        FROM public.tcf_co_sessions s
        JOIN public.profiles p ON p.id = auth.uid()
        WHERE s.id::text = (storage.foldername(name))[1]
          AND s.created_by = auth.uid()
          AND p.role = 'teacher'
      )
    )
  );

CREATE POLICY "tcf_co_images_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'tcf-co-images'
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
      )
      OR EXISTS (
        SELECT 1
        FROM public.tcf_co_sessions s
        JOIN public.profiles p ON p.id = auth.uid()
        WHERE s.id::text = (storage.foldername(name))[1]
          AND s.created_by = auth.uid()
          AND p.role = 'teacher'
      )
    )
  )
  WITH CHECK (
    bucket_id = 'tcf-co-images'
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
      )
      OR EXISTS (
        SELECT 1
        FROM public.tcf_co_sessions s
        JOIN public.profiles p ON p.id = auth.uid()
        WHERE s.id::text = (storage.foldername(name))[1]
          AND s.created_by = auth.uid()
          AND p.role = 'teacher'
      )
    )
  );

CREATE POLICY "tcf_co_images_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'tcf-co-images'
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
      )
      OR EXISTS (
        SELECT 1
        FROM public.tcf_co_sessions s
        JOIN public.profiles p ON p.id = auth.uid()
        WHERE s.id::text = (storage.foldername(name))[1]
          AND s.created_by = auth.uid()
          AND p.role = 'teacher'
      )
    )
  );

NOTIFY pgrst, 'reload schema';
