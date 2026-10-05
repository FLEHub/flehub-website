/*
  La page « Choisir un enseignant » interroge teachers + profiles.
  Les règles qui relisent profiles depuis une règle sur profiles
  provoquent « infinite recursion » : la requête échoue, la page
  affiche « Aucun enseignant disponible ».

  On remplace ces règles par current_profile_role() (SECURITY DEFINER).
  L'apprenant ne reçoit plus la fiche complète de l'enseignant
  (donc pas l'e-mail, ni les coordonnées bancaires) : seulement
  nom, photo, biographie et modules publiés, via une fonction dédiée.

  L'enseignant ne lit les lignes learners que pour ses apprenants liés
  (ou ceux à qui il a assigné un module).
*/

DROP POLICY IF EXISTS "Admins can read all profiles" ON public.profiles;
CREATE POLICY "Admins can read all profiles"
  ON public.profiles FOR SELECT TO authenticated
  USING (public.current_profile_role() = 'admin');

-- Ne plus laisser un apprenant lire toute la ligne profiles d'un enseignant
-- (elle contient l'e-mail).
DROP POLICY IF EXISTS "Learners can read teacher profiles" ON public.profiles;

DROP POLICY IF EXISTS "Admins can read all teachers" ON public.teachers;
CREATE POLICY "Admins can read all teachers"
  ON public.teachers FOR SELECT TO authenticated
  USING (public.current_profile_role() = 'admin');

-- L'apprenant ne lit plus la table teachers (compte bancaire, etc.).
DROP POLICY IF EXISTS "Learners can read teachers" ON public.teachers;

DROP POLICY IF EXISTS "Admins and teachers can read learners" ON public.learners;
CREATE POLICY "Admins and teachers can read learners"
  ON public.learners FOR SELECT TO authenticated
  USING (public.teacher_can_read_learner_profile(profile_id));

CREATE OR REPLACE FUNCTION public.list_teachers_for_learners()
RETURNS TABLE (
  id uuid,
  full_name text,
  avatar_url text,
  bio text,
  specializations text[],
  modules jsonb
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    t.id,
    coalesce(nullif(btrim(p.full_name), ''), 'Enseignant') AS full_name,
    p.avatar_url,
    t.bio,
    coalesce(t.specializations, '{}'::text[]) AS specializations,
    coalesce(
      (
        SELECT jsonb_agg(
          jsonb_build_object('id', m.id, 'title', m.title)
          ORDER BY m.title
        )
        FROM elearning_modules m
        WHERE m.teacher_id = t.id
          AND m.published = true
      ),
      '[]'::jsonb
    ) AS modules
  FROM teachers t
  JOIN profiles p ON p.id = t.profile_id
  WHERE public.current_profile_role() = 'learner'
    AND p.role = 'teacher'
    AND p.status IN (
      'active',
      'approved',
      'pending_admin_validation'
    );
$$;

REVOKE ALL ON FUNCTION public.list_teachers_for_learners() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.list_teachers_for_learners() FROM anon;
GRANT EXECUTE ON FUNCTION public.list_teachers_for_learners() TO authenticated;
