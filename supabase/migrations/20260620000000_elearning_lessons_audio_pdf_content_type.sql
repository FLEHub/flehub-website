-- Extend lesson content_type with audio and pdf (storage path in content)

ALTER TABLE elearning_lessons
  DROP CONSTRAINT IF EXISTS elearning_lessons_content_type_check;

ALTER TABLE elearning_lessons
  ADD CONSTRAINT elearning_lessons_content_type_check
  CHECK (content_type IN ('youtube', 'image', 'text', 'audio', 'pdf'));

-- Allow PDF uploads in elearning-media (audio MIME types already present)
UPDATE storage.buckets
SET allowed_mime_types = ARRAY[
  'audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/webm', 'audio/ogg', 'audio/x-m4a', 'audio/mp4',
  'video/mp4', 'video/webm', 'video/quicktime',
  'image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif',
  'application/pdf'
]
WHERE id = 'elearning-media';
