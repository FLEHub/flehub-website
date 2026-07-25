-- Lesson content type: youtube URL | image storage path | free text
-- Stored value remains in elearning_lessons.content

ALTER TABLE elearning_lessons
  ADD COLUMN IF NOT EXISTS content_type text NOT NULL DEFAULT 'text';

ALTER TABLE elearning_lessons
  DROP CONSTRAINT IF EXISTS elearning_lessons_content_type_check;

ALTER TABLE elearning_lessons
  ADD CONSTRAINT elearning_lessons_content_type_check
  CHECK (content_type IN ('youtube', 'image', 'text'));

-- Allow lesson images in the existing elearning-media bucket
UPDATE storage.buckets
SET allowed_mime_types = ARRAY[
  'audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/webm', 'audio/ogg', 'audio/x-m4a', 'audio/mp4',
  'video/mp4', 'video/webm', 'video/quicktime',
  'image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif'
]
WHERE id = 'elearning-media';
