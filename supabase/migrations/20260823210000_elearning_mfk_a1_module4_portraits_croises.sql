/*
  Seed eLearning MFK — Module 4 A1 « Portraits croisés »

  Même micro-monde que le Module 3 : cour « Le Seuil des Sources », Rukiri-Nord.
  Album de portraits inventé sous le figuier.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a1-m4/
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
  v_module_title text := 'A1 — Portraits croisés';
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
      'Seed A1 Module 4 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed Module 4 : enseignant % (%)', v_teacher_email, v_teacher_id;

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
      'Grande étape 4 : parler de sa famille, se décrire, dire ce qu''on aime, se raconter, parler du temps libre et du corps — album de portraits sous le figuier du Seuil des Sources (Rukiri-Nord).',
      'A1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape 4 : parler de sa famille, se décrire, dire ce qu''on aime, se raconter, parler du temps libre et du corps — album de portraits sous le figuier du Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'A1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== En famille =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'En famille'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'En famille', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — L''album sous le figuier',
    'CO',
    $c$Objectif
Comprendre un échange sur la famille : c'est ma / mon, j'ai un / une.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui est sur les photos ? Quels mots de famille entendez-vous ?

Support — Cour du Seuil, album de tissu crème
Aline : Voici mon album. C'est ma mère, Claire Mukamana.
Léa : Elle est belle. Et lui ?
Aline : C'est mon frère, Éric. J'ai aussi une nièce : Nina.
Léa : Moi, j'ai une sœur. Elle s'appelle Mireille.
Hawa : Et moi, c'est ma tante, Fatou Diallo. Elle habite près du pont.
Aline : On épingle tout sur le figuier. C'est notre famille du Seuil.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Claire Mukamana est la mère d'Aline.",
  "correct": true,
  "explanation": "Aline dit : « C'est ma mère, Claire Mukamana. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment s'appelle la sœur de Léa ?",
  "options": [
    {
      "text": "Nina",
      "correct": false
    },
    {
      "text": "Fatou",
      "correct": false
    },
    {
      "text": "Mireille",
      "correct": true
    },
    {
      "text": "Claire",
      "correct": false
    }
  ],
  "explanation": "Léa : « Elle s'appelle Mireille. »"
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
      "left": "ma mère",
      "right": "Claire"
    },
    {
      "left": "mon frère",
      "right": "Éric"
    },
    {
      "left": "ma sœur",
      "right": "Mireille"
    },
    {
      "left": "ma tante",
      "right": "Fatou"
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
  "prompt": "Complétez :\nC'est ___ mère.",
  "answer": "ma"
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
    "une",
    "sœur",
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
  "word": "mère",
  "hint": "Aline la montre en premier dans l'album."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est mon mère.",
  "correct_sentence": "C'est ma mère.",
  "explanation": "Mère est féminin : ma mère."
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
      "image_path": "/elearning/mfk-a1-m4/mere.svg",
      "word": "la mère"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/frere.svg",
      "word": "le frère"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/soeur.svg",
      "word": "la sœur"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/tante.svg",
      "word": "la tante"
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
  "prompt": "Notez quatre personnes de l'album et leur lien (mère, frère, sœur, tante)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Voici mon album. C'est ma mère. C'est mon frère. J'ai une sœur. C'est ma tante."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Les étiquettes de l''album',
    'CE',
    $c$Objectif
Lire des légendes de photos de famille : ma / mon / mes, c'est, j'ai.

Consigne
Lisez les étiquettes épinglées sur le tissu, puis répondez.

Support — Étiquettes (encre brune)
1. Aline — C'est ma mère, Claire. J'ai un frère, Éric. J'ai une nièce, Nina.
2. Léa — C'est ma sœur, Mireille. Mes parents habitent loin.
3. Hawa — C'est ma tante, Fatou. Je n'ai pas de frère.
4. Marc — C'est mon fils, Kévin. Il a huit ans.
Album du Seuil — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa a un frère.",
  "correct": false,
  "explanation": "L'étiquette : « Je n'ai pas de frère. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui est Kévin ?",
  "options": [
    {
      "text": "Le frère d'Aline",
      "correct": false
    },
    {
      "text": "Le fils de Marc",
      "correct": true
    },
    {
      "text": "L'oncle de Léa",
      "correct": false
    },
    {
      "text": "Le père d'Hawa",
      "correct": false
    }
  ],
  "explanation": "Marc : « C'est mon fils, Kévin. »"
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
      "left": "Aline",
      "right": "un frère et une nièce"
    },
    {
      "left": "Léa",
      "right": "une sœur"
    },
    {
      "left": "Hawa",
      "right": "une tante"
    },
    {
      "left": "Marc",
      "right": "un fils"
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
  "prompt": "Complétez :\nC'est ___ fils.",
  "answer": "mon"
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
    "un",
    "frère",
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
  "word": "sœur",
  "hint": "Léa en a une, elle s'appelle Mireille."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai un sœur.",
  "correct_sentence": "J'ai une sœur.",
  "explanation": "Sœur est féminin : une sœur."
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
      "image_path": "/elearning/mfk-a1-m4/famille.svg",
      "word": "la famille"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/enfant.svg",
      "word": "un enfant"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/pere.svg",
      "word": "le père"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/oncle.svg",
      "word": "l'oncle"
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
  "prompt": "Recopiez les quatre étiquettes. Ajoutez une phrase : « C'est mon / ma… »"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les quatre étiquettes à voix haute, lentement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Présenter les siens',
    'PO',
    $c$Objectif
Présenter sa famille avec c'est ma / mon et j'ai.

Consigne
Répétez les modèles, puis changez les prénoms.

Support — Modèles d'Aline
C'est ma mère.
C'est mon père.
C'est mon frère.
C'est ma sœur.
C'est ma tante.
C'est mon oncle.
J'ai un enfant.
Voici ma famille.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Voici ma famille » sert à montrer tout le groupe.",
  "correct": true,
  "explanation": "Voici = présentation."
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
      "text": "C'est mon sœur",
      "correct": false
    },
    {
      "text": "C'est ma sœur",
      "correct": true
    },
    {
      "text": "C'est mes sœur",
      "correct": false
    },
    {
      "text": "C'est le sœur",
      "correct": false
    }
  ],
  "explanation": "Sœur → ma sœur."
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
      "left": "ma",
      "right": "mère, sœur, tante"
    },
    {
      "left": "mon",
      "right": "père, frère, oncle"
    },
    {
      "left": "mes",
      "right": "parents, frères"
    },
    {
      "left": "j'ai",
      "right": "un / une + personne"
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
  "prompt": "Complétez :\nC'est ___ père.",
  "answer": "mon"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Voici",
    "ma",
    "famille",
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
  "word": "famille",
  "hint": "Le mot pour tout le groupe, à la fin des modèles."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est mes père.",
  "correct_sentence": "C'est mon père.",
  "explanation": "Un seul père : mon père. Mes = plusieurs."
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
      "image_path": "/elearning/mfk-a1-m4/mere.svg",
      "word": "la mère"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/pere.svg",
      "word": "le père"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/frere.svg",
      "word": "le frère"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/soeur.svg",
      "word": "la sœur"
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
  "prompt": "Écrivez six phrases : c'est ma / mon… et une phrase avec j'ai."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit phrases modèles, puis votre famille (vraie ou inventée)."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Une page pour l''album',
    'PE',
    $c$Objectif
Écrire une courte page de famille avec ma / mon et j'ai.

Consigne
Imitez la page de Léa. Changez les prénoms.

Support — Page de Léa (papier crème)
Je m'appelle Léa Niyonzima.
Voici ma famille.
C'est ma sœur, Mireille.
J'ai une sœur. Je n'ai pas de frère.
Mes parents habitent loin.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa a un frère.",
  "correct": false,
  "explanation": "Elle écrit : « Je n'ai pas de frère. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel possessif utilise Léa devant « parents » ?",
  "options": [
    {
      "text": "mon",
      "correct": false
    },
    {
      "text": "ma",
      "correct": false
    },
    {
      "text": "mes",
      "correct": true
    },
    {
      "text": "leur",
      "correct": false
    }
  ],
  "explanation": "« Mes parents » : plusieurs."
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
      "left": "ma sœur",
      "right": "une personne"
    },
    {
      "left": "mes parents",
      "right": "plusieurs personnes"
    },
    {
      "left": "j'ai",
      "right": "possession"
    },
    {
      "left": "je n'ai pas",
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
  "prompt": "Complétez :\n___ parents habitent loin.",
  "answer": "Mes"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Voici",
    "ma",
    "famille",
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
  "word": "parents",
  "hint": "Le père et la mère, ensemble."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est mon sœur, Mireille.",
  "correct_sentence": "C'est ma sœur, Mireille.",
  "explanation": "Sœur est féminin : ma sœur."
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
      "image_path": "/elearning/mfk-a1-m4/soeur.svg",
      "word": "la sœur"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/famille.svg",
      "word": "la famille"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/photo.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/maison.svg",
      "word": "la maison"
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
  "prompt": "Écrivez une page de six lignes pour l'album : je m'appelle, voici, c'est ma/mon, j'ai, je n'ai pas."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre page comme Léa, une phrase, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Ma, mon, mes',
    'EL',
    $c$Objectif
Retenir les possessifs et les mots de la famille.

Consigne
Apprenez la fiche, puis entraînez-vous.

Support — Fiche de l'album
ma + féminin : ma mère, ma sœur, ma tante
mon + masculin : mon père, mon frère, mon oncle
mes + pluriel : mes parents, mes frères
j'ai un frère / une sœur
je n'ai pas de frère
C'est + ma / mon + personne
Voici ma famille.
Attention : on dit ma mère, pas mon mère.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « mon sœur ».",
  "correct": false,
  "explanation": "Sœur est féminin : ma sœur."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel mot va avec « oncle » ?",
  "options": [
    {
      "text": "ma",
      "correct": false
    },
    {
      "text": "mes",
      "correct": false
    },
    {
      "text": "mon",
      "correct": true
    },
    {
      "text": "une",
      "correct": false
    }
  ],
  "explanation": "Oncle est masculin : mon oncle."
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
      "left": "mère",
      "right": "ma"
    },
    {
      "left": "père",
      "right": "mon"
    },
    {
      "left": "parents",
      "right": "mes"
    },
    {
      "left": "sœur",
      "right": "ma"
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
  "prompt": "Complétez :\nC'est ___ tante.",
  "answer": "ma"
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
    "de",
    "frère",
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
  "word": "tante",
  "hint": "La sœur du père ou de la mère."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est ma oncle.",
  "correct_sentence": "C'est mon oncle.",
  "explanation": "Oncle est masculin : mon oncle."
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
      "image_path": "/elearning/mfk-a1-m4/tante.svg",
      "word": "la tante"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/oncle.svg",
      "word": "l'oncle"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/enfant.svg",
      "word": "un enfant"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/famille.svg",
      "word": "la famille"
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
  "prompt": "Recopiez la fiche. Ajoutez quatre phrases vraies ou inventées sur votre famille."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : ma mère, mon père, ma sœur, mon frère, ma tante, mon oncle, mes parents."
}$j$::jsonb,
    9
  );

  -- ===== Se ressembler, se distinguer =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Se ressembler, se distinguer'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Se ressembler, se distinguer', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Deux photos, une ressemblance',
    'CO',
    $c$Objectif
Comprendre une description simple : il / elle est, il / elle a, aussi, mais.

Consigne
Qui est grand ? Qui a des lunettes ? Qu'est-ce qui est pareil, qu'est-ce qui change ?

Support — Sous le figuier, deux photos
Patrick : Éric est grand. Nina est petite.
Aline : Oui. Mais Nina a les mêmes yeux. Elle ressemble à Éric.
Léa : Éric a des lunettes. Nina n'a pas de lunettes.
Patrick : Éric est jeune. Claire n'est pas jeune, mais elle sourit aussi.
Aline : Ils sont différents, et c'est une famille.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Nina est grande.",
  "correct": false,
  "explanation": "Patrick : « Nina est petite. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a des lunettes ?",
  "options": [
    {
      "text": "Nina",
      "correct": false
    },
    {
      "text": "Éric",
      "correct": true
    },
    {
      "text": "Léa",
      "correct": false
    },
    {
      "text": "Patrick",
      "correct": false
    }
  ],
  "explanation": "Léa : « Éric a des lunettes. »"
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
      "right": "Éric"
    },
    {
      "left": "petite",
      "right": "Nina"
    },
    {
      "left": "lunettes",
      "right": "Éric"
    },
    {
      "left": "aussi",
      "right": "le sourire de Claire"
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
  "prompt": "Complétez :\nNina est ___.",
  "answer": "petite"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Éric",
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
  "word": "lunettes",
  "hint": "Éric en porte, Nina non."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nina est petit.",
  "correct_sentence": "Nina est petite.",
  "explanation": "Nina = elle : petite (féminin)."
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
      "image_path": "/elearning/mfk-a1-m4/grand.svg",
      "word": "grand"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/petit.svg",
      "word": "petit"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/lunettes.svg",
      "word": "les lunettes"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/cheveux.svg",
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
  "prompt": "Notez deux ressemblances et deux différences entendues dans le dialogue."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Éric est grand. Nina est petite. Éric a des lunettes. Elle sourit aussi."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Cartes « même » et « mais »',
    'CE',
    $c$Objectif
Lire des portraits croisés : est / a, aussi, mais.

Consigne
Lisez les cartes épinglées, puis répondez.

Support — Cartes de l'album
Carte A — Éric Uwase
Il est grand. Il a des lunettes. Il a les cheveux courts.

Carte B — Nina Uwase
Elle est petite. Elle n'a pas de lunettes. Mais elle a les mêmes yeux.

Carte C — Claire et Aline
Claire a les cheveux longs. Aline aussi. Mais Aline est plus jeune.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline a les cheveux courts, comme Claire.",
  "correct": false,
  "explanation": "Claire a les cheveux longs. Aline aussi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est vraie pour Nina ?",
  "options": [
    {
      "text": "Elle est grande",
      "correct": false
    },
    {
      "text": "Elle a des lunettes",
      "correct": false
    },
    {
      "text": "Elle est petite",
      "correct": true
    },
    {
      "text": "Elle habite loin",
      "correct": false
    }
  ],
  "explanation": "Carte B : « Elle est petite. »"
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
      "right": "description avec être"
    },
    {
      "left": "il a",
      "right": "description avec avoir"
    },
    {
      "left": "aussi",
      "right": "pareil"
    },
    {
      "left": "mais",
      "right": "différence"
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
  "prompt": "Complétez :\nAline aussi. ___ Aline est plus jeune.",
  "answer": "Mais"
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
    "des",
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
  "word": "cheveux",
  "hint": "Longs chez Claire, et chez Aline aussi."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est grande.",
  "correct_sentence": "Il est grand.",
  "explanation": "Il = masculin : grand, sans e."
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
      "image_path": "/elearning/mfk-a1-m4/grand.svg",
      "word": "grand"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/petit.svg",
      "word": "petit"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/cheveux.svg",
      "word": "les cheveux"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/portrait.svg",
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
  "prompt": "Recopiez une carte, puis écrivez deux phrases avec aussi et mais."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les trois cartes à voix haute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire qui on est, qui on n''est pas',
    'PO',
    $c$Objectif
Décrire une personne : il / elle est, il / elle a, aussi, mais.

Consigne
Répétez, puis décrivez un camarade ou une photo.

Support — Modèles de Patrick
Il est grand.
Elle est petite.
Il est jeune.
Elle a les cheveux longs.
Il a des lunettes.
Moi aussi.
Mais je suis petit.
Nous sommes différents.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Moi aussi » marque une ressemblance.",
  "correct": true,
  "explanation": "Aussi = pareil."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel mot introduit une différence ?",
  "options": [
    {
      "text": "aussi",
      "correct": false
    },
    {
      "text": "et",
      "correct": false
    },
    {
      "text": "mais",
      "correct": true
    },
    {
      "text": "voici",
      "correct": false
    }
  ],
  "explanation": "Mais = contraste."
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
      "right": "pas petit"
    },
    {
      "left": "jeune",
      "right": "pas âgé"
    },
    {
      "left": "aussi",
      "right": "pareil"
    },
    {
      "left": "mais",
      "right": "contraire"
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
  "prompt": "Complétez :\nElle ___ les cheveux longs.",
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
    "Elle",
    "est",
    "petite",
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
  "word": "aussi",
  "hint": "Le petit mot pour dire « pareil »."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Elle a le cheveux longs.",
  "correct_sentence": "Elle a les cheveux longs.",
  "explanation": "Cheveux est pluriel : les cheveux."
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
      "image_path": "/elearning/mfk-a1-m4/cheveux.svg",
      "word": "les cheveux"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/lunettes.svg",
      "word": "les lunettes"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/sourire.svg",
      "word": "un sourire"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/portrait.svg",
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
  "prompt": "Écrivez six phrases : deux avec est, deux avec a, une avec aussi, une avec mais."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit phrases, puis un mini-portrait d'Éric ou de Nina."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Deux colonnes sur une carte',
    'PE',
    $c$Objectif
Écrire un portrait croisé : ressemblances et différences.

Consigne
Imitez la carte de Patrick. Une colonne « aussi », une colonne « mais ».

Support — Carte de Patrick
Éric et Nina
Aussi : les yeux.
Mais : la taille. Éric est grand. Nina est petite.
Aussi : le sourire.
Mais : les lunettes. Éric a des lunettes. Nina n'a pas de lunettes.
Patrick
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick écrit que Nina a des lunettes.",
  "correct": false,
  "explanation": "« Nina n'a pas de lunettes. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qu'est-ce qui est pareil, d'après Patrick ?",
  "options": [
    {
      "text": "La taille",
      "correct": false
    },
    {
      "text": "Les lunettes",
      "correct": false
    },
    {
      "text": "Les yeux",
      "correct": true
    },
    {
      "text": "L'âge",
      "correct": false
    }
  ],
  "explanation": "Colonne Aussi : les yeux."
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
      "left": "Aussi",
      "right": "yeux, sourire"
    },
    {
      "left": "Mais",
      "right": "taille, lunettes"
    },
    {
      "left": "grand",
      "right": "Éric"
    },
    {
      "left": "petite",
      "right": "Nina"
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
  "prompt": "Complétez :\nNina n'a pas ___ lunettes.",
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
    "Éric",
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
  "word": "taille",
  "hint": "Éric et Nina : ce n'est pas la même…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nina n'a pas des lunettes.",
  "correct_sentence": "Nina n'a pas de lunettes.",
  "explanation": "Négation : pas de + nom."
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
      "image_path": "/elearning/mfk-a1-m4/photo.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/lunettes.svg",
      "word": "les lunettes"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/sourire.svg",
      "word": "un sourire"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/petit.svg",
      "word": "petit"
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
  "prompt": "Écrivez une carte : deux personnes, deux « aussi », deux « mais ». Signez."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre carte, lentement, comme Patrick."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Être, avoir, aussi, mais',
    'EL',
    $c$Objectif
Retenir il / elle est, il / elle a, et les petits mots aussi / mais.

Consigne
Étudiez la fiche, puis décrivez deux personnes.

Support — Fiche de Patrick
Il est / elle est + adjectif : grand, grande, petit, petite, jeune
Il a / elle a + les cheveux / des lunettes
aussi = pareil
mais = différence
Je suis / tu es / il est / elle est
J'ai / tu as / il a / elle a
Attention : elle est petite (avec e). Il est petit.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « elle est petit ».",
  "correct": false,
  "explanation": "Féminin : petite."
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
      "text": "Elle est grand",
      "correct": false
    },
    {
      "text": "Elle est grande",
      "correct": true
    },
    {
      "text": "Elle sont grande",
      "correct": false
    },
    {
      "text": "Elle es grande",
      "correct": false
    }
  ],
  "explanation": "Elle est grande."
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
      "right": "il est grand"
    },
    {
      "left": "avoir",
      "right": "il a des lunettes"
    },
    {
      "left": "aussi",
      "right": "ressemblance"
    },
    {
      "left": "mais",
      "right": "différence"
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
  "prompt": "Complétez :\nElle est ___. (Nina, la taille)",
  "answer": "petite"
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
    "suis",
    "jeune",
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
  "word": "grande",
  "hint": "Féminin de grand."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il a les lunettes.",
  "correct_sentence": "Il a des lunettes.",
  "explanation": "On dit souvent des lunettes (une paire)."
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
      "image_path": "/elearning/mfk-a1-m4/grand.svg",
      "word": "grand"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/petit.svg",
      "word": "petit"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/lunettes.svg",
      "word": "les lunettes"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/cheveux.svg",
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : est / a / aussi / mais."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites la conjugaison de être et d'avoir au présent (je, tu, il, elle)."
}$j$::jsonb,
    9
  );

  -- ===== Ce qu'on aime, ce qu'on n'aime pas =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Ce qu''on aime, ce qu''on n''aime pas'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Ce qu''on aime, ce qu''on n''aime pas', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le tour des goûts, autour du thé',
    'CO',
    $c$Objectif
Comprendre j'aime, j'adore, je n'aime pas.

Consigne
Qui aime quoi ? Qui n'aime pas le football ?

Support — Banc près de la fontaine, tasses de thé
Hawa : J'adore le thé. Je n'aime pas le football.
Marc : Moi, j'aime le football. Mon fils Kévin aussi.
Léa : J'aime les livres. Je n'aime pas la radio trop forte.
Rose : J'adore la danse. Et le thé, moi aussi.
Aline : J'aime le jardin, le samedi. Je n'aime pas partir loin.
Joël : Moi, j'aime la moto. Mais j'aime aussi le thé, lentement.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa adore le football.",
  "correct": false,
  "explanation": "Hawa : « Je n'aime pas le football. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qu'est-ce que Léa aime ?",
  "options": [
    {
      "text": "La moto",
      "correct": false
    },
    {
      "text": "Les livres",
      "correct": true
    },
    {
      "text": "Le football",
      "correct": false
    },
    {
      "text": "La radio trop forte",
      "correct": false
    }
  ],
  "explanation": "Léa : « J'aime les livres. »"
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
      "left": "Hawa",
      "right": "le thé"
    },
    {
      "left": "Marc",
      "right": "le football"
    },
    {
      "left": "Rose",
      "right": "la danse"
    },
    {
      "left": "Aline",
      "right": "le jardin"
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
  "prompt": "Complétez :\nJ'___ le thé.",
  "answer": "adore"
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
    "n'aime",
    "pas",
    "le",
    "football",
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
  "word": "thé",
  "hint": "Hawa en adore une tasse, près de la fontaine."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je n'aime pas le danse.",
  "correct_sentence": "Je n'aime pas la danse.",
  "explanation": "Danse est féminin : la danse."
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
      "image_path": "/elearning/mfk-a1-m4/the.svg",
      "word": "le thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/football.svg",
      "word": "le football"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/danse.svg",
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
  "prompt": "Listez quatre goûts entendus : j'aime / j'adore / je n'aime pas."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : J'adore le thé. J'aime les livres. Je n'aime pas le football. J'adore la danse."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Les cartes-goûts du figuier',
    'CE',
    $c$Objectif
Lire des cartes de goûts : aimer, adorer, ne pas aimer.

Consigne
Lisez les cartes, puis répondez.

Support — Cartes colorées
Hawa — J'adore le thé. Je n'aime pas le football.
Marc — J'aime le football et la radio.
Léa — J'aime les livres. Je n'aime pas le bruit.
Rose — J'adore la danse. J'aime le thé aussi.
Joël — J'aime la moto. Je n'aime pas rester assis.
Règle du Seuil : un « j'aime », un « je n'aime pas » par carte.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël aime rester assis.",
  "correct": false,
  "explanation": "« Je n'aime pas rester assis. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui écrit deux choses aimées, sans « je n'aime pas » ?",
  "options": [
    {
      "text": "Hawa",
      "correct": false
    },
    {
      "text": "Marc",
      "correct": true
    },
    {
      "text": "Léa",
      "correct": false
    },
    {
      "text": "Joël",
      "correct": false
    }
  ],
  "explanation": "Marc : football et radio. Pas de « je n'aime pas » sur sa carte."
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
      "left": "j'adore",
      "right": "très fort"
    },
    {
      "left": "j'aime",
      "right": "c'est bien"
    },
    {
      "left": "je n'aime pas",
      "right": "non merci"
    },
    {
      "left": "aussi",
      "right": "moi de même"
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
  "prompt": "Complétez :\nJe n'aime ___ le bruit.",
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
    "J'aime",
    "les",
    "livres",
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
  "word": "danse",
  "hint": "Rose l'adore, après le thé."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'aime pas le football.",
  "correct_sentence": "Je n'aime pas le football.",
  "explanation": "Négation complète : ne… pas → je n'aime pas."
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
      "image_path": "/elearning/mfk-a1-m4/the.svg",
      "word": "le thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/musique.svg",
      "word": "la musique"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/adorer.svg",
      "word": "adorer"
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
  "prompt": "Recopiez deux cartes. Ajoutez la vôtre : un j'aime et un je n'aime pas."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les cinq cartes, puis la règle du Seuil."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire j''aime et je n''aime pas',
    'PO',
    $c$Objectif
Dire ses goûts avec aimer, adorer et ne pas aimer.

Consigne
Répétez, puis parlez de vous.

Support — Modèles de Rose
J'aime le thé.
J'adore la danse.
Je n'aime pas le football.
J'aime les livres.
J'aime la musique.
Je n'aime pas le bruit.
Moi aussi.
Mais moi, j'aime la moto.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« J'adore » est plus fort que « j'aime ».",
  "correct": true,
  "explanation": "Adorer = aimer beaucoup."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est une négation ?",
  "options": [
    {
      "text": "J'aime le thé",
      "correct": false
    },
    {
      "text": "J'adore la danse",
      "correct": false
    },
    {
      "text": "Je n'aime pas le bruit",
      "correct": true
    },
    {
      "text": "Moi aussi",
      "correct": false
    }
  ],
  "explanation": "Ne… pas = négation."
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
      "left": "j'aime",
      "right": "positif"
    },
    {
      "left": "j'adore",
      "right": "très positif"
    },
    {
      "left": "je n'aime pas",
      "right": "négatif"
    },
    {
      "left": "mais moi",
      "right": "contraste"
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
  "prompt": "Complétez :\nJ'___ la danse.",
  "answer": "adore"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'aime",
    "la",
    "musique",
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
  "word": "adore",
  "hint": "Plus fort que j'aime."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'aime le musique.",
  "correct_sentence": "J'aime la musique.",
  "explanation": "Musique est féminin : la musique."
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
      "image_path": "/elearning/mfk-a1-m4/danse.svg",
      "word": "la danse"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/musique.svg",
      "word": "la musique"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/football.svg",
      "word": "le football"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/the.svg",
      "word": "le thé"
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
  "prompt": "Écrivez six phrases de goûts : deux j'aime, deux j'adore, deux je n'aime pas."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis vos goûts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma carte-goût',
    'PE',
    $c$Objectif
Écrire une carte de goûts claire, comme à l'album.

Consigne
Imitez la carte de Rose. Respectez la règle : un j'aime, un j'adore, un je n'aime pas.

Support — Carte de Rose
Je m'appelle Rose Iradukunda.
J'adore la danse.
J'aime le thé.
Je n'aime pas rester assise.
Et vous ?
Rose
Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose pose une question à la fin.",
  "correct": true,
  "explanation": "« Et vous ? »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que n'aime pas Rose ?",
  "options": [
    {
      "text": "La danse",
      "correct": false
    },
    {
      "text": "Le thé",
      "correct": false
    },
    {
      "text": "Rester assise",
      "correct": true
    },
    {
      "text": "Le Seuil",
      "correct": false
    }
  ],
  "explanation": "« Je n'aime pas rester assise. »"
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
      "left": "J'adore",
      "right": "la danse"
    },
    {
      "left": "J'aime",
      "right": "le thé"
    },
    {
      "left": "Je n'aime pas",
      "right": "rester assise"
    },
    {
      "left": "Et vous ?",
      "right": "question"
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
  "prompt": "Complétez :\nJe n'aime pas rester ___.",
  "answer": "assise"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'adore",
    "la",
    "danse",
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
  "word": "assise",
  "hint": "Rose n'aime pas rester… (féminin)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je n'aime pas rester assis.",
  "correct_sentence": "Je n'aime pas rester assise.",
  "explanation": "Rose = elle : assise."
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
      "image_path": "/elearning/mfk-a1-m4/danse.svg",
      "word": "la danse"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/the.svg",
      "word": "le thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/adorer.svg",
      "word": "adorer"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/photo.svg",
      "word": "une photo"
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
  "prompt": "Écrivez votre carte : je m'appelle, j'adore, j'aime, je n'aime pas, et vous ?"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre carte, puis posez la question « Et vous ? »"
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Aimer et ne pas aimer',
    'EL',
    $c$Objectif
Retenir aimer / adorer / ne pas aimer + un nom.

Consigne
Apprenez la fiche du Seuil.

Support — Fiche de Rose
j'aime + le / la / les + nom
j'adore + le / la + nom
je n'aime pas + le / la + nom
j'aime le thé / la danse / les livres
j'aime / tu aimes / il aime / elle aime
nous aimons / vous aimez / ils aiment
Attention : je n'aime pas (avec n').
On ne dit pas « j'aime pas » à l'écrit, ici.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« J'aime pas » est la forme de la fiche.",
  "correct": false,
  "explanation": "La fiche demande : je n'aime pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle conjugaison est correcte ?",
  "options": [
    {
      "text": "tu aime",
      "correct": false
    },
    {
      "text": "tu aimes",
      "correct": true
    },
    {
      "text": "tu aimer",
      "correct": false
    },
    {
      "text": "tu aimes-tu",
      "correct": false
    }
  ],
  "explanation": "Tu aimes."
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
      "left": "j'aime",
      "right": "je"
    },
    {
      "left": "tu aimes",
      "right": "tu"
    },
    {
      "left": "nous aimons",
      "right": "nous"
    },
    {
      "left": "ils aiment",
      "right": "ils"
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
  "prompt": "Complétez :\nTu ___ le thé ?",
  "answer": "aimes"
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
    "aimons",
    "la",
    "danse",
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
  "word": "aimons",
  "hint": "Nous… (verbe aimer)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Elle aimes la musique.",
  "correct_sentence": "Elle aime la musique.",
  "explanation": "Il / elle aime (sans s)."
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
      "image_path": "/elearning/mfk-a1-m4/the.svg",
      "word": "le thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/musique.svg",
      "word": "la musique"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/football.svg",
      "word": "le football"
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
  "prompt": "Conjuguez aimer. Écrivez trois phrases : j'aime / j'adore / je n'aime pas."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites la conjugaison d'aimer, puis trois goûts personnels."
}$j$::jsonb,
    9
  );

  -- ===== Se raconter en quelques mots =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Se raconter en quelques mots'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Se raconter en quelques mots', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Quatre voix, quatre portraits',
    'CO',
    $c$Objectif
Comprendre un mini-portrait : je m'appelle, j'ai … ans, j'habite, je suis.

Consigne
Qui habite au Seuil ? Qui est chauffeur ? Qui a quel âge ?

Support — Tour de parole sous le figuier
Léa : Je m'appelle Léa Niyonzima. J'ai vingt-six ans. J'habite au Seuil. Je suis nouvelle.
Marc : Je m'appelle Marc. J'ai quarante ans. Je suis chauffeur. J'habite Rukiri-Nord.
Patrick : Je m'appelle Patrick Habimana. J'ai trente ans. Je suis guide. J'habite près du marché.
Aline : Je m'appelle Aline Uwase. J'ai trente-deux ans. J'habite près de la cour. Je suis à l'accueil du Seuil.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa habite au Seuil.",
  "correct": true,
  "explanation": "Léa : « J'habite au Seuil. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel âge a Patrick ?",
  "options": [
    {
      "text": "Vingt-six ans",
      "correct": false
    },
    {
      "text": "Trente ans",
      "correct": true
    },
    {
      "text": "Trente-deux ans",
      "correct": false
    },
    {
      "text": "Quarante ans",
      "correct": false
    }
  ],
  "explanation": "Patrick : « J'ai trente ans. »"
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
      "right": "nouvelle"
    },
    {
      "left": "Marc",
      "right": "chauffeur"
    },
    {
      "left": "Patrick",
      "right": "guide"
    },
    {
      "left": "Aline",
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
  "prompt": "Complétez :\nJ'___ trente ans.",
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
    "Je",
    "suis",
    "guide",
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
  "hint": "Le verbe pour dire où on vit."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai trente an.",
  "correct_sentence": "J'ai trente ans.",
  "explanation": "Ans, au pluriel, après un nombre."
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
      "image_path": "/elearning/mfk-a1-m4/portrait.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/maison.svg",
      "word": "la maison"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/photo.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/famille.svg",
      "word": "la famille"
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
  "prompt": "Notez pour chaque voix : prénom, âge, lieu, rôle."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je m'appelle… J'ai … ans. J'habite… Je suis…"
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fiches portrait du tissu',
    'CE',
    $c$Objectif
Lire des mini-portraits écrits.

Consigne
Lisez les quatre fiches, puis répondez.

Support — Fiches crème
Léa Niyonzima — 26 ans — habite au Seuil — est nouvelle
Marc Nkurunziza — 40 ans — habite Rukiri-Nord — est chauffeur
Patrick Habimana — 30 ans — habite près du marché — est guide
Aline Uwase — 32 ans — habite près de la cour — est à l'accueil
Consigne de l'album : quatre lignes, pas plus.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline habite loin de la cour.",
  "correct": false,
  "explanation": "Fiche : « habite près de la cour »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a quarante ans ?",
  "options": [
    {
      "text": "Léa",
      "correct": false
    },
    {
      "text": "Marc",
      "correct": true
    },
    {
      "text": "Patrick",
      "correct": false
    },
    {
      "text": "Aline",
      "correct": false
    }
  ],
  "explanation": "Marc Nkurunziza — 40 ans."
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
      "left": "26 ans",
      "right": "Léa"
    },
    {
      "left": "30 ans",
      "right": "Patrick"
    },
    {
      "left": "32 ans",
      "right": "Aline"
    },
    {
      "left": "40 ans",
      "right": "Marc"
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
  "prompt": "Complétez :\nPatrick est ___.",
  "answer": "guide"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'habite",
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
  "word": "nouvelle",
  "hint": "Léa l'est encore, au Seuil."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis nouveau.",
  "correct_sentence": "Je suis nouvelle.",
  "explanation": "Léa = féminin : nouvelle."
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
      "image_path": "/elearning/mfk-a1-m4/portrait.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/maison.svg",
      "word": "la maison"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/photo.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/famille.svg",
      "word": "la famille"
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
  "prompt": "Recopiez une fiche en phrases complètes : je m'appelle / j'ai / j'habite / je suis."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les quatre fiches, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Se dire en quatre phrases',
    'PO',
    $c$Objectif
Se présenter en quatre phrases stables.

Consigne
Répétez le cadre, puis remplissez avec votre vie (ou une vie inventée).

Support — Cadre d'Aline
Je m'appelle …
J'ai … ans.
J'habite …
Je suis …
Enchanté / Enchantée.
Voilà, c'est moi.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut dire « Enchantée » au féminin.",
  "correct": true,
  "explanation": "Accord : enchanté / enchantée."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase dit l'âge ?",
  "options": [
    {
      "text": "Je m'appelle Aline",
      "correct": false
    },
    {
      "text": "J'ai trente-deux ans",
      "correct": true
    },
    {
      "text": "J'habite près de la cour",
      "correct": false
    },
    {
      "text": "Je suis à l'accueil",
      "correct": false
    }
  ],
  "explanation": "J'ai + nombre + ans."
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
      "left": "je m'appelle",
      "right": "nom"
    },
    {
      "left": "j'ai … ans",
      "right": "âge"
    },
    {
      "left": "j'habite",
      "right": "lieu"
    },
    {
      "left": "je suis",
      "right": "rôle"
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
  "prompt": "Complétez :\nJe m'___.",
  "answer": "appelle"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Voici",
    "mon",
    "portrait",
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
  "word": "appelle",
  "hint": "Je m'… + prénom."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'habite à le Seuil.",
  "correct_sentence": "J'habite au Seuil.",
  "explanation": "À + le → au."
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
      "image_path": "/elearning/mfk-a1-m4/portrait.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/maison.svg",
      "word": "la maison"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/photo.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/sourire.svg",
      "word": "un sourire"
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
  "prompt": "Écrivez votre cadre en six lignes, y compris Enchanté(e) et Voilà, c'est moi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez votre portrait en quatre phrases, puis « Voilà, c'est moi. »"
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma fiche de l''album',
    'PE',
    $c$Objectif
Écrire un mini-portrait de quatre phrases.

Consigne
Imitez la fiche de Joël. Restez à quatre phrases + signature.

Support — Fiche de Joël
Je m'appelle Joël Mugisha.
J'ai vingt-neuf ans.
J'habite Rukiri-Nord.
Je suis sur la route, avec la moto.
Joël
Album du Seuil
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël a vingt-neuf ans.",
  "correct": true,
  "explanation": "Deuxième phrase de la fiche."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait Joël ?",
  "options": [
    {
      "text": "Il est à l'accueil",
      "correct": false
    },
    {
      "text": "Il est sur la route, avec la moto",
      "correct": true
    },
    {
      "text": "Il est guide du marché",
      "correct": false
    },
    {
      "text": "Il est nouveau au Seuil",
      "correct": false
    }
  ],
  "explanation": "« Je suis sur la route, avec la moto. »"
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
      "left": "Je m'appelle",
      "right": "Joël Mugisha"
    },
    {
      "left": "J'ai",
      "right": "vingt-neuf ans"
    },
    {
      "left": "J'habite",
      "right": "Rukiri-Nord"
    },
    {
      "left": "Je suis",
      "right": "sur la route"
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
  "prompt": "Complétez :\nJ'ai vingt-neuf ___.",
  "answer": "ans"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'habite",
    "Rukiri-Nord",
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
  "word": "vingt",
  "hint": "Le début du nombre 29."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai vingt-neuf an.",
  "correct_sentence": "J'ai vingt-neuf ans.",
  "explanation": "Ans au pluriel."
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
      "image_path": "/elearning/mfk-a1-m4/portrait.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/photo.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/maison.svg",
      "word": "la maison"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/sourire.svg",
      "word": "un sourire"
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
  "prompt": "Écrivez votre fiche : quatre phrases, une signature, le mot Album du Seuil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre fiche comme pour l'album."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Le cadre du portrait',
    'EL',
    $c$Objectif
Retenir le cadre : s'appeler, avoir + âge, habiter, être.

Consigne
Apprenez, puis racontez-vous.

Support — Fiche d'Aline
Je m'appelle + prénom
J'ai + nombre + ans
J'habite + lieu (à / au / près de)
Je suis + rôle
Enchanté (homme) / Enchantée (femme)
avoir : j'ai, tu as, il a, elle a
être : je suis, tu es, il est, elle est
Attention : j'ai trente ans (pas « j'ai trente an »).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « j'ai trente an ».",
  "correct": false,
  "explanation": "Ans, au pluriel."
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
      "text": "Je habite",
      "correct": false
    },
    {
      "text": "J'habite",
      "correct": true
    },
    {
      "text": "J'habit",
      "correct": false
    },
    {
      "text": "Je habites",
      "correct": false
    }
  ],
  "explanation": "J'habite (élision)."
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
      "left": "s'appeler",
      "right": "le nom"
    },
    {
      "left": "avoir",
      "right": "l'âge"
    },
    {
      "left": "habiter",
      "right": "le lieu"
    },
    {
      "left": "être",
      "right": "le rôle"
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
  "prompt": "Complétez :\nJe ___ nouvelle.",
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
    "Je",
    "suis",
    "chauffeur",
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
  "hint": "Le verbe du lieu de vie."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je m'appelle est Léa.",
  "correct_sentence": "Je m'appelle Léa.",
  "explanation": "Pas de « est » après je m'appelle."
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
      "image_path": "/elearning/mfk-a1-m4/portrait.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/photo.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/maison.svg",
      "word": "la maison"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/famille.svg",
      "word": "la famille"
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
  "prompt": "Recopiez la fiche. Écrivez votre portrait en quatre phrases."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites le cadre, puis votre portrait."
}$j$::jsonb,
    9
  );

  -- ===== Temps libre =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Temps libre'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Temps libre', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le samedi au Seuil',
    'CO',
    $c$Objectif
Comprendre des activités de temps libre : le samedi, jouer à, écouter, lire, danser.

Consigne
Qui fait quoi le week-end ?

Support — Fin d'après-midi, craie à la main
Marc : Le samedi, je joue au football avec Kévin.
Léa : Le dimanche, je lis un livre sous le figuier.
Rose : Le samedi soir, je danse. Pas trop tard.
Hawa : J'écoute la radio, et je bois du thé.
Patrick : Le dimanche, je marche au jardin. Pas de guide, juste moi.
Aline : Moi, je jardine près de la cour. C'est calme.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick est guide le dimanche, au jardin.",
  "correct": false,
  "explanation": "« Pas de guide, juste moi. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait Léa le dimanche ?",
  "options": [
    {
      "text": "Elle joue au football",
      "correct": false
    },
    {
      "text": "Elle lit un livre",
      "correct": true
    },
    {
      "text": "Elle danse",
      "correct": false
    },
    {
      "text": "Elle jardine",
      "correct": false
    }
  ],
  "explanation": "Léa : « je lis un livre sous le figuier. »"
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
      "left": "Marc",
      "right": "football"
    },
    {
      "left": "Rose",
      "right": "danse"
    },
    {
      "left": "Hawa",
      "right": "radio et thé"
    },
    {
      "left": "Aline",
      "right": "jardin"
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
  "prompt": "Complétez :\nJe joue ___ football.",
  "answer": "au"
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
    "lis",
    "un",
    "livre",
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
  "word": "samedi",
  "hint": "Jour où Marc joue avec Kévin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je joue à le football.",
  "correct_sentence": "Je joue au football.",
  "explanation": "Jouer à + le → au football."
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
      "image_path": "/elearning/mfk-a1-m4/football.svg",
      "word": "le football"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/danse.svg",
      "word": "la danse"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/jardin.svg",
      "word": "le jardin"
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
  "prompt": "Notez six activités et le jour (samedi ou dimanche)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Le samedi, je joue au football. Le dimanche, je lis un livre. J'écoute la radio."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le tableau des samedis',
    'CE',
    $c$Objectif
Lire un tableau d'activités de week-end.

Consigne
Lisez le tableau à la craie.

Support — Tableau Figuier
Temps libre — Seuil des Sources
Samedi
Marc + Kévin — jouer au football
Rose — danser
Aline — jardiner
Hawa — écouter la radio
Dimanche
Léa — lire
Patrick — marcher au jardin
Joël — se reposer (parfois la moto)
Rien d'obligatoire. C'est le temps libre.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël joue au football le dimanche.",
  "correct": false,
  "explanation": "Joël : se reposer (parfois la moto)."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui jardine le samedi ?",
  "options": [
    {
      "text": "Léa",
      "correct": false
    },
    {
      "text": "Aline",
      "correct": true
    },
    {
      "text": "Patrick",
      "correct": false
    },
    {
      "text": "Rose",
      "correct": false
    }
  ],
  "explanation": "Samedi — Aline — jardiner."
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
      "left": "jouer",
      "right": "football"
    },
    {
      "left": "danser",
      "right": "Rose"
    },
    {
      "left": "lire",
      "right": "Léa"
    },
    {
      "left": "marcher",
      "right": "Patrick"
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
  "prompt": "Complétez :\nLe dimanche, Léa ___.",
  "answer": "lit"
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
    "temps",
    "libre",
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
  "word": "jardiner",
  "hint": "L'activité d'Aline, près de la cour."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je joue au danse.",
  "correct_sentence": "Je danse.",
  "explanation": "On danse (verbe). On ne dit pas « jouer au danse »."
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
      "image_path": "/elearning/mfk-a1-m4/ballon.svg",
      "word": "un ballon"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/radio.svg",
      "word": "la radio"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/jardin.svg",
      "word": "le jardin"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/livre.svg",
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
  "prompt": "Recopiez le tableau. Ajoutez votre ligne : jour + verbe."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le tableau, samedi d'abord, puis dimanche."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire son week-end',
    'PO',
    $c$Objectif
Parler de son temps libre avec le samedi / le dimanche + un verbe.

Consigne
Répétez, puis dites votre week-end.

Support — Modèles de Marc
Le samedi, je joue au football.
Le dimanche, je me repose.
J'écoute la radio.
Je lis un livre.
Je danse.
Je jardine.
Je marche.
J'aime ce temps libre.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je me repose » est une activité de temps libre.",
  "correct": true,
  "explanation": "Repos = temps libre aussi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase dit le jour ?",
  "options": [
    {
      "text": "J'écoute la radio",
      "correct": false
    },
    {
      "text": "Le samedi, je joue au football",
      "correct": true
    },
    {
      "text": "J'aime ce temps libre",
      "correct": false
    },
    {
      "text": "Je marche",
      "correct": false
    }
  ],
  "explanation": "Le samedi = jour."
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
      "left": "jouer au",
      "right": "football"
    },
    {
      "left": "écouter",
      "right": "la radio"
    },
    {
      "left": "lire",
      "right": "un livre"
    },
    {
      "left": "danser",
      "right": "le samedi soir"
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
  "prompt": "Complétez :\nLe dimanche, je me ___.",
  "answer": "repose"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'écoute",
    "la",
    "radio",
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
  "word": "repose",
  "hint": "Je me… le dimanche, parfois."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le samedi je joue à football.",
  "correct_sentence": "Le samedi je joue au football.",
  "explanation": "Jouer au football."
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
      "image_path": "/elearning/mfk-a1-m4/football.svg",
      "word": "le football"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/radio.svg",
      "word": "la radio"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/danse.svg",
      "word": "la danse"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/jardin.svg",
      "word": "le jardin"
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
  "prompt": "Écrivez six phrases : trois pour samedi, trois pour dimanche."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre week-end."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon samedi en cinq lignes',
    'PE',
    $c$Objectif
Écrire un petit texte de temps libre.

Consigne
Imitez le mot de Kévin (écrit avec Marc).

Support — Mot de Kévin
Bonjour,
Le samedi, je joue au football avec mon père.
Après, j'écoute la radio.
Le dimanche, je me repose.
J'aime ce temps libre.
Kévin
8 ans
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Kévin joue le dimanche.",
  "correct": false,
  "explanation": "Il joue le samedi. Le dimanche, il se repose."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Avec qui Kévin joue-t-il ?",
  "options": [
    {
      "text": "Aline",
      "correct": false
    },
    {
      "text": "Son père",
      "correct": true
    },
    {
      "text": "Rose",
      "correct": false
    },
    {
      "text": "Léa",
      "correct": false
    }
  ],
  "explanation": "« avec mon père »."
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
      "left": "samedi",
      "right": "football puis radio"
    },
    {
      "left": "dimanche",
      "right": "repos"
    },
    {
      "left": "j'aime",
      "right": "ce temps libre"
    },
    {
      "left": "8 ans",
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
  "prompt": "Complétez :\nJe joue au football avec ___ père.",
  "answer": "mon"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'aime",
    "ce",
    "temps",
    "libre",
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
  "word": "libre",
  "hint": "Le temps… du week-end, pas l'école."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le samedi je joue au football avec ma père.",
  "correct_sentence": "Le samedi je joue au football avec mon père.",
  "explanation": "Père est masculin : mon père."
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
      "image_path": "/elearning/mfk-a1-m4/ballon.svg",
      "word": "un ballon"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/radio.svg",
      "word": "la radio"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/enfant.svg",
      "word": "un enfant"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/football.svg",
      "word": "le football"
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
  "prompt": "Écrivez cinq lignes : bonjour, samedi, après, dimanche, j'aime…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot, simplement, comme Kévin."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Verbes du temps libre',
    'EL',
    $c$Objectif
Retenir les verbes de week-end et jouer à / au.

Consigne
Étudiez la fiche.

Support — Fiche de Marc
le samedi / le dimanche
je joue au football
j'écoute la radio
je lis un livre
je danse
je jardine
je marche
je me repose
jouer à + le → au
Attention : je lis (pas « je lise » au présent).
J'aime ce temps libre.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je lise un livre » au présent.",
  "correct": false,
  "explanation": "Présent : je lis."
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
      "text": "je joue à le football",
      "correct": false
    },
    {
      "text": "je joue au football",
      "correct": true
    },
    {
      "text": "je joue de football",
      "correct": false
    },
    {
      "text": "je joue football",
      "correct": false
    }
  ],
  "explanation": "Jouer au football."
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
      "left": "jouer",
      "right": "ballon"
    },
    {
      "left": "écouter",
      "right": "radio"
    },
    {
      "left": "lire",
      "right": "livre"
    },
    {
      "left": "se reposer",
      "right": "calme"
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
  "prompt": "Complétez :\nJe ___ un livre.",
  "answer": "lis"
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
    "me",
    "repose",
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
  "word": "écoute",
  "hint": "J'… la radio."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je lise un livre le dimanche.",
  "correct_sentence": "Je lis un livre le dimanche.",
  "explanation": "Présent de lire : je lis."
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
      "image_path": "/elearning/mfk-a1-m4/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/radio.svg",
      "word": "la radio"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/ballon.svg",
      "word": "un ballon"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/jardin.svg",
      "word": "le jardin"
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
  "prompt": "Recopiez la fiche. Écrivez votre week-end en quatre phrases."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites tous les verbes de la fiche, puis deux phrases au samedi."
}$j$::jsonb,
    9
  );

  -- ===== Quand le corps parle =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Quand le corps parle'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Quand le corps parle', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Après la route, Joël s''assoit',
    'CO',
    $c$Objectif
Comprendre le corps et les sensations : j'ai mal à, je suis fatigué, je suis content.

Consigne
Où Joël a-t-il mal ? Comment se sent Rose ?

Support — Banc sous le figuier, casque posé
Joël : Ah… j'ai mal au dos. La route est longue.
Léa : Tu es fatigué ?
Joël : Oui. J'ai aussi mal à la tête. Mais je suis content : tout le monde est arrivé.
Rose : Moi, j'ai mal au pied. J'ai trop dansé.
Aline : Prenez le thé. Après, la main est calme, la tête aussi.
Hawa : Je suis fatiguée, mais je souris.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël a mal au pied.",
  "correct": false,
  "explanation": "Joël a mal au dos et à la tête. Rose a mal au pied."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi Rose a-t-elle mal au pied ?",
  "options": [
    {
      "text": "Elle a marché au pont",
      "correct": false
    },
    {
      "text": "Elle a trop dansé",
      "correct": true
    },
    {
      "text": "Elle a joué au football",
      "correct": false
    },
    {
      "text": "Elle a jardiné",
      "correct": false
    }
  ],
  "explanation": "Rose : « J'ai trop dansé. »"
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
      "left": "dos",
      "right": "Joël"
    },
    {
      "left": "tête",
      "right": "Joël aussi"
    },
    {
      "left": "pied",
      "right": "Rose"
    },
    {
      "left": "sourire",
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
  "prompt": "Complétez :\nJ'ai mal ___ dos.",
  "answer": "au"
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
    "suis",
    "fatigué",
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
  "word": "dos",
  "hint": "Joël y a mal, après la moto."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai mal à le dos.",
  "correct_sentence": "J'ai mal au dos.",
  "explanation": "À + le → au."
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
      "image_path": "/elearning/mfk-a1-m4/dos.svg",
      "word": "le dos"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/tete.svg",
      "word": "la tête"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/pied.svg",
      "word": "le pied"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/fatigue.svg",
      "word": "fatigué"
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
  "prompt": "Notez qui a mal où, et qui est fatigué / content."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : J'ai mal au dos. J'ai mal à la tête. Je suis fatigué. Mais je suis content."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Billets « mal » et « mieux »',
    'CE',
    $c$Objectif
Lire de courtes notes sur le corps.

Consigne
Lisez les billets épinglés près du thé.

Support — Billets
Joël — J'ai mal au dos et à la tête. Je suis fatigué. Mais je suis content.
Rose — J'ai mal au pied. La danse, c'est trop ! Demain, ça va.
Hawa — Je suis fatiguée. J'ai mal à la main (beaucoup de cartes). Je souris.
Aline — Thé sucré pour la tête. La main tient la tasse. Tout va bien.
Conseil du Seuil : dire où ça fait mal, simplement.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa a mal à la main.",
  "correct": true,
  "explanation": "Billet d'Hawa : « J'ai mal à la main. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que propose Aline pour la tête ?",
  "options": [
    {
      "text": "Un ballon",
      "correct": false
    },
    {
      "text": "Un thé sucré",
      "correct": true
    },
    {
      "text": "La moto",
      "correct": false
    },
    {
      "text": "Le football",
      "correct": false
    }
  ],
  "explanation": "« Thé sucré pour la tête. »"
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
      "left": "mal au dos",
      "right": "Joël"
    },
    {
      "left": "mal au pied",
      "right": "Rose"
    },
    {
      "left": "mal à la main",
      "right": "Hawa"
    },
    {
      "left": "thé sucré",
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
  "prompt": "Complétez :\nJ'ai mal ___ la tête.",
  "answer": "à"
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
    "suis",
    "content",
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
  "word": "main",
  "hint": "Hawa y a mal, à force de cartes."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis fatigué.",
  "correct_sentence": "Je suis fatiguée.",
  "explanation": "Hawa parle : féminin, fatiguée."
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
      "image_path": "/elearning/mfk-a1-m4/main.svg",
      "word": "la main"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/tete.svg",
      "word": "la tête"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/pied.svg",
      "word": "le pied"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/sourire.svg",
      "word": "un sourire"
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
  "prompt": "Recopiez deux billets. Ajoutez le vôtre : j'ai mal à… / je suis…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les quatre billets, puis le conseil du Seuil."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire j''ai mal, je suis…',
    'PO',
    $c$Objectif
Dire une douleur et un sentiment simples.

Consigne
Répétez, puis parlez de vous (vrai ou inventé).

Support — Modèles d'Aline
J'ai mal à la tête.
J'ai mal au dos.
J'ai mal au pied.
J'ai mal à la main.
Je suis fatigué.
Je suis fatiguée.
Je suis content.
Je suis contente.
Je souris.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je suis contente » est au féminin.",
  "correct": true,
  "explanation": "Contente = elle."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase parle d'un sentiment, pas d'un lieu du corps ?",
  "options": [
    {
      "text": "J'ai mal à la tête",
      "correct": false
    },
    {
      "text": "J'ai mal au dos",
      "correct": false
    },
    {
      "text": "Je suis content",
      "correct": true
    },
    {
      "text": "J'ai mal à la main",
      "correct": false
    }
  ],
  "explanation": "Content = sentiment."
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
      "left": "la tête",
      "right": "à la tête"
    },
    {
      "left": "le dos",
      "right": "au dos"
    },
    {
      "left": "le pied",
      "right": "au pied"
    },
    {
      "left": "la main",
      "right": "à la main"
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
  "prompt": "Complétez :\nJ'ai mal ___ pied.",
  "answer": "au"
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
    "souris",
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
  "word": "mal",
  "hint": "J'ai … à la tête."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai mal à le pied.",
  "correct_sentence": "J'ai mal au pied.",
  "explanation": "À + le → au."
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
      "image_path": "/elearning/mfk-a1-m4/tete.svg",
      "word": "la tête"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/dos.svg",
      "word": "le dos"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/main.svg",
      "word": "la main"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/sourire.svg",
      "word": "un sourire"
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
  "prompt": "Écrivez six phrases : quatre « j'ai mal à/au », deux « je suis… »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis deux phrases sur vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Un billet pour Aline',
    'PE',
    $c$Objectif
Écrire un court billet sur le corps et l'état.

Consigne
Imitez le billet de Joël.

Support — Billet de Joël
Aline,
Aujourd'hui, j'ai mal au dos.
J'ai aussi mal à la tête.
Je suis fatigué, mais je suis content.
Merci pour le thé.
Joël
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël remercie pour le thé.",
  "correct": true,
  "explanation": "Dernière phrase avant la signature."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de « j'ai mal » Joël écrit-il ?",
  "options": [
    {
      "text": "Un",
      "correct": false
    },
    {
      "text": "Deux",
      "correct": true
    },
    {
      "text": "Trois",
      "correct": false
    },
    {
      "text": "Zéro",
      "correct": false
    }
  ],
  "explanation": "Dos et tête : deux."
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
      "left": "dos",
      "right": "première douleur"
    },
    {
      "left": "tête",
      "right": "deuxième douleur"
    },
    {
      "left": "fatigué",
      "right": "état"
    },
    {
      "left": "content",
      "right": "mais…"
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
  "prompt": "Complétez :\nJe suis fatigué, ___ je suis content.",
  "answer": "mais"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Merci",
    "pour",
    "le",
    "thé",
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
  "word": "content",
  "hint": "Joël l'est, malgré le dos."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis fatigué mais je suis contente.",
  "correct_sentence": "Je suis fatigué mais je suis content.",
  "explanation": "Joël = il : content."
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
      "image_path": "/elearning/mfk-a1-m4/dos.svg",
      "word": "le dos"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/tete.svg",
      "word": "la tête"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/the.svg",
      "word": "le thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/fatigue.svg",
      "word": "fatigué"
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
  "prompt": "Écrivez un billet de six lignes : prénom, deux douleurs, un état, mais, merci."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre billet, calmement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Mal à, mal au, je suis',
    'EL',
    $c$Objectif
Retenir le corps et j'ai mal à / au, je suis + adjectif.

Consigne
Apprenez la fiche, puis dites comment vous allez.

Support — Fiche d'Aline
la tête → j'ai mal à la tête
la main → j'ai mal à la main
le dos → j'ai mal au dos
le pied → j'ai mal au pied
je suis fatigué / fatiguée
je suis content / contente
je souris
à + la → à la
à + le → au
Attention : j'ai mal (pas « je suis mal » pour une partie du corps).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je suis mal à la tête ».",
  "correct": false,
  "explanation": "On dit j'ai mal à la tête."
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
      "text": "J'ai mal à le dos",
      "correct": false
    },
    {
      "text": "J'ai mal au dos",
      "correct": true
    },
    {
      "text": "J'ai mal de dos",
      "correct": false
    },
    {
      "text": "Je suis mal au dos",
      "correct": false
    }
  ],
  "explanation": "J'ai mal au dos."
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
      "left": "tête",
      "right": "à la"
    },
    {
      "left": "main",
      "right": "à la"
    },
    {
      "left": "dos",
      "right": "au"
    },
    {
      "left": "pied",
      "right": "au"
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
  "prompt": "Complétez :\nJ'ai mal ___ la main.",
  "answer": "à"
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
    "suis",
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
  "word": "tête",
  "hint": "On y a souvent mal, après la route."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai mal à dos.",
  "correct_sentence": "J'ai mal au dos.",
  "explanation": "Au dos (à + le)."
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
      "image_path": "/elearning/mfk-a1-m4/tete.svg",
      "word": "la tête"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/main.svg",
      "word": "la main"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/dos.svg",
      "word": "le dos"
    },
    {
      "image_path": "/elearning/mfk-a1-m4/pied.svg",
      "word": "le pied"
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : deux douleurs, fatigué(e), content(e)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : à la tête, à la main, au dos, au pied, je suis fatigué, je suis content."
}$j$::jsonb,
    9
  );

END;
$$;
