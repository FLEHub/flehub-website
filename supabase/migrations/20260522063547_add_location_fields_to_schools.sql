/*
  # Add full Rwanda administrative location fields to schools

  ## Changes
  - `schools` table:
    - Add `sector` (text, nullable) — Umurenge/Sector
    - Add `cell` (text, nullable) — Akagari/Cell
    - Add `village` (text, nullable) — Umudugudu/Village (free text)

  ## Notes
  - Existing rows retain NULL for new columns — no data loss
  - All new columns are optional to preserve backwards compatibility
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'schools' AND column_name = 'sector'
  ) THEN
    ALTER TABLE schools ADD COLUMN sector text;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'schools' AND column_name = 'cell'
  ) THEN
    ALTER TABLE schools ADD COLUMN cell text;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'schools' AND column_name = 'village'
  ) THEN
    ALTER TABLE schools ADD COLUMN village text;
  END IF;
END $$;
