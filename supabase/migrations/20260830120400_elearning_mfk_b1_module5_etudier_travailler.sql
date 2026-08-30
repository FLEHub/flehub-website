/*
  Seed eLearning MFK — B1 — Étudier et travailler autrement

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b1-m5/
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
  v_module_title text := 'B1 — Étudier et travailler autrement';
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
      'Grande étape B1-5 : dire son parcours, se préparer à l''entretien, oser une expérience, raconter une journée de métier, vivre un stage à Radio Figuier et faire le bilan — Patrick et Joël cherchent leur voie, Léa rejoint l''antenne, Dieudonné ouvre l''Atelier du Tissu, Aline prépare les entretiens, au Seuil des Sources (Rukiri-Nord).',
      'B1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B1-5 : dire son parcours, se préparer à l''entretien, oser une expérience, raconter une journée de métier, vivre un stage à Radio Figuier et faire le bilan — Patrick et Joël cherchent leur voie, Léa rejoint l''antenne, Dieudonné ouvre l''Atelier du Tissu, Aline prépare les entretiens, au Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'B1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Dire son parcours =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Dire son parcours'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Dire son parcours', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Parcours sous le figuier',
    'CO',
    $c$Objectif
Comprendre une motivation et les articulateurs d'une lettre.

Consigne
Lisez le dialogue. Quel parcours ? Quels articulateurs ?

Support — Banc du Seuil, lettres ouvertes
Patrick : Tout d'abord, je veux relire mon parcours avec Aline.
Joël : En effet, sans plan, la lettre part trop vite.
Léa : Par ailleurs, Radio Figuier attend une page claire, pas vingt.
Marc : De plus, il faut dire pourquoi on choisit ce lieu, pas un autre.
Hawa : Enfin, on clôt : dans l'attente de votre réponse.
Aline : Je vous prie de garder un ton calme, assez précis.
Dieudonné : Tout d'abord l'atelier, ensuite les sacs, enfin le relais.
Rose : En effet, Joël a déjà porté des seaux : cela compte.
Karim : Par ailleurs, Solange lira les lettres au Bureau des Escales.
Lila : De plus, un stage n'est pas un discours : une preuve suffit.
Félicie : Dans l'attente de votre réponse, la table reste ouverte jeudi.
Patrick : Je vous prie d'agréer, Madame, mes salutations attentives.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa clôt avec « dans l'attente de votre réponse ».",
  "correct": true,
  "explanation": "Hawa : « Enfin, on clôt : dans l'attente de votre réponse. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que demande Aline pour le ton ?",
  "options": [
    {
      "text": "Un ton extrêmement long",
      "correct": false
    },
    {
      "text": "Un ton calme, assez précis",
      "correct": true
    },
    {
      "text": "Un ton crié",
      "correct": false
    },
    {
      "text": "Aucun ton, seulement des chiffres",
      "correct": false
    }
  ],
  "explanation": "Aline : « un ton calme, assez précis. »"
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
      "left": "tout d'abord",
      "right": "ouverture"
    },
    {
      "left": "en effet",
      "right": "justification"
    },
    {
      "left": "par ailleurs / de plus",
      "right": "ajout"
    },
    {
      "left": "dans l'attente de",
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
  "prompt": "Complétez :\n___ d'abord, je veux relire mon parcours.",
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
    "En",
    "effet",
    "sans",
    "plan",
    "la",
    "lettre",
    "part",
    "trop",
    "vite",
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
  "word": "ailleurs",
  "hint": "Articulateur d'ajout : par…, Radio Figuier attend une page."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tout dabord je veux relire mon parcours avec Aline.",
  "correct_sentence": "Tout d'abord je veux relire mon parcours avec Aline.",
  "explanation": "Tout d'abord, avec apostrophe."
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
      "image_path": "/elearning/mfk-b1-m5/lettre-motivation.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/articulateur.svg",
      "word": "un articulateur"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/parcours-patrick.svg",
      "word": "un parcours"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/cv-joel.svg",
      "word": "un curriculum"
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
  "prompt": "Notez cinq articulateurs entendus et leur rôle (ouvrir, justifier, ajouter, clore)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Tout d'abord. En effet. Par ailleurs. De plus. Enfin. Dans l'attente de votre réponse."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Lettre de motivation de Patrick',
    'CE',
    $c$Objectif
Lire une lettre de parcours avec articulateurs.

Consigne
Lisez la lettre, sans aller trop vite.

Support — Lettre de Patrick Habimana
Patrick Habimana — Seuil des Sources, Rukiri-Nord
Madame Sow,
Tout d'abord, je vous écris pour le relais du matin à Radio Figuier.
En effet, j'ai déjà tenu le Cahier des racines et porté des seaux à la rive.
Par ailleurs, Joël peut confirmer ces gestes, sans discours trop long.
De plus, Aline m'a aidé à dire mon parcours en une page.
Enfin, je joins une feuille de dates, assez claire.
Dans l'attente de votre réponse, je reste joignable à la cour.
Je vous prie d'agréer, Madame, mes salutations attentives.
Patrick Habimana
Copie : Aline Uwase
Copie au Cahier des racines, sous le figuier.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick écrit à Madame Sow pour un relais à Radio Figuier.",
  "correct": true,
  "explanation": "« pour le relais du matin à Radio Figuier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui peut confirmer les gestes de Patrick ?",
  "options": [
    {
      "text": "Solange seule",
      "correct": false
    },
    {
      "text": "Joël",
      "correct": true
    },
    {
      "text": "Un minibus",
      "correct": false
    },
    {
      "text": "Félicie seulement",
      "correct": false
    }
  ],
  "explanation": "« Joël peut confirmer ces gestes. »"
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
      "left": "tout d'abord",
      "right": "je vous écris"
    },
    {
      "left": "en effet",
      "right": "Cahier et seaux"
    },
    {
      "left": "par ailleurs",
      "right": "Joël"
    },
    {
      "left": "je vous prie",
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
  "prompt": "Complétez :\n___ plus, Aline m'a aidé à dire mon parcours.",
  "answer": "De"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Dans",
    "l'attente",
    "de",
    "votre",
    "réponse",
    "je",
    "reste",
    "joignable",
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
  "word": "attente",
  "hint": "Formule de clôture : dans l'… de votre réponse."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je vous prie d'agréer Madame mes salutation attentives.",
  "correct_sentence": "Je vous prie d'agréer Madame mes salutations attentives.",
  "explanation": "Salutations au pluriel."
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
      "image_path": "/elearning/mfk-b1-m5/articulateur.svg",
      "word": "un articulateur"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/parcours-patrick.svg",
      "word": "un parcours"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/cv-joel.svg",
      "word": "un curriculum"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/entretien-conseil.svg",
      "word": "un entretien"
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
  "prompt": "Recopiez la lettre et encadrez les sept articulateurs de la séquence."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la lettre de Patrick, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Enchaîner une lettre',
    'PO',
    $c$Objectif
Dire un parcours avec tout d'abord, en effet, par ailleurs, de plus, enfin, clôture.

Consigne
Répétez, puis dites votre parcours en six étapes.

Support — Modèles de Joël
Tout d'abord, je me présente.
En effet, j'ai déjà porté des seaux.
Par ailleurs, l'atelier me connaît.
De plus, je sais relayer une heure.
Enfin, je joins une page.
Dans l'attente de votre réponse…
Je vous prie d'agréer mes salutations.
Je veux ce relais, pas un autre.
Mon parcours reste local.
Assez d'une page.
Pas trop de discours.
Aline m'écoute.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« En effet » sert à justifier, pas à conclure.",
  "correct": true,
  "explanation": "Justification après l'ouverture."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle formule clôt la lettre ?",
  "options": [
    {
      "text": "Tout d'abord",
      "correct": false
    },
    {
      "text": "Dans l'attente de votre réponse",
      "correct": true
    },
    {
      "text": "Par ailleurs",
      "correct": false
    },
    {
      "text": "De plus",
      "correct": false
    }
  ],
  "explanation": "Clôture : dans l'attente de…"
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
      "left": "tout d'abord",
      "right": "1"
    },
    {
      "left": "en effet",
      "right": "preuve"
    },
    {
      "left": "de plus",
      "right": "ajout"
    },
    {
      "left": "enfin",
      "right": "avant la clôture"
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
  "prompt": "Complétez :\nJe vous ___ d'agréer mes salutations.",
  "answer": "prie"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Tout",
    "d'abord",
    "je",
    "me",
    "présente",
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
  "word": "parcours",
  "hint": "Ce qu'on raconte dans la lettre : son… , pas vingt pages."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Par ailleur l'atelier me connaît déjà.",
  "correct_sentence": "Par ailleurs l'atelier me connaît déjà.",
  "explanation": "Ailleurs, avec s."
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
      "image_path": "/elearning/mfk-b1-m5/parcours-patrick.svg",
      "word": "un parcours"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/cv-joel.svg",
      "word": "un curriculum"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/entretien-conseil.svg",
      "word": "un entretien"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/porte-essai.svg",
      "word": "une porte"
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
  "prompt": "Écrivez six phrases orales, une par articulateur de la fiche."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis votre parcours en six étapes."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma lettre de parcours',
    'PE',
    $c$Objectif
Écrire une lettre de motivation avec les articulateurs.

Consigne
Imitez la lettre de Joël, sans aller trop vite.

Support — Lettre de Joël Mugisha
Joël Mugisha
Seuil des Sources, Rukiri-Nord
Madame Hakizimana,
Tout d'abord, je vous écris pour aider à l'Atelier du Tissu le matin.
En effet, j'ai déjà plié des sacs et porté des seaux à la rive.
Par ailleurs, Patrick peut confirmer ces heures.
De plus, Aline a relu cette page avec moi.
Enfin, je joins trois dates libres.
Dans l'attente de votre réponse, je reste à la cour.
Je vous prie d'agréer, Madame, mes salutations.
Joël
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël écrit à Madame Hakizimana pour l'atelier le matin.",
  "correct": true,
  "explanation": "« pour aider à l'Atelier du Tissu le matin. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que joint Joël à la fin ?",
  "options": [
    {
      "text": "Vingt pages",
      "correct": false
    },
    {
      "text": "Trois dates libres",
      "correct": true
    },
    {
      "text": "Un passeport",
      "correct": false
    },
    {
      "text": "Une cravate",
      "correct": false
    }
  ],
  "explanation": "« je joins trois dates libres. »"
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
      "left": "tout d'abord",
      "right": "l'atelier"
    },
    {
      "left": "en effet",
      "right": "sacs et seaux"
    },
    {
      "left": "par ailleurs",
      "right": "Patrick"
    },
    {
      "left": "dans l'attente de",
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
  "prompt": "Complétez :\n___ , je joins trois dates libres.",
  "answer": "Enfin"
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
    "vous",
    "prie",
    "d'agréer",
    "mes",
    "salutations",
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
  "word": "motivation",
  "hint": "La lettre dit pourquoi on veut ce relais : une… claire."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dans l'attente de votre reponse je reste à la cour trop vite.",
  "correct_sentence": "Dans l'attente de votre réponse je reste à la cour trop vite.",
  "explanation": "Réponse, avec accent."
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
      "image_path": "/elearning/mfk-b1-m5/cv-joel.svg",
      "word": "un curriculum"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/entretien-conseil.svg",
      "word": "un entretien"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/porte-essai.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/cravate-inventee.svg",
      "word": "une cravate"
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
  "prompt": "Imitez : une lettre de dix à douze lignes, sept articulateurs."
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
    'EL — Articulateurs de lettre',
    'EL',
    $c$Objectif
Retenir tout d'abord, en effet, par ailleurs, de plus, enfin, dans l'attente de, je vous prie.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
Ouverture : tout d'abord (apostrophe : d'abord).
Justification : en effet (on prouve, on explique).
Ajout : par ailleurs / de plus (une idée de plus, sans tout répéter).
Fin du développement : enfin.
Attente : dans l'attente de votre réponse / de votre lecture.
Clôture : je vous prie d'agréer… / je vous prie de + infinitif.
Parcours : ce que j'ai déjà fait, ici, au Seuil, assez d'une page.
Destinataires inventés : Madame Sow, Madame Hakizimana, Bureau des Escales.
Ne pas dire : tout dabord (sans apostrophe).
Ne pas dire : par ailleur (sans s).
Ne pas dire : je vous pries.
Ordre fréquent : tout d'abord → en effet → par ailleurs → de plus → enfin → attente → prie.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « je vous pries » à la clôture.",
  "correct": false,
  "explanation": "Je vous prie, sans s."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel articulateur justifie ?",
  "options": [
    {
      "text": "tout d'abord",
      "correct": false
    },
    {
      "text": "en effet",
      "correct": true
    },
    {
      "text": "enfin",
      "correct": false
    },
    {
      "text": "dans l'attente de",
      "correct": false
    }
  ],
  "explanation": "En effet = justification."
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
      "left": "tout d'abord",
      "right": "ouvrir"
    },
    {
      "left": "en effet",
      "right": "justifier"
    },
    {
      "left": "par ailleurs",
      "right": "ajouter"
    },
    {
      "left": "je vous prie",
      "right": "clore"
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
  "prompt": "Complétez :\nPar ___ , l'atelier me connaît.",
  "answer": "ailleurs"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Dans",
    "l'attente",
    "de",
    "votre",
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
  "word": "justifier",
  "hint": "Rôle de « en effet » : … ce qu'on vient de dire."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je vous pries d'agréer mes salutations attentives.",
  "correct_sentence": "Je vous prie d'agréer mes salutations attentives.",
  "explanation": "Je vous prie, 1re personne, sans s."
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
      "image_path": "/elearning/mfk-b1-m5/entretien-conseil.svg",
      "word": "un entretien"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/porte-essai.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/cravate-inventee.svg",
      "word": "une cravate"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/notes-aline.svg",
      "word": "une note"
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
  "prompt": "Rédigez une mini-lettre de huit lignes en suivant l'ordre de la fiche."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et les sept articulateurs."
}$j$::jsonb,
    9
  );

  -- ===== Se préparer à l'entretien =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Se préparer à l''entretien'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Se préparer à l''entretien', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Aline prépare l''entretien',
    'CO',
    $c$Objectif
Repérer les conseils d'embauche : vous devriez, il vaudrait mieux, évitez de.

Consigne
Lisez le dialogue. Quels conseils ? Quels pièges ?

Support — Salle des Herbes, notes d'Aline
Aline : Vous devriez arriver dix minutes avant, pas trop tôt non plus.
Patrick : Il vaudrait mieux préparer deux exemples, assez clairs.
Joël : Évitez de parler trop vite : une phrase, une pause.
Léa : Vous devriez écouter la question jusqu'au bout.
Marc : Il vaudrait mieux regarder la personne, pas seulement la feuille.
Hawa : Évitez de critiquer un ancien relais.
Dieudonné : Vous devriez montrer un sac, un geste, une heure tenue.
Rose : Il vaudrait mieux saluer Solange si elle passe.
Karim : Évitez d'inventer une ville ou une enseigne.
Lila : Vous devriez répéter votre ouverture, pas tout le discours.
Félicie : Il vaudrait mieux remercier, même si la réponse attend.
Aline : Évitez de dire « je sais tout » : nuancez.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël conseille d'éviter de parler trop vite.",
  "correct": true,
  "explanation": "Joël : « Évitez de parler trop vite. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien d'exemples Patrick devrait-il préparer ?",
  "options": [
    {
      "text": "Aucun",
      "correct": false
    },
    {
      "text": "Deux",
      "correct": true
    },
    {
      "text": "Vingt",
      "correct": false
    },
    {
      "text": "Un seul mot",
      "correct": false
    }
  ],
  "explanation": "« deux exemples, assez clairs. »"
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
      "left": "vous devriez",
      "right": "conseil poli"
    },
    {
      "left": "il vaudrait mieux",
      "right": "conseil plus net"
    },
    {
      "left": "évitez de",
      "right": "interdit doux"
    },
    {
      "left": "dix minutes avant",
      "right": "horaire"
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
  "prompt": "Complétez :\n___ de parler trop vite.",
  "answer": "Évitez"
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
    "devriez",
    "arriver",
    "dix",
    "minutes",
    "avant",
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
  "word": "devriez",
  "hint": "Conseil à vous : vous… écouter jusqu'au bout."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Évitez de inventer une ville ou une enseigne.",
  "correct_sentence": "Évitez d'inventer une ville ou une enseigne.",
  "explanation": "Éviter d' + voyelle."
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
      "image_path": "/elearning/mfk-b1-m5/porte-essai.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/cravate-inventee.svg",
      "word": "une cravate"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/notes-aline.svg",
      "word": "une note"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/prise-risque.svg",
      "word": "un risque"
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
  "prompt": "Classez six conseils : devriez / vaudrait mieux / évitez de."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Vous devriez arriver avant. Il vaudrait mieux préparer deux exemples. Évitez de parler trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fiche conseils d''Aline',
    'CE',
    $c$Objectif
Lire une fiche d'entretien avec vous devriez, il vaudrait mieux, évitez de.

Consigne
Lisez la fiche, sans aller trop vite.

Support — Fiche d'Aline Uwase
Entretien au Seuil — conseils
1. Vous devriez saluer, puis attendre qu'on vous offre le banc.
2. Il vaudrait mieux dire votre parcours en huit phrases, pas plus.
3. Évitez de lire toute la lettre à voix haute.
4. Vous devriez donner un exemple tenu : un seau, un sac, une heure.
5. Il vaudrait mieux poser une question à la fin.
6. Évitez d'interrompre Lila ou Dieudonné.
7. Vous devriez remercier, même si on vous dit « on écrit ».
8. Il vaudrait mieux un vêtement simple qu'une cravate trop inventée.
9. Évitez de promettre ce que la cour ne peut pas tenir.
10. Vous devriez arriver par le figuier, assez calmes.
11. Karim : il vaudrait mieux un dossier d'une page.
12. Solange : évitez de taper trop fort à la porte du Bureau.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline recommande de lire toute la lettre à voix haute.",
  "correct": false,
  "explanation": "Point 3 : « Évitez de lire toute la lettre. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que vaut-il mieux faire à la fin ?",
  "options": [
    {
      "text": "Partir sans un mot",
      "correct": false
    },
    {
      "text": "Poser une question",
      "correct": true
    },
    {
      "text": "Crier un chiffre",
      "correct": false
    },
    {
      "text": "Signer pour les autres",
      "correct": false
    }
  ],
  "explanation": "« poser une question à la fin. »"
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
      "left": "vous devriez saluer",
      "right": "ouverture"
    },
    {
      "left": "il vaudrait mieux dire",
      "right": "huit phrases"
    },
    {
      "left": "évitez de lire",
      "right": "toute la lettre"
    },
    {
      "left": "évitez d'interrompre",
      "right": "Lila ou Dieudonné"
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
  "prompt": "Complétez :\nIl vaudrait mieux poser une ___ à la fin.",
  "answer": "question"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Évitez",
    "de",
    "promettre",
    "ce",
    "que",
    "la",
    "cour",
    "ne",
    "peut",
    "pas",
    "tenir",
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
  "word": "interrompre",
  "hint": "Évitez d'… Lila : laissez-la finir sa phrase."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Évitez de interrompre Lila ou Dieudonné pendant l'entretien.",
  "correct_sentence": "Évitez d'interrompre Lila ou Dieudonné pendant l'entretien.",
  "explanation": "D'interrompre, élision."
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
      "image_path": "/elearning/mfk-b1-m5/cravate-inventee.svg",
      "word": "une cravate"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/notes-aline.svg",
      "word": "une note"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/prise-risque.svg",
      "word": "un risque"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/experience-valoriser.svg",
      "word": "une expérience"
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
  "prompt": "Recopiez la fiche et ajoutez deux conseils à vous, avec les mêmes formules."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les douze points, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Conseiller pour l''entretien',
    'PO',
    $c$Objectif
Donner des conseils d'embauche à voix haute.

Consigne
Répétez, puis conseillez Patrick ou Léa.

Support — Modèles d'Aline
Vous devriez arriver un peu avant.
Vous devriez écouter jusqu'au bout.
Il vaudrait mieux deux exemples.
Il vaudrait mieux une question à la fin.
Évitez de parler trop vite.
Évitez d'inventer un lieu.
Vous devriez remercier.
Il vaudrait mieux une page.
Évitez de tout promettre.
Saluez.
Attendez le banc.
Restez clairs.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Évitez de » + infinitif exprime un conseil négatif.",
  "correct": true,
  "explanation": "Évitez de parler trop vite."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est correcte devant une voyelle ?",
  "options": [
    {
      "text": "évitez de inventer",
      "correct": false
    },
    {
      "text": "évitez d'inventer",
      "correct": true
    },
    {
      "text": "évitez inventer",
      "correct": false
    },
    {
      "text": "évitez que inventer",
      "correct": false
    }
  ],
  "explanation": "Éviter d' + voyelle."
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
      "left": "vous devriez",
      "right": "vous / devoir au conditionnel"
    },
    {
      "left": "il vaudrait mieux",
      "right": "conseil net"
    },
    {
      "left": "évitez de",
      "right": "ne pas faire"
    },
    {
      "left": "évitez d'",
      "right": "devant voyelle"
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
  "prompt": "Complétez :\nVous ___ écouter jusqu'au bout.",
  "answer": "devriez"
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
    "deux",
    "exemples",
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
  "word": "exemples",
  "hint": "Il vaudrait mieux en préparer deux, assez clairs."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il vaudrait mieux de préparer deux exemples assez clairs.",
  "correct_sentence": "Il vaudrait mieux préparer deux exemples assez clairs.",
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
      "image_path": "/elearning/mfk-b1-m5/notes-aline.svg",
      "word": "une note"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/prise-risque.svg",
      "word": "un risque"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/experience-valoriser.svg",
      "word": "une expérience"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/nuage-oser.svg",
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
  "prompt": "Écrivez six conseils : deux de chaque formule."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis trois conseils à Patrick."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mes conseils d''entretien',
    'PE',
    $c$Objectif
Écrire une fiche de conseils pour un entretien au Seuil.

Consigne
Imitez la fiche de Léa, sans aller trop vite.

Support — Fiche de Léa Niyonzima
Léa Niyonzima
Vous devriez arriver par le figuier, assez calmes.
Il vaudrait mieux préparer deux exemples tenus.
Évitez de parler trop vite : une phrase, une pause.
Vous devriez écouter Lila jusqu'au bout.
Il vaudrait mieux poser une question à la fin.
Évitez d'inventer une enseigne ou une ville.
Vous devriez remercier, même si la réponse attend.
Léa
Radio Figuier — notes d'entretien
Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa demande d'inventer une enseigne.",
  "correct": false,
  "explanation": "« Évitez d'inventer une enseigne ou une ville. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Par où Léa dit-elle d'arriver ?",
  "options": [
    {
      "text": "Par le marché seulement",
      "correct": false
    },
    {
      "text": "Par le figuier",
      "correct": true
    },
    {
      "text": "Par un minibus de ville",
      "correct": false
    },
    {
      "text": "Par la rivière à minuit",
      "correct": false
    }
  ],
  "explanation": "« arriver par le figuier. »"
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
      "left": "vous devriez arriver",
      "right": "figuier"
    },
    {
      "left": "il vaudrait mieux préparer",
      "right": "deux exemples"
    },
    {
      "left": "évitez de parler",
      "right": "trop vite"
    },
    {
      "left": "évitez d'inventer",
      "right": "enseigne"
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
  "prompt": "Complétez :\nÉvitez ___ parler trop vite.",
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
    "Vous",
    "devriez",
    "remercier",
    "même",
    "si",
    "la",
    "réponse",
    "attend",
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
  "word": "remercier",
  "hint": "Vous devriez… même si la réponse attend."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Évitez de parler trop vite une phrase une pause trop longues.",
  "correct_sentence": "Évitez de parler trop vite une phrase une pause trop longue.",
  "explanation": "Une pause trop longue, accord avec pause."
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
      "image_path": "/elearning/mfk-b1-m5/prise-risque.svg",
      "word": "un risque"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/experience-valoriser.svg",
      "word": "une expérience"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/nuage-oser.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/badge-stage.svg",
      "word": "un badge"
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
  "prompt": "Imitez : dix lignes, trois formules de conseil, deux exemples du Seuil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre fiche, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Conseils d''embauche',
    'EL',
    $c$Objectif
Retenir vous devriez, il vaudrait mieux, évitez de.

Consigne
Apprenez la fiche.

Support — Fiche de l'entretien
Vous devriez + infinitif : devoir au conditionnel, conseil poli.
Il vaudrait mieux + infinitif : conseil plus net, sans de.
Il vaudrait mieux que + subjonctif : autre sujet (qu'il écoute).
Évitez de + infinitif : conseil négatif.
Évitez d' + voyelle : évitez d'inventer, évitez d'interrompre.
Pièges au Seuil : parler trop vite, tout promettre, inventer un lieu réel,
lire toute la lettre, une cravate trop inventée, taper trop fort.
Gestes utiles : saluer, attendre le banc, deux exemples, une question, remercier.
Ne pas dire : vous devez de arriver.
Ne pas dire : il vaudrait mieux de + infinitif.
Ne pas dire : évitez de + voyelle sans élision.
Conditionnel : je devrais, tu devrais, il devrait, nous devrions, vous devriez.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Évitez d'interrompre » est la forme devant voyelle.",
  "correct": true,
  "explanation": "Élision : d'interrompre."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série est correcte ?",
  "options": [
    {
      "text": "vous devez de / évitez de inventer",
      "correct": false
    },
    {
      "text": "vous devriez / évitez d'inventer",
      "correct": true
    },
    {
      "text": "vous devriez de / évitez inventer",
      "correct": false
    },
    {
      "text": "il faut de / évitez que inventer",
      "correct": false
    }
  ],
  "explanation": "Devriez + infinitif ; évitez d' + voyelle."
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
      "left": "vous devriez",
      "right": "conseil"
    },
    {
      "left": "il vaudrait mieux",
      "right": "conseil net"
    },
    {
      "left": "évitez de",
      "right": "négatif"
    },
    {
      "left": "évitez d'",
      "right": "voyelle"
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
  "prompt": "Complétez :\nÉvitez ___ interrompre Lila.",
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
    "Vous",
    "devriez",
    "saluer",
    "puis",
    "attendre",
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
  "word": "conditionnel",
  "hint": "Devriez et vaudrait : un temps pour conseiller, le…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Vous devriez de arriver dix minutes avant l'entretien.",
  "correct_sentence": "Vous devriez arriver dix minutes avant l'entretien.",
  "explanation": "Devriez + infinitif, sans de."
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
      "image_path": "/elearning/mfk-b1-m5/experience-valoriser.svg",
      "word": "une expérience"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/nuage-oser.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/badge-stage.svg",
      "word": "un badge"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/gerondif-metier.svg",
      "word": "un gérondif"
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
  "prompt": "Conjuguez devoir au conditionnel et écrivez trois évitez de / d'."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six conseils."
}$j$::jsonb,
    9
  );

  -- ===== Oser une expérience =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Oser une expérience'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Oser une expérience', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Oser sous le figuier',
    'CO',
    $c$Objectif
Comprendre une prise de risque et sa valorisation : j'ai appris à, cela m'a permis de.

Consigne
Lisez le dialogue. Qui a osé ? Qu'a-t-il appris ?

Support — Cour du Seuil, après un essai
Joël : J'ai osé porter les seaux trop lourds : j'ai appris à demander de l'aide.
Patrick : Cela m'a permis de parler moins vite au Bureau.
Léa : J'ai osé le micro : j'ai appris à respirer avant la phrase.
Dieudonné : Oser l'atelier, cela m'a permis de montrer un sac fini.
Aline : Valorisez le risque : pas « j'ai échoué », « j'ai appris à… ».
Marc : J'ai appris à écouter Lila jusqu'au bout.
Hawa : Cela m'a permis de nuancer, pas de tout promettre.
Rose : J'ai osé signer la première : j'ai appris à tenir une heure.
Karim : Cela m'a permis de relire la lettre sans trembler.
Lila : J'ai appris à couper un discours trop long.
Félicie : Oser la table un jour de foule, cela m'a permis de ranger plus tôt.
Solange : Le Bureau aime un risque raconté, pas un risque caché.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline veut qu'on valorise le risque par « j'ai appris à ».",
  "correct": true,
  "explanation": "Aline : pas « j'ai échoué », « j'ai appris à… »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qu'a permis à Patrick de parler moins vite ?",
  "options": [
    {
      "text": "Un voyage dans une grande ville",
      "correct": false
    },
    {
      "text": "L'expérience racontée ici",
      "correct": true
    },
    {
      "text": "Une cravate",
      "correct": false
    },
    {
      "text": "Fermer Radio Figuier",
      "correct": false
    }
  ],
  "explanation": "« Cela m'a permis de parler moins vite. »"
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
      "left": "j'ai osé",
      "right": "prise de risque"
    },
    {
      "left": "j'ai appris à",
      "right": "compétence"
    },
    {
      "left": "cela m'a permis de",
      "right": "résultat"
    },
    {
      "left": "valoriser",
      "right": "dire l'apport"
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
  "prompt": "Complétez :\nJ'ai ___ à demander de l'aide.",
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
    "Cela",
    "m'a",
    "permis",
    "de",
    "parler",
    "moins",
    "vite",
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
  "word": "oser",
  "hint": "Prendre un risque utile : … le micro, l'atelier, la table."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai appris de demander de l'aide trop vite.",
  "correct_sentence": "J'ai appris à demander de l'aide trop vite.",
  "explanation": "Apprendre à + infinitif."
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
      "image_path": "/elearning/mfk-b1-m5/nuage-oser.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/badge-stage.svg",
      "word": "un badge"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/gerondif-metier.svg",
      "word": "un gérondif"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/participe-present.svg",
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
  "prompt": "Notez trois risques et, pour chacun, j'ai appris à / cela m'a permis de."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : J'ai osé. J'ai appris à demander. Cela m'a permis de parler moins vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Portraits d''expériences',
    'CE',
    $c$Objectif
Lire des portraits qui valorisent une prise de risque.

Consigne
Lisez les portraits, sans aller trop vite.

Support — Mur de la Maison des Vents
Portrait Joël : j'ai osé le compost trop tôt ; j'ai appris à commencer petit.
Portrait Patrick : oser la lettre, cela m'a permis de classer mon parcours.
Portrait Léa : j'ai osé le premier micro ; j'ai appris à dire une phrase, puis à taire.
Portrait Dieudonné : oser un sac trop large, cela m'a permis de recoudre un fond.
Portrait Aline : valorisez : j'ai appris à / cela m'a permis de, pas seulement j'ai raté.
Portrait Marc : j'ai appris à filmer sans parler par-dessus Lila.
Portrait Hawa : cela m'a permis de mesurer l'eau, de moins en moins gaspiller.
Portrait Rose : j'ai osé le premier nom du Cahier ; j'ai appris à relayer.
Portrait Lila : oser une heure d'antenne trop calme, cela m'a permis d'écouter la cour.
Portrait Félicie : j'ai appris à ouvrir la table sans tout poser d'un coup.
Portrait Karim : cela m'a permis de porter un dossier d'une page.
Portrait Solange : le Bureau lit les risques dits, pas les risques cachés.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné a appris, en osant un sac trop large, à recoudre un fond.",
  "correct": true,
  "explanation": "« cela m'a permis de recoudre un fond. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que valorise Aline, d'après le mur ?",
  "options": [
    {
      "text": "Seulement « j'ai raté »",
      "correct": false
    },
    {
      "text": "J'ai appris à / cela m'a permis de",
      "correct": true
    },
    {
      "text": "Inventer une ville",
      "correct": false
    },
    {
      "text": "Cacher le risque",
      "correct": false
    }
  ],
  "explanation": "Portrait Aline : valorisez ces deux formules."
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
      "left": "Joël",
      "right": "commencer petit"
    },
    {
      "left": "Léa",
      "right": "une phrase puis taire"
    },
    {
      "left": "Dieudonné",
      "right": "recoudre un fond"
    },
    {
      "left": "Lila",
      "right": "écouter la cour"
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
  "prompt": "Complétez :\nOser la lettre, cela m'a ___ de classer mon parcours.",
  "answer": "permis"
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
    "à",
    "commencer",
    "petit",
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
  "word": "valoriser",
  "hint": "Transformer un risque en compétence : … l'expérience."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Cela m'a permis à classer mon parcours trop vite.",
  "correct_sentence": "Cela m'a permis de classer mon parcours trop vite.",
  "explanation": "Permettre de + infinitif."
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
      "image_path": "/elearning/mfk-b1-m5/badge-stage.svg",
      "word": "un badge"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/gerondif-metier.svg",
      "word": "un gérondif"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/participe-present.svg",
      "word": "un participe"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/pronom-ou.svg",
      "word": "un pronom"
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
  "prompt": "Choisissez trois portraits et réécrivez-les à la 1re personne."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les douze portraits, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Valoriser un risque',
    'PO',
    $c$Objectif
Raconter une expérience osée et la valoriser.

Consigne
Répétez, puis valorisez un geste à vous.

Support — Modèles de Patrick
J'ai osé écrire.
J'ai appris à classer.
Cela m'a permis de parler moins vite.
J'ai osé le micro.
J'ai appris à respirer.
Cela m'a permis d'écouter.
J'ai osé l'atelier.
J'ai appris à recoudre.
Cela m'a permis de montrer un sac.
Je ne dis pas seulement « j'ai raté ».
Je valorise.
Je nuance.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Cela m'a permis de » introduit un résultat.",
  "correct": true,
  "explanation": "Résultat de l'expérience."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle construction est correcte ?",
  "options": [
    {
      "text": "j'ai appris de classer",
      "correct": false
    },
    {
      "text": "j'ai appris à classer",
      "correct": true
    },
    {
      "text": "cela m'a permis à classer",
      "correct": false
    },
    {
      "text": "j'ai appris classer",
      "correct": false
    }
  ],
  "explanation": "Apprendre à + infinitif."
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
      "left": "j'ai osé",
      "right": "risque"
    },
    {
      "left": "j'ai appris à",
      "right": "geste appris"
    },
    {
      "left": "cela m'a permis de",
      "right": "résultat"
    },
    {
      "left": "valoriser",
      "right": "dire l'apport"
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
  "prompt": "Complétez :\nCela m'a permis ___ parler moins vite.",
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
    "J'ai",
    "osé",
    "le",
    "micro",
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
  "word": "respirer",
  "hint": "Léa a appris à… avant la phrase au micro."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai appris à classer cela m'a permis à parler moins vite.",
  "correct_sentence": "J'ai appris à classer cela m'a permis de parler moins vite.",
  "explanation": "Permis de, pas permis à."
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
      "image_path": "/elearning/mfk-b1-m5/gerondif-metier.svg",
      "word": "un gérondif"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/participe-present.svg",
      "word": "un participe"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/pronom-ou.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/horloge-journee.svg",
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
  "prompt": "Écrivez six phrases : deux osé, deux appris à, deux permis de."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis une expérience à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon expérience osée',
    'PE',
    $c$Objectif
Écrire un portrait qui valorise une prise de risque.

Consigne
Imitez le portrait de Dieudonné, sans aller trop vite.

Support — Portrait de Dieudonné Hakizimana
Dieudonné Hakizimana
J'ai osé un sac trop large pour la rive.
J'ai appris à recoudre un fond solide.
Cela m'a permis de montrer un geste fini à Joël.
J'ai osé dire non à trop de tissu perdu.
J'ai appris à commencer par trois sacs.
Cela m'a permis de tenir l'heure du matin.
Je valorise : pas seulement « j'ai raté ».
Dieudonné
Atelier du Tissu
Seuil des Sources — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné a appris à commencer par trois sacs.",
  "correct": true,
  "explanation": "« J'ai appris à commencer par trois sacs. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À qui a-t-il montré un geste fini ?",
  "options": [
    {
      "text": "Solange",
      "correct": false
    },
    {
      "text": "Joël",
      "correct": true
    },
    {
      "text": "Lila",
      "correct": false
    },
    {
      "text": "Un minibus",
      "correct": false
    }
  ],
  "explanation": "« à Joël. »"
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
      "left": "osé un sac trop large",
      "right": "risque"
    },
    {
      "left": "appris à recoudre",
      "right": "geste"
    },
    {
      "left": "permis de montrer",
      "right": "résultat"
    },
    {
      "left": "commencer par trois",
      "right": "mesure"
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
  "prompt": "Complétez :\nJ'ai appris ___ recoudre un fond solide.",
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
    "Cela",
    "m'a",
    "permis",
    "de",
    "tenir",
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
  "word": "recoudre",
  "hint": "Dieudonné a appris à… un fond trop faible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai appris à recoudre un fond solide trop solides.",
  "correct_sentence": "J'ai appris à recoudre un fond solide trop solide.",
  "explanation": "Fond est masculin singulier : solide."
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
      "image_path": "/elearning/mfk-b1-m5/participe-present.svg",
      "word": "un participe"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/pronom-ou.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/horloge-journee.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/stage-radio.svg",
      "word": "un stage"
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
  "prompt": "Imitez : dix lignes, deux risques, deux j'ai appris à, deux cela m'a permis de."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre portrait, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Valoriser une expérience',
    'EL',
    $c$Objectif
Retenir j'ai osé, j'ai appris à, cela m'a permis de.

Consigne
Apprenez la fiche.

Support — Fiche du risque utile
Prise de risque : j'ai osé + nom / infinitif (j'ai osé le micro / oser écrire).
Compétence : j'ai appris à + infinitif (pas apprendre de + infinitif ici).
Résultat : cela m'a permis de + infinitif (pas permis à + infinitif).
Devant voyelle : cela m'a permis d'écouter.
Valoriser : transformer l'échec apparent en apport (j'ai appris à demander).
Ne pas rester à « j'ai raté » seul.
Exemples du Seuil : seaux trop lourds, sac trop large, premier micro, lettre,
table un jour de foule, heure d'antenne trop calme.
Accord : j'ai appris (invariable ici) ; cela (neutre) m'a permis.
Ne pas dire : j'ai appris de + infinitif (sens « on m'a dit » est autre).
Ne pas dire : cela m'a permis à.
On peut relier : en osant X, j'ai appris à Y.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « cela m'a permis à classer ».",
  "correct": false,
  "explanation": "Permis de + infinitif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Cela m'a permis ___ écouter. »",
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
      "text": "à",
      "correct": false
    },
    {
      "text": "pour",
      "correct": false
    }
  ],
  "explanation": "Devant voyelle : d'écouter."
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
      "left": "j'ai osé",
      "right": "risque"
    },
    {
      "left": "j'ai appris à",
      "right": "compétence"
    },
    {
      "left": "cela m'a permis de",
      "right": "résultat"
    },
    {
      "left": "valoriser",
      "right": "dire l'apport"
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
  "prompt": "Complétez :\nCela m'a permis ___ écouter la cour.",
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
    "J'ai",
    "appris",
    "à",
    "demander",
    "de",
    "l'aide",
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
  "word": "competence",
  "hint": "Ce qu'on a appris à faire. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En osant le micro j'ai appris de respirer avant la phrase.",
  "correct_sentence": "En osant le micro j'ai appris à respirer avant la phrase.",
  "explanation": "Apprendre à + infinitif."
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
      "image_path": "/elearning/mfk-b1-m5/pronom-ou.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/horloge-journee.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/stage-radio.svg",
      "word": "un stage"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/casque-lea.svg",
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
  "prompt": "Transformez six échecs apparents en j'ai appris à / cela m'a permis de."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et quatre valorisations."
}$j$::jsonb,
    9
  );

  -- ===== Une journée de métier =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une journée de métier'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une journée de métier', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Journée à l''atelier et à l''antenne',
    'CO',
    $c$Objectif
Repérer le pronom où et distinguer gérondif et participe présent.

Consigne
Lisez le dialogue. Où ? En arrivant ou arrivant ?

Support — Atelier du Tissu / seuil de Radio Figuier
Dieudonné : L'atelier où je couds ouvre à sept heures.
Léa : La radio où Lila parle est derrière le figuier.
Marc : En arrivant, je range les casques. Arrivant trop vite, je casse le silence.
Aline : Une personne arrivant sans saluer fatigue l'équipe.
Patrick : Le banc où Joël pose sa feuille reste libre le matin.
Joël : En écoutant, j'apprends. Écoutant seulement, je n'ose pas encore.
Hawa : Le jour où Félicie ouvre tôt, la table suffit.
Rose : En marchant vers la rive, on voit le lieu où l'on trie.
Karim : Le Bureau où Solange lit n'aime pas une personne criant.
Lila : En parlant, je respire. Parlant trop, je perds l'heure.
Félicie : La cour où l'on se retrouve ferme après le dernier seau.
Dieudonné : Une équipe travaillant calmement tient mieux qu'une équipe courant partout.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc oppose « en arrivant » (gérondif) et « arrivant trop vite » (participe).",
  "correct": true,
  "explanation": "Marc : les deux formes, deux emplois."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Dieudonné coud-il ?",
  "options": [
    {
      "text": "Au Bureau des Escales",
      "correct": false
    },
    {
      "text": "À l'atelier",
      "correct": true
    },
    {
      "text": "Dans un minibus",
      "correct": false
    },
    {
      "text": "Sous un pont de ville",
      "correct": false
    }
  ],
  "explanation": "« L'atelier où je couds. »"
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
      "left": "où",
      "right": "lieu ou moment"
    },
    {
      "left": "en arrivant",
      "right": "gérondif"
    },
    {
      "left": "arrivant trop vite",
      "right": "participe / cause"
    },
    {
      "left": "une personne arrivant",
      "right": "qui arrive"
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
  "prompt": "Complétez :\nL'atelier ___ je couds ouvre à sept heures.",
  "answer": "où"
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
    "arrivant",
    "je",
    "range",
    "les",
    "casques",
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
  "word": "atelier",
  "hint": "Le lieu où Dieudonné coud les sacs de la rive."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "L'atelier que je couds ouvre à sept heures.",
  "correct_sentence": "L'atelier où je couds ouvre à sept heures.",
  "explanation": "Lieu : où, pas que."
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
      "image_path": "/elearning/mfk-b1-m5/horloge-journee.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/stage-radio.svg",
      "word": "un stage"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/casque-lea.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/atelier-tissu.svg",
      "word": "un atelier"
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
  "prompt": "Notez trois où, deux gérondifs et deux participes présents."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : L'atelier où je couds. En arrivant, je range. Une personne arrivant sans saluer."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fil d''une journée',
    'CE',
    $c$Objectif
Lire le fil d'une journée avec où, gérondif et participe présent.

Consigne
Lisez le fil, sans aller trop vite.

Support — Fil de Dieudonné et de Léa
7 h — l'atelier où Dieudonné allume, en arrivant, la lampe ocre.
7 h 20 — une personne arrivant trop tard range d'abord, parle ensuite.
8 h — le banc où Joël pose le cahier ; en écoutant, Patrick note.
9 h — la radio où Léa essaie le casque. Parlant trop vite, elle recommence.
10 h — le jour où Félicie ouvre la table, en portant deux cruches.
11 h — le lieu où l'on trie près de la rive. En marchant, on voit les sacs.
12 h — une équipe mangeant sous le figuier laisse de la place.
14 h — le Bureau où Solange lit, une page arrivant déjà tamponnée.
16 h — en fermant l'atelier, Dieudonné compte trois sacs tenus.
17 h — la cour où l'on se dit au revoir, sans courir.
18 h — Radio Figuier, l'heure où Lila coupe, écoutant la cour encore.
Règle : en + participe = gérondif ; participe seul = cause ou adjectif.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "À 16 h, Dieudonné compte trois sacs en fermant l'atelier.",
  "correct": true,
  "explanation": "« en fermant l'atelier, Dieudonné compte trois sacs. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait Léa à 9 h si elle parle trop vite ?",
  "options": [
    {
      "text": "Elle ferme le Bureau",
      "correct": false
    },
    {
      "text": "Elle recommence",
      "correct": true
    },
    {
      "text": "Elle coud un sac",
      "correct": false
    },
    {
      "text": "Elle part à Val-des-Peupliers",
      "correct": false
    }
  ],
  "explanation": "« Parlant trop vite, elle recommence. »"
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
      "left": "l'atelier où",
      "right": "Dieudonné"
    },
    {
      "left": "la radio où",
      "right": "Léa"
    },
    {
      "left": "en arrivant",
      "right": "gérondif"
    },
    {
      "left": "parlant trop vite",
      "right": "participe"
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
  "prompt": "Complétez :\nLe banc ___ Joël pose le cahier reste libre.",
  "answer": "où"
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
    "fermant",
    "l'atelier",
    "Dieudonné",
    "compte",
    "trois",
    "sacs",
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
  "word": "gérondif",
  "hint": "En + participe : en arrivant, en écoutant. Le nom de cette forme."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le jour que Félicie ouvre la table on porte deux cruches.",
  "correct_sentence": "Le jour où Félicie ouvre la table on porte deux cruches.",
  "explanation": "Moment : le jour où."
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
      "image_path": "/elearning/mfk-b1-m5/stage-radio.svg",
      "word": "un stage"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/casque-lea.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/atelier-tissu.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/micro-essai.svg",
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
  "prompt": "Recopiez six heures et indiquez où / en + participe / participe seul."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le fil de la journée, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Où, en arrivant, arrivant',
    'PO',
    $c$Objectif
Situer et relier : où ; gérondif versus participe présent.

Consigne
Répétez, puis racontez une heure de métier.

Support — Modèles de Lila
C'est l'atelier où je couds.
C'est la radio où je parle.
C'est le jour où l'on ouvre tôt.
En arrivant, je salue.
En écoutant, j'apprends.
Arrivant trop vite, je casse le silence.
Une personne arrivant sans saluer fatigue.
En fermant, je compte.
Parlant trop, je perds l'heure.
Le lieu où l'on trie est près de la rive.
Le Bureau où Solange lit reste calme.
On avance en marchant, pas en criant.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« En arrivant » porte en ; « arrivant trop vite » n'en a pas.",
  "correct": true,
  "explanation": "Gérondif vs participe."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase contient un gérondif ?",
  "options": [
    {
      "text": "Arrivant trop vite je casse le silence",
      "correct": false
    },
    {
      "text": "En arrivant je salue",
      "correct": true
    },
    {
      "text": "Une personne arrivant sans saluer",
      "correct": false
    },
    {
      "text": "La radio où je parle",
      "correct": false
    }
  ],
  "explanation": "En + participe."
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
      "left": "où",
      "right": "lieu / moment"
    },
    {
      "left": "en + participe",
      "right": "gérondif"
    },
    {
      "left": "participe seul",
      "right": "cause ou adjectif"
    },
    {
      "left": "une personne arrivant",
      "right": "qui arrive"
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
  "prompt": "Complétez :\n___ écoutant j'apprends.",
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
    "C'est",
    "la",
    "radio",
    "où",
    "je",
    "parle",
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
  "hint": "Arrivant trop vite Marc casse le… de l'antenne."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En arrivant trop vite je casse le silence de la radio où je parle trop.",
  "correct_sentence": "Arrivant trop vite je casse le silence de la radio où je parle trop.",
  "explanation": "Cause : participe sans en, pas le gérondif ici."
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
      "image_path": "/elearning/mfk-b1-m5/casque-lea.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/atelier-tissu.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/micro-essai.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/bilan-semaine.svg",
      "word": "un bilan"
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
  "prompt": "Écrivez six phrases : deux où, deux en + participe, deux participes seuls."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis une heure à l'atelier ou à la radio."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma journée de métier',
    'PE',
    $c$Objectif
Écrire le fil d'une journée avec où, gérondif et participe présent.

Consigne
Imitez la journée de Félicie, sans aller trop vite.

Support — Journée de Félicie Ndayishimiye
Félicie Ndayishimiye
La cour où je dresse la table ouvre tôt.
En arrivant, je pose deux cruches.
Une personne arrivant trop vite attend le banc.
Le jour où Joël aide, on range plus vite.
En écoutant Aline, je nuance les heures.
Parlant trop, je perds le fil : je recommence.
La table où l'on signe reste claire.
Félicie
Table des Sources
Seuil des Sources — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Félicie pose deux cruches en arrivant.",
  "correct": true,
  "explanation": "« En arrivant, je pose deux cruches. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait une personne arrivant trop vite ?",
  "options": [
    {
      "text": "Elle coud",
      "correct": false
    },
    {
      "text": "Elle attend le banc",
      "correct": true
    },
    {
      "text": "Elle ferme le Bureau",
      "correct": false
    },
    {
      "text": "Elle filme",
      "correct": false
    }
  ],
  "explanation": "« attend le banc. »"
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
      "left": "la cour où",
      "right": "table"
    },
    {
      "left": "en arrivant",
      "right": "cruches"
    },
    {
      "left": "une personne arrivant",
      "right": "attend"
    },
    {
      "left": "le jour où",
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
  "prompt": "Complétez :\nLa table ___ l'on signe reste claire.",
  "answer": "où"
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
    "écoutant",
    "Aline",
    "je",
    "nuance",
    "les",
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
  "word": "cruches",
  "hint": "Félicie en pose deux en arrivant à la table."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La cour que je dresse la table ouvre tôt.",
  "correct_sentence": "La cour où je dresse la table ouvre tôt.",
  "explanation": "Lieu : où."
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
      "image_path": "/elearning/mfk-b1-m5/atelier-tissu.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/micro-essai.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/bilan-semaine.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/cahier-notes.svg",
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
  "prompt": "Imitez : dix lignes, trois où, deux gérondifs, un participe seul."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre journée, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Pronom où, gérondif, participe présent',
    'EL',
    $c$Objectif
Retenir où et la différence en arrivant / arrivant / une personne arrivant.

Consigne
Apprenez la fiche.

Support — Fiche de Lila
Où = lieu ou moment : l'atelier où je couds ; le jour où l'on ouvre.
On ne dit pas : l'atelier que je couds (lieu) ; le jour que Félicie ouvre (moment).
Gérondif : en + participe présent (en arrivant, en écoutant, en fermant).
Emploi du gérondif : simultanéité, moyen, condition légère.
Participe présent seul : cause (Arrivant trop vite, je casse le silence).
Participe adjectival : une personne arrivant / une équipe travaillant.
Le participe présent est invariable (arrivant, parlant, travaillant).
Ne pas mettre en si l'on veut une cause nette ou un adjectif.
Ne pas oublier en si l'on veut le gérondif de manière.
L'élision : l'atelier où l'on trie (l'on pour le son).
Même radical : arriver → arrivant ; écouter → écoutant ; fermer → fermant.
Parler → parlant (pas parlanté).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le participe présent s'accorde comme un adjectif court.",
  "correct": false,
  "explanation": "Il est invariable : arrivant."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Une personne ___ sans saluer fatigue. »",
  "options": [
    {
      "text": "en arrivant",
      "correct": false
    },
    {
      "text": "arrivant",
      "correct": true
    },
    {
      "text": "arrivée de",
      "correct": false
    },
    {
      "text": "où arrivant",
      "correct": false
    }
  ],
  "explanation": "Adjectival : une personne arrivant."
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
      "left": "où",
      "right": "lieu / moment"
    },
    {
      "left": "en arrivant",
      "right": "gérondif"
    },
    {
      "left": "arrivant trop vite",
      "right": "cause"
    },
    {
      "left": "une personne arrivant",
      "right": "adjectif verbal"
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
  "prompt": "Complétez :\nC'est le jour ___ l'on ouvre tôt.",
  "answer": "où"
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
    "personne",
    "arrivant",
    "sans",
    "saluer",
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
  "word": "invariable",
  "hint": "Le participe présent ne change pas : il est…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En arrivants trop vite je casse le silence de l'antenne.",
  "correct_sentence": "En arrivant trop vite je casse le silence de l'antenne.",
  "explanation": "Participe invariable : arrivant."
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
      "image_path": "/elearning/mfk-b1-m5/micro-essai.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/bilan-semaine.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/cahier-notes.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/tampon-ok.svg",
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
  "prompt": "Transformez six phrases : où / en + p.p. / p.p. seul / personne + p.p."
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

  -- ===== Un stage à la radio =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un stage à la radio'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un stage à la radio', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Premier jour à Radio Figuier',
    'CO',
    $c$Objectif
Comprendre le premier jour de stage de Léa avec Lila et Marc.

Consigne
Lisez le dialogue. Qui fait quoi à l'antenne ?

Support — Studio de Radio Figuier, casques ocre
Lila : Léa, le plateau où tu t'assieds reste assez calme.
Léa : En arrivant, j'ai posé le casque. J'ai appris à attendre le geste.
Marc : Je filme le geste, pas le visage trop près. Tu pourrais respirer.
Lila : Évitez de parler par-dessus l'invité, même Joël, même Patrick.
Léa : Cela m'a permis d'écouter la cour avant d'ouvrir le micro.
Marc : Le jour où l'on reçoit Solange, on prépare une question, pas dix.
Lila : Tout d'abord le son, ensuite la phrase, enfin le silence.
Léa : Par ailleurs, Dieudonné passera pour le sac de l'antenne.
Marc : De plus, Aline viendra écouter, sans corriger à voix haute.
Lila : Il vaudrait mieux une minute nette qu'un quart d'heure trop plein.
Léa : J'adhère, mais je nuance : j'ai encore peur du silence.
Marc : En osant ce silence, tu tiens mieux qu'en parlant trop.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila demande d'éviter de parler par-dessus l'invité.",
  "correct": true,
  "explanation": "Lila : « Évitez de parler par-dessus l'invité. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que prépare-t-on le jour où Solange vient ?",
  "options": [
    {
      "text": "Dix questions",
      "correct": false
    },
    {
      "text": "Une question",
      "correct": true
    },
    {
      "text": "Un discours de vingt pages",
      "correct": false
    },
    {
      "text": "Une cravate pour Marc",
      "correct": false
    }
  ],
  "explanation": "Marc : « une question, pas dix. »"
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
      "left": "plateau où",
      "right": "Léa"
    },
    {
      "left": "en arrivant",
      "right": "casque"
    },
    {
      "left": "évitez de parler",
      "right": "par-dessus"
    },
    {
      "left": "une minute nette",
      "right": "plutôt qu'un quart d'heure"
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
  "prompt": "Complétez :\nLe plateau ___ tu t'assieds reste assez calme.",
  "answer": "où"
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
    "arrivant",
    "j'ai",
    "posé",
    "le",
    "casque",
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
  "word": "casque",
  "hint": "Léa le pose en arrivant au plateau de Radio Figuier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Évitez de parler par-dessus l'invité même Joël trop vites.",
  "correct_sentence": "Évitez de parler par-dessus l'invité même Joël trop vite.",
  "explanation": "Trop vite, invariable."
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
      "image_path": "/elearning/mfk-b1-m5/bilan-semaine.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/cahier-notes.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/tampon-ok.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/table-sources-pro.svg",
      "word": "une table"
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
  "prompt": "Notez les rôles de Léa, Lila et Marc au premier jour."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Le plateau où tu t'assieds. En arrivant j'ai posé le casque. Une minute nette."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Carnet de stage de Léa',
    'CE',
    $c$Objectif
Lire le carnet de stage à Radio Figuier.

Consigne
Lisez le carnet, sans aller trop vite.

Support — Carnet de Léa Niyonzima
Stage — Radio Figuier, semaine 0 (préparation)
Lila Sow m'accueille au plateau où l'on teste le son.
Marc Nkurunziza filme en restant sur le geste, pas sur le visage.
En arrivant, je pose le casque ; arrivant trop vite, je refais le silence.
J'ai osé une minute : j'ai appris à respirer ; cela m'a permis d'écouter.
Tout d'abord le son. En effet, sans son net, la phrase tombe.
Par ailleurs, Dieudonné apporte un sac pour les nappes du micro.
De plus, Aline note sans m'interrompre.
Enfin, Lila coupe : assez d'une minute, pas trop de discours.
Le jour où Solange passe, une question suffit.
Évitez de parler par-dessus. Vous devriez remercier l'invité.
Il vaudrait mieux un silence tenu qu'une phrase trop longue.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa a osé une minute et a appris à respirer.",
  "correct": true,
  "explanation": "« J'ai osé une minute : j'ai appris à respirer. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui filme le geste, d'après le carnet ?",
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
      "text": "Solange",
      "correct": false
    },
    {
      "text": "Félicie",
      "correct": false
    }
  ],
  "explanation": "« Marc Nkurunziza filme. »"
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
      "left": "Lila",
      "right": "accueille"
    },
    {
      "left": "Marc",
      "right": "filme"
    },
    {
      "left": "Dieudonné",
      "right": "sac du micro"
    },
    {
      "left": "Aline",
      "right": "note sans interrompre"
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
  "prompt": "Complétez :\nAssez d'une minute, pas trop de ___.",
  "answer": "discours"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Lila",
    "m'accueille",
    "au",
    "plateau",
    "où",
    "l'on",
    "teste",
    "le",
    "son",
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
  "word": "plateau",
  "hint": "Le lieu où Léa s'assied pour tester le son."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En arrivant je pose le casque arrivant trop vite je refais le silences.",
  "correct_sentence": "En arrivant je pose le casque arrivant trop vite je refais le silence.",
  "explanation": "Silence au singulier."
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
      "image_path": "/elearning/mfk-b1-m5/cahier-notes.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/tampon-ok.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/table-sources-pro.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/dieudonne-tissu.svg",
      "word": "un tissu"
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
  "prompt": "Recopiez le carnet et soulignez où, gérondif, articulateurs et conseils."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le carnet de Léa, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire le plateau',
    'PO',
    $c$Objectif
Parler du stage à Radio Figuier : rôles, où, gérondif, conseils.

Consigne
Répétez, puis présentez le plateau à un voisin.

Support — Modèles de Marc
C'est le plateau où Léa s'assied.
En arrivant, elle pose le casque.
Lila accueille.
Je filme le geste.
Évitez de parler par-dessus.
Vous devriez remercier.
Il vaudrait mieux une minute nette.
J'ai appris à attendre.
Cela m'a permis d'écouter.
Le jour où Solange passe, une question.
Assez d'une minute.
Pas trop de discours.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc filme le geste, pas le visage trop près.",
  "correct": true,
  "explanation": "Modèle : je filme le geste."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle durée Lila préfère-t-elle ?",
  "options": [
    {
      "text": "Un quart d'heure trop plein",
      "correct": false
    },
    {
      "text": "Une minute nette",
      "correct": true
    },
    {
      "text": "Vingt pages lues",
      "correct": false
    },
    {
      "text": "Toute la nuit",
      "correct": false
    }
  ],
  "explanation": "Une minute nette."
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
      "left": "plateau où",
      "right": "Léa"
    },
    {
      "left": "en arrivant",
      "right": "casque"
    },
    {
      "left": "Lila",
      "right": "accueille"
    },
    {
      "left": "Marc",
      "right": "filme"
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
  "prompt": "Complétez :\nIl vaudrait mieux une ___ nette.",
  "answer": "minute"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Évitez",
    "de",
    "parler",
    "par-dessus",
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
  "word": "invité",
  "hint": "On évite de parler par-dessus l'… au micro."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le plateau que Léa s'assied le matin.",
  "correct_sentence": "C'est le plateau où Léa s'assied le matin.",
  "explanation": "S'asseoir à un lieu → où."
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
      "image_path": "/elearning/mfk-b1-m5/tampon-ok.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/table-sources-pro.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/dieudonne-tissu.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/lila-antenne.svg",
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
  "prompt": "Écrivez six phrases de plateau : où, gérondif, un conseil, un rôle."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis une visite guidée du plateau."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon carnet de radio',
    'PE',
    $c$Objectif
Écrire un carnet de stage à Radio Figuier.

Consigne
Imitez le carnet de Marc, sans aller trop vite.

Support — Carnet de Marc Nkurunziza
Marc Nkurunziza
Le plateau où Léa s'assied reste assez calme.
En arrivant, je filme le geste, pas le visage trop près.
Lila accueille ; j'ai appris à attendre son signe.
Cela m'a permis d'écouter la cour avant d'ouvrir.
Évitez de parler par-dessus l'invité.
Il vaudrait mieux une minute nette.
Le jour où Solange passe, une question suffit.
Marc
Radio Figuier
Seuil des Sources — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc a appris à attendre le signe de Lila.",
  "correct": true,
  "explanation": "« j'ai appris à attendre son signe. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que filme Marc ?",
  "options": [
    {
      "text": "Le visage trop près",
      "correct": false
    },
    {
      "text": "Le geste",
      "correct": true
    },
    {
      "text": "La rivière seulement",
      "correct": false
    },
    {
      "text": "Le Bureau fermé",
      "correct": false
    }
  ],
  "explanation": "« je filme le geste. »"
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
      "left": "plateau où",
      "right": "Léa"
    },
    {
      "left": "en arrivant",
      "right": "filmer"
    },
    {
      "left": "appris à attendre",
      "right": "signe"
    },
    {
      "left": "une minute nette",
      "right": "durée"
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
  "prompt": "Complétez :\nÉvitez de parler par-dessus l'___.",
  "answer": "invité"
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
    "une",
    "minute",
    "nette",
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
  "word": "antenne",
  "hint": "Radio Figuier : Lila tient l'… , Léa essaie le casque."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En arrivant je filme le geste pas le visage trop près trop pres.",
  "correct_sentence": "En arrivant je filme le geste pas le visage trop près trop près.",
  "explanation": "Près, avec accent."
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
      "image_path": "/elearning/mfk-b1-m5/table-sources-pro.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/dieudonne-tissu.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/lila-antenne.svg",
      "word": "une antenne"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/main-poignee.svg",
      "word": "une poignée"
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
  "prompt": "Imitez : un carnet de dix lignes, Léa / Lila / Marc, un où, un gérondif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre carnet, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Lexique et formes du plateau',
    'EL',
    $c$Objectif
Retenir le lexique de Radio Figuier et les formes déjà vues.

Consigne
Apprenez la fiche.

Support — Fiche de l'antenne
Lieux : plateau, antenne, Radio Figuier, cour, figuier (pas une radio réelle).
Personnes : Léa (stage), Lila (antenne), Marc (geste filmé), Aline (écoute),
Solange (invitée possible), Dieudonné (sac du micro).
Où : le plateau où, le jour où, la radio où.
Gérondif : en arrivant, en restant, en osant.
Participe : arrivant trop vite, parlant trop.
Conseils : vous devriez, il vaudrait mieux, évitez de / d'.
Valoriser : j'ai appris à, cela m'a permis de / d'.
Articulateurs utiles à l'antenne : tout d'abord, en effet, enfin.
Durée : assez d'une minute, pas trop de discours, un silence tenu.
Ne pas parler par-dessus l'invité.
Ne pas inventer une enseigne d'antenne hors du Seuil.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Radio Figuier est une antenne inventée du Seuil.",
  "correct": true,
  "explanation": "Pas une radio réelle."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui accueille Léa au plateau ?",
  "options": [
    {
      "text": "Félicie",
      "correct": false
    },
    {
      "text": "Lila",
      "correct": true
    },
    {
      "text": "Karim",
      "correct": false
    },
    {
      "text": "Un guide de ville",
      "correct": false
    }
  ],
  "explanation": "Lila Sow, antenne."
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
      "right": "stage"
    },
    {
      "left": "Lila",
      "right": "antenne"
    },
    {
      "left": "Marc",
      "right": "geste"
    },
    {
      "left": "plateau où",
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
  "prompt": "Complétez :\nAssez d'une minute, pas trop de ___.",
  "answer": "discours"
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
    "jour",
    "où",
    "Solange",
    "passe",
    "une",
    "question",
    "suffit",
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
  "hint": "Il vaudrait mieux un… tenu qu'une phrase trop longue."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le plateau que Léa s'assied reste assez calme.",
  "correct_sentence": "Le plateau où Léa s'assied reste assez calme.",
  "explanation": "Lieu : où."
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
      "image_path": "/elearning/mfk-b1-m5/dieudonne-tissu.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/lila-antenne.svg",
      "word": "une antenne"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/main-poignee.svg",
      "word": "une poignée"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/etoile-poste.svg",
      "word": "une étoile"
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
  "prompt": "Faites un glossaire de dix mots du plateau, avec une phrase chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et une présentation de l'antenne."
}$j$::jsonb,
    9
  );

  -- ===== Bilan de la première semaine =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Bilan de la première semaine'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Bilan de la première semaine', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Bilan sous le figuier',
    'CO',
    $c$Objectif
Comprendre une synthèse de parcours avec gérondif.

Consigne
Lisez le bilan. Qui synthétise quoi ?

Support — Table des Sources, fin de la première semaine
Aline : En faisant le bilan, on garde les preuves, pas les discours trop longs.
Patrick : En relisant ma lettre, j'ai vu ce que j'ai appris à classer.
Joël : En osant l'atelier, cela m'a permis de tenir trois matins.
Léa : En arrivant chaque jour, j'ai appris à attendre le signe de Lila.
Marc : En filmant le geste, j'ai moins parlé par-dessus.
Dieudonné : En recousant, j'ai sauvé deux sacs.
Hawa : En mesurant l'eau, on a mis de moins en moins de cruches.
Rose : En signant tôt, j'ai relayé sans crier.
Lila : En coupant à une minute, l'antenne reste nette.
Karim : En portant une page, le Bureau a lu plus vite.
Félicie : En ouvrant tôt, la table a suffi.
Solange : En lisant vos noms, je vois un parcours, pas une liste vide.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël a tenu trois matins en osant l'atelier.",
  "correct": true,
  "explanation": "Joël : « cela m'a permis de tenir trois matins. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que garde-t-on en faisant le bilan, d'après Aline ?",
  "options": [
    {
      "text": "Les discours trop longs",
      "correct": false
    },
    {
      "text": "Les preuves",
      "correct": true
    },
    {
      "text": "Les cravates",
      "correct": false
    },
    {
      "text": "Les villes réelles",
      "correct": false
    }
  ],
  "explanation": "« on garde les preuves. »"
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
      "left": "en faisant le bilan",
      "right": "preuves"
    },
    {
      "left": "en relisant",
      "right": "Patrick"
    },
    {
      "left": "en arrivant",
      "right": "Léa"
    },
    {
      "left": "en recousant",
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
  "prompt": "Complétez :\n___ faisant le bilan on garde les preuves.",
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
    "filmant",
    "le",
    "geste",
    "j'ai",
    "moins",
    "parlé",
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
  "word": "bilan",
  "hint": "Synthèse de la première semaine, sous le figuier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En faisant le bilan on garde les preuves pas les discours trop longue.",
  "correct_sentence": "En faisant le bilan on garde les preuves pas les discours trop longs.",
  "explanation": "Discours trop longs, masculin pluriel."
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
      "image_path": "/elearning/mfk-b1-m5/lila-antenne.svg",
      "word": "une antenne"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/main-poignee.svg",
      "word": "une poignée"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/etoile-poste.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/calendrier-stage.svg",
      "word": "un calendrier"
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
  "prompt": "Notez six gérondifs du bilan et l'apport de chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : En faisant le bilan. En osant l'atelier. En arrivant chaque jour."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Synthèse de la semaine',
    'CE',
    $c$Objectif
Lire une synthèse écrite de parcours, tissée de gérondifs.

Consigne
Lisez la synthèse, sans aller trop vite.

Support — Page collective, Cahier des racines
Bilan — première semaine au Seuil
En disant nos parcours, Patrick et Joël ont tenu une page chacun.
En préparant l'entretien, Aline a répété : vous devriez, évitez de, il vaudrait mieux.
En osant un geste, chacun a pu dire : j'ai appris à, cela m'a permis de.
En racontant une journée, on a placé où, en arrivant, une personne arrivant.
En tenant le plateau, Léa, Lila et Marc ont gardé une minute nette.
Preuves : 3 matins d'atelier, 5 silences tenus, 2 sacs sauvés, 1 page au Bureau.
En mesurant, on voit de plus en plus de calme, de moins en moins de précipitation.
Dans l'attente de la deuxième semaine, nous vous prions de lire cette page.
En restant locaux, on n'invente ni ville ni enseigne.
Dieudonné : en recousant, on répare plus qu'on jette.
Félicie : en ouvrant tôt, la table suffit.
Solange : en tamponnant, le Bureau reconnaît un essai, pas une fin.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La synthèse refuse d'inventer une ville ou une enseigne.",
  "correct": true,
  "explanation": "« on n'invente ni ville ni enseigne. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de silences tenus la page compte-t-elle ?",
  "options": [
    {
      "text": "3",
      "correct": false
    },
    {
      "text": "5",
      "correct": true
    },
    {
      "text": "2",
      "correct": false
    },
    {
      "text": "1",
      "correct": false
    }
  ],
  "explanation": "« 5 silences tenus. »"
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
      "left": "en disant nos parcours",
      "right": "Patrick et Joël"
    },
    {
      "left": "en préparant",
      "right": "Aline"
    },
    {
      "left": "en tenant le plateau",
      "right": "Léa Lila Marc"
    },
    {
      "left": "en recousant",
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
  "prompt": "Complétez :\nEn mesurant on voit de plus en plus de ___.",
  "answer": "calme"
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
    "restant",
    "locaux",
    "on",
    "n'invente",
    "ni",
    "ville",
    "ni",
    "enseigne",
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
  "word": "synthese",
  "hint": "Page qui rassemble le parcours de la semaine. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En disant nos parcours Patrick et Joël ont tenu une pages chacun.",
  "correct_sentence": "En disant nos parcours Patrick et Joël ont tenu une page chacun.",
  "explanation": "Une page, singulier."
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
      "image_path": "/elearning/mfk-b1-m5/main-poignee.svg",
      "word": "une poignée"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/etoile-poste.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/calendrier-stage.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/porte-ouverte.svg",
      "word": "une ouverture"
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
  "prompt": "Recopiez la synthèse et encadrez tous les gérondifs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la synthèse, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Synthétiser en + participe',
    'PO',
    $c$Objectif
Faire le bilan à voix haute avec des gérondifs en chaîne.

Consigne
Répétez, puis dites votre semaine en six gérondifs.

Support — Modèles d'Aline
En faisant le bilan, on garde les preuves.
En relisant, je classe.
En osant, j'apprends.
En arrivant, j'attends le signe.
En filmant, je parle moins.
En recousant, je répare.
En mesurant, je nuance.
En signant, je relais.
En coupant, je tiens l'heure.
En portant une page, je convaincs.
En ouvrant tôt, la table suffit.
En restant local, je reste juste.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le gérondif permet d'enchaîner le bilan sans tout re-raconter.",
  "correct": true,
  "explanation": "En + participe : synthèse."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est un gérondif de bilan ?",
  "options": [
    {
      "text": "J'ai un bilan",
      "correct": false
    },
    {
      "text": "En osant j'apprends",
      "correct": true
    },
    {
      "text": "Ose maintenant",
      "correct": false
    },
    {
      "text": "Le bilan est fini",
      "correct": false
    }
  ],
  "explanation": "En osant."
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
      "left": "en relisant",
      "right": "classer"
    },
    {
      "left": "en osant",
      "right": "apprendre"
    },
    {
      "left": "en filmant",
      "right": "moins parler"
    },
    {
      "left": "en recousant",
      "right": "réparer"
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
  "prompt": "Complétez :\nEn ___ tôt la table suffit. (ouvrir)",
  "answer": "ouvrant"
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
    "faisant",
    "le",
    "bilan",
    "on",
    "garde",
    "les",
    "preuves",
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
  "hint": "On les garde en faisant le bilan, pas les longs discours."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En faisant le bilan on garde les preuves en restants locaux.",
  "correct_sentence": "En faisant le bilan on garde les preuves en restant locaux.",
  "explanation": "Restant, invariable."
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
      "image_path": "/elearning/mfk-b1-m5/etoile-poste.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/calendrier-stage.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/porte-ouverte.svg",
      "word": "une ouverture"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/lettre-motivation.svg",
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
  "prompt": "Écrivez six gérondifs de bilan, un par jour inventé de la semaine."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis votre semaine en six gérondifs."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon bilan de semaine',
    'PE',
    $c$Objectif
Écrire une synthèse de parcours avec gérondifs.

Consigne
Imitez le bilan de Patrick, sans aller trop vite.

Support — Bilan de Patrick Habimana
Patrick Habimana
En disant mon parcours, j'ai tenu une page.
En préparant l'entretien, j'ai appris à écouter jusqu'au bout.
En osant la lettre, cela m'a permis de classer.
En arrivant à l'atelier avec Joël, j'ai vu le lieu où l'on coud.
En écoutant Léa à Radio Figuier, j'ai compris une minute nette.
En faisant ce bilan, je garde les preuves, pas trop de discours.
Dans l'attente de la suite, je vous prie de lire cette page.
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
  "statement": "Patrick a tenu une page en disant son parcours.",
  "correct": true,
  "explanation": "Première ligne du bilan."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Patrick est-il arrivé avec Joël ?",
  "options": [
    {
      "text": "Au minibus d'une ville",
      "correct": false
    },
    {
      "text": "À l'atelier",
      "correct": true
    },
    {
      "text": "Au lac seulement",
      "correct": false
    },
    {
      "text": "Chez une enseigne réelle",
      "correct": false
    }
  ],
  "explanation": "« le lieu où l'on coud. »"
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
      "left": "en disant",
      "right": "une page"
    },
    {
      "left": "en préparant",
      "right": "écouter"
    },
    {
      "left": "en osant",
      "right": "classer"
    },
    {
      "left": "en faisant ce bilan",
      "right": "preuves"
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
  "prompt": "Complétez :\nEn faisant ce bilan je garde les ___.",
  "answer": "preuves"
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
    "osant",
    "la",
    "lettre",
    "cela",
    "m'a",
    "permis",
    "de",
    "classer",
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
  "word": "semaine",
  "hint": "Première… : le temps du bilan, sept jours au Seuil."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En faisant ce bilan je garde les preuves pas trop de discour.",
  "correct_sentence": "En faisant ce bilan je garde les preuves pas trop de discours.",
  "explanation": "Discours, avec s."
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
      "image_path": "/elearning/mfk-b1-m5/calendrier-stage.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/porte-ouverte.svg",
      "word": "une ouverture"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/lettre-motivation.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/articulateur.svg",
      "word": "un articulateur"
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
  "prompt": "Imitez : un bilan de dix lignes, six gérondifs, une phrase d'attente."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre bilan, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Synthèse : parcours et gérondif',
    'EL',
    $c$Objectif
Relier le parcours de la semaine et le gérondif de synthèse.

Consigne
Apprenez la fiche.

Support — Fiche de clôture
Bilan = preuves + gérondifs + une attente, pas un nouveau discours.
En + participe : en disant, en préparant, en osant, en arrivant, en filmant,
en recousant, en mesurant, en faisant le bilan, en restant locaux.
Le gérondif relie le parcours sans tout re-raconter : simultanéité et moyen.
On reprend : j'ai appris à / cela m'a permis de, à l'intérieur du bilan.
Où reste utile : le lieu où l'on coud, le plateau où Léa s'assied.
Clôture : dans l'attente de… ; je vous prie de lire cette page.
Preuves inventées : 3 matins, 5 silences, 2 sacs, 1 page.
Ne pas accorder le participe du gérondif (en restant, pas en restants).
Ne pas remplacer où par que pour un lieu ou un moment.
Ne pas inventer une ville ou une enseigne hors du Seuil.
Ordre possible : faits en gérondif → preuves chiffrées → attente.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le gérondif du bilan s'accorde au pluriel : en restants.",
  "correct": false,
  "explanation": "Invariable : en restant."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle clôture convient au bilan ?",
  "options": [
    {
      "text": "Criez la suite",
      "correct": false
    },
    {
      "text": "Dans l'attente de la suite je vous prie de lire",
      "correct": true
    },
    {
      "text": "Inventez une ville",
      "correct": false
    },
    {
      "text": "Effacez les preuves",
      "correct": false
    }
  ],
  "explanation": "Attente + je vous prie."
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
      "left": "en disant",
      "right": "parcours"
    },
    {
      "left": "en osant",
      "right": "apprentissage"
    },
    {
      "left": "en faisant le bilan",
      "right": "preuves"
    },
    {
      "left": "dans l'attente de",
      "right": "suite"
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
  "prompt": "Complétez :\nEn ___ locaux on reste juste. (rester)",
  "answer": "restant"
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
    "faisant",
    "le",
    "bilan",
    "on",
    "garde",
    "les",
    "preuves",
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
  "word": "locaux",
  "hint": "En restant… : on n'invente ni ville ni enseigne."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En restants locaux on n'invente ni ville ni enseigne.",
  "correct_sentence": "En restant locaux on n'invente ni ville ni enseigne.",
  "explanation": "Gérondif invariable : restant."
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
      "image_path": "/elearning/mfk-b1-m5/porte-ouverte.svg",
      "word": "une ouverture"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/lettre-motivation.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/articulateur.svg",
      "word": "un articulateur"
    },
    {
      "image_path": "/elearning/mfk-b1-m5/parcours-patrick.svg",
      "word": "un parcours"
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
  "prompt": "Rédigez une fiche bilan : six gérondifs, trois preuves, une clôture."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et votre synthèse en six gérondifs."
}$j$::jsonb,
    9
  );

END;
$$;
