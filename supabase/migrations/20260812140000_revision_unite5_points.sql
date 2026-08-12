/*
  # Révision Unité 5 — Prépositions et connecteurs

  1. Assure le titre de l'unité 5
  2. Insère les 12 points (idempotent)
*/

UPDATE public.revision_unites
SET titre = 'Prépositions et connecteurs'
WHERE numero = 5
  AND titre IS DISTINCT FROM 'Prépositions et connecteurs';

INSERT INTO public.revision_points (unite_id, numero, titre)
SELECT u.id, v.numero, v.titre
FROM public.revision_unites u
CROSS JOIN (VALUES
  (1,  'Prépositions simples'),
  (2,  'Prépositions composées / locutions prépositives'),
  (3,  'Prépositions de lieu'),
  (4,  'Prépositions de temps'),
  (5,  'Connecteurs d''addition'),
  (6,  'Connecteurs de cause'),
  (7,  'Connecteurs de conséquence'),
  (8,  'Connecteurs d''opposition et de concession'),
  (9,  'Connecteurs de but'),
  (10, 'Connecteurs chronologiques / organisateurs textuels'),
  (11, 'Connecteurs de comparaison'),
  (12, 'Connecteurs de conclusion et de synthèse')
) AS v(numero, titre)
WHERE u.numero = 5
  AND NOT EXISTS (
    SELECT 1
    FROM public.revision_points p
    WHERE p.unite_id = u.id
      AND p.numero = v.numero
  );

NOTIFY pgrst, 'reload schema';
