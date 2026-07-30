/*
  Harden elearning_level_exam_scores writes:
  1) Drop leftover triggers/functions that still reference created_at
     (would raise 42703 on INSERT/UPDATE even after the app select fix).
  2) Provide SECURITY DEFINER upsert RPC that only uses recorded_at/updated_at.
  3) Reload PostgREST schema cache.
*/

-- ---------------------------------------------------------------------------
-- Drop non-internal triggers whose function body still mentions created_at
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT t.tgname, p.proname
    FROM pg_trigger t
    JOIN pg_proc p ON p.oid = t.tgfoid
    WHERE t.tgrelid = 'public.elearning_level_exam_scores'::regclass
      AND NOT t.tgisinternal
      AND pg_get_functiondef(p.oid) ILIKE '%created_at%'
  LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS %I ON public.elearning_level_exam_scores',
      r.tgname
    );
    RAISE NOTICE 'Dropped trigger % on elearning_level_exam_scores (referenced created_at)', r.tgname;
  END LOOP;
END $$;

-- Ensure recorded_at exists (idempotent with prior migration)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'elearning_level_exam_scores'
      AND column_name = 'created_at'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'elearning_level_exam_scores'
      AND column_name = 'recorded_at'
  ) THEN
    ALTER TABLE elearning_level_exam_scores
      RENAME COLUMN created_at TO recorded_at;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'elearning_level_exam_scores'
      AND column_name = 'recorded_at'
  ) THEN
    ALTER TABLE elearning_level_exam_scores
      ADD COLUMN recorded_at timestamptz DEFAULT now();
  END IF;
END $$;

-- ---------------------------------------------------------------------------
-- Authoritative upsert — never references created_at
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.upsert_elearning_level_exam_scores(
  p_learner_id uuid,
  p_teacher_id uuid,
  p_level text,
  p_score_po numeric DEFAULT NULL,
  p_score_pe numeric DEFAULT NULL,
  p_score_co numeric DEFAULT NULL,
  p_score_ce numeric DEFAULT NULL,
  p_score_langue numeric DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  learner_id uuid,
  teacher_id uuid,
  level text,
  score_po numeric,
  score_pe numeric,
  score_co numeric,
  score_ce numeric,
  score_langue numeric,
  total_score numeric,
  recorded_at timestamptz,
  updated_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Caller must be the teacher row being written (or admin)
  IF NOT EXISTS (
    SELECT 1 FROM teachers t
    WHERE t.id = p_teacher_id AND t.profile_id = auth.uid()
  ) AND NOT EXISTS (
    SELECT 1 FROM profiles p
    WHERE p.id = auth.uid() AND p.role = 'admin'
  ) THEN
    RAISE EXCEPTION 'not authorized to upsert exam scores';
  END IF;

  RETURN QUERY
  INSERT INTO elearning_level_exam_scores AS s (
    learner_id,
    teacher_id,
    level,
    score_po,
    score_pe,
    score_co,
    score_ce,
    score_langue,
    recorded_at,
    updated_at
  )
  VALUES (
    p_learner_id,
    p_teacher_id,
    p_level,
    p_score_po,
    p_score_pe,
    p_score_co,
    p_score_ce,
    p_score_langue,
    now(),
    now()
  )
  ON CONFLICT (learner_id, level) DO UPDATE SET
    teacher_id = EXCLUDED.teacher_id,
    score_po = EXCLUDED.score_po,
    score_pe = EXCLUDED.score_pe,
    score_co = EXCLUDED.score_co,
    score_ce = EXCLUDED.score_ce,
    score_langue = EXCLUDED.score_langue,
    updated_at = now()
  RETURNING
    s.id,
    s.learner_id,
    s.teacher_id,
    s.level,
    s.score_po,
    s.score_pe,
    s.score_co,
    s.score_ce,
    s.score_langue,
    s.total_score,
    s.recorded_at,
    s.updated_at;
END;
$$;

REVOKE ALL ON FUNCTION public.upsert_elearning_level_exam_scores(
  uuid, uuid, text, numeric, numeric, numeric, numeric, numeric
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.upsert_elearning_level_exam_scores(
  uuid, uuid, text, numeric, numeric, numeric, numeric, numeric
) TO authenticated;

NOTIFY pgrst, 'reload schema';
