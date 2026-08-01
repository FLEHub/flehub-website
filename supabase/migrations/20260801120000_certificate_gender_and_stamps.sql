-- Admin: signatory gender + official stamp for certificates
ALTER TABLE org_settings
  ADD COLUMN IF NOT EXISTS admin_gender text
    CHECK (admin_gender IS NULL OR admin_gender IN ('M', 'F'));

ALTER TABLE org_settings
  ADD COLUMN IF NOT EXISTS stamp_url text;

-- School branding: stamp stored as path in school-assets (same pattern as signature/logo)
ALTER TABLE school_settings
  ADD COLUMN IF NOT EXISTS stamp_path text;
