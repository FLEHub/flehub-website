/*
  # Révision Unité 2 — Grammaire / parties du discours

  1. Renomme l'unité 2 en « Grammaire » (si besoin)
  2. Insère les 9 points (idempotent)
*/

-- Titre de l'unité 2
UPDATE public.revision_unites
SET titre = 'Grammaire'
WHERE numero = 2
  AND titre IS DISTINCT FROM 'Grammaire';

-- 9 points
INSERT INTO public.revision_points (unite_id, numero, titre)
SELECT u.id, v.numero, v.titre
FROM public.revision_unites u
CROSS JOIN (VALUES
  (1, 'Le nom : genre et nombre'),
  (2, 'Les déterminants (article défini/indéfini/partitif, possessifs, démonstratifs)'),
  (3, 'L''adjectif : accord, place, comparatif/superlatif'),
  (4, 'Les pronoms personnels (sujet, COD, COI, en, y)'),
  (5, 'Les pronoms relatifs (qui, que, dont, où, lequel)'),
  (6, 'Les pronoms démonstratifs et possessifs'),
  (7, 'Les adverbes (formation en -ment, place dans la phrase)'),
  (8, 'Les prépositions (lieu, temps, verbes + préposition fixe)'),
  (9, 'Les conjonctions de coordination et de subordination')
) AS v(numero, titre)
WHERE u.numero = 2
  AND NOT EXISTS (
    SELECT 1
    FROM public.revision_points p
    WHERE p.unite_id = u.id
      AND p.numero = v.numero
  );

NOTIFY pgrst, 'reload schema';
