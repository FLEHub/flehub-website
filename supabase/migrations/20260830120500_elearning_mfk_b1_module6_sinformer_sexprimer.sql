/*
  Seed eLearning MFK — B1 — S'informer, s'exprimer

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b1-m6/
  Module laissé en brouillon (published = false).
  Aucune table nouvelle. Idempotent. Éditable via « Gérer le contenu ».
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
  v_module_title text := 'B1 — S''informer, s''exprimer';
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
      'Seed B1 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed B1 : enseignant % (%) — %', v_teacher_email, v_teacher_id, v_module_title;

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
      'Grande étape B1-6 : analyser une source, relater un fait, démasquer une rumeur, tenir le micro, préparer le journal parlé et respecter l''éthique de l''antenne — à Radio Figuier, entre la rumeur du Marché des Lampions et la nouvelle vérifiée de la rivière, au Seuil des Sources (Rukiri-Nord).',
      'B1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B1-6 : analyser une source, relater un fait, démasquer une rumeur, tenir le micro, préparer le journal parlé et respecter l''éthique de l''antenne — à Radio Figuier, entre la rumeur du Marché des Lampions et la nouvelle vérifiée de la rivière, au Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'B1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Lire une source =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Lire une source'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Lire une source', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Quelle source à l''antenne ?',
    'CO',
    $c$Objectif
Analyser une source : média traditionnel ou voix du marché ; concession et passif.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Quelle source est vérifiée ?

Support — Studio de Radio Figuier, casque de Léa
Léa : J'ai lu la Feuille du Seuil. C'est une source écrite, pesée par Lila.
Marc : Au Marché des Lampions, une voix a couru sans nom. Ce n'est pas une source.
Aline : Un média traditionnel, ici, c'est Radio Figuier ou la Feuille du Seuil.
Patrick : Un média social de la cour, c'est une phrase répétée de banc en banc.
Hawa : Bien que la rumeur circule, la crue n'a pas été confirmée.
Joël : Pourtant, le marché était inquiet dès l'aube.
Lila : Cependant, chaque fait a été pesé avant l'antenne.
Karim : Néanmoins, on relatera seulement ce qui a été vu à la rivière.
Solange : La nouvelle a été lue à sept heures. Elle a été reprise par Hawa.
Mado : D'après le Bureau des Escales, le pont des Herbes tient encore.
Sami : Selon Dieudonné, l'eau est haute, mais la cour n'est pas inondée.
Dieudonné : Rien n'a été inventé : le niveau a été mesuré ce matin.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa dit que la crue a été confirmée.",
  "correct": false,
  "explanation": "Hawa : « la crue n'a pas été confirmée. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Aline, un média traditionnel du Seuil, c'est…",
  "options": [
    {
      "text": "une voix sans nom au marché",
      "correct": false
    },
    {
      "text": "Radio Figuier ou la Feuille du Seuil",
      "correct": true
    },
    {
      "text": "un cri sous le figuier",
      "correct": false
    },
    {
      "text": "un message inventé",
      "correct": false
    }
  ],
  "explanation": "Aline nomme Radio Figuier et la Feuille du Seuil."
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
      "left": "bien que + subjonctif",
      "right": "Hawa / circule"
    },
    {
      "left": "pourtant",
      "right": "Joël"
    },
    {
      "left": "cependant",
      "right": "Lila"
    },
    {
      "left": "néanmoins",
      "right": "Karim"
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
  "prompt": "Complétez :\nBien que la rumeur ___, la crue n'a pas été confirmée.",
  "answer": "circule"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "La",
    "nouvelle",
    "a",
    "été",
    "lue",
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
  "word": "pourtant",
  "hint": "Joël l'emploie : un lien d'opposition, pas bien que."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que la rumeur circule, la crue a confirmé ce matin.",
  "correct_sentence": "Bien que la rumeur circule, la crue n'a pas été confirmée.",
  "explanation": "Passif : a été confirmée. Hawa nie la crue."
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
      "image_path": "/elearning/mfk-b1-m6/source-info.svg",
      "word": "une source"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/concession.svg",
      "word": "une concession"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/voix-passive.svg",
      "word": "la voix passive"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/deux-medias.svg",
      "word": "deux médias"
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
  "prompt": "Notez deux sources vérifiées et deux voix non vérifiées."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Bien que la rumeur circule, le fait a été pesé. Pourtant le marché était inquiet."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Deux colonnes au tableau',
    'CE',
    $c$Objectif
Lire une analyse de sources : médias de la cour contre voix du marché.

Consigne
Lisez le tableau, sans aller trop vite.

Support — Tableau ocre, Salle des Herbes
Feuille d'Aline Uwase — Lire une source
Colonne 1 — médias de la cour : Radio Figuier, Feuille du Seuil, Bureau des Escales.
Colonne 2 — voix du marché : une phrase sans auteur, un cri répété, un geste inquiet.
On relate un fait : on dit ce qui a été vu, mesuré, signé.
On ne relate pas une peur : on la nomme comme rumeur.
Bien que le marché parle fort, le niveau a été mesuré par Dieudonné.
Pourtant certains bancs restent tendus.
Cependant Lila n'ouvrira l'antenne que sur un fait pesé.
Néanmoins Karim notera la rumeur à part, dans le Cahier du chemin.
Règle : bien que + subjonctif ; pourtant / cependant / néanmoins + indicatif.
Passif : le niveau a été mesuré ; la nouvelle a été lue.
Seuil des Sources — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Karim jette la rumeur : il ne la note pas.",
  "correct": false,
  "explanation": "« Karim notera la rumeur à part, dans le Cahier du chemin. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a mesuré le niveau de l'eau ?",
  "options": [
    {
      "text": "Marc",
      "correct": false
    },
    {
      "text": "Mado",
      "correct": false
    },
    {
      "text": "Dieudonné",
      "correct": true
    },
    {
      "text": "Sami",
      "correct": false
    }
  ],
  "explanation": "« mesuré par Dieudonné. »"
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
      "left": "Radio Figuier",
      "right": "média de la cour"
    },
    {
      "left": "phrase sans auteur",
      "right": "voix du marché"
    },
    {
      "left": "bien que",
      "right": "subjonctif"
    },
    {
      "left": "pourtant",
      "right": "indicatif"
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
  "prompt": "Complétez :\nBien que le marché parle fort, le niveau ___ été mesuré.",
  "answer": "a"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "La",
    "nouvelle",
    "a",
    "été",
    "lue",
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
  "word": "cependant",
  "hint": "Lila l'écrit : un autre mot de concession, pas pourtant."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que le marché parle fort, le niveau a mesurer par Dieudonné.",
  "correct_sentence": "Bien que le marché parle fort, le niveau a été mesuré par Dieudonné.",
  "explanation": "Passif : a été mesuré."
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
      "image_path": "/elearning/mfk-b1-m6/concession.svg",
      "word": "une concession"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/voix-passive.svg",
      "word": "un passif"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/deux-medias.svg",
      "word": "deux médias"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/recit-journal.svg",
      "word": "un récit"
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
  "prompt": "Recopiez les deux colonnes et ajoutez une source de la cour."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les deux colonnes, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Relater sans céder à la rumeur',
    'PO',
    $c$Objectif
Relater un fait à l'oral : concession et voix passive.

Consigne
Répétez les modèles, puis relatez un fait du Seuil.

Support — Modèles de Lila Sow
Bien que la rumeur circule, le pont tient.
Pourtant le marché était inquiet.
Cependant le fait a été vérifié.
Néanmoins on ouvrira l'antenne à huit heures.
La nouvelle a été lue par Hawa.
Le niveau a été mesuré ce matin.
Rien n'a été inventé.
On relatera seulement ce qui a été vu.
D'après Solange, le dossier est clair.
Selon Dieudonné, l'eau est haute.
Ce n'est pas une source : c'est une voix sans nom.
Radio Figuier pèse chaque phrase.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Bien que » demande le subjonctif.",
  "correct": true,
  "explanation": "Bien que la rumeur circule."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est au passif ?",
  "options": [
    {
      "text": "Le pont tient",
      "correct": false
    },
    {
      "text": "Le marché était inquiet",
      "correct": false
    },
    {
      "text": "Le niveau a été mesuré",
      "correct": true
    },
    {
      "text": "On ouvrira l'antenne",
      "correct": false
    }
  ],
  "explanation": "A été + participe."
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
      "left": "bien que",
      "right": "subjonctif"
    },
    {
      "left": "pourtant",
      "right": "opposition"
    },
    {
      "left": "a été lue",
      "right": "passif"
    },
    {
      "left": "d'après",
      "right": "source nommée"
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
  "prompt": "Complétez :\nLe niveau ___ été mesuré ce matin.",
  "answer": "a"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Rien",
    "n'a",
    "été",
    "inventé",
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
  "word": "neanmoins",
  "hint": "Karim l'emploie : concession, sans accent."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que la rumeur circule, le fait a vérifier hier.",
  "correct_sentence": "Bien que la rumeur circule, le fait a été vérifié.",
  "explanation": "Passif : a été vérifié."
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
      "image_path": "/elearning/mfk-b1-m6/voix-passive.svg",
      "word": "un passif"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/deux-medias.svg",
      "word": "deux médias"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/recit-journal.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/faits-passes.svg",
      "word": "un fait passé"
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
  "prompt": "Écrivez six phrases : deux bien que, deux pourtant, deux passifs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis deux faits relatés à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma note de source',
    'PE',
    $c$Objectif
Écrire une courte analyse de source avec concession et passif.

Consigne
Imitez la note de Patrick, sans aller trop vite.

Support — Note de Patrick Habimana, Cahier du chemin
Patrick Habimana
J'ai lu deux sources ce matin.
La Feuille du Seuil a été signée par Solange. C'est une source.
Au Marché des Lampions, une voix a couru sans nom. Ce n'est pas une source.
Bien que le marché parle fort, la crue n'a pas été confirmée.
Pourtant les paniers étaient déjà plus hauts.
Cependant le niveau a été mesuré par Dieudonné.
Néanmoins je relaterai seulement le chiffre vu à la rivière.
Patrick
Radio Figuier — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick traite la voix du marché comme une source signée.",
  "correct": false,
  "explanation": "« Ce n'est pas une source. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a signé la Feuille du Seuil ?",
  "options": [
    {
      "text": "Lila",
      "correct": false
    },
    {
      "text": "Hawa",
      "correct": false
    },
    {
      "text": "Solange",
      "correct": true
    },
    {
      "text": "Marc",
      "correct": false
    }
  ],
  "explanation": "« signée par Solange. »"
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
      "left": "Feuille du Seuil",
      "right": "source"
    },
    {
      "left": "voix sans nom",
      "right": "pas une source"
    },
    {
      "left": "bien que",
      "right": "marché / crue"
    },
    {
      "left": "a été mesuré",
      "right": "Dieudonné"
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
  "prompt": "Complétez :\nBien que le marché parle fort, la crue n'a pas ___ confirmée.",
  "answer": "été"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Pourtant",
    "les",
    "paniers",
    "étaient",
    "déjà",
    "plus",
    "hauts",
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
  "word": "relaterai",
  "hint": "Patrick le fera : dire le fait, au futur."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La Feuille du Seuil a signé par Solange ce matin.",
  "correct_sentence": "La Feuille du Seuil a été signée par Solange.",
  "explanation": "Passif féminin : a été signée."
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
      "image_path": "/elearning/mfk-b1-m6/deux-medias.svg",
      "word": "deux médias"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/recit-journal.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/faits-passes.svg",
      "word": "un fait passé"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/titre-une.svg",
      "word": "un titre"
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
  "prompt": "Imitez : huit lignes, une concession, deux passifs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre note, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Concession et voix passive',
    'EL',
    $c$Objectif
Retenir bien que + subjonctif, pourtant / cependant / néanmoins, et le passif.

Consigne
Apprenez la fiche.

Support — Fiche du studio
Concession
bien que + subjonctif : Bien que la rumeur circule, on ouvre l'antenne.
pourtant / cependant / néanmoins + indicatif : Pourtant le marché était inquiet.
On ne dit pas : bien que la rumeur circule pas (oubli du subjonctif juste).
Voix passive
Actif : Dieudonné a mesuré le niveau.
Passif : Le niveau a été mesuré (par Dieudonné).
Accord : la nouvelle a été lue ; les faits ont été pesés.
Agent facultatif : par + personne.
Relater : dire ce qui a été vu, sans inventer.
Média de la cour ≠ voix du marché.
Au Seuil : Radio Figuier pèse ; le marché répète.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Après pourtant, on met le subjonctif.",
  "correct": false,
  "explanation": "Pourtant + indicatif. Le subjonctif suit bien que."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Dieudonné a mesuré le niveau » au passif, c'est…",
  "options": [
    {
      "text": "Dieudonné a été mesuré par le niveau",
      "correct": false
    },
    {
      "text": "Le niveau a mesuré Dieudonné",
      "correct": false
    },
    {
      "text": "Le niveau a été mesuré par Dieudonné",
      "correct": true
    },
    {
      "text": "Le niveau est mesurer",
      "correct": false
    }
  ],
  "explanation": "Objet → sujet. Agent : par."
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
      "left": "bien que",
      "right": "subjonctif"
    },
    {
      "left": "pourtant",
      "right": "indicatif"
    },
    {
      "left": "être + PP",
      "right": "passif"
    },
    {
      "left": "par",
      "right": "agent"
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
  "prompt": "Complétez :\nBien que la rumeur ___, on ouvre l'antenne.",
  "answer": "circule"
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
    "niveau",
    "a",
    "été",
    "mesuré",
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
  "word": "indicatif",
  "hint": "Le mode après pourtant, cependant, néanmoins."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que la rumeur circule, le niveau a mesurer ce matin.",
  "correct_sentence": "Bien que la rumeur circule, le niveau a été mesuré.",
  "explanation": "Passif : a été mesuré."
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
      "image_path": "/elearning/mfk-b1-m6/recit-journal.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/faits-passes.svg",
      "word": "un fait passé"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/titre-une.svg",
      "word": "un titre"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/carnet-reporter.svg",
      "word": "un carnet"
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
  "prompt": "Tableau : six phrases, concession à gauche, passif à droite."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six phrases modèles."
}$j$::jsonb,
    9
  );

  -- ===== Écrire un fait divers =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Écrire un fait divers'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Écrire un fait divers', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Hier à la rivière',
    'CO',
    $c$Objectif
Repérer le récit : imparfait (cadre), PC (faits), PQP (avant) ; on a annoncé que.

Consigne
Lisez le dialogue. Quel temps pour le cadre, quel temps pour l'événement ?

Support — Rive ocre, carnet de Marc
Marc : Hier, le ciel était gris. L'eau montait déjà.
Léa : On a annoncé que le pont des Herbes restait ouvert.
Aline : Avant l'aube, Dieudonné avait mesuré le niveau.
Patrick : Les paniers étaient plus hauts. Puis Mado a déplacé le stand.
Hawa : On a annoncé que personne n'avait dormi sous la rive.
Joël : Sami a porté deux seaux. Il avait préparé les cordes la veille.
Lila : Le studio était calme. Ensuite Hawa a lu le bulletin.
Karim : On a annoncé que la cour n'était pas inondée.
Solange : J'avais tamponné la feuille avant que Lila n'ouvre l'antenne.
Mado : Le marché bruissait. Puis la voix sans nom s'est tue.
Sami : J'ai frappé le tambour une fois : le Seuil a écouté.
Dieudonné : J'avais noué la corde. Ensuite j'ai fixé la marque sur le pieu.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné avait mesuré le niveau avant l'aube : c'est un plus-que-parfait.",
  "correct": true,
  "explanation": "Aline : « avait mesuré » — avant le moment du récit."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel temps pose le cadre « le ciel était gris » ?",
  "options": [
    {
      "text": "passé composé",
      "correct": false
    },
    {
      "text": "imparfait",
      "correct": true
    },
    {
      "text": "plus-que-parfait",
      "correct": false
    },
    {
      "text": "futur",
      "correct": false
    }
  ],
  "explanation": "Imparfait : cadre, description."
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
      "left": "était gris",
      "right": "imparfait / cadre"
    },
    {
      "left": "a annoncé",
      "right": "passé composé"
    },
    {
      "left": "avait mesuré",
      "right": "plus-que-parfait"
    },
    {
      "left": "a lu",
      "right": "fait du bulletin"
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
  "prompt": "Complétez :\nOn ___ annoncé que le pont restait ouvert.",
  "answer": "a"
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
    "a",
    "annoncé",
    "que",
    "le",
    "pont",
    "restait",
    "ouvert",
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
  "hint": "L'imparfait le pose : ciel, eau, marché."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Hier, le ciel a été gris pendant que l'eau montait déjà depuis longtemps.",
  "correct_sentence": "Hier, le ciel était gris pendant que l'eau montait déjà depuis longtemps.",
  "explanation": "Cadre : imparfait (était), pas a été."
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
      "image_path": "/elearning/mfk-b1-m6/faits-passes.svg",
      "word": "un fait passé"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/titre-une.svg",
      "word": "un titre"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/carnet-reporter.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/fausse-info.svg",
      "word": "une rumeur"
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
  "prompt": "Classez six verbes : imparfait / PC / PQP."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Le ciel était gris. On a annoncé que le pont restait ouvert. Dieudonné avait mesuré."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fait divers de la rive',
    'CE',
    $c$Objectif
Lire un récit journalistique au passé.

Consigne
Lisez le fait divers, sans aller trop vite.

Support — Feuille de une, Radio Figuier
Fait divers — La rive a tenu
Hier matin, le marché était déjà ouvert. L'eau montait le long des pieux.
On a annoncé que le pont des Herbes restait praticable.
Avant l'ouverture, Dieudonné avait marqué le niveau sur le bois.
Mado a relevé les paniers. Elle avait noué les toiles la veille.
Sami a frappé le tambour. La cour a cessé de courir.
Lila a lu le bulletin à huit heures. Rien n'avait été inventé.
Selon Solange, le dossier de la rive avait été tamponné à l'aube.
Pourtant une voix sans nom avait couru au Marché des Lampions.
Cependant le chiffre mesuré a calmé les bancs.
Radio Figuier — Rukiri-Nord
Prochaine une : le soir, si l'eau change.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado avait noué les toiles la veille : l'action est antérieure.",
  "correct": true,
  "explanation": "Plus-que-parfait : avant le relevage des paniers."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À quelle heure Lila a-t-elle lu le bulletin ?",
  "options": [
    {
      "text": "à l'aube",
      "correct": false
    },
    {
      "text": "à midi",
      "correct": false
    },
    {
      "text": "à huit heures",
      "correct": true
    },
    {
      "text": "à minuit",
      "correct": false
    }
  ],
  "explanation": "« Lila a lu le bulletin à huit heures. »"
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
      "left": "était ouvert",
      "right": "imparfait"
    },
    {
      "left": "a relevé",
      "right": "passé composé"
    },
    {
      "left": "avait marqué",
      "right": "plus-que-parfait"
    },
    {
      "left": "on a annoncé que",
      "right": "relais du fait"
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
  "prompt": "Complétez :\nDieudonné ___ marqué le niveau sur le bois.",
  "answer": "avait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Mado",
    "a",
    "relevé",
    "les",
    "paniers",
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
  "word": "praticable",
  "hint": "Le pont restait… : on pouvait encore passer."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dieudonné a marqué le niveau avant l'ouverture déjà depuis la nuit.",
  "correct_sentence": "Avant l'ouverture, Dieudonné avait marqué le niveau sur le bois.",
  "explanation": "Antériorité : plus-que-parfait."
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
      "image_path": "/elearning/mfk-b1-m6/titre-une.svg",
      "word": "un titre"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/carnet-reporter.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/fausse-info.svg",
      "word": "une rumeur"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/rumeur-marche.svg",
      "word": "le marché"
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
  "prompt": "Recopiez le fait divers et soulignez PC, imparfait, PQP."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le fait divers, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Raconter hier',
    'PO',
    $c$Objectif
Rapporter des faits passés à l'oral avec les trois temps.

Consigne
Répétez, puis racontez un fait de la cour.

Support — Modèles de Hawa Diallo
Le marché était ouvert.
L'eau montait.
On a annoncé que le pont tenait.
Dieudonné avait mesuré le niveau.
Mado a relevé les paniers.
Elle avait noué les toiles.
Sami a frappé le tambour.
Lila a lu le bulletin.
Rien n'avait été inventé.
La cour a écouté.
Le ciel était gris.
Puis le soleil a percé.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« On a annoncé que » introduit un fait rapporté.",
  "correct": true,
  "explanation": "On = la rédaction. Que + phrase au passé."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Elle avait noué les toiles » situe l'action…",
  "options": [
    {
      "text": "après le relevage",
      "correct": false
    },
    {
      "text": "en même temps que le ciel",
      "correct": false
    },
    {
      "text": "avant le relevage",
      "correct": true
    },
    {
      "text": "au futur",
      "correct": false
    }
  ],
  "explanation": "Plus-que-parfait : avant."
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
      "left": "était / montait",
      "right": "cadre"
    },
    {
      "left": "a annoncé / a lu",
      "right": "événements"
    },
    {
      "left": "avait mesuré",
      "right": "avant"
    },
    {
      "left": "on a annoncé que",
      "right": "relais"
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
  "prompt": "Complétez :\nElle ___ noué les toiles la veille.",
  "answer": "avait"
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
    "a",
    "annoncé",
    "que",
    "le",
    "pont",
    "tenait",
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
  "word": "bulletin",
  "hint": "Hawa ou Lila le lit à l'antenne."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On a annoncé que Dieudonné mesure le niveau hier avant l'aube.",
  "correct_sentence": "On a annoncé que Dieudonné avait mesuré le niveau.",
  "explanation": "Fait antérieur : plus-que-parfait."
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
      "image_path": "/elearning/mfk-b1-m6/carnet-reporter.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/fausse-info.svg",
      "word": "une rumeur"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/rumeur-marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/loupe-verite.svg",
      "word": "une loupe"
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
  "prompt": "Écrivez un récit de huit phrases : 3 imparfaits, 3 PC, 2 PQP."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis votre récit d'hier."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon fait divers',
    'PE',
    $c$Objectif
Écrire un récit journalistique au passé.

Consigne
Imitez le fait de Rose, sans aller trop vite.

Support — Fait de Rose Iradukunda
Rose Iradukunda
Hier, la Table des Sources était encore humide.
On a annoncé que personne n'avait glissé.
Joël avait posé deux nattes avant l'ouverture.
Puis Léa a essuyé le banc. Marc a noté l'heure.
Le figuier donnait peu d'ombre. Le vent poussait les feuilles.
Hawa a lu trois phrases. Rien n'avait été ajouté.
Pourtant une voix du marché avait parlé d'une chute.
Cependant aucun témoin n'a confirmé.
Rose
Feuille de une — Radio Figuier
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Un témoin a confirmé la chute.",
  "correct": false,
  "explanation": "« aucun témoin n'a confirmé. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui avait posé les nattes ?",
  "options": [
    {
      "text": "Léa",
      "correct": false
    },
    {
      "text": "Marc",
      "correct": false
    },
    {
      "text": "Joël",
      "correct": true
    },
    {
      "text": "Hawa",
      "correct": false
    }
  ],
  "explanation": "« Joël avait posé deux nattes. »"
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
      "left": "était humide",
      "right": "imparfait"
    },
    {
      "left": "a essuyé",
      "right": "passé composé"
    },
    {
      "left": "avait posé",
      "right": "plus-que-parfait"
    },
    {
      "left": "on a annoncé que",
      "right": "ouverture du récit"
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
  "prompt": "Complétez :\nOn a annoncé que personne n'___ glissé.",
  "answer": "avait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Léa",
    "a",
    "essuyé",
    "le",
    "banc",
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
  "word": "temoin",
  "hint": "Aucun… n'a confirmé (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Joël a posé deux nattes avant l'ouverture déjà la veille au soir.",
  "correct_sentence": "Joël avait posé deux nattes avant l'ouverture.",
  "explanation": "Antériorité : plus-que-parfait."
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
      "image_path": "/elearning/mfk-b1-m6/fausse-info.svg",
      "word": "une rumeur"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/rumeur-marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/loupe-verite.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/tampon-verifie.svg",
      "word": "un tampon"
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
  "prompt": "Imitez : dix lignes, les trois temps, une phrase on a annoncé que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre fait divers, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — PC, imparfait, plus-que-parfait',
    'EL',
    $c$Objectif
Retenir le rôle de chaque temps dans un récit journalistique.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
Imparfait : cadre, description, habitude du moment.
Le marché était ouvert. L'eau montait.
Passé composé : faits, événements, ce qui fait avancer le récit.
Mado a relevé les paniers. Hawa a lu le bulletin.
Plus-que-parfait : une action déjà faite avant un autre passé.
Dieudonné avait mesuré. Elle avait noué les toiles.
On a annoncé que + phrase : relais du fait (souvent imparfait ou PQP dans que).
On a annoncé que le pont restait ouvert.
On a annoncé que personne n'avait dormi sous la rive.
Pas : on a annoncé que Dieudonné mesure hier.
Ordre utile : cadre (imp.) → avant (PQP) → faits (PC).
Radio Figuier raconte ainsi la rive.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le plus-que-parfait place un fait avant un autre passé.",
  "correct": true,
  "explanation": "Avoir / être à l'imparfait + participe."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pour le cadre « le ciel… gris », on dit…",
  "options": [
    {
      "text": "le ciel a été gris",
      "correct": false
    },
    {
      "text": "le ciel était gris",
      "correct": true
    },
    {
      "text": "le ciel avait été gris seulement",
      "correct": false
    },
    {
      "text": "le ciel sera gris",
      "correct": false
    }
  ],
  "explanation": "Imparfait de description."
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
      "left": "imparfait",
      "right": "cadre"
    },
    {
      "left": "passé composé",
      "right": "événement"
    },
    {
      "left": "plus-que-parfait",
      "right": "avant"
    },
    {
      "left": "on a annoncé que",
      "right": "relais"
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
  "prompt": "Complétez :\nDieudonné ___ mesuré le niveau avant l'aube.",
  "answer": "avait"
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
    "marché",
    "était",
    "ouvert",
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
  "word": "evenement",
  "hint": "Le PC le raconte (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On a annoncé que Dieudonné mesure le niveau hier à l'aube.",
  "correct_sentence": "On a annoncé que Dieudonné avait mesuré le niveau.",
  "explanation": "Dans que, le fait antérieur se met au plus-que-parfait."
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
      "image_path": "/elearning/mfk-b1-m6/rumeur-marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/loupe-verite.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/tampon-verifie.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/mise-en-evidence.svg",
      "word": "une mise en évidence"
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
  "prompt": "Transformez six phrases : cadre, avant, événement."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six phrases aux trois temps."
}$j$::jsonb,
    9
  );

  -- ===== Démasquer une rumeur =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Démasquer une rumeur'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Démasquer une rumeur', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Il paraît, on confirme',
    'CO',
    $c$Objectif
Distinguer rumeur et fait : d'après, selon, il paraît que / il a été confirmé que.

Consigne
Lisez le dialogue. Qui vérifie ? Qui répète ?

Support — Marché des Lampions, banc de Mado
Mado : Il paraît que le pont s'est cassé. Je n'ai rien vu.
Sami : Selon un passant, l'eau a tout pris. Il n'a pas donné son nom.
Léa : D'après Dieudonné, le pont tient. Il a montré la marque.
Marc : Il a été confirmé que le niveau est haut, pas que le pont est rompu.
Aline : Il paraît que n'est pas une preuve. C'est une rumeur.
Patrick : Selon la Feuille du Seuil, la rive est praticable.
Hawa : D'après Solange, le dossier a été tamponné.
Joël : Il paraît que Joël a fui. C'est faux : je suis là.
Lila : Il a été confirmé que personne n'a quitté la cour.
Karim : J'écris : rumeur d'un côté, fait de l'autre.
Yvette : Selon l'infirmerie, aucun blessé n'a été reçu.
Dieudonné : Venez voir le pieu. Le bois n'a pas cédé.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il paraît que le pont s'est cassé » est présenté comme une preuve.",
  "correct": false,
  "explanation": "Mado n'a rien vu. Aline : ce n'est pas une preuve."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui montre la marque sur le pont ?",
  "options": [
    {
      "text": "Sami",
      "correct": false
    },
    {
      "text": "Dieudonné",
      "correct": true
    },
    {
      "text": "Joël",
      "correct": false
    },
    {
      "text": "Karim",
      "correct": false
    }
  ],
  "explanation": "Léa : « D'après Dieudonné… Il a montré la marque. »"
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
      "left": "il paraît que",
      "right": "rumeur"
    },
    {
      "left": "il a été confirmé que",
      "right": "fait pesé"
    },
    {
      "left": "d'après Dieudonné",
      "right": "source nommée"
    },
    {
      "left": "selon un passant",
      "right": "source faible"
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
  "prompt": "Complétez :\nIl ___ que le pont s'est cassé. Je n'ai rien vu.",
  "answer": "paraît"
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
    "a",
    "été",
    "confirmé",
    "que",
    "le",
    "niveau",
    "est",
    "haut",
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
  "word": "parait",
  "hint": "Il… que : rumeur, sans accent."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il a été confirmé que le pont s'est cassé, d'après Mado qui n'a rien vu.",
  "correct_sentence": "Il paraît que le pont s'est cassé, d'après Mado qui n'a rien vu.",
  "explanation": "Sans preuve, on dit il paraît que, pas il a été confirmé que."
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
      "image_path": "/elearning/mfk-b1-m6/loupe-verite.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/tampon-verifie.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/mise-en-evidence.svg",
      "word": "une mise en évidence"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/micro-public.svg",
      "word": "un micro"
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
  "prompt": "Classez six phrases : rumeur / fait confirmé."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il paraît que… D'après Dieudonné… Il a été confirmé que…"
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Deux versions au figuier',
    'CE',
    $c$Objectif
Lire une rumeur et sa vérification.

Consigne
Lisez les deux versions, sans aller trop vite.

Support — Affiche ocre, tronc du figuier
Version A — voix du Marché des Lampions
Il paraît que le pont des Herbes s'est ouvert en deux.
Selon un panier anonyme, l'eau a emporté une barque.
D'après « on », Sami a cessé de frapper par peur.
Version B — vérification de Radio Figuier
Il a été confirmé que le pont tient : Dieudonné a montré le pieu.
Selon la Feuille du Seuil, aucune barque n'a disparu.
D'après Sami, le tambour a sonné pour rassembler, pas pour fuir.
Règle : d'après / selon + une source qu'on nomme.
Il paraît que = on répète sans preuve.
Il a été confirmé que = un fait a été pesé.
Karim a collé les deux versions. La cour a choisi B.
Cahier du chemin — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La version B dit qu'une barque a disparu.",
  "correct": false,
  "explanation": "« aucune barque n'a disparu. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi Sami a-t-il frappé, d'après la version B ?",
  "options": [
    {
      "text": "par peur",
      "correct": false
    },
    {
      "text": "pour vendre un panier",
      "correct": false
    },
    {
      "text": "pour rassembler",
      "correct": true
    },
    {
      "text": "pour fermer Radio Figuier",
      "correct": false
    }
  ],
  "explanation": "« pour rassembler, pas pour fuir. »"
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
      "left": "il paraît que",
      "right": "version A"
    },
    {
      "left": "il a été confirmé que",
      "right": "version B"
    },
    {
      "left": "panier anonyme",
      "right": "source faible"
    },
    {
      "left": "Dieudonné / pieu",
      "right": "preuve"
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
  "prompt": "Complétez :\nIl a été ___ que le pont tient.",
  "answer": "confirmé"
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
    "paraît",
    "que",
    "le",
    "pont",
    "tient",
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
  "word": "anonyme",
  "hint": "Un panier sans nom : source…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il a été confirmé que le pont s'est ouvert en deux, version A sans preuve.",
  "correct_sentence": "Il a été confirmé que le pont tient : Dieudonné a montré le pieu.",
  "explanation": "La confirmation suit la preuve, pas la rumeur."
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
      "image_path": "/elearning/mfk-b1-m6/tampon-verifie.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/mise-en-evidence.svg",
      "word": "une mise en évidence"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/micro-public.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/argumenter.svg",
      "word": "un argument"
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
  "prompt": "Recopiez B et barre d'une croix chaque phrase de A."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez A puis B, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Nommer la source',
    'PO',
    $c$Objectif
Vérifier à l'oral : d'après, selon, il paraît que, il a été confirmé que.

Consigne
Répétez, puis corrigez une rumeur de la cour.

Support — Modèles de Karim
Il paraît que le pont est rompu.
D'après Dieudonné, le pont tient.
Selon Solange, le dossier est clair.
Il a été confirmé que la cour est sèche.
Il paraît que Joël a fui.
Selon Joël, il est resté.
D'après Yvette, aucun blessé n'est venu.
Il a été confirmé que le tambour rassemblait.
Ce n'est pas une preuve.
C'est une voix sans nom.
Je vérifie avant l'antenne.
Je nomme ma source.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Selon » doit être suivi d'une source qu'on peut nommer.",
  "correct": true,
  "explanation": "Selon Solange, selon Joël — pas selon on."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle formule pèse un fait ?",
  "options": [
    {
      "text": "il paraît que",
      "correct": false
    },
    {
      "text": "on dit que",
      "correct": false
    },
    {
      "text": "il a été confirmé que",
      "correct": true
    },
    {
      "text": "quelqu'un a crié que",
      "correct": false
    }
  ],
  "explanation": "Confirmation = fait pesé."
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
      "left": "il paraît que",
      "right": "sans preuve"
    },
    {
      "left": "d'après",
      "right": "source"
    },
    {
      "left": "selon",
      "right": "source"
    },
    {
      "left": "il a été confirmé que",
      "right": "fait"
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
  "prompt": "Complétez :\n___ Solange, le dossier est clair.",
  "answer": "Selon"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Je",
    "nomme",
    "ma",
    "source",
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
  "word": "verifier",
  "hint": "Karim le fait avant l'antenne (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Selon on, le pont tient vraiment ce matin.",
  "correct_sentence": "D'après Dieudonné, le pont tient.",
  "explanation": "Selon / d'après + une personne ou un écrit, pas on."
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
      "image_path": "/elearning/mfk-b1-m6/mise-en-evidence.svg",
      "word": "une mise en évidence"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/micro-public.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/argumenter.svg",
      "word": "un argument"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/pupitre-marc.svg",
      "word": "un pupitre"
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
  "prompt": "Écrivez huit phrases : 3 il paraît, 3 d'après/selon, 2 confirmé."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis une rumeur corrigée."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma vérification',
    'PE',
    $c$Objectif
Écrire une note qui démasque une rumeur.

Consigne
Imitez la note de Léa, sans aller trop vite.

Support — Note de Léa Niyonzima
Léa Niyonzima
Il paraît que la Table des Sources a disparu sous l'eau.
D'après Félicie, la table était seulement humide.
Selon Joël, deux nattes avaient été posées.
Il a été confirmé que personne n'a glissé.
La rumeur partait du Marché des Lampions.
La preuve venait de la cour et de l'infirmerie.
Je n'écrirai pas « il paraît » à l'antenne sans nom.
Je peux écrire « selon Yvette » ou « d'après Félicie ».
Léa
Cahier du chemin — Radio Figuier
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa veut dire « il paraît » à l'antenne sans nommer personne.",
  "correct": false,
  "explanation": "« Je n'écrirai pas « il paraît » à l'antenne sans nom. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon qui les nattes avaient-elles été posées ?",
  "options": [
    {
      "text": "Félicie",
      "correct": false
    },
    {
      "text": "Yvette",
      "correct": false
    },
    {
      "text": "Joël",
      "correct": true
    },
    {
      "text": "Mado",
      "correct": false
    }
  ],
  "explanation": "« Selon Joël, deux nattes avaient été posées. »"
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
      "left": "il paraît que",
      "right": "table disparue"
    },
    {
      "left": "d'après Félicie",
      "right": "table humide"
    },
    {
      "left": "selon Joël",
      "right": "nattes"
    },
    {
      "left": "il a été confirmé que",
      "right": "personne n'a glissé"
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
  "prompt": "Complétez :\nIl a été ___ que personne n'a glissé.",
  "answer": "confirmé"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "D'après",
    "Félicie",
    "la",
    "table",
    "était",
    "humide",
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
  "word": "infirmerie",
  "hint": "Yvette y reçoit : aucun blessé."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il a été confirmé que personne a glissé sous la Table des Sources.",
  "correct_sentence": "Il a été confirmé que personne n'a glissé sous la Table des Sources.",
  "explanation": "Personne… n'a : la négation ne disparaît pas."
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
      "image_path": "/elearning/mfk-b1-m6/micro-public.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/argumenter.svg",
      "word": "un argument"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/pupitre-marc.svg",
      "word": "un pupitre"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/journal-parle.svg",
      "word": "un journal"
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
  "prompt": "Imitez : une rumeur, deux sources nommées, une confirmation."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre vérification, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — D''après, selon, il paraît, confirmé',
    'EL',
    $c$Objectif
Retenir les formules qui pèsent ou qui répètent.

Consigne
Apprenez la fiche.

Support — Fiche de Lila
Rumeur
il paraît que + indicatif : on répète, on n'a pas vu.
on dit que : même prudence.
Fait pesé
il a été confirmé que + indicatif : une preuve existe.
Source nommée
d'après + nom : D'après Dieudonné, le pont tient.
selon + nom : Selon Solange, le dossier est clair.
On évite : selon on / d'après les gens.
On peut écrire la rumeur à part, dans le Cahier du chemin.
On ne la lit pas comme une une.
Au Seuil : le marché répète ; Radio Figuier nomme.
Vérifier = aller voir, demander, comparer deux versions.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« D'après les gens » est une source assez nommée.",
  "correct": false,
  "explanation": "On nomme une personne ou un écrit."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle formule introduit une rumeur ?",
  "options": [
    {
      "text": "il a été confirmé que",
      "correct": false
    },
    {
      "text": "d'après Dieudonné",
      "correct": false
    },
    {
      "text": "il paraît que",
      "correct": true
    },
    {
      "text": "selon la Feuille du Seuil",
      "correct": false
    }
  ],
  "explanation": "Il paraît que = sans preuve."
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
      "left": "il paraît que",
      "right": "rumeur"
    },
    {
      "left": "d'après + nom",
      "right": "source"
    },
    {
      "left": "selon + nom",
      "right": "source"
    },
    {
      "left": "il a été confirmé que",
      "right": "preuve"
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
  "prompt": "Complétez :\n___ Dieudonné, le pont tient.",
  "answer": "D'après"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Je",
    "vérifie",
    "avant",
    "l'antenne",
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
  "word": "preuve",
  "hint": "Sans elle, on ne confirme pas."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "D'après les gens du marché, il a été confirmé que le pont est rompu.",
  "correct_sentence": "D'après les gens du marché, il paraît que le pont est rompu.",
  "explanation": "Source floue : il paraît, pas il a été confirmé."
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
      "image_path": "/elearning/mfk-b1-m6/argumenter.svg",
      "word": "un argument"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/pupitre-marc.svg",
      "word": "un pupitre"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/journal-parle.svg",
      "word": "un journal"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/studio-radio.svg",
      "word": "un studio"
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
  "prompt": "Écrivez une mini-charte : 4 formules, 4 exemples du Seuil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et huit formules."
}$j$::jsonb,
    9
  );

  -- ===== Tenir le micro =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Tenir le micro'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Tenir le micro', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Ce qui compte, c''est le fait',
    'CO',
    $c$Objectif
Capter l'attention et argumenter : ce qui… c'est, c'est… que, ce que.

Consigne
Lisez le dialogue. Qu'est-ce qu'on met en avant ?

Support — Pupitre de Marc, studio Figuier
Marc : Ce qui inquiète le marché, c'est l'eau, pas le silence.
Léa : C'est le chiffre que nous lirons en premier.
Aline : Ce que je demande, c'est une phrase courte.
Patrick : Ce qui rassure, c'est une source nommée.
Hawa : C'est Dieudonné que j'ai interrogé, pas une voix sans nom.
Joël : Ce que le Seuil attend, c'est une heure claire.
Lila : Ce qui ouvre l'antenne, c'est le salut, puis le fait.
Karim : C'est la rumeur que nous écarterons ensuite.
Solange : Ce que le Bureau confirme, c'est la praticabilité du pont.
Mado : Ce qui a calmé les paniers, c'est le tambour de Sami.
Sami : C'est pour rassembler que j'ai frappé, pas pour alarmer.
Dieudonné : Ce que j'ai montré, c'est la marque sur le pieu.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa a interrogé une voix sans nom.",
  "correct": false,
  "explanation": "« C'est Dieudonné que j'ai interrogé, pas une voix sans nom. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Lila, qu'est-ce qui ouvre l'antenne ?",
  "options": [
    {
      "text": "la rumeur",
      "correct": false
    },
    {
      "text": "le salut, puis le fait",
      "correct": true
    },
    {
      "text": "le tambour seul",
      "correct": false
    },
    {
      "text": "le silence",
      "correct": false
    }
  ],
  "explanation": "« Ce qui ouvre l'antenne, c'est le salut, puis le fait. »"
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
      "left": "ce qui… c'est",
      "right": "sujet mis en avant"
    },
    {
      "left": "c'est… que",
      "right": "complément mis en avant"
    },
    {
      "left": "ce que… c'est",
      "right": "objet mis en avant"
    },
    {
      "left": "c'est pour… que",
      "right": "but mis en avant"
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
  "prompt": "Complétez :\nCe qui rassure, ___ une source nommée.",
  "answer": "c'est"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "C'est",
    "le",
    "chiffre",
    "que",
    "nous",
    "lirons",
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
  "word": "rassure",
  "hint": "Patrick : ce qui… , c'est une source nommée."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ce qui rassure, c'est que une source nommée seulement.",
  "correct_sentence": "Ce qui rassure, c'est une source nommée.",
  "explanation": "Après c'est, le nom mis en avant, sans que inutile."
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
      "image_path": "/elearning/mfk-b1-m6/pupitre-marc.svg",
      "word": "un pupitre"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/journal-parle.svg",
      "word": "un journal"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/studio-radio.svg",
      "word": "un studio"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/horloge-antenne.svg",
      "word": "une horloge"
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
  "prompt": "Notez six mises en évidence entendues."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Ce qui rassure, c'est une source. C'est le chiffre que nous lirons. Ce que je demande, c'est une phrase courte."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Argument du matin',
    'CE',
    $c$Objectif
Lire un texte qui explique et argumente avec la mise en évidence.

Consigne
Lisez l'argument, sans aller trop vite.

Support — Feuille de Karim, groupe rédaction
Pourquoi lire le fait avant la rumeur
Ce qui capte l'oreille, c'est une phrase nette.
C'est le pont que nous plaçons en une, pas le cri du marché.
Ce que nous écartons, c'est la voix sans nom.
Argument 1 : une source nommée permet de vérifier.
Argument 2 : un chiffre mesuré calme mieux qu'un « il paraît ».
Argument 3 : le droit d'être entendu vient après le fait, pas à la place.
Ce qui unit la rédaction, c'est la charte de Radio Figuier.
C'est Lila que la cour écoute d'abord, puis Hawa.
Ce que Solange tamponne, c'est le dossier, pas la peur.
On explique : on dit pourquoi on a choisi cet ordre.
On argumente : on donne trois raisons, on conclut.
Studio Figuier — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La une place le cri du marché avant le pont.",
  "correct": false,
  "explanation": "« C'est le pont que nous plaçons en une, pas le cri du marché. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de raisons l'argument compte-t-il ?",
  "options": [
    {
      "text": "une",
      "correct": false
    },
    {
      "text": "deux",
      "correct": false
    },
    {
      "text": "trois",
      "correct": true
    },
    {
      "text": "cinq",
      "correct": false
    }
  ],
  "explanation": "Argument 1, 2 et 3."
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
      "left": "ce qui capte",
      "right": "phrase nette"
    },
    {
      "left": "c'est le pont que",
      "right": "une"
    },
    {
      "left": "ce que nous écartons",
      "right": "voix sans nom"
    },
    {
      "left": "trois raisons",
      "right": "argumenter"
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
  "prompt": "Complétez :\nCe qui unit la rédaction, ___ la charte de Radio Figuier.",
  "answer": "c'est"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "C'est",
    "le",
    "pont",
    "que",
    "nous",
    "plaçons",
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
  "word": "argumente",
  "hint": "On… : on donne des raisons."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ce qui capte l'oreille, c'est que une phrase nette seulement.",
  "correct_sentence": "Ce qui capte l'oreille, c'est une phrase nette.",
  "explanation": "Ce qui + verbe, c'est + nom."
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
      "image_path": "/elearning/mfk-b1-m6/journal-parle.svg",
      "word": "un journal"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/studio-radio.svg",
      "word": "un studio"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/horloge-antenne.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/casque-hawa.svg",
      "word": "un casque"
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
  "prompt": "Recopiez les trois arguments et ajoutez-en un."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'argument, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Mettre en avant',
    'PO',
    $c$Objectif
Expliquer et argumenter à l'oral avec ce qui, c'est… que, ce que.

Consigne
Répétez, puis mettez en avant un fait du Seuil.

Support — Modèles d'Aline
Ce qui compte, c'est le fait.
C'est le chiffre que je lis.
Ce que je refuse, c'est la rumeur.
C'est Dieudonné que j'interroge.
Ce qui calme, c'est une heure fixe.
C'est pour rassembler que Sami frappe.
Ce que Solange confirme, c'est le dossier.
C'est Lila qui ouvre l'antenne.
Ce qui unit, c'est la charte.
Je commence par le salut.
J'explique ensuite le choix.
Je conclus par l'heure du prochain bulletin.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« C'est Lila qui ouvre » met Lila en évidence.",
  "correct": true,
  "explanation": "C'est + nom + qui + verbe."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pour mettre un COD en avant, on dit souvent…",
  "options": [
    {
      "text": "ce qui… c'est",
      "correct": false
    },
    {
      "text": "c'est… que",
      "correct": true
    },
    {
      "text": "il paraît que",
      "correct": false
    },
    {
      "text": "bien que",
      "correct": false
    }
  ],
  "explanation": "C'est le chiffre que je lis."
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
      "left": "ce qui… c'est",
      "right": "sujet"
    },
    {
      "left": "c'est… que",
      "right": "COD / complément"
    },
    {
      "left": "c'est… qui",
      "right": "sujet nommé"
    },
    {
      "left": "c'est pour… que",
      "right": "but"
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
  "prompt": "Complétez :\nC'est le chiffre ___ je lis.",
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
    "Ce",
    "qui",
    "compte",
    "c'est",
    "le",
    "fait",
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
  "word": "evidence",
  "hint": "Mise en… : ce qui, c'est, ce que (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le chiffre qui je lis en premier à l'antenne.",
  "correct_sentence": "C'est le chiffre que je lis en premier à l'antenne.",
  "explanation": "COD : que, pas qui."
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
      "image_path": "/elearning/mfk-b1-m6/studio-radio.svg",
      "word": "un studio"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/horloge-antenne.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/casque-hawa.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/ethique-micro.svg",
      "word": "l'éthique"
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
  "prompt": "Transformez six phrases plates en mises en évidence."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis deux arguments à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon micro',
    'PE',
    $c$Objectif
Écrire un court argument pour l'antenne.

Consigne
Imitez le texte de Hawa, sans aller trop vite.

Support — Texte de Hawa Diallo
Hawa Diallo
Ce qui ouvre mon micro, c'est le nom de Radio Figuier.
C'est le niveau de la rivière que je lis d'abord.
Ce que j'écarte, c'est la voix sans nom du marché.
C'est Dieudonné que je cite, pas « on ».
Ce qui rassure la cour, c'est une phrase courte.
C'est pour informer que je parle, pas pour alarmer.
Je conclus : prochain bulletin à midi, même pieu, même règle.
Hawa
Journal parlé — Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa cite « on » comme source principale.",
  "correct": false,
  "explanation": "« C'est Dieudonné que je cite, pas « on ». »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que lit Hawa d'abord ?",
  "options": [
    {
      "text": "la voix du marché",
      "correct": false
    },
    {
      "text": "le niveau de la rivière",
      "correct": true
    },
    {
      "text": "un conte",
      "correct": false
    },
    {
      "text": "la charte entière",
      "correct": false
    }
  ],
  "explanation": "« C'est le niveau de la rivière que je lis d'abord. »"
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
      "left": "ce qui ouvre",
      "right": "nom de Radio Figuier"
    },
    {
      "left": "c'est le niveau que",
      "right": "d'abord"
    },
    {
      "left": "ce que j'écarte",
      "right": "voix sans nom"
    },
    {
      "left": "c'est pour informer que",
      "right": "but"
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
  "prompt": "Complétez :\nC'est Dieudonné ___ je cite, pas « on ».",
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
    "Ce",
    "que",
    "j'écarte",
    "c'est",
    "la",
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
  "word": "alarmer",
  "hint": "Hawa refuse : elle informe, elle ne veut pas…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le niveau de la rivière qui je lis d'abord.",
  "correct_sentence": "C'est le niveau de la rivière que je lis d'abord.",
  "explanation": "Lire quelque chose → que."
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
      "image_path": "/elearning/mfk-b1-m6/horloge-antenne.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/casque-hawa.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/ethique-micro.svg",
      "word": "l'éthique"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/droit-reponse.svg",
      "word": "un droit"
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
  "prompt": "Imitez : six mises en évidence, un but, une conclusion."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre texte de micro, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Ce qui, c''est… que, ce que',
    'EL',
    $c$Objectif
Retenir la mise en évidence pour argumenter.

Consigne
Apprenez la fiche.

Support — Fiche du pupitre
Mettre en avant le sujet
Ce qui + verbe, c'est + nom : Ce qui rassure, c'est une source.
C'est + nom + qui + verbe : C'est Lila qui ouvre.
Mettre en avant l'objet
C'est + nom + que + sujet + verbe : C'est le chiffre que je lis.
Ce que + sujet + verbe, c'est + nom : Ce que je refuse, c'est la rumeur.
But
C'est pour + infinitif + que : C'est pour rassembler que Sami frappe.
On n'écrit pas : c'est le chiffre qui je lis.
On n'écrit pas : ce qui rassure, c'est que une source.
Capter l'attention : phrase courte, puis raison.
Argumenter : trois raisons, une conclusion.
Au Seuil : le micro sert à expliquer, pas à crier.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Ce qui » reprend un sujet.",
  "correct": true,
  "explanation": "Ce qui rassure = la chose qui rassure."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Ce que je refuse, c'est la rumeur » met en avant…",
  "options": [
    {
      "text": "le sujet Lila",
      "correct": false
    },
    {
      "text": "l'objet rumeur",
      "correct": true
    },
    {
      "text": "un passif",
      "correct": false
    },
    {
      "text": "un imparfait",
      "correct": false
    }
  ],
  "explanation": "Ce que = ce que je refuse."
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
      "left": "ce qui",
      "right": "sujet"
    },
    {
      "left": "ce que",
      "right": "objet"
    },
    {
      "left": "c'est… que",
      "right": "objet nommé"
    },
    {
      "left": "c'est… qui",
      "right": "sujet nommé"
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
  "prompt": "Complétez :\nCe ___ je refuse, c'est la rumeur.",
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
    "C'est",
    "Lila",
    "qui",
    "ouvre",
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
  "word": "pupitre",
  "hint": "Marc s'y tient pour parler."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le chiffre qui je lis avant la rumeur.",
  "correct_sentence": "C'est le chiffre que je lis avant la rumeur.",
  "explanation": "COD : que."
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
      "image_path": "/elearning/mfk-b1-m6/casque-hawa.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/ethique-micro.svg",
      "word": "l'éthique"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/droit-reponse.svg",
      "word": "un droit"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/charte-figuier.svg",
      "word": "une charte"
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
  "prompt": "Fiche personnelle : 8 phrases, les quatre schémas."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et huit mises en évidence."
}$j$::jsonb,
    9
  );

  -- ===== Préparer le journal parlé =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Préparer le journal parlé'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Préparer le journal parlé', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — L''ordre de l''émission',
    'CO',
    $c$Objectif
Repérer la structure d'un journal parlé au Seuil.

Consigne
Lisez le dialogue. Dans quel ordre passe l'émission ?

Support — Horloge d'antenne, studio Figuier
Lila : D'abord le générique, puis mon salut.
Hawa : Ensuite le fait de la rivière, en trois phrases.
Marc : Après, un rappel de source : qui a vu, qui a mesuré.
Léa : Puis la météo du figuier, très courte.
Patrick : Ensuite l'agenda de la cour : Table, marché, infirmerie.
Aline : Plus tard, une voix invitée, jamais une rumeur.
Karim : Avant de fermer, on lit l'heure du prochain bulletin.
Solange : On ne mélange pas le dossier et le conte.
Mado : Le marché peut être cité s'il est nommé.
Sami : Un son de tambour peut ouvrir, pas remplacer le fait.
Joël : On chronomètre : huit minutes, pas plus.
Dieudonné : Si l'eau change, on refait le fait, pas tout le reste.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'émission commence par la voix invitée.",
  "correct": false,
  "explanation": "Lila : générique, puis salut."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de minutes dure le journal, selon Joël ?",
  "options": [
    {
      "text": "trois",
      "correct": false
    },
    {
      "text": "huit",
      "correct": true
    },
    {
      "text": "vingt",
      "correct": false
    },
    {
      "text": "une heure",
      "correct": false
    }
  ],
  "explanation": "« huit minutes, pas plus. »"
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
      "left": "générique / salut",
      "right": "ouverture"
    },
    {
      "left": "fait de la rivière",
      "right": "une"
    },
    {
      "left": "voix invitée",
      "right": "après le fait"
    },
    {
      "left": "heure du prochain",
      "right": "fermeture"
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
  "prompt": "Complétez :\nD'abord le générique, ___ mon salut.",
  "answer": "puis"
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
    "chronomètre",
    "huit",
    "minutes",
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
  "word": "generique",
  "hint": "Lila l'ouvre en premier (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "D'abord la voix invitée, puis le générique et le salut de Lila.",
  "correct_sentence": "D'abord le générique, puis mon salut.",
  "explanation": "L'ouverture précède l'invité."
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
      "image_path": "/elearning/mfk-b1-m6/ethique-micro.svg",
      "word": "l'éthique"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/droit-reponse.svg",
      "word": "un droit"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/charte-figuier.svg",
      "word": "une charte"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/oreille-critique.svg",
      "word": "une oreille"
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
  "prompt": "Dessinez l'ordre de l'émission en six cases."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez l'ordre : générique, salut, fait, source, agenda, clôture."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Conducteur du matin',
    'CE',
    $c$Objectif
Lire la structure écrite d'une émission.

Consigne
Lisez le conducteur, sans aller trop vite.

Support — Feuille conducteur, Radio Figuier
Conducteur — journal parlé du Seuil
1. Générique (20 secondes) — Lila.
2. Salut et date — Lila.
3. Fait 1 : niveau de la rivière — Hawa (chiffre, source Dieudonné).
4. Fait 2 : pont praticable — Marc (source Solange).
5. Rumeur écartée en une phrase, sans la répéter en détail — Karim.
6. Agenda : Marché des Lampions, Table des Sources, infirmerie — Léa.
7. Voix invitée du jour : Mado, deux minutes, stand des lampions.
8. Annonce du prochain bulletin (midi) — Lila.
9. Générique de fin.
Durée visée : huit minutes.
Interdit : une une sans source ; un conte à la place du fait.
Studio Figuier — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Karim développe longuement la rumeur.",
  "correct": false,
  "explanation": "« en une phrase, sans la répéter en détail. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui dit le fait sur le niveau de la rivière ?",
  "options": [
    {
      "text": "Lila",
      "correct": false
    },
    {
      "text": "Hawa",
      "correct": true
    },
    {
      "text": "Léa",
      "correct": false
    },
    {
      "text": "Mado",
      "correct": false
    }
  ],
  "explanation": "Fait 1 — Hawa."
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
      "left": "fait 1",
      "right": "Hawa"
    },
    {
      "left": "agenda",
      "right": "Léa"
    },
    {
      "left": "voix invitée",
      "right": "Mado"
    },
    {
      "left": "clôture",
      "right": "Lila"
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
  "prompt": "Complétez :\nDurée visée : ___ minutes.",
  "answer": "huit"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Annonce",
    "du",
    "prochain",
    "bulletin",
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
  "word": "conducteur",
  "hint": "La feuille qui ordonne l'émission."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Fait 1 : niveau de la rivière — Hawa sans aucune source nommée.",
  "correct_sentence": "Fait 1 : niveau de la rivière — Hawa (chiffre, source Dieudonné).",
  "explanation": "Chaque fait porte une source."
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
      "image_path": "/elearning/mfk-b1-m6/droit-reponse.svg",
      "word": "un droit"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/charte-figuier.svg",
      "word": "une charte"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/oreille-critique.svg",
      "word": "une oreille"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/antenne-radio.svg",
      "word": "une antenne"
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
  "prompt": "Recopiez le conducteur et changez la voix invitée."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les neuf points, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Enchaîner l''émission',
    'PO',
    $c$Objectif
Enchaîner à l'oral les parties d'un journal parlé.

Consigne
Répétez les formules de liaison, puis enchaînez un mini-journal.

Support — Formules de Lila
Ici Radio Figuier, journal du Seuil.
Bonjour. Voici d'abord le fait de la rivière.
Selon Dieudonné, le niveau est haut.
Venons-en au pont : il reste praticable.
Une voix du marché a couru : elle n'a pas été confirmée.
Passons à l'agenda de la cour.
Nous recevons maintenant Mado.
Merci Mado. Prochain bulletin à midi.
Bonne écoute sous le figuier.
Je vous retrouve à midi.
Huit minutes, pas davantage.
Chaque fait a une source.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Venons-en au pont » sert à changer de sujet.",
  "correct": true,
  "explanation": "Liaison d'émission."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle formule ouvre l'antenne ?",
  "options": [
    {
      "text": "Merci Mado",
      "correct": false
    },
    {
      "text": "Ici Radio Figuier, journal du Seuil",
      "correct": true
    },
    {
      "text": "Passons à l'agenda",
      "correct": false
    },
    {
      "text": "Bonne écoute",
      "correct": false
    }
  ],
  "explanation": "Salut d'ouverture."
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
      "left": "ici Radio Figuier",
      "right": "ouverture"
    },
    {
      "left": "venons-en au",
      "right": "enchaînement"
    },
    {
      "left": "passons à",
      "right": "agenda"
    },
    {
      "left": "prochain bulletin",
      "right": "fermeture"
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
  "prompt": "Complétez :\n___-en au pont : il reste praticable.",
  "answer": "Venons"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Passons",
    "à",
    "l'agenda",
    "de",
    "la",
    "cour",
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
  "word": "enchaine",
  "hint": "On… les parties (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ici Radio Figuier, merci Mado et bonjour en même temps.",
  "correct_sentence": "Ici Radio Figuier, journal du Seuil. Bonjour.",
  "explanation": "L'ouverture précède les remerciements."
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
      "image_path": "/elearning/mfk-b1-m6/charte-figuier.svg",
      "word": "une charte"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/oreille-critique.svg",
      "word": "une oreille"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/antenne-radio.svg",
      "word": "une antenne"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/feuille-une.svg",
      "word": "une feuille"
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
  "prompt": "Écrivez un mini-conducteur oral de dix phrases."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez un journal de huit phrases, chronométré."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon conducteur',
    'PE',
    $c$Objectif
Écrire la structure d'une émission de huit minutes.

Consigne
Imitez le conducteur de Patrick, sans aller trop vite.

Support — Conducteur de Patrick Habimana
Patrick Habimana — journal du soir
1. Générique et salut.
2. Fait : le pieu de Dieudonné, chiffre du soir.
3. Source : Feuille du Seuil, tampon de Solange.
4. Rumeur écartée : une phrase, pas plus.
5. Agenda : Salle des Herbes, infirmerie, marché.
6. Voix invitée : Sami, pourquoi le tambour a rassemblé.
7. Heure du bulletin de demain.
8. Générique de fin.
Durée : huit minutes.
Interdit : une une sans nom.
Patrick
Radio Figuier
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick invite Dieudonné comme voix du soir.",
  "correct": false,
  "explanation": "Voix invitée : Sami."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait Patrick de la rumeur ?",
  "options": [
    {
      "text": "Il la développe en trois minutes",
      "correct": false
    },
    {
      "text": "Il l'écarte en une phrase",
      "correct": true
    },
    {
      "text": "Il la place en une",
      "correct": false
    },
    {
      "text": "Il la chante",
      "correct": false
    }
  ],
  "explanation": "« une phrase, pas plus. »"
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
      "left": "fait",
      "right": "pieu / chiffre"
    },
    {
      "left": "source",
      "right": "Solange"
    },
    {
      "left": "invité",
      "right": "Sami"
    },
    {
      "left": "durée",
      "right": "huit minutes"
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
  "prompt": "Complétez :\nDurée : ___ minutes.",
  "answer": "huit"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Générique",
    "et",
    "salut",
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
  "word": "interdit",
  "hint": "Chez Patrick : une une sans nom est…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voix invitée : une voix sans nom du Marché des Lampions.",
  "correct_sentence": "Voix invitée : Sami, pourquoi le tambour a rassemblé.",
  "explanation": "L'invité est nommé."
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
      "image_path": "/elearning/mfk-b1-m6/oreille-critique.svg",
      "word": "une oreille"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/antenne-radio.svg",
      "word": "une antenne"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/feuille-une.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/carte-direct.svg",
      "word": "une carte"
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
  "prompt": "Imitez : huit points, une durée, un interdit."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre conducteur, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Structure d''une émission',
    'EL',
    $c$Objectif
Retenir l'ordre d'un journal parlé.

Consigne
Apprenez la fiche.

Support — Fiche studio
Ordre type — Radio Figuier
1. Générique 2. Salut et date 3. Fait principal
4. Source nommée 5. Rumeur écartée (une phrase)
6. Agenda de la cour 7. Voix invitée 8. Prochain bulletin 9. Générique
Liaisons
Ici… / Voici d'abord… / Venons-en à… / Passons à… / Nous recevons…
Merci… / Prochain bulletin à…
Durée visée : huit minutes.
Chaque fait porte une source.
On n'ouvre pas sur une rumeur.
On n'invite pas une voix sans nom.
Le tambour peut ouvrir le son, pas remplacer le texte.
Si l'eau change, on refait le fait, pas tout l'agenda.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut ouvrir le journal sur une rumeur si elle est forte.",
  "correct": false,
  "explanation": "On n'ouvre pas sur une rumeur."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle liaison annonce l'invité ?",
  "options": [
    {
      "text": "Voici d'abord",
      "correct": false
    },
    {
      "text": "Nous recevons",
      "correct": true
    },
    {
      "text": "Prochain bulletin",
      "correct": false
    },
    {
      "text": "Générique",
      "correct": false
    }
  ],
  "explanation": "Nous recevons + nom."
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
      "left": "voici d'abord",
      "right": "fait"
    },
    {
      "left": "venons-en à",
      "right": "enchaînement"
    },
    {
      "left": "nous recevons",
      "right": "invité"
    },
    {
      "left": "prochain bulletin",
      "right": "clôture"
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
  "prompt": "Complétez :\nNous ___ maintenant Mado.",
  "answer": "recevons"
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
    "n'ouvre",
    "pas",
    "sur",
    "une",
    "rumeur",
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
  "word": "liaisons",
  "hint": "Voici, venons-en, passons : les… de l'antenne."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On ouvre le journal sur une rumeur si le marché parle fort.",
  "correct_sentence": "On n'ouvre pas sur une rumeur.",
  "explanation": "Le fait précède la rumeur écartée."
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
      "image_path": "/elearning/mfk-b1-m6/antenne-radio.svg",
      "word": "une antenne"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/feuille-une.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/carte-direct.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/groupe-redaction.svg",
      "word": "une rédaction"
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
  "prompt": "Recopiez l'ordre type et inventez trois liaisons."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et un enchaînement complet."
}$j$::jsonb,
    9
  );

  -- ===== L'éthique du micro =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'L''éthique du micro'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'L''éthique du micro', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le droit de répondre',
    'CO',
    $c$Objectif
Comprendre le droit de réponse et une limite éthique de l'antenne.

Consigne
Lisez le dialogue. Qui peut répondre ? Pourquoi ?

Support — Salle des Herbes, oreille de la cour
Joël : On a dit que j'avais fui. Ce n'est pas vrai.
Lila : Tu as un droit de réponse. Tu parles après le fait, deux minutes.
Aline : Le droit de réponse, c'est le droit d'être entendu quand on a été nommé à tort.
Marc : On ne lit pas la rumeur une seconde fois pour « équilibrer ».
Léa : On lit la correction, puis Joël parle.
Patrick : La charte de Radio Figuier interdit d'humilier.
Hawa : Elle demande une source avant chaque nom.
Karim : Elle demande aussi d'écouter celui qu'on a blessé.
Solange : Le Bureau note la réponse. Elle reste au dossier.
Mado : Le marché n'a pas ce droit écrit : la radio, si.
Sami : Je peux offrir un son, pas une accusation.
Dieudonné : Si l'on me nomme à tort, je viendrai au pieu et au micro.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila refuse que Joël parle à l'antenne.",
  "correct": false,
  "explanation": "« Tu as un droit de réponse. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de minutes Joël a-t-il pour répondre ?",
  "options": [
    {
      "text": "huit",
      "correct": false
    },
    {
      "text": "vingt",
      "correct": false
    },
    {
      "text": "deux",
      "correct": true
    },
    {
      "text": "une heure",
      "correct": false
    }
  ],
  "explanation": "Lila : deux minutes."
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
      "left": "droit de réponse",
      "right": "être entendu"
    },
    {
      "left": "charte",
      "right": "interdit d'humilier"
    },
    {
      "left": "source avant chaque nom",
      "right": "Hawa"
    },
    {
      "left": "dossier",
      "right": "Solange"
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
  "prompt": "Complétez :\nTu as un droit de ___.",
  "answer": "réponse"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Tu",
    "as",
    "un",
    "droit",
    "de",
    "réponse",
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
  "word": "humilier",
  "hint": "La charte l'interdit : faire honte à quelqu'un."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On lit la rumeur une seconde fois pour équilibrer, puis Joël se tait.",
  "correct_sentence": "On lit la correction, puis Joël parle.",
  "explanation": "On ne répète pas la rumeur pour « équilibrer »."
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
      "image_path": "/elearning/mfk-b1-m6/feuille-une.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/carte-direct.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/groupe-redaction.svg",
      "word": "une rédaction"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/nuage-rumeur.svg",
      "word": "un nuage"
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
  "prompt": "Notez trois règles éthiques entendues."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Tu as un droit de réponse. On lit la correction. La charte interdit d'humilier."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Charte de Radio Figuier',
    'CE',
    $c$Objectif
Lire une charte inventée de l'antenne.

Consigne
Lisez la charte, sans aller trop vite.

Support — Charte ocre, studio Figuier
Charte de Radio Figuier — Seuil des Sources
1. Chaque nom cité a une source visible.
2. Une rumeur n'ouvre jamais le journal.
3. Celui ou celle qui a été nommé(e) à tort a deux minutes de réponse.
4. On ne répète pas l'accusation pour « faire juste ».
5. On n'humilie pas. On n'invente pas de titre cruel.
6. Le Cahier du chemin garde les versions. On peut les relire.
7. Lila peut refuser une phrase qui blesse sans informer.
8. Solange peut tamponner une correction au Bureau des Escales.
9. Le tambour rassemble ; il n'accuse pas.
10. Si l'eau, le marché ou la cour change, on corrige à l'antenne suivante.
Signée : Lila Sow, Aline Uwase, Solange Mukamana.
Rukiri-Nord — sous le figuier
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le tambour peut accuser quelqu'un s'il joue fort.",
  "correct": false,
  "explanation": "Point 9 : il n'accuse pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui peut tamponner une correction ?",
  "options": [
    {
      "text": "Sami",
      "correct": false
    },
    {
      "text": "Mado",
      "correct": false
    },
    {
      "text": "Solange",
      "correct": true
    },
    {
      "text": "Joël",
      "correct": false
    }
  ],
  "explanation": "Point 8."
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
      "left": "source visible",
      "right": "article 1"
    },
    {
      "left": "deux minutes",
      "right": "droit de réponse"
    },
    {
      "left": "Cahier du chemin",
      "right": "versions"
    },
    {
      "left": "corriger ensuite",
      "right": "article 10"
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
  "prompt": "Complétez :\nUne rumeur n'___ jamais le journal.",
  "answer": "ouvre"
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
    "n'humilie",
    "pas",
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
  "word": "correction",
  "hint": "Solange peut la tamponner au Bureau."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Une rumeur ouvre le journal si elle vient du Marché des Lampions.",
  "correct_sentence": "Une rumeur n'ouvre jamais le journal.",
  "explanation": "Article 2 de la charte."
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
      "image_path": "/elearning/mfk-b1-m6/carte-direct.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/groupe-redaction.svg",
      "word": "une rédaction"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/nuage-rumeur.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/soleil-fait.svg",
      "word": "un soleil"
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
  "prompt": "Recopiez cinq articles et ajoutez-en un à vous."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les dix articles, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Répondre sans blesser',
    'PO',
    $c$Objectif
Parler au micro après une erreur, selon la charte.

Consigne
Répétez, puis formulez un droit de réponse.

Support — Modèles de Joël
On a dit que j'avais fui. C'est faux.
J'étais à la Table des Sources.
Je demande deux minutes de réponse.
Je nomme mes témoins : Félicie et Léa.
Je n'accuse personne en retour.
Je remercie Lila de corriger.
La charte me protège. Elle protège aussi les autres.
Je parle après le fait, pas à sa place.
Je reste calme. Je reste précis.
Je ne répète pas la rumeur.
Je dis où j'étais. Je dis qui m'a vu.
Merci à la cour de m'écouter.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël accuse le marché en retour.",
  "correct": false,
  "explanation": "« Je n'accuse personne en retour. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quels témoins Joël nomme-t-il ?",
  "options": [
    {
      "text": "Sami et Mado",
      "correct": false
    },
    {
      "text": "Félicie et Léa",
      "correct": true
    },
    {
      "text": "Karim et Marc",
      "correct": false
    },
    {
      "text": "Dieudonné et Solange",
      "correct": false
    }
  ],
  "explanation": "« Félicie et Léa. »"
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
      "left": "c'est faux",
      "right": "démenti"
    },
    {
      "left": "témoins",
      "right": "Félicie / Léa"
    },
    {
      "left": "deux minutes",
      "right": "droit"
    },
    {
      "left": "je n'accuse pas",
      "right": "éthique"
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
  "prompt": "Complétez :\nJe n'___ personne en retour.",
  "answer": "accuse"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Je",
    "demande",
    "deux",
    "minutes",
    "de",
    "réponse",
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
  "word": "temoins",
  "hint": "Félicie et Léa : ceux qui ont vu (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je répète la rumeur en entier pour mieux la casser ensuite.",
  "correct_sentence": "Je ne répète pas la rumeur.",
  "explanation": "La charte : on ne relit pas l'accusation."
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
      "image_path": "/elearning/mfk-b1-m6/groupe-redaction.svg",
      "word": "une rédaction"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/nuage-rumeur.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/soleil-fait.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/source-info.svg",
      "word": "une source"
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
  "prompt": "Écrivez un droit de réponse de dix phrases."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis votre réponse de deux minutes."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma réponse à l''antenne',
    'PE',
    $c$Objectif
Écrire un droit de réponse selon la charte.

Consigne
Imitez la réponse de Joël, sans aller trop vite.

Support — Réponse de Joël Mugisha
Joël Mugisha
On a dit que j'avais fui la rive. C'est faux.
J'étais à la Table des Sources. Félicie m'a vu. Léa aussi.
Je demande le droit de réponse prévu par la charte.
Je ne répète pas la voix du marché.
Je remercie Radio Figuier de lire cette correction.
Je n'humilie personne. Je n'invente aucun nom.
Le Bureau des Escales peut joindre cette feuille au dossier.
Joël
Seuil des Sources — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël invente un nom pour se défendre.",
  "correct": false,
  "explanation": "« Je n'invente aucun nom. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Joël était-il ?",
  "options": [
    {
      "text": "au Marché des Lampions",
      "correct": false
    },
    {
      "text": "à la Table des Sources",
      "correct": true
    },
    {
      "text": "à Val-des-Peupliers",
      "correct": false
    },
    {
      "text": "sous la rive",
      "correct": false
    }
  ],
  "explanation": "« J'étais à la Table des Sources. »"
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
      "left": "c'est faux",
      "right": "fuite"
    },
    {
      "left": "témoins",
      "right": "Félicie / Léa"
    },
    {
      "left": "charte",
      "right": "droit de réponse"
    },
    {
      "left": "dossier",
      "right": "Bureau des Escales"
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
  "prompt": "Complétez :\nJe n'invente aucun ___.",
  "answer": "nom"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "C'est",
    "faux",
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
  "word": "dossier",
  "hint": "Solange y joint la feuille."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On a dit que j'avais fui. Je répète toute la rumeur pour rire.",
  "correct_sentence": "On a dit que j'avais fui la rive. C'est faux.",
  "explanation": "On dément, on ne rejoue pas la rumeur."
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
      "image_path": "/elearning/mfk-b1-m6/nuage-rumeur.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/soleil-fait.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/source-info.svg",
      "word": "une source"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/concession.svg",
      "word": "une concession"
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
  "prompt": "Imitez : démenti, lieu, témoins, remerciement, dossier."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre réponse, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Droit de réponse et charte',
    'EL',
    $c$Objectif
Retenir l'éthique du micro de Radio Figuier.

Consigne
Apprenez la fiche.

Support — Fiche d'éthique
Droit de réponse
Si l'on vous nomme à tort, vous parlez après le fait, deux minutes.
On lit une correction. On ne relit pas l'accusation.
Charte de Radio Figuier (inventée au Seuil)
source avant chaque nom ; pas de une-rumeur ; pas d'humiliation.
Cahier du chemin = mémoire des versions.
Lila peut refuser une phrase qui blesse.
Solange peut tamponner la correction.
Le tambour rassemble ; il n'accuse pas.
On corrige à l'émission suivante si le fait change.
On n'équilibre pas une erreur en la répétant.
On nomme ses témoins. On n'invente pas de nom.
Éthique = protéger la cour et la vérité du pieu.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Équilibrer une erreur, c'est relire l'accusation.",
  "correct": false,
  "explanation": "On ne l'équilibre pas en la répétant."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où garde-t-on les versions ?",
  "options": [
    {
      "text": "dans un cri du marché",
      "correct": false
    },
    {
      "text": "dans le Cahier du chemin",
      "correct": true
    },
    {
      "text": "sous l'eau",
      "correct": false
    },
    {
      "text": "nulle part",
      "correct": false
    }
  ],
  "explanation": "Cahier du chemin = mémoire."
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
      "left": "deux minutes",
      "right": "réponse"
    },
    {
      "left": "correction",
      "right": "sans relire l'accusation"
    },
    {
      "left": "Lila",
      "right": "peut refuser"
    },
    {
      "left": "Solange",
      "right": "tampon"
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
  "prompt": "Complétez :\nLe tambour rassemble ; il n'___ pas.",
  "answer": "accuse"
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
    "nomme",
    "ses",
    "témoins",
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
  "word": "ethique",
  "hint": "Protéger la cour et le pieu (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On équilibre une accusation en la relisant deux fois.",
  "correct_sentence": "On lit une correction. On ne relit pas l'accusation.",
  "explanation": "La charte refuse ce faux équilibre."
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
      "image_path": "/elearning/mfk-b1-m6/soleil-fait.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/source-info.svg",
      "word": "une source"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/concession.svg",
      "word": "une concession"
    },
    {
      "image_path": "/elearning/mfk-b1-m6/voix-passive.svg",
      "word": "un passif"
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
  "prompt": "Rédigez cinq articles personnels pour le micro de la cour."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et votre serment d'antenne."
}$j$::jsonb,
    9
  );

END;
$$;
