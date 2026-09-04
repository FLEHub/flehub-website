/*
  Seed eLearning MFK — C2 — Bonheurs et utopies

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-c2-m1/
  Module laissé en brouillon (published = false).
  Aucune table nouvelle. Idempotent. Éditable via « Gérer le contenu ».
  A1 / A2 / B1 / B2 inchangés.
*/

CREATE OR REPLACE FUNCTION pg_temp.mfk_upsert_lesson(
  p_sequence_id uuid,
  p_title text,
  p_competency text,
  p_content text,
  p_order integer
) RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  SELECT l.id INTO v_id
  FROM elearning_lessons l
  WHERE l.sequence_id = p_sequence_id
    AND l.competency = p_competency
  ORDER BY l.order_index
  LIMIT 1;

  IF v_id IS NULL THEN
    INSERT INTO elearning_lessons (
      sequence_id, title, competency, content_type, content, order_index
    )
    VALUES (
      p_sequence_id, p_title, p_competency, 'text', p_content, p_order
    )
    RETURNING id INTO v_id;
  ELSE
    UPDATE elearning_lessons
    SET
      title = p_title,
      content_type = 'text',
      content = p_content,
      order_index = p_order
    WHERE id = v_id;
  END IF;

  DELETE FROM elearning_exercises
  WHERE lesson_id = v_id
    AND order_index BETWEEN 0 AND 9;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION pg_temp.mfk_seed_exercise(
  p_lesson_id uuid,
  p_title text,
  p_type text,
  p_content jsonb,
  p_order integer
) RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO elearning_exercises (
    lesson_id, title, exercise_type, content, order_index
  )
  VALUES (
    p_lesson_id, p_title, p_type, p_content, p_order
  );
END;
$$;


DO $$
DECLARE
  v_teacher_id uuid;
  v_teacher_email text;
  v_module_id uuid;
  v_seq_id uuid;
  v_lesson_id uuid;
  v_module_title text := 'C2 — Bonheurs et utopies';
BEGIN
  SELECT t.id, p.email
    INTO v_teacher_id, v_teacher_email
  FROM teachers t
  JOIN profiles p ON p.id = t.profile_id
  WHERE lower(p.email) = 'murick50@gmail.com'
  LIMIT 1;

  IF v_teacher_id IS NULL THEN
    SELECT t.id, p.email
      INTO v_teacher_id, v_teacher_email
    FROM teachers t
    JOIN profiles p ON p.id = t.profile_id
    ORDER BY t.created_at ASC NULLS LAST
    LIMIT 1;
  END IF;

  IF v_teacher_id IS NULL THEN
    RAISE EXCEPTION
      'Seed C2 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed C2 : enseignant % (%) — %', v_teacher_email, v_teacher_id, v_module_title;

  SELECT m.id INTO v_module_id
  FROM elearning_modules m
  WHERE m.teacher_id = v_teacher_id
    AND m.title = v_module_title
  LIMIT 1;

  IF v_module_id IS NULL THEN
    INSERT INTO elearning_modules (
      teacher_id, title, description, cefr_level, published
    )
    VALUES (
      v_teacher_id,
      v_module_title,
      'Grande étape C2-1 : interpréter une scène inventée, prendre position sur un bonheur trop mesuré, argumenter une médiation animale au Seuil, décrire une utopie de rive, écrire une lettre, puis un ailleurs — Mado lit entre les répliques, Basile Habiyaremye amène un chien trop calme, Sami se lasse d''être heureux à l''heure dite, et Radio Figuier (Rukiri-Nord) refuse l''usine à sourires.',
      'C2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape C2-1 : interpréter une scène inventée, prendre position sur un bonheur trop mesuré, argumenter une médiation animale au Seuil, décrire une utopie de rive, écrire une lettre, puis un ailleurs — Mado lit entre les répliques, Basile Habiyaremye amène un chien trop calme, Sami se lasse d''être heureux à l''heure dite, et Radio Figuier (Rukiri-Nord) refuse l''usine à sourires.',
      cefr_level = 'C2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Scène sous le figuier =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Scène sous le figuier'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Scène sous le figuier', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Scène sous le figuier',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Analyser un extrait inventé et formuler un point de vue critique sans résumé plat. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Scène sous le figuier
Lila Sow : Radio Figuier. On parle trop vite de une scène trop calme à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on tienne lieu d'analyse, un adjectif trop large pour une scène trop retenue n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que l'émotion a sa place après le spectacle, pour autant que l'on dise d'abord ce que les silences ont fait.
Aline Uwase : Ce que l'on nomme sous-entendu, ici, n'est pas un slogan : sens non dit, à justifier.
Patrick Habimana : Mado : loin de bouleverser, la scène a figé, ce qui n'est pas rien.
Hawa Diallo : Fût-ce à voix basse, Léa a dit le contraire de son sourire.
Joël Mugisha : Sami a ri trop tard : on aurait dit une consigne.
Rose Iradukunda : Aline : l'ironie n'est pas un rire, c'est un écart.
Solange Mukamana : Patrick refuse le mot chef-d'œuvre.
Karim Bamba : Lila a trop vite conclu.
Félicie Ndayishimiye : Un chiffre, une trace : Trois silences de huit secondes ; un rire trop tardif ; zéro larme, malgré l'adjectif trop large.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de juger une scène, pas de se juger ému
Yvette : Rose a cousu dans le noir, mieux que le plateau.
Mado : Sami entend, dans « quelle émotion », ceci qui n'est pas dit : quelle émotion dispense souvent de voir que personne n'a osé bouger
Sami : Autrement dit, interpréter, c'est lire le non-jeu autant que le jeu
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un échange d'impressions : deux lectures, une ironie, zéro adjectif orphelin
Nina Kayitesi : Marc : un point de vue critique nomme le silence, pas seulement l'acteur.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'extrait joué par Léa et Marc d'un côté, l'émission trop rapide de Lila de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Il ne s'agirait que d'un détail, bien sûr : personne n'a bougé, et l'on appelle cela du recueillement.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un adjectif trop large pour une scène trop retenue est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un adjectif trop large pour une scène trop retenue n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Sami, que reste-t-il implicite dans « quelle émotion » ?",
  "options": [
    {
      "text": "Que Mado a trouvé la scène nulle",
      "correct": false
    },
    {
      "text": "Personne n'a osé bouger",
      "correct": true
    },
    {
      "text": "Que Sami a pleuré pour la radio",
      "correct": false
    },
    {
      "text": "Que Léa a oublié son texte",
      "correct": false
    }
  ],
  "explanation": "quelle émotion dispense souvent de voir que personne n'a osé bouger"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "sous-entendu",
      "right": "sens non dit, à justifier"
    },
    {
      "left": "réplique",
      "right": "parole de scène, parfois un piège"
    },
    {
      "left": "critique",
      "right": "point de vue argumenté, pas un adjectif"
    },
    {
      "left": "silence",
      "right": "matériau de la scène, pas un trou"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl ne s'agirait ___ d'un détail, à entendre certains. (ne … que)",
  "answer": "que"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Il",
    "ne",
    "s'agirait",
    "que",
    "d'un",
    "détail",
    "à",
    "entendre",
    "certains",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "sous-entendu",
  "hint": "sens non dit, à justifier"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tant est que le bonheur s'industrialise, il se vend déjà, et Mado sourit trop large.",
  "correct_sentence": "Si tant est que le bonheur s'industrialise, il se vendrait déjà, et Mado sourit trop large.",
  "explanation": "Si tant est que + hypothese : se vendrait (irréel / doute)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/extrait-theatre.svg",
      "word": "extrait theatre"
    },
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
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « quelle émotion » et la concession de Mado."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'extrait joué par Léa et Marc et l'émission trop rapide de Lila distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le silence a joué aussi',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Analyser un extrait inventé et formuler un point de vue critique sans résumé plat. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le silence a joué aussi », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le silence a joué aussi
On parle trop vite de une scène trop calme à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
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
La proposition qui reste debout est celle-ci : un échange d'impressions : deux lectures, une ironie, zéro adjectif orphelin
Marc : un point de vue critique nomme le silence, pas seulement l'acteur.
Nous clôturons sans fusionner les voix : l'extrait joué par Léa et Marc d'un côté, l'émission trop rapide de Lila de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'extrait joué par Léa et Marc et l'émission trop rapide de Lila en une seule affiche.",
  "correct": true,
  "explanation": "La clôture garde deux voix et le point où elles ne se ressemblent pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il retenir du fait ou du chiffre avancé ?",
  "options": [
    {
      "text": "Rien n'est chiffré, tout est slogan",
      "correct": false
    },
    {
      "text": "Trois silences, un rire trop tardif, zéro larme",
      "correct": true
    },
    {
      "text": "Le chiffre annule la concession",
      "correct": false
    },
    {
      "text": "Le micro interdit les traces",
      "correct": false
    }
  ],
  "explanation": "Trois silences de huit secondes ; un rire trop tardif ; zéro larme, malgré l'adjectif trop large."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "sous-entendu",
      "right": "sens non dit, à justifier"
    },
    {
      "left": "réplique",
      "right": "parole de scène, parfois un piège"
    },
    {
      "left": "critique",
      "right": "point de vue argumenté, pas un adjectif"
    },
    {
      "left": "silence",
      "right": "matériau de la scène, pas un trou"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLoin de ___ la cour, le sourire la fatigue. (rassurer)",
  "answer": "rassurer"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Loin",
    "de",
    "rassurer",
    "la",
    "cour",
    "le",
    "sourire",
    "la",
    "fatigue",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "réplique",
  "hint": "parole de scène, parfois un piège"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La sous-entendu de trop vite n'aide personne, et Sami reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Sami reprend le fil.",
  "explanation": "Éviter une construction calquée ; préférer un nom d'action juste (précipitation)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
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
      "image_path": "/elearning/mfk-c2-m1/routinite.svg",
      "word": "routinite"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le silence a joué aussi » : thèse, concession, implicite, proposition (quinze lignes)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Scène sous le figuier : dire sans slogan',
    'PO',
    $c$Objectif
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
La proposition qui reste debout est celle-ci : un échange d'impressions : deux lectures, une ironie, zéro adjectif orphelin
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'extrait joué par Léa et Marc d'un côté, l'émission trop rapide de Lila de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Mado concède que l'émotion a sa place après le spectacle, pour autant que l'on dise d'abord ce que les silences ont fait."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Mado, et à quelle condition ?",
  "options": [
    {
      "text": "Mado n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "l'émotion a sa place après le spectacle — à condition que l'on dise d'abord ce que les silences ont fait",
      "correct": true
    },
    {
      "text": "Mado abandonne il s'agit de juger une scène, pas de se juger ému",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on dise d'abord ce que les silences ont fait"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "sous-entendu",
      "right": "sens non dit, à justifier"
    },
    {
      "left": "réplique",
      "right": "parole de scène, parfois un piège"
    },
    {
      "left": "critique",
      "right": "point de vue argumenté, pas un adjectif"
    },
    {
      "left": "silence",
      "right": "matériau de la scène, pas un trou"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nFût-ce à voix basse, Mado ___ le contraire de ce qu'on affiche. (dire)",
  "answer": "dit"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Fût-ce",
    "à",
    "voix",
    "basse",
    "Mado",
    "dit",
    "le",
    "contraire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "critique",
  "hint": "point de vue argumenté, pas un adjectif"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Mado écoute encore, et il fautons interpréter avant de crier.",
  "correct_sentence": "Mado écoute encore, et il faut interpréter avant de crier.",
  "explanation": "Toujours il faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
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
      "image_path": "/elearning/mfk-c2-m1/routinite.svg",
      "word": "routinite"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/bonheur-usine.svg",
      "word": "bonheur usine"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur interprétation théâtrale ; sous-entendu ; point de vue critique, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'extrait joué par Léa et Marc et l'émission trop rapide de Lila distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Mado',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Analyser un extrait inventé et formuler un point de vue critique sans résumé plat. Point : interprétation théâtrale ; sous-entendu ; point de vue critique.

Consigne
Imitez le texte de Mado.

Support — Mado — Le silence a joué aussi
Mado — Le silence a joué aussi
On parle trop vite de une scène trop calme à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu d'analyse, un adjectif trop large pour une scène trop retenue n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que l'émotion a sa place après le spectacle, pour autant que l'on dise d'abord ce que les silences ont fait.
Ce que l'on nomme sous-entendu, ici, n'est pas un slogan : sens non dit, à justifier.
Mado : loin de bouleverser, la scène a figé, ce qui n'est pas rien.
Patrick refuse le mot chef-d'œuvre.
Lila a trop vite conclu.
Rose a cousu dans le noir, mieux que le plateau.
La proposition qui reste debout est celle-ci : un échange d'impressions : deux lectures, une ironie, zéro adjectif orphelin
Marc : un point de vue critique nomme le silence, pas seulement l'acteur.
Nous clôturons sans fusionner les voix : l'extrait joué par Léa et Marc d'un côté, l'émission trop rapide de Lila de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on interprète, un adjectif trop large pour une scène trop retenue n'est pas un détail.
Mado concède que l'émotion a sa place après le spectacle, pour autant que l'on dise d'abord ce que les silences ont fait.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
interpréter, c'est lire le non-jeu autant que le jeu
Mado, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un échange d'impressions : deux lectures, une ironie, zéro adjectif orphelin",
  "correct": true,
  "explanation": "un échange d'impressions : deux lectures, une ironie, zéro adjectif orphelin"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle proposition reste debout à la fin ?",
  "options": [
    {
      "text": "Fusionner les deux documents en une affiche",
      "correct": false
    },
    {
      "text": "un échange d'impressions : deux lectures, une ironie, zéro adjectif orphelin",
      "correct": true
    },
    {
      "text": "Interdire toute nominalisation",
      "correct": false
    },
    {
      "text": "Couper le micro de Lila",
      "correct": false
    }
  ],
  "explanation": "un échange d'impressions : deux lectures, une ironie, zéro adjectif orphelin"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "sous-entendu",
      "right": "sens non dit, à justifier"
    },
    {
      "left": "réplique",
      "right": "parole de scène, parfois un piège"
    },
    {
      "left": "critique",
      "right": "point de vue argumenté, pas un adjectif"
    },
    {
      "left": "silence",
      "right": "matériau de la scène, pas un trou"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi tant est que le bonheur s'___, il se vendrait déjà sous le figuier. (industrialiser)",
  "answer": "industrialise"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Si",
    "tant",
    "est",
    "que",
    "le",
    "bonheur",
    "s'industrialise",
    "il",
    "se",
    "vendrait",
    "déjà",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "silence",
  "hint": "matériau de la scène, pas un trou"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Mado est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Mado sont clairs, et Lila garde le micro ouvert.",
  "explanation": "Accord : les arguments sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/scene-ombres.svg",
      "word": "scene ombres"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/routinite.svg",
      "word": "routinite"
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
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Mado : vingt lignes, deux voix, une concession, une proposition."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — interprétation théâtrale ; sous-entendu ; point de vue critique',
    'EL',
    $c$Objectif
Maîtriser interprétation théâtrale ; sous-entendu ; point de vue critique au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — interprétation théâtrale ; sous-entendu ; point de vue critique
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on interprète, un adjectif trop large pour une scène trop retenue n'est pas un détail.
Mado concède que l'émotion a sa place après le spectacle, pour autant que l'on dise d'abord ce que les silences ont fait.
Autrement dit, interpréter, c'est lire le non-jeu autant que le jeu
Il ressort qu'un échange d'impressions : deux lectures, une ironie, zéro adjectif orphelin
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme sous-entendu, ici, n'est pas un slogan : sens non dit, à justifier.
Fût-ce à voix basse, Léa a dit le contraire de son sourire.
Patrick refuse le mot chef-d'œuvre.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au critique pour de vrai genre, et Sami demande un registre plus net.
Correction : On va au critique vraiment, et Sami demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'ironie peut dire le contraire de ce qu'elle affirme.",
  "correct": true,
  "explanation": "Antiphrase possible."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Il ne s'agirait que d'un détail » est souvent…",
  "options": [
    {
      "text": "une preuve que c'est un détail",
      "correct": false
    },
    {
      "text": "un sous-entendu, parfois ironique",
      "correct": true
    },
    {
      "text": "un passé simple",
      "correct": false
    },
    {
      "text": "un ordre",
      "correct": false
    }
  ],
  "explanation": "Understatement / ironie."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "sous-entendu",
      "right": "sens non dit, à justifier"
    },
    {
      "left": "réplique",
      "right": "parole de scène, parfois un piège"
    },
    {
      "left": "critique",
      "right": "point de vue argumenté, pas un adjectif"
    },
    {
      "left": "silence",
      "right": "matériau de la scène, pas un trou"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'___ n'est pas un rire : c'est un écart entre le dit et le visé. (ironie)",
  "answer": "ironie"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "L'ironie",
    "n'est",
    "pas",
    "un",
    "rire",
    "c'est",
    "un",
    "écart",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "collocation",
  "hint": "Précision du discours, sans nommer le mot-cible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On va au critique pour de vrai genre, et Sami demande un registre plus net.",
  "correct_sentence": "On va au critique vraiment, et Sami demande un registre plus net.",
  "explanation": "Registre : éviter le marqueur trop oral « genre » dans un écrit soutenu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/routinite.svg",
      "word": "routinite"
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
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « interprétation théâtrale ; sous-entendu ; point de vue critique » et deux pièges commentés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre phrases justes au registre demandé."
}$j$::jsonb,
    9
  );

  -- ===== Bonheur en série =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Bonheur en série'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Bonheur en série', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Bonheur en série',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Prendre position sur un bonheur trop mesuré, trop vendu. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Bonheur en série
Lila Sow : Radio Figuier. On parle trop vite de le bonheur à l'heure dite sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on usine un sourire à dix-huit heures, une joie qui ressemble à un planning n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Sami concède que un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
Aline Uwase : Ce que l'on nomme bonheur, ici, n'est pas un slogan : sentiment, pas une consigne.
Patrick Habimana : Sami : il ne s'agirait que d'un détail, la fatigue, à entendre les animateurs trop nets.
Hawa Diallo : Loin de rassurer, le sourire de dix-huit heures lasse.
Joël Mugisha : Mado écrit la suite d'un extrait où le personnage rayonne trop pour être cru.
Rose Iradukunda : Aline : l'antiphrase se signale par un trop.
Solange Mukamana : Félicie pose le bol sans « savoure ! ».
Karim Bamba : Lila n'ouvrira pas une émission de bonheur.
Félicie Ndayishimiye : Un chiffre, une trace : Sami a compté sept soirs « heureux » ; trois bâillements cachés ; zéro droit déclaré à la fatigue.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de pouvoir être las sans être coupable
Yvette : Yvette a le droit d'être lasse.
Mado : Mado entend, dans « soyez heureux », ceci qui n'est pas dit : soyez heureux arrive souvent quand on n'a plus le droit d'être las
Sami : Autrement dit, si tant est que le bonheur s'industrialise, il se vendrait déjà au Marché des Lampions
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une tribune : contre la joie obligatoire, pour les soirs sans score
Nina Kayitesi : Marc : prendre position, c'est refuser l'usine à joie.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'interview trop lisse d'un animateur inventé d'un côté, l'extrait de roman de Mado de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : On nous dit que tout va bien, ce qui, en soi, devrait rassurer — et n'y parvient pas.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une joie qui ressemble à un planning est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une joie qui ressemble à un planning n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Mado, que reste-t-il implicite dans « soyez heureux » ?",
  "options": [
    {
      "text": "Que Sami interdit les soirs",
      "correct": false
    },
    {
      "text": "Plus le droit d'être las",
      "correct": true
    },
    {
      "text": "Que Mado vend des sourires",
      "correct": false
    },
    {
      "text": "Que le figuier impose dix-huit heures",
      "correct": false
    }
  ],
  "explanation": "soyez heureux arrive souvent quand on n'a plus le droit d'être las"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "bonheur",
      "right": "sentiment, pas une consigne"
    },
    {
      "left": "rituel",
      "right": "geste répété, parfois une cage"
    },
    {
      "left": "fatigue",
      "right": "droit, trop souvent une honte"
    },
    {
      "left": "tribune",
      "right": "texte de position, ironique s'il le faut"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl ne s'agirait ___ d'un détail, à entendre certains. (ne … que)",
  "answer": "que"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Il",
    "ne",
    "s'agirait",
    "que",
    "d'un",
    "détail",
    "à",
    "entendre",
    "certains",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "bonheur",
  "hint": "sentiment, pas une consigne"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tant est que le bonheur s'industrialise, il se vend déjà, et Sami sourit trop large.",
  "correct_sentence": "Si tant est que le bonheur s'industrialise, il se vendrait déjà, et Sami sourit trop large.",
  "explanation": "Si tant est que + hypothese : se vendrait (irréel / doute)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
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
    },
    {
      "image_path": "/elearning/mfk-c2-m1/mediation-animale.svg",
      "word": "mediation animale"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « soyez heureux » et la concession de Sami."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'interview trop lisse d'un animateur inventé et l'extrait de roman de Mado distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — La joie n''est pas un planning',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Prendre position sur un bonheur trop mesuré, trop vendu. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « La joie n'est pas un planning », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La joie n'est pas un planning
On parle trop vite de le bonheur à l'heure dite sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on usine un sourire à dix-huit heures, une joie qui ressemble à un planning n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
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
La proposition qui reste debout est celle-ci : une tribune : contre la joie obligatoire, pour les soirs sans score
Marc : prendre position, c'est refuser l'usine à joie.
Nous clôturons sans fusionner les voix : l'interview trop lisse d'un animateur inventé d'un côté, l'extrait de roman de Mado de l'autre, et le point où elles refusent de se ressembler.
Signé : Sami, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'interview trop lisse d'un animateur inventé et l'extrait de roman de Mado en une seule affiche.",
  "correct": true,
  "explanation": "La clôture garde deux voix et le point où elles ne se ressemblent pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il retenir du fait ou du chiffre avancé ?",
  "options": [
    {
      "text": "Rien n'est chiffré, tout est slogan",
      "correct": false
    },
    {
      "text": "Sept soirs heureux, trois bâillements, zéro droit à la fatigue",
      "correct": true
    },
    {
      "text": "Le chiffre annule la concession",
      "correct": false
    },
    {
      "text": "Le micro interdit les traces",
      "correct": false
    }
  ],
  "explanation": "Sami a compté sept soirs « heureux » ; trois bâillements cachés ; zéro droit déclaré à la fatigue."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "bonheur",
      "right": "sentiment, pas une consigne"
    },
    {
      "left": "rituel",
      "right": "geste répété, parfois une cage"
    },
    {
      "left": "fatigue",
      "right": "droit, trop souvent une honte"
    },
    {
      "left": "tribune",
      "right": "texte de position, ironique s'il le faut"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLoin de ___ la cour, le sourire la fatigue. (rassurer)",
  "answer": "rassurer"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Loin",
    "de",
    "rassurer",
    "la",
    "cour",
    "le",
    "sourire",
    "la",
    "fatigue",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "rituel",
  "hint": "geste répété, parfois une cage"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La bonheur de trop vite n'aide personne, et Mado reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Mado reprend le fil.",
  "explanation": "Éviter une construction calquée ; préférer un nom d'action juste (précipitation)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/interview-doute.svg",
      "word": "interview doute"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/sourire-mesure.svg",
      "word": "sourire mesure"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/mediation-animale.svg",
      "word": "mediation animale"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/lettre-chien.svg",
      "word": "lettre chien"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « La joie n'est pas un planning » : thèse, concession, implicite, proposition (quinze lignes)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Bonheur en série : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : antiphrase ; industrialisation d'un sentiment ; prise de position.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on usine un sourire à dix-huit heures, une joie qui ressemble à un planning n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
Ce que l'on nomme bonheur, ici, n'est pas un slogan : sentiment, pas une consigne.
Encore que l'on refuse, une joie qui ressemble à un planning n'est pas un détail.
Sami concède que un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
Autrement dit, si tant est que le bonheur s'industrialise, il se vendrait déjà au Marché des Lampions
Il ressort qu'une tribune : contre la joie obligatoire, pour les soirs sans score
Loin de rassurer, le sourire de dix-huit heures lasse.
Félicie pose le bol sans « savoure ! ».
La proposition qui reste debout est celle-ci : une tribune : contre la joie obligatoire, pour les soirs sans score
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'interview trop lisse d'un animateur inventé d'un côté, l'extrait de roman de Mado de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Sami transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Sami concède que un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Sami, et à quelle condition ?",
  "options": [
    {
      "text": "Sami n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "un rituel de soirée peut apaiser — à condition que l'on n'y lise pas une obligation de rayonner",
      "correct": true
    },
    {
      "text": "Sami abandonne il s'agit de pouvoir être las sans être coupable",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y lise pas une obligation de rayonner"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "bonheur",
      "right": "sentiment, pas une consigne"
    },
    {
      "left": "rituel",
      "right": "geste répété, parfois une cage"
    },
    {
      "left": "fatigue",
      "right": "droit, trop souvent une honte"
    },
    {
      "left": "tribune",
      "right": "texte de position, ironique s'il le faut"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nFût-ce à voix basse, Mado ___ le contraire de ce qu'on affiche. (dire)",
  "answer": "dit"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Fût-ce",
    "à",
    "voix",
    "basse",
    "Mado",
    "dit",
    "le",
    "contraire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "fatigue",
  "hint": "droit, trop souvent une honte"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Sami écoute encore, et il fautons refuser avant de crier.",
  "correct_sentence": "Sami écoute encore, et il faut refuser avant de crier.",
  "explanation": "Toujours il faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/sourire-mesure.svg",
      "word": "sourire mesure"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/mediation-animale.svg",
      "word": "mediation animale"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/lettre-chien.svg",
      "word": "lettre chien"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/justice-douce.svg",
      "word": "justice douce"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur antiphrase ; industrialisation d'un sentiment ; prise de position, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'interview trop lisse d'un animateur inventé et l'extrait de roman de Mado distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Sami',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Prendre position sur un bonheur trop mesuré, trop vendu. Point : antiphrase ; industrialisation d'un sentiment ; prise de position.

Consigne
Imitez le texte de Sami.

Support — Sami — La joie n'est pas un planning
Sami — La joie n'est pas un planning
On parle trop vite de le bonheur à l'heure dite sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on usine un sourire à dix-huit heures, une joie qui ressemble à un planning n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
Ce que l'on nomme bonheur, ici, n'est pas un slogan : sentiment, pas une consigne.
Sami : il ne s'agirait que d'un détail, la fatigue, à entendre les animateurs trop nets.
Félicie pose le bol sans « savoure ! ».
Lila n'ouvrira pas une émission de bonheur.
Yvette a le droit d'être lasse.
La proposition qui reste debout est celle-ci : une tribune : contre la joie obligatoire, pour les soirs sans score
Marc : prendre position, c'est refuser l'usine à joie.
Nous clôturons sans fusionner les voix : l'interview trop lisse d'un animateur inventé d'un côté, l'extrait de roman de Mado de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on refuse, une joie qui ressemble à un planning n'est pas un détail.
Sami concède que un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
si tant est que le bonheur s'industrialise, il se vendrait déjà au Marché des Lampions
Sami, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : une tribune : contre la joie obligatoire, pour les soirs sans score",
  "correct": true,
  "explanation": "une tribune : contre la joie obligatoire, pour les soirs sans score"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle proposition reste debout à la fin ?",
  "options": [
    {
      "text": "Fusionner les deux documents en une affiche",
      "correct": false
    },
    {
      "text": "une tribune : contre la joie obligatoire, pour les soirs sans score",
      "correct": true
    },
    {
      "text": "Interdire toute nominalisation",
      "correct": false
    },
    {
      "text": "Couper le micro de Lila",
      "correct": false
    }
  ],
  "explanation": "une tribune : contre la joie obligatoire, pour les soirs sans score"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "bonheur",
      "right": "sentiment, pas une consigne"
    },
    {
      "left": "rituel",
      "right": "geste répété, parfois une cage"
    },
    {
      "left": "fatigue",
      "right": "droit, trop souvent une honte"
    },
    {
      "left": "tribune",
      "right": "texte de position, ironique s'il le faut"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi tant est que le bonheur s'___, il se vendrait déjà sous le figuier. (industrialiser)",
  "answer": "industrialise"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Si",
    "tant",
    "est",
    "que",
    "le",
    "bonheur",
    "s'industrialise",
    "il",
    "se",
    "vendrait",
    "déjà",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tribune",
  "hint": "texte de position, ironique s'il le faut"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Sami est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Sami sont clairs, et Lila garde le micro ouvert.",
  "explanation": "Accord : les arguments sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/mediation-animale.svg",
      "word": "mediation animale"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/lettre-chien.svg",
      "word": "lettre chien"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/justice-douce.svg",
      "word": "justice douce"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/banc-bete.svg",
      "word": "banc bete"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Sami : vingt lignes, deux voix, une concession, une proposition."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — antiphrase ; industrialisation d''un sentiment ; prise de position',
    'EL',
    $c$Objectif
Maîtriser antiphrase ; industrialisation d'un sentiment ; prise de position au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — antiphrase ; industrialisation d'un sentiment ; prise de position
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on refuse, une joie qui ressemble à un planning n'est pas un détail.
Sami concède que un rituel de soirée peut apaiser, pour autant que l'on n'y lise pas une obligation de rayonner.
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
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'ironie peut dire le contraire de ce qu'elle affirme.",
  "correct": true,
  "explanation": "Antiphrase possible."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Il ne s'agirait que d'un détail » est souvent…",
  "options": [
    {
      "text": "une preuve que c'est un détail",
      "correct": false
    },
    {
      "text": "un sous-entendu, parfois ironique",
      "correct": true
    },
    {
      "text": "un passé simple",
      "correct": false
    },
    {
      "text": "un ordre",
      "correct": false
    }
  ],
  "explanation": "Understatement / ironie."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "bonheur",
      "right": "sentiment, pas une consigne"
    },
    {
      "left": "rituel",
      "right": "geste répété, parfois une cage"
    },
    {
      "left": "fatigue",
      "right": "droit, trop souvent une honte"
    },
    {
      "left": "tribune",
      "right": "texte de position, ironique s'il le faut"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'___ n'est pas un rire : c'est un écart entre le dit et le visé. (ironie)",
  "answer": "ironie"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "L'ironie",
    "n'est",
    "pas",
    "un",
    "rire",
    "c'est",
    "un",
    "écart",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "collocation",
  "hint": "Précision du discours, sans nommer le mot-cible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On va au fatigue pour de vrai genre, et Mado demande un registre plus net.",
  "correct_sentence": "On va au fatigue vraiment, et Mado demande un registre plus net.",
  "explanation": "Registre : éviter le marqueur trop oral « genre » dans un écrit soutenu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/lettre-chien.svg",
      "word": "lettre chien"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/justice-douce.svg",
      "word": "justice douce"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/banc-bete.svg",
      "word": "banc bete"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/utopie-rive.svg",
      "word": "utopie rive"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « antiphrase ; industrialisation d'un sentiment ; prise de position » et deux pièges commentés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre phrases justes au registre demandé."
}$j$::jsonb,
    9
  );

  -- ===== La bête et le banc =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'La bête et le banc'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'La bête et le banc', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La bête et le banc',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Argumenter en faveur d'une médiation animale au Seuil, sans mièvrerie. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — La bête et le banc
Lila Sow : Radio Figuier. On parle trop vite de le chien de Basile Habiyaremye, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on chasse le chien au nom de la dignité trop abstraite, un banc trop raide pour qui tremble n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Basile Habiyaremye concède que un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
Aline Uwase : Ce que l'on nomme médiation, ici, n'est pas un slogan : présence encadrée, distincte d'un soin miracle.
Patrick Habimana : Basile : il convient que l'on autorise des heures, non un culte.
Hawa Diallo : Inès objecte le risque, et c'est une objection digne.
Joël Mugisha : Hawa a parlé au chien, puis à Inès, dans cet ordre.
Rose Iradukunda : Aline : encore que l'on discute le sérieux, le refus a été respecté.
Solange Mukamana : Dieudonné peut tenir la laisse.
Karim Bamba : Lila n'en fera pas une émission trop tendre.
Félicie Ndayishimiye : Un chiffre, une trace : Basile a tenu trois heures de présence ; deux personnes ont parlé ; une a refusé, et c'est noté.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une justice douce, pas d'une mascotte
Yvette : Patrick veut la responsabilité écrite.
Mado : Inès Mukama entend, dans « les bêtes n'ont pas leur place », ceci qui n'est pas dit : pas leur place veut souvent dire notre malaise d'abord
Sami : Autrement dit, fût-ce un chien trop calme, la médiation peut ouvrir une parole que le jargon ferme
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une lettre au Bureau des Escales : horaires, responsabilité, droit de dire non
Nina Kayitesi : Marc : une lettre de médiation n'est pas une fable.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : la lettre de Basile d'un côté, la réserve d'Inès de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : On objectera que ce n'est pas sérieux. C'est souvent ainsi que l'on nomme ce qui dérange un protocole trop sûr.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un banc trop raide pour qui tremble est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un banc trop raide pour qui tremble n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Inès Mukama, que reste-t-il implicite dans « les bêtes n'ont pas leur place » ?",
  "options": [
    {
      "text": "Que Basile promet une guérison",
      "correct": false
    },
    {
      "text": "Notre malaise d'abord",
      "correct": true
    },
    {
      "text": "Que Inès a chassé le chien",
      "correct": false
    },
    {
      "text": "Que le Bureau a déjà voté contre",
      "correct": false
    }
  ],
  "explanation": "pas leur place veut souvent dire notre malaise d'abord"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "médiation",
      "right": "présence encadrée, distincte d'un soin miracle"
    },
    {
      "left": "responsabilité",
      "right": "qui répond du chien, des heures, du non"
    },
    {
      "left": "refus",
      "right": "droit, à noter, pas à contourner"
    },
    {
      "left": "lettre",
      "right": "demande argumentée au Bureau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ avant d'accélérer. (autoriser, subj.)",
  "answer": "autorise"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Il",
    "convient",
    "que",
    "l'on",
    "autorise",
    "avant",
    "d'accélérer",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "médiation",
  "hint": "présence encadrée, distincte d'un soin miracle"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il convient que l'on autoriser trop tard, et Basile Habiyaremye refuse d'accélérer la pente.",
  "correct_sentence": "Il convient que l'on autorise trop tard, et Basile Habiyaremye refuse d'accélérer la pente.",
  "explanation": "Il convient que + autorise."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/justice-douce.svg",
      "word": "justice douce"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/banc-bete.svg",
      "word": "banc bete"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/utopie-rive.svg",
      "word": "utopie rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/contrainte-reve.svg",
      "word": "contrainte reve"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « les bêtes n'ont pas leur place » et la concession de Basile Habiyaremye."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez la lettre de Basile et la réserve d'Inès distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Un chien n''est pas une mascotte',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Argumenter en faveur d'une médiation animale au Seuil, sans mièvrerie. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Un chien n'est pas une mascotte », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Un chien n'est pas une mascotte
On parle trop vite de le chien de Basile Habiyaremye, comme si le mot dispensait d'en examiner le prix.
Encore que l'on chasse le chien au nom de la dignité trop abstraite, un banc trop raide pour qui tremble n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Basile Habiyaremye concède que un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
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
La proposition qui reste debout est celle-ci : une lettre au Bureau des Escales : horaires, responsabilité, droit de dire non
Marc : une lettre de médiation n'est pas une fable.
Nous clôturons sans fusionner les voix : la lettre de Basile d'un côté, la réserve d'Inès de l'autre, et le point où elles refusent de se ressembler.
Signé : Basile Habiyaremye, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner la lettre de Basile et la réserve d'Inès en une seule affiche.",
  "correct": true,
  "explanation": "La clôture garde deux voix et le point où elles ne se ressemblent pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il retenir du fait ou du chiffre avancé ?",
  "options": [
    {
      "text": "Rien n'est chiffré, tout est slogan",
      "correct": false
    },
    {
      "text": "Trois heures, deux paroles, un refus respecté",
      "correct": true
    },
    {
      "text": "Le chiffre annule la concession",
      "correct": false
    },
    {
      "text": "Le micro interdit les traces",
      "correct": false
    }
  ],
  "explanation": "Basile a tenu trois heures de présence ; deux personnes ont parlé ; une a refusé, et c'est noté."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "médiation",
      "right": "présence encadrée, distincte d'un soin miracle"
    },
    {
      "left": "responsabilité",
      "right": "qui répond du chien, des heures, du non"
    },
    {
      "left": "refus",
      "right": "droit, à noter, pas à contourner"
    },
    {
      "left": "lettre",
      "right": "demande argumentée au Bureau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl s'agit de ___ la pente, non de la nier. (nommer)",
  "answer": "nommer"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Il",
    "s'agit",
    "de",
    "nommer",
    "la",
    "pente",
    "non",
    "de",
    "la",
    "nier",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "responsabilité",
  "hint": "qui répond du chien, des heures, du non"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La médiation de trop vite n'aide personne, et Inès Mukama reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Inès Mukama reprend le fil.",
  "explanation": "Éviter une construction calquée ; préférer un nom d'action juste (précipitation)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/banc-bete.svg",
      "word": "banc bete"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/utopie-rive.svg",
      "word": "utopie rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/contrainte-reve.svg",
      "word": "contrainte reve"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/conte-philo.svg",
      "word": "conte philo"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Un chien n'est pas une mascotte » : thèse, concession, implicite, proposition (quinze lignes)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — La bête et le banc : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : argumentation juridique inventée ; encore que ; fût-ce.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on chasse le chien au nom de la dignité trop abstraite, un banc trop raide pour qui tremble n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Basile Habiyaremye concède que un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
Ce que l'on nomme médiation, ici, n'est pas un slogan : présence encadrée, distincte d'un soin miracle.
Encore que l'on autorise, un banc trop raide pour qui tremble n'est pas un détail.
Basile Habiyaremye concède que un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
Autrement dit, fût-ce un chien trop calme, la médiation peut ouvrir une parole que le jargon ferme
Il ressort qu'une lettre au Bureau des Escales : horaires, responsabilité, droit de dire non
Inès objecte le risque, et c'est une objection digne.
Dieudonné peut tenir la laisse.
La proposition qui reste debout est celle-ci : une lettre au Bureau des Escales : horaires, responsabilité, droit de dire non
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : la lettre de Basile d'un côté, la réserve d'Inès de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Basile Habiyaremye transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Basile Habiyaremye concède que un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Basile Habiyaremye, et à quelle condition ?",
  "options": [
    {
      "text": "Basile Habiyaremye n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "un animal n'est pas un soignant — à condition que l'on n'en fasse pas moins un médiateur possible, encadré",
      "correct": true
    },
    {
      "text": "Basile Habiyaremye abandonne il s'agit d'une justice douce, pas d'une mascotte",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'en fasse pas moins un médiateur possible, encadré"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "médiation",
      "right": "présence encadrée, distincte d'un soin miracle"
    },
    {
      "left": "responsabilité",
      "right": "qui répond du chien, des heures, du non"
    },
    {
      "left": "refus",
      "right": "droit, à noter, pas à contourner"
    },
    {
      "left": "lettre",
      "right": "demande argumentée au Bureau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous recommandons que la cour ___ un relais. (autoriser, subj.)",
  "answer": "autorise"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Nous",
    "recommandons",
    "que",
    "la",
    "cour",
    "autorise",
    "un",
    "relais",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "refus",
  "hint": "droit, à noter, pas à contourner"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Basile Habiyaremye écoute encore, et il fautons autoriser avant de crier.",
  "correct_sentence": "Basile Habiyaremye écoute encore, et il faut autoriser avant de crier.",
  "explanation": "Toujours il faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/utopie-rive.svg",
      "word": "utopie rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/contrainte-reve.svg",
      "word": "contrainte reve"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/conte-philo.svg",
      "word": "conte philo"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/carte-ailleurs.svg",
      "word": "carte ailleurs"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur argumentation juridique inventée ; encore que ; fût-ce, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez la lettre de Basile et la réserve d'Inès distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Basile Habiyaremye',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Argumenter en faveur d'une médiation animale au Seuil, sans mièvrerie. Point : argumentation juridique inventée ; encore que ; fût-ce.

Consigne
Imitez le texte de Basile Habiyaremye.

Support — Basile Habiyaremye — Un chien n'est pas une mascotte
Basile Habiyaremye — Un chien n'est pas une mascotte
On parle trop vite de le chien de Basile Habiyaremye, comme si le mot dispensait d'en examiner le prix.
Encore que l'on chasse le chien au nom de la dignité trop abstraite, un banc trop raide pour qui tremble n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Basile Habiyaremye concède que un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
Ce que l'on nomme médiation, ici, n'est pas un slogan : présence encadrée, distincte d'un soin miracle.
Basile : il convient que l'on autorise des heures, non un culte.
Dieudonné peut tenir la laisse.
Lila n'en fera pas une émission trop tendre.
Patrick veut la responsabilité écrite.
La proposition qui reste debout est celle-ci : une lettre au Bureau des Escales : horaires, responsabilité, droit de dire non
Marc : une lettre de médiation n'est pas une fable.
Nous clôturons sans fusionner les voix : la lettre de Basile d'un côté, la réserve d'Inès de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on autorise, un banc trop raide pour qui tremble n'est pas un détail.
Basile Habiyaremye concède que un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
fût-ce un chien trop calme, la médiation peut ouvrir une parole que le jargon ferme
Basile Habiyaremye, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : une lettre au Bureau des Escales : horaires, responsabilité, droit de dire non",
  "correct": true,
  "explanation": "une lettre au Bureau des Escales : horaires, responsabilité, droit de dire non"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle proposition reste debout à la fin ?",
  "options": [
    {
      "text": "Fusionner les deux documents en une affiche",
      "correct": false
    },
    {
      "text": "une lettre au Bureau des Escales : horaires, responsabilité, droit de dire non",
      "correct": true
    },
    {
      "text": "Interdire toute nominalisation",
      "correct": false
    },
    {
      "text": "Couper le micro de Lila",
      "correct": false
    }
  ],
  "explanation": "une lettre au Bureau des Escales : horaires, responsabilité, droit de dire non"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "médiation",
      "right": "présence encadrée, distincte d'un soin miracle"
    },
    {
      "left": "responsabilité",
      "right": "qui répond du chien, des heures, du non"
    },
    {
      "left": "refus",
      "right": "droit, à noter, pas à contourner"
    },
    {
      "left": "lettre",
      "right": "demande argumentée au Bureau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le camion ___ utile, il n'a pas tous les droits. (être, subj.)",
  "answer": "soit"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Une",
    "recommandation",
    "n'est",
    "pas",
    "un",
    "ordre",
    "crié",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lettre",
  "hint": "demande argumentée au Bureau"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Basile Habiyaremye est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Basile Habiyaremye sont clairs, et Lila garde le micro ouvert.",
  "explanation": "Accord : les arguments sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/contrainte-reve.svg",
      "word": "contrainte reve"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/conte-philo.svg",
      "word": "conte philo"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/carte-ailleurs.svg",
      "word": "carte ailleurs"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/point-de-vue.svg",
      "word": "point de vue"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Basile Habiyaremye : vingt lignes, deux voix, une concession, une proposition."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — argumentation juridique inventée ; encore que ; fût-ce',
    'EL',
    $c$Objectif
Maîtriser argumentation juridique inventée ; encore que ; fût-ce au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — argumentation juridique inventée ; encore que ; fût-ce
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on autorise, un banc trop raide pour qui tremble n'est pas un détail.
Basile Habiyaremye concède que un animal n'est pas un soignant, pour autant que l'on n'en fasse pas moins un médiateur possible, encadré.
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
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il convient que » se construit avec le subjonctif.",
  "correct": true,
  "explanation": "Volonté / opportunité."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Après « il convient que », quel mode ?",
  "options": [
    {
      "text": "indicatif seulement",
      "correct": false
    },
    {
      "text": "subjonctif",
      "correct": true
    },
    {
      "text": "impératif uniquement",
      "correct": false
    },
    {
      "text": "conditionnel passé obligatoire",
      "correct": false
    }
  ],
  "explanation": "Il convient que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "médiation",
      "right": "présence encadrée, distincte d'un soin miracle"
    },
    {
      "left": "responsabilité",
      "right": "qui répond du chien, des heures, du non"
    },
    {
      "left": "refus",
      "right": "droit, à noter, pas à contourner"
    },
    {
      "left": "lettre",
      "right": "demande argumentée au Bureau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn procédera à une ___ des heures, non à un slogan. (nominalisation de revoir)",
  "answer": "révision"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Encore",
    "que",
    "le",
    "camion",
    "soit",
    "utile",
    "il",
    "n'a",
    "pas",
    "tous",
    "les",
    "droits",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "collocation",
  "hint": "Précision du discours, sans nommer le mot-cible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On va au refus pour de vrai genre, et Inès Mukama demande un registre plus net.",
  "correct_sentence": "On va au refus vraiment, et Inès Mukama demande un registre plus net.",
  "explanation": "Registre : éviter le marqueur trop oral « genre » dans un écrit soutenu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/conte-philo.svg",
      "word": "conte philo"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/carte-ailleurs.svg",
      "word": "carte ailleurs"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/point-de-vue.svg",
      "word": "point de vue"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/ironie-fine.svg",
      "word": "ironie fine"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « argumentation juridique inventée ; encore que ; fût-ce » et deux pièges commentés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre phrases justes au registre demandé."
}$j$::jsonb,
    9
  );

  -- ===== Ailleurs possibles =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Ailleurs possibles'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Ailleurs possibles', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Ailleurs possibles',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Comprendre les enjeux d'une utopie de rive et en décrire une, sans naïveté. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Ailleurs possibles
Lila Sow : Radio Figuier. On parle trop vite de une utopie trop propre de Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface toute contrainte comme une honte, une liberté qui n'aurait plus de relais ni de rampe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Nina Kayitesi concède que rêver un ailleurs aide à juger l'ici, pour autant que l'on n'oublie pas qui porterait encore les lanternes.
Aline Uwase : Ce que l'on nomme utopie, ici, n'est pas un slogan : ailleurs pensé, avec contraintes avouées.
Patrick Habimana : On dirait que la rivière n'aurait plus de crue, et Joël demande qui essuierait quand même.
Hawa Diallo : Nina : une utopie trop propre est une oubliette.
Joël Mugisha : Mado écrit un conte où la liberté a un relais, ou n'est pas.
Rose Iradukunda : Aline : le conditionnel peint, il n'absout pas.
Solange Mukamana : Sami veut trop d'air ; Yvette trop d'ombre ; le calque les tient.
Karim Bamba : Lila lira l'utopie sans musique triomphale.
Félicie Ndayishimiye : Un chiffre, une trace : Nina a dessiné zéro tour ; trois relais ; une rampe ; un chien ; pas de midi sans ombre.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de rêver sans renvoyer Joël dans l'angle mort
Yvette : Basile y met le chien, encadré.
Mado : Joël Mugisha entend, dans « demain on sera libres », ceci qui n'est pas dit : on sera libres dispense trop souvent de dire qui restera chargé
Sami : Autrement dit, une utopie se juge à ses contraintes avouées, pas à ses nuages
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : décrire une rive possible : libertés, charges, refus du trop propre
Nina Kayitesi : Marc : décrire une utopie, c'est avouer ses charges.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le calque utopique de Nina d'un côté, le conte philosophique de Mado de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Demain on sera libres, répète-t-on, avec cette générosité particulière qui n'a pas à porter les lanternes.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une liberté qui n'aurait plus de relais ni de rampe est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une liberté qui n'aurait plus de relais ni de rampe n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Joël Mugisha, que reste-t-il implicite dans « demain on sera libres » ?",
  "options": [
    {
      "text": "Que Nina a dessiné une tour",
      "correct": false
    },
    {
      "text": "Qui restera chargé",
      "correct": true
    },
    {
      "text": "Que Joël est absent du calque",
      "correct": false
    },
    {
      "text": "Que Mado interdit les rêves",
      "correct": false
    }
  ],
  "explanation": "on sera libres dispense trop souvent de dire qui restera chargé"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "utopie",
      "right": "ailleurs pensé, avec contraintes avouées"
    },
    {
      "left": "contrainte",
      "right": "limite nécessaire, pas seulement un mal"
    },
    {
      "left": "liberté",
      "right": "pouvoir, distinct d'un slogan"
    },
    {
      "left": "charge",
      "right": "travail qui reste, même demain"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn dirait que la rivière ___ une voix. (prendre, cond.)",
  "answer": "prendrait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "On",
    "dirait",
    "que",
    "la",
    "rivière",
    "prendrait",
    "une",
    "voix",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "utopie",
  "hint": "ailleurs pensé, avec contraintes avouées"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On dirait que la rivière prend une voix demain soir, et Nina Kayitesi écrit encore.",
  "correct_sentence": "On dirait que la rivière prendrait une voix demain soir, et Nina Kayitesi écrit encore.",
  "explanation": "Hypotypose : conditionnel prendrait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/carte-ailleurs.svg",
      "word": "carte ailleurs"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/point-de-vue.svg",
      "word": "point de vue"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/ironie-fine.svg",
      "word": "ironie fine"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/micro-bonheur.svg",
      "word": "micro bonheur"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « demain on sera libres » et la concession de Nina Kayitesi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le calque utopique de Nina et le conte philosophique de Mado distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — L''utopie avoue ses charges',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comprendre les enjeux d'une utopie de rive et en décrire une, sans naïveté. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « L'utopie avoue ses charges », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — L'utopie avoue ses charges
On parle trop vite de une utopie trop propre de Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
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
La proposition qui reste debout est celle-ci : décrire une rive possible : libertés, charges, refus du trop propre
Marc : décrire une utopie, c'est avouer ses charges.
Nous clôturons sans fusionner les voix : le calque utopique de Nina d'un côté, le conte philosophique de Mado de l'autre, et le point où elles refusent de se ressembler.
Signé : Nina Kayitesi, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le calque utopique de Nina et le conte philosophique de Mado en une seule affiche.",
  "correct": true,
  "explanation": "La clôture garde deux voix et le point où elles ne se ressemblent pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il retenir du fait ou du chiffre avancé ?",
  "options": [
    {
      "text": "Rien n'est chiffré, tout est slogan",
      "correct": false
    },
    {
      "text": "Zéro tour, trois relais, une rampe, pas de midi sans ombre",
      "correct": true
    },
    {
      "text": "Le chiffre annule la concession",
      "correct": false
    },
    {
      "text": "Le micro interdit les traces",
      "correct": false
    }
  ],
  "explanation": "Nina a dessiné zéro tour ; trois relais ; une rampe ; un chien ; pas de midi sans ombre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "utopie",
      "right": "ailleurs pensé, avec contraintes avouées"
    },
    {
      "left": "contrainte",
      "right": "limite nécessaire, pas seulement un mal"
    },
    {
      "left": "liberté",
      "right": "pouvoir, distinct d'un slogan"
    },
    {
      "left": "charge",
      "right": "travail qui reste, même demain"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi la colline ___ parler, elle parlerait des racines. (pouvoir, imp.)",
  "answer": "pouvait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Si",
    "la",
    "colline",
    "pouvait",
    "parler",
    "elle",
    "parlerait",
    "des",
    "racines",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "contrainte",
  "hint": "limite nécessaire, pas seulement un mal"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La utopie de trop vite n'aide personne, et Joël Mugisha reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Joël Mugisha reprend le fil.",
  "explanation": "Éviter une construction calquée ; préférer un nom d'action juste (précipitation)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/point-de-vue.svg",
      "word": "point de vue"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/ironie-fine.svg",
      "word": "ironie fine"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/micro-bonheur.svg",
      "word": "micro bonheur"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/cahier-utopie.svg",
      "word": "cahier utopie"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « L'utopie avoue ses charges » : thèse, concession, implicite, proposition (quinze lignes)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Ailleurs possibles : dire sans slogan',
    'PO',
    $c$Objectif
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
La proposition qui reste debout est celle-ci : décrire une rive possible : libertés, charges, refus du trop propre
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le calque utopique de Nina d'un côté, le conte philosophique de Mado de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Nina Kayitesi transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Nina Kayitesi concède que rêver un ailleurs aide à juger l'ici, pour autant que l'on n'oublie pas qui porterait encore les lanternes."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Nina Kayitesi, et à quelle condition ?",
  "options": [
    {
      "text": "Nina Kayitesi n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "rêver un ailleurs aide à juger l'ici — à condition que l'on n'oublie pas qui porterait encore les lanternes",
      "correct": true
    },
    {
      "text": "Nina Kayitesi abandonne il s'agit de rêver sans renvoyer Joël dans l'angle mort",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'oublie pas qui porterait encore les lanternes"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "utopie",
      "right": "ailleurs pensé, avec contraintes avouées"
    },
    {
      "left": "contrainte",
      "right": "limite nécessaire, pas seulement un mal"
    },
    {
      "left": "liberté",
      "right": "pouvoir, distinct d'un slogan"
    },
    {
      "left": "charge",
      "right": "travail qui reste, même demain"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne tour ___ l'ombre jusqu'au saule. (avaler, cond.)",
  "answer": "avalerait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Une",
    "tour",
    "avalerait",
    "l'ombre",
    "jusqu'au",
    "saule",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "liberté",
  "hint": "pouvoir, distinct d'un slogan"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nina Kayitesi écoute encore, et il fautons rêver avant de crier.",
  "correct_sentence": "Nina Kayitesi écoute encore, et il faut rêver avant de crier.",
  "explanation": "Toujours il faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/ironie-fine.svg",
      "word": "ironie fine"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/micro-bonheur.svg",
      "word": "micro bonheur"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/cahier-utopie.svg",
      "word": "cahier utopie"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/salle-herbes-soir.svg",
      "word": "salle herbes soir"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur utopie / contrainte ; conditionnel ; rêve et réalité, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le calque utopique de Nina et le conte philosophique de Mado distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Nina Kayitesi',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Comprendre les enjeux d'une utopie de rive et en décrire une, sans naïveté. Point : utopie / contrainte ; conditionnel ; rêve et réalité.

Consigne
Imitez le texte de Nina Kayitesi.

Support — Nina Kayitesi — L'utopie avoue ses charges
Nina Kayitesi — L'utopie avoue ses charges
On parle trop vite de une utopie trop propre de Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface toute contrainte comme une honte, une liberté qui n'aurait plus de relais ni de rampe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que rêver un ailleurs aide à juger l'ici, pour autant que l'on n'oublie pas qui porterait encore les lanternes.
Ce que l'on nomme utopie, ici, n'est pas un slogan : ailleurs pensé, avec contraintes avouées.
On dirait que la rivière n'aurait plus de crue, et Joël demande qui essuierait quand même.
Sami veut trop d'air ; Yvette trop d'ombre ; le calque les tient.
Lila lira l'utopie sans musique triomphale.
Basile y met le chien, encadré.
La proposition qui reste debout est celle-ci : décrire une rive possible : libertés, charges, refus du trop propre
Marc : décrire une utopie, c'est avouer ses charges.
Nous clôturons sans fusionner les voix : le calque utopique de Nina d'un côté, le conte philosophique de Mado de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on rêve, une liberté qui n'aurait plus de relais ni de rampe n'est pas un détail.
Nina Kayitesi concède que rêver un ailleurs aide à juger l'ici, pour autant que l'on n'oublie pas qui porterait encore les lanternes.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
une utopie se juge à ses contraintes avouées, pas à ses nuages
Nina Kayitesi, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : décrire une rive possible : libertés, charges, refus du trop propre",
  "correct": true,
  "explanation": "décrire une rive possible : libertés, charges, refus du trop propre"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle proposition reste debout à la fin ?",
  "options": [
    {
      "text": "Fusionner les deux documents en une affiche",
      "correct": false
    },
    {
      "text": "décrire une rive possible : libertés, charges, refus du trop propre",
      "correct": true
    },
    {
      "text": "Interdire toute nominalisation",
      "correct": false
    },
    {
      "text": "Couper le micro de Lila",
      "correct": false
    }
  ],
  "explanation": "décrire une rive possible : libertés, charges, refus du trop propre"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "utopie",
      "right": "ailleurs pensé, avec contraintes avouées"
    },
    {
      "left": "contrainte",
      "right": "limite nécessaire, pas seulement un mal"
    },
    {
      "left": "liberté",
      "right": "pouvoir, distinct d'un slogan"
    },
    {
      "left": "charge",
      "right": "travail qui reste, même demain"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le récit ___ inventé, il dit une peur vraie. (être, subj.)",
  "answer": "soit"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Le",
    "conditionnel",
    "ici",
    "n'est",
    "pas",
    "un",
    "rêve",
    "creux",
    "c'est",
    "une",
    "hypotypose",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "charge",
  "hint": "travail qui reste, même demain"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Nina Kayitesi est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Nina Kayitesi sont clairs, et Lila garde le micro ouvert.",
  "explanation": "Accord : les arguments sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/micro-bonheur.svg",
      "word": "micro bonheur"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/cahier-utopie.svg",
      "word": "cahier utopie"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/salle-herbes-soir.svg",
      "word": "salle herbes soir"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/masque-invente.svg",
      "word": "masque invente"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Nina Kayitesi : vingt lignes, deux voix, une concession, une proposition."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — utopie / contrainte ; conditionnel ; rêve et réalité',
    'EL',
    $c$Objectif
Maîtriser utopie / contrainte ; conditionnel ; rêve et réalité au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — utopie / contrainte ; conditionnel ; rêve et réalité
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on rêve, une liberté qui n'aurait plus de relais ni de rampe n'est pas un détail.
Nina Kayitesi concède que rêver un ailleurs aide à juger l'ici, pour autant que l'on n'oublie pas qui porterait encore les lanternes.
Autrement dit, une utopie se juge à ses contraintes avouées, pas à ses nuages
Il ressort que décrire une rive possible : libertés, charges, refus du trop propre
Piège : indicatif plat là où le conditionnel peint
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme utopie, ici, n'est pas un slogan : ailleurs pensé, avec contraintes avouées.
Nina : une utopie trop propre est une oubliette.
Sami veut trop d'air ; Yvette trop d'ombre ; le calque les tient.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au liberté pour de vrai genre, et Joël Mugisha demande un registre plus net.
Correction : On va au liberté vraiment, et Joël Mugisha demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le conditionnel peut peindre un comme si, pas seulement une politesse.",
  "correct": true,
  "explanation": "Hypotypose."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Dans une description fantastique, le conditionnel sert surtout à…",
  "options": [
    {
      "text": "donner un ordre",
      "correct": false
    },
    {
      "text": "peindre une hypotypose, un comme si",
      "correct": true
    },
    {
      "text": "marquer un passé antérieur",
      "correct": false
    },
    {
      "text": "interdire la métaphore",
      "correct": false
    }
  ],
  "explanation": "Conditionnel d'imagination / hypotypose."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "utopie",
      "right": "ailleurs pensé, avec contraintes avouées"
    },
    {
      "left": "contrainte",
      "right": "limite nécessaire, pas seulement un mal"
    },
    {
      "left": "liberté",
      "right": "pouvoir, distinct d'un slogan"
    },
    {
      "left": "charge",
      "right": "travail qui reste, même demain"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'___ du plan n'empêche pas d'écrire le cauchemar. (urbanisme déjà donné)",
  "answer": "utopie"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Encore",
    "que",
    "le",
    "récit",
    "soit",
    "inventé",
    "il",
    "dit",
    "une",
    "peur",
    "vraie",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "collocation",
  "hint": "Précision du discours, sans nommer le mot-cible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On va au liberté pour de vrai genre, et Joël Mugisha demande un registre plus net.",
  "correct_sentence": "On va au liberté vraiment, et Joël Mugisha demande un registre plus net.",
  "explanation": "Registre : éviter le marqueur trop oral « genre » dans un écrit soutenu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/cahier-utopie.svg",
      "word": "cahier utopie"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/salle-herbes-soir.svg",
      "word": "salle herbes soir"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/masque-invente.svg",
      "word": "masque invente"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/lampe-scene.svg",
      "word": "lampe scene"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « utopie / contrainte ; conditionnel ; rêve et réalité » et deux pièges commentés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre phrases justes au registre demandé."
}$j$::jsonb,
    9
  );

  -- ===== Lettre pour Basile =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Lettre pour Basile'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Lettre pour Basile', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Lettre pour Basile',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Rédiger une lettre de médiation claire, relisible, sans mièvrerie. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Lettre pour Basile
Lila Sow : Radio Figuier. On parle trop vite de la lettre au Bureau des Escales, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace le droit par l'émotion, une lettre trop tendre pour être opposable n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Inès Mukama concède que le ton peut rester humain, pour autant que l'on y trouve horaires, responsabilités, droit de refus.
Aline Uwase : Ce que l'on nomme cadre, ici, n'est pas un slogan : règles écrites de la médiation.
Patrick Habimana : Inès : il convient que l'on date, encore que le ton reste humain.
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
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : trois paragraphes : constat, cadre, demande datée
Nina Kayitesi : Marc : une lettre formelle n'est pas une froideur, c'est une hospitalité faite au malentendu futur.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le brouillon trop tendre d'un côté, la lettre retenue de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Le cœur, en ces matières, a cet avantage : on ne peut pas le citer dans un compte-rendu.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une lettre trop tendre pour être opposable est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une lettre trop tendre pour être opposable n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Basile Habiyaremye, que reste-t-il implicite dans « suivez votre cœur » ?",
  "options": [
    {
      "text": "Que Inès a écrit suivez votre cœur",
      "correct": false
    },
    {
      "text": "Qui répond du chien s'il gronde",
      "correct": true
    },
    {
      "text": "Que Basile a refusé tout cadre",
      "correct": false
    },
    {
      "text": "Que le jeudi a disparu",
      "correct": false
    }
  ],
  "explanation": "suivez votre cœur évite d'écrire qui répond du chien s'il gronde"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cadre",
      "right": "règles écrites de la médiation"
    },
    {
      "left": "horaire",
      "right": "heures nommées, pas un nuage"
    },
    {
      "left": "opposable",
      "right": "texte dont on peut se prévaloir"
    },
    {
      "left": "paragraphe",
      "right": "unité de la lettre formelle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ avant d'accélérer. (dater, subj.)",
  "answer": "date"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Il",
    "convient",
    "que",
    "l'on",
    "date",
    "avant",
    "d'accélérer",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "cadre",
  "hint": "règles écrites de la médiation"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il convient que l'on dater trop tard, et Inès Mukama refuse d'accélérer la pente.",
  "correct_sentence": "Il convient que l'on date trop tard, et Inès Mukama refuse d'accélérer la pente.",
  "explanation": "Il convient que + date."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/salle-herbes-soir.svg",
      "word": "salle herbes soir"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/masque-invente.svg",
      "word": "masque invente"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/lampe-scene.svg",
      "word": "lampe scene"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/plume-mado.svg",
      "word": "plume mado"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « suivez votre cœur » et la concession de Inès Mukama."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le brouillon trop tendre et la lettre retenue distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Opposable, pas trop tendre',
    'CE',
    $c$Objectif
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
La proposition qui reste debout est celle-ci : trois paragraphes : constat, cadre, demande datée
Marc : une lettre formelle n'est pas une froideur, c'est une hospitalité faite au malentendu futur.
Nous clôturons sans fusionner les voix : le brouillon trop tendre d'un côté, la lettre retenue de l'autre, et le point où elles refusent de se ressembler.
Signé : Inès Mukama, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le brouillon trop tendre et la lettre retenue en une seule affiche.",
  "correct": true,
  "explanation": "La clôture garde deux voix et le point où elles ne se ressemblent pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il retenir du fait ou du chiffre avancé ?",
  "options": [
    {
      "text": "Rien n'est chiffré, tout est slogan",
      "correct": false
    },
    {
      "text": "Cœur raturé, refus gardé, jeudi daté",
      "correct": true
    },
    {
      "text": "Le chiffre annule la concession",
      "correct": false
    },
    {
      "text": "Le micro interdit les traces",
      "correct": false
    }
  ],
  "explanation": "Inès a raturé suivez votre cœur ; gardé le refus ; daté le jeudi."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cadre",
      "right": "règles écrites de la médiation"
    },
    {
      "left": "horaire",
      "right": "heures nommées, pas un nuage"
    },
    {
      "left": "opposable",
      "right": "texte dont on peut se prévaloir"
    },
    {
      "left": "paragraphe",
      "right": "unité de la lettre formelle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl s'agit de ___ la pente, non de la nier. (nommer)",
  "answer": "nommer"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Il",
    "s'agit",
    "de",
    "nommer",
    "la",
    "pente",
    "non",
    "de",
    "la",
    "nier",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "horaire",
  "hint": "heures nommées, pas un nuage"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La cadre de trop vite n'aide personne, et Basile Habiyaremye reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Basile Habiyaremye reprend le fil.",
  "explanation": "Éviter une construction calquée ; préférer un nom d'action juste (précipitation)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/masque-invente.svg",
      "word": "masque invente"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/lampe-scene.svg",
      "word": "lampe scene"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/plume-mado.svg",
      "word": "plume mado"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/radio-ame.svg",
      "word": "radio ame"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Opposable, pas trop tendre » : thèse, concession, implicite, proposition (quinze lignes)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Lettre pour Basile : dire sans slogan',
    'PO',
    $c$Objectif
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
La proposition qui reste debout est celle-ci : trois paragraphes : constat, cadre, demande datée
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le brouillon trop tendre d'un côté, la lettre retenue de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Inès Mukama transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Inès Mukama concède que le ton peut rester humain, pour autant que l'on y trouve horaires, responsabilités, droit de refus."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Inès Mukama, et à quelle condition ?",
  "options": [
    {
      "text": "Inès Mukama n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "le ton peut rester humain — à condition que l'on y trouve horaires, responsabilités, droit de refus",
      "correct": true
    },
    {
      "text": "Inès Mukama abandonne il s'agit qu'une lettre puisse se relire en cas de malentendu",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on y trouve horaires, responsabilités, droit de refus"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cadre",
      "right": "règles écrites de la médiation"
    },
    {
      "left": "horaire",
      "right": "heures nommées, pas un nuage"
    },
    {
      "left": "opposable",
      "right": "texte dont on peut se prévaloir"
    },
    {
      "left": "paragraphe",
      "right": "unité de la lettre formelle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous recommandons que la cour ___ un relais. (dater, subj.)",
  "answer": "date"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Nous",
    "recommandons",
    "que",
    "la",
    "cour",
    "date",
    "un",
    "relais",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "opposable",
  "hint": "texte dont on peut se prévaloir"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Inès Mukama écoute encore, et il fautons dater avant de crier.",
  "correct_sentence": "Inès Mukama écoute encore, et il faut dater avant de crier.",
  "explanation": "Toujours il faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/lampe-scene.svg",
      "word": "lampe scene"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/plume-mado.svg",
      "word": "plume mado"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/radio-ame.svg",
      "word": "radio ame"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/soleil-reve.svg",
      "word": "soleil reve"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur lettre formelle ; concession ; hypotaxe longue, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le brouillon trop tendre et la lettre retenue distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Inès Mukama',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Rédiger une lettre de médiation claire, relisible, sans mièvrerie. Point : lettre formelle ; concession ; hypotaxe longue.

Consigne
Imitez le texte de Inès Mukama.

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
La proposition qui reste debout est celle-ci : trois paragraphes : constat, cadre, demande datée
Marc : une lettre formelle n'est pas une froideur, c'est une hospitalité faite au malentendu futur.
Nous clôturons sans fusionner les voix : le brouillon trop tendre d'un côté, la lettre retenue de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on date, une lettre trop tendre pour être opposable n'est pas un détail.
Inès Mukama concède que le ton peut rester humain, pour autant que l'on y trouve horaires, responsabilités, droit de refus.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
une lettre de C2 tient l'hypotaxe et le concret : fût-ce pour un chien
Inès Mukama, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : trois paragraphes : constat, cadre, demande datée",
  "correct": true,
  "explanation": "trois paragraphes : constat, cadre, demande datée"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle proposition reste debout à la fin ?",
  "options": [
    {
      "text": "Fusionner les deux documents en une affiche",
      "correct": false
    },
    {
      "text": "trois paragraphes : constat, cadre, demande datée",
      "correct": true
    },
    {
      "text": "Interdire toute nominalisation",
      "correct": false
    },
    {
      "text": "Couper le micro de Lila",
      "correct": false
    }
  ],
  "explanation": "trois paragraphes : constat, cadre, demande datée"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cadre",
      "right": "règles écrites de la médiation"
    },
    {
      "left": "horaire",
      "right": "heures nommées, pas un nuage"
    },
    {
      "left": "opposable",
      "right": "texte dont on peut se prévaloir"
    },
    {
      "left": "paragraphe",
      "right": "unité de la lettre formelle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le camion ___ utile, il n'a pas tous les droits. (être, subj.)",
  "answer": "soit"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Une",
    "recommandation",
    "n'est",
    "pas",
    "un",
    "ordre",
    "crié",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "paragraphe",
  "hint": "unité de la lettre formelle"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Inès Mukama est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Inès Mukama sont clairs, et Lila garde le micro ouvert.",
  "explanation": "Accord : les arguments sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/plume-mado.svg",
      "word": "plume mado"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/radio-ame.svg",
      "word": "radio ame"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/soleil-reve.svg",
      "word": "soleil reve"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/nuage-ennui.svg",
      "word": "nuage ennui"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Inès Mukama : vingt lignes, deux voix, une concession, une proposition."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — lettre formelle ; concession ; hypotaxe longue',
    'EL',
    $c$Objectif
Maîtriser lettre formelle ; concession ; hypotaxe longue au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — lettre formelle ; concession ; hypotaxe longue
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on date, une lettre trop tendre pour être opposable n'est pas un détail.
Inès Mukama concède que le ton peut rester humain, pour autant que l'on y trouve horaires, responsabilités, droit de refus.
Autrement dit, une lettre de C2 tient l'hypotaxe et le concret : fût-ce pour un chien
Il ressort que trois paragraphes : constat, cadre, demande datée
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme cadre, ici, n'est pas un slogan : règles écrites de la médiation.
Basile accepte le refus noté.
Lila ne lira pas la lettre à l'antenne sans accord.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au opposable pour de vrai genre, et Basile Habiyaremye demande un registre plus net.
Correction : On va au opposable vraiment, et Basile Habiyaremye demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il convient que » se construit avec le subjonctif.",
  "correct": true,
  "explanation": "Volonté / opportunité."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Après « il convient que », quel mode ?",
  "options": [
    {
      "text": "indicatif seulement",
      "correct": false
    },
    {
      "text": "subjonctif",
      "correct": true
    },
    {
      "text": "impératif uniquement",
      "correct": false
    },
    {
      "text": "conditionnel passé obligatoire",
      "correct": false
    }
  ],
  "explanation": "Il convient que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cadre",
      "right": "règles écrites de la médiation"
    },
    {
      "left": "horaire",
      "right": "heures nommées, pas un nuage"
    },
    {
      "left": "opposable",
      "right": "texte dont on peut se prévaloir"
    },
    {
      "left": "paragraphe",
      "right": "unité de la lettre formelle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn procédera à une ___ des heures, non à un slogan. (nominalisation de revoir)",
  "answer": "révision"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Encore",
    "que",
    "le",
    "camion",
    "soit",
    "utile",
    "il",
    "n'a",
    "pas",
    "tous",
    "les",
    "droits",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "collocation",
  "hint": "Précision du discours, sans nommer le mot-cible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On va au opposable pour de vrai genre, et Basile Habiyaremye demande un registre plus net.",
  "correct_sentence": "On va au opposable vraiment, et Basile Habiyaremye demande un registre plus net.",
  "explanation": "Registre : éviter le marqueur trop oral « genre » dans un écrit soutenu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/radio-ame.svg",
      "word": "radio ame"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/soleil-reve.svg",
      "word": "soleil reve"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/nuage-ennui.svg",
      "word": "nuage ennui"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/feuille-lettre.svg",
      "word": "feuille lettre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « lettre formelle ; concession ; hypotaxe longue » et deux pièges commentés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre phrases justes au registre demandé."
}$j$::jsonb,
    9
  );

  -- ===== Une utopie de rive =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une utopie de rive'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une utopie de rive', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Une utopie de rive',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Décrire une utopie personnelle ancrée à Rukiri-Nord, C2, sans carte postale. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Une utopie de rive
Lila Sow : Radio Figuier. On parle trop vite de la rive que l'on ose encore rêver, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on gommenait Joël, la rampe, la crue, une perfection qui n'a plus besoin de personne n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que le rêve a le droit d'être beau, pour autant que l'on y laisse sale un peu de terre sous l'ongle.
Aline Uwase : Ce que l'on nomme rive, ici, n'est pas un slogan : bord d'eau et de travail.
Patrick Habimana : Mado : on dirait que la crue viendrait encore, et que l'on saurait ensemble.
Hawa Diallo : Nina refuse le trop propre.
Joël Mugisha : Joël apparaît au troisième paragraphe, pas en note.
Rose Iradukunda : Aline : le conditionnel ici est une éthique.
Solange Mukamana : Sami veut trop d'air ; on lui laisse, avec un relais.
Karim Bamba : Lila lira sans triomphe.
Félicie Ndayishimiye : Un chiffre, une trace : Mado a laissé la terre ; Nina la rampe ; Joël un relais ; zéro monde parfait.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de rêver une cour, pas une vitrine
Yvette : Félicie glisse un bol.
Mado : Nina Kayitesi entend, dans « un monde parfait », ceci qui n'est pas dit : parfait veut souvent dire sans visages trop réels
Sami : Autrement dit, on dirait une rive où l'on porterait encore, mais à plusieurs, et midi aurait une ombre
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : deux pages : ailleurs, charges, une ironie contre le trop propre
Nina Kayitesi : Marc : une utopie de rive se juge à ses ongles.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'utopie de Mado d'un côté, les ratures de Nina de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Un monde parfait, au Seuil, aurait cet inconvénient majeur : on n'y verrait plus qui essuie.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une perfection qui n'a plus besoin de personne est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une perfection qui n'a plus besoin de personne n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Nina Kayitesi, que reste-t-il implicite dans « un monde parfait » ?",
  "options": [
    {
      "text": "Que Mado a écrit un monde parfait",
      "correct": false
    },
    {
      "text": "Sans visages trop réels",
      "correct": true
    },
    {
      "text": "Que Nina a gommé Joël",
      "correct": false
    },
    {
      "text": "Que la terre est interdite au rêve",
      "correct": false
    }
  ],
  "explanation": "parfait veut souvent dire sans visages trop réels"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "rive",
      "right": "bord d'eau et de travail"
    },
    {
      "left": "perfection",
      "right": "idéal trop net, souvent une oubliette"
    },
    {
      "left": "terre",
      "right": "matière qui salit le rêve juste assez"
    },
    {
      "left": "vitrine",
      "right": "ailleurs trop exposé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn dirait que la rivière ___ une voix. (prendre, cond.)",
  "answer": "prendrait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "On",
    "dirait",
    "que",
    "la",
    "rivière",
    "prendrait",
    "une",
    "voix",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "rive",
  "hint": "bord d'eau et de travail"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On dirait que la rivière prend une voix demain soir, et Mado écrit encore.",
  "correct_sentence": "On dirait que la rivière prendrait une voix demain soir, et Mado écrit encore.",
  "explanation": "Hypotypose : conditionnel prendrait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/soleil-reve.svg",
      "word": "soleil reve"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/nuage-ennui.svg",
      "word": "nuage ennui"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/feuille-lettre.svg",
      "word": "feuille lettre"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/groupe-spectateurs.svg",
      "word": "groupe spectateurs"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « un monde parfait » et la concession de Mado."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'utopie de Mado et les ratures de Nina distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Un peu de terre sous l''ongle',
    'CE',
    $c$Objectif
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
La proposition qui reste debout est celle-ci : deux pages : ailleurs, charges, une ironie contre le trop propre
Marc : une utopie de rive se juge à ses ongles.
Nous clôturons sans fusionner les voix : l'utopie de Mado d'un côté, les ratures de Nina de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'utopie de Mado et les ratures de Nina en une seule affiche.",
  "correct": true,
  "explanation": "La clôture garde deux voix et le point où elles ne se ressemblent pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il retenir du fait ou du chiffre avancé ?",
  "options": [
    {
      "text": "Rien n'est chiffré, tout est slogan",
      "correct": false
    },
    {
      "text": "Terre, rampe, relais, zéro monde parfait",
      "correct": true
    },
    {
      "text": "Le chiffre annule la concession",
      "correct": false
    },
    {
      "text": "Le micro interdit les traces",
      "correct": false
    }
  ],
  "explanation": "Mado a laissé la terre ; Nina la rampe ; Joël un relais ; zéro monde parfait."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "rive",
      "right": "bord d'eau et de travail"
    },
    {
      "left": "perfection",
      "right": "idéal trop net, souvent une oubliette"
    },
    {
      "left": "terre",
      "right": "matière qui salit le rêve juste assez"
    },
    {
      "left": "vitrine",
      "right": "ailleurs trop exposé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi la colline ___ parler, elle parlerait des racines. (pouvoir, imp.)",
  "answer": "pouvait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Si",
    "la",
    "colline",
    "pouvait",
    "parler",
    "elle",
    "parlerait",
    "des",
    "racines",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "perfection",
  "hint": "idéal trop net, souvent une oubliette"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La rive de trop vite n'aide personne, et Nina Kayitesi reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Nina Kayitesi reprend le fil.",
  "explanation": "Éviter une construction calquée ; préférer un nom d'action juste (précipitation)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/nuage-ennui.svg",
      "word": "nuage ennui"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/feuille-lettre.svg",
      "word": "feuille lettre"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/groupe-spectateurs.svg",
      "word": "groupe spectateurs"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/coeur-utopie.svg",
      "word": "coeur utopie"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Un peu de terre sous l'ongle » : thèse, concession, implicite, proposition (quinze lignes)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Une utopie de rive : dire sans slogan',
    'PO',
    $c$Objectif
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
La proposition qui reste debout est celle-ci : deux pages : ailleurs, charges, une ironie contre le trop propre
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'utopie de Mado d'un côté, les ratures de Nina de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Mado concède que le rêve a le droit d'être beau, pour autant que l'on y laisse sale un peu de terre sous l'ongle."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Mado, et à quelle condition ?",
  "options": [
    {
      "text": "Mado n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "le rêve a le droit d'être beau — à condition que l'on y laisse sale un peu de terre sous l'ongle",
      "correct": true
    },
    {
      "text": "Mado abandonne il s'agit de rêver une cour, pas une vitrine",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on y laisse sale un peu de terre sous l'ongle"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "rive",
      "right": "bord d'eau et de travail"
    },
    {
      "left": "perfection",
      "right": "idéal trop net, souvent une oubliette"
    },
    {
      "left": "terre",
      "right": "matière qui salit le rêve juste assez"
    },
    {
      "left": "vitrine",
      "right": "ailleurs trop exposé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne tour ___ l'ombre jusqu'au saule. (avaler, cond.)",
  "answer": "avalerait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Une",
    "tour",
    "avalerait",
    "l'ombre",
    "jusqu'au",
    "saule",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "terre",
  "hint": "matière qui salit le rêve juste assez"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Mado écoute encore, et il fautons salir avant de crier.",
  "correct_sentence": "Mado écoute encore, et il faut salir avant de crier.",
  "explanation": "Toujours il faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/feuille-lettre.svg",
      "word": "feuille lettre"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/groupe-spectateurs.svg",
      "word": "groupe spectateurs"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/coeur-utopie.svg",
      "word": "coeur utopie"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/extrait-theatre.svg",
      "word": "extrait theatre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur écriture d'utopie ; charges avouées ; ironie douce, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'utopie de Mado et les ratures de Nina distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Mado',
    'PE',
    $c$Objectif
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
La proposition qui reste debout est celle-ci : deux pages : ailleurs, charges, une ironie contre le trop propre
Marc : une utopie de rive se juge à ses ongles.
Nous clôturons sans fusionner les voix : l'utopie de Mado d'un côté, les ratures de Nina de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on salisse, une perfection qui n'a plus besoin de personne n'est pas un détail.
Mado concède que le rêve a le droit d'être beau, pour autant que l'on y laisse sale un peu de terre sous l'ongle.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
on dirait une rive où l'on porterait encore, mais à plusieurs, et midi aurait une ombre
Mado, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : deux pages : ailleurs, charges, une ironie contre le trop propre",
  "correct": true,
  "explanation": "deux pages : ailleurs, charges, une ironie contre le trop propre"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle proposition reste debout à la fin ?",
  "options": [
    {
      "text": "Fusionner les deux documents en une affiche",
      "correct": false
    },
    {
      "text": "deux pages : ailleurs, charges, une ironie contre le trop propre",
      "correct": true
    },
    {
      "text": "Interdire toute nominalisation",
      "correct": false
    },
    {
      "text": "Couper le micro de Lila",
      "correct": false
    }
  ],
  "explanation": "deux pages : ailleurs, charges, une ironie contre le trop propre"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "rive",
      "right": "bord d'eau et de travail"
    },
    {
      "left": "perfection",
      "right": "idéal trop net, souvent une oubliette"
    },
    {
      "left": "terre",
      "right": "matière qui salit le rêve juste assez"
    },
    {
      "left": "vitrine",
      "right": "ailleurs trop exposé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le récit ___ inventé, il dit une peur vraie. (être, subj.)",
  "answer": "soit"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Le",
    "conditionnel",
    "ici",
    "n'est",
    "pas",
    "un",
    "rêve",
    "creux",
    "c'est",
    "une",
    "hypotypose",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "vitrine",
  "hint": "ailleurs trop exposé"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Mado est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Mado sont clairs, et Lila garde le micro ouvert.",
  "explanation": "Accord : les arguments sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/groupe-spectateurs.svg",
      "word": "groupe spectateurs"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/coeur-utopie.svg",
      "word": "coeur utopie"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/extrait-theatre.svg",
      "word": "extrait theatre"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/critique-film.svg",
      "word": "critique film"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Mado : vingt lignes, deux voix, une concession, une proposition."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — écriture d''utopie ; charges avouées ; ironie douce',
    'EL',
    $c$Objectif
Maîtriser écriture d'utopie ; charges avouées ; ironie douce au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — écriture d'utopie ; charges avouées ; ironie douce
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on salisse, une perfection qui n'a plus besoin de personne n'est pas un détail.
Mado concède que le rêve a le droit d'être beau, pour autant que l'on y laisse sale un peu de terre sous l'ongle.
Autrement dit, on dirait une rive où l'on porterait encore, mais à plusieurs, et midi aurait une ombre
Il ressort que deux pages : ailleurs, charges, une ironie contre le trop propre
Piège : indicatif plat là où le conditionnel peint
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme rive, ici, n'est pas un slogan : bord d'eau et de travail.
Nina refuse le trop propre.
Sami veut trop d'air ; on lui laisse, avec un relais.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au terre pour de vrai genre, et Nina Kayitesi demande un registre plus net.
Correction : On va au terre vraiment, et Nina Kayitesi demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le conditionnel peut peindre un comme si, pas seulement une politesse.",
  "correct": true,
  "explanation": "Hypotypose."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Dans une description fantastique, le conditionnel sert surtout à…",
  "options": [
    {
      "text": "donner un ordre",
      "correct": false
    },
    {
      "text": "peindre une hypotypose, un comme si",
      "correct": true
    },
    {
      "text": "marquer un passé antérieur",
      "correct": false
    },
    {
      "text": "interdire la métaphore",
      "correct": false
    }
  ],
  "explanation": "Conditionnel d'imagination / hypotypose."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "rive",
      "right": "bord d'eau et de travail"
    },
    {
      "left": "perfection",
      "right": "idéal trop net, souvent une oubliette"
    },
    {
      "left": "terre",
      "right": "matière qui salit le rêve juste assez"
    },
    {
      "left": "vitrine",
      "right": "ailleurs trop exposé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'___ du plan n'empêche pas d'écrire le cauchemar. (urbanisme déjà donné)",
  "answer": "rive"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Encore",
    "que",
    "le",
    "récit",
    "soit",
    "inventé",
    "il",
    "dit",
    "une",
    "peur",
    "vraie",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "collocation",
  "hint": "Précision du discours, sans nommer le mot-cible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On va au terre pour de vrai genre, et Nina Kayitesi demande un registre plus net.",
  "correct_sentence": "On va au terre vraiment, et Nina Kayitesi demande un registre plus net.",
  "explanation": "Registre : éviter le marqueur trop oral « genre » dans un écrit soutenu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m1/coeur-utopie.svg",
      "word": "coeur utopie"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/extrait-theatre.svg",
      "word": "extrait theatre"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/critique-film.svg",
      "word": "critique film"
    },
    {
      "image_path": "/elearning/mfk-c2-m1/sentiment-fin.svg",
      "word": "sentiment fin"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « écriture d'utopie ; charges avouées ; ironie douce » et deux pièges commentés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre phrases justes au registre demandé."
}$j$::jsonb,
    9
  );

END;
$$;
