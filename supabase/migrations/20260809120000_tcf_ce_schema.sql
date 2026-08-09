/*
  # TCF Compréhension Écrite (CE)

  Même modèle que TCF CO, avec image (image_url) à la place de l'audio.

  Tables:
  - tcf_ce_sessions
  - tcf_ce_questions          (bonne_reponse restreinte — pas de SELECT learner)
  - student_ce_attempts
  - tcf_ce_baremes

  Vue:
  - tcf_ce_questions_pour_apprenants (sans bonne_reponse, sessions publiées)

  Fonction:
  - correct_student_ce_attempt()

  Storage:
  - bucket privé tcf-ce-images ({session_id}/fichier.jpg|png, max 5 Mo)
*/

-- ---------------------------------------------------------------------------
-- 1. tcf_ce_sessions (pas de colonne niveau)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tcf_ce_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  titre text NOT NULL,
  duree_minuteur integer NOT NULL CHECK (duree_minuteur > 0),
  statut text NOT NULL DEFAULT 'brouillon' CHECK (statut IN ('brouillon', 'publiee')),
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS tcf_ce_sessions_created_by_idx
  ON public.tcf_ce_sessions (created_by);

CREATE INDEX IF NOT EXISTS tcf_ce_sessions_statut_idx
  ON public.tcf_ce_sessions (statut);

ALTER TABLE public.tcf_ce_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can select own tcf_ce_sessions" ON public.tcf_ce_sessions;
CREATE POLICY "Teachers can select own tcf_ce_sessions"
  ON public.tcf_ce_sessions FOR SELECT
  TO authenticated
  USING (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can insert own tcf_ce_sessions" ON public.tcf_ce_sessions;
CREATE POLICY "Teachers can insert own tcf_ce_sessions"
  ON public.tcf_ce_sessions FOR INSERT
  TO authenticated
  WITH CHECK (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can update own tcf_ce_sessions" ON public.tcf_ce_sessions;
CREATE POLICY "Teachers can update own tcf_ce_sessions"
  ON public.tcf_ce_sessions FOR UPDATE
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

DROP POLICY IF EXISTS "Teachers can delete own tcf_ce_sessions" ON public.tcf_ce_sessions;
CREATE POLICY "Teachers can delete own tcf_ce_sessions"
  ON public.tcf_ce_sessions FOR DELETE
  TO authenticated
  USING (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Learners can select published tcf_ce_sessions" ON public.tcf_ce_sessions;
CREATE POLICY "Learners can select published tcf_ce_sessions"
  ON public.tcf_ce_sessions FOR SELECT
  TO authenticated
  USING (
    statut = 'publiee'
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Admins can manage tcf_ce_sessions" ON public.tcf_ce_sessions;
CREATE POLICY "Admins can manage tcf_ce_sessions"
  ON public.tcf_ce_sessions FOR ALL
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
-- 2. tcf_ce_questions (niveau par question + image_url, pas d'audio)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tcf_ce_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES public.tcf_ce_sessions(id) ON DELETE CASCADE,
  ordre integer NOT NULL CHECK (ordre BETWEEN 1 AND 40),
  niveau text NOT NULL CHECK (niveau IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  image_url text NOT NULL,
  question_texte text NOT NULL,
  choix_a text NOT NULL,
  choix_b text NOT NULL,
  choix_c text NOT NULL,
  choix_d text NOT NULL,
  bonne_reponse text NOT NULL CHECK (bonne_reponse IN ('a', 'b', 'c', 'd')),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (session_id, ordre)
);

CREATE INDEX IF NOT EXISTS tcf_ce_questions_session_id_idx
  ON public.tcf_ce_questions (session_id);

ALTER TABLE public.tcf_ce_questions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can select own tcf_ce_questions" ON public.tcf_ce_questions;
CREATE POLICY "Teachers can select own tcf_ce_questions"
  ON public.tcf_ce_questions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_ce_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can insert own tcf_ce_questions" ON public.tcf_ce_questions;
CREATE POLICY "Teachers can insert own tcf_ce_questions"
  ON public.tcf_ce_questions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.tcf_ce_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can update own tcf_ce_questions" ON public.tcf_ce_questions;
CREATE POLICY "Teachers can update own tcf_ce_questions"
  ON public.tcf_ce_questions FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_ce_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.tcf_ce_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can delete own tcf_ce_questions" ON public.tcf_ce_questions;
CREATE POLICY "Teachers can delete own tcf_ce_questions"
  ON public.tcf_ce_questions FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_ce_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

-- IMPORTANT : aucune policy SELECT pour les apprenants sur cette table

DROP POLICY IF EXISTS "Admins can manage tcf_ce_questions" ON public.tcf_ce_questions;
CREATE POLICY "Admins can manage tcf_ce_questions"
  ON public.tcf_ce_questions FOR ALL
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
-- 3. Vue apprenants (sans bonne_reponse) — DROP + CREATE
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS public.tcf_ce_questions_pour_apprenants;

CREATE VIEW public.tcf_ce_questions_pour_apprenants
WITH (security_invoker = false) AS
SELECT
  q.id,
  q.session_id,
  q.ordre,
  q.niveau,
  q.image_url,
  q.question_texte,
  q.choix_a,
  q.choix_b,
  q.choix_c,
  q.choix_d,
  q.created_at
FROM public.tcf_ce_questions q
INNER JOIN public.tcf_ce_sessions s ON s.id = q.session_id
WHERE s.statut = 'publiee';

REVOKE ALL ON public.tcf_ce_questions_pour_apprenants FROM PUBLIC;
GRANT SELECT ON public.tcf_ce_questions_pour_apprenants TO authenticated;

-- ---------------------------------------------------------------------------
-- 4. student_ce_attempts
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.student_ce_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES public.tcf_ce_sessions(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reponses jsonb NOT NULL DEFAULT '{}'::jsonb,
  score integer,
  niveau_obtenu text CHECK (
    niveau_obtenu IS NULL
    OR niveau_obtenu IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')
  ),
  temps_utilise_secondes integer,
  started_at timestamptz DEFAULT now(),
  completed_at timestamptz
);

CREATE INDEX IF NOT EXISTS student_ce_attempts_session_id_idx
  ON public.student_ce_attempts (session_id);

CREATE INDEX IF NOT EXISTS student_ce_attempts_student_id_idx
  ON public.student_ce_attempts (student_id);

ALTER TABLE public.student_ce_attempts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Learners can select own student_ce_attempts" ON public.student_ce_attempts;
CREATE POLICY "Learners can select own student_ce_attempts"
  ON public.student_ce_attempts FOR SELECT
  TO authenticated
  USING (
    student_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Learners can insert own student_ce_attempts" ON public.student_ce_attempts;
CREATE POLICY "Learners can insert own student_ce_attempts"
  ON public.student_ce_attempts FOR INSERT
  TO authenticated
  WITH CHECK (
    student_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
    AND EXISTS (
      SELECT 1 FROM public.tcf_ce_sessions s
      WHERE s.id = session_id AND s.statut = 'publiee'
    )
  );

DROP POLICY IF EXISTS "Learners can update own student_ce_attempts" ON public.student_ce_attempts;
CREATE POLICY "Learners can update own student_ce_attempts"
  ON public.student_ce_attempts FOR UPDATE
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

DROP POLICY IF EXISTS "Teachers can select ce attempts on own sessions" ON public.student_ce_attempts;
CREATE POLICY "Teachers can select ce attempts on own sessions"
  ON public.student_ce_attempts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_ce_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Admins can manage student_ce_attempts" ON public.student_ce_attempts;
CREATE POLICY "Admins can manage student_ce_attempts"
  ON public.student_ce_attempts FOR ALL
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
-- 5. tcf_ce_baremes + seed (même grille que tcf_co_baremes)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tcf_ce_baremes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  score_min integer NOT NULL,
  score_max integer NOT NULL,
  niveau text NOT NULL CHECK (niveau IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  CONSTRAINT tcf_ce_baremes_score_range CHECK (score_min <= score_max)
);

CREATE INDEX IF NOT EXISTS tcf_ce_baremes_score_idx
  ON public.tcf_ce_baremes (score_min, score_max);

ALTER TABLE public.tcf_ce_baremes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated can read tcf_ce_baremes" ON public.tcf_ce_baremes;
CREATE POLICY "Authenticated can read tcf_ce_baremes"
  ON public.tcf_ce_baremes FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Admins can manage tcf_ce_baremes" ON public.tcf_ce_baremes;
CREATE POLICY "Admins can manage tcf_ce_baremes"
  ON public.tcf_ce_baremes FOR ALL
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

INSERT INTO public.tcf_ce_baremes (score_min, score_max, niveau)
SELECT * FROM (VALUES
  (0,  9,  'A1'),
  (10, 14, 'A2'),
  (15, 19, 'B1'),
  (20, 24, 'B2'),
  (25, 31, 'C1'),
  (32, 40, 'C2')
) AS v(score_min, score_max, niveau)
WHERE NOT EXISTS (SELECT 1 FROM public.tcf_ce_baremes LIMIT 1);

-- ---------------------------------------------------------------------------
-- 6. correct_student_ce_attempt
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.correct_student_ce_attempt(
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
  v_attempt public.student_ce_attempts%ROWTYPE;
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

  IF v_attempt.completed_at IS NOT NULL THEN
    RAISE EXCEPTION 'Cette tentative est déjà terminée';
  END IF;

  v_reponses := COALESCE(p_reponses, v_attempt.reponses, '{}'::jsonb);

  FOR r IN
    SELECT q.id, q.ordre, q.bonne_reponse
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

  UPDATE public.student_ce_attempts
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

REVOKE ALL ON FUNCTION public.correct_student_ce_attempt(uuid, jsonb, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.correct_student_ce_attempt(uuid, jsonb, integer) TO authenticated;

-- ---------------------------------------------------------------------------
-- 7. Bucket Storage tcf-ce-images (privé, images, 5 Mo)
--    Chemin : {session_id}/{filename}.jpg|jpeg|png
-- ---------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'tcf-ce-images',
  'tcf-ce-images',
  false,
  5242880, -- 5 Mo
  ARRAY[
    'image/jpeg',
    'image/jpg',
    'image/png'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "tcf_ce_images_select" ON storage.objects;
DROP POLICY IF EXISTS "tcf_ce_images_insert" ON storage.objects;
DROP POLICY IF EXISTS "tcf_ce_images_update" ON storage.objects;
DROP POLICY IF EXISTS "tcf_ce_images_delete" ON storage.objects;

CREATE POLICY "tcf_ce_images_select" ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'tcf-ce-images'
    AND (
      EXISTS (
        SELECT 1
        FROM public.tcf_ce_sessions s
        WHERE s.id::text = (storage.foldername(name))[1]
          AND (
            s.statut = 'publiee'
            OR s.created_by = auth.uid()
            OR EXISTS (
              SELECT 1 FROM public.profiles p
              WHERE p.id = auth.uid() AND p.role = 'admin'
            )
          )
      )
    )
  );

CREATE POLICY "tcf_ce_images_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'tcf-ce-images'
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
      )
      OR EXISTS (
        SELECT 1
        FROM public.tcf_ce_sessions s
        JOIN public.profiles p ON p.id = auth.uid()
        WHERE s.id::text = (storage.foldername(name))[1]
          AND s.created_by = auth.uid()
          AND p.role = 'teacher'
      )
    )
  );

CREATE POLICY "tcf_ce_images_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'tcf-ce-images'
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
      )
      OR EXISTS (
        SELECT 1
        FROM public.tcf_ce_sessions s
        JOIN public.profiles p ON p.id = auth.uid()
        WHERE s.id::text = (storage.foldername(name))[1]
          AND s.created_by = auth.uid()
          AND p.role = 'teacher'
      )
    )
  )
  WITH CHECK (
    bucket_id = 'tcf-ce-images'
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
      )
      OR EXISTS (
        SELECT 1
        FROM public.tcf_ce_sessions s
        JOIN public.profiles p ON p.id = auth.uid()
        WHERE s.id::text = (storage.foldername(name))[1]
          AND s.created_by = auth.uid()
          AND p.role = 'teacher'
      )
    )
  );

CREATE POLICY "tcf_ce_images_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'tcf-ce-images'
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
      )
      OR EXISTS (
        SELECT 1
        FROM public.tcf_ce_sessions s
        JOIN public.profiles p ON p.id = auth.uid()
        WHERE s.id::text = (storage.foldername(name))[1]
          AND s.created_by = auth.uid()
          AND p.role = 'teacher'
      )
    )
  );

NOTIFY pgrst, 'reload schema';
