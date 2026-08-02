-- News portal: categories + articles
CREATE TABLE IF NOT EXISTS article_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS articles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  journalist_id uuid NOT NULL REFERENCES journalists(id) ON DELETE CASCADE,
  category_id uuid REFERENCES article_categories(id) ON DELETE SET NULL,
  title text NOT NULL,
  slug text NOT NULL UNIQUE,
  excerpt text,
  content text NOT NULL DEFAULT '',
  cover_image_url text,
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'published')),
  published_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_articles_status_published_at
  ON articles (status, published_at DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS idx_articles_journalist ON articles (journalist_id);
CREATE INDEX IF NOT EXISTS idx_articles_category ON articles (category_id);
CREATE INDEX IF NOT EXISTS idx_articles_slug ON articles (slug);

ALTER TABLE article_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;

-- Categories: public read; admin manage
DROP POLICY IF EXISTS "Anyone can read article categories" ON article_categories;
CREATE POLICY "Anyone can read article categories"
  ON article_categories FOR SELECT
  TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS "Admins manage article categories" ON article_categories;
CREATE POLICY "Admins manage article categories"
  ON article_categories FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- Articles: public read published; journalists manage own; admins all
DROP POLICY IF EXISTS "Anyone can read published articles" ON articles;
CREATE POLICY "Anyone can read published articles"
  ON articles FOR SELECT
  TO anon, authenticated
  USING (status = 'published');

DROP POLICY IF EXISTS "Journalists can read own articles" ON articles;
CREATE POLICY "Journalists can read own articles"
  ON articles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = articles.journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can insert own articles" ON articles;
CREATE POLICY "Journalists can insert own articles"
  ON articles FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can update own articles" ON articles;
CREATE POLICY "Journalists can update own articles"
  ON articles FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = articles.journalist_id AND j.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = articles.journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can delete own articles" ON articles;
CREATE POLICY "Journalists can delete own articles"
  ON articles FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = articles.journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins manage all articles" ON articles;
CREATE POLICY "Admins manage all articles"
  ON articles FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- Public can read journalist rows + profile names for bylines
DROP POLICY IF EXISTS "Anyone can read journalists" ON journalists;
CREATE POLICY "Anyone can read journalists"
  ON journalists FOR SELECT
  TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS "Anyone can read journalist profiles" ON profiles;
CREATE POLICY "Anyone can read journalist profiles"
  ON profiles FOR SELECT
  TO anon, authenticated
  USING (role = 'journalist');

-- Public can load cover images from the journalist-assets bucket
DROP POLICY IF EXISTS "journalist_assets_public_select" ON storage.objects;
CREATE POLICY "journalist_assets_public_select" ON storage.objects
  FOR SELECT TO anon, authenticated
  USING (bucket_id = 'journalist-assets');

-- Seed default categories (idempotent)
INSERT INTO article_categories (name, slug)
VALUES
  ('Actualités', 'actualites'),
  ('Événements', 'evenements'),
  ('Culture', 'culture'),
  ('Éducation', 'education'),
  ('Francophonie', 'francophonie')
ON CONFLICT (slug) DO NOTHING;
