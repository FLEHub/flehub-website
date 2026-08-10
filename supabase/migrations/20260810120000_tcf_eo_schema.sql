/*
  # TCF Expression Orale (EO)

  Séance de préparation à un rendez-vous EO (distincte des Sessions
  de visioconférence existantes).

  Tables:
  - tcf_eo_sessions
  - tcf_eo_sujets              (banque tâches 2 et 3)
  - student_eo_evaluations     (notation post-visio)

  Rôles FLEHub:
  - préparateur = profiles.role = 'teacher'
  - apprenant   = profiles.role = 'learner'
  - admin       = profiles.role = 'admin'
*/

-- ---------------------------------------------------------------------------
-- 1. tcf_eo_sessions
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tcf_eo_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  titre text NOT NULL,
  statut text NOT NULL DEFAULT 'brouillon' CHECK (statut IN ('brouillon', 'publiee')),
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS tcf_eo_sessions_created_by_idx
  ON public.tcf_eo_sessions (created_by);

CREATE INDEX IF NOT EXISTS tcf_eo_sessions_statut_idx
  ON public.tcf_eo_sessions (statut);

ALTER TABLE public.tcf_eo_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can select own tcf_eo_sessions" ON public.tcf_eo_sessions;
CREATE POLICY "Teachers can select own tcf_eo_sessions"
  ON public.tcf_eo_sessions FOR SELECT
  TO authenticated
  USING (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can insert own tcf_eo_sessions" ON public.tcf_eo_sessions;
CREATE POLICY "Teachers can insert own tcf_eo_sessions"
  ON public.tcf_eo_sessions FOR INSERT
  TO authenticated
  WITH CHECK (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can update own tcf_eo_sessions" ON public.tcf_eo_sessions;
CREATE POLICY "Teachers can update own tcf_eo_sessions"
  ON public.tcf_eo_sessions FOR UPDATE
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

DROP POLICY IF EXISTS "Teachers can delete own tcf_eo_sessions" ON public.tcf_eo_sessions;
CREATE POLICY "Teachers can delete own tcf_eo_sessions"
  ON public.tcf_eo_sessions FOR DELETE
  TO authenticated
  USING (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Learners can select published tcf_eo_sessions" ON public.tcf_eo_sessions;
CREATE POLICY "Learners can select published tcf_eo_sessions"
  ON public.tcf_eo_sessions FOR SELECT
  TO authenticated
  USING (
    statut = 'publiee'
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Admins can manage tcf_eo_sessions" ON public.tcf_eo_sessions;
CREATE POLICY "Admins can manage tcf_eo_sessions"
  ON public.tcf_eo_sessions FOR ALL
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
-- 2. tcf_eo_sujets (banque de sujets — tâches 2 et 3 uniquement)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tcf_eo_sujets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES public.tcf_eo_sessions(id) ON DELETE CASCADE,
  tache integer NOT NULL CHECK (tache IN (2, 3)),
  enonce text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS tcf_eo_sujets_session_id_idx
  ON public.tcf_eo_sujets (session_id);

CREATE INDEX IF NOT EXISTS tcf_eo_sujets_tache_idx
  ON public.tcf_eo_sujets (tache);

ALTER TABLE public.tcf_eo_sujets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can select own tcf_eo_sujets" ON public.tcf_eo_sujets;
CREATE POLICY "Teachers can select own tcf_eo_sujets"
  ON public.tcf_eo_sujets FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_eo_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can insert own tcf_eo_sujets" ON public.tcf_eo_sujets;
CREATE POLICY "Teachers can insert own tcf_eo_sujets"
  ON public.tcf_eo_sujets FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.tcf_eo_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can update own tcf_eo_sujets" ON public.tcf_eo_sujets;
CREATE POLICY "Teachers can update own tcf_eo_sujets"
  ON public.tcf_eo_sujets FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_eo_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.tcf_eo_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can delete own tcf_eo_sujets" ON public.tcf_eo_sujets;
CREATE POLICY "Teachers can delete own tcf_eo_sujets"
  ON public.tcf_eo_sujets FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_eo_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

-- Apprenant : lecture des sujets des séances publiées (tâches 2 et 3)
DROP POLICY IF EXISTS "Learners can select sujets of published tcf_eo_sessions" ON public.tcf_eo_sujets;
CREATE POLICY "Learners can select sujets of published tcf_eo_sessions"
  ON public.tcf_eo_sujets FOR SELECT
  TO authenticated
  USING (
    tache IN (2, 3)
    AND EXISTS (
      SELECT 1
      FROM public.tcf_eo_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.statut = 'publiee'
        AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Admins can manage tcf_eo_sujets" ON public.tcf_eo_sujets;
CREATE POLICY "Admins can manage tcf_eo_sujets"
  ON public.tcf_eo_sujets FOR ALL
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
-- 3. student_eo_evaluations (notation post-visio par le préparateur)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.student_eo_evaluations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES public.tcf_eo_sessions(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  evaluated_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  score_interaction integer CHECK (
    score_interaction IS NULL OR score_interaction BETWEEN 0 AND 10
  ),
  score_fluidite integer CHECK (
    score_fluidite IS NULL OR score_fluidite BETWEEN 0 AND 10
  ),
  score_structure integer CHECK (
    score_structure IS NULL OR score_structure BETWEEN 0 AND 10
  ),
  score_vocabulaire integer CHECK (
    score_vocabulaire IS NULL OR score_vocabulaire BETWEEN 0 AND 10
  ),
  score_grammaire integer CHECK (
    score_grammaire IS NULL OR score_grammaire BETWEEN 0 AND 10
  ),
  score_prononciation integer CHECK (
    score_prononciation IS NULL OR score_prononciation BETWEEN 0 AND 10
  ),
  commentaire_general text,
  evaluated_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS student_eo_evaluations_session_id_idx
  ON public.student_eo_evaluations (session_id);

CREATE INDEX IF NOT EXISTS student_eo_evaluations_student_id_idx
  ON public.student_eo_evaluations (student_id);

CREATE INDEX IF NOT EXISTS student_eo_evaluations_evaluated_by_idx
  ON public.student_eo_evaluations (evaluated_by);

ALTER TABLE public.student_eo_evaluations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can select eo evaluations on own sessions" ON public.student_eo_evaluations;
CREATE POLICY "Teachers can select eo evaluations on own sessions"
  ON public.student_eo_evaluations FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_eo_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can insert eo evaluations on own sessions" ON public.student_eo_evaluations;
CREATE POLICY "Teachers can insert eo evaluations on own sessions"
  ON public.student_eo_evaluations FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.tcf_eo_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
    AND (
      evaluated_by IS NULL
      OR evaluated_by = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Teachers can update eo evaluations on own sessions" ON public.student_eo_evaluations;
CREATE POLICY "Teachers can update eo evaluations on own sessions"
  ON public.student_eo_evaluations FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_eo_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.tcf_eo_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
    AND (
      evaluated_by IS NULL
      OR evaluated_by = auth.uid()
    )
  );

-- Apprenant : lecture de ses évaluations une fois publiées (evaluated_at rempli)
DROP POLICY IF EXISTS "Learners can select own published student_eo_evaluations" ON public.student_eo_evaluations;
CREATE POLICY "Learners can select own published student_eo_evaluations"
  ON public.student_eo_evaluations FOR SELECT
  TO authenticated
  USING (
    evaluated_at IS NOT NULL
    AND student_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Admins can manage student_eo_evaluations" ON public.student_eo_evaluations;
CREATE POLICY "Admins can manage student_eo_evaluations"
  ON public.student_eo_evaluations FOR ALL
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

NOTIFY pgrst, 'reload schema';
