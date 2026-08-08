/*
  # TCF Compréhension Orale (CO)

  Tables:
  - tcf_co_sessions      : sessions de test CO créées par les préparateurs
  - tcf_co_questions     : questions (avec bonne_reponse, accès restreint)
  - student_co_attempts  : tentatives des apprenants

  Accès réponses:
  - Les apprenants ne SELECT pas tcf_co_questions (donc jamais bonne_reponse).
  - Ils lisent via la vue tcf_co_questions_pour_apprenants (sans bonne_reponse).
  - Correction via la fonction SECURITY DEFINER correct_student_co_attempt().

  Rôles FLEHub:
  - préparateur = profiles.role = 'teacher'
  - apprenant   = profiles.role = 'learner'
*/

-- ---------------------------------------------------------------------------
-- 1. tcf_co_sessions
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tcf_co_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  titre text NOT NULL,
  niveau text NOT NULL CHECK (niveau IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  duree_minuteur integer NOT NULL CHECK (duree_minuteur > 0),
  statut text NOT NULL DEFAULT 'brouillon' CHECK (statut IN ('brouillon', 'publiee')),
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS tcf_co_sessions_created_by_idx
  ON public.tcf_co_sessions (created_by);

CREATE INDEX IF NOT EXISTS tcf_co_sessions_statut_idx
  ON public.tcf_co_sessions (statut);

ALTER TABLE public.tcf_co_sessions ENABLE ROW LEVEL SECURITY;

-- Préparateur : CRUD sur ses propres sessions
CREATE POLICY "Teachers can select own tcf_co_sessions"
  ON public.tcf_co_sessions FOR SELECT
  TO authenticated
  USING (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

CREATE POLICY "Teachers can insert own tcf_co_sessions"
  ON public.tcf_co_sessions FOR INSERT
  TO authenticated
  WITH CHECK (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

CREATE POLICY "Teachers can update own tcf_co_sessions"
  ON public.tcf_co_sessions FOR UPDATE
  TO authenticated
  USING (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  )
  WITH CHECK (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

CREATE POLICY "Teachers can delete own tcf_co_sessions"
  ON public.tcf_co_sessions FOR DELETE
  TO authenticated
  USING (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

-- Apprenant : lecture seule des sessions publiées
CREATE POLICY "Learners can select published tcf_co_sessions"
  ON public.tcf_co_sessions FOR SELECT
  TO authenticated
  USING (
    statut = 'publiee'
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

-- Admin : accès complet
CREATE POLICY "Admins can manage tcf_co_sessions"
  ON public.tcf_co_sessions FOR ALL
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

-- ---------------------------------------------------------------------------
-- 2. tcf_co_questions
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tcf_co_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES public.tcf_co_sessions(id) ON DELETE CASCADE,
  ordre integer NOT NULL CHECK (ordre BETWEEN 1 AND 40),
  audio_url text NOT NULL,
  question_texte text NOT NULL,
  choix_a text NOT NULL,
  choix_b text NOT NULL,
  choix_c text NOT NULL,
  choix_d text NOT NULL,
  bonne_reponse text NOT NULL CHECK (bonne_reponse IN ('a', 'b', 'c', 'd')),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (session_id, ordre)
);

CREATE INDEX IF NOT EXISTS tcf_co_questions_session_id_idx
  ON public.tcf_co_questions (session_id);

ALTER TABLE public.tcf_co_questions ENABLE ROW LEVEL SECURITY;

-- Préparateur : CRUD sur les questions de ses sessions
CREATE POLICY "Teachers can select own tcf_co_questions"
  ON public.tcf_co_questions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_co_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

CREATE POLICY "Teachers can insert own tcf_co_questions"
  ON public.tcf_co_questions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.tcf_co_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

CREATE POLICY "Teachers can update own tcf_co_questions"
  ON public.tcf_co_questions FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_co_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.tcf_co_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

CREATE POLICY "Teachers can delete own tcf_co_questions"
  ON public.tcf_co_questions FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_co_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

-- IMPORTANT : aucune policy SELECT pour les apprenants sur cette table
-- (évite l'exposition de bonne_reponse via l'API PostgREST)

CREATE POLICY "Admins can manage tcf_co_questions"
  ON public.tcf_co_questions FOR ALL
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

-- ---------------------------------------------------------------------------
-- Vue sans bonne_reponse pour les apprenants (sessions publiées uniquement)
-- security_invoker = false : exécutée avec les droits du propriétaire,
-- ce qui contourne le RLS de la table tout en filtrant statut = 'publiee'.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.tcf_co_questions_pour_apprenants
WITH (security_invoker = false) AS
SELECT
  q.id,
  q.session_id,
  q.ordre,
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
-- 3. student_co_attempts
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.student_co_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES public.tcf_co_sessions(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reponses jsonb NOT NULL DEFAULT '{}'::jsonb,
  score integer,
  temps_utilise_secondes integer,
  started_at timestamptz DEFAULT now(),
  completed_at timestamptz
);

CREATE INDEX IF NOT EXISTS student_co_attempts_session_id_idx
  ON public.student_co_attempts (session_id);

CREATE INDEX IF NOT EXISTS student_co_attempts_student_id_idx
  ON public.student_co_attempts (student_id);

ALTER TABLE public.student_co_attempts ENABLE ROW LEVEL SECURITY;

-- Apprenant : voir / créer / mettre à jour ses propres tentatives
CREATE POLICY "Learners can select own student_co_attempts"
  ON public.student_co_attempts FOR SELECT
  TO authenticated
  USING (
    student_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

CREATE POLICY "Learners can insert own student_co_attempts"
  ON public.student_co_attempts FOR INSERT
  TO authenticated
  WITH CHECK (
    student_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
    AND EXISTS (
      SELECT 1 FROM public.tcf_co_sessions s
      WHERE s.id = session_id AND s.statut = 'publiee'
    )
  );

CREATE POLICY "Learners can update own student_co_attempts"
  ON public.student_co_attempts FOR UPDATE
  TO authenticated
  USING (
    student_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  )
  WITH CHECK (
    student_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

-- Préparateur : voir les tentatives sur ses sessions
CREATE POLICY "Teachers can select attempts on own sessions"
  ON public.student_co_attempts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_co_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

CREATE POLICY "Admins can manage student_co_attempts"
  ON public.student_co_attempts FOR ALL
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

-- ---------------------------------------------------------------------------
-- 4. Correction sécurisée (sans exposer bonne_reponse via SELECT table)
--
-- p_reponses attend un objet JSON du type :
--   { "<question_id>": "a"|"b"|"c"|"d", ... }
--   ou { "<ordre>": "a"|"b"|"c"|"d", ... }
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

  -- Seul l'apprenant propriétaire (ou un admin) peut corriger
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

  UPDATE public.student_co_attempts
  SET
    reponses = v_reponses,
    score = v_score,
    temps_utilise_secondes = COALESCE(p_temps_utilise_secondes, temps_utilise_secondes),
    completed_at = now()
  WHERE id = p_attempt_id;

  RETURN jsonb_build_object(
    'attempt_id', p_attempt_id,
    'score', v_score,
    'total', v_total,
    'details', v_details
  );
END;
$$;

REVOKE ALL ON FUNCTION public.correct_student_co_attempt(uuid, jsonb, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.correct_student_co_attempt(uuid, jsonb, integer) TO authenticated;

NOTIFY pgrst, 'reload schema';
