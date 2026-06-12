/*
  Resource library for teacher lesson package uploads.
*/

CREATE TABLE IF NOT EXISTS public.resources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id uuid NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  type text NOT NULL CHECK (type IN ('pdf', 'audio', 'image', 'video')),
  subject text CHECK (
    subject IS NULL OR subject IN (
      'Grammaire',
      'Vocabulaire',
      'Expression orale',
      'Expression écrite',
      'Compréhension orale',
      'Compréhension écrite',
      'Phonétique',
      'Civilisation',
      'Préparation DELF/DALF'
    )
  ),
  level text CHECK (level IS NULL OR level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  file_path text NOT NULL,
  file_size bigint,
  file_name text,
  is_public boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can read own and public resources" ON public.resources;
CREATE POLICY "Teachers can read own and public resources"
  ON public.resources FOR SELECT TO authenticated
  USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
    OR (
      is_public = true
      AND public.has_role(ARRAY['teacher', 'admin'])
    )
  );

DROP POLICY IF EXISTS "Teachers can insert own resources" ON public.resources;
CREATE POLICY "Teachers can insert own resources"
  ON public.resources FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Teachers can update own resources" ON public.resources;
CREATE POLICY "Teachers can update own resources"
  ON public.resources FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Teachers can delete own resources" ON public.resources;
CREATE POLICY "Teachers can delete own resources"
  ON public.resources FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
  );

CREATE INDEX IF NOT EXISTS idx_resources_teacher ON public.resources(teacher_id);
CREATE INDEX IF NOT EXISTS idx_resources_public ON public.resources(is_public);
CREATE INDEX IF NOT EXISTS idx_resources_type ON public.resources(type);
CREATE INDEX IF NOT EXISTS idx_resources_level ON public.resources(level);
CREATE INDEX IF NOT EXISTS idx_resources_subject ON public.resources(subject);

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'flehub-resources',
  'flehub-resources',
  false,
  52428800,
  ARRAY[
    'application/pdf',
    'audio/mpeg',
    'audio/mp3',
    'audio/wav',
    'audio/x-wav',
    'audio/ogg',
    'image/jpeg',
    'image/png',
    'image/webp'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Teachers can upload own resource files" ON storage.objects;
CREATE POLICY "Teachers can upload own resource files"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'flehub-resources'
    AND EXISTS (
      SELECT 1 FROM public.teachers t
      WHERE t.id::text = split_part(name, '/', 1)
        AND t.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Teachers can read own and public resource files" ON storage.objects;
CREATE POLICY "Teachers can read own and public resource files"
  ON storage.objects FOR SELECT TO authenticated
  USING (
    bucket_id = 'flehub-resources'
    AND EXISTS (
      SELECT 1
      FROM public.resources r
      LEFT JOIN public.teachers t ON t.id = r.teacher_id
      WHERE r.file_path = name
        AND (
          public.is_admin()
          OR t.profile_id = auth.uid()
          OR (
            r.is_public = true
            AND public.has_role(ARRAY['teacher', 'admin'])
          )
        )
    )
  );

DROP POLICY IF EXISTS "Teachers can update own resource files" ON storage.objects;
CREATE POLICY "Teachers can update own resource files"
  ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'flehub-resources'
    AND EXISTS (
      SELECT 1 FROM public.teachers t
      WHERE t.id::text = split_part(name, '/', 1)
        AND t.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    bucket_id = 'flehub-resources'
    AND EXISTS (
      SELECT 1 FROM public.teachers t
      WHERE t.id::text = split_part(name, '/', 1)
        AND t.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Teachers can delete own resource files" ON storage.objects;
CREATE POLICY "Teachers can delete own resource files"
  ON storage.objects FOR DELETE TO authenticated
  USING (
    bucket_id = 'flehub-resources'
    AND EXISTS (
      SELECT 1 FROM public.teachers t
      WHERE t.id::text = split_part(name, '/', 1)
        AND t.profile_id = auth.uid()
    )
  );
