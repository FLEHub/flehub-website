/*
  # Correctif typo — Révision Conjugaison, Point 12, question 4

  - "habitest-tu" → "habites-tu"
  - distracteur "habiteais" → "habiterais" (si déjà seedé)
*/

UPDATE public.revision_questions q
SET
  question_texte = 'Tu m''as demandé : « Où habites-tu ? » → Tu m''as demandé où j''___ .',
  choix_c = CASE
    WHEN q.choix_c = 'habiteais' THEN 'habiterais'
    ELSE q.choix_c
  END,
  choix_a = CASE
    WHEN q.choix_a = 'habiteais' THEN 'habiterais'
    ELSE q.choix_a
  END,
  choix_b = CASE
    WHEN q.choix_b = 'habiteais' THEN 'habiterais'
    ELSE q.choix_b
  END,
  choix_d = CASE
    WHEN q.choix_d = 'habiteais' THEN 'habiterais'
    ELSE q.choix_d
  END
FROM public.revision_points p
JOIN public.revision_unites u ON u.id = p.unite_id
WHERE q.point_id = p.id
  AND u.numero = 1
  AND p.numero = 12
  AND q.ordre = 4;
