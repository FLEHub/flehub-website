-- Add physical signatory name for admin certificate signature zone
ALTER TABLE org_settings
  ADD COLUMN IF NOT EXISTS admin_signatory_name text;
