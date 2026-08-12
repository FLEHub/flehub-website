/*
  # Révision Unité 4 — Le Pronom

  1. Renomme l'unité 4 en « Le Pronom »
  2. Insère les 12 points (idempotent)
*/

UPDATE public.revision_unites
SET titre = 'Le Pronom'
WHERE numero = 4
  AND titre IS DISTINCT FROM 'Le Pronom';

INSERT INTO public.revision_points (unite_id, numero, titre)
SELECT u.id, v.numero, v.titre
FROM public.revision_unites u
CROSS JOIN (VALUES
  (1,  'Pronoms personnels sujets'),
  (2,  'Pronoms personnels compléments directs (COD)'),
  (3,  'Pronoms personnels compléments indirects (COI)'),
  (4,  'Pronoms toniques'),
  (5,  'Les pronoms "en" et "y"'),
  (6,  'Double pronominalisation et leur ordre'),
  (7,  'Pronoms relatifs simples (qui, que, dont, où)'),
  (8,  'Pronoms relatifs composés (lequel, auquel, duquel)'),
  (9,  'Pronoms démonstratifs'),
  (10, 'Pronoms possessifs'),
  (11, 'Pronoms indéfinis'),
  (12, 'Pronoms interrogatifs')
) AS v(numero, titre)
WHERE u.numero = 4
  AND NOT EXISTS (
    SELECT 1
    FROM public.revision_points p
    WHERE p.unite_id = u.id
      AND p.numero = v.numero
  );

NOTIFY pgrst, 'reload schema';
