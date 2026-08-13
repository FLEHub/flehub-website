/*
  # Révision Unité 6 — Vocabulaire

  1. Renomme l'unité 6 en « Vocabulaire »
  2. Insère les 12 points (idempotent)
*/

UPDATE public.revision_unites
SET titre = 'Vocabulaire'
WHERE numero = 6
  AND titre IS DISTINCT FROM 'Vocabulaire';

INSERT INTO public.revision_points (unite_id, numero, titre)
SELECT u.id, v.numero, v.titre
FROM public.revision_unites u
CROSS JOIN (VALUES
  (1,  'Préfixes courants'),
  (2,  'Suffixes courants'),
  (3,  'Familles de mots'),
  (4,  'Synonymes et nuances de sens'),
  (5,  'Antonymes'),
  (6,  'Homonymes et paronymes'),
  (7,  'Polysémie (un mot, plusieurs sens selon le contexte)'),
  (8,  'Registres de langue (familier / courant / soutenu)'),
  (9,  'Vocabulaire thématique : travail et vie professionnelle'),
  (10, 'Vocabulaire thématique : société, environnement, actualité'),
  (11, 'Expressions idiomatiques et locutions figées — niveau A2-B1'),
  (12, 'Expressions idiomatiques et locutions figées — niveau B2-C2')
) AS v(numero, titre)
WHERE u.numero = 6
  AND NOT EXISTS (
    SELECT 1
    FROM public.revision_points p
    WHERE p.unite_id = u.id
      AND p.numero = v.numero
  );

NOTIFY pgrst, 'reload schema';
