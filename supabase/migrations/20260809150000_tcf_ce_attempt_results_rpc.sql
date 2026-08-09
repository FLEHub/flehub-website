/*
  # RPC résultats TCF CE (après tentative)

  get_student_ce_attempt_results(attempt_id) :
  - accessible uniquement au propriétaire (ou admin)
  - recalcule le score, l'enregistre dans student_ce_attempts.score
  - renvoie le détail question par question
*/

CREATE OR REPLACE FUNCTION public.get_student_ce_attempt_results(
  p_attempt_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_attempt public.student_ce_attempts%ROWTYPE;
  v_reponses jsonb;
  v_score integer := 0;
  v_total integer := 0;
  v_details jsonb := '[]'::jsonb;
  v_niveau_obtenu text;
  v_temps integer;
  r record;
  v_given text;
  v_ok boolean;
BEGIN
  SELECT * INTO v_attempt
  FROM public.student_ce_attempts
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

  v_reponses := COALESCE(v_attempt.reponses, '{}'::jsonb);

  FOR r IN
    SELECT
      q.id,
      q.ordre,
      q.niveau,
      q.question_texte,
      q.choix_a,
      q.choix_b,
      q.choix_c,
      q.choix_d,
      q.bonne_reponse
    FROM public.tcf_ce_questions q
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
        'niveau', r.niveau,
        'question_texte', r.question_texte,
        'choix_a', r.choix_a,
        'choix_b', r.choix_b,
        'choix_c', r.choix_c,
        'choix_d', r.choix_d,
        'reponse_donnee', v_given,
        'bonne_reponse', r.bonne_reponse,
        'correct', v_ok
      )
    );
  END LOOP;

  SELECT b.niveau INTO v_niveau_obtenu
  FROM public.tcf_ce_baremes b
  WHERE v_score BETWEEN b.score_min AND b.score_max
  ORDER BY b.score_min
  LIMIT 1;

  v_temps := v_attempt.temps_utilise_secondes;
  IF v_temps IS NULL AND v_attempt.started_at IS NOT NULL THEN
    v_temps := GREATEST(
      0,
      FLOOR(
        EXTRACT(
          EPOCH FROM (COALESCE(v_attempt.completed_at, now()) - v_attempt.started_at)
        )
      )::integer
    );
  END IF;

  UPDATE public.student_ce_attempts
  SET
    score = v_score,
    niveau_obtenu = COALESCE(v_niveau_obtenu, niveau_obtenu),
    temps_utilise_secondes = COALESCE(v_temps, temps_utilise_secondes),
    completed_at = COALESCE(completed_at, now())
  WHERE id = p_attempt_id;

  RETURN jsonb_build_object(
    'attempt_id', p_attempt_id,
    'session_id', v_attempt.session_id,
    'score', v_score,
    'total', v_total,
    'pourcentage', CASE
      WHEN v_total > 0 THEN ROUND((v_score::numeric / v_total::numeric) * 100)
      ELSE 0
    END,
    'niveau_obtenu', v_niveau_obtenu,
    'temps_utilise_secondes', v_temps,
    'completed_at', COALESCE(v_attempt.completed_at, now()),
    'questions', v_details
  );
END;
$$;

REVOKE ALL ON FUNCTION public.get_student_ce_attempt_results(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_student_ce_attempt_results(uuid) TO authenticated;

NOTIFY pgrst, 'reload schema';
