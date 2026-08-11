/*
  # Module Révision (Préparation — grammaire / vocabulaire)

  Distinct des épreuves TCF (CO / CE / EE / EO).

  Tables:
  - revision_unites
  - revision_points
  - revision_questions          (bonne_reponse restreinte — pas de SELECT learner)
  - revision_ressources         (1 PDF « trace écrite » par point)
  - student_revision_attempts

  Vue:
  - revision_questions_pour_apprenants (sans bonne_reponse)

  Fonction:
  - correct_student_revision_attempt()  → score /10 (pas de niveau_obtenu)

  Storage:
  - bucket privé revision-pdfs ({point_id}/nom-fichier.pdf, PDF, max 10 Mo)

  Seed:
  - Unité 1 « Conjugaison » + 12 points
  - Unités 2–6 (structure, sans points pour l’instant)
*/

-- ---------------------------------------------------------------------------
-- 1. revision_unites
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.revision_unites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  numero integer NOT NULL UNIQUE,
  titre text NOT NULL,
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS revision_unites_numero_idx
  ON public.revision_unites (numero);

ALTER TABLE public.revision_unites ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can select revision_unites" ON public.revision_unites;
CREATE POLICY "Teachers can select revision_unites"
  ON public.revision_unites FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can insert revision_unites" ON public.revision_unites;
CREATE POLICY "Teachers can insert revision_unites"
  ON public.revision_unites FOR INSERT
  TO authenticated
  WITH CHECK (
    (created_by = auth.uid() OR created_by IS NULL)
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can update revision_unites" ON public.revision_unites;
CREATE POLICY "Teachers can update revision_unites"
  ON public.revision_unites FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
    AND (created_by = auth.uid() OR created_by IS NULL)
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
    AND (created_by = auth.uid() OR created_by IS NULL)
  );

DROP POLICY IF EXISTS "Teachers can delete revision_unites" ON public.revision_unites;
CREATE POLICY "Teachers can delete revision_unites"
  ON public.revision_unites FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
    AND (created_by = auth.uid() OR created_by IS NULL)
  );

DROP POLICY IF EXISTS "Learners can select revision_unites" ON public.revision_unites;
CREATE POLICY "Learners can select revision_unites"
  ON public.revision_unites FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Admins can manage revision_unites" ON public.revision_unites;
CREATE POLICY "Admins can manage revision_unites"
  ON public.revision_unites FOR ALL
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
-- 2. revision_points
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.revision_points (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  unite_id uuid NOT NULL REFERENCES public.revision_unites(id) ON DELETE CASCADE,
  numero integer NOT NULL,
  titre text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (unite_id, numero)
);

CREATE INDEX IF NOT EXISTS revision_points_unite_id_idx
  ON public.revision_points (unite_id);

ALTER TABLE public.revision_points ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can select revision_points" ON public.revision_points;
CREATE POLICY "Teachers can select revision_points"
  ON public.revision_points FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can insert revision_points" ON public.revision_points;
CREATE POLICY "Teachers can insert revision_points"
  ON public.revision_points FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.revision_unites u
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE u.id = unite_id
        AND p.role = 'teacher'
        AND (u.created_by = auth.uid() OR u.created_by IS NULL)
    )
  );

DROP POLICY IF EXISTS "Teachers can update revision_points" ON public.revision_points;
CREATE POLICY "Teachers can update revision_points"
  ON public.revision_points FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.revision_unites u
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE u.id = unite_id
        AND p.role = 'teacher'
        AND (u.created_by = auth.uid() OR u.created_by IS NULL)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.revision_unites u
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE u.id = unite_id
        AND p.role = 'teacher'
        AND (u.created_by = auth.uid() OR u.created_by IS NULL)
    )
  );

DROP POLICY IF EXISTS "Teachers can delete revision_points" ON public.revision_points;
CREATE POLICY "Teachers can delete revision_points"
  ON public.revision_points FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.revision_unites u
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE u.id = unite_id
        AND p.role = 'teacher'
        AND (u.created_by = auth.uid() OR u.created_by IS NULL)
    )
  );

DROP POLICY IF EXISTS "Learners can select revision_points" ON public.revision_points;
CREATE POLICY "Learners can select revision_points"
  ON public.revision_points FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Admins can manage revision_points" ON public.revision_points;
CREATE POLICY "Admins can manage revision_points"
  ON public.revision_points FOR ALL
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
-- 3. revision_questions
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.revision_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  point_id uuid NOT NULL REFERENCES public.revision_points(id) ON DELETE CASCADE,
  ordre integer NOT NULL CHECK (ordre BETWEEN 1 AND 10),
  niveau text NOT NULL CHECK (niveau IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  question_texte text NOT NULL,
  choix_a text NOT NULL,
  choix_b text NOT NULL,
  choix_c text NOT NULL,
  choix_d text NOT NULL,
  bonne_reponse text NOT NULL CHECK (bonne_reponse IN ('a', 'b', 'c', 'd')),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (point_id, ordre)
);

CREATE INDEX IF NOT EXISTS revision_questions_point_id_idx
  ON public.revision_questions (point_id);

ALTER TABLE public.revision_questions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can select revision_questions" ON public.revision_questions;
CREATE POLICY "Teachers can select revision_questions"
  ON public.revision_questions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.revision_points pt
      JOIN public.revision_unites u ON u.id = pt.unite_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE pt.id = point_id
        AND p.role = 'teacher'
        AND (u.created_by = auth.uid() OR u.created_by IS NULL)
    )
  );

DROP POLICY IF EXISTS "Teachers can insert revision_questions" ON public.revision_questions;
CREATE POLICY "Teachers can insert revision_questions"
  ON public.revision_questions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.revision_points pt
      JOIN public.revision_unites u ON u.id = pt.unite_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE pt.id = point_id
        AND p.role = 'teacher'
        AND (u.created_by = auth.uid() OR u.created_by IS NULL)
    )
  );

DROP POLICY IF EXISTS "Teachers can update revision_questions" ON public.revision_questions;
CREATE POLICY "Teachers can update revision_questions"
  ON public.revision_questions FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.revision_points pt
      JOIN public.revision_unites u ON u.id = pt.unite_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE pt.id = point_id
        AND p.role = 'teacher'
        AND (u.created_by = auth.uid() OR u.created_by IS NULL)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.revision_points pt
      JOIN public.revision_unites u ON u.id = pt.unite_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE pt.id = point_id
        AND p.role = 'teacher'
        AND (u.created_by = auth.uid() OR u.created_by IS NULL)
    )
  );

DROP POLICY IF EXISTS "Teachers can delete revision_questions" ON public.revision_questions;
CREATE POLICY "Teachers can delete revision_questions"
  ON public.revision_questions FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.revision_points pt
      JOIN public.revision_unites u ON u.id = pt.unite_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE pt.id = point_id
        AND p.role = 'teacher'
        AND (u.created_by = auth.uid() OR u.created_by IS NULL)
    )
  );

-- IMPORTANT : aucune policy SELECT pour les apprenants sur cette table

DROP POLICY IF EXISTS "Admins can manage revision_questions" ON public.revision_questions;
CREATE POLICY "Admins can manage revision_questions"
  ON public.revision_questions FOR ALL
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
-- 4. Helper : point prêt (10 questions) — SECURITY DEFINER pour RLS / vue
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.revision_point_has_full_quiz(p_point_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT (
    SELECT COUNT(*)::integer
    FROM public.revision_questions
    WHERE point_id = p_point_id
  ) = 10;
$$;

REVOKE ALL ON FUNCTION public.revision_point_has_full_quiz(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.revision_point_has_full_quiz(uuid) TO authenticated;

-- ---------------------------------------------------------------------------
-- 5. Vue apprenants (sans bonne_reponse) — DROP + CREATE
--    Uniquement pour les points « publiés » (10 questions).
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS public.revision_questions_pour_apprenants;

CREATE VIEW public.revision_questions_pour_apprenants
WITH (security_invoker = false) AS
SELECT
  q.id,
  q.point_id,
  q.ordre,
  q.niveau,
  q.question_texte,
  q.choix_a,
  q.choix_b,
  q.choix_c,
  q.choix_d,
  q.created_at
FROM public.revision_questions q
WHERE public.revision_point_has_full_quiz(q.point_id);

REVOKE ALL ON public.revision_questions_pour_apprenants FROM PUBLIC;
GRANT SELECT ON public.revision_questions_pour_apprenants TO authenticated;

-- ---------------------------------------------------------------------------
-- 6. revision_ressources (1 PDF par point)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.revision_ressources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  point_id uuid NOT NULL UNIQUE REFERENCES public.revision_points(id) ON DELETE CASCADE,
  pdf_url text NOT NULL,
  titre text,
  uploaded_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS revision_ressources_point_id_idx
  ON public.revision_ressources (point_id);

ALTER TABLE public.revision_ressources ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can select revision_ressources" ON public.revision_ressources;
CREATE POLICY "Teachers can select revision_ressources"
  ON public.revision_ressources FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can insert revision_ressources" ON public.revision_ressources;
CREATE POLICY "Teachers can insert revision_ressources"
  ON public.revision_ressources FOR INSERT
  TO authenticated
  WITH CHECK (
    uploaded_by = auth.uid()
    AND EXISTS (
      SELECT 1
      FROM public.revision_points pt
      JOIN public.revision_unites u ON u.id = pt.unite_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE pt.id = point_id
        AND p.role = 'teacher'
        AND (u.created_by = auth.uid() OR u.created_by IS NULL)
    )
  );

DROP POLICY IF EXISTS "Teachers can update revision_ressources" ON public.revision_ressources;
CREATE POLICY "Teachers can update revision_ressources"
  ON public.revision_ressources FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.revision_points pt
      JOIN public.revision_unites u ON u.id = pt.unite_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE pt.id = point_id
        AND p.role = 'teacher'
        AND (u.created_by = auth.uid() OR u.created_by IS NULL)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.revision_points pt
      JOIN public.revision_unites u ON u.id = pt.unite_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE pt.id = point_id
        AND p.role = 'teacher'
        AND (u.created_by = auth.uid() OR u.created_by IS NULL)
    )
  );

DROP POLICY IF EXISTS "Teachers can delete revision_ressources" ON public.revision_ressources;
CREATE POLICY "Teachers can delete revision_ressources"
  ON public.revision_ressources FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.revision_points pt
      JOIN public.revision_unites u ON u.id = pt.unite_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE pt.id = point_id
        AND p.role = 'teacher'
        AND (u.created_by = auth.uid() OR u.created_by IS NULL)
    )
  );

DROP POLICY IF EXISTS "Learners can select revision_ressources" ON public.revision_ressources;
CREATE POLICY "Learners can select revision_ressources"
  ON public.revision_ressources FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Admins can manage revision_ressources" ON public.revision_ressources;
CREATE POLICY "Admins can manage revision_ressources"
  ON public.revision_ressources FOR ALL
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
-- 7. student_revision_attempts (1 tentative = 10 questions d'un point)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.student_revision_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  point_id uuid NOT NULL REFERENCES public.revision_points(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reponses jsonb NOT NULL DEFAULT '{}'::jsonb,
  score integer,
  started_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz
);

CREATE INDEX IF NOT EXISTS student_revision_attempts_point_id_idx
  ON public.student_revision_attempts (point_id);

CREATE INDEX IF NOT EXISTS student_revision_attempts_student_id_idx
  ON public.student_revision_attempts (student_id);

ALTER TABLE public.student_revision_attempts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Learners can select own student_revision_attempts" ON public.student_revision_attempts;
CREATE POLICY "Learners can select own student_revision_attempts"
  ON public.student_revision_attempts FOR SELECT
  TO authenticated
  USING (
    student_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Learners can insert own student_revision_attempts" ON public.student_revision_attempts;
CREATE POLICY "Learners can insert own student_revision_attempts"
  ON public.student_revision_attempts FOR INSERT
  TO authenticated
  WITH CHECK (
    student_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
    AND public.revision_point_has_full_quiz(point_id)
  );

DROP POLICY IF EXISTS "Learners can update own student_revision_attempts" ON public.student_revision_attempts;
CREATE POLICY "Learners can update own student_revision_attempts"
  ON public.student_revision_attempts FOR UPDATE
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

DROP POLICY IF EXISTS "Teachers can select revision attempts" ON public.student_revision_attempts;
CREATE POLICY "Teachers can select revision attempts"
  ON public.student_revision_attempts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Admins can manage student_revision_attempts" ON public.student_revision_attempts;
CREATE POLICY "Admins can manage student_revision_attempts"
  ON public.student_revision_attempts FOR ALL
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
-- 8. correct_student_revision_attempt (score /10, pas de niveau_obtenu)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.correct_student_revision_attempt(
  p_attempt_id uuid,
  p_reponses jsonb DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_attempt public.student_revision_attempts%ROWTYPE;
  v_reponses jsonb;
  v_score integer := 0;
  v_total integer := 0;
  v_details jsonb := '[]'::jsonb;
  r record;
  v_given text;
  v_ok boolean;
BEGIN
  SELECT * INTO v_attempt
  FROM public.student_revision_attempts
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
    FROM public.revision_questions q
    WHERE q.point_id = v_attempt.point_id
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

  UPDATE public.student_revision_attempts
  SET
    reponses = v_reponses,
    score = v_score,
    completed_at = now()
  WHERE id = p_attempt_id;

  RETURN jsonb_build_object(
    'attempt_id', p_attempt_id,
    'point_id', v_attempt.point_id,
    'score', v_score,
    'total', v_total,
    'details', v_details
  );
END;
$$;

REVOKE ALL ON FUNCTION public.correct_student_revision_attempt(uuid, jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.correct_student_revision_attempt(uuid, jsonb) TO authenticated;

-- ---------------------------------------------------------------------------
-- 9. Bucket Storage revision-pdfs (privé, PDF, 10 Mo)
--    Chemin : {point_id}/nom-fichier.pdf
-- ---------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'revision-pdfs',
  'revision-pdfs',
  false,
  10485760, -- 10 Mo
  ARRAY['application/pdf']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "revision_pdfs_select" ON storage.objects;
DROP POLICY IF EXISTS "revision_pdfs_insert" ON storage.objects;
DROP POLICY IF EXISTS "revision_pdfs_update" ON storage.objects;
DROP POLICY IF EXISTS "revision_pdfs_delete" ON storage.objects;

-- Lecture : teacher / admin / learner (PDF en lecture seule pour l'apprenant)
CREATE POLICY "revision_pdfs_select" ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'revision-pdfs'
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role IN ('teacher', 'admin', 'learner')
      )
      AND EXISTS (
        SELECT 1
        FROM public.revision_points pt
        WHERE pt.id::text = (storage.foldername(name))[1]
      )
    )
  );

CREATE POLICY "revision_pdfs_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'revision-pdfs'
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
      )
      OR EXISTS (
        SELECT 1
        FROM public.revision_points pt
        JOIN public.revision_unites u ON u.id = pt.unite_id
        JOIN public.profiles p ON p.id = auth.uid()
        WHERE pt.id::text = (storage.foldername(name))[1]
          AND p.role = 'teacher'
          AND (u.created_by = auth.uid() OR u.created_by IS NULL)
      )
    )
  );

CREATE POLICY "revision_pdfs_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'revision-pdfs'
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
      )
      OR EXISTS (
        SELECT 1
        FROM public.revision_points pt
        JOIN public.revision_unites u ON u.id = pt.unite_id
        JOIN public.profiles p ON p.id = auth.uid()
        WHERE pt.id::text = (storage.foldername(name))[1]
          AND p.role = 'teacher'
          AND (u.created_by = auth.uid() OR u.created_by IS NULL)
      )
    )
  )
  WITH CHECK (
    bucket_id = 'revision-pdfs'
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
      )
      OR EXISTS (
        SELECT 1
        FROM public.revision_points pt
        JOIN public.revision_unites u ON u.id = pt.unite_id
        JOIN public.profiles p ON p.id = auth.uid()
        WHERE pt.id::text = (storage.foldername(name))[1]
          AND p.role = 'teacher'
          AND (u.created_by = auth.uid() OR u.created_by IS NULL)
      )
    )
  );

CREATE POLICY "revision_pdfs_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'revision-pdfs'
    AND (
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
      )
      OR EXISTS (
        SELECT 1
        FROM public.revision_points pt
        JOIN public.revision_unites u ON u.id = pt.unite_id
        JOIN public.profiles p ON p.id = auth.uid()
        WHERE pt.id::text = (storage.foldername(name))[1]
          AND p.role = 'teacher'
          AND (u.created_by = auth.uid() OR u.created_by IS NULL)
      )
    )
  );

-- ---------------------------------------------------------------------------
-- 10. Seed : 6 unités + 12 points Conjugaison
-- ---------------------------------------------------------------------------
INSERT INTO public.revision_unites (numero, titre, created_by)
SELECT v.numero, v.titre, NULL
FROM (VALUES
  (1, 'Conjugaison'),
  (2, 'Déterminants et articles'),
  (3, 'Adjectifs et accords'),
  (4, 'Pronoms'),
  (5, 'Prépositions et connecteurs'),
  (6, 'Syntaxe et vocabulaire')
) AS v(numero, titre)
WHERE NOT EXISTS (
  SELECT 1 FROM public.revision_unites u WHERE u.numero = v.numero
);

INSERT INTO public.revision_points (unite_id, numero, titre)
SELECT u.id, v.numero, v.titre
FROM public.revision_unites u
CROSS JOIN (VALUES
  (1,  'Les 3 groupes de verbes et leurs terminaisons'),
  (2,  'Présent de l''indicatif'),
  (3,  'Passé composé vs imparfait'),
  (4,  'Futur simple et futur proche'),
  (5,  'Plus-que-parfait et passé simple'),
  (6,  'Impératif'),
  (7,  'Subjonctif présent'),
  (8,  'Conditionnel présent et passé'),
  (9,  'Participe présent et gérondif'),
  (10, 'Accord du participe passé'),
  (11, 'Voix passive'),
  (12, 'Concordance des temps au discours indirect')
) AS v(numero, titre)
WHERE u.numero = 1
  AND NOT EXISTS (
    SELECT 1
    FROM public.revision_points p
    WHERE p.unite_id = u.id AND p.numero = v.numero
  );

NOTIFY pgrst, 'reload schema';
