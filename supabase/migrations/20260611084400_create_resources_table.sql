/*
  Resources uploaded by teachers to Supabase Storage.
*/

CREATE TABLE IF NOT EXISTS public.resources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  teacher_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  type text CHECK (type IN ('video', 'pdf', 'audio', 'image')),
  subject text,
  level text CHECK (level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  file_path text NOT NULL,
  file_size bigint,
  file_name text,
  is_public boolean DEFAULT false,
  download_count integer DEFAULT 0
);

ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can insert own resources" ON public.resources;
CREATE POLICY "Teachers can insert own resources"
  ON public.resources FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = teacher_id
    AND public.has_role(ARRAY['teacher'])
  );

DROP POLICY IF EXISTS "Teachers can select own resources" ON public.resources;
CREATE POLICY "Teachers can select own resources"
  ON public.resources FOR SELECT
  TO authenticated
  USING (
    auth.uid() = teacher_id
    AND public.has_role(ARRAY['teacher'])
  );

DROP POLICY IF EXISTS "Teachers can update own resources" ON public.resources;
CREATE POLICY "Teachers can update own resources"
  ON public.resources FOR UPDATE
  TO authenticated
  USING (
    auth.uid() = teacher_id
    AND public.has_role(ARRAY['teacher'])
  )
  WITH CHECK (
    auth.uid() = teacher_id
    AND public.has_role(ARRAY['teacher'])
  );

DROP POLICY IF EXISTS "Teachers can delete own resources" ON public.resources;
CREATE POLICY "Teachers can delete own resources"
  ON public.resources FOR DELETE
  TO authenticated
  USING (
    auth.uid() = teacher_id
    AND public.has_role(ARRAY['teacher'])
  );

DROP POLICY IF EXISTS "Learners can select public resources" ON public.resources;
CREATE POLICY "Learners can select public resources"
  ON public.resources FOR SELECT
  TO authenticated
  USING (
    is_public = true
    AND public.has_role(ARRAY['learner'])
  );

CREATE INDEX IF NOT EXISTS idx_resources_teacher_id ON public.resources(teacher_id);
CREATE INDEX IF NOT EXISTS idx_resources_public_level ON public.resources(is_public, level);
CREATE INDEX IF NOT EXISTS idx_resources_type ON public.resources(type);
