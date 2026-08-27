/*
  Seed eLearning MFK — Module 6 A1 « Histoires vécues »

  Même micro-monde que les Modules 3, 4 et 5 : cour « Le Seuil des Sources », Rukiri-Nord.
  Cahier des histoires inventé sous le figuier.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a1-m6/
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
  v_module_title text := 'A1 — Histoires vécues';
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
      'Seed A1 Module 6 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed Module 6 : enseignant % (%)', v_teacher_email, v_teacher_id;

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
      'Grande étape 6 : raconter au passé composé, parler d''un passé récent et d''un projet, lire une bio, décrire, comparer avant et maintenant, donner un conseil — cahier des histoires sous le figuier du Seuil des Sources (Rukiri-Nord).',
      'A1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape 6 : raconter au passé composé, parler d''un passé récent et d''un projet, lire une bio, décrire, comparer avant et maintenant, donner un conseil — cahier des histoires sous le figuier du Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'A1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Apprendre à sa manière =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Apprendre à sa manière'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Apprendre à sa manière', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Hier, sous le figuier',
    'CO',
    $c$Objectif
Comprendre un récit au passé composé : j'ai écouté, j'ai lu, j'ai appris.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui a appris quoi, hier ?

Support — Cahier des histoires, banc du Seuil
Léa : Hier, j'ai écouté Aline. J'ai répété les heures. J'ai appris « il est midi ».
Aline : Très bien. Moi, j'ai écrit trois cartes pour le fil.
Patrick : Hier, j'ai lu une page de Mado. J'ai appris un mot : figuier.
Hawa : J'ai écouté Radio Figuier. J'ai noté deux phrases.
Joël : Moi, j'ai travaillé. Je n'ai pas lu. Demain, peut-être.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa a appris « il est midi ».",
  "correct": true,
  "explanation": "Léa dit : j'ai appris « il est midi »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qu'est-ce que Patrick a lu ?",
  "options": [
    {
      "text": "Le journal du marché",
      "correct": false
    },
    {
      "text": "Une page de Mado",
      "correct": true
    },
    {
      "text": "Une carte d'Aline",
      "correct": false
    },
    {
      "text": "Un horaire de minibus",
      "correct": false
    }
  ],
  "explanation": "Patrick : « j'ai lu une page de Mado. »"
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
      "right": "a écouté et répété"
    },
    {
      "left": "Aline",
      "right": "a écrit des cartes"
    },
    {
      "left": "Patrick",
      "right": "a lu une page"
    },
    {
      "left": "Joël",
      "right": "n'a pas lu"
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
  "prompt": "Complétez :\nHier, j'___ écouté Aline.",
  "answer": "ai"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'ai",
    "appris",
    "un",
    "mot",
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
  "word": "appris",
  "hint": "Le participe de apprendre, après j'ai."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Hier j'ai apprendre les heures.",
  "correct_sentence": "Hier j'ai appris les heures.",
  "explanation": "Passé composé : j'ai + participe (appris)."
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
      "image_path": "/elearning/mfk-a1-m6/cahier.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/hier.svg",
      "word": "hier"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/ecouter.svg",
      "word": "écouter"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/apprendre.svg",
      "word": "apprendre"
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
  "prompt": "Notez pour quatre personnes : j'ai + verbe (écouté, écrit, lu, travaillé)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Hier, j'ai écouté. J'ai lu une page. J'ai appris un mot. J'ai écrit trois cartes."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Pages du cahier',
    'CE',
    $c$Objectif
Lire de courtes notes au passé composé.

Consigne
Lisez les pages épinglées, puis répondez.

Support — Cahier des histoires
Léa — Hier, j'ai écouté. J'ai répété. J'ai appris trois phrases.
Aline — Hier, j'ai écrit les cartes du fil. J'ai aidé Léa.
Patrick — Hier, j'ai lu les Notes du figuier. J'ai appris le mot « source ».
Hawa — Hier, j'ai écouté la radio. Je n'ai pas écrit.
Joël — Hier, j'ai travaillé avec la moto. Je n'ai pas lu.
Règle du Seuil : une phrase avec j'ai, une phrase vraie.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa a écrit hier.",
  "correct": false,
  "explanation": "Hawa : « Je n'ai pas écrit. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a aidé Léa ?",
  "options": [
    {
      "text": "Joël",
      "correct": false
    },
    {
      "text": "Patrick",
      "correct": false
    },
    {
      "text": "Aline",
      "correct": true
    },
    {
      "text": "Hawa",
      "correct": false
    }
  ],
  "explanation": "Aline : « J'ai aidé Léa. »"
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
      "left": "j'ai écouté",
      "right": "Léa, Hawa"
    },
    {
      "left": "j'ai lu",
      "right": "Patrick"
    },
    {
      "left": "j'ai écrit",
      "right": "Aline"
    },
    {
      "left": "je n'ai pas lu",
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
  "prompt": "Complétez :\nJe n'___ pas écrit.",
  "answer": "ai"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'ai",
    "lu",
    "une",
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
  "word": "écrit",
  "hint": "Le participe de écrire, après j'ai."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je n'ai pas écouté pas la radio.",
  "correct_sentence": "Je n'ai pas écouté la radio.",
  "explanation": "Une seule négation : ne… pas autour de l'auxiliaire."
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
      "image_path": "/elearning/mfk-a1-m6/lire.svg",
      "word": "lire"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/ecrire.svg",
      "word": "écrire"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/cahier.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/figuier.svg",
      "word": "le figuier"
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
  "prompt": "Recopiez deux pages. Ajoutez la vôtre : hier, j'ai… / je n'ai pas…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les cinq pages, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire ce qu''on a fait',
    'PO',
    $c$Objectif
Raconter au passé composé avec avoir : j'ai, tu as, il/elle a.

Consigne
Répétez, puis racontez hier (vrai ou inventé).

Support — Modèles de Léa
J'ai écouté.
J'ai lu une page.
J'ai écrit une carte.
J'ai appris un mot.
Tu as écouté ?
Il a lu.
Elle a écrit.
Je n'ai pas travaillé.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« J'ai » est l'auxiliaire avoir au passé composé.",
  "correct": true,
  "explanation": "J'ai + participe."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est au passé composé ?",
  "options": [
    {
      "text": "J'écoute",
      "correct": false
    },
    {
      "text": "Je vais écouter",
      "correct": false
    },
    {
      "text": "J'ai écouté",
      "correct": true
    },
    {
      "text": "J'écoute demain",
      "correct": false
    }
  ],
  "explanation": "J'ai écouté = passé composé."
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
      "left": "j'ai",
      "right": "je"
    },
    {
      "left": "tu as",
      "right": "tu"
    },
    {
      "left": "il a",
      "right": "il"
    },
    {
      "left": "elle a",
      "right": "elle"
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
  "prompt": "Complétez :\nTu ___ lu une page ?",
  "answer": "as"
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
    "a",
    "écrit",
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
  "word": "écouté",
  "hint": "Le participe de écouter."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tu a écouté hier.",
  "correct_sentence": "Tu as écouté hier.",
  "explanation": "Tu as (avec s)."
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
      "image_path": "/elearning/mfk-a1-m6/ecouter.svg",
      "word": "écouter"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/lire.svg",
      "word": "lire"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/ecrire.svg",
      "word": "écrire"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/apprendre.svg",
      "word": "apprendre"
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
  "prompt": "Écrivez six phrases : trois j'ai…, une tu as…, une il a…, une je n'ai pas…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre hier."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma page d''hier',
    'PE',
    $c$Objectif
Écrire une courte page au passé composé.

Consigne
Imitez la page de Léa.

Support — Page de Léa
Hier,
j'ai écouté Aline.
J'ai répété les heures.
J'ai appris trois phrases.
Je n'ai pas dansé.
Léa Niyonzima
Cahier des histoires
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa a dansé hier.",
  "correct": false,
  "explanation": "« Je n'ai pas dansé. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de phrases Léa a-t-elle apprises ?",
  "options": [
    {
      "text": "Une",
      "correct": false
    },
    {
      "text": "Deux",
      "correct": false
    },
    {
      "text": "Trois",
      "correct": true
    },
    {
      "text": "Zéro",
      "correct": false
    }
  ],
  "explanation": "« J'ai appris trois phrases. »"
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
      "left": "j'ai écouté",
      "right": "Aline"
    },
    {
      "left": "j'ai répété",
      "right": "les heures"
    },
    {
      "left": "j'ai appris",
      "right": "trois phrases"
    },
    {
      "left": "je n'ai pas",
      "right": "dansé"
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
  "prompt": "Complétez :\nJ'ai ___ trois phrases.",
  "answer": "appris"
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
    "n'ai",
    "pas",
    "dansé",
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
  "word": "répété",
  "hint": "Léa a… les heures, après Aline."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai appris trois phrase.",
  "correct_sentence": "J'ai appris trois phrases.",
  "explanation": "Phrases au pluriel après trois."
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
      "image_path": "/elearning/mfk-a1-m6/cahier.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/hier.svg",
      "word": "hier"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/apprendre.svg",
      "word": "apprendre"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/danse.svg",
      "word": "la danse"
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
  "prompt": "Écrivez cinq lignes : hier, deux j'ai, un j'ai appris, un je n'ai pas, signature."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre page, une phrase, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — J''ai + participe',
    'EL',
    $c$Objectif
Retenir le passé composé avec avoir.

Consigne
Apprenez la fiche, puis racontez hier.

Support — Fiche du cahier
j'ai / tu as / il a / elle a / nous avons + participe
j'ai écouté, lu, écrit, appris, travaillé, dansé
je n'ai pas + participe
hier / samedi dernier
Participe : écouté, lu, écrit, appris (pas « apprendre »).
Attention : tu as (pas tu a). J'ai appris (invariable ici).
On ne dit pas « j'ai apprendre ».
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « j'ai apprendre ».",
  "correct": false,
  "explanation": "J'ai appris."
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
      "text": "j'ai lu",
      "correct": true
    },
    {
      "text": "j'ai lire",
      "correct": false
    },
    {
      "text": "j'ai lis",
      "correct": false
    },
    {
      "text": "j'ai lise",
      "correct": false
    }
  ],
  "explanation": "J'ai lu."
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
      "left": "écouter",
      "right": "écouté"
    },
    {
      "left": "lire",
      "right": "lu"
    },
    {
      "left": "écrire",
      "right": "écrit"
    },
    {
      "left": "apprendre",
      "right": "appris"
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
  "prompt": "Complétez :\nElle a ___ une carte.",
  "answer": "écrit"
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
    "avons",
    "lu",
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
  "word": "avons",
  "hint": "Nous… (auxiliaire avoir)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il a apprendre un mot.",
  "correct_sentence": "Il a appris un mot.",
  "explanation": "Passé composé : a + appris."
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
      "image_path": "/elearning/mfk-a1-m6/apprendre.svg",
      "word": "apprendre"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/lire.svg",
      "word": "lire"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/ecrire.svg",
      "word": "écrire"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/cahier.svg",
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : écouté / lu / écrit / appris."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : j'ai, tu as, il a, elle a, puis j'ai écouté, j'ai lu, j'ai appris."
}$j$::jsonb,
    9
  );

  -- ===== Jeunes talents =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Jeunes talents'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Jeunes talents', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Sami et Benoît sous le fil',
    'CO',
    $c$Objectif
Comprendre je viens de + infinitif et je vais + infinitif.

Consigne
Qui vient de faire quoi ? Qui va faire quoi ?

Support — Cour, après la Salle des Herbes
Sami : Je viens de jouer du tambour. J'ai dix-sept ans. Je suis de Rukiri-Nord.
Rose : Bravo. Moi, je vais danser ce soir.
Benoît : Je viens de courir au jardin. Demain, je vais courir encore.
Kévin : Je viens de jouer au football avec papa.
Léa : Moi, je vais écrire une page sur vous, dans le cahier.
Aline : Les jeunes talents du Seuil. On va écouter, ce soir.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Sami vient de jouer du tambour.",
  "correct": true,
  "explanation": "Sami : « Je viens de jouer du tambour. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que va faire Rose ce soir ?",
  "options": [
    {
      "text": "Courir",
      "correct": false
    },
    {
      "text": "Jouer au football",
      "correct": false
    },
    {
      "text": "Danser",
      "correct": true
    },
    {
      "text": "Écrire un livre",
      "correct": false
    }
  ],
  "explanation": "Rose : « je vais danser ce soir. »"
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
      "left": "Sami",
      "right": "vient de jouer"
    },
    {
      "left": "Benoît",
      "right": "vient de courir"
    },
    {
      "left": "Rose",
      "right": "va danser"
    },
    {
      "left": "Léa",
      "right": "va écrire"
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
  "prompt": "Complétez :\nJe ___ de jouer du tambour.",
  "answer": "viens"
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
    "vais",
    "danser",
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
  "word": "viens",
  "hint": "Je… de + infinitif : c'est tout proche."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je vien de jouer.",
  "correct_sentence": "Je viens de jouer.",
  "explanation": "Je viens (avec s)."
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
      "image_path": "/elearning/mfk-a1-m6/tambour.svg",
      "word": "un tambour"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/courir.svg",
      "word": "courir"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/talent.svg",
      "word": "un talent"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/jeune.svg",
      "word": "jeune"
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
  "prompt": "Notez deux « je viens de » et deux « je vais » entendus."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je viens de jouer. Je viens de courir. Je vais danser. Je vais écrire."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Cartes « vient de » / « va »',
    'CE',
    $c$Objectif
Lire des projets et des actions toutes proches.

Consigne
Lisez les cartes du cahier.

Support — Cartes jeunes talents
Sami Niyonteze — 17 ans — vient de jouer du tambour — va répéter demain
Benoît Habumuremyi — vient de courir — va courir demain matin
Rose Iradukunda — va danser ce soir à la Salle des Herbes
Kévin Nkurunziza — vient de jouer au football
Léa — va écrire leurs histoires
Feuille du Seuil : un talent, une phrase au passé récent, une au futur proche.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Benoît va courir ce soir.",
  "correct": false,
  "explanation": "Benoît va courir demain matin."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel âge a Sami ?",
  "options": [
    {
      "text": "Huit ans",
      "correct": false
    },
    {
      "text": "Dix-sept ans",
      "correct": true
    },
    {
      "text": "Trente ans",
      "correct": false
    },
    {
      "text": "On ne sait pas",
      "correct": false
    }
  ],
  "explanation": "Carte : 17 ans."
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
      "left": "vient de",
      "right": "tout près dans le passé"
    },
    {
      "left": "va",
      "right": "tout près dans le futur"
    },
    {
      "left": "tambour",
      "right": "Sami"
    },
    {
      "left": "football",
      "right": "Kévin"
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
  "prompt": "Complétez :\nSami va ___ demain.",
  "answer": "répéter"
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
    "vient",
    "de",
    "courir",
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
  "word": "demain",
  "hint": "Le jour après aujourd'hui, pour un projet."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je vas danser ce soir.",
  "correct_sentence": "Je vais danser ce soir.",
  "explanation": "Je vais (pas je vas)."
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
      "image_path": "/elearning/mfk-a1-m6/recent.svg",
      "word": "venir de"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/projet.svg",
      "word": "un projet"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/tambour.svg",
      "word": "un tambour"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/danse.svg",
      "word": "la danse"
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
  "prompt": "Recopiez deux cartes. Ajoutez la vôtre : je viens de… / je vais…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les cartes, puis la phrase de la Feuille du Seuil."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire je viens de, je vais',
    'PO',
    $c$Objectif
Dire un passé récent et un projet proche.

Consigne
Répétez, puis parlez de vous.

Support — Modèles de Sami
Je viens de jouer.
Tu viens de courir.
Il vient de manger.
Je vais répéter.
Tu vas danser.
Elle va écrire.
Nous allons écouter.
On va au jardin.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je viens de » parle d'un passé tout proche.",
  "correct": true,
  "explanation": "Venir de + infinitif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est un projet proche ?",
  "options": [
    {
      "text": "Je viens de jouer",
      "correct": false
    },
    {
      "text": "J'ai joué hier",
      "correct": false
    },
    {
      "text": "Je vais répéter",
      "correct": true
    },
    {
      "text": "Je joue toujours",
      "correct": false
    }
  ],
  "explanation": "Je vais + infinitif = futur proche."
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
      "left": "je viens",
      "right": "de + infinitif"
    },
    {
      "left": "tu viens",
      "right": "de + infinitif"
    },
    {
      "left": "je vais",
      "right": "infinitif"
    },
    {
      "left": "tu vas",
      "right": "infinitif"
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
  "prompt": "Complétez :\nTu ___ danser ce soir.",
  "answer": "vas"
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
    "allons",
    "écouter",
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
  "word": "allons",
  "hint": "Nous… + infinitif : futur proche."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il vient de joue.",
  "correct_sentence": "Il vient de jouer.",
  "explanation": "Venir de + infinitif (jouer)."
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
      "image_path": "/elearning/mfk-a1-m6/recent.svg",
      "word": "venir de"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/projet.svg",
      "word": "un projet"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/courir.svg",
      "word": "courir"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/talent.svg",
      "word": "un talent"
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
  "prompt": "Écrivez six phrases : trois je viens de, trois je vais."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis un talent (vrai ou inventé)."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma carte de talent',
    'PE',
    $c$Objectif
Écrire une carte : je viens de / je vais.

Consigne
Imitez la carte de Benoît.

Support — Carte de Benoît
Je m'appelle Benoît Habumuremyi.
Je viens de courir au jardin des Sources.
Demain, je vais courir encore.
Je n'ai pas dix-sept ans. J'ai vingt ans.
Benoît
Jeunes talents — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Benoît a dix-sept ans.",
  "correct": false,
  "explanation": "« Je n'ai pas dix-sept ans. J'ai vingt ans. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Benoît vient-il de courir ?",
  "options": [
    {
      "text": "À la salle",
      "correct": false
    },
    {
      "text": "Au jardin des Sources",
      "correct": true
    },
    {
      "text": "Au marché",
      "correct": false
    },
    {
      "text": "À l'accueil",
      "correct": false
    }
  ],
  "explanation": "« au jardin des Sources »."
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
      "left": "je viens de",
      "right": "courir"
    },
    {
      "left": "je vais",
      "right": "courir encore"
    },
    {
      "left": "vingt ans",
      "right": "âge"
    },
    {
      "left": "jardin",
      "right": "lieu"
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
  "prompt": "Complétez :\nJe viens ___ courir.",
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
    "Je",
    "vais",
    "courir",
    "encore",
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
  "word": "courir",
  "hint": "Le verbe de Benoît, au jardin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je viens de courir. Je vas courir demain.",
  "correct_sentence": "Je viens de courir. Je vais courir demain.",
  "explanation": "Je vais (pas je vas)."
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
      "image_path": "/elearning/mfk-a1-m6/courir.svg",
      "word": "courir"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/jeune.svg",
      "word": "jeune"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/projet.svg",
      "word": "un projet"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/figuier.svg",
      "word": "le figuier"
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
  "prompt": "Écrivez votre carte : je m'appelle, je viens de, je vais, âge, signature."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre carte, simplement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Venir de, aller + infinitif',
    'EL',
    $c$Objectif
Retenir le passé récent et le futur proche.

Consigne
Étudiez la fiche.

Support — Fiche de Sami
Passé récent : je viens / tu viens / il vient / elle vient + de + infinitif
Futur proche : je vais / tu vas / il va / elle va + infinitif
nous venons de / nous allons
Attention : je viens (pas je vien). Je vais (pas je vas).
Après de / après vais : un infinitif (jouer, courir, danser).
Hier = passé composé. Tout à l'heure = souvent venir de / aller.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je vas répéter ».",
  "correct": false,
  "explanation": "Je vais répéter."
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
      "text": "il vien de courir",
      "correct": false
    },
    {
      "text": "il vient de courir",
      "correct": true
    },
    {
      "text": "il viennent de courir",
      "correct": false
    },
    {
      "text": "il venir de courir",
      "correct": false
    }
  ],
  "explanation": "Il vient de courir."
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
      "left": "venir de",
      "right": "passé tout proche"
    },
    {
      "left": "aller + inf.",
      "right": "futur tout proche"
    },
    {
      "left": "j'ai joué",
      "right": "passé composé"
    },
    {
      "left": "infinitif",
      "right": "jouer, courir"
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
  "prompt": "Complétez :\nElle ___ de danser.",
  "answer": "vient"
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
    "vas",
    "écrire",
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
  "word": "vient",
  "hint": "Il / elle… de + infinitif."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous venons de dansons.",
  "correct_sentence": "Nous venons de danser.",
  "explanation": "De + infinitif : danser."
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
      "image_path": "/elearning/mfk-a1-m6/recent.svg",
      "word": "venir de"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/projet.svg",
      "word": "un projet"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/tambour.svg",
      "word": "un tambour"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/danse.svg",
      "word": "la danse"
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
  "prompt": "Recopiez la fiche. Écrivez deux je viens de et deux je vais."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites je viens, tu viens, il vient, je vais, tu vas, elle va, puis deux phrases."
}$j$::jsonb,
    9
  );

  -- ===== Plumes francophones =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Plumes francophones'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Plumes francophones', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Mado, la plume du figuier',
    'CO',
    $c$Objectif
Comprendre une bio simple : elle est née, elle a écrit, elle habite.

Consigne
Où Mado est-elle née ? Qu'a-t-elle écrit ?

Support — Lecture à voix haute, cahier ouvert
Patrick : Voici Mado Karekezi. Elle est née à Rukiri-Nord.
Léa : Elle a quel âge ?
Aline : Elle a soixante ans. Elle habite près du jardin.
Hawa : Elle a écrit les Notes du figuier. Ce sont de petites histoires.
Rose : Elle parle français. Elle a appris ici, à sa manière.
Mado : J'ai écrit pour la colline. Je vais lire une page, ce soir.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado est née à Rukiri-Nord.",
  "correct": true,
  "explanation": "Patrick : « Elle est née à Rukiri-Nord. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qu'a écrit Mado ?",
  "options": [
    {
      "text": "Un horaire de minibus",
      "correct": false
    },
    {
      "text": "Les Notes du figuier",
      "correct": true
    },
    {
      "text": "Un album de photos",
      "correct": false
    },
    {
      "text": "Une carte de danse",
      "correct": false
    }
  ],
  "explanation": "Hawa : « Elle a écrit les Notes du figuier. »"
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
      "left": "est née",
      "right": "naissance"
    },
    {
      "left": "a écrit",
      "right": "livres / notes"
    },
    {
      "left": "habite",
      "right": "maintenant"
    },
    {
      "left": "va lire",
      "right": "ce soir"
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
  "prompt": "Complétez :\nElle ___ née à Rukiri-Nord.",
  "answer": "est"
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
    "a",
    "écrit",
    "des",
    "notes",
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
  "word": "née",
  "hint": "Le participe avec être, pour une femme."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Elle a née à Rukiri-Nord.",
  "correct_sentence": "Elle est née à Rukiri-Nord.",
  "explanation": "Naître se conjugue avec être : elle est née."
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
      "image_path": "/elearning/mfk-a1-m6/plume.svg",
      "word": "une plume"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/naissance.svg",
      "word": "naître"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/figuier.svg",
      "word": "le figuier"
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
  "prompt": "Notez : lieu de naissance, âge, livre, projet de ce soir."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Elle est née ici. Elle a soixante ans. Elle a écrit des notes. Elle va lire ce soir."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fiche bio de Mado',
    'CE',
    $c$Objectif
Lire une fiche biographique inventée.

Consigne
Lisez la fiche de la Feuille du Seuil.

Support — Feuille du Seuil
Mado Karekezi — plume de Rukiri-Nord
Elle est née à Rukiri-Nord.
Elle a soixante ans.
Elle habite près du jardin des Sources.
Elle a écrit les Notes du figuier (petites histoires).
Elle parle français et kinyarwanda.
Ce soir, elle va lire sous le figuier.
Personne réelle ? Non. Figure du cahier, inventée pour le Seuil.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado habite loin de la colline.",
  "correct": false,
  "explanation": "« Elle habite près du jardin des Sources. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que va faire Mado ce soir ?",
  "options": [
    {
      "text": "Danser à la salle",
      "correct": false
    },
    {
      "text": "Courir au jardin",
      "correct": false
    },
    {
      "text": "Lire sous le figuier",
      "correct": true
    },
    {
      "text": "Prendre le minibus",
      "correct": false
    }
  ],
  "explanation": "« elle va lire sous le figuier »."
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
      "left": "née",
      "right": "Rukiri-Nord"
    },
    {
      "left": "60 ans",
      "right": "âge"
    },
    {
      "left": "Notes du figuier",
      "right": "écrits"
    },
    {
      "left": "ce soir",
      "right": "lecture"
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
  "prompt": "Complétez :\nElle a ___ les Notes du figuier.",
  "answer": "écrit"
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
    "habite",
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
  "word": "écrit",
  "hint": "Le participe après elle a…, pour les notes."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Elle est né à Rukiri-Nord.",
  "correct_sentence": "Elle est née à Rukiri-Nord.",
  "explanation": "Féminin : née (avec e)."
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
      "image_path": "/elearning/mfk-a1-m6/plume.svg",
      "word": "une plume"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/journal.svg",
      "word": "un journal"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/cahier.svg",
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
  "prompt": "Recopiez la fiche en quatre phrases : née, habite, a écrit, va lire."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la fiche, une ligne, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire une petite bio',
    'PO',
    $c$Objectif
Présenter une personne : il/elle est né(e), il/elle a écrit, il/elle habite.

Consigne
Répétez, puis présentez Mado ou une personne inventée.

Support — Modèles d'Aline
Elle est née ici.
Il est né à Rukiri-Nord.
Elle a soixante ans.
Elle habite près du jardin.
Elle a écrit des notes.
Elle parle français.
Il a écrit une page.
Elle va lire ce soir.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Elle est née » s'accorde au féminin.",
  "correct": true,
  "explanation": "Être + née."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est correcte pour un homme ?",
  "options": [
    {
      "text": "Il est née",
      "correct": false
    },
    {
      "text": "Il a né",
      "correct": false
    },
    {
      "text": "Il est né",
      "correct": true
    },
    {
      "text": "Il est nés",
      "correct": false
    }
  ],
  "explanation": "Il est né."
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
      "left": "elle est née",
      "right": "femme"
    },
    {
      "left": "il est né",
      "right": "homme"
    },
    {
      "left": "elle a écrit",
      "right": "avoir + écrit"
    },
    {
      "left": "elle habite",
      "right": "présent"
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
  "prompt": "Complétez :\nIl est ___ à Rukiri-Nord.",
  "answer": "né"
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
    "parle",
    "français",
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
  "word": "habite",
  "hint": "Le verbe du lieu de vie, au présent."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est née à Rukiri-Nord.",
  "correct_sentence": "Il est né à Rukiri-Nord.",
  "explanation": "Masculin : né (sans e)."
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
      "image_path": "/elearning/mfk-a1-m6/naissance.svg",
      "word": "naître"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/plume.svg",
      "word": "une plume"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/portrait.svg",
      "word": "un portrait"
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
  "prompt": "Écrivez six phrases de bio : née/né, âge, habite, a écrit, parle, va."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis la bio de Mado."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Une bio en cinq lignes',
    'PE',
    $c$Objectif
Écrire une mini-biographie.

Consigne
Imitez la bio de Mado, ou inventez un voisin du Seuil.

Support — Bio modèle
Mado Karekezi est née à Rukiri-Nord.
Elle a soixante ans. Elle habite près du jardin.
Elle a écrit les Notes du figuier.
Elle parle français.
Ce soir, elle va lire sous le figuier.
Cahier des histoires
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La bio dit que Mado va lire ce soir.",
  "correct": true,
  "explanation": "Dernière phrase avant le titre du cahier."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel livre (inventé) Mado a-t-elle écrit ?",
  "options": [
    {
      "text": "Les Heures du minibus",
      "correct": false
    },
    {
      "text": "Les Notes du figuier",
      "correct": true
    },
    {
      "text": "Le Cahier de Joël",
      "correct": false
    },
    {
      "text": "La Moto de Rukiri",
      "correct": false
    }
  ],
  "explanation": "Les Notes du figuier — titre inventé MFK."
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
      "left": "est née",
      "right": "passé avec être"
    },
    {
      "left": "a écrit",
      "right": "passé avec avoir"
    },
    {
      "left": "habite",
      "right": "présent"
    },
    {
      "left": "va lire",
      "right": "futur proche"
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
  "prompt": "Complétez :\nMado Karekezi est ___ à Rukiri-Nord.",
  "answer": "née"
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
    "a",
    "soixante",
    "ans",
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
  "word": "notes",
  "hint": "Les petites histoires du figuier, au pluriel."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Mado est née à Rukiri-Nord. Elle a écrite un livre.",
  "correct_sentence": "Mado est née à Rukiri-Nord. Elle a écrit un livre.",
  "explanation": "Avec avoir, écrit reste invariable ici (pas de COD avant le verbe)."
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
      "image_path": "/elearning/mfk-a1-m6/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/plume.svg",
      "word": "une plume"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/cahier.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/figuier.svg",
      "word": "le figuier"
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
  "prompt": "Écrivez cinq lignes : est né(e), âge, habite, a écrit, va…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre bio, calmement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Être né(e), avoir écrit',
    'EL',
    $c$Objectif
Retenir la bio : être né(e), avoir + participe, présent, futur proche.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
elle est née / il est né
j'ai écrit / elle a écrit
elle habite / elle parle
elle va lire
être (né, allé, arrivé) : on accorde
avoir (écrit, lu, appris) : pas d'accord ici
Attention : elle est née (pas elle a née). Il est né (pas il est née).
Personne inventée : Mado Karekezi, pas une célébrité réelle.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « elle a née ».",
  "correct": false,
  "explanation": "Elle est née."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est correcte ?",
  "options": [
    {
      "text": "Elle a née ici",
      "correct": false
    },
    {
      "text": "Elle est né ici",
      "correct": false
    },
    {
      "text": "Elle est née ici",
      "correct": true
    },
    {
      "text": "Elle née ici",
      "correct": false
    }
  ],
  "explanation": "Elle est née ici."
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
      "left": "être",
      "right": "né / née"
    },
    {
      "left": "avoir",
      "right": "écrit / lu"
    },
    {
      "left": "présent",
      "right": "habite"
    },
    {
      "left": "futur proche",
      "right": "va lire"
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
  "prompt": "Complétez :\nIls sont ___ à Rukiri-Nord. (deux hommes)",
  "answer": "nés"
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
    "est",
    "née",
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
  "word": "nés",
  "hint": "Le pluriel masculin, avec ils sont…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ils sont né à Rukiri-Nord.",
  "correct_sentence": "Ils sont nés à Rukiri-Nord.",
  "explanation": "Pluriel : nés."
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
      "image_path": "/elearning/mfk-a1-m6/naissance.svg",
      "word": "naître"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/plume.svg",
      "word": "une plume"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/ecrire.svg",
      "word": "écrire"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/livre.svg",
      "word": "un livre"
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
  "prompt": "Recopiez la fiche. Écrivez une bio inventée en quatre phrases."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : elle est née, il est né, elle a écrit, elle habite, elle va lire."
}$j$::jsonb,
    9
  );

  -- ===== Portrait d'un jour =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Portrait d''un jour'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Portrait d''un jour', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Sami, hier soir',
    'CO',
    $c$Objectif
Comprendre un portrait : il est, il a, et un événement (il est arrivé).

Consigne
Comment est Sami ? Qu'est-ce qu'il a ? Que s'est-il passé hier ?

Support — Photo épinglée au cahier
Léa : Hier, Sami est arrivé à la salle. Il est grand.
Rose : Il a les cheveux courts. Il a un sourire.
Patrick : Il a un tambour. Il n'a pas de lunettes.
Aline : Il est jeune. Il est de Rukiri-Nord.
Hawa : Après, il a joué. Tout le monde a écouté.
Sami : Voilà mon portrait d'un jour.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Sami a des lunettes.",
  "correct": false,
  "explanation": "Patrick : « Il n'a pas de lunettes. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment Sami est-il arrivé, d'après Léa ?",
  "options": [
    {
      "text": "Il est petit",
      "correct": false
    },
    {
      "text": "Il est arrivé à la salle",
      "correct": true
    },
    {
      "text": "Il est né à midi",
      "correct": false
    },
    {
      "text": "Il a les cheveux longs",
      "correct": false
    }
  ],
  "explanation": "Léa : « Sami est arrivé à la salle. »"
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
      "left": "grand",
      "right": "taille"
    },
    {
      "left": "cheveux courts",
      "right": "tête"
    },
    {
      "left": "tambour",
      "right": "objet"
    },
    {
      "left": "arrivé",
      "right": "hier"
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
  "prompt": "Complétez :\nIl ___ les cheveux courts.",
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
    "Il",
    "est",
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
  "word": "arrivé",
  "hint": "Le participe avec être, hier à la salle."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Sami est arrivée à la salle.",
  "correct_sentence": "Sami est arrivé à la salle.",
  "explanation": "Sami = il : arrivé (sans e)."
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
      "image_path": "/elearning/mfk-a1-m6/portrait.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/grand.svg",
      "word": "grand"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/cheveux.svg",
      "word": "les cheveux"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/tambour.svg",
      "word": "un tambour"
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
  "prompt": "Notez : un verbe d'arrivée, deux « il est », deux « il a »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Hier, il est arrivé. Il est grand. Il a les cheveux courts. Il a un tambour."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Carte portrait',
    'CE',
    $c$Objectif
Lire un portrait écrit pour un jour précis.

Consigne
Lisez la carte de Léa.

Support — Carte « Un jour »
Hier soir — Salle des Herbes
Sami Niyonteze
Il est arrivé à dix-neuf heures.
Il est grand. Il est jeune.
Il a les cheveux courts. Il a un sourire.
Il a un tambour. Il n'a pas de lunettes.
Il a joué. Nous avons écouté.
Portrait d'un jour — Léa
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Sami est arrivé le matin.",
  "correct": false,
  "explanation": "Carte : hier soir, 19 h."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a écrit la carte ?",
  "options": [
    {
      "text": "Sami",
      "correct": false
    },
    {
      "text": "Rose",
      "correct": false
    },
    {
      "text": "Léa",
      "correct": true
    },
    {
      "text": "Mado",
      "correct": false
    }
  ],
  "explanation": "Signature : Léa."
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
      "left": "est arrivé",
      "right": "être + participe"
    },
    {
      "left": "est grand",
      "right": "description"
    },
    {
      "left": "a les cheveux",
      "right": "avoir"
    },
    {
      "left": "a joué",
      "right": "avoir + participe"
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
  "prompt": "Complétez :\nIl n'a pas ___ lunettes.",
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
    "Il",
    "a",
    "un",
    "sourire",
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
  "word": "sourire",
  "hint": "Sami l'a, sur la photo du cahier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il a les cheveu courts.",
  "correct_sentence": "Il a les cheveux courts.",
  "explanation": "Cheveux au pluriel."
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
      "image_path": "/elearning/mfk-a1-m6/photo.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/lunettes.svg",
      "word": "les lunettes"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/cheveux.svg",
      "word": "les cheveux"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/jeune.svg",
      "word": "jeune"
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
  "prompt": "Recopiez la carte. Changez le prénom et deux détails."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la carte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Décrire une personne',
    'PO',
    $c$Objectif
Décrire : il/elle est, il/elle a, et un passé simple à l'oral (est arrivé(e)).

Consigne
Répétez, puis décrivez Sami ou un camarade.

Support — Modèles de Rose
Il est grand.
Elle est petite.
Il est jeune.
Il a les cheveux courts.
Elle a les cheveux longs.
Il a des lunettes.
Elle n'a pas de lunettes.
Il est arrivé hier.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Elle est petite » s'accorde au féminin.",
  "correct": true,
  "explanation": "Petite, avec e."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase décrit un objet sur la personne ?",
  "options": [
    {
      "text": "Il est grand",
      "correct": false
    },
    {
      "text": "Il est jeune",
      "correct": false
    },
    {
      "text": "Il a des lunettes",
      "correct": true
    },
    {
      "text": "Il est arrivé",
      "correct": false
    }
  ],
  "explanation": "Avoir + lunettes."
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
      "left": "il est",
      "right": "adjectif"
    },
    {
      "left": "il a",
      "right": "cheveux / lunettes / tambour"
    },
    {
      "left": "est arrivé",
      "right": "un moment"
    },
    {
      "left": "n'a pas de",
      "right": "absence"
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
  "prompt": "Complétez :\nElle ___ petite.",
  "answer": "est"
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
    "est",
    "arrivée",
    "hier",
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
  "word": "petite",
  "hint": "Féminin de petit."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Elle est arrivé hier.",
  "correct_sentence": "Elle est arrivée hier.",
  "explanation": "Féminin avec être : arrivée."
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
      "image_path": "/elearning/mfk-a1-m6/grand.svg",
      "word": "grand"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/cheveux.svg",
      "word": "les cheveux"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/lunettes.svg",
      "word": "les lunettes"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/portrait.svg",
      "word": "un portrait"
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
  "prompt": "Écrivez six phrases : deux est, deux a, une n'a pas, une est arrivé(e)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis un portrait d'un jour."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Un portrait d''un jour',
    'PE',
    $c$Objectif
Écrire un portrait daté.

Consigne
Imitez le portrait de Léa. Changez la personne.

Support — Portrait
Hier soir, Rose est arrivée à la salle.
Elle est jeune. Elle a les cheveux longs.
Elle n'a pas de tambour. Elle a un sourire.
Elle a dansé. Nous avons regardé.
Léa
Portrait d'un jour
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose a un tambour.",
  "correct": false,
  "explanation": "« Elle n'a pas de tambour. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que s'est-il passé après l'arrivée de Rose ?",
  "options": [
    {
      "text": "Elle a couru",
      "correct": false
    },
    {
      "text": "Elle a dansé",
      "correct": true
    },
    {
      "text": "Elle a écrit un livre",
      "correct": false
    },
    {
      "text": "Elle est née",
      "correct": false
    }
  ],
  "explanation": "« Elle a dansé. »"
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
      "left": "est arrivée",
      "right": "Rose"
    },
    {
      "left": "cheveux longs",
      "right": "description"
    },
    {
      "left": "a dansé",
      "right": "action"
    },
    {
      "left": "nous avons regardé",
      "right": "le groupe"
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
  "prompt": "Complétez :\nRose est ___ à la salle.",
  "answer": "arrivée"
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
    "a",
    "dansé",
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
  "word": "longs",
  "hint": "Les cheveux de Rose, pas courts."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Rose est arrivé à la salle.",
  "correct_sentence": "Rose est arrivée à la salle.",
  "explanation": "Rose = elle : arrivée."
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
      "image_path": "/elearning/mfk-a1-m6/danse.svg",
      "word": "la danse"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/photo.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/portrait.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/cheveux.svg",
      "word": "les cheveux"
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
  "prompt": "Écrivez un portrait daté : est arrivé(e), est, a, n'a pas, a + verbe."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre portrait, une phrase, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Est, a, est arrivé(e)',
    'EL',
    $c$Objectif
Retenir description et accord avec être.

Consigne
Apprenez la fiche.

Support — Fiche de Léa
il est / elle est + adjectif (grand, grande, jeune)
il a / elle a + les cheveux / des lunettes / un tambour
il n'a pas de + nom
il est arrivé / elle est arrivée
ils sont arrivés / elles sont arrivées
avoir : il a joué, elle a dansé (pas d'accord ici)
Attention : arrivé / arrivée / arrivés / arrivées.
On ne dit pas « elle est arrivé ».
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « elle est arrivé ».",
  "correct": false,
  "explanation": "Elle est arrivée."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est correcte ?",
  "options": [
    {
      "text": "Elles sont arrivé",
      "correct": false
    },
    {
      "text": "Elles sont arrivée",
      "correct": false
    },
    {
      "text": "Elles sont arrivées",
      "correct": true
    },
    {
      "text": "Elles ont arrivées",
      "correct": false
    }
  ],
  "explanation": "Elles sont arrivées."
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
      "left": "il est arrivé",
      "right": "un homme"
    },
    {
      "left": "elle est arrivée",
      "right": "une femme"
    },
    {
      "left": "ils sont arrivés",
      "right": "plusieurs, dont un homme"
    },
    {
      "left": "elles sont arrivées",
      "right": "plusieurs femmes"
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
  "prompt": "Complétez :\nElles sont ___.",
  "answer": "arrivées"
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
    "n'a",
    "pas",
    "de",
    "lunettes",
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
  "word": "arrivée",
  "hint": "Une femme, hier, à la salle : elle est…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ils sont arrivé à dix-neuf heures.",
  "correct_sentence": "Ils sont arrivés à dix-neuf heures.",
  "explanation": "Pluriel : arrivés."
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
      "image_path": "/elearning/mfk-a1-m6/arriver.svg",
      "word": "arriver"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/grand.svg",
      "word": "grand"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/lunettes.svg",
      "word": "les lunettes"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/portrait.svg",
      "word": "un portrait"
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
  "prompt": "Recopiez la fiche. Écrivez quatre accords : il / elle / ils / elles."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : il est arrivé, elle est arrivée, ils sont arrivés, elles sont arrivées."
}$j$::jsonb,
    9
  );

  -- ===== Un choix de vie =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un choix de vie'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un choix de vie', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Yvette a choisi la colline',
    'CO',
    $c$Objectif
Comprendre un choix : avant + passé composé, maintenant + présent.

Consigne
Qu'a fait Yvette avant ? Que fait-elle maintenant ?

Support — Infirmerie des Herbes, thé à la main
Yvette : Avant, j'ai travaillé loin. J'ai habité en ville.
Léa : Et maintenant ?
Yvette : Maintenant, je suis ici. Je travaille à l'Infirmerie des Herbes.
Joël : Moi, avant, j'ai conduit un grand bus. Maintenant, je suis à la moto.
Aline : J'ai choisi l'accueil. Maintenant, j'ouvre le Seuil.
Patrick : On a tous choisi un chemin.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Yvette travaille encore en ville.",
  "correct": false,
  "explanation": "Maintenant, elle est ici, à l'infirmerie."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faisait Joël avant ?",
  "options": [
    {
      "text": "Il dansait",
      "correct": false
    },
    {
      "text": "Il a conduit un grand bus",
      "correct": true
    },
    {
      "text": "Il écrivait des notes",
      "correct": false
    },
    {
      "text": "Il était guide",
      "correct": false
    }
  ],
  "explanation": "Joël : « j'ai conduit un grand bus. »"
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
      "left": "Yvette avant",
      "right": "ville, loin"
    },
    {
      "left": "Yvette maintenant",
      "right": "infirmerie"
    },
    {
      "left": "Joël avant",
      "right": "grand bus"
    },
    {
      "left": "Aline maintenant",
      "right": "accueil"
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
  "prompt": "Complétez :\nAvant, j'___ travaillé loin.",
  "answer": "ai"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Maintenant",
    "je",
    "suis",
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
  "word": "choix",
  "hint": "Un chemin de vie : on a… un."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avant j'ai travaillé loin. Maintenant j'ai suis ici.",
  "correct_sentence": "Avant j'ai travaillé loin. Maintenant je suis ici.",
  "explanation": "Maintenant : présent (je suis), pas j'ai suis."
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
      "image_path": "/elearning/mfk-a1-m6/choix.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/avant.svg",
      "word": "avant"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/maintenant.svg",
      "word": "maintenant"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/aller.svg",
      "word": "aller"
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
  "prompt": "Notez deux « avant, j'ai… » et deux « maintenant, je… »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Avant, j'ai travaillé loin. Maintenant, je suis ici. J'ai choisi ce chemin."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Deux colonnes : avant / maintenant',
    'CE',
    $c$Objectif
Lire un tableau de choix de vie.

Consigne
Lisez le tableau du cahier.

Support — Tableau
Un choix de vie — Rukiri-Nord
Yvette Mukeshimana — Avant : elle a travaillé loin. Maintenant : infirmerie des Herbes.
Joël Mugisha — Avant : il a conduit un bus. Maintenant : moto Figuier.
Aline Uwase — Avant : elle a étudié en ville. Maintenant : accueil du Seuil.
Léa Niyonzima — Avant : elle a habité loin. Maintenant : elle apprend ici.
Rien n'est obligatoire. C'est un choix.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa habite encore loin.",
  "correct": false,
  "explanation": "Maintenant, elle apprend ici."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qu'a fait Aline avant ?",
  "options": [
    {
      "text": "Elle a dansé",
      "correct": false
    },
    {
      "text": "Elle a étudié en ville",
      "correct": true
    },
    {
      "text": "Elle a conduit un bus",
      "correct": false
    },
    {
      "text": "Elle a écrit les Notes",
      "correct": false
    }
  ],
  "explanation": "Aline : elle a étudié en ville."
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
      "left": "avant",
      "right": "passé composé"
    },
    {
      "left": "maintenant",
      "right": "présent"
    },
    {
      "left": "infirmerie",
      "right": "Yvette"
    },
    {
      "left": "accueil",
      "right": "Aline"
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
  "prompt": "Complétez :\nMaintenant, elle ___ ici.",
  "answer": "apprend"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'ai",
    "choisi",
    "ce",
    "chemin",
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
  "word": "choisi",
  "hint": "Le participe après j'ai, pour un chemin de vie."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avant elle a étudié. Maintenant elle a étudie à l'accueil.",
  "correct_sentence": "Avant elle a étudié. Maintenant elle étudie à l'accueil.",
  "explanation": "Maintenant : présent (étudie), pas a étudie."
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
      "image_path": "/elearning/mfk-a1-m6/avant.svg",
      "word": "avant"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/maintenant.svg",
      "word": "maintenant"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/choix.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/cahier.svg",
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
  "prompt": "Recopiez une ligne. Ajoutez la vôtre : avant / maintenant."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le tableau, avant d'abord, puis maintenant."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire avant et maintenant',
    'PO',
    $c$Objectif
Opposer un passé et un présent : avant j'ai…, maintenant je…

Consigne
Répétez, puis parlez d'un choix (vrai ou inventé).

Support — Modèles d'Yvette
Avant, j'ai travaillé loin.
Avant, j'ai habité en ville.
Maintenant, je suis ici.
Maintenant, je travaille à l'infirmerie.
J'ai choisi la colline.
Il a choisi la moto.
Elle a choisi l'accueil.
On a choisi ce Seuil.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« J'ai choisi » est au passé composé.",
  "correct": true,
  "explanation": "Avoir + choisi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est au présent ?",
  "options": [
    {
      "text": "J'ai travaillé loin",
      "correct": false
    },
    {
      "text": "J'ai choisi la colline",
      "correct": false
    },
    {
      "text": "Maintenant je suis ici",
      "correct": true
    },
    {
      "text": "Avant j'ai habité en ville",
      "correct": false
    }
  ],
  "explanation": "Je suis = présent."
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
      "left": "avant",
      "right": "j'ai…"
    },
    {
      "left": "maintenant",
      "right": "je suis / je travaille"
    },
    {
      "left": "j'ai choisi",
      "right": "décision"
    },
    {
      "left": "ici",
      "right": "Rukiri-Nord"
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
  "prompt": "Complétez :\nJ'ai ___ la colline.",
  "answer": "choisi"
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
    "a",
    "choisi",
    "l'accueil",
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
  "word": "avant",
  "hint": "Le mot du passé, face à maintenant."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai choisi la colline. Maintenant j'ai travailler ici.",
  "correct_sentence": "J'ai choisi la colline. Maintenant je travaille ici.",
  "explanation": "Maintenant : je travaille (présent)."
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
      "image_path": "/elearning/mfk-a1-m6/choix.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/avant.svg",
      "word": "avant"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/maintenant.svg",
      "word": "maintenant"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/arriver.svg",
      "word": "arriver"
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
  "prompt": "Écrivez six phrases : deux avant, deux maintenant, deux j'ai choisi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre choix."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon choix en six lignes',
    'PE',
    $c$Objectif
Écrire un petit texte avant / maintenant.

Consigne
Imitez le mot d'Yvette.

Support — Mot d'Yvette
Bonjour,
Avant, j'ai travaillé loin. J'ai habité en ville.
Maintenant, je suis à Rukiri-Nord.
Je travaille à l'Infirmerie des Herbes.
J'ai choisi ce chemin.
Yvette Mukeshimana
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Yvette habite encore en ville.",
  "correct": false,
  "explanation": "Maintenant, elle est à Rukiri-Nord."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Yvette travaille-t-elle maintenant ?",
  "options": [
    {
      "text": "À l'accueil",
      "correct": false
    },
    {
      "text": "À l'Infirmerie des Herbes",
      "correct": true
    },
    {
      "text": "Au minibus",
      "correct": false
    },
    {
      "text": "À la salle",
      "correct": false
    }
  ],
  "explanation": "« Je travaille à l'Infirmerie des Herbes. »"
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
      "left": "avant",
      "right": "loin, ville"
    },
    {
      "left": "maintenant",
      "right": "Rukiri-Nord"
    },
    {
      "left": "infirmerie",
      "right": "travail"
    },
    {
      "left": "chemin",
      "right": "choix"
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
  "prompt": "Complétez :\nMaintenant, je ___ à Rukiri-Nord.",
  "answer": "suis"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'ai",
    "habité",
    "en",
    "ville",
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
  "word": "ville",
  "hint": "Le lieu d'avant, opposé à la colline."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai habité en ville. Maintenant je suis allé à Rukiri-Nord.",
  "correct_sentence": "J'ai habité en ville. Maintenant je suis à Rukiri-Nord.",
  "explanation": "Yvette = elle, et c'est un état présent : je suis (pas je suis allé)."
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
      "image_path": "/elearning/mfk-a1-m6/choix.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/maintenant.svg",
      "word": "maintenant"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/avant.svg",
      "word": "avant"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/journal.svg",
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
  "prompt": "Écrivez six lignes : bonjour, deux avant, deux maintenant, j'ai choisi."
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
    'EL — Avant j''ai, maintenant je',
    'EL',
    $c$Objectif
Retenir le contraste passé composé / présent.

Consigne
Apprenez la fiche.

Support — Fiche d'Yvette
Avant + passé composé : j'ai travaillé, j'ai habité, j'ai choisi
Maintenant + présent : je suis, je travaille, j'habite
j'ai choisi / tu as choisi / elle a choisi
Attention : choisi (pas « choisé »).
On ne mélange pas : « maintenant j'ai suis ».
Un choix de vie = un chemin, pas une célébrité.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « j'ai choisé ».",
  "correct": false,
  "explanation": "J'ai choisi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est correcte ?",
  "options": [
    {
      "text": "Maintenant j'ai suis ici",
      "correct": false
    },
    {
      "text": "Maintenant je suis ici",
      "correct": true
    },
    {
      "text": "Maintenant je suis allé ici",
      "correct": false
    },
    {
      "text": "Maintenant j'être ici",
      "correct": false
    }
  ],
  "explanation": "Maintenant je suis ici."
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
      "left": "avant",
      "right": "passé composé"
    },
    {
      "left": "maintenant",
      "right": "présent"
    },
    {
      "left": "choisi",
      "right": "participe"
    },
    {
      "left": "chemin",
      "right": "vie"
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
  "prompt": "Complétez :\nTu as ___ l'accueil ?",
  "answer": "choisi"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Maintenant",
    "je",
    "travaille",
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
  "word": "choisi",
  "hint": "Le participe après j'ai, pour un chemin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Elle a choisi la colline. Avant elle habite loin.",
  "correct_sentence": "Elle a choisi la colline. Avant elle a habité loin.",
  "explanation": "Avant : passé composé (a habité)."
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
      "image_path": "/elearning/mfk-a1-m6/choix.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/avant.svg",
      "word": "avant"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/maintenant.svg",
      "word": "maintenant"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/aller.svg",
      "word": "aller"
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : deux avant, deux maintenant."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : avant j'ai travaillé, maintenant je travaille, j'ai choisi ce chemin."
}$j$::jsonb,
    9
  );

  -- ===== S'informer pour avancer =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'S''informer pour avancer'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'S''informer pour avancer', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Conseils autour du cahier',
    'CO',
    $c$Objectif
Comprendre des conseils : écoutez, lisez, il faut, on peut.

Consigne
Quels conseils entend-on ? Pour avancer comment ?

Support — Feuille du Seuil, lue à voix haute
Aline : Écoutez Radio Figuier. Lisez la Feuille du Seuil.
Patrick : Demandez le chemin, si vous ne savez pas.
Mado : Il faut lire un peu, tous les jours. On peut écrire une ligne.
Léa : Posez une question. Ce n'est pas grave.
Yvette : Allez à l'infirmerie si vous êtes fatigué.
Rose : Venez à la salle. Mais d'abord, informez-vous.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline conseille d'écouter la radio.",
  "correct": true,
  "explanation": "Aline : « Écoutez Radio Figuier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que dit Mado ?",
  "options": [
    {
      "text": "Il faut danser",
      "correct": false
    },
    {
      "text": "Il faut lire un peu",
      "correct": true
    },
    {
      "text": "Il faut prendre la moto",
      "correct": false
    },
    {
      "text": "Il faut partir",
      "correct": false
    }
  ],
  "explanation": "Mado : « Il faut lire un peu, tous les jours. »"
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
      "left": "écoutez",
      "right": "radio"
    },
    {
      "left": "lisez",
      "right": "Feuille du Seuil"
    },
    {
      "left": "il faut",
      "right": "lire"
    },
    {
      "left": "on peut",
      "right": "écrire"
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
  "prompt": "Complétez :\nIl ___ lire un peu.",
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
    "Posez",
    "une",
    "question",
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
  "hint": "Il… + infinitif : un conseil fort."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut tu lis tous les jours.",
  "correct_sentence": "Il faut lire tous les jours.",
  "explanation": "Il faut + infinitif (lire)."
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
      "image_path": "/elearning/mfk-a1-m6/conseil.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/journal.svg",
      "word": "un journal"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/question.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/ecouter.svg",
      "word": "écouter"
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
  "prompt": "Listez quatre conseils entendus (impératif ou il faut / on peut)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Écoutez la radio. Lisez la feuille. Il faut lire un peu. On peut écrire une ligne."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — La Feuille du Seuil',
    'CE',
    $c$Objectif
Lire une petite feuille de conseils.

Consigne
Lisez l'affiche.

Support — Affiche
S'informer pour avancer — Rukiri-Nord
1. Écoutez Radio Figuier (16 h).
2. Lisez la Feuille du Seuil (sous le figuier).
3. Demandez à Aline, à l'accueil.
4. Il faut noter une phrase dans le cahier.
5. On peut poser une question. Ce n'est pas grave.
6. Allez au jardin pour marcher, ou à la salle pour danser.
Inventée pour le Seuil. Pas un journal réel.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On doit écouter la radio à minuit.",
  "correct": false,
  "explanation": "Radio Figuier à 16 h."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À qui demander, d'après l'affiche ?",
  "options": [
    {
      "text": "À Mado seulement",
      "correct": false
    },
    {
      "text": "À Aline, à l'accueil",
      "correct": true
    },
    {
      "text": "Au minibus",
      "correct": false
    },
    {
      "text": "À Kévin",
      "correct": false
    }
  ],
  "explanation": "« Demandez à Aline, à l'accueil. »"
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
      "left": "écoutez",
      "right": "radio"
    },
    {
      "left": "lisez",
      "right": "feuille"
    },
    {
      "left": "demandez",
      "right": "Aline"
    },
    {
      "left": "allez",
      "right": "jardin ou salle"
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
  "prompt": "Complétez :\nOn ___ poser une question.",
  "answer": "peut"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Demandez",
    "à",
    "Aline",
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
  "word": "conseil",
  "hint": "Un mot pour aider à avancer."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Écoute la radio.",
  "correct_sentence": "Écoutez la radio.",
  "explanation": "Au groupe : écoutez (pas écoute)."
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
      "image_path": "/elearning/mfk-a1-m6/journal.svg",
      "word": "un journal"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/conseil.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/question.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/figuier.svg",
      "word": "le figuier"
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
  "prompt": "Recopiez trois conseils. Ajoutez le vôtre avec il faut ou on peut."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'affiche, un numéro, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Donner un conseil',
    'PO',
    $c$Objectif
Donner un conseil : impératif, il faut, on peut.

Consigne
Répétez, puis conseillez un camarade.

Support — Modèles d'Aline
Écoutez.
Lisez.
Demandez.
Posez une question.
Allez à l'accueil.
Il faut lire.
On peut écrire.
N'oubliez pas le cahier.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Écoutez » est un impératif de politesse au groupe.",
  "correct": true,
  "explanation": "Vous : écoutez."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase utilise « il faut » ?",
  "options": [
    {
      "text": "Écoutez",
      "correct": false
    },
    {
      "text": "On peut écrire",
      "correct": false
    },
    {
      "text": "Il faut lire",
      "correct": true
    },
    {
      "text": "Allez à l'accueil",
      "correct": false
    }
  ],
  "explanation": "Il faut + infinitif."
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
      "left": "écoutez",
      "right": "impératif"
    },
    {
      "left": "il faut",
      "right": "obligation douce"
    },
    {
      "left": "on peut",
      "right": "possibilité"
    },
    {
      "left": "n'oubliez pas",
      "right": "négation"
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
  "prompt": "Complétez :\n___ une question.",
  "answer": "Posez"
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
    "lire",
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
  "word": "lisez",
  "hint": "L'impératif de lire, pour vous / le groupe."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut lisez le cahier.",
  "correct_sentence": "Il faut lire le cahier.",
  "explanation": "Il faut + infinitif, pas l'impératif."
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
      "image_path": "/elearning/mfk-a1-m6/conseil.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/lire.svg",
      "word": "lire"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/ecouter.svg",
      "word": "écouter"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/question.svg",
      "word": "une question"
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
  "prompt": "Écrivez six conseils : deux impératifs, deux il faut, deux on peut."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux conseils personnels."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Un petit mot de conseil',
    'PE',
    $c$Objectif
Écrire une courte liste de conseils.

Consigne
Imitez le mot de Mado.

Support — Mot de Mado
Amies, amis,
Écoutez un peu chaque jour.
Lisez une ligne des Notes du figuier.
Il faut poser une question.
On peut écrire dans le cahier.
Avancez, à votre manière.
Mado Karekezi
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado interdit d'écrire dans le cahier.",
  "correct": false,
  "explanation": "« On peut écrire dans le cahier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle formule de clôture Mado utilise-t-elle ?",
  "options": [
    {
      "text": "Au revoir la ville",
      "correct": false
    },
    {
      "text": "Avancez, à votre manière",
      "correct": true
    },
    {
      "text": "Prenez le bus",
      "correct": false
    },
    {
      "text": "Silence",
      "correct": false
    }
  ],
  "explanation": "« Avancez, à votre manière. »"
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
      "left": "écoutez",
      "right": "chaque jour"
    },
    {
      "left": "lisez",
      "right": "une ligne"
    },
    {
      "left": "il faut",
      "right": "poser une question"
    },
    {
      "left": "on peut",
      "right": "écrire"
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
  "prompt": "Complétez :\nAvancez, à votre ___.",
  "answer": "manière"
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
    "peut",
    "écrire",
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
  "word": "avancez",
  "hint": "L'impératif de la dernière ligne, pour le groupe."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut posez une question.",
  "correct_sentence": "Il faut poser une question.",
  "explanation": "Il faut + infinitif : poser."
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
      "image_path": "/elearning/mfk-a1-m6/conseil.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/cahier.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/plume.svg",
      "word": "une plume"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/journal.svg",
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
  "prompt": "Écrivez un mot : deux impératifs, il faut, on peut, une phrase de clôture."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot, comme Mado."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Impératif, il faut, on peut',
    'EL',
    $c$Objectif
Retenir les formes du conseil.

Consigne
Apprenez la fiche, puis donnez trois conseils.

Support — Fiche d'Aline
Impératif (vous / groupe) : écoutez, lisez, demandez, allez, posez, venez
il faut + infinitif
on peut + infinitif
n'oubliez pas
Attention : il faut lire (pas il faut lisez).
écoute (tu) / écoutez (vous).
S'informer = écouter, lire, demander.
Pour avancer : un peu, tous les jours.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « il faut lisez ».",
  "correct": false,
  "explanation": "Il faut lire."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme s'adresse au groupe ?",
  "options": [
    {
      "text": "écoute",
      "correct": false
    },
    {
      "text": "lis",
      "correct": false
    },
    {
      "text": "écoutez",
      "correct": true
    },
    {
      "text": "je écoute",
      "correct": false
    }
  ],
  "explanation": "Écoutez."
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
      "left": "impératif",
      "right": "écoutez"
    },
    {
      "left": "il faut",
      "right": "lire"
    },
    {
      "left": "on peut",
      "right": "écrire"
    },
    {
      "left": "s'informer",
      "right": "radio, feuille, questions"
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
  "prompt": "Complétez :\nVous, ___ à l'accueil.",
  "answer": "allez"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "N'oubliez",
    "pas",
    "le",
    "cahier",
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
  "word": "demandez",
  "hint": "L'impératif pour poser une question à Aline."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On peut écrivez une ligne.",
  "correct_sentence": "On peut écrire une ligne.",
  "explanation": "On peut + infinitif : écrire."
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
      "image_path": "/elearning/mfk-a1-m6/conseil.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/question.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/ecouter.svg",
      "word": "écouter"
    },
    {
      "image_path": "/elearning/mfk-a1-m6/lire.svg",
      "word": "lire"
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
  "prompt": "Recopiez la fiche. Écrivez trois conseils : impératif, il faut, on peut."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : écoutez, lisez, demandez, il faut lire, on peut écrire, n'oubliez pas."
}$j$::jsonb,
    9
  );

END;
$$;
