/*
  Relecture QA MFK — correctifs idempotents (niveau C1).
  UPDATE ciblés uniquement. Aucune table nouvelle.
  published n'est pas modifié.
  Clés métier : titre de module + titre de séquence + compétence
  (+ type et order_index pour les exercices).
*/

-- C1 — La colline de demain
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Rendre compte de deux regards sur la colline future sans les fusionner. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — La colline future
Lila Sow : Radio Figuier. On parle trop vite de la colline de demain, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on promette des lanternes plus hautes, le parking projeté à la racine du figuier n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Je concède que la densification peut protéger les jardins, pour autant que l'on en discute avant les camions.
Aline Uwase : Ce que l'on nomme urbanisme, ici, n'est pas un slogan : organisation raisonnée de l'espace habité.
Patrick Habimana : Nina Kayitesi déroule un calque : la friche n'est pas un vide, c'est une mémoire en attente de verbe.
Hawa Diallo : Patrick refuse qu'on accélère la pente au nom d'un urbanisme qui n'aurait d'urbain que la vitesse.
Joël Mugisha : Joël rappelle que porter les lanternes n'est pas habiter : l'une éclaire, l'autre reste.
Rose Iradukunda : Rose coupe un tissu ocre et dit que le plan, s'il n'habille personne, n'est qu'une affiche.
Solange Mukamana : Solange demande qui paiera la rampe, car une colline sans rampe n'accueille que ceux qui montent vite.
Karim Bamba : Félicie pose le bol : on ne mange pas un plan, on mange ce que la pente laisse pousser.
Félicie Ndayishimiye : Un chiffre, une trace : Karim compte trois files de camions, zéro banc nouveau, une ombre de moins à midi.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de garder une colline habitable, non une affiche lumineuse
Yvette : Dieudonné réparera l'escalier une fois que l'on aura nommé s'il reste un escalier.
Mado : Hawa Diallo entend, dans « colline de demain », ceci qui n'est pas dit : l'effacement possible du mot figuier n'est pas un accident de vocabulaire
Sami : Autrement dit, la densification n'est un abri que si elle cesse d'être un parking habillé de mots
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : garder deux voix dans le compte-rendu et une rampe avant les lanternes nouvelles
Marc Nkurunziza : un compte-rendu n'est pas une victoire, c'est une hospitalité faite aux désaccords.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le calque de Nina Kayitesi d'un côté, la tribune de Marc Nkurunziza de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'La colline future'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Léa Niyonzima sur « La colline future » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Léa Niyonzima sur « La colline future » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'La colline future'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Dégager l'essentiel de deux documents sur l'habitat partagé et en rédiger la synthèse. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Habiter autrement
Lila Sow : Radio Figuier. On parle trop vite de l'habitat partagé du Pavillon du Saule, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on garantisse une serrure pour chacun, la cour fermée à clé dès dix-neuf heures n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Hawa Diallo concède que partager le toit peut alléger les loyers inventés du Pavillon, pour autant que l'on nomme les heures de silence autant que les heures de soupe.
Aline Uwase : Ce que l'on nomme synthèse, ici, n'est pas un slogan : texte qui retient l'essentiel de plusieurs sources.
Patrick Habimana : Dieudonné habite le Pavillon : il répare, il n'écoute pas les conversations comme un loyer.
Hawa Diallo : Lila a enregistré une chronique où le mot famille revient trop souvent pour ne pas cacher une peur.
Joël Mugisha : Patrick demande ce à quoi l'on s'engage quand on pose son sac : la vaisselle, ou le silence ?
Rose Iradukunda : Aline insiste : la relative ce dont nous avons besoin n'est pas un ornement, c'est le noyau.
Solange Mukamana : Karim refuse qu'on appelle solidarité le fait de tout entendre à travers la planche.
Karim Bamba : Félicie apporte la soupe et sort : elle n'est pas une preuve que le toit suffit.
Félicie Ndayishimiye : Un chiffre, une trace : Yvette note quatre lits, deux clés, une soupe à vingt heures, zéro banc pour écrire.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de pouvoir rentrer sans demander pardon d'exister
Yvette : Sami dit qu'il aime le bruit ; Yvette répond qu'aimer le bruit n'est pas une loi.
Mado : Rose Iradukunda entend, dans « toit commun », ceci qui n'est pas dit : ceux qui disent famille élargie veulent parfois dire plus de témoins et moins de portes
Sami : Autrement dit, un toit commun n'est pas une famille : c'est un contrat de souffle et d'ombre
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : écrire une synthèse qui retienne loyers, heures calmes et ce dont personne ne veut parler : la clé
Marc : synthétiser, ce n'est pas couper les aspérités jusqu'à ce que tout le monde ait l'air d'accord.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : la chronique de Lila Sow d'un côté, l'entretien écrit de Dieudonné Hakizimana de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Habiter autrement'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "la cour fermée à clé dès dix-neuf heures est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que la cour fermée à clé dès dix-neuf heures n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Habiter autrement'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Hawa Diallo sur « Habiter autrement » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Hawa Diallo sur « Habiter autrement » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Habiter autrement'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Faire des recommandations pour une mobilité qui n'écrase pas la pente. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Circuler à Rukiri-Nord
Lila Sow : Radio Figuier. On parle trop vite de la mobilité sur la pente de Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on élargisse la route des camions, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Patrick Habimana concède qu'un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Aline Uwase : Ce que l'on nomme mobilité, ici, n'est pas un slogan : façon de se déplacer, pas seulement de rouler.
Patrick Habimana : Nina dessine un trait trop droit : la pente, elle, n'est pas droite.
Hawa Diallo : Joël dit qu'un camion n'a pas d'oreilles pour un « attention ».
Joël Mugisha : Léa propose un relais sous le saule, non un klaxon de plus.
Rose Iradukunda : Karim chiffre les minutes gagnées et refuse des nommer un bonheur.
Solange Mukamana : Solange demande qui portera les jarres si le trottoir disparaît.
Karim Bamba : Dieudonné réparerait bien la rampe, pour autant qu'on la finance.
Félicie Ndayishimiye : Un chiffre, une trace : Joël a compté dix-huit lanternes, deux pauses, zéro place pour croiser un enfant.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de descendre vivant, pas seulement plus vite
Yvette : Sami court ; Yvette rappelle qu'un enfant n'est pas un obstacle.
Mado : Joël Mugisha entend, dans « fluidifier la colline », ceci qui n'est pas dit : fluidifier veut souvent dire faire passer les camions avant les genoux
Sami : Autrement dit, recommander, ce n'est pas crier : c'est dire ce qu'il convient de faire, et pour qui
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe
Marc : il convient que l'on nomme les genoux dans la motion, pas seulement les roues.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'émission de Radio Figuier d'un côté, la note de Nina Kayitesi sur la pente de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Circuler à Rukiri-Nord'
  AND l.competency = 'CO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Faire des recommandations pour une mobilité qui n'écrase pas la pente. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « La pente n'est pas une piste », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La pente n'est pas une piste
On parle trop vite de la mobilité sur la pente de Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Encore que l'on élargisse la route des camions, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède qu'un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Ce que l'on nomme mobilité, ici, n'est pas un slogan : façon de se déplacer, pas seulement de rouler.
Nina dessine un trait trop droit : la pente, elle, n'est pas droite.
Joël dit qu'un camion n'a pas d'oreilles pour un « attention ».
Léa propose un relais sous le saule, non un klaxon de plus.
Karim chiffre les minutes gagnées et refuse des nommer un bonheur.
Solange demande qui portera les jarres si le trottoir disparaît.
Dieudonné réparerait bien la rampe, pour autant qu'on la finance.
Un chiffre, une trace : Joël a compté dix-huit lanternes, deux pauses, zéro place pour croiser un enfant.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de descendre vivant, pas seulement plus vite
Sami court ; Yvette rappelle qu'un enfant n'est pas un obstacle.
Joël Mugisha entend, dans « fluidifier la colline », ceci qui n'est pas dit : fluidifier veut souvent dire faire passer les camions avant les genoux
Autrement dit, recommander, ce n'est pas crier : c'est dire ce qu'il convient de faire, et pour qui
La proposition qui reste debout est celle-ci : un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe
Marc : il convient que l'on nomme les genoux dans la motion, pas seulement les roues.
Nous clôturons sans fusionner les voix : l'émission de Radio Figuier d'un côté, la note de Nina Kayitesi sur la pente de l'autre, et le point où elles refusent de se ressembler.
Signé : Patrick Habimana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Circuler à Rukiri-Nord'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : il convient que / il s'agit de ; recommandations.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on élargisse la route des camions, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède qu'un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Ce que l'on nomme mobilité, ici, n'est pas un slogan : façon de se déplacer, pas seulement de rouler.
Encore que l'on ralentisse, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail.
Patrick Habimana concède qu'un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Autrement dit, recommander, ce n'est pas crier : c'est dire ce qu'il convient de faire, et pour qui
Il ressort qu'un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe
Joël dit qu'un camion n'a pas d'oreilles pour un « attention ».
Solange demande qui portera les jarres si le trottoir disparaît.
La proposition qui reste debout est celle-ci : un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'émission de Radio Figuier d'un côté, la note de Nina Kayitesi sur la pente de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Circuler à Rukiri-Nord'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Patrick Habimana transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Patrick Habimana concède qu'un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Circuler à Rukiri-Nord'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Faire des recommandations pour une mobilité qui n'écrase pas la pente. Point : il convient que / il s'agit de ; recommandations.

Consigne
Imitez le texte de Patrick Habimana.

Support — Patrick Habimana — La pente n'est pas une piste
Patrick Habimana — La pente n'est pas une piste
On parle trop vite de la mobilité sur la pente de Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Encore que l'on élargisse la route des camions, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède qu'un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Ce que l'on nomme mobilité, ici, n'est pas un slogan : façon de se déplacer, pas seulement de rouler.
Nina dessine un trait trop droit : la pente, elle, n'est pas droite.
Solange demande qui portera les jarres si le trottoir disparaît.
Dieudonné réparerait bien la rampe, pour autant qu'on la finance.
Sami court ; Yvette rappelle qu'un enfant n'est pas un obstacle.
La proposition qui reste debout est celle-ci : un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe
Marc : il convient que l'on nomme les genoux dans la motion, pas seulement les roues.
Nous clôturons sans fusionner les voix : l'émission de Radio Figuier d'un côté, la note de Nina Kayitesi sur la pente de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on ralentisse, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail.
Patrick Habimana concède qu'un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
recommander, ce n'est pas crier : c'est dire ce qu'il convient de faire, et pour qui
Patrick Habimana, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Circuler à Rukiri-Nord'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Patrick Habimana sur « Circuler à Rukiri-Nord » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Patrick Habimana sur « Circuler à Rukiri-Nord » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Circuler à Rukiri-Nord'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser il convient que / il s'agit de ; recommandations au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — il convient que / il s'agit de ; recommandations
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on ralentisse, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail.
Patrick Habimana concède qu'un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Autrement dit, recommander, ce n'est pas crier : c'est dire ce qu'il convient de faire, et pour qui
Il ressort qu'un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme mobilité, ici, n'est pas un slogan : façon de se déplacer, pas seulement de rouler.
Joël dit qu'un camion n'a pas d'oreilles pour un « attention ».
Solange demande qui portera les jarres si le trottoir disparaît.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au relais pour de vrai genre, et Joël Mugisha demande un registre plus net.
Correction : On va au relais vraiment, et Joël Mugisha demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Circuler à Rukiri-Nord'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Décrire une Rukiri-Nord imaginaire pour faire entendre une peur vraie. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Midi sans ombre
Lila Sow : Radio Figuier. On parle trop vite d'une Rukiri-Nord trop lisse, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface toute ombre sous le figuier, une tour qui avalerait midi n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que inventer peut aider à voir ce que le plan cache, pour autant que l'on n'oublie pas que le cauchemar parle du présent.
Aline Uwase : Ce que l'on nomme hypotypose, ici, n'est pas un slogan : description qui donne à voir, souvent au conditionnel.
Patrick Habimana : Mado écrit : la rivière prendrait une voix pour demander où l'on a mis ses roseaux.
Hawa Diallo : On dirait que les lanternes marcheraient toutes seules, fatiguées d'être portées.
Joël Mugisha : Si le figuier pouvait tousser, il tousserait la poussière des camions.
Aline : le conditionnel ici n'est pas une politesse, c'est une peinture.
Solange Mukamana : Patrick a peur des récits trop beaux : ils habillent souvent une coupe.
Karim Bamba : Rose coud une ombre trop large, exprès, pour le texte.
Félicie Ndayishimiye : Un chiffre, une trace : Dans le récit de Mado, midi n'a plus d'ombre à compter : zéro, dit-elle, et c'est déjà trop.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de reconnaître la peur avant qu'elle ne s'appelle progrès
Yvette : Joël n'aime pas les tours : elles n'ont pas de relais.
Mado : Sami entend, dans « ville parfaite », ceci qui n'est pas dit : la ville trop nette est souvent une ville où l'on n'a plus le droit de s'asseoir
Sami : Autrement dit, le fantastique ici n'est pas une évasion : c'est une loupe
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : écrire la colline comme si les racines parlaient, puis revenir au banc réel
Nina Kayitesi : Lila lira l'extrait à voix basse, comme si la colline écoutait.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'extrait inventé de Mado d'un côté, la photo de la pente prise par Léa de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Midi sans ombre'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une tour qui avalerait midi est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une tour qui avalerait midi n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Midi sans ombre'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Décrire une Rukiri-Nord imaginaire pour faire entendre une peur vraie. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Midi sans ombre », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Midi sans ombre
On parle trop vite d'une Rukiri-Nord trop lisse, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface toute ombre sous le figuier, une tour qui avalerait midi n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que inventer peut aider à voir ce que le plan cache, pour autant que l'on n'oublie pas que le cauchemar parle du présent.
Ce que l'on nomme hypotypose, ici, n'est pas un slogan : description qui donne à voir, souvent au conditionnel.
Mado écrit : la rivière prendrait une voix pour demander où l'on a mis ses roseaux.
On dirait que les lanternes marcheraient toutes seules, fatiguées d'être portées.
Si le figuier pouvait tousser, il tousserait la poussière des camions.
Aline : le conditionnel ici n'est pas une politesse, c'est une peinture.
Patrick a peur des récits trop beaux : ils habillent souvent une coupe.
Rose coud une ombre trop large, exprès, pour le texte.
Un chiffre, une trace : Dans le récit de Mado, midi n'a plus d'ombre à compter : zéro, dit-elle, et c'est déjà trop.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de reconnaître la peur avant qu'elle ne s'appelle progrès
Joël n'aime pas les tours : elles n'ont pas de relais.
Sami entend, dans « ville parfaite », ceci qui n'est pas dit : la ville trop nette est souvent une ville où l'on n'a plus le droit de s'asseoir
Autrement dit, le fantastique ici n'est pas une évasion : c'est une loupe
La proposition qui reste debout est celle-ci : écrire la colline comme si les racines parlaient, puis revenir au banc réel
Lila lira l'extrait à voix basse, comme si la colline écoutait.
Nous clôturons sans fusionner les voix : l'extrait inventé de Mado d'un côté, la photo de la pente prise par Léa de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Midi sans ombre'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Décrire une Rukiri-Nord imaginaire pour faire entendre une peur vraie. Point : conditionnel d'hypotypose ; comme si ; on dirait que.

Consigne
Imitez le texte de Mado.

Support — Mado — Midi sans ombre
Mado — Midi sans ombre
On parle trop vite d'une Rukiri-Nord trop lisse, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface toute ombre sous le figuier, une tour qui avalerait midi n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que inventer peut aider à voir ce que le plan cache, pour autant que l'on n'oublie pas que le cauchemar parle du présent.
Ce que l'on nomme hypotypose, ici, n'est pas un slogan : description qui donne à voir, souvent au conditionnel.
Mado écrit : la rivière prendrait une voix pour demander où l'on a mis ses roseaux.
Patrick a peur des récits trop beaux : ils habillent souvent une coupe.
Rose coud une ombre trop large, exprès, pour le texte.
Joël n'aime pas les tours : elles n'ont pas de relais.
La proposition qui reste debout est celle-ci : écrire la colline comme si les racines parlaient, puis revenir au banc réel
Lila lira l'extrait à voix basse, comme si la colline écoutait.
Nous clôturons sans fusionner les voix : l'extrait inventé de Mado d'un côté, la photo de la pente prise par Léa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on invente, une tour qui avalerait midi n'est pas un détail.
Mado concède que inventer peut aider à voir ce que le plan cache, pour autant que l'on n'oublie pas que le cauchemar parle du présent.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
le fantastique ici n'est pas une évasion : c'est une loupe
Mado, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Midi sans ombre'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Mado sur « Midi sans ombre » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Mado sur « Midi sans ombre » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Midi sans ombre'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Transformer l'analyse en motion claire pour l'assemblée sous le figuier. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Recommandations pour la colline
Lila Sow : Radio Figuier. On parle trop vite de la motion de la colline, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on signe trop vite une motion trop lisse, une action sans destinataires nommés n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé.
Aline Uwase : Ce que l'on nomme motion, ici, n'est pas un slogan : texte voté, plus précis qu'un cri.
Patrick Habimana : Solange lit trop vite ; Aline lui demande de nommer qui portera la rampe.
Hawa Diallo : Karim veut un calendrier, non une émotion.
Joël Mugisha : Léa rappelle la clé du Pavillon : la colline n'est pas qu'une route.
Rose Iradukunda : Joël demande un relais écrit, pas promis.
Solange Mukamana : Nina accepte de corriger le calque si la motion le force.
Karim Bamba : Dieudonné dit qu'il peut commencer jeudi, pour autant qu'on paie le fer.
Félicie Ndayishimiye : Un chiffre, une trace : Le banc a recensé onze voix pour la rampe, quatre abstentions, zéro pour le parking du figuier.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la motion puisse se relire dans un an sans honte
Yvette : une motion sans date est un oubli poli.
Mado : Karim Bamba entend, dans « passer à l'action », ceci qui n'est pas dit : passer à l'action peut servir à ne plus entendre ceux qui marchent lentement
Sami : Autrement dit, une recommandation nomme qui fait, qui paie, qui peut refuser
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : trois gestes datés — rampe, relais, heures de camions, signés par le Bureau des Escales
Nina Kayitesi : Marc clôt : en vue de l'hivernage, il convient que l'on vote les trois gestes, pas l'affiche.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les notes d'assemblée d'Aline d'un côté, le brouillon de Solange de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Recommandations pour la colline'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une action sans destinataires nommés est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une action sans destinataires nommés n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Recommandations pour la colline'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Transformer l'analyse en motion claire pour l'assemblée sous le figuier. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Trois gestes, pas un slogan », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Trois gestes, pas un slogan
On parle trop vite de la motion de la colline, comme si le mot dispensait d'en examiner le prix.
Encore que l'on signe trop vite une motion trop lisse, une action sans destinataires nommés n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé.
Ce que l'on nomme motion, ici, n'est pas un slogan : texte voté, plus précis qu'un cri.
Solange lit trop vite ; Aline lui demande de nommer qui portera la rampe.
Karim veut un calendrier, non une émotion.
Léa rappelle la clé du Pavillon : la colline n'est pas qu'une route.
Joël demande un relais écrit, pas promis.
Nina accepte de corriger le calque si la motion le force.
Dieudonné dit qu'il peut commencer jeudi, pour autant qu'on paie le fer.
Un chiffre, une trace : Le banc a recensé onze voix pour la rampe, quatre abstentions, zéro pour le parking du figuier.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la motion puisse se relire dans un an sans honte
Yvette : une motion sans date est un oubli poli.
Karim Bamba entend, dans « passer à l'action », ceci qui n'est pas dit : passer à l'action peut servir à ne plus entendre ceux qui marchent lentement
Autrement dit, une recommandation nomme qui fait, qui paie, qui peut refuser
La proposition qui reste debout est celle-ci : trois gestes datés — rampe, relais, heures de camions, signés par le Bureau des Escales
Marc clôt : en vue de l'hivernage, il convient que l'on vote les trois gestes, pas l'affiche.
Nous clôturons sans fusionner les voix : les notes d'assemblée d'Aline d'un côté, le brouillon de Solange de l'autre, et le point où elles refusent de se ressembler.
Signé : Solange Mukamana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Recommandations pour la colline'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : connecteurs de recommandation ; il convient que ; en vue de.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on signe trop vite une motion trop lisse, une action sans destinataires nommés n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé.
Ce que l'on nomme motion, ici, n'est pas un slogan : texte voté, plus précis qu'un cri.
Encore que l'on signe, une action sans destinataires nommés n'est pas un détail.
Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé.
Autrement dit, une recommandation nomme qui fait, qui paie, qui peut refuser
Il ressort que trois gestes datés : rampe, relais, heures de camions, signés par le Bureau des Escales
Karim veut un calendrier, non une émotion.
Nina accepte de corriger le calque si la motion le force.
La proposition qui reste debout est celle-ci : trois gestes datés — rampe, relais, heures de camions, signés par le Bureau des Escales
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les notes d'assemblée d'Aline d'un côté, le brouillon de Solange de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Recommandations pour la colline'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Transformer l'analyse en motion claire pour l'assemblée sous le figuier. Point : connecteurs de recommandation ; il convient que ; en vue de.

Consigne
Imitez le texte de Solange Mukamana.

Support — Solange Mukamana — Trois gestes, pas un slogan
Solange Mukamana — Trois gestes, pas un slogan
On parle trop vite de la motion de la colline, comme si le mot dispensait d'en examiner le prix.
Encore que l'on signe trop vite une motion trop lisse, une action sans destinataires nommés n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé.
Ce que l'on nomme motion, ici, n'est pas un slogan : texte voté, plus précis qu'un cri.
Solange lit trop vite ; Aline lui demande de nommer qui portera la rampe.
Nina accepte de corriger le calque si la motion le force.
Dieudonné dit qu'il peut commencer jeudi, pour autant qu'on paie le fer.
Yvette : une motion sans date est un oubli poli.
La proposition qui reste debout est celle-ci : trois gestes datés — rampe, relais, heures de camions, signés par le Bureau des Escales
Marc clôt : en vue de l'hivernage, il convient que l'on vote les trois gestes, pas l'affiche.
Nous clôturons sans fusionner les voix : les notes d'assemblée d'Aline d'un côté, le brouillon de Solange de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on signe, une action sans destinataires nommés n'est pas un détail.
Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
une recommandation nomme qui fait, qui paie, qui peut refuser
Solange Mukamana, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Recommandations pour la colline'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Solange Mukamana sur « Recommandations pour la colline » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Solange Mukamana sur « Recommandations pour la colline » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Recommandations pour la colline'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Rendre compte oralement de deux documents sur la colline, horizon inventé 2040. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Compte-rendu 2040
Lila Sow : Radio Figuier. On parle trop vite d'un horizon 2040 sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on annonce une colline sans files, un horizon qui n'a plus de bancs n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Aline Uwase : Ce que l'on nomme horizon, ici, n'est pas un slogan : projection, pas une excuse.
Patrick Habimana : Selon Nina, 2040 n'est qu'un calque pour forcer la rampe dès cette saison.
Hawa Diallo : D'après Marc, un horizon sans bancs n'est pas un avenir, c'est un oubli.
Joël Mugisha : Il ressort que les deux documents s'opposent sur la tour, pas sur la soif d'ombre.
Aline : on n'écrit pas « tout le monde pense », on écrit selon qui.
Solange Mukamana : Hawa refuse qu'on date 2040 pour ne plus dater les camions.
Karim Bamba : Joël demande si, en 2040, quelqu'un portera encore les lanternes.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a chronométré : quatre minutes, deux noms de sources, zéro slogan « ville parfaite ».
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que 2040 n'efface pas Joël sous les lanternes de 2026
Yvette : Mado glisse une phrase au conditionnel, puis rature : ce n'est plus le moment du fantastique.
Mado : Nina Kayitesi entend, dans « Rukiri-Nord 2040 », ceci qui n'est pas dit : 2040 sert parfois à ne plus devoir répondre des camions d'aujourd'hui
Sami : Autrement dit, le compte-rendu attribue : selon Nina ceci, d'après Marc cela, il ressort que la rampe précède la tour
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un oral de quatre minutes — deux sources, un désaccord, un geste 2026 qui rend 2040 habitable
Lila : le compte-rendu se clôt sur un geste, pas sur un nuage.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le calque annoté « 2040 » d'un côté, la chronique de Marc pour Radio Figuier de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Compte-rendu 2040'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un horizon qui n'a plus de bancs est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un horizon qui n'a plus de bancs n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Compte-rendu 2040'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rendre compte oralement de deux documents sur la colline, horizon inventé 2040. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « 2040 sans effacer 2026 », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — 2040 sans effacer 2026
On parle trop vite d'un horizon 2040 sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on annonce une colline sans files, un horizon qui n'a plus de bancs n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Ce que l'on nomme horizon, ici, n'est pas un slogan : projection, pas une excuse.
Selon Nina, 2040 n'est qu'un calque pour forcer la rampe dès cette saison.
D'après Marc, un horizon sans bancs n'est pas un avenir, c'est un oubli.
Il ressort que les deux documents s'opposent sur la tour, pas sur la soif d'ombre.
Aline : on n'écrit pas « tout le monde pense », on écrit selon qui.
Hawa refuse qu'on date 2040 pour ne plus dater les camions.
Joël demande si, en 2040, quelqu'un portera encore les lanternes.
Un chiffre, une trace : Léa a chronométré : quatre minutes, deux noms de sources, zéro slogan « ville parfaite ».
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que 2040 n'efface pas Joël sous les lanternes de 2026
Mado glisse une phrase au conditionnel, puis rature : ce n'est plus le moment du fantastique.
Nina Kayitesi entend, dans « Rukiri-Nord 2040 », ceci qui n'est pas dit : 2040 sert parfois à ne plus devoir répondre des camions d'aujourd'hui
Autrement dit, le compte-rendu attribue : selon Nina ceci, d'après Marc cela, il ressort que la rampe précède la tour
La proposition qui reste debout est celle-ci : un oral de quatre minutes — deux sources, un désaccord, un geste 2026 qui rend 2040 habitable
Lila : le compte-rendu se clôt sur un geste, pas sur un nuage.
Nous clôturons sans fusionner les voix : le calque annoté « 2040 » d'un côté, la chronique de Marc pour Radio Figuier de l'autre, et le point où elles refusent de se ressembler.
Signé : Marc Nkurunziza, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Compte-rendu 2040'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : selon / d'après / il ressort que ; attribution des sources.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on annonce une colline sans files, un horizon qui n'a plus de bancs n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Ce que l'on nomme horizon, ici, n'est pas un slogan : projection, pas une excuse.
Encore que l'on attribue, un horizon qui n'a plus de bancs n'est pas un détail.
Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Autrement dit, le compte-rendu attribue : selon Nina ceci, d'après Marc cela, il ressort que la rampe précède la tour
Il ressort qu'un oral de quatre minutes : deux sources, un désaccord, un geste 2026 qui rend 2040 habitable
D'après Marc, un horizon sans bancs n'est pas un avenir, c'est un oubli.
Hawa refuse qu'on date 2040 pour ne plus dater les camions.
La proposition qui reste debout est celle-ci : un oral de quatre minutes — deux sources, un désaccord, un geste 2026 qui rend 2040 habitable
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le calque annoté « 2040 » d'un côté, la chronique de Marc pour Radio Figuier de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Compte-rendu 2040'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Rendre compte oralement de deux documents sur la colline, horizon inventé 2040. Point : selon / d'après / il ressort que ; attribution des sources.

Consigne
Imitez le texte de Marc Nkurunziza.

Support — Marc Nkurunziza — 2040 sans effacer 2026
Marc Nkurunziza — 2040 sans effacer 2026
On parle trop vite d'un horizon 2040 sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on annonce une colline sans files, un horizon qui n'a plus de bancs n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Ce que l'on nomme horizon, ici, n'est pas un slogan : projection, pas une excuse.
Selon Nina, 2040 n'est qu'un calque pour forcer la rampe dès cette saison.
Hawa refuse qu'on date 2040 pour ne plus dater les camions.
Joël demande si, en 2040, quelqu'un portera encore les lanternes.
Mado glisse une phrase au conditionnel, puis rature : ce n'est plus le moment du fantastique.
La proposition qui reste debout est celle-ci : un oral de quatre minutes — deux sources, un désaccord, un geste 2026 qui rend 2040 habitable
Lila : le compte-rendu se clôt sur un geste, pas sur un nuage.
Nous clôturons sans fusionner les voix : le calque annoté « 2040 » d'un côté, la chronique de Marc pour Radio Figuier de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on attribue, un horizon qui n'a plus de bancs n'est pas un détail.
Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
le compte-rendu attribue : selon Nina ceci, d'après Marc cela, il ressort que la rampe précède la tour
Marc Nkurunziza, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Compte-rendu 2040'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Marc Nkurunziza sur « Compte-rendu 2040 » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Marc Nkurunziza sur « Compte-rendu 2040 » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Compte-rendu 2040'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser selon / d'après / il ressort que ; attribution des sources au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — selon / d'après / il ressort que ; attribution des sources
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on attribue, un horizon qui n'a plus de bancs n'est pas un détail.
Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Autrement dit, le compte-rendu attribue : selon Nina ceci, d'après Marc cela, il ressort que la rampe précède la tour
Il ressort qu'un oral de quatre minutes : deux sources, un désaccord, un geste 2026 qui rend 2040 habitable
Piège : fusionner les sources au lieu des attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme horizon, ici, n'est pas un slogan : projection, pas une excuse.
D'après Marc, un horizon sans bancs n'est pas un avenir, c'est un oubli.
Hawa refuse qu'on date 2040 pour ne plus dater les camions.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au geste pour de vrai genre, et Nina Kayitesi demande un registre plus net.
Correction : On va au geste vraiment, et Nina Kayitesi demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — La colline de demain'
  AND s.title = 'Compte-rendu 2040'
  AND l.competency = 'EL';

-- C1 — Faims du figuier
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Définir une faim qui n'est pas seulement le ventre et relier goûts et émotions. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le creux a un nom
Lila Sow : Radio Figuier. On parle trop vite de la faim qui n'est pas seulement le ventre, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on réduise la faim à un oubli de bol, une tristesse qui se déguise en appétit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Félicie Ndayishimiye concède qu'un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Aline Uwase : Ce que l'on nomme sensation, ici, n'est pas un slogan : information du corps, plus large que la faim.
Patrick Habimana : Félicie pose le bol et attend : le creux n'est pas toujours le ventre.
Hawa Diallo : Patrick croit qu'un proverbe suffit ; Aline demande une définition.
Joël Mugisha : Hawa dit qu'elle mange plus vite quand Radio Figuier parle trop fort.
Rose Iradukunda : Karim refuse de chiffrer la tristesse, mais il note les midis silencieux.
Solange Mukamana : Rose coud en goûtant : les mains savent ce que la bouche nie.
Karim Bamba : Sami rit trop fort ; Yvette entend la faim derrière le rire.
Félicie Ndayishimiye : Un chiffre, une trace : Félicie a noté sept midis sans parole, trois bols trop vite, une infusion trop chaude pour cacher les yeux.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de pouvoir dire j'ai faim de présence, non seulement de sel
Yvette : Oscar Niyitegeka apporte des feuilles : la terre aussi a des creux.
Mado : Aline Uwase entend, dans « juste un creux », ceci qui n'est pas dit : dire juste un creux permet souvent de ne pas nommer la solitude de midi
Sami : Autrement dit, la sensation n'est pas une faiblesse : c'est une information que le Seuil refuse trop vite
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser
Lila : définir, ce n'est pas accuser, c'est donner un nom qui ne fasse pas honte.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'article du Cahier du chemin d'un côté, le livre lu à voix haute par Mado de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Le creux a un nom'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une tristesse qui se déguise en appétit est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une tristesse qui se déguise en appétit n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Le creux a un nom'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Définir une faim qui n'est pas seulement le ventre et relier goûts et émotions. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le creux a un nom », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le creux a un nom
On parle trop vite de la faim qui n'est pas seulement le ventre, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise la faim à un oubli de bol, une tristesse qui se déguise en appétit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Félicie Ndayishimiye concède qu'un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Ce que l'on nomme sensation, ici, n'est pas un slogan : information du corps, plus large que la faim.
Félicie pose le bol et attend : le creux n'est pas toujours le ventre.
Patrick croit qu'un proverbe suffit ; Aline demande une définition.
Hawa dit qu'elle mange plus vite quand Radio Figuier parle trop fort.
Karim refuse de chiffrer la tristesse, mais il note les midis silencieux.
Rose coud en goûtant : les mains savent ce que la bouche nie.
Sami rit trop fort ; Yvette entend la faim derrière le rire.
Un chiffre, une trace : Félicie a noté sept midis sans parole, trois bols trop vite, une infusion trop chaude pour cacher les yeux.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de pouvoir dire j'ai faim de présence, non seulement de sel
Oscar Niyitegeka apporte des feuilles : la terre aussi a des creux.
Aline Uwase entend, dans « juste un creux », ceci qui n'est pas dit : dire juste un creux permet souvent de ne pas nommer la solitude de midi
Autrement dit, la sensation n'est pas une faiblesse : c'est une information que le Seuil refuse trop vite
La proposition qui reste debout est celle-ci : un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser
Lila : définir, ce n'est pas accuser, c'est donner un nom qui ne fasse pas honte.
Nous clôturons sans fusionner les voix : l'article du Cahier du chemin d'un côté, le livre lu à voix haute par Mado de l'autre, et le point où elles refusent de se ressembler.
Signé : Félicie Ndayishimiye, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Le creux a un nom'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : définir une notion ; cause émotionnelle ; nominalisation des sensations.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on réduise la faim à un oubli de bol, une tristesse qui se déguise en appétit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Félicie Ndayishimiye concède qu'un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Ce que l'on nomme sensation, ici, n'est pas un slogan : information du corps, plus large que la faim.
Encore que l'on nomme, une tristesse qui se déguise en appétit n'est pas un détail.
Félicie Ndayishimiye concède qu'un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Autrement dit, la sensation n'est pas une faiblesse : c'est une information que le Seuil refuse trop vite
Il ressort qu'un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser
Patrick croit qu'un proverbe suffit ; Aline demande une définition.
Rose coud en goûtant : les mains savent ce que la bouche nie.
La proposition qui reste debout est celle-ci : un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'article du Cahier du chemin d'un côté, le livre lu à voix haute par Mado de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Le creux a un nom'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Félicie Ndayishimiye transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Félicie Ndayishimiye concède qu'un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Le creux a un nom'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Définir une faim qui n'est pas seulement le ventre et relier goûts et émotions. Point : définir une notion ; cause émotionnelle ; nominalisation des sensations.

Consigne
Imitez le texte de Félicie Ndayishimiye.

Support — Félicie Ndayishimiye — Le creux a un nom
Félicie Ndayishimiye — Le creux a un nom
On parle trop vite de la faim qui n'est pas seulement le ventre, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise la faim à un oubli de bol, une tristesse qui se déguise en appétit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Félicie Ndayishimiye concède qu'un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Ce que l'on nomme sensation, ici, n'est pas un slogan : information du corps, plus large que la faim.
Félicie pose le bol et attend : le creux n'est pas toujours le ventre.
Rose coud en goûtant : les mains savent ce que la bouche nie.
Sami rit trop fort ; Yvette entend la faim derrière le rire.
Oscar Niyitegeka apporte des feuilles : la terre aussi a des creux.
La proposition qui reste debout est celle-ci : un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser
Lila : définir, ce n'est pas accuser, c'est donner un nom qui ne fasse pas honte.
Nous clôturons sans fusionner les voix : l'article du Cahier du chemin d'un côté, le livre lu à voix haute par Mado de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on nomme, une tristesse qui se déguise en appétit n'est pas un détail.
Félicie Ndayishimiye concède qu'un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
la sensation n'est pas une faiblesse : c'est une information que le Seuil refuse trop vite
Félicie Ndayishimiye, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Le creux a un nom'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Félicie Ndayishimiye sur « Le creux a un nom » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Félicie Ndayishimiye sur « Le creux a un nom » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Le creux a un nom'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser définir une notion ; cause émotionnelle ; nominalisation des sensations au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — définir une notion ; cause émotionnelle ; nominalisation des sensations
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on nomme, une tristesse qui se déguise en appétit n'est pas un détail.
Félicie Ndayishimiye concède qu'un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Autrement dit, la sensation n'est pas une faiblesse : c'est une information que le Seuil refuse trop vite
Il ressort qu'un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser
Piège : indicatif après encore que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme sensation, ici, n'est pas un slogan : information du corps, plus large que la faim.
Patrick croit qu'un proverbe suffit ; Aline demande une définition.
Rose coud en goûtant : les mains savent ce que la bouche nie.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au solitude pour de vrai genre, et Aline Uwase demande un registre plus net.
Correction : On va au solitude vraiment, et Aline Uwase demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Le creux a un nom'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Restituer des données inventées du Filtre des Herbes sans en faire une sentence. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Un tiers n'est pas une morale
Lila Sow : Radio Figuier. On parle trop vite des rations inventées du Filtre des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on close le débat par un pourcentage, un rapport qui n'a pas goûté le bol n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Karim Bamba concède qu'un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Aline Uwase : Ce que l'on nomme statistique, ici, n'est pas un slogan : donnée chiffrée, pas une sentence.
Patrick Habimana : Karim lit le graphique sans sourire : un tiers n'est pas une foule, c'est une alerte.
Hawa Diallo : Oscar dit que le jeudi, la terre a soif avant les étiquettes.
Joël Mugisha : Inès objecte : le sel excessif n'explique pas tous les maux, il en éclaire certains.
Aline : alors que le pourcentage monte, le bol de Félicie, lui, se vide trop vite.
Solange Mukamana : Léa demande qui a pesé, et à quelle heure d'ombre.
Karim Bamba : Marc refuse la formule les chiffres parlent : quelqu'un les a fait parler.
Félicie Ndayishimiye : Un chiffre, une trace : Le Filtre annonce : près d'un bol sur trois trop salé, deux jardins moins arrosés, une file plus longue le jeudi.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la santé du Seuil ne soit pas un slogan chiffré
Yvette : Lila cittera le Filtre et l'entretien, pas l'un contre l'autre comme une guerre.
Mado : Inès Mukama entend, dans « les chiffres parlent d'eux-mêmes », ceci qui n'est pas dit : les chiffres parlent d'eux-mêmes veut souvent dire ne me posez plus de questions
Sami : Autrement dit, s'établir à un tiers n'est pas prouver une morale : c'est ouvrir une lecture
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un article qui cite le Filtre, oppose alors que, et refuse la sentence
Hawa : restituer, c'est garder le doute là où le rapport trop lisse le cache.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le graphique du Filtre des Herbes d'un côté, l'entretien d'Oscar au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Un tiers n''est pas une morale'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un rapport qui n'a pas goûté le bol est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un rapport qui n'a pas goûté le bol n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Un tiers n''est pas une morale'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Restituer des données inventées du Filtre des Herbes sans en faire une sentence. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Un tiers n'est pas une morale », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Un tiers n'est pas une morale
On parle trop vite des rations inventées du Filtre des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on close le débat par un pourcentage, un rapport qui n'a pas goûté le bol n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède qu'un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Ce que l'on nomme statistique, ici, n'est pas un slogan : donnée chiffrée, pas une sentence.
Karim lit le graphique sans sourire : un tiers n'est pas une foule, c'est une alerte.
Oscar dit que le jeudi, la terre a soif avant les étiquettes.
Inès objecte : le sel excessif n'explique pas tous les maux, il en éclaire certains.
Aline : alors que le pourcentage monte, le bol de Félicie, lui, se vide trop vite.
Léa demande qui a pesé, et à quelle heure d'ombre.
Marc refuse la formule les chiffres parlent : quelqu'un les a fait parler.
Un chiffre, une trace : Le Filtre annonce : près d'un bol sur trois trop salé, deux jardins moins arrosés, une file plus longue le jeudi.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la santé du Seuil ne soit pas un slogan chiffré
Lila cittera le Filtre et l'entretien, pas l'un contre l'autre comme une guerre.
Inès Mukama entend, dans « les chiffres parlent d'eux-mêmes », ceci qui n'est pas dit : les chiffres parlent d'eux-mêmes veut souvent dire ne me posez plus de questions
Autrement dit, s'établir à un tiers n'est pas prouver une morale : c'est ouvrir une lecture
La proposition qui reste debout est celle-ci : un article qui cite le Filtre, oppose alors que, et refuse la sentence
Hawa : restituer, c'est garder le doute là où le rapport trop lisse le cache.
Nous clôturons sans fusionner les voix : le graphique du Filtre des Herbes d'un côté, l'entretien d'Oscar au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
Signé : Karim Bamba, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Un tiers n''est pas une morale'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : commenter des chiffres ; s'établir à ; alors que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on close le débat par un pourcentage, un rapport qui n'a pas goûté le bol n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède qu'un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Ce que l'on nomme statistique, ici, n'est pas un slogan : donnée chiffrée, pas une sentence.
Encore que l'on pèse, un rapport qui n'a pas goûté le bol n'est pas un détail.
Karim Bamba concède qu'un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Autrement dit, s'établir à un tiers n'est pas prouver une morale : c'est ouvrir une lecture
Il ressort qu'un article qui cite le Filtre, oppose alors que, et refuse la sentence
Oscar dit que le jeudi, la terre a soif avant les étiquettes.
Léa demande qui a pesé, et à quelle heure d'ombre.
La proposition qui reste debout est celle-ci : un article qui cite le Filtre, oppose alors que, et refuse la sentence
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le graphique du Filtre des Herbes d'un côté, l'entretien d'Oscar au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Un tiers n''est pas une morale'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Karim Bamba transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Karim Bamba concède qu'un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Un tiers n''est pas une morale'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Restituer des données inventées du Filtre des Herbes sans en faire une sentence. Point : commenter des chiffres ; s'établir à ; alors que.

Consigne
Imitez le texte de Karim Bamba.

Support — Karim Bamba — Un tiers n'est pas une morale
Karim Bamba — Un tiers n'est pas une morale
On parle trop vite des rations inventées du Filtre des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on close le débat par un pourcentage, un rapport qui n'a pas goûté le bol n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède qu'un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Ce que l'on nomme statistique, ici, n'est pas un slogan : donnée chiffrée, pas une sentence.
Karim lit le graphique sans sourire : un tiers n'est pas une foule, c'est une alerte.
Léa demande qui a pesé, et à quelle heure d'ombre.
Marc refuse la formule les chiffres parlent : quelqu'un les a fait parler.
Lila cittera le Filtre et l'entretien, pas l'un contre l'autre comme une guerre.
La proposition qui reste debout est celle-ci : un article qui cite le Filtre, oppose alors que, et refuse la sentence
Hawa : restituer, c'est garder le doute là où le rapport trop lisse le cache.
Nous clôturons sans fusionner les voix : le graphique du Filtre des Herbes d'un côté, l'entretien d'Oscar au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on pèse, un rapport qui n'a pas goûté le bol n'est pas un détail.
Karim Bamba concède qu'un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
s'établir à un tiers n'est pas prouver une morale : c'est ouvrir une lecture
Karim Bamba, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Un tiers n''est pas une morale'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Karim Bamba sur « Un tiers n’est pas une morale » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Karim Bamba sur « Un tiers n’est pas une morale » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Un tiers n''est pas une morale'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser commenter des chiffres ; s'établir à ; alors que au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — commenter des chiffres ; s'établir à ; alors que
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on pèse, un rapport qui n'a pas goûté le bol n'est pas un détail.
Karim Bamba concède qu'un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Autrement dit, s'établir à un tiers n'est pas prouver une morale : c'est ouvrir une lecture
Il ressort qu'un article qui cite le Filtre, oppose alors que, et refuse la sentence
Piège : prendre un pourcentage pour une preuve morale
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme statistique, ici, n'est pas un slogan : donnée chiffrée, pas une sentence.
Oscar dit que le jeudi, la terre a soif avant les étiquettes.
Léa demande qui a pesé, et à quelle heure d'ombre.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au graphique pour de vrai genre, et Inès Mukama demande un registre plus net.
Correction : On va au graphique vraiment, et Inès Mukama demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Un tiers n''est pas une morale'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Analyser et commenter un fait de société : la colère de ceux qui font pousser. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — La terre n'est pas un caprice
Lila Sow : Radio Figuier. On parle trop vite de la colère des jardiniers de la rive, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on réduise la colère à un caprice de saison, un prix de la terre qui flambe sans que les mains soient payées n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Oscar Niyitegeka concède que le Marché des Lampions attire des regards, pour autant que l'on n'y voie pas le droit d'oublier qui a planté.
Aline Uwase : Ce que l'on nomme colère, ici, n'est pas un slogan : signal politique, pas un caprice.
Patrick Habimana : Oscar parle bas : la colère trop criée sert ceux qui n'écoutent que le volume.
Hawa Diallo : Du fait que le prix flambe, les aides s'en vont, si bien que la rive maigrit.
Joël Mugisha : Félicie entend la terre avant d'entendre le slogan.
Rose Iradukunda : Patrick veut un exposé, pas une bagarre de bancs.
Solange Mukamana : Solange demande qui profite du brillant des Lampions.
Karim Bamba : Dieudonné réparerait les clôtures, pour autant qu'on cesse des voler pour le décor.
Félicie Ndayishimiye : Un chiffre, une trace : Oscar a perdu deux aides cette lune ; la file des Herbes s'allonge d'une heure ; le Lampions vend plus brillant.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la rive reste une rive nourricière, non un décor
Yvette : un fait de société a des visages, pas seulement des causes.
Mado : Karim Bamba entend, dans « ils exagèrent », ceci qui n'est pas dit : ils exagèrent signifie souvent nous ne voulons pas entendre le prix réel
Sami : Autrement dit, un fait de société se commente : causes, conséquences, visages, pas un cri contre un cri
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi
Marc : commenter, c'est refuser ils exagèrent comme seule analyse.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le récit d'Oscar au Cahier des racines d'un côté, le reportage inventé de Lila au marché de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'La terre n''est pas un caprice'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un prix de la terre qui flambe sans que les mains soient payées est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un prix de la terre qui flambe sans que les mains soient payées n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'La terre n''est pas un caprice'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Reformulez l'implicite de « ils exagèrent » et la concession d'Oscar Niyitegeka."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'La terre n''est pas un caprice'
  AND l.competency = 'CO'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Analyser et commenter un fait de société : la colère de ceux qui font pousser. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « La terre n'est pas un caprice », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La terre n'est pas un caprice
On parle trop vite de la colère des jardiniers de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise la colère à un caprice de saison, un prix de la terre qui flambe sans que les mains soient payées n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Oscar Niyitegeka concède que le Marché des Lampions attire des regards, pour autant que l'on n'y voie pas le droit d'oublier qui a planté.
Ce que l'on nomme colère, ici, n'est pas un slogan : signal politique, pas un caprice.
Oscar parle bas : la colère trop criée sert ceux qui n'écoutent que le volume.
Du fait que le prix flambe, les aides s'en vont, si bien que la rive maigrit.
Félicie entend la terre avant d'entendre le slogan.
Patrick veut un exposé, pas une bagarre de bancs.
Solange demande qui profite du brillant des Lampions.
Dieudonné réparerait les clôtures, pour autant qu'on cesse des voler pour le décor.
Un chiffre, une trace : Oscar a perdu deux aides cette lune ; la file des Herbes s'allonge d'une heure ; le Lampions vend plus brillant.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la rive reste une rive nourricière, non un décor
Yvette : un fait de société a des visages, pas seulement des causes.
Karim Bamba entend, dans « ils exagèrent », ceci qui n'est pas dit : ils exagèrent signifie souvent nous ne voulons pas entendre le prix réel
Autrement dit, un fait de société se commente : causes, conséquences, visages, pas un cri contre un cri
La proposition qui reste debout est celle-ci : un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi
Marc : commenter, c'est refuser ils exagèrent comme seule analyse.
Nous clôturons sans fusionner les voix : le récit d'Oscar au Cahier des racines d'un côté, le reportage inventé de Lila au marché de l'autre, et le point où elles refusent de se ressembler.
Signé : Oscar Niyitegeka, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'La terre n''est pas un caprice'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Analyser et commenter un fait de société : la colère de ceux qui font pousser. Point : cause et conséquence avancées ; du fait que ; si bien que.

Consigne
Imitez le texte d'Oscar Niyitegeka.

Support — Oscar Niyitegeka — La terre n'est pas un caprice
Oscar Niyitegeka — La terre n'est pas un caprice
On parle trop vite de la colère des jardiniers de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise la colère à un caprice de saison, un prix de la terre qui flambe sans que les mains soient payées n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Oscar Niyitegeka concède que le Marché des Lampions attire des regards, pour autant que l'on n'y voie pas le droit d'oublier qui a planté.
Ce que l'on nomme colère, ici, n'est pas un slogan : signal politique, pas un caprice.
Oscar parle bas : la colère trop criée sert ceux qui n'écoutent que le volume.
Solange demande qui profite du brillant des Lampions.
Dieudonné réparerait les clôtures, pour autant qu'on cesse des voler pour le décor.
Yvette : un fait de société a des visages, pas seulement des causes.
La proposition qui reste debout est celle-ci : un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi
Marc : commenter, c'est refuser ils exagèrent comme seule analyse.
Nous clôturons sans fusionner les voix : le récit d'Oscar au Cahier des racines d'un côté, le reportage inventé de Lila au marché de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on écoute, un prix de la terre qui flambe sans que les mains soient payées n'est pas un détail.
Oscar Niyitegeka concède que le Marché des Lampions attire des regards, pour autant que l'on n'y voie pas le droit d'oublier qui a planté.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
un fait de société se commente : causes, conséquences, visages, pas un cri contre un cri
Oscar Niyitegeka, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'La terre n''est pas un caprice'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos d'Oscar Niyitegeka sur « La terre n’est pas un caprice » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos d'Oscar Niyitegeka sur « La terre n’est pas un caprice » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'La terre n''est pas un caprice'
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
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'La terre n''est pas un caprice'
  AND l.competency = 'PE'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Conseiller des achats sans ordonner, et peser une application inventée. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Choisir au marché
Lila Sow : Radio Figuier. On parle trop vite de l'application inventée Fil-des-Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace le goût par un score, une étiquette qui parle plus fort que Félicie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Je concède qu'un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Aline Uwase : Ce que l'on nomme étiquette, ici, n'est pas un slogan : texte sur le bol, à lire deux fois.
Patrick Habimana : Léa ouvre Fil-des-Herbes et rit : le bol d'Oscar n'a pas de page.
Hawa Diallo : On ferait mieux de lire l'étiquette deux fois, dit Inès, non l'écran une fois.
Joël Mugisha : Karim voit l'avantage : le sel apparaît. Il voit le piège : les mains disparaissent.
Rose : un conseil n'élève pas la voix.
Solange Mukamana : Joël achète trop vite quand le score est vert ; Aline le ralentit.
Karim Bamba : Sami aime l'outil ; Yvette demande qui l'a payé.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a comparé : trois scores verts, un bol trop cher, zéro mention des mains d'Oscar.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de choisir sans se laisser choisir par un slogan doux
Lila : présenter avantages et limites, ce n'est pas condamner l'outil, c'est refuser l'obéissance.
Mado : Félicie Ndayishimiye entend, dans « mieux choisir », ceci qui n'est pas dit : mieux choisir veut souvent dire mieux obéir à un écran qu'à une file
Sami : Autrement dit, l'outil peut être un avis ; il ne doit pas devenir une loi de marché
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois
Marc : il vaudrait mieux que tu lises le bol avant le slogan.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : la notice du Fil-des-Herbes d'un côté, l'émission de Lila au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Choisir au marché'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une étiquette qui parle plus fort que Félicie est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une étiquette qui parle plus fort que Félicie n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Choisir au marché'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Conseiller des achats sans ordonner, et peser une application inventée. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le score n'est pas le goût », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le score n'est pas le goût
On parle trop vite de l'application inventée Fil-des-Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le goût par un score, une étiquette qui parle plus fort que Félicie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède qu'un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Ce que l'on nomme étiquette, ici, n'est pas un slogan : texte sur le bol, à lire deux fois.
Léa ouvre Fil-des-Herbes et rit : le bol d'Oscar n'a pas de page.
On ferait mieux de lire l'étiquette deux fois, dit Inès, non l'écran une fois.
Karim voit l'avantage : le sel apparaît. Il voit le piège : les mains disparaissent.
Rose : un conseil n'élève pas la voix.
Joël achète trop vite quand le score est vert ; Aline le ralentit.
Sami aime l'outil ; Yvette demande qui l'a payé.
Un chiffre, une trace : Léa a comparé : trois scores verts, un bol trop cher, zéro mention des mains d'Oscar.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de choisir sans se laisser choisir par un slogan doux
Lila : présenter avantages et limites, ce n'est pas condamner l'outil, c'est refuser l'obéissance.
Félicie Ndayishimiye entend, dans « mieux choisir », ceci qui n'est pas dit : mieux choisir veut souvent dire mieux obéir à un écran qu'à une file
Autrement dit, l'outil peut être un avis ; il ne doit pas devenir une loi de marché
La proposition qui reste debout est celle-ci : échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois
Marc : il vaudrait mieux que tu lises le bol avant le slogan.
Nous clôturons sans fusionner les voix : la notice du Fil-des-Herbes d'un côté, l'émission de Lila au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Choisir au marché'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : conseil atténué ; on ferait mieux de ; il vaudrait mieux que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace le goût par un score, une étiquette qui parle plus fort que Félicie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède qu'un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Ce que l'on nomme étiquette, ici, n'est pas un slogan : texte sur le bol, à lire deux fois.
Encore que l'on lises, une étiquette qui parle plus fort que Félicie n'est pas un détail.
Léa Niyonzima concède qu'un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Autrement dit, l'outil peut être un avis ; il ne doit pas devenir une loi de marché
Il ressort qu'échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois
On ferait mieux de lire l'étiquette deux fois, dit Inès, non l'écran une fois.
Joël achète trop vite quand le score est vert ; Aline le ralentit.
La proposition qui reste debout est celle-ci : échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : la notice du Fil-des-Herbes d'un côté, l'émission de Lila au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Choisir au marché'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Léa Niyonzima transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Léa Niyonzima concède qu'un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Choisir au marché'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Conseiller des achats sans ordonner, et peser une application inventée. Point : conseil atténué ; on ferait mieux de ; il vaudrait mieux que.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Le score n'est pas le goût
Léa Niyonzima — Le score n'est pas le goût
On parle trop vite de l'application inventée Fil-des-Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le goût par un score, une étiquette qui parle plus fort que Félicie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède qu'un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Ce que l'on nomme étiquette, ici, n'est pas un slogan : texte sur le bol, à lire deux fois.
Léa ouvre Fil-des-Herbes et rit : le bol d'Oscar n'a pas de page.
Joël achète trop vite quand le score est vert ; Aline le ralentit.
Sami aime l'outil ; Yvette demande qui l'a payé.
Lila : présenter avantages et limites, ce n'est pas condamner l'outil, c'est refuser l'obéissance.
La proposition qui reste debout est celle-ci : échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois
Marc : il vaudrait mieux que tu lises le bol avant le slogan.
Nous clôturons sans fusionner les voix : la notice du Fil-des-Herbes d'un côté, l'émission de Lila au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on lises, une étiquette qui parle plus fort que Félicie n'est pas un détail.
Léa Niyonzima concède qu'un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
l'outil peut être un avis ; il ne doit pas devenir une loi de marché
Léa Niyonzima, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Choisir au marché'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Léa Niyonzima sur « Choisir au marché » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Léa Niyonzima sur « Choisir au marché » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Choisir au marché'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser conseil atténué ; on ferait mieux de ; il vaudrait mieux que au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — conseil atténué ; on ferait mieux de ; il vaudrait mieux que
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on lises, une étiquette qui parle plus fort que Félicie n'est pas un détail.
Léa Niyonzima concède qu'un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Autrement dit, l'outil peut être un avis ; il ne doit pas devenir une loi de marché
Il ressort qu'échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois
Piège : impératif brutal à la place du conditionnel de conseil
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme étiquette, ici, n'est pas un slogan : texte sur le bol, à lire deux fois.
On ferait mieux de lire l'étiquette deux fois, dit Inès, non l'écran une fois.
Joël achète trop vite quand le score est vert ; Aline le ralentit.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au application pour de vrai genre, et Félicie Ndayishimiye demande un registre plus net.
Correction : On va au application vraiment, et Félicie Ndayishimiye demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Choisir au marché'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Débattre du marketing du Marché des Lampions sans slogan contre slogan. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Débat marketing
Lila Sow : Radio Figuier. On parle trop vite du marketing du Marché des Lampions, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on habille le sel d'un mot doux, une affiche qui cache le prix des mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Karim Bamba concède qu'une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Aline Uwase : Ce que l'on nomme affiche, ici, n'est pas un slogan : enseigne argumentée ou menteuse selon les mots.
Karim : certes l'enseigne guide, mais elle n'a pas à guérir.
Hawa Diallo : Inès refuse que le mot santé soit collé au sel brillant.
Joël Mugisha : Félicie n'a pas besoin d'un mot doux pour savoir si le bol nourrit.
Rose Iradukunda : Oscar n'apparaît pas sur l'affiche : c'est déjà un argument.
Aline : encore que l'on discute le graphisme, le prix minuscule est une politique.
Karim Bamba : Léa propose un débat pour / contre, avec concession obligatoire.
Félicie Ndayishimiye : Un chiffre, une trace : Lila a relevé cinq mots doux sur l'affiche, zéro nom de jardinier, un prix en petits caractères.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la publicité inventée n'emprunte pas la voix de l'infirmerie
Yvette : Sami aime le brillant ; Yvette demande le coût.
Mado : Inès Mukama entend, dans « le brillant rend heureux », ceci qui n'est pas dit : le brillant rend heureux sert à ne plus demander qui a planté
Sami : Autrement dit, certes l'affiche attire, mais elle n'a pas le droit de se faire passer pour un soin
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un débat — avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel
Lila : Radio Figuier n'est pas une affiche, même quand elle parle des Lampions.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'affiche du Marché des Lampions d'un côté, la chronique de Karim de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Débat marketing'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une affiche qui cache le prix des mains est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une affiche qui cache le prix des mains n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Débat marketing'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Débattre du marketing du Marché des Lampions sans slogan contre slogan. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le mot doux n'est pas un soin », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le mot doux n'est pas un soin
On parle trop vite du marketing du Marché des Lampions, comme si le mot dispensait d'en examiner le prix.
Encore que l'on habille le sel d'un mot doux, une affiche qui cache le prix des mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède qu'une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Ce que l'on nomme affiche, ici, n'est pas un slogan : enseigne argumentée ou menteuse selon les mots.
Karim : certes l'enseigne guide, mais elle n'a pas à guérir.
Inès refuse que le mot santé soit collé au sel brillant.
Félicie n'a pas besoin d'un mot doux pour savoir si le bol nourrit.
Oscar n'apparaît pas sur l'affiche : c'est déjà un argument.
Aline : encore que l'on discute le graphisme, le prix minuscule est une politique.
Léa propose un débat pour / contre, avec concession obligatoire.
Un chiffre, une trace : Lila a relevé cinq mots doux sur l'affiche, zéro nom de jardinier, un prix en petits caractères.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la publicité inventée n'emprunte pas la voix de l'infirmerie
Sami aime le brillant ; Yvette demande le coût.
Inès Mukama entend, dans « le brillant rend heureux », ceci qui n'est pas dit : le brillant rend heureux sert à ne plus demander qui a planté
Autrement dit, certes l'affiche attire, mais elle n'a pas le droit de se faire passer pour un soin
La proposition qui reste debout est celle-ci : un débat — avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel
Lila : Radio Figuier n'est pas une affiche, même quand elle parle des Lampions.
Nous clôturons sans fusionner les voix : l'affiche du Marché des Lampions d'un côté, la chronique de Karim de l'autre, et le point où elles refusent de se ressembler.
Signé : Karim Bamba, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Débat marketing'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : certes… mais ; encore que ; avantages et inconvénients.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on habille le sel d'un mot doux, une affiche qui cache le prix des mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède qu'une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Ce que l'on nomme affiche, ici, n'est pas un slogan : enseigne argumentée ou menteuse selon les mots.
Encore que l'on discute, une affiche qui cache le prix des mains n'est pas un détail.
Karim Bamba concède qu'une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Autrement dit, certes l'affiche attire, mais elle n'a pas le droit de se faire passer pour un soin
Il ressort qu'un débat : avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel
Inès refuse que le mot santé soit collé au sel brillant.
Aline : encore que l'on discute le graphisme, le prix minuscule est une politique.
La proposition qui reste debout est celle-ci : un débat — avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'affiche du Marché des Lampions d'un côté, la chronique de Karim de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Débat marketing'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Karim Bamba transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Karim Bamba concède qu'une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Débat marketing'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Débattre du marketing du Marché des Lampions sans slogan contre slogan. Point : certes… mais ; encore que ; avantages et inconvénients.

Consigne
Imitez le texte de Karim Bamba.

Support — Karim Bamba — Le mot doux n'est pas un soin
Karim Bamba — Le mot doux n'est pas un soin
On parle trop vite du marketing du Marché des Lampions, comme si le mot dispensait d'en examiner le prix.
Encore que l'on habille le sel d'un mot doux, une affiche qui cache le prix des mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède qu'une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Ce que l'on nomme affiche, ici, n'est pas un slogan : enseigne argumentée ou menteuse selon les mots.
Karim : certes l'enseigne guide, mais elle n'a pas à guérir.
Aline : encore que l'on discute le graphisme, le prix minuscule est une politique.
Léa propose un débat pour / contre, avec concession obligatoire.
Sami aime le brillant ; Yvette demande le coût.
La proposition qui reste debout est celle-ci : un débat — avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel
Lila : Radio Figuier n'est pas une affiche, même quand elle parle des Lampions.
Nous clôturons sans fusionner les voix : l'affiche du Marché des Lampions d'un côté, la chronique de Karim de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on discute, une affiche qui cache le prix des mains n'est pas un détail.
Karim Bamba concède qu'une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
certes l'affiche attire, mais elle n'a pas le droit de se faire passer pour un soin
Karim Bamba, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Débat marketing'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Karim Bamba sur « Débat marketing » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Karim Bamba sur « Débat marketing » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Débat marketing'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser certes… mais ; encore que ; avantages et inconvénients au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — certes… mais ; encore que ; avantages et inconvénients
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on discute, une affiche qui cache le prix des mains n'est pas un détail.
Karim Bamba concède qu'une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Autrement dit, certes l'affiche attire, mais elle n'a pas le droit de se faire passer pour un soin
Il ressort qu'un débat : avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel
Piège : indicatif après encore que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme affiche, ici, n'est pas un slogan : enseigne argumentée ou menteuse selon les mots.
Inès refuse que le mot santé soit collé au sel brillant.
Aline : encore que l'on discute le graphisme, le prix minuscule est une politique.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au promesse pour de vrai genre, et Inès Mukama demande un registre plus net.
Correction : On va au promesse vraiment, et Inès Mukama demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Débat marketing'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Composer un recueil de plaisirs minuscules ancré dans le Seuil, sans morale lourde. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Huit notices sous le figuier
Lila Sow : Radio Figuier. On parle trop vite des plaisirs minuscules du figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme le plaisir en consigne, une joie ordonnée comme un score n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que écrire le plaisir peut le rendre partageable, pour autant que l'on n'en fasse pas une leçon de bien manger.
Aline Uwase : Ce que l'on nomme plaisir, ici, n'est pas un slogan : expérience minuscule, non une consigne.
Mado : on dirait que l'ombre du figuier aurait un goût de thé trop infusé, et ce serait assez.
Hawa Diallo : Félicie ajoute une notice : le bol chaud quand personne n'interroge.
Joël Mugisha : Aline refuse l'impératif jouissez.
Rose Iradukunda : Patrick sourit d'une feuille croquée sans discours.
Solange Mukamana : Rose coud un signet trop simple, exprès.
Karim Bamba : Sami veut une notice drôle ; Yvette en veut une lente.
Félicie Ndayishimiye : Un chiffre, une trace : Mado a écrit huit notices ; Lila n'en lira que cinq, les trois trop morales restent dans le tiroir.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de goûter sans se faire discipliner par un slogan de table
Yvette : Oscar glisse une terre sous l'ongle : cela aussi est un plaisir, dit-il, sans le vendre.
Mado : Félicie Ndayishimiye entend, dans « il faut jouir », ceci qui n'est pas dit : il faut jouir ressemble trop à une affiche pour n'être pas un ordre déguisé
Sami : Autrement dit, le minuscule ici, c'est ce qui n'a pas besoin d'affiche : l'ombre, le bol, la feuille
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : huit notices de plaisir, au conditionnel parfois, sans injonction
Nina Kayitesi : Lila lira sans musique : le minuscule n'a pas besoin d'orchestre.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le recueil de Mado d'un côté, les notes de Félicie au bas des pages de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Huit notices sous le figuier'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une joie ordonnée comme un score est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une joie ordonnée comme un score n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Huit notices sous le figuier'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Composer un recueil de plaisirs minuscules ancré dans le Seuil, sans morale lourde. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Huit notices, pas une leçon », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Huit notices, pas une leçon
On parle trop vite des plaisirs minuscules du figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le plaisir en consigne, une joie ordonnée comme un score n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que écrire le plaisir peut le rendre partageable, pour autant que l'on n'en fasse pas une leçon de bien manger.
Ce que l'on nomme plaisir, ici, n'est pas un slogan : expérience minuscule, non une consigne.
Mado : on dirait que l'ombre du figuier aurait un goût de thé trop infusé, et ce serait assez.
Félicie ajoute une notice : le bol chaud quand personne n'interroge.
Aline refuse l'impératif jouissez.
Patrick sourit d'une feuille croquée sans discours.
Rose coud un signet trop simple, exprès.
Sami veut une notice drôle ; Yvette en veut une lente.
Un chiffre, une trace : Mado a écrit huit notices ; Lila n'en lira que cinq, les trois trop morales restent dans le tiroir.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de goûter sans se faire discipliner par un slogan de table
Oscar glisse une terre sous l'ongle : cela aussi est un plaisir, dit-il, sans le vendre.
Félicie Ndayishimiye entend, dans « il faut jouir », ceci qui n'est pas dit : il faut jouir ressemble trop à une affiche pour n'être pas un ordre déguisé
Autrement dit, le minuscule ici, c'est ce qui n'a pas besoin d'affiche : l'ombre, le bol, la feuille
La proposition qui reste debout est celle-ci : huit notices de plaisir, au conditionnel parfois, sans injonction
Lila lira sans musique : le minuscule n'a pas besoin d'orchestre.
Nous clôturons sans fusionner les voix : le recueil de Mado d'un côté, les notes de Félicie au bas des pages de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Huit notices sous le figuier'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Composer un recueil de plaisirs minuscules ancré dans le Seuil, sans morale lourde. Point : écriture créative encadrée ; nominalisation des sensations.

Consigne
Imitez le texte de Mado.

Support — Mado — Huit notices, pas une leçon
Mado — Huit notices, pas une leçon
On parle trop vite des plaisirs minuscules du figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le plaisir en consigne, une joie ordonnée comme un score n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que écrire le plaisir peut le rendre partageable, pour autant que l'on n'en fasse pas une leçon de bien manger.
Ce que l'on nomme plaisir, ici, n'est pas un slogan : expérience minuscule, non une consigne.
Mado : on dirait que l'ombre du figuier aurait un goût de thé trop infusé, et ce serait assez.
Rose coud un signet trop simple, exprès.
Sami veut une notice drôle ; Yvette en veut une lente.
Oscar glisse une terre sous l'ongle : cela aussi est un plaisir, dit-il, sans le vendre.
La proposition qui reste debout est celle-ci : huit notices de plaisir, au conditionnel parfois, sans injonction
Lila lira sans musique : le minuscule n'a pas besoin d'orchestre.
Nous clôturons sans fusionner les voix : le recueil de Mado d'un côté, les notes de Félicie au bas des pages de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on écrive, une joie ordonnée comme un score n'est pas un détail.
Mado concède que écrire le plaisir peut le rendre partageable, pour autant que l'on n'en fasse pas une leçon de bien manger.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
le minuscule ici, c'est ce qui n'a pas besoin d'affiche : l'ombre, le bol, la feuille
Mado, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Huit notices sous le figuier'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Mado sur « Huit notices sous le figuier » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Mado sur « Huit notices sous le figuier » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Faims du figuier'
  AND s.title = 'Huit notices sous le figuier'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;

-- C1 — Soigner autrement
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Reformuler les difficultés d'un parcours à l'Infirmerie des Herbes sans jargon abandonnant. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Dons et parcours
Lila Sow : Radio Figuier. On parle trop vite du parcours à l'Infirmerie des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on réduise l'attente à une vertu, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Hawa Diallo concède qu'un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Aline Uwase : Ce que l'on nomme parcours, ici, n'est pas un slogan : suite de portes et de mots, plus qu'une attente.
Hawa : on m'a dit d'attendre comme on dit merci.
Hawa Diallo : Inès refuse le jargon qui abandonne : elle traduit, elle n'humilie pas.
Joël Mugisha : Dieudonné répare la porte d'attente pour qu'elle grince moins.
Aline : le passif a été reçue trop tard n'est pas une excuse, c'est une phrase à relire.
Solange Mukamana : Patrick demande ce dont on a besoin : une explication, pas un mot savant.
Karim Bamba : Solange apporte une infusion et sort : elle n'est pas le protocole.
Félicie Ndayishimiye : Un chiffre, une trace : Hawa a compté onze passages de porte, trois jargon incompréhensibles, une main de Dieudonné sur le banc.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le consentement soit clair, pas seulement signé trop vite
Yvette : Lila enregistrera le podcast si Hawa le veut, pas pour le spectacle.
Mado : Inès Mukama entend, dans « il suffit d'attendre », ceci qui n'est pas dit : il suffit d'attendre veut souvent dire votre douleur n'a pas de place dans l'emploi du temps
Sami : Autrement dit, le parcours n'est pas une ligne : c'est une série de portes, de mots, de peurs nommées
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un podcast qui reformule le parcours d'Hawa sans voler sa voix
Marc : reformuler un parcours, c'est rendre les portes visibles.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les notes d'Hawa au Cahier des dons d'un côté, la fiche trop technique d'un passage inventé de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Dons et parcours'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une porte trop longue à s'ouvrir pour Hawa est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une porte trop longue à s'ouvrir pour Hawa n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Dons et parcours'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Reformuler les difficultés d'un parcours à l'Infirmerie des Herbes sans jargon abandonnant. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « La porte trop longue », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La porte trop longue
On parle trop vite du parcours à l'Infirmerie des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise l'attente à une vertu, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède qu'un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Ce que l'on nomme parcours, ici, n'est pas un slogan : suite de portes et de mots, plus qu'une attente.
Hawa : on m'a dit d'attendre comme on dit merci.
Inès refuse le jargon qui abandonne : elle traduit, elle n'humilie pas.
Dieudonné répare la porte d'attente pour qu'elle grince moins.
Aline : le passif a été reçue trop tard n'est pas une excuse, c'est une phrase à relire.
Patrick demande ce dont on a besoin : une explication, pas un mot savant.
Solange apporte une infusion et sort : elle n'est pas le protocole.
Un chiffre, une trace : Hawa a compté onze passages de porte, trois jargon incompréhensibles, une main de Dieudonné sur le banc.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le consentement soit clair, pas seulement signé trop vite
Lila enregistrera le podcast si Hawa le veut, pas pour le spectacle.
Inès Mukama entend, dans « il suffit d'attendre », ceci qui n'est pas dit : il suffit d'attendre veut souvent dire votre douleur n'a pas de place dans l'emploi du temps
Autrement dit, le parcours n'est pas une ligne : c'est une série de portes, de mots, de peurs nommées
La proposition qui reste debout est celle-ci : un podcast qui reformule le parcours d'Hawa sans voler sa voix
Marc : reformuler un parcours, c'est rendre les portes visibles.
Nous clôturons sans fusionner les voix : les notes d'Hawa au Cahier des dons d'un côté, la fiche trop technique d'un passage inventé de l'autre, et le point où elles refusent de se ressembler.
Signé : Hawa Diallo, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Dons et parcours'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : passif ; reformulation d'un parcours ; vocabulaire du soin (inventé).

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on réduise l'attente à une vertu, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède qu'un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Ce que l'on nomme parcours, ici, n'est pas un slogan : suite de portes et de mots, plus qu'une attente.
Encore que l'on reformule, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail.
Hawa Diallo concède qu'un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Autrement dit, le parcours n'est pas une ligne : c'est une série de portes, de mots, de peurs nommées
Il ressort qu'un podcast qui reformule le parcours d'Hawa sans voler sa voix
Inès refuse le jargon qui abandonne : elle traduit, elle n'humilie pas.
Patrick demande ce dont on a besoin : une explication, pas un mot savant.
La proposition qui reste debout est celle-ci : un podcast qui reformule le parcours d'Hawa sans voler sa voix
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les notes d'Hawa au Cahier des dons d'un côté, la fiche trop technique d'un passage inventé de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Dons et parcours'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Hawa Diallo transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Hawa Diallo concède qu'un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Dons et parcours'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Reformuler les difficultés d'un parcours à l'Infirmerie des Herbes sans jargon abandonnant. Point : passif ; reformulation d'un parcours ; vocabulaire du soin (inventé).

Consigne
Imitez le texte de Hawa Diallo.

Support — Hawa Diallo — La porte trop longue
Hawa Diallo — La porte trop longue
On parle trop vite du parcours à l'Infirmerie des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise l'attente à une vertu, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède qu'un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Ce que l'on nomme parcours, ici, n'est pas un slogan : suite de portes et de mots, plus qu'une attente.
Hawa : on m'a dit d'attendre comme on dit merci.
Patrick demande ce dont on a besoin : une explication, pas un mot savant.
Solange apporte une infusion et sort : elle n'est pas le protocole.
Lila enregistrera le podcast si Hawa le veut, pas pour le spectacle.
La proposition qui reste debout est celle-ci : un podcast qui reformule le parcours d'Hawa sans voler sa voix
Marc : reformuler un parcours, c'est rendre les portes visibles.
Nous clôturons sans fusionner les voix : les notes d'Hawa au Cahier des dons d'un côté, la fiche trop technique d'un passage inventé de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on reformule, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail.
Hawa Diallo concède qu'un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
le parcours n'est pas une ligne : c'est une série de portes, de mots, de peurs nommées
Hawa Diallo, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Dons et parcours'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Hawa Diallo sur « Dons et parcours » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Hawa Diallo sur « Dons et parcours » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Dons et parcours'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser passif ; reformulation d'un parcours ; vocabulaire du soin (inventé) au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — passif ; reformulation d'un parcours ; vocabulaire du soin (inventé)
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on reformule, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail.
Hawa Diallo concède qu'un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Autrement dit, le parcours n'est pas une ligne : c'est une série de portes, de mots, de peurs nommées
Il ressort qu'un podcast qui reformule le parcours d'Hawa sans voler sa voix
Piège : ce que + besoin au lieu de ce dont
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme parcours, ici, n'est pas un slogan : suite de portes et de mots, plus qu'une attente.
Inès refuse le jargon qui abandonne : elle traduit, elle n'humilie pas.
Patrick demande ce dont on a besoin : une explication, pas un mot savant.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au jargon pour de vrai genre, et Inès Mukama demande un registre plus net.
Correction : On va au jargon vraiment, et Inès Mukama demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Dons et parcours'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Rapporter une enquête du Filtre et expliciter une découverte sans triomphalisme. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le graphique n'efface pas la peur
Lila Sow : Radio Figuier. On parle trop vite d'une découverte du Filtre des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on close la peur par un graphique, une crainte qui n'est pas une ignorance n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Inès Mukama concède qu'un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Aline Uwase : Ce que l'on nomme enquête, ici, n'est pas un slogan : recherche datée, avec limites.
Inès : il apparaîtrait que le risque baisse, et j'entends déjà ceux qui veulent que je cesse le conditionnel.
Hawa : ma crainte n'est pas une erreur de calcul.
Joël Mugisha : Karim exige la taille de l'échantillon, pas le mot miracle.
Aline : modaliser, c'est rester honnête.
Solange Mukamana : Patrick veut une mini-conférence, pas une messe.
Karim Bamba : Solange demande ce que l'on fera des deux craintes hors graphique.
Félicie Ndayishimiye : Un chiffre, une trace : Le Filtre avance : risque moindre dans un échantillon inventé de quarante bols ; deux craintes non mesurées restent sur le banc.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de nommer le progrès sans chasser la crainte comme une honte
Yvette : Lila notera le conditionnel à l'antenne, exprès.
Mado : Hawa Diallo entend, dans « la science a parlé », ceci qui n'est pas dit : la science a parlé sert parfois à ne plus écouter ceux qui ont peur pour de vraies raisons
Sami : Autrement dit, il apparaîtrait que le filtre réduit un risque : ce conditionnel de prudence n'est pas une faiblesse
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une mini-conférence — résultat, limite, crainte légitime, geste de cour
Marc : expliciter une découverte, c'est aussi dire où elle s'arrête.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le rapport du Filtre d'un côté, la conférence d'Inès sous le figuier de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Le graphique n''efface pas la peur'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une crainte qui n'est pas une ignorance est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une crainte qui n'est pas une ignorance n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Le graphique n''efface pas la peur'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Reformulez l'implicite de « la science a parlé » et la concession d'Inès Mukama."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Le graphique n''efface pas la peur'
  AND l.competency = 'CO'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rapporter une enquête du Filtre et expliciter une découverte sans triomphalisme. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le graphique n'efface pas la peur », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le graphique n'efface pas la peur
On parle trop vite d'une découverte du Filtre des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on close la peur par un graphique, une crainte qui n'est pas une ignorance n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède qu'un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Ce que l'on nomme enquête, ici, n'est pas un slogan : recherche datée, avec limites.
Inès : il apparaîtrait que le risque baisse, et j'entends déjà ceux qui veulent que je cesse le conditionnel.
Hawa : ma crainte n'est pas une erreur de calcul.
Karim exige la taille de l'échantillon, pas le mot miracle.
Aline : modaliser, c'est rester honnête.
Patrick veut une mini-conférence, pas une messe.
Solange demande ce que l'on fera des deux craintes hors graphique.
Un chiffre, une trace : Le Filtre avance : risque moindre dans un échantillon inventé de quarante bols ; deux craintes non mesurées restent sur le banc.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de nommer le progrès sans chasser la crainte comme une honte
Lila notera le conditionnel à l'antenne, exprès.
Hawa Diallo entend, dans « la science a parlé », ceci qui n'est pas dit : la science a parlé sert parfois à ne plus écouter ceux qui ont peur pour de vraies raisons
Autrement dit, il apparaîtrait que le filtre réduit un risque : ce conditionnel de prudence n'est pas une faiblesse
La proposition qui reste debout est celle-ci : une mini-conférence — résultat, limite, crainte légitime, geste de cour
Marc : expliciter une découverte, c'est aussi dire où elle s'arrête.
Nous clôturons sans fusionner les voix : le rapport du Filtre d'un côté, la conférence d'Inès sous le figuier de l'autre, et le point où elles refusent de se ressembler.
Signé : Inès Mukama, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Le graphique n''efface pas la peur'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : rapporter une enquête ; il apparaîtrait que ; modalisation.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on close la peur par un graphique, une crainte qui n'est pas une ignorance n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède qu'un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Ce que l'on nomme enquête, ici, n'est pas un slogan : recherche datée, avec limites.
Encore que l'on rapporte, une crainte qui n'est pas une ignorance n'est pas un détail.
Inès Mukama concède qu'un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Autrement dit, il apparaîtrait que le filtre réduit un risque : ce conditionnel de prudence n'est pas une faiblesse
Il ressort qu'une mini-conférence : résultat, limite, crainte légitime, geste de cour
Hawa : ma crainte n'est pas une erreur de calcul.
Patrick veut une mini-conférence, pas une messe.
La proposition qui reste debout est celle-ci : une mini-conférence — résultat, limite, crainte légitime, geste de cour
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le rapport du Filtre d'un côté, la conférence d'Inès sous le figuier de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Le graphique n''efface pas la peur'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Inès Mukama transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Inès Mukama concède qu'un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Le graphique n''efface pas la peur'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Rapporter une enquête du Filtre et expliciter une découverte sans triomphalisme. Point : rapporter une enquête ; il apparaîtrait que ; modalisation.

Consigne
Imitez le texte d'Inès Mukama.

Support — Inès Mukama — Le graphique n'efface pas la peur
Inès Mukama — Le graphique n'efface pas la peur
On parle trop vite d'une découverte du Filtre des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on close la peur par un graphique, une crainte qui n'est pas une ignorance n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède qu'un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Ce que l'on nomme enquête, ici, n'est pas un slogan : recherche datée, avec limites.
Inès : il apparaîtrait que le risque baisse, et j'entends déjà ceux qui veulent que je cesse le conditionnel.
Patrick veut une mini-conférence, pas une messe.
Solange demande ce que l'on fera des deux craintes hors graphique.
Lila notera le conditionnel à l'antenne, exprès.
La proposition qui reste debout est celle-ci : une mini-conférence — résultat, limite, crainte légitime, geste de cour
Marc : expliciter une découverte, c'est aussi dire où elle s'arrête.
Nous clôturons sans fusionner les voix : le rapport du Filtre d'un côté, la conférence d'Inès sous le figuier de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on rapporte, une crainte qui n'est pas une ignorance n'est pas un détail.
Inès Mukama concède qu'un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il apparaîtrait que le filtre réduit un risque : ce conditionnel de prudence n'est pas une faiblesse
Inès Mukama, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Le graphique n''efface pas la peur'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos d'Inès Mukama sur « Le graphique n’efface pas la peur » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos d'Inès Mukama sur « Le graphique n’efface pas la peur » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Le graphique n''efface pas la peur'
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
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Le graphique n''efface pas la peur'
  AND l.competency = 'PE'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser rapporter une enquête ; il apparaîtrait que ; modalisation au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — rapporter une enquête ; il apparaîtrait que ; modalisation
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on rapporte, une crainte qui n'est pas une ignorance n'est pas un détail.
Inès Mukama concède qu'un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Autrement dit, il apparaîtrait que le filtre réduit un risque : ce conditionnel de prudence n'est pas une faiblesse
Il ressort qu'une mini-conférence : résultat, limite, crainte légitime, geste de cour
Piège : prendre un pourcentage pour une preuve morale
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme enquête, ici, n'est pas un slogan : recherche datée, avec limites.
Hawa : ma crainte n'est pas une erreur de calcul.
Patrick veut une mini-conférence, pas une messe.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au crainte pour de vrai genre, et Hawa Diallo demande un registre plus net.
Correction : On va au crainte vraiment, et Hawa Diallo demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Le graphique n''efface pas la peur'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Raconter les difficultés d'une formation trop longue sans pathos de sacrifice. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Une vie de formation
Lila Sow : Radio Figuier. On parle trop vite d'une formation trop longue au Seuil, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme l'épuisement en vertu, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Aline Uwase : Ce que l'on nomme formation, ici, n'est pas un slogan : temps d'apprendre, pas une épreuve sacrée.
Aline : j'avais cru que former, c'était parler ; j'ai appris que c'était d'abord ne pas disparaître.
Hawa Diallo : Patrick lit le journal sans corriger l'émotion, seulement la syntaxe.
Joël Mugisha : Inès reconnaît les gardes : elle les a faites, elle refuse d'en faire une légende.
Rose Iradukunda : Hawa dit qu'une élève n'a pas à payer le sommeil de la formatrice.
Solange Mukamana : Lila n'enregistrera le journal que si Aline le veut.
Karim Bamba : Dieudonné apporte du thé à l'aube, sans discours.
Félicie Ndayishimiye : Un chiffre, une trace : Aline a noté vingt gardes, quatre cours manqués, une élève qui attend encore la fiche.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la transmission ne meure pas sous le mot sacrifice
Yvette : un métier difficile n'est pas une religion.
Mado : Patrick Habimana entend, dans « c'est le prix à payer », ceci qui n'est pas dit : c'est le prix à payer interdit souvent de demander qui encaisse
Sami : Autrement dit, le journal n'est pas une plainte : c'est une archive de ce que la blouse cache
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : trois pages de journal — faits, doute, ce qui reste transmissible
Marc : selon le journal, il ressort que la transmission exige des heures, pas un martyre.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le journal d'Aline d'un côté, l'émission où l'on parle trop vite de vocation de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Une vie de formation'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Reformulez l'implicite de « c'est le prix à payer » et la concession d'Aline Uwase."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Une vie de formation'
  AND l.competency = 'CO'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Raconter les difficultés d'une formation trop longue sans pathos de sacrifice. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Ce que la blouse cache », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Ce que la blouse cache
On parle trop vite d'une formation trop longue au Seuil, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme l'épuisement en vertu, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Ce que l'on nomme formation, ici, n'est pas un slogan : temps d'apprendre, pas une épreuve sacrée.
Aline : j'avais cru que former, c'était parler ; j'ai appris que c'était d'abord ne pas disparaître.
Patrick lit le journal sans corriger l'émotion, seulement la syntaxe.
Inès reconnaît les gardes : elle les a faites, elle refuse d'en faire une légende.
Hawa dit qu'une élève n'a pas à payer le sommeil de la formatrice.
Lila n'enregistrera le journal que si Aline le veut.
Dieudonné apporte du thé à l'aube, sans discours.
Un chiffre, une trace : Aline a noté vingt gardes, quatre cours manqués, une élève qui attend encore la fiche.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la transmission ne meure pas sous le mot sacrifice
Yvette : un métier difficile n'est pas une religion.
Patrick Habimana entend, dans « c'est le prix à payer », ceci qui n'est pas dit : c'est le prix à payer interdit souvent de demander qui encaisse
Autrement dit, le journal n'est pas une plainte : c'est une archive de ce que la blouse cache
La proposition qui reste debout est celle-ci : trois pages de journal — faits, doute, ce qui reste transmissible
Marc : selon le journal, il ressort que la transmission exige des heures, pas un martyre.
Nous clôturons sans fusionner les voix : le journal d'Aline d'un côté, l'émission où l'on parle trop vite de vocation de l'autre, et le point où elles refusent de se ressembler.
Signé : Aline Uwase, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Une vie de formation'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : journal intime ; imparfait / plus-que-parfait ; modalisation du doute.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme l'épuisement en vertu, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Ce que l'on nomme formation, ici, n'est pas un slogan : temps d'apprendre, pas une épreuve sacrée.
Encore que l'on écrive, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail.
Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Autrement dit, le journal n'est pas une plainte : c'est une archive de ce que la blouse cache
Il ressort que trois pages de journal : faits, doute, ce qui reste transmissible
Patrick lit le journal sans corriger l'émotion, seulement la syntaxe.
Lila n'enregistrera le journal que si Aline le veut.
La proposition qui reste debout est celle-ci : trois pages de journal — faits, doute, ce qui reste transmissible
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le journal d'Aline d'un côté, l'émission où l'on parle trop vite de vocation de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Une vie de formation'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Raconter les difficultés d'une formation trop longue sans pathos de sacrifice. Point : journal intime ; imparfait / plus-que-parfait ; modalisation du doute.

Consigne
Imitez le texte d'Aline Uwase.

Support — Aline Uwase — Ce que la blouse cache
Aline Uwase — Ce que la blouse cache
On parle trop vite d'une formation trop longue au Seuil, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme l'épuisement en vertu, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Ce que l'on nomme formation, ici, n'est pas un slogan : temps d'apprendre, pas une épreuve sacrée.
Aline : j'avais cru que former, c'était parler ; j'ai appris que c'était d'abord ne pas disparaître.
Lila n'enregistrera le journal que si Aline le veut.
Dieudonné apporte du thé à l'aube, sans discours.
Yvette : un métier difficile n'est pas une religion.
La proposition qui reste debout est celle-ci : trois pages de journal — faits, doute, ce qui reste transmissible
Marc : selon le journal, il ressort que la transmission exige des heures, pas un martyre.
Nous clôturons sans fusionner les voix : le journal d'Aline d'un côté, l'émission où l'on parle trop vite de vocation de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on écrive, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail.
Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
le journal n'est pas une plainte : c'est une archive de ce que la blouse cache
Aline Uwase, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Une vie de formation'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos d'Aline Uwase sur « Une vie de formation » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos d'Aline Uwase sur « Une vie de formation » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Une vie de formation'
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
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Une vie de formation'
  AND l.competency = 'PE'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser journal intime ; imparfait / plus-que-parfait ; modalisation du doute au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — journal intime ; imparfait / plus-que-parfait ; modalisation du doute
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on écrive, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail.
Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Autrement dit, le journal n'est pas une plainte : c'est une archive de ce que la blouse cache
Il ressort que trois pages de journal : faits, doute, ce qui reste transmissible
Piège : fusionner les sources au lieu des attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme formation, ici, n'est pas un slogan : temps d'apprendre, pas une épreuve sacrée.
Patrick lit le journal sans corriger l'émotion, seulement la syntaxe.
Lila n'enregistrera le journal que si Aline le veut.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au garde pour de vrai genre, et Patrick Habimana demande un registre plus net.
Correction : On va au garde vraiment, et Patrick Habimana demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Une vie de formation'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Présenter une polémique sur les infusions de Solange sans caricature. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — L'herbe et la porte
Lila Sow : Radio Figuier. On parle trop vite des infusions de Solange Mukamana, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace l'infirmerie par une casserole, une confiance trop simple dans l'herbe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Solange Mukamana concède qu'une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Aline Uwase : Ce que l'on nomme polémique, ici, n'est pas un slogan : désaccord public à présenter, non à envenimer.
Solange : certains affirment que l'herbe suffit ; je n'ai jamais dit cela, j'ai dit qu'elle console.
Inès : d'autres objectent que console veut dire guérir, et c'est là que les portes s'ouvrent trop tard.
Joël Mugisha : Aline exige les deux voix dans le même exposé.
Rose Iradukunda : Hawa a goûté l'infusion et gardé son rendez-vous.
Solange Mukamana : Karim refuse le donc trop rapide : naturel donc sûr.
Karim Bamba : Lila présentera la polémique sans chercher une gagnante.
Félicie Ndayishimiye : Un chiffre, une trace : Solange a servi douze infusions ; Inès a reçu trois personnes trop tard, persuadées que l'herbe suffisait.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de soigner sans magie, ni mépris de l'herbe, ni abandon du suivi
Dieudonné : une casserole n'est pas une infamie, c'est un outil.
Mado : Inès Mukama entend, dans « c'est naturel donc c'est sûr », ceci qui n'est pas dit : naturel donc sûr permet de vendre une calme ignorance
Sami : Autrement dit, la polémique n'est pas Solange contre Inès : c'est le mot sûr collé trop vite à l'herbe
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : présenter deux positions, une limite, un geste — l'herbe n'efface pas la porte d'Inès
Marc : expliquer le fonctionnement d'une thérapie, c'est aussi dire où elle s'arrête.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : la chronique de Solange d'un côté, la mise au point d'Inès de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'L''herbe et la porte'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une confiance trop simple dans l'herbe est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une confiance trop simple dans l'herbe n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'L''herbe et la porte'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Présenter une polémique sur les infusions de Solange sans caricature. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « L'herbe n'est pas un sort », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — L'herbe n'est pas un sort
On parle trop vite des infusions de Solange Mukamana, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'infirmerie par une casserole, une confiance trop simple dans l'herbe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède qu'une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Ce que l'on nomme polémique, ici, n'est pas un slogan : désaccord public à présenter, non à envenimer.
Solange : certains affirment que l'herbe suffit ; je n'ai jamais dit cela, j'ai dit qu'elle console.
Inès : d'autres objectent que console veut dire guérir, et c'est là que les portes s'ouvrent trop tard.
Aline exige les deux voix dans le même exposé.
Hawa a goûté l'infusion et gardé son rendez-vous.
Karim refuse le donc trop rapide : naturel donc sûr.
Lila présentera la polémique sans chercher une gagnante.
Un chiffre, une trace : Solange a servi douze infusions ; Inès a reçu trois personnes trop tard, persuadées que l'herbe suffisait.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de soigner sans magie, ni mépris de l'herbe, ni abandon du suivi
Dieudonné : une casserole n'est pas une infamie, c'est un outil.
Inès Mukama entend, dans « c'est naturel donc c'est sûr », ceci qui n'est pas dit : naturel donc sûr permet de vendre une calme ignorance
Autrement dit, la polémique n'est pas Solange contre Inès : c'est le mot sûr collé trop vite à l'herbe
La proposition qui reste debout est celle-ci : présenter deux positions, une limite, un geste — l'herbe n'efface pas la porte d'Inès
Marc : expliquer le fonctionnement d'une thérapie, c'est aussi dire où elle s'arrête.
Nous clôturons sans fusionner les voix : la chronique de Solange d'un côté, la mise au point d'Inès de l'autre, et le point où elles refusent de se ressembler.
Signé : Solange Mukamana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'L''herbe et la porte'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : présenter une polémique ; certains affirment / d'autres objectent.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace l'infirmerie par une casserole, une confiance trop simple dans l'herbe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède qu'une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Ce que l'on nomme polémique, ici, n'est pas un slogan : désaccord public à présenter, non à envenimer.
Encore que l'on présente, une confiance trop simple dans l'herbe n'est pas un détail.
Solange Mukamana concède qu'une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Autrement dit, la polémique n'est pas Solange contre Inès : c'est le mot sûr collé trop vite à l'herbe
Il ressort que présenter deux positions, une limite, un geste : l'herbe n'efface pas la porte d'Inès
Inès : d'autres objectent que console veut dire guérir, et c'est là que les portes s'ouvrent trop tard.
Karim refuse le donc trop rapide : naturel donc sûr.
La proposition qui reste debout est celle-ci : présenter deux positions, une limite, un geste — l'herbe n'efface pas la porte d'Inès
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : la chronique de Solange d'un côté, la mise au point d'Inès de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'L''herbe et la porte'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Solange Mukamana transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Solange Mukamana concède qu'une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'L''herbe et la porte'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Présenter une polémique sur les infusions de Solange sans caricature. Point : présenter une polémique ; certains affirment / d'autres objectent.

Consigne
Imitez le texte de Solange Mukamana.

Support — Solange Mukamana — L'herbe n'est pas un sort
Solange Mukamana — L'herbe n'est pas un sort
On parle trop vite des infusions de Solange Mukamana, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'infirmerie par une casserole, une confiance trop simple dans l'herbe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède qu'une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Ce que l'on nomme polémique, ici, n'est pas un slogan : désaccord public à présenter, non à envenimer.
Solange : certains affirment que l'herbe suffit ; je n'ai jamais dit cela, j'ai dit qu'elle console.
Karim refuse le donc trop rapide : naturel donc sûr.
Lila présentera la polémique sans chercher une gagnante.
Dieudonné : une casserole n'est pas une infamie, c'est un outil.
La proposition qui reste debout est celle-ci : présenter deux positions, une limite, un geste — l'herbe n'efface pas la porte d'Inès
Marc : expliquer le fonctionnement d'une thérapie, c'est aussi dire où elle s'arrête.
Nous clôturons sans fusionner les voix : la chronique de Solange d'un côté, la mise au point d'Inès de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on présente, une confiance trop simple dans l'herbe n'est pas un détail.
Solange Mukamana concède qu'une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
la polémique n'est pas Solange contre Inès : c'est le mot sûr collé trop vite à l'herbe
Solange Mukamana, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'L''herbe et la porte'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Solange Mukamana sur « L’herbe et la porte » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Solange Mukamana sur « L’herbe et la porte » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'L''herbe et la porte'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser présenter une polémique ; certains affirment / d'autres objectent au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — présenter une polémique ; certains affirment / d'autres objectent
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on présente, une confiance trop simple dans l'herbe n'est pas un détail.
Solange Mukamana concède qu'une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Autrement dit, la polémique n'est pas Solange contre Inès : c'est le mot sûr collé trop vite à l'herbe
Il ressort que présenter deux positions, une limite, un geste : l'herbe n'efface pas la porte d'Inès
Piège : confusion cause / concession
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme polémique, ici, n'est pas un slogan : désaccord public à présenter, non à envenimer.
Inès : d'autres objectent que console veut dire guérir, et c'est là que les portes s'ouvrent trop tard.
Karim refuse le donc trop rapide : naturel donc sûr.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au suivi pour de vrai genre, et Inès Mukama demande un registre plus net.
Correction : On va au suivi vraiment, et Inès Mukama demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'L''herbe et la porte'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Tenir une mini-conférence claire : résultat, limite, geste. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Mini-conférence du Filtre
Lila Sow : Radio Figuier. On parle trop vite de la mini-conférence sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace le plan par le charisme, une salle qui applaudit trop tôt n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Inès Mukama concède qu'un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Aline Uwase : Ce que l'on nomme conférence, ici, n'est pas un slogan : oral structuré, distinct d'un spectacle.
Patrick Habimana : Inès pose le fait, puis la limite, puis le geste : la salle voudrait inverser.
Aline : il convient que l'on entende le donc avant l'applaudissement.
Joël Mugisha : Karim demande ce qui ne s'ensuit pas.
Rose Iradukunda : Hawa pose la question que le graphique évite.
Solange Mukamana : Patrick chronomètre sans brutalité.
Karim Bamba : Lila gardera les trois questions, pas seulement la formule claire.
Félicie Ndayishimiye : Un chiffre, une trace : Inès a parlé onze minutes ; trois questions ; zéro mot miracle.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la cour puisse relire la conférence demain sans se sentir trompée
Yvette : Solange apporte de l'eau, pas une conclusion.
Mado : Aline Uwase entend, dans « faites confiance », ceci qui n'est pas dit : faites confiance veut souvent dire ne demandez pas le plan
Sami : Autrement dit, déduire, ce n'est pas enchaîner des mots savants : c'est montrer ce qui s'ensuit, et ce qui ne s'ensuit pas
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un plan en trois temps — fait, limite, recommandation pour la cour
Marc : une mini-conférence est une hospitalité faite au doute.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le plan d'Inès d'un côté, les questions d'Hawa et de Karim de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Mini-conférence du Filtre'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une salle qui applaudit trop tôt est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une salle qui applaudit trop tôt n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Mini-conférence du Filtre'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Reformulez l'implicite de « faites confiance » et la concession d'Inès Mukama."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Mini-conférence du Filtre'
  AND l.competency = 'CO'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Tenir une mini-conférence claire : résultat, limite, geste. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Ce qui s'ensuit, ce qui ne s'ensuit pas », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Ce qui s'ensuit, ce qui ne s'ensuit pas
On parle trop vite de la mini-conférence sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le plan par le charisme, une salle qui applaudit trop tôt n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède qu'un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Ce que l'on nomme conférence, ici, n'est pas un slogan : oral structuré, distinct d'un spectacle.
Inès pose le fait, puis la limite, puis le geste : la salle voudrait inverser.
Aline : il convient que l'on entende le donc avant l'applaudissement.
Karim demande ce qui ne s'ensuit pas.
Hawa pose la question que le graphique évite.
Patrick chronomètre sans brutalité.
Lila gardera les trois questions, pas seulement la formule claire.
Un chiffre, une trace : Inès a parlé onze minutes ; trois questions ; zéro mot miracle.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la cour puisse relire la conférence demain sans se sentir trompée
Solange apporte de l'eau, pas une conclusion.
Aline Uwase entend, dans « faites confiance », ceci qui n'est pas dit : faites confiance veut souvent dire ne demandez pas le plan
Autrement dit, déduire, ce n'est pas enchaîner des mots savants : c'est montrer ce qui s'ensuit, et ce qui ne s'ensuit pas
La proposition qui reste debout est celle-ci : un plan en trois temps — fait, limite, recommandation pour la cour
Marc : une mini-conférence est une hospitalité faite au doute.
Nous clôturons sans fusionner les voix : le plan d'Inès d'un côté, les questions d'Hawa et de Karim de l'autre, et le point où elles refusent de se ressembler.
Signé : Inès Mukama, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Mini-conférence du Filtre'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : plan déductif ; il s'ensuit que ; en conséquence.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace le plan par le charisme, une salle qui applaudit trop tôt n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède qu'un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Ce que l'on nomme conférence, ici, n'est pas un slogan : oral structuré, distinct d'un spectacle.
Encore que l'on conclue, une salle qui applaudit trop tôt n'est pas un détail.
Inès Mukama concède qu'un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Autrement dit, déduire, ce n'est pas enchaîner des mots savants : c'est montrer ce qui s'ensuit, et ce qui ne s'ensuit pas
Il ressort qu'un plan en trois temps : fait, limite, recommandation pour la cour
Aline : il convient que l'on entende le donc avant l'applaudissement.
Patrick chronomètre sans brutalité.
La proposition qui reste debout est celle-ci : un plan en trois temps — fait, limite, recommandation pour la cour
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le plan d'Inès d'un côté, les questions d'Hawa et de Karim de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Mini-conférence du Filtre'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Inès Mukama transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Inès Mukama concède qu'un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Mini-conférence du Filtre'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Tenir une mini-conférence claire : résultat, limite, geste. Point : plan déductif ; il s'ensuit que ; en conséquence.

Consigne
Imitez le texte d'Inès Mukama.

Support — Inès Mukama — Ce qui s'ensuit, ce qui ne s'ensuit pas
Inès Mukama — Ce qui s'ensuit, ce qui ne s'ensuit pas
On parle trop vite de la mini-conférence sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le plan par le charisme, une salle qui applaudit trop tôt n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède qu'un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Ce que l'on nomme conférence, ici, n'est pas un slogan : oral structuré, distinct d'un spectacle.
Inès pose le fait, puis la limite, puis le geste : la salle voudrait inverser.
Patrick chronomètre sans brutalité.
Lila gardera les trois questions, pas seulement la formule claire.
Solange apporte de l'eau, pas une conclusion.
La proposition qui reste debout est celle-ci : un plan en trois temps — fait, limite, recommandation pour la cour
Marc : une mini-conférence est une hospitalité faite au doute.
Nous clôturons sans fusionner les voix : le plan d'Inès d'un côté, les questions d'Hawa et de Karim de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on conclue, une salle qui applaudit trop tôt n'est pas un détail.
Inès Mukama concède qu'un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
déduire, ce n'est pas enchaîner des mots savants : c'est montrer ce qui s'ensuit, et ce qui ne s'ensuit pas
Inès Mukama, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Mini-conférence du Filtre'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos d'Inès Mukama sur « Mini-conférence du Filtre » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos d'Inès Mukama sur « Mini-conférence du Filtre » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Mini-conférence du Filtre'
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
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Mini-conférence du Filtre'
  AND l.competency = 'PE'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser plan déductif ; il s'ensuit que ; en conséquence au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — plan déductif ; il s'ensuit que ; en conséquence
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on conclue, une salle qui applaudit trop tôt n'est pas un détail.
Inès Mukama concède qu'un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Autrement dit, déduire, ce n'est pas enchaîner des mots savants : c'est montrer ce qui s'ensuit, et ce qui ne s'ensuit pas
Il ressort qu'un plan en trois temps : fait, limite, recommandation pour la cour
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme conférence, ici, n'est pas un slogan : oral structuré, distinct d'un spectacle.
Aline : il convient que l'on entende le donc avant l'applaudissement.
Patrick chronomètre sans brutalité.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au limite pour de vrai genre, et Aline Uwase demande un registre plus net.
Correction : On va au limite vraiment, et Aline Uwase demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Mini-conférence du Filtre'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Enregistrer un podcast qui rapporte un parcours médical inventé sans le voler. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Podcast du parcours
Lila Sow : Radio Figuier. On parle trop vite du podcast de Radio Figuier sur le parcours, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on coupe la parole d'Hawa pour faire plus vrai, un montage trop lisse n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Aline Uwase : Ce que l'on nomme podcast, ici, n'est pas un slogan : épisode parlé, monté avec éthique.
Patrick Habimana : Hawa a dit qu'elle voulait le silence après le mot porte.
Hawa Diallo : Lila a demandé si l'on pouvait reformuler jargon ; Hawa a dit que oui, à condition du signaler.
Joël Mugisha : Inès a prétendu que le protocole était clair ; Hawa a ri, puis s'est tue.
Aline : le discours indirect ici protège, il n'habille pas.
Solange Mukamana : Dieudonné n'apparaît que s'il accepte.
Karim Bamba : Patrick écoute le rush et refuse le fond musical.
Félicie Ndayishimiye : Un chiffre, une trace : Lila a gardé quatre silences ; coupé deux répétitions ; refusé un fond musical trop doux.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le podcast reste un soin de parole, pas un spectacle de douleur
Yvette : donner la voix n'est pas une décoration.
Mado : Hawa Diallo entend, dans « donner la voix aux patients », ceci qui n'est pas dit : donner la voix peut cacher le fait qu'on la prend
Sami : Autrement dit, rapporter, ce n'est pas sténographier, et ce n'est pas non plus embellir la peur
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un épisode — Hawa, Inès, un silence gardé, une reformulation signalée
Marc : Radio Figuier rapportera, elle n'éditera pas la peur.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le rush du podcast d'un côté, les consignes d'Hawa sur ce qui ne se dit pas de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Podcast du parcours'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un montage trop lisse est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un montage trop lisse n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Podcast du parcours'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Enregistrer un podcast qui rapporte un parcours médical inventé sans le voler. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Ce qui ne se monte pas », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Ce qui ne se monte pas
On parle trop vite du podcast de Radio Figuier sur le parcours, comme si le mot dispensait d'en examiner le prix.
Encore que l'on coupe la parole d'Hawa pour faire plus vrai, un montage trop lisse n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Ce que l'on nomme podcast, ici, n'est pas un slogan : épisode parlé, monté avec éthique.
Hawa a dit qu'elle voulait le silence après le mot porte.
Lila a demandé si l'on pouvait reformuler jargon ; Hawa a dit que oui, à condition du signaler.
Inès a prétendu que le protocole était clair ; Hawa a ri, puis s'est tue.
Aline : le discours indirect ici protège, il n'habille pas.
Dieudonné n'apparaît que s'il accepte.
Patrick écoute le rush et refuse le fond musical.
Un chiffre, une trace : Lila a gardé quatre silences ; coupé deux répétitions ; refusé un fond musical trop doux.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le podcast reste un soin de parole, pas un spectacle de douleur
Yvette : donner la voix n'est pas une décoration.
Hawa Diallo entend, dans « donner la voix aux patients », ceci qui n'est pas dit : donner la voix peut cacher le fait qu'on la prend
Autrement dit, rapporter, ce n'est pas sténographier, et ce n'est pas non plus embellir la peur
La proposition qui reste debout est celle-ci : un épisode — Hawa, Inès, un silence gardé, une reformulation signalée
Marc : Radio Figuier rapportera, elle n'éditera pas la peur.
Nous clôturons sans fusionner les voix : le rush du podcast d'un côté, les consignes d'Hawa sur ce qui ne se dit pas de l'autre, et le point où elles refusent de se ressembler.
Signé : Lila Sow, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Podcast du parcours'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : discours rapporté complexe ; elle a dit qu'elle / si.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on coupe la parole d'Hawa pour faire plus vrai, un montage trop lisse n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Ce que l'on nomme podcast, ici, n'est pas un slogan : épisode parlé, monté avec éthique.
Encore que l'on coupe, un montage trop lisse n'est pas un détail.
Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Autrement dit, rapporter, ce n'est pas sténographier, et ce n'est pas non plus embellir la peur
Il ressort qu'un épisode : Hawa, Inès, un silence gardé, une reformulation signalée
Lila a demandé si l'on pouvait reformuler jargon ; Hawa a dit que oui, à condition du signaler.
Dieudonné n'apparaît que s'il accepte.
La proposition qui reste debout est celle-ci : un épisode — Hawa, Inès, un silence gardé, une reformulation signalée
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le rush du podcast d'un côté, les consignes d'Hawa sur ce qui ne se dit pas de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Podcast du parcours'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Enregistrer un podcast qui rapporte un parcours médical inventé sans le voler. Point : discours rapporté complexe ; elle a dit qu'elle / si.

Consigne
Imitez le texte de Lila Sow.

Support — Lila Sow — Ce qui ne se monte pas
Lila Sow — Ce qui ne se monte pas
On parle trop vite du podcast de Radio Figuier sur le parcours, comme si le mot dispensait d'en examiner le prix.
Encore que l'on coupe la parole d'Hawa pour faire plus vrai, un montage trop lisse n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Ce que l'on nomme podcast, ici, n'est pas un slogan : épisode parlé, monté avec éthique.
Hawa a dit qu'elle voulait le silence après le mot porte.
Dieudonné n'apparaît que s'il accepte.
Patrick écoute le rush et refuse le fond musical.
Yvette : donner la voix n'est pas une décoration.
La proposition qui reste debout est celle-ci : un épisode — Hawa, Inès, un silence gardé, une reformulation signalée
Marc : Radio Figuier rapportera, elle n'éditera pas la peur.
Nous clôturons sans fusionner les voix : le rush du podcast d'un côté, les consignes d'Hawa sur ce qui ne se dit pas de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on coupe, un montage trop lisse n'est pas un détail.
Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
rapporter, ce n'est pas sténographier, et ce n'est pas non plus embellir la peur
Lila Sow, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Podcast du parcours'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Lila Sow sur « Podcast du parcours » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Lila Sow sur « Podcast du parcours » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Podcast du parcours'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser discours rapporté complexe ; elle a dit qu'elle / si au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — discours rapporté complexe ; elle a dit qu'elle / si
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on coupe, un montage trop lisse n'est pas un détail.
Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Autrement dit, rapporter, ce n'est pas sténographier, et ce n'est pas non plus embellir la peur
Il ressort qu'un épisode : Hawa, Inès, un silence gardé, une reformulation signalée
Piège : garder le présent du DD dans un DI au passé
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme podcast, ici, n'est pas un slogan : épisode parlé, monté avec éthique.
Lila a demandé si l'on pouvait reformuler jargon ; Hawa a dit que oui, à condition du signaler.
Dieudonné n'apparaît que s'il accepte.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au silence pour de vrai genre, et Hawa Diallo demande un registre plus net.
Correction : On va au silence vraiment, et Hawa Diallo demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Soigner autrement'
  AND s.title = 'Podcast du parcours'
  AND l.competency = 'EL';

-- C1 — Corps visibles
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Commenter une tendance du regard sans répéter les mots d'un fil. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Image de soi sous le figuier
Lila Sow : Radio Figuier. On parle trop vite du regard que la cour porte sur les corps, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme le corps en vitrine du fil, un compliment qui mesure trop n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Je concède qu'un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Aline Uwase : Ce que l'on nomme regard, ici, n'est pas un slogan : manière de voir, parfois une mesure.
Léa : on dirait que le fil n'aime que les midis sans ombre.
Hawa Diallo : Rose coud un col trop large, exprès, pour que le corps respire.
Joël Mugisha : Sami pose un portrait et le retire : trop de commentaires.
Rose Iradukunda : Aline distingue le registre du banc et celui du fil.
Solange Mukamana : Hawa refuse le compliment qui pèse.
Karim Bamba : Joël ne se photographie pas portant les lanternes : ce n'est pas un spectacle.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a vu six portraits trop semblables au fil inventé de la cour, un seul où l'ombre n'était pas gommée.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de se voir sans se mettre en vitrine
Yvette : Lila n'ouvrira pas une émission de notes.
Mado : Rose Iradukunda entend, dans « sois toi-même », ceci qui n'est pas dit : sois toi-même arrive souvent après une liste de ce que toi-même devrait être
Sami : Autrement dit, commenter une tendance, c'est nommer qui gagne à ce que l'on se compare
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un billet pour le Cahier du chemin — tendance, implicite, geste de ne pas mesurer
Marc : commenter, ce n'est pas noter.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les portraits trop nets du fil de la cour d'un côté, le billet de Léa de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Image de soi sous le figuier'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un compliment qui mesure trop est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un compliment qui mesure trop n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Image de soi sous le figuier'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Commenter une tendance du regard sans répéter les mots d'un fil. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Toi-même, après la liste », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Toi-même, après la liste
On parle trop vite du regard que la cour porte sur les corps, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le corps en vitrine du fil, un compliment qui mesure trop n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède qu'un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Ce que l'on nomme regard, ici, n'est pas un slogan : manière de voir, parfois une mesure.
Léa : on dirait que le fil n'aime que les midis sans ombre.
Rose coud un col trop large, exprès, pour que le corps respire.
Sami pose un portrait et le retire : trop de commentaires.
Aline distingue le registre du banc et celui du fil.
Hawa refuse le compliment qui pèse.
Joël ne se photographie pas portant les lanternes : ce n'est pas un spectacle.
Un chiffre, une trace : Léa a vu six portraits trop semblables au fil inventé de la cour, un seul où l'ombre n'était pas gommée.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de se voir sans se mettre en vitrine
Lila n'ouvrira pas une émission de notes.
Rose Iradukunda entend, dans « sois toi-même », ceci qui n'est pas dit : sois toi-même arrive souvent après une liste de ce que toi-même devrait être
Autrement dit, commenter une tendance, c'est nommer qui gagne à ce que l'on se compare
La proposition qui reste debout est celle-ci : un billet pour le Cahier du chemin — tendance, implicite, geste de ne pas mesurer
Marc : commenter, ce n'est pas noter.
Nous clôturons sans fusionner les voix : les portraits trop nets du fil de la cour d'un côté, le billet de Léa de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Image de soi sous le figuier'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : commenter une tendance ; on dirait que ; registre du regard.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme le corps en vitrine du fil, un compliment qui mesure trop n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède qu'un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Ce que l'on nomme regard, ici, n'est pas un slogan : manière de voir, parfois une mesure.
Encore que l'on commente, un compliment qui mesure trop n'est pas un détail.
Léa Niyonzima concède qu'un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Autrement dit, commenter une tendance, c'est nommer qui gagne à ce que l'on se compare
Il ressort qu'un billet pour le Cahier du chemin : tendance, implicite, geste de ne pas mesurer
Rose coud un col trop large, exprès, pour que le corps respire.
Hawa refuse le compliment qui pèse.
La proposition qui reste debout est celle-ci : un billet pour le Cahier du chemin — tendance, implicite, geste de ne pas mesurer
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les portraits trop nets du fil de la cour d'un côté, le billet de Léa de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Image de soi sous le figuier'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Léa Niyonzima transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Léa Niyonzima concède qu'un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Image de soi sous le figuier'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Commenter une tendance du regard sans répéter les mots d'un fil. Point : commenter une tendance ; on dirait que ; registre du regard.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Toi-même, après la liste
Léa Niyonzima — Toi-même, après la liste
On parle trop vite du regard que la cour porte sur les corps, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le corps en vitrine du fil, un compliment qui mesure trop n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède qu'un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Ce que l'on nomme regard, ici, n'est pas un slogan : manière de voir, parfois une mesure.
Léa : on dirait que le fil n'aime que les midis sans ombre.
Hawa refuse le compliment qui pèse.
Joël ne se photographie pas portant les lanternes : ce n'est pas un spectacle.
Lila n'ouvrira pas une émission de notes.
La proposition qui reste debout est celle-ci : un billet pour le Cahier du chemin — tendance, implicite, geste de ne pas mesurer
Marc : commenter, ce n'est pas noter.
Nous clôturons sans fusionner les voix : les portraits trop nets du fil de la cour d'un côté, le billet de Léa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on commente, un compliment qui mesure trop n'est pas un détail.
Léa Niyonzima concède qu'un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
commenter une tendance, c'est nommer qui gagne à ce que l'on se compare
Léa Niyonzima, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Image de soi sous le figuier'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Léa Niyonzima sur « Image de soi sous le figuier » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Léa Niyonzima sur « Image de soi sous le figuier » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Image de soi sous le figuier'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser commenter une tendance ; on dirait que ; registre du regard au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — commenter une tendance ; on dirait que ; registre du regard
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on commente, un compliment qui mesure trop n'est pas un détail.
Léa Niyonzima concède qu'un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Autrement dit, commenter une tendance, c'est nommer qui gagne à ce que l'on se compare
Il ressort qu'un billet pour le Cahier du chemin : tendance, implicite, geste de ne pas mesurer
Piège : familier non signalé dans un discours d'assemblée
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme regard, ici, n'est pas un slogan : manière de voir, parfois une mesure.
Rose coud un col trop large, exprès, pour que le corps respire.
Hawa refuse le compliment qui pèse.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au tendance pour de vrai genre, et Rose Iradukunda demande un registre plus net.
Correction : On va au tendance vraiment, et Rose Iradukunda demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Image de soi sous le figuier'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Dénoncer ce que la cour rend invisible, notamment l'accès. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — La planche n'est pas une rampe
Lila Sow : Radio Figuier. On parle trop vite de ce que la cour ne voit pas, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on mette la rampe à plus tard, une assemblée sans place pour Joël le jour de la pluie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice.
Aline Uwase : Ce que l'on nomme inégalité, ici, n'est pas un slogan : écart d'accès rendu normal par l'habitude.
Joël : il n'est que trop évident que la pluie choisit qui parle.
Hawa Diallo : Solange a honte de la planche, et la honte n'est pas une rampe.
Joël Mugisha : Léa écrit le manifeste au nom de ceux qui n'ont pas pu monter.
Rose Iradukunda : Dieudonné peut souder, il demande une date.
Solange Mukamana : Karim chiffre le fer, refuse le mot bientôt.
Aline : la relative dont on se passe trop souvent, c'est ceux pour qui la cour se ferme.
Félicie Ndayishimiye : Un chiffre, une trace : Joël a manqué trois assemblées de pluie ; la planche a glissé huit fois ; zéro date de rampe.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la cour soit une cour, pas un club de ceux qui montent vite
Yvette : Lila lira le manifeste sans musique héroïque.
Mado : Solange Mukamana entend, dans « on s'adapte », ceci qui n'est pas dit : on s'adapte veut dire c'est à toi de disparaître quand il pleut
Sami : Autrement dit, dénoncer, ce n'est pas insulter : c'est rendre visible une inégalité que l'habitude a rendue normale
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un manifeste — rampe, heures, bancs, signatures du Bureau des Escales
Marc : dénoncer une inégalité, c'est rendre le banc habitable.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le manifeste de Joël et de Léa d'un côté, les minutes trop vagues de l'assemblée de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'La planche n''est pas une rampe'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une assemblée sans place pour Joël le jour de la pluie est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une assemblée sans place pour Joël le jour de la pluie n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'La planche n''est pas une rampe'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Dénoncer ce que la cour rend invisible, notamment l'accès. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « La planche n'est pas une rampe », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La planche n'est pas une rampe
On parle trop vite de ce que la cour ne voit pas, comme si le mot dispensait d'en examiner le prix.
Encore que l'on mette la rampe à plus tard, une assemblée sans place pour Joël le jour de la pluie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice.
Ce que l'on nomme inégalité, ici, n'est pas un slogan : écart d'accès rendu normal par l'habitude.
Joël : il n'est que trop évident que la pluie choisit qui parle.
Solange a honte de la planche, et la honte n'est pas une rampe.
Léa écrit le manifeste au nom de ceux qui n'ont pas pu monter.
Dieudonné peut souder, il demande une date.
Karim chiffre le fer, refuse le mot bientôt.
Aline : la relative dont on se passe trop souvent, c'est ceux pour qui la cour se ferme.
Un chiffre, une trace : Joël a manqué trois assemblées de pluie ; la planche a glissé huit fois ; zéro date de rampe.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la cour soit une cour, pas un club de ceux qui montent vite
Lila lira le manifeste sans musique héroïque.
Solange Mukamana entend, dans « on s'adapte », ceci qui n'est pas dit : on s'adapte veut dire c'est à toi de disparaître quand il pleut
Autrement dit, dénoncer, ce n'est pas insulter : c'est rendre visible une inégalité que l'habitude a rendue normale
La proposition qui reste debout est celle-ci : un manifeste — rampe, heures, bancs, signatures du Bureau des Escales
Marc : dénoncer une inégalité, c'est rendre le banc habitable.
Nous clôturons sans fusionner les voix : le manifeste de Joël et de Léa d'un côté, les minutes trop vagues de l'assemblée de l'autre, et le point où elles refusent de se ressembler.
Signé : Joël Mugisha, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'La planche n''est pas une rampe'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : dénoncer une inégalité ; relatives complexes ; il n'est que trop.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on mette la rampe à plus tard, une assemblée sans place pour Joël le jour de la pluie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice.
Ce que l'on nomme inégalité, ici, n'est pas un slogan : écart d'accès rendu normal par l'habitude.
Encore que l'on dénonce, une assemblée sans place pour Joël le jour de la pluie n'est pas un détail.
Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice.
Autrement dit, dénoncer, ce n'est pas insulter : c'est rendre visible une inégalité que l'habitude a rendue normale
Il ressort qu'un manifeste : rampe, heures, bancs, signatures du Bureau des Escales
Solange a honte de la planche, et la honte n'est pas une rampe.
Karim chiffre le fer, refuse le mot bientôt.
La proposition qui reste debout est celle-ci : un manifeste — rampe, heures, bancs, signatures du Bureau des Escales
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le manifeste de Joël et de Léa d'un côté, les minutes trop vagues de l'assemblée de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'La planche n''est pas une rampe'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Dénoncer ce que la cour rend invisible, notamment l'accès. Point : dénoncer une inégalité ; relatives complexes ; il n'est que trop.

Consigne
Imitez le texte de Joël Mugisha.

Support — Joël Mugisha — La planche n'est pas une rampe
Joël Mugisha — La planche n'est pas une rampe
On parle trop vite de ce que la cour ne voit pas, comme si le mot dispensait d'en examiner le prix.
Encore que l'on mette la rampe à plus tard, une assemblée sans place pour Joël le jour de la pluie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice.
Ce que l'on nomme inégalité, ici, n'est pas un slogan : écart d'accès rendu normal par l'habitude.
Joël : il n'est que trop évident que la pluie choisit qui parle.
Karim chiffre le fer, refuse le mot bientôt.
Aline : la relative dont on se passe trop souvent, c'est ceux pour qui la cour se ferme.
Lila lira le manifeste sans musique héroïque.
La proposition qui reste debout est celle-ci : un manifeste — rampe, heures, bancs, signatures du Bureau des Escales
Marc : dénoncer une inégalité, c'est rendre le banc habitable.
Nous clôturons sans fusionner les voix : le manifeste de Joël et de Léa d'un côté, les minutes trop vagues de l'assemblée de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on dénonce, une assemblée sans place pour Joël le jour de la pluie n'est pas un détail.
Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
dénoncer, ce n'est pas insulter : c'est rendre visible une inégalité que l'habitude a rendue normale
Joël Mugisha, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'La planche n''est pas une rampe'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Joël Mugisha sur « La planche n’est pas une rampe » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Joël Mugisha sur « La planche n’est pas une rampe » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'La planche n''est pas une rampe'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Interpréter la gestuelle de la cour et des idiomes, sans les prendre pour des preuves. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Les épaules ne sont pas un verdict
Lila Sow : Radio Figuier. On parle trop vite des gestes sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on fasse d'un haussement d'épaules un verdict, une lecture trop sûre des mains de Rose n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Sami concède qu'un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Aline Uwase : Ce que l'on nomme geste, ici, n'est pas un slogan : mouvement à interpréter, non à juger trop vite.
Sami : j'ai les mots dans les mains, et ce n'est pas une preuve contre Rose.
Hawa Diallo : Rose tourne les talons pour coudre, non pour fuir un procès.
Joël Mugisha : Aline explique avoir les bras cassés : fatigue, pas anatomie.
Rose Iradukunda : Léa filme trop près ; Patrick lui demande de reculer.
Solange Mukamana : Hawa dit qu'un silence n'est pas un aveu.
Karim Bamba : Joël porte les lanternes : ses épaules parlent de fer, pas de honte.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a noté cinq épaules trop vite lues, deux silences, un tambour de Sami qui n'était pas une colère.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de lire le corps comme un texte, avec des hypothèses, pas des sentences
Lila : interpréter, c'est proposer, c'est laisser corriger.
Mado : Rose Iradukunda entend, dans « le corps ne ment pas », ceci qui n'est pas dit : le corps ne ment pas est souvent une excuse pour ne plus écouter les mots
Sami : Autrement dit, un idiome (avoir les bras cassés, tourner les talons) décrit une relation, pas une anatomie
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot
Marc : le corps ne ment pas est un slogan trop sûr pour une cour.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les notes de Léa sur les gestes d'un côté, le slam inventé de Sami de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Les épaules ne sont pas un verdict'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une lecture trop sûre des mains de Rose est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une lecture trop sûre des mains de Rose n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Les épaules ne sont pas un verdict'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Interpréter la gestuelle de la cour et des idiomes, sans les prendre pour des preuves. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Les épaules ne sont pas un verdict », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Les épaules ne sont pas un verdict
On parle trop vite des gestes sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on fasse d'un haussement d'épaules un verdict, une lecture trop sûre des mains de Rose n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède qu'un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Ce que l'on nomme geste, ici, n'est pas un slogan : mouvement à interpréter, non à juger trop vite.
Sami : j'ai les mots dans les mains, et ce n'est pas une preuve contre Rose.
Rose tourne les talons pour coudre, non pour fuir un procès.
Aline explique avoir les bras cassés : fatigue, pas anatomie.
Léa filme trop près ; Patrick lui demande de reculer.
Hawa dit qu'un silence n'est pas un aveu.
Joël porte les lanternes : ses épaules parlent de fer, pas de honte.
Un chiffre, une trace : Léa a noté cinq épaules trop vite lues, deux silences, un tambour de Sami qui n'était pas une colère.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de lire le corps comme un texte, avec des hypothèses, pas des sentences
Lila : interpréter, c'est proposer, c'est laisser corriger.
Rose Iradukunda entend, dans « le corps ne ment pas », ceci qui n'est pas dit : le corps ne ment pas est souvent une excuse pour ne plus écouter les mots
Autrement dit, un idiome (avoir les bras cassés, tourner les talons) décrit une relation, pas une anatomie
La proposition qui reste debout est celle-ci : interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot
Marc : le corps ne ment pas est un slogan trop sûr pour une cour.
Nous clôturons sans fusionner les voix : les notes de Léa sur les gestes d'un côté, le slam inventé de Sami de l'autre, et le point où elles refusent de se ressembler.
Signé : Sami, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Les épaules ne sont pas un verdict'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : idiomes corporels ; ne pas les calquer ; interpréter un geste.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on fasse d'un haussement d'épaules un verdict, une lecture trop sûre des mains de Rose n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède qu'un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Ce que l'on nomme geste, ici, n'est pas un slogan : mouvement à interpréter, non à juger trop vite.
Encore que l'on interprète, une lecture trop sûre des mains de Rose n'est pas un détail.
Sami concède qu'un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Autrement dit, un idiome (avoir les bras cassés, tourner les talons) décrit une relation, pas une anatomie
Il ressort qu'interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot
Rose tourne les talons pour coudre, non pour fuir un procès.
Hawa dit qu'un silence n'est pas un aveu.
La proposition qui reste debout est celle-ci : interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les notes de Léa sur les gestes d'un côté, le slam inventé de Sami de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Les épaules ne sont pas un verdict'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Sami transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Sami concède qu'un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Les épaules ne sont pas un verdict'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Interpréter la gestuelle de la cour et des idiomes, sans les prendre pour des preuves. Point : idiomes corporels ; ne pas les calquer ; interpréter un geste.

Consigne
Imitez le texte de Sami.

Support — Sami — Les épaules ne sont pas un verdict
Sami — Les épaules ne sont pas un verdict
On parle trop vite des gestes sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on fasse d'un haussement d'épaules un verdict, une lecture trop sûre des mains de Rose n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède qu'un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Ce que l'on nomme geste, ici, n'est pas un slogan : mouvement à interpréter, non à juger trop vite.
Sami : j'ai les mots dans les mains, et ce n'est pas une preuve contre Rose.
Hawa dit qu'un silence n'est pas un aveu.
Joël porte les lanternes : ses épaules parlent de fer, pas de honte.
Lila : interpréter, c'est proposer, c'est laisser corriger.
La proposition qui reste debout est celle-ci : interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot
Marc : le corps ne ment pas est un slogan trop sûr pour une cour.
Nous clôturons sans fusionner les voix : les notes de Léa sur les gestes d'un côté, le slam inventé de Sami de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on interprète, une lecture trop sûre des mains de Rose n'est pas un détail.
Sami concède qu'un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
un idiome (avoir les bras cassés, tourner les talons) décrit une relation, pas une anatomie
Sami, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Les épaules ne sont pas un verdict'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Sami sur « Les épaules ne sont pas un verdict » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Sami sur « Les épaules ne sont pas un verdict » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Les épaules ne sont pas un verdict'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser idiomes corporels ; ne pas les calquer ; interpréter un geste au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — idiomes corporels ; ne pas les calquer ; interpréter un geste
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on interprète, une lecture trop sûre des mains de Rose n'est pas un détail.
Sami concède qu'un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Autrement dit, un idiome (avoir les bras cassés, tourner les talons) décrit une relation, pas une anatomie
Il ressort qu'interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot
Piège : familier non signalé dans un discours d'assemblée
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme geste, ici, n'est pas un slogan : mouvement à interpréter, non à juger trop vite.
Rose tourne les talons pour coudre, non pour fuir un procès.
Hawa dit qu'un silence n'est pas un aveu.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au épaule pour de vrai genre, et Rose Iradukunda demande un registre plus net.
Correction : On va au épaule vraiment, et Rose Iradukunda demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Les épaules ne sont pas un verdict'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Analyser une œuvre inventée de Rose pour un audioguide. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le lin tient le geste
Lila Sow : Radio Figuier. On parle trop vite de l'œuvre de Rose à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace l'analyse par l'admiration muette, une toile dont on ne dit que le prix n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste.
Aline Uwase : Ce que l'on nomme œuvre, ici, n'est pas un slogan : travail de Rose, à décrire sans le posséder.
Patrick Habimana : On dirait que le lin marcherait si l'on cessait du clouer du regard.
Rose : je n'ai pas animé un corps, j'ai donné une ombre à une couture.
Joël Mugisha : Léa choisit le présent : la pièce avance, l'ocre retient.
Rose Iradukunda : Aline refuse le jargon d'école trop loin du fil.
Solange Mukamana : Sami veut frapper le tambour trop près ; Rose dit non.
Karim Bamba : Patrick décrit les onze pièces sans les compter comme un exploit.
Félicie Ndayishimiye : Un chiffre, une trace : Rose a cousu onze pièces d'ocre ; Léa a écrit trois hypothèses ; zéro prix annoncé au banc.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'interpréter sans posséder l'œuvre par le jargon
Yvette : Lila enregistrera l'audioguide dans la salle vide, d'abord.
Mado : Léa Niyonzima entend, dans « c'est beau point », ceci qui n'est pas dit : c'est beau point permet de ne pas voir le corps trop réel que Rose a cousu
Sami : Autrement dit, décrire, c'est choisir un angle : couture, ombre, regard, pas un mot magique
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un audioguide de trois minutes — matériaux, geste, hypothèse, silence
Marc : analyser une œuvre, c'est proposer, c'est se taire à temps.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'œuvre de Rose d'un côté, le brouillon d'audioguide de Léa de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Le lin tient le geste'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une toile dont on ne dit que le prix est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une toile dont on ne dit que le prix n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Le lin tient le geste'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Analyser une œuvre inventée de Rose pour un audioguide. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le lin tient le geste », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le lin tient le geste
On parle trop vite de l'œuvre de Rose à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'analyse par l'admiration muette, une toile dont on ne dit que le prix n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste.
Ce que l'on nomme œuvre, ici, n'est pas un slogan : travail de Rose, à décrire sans le posséder.
On dirait que le lin marcherait si l'on cessait du clouer du regard.
Rose : je n'ai pas animé un corps, j'ai donné une ombre à une couture.
Léa choisit le présent : la pièce avance, l'ocre retient.
Aline refuse le jargon d'école trop loin du fil.
Sami veut frapper le tambour trop près ; Rose dit non.
Patrick décrit les onze pièces sans les compter comme un exploit.
Un chiffre, une trace : Rose a cousu onze pièces d'ocre ; Léa a écrit trois hypothèses ; zéro prix annoncé au banc.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'interpréter sans posséder l'œuvre par le jargon
Lila enregistrera l'audioguide dans la salle vide, d'abord.
Léa Niyonzima entend, dans « c'est beau point », ceci qui n'est pas dit : c'est beau point permet de ne pas voir le corps trop réel que Rose a cousu
Autrement dit, décrire, c'est choisir un angle : couture, ombre, regard, pas un mot magique
La proposition qui reste debout est celle-ci : un audioguide de trois minutes — matériaux, geste, hypothèse, silence
Marc : analyser une œuvre, c'est proposer, c'est se taire à temps.
Nous clôturons sans fusionner les voix : l'œuvre de Rose d'un côté, le brouillon d'audioguide de Léa de l'autre, et le point où elles refusent de se ressembler.
Signé : Rose Iradukunda, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Le lin tient le geste'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : décrire une œuvre ; présent de reportage ; métaphore contrôlée.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace l'analyse par l'admiration muette, une toile dont on ne dit que le prix n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste.
Ce que l'on nomme œuvre, ici, n'est pas un slogan : travail de Rose, à décrire sans le posséder.
Encore que l'on décrive, une toile dont on ne dit que le prix n'est pas un détail.
Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste.
Autrement dit, décrire, c'est choisir un angle : couture, ombre, regard, pas un mot magique
Il ressort qu'un audioguide de trois minutes : matériaux, geste, hypothèse, silence
Rose : je n'ai pas animé un corps, j'ai donné une ombre à une couture.
Sami veut frapper le tambour trop près ; Rose dit non.
La proposition qui reste debout est celle-ci : un audioguide de trois minutes — matériaux, geste, hypothèse, silence
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'œuvre de Rose d'un côté, le brouillon d'audioguide de Léa de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Le lin tient le geste'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Analyser une œuvre inventée de Rose pour un audioguide. Point : décrire une œuvre ; présent de reportage ; métaphore contrôlée.

Consigne
Imitez le texte de Rose Iradukunda.

Support — Rose Iradukunda — Le lin tient le geste
Rose Iradukunda — Le lin tient le geste
On parle trop vite de l'œuvre de Rose à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'analyse par l'admiration muette, une toile dont on ne dit que le prix n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste.
Ce que l'on nomme œuvre, ici, n'est pas un slogan : travail de Rose, à décrire sans le posséder.
On dirait que le lin marcherait si l'on cessait du clouer du regard.
Sami veut frapper le tambour trop près ; Rose dit non.
Patrick décrit les onze pièces sans les compter comme un exploit.
Lila enregistrera l'audioguide dans la salle vide, d'abord.
La proposition qui reste debout est celle-ci : un audioguide de trois minutes — matériaux, geste, hypothèse, silence
Marc : analyser une œuvre, c'est proposer, c'est se taire à temps.
Nous clôturons sans fusionner les voix : l'œuvre de Rose d'un côté, le brouillon d'audioguide de Léa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on décrive, une toile dont on ne dit que le prix n'est pas un détail.
Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
décrire, c'est choisir un angle : couture, ombre, regard, pas un mot magique
Rose Iradukunda, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Le lin tient le geste'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Rose Iradukunda sur « Le lin tient le geste » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Rose Iradukunda sur « Le lin tient le geste » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Le lin tient le geste'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Écrire un manifeste qui exige sans insulter, et qui nomme des gestes. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Manifeste de la rampe
Lila Sow : Radio Figuier. On parle trop vite du manifeste pour la rampe, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on réduise le manifeste à un cri, un assez sans destinataire ni date n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Joël Mugisha concède qu'un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Aline Uwase : Ce que l'on nomme manifeste, ici, n'est pas un slogan : texte d'exigence argumentée.
Joël : nous exigeons que la rampe soit posée avant les pluies, non après les excuses.
Hawa Diallo : Il convient que l'on nomme Dieudonné et le fer.
Joël Mugisha : Solange rature les insultes, garde la colère.
Rose Iradukunda : Aline corrige le subjonctif, pas le fond.
Solange Mukamana : Léa ajoute les bancs.
Karim Bamba : Lila lira le manifeste à l'antenne, lentement.
Félicie Ndayishimiye : Un chiffre, une trace : Vingt-deux signatures ; une date proposée ; zéro insulte dans le texte retenu.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le manifeste puisse se relire sans honte quand la rampe sera là
Yvette : signe ; Sami aussi, sans grimace.
Mado : Karim Bamba entend, dans « assez », ceci qui n'est pas dit : assez tout seul laisse à la cour le loisir de n'avoir rien entendu
Sami : Autrement dit, nous exigeons que la rampe soit datée : le subjonctif ici est une volonté, pas une décoration
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un manifeste signé — rampe, bancs, pluie, fer, jeudi
Marc : une injonction sans date est un assez qui s'évapore.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le manifeste d'un côté, les ratures de Solange et d'Aline de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Manifeste de la rampe'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un assez sans destinataire ni date est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un assez sans destinataire ni date n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Manifeste de la rampe'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Écrire un manifeste qui exige sans insulter, et qui nomme des gestes. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Assez, puis la date », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Assez, puis la date
On parle trop vite du manifeste pour la rampe, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise le manifeste à un cri, un assez sans destinataire ni date n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède qu'un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Ce que l'on nomme manifeste, ici, n'est pas un slogan : texte d'exigence argumentée.
Joël : nous exigeons que la rampe soit posée avant les pluies, non après les excuses.
Il convient que l'on nomme Dieudonné et le fer.
Solange rature les insultes, garde la colère.
Aline corrige le subjonctif, pas le fond.
Léa ajoute les bancs.
Lila lira le manifeste à l'antenne, lentement.
Un chiffre, une trace : Vingt-deux signatures ; une date proposée ; zéro insulte dans le texte retenu.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le manifeste puisse se relire sans honte quand la rampe sera là
Yvette signe ; Sami aussi, sans grimace.
Karim Bamba entend, dans « assez », ceci qui n'est pas dit : assez tout seul laisse à la cour le loisir de n'avoir rien entendu
Autrement dit, nous exigeons que la rampe soit datée : le subjonctif ici est une volonté, pas une décoration
La proposition qui reste debout est celle-ci : un manifeste signé — rampe, bancs, pluie, fer, jeudi
Marc : une injonction sans date est un assez qui s'évapore.
Nous clôturons sans fusionner les voix : le manifeste d'un côté, les ratures de Solange et d'Aline de l'autre, et le point où elles refusent de se ressembler.
Signé : Joël Mugisha, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Manifeste de la rampe'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : injonction vs subjonctif de volonté ; nous exigeons que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on réduise le manifeste à un cri, un assez sans destinataire ni date n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède qu'un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Ce que l'on nomme manifeste, ici, n'est pas un slogan : texte d'exigence argumentée.
Encore que l'on exige, un assez sans destinataire ni date n'est pas un détail.
Joël Mugisha concède qu'un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Autrement dit, nous exigeons que la rampe soit datée : le subjonctif ici est une volonté, pas une décoration
Il ressort qu'un manifeste signé : rampe, bancs, pluie, fer, jeudi
Il convient que l'on nomme Dieudonné et le fer.
Léa ajoute les bancs.
La proposition qui reste debout est celle-ci : un manifeste signé — rampe, bancs, pluie, fer, jeudi
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le manifeste d'un côté, les ratures de Solange et d'Aline de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Manifeste de la rampe'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Joël Mugisha transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Joël Mugisha concède qu'un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Manifeste de la rampe'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Écrire un manifeste qui exige sans insulter, et qui nomme des gestes. Point : injonction vs subjonctif de volonté ; nous exigeons que.

Consigne
Imitez le texte de Joël Mugisha.

Support — Joël Mugisha — Assez, puis la date
Joël Mugisha — Assez, puis la date
On parle trop vite du manifeste pour la rampe, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise le manifeste à un cri, un assez sans destinataire ni date n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède qu'un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Ce que l'on nomme manifeste, ici, n'est pas un slogan : texte d'exigence argumentée.
Joël : nous exigeons que la rampe soit posée avant les pluies, non après les excuses.
Léa ajoute les bancs.
Lila lira le manifeste à l'antenne, lentement.
Yvette signe ; Sami aussi, sans grimace.
La proposition qui reste debout est celle-ci : un manifeste signé — rampe, bancs, pluie, fer, jeudi
Marc : une injonction sans date est un assez qui s'évapore.
Nous clôturons sans fusionner les voix : le manifeste d'un côté, les ratures de Solange et d'Aline de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on exige, un assez sans destinataire ni date n'est pas un détail.
Joël Mugisha concède qu'un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
nous exigeons que la rampe soit datée : le subjonctif ici est une volonté, pas une décoration
Joël Mugisha, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Manifeste de la rampe'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Joël Mugisha sur « Manifeste de la rampe » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Joël Mugisha sur « Manifeste de la rampe » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Manifeste de la rampe'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser injonction vs subjonctif de volonté ; nous exigeons que au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — injonction vs subjonctif de volonté ; nous exigeons que
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on exige, un assez sans destinataire ni date n'est pas un détail.
Joël Mugisha concède qu'un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Autrement dit, nous exigeons que la rampe soit datée : le subjonctif ici est une volonté, pas une décoration
Il ressort qu'un manifeste signé : rampe, bancs, pluie, fer, jeudi
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme manifeste, ici, n'est pas un slogan : texte d'exigence argumentée.
Il convient que l'on nomme Dieudonné et le fer.
Léa ajoute les bancs.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au signature pour de vrai genre, et Karim Bamba demande un registre plus net.
Correction : On va au signature vraiment, et Karim Bamba demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Manifeste de la rampe'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Enregistrer un audioguide qui guide sans posséder l'œuvre. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Audioguide de Rose
Lila Sow : Radio Figuier. On parle trop vite de l'audioguide de la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on force l'admiration, un vous trop sûr de ce que l'œil doit sentir n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Je concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer.
Aline Uwase : Ce que l'on nomme guide, ici, n'est pas un slogan : voix qui propose un regard.
Léa : vous pouvez vous tenir à gauche, là où le lin prend l'ombre.
Hawa Diallo : On dirait qu'une couture avance ; il se peut que ce soit seulement votre pas.
Joël Mugisha : Rose a demandé que l'on coupe vous allez aimer.
Aline : la deuxième personne n'est pas un ordre.
Solange Mukamana : Sami chuchote trop près du micro ; Lila recule.
Karim Bamba : Patrick aime le silence de huit secondes.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a chronométré 2 min 50 ; un silence de huit secondes ; zéro vous allez aimer.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'accompagner le regard, pas du remplacer
Yvette : Joël écoutera assis, si le banc est là.
Mado : Rose Iradukunda entend, dans « vous allez aimer », ceci qui n'est pas dit : vous allez aimer est déjà une petite violence polie
Sami : Autrement dit, vous pouvez voir, on dirait que, il se peut que : le guide propose, il n'assigne pas
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : trois minutes — matériaux, une hypothèse, un silence, une sortie
Marc : un audioguide est une hospitalité, pas une leçon de goût.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le script d'audioguide d'un côté, les remarques de Rose de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Audioguide de Rose'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un vous trop sûr de ce que l'œil doit sentir est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un vous trop sûr de ce que l'œil doit sentir n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Audioguide de Rose'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Enregistrer un audioguide qui guide sans posséder l'œuvre. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Vous pouvez voir », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Vous pouvez voir
On parle trop vite de l'audioguide de la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on force l'admiration, un vous trop sûr de ce que l'œil doit sentir n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer.
Ce que l'on nomme guide, ici, n'est pas un slogan : voix qui propose un regard.
Léa : vous pouvez vous tenir à gauche, là où le lin prend l'ombre.
On dirait qu'une couture avance ; il se peut que ce soit seulement votre pas.
Rose a demandé que l'on coupe vous allez aimer.
Aline : la deuxième personne n'est pas un ordre.
Sami chuchote trop près du micro ; Lila recule.
Patrick aime le silence de huit secondes.
Un chiffre, une trace : Léa a chronométré 2 min 50 ; un silence de huit secondes ; zéro vous allez aimer.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'accompagner le regard, pas du remplacer
Joël écoutera assis, si le banc est là.
Rose Iradukunda entend, dans « vous allez aimer », ceci qui n'est pas dit : vous allez aimer est déjà une petite violence polie
Autrement dit, vous pouvez voir, on dirait que, il se peut que : le guide propose, il n'assigne pas
La proposition qui reste debout est celle-ci : trois minutes — matériaux, une hypothèse, un silence, une sortie
Marc : un audioguide est une hospitalité, pas une leçon de goût.
Nous clôturons sans fusionner les voix : le script d'audioguide d'un côté, les remarques de Rose de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Audioguide de Rose'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : deuxième personne de guide ; hypotaxe ; hypothèse signalée.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on force l'admiration, un vous trop sûr de ce que l'œil doit sentir n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer.
Ce que l'on nomme guide, ici, n'est pas un slogan : voix qui propose un regard.
Encore que l'on guide, un vous trop sûr de ce que l'œil doit sentir n'est pas un détail.
Léa Niyonzima concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer.
Autrement dit, vous pouvez voir, on dirait que, il se peut que : le guide propose, il n'assigne pas
Il ressort que trois minutes : matériaux, une hypothèse, un silence, une sortie
On dirait qu'une couture avance ; il se peut que ce soit seulement votre pas.
Sami chuchote trop près du micro ; Lila recule.
La proposition qui reste debout est celle-ci : trois minutes — matériaux, une hypothèse, un silence, une sortie
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le script d'audioguide d'un côté, les remarques de Rose de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Audioguide de Rose'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Enregistrer un audioguide qui guide sans posséder l'œuvre. Point : deuxième personne de guide ; hypotaxe ; hypothèse signalée.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Vous pouvez voir
Léa Niyonzima — Vous pouvez voir
On parle trop vite de l'audioguide de la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on force l'admiration, un vous trop sûr de ce que l'œil doit sentir n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer.
Ce que l'on nomme guide, ici, n'est pas un slogan : voix qui propose un regard.
Léa : vous pouvez vous tenir à gauche, là où le lin prend l'ombre.
Sami chuchote trop près du micro ; Lila recule.
Patrick aime le silence de huit secondes.
Joël écoutera assis, si le banc est là.
La proposition qui reste debout est celle-ci : trois minutes — matériaux, une hypothèse, un silence, une sortie
Marc : un audioguide est une hospitalité, pas une leçon de goût.
Nous clôturons sans fusionner les voix : le script d'audioguide d'un côté, les remarques de Rose de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on guide, un vous trop sûr de ce que l'œil doit sentir n'est pas un détail.
Léa Niyonzima concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
vous pouvez voir, on dirait que, il se peut que : le guide propose, il n'assigne pas
Léa Niyonzima, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Audioguide de Rose'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Léa Niyonzima sur « Audioguide de Rose » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Léa Niyonzima sur « Audioguide de Rose » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Corps visibles'
  AND s.title = 'Audioguide de Rose'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;

-- C1 — Le monde de la cour
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Expliquer le message d'un chant de cour inventé, y compris ce qu'il ne dit pas. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Chant de la cour
Lila Sow : Radio Figuier. On parle trop vite du chant inventé de la cour, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on réduise le chant à un air, un refrain trop clair pour n'être pas une porte fermée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer.
Aline Uwase : Ce que l'on nomme refrain, ici, n'est pas un slogan : retour d'un chant, parfois une porte.
Sami : le refrain dit colline, et l'on entend trop vite panorama.
Hawa Diallo : Solange entend une porte.
Joël Mugisha : Mado écrit que la métaphore n'est pas un ornement.
Aline : expliquer un chant, c'est risquer d'être trop clair, et il le faut parfois.
Solange Mukamana : Léa refuse le mot verlan collé pour faire vrai.
Karim Bamba : Lila jouera l'air, puis le silence.
Félicie Ndayishimiye : Un chiffre, une trace : Sami a changé un mot ; Lila a reçu trois lectures opposées ; zéro clip trop lisse retenu.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'entendre le chant comme une parole de cour, pas comme un décor
Yvette : c'est juste une chanson est déjà une politique.
Mado : Solange Mukamana entend, dans « c'est juste une chanson », ceci qui n'est pas dit : c'est juste une chanson permet de ne pas entendre qui reste derrière la colline
Sami : Autrement dit, un chant engagé n'a pas besoin de slogan : l'implicite fait le travail, encore faut-il le lire
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : expliquer le message — qui parle, qui n'est pas nommé, quel geste le refrain demande
Marc : le message, c'est aussi qui n'a pas le micro.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les paroles inventées de Sami d'un côté, l'article de Mado sur le refrain de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Chant de la cour'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un refrain trop clair pour n'être pas une porte fermée est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un refrain trop clair pour n'être pas une porte fermée n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Chant de la cour'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Expliquer le message d'un chant de cour inventé, y compris ce qu'il ne dit pas. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le refrain n'est pas un décor », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le refrain n'est pas un décor
On parle trop vite du chant inventé de la cour, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise le chant à un air, un refrain trop clair pour n'être pas une porte fermée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer.
Ce que l'on nomme refrain, ici, n'est pas un slogan : retour d'un chant, parfois une porte.
Sami : le refrain dit colline, et l'on entend trop vite panorama.
Solange entend une porte.
Mado écrit que la métaphore n'est pas un ornement.
Aline : expliquer un chant, c'est risquer d'être trop clair, et il le faut parfois.
Léa refuse le mot verlan collé pour faire vrai.
Lila jouera l'air, puis le silence.
Un chiffre, une trace : Sami a changé un mot ; Lila a reçu trois lectures opposées ; zéro clip trop lisse retenu.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'entendre le chant comme une parole de cour, pas comme un décor
Yvette : c'est juste une chanson est déjà une politique.
Solange Mukamana entend, dans « c'est juste une chanson », ceci qui n'est pas dit : c'est juste une chanson permet de ne pas entendre qui reste derrière la colline
Autrement dit, un chant engagé n'a pas besoin de slogan : l'implicite fait le travail, encore faut-il le lire
La proposition qui reste debout est celle-ci : expliquer le message — qui parle, qui n'est pas nommé, quel geste le refrain demande
Marc : le message, c'est aussi qui n'a pas le micro.
Nous clôturons sans fusionner les voix : les paroles inventées de Sami d'un côté, l'article de Mado sur le refrain de l'autre, et le point où elles refusent de se ressembler.
Signé : Sami, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Chant de la cour'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : expliquer un implicite ; métaphore ; message d'un chant inventé.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on réduise le chant à un air, un refrain trop clair pour n'être pas une porte fermée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer.
Ce que l'on nomme refrain, ici, n'est pas un slogan : retour d'un chant, parfois une porte.
Encore que l'on explique, un refrain trop clair pour n'être pas une porte fermée n'est pas un détail.
Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer.
Autrement dit, un chant engagé n'a pas besoin de slogan : l'implicite fait le travail, encore faut-il le lire
Il ressort qu'expliquer le message : qui parle, qui n'est pas nommé, quel geste le refrain demande
Solange entend une porte.
Léa refuse le mot verlan collé pour faire vrai.
La proposition qui reste debout est celle-ci : expliquer le message — qui parle, qui n'est pas nommé, quel geste le refrain demande
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les paroles inventées de Sami d'un côté, l'article de Mado sur le refrain de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Chant de la cour'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Expliquer le message d'un chant de cour inventé, y compris ce qu'il ne dit pas. Point : expliquer un implicite ; métaphore ; message d'un chant inventé.

Consigne
Imitez le texte de Sami.

Support — Sami — Le refrain n'est pas un décor
Sami — Le refrain n'est pas un décor
On parle trop vite du chant inventé de la cour, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise le chant à un air, un refrain trop clair pour n'être pas une porte fermée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer.
Ce que l'on nomme refrain, ici, n'est pas un slogan : retour d'un chant, parfois une porte.
Sami : le refrain dit colline, et l'on entend trop vite panorama.
Léa refuse le mot verlan collé pour faire vrai.
Lila jouera l'air, puis le silence.
Yvette : c'est juste une chanson est déjà une politique.
La proposition qui reste debout est celle-ci : expliquer le message — qui parle, qui n'est pas nommé, quel geste le refrain demande
Marc : le message, c'est aussi qui n'a pas le micro.
Nous clôturons sans fusionner les voix : les paroles inventées de Sami d'un côté, l'article de Mado sur le refrain de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on explique, un refrain trop clair pour n'être pas une porte fermée n'est pas un détail.
Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
un chant engagé n'a pas besoin de slogan : l'implicite fait le travail, encore faut-il le lire
Sami, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Chant de la cour'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Sami sur « Chant de la cour » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Sami sur « Chant de la cour » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Chant de la cour'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Résumer un discours et écrire la biographie d'une voix engagée de la cour. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Biographie engagée
Lila Sow : Radio Figuier. On parle trop vite de la biographie de Solange Mukamana, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme Solange en statue, une nécrologie trop douce de son vivant n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Aline Uwase : Ce que l'on nomme biographie, ici, n'est pas un slogan : récit d'une vie, sans statue.
Patrick Habimana : Il fut un temps où Solange parlait trop tôt pour trop de portes.
Hawa Diallo : Elle avait déjà exigé la rampe quand on la disait trop pressée.
Joël Mugisha : Mado résume le discours sans le sucrer.
Aline : le plus-que-parfait dit l'antériorité d'une lutte, pas le mythe.
Solange Mukamana : Patrick refuse exceptionnelle : trop commode.
Karim Bamba : Lila lira la bio si Solange la signe.
Félicie Ndayishimiye : Un chiffre, une trace : Solange a ouvert quatre portes ; Mado a raturé six adjectifs trop grands ; un discours lu deux fois.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'écrire une vie qui reste une vie, pas un exemple impossible
Yvette : se reconnaît dans une porte, pas dans une couronne.
Mado : Solange Mukamana entend, dans « une femme exceptionnelle », ceci qui n'est pas dit : exceptionnelle permet de ne pas rendre ordinaires les droits qu'elle a exigés
Sami : Autrement dit, une biographie engagée relie les faits aux luttes, sans hagiographie
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : deux pages — dates, discours, ce qu'elle a refusé qu'on dise d'elle
Marc : selon le discours, il ressort que l'honneur véritable, c'est la date d'une rampe.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le discours de Solange sous le figuier d'un côté, la biographie raturée de Mado de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Biographie engagée'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une nécrologie trop douce de son vivant est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une nécrologie trop douce de son vivant n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Biographie engagée'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m5/discours-solange.svg",
      "word": "discours solange"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/necrologie-douce.svg",
      "word": "necrologie douce"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/portrait-voix.svg",
      "word": "portrait voix"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/accueil-cles.svg",
      "word": "accueil clés"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Biographie engagée'
  AND l.competency = 'CO'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Résumer un discours et écrire la biographie d'une voix engagée de la cour. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Pas une statue », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Pas une statue
On parle trop vite de la biographie de Solange Mukamana, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme Solange en statue, une nécrologie trop douce de son vivant n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Ce que l'on nomme biographie, ici, n'est pas un slogan : récit d'une vie, sans statue.
Il fut un temps où Solange parlait trop tôt pour trop de portes.
Elle avait déjà exigé la rampe quand on la disait trop pressée.
Mado résume le discours sans le sucrer.
Aline : le plus-que-parfait dit l'antériorité d'une lutte, pas le mythe.
Patrick refuse exceptionnelle : trop commode.
Lila lira la bio si Solange la signe.
Un chiffre, une trace : Solange a ouvert quatre portes ; Mado a raturé six adjectifs trop grands ; un discours lu deux fois.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'écrire une vie qui reste une vie, pas un exemple impossible
Yvette se reconnaît dans une porte, pas dans une couronne.
Solange Mukamana entend, dans « une femme exceptionnelle », ceci qui n'est pas dit : exceptionnelle permet de ne pas rendre ordinaires les droits qu'elle a exigés
Autrement dit, une biographie engagée relie les faits aux luttes, sans hagiographie
La proposition qui reste debout est celle-ci : deux pages — dates, discours, ce qu'elle a refusé qu'on dise d'elle
Marc : selon le discours, il ressort que l'honneur véritable, c'est la date d'une rampe.
Nous clôturons sans fusionner les voix : le discours de Solange sous le figuier d'un côté, la biographie raturée de Mado de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Biographie engagée'
  AND l.competency = 'CE';
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m5/necrologie-douce.svg",
      "word": "necrologie douce"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/portrait-voix.svg",
      "word": "portrait voix"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/accueil-cles.svg",
      "word": "accueil clés"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/poeme-rive.svg",
      "word": "poeme rive"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Biographie engagée'
  AND l.competency = 'CE'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : plus-que-parfait ; il fut un temps ; résumé d'un discours.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme Solange en statue, une nécrologie trop douce de son vivant n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Ce que l'on nomme biographie, ici, n'est pas un slogan : récit d'une vie, sans statue.
Encore que l'on raconte, une nécrologie trop douce de son vivant n'est pas un détail.
Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Autrement dit, une biographie engagée relie les faits aux luttes, sans hagiographie
Il ressort que deux pages : dates, discours, ce qu'elle a refusé qu'on dise d'elle
Elle avait déjà exigé la rampe quand on la disait trop pressée.
Patrick refuse exceptionnelle : trop commode.
La proposition qui reste debout est celle-ci : deux pages — dates, discours, ce qu'elle a refusé qu'on dise d'elle
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le discours de Solange sous le figuier d'un côté, la biographie raturée de Mado de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Biographie engagée'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m5/portrait-voix.svg",
      "word": "portrait voix"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/accueil-cles.svg",
      "word": "accueil clés"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/poeme-rive.svg",
      "word": "poeme rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/chronique-humor.svg",
      "word": "chronique humor"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Biographie engagée'
  AND l.competency = 'PO'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Résumer un discours et écrire la biographie d'une voix engagée de la cour. Point : plus-que-parfait ; il fut un temps ; résumé d'un discours.

Consigne
Imitez le texte de Mado.

Support — Mado — Pas une statue
Mado — Pas une statue
On parle trop vite de la biographie de Solange Mukamana, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme Solange en statue, une nécrologie trop douce de son vivant n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Ce que l'on nomme biographie, ici, n'est pas un slogan : récit d'une vie, sans statue.
Il fut un temps où Solange parlait trop tôt pour trop de portes.
Patrick refuse exceptionnelle : trop commode.
Lila lira la bio si Solange la signe.
Yvette se reconnaît dans une porte, pas dans une couronne.
La proposition qui reste debout est celle-ci : deux pages — dates, discours, ce qu'elle a refusé qu'on dise d'elle
Marc : selon le discours, il ressort que l'honneur véritable, c'est la date d'une rampe.
Nous clôturons sans fusionner les voix : le discours de Solange sous le figuier d'un côté, la biographie raturée de Mado de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on raconte, une nécrologie trop douce de son vivant n'est pas un détail.
Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
une biographie engagée relie les faits aux luttes, sans hagiographie
Mado, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Biographie engagée'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Mado sur « Biographie engagée » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Mado sur « Biographie engagée » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Biographie engagée'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m5/accueil-cles.svg",
      "word": "accueil clés"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/poeme-rive.svg",
      "word": "poeme rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/chronique-humor.svg",
      "word": "chronique humor"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/valise-ouverte.svg",
      "word": "valise ouverte"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Biographie engagée'
  AND l.competency = 'PE'
  AND e.exercise_type = 'image_match'
  AND e.order_index = 7;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser plus-que-parfait ; il fut un temps ; résumé d'un discours au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — plus-que-parfait ; il fut un temps ; résumé d'un discours
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on raconte, une nécrologie trop douce de son vivant n'est pas un détail.
Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Autrement dit, une biographie engagée relie les faits aux luttes, sans hagiographie
Il ressort que deux pages : dates, discours, ce qu'elle a refusé qu'on dise d'elle
Piège : fusionner les sources au lieu des attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme biographie, ici, n'est pas un slogan : récit d'une vie, sans statue.
Elle avait déjà exigé la rampe quand on la disait trop pressée.
Patrick refuse exceptionnelle : trop commode.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au lutte pour de vrai genre, et Solange Mukamana demande un registre plus net.
Correction : On va au lutte vraiment, et Solange Mukamana demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Biographie engagée'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Comprendre une chronique d'accueil et écrire un poème sans slogan. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le sourire n'est pas un lit
Lila Sow : Radio Figuier. On parle trop vite de l'accueil à Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on tienne lieu de lit et de papiers, un sourire trop large à la porte du Pavillon n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Hawa Diallo concède qu'un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Aline Uwase : Ce que l'on nomme accueil, ici, n'est pas un slogan : geste concret, distinct d'un mot.
Hawa : il ne s'agirait que d'un détail, le lit, à entendre certains sourires.
Hawa Diallo : Loin de rassurer, le mot hospitaliers fatigue quand la clé manque.
Joël Mugisha : Mado écrit une chronique où le sourire trébuche, sans écraser personne.
Aline : l'humour ici n'est pas une arme contre ceux qui arrivent.
Solange Mukamana : Patrick pose un banc.
Karim Bamba : Rose coud un ourlet trop large pour une valise trop pleine.
Félicie Ndayishimiye : Un chiffre, une trace : Hawa a reçu trois valises ; deux clés ; un sourire sans banc. Mado en a fait huit vers.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'accueillir des personnes, pas d'illustrer une vertu
Yvette : Lila lira le poème lentement.
Mado : Dieudonné Hakizimana entend, dans « nous sommes hospitaliers », ceci qui n'est pas dit : nous sommes hospitaliers se dit trop souvent à ceux à qui l'on n'a rien donné
Sami : Autrement dit, le poème peut dire l'accueil mieux qu'une affiche, s'il nomme la clé
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une chronique d'humour sans mépris, puis un poème qui tient dans la poche
Marc : un accueil de cour se mesure aux clés, pas aux phrases.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : la chronique de Mado d'un côté, le poème d'Hawa de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Le sourire n''est pas un lit'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un sourire trop large à la porte du Pavillon est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un sourire trop large à la porte du Pavillon n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Le sourire n''est pas un lit'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comprendre une chronique d'accueil et écrire un poème sans slogan. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le sourire n'est pas un lit », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le sourire n'est pas un lit
On parle trop vite de l'accueil à Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu de lit et de papiers, un sourire trop large à la porte du Pavillon n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède qu'un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Ce que l'on nomme accueil, ici, n'est pas un slogan : geste concret, distinct d'un mot.
Hawa : il ne s'agirait que d'un détail, le lit, à entendre certains sourires.
Loin de rassurer, le mot hospitaliers fatigue quand la clé manque.
Mado écrit une chronique où le sourire trébuche, sans écraser personne.
Aline : l'humour ici n'est pas une arme contre ceux qui arrivent.
Patrick pose un banc.
Rose coud un ourlet trop large pour une valise trop pleine.
Un chiffre, une trace : Hawa a reçu trois valises ; deux clés ; un sourire sans banc. Mado en a fait huit vers.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'accueillir des personnes, pas d'illustrer une vertu
Lila lira le poème lentement.
Dieudonné Hakizimana entend, dans « nous sommes hospitaliers », ceci qui n'est pas dit : nous sommes hospitaliers se dit trop souvent à ceux à qui l'on n'a rien donné
Autrement dit, le poème peut dire l'accueil mieux qu'une affiche, s'il nomme la clé
La proposition qui reste debout est celle-ci : une chronique d'humour sans mépris, puis un poème qui tient dans la poche
Marc : un accueil de cour se mesure aux clés, pas aux phrases.
Nous clôturons sans fusionner les voix : la chronique de Mado d'un côté, le poème d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Signé : Hawa Diallo, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Le sourire n''est pas un lit'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : humour et sous-entendu ; écrire un poème ; chronique.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on tienne lieu de lit et de papiers, un sourire trop large à la porte du Pavillon n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède qu'un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Ce que l'on nomme accueil, ici, n'est pas un slogan : geste concret, distinct d'un mot.
Encore que l'on accueille, un sourire trop large à la porte du Pavillon n'est pas un détail.
Hawa Diallo concède qu'un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Autrement dit, le poème peut dire l'accueil mieux qu'une affiche, s'il nomme la clé
Il ressort qu'une chronique d'humour sans mépris, puis un poème qui tient dans la poche
Loin de rassurer, le mot hospitaliers fatigue quand la clé manque.
Patrick pose un banc.
La proposition qui reste debout est celle-ci : une chronique d'humour sans mépris, puis un poème qui tient dans la poche
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : la chronique de Mado d'un côté, le poème d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Le sourire n''est pas un lit'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Hawa Diallo transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Hawa Diallo concède qu'un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Le sourire n''est pas un lit'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Comprendre une chronique d'accueil et écrire un poème sans slogan. Point : humour et sous-entendu ; écrire un poème ; chronique.

Consigne
Imitez le texte de Hawa Diallo.

Support — Hawa Diallo — Le sourire n'est pas un lit
Hawa Diallo — Le sourire n'est pas un lit
On parle trop vite de l'accueil à Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu de lit et de papiers, un sourire trop large à la porte du Pavillon n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède qu'un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Ce que l'on nomme accueil, ici, n'est pas un slogan : geste concret, distinct d'un mot.
Hawa : il ne s'agirait que d'un détail, le lit, à entendre certains sourires.
Patrick pose un banc.
Rose coud un ourlet trop large pour une valise trop pleine.
Lila lira le poème lentement.
La proposition qui reste debout est celle-ci : une chronique d'humour sans mépris, puis un poème qui tient dans la poche
Marc : un accueil de cour se mesure aux clés, pas aux phrases.
Nous clôturons sans fusionner les voix : la chronique de Mado d'un côté, le poème d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on accueille, un sourire trop large à la porte du Pavillon n'est pas un détail.
Hawa Diallo concède qu'un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
le poème peut dire l'accueil mieux qu'une affiche, s'il nomme la clé
Hawa Diallo, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Le sourire n''est pas un lit'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Hawa Diallo sur « Le sourire n’est pas un lit » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Hawa Diallo sur « Le sourire n’est pas un lit » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Le sourire n''est pas un lit'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser humour et sous-entendu ; écrire un poème ; chronique au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — humour et sous-entendu ; écrire un poème ; chronique
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on accueille, un sourire trop large à la porte du Pavillon n'est pas un détail.
Hawa Diallo concède qu'un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Autrement dit, le poème peut dire l'accueil mieux qu'une affiche, s'il nomme la clé
Il ressort qu'une chronique d'humour sans mépris, puis un poème qui tient dans la poche
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme accueil, ici, n'est pas un slogan : geste concret, distinct d'un mot.
Loin de rassurer, le mot hospitaliers fatigue quand la clé manque.
Patrick pose un banc.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au poème pour de vrai genre, et Dieudonné Hakizimana demande un registre plus net.
Correction : On va au poème vraiment, et Dieudonné Hakizimana demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Le sourire n''est pas un lit'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Comparer deux générations et adapter le registre sans mépris. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Deux vitesses une cour
Lila Sow : Radio Figuier. On parle trop vite de deux âges sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on ferme l'oreille aux plus jeunes ou aux plus vieux, un sketch trop sûr de ses cibles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs.
Aline Uwase : Ce que l'on nomme génération, ici, n'est pas un slogan : âge d'une parole, pas une armée.
Yvette : de mon temps, on disait cela, et ce n'était pas toujours mieux.
Hawa Diallo : Sami tutole trop vite le micro ; Aline lui rappelle l'oreille de l'assemblée.
Joël Mugisha : Alors que les lanternes pèsent pareil, les récits d'effort divergent.
Rose Iradukunda : Patrick refuse le sketch qui écrase.
Solange Mukamana : Mado rature trois vannes.
Karim Bamba : Lila vouvoie, puis explique pourquoi.
Félicie Ndayishimiye : Un chiffre, une trace : Yvette vouvoie Lila au micro ; tutole Sami au banc ; Sami inverse parfois, et l'on en parle.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la cour tienne deux vitesses de parole sans humiliation
Yvette : Joël se tait : le fer n'a pas d'âge, dit-il.
Mado : Sami entend, dans « de mon temps », ceci qui n'est pas dit : de mon temps veut souvent dire le vôtre ne compte pas
Sami : Autrement dit, comparer des âges, c'est croiser des registres, pas couronner une génération
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un dialogue — Yvette et Sami, deux registres, une cour commune
Marc : adapter le registre, c'est respecter l'oreille, pas trahir.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le portrait d'Yvette par Mado d'un côté, le sketch trop dur de Sami, raturé de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Deux vitesses une cour'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "un sketch trop sûr de ses cibles est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'un sketch trop sûr de ses cibles n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Deux vitesses une cour'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comparer deux générations et adapter le registre sans mépris. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Deux vitesses, une cour », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Deux vitesses, une cour
On parle trop vite de deux âges sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on ferme l'oreille aux plus jeunes ou aux plus vieux, un sketch trop sûr de ses cibles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs.
Ce que l'on nomme génération, ici, n'est pas un slogan : âge d'une parole, pas une armée.
Yvette : de mon temps, on disait cela, et ce n'était pas toujours mieux.
Sami tutole trop vite le micro ; Aline lui rappelle l'oreille de l'assemblée.
Alors que les lanternes pèsent pareil, les récits d'effort divergent.
Patrick refuse le sketch qui écrase.
Mado rature trois vannes.
Lila vouvoie, puis explique pourquoi.
Un chiffre, une trace : Yvette vouvoie Lila au micro ; tutole Sami au banc ; Sami inverse parfois, et l'on en parle.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la cour tienne deux vitesses de parole sans humiliation
Joël se tait : le fer n'a pas d'âge, dit-il.
Sami entend, dans « de mon temps », ceci qui n'est pas dit : de mon temps veut souvent dire le vôtre ne compte pas
Autrement dit, comparer des âges, c'est croiser des registres, pas couronner une génération
La proposition qui reste debout est celle-ci : un dialogue — Yvette et Sami, deux registres, une cour commune
Marc : adapter le registre, c'est respecter l'oreille, pas trahir.
Nous clôturons sans fusionner les voix : le portrait d'Yvette par Mado d'un côté, le sketch trop dur de Sami, raturé de l'autre, et le point où elles refusent de se ressembler.
Signé : Yvette, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Deux vitesses une cour'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : registres selon l'interlocuteur ; tutoiement / vouvoiement ; alors que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on ferme l'oreille aux plus jeunes ou aux plus vieux, un sketch trop sûr de ses cibles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs.
Ce que l'on nomme génération, ici, n'est pas un slogan : âge d'une parole, pas une armée.
Encore que l'on adapte, un sketch trop sûr de ses cibles n'est pas un détail.
Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs.
Autrement dit, comparer des âges, c'est croiser des registres, pas couronner une génération
Il ressort qu'un dialogue : Yvette et Sami, deux registres, une cour commune
Sami tutole trop vite le micro ; Aline lui rappelle l'oreille de l'assemblée.
Mado rature trois vannes.
La proposition qui reste debout est celle-ci : un dialogue — Yvette et Sami, deux registres, une cour commune
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le portrait d'Yvette par Mado d'un côté, le sketch trop dur de Sami, raturé de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Deux vitesses une cour'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Comparer deux générations et adapter le registre sans mépris. Point : registres selon l'interlocuteur ; tutoiement / vouvoiement ; alors que.

Consigne
Imitez le texte de Yvette.

Support — Yvette — Deux vitesses, une cour
Yvette — Deux vitesses, une cour
On parle trop vite de deux âges sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on ferme l'oreille aux plus jeunes ou aux plus vieux, un sketch trop sûr de ses cibles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs.
Ce que l'on nomme génération, ici, n'est pas un slogan : âge d'une parole, pas une armée.
Yvette : de mon temps, on disait cela, et ce n'était pas toujours mieux.
Mado rature trois vannes.
Lila vouvoie, puis explique pourquoi.
Joël se tait : le fer n'a pas d'âge, dit-il.
La proposition qui reste debout est celle-ci : un dialogue — Yvette et Sami, deux registres, une cour commune
Marc : adapter le registre, c'est respecter l'oreille, pas trahir.
Nous clôturons sans fusionner les voix : le portrait d'Yvette par Mado d'un côté, le sketch trop dur de Sami, raturé de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on adapte, un sketch trop sûr de ses cibles n'est pas un détail.
Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
comparer des âges, c'est croiser des registres, pas couronner une génération
Yvette, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Deux vitesses une cour'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Yvette sur « Deux vitesses une cour » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Yvette sur « Deux vitesses une cour » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Deux vitesses une cour'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Croiser un poème et une chronique pour dire le monde de la cour. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Poème et chronique
Lila Sow : Radio Figuier. On parle trop vite du cahier des combats, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on sépare trop net la gravité et le rire, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède qu'un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Aline Uwase : Ce que l'on nomme diptyque, ici, n'est pas un slogan : deux volets d'un même propos.
Mado : loin de s'opposer, le vers et la chronique se prêtent la date.
Hawa Diallo : Il ne s'agirait que d'un détail, le genre, à entendre ceux qui ont peur du mélange.
Joël Mugisha : Sami pose un rythme entre les deux.
Rose Iradukunda : Aline accepte le mélange si l'implicite tient.
Solange Mukamana : Solange se reconnaît dans la chronique, Léa dans le vers.
Karim Bamba : Patrick a peur du désordre ; il relit, il cède.
Félicie Ndayishimiye : Un chiffre, une trace : Mado a publié les deux le même jeudi ; Lila a lu l'un, puis l'autre ; trois auditeurs ont entendu le même implicite.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de garder plusieurs langues pour un même monde
Lila : deux lectures, une oreille.
Mado : Lila Sow entend, dans « il faut choisir un genre », ceci qui n'est pas dit : choisir un genre veut parfois dire ne sois pas trop vivant
Sami : Autrement dit, la chronique peut porter un vers, le poème une date : le Seuil n'est pas une anthologie trop sage
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un diptyque — huit vers, une chronique, un même non-dit
Marc : le monde de la cour n'a pas un seul ton, et c'est tant mieux.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le poème de Mado d'un côté, sa chronique du même jeudi de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Poème et chronique'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une cour qui n'aurait droit qu'à un seul ton est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une cour qui n'aurait droit qu'à un seul ton n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Poème et chronique'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Croiser un poème et une chronique pour dire le monde de la cour. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Deux formes, un non-dit », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Deux formes, un non-dit
On parle trop vite du cahier des combats, comme si le mot dispensait d'en examiner le prix.
Encore que l'on sépare trop net la gravité et le rire, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède qu'un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Ce que l'on nomme diptyque, ici, n'est pas un slogan : deux volets d'un même propos.
Mado : loin de s'opposer, le vers et la chronique se prêtent la date.
Il ne s'agirait que d'un détail, le genre, à entendre ceux qui ont peur du mélange.
Sami pose un rythme entre les deux.
Aline accepte le mélange si l'implicite tient.
Solange se reconnaît dans la chronique, Léa dans le vers.
Patrick a peur du désordre ; il relit, il cède.
Un chiffre, une trace : Mado a publié les deux le même jeudi ; Lila a lu l'un, puis l'autre ; trois auditeurs ont entendu le même implicite.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de garder plusieurs langues pour un même monde
Lila : deux lectures, une oreille.
Lila Sow entend, dans « il faut choisir un genre », ceci qui n'est pas dit : choisir un genre veut parfois dire ne sois pas trop vivant
Autrement dit, la chronique peut porter un vers, le poème une date : le Seuil n'est pas une anthologie trop sage
La proposition qui reste debout est celle-ci : un diptyque — huit vers, une chronique, un même non-dit
Marc : le monde de la cour n'a pas un seul ton, et c'est tant mieux.
Nous clôturons sans fusionner les voix : le poème de Mado d'un côté, sa chronique du même jeudi de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Poème et chronique'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : croiser deux genres ; implicite ; humour sans mépris.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on sépare trop net la gravité et le rire, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède qu'un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Ce que l'on nomme diptyque, ici, n'est pas un slogan : deux volets d'un même propos.
Encore que l'on croise, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail.
Mado concède qu'un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Autrement dit, la chronique peut porter un vers, le poème une date : le Seuil n'est pas une anthologie trop sage
Il ressort qu'un diptyque : huit vers, une chronique, un même non-dit
Il ne s'agirait que d'un détail, le genre, à entendre ceux qui ont peur du mélange.
Solange se reconnaît dans la chronique, Léa dans le vers.
La proposition qui reste debout est celle-ci : un diptyque — huit vers, une chronique, un même non-dit
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le poème de Mado d'un côté, sa chronique du même jeudi de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Poème et chronique'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Mado transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Mado concède qu'un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Poème et chronique'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Croiser un poème et une chronique pour dire le monde de la cour. Point : croiser deux genres ; implicite ; humour sans mépris.

Consigne
Imitez le texte de Mado.

Support — Mado — Deux formes, un non-dit
Mado — Deux formes, un non-dit
On parle trop vite du cahier des combats, comme si le mot dispensait d'en examiner le prix.
Encore que l'on sépare trop net la gravité et le rire, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède qu'un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Ce que l'on nomme diptyque, ici, n'est pas un slogan : deux volets d'un même propos.
Mado : loin de s'opposer, le vers et la chronique se prêtent la date.
Solange se reconnaît dans la chronique, Léa dans le vers.
Patrick a peur du désordre ; il relit, il cède.
Lila : deux lectures, une oreille.
La proposition qui reste debout est celle-ci : un diptyque — huit vers, une chronique, un même non-dit
Marc : le monde de la cour n'a pas un seul ton, et c'est tant mieux.
Nous clôturons sans fusionner les voix : le poème de Mado d'un côté, sa chronique du même jeudi de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on croise, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail.
Mado concède qu'un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
la chronique peut porter un vers, le poème une date : le Seuil n'est pas une anthologie trop sage
Mado, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Poème et chronique'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Mado sur « Poème et chronique » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Mado sur « Poème et chronique » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Poème et chronique'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser croiser deux genres ; implicite ; humour sans mépris au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — croiser deux genres ; implicite ; humour sans mépris
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on croise, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail.
Mado concède qu'un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Autrement dit, la chronique peut porter un vers, le poème une date : le Seuil n'est pas une anthologie trop sage
Il ressort qu'un diptyque : huit vers, une chronique, un même non-dit
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme diptyque, ici, n'est pas un slogan : deux volets d'un même propos.
Il ne s'agirait que d'un détail, le genre, à entendre ceux qui ont peur du mélange.
Solange se reconnaît dans la chronique, Léa dans le vers.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au ton pour de vrai genre, et Lila Sow demande un registre plus net.
Correction : On va au ton vraiment, et Lila Sow demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Poème et chronique'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Comparer deux modes de vie d'âges différents sans couronner l'un des deux. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Comparaison de générations
Lila Sow : Radio Figuier. On parle trop vite de la comparaison Yvette / Sami, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on gagne le débat par la nostalgie, une synthèse qui n'est qu'un vainqueur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Aline Uwase : Ce que l'on nomme comparaison, ici, n'est pas un slogan : mise en regard, sans podium.
Patrick Habimana : Selon Yvette, les soirs étaient plus lents ; d'après Sami, ils étaient plus muets pour certains.
Hawa Diallo : Il ressort que les lanternes pèsent autant.
Joël Mugisha : Alors que l'un veut le silence, l'autre veut le micro, la cour a besoin des deux.
Aline : à mesure que l'on compare, on découvre les non-dits.
Solange Mukamana : Mado rature mieux avant.
Karim Bamba : Lila lira les deux colonnes.
Félicie Ndayishimiye : Un chiffre, une trace : Patrick a dressé deux colonnes ; six points communs ; zéro vainqueur.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la comparaison serve la cour, pas une hiérarchie d'âges
Joël : le fer n'a pas de nostalgie.
Mado : Yvette entend, dans « c'était mieux avant », ceci qui n'est pas dit : c'était mieux avant efface trop souvent qui n'avait pas la parole
Sami : Autrement dit, à mesure que la cour change, comparer n'est pas classer
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une synthèse — deux emplois du temps, deux peurs, un banc commun
Marc : une synthèse sans vainqueur est déjà un geste politique.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les deux emplois du temps d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Comparaison de générations'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une synthèse qui n'est qu'un vainqueur est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une synthèse qui n'est qu'un vainqueur n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Comparaison de générations'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comparer deux modes de vie d'âges différents sans couronner l'un des deux. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Zéro vainqueur », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Zéro vainqueur
On parle trop vite de la comparaison Yvette / Sami, comme si le mot dispensait d'en examiner le prix.
Encore que l'on gagne le débat par la nostalgie, une synthèse qui n'est qu'un vainqueur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Ce que l'on nomme comparaison, ici, n'est pas un slogan : mise en regard, sans podium.
Selon Yvette, les soirs étaient plus lents ; d'après Sami, ils étaient plus muets pour certains.
Il ressort que les lanternes pèsent autant.
Alors que l'un veut le silence, l'autre veut le micro, la cour a besoin des deux.
Aline : à mesure que l'on compare, on découvre les non-dits.
Mado rature mieux avant.
Lila lira les deux colonnes.
Un chiffre, une trace : Patrick a dressé deux colonnes ; six points communs ; zéro vainqueur.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la comparaison serve la cour, pas une hiérarchie d'âges
Joël : le fer n'a pas de nostalgie.
Yvette entend, dans « c'était mieux avant », ceci qui n'est pas dit : c'était mieux avant efface trop souvent qui n'avait pas la parole
Autrement dit, à mesure que la cour change, comparer n'est pas classer
La proposition qui reste debout est celle-ci : une synthèse — deux emplois du temps, deux peurs, un banc commun
Marc : une synthèse sans vainqueur est déjà un geste politique.
Nous clôturons sans fusionner les voix : les deux emplois du temps d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
Signé : Patrick Habimana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Comparaison de générations'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : alors que / tandis que / à mesure que ; synthèse.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on gagne le débat par la nostalgie, une synthèse qui n'est qu'un vainqueur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Ce que l'on nomme comparaison, ici, n'est pas un slogan : mise en regard, sans podium.
Encore que l'on compare, une synthèse qui n'est qu'un vainqueur n'est pas un détail.
Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Autrement dit, à mesure que la cour change, comparer n'est pas classer
Il ressort qu'une synthèse : deux emplois du temps, deux peurs, un banc commun
Il ressort que les lanternes pèsent autant.
Mado rature mieux avant.
La proposition qui reste debout est celle-ci : une synthèse — deux emplois du temps, deux peurs, un banc commun
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les deux emplois du temps d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Comparaison de générations'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Comparer deux modes de vie d'âges différents sans couronner l'un des deux. Point : alors que / tandis que / à mesure que ; synthèse.

Consigne
Imitez le texte de Patrick Habimana.

Support — Patrick Habimana — Zéro vainqueur
Patrick Habimana — Zéro vainqueur
On parle trop vite de la comparaison Yvette / Sami, comme si le mot dispensait d'en examiner le prix.
Encore que l'on gagne le débat par la nostalgie, une synthèse qui n'est qu'un vainqueur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Ce que l'on nomme comparaison, ici, n'est pas un slogan : mise en regard, sans podium.
Selon Yvette, les soirs étaient plus lents ; d'après Sami, ils étaient plus muets pour certains.
Mado rature mieux avant.
Lila lira les deux colonnes.
Joël : le fer n'a pas de nostalgie.
La proposition qui reste debout est celle-ci : une synthèse — deux emplois du temps, deux peurs, un banc commun
Marc : une synthèse sans vainqueur est déjà un geste politique.
Nous clôturons sans fusionner les voix : les deux emplois du temps d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on compare, une synthèse qui n'est qu'un vainqueur n'est pas un détail.
Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
à mesure que la cour change, comparer n'est pas classer
Patrick Habimana, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Comparaison de générations'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Patrick Habimana sur « Comparaison de générations » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Patrick Habimana sur « Comparaison de générations » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Comparaison de générations'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser alors que / tandis que / à mesure que ; synthèse au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — alors que / tandis que / à mesure que ; synthèse
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on compare, une synthèse qui n'est qu'un vainqueur n'est pas un détail.
Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Autrement dit, à mesure que la cour change, comparer n'est pas classer
Il ressort qu'une synthèse : deux emplois du temps, deux peurs, un banc commun
Piège : fusionner les sources au lieu des attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme comparaison, ici, n'est pas un slogan : mise en regard, sans podium.
Il ressort que les lanternes pèsent autant.
Mado rature mieux avant.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au synthèse pour de vrai genre, et Yvette demande un registre plus net.
Correction : On va au synthèse vraiment, et Yvette demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Le monde de la cour'
  AND s.title = 'Comparaison de générations'
  AND l.competency = 'EL';

-- C1 — Travailler au Seuil
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Réaliser une revue de presse de l'atelier et de la radio, sans fusionner les sources. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Pas de tout le monde dit
Lila Sow : Radio Figuier. On parle trop vite de la revue de presse du Seuil, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface les signatures, une revue trop lisse pour être honnête n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Lila Sow concède que raccourcir aide l'oreille, pour autant que l'on garde selon et d'après.
Aline Uwase : Ce que l'on nomme revue, ici, n'est pas un slogan : tour de sources attribuées.
Patrick Habimana : Selon le Cahier, l'atelier manque de relais ; d'après l'antenne, la radio manque d'heures.
Hawa Diallo : Il ressort que les deux manques se parlent.
Joël Mugisha : Rose a dit que les mains n'apparaissent pas dans les unes.
Rose Iradukunda : Karim a chiffré les heures.
Aline : tout le monde dit est interdit en revue.
Karim Bamba : Joël écoute sa propre absence et la nomme.
Félicie Ndayishimiye : Un chiffre, une trace : Lila a cité Marc, Rose, Karim ; coupé un anonymat trop commode ; gardé un désaccord.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le travail de la cour ait des voix, pas une rumeur
Yvette : Patrick veut la friction, pas la paix fausse.
Mado : Marc Nkurunziza entend, dans « tout le monde dit », ceci qui n'est pas dit : tout le monde dit est déjà une prise de pouvoir sur les sources
Sami : Autrement dit, la revue attribue : Cahier des racines, Radio Figuier, affiche de l'atelier
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : trois extraits, trois attributions, un point de friction nommé
Marc : une revue de presse est un art d'attribution.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le Cahier des racines du mardi d'un côté, l'antenne de Radio Figuier du mercredi de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Pas de tout le monde dit'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une revue trop lisse pour être honnête est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une revue trop lisse pour être honnête n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Pas de tout le monde dit'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Lila Sow sur « Pas de tout le monde dit » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Lila Sow sur « Pas de tout le monde dit » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Pas de tout le monde dit'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser selon tel cahier / tel micro ; organisation du travail au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — selon tel cahier / tel micro ; organisation du travail
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on cite, une revue trop lisse pour être honnête n'est pas un détail.
Lila Sow concède que raccourcir aide l'oreille, pour autant que l'on garde selon et d'après.
Autrement dit, la revue attribue : Cahier des racines, Radio Figuier, affiche de l'atelier
Il ressort que trois extraits, trois attributions, un point de friction nommé
Piège : fusionner les sources au lieu des attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme revue, ici, n'est pas un slogan : tour de sources attribuées.
Il ressort que les deux manques se parlent.
Aline : tout le monde dit est interdit en revue.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au attribution pour de vrai genre, et Marc Nkurunziza demande un registre plus net.
Correction : On va au attribution vraiment, et Marc Nkurunziza demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Pas de tout le monde dit'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Témoigner d'un entretien et rédiger une accroche d'offre sans mensonge. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Accroche et entretien
Lila Sow : Radio Figuier. On parle trop vite de l'entretien de Joël à l'atelier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on habille le poste d'un mot trop grand, une accroche qui n'a pas de mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Joël Mugisha concède qu'une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Aline Uwase : Ce que l'on nomme accroche, ici, n'est pas un slogan : première phrase d'une offre, à tenir juste.
Patrick Habimana : Joël a dit qu'il poserait le casque dès l'aube si le relais existait.
Hawa Diallo : Rose a demandé si l'on nommait les mains dans l'accroche.
Joël Mugisha : Karim a prétendu que les heures étaient déjà trop longues, puis a corrigé.
Rose Iradukunda : Lila a exigé que l'on coupe super profil.
Aline : le DI au passé décale les temps, il n'embellit pas.
Karim Bamba : Dieudonné a écouté derrière la porte, puis s'est montré.
Félicie Ndayishimiye : Un chiffre, une trace : Joël a parlé de relais ; Karim a parlé de chiffres ; l'accroche trop grande a été raturée deux fois.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de recruter sans mentir sur la peine ni sur la joie
Yvette : un entretien n'est pas une chasse.
Mado : Karim Bamba entend, dans « super profil », ceci qui n'est pas dit : super profil flatte pour ne pas dire ce que le poste exige vraiment
Sami : Autrement dit, Joël a dit qu'il poserait le casque ; l'accroche n'a pas à le transformer en héros
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une accroche juste, puis un témoignage d'entretien au discours indirect
Marc : témoigner, c'est garder le fer dans la phrase.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'accroche raturée d'un côté, le témoignage de Joël de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Accroche et entretien'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une accroche qui n'a pas de mains est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une accroche qui n'a pas de mains n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Accroche et entretien'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Témoigner d'un entretien et rédiger une accroche d'offre sans mensonge. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Pas de super profil », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Pas de super profil
On parle trop vite de l'entretien de Joël à l'atelier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on habille le poste d'un mot trop grand, une accroche qui n'a pas de mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède qu'une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Ce que l'on nomme accroche, ici, n'est pas un slogan : première phrase d'une offre, à tenir juste.
Joël a dit qu'il poserait le casque dès l'aube si le relais existait.
Rose a demandé si l'on nommait les mains dans l'accroche.
Karim a prétendu que les heures étaient déjà trop longues, puis a corrigé.
Lila a exigé que l'on coupe super profil.
Aline : le DI au passé décale les temps, il n'embellit pas.
Dieudonné a écouté derrière la porte, puis s'est montré.
Un chiffre, une trace : Joël a parlé de relais ; Karim a parlé de chiffres ; l'accroche trop grande a été raturée deux fois.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de recruter sans mentir sur la peine ni sur la joie
Yvette : un entretien n'est pas une chasse.
Karim Bamba entend, dans « super profil », ceci qui n'est pas dit : super profil flatte pour ne pas dire ce que le poste exige vraiment
Autrement dit, Joël a dit qu'il poserait le casque ; l'accroche n'a pas à le transformer en héros
La proposition qui reste debout est celle-ci : une accroche juste, puis un témoignage d'entretien au discours indirect
Marc : témoigner, c'est garder le fer dans la phrase.
Nous clôturons sans fusionner les voix : l'accroche raturée d'un côté, le témoignage de Joël de l'autre, et le point où elles refusent de se ressembler.
Signé : Joël Mugisha, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Accroche et entretien'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : discours indirect ; accroche d'offre ; témoignage.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on habille le poste d'un mot trop grand, une accroche qui n'a pas de mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède qu'une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Ce que l'on nomme accroche, ici, n'est pas un slogan : première phrase d'une offre, à tenir juste.
Encore que l'on rature, une accroche qui n'a pas de mains n'est pas un détail.
Joël Mugisha concède qu'une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Autrement dit, Joël a dit qu'il poserait le casque ; l'accroche n'a pas à le transformer en héros
Il ressort qu'une accroche juste, puis un témoignage d'entretien au discours indirect
Rose a demandé si l'on nommait les mains dans l'accroche.
Aline : le DI au passé décale les temps, il n'embellit pas.
La proposition qui reste debout est celle-ci : une accroche juste, puis un témoignage d'entretien au discours indirect
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'accroche raturée d'un côté, le témoignage de Joël de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Accroche et entretien'
  AND l.competency = 'PO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "Joël Mugisha transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Joël Mugisha concède qu'une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Accroche et entretien'
  AND l.competency = 'PO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Témoigner d'un entretien et rédiger une accroche d'offre sans mensonge. Point : discours indirect ; accroche d'offre ; témoignage.

Consigne
Imitez le texte de Joël Mugisha.

Support — Joël Mugisha — Pas de super profil
Joël Mugisha — Pas de super profil
On parle trop vite de l'entretien de Joël à l'atelier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on habille le poste d'un mot trop grand, une accroche qui n'a pas de mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède qu'une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Ce que l'on nomme accroche, ici, n'est pas un slogan : première phrase d'une offre, à tenir juste.
Joël a dit qu'il poserait le casque dès l'aube si le relais existait.
Aline : le DI au passé décale les temps, il n'embellit pas.
Dieudonné a écouté derrière la porte, puis s'est montré.
Yvette : un entretien n'est pas une chasse.
La proposition qui reste debout est celle-ci : une accroche juste, puis un témoignage d'entretien au discours indirect
Marc : témoigner, c'est garder le fer dans la phrase.
Nous clôturons sans fusionner les voix : l'accroche raturée d'un côté, le témoignage de Joël de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on rature, une accroche qui n'a pas de mains n'est pas un détail.
Joël Mugisha concède qu'une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
Joël a dit qu'il poserait le casque ; l'accroche n'a pas à le transformer en héros
Joël Mugisha, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Accroche et entretien'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Joël Mugisha sur « Accroche et entretien » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Joël Mugisha sur « Accroche et entretien » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Accroche et entretien'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Maîtriser discours indirect ; accroche d'offre ; témoignage au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — discours indirect ; accroche d'offre ; témoignage
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on rature, une accroche qui n'a pas de mains n'est pas un détail.
Joël Mugisha concède qu'une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Autrement dit, Joël a dit qu'il poserait le casque ; l'accroche n'a pas à le transformer en héros
Il ressort qu'une accroche juste, puis un témoignage d'entretien au discours indirect
Piège : garder le présent du DD dans un DI au passé
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme accroche, ici, n'est pas un slogan : première phrase d'une offre, à tenir juste.
Rose a demandé si l'on nommait les mains dans l'accroche.
Aline : le DI au passé décale les temps, il n'embellit pas.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au poste pour de vrai genre, et Karim Bamba demande un registre plus net.
Correction : On va au poste vraiment, et Karim Bamba demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Accroche et entretien'
  AND l.competency = 'EL';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Comprendre un conflit de travail et le rapporter sans le romancer. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Conflit à l'atelier
Lila Sow : Radio Figuier. On parle trop vite de la crise de l'atelier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on désigne un coupable trop vite, une table trop froide après la voix trop haute n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation.
Aline Uwase : Ce que l'on nomme conflit, ici, n'est pas un slogan : désaccord de travail, à rapporter.
Patrick Habimana : On aurait dit que la table allait se fendre ; elle n'a fait que refroidir.
Hawa Diallo : Rose a dit qu'elle garderait les propos, pas les insultes.
Joël Mugisha : Joël a demandé si l'on parlait encore du relais.
Rose Iradukunda : Karim a chiffré, trop tôt.
Aline : le style indirect libre peut montrer la fièvre, il ne doit pas l'inventer.
Karim Bamba : Lila n'enregistrera pas la crise comme un spectacle.
Félicie Ndayishimiye : Un chiffre, une trace : Deux voix trop hautes ; une heure de silence ; un relais promis, puis oublié, puis réécrit.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la crise serve à réparer le travail, pas à créer un héros et un traître
Yvette : Patrick propose une heure calme avant de décider.
Mado : Dieudonné Hakizimana entend, dans « c'est la faute des autres », ceci qui n'est pas dit : c'est la faute des autres évite de compter les heures mal partagées
Sami : Autrement dit, rapporter un discours de crise, c'est garder les propos, signaler le ton, refuser le roman
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un compte-rendu — ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider
Marc : une crise du travail se répare au relais, pas au roman.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le compte-rendu de Rose d'un côté, les notes de Karim de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Conflit à l''atelier'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une table trop froide après la voix trop haute est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une table trop froide après la voix trop haute n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Conflit à l''atelier'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comprendre un conflit de travail et le rapporter sans le romancer. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Pas de roman de crise », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Pas de roman de crise
On parle trop vite de la crise de l'atelier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on désigne un coupable trop vite, une table trop froide après la voix trop haute n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation.
Ce que l'on nomme conflit, ici, n'est pas un slogan : désaccord de travail, à rapporter.
On aurait dit que la table allait se fendre ; elle n'a fait que refroidir.
Rose a dit qu'elle garderait les propos, pas les insultes.
Joël a demandé si l'on parlait encore du relais.
Karim a chiffré, trop tôt.
Aline : le style indirect libre peut montrer la fièvre, il ne doit pas l'inventer.
Lila n'enregistrera pas la crise comme un spectacle.
Un chiffre, une trace : Deux voix trop hautes ; une heure de silence ; un relais promis, puis oublié, puis réécrit.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la crise serve à réparer le travail, pas à créer un héros et un traître
Patrick propose une heure calme avant de décider.
Dieudonné Hakizimana entend, dans « c'est la faute des autres », ceci qui n'est pas dit : c'est la faute des autres évite de compter les heures mal partagées
Autrement dit, rapporter un discours de crise, c'est garder les propos, signaler le ton, refuser le roman
La proposition qui reste debout est celle-ci : un compte-rendu — ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider
Marc : une crise du travail se répare au relais, pas au roman.
Nous clôturons sans fusionner les voix : le compte-rendu de Rose d'un côté, les notes de Karim de l'autre, et le point où elles refusent de se ressembler.
Signé : Rose Iradukunda, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Conflit à l''atelier'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : rapporter une crise ; style indirect libre ; on aurait dit.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on désigne un coupable trop vite, une table trop froide après la voix trop haute n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation.
Ce que l'on nomme conflit, ici, n'est pas un slogan : désaccord de travail, à rapporter.
Encore que l'on rapporte, une table trop froide après la voix trop haute n'est pas un détail.
Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation.
Autrement dit, rapporter un discours de crise, c'est garder les propos, signaler le ton, refuser le roman
Il ressort qu'un compte-rendu : ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider
Rose a dit qu'elle garderait les propos, pas les insultes.
Aline : le style indirect libre peut montrer la fièvre, il ne doit pas l'inventer.
La proposition qui reste debout est celle-ci : un compte-rendu — ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le compte-rendu de Rose d'un côté, les notes de Karim de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Conflit à l''atelier'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Comprendre un conflit de travail et le rapporter sans le romancer. Point : rapporter une crise ; style indirect libre ; on aurait dit.

Consigne
Imitez le texte de Rose Iradukunda.

Support — Rose Iradukunda — Pas de roman de crise
Rose Iradukunda — Pas de roman de crise
On parle trop vite de la crise de l'atelier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on désigne un coupable trop vite, une table trop froide après la voix trop haute n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation.
Ce que l'on nomme conflit, ici, n'est pas un slogan : désaccord de travail, à rapporter.
On aurait dit que la table allait se fendre ; elle n'a fait que refroidir.
Aline : le style indirect libre peut montrer la fièvre, il ne doit pas l'inventer.
Lila n'enregistrera pas la crise comme un spectacle.
Patrick propose une heure calme avant de décider.
La proposition qui reste debout est celle-ci : un compte-rendu — ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider
Marc : une crise du travail se répare au relais, pas au roman.
Nous clôturons sans fusionner les voix : le compte-rendu de Rose d'un côté, les notes de Karim de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on rapporte, une table trop froide après la voix trop haute n'est pas un détail.
Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
rapporter un discours de crise, c'est garder les propos, signaler le ton, refuser le roman
Rose Iradukunda, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Conflit à l''atelier'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Rose Iradukunda sur « Conflit à l’atelier » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Rose Iradukunda sur « Conflit à l’atelier » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Conflit à l''atelier'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Présenter des départs et des ailleurs inventés, sans mirage. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Là-bas n'est pas une morale
Lila Sow : Radio Figuier. On parle trop vite des ailleurs trop brillants, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface le Seuil d'un revers de valise, une promesse d'heures plus douces jamais datée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent.
Aline Uwase : Ce que l'on nomme ailleurs, ici, n'est pas un slogan : lieu projeté, parfois un mirage.
Karim : encore que l'on promette des heures plus douces, le contrat n'était pas dans la lettre.
Hawa Diallo : Hawa est partie, revenue, sans devoir choisir un camp.
Joël Mugisha : Joël reste, et ce n'est pas un échec.
Rose Iradukunda : Aline refuse le mot eldorado collé comme une insulte.
Solange Mukamana : Rose a cousu pour un départ, puis pour un retour.
Karim Bamba : Lila recueillera les trois voix.
Félicie Ndayishimiye : Un chiffre, une trace : Trois lettres ; une valise trop légère ; zéro contrat lu jusqu'au bout dans le récit trop brillant.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de parler d'ailleurs sans faire du Seuil une honte
Yvette : là-bas c'est mieux n'est pas une analyse.
Mado : Hawa Diallo entend, dans « là-bas c'est mieux », ceci qui n'est pas dit : là-bas c'est mieux sert trop souvent à ne plus améliorer ici
Sami : Autrement dit, encore que l'ailleurs attire, le Seuil a des heures à réparer
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : recueillir trois témoignages — parti, resté, revenu, sans podium
Marc : intégrer des témoignages, c'est refuser le podium.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les lettres d'ailleurs inventées d'un côté, les voix du banc de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Là-bas n''est pas une morale'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une promesse d'heures plus douces jamais datée est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une promesse d'heures plus douces jamais datée n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Là-bas n''est pas une morale'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Présenter des départs et des ailleurs inventés, sans mirage. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Là-bas n'est pas une morale », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Là-bas n'est pas une morale
On parle trop vite des ailleurs trop brillants, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface le Seuil d'un revers de valise, une promesse d'heures plus douces jamais datée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent.
Ce que l'on nomme ailleurs, ici, n'est pas un slogan : lieu projeté, parfois un mirage.
Karim : encore que l'on promette des heures plus douces, le contrat n'était pas dans la lettre.
Hawa est partie, revenue, sans devoir choisir un camp.
Joël reste, et ce n'est pas un échec.
Aline refuse le mot eldorado collé comme une insulte.
Rose a cousu pour un départ, puis pour un retour.
Lila recueillera les trois voix.
Un chiffre, une trace : Trois lettres ; une valise trop légère ; zéro contrat lu jusqu'au bout dans le récit trop brillant.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de parler d'ailleurs sans faire du Seuil une honte
Yvette : là-bas c'est mieux n'est pas une analyse.
Hawa Diallo entend, dans « là-bas c'est mieux », ceci qui n'est pas dit : là-bas c'est mieux sert trop souvent à ne plus améliorer ici
Autrement dit, encore que l'ailleurs attire, le Seuil a des heures à réparer
La proposition qui reste debout est celle-ci : recueillir trois témoignages — parti, resté, revenu, sans podium
Marc : intégrer des témoignages, c'est refuser le podium.
Nous clôturons sans fusionner les voix : les lettres d'ailleurs inventées d'un côté, les voix du banc de l'autre, et le point où elles refusent de se ressembler.
Signé : Karim Bamba, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Là-bas n''est pas une morale'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : concession ; hypothèse ; habitudes professionnelles ailleurs.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on efface le Seuil d'un revers de valise, une promesse d'heures plus douces jamais datée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent.
Ce que l'on nomme ailleurs, ici, n'est pas un slogan : lieu projeté, parfois un mirage.
Encore que l'on parte, une promesse d'heures plus douces jamais datée n'est pas un détail.
Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent.
Autrement dit, encore que l'ailleurs attire, le Seuil a des heures à réparer
Il ressort que recueillir trois témoignages : parti, resté, revenu, sans podium
Hawa est partie, revenue, sans devoir choisir un camp.
Rose a cousu pour un départ, puis pour un retour.
La proposition qui reste debout est celle-ci : recueillir trois témoignages — parti, resté, revenu, sans podium
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les lettres d'ailleurs inventées d'un côté, les voix du banc de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Là-bas n''est pas une morale'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Présenter des départs et des ailleurs inventés, sans mirage. Point : concession ; hypothèse ; habitudes professionnelles ailleurs.

Consigne
Imitez le texte de Karim Bamba.

Support — Karim Bamba — Là-bas n'est pas une morale
Karim Bamba — Là-bas n'est pas une morale
On parle trop vite des ailleurs trop brillants, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface le Seuil d'un revers de valise, une promesse d'heures plus douces jamais datée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent.
Ce que l'on nomme ailleurs, ici, n'est pas un slogan : lieu projeté, parfois un mirage.
Karim : encore que l'on promette des heures plus douces, le contrat n'était pas dans la lettre.
Rose a cousu pour un départ, puis pour un retour.
Lila recueillera les trois voix.
Yvette : là-bas c'est mieux n'est pas une analyse.
La proposition qui reste debout est celle-ci : recueillir trois témoignages — parti, resté, revenu, sans podium
Marc : intégrer des témoignages, c'est refuser le podium.
Nous clôturons sans fusionner les voix : les lettres d'ailleurs inventées d'un côté, les voix du banc de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on parte, une promesse d'heures plus douces jamais datée n'est pas un détail.
Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
encore que l'ailleurs attire, le Seuil a des heures à réparer
Karim Bamba, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Là-bas n''est pas une morale'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Karim Bamba sur « Là-bas n’est pas une morale » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Karim Bamba sur « Là-bas n’est pas une morale » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Là-bas n''est pas une morale'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Intégrer des témoignages dans une analyse du travail au Seuil. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Témoignages croisés
Lila Sow : Radio Figuier. On parle trop vite des voix croisées de l'atelier et de la radio, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on lisse les citations jusqu'au consensus faux, une analyse sans aspérités n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent.
Aline Uwase : Ce que l'on nomme citation, ici, n'est pas un slogan : parole attribuée, non fondue.
Patrick Habimana : Rose a déclaré que les mains manquaient dans les unes.
Hawa Diallo : Joël a dit qu'il reviendrait si le relais tenait.
Joël Mugisha : Lila a demandé si l'on pouvait garder le doute à l'antenne.
Aline : intégrer n'est pas fondre.
Solange Mukamana : Karim ajoute un chiffre, pas un verdict.
Karim Bamba : Patrick relit les aspérités.
Félicie Ndayishimiye : Un chiffre, une trace : Marc a cité Rose, Joël, Lila ; gardé deux frictions ; refusé un tous d'accord final.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que l'analyse ressemble au travail réel, pas à une brochure
Yvette : Dieudonné signe le relais proposé.
Mado : Rose Iradukunda entend, dans « on a tous le même avis », ceci qui n'est pas dit : on a tous le même avis est le contraire d'une enquête
Sami : Autrement dit, intégrer, c'est citer, attribuer, commenter, pas fondre
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une analyse — trois citations, deux frictions, une proposition de relais
Marc : une analyse du travail au Seuil se juge à ce qu'elle n'a pas gommé.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les témoignages bruts d'un côté, l'analyse de Marc de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Témoignages croisés'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une analyse sans aspérités est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une analyse sans aspérités n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Témoignages croisés'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Intégrer des témoignages dans une analyse du travail au Seuil. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Garder ce qui gêne », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Garder ce qui gêne
On parle trop vite des voix croisées de l'atelier et de la radio, comme si le mot dispensait d'en examiner le prix.
Encore que l'on lisse les citations jusqu'au consensus faux, une analyse sans aspérités n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent.
Ce que l'on nomme citation, ici, n'est pas un slogan : parole attribuée, non fondue.
Rose a déclaré que les mains manquaient dans les unes.
Joël a dit qu'il reviendrait si le relais tenait.
Lila a demandé si l'on pouvait garder le doute à l'antenne.
Aline : intégrer n'est pas fondre.
Karim ajoute un chiffre, pas un verdict.
Patrick relit les aspérités.
Un chiffre, une trace : Marc a cité Rose, Joël, Lila ; gardé deux frictions ; refusé un tous d'accord final.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que l'analyse ressemble au travail réel, pas à une brochure
Dieudonné signe le relais proposé.
Rose Iradukunda entend, dans « on a tous le même avis », ceci qui n'est pas dit : on a tous le même avis est le contraire d'une enquête
Autrement dit, intégrer, c'est citer, attribuer, commenter, pas fondre
La proposition qui reste debout est celle-ci : une analyse — trois citations, deux frictions, une proposition de relais
Marc : une analyse du travail au Seuil se juge à ce qu'elle n'a pas gommé.
Nous clôturons sans fusionner les voix : les témoignages bruts d'un côté, l'analyse de Marc de l'autre, et le point où elles refusent de se ressembler.
Signé : Marc Nkurunziza, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Témoignages croisés'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : intégrer des citations ; il a déclaré que ; nuance.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on lisse les citations jusqu'au consensus faux, une analyse sans aspérités n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent.
Ce que l'on nomme citation, ici, n'est pas un slogan : parole attribuée, non fondue.
Encore que l'on cite, une analyse sans aspérités n'est pas un détail.
Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent.
Autrement dit, intégrer, c'est citer, attribuer, commenter, pas fondre
Il ressort qu'une analyse : trois citations, deux frictions, une proposition de relais
Joël a dit qu'il reviendrait si le relais tenait.
Karim ajoute un chiffre, pas un verdict.
La proposition qui reste debout est celle-ci : une analyse — trois citations, deux frictions, une proposition de relais
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les témoignages bruts d'un côté, l'analyse de Marc de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Témoignages croisés'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Intégrer des témoignages dans une analyse du travail au Seuil. Point : intégrer des citations ; il a déclaré que ; nuance.

Consigne
Imitez le texte de Marc Nkurunziza.

Support — Marc Nkurunziza — Garder ce qui gêne
Marc Nkurunziza — Garder ce qui gêne
On parle trop vite des voix croisées de l'atelier et de la radio, comme si le mot dispensait d'en examiner le prix.
Encore que l'on lisse les citations jusqu'au consensus faux, une analyse sans aspérités n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent.
Ce que l'on nomme citation, ici, n'est pas un slogan : parole attribuée, non fondue.
Rose a déclaré que les mains manquaient dans les unes.
Karim ajoute un chiffre, pas un verdict.
Patrick relit les aspérités.
Dieudonné signe le relais proposé.
La proposition qui reste debout est celle-ci : une analyse — trois citations, deux frictions, une proposition de relais
Marc : une analyse du travail au Seuil se juge à ce qu'elle n'a pas gommé.
Nous clôturons sans fusionner les voix : les témoignages bruts d'un côté, l'analyse de Marc de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on cite, une analyse sans aspérités n'est pas un détail.
Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
intégrer, c'est citer, attribuer, commenter, pas fondre
Marc Nkurunziza, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Témoignages croisés'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos de Marc Nkurunziza sur « Témoignages croisés » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos de Marc Nkurunziza sur « Témoignages croisés » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Témoignages croisés'
  AND l.competency = 'PE'
  AND e.exercise_type = 'find_error'
  AND e.order_index = 6;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Comprendre un échange long et en extraire l'implicite. Conclure le module par une analyse : organisation, recrutement, crise, ailleurs. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Analyse du travail au Seuil
Lila Sow : Radio Figuier. On parle trop vite du travail au Seuil comme horizon commun, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on reporte le relais à une saison trop vague, une analyse sans calendrier n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier.
Aline Uwase : Ce que l'on nomme constat, ici, n'est pas un slogan : fait établi, distinct d'un slogan.
Aline : il convient que l'on date le relais, encore que tout ne se répare pas jeudi.
Hawa Diallo : Joël entend enfin son nom dans une motion.
Joël Mugisha : Rose exige que l'accroche reste juste.
Rose Iradukunda : Karim veut la revue dans un mois, pas un nuage.
Solange Mukamana : Lila ouvrira l'antenne pour la revue.
Karim Bamba : Patrick relie C1-6 aux heures de la colline.
Félicie Ndayishimiye : Un chiffre, une trace : Quatre constats écrits ; deux dates ; une revue promise sous le figuier dans un mois.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que C1-6 ne reste pas une suite de récits, mais une cour qui décide
Yvette : Dieudonné peut commencer le fer.
Mado : Joël Mugisha entend, dans « on verra plus tard », ceci qui n'est pas dit : on verra plus tard est la phrase préférée de ce qui n'a pas à porter les lanternes
Sami : Autrement dit, il s'agit de tenir ensemble les voix, les heures et la date
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un texte final — quatre constats, deux gestes datés, une revue dans un mois
Marc : une analyse qui n'agit pas n'était qu'un exercice.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les quatre séquences précédentes d'un côté, la motion d'Aline de l'autre, et le point où elles refusent de se ressembler.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Analyse du travail au Seuil'
  AND l.competency = 'CO';
UPDATE elearning_exercises e
SET content = $qj${
  "statement": "une analyse sans calendrier est présentée comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire qu'une analyse sans calendrier n'est pas un détail."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Analyse du travail au Seuil'
  AND l.competency = 'CO'
  AND e.exercise_type = 'true_false'
  AND e.order_index = 0;
UPDATE elearning_exercises e
SET content = $qj${
  "prompt": "Reformulez l'implicite de « on verra plus tard » et la concession d'Aline Uwase."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Analyse du travail au Seuil'
  AND l.competency = 'CO'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
UPDATE elearning_lessons l
SET content = $qa$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Conclure le module par une analyse : organisation, recrutement, crise, ailleurs. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Deux dates, pas plus tard », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Deux dates, pas plus tard
On parle trop vite du travail au Seuil comme horizon commun, comme si le mot dispensait d'en examiner le prix.
Encore que l'on reporte le relais à une saison trop vague, une analyse sans calendrier n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier.
Ce que l'on nomme constat, ici, n'est pas un slogan : fait établi, distinct d'un slogan.
Aline : il convient que l'on date le relais, encore que tout ne se répare pas jeudi.
Joël entend enfin son nom dans une motion.
Rose exige que l'accroche reste juste.
Karim veut la revue dans un mois, pas un nuage.
Lila ouvrira l'antenne pour la revue.
Patrick relie C1-6 aux heures de la colline.
Un chiffre, une trace : Quatre constats écrits ; deux dates ; une revue promise sous le figuier dans un mois.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que C1-6 ne reste pas une suite de récits, mais une cour qui décide
Dieudonné peut commencer le fer.
Joël Mugisha entend, dans « on verra plus tard », ceci qui n'est pas dit : on verra plus tard est la phrase préférée de ce qui n'a pas à porter les lanternes
Autrement dit, il s'agit de tenir ensemble les voix, les heures et la date
La proposition qui reste debout est celle-ci : un texte final — quatre constats, deux gestes datés, une revue dans un mois
Marc : une analyse qui n'agit pas n'était qu'un exercice.
Nous clôturons sans fusionner les voix : les quatre séquences précédentes d'un côté, la motion d'Aline de l'autre, et le point où elles refusent de se ressembler.
Signé : Aline Uwase, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Analyse du travail au Seuil'
  AND l.competency = 'CE';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : synthèse argumentée ; encore que ; il s'agit de.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on reporte le relais à une saison trop vague, une analyse sans calendrier n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier.
Ce que l'on nomme constat, ici, n'est pas un slogan : fait établi, distinct d'un slogan.
Encore que l'on date, une analyse sans calendrier n'est pas un détail.
Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier.
Autrement dit, il s'agit de tenir ensemble les voix, les heures et la date
Il ressort qu'un texte final : quatre constats, deux gestes datés, une revue dans un mois
Joël entend enfin son nom dans une motion.
Lila ouvrira l'antenne pour la revue.
La proposition qui reste debout est celle-ci : un texte final — quatre constats, deux gestes datés, une revue dans un mois
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les quatre séquences précédentes d'un côté, la motion d'Aline de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Analyse du travail au Seuil'
  AND l.competency = 'PO';
UPDATE elearning_lessons l
SET content = $qa$Objectif
Écrire un texte long et structuré. Conclure le module par une analyse : organisation, recrutement, crise, ailleurs. Point : synthèse argumentée ; encore que ; il s'agit de.

Consigne
Imitez le texte d'Aline Uwase.

Support — Aline Uwase — Deux dates, pas plus tard
Aline Uwase — Deux dates, pas plus tard
On parle trop vite du travail au Seuil comme horizon commun, comme si le mot dispensait d'en examiner le prix.
Encore que l'on reporte le relais à une saison trop vague, une analyse sans calendrier n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier.
Ce que l'on nomme constat, ici, n'est pas un slogan : fait établi, distinct d'un slogan.
Aline : il convient que l'on date le relais, encore que tout ne se répare pas jeudi.
Lila ouvrira l'antenne pour la revue.
Patrick relie C1-6 aux heures de la colline.
Dieudonné peut commencer le fer.
La proposition qui reste debout est celle-ci : un texte final — quatre constats, deux gestes datés, une revue dans un mois
Marc : une analyse qui n'agit pas n'était qu'un exercice.
Nous clôturons sans fusionner les voix : les quatre séquences précédentes d'un côté, la motion d'Aline de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on date, une analyse sans calendrier n'est pas un détail.
Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il s'agit de tenir ensemble les voix, les heures et la date
Aline Uwase, Rukiri-Nord
$qa$
FROM elearning_sequences s
JOIN elearning_modules m ON m.id = s.module_id
WHERE l.sequence_id = s.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Analyse du travail au Seuil'
  AND l.competency = 'PE';
UPDATE elearning_exercises e
SET content = $qj${
  "sentence_with_error": "Les propos d'Aline Uwase sur « Analyse du travail au Seuil » est nets, et Lila laisse le micro ouvert.",
  "correct_sentence": "Les propos d'Aline Uwase sur « Analyse du travail au Seuil » sont nets, et Lila laisse le micro ouvert.",
  "explanation": "Accord : les propos sont nets."
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Analyse du travail au Seuil'
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
  AND m.title = 'C1 — Travailler au Seuil'
  AND s.title = 'Analyse du travail au Seuil'
  AND l.competency = 'PE'
  AND e.exercise_type = 'short_answer'
  AND e.order_index = 8;
