/*
  # TCF EE — préparateur peut mettre à jour les tentatives de ses séances

  Nécessaire pour passer student_ee_attempts.statut à "corrige"
  lors de la publication d'une correction.
*/

DROP POLICY IF EXISTS "Teachers can update ee attempts on own sessions"
  ON public.student_ee_attempts;

CREATE POLICY "Teachers can update ee attempts on own sessions"
  ON public.student_ee_attempts FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.tcf_ee_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.tcf_ee_sessions s
      JOIN public.profiles p ON p.id = auth.uid()
      WHERE s.id = session_id
        AND s.created_by = auth.uid()
        AND p.role = 'teacher'
    )
  );

NOTIFY pgrst, 'reload schema';
