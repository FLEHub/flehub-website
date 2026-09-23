/*
  Two-step account activation.

  Signup lifecycle on public.profiles.status:
    pending_email_confirmation → pending_admin_validation → active
    (or rejected)

  `suspended` is kept so an already-active account can still be blocked
  after the fact. Legacy values are migrated:
    approved → active
    pending + confirmed email → pending_admin_validation
    pending + unconfirmed email → pending_email_confirmation

  Email confirmation uses Supabase Auth. When auth.users.email_confirmed_at
  goes from NULL to a timestamp, the profile moves to pending_admin_validation.
  The branded template lives in supabase/templates/confirmation.html
  (Authentication → Email Templates → Confirm signup, Site URL https://mfkigali.com).
*/

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS email_confirmed_at timestamptz,
  ADD COLUMN IF NOT EXISTS validated_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS validated_at timestamptz,
  ADD COLUMN IF NOT EXISTS rejection_reason text;

-- Drop every CHECK that mentions profiles.status (name varies by environment).
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT con.conname
    FROM pg_constraint con
    JOIN pg_class rel ON rel.oid = con.conrelid
    JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
    WHERE nsp.nspname = 'public'
      AND rel.relname = 'profiles'
      AND con.contype = 'c'
      AND pg_get_constraintdef(con.oid) ILIKE '%status%'
  LOOP
    EXECUTE format('ALTER TABLE public.profiles DROP CONSTRAINT %I', r.conname);
  END LOOP;
END $$;

UPDATE public.profiles p
SET email_confirmed_at = u.email_confirmed_at
FROM auth.users u
WHERE p.id = u.id
  AND u.email_confirmed_at IS NOT NULL
  AND p.email_confirmed_at IS NULL;

UPDATE public.profiles
SET status = 'active'
WHERE status = 'approved';

UPDATE public.profiles
SET status = 'pending_admin_validation'
WHERE status = 'pending'
  AND email_confirmed_at IS NOT NULL;

UPDATE public.profiles
SET status = 'pending_email_confirmation'
WHERE status = 'pending'
  AND email_confirmed_at IS NULL;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_status_check
  CHECK (
    status IN (
      'pending_email_confirmation',
      'pending_admin_validation',
      'active',
      'rejected',
      'suspended'
    )
  );

ALTER TABLE public.profiles
  ALTER COLUMN status SET DEFAULT 'pending_email_confirmation';

CREATE INDEX IF NOT EXISTS idx_profiles_pending_admin_validation
  ON public.profiles (email_confirmed_at)
  WHERE status = 'pending_admin_validation';

-- Staff accounts created by an admin are active immediately.
-- Public signup (learner / teacher / school) waits for email, then for an admin.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  meta_role text;
  profile_role text;
  profile_status text;
BEGIN
  meta_role := lower(btrim(coalesce(NEW.raw_user_meta_data->>'role', '')));

  IF meta_role IN ('admin', 'school', 'teacher', 'learner', 'journalist', 'creator') THEN
    profile_role := meta_role;
  ELSE
    profile_role := 'learner';
  END IF;

  IF profile_role IN ('admin', 'journalist', 'creator') THEN
    profile_status := 'active';
  ELSIF NEW.email_confirmed_at IS NOT NULL THEN
    profile_status := 'pending_admin_validation';
  ELSE
    profile_status := 'pending_email_confirmation';
  END IF;

  INSERT INTO public.profiles (
    id, email, full_name, phone, role, status, email_confirmed_at
  )
  VALUES (
    NEW.id,
    coalesce(NEW.email, ''),
    coalesce(NEW.raw_user_meta_data->>'full_name', ''),
    nullif(NEW.raw_user_meta_data->>'phone', ''),
    profile_role,
    profile_status,
    NEW.email_confirmed_at
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM anon;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM authenticated;

-- Promote a profile only when Auth records the first email confirmation.
CREATE OR REPLACE FUNCTION public.handle_user_email_confirmed()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF OLD.email_confirmed_at IS NULL AND NEW.email_confirmed_at IS NOT NULL THEN
    PERFORM set_config('mfk.allow_profile_status_write', '1', true);

    UPDATE public.profiles
    SET
      status = 'pending_admin_validation',
      email_confirmed_at = COALESCE(email_confirmed_at, now()),
      updated_at = now()
    WHERE id = NEW.id
      AND status = 'pending_email_confirmation';
  END IF;

  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.handle_user_email_confirmed() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.handle_user_email_confirmed() FROM anon;
REVOKE ALL ON FUNCTION public.handle_user_email_confirmed() FROM authenticated;

DROP TRIGGER IF EXISTS on_auth_user_email_confirmed ON auth.users;
CREATE TRIGGER on_auth_user_email_confirmed
  AFTER UPDATE OF email_confirmed_at ON auth.users
  FOR EACH ROW
  WHEN (OLD.email_confirmed_at IS NULL AND NEW.email_confirmed_at IS NOT NULL)
  EXECUTE PROCEDURE public.handle_user_email_confirmed();

-- A signed-in user must not be able to activate themselves or change role.
CREATE OR REPLACE FUNCTION public.protect_profile_activation_fields()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  jwt_role text;
  caller_is_admin boolean;
BEGIN
  IF coalesce(current_setting('mfk.allow_profile_status_write', true), '') = '1' THEN
    RETURN NEW;
  END IF;

  jwt_role := coalesce(auth.jwt()->>'role', '');
  IF jwt_role = 'service_role' THEN
    RETURN NEW;
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM public.profiles p
    WHERE p.id = auth.uid()
      AND p.role = 'admin'
      AND p.status = 'active'
  ) INTO caller_is_admin;

  IF caller_is_admin THEN
    RETURN NEW;
  END IF;

  NEW.status := OLD.status;
  NEW.email_confirmed_at := OLD.email_confirmed_at;
  NEW.validated_by := OLD.validated_by;
  NEW.validated_at := OLD.validated_at;
  NEW.rejection_reason := OLD.rejection_reason;
  NEW.role := OLD.role;
  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.protect_profile_activation_fields() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.protect_profile_activation_fields() FROM anon;
REVOKE ALL ON FUNCTION public.protect_profile_activation_fields() FROM authenticated;

DROP TRIGGER IF EXISTS protect_profile_activation_fields ON public.profiles;
CREATE TRIGGER protect_profile_activation_fields
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE PROCEDURE public.protect_profile_activation_fields();

-- Used by restrictive RLS policies. SECURITY DEFINER avoids policy recursion.
CREATE OR REPLACE FUNCTION public.is_active_account()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid()
      AND status = 'active'
  );
$$;

REVOKE ALL ON FUNCTION public.is_active_account() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_active_account() TO authenticated;

-- Non-active sessions cannot read or write course / exam data, even via the API.
DO $$
DECLARE
  t text;
  tables text[] := ARRAY[
    'courses',
    'exercises',
    'exercise_questions',
    'learner_progress',
    'exam_sessions',
    'exam_registrations',
    'exam_results',
    'exam_papers',
    'exam_result_drafts',
    'certificates',
    'school_certificates',
    'live_sessions',
    'elearning_modules',
    'elearning_sequences',
    'elearning_lessons',
    'elearning_exercises',
    'elearning_enrollments',
    'elearning_progress',
    'elearning_submissions',
    'elearning_capsules',
    'elearning_badges',
    'elearning_module_badges',
    'elearning_module_assignments',
    'elearning_level_exam_scores',
    'elearning_certificates',
    'exercise_audio_submissions',
    'tcf_co_sessions',
    'tcf_co_questions',
    'tcf_co_baremes',
    'student_co_attempts',
    'tcf_ce_sessions',
    'tcf_ce_questions',
    'tcf_ce_baremes',
    'student_ce_attempts',
    'tcf_ee_sessions',
    'tcf_ee_taches',
    'student_ee_attempts',
    'student_ee_reponses',
    'ee_corrections',
    'tcf_eo_sessions',
    'tcf_eo_sujets',
    'student_eo_evaluations',
    'revision_unites',
    'revision_points',
    'revision_questions',
    'revision_ressources',
    'student_revision_attempts'
  ];
BEGIN
  FOREACH t IN ARRAY tables LOOP
    IF to_regclass('public.' || t) IS NULL THEN
      CONTINUE;
    END IF;

    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', 'Active accounts only', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I AS RESTRICTIVE FOR ALL TO authenticated USING (public.is_active_account()) WITH CHECK (public.is_active_account())',
      'Active accounts only',
      t
    );
  END LOOP;
END $$;

DROP POLICY IF EXISTS "Active accounts can access course and exam files" ON storage.objects;
CREATE POLICY "Active accounts can access course and exam files"
  ON storage.objects
  AS RESTRICTIVE
  FOR ALL
  TO authenticated
  USING (
    bucket_id NOT IN (
      'exam-papers',
      'exam-audio',
      'elearning-media',
      'elearning-certificates',
      'revision-pdfs',
      'tcf-co-images',
      'tcf-co-audios',
      'tcf-ce-images'
    )
    OR public.is_active_account()
  )
  WITH CHECK (
    bucket_id NOT IN (
      'exam-papers',
      'exam-audio',
      'elearning-media',
      'elearning-certificates',
      'revision-pdfs',
      'tcf-co-images',
      'tcf-co-audios',
      'tcf-ce-images'
    )
    OR public.is_active_account()
  );
