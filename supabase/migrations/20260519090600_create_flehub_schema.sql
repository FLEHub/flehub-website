/*
  # FLEHub - French Language Examination & Learning Management System

  ## Overview
  Full schema for FLEHub supporting 4 user roles:
  - admin: platform administrators
  - school: schools that enroll pupils
  - teacher: independent teachers
  - learner: students (independent adults or school pupils)

  ## Tables Created
  1. `profiles` - extended user info linked to auth.users
  2. `schools` - school organizations
  3. `teachers` - teacher profiles
  4. `learners` - learner profiles with subtype (independent/pupil)
  5. `school_enrollments` - links pupils to schools
  6. `teacher_assignments` - links learners to teachers
  7. `courses` - course capsules (video/audio/PDF)
  8. `exercises` - interactive exercises per course
  9. `exercise_questions` - questions within exercises
  10. `exam_sessions` - official CEFR exam sessions
  11. `exam_results` - per-competency results
  12. `certificates` - generated certificates
  13. `live_sessions` - BigBlueButton scheduled sessions
  14. `payments` - Mobile Money payment records
  15. `messages` - internal messaging
  16. `notifications` - in-app notifications
  17. `calendar_events` - exam calendar
  18. `learner_progress` - tracks content completion

  ## Security
  - RLS enabled on all tables
  - Role-based access policies
*/

-- Profiles (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  full_name text NOT NULL DEFAULT '',
  role text NOT NULL CHECK (role IN ('admin', 'school', 'teacher', 'learner')),
  avatar_url text,
  phone text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'suspended')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can read all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Admins can update all profiles"
  ON profiles FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Allow insert own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Schools
CREATE TABLE IF NOT EXISTS schools (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  school_name text NOT NULL,
  address text,
  district text,
  province text,
  logo_url text,
  registration_number text,
  contact_person text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE schools ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Schools can read own data"
  ON schools FOR SELECT
  TO authenticated
  USING (profile_id = auth.uid());

CREATE POLICY "Schools can update own data"
  ON schools FOR UPDATE
  TO authenticated
  USING (profile_id = auth.uid())
  WITH CHECK (profile_id = auth.uid());

CREATE POLICY "Schools can insert own data"
  ON schools FOR INSERT
  TO authenticated
  WITH CHECK (profile_id = auth.uid());

CREATE POLICY "Admins can read all schools"
  ON schools FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Teachers
CREATE TABLE IF NOT EXISTS teachers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  bio text,
  qualifications text,
  specializations text[] DEFAULT '{}',
  bank_account text,
  mobile_money_number text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can read own data"
  ON teachers FOR SELECT
  TO authenticated
  USING (profile_id = auth.uid());

CREATE POLICY "Teachers can update own data"
  ON teachers FOR UPDATE
  TO authenticated
  USING (profile_id = auth.uid())
  WITH CHECK (profile_id = auth.uid());

CREATE POLICY "Teachers can insert own data"
  ON teachers FOR INSERT
  TO authenticated
  WITH CHECK (profile_id = auth.uid());

CREATE POLICY "Admins can read all teachers"
  ON teachers FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Learners
CREATE TABLE IF NOT EXISTS learners (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  subtype text NOT NULL DEFAULT 'independent' CHECK (subtype IN ('independent', 'pupil')),
  date_of_birth date,
  nationality text DEFAULT 'Rwandan',
  cefr_level text CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  school_id uuid REFERENCES schools(id),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE learners ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can read own data"
  ON learners FOR SELECT
  TO authenticated
  USING (profile_id = auth.uid());

CREATE POLICY "Learners can update own data"
  ON learners FOR UPDATE
  TO authenticated
  USING (profile_id = auth.uid())
  WITH CHECK (profile_id = auth.uid());

CREATE POLICY "Learners can insert own data"
  ON learners FOR INSERT
  TO authenticated
  WITH CHECK (profile_id = auth.uid());

CREATE POLICY "Admins and teachers can read learners"
  ON learners FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher', 'school'))
  );

-- Teacher Assignments (learner <-> teacher)
CREATE TABLE IF NOT EXISTS teacher_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  teacher_id uuid NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
  assigned_by uuid REFERENCES profiles(id),
  assigned_at timestamptz DEFAULT now(),
  active boolean DEFAULT true,
  UNIQUE(learner_id, teacher_id)
);

ALTER TABLE teacher_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can read own assignments"
  ON teacher_assignments FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  );

CREATE POLICY "Learners can read own assignments"
  ON teacher_assignments FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Admins can manage assignments"
  ON teacher_assignments FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Admins can insert assignments"
  ON teacher_assignments FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Courses
CREATE TABLE IF NOT EXISTS courses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id uuid NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  cefr_level text NOT NULL CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  competency text CHECK (competency IN ('EO', 'EE', 'CO', 'CE', 'EL')),
  content_type text NOT NULL CHECK (content_type IN ('video', 'audio', 'pdf', 'text')),
  content_url text,
  thumbnail_url text,
  duration_minutes integer DEFAULT 0,
  is_published boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE courses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can manage own courses"
  ON courses FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can insert courses"
  ON courses FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can update own courses"
  ON courses FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  );

CREATE POLICY "Learners can read published courses"
  ON courses FOR SELECT
  TO authenticated
  USING (
    is_published = true AND
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'learner')
  );

-- Exercises
CREATE TABLE IF NOT EXISTS exercises (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  teacher_id uuid NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  exercise_type text NOT NULL CHECK (exercise_type IN ('qcm', 'matching', 'fill_blank', 'short_answer')),
  cefr_level text NOT NULL CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  time_limit_minutes integer,
  is_published boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can manage own exercises"
  ON exercises FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can insert exercises"
  ON exercises FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can update exercises"
  ON exercises FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  );

CREATE POLICY "Learners can read published exercises"
  ON exercises FOR SELECT
  TO authenticated
  USING (
    is_published = true AND
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'learner')
  );

-- Exercise Questions
CREATE TABLE IF NOT EXISTS exercise_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id uuid NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  question_text text NOT NULL,
  question_type text NOT NULL CHECK (question_type IN ('qcm', 'matching', 'fill_blank', 'short_answer')),
  options jsonb DEFAULT '[]',
  correct_answer jsonb,
  points integer DEFAULT 1,
  order_index integer DEFAULT 0
);

ALTER TABLE exercise_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can manage questions via exercise ownership"
  ON exercise_questions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM exercises e
      JOIN teachers t ON t.id = e.teacher_id
      WHERE e.id = exercise_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can insert questions"
  ON exercise_questions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM exercises e
      JOIN teachers t ON t.id = e.teacher_id
      WHERE e.id = exercise_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Learners can read questions for published exercises"
  ON exercise_questions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM exercises e
      WHERE e.id = exercise_id AND e.is_published = true
    ) AND
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'learner')
  );

-- Exam Sessions
CREATE TABLE IF NOT EXISTS exam_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  cefr_level text NOT NULL CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  exam_date date NOT NULL,
  registration_deadline date NOT NULL,
  price_rwf integer NOT NULL DEFAULT 0,
  max_candidates integer DEFAULT 100,
  venue text,
  status text DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed', 'cancelled')),
  retake_waiting_days integer DEFAULT 90,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE exam_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone authenticated can read exam sessions"
  ON exam_sessions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage exam sessions"
  ON exam_sessions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Admins can update exam sessions"
  ON exam_sessions FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Exam Registrations
CREATE TABLE IF NOT EXISTS exam_registrations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_session_id uuid NOT NULL REFERENCES exam_sessions(id) ON DELETE CASCADE,
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  payment_status text DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded')),
  registration_date timestamptz DEFAULT now(),
  UNIQUE(exam_session_id, learner_id)
);

ALTER TABLE exam_registrations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can read own registrations"
  ON exam_registrations FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Learners can insert own registrations"
  ON exam_registrations FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Admins can read all registrations"
  ON exam_registrations FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Exam Results
CREATE TABLE IF NOT EXISTS exam_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_session_id uuid NOT NULL REFERENCES exam_sessions(id) ON DELETE CASCADE,
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  entered_by uuid REFERENCES profiles(id),
  score_eo numeric(5,2),
  score_ee numeric(5,2),
  score_co numeric(5,2),
  score_ce numeric(5,2),
  score_el numeric(5,2),
  total_score numeric(5,2),
  passed boolean DEFAULT false,
  remarks text,
  created_at timestamptz DEFAULT now(),
  UNIQUE(exam_session_id, learner_id)
);

ALTER TABLE exam_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can read own results"
  ON exam_results FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Schools can insert results for their pupils"
  ON exam_results FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('school', 'admin'))
  );

CREATE POLICY "Admins can manage all results"
  ON exam_results FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'school', 'teacher'))
  );

-- Certificates
CREATE TABLE IF NOT EXISTS certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  exam_result_id uuid REFERENCES exam_results(id),
  certificate_number text UNIQUE NOT NULL,
  cefr_level text NOT NULL,
  issue_date date DEFAULT CURRENT_DATE,
  issued_by uuid REFERENCES profiles(id),
  school_id uuid REFERENCES schools(id),
  verification_code text UNIQUE NOT NULL,
  pdf_url text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can read own certificates"
  ON certificates FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Admins and schools can manage certificates"
  ON certificates FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'school'))
  );

CREATE POLICY "Admins can insert certificates"
  ON certificates FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'school'))
  );

-- Live Sessions (BigBlueButton)
CREATE TABLE IF NOT EXISTS live_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id uuid NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  scheduled_at timestamptz NOT NULL,
  duration_minutes integer DEFAULT 60,
  bbb_meeting_id text,
  bbb_join_url text,
  cefr_level text CHECK (cefr_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  max_participants integer DEFAULT 30,
  status text DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'live', 'completed', 'cancelled')),
  recording_url text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE live_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can manage own sessions"
  ON live_sessions FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can insert sessions"
  ON live_sessions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can update own sessions"
  ON live_sessions FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM teachers t WHERE t.id = teacher_id AND t.profile_id = auth.uid())
  );

CREATE POLICY "Learners can read sessions"
  ON live_sessions FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'learner')
  );

-- Payments
CREATE TABLE IF NOT EXISTS payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  payment_type text NOT NULL CHECK (payment_type IN ('exam_registration', 'course_access', 'certificate')),
  reference_id uuid,
  amount_rwf integer NOT NULL,
  currency text DEFAULT 'RWF',
  payment_method text CHECK (payment_method IN ('mtn_momo', 'airtel_money', 'bank_transfer', 'cash')),
  transaction_id text,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  phone_number text,
  created_at timestamptz DEFAULT now(),
  completed_at timestamptz
);

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can read own payments"
  ON payments FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Learners can insert payments"
  ON payments FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Admins can read all payments"
  ON payments FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Messages
CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  recipient_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  subject text,
  body text NOT NULL,
  is_read boolean DEFAULT false,
  parent_id uuid REFERENCES messages(id),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own messages"
  ON messages FOR SELECT
  TO authenticated
  USING (sender_id = auth.uid() OR recipient_id = auth.uid());

CREATE POLICY "Users can send messages"
  ON messages FOR INSERT
  TO authenticated
  WITH CHECK (sender_id = auth.uid());

CREATE POLICY "Recipients can update read status"
  ON messages FOR UPDATE
  TO authenticated
  USING (recipient_id = auth.uid())
  WITH CHECK (recipient_id = auth.uid());

-- Notifications
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title text NOT NULL,
  body text NOT NULL,
  type text DEFAULT 'info' CHECK (type IN ('info', 'success', 'warning', 'error')),
  is_read boolean DEFAULT false,
  action_url text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own notifications"
  ON notifications FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "System can insert notifications"
  ON notifications FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher', 'school'))
    OR user_id = auth.uid()
  );

-- Calendar Events
CREATE TABLE IF NOT EXISTS calendar_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  event_type text DEFAULT 'exam' CHECK (event_type IN ('exam', 'session', 'deadline', 'holiday')),
  start_date timestamptz NOT NULL,
  end_date timestamptz,
  created_by uuid REFERENCES profiles(id),
  is_public boolean DEFAULT true,
  cefr_level text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE calendar_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read public events"
  ON calendar_events FOR SELECT
  TO authenticated
  USING (is_public = true);

CREATE POLICY "Admins can manage events"
  ON calendar_events FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Learner Progress
CREATE TABLE IF NOT EXISTS learner_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  exercise_id uuid REFERENCES exercises(id) ON DELETE CASCADE,
  status text DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed')),
  score numeric(5,2),
  attempts integer DEFAULT 0,
  last_accessed timestamptz DEFAULT now(),
  completed_at timestamptz,
  UNIQUE(learner_id, course_id)
);

ALTER TABLE learner_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can read own progress"
  ON learner_progress FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Learners can upsert own progress"
  ON learner_progress FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
  );

CREATE POLICY "Teachers can read learner progress"
  ON learner_progress FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('teacher', 'admin'))
  );

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_status ON profiles(status);
CREATE INDEX IF NOT EXISTS idx_learners_profile ON learners(profile_id);
CREATE INDEX IF NOT EXISTS idx_learners_school ON learners(school_id);
CREATE INDEX IF NOT EXISTS idx_courses_teacher ON courses(teacher_id);
CREATE INDEX IF NOT EXISTS idx_courses_level ON courses(cefr_level);
CREATE INDEX IF NOT EXISTS idx_messages_recipient ON messages(recipient_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_payments_learner ON payments(learner_id);
CREATE INDEX IF NOT EXISTS idx_exam_results_learner ON exam_results(learner_id);
