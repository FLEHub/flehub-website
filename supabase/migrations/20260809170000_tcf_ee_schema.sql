/*
  # TCF Expression Écrite (EE)

  Séances complètes à 3 tâches, sans niveau global (comme CO / CE).

  Tables:
  - tcf_ee_sessions
  - tcf_ee_taches
  - student_ee_attempts
  - student_ee_reponses
  - ee_corrections

  Rôles FLEHub:
  - préparateur = profiles.role = 'teacher'
  - apprenant   = profiles.role = 'learner'
  - admin       = profiles.role = 'admin'
*/

-- ---------------------------------------------------------------------------
-- 1. tcf_ee_sessions (pas de colonne niveau)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tcf_ee_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  titre text NOT NULL,
  duree_minuteur integer NOT NULL DEFAULT 60 CHECK (duree_minuteur > 0),
  statut text NOT NULL DEFAULT 'brouillon' CHECK (statut IN ('brouillon', 'publiee')),
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS tcf_ee_sessions_created_by_idx
  ON public.tcf_ee_sessions (created_by);

CREATE INDEX IF NOT EXISTS tcf_ee_sessions_statut_idx
  ON public.tcf_ee_sessions (statut);

ALTER TABLE public.tcf_ee_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can select own tcf_ee_sessions" ON public.tcf_ee_sessions;
CREATE POLICY "Teachers can select own tcf_ee_sessions"
  ON public.tcf_ee_sessions FOR SELECT
  TO authenticated
  USING (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can insert own tcf_ee_sessions" ON public.tcf_ee_sessions;
CREATE POLICY "Teachers can insert own tcf_ee_sessions"
  ON public.tcf_ee_sessions FOR INSERT
  TO authenticated
  WITH CHECK (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can update own tcf_ee_sessions" ON public.tcf_ee_sessions;
CREATE POLICY "Teachers can update own tcf_ee_sessions"
  ON public.tcf_ee_sessions FOR UPDATE
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

DROP POLICY IF EXISTS "Teachers can delete own tcf_ee_sessions" ON public.tcf_ee_sessions;
CREATE POLICY "Teachers can delete own tcf_ee_sessions"
  ON public.tcf_ee_sessions FOR DELETE
  TO authenticated
  USING (
    created_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Learners can select published tcf_ee_sessions" ON public.tcf_ee_sessions;
CREATE POLICY "Learners can select published tcf_ee_sessions"
  ON public.tcf_ee_sessions FOR SELECT
  TO authenticated
  USING (
    statut = 'publiee'
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Admins can manage tcf_ee_sessions" ON public.tcf_ee_sessions;
CREATE POLICY "Admins can manage tcf_ee_sessions"
  ON public.tcf_ee_sessions FOR ALL
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
-- 2. tcf_ee_taches (3 tâches par séance)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tcf_ee_taches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES public.tcf_ee_sessions(id) ON DELETE CASCADE,
  numero integer NOT NULL CHECK (numero BETWEEN 1 AND 3),
  consigne text NOT NULL,
  mots_min integer NOT NULL CHECK (mots_min > 0),
  mots_max integer NOT NULL CHECK (mots_max > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (session_id, numero),
  CHECK (mots_max >= mots_min)
);

CREATE INDEX IF NOT EXISTS tcf_ee_taches_session_id_idx
  ON public.tcf_ee_taches (session_id);

ALTER TABLE public.tcf_ee_taches ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can select own tcf_ee_taches" ON public.tcf_ee_taches;
CREATE POLICY "Teachers can select own tcf_ee_taches"
  ON public.tcf_ee_taches FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_ee_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can insert own tcf_ee_taches" ON public.tcf_ee_taches;
CREATE POLICY "Teachers can insert own tcf_ee_taches"
  ON public.tcf_ee_taches FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.tcf_ee_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can update own tcf_ee_taches" ON public.tcf_ee_taches;
CREATE POLICY "Teachers can update own tcf_ee_taches"
  ON public.tcf_ee_taches FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_ee_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.tcf_ee_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can delete own tcf_ee_taches" ON public.tcf_ee_taches;
CREATE POLICY "Teachers can delete own tcf_ee_taches"
  ON public.tcf_ee_taches FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_ee_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Learners can select taches of published tcf_ee_sessions" ON public.tcf_ee_taches;
CREATE POLICY "Learners can select taches of published tcf_ee_sessions"
  ON public.tcf_ee_taches FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_ee_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.statut = 'publiee'
        AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Admins can manage tcf_ee_taches" ON public.tcf_ee_taches;
CREATE POLICY "Admins can manage tcf_ee_taches"
  ON public.tcf_ee_taches FOR ALL
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
-- 3. student_ee_attempts (1 tentative = les 3 tâches)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.student_ee_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES public.tcf_ee_sessions(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  statut text NOT NULL DEFAULT 'en_cours'
    CHECK (statut IN ('en_cours', 'a_corriger', 'corrige')),
  nb_sorties_onglet integer NOT NULL DEFAULT 0 CHECK (nb_sorties_onglet >= 0),
  started_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz
);

CREATE INDEX IF NOT EXISTS student_ee_attempts_session_id_idx
  ON public.student_ee_attempts (session_id);

CREATE INDEX IF NOT EXISTS student_ee_attempts_student_id_idx
  ON public.student_ee_attempts (student_id);

CREATE INDEX IF NOT EXISTS student_ee_attempts_statut_idx
  ON public.student_ee_attempts (statut);

ALTER TABLE public.student_ee_attempts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Learners can select own student_ee_attempts" ON public.student_ee_attempts;
CREATE POLICY "Learners can select own student_ee_attempts"
  ON public.student_ee_attempts FOR SELECT
  TO authenticated
  USING (
    student_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Learners can insert own student_ee_attempts" ON public.student_ee_attempts;
CREATE POLICY "Learners can insert own student_ee_attempts"
  ON public.student_ee_attempts FOR INSERT
  TO authenticated
  WITH CHECK (
    student_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
    AND EXISTS (
      SELECT 1 FROM public.tcf_ee_sessions s
      WHERE s.id = session_id AND s.statut = 'publiee'
    )
  );

DROP POLICY IF EXISTS "Learners can update own student_ee_attempts" ON public.student_ee_attempts;
CREATE POLICY "Learners can update own student_ee_attempts"
  ON public.student_ee_attempts FOR UPDATE
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

DROP POLICY IF EXISTS "Learners can delete own student_ee_attempts" ON public.student_ee_attempts;
CREATE POLICY "Learners can delete own student_ee_attempts"
  ON public.student_ee_attempts FOR DELETE
  TO authenticated
  USING (
    student_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Teachers can select ee attempts on own sessions" ON public.student_ee_attempts;
CREATE POLICY "Teachers can select ee attempts on own sessions"
  ON public.student_ee_attempts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_ee_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Admins can manage student_ee_attempts" ON public.student_ee_attempts;
CREATE POLICY "Admins can manage student_ee_attempts"
  ON public.student_ee_attempts FOR ALL
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
-- 4. student_ee_reponses (texte rédigé par tâche)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.student_ee_reponses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id uuid NOT NULL REFERENCES public.student_ee_attempts(id) ON DELETE CASCADE,
  tache_id uuid NOT NULL REFERENCES public.tcf_ee_taches(id) ON DELETE CASCADE,
  texte text NOT NULL DEFAULT '',
  nombre_mots integer NOT NULL DEFAULT 0 CHECK (nombre_mots >= 0),
  UNIQUE (attempt_id, tache_id)
);

CREATE INDEX IF NOT EXISTS student_ee_reponses_attempt_id_idx
  ON public.student_ee_reponses (attempt_id);

CREATE INDEX IF NOT EXISTS student_ee_reponses_tache_id_idx
  ON public.student_ee_reponses (tache_id);

ALTER TABLE public.student_ee_reponses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Learners can select own student_ee_reponses" ON public.student_ee_reponses;
CREATE POLICY "Learners can select own student_ee_reponses"
  ON public.student_ee_reponses FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.student_ee_attempts a
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE a.id = attempt_id
        AND a.student_id = auth.uid()
        AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Learners can insert own student_ee_reponses" ON public.student_ee_reponses;
CREATE POLICY "Learners can insert own student_ee_reponses"
  ON public.student_ee_reponses FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.student_ee_attempts a
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE a.id = attempt_id
        AND a.student_id = auth.uid()
        AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Learners can update own student_ee_reponses" ON public.student_ee_reponses;
CREATE POLICY "Learners can update own student_ee_reponses"
  ON public.student_ee_reponses FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.student_ee_attempts a
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE a.id = attempt_id
        AND a.student_id = auth.uid()
        AND p.role = 'learner'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.student_ee_attempts a
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE a.id = attempt_id
        AND a.student_id = auth.uid()
        AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Learners can delete own student_ee_reponses" ON public.student_ee_reponses;
CREATE POLICY "Learners can delete own student_ee_reponses"
  ON public.student_ee_reponses FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.student_ee_attempts a
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE a.id = attempt_id
        AND a.student_id = auth.uid()
        AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Teachers can select ee reponses on own sessions" ON public.student_ee_reponses;
CREATE POLICY "Teachers can select ee reponses on own sessions"
  ON public.student_ee_reponses FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.student_ee_attempts a
      JOIN public.tcf_ee_sessions s ON s.id = a.session_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE a.id = attempt_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Admins can manage student_ee_reponses" ON public.student_ee_reponses;
CREATE POLICY "Admins can manage student_ee_reponses"
  ON public.student_ee_reponses FOR ALL
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
-- 5. ee_corrections (grille formateur, 1 ligne par tâche)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ee_corrections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id uuid NOT NULL REFERENCES public.student_ee_attempts(id) ON DELETE CASCADE,
  tache_id uuid NOT NULL REFERENCES public.tcf_ee_taches(id) ON DELETE CASCADE,
  score_fond integer CHECK (score_fond IS NULL OR score_fond BETWEEN 0 AND 10),
  commentaire_fond text,
  score_forme integer CHECK (score_forme IS NULL OR score_forme BETWEEN 0 AND 10),
  commentaire_forme text,
  corrected_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  corrected_at timestamptz,
  UNIQUE (attempt_id, tache_id)
);

CREATE INDEX IF NOT EXISTS ee_corrections_attempt_id_idx
  ON public.ee_corrections (attempt_id);

CREATE INDEX IF NOT EXISTS ee_corrections_tache_id_idx
  ON public.ee_corrections (tache_id);

CREATE INDEX IF NOT EXISTS ee_corrections_corrected_by_idx
  ON public.ee_corrections (corrected_by);

ALTER TABLE public.ee_corrections ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Teachers can select ee_corrections on own sessions" ON public.ee_corrections;
CREATE POLICY "Teachers can select ee_corrections on own sessions"
  ON public.ee_corrections FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.student_ee_attempts a
      JOIN public.tcf_ee_sessions s ON s.id = a.session_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE a.id = attempt_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

DROP POLICY IF EXISTS "Teachers can insert ee_corrections on own sessions" ON public.ee_corrections;
CREATE POLICY "Teachers can insert ee_corrections on own sessions"
  ON public.ee_corrections FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.student_ee_attempts a
      JOIN public.tcf_ee_sessions s ON s.id = a.session_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE a.id = attempt_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
    AND (
      corrected_by IS NULL
      OR corrected_by = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Teachers can update ee_corrections on own sessions" ON public.ee_corrections;
CREATE POLICY "Teachers can update ee_corrections on own sessions"
  ON public.ee_corrections FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.student_ee_attempts a
      JOIN public.tcf_ee_sessions s ON s.id = a.session_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE a.id = attempt_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.student_ee_attempts a
      JOIN public.tcf_ee_sessions s ON s.id = a.session_id
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE a.id = attempt_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
    AND (
      corrected_by IS NULL
      OR corrected_by = auth.uid()
    )
  );

-- Apprenant : lecture de ses corrections une fois publiées (corrected_at rempli)
DROP POLICY IF EXISTS "Learners can select own published ee_corrections" ON public.ee_corrections;
CREATE POLICY "Learners can select own published ee_corrections"
  ON public.ee_corrections FOR SELECT
  TO authenticated
  USING (
    corrected_at IS NOT NULL
    AND EXISTS (
      SELECT 1
      FROM public.student_ee_attempts a
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE a.id = attempt_id
        AND a.student_id = auth.uid()
        AND p.role = 'learner'
    )
  );

DROP POLICY IF EXISTS "Admins can manage ee_corrections" ON public.ee_corrections;
CREATE POLICY "Admins can manage ee_corrections"
  ON public.ee_corrections FOR ALL
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
