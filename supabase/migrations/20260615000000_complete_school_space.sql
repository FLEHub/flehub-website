/*
  Complete SCHOOL space support.

  This migration keeps existing FLEHub tables compatible while adding the
  institution/pupil model requested for primary and secondary schools.
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

CREATE OR REPLACE FUNCTION public.is_approved_school()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles p
    JOIN public.schools s ON s.profile_id = p.id
    WHERE p.id = auth.uid()
      AND p.role = 'school'
      AND p.status = 'approved'
      AND COALESCE(s.status, p.status) = 'approved'
  );
$$;

GRANT EXECUTE ON FUNCTION public.current_school_id() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_approved_school() TO authenticated;

-- ---------------------------------------------------------------------------
-- Schools: required institutional profile fields
-- ---------------------------------------------------------------------------

ALTER TABLE public.schools
  ADD COLUMN IF NOT EXISTS name text,
  ADD COLUMN IF NOT EXISTS type text CHECK (type IN ('primary', 'secondary', 'both')),
  ADD COLUMN IF NOT EXISTS director_name text,
  ADD COLUMN IF NOT EXISTS email text,
  ADD COLUMN IF NOT EXISTS phone text,
  ADD COLUMN IF NOT EXISTS signature_url text,
  ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'suspended')),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

UPDATE public.schools s
SET
  name = COALESCE(s.name, s.school_name),
  director_name = COALESCE(s.director_name, p.full_name),
  email = COALESCE(s.email, p.email),
  phone = COALESCE(s.phone, p.phone),
  status = COALESCE(s.status, p.status)
FROM public.profiles p
WHERE p.id = s.profile_id;

CREATE OR REPLACE FUNCTION public.sync_school_status_from_profile()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.role = 'school' AND NEW.status IS DISTINCT FROM OLD.status THEN
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

-- ---------------------------------------------------------------------------
-- Students: pupils do not have auth accounts or email addresses
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.students (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  first_name text NOT NULL,
  last_name text NOT NULL,
  date_of_birth date,
  gender text NOT NULL CHECK (gender IN ('M', 'F')),
  grade text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Schools can read own students" ON public.students;
CREATE POLICY "Schools can read own students"
  ON public.students FOR SELECT TO authenticated
  USING (school_id = public.current_school_id() OR public.is_admin());

DROP POLICY IF EXISTS "Schools can insert own students" ON public.students;
CREATE POLICY "Schools can insert own students"
  ON public.students FOR INSERT TO authenticated
  WITH CHECK (school_id = public.current_school_id() AND public.is_approved_school());

DROP POLICY IF EXISTS "Schools can update own students" ON public.students;
CREATE POLICY "Schools can update own students"
  ON public.students FOR UPDATE TO authenticated
  USING (school_id = public.current_school_id())
  WITH CHECK (school_id = public.current_school_id() AND public.is_approved_school());

DROP POLICY IF EXISTS "Schools can delete own students" ON public.students;
CREATE POLICY "Schools can delete own students"
  ON public.students FOR DELETE TO authenticated
  USING (school_id = public.current_school_id() AND public.is_approved_school());

CREATE INDEX IF NOT EXISTS idx_students_school ON public.students(school_id);
CREATE INDEX IF NOT EXISTS idx_students_school_grade ON public.students(school_id, grade);

-- ---------------------------------------------------------------------------
-- Exam sessions and official papers
-- ---------------------------------------------------------------------------

ALTER TABLE public.exam_sessions
  ADD COLUMN IF NOT EXISTS pass_threshold numeric(5,2) NOT NULL DEFAULT 60,
  ADD COLUMN IF NOT EXISTS competency_threshold numeric(5,2) NOT NULL DEFAULT 0;

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

CREATE INDEX IF NOT EXISTS idx_exam_papers_session ON public.exam_papers(exam_session_id);

-- ---------------------------------------------------------------------------
-- Student enrollments: one active exam session per level at a time
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.student_enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  exam_session_id uuid NOT NULL REFERENCES public.exam_sessions(id) ON DELETE CASCADE,
  cefr_level text NOT NULL CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
  enrolled_at timestamptz DEFAULT now(),
  UNIQUE(student_id, exam_session_id)
);

ALTER TABLE public.student_enrollments ENABLE ROW LEVEL SECURITY;

CREATE UNIQUE INDEX IF NOT EXISTS idx_student_enrollments_one_active_level
  ON public.student_enrollments(student_id, cefr_level)
  WHERE status = 'active';

DROP POLICY IF EXISTS "Schools can read own student enrollments" ON public.student_enrollments;
CREATE POLICY "Schools can read own student enrollments"
  ON public.student_enrollments FOR SELECT TO authenticated
  USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1
      FROM public.students st
      WHERE st.id = student_enrollments.student_id
        AND st.school_id = public.current_school_id()
    )
  );

DROP POLICY IF EXISTS "Schools can insert own student enrollments" ON public.student_enrollments;
CREATE POLICY "Schools can insert own student enrollments"
  ON public.student_enrollments FOR INSERT TO authenticated
  WITH CHECK (
    public.is_approved_school()
    AND EXISTS (
      SELECT 1
      FROM public.students st
      WHERE st.id = student_enrollments.student_id
        AND st.school_id = public.current_school_id()
    )
  );

DROP POLICY IF EXISTS "Schools can update own student enrollments" ON public.student_enrollments;
CREATE POLICY "Schools can update own student enrollments"
  ON public.student_enrollments FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.students st
      WHERE st.id = student_enrollments.student_id
        AND st.school_id = public.current_school_id()
    )
  )
  WITH CHECK (
    public.is_approved_school()
    AND EXISTS (
      SELECT 1
      FROM public.students st
      WHERE st.id = student_enrollments.student_id
        AND st.school_id = public.current_school_id()
    )
  );

DROP POLICY IF EXISTS "Schools can delete own student enrollments" ON public.student_enrollments;
CREATE POLICY "Schools can delete own student enrollments"
  ON public.student_enrollments FOR DELETE TO authenticated
  USING (
    public.is_approved_school()
    AND EXISTS (
      SELECT 1
      FROM public.students st
      WHERE st.id = student_enrollments.student_id
        AND st.school_id = public.current_school_id()
    )
  );

CREATE INDEX IF NOT EXISTS idx_student_enrollments_student ON public.student_enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_student_enrollments_session ON public.student_enrollments(exam_session_id);

DROP POLICY IF EXISTS "Approved schools can read exam paper metadata" ON public.exam_papers;
CREATE POLICY "Approved schools can read exam paper metadata"
  ON public.exam_papers FOR SELECT TO authenticated
  USING (
    public.is_approved_school()
    AND EXISTS (
      SELECT 1
      FROM public.student_enrollments se
      JOIN public.students st ON st.id = se.student_id
      WHERE se.exam_session_id = exam_papers.exam_session_id
        AND se.status = 'active'
        AND st.school_id = public.current_school_id()
    )
  );

-- ---------------------------------------------------------------------------
-- Results: draft/submitted/admin validation workflow
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.student_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  exam_session_id uuid NOT NULL REFERENCES public.exam_sessions(id) ON DELETE CASCADE,
  score_eo numeric(5,2) CHECK (score_eo IS NULL OR (score_eo >= 0 AND score_eo <= 100)),
  score_ee numeric(5,2) CHECK (score_ee IS NULL OR (score_ee >= 0 AND score_ee <= 100)),
  score_co numeric(5,2) CHECK (score_co IS NULL OR (score_co >= 0 AND score_co <= 100)),
  score_ce numeric(5,2) CHECK (score_ce IS NULL OR (score_ce >= 0 AND score_ce <= 100)),
  score_langue numeric(5,2) CHECK (score_langue IS NULL OR (score_langue >= 0 AND score_langue <= 100)),
  overall_pass boolean DEFAULT false,
  submitted boolean DEFAULT false,
  validated_by_admin boolean DEFAULT false,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'validated', 'rejected')),
  admin_feedback text,
  submitted_at timestamptz,
  validated_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(student_id, exam_session_id)
);

ALTER TABLE public.student_results ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Schools can read own student results" ON public.student_results;
CREATE POLICY "Schools can read own student results"
  ON public.student_results FOR SELECT TO authenticated
  USING (school_id = public.current_school_id() OR public.is_admin());

DROP POLICY IF EXISTS "Schools can insert own student results" ON public.student_results;
CREATE POLICY "Schools can insert own student results"
  ON public.student_results FOR INSERT TO authenticated
  WITH CHECK (
    school_id = public.current_school_id()
    AND public.is_approved_school()
    AND EXISTS (
      SELECT 1 FROM public.students st
      WHERE st.id = student_results.student_id
        AND st.school_id = student_results.school_id
    )
  );

DROP POLICY IF EXISTS "Schools can update draft or rejected own results" ON public.student_results;
CREATE POLICY "Schools can update draft or rejected own results"
  ON public.student_results FOR UPDATE TO authenticated
  USING (
    school_id = public.current_school_id()
    AND status IN ('draft', 'rejected')
  )
  WITH CHECK (
    school_id = public.current_school_id()
    AND public.is_approved_school()
    AND status IN ('draft', 'submitted')
  );

DROP POLICY IF EXISTS "Admins can validate student results" ON public.student_results;
CREATE POLICY "Admins can validate student results"
  ON public.student_results FOR UPDATE TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE INDEX IF NOT EXISTS idx_student_results_school ON public.student_results(school_id);
CREATE INDEX IF NOT EXISTS idx_student_results_session ON public.student_results(exam_session_id);
CREATE INDEX IF NOT EXISTS idx_student_results_status ON public.student_results(status);

-- ---------------------------------------------------------------------------
-- Downloads and certificates
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.exam_downloads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  exam_id uuid NOT NULL REFERENCES public.exam_sessions(id) ON DELETE CASCADE,
  competency text NOT NULL CHECK (competency IN ('EO', 'EE', 'CO', 'CE', 'LANGUE')),
  downloaded_at timestamptz DEFAULT now()
);

ALTER TABLE public.exam_downloads ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Schools can read own exam downloads" ON public.exam_downloads;
CREATE POLICY "Schools can read own exam downloads"
  ON public.exam_downloads FOR SELECT TO authenticated
  USING (school_id = public.current_school_id() OR public.is_admin());

DROP POLICY IF EXISTS "Schools can insert own exam downloads" ON public.exam_downloads;
CREATE POLICY "Schools can insert own exam downloads"
  ON public.exam_downloads FOR INSERT TO authenticated
  WITH CHECK (school_id = public.current_school_id() AND public.is_approved_school());

CREATE INDEX IF NOT EXISTS idx_exam_downloads_school ON public.exam_downloads(school_id);
CREATE INDEX IF NOT EXISTS idx_exam_downloads_exam ON public.exam_downloads(exam_id);

ALTER TABLE public.certificates
  ALTER COLUMN learner_id DROP NOT NULL,
  ALTER COLUMN certificate_number DROP NOT NULL,
  ALTER COLUMN verification_code DROP NOT NULL,
  ADD COLUMN IF NOT EXISTS student_id uuid REFERENCES public.students(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS level text CHECK (level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  ADD COLUMN IF NOT EXISTS certificate_uuid uuid DEFAULT gen_random_uuid(),
  ADD COLUMN IF NOT EXISTS verified_url text;

UPDATE public.certificates
SET
  level = COALESCE(level, cefr_level),
  certificate_uuid = COALESCE(certificate_uuid, gen_random_uuid()),
  verified_url = COALESCE(verified_url, '/certificats/verifier/' || verification_code)
WHERE level IS NULL
   OR certificate_uuid IS NULL
   OR verified_url IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_certificates_certificate_uuid
  ON public.certificates(certificate_uuid);
CREATE INDEX IF NOT EXISTS idx_certificates_student ON public.certificates(student_id);
CREATE INDEX IF NOT EXISTS idx_certificates_school ON public.certificates(school_id);

DROP POLICY IF EXISTS "Admins and schools can manage certificates" ON public.certificates;
DROP POLICY IF EXISTS "Admins can insert certificates" ON public.certificates;

DROP POLICY IF EXISTS "Schools can read own certificates" ON public.certificates;
CREATE POLICY "Schools can read own certificates"
  ON public.certificates FOR SELECT TO authenticated
  USING (school_id = public.current_school_id() OR public.is_admin());

DROP POLICY IF EXISTS "Schools can insert own certificates" ON public.certificates;
CREATE POLICY "Schools can insert own certificates"
  ON public.certificates FOR INSERT TO authenticated
  WITH CHECK (school_id = public.current_school_id() AND public.is_approved_school());

DROP POLICY IF EXISTS "Schools can update own certificates" ON public.certificates;
CREATE POLICY "Schools can update own certificates"
  ON public.certificates FOR UPDATE TO authenticated
  USING (school_id = public.current_school_id() OR public.is_admin())
  WITH CHECK (school_id = public.current_school_id() OR public.is_admin());

-- ---------------------------------------------------------------------------
-- Storage buckets and RLS
-- ---------------------------------------------------------------------------

INSERT INTO storage.buckets (id, name, public)
VALUES
  ('school-assets', 'school-assets', false),
  ('exam-papers', 'exam-papers', false),
  ('certificates', 'certificates', true)
ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public;

DROP POLICY IF EXISTS "Schools manage own school assets" ON storage.objects;
CREATE POLICY "Schools manage own school assets"
  ON storage.objects FOR ALL TO authenticated
  USING (
    bucket_id = 'school-assets'
    AND (
      public.is_admin()
      OR split_part(name, '/', 1)::uuid = public.current_school_id()
    )
  )
  WITH CHECK (
    bucket_id = 'school-assets'
    AND (
      public.is_admin()
      OR split_part(name, '/', 1)::uuid = public.current_school_id()
    )
  );

DROP POLICY IF EXISTS "Admins manage exam papers" ON storage.objects;
CREATE POLICY "Admins manage exam papers"
  ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'exam-papers' AND public.is_admin())
  WITH CHECK (bucket_id = 'exam-papers' AND public.is_admin());

DROP POLICY IF EXISTS "Public can read certificates" ON storage.objects;
CREATE POLICY "Public can read certificates"
  ON storage.objects FOR SELECT TO anon, authenticated
  USING (bucket_id = 'certificates');

DROP POLICY IF EXISTS "Schools manage own certificate PDFs" ON storage.objects;
CREATE POLICY "Schools manage own certificate PDFs"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'certificates'
    AND (
      public.is_admin()
      OR split_part(name, '/', 1)::uuid = public.current_school_id()
    )
  );
