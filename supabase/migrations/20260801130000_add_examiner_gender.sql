-- School examiner / director gender for certificate titles
ALTER TABLE school_settings
  ADD COLUMN IF NOT EXISTS examiner_gender text
    CHECK (examiner_gender IS NULL OR examiner_gender IN ('M', 'F'));
