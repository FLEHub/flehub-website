-- News portal: audio reportages (same RLS pattern as articles/videos)
CREATE TABLE IF NOT EXISTS reportages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  journalist_id uuid NOT NULL REFERENCES journalists(id) ON DELETE CASCADE,
  category_id uuid REFERENCES article_categories(id) ON DELETE SET NULL,
  title text NOT NULL,
  slug text NOT NULL UNIQUE,
  description text,
  audio_url text NOT NULL,
  cover_image_url text,
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'published')),
  published_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_reportages_status_published_at
  ON reportages (status, published_at DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS idx_reportages_journalist ON reportages (journalist_id);
CREATE INDEX IF NOT EXISTS idx_reportages_category ON reportages (category_id);
CREATE INDEX IF NOT EXISTS idx_reportages_slug ON reportages (slug);

ALTER TABLE reportages ENABLE ROW LEVEL SECURITY;

-- Reportages: public read published; journalists manage own; admins all
DROP POLICY IF EXISTS "Anyone can read published reportages" ON reportages;
CREATE POLICY "Anyone can read published reportages"
  ON reportages FOR SELECT
  TO anon, authenticated
  USING (status = 'published');

DROP POLICY IF EXISTS "Journalists can read own reportages" ON reportages;
CREATE POLICY "Journalists can read own reportages"
  ON reportages FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = reportages.journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can insert own reportages" ON reportages;
CREATE POLICY "Journalists can insert own reportages"
  ON reportages FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can update own reportages" ON reportages;
CREATE POLICY "Journalists can update own reportages"
  ON reportages FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = reportages.journalist_id AND j.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = reportages.journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can delete own reportages" ON reportages;
CREATE POLICY "Journalists can delete own reportages"
  ON reportages FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = reportages.journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins manage all reportages" ON reportages;
CREATE POLICY "Admins manage all reportages"
  ON reportages FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- Public bucket for reportage audio files
-- Paths: {journalistId}/{filename}
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'reportage-audio',
  'reportage-audio',
  true,
  52428800,
  ARRAY[
    'audio/mpeg',
    'audio/mp3',
    'audio/wav',
    'audio/x-wav',
    'audio/wave',
    'audio/mp4',
    'audio/m4a',
    'audio/x-m4a'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "reportage_audio_public_select" ON storage.objects;
CREATE POLICY "reportage_audio_public_select" ON storage.objects
  FOR SELECT TO anon, authenticated
  USING (bucket_id = 'reportage-audio');

DROP POLICY IF EXISTS "reportage_audio_insert" ON storage.objects;
CREATE POLICY "reportage_audio_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'reportage-audio'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR EXISTS (
        SELECT 1 FROM journalists j
        WHERE j.profile_id = auth.uid()
          AND j.id::text = (storage.foldername(name))[1]
      )
    )
  );

DROP POLICY IF EXISTS "reportage_audio_update" ON storage.objects;
CREATE POLICY "reportage_audio_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'reportage-audio'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR EXISTS (
        SELECT 1 FROM journalists j
        WHERE j.profile_id = auth.uid()
          AND j.id::text = (storage.foldername(name))[1]
      )
    )
  )
  WITH CHECK (
    bucket_id = 'reportage-audio'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR EXISTS (
        SELECT 1 FROM journalists j
        WHERE j.profile_id = auth.uid()
          AND j.id::text = (storage.foldername(name))[1]
      )
    )
  );

DROP POLICY IF EXISTS "reportage_audio_delete" ON storage.objects;
CREATE POLICY "reportage_audio_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'reportage-audio'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR EXISTS (
        SELECT 1 FROM journalists j
        WHERE j.profile_id = auth.uid()
          AND j.id::text = (storage.foldername(name))[1]
      )
    )
  );
