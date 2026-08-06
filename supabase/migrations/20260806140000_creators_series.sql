-- Creators space: web-séries + podcasts
-- Widens profiles.role and creates creators / series / series_episodes + storage

ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles
  ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('admin', 'school', 'teacher', 'learner', 'journalist', 'creator'));

-- Creators extension table (mirrors journalists)
CREATE TABLE IF NOT EXISTS creators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  bio text,
  avatar_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_creators_profile ON creators(profile_id);

ALTER TABLE creators ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Creators can read own data" ON creators;
CREATE POLICY "Creators can read own data"
  ON creators FOR SELECT
  TO authenticated
  USING (profile_id = auth.uid());

DROP POLICY IF EXISTS "Creators can update own data" ON creators;
CREATE POLICY "Creators can update own data"
  ON creators FOR UPDATE
  TO authenticated
  USING (profile_id = auth.uid())
  WITH CHECK (profile_id = auth.uid());

DROP POLICY IF EXISTS "Admins can manage creators" ON creators;
CREATE POLICY "Admins can manage creators"
  ON creators FOR ALL
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

DROP POLICY IF EXISTS "Anyone can read creators" ON creators;
CREATE POLICY "Anyone can read creators"
  ON creators FOR SELECT
  TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS "Anyone can read creator profiles" ON profiles;
CREATE POLICY "Anyone can read creator profiles"
  ON profiles FOR SELECT
  TO anon, authenticated
  USING (role = 'creator');

-- Series (webseries | podcast)
CREATE TABLE IF NOT EXISTS series (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id uuid NOT NULL REFERENCES creators(id) ON DELETE CASCADE,
  category_id uuid REFERENCES article_categories(id) ON DELETE SET NULL,
  type text NOT NULL CHECK (type IN ('webseries', 'podcast')),
  title text NOT NULL,
  slug text NOT NULL UNIQUE,
  description text,
  cover_image_url text,
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'published')),
  published_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_series_status_published_at
  ON series (status, published_at DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS idx_series_creator ON series (creator_id);
CREATE INDEX IF NOT EXISTS idx_series_category ON series (category_id);
CREATE INDEX IF NOT EXISTS idx_series_type_status ON series (type, status);
CREATE INDEX IF NOT EXISTS idx_series_slug ON series (slug);

ALTER TABLE series ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read published series" ON series;
CREATE POLICY "Anyone can read published series"
  ON series FOR SELECT
  TO anon, authenticated
  USING (status = 'published');

DROP POLICY IF EXISTS "Creators can read own series" ON series;
CREATE POLICY "Creators can read own series"
  ON series FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM creators c
      WHERE c.id = series.creator_id AND c.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Creators can insert own series" ON series;
CREATE POLICY "Creators can insert own series"
  ON series FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM creators c
      WHERE c.id = creator_id AND c.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Creators can update own series" ON series;
CREATE POLICY "Creators can update own series"
  ON series FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM creators c
      WHERE c.id = series.creator_id AND c.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM creators c
      WHERE c.id = series.creator_id AND c.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Creators can delete own series" ON series;
CREATE POLICY "Creators can delete own series"
  ON series FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM creators c
      WHERE c.id = series.creator_id AND c.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins manage all series" ON series;
CREATE POLICY "Admins manage all series"
  ON series FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- Episodes (1-N under a series)
CREATE TABLE IF NOT EXISTS series_episodes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  series_id uuid NOT NULL REFERENCES series(id) ON DELETE CASCADE,
  episode_number integer NOT NULL DEFAULT 1,
  title text NOT NULL,
  description text,
  youtube_url text,
  youtube_video_id text,
  thumbnail_url text,
  audio_url text,
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'published')),
  published_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE (series_id, episode_number)
);

CREATE INDEX IF NOT EXISTS idx_series_episodes_series_number
  ON series_episodes (series_id, episode_number);
CREATE INDEX IF NOT EXISTS idx_series_episodes_status
  ON series_episodes (status);

ALTER TABLE series_episodes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read published episodes of published series" ON series_episodes;
CREATE POLICY "Anyone can read published episodes of published series"
  ON series_episodes FOR SELECT
  TO anon, authenticated
  USING (
    status = 'published'
    AND EXISTS (
      SELECT 1 FROM series s
      WHERE s.id = series_episodes.series_id AND s.status = 'published'
    )
  );

DROP POLICY IF EXISTS "Creators can read own series episodes" ON series_episodes;
CREATE POLICY "Creators can read own series episodes"
  ON series_episodes FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM series s
      JOIN creators c ON c.id = s.creator_id
      WHERE s.id = series_episodes.series_id AND c.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Creators can insert own series episodes" ON series_episodes;
CREATE POLICY "Creators can insert own series episodes"
  ON series_episodes FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM series s
      JOIN creators c ON c.id = s.creator_id
      WHERE s.id = series_id AND c.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Creators can update own series episodes" ON series_episodes;
CREATE POLICY "Creators can update own series episodes"
  ON series_episodes FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM series s
      JOIN creators c ON c.id = s.creator_id
      WHERE s.id = series_episodes.series_id AND c.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM series s
      JOIN creators c ON c.id = s.creator_id
      WHERE s.id = series_episodes.series_id AND c.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Creators can delete own series episodes" ON series_episodes;
CREATE POLICY "Creators can delete own series episodes"
  ON series_episodes FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM series s
      JOIN creators c ON c.id = s.creator_id
      WHERE s.id = series_episodes.series_id AND c.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins manage all series episodes" ON series_episodes;
CREATE POLICY "Admins manage all series episodes"
  ON series_episodes FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- Public bucket for creator avatars / cover images
-- Paths: {profileId}/... or {creatorId}/covers/...
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'creator-assets',
  'creator-assets',
  true,
  10485760,
  ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "creator_assets_public_select" ON storage.objects;
CREATE POLICY "creator_assets_public_select" ON storage.objects
  FOR SELECT TO anon, authenticated
  USING (bucket_id = 'creator-assets');

DROP POLICY IF EXISTS "creator_assets_insert" ON storage.objects;
CREATE POLICY "creator_assets_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'creator-assets'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR (storage.foldername(name))[1] = auth.uid()::text
      OR EXISTS (
        SELECT 1 FROM creators c
        WHERE c.profile_id = auth.uid()
          AND c.id::text = (storage.foldername(name))[1]
      )
    )
  );

DROP POLICY IF EXISTS "creator_assets_update" ON storage.objects;
CREATE POLICY "creator_assets_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'creator-assets'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR (storage.foldername(name))[1] = auth.uid()::text
      OR EXISTS (
        SELECT 1 FROM creators c
        WHERE c.profile_id = auth.uid()
          AND c.id::text = (storage.foldername(name))[1]
      )
    )
  )
  WITH CHECK (
    bucket_id = 'creator-assets'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR (storage.foldername(name))[1] = auth.uid()::text
      OR EXISTS (
        SELECT 1 FROM creators c
        WHERE c.profile_id = auth.uid()
          AND c.id::text = (storage.foldername(name))[1]
      )
    )
  );

DROP POLICY IF EXISTS "creator_assets_delete" ON storage.objects;
CREATE POLICY "creator_assets_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'creator-assets'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR (storage.foldername(name))[1] = auth.uid()::text
      OR EXISTS (
        SELECT 1 FROM creators c
        WHERE c.profile_id = auth.uid()
          AND c.id::text = (storage.foldername(name))[1]
      )
    )
  );

-- Public bucket for podcast episode audio
-- Paths: {creatorId}/{seriesId}/{filename}
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'episode-audio',
  'episode-audio',
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

DROP POLICY IF EXISTS "episode_audio_public_select" ON storage.objects;
CREATE POLICY "episode_audio_public_select" ON storage.objects
  FOR SELECT TO anon, authenticated
  USING (bucket_id = 'episode-audio');

DROP POLICY IF EXISTS "episode_audio_insert" ON storage.objects;
CREATE POLICY "episode_audio_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'episode-audio'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR EXISTS (
        SELECT 1 FROM creators c
        WHERE c.profile_id = auth.uid()
          AND c.id::text = (storage.foldername(name))[1]
      )
    )
  );

DROP POLICY IF EXISTS "episode_audio_update" ON storage.objects;
CREATE POLICY "episode_audio_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'episode-audio'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR EXISTS (
        SELECT 1 FROM creators c
        WHERE c.profile_id = auth.uid()
          AND c.id::text = (storage.foldername(name))[1]
      )
    )
  )
  WITH CHECK (
    bucket_id = 'episode-audio'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR EXISTS (
        SELECT 1 FROM creators c
        WHERE c.profile_id = auth.uid()
          AND c.id::text = (storage.foldername(name))[1]
      )
    )
  );

DROP POLICY IF EXISTS "episode_audio_delete" ON storage.objects;
CREATE POLICY "episode_audio_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'episode-audio'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR EXISTS (
        SELECT 1 FROM creators c
        WHERE c.profile_id = auth.uid()
          AND c.id::text = (storage.foldername(name))[1]
      )
    )
  );
