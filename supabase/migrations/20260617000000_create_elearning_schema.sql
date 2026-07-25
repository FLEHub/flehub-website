/*
  # FLEHub eLearning schema

  Tables:
  - elearning_modules
  - elearning_sequences
  - elearning_lessons
  - elearning_exercises
  - elearning_enrollments
  - elearning_progress
  - elearning_submissions
  - elearning_capsules
  - elearning_badges

  Storage bucket: elearning-media (audio PE/PO submissions + capsule videos)
*/

-- Modules
CREATE TABLE IF NOT EXISTS elearning_modules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id uuid NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  cefr_level text CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  published boolean NOT NULL DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE elearning_modules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can read own elearning modules"
  ON elearning_modules FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Learners can read published elearning modules"
  ON elearning_modules FOR SELECT TO authenticated
  USING (
    published = true
    AND EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'learner')
  );

CREATE POLICY "Teachers can insert own elearning modules"
  ON elearning_modules FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can update own elearning modules"
  ON elearning_modules FOR UPDATE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can delete own elearning modules"
  ON elearning_modules FOR DELETE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  );

-- Sequences
CREATE TABLE IF NOT EXISTS elearning_sequences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid NOT NULL REFERENCES elearning_modules(id) ON DELETE CASCADE,
  title text NOT NULL DEFAULT '',
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE elearning_sequences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can manage sequences of own modules"
  ON elearning_sequences FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Learners can read sequences of published modules"
  ON elearning_sequences FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      WHERE m.id = module_id AND m.published = true
    )
    AND EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'learner')
  );

-- Lessons
CREATE TABLE IF NOT EXISTS elearning_lessons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sequence_id uuid NOT NULL REFERENCES elearning_sequences(id) ON DELETE CASCADE,
  title text NOT NULL DEFAULT '',
  competency text CHECK (competency IN ('PE', 'PO', 'CE', 'CO', 'EE', 'EO', 'EL')),
  content_type text NOT NULL DEFAULT 'text' CHECK (content_type IN ('youtube', 'image', 'text')),
  content text,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE elearning_lessons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can manage lessons of own modules"
  ON elearning_lessons FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_sequences s
      JOIN elearning_modules m ON m.id = s.module_id
      JOIN teachers t ON t.id = m.teacher_id
      WHERE s.id = sequence_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM elearning_sequences s
      JOIN elearning_modules m ON m.id = s.module_id
      JOIN teachers t ON t.id = m.teacher_id
      WHERE s.id = sequence_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Learners can read lessons of published modules"
  ON elearning_lessons FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_sequences s
      JOIN elearning_modules m ON m.id = s.module_id
      WHERE s.id = sequence_id AND m.published = true
    )
    AND EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'learner')
  );

-- Exercises (auto-correctable activities attached to a lesson)
CREATE TABLE IF NOT EXISTS elearning_exercises (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id uuid NOT NULL REFERENCES elearning_lessons(id) ON DELETE CASCADE,
  title text NOT NULL DEFAULT '',
  exercise_type text NOT NULL CHECK (exercise_type IN ('qcm', 'matching', 'fill_blank', 'short_answer')),
  content jsonb NOT NULL DEFAULT '{}'::jsonb,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE elearning_exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can manage exercises of own modules"
  ON elearning_exercises FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_lessons l
      JOIN elearning_sequences s ON s.id = l.sequence_id
      JOIN elearning_modules m ON m.id = s.module_id
      JOIN teachers t ON t.id = m.teacher_id
      WHERE l.id = lesson_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM elearning_lessons l
      JOIN elearning_sequences s ON s.id = l.sequence_id
      JOIN elearning_modules m ON m.id = s.module_id
      JOIN teachers t ON t.id = m.teacher_id
      WHERE l.id = lesson_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Learners can read exercises of published modules"
  ON elearning_exercises FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_lessons l
      JOIN elearning_sequences s ON s.id = l.sequence_id
      JOIN elearning_modules m ON m.id = s.module_id
      WHERE l.id = lesson_id AND m.published = true
    )
    AND EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'learner')
  );

-- Enrollments
CREATE TABLE IF NOT EXISTS elearning_enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid NOT NULL REFERENCES elearning_modules(id) ON DELETE CASCADE,
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  enrolled_at timestamptz DEFAULT now(),
  UNIQUE (module_id, learner_id)
);

ALTER TABLE elearning_enrollments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can read enrollments of own modules"
  ON elearning_enrollments FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Learners can read own enrollments"
  ON elearning_enrollments FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Learners can enroll in published modules"
  ON elearning_enrollments FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
    AND EXISTS (SELECT 1 FROM elearning_modules m WHERE m.id = module_id AND m.published = true)
  );

-- Progress
CREATE TABLE IF NOT EXISTS elearning_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  lesson_id uuid NOT NULL REFERENCES elearning_lessons(id) ON DELETE CASCADE,
  started_at timestamptz DEFAULT now(),
  completed_at timestamptz,
  UNIQUE (learner_id, lesson_id)
);

ALTER TABLE elearning_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can manage own elearning progress"
  ON elearning_progress FOR ALL TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can read progress on own modules"
  ON elearning_progress FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_lessons l
      JOIN elearning_sequences s ON s.id = l.sequence_id
      JOIN elearning_modules m ON m.id = s.module_id
      JOIN teachers t ON t.id = m.teacher_id
      WHERE l.id = lesson_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Submissions (PE text / PO audio path) — teacher-corrected
CREATE TABLE IF NOT EXISTS elearning_submissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id uuid NOT NULL REFERENCES elearning_lessons(id) ON DELETE CASCADE,
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  content text NOT NULL DEFAULT '',
  teacher_feedback text,
  validated boolean NOT NULL DEFAULT false,
  submitted_at timestamptz DEFAULT now(),
  validated_at timestamptz
);

ALTER TABLE elearning_submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can manage own submissions"
  ON elearning_submissions FOR ALL TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can read submissions of own modules"
  ON elearning_submissions FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_lessons l
      JOIN elearning_sequences s ON s.id = l.sequence_id
      JOIN elearning_modules m ON m.id = s.module_id
      JOIN teachers t ON t.id = m.teacher_id
      WHERE l.id = lesson_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Teachers can update submissions of own modules"
  ON elearning_submissions FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_lessons l
      JOIN elearning_sequences s ON s.id = l.sequence_id
      JOIN elearning_modules m ON m.id = s.module_id
      JOIN teachers t ON t.id = m.teacher_id
      WHERE l.id = lesson_id AND t.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM elearning_lessons l
      JOIN elearning_sequences s ON s.id = l.sequence_id
      JOIN elearning_modules m ON m.id = s.module_id
      JOIN teachers t ON t.id = m.teacher_id
      WHERE l.id = lesson_id AND t.profile_id = auth.uid()
    )
  );

-- Capsules (final video productions)
CREATE TABLE IF NOT EXISTS elearning_capsules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid NOT NULL REFERENCES elearning_modules(id) ON DELETE CASCADE,
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  content text NOT NULL DEFAULT '',
  validated boolean NOT NULL DEFAULT false,
  submitted_at timestamptz DEFAULT now(),
  validated_at timestamptz,
  UNIQUE (module_id, learner_id)
);

ALTER TABLE elearning_capsules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can manage own capsules"
  ON elearning_capsules FOR ALL TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can read capsules of own modules"
  ON elearning_capsules FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Teachers can update capsules of own modules"
  ON elearning_capsules FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can delete capsules of own modules"
  ON elearning_capsules FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
  );

-- Badges (awarded when a capsule is validated)
CREATE TABLE IF NOT EXISTS elearning_badges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  capsule_id uuid NOT NULL REFERENCES elearning_capsules(id) ON DELETE CASCADE,
  module_id uuid NOT NULL REFERENCES elearning_modules(id) ON DELETE CASCADE,
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  awarded_at timestamptz DEFAULT now(),
  UNIQUE (capsule_id)
);

ALTER TABLE elearning_badges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can insert badges for own modules"
  ON elearning_badges FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can read badges of own modules"
  ON elearning_badges FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Learners can read own badges"
  ON elearning_badges FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

-- Indexes
CREATE INDEX IF NOT EXISTS idx_elearning_modules_teacher ON elearning_modules(teacher_id);
CREATE INDEX IF NOT EXISTS idx_elearning_sequences_module ON elearning_sequences(module_id);
CREATE INDEX IF NOT EXISTS idx_elearning_lessons_sequence ON elearning_lessons(sequence_id);
CREATE INDEX IF NOT EXISTS idx_elearning_exercises_lesson ON elearning_exercises(lesson_id);
CREATE INDEX IF NOT EXISTS idx_elearning_enrollments_module ON elearning_enrollments(module_id);
CREATE INDEX IF NOT EXISTS idx_elearning_enrollments_learner ON elearning_enrollments(learner_id);
CREATE INDEX IF NOT EXISTS idx_elearning_progress_lesson ON elearning_progress(lesson_id);
CREATE INDEX IF NOT EXISTS idx_elearning_progress_learner ON elearning_progress(learner_id);
CREATE INDEX IF NOT EXISTS idx_elearning_submissions_lesson ON elearning_submissions(lesson_id);
CREATE INDEX IF NOT EXISTS idx_elearning_submissions_validated ON elearning_submissions(validated);
CREATE INDEX IF NOT EXISTS idx_elearning_capsules_module ON elearning_capsules(module_id);
CREATE INDEX IF NOT EXISTS idx_elearning_capsules_validated ON elearning_capsules(validated);

-- Storage bucket for PE/PO audio and capsule videos
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'elearning-media',
  'elearning-media',
  false,
  104857600,
  ARRAY[
    'audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/webm', 'audio/ogg', 'audio/x-m4a', 'audio/mp4',
    'video/mp4', 'video/webm', 'video/quicktime',
    'image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif'
  ]
)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Authenticated users can read elearning media" ON storage.objects;
CREATE POLICY "Authenticated users can read elearning media"
  ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'elearning-media');

DROP POLICY IF EXISTS "Authenticated users can upload elearning media" ON storage.objects;
CREATE POLICY "Authenticated users can upload elearning media"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'elearning-media');

DROP POLICY IF EXISTS "Authenticated users can update elearning media" ON storage.objects;
CREATE POLICY "Authenticated users can update elearning media"
  ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'elearning-media')
  WITH CHECK (bucket_id = 'elearning-media');

DROP POLICY IF EXISTS "Authenticated users can delete elearning media" ON storage.objects;
CREATE POLICY "Authenticated users can delete elearning media"
  ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'elearning-media');
