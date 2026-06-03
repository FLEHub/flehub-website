/*
  Tables and columns referenced by dashboard pages but missing from base schema.
*/

-- Align learner_progress with dashboard queries
ALTER TABLE learner_progress
  ADD COLUMN IF NOT EXISTS progress_percent numeric(5,2) DEFAULT 0;

ALTER TABLE learner_progress
  ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- school_enrollments
CREATE TABLE IF NOT EXISTS school_enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  enrolled_at timestamptz DEFAULT now(),
  UNIQUE(school_id, learner_id)
);

ALTER TABLE school_enrollments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Schools can read own enrollments"
  ON school_enrollments FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM schools s
      WHERE s.id = school_id AND s.profile_id = auth.uid()
    )
  );

CREATE POLICY "Schools can manage own enrollments"
  ON school_enrollments FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM schools s
      WHERE s.id = school_id AND s.profile_id = auth.uid()
    )
  );

CREATE POLICY "Admins can read all school enrollments"
  ON school_enrollments FOR SELECT TO authenticated
  USING (public.is_admin());

-- course_enrollments
CREATE TABLE IF NOT EXISTS course_enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  enrolled_at timestamptz DEFAULT now(),
  UNIQUE(course_id, learner_id)
);

ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can read enrollments for own courses"
  ON course_enrollments FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      JOIN teachers t ON t.id = c.teacher_id
      WHERE c.id = course_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Learners can read own course enrollments"
  ON course_enrollments FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM learners l
      WHERE l.id = learner_id AND l.profile_id = auth.uid()
    )
  );

CREATE POLICY "Admins can read all course enrollments"
  ON course_enrollments FOR SELECT TO authenticated
  USING (public.is_admin());

-- learner_exercise_attempts
CREATE TABLE IF NOT EXISTS learner_exercise_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  exercise_id uuid REFERENCES exercises(id) ON DELETE SET NULL,
  competency text CHECK (competency IN ('EO', 'EE', 'CO', 'CE', 'EL')),
  score numeric(5,2),
  completed_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE learner_exercise_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can read own exercise attempts"
  ON learner_exercise_attempts FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM learners l
      WHERE l.id = learner_id AND l.profile_id = auth.uid()
    )
  );

CREATE POLICY "Learners can insert own exercise attempts"
  ON learner_exercise_attempts FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM learners l
      WHERE l.id = learner_id AND l.profile_id = auth.uid()
    )
  );

CREATE POLICY "Teachers and admins can read exercise attempts"
  ON learner_exercise_attempts FOR SELECT TO authenticated
  USING (public.has_role(ARRAY['teacher', 'admin']));

CREATE INDEX IF NOT EXISTS idx_school_enrollments_school ON school_enrollments(school_id);
CREATE INDEX IF NOT EXISTS idx_school_enrollments_learner ON school_enrollments(learner_id);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_course ON course_enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_learner ON course_enrollments(learner_id);
CREATE INDEX IF NOT EXISTS idx_learner_exercise_attempts_learner ON learner_exercise_attempts(learner_id);

-- Schools can read exam registrations for enrolled learners
CREATE POLICY "Schools can read registrations for enrolled learners"
  ON exam_registrations FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM school_enrollments se
      JOIN schools s ON s.id = se.school_id
      WHERE se.learner_id = exam_registrations.learner_id
        AND s.profile_id = auth.uid()
    )
  );

-- Schools can read learners linked via school_enrollments
CREATE POLICY "Schools can read enrolled learners"
  ON learners FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM school_enrollments se
      JOIN schools s ON s.id = se.school_id
      WHERE se.learner_id = learners.id
        AND s.profile_id = auth.uid()
    )
  );
