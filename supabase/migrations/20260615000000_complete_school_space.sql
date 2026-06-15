/*
  Complete SCHOOL space (Space 1)

  Adds the institution profile fields, pupil-first student model, exam paper
  downloads, draft/submitted result workflow, certificate fields, storage buckets,
  and school-scoped RLS policies required by the school workspace.
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

CREATE OR REPLACE FUNCTION public.student_belongs_to_school(student_uuid uuid, school_uuid uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.students s
    WHERE s.id = student_uuid
      AND s.school_id = school_uuid
  );
$$;

CREATE OR REPLACE FUNCTION public.school_has_active_exam_enrollment(school_uuid uuid, exam_uuid uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.student_enrollments se
    JOIN public.students s ON s.id = se.student_id
    WHERE s.school_id = school_uuid
      AND se.exam_session_id = exam_uuid
      AND se.active = true
  );
$$;

GRANT EXECUTE ON FUNCTION public.student_belongs_to_school(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.school_has_active_exam_enrollment(uuid, uuid) TO authenticated;

-- ---------------------------------------------------------------------------
-- School institutional profile
-- ---------------------------------------------------------------------------

ALTER TABLE public.schools
  ADD COLUMN IF NOT EXISTS name text,
  ADD COLUMN IF NOT EXISTS type text DEFAULT 'both',
  ADD COLUMN IF NOT EXISTS director_name text,
  ADD COLUMN IF NOT EXISTS email text,
  ADD COLUMN IF NOT EXISTS phone text,
  ADD COLUMN IF NOT EXISTS signature_url text,
  ADD COLUMN IF NOT EXISTS status text DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

UPDATE public.schools s
SET
  name = COALESCE(s.name, s.school_name),
  director_name = COALESCE(s.director_name, s.contact_person, p.full_name),
  email = COALESCE(s.email, p.email),
  phone = COALESCE(s.phone, p.phone),
  status = COALESCE(s.status, p.status)
FROM public.profiles p
WHERE p.id = s.profile_id;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'schools_type_check'
  ) THEN
    ALTER TABLE public.schools
      ADD CONSTRAINT schools_type_check
      CHECK (type IN ('primary', 'secondary', 'both'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'schools_status_check'
  ) THEN
    ALTER TABLE public.schools
      ADD CONSTRAINT schools_status_check
      CHECK (status IN ('pending', 'approved', 'rejected', 'suspended'));
  END IF;
END $$;

-- Keep school.status aligned with the account status used by auth/profile flows.
CREATE OR REPLACE FUNCTION public.sync_school_status_from_profile()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.role = 'school' THEN
    UPDATE public.schools
    SET status = NEW.status, updated_at = now()
    WHERE profile_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_school_status_from_profile ON public.profiles;
CREATE TRIGGER trg_sync_school_status_from_profile
AFTER UPDATE OF status ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.sync_school_status_from_profile();

DROP POLICY IF EXISTS "Admins can update all schools" ON public.schools;
CREATE POLICY "Admins can update all schools"
  ON public.schools FOR UPDATE TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------------------
-- Pupils without email
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.students (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  first_name text NOT NULL,
  last_name text NOT NULL,
  date_of_birth date NOT NULL,
  gender text NOT NULL CHECK (gender IN ('M', 'F')),
  grade text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_students_school_id ON public.students(school_id);
CREATE INDEX IF NOT EXISTS idx_students_name ON public.students(school_id, last_name, first_name);

DROP POLICY IF EXISTS "Schools can read own students" ON public.students;
CREATE POLICY "Schools can read own students"
  ON public.students FOR SELECT TO authenticated
  USING (school_id = public.current_school_id() OR public.is_admin());

DROP POLICY IF EXISTS "Schools can insert own students" ON public.students;
CREATE POLICY "Schools can insert own students"
  ON public.students FOR INSERT TO authenticated
  WITH CHECK (school_id = public.current_school_id() OR public.is_admin());

DROP POLICY IF EXISTS "Schools can update own students" ON public.students;
CREATE POLICY "Schools can update own students"
  ON public.students FOR UPDATE TO authenticated
  USING (school_id = public.current_school_id() OR public.is_admin())
  WITH CHECK (school_id = public.current_school_id() OR public.is_admin());

DROP POLICY IF EXISTS "Schools can delete own students" ON public.students;
CREATE POLICY "Schools can delete own students"
  ON public.students FOR DELETE TO authenticated
  USING (school_id = public.current_school_id() OR public.is_admin());

CREATE TABLE IF NOT EXISTS public.student_enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  exam_session_id uuid NOT NULL REFERENCES public.exam_sessions(id) ON DELETE CASCADE,
  cefr_level text NOT NULL CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  active boolean NOT NULL DEFAULT true,
  enrolled_at timestamptz DEFAULT now(),
  UNIQUE(student_id, exam_session_id)
);

ALTER TABLE public.student_enrollments ENABLE ROW LEVEL SECURITY;

CREATE UNIQUE INDEX IF NOT EXISTS one_active_student_exam_per_level
  ON public.student_enrollments(student_id, cefr_level)
  WHERE active = true;

CREATE INDEX IF NOT EXISTS idx_student_enrollments_exam ON public.student_enrollments(exam_session_id);

DROP POLICY IF EXISTS "Schools can read own student enrollments" ON public.student_enrollments;
CREATE POLICY "Schools can read own student enrollments"
  ON public.student_enrollments FOR SELECT TO authenticated
  USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.students s
      WHERE s.id = student_id AND s.school_id = public.current_school_id()
    )
  );

DROP POLICY IF EXISTS "Schools can insert own student enrollments" ON public.student_enrollments;
CREATE POLICY "Schools can insert own student enrollments"
  ON public.student_enrollments FOR INSERT TO authenticated
  WITH CHECK (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.students s
      WHERE s.id = student_id AND s.school_id = public.current_school_id()
    )
  );

DROP POLICY IF EXISTS "Schools can update own student enrollments" ON public.student_enrollments;
CREATE POLICY "Schools can update own student enrollments"
  ON public.student_enrollments FOR UPDATE TO authenticated
  USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.students s
      WHERE s.id = student_id AND s.school_id = public.current_school_id()
    )
  )
  WITH CHECK (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.students s
      WHERE s.id = student_id AND s.school_id = public.current_school_id()
    )
  );

DROP POLICY IF EXISTS "Schools can delete own student enrollments" ON public.student_enrollments;
CREATE POLICY "Schools can delete own student enrollments"
  ON public.student_enrollments FOR DELETE TO authenticated
  USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.students s
      WHERE s.id = student_id AND s.school_id = public.current_school_id()
    )
  );

-- ---------------------------------------------------------------------------
-- Exam papers and download logs
-- ---------------------------------------------------------------------------

ALTER TABLE public.exam_sessions
  ADD COLUMN IF NOT EXISTS pass_threshold numeric(5,2) NOT NULL DEFAULT 60;

DROP POLICY IF EXISTS "Admins can delete exam sessions" ON public.exam_sessions;
CREATE POLICY "Admins can delete exam sessions"
  ON public.exam_sessions FOR DELETE TO authenticated
  USING (public.is_admin());

CREATE TABLE IF NOT EXISTS public.exam_papers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_session_id uuid NOT NULL REFERENCES public.exam_sessions(id) ON DELETE CASCADE,
  competency text NOT NULL CHECK (competency IN ('EO', 'EE', 'CO', 'CE', 'LANGUE')),
  file_path text NOT NULL,
  uploaded_by uuid REFERENCES public.profiles(id),
  created_at timestamptz DEFAULT now(),
  UNIQUE(exam_session_id, competency)
);

ALTER TABLE public.exam_papers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can manage exam papers" ON public.exam_papers;
CREATE POLICY "Admins can manage exam papers"
  ON public.exam_papers FOR ALL TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Schools can read papers for enrolled sessions" ON public.exam_papers;
CREATE POLICY "Schools can read papers for enrolled sessions"
  ON public.exam_papers FOR SELECT TO authenticated
  USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1
      FROM public.student_enrollments se
      JOIN public.students st ON st.id = se.student_id
      WHERE se.exam_session_id = exam_papers.exam_session_id
        AND se.active = true
        AND st.school_id = public.current_school_id()
    )
  );

CREATE TABLE IF NOT EXISTS public.exam_downloads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  exam_id uuid NOT NULL REFERENCES public.exam_sessions(id) ON DELETE CASCADE,
  competency text NOT NULL CHECK (competency IN ('EO', 'EE', 'CO', 'CE', 'LANGUE')),
  downloaded_at timestamptz DEFAULT now()
);

ALTER TABLE public.exam_downloads ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_exam_downloads_school_exam ON public.exam_downloads(school_id, exam_id);

DROP POLICY IF EXISTS "Schools can read own exam downloads" ON public.exam_downloads;
CREATE POLICY "Schools can read own exam downloads"
  ON public.exam_downloads FOR SELECT TO authenticated
  USING (school_id = public.current_school_id() OR public.is_admin());

DROP POLICY IF EXISTS "Schools can insert own exam downloads" ON public.exam_downloads;
CREATE POLICY "Schools can insert own exam downloads"
  ON public.exam_downloads FOR INSERT TO authenticated
  WITH CHECK (
    public.is_admin()
    OR (
      school_id = public.current_school_id()
      AND public.school_has_active_exam_enrollment(school_id, exam_id)
    )
  );

-- ---------------------------------------------------------------------------
-- Result drafts, submission, and admin validation
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.student_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  exam_session_id uuid NOT NULL REFERENCES public.exam_sessions(id) ON DELETE CASCADE,
  score_eo numeric(5,2) CHECK (score_eo BETWEEN 0 AND 100),
  score_ee numeric(5,2) CHECK (score_ee BETWEEN 0 AND 100),
  score_co numeric(5,2) CHECK (score_co BETWEEN 0 AND 100),
  score_ce numeric(5,2) CHECK (score_ce BETWEEN 0 AND 100),
  score_langue numeric(5,2) CHECK (score_langue BETWEEN 0 AND 100),
  total_score numeric(6,2),
  overall_pass boolean DEFAULT false,
  submitted boolean DEFAULT false,
  submitted_at timestamptz,
  validated_by_admin boolean DEFAULT false,
  validation_status text NOT NULL DEFAULT 'draft' CHECK (validation_status IN ('draft', 'submitted', 'validated', 'rejected')),
  admin_feedback text,
  validated_by uuid REFERENCES public.profiles(id),
  validated_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(student_id, exam_session_id)
);

ALTER TABLE public.student_results ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_student_results_school_exam ON public.student_results(school_id, exam_session_id);

DROP POLICY IF EXISTS "Schools can read own student results" ON public.student_results;
CREATE POLICY "Schools can read own student results"
  ON public.student_results FOR SELECT TO authenticated
  USING (
    public.is_admin()
    OR (
      school_id = public.current_school_id()
      AND public.student_belongs_to_school(student_id, school_id)
    )
  );

DROP POLICY IF EXISTS "Schools can insert own student results" ON public.student_results;
CREATE POLICY "Schools can insert own student results"
  ON public.student_results FOR INSERT TO authenticated
  WITH CHECK (
    public.is_admin()
    OR (
      school_id = public.current_school_id()
      AND public.student_belongs_to_school(student_id, school_id)
      AND EXISTS (
        SELECT 1
        FROM public.student_enrollments se
        WHERE se.student_id = student_results.student_id
          AND se.exam_session_id = student_results.exam_session_id
          AND se.active = true
      )
    )
  );

DROP POLICY IF EXISTS "Schools can update own unlocked student results" ON public.student_results;
CREATE POLICY "Schools can update own unlocked student results"
  ON public.student_results FOR UPDATE TO authenticated
  USING (
    public.is_admin()
    OR (
      school_id = public.current_school_id()
      AND public.student_belongs_to_school(student_id, school_id)
      AND (submitted = false OR validation_status = 'rejected')
    )
  )
  WITH CHECK (
    public.is_admin()
    OR (
      school_id = public.current_school_id()
      AND public.student_belongs_to_school(student_id, school_id)
      AND validation_status IN ('draft', 'submitted')
    )
  );

DROP POLICY IF EXISTS "Admins can validate student results" ON public.student_results;
CREATE POLICY "Admins can validate student results"
  ON public.student_results FOR UPDATE TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Optional policy for legacy results now scopes schools to their own learners.
ALTER TABLE public.exam_results
  ADD COLUMN IF NOT EXISTS school_id uuid REFERENCES public.schools(id),
  ADD COLUMN IF NOT EXISTS certificate_id uuid;

DROP POLICY IF EXISTS "Admins can manage all results" ON public.exam_results;
CREATE POLICY "Admins can manage all results"
  ON public.exam_results FOR SELECT TO authenticated
  USING (
    public.is_admin()
    OR school_id = public.current_school_id()
    OR EXISTS (
      SELECT 1 FROM public.learners l
      WHERE l.id = learner_id AND l.profile_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- Certificates for pupils
-- ---------------------------------------------------------------------------

ALTER TABLE public.certificates
  ADD COLUMN IF NOT EXISTS student_id uuid REFERENCES public.students(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS level text,
  ADD COLUMN IF NOT EXISTS certificate_uuid uuid DEFAULT gen_random_uuid(),
  ADD COLUMN IF NOT EXISTS verified_url text;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'certificates_level_check'
  ) THEN
    ALTER TABLE public.certificates
      ADD CONSTRAINT certificates_level_check
      CHECK (level IS NULL OR level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2'));
  END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS idx_certificates_certificate_uuid
  ON public.certificates(certificate_uuid)
  WHERE certificate_uuid IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_certificates_student_school_level
  ON public.certificates(student_id, school_id, level)
  WHERE student_id IS NOT NULL AND school_id IS NOT NULL AND level IS NOT NULL;

ALTER TABLE public.certificates ALTER COLUMN learner_id DROP NOT NULL;
ALTER TABLE public.certificates ALTER COLUMN certificate_number DROP NOT NULL;
ALTER TABLE public.certificates ALTER COLUMN verification_code DROP NOT NULL;

DROP POLICY IF EXISTS "Admins and schools can manage certificates" ON public.certificates;
CREATE POLICY "Admins and schools can manage certificates"
  ON public.certificates FOR SELECT TO authenticated
  USING (
    public.is_admin()
    OR (
      school_id = public.current_school_id()
      AND (
        student_id IS NULL
        OR public.student_belongs_to_school(student_id, school_id)
      )
    )
    OR EXISTS (
      SELECT 1 FROM public.learners l
      WHERE l.id = learner_id AND l.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins can insert certificates" ON public.certificates;
CREATE POLICY "Admins can insert certificates"
  ON public.certificates FOR INSERT TO authenticated
  WITH CHECK (
    public.is_admin()
    OR (
      school_id = public.current_school_id()
      AND student_id IS NOT NULL
      AND public.student_belongs_to_school(student_id, school_id)
    )
  );

DROP POLICY IF EXISTS "Schools can update own certificates" ON public.certificates;
CREATE POLICY "Schools can update own certificates"
  ON public.certificates FOR UPDATE TO authenticated
  USING (
    public.is_admin()
    OR (
      school_id = public.current_school_id()
      AND (
        student_id IS NULL
        OR public.student_belongs_to_school(student_id, school_id)
      )
    )
  )
  WITH CHECK (
    public.is_admin()
    OR (
      school_id = public.current_school_id()
      AND student_id IS NOT NULL
      AND public.student_belongs_to_school(student_id, school_id)
    )
  );

-- ---------------------------------------------------------------------------
-- Storage buckets and object policies
-- ---------------------------------------------------------------------------

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('school-assets', 'school-assets', false, 5242880, ARRAY['image/png', 'image/jpeg']::text[]),
  ('exam-papers', 'exam-papers', false, 52428800, ARRAY['application/pdf']::text[]),
  ('certificates', 'certificates', true, 52428800, ARRAY['application/pdf', 'application/zip']::text[])
ON CONFLICT (id) DO UPDATE
SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Schools manage own school assets" ON storage.objects;
CREATE POLICY "Schools manage own school assets"
  ON storage.objects FOR ALL TO authenticated
  USING (
    bucket_id = 'school-assets'
    AND (
      public.is_admin()
      OR (storage.foldername(name))[1] = public.current_school_id()::text
    )
  )
  WITH CHECK (
    bucket_id = 'school-assets'
    AND (
      public.is_admin()
      OR (storage.foldername(name))[1] = public.current_school_id()::text
    )
  );

DROP POLICY IF EXISTS "Admins manage exam papers bucket" ON storage.objects;
CREATE POLICY "Admins manage exam papers bucket"
  ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'exam-papers' AND public.is_admin())
  WITH CHECK (bucket_id = 'exam-papers' AND public.is_admin());

DROP POLICY IF EXISTS "Schools read enrolled exam papers" ON storage.objects;
CREATE POLICY "Schools read enrolled exam papers"
  ON storage.objects FOR SELECT TO authenticated
  USING (
    bucket_id = 'exam-papers'
    AND (
      public.is_admin()
      OR EXISTS (
        SELECT 1
        FROM public.exam_papers ep
        JOIN public.student_enrollments se ON se.exam_session_id = ep.exam_session_id
        JOIN public.students st ON st.id = se.student_id
        WHERE ep.file_path = storage.objects.name
          AND se.active = true
          AND st.school_id = public.current_school_id()
      )
    )
  );

DROP POLICY IF EXISTS "Schools manage own certificate files" ON storage.objects;
CREATE POLICY "Schools manage own certificate files"
  ON storage.objects FOR ALL TO authenticated
  USING (
    bucket_id = 'certificates'
    AND (
      public.is_admin()
      OR (storage.foldername(name))[1] = public.current_school_id()::text
    )
  )
  WITH CHECK (
    bucket_id = 'certificates'
    AND (
      public.is_admin()
      OR (storage.foldername(name))[1] = public.current_school_id()::text
    )
  );
