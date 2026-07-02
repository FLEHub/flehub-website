
-- Storage RLS for exam-papers bucket (admin upload, authenticated read)
CREATE POLICY "exam_papers_select" ON storage.objects FOR SELECT
  TO authenticated USING (bucket_id = 'exam-papers');

CREATE POLICY "exam_papers_insert" ON storage.objects FOR INSERT
  TO authenticated WITH CHECK (
    bucket_id = 'exam-papers'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "exam_papers_update" ON storage.objects FOR UPDATE
  TO authenticated USING (
    bucket_id = 'exam-papers'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "exam_papers_delete" ON storage.objects FOR DELETE
  TO authenticated USING (
    bucket_id = 'exam-papers'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Storage RLS for exam-audio bucket (admin upload, authenticated read)
CREATE POLICY "exam_audio_select" ON storage.objects FOR SELECT
  TO authenticated USING (bucket_id = 'exam-audio');

CREATE POLICY "exam_audio_insert" ON storage.objects FOR INSERT
  TO authenticated WITH CHECK (
    bucket_id = 'exam-audio'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "exam_audio_update" ON storage.objects FOR UPDATE
  TO authenticated USING (
    bucket_id = 'exam-audio'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "exam_audio_delete" ON storage.objects FOR DELETE
  TO authenticated USING (
    bucket_id = 'exam-audio'
    AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
