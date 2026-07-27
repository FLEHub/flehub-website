/*
  Add exercise type audio_record + exercise_audio_submissions table
*/

ALTER TABLE elearning_exercises
  DROP CONSTRAINT IF EXISTS elearning_exercises_exercise_type_check;

ALTER TABLE elearning_exercises
  ADD CONSTRAINT elearning_exercises_exercise_type_check
  CHECK (
    exercise_type IN (
      'qcm',
      'matching',
      'fill_blank',
      'short_answer',
      'word_order',
      'anagram',
      'true_false',
      'image_match',
      'find_error',
      'audio_record'
    )
  );

CREATE TABLE IF NOT EXISTS exercise_audio_submissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id uuid NOT NULL REFERENCES elearning_exercises(id) ON DELETE CASCADE,
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  audio_path text NOT NULL,
  teacher_feedback text,
  validated boolean NOT NULL DEFAULT false,
  submitted_at timestamptz DEFAULT now(),
  validated_at timestamptz,
  UNIQUE (exercise_id, learner_id)
);

CREATE INDEX IF NOT EXISTS exercise_audio_submissions_exercise_id_idx
  ON exercise_audio_submissions (exercise_id);
CREATE INDEX IF NOT EXISTS exercise_audio_submissions_learner_id_idx
  ON exercise_audio_submissions (learner_id);
CREATE INDEX IF NOT EXISTS exercise_audio_submissions_validated_idx
  ON exercise_audio_submissions (validated);

ALTER TABLE exercise_audio_submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can read own exercise audio submissions"
  ON exercise_audio_submissions FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
    OR EXISTS (
      SELECT 1 FROM elearning_exercises e
      JOIN elearning_lessons les ON les.id = e.lesson_id
      JOIN elearning_sequences s ON s.id = les.sequence_id
      JOIN elearning_modules m ON m.id = s.module_id
      JOIN teachers t ON t.id = m.teacher_id
      WHERE e.id = exercise_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Learners can insert own exercise audio submissions"
  ON exercise_audio_submissions FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Learners can update own pending exercise audio submissions"
  ON exercise_audio_submissions FOR UPDATE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can update exercise audio submissions of own modules"
  ON exercise_audio_submissions FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_exercises e
      JOIN elearning_lessons les ON les.id = e.lesson_id
      JOIN elearning_sequences s ON s.id = les.sequence_id
      JOIN elearning_modules m ON m.id = s.module_id
      JOIN teachers t ON t.id = m.teacher_id
      WHERE e.id = exercise_id AND t.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM elearning_exercises e
      JOIN elearning_lessons les ON les.id = e.lesson_id
      JOIN elearning_sequences s ON s.id = les.sequence_id
      JOIN elearning_modules m ON m.id = s.module_id
      JOIN teachers t ON t.id = m.teacher_id
      WHERE e.id = exercise_id AND t.profile_id = auth.uid()
    )
  );
