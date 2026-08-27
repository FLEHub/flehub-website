/*
  Seed eLearning MFK — Module 7 A1 « Cap sur ailleurs »

  Même micro-monde que les Modules 3 à 6 : cour « Le Seuil des Sources », Rukiri-Nord.
  Carnet de route inventé sous le figuier.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a1-m7/
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
  v_module_title text := 'A1 — Cap sur ailleurs';
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
      'Seed A1 Module 7 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed Module 7 : enseignant % (%)', v_teacher_email, v_teacher_id;

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
      'Grande étape 7 : dire un projet de départ au futur simple, voyager autrement, situer un ailleurs inventé, trouver un point de chute, choisir une saison et tenir un carnet — sous le figuier du Seuil des Sources (Rukiri-Nord).',
      'A1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape 7 : dire un projet de départ au futur simple, voyager autrement, situer un ailleurs inventé, trouver un point de chute, choisir une saison et tenir un carnet — sous le figuier du Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'A1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Envie de partir =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Envie de partir'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Envie de partir', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Un billet sous le figuier',
    'CO',
    $c$Objectif
Comprendre un projet de départ : je partirai, j'aurai, il faut.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui partira ? Où ? Qu'est-ce qu'il faut ?

Support — Carnet de route, banc du Seuil
Léa : J'ai envie de partir. Je partirai au lac des Nénuphars.
Aline : Il faut un billet. Tu auras une place dans le minibus Figuier 7.
Marc : Oui. Je prendrai la route à six heures. Léa, tu seras à l'heure ?
Léa : Oui. J'aurai ma petite valise.
Joël : Moi, je ne partirai pas. Je resterai près de la moto.
Patrick : Il faut demander l'heure à l'accueil.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa partira au lac des Nénuphars.",
  "correct": true,
  "explanation": "Léa : « Je partirai au lac des Nénuphars. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qu'est-ce qu'il faut, d'après Aline ?",
  "options": [
    {
      "text": "Un tambour",
      "correct": false
    },
    {
      "text": "Un billet",
      "correct": true
    },
    {
      "text": "Une danse",
      "correct": false
    },
    {
      "text": "Un cahier d'histoires",
      "correct": false
    }
  ],
  "explanation": "Aline : « Il faut un billet. »"
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
      "left": "Léa",
      "right": "partira au lac"
    },
    {
      "left": "Marc",
      "right": "prendra la route"
    },
    {
      "left": "Joël",
      "right": "restera"
    },
    {
      "left": "Aline",
      "right": "parle du billet"
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
  "prompt": "Complétez :\nJe ___ au lac des Nénuphars.",
  "answer": "partirai"
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
    "faut",
    "un",
    "billet",
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
  "word": "partirai",
  "hint": "Le futur de partir, avec je."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je partiras au lac demain.",
  "correct_sentence": "Je partirai au lac demain.",
  "explanation": "Je partirai (pas partiras)."
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
      "image_path": "/elearning/mfk-a1-m7/valise.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/ticket.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/partir.svg",
      "word": "partir"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/minibus.svg",
      "word": "le minibus"
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
  "prompt": "Notez qui partira, qui restera, et ce qu'il faut."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : J'ai envie de partir. Je partirai demain. Il faut un billet. J'aurai ma valise."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Cartes du carnet',
    'CE',
    $c$Objectif
Lire des projets au futur simple et la formule il faut.

Consigne
Lisez les cartes épinglées.

Support — Carnet de route
Léa — Je partirai au lac des Nénuphars. J'aurai une valise.
Marc — Je prendrai le minibus à 6 h. Tu seras à l'heure ?
Aline — Il faut un billet. Il faut demander à l'accueil.
Joël — Je ne partirai pas. Je resterai ici.
Noura Sarr — Je visiterai le Seuil. Après, je partirai aussi.
Règle : une phrase au futur, une phrase avec il faut.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël partira avec Léa.",
  "correct": false,
  "explanation": "Joël : « Je ne partirai pas. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui visitera d'abord le Seuil ?",
  "options": [
    {
      "text": "Marc",
      "correct": false
    },
    {
      "text": "Noura Sarr",
      "correct": true
    },
    {
      "text": "Aline",
      "correct": false
    },
    {
      "text": "Patrick",
      "correct": false
    }
  ],
  "explanation": "Carte Noura : « Je visiterai le Seuil. »"
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
      "left": "je partirai",
      "right": "Léa"
    },
    {
      "left": "je prendrai",
      "right": "Marc"
    },
    {
      "left": "il faut",
      "right": "Aline"
    },
    {
      "left": "je resterai",
      "right": "Joël"
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
  "prompt": "Complétez :\nIl ___ un billet.",
  "answer": "faut"
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
    "seras",
    "à",
    "l'heure",
    "?"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "aurai",
  "hint": "Le futur de avoir, avec je : j'…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il fauts un billet.",
  "correct_sentence": "Il faut un billet.",
  "explanation": "Il faut : toujours 3e personne, sans s."
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
      "image_path": "/elearning/mfk-a1-m7/carnet.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/ticket.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/valise.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/carte.svg",
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
  "prompt": "Recopiez deux cartes. Ajoutez la vôtre : je partirai… / il faut…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les cinq cartes, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire je partirai, il faut',
    'PO',
    $c$Objectif
Dire un projet : je partirai, tu seras, j'aurai, il faut.

Consigne
Répétez, puis parlez de votre envie de partir (vraie ou inventée).

Support — Modèles de Léa
Je partirai demain.
Tu partiras aussi.
Il restera ici.
J'aurai une valise.
Tu seras à l'heure.
Il faut un billet.
Il faut demander.
Je ne partirai pas.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il faut » ne change pas avec je ou tu.",
  "correct": true,
  "explanation": "Toujours il faut + nom ou infinitif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est au futur simple ?",
  "options": [
    {
      "text": "Je pars",
      "correct": false
    },
    {
      "text": "Je vais partir",
      "correct": false
    },
    {
      "text": "Je partirai",
      "correct": true
    },
    {
      "text": "Je suis parti",
      "correct": false
    }
  ],
  "explanation": "Je partirai = futur simple."
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
      "left": "je partirai",
      "right": "partir"
    },
    {
      "left": "j'aurai",
      "right": "avoir"
    },
    {
      "left": "tu seras",
      "right": "être"
    },
    {
      "left": "il faut",
      "right": "conseil"
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
  "prompt": "Complétez :\nTu ___ à l'heure.",
  "answer": "seras"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'aurai",
    "une",
    "valise",
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
  "word": "seras",
  "hint": "Le futur de être, avec tu."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je sera à l'heure.",
  "correct_sentence": "Je serai à l'heure.",
  "explanation": "Je serai (être au futur)."
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
      "image_path": "/elearning/mfk-a1-m7/partir.svg",
      "word": "partir"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/rester.svg",
      "word": "rester"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/valise.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/ticket.svg",
      "word": "un billet"
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
  "prompt": "Écrivez six phrases : deux je partirai, deux j'aurai/tu seras, deux il faut."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre projet."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma carte de départ',
    'PE',
    $c$Objectif
Écrire une courte carte au futur simple.

Consigne
Imitez la carte de Léa.

Support — Carte de Léa
Léa Niyonzima
Je partirai au lac des Nénuphars.
J'aurai une petite valise.
Il faut un billet. Il faut être à six heures.
Je serai à l'heure.
Léa
Carnet de route — Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa sera en retard, d'après sa carte.",
  "correct": false,
  "explanation": "« Je serai à l'heure. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À quelle heure faut-il être ?",
  "options": [
    {
      "text": "À midi",
      "correct": false
    },
    {
      "text": "À six heures",
      "correct": true
    },
    {
      "text": "À minuit",
      "correct": false
    },
    {
      "text": "À seize heures",
      "correct": false
    }
  ],
  "explanation": "« Il faut être à six heures. »"
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
      "left": "je partirai",
      "right": "lac"
    },
    {
      "left": "j'aurai",
      "right": "valise"
    },
    {
      "left": "il faut",
      "right": "billet"
    },
    {
      "left": "je serai",
      "right": "à l'heure"
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
  "prompt": "Complétez :\nJe ___ à l'heure.",
  "answer": "serai"
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
    "partirai",
    "demain",
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
  "word": "faut",
  "hint": "Il… un billet : toujours 3e personne."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je faut un billet.",
  "correct_sentence": "Il faut un billet.",
  "explanation": "On ne dit pas je faut. Toujours il faut."
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
      "image_path": "/elearning/mfk-a1-m7/valise.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/lac.svg",
      "word": "un lac"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/ticket.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/carnet.svg",
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
  "prompt": "Écrivez cinq lignes : je partirai, j'aurai, deux il faut, je serai."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre carte, une phrase, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Futur de partir, être, avoir',
    'EL',
    $c$Objectif
Retenir le futur simple (je/tu/il) et il faut.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
je partirai / tu partiras / il partira / elle partira
être : je serai / tu seras / il sera / nous serons
avoir : j'aurai / tu auras / il aura / nous aurons
il faut + nom : il faut un billet
il faut + infinitif : il faut demander
Attention : je serai (pas je sera). Je partirai (pas je partiras).
Il faut : toujours il. Pas je faut, pas tu faut.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je faut partir ».",
  "correct": false,
  "explanation": "Il faut partir."
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
      "text": "je sera",
      "correct": false
    },
    {
      "text": "je serai",
      "correct": true
    },
    {
      "text": "je êtreai",
      "correct": false
    },
    {
      "text": "je serais-tu",
      "correct": false
    }
  ],
  "explanation": "Je serai."
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
      "left": "partir",
      "right": "je partirai"
    },
    {
      "left": "être",
      "right": "je serai"
    },
    {
      "left": "avoir",
      "right": "j'aurai"
    },
    {
      "left": "il faut",
      "right": "3e personne"
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
  "prompt": "Complétez :\nNous ___ à l'heure. (être)",
  "answer": "serons"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Elle",
    "partira",
    "demain",
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
  "word": "auras",
  "hint": "Le futur de avoir, avec tu."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tu aura une valise.",
  "correct_sentence": "Tu auras une valise.",
  "explanation": "Tu auras (avec s)."
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
      "image_path": "/elearning/mfk-a1-m7/partir.svg",
      "word": "partir"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/valise.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/ticket.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/boussole.svg",
      "word": "une boussole"
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : je partirai, je serai, j'aurai, il faut."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : je partirai, tu seras, j'aurai, il sera, il faut un billet."
}$j$::jsonb,
    9
  );

  -- ===== Voyager autrement =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Voyager autrement'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Voyager autrement', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Minibus, moto, bateau',
    'CO',
    $c$Objectif
Comprendre des moyens de voyage au futur : je prendrai, je ferai, on pourra.

Consigne
Qui prendra quoi ? Où ira le bateau ?

Support — Carte du Seuil vers ailleurs
Marc : Je prendrai le minibus. Je ferai la route du lac.
Joël : Moi, je prendrai la moto. On pourra aller jusqu'au Port de la Brise.
Ibrahim Tchami : Là, je prendrai le bateau. Vous serez sur l'eau vers l'Île de Sable-Rouge.
Léa : Je ne prendrai pas l'avion. Je voyagerai autrement.
Aline : Il faut choisir. Il faudra un billet pour le bateau.
Hawa : Nous ferons une pause, un thé, avant.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa prendra l'avion.",
  "correct": false,
  "explanation": "Léa : « Je ne prendrai pas l'avion. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que prendra Ibrahim au Port de la Brise ?",
  "options": [
    {
      "text": "Le minibus",
      "correct": false
    },
    {
      "text": "La moto",
      "correct": false
    },
    {
      "text": "Le bateau",
      "correct": true
    },
    {
      "text": "Le fil des heures",
      "correct": false
    }
  ],
  "explanation": "Ibrahim : « Je prendrai le bateau. »"
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
      "left": "minibus",
      "right": "Marc"
    },
    {
      "left": "moto",
      "right": "Joël"
    },
    {
      "left": "bateau",
      "right": "Ibrahim"
    },
    {
      "left": "thé",
      "right": "Hawa"
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
  "prompt": "Complétez :\nJe ___ le minibus.",
  "answer": "prendrai"
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
    "pourra",
    "aller",
    "loin",
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
  "word": "ferai",
  "hint": "Le futur de faire, avec je."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ferrai la route demain.",
  "correct_sentence": "Je ferai la route demain.",
  "explanation": "Faire au futur : je ferai (un seul r)."
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
      "image_path": "/elearning/mfk-a1-m7/minibus.svg",
      "word": "le minibus"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/moto.svg",
      "word": "la moto"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/bateau.svg",
      "word": "un bateau"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/mer.svg",
      "word": "la mer"
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
  "prompt": "Notez trois moyens et une phrase avec on pourra."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je prendrai le minibus. Je ferai la route. On pourra prendre le bateau. Je ne prendrai pas l'avion."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Affiche « autrement »',
    'CE',
    $c$Objectif
Lire une affiche de voyages inventés.

Consigne
Lisez l'affiche sous le figuier.

Support — Affiche ocre
Voyager autrement — Rukiri-Nord
Minibus Figuier 7 — Marc — on prendra la route du lac
Moto Figuier — Joël — on pourra aller au Port de la Brise
Bateau d'Ibrahim — Île de Sable-Rouge — il faudra un billet
Pas d'avion ici. On fera la route, ensemble.
Il faut demander l'heure à l'accueil.
Carnet de route du Seuil
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'affiche propose un avion.",
  "correct": false,
  "explanation": "« Pas d'avion ici. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pour l'île, qu'est-ce qu'il faudra ?",
  "options": [
    {
      "text": "Un tambour",
      "correct": false
    },
    {
      "text": "Un billet",
      "correct": true
    },
    {
      "text": "Une radio",
      "correct": false
    },
    {
      "text": "Un album",
      "correct": false
    }
  ],
  "explanation": "« Il faudra un billet. »"
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
      "left": "minibus",
      "right": "lac"
    },
    {
      "left": "moto",
      "right": "Port de la Brise"
    },
    {
      "left": "bateau",
      "right": "île"
    },
    {
      "left": "accueil",
      "right": "l'heure"
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
  "prompt": "Complétez :\nOn ___ la route ensemble.",
  "answer": "fera"
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
    "faudra",
    "un",
    "billet",
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
  "word": "pourra",
  "hint": "On… aller loin : futur de pouvoir (deux r)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On poura aller au port.",
  "correct_sentence": "On pourra aller au port.",
  "explanation": "Pouvoir au futur : pourra (deux r)."
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
      "image_path": "/elearning/mfk-a1-m7/bateau.svg",
      "word": "un bateau"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/ile.svg",
      "word": "une île"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/ticket.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/carte.svg",
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
  "prompt": "Recopiez l'affiche. Entourez le moyen que vous choisirez."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'affiche, une ligne, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire je prendrai, je ferai, on pourra',
    'PO',
    $c$Objectif
Parler d'un voyage : prendre, faire, pouvoir au futur.

Consigne
Répétez, puis choisissez un moyen.

Support — Modèles de Marc
Je prendrai le minibus.
Tu prendras la moto.
Il prendra le bateau.
Je ferai la route.
Nous ferons une pause.
On pourra partir tôt.
Vous serez sur l'eau.
Il faudra un billet.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il faudra » est le futur de il faut.",
  "correct": true,
  "explanation": "Falloir au futur : il faudra."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme de pouvoir est correcte ?",
  "options": [
    {
      "text": "je poura",
      "correct": false
    },
    {
      "text": "je pourrai",
      "correct": true
    },
    {
      "text": "je peusrai",
      "correct": false
    },
    {
      "text": "je pouvrai",
      "correct": false
    }
  ],
  "explanation": "Je pourrai (deux r)."
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
      "left": "prendre",
      "right": "je prendrai"
    },
    {
      "left": "faire",
      "right": "je ferai"
    },
    {
      "left": "pouvoir",
      "right": "je pourrai"
    },
    {
      "left": "falloir",
      "right": "il faudra"
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
  "prompt": "Complétez :\nJe ___ la route. (faire)",
  "answer": "ferai"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Vous",
    "serez",
    "sur",
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
  "word": "prendrai",
  "hint": "Le futur de prendre, avec je."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je prendreai le minibus.",
  "correct_sentence": "Je prendrai le minibus.",
  "explanation": "Prendre : je prendrai."
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
      "image_path": "/elearning/mfk-a1-m7/minibus.svg",
      "word": "le minibus"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/moto.svg",
      "word": "la moto"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/bateau.svg",
      "word": "un bateau"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/pont.svg",
      "word": "un pont"
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
  "prompt": "Écrivez six phrases : deux prendrai, deux ferai, un pourra, un faudra."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre moyen de voyage."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon voyage autrement',
    'PE',
    $c$Objectif
Écrire un petit projet de route.

Consigne
Imitez le mot de Joël.

Support — Mot de Joël
Bonjour,
Je prendrai la moto. Je ferai la route jusqu'au Port de la Brise.
On pourra voir la mer.
Je ne prendrai pas l'avion.
Il faudra de l'eau et un billet.
Joël Mugisha
Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël prendra l'avion.",
  "correct": false,
  "explanation": "« Je ne prendrai pas l'avion. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Jusqu'où Joël fera-t-il la route ?",
  "options": [
    {
      "text": "Le lac des Nénuphars",
      "correct": false
    },
    {
      "text": "Le Port de la Brise",
      "correct": true
    },
    {
      "text": "Mwezi-Haut",
      "correct": false
    },
    {
      "text": "L'accueil",
      "correct": false
    }
  ],
  "explanation": "« jusqu'au Port de la Brise »."
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
      "left": "je prendrai",
      "right": "moto"
    },
    {
      "left": "je ferai",
      "right": "route"
    },
    {
      "left": "on pourra",
      "right": "mer"
    },
    {
      "left": "il faudra",
      "right": "eau et billet"
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
  "prompt": "Complétez :\nOn ___ voir la mer.",
  "answer": "pourra"
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
    "ferai",
    "la",
    "route",
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
  "word": "moto",
  "hint": "Le moyen de Joël, pas le minibus."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faudra de l'eau. Je faut un billet.",
  "correct_sentence": "Il faudra de l'eau. Il faut un billet.",
  "explanation": "Toujours il faut / il faudra."
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
      "image_path": "/elearning/mfk-a1-m7/moto.svg",
      "word": "la moto"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/mer.svg",
      "word": "la mer"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/ticket.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/partir.svg",
      "word": "partir"
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
  "prompt": "Écrivez cinq lignes : je prendrai, je ferai, on pourra, je ne prendrai pas, il faudra."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot, simplement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Prendre, faire, pouvoir, falloir',
    'EL',
    $c$Objectif
Retenir les futurs irréguliers de la route.

Consigne
Étudiez la fiche.

Support — Fiche de Marc
prendre : je prendrai / tu prendras / il prendra
faire : je ferai / tu feras / il fera / nous ferons
pouvoir : je pourrai / tu pourras / il pourra (deux r)
falloir : il faut / il faudra (seulement il)
être : vous serez
Attention : je ferai (un r). Je pourrai (deux r).
Pas je faut. Pas on poura.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « je ferrai » (deux r).",
  "correct": false,
  "explanation": "Je ferai, un seul r."
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
      "text": "il faudra",
      "correct": true
    },
    {
      "text": "ils faudra",
      "correct": false
    },
    {
      "text": "il fautent",
      "correct": false
    },
    {
      "text": "je faudra",
      "correct": false
    }
  ],
  "explanation": "Il faudra : seulement il."
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
      "left": "je ferai",
      "right": "faire"
    },
    {
      "left": "je pourrai",
      "right": "pouvoir"
    },
    {
      "left": "je prendrai",
      "right": "prendre"
    },
    {
      "left": "il faudra",
      "right": "falloir"
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
  "prompt": "Complétez :\nTu ___ partir tôt. (pouvoir)",
  "answer": "pourras"
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
    "ferons",
    "une",
    "pause",
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
  "word": "ferons",
  "hint": "Le futur de faire, avec nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Vous sera sur l'eau.",
  "correct_sentence": "Vous serez sur l'eau.",
  "explanation": "Vous serez (être)."
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
      "image_path": "/elearning/mfk-a1-m7/minibus.svg",
      "word": "le minibus"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/bateau.svg",
      "word": "un bateau"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/boussole.svg",
      "word": "une boussole"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/carte.svg",
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : prendrai, ferai, pourrai, faudra."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : je prendrai, je ferai, je pourrai, il faudra, vous serez."
}$j$::jsonb,
    9
  );

  -- ===== Un tour d'horizon =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un tour d''horizon'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un tour d''horizon', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La carte vers ailleurs',
    'CO',
    $c$Objectif
Comprendre un tour d'horizon : nord, sud, lac, île, montagne.

Consigne
Quels lieux entend-on ? Qui visitera quoi ?

Support — Carte inventée, épinglée au figuier
Patrick : Voici un tour d'horizon. Au nord, le lac des Nénuphars.
Noura : Au sud, Mwezi-Haut. Il y aura une montagne.
Ibrahim : À l'ouest, le Port de la Brise. Après, l'Île de Sable-Rouge.
Léa : Nous visiterons le lac d'abord. Puis nous irons au port.
Aline : Il faut regarder la carte. Vous serez moins perdus.
Joël : Moi, je resterai près du Seuil. Je verrai la carte ici.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le lac des Nénuphars est au nord.",
  "correct": true,
  "explanation": "Patrick : « Au nord, le lac des Nénuphars. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où est Mwezi-Haut ?",
  "options": [
    {
      "text": "Au nord",
      "correct": false
    },
    {
      "text": "Au sud",
      "correct": true
    },
    {
      "text": "Sur l'île",
      "correct": false
    },
    {
      "text": "À l'accueil",
      "correct": false
    }
  ],
  "explanation": "Noura : « Au sud, Mwezi-Haut. »"
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
      "left": "nord",
      "right": "lac"
    },
    {
      "left": "sud",
      "right": "Mwezi-Haut"
    },
    {
      "left": "ouest",
      "right": "port et île"
    },
    {
      "left": "Seuil",
      "right": "Joël"
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
  "prompt": "Complétez :\nNous ___ le lac d'abord.",
  "answer": "visiterons"
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
    "y",
    "aura",
    "une",
    "montagne",
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
  "word": "irons",
  "hint": "Le futur de aller, avec nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous allerons au port.",
  "correct_sentence": "Nous irons au port.",
  "explanation": "Aller au futur : nous irons."
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
      "image_path": "/elearning/mfk-a1-m7/carte.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/lac.svg",
      "word": "un lac"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/ile.svg",
      "word": "une île"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/montagne.svg",
      "word": "une montagne"
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
  "prompt": "Notez quatre lieux et leur direction (nord, sud, ouest, ici)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Au nord, le lac. Au sud, la montagne. Nous visiterons le port. Il y aura une île."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Légende de la carte',
    'CE',
    $c$Objectif
Lire une légende de carte inventée.

Consigne
Lisez la légende.

Support — Légende
Carte du Seuil vers ailleurs
N — lac des Nénuphars — 2 h en minibus
S — Mwezi-Haut — montagne, air frais
O — Port de la Brise — bateau d'Ibrahim
Île de Sable-Rouge — après le port
Rive d'Orage — vent, plus loin
Il y aura des pauses. Nous irons lentement.
Rien n'est copié d'une ville réelle. C'est le carnet du Seuil.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mwezi-Haut est une grande ville réelle.",
  "correct": false,
  "explanation": "Lieu inventé du carnet."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien d'heures jusqu'au lac, en minibus ?",
  "options": [
    {
      "text": "Une",
      "correct": false
    },
    {
      "text": "Deux",
      "correct": true
    },
    {
      "text": "Six",
      "correct": false
    },
    {
      "text": "Douze",
      "correct": false
    }
  ],
  "explanation": "N — 2 h en minibus."
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
      "left": "N",
      "right": "lac"
    },
    {
      "left": "S",
      "right": "montagne"
    },
    {
      "left": "O",
      "right": "port"
    },
    {
      "left": "île",
      "right": "Sable-Rouge"
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
  "prompt": "Complétez :\nIl y ___ des pauses.",
  "answer": "aura"
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
    "irons",
    "lentement",
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
  "word": "montagne",
  "hint": "Au sud, l'air frais de Mwezi-Haut."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il y aura des pause.",
  "correct_sentence": "Il y aura des pauses.",
  "explanation": "Pauses au pluriel après des."
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
      "image_path": "/elearning/mfk-a1-m7/nord.svg",
      "word": "le nord"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/sud.svg",
      "word": "le sud"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/boussole.svg",
      "word": "une boussole"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/montagne.svg",
      "word": "une montagne"
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
  "prompt": "Recopiez quatre lignes de la légende. Ajoutez un lieu inventé."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la légende, du nord vers l'île."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Situer et projeter',
    'PO',
    $c$Objectif
Situer un lieu et dire nous visiterons / il y aura.

Consigne
Répétez, puis décrivez la carte.

Support — Modèles de Patrick
Au nord, il y a un lac.
Au sud, il y aura une montagne.
Nous visiterons le port.
Nous irons à l'île.
Vous serez au Seuil.
Ils partiront tôt.
La carte sera claire.
Il faut regarder le nord.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il y aura » est le futur de il y a.",
  "correct": true,
  "explanation": "Avoir au futur : aura."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est au futur ?",
  "options": [
    {
      "text": "Au nord, il y a un lac",
      "correct": false
    },
    {
      "text": "Il faut regarder le nord",
      "correct": false
    },
    {
      "text": "Nous visiterons le port",
      "correct": true
    },
    {
      "text": "La carte est claire",
      "correct": false
    }
  ],
  "explanation": "Nous visiterons."
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
      "left": "au nord",
      "right": "lac"
    },
    {
      "left": "au sud",
      "right": "montagne"
    },
    {
      "left": "nous irons",
      "right": "île"
    },
    {
      "left": "il faut",
      "right": "regarder"
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
  "prompt": "Complétez :\nVous ___ au Seuil. (être)",
  "answer": "serez"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ils",
    "partiront",
    "tôt",
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
  "word": "visiterons",
  "hint": "Le futur de visiter, avec nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La carte sera claire. Il y auras un lac.",
  "correct_sentence": "La carte sera claire. Il y aura un lac.",
  "explanation": "Il y aura (pas auras)."
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
      "image_path": "/elearning/mfk-a1-m7/lac.svg",
      "word": "un lac"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/ile.svg",
      "word": "une île"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/carte.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/visiter.svg",
      "word": "visiter"
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
  "prompt": "Écrivez six phrases : deux lieux, deux nous visiterons/irons, un il y aura, un il faut."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis un mini-tour d'horizon."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon tour d''horizon',
    'PE',
    $c$Objectif
Écrire un court tour de carte.

Consigne
Imitez le mot de Noura.

Support — Mot de Noura
Noura Sarr
Au nord, nous visiterons le lac.
Au sud, il y aura Mwezi-Haut.
Puis nous irons au Port de la Brise.
Je ne visiterai pas la Rive d'Orage cette fois.
Il faut la carte.
Noura
Carnet de route
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Noura visitera la Rive d'Orage cette fois.",
  "correct": false,
  "explanation": "« Je ne visiterai pas la Rive d'Orage cette fois. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que visiteront-ils au nord ?",
  "options": [
    {
      "text": "La montagne",
      "correct": false
    },
    {
      "text": "Le lac",
      "correct": true
    },
    {
      "text": "L'auberge",
      "correct": false
    },
    {
      "text": "L'accueil",
      "correct": false
    }
  ],
  "explanation": "« Nous visiterons le lac. »"
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
      "left": "nord",
      "right": "lac"
    },
    {
      "left": "sud",
      "right": "Mwezi-Haut"
    },
    {
      "left": "port",
      "right": "ensuite"
    },
    {
      "left": "carte",
      "right": "il faut"
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
  "prompt": "Complétez :\nNous ___ au Port de la Brise.",
  "answer": "irons"
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
    "faut",
    "la",
    "carte",
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
  "word": "horizon",
  "hint": "Un tour d'… : regarder loin, sur la carte."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous visiterons le lac. Je visiterai pas la rive.",
  "correct_sentence": "Nous visiterons le lac. Je ne visiterai pas la rive.",
  "explanation": "Négation : ne… pas."
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
      "image_path": "/elearning/mfk-a1-m7/carte.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/lac.svg",
      "word": "un lac"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/nord.svg",
      "word": "le nord"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/sud.svg",
      "word": "le sud"
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
  "prompt": "Écrivez cinq lignes : nord, sud, puis, je ne… pas, il faut."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre tour d'horizon."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Visiter, aller, il y aura',
    'EL',
    $c$Objectif
Retenir nous visiterons, nous irons, il y aura, les points cardinaux.

Consigne
Apprenez la fiche.

Support — Fiche de Patrick
visiter : je visiterai / nous visiterons
aller : j'irai / tu iras / nous irons
il y a → il y aura
nord / sud / est / ouest
il faut + nom (la carte)
Attention : nous irons (pas nous allerons).
Il y aura (pas il y auras).
Lieux du carnet : inventés, pas des villes copiées.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « nous allerons ».",
  "correct": false,
  "explanation": "Nous irons."
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
      "text": "j'allerai",
      "correct": false
    },
    {
      "text": "j'irai",
      "correct": true
    },
    {
      "text": "je irai",
      "correct": false
    },
    {
      "text": "j'allerais",
      "correct": false
    }
  ],
  "explanation": "J'irai."
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
      "left": "aller",
      "right": "j'irai"
    },
    {
      "left": "visiter",
      "right": "nous visiterons"
    },
    {
      "left": "il y a",
      "right": "il y aura"
    },
    {
      "left": "ouest",
      "right": "port"
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
  "prompt": "Complétez :\nJ'___ au lac demain. (aller)",
  "answer": "irai"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Au",
    "nord",
    "il",
    "y",
    "aura",
    "un",
    "lac",
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
  "word": "irai",
  "hint": "Le futur de aller, avec je : j'…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tu iras au sud. J'allerai au nord.",
  "correct_sentence": "Tu iras au sud. J'irai au nord.",
  "explanation": "Aller : j'irai."
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
      "image_path": "/elearning/mfk-a1-m7/boussole.svg",
      "word": "une boussole"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/nord.svg",
      "word": "le nord"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/sud.svg",
      "word": "le sud"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/visiter.svg",
      "word": "visiter"
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : irai, visiterons, il y aura, au nord."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : j'irai, nous irons, nous visiterons, il y aura, au nord, au sud."
}$j$::jsonb,
    9
  );

  -- ===== Un point de chute =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un point de chute'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un point de chute', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — L''Auberge des Figues',
    'CO',
    $c$Objectif
Comprendre un hébergement au futur : je resterai, il faudra une chambre.

Consigne
Où Léa restera-t-elle ? Qu'est-ce qu'il faudra ?

Support — Port de la Brise, clé à la main
Léa : Je resterai à l'Auberge des Figues. Ce n'est pas loin du bateau.
Aline : Il faudra une chambre. Il faudra une clé.
Noura : Moi, je prendrai la petite chambre. Elle sera calme.
Ibrahim : Vous serez près de la mer. Il faudra arriver avant dix-neuf heures.
Joël : Je ne resterai pas. Je rentrerai au Seuil.
Patrick : Il faut demander à l'accueil de l'auberge.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël restera à l'auberge.",
  "correct": false,
  "explanation": "Joël : « Je ne resterai pas. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Léa restera-t-elle ?",
  "options": [
    {
      "text": "Au Seuil",
      "correct": false
    },
    {
      "text": "À l'Auberge des Figues",
      "correct": true
    },
    {
      "text": "À Mwezi-Haut",
      "correct": false
    },
    {
      "text": "Chez Kévin",
      "correct": false
    }
  ],
  "explanation": "Léa : « Je resterai à l'Auberge des Figues. »"
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
      "left": "Léa",
      "right": "auberge"
    },
    {
      "left": "Noura",
      "right": "petite chambre"
    },
    {
      "left": "Joël",
      "right": "rentrera"
    },
    {
      "left": "Ibrahim",
      "right": "avant 19 h"
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
  "prompt": "Complétez :\nJe ___ à l'auberge.",
  "answer": "resterai"
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
    "faudra",
    "une",
    "chambre",
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
  "word": "chambre",
  "hint": "Le lieu pour dormir, à l'auberge."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je resterai à l'auberge. Il faudra une clés.",
  "correct_sentence": "Je resterai à l'auberge. Il faudra une clé.",
  "explanation": "Une clé, au singulier."
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
      "image_path": "/elearning/mfk-a1-m7/auberge.svg",
      "word": "une auberge"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/chambre.svg",
      "word": "une chambre"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/cle.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/rester.svg",
      "word": "rester"
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
  "prompt": "Notez qui restera, qui rentrera, et deux « il faudra »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je resterai à l'auberge. Il faudra une chambre. La chambre sera calme. Je rentrerai demain."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fiche de l''auberge',
    'CE',
    $c$Objectif
Lire une fiche d'hébergement inventée.

Consigne
Lisez la fiche.

Support — Fiche
Auberge des Figues — Port de la Brise
Chambre petite — Noura — elle sera calme
Chambre près de la mer — Léa — elle regardera l'eau
Arrivée : avant 19 h
Il faudra une clé. Il faudra un nom.
Pas d'avion. On arrivera en bateau ou en moto.
Inventée pour le carnet. Pas un hôtel réel.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa aura la chambre petite.",
  "correct": false,
  "explanation": "Léa a la chambre près de la mer. Noura a la petite chambre."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Avant quelle heure faut-il arriver ?",
  "options": [
    {
      "text": "6 h",
      "correct": false
    },
    {
      "text": "12 h",
      "correct": false
    },
    {
      "text": "19 h",
      "correct": true
    },
    {
      "text": "Minuit",
      "correct": false
    }
  ],
  "explanation": "Arrivée : avant 19 h."
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
      "left": "petite chambre",
      "right": "Noura"
    },
    {
      "left": "près de la mer",
      "right": "Léa"
    },
    {
      "left": "clé",
      "right": "il faudra"
    },
    {
      "left": "19 h",
      "right": "arrivée"
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
  "prompt": "Complétez :\nOn ___ en bateau. (arriver)",
  "answer": "arrivera"
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
    "chambre",
    "sera",
    "calme",
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
  "word": "auberge",
  "hint": "La maison du Port de la Brise, pour une nuit."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On arriverons en bateau.",
  "correct_sentence": "On arrivera en bateau.",
  "explanation": "On = il/elle : arrivera."
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
      "image_path": "/elearning/mfk-a1-m7/chambre.svg",
      "word": "une chambre"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/auberge.svg",
      "word": "une auberge"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/cle.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/mer.svg",
      "word": "la mer"
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
  "prompt": "Recopiez la fiche en phrases : je resterai, il faudra, on arrivera."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la fiche, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire je resterai, il faudra',
    'PO',
    $c$Objectif
Parler d'un point de chute : rester, arriver, falloir.

Consigne
Répétez, puis inventez une chambre.

Support — Modèles de Noura
Je resterai ici.
Tu resteras près de la mer.
Elle sera calme.
Nous arriverons tôt.
Il faudra une clé.
Il faudra demander.
Vous serez à l'auberge.
Je rentrerai demain.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Vous serez » est le futur de être.",
  "correct": true,
  "explanation": "Vous serez."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase dit un besoin ?",
  "options": [
    {
      "text": "Je resterai ici",
      "correct": false
    },
    {
      "text": "Elle sera calme",
      "correct": false
    },
    {
      "text": "Il faudra une clé",
      "correct": true
    },
    {
      "text": "Je rentrerai demain",
      "correct": false
    }
  ],
  "explanation": "Il faudra = besoin au futur."
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
      "left": "je resterai",
      "right": "nuit"
    },
    {
      "left": "nous arriverons",
      "right": "entrée"
    },
    {
      "left": "il faudra",
      "right": "clé"
    },
    {
      "left": "je rentrerai",
      "right": "retour"
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
  "prompt": "Complétez :\nNous ___ tôt. (arriver)",
  "answer": "arriverons"
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
    "resteras",
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
  "word": "clé",
  "hint": "Il la faudra, pour la chambre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous arriverons tôt. Il faudra demandé à l'accueil.",
  "correct_sentence": "Nous arriverons tôt. Il faudra demander à l'accueil.",
  "explanation": "Il faudra + infinitif : demander."
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
      "image_path": "/elearning/mfk-a1-m7/rester.svg",
      "word": "rester"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/arriver.svg",
      "word": "arriver"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/chambre.svg",
      "word": "une chambre"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/auberge.svg",
      "word": "une auberge"
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
  "prompt": "Écrivez six phrases : resterai, arriverons, deux il faudra, serez, rentrerai."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre point de chute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma fiche de chambre',
    'PE',
    $c$Objectif
Écrire une fiche de point de chute.

Consigne
Imitez la fiche de Léa.

Support — Fiche de Léa
Léa Niyonzima
Je resterai à l'Auberge des Figues.
La chambre sera près de la mer.
Il faudra une clé. Il faudra arriver avant dix-neuf heures.
Je ne resterai pas longtemps. Je rentrerai au Seuil.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa restera longtemps.",
  "correct": false,
  "explanation": "« Je ne resterai pas longtemps. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où sera la chambre de Léa ?",
  "options": [
    {
      "text": "Sous le figuier",
      "correct": false
    },
    {
      "text": "Près de la mer",
      "correct": true
    },
    {
      "text": "À Mwezi-Haut",
      "correct": false
    },
    {
      "text": "Dans le minibus",
      "correct": false
    }
  ],
  "explanation": "« près de la mer »."
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
      "left": "je resterai",
      "right": "auberge"
    },
    {
      "left": "sera",
      "right": "près de la mer"
    },
    {
      "left": "il faudra",
      "right": "clé et heure"
    },
    {
      "left": "je rentrerai",
      "right": "Seuil"
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
  "prompt": "Complétez :\nJe ne resterai ___ longtemps.",
  "answer": "pas"
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
    "rentrerai",
    "au",
    "Seuil",
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
  "word": "rentrerai",
  "hint": "Le futur de rentrer, vers le Seuil."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La chambre sera près de la mer. Il faudra une clé. Je faut arriver tôt.",
  "correct_sentence": "La chambre sera près de la mer. Il faudra une clé. Il faudra arriver tôt.",
  "explanation": "Il faudra (pas je faut)."
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
      "image_path": "/elearning/mfk-a1-m7/chambre.svg",
      "word": "une chambre"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/cle.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/mer.svg",
      "word": "la mer"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/carnet.svg",
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
  "prompt": "Écrivez cinq lignes : je resterai, la chambre sera, deux il faudra, je rentrerai."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre fiche, calmement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Rester, arriver, il faudra',
    'EL',
    $c$Objectif
Retenir rester / arriver au futur et il faudra.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
rester : je resterai / tu resteras / elle restera
arriver : j'arriverai / nous arriverons / on arrivera
rentrer : je rentrerai
être : elle sera / vous serez
il faut / il faudra + nom ou infinitif
Attention : on arrivera (comme il). Pas on arriverons.
Il faudra demander (infinitif).
Auberge des Figues : lieu inventé.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On conjugue « on » comme « nous » au futur (arriverons).",
  "correct": false,
  "explanation": "On arrivera, comme il/elle."
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
      "text": "on arriverons",
      "correct": false
    },
    {
      "text": "on arrivera",
      "correct": true
    },
    {
      "text": "on arriver",
      "correct": false
    },
    {
      "text": "on arriveront",
      "correct": false
    }
  ],
  "explanation": "On arrivera."
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
      "left": "je resterai",
      "right": "nuit"
    },
    {
      "left": "nous arriverons",
      "right": "nous"
    },
    {
      "left": "on arrivera",
      "right": "on = il"
    },
    {
      "left": "il faudra",
      "right": "besoin"
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
  "prompt": "Complétez :\nElle ___ près de la mer. (rester)",
  "answer": "restera"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Vous",
    "serez",
    "à",
    "l'auberge",
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
  "word": "restera",
  "hint": "Le futur de rester, avec elle."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On arriverons avant dix-neuf heures.",
  "correct_sentence": "On arrivera avant dix-neuf heures.",
  "explanation": "On arrivera."
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
      "image_path": "/elearning/mfk-a1-m7/auberge.svg",
      "word": "une auberge"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/chambre.svg",
      "word": "une chambre"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/arriver.svg",
      "word": "arriver"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/rester.svg",
      "word": "rester"
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : resterai, arriverons, sera, faudra."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : je resterai, nous arriverons, on arrivera, il faudra une clé, elle sera calme."
}$j$::jsonb,
    9
  );

  -- ===== Choisir sa saison =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Choisir sa saison'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Choisir sa saison', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Saison sèche ou pluie',
    'CO',
    $c$Objectif
Comprendre un choix de saison : il fera, il pleuvra, je partirai.

Consigne
Quelle saison pour le lac ? Pour l'île ?

Support — Carnet ouvert, thé
Patrick : En saison sèche, il fera chaud. Le lac sera clair.
Hawa : En saison des pluies, il pleuvra. La route sera longue.
Léa : Je partirai en saison sèche. Je verrai le soleil.
Noura : Moi, je visiterai Mwezi-Haut en saison fraîche. Il fera moins chaud.
Ibrahim : Pour le bateau, il faudra peu de vent. Pas la Rive d'Orage.
Aline : Il faut choisir sa saison. On ne partira pas tous le même jour.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa partira en saison des pluies.",
  "correct": false,
  "explanation": "Léa : « Je partirai en saison sèche. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fera-t-il en saison sèche, d'après Patrick ?",
  "options": [
    {
      "text": "Il pleuvra",
      "correct": false
    },
    {
      "text": "Il fera chaud",
      "correct": true
    },
    {
      "text": "Il neigera",
      "correct": false
    },
    {
      "text": "Il fera nuit à midi",
      "correct": false
    }
  ],
  "explanation": "Patrick : « Il fera chaud. »"
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
      "left": "saison sèche",
      "right": "chaud, lac clair"
    },
    {
      "left": "pluies",
      "right": "route longue"
    },
    {
      "left": "saison fraîche",
      "right": "Mwezi-Haut"
    },
    {
      "left": "peu de vent",
      "right": "bateau"
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
  "prompt": "Complétez :\nIl ___ chaud. (faire)",
  "answer": "fera"
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
    "pleuvra",
    "demain",
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
  "word": "pleuvra",
  "hint": "Le futur de pleuvoir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il ferra chaud en saison sèche.",
  "correct_sentence": "Il fera chaud en saison sèche.",
  "explanation": "Faire : il fera (un r)."
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
      "image_path": "/elearning/mfk-a1-m7/saison.svg",
      "word": "une saison"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/soleil.svg",
      "word": "le soleil"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/pluie.svg",
      "word": "la pluie"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/vent.svg",
      "word": "le vent"
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
  "prompt": "Notez trois saisons et une phrase il fera / il pleuvra."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : En saison sèche, il fera chaud. Il pleuvra en saison des pluies. Je partirai. Je verrai le soleil."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Tableau des saisons',
    'CE',
    $c$Objectif
Lire un tableau de saisons inventé pour le carnet.

Consigne
Lisez le tableau.

Support — Tableau Figuier
Choisir sa saison
Saison sèche — il fera chaud — lac des Nénuphars — soleil
Saison des pluies — il pleuvra — route longue — rester au Seuil
Saison fraîche — il fera moins chaud — Mwezi-Haut
Vent fort — Rive d'Orage — on ne prendra pas le bateau
Il faudra regarder le ciel. Il faut demander à Patrick.
Carnet de route
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On prendra le bateau par vent fort.",
  "correct": false,
  "explanation": "Vent fort : on ne prendra pas le bateau."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où aller en saison fraîche ?",
  "options": [
    {
      "text": "Au lac seulement",
      "correct": false
    },
    {
      "text": "À Mwezi-Haut",
      "correct": true
    },
    {
      "text": "À la Rive d'Orage",
      "correct": false
    },
    {
      "text": "Nulle part",
      "correct": false
    }
  ],
  "explanation": "Saison fraîche — Mwezi-Haut."
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
      "left": "sèche",
      "right": "soleil"
    },
    {
      "left": "pluies",
      "right": "Seuil"
    },
    {
      "left": "fraîche",
      "right": "montagne"
    },
    {
      "left": "vent fort",
      "right": "pas de bateau"
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
  "prompt": "Complétez :\nIl ___ regarder le ciel. (futur de falloir)",
  "answer": "faudra"
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
    "fera",
    "moins",
    "chaud",
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
  "word": "saison",
  "hint": "Un moment de l'année, sèche ou des pluies."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il pleuvra. Il faut tu restes au Seuil.",
  "correct_sentence": "Il pleuvra. Il faut rester au Seuil.",
  "explanation": "Il faut + infinitif."
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
      "image_path": "/elearning/mfk-a1-m7/soleil.svg",
      "word": "le soleil"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/pluie.svg",
      "word": "la pluie"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/ete.svg",
      "word": "l'été"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/hiver.svg",
      "word": "l'hiver"
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
  "prompt": "Recopiez le tableau. Ajoutez votre saison et un il fera / il pleuvra."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le tableau, une saison, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire il fera, il pleuvra',
    'PO',
    $c$Objectif
Parler du temps au futur et d'un choix de saison.

Consigne
Répétez, puis choisissez une saison.

Support — Modèles d'Hawa
Il fera chaud.
Il fera frais.
Il pleuvra.
Il y aura du vent.
Je partirai en saison sèche.
Nous resterons s'il pleut.
Il faudra un chapeau.
En hiver, ailleurs, il fera froid.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il fera froid » décrit le temps au futur.",
  "correct": true,
  "explanation": "Faire au futur, pour le temps."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est un projet de départ ?",
  "options": [
    {
      "text": "Il pleuvra",
      "correct": false
    },
    {
      "text": "Il y aura du vent",
      "correct": false
    },
    {
      "text": "Je partirai en saison sèche",
      "correct": true
    },
    {
      "text": "Il fera frais",
      "correct": false
    }
  ],
  "explanation": "Je partirai."
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
      "left": "il fera",
      "right": "chaud / frais / froid"
    },
    {
      "left": "il pleuvra",
      "right": "pluie"
    },
    {
      "left": "il y aura",
      "right": "vent"
    },
    {
      "left": "il faudra",
      "right": "chapeau"
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
  "prompt": "Complétez :\nEn hiver, il fera ___.",
  "answer": "froid"
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
    "partirai",
    "en",
    "saison",
    "sèche",
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
  "word": "chaud",
  "hint": "Le contraire de froid, en saison sèche."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il fera chaud. Je partirai. Il faudra un chapeaux.",
  "correct_sentence": "Il fera chaud. Je partirai. Il faudra un chapeau.",
  "explanation": "Un chapeau, au singulier."
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
      "image_path": "/elearning/mfk-a1-m7/soleil.svg",
      "word": "le soleil"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/pluie.svg",
      "word": "la pluie"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/printemps.svg",
      "word": "le printemps"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/automne.svg",
      "word": "l'automne"
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
  "prompt": "Écrivez six phrases : deux il fera, un il pleuvra, un je partirai, un nous resterons, un il faudra."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre saison."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma saison',
    'PE',
    $c$Objectif
Écrire un choix de saison.

Consigne
Imitez le mot de Léa.

Support — Mot de Léa
Léa
Je partirai en saison sèche.
Il fera chaud. Il y aura du soleil.
Je ne partirai pas s'il pleut.
Il faudra de l'eau. Il faudra un chapeau.
À bientôt, lac des Nénuphars.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa partira s'il pleut.",
  "correct": false,
  "explanation": "« Je ne partirai pas s'il pleut. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faudra-t-il, d'après Léa ?",
  "options": [
    {
      "text": "Un tambour et une radio",
      "correct": false
    },
    {
      "text": "De l'eau et un chapeau",
      "correct": true
    },
    {
      "text": "Un avion",
      "correct": false
    },
    {
      "text": "De la neige",
      "correct": false
    }
  ],
  "explanation": "Eau et chapeau."
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
      "left": "saison sèche",
      "right": "départ"
    },
    {
      "left": "il fera",
      "right": "chaud"
    },
    {
      "left": "s'il pleut",
      "right": "pas de départ"
    },
    {
      "left": "il faudra",
      "right": "eau, chapeau"
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
  "prompt": "Complétez :\nIl y aura du ___.",
  "answer": "soleil"
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
    "fera",
    "chaud",
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
  "word": "soleil",
  "hint": "Il y en aura, en saison sèche."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je partirai en saison sèche. Il ferra chaud.",
  "correct_sentence": "Je partirai en saison sèche. Il fera chaud.",
  "explanation": "Il fera (un r)."
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
      "image_path": "/elearning/mfk-a1-m7/saison.svg",
      "word": "une saison"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/soleil.svg",
      "word": "le soleil"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/pluie.svg",
      "word": "la pluie"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/valise.svg",
      "word": "une valise"
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
  "prompt": "Écrivez cinq lignes : je partirai en…, il fera, je ne… pas, deux il faudra."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot de saison."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Il fera, il pleuvra, saisons',
    'EL',
    $c$Objectif
Retenir le temps au futur et les saisons du carnet.

Consigne
Apprenez la fiche.

Support — Fiche d'Hawa
il fera chaud / frais / froid
il pleuvra
il y aura du vent / du soleil
saison sèche / saison des pluies / saison fraîche
ailleurs : printemps, été, automne, hiver
faire (temps) : il fera
Attention : il fera (pas il ferra). Il pleuvra.
Il faut / il faudra choisir sa saison.
On ne partira pas tous le même jour.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « il ferra froid ».",
  "correct": false,
  "explanation": "Il fera froid."
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
      "text": "il pleuvra",
      "correct": true
    },
    {
      "text": "il pleuvera",
      "correct": false
    },
    {
      "text": "il pleusera",
      "correct": false
    },
    {
      "text": "il pleuvoir",
      "correct": false
    }
  ],
  "explanation": "Il pleuvra."
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
      "left": "saison sèche",
      "right": "chaud"
    },
    {
      "left": "pluies",
      "right": "il pleuvra"
    },
    {
      "left": "hiver",
      "right": "froid"
    },
    {
      "left": "été",
      "right": "soleil"
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
  "prompt": "Complétez :\nEn saison des pluies, il ___.",
  "answer": "pleuvra"
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
    "y",
    "aura",
    "du",
    "vent",
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
  "word": "frais",
  "hint": "Moins chaud, à Mwezi-Haut."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il pleuvra. Il fera froid. Il fauts un chapeau.",
  "correct_sentence": "Il pleuvra. Il fera froid. Il faut un chapeau.",
  "explanation": "Il faut, sans s."
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
      "image_path": "/elearning/mfk-a1-m7/ete.svg",
      "word": "l'été"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/hiver.svg",
      "word": "l'hiver"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/printemps.svg",
      "word": "le printemps"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/automne.svg",
      "word": "l'automne"
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : fera, pleuvra, saison sèche, il faudra."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : il fera chaud, il pleuvra, il y aura du vent, printemps, été, automne, hiver."
}$j$::jsonb,
    9
  );

  -- ===== Carnets de route =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Carnets de route'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Carnets de route', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — On écrira le chemin',
    'CO',
    $c$Objectif
Comprendre un projet de carnet : j'écrirai, nous raconterons, je serai.

Consigne
Qui écrira quoi ? Que racontera-t-on au retour ?

Support — Sous le figuier, carnets ouverts
Léa : J'écrirai chaque soir. Je serai fatiguée, mais contente.
Noura : Nous raconterons le lac, le bateau, l'auberge.
Mado : Il faut une ligne par jour. On pourra relire plus tard.
Patrick : Je noterai les heures. Vous serez précis.
Joël : Moi, j'écrirai peu. Je dessinerai la moto.
Aline : Au retour, on sera au Seuil. Il faudra lire une page, ensemble.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa écrira chaque soir.",
  "correct": true,
  "explanation": "Léa : « J'écrirai chaque soir. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que dessinera Joël ?",
  "options": [
    {
      "text": "Le lac",
      "correct": false
    },
    {
      "text": "La moto",
      "correct": true
    },
    {
      "text": "L'auberge",
      "correct": false
    },
    {
      "text": "La radio",
      "correct": false
    }
  ],
  "explanation": "Joël : « Je dessinerai la moto. »"
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
      "left": "Léa",
      "right": "écrira"
    },
    {
      "left": "Noura",
      "right": "racontera le voyage"
    },
    {
      "left": "Patrick",
      "right": "notera les heures"
    },
    {
      "left": "Joël",
      "right": "dessinera"
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
  "prompt": "Complétez :\nJ'___ chaque soir. (écrire)",
  "answer": "écrirai"
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
    "raconterons",
    "le",
    "lac",
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
  "word": "écrirai",
  "hint": "Le futur de écrire, avec je."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je serai fatiguée. J'écrireai chaque soir.",
  "correct_sentence": "Je serai fatiguée. J'écrirai chaque soir.",
  "explanation": "Écrire : j'écrirai."
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
      "image_path": "/elearning/mfk-a1-m7/carnet.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/visiter.svg",
      "word": "visiter"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/partir.svg",
      "word": "partir"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/pont.svg",
      "word": "un pont"
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
  "prompt": "Notez quatre verbes au futur entendus (écrire, raconter, noter, dessiner)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : J'écrirai chaque soir. Nous raconterons le lac. Je serai contente. Il faudra lire une page."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Consignes du carnet',
    'CE',
    $c$Objectif
Lire des consignes pour tenir un carnet de route.

Consigne
Lisez la page.

Support — Page de Mado
Carnets de route — Seuil des Sources
1. J'écrirai une ligne le soir.
2. Nous raconterons un lieu : lac, port, île, auberge.
3. Il faudra la date et l'heure.
4. On pourra coller un petit dessin.
5. Au retour, nous serons sous le figuier. Nous lirons.
Inventé pour le Seuil. Pas un guide de voyage réel.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Il faudra la date et l'heure.",
  "correct": true,
  "explanation": "Point 3 de la page."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où sera-t-on au retour, pour lire ?",
  "options": [
    {
      "text": "À l'île",
      "correct": false
    },
    {
      "text": "Sous le figuier",
      "correct": true
    },
    {
      "text": "À Mwezi-Haut",
      "correct": false
    },
    {
      "text": "Dans le minibus",
      "correct": false
    }
  ],
  "explanation": "« Nous serons sous le figuier. »"
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
      "left": "j'écrirai",
      "right": "une ligne"
    },
    {
      "left": "nous raconterons",
      "right": "un lieu"
    },
    {
      "left": "il faudra",
      "right": "date et heure"
    },
    {
      "left": "nous lirons",
      "right": "retour"
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
  "prompt": "Complétez :\nNous ___ sous le figuier. (être)",
  "answer": "serons"
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
    "pourra",
    "coller",
    "un",
    "dessin",
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
  "word": "raconterons",
  "hint": "Le futur de raconter, avec nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous serons sous le figuier. Nous liserons une page.",
  "correct_sentence": "Nous serons sous le figuier. Nous lirons une page.",
  "explanation": "Lire au futur : nous lirons."
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
      "image_path": "/elearning/mfk-a1-m7/carnet.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/carte.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/ticket.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/boussole.svg",
      "word": "une boussole"
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
  "prompt": "Recopiez trois consignes. Ajoutez la vôtre au futur."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la page de Mado, un numéro, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire j''écrirai, nous serons',
    'PO',
    $c$Objectif
Projeter l'écriture du voyage : écrire, raconter, être, lire.

Consigne
Répétez, puis dites ce que vous écrirez.

Support — Modèles de Mado
J'écrirai une ligne.
Tu écriras la date.
Nous raconterons le bateau.
Je serai contente.
Vous serez précis.
Nous lirons au retour.
Il faudra un crayon.
On pourra dessiner.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Nous lirons » est le futur de lire.",
  "correct": true,
  "explanation": "Nous lirons."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme d'être est correcte au futur, avec je ?",
  "options": [
    {
      "text": "je sera",
      "correct": false
    },
    {
      "text": "je serai",
      "correct": true
    },
    {
      "text": "je suisrai",
      "correct": false
    },
    {
      "text": "j'éterai",
      "correct": false
    }
  ],
  "explanation": "Je serai."
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
      "left": "écrire",
      "right": "j'écrirai"
    },
    {
      "left": "être",
      "right": "je serai"
    },
    {
      "left": "lire",
      "right": "nous lirons"
    },
    {
      "left": "raconter",
      "right": "nous raconterons"
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
  "prompt": "Complétez :\nTu ___ la date. (écrire)",
  "answer": "écriras"
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
    "serai",
    "contente",
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
  "word": "lirons",
  "hint": "Le futur de lire, avec nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je serai content.",
  "correct_sentence": "Je serai contente.",
  "explanation": "Léa = elle : contente."
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
      "image_path": "/elearning/mfk-a1-m7/carnet.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/partir.svg",
      "word": "partir"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/arriver.svg",
      "word": "arriver"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/visiter.svg",
      "word": "visiter"
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
  "prompt": "Écrivez six phrases : écrirai, raconterons, serai, serez, lirons, faudra."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis une ligne pour votre carnet."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma première ligne',
    'PE',
    $c$Objectif
Écrire la première page d'un carnet de route.

Consigne
Imitez la page de Noura.

Support — Page de Noura
Carnet de Noura Sarr
Demain, je partirai. J'écrirai le soir.
Nous visiterons le lac. Je serai à l'Auberge des Figues.
Il faudra une ligne, seulement une.
Au retour, nous raconterons tout sous le figuier.
Noura
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Noura écrira le matin, d'après sa page.",
  "correct": false,
  "explanation": "« J'écrirai le soir. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de lignes faudra-t-il, d'après Noura ?",
  "options": [
    {
      "text": "Dix",
      "correct": false
    },
    {
      "text": "Une",
      "correct": true
    },
    {
      "text": "Zéro",
      "correct": false
    },
    {
      "text": "Cent",
      "correct": false
    }
  ],
  "explanation": "« une ligne, seulement une »."
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
      "left": "je partirai",
      "right": "demain"
    },
    {
      "left": "j'écrirai",
      "right": "le soir"
    },
    {
      "left": "je serai",
      "right": "auberge"
    },
    {
      "left": "nous raconterons",
      "right": "retour"
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
  "prompt": "Complétez :\nNous ___ tout sous le figuier.",
  "answer": "raconterons"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'écrirai",
    "le",
    "soir",
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
  "word": "ligne",
  "hint": "Une seule, chaque soir, dans le carnet."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Demain je partirai. J'écrirai le soir. Je sera à l'auberge.",
  "correct_sentence": "Demain je partirai. J'écrirai le soir. Je serai à l'auberge.",
  "explanation": "Je serai (pas je sera)."
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
      "image_path": "/elearning/mfk-a1-m7/carnet.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/lac.svg",
      "word": "un lac"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/auberge.svg",
      "word": "une auberge"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/partir.svg",
      "word": "partir"
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
  "prompt": "Écrivez cinq lignes de carnet : partirai, écrirai, visiterons, serai, raconterons."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre première page, une phrase, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Écrire, être, lire au futur',
    'EL',
    $c$Objectif
Retenir j'écrirai, je serai, nous lirons, nous raconterons.

Consigne
Apprenez la fiche, puis promettez une ligne.

Support — Fiche de Mado
écrire : j'écrirai / tu écriras / nous écrirons
être : je serai / tu seras / nous serons / vous serez
lire : je lirai / nous lirons
raconter : nous raconterons
il faudra une ligne
on pourra dessiner
Attention : j'écrirai (pas j'écrireai). Je serai (pas je sera).
Nous lirons (pas nous liserons).
Le carnet est inventé, sous le figuier.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « j'écrireai ».",
  "correct": false,
  "explanation": "J'écrirai."
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
      "text": "nous liserons",
      "correct": false
    },
    {
      "text": "nous lirons",
      "correct": true
    },
    {
      "text": "nous lireons",
      "correct": false
    },
    {
      "text": "nous lesirons",
      "correct": false
    }
  ],
  "explanation": "Nous lirons."
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
      "left": "écrire",
      "right": "j'écrirai"
    },
    {
      "left": "être",
      "right": "nous serons"
    },
    {
      "left": "lire",
      "right": "nous lirons"
    },
    {
      "left": "raconter",
      "right": "nous raconterons"
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
  "prompt": "Complétez :\nVous ___ précis. (être)",
  "answer": "serez"
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
    "écrirons",
    "une",
    "ligne",
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
  "word": "serons",
  "hint": "Le futur de être, avec nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous raconterons le lac. Vous sera sous le figuier.",
  "correct_sentence": "Nous raconterons le lac. Vous serez sous le figuier.",
  "explanation": "Vous serez."
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
      "image_path": "/elearning/mfk-a1-m7/carnet.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/boussole.svg",
      "word": "une boussole"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/carte.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a1-m7/visiter.svg",
      "word": "visiter"
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
  "prompt": "Recopiez la fiche. Écrivez quatre futurs : écrirai, serai, lirons, raconterons."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : j'écrirai, je serai, nous serons, nous lirons, nous raconterons, il faudra une ligne."
}$j$::jsonb,
    9
  );

END;
$$;
