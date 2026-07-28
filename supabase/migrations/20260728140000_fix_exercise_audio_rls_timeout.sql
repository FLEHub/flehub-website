/*
  Fix exercise_audio_submissions teacher UPDATE timeout (Postgres 57014).

  Audit of existing indexes (do NOT recreate duplicates):
  - elearning_exercises(lesson_id)     → already idx_elearning_exercises_lesson
  - elearning_lessons(sequence_id)     → already idx_elearning_lessons_sequence
  - elearning_sequences(module_id)     → already idx_elearning_sequences_module
  - elearning_modules(teacher_id)      → already idx_elearning_modules_teacher
  - exercise_audio_submissions(exercise_id) → already exercise_audio_submissions_exercise_id_idx

  Missing for the RLS join chain:
  - teachers(profile_id) used by t.profile_id = auth.uid()

  Main cause of timeout: nested RLS when the policy joins tables that
  themselves have RLS (exercises → lessons → sequences → modules → teachers).
  Replace the inline join with a SECURITY DEFINER helper that bypasses RLS.
*/

-- ---------------------------------------------------------------------------
-- Missing index (others already exist — see comment above)
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_teachers_profile_id
  ON teachers (profile_id);

-- ---------------------------------------------------------------------------
-- Ownership helper (bypasses RLS on joined tables; still auth-scoped)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.teacher_owns_elearning_exercise(p_exercise_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM elearning_exercises e
    JOIN elearning_lessons les ON les.id = e.lesson_id
    JOIN elearning_sequences s ON s.id = les.sequence_id
    JOIN elearning_modules m ON m.id = s.module_id
    JOIN teachers t ON t.id = m.teacher_id
    WHERE e.id = p_exercise_id
      AND t.profile_id = auth.uid()
  );
$$;

REVOKE ALL ON FUNCTION public.teacher_owns_elearning_exercise(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.teacher_owns_elearning_exercise(uuid) TO authenticated;

-- ---------------------------------------------------------------------------
-- Rebuild exercise_audio_submissions policies to use the helper
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "Learners can read own exercise audio submissions"
  ON exercise_audio_submissions;
DROP POLICY IF EXISTS "Learners can insert own exercise audio submissions"
  ON exercise_audio_submissions;
DROP POLICY IF EXISTS "Learners can update own pending exercise audio submissions"
  ON exercise_audio_submissions;
DROP POLICY IF EXISTS "Teachers can update exercise audio submissions of own modules"
  ON exercise_audio_submissions;

CREATE POLICY "Learners can read own exercise audio submissions"
  ON exercise_audio_submissions FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM learners l
      WHERE l.id = learner_id AND l.profile_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
    OR public.teacher_owns_elearning_exercise(exercise_id)
  );

CREATE POLICY "Learners can insert own exercise audio submissions"
  ON exercise_audio_submissions FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM learners l
      WHERE l.id = learner_id AND l.profile_id = auth.uid()
    )
  );

-- Learners may only update their own rows (resubmit before validation).
CREATE POLICY "Learners can update own exercise audio submissions"
  ON exercise_audio_submissions FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM learners l
      WHERE l.id = learner_id AND l.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM learners l
      WHERE l.id = learner_id AND l.profile_id = auth.uid()
    )
  );

-- Teachers validate / comment on submissions of their modules.
CREATE POLICY "Teachers can update exercise audio submissions of own modules"
  ON exercise_audio_submissions FOR UPDATE TO authenticated
  USING (public.teacher_owns_elearning_exercise(exercise_id))
  WITH CHECK (public.teacher_owns_elearning_exercise(exercise_id));
