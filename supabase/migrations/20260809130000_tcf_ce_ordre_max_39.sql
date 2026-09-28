/*
  # TCF CE — 39 questions (épreuve officielle)

  1. ordre : CHECK BETWEEN 1 AND 39 (au lieu de 40)
  2. barème C2 : score_max 39 (au lieu de 40) → tranche 32–39 → C2
*/

-- ---------------------------------------------------------------------------
-- 1. Contrainte ordre (1–39)
-- ---------------------------------------------------------------------------
ALTER TABLE public.tcf_ce_questions
  DROP CONSTRAINT IF EXISTS tcf_ce_questions_ordre_check;

ALTER TABLE public.tcf_ce_questions
  ADD CONSTRAINT tcf_ce_questions_ordre_check
  CHECK (ordre BETWEEN 1 AND 39);

-- ---------------------------------------------------------------------------
-- 2. Barème : dernière tranche C2 → 32–39 (cohérent avec un max de 39)
-- ---------------------------------------------------------------------------
UPDATE public.tcf_ce_baremes
SET score_max = 39
WHERE niveau = 'C2'
  AND score_min = 32
  AND score_max = 40;
