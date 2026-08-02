-- Branding fields for MFK rebrand (short name + full tagline)
ALTER TABLE org_settings
  ADD COLUMN IF NOT EXISTS org_short_name text NOT NULL DEFAULT 'MFK';

ALTER TABLE org_settings
  ADD COLUMN IF NOT EXISTS org_tagline text NOT NULL DEFAULT 'Maison de la Francophonie Kigali';

-- Backfill existing rows and align org_name default brand
UPDATE org_settings
SET
  org_short_name = COALESCE(NULLIF(TRIM(org_short_name), ''), 'MFK'),
  org_tagline = COALESCE(NULLIF(TRIM(org_tagline), ''), 'Maison de la Francophonie Kigali'),
  org_name = CASE
    WHEN org_name IS NULL OR TRIM(org_name) = '' OR LOWER(TRIM(org_name)) = 'flehub' THEN 'MFK'
    ELSE org_name
  END;

-- Allow public read of org branding (homepage / login)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'org_settings'
      AND policyname = 'anon_select_org_settings'
  ) THEN
    CREATE POLICY "anon_select_org_settings" ON org_settings
      FOR SELECT TO anon USING (true);
  END IF;
END $$;
