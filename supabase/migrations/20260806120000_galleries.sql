-- News portal: photo galleries (albums) + photos (1-N)
CREATE TABLE IF NOT EXISTS galleries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  journalist_id uuid NOT NULL REFERENCES journalists(id) ON DELETE CASCADE,
  category_id uuid REFERENCES article_categories(id) ON DELETE SET NULL,
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

CREATE INDEX IF NOT EXISTS idx_galleries_status_published_at
  ON galleries (status, published_at DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS idx_galleries_journalist ON galleries (journalist_id);
CREATE INDEX IF NOT EXISTS idx_galleries_category ON galleries (category_id);
CREATE INDEX IF NOT EXISTS idx_galleries_slug ON galleries (slug);

CREATE TABLE IF NOT EXISTS gallery_photos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  gallery_id uuid NOT NULL REFERENCES galleries(id) ON DELETE CASCADE,
  photo_url text NOT NULL,
  caption text,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_gallery_photos_gallery_sort
  ON gallery_photos (gallery_id, sort_order);

ALTER TABLE galleries ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery_photos ENABLE ROW LEVEL SECURITY;

-- Galleries: public read published; journalists manage own; admins all
DROP POLICY IF EXISTS "Anyone can read published galleries" ON galleries;
CREATE POLICY "Anyone can read published galleries"
  ON galleries FOR SELECT
  TO anon, authenticated
  USING (status = 'published');

DROP POLICY IF EXISTS "Journalists can read own galleries" ON galleries;
CREATE POLICY "Journalists can read own galleries"
  ON galleries FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = galleries.journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can insert own galleries" ON galleries;
CREATE POLICY "Journalists can insert own galleries"
  ON galleries FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can update own galleries" ON galleries;
CREATE POLICY "Journalists can update own galleries"
  ON galleries FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = galleries.journalist_id AND j.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = galleries.journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can delete own galleries" ON galleries;
CREATE POLICY "Journalists can delete own galleries"
  ON galleries FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journalists j
      WHERE j.id = galleries.journalist_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins manage all galleries" ON galleries;
CREATE POLICY "Admins manage all galleries"
  ON galleries FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- Gallery photos: public read when parent gallery is published;
-- journalists manage photos of their own galleries; admins all
DROP POLICY IF EXISTS "Anyone can read photos of published galleries" ON gallery_photos;
CREATE POLICY "Anyone can read photos of published galleries"
  ON gallery_photos FOR SELECT
  TO anon, authenticated
  USING (
    EXISTS (
      SELECT 1 FROM galleries g
      WHERE g.id = gallery_photos.gallery_id AND g.status = 'published'
    )
  );

DROP POLICY IF EXISTS "Journalists can read own gallery photos" ON gallery_photos;
CREATE POLICY "Journalists can read own gallery photos"
  ON gallery_photos FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM galleries g
      JOIN journalists j ON j.id = g.journalist_id
      WHERE g.id = gallery_photos.gallery_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can insert own gallery photos" ON gallery_photos;
CREATE POLICY "Journalists can insert own gallery photos"
  ON gallery_photos FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM galleries g
      JOIN journalists j ON j.id = g.journalist_id
      WHERE g.id = gallery_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can update own gallery photos" ON gallery_photos;
CREATE POLICY "Journalists can update own gallery photos"
  ON gallery_photos FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM galleries g
      JOIN journalists j ON j.id = g.journalist_id
      WHERE g.id = gallery_photos.gallery_id AND j.profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM galleries g
      JOIN journalists j ON j.id = g.journalist_id
      WHERE g.id = gallery_photos.gallery_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Journalists can delete own gallery photos" ON gallery_photos;
CREATE POLICY "Journalists can delete own gallery photos"
  ON gallery_photos FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM galleries g
      JOIN journalists j ON j.id = g.journalist_id
      WHERE g.id = gallery_photos.gallery_id AND j.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins manage all gallery photos" ON gallery_photos;
CREATE POLICY "Admins manage all gallery photos"
  ON gallery_photos FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- Public bucket for gallery photos
-- Paths: {journalistId}/{galleryId}/{filename}
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'gallery-photos',
  'gallery-photos',
  true,
  15728640,
  ARRAY[
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
    'image/gif'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "gallery_photos_public_select" ON storage.objects;
CREATE POLICY "gallery_photos_public_select" ON storage.objects
  FOR SELECT TO anon, authenticated
  USING (bucket_id = 'gallery-photos');

DROP POLICY IF EXISTS "gallery_photos_insert" ON storage.objects;
CREATE POLICY "gallery_photos_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'gallery-photos'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR EXISTS (
        SELECT 1 FROM journalists j
        WHERE j.profile_id = auth.uid()
          AND j.id::text = (storage.foldername(name))[1]
      )
    )
  );

DROP POLICY IF EXISTS "gallery_photos_update" ON storage.objects;
CREATE POLICY "gallery_photos_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'gallery-photos'
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
    bucket_id = 'gallery-photos'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR EXISTS (
        SELECT 1 FROM journalists j
        WHERE j.profile_id = auth.uid()
          AND j.id::text = (storage.foldername(name))[1]
      )
    )
  );

DROP POLICY IF EXISTS "gallery_photos_delete" ON storage.objects;
CREATE POLICY "gallery_photos_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'gallery-photos'
    AND (
      EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
      OR EXISTS (
        SELECT 1 FROM journalists j
        WHERE j.profile_id = auth.uid()
          AND j.id::text = (storage.foldername(name))[1]
      )
    )
  );
