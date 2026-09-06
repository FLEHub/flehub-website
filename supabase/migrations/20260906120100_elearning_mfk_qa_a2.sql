/*
  Relecture QA MFK — correctifs idempotents (niveau A2).
  UPDATE ciblés uniquement. Aucune table nouvelle.
  published n'est pas modifié.
  Clés métier : titre de module + titre de séquence + compétence
  (+ type et order_index pour les exercices).
*/

-- A2 — Cultures en partage
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre des questions formelles à l'inversion.

Consigne
Lisez le dialogue. Quelles questions sont inversées ?

Support — Pupitre de la Salle des Herbes
Aline : Avez-vous entendu le chant du figuier ?
Patrick : Pouvez-vous expliquer la danse des trois rives ?
Karim : Quel est le thème de Radio Figuier ce soir ?
Solange : Savez-vous où se tient l'échange des carnets ?
Noura : Faut-il éteindre les lanternes à minuit ?
Lila : Qu'est-ce qui a changé depuis hier ?
Marc : Est-ce que le marché ferme à vingt-deux heures ?
Hawa : Où se trouve le micro, s'il vous plaît ?
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'A2 — Cultures en partage'
  AND s.title = 'Demander des explications'
  AND l.competency = 'CO';

-- A2 — Le monde en direct
UPDATE elearning_lessons l
SET title = 'CE — Feuille de la une', content = $qa$Objectif
Lire un bulletin local entièrement au passif.

Consigne
Lisez la feuille, sans aller trop vite.

Support — Feuille de la une, Radio Figuier
Le monde en direct — bulletin du Seuil
Le marché des Lampions a été ouvert à l'aube. Il a été tenu par Mado et Sami.
Une barque a été trouvée près du lac des Nénuphars. Elle a été ramenée par Benoît.
Le Cahier des racines a été relu. Trois noms ont été ajoutés.
L'Atelier du Tissu a été visité. Un coupon ocre a été offert par Dieudonné.
Aucune rumeur n'a été confirmée. Chaque phrase a été pesée.
Prochaine émission : le fait sera raconté de nouveau à midi.
Studio Figuier — Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'A2 — Le monde en direct'
  AND s.title = 'Un fait à raconter'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Repérer on = nous, on = quelqu'un, on = les gens, dans un échange sur un livre.

Consigne
Lisez le dialogue. Qui est « on » à chaque fois ?

Support — Table des Sources, couverture ocre
Léa : On a lu « Le figuier n'oublie pas », le Cahier du chemin. On = nous, l'équipe.
Marc : On raconte qu'un arbre garde les voix. On = les gens, on dit que…
Aline : On a sonné à la porte du studio. On = quelqu'un, on ne sait pas qui.
Patrick : Dans le livre, on marche jusqu'à la rive. On = le lecteur, tout le monde.
Hawa : On aime ce titre. On n'oublie pas le Seuil. On = nous encore.
Joël : Si on ouvre la page 3, on voit un banc. On = n'importe qui.
Rose : On ne prête pas ce livre sans le noter. On = règle, les gens du Seuil.
Karim : On m'a dit que Lila l'avait copié à la main. On = quelqu'un.
Benoît : On finit par l'antenne. On = nous, Léa et Marc.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'A2 — Le monde en direct'
  AND s.title = 'Parler d''un livre'
  AND l.competency = 'CO';
