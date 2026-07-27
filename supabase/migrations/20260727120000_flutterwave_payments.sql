/*
  Flutterwave payments:
  - elearning_modules.price_rwf
  - module_payments
  - school_subscriptions
*/

-- ---------------------------------------------------------------------------
-- Module pricing
-- ---------------------------------------------------------------------------
ALTER TABLE elearning_modules
  ADD COLUMN IF NOT EXISTS price_rwf integer NOT NULL DEFAULT 0
  CHECK (price_rwf >= 0);

COMMENT ON COLUMN elearning_modules.price_rwf IS 'Module price in RWF. 0 = free enrollment.';

-- ---------------------------------------------------------------------------
-- Module payments (learner pays for a module)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS module_payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid NOT NULL REFERENCES elearning_modules(id) ON DELETE CASCADE,
  learner_id uuid NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
  amount_rwf integer NOT NULL CHECK (amount_rwf > 0),
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'successful', 'failed', 'cancelled')),
  flutterwave_tx_ref text NOT NULL UNIQUE,
  flutterwave_transaction_id text,
  paid_at timestamptz,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS module_payments_learner_id_idx ON module_payments (learner_id);
CREATE INDEX IF NOT EXISTS module_payments_module_id_idx ON module_payments (module_id);
CREATE INDEX IF NOT EXISTS module_payments_tx_ref_idx ON module_payments (flutterwave_tx_ref);

ALTER TABLE module_payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can read own module payments"
  ON module_payments FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
    OR EXISTS (
      SELECT 1 FROM elearning_modules m
      JOIN teachers t ON t.id = m.teacher_id
      WHERE m.id = module_id AND t.profile_id = auth.uid()
    )
  );

CREATE POLICY "Learners can insert own pending module payments"
  ON module_payments FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM learners l WHERE l.id = learner_id AND l.profile_id = auth.uid())
    AND status = 'pending'
  );

-- Updates (status / paid_at) are performed by the webhook via service role.

-- ---------------------------------------------------------------------------
-- School annual subscriptions
-- Link: schools.profile_id = profiles.id (= auth.uid() for the school account)
-- There is no school_staff table; the school user owns the school row.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS school_subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  amount_rwf integer NOT NULL CHECK (amount_rwf > 0),
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'active', 'expired', 'failed')),
  period_start timestamptz,
  period_end timestamptz,
  flutterwave_tx_ref text NOT NULL UNIQUE,
  flutterwave_transaction_id text,
  paid_at timestamptz,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS school_subscriptions_school_id_idx ON school_subscriptions (school_id);
CREATE INDEX IF NOT EXISTS school_subscriptions_tx_ref_idx ON school_subscriptions (flutterwave_tx_ref);
CREATE INDEX IF NOT EXISTS school_subscriptions_status_idx ON school_subscriptions (status);

ALTER TABLE school_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "School staff can read own subscriptions"
  ON school_subscriptions FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM schools s
      WHERE s.id = school_id AND s.profile_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "School staff can insert own pending subscriptions"
  ON school_subscriptions FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM schools s
      WHERE s.id = school_id AND s.profile_id = auth.uid()
    )
    AND status = 'pending'
  );

CREATE POLICY "Admins can update school subscriptions"
  ON school_subscriptions FOR UPDATE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Updates to activate subscriptions are performed by the webhook via service role.
