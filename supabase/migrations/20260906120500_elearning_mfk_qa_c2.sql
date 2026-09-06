/*
  Relecture QA MFK — correctifs idempotents (niveau C2).
  UPDATE ciblés uniquement. Aucune table nouvelle.
  published n'est pas modifié.
  Clés métier : titre de module + titre de séquence + compétence
  (+ type et order_index pour les exercices).
*/

-- C2 — Bonheurs et utopies
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Analyser un extrait inventé et formuler un point de vue critique sans résumé plat. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Scène sous le figuier
Lila Sow : Radio Figuier. On parle trop vite d'une scène trop calme à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on tienne lieu d'analyse, un adjectif trop large pour une scène trop retenue n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que l'émotion a sa place après le spectacle, pour autant que l'on dise d'abord ce que les silences ont fait.
Aline Uwase : Ce que l'on nomme sous-entendu, ici, n'est pas un slogan : sens non dit, à justifier.
Mado : loin de bouleverser, la scène a figé, ce qui n'est pas rien.
Hawa Diallo : Fût-ce à voix basse, Léa a dit le contraire de son sourire.
Joël Mugisha : Sami a ri trop tard : on aurait dit une consigne.
Aline : l'ironie n'est pas un rire, c'est un écart.
Solange Mukamana : Patrick refuse le mot chef-d'œuvre.
Karim Bamba : Lila a trop vite conclu.
Félicie Ndayishimiye : Un chiffre, une trace : Trois silences de huit secondes ; un rire trop tardif ; zéro larme, malgré l'adjectif trop large.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de juger une scène, pas de se juger ému
Yvette : Rose a cousu dans le noir, mieux que le plateau.
Mado : Sami entend, dans « quelle émotion », ceci qui n'est pas dit : quelle émotion dispense souvent de voir que personne n'a osé bouger
Sami : Autrement dit, interpréter, c'est lire le non-jeu autant que le jeu
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un échange d'impressions — deux lectures, une ironie, zéro adjectif orphelin
Marc : un point de vue critique nomme le silence, pas seulement l'acteur.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'extrait joué par Léa et Marc d'un côté, l'émission trop rapide de Lila de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Il ne s'agirait que d'un détail, bien sûr : personne n'a bougé, et l'on appelle cela du recueillement.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Scène sous le figuier'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un adjectif trop large pour une scène trop retenue est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un adjectif trop large pour une scène trop retenue n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Scène sous le figuier'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Analyser un extrait inventé et formuler un point de vue critique sans résumé plat. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le silence a joué aussi », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le silence a joué aussi
On parle trop vite d'une scène trop calme à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu d'analyse, un adjectif trop large pour une scène trop retenue n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que l'émotion a sa place après le spectacle, pour autant que l'on dise d'abord ce que les silences ont fait.
Ce que l'on nomme sous-entendu, ici, n'est pas un slogan : sens non dit, à justifier.
Mado : loin de bouleverser, la scène a figé, ce qui n'est pas rien.
Fût-ce à voix basse, Léa a dit le contraire de son sourire.
Sami a ri trop tard : on aurait dit une consigne.
Aline : l'ironie n'est pas un rire, c'est un écart.
Patrick refuse le mot chef-d'œuvre.
Lila a trop vite conclu.
Un chiffre, une trace : Trois silences de huit secondes ; un rire trop tardif ; zéro larme, malgré l'adjectif trop large.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de juger une scène, pas de se juger ému
Rose a cousu dans le noir, mieux que le plateau.
Sami entend, dans « quelle émotion », ceci qui n'est pas dit : quelle émotion dispense souvent de voir que personne n'a osé bouger
Autrement dit, interpréter, c'est lire le non-jeu autant que le jeu
La proposition qui reste debout est celle-ci : un échange d'impressions — deux lectures, une ironie, zéro adjectif orphelin
Marc : un point de vue critique nomme le silence, pas seulement l'acteur.
Nous clôturons sans fusionner les voix : l'extrait joué par Léa et Marc d'un côté, l'émission trop rapide de Lila de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Scène sous le figuier'
  AND l.competency = 'CE';
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/critique-film.svg",
      "word": "critique film"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/sentiment-fin.svg",
      "word": "sentiment fin"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/scene-ombres.svg",
      "word": "scene ombres"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/joie-horloge.svg",
      "word": "joie-horloge"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Scène sous le figuier'
  AND l.competency = 'CE'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : interprétation théâtrale ; sous-entendu ; point de vue critique.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on tienne lieu d'analyse, un adjectif trop large pour une scène trop retenue n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que l'émotion a sa place après le spectacle, pour autant que l'on dise d'abord ce que les silences ont fait.
Ce que l'on nomme sous-entendu, ici, n'est pas un slogan : sens non dit, à justifier.
Encore que l'on interprète, un adjectif trop large pour une scène trop retenue n'est pas un détail.
Mado concède que l'émotion a sa place après le spectacle, pour autant que l'on dise d'abord ce que les silences ont fait.
Autrement dit, interpréter, c'est lire le non-jeu autant que le jeu
Il ressort qu'un échange d'impressions : deux lectures, une ironie, zéro adjectif orphelin
Fût-ce à voix basse, Léa a dit le contraire de son sourire.
Patrick refuse le mot chef-d'œuvre.
La proposition qui reste debout est celle-ci : un échange d'impressions — deux lectures, une ironie, zéro adjectif orphelin
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'extrait joué par Léa et Marc d'un côté, l'émission trop rapide de Lila de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Scène sous le figuier'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/sentiment-fin.svg",
      "word": "sentiment fin"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/scene-ombres.svg",
      "word": "scene ombres"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/joie-horloge.svg",
      "word": "joie-horloge"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/bonheur-usine.svg",
      "word": "bonheur usine"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Scène sous le figuier'
  AND l.competency = 'PO'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Analyser un extrait inventé et formuler un point de vue critique sans résumé plat. Point : interprétation théâtrale ; sous-entendu ; point de vue critique.

Consigne
Imitez le texte de Mado.

Support — Mado — Le silence a joué aussi
Mado — Le silence a joué aussi
On parle trop vite d'une scène trop calme à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu d'analyse, un adjectif trop large pour une scène trop retenue n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que l'émotion a sa place après le spectacle, pour autant que l'on dise d'abord ce que les silences ont fait.
Ce que l'on nomme sous-entendu, ici, n'est pas un slogan : sens non dit, à justifier.
Mado : loin de bouleverser, la scène a figé, ce qui n'est pas rien.
Patrick refuse le mot chef-d'œuvre.
Lila a trop vite conclu.
Rose a cousu dans le noir, mieux que le plateau.
La proposition qui reste debout est celle-ci : un échange d'impressions — deux lectures, une ironie, zéro adjectif orphelin
Marc : un point de vue critique nomme le silence, pas seulement l'acteur.
Nous clôturons sans fusionner les voix : l'extrait joué par Léa et Marc d'un côté, l'émission trop rapide de Lila de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on interprète, un adjectif trop large pour une scène trop retenue n'est pas un détail.
Mado concède que l'émotion a sa place après le spectacle, pour autant que l'on dise d'abord ce que les silences ont fait.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
interpréter, c'est lire le non-jeu autant que le jeu
Mado, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Scène sous le figuier'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Mado sur « Scène sous le figuier » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Mado sur « Scène sous le figuier » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Scène sous le figuier'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/scene-ombres.svg",
      "word": "scene ombres"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/joie-horloge.svg",
      "word": "joie-horloge"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/bonheur-usine.svg",
      "word": "bonheur usine"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/interview-doute.svg",
      "word": "interview doute"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Scène sous le figuier'
  AND l.competency = 'PE'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/joie-horloge.svg",
      "word": "joie-horloge"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/bonheur-usine.svg",
      "word": "bonheur usine"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/interview-doute.svg",
      "word": "interview doute"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/sourire-mesure.svg",
      "word": "sourire mesure"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Scène sous le figuier'
  AND l.competency = 'EL'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Prendre position sur un bonheur trop mesuré, trop vendu. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Bonheur en série
Lila Sow : Radio Figuier. On parle trop vite du bonheur à l'heure dite sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on usine un sourire à dix-huit heures, une joie qui ressemble à un planning n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Sami concède qu'un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
Aline Uwase : Ce que l'on nomme bonheur, ici, n'est pas un slogan : sentiment, pas une consigne.
Sami : il ne s'agirait que d'un détail, la fatigue, à entendre les animateurs trop nets.
Hawa Diallo : Loin de rassurer, le sourire de dix-huit heures lasse.
Joël Mugisha : Mado écrit la suite d'un extrait où le personnage rayonne trop pour être cru.
Aline : l'antiphrase se signale par un trop.
Solange Mukamana : Félicie pose le bol sans « savoure ! ».
Karim Bamba : Lila n'ouvrira pas une émission de bonheur.
Félicie Ndayishimiye : Un chiffre, une trace : Sami a compté sept soirs « heureux » ; trois bâillements cachés ; zéro droit déclaré à la fatigue.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de pouvoir être las sans être coupable
Yvette : a le droit d'être lasse.
Mado : entend, dans « soyez heureux », ceci qui n'est pas dit : soyez heureux arrive souvent quand on n'a plus le droit d'être las
Sami : Autrement dit, si tant est que le bonheur s'industrialise, il se vendrait déjà au Marché des Lampions
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une tribune — contre la joie obligatoire, pour les soirs sans score
Marc : prendre position, c'est refuser l'usine à joie.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'interview trop lisse d'un animateur inventé d'un côté, l'extrait de roman de Mado de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : On nous dit que tout va bien, ce qui, en soi, devrait rassurer — et n'y parvient pas.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Bonheur en série'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une joie qui ressemble à un planning est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une joie qui ressemble à un planning n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Bonheur en série'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Prendre position sur un bonheur trop mesuré, trop vendu. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « La joie n'est pas un planning », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La joie n'est pas un planning
On parle trop vite du bonheur à l'heure dite sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on usine un sourire à dix-huit heures, une joie qui ressemble à un planning n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède qu'un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
Ce que l'on nomme bonheur, ici, n'est pas un slogan : sentiment, pas une consigne.
Sami : il ne s'agirait que d'un détail, la fatigue, à entendre les animateurs trop nets.
Loin de rassurer, le sourire de dix-huit heures lasse.
Mado écrit la suite d'un extrait où le personnage rayonne trop pour être cru.
Aline : l'antiphrase se signale par un trop.
Félicie pose le bol sans « savoure ! ».
Lila n'ouvrira pas une émission de bonheur.
Un chiffre, une trace : Sami a compté sept soirs « heureux » ; trois bâillements cachés ; zéro droit déclaré à la fatigue.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de pouvoir être las sans être coupable
Yvette a le droit d'être lasse.
Mado entend, dans « soyez heureux », ceci qui n'est pas dit : soyez heureux arrive souvent quand on n'a plus le droit d'être las
Autrement dit, si tant est que le bonheur s'industrialise, il se vendrait déjà au Marché des Lampions
La proposition qui reste debout est celle-ci : une tribune — contre la joie obligatoire, pour les soirs sans score
Marc : prendre position, c'est refuser l'usine à joie.
Nous clôturons sans fusionner les voix : l'interview trop lisse d'un animateur inventé d'un côté, l'extrait de roman de Mado de l'autre, et le point où elles refusent de se ressembler.
Signé : Sami, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Bonheur en série'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : antiphrase ; industrialisation d'un sentiment ; prise de position.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on usine un sourire à dix-huit heures, une joie qui ressemble à un planning n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède qu'un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
Ce que l'on nomme bonheur, ici, n'est pas un slogan : sentiment, pas une consigne.
Encore que l'on refuse, une joie qui ressemble à un planning n'est pas un détail.
Sami concède qu'un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
Autrement dit, si tant est que le bonheur s'industrialise, il se vendrait déjà au Marché des Lampions
Il ressort qu'une tribune : contre la joie obligatoire, pour les soirs sans score
Loin de rassurer, le sourire de dix-huit heures lasse.
Félicie pose le bol sans « savoure ! ».
La proposition qui reste debout est celle-ci : une tribune — contre la joie obligatoire, pour les soirs sans score
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'interview trop lisse d'un animateur inventé d'un côté, l'extrait de roman de Mado de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Bonheur en série'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Sami transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Sami concède qu'un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Bonheur en série'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Prendre position sur un bonheur trop mesuré, trop vendu. Point : antiphrase ; industrialisation d'un sentiment ; prise de position.

Consigne
Imitez le texte de Sami.

Support — Sami — La joie n'est pas un planning
Sami — La joie n'est pas un planning
On parle trop vite du bonheur à l'heure dite sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on usine un sourire à dix-huit heures, une joie qui ressemble à un planning n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède qu'un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
Ce que l'on nomme bonheur, ici, n'est pas un slogan : sentiment, pas une consigne.
Sami : il ne s'agirait que d'un détail, la fatigue, à entendre les animateurs trop nets.
Félicie pose le bol sans « savoure ! ».
Lila n'ouvrira pas une émission de bonheur.
Yvette a le droit d'être lasse.
La proposition qui reste debout est celle-ci : une tribune — contre la joie obligatoire, pour les soirs sans score
Marc : prendre position, c'est refuser l'usine à joie.
Nous clôturons sans fusionner les voix : l'interview trop lisse d'un animateur inventé d'un côté, l'extrait de roman de Mado de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on refuse, une joie qui ressemble à un planning n'est pas un détail.
Sami concède qu'un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
si tant est que le bonheur s'industrialise, il se vendrait déjà au Marché des Lampions
Sami, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Bonheur en série'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Sami sur « Bonheur en série » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Sami sur « Bonheur en série » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Bonheur en série'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser antiphrase ; industrialisation d'un sentiment ; prise de position au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — antiphrase ; industrialisation d'un sentiment ; prise de position
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on refuse, une joie qui ressemble à un planning n'est pas un détail.
Sami concède qu'un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
Autrement dit, si tant est que le bonheur s'industrialise, il se vendrait déjà au Marché des Lampions
Il ressort qu'une tribune : contre la joie obligatoire, pour les soirs sans score
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme bonheur, ici, n'est pas un slogan : sentiment, pas une consigne.
Loin de rassurer, le sourire de dix-huit heures lasse.
Félicie pose le bol sans « savoure ! ».
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au fatigue pour de vrai genre, et Mado demande un registre plus net.
Correction : On va au fatigue vraiment, et Mado demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Bonheur en série'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Argumenter en faveur d'une médiation animale au Seuil, sans mièvrerie. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — La bête et le banc
Lila Sow : Radio Figuier. On parle trop vite du chien de Basile Habiyaremye, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on chasse le chien au nom de la dignité trop abstraite, un banc trop raide pour qui tremble n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Basile Habiyaremye concède qu'un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
Aline Uwase : Ce que l'on nomme médiation, ici, n'est pas un slogan : présence encadrée, distincte d'un soin miracle.
Basile : il convient que l'on autorise des heures, non un culte.
Hawa Diallo : Inès objecte le risque, et c'est une objection digne.
Joël Mugisha : Hawa a parlé au chien, puis à Inès, dans cet ordre.
Aline : encore que l'on discute le sérieux, le refus a été respecté.
Solange Mukamana : Dieudonné peut tenir la laisse.
Karim Bamba : Lila n'en fera pas une émission trop tendre.
Félicie Ndayishimiye : Un chiffre, une trace : Basile a tenu trois heures de présence ; deux personnes ont parlé ; une a refusé, et c'est noté.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une justice douce, pas d'une mascotte
Yvette : Patrick veut la responsabilité écrite.
Mado : Inès Mukama entend, dans « les bêtes n'ont pas leur place », ceci qui n'est pas dit : pas leur place veut souvent dire notre malaise d'abord
Sami : Autrement dit, fût-ce un chien trop calme, la médiation peut ouvrir une parole que le jargon ferme
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une lettre au Bureau des Escales — horaires, responsabilité, droit de dire non
Marc : une lettre de médiation n'est pas une fable.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : la lettre de Basile d'un côté, la réserve d'Inès de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : On objectera que ce n'est pas sérieux. C'est souvent ainsi que l'on nomme ce qui dérange un protocole trop sûr.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'La bête et le banc'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un banc trop raide pour qui tremble est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un banc trop raide pour qui tremble n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'La bête et le banc'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Argumenter en faveur d'une médiation animale au Seuil, sans mièvrerie. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Un chien n'est pas une mascotte », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Un chien n'est pas une mascotte
On parle trop vite du chien de Basile Habiyaremye, comme si le mot dispensait d'en examiner le prix.
Encore que l'on chasse le chien au nom de la dignité trop abstraite, un banc trop raide pour qui tremble n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Basile Habiyaremye concède qu'un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
Ce que l'on nomme médiation, ici, n'est pas un slogan : présence encadrée, distincte d'un soin miracle.
Basile : il convient que l'on autorise des heures, non un culte.
Inès objecte le risque, et c'est une objection digne.
Hawa a parlé au chien, puis à Inès, dans cet ordre.
Aline : encore que l'on discute le sérieux, le refus a été respecté.
Dieudonné peut tenir la laisse.
Lila n'en fera pas une émission trop tendre.
Un chiffre, une trace : Basile a tenu trois heures de présence ; deux personnes ont parlé ; une a refusé, et c'est noté.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une justice douce, pas d'une mascotte
Patrick veut la responsabilité écrite.
Inès Mukama entend, dans « les bêtes n'ont pas leur place », ceci qui n'est pas dit : pas leur place veut souvent dire notre malaise d'abord
Autrement dit, fût-ce un chien trop calme, la médiation peut ouvrir une parole que le jargon ferme
La proposition qui reste debout est celle-ci : une lettre au Bureau des Escales — horaires, responsabilité, droit de dire non
Marc : une lettre de médiation n'est pas une fable.
Nous clôturons sans fusionner les voix : la lettre de Basile d'un côté, la réserve d'Inès de l'autre, et le point où elles refusent de se ressembler.
Signé : Basile Habiyaremye, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'La bête et le banc'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : argumentation juridique inventée ; encore que ; fût-ce.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on chasse le chien au nom de la dignité trop abstraite, un banc trop raide pour qui tremble n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Basile Habiyaremye concède qu'un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
Ce que l'on nomme médiation, ici, n'est pas un slogan : présence encadrée, distincte d'un soin miracle.
Encore que l'on autorise, un banc trop raide pour qui tremble n'est pas un détail.
Basile Habiyaremye concède qu'un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
Autrement dit, fût-ce un chien trop calme, la médiation peut ouvrir une parole que le jargon ferme
Il ressort qu'une lettre au Bureau des Escales : horaires, responsabilité, droit de dire non
Inès objecte le risque, et c'est une objection digne.
Dieudonné peut tenir la laisse.
La proposition qui reste debout est celle-ci : une lettre au Bureau des Escales — horaires, responsabilité, droit de dire non
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : la lettre de Basile d'un côté, la réserve d'Inès de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'La bête et le banc'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Basile Habiyaremye transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Basile Habiyaremye concède qu'un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'La bête et le banc'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Argumenter en faveur d'une médiation animale au Seuil, sans mièvrerie. Point : argumentation juridique inventée ; encore que ; fût-ce.

Consigne
Imitez le texte de Basile Habiyaremye.

Support — Basile Habiyaremye — Un chien n'est pas une mascotte
Basile Habiyaremye — Un chien n'est pas une mascotte
On parle trop vite du chien de Basile Habiyaremye, comme si le mot dispensait d'en examiner le prix.
Encore que l'on chasse le chien au nom de la dignité trop abstraite, un banc trop raide pour qui tremble n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Basile Habiyaremye concède qu'un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
Ce que l'on nomme médiation, ici, n'est pas un slogan : présence encadrée, distincte d'un soin miracle.
Basile : il convient que l'on autorise des heures, non un culte.
Dieudonné peut tenir la laisse.
Lila n'en fera pas une émission trop tendre.
Patrick veut la responsabilité écrite.
La proposition qui reste debout est celle-ci : une lettre au Bureau des Escales — horaires, responsabilité, droit de dire non
Marc : une lettre de médiation n'est pas une fable.
Nous clôturons sans fusionner les voix : la lettre de Basile d'un côté, la réserve d'Inès de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on autorise, un banc trop raide pour qui tremble n'est pas un détail.
Basile Habiyaremye concède qu'un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
fût-ce un chien trop calme, la médiation peut ouvrir une parole que le jargon ferme
Basile Habiyaremye, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'La bête et le banc'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Basile Habiyaremye sur « La bête et le banc » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Basile Habiyaremye sur « La bête et le banc » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'La bête et le banc'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser argumentation juridique inventée ; encore que ; fût-ce au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — argumentation juridique inventée ; encore que ; fût-ce
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on autorise, un banc trop raide pour qui tremble n'est pas un détail.
Basile Habiyaremye concède qu'un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
Autrement dit, fût-ce un chien trop calme, la médiation peut ouvrir une parole que le jargon ferme
Il ressort qu'une lettre au Bureau des Escales : horaires, responsabilité, droit de dire non
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme médiation, ici, n'est pas un slogan : présence encadrée, distincte d'un soin miracle.
Inès objecte le risque, et c'est une objection digne.
Dieudonné peut tenir la laisse.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au refus pour de vrai genre, et Inès Mukama demande un registre plus net.
Correction : On va au refus vraiment, et Inès Mukama demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'La bête et le banc'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Comprendre les enjeux d'une utopie de rive et en décrire une, sans naïveté. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Ailleurs possibles
Lila Sow : Radio Figuier. On parle trop vite d'une utopie trop propre de Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface toute contrainte comme une honte, une liberté qui n'aurait plus de relais ni de rampe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Nina Kayitesi concède que rêver un ailleurs aide à juger l'ici, pour autant que l'on n'oublie pas qui porterait encore les lanternes.
Aline Uwase : Ce que l'on nomme utopie, ici, n'est pas un slogan : ailleurs pensé, avec contraintes avouées.
Patrick Habimana : On dirait que la rivière n'aurait plus de crue, et Joël demande qui essuierait quand même.
Nina : une utopie trop propre est une oubliette.
Joël Mugisha : Mado écrit un conte où la liberté a un relais, ou n'est pas.
Aline : le conditionnel peint, il n'absout pas.
Solange Mukamana : Sami veut trop d'air ; Yvette trop d'ombre ; le calque les tient.
Karim Bamba : Lila lira l'utopie sans musique triomphale.
Félicie Ndayishimiye : Un chiffre, une trace : Nina a dessiné zéro tour ; trois relais ; une rampe ; un chien ; pas de midi sans ombre.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de rêver sans renvoyer Joël dans l'angle mort
Yvette : Basile y met le chien, encadré.
Mado : Joël Mugisha entend, dans « demain on sera libres », ceci qui n'est pas dit : on sera libres dispense trop souvent de dire qui restera chargé
Sami : Autrement dit, une utopie se juge à ses contraintes avouées, pas à ses nuages
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : décrire une rive possible — libertés, charges, refus du trop propre
Marc : décrire une utopie, c'est avouer ses charges.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le calque utopique de Nina d'un côté, le conte philosophique de Mado de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Demain on sera libres, répète-t-on, avec cette générosité particulière qui n'a pas à porter les lanternes.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Ailleurs possibles'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une liberté qui n'aurait plus de relais ni de rampe est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une liberté qui n'aurait plus de relais ni de rampe n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Ailleurs possibles'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comprendre les enjeux d'une utopie de rive et en décrire une, sans naïveté. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « L'utopie avoue ses charges », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — L'utopie avoue ses charges
On parle trop vite d'une utopie trop propre de Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface toute contrainte comme une honte, une liberté qui n'aurait plus de relais ni de rampe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que rêver un ailleurs aide à juger l'ici, pour autant que l'on n'oublie pas qui porterait encore les lanternes.
Ce que l'on nomme utopie, ici, n'est pas un slogan : ailleurs pensé, avec contraintes avouées.
On dirait que la rivière n'aurait plus de crue, et Joël demande qui essuierait quand même.
Nina : une utopie trop propre est une oubliette.
Mado écrit un conte où la liberté a un relais, ou n'est pas.
Aline : le conditionnel peint, il n'absout pas.
Sami veut trop d'air ; Yvette trop d'ombre ; le calque les tient.
Lila lira l'utopie sans musique triomphale.
Un chiffre, une trace : Nina a dessiné zéro tour ; trois relais ; une rampe ; un chien ; pas de midi sans ombre.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de rêver sans renvoyer Joël dans l'angle mort
Basile y met le chien, encadré.
Joël Mugisha entend, dans « demain on sera libres », ceci qui n'est pas dit : on sera libres dispense trop souvent de dire qui restera chargé
Autrement dit, une utopie se juge à ses contraintes avouées, pas à ses nuages
La proposition qui reste debout est celle-ci : décrire une rive possible — libertés, charges, refus du trop propre
Marc : décrire une utopie, c'est avouer ses charges.
Nous clôturons sans fusionner les voix : le calque utopique de Nina d'un côté, le conte philosophique de Mado de l'autre, et le point où elles refusent de se ressembler.
Signé : Nina Kayitesi, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Ailleurs possibles'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : utopie / contrainte ; conditionnel ; rêve et réalité.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on efface toute contrainte comme une honte, une liberté qui n'aurait plus de relais ni de rampe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que rêver un ailleurs aide à juger l'ici, pour autant que l'on n'oublie pas qui porterait encore les lanternes.
Ce que l'on nomme utopie, ici, n'est pas un slogan : ailleurs pensé, avec contraintes avouées.
Encore que l'on rêve, une liberté qui n'aurait plus de relais ni de rampe n'est pas un détail.
Nina Kayitesi concède que rêver un ailleurs aide à juger l'ici, pour autant que l'on n'oublie pas qui porterait encore les lanternes.
Autrement dit, une utopie se juge à ses contraintes avouées, pas à ses nuages
Il ressort que décrire une rive possible : libertés, charges, refus du trop propre
Nina : une utopie trop propre est une oubliette.
Sami veut trop d'air ; Yvette trop d'ombre ; le calque les tient.
La proposition qui reste debout est celle-ci : décrire une rive possible — libertés, charges, refus du trop propre
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le calque utopique de Nina d'un côté, le conte philosophique de Mado de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Ailleurs possibles'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Comprendre les enjeux d'une utopie de rive et en décrire une, sans naïveté. Point : utopie / contrainte ; conditionnel ; rêve et réalité.

Consigne
Imitez le texte de Nina Kayitesi.

Support — Nina Kayitesi — L'utopie avoue ses charges
Nina Kayitesi — L'utopie avoue ses charges
On parle trop vite d'une utopie trop propre de Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface toute contrainte comme une honte, une liberté qui n'aurait plus de relais ni de rampe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que rêver un ailleurs aide à juger l'ici, pour autant que l'on n'oublie pas qui porterait encore les lanternes.
Ce que l'on nomme utopie, ici, n'est pas un slogan : ailleurs pensé, avec contraintes avouées.
On dirait que la rivière n'aurait plus de crue, et Joël demande qui essuierait quand même.
Sami veut trop d'air ; Yvette trop d'ombre ; le calque les tient.
Lila lira l'utopie sans musique triomphale.
Basile y met le chien, encadré.
La proposition qui reste debout est celle-ci : décrire une rive possible — libertés, charges, refus du trop propre
Marc : décrire une utopie, c'est avouer ses charges.
Nous clôturons sans fusionner les voix : le calque utopique de Nina d'un côté, le conte philosophique de Mado de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on rêve, une liberté qui n'aurait plus de relais ni de rampe n'est pas un détail.
Nina Kayitesi concède que rêver un ailleurs aide à juger l'ici, pour autant que l'on n'oublie pas qui porterait encore les lanternes.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
une utopie se juge à ses contraintes avouées, pas à ses nuages
Nina Kayitesi, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Ailleurs possibles'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Nina Kayitesi sur « Ailleurs possibles » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Nina Kayitesi sur « Ailleurs possibles » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Ailleurs possibles'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Rédiger une lettre de médiation claire, relisible, sans mièvrerie. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Lettre pour Basile
Lila Sow : Radio Figuier. On parle trop vite de la lettre au Bureau des Escales, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace le droit par l'émotion, une lettre trop tendre pour être opposable n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Inès Mukama concède que le ton peut rester humain, pour autant que l'on y trouve horaires, responsabilités, droit de refus.
Aline Uwase : Ce que l'on nomme cadre, ici, n'est pas un slogan : règles écrites de la médiation.
Inès : il convient que l'on date, encore que le ton reste humain.
Hawa Diallo : Basile accepte le refus noté.
Joël Mugisha : Aline allonge une phrase pour tenir concession et demande.
Rose Iradukunda : Karim veut un responsable nommé.
Solange Mukamana : Lila ne lira pas la lettre à l'antenne sans accord.
Karim Bamba : Dieudonné peut tenir la laisse aux heures dites.
Félicie Ndayishimiye : Un chiffre, une trace : Inès a raturé suivez votre cœur ; gardé le refus ; daté le jeudi.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit qu'une lettre puisse se relire en cas de malentendu
Yvette : Patrick relit l'hypotaxe.
Mado : Basile Habiyaremye entend, dans « suivez votre cœur », ceci qui n'est pas dit : suivez votre cœur évite d'écrire qui répond du chien s'il gronde
Sami : Autrement dit, une lettre de C2 tient l'hypotaxe et le concret : fût-ce pour un chien
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : trois paragraphes — constat, cadre, demande datée
Marc : une lettre formelle n'est pas une froideur, c'est une hospitalité faite au malentendu futur.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le brouillon trop tendre d'un côté, la lettre retenue de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Le cœur, en ces matières, a cet avantage : on ne peut pas le citer dans un compte-rendu.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Lettre pour Basile'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une lettre trop tendre pour être opposable est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une lettre trop tendre pour être opposable n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Lettre pour Basile'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Reformulez l'implicite de « suivez votre cœur » et la concession d'Inès Mukama."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Lettre pour Basile'
  AND l.competency = 'CO'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rédiger une lettre de médiation claire, relisible, sans mièvrerie. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Opposable, pas trop tendre », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Opposable, pas trop tendre
On parle trop vite de la lettre au Bureau des Escales, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le droit par l'émotion, une lettre trop tendre pour être opposable n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède que le ton peut rester humain, pour autant que l'on y trouve horaires, responsabilités, droit de refus.
Ce que l'on nomme cadre, ici, n'est pas un slogan : règles écrites de la médiation.
Inès : il convient que l'on date, encore que le ton reste humain.
Basile accepte le refus noté.
Aline allonge une phrase pour tenir concession et demande.
Karim veut un responsable nommé.
Lila ne lira pas la lettre à l'antenne sans accord.
Dieudonné peut tenir la laisse aux heures dites.
Un chiffre, une trace : Inès a raturé suivez votre cœur ; gardé le refus ; daté le jeudi.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit qu'une lettre puisse se relire en cas de malentendu
Patrick relit l'hypotaxe.
Basile Habiyaremye entend, dans « suivez votre cœur », ceci qui n'est pas dit : suivez votre cœur évite d'écrire qui répond du chien s'il gronde
Autrement dit, une lettre de C2 tient l'hypotaxe et le concret : fût-ce pour un chien
La proposition qui reste debout est celle-ci : trois paragraphes — constat, cadre, demande datée
Marc : une lettre formelle n'est pas une froideur, c'est une hospitalité faite au malentendu futur.
Nous clôturons sans fusionner les voix : le brouillon trop tendre d'un côté, la lettre retenue de l'autre, et le point où elles refusent de se ressembler.
Signé : Inès Mukama, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Lettre pour Basile'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : lettre formelle ; concession ; hypotaxe longue.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace le droit par l'émotion, une lettre trop tendre pour être opposable n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède que le ton peut rester humain, pour autant que l'on y trouve horaires, responsabilités, droit de refus.
Ce que l'on nomme cadre, ici, n'est pas un slogan : règles écrites de la médiation.
Encore que l'on date, une lettre trop tendre pour être opposable n'est pas un détail.
Inès Mukama concède que le ton peut rester humain, pour autant que l'on y trouve horaires, responsabilités, droit de refus.
Autrement dit, une lettre de C2 tient l'hypotaxe et le concret : fût-ce pour un chien
Il ressort que trois paragraphes : constat, cadre, demande datée
Basile accepte le refus noté.
Lila ne lira pas la lettre à l'antenne sans accord.
La proposition qui reste debout est celle-ci : trois paragraphes — constat, cadre, demande datée
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le brouillon trop tendre d'un côté, la lettre retenue de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Lettre pour Basile'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Rédiger une lettre de médiation claire, relisible, sans mièvrerie. Point : lettre formelle ; concession ; hypotaxe longue.

Consigne
Imitez le texte d'Inès Mukama.

Support — Inès Mukama — Opposable, pas trop tendre
Inès Mukama — Opposable, pas trop tendre
On parle trop vite de la lettre au Bureau des Escales, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le droit par l'émotion, une lettre trop tendre pour être opposable n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède que le ton peut rester humain, pour autant que l'on y trouve horaires, responsabilités, droit de refus.
Ce que l'on nomme cadre, ici, n'est pas un slogan : règles écrites de la médiation.
Inès : il convient que l'on date, encore que le ton reste humain.
Lila ne lira pas la lettre à l'antenne sans accord.
Dieudonné peut tenir la laisse aux heures dites.
Patrick relit l'hypotaxe.
La proposition qui reste debout est celle-ci : trois paragraphes — constat, cadre, demande datée
Marc : une lettre formelle n'est pas une froideur, c'est une hospitalité faite au malentendu futur.
Nous clôturons sans fusionner les voix : le brouillon trop tendre d'un côté, la lettre retenue de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on date, une lettre trop tendre pour être opposable n'est pas un détail.
Inès Mukama concède que le ton peut rester humain, pour autant que l'on y trouve horaires, responsabilités, droit de refus.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
une lettre de C2 tient l'hypotaxe et le concret : fût-ce pour un chien
Inès Mukama, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Lettre pour Basile'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos d'Inès Mukama sur « Lettre pour Basile » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos d'Inès Mukama sur « Lettre pour Basile » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Lettre pour Basile'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Imitez le texte d'Inès Mukama : vingt lignes, deux voix, une concession, une proposition."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Lettre pour Basile'
  AND l.competency = 'PE'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Décrire une utopie personnelle ancrée à Rukiri-Nord, C2, sans carte postale. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Une utopie de rive
Lila Sow : Radio Figuier. On parle trop vite de la rive que l'on ose encore rêver, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on gommenait Joël, la rampe, la crue, une perfection qui n'a plus besoin de personne n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que le rêve a le droit d'être beau, pour autant que l'on y laisse sale un peu de terre sous l'ongle.
Aline Uwase : Ce que l'on nomme rive, ici, n'est pas un slogan : bord d'eau et de travail.
Mado : on dirait que la crue viendrait encore, et que l'on saurait ensemble.
Hawa Diallo : Nina refuse le trop propre.
Joël Mugisha : Joël apparaît au troisième paragraphe, pas en note.
Aline : le conditionnel ici est une éthique.
Solange Mukamana : Sami veut trop d'air ; on lui laisse, avec un relais.
Karim Bamba : Lila lira sans triomphe.
Félicie Ndayishimiye : Un chiffre, une trace : Mado a laissé la terre ; Nina la rampe ; Joël un relais ; zéro monde parfait.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de rêver une cour, pas une vitrine
Yvette : Félicie glisse un bol.
Mado : Nina Kayitesi entend, dans « un monde parfait », ceci qui n'est pas dit : parfait veut souvent dire sans visages trop réels
Sami : Autrement dit, on dirait une rive où l'on porterait encore, mais à plusieurs, et midi aurait une ombre
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : deux pages — ailleurs, charges, une ironie contre le trop propre
Marc : une utopie de rive se juge à ses ongles.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'utopie de Mado d'un côté, les ratures de Nina de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Un monde parfait, au Seuil, aurait cet inconvénient majeur : on n'y verrait plus qui essuie.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Une utopie de rive'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une perfection qui n'a plus besoin de personne est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une perfection qui n'a plus besoin de personne n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Une utopie de rive'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Décrire une utopie personnelle ancrée à Rukiri-Nord, C2, sans carte postale. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Un peu de terre sous l'ongle », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Un peu de terre sous l'ongle
On parle trop vite de la rive que l'on ose encore rêver, comme si le mot dispensait d'en examiner le prix.
Encore que l'on gommenait Joël, la rampe, la crue, une perfection qui n'a plus besoin de personne n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que le rêve a le droit d'être beau, pour autant que l'on y laisse sale un peu de terre sous l'ongle.
Ce que l'on nomme rive, ici, n'est pas un slogan : bord d'eau et de travail.
Mado : on dirait que la crue viendrait encore, et que l'on saurait ensemble.
Nina refuse le trop propre.
Joël apparaît au troisième paragraphe, pas en note.
Aline : le conditionnel ici est une éthique.
Sami veut trop d'air ; on lui laisse, avec un relais.
Lila lira sans triomphe.
Un chiffre, une trace : Mado a laissé la terre ; Nina la rampe ; Joël un relais ; zéro monde parfait.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de rêver une cour, pas une vitrine
Félicie glisse un bol.
Nina Kayitesi entend, dans « un monde parfait », ceci qui n'est pas dit : parfait veut souvent dire sans visages trop réels
Autrement dit, on dirait une rive où l'on porterait encore, mais à plusieurs, et midi aurait une ombre
La proposition qui reste debout est celle-ci : deux pages — ailleurs, charges, une ironie contre le trop propre
Marc : une utopie de rive se juge à ses ongles.
Nous clôturons sans fusionner les voix : l'utopie de Mado d'un côté, les ratures de Nina de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Une utopie de rive'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : écriture d'utopie ; charges avouées ; ironie douce.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on gommenait Joël, la rampe, la crue, une perfection qui n'a plus besoin de personne n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que le rêve a le droit d'être beau, pour autant que l'on y laisse sale un peu de terre sous l'ongle.
Ce que l'on nomme rive, ici, n'est pas un slogan : bord d'eau et de travail.
Encore que l'on salisse, une perfection qui n'a plus besoin de personne n'est pas un détail.
Mado concède que le rêve a le droit d'être beau, pour autant que l'on y laisse sale un peu de terre sous l'ongle.
Autrement dit, on dirait une rive où l'on porterait encore, mais à plusieurs, et midi aurait une ombre
Il ressort que deux pages : ailleurs, charges, une ironie contre le trop propre
Nina refuse le trop propre.
Sami veut trop d'air ; on lui laisse, avec un relais.
La proposition qui reste debout est celle-ci : deux pages — ailleurs, charges, une ironie contre le trop propre
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'utopie de Mado d'un côté, les ratures de Nina de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Une utopie de rive'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Décrire une utopie personnelle ancrée à Rukiri-Nord, C2, sans carte postale. Point : écriture d'utopie ; charges avouées ; ironie douce.

Consigne
Imitez le texte de Mado.

Support — Mado — Un peu de terre sous l'ongle
Mado — Un peu de terre sous l'ongle
On parle trop vite de la rive que l'on ose encore rêver, comme si le mot dispensait d'en examiner le prix.
Encore que l'on gommenait Joël, la rampe, la crue, une perfection qui n'a plus besoin de personne n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que le rêve a le droit d'être beau, pour autant que l'on y laisse sale un peu de terre sous l'ongle.
Ce que l'on nomme rive, ici, n'est pas un slogan : bord d'eau et de travail.
Mado : on dirait que la crue viendrait encore, et que l'on saurait ensemble.
Sami veut trop d'air ; on lui laisse, avec un relais.
Lila lira sans triomphe.
Félicie glisse un bol.
La proposition qui reste debout est celle-ci : deux pages — ailleurs, charges, une ironie contre le trop propre
Marc : une utopie de rive se juge à ses ongles.
Nous clôturons sans fusionner les voix : l'utopie de Mado d'un côté, les ratures de Nina de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on salisse, une perfection qui n'a plus besoin de personne n'est pas un détail.
Mado concède que le rêve a le droit d'être beau, pour autant que l'on y laisse sale un peu de terre sous l'ongle.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
on dirait une rive où l'on porterait encore, mais à plusieurs, et midi aurait une ombre
Mado, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Une utopie de rive'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Mado sur « Une utopie de rive » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Mado sur « Une utopie de rive » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Bonheurs et utopies'
  AND s.title = 'Une utopie de rive'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;

-- C2 — Parler nos français
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Réagir aux emprunts et définir notre représentation du français au Seuil. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Mots voyageurs
Lila Sow : Radio Figuier. On parle trop vite des mots voyageurs sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on chasse les emprunts comme une honte, une pureté qui n'a jamais existé sur la pente n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches.
Aline Uwase : Ce que l'on nomme emprunt, ici, n'est pas un slogan : mot venu d'ailleurs, parfois utile.
Karim : encore que certains mots fatiguent, la chasse fatigue davantage.
Hawa Diallo : Aline distingue registre et police.
Joël Mugisha : Hawa emprunte, traduit, n'a pas à s'excuser.
Rose Iradukunda : Rose coud un mot d'ailleurs sur un lin d'ici.
Solange Mukamana : Lila tend le micro aux bouches réelles.
Karim Bamba : Sami joue avec un emprunt ; Yvette sourit.
Félicie Ndayishimiye : Un chiffre, une trace : Karim a listé huit emprunts utiles ; trois vaniteux ; zéro chasse aux bouches.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de parler juste, pas de parler « propre »
Yvette : Patrick refuse la boutique du pur.
Mado : Aline Uwase entend, dans « il faut parler pur », ceci qui n'est pas dit : parler pur veut souvent dire parler comme ceux qui n'ont pas eu à emprunter pour vivre
Sami : Autrement dit, une langue se décrit par ses voyages, pas par une vitrine trop nette
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un article — ce que nous empruntons, ce que nous refusons, sans tribunal
Marc : décrire une langue, c'est raconter ses voyages.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'émission trop sévère d'un côté, l'article de Karim de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Il faut parler pur, répète-t-on, avec cette innocence des vitrines qui n'ont jamais eu à négocier un prix.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Mots voyageurs'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une pureté qui n'a jamais existé sur la pente est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une pureté qui n'a jamais existé sur la pente n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Mots voyageurs'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Réagir aux emprunts et définir notre représentation du français au Seuil. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Pas de police des bouches », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Pas de police des bouches
On parle trop vite des mots voyageurs sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on chasse les emprunts comme une honte, une pureté qui n'a jamais existé sur la pente n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches.
Ce que l'on nomme emprunt, ici, n'est pas un slogan : mot venu d'ailleurs, parfois utile.
Karim : encore que certains mots fatiguent, la chasse fatigue davantage.
Aline distingue registre et police.
Hawa emprunte, traduit, n'a pas à s'excuser.
Rose coud un mot d'ailleurs sur un lin d'ici.
Lila tend le micro aux bouches réelles.
Sami joue avec un emprunt ; Yvette sourit.
Un chiffre, une trace : Karim a listé huit emprunts utiles ; trois vaniteux ; zéro chasse aux bouches.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de parler juste, pas de parler « propre »
Patrick refuse la boutique du pur.
Aline Uwase entend, dans « il faut parler pur », ceci qui n'est pas dit : parler pur veut souvent dire parler comme ceux qui n'ont pas eu à emprunter pour vivre
Autrement dit, une langue se décrit par ses voyages, pas par une vitrine trop nette
La proposition qui reste debout est celle-ci : un article — ce que nous empruntons, ce que nous refusons, sans tribunal
Marc : décrire une langue, c'est raconter ses voyages.
Nous clôturons sans fusionner les voix : l'émission trop sévère d'un côté, l'article de Karim de l'autre, et le point où elles refusent de se ressembler.
Signé : Karim Bamba, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Mots voyageurs'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : emprunts ; représentation d'une langue ; sans purisme de boutique.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on chasse les emprunts comme une honte, une pureté qui n'a jamais existé sur la pente n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches.
Ce que l'on nomme emprunt, ici, n'est pas un slogan : mot venu d'ailleurs, parfois utile.
Encore que l'on emprunte, une pureté qui n'a jamais existé sur la pente n'est pas un détail.
Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches.
Autrement dit, une langue se décrit par ses voyages, pas par une vitrine trop nette
Il ressort qu'un article : ce que nous empruntons, ce que nous refusons, sans tribunal
Aline distingue registre et police.
Lila tend le micro aux bouches réelles.
La proposition qui reste debout est celle-ci : un article — ce que nous empruntons, ce que nous refusons, sans tribunal
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'émission trop sévère d'un côté, l'article de Karim de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Mots voyageurs'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Réagir aux emprunts et définir notre représentation du français au Seuil. Point : emprunts ; représentation d'une langue ; sans purisme de boutique.

Consigne
Imitez le texte de Karim Bamba.

Support — Karim Bamba — Pas de police des bouches
Karim Bamba — Pas de police des bouches
On parle trop vite des mots voyageurs sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on chasse les emprunts comme une honte, une pureté qui n'a jamais existé sur la pente n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches.
Ce que l'on nomme emprunt, ici, n'est pas un slogan : mot venu d'ailleurs, parfois utile.
Karim : encore que certains mots fatiguent, la chasse fatigue davantage.
Lila tend le micro aux bouches réelles.
Sami joue avec un emprunt ; Yvette sourit.
Patrick refuse la boutique du pur.
La proposition qui reste debout est celle-ci : un article — ce que nous empruntons, ce que nous refusons, sans tribunal
Marc : décrire une langue, c'est raconter ses voyages.
Nous clôturons sans fusionner les voix : l'émission trop sévère d'un côté, l'article de Karim de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on emprunte, une pureté qui n'a jamais existé sur la pente n'est pas un détail.
Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
une langue se décrit par ses voyages, pas par une vitrine trop nette
Karim Bamba, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Mots voyageurs'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Karim Bamba sur « Mots voyageurs » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Karim Bamba sur « Mots voyageurs » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Mots voyageurs'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Analyser et écrire une lettre ouverte sur les voix de la cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Politiques des voix
Lila Sow : Radio Figuier. On parle trop vite de qui a droit au micro de Radio Figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on réduit les voix à un usage trop étroit, un micro qui n'ouvre qu'à une musique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Lila Sow concède qu'un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Aline Uwase : Ce que l'on nomme politique, ici, n'est pas un slogan : choix collectif sur les voix.
Lila : il convient que l'on ouvre, encore que l'on traduise.
Hawa Diallo : Aline refuse l'effacement poli.
Joël Mugisha : Hawa écrit une phrase de la lettre en deux souffles.
Rose Iradukunda : Karim veut être compris, pas réduit.
Solange Mukamana : Solange signe.
Karim Bamba : Patrick relit le ton.
Félicie Ndayishimiye : Un chiffre, une trace : Lila a ouvert trois heures mixtes ; deux refus poliment notés ; une lettre signée par onze voix.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de politiques de cour, pas d'un État fantasmé
Yvette : Sami lit trop vite ; on le ralentit.
Mado : Aline Uwase entend, dans « une seule langue officielle de cour », ceci qui n'est pas dit : une seule langue officielle veut souvent dire une seule oreille légitime
Sami : Autrement dit, il convient que l'on ouvre le micro, encore que l'assemblée ait besoin d'un usage commun
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une lettre ouverte — heures, langues, droit d'être compris sans être effacé
Marc : une lettre ouverte nomme le micro, pas un empire.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le projet trop étroit d'un côté, la lettre ouverte de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Une seule langue officielle de cour : formule propre, comme le sont souvent les exclusions.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Politiques des voix'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un micro qui n'ouvre qu'à une musique est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un micro qui n'ouvre qu'à une musique n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Politiques des voix'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Analyser et écrire une lettre ouverte sur les voix de la cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Plus d'une oreille », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Plus d'une oreille
On parle trop vite de qui a droit au micro de Radio Figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduit les voix à un usage trop étroit, un micro qui n'ouvre qu'à une musique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède qu'un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Ce que l'on nomme politique, ici, n'est pas un slogan : choix collectif sur les voix.
Lila : il convient que l'on ouvre, encore que l'on traduise.
Aline refuse l'effacement poli.
Hawa écrit une phrase de la lettre en deux souffles.
Karim veut être compris, pas réduit.
Solange signe.
Patrick relit le ton.
Un chiffre, une trace : Lila a ouvert trois heures mixtes ; deux refus poliment notés ; une lettre signée par onze voix.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de politiques de cour, pas d'un État fantasmé
Sami lit trop vite ; on le ralentit.
Aline Uwase entend, dans « une seule langue officielle de cour », ceci qui n'est pas dit : une seule langue officielle veut souvent dire une seule oreille légitime
Autrement dit, il convient que l'on ouvre le micro, encore que l'assemblée ait besoin d'un usage commun
La proposition qui reste debout est celle-ci : une lettre ouverte — heures, langues, droit d'être compris sans être effacé
Marc : une lettre ouverte nomme le micro, pas un empire.
Nous clôturons sans fusionner les voix : le projet trop étroit d'un côté, la lettre ouverte de l'autre, et le point où elles refusent de se ressembler.
Signé : Lila Sow, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Politiques des voix'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : lettre ouverte ; politiques linguistiques inventées ; francophonies.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on réduit les voix à un usage trop étroit, un micro qui n'ouvre qu'à une musique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède qu'un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Ce que l'on nomme politique, ici, n'est pas un slogan : choix collectif sur les voix.
Encore que l'on ouvre, un micro qui n'ouvre qu'à une musique n'est pas un détail.
Lila Sow concède qu'un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Autrement dit, il convient que l'on ouvre le micro, encore que l'assemblée ait besoin d'un usage commun
Il ressort qu'une lettre ouverte : heures, langues, droit d'être compris sans être effacé
Aline refuse l'effacement poli.
Solange signe.
La proposition qui reste debout est celle-ci : une lettre ouverte — heures, langues, droit d'être compris sans être effacé
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le projet trop étroit d'un côté, la lettre ouverte de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Politiques des voix'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Lila Sow transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Lila Sow concède qu'un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Politiques des voix'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Analyser et écrire une lettre ouverte sur les voix de la cour. Point : lettre ouverte ; politiques linguistiques inventées ; francophonies.

Consigne
Imitez le texte de Lila Sow.

Support — Lila Sow — Plus d'une oreille
Lila Sow — Plus d'une oreille
On parle trop vite de qui a droit au micro de Radio Figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduit les voix à un usage trop étroit, un micro qui n'ouvre qu'à une musique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède qu'un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Ce que l'on nomme politique, ici, n'est pas un slogan : choix collectif sur les voix.
Lila : il convient que l'on ouvre, encore que l'on traduise.
Solange signe.
Patrick relit le ton.
Sami lit trop vite ; on le ralentit.
La proposition qui reste debout est celle-ci : une lettre ouverte — heures, langues, droit d'être compris sans être effacé
Marc : une lettre ouverte nomme le micro, pas un empire.
Nous clôturons sans fusionner les voix : le projet trop étroit d'un côté, la lettre ouverte de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on ouvre, un micro qui n'ouvre qu'à une musique n'est pas un détail.
Lila Sow concède qu'un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il convient que l'on ouvre le micro, encore que l'assemblée ait besoin d'un usage commun
Lila Sow, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Politiques des voix'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Lila Sow sur « Politiques des voix » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Lila Sow sur « Politiques des voix » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Politiques des voix'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser lettre ouverte ; politiques linguistiques inventées ; francophonies au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — lettre ouverte ; politiques linguistiques inventées ; francophonies
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on ouvre, un micro qui n'ouvre qu'à une musique n'est pas un détail.
Lila Sow concède qu'un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Autrement dit, il convient que l'on ouvre le micro, encore que l'assemblée ait besoin d'un usage commun
Il ressort qu'une lettre ouverte : heures, langues, droit d'être compris sans être effacé
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme politique, ici, n'est pas un slogan : choix collectif sur les voix.
Aline refuse l'effacement poli.
Solange signe.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au usage pour de vrai genre, et Aline Uwase demande un registre plus net.
Correction : On va au usage vraiment, et Aline Uwase demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Politiques des voix'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Comparer deux extraits de Mado et commenter les choix d'écriture. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Deux extraits deux oreilles
Lila Sow : Radio Figuier. On parle trop vite de deux extraits trop éloignés pour n'être pas une politique, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on écrase l'hypotaxe au nom du peuple, un simple qui n'est que du mépris déguisé n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent.
Aline Uwase : Ce que l'on nomme extrait, ici, n'est pas un slogan : morceau comparé, avec un rythme.
Mado : loin de s'opposer, les deux extraits se jugent à ce qu'ils excluent.
Hawa Diallo : Aline commente dont et auquel dans le noué.
Joël Mugisha : Sami aime la coupe.
Rose Iradukunda : Yvette la noue.
Solange Mukamana : Lila lira les deux, lentement.
Karim Bamba : Karim refuse le mot peuple collé.
Félicie Ndayishimiye : Un chiffre, une trace : Mado a posé deux pages ; Aline a noté six relatives ; Sami a préféré la courte, Yvette la nouée.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de voir le registre comme un choix, pas comme une nature
Patrick : un choix d'écriture est une politique de l'oreille.
Mado : Aline Uwase entend, dans « il faut écrire simple », ceci qui n'est pas dit : écrire simple veut parfois dire n'embêtez pas ceux qui pourraient comprendre plus loin
Sami : Autrement dit, deux extraits : l'un coupe court, l'autre noue ; ni l'un ni l'autre n'est le peuple
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un commentaire — destinataires, rythme, ce que chaque choix exclut
Marc : commenter, c'est dire pour qui l'on coupe, pour qui l'on noue.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'extrait court d'un côté, l'extrait noué de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Il faut écrire simple, dit-on, souvent de très loin des bouches que l'on prétend servir.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Deux extraits deux oreilles'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un simple qui n'est que du mépris déguisé est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un simple qui n'est que du mépris déguisé n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Deux extraits deux oreilles'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comparer deux extraits de Mado et commenter les choix d'écriture. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Ni l'un ni l'autre n'est le peuple », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Ni l'un ni l'autre n'est le peuple
On parle trop vite de deux extraits trop éloignés pour n'être pas une politique, comme si le mot dispensait d'en examiner le prix.
Encore que l'on écrase l'hypotaxe au nom du peuple, un simple qui n'est que du mépris déguisé n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent.
Ce que l'on nomme extrait, ici, n'est pas un slogan : morceau comparé, avec un rythme.
Mado : loin de s'opposer, les deux extraits se jugent à ce qu'ils excluent.
Aline commente dont et auquel dans le noué.
Sami aime la coupe.
Yvette la noue.
Lila lira les deux, lentement.
Karim refuse le mot peuple collé.
Un chiffre, une trace : Mado a posé deux pages ; Aline a noté six relatives ; Sami a préféré la courte, Yvette la nouée.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de voir le registre comme un choix, pas comme une nature
Patrick : un choix d'écriture est une politique de l'oreille.
Aline Uwase entend, dans « il faut écrire simple », ceci qui n'est pas dit : écrire simple veut parfois dire n'embêtez pas ceux qui pourraient comprendre plus loin
Autrement dit, deux extraits : l'un coupe court, l'autre noue ; ni l'un ni l'autre n'est le peuple
La proposition qui reste debout est celle-ci : un commentaire — destinataires, rythme, ce que chaque choix exclut
Marc : commenter, c'est dire pour qui l'on coupe, pour qui l'on noue.
Nous clôturons sans fusionner les voix : l'extrait court d'un côté, l'extrait noué de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Deux extraits deux oreilles'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : registres sociaux ; comparer deux extraits ; choix d'écriture.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on écrase l'hypotaxe au nom du peuple, un simple qui n'est que du mépris déguisé n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent.
Ce que l'on nomme extrait, ici, n'est pas un slogan : morceau comparé, avec un rythme.
Encore que l'on compare, un simple qui n'est que du mépris déguisé n'est pas un détail.
Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent.
Autrement dit, deux extraits : l'un coupe court, l'autre noue ; ni l'un ni l'autre n'est le peuple
Il ressort qu'un commentaire : destinataires, rythme, ce que chaque choix exclut
Aline commente dont et auquel dans le noué.
Lila lira les deux, lentement.
La proposition qui reste debout est celle-ci : un commentaire — destinataires, rythme, ce que chaque choix exclut
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'extrait court d'un côté, l'extrait noué de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Deux extraits deux oreilles'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Comparer deux extraits de Mado et commenter les choix d'écriture. Point : registres sociaux ; comparer deux extraits ; choix d'écriture.

Consigne
Imitez le texte de Mado.

Support — Mado — Ni l'un ni l'autre n'est le peuple
Mado — Ni l'un ni l'autre n'est le peuple
On parle trop vite de deux extraits trop éloignés pour n'être pas une politique, comme si le mot dispensait d'en examiner le prix.
Encore que l'on écrase l'hypotaxe au nom du peuple, un simple qui n'est que du mépris déguisé n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent.
Ce que l'on nomme extrait, ici, n'est pas un slogan : morceau comparé, avec un rythme.
Mado : loin de s'opposer, les deux extraits se jugent à ce qu'ils excluent.
Lila lira les deux, lentement.
Karim refuse le mot peuple collé.
Patrick : un choix d'écriture est une politique de l'oreille.
La proposition qui reste debout est celle-ci : un commentaire — destinataires, rythme, ce que chaque choix exclut
Marc : commenter, c'est dire pour qui l'on coupe, pour qui l'on noue.
Nous clôturons sans fusionner les voix : l'extrait court d'un côté, l'extrait noué de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on compare, un simple qui n'est que du mépris déguisé n'est pas un détail.
Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
deux extraits : l'un coupe court, l'autre noue ; ni l'un ni l'autre n'est le peuple
Mado, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Deux extraits deux oreilles'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Mado sur « Deux extraits deux oreilles » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Mado sur « Deux extraits deux oreilles » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Deux extraits deux oreilles'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Parler de notre rapport à l'oral et préparer un discours d'éloquence de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le souffle sous le figuier
Lila Sow : Radio Figuier. On parle trop vite du concours d'éloquence sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace l'argument par le souffle trop sûr, une éloquence qui n'écoute plus n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire.
Aline Uwase : Ce que l'on nomme éloquence, ici, n'est pas un slogan : art de dire, avec un plan.
Aline : il convient que l'on convainque, encore que l'on respire.
Hawa Diallo : Léa pose la concession avant le geste.
Joël Mugisha : Sami a trop de souffle, pas assez de selon.
Rose Iradukunda : Yvette parle bas, et l'on entend.
Solange Mukamana : Lila tend le micro sans le pousser.
Karim Bamba : Patrick refuse le ventre comme méthode.
Félicie Ndayishimiye : Un chiffre, une trace : Aline a chronométré quatre minutes ; un silence ; zéro ventre sans plan.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de convaincre une cour, pas de la submerger
Yvette : Rose écoute les mains de l'orateur.
Mado : Lila Sow entend, dans « parlez avec le ventre », ceci qui n'est pas dit : parlez avec le ventre dispense trop souvent d'avoir un plan
Sami : Autrement dit, l'art oratoire au Seuil, c'est un plan, un souffle, un silence, un destinataire
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un discours de quatre minutes — thèse, concession, implicite, geste
Marc : un concours d'éloquence au Seuil se juge à ce qu'il n'a pas écrasé.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'essai d'Aline sur l'oral d'un côté, le discours de Léa de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Parlez avec le ventre : conseil généreux, surtout quand le ventre n'a pas eu à lire le dossier.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Le souffle sous le figuier'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une éloquence qui n'écoute plus est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une éloquence qui n'écoute plus n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Le souffle sous le figuier'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Reformulez l'implicite de « parlez avec le ventre » et la concession d'Aline Uwase."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Le souffle sous le figuier'
  AND l.competency = 'CO'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Parler de notre rapport à l'oral et préparer un discours d'éloquence de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Un plan, puis le souffle », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Un plan, puis le souffle
On parle trop vite du concours d'éloquence sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'argument par le souffle trop sûr, une éloquence qui n'écoute plus n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire.
Ce que l'on nomme éloquence, ici, n'est pas un slogan : art de dire, avec un plan.
Aline : il convient que l'on convainque, encore que l'on respire.
Léa pose la concession avant le geste.
Sami a trop de souffle, pas assez de selon.
Yvette parle bas, et l'on entend.
Lila tend le micro sans le pousser.
Patrick refuse le ventre comme méthode.
Un chiffre, une trace : Aline a chronométré quatre minutes ; un silence ; zéro ventre sans plan.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de convaincre une cour, pas de la submerger
Rose écoute les mains de l'orateur.
Lila Sow entend, dans « parlez avec le ventre », ceci qui n'est pas dit : parlez avec le ventre dispense trop souvent d'avoir un plan
Autrement dit, l'art oratoire au Seuil, c'est un plan, un souffle, un silence, un destinataire
La proposition qui reste debout est celle-ci : un discours de quatre minutes — thèse, concession, implicite, geste
Marc : un concours d'éloquence au Seuil se juge à ce qu'il n'a pas écrasé.
Nous clôturons sans fusionner les voix : l'essai d'Aline sur l'oral d'un côté, le discours de Léa de l'autre, et le point où elles refusent de se ressembler.
Signé : Aline Uwase, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Le souffle sous le figuier'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : art oratoire ; rapport à l'oral ; souffle et hypotaxe.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace l'argument par le souffle trop sûr, une éloquence qui n'écoute plus n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire.
Ce que l'on nomme éloquence, ici, n'est pas un slogan : art de dire, avec un plan.
Encore que l'on convainque, une éloquence qui n'écoute plus n'est pas un détail.
Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire.
Autrement dit, l'art oratoire au Seuil, c'est un plan, un souffle, un silence, un destinataire
Il ressort qu'un discours de quatre minutes : thèse, concession, implicite, geste
Léa pose la concession avant le geste.
Lila tend le micro sans le pousser.
La proposition qui reste debout est celle-ci : un discours de quatre minutes — thèse, concession, implicite, geste
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'essai d'Aline sur l'oral d'un côté, le discours de Léa de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Le souffle sous le figuier'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Parler de notre rapport à l'oral et préparer un discours d'éloquence de cour. Point : art oratoire ; rapport à l'oral ; souffle et hypotaxe.

Consigne
Imitez le texte d'Aline Uwase.

Support — Aline Uwase — Un plan, puis le souffle
Aline Uwase — Un plan, puis le souffle
On parle trop vite du concours d'éloquence sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'argument par le souffle trop sûr, une éloquence qui n'écoute plus n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire.
Ce que l'on nomme éloquence, ici, n'est pas un slogan : art de dire, avec un plan.
Aline : il convient que l'on convainque, encore que l'on respire.
Lila tend le micro sans le pousser.
Patrick refuse le ventre comme méthode.
Rose écoute les mains de l'orateur.
La proposition qui reste debout est celle-ci : un discours de quatre minutes — thèse, concession, implicite, geste
Marc : un concours d'éloquence au Seuil se juge à ce qu'il n'a pas écrasé.
Nous clôturons sans fusionner les voix : l'essai d'Aline sur l'oral d'un côté, le discours de Léa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on convainque, une éloquence qui n'écoute plus n'est pas un détail.
Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
l'art oratoire au Seuil, c'est un plan, un souffle, un silence, un destinataire
Aline Uwase, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Le souffle sous le figuier'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos d'Aline Uwase sur « Le souffle sous le figuier » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos d'Aline Uwase sur « Le souffle sous le figuier » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Le souffle sous le figuier'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Imitez le texte d'Aline Uwase : vingt lignes, deux voix, une concession, une proposition."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Le souffle sous le figuier'
  AND l.competency = 'PE'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Écrire une lettre ouverte qui dénonce un étroit linguistique de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Lettre ouverte aux voix
Lila Sow : Radio Figuier. On parle trop vite de la lettre sur le micro trop étroit, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on reporte l'ouverture des voix, un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage.
Aline Uwase : Ce que l'on nomme ouverture, ici, n'est pas un slogan : accès daté au micro.
Hawa : nous demandons que le jeudi s'ouvre, encore que l'on traduise.
Hawa Diallo : Lila entend, rature ce n'est pas le moment.
Joël Mugisha : Aline corrige le subjonctif, garde la colère.
Rose Iradukunda : Karim signe.
Solange Mukamana : Solange aussi.
Karim Bamba : Patrick veut des exemples, les obtient.
Félicie Ndayishimiye : Un chiffre, une trace : Hawa a cité deux émissions trop étroites ; proposé un jeudi mixte ; obtenu neuf signatures.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'ouvrir des oreilles, pas de fermer le français
Yvette : Sami lit trop vite la lettre ; on le reprend.
Mado : Lila Sow entend, dans « ce n'est pas le moment », ceci qui n'est pas dit : ce n'est pas le moment veut dire votre bouche peut attendre
Sami : Autrement dit, nous demandons que le micro s'ouvre : le subjonctif ici est une politique
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une lettre — constat, exemples, heures datées, signatures
Marc : dénoncer un étroit, c'est dater une heure, pas crier une essence.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les deux émissions d'un côté, la lettre d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Ce n'est pas le moment : phrase de salon, d'une étonnante longévité.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Lettre ouverte aux voix'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un plus tard qui n'arrive jamais pour certaines bouches est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Lettre ouverte aux voix'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Écrire une lettre ouverte qui dénonce un étroit linguistique de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Dater le jeudi mixte », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Dater le jeudi mixte
On parle trop vite de la lettre sur le micro trop étroit, comme si le mot dispensait d'en examiner le prix.
Encore que l'on reporte l'ouverture des voix, un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage.
Ce que l'on nomme ouverture, ici, n'est pas un slogan : accès daté au micro.
Hawa : nous demandons que le jeudi s'ouvre, encore que l'on traduise.
Lila entend, rature ce n'est pas le moment.
Aline corrige le subjonctif, garde la colère.
Karim signe.
Solange aussi.
Patrick veut des exemples, les obtient.
Un chiffre, une trace : Hawa a cité deux émissions trop étroites ; proposé un jeudi mixte ; obtenu neuf signatures.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'ouvrir des oreilles, pas de fermer le français
Sami lit trop vite la lettre ; on le reprend.
Lila Sow entend, dans « ce n'est pas le moment », ceci qui n'est pas dit : ce n'est pas le moment veut dire votre bouche peut attendre
Autrement dit, nous demandons que le micro s'ouvre : le subjonctif ici est une politique
La proposition qui reste debout est celle-ci : une lettre — constat, exemples, heures datées, signatures
Marc : dénoncer un étroit, c'est dater une heure, pas crier une essence.
Nous clôturons sans fusionner les voix : les deux émissions d'un côté, la lettre d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Signé : Hawa Diallo, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Lettre ouverte aux voix'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : dénoncer sans insulter ; hypotaxe ; nous demandons que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on reporte l'ouverture des voix, un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage.
Ce que l'on nomme ouverture, ici, n'est pas un slogan : accès daté au micro.
Encore que l'on demande, un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail.
Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage.
Autrement dit, nous demandons que le micro s'ouvre : le subjonctif ici est une politique
Il ressort qu'une lettre : constat, exemples, heures datées, signatures
Lila entend, rature ce n'est pas le moment.
Solange aussi.
La proposition qui reste debout est celle-ci : une lettre — constat, exemples, heures datées, signatures
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les deux émissions d'un côté, la lettre d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Lettre ouverte aux voix'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Écrire une lettre ouverte qui dénonce un étroit linguistique de cour. Point : dénoncer sans insulter ; hypotaxe ; nous demandons que.

Consigne
Imitez le texte de Hawa Diallo.

Support — Hawa Diallo — Dater le jeudi mixte
Hawa Diallo — Dater le jeudi mixte
On parle trop vite de la lettre sur le micro trop étroit, comme si le mot dispensait d'en examiner le prix.
Encore que l'on reporte l'ouverture des voix, un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage.
Ce que l'on nomme ouverture, ici, n'est pas un slogan : accès daté au micro.
Hawa : nous demandons que le jeudi s'ouvre, encore que l'on traduise.
Solange aussi.
Patrick veut des exemples, les obtient.
Sami lit trop vite la lettre ; on le reprend.
La proposition qui reste debout est celle-ci : une lettre — constat, exemples, heures datées, signatures
Marc : dénoncer un étroit, c'est dater une heure, pas crier une essence.
Nous clôturons sans fusionner les voix : les deux émissions d'un côté, la lettre d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on demande, un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail.
Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
nous demandons que le micro s'ouvre : le subjonctif ici est une politique
Hawa Diallo, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Lettre ouverte aux voix'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Hawa Diallo sur « Lettre ouverte aux voix » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Hawa Diallo sur « Lettre ouverte aux voix » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Lettre ouverte aux voix'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Organiser et tenir un concours d'éloquence de cour, C2. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Concours d'éloquence
Lila Sow : Radio Figuier. On parle trop vite du concours sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme la parole en trophée, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Je concède qu'un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Aline Uwase : Ce que l'on nomme concours, ici, n'est pas un slogan : exercice oratoire, pas un trône.
Léa : loin de gagner, j'ai concédé, et l'oreille a mieux tenu.
Hawa Diallo : Yvette parle bas, emporte le prix de la concession.
Joël Mugisha : Sami trop brillant, trop peu selon.
Rose Iradukunda : Aline refuse le roi.
Solange Mukamana : Lila n'annonce pas un vainqueur, elle annonce trois écoutes.
Karim Bamba : Patrick sourit.
Félicie Ndayishimiye : Un chiffre, une trace : Trois discours ; un prix de la concession à Yvette ; zéro roi.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'entraîner une cour, pas de couronner une bouche
Yvette : Rose écoute les mains.
Mado : Yvette entend, dans « le meilleur gagne », ceci qui n'est pas dit : le meilleur gagne oublie trop vite qui n'a pas eu le micro assez tôt
Sami : Autrement dit, loin de désigner un roi, le concours entraîne l'oreille à la concession
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : trois discours, un prix de la concession, zéro trophée trop lourd
Marc : un concours C2 se juge à ce qu'il a su ne pas écraser.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les trois discours d'un côté, le palmarès d'Aline de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Le meilleur gagne : on appréciera la modestie du critère.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Concours d''éloquence'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un vainqueur trop sûr d'avoir eu raison tout seul est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Concours d''éloquence'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Organiser et tenir un concours d'éloquence de cour, C2. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le prix de la concession », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le prix de la concession
On parle trop vite du concours sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme la parole en trophée, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède qu'un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Ce que l'on nomme concours, ici, n'est pas un slogan : exercice oratoire, pas un trône.
Léa : loin de gagner, j'ai concédé, et l'oreille a mieux tenu.
Yvette parle bas, emporte le prix de la concession.
Sami trop brillant, trop peu selon.
Aline refuse le roi.
Lila n'annonce pas un vainqueur, elle annonce trois écoutes.
Patrick sourit.
Un chiffre, une trace : Trois discours ; un prix de la concession à Yvette ; zéro roi.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'entraîner une cour, pas de couronner une bouche
Rose écoute les mains.
Yvette entend, dans « le meilleur gagne », ceci qui n'est pas dit : le meilleur gagne oublie trop vite qui n'a pas eu le micro assez tôt
Autrement dit, loin de désigner un roi, le concours entraîne l'oreille à la concession
La proposition qui reste debout est celle-ci : trois discours, un prix de la concession, zéro trophée trop lourd
Marc : un concours C2 se juge à ce qu'il a su ne pas écraser.
Nous clôturons sans fusionner les voix : les trois discours d'un côté, le palmarès d'Aline de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Concours d''éloquence'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : prononcer un discours ; concession oratoire ; implicite assumé.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme la parole en trophée, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède qu'un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Ce que l'on nomme concours, ici, n'est pas un slogan : exercice oratoire, pas un trône.
Encore que l'on entraîne, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail.
Léa Niyonzima concède qu'un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Autrement dit, loin de désigner un roi, le concours entraîne l'oreille à la concession
Il ressort que trois discours, un prix de la concession, zéro trophée trop lourd
Yvette parle bas, emporte le prix de la concession.
Lila n'annonce pas un vainqueur, elle annonce trois écoutes.
La proposition qui reste debout est celle-ci : trois discours, un prix de la concession, zéro trophée trop lourd
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les trois discours d'un côté, le palmarès d'Aline de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Concours d''éloquence'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Léa Niyonzima transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Léa Niyonzima concède qu'un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Concours d''éloquence'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Organiser et tenir un concours d'éloquence de cour, C2. Point : prononcer un discours ; concession oratoire ; implicite assumé.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Le prix de la concession
Léa Niyonzima — Le prix de la concession
On parle trop vite du concours sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme la parole en trophée, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède qu'un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Ce que l'on nomme concours, ici, n'est pas un slogan : exercice oratoire, pas un trône.
Léa : loin de gagner, j'ai concédé, et l'oreille a mieux tenu.
Lila n'annonce pas un vainqueur, elle annonce trois écoutes.
Patrick sourit.
Rose écoute les mains.
La proposition qui reste debout est celle-ci : trois discours, un prix de la concession, zéro trophée trop lourd
Marc : un concours C2 se juge à ce qu'il a su ne pas écraser.
Nous clôturons sans fusionner les voix : les trois discours d'un côté, le palmarès d'Aline de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on entraîne, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail.
Léa Niyonzima concède qu'un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
loin de désigner un roi, le concours entraîne l'oreille à la concession
Léa Niyonzima, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Concours d''éloquence'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Léa Niyonzima sur « Concours d’éloquence » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Léa Niyonzima sur « Concours d’éloquence » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Concours d''éloquence'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser prononcer un discours ; concession oratoire ; implicite assumé au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — prononcer un discours ; concession oratoire ; implicite assumé
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on entraîne, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail.
Léa Niyonzima concède qu'un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Autrement dit, loin de désigner un roi, le concours entraîne l'oreille à la concession
Il ressort que trois discours, un prix de la concession, zéro trophée trop lourd
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme concours, ici, n'est pas un slogan : exercice oratoire, pas un trône.
Yvette parle bas, emporte le prix de la concession.
Lila n'annonce pas un vainqueur, elle annonce trois écoutes.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au palmarès pour de vrai genre, et Yvette demande un registre plus net.
Correction : On va au palmarès vraiment, et Yvette demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Parler nos français'
  AND s.title = 'Concours d''éloquence'
  AND l.competency = 'EL';

-- C2 — L'ère du fil
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Débattre de l'impact du fil sur la lecture, sans nostalgie de boutique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le fil et le Cahier
Lila Sow : Radio Figuier. On parle trop vite du fil et le Cahier du chemin, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on enterre le Cahier d'un tweet inventé trop court, un résumé qui se prend pour le livre n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède qu'un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Aline Uwase : Ce que l'on nomme fil, ici, n'est pas un slogan : flux inventé de la cour, trop rapide parfois.
Mado : encore que le fil porte un vers, il n'a pas à se prendre pour la page.
Hawa Diallo : Léa refuse l'enterrement.
Joël Mugisha : Sami résume trop court ; Aline allonge.
Rose Iradukunda : Karim cite un lecteur nouveau, sans triomphe.
Solange Mukamana : Lila ouvrira un débat, pas un procès.
Karim Bamba : Patrick aime le papier et le fil, à deux vitesses.
Félicie Ndayishimiye : Un chiffre, une trace : Mado a vu vingt résumés trop courts ; trois lecteurs nouveaux ; zéro enterrement du Cahier.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de lire plus loin, pas de gagner contre un écran
Yvette : Rose coud un signet.
Mado : Léa Niyonzima entend, dans « plus personne ne lit », ceci qui n'est pas dit : plus personne ne lit est souvent le cri de ceux qui n'aiment qu'une façon de lire
Sami : Autrement dit, certes le fil accélère, mais il n'a pas à remplacer la librairie immense du Cahier
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un débat — trois positions, une concession obligatoire, un geste pour le Cahier
Marc : débattre, c'est concéder, pas gagner contre un écran.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les résumés trop courts du fil d'un côté, la tribune de Mado de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Plus personne ne lit : constat commode, surtout à l'heure où l'on n'a pas ouvert le Cahier soi-même.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le fil et le Cahier'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un résumé qui se prend pour le livre est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un résumé qui se prend pour le livre n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le fil et le Cahier'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Débattre de l'impact du fil sur la lecture, sans nostalgie de boutique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le résumé n'est pas le livre », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le résumé n'est pas le livre
On parle trop vite du fil et le Cahier du chemin, comme si le mot dispensait d'en examiner le prix.
Encore que l'on enterre le Cahier d'un tweet inventé trop court, un résumé qui se prend pour le livre n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède qu'un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Ce que l'on nomme fil, ici, n'est pas un slogan : flux inventé de la cour, trop rapide parfois.
Mado : encore que le fil porte un vers, il n'a pas à se prendre pour la page.
Léa refuse l'enterrement.
Sami résume trop court ; Aline allonge.
Karim cite un lecteur nouveau, sans triomphe.
Lila ouvrira un débat, pas un procès.
Patrick aime le papier et le fil, à deux vitesses.
Un chiffre, une trace : Mado a vu vingt résumés trop courts ; trois lecteurs nouveaux ; zéro enterrement du Cahier.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de lire plus loin, pas de gagner contre un écran
Rose coud un signet.
Léa Niyonzima entend, dans « plus personne ne lit », ceci qui n'est pas dit : plus personne ne lit est souvent le cri de ceux qui n'aiment qu'une façon de lire
Autrement dit, certes le fil accélère, mais il n'a pas à remplacer la librairie immense du Cahier
La proposition qui reste debout est celle-ci : un débat — trois positions, une concession obligatoire, un geste pour le Cahier
Marc : débattre, c'est concéder, pas gagner contre un écran.
Nous clôturons sans fusionner les voix : les résumés trop courts du fil d'un côté, la tribune de Mado de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le fil et le Cahier'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : accord, concession, désaccord ; fil et livres.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on enterre le Cahier d'un tweet inventé trop court, un résumé qui se prend pour le livre n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède qu'un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Ce que l'on nomme fil, ici, n'est pas un slogan : flux inventé de la cour, trop rapide parfois.
Encore que l'on lise, un résumé qui se prend pour le livre n'est pas un détail.
Mado concède qu'un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Autrement dit, certes le fil accélère, mais il n'a pas à remplacer la librairie immense du Cahier
Il ressort qu'un débat : trois positions, une concession obligatoire, un geste pour le Cahier
Léa refuse l'enterrement.
Lila ouvrira un débat, pas un procès.
La proposition qui reste debout est celle-ci : un débat — trois positions, une concession obligatoire, un geste pour le Cahier
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les résumés trop courts du fil d'un côté, la tribune de Mado de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le fil et le Cahier'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Mado transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Mado concède qu'un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le fil et le Cahier'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Débattre de l'impact du fil sur la lecture, sans nostalgie de boutique. Point : accord, concession, désaccord ; fil et livres.

Consigne
Imitez le texte de Mado.

Support — Mado — Le résumé n'est pas le livre
Mado — Le résumé n'est pas le livre
On parle trop vite du fil et le Cahier du chemin, comme si le mot dispensait d'en examiner le prix.
Encore que l'on enterre le Cahier d'un tweet inventé trop court, un résumé qui se prend pour le livre n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède qu'un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Ce que l'on nomme fil, ici, n'est pas un slogan : flux inventé de la cour, trop rapide parfois.
Mado : encore que le fil porte un vers, il n'a pas à se prendre pour la page.
Lila ouvrira un débat, pas un procès.
Patrick aime le papier et le fil, à deux vitesses.
Rose coud un signet.
La proposition qui reste debout est celle-ci : un débat — trois positions, une concession obligatoire, un geste pour le Cahier
Marc : débattre, c'est concéder, pas gagner contre un écran.
Nous clôturons sans fusionner les voix : les résumés trop courts du fil d'un côté, la tribune de Mado de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on lise, un résumé qui se prend pour le livre n'est pas un détail.
Mado concède qu'un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
certes le fil accélère, mais il n'a pas à remplacer la librairie immense du Cahier
Mado, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le fil et le Cahier'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Mado sur « Le fil et le Cahier » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Mado sur « Le fil et le Cahier » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le fil et le Cahier'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser accord, concession, désaccord ; fil et livres au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — accord, concession, désaccord ; fil et livres
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on lise, un résumé qui se prend pour le livre n'est pas un détail.
Mado concède qu'un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Autrement dit, certes le fil accélère, mais il n'a pas à remplacer la librairie immense du Cahier
Il ressort qu'un débat : trois positions, une concession obligatoire, un geste pour le Cahier
Piège : indicatif après encore que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme fil, ici, n'est pas un slogan : flux inventé de la cour, trop rapide parfois.
Léa refuse l'enterrement.
Lila ouvrira un débat, pas un procès.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au lecture pour de vrai genre, et Léa Niyonzima demande un registre plus net.
Correction : On va au lecture vraiment, et Léa Niyonzima demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le fil et le Cahier'
  AND l.competency = 'EL';
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m3/campagne-prevention.svg",
      "word": "campagne prevention"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/public-cible.svg",
      "word": "public cible"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/conseil-adapte.svg",
      "word": "conseil adapte"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/campagne-deux-tons.svg",
      "word": "campagne-deux-tons"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le fil et le Cahier'
  AND l.competency = 'EL'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Adapter une campagne de prévention à un public de cour, sans panique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Deux tons un même soin
Lila Sow : Radio Figuier. On parle trop vite d'une campagne trop criée contre le fil, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace l'argument par la peur, une affiche qui parle à tout le monde, donc à personne n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Je concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique.
Aline Uwase : Ce que l'on nomme campagne, ici, n'est pas un slogan : discours préventif adapté.
Léa : on ferait mieux d'écrire pour une oreille, non pour une foule.
Hawa Diallo : Il vaudrait mieux que tu lises la version d'Yvette avant de crier.
Joël Mugisha : Sami corrige le trop jeune trop faux.
Rose Iradukunda : Aline refuse le slogan orphelin.
Solange Mukamana : Lila lira les deux tons.
Karim Bamba : Patrick veut le fait, pas la peur.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a écrit deux versions ; Sami a corrigé la sienne ; Yvette la sienne ; zéro panique retenue.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de prévenir, pas d'humilier l'usage
Yvette : Rose affiche sans rouge trop violent.
Mado : Sami entend, dans « ouvrez l'œil », ceci qui n'est pas dit : une affiche pour tous évite souvent de parler aux plus exposés
Sami : Autrement dit, on ferait mieux d'écrire deux versions : banc des jeunes, banc des anciens, même soin
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une campagne — deux tons, un même fait, zéro slogan orphelin
Marc : adapter un discours, c'est respecter l'interlocuteur.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'affiche trop criée d'un côté, les deux versions de Léa de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Ouvrez l'œil : on reconnaît la pédagogie de ceux qui n'ont pas le temps de nommer le risque.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Deux tons un même soin'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une affiche qui parle à tout le monde, donc à personne est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une affiche qui parle à tout le monde, donc à personne n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Deux tons un même soin'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m3/public-cible.svg",
      "word": "public cible"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/conseil-adapte.svg",
      "word": "conseil adapte"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/campagne-deux-tons.svg",
      "word": "campagne-deux-tons"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/torrent-infos.svg",
      "word": "torrent infos"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Deux tons un même soin'
  AND l.competency = 'CO'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Adapter une campagne de prévention à un public de cour, sans panique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Deux tons, un même soin », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Deux tons, un même soin
On parle trop vite d'une campagne trop criée contre le fil, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'argument par la peur, une affiche qui parle à tout le monde, donc à personne n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique.
Ce que l'on nomme campagne, ici, n'est pas un slogan : discours préventif adapté.
Léa : on ferait mieux d'écrire pour une oreille, non pour une foule.
Il vaudrait mieux que tu lises la version d'Yvette avant de crier.
Sami corrige le trop jeune trop faux.
Aline refuse le slogan orphelin.
Lila lira les deux tons.
Patrick veut le fait, pas la peur.
Un chiffre, une trace : Léa a écrit deux versions ; Sami a corrigé la sienne ; Yvette la sienne ; zéro panique retenue.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de prévenir, pas d'humilier l'usage
Rose affiche sans rouge trop violent.
Sami entend, dans « ouvrez l'œil », ceci qui n'est pas dit : une affiche pour tous évite souvent de parler aux plus exposés
Autrement dit, on ferait mieux d'écrire deux versions : banc des jeunes, banc des anciens, même soin
La proposition qui reste debout est celle-ci : une campagne — deux tons, un même fait, zéro slogan orphelin
Marc : adapter un discours, c'est respecter l'interlocuteur.
Nous clôturons sans fusionner les voix : l'affiche trop criée d'un côté, les deux versions de Léa de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Deux tons un même soin'
  AND l.competency = 'CE';
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m3/conseil-adapte.svg",
      "word": "conseil adapte"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/campagne-deux-tons.svg",
      "word": "campagne-deux-tons"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/torrent-infos.svg",
      "word": "torrent infos"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/paradoxe-article.svg",
      "word": "paradoxe article"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Deux tons un même soin'
  AND l.competency = 'CE'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : adapter un discours ; conseils ; public visé.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace l'argument par la peur, une affiche qui parle à tout le monde, donc à personne n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique.
Ce que l'on nomme campagne, ici, n'est pas un slogan : discours préventif adapté.
Encore que l'on adapte, une affiche qui parle à tout le monde, donc à personne n'est pas un détail.
Léa Niyonzima concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique.
Autrement dit, on ferait mieux d'écrire deux versions : banc des jeunes, banc des anciens, même soin
Il ressort qu'une campagne : deux tons, un même fait, zéro slogan orphelin
Il vaudrait mieux que tu lises la version d'Yvette avant de crier.
Lila lira les deux tons.
La proposition qui reste debout est celle-ci : une campagne — deux tons, un même fait, zéro slogan orphelin
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'affiche trop criée d'un côté, les deux versions de Léa de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Deux tons un même soin'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m3/campagne-deux-tons.svg",
      "word": "campagne-deux-tons"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/torrent-infos.svg",
      "word": "torrent infos"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/paradoxe-article.svg",
      "word": "paradoxe article"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/bruit-vrai.svg",
      "word": "bruit vrai"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Deux tons un même soin'
  AND l.competency = 'PO'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Adapter une campagne de prévention à un public de cour, sans panique. Point : adapter un discours ; conseils ; public visé.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Deux tons, un même soin
Léa Niyonzima — Deux tons, un même soin
On parle trop vite d'une campagne trop criée contre le fil, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'argument par la peur, une affiche qui parle à tout le monde, donc à personne n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique.
Ce que l'on nomme campagne, ici, n'est pas un slogan : discours préventif adapté.
Léa : on ferait mieux d'écrire pour une oreille, non pour une foule.
Lila lira les deux tons.
Patrick veut le fait, pas la peur.
Rose affiche sans rouge trop violent.
La proposition qui reste debout est celle-ci : une campagne — deux tons, un même fait, zéro slogan orphelin
Marc : adapter un discours, c'est respecter l'interlocuteur.
Nous clôturons sans fusionner les voix : l'affiche trop criée d'un côté, les deux versions de Léa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on adapte, une affiche qui parle à tout le monde, donc à personne n'est pas un détail.
Léa Niyonzima concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
on ferait mieux d'écrire deux versions : banc des jeunes, banc des anciens, même soin
Léa Niyonzima, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Deux tons un même soin'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Léa Niyonzima sur « Deux tons un même soin » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Léa Niyonzima sur « Deux tons un même soin » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Deux tons un même soin'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Comprendre le processus d'un bruit sans source et écrire un paradoxe. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le bruit sans source
Lila Sow : Radio Figuier. On parle trop vite d'un bruit trop vite vrai sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on prend le torrent pour une preuve, une rumeur qui n'a plus d'auteur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord.
Aline Uwase : Ce que l'on nomme rumeur, ici, n'est pas un slogan : bruit sans auteur, trop vite vrai.
Marc : loin de s'informer, la cour s'inondait, et bel et bien personne n'avait de source.
Hawa Diallo : Lila dément trop tard, ce qui est déjà une leçon.
Aline : le paradoxe n'est pas un jeu, c'est une alarme.
Rose Iradukunda : Léa retrace, échoue, le dit.
Solange Mukamana : Karim refuse le partout.
Karim Bamba : Sami avait partagé trop vite ; il le dit aussi.
Félicie Ndayishimiye : Un chiffre, une trace : Marc a retracé zéro source ; sept répétitions ; une démenti tardif de Lila.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de ralentir le bruit, pas d'interdire le fil
Yvette : Patrick veut un article, pas une chasse.
Mado : Lila Sow entend, dans « c'est partout donc c'est vrai », ceci qui n'est pas dit : partout donc vrai est la grammaire du torrent, pas celle d'une enquête
Sami : Autrement dit, loin de s'informer, on s'inonde ; bel et bien une source manquait
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un article-paradoxe — plus l'on répète, moins l'on sait, sauf si l'on nomme
Nina Kayitesi : Mado glisse une ironie, puis une méthode.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le torrent du fil d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : C'est partout donc c'est vrai : on admirera la rigueur du donc.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le bruit sans source'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une rumeur qui n'a plus d'auteur est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une rumeur qui n'a plus d'auteur n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le bruit sans source'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comprendre le processus d'un bruit sans source et écrire un paradoxe. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Partout n'est pas une source », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Partout n'est pas une source
On parle trop vite d'un bruit trop vite vrai sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on prend le torrent pour une preuve, une rumeur qui n'a plus d'auteur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord.
Ce que l'on nomme rumeur, ici, n'est pas un slogan : bruit sans auteur, trop vite vrai.
Marc : loin de s'informer, la cour s'inondait, et bel et bien personne n'avait de source.
Lila dément trop tard, ce qui est déjà une leçon.
Aline : le paradoxe n'est pas un jeu, c'est une alarme.
Léa retrace, échoue, le dit.
Karim refuse le partout.
Sami avait partagé trop vite ; il le dit aussi.
Un chiffre, une trace : Marc a retracé zéro source ; sept répétitions ; une démenti tardif de Lila.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de ralentir le bruit, pas d'interdire le fil
Patrick veut un article, pas une chasse.
Lila Sow entend, dans « c'est partout donc c'est vrai », ceci qui n'est pas dit : partout donc vrai est la grammaire du torrent, pas celle d'une enquête
Autrement dit, loin de s'informer, on s'inonde ; bel et bien une source manquait
La proposition qui reste debout est celle-ci : un article-paradoxe — plus l'on répète, moins l'on sait, sauf si l'on nomme
Mado glisse une ironie, puis une méthode.
Nous clôturons sans fusionner les voix : le torrent du fil d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Signé : Marc Nkurunziza, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le bruit sans source'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : paradoxe ; bruit sans source ; loin de / bel et bien.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on prend le torrent pour une preuve, une rumeur qui n'a plus d'auteur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord.
Ce que l'on nomme rumeur, ici, n'est pas un slogan : bruit sans auteur, trop vite vrai.
Encore que l'on nomme, une rumeur qui n'a plus d'auteur n'est pas un détail.
Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord.
Autrement dit, loin de s'informer, on s'inonde ; bel et bien une source manquait
Il ressort qu'un article-paradoxe : plus l'on répète, moins l'on sait, sauf si l'on nomme
Lila dément trop tard, ce qui est déjà une leçon.
Karim refuse le partout.
La proposition qui reste debout est celle-ci : un article-paradoxe — plus l'on répète, moins l'on sait, sauf si l'on nomme
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le torrent du fil d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le bruit sans source'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Comprendre le processus d'un bruit sans source et écrire un paradoxe. Point : paradoxe ; bruit sans source ; loin de / bel et bien.

Consigne
Imitez le texte de Marc Nkurunziza.

Support — Marc Nkurunziza — Partout n'est pas une source
Marc Nkurunziza — Partout n'est pas une source
On parle trop vite d'un bruit trop vite vrai sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on prend le torrent pour une preuve, une rumeur qui n'a plus d'auteur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord.
Ce que l'on nomme rumeur, ici, n'est pas un slogan : bruit sans auteur, trop vite vrai.
Marc : loin de s'informer, la cour s'inondait, et bel et bien personne n'avait de source.
Karim refuse le partout.
Sami avait partagé trop vite ; il le dit aussi.
Patrick veut un article, pas une chasse.
La proposition qui reste debout est celle-ci : un article-paradoxe — plus l'on répète, moins l'on sait, sauf si l'on nomme
Mado glisse une ironie, puis une méthode.
Nous clôturons sans fusionner les voix : le torrent du fil d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on nomme, une rumeur qui n'a plus d'auteur n'est pas un détail.
Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
loin de s'informer, on s'inonde ; bel et bien une source manquait
Marc Nkurunziza, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le bruit sans source'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Marc Nkurunziza sur « Le bruit sans source » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Marc Nkurunziza sur « Le bruit sans source » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Le bruit sans source'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Envisager des dérives technologiques inventées et écrire un extrait dystopique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Demain trop net
Lila Sow : Radio Figuier. On parle trop vite d'une Rukiri-Nord trop écoutée, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace les relais humains par une voix trop sûre, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Je concède qu'un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Aline Uwase : Ce que l'on nomme dystopie, ici, n'est pas un slogan : ailleurs sombre pour juger l'ici.
Léa : on dirait que midi n'aurait plus d'ombre, seulement un score.
Hawa Diallo : Joël demande qui dirait non.
Aline : le conditionnel ici est une éthique.
Rose Iradukunda : Marc entend une antenne trop sûre.
Solange Mukamana : Mado rature miracle.
Karim Bamba : Lila n'adoucira pas l'extrait.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a écrit trois pages ; coupé le mot miracle ; gardé le refus de Joël.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'imaginer pour juger l'ici, pas pour se faire peur en vain
Yvette : Nina voit une tour.
Mado : Joël Mugisha entend, dans « la machine nous aide », ceci qui n'est pas dit : la machine nous aide cache trop souvent qui n'a plus le droit de dire non
Sami : Autrement dit, on dirait que les lanternes marcheraient toutes seules, et l'on n'entendrait plus Joël
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un extrait — demain trop net, une voix, un refus, une ombre
Patrick : déduire un point de vue, c'est lire qui parle trop bien de l'aide.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le podcast trop enthousiaste d'un côté, l'extrait de Léa de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : La machine nous aide : on notera le nous, d'une générosité qui n'a pas à porter.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Demain trop net'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un demain où Joël n'aurait plus à porter, ni à décider est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Demain trop net'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Envisager des dérives technologiques inventées et écrire un extrait dystopique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Les lanternes trop seules », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Les lanternes trop seules
On parle trop vite d'une Rukiri-Nord trop écoutée, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace les relais humains par une voix trop sûre, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède qu'un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Ce que l'on nomme dystopie, ici, n'est pas un slogan : ailleurs sombre pour juger l'ici.
Léa : on dirait que midi n'aurait plus d'ombre, seulement un score.
Joël demande qui dirait non.
Aline : le conditionnel ici est une éthique.
Marc entend une antenne trop sûre.
Mado rature miracle.
Lila n'adoucira pas l'extrait.
Un chiffre, une trace : Léa a écrit trois pages ; coupé le mot miracle ; gardé le refus de Joël.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'imaginer pour juger l'ici, pas pour se faire peur en vain
Nina voit une tour.
Joël Mugisha entend, dans « la machine nous aide », ceci qui n'est pas dit : la machine nous aide cache trop souvent qui n'a plus le droit de dire non
Autrement dit, on dirait que les lanternes marcheraient toutes seules, et l'on n'entendrait plus Joël
La proposition qui reste debout est celle-ci : un extrait — demain trop net, une voix, un refus, une ombre
Patrick : déduire un point de vue, c'est lire qui parle trop bien de l'aide.
Nous clôturons sans fusionner les voix : le podcast trop enthousiaste d'un côté, l'extrait de Léa de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Demain trop net'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : dystopie ; dérives ; point de vue d'un intervenant.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace les relais humains par une voix trop sûre, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède qu'un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Ce que l'on nomme dystopie, ici, n'est pas un slogan : ailleurs sombre pour juger l'ici.
Encore que l'on imagine, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail.
Léa Niyonzima concède qu'un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Autrement dit, on dirait que les lanternes marcheraient toutes seules, et l'on n'entendrait plus Joël
Il ressort qu'un extrait : demain trop net, une voix, un refus, une ombre
Joël demande qui dirait non.
Mado rature miracle.
La proposition qui reste debout est celle-ci : un extrait — demain trop net, une voix, un refus, une ombre
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le podcast trop enthousiaste d'un côté, l'extrait de Léa de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Demain trop net'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Léa Niyonzima transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Léa Niyonzima concède qu'un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Demain trop net'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Envisager des dérives technologiques inventées et écrire un extrait dystopique. Point : dystopie ; dérives ; point de vue d'un intervenant.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Les lanternes trop seules
Léa Niyonzima — Les lanternes trop seules
On parle trop vite d'une Rukiri-Nord trop écoutée, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace les relais humains par une voix trop sûre, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède qu'un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Ce que l'on nomme dystopie, ici, n'est pas un slogan : ailleurs sombre pour juger l'ici.
Léa : on dirait que midi n'aurait plus d'ombre, seulement un score.
Mado rature miracle.
Lila n'adoucira pas l'extrait.
Nina voit une tour.
La proposition qui reste debout est celle-ci : un extrait — demain trop net, une voix, un refus, une ombre
Patrick : déduire un point de vue, c'est lire qui parle trop bien de l'aide.
Nous clôturons sans fusionner les voix : le podcast trop enthousiaste d'un côté, l'extrait de Léa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on imagine, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail.
Léa Niyonzima concède qu'un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
on dirait que les lanternes marcheraient toutes seules, et l'on n'entendrait plus Joël
Léa Niyonzima, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Demain trop net'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Léa Niyonzima sur « Demain trop net » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Léa Niyonzima sur « Demain trop net » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Demain trop net'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser dystopie ; dérives ; point de vue d'un intervenant au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — dystopie ; dérives ; point de vue d'un intervenant
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on imagine, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail.
Léa Niyonzima concède qu'un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Autrement dit, on dirait que les lanternes marcheraient toutes seules, et l'on n'entendrait plus Joël
Il ressort qu'un extrait : demain trop net, une voix, un refus, une ombre
Piège : indicatif plat là où le conditionnel peint
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme dystopie, ici, n'est pas un slogan : ailleurs sombre pour juger l'ici.
Joël demande qui dirait non.
Mado rature miracle.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au refus pour de vrai genre, et Joël Mugisha demande un registre plus net.
Correction : On va au refus vraiment, et Joël Mugisha demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Demain trop net'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Rédiger un article qui tienne un paradoxe sans se perdre en effets. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Article-paradoxe
Lila Sow : Radio Figuier. On parle trop vite de plus l'on sait, moins l'on vérifie, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on prend le volume pour la connaissance, une fierté d'être au courant qui n'a plus de source n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait.
Aline Uwase : Ce que l'on nomme paradoxe, ici, n'est pas un slogan : tension tenue entre deux vérités.
Marc : loin de savoir davantage, l'on vérifie moins, et c'est bel et bien un paradoxe de cour.
Hawa Diallo : Lila accepte d'être le geste : attendre.
Joël Mugisha : Aline refuse l'effet gratuit.
Rose Iradukunda : Léa fournit l'exemple.
Solange Mukamana : Sami avait partagé ; il relit.
Karim Bamba : Patrick veut un titre sans cri.
Félicie Ndayishimiye : Un chiffre, une trace : Marc a cité le torrent de la veille ; zéro source ; un geste : attendre Lila.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'écrire juste, pas d'épater par le paradoxe
Yvette : Mado glisse une ironie, puis la rature trop facile.
Mado : Lila Sow entend, dans « on est informés comme jamais », ceci qui n'est pas dit : informés comme jamais flatte pour ne plus avoir à vérifier
Sami : Autrement dit, plus le torrent grossit, plus la source se dérobe — sauf à la nommer
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un article — paradoxe, exemple du Seuil, geste (nommer, ralentir)
Karim : un article C2 se juge à l'exemple, pas à la pirouette.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les bruits de la veille d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : On est informés comme jamais : la formule a cet avantage qu'elle n'exige aucune source.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Article-paradoxe'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une fierté d'être au courant qui n'a plus de source est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une fierté d'être au courant qui n'a plus de source n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Article-paradoxe'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rédiger un article qui tienne un paradoxe sans se perdre en effets. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le volume n'est pas le savoir », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le volume n'est pas le savoir
On parle trop vite de plus l'on sait, moins l'on vérifie, comme si le mot dispensait d'en examiner le prix.
Encore que l'on prend le volume pour la connaissance, une fierté d'être au courant qui n'a plus de source n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait.
Ce que l'on nomme paradoxe, ici, n'est pas un slogan : tension tenue entre deux vérités.
Marc : loin de savoir davantage, l'on vérifie moins, et c'est bel et bien un paradoxe de cour.
Lila accepte d'être le geste : attendre.
Aline refuse l'effet gratuit.
Léa fournit l'exemple.
Sami avait partagé ; il relit.
Patrick veut un titre sans cri.
Un chiffre, une trace : Marc a cité le torrent de la veille ; zéro source ; un geste : attendre Lila.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'écrire juste, pas d'épater par le paradoxe
Mado glisse une ironie, puis la rature trop facile.
Lila Sow entend, dans « on est informés comme jamais », ceci qui n'est pas dit : informés comme jamais flatte pour ne plus avoir à vérifier
Autrement dit, plus le torrent grossit, plus la source se dérobe — sauf à la nommer
La proposition qui reste debout est celle-ci : un article — paradoxe, exemple du Seuil, geste (nommer, ralentir)
Karim : un article C2 se juge à l'exemple, pas à la pirouette.
Nous clôturons sans fusionner les voix : les bruits de la veille d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Signé : Marc Nkurunziza, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Article-paradoxe'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : exprimer un paradoxe ; concession ; reformulation.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on prend le volume pour la connaissance, une fierté d'être au courant qui n'a plus de source n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait.
Ce que l'on nomme paradoxe, ici, n'est pas un slogan : tension tenue entre deux vérités.
Encore que l'on vérifie, une fierté d'être au courant qui n'a plus de source n'est pas un détail.
Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait.
Autrement dit, plus le torrent grossit, plus la source se dérobe — sauf à la nommer
Il ressort qu'un article : paradoxe, exemple du Seuil, geste (nommer, ralentir)
Lila accepte d'être le geste : attendre.
Sami avait partagé ; il relit.
La proposition qui reste debout est celle-ci : un article — paradoxe, exemple du Seuil, geste (nommer, ralentir)
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les bruits de la veille d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Article-paradoxe'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Rédiger un article qui tienne un paradoxe sans se perdre en effets. Point : exprimer un paradoxe ; concession ; reformulation.

Consigne
Imitez le texte de Marc Nkurunziza.

Support — Marc Nkurunziza — Le volume n'est pas le savoir
Marc Nkurunziza — Le volume n'est pas le savoir
On parle trop vite de plus l'on sait, moins l'on vérifie, comme si le mot dispensait d'en examiner le prix.
Encore que l'on prend le volume pour la connaissance, une fierté d'être au courant qui n'a plus de source n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait.
Ce que l'on nomme paradoxe, ici, n'est pas un slogan : tension tenue entre deux vérités.
Marc : loin de savoir davantage, l'on vérifie moins, et c'est bel et bien un paradoxe de cour.
Sami avait partagé ; il relit.
Patrick veut un titre sans cri.
Mado glisse une ironie, puis la rature trop facile.
La proposition qui reste debout est celle-ci : un article — paradoxe, exemple du Seuil, geste (nommer, ralentir)
Karim : un article C2 se juge à l'exemple, pas à la pirouette.
Nous clôturons sans fusionner les voix : les bruits de la veille d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on vérifie, une fierté d'être au courant qui n'a plus de source n'est pas un détail.
Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
plus le torrent grossit, plus la source se dérobe — sauf à la nommer
Marc Nkurunziza, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Article-paradoxe'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Marc Nkurunziza sur « Article-paradoxe » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Marc Nkurunziza sur « Article-paradoxe » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Article-paradoxe'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Écrire un extrait de dystopie ancré à Rukiri-Nord, original, sans catalogue de gadgets. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Extrait dystopique
Lila Sow : Radio Figuier. On parle trop vite de la cour trop écoutée de demain, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface les relais, les ratures, les non, une simplicité où l'on n'aurait plus à se parler n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Je concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus.
Aline Uwase : Ce que l'on nomme anticipation, ici, n'est pas un slogan : écriture du demain pour juger l'aujourd'hui.
Léa : on dirait que les lanternes avanceraient sans Joël, et que cela s'appellerait simple.
Hawa Diallo : Mado exige le non.
Aline : pas de catalogue.
Rose Iradukunda : Marc entend trop de tout sera.
Solange Mukamana : Lila n'adoucit pas.
Karim Bamba : Nina voit midi trop blanc.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a gardé le non de Joël ; coupé trois gadgets ; laissé l'ombre.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une écriture, pas d'un inventaire d'objets
Yvette : Sami veut un objet ; on le refuse.
Mado : entend, dans « tout sera plus simple », ceci qui n'est pas dit : plus simple veut souvent dire plus seul, plus écouté, moins consulté
Sami : Autrement dit, midi n'aurait plus d'ombre ; Joël n'aurait plus de relais ; Lila n'aurait plus de rature
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un extrait de quarante lignes — un midi, une voix trop sûre, un non
Patrick : un extrait se juge à l'ombre qu'il a gardée.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les ratures de Léa d'un côté, la lecture de Mado de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Tout sera plus simple : promesse d'une voix qui n'a pas à demander la permission de couper l'ombre.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Extrait dystopique'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une simplicité où l'on n'aurait plus à se parler est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une simplicité où l'on n'aurait plus à se parler n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Extrait dystopique'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Écrire un extrait de dystopie ancré à Rukiri-Nord, original, sans catalogue de gadgets. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Garder le non », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Garder le non
On parle trop vite de la cour trop écoutée de demain, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface les relais, les ratures, les non, une simplicité où l'on n'aurait plus à se parler n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus.
Ce que l'on nomme anticipation, ici, n'est pas un slogan : écriture du demain pour juger l'aujourd'hui.
Léa : on dirait que les lanternes avanceraient sans Joël, et que cela s'appellerait simple.
Mado exige le non.
Aline : pas de catalogue.
Marc entend trop de tout sera.
Lila n'adoucit pas.
Nina voit midi trop blanc.
Un chiffre, une trace : Léa a gardé le non de Joël ; coupé trois gadgets ; laissé l'ombre.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une écriture, pas d'un inventaire d'objets
Sami veut un objet ; on le refuse.
Mado entend, dans « tout sera plus simple », ceci qui n'est pas dit : plus simple veut souvent dire plus seul, plus écouté, moins consulté
Autrement dit, midi n'aurait plus d'ombre ; Joël n'aurait plus de relais ; Lila n'aurait plus de rature
La proposition qui reste debout est celle-ci : un extrait de quarante lignes — un midi, une voix trop sûre, un non
Patrick : un extrait se juge à l'ombre qu'il a gardée.
Nous clôturons sans fusionner les voix : les ratures de Léa d'un côté, la lecture de Mado de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Extrait dystopique'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : écriture d'anticipation ; voix ; ombre.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on efface les relais, les ratures, les non, une simplicité où l'on n'aurait plus à se parler n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus.
Ce que l'on nomme anticipation, ici, n'est pas un slogan : écriture du demain pour juger l'aujourd'hui.
Encore que l'on écrive, une simplicité où l'on n'aurait plus à se parler n'est pas un détail.
Léa Niyonzima concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus.
Autrement dit, midi n'aurait plus d'ombre ; Joël n'aurait plus de relais ; Lila n'aurait plus de rature
Il ressort qu'un extrait de quarante lignes : un midi, une voix trop sûre, un non
Mado exige le non.
Lila n'adoucit pas.
La proposition qui reste debout est celle-ci : un extrait de quarante lignes — un midi, une voix trop sûre, un non
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les ratures de Léa d'un côté, la lecture de Mado de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Extrait dystopique'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Écrire un extrait de dystopie ancré à Rukiri-Nord, original, sans catalogue de gadgets. Point : écriture d'anticipation ; voix ; ombre.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Garder le non
Léa Niyonzima — Garder le non
On parle trop vite de la cour trop écoutée de demain, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface les relais, les ratures, les non, une simplicité où l'on n'aurait plus à se parler n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus.
Ce que l'on nomme anticipation, ici, n'est pas un slogan : écriture du demain pour juger l'aujourd'hui.
Léa : on dirait que les lanternes avanceraient sans Joël, et que cela s'appellerait simple.
Lila n'adoucit pas.
Nina voit midi trop blanc.
Sami veut un objet ; on le refuse.
La proposition qui reste debout est celle-ci : un extrait de quarante lignes — un midi, une voix trop sûre, un non
Patrick : un extrait se juge à l'ombre qu'il a gardée.
Nous clôturons sans fusionner les voix : les ratures de Léa d'un côté, la lecture de Mado de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on écrive, une simplicité où l'on n'aurait plus à se parler n'est pas un détail.
Léa Niyonzima concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
midi n'aurait plus d'ombre ; Joël n'aurait plus de relais ; Lila n'aurait plus de rature
Léa Niyonzima, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Extrait dystopique'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Léa Niyonzima sur « Extrait dystopique » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Léa Niyonzima sur « Extrait dystopique » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — L''ère du fil'
  AND s.title = 'Extrait dystopique'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;

-- C2 — Ce que le figuier se souvient
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Démontrer l'intérêt d'un support inventé pour enseigner une mémoire de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le tableau de la cour
Lila Sow : Radio Figuier. On parle trop vite d'un support trop controversé d'Aline, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on tienne le craie pour une vérité sans source, une pédagogie qui n'avoue pas ses angles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Aline Uwase concède qu'un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Aline Uwase : Ce que l'on nomme support, ici, n'est pas un slogan : outil pédagogique, avec un angle.
Patrick Habimana : Selon Aline, le tableau aide à déduire ; d'après Patrick, il aide trop.
Hawa Diallo : Il ressort que l'intérêt existe, et l'angle mort aussi.
Joël Mugisha : Yvette se souvient autrement.
Rose Iradukunda : Lila n'enregistrera pas une leçon trop sûre.
Solange Mukamana : Solange demande les sources de la craie.
Karim Bamba : Sami déduit trop vite ; on le ralentit.
Félicie Ndayishimiye : Un chiffre, une trace : Aline a montré deux supports ; six déductions ; deux angles morts nommés.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'enseigner une mémoire, pas une obéissance
Yvette : Mado glisse une ironie sur la craie.
Mado : Patrick Habimana entend, dans « au tableau on ne discute pas », ceci qui n'est pas dit : on ne discute pas veut dire la craie a déjà choisi pour vous
Sami : Autrement dit, il ressort qu'un support se juge à ce qu'il permet de déduire, et à ce qu'il empêche de voir
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un essai — intérêt, angle mort, usage sous le figuier
Marc : un essai pédagogique avoue ses angles.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le support d'Aline d'un côté, la critique de Patrick de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Au tableau on ne discute pas : on reconnaît la sérénité des vérités qui n'ont pas à se sourcer.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Le tableau de la cour'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une pédagogie qui n'avoue pas ses angles est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une pédagogie qui n'avoue pas ses angles n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Le tableau de la cour'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Reformulez l'implicite de « au tableau on ne discute pas » et la concession d'Aline Uwase."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Le tableau de la cour'
  AND l.competency = 'CO'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Démontrer l'intérêt d'un support inventé pour enseigner une mémoire de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « La craie a un angle », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La craie a un angle
On parle trop vite d'un support trop controversé d'Aline, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne le craie pour une vérité sans source, une pédagogie qui n'avoue pas ses angles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède qu'un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Ce que l'on nomme support, ici, n'est pas un slogan : outil pédagogique, avec un angle.
Selon Aline, le tableau aide à déduire ; d'après Patrick, il aide trop.
Il ressort que l'intérêt existe, et l'angle mort aussi.
Yvette se souvient autrement.
Lila n'enregistrera pas une leçon trop sûre.
Solange demande les sources de la craie.
Sami déduit trop vite ; on le ralentit.
Un chiffre, une trace : Aline a montré deux supports ; six déductions ; deux angles morts nommés.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'enseigner une mémoire, pas une obéissance
Mado glisse une ironie sur la craie.
Patrick Habimana entend, dans « au tableau on ne discute pas », ceci qui n'est pas dit : on ne discute pas veut dire la craie a déjà choisi pour vous
Autrement dit, il ressort qu'un support se juge à ce qu'il permet de déduire, et à ce qu'il empêche de voir
La proposition qui reste debout est celle-ci : un essai — intérêt, angle mort, usage sous le figuier
Marc : un essai pédagogique avoue ses angles.
Nous clôturons sans fusionner les voix : le support d'Aline d'un côté, la critique de Patrick de l'autre, et le point où elles refusent de se ressembler.
Signé : Aline Uwase, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Le tableau de la cour'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : raisonnement déductif ; intérêt d'un support pédagogique.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on tienne le craie pour une vérité sans source, une pédagogie qui n'avoue pas ses angles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède qu'un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Ce que l'on nomme support, ici, n'est pas un slogan : outil pédagogique, avec un angle.
Encore que l'on démontre, une pédagogie qui n'avoue pas ses angles n'est pas un détail.
Aline Uwase concède qu'un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Autrement dit, il ressort qu'un support se juge à ce qu'il permet de déduire, et à ce qu'il empêche de voir
Il ressort qu'un essai : intérêt, angle mort, usage sous le figuier
Il ressort que l'intérêt existe, et l'angle mort aussi.
Solange demande les sources de la craie.
La proposition qui reste debout est celle-ci : un essai — intérêt, angle mort, usage sous le figuier
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le support d'Aline d'un côté, la critique de Patrick de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Le tableau de la cour'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Aline Uwase transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Aline Uwase concède qu'un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Le tableau de la cour'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Démontrer l'intérêt d'un support inventé pour enseigner une mémoire de cour. Point : raisonnement déductif ; intérêt d'un support pédagogique.

Consigne
Imitez le texte d'Aline Uwase.

Support — Aline Uwase — La craie a un angle
Aline Uwase — La craie a un angle
On parle trop vite d'un support trop controversé d'Aline, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne le craie pour une vérité sans source, une pédagogie qui n'avoue pas ses angles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède qu'un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Ce que l'on nomme support, ici, n'est pas un slogan : outil pédagogique, avec un angle.
Selon Aline, le tableau aide à déduire ; d'après Patrick, il aide trop.
Solange demande les sources de la craie.
Sami déduit trop vite ; on le ralentit.
Mado glisse une ironie sur la craie.
La proposition qui reste debout est celle-ci : un essai — intérêt, angle mort, usage sous le figuier
Marc : un essai pédagogique avoue ses angles.
Nous clôturons sans fusionner les voix : le support d'Aline d'un côté, la critique de Patrick de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on démontre, une pédagogie qui n'avoue pas ses angles n'est pas un détail.
Aline Uwase concède qu'un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il ressort qu'un support se juge à ce qu'il permet de déduire, et à ce qu'il empêche de voir
Aline Uwase, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Le tableau de la cour'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos d'Aline Uwase sur « Le tableau de la cour » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos d'Aline Uwase sur « Le tableau de la cour » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Le tableau de la cour'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Imitez le texte d'Aline Uwase : vingt lignes, deux voix, une concession, une proposition."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Le tableau de la cour'
  AND l.competency = 'PE'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser raisonnement déductif ; intérêt d'un support pédagogique au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — raisonnement déductif ; intérêt d'un support pédagogique
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on démontre, une pédagogie qui n'avoue pas ses angles n'est pas un détail.
Aline Uwase concède qu'un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Autrement dit, il ressort qu'un support se juge à ce qu'il permet de déduire, et à ce qu'il empêche de voir
Il ressort qu'un essai : intérêt, angle mort, usage sous le figuier
Piège : fusionner les sources au lieu des attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme support, ici, n'est pas un slogan : outil pédagogique, avec un angle.
Il ressort que l'intérêt existe, et l'angle mort aussi.
Solange demande les sources de la craie.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au angle pour de vrai genre, et Patrick Habimana demande un registre plus net.
Correction : On va au angle vraiment, et Patrick Habimana demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Le tableau de la cour'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Rédiger un éditorial sur des pactes de cour, sans copier un traité réel. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Éditorial des pactes
Lila Sow : Radio Figuier. On parle trop vite des pactes de la rive, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface les désaccords datés, un éditorial trop lyrique pour être historique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Marc Nkurunziza concède qu'un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Aline Uwase : Ce que l'on nomme pacte, ici, n'est pas un slogan : accord daté de cour, avec cessions.
Marc : selon les minutes, le premier jeudi a cédé une heure ; le deuxième une rampe ; le troisième un silence.
Hawa Diallo : D'après Solange, l'hymne arrivait trop tôt.
Joël Mugisha : Il ressort qu'un pacte se raconte, il ne se chante pas.
Rose Iradukunda : Aline veut la chronologie.
Solange Mukamana : Lila lira l'éditorial sans fanfare.
Karim Bamba : Patrick refuse la carte trop grande.
Félicie Ndayishimiye : Un chiffre, une trace : Marc a daté trois jeudis ; nommé Solange et Joël ; raturé l'union trop large.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'accords de cour, pas d'une carte d'États
Yvette : se souvient du troisième jeudi.
Mado : Solange Mukamana entend, dans « l'union fait la force », ceci qui n'est pas dit : l'union fait la force dispense trop souvent de dire qui a porté
Sami : Autrement dit, un éditorial C2 a un plan chronologique, des noms, une ironie contre le lyrique trop facile
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un éditorial — trois dates inventées de cour, un pacte, une rampe
Nina : un accord de rive n'est pas un empire.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les minutes trop lyriques d'un côté, l'éditorial de Marc de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : L'union fait la force : on aimerait connaître le nom de ceux qui, dans l'union, portent.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Éditorial des pactes'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un éditorial trop lyrique pour être historique est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un éditorial trop lyrique pour être historique n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Éditorial des pactes'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m4/plan-chrono.svg",
      "word": "plan chrono"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/assemblee-rive.svg",
      "word": "assemblee rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/carte-pactes.svg",
      "word": "carte pactes"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/pacte-rive.svg",
      "word": "pacte-rive"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Éditorial des pactes'
  AND l.competency = 'CO'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rédiger un éditorial sur des pactes de cour, sans copier un traité réel. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Des dates, pas un hymne », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Des dates, pas un hymne
On parle trop vite des pactes de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface les désaccords datés, un éditorial trop lyrique pour être historique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède qu'un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Ce que l'on nomme pacte, ici, n'est pas un slogan : accord daté de cour, avec cessions.
Marc : selon les minutes, le premier jeudi a cédé une heure ; le deuxième une rampe ; le troisième un silence.
D'après Solange, l'hymne arrivait trop tôt.
Il ressort qu'un pacte se raconte, il ne se chante pas.
Aline veut la chronologie.
Lila lira l'éditorial sans fanfare.
Patrick refuse la carte trop grande.
Un chiffre, une trace : Marc a daté trois jeudis ; nommé Solange et Joël ; raturé l'union trop large.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'accords de cour, pas d'une carte d'États
Yvette se souvient du troisième jeudi.
Solange Mukamana entend, dans « l'union fait la force », ceci qui n'est pas dit : l'union fait la force dispense trop souvent de dire qui a porté
Autrement dit, un éditorial C2 a un plan chronologique, des noms, une ironie contre le lyrique trop facile
La proposition qui reste debout est celle-ci : un éditorial — trois dates inventées de cour, un pacte, une rampe
Nina : un accord de rive n'est pas un empire.
Nous clôturons sans fusionner les voix : les minutes trop lyriques d'un côté, l'éditorial de Marc de l'autre, et le point où elles refusent de se ressembler.
Signé : Marc Nkurunziza, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Éditorial des pactes'
  AND l.competency = 'CE';
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m4/assemblee-rive.svg",
      "word": "assemblee rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/carte-pactes.svg",
      "word": "carte pactes"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/pacte-rive.svg",
      "word": "pacte-rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/discours-officiel.svg",
      "word": "discours officiel"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Éditorial des pactes'
  AND l.competency = 'CE'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : plan chronologique ; éditorial ; accords de rive inventés.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on efface les désaccords datés, un éditorial trop lyrique pour être historique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède qu'un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Ce que l'on nomme pacte, ici, n'est pas un slogan : accord daté de cour, avec cessions.
Encore que l'on date, un éditorial trop lyrique pour être historique n'est pas un détail.
Marc Nkurunziza concède qu'un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Autrement dit, un éditorial C2 a un plan chronologique, des noms, une ironie contre le lyrique trop facile
Il ressort qu'un éditorial : trois dates inventées de cour, un pacte, une rampe
D'après Solange, l'hymne arrivait trop tôt.
Lila lira l'éditorial sans fanfare.
La proposition qui reste debout est celle-ci : un éditorial — trois dates inventées de cour, un pacte, une rampe
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les minutes trop lyriques d'un côté, l'éditorial de Marc de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Éditorial des pactes'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Marc Nkurunziza transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Marc Nkurunziza concède qu'un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Éditorial des pactes'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m4/carte-pactes.svg",
      "word": "carte pactes"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/pacte-rive.svg",
      "word": "pacte-rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/discours-officiel.svg",
      "word": "discours officiel"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/chronique-guerre.svg",
      "word": "chronique guerre"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Éditorial des pactes'
  AND l.competency = 'PO'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Rédiger un éditorial sur des pactes de cour, sans copier un traité réel. Point : plan chronologique ; éditorial ; accords de rive inventés.

Consigne
Imitez le texte de Marc Nkurunziza.

Support — Marc Nkurunziza — Des dates, pas un hymne
Marc Nkurunziza — Des dates, pas un hymne
On parle trop vite des pactes de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface les désaccords datés, un éditorial trop lyrique pour être historique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède qu'un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Ce que l'on nomme pacte, ici, n'est pas un slogan : accord daté de cour, avec cessions.
Marc : selon les minutes, le premier jeudi a cédé une heure ; le deuxième une rampe ; le troisième un silence.
Lila lira l'éditorial sans fanfare.
Patrick refuse la carte trop grande.
Yvette se souvient du troisième jeudi.
La proposition qui reste debout est celle-ci : un éditorial — trois dates inventées de cour, un pacte, une rampe
Nina : un accord de rive n'est pas un empire.
Nous clôturons sans fusionner les voix : les minutes trop lyriques d'un côté, l'éditorial de Marc de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on date, un éditorial trop lyrique pour être historique n'est pas un détail.
Marc Nkurunziza concède qu'un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
un éditorial C2 a un plan chronologique, des noms, une ironie contre le lyrique trop facile
Marc Nkurunziza, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Éditorial des pactes'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Marc Nkurunziza sur « Éditorial des pactes » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Marc Nkurunziza sur « Éditorial des pactes » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Éditorial des pactes'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m4/pacte-rive.svg",
      "word": "pacte-rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/discours-officiel.svg",
      "word": "discours officiel"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/chronique-guerre.svg",
      "word": "chronique guerre"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/veillee-noms.svg",
      "word": "veillee noms"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Éditorial des pactes'
  AND l.competency = 'PE'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser plan chronologique ; éditorial ; accords de rive inventés au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — plan chronologique ; éditorial ; accords de rive inventés
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on date, un éditorial trop lyrique pour être historique n'est pas un détail.
Marc Nkurunziza concède qu'un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Autrement dit, un éditorial C2 a un plan chronologique, des noms, une ironie contre le lyrique trop facile
Il ressort qu'un éditorial : trois dates inventées de cour, un pacte, une rampe
Piège : fusionner les sources au lieu des attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme pacte, ici, n'est pas un slogan : accord daté de cour, avec cessions.
D'après Solange, l'hymne arrivait trop tôt.
Lila lira l'éditorial sans fanfare.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au chronologie pour de vrai genre, et Solange Mukamana demande un registre plus net.
Correction : On va au chronologie vraiment, et Solange Mukamana demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Éditorial des pactes'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Analyser un discours de veillée et enregistrer une chronique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Les noms avant la formule
Lila Sow : Radio Figuier. On parle trop vite de la veillée sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on tienne lieu de travail de mémoire, une formule trop lisse pour les noms trop précis n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Yvette concède qu'une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Aline Uwase : Ce que l'on nomme veillée, ici, n'est pas un slogan : temps de mémoire, avec des noms.
Yvette : loin de rassembler, le slogan trop tôt dispersait les noms.
Hawa Diallo : Patrick refuse l'oubli poli.
Joël Mugisha : Aline analyse le discours : qui parle, pour qui, ce qu'il évite.
Rose Iradukunda : Lila ralentit.
Solange Mukamana : Solange pose une lanterne, pas une formule.
Karim Bamba : Sami se tait, pour une fois juste.
Félicie Ndayishimiye : Un chiffre, une trace : Yvette a nommé sept personnes ; Lila a gardé un silence ; le slogan trop lisse a été reculé.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de se souvenir, pas de se donner le change
Yvette : Mado écrit les sept prénoms.
Mado : Patrick Habimana entend, dans « plus jamais ça », ceci qui n'est pas dit : plus jamais ça trop seul permet de ne plus nommer
Sami : Autrement dit, une chronique C2 ralentit le slogan, rend les noms, refuse l'oubli poli
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un discours lu, une chronique — noms, silence, ce que le slogan évitait
Marc : une chronique de mémoire se juge à ce qu'elle n'a pas lissé.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le discours trop lisse d'un côté, la chronique d'Yvette de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Plus jamais ça : on notera la commodité d'un ça qui n'a plus à porter de prénom.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Les noms avant la formule'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une formule trop lisse pour les noms trop précis est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une formule trop lisse pour les noms trop précis n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Les noms avant la formule'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Analyser un discours de veillée et enregistrer une chronique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Les noms avant la formule », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Les noms avant la formule
On parle trop vite de la veillée sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu de travail de mémoire, une formule trop lisse pour les noms trop précis n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Yvette concède qu'une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Ce que l'on nomme veillée, ici, n'est pas un slogan : temps de mémoire, avec des noms.
Yvette : loin de rassembler, le slogan trop tôt dispersait les noms.
Patrick refuse l'oubli poli.
Aline analyse le discours : qui parle, pour qui, ce qu'il évite.
Lila ralentit.
Solange pose une lanterne, pas une formule.
Sami se tait, pour une fois juste.
Un chiffre, une trace : Yvette a nommé sept personnes ; Lila a gardé un silence ; le slogan trop lisse a été reculé.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de se souvenir, pas de se donner le change
Mado écrit les sept prénoms.
Patrick Habimana entend, dans « plus jamais ça », ceci qui n'est pas dit : plus jamais ça trop seul permet de ne plus nommer
Autrement dit, une chronique C2 ralentit le slogan, rend les noms, refuse l'oubli poli
La proposition qui reste debout est celle-ci : un discours lu, une chronique — noms, silence, ce que le slogan évitait
Marc : une chronique de mémoire se juge à ce qu'elle n'a pas lissé.
Nous clôturons sans fusionner les voix : le discours trop lisse d'un côté, la chronique d'Yvette de l'autre, et le point où elles refusent de se ressembler.
Signé : Yvette, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Les noms avant la formule'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : analyse d'un discours ; chronique de veillée ; mémoire.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on tienne lieu de travail de mémoire, une formule trop lisse pour les noms trop précis n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Yvette concède qu'une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Ce que l'on nomme veillée, ici, n'est pas un slogan : temps de mémoire, avec des noms.
Encore que l'on nomme, une formule trop lisse pour les noms trop précis n'est pas un détail.
Yvette concède qu'une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Autrement dit, une chronique C2 ralentit le slogan, rend les noms, refuse l'oubli poli
Il ressort qu'un discours lu, une chronique : noms, silence, ce que le slogan évitait
Patrick refuse l'oubli poli.
Solange pose une lanterne, pas une formule.
La proposition qui reste debout est celle-ci : un discours lu, une chronique — noms, silence, ce que le slogan évitait
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le discours trop lisse d'un côté, la chronique d'Yvette de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Les noms avant la formule'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Yvette transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Yvette concède qu'une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Les noms avant la formule'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Analyser un discours de veillée et enregistrer une chronique. Point : analyse d'un discours ; chronique de veillée ; mémoire.

Consigne
Imitez le texte de Yvette.

Support — Yvette — Les noms avant la formule
Yvette — Les noms avant la formule
On parle trop vite de la veillée sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu de travail de mémoire, une formule trop lisse pour les noms trop précis n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Yvette concède qu'une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Ce que l'on nomme veillée, ici, n'est pas un slogan : temps de mémoire, avec des noms.
Yvette : loin de rassembler, le slogan trop tôt dispersait les noms.
Solange pose une lanterne, pas une formule.
Sami se tait, pour une fois juste.
Mado écrit les sept prénoms.
La proposition qui reste debout est celle-ci : un discours lu, une chronique — noms, silence, ce que le slogan évitait
Marc : une chronique de mémoire se juge à ce qu'elle n'a pas lissé.
Nous clôturons sans fusionner les voix : le discours trop lisse d'un côté, la chronique d'Yvette de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on nomme, une formule trop lisse pour les noms trop précis n'est pas un détail.
Yvette concède qu'une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
une chronique C2 ralentit le slogan, rend les noms, refuse l'oubli poli
Yvette, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Les noms avant la formule'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Yvette sur « Les noms avant la formule » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Yvette sur « Les noms avant la formule » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Les noms avant la formule'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser analyse d'un discours ; chronique de veillée ; mémoire au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — analyse d'un discours ; chronique de veillée ; mémoire
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on nomme, une formule trop lisse pour les noms trop précis n'est pas un détail.
Yvette concède qu'une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Autrement dit, une chronique C2 ralentit le slogan, rend les noms, refuse l'oubli poli
Il ressort qu'un discours lu, une chronique : noms, silence, ce que le slogan évitait
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme veillée, ici, n'est pas un slogan : temps de mémoire, avec des noms.
Patrick refuse l'oubli poli.
Solange pose une lanterne, pas une formule.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au chronique pour de vrai genre, et Patrick Habimana demande un registre plus net.
Correction : On va au chronique vraiment, et Patrick Habimana demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Les noms avant la formule'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Analyser et rédiger le plan d'une plaidoirie inventée, sans procès d'État. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Plaidoirie sous le figuier
Lila Sow : Radio Figuier. On parle trop vite d'une plaidoirie au Bureau des Escales, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace le plan par la rumeur, un contexte trop bruyant pour une introduction nette n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande.
Aline Uwase : Ce que l'on nomme plaidoirie, ici, n'est pas un slogan : discours de demande, avec un plan.
Solange : il convient que l'on introduise les faits, encore que le fil ait déjà crié.
Hawa Diallo : Marc place la rumeur en note.
Joël Mugisha : Aline veut les textes de cour.
Rose Iradukunda : Lila n'enregistrera pas un spectacle.
Solange Mukamana : Patrick chronomètre l'introduction.
Karim Bamba : Yvette écoute comme si les noms étaient là.
Félicie Ndayishimiye : Un chiffre, une trace : Solange a tenu quatre parties ; reculé la rumeur en note ; lu l'introduction en trois minutes.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une justice de cour, pas d'un spectacle
Yvette : Dieudonné tient la porte.
Mado : Marc Nkurunziza entend, dans « l'opinion a déjà jugé », ceci qui n'est pas dit : l'opinion a déjà jugé invite à n'avoir plus de plan
Sami : Autrement dit, il convient que l'introduction nomme le contexte sans s'y noyer
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un plan — faits, textes, contexte, demande ; puis l'introduction lue
Léa : une plaidoirie C2 a un plan, ou n'est qu'un bruit.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le bruit du fil d'un côté, le plan de Solange de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : L'opinion a déjà jugé : on appréciera la modestie de ceux qui n'ont pas à ouvrir un dossier.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Plaidoirie sous le figuier'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un contexte trop bruyant pour une introduction nette est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un contexte trop bruyant pour une introduction nette n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Plaidoirie sous le figuier'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Analyser et rédiger le plan d'une plaidoirie inventée, sans procès d'État. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « La rumeur en note, pas en tête », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La rumeur en note, pas en tête
On parle trop vite d'une plaidoirie au Bureau des Escales, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le plan par la rumeur, un contexte trop bruyant pour une introduction nette n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande.
Ce que l'on nomme plaidoirie, ici, n'est pas un slogan : discours de demande, avec un plan.
Solange : il convient que l'on introduise les faits, encore que le fil ait déjà crié.
Marc place la rumeur en note.
Aline veut les textes de cour.
Lila n'enregistrera pas un spectacle.
Patrick chronomètre l'introduction.
Yvette écoute comme si les noms étaient là.
Un chiffre, une trace : Solange a tenu quatre parties ; reculé la rumeur en note ; lu l'introduction en trois minutes.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une justice de cour, pas d'un spectacle
Dieudonné tient la porte.
Marc Nkurunziza entend, dans « l'opinion a déjà jugé », ceci qui n'est pas dit : l'opinion a déjà jugé invite à n'avoir plus de plan
Autrement dit, il convient que l'introduction nomme le contexte sans s'y noyer
La proposition qui reste debout est celle-ci : un plan — faits, textes, contexte, demande ; puis l'introduction lue
Léa : une plaidoirie C2 a un plan, ou n'est qu'un bruit.
Nous clôturons sans fusionner les voix : le bruit du fil d'un côté, le plan de Solange de l'autre, et le point où elles refusent de se ressembler.
Signé : Solange Mukamana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Plaidoirie sous le figuier'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : plan d'une plaidoirie ; contexte et opinion ; justice de cour.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace le plan par la rumeur, un contexte trop bruyant pour une introduction nette n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande.
Ce que l'on nomme plaidoirie, ici, n'est pas un slogan : discours de demande, avec un plan.
Encore que l'on introduise, un contexte trop bruyant pour une introduction nette n'est pas un détail.
Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande.
Autrement dit, il convient que l'introduction nomme le contexte sans s'y noyer
Il ressort qu'un plan : faits, textes, contexte, demande ; puis l'introduction lue
Marc place la rumeur en note.
Patrick chronomètre l'introduction.
La proposition qui reste debout est celle-ci : un plan — faits, textes, contexte, demande ; puis l'introduction lue
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le bruit du fil d'un côté, le plan de Solange de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Plaidoirie sous le figuier'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Analyser et rédiger le plan d'une plaidoirie inventée, sans procès d'État. Point : plan d'une plaidoirie ; contexte et opinion ; justice de cour.

Consigne
Imitez le texte de Solange Mukamana.

Support — Solange Mukamana — La rumeur en note, pas en tête
Solange Mukamana — La rumeur en note, pas en tête
On parle trop vite d'une plaidoirie au Bureau des Escales, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le plan par la rumeur, un contexte trop bruyant pour une introduction nette n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande.
Ce que l'on nomme plaidoirie, ici, n'est pas un slogan : discours de demande, avec un plan.
Solange : il convient que l'on introduise les faits, encore que le fil ait déjà crié.
Patrick chronomètre l'introduction.
Yvette écoute comme si les noms étaient là.
Dieudonné tient la porte.
La proposition qui reste debout est celle-ci : un plan — faits, textes, contexte, demande ; puis l'introduction lue
Léa : une plaidoirie C2 a un plan, ou n'est qu'un bruit.
Nous clôturons sans fusionner les voix : le bruit du fil d'un côté, le plan de Solange de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on introduise, un contexte trop bruyant pour une introduction nette n'est pas un détail.
Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il convient que l'introduction nomme le contexte sans s'y noyer
Solange Mukamana, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Plaidoirie sous le figuier'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Solange Mukamana sur « Plaidoirie sous le figuier » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Solange Mukamana sur « Plaidoirie sous le figuier » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Plaidoirie sous le figuier'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Rédiger l'essai promis : intérêt d'un support pour une mémoire de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Essai du support
Lila Sow : Radio Figuier. On parle trop vite de l'essai d'Aline relu par la cour, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on dispense de l'angle mort, un donc trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Aline Uwase : Ce que l'on nomme intérêt, ici, n'est pas un slogan : ce que le support permet, à démontrer.
Patrick : selon le tableau, l'on déduit plus vite ; d'après Yvette, l'on nomme moins.
Hawa Diallo : Il ressort qu'un essai tient les deux.
Joël Mugisha : Aline accepte l'angle.
Rose Iradukunda : Lila lira lentement.
Solange Mukamana : Solange veut l'usage concret.
Karim Bamba : Sami s'ennuie d'un tampon.
Félicie Ndayishimiye : Un chiffre, une trace : Patrick a gardé l'intérêt ; nommé l'angle ; proposé un usage ; refusé le donc.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'un essai, pas d'un tampon
Yvette : Mado glisse une phrase sur le donc.
Mado : Aline Uwase entend, dans « c'est pédagogique donc c'est bien », ceci qui n'est pas dit : donc c'est bien évite l'essai véritable
Sami : Autrement dit, selon le support, on déduit ; d'après les noms, on doute ; il ressort qu'il faut les deux
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un essai de vingt lignes — intérêt, angle, usage, limite
Marc : un essai C2 se relit, il ne se tamponne pas.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le brouillon trop sûr d'un côté, l'essai de Patrick de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : C'est pédagogique donc c'est bien : syllogisme dont on aimerait voir la mineure.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Essai du support'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un donc trop généreux est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un donc trop généreux n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Essai du support'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rédiger l'essai promis : intérêt d'un support pour une mémoire de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le donc n'est pas un essai », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le donc n'est pas un essai
On parle trop vite de l'essai d'Aline relu par la cour, comme si le mot dispensait d'en examiner le prix.
Encore que l'on dispense de l'angle mort, un donc trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Ce que l'on nomme intérêt, ici, n'est pas un slogan : ce que le support permet, à démontrer.
Patrick : selon le tableau, l'on déduit plus vite ; d'après Yvette, l'on nomme moins.
Il ressort qu'un essai tient les deux.
Aline accepte l'angle.
Lila lira lentement.
Solange veut l'usage concret.
Sami s'ennuie d'un tampon.
Un chiffre, une trace : Patrick a gardé l'intérêt ; nommé l'angle ; proposé un usage ; refusé le donc.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'un essai, pas d'un tampon
Mado glisse une phrase sur le donc.
Aline Uwase entend, dans « c'est pédagogique donc c'est bien », ceci qui n'est pas dit : donc c'est bien évite l'essai véritable
Autrement dit, selon le support, on déduit ; d'après les noms, on doute ; il ressort qu'il faut les deux
La proposition qui reste debout est celle-ci : un essai de vingt lignes — intérêt, angle, usage, limite
Marc : un essai C2 se relit, il ne se tamponne pas.
Nous clôturons sans fusionner les voix : le brouillon trop sûr d'un côté, l'essai de Patrick de l'autre, et le point où elles refusent de se ressembler.
Signé : Patrick Habimana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Essai du support'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : essai argumenté ; déduction ; pédagogie de mémoire.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on dispense de l'angle mort, un donc trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Ce que l'on nomme intérêt, ici, n'est pas un slogan : ce que le support permet, à démontrer.
Encore que l'on examine, un donc trop généreux n'est pas un détail.
Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Autrement dit, selon le support, on déduit ; d'après les noms, on doute ; il ressort qu'il faut les deux
Il ressort qu'un essai de vingt lignes : intérêt, angle, usage, limite
Il ressort qu'un essai tient les deux.
Solange veut l'usage concret.
La proposition qui reste debout est celle-ci : un essai de vingt lignes — intérêt, angle, usage, limite
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le brouillon trop sûr d'un côté, l'essai de Patrick de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Essai du support'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Rédiger l'essai promis : intérêt d'un support pour une mémoire de cour. Point : essai argumenté ; déduction ; pédagogie de mémoire.

Consigne
Imitez le texte de Patrick Habimana.

Support — Patrick Habimana — Le donc n'est pas un essai
Patrick Habimana — Le donc n'est pas un essai
On parle trop vite de l'essai d'Aline relu par la cour, comme si le mot dispensait d'en examiner le prix.
Encore que l'on dispense de l'angle mort, un donc trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Ce que l'on nomme intérêt, ici, n'est pas un slogan : ce que le support permet, à démontrer.
Patrick : selon le tableau, l'on déduit plus vite ; d'après Yvette, l'on nomme moins.
Solange veut l'usage concret.
Sami s'ennuie d'un tampon.
Mado glisse une phrase sur le donc.
La proposition qui reste debout est celle-ci : un essai de vingt lignes — intérêt, angle, usage, limite
Marc : un essai C2 se relit, il ne se tamponne pas.
Nous clôturons sans fusionner les voix : le brouillon trop sûr d'un côté, l'essai de Patrick de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on examine, un donc trop généreux n'est pas un détail.
Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
selon le support, on déduit ; d'après les noms, on doute ; il ressort qu'il faut les deux
Patrick Habimana, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Essai du support'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Patrick Habimana sur « Essai du support » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Patrick Habimana sur « Essai du support » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Essai du support'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser essai argumenté ; déduction ; pédagogie de mémoire au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — essai argumenté ; déduction ; pédagogie de mémoire
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on examine, un donc trop généreux n'est pas un détail.
Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Autrement dit, selon le support, on déduit ; d'après les noms, on doute ; il ressort qu'il faut les deux
Il ressort qu'un essai de vingt lignes : intérêt, angle, usage, limite
Piège : fusionner les sources au lieu des attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme intérêt, ici, n'est pas un slogan : ce que le support permet, à démontrer.
Il ressort qu'un essai tient les deux.
Solange veut l'usage concret.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au usage pour de vrai genre, et Aline Uwase demande un registre plus net.
Correction : On va au usage vraiment, et Aline Uwase demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Essai du support'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Enregistrer la chronique finale de mémoire, C2. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Chronique de veillée
Lila Sow : Radio Figuier. On parle trop vite de la chronique que Lila n'adoucira pas, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme la veillée en décor, un bel qui n'a plus de prénoms n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Lila Sow concède qu'une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Aline Uwase : Ce que l'on nomme cérémonie, ici, n'est pas un slogan : forme, trop vite dite belle.
Lila : loin d'adoucir, j'ai coupé le bel.
Hawa Diallo : Yvette entend les prénoms.
Joël Mugisha : Aline accepte le silence.
Rose Iradukunda : Patrick refuse la fête.
Solange Mukamana : Sami se tait encore.
Karim Bamba : Mado écrit juste.
Félicie Ndayishimiye : Un chiffre, une trace : Lila a lu sept noms ; gardé huit secondes ; coupé belle cérémonie.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une voix de radio qui ne se donne pas le change
Yvette : Solange pose la lanterne.
Mado : Yvette entend, dans « une belle cérémonie », ceci qui n'est pas dit : belle cérémonie est déjà un oubli poli
Sami : Autrement dit, loin d'être belle, la veillée fut juste, ce qui est autre chose, et plus difficile
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une chronique de quatre minutes — noms, un silence, un refus du bel
Marc : une chronique C2 se juge à ce qu'elle n'a pas trop poli.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le rush trop soigné d'un côté, la chronique retenue de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Une belle cérémonie : on reconnaît le compliment de ceux qui n'avaient personne à nommer.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Chronique de veillée'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un bel qui n'a plus de prénoms est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un bel qui n'a plus de prénoms n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Chronique de veillée'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Enregistrer la chronique finale de mémoire, C2. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Juste, pas belle », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Juste, pas belle
On parle trop vite de la chronique que Lila n'adoucira pas, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme la veillée en décor, un bel qui n'a plus de prénoms n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède qu'une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Ce que l'on nomme cérémonie, ici, n'est pas un slogan : forme, trop vite dite belle.
Lila : loin d'adoucir, j'ai coupé le bel.
Yvette entend les prénoms.
Aline accepte le silence.
Patrick refuse la fête.
Sami se tait encore.
Mado écrit juste.
Un chiffre, une trace : Lila a lu sept noms ; gardé huit secondes ; coupé belle cérémonie.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une voix de radio qui ne se donne pas le change
Solange pose la lanterne.
Yvette entend, dans « une belle cérémonie », ceci qui n'est pas dit : belle cérémonie est déjà un oubli poli
Autrement dit, loin d'être belle, la veillée fut juste, ce qui est autre chose, et plus difficile
La proposition qui reste debout est celle-ci : une chronique de quatre minutes — noms, un silence, un refus du bel
Marc : une chronique C2 se juge à ce qu'elle n'a pas trop poli.
Nous clôturons sans fusionner les voix : le rush trop soigné d'un côté, la chronique retenue de l'autre, et le point où elles refusent de se ressembler.
Signé : Lila Sow, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Chronique de veillée'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : voix de chronique ; noms ; silence.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme la veillée en décor, un bel qui n'a plus de prénoms n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède qu'une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Ce que l'on nomme cérémonie, ici, n'est pas un slogan : forme, trop vite dite belle.
Encore que l'on adoucisse, un bel qui n'a plus de prénoms n'est pas un détail.
Lila Sow concède qu'une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Autrement dit, loin d'être belle, la veillée fut juste, ce qui est autre chose, et plus difficile
Il ressort qu'une chronique de quatre minutes : noms, un silence, un refus du bel
Yvette entend les prénoms.
Sami se tait encore.
La proposition qui reste debout est celle-ci : une chronique de quatre minutes — noms, un silence, un refus du bel
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le rush trop soigné d'un côté, la chronique retenue de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Chronique de veillée'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Lila Sow transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Lila Sow concède qu'une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Chronique de veillée'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Enregistrer la chronique finale de mémoire, C2. Point : voix de chronique ; noms ; silence.

Consigne
Imitez le texte de Lila Sow.

Support — Lila Sow — Juste, pas belle
Lila Sow — Juste, pas belle
On parle trop vite de la chronique que Lila n'adoucira pas, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme la veillée en décor, un bel qui n'a plus de prénoms n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède qu'une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Ce que l'on nomme cérémonie, ici, n'est pas un slogan : forme, trop vite dite belle.
Lila : loin d'adoucir, j'ai coupé le bel.
Sami se tait encore.
Mado écrit juste.
Solange pose la lanterne.
La proposition qui reste debout est celle-ci : une chronique de quatre minutes — noms, un silence, un refus du bel
Marc : une chronique C2 se juge à ce qu'elle n'a pas trop poli.
Nous clôturons sans fusionner les voix : le rush trop soigné d'un côté, la chronique retenue de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on adoucisse, un bel qui n'a plus de prénoms n'est pas un détail.
Lila Sow concède qu'une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
loin d'être belle, la veillée fut juste, ce qui est autre chose, et plus difficile
Lila Sow, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Chronique de veillée'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Lila Sow sur « Chronique de veillée » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Lila Sow sur « Chronique de veillée » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Chronique de veillée'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser voix de chronique ; noms ; silence au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — voix de chronique ; noms ; silence
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on adoucisse, un bel qui n'a plus de prénoms n'est pas un détail.
Lila Sow concède qu'une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Autrement dit, loin d'être belle, la veillée fut juste, ce qui est autre chose, et plus difficile
Il ressort qu'une chronique de quatre minutes : noms, un silence, un refus du bel
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme cérémonie, ici, n'est pas un slogan : forme, trop vite dite belle.
Yvette entend les prénoms.
Sami se tait encore.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au rush pour de vrai genre, et Yvette demande un registre plus net.
Correction : On va au rush vraiment, et Yvette demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Ce que le figuier se souvient'
  AND s.title = 'Chronique de veillée'
  AND l.competency = 'EL';

-- C2 — Cultures croisées
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Rédiger un article qui exprime implicitement une position sur l'accès à la Salle. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Culture partagée
Lila Sow : Radio Figuier. On parle trop vite de l'accès trop cher à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on dispense d'ouvrir vraiment la porte, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Hawa Diallo concède qu'un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Aline Uwase : Ce que l'on nomme accessibilité, ici, n'est pas un slogan : possibilité réelle d'entrer.
Hawa : il ne s'agirait que d'un détail, le tarif, à entendre l'affiche.
Hawa Diallo : Loin d'ouvrir, le mot généreux fermait plus net.
Joël Mugisha : Rose coud trop près de la porte.
Aline : l'implicite se justifie par l'écart.
Solange Mukamana : Joël n'entre pas sous la pluie.
Karim Bamba : Lila lira sans coller un slogan contraire.
Félicie Ndayishimiye : Un chiffre, une trace : Hawa a cité le tarif ; la rampe absente ; le mot généreux ; zéro cri.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une position, pas d'une affiche contraire
Yvette : Patrick veut les faits.
Mado : Rose Iradukunda entend, dans « la culture est à tout le monde », ceci qui n'est pas dit : à tout le monde, sans rampe ni tarif, est une invitation à se taire
Sami : Autrement dit, l'article ne criera pas : il décrira la porte, le tarif, le mot, et l'écart fera le travail
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un article implicite — faits, écart, zéro slogan retourné
Marc : une position C2 peut ne pas crier, elle doit se lire.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'affiche trop généreuse d'un côté, l'article d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : La culture est à tout le monde : on vérifiera, par politesse, le tarif et la rampe.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Culture partagée'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un billet trop haut pour Hawa, un mot trop généreux est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Culture partagée'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rédiger un article qui exprime implicitement une position sur l'accès à la Salle. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le mot, la porte, l'écart », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le mot, la porte, l'écart
On parle trop vite de l'accès trop cher à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on dispense d'ouvrir vraiment la porte, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède qu'un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Ce que l'on nomme accessibilité, ici, n'est pas un slogan : possibilité réelle d'entrer.
Hawa : il ne s'agirait que d'un détail, le tarif, à entendre l'affiche.
Loin d'ouvrir, le mot généreux fermait plus net.
Rose coud trop près de la porte.
Aline : l'implicite se justifie par l'écart.
Joël n'entre pas sous la pluie.
Lila lira sans coller un slogan contraire.
Un chiffre, une trace : Hawa a cité le tarif ; la rampe absente ; le mot généreux ; zéro cri.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une position, pas d'une affiche contraire
Patrick veut les faits.
Rose Iradukunda entend, dans « la culture est à tout le monde », ceci qui n'est pas dit : à tout le monde, sans rampe ni tarif, est une invitation à se taire
Autrement dit, l'article ne criera pas : il décrira la porte, le tarif, le mot, et l'écart fera le travail
La proposition qui reste debout est celle-ci : un article implicite — faits, écart, zéro slogan retourné
Marc : une position C2 peut ne pas crier, elle doit se lire.
Nous clôturons sans fusionner les voix : l'affiche trop généreuse d'un côté, l'article d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Signé : Hawa Diallo, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Culture partagée'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : implicite ; accessibilité ; position non criée.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on dispense d'ouvrir vraiment la porte, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède qu'un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Ce que l'on nomme accessibilité, ici, n'est pas un slogan : possibilité réelle d'entrer.
Encore que l'on ouvre, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail.
Hawa Diallo concède qu'un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Autrement dit, l'article ne criera pas : il décrira la porte, le tarif, le mot, et l'écart fera le travail
Il ressort qu'un article implicite : faits, écart, zéro slogan retourné
Loin d'ouvrir, le mot généreux fermait plus net.
Joël n'entre pas sous la pluie.
La proposition qui reste debout est celle-ci : un article implicite — faits, écart, zéro slogan retourné
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'affiche trop généreuse d'un côté, l'article d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Culture partagée'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Hawa Diallo transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Hawa Diallo concède qu'un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Culture partagée'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Rédiger un article qui exprime implicitement une position sur l'accès à la Salle. Point : implicite ; accessibilité ; position non criée.

Consigne
Imitez le texte de Hawa Diallo.

Support — Hawa Diallo — Le mot, la porte, l'écart
Hawa Diallo — Le mot, la porte, l'écart
On parle trop vite de l'accès trop cher à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on dispense d'ouvrir vraiment la porte, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède qu'un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Ce que l'on nomme accessibilité, ici, n'est pas un slogan : possibilité réelle d'entrer.
Hawa : il ne s'agirait que d'un détail, le tarif, à entendre l'affiche.
Joël n'entre pas sous la pluie.
Lila lira sans coller un slogan contraire.
Patrick veut les faits.
La proposition qui reste debout est celle-ci : un article implicite — faits, écart, zéro slogan retourné
Marc : une position C2 peut ne pas crier, elle doit se lire.
Nous clôturons sans fusionner les voix : l'affiche trop généreuse d'un côté, l'article d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on ouvre, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail.
Hawa Diallo concède qu'un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
l'article ne criera pas : il décrira la porte, le tarif, le mot, et l'écart fera le travail
Hawa Diallo, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Culture partagée'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Hawa Diallo sur « Culture partagée » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Hawa Diallo sur « Culture partagée » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Culture partagée'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser implicite ; accessibilité ; position non criée au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — implicite ; accessibilité ; position non criée
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on ouvre, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail.
Hawa Diallo concède qu'un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Autrement dit, l'article ne criera pas : il décrira la porte, le tarif, le mot, et l'écart fera le travail
Il ressort qu'un article implicite : faits, écart, zéro slogan retourné
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme accessibilité, ici, n'est pas un slogan : possibilité réelle d'entrer.
Loin d'ouvrir, le mot généreux fermait plus net.
Joël n'entre pas sous la pluie.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au implicite pour de vrai genre, et Rose Iradukunda demande un registre plus net.
Correction : On va au implicite vraiment, et Rose Iradukunda demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Culture partagée'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Expliquer une scène comique de cour sans en faire une recette, ni un procès. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Qui paie le rire
Lila Sow : Radio Figuier. On parle trop vite d'un sketch trop sûr de ses cibles, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on tienne lieu de droit de blesser, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Sami concède qu'un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Aline Uwase : Ce que l'on nomme ressort, ici, n'est pas un slogan : mécanisme comique, à expliquer.
Sami : loin de tout permettre, l'humour se juge à la cible.
Hawa Diallo : Hawa n'a pas ri, et le non compte.
Joël Mugisha : Aline explique le quiproquo sans recette.
Rose Iradukunda : Lila n'enregistrera pas la version trop dure.
Solange Mukamana : Yvette rit du quiproquo, pas de la bouche trop seule.
Karim Bamba : Patrick refuse le succès comme preuve.
Félicie Ndayishimiye : Un chiffre, une trace : Sami a raturé une cible ; gardé un quiproquo ; Yvette a ri ; Hawa non, et c'est noté.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de rire avec une cour, pas contre une bouche trop seule
Yvette : Mado note le ressort.
Mado : Hawa Diallo entend, dans « c'est de l'humour », ceci qui n'est pas dit : c'est de l'humour arrive trop souvent après le geste qui a déjà fait mal
Sami : Autrement dit, expliquer un ressort, c'est dire qui paie le rire, et si le succès n'est qu'un confort
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une explication — quiproquo, cible, limite, version raturée
Marc : une scène comique C2 a une limite, ou n'est qu'un confort.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le sketch trop dur d'un côté, la version raturée de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : C'est de l'humour : on reconnaît le sauf-conduit de ceux qui n'ont pas à essuyer.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Qui paie le rire'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un rire qui n'a plus d'oreille pour Hawa est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un rire qui n'a plus d'oreille pour Hawa n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Qui paie le rire'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Expliquer une scène comique de cour sans en faire une recette, ni un procès. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Qui paie le rire », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Qui paie le rire
On parle trop vite d'un sketch trop sûr de ses cibles, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu de droit de blesser, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède qu'un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Ce que l'on nomme ressort, ici, n'est pas un slogan : mécanisme comique, à expliquer.
Sami : loin de tout permettre, l'humour se juge à la cible.
Hawa n'a pas ri, et le non compte.
Aline explique le quiproquo sans recette.
Lila n'enregistrera pas la version trop dure.
Yvette rit du quiproquo, pas de la bouche trop seule.
Patrick refuse le succès comme preuve.
Un chiffre, une trace : Sami a raturé une cible ; gardé un quiproquo ; Yvette a ri ; Hawa non, et c'est noté.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de rire avec une cour, pas contre une bouche trop seule
Mado note le ressort.
Hawa Diallo entend, dans « c'est de l'humour », ceci qui n'est pas dit : c'est de l'humour arrive trop souvent après le geste qui a déjà fait mal
Autrement dit, expliquer un ressort, c'est dire qui paie le rire, et si le succès n'est qu'un confort
La proposition qui reste debout est celle-ci : une explication — quiproquo, cible, limite, version raturée
Marc : une scène comique C2 a une limite, ou n'est qu'un confort.
Nous clôturons sans fusionner les voix : le sketch trop dur d'un côté, la version raturée de l'autre, et le point où elles refusent de se ressembler.
Signé : Sami, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Qui paie le rire'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : ressorts comiques ; humour ; succès trop facile.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on tienne lieu de droit de blesser, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède qu'un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Ce que l'on nomme ressort, ici, n'est pas un slogan : mécanisme comique, à expliquer.
Encore que l'on rature, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail.
Sami concède qu'un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Autrement dit, expliquer un ressort, c'est dire qui paie le rire, et si le succès n'est qu'un confort
Il ressort qu'une explication : quiproquo, cible, limite, version raturée
Hawa n'a pas ri, et le non compte.
Yvette rit du quiproquo, pas de la bouche trop seule.
La proposition qui reste debout est celle-ci : une explication — quiproquo, cible, limite, version raturée
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le sketch trop dur d'un côté, la version raturée de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Qui paie le rire'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Sami transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Sami concède qu'un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Qui paie le rire'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Expliquer une scène comique de cour sans en faire une recette, ni un procès. Point : ressorts comiques ; humour ; succès trop facile.

Consigne
Imitez le texte de Sami.

Support — Sami — Qui paie le rire
Sami — Qui paie le rire
On parle trop vite d'un sketch trop sûr de ses cibles, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu de droit de blesser, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède qu'un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Ce que l'on nomme ressort, ici, n'est pas un slogan : mécanisme comique, à expliquer.
Sami : loin de tout permettre, l'humour se juge à la cible.
Yvette rit du quiproquo, pas de la bouche trop seule.
Patrick refuse le succès comme preuve.
Mado note le ressort.
La proposition qui reste debout est celle-ci : une explication — quiproquo, cible, limite, version raturée
Marc : une scène comique C2 a une limite, ou n'est qu'un confort.
Nous clôturons sans fusionner les voix : le sketch trop dur d'un côté, la version raturée de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on rature, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail.
Sami concède qu'un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
expliquer un ressort, c'est dire qui paie le rire, et si le succès n'est qu'un confort
Sami, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Qui paie le rire'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Sami sur « Qui paie le rire » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Sami sur « Qui paie le rire » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Qui paie le rire'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser ressorts comiques ; humour ; succès trop facile au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — ressorts comiques ; humour ; succès trop facile
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on rature, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail.
Sami concède qu'un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Autrement dit, expliquer un ressort, c'est dire qui paie le rire, et si le succès n'est qu'un confort
Il ressort qu'une explication : quiproquo, cible, limite, version raturée
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme ressort, ici, n'est pas un slogan : mécanisme comique, à expliquer.
Hawa n'a pas ri, et le non compte.
Yvette rit du quiproquo, pas de la bouche trop seule.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au quiproquo pour de vrai genre, et Hawa Diallo demande un registre plus net.
Correction : On va au quiproquo vraiment, et Hawa Diallo demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Qui paie le rire'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Débattre d'un lin trop vite porté comme décor, sans procès d'intention plat. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le lin trop vite porté
Lila Sow : Radio Figuier. On parle trop vite d'un lin de Rose trop vite copié, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on dispense de demander à Rose, une tendance qui vide un signe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas.
Aline Uwase : Ce que l'on nomme signe, ici, n'est pas un slogan : motif chargé, distinct d'un décor.
Rose : du fait que le lin plaît, si bien que l'on copie, il ne s'ensuit pas un droit.
Hawa Diallo : Léa ouvre le débat, pas le procès plat.
Joël Mugisha : Aline exige la permission comme mot.
Rose Iradukunda : Karim parle de prix.
Solange Mukamana : Sami avait porté trop vite ; il retire.
Karim Bamba : Lila n'adoucira pas.
Félicie Ndayishimiye : Un chiffre, une trace : Rose a vu six copies trop nettes ; zéro demande ; un hommage trop tardif.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'un signe, pas d'une mode d'affiche
Yvette : Patrick refuse hommage comme sauf-conduit.
Mado : Léa Niyonzima entend, dans « c'est un hommage », ceci qui n'est pas dit : hommage trop vite dit évite le prix, la source, la permission
Sami : Autrement dit, du fait que le lin circule, il ne s'ensuit pas qu'il soit un décor libre
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un débat — inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)
Marc : un débat C2 nomme le vide, pas seulement l'intention.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les copies trop nettes d'un côté, la prise de parole de Rose de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : C'est un hommage : on vérifiera s'il a traversé, par hasard, une caisse.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Le lin trop vite porté'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une tendance qui vide un signe est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une tendance qui vide un signe n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Le lin trop vite porté'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Débattre d'un lin trop vite porté comme décor, sans procès d'intention plat. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Un signe n'est pas un décor », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Un signe n'est pas un décor
On parle trop vite d'un lin de Rose trop vite copié, comme si le mot dispensait d'en examiner le prix.
Encore que l'on dispense de demander à Rose, une tendance qui vide un signe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas.
Ce que l'on nomme signe, ici, n'est pas un slogan : motif chargé, distinct d'un décor.
Rose : du fait que le lin plaît, si bien que l'on copie, il ne s'ensuit pas un droit.
Léa ouvre le débat, pas le procès plat.
Aline exige la permission comme mot.
Karim parle de prix.
Sami avait porté trop vite ; il retire.
Lila n'adoucira pas.
Un chiffre, une trace : Rose a vu six copies trop nettes ; zéro demande ; un hommage trop tardif.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'un signe, pas d'une mode d'affiche
Patrick refuse hommage comme sauf-conduit.
Léa Niyonzima entend, dans « c'est un hommage », ceci qui n'est pas dit : hommage trop vite dit évite le prix, la source, la permission
Autrement dit, du fait que le lin circule, il ne s'ensuit pas qu'il soit un décor libre
La proposition qui reste debout est celle-ci : un débat — inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)
Marc : un débat C2 nomme le vide, pas seulement l'intention.
Nous clôturons sans fusionner les voix : les copies trop nettes d'un côté, la prise de parole de Rose de l'autre, et le point où elles refusent de se ressembler.
Signé : Rose Iradukunda, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Le lin trop vite porté'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : débat ; appropriation ; tendance trop vite portée.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on dispense de demander à Rose, une tendance qui vide un signe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas.
Ce que l'on nomme signe, ici, n'est pas un slogan : motif chargé, distinct d'un décor.
Encore que l'on demande, une tendance qui vide un signe n'est pas un détail.
Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas.
Autrement dit, du fait que le lin circule, il ne s'ensuit pas qu'il soit un décor libre
Il ressort qu'un débat : inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)
Léa ouvre le débat, pas le procès plat.
Sami avait porté trop vite ; il retire.
La proposition qui reste debout est celle-ci : un débat — inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les copies trop nettes d'un côté, la prise de parole de Rose de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Le lin trop vite porté'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Débattre d'un lin trop vite porté comme décor, sans procès d'intention plat. Point : débat ; appropriation ; tendance trop vite portée.

Consigne
Imitez le texte de Rose Iradukunda.

Support — Rose Iradukunda — Un signe n'est pas un décor
Rose Iradukunda — Un signe n'est pas un décor
On parle trop vite d'un lin de Rose trop vite copié, comme si le mot dispensait d'en examiner le prix.
Encore que l'on dispense de demander à Rose, une tendance qui vide un signe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas.
Ce que l'on nomme signe, ici, n'est pas un slogan : motif chargé, distinct d'un décor.
Rose : du fait que le lin plaît, si bien que l'on copie, il ne s'ensuit pas un droit.
Sami avait porté trop vite ; il retire.
Lila n'adoucira pas.
Patrick refuse hommage comme sauf-conduit.
La proposition qui reste debout est celle-ci : un débat — inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)
Marc : un débat C2 nomme le vide, pas seulement l'intention.
Nous clôturons sans fusionner les voix : les copies trop nettes d'un côté, la prise de parole de Rose de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on demande, une tendance qui vide un signe n'est pas un détail.
Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
du fait que le lin circule, il ne s'ensuit pas qu'il soit un décor libre
Rose Iradukunda, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Le lin trop vite porté'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Rose Iradukunda sur « Le lin trop vite porté » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Rose Iradukunda sur « Le lin trop vite porté » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Le lin trop vite porté'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Raconter une expérience interculturelle au Seuil, détaillée, sans figer l'autre. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Récit interculturel
Lila Sow : Radio Figuier. On parle trop vite des premiers mois d'Hawa au Pavillon, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on fige Hawa en exemple, un récit trop typique pour rester une vie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Aline Uwase : Ce que l'on nomme malentendu, ici, n'est pas un slogan : écart de lecture, corrigeable.
Patrick Habimana : Hawa avait déjà posé la valise quand on lui a dit chez eux.
Hawa Diallo : Dieudonné avait cru bien faire avec le thé trop tôt.
Joël Mugisha : Il ressort deux corrections, pas une leçon.
Rose Iradukunda : Aline refuse l'ethnologie de banc.
Solange Mukamana : Lila n'adoucira pas le eux.
Karim Bamba : Rose coud un ourlet trop large encore.
Félicie Ndayishimiye : Un chiffre, une trace : Hawa a daté onze semaines ; trois malentendus ; deux corrections ; zéro essence.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une personne, pas d'une vitrine culturelle
Yvette : Patrick veut les onze semaines.
Mado : Dieudonné Hakizimana entend, dans « chez eux c'est comme ça », ceci qui n'est pas dit : chez eux c'est comme ça évite de dire chez nous aussi, et moi
Sami : Autrement dit, selon Hawa, la clé manquait ; d'après Dieudonné, le thé était trop tôt ; il ressort une vie, pas un type
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un récit — dates, gestes, malentendus, corrections, zéro chez eux trop large
Marc : un récit C2 se juge à ce qu'il n'a pas figé.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les notes trop typiques d'un voisin d'un côté, le récit d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Chez eux c'est comme ça : on admirera la géographie, si commode, du eux.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Récit interculturel'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un récit trop typique pour rester une vie est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un récit trop typique pour rester une vie n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Récit interculturel'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Raconter une expérience interculturelle au Seuil, détaillée, sans figer l'autre. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Une vie, pas un type », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Une vie, pas un type
On parle trop vite des premiers mois d'Hawa au Pavillon, comme si le mot dispensait d'en examiner le prix.
Encore que l'on fige Hawa en exemple, un récit trop typique pour rester une vie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Ce que l'on nomme malentendu, ici, n'est pas un slogan : écart de lecture, corrigeable.
Hawa avait déjà posé la valise quand on lui a dit chez eux.
Dieudonné avait cru bien faire avec le thé trop tôt.
Il ressort deux corrections, pas une leçon.
Aline refuse l'ethnologie de banc.
Lila n'adoucira pas le eux.
Rose coud un ourlet trop large encore.
Un chiffre, une trace : Hawa a daté onze semaines ; trois malentendus ; deux corrections ; zéro essence.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une personne, pas d'une vitrine culturelle
Patrick veut les onze semaines.
Dieudonné Hakizimana entend, dans « chez eux c'est comme ça », ceci qui n'est pas dit : chez eux c'est comme ça évite de dire chez nous aussi, et moi
Autrement dit, selon Hawa, la clé manquait ; d'après Dieudonné, le thé était trop tôt ; il ressort une vie, pas un type
La proposition qui reste debout est celle-ci : un récit — dates, gestes, malentendus, corrections, zéro chez eux trop large
Marc : un récit C2 se juge à ce qu'il n'a pas figé.
Nous clôturons sans fusionner les voix : les notes trop typiques d'un voisin d'un côté, le récit d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Signé : Hawa Diallo, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Récit interculturel'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : récit détaillé au passé ; différences ; sans ethnologiser.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on fige Hawa en exemple, un récit trop typique pour rester une vie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Ce que l'on nomme malentendu, ici, n'est pas un slogan : écart de lecture, corrigeable.
Encore que l'on raconte, un récit trop typique pour rester une vie n'est pas un détail.
Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Autrement dit, selon Hawa, la clé manquait ; d'après Dieudonné, le thé était trop tôt ; il ressort une vie, pas un type
Il ressort qu'un récit : dates, gestes, malentendus, corrections, zéro chez eux trop large
Dieudonné avait cru bien faire avec le thé trop tôt.
Lila n'adoucira pas le eux.
La proposition qui reste debout est celle-ci : un récit — dates, gestes, malentendus, corrections, zéro chez eux trop large
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les notes trop typiques d'un voisin d'un côté, le récit d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Récit interculturel'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Raconter une expérience interculturelle au Seuil, détaillée, sans figer l'autre. Point : récit détaillé au passé ; différences ; sans ethnologiser.

Consigne
Imitez le texte de Hawa Diallo.

Support — Hawa Diallo — Une vie, pas un type
Hawa Diallo — Une vie, pas un type
On parle trop vite des premiers mois d'Hawa au Pavillon, comme si le mot dispensait d'en examiner le prix.
Encore que l'on fige Hawa en exemple, un récit trop typique pour rester une vie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Ce que l'on nomme malentendu, ici, n'est pas un slogan : écart de lecture, corrigeable.
Hawa avait déjà posé la valise quand on lui a dit chez eux.
Lila n'adoucira pas le eux.
Rose coud un ourlet trop large encore.
Patrick veut les onze semaines.
La proposition qui reste debout est celle-ci : un récit — dates, gestes, malentendus, corrections, zéro chez eux trop large
Marc : un récit C2 se juge à ce qu'il n'a pas figé.
Nous clôturons sans fusionner les voix : les notes trop typiques d'un voisin d'un côté, le récit d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on raconte, un récit trop typique pour rester une vie n'est pas un détail.
Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
selon Hawa, la clé manquait ; d'après Dieudonné, le thé était trop tôt ; il ressort une vie, pas un type
Hawa Diallo, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Récit interculturel'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Hawa Diallo sur « Récit interculturel » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Hawa Diallo sur « Récit interculturel » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Récit interculturel'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser récit détaillé au passé ; différences ; sans ethnologiser au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — récit détaillé au passé ; différences ; sans ethnologiser
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on raconte, un récit trop typique pour rester une vie n'est pas un détail.
Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Autrement dit, selon Hawa, la clé manquait ; d'après Dieudonné, le thé était trop tôt ; il ressort une vie, pas un type
Il ressort qu'un récit : dates, gestes, malentendus, corrections, zéro chez eux trop large
Piège : fusionner les sources au lieu des attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme malentendu, ici, n'est pas un slogan : écart de lecture, corrigeable.
Dieudonné avait cru bien faire avec le thé trop tôt.
Lila n'adoucira pas le eux.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au récit pour de vrai genre, et Dieudonné Hakizimana demande un registre plus net.
Correction : On va au récit vraiment, et Dieudonné Hakizimana demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Récit interculturel'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Tenir l'article implicite jusqu'au bout, sans retomber dans le cri. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Article implicite
Lila Sow : Radio Figuier. On parle trop vite de la seconde version de l'article d'Hawa, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on force le cri au nom de la clarté, une clarté qui n'est qu'un slogan contraire n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Aline Uwase : Ce que l'on nomme composition, ici, n'est pas un slogan : arrangement des faits, lisible.
Aline : loin de manquer de courage, l'article se lisait.
Hawa Diallo : Je garde le tarif bas dans ma version, sans le crier.
Joël Mugisha : Lila n'ajoute pas un cri.
Rose Iradukunda : Patrick relit l'écart.
Solange Mukamana : Rose entend la porte.
Karim Bamba : Sami voulait plus net ; il relit, il cède.
Félicie Ndayishimiye : Un chiffre, une trace : Aline a justifié l'écart ; Hawa a gardé le tarif ; zéro cri ajouté.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une maîtrise de registre, pas d'un manque de courage
Yvette : Mado aime la composition.
Mado : Hawa Diallo entend, dans « il faut le dire clairement », ceci qui n'est pas dit : clairement veut parfois dire criez comme nous
Sami : Autrement dit, l'implicite C2 n'est pas un flou : c'est une composition de faits dont la conclusion se lit
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire
Marc : un implicite C2 se justifie, il ne se dilue pas.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : la demande de crier d'un côté, l'article gardé de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Il faut le dire clairement : on notera que clairement, ici, signifie souvent plus fort que moi.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Article implicite'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une clarté qui n'est qu'un slogan contraire est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une clarté qui n'est qu'un slogan contraire n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Article implicite'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Reformulez l'implicite de « il faut le dire clairement » et la concession d'Aline Uwase."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Article implicite'
  AND l.competency = 'CO'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Tenir l'article implicite jusqu'au bout, sans retomber dans le cri. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « La conclusion se lit », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La conclusion se lit
On parle trop vite de la seconde version de l'article d'Hawa, comme si le mot dispensait d'en examiner le prix.
Encore que l'on force le cri au nom de la clarté, une clarté qui n'est qu'un slogan contraire n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Ce que l'on nomme composition, ici, n'est pas un slogan : arrangement des faits, lisible.
Aline : loin de manquer de courage, l'article se lisait.
Hawa garde le tarif bas dans sa version, sans le crier.
Lila n'ajoute pas un cri.
Patrick relit l'écart.
Rose entend la porte.
Sami voulait plus net ; il relit, il cède.
Un chiffre, une trace : Aline a justifié l'écart ; Hawa a gardé le tarif ; zéro cri ajouté.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une maîtrise de registre, pas d'un manque de courage
Mado aime la composition.
Hawa Diallo entend, dans « il faut le dire clairement », ceci qui n'est pas dit : clairement veut parfois dire criez comme nous
Autrement dit, l'implicite C2 n'est pas un flou : c'est une composition de faits dont la conclusion se lit
La proposition qui reste debout est celle-ci : garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire
Marc : un implicite C2 se justifie, il ne se dilue pas.
Nous clôturons sans fusionner les voix : la demande de crier d'un côté, l'article gardé de l'autre, et le point où elles refusent de se ressembler.
Signé : Aline Uwase, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Article implicite'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : écrire en sous-entendu ; faits ; écart.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on force le cri au nom de la clarté, une clarté qui n'est qu'un slogan contraire n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Ce que l'on nomme composition, ici, n'est pas un slogan : arrangement des faits, lisible.
Encore que l'on justifie, une clarté qui n'est qu'un slogan contraire n'est pas un détail.
Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Autrement dit, l'implicite C2 n'est pas un flou : c'est une composition de faits dont la conclusion se lit
Il ressort que garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire
Hawa garde le tarif bas dans sa version, sans le crier.
Rose entend la porte.
La proposition qui reste debout est celle-ci : garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : la demande de crier d'un côté, l'article gardé de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Article implicite'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Tenir l'article implicite jusqu'au bout, sans retomber dans le cri. Point : écrire en sous-entendu ; faits ; écart.

Consigne
Imitez le texte d'Aline Uwase.

Support — Aline Uwase — La conclusion se lit
Aline Uwase — La conclusion se lit
On parle trop vite de la seconde version de l'article d'Hawa, comme si le mot dispensait d'en examiner le prix.
Encore que l'on force le cri au nom de la clarté, une clarté qui n'est qu'un slogan contraire n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Ce que l'on nomme composition, ici, n'est pas un slogan : arrangement des faits, lisible.
Aline : loin de manquer de courage, l'article se lisait.
Rose entend la porte.
Sami voulait plus net ; il relit, il cède.
Mado aime la composition.
La proposition qui reste debout est celle-ci : garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire
Marc : un implicite C2 se justifie, il ne se dilue pas.
Nous clôturons sans fusionner les voix : la demande de crier d'un côté, l'article gardé de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on justifie, une clarté qui n'est qu'un slogan contraire n'est pas un détail.
Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
l'implicite C2 n'est pas un flou : c'est une composition de faits dont la conclusion se lit
Aline Uwase, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Article implicite'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos d'Aline Uwase sur « Article implicite » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos d'Aline Uwase sur « Article implicite » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Article implicite'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Imitez le texte d'Aline Uwase : vingt lignes, deux voix, une concession, une proposition."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Article implicite'
  AND l.competency = 'PE'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser écrire en sous-entendu ; faits ; écart au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — écrire en sous-entendu ; faits ; écart
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on justifie, une clarté qui n'est qu'un slogan contraire n'est pas un détail.
Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Autrement dit, l'implicite C2 n'est pas un flou : c'est une composition de faits dont la conclusion se lit
Il ressort que garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme composition, ici, n'est pas un slogan : arrangement des faits, lisible.
Hawa garde le tarif bas dans sa version, sans le crier.
Rose entend la porte.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au clarté pour de vrai genre, et Hawa Diallo demande un registre plus net.
Correction : On va au clarté vraiment, et Hawa Diallo demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Article implicite'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Tenir un débat sur un sujet polémique de cour, avec règles C2. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Débat de la cour
Lila Sow : Radio Figuier. On parle trop vite du débat sous le figuier, après les copies et le rire, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme le débat en combat, une synthèse trop lisse après trop de bruit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Patrick Habimana concède qu'un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Aline Uwase : Ce que l'on nomme débat, ici, n'est pas un slogan : échange réglé, distinct d'un combat.
Patrick : il convient que l'on débatte, encore que l'on refuse l'arène.
Hawa Diallo : Rose concède l'inspiration, pas le vide.
Joël Mugisha : Sami concède la cible.
Rose Iradukunda : Hawa concède le mot généreux, pas le tarif trop bas qu'elle refuse de crier.
Solange Mukamana : Aline chronomètre.
Karim Bamba : Lila n'annonce pas de vainqueur.
Félicie Ndayishimiye : Un chiffre, une trace : Trois tours ; trois concessions ; une synthèse sans vainqueur.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une cour qui pense, pas d'une arène
Yvette : écoute.
Mado : Rose Iradukunda entend, dans « que le meilleur gagne », ceci qui n'est pas dit : le meilleur gagne est déjà une politique du micro
Sami : Autrement dit, il convient que l'on débatte, encore que l'on synthétise sans vainqueur
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un débat — Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi
Marc : une synthèse C2 se juge à ce qu'elle n'a pas couronné.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les prises de parole d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Que le meilleur gagne : on aimerait, par curiosité, le critère du meilleur.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Débat de la cour'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une synthèse trop lisse après trop de bruit est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une synthèse trop lisse après trop de bruit n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Débat de la cour'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Tenir un débat sur un sujet polémique de cour, avec règles C2. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Zéro roi au banc », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Zéro roi au banc
On parle trop vite du débat sous le figuier, après les copies et le rire, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le débat en combat, une synthèse trop lisse après trop de bruit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède qu'un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Ce que l'on nomme débat, ici, n'est pas un slogan : échange réglé, distinct d'un combat.
Patrick : il convient que l'on débatte, encore que l'on refuse l'arène.
Rose concède l'inspiration, pas le vide.
Sami concède la cible.
Hawa concède le mot généreux, pas le tarif trop bas qu'elle refuse de crier.
Aline chronomètre.
Lila n'annonce pas de vainqueur.
Un chiffre, une trace : Trois tours ; trois concessions ; une synthèse sans vainqueur.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une cour qui pense, pas d'une arène
Yvette écoute.
Rose Iradukunda entend, dans « que le meilleur gagne », ceci qui n'est pas dit : le meilleur gagne est déjà une politique du micro
Autrement dit, il convient que l'on débatte, encore que l'on synthétise sans vainqueur
La proposition qui reste debout est celle-ci : un débat — Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi
Marc : une synthèse C2 se juge à ce qu'elle n'a pas couronné.
Nous clôturons sans fusionner les voix : les prises de parole d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
Signé : Patrick Habimana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Débat de la cour'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : débat contradictoire ; polémique ; synthèse.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme le débat en combat, une synthèse trop lisse après trop de bruit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède qu'un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Ce que l'on nomme débat, ici, n'est pas un slogan : échange réglé, distinct d'un combat.
Encore que l'on débatte, une synthèse trop lisse après trop de bruit n'est pas un détail.
Patrick Habimana concède qu'un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Autrement dit, il convient que l'on débatte, encore que l'on synthétise sans vainqueur
Il ressort qu'un débat : Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi
Rose concède l'inspiration, pas le vide.
Aline chronomètre.
La proposition qui reste debout est celle-ci : un débat — Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les prises de parole d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Débat de la cour'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Patrick Habimana transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Patrick Habimana concède qu'un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Débat de la cour'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Tenir un débat sur un sujet polémique de cour, avec règles C2. Point : débat contradictoire ; polémique ; synthèse.

Consigne
Imitez le texte de Patrick Habimana.

Support — Patrick Habimana — Zéro roi au banc
Patrick Habimana — Zéro roi au banc
On parle trop vite du débat sous le figuier, après les copies et le rire, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le débat en combat, une synthèse trop lisse après trop de bruit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède qu'un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Ce que l'on nomme débat, ici, n'est pas un slogan : échange réglé, distinct d'un combat.
Patrick : il convient que l'on débatte, encore que l'on refuse l'arène.
Aline chronomètre.
Lila n'annonce pas de vainqueur.
Yvette écoute.
La proposition qui reste debout est celle-ci : un débat — Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi
Marc : une synthèse C2 se juge à ce qu'elle n'a pas couronné.
Nous clôturons sans fusionner les voix : les prises de parole d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on débatte, une synthèse trop lisse après trop de bruit n'est pas un détail.
Patrick Habimana concède qu'un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il convient que l'on débatte, encore que l'on synthétise sans vainqueur
Patrick Habimana, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Débat de la cour'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Patrick Habimana sur « Débat de la cour » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Patrick Habimana sur « Débat de la cour » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Débat de la cour'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser débat contradictoire ; polémique ; synthèse au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — débat contradictoire ; polémique ; synthèse
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on débatte, une synthèse trop lisse après trop de bruit n'est pas un détail.
Patrick Habimana concède qu'un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Autrement dit, il convient que l'on débatte, encore que l'on synthétise sans vainqueur
Il ressort qu'un débat : Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme débat, ici, n'est pas un slogan : échange réglé, distinct d'un combat.
Rose concède l'inspiration, pas le vide.
Aline chronomètre.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au règle pour de vrai genre, et Rose Iradukunda demande un registre plus net.
Correction : On va au règle vraiment, et Rose Iradukunda demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Cultures croisées'
  AND s.title = 'Débat de la cour'
  AND l.competency = 'EL';

-- C2 — Révolutions de la rive
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Faire des hypothèses sur une crue inventée et exposer des conséquences. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — La crue trop tôt
Lila Sow : Radio Figuier. On parle trop vite de la crue trop tôt de la rive, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on reporte l'hypothèse à plus tard, un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer.
Aline Uwase : Ce que l'on nomme crue, ici, n'est pas un slogan : montée d'eau trop tôt, mesurée.
Oscar : la part de terre trop tôt mouillée s'établit à ce que le saule sait déjà.
Hawa Diallo : Nina dessine la conséquence.
Aline : l'hypothèse n'est pas une panique.
Rose Iradukunda : Félicie entend la terre.
Solange Mukamana : Lila n'adoucira pas.
Karim Bamba : Karim chiffre sans sentence.
Félicie Ndayishimiye : Un chiffre, une trace : Oscar a mesuré deux crues trop tôt ; trois jardins plus bas ; une ombre de moins.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une rive, pas d'un spectacle de fin du monde
Yvette : Joël demande le relais.
Mado : Nina Kayitesi entend, dans « on verra bien », ceci qui n'est pas dit : on verra bien est la phrase de ceux dont le jardin n'est pas le premier mouillé
Sami : Autrement dit, s'il montait encore, le saule perdrait ; il se peut que l'on ait encore un relais
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un compte-rendu oral — hypothèses, conséquences, un geste de rive
Marc : un compte-rendu climat de cour nomme le jardin, pas la planète abstraite.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les mesures d'Oscar d'un côté, l'émission trop calme de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : On verra bien : futur d'une sérénité qui n'habite pas le premier jardin.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'La crue trop tôt'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un plus tard qui n'a pas d'ombre à midi déjà trop blanc est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'La crue trop tôt'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m6/hypothese-crue.svg",
      "word": "hypothèse de crue"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/biodiversite-rive.svg",
      "word": "biodiversite rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/hypothese-climat.svg",
      "word": "hypothese climat"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/graphique-crue.svg",
      "word": "graphique crue"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'La crue trop tôt'
  AND l.competency = 'CO'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Reformulez l'implicite de « on verra bien » et la concession d'Oscar Niyitegeka."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'La crue trop tôt'
  AND l.competency = 'CO'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Faire des hypothèses sur une crue inventée et exposer des conséquences. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le jardin mouillé d'abord », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le jardin mouillé d'abord
On parle trop vite de la crue trop tôt de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on reporte l'hypothèse à plus tard, un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer.
Ce que l'on nomme crue, ici, n'est pas un slogan : montée d'eau trop tôt, mesurée.
Oscar : la part de terre trop tôt mouillée s'établit à ce que le saule sait déjà.
Nina dessine la conséquence.
Aline : l'hypothèse n'est pas une panique.
Félicie entend la terre.
Lila n'adoucira pas.
Karim chiffre sans sentence.
Un chiffre, une trace : Oscar a mesuré deux crues trop tôt ; trois jardins plus bas ; une ombre de moins.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une rive, pas d'un spectacle de fin du monde
Joël demande le relais.
Nina Kayitesi entend, dans « on verra bien », ceci qui n'est pas dit : on verra bien est la phrase de ceux dont le jardin n'est pas le premier mouillé
Autrement dit, s'il montait encore, le saule perdrait ; il se peut que l'on ait encore un relais
La proposition qui reste debout est celle-ci : un compte-rendu oral — hypothèses, conséquences, un geste de rive
Marc : un compte-rendu climat de cour nomme le jardin, pas la planète abstraite.
Nous clôturons sans fusionner les voix : les mesures d'Oscar d'un côté, l'émission trop calme de l'autre, et le point où elles refusent de se ressembler.
Signé : Oscar Niyitegeka, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'La crue trop tôt'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : hypothèses ; conséquences ; biodiversité de rive.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on reporte l'hypothèse à plus tard, un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer.
Ce que l'on nomme crue, ici, n'est pas un slogan : montée d'eau trop tôt, mesurée.
Encore que l'on expose, un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail.
Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer.
Autrement dit, s'il montait encore, le saule perdrait ; il se peut que l'on ait encore un relais
Il ressort qu'un compte-rendu oral : hypothèses, conséquences, un geste de rive
Nina dessine la conséquence.
Lila n'adoucira pas.
La proposition qui reste debout est celle-ci : un compte-rendu oral — hypothèses, conséquences, un geste de rive
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les mesures d'Oscar d'un côté, l'émission trop calme de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'La crue trop tôt'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Faire des hypothèses sur une crue inventée et exposer des conséquences. Point : hypothèses ; conséquences ; biodiversité de rive.

Consigne
Imitez le texte d'Oscar Niyitegeka.

Support — Oscar Niyitegeka — Le jardin mouillé d'abord
Oscar Niyitegeka — Le jardin mouillé d'abord
On parle trop vite de la crue trop tôt de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on reporte l'hypothèse à plus tard, un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer.
Ce que l'on nomme crue, ici, n'est pas un slogan : montée d'eau trop tôt, mesurée.
Oscar : la part de terre trop tôt mouillée s'établit à ce que le saule sait déjà.
Lila n'adoucira pas.
Karim chiffre sans sentence.
Joël demande le relais.
La proposition qui reste debout est celle-ci : un compte-rendu oral — hypothèses, conséquences, un geste de rive
Marc : un compte-rendu climat de cour nomme le jardin, pas la planète abstraite.
Nous clôturons sans fusionner les voix : les mesures d'Oscar d'un côté, l'émission trop calme de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on expose, un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail.
Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
s'il montait encore, le saule perdrait ; il se peut que l'on ait encore un relais
Oscar Niyitegeka, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'La crue trop tôt'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos d'Oscar Niyitegeka sur « La crue trop tôt » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos d'Oscar Niyitegeka sur « La crue trop tôt » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'La crue trop tôt'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Imitez le texte d'Oscar Niyitegeka : vingt lignes, deux voix, une concession, une proposition."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'La crue trop tôt'
  AND l.competency = 'PE'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Rédiger un article qui répond aux doutes trop commodes, sans mépris. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Consensus trop commode
Lila Sow : Radio Figuier. On parle trop vite du déni poli sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme la mesure en caprice d'Oscar, un doute qui n'a pas visité la rive n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive.
Aline Uwase : Ce que l'on nomme déni, ici, n'est pas un slogan : refus poli de voir, distinct du doute.
Nina : loin de crier, j'aligne.
Hawa Diallo : Karim avait dit pas si grave ; il a vu le jardin.
Joël Mugisha : Oscar n'humilie pas.
Rose Iradukunda : Aline distingue doute et déni.
Solange Mukamana : Lila lira l'article.
Karim Bamba : Félicie pose le bol après la visite.
Félicie Ndayishimiye : Un chiffre, une trace : Nina a emmené trois sceptiques à la rive ; deux ont changé de phrase ; un a gardé pas si grave.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'argumenter, pas d'humilier un doute
Yvette : Patrick veut la stratégie, pas l'insulte.
Mado : Karim Bamba entend, dans « ce n'est pas si grave », ceci qui n'est pas dit : pas si grave veut dire pas chez moi d'abord
Sami : Autrement dit, loin de convaincre par le cri, l'article aligne mesures, visite, conséquence
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un article — doute légitime vs déni poli, preuves de cour, geste
Marc : répondre au déni poli, c'est une rhétorique, pas une guerre.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les phrases trop calmes du banc d'un côté, l'article de Nina de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Ce n'est pas si grave : on aimerait connaître l'adresse du pas si.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Consensus trop commode'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un doute qui n'a pas visité la rive est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un doute qui n'a pas visité la rive n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Consensus trop commode'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rédiger un article qui répond aux doutes trop commodes, sans mépris. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Douter après la rive », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Douter après la rive
On parle trop vite du déni poli sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme la mesure en caprice d'Oscar, un doute qui n'a pas visité la rive n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive.
Ce que l'on nomme déni, ici, n'est pas un slogan : refus poli de voir, distinct du doute.
Nina : loin de crier, j'aligne.
Karim avait dit pas si grave ; il a vu le jardin.
Oscar n'humilie pas.
Aline distingue doute et déni.
Lila lira l'article.
Félicie pose le bol après la visite.
Un chiffre, une trace : Nina a emmené trois sceptiques à la rive ; deux ont changé de phrase ; un a gardé pas si grave.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'argumenter, pas d'humilier un doute
Patrick veut la stratégie, pas l'insulte.
Karim Bamba entend, dans « ce n'est pas si grave », ceci qui n'est pas dit : pas si grave veut dire pas chez moi d'abord
Autrement dit, loin de convaincre par le cri, l'article aligne mesures, visite, conséquence
La proposition qui reste debout est celle-ci : un article — doute légitime vs déni poli, preuves de cour, geste
Marc : répondre au déni poli, c'est une rhétorique, pas une guerre.
Nous clôturons sans fusionner les voix : les phrases trop calmes du banc d'un côté, l'article de Nina de l'autre, et le point où elles refusent de se ressembler.
Signé : Nina Kayitesi, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Consensus trop commode'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : stratégie argumentative ; répondre au déni poli.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme la mesure en caprice d'Oscar, un doute qui n'a pas visité la rive n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive.
Ce que l'on nomme déni, ici, n'est pas un slogan : refus poli de voir, distinct du doute.
Encore que l'on réponde, un doute qui n'a pas visité la rive n'est pas un détail.
Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive.
Autrement dit, loin de convaincre par le cri, l'article aligne mesures, visite, conséquence
Il ressort qu'un article : doute légitime vs déni poli, preuves de cour, geste
Karim avait dit pas si grave ; il a vu le jardin.
Lila lira l'article.
La proposition qui reste debout est celle-ci : un article — doute légitime vs déni poli, preuves de cour, geste
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les phrases trop calmes du banc d'un côté, l'article de Nina de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Consensus trop commode'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Rédiger un article qui répond aux doutes trop commodes, sans mépris. Point : stratégie argumentative ; répondre au déni poli.

Consigne
Imitez le texte de Nina Kayitesi.

Support — Nina Kayitesi — Douter après la rive
Nina Kayitesi — Douter après la rive
On parle trop vite du déni poli sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme la mesure en caprice d'Oscar, un doute qui n'a pas visité la rive n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive.
Ce que l'on nomme déni, ici, n'est pas un slogan : refus poli de voir, distinct du doute.
Nina : loin de crier, j'aligne.
Lila lira l'article.
Félicie pose le bol après la visite.
Patrick veut la stratégie, pas l'insulte.
La proposition qui reste debout est celle-ci : un article — doute légitime vs déni poli, preuves de cour, geste
Marc : répondre au déni poli, c'est une rhétorique, pas une guerre.
Nous clôturons sans fusionner les voix : les phrases trop calmes du banc d'un côté, l'article de Nina de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on réponde, un doute qui n'a pas visité la rive n'est pas un détail.
Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
loin de convaincre par le cri, l'article aligne mesures, visite, conséquence
Nina Kayitesi, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Consensus trop commode'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Nina Kayitesi sur « Consensus trop commode » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Nina Kayitesi sur « Consensus trop commode » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Consensus trop commode'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Proposer des mesures écologiques de cour, datées, finançables. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Mesures pour la rive
Lila Sow : Radio Figuier. On parle trop vite d'un programme trop lyrique de la rive, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface le jardin d'Oscar sous un mot trop grand, un programme sans destinataire ni fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Solange Mukamana concède qu'un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Aline Uwase : Ce que l'on nomme mesure, ici, n'est pas un slogan : geste politique daté, finançable.
Solange : il convient que l'on vote le compost, encore que l'hymne plaise.
Hawa Diallo : Oscar entend son jardin.
Joël Mugisha : Karim chiffre le fer.
Rose Iradukunda : Nina dessine la rampe de crue.
Solange Mukamana : Aline rature planète.
Karim Bamba : Lila lira le programme.
Félicie Ndayishimiye : Un chiffre, une trace : Solange a raturé planète ; gardé compost, relais, heures ; daté deux jeudis.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une politique de rive, pas d'un hymne
Yvette : Joël peut porter.
Mado : Oscar Niyitegeka entend, dans « sauvons la planète », ceci qui n'est pas dit : sauvons la planète permet de ne pas nommer le jeudi et le fer
Sami : Autrement dit, il convient que l'on vote trois mesures, encore que l'on n'ait pas de planète à mettre dans une motion
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un programme de cour — trois mesures, deux dates, un financement inventé du Bureau
Marc : des mesures C2 ont un destinataire, ou ne sont qu'un nuage.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le brouillon trop lyrique d'un côté, le programme retenu de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Sauvons la planète : on vérifiera si le jeudi, plus modeste, a survécu à la phrase.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Mesures pour la rive'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un programme sans destinataire ni fer est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un programme sans destinataire ni fer n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Mesures pour la rive'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Proposer des mesures écologiques de cour, datées, finançables. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Trois mesures, pas un hymne », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Trois mesures, pas un hymne
On parle trop vite d'un programme trop lyrique de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface le jardin d'Oscar sous un mot trop grand, un programme sans destinataire ni fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède qu'un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Ce que l'on nomme mesure, ici, n'est pas un slogan : geste politique daté, finançable.
Solange : il convient que l'on vote le compost, encore que l'hymne plaise.
Oscar entend son jardin.
Karim chiffre le fer.
Nina dessine la rampe de crue.
Aline rature planète.
Lila lira le programme.
Un chiffre, une trace : Solange a raturé planète ; gardé compost, relais, heures ; daté deux jeudis.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une politique de rive, pas d'un hymne
Joël peut porter.
Oscar Niyitegeka entend, dans « sauvons la planète », ceci qui n'est pas dit : sauvons la planète permet de ne pas nommer le jeudi et le fer
Autrement dit, il convient que l'on vote trois mesures, encore que l'on n'ait pas de planète à mettre dans une motion
La proposition qui reste debout est celle-ci : un programme de cour — trois mesures, deux dates, un financement inventé du Bureau
Marc : des mesures C2 ont un destinataire, ou ne sont qu'un nuage.
Nous clôturons sans fusionner les voix : le brouillon trop lyrique d'un côté, le programme retenu de l'autre, et le point où elles refusent de se ressembler.
Signé : Solange Mukamana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Mesures pour la rive'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : programme ; mesures politiques de cour ; il convient que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on efface le jardin d'Oscar sous un mot trop grand, un programme sans destinataire ni fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède qu'un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Ce que l'on nomme mesure, ici, n'est pas un slogan : geste politique daté, finançable.
Encore que l'on vote, un programme sans destinataire ni fer n'est pas un détail.
Solange Mukamana concède qu'un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Autrement dit, il convient que l'on vote trois mesures, encore que l'on n'ait pas de planète à mettre dans une motion
Il ressort qu'un programme de cour : trois mesures, deux dates, un financement inventé du Bureau
Oscar entend son jardin.
Aline rature planète.
La proposition qui reste debout est celle-ci : un programme de cour — trois mesures, deux dates, un financement inventé du Bureau
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le brouillon trop lyrique d'un côté, le programme retenu de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Mesures pour la rive'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Solange Mukamana transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Solange Mukamana concède qu'un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Mesures pour la rive'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Proposer des mesures écologiques de cour, datées, finançables. Point : programme ; mesures politiques de cour ; il convient que.

Consigne
Imitez le texte de Solange Mukamana.

Support — Solange Mukamana — Trois mesures, pas un hymne
Solange Mukamana — Trois mesures, pas un hymne
On parle trop vite d'un programme trop lyrique de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface le jardin d'Oscar sous un mot trop grand, un programme sans destinataire ni fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède qu'un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Ce que l'on nomme mesure, ici, n'est pas un slogan : geste politique daté, finançable.
Solange : il convient que l'on vote le compost, encore que l'hymne plaise.
Aline rature planète.
Lila lira le programme.
Joël peut porter.
La proposition qui reste debout est celle-ci : un programme de cour — trois mesures, deux dates, un financement inventé du Bureau
Marc : des mesures C2 ont un destinataire, ou ne sont qu'un nuage.
Nous clôturons sans fusionner les voix : le brouillon trop lyrique d'un côté, le programme retenu de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on vote, un programme sans destinataire ni fer n'est pas un détail.
Solange Mukamana concède qu'un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il convient que l'on vote trois mesures, encore que l'on n'ait pas de planète à mettre dans une motion
Solange Mukamana, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Mesures pour la rive'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Solange Mukamana sur « Mesures pour la rive » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Solange Mukamana sur « Mesures pour la rive » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Mesures pour la rive'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser programme ; mesures politiques de cour ; il convient que au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — programme ; mesures politiques de cour ; il convient que
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on vote, un programme sans destinataire ni fer n'est pas un détail.
Solange Mukamana concède qu'un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Autrement dit, il convient que l'on vote trois mesures, encore que l'on n'ait pas de planète à mettre dans une motion
Il ressort qu'un programme de cour : trois mesures, deux dates, un financement inventé du Bureau
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme mesure, ici, n'est pas un slogan : geste politique daté, finançable.
Oscar entend son jardin.
Aline rature planète.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au financement pour de vrai genre, et Oscar Niyitegeka demande un registre plus net.
Correction : On va au financement vraiment, et Oscar Niyitegeka demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Mesures pour la rive'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Encourager des gestes et étudier un personnage de roman qui défend une rive. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Un personnage de rive
Lila Sow : Radio Figuier. On parle trop vite d'un personnage trop exemplaire de Mado, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme le geste en consigne de vitrine, un personnage qui n'aurait plus de contradiction n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède qu'un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Aline Uwase : Ce que l'on nomme personnage, ici, n'est pas un slogan : être de roman, avec une fonction.
Mado : on dirait qu'elle douterait encore, et l'on la croirait.
Hawa Diallo : Félicie refuse d'être une sainte.
Aline : la fonction d'un personnage n'est pas l'affiche.
Rose Iradukunda : Oscar veut de la terre sous l'ongle.
Solange Mukamana : Lila n'adoucira pas.
Karim Bamba : Sami aime trop l'exemple ; on le complique.
Félicie Ndayishimiye : Un chiffre, une trace : Mado a laissé le bol trop vite ; gardé le compost ; refusé la sainte.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une fonction dans un roman, pas d'une mascotte
Yvette : Patrick relit la contradiction.
Mado : Félicie Ndayishimiye entend, dans « soyez écolos », ceci qui n'est pas dit : soyez écolos est une affiche, pas une fonction romanesque
Sami : Autrement dit, on dirait qu'elle porterait encore, tout en doutant, et ce doute la rendrait croyable
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un personnage — un geste, une contradiction, une rive, zéro sainteté
Marc : encourager un geste, au C2, ce n'est pas ordonner une vitrine.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le brouillon trop saint d'un côté, le personnage retenu de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Soyez écolos : impératif d'une vitrine, rarement d'un roman.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Un personnage de rive'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un personnage qui n'aurait plus de contradiction est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un personnage qui n'aurait plus de contradiction n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Un personnage de rive'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Encourager des gestes et étudier un personnage de roman qui défend une rive. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Une contradiction, pas une sainte », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Une contradiction, pas une sainte
On parle trop vite d'un personnage trop exemplaire de Mado, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le geste en consigne de vitrine, un personnage qui n'aurait plus de contradiction n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède qu'un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Ce que l'on nomme personnage, ici, n'est pas un slogan : être de roman, avec une fonction.
Mado : on dirait qu'elle douterait encore, et l'on la croirait.
Félicie refuse d'être une sainte.
Aline : la fonction d'un personnage n'est pas l'affiche.
Oscar veut de la terre sous l'ongle.
Lila n'adoucira pas.
Sami aime trop l'exemple ; on le complique.
Un chiffre, une trace : Mado a laissé le bol trop vite ; gardé le compost ; refusé la sainte.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une fonction dans un roman, pas d'une mascotte
Patrick relit la contradiction.
Félicie Ndayishimiye entend, dans « soyez écolos », ceci qui n'est pas dit : soyez écolos est une affiche, pas une fonction romanesque
Autrement dit, on dirait qu'elle porterait encore, tout en doutant, et ce doute la rendrait croyable
La proposition qui reste debout est celle-ci : un personnage — un geste, une contradiction, une rive, zéro sainteté
Marc : encourager un geste, au C2, ce n'est pas ordonner une vitrine.
Nous clôturons sans fusionner les voix : le brouillon trop saint d'un côté, le personnage retenu de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Un personnage de rive'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : gestes quotidiens ; personnage de roman ; mode et éthique inventées.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme le geste en consigne de vitrine, un personnage qui n'aurait plus de contradiction n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède qu'un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Ce que l'on nomme personnage, ici, n'est pas un slogan : être de roman, avec une fonction.
Encore que l'on laisse, un personnage qui n'aurait plus de contradiction n'est pas un détail.
Mado concède qu'un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Autrement dit, on dirait qu'elle porterait encore, tout en doutant, et ce doute la rendrait croyable
Il ressort qu'un personnage : un geste, une contradiction, une rive, zéro sainteté
Félicie refuse d'être une sainte.
Lila n'adoucira pas.
La proposition qui reste debout est celle-ci : un personnage — un geste, une contradiction, une rive, zéro sainteté
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le brouillon trop saint d'un côté, le personnage retenu de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Un personnage de rive'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Mado transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Mado concède qu'un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Un personnage de rive'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Encourager des gestes et étudier un personnage de roman qui défend une rive. Point : gestes quotidiens ; personnage de roman ; mode et éthique inventées.

Consigne
Imitez le texte de Mado.

Support — Mado — Une contradiction, pas une sainte
Mado — Une contradiction, pas une sainte
On parle trop vite d'un personnage trop exemplaire de Mado, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le geste en consigne de vitrine, un personnage qui n'aurait plus de contradiction n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède qu'un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Ce que l'on nomme personnage, ici, n'est pas un slogan : être de roman, avec une fonction.
Mado : on dirait qu'elle douterait encore, et l'on la croirait.
Lila n'adoucira pas.
Sami aime trop l'exemple ; on le complique.
Patrick relit la contradiction.
La proposition qui reste debout est celle-ci : un personnage — un geste, une contradiction, une rive, zéro sainteté
Marc : encourager un geste, au C2, ce n'est pas ordonner une vitrine.
Nous clôturons sans fusionner les voix : le brouillon trop saint d'un côté, le personnage retenu de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on laisse, un personnage qui n'aurait plus de contradiction n'est pas un détail.
Mado concède qu'un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
on dirait qu'elle porterait encore, tout en doutant, et ce doute la rendrait croyable
Mado, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Un personnage de rive'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Mado sur « Un personnage de rive » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Mado sur « Un personnage de rive » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Un personnage de rive'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser gestes quotidiens ; personnage de roman ; mode et éthique inventées au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — gestes quotidiens ; personnage de roman ; mode et éthique inventées
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on laisse, un personnage qui n'aurait plus de contradiction n'est pas un détail.
Mado concède qu'un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Autrement dit, on dirait qu'elle porterait encore, tout en doutant, et ce doute la rendrait croyable
Il ressort qu'un personnage : un geste, une contradiction, une rive, zéro sainteté
Piège : indicatif plat là où le conditionnel peint
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme personnage, ici, n'est pas un slogan : être de roman, avec une fonction.
Félicie refuse d'être une sainte.
Lila n'adoucira pas.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au contradiction pour de vrai genre, et Félicie Ndayishimiye demande un registre plus net.
Correction : On va au contradiction vraiment, et Félicie Ndayishimiye demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Un personnage de rive'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Faire le compte-rendu oral des conséquences, à partir des séquences précédentes. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Compte-rendu climat
Lila Sow : Radio Figuier. On parle trop vite de ce que la cour peut déjà dire de la rive, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on noye l'oreille sous trop de fin du monde, un oral trop vaste pour une cour n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Aline Uwase : Ce que l'on nomme ampleur, ici, n'est pas un slogan : échelle, à borner pour l'oreille.
Nina : selon Oscar, la crue trop tôt ; d'après Solange, trois mesures.
Hawa Diallo : Il ressort un jardin, pas un spectacle.
Joël Mugisha : Aline chronomètre.
Rose Iradukunda : Lila n'ajoute pas de musique.
Solange Mukamana : Karim veut un chiffre, le reçoit.
Karim Bamba : Félicie écoute.
Félicie Ndayishimiye : Un chiffre, une trace : Nina a parlé 3 min 50 ; cité Oscar et Solange ; zéro fin du monde.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'informer une cour, pas de la sidérer
Yvette : Joël entend le relais.
Mado : Oscar Niyitegeka entend, dans « il faut tout dire », ceci qui n'est pas dit : tout dire est souvent le contraire d'un compte-rendu
Sami : Autrement dit, selon Oscar la crue ; d'après Nina le déni ; il ressort trois mesures et un jardin
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un oral — quatre minutes, deux sources, une conséquence, un geste
Marc : un compte-rendu C2 se juge à ce qu'il a su borner.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les rapports de la rive d'un côté, l'oral de Nina de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Il faut tout dire : programme d'une honnêteté qui n'a pas d'oreille en face.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Compte-rendu climat'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un oral trop vaste pour une cour est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un oral trop vaste pour une cour n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Compte-rendu climat'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Faire le compte-rendu oral des conséquences, à partir des séquences précédentes. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Quatre minutes, pas le monde entier », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Quatre minutes, pas le monde entier
On parle trop vite de ce que la cour peut déjà dire de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on noye l'oreille sous trop de fin du monde, un oral trop vaste pour une cour n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Ce que l'on nomme ampleur, ici, n'est pas un slogan : échelle, à borner pour l'oreille.
Nina : selon Oscar, la crue trop tôt ; d'après Solange, trois mesures.
Il ressort un jardin, pas un spectacle.
Aline chronomètre.
Lila n'ajoute pas de musique.
Karim veut un chiffre, le reçoit.
Félicie écoute.
Un chiffre, une trace : Nina a parlé 3 min 50 ; cité Oscar et Solange ; zéro fin du monde.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'informer une cour, pas de la sidérer
Joël entend le relais.
Oscar Niyitegeka entend, dans « il faut tout dire », ceci qui n'est pas dit : tout dire est souvent le contraire d'un compte-rendu
Autrement dit, selon Oscar la crue ; d'après Nina le déni ; il ressort trois mesures et un jardin
La proposition qui reste debout est celle-ci : un oral — quatre minutes, deux sources, une conséquence, un geste
Marc : un compte-rendu C2 se juge à ce qu'il a su borner.
Nous clôturons sans fusionner les voix : les rapports de la rive d'un côté, l'oral de Nina de l'autre, et le point où elles refusent de se ressembler.
Signé : Nina Kayitesi, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Compte-rendu climat'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : oral de synthèse ; conséquences ; sans spectacle.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on noye l'oreille sous trop de fin du monde, un oral trop vaste pour une cour n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Ce que l'on nomme ampleur, ici, n'est pas un slogan : échelle, à borner pour l'oreille.
Encore que l'on borne, un oral trop vaste pour une cour n'est pas un détail.
Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Autrement dit, selon Oscar la crue ; d'après Nina le déni ; il ressort trois mesures et un jardin
Il ressort qu'un oral : quatre minutes, deux sources, une conséquence, un geste
Il ressort un jardin, pas un spectacle.
Karim veut un chiffre, le reçoit.
La proposition qui reste debout est celle-ci : un oral — quatre minutes, deux sources, une conséquence, un geste
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les rapports de la rive d'un côté, l'oral de Nina de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Compte-rendu climat'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Faire le compte-rendu oral des conséquences, à partir des séquences précédentes. Point : oral de synthèse ; conséquences ; sans spectacle.

Consigne
Imitez le texte de Nina Kayitesi.

Support — Nina Kayitesi — Quatre minutes, pas le monde entier
Nina Kayitesi — Quatre minutes, pas le monde entier
On parle trop vite de ce que la cour peut déjà dire de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on noye l'oreille sous trop de fin du monde, un oral trop vaste pour une cour n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Ce que l'on nomme ampleur, ici, n'est pas un slogan : échelle, à borner pour l'oreille.
Nina : selon Oscar, la crue trop tôt ; d'après Solange, trois mesures.
Karim veut un chiffre, le reçoit.
Félicie écoute.
Joël entend le relais.
La proposition qui reste debout est celle-ci : un oral — quatre minutes, deux sources, une conséquence, un geste
Marc : un compte-rendu C2 se juge à ce qu'il a su borner.
Nous clôturons sans fusionner les voix : les rapports de la rive d'un côté, l'oral de Nina de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on borne, un oral trop vaste pour une cour n'est pas un détail.
Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
selon Oscar la crue ; d'après Nina le déni ; il ressort trois mesures et un jardin
Nina Kayitesi, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Compte-rendu climat'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Nina Kayitesi sur « Compte-rendu climat » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Nina Kayitesi sur « Compte-rendu climat » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Compte-rendu climat'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser oral de synthèse ; conséquences ; sans spectacle au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — oral de synthèse ; conséquences ; sans spectacle
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on borne, un oral trop vaste pour une cour n'est pas un détail.
Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Autrement dit, selon Oscar la crue ; d'après Nina le déni ; il ressort trois mesures et un jardin
Il ressort qu'un oral : quatre minutes, deux sources, une conséquence, un geste
Piège : fusionner les sources au lieu des attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme ampleur, ici, n'est pas un slogan : échelle, à borner pour l'oreille.
Il ressort un jardin, pas un spectacle.
Karim veut un chiffre, le reçoit.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au source pour de vrai genre, et Oscar Niyitegeka demande un registre plus net.
Correction : On va au source vraiment, et Oscar Niyitegeka demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Compte-rendu climat'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Tenir ensemble un programme de rive et un personnage de roman, tâche finale C2-6. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Programme et personnage
Lila Sow : Radio Figuier. On parle trop vite de ce que le module laisse à la cour, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on clôt trop tôt ce qui n'a pas encore de jeudi, une fierté d'avoir parlé, sans fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte.
Aline Uwase : Ce que l'on nomme clôture, ici, n'est pas un slogan : fin de module, pas un job trop vite dit.
Aline : il convient que l'on laisse une date, encore que l'on ait parlé longtemps.
Hawa Diallo : Mado refuse la sainte.
Joël Mugisha : Oscar tient le compost.
Rose Iradukunda : Nina tient la rampe de crue.
Solange Mukamana : Solange tient les jeudis.
Karim Bamba : Lila ouvrira la revue.
Félicie Ndayishimiye : Un chiffre, une trace : Aline a daté la revue ; Mado a gardé le doute du personnage ; Oscar a le compost.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que C2-6 n'ait pas été seulement un exercice de style
Yvette : Félicie pose le bol.
Mado : entend, dans « on a fait le job », ceci qui n'est pas dit : on a fait le job est la phrase de ceux qui n'auront pas à essuyer la prochaine crue
Sami : Autrement dit, il s'agit de laisser un programme et un personnage, relisibles, imparfaits, datés
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un texte final — quatre mesures, un personnage contradictoire, une revue sous le figuier
Marc : une tâche finale C2 se juge au fer qu'elle n'a pas oublié.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le programme et le roman d'un côté, la clôture d'Aline de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : On a fait le job : on aimerait savoir qui, au juste, essuiera encore.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Programme et personnage'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une fierté d'avoir parlé, sans fer est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une fierté d'avoir parlé, sans fer n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Programme et personnage'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Reformulez l'implicite de « on a fait le job » et la concession d'Aline Uwase."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Programme et personnage'
  AND l.competency = 'CO'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Tenir ensemble un programme de rive et un personnage de roman, tâche finale C2-6. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Daté, imparfait, relisible », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Daté, imparfait, relisible
On parle trop vite de ce que le module laisse à la cour, comme si le mot dispensait d'en examiner le prix.
Encore que l'on clôt trop tôt ce qui n'a pas encore de jeudi, une fierté d'avoir parlé, sans fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte.
Ce que l'on nomme clôture, ici, n'est pas un slogan : fin de module, pas un job trop vite dit.
Aline : il convient que l'on laisse une date, encore que l'on ait parlé longtemps.
Mado refuse la sainte.
Oscar tient le compost.
Nina tient la rampe de crue.
Solange tient les jeudis.
Lila ouvrira la revue.
Un chiffre, une trace : Aline a daté la revue ; Mado a gardé le doute du personnage ; Oscar a le compost.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que C2-6 n'ait pas été seulement un exercice de style
Félicie pose le bol.
Mado entend, dans « on a fait le job », ceci qui n'est pas dit : on a fait le job est la phrase de ceux qui n'auront pas à essuyer la prochaine crue
Autrement dit, il s'agit de laisser un programme et un personnage, relisibles, imparfaits, datés
La proposition qui reste debout est celle-ci : un texte final — quatre mesures, un personnage contradictoire, une revue sous le figuier
Marc : une tâche finale C2 se juge au fer qu'elle n'a pas oublié.
Nous clôturons sans fusionner les voix : le programme et le roman d'un côté, la clôture d'Aline de l'autre, et le point où elles refusent de se ressembler.
Signé : Aline Uwase, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Programme et personnage'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : synthèse finale ; programme ; roman.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on clôt trop tôt ce qui n'a pas encore de jeudi, une fierté d'avoir parlé, sans fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte.
Ce que l'on nomme clôture, ici, n'est pas un slogan : fin de module, pas un job trop vite dit.
Encore que l'on laisse, une fierté d'avoir parlé, sans fer n'est pas un détail.
Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte.
Autrement dit, il s'agit de laisser un programme et un personnage, relisibles, imparfaits, datés
Il ressort qu'un texte final : quatre mesures, un personnage contradictoire, une revue sous le figuier
Mado refuse la sainte.
Solange tient les jeudis.
La proposition qui reste debout est celle-ci : un texte final — quatre mesures, un personnage contradictoire, une revue sous le figuier
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le programme et le roman d'un côté, la clôture d'Aline de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Programme et personnage'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m6/porte-jardin.svg",
      "word": "porte jardin"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/lampe-veille-eau.svg",
      "word": "lampe veille eau"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/coeur-rive.svg",
      "word": "coeur rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/hypothese-crue.svg",
      "word": "hypothèse de crue"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Programme et personnage'
  AND l.competency = 'PO'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Tenir ensemble un programme de rive et un personnage de roman, tâche finale C2-6. Point : synthèse finale ; programme ; roman.

Consigne
Imitez le texte d'Aline Uwase.

Support — Aline Uwase — Daté, imparfait, relisible
Aline Uwase — Daté, imparfait, relisible
On parle trop vite de ce que le module laisse à la cour, comme si le mot dispensait d'en examiner le prix.
Encore que l'on clôt trop tôt ce qui n'a pas encore de jeudi, une fierté d'avoir parlé, sans fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte.
Ce que l'on nomme clôture, ici, n'est pas un slogan : fin de module, pas un job trop vite dit.
Aline : il convient que l'on laisse une date, encore que l'on ait parlé longtemps.
Solange tient les jeudis.
Lila ouvrira la revue.
Félicie pose le bol.
La proposition qui reste debout est celle-ci : un texte final — quatre mesures, un personnage contradictoire, une revue sous le figuier
Marc : une tâche finale C2 se juge au fer qu'elle n'a pas oublié.
Nous clôturons sans fusionner les voix : le programme et le roman d'un côté, la clôture d'Aline de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on laisse, une fierté d'avoir parlé, sans fer n'est pas un détail.
Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il s'agit de laisser un programme et un personnage, relisibles, imparfaits, datés
Aline Uwase, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Programme et personnage'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos d'Aline Uwase sur « Programme et personnage » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos d'Aline Uwase sur « Programme et personnage » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Programme et personnage'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m6/lampe-veille-eau.svg",
      "word": "lampe veille eau"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/coeur-rive.svg",
      "word": "coeur rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/hypothese-crue.svg",
      "word": "hypothèse de crue"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/biodiversite-rive.svg",
      "word": "biodiversite rive"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Programme et personnage'
  AND l.competency = 'PE'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Imitez le texte d'Aline Uwase : vingt lignes, deux voix, une concession, une proposition."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Programme et personnage'
  AND l.competency = 'PE'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m6/coeur-rive.svg",
      "word": "coeur rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/hypothese-crue.svg",
      "word": "hypothèse de crue"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/biodiversite-rive.svg",
      "word": "biodiversite rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/hypothese-climat.svg",
      "word": "hypothese climat"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C2 — Révolutions de la rive'
  AND s.title = 'Programme et personnage'
  AND l.competency = 'EL'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
