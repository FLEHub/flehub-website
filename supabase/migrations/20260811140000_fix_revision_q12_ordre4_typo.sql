/*
  # Correctif typo — Révision Conjugaison, Point 12, question 4

  "habitest-tu" → "habites-tu"
*/

UPDATE public.revision_questions q
SET question_texte = 'Tu m''as demandé : « Où habites-tu ? » → Tu m''as demandé où j''___ .'
FROM public.revision_points p
JOIN public.revision_unites u ON u.id = p.unite_id
WHERE q.point_id = p.id
  AND u.numero = 1
  AND p.numero = 12
  AND q.ordre = 4;
