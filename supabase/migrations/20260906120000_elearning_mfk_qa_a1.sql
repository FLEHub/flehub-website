/*
  Relecture QA MFK — correctifs idempotents (niveau A1).
  UPDATE ciblés uniquement. Aucune table nouvelle.
  published n'est pas modifié.
  Clés métier : titre de module + titre de séquence + compétence
  (+ type et order_index pour les exercices).
*/

-- A1 — Premiers repères
UPDATE elearning_lessons l
SET title = 'CO — Un « bonjour » sous l''auvent'
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'A1 — Premiers repères'
  AND s.title = 'Bienvenue en français'
  AND l.competency = 'CO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Fixer : nombres 0–20, avoir + âge, jours, c'est + jour.

Consigne
Fiche collée dans le carton à livres.

Fiche
0 zéro 1 un 2 deux 3 trois 4 quatre 5 cinq
6 six 7 sept 8 huit 9 neuf 10 dix
11 onze 12 douze 13 treize 14 quatorze 15 quinze
16 seize 17 dix-sept 18 dix-huit 19 dix-neuf 20 vingt

J'ai vingt ans. Tu as quel âge ?
C'est lundi. C'est mardi. On est quel jour ?
lundi mardi mercredi jeudi vendredi samedi dimanche
Nous sommes quatre.$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'A1 — Premiers repères'
  AND s.title = 'Se compter et s''organiser'
  AND l.competency = 'EL';
UPDATE elearning_exercises e
SET content = $qj${
  "word": "parle",
  "hint": "Verbe après « je » pour une langue."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'A1 — Premiers repères'
  AND s.title = 'Le monde en français'
  AND l.competency = 'PO'
  AND e.exercise_type = 'anagram'
  AND e.order_index = 5;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Fixer : être, nationalités (accord), d'où, je parle, de / du / de la / en / au.

Consigne
Fiche au dos du carton.

Fiche
je suis tu es il / elle est
nous sommes vous êtes ils / elles sont

rwandais / rwandaise
burundais / burundaise
français / française
congolais / congolaise

Je viens de France. Je vis en France.
Je viens du Rwanda. Je vis au Rwanda.
Je viens du Burundi. Je vis au Burundi.
Je viens de la RDC.

Je parle français. Tu parles quelle langue ?$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'A1 — Premiers repères'
  AND s.title = 'Le monde en français'
  AND l.competency = 'EL';
UPDATE elearning_exercises e
SET content = $qj${
  "word": "livre",
  "hint": "Sonia le montre sur le muret."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'A1 — Premiers repères'
  AND s.title = 'Vivre en classe'
  AND l.competency = 'CO'
  AND e.exercise_type = 'anagram'
  AND e.order_index = 5;
UPDATE elearning_exercises e
SET content = $qj${
  "word": "stylo",
  "hint": "Inès le demande à Yvan."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'A1 — Premiers repères'
  AND s.title = 'Vivre en classe'
  AND l.competency = 'CE'
  AND e.exercise_type = 'anagram'
  AND e.order_index = 5;
UPDATE elearning_exercises e
SET content = $qj${
  "word": "cahier",
  "hint": "Consigne d'Inès au début de l'atelier."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'A1 — Premiers repères'
  AND s.title = 'Vivre en classe'
  AND l.competency = 'PO'
  AND e.exercise_type = 'anagram'
  AND e.order_index = 5;
UPDATE elearning_exercises e
SET content = $qj${
  "word": "table",
  "hint": "Objet pliant de l'atelier."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'A1 — Premiers repères'
  AND s.title = 'Vivre en classe'
  AND l.competency = 'PE'
  AND e.exercise_type = 'anagram'
  AND e.order_index = 5;
UPDATE elearning_exercises e
SET content = $qj${
  "word": "stylo",
  "hint": "Objet masculin que Didier note sur sa liste."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'A1 — Premiers repères'
  AND s.title = 'Vivre en classe'
  AND l.competency = 'EL'
  AND e.exercise_type = 'anagram'
  AND e.order_index = 5;

-- A1 — Histoires vécues
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un choix : avant + passé composé, maintenant + présent.

Consigne
Qu'a fait Yvette avant ? Que fait-elle maintenant ?

Support — Infirmerie des Herbes, thé à la main
Yvette : Avant, j'ai travaillé loin. J'ai habité en ville.
Léa : Et maintenant ?
Yvette : J'ai choisi la colline. Maintenant, je suis ici. Je travaille à l'Infirmerie des Herbes.
Joël : Moi, avant, j'ai conduit un grand bus. Maintenant, je suis à la moto.
Aline : J'ai choisi l'accueil. Maintenant, j'ouvre le Seuil.
Patrick : On a tous choisi un chemin.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'A1 — Histoires vécues'
  AND s.title = 'Un choix de vie'
  AND l.competency = 'CO';
