/*
  # TCF CO — niveau par question + barème score → niveau

  1. Retire niveau de tcf_co_sessions
  2. Ajoute niveau (A1–C2) sur tcf_co_questions
  3. Crée tcf_co_baremes + données initiales (40 questions)
  4. Ajoute student_co_attempts.niveau_obtenu
  5. Met à jour correct_student_co_attempt (retourne niveau_obtenu)
  6. Met à jour la vue tcf_co_questions_pour_apprenants
*/

-- ---------------------------------------------------------------------------
-- 1. Niveau sur chaque question
-- ---------------------------------------------------------------------------
ALTER TABLE public.tcf_co_questions
  ADD COLUMN IF NOT EXISTS niveau text;

-- Reprend le niveau de la séance si des questions existent déjà
UPDATE public.tcf_co_questions q
SET niveau = s.niveau
FROM public.tcf_co_sessions s
WHERE s.id = q.session_id
  AND q.niveau IS NULL
  AND s.niveau IS NOT NULL;

-- Défaut de secours si aucune source n'est disponible
UPDATE public.tcf_co_questions
SET niveau = 'B1'
WHERE niveau IS NULL;

ALTER TABLE public.tcf_co_questions
  ALTER COLUMN niveau SET NOT NULL;

ALTER TABLE public.tcf_co_questions
  DROP CONSTRAINT IF EXISTS tcf_co_questions_niveau_check;

ALTER TABLE public.tcf_co_questions
  ADD CONSTRAINT tcf_co_questions_niveau_check
  CHECK (niveau IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2'));

-- ---------------------------------------------------------------------------
-- 2. Retirer niveau de la séance
-- ---------------------------------------------------------------------------
ALTER TABLE public.tcf_co_sessions
  DROP CONSTRAINT IF EXISTS tcf_co_sessions_niveau_check;

ALTER TABLE public.tcf_co_sessions
  DROP COLUMN IF EXISTS niveau;

-- ---------------------------------------------------------------------------
-- 3. Barème score → niveau
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tcf_co_baremes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  score_min integer NOT NULL,
  score_max integer NOT NULL,
  niveau text NOT NULL CHECK (niveau IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  CONSTRAINT tcf_co_baremes_score_range CHECK (score_min <= score_max)
);

CREATE INDEX IF NOT EXISTS tcf_co_baremes_score_idx
  ON public.tcf_co_baremes (score_min, score_max);

ALTER TABLE public.tcf_co_baremes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated can read tcf_co_baremes" ON public.tcf_co_baremes;
CREATE POLICY "Authenticated can read tcf_co_baremes"
  ON public.tcf_co_baremes FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Admins can manage tcf_co_baremes" ON public.tcf_co_baremes;
CREATE POLICY "Admins can manage tcf_co_baremes"
  ON public.tcf_co_baremes FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- Données de départ (ajustables plus tard avec le barème officiel TCF Canada)
INSERT INTO public.tcf_co_baremes (score_min, score_max, niveau)
SELECT * FROM (VALUES
  (0,  9,  'A1'),
  (10, 14, 'A2'),
  (15, 19, 'B1'),
  (20, 24, 'B2'),
  (25, 31, 'C1'),
  (32, 40, 'C2')
) AS v(score_min, score_max, niveau)
WHERE NOT EXISTS (SELECT 1 FROM public.tcf_co_baremes LIMIT 1);

-- ---------------------------------------------------------------------------
-- 4. niveau_obtenu sur les tentatives
-- ---------------------------------------------------------------------------
ALTER TABLE public.student_co_attempts
  ADD COLUMN IF NOT EXISTS niveau_obtenu text;

ALTER TABLE public.student_co_attempts
  DROP CONSTRAINT IF EXISTS student_co_attempts_niveau_obtenu_check;

ALTER TABLE public.student_co_attempts
  ADD CONSTRAINT student_co_attempts_niveau_obtenu_check
  CHECK (
    niveau_obtenu IS NULL
    OR niveau_obtenu IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')
  );

-- ---------------------------------------------------------------------------
-- 5. Vue apprenants : inclure niveau question, toujours sans bonne_reponse
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.tcf_co_questions_pour_apprenants
WITH (security_invoker = false) AS
SELECT
  q.id,
  q.session_id,
  q.ordre,
  q.niveau,
  q.audio_url,
  q.question_texte,
  q.choix_a,
  q.choix_b,
  q.choix_c,
  q.choix_d,
  q.created_at
FROM public.tcf_co_questions q
INNER JOIN public.tcf_co_sessions s ON s.id = q.session_id
WHERE s.statut = 'publiee';

REVOKE ALL ON public.tcf_co_questions_pour_apprenants FROM PUBLIC;
GRANT SELECT ON public.tcf_co_questions_pour_apprenants TO authenticated;

-- ---------------------------------------------------------------------------
-- 6. Correction : score + niveau_obtenu via barème
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.correct_student_co_attempt(
  p_attempt_id uuid,
  p_reponses jsonb DEFAULT NULL,
  p_temps_utilise_secondes integer DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_attempt public.student_co_attempts%ROWTYPE;
  v_reponses jsonb;
  v_score integer := 0;
  v_total integer := 0;
  v_details jsonb := '[]'::jsonb;
  v_niveau_obtenu text;
  r record;
  v_given text;
  v_ok boolean;
BEGIN
  SELECT * INTO v_attempt
  FROM public.student_co_attempts
  WHERE id = p_attempt_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Tentative introuvable';
  END IF;

  IF v_attempt.student_id <> auth.uid()
     AND NOT EXISTS (
       SELECT 1 FROM public.profiles p
       WHERE p.id = auth.uid() AND p.role = 'admin'
     )
  THEN
    RAISE EXCEPTION 'Accès refusé';
  END IF;

  IF v_attempt.completed_at IS NOT NULL THEN
    RAISE EXCEPTION 'Cette tentative est déjà terminée';
  END IF;

  v_reponses := COALESCE(p_reponses, v_attempt.reponses, '{}'::jsonb);

  FOR r IN
    SELECT q.id, q.ordre, q.bonne_reponse
    FROM public.tcf_co_questions q
    WHERE q.session_id = v_attempt.session_id
    ORDER BY q.ordre
  LOOP
    v_total := v_total + 1;
    v_given := COALESCE(
      v_reponses ->> r.id::text,
      v_reponses ->> r.ordre::text
    );
    v_ok := (v_given IS NOT NULL AND lower(v_given) = r.bonne_reponse);

    IF v_ok THEN
      v_score := v_score + 1;
    END IF;

    v_details := v_details || jsonb_build_array(
      jsonb_build_object(
        'question_id', r.id,
        'ordre', r.ordre,
        'reponse_donnee', v_given,
        'bonne_reponse', r.bonne_reponse,
        'correct', v_ok
      )
    );
  END LOOP;

  SELECT b.niveau INTO v_niveau_obtenu
  FROM public.tcf_co_baremes b
  WHERE v_score BETWEEN b.score_min AND b.score_max
  ORDER BY b.score_min
  LIMIT 1;

  UPDATE public.student_co_attempts
  SET
    reponses = v_reponses,
    score = v_score,
    niveau_obtenu = v_niveau_obtenu,
    temps_utilise_secondes = COALESCE(p_temps_utilise_secondes, temps_utilise_secondes),
    completed_at = now()
  WHERE id = p_attempt_id;

  RETURN jsonb_build_object(
    'attempt_id', p_attempt_id,
    'score', v_score,
    'total', v_total,
    'niveau_obtenu', v_niveau_obtenu,
    'details', v_details
  );
END;
$$;

REVOKE ALL ON FUNCTION public.correct_student_co_attempt(uuid, jsonb, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.correct_student_co_attempt(uuid, jsonb, integer) TO authenticated;

NOTIFY pgrst, 'reload schema';
