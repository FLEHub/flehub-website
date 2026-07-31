/*
  Fix 42702 ambiguous learner_id in upsert_elearning_level_exam_scores.

  RETURNS TABLE(id, learner_id, ...) creates PL/pgSQL variables that collide
  with table columns in ON CONFLICT (learner_id, level). Rename outputs to out_*.
  DROP required: CREATE OR REPLACE cannot change the return row type.
*/

DROP FUNCTION IF EXISTS public.upsert_elearning_level_exam_scores(
  uuid, uuid, text, numeric, numeric, numeric, numeric, numeric
);

CREATE FUNCTION public.upsert_elearning_level_exam_scores(
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
  out_id uuid,
  out_learner_id uuid,
  out_teacher_id uuid,
  out_level text,
  out_score_po numeric,
  out_score_pe numeric,
  out_score_co numeric,
  out_score_ce numeric,
  out_score_langue numeric,
  out_total_score numeric,
  out_recorded_at timestamptz,
  out_updated_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
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
