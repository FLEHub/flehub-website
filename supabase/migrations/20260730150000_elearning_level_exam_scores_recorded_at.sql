/*
  Align elearning_level_exam_scores timestamps with production schema:
  recorded_at (first entry) + updated_at (last modification).
  Some installs still have created_at from the original migration.
*/

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'elearning_level_exam_scores'
      AND column_name = 'created_at'
  ) AND NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'elearning_level_exam_scores'
      AND column_name = 'recorded_at'
  ) THEN
    ALTER TABLE elearning_level_exam_scores
      RENAME COLUMN created_at TO recorded_at;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'elearning_level_exam_scores'
      AND column_name = 'recorded_at'
  ) THEN
    ALTER TABLE elearning_level_exam_scores
      ADD COLUMN recorded_at timestamptz DEFAULT now();
  END IF;
END $$;
