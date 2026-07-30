/*
  Module badges: awarded when a learner has validated PE + PO
  lesson submissions for a given module (final production pair).
*/

CREATE TABLE IF NOT EXISTS elearning_module_badges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  module_id uuid NOT NULL REFERENCES elearning_modules(id) ON DELETE CASCADE,
  awarded_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (learner_id, module_id)
);

CREATE INDEX IF NOT EXISTS idx_elearning_module_badges_learner
  ON elearning_module_badges (learner_id);
CREATE INDEX IF NOT EXISTS idx_elearning_module_badges_module
  ON elearning_module_badges (module_id);

COMMENT ON TABLE elearning_module_badges IS
  'Badge unlocked when PE and PO final tasks of a module are validated for a learner';

ALTER TABLE elearning_module_badges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can insert module badges for own modules"
  ON elearning_module_badges FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can read module badges of own modules"
  ON elearning_module_badges FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

CREATE POLICY "Learners can read own module badges"
  ON elearning_module_badges FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM learners l
      WHERE l.id = learner_id AND l.profile_id = auth.uid()
    )
  );

-- Learners need module titles for badges (even if module is unpublished)
DROP POLICY IF EXISTS "Learners can read modules with own badges" ON elearning_modules;
CREATE POLICY "Learners can read modules with own badges"
  ON elearning_modules FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM elearning_module_badges b
      JOIN learners l ON l.id = b.learner_id
      WHERE b.module_id = elearning_modules.id
        AND l.profile_id = auth.uid()
    )
  );

-- Resolve module_id for a lesson
CREATE OR REPLACE FUNCTION public.elearning_lesson_module_id(p_lesson_id uuid)
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT s.module_id
  FROM elearning_lessons l
  JOIN elearning_sequences s ON s.id = l.sequence_id
  WHERE l.id = p_lesson_id;
$$;

REVOKE ALL ON FUNCTION public.elearning_lesson_module_id(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.elearning_lesson_module_id(uuid) TO authenticated;

-- True when learner has at least one validated PE and one validated PO
-- submission among lessons belonging to the module.
CREATE OR REPLACE FUNCTION public.learner_has_validated_pe_po(
  p_learner_id uuid,
  p_module_id uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    EXISTS (
      SELECT 1
      FROM elearning_submissions sub
      JOIN elearning_lessons l ON l.id = sub.lesson_id
      JOIN elearning_sequences s ON s.id = l.sequence_id
      WHERE sub.learner_id = p_learner_id
        AND s.module_id = p_module_id
        AND l.competency = 'PE'
        AND sub.validated = true
    )
    AND EXISTS (
      SELECT 1
      FROM elearning_submissions sub
      JOIN elearning_lessons l ON l.id = sub.lesson_id
      JOIN elearning_sequences s ON s.id = l.sequence_id
      WHERE sub.learner_id = p_learner_id
        AND s.module_id = p_module_id
        AND l.competency = 'PO'
        AND sub.validated = true
    )
    AND EXISTS (
      SELECT 1
      FROM elearning_lessons l
      JOIN elearning_sequences s ON s.id = l.sequence_id
      WHERE s.module_id = p_module_id AND l.competency = 'PE'
    )
    AND EXISTS (
      SELECT 1
      FROM elearning_lessons l
      JOIN elearning_sequences s ON s.id = l.sequence_id
      WHERE s.module_id = p_module_id AND l.competency = 'PO'
    );
$$;

REVOKE ALL ON FUNCTION public.learner_has_validated_pe_po(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.learner_has_validated_pe_po(uuid, uuid) TO authenticated;

-- Award badge if PE+PO complete (idempotent via ON CONFLICT)
CREATE OR REPLACE FUNCTION public.try_award_module_badge(
  p_learner_id uuid,
  p_module_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_learner_id IS NULL OR p_module_id IS NULL THEN
    RETURN false;
  END IF;

  IF NOT public.learner_has_validated_pe_po(p_learner_id, p_module_id) THEN
    RETURN false;
  END IF;

  INSERT INTO elearning_module_badges (learner_id, module_id)
  VALUES (p_learner_id, p_module_id)
  ON CONFLICT (learner_id, module_id) DO NOTHING;

  RETURN true;
END;
$$;

REVOKE ALL ON FUNCTION public.try_award_module_badge(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.try_award_module_badge(uuid, uuid) TO authenticated;

-- Auto-award when a PE/PO submission becomes validated
CREATE OR REPLACE FUNCTION public.award_module_badge_on_submission_validated()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_module_id uuid;
  v_competency text;
BEGIN
  IF NEW.validated IS NOT TRUE THEN
    RETURN NEW;
  END IF;
  IF TG_OP = 'UPDATE' AND OLD.validated IS TRUE THEN
    RETURN NEW;
  END IF;

  SELECT l.competency, public.elearning_lesson_module_id(NEW.lesson_id)
  INTO v_competency, v_module_id
  FROM elearning_lessons l
  WHERE l.id = NEW.lesson_id;

  IF v_competency NOT IN ('PE', 'PO') OR v_module_id IS NULL THEN
    RETURN NEW;
  END IF;

  PERFORM public.try_award_module_badge(NEW.learner_id, v_module_id);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_award_module_badge_on_submission_validated
  ON elearning_submissions;

CREATE TRIGGER trg_award_module_badge_on_submission_validated
  AFTER INSERT OR UPDATE OF validated
  ON elearning_submissions
  FOR EACH ROW
  EXECUTE FUNCTION public.award_module_badge_on_submission_validated();
