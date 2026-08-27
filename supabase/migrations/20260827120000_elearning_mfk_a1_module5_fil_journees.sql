/*
  Seed eLearning MFK — Module 5 A1 « Le fil des journées »

  Même micro-monde que les Modules 3 et 4 : cour « Le Seuil des Sources », Rukiri-Nord.
  Fil des heures inventé sous le figuier.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a1-m5/
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
  v_module_title text := 'A1 — Le fil des journées';
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
      'Seed A1 Module 5 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed Module 5 : enseignant % (%)', v_teacher_email, v_teacher_id;

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
      'Grande étape 5 : indiquer l''heure, parler des habitudes, raconter une journée de travail, s''informer sur les sorties et inviter — fil des heures sous le figuier du Seuil des Sources (Rukiri-Nord).',
      'A1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape 5 : indiquer l''heure, parler des habitudes, raconter une journée de travail, s''informer sur les sorties et inviter — fil des heures sous le figuier du Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'A1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Une journée dans le monde =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une journée dans le monde'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une journée dans le monde', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le fil des heures',
    'CO',
    $c$Objectif
Comprendre l'heure : il est…, à + heure, du matin / de l'après-midi / du soir.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Quelle heure est-il ? Qui fait quoi, et à quelle heure ?

Support — Sous le figuier, cartes sur un fil
Aline : Le fil commence. Quelle heure est-il ?
Léa : Il est sept heures du matin.
Marc : À six heures, le minibus part. Moi, je suis déjà sur la route.
Hawa : À midi, on prend le thé ici.
Patrick : À trois heures de l'après-midi, je rentre du jardin.
Joël : À minuit, plus de moto. Je dors.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Il est sept heures du matin, au début du dialogue.",
  "correct": true,
  "explanation": "Léa : « Il est sept heures du matin. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À quelle heure le minibus de Marc part-il ?",
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
      "text": "À trois heures",
      "correct": false
    }
  ],
  "explanation": "Marc : « À six heures, le minibus part. »"
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
      "left": "sept heures",
      "right": "du matin"
    },
    {
      "left": "midi",
      "right": "le thé"
    },
    {
      "left": "trois heures",
      "right": "de l'après-midi"
    },
    {
      "left": "minuit",
      "right": "Joël dort"
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
  "prompt": "Complétez :\nIl ___ sept heures du matin.",
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
    "Il",
    "est",
    "midi",
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
  "word": "heures",
  "hint": "On les compte : une, deux, trois…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est sept heure du matin.",
  "correct_sentence": "Il est sept heures du matin.",
  "explanation": "Après un nombre différent de un : heures, au pluriel."
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
      "image_path": "/elearning/mfk-a1-m5/heure.svg",
      "word": "l'heure"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/midi.svg",
      "word": "midi"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/minuit.svg",
      "word": "minuit"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/fil.svg",
      "word": "le fil"
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
  "prompt": "Notez quatre heures entendues et l'activité (minibus, thé, jardin, sommeil)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Quelle heure est-il ? Il est sept heures du matin. À midi, on prend le thé. À minuit, je dors."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Les cartes du fil',
    'CE',
    $c$Objectif
Lire des heures et des moments de la journée.

Consigne
Lisez les cartes épinglées sur le fil, puis répondez.

Support — Cartes (encre ocre)
1. 6 h — Marc — minibus Figuier 7 — du matin
2. 7 h — Aline — accueil du Seuil — du matin
3. 12 h — Hawa — thé sous le figuier — midi
4. 15 h — Patrick — jardin des Sources — de l'après-midi
5. 19 h — Rose — Salle des Herbes — du soir
Radio Figuier : « Il est… à Rukiri-Nord. »
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose danse à sept heures du matin.",
  "correct": false,
  "explanation": "Carte 5 : 19 h, du soir, Salle des Herbes."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui est à l'accueil à sept heures ?",
  "options": [
    {
      "text": "Marc",
      "correct": false
    },
    {
      "text": "Hawa",
      "correct": false
    },
    {
      "text": "Aline",
      "correct": true
    },
    {
      "text": "Patrick",
      "correct": false
    }
  ],
  "explanation": "Carte 2 : 7 h — Aline — accueil."
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
      "left": "6 h",
      "right": "minibus"
    },
    {
      "left": "12 h",
      "right": "thé"
    },
    {
      "left": "15 h",
      "right": "jardin"
    },
    {
      "left": "19 h",
      "right": "salle"
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
  "prompt": "Complétez :\nIl est trois heures ___ l'après-midi.",
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
    "est",
    "sept",
    "heures",
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
  "word": "matin",
  "hint": "Le début de la journée, avant midi."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est midi heures.",
  "correct_sentence": "Il est midi.",
  "explanation": "Midi et minuit : sans le mot heures."
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
      "image_path": "/elearning/mfk-a1-m5/matin.svg",
      "word": "le matin"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/apresmidi.svg",
      "word": "l'après-midi"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/soir.svg",
      "word": "le soir"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/carte.svg",
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
  "prompt": "Recopiez les cinq cartes. Ajoutez une carte pour vous : heure + lieu."
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
    'PO — Dire l''heure',
    'PO',
    $c$Objectif
Dire l'heure et le moment : il est…, à… heures, du matin / du soir.

Consigne
Répétez les modèles, puis dites l'heure maintenant (vraie ou inventée).

Support — Modèles d'Aline
Quelle heure est-il ?
Il est sept heures.
Il est sept heures du matin.
Il est midi.
Il est trois heures de l'après-midi.
Il est sept heures du soir.
Il est minuit.
À six heures, je commence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Quelle heure est-il ? » sert à demander l'heure.",
  "correct": true,
  "explanation": "Question d'Aline sur le fil."
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
      "text": "Il est sept heure",
      "correct": false
    },
    {
      "text": "Il est sept heures",
      "correct": true
    },
    {
      "text": "Il sont sept heures",
      "correct": false
    },
    {
      "text": "Il es sept heures",
      "correct": false
    }
  ],
  "explanation": "Il est + nombre + heures."
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
      "left": "du matin",
      "right": "avant midi"
    },
    {
      "left": "de l'après-midi",
      "right": "après 12 h"
    },
    {
      "left": "du soir",
      "right": "après le travail"
    },
    {
      "left": "minuit",
      "right": "la nuit"
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
  "prompt": "Complétez :\nQuelle heure ___-il ?",
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
    "Il",
    "est",
    "minuit",
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
  "word": "midi",
  "hint": "Douze heures, on prend souvent le thé."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est une heures.",
  "correct_sentence": "Il est une heure.",
  "explanation": "Une heure : singulier."
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
      "image_path": "/elearning/mfk-a1-m5/heure.svg",
      "word": "l'heure"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/midi.svg",
      "word": "midi"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/minuit.svg",
      "word": "minuit"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/reveil.svg",
      "word": "le réveil"
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
  "prompt": "Écrivez six phrases : trois « il est… », trois « à… heures, je… »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis l'heure de votre réveil."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma carte pour le fil',
    'PE',
    $c$Objectif
Écrire une petite carte d'heure, comme sur le fil.

Consigne
Imitez la carte de Léa. Changez l'heure et l'activité.

Support — Carte de Léa
Léa Niyonzima
Il est huit heures du matin.
À huit heures, je prends le thé.
À midi, je lis sous le figuier.
Léa
Fil des heures — Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa prend le thé à midi.",
  "correct": false,
  "explanation": "Elle prend le thé à huit heures. À midi, elle lit."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle heure Léa écrit-elle en premier ?",
  "options": [
    {
      "text": "Midi",
      "correct": false
    },
    {
      "text": "Huit heures du matin",
      "correct": true
    },
    {
      "text": "Minuit",
      "correct": false
    },
    {
      "text": "Trois heures",
      "correct": false
    }
  ],
  "explanation": "« Il est huit heures du matin. »"
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
      "left": "huit heures",
      "right": "thé"
    },
    {
      "left": "midi",
      "right": "lire"
    },
    {
      "left": "Léa",
      "right": "signature"
    },
    {
      "left": "fil",
      "right": "le Seuil"
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
  "prompt": "Complétez :\nÀ huit heures, je prends ___ thé.",
  "answer": "le"
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
    "huit",
    "heures",
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
  "word": "soir",
  "hint": "Le moment après l'après-midi, avant minuit."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "À huit heures je prends le thés.",
  "correct_sentence": "À huit heures je prends le thé.",
  "explanation": "Thé reste au singulier : le thé."
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
      "image_path": "/elearning/mfk-a1-m5/the.svg",
      "word": "le thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/carte.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/fil.svg",
      "word": "le fil"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/matin.svg",
      "word": "le matin"
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
  "prompt": "Écrivez votre carte : prénom, il est…, à… je…, signature."
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
    'EL — Il est, à, du matin',
    'EL',
    $c$Objectif
Retenir l'heure : il est, à + heure, midi / minuit, du matin / du soir.

Consigne
Apprenez la fiche, puis dites l'heure.

Support — Fiche du fil
Quelle heure est-il ?
Il est + nombre + heures
Il est une heure (singulier)
Il est midi. Il est minuit.
à + heure : à six heures
du matin / de l'après-midi / du soir
Attention : heures au pluriel (sauf une heure).
On ne dit pas « midi heures ».
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « il est midi heures ».",
  "correct": false,
  "explanation": "Il est midi. Sans heures."
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
      "text": "à le six heures",
      "correct": false
    },
    {
      "text": "à six heure",
      "correct": false
    },
    {
      "text": "à six heures",
      "correct": true
    },
    {
      "text": "à six-heures",
      "correct": false
    }
  ],
  "explanation": "À six heures."
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
      "right": "l'heure maintenant"
    },
    {
      "left": "à",
      "right": "l'heure d'une action"
    },
    {
      "left": "midi",
      "right": "12 h"
    },
    {
      "left": "minuit",
      "right": "0 h"
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
  "prompt": "Complétez :\nIl est une ___.",
  "answer": "heure"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Quelle",
    "heure",
    "est-il",
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
  "word": "minuit",
  "hint": "L'heure où Joël range la moto."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est minuit heures.",
  "correct_sentence": "Il est minuit.",
  "explanation": "Minuit : sans heures."
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
      "image_path": "/elearning/mfk-a1-m5/heure.svg",
      "word": "l'heure"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/midi.svg",
      "word": "midi"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/soir.svg",
      "word": "le soir"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/reveil.svg",
      "word": "le réveil"
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
  "prompt": "Recopiez la fiche. Écrivez quatre heures : matin, midi, après-midi, soir."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : Quelle heure est-il ? Il est une heure. Il est midi. Il est minuit. À six heures."
}$j$::jsonb,
    9
  );

  -- ===== Rythmes de vie =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Rythmes de vie'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Rythmes de vie', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — De l''aube au fil',
    'CO',
    $c$Objectif
Comprendre un rythme de journée : je me lève, je prends, je dîne, je me couche.

Consigne
Qui se lève tôt ? Qui se couche à quelle heure ?

Support — Banc près de la fontaine
Léa : D'habitude, je me lève à six heures.
Aline : Moi aussi. Je prends le thé, puis j'ouvre l'accueil.
Patrick : Je me lève à sept heures. Le matin, je marche au jardin.
Hawa : L'après-midi, je range les cartes. Le soir, je dîne ici.
Joël : Je me couche à minuit. Pas trop tôt.
Rose : Moi, je me couche à vingt-deux heures. Demain, je danse.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa se lève à six heures.",
  "correct": true,
  "explanation": "Léa : « D'habitude, je me lève à six heures. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À quelle heure Joël se couche-t-il ?",
  "options": [
    {
      "text": "À six heures",
      "correct": false
    },
    {
      "text": "À sept heures",
      "correct": false
    },
    {
      "text": "À minuit",
      "correct": true
    },
    {
      "text": "À vingt-deux heures",
      "correct": false
    }
  ],
  "explanation": "Joël : « Je me couche à minuit. »"
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
      "right": "se lève à 6 h"
    },
    {
      "left": "Patrick",
      "right": "marche le matin"
    },
    {
      "left": "Hawa",
      "right": "dîne le soir"
    },
    {
      "left": "Rose",
      "right": "se couche à 22 h"
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
  "prompt": "Complétez :\nJe me ___ à six heures.",
  "answer": "lève"
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
    "couche",
    "tard",
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
  "word": "lève",
  "hint": "Le premier verbe du matin, avec je me…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je se lève à six heures.",
  "correct_sentence": "Je me lève à six heures.",
  "explanation": "Je me lève (pas je se)."
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
      "image_path": "/elearning/mfk-a1-m5/lever.svg",
      "word": "se lever"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/petitdej.svg",
      "word": "le petit déjeuner"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/diner.svg",
      "word": "dîner"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/coucher.svg",
      "word": "se coucher"
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
  "prompt": "Notez pour quatre personnes : se lever / activité / se coucher."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je me lève à six heures. Je prends le thé. Le soir, je dîne. Je me couche à vingt-deux heures."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Cartes-rythmes',
    'CE',
    $c$Objectif
Lire des rythmes de vie : le matin, l'après-midi, le soir.

Consigne
Lisez les cartes, puis répondez.

Support — Cartes du fil
Léa — Je me lève à 6 h. Le matin, je prends le thé. Je me couche à 22 h.
Aline — Je me lève à 6 h. Puis j'ouvre l'accueil. Le soir, je range le fil.
Patrick — Je me lève à 7 h. Le matin, je marche. L'après-midi, je guide.
Joël — Je me lève à 8 h. Le soir, je roule. Je me couche à minuit.
Règle du Seuil : une heure pour se lever, une heure pour se coucher.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick se lève à six heures.",
  "correct": false,
  "explanation": "Carte Patrick : 7 h."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui se couche à minuit ?",
  "options": [
    {
      "text": "Léa",
      "correct": false
    },
    {
      "text": "Aline",
      "correct": false
    },
    {
      "text": "Patrick",
      "correct": false
    },
    {
      "text": "Joël",
      "correct": true
    }
  ],
  "explanation": "Joël : « Je me couche à minuit. »"
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
      "left": "le matin",
      "right": "thé, marche, accueil"
    },
    {
      "left": "l'après-midi",
      "right": "Patrick guide"
    },
    {
      "left": "le soir",
      "right": "fil et moto"
    },
    {
      "left": "d'habitude",
      "right": "presque toujours"
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
  "prompt": "Complétez :\nJe me ___ à minuit.",
  "answer": "couche"
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
    "prends",
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
  "word": "couche",
  "hint": "Le dernier verbe de la journée, avec je me…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tu me lèves à sept heures.",
  "correct_sentence": "Tu te lèves à sept heures.",
  "explanation": "Tu te lèves (pas tu me)."
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
      "image_path": "/elearning/mfk-a1-m5/matin.svg",
      "word": "le matin"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/apresmidi.svg",
      "word": "l'après-midi"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/soir.svg",
      "word": "le soir"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/the.svg",
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
  "prompt": "Recopiez une carte. Ajoutez la vôtre : je me lève / je me couche."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les quatre cartes, puis la règle du Seuil."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Raconter sa journée',
    'PO',
    $c$Objectif
Dire son rythme : je me lève, je prends, je dîne, je me couche.

Consigne
Répétez, puis parlez de votre journée.

Support — Modèles de Léa
Je me lève à six heures.
Je prends le thé.
Le matin, je marche.
L'après-midi, je lis.
Le soir, je dîne.
Je me couche à vingt-deux heures.
D'habitude, je me lève tôt.
Parfois, je me couche tard.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« D'habitude » veut dire presque toujours.",
  "correct": true,
  "explanation": "Habitude = souvent, presque chaque jour."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel mot introduit une exception ?",
  "options": [
    {
      "text": "d'habitude",
      "correct": false
    },
    {
      "text": "le matin",
      "correct": false
    },
    {
      "text": "parfois",
      "correct": true
    },
    {
      "text": "puis",
      "correct": false
    }
  ],
  "explanation": "Parfois = de temps en temps."
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
      "left": "je me lève",
      "right": "matin"
    },
    {
      "left": "je dîne",
      "right": "soir"
    },
    {
      "left": "je me couche",
      "right": "nuit"
    },
    {
      "left": "parfois",
      "right": "pas toujours"
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
  "prompt": "Complétez :\nD'habitude, je me lève ___.",
  "answer": "tôt"
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
    "matin",
    "je",
    "marche",
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
  "word": "parfois",
  "hint": "Le contraire de toujours, un peu."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je me couche à vingt-deux heure.",
  "correct_sentence": "Je me couche à vingt-deux heures.",
  "explanation": "Heures au pluriel."
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
      "image_path": "/elearning/mfk-a1-m5/lever.svg",
      "word": "se lever"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/coucher.svg",
      "word": "se coucher"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/diner.svg",
      "word": "dîner"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/reveil.svg",
      "word": "le réveil"
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
  "prompt": "Écrivez huit phrases comme Léa, avec vos heures (vraies ou inventées)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre rythme."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma journée en six lignes',
    'PE',
    $c$Objectif
Écrire un petit rythme de vie.

Consigne
Imitez le mot de Patrick.

Support — Mot de Patrick
Bonjour,
D'habitude, je me lève à sept heures.
Le matin, je marche au jardin.
L'après-midi, je suis guide.
Le soir, je dîne au Seuil.
Je me couche à vingt-deux heures.
Patrick
Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick dîne au Seuil.",
  "correct": true,
  "explanation": "« Le soir, je dîne au Seuil. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait Patrick le matin ?",
  "options": [
    {
      "text": "Il dîne",
      "correct": false
    },
    {
      "text": "Il se couche",
      "correct": false
    },
    {
      "text": "Il marche au jardin",
      "correct": true
    },
    {
      "text": "Il ouvre l'accueil",
      "correct": false
    }
  ],
  "explanation": "« Le matin, je marche au jardin. »"
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
      "left": "je me lève",
      "right": "7 h"
    },
    {
      "left": "le matin",
      "right": "jardin"
    },
    {
      "left": "l'après-midi",
      "right": "guide"
    },
    {
      "left": "le soir",
      "right": "dîner"
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
  "prompt": "Complétez :\nJe me couche ___ vingt-deux heures.",
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
    "dîne",
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
  "word": "jardin",
  "hint": "Patrick y marche, le matin, près des sources."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le matin je marche à le jardin.",
  "correct_sentence": "Le matin je marche au jardin.",
  "explanation": "À + le → au jardin."
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
      "image_path": "/elearning/mfk-a1-m5/jardin.svg",
      "word": "le jardin"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/marche.svg",
      "word": "marcher"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/diner.svg",
      "word": "dîner"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/coucher.svg",
      "word": "se coucher"
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
  "prompt": "Écrivez six lignes : bonjour, je me lève, matin, après-midi, soir, je me couche."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot, simplement, comme Patrick."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Se lever, se coucher',
    'EL',
    $c$Objectif
Retenir les verbes du rythme et je me / tu te / il se.

Consigne
Étudiez la fiche.

Support — Fiche de Léa
je me lève / tu te lèves / il se lève / elle se lève
je me couche / tu te couches / il se couche
je prends le thé
je dîne
le matin / l'après-midi / le soir
d'habitude / parfois
Attention : je me lève (pas je se lève).
tôt / tard.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je se lève ».",
  "correct": false,
  "explanation": "Je me lève."
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
      "text": "tu me lèves",
      "correct": false
    },
    {
      "text": "tu te lèves",
      "correct": true
    },
    {
      "text": "tu se lèves",
      "correct": false
    },
    {
      "text": "tu lèves-toi",
      "correct": false
    }
  ],
  "explanation": "Tu te lèves."
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
      "left": "je me",
      "right": "lève / couche"
    },
    {
      "left": "tu te",
      "right": "lèves / couches"
    },
    {
      "left": "il se",
      "right": "lève / couche"
    },
    {
      "left": "elle se",
      "right": "lève / couche"
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
  "prompt": "Complétez :\nTu ___ lèves à sept heures.",
  "answer": "te"
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
    "se",
    "couche",
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
  "word": "lèves",
  "hint": "La forme avec tu te…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Elle me couche à vingt-deux heures.",
  "correct_sentence": "Elle se couche à vingt-deux heures.",
  "explanation": "Elle se couche."
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
      "image_path": "/elearning/mfk-a1-m5/lever.svg",
      "word": "se lever"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/coucher.svg",
      "word": "se coucher"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/matin.svg",
      "word": "le matin"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/soir.svg",
      "word": "le soir"
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : je / tu / il / elle."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites je me lève, tu te lèves, il se lève, elle se lève, puis je me couche."
}$j$::jsonb,
    9
  );

  -- ===== Nos habitudes partagées =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Nos habitudes partagées'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Nos habitudes partagées', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — On se retrouve sous le figuier',
    'CO',
    $c$Objectif
Comprendre des habitudes communes : on + verbe, tous les jours, d'habitude.

Consigne
Qu'est-ce qu'on fait ensemble ? Quel jour ?

Support — Pause du Seuil, 16 h
Hawa : Tous les jours, on prend le thé à quatre heures.
Aline : Oui. D'habitude, on se retrouve ici.
Marc : Le samedi, on n'est pas tous là. Kévin joue au football.
Rose : Le samedi soir, on danse à la Salle des Herbes.
Léa : Moi, j'aime ça. On écoute aussi la radio.
Patrick : Le dimanche, on marche au jardin. Pas de course.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On prend le thé tous les jours à quatre heures.",
  "correct": true,
  "explanation": "Hawa : « Tous les jours, on prend le thé à quatre heures. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait-on le dimanche ?",
  "options": [
    {
      "text": "On danse",
      "correct": false
    },
    {
      "text": "On prend le minibus",
      "correct": false
    },
    {
      "text": "On marche au jardin",
      "correct": true
    },
    {
      "text": "On ouvre l'accueil",
      "correct": false
    }
  ],
  "explanation": "Patrick : « Le dimanche, on marche au jardin. »"
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
      "left": "tous les jours",
      "right": "thé à 16 h"
    },
    {
      "left": "samedi soir",
      "right": "danse"
    },
    {
      "left": "dimanche",
      "right": "jardin"
    },
    {
      "left": "samedi",
      "right": "football de Kévin"
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
  "prompt": "Complétez :\nTous les jours, ___ prend le thé.",
  "answer": "on"
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
    "se",
    "retrouve",
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
  "word": "habitude",
  "hint": "D'… : presque toujours, au Seuil."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On prends le thé à quatre heures.",
  "correct_sentence": "On prend le thé à quatre heures.",
  "explanation": "On prend (comme il/elle), sans s."
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
      "image_path": "/elearning/mfk-a1-m5/the.svg",
      "word": "le thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/danse.svg",
      "word": "la danse"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/jardin.svg",
      "word": "le jardin"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/radio.svg",
      "word": "la radio"
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
  "prompt": "Listez quatre habitudes du Seuil : tous les jours / samedi / dimanche."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Tous les jours, on prend le thé. Le samedi soir, on danse. Le dimanche, on marche."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Tableau des habitudes',
    'CE',
    $c$Objectif
Lire un tableau d'habitudes partagées.

Consigne
Lisez le tableau à la craie.

Support — Tableau Figuier
Habitudes du Seuil
Tous les jours — 16 h — on prend le thé
D'habitude — on se retrouve sous le figuier
Samedi — Kévin joue au football
Samedi soir — on danse à la Salle des Herbes
Dimanche — on marche au jardin
Parfois — on écoute Radio Figuier
Rien d'obligatoire. C'est notre fil.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On danse tous les jours.",
  "correct": false,
  "explanation": "On danse le samedi soir."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À quelle heure prend-on le thé tous les jours ?",
  "options": [
    {
      "text": "À 6 h",
      "correct": false
    },
    {
      "text": "À midi",
      "correct": false
    },
    {
      "text": "À 16 h",
      "correct": true
    },
    {
      "text": "À minuit",
      "correct": false
    }
  ],
  "explanation": "Tous les jours — 16 h — on prend le thé."
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
      "left": "on prend",
      "right": "le thé"
    },
    {
      "left": "on danse",
      "right": "Salle des Herbes"
    },
    {
      "left": "on marche",
      "right": "jardin"
    },
    {
      "left": "parfois",
      "right": "radio"
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
  "prompt": "Complétez :\nLe samedi soir, on ___.",
  "answer": "danse"
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
    "écoute",
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
  "word": "samedi",
  "hint": "Jour où Kévin joue, et où l'on danse le soir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On vas au jardin le dimanche.",
  "correct_sentence": "On va au jardin le dimanche.",
  "explanation": "On va (pas on vas)."
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
      "image_path": "/elearning/mfk-a1-m5/samedi.svg",
      "word": "samedi"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/weekend.svg",
      "word": "le week-end"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/fil.svg",
      "word": "le fil"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/pause.svg",
      "word": "la pause"
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
  "prompt": "Recopiez le tableau. Ajoutez une ligne : jour + on + verbe."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le tableau, du haut vers le bas."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire ce qu''on fait ensemble',
    'PO',
    $c$Objectif
Parler d'habitudes avec on, tous les jours, d'habitude, parfois.

Consigne
Répétez, puis dites une habitude de votre groupe.

Support — Modèles d'Hawa
On prend le thé.
On se retrouve ici.
Tous les jours, on parle un peu.
D'habitude, on est à l'heure.
Parfois, on écoute la radio.
Le samedi, on danse.
Le dimanche, on se repose.
On aime ce fil.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« On » peut parler du groupe, ici le Seuil.",
  "correct": true,
  "explanation": "On = nous, de façon simple."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase dit la fréquence « presque toujours » ?",
  "options": [
    {
      "text": "Parfois on écoute la radio",
      "correct": false
    },
    {
      "text": "D'habitude on est à l'heure",
      "correct": true
    },
    {
      "text": "Le samedi on danse",
      "correct": false
    },
    {
      "text": "On prend le thé",
      "correct": false
    }
  ],
  "explanation": "D'habitude = presque toujours."
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
      "left": "tous les jours",
      "right": "chaque jour"
    },
    {
      "left": "d'habitude",
      "right": "presque toujours"
    },
    {
      "left": "parfois",
      "right": "de temps en temps"
    },
    {
      "left": "le samedi",
      "right": "un jour précis"
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
  "prompt": "Complétez :\nParfois, on ___ la radio.",
  "answer": "écoute"
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
    "aime",
    "ce",
    "fil",
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
  "word": "parfois",
  "hint": "Pas tous les jours : de temps en temps."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tous les jours on prends le thé.",
  "correct_sentence": "Tous les jours on prend le thé.",
  "explanation": "On prend, sans s."
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
      "image_path": "/elearning/mfk-a1-m5/the.svg",
      "word": "le thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/radio.svg",
      "word": "la radio"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/danse.svg",
      "word": "la danse"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/weekend.svg",
      "word": "le week-end"
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
  "prompt": "Écrivez six phrases avec on : deux tous les jours, deux parfois, deux week-end."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis une habitude de votre classe."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Notre petite habitude',
    'PE',
    $c$Objectif
Écrire une habitude partagée.

Consigne
Imitez le mot d'Hawa.

Support — Mot d'Hawa
Amies, amis du Seuil,
Tous les jours, on prend le thé à quatre heures.
D'habitude, on se retrouve sous le figuier.
Parfois, on écoute Radio Figuier.
Le dimanche, on marche au jardin.
Venez.
Hawa Diallo
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa invite à venir.",
  "correct": true,
  "explanation": "Dernier mot avant la signature : « Venez. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où se retrouve-t-on, d'habitude ?",
  "options": [
    {
      "text": "À la Salle des Herbes",
      "correct": false
    },
    {
      "text": "Sous le figuier",
      "correct": true
    },
    {
      "text": "Au minibus",
      "correct": false
    },
    {
      "text": "Chez Kévin",
      "correct": false
    }
  ],
  "explanation": "« sous le figuier »."
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
      "left": "tous les jours",
      "right": "thé à 16 h"
    },
    {
      "left": "d'habitude",
      "right": "figuier"
    },
    {
      "left": "parfois",
      "right": "radio"
    },
    {
      "left": "dimanche",
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
  "prompt": "Complétez :\nD'habitude, on se retrouve ___ le figuier.",
  "answer": "sous"
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
    "sous",
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
  "word": "figuier",
  "hint": "L'arbre de la cour, où l'on prend le thé."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On se retrouve sous le figuier tous les jour.",
  "correct_sentence": "On se retrouve sous le figuier tous les jours.",
  "explanation": "Jours au pluriel : tous les jours."
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
      "image_path": "/elearning/mfk-a1-m5/the.svg",
      "word": "le thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/jardin.svg",
      "word": "le jardin"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/radio.svg",
      "word": "la radio"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/fil.svg",
      "word": "le fil"
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
  "prompt": "Écrivez un mot de cinq lignes : tous les jours, d'habitude, parfois, un jour, venez."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot, puis dites « Venez. »"
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — On, tous les jours, parfois',
    'EL',
    $c$Objectif
Retenir on + verbe et les mots de fréquence.

Consigne
Apprenez la fiche du Seuil.

Support — Fiche d'Hawa
on + verbe (comme il / elle) : on prend, on va, on danse
tous les jours
d'habitude
parfois
le samedi / le dimanche
on se retrouve
Attention : on prend (pas on prends). On va (pas on vas).
On aime ce fil.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On conjugue « on » comme « nous » (prenons).",
  "correct": false,
  "explanation": "On prend, comme il/elle."
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
      "text": "on vas",
      "correct": false
    },
    {
      "text": "on va",
      "correct": true
    },
    {
      "text": "on allers",
      "correct": false
    },
    {
      "text": "on aller",
      "correct": false
    }
  ],
  "explanation": "On va."
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
      "left": "on prend",
      "right": "il/elle prend"
    },
    {
      "left": "on va",
      "right": "il/elle va"
    },
    {
      "left": "tous les jours",
      "right": "fréquence forte"
    },
    {
      "left": "parfois",
      "right": "fréquence faible"
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
  "prompt": "Complétez :\nOn ___ au jardin le dimanche.",
  "answer": "va"
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
    "danse",
    "le",
    "samedi",
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
  "word": "prend",
  "hint": "On… le thé, tous les jours."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On aimes ce fil.",
  "correct_sentence": "On aime ce fil.",
  "explanation": "On aime (pas aimes)."
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
      "image_path": "/elearning/mfk-a1-m5/pause.svg",
      "word": "la pause"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/samedi.svg",
      "word": "samedi"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/weekend.svg",
      "word": "le week-end"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/danse.svg",
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases avec on."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : on prend, on va, on danse, on se retrouve, tous les jours, parfois."
}$j$::jsonb,
    9
  );

  -- ===== Une journée de travail =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une journée de travail'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une journée de travail', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Les heures de la cour',
    'CO',
    $c$Objectif
Comprendre une journée de travail : je travaille, je commence, je finis.

Consigne
Qui commence à quelle heure ? Qui finit quand ?

Support — Accueil du Seuil, craie à la main
Aline : Je travaille à l'accueil. Je commence à sept heures. Je finis à quinze heures.
Marc : Je suis chauffeur. Je commence à six heures. Je finis à quatorze heures.
Patrick : Je suis guide. Je commence à huit heures. Je finis à seize heures.
Joël : Moi, je travaille avec la moto. Je commence à neuf heures. Je finis tard.
Hawa : Je range les cartes l'après-midi. Ce n'est pas un bureau, mais c'est du travail.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline finit à quinze heures.",
  "correct": true,
  "explanation": "Aline : « Je finis à quinze heures. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui commence le plus tôt ?",
  "options": [
    {
      "text": "Aline",
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
      "text": "Joël",
      "correct": false
    }
  ],
  "explanation": "Marc commence à six heures."
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
      "right": "accueil 7 h–15 h"
    },
    {
      "left": "Marc",
      "right": "minibus 6 h–14 h"
    },
    {
      "left": "Patrick",
      "right": "guide 8 h–16 h"
    },
    {
      "left": "Joël",
      "right": "moto dès 9 h"
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
  "prompt": "Complétez :\nJe ___ à sept heures.",
  "answer": "commence"
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
    "finis",
    "à",
    "quinze",
    "heures",
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
  "word": "travaille",
  "hint": "Le verbe du métier, à l'accueil ou sur la route."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je fini à quinze heures.",
  "correct_sentence": "Je finis à quinze heures.",
  "explanation": "Je finis (avec s)."
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
      "image_path": "/elearning/mfk-a1-m5/travailler.svg",
      "word": "travailler"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/accueil.svg",
      "word": "l'accueil"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/moto.svg",
      "word": "la moto"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/minibus.svg",
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
  "prompt": "Notez pour quatre personnes : métier, heure de début, heure de fin."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je travaille à l'accueil. Je commence à sept heures. Je finis à quinze heures."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fiches de poste',
    'CE',
    $c$Objectif
Lire des fiches de journée de travail.

Consigne
Lisez les fiches accrochées près de l'accueil.

Support — Fiches crème
Aline Uwase — accueil — commence 7 h — finit 15 h — pause à midi
Marc Nkurunziza — chauffeur — commence 6 h — finit 14 h — pause courte
Patrick Habimana — guide — commence 8 h — finit 16 h — jardin le matin
Joël Mugisha — moto — commence 9 h — finit tard — pause au thé
Consigne du Seuil : écrire je commence / je finis, pas seulement les chiffres.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick finit à quatorze heures.",
  "correct": false,
  "explanation": "Patrick finit à 16 h. Marc finit à 14 h."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a une pause à midi ?",
  "options": [
    {
      "text": "Marc",
      "correct": false
    },
    {
      "text": "Aline",
      "correct": true
    },
    {
      "text": "Joël",
      "correct": false
    },
    {
      "text": "Patrick",
      "correct": false
    }
  ],
  "explanation": "Fiche Aline : pause à midi."
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
      "left": "commence 6 h",
      "right": "Marc"
    },
    {
      "left": "commence 7 h",
      "right": "Aline"
    },
    {
      "left": "commence 8 h",
      "right": "Patrick"
    },
    {
      "left": "commence 9 h",
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
  "prompt": "Complétez :\nJe finis ___ quinze heures.",
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
    "travaille",
    "à",
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
  "word": "commence",
  "hint": "Le verbe du début, avant je finis."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je commence à le accueil.",
  "correct_sentence": "Je commence à l'accueil.",
  "explanation": "À l'accueil (élision)."
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
      "image_path": "/elearning/mfk-a1-m5/accueil.svg",
      "word": "l'accueil"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/minibus.svg",
      "word": "le minibus"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/pause.svg",
      "word": "la pause"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/travailler.svg",
      "word": "travailler"
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
  "prompt": "Recopiez une fiche en phrases : je suis, je commence, je finis, pause."
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
    'PO — Dire son travail',
    'PO',
    $c$Objectif
Parler de sa journée de travail : je suis, je commence, je finis.

Consigne
Répétez, puis inventez un métier au Seuil.

Support — Modèles d'Aline
Je suis à l'accueil.
Je travaille ici.
Je commence à sept heures.
Je finis à quinze heures.
À midi, je prends une pause.
Je suis chauffeur.
Je suis guide.
Je travaille avec la moto.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je commence » dit le début du travail.",
  "correct": true,
  "explanation": "Commencer = le début."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel verbe dit la fin du travail ?",
  "options": [
    {
      "text": "je commence",
      "correct": false
    },
    {
      "text": "je prends",
      "correct": false
    },
    {
      "text": "je finis",
      "correct": true
    },
    {
      "text": "je suis",
      "correct": false
    }
  ],
  "explanation": "Je finis à…"
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
      "left": "je suis",
      "right": "rôle"
    },
    {
      "left": "je commence",
      "right": "début"
    },
    {
      "left": "je finis",
      "right": "fin"
    },
    {
      "left": "pause",
      "right": "midi"
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
  "prompt": "Complétez :\nÀ midi, je prends une ___.",
  "answer": "pause"
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
  "word": "finis",
  "hint": "Je… à quinze heures, après le travail."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je travaille à le accueil.",
  "correct_sentence": "Je travaille à l'accueil.",
  "explanation": "À l'accueil."
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
      "image_path": "/elearning/mfk-a1-m5/travailler.svg",
      "word": "travailler"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/accueil.svg",
      "word": "l'accueil"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/moto.svg",
      "word": "la moto"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/pause.svg",
      "word": "la pause"
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
  "prompt": "Écrivez six phrases : je suis, je travaille, je commence, je finis, pause, lieu."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre journée (vraie ou inventée)."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma fiche de journée',
    'PE',
    $c$Objectif
Écrire une fiche de travail claire.

Consigne
Imitez la fiche de Marc.

Support — Fiche de Marc
Je m'appelle Marc Nkurunziza.
Je suis chauffeur.
Je commence à six heures du matin.
Je finis à quatorze heures.
À midi, pause courte.
Puis le minibus Figuier 7 rentre.
Marc
Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc finit le matin.",
  "correct": false,
  "explanation": "Il finit à quatorze heures, l'après-midi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel est le métier de Marc ?",
  "options": [
    {
      "text": "Guide",
      "correct": false
    },
    {
      "text": "Accueil",
      "correct": false
    },
    {
      "text": "Chauffeur",
      "correct": true
    },
    {
      "text": "Danseur",
      "correct": false
    }
  ],
  "explanation": "« Je suis chauffeur. »"
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
      "left": "six heures",
      "right": "début"
    },
    {
      "left": "quatorze heures",
      "right": "fin"
    },
    {
      "left": "midi",
      "right": "pause"
    },
    {
      "left": "Figuier 7",
      "right": "minibus"
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
  "prompt": "Complétez :\nJe suis ___.",
  "answer": "chauffeur"
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
    "commence",
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
  "word": "chauffeur",
  "hint": "Le métier de Marc, avec le minibus."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je commence à six heure du matin.",
  "correct_sentence": "Je commence à six heures du matin.",
  "explanation": "Heures au pluriel."
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
      "image_path": "/elearning/mfk-a1-m5/minibus.svg",
      "word": "le minibus"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/travailler.svg",
      "word": "travailler"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/pause.svg",
      "word": "la pause"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/reveil.svg",
      "word": "le réveil"
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
  "prompt": "Écrivez votre fiche : je m'appelle, je suis, je commence, je finis, pause."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre fiche comme pour l'accueil."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Commencer, finir, travailler',
    'EL',
    $c$Objectif
Retenir je travaille, je commence à, je finis à.

Consigne
Apprenez, puis dites une journée de travail.

Support — Fiche d'Aline
je travaille / tu travailles / il travaille
je commence / tu commences / elle commence
je finis / tu finis / il finit
à + heure
à l'accueil / au jardin / avec la moto
pause à midi
Attention : je finis (avec s). Je commence à (pas « je commence à le »).
Je suis + métier.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « je fini ».",
  "correct": false,
  "explanation": "Je finis, avec s."
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
      "text": "tu travaille",
      "correct": false
    },
    {
      "text": "tu travailles",
      "correct": true
    },
    {
      "text": "tu travailler",
      "correct": false
    },
    {
      "text": "tu travaill",
      "correct": false
    }
  ],
  "explanation": "Tu travailles."
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
      "left": "travailler",
      "right": "le métier"
    },
    {
      "left": "commencer",
      "right": "le début"
    },
    {
      "left": "finir",
      "right": "la fin"
    },
    {
      "left": "pause",
      "right": "un moment"
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
  "prompt": "Complétez :\nTu ___ à seize heures. (fin du travail)",
  "answer": "finis"
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
  "word": "commences",
  "hint": "La forme avec tu…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il fini à seize heures.",
  "correct_sentence": "Il finit à seize heures.",
  "explanation": "Il/elle finit (avec t)."
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
      "image_path": "/elearning/mfk-a1-m5/travailler.svg",
      "word": "travailler"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/accueil.svg",
      "word": "l'accueil"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/moto.svg",
      "word": "la moto"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/minibus.svg",
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
  "prompt": "Recopiez la fiche. Écrivez trois phrases : je travaille / je commence / je finis."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites la conjugaison de commencer et de finir (je, tu, il, elle)."
}$j$::jsonb,
    9
  );

  -- ===== Sortir à sa façon =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Sortir à sa façon'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Sortir à sa façon', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Ce soir au Seuil',
    'CO',
    $c$Objectif
Comprendre des sorties : je sors, on va à, ce soir, demain.

Consigne
Qui sort où ? Quel lieu ?

Support — Fil du soir, lampions
Rose : Ce soir, je sors. Je vais à la Salle des Herbes. On danse.
Léa : Moi, je vais au jardin. C'est calme.
Hawa : Ce soir, je vais au Marché des Lampions. Il y a du thé et des lumières.
Marc : Demain, je ne sors pas. Je me repose avec Kévin.
Joël : Moi, je sors un peu, en moto. Puis je rentre.
Aline : On peut rester ici, aussi. Sortir à sa façon.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc sort ce soir.",
  "correct": false,
  "explanation": "Marc : « Demain, je ne sors pas. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où va Rose ce soir ?",
  "options": [
    {
      "text": "Au jardin",
      "correct": false
    },
    {
      "text": "À la Salle des Herbes",
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
  "explanation": "Rose : « Je vais à la Salle des Herbes. »"
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
      "left": "Rose",
      "right": "danse"
    },
    {
      "left": "Léa",
      "right": "jardin"
    },
    {
      "left": "Hawa",
      "right": "marché"
    },
    {
      "left": "Marc",
      "right": "repos"
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
  "prompt": "Complétez :\nCe soir, je ___.",
  "answer": "sors"
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
    "au",
    "jardin",
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
  "word": "sors",
  "hint": "Je… ce soir : quitter la maison un moment."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je vais à le jardin.",
  "correct_sentence": "Je vais au jardin.",
  "explanation": "À + le → au jardin."
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
      "image_path": "/elearning/mfk-a1-m5/danse.svg",
      "word": "la danse"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/salle.svg",
      "word": "la salle"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/lampion.svg",
      "word": "un lampion"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/jardin.svg",
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
  "prompt": "Notez quatre sorties : personne, lieu, ce soir ou demain."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Ce soir, je sors. Je vais à la salle. Je vais au jardin. Je vais au marché."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Affiche des sorties',
    'CE',
    $c$Objectif
Lire une affiche de sorties du quartier.

Consigne
Lisez l'affiche épinglée sur le fil.

Support — Affiche ocre
Sortir à Rukiri-Nord
Ce soir — Salle des Herbes — danse avec Rose — 19 h
Ce soir — Marché des Lampions — thé et lumières — 18 h
Demain — Jardin des Sources — marche avec Patrick — 9 h
Dimanche — Radio Figuier sous le figuier — 16 h
Entrée libre. On va à sa façon.
Seuil des Sources
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La danse commence à dix-huit heures.",
  "correct": false,
  "explanation": "Danse à 19 h. Marché à 18 h."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À quelle heure est la marche au jardin ?",
  "options": [
    {
      "text": "19 h",
      "correct": false
    },
    {
      "text": "18 h",
      "correct": false
    },
    {
      "text": "9 h",
      "correct": true
    },
    {
      "text": "16 h",
      "correct": false
    }
  ],
  "explanation": "Demain — jardin — 9 h."
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
      "left": "Salle des Herbes",
      "right": "danse"
    },
    {
      "left": "Marché des Lampions",
      "right": "thé"
    },
    {
      "left": "Jardin des Sources",
      "right": "marche"
    },
    {
      "left": "Radio Figuier",
      "right": "figuier"
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
  "prompt": "Complétez :\nOn va ___ la Salle des Herbes.",
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
    "Ce",
    "soir",
    "je",
    "sors",
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
  "word": "marché",
  "hint": "Le soir, des lampions et du thé, pas le matin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je vais à le Salle des Herbes.",
  "correct_sentence": "Je vais à la Salle des Herbes.",
  "explanation": "Salle est féminin : à la salle."
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
      "image_path": "/elearning/mfk-a1-m5/lampion.svg",
      "word": "un lampion"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/salle.svg",
      "word": "la salle"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/radio.svg",
      "word": "la radio"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/marche.svg",
      "word": "marcher"
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
  "prompt": "Recopiez l'affiche. Entourez la sortie que vous choisissez et dites pourquoi."
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
    'PO — Dire où l''on va',
    'PO',
    $c$Objectif
Dire une sortie : je sors, je vais à / au / à la, ce soir.

Consigne
Répétez, puis choisissez une sortie.

Support — Modèles de Rose
Je sors ce soir.
Je vais à la salle.
Je vais au jardin.
Je vais au marché.
On danse.
On marche.
Je ne sors pas demain.
J'aime sortir à ma façon.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je ne sors pas » est une négation.",
  "correct": true,
  "explanation": "Ne… pas = pas de sortie."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase va vers un lieu masculin avec à + le ?",
  "options": [
    {
      "text": "Je vais à la salle",
      "correct": false
    },
    {
      "text": "Je vais au jardin",
      "correct": true
    },
    {
      "text": "Je sors ce soir",
      "correct": false
    },
    {
      "text": "On danse",
      "correct": false
    }
  ],
  "explanation": "Au jardin = à + le jardin."
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
      "left": "à la",
      "right": "salle"
    },
    {
      "left": "au",
      "right": "jardin, marché"
    },
    {
      "left": "ce soir",
      "right": "aujourd'hui, plus tard"
    },
    {
      "left": "demain",
      "right": "le jour d'après"
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
  "prompt": "Complétez :\nJe vais ___ marché.",
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
    "J'aime",
    "sortir",
    "ce",
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
  "word": "sortir",
  "hint": "Quitter la cour un moment, pour la salle ou le marché."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je vais à le marché.",
  "correct_sentence": "Je vais au marché.",
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
      "image_path": "/elearning/mfk-a1-m5/soir.svg",
      "word": "le soir"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/salle.svg",
      "word": "la salle"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/jardin.svg",
      "word": "le jardin"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/lampion.svg",
      "word": "un lampion"
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
  "prompt": "Écrivez six phrases : deux je sors, deux je vais à/au, une négation, une préférence."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre sortie."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon programme du soir',
    'PE',
    $c$Objectif
Écrire un petit programme de sortie.

Consigne
Imitez le mot de Léa.

Support — Mot de Léa
Bonsoir,
Ce soir, je sors.
Je vais au jardin des Sources.
C'est calme. Je marche un peu.
Je ne vais pas à la salle.
À demain.
Léa
Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa va à la salle ce soir.",
  "correct": false,
  "explanation": "« Je ne vais pas à la salle. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Léa va-t-elle ?",
  "options": [
    {
      "text": "Au marché",
      "correct": false
    },
    {
      "text": "Au jardin",
      "correct": true
    },
    {
      "text": "À l'accueil",
      "correct": false
    },
    {
      "text": "À la moto",
      "correct": false
    }
  ],
  "explanation": "« Je vais au jardin des Sources. »"
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
      "left": "ce soir",
      "right": "je sors"
    },
    {
      "left": "jardin",
      "right": "calme"
    },
    {
      "left": "salle",
      "right": "non"
    },
    {
      "left": "à demain",
      "right": "salutation"
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
  "prompt": "Complétez :\nJe ne vais ___ à la salle.",
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
    "marche",
    "un",
    "peu",
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
  "word": "calme",
  "hint": "Léa aime le jardin, pas trop de bruit."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je vais à le jardin.",
  "correct_sentence": "Je vais au jardin.",
  "explanation": "À + le → au jardin."
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
      "image_path": "/elearning/mfk-a1-m5/jardin.svg",
      "word": "le jardin"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/marche.svg",
      "word": "marcher"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/soir.svg",
      "word": "le soir"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/invitation.svg",
      "word": "une invitation"
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
  "prompt": "Écrivez cinq lignes : bonsoir, je sors, je vais, je ne vais pas, à demain."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot, calmement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Aller à, au, à la',
    'EL',
    $c$Objectif
Retenir je sors et je vais à / au / à la.

Consigne
Apprenez la fiche.

Support — Fiche de Rose
je sors / tu sors / il sort / elle sort
je vais / tu vas / il va
à la salle
au jardin (à + le)
au marché
ce soir / demain
je ne sors pas
Attention : au = à + le. On ne dit pas « à le jardin ».
Sortir à sa façon : chacun choisit.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je vais à le jardin ».",
  "correct": false,
  "explanation": "Je vais au jardin."
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
      "text": "tu vas",
      "correct": true
    },
    {
      "text": "tu va",
      "correct": false
    },
    {
      "text": "tu aller",
      "correct": false
    },
    {
      "text": "tu vais",
      "correct": false
    }
  ],
  "explanation": "Tu vas."
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
      "left": "à la",
      "right": "salle"
    },
    {
      "left": "au",
      "right": "jardin / marché"
    },
    {
      "left": "je sors",
      "right": "je quitte un moment"
    },
    {
      "left": "je ne sors pas",
      "right": "je reste"
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
  "prompt": "Complétez :\nElle ___ ce soir.",
  "answer": "sort"
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
    "au",
    "marché",
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
  "word": "marché",
  "hint": "Le soir, des lampions : on y va…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Elle sors ce soir.",
  "correct_sentence": "Elle sort ce soir.",
  "explanation": "Il / elle sort (sans s)."
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
      "image_path": "/elearning/mfk-a1-m5/salle.svg",
      "word": "la salle"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/jardin.svg",
      "word": "le jardin"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/lampion.svg",
      "word": "un lampion"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/soir.svg",
      "word": "le soir"
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : sors / vais à la / vais au / ne sors pas."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : je sors, tu sors, elle sort, je vais à la salle, je vais au jardin."
}$j$::jsonb,
    9
  );

  -- ===== Organiser une rencontre =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Organiser une rencontre'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Organiser une rencontre', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Une invitation sous le fil',
    'CO',
    $c$Objectif
Comprendre une invitation : tu veux… ?, oui, d'accord, je ne peux pas.

Consigne
Qui invite ? Qui accepte ? Qui refuse ?

Support — Fin d'après-midi
Rose : Léa, tu veux venir à la salle ce soir ?
Léa : Oui, avec plaisir. À quelle heure ?
Rose : À dix-neuf heures. D'accord ?
Léa : D'accord.
Rose : Joël, tu viens aussi ?
Joël : Non, je ne peux pas. Désolé. La route est longue.
Aline : Une autre fois, alors. Merci, Rose.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa accepte l'invitation.",
  "correct": true,
  "explanation": "Léa : « Oui, avec plaisir. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi Joël refuse-t-il ?",
  "options": [
    {
      "text": "Il n'aime pas danser",
      "correct": false
    },
    {
      "text": "La route est longue",
      "correct": true
    },
    {
      "text": "Il est à l'accueil",
      "correct": false
    },
    {
      "text": "Il n'a pas le temps",
      "correct": false
    }
  ],
  "explanation": "Joël : « La route est longue. »"
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
      "left": "tu veux venir",
      "right": "invitation"
    },
    {
      "left": "avec plaisir",
      "right": "oui"
    },
    {
      "left": "d'accord",
      "right": "oui simple"
    },
    {
      "left": "je ne peux pas",
      "right": "non poli"
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
  "prompt": "Complétez :\nOui, avec ___.",
  "answer": "plaisir"
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
    "veux",
    "venir",
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
  "word": "plaisir",
  "hint": "Oui, avec… : un oui chaleureux."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ne peut pas.",
  "correct_sentence": "Je ne peux pas.",
  "explanation": "Je peux (avec x)."
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
      "image_path": "/elearning/mfk-a1-m5/invitation.svg",
      "word": "une invitation"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/daccord.svg",
      "word": "d'accord"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/refuse.svg",
      "word": "refuser"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/salle.svg",
      "word": "la salle"
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
  "prompt": "Notez : la question de Rose, la réponse de Léa, la réponse de Joël."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Tu veux venir ce soir ? Oui, avec plaisir. Non, je ne peux pas. Désolé."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Billets d''invitation',
    'CE',
    $c$Objectif
Lire des billets pour inviter, accepter ou refuser.

Consigne
Lisez les billets près du thé.

Support — Billets
1. Rose → Léa — Tu veux venir à la Salle des Herbes ce soir, à 19 h ?
2. Léa → Rose — Oui, avec plaisir. À tout à l'heure.
3. Rose → Joël — Tu viens aussi ?
4. Joël → Rose — Non, je ne peux pas. Désolé. Une autre fois.
5. Aline — Merci. On se retrouve sous le fil, demain.
Règle du Seuil : un oui clair, ou un non poli.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël écrit « avec plaisir ».",
  "correct": false,
  "explanation": "Joël refuse : « je ne peux pas »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle formule Léa utilise-t-elle pour accepter ?",
  "options": [
    {
      "text": "D'accord seulement",
      "correct": false
    },
    {
      "text": "Oui, avec plaisir",
      "correct": true
    },
    {
      "text": "Je ne peux pas",
      "correct": false
    },
    {
      "text": "Une autre fois",
      "correct": false
    }
  ],
  "explanation": "Billet 2 : « Oui, avec plaisir. »"
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
      "left": "tu veux",
      "right": "inviter"
    },
    {
      "left": "avec plaisir",
      "right": "accepter"
    },
    {
      "left": "je ne peux pas",
      "right": "refuser"
    },
    {
      "left": "une autre fois",
      "right": "plus tard"
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
  "prompt": "Complétez :\nNon, je ne ___ pas.",
  "answer": "peux"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "À",
    "tout",
    "à",
    "l'heure",
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
  "word": "désolé",
  "hint": "Le mot de Joël, pour refuser poliment (masculin)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Non je ne peux pas. Désoler.",
  "correct_sentence": "Non je ne peux pas. Désolé.",
  "explanation": "Désolé est un adjectif (pas un verbe)."
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
      "image_path": "/elearning/mfk-a1-m5/invitation.svg",
      "word": "une invitation"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/daccord.svg",
      "word": "d'accord"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/refuse.svg",
      "word": "refuser"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/the.svg",
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
  "prompt": "Recopiez un oui et un non. Ajoutez votre billet : tu veux… ? + réponse."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les cinq billets, puis la règle du Seuil."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Inviter, dire oui, dire non',
    'PO',
    $c$Objectif
Inviter et répondre : tu veux… ?, d'accord, avec plaisir, je ne peux pas.

Consigne
Répétez, puis invitez un camarade.

Support — Modèles de Rose
Tu veux venir ce soir ?
Tu viens à la salle ?
Oui, avec plaisir.
D'accord.
À quelle heure ?
Non, je ne peux pas.
Désolé. / Désolée.
Une autre fois.
Merci.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Désolée » s'accorde au féminin.",
  "correct": true,
  "explanation": "Désolé / désolée."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase refuse poliment ?",
  "options": [
    {
      "text": "Oui, avec plaisir",
      "correct": false
    },
    {
      "text": "D'accord",
      "correct": false
    },
    {
      "text": "Non, je ne peux pas",
      "correct": true
    },
    {
      "text": "Tu veux venir",
      "correct": false
    }
  ],
  "explanation": "Je ne peux pas = refus."
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
      "left": "tu veux",
      "right": "question"
    },
    {
      "left": "avec plaisir",
      "right": "oui chaleureux"
    },
    {
      "left": "d'accord",
      "right": "oui simple"
    },
    {
      "left": "une autre fois",
      "right": "pas maintenant"
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
  "prompt": "Complétez :\nTu ___ venir ce soir ?",
  "answer": "veux"
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
    "autre",
    "fois",
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
  "word": "peux",
  "hint": "Je ne… pas : refuser."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tu veut venir ce soir ?",
  "correct_sentence": "Tu veux venir ce soir ?",
  "explanation": "Tu veux (avec x)."
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
      "image_path": "/elearning/mfk-a1-m5/invitation.svg",
      "word": "une invitation"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/daccord.svg",
      "word": "d'accord"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/refuse.svg",
      "word": "refuser"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/soir.svg",
      "word": "le soir"
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
  "prompt": "Écrivez un mini-dialogue de six répliques : inviter, heure, oui, non, merci."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis une invitation et deux réponses (oui et non)."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Un billet aller-retour',
    'PE',
    $c$Objectif
Écrire une invitation et une réponse.

Consigne
Imitez le billet de Rose, puis la réponse de Léa.

Support — Deux billets
Rose
Léa, tu veux venir à la salle ce soir, à dix-neuf heures ?
Rose

Léa
Oui, avec plaisir. D'accord. À tout à l'heure.
Léa
Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa refuse.",
  "correct": false,
  "explanation": "Elle écrit : « Oui, avec plaisir. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À quelle heure Rose propose-t-elle de se voir ?",
  "options": [
    {
      "text": "À midi",
      "correct": false
    },
    {
      "text": "À seize heures",
      "correct": false
    },
    {
      "text": "À dix-neuf heures",
      "correct": true
    },
    {
      "text": "À minuit",
      "correct": false
    }
  ],
  "explanation": "« à dix-neuf heures »."
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
      "left": "tu veux venir",
      "right": "Rose"
    },
    {
      "left": "avec plaisir",
      "right": "Léa"
    },
    {
      "left": "dix-neuf heures",
      "right": "horaire"
    },
    {
      "left": "à tout à l'heure",
      "right": "bientôt"
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
  "prompt": "Complétez :\n___ , avec plaisir.",
  "answer": "Oui"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Oui",
    "avec",
    "plaisir",
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
  "word": "venir",
  "hint": "Tu veux… à la salle : le verbe de l'invitation."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tu veux de venir à la salle ?",
  "correct_sentence": "Tu veux venir à la salle ?",
  "explanation": "Tu veux + verbe à l'infinitif, sans de."
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
      "image_path": "/elearning/mfk-a1-m5/invitation.svg",
      "word": "une invitation"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/daccord.svg",
      "word": "d'accord"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/salle.svg",
      "word": "la salle"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/carte.svg",
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
  "prompt": "Écrivez deux billets : une invitation (heure + lieu) et un oui ou un non poli."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les deux billets, comme un aller-retour."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Tu veux, d''accord, je ne peux pas',
    'EL',
    $c$Objectif
Retenir les formules pour inviter, accepter et refuser.

Consigne
Apprenez la fiche, puis jouez une rencontre.

Support — Fiche de Rose
Inviter : Tu veux… ? Tu viens… ? On va… ?
Accepter : Oui. D'accord. Avec plaisir.
Demander l'heure : À quelle heure ?
Refuser : Non, je ne peux pas. Désolé / Désolée.
Reporter : Une autre fois.
Remercier : Merci.
Attention : je peux / tu peux / il peut.
On ne dit pas « je ne peut pas ».
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je ne peut pas ».",
  "correct": false,
  "explanation": "Je ne peux pas."
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
      "text": "il peux",
      "correct": false
    },
    {
      "text": "il peut",
      "correct": true
    },
    {
      "text": "il peuts",
      "correct": false
    },
    {
      "text": "il pouvois",
      "correct": false
    }
  ],
  "explanation": "Il / elle peut."
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
      "left": "tu veux",
      "right": "inviter"
    },
    {
      "left": "d'accord",
      "right": "accepter"
    },
    {
      "left": "je ne peux pas",
      "right": "refuser"
    },
    {
      "left": "merci",
      "right": "remercier"
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
  "prompt": "Complétez :\nIl ne ___ pas venir.",
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
    "Merci",
    "Rose",
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
  "word": "merci",
  "hint": "Le petit mot à la fin, pour Rose ou pour Léa."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il ne peux pas venir.",
  "correct_sentence": "Il ne peut pas venir.",
  "explanation": "Il / elle peut (avec t)."
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
      "image_path": "/elearning/mfk-a1-m5/invitation.svg",
      "word": "une invitation"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/daccord.svg",
      "word": "d'accord"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/refuse.svg",
      "word": "refuser"
    },
    {
      "image_path": "/elearning/mfk-a1-m5/fil.svg",
      "word": "le fil"
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
  "prompt": "Recopiez la fiche. Écrivez un oui et un non, avec une invitation."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : tu veux venir ? oui, avec plaisir ; non, je ne peux pas ; une autre fois ; merci."
}$j$::jsonb,
    9
  );

END;
$$;
