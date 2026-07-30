/*
  Paper exam scores per learner per CEFR level (teacher-entered).
  One row per (learner_id, level); total_score is generated.
*/

CREATE TABLE IF NOT EXISTS elearning_level_exam_scores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  teacher_id uuid NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
  level text NOT NULL CHECK (level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  score_po numeric(5,2) CHECK (score_po IS NULL OR (score_po >= 0 AND score_po <= 20)),
  score_pe numeric(5,2) CHECK (score_pe IS NULL OR (score_pe >= 0 AND score_pe <= 20)),
  score_co numeric(5,2) CHECK (score_co IS NULL OR (score_co >= 0 AND score_co <= 20)),
  score_ce numeric(5,2) CHECK (score_ce IS NULL OR (score_ce >= 0 AND score_ce <= 20)),
  score_langue numeric(5,2) CHECK (score_langue IS NULL OR (score_langue >= 0 AND score_langue <= 20)),
  total_score numeric(5,2) GENERATED ALWAYS AS (
    COALESCE(score_po, 0) + COALESCE(score_pe, 0) +
    COALESCE(score_co, 0) + COALESCE(score_ce, 0) +
    COALESCE(score_langue, 0)
  ) STORED,
  recorded_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE (learner_id, level)
);

CREATE INDEX IF NOT EXISTS idx_elearning_level_exam_scores_learner
  ON elearning_level_exam_scores (learner_id);
CREATE INDEX IF NOT EXISTS idx_elearning_level_exam_scores_teacher
  ON elearning_level_exam_scores (teacher_id);

COMMENT ON TABLE elearning_level_exam_scores IS
  'Paper exam competency scores (PO/PE/CO/CE/Langue) entered by teachers per learner CEFR level';

ALTER TABLE elearning_level_exam_scores ENABLE ROW LEVEL SECURITY;

-- Teachers can read scores for their linked learners, their own rows, or admins all
CREATE POLICY "Teachers can read level exam scores"
  ON elearning_level_exam_scores FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM teachers t
      JOIN learner_teacher_links ltl ON ltl.teacher_id = t.id
      WHERE t.profile_id = auth.uid()
        AND ltl.learner_id = elearning_level_exam_scores.learner_id
    )
    OR EXISTS (
      SELECT 1 FROM teachers t
      JOIN elearning_module_assignments a ON a.teacher_id = t.id
      WHERE t.profile_id = auth.uid()
        AND a.learner_id = elearning_level_exam_scores.learner_id
    )
    OR EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- Learners can read their own scores
CREATE POLICY "Learners can read own level exam scores"
  ON elearning_level_exam_scores FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM learners l
      WHERE l.id = learner_id AND l.profile_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can insert level exam scores"
  ON elearning_level_exam_scores FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
    AND (
      EXISTS (
        SELECT 1 FROM learner_teacher_links ltl
        WHERE ltl.teacher_id = teacher_id
          AND ltl.learner_id = elearning_level_exam_scores.learner_id
      )
      OR EXISTS (
        SELECT 1 FROM elearning_module_assignments a
        WHERE a.teacher_id = teacher_id
          AND a.learner_id = elearning_level_exam_scores.learner_id
      )
    )
  );

-- Allow update by owning teacher or any linked teacher (upsert may change teacher_id)
CREATE POLICY "Teachers can update level exam scores"
  ON elearning_level_exam_scores FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM teachers t
      JOIN learner_teacher_links ltl ON ltl.teacher_id = t.id
      WHERE t.profile_id = auth.uid()
        AND ltl.learner_id = elearning_level_exam_scores.learner_id
    )
    OR EXISTS (
      SELECT 1 FROM teachers t
      JOIN elearning_module_assignments a ON a.teacher_id = t.id
      WHERE t.profile_id = auth.uid()
        AND a.learner_id = elearning_level_exam_scores.learner_id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can delete own level exam scores"
  ON elearning_level_exam_scores FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM teachers t
      WHERE t.id = teacher_id AND t.profile_id = auth.uid()
    )
  );
