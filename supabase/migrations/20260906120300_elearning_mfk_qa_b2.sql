/*
  Relecture QA MFK — correctifs idempotents (niveau B2).
  UPDATE ciblés uniquement. Aucune table nouvelle.
  published n'est pas modifié.
  Clés métier : titre de module + titre de séquence + compétence
  (+ type et order_index pour les exercices).
*/

-- B2 — Mémoire du Seuil
UPDATE elearning_lessons l
SET content = $qa$Objectif
Repérer si + plus-que-parfait et le conditionnel passé pour une hypothèse non réalisée.

Consigne
Lisez l'entretien (à écouter avec l'enseignant). Quelles actions n'ont pas eu lieu ?

Support — Entretien sous le figuier, photos ocre
Sami : Si j'avais su que le Cahier du chemin dormait si longtemps, j'aurais ouvert plus tôt.
Mado : Si nous avions écouté les anciens avant la pluie, nous aurions noté d'autres noms.
Aline Uwase : Attention : si + plus-que-parfait, ensuite le conditionnel passé. Pas « si j'aurais ».
Léa Niyonzima : Si j'avais su le pont si glissant, je serais restée trois jeudis de plus.
Patrick Habimana : Si tu m'avais prévenu, j'aurais porté la valise autrement, moins vite.
Marc Nkurunziza : Si Lila avait enregistré Sami à temps, Radio Figuier aurait une archive, pas seulement un écho.
Hawa Diallo : Si nous n'avions pas attendu, nous aurions perdu moins de voix.
Joël Mugisha : Si j'avais su le vent de ce soir-là, j'aurais accroché moins haut.
Rose Iradukunda : Si l'on m'avait dit le nom du premier lin, j'aurais cousu une pièce de plus, pour la cour.
Solange Mukamana : Si le tampon avait été posé, nous saurions la date. Là, nous hypothèsons.
Karim Bamba : Si j'avais su qui payait l'huile, j'aurais moins crié sur le prix.
Lila Sow : Si j'avais tendu le micro plus tôt, j'aurais moins de regrets, plus de bandes.
Félicie : Si Dieudonné avait réparé la table avant, le cahier n'aurait pas glissé.
Yvette : Si nous avions nommé les dangers, quelqu'un se serait moins brûlé les doigts.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'B2 — Mémoire du Seuil'
  AND s.title = 'Hypothèses sur le passé'
  AND l.competency = 'CO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire des extraits d'archives et en comprendre le statut (tenu / hypothétisé).

Consigne
Lisez les feuillets, sans aller trop vite.

Support — Feuillets du Cahier du chemin, encre et marge
Feuillet 1. Sami écrivit : « Je tiens le tampon manquant. J'imagine une date après la pluie. »
Feuillet 2. Mado ajouta en marge : « Tache vérifiée. Bol de Félicie non mentionné dans la page sèche. »
Feuillet 3. Lila déposa : « Bande du vent. Dieudonné absent de l'écoute. Datée, signée. »
Il dit, plus bas, qu'une archive n'efface pas une autre voix : elle la cote.
Nous vîmes ensuite la main de Rose : un lin glissé, sans prix, avec un doute en marge sur le nom.
Karim vint et écrivit : « Huile : qui paie ? » — question, pas slogan.
Aline reprit : appartenir à ceux qui liront, c'est laisser de l'air, pas remplir.
Léa, de Rive-des-Saules, envoya une lettre : elle entra par la marge, comme convenu.
Yvette nota une brûlure ancienne ; Solange refusa un tampon trop neuf, trop sûr.
Dieudonné signa le calage de la table : sans ce geste, les feuillets glisseraient encore.
Joël data une lanterne trop haute : hypothèse utile pour demain, dit-il.
Hawa copia les règles : dater, signer, marger, séparer tenu et imaginé.
Patrick lut trop vite au milieu ; il promit la marge désormais.
Nous relûmes le tout lorsque le soleil baissa : l'archive était devenue une société, pas un tiroir.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'B2 — Mémoire du Seuil'
  AND s.title = 'Archives du Cahier du chemin'
  AND l.competency = 'CE';

-- B2 — Une culture commune
UPDATE elearning_modules
SET description = 'Grande étape B2-3 : comparer et résumer des œuvres inventées, débattre et dresser des portraits (Mado, Sami, Aline), poser un problème culturel et des solutions, parler d''une tendance et d''une création, puis rédiger une critique et un manifeste — Saison des Voix, pièce « La cour n''oublie pas », livre « Le figuier n''oublie pas », Veillée des Lampions et tambour de Sami, au Seuil des Sources (Rukiri-Nord).'
WHERE title = 'B2 — Une culture commune';

-- B2 — Vivre avec la technologie
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "left": "parce que la trace est incomplète",
      "right": "on reconstruit mal"
    },
    {
      "left": "puisqu'une marque reste",
      "right": "retracer possible"
    },
    {
      "left": "de sorte que",
      "right": "trois cours / visage revenu"
    },
    {
      "left": "si bien que",
      "right": "réponse trop vite / mémoire-bruit"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'B2 — Vivre avec la technologie'
  AND s.title = 'Mémoire et réseaux'
  AND l.competency = 'PE'
  AND e.exercise_type = 'matching'
  AND e.order_index = 2;
