/*
  # Replace BigBlueButton columns with meeting_url

  ## Changes
  - `live_sessions` table:
    - Add `meeting_url` (text, nullable) — teacher pastes a Google Meet, Zoom, or Teams link
    - Remove `bbb_meeting_id` and `bbb_join_url` (BBB integration removed)
    - Remove `recording_url` (no longer relevant without BBB)

  ## Notes
  - Existing rows get meeting_url = NULL (no data loss for sessions, just removing unused BBB columns)
  - Safe: uses IF EXISTS / IF NOT EXISTS guards throughout
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'live_sessions' AND column_name = 'meeting_url'
  ) THEN
    ALTER TABLE live_sessions ADD COLUMN meeting_url text;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'live_sessions' AND column_name = 'bbb_meeting_id'
  ) THEN
    ALTER TABLE live_sessions DROP COLUMN bbb_meeting_id;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'live_sessions' AND column_name = 'bbb_join_url'
  ) THEN
    ALTER TABLE live_sessions DROP COLUMN bbb_join_url;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'live_sessions' AND column_name = 'recording_url'
  ) THEN
    ALTER TABLE live_sessions DROP COLUMN recording_url;
  END IF;
END $$;
