/*
  # Bucket Storage tcf-co-audios

  Fichiers audio des questions TCF Compréhension Orale.

  Convention de chemin (obligatoire pour les policies) :
    {session_id}/{filename}.mp3|wav|m4a

  Exemple :
    a1b2c3d4-.../question-03.mp3

  Accès :
  - INSERT / UPDATE / DELETE : teacher (sur ses sessions) ou admin
  - SELECT :
      * session statut = 'publiee' → tout utilisateur authentifié
      * brouillon → teacher propriétaire (created_by) ou admin
*/

-- ---------------------------------------------------------------------------
-- Bucket (privé : les URLs publiques ne contournent pas le RLS)
-- ---------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'tcf-co-audios',
  'tcf-co-audios',
  false,
  10485760, -- 10 Mo
  ARRAY[
    'audio/mpeg',
    'audio/mp3',
    'audio/wav',
    'audio/x-wav',
    'audio/wave',
    'audio/mp4',
    'audio/m4a',
    'audio/x-m4a'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ---------------------------------------------------------------------------
-- Policies storage.objects
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "tcf_co_audios_select" ON storage.objects;
DROP POLICY IF EXISTS "tcf_co_audios_insert" ON storage.objects;
DROP POLICY IF EXISTS "tcf_co_audios_update" ON storage.objects;
DROP POLICY IF EXISTS "tcf_co_audios_delete" ON storage.objects;

-- Lecture : session publiée (tous les connectés) OU propriétaire/admin (même brouillon)
CREATE POLICY "tcf_co_audios_select" ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'tcf-co-audios'
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

-- Upload : teacher sur une session qu'il a créée, ou admin
CREATE POLICY "tcf_co_audios_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'tcf-co-audios'
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

CREATE POLICY "tcf_co_audios_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'tcf-co-audios'
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
    bucket_id = 'tcf-co-audios'
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

CREATE POLICY "tcf_co_audios_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'tcf-co-audios'
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
