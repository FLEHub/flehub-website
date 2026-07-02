
CREATE TABLE IF NOT EXISTS org_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_name text NOT NULL DEFAULT 'FLEHub',
  contact_email text,
  contact_phone text,
  logo_url text,
  signature_url text,
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE org_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "select_org_settings" ON org_settings FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "insert_org_settings" ON org_settings FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "update_org_settings" ON org_settings FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "delete_org_settings" ON org_settings FOR DELETE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Seed one default row
INSERT INTO org_settings (org_name) VALUES ('FLEHub') ON CONFLICT DO NOTHING;
