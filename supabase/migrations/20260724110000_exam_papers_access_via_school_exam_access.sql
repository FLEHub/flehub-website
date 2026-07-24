/*
  Fix: exam papers/audio visibility for schools must NOT depend on student_enrollments.

  Root cause (from complete school space RLS):
  - "Schools can read papers for enrolled sessions" on exam_papers
  - "Schools read enrolled exam papers" on storage.objects
  - school_has_active_exam_enrollment() used by exam_downloads

  Desired gate: school_exam_access.status = 'completed' for (school_id, exam_session_id).
  Once access exists, PDFs/audio are listable and downloadable immediately.
*/

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.current_school_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT s.id
  FROM public.schools s
  WHERE s.profile_id = auth.uid()
  LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.current_school_id() TO authenticated;

-- ---------------------------------------------------------------------------
-- school_exam_access table (idempotent; may already exist from Phase 1 draft)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.school_exam_access (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  exam_session_id uuid NOT NULL REFERENCES public.exam_sessions(id) ON DELETE CASCADE,
  payment_id uuid REFERENCES public.payments(id),
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  paid_at timestamptz,
  UNIQUE (school_id, exam_session_id)
);

ALTER TABLE public.school_exam_access ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_school_exam_access_school ON public.school_exam_access(school_id);
CREATE INDEX IF NOT EXISTS idx_school_exam_access_session ON public.school_exam_access(exam_session_id);

DROP POLICY IF EXISTS "school_exam_access_school_select" ON public.school_exam_access;
CREATE POLICY "school_exam_access_school_select" ON public.school_exam_access FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM public.schools s WHERE s.id = school_id AND s.profile_id = auth.uid())
  );

DROP POLICY IF EXISTS "school_exam_access_admin_select" ON public.school_exam_access;
CREATE POLICY "school_exam_access_admin_select" ON public.school_exam_access FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

DROP POLICY IF EXISTS "school_exam_access_admin_insert" ON public.school_exam_access;
CREATE POLICY "school_exam_access_admin_insert" ON public.school_exam_access FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

DROP POLICY IF EXISTS "school_exam_access_admin_update" ON public.school_exam_access;
CREATE POLICY "school_exam_access_admin_update" ON public.school_exam_access FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE OR REPLACE FUNCTION public.school_has_exam_access(school_uuid uuid, exam_uuid uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    school_uuid IS NOT NULL
    AND exam_uuid IS NOT NULL
    AND EXISTS (
      SELECT 1
      FROM public.school_exam_access sea
      WHERE sea.school_id = school_uuid
        AND sea.exam_session_id = exam_uuid
        AND sea.status = 'completed'
    );
$$;

GRANT EXECUTE ON FUNCTION public.school_has_exam_access(uuid, uuid) TO authenticated;

-- ---------------------------------------------------------------------------
-- exam_papers: drop enrollment / open-select policies, gate on school_exam_access
-- ---------------------------------------------------------------------------

-- Schema compatibility with older school-space migration (file_path NOT NULL, no audio)
ALTER TABLE public.exam_papers
  ADD COLUMN IF NOT EXISTS audio_path text,
  ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

DO $$
BEGIN
  ALTER TABLE public.exam_papers ALTER COLUMN file_path DROP NOT NULL;
EXCEPTION
  WHEN undefined_column THEN NULL;
  WHEN others THEN NULL;
END $$;

DROP POLICY IF EXISTS "Schools can read papers for enrolled sessions" ON public.exam_papers;
DROP POLICY IF EXISTS "select_exam_papers" ON public.exam_papers;
DROP POLICY IF EXISTS "Admins can manage exam papers" ON public.exam_papers;
DROP POLICY IF EXISTS "Schools can read papers with exam access" ON public.exam_papers;

CREATE POLICY "Schools can read papers with exam access"
  ON public.exam_papers FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
    OR public.school_has_exam_access(public.current_school_id(), exam_session_id)
  );

-- Keep / ensure admin write policies (July naming + legacy naming)
DROP POLICY IF EXISTS "insert_exam_papers" ON public.exam_papers;
CREATE POLICY "insert_exam_papers" ON public.exam_papers FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

DROP POLICY IF EXISTS "update_exam_papers" ON public.exam_papers;
CREATE POLICY "update_exam_papers" ON public.exam_papers FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

DROP POLICY IF EXISTS "delete_exam_papers" ON public.exam_papers;
CREATE POLICY "delete_exam_papers" ON public.exam_papers FOR DELETE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- ---------------------------------------------------------------------------
-- exam_downloads (if present): gate insert on school_exam_access, not enrollments
-- ---------------------------------------------------------------------------

DO $$
BEGIN
  IF to_regclass('public.exam_downloads') IS NOT NULL THEN
    EXECUTE 'DROP POLICY IF EXISTS "Schools can insert own exam downloads" ON public.exam_downloads';
    EXECUTE $pol$
      CREATE POLICY "Schools can insert own exam downloads"
        ON public.exam_downloads FOR INSERT TO authenticated
        WITH CHECK (
          EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
          OR (
            school_id = public.current_school_id()
            AND public.school_has_exam_access(school_id, exam_id)
          )
        )
    $pol$;
  END IF;
END $$;

-- ---------------------------------------------------------------------------
-- Storage buckets (ensure present)
-- ---------------------------------------------------------------------------

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('exam-papers', 'exam-papers', false, 52428800, ARRAY['application/pdf']::text[]),
  ('exam-audio', 'exam-audio', false, 52428800, ARRAY['audio/mpeg', 'audio/mp3', 'audio/wav']::text[])
ON CONFLICT (id) DO UPDATE
SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ---------------------------------------------------------------------------
-- Storage RLS: remove enrollment / open-select gates; use school_exam_access
-- Paths are {exam_session_id}/{competency}.pdf|.mp3
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "Schools read enrolled exam papers" ON storage.objects;
DROP POLICY IF EXISTS "exam_papers_select" ON storage.objects;
DROP POLICY IF EXISTS "Schools read accessible exam papers" ON storage.objects;
DROP POLICY IF EXISTS "Admins manage exam papers bucket" ON storage.objects;
DROP POLICY IF EXISTS "exam_papers_insert" ON storage.objects;
DROP POLICY IF EXISTS "exam_papers_update" ON storage.objects;
DROP POLICY IF EXISTS "exam_papers_delete" ON storage.objects;

CREATE POLICY "Schools read accessible exam papers"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'exam-papers'
    AND (
      EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR (
        (storage.foldername(name))[1] ~* '^[0-9a-f-]{36}$'
        AND public.school_has_exam_access(
          public.current_school_id(),
          ((storage.foldername(name))[1])::uuid
        )
      )
    )
  );

CREATE POLICY "exam_papers_insert" ON storage.objects FOR INSERT
  TO authenticated WITH CHECK (
    bucket_id = 'exam-papers'
    AND EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "exam_papers_update" ON storage.objects FOR UPDATE
  TO authenticated USING (
    bucket_id = 'exam-papers'
    AND EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "exam_papers_delete" ON storage.objects FOR DELETE
  TO authenticated USING (
    bucket_id = 'exam-papers'
    AND EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

DROP POLICY IF EXISTS "exam_audio_select" ON storage.objects;
DROP POLICY IF EXISTS "Schools read accessible exam audio" ON storage.objects;
DROP POLICY IF EXISTS "exam_audio_insert" ON storage.objects;
DROP POLICY IF EXISTS "exam_audio_update" ON storage.objects;
DROP POLICY IF EXISTS "exam_audio_delete" ON storage.objects;

CREATE POLICY "Schools read accessible exam audio"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'exam-audio'
    AND (
      EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR (
        (storage.foldername(name))[1] ~* '^[0-9a-f-]{36}$'
        AND public.school_has_exam_access(
          public.current_school_id(),
          ((storage.foldername(name))[1])::uuid
        )
      )
    )
  );

CREATE POLICY "exam_audio_insert" ON storage.objects FOR INSERT
  TO authenticated WITH CHECK (
    bucket_id = 'exam-audio'
    AND EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "exam_audio_update" ON storage.objects FOR UPDATE
  TO authenticated USING (
    bucket_id = 'exam-audio'
    AND EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "exam_audio_delete" ON storage.objects FOR DELETE
  TO authenticated USING (
    bucket_id = 'exam-audio'
    AND EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );
