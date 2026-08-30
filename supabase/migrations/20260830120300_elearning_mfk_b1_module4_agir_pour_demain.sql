/*
  Seed eLearning MFK — B1 — Agir pour demain

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b1-m4/
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
  v_module_title text := 'B1 — Agir pour demain';
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
      'Grande étape B1-4 : rendre compte d''une expérience, adhérer et nuancer, débattre de solutions, présenter un projet pour la rive, persuader d''agir et mesurer l''impact — autour du figuier, du compost et de la petite rivière du Seuil des Sources (Rukiri-Nord), jusqu''au Bureau des Escales.',
      'B1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B1-4 : rendre compte d''une expérience, adhérer et nuancer, débattre de solutions, présenter un projet pour la rive, persuader d''agir et mesurer l''impact — autour du figuier, du compost et de la petite rivière du Seuil des Sources (Rukiri-Nord), jusqu''au Bureau des Escales.',
      cefr_level = 'B1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Rendre compte, adhérer, nuancer =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Rendre compte, adhérer, nuancer'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Rendre compte, adhérer, nuancer', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Compte rendu sous le figuier',
    'CO',
    $c$Objectif
Comprendre un compte rendu d'expérience : adhésion, réserves, indéfinis de quantité.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui adhère ? Qui nuance ?

Support — Banc du figuier, après l'assemblée
Léa : Hier, sous le figuier, nous avons rendu compte de la rive.
Patrick : Quelques voisins sont venus. Plusieurs ont parlé trop vite.
Hawa : La plupart des habitants veulent protéger le figuier.
Marc : Tout le monde n'est pas d'accord : j'ai encore des réserves.
Joël : Aucun seau n'était prêt, pourtant certains ont déjà composté.
Rose : Chaque sac de feuilles compte, même s'il est petit.
Aline : J'adhère à l'idée, mais je nuance : il faut du temps.
Karim : Certains gestes sont clairs. D'autres restent flous pour le Bureau.
Lila : Radio Figuier a noté tout cela pour le Cahier des racines.
Solange : Le Bureau des Escales lira quelques pages, pas toutes d'un coup.
Félicie : J'adhère aussi, sans cacher mes doutes sur le rythme.
Dieudonné : Plusieurs tissus de l'atelier serviront de sacs, pas tous.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa dit que la plupart des habitants veulent protéger le figuier.",
  "correct": true,
  "explanation": "Hawa : « La plupart des habitants veulent protéger le figuier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que dit Joël des seaux ?",
  "options": [
    {
      "text": "Tous les seaux étaient prêts",
      "correct": false
    },
    {
      "text": "Aucun seau n'était prêt",
      "correct": true
    },
    {
      "text": "Chaque seau était plein",
      "correct": false
    },
    {
      "text": "Quelques seaux ont disparu",
      "correct": false
    }
  ],
  "explanation": "Joël : « Aucun seau n'était prêt. »"
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
      "left": "quelques voisins",
      "right": "un petit nombre"
    },
    {
      "left": "la plupart des habitants",
      "right": "presque tous"
    },
    {
      "left": "aucun seau",
      "right": "pas un seul"
    },
    {
      "left": "chaque sac",
      "right": "un par un"
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
  "prompt": "Complétez :\n___ seau n'était prêt.",
  "answer": "Aucun"
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
    "plupart",
    "des",
    "habitants",
    "veulent",
    "protéger",
    "le",
    "figuier",
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
  "word": "quelques",
  "hint": "Un petit nombre de voisins, pas la majorité."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La plupart des habitants veut protéger le figuier.",
  "correct_sentence": "La plupart des habitants veulent protéger le figuier.",
  "explanation": "La plupart + nom pluriel : verbe au pluriel."
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
      "image_path": "/elearning/mfk-b1-m4/compte-rendu.svg",
      "word": "un compte rendu"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/indefinis-quantite.svg",
      "word": "une quantité"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/reserve-adhesion.svg",
      "word": "une réserve"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/cahier-racines.svg",
      "word": "un cahier"
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
  "prompt": "Notez deux adhésions et deux réserves entendues, avec un indéfini chacune."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Quelques voisins sont venus. La plupart veulent protéger. J'adhère, mais je nuance."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Pages du Cahier des racines',
    'CE',
    $c$Objectif
Lire un compte rendu écrit avec indéfinis de quantité, adhésion et réserves.

Consigne
Lisez les pages épinglées, sans aller trop vite.

Support — Cahier des racines, feuille ocre
Assemblée du Seuil — compte rendu
Quelques voix ont ouvert la séance sous le figuier.
Plusieurs habitants ont décrit la rive : plastique, terre sèche, odeur.
La plupart des présents adhèrent au compost de la cour.
Certains nuancent : trop d'outils, trop peu de relais le soir.
Aucun enfant n'est resté sans tâche : chaque seau a un nom.
Tout le compost ira près de la Table des Sources, pas plus loin.
Rose écrit : j'adhère, à condition que le rythme reste humain.
Karim note : plusieurs sacs, pas tous, viendront de l'Atelier du Tissu.
Solange Mukamana lira tout le cahier avant jeudi.
Félicie ajoute une réserve : aucun feu près de l'eau.
Dieudonné signe : chaque tissu réemployé compte.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Tous les sacs viendront de l'Atelier du Tissu.",
  "correct": false,
  "explanation": "Karim : « plusieurs sacs, pas tous. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle réserve Félicie ajoute-t-elle ?",
  "options": [
    {
      "text": "Aucun compost dans la cour",
      "correct": false
    },
    {
      "text": "Aucun feu près de l'eau",
      "correct": true
    },
    {
      "text": "Aucune signature avant jeudi",
      "correct": false
    },
    {
      "text": "Aucun enfant à l'assemblée",
      "correct": false
    }
  ],
  "explanation": "« aucun feu près de l'eau. »"
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
      "left": "quelques voix",
      "right": "ouverture"
    },
    {
      "left": "la plupart des présents",
      "right": "adhésion au compost"
    },
    {
      "left": "certains",
      "right": "nuancent le rythme"
    },
    {
      "left": "chaque seau",
      "right": "un nom"
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
  "prompt": "Complétez :\n___ enfant n'est resté sans tâche.",
  "answer": "Aucun"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Certains",
    "nuancent",
    "le",
    "rythme",
    "du",
    "projet",
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
  "word": "certains",
  "hint": "Pas tous : une partie des habitants, au masculin pluriel."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aucun enfant est resté sans tâche.",
  "correct_sentence": "Aucun enfant n'est resté sans tâche.",
  "explanation": "Aucun s'emploie avec ne."
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
      "image_path": "/elearning/mfk-b1-m4/indefinis-quantite.svg",
      "word": "une quantité"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/reserve-adhesion.svg",
      "word": "une réserve"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/cahier-racines.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/participe-present.svg",
      "word": "un participe"
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
  "prompt": "Recopiez le compte rendu et soulignez tous les indéfinis de quantité."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les pages du Cahier des racines, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Adhérer et nuancer',
    'PO',
    $c$Objectif
Dire une adhésion, une réserve et une quantité à voix haute.

Consigne
Répétez les modèles, puis parlez de la rive du Seuil.

Support — Modèles d'Aline
Quelques voisins sont déjà là.
Plusieurs ont adhéré sans réserve.
La plupart des gestes sont simples.
Tout le compost reste dans la cour.
Aucun sac ne part trop loin.
Certains doutent encore du rythme.
Chaque seau a sa place.
J'adhère à l'idée, mais je nuance.
Nous adhérons, à condition d'aller lentement.
Plusieurs tissus serviront, pas tous.
La plupart veulent signer.
Aucun feu n'est prévu près de l'eau.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« La plupart » annonce souvent un verbe au pluriel.",
  "correct": true,
  "explanation": "La plupart des gestes sont simples."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase exprime une réserve ?",
  "options": [
    {
      "text": "Plusieurs ont adhéré sans réserve",
      "correct": false
    },
    {
      "text": "J'adhère à l'idée mais je nuance",
      "correct": true
    },
    {
      "text": "Tout le compost reste dans la cour",
      "correct": false
    },
    {
      "text": "Chaque seau a sa place",
      "correct": false
    }
  ],
  "explanation": "Adhérer + mais je nuance."
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
      "left": "quelques",
      "right": "un petit nombre"
    },
    {
      "left": "plusieurs",
      "right": "plus de deux"
    },
    {
      "left": "tout",
      "right": "l'ensemble"
    },
    {
      "left": "aucun… ne",
      "right": "zéro"
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
  "prompt": "Complétez :\n___ seau a sa place.",
  "answer": "Chaque"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'adhère",
    "à",
    "l'idée",
    "mais",
    "je",
    "nuance",
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
  "word": "chaque",
  "hint": "Un par un : … seau a sa place."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Chaque seaux a sa place près du figuier.",
  "correct_sentence": "Chaque seau a sa place près du figuier.",
  "explanation": "Chaque + nom singulier."
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
      "image_path": "/elearning/mfk-b1-m4/reserve-adhesion.svg",
      "word": "une réserve"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/cahier-racines.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/participe-present.svg",
      "word": "un participe"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/debat-rive.svg",
      "word": "un débat"
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
  "prompt": "Écrivez six phrases : deux adhésions, deux réserves, deux indéfinis différents."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis deux phrases à vous : j'adhère / je nuance."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon compte rendu',
    'PE',
    $c$Objectif
Écrire un court compte rendu d'expérience avec adhésion, réserve et indéfinis.

Consigne
Imitez le compte rendu de Patrick, sans aller trop vite.

Support — Compte rendu de Patrick Habimana
Patrick Habimana
Quelques voisins sont venus sous le figuier.
Plusieurs ont parlé de la petite rivière.
La plupart des présents adhèrent au compost.
J'adhère aussi, mais je nuance : aucun geste ne doit brûler l'équipe.
Certains préfèrent les seaux le matin, d'autres le soir.
Chaque page du Cahier des racines portera un nom.
Tout le plastique ramassé ira hors de la rive.
Patrick
Seuil des Sources — Rukiri-Nord
Cahier des racines
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick refuse le compost.",
  "correct": false,
  "explanation": "« J'adhère aussi, mais je nuance. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que portera chaque page, d'après Patrick ?",
  "options": [
    {
      "text": "Un tampon de ville",
      "correct": false
    },
    {
      "text": "Un nom",
      "correct": true
    },
    {
      "text": "Un prix",
      "correct": false
    },
    {
      "text": "Un horaire de minibus",
      "correct": false
    }
  ],
  "explanation": "« Chaque page … portera un nom. »"
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
      "left": "quelques voisins",
      "right": "sont venus"
    },
    {
      "left": "la plupart des présents",
      "right": "adhèrent"
    },
    {
      "left": "aucun geste",
      "right": "ne doit brûler"
    },
    {
      "left": "chaque page",
      "right": "un nom"
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
  "prompt": "Complétez :\n___ le plastique ramassé ira hors de la rive.",
  "answer": "Tout"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Plusieurs",
    "ont",
    "parlé",
    "de",
    "la",
    "rivière",
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
  "word": "nuance",
  "hint": "Adhérer sans tout accepter : on… le rythme."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tout les plastiques ramassés iront hors de la rive.",
  "correct_sentence": "Tous les plastiques ramassés iront hors de la rive.",
  "explanation": "Tous les + nom pluriel masculin."
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
      "image_path": "/elearning/mfk-b1-m4/cahier-racines.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/participe-present.svg",
      "word": "un participe"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/debat-rive.svg",
      "word": "un débat"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/adverbe-ment.svg",
      "word": "un adverbe"
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
  "prompt": "Imitez : dix lignes, trois indéfinis, une adhésion et une réserve."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre compte rendu, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Indéfinis de quantité',
    'EL',
    $c$Objectif
Retenir quelques, plusieurs, la plupart, tout, aucun, certains, chaque.

Consigne
Apprenez la fiche.

Support — Fiche du carnet, ombre du figuier
quelques + nom pluriel : un petit nombre (quelques voisins).
plusieurs + nom pluriel : plus de deux, sans tout dire.
la plupart des + nom pluriel : verbe souvent au pluriel (veulent).
tout / toute / tous / toutes : l'ensemble (tout le compost / tous les sacs).
aucun / aucune + ne + verbe au singulier : pas un seul.
certains / certaines : une partie, souvent avec une réserve.
chaque + nom singulier : un par un (chaque seau).
Adhésion : j'adhère à… / je suis d'accord pour…
Réserve : je nuance / j'adhère, mais… / à condition que…
Ne pas dire : la plupart veut (avec un nom pluriel).
Ne pas dire : aucun… est (sans ne).
Ne pas dire : chaque seaux.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « chaque seaux » au pluriel.",
  "correct": false,
  "explanation": "Chaque + singulier."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est correcte ?",
  "options": [
    {
      "text": "Aucun seau était prêt",
      "correct": false
    },
    {
      "text": "Aucun seau n'était prêt",
      "correct": true
    },
    {
      "text": "Aucuns seaux n'étaient prêtes",
      "correct": false
    },
    {
      "text": "Aucun des seau est prêt",
      "correct": false
    }
  ],
  "explanation": "Aucun + ne + singulier."
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
      "left": "quelques",
      "right": "petit nombre"
    },
    {
      "left": "la plupart des",
      "right": "presque tous"
    },
    {
      "left": "aucun… ne",
      "right": "zéro"
    },
    {
      "left": "chaque",
      "right": "un par un"
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
  "prompt": "Complétez :\nLa plupart des habitants ___ signer. (vouloir)",
  "answer": "veulent"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Aucun",
    "feu",
    "n'est",
    "prévu",
    "près",
    "de",
    "l'eau",
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
  "word": "plusieurs",
  "hint": "Plus de deux habitants, sans dire tout le groupe."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Certains habitants nuance encore le rythme.",
  "correct_sentence": "Certains habitants nuancent encore le rythme.",
  "explanation": "Certains + verbe au pluriel : nuancent."
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
      "image_path": "/elearning/mfk-b1-m4/participe-present.svg",
      "word": "un participe"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/debat-rive.svg",
      "word": "un débat"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/adverbe-ment.svg",
      "word": "un adverbe"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/intensite-trop.svg",
      "word": "une intensité"
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
  "prompt": "Construisez sept phrases, une pour chaque indéfini de la fiche."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis trois exemples à vous."
}$j$::jsonb,
    9
  );

  -- ===== Débattre de solutions =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Débattre de solutions'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Débattre de solutions', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Débat sur la rive',
    'CO',
    $c$Objectif
Repérer le participe présent, le gérondif, les adverbes en -ment et l'intensité.

Consigne
Lisez le débat. Quelle solution ? Quelle intensité ?

Support — Rive du Seuil, cercle debout
Patrick : En agissant maintenant, on évite un mal vraiment plus grand.
Léa : Étant trop pressés, certains déplacent trop de terre.
Marc : En écoutant chacun, on avance lentement, pas trop vite.
Hawa : La rive est particulièrement fragile près des racines.
Joël : En compostant ici, on réduit extrêmement les déchets de cuisine.
Rose : Je parle calmement : assez de seaux, pas trop de discours.
Aline : En étant clairs, nous convaincrons le Bureau plus facilement.
Karim : Lila a parlé clairement : l'eau monte vraiment trop vite.
Félicie : En rangeant le soir, on laisse la cour propre.
Dieudonné : Une équipe agissant trop vite abîme le tissu des sacs.
Solange : Le Bureau écoute attentivement, pas seulement les plus forts.
Lila : En mesurant chaque semaine, on débattra moins à vide.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa dit que la rive est particulièrement fragile près des racines.",
  "correct": true,
  "explanation": "Hawa : « particulièrement fragile près des racines. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que craint Léa si l'on est trop pressé ?",
  "options": [
    {
      "text": "On manque de seaux",
      "correct": false
    },
    {
      "text": "On déplace trop de terre",
      "correct": true
    },
    {
      "text": "On éteint Radio Figuier",
      "correct": false
    },
    {
      "text": "On ferme le Bureau",
      "correct": false
    }
  ],
  "explanation": "Léa : « trop de terre. »"
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
      "left": "en agissant",
      "right": "moyen / simultanéité"
    },
    {
      "left": "étant trop pressés",
      "right": "cause"
    },
    {
      "left": "lentement",
      "right": "adverbe en -ment"
    },
    {
      "left": "particulièrement",
      "right": "intensité"
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
  "prompt": "Complétez :\n___ agissant maintenant, on évite un mal plus grand.",
  "answer": "En"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "En",
    "agissant",
    "maintenant",
    "on",
    "évite",
    "un",
    "mal",
    "plus",
    "grand",
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
  "word": "lentement",
  "hint": "Pas trop vite : on avance…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En agissant maintenant on évite un mal vraiment plus grands.",
  "correct_sentence": "En agissant maintenant on évite un mal vraiment plus grand.",
  "explanation": "Mal est masculin singulier : grand."
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
      "image_path": "/elearning/mfk-b1-m4/debat-rive.svg",
      "word": "un débat"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/adverbe-ment.svg",
      "word": "un adverbe"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/intensite-trop.svg",
      "word": "une intensité"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/projet-local.svg",
      "word": "un projet"
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
  "prompt": "Notez deux gérondifs, un participe présent et trois adverbes d'intensité."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : En agissant maintenant. Étant trop pressés. La rive est particulièrement fragile."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Notes de débat',
    'CE',
    $c$Objectif
Lire des notes de solutions avec participe présent, -ment et intensité.

Consigne
Lisez les notes, sans aller trop vite.

Support — Feuille de Marc Nkurunziza
Débat du mardi — solutions pour la rive
1. En retirant le plastique, on libère vraiment le courant.
2. Étant trop nombreux le même soir, on piétine les racines.
3. En arrosant lentement, le compost reste assez humide.
4. Une équipe agissant calmement convainc plus qu'une équipe criant.
5. La pente est extrêmement glissante après la pluie.
6. En parlant clairement, on évite les rumeurs du marché.
7. Trop de seaux vides fatiguent ; assez de relais suffit.
8. Joël : en triant particulièrement les épluchures, on aide Félicie.
9. Lila : Radio Figuier répétera attentivement les horaires.
10. Solange : le Bureau lira le débat en restant prudent.
11. Rose : en nuançant, on n'abandonne pas, on ajuste.
12. Aline : extrêmement utile, ce cercle, s'il reste humain.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc écrit qu'être trop nombreux le même soir piétine les racines.",
  "correct": true,
  "explanation": "Point 2 : « Étant trop nombreux… on piétine les racines. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment le compost reste-t-il assez humide ?",
  "options": [
    {
      "text": "En criant plus fort",
      "correct": false
    },
    {
      "text": "En arrosant lentement",
      "correct": true
    },
    {
      "text": "En fermant la rive",
      "correct": false
    },
    {
      "text": "En courant extrêmement vite",
      "correct": false
    }
  ],
  "explanation": "« En arrosant lentement. »"
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
      "left": "en retirant",
      "right": "le plastique"
    },
    {
      "left": "étant trop nombreux",
      "right": "piétiner"
    },
    {
      "left": "extrêmement",
      "right": "glissante"
    },
    {
      "left": "assez",
      "right": "de relais"
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
  "prompt": "Complétez :\nLa pente est ___ glissante après la pluie.",
  "answer": "extrêmement"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "En",
    "parlant",
    "clairement",
    "on",
    "évite",
    "les",
    "rumeurs",
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
  "word": "vraiment",
  "hint": "Adverbe d'intensité : le courant est… libre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En arrosant lentement le compost reste assez humides.",
  "correct_sentence": "En arrosant lentement le compost reste assez humide.",
  "explanation": "Compost est masculin singulier : humide."
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
      "image_path": "/elearning/mfk-b1-m4/adverbe-ment.svg",
      "word": "un adverbe"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/intensite-trop.svg",
      "word": "une intensité"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/projet-local.svg",
      "word": "un projet"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/but-subjonctif.svg",
      "word": "un but"
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
  "prompt": "Soulignez les -ment et classez-les : manière ou intensité."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les douze notes, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire en agissant, trop, vraiment',
    'PO',
    $c$Objectif
Débattre : gérondif, participe présent, adverbes en -ment, intensité.

Consigne
Répétez, puis proposez une solution pour la cour.

Support — Modèles de Léa
En agissant tôt, on voit la rive.
Étant patients, nous avançons.
On parle calmement.
On avance lentement.
C'est vraiment utile.
C'est particulièrement fragile.
C'est extrêmement sale après l'orage.
Assez de seaux, pas trop de bruit.
En écoutant, on nuance.
Une voix criant trop fort fatigue.
En compostant ici, on aide Félicie.
On explique clairement le relais.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« En agissant » est un gérondif (en + participe présent).",
  "correct": true,
  "explanation": "En + agissant."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase marque une intensité trop forte ?",
  "options": [
    {
      "text": "On avance lentement",
      "correct": false
    },
    {
      "text": "C'est extrêmement sale",
      "correct": true
    },
    {
      "text": "Assez de seaux",
      "correct": false
    },
    {
      "text": "On parle calmement",
      "correct": false
    }
  ],
  "explanation": "Extrêmement = intensité très haute."
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
      "left": "en + participe",
      "right": "gérondif"
    },
    {
      "left": "étant patients",
      "right": "cause"
    },
    {
      "left": "-ment",
      "right": "adverbe"
    },
    {
      "left": "trop / assez",
      "right": "intensité"
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
  "prompt": "Complétez :\nC'est ___ fragile près des racines.",
  "answer": "particulièrement"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "En",
    "compostant",
    "ici",
    "on",
    "aide",
    "Félicie",
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
  "word": "agissant",
  "hint": "Gérondif : en… tôt, on voit la rive."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Étant trop pressés on avance extrêmement lentes.",
  "correct_sentence": "Étant trop pressés on avance extrêmement lentement.",
  "explanation": "Adverbe : lentement, pas lentes."
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
      "image_path": "/elearning/mfk-b1-m4/intensite-trop.svg",
      "word": "une intensité"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/projet-local.svg",
      "word": "un projet"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/but-subjonctif.svg",
      "word": "un but"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/banderole-agir.svg",
      "word": "une banderole"
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
  "prompt": "Écrivez six phrases : deux en + participe, deux -ment, deux intensités."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis un tour de débat à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon tour de débat',
    'PE',
    $c$Objectif
Écrire un tour de débat avec gérondif, -ment et intensité.

Consigne
Imitez le tour de Joël, sans aller trop vite.

Support — Tour de Joël Mugisha
Joël Mugisha
En agissant ce soir, on soulage vraiment la rive.
Étant trop nombreux, nous piétinerions les racines.
Je parle calmement : assez de seaux, pas trop de discours.
La pente est particulièrement glissante.
En triant les épluchures, on aide extrêmement Félicie.
Une équipe agissant lentement convainc mieux.
Joël
Rive du Seuil
Cahier des racines — débat du mardi
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël veut trop de discours et peu de seaux.",
  "correct": false,
  "explanation": "« assez de seaux, pas trop de discours. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui Joël dit-il aider extrêmement ?",
  "options": [
    {
      "text": "Solange",
      "correct": false
    },
    {
      "text": "Félicie",
      "correct": true
    },
    {
      "text": "Karim",
      "correct": false
    },
    {
      "text": "Lila",
      "correct": false
    }
  ],
  "explanation": "« on aide extrêmement Félicie. »"
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
      "left": "en agissant",
      "right": "ce soir"
    },
    {
      "left": "calmement",
      "right": "manière"
    },
    {
      "left": "particulièrement",
      "right": "glissante"
    },
    {
      "left": "lentement",
      "right": "convaincre"
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
  "prompt": "Complétez :\nJe parle ___ : assez de seaux.",
  "answer": "calmement"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "En",
    "triant",
    "les",
    "épluchures",
    "on",
    "aide",
    "Félicie",
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
  "word": "extremement",
  "hint": "Très très : on aide… Félicie. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En agissant ce soir on soulage vraiment les rives trop vite.",
  "correct_sentence": "En agissant ce soir on soulage vraiment la rive trop vite.",
  "explanation": "Ici : la rive, singulier, le lieu du débat."
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
      "image_path": "/elearning/mfk-b1-m4/projet-local.svg",
      "word": "un projet"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/but-subjonctif.svg",
      "word": "un but"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/banderole-agir.svg",
      "word": "une banderole"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/seau-eau.svg",
      "word": "un seau"
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
  "prompt": "Imitez : dix lignes, deux gérondifs, deux -ment, une intensité."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre tour de débat, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Participe présent, -ment, intensité',
    'EL',
    $c$Objectif
Retenir en agissant / étant, les adverbes en -ment et l'intensité.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
Participe présent : agissant, étant, parlant, triant (invariable).
Gérondif = en + participe : en agissant, en écoutant (moyen, simultanéité).
Participe seul : étant trop pressés, nous piétinons (cause).
Adjectif verbal : une équipe agissant trop vite (qui agit).
Adverbes en -ment : lent / lente → lentement ; clair → clairement.
-ent → -emment : récent → récemment. -ant → -amment : constant → constamment.
Intensité : assez (suffisant) / trop (excessif) / vraiment / particulièrement / extrêmement.
Place : trop vite, assez humide, vraiment utile, particulièrement fragile.
Ne pas dire : en agissant de (le de est de trop).
Ne pas dire : extrêmement lentes pour un verbe (il faut l'adverbe).
Assez de + nom / assez + adjectif.
Trop de + nom / trop + adjectif / trop + adverbe.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le gérondif se forme avec en + participe présent.",
  "correct": true,
  "explanation": "En agissant."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Récent » donne quel adverbe ?",
  "options": [
    {
      "text": "récemment",
      "correct": true
    },
    {
      "text": "récentment",
      "correct": false
    },
    {
      "text": "récemmant",
      "correct": false
    },
    {
      "text": "récentemment",
      "correct": false
    }
  ],
  "explanation": "-ent → -emment : récemment."
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
      "left": "en agissant",
      "right": "gérondif"
    },
    {
      "left": "étant trop pressés",
      "right": "cause"
    },
    {
      "left": "clairement",
      "right": "manière"
    },
    {
      "left": "trop / assez",
      "right": "dose"
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
  "prompt": "Complétez :\nOn avance ___ pour protéger les racines.",
  "answer": "lentement"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Étant",
    "patients",
    "nous",
    "avançons",
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
  "word": "clairement",
  "hint": "Adverbe de clair : parler… pour éviter les rumeurs."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En agissant de maintenant on avance trop vite.",
  "correct_sentence": "En agissant maintenant on avance trop vite.",
  "explanation": "Gérondif : en + participe, sans de."
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
      "image_path": "/elearning/mfk-b1-m4/but-subjonctif.svg",
      "word": "un but"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/banderole-agir.svg",
      "word": "une banderole"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/seau-eau.svg",
      "word": "un seau"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/eco-geste.svg",
      "word": "un geste"
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
  "prompt": "Transformez : agit → en agissant ; clair → adverbe ; trop / assez + trois noms."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et quatre exemples."
}$j$::jsonb,
    9
  );

  -- ===== Un projet pour la rive =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un projet pour la rive'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un projet pour la rive', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Présenter le projet rive',
    'CO',
    $c$Objectif
Comprendre un projet local et le but : pour, afin de, pour que, afin que.

Consigne
Lisez la présentation. Quel but ? Qui doit agir ?

Support — Cour du Seuil, banderole ocre
Patrick : Nous présentons un projet pour la rive du figuier.
Léa : On plante pour retenir la terre, afin de calmer l'eau.
Marc : Je parle fort pour que les enfants entendent le plan.
Hawa : On range les seaux afin que Félicie trouve tout le matin.
Joël : Venez signer pour que Solange lise le Cahier des racines.
Rose : On incite les voisins à relayer, pas à crier.
Aline : Un projet local : compost, sacs, horaires, rien de plus.
Karim : Afin de convaincre le Bureau, on reste précis.
Lila : Radio Figuier répète pour que personne n'arrive trop tard.
Dieudonné : Je couds des sacs pour porter sans déchirer.
Félicie : Venez tôt afin de préparer la Table des Sources.
Solange : J'écoute pour que le Bureau des Escales tranche juste.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa plante pour retenir la terre, afin de calmer l'eau.",
  "correct": true,
  "explanation": "Léa : « pour retenir la terre, afin de calmer l'eau. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi Marc parle-t-il fort ?",
  "options": [
    {
      "text": "Pour fermer la rive",
      "correct": false
    },
    {
      "text": "Pour que les enfants entendent le plan",
      "correct": true
    },
    {
      "text": "Afin de vendre des sacs",
      "correct": false
    },
    {
      "text": "Pour que Radio Figuier s'arrête",
      "correct": false
    }
  ],
  "explanation": "« pour que les enfants entendent. »"
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
      "left": "pour + infinitif",
      "right": "même sujet"
    },
    {
      "left": "afin de + infinitif",
      "right": "même sujet, plus soigné"
    },
    {
      "left": "pour que + subj.",
      "right": "autre sujet"
    },
    {
      "left": "afin que + subj.",
      "right": "autre sujet, soigné"
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
  "prompt": "Complétez :\nOn range les seaux afin ___ Félicie trouve tout.",
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
    "On",
    "plante",
    "pour",
    "retenir",
    "la",
    "terre",
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
  "word": "projet",
  "hint": "Un plan local pour la rive, présenté sous le figuier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je parle fort pour que les enfants entendre le plan.",
  "correct_sentence": "Je parle fort pour que les enfants entendent le plan.",
  "explanation": "Pour que + subjonctif : entendent."
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
      "image_path": "/elearning/mfk-b1-m4/banderole-agir.svg",
      "word": "une banderole"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/seau-eau.svg",
      "word": "un seau"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/eco-geste.svg",
      "word": "un geste"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/persuader-joel.svg",
      "word": "une persuasion"
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
  "prompt": "Classez quatre buts : infinitif ou subjonctif, et qui est le sujet."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On plante pour retenir. Afin de calmer l'eau. Pour que les enfants entendent."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Affiche du projet local',
    'CE',
    $c$Objectif
Lire une affiche qui présente et incite, avec pour / afin de / pour que / afin que.

Consigne
Lisez l'affiche, sans aller trop vite.

Support — Affiche épinglée au figuier
Projet « Rive du Seuil » — appel
Nous agissons pour protéger le figuier et la petite rivière.
Venez le jeudi afin de voir le plan, les seaux, les sacs.
Signez pour que Solange porte le dossier au Bureau des Escales.
Laissez un relais afin que personne ne reste seul le soir.
On incite : parlez à un voisin, pas à toute la rue d'un coup.
Patrick coordonne pour tenir le rythme.
Léa note afin de garder les heures justes.
Marc filme pour que Radio Figuier montre le geste, pas le bruit.
Hawa prépare l'eau afin que le compost ne sèche pas.
Dieudonné tend les sacs pour porter sans perdre.
Félicie ouvre la table afin que chacun signe au calme.
Rose : un projet local, assez clair, pas trop large.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'affiche demande de parler à toute la rue d'un coup.",
  "correct": false,
  "explanation": "« parlez à un voisin, pas à toute la rue d'un coup. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi signer, d'après l'affiche ?",
  "options": [
    {
      "text": "Pour fermer le compost",
      "correct": false
    },
    {
      "text": "Pour que Solange porte le dossier au Bureau",
      "correct": true
    },
    {
      "text": "Afin de vendre le figuier",
      "correct": false
    },
    {
      "text": "Pour que Félicie parte",
      "correct": false
    }
  ],
  "explanation": "« pour que Solange porte le dossier. »"
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
      "left": "pour protéger",
      "right": "figuier et rivière"
    },
    {
      "left": "afin de voir",
      "right": "le plan"
    },
    {
      "left": "pour que Solange porte",
      "right": "le dossier"
    },
    {
      "left": "afin que personne ne reste",
      "right": "seul"
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
  "prompt": "Complétez :\nSignez pour ___ Solange porte le dossier.",
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
    "Venez",
    "le",
    "jeudi",
    "afin",
    "de",
    "voir",
    "le",
    "plan",
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
  "word": "inciter",
  "hint": "Pousser un voisin à venir : on… sans crier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Signez pour que Solange porte le dossier afin de que le Bureau lise.",
  "correct_sentence": "Signez pour que Solange porte le dossier afin que le Bureau lise.",
  "explanation": "Afin que + subjonctif, pas afin de que."
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
      "image_path": "/elearning/mfk-b1-m4/seau-eau.svg",
      "word": "un seau"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/eco-geste.svg",
      "word": "un geste"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/persuader-joel.svg",
      "word": "une persuasion"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/compost-cour.svg",
      "word": "un compost"
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
  "prompt": "Recopiez l'affiche et encadrez pour, afin de, pour que, afin que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'affiche du projet, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire le but',
    'PO',
    $c$Objectif
Présenter un projet et inciter : infinitif et subjonctif de but.

Consigne
Répétez, puis présentez un geste pour la rive.

Support — Modèles de Karim
On agit pour protéger la rive.
On vient afin de voir le plan.
Je parle pour que tu entendes.
Nous rangeons afin que Félicie trouve.
Signez pour que Solange lise.
Incitez un voisin à relayer.
On filme pour montrer le geste.
On note afin de garder l'heure.
Je couds pour que les sacs tiennent.
On ouvre tôt afin que chacun signe.
N'élargissez pas trop le projet.
Restez locaux, assez clairs.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Pour que et afin que demandent le subjonctif.",
  "correct": true,
  "explanation": "Pour que tu entendes / afin que Félicie trouve."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Même sujet : quelle construction ?",
  "options": [
    {
      "text": "pour que + infinitif",
      "correct": false
    },
    {
      "text": "pour + infinitif",
      "correct": true
    },
    {
      "text": "afin que + infinitif",
      "correct": false
    },
    {
      "text": "pour de + subjonctif",
      "correct": false
    }
  ],
  "explanation": "Même sujet : pour / afin de + infinitif."
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
      "left": "pour + infinitif",
      "right": "même sujet"
    },
    {
      "left": "afin de",
      "right": "même sujet, soigné"
    },
    {
      "left": "pour que",
      "right": "autre sujet"
    },
    {
      "left": "afin que",
      "right": "autre sujet, soigné"
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
  "prompt": "Complétez :\nJe parle pour que tu ___. (entendre)",
  "answer": "entendes"
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
    "agit",
    "pour",
    "protéger",
    "la",
    "rive",
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
  "word": "afin",
  "hint": "Plus soigné que pour : … de voir le plan."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On vient afin que voir le plan sous le figuier.",
  "correct_sentence": "On vient afin de voir le plan sous le figuier.",
  "explanation": "Même sujet : afin de + infinitif."
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
      "image_path": "/elearning/mfk-b1-m4/eco-geste.svg",
      "word": "un geste"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/persuader-joel.svg",
      "word": "une persuasion"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/compost-cour.svg",
      "word": "un compost"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/arbre-proteger.svg",
      "word": "un arbre"
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
  "prompt": "Écrivez six buts : deux pour, deux afin de, un pour que, un afin que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis un appel à un voisin."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon projet local',
    'PE',
    $c$Objectif
Écrire la présentation d'un projet et inciter à rejoindre.

Consigne
Imitez le projet de Hawa, sans aller trop vite.

Support — Projet de Hawa Diallo
Hawa Diallo
Nous présentons un projet pour la rive du Seuil.
On plante pour retenir la terre afin de calmer l'eau.
Venez jeudi pour que Solange voie les signatures.
On range les seaux afin que Félicie trouve tout.
J'incite un voisin à relayer, pas à crier.
Marc filme pour que Radio Figuier montre le geste.
Hawa
Rive du figuier — Rukiri-Nord
Cahier des racines
Projet local : assez clair, pas trop large.
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa incite à crier dans la rue.",
  "correct": false,
  "explanation": "« à relayer, pas à crier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quand Hawa invite-t-elle à venir ?",
  "options": [
    {
      "text": "Lundi",
      "correct": false
    },
    {
      "text": "Jeudi",
      "correct": true
    },
    {
      "text": "Dimanche",
      "correct": false
    },
    {
      "text": "À minuit",
      "correct": false
    }
  ],
  "explanation": "« Venez jeudi. »"
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
      "left": "pour retenir",
      "right": "la terre"
    },
    {
      "left": "afin de calmer",
      "right": "l'eau"
    },
    {
      "left": "pour que Solange voie",
      "right": "signatures"
    },
    {
      "left": "afin que Félicie trouve",
      "right": "les seaux"
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
  "prompt": "Complétez :\nVenez jeudi pour que Solange ___ les signatures.",
  "answer": "voie"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'incite",
    "un",
    "voisin",
    "à",
    "relayer",
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
  "word": "retenir",
  "hint": "On plante pour… la terre sur la pente."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Venez jeudi pour que Solange vois les signatures.",
  "correct_sentence": "Venez jeudi pour que Solange voie les signatures.",
  "explanation": "Subjonctif de voir : qu'elle voie."
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
      "image_path": "/elearning/mfk-b1-m4/persuader-joel.svg",
      "word": "une persuasion"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/compost-cour.svg",
      "word": "un compost"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/arbre-proteger.svg",
      "word": "un arbre"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/mesurer-impact.svg",
      "word": "un impact"
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
  "prompt": "Imitez : un projet de dix lignes, deux infinitifs de but, deux subjonctifs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre projet, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Infinitif et subjonctif de but',
    'EL',
    $c$Objectif
Retenir pour, afin de, pour que, afin que.

Consigne
Apprenez la fiche.

Support — Fiche du projet
Même sujet → infinitif :
pour + infinitif : on plante pour retenir.
afin de + infinitif : on vient afin de voir (plus soigné).
Sujet différent → subjonctif :
pour que + subjonctif : je parle pour que tu entendes.
afin que + subjonctif : on range afin qu'elle trouve.
Subjonctif utile : que je sois, que tu entendes, qu'il lise, que nous tenions,
que vous voyiez, qu'elles portent, qu'il accepte, qu'elle voie.
Incitement : venez, signez, parlez à un voisin, n'élargissez pas trop.
Ne pas dire : afin de que. On dit afin que.
Ne pas dire : pour que + infinitif (pour que entendre).
Ne pas dire : pour de protéger.
Après pour que / afin que : ne… pas se place autour du verbe.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « afin de que le Bureau lise ».",
  "correct": false,
  "explanation": "Afin que, pas afin de que."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Je filme ___ Radio Figuier montre le geste. »",
  "options": [
    {
      "text": "pour",
      "correct": false
    },
    {
      "text": "afin de",
      "correct": false
    },
    {
      "text": "pour que",
      "correct": true
    },
    {
      "text": "pour de",
      "correct": false
    }
  ],
  "explanation": "Sujet différent : pour que + subjonctif."
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
      "left": "pour / afin de",
      "right": "infinitif"
    },
    {
      "left": "pour que / afin que",
      "right": "subjonctif"
    },
    {
      "left": "même sujet",
      "right": "infinitif"
    },
    {
      "left": "autre sujet",
      "right": "subjonctif"
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
  "prompt": "Complétez :\nOn range afin ___ elle trouve les seaux.",
  "answer": "qu'"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Signez",
    "pour",
    "que",
    "Solange",
    "lise",
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
  "word": "accepte",
  "hint": "Subjonctif : pour que le Bureau… le dossier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je parle pour que tu entendre le plan de la rive.",
  "correct_sentence": "Je parle pour que tu entendes le plan de la rive.",
  "explanation": "Pour que + subjonctif : entendes."
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
      "image_path": "/elearning/mfk-b1-m4/compost-cour.svg",
      "word": "un compost"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/arbre-proteger.svg",
      "word": "un arbre"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/mesurer-impact.svg",
      "word": "un impact"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/graphique-riviere.svg",
      "word": "un graphique"
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
  "prompt": "Transformez six buts : trois même sujet, trois sujet différent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six exemples."
}$j$::jsonb,
    9
  );

  -- ===== Persuader d'agir =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Persuader d''agir'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Persuader d''agir', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Persuader près du compost',
    'CO',
    $c$Objectif
Comprendre des éco-gestes et la persuasion : tu pourrais, si on, il vaudrait mieux.

Consigne
Lisez le dialogue. Qui persuade ? Quel geste ?

Support — Compost de la cour, seaux alignés
Joël : Tu pourrais apporter tes épluchures ici, pas plus loin.
Patrick : Si on commençait petit, le tas resterait propre.
Aline : Il vaudrait mieux rincer les seaux le soir.
Léa : Tu pourrais prévenir Rose avant de trop charger.
Marc : Si on filmait le geste, Radio Figuier relayerait sans crier.
Hawa : Il vaudrait mieux laisser l'eau à la rive, pas au chemin.
Rose : Tu pourrais signer d'abord, discuter ensuite.
Karim : Si on évitait le feu près de l'eau, Félicie serait plus calme.
Lila : Il vaudrait mieux répéter l'heure deux fois, assez lentement.
Dieudonné : Tu pourrais plier le sac plutôt que le jeter.
Félicie : Si on rangeait tôt, la Table des Sources resterait libre.
Solange : Il vaudrait mieux un dossier court pour le Bureau.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline conseille de rincer les seaux le soir.",
  "correct": true,
  "explanation": "Aline : « Il vaudrait mieux rincer les seaux le soir. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que propose Patrick pour le tas ?",
  "options": [
    {
      "text": "Tout brûler d'un coup",
      "correct": false
    },
    {
      "text": "Commencer petit",
      "correct": true
    },
    {
      "text": "Fermer le compost",
      "correct": false
    },
    {
      "text": "Partir à Val-des-Peupliers",
      "correct": false
    }
  ],
  "explanation": "« Si on commençait petit. »"
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
      "left": "tu pourrais",
      "right": "suggestion douce"
    },
    {
      "left": "si on + imparfait",
      "right": "hypothèse / invitation"
    },
    {
      "left": "il vaudrait mieux",
      "right": "conseil plus fort"
    },
    {
      "left": "épluchures ici",
      "right": "éco-geste"
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
  "prompt": "Complétez :\nIl ___ mieux rincer les seaux le soir.",
  "answer": "vaudrait"
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
    "pourrais",
    "apporter",
    "tes",
    "épluchures",
    "ici",
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
  "word": "pourrais",
  "hint": "Suggestion à tu : tu… apporter un seau."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il vaudrait mieux de rincer les seaux le soir.",
  "correct_sentence": "Il vaudrait mieux rincer les seaux le soir.",
  "explanation": "Il vaudrait mieux + infinitif, sans de."
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
      "image_path": "/elearning/mfk-b1-m4/arbre-proteger.svg",
      "word": "un arbre"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/mesurer-impact.svg",
      "word": "un impact"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/graphique-riviere.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/de-plus-en-plus.svg",
      "word": "une hausse"
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
  "prompt": "Notez trois éco-gestes et la formule de persuasion de chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Tu pourrais apporter tes épluchures. Si on commençait petit. Il vaudrait mieux rincer."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Feuille des éco-gestes',
    'CE',
    $c$Objectif
Lire une feuille qui persuade d'agir par petits gestes.

Consigne
Lisez la feuille, sans aller trop vite.

Support — Feuille de Joël, compost de la cour
Éco-gestes du Seuil — pour persuader sans crier
1. Tu pourrais trier les épluchures avant le marché.
2. Si on fermait bien le couvercle, les bêtes viendraient moins.
3. Il vaudrait mieux porter un seau à deux que trop charger.
4. Tu pourrais rincer, puis poser le seau à l'ombre du figuier.
5. Si on évitait le plastique près de l'eau, la rive respirerait.
6. Il vaudrait mieux prévenir Félicie avant un grand tas.
7. Tu pourrais signer le Cahier des racines d'une ligne claire.
8. Si on répétait l'heure à Radio Figuier, moins de monde arriverait trop tard.
9. Il vaudrait mieux un geste tenu qu'un discours extrêmement long.
10. Rose : tu pourrais relayer à un seul voisin, assez.
11. Karim : si on notait les seaux, aucun ne se perdrait.
12. Solange : il vaudrait mieux joindre deux pages, pas vingt.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La feuille recommande un discours extrêmement long.",
  "correct": false,
  "explanation": "Point 9 : « un geste tenu qu'un discours extrêmement long. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que se passe-t-il si on ferme bien le couvercle ?",
  "options": [
    {
      "text": "Les bêtes viennent plus",
      "correct": false
    },
    {
      "text": "Les bêtes viennent moins",
      "correct": true
    },
    {
      "text": "Le figuier tombe",
      "correct": false
    },
    {
      "text": "Le Bureau ferme",
      "correct": false
    }
  ],
  "explanation": "« les bêtes viendraient moins. »"
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
      "left": "tu pourrais trier",
      "right": "épluchures"
    },
    {
      "left": "si on fermait",
      "right": "couvercle"
    },
    {
      "left": "il vaudrait mieux porter",
      "right": "à deux"
    },
    {
      "left": "si on notait",
      "right": "les seaux"
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
  "prompt": "Complétez :\n___ on fermait bien le couvercle, les bêtes viendraient moins.",
  "answer": "Si"
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
    "vaudrait",
    "mieux",
    "prévenir",
    "Félicie",
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
  "word": "couvercle",
  "hint": "On le ferme bien pour que les bêtes viennent moins."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si on fermera bien le couvercle les bêtes viendraient moins.",
  "correct_sentence": "Si on fermait bien le couvercle les bêtes viendraient moins.",
  "explanation": "Si + imparfait pour une suggestion."
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
      "image_path": "/elearning/mfk-b1-m4/mesurer-impact.svg",
      "word": "un impact"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/graphique-riviere.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/de-plus-en-plus.svg",
      "word": "une hausse"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/loupe-chiffre.svg",
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
  "prompt": "Recopiez six gestes et indiquez la formule : tu pourrais / si on / il vaudrait mieux."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la feuille des éco-gestes, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Persuader sans crier',
    'PO',
    $c$Objectif
Persuader : tu pourrais, si on, il vaudrait mieux.

Consigne
Répétez, puis persuadez un voisin d'un éco-geste.

Support — Modèles de Rose
Tu pourrais apporter un seau.
Tu pourrais signer ici.
Si on commençait petit…
Si on évitait le feu près de l'eau…
Il vaudrait mieux rincer le soir.
Il vaudrait mieux un dossier court.
Tu pourrais prévenir Aline.
Si on rangeait tôt, la table resterait libre.
Il vaudrait mieux porter à deux.
N'obligez pas : persuadez.
Assez d'un geste tenu.
Pas trop de discours.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il vaudrait mieux » est un conseil au conditionnel.",
  "correct": true,
  "explanation": "Conditionnel de valoir + infinitif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est une suggestion à tu ?",
  "options": [
    {
      "text": "Il vaudrait mieux rincer",
      "correct": false
    },
    {
      "text": "Tu pourrais apporter un seau",
      "correct": true
    },
    {
      "text": "Si on commençait petit",
      "correct": false
    },
    {
      "text": "Signez tous maintenant",
      "correct": false
    }
  ],
  "explanation": "Tu pourrais + infinitif."
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
      "left": "tu pourrais",
      "right": "tu"
    },
    {
      "left": "si on + imparfait",
      "right": "groupe"
    },
    {
      "left": "il vaudrait mieux",
      "right": "conseil"
    },
    {
      "left": "persuader",
      "right": "sans obliger"
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
  "prompt": "Complétez :\nTu ___ apporter un seau.",
  "answer": "pourrais"
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
    "on",
    "commençait",
    "petit",
    "le",
    "tas",
    "resterait",
    "propre",
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
  "word": "vaudrait",
  "hint": "Il… mieux rincer : conseil au conditionnel."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tu pourrais d'apporter un seau près du compost.",
  "correct_sentence": "Tu pourrais apporter un seau près du compost.",
  "explanation": "Pouvoir + infinitif, sans de."
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
      "image_path": "/elearning/mfk-b1-m4/graphique-riviere.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/de-plus-en-plus.svg",
      "word": "une hausse"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/loupe-chiffre.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/convaincre-bureau.svg",
      "word": "un bureau"
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
  "prompt": "Écrivez six persuasions : deux de chaque formule."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis deux phrases à un voisin."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon mot pour persuader',
    'PE',
    $c$Objectif
Écrire un mot qui persuade d'un éco-geste.

Consigne
Imitez le mot de Dieudonné, sans aller trop vite.

Support — Mot de Dieudonné Hakizimana
Dieudonné Hakizimana
Tu pourrais plier le sac plutôt que le jeter.
Si on commençait par trois sacs, l'atelier suivrait.
Il vaudrait mieux coudre un fond solide.
Tu pourrais prévenir Joël avant un grand tas.
Si on évitait le plastique près de l'eau, la rive respirerait.
Il vaudrait mieux un geste tenu qu'un discours trop long.
Dieudonné
Atelier du Tissu — Seuil des Sources
Cahier des racines
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné propose de commencer par trois sacs.",
  "correct": true,
  "explanation": "« Si on commençait par trois sacs. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que vaudrait-il mieux coudre ?",
  "options": [
    {
      "text": "Un drapeau de ville",
      "correct": false
    },
    {
      "text": "Un fond solide",
      "correct": true
    },
    {
      "text": "Une cravate",
      "correct": false
    },
    {
      "text": "Un rideau de scène",
      "correct": false
    }
  ],
  "explanation": "« un fond solide. »"
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
      "left": "tu pourrais plier",
      "right": "le sac"
    },
    {
      "left": "si on commençait",
      "right": "trois sacs"
    },
    {
      "left": "il vaudrait mieux coudre",
      "right": "fond solide"
    },
    {
      "left": "si on évitait",
      "right": "le plastique"
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
  "prompt": "Complétez :\nIl vaudrait ___ coudre un fond solide.",
  "answer": "mieux"
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
    "pourrais",
    "plier",
    "le",
    "sac",
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
  "word": "plier",
  "hint": "Le contraire de jeter le sac : le… d'abord."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si on commencera par trois sacs l'atelier suivrait.",
  "correct_sentence": "Si on commençait par trois sacs l'atelier suivrait.",
  "explanation": "Si + imparfait, pas le futur."
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
      "image_path": "/elearning/mfk-b1-m4/de-plus-en-plus.svg",
      "word": "une hausse"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/loupe-chiffre.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/convaincre-bureau.svg",
      "word": "un bureau"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/lettre-solange.svg",
      "word": "une lettre"
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
  "prompt": "Imitez : dix lignes, les trois formules de persuasion, deux éco-gestes."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Persuader : tu pourrais, si on, il vaudrait mieux',
    'EL',
    $c$Objectif
Retenir les formes pour persuader d'un geste.

Consigne
Apprenez la fiche.

Support — Fiche de persuasion
Tu pourrais + infinitif : suggestion douce à une personne.
Vous pourriez + infinitif : même idée, vouvoiement.
Si on + imparfait, + conditionnel : invitation collective.
Si on commençait petit, le tas resterait propre.
Il vaudrait mieux + infinitif : conseil plus net (sans de).
Il vaudrait mieux que + subjonctif : autre sujet (il vaudrait mieux qu'elle lise).
Éco-gestes du Seuil : trier, rincer, porter à deux, fermer le couvercle,
éviter le plastique près de l'eau, plier un sac, signer une ligne.
Persuader ≠ ordonner : assez d'un geste, pas trop de discours.
Ne pas dire : tu pourrais de + infinitif.
Ne pas dire : il vaudrait mieux de + infinitif.
Ne pas dire : si on + futur pour cette suggestion.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « il vaudrait mieux de rincer ».",
  "correct": false,
  "explanation": "Sans de : il vaudrait mieux rincer."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase invite le groupe ?",
  "options": [
    {
      "text": "Tu pourrais signer",
      "correct": false
    },
    {
      "text": "Si on rangeait tôt",
      "correct": true
    },
    {
      "text": "Il faut que tu signes tout de suite",
      "correct": false
    },
    {
      "text": "Signez ou partez",
      "correct": false
    }
  ],
  "explanation": "Si on + imparfait."
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
      "left": "tu pourrais",
      "right": "suggestion"
    },
    {
      "left": "si on + imparfait",
      "right": "invitation"
    },
    {
      "left": "il vaudrait mieux",
      "right": "conseil"
    },
    {
      "left": "éco-geste",
      "right": "petit acte"
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
  "prompt": "Complétez :\nSi on ___ petit, le tas resterait propre. (commencer)",
  "answer": "commençait"
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
    "vaudrait",
    "mieux",
    "un",
    "dossier",
    "court",
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
  "word": "rincer",
  "hint": "Il vaudrait mieux… les seaux le soir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Vous pourriez de prévenir Aline avant le grand tas.",
  "correct_sentence": "Vous pourriez prévenir Aline avant le grand tas.",
  "explanation": "Pourriez + infinitif, sans de."
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
      "image_path": "/elearning/mfk-b1-m4/loupe-chiffre.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/convaincre-bureau.svg",
      "word": "un bureau"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/lettre-solange.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/tampon-projet.svg",
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
  "prompt": "Écrivez un mini-dialogue de persuasion (huit répliques, trois formules)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et trois persuasions à vous."
}$j$::jsonb,
    9
  );

  -- ===== Mesurer l'impact =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Mesurer l''impact'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Mesurer l''impact', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Chiffres sous le figuier',
    'CO',
    $c$Objectif
Comprendre des chiffres inventés et de plus en plus / de moins en moins.

Consigne
Lisez le dialogue. Qu'est-ce qui augmente ? Qu'est-ce qui diminue ?

Support — Micro de Radio Figuier, ombre du figuier
Lila : Cette semaine : 12 seaux, 3 sacs de compost, 18 signatures.
Marc : La rive est de plus en plus claire, de moins en moins d'odeurs.
Patrick : On a de plus en plus de relais le matin : 4 puis 7.
Léa : De moins en moins de plastique près des racines : 20 morceaux, puis 9.
Joël : Le tas pèse de plus en plus : 8 kilos, puis 14.
Hawa : On met de moins en moins d'eau : 6 cruches, puis 4.
Rose : Les enfants viennent de plus en plus tôt : 5, puis 11.
Karim : Le Bureau lit de plus en plus vite nos pages courtes.
Aline : De moins en moins de disputes : 3 la première semaine, 1 ensuite.
Félicie : La table reste de plus en plus libre après le tri.
Dieudonné : 6 sacs tenus, 2 réparés : de moins en moins de pertes.
Solange : 18 noms, ce n'est pas 80 : assez pour commencer.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa dit qu'il y a de moins en moins de plastique près des racines.",
  "correct": true,
  "explanation": "Léa : 20 morceaux, puis 9."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de signatures Lila annonce-t-elle ?",
  "options": [
    {
      "text": "12",
      "correct": false
    },
    {
      "text": "3",
      "correct": false
    },
    {
      "text": "18",
      "correct": true
    },
    {
      "text": "80",
      "correct": false
    }
  ],
  "explanation": "« 18 signatures. »"
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
      "left": "de plus en plus claire",
      "right": "la rive"
    },
    {
      "left": "de moins en moins de plastique",
      "right": "racines"
    },
    {
      "left": "12 seaux",
      "right": "cette semaine"
    },
    {
      "left": "18 signatures",
      "right": "assez pour commencer"
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
  "prompt": "Complétez :\nLa rive est de ___ en plus claire.",
  "answer": "plus"
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
    "de",
    "plus",
    "en",
    "plus",
    "de",
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
  "word": "chiffres",
  "hint": "12 seaux et 18 signatures : des… inventés pour le Seuil."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La rive est de plus en plus de claire après le tri.",
  "correct_sentence": "La rive est de plus en plus claire après le tri.",
  "explanation": "De plus en plus + adjectif, sans de."
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
      "image_path": "/elearning/mfk-b1-m4/convaincre-bureau.svg",
      "word": "un bureau"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/lettre-solange.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/tampon-projet.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/main-signature.svg",
      "word": "une signature"
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
  "prompt": "Relevez quatre chiffres et deux évolutions (plus / moins)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : 12 seaux, 18 signatures. De plus en plus claire. De moins en moins de plastique."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Graphique de la rivière',
    'CE',
    $c$Objectif
Lire un relevé chiffré inventé avec de plus en plus / de moins en moins.

Consigne
Lisez le relevé, sans aller trop vite.

Support — Relevé de Lila Sow
Impact — rivière du Seuil (chiffres du Cahier des racines)
Semaine 1 : 20 plastiques, 8 kilos de compost, 5 relais, 9 signatures.
Semaine 2 : 9 plastiques, 14 kilos, 7 relais, 18 signatures.
La rive devient de plus en plus claire.
On trouve de moins en moins de plastique près du figuier.
Le tas est de plus en plus lourd, de moins en moins d'eau versée (6 puis 4).
Les relais du matin sont de plus en plus nombreux.
Les disputes sont de moins en moins longues : 3 puis 1.
Radio Figuier répète : assez de preuves, pas trop de discours.
Karim : 2 pages lues, le Bureau avance de plus en plus.
Félicie : de moins en moins de seaux oubliés sous la table.
Dieudonné : 6 sacs tenus, de plus en plus solides.
Solange : 18 noms suffisent pour un premier tampon.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "En semaine 2, il y a 18 signatures.",
  "correct": true,
  "explanation": "Semaine 2 : 18 signatures."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que deviennent les disputes ?",
  "options": [
    {
      "text": "De plus en plus longues",
      "correct": false
    },
    {
      "text": "De moins en moins longues",
      "correct": true
    },
    {
      "text": "Elles disparaissent à zéro",
      "correct": false
    },
    {
      "text": "Elles passent à 80",
      "correct": false
    }
  ],
  "explanation": "« de moins en moins longues : 3 puis 1. »"
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
      "left": "20 puis 9",
      "right": "plastiques"
    },
    {
      "left": "8 puis 14",
      "right": "kilos"
    },
    {
      "left": "5 puis 7",
      "right": "relais"
    },
    {
      "left": "9 puis 18",
      "right": "signatures"
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
  "prompt": "Complétez :\nOn trouve de moins en ___ de plastique.",
  "answer": "moins"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Les",
    "relais",
    "sont",
    "de",
    "plus",
    "en",
    "plus",
    "nombreux",
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
  "word": "graphique",
  "hint": "Le relevé de Lila : un… de la rivière, avec des chiffres."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On trouve de moins en moins plastique près du figuier.",
  "correct_sentence": "On trouve de moins en moins de plastique près du figuier.",
  "explanation": "De moins en moins de + nom."
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
      "image_path": "/elearning/mfk-b1-m4/lettre-solange.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/tampon-projet.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/main-signature.svg",
      "word": "une signature"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/riviere-propre.svg",
      "word": "une rivière"
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
  "prompt": "Dessinez le relevé en cinq phrases : deux hausses, deux baisses, un chiffre."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le relevé de Lila, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire l''évolution',
    'PO',
    $c$Objectif
Mesurer l'impact à voix haute : chiffres, de plus en plus, de moins en moins.

Consigne
Répétez, puis commentez deux chiffres du Seuil.

Support — Modèles de Marc
Il y a 12 seaux.
Il y a 18 signatures.
La rive est de plus en plus claire.
On a de plus en plus de relais.
Le plastique est de moins en moins visible.
On met de moins en moins d'eau.
Les disputes sont de moins en moins longues.
Le tas est de plus en plus lourd.
Assez de preuves.
Pas trop de discours.
6 sacs tenus.
2 pages lues.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "De plus en plus de + nom : la quantité augmente.",
  "correct": true,
  "explanation": "De plus en plus de relais."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase décrit une baisse ?",
  "options": [
    {
      "text": "De plus en plus de relais",
      "correct": false
    },
    {
      "text": "De moins en moins d'eau",
      "correct": true
    },
    {
      "text": "18 signatures",
      "correct": false
    },
    {
      "text": "Le tas est de plus en plus lourd",
      "correct": false
    }
  ],
  "explanation": "De moins en moins d'eau."
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
      "left": "de plus en plus + adj.",
      "right": "qualité qui monte"
    },
    {
      "left": "de plus en plus de + nom",
      "right": "quantité qui monte"
    },
    {
      "left": "de moins en moins + adj.",
      "right": "qualité qui baisse"
    },
    {
      "left": "de moins en moins de + nom",
      "right": "quantité qui baisse"
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
  "prompt": "Complétez :\nOn a de plus en plus ___ relais.",
  "answer": "de"
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
    "rive",
    "est",
    "de",
    "plus",
    "en",
    "plus",
    "claire",
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
  "word": "relais",
  "hint": "De plus en plus de… le matin : 4 puis 7."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On a de plus en plus relais le matin sous le figuier.",
  "correct_sentence": "On a de plus en plus de relais le matin sous le figuier.",
  "explanation": "De plus en plus de + nom."
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
      "image_path": "/elearning/mfk-b1-m4/tampon-projet.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/main-signature.svg",
      "word": "une signature"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/riviere-propre.svg",
      "word": "une rivière"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/figuier-ombre.svg",
      "word": "un figuier"
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
  "prompt": "Écrivez six mesures : trois hausses, trois baisses, avec au moins un chiffre."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis deux phrases chiffrées à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon relevé d''impact',
    'PE',
    $c$Objectif
Écrire un relevé avec des chiffres inventés et des évolutions.

Consigne
Imitez le relevé de Rose, sans aller trop vite.

Support — Relevé de Rose Iradukunda
Rose Iradukunda
Semaine 1 : 20 plastiques, 5 relais, 9 signatures.
Semaine 2 : 9 plastiques, 7 relais, 18 signatures.
La rive est de plus en plus claire.
On trouve de moins en moins de plastique.
Les relais sont de plus en plus nombreux.
Les disputes sont de moins en moins longues.
Assez de preuves pour le Bureau, pas trop de discours.
Rose
Cahier des racines
Seuil des Sources — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose passe de 9 à 18 signatures.",
  "correct": true,
  "explanation": "Semaine 1 : 9. Semaine 2 : 18."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que dit Rose des discours ?",
  "options": [
    {
      "text": "Il en faut extrêmement",
      "correct": false
    },
    {
      "text": "Pas trop de discours",
      "correct": true
    },
    {
      "text": "Plus de discours que de preuves",
      "correct": false
    },
    {
      "text": "Aucun discours jamais",
      "correct": false
    }
  ],
  "explanation": "« pas trop de discours. »"
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
      "left": "20 puis 9",
      "right": "plastiques"
    },
    {
      "left": "5 puis 7",
      "right": "relais"
    },
    {
      "left": "de plus en plus claire",
      "right": "rive"
    },
    {
      "left": "de moins en moins longues",
      "right": "disputes"
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
  "prompt": "Complétez :\nLes relais sont de plus en plus ___.",
  "answer": "nombreux"
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
    "trouve",
    "de",
    "moins",
    "en",
    "moins",
    "de",
    "plastique",
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
  "word": "preuves",
  "hint": "Assez de… pour le Bureau : chiffres et gestes tenus."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les relais sont de plus en plus nombreuse le matin.",
  "correct_sentence": "Les relais sont de plus en plus nombreux le matin.",
  "explanation": "Relais est masculin pluriel : nombreux."
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
      "image_path": "/elearning/mfk-b1-m4/main-signature.svg",
      "word": "une signature"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/riviere-propre.svg",
      "word": "une rivière"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/figuier-ombre.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/groupe-engagement.svg",
      "word": "un groupe"
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
  "prompt": "Imitez : un relevé de dix lignes, quatre chiffres, deux évolutions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre relevé, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — De plus en plus, de moins en moins',
    'EL',
    $c$Objectif
Retenir les structures d'évolution et la lecture de chiffres.

Consigne
Apprenez la fiche.

Support — Fiche des mesures
De plus en plus + adjectif : de plus en plus claire / lourds / nombreux.
De moins en moins + adjectif : de moins en moins longue / visibles.
De plus en plus de + nom : de plus en plus de relais.
De moins en moins de + nom : de moins en moins de plastique.
Devant voyelle : de moins en moins d'eau (de → d').
On peut + verbe : on vient de plus en plus tôt.
Chiffres du Seuil (inventés) : 12 seaux, 3 sacs, 18 signatures, 8 puis 14 kilos.
Assez de + nom / trop de + nom pour juger l'impact.
Accord de l'adjectif : relais nombreux, rive claire, disputes longues.
Ne pas dire : de plus en plus de claire.
Ne pas dire : de moins en moins plastique (sans de).
Comparer deux semaines, pas inventer une ville réelle.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « de plus en plus de claire ».",
  "correct": false,
  "explanation": "Adjectif : de plus en plus claire (sans de)."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« De moins en moins ___ eau. »",
  "options": [
    {
      "text": "de",
      "correct": false
    },
    {
      "text": "d'",
      "correct": true
    },
    {
      "text": "des",
      "correct": false
    },
    {
      "text": "du",
      "correct": false
    }
  ],
  "explanation": "Devant voyelle : d'eau."
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
      "left": "plus en plus + adj.",
      "right": "hausse de qualité"
    },
    {
      "left": "plus en plus de + nom",
      "right": "hausse de quantité"
    },
    {
      "left": "moins en moins + adj.",
      "right": "baisse de qualité"
    },
    {
      "left": "moins en moins de + nom",
      "right": "baisse de quantité"
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
  "prompt": "Complétez :\nOn met de moins en moins ___ eau.",
  "answer": "d'"
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
    "tas",
    "est",
    "de",
    "plus",
    "en",
    "plus",
    "lourd",
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
  "word": "nombreux",
  "hint": "Les relais sont de plus en plus… : accord masculin pluriel."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On met de moins en moins de eau dans le compost.",
  "correct_sentence": "On met de moins en moins d'eau dans le compost.",
  "explanation": "De + eau → d'eau."
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
      "image_path": "/elearning/mfk-b1-m4/riviere-propre.svg",
      "word": "une rivière"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/figuier-ombre.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/groupe-engagement.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/micro-radio.svg",
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
  "prompt": "Rédigez un tableau : quatre hausses, quatre baisses, avec chiffres inventés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six mesures."
}$j$::jsonb,
    9
  );

  -- ===== Convaincre le Bureau =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Convaincre le Bureau'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Convaincre le Bureau', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Préparer la lettre à Solange',
    'CO',
    $c$Objectif
Comprendre comment on prépare une lettre et une pétition pour le Bureau.

Consigne
Lisez le dialogue. Que doit contenir la lettre ?

Support — Table des Sources, Cahier des racines ouvert
Patrick : On écrit à Solange pour que le Bureau des Escales tamponne le projet.
Léa : Tout d'abord les faits : 18 signatures, 12 seaux, une rive plus claire.
Marc : Ensuite une demande nette : un tampon, pas vingt pages.
Hawa : On joint le Cahier des racines afin qu'elle lise les noms.
Joël : Il vaudrait mieux rester polis et centrés sur la rive.
Rose : Si on signait tous sur une feuille, le geste serait clair.
Aline : Tu pourrais relire pour qu'aucune phrase ne parte trop vite.
Karim : La pétition tient en une page : assez, pas trop.
Lila : Radio Figuier lira la lettre afin que les absents sachent.
Dieudonné : J'ajoute trois sacs tenus pour montrer l'atelier.
Félicie : Je prie Solange de passer à la table jeudi.
Solange : J'ouvre le courrier ; convaincre, ce n'est pas crier.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La pétition doit tenir en une page.",
  "correct": true,
  "explanation": "Karim : « La pétition tient en une page. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que joint-on afin que Solange lise les noms ?",
  "options": [
    {
      "text": "Un billet de minibus",
      "correct": false
    },
    {
      "text": "Le Cahier des racines",
      "correct": true
    },
    {
      "text": "Une cravate",
      "correct": false
    },
    {
      "text": "Un contrat de ville",
      "correct": false
    }
  ],
  "explanation": "Hawa : « On joint le Cahier des racines. »"
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
      "left": "lettre à Solange",
      "right": "Bureau des Escales"
    },
    {
      "left": "18 signatures",
      "right": "faits"
    },
    {
      "left": "pétition",
      "right": "une page"
    },
    {
      "left": "Cahier des racines",
      "right": "les noms"
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
  "prompt": "Complétez :\nOn écrit à Solange pour que le Bureau ___ le projet.",
  "answer": "tamponne"
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
    "joint",
    "le",
    "Cahier",
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
  "word": "petition",
  "hint": "Une page de noms pour le Bureau. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On écrit à Solange pour que le Bureau tamponne le projets.",
  "correct_sentence": "On écrit à Solange pour que le Bureau tamponne le projet.",
  "explanation": "Projet au singulier."
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
      "image_path": "/elearning/mfk-b1-m4/figuier-ombre.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/groupe-engagement.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/micro-radio.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/soleil-demain.svg",
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
  "prompt": "Listez les pièces de la lettre : faits, demande, pièce jointe, ton."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On écrit à Solange. 18 signatures. Une pétition d'une page. On joint le Cahier."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Lettre et pétition',
    'CE',
    $c$Objectif
Lire une lettre-pétition adressée à Solange, jointe au Cahier des racines.

Consigne
Lisez la lettre, sans aller trop vite.

Support — Lettre collective, tampon en attente
Seuil des Sources, Rukiri-Nord
Madame Mukamana,
Nous vous écrivons pour que le Bureau des Escales reconnaisse le projet « Rive du Seuil ».
Tout d'abord les faits : 18 signatures, 12 seaux, de moins en moins de plastique.
Nous agissons afin de protéger le figuier et la petite rivière.
Nous joignons le Cahier des racines afin que vous lisiez les noms.
Il vaudrait mieux un tampon clair qu'un long silence.
Si le Bureau acceptait un premier essai, la cour tiendrait le rythme.
Nous vous prions de croire à notre engagement calme.
Les signataires : Patrick, Léa, Marc, Hawa, Joël, Rose, Aline, Karim, Lila,
Dieudonné, Félicie, et quelques voisins.
Pétition jointe : une page, assez de noms, pas trop de discours.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La lettre demande au Bureau de reconnaître le projet « Rive du Seuil ».",
  "correct": true,
  "explanation": "Premier paragraphe de demande."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que joignent les signataires ?",
  "options": [
    {
      "text": "Un passeport",
      "correct": false
    },
    {
      "text": "Le Cahier des racines",
      "correct": true
    },
    {
      "text": "Un contrat de location",
      "correct": false
    },
    {
      "text": "Une carte de minibus",
      "correct": false
    }
  ],
  "explanation": "« Nous joignons le Cahier des racines. »"
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
      "left": "pour que le Bureau reconnaisse",
      "right": "but"
    },
    {
      "left": "afin de protéger",
      "right": "figuier et rivière"
    },
    {
      "left": "afin que vous lisiez",
      "right": "les noms"
    },
    {
      "left": "une page",
      "right": "pétition"
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
  "prompt": "Complétez :\nNous joignons le Cahier afin que vous ___ les noms.",
  "answer": "lisiez"
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
    "vous",
    "écrivons",
    "pour",
    "que",
    "le",
    "Bureau",
    "reconnaisse",
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
  "word": "tampon",
  "hint": "Solange le pose sur le dossier si le Bureau accepte."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous joignons le Cahier afin que vous lisez les noms.",
  "correct_sentence": "Nous joignons le Cahier afin que vous lisiez les noms.",
  "explanation": "Afin que + subjonctif : lisiez."
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
      "image_path": "/elearning/mfk-b1-m4/groupe-engagement.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/micro-radio.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/soleil-demain.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/feuille-appel.svg",
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
  "prompt": "Recopiez la lettre et indiquez faits, but, pièce, formule de politesse."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la lettre à Solange, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Convaincre avec calme',
    'PO',
    $c$Objectif
Oraliser une demande au Bureau : faits, but, ton poli.

Consigne
Répétez, puis convainquez Solange en six phrases.

Support — Modèles d'Aline
Nous vous écrivons pour le projet.
Tout d'abord les faits.
Nous joignons le Cahier des racines.
Il vaudrait mieux un tampon clair.
Si le Bureau acceptait, nous tiendrions le rythme.
Nous vous prions de lire cette page.
Assez de noms, pas trop de discours.
La rive est de plus en plus claire.
On agit afin de protéger le figuier.
Signez ici pour que Solange voie.
Restez polis.
Restez précis.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le ton demandé est poli et précis, pas crié.",
  "correct": true,
  "explanation": "Restez polis. Restez précis."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle formule ouvre les faits ?",
  "options": [
    {
      "text": "Enfin les faits",
      "correct": false
    },
    {
      "text": "Tout d'abord les faits",
      "correct": true
    },
    {
      "text": "Dans l'attente des faits",
      "correct": false
    },
    {
      "text": "Je vous prie les faits",
      "correct": false
    }
  ],
  "explanation": "Tout d'abord les faits."
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
      "left": "nous vous écrivons",
      "right": "ouverture"
    },
    {
      "left": "tout d'abord",
      "right": "faits"
    },
    {
      "left": "nous joignons",
      "right": "Cahier"
    },
    {
      "left": "nous vous prions",
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
  "prompt": "Complétez :\nSi le Bureau ___, nous tiendrions le rythme. (accepter)",
  "answer": "acceptait"
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
    "joignons",
    "le",
    "Cahier",
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
  "word": "precis",
  "hint": "Le contraire de flou, pour convaincre. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si le Bureau acceptera nous tiendrions le rythme.",
  "correct_sentence": "Si le Bureau acceptait nous tiendrions le rythme.",
  "explanation": "Si + imparfait, pas le futur."
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
      "image_path": "/elearning/mfk-b1-m4/micro-radio.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/soleil-demain.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/feuille-appel.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/compte-rendu.svg",
      "word": "un compte rendu"
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
  "prompt": "Écrivez six phrases orales pour Solange : faits, but, demande, politesse."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis votre demande au Bureau."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma lettre au Bureau',
    'PE',
    $c$Objectif
Écrire une lettre-pétition à Solange, jointe au Cahier des racines.

Consigne
Imitez la lettre de Léa, sans aller trop vite.

Support — Lettre de Léa Niyonzima
Léa Niyonzima
Seuil des Sources, Rukiri-Nord
Madame Mukamana,
Nous vous écrivons pour que le Bureau des Escales tamponne le projet « Rive du Seuil ».
Tout d'abord : 18 signatures, 12 seaux, de moins en moins de plastique.
Nous joignons le Cahier des racines afin que vous lisiez les noms.
Il vaudrait mieux un premier essai qu'un long silence.
Nous vous prions de croire à notre engagement.
Léa — pour le groupe du figuier
Pétition : une page.
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa écrit au nom du groupe du figuier.",
  "correct": true,
  "explanation": "« Léa — pour le groupe du figuier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que vaudrait-il mieux, d'après Léa ?",
  "options": [
    {
      "text": "Un long silence",
      "correct": false
    },
    {
      "text": "Un premier essai",
      "correct": true
    },
    {
      "text": "Vingt pages",
      "correct": false
    },
    {
      "text": "Fermer la rive",
      "correct": false
    }
  ],
  "explanation": "« un premier essai qu'un long silence. »"
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
      "left": "pour que le Bureau tamponne",
      "right": "but"
    },
    {
      "left": "18 signatures",
      "right": "faits"
    },
    {
      "left": "Cahier des racines",
      "right": "pièce"
    },
    {
      "left": "nous vous prions",
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
  "prompt": "Complétez :\nNous vous ___ de croire à notre engagement.",
  "answer": "prions"
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
    "vous",
    "écrivons",
    "pour",
    "le",
    "projet",
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
  "word": "engagement",
  "hint": "On prie Solange de croire à notre… calme."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous vous prions de croire à notre engagements.",
  "correct_sentence": "Nous vous prions de croire à notre engagement.",
  "explanation": "Engagement au singulier après notre."
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
      "image_path": "/elearning/mfk-b1-m4/soleil-demain.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/feuille-appel.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/compte-rendu.svg",
      "word": "un compte rendu"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/indefinis-quantite.svg",
      "word": "une quantité"
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
  "prompt": "Imitez : une lettre de dix à douze lignes à Solange, avec pétition d'une phrase."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre lettre, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Lettre, pétition, Cahier des racines',
    'EL',
    $c$Objectif
Retenir le plan d'une lettre pour convaincre le Bureau.

Consigne
Apprenez la fiche.

Support — Fiche du courrier
Plan : lieu et date ; Madame Mukamana, ; faits ; but ; pièce ; clôture.
Faits : chiffres inventés du Seuil, de plus en plus / de moins en moins.
But : pour que + subjonctif / afin de + infinitif / afin que + subjonctif.
Pièce : nous joignons le Cahier des racines.
Pétition : une page, des noms, une demande nette (un tampon, un essai).
Clôture : nous vous prions de + infinitif.
Ton : poli, précis, assez de preuves, pas trop de discours.
Convaincre ≠ crier. Inciter ≠ exiger.
Ne pas inventer une ville réelle ni une enseigne réelle.
Ne pas dire : afin de que vous lisez.
Subjonctif : que le Bureau reconnaisse / tamponne / accepte ; que vous lisiez.
Si + imparfait : si le Bureau acceptait, nous tiendrions.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La pétition du Seuil tient en une page.",
  "correct": true,
  "explanation": "Une page, une demande nette."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle clôture est adaptée ?",
  "options": [
    {
      "text": "Répondez tout de suite",
      "correct": false
    },
    {
      "text": "Nous vous prions de lire cette page",
      "correct": true
    },
    {
      "text": "Tamponnez ou partez",
      "correct": false
    },
    {
      "text": "Criez au Bureau",
      "correct": false
    }
  ],
  "explanation": "Nous vous prions de + infinitif."
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
      "left": "faits",
      "right": "chiffres"
    },
    {
      "left": "but",
      "right": "pour que / afin que"
    },
    {
      "left": "pièce",
      "right": "Cahier des racines"
    },
    {
      "left": "clôture",
      "right": "nous vous prions"
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
  "prompt": "Complétez :\nNous ___ le Cahier des racines.",
  "answer": "joignons"
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
    "vous",
    "prions",
    "de",
    "lire",
    "cette",
    "page",
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
  "word": "racines",
  "hint": "Le cahier des… : les noms sous le figuier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous joignons le Cahier afin de que vous lisiez les noms.",
  "correct_sentence": "Nous joignons le Cahier afin que vous lisiez les noms.",
  "explanation": "Afin que, pas afin de que."
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
      "image_path": "/elearning/mfk-b1-m4/feuille-appel.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/compte-rendu.svg",
      "word": "un compte rendu"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/indefinis-quantite.svg",
      "word": "une quantité"
    },
    {
      "image_path": "/elearning/mfk-b1-m4/reserve-adhesion.svg",
      "word": "une réserve"
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
  "prompt": "Rédigez le plan d'une lettre en six blocs, avec un exemple chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et la lecture de votre plan."
}$j$::jsonb,
    9
  );

END;
$$;
