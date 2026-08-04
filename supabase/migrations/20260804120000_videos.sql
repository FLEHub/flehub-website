-- News portal: YouTube videos (same RLS pattern as articles)
CREATE TABLE IF NOT EXISTS videos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  journalist_id uuid NOT NULL REFERENCES journalists(id) ON DELETE CASCADE,
  category_id uuid REFERENCES article_categories(id) ON DELETE SET NULL,
  title text NOT NULL,
  slug text NOT NULL UNIQUE,
  description text,
  youtube_url text NOT NULL,
  youtube_video_id text NOT NULL,
  thumbnail_url text NOT NULL,
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'published')),
  published_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_videos_status_published_at
  ON videos (status, published_at DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS idx_videos_journalist ON videos (journalist_id);
CREATE INDEX IF NOT EXISTS idx_videos_category ON videos (category_id);
CREATE INDEX IF NOT EXISTS idx_videos_slug ON videos (slug);

ALTER TABLE videos ENABLE ROW LEVEL SECURITY;

-- Videos: public read published; journalists manage own; admins all
DROP POLICY IF EXISTS "Anyone can read published videos" ON videos;
CREATE POLICY "Anyone can read published videos"
  ON videos FOR SELECT
  TO anon, authenticated
  USING (status = 'published');

DROP POLICY IF EXISTS "Journalists can read own videos" ON videos;
CREATE POLICY "Journalists can read own videos"
  ON videos FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = videos.journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can insert own videos" ON videos;
CREATE POLICY "Journalists can insert own videos"
  ON videos FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can update own videos" ON videos;
CREATE POLICY "Journalists can update own videos"
  ON videos FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = videos.journalist_id AND j.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = videos.journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can delete own videos" ON videos;
CREATE POLICY "Journalists can delete own videos"
  ON videos FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = videos.journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins manage all videos" ON videos;
CREATE POLICY "Admins manage all videos"
  ON videos FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));
