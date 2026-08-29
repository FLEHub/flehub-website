/*
  Seed eLearning MFK — Module 8 A1 « Gestes du quotidien »

  Même micro-monde que les Modules 3 à 7 : cour « Le Seuil des Sources », Rukiri-Nord.
  Table des Sources, Marché des Lampions, Atelier du Tissu — gestes du quotidien sous le figuier.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a1-m8/
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
  v_module_title text := 'A1 — Gestes du quotidien';
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
      'Seed A1 Module 8 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed Module 8 : enseignant % (%)', v_teacher_email, v_teacher_id;

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
      'Grande étape 8 : lire un menu, faire des courses, comparer, parler d''hier et d''aujourd''hui, s''habiller et donner son avis — à la Table des Sources, au Marché des Lampions et à l''Atelier du Tissu (Seuil des Sources, Rukiri-Nord).',
      'A1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape 8 : lire un menu, faire des courses, comparer, parler d''hier et d''aujourd''hui, s''habiller et donner son avis — à la Table des Sources, au Marché des Lampions et à l''Atelier du Tissu (Seuil des Sources, Rukiri-Nord).',
      cefr_level = 'A1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== La table du Seuil =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'La table du Seuil'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'La table du Seuil', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Midi à la Table des Sources',
    'CO',
    $c$Objectif
Comprendre un menu et un avis : du / de la / des ; j'aime le / la / les.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qu'est-ce qu'il y a à table ? Qui aime quoi ?

Support — Banc du figuier, midi
Félicie Ndayishimiye : Aujourd'hui, il y a de la soupe aux herbes. Et du pain du Seuil.
Léa : J'aime le pain. Je n'aime pas trop le poisson.
Marc : Moi, je prends du poulet. Il y a aussi des ignames.
Hawa : Il n'y a pas de fromage aujourd'hui. Tant pis. Je bois du thé.
Joël : Je déteste le café. J'adore le thé au gingembre.
Aline : Il faut goûter. La goyave est pour le dessert.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa aime le pain.",
  "correct": true,
  "explanation": "Léa : « J'aime le pain. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qu'est-ce qu'il n'y a pas, d'après Hawa ?",
  "options": [
    {
      "text": "Du pain",
      "correct": false
    },
    {
      "text": "De la soupe",
      "correct": false
    },
    {
      "text": "Du fromage",
      "correct": true
    },
    {
      "text": "Du thé",
      "correct": false
    }
  ],
  "explanation": "Hawa : « Il n'y a pas de fromage. »"
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
      "left": "Félicie",
      "right": "soupe et pain"
    },
    {
      "left": "Marc",
      "right": "poulet"
    },
    {
      "left": "Joël",
      "right": "thé"
    },
    {
      "left": "Aline",
      "right": "goyave"
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
  "prompt": "Complétez :\nIl y a ___ soupe aux herbes.",
  "answer": "de la"
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
    "le",
    "pain",
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
  "word": "soupe",
  "hint": "Le plat liquide de Félicie, aux herbes."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je n'aime pas du poisson.",
  "correct_sentence": "Je n'aime pas le poisson.",
  "explanation": "Après aimer / n'aimer pas : le, la, les (pas du)."
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
      "image_path": "/elearning/mfk-a1-m8/menu.svg",
      "word": "un menu"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/pain.svg",
      "word": "du pain"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/poulet.svg",
      "word": "du poulet"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/the.svg",
      "word": "du thé"
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
  "prompt": "Notez trois plats et un avis (j'aime / je n'aime pas)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il y a de la soupe. J'aime le pain. Je n'aime pas le poisson. Je bois du thé."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Menu du midi',
    'CE',
    $c$Objectif
Lire un menu inventé et repérer du / de la / des.

Consigne
Lisez le menu.

Support — Ardoise de la Table des Sources
Midi sous le figuier
Entrée : de la soupe aux herbes
Plat : du poulet au citron ou du poisson du lac
Accompagnement : des ignames ou des légumes du jardin
Pain du Seuil
Dessert : de la goyave
Boisson : du thé au gingembre. Pas de café aujourd'hui.
Félicie Ndayishimiye — Seuil des Sources
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le menu propose du café.",
  "correct": false,
  "explanation": "« Pas de café aujourd'hui. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel dessert y a-t-il ?",
  "options": [
    {
      "text": "Du chocolat",
      "correct": false
    },
    {
      "text": "De la goyave",
      "correct": true
    },
    {
      "text": "Des ignames frites",
      "correct": false
    },
    {
      "text": "Un gâteau du port",
      "correct": false
    }
  ],
  "explanation": "Dessert : de la goyave."
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
      "left": "entrée",
      "right": "soupe"
    },
    {
      "left": "plat",
      "right": "poulet ou poisson"
    },
    {
      "left": "accompagnement",
      "right": "ignames ou légumes"
    },
    {
      "left": "boisson",
      "right": "thé"
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
  "prompt": "Complétez :\nIl y a ___ ignames.",
  "answer": "des"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Pas",
    "de",
    "café",
    "aujourd'hui",
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
  "word": "menu",
  "hint": "La liste des plats, sur l'ardoise."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il n'y a pas du café.",
  "correct_sentence": "Il n'y a pas de café.",
  "explanation": "Après pas : de (pas du)."
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
      "image_path": "/elearning/mfk-a1-m8/assiette.svg",
      "word": "une assiette"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/poisson.svg",
      "word": "du poisson"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/legume.svg",
      "word": "des légumes"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/fruit.svg",
      "word": "un fruit"
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
  "prompt": "Recopiez le menu. Ajoutez un plat avec du, de la ou des."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le menu, une ligne, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire j''aime, il y a du',
    'PO',
    $c$Objectif
Parler d'un plat : partitif et goût.

Consigne
Répétez, puis dites ce que vous aimez à table.

Support — Modèles de Félicie
Il y a du pain.
Il y a de la soupe.
Il y a de l'huile.
Il y a des légumes.
J'aime le thé.
Je n'aime pas le café.
Je bois du thé.
Il n'y a pas de fromage.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « j'aime du thé ».",
  "correct": false,
  "explanation": "J'aime le thé (article défini)."
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
      "text": "Il y a de pain",
      "correct": false
    },
    {
      "text": "Il y a du pain",
      "correct": true
    },
    {
      "text": "Il y a le pain beaucoup",
      "correct": false
    },
    {
      "text": "Il y a pain",
      "correct": false
    }
  ],
  "explanation": "Du = de + le."
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
      "left": "du",
      "right": "pain, poulet, thé"
    },
    {
      "left": "de la",
      "right": "soupe, goyave"
    },
    {
      "left": "de l'",
      "right": "huile"
    },
    {
      "left": "des",
      "right": "légumes, ignames"
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
  "prompt": "Complétez :\nJe bois ___ thé.",
  "answer": "du"
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
    "café",
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
  "word": "fromage",
  "hint": "Il n'y en a pas aujourd'hui, à table."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'aime de la soupe.",
  "correct_sentence": "J'aime la soupe.",
  "explanation": "Goût : le / la / les, pas du / de la."
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
      "image_path": "/elearning/mfk-a1-m8/fromage.svg",
      "word": "du fromage"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/the.svg",
      "word": "du thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/cafe.svg",
      "word": "du café"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/table.svg",
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
  "prompt": "Écrivez six phrases : trois il y a du/de la/des, trois j'aime / je n'aime pas."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre plat préféré."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon avis à table',
    'PE',
    $c$Objectif
Écrire un court avis sur un menu.

Consigne
Imitez le mot de Léa.

Support — Mot de Léa
Léa Niyonzima
À la Table des Sources, il y a de la soupe et du pain.
J'aime le pain. Je n'aime pas le poisson.
Je bois du thé. Il n'y a pas de fromage.
C'est simple. Merci, Félicie.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa aime le poisson.",
  "correct": false,
  "explanation": "« Je n'aime pas le poisson. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que boit Léa ?",
  "options": [
    {
      "text": "Du café",
      "correct": false
    },
    {
      "text": "Du thé",
      "correct": true
    },
    {
      "text": "De l'eau de mer",
      "correct": false
    },
    {
      "text": "Du sirop",
      "correct": false
    }
  ],
  "explanation": "« Je bois du thé. »"
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
      "left": "il y a",
      "right": "soupe et pain"
    },
    {
      "left": "j'aime",
      "right": "pain"
    },
    {
      "left": "je n'aime pas",
      "right": "poisson"
    },
    {
      "left": "je bois",
      "right": "thé"
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
  "prompt": "Complétez :\nIl n'y a pas ___ fromage.",
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
    "J'aime",
    "le",
    "pain",
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
  "hint": "La boisson chaude de Léa, pas le café."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je bois de thé.",
  "correct_sentence": "Je bois du thé.",
  "explanation": "Du thé (de + le)."
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
      "image_path": "/elearning/mfk-a1-m8/pain.svg",
      "word": "du pain"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/the.svg",
      "word": "du thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/assiette.svg",
      "word": "une assiette"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/cuisine.svg",
      "word": "la cuisine"
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
  "prompt": "Écrivez cinq lignes : il y a, j'aime, je n'aime pas, je bois, il n'y a pas."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot, une phrase, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Du, de la, des ; j''aime le',
    'EL',
    $c$Objectif
Retenir les articles partitifs et l'article défini après aimer.

Consigne
Apprenez la fiche.

Support — Fiche de Félicie
du pain / de la soupe / de l'huile / des légumes
pas de fromage (après pas : de)
j'aime le pain / la soupe / les légumes
je n'aime pas le café
je bois du thé
Attention : j'aime le (pas j'aime du).
Il n'y a pas de (pas pas du).
Table des Sources : lieu inventé du Seuil.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « pas du pain » après il n'y a.",
  "correct": false,
  "explanation": "Il n'y a pas de pain."
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
      "text": "j'aime du poulet",
      "correct": false
    },
    {
      "text": "j'aime le poulet",
      "correct": true
    },
    {
      "text": "j'aime de poulet",
      "correct": false
    },
    {
      "text": "j'aime poulet",
      "correct": false
    }
  ],
  "explanation": "J'aime le poulet."
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
      "left": "du",
      "right": "masculin"
    },
    {
      "left": "de la",
      "right": "féminin"
    },
    {
      "left": "de l'",
      "right": "voyelle"
    },
    {
      "left": "des",
      "right": "pluriel"
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
  "prompt": "Complétez :\nIl y a ___ huile. (partitif)",
  "answer": "de l'"
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
    "a",
    "des",
    "légumes",
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
  "word": "pain",
  "hint": "On le coupe, on le mange avec la soupe."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il y a de pain sur la table.",
  "correct_sentence": "Il y a du pain sur la table.",
  "explanation": "Du pain."
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
      "image_path": "/elearning/mfk-a1-m8/pain.svg",
      "word": "du pain"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/fromage.svg",
      "word": "du fromage"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/legume.svg",
      "word": "des légumes"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/menu.svg",
      "word": "un menu"
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : du, de la, des, j'aime le."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : du pain, de la soupe, de l'huile, des légumes, j'aime le thé, pas de café."
}$j$::jsonb,
    9
  );

  -- ===== Courses au marché =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Courses au marché'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Courses au marché', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — À l''étal de Rose',
    'CO',
    $c$Objectif
Comprendre des courses : je voudrais, un kilo de, une bouteille de.

Consigne
Qui achète quoi ? Quelles quantités ?

Support — Marché des Lampions
Rose Iradukunda : Bonjour. Qu'est-ce que vous voulez ?
Léa : Je voudrais un kilo de tomates, s'il vous plaît.
Hawa : Moi, une bouteille d'huile de figuier.
Marc : Un pot de miel des Herbes. Et un morceau de fromage.
Joël : Deux pains du Seuil. C'est tout.
Rose : Voilà. Ça fait peu. Il faut un sac ?
Aline : Oui. Un sac, merci.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa voudrait un kilo de tomates.",
  "correct": true,
  "explanation": "Léa : « un kilo de tomates »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que voudrait Hawa ?",
  "options": [
    {
      "text": "Un pot de miel",
      "correct": false
    },
    {
      "text": "Une bouteille d'huile",
      "correct": true
    },
    {
      "text": "Deux pains",
      "correct": false
    },
    {
      "text": "Un kilo de café",
      "correct": false
    }
  ],
  "explanation": "Hawa : « une bouteille d'huile de figuier »."
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
      "right": "un kilo de tomates"
    },
    {
      "left": "Hawa",
      "right": "une bouteille d'huile"
    },
    {
      "left": "Marc",
      "right": "miel et fromage"
    },
    {
      "left": "Joël",
      "right": "deux pains"
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
  "prompt": "Complétez :\nJe voudrais un kilo ___ tomates.",
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
    "voudrais",
    "un",
    "pot",
    "de",
    "miel",
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
  "word": "kilo",
  "hint": "Mille grammes, pour les tomates."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je voudrais un kilo du tomates.",
  "correct_sentence": "Je voudrais un kilo de tomates.",
  "explanation": "Quantité + de (pas du)."
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
      "image_path": "/elearning/mfk-a1-m8/marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/panier.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/bouteille.svg",
      "word": "une bouteille"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/kilo.svg",
      "word": "un kilo"
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
  "prompt": "Notez quatre achats avec la quantité."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je voudrais un kilo de tomates. Une bouteille d'huile. Un pot de miel. Deux pains."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Liste de Rose',
    'CE',
    $c$Objectif
Lire une liste de courses avec des quantités.

Consigne
Lisez la liste.

Support — Liste épinglée à l'étal
Marché des Lampions — Rose
Pour la Table des Sources
un kilo de tomates
une bouteille d'huile de figuier
un pot de miel des Herbes
un morceau de fromage
deux pains du Seuil
un sac
Pas d'enseigne réelle. Étal inventé, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La liste demande trois pains.",
  "correct": false,
  "explanation": "Deux pains du Seuil."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de bouteilles d'huile ?",
  "options": [
    {
      "text": "Zéro",
      "correct": false
    },
    {
      "text": "Une",
      "correct": true
    },
    {
      "text": "Deux",
      "correct": false
    },
    {
      "text": "Un kilo",
      "correct": false
    }
  ],
  "explanation": "Une bouteille d'huile."
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
      "left": "kilo",
      "right": "tomates"
    },
    {
      "left": "bouteille",
      "right": "huile"
    },
    {
      "left": "pot",
      "right": "miel"
    },
    {
      "left": "morceau",
      "right": "fromage"
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
  "prompt": "Complétez :\nUn morceau ___ fromage.",
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
    "Une",
    "bouteille",
    "d'huile",
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
  "word": "miel",
  "hint": "Le pot sucré des Herbes, chez Rose."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je voudrais une bouteille de l'huile.",
  "correct_sentence": "Je voudrais une bouteille d'huile.",
  "explanation": "Une bouteille d'huile (d' devant voyelle)."
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
      "image_path": "/elearning/mfk-a1-m8/pot.svg",
      "word": "un pot"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/sac.svg",
      "word": "un sac"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/fromage.svg",
      "word": "du fromage"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/pain.svg",
      "word": "du pain"
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
  "prompt": "Recopiez la liste. Ajoutez un article : je voudrais…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la liste, un article, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire je voudrais, un kilo de',
    'PO',
    $c$Objectif
Faire des courses : je voudrais + quantité + de.

Consigne
Répétez, puis achetez deux choses.

Support — Modèles de Rose
Je voudrais un kilo de tomates.
Je voudrais une bouteille d'huile.
Je voudrais un pot de miel.
Je voudrais un morceau de fromage.
Je voudrais deux pains.
S'il vous plaît.
C'est tout.
Il faut un sac.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je voudrais » sert à demander poliment.",
  "correct": true,
  "explanation": "Au marché, pour acheter."
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
      "text": "un kilo du pain",
      "correct": false
    },
    {
      "text": "un kilo de pain",
      "correct": true
    },
    {
      "text": "un kilo le pain",
      "correct": false
    },
    {
      "text": "un kilo pain",
      "correct": false
    }
  ],
  "explanation": "Un kilo de pain."
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
      "left": "un kilo de",
      "right": "tomates"
    },
    {
      "left": "une bouteille d'",
      "right": "huile"
    },
    {
      "left": "un pot de",
      "right": "miel"
    },
    {
      "left": "deux",
      "right": "pains"
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
  "prompt": "Complétez :\nJe ___ un sac. (vouloir, poli)",
  "answer": "voudrais"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "S'il",
    "vous",
    "plaît",
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
  "word": "panier",
  "hint": "On y met les courses, au marché."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je voudrai un kilo de tomates. (demande polie)",
  "correct_sentence": "Je voudrais un kilo de tomates.",
  "explanation": "Je voudrais (poli), pas je voudrai."
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
      "image_path": "/elearning/mfk-a1-m8/panier.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/bouteille.svg",
      "word": "une bouteille"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/pot.svg",
      "word": "un pot"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/kilo.svg",
      "word": "un kilo"
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
  "prompt": "Écrivez six phrases je voudrais + quantité."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis vos deux courses."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma liste',
    'PE',
    $c$Objectif
Écrire une petite liste de courses.

Consigne
Imitez la liste d'Hawa.

Support — Liste d'Hawa
Hawa Diallo
Je voudrais :
une bouteille d'huile
un pot de miel
un kilo de tomates
deux pains
s'il vous plaît.
Marché des Lampions
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa veut du café.",
  "correct": false,
  "explanation": "Huile, miel, tomates, pains."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de pains Hawa voudrait-elle ?",
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
      "text": "Un kilo",
      "correct": false
    },
    {
      "text": "Zéro",
      "correct": false
    }
  ],
  "explanation": "Deux pains."
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
      "left": "bouteille",
      "right": "huile"
    },
    {
      "left": "pot",
      "right": "miel"
    },
    {
      "left": "kilo",
      "right": "tomates"
    },
    {
      "left": "deux",
      "right": "pains"
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
  "prompt": "Complétez :\nJe voudrais une bouteille ___ huile.",
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
    "Je",
    "voudrais",
    "deux",
    "pains",
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
  "word": "sac",
  "hint": "Rose le propose, pour porter."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je voudrais un pot du miel.",
  "correct_sentence": "Je voudrais un pot de miel.",
  "explanation": "Un pot de miel."
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
      "image_path": "/elearning/mfk-a1-m8/marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/sac.svg",
      "word": "un sac"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/bouteille.svg",
      "word": "une bouteille"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/pain.svg",
      "word": "du pain"
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
  "prompt": "Écrivez cinq lignes : je voudrais + quatre quantités."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre liste, simplement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Quantités et je voudrais',
    'EL',
    $c$Objectif
Retenir quantité + de et je voudrais.

Consigne
Apprenez la fiche.

Support — Fiche de Rose
je voudrais (+ nom)
un kilo de tomates
une bouteille d'huile
un pot de miel
un morceau de fromage
deux pains
un sac
Attention : quantité + de (pas du).
Devant une voyelle : d'huile.
Je voudrais (poli). Pas je voudrai.
Marché des Lampions : lieu déjà connu du Seuil.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « un kilo du tomates ».",
  "correct": false,
  "explanation": "Un kilo de tomates."
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
      "text": "je voudrai du miel",
      "correct": false
    },
    {
      "text": "je voudrais un pot de miel",
      "correct": true
    },
    {
      "text": "je veux de un miel",
      "correct": false
    },
    {
      "text": "je voudrais du un miel",
      "correct": false
    }
  ],
  "explanation": "Je voudrais un pot de miel."
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
      "left": "kilo",
      "right": "poids"
    },
    {
      "left": "bouteille",
      "right": "liquide"
    },
    {
      "left": "pot",
      "right": "miel"
    },
    {
      "left": "morceau",
      "right": "fromage"
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
  "prompt": "Complétez :\nUn ___ de fromage.",
  "answer": "morceau"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Un",
    "kilo",
    "de",
    "tomates",
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
  "word": "voudrais",
  "hint": "La forme polie de vouloir, avec je."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je voudrais un morceau de le fromage.",
  "correct_sentence": "Je voudrais un morceau de fromage.",
  "explanation": "De fromage, sans article."
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
      "image_path": "/elearning/mfk-a1-m8/kilo.svg",
      "word": "un kilo"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/pot.svg",
      "word": "un pot"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/panier.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/marche.svg",
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
  "prompt": "Recopiez la fiche. Écrivez quatre je voudrais avec de."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : je voudrais, un kilo de, une bouteille d'huile, un pot de miel, s'il vous plaît."
}$j$::jsonb,
    9
  );

  -- ===== On compare =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'On compare'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'On compare', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Thé ou café, radio ou carnet',
    'CO',
    $c$Objectif
Comprendre une comparaison : plus, moins, aussi … que.

Consigne
Qui boit plus ? Qu'est-ce qui est moins cher ?

Support — Sous le figuier
Patrick : Le thé est moins cher que le café, ici.
Hawa : Moi, je bois plus de thé que Joël.
Joël : C'est vrai. Je bois moins de thé qu'Hawa. J'aime autant le café.
Léa : La Radio Figuier est aussi calme que le banc.
Marc : Le miel est plus sucré que la goyave.
Aline : Je vais prendre le thé. C'est plus simple.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le thé est moins cher que le café.",
  "correct": true,
  "explanation": "Patrick : « moins cher que le café »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui boit plus de thé ?",
  "options": [
    {
      "text": "Joël",
      "correct": false
    },
    {
      "text": "Hawa",
      "correct": true
    },
    {
      "text": "Marc",
      "correct": false
    },
    {
      "text": "Personne",
      "correct": false
    }
  ],
  "explanation": "Hawa boit plus de thé que Joël."
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
      "left": "thé",
      "right": "moins cher"
    },
    {
      "left": "Hawa",
      "right": "plus de thé"
    },
    {
      "left": "radio",
      "right": "aussi calme"
    },
    {
      "left": "miel",
      "right": "plus sucré"
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
  "prompt": "Complétez :\nLe miel est plus sucré ___ la goyave.",
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
    "Je",
    "vais",
    "prendre",
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
  "word": "moins",
  "hint": "Le contraire de plus, dans une comparaison."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le thé est moins cher que le café n'est.",
  "correct_sentence": "Le thé est moins cher que le café.",
  "explanation": "Moins … que + nom."
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
      "image_path": "/elearning/mfk-a1-m8/the.svg",
      "word": "du thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/cafe.svg",
      "word": "du café"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/comparer.svg",
      "word": "comparer"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/avis.svg",
      "word": "un avis"
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
  "prompt": "Notez trois comparaisons entendues."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Le thé est moins cher que le café. Je bois plus de thé. La radio est aussi calme. Je vais prendre le thé."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Tableau des goûts',
    'CE',
    $c$Objectif
Lire un tableau de comparaisons inventé.

Consigne
Lisez le tableau.

Support — Feuille du figuier
On compare — Seuil des Sources
thé — moins cher que le café
miel — plus sucré que la goyave
Radio Figuier — aussi calme que le banc
Hawa — plus de thé que Joël
ignames — aussi bonnes que le pain
Table des Sources — moins loin que le Port de la Brise
Rien n'est copié d'une enquête réelle.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Les ignames sont moins bonnes que le pain, d'après le tableau.",
  "correct": false,
  "explanation": "Aussi bonnes que le pain."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "La Table des Sources est…",
  "options": [
    {
      "text": "Plus loin que le port",
      "correct": false
    },
    {
      "text": "Moins loin que le Port de la Brise",
      "correct": true
    },
    {
      "text": "Aussi loin que l'île",
      "correct": false
    },
    {
      "text": "Fermée",
      "correct": false
    }
  ],
  "explanation": "Moins loin que le Port de la Brise."
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
      "left": "thé",
      "right": "moins cher"
    },
    {
      "left": "miel",
      "right": "plus sucré"
    },
    {
      "left": "radio",
      "right": "aussi calme"
    },
    {
      "left": "Hawa",
      "right": "plus de thé"
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
  "prompt": "Complétez :\nHawa boit plus de thé ___ Joël.",
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
    "Le",
    "thé",
    "est",
    "moins",
    "cher",
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
  "word": "sucré",
  "hint": "Le miel l'est plus que la goyave."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La radio est aussi calme que le banc est.",
  "correct_sentence": "La radio est aussi calme que le banc.",
  "explanation": "Aussi … que + nom."
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
      "image_path": "/elearning/mfk-a1-m8/comparer.svg",
      "word": "comparer"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/table.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/the.svg",
      "word": "du thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/fruit.svg",
      "word": "un fruit"
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
  "prompt": "Recopiez trois lignes. Ajoutez une comparaison personnelle."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le tableau, une ligne, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire plus, moins, aussi',
    'PO',
    $c$Objectif
Comparer deux choses ou deux personnes.

Consigne
Répétez, puis comparez deux boissons.

Support — Modèles de Patrick
Le thé est moins cher que le café.
Le miel est plus sucré que la goyave.
La radio est aussi calme que le banc.
Je bois plus de thé que Joël.
Je bois moins de café qu'Hawa.
Je vais le prendre.
C'est plus simple.
Il est aussi bon.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Aussi … que » veut dire « la même chose ».",
  "correct": true,
  "explanation": "Même degré."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est une comparaison ?",
  "options": [
    {
      "text": "Je voudrais du thé",
      "correct": false
    },
    {
      "text": "Le thé est moins cher que le café",
      "correct": true
    },
    {
      "text": "Il y a du pain",
      "correct": false
    },
    {
      "text": "Bonjour Rose",
      "correct": false
    }
  ],
  "explanation": "Moins cher que."
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
      "left": "plus … que",
      "right": "davantage"
    },
    {
      "left": "moins … que",
      "right": "pas autant"
    },
    {
      "left": "aussi … que",
      "right": "pareil"
    },
    {
      "left": "je vais le prendre",
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
  "prompt": "Complétez :\nLa radio est aussi calme ___ le banc.",
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
    "plus",
    "simple",
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
  "hint": "Pour dire « la même chose », avant l'adjectif."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je bois plus que thé que Joël.",
  "correct_sentence": "Je bois plus de thé que Joël.",
  "explanation": "Plus de + nom + que."
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
      "image_path": "/elearning/mfk-a1-m8/comparer.svg",
      "word": "comparer"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/cafe.svg",
      "word": "du café"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/the.svg",
      "word": "du thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/avis.svg",
      "word": "un avis"
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
  "prompt": "Écrivez six phrases : deux plus, deux moins, deux aussi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis une comparaison à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma comparaison',
    'PE',
    $c$Objectif
Écrire trois comparaisons.

Consigne
Imitez le mot de Marc.

Support — Mot de Marc
Marc Nkurunziza
Le miel est plus sucré que la goyave.
Le thé est moins cher que le café.
La Table des Sources est aussi calme que le figuier.
Je vais prendre le thé.
Marc
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc trouve le café moins cher que le thé.",
  "correct": false,
  "explanation": "Le thé est moins cher que le café."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que va prendre Marc ?",
  "options": [
    {
      "text": "Le café",
      "correct": false
    },
    {
      "text": "Le thé",
      "correct": true
    },
    {
      "text": "Le miel seul",
      "correct": false
    },
    {
      "text": "Rien",
      "correct": false
    }
  ],
  "explanation": "« Je vais prendre le thé. »"
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
      "left": "miel",
      "right": "plus sucré"
    },
    {
      "left": "thé",
      "right": "moins cher"
    },
    {
      "left": "table",
      "right": "aussi calme"
    },
    {
      "left": "choix",
      "right": "le thé"
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
  "prompt": "Complétez :\nJe vais ___ le thé.",
  "answer": "prendre"
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
    "miel",
    "est",
    "plus",
    "sucré",
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
  "word": "goyave",
  "hint": "Le fruit du dessert, moins sucré que le miel."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le thé est plus moins cher que le café.",
  "correct_sentence": "Le thé est moins cher que le café.",
  "explanation": "Un seul mot : plus ou moins."
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
      "image_path": "/elearning/mfk-a1-m8/fruit.svg",
      "word": "un fruit"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/the.svg",
      "word": "du thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/table.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/comparer.svg",
      "word": "comparer"
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
  "prompt": "Écrivez cinq lignes : plus, moins, aussi, je vais prendre, un avis."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot de comparaison."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Plus, moins, aussi … que',
    'EL',
    $c$Objectif
Retenir les comparatifs A1.

Consigne
Apprenez la fiche.

Support — Fiche de Patrick
plus + adj + que : plus sucré que
moins + adj + que : moins cher que
aussi + adj + que : aussi calme que
plus de / moins de + nom : plus de thé
je vais le prendre
Attention : que (pas qui) après la comparaison.
Aussi (deux s).
Pas plus moins ensemble.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « ausi calme » (un s).",
  "correct": false,
  "explanation": "Aussi, deux s."
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
      "text": "plus sucré que",
      "correct": true
    },
    {
      "text": "plus sucré qui",
      "correct": false
    },
    {
      "text": "plus sucré de que",
      "correct": false
    },
    {
      "text": "le plus sucré que la",
      "correct": false
    }
  ],
  "explanation": "Plus sucré que."
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
      "left": "plus",
      "right": "davantage"
    },
    {
      "left": "moins",
      "right": "pas autant"
    },
    {
      "left": "aussi",
      "right": "égal"
    },
    {
      "left": "que",
      "right": "après l'adjectif"
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
  "prompt": "Complétez :\nJoël boit moins ___ thé qu'Hawa.",
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
    "Aussi",
    "calme",
    "que",
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
  "word": "simple",
  "hint": "C'est plus… : facile, sans souci."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est plus simple que le café est.",
  "correct_sentence": "C'est plus simple.",
  "explanation": "Pas besoin de répéter le verbe."
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
      "image_path": "/elearning/mfk-a1-m8/avis.svg",
      "word": "un avis"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/comparer.svg",
      "word": "comparer"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/cafe.svg",
      "word": "du café"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/menu.svg",
      "word": "un menu"
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
  "prompt": "Recopiez la fiche. Écrivez quatre comparaisons."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : plus sucré que, moins cher que, aussi calme que, plus de thé, je vais le prendre."
}$j$::jsonb,
    9
  );

  -- ===== Autrefois, maintenant =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Autrefois, maintenant'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Autrefois, maintenant', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Félicie raconte',
    'CO',
    $c$Objectif
Comprendre hier et aujourd'hui : imparfait / présent.

Consigne
Que faisait Félicie avant ? Que fait-elle maintenant ?

Support — Table des Sources
Félicie : Avant, j'étais à Mwezi-Haut. Je cuisinais pour ma famille.
Léa : Et maintenant ?
Félicie : Maintenant, je suis au Seuil. Je cuisine ici, midi.
Patrick : Tu voulais partir ?
Félicie : Oui. Je voulais un travail près du figuier. J'avais peu de temps, avant.
Aline : On mangeait trop vite, là-bas. Ici, on mange plus lentement.
Joël : Moi, je n'étais pas cuisinier. Je restais à la moto.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Félicie était à Mwezi-Haut, avant.",
  "correct": true,
  "explanation": "« j'étais à Mwezi-Haut »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait Félicie maintenant ?",
  "options": [
    {
      "text": "Elle cuisinait à Mwezi-Haut",
      "correct": false
    },
    {
      "text": "Elle est au Seuil et elle cuisine ici",
      "correct": true
    },
    {
      "text": "Elle reste à la moto",
      "correct": false
    },
    {
      "text": "Elle vend des vestes",
      "correct": false
    }
  ],
  "explanation": "Maintenant, je suis au Seuil."
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
      "right": "Mwezi-Haut"
    },
    {
      "left": "maintenant",
      "right": "le Seuil"
    },
    {
      "left": "on mangeait",
      "right": "trop vite"
    },
    {
      "left": "Joël",
      "right": "pas cuisinier"
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
  "prompt": "Complétez :\nAvant, j'___ à Mwezi-Haut. (être)",
  "answer": "étais"
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
    "cuisinais",
    "pour",
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
  "word": "étais",
  "hint": "Le verbe être, à l'imparfait, avec je."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avant je suis à Mwezi-Haut.",
  "correct_sentence": "Avant, j'étais à Mwezi-Haut.",
  "explanation": "Hier / avant : imparfait (j'étais)."
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
      "image_path": "/elearning/mfk-a1-m8/hier.svg",
      "word": "hier"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/cuisine.svg",
      "word": "la cuisine"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/table.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/assiette.svg",
      "word": "une assiette"
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
  "prompt": "Notez deux phrases avant (imparfait) et deux maintenant (présent)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Avant, j'étais à Mwezi-Haut. Je cuisinais. Maintenant, je suis au Seuil. On mange plus lentement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Carte d''autrefois',
    'CE',
    $c$Objectif
Lire un petit portrait hier / aujourd'hui.

Consigne
Lisez la carte.

Support — Carte de Félicie
Félicie Ndayishimiye
Avant : j'étais à Mwezi-Haut. Je cuisinais le soir. J'avais peu de temps. Je voulais partir.
Maintenant : je suis au Seuil. Je cuisine à midi. J'ai le figuier. On mange lentement.
Table des Sources — Rukiri-Nord
Portrait inventé.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Félicie cuisine encore le soir, maintenant.",
  "correct": false,
  "explanation": "Maintenant : à midi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que voulait Félicie, avant ?",
  "options": [
    {
      "text": "Rester à la moto",
      "correct": false
    },
    {
      "text": "Partir",
      "correct": true
    },
    {
      "text": "Acheter une veste",
      "correct": false
    },
    {
      "text": "Fermer la table",
      "correct": false
    }
  ],
  "explanation": "« Je voulais partir. »"
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
      "left": "j'étais",
      "right": "Mwezi-Haut"
    },
    {
      "left": "je cuisinais",
      "right": "le soir"
    },
    {
      "left": "je suis",
      "right": "Seuil"
    },
    {
      "left": "je cuisine",
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
  "prompt": "Complétez :\nJe ___ partir. (vouloir, avant)",
  "answer": "voulais"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'avais",
    "peu",
    "de",
    "temps",
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
  "word": "voulais",
  "hint": "Le verbe vouloir, à l'imparfait, avec je."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Maintenant j'étais au Seuil.",
  "correct_sentence": "Maintenant je suis au Seuil.",
  "explanation": "Maintenant : présent (je suis)."
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
      "image_path": "/elearning/mfk-a1-m8/hier.svg",
      "word": "hier"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/cuisine.svg",
      "word": "la cuisine"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/table.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/menu.svg",
      "word": "un menu"
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
  "prompt": "Recopiez la carte en deux colonnes : avant / maintenant."
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
    'PO — Dire j''étais, je suis',
    'PO',
    $c$Objectif
Parler d'une évolution : imparfait et présent.

Consigne
Répétez, puis dites un avant / maintenant (vrai ou inventé).

Support — Modèles de Félicie
J'étais à Mwezi-Haut.
Je cuisinais le soir.
J'avais peu de temps.
Je voulais partir.
Maintenant, je suis ici.
Je cuisine à midi.
On mangeait trop vite.
On mange lentement.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« J'étais » est l'imparfait de être.",
  "correct": true,
  "explanation": "Je suis → j'étais."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme d'imparfait est correcte ?",
  "options": [
    {
      "text": "je étais",
      "correct": false
    },
    {
      "text": "j'étais",
      "correct": true
    },
    {
      "text": "j'étaisais",
      "correct": false
    },
    {
      "text": "je suisais",
      "correct": false
    }
  ],
  "explanation": "J'étais."
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
      "right": "j'étais"
    },
    {
      "left": "avoir",
      "right": "j'avais"
    },
    {
      "left": "vouloir",
      "right": "je voulais"
    },
    {
      "left": "cuisiner",
      "right": "je cuisinais"
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
  "prompt": "Complétez :\nOn ___ trop vite. (manger, avant)",
  "answer": "mangeait"
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
  "word": "avait",
  "hint": "Le verbe avoir, à l'imparfait, avec il/elle."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On mangions trop vite.",
  "correct_sentence": "On mangeait trop vite.",
  "explanation": "On = il/elle : mangeait."
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
      "image_path": "/elearning/mfk-a1-m8/hier.svg",
      "word": "hier"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/cuisine.svg",
      "word": "la cuisine"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/assiette.svg",
      "word": "une assiette"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/poulet.svg",
      "word": "du poulet"
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
  "prompt": "Écrivez six phrases : trois imparfaits, trois présents."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre avant / maintenant."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma carte hier / aujourd''hui',
    'PE',
    $c$Objectif
Écrire un mini-portrait d'évolution.

Consigne
Imitez la carte de Joël.

Support — Carte de Joël
Joël Mugisha
Avant, j'étais toujours à la moto. Je n'avais pas le midi à table.
Je voulais un moment calme.
Maintenant, je mange à la Table des Sources. Je suis content.
Joël
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël mangeait déjà à la Table des Sources, avant.",
  "correct": false,
  "explanation": "Avant : à la moto, pas le midi à table."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que voulait Joël ?",
  "options": [
    {
      "text": "Un avion",
      "correct": false
    },
    {
      "text": "Un moment calme",
      "correct": true
    },
    {
      "text": "Du café seulement",
      "correct": false
    },
    {
      "text": "Partir au port",
      "correct": false
    }
  ],
  "explanation": "« un moment calme »."
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
      "right": "moto"
    },
    {
      "left": "je n'avais pas",
      "right": "le midi"
    },
    {
      "left": "je voulais",
      "right": "calme"
    },
    {
      "left": "maintenant",
      "right": "table"
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
  "prompt": "Complétez :\nMaintenant, je ___ content.",
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
    "voulais",
    "un",
    "moment",
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
  "word": "content",
  "hint": "Joël l'est, maintenant, à table."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avant je suis toujours à la moto.",
  "correct_sentence": "Avant, j'étais toujours à la moto.",
  "explanation": "Avant : j'étais."
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
      "image_path": "/elearning/mfk-a1-m8/hier.svg",
      "word": "hier"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/table.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/cuisine.svg",
      "word": "la cuisine"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/avis.svg",
      "word": "un avis"
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
  "prompt": "Écrivez cinq lignes : deux avant, deux maintenant, un je voulais."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre carte, calmement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Imparfait : être, avoir, vouloir',
    'EL',
    $c$Objectif
Retenir l'imparfait (je/tu/il) pour décrire avant.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
être : j'étais / tu étais / il était / nous étions
avoir : j'avais / tu avais / elle avait
vouloir : je voulais / il voulait
cuisiner : je cuisinais / on cuisinait
manger : je mangeais / on mangeait / nous mangions
Attention : j'étais (pas je suis au passé). Être : ét- (pas êt-).
Maintenant + présent. Avant + imparfait.
On mangeait (pas on mangions).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je suisais » à l'imparfait.",
  "correct": false,
  "explanation": "J'étais."
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
      "text": "nous mangeions",
      "correct": false
    },
    {
      "text": "nous mangions",
      "correct": true
    },
    {
      "text": "nous mangerons hier",
      "correct": false
    },
    {
      "text": "nous mangeait",
      "correct": false
    }
  ],
  "explanation": "Nous mangions (g + i, sans e)."
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
      "left": "j'étais",
      "right": "être"
    },
    {
      "left": "j'avais",
      "right": "avoir"
    },
    {
      "left": "je voulais",
      "right": "vouloir"
    },
    {
      "left": "je mangeais",
      "right": "manger"
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
  "prompt": "Complétez :\nNous ___ au Seuil. (être, avant)",
  "answer": "étions"
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
    "avait",
    "peu",
    "de",
    "temps",
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
  "word": "étions",
  "hint": "Le verbe être, à l'imparfait, avec nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On mangions trop vite.",
  "correct_sentence": "On mangeait trop vite.",
  "explanation": "On = il : mangeait."
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
      "image_path": "/elearning/mfk-a1-m8/hier.svg",
      "word": "hier"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/cuisine.svg",
      "word": "la cuisine"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/poisson.svg",
      "word": "du poisson"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/table.svg",
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
  "prompt": "Recopiez la fiche. Écrivez quatre imparfaits : étais, avais, voulais, mangeais."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : j'étais, tu étais, j'avais, je voulais, je cuisinais, on mangeait, maintenant je suis."
}$j$::jsonb,
    9
  );

  -- ===== S'habiller à la cour =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'S''habiller à la cour'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'S''habiller à la cour', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — À l''Atelier du Tissu',
    'CO',
    $c$Objectif
Comprendre un achat de vêtements : cette robe, ces sandales, une veste.

Consigne
Qui veut quoi ? Quelle couleur ?

Support — Atelier du Tissu
Dieudonné Hakizimana : Bonjour. Cette chemise ? Elle est bleue.
Léa : Non. Je voudrais cette robe. La robe rouge.
Hawa : Moi, ces sandales. Elles sont simples.
Joël : Une veste, s'il vous plaît. Pas trop chaude.
Rose : J'aime le pagne vert. Il est assez long.
Patrick : Ce pantalon est trop large. L'autre, s'il vous plaît.
Dieudonné : Je vais le prendre de côté. Il faut essayer.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa voudrait la robe rouge.",
  "correct": true,
  "explanation": "Léa : « cette robe. La robe rouge. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que veut Hawa ?",
  "options": [
    {
      "text": "Une veste",
      "correct": false
    },
    {
      "text": "Ces sandales",
      "correct": true
    },
    {
      "text": "Le pagne vert",
      "correct": false
    },
    {
      "text": "Ce pantalon",
      "correct": false
    }
  ],
  "explanation": "Hawa : « ces sandales »."
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
      "right": "robe rouge"
    },
    {
      "left": "Hawa",
      "right": "sandales"
    },
    {
      "left": "Joël",
      "right": "veste"
    },
    {
      "left": "Rose",
      "right": "pagne vert"
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
  "prompt": "Complétez :\nJe voudrais ___ robe. (démonstratif, féminin)",
  "answer": "cette"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Cette",
    "chemise",
    "est",
    "bleue",
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
  "word": "robe",
  "hint": "Léa la veut, rouge, à l'atelier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ce robe est rouge.",
  "correct_sentence": "Cette robe est rouge.",
  "explanation": "Robe = féminin : cette."
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
      "image_path": "/elearning/mfk-a1-m8/robe.svg",
      "word": "une robe"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/chemise.svg",
      "word": "une chemise"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/sandale.svg",
      "word": "des sandales"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/veste.svg",
      "word": "une veste"
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
  "prompt": "Notez quatre vêtements et une couleur."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Cette robe est rouge. Ces sandales sont simples. Ce pantalon est trop large. Je voudrais une veste."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Ardoise de l''atelier',
    'CE',
    $c$Objectif
Lire une liste de vêtements inventée.

Consigne
Lisez l'ardoise.

Support — Ardoise
Atelier du Tissu — Dieudonné
cette chemise bleue
cette robe rouge
ces sandales
une veste
un pantalon (trop large / l'autre)
un pagne vert
une jupe
Inventé pour la cour. Pas un magasin réel.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'atelier vend un avion.",
  "correct": false,
  "explanation": "Vêtements seulement."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle couleur a le pagne ?",
  "options": [
    {
      "text": "Rouge",
      "correct": false
    },
    {
      "text": "Bleu",
      "correct": false
    },
    {
      "text": "Vert",
      "correct": true
    },
    {
      "text": "Noir",
      "correct": false
    }
  ],
  "explanation": "Un pagne vert."
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
      "left": "chemise",
      "right": "bleue"
    },
    {
      "left": "robe",
      "right": "rouge"
    },
    {
      "left": "pagne",
      "right": "vert"
    },
    {
      "left": "pantalon",
      "right": "trop large"
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
  "prompt": "Complétez :\n___ sandales. (démonstratif, pluriel)",
  "answer": "Ces"
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
    "jupe",
    "s'il",
    "vous",
    "plaît",
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
  "word": "jupe",
  "hint": "Un vêtement, plus court qu'une robe."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ces chemise est bleue.",
  "correct_sentence": "Cette chemise est bleue.",
  "explanation": "Une chemise : cette."
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
      "image_path": "/elearning/mfk-a1-m8/pagne.svg",
      "word": "un pagne"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/pantalon.svg",
      "word": "un pantalon"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/jupe.svg",
      "word": "une jupe"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/tissu.svg",
      "word": "du tissu"
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
  "prompt": "Recopiez l'ardoise. Entourez le vêtement que vous choisiriez."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'ardoise, un vêtement, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire cette robe, ces sandales',
    'PO',
    $c$Objectif
Nommer un vêtement et une couleur.

Consigne
Répétez, puis choisissez un habit.

Support — Modèles de Dieudonné
Cette chemise est bleue.
Cette robe est rouge.
Ces sandales sont simples.
Ce pantalon est trop large.
Cette jupe est courte.
Ce pagne est vert.
Je voudrais une veste.
Il faut essayer.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Ces » va avec un nom pluriel.",
  "correct": true,
  "explanation": "Ces sandales."
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
      "text": "ce jupe",
      "correct": false
    },
    {
      "text": "cette jupe",
      "correct": true
    },
    {
      "text": "ces jupe",
      "correct": false
    },
    {
      "text": "cet jupe",
      "correct": false
    }
  ],
  "explanation": "Cette jupe."
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
      "left": "ce",
      "right": "pantalon, pagne"
    },
    {
      "left": "cette",
      "right": "chemise, robe, jupe"
    },
    {
      "left": "ces",
      "right": "sandales"
    },
    {
      "left": "une",
      "right": "veste"
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
  "prompt": "Complétez :\nCette chemise est ___. (couleur, féminin)",
  "answer": "bleue"
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
    "voudrais",
    "une",
    "veste",
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
  "word": "veste",
  "hint": "Joël en veut une, pas trop chaude."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La chemise est bleu.",
  "correct_sentence": "La chemise est bleue.",
  "explanation": "Chemise = elle : bleue."
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
      "image_path": "/elearning/mfk-a1-m8/chemise.svg",
      "word": "une chemise"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/jupe.svg",
      "word": "une jupe"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/veste.svg",
      "word": "une veste"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/pagne.svg",
      "word": "un pagne"
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
  "prompt": "Écrivez six phrases : trois ce/cette/ces, trois couleurs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre vêtement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon choix de tissu',
    'PE',
    $c$Objectif
Écrire un petit choix de vêtement.

Consigne
Imitez le mot d'Hawa.

Support — Mot d'Hawa
Hawa Diallo
Je voudrais ces sandales. Elles sont simples.
Cette robe est trop rouge pour moi.
Le pagne vert est assez long.
Merci, Dieudonné.
Hawa
Atelier du Tissu
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa veut la robe trop rouge.",
  "correct": false,
  "explanation": "Trop rouge pour elle. Elle veut les sandales."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment est le pagne, d'après Hawa ?",
  "options": [
    {
      "text": "Trop court",
      "correct": false
    },
    {
      "text": "Assez long",
      "correct": true
    },
    {
      "text": "Bleu",
      "correct": false
    },
    {
      "text": "Large comme un pantalon",
      "correct": false
    }
  ],
  "explanation": "« assez long »."
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
      "left": "sandales",
      "right": "simples"
    },
    {
      "left": "robe",
      "right": "trop rouge"
    },
    {
      "left": "pagne",
      "right": "assez long"
    },
    {
      "left": "merci",
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
  "prompt": "Complétez :\nLe pagne vert est assez ___.",
  "answer": "long"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ces",
    "sandales",
    "sont",
    "simples",
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
  "word": "sandales",
  "hint": "Hawa les voudrait, à l'atelier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ces sandales est simples.",
  "correct_sentence": "Ces sandales sont simples.",
  "explanation": "Sandales = elles : sont."
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
      "image_path": "/elearning/mfk-a1-m8/sandale.svg",
      "word": "des sandales"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/robe.svg",
      "word": "une robe"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/pagne.svg",
      "word": "un pagne"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/tissu.svg",
      "word": "du tissu"
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
  "prompt": "Écrivez cinq lignes : je voudrais, cette/ces, une couleur, trop, assez."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot, une phrase, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Vêtements, ce / cette / ces',
    'EL',
    $c$Objectif
Retenir les vêtements et les démonstratifs.

Consigne
Apprenez la fiche.

Support — Fiche de Dieudonné
ce pantalon / ce pagne
cet (devant voyelle : cet atelier)
cette chemise / cette robe / cette jupe / cette veste
ces sandales
couleurs : bleu / bleue ; vert / verte ; rouge (invariable)
trop large / assez long
Attention : cette (féminin). Ces (pluriel).
Bleue avec e au féminin.
Atelier du Tissu : lieu inventé.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « ce robe ».",
  "correct": false,
  "explanation": "Cette robe."
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
      "text": "un jupe",
      "correct": false
    },
    {
      "text": "une jupe",
      "correct": true
    },
    {
      "text": "une jupon",
      "correct": false
    },
    {
      "text": "un jupe rouge",
      "correct": false
    }
  ],
  "explanation": "Une jupe."
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
      "left": "un",
      "right": "pantalon, pagne"
    },
    {
      "left": "une",
      "right": "chemise, robe, jupe, veste"
    },
    {
      "left": "des",
      "right": "sandales"
    },
    {
      "left": "cette",
      "right": "féminin singulier"
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
  "prompt": "Complétez :\n___ pantalon est trop large.",
  "answer": "Ce"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Cette",
    "veste",
    "est",
    "simple",
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
  "word": "pagne",
  "hint": "Le tissu long, souvent vert, chez Dieudonné."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La jupe est vert.",
  "correct_sentence": "La jupe est verte.",
  "explanation": "Jupe = elle : verte."
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
      "image_path": "/elearning/mfk-a1-m8/pantalon.svg",
      "word": "un pantalon"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/veste.svg",
      "word": "une veste"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/jupe.svg",
      "word": "une jupe"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/chemise.svg",
      "word": "une chemise"
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : ce, cette, ces, une couleur."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : ce pantalon, cette robe, ces sandales, une veste, un pagne vert, trop large, assez long."
}$j$::jsonb,
    9
  );

  -- ===== Dire son avis =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Dire son avis'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Dire son avis', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Autour du thé, on dit',
    'CO',
    $c$Objectif
Comprendre un avis : vraiment, trop, assez, un peu.

Consigne
Qui trouve ça bon ? Qui n'aime pas trop ?

Support — Banc du figuier
Léa : La soupe est vraiment bonne.
Marc : Le poulet est assez chaud. Parfait.
Joël : Le thé est un peu trop sucré pour moi.
Hawa : Moi, je trouve ça franchement original. J'adore.
Patrick : La veste est trop chaude, non ?
Dieudonné : Un peu, oui. L'autre est mieux.
Aline : Ce n'est pas mal. C'est calme. J'aime bien.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa trouve la soupe vraiment bonne.",
  "correct": true,
  "explanation": "Léa : « vraiment bonne »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que pense Joël du thé ?",
  "options": [
    {
      "text": "Vraiment bon",
      "correct": false
    },
    {
      "text": "Un peu trop sucré",
      "correct": true
    },
    {
      "text": "Pas assez chaud",
      "correct": false
    },
    {
      "text": "Ridicule",
      "correct": false
    }
  ],
  "explanation": "Joël : « un peu trop sucré »."
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
      "right": "vraiment bonne"
    },
    {
      "left": "Marc",
      "right": "assez chaud"
    },
    {
      "left": "Joël",
      "right": "trop sucré"
    },
    {
      "left": "Hawa",
      "right": "franchement original"
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
  "prompt": "Complétez :\nLa veste est trop ___.",
  "answer": "chaude"
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
    "vraiment",
    "bon",
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
  "word": "avis",
  "hint": "Ce qu'on pense : bon, trop, assez…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le thé est trop de sucré.",
  "correct_sentence": "Le thé est trop sucré.",
  "explanation": "Trop + adjectif (pas trop de + adj.)."
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
      "image_path": "/elearning/mfk-a1-m8/avis.svg",
      "word": "un avis"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/trop.svg",
      "word": "trop"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/the.svg",
      "word": "du thé"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/veste.svg",
      "word": "une veste"
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
  "prompt": "Notez quatre avis (positif ou négatif)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : C'est vraiment bon. C'est assez chaud. C'est un peu trop sucré. Ce n'est pas mal. J'aime bien."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Feuille des avis',
    'CE',
    $c$Objectif
Lire des avis courts sur la cour.

Consigne
Lisez la feuille.

Support — Feuille du Seuil
Dire son avis
Table des Sources — vraiment bonne, assez calme
Thé — un peu trop sucré (Joël)
Pagne vert — franchement original (Hawa)
Veste — trop chaude (Patrick)
Radio Figuier — ce n'est pas mal
Atelier — j'aime bien
Inventé sous le figuier. Pas un magazine réel.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick trouve la veste trop chaude.",
  "correct": true,
  "explanation": "Veste — trop chaude (Patrick)."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui trouve le pagne franchement original ?",
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
      "text": "Hawa",
      "correct": true
    },
    {
      "text": "Félicie",
      "correct": false
    }
  ],
  "explanation": "Hawa."
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
      "left": "table",
      "right": "vraiment bonne"
    },
    {
      "left": "thé",
      "right": "trop sucré"
    },
    {
      "left": "pagne",
      "right": "original"
    },
    {
      "left": "radio",
      "right": "pas mal"
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
  "prompt": "Complétez :\nJ'aime ___.",
  "answer": "bien"
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
    "n'est",
    "pas",
    "mal",
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
  "word": "original",
  "hint": "Hawa trouve le pagne ainsi : pas comme les autres."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est trop de chaud.",
  "correct_sentence": "C'est trop chaud.",
  "explanation": "Trop + adjectif."
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
      "image_path": "/elearning/mfk-a1-m8/avis.svg",
      "word": "un avis"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/trop.svg",
      "word": "trop"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/pagne.svg",
      "word": "un pagne"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/table.svg",
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
  "prompt": "Recopiez quatre avis. Ajoutez le vôtre avec vraiment ou trop."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la feuille, un avis, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire vraiment, trop, assez',
    'PO',
    $c$Objectif
Donner un avis positif ou négatif.

Consigne
Répétez, puis donnez votre avis sur un plat ou un vêtement.

Support — Modèles d'Aline
C'est vraiment bon.
C'est assez calme.
C'est un peu trop sucré.
C'est trop chaud.
Ce n'est pas mal.
J'aime bien.
Je n'aime pas trop.
C'est franchement original.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je n'aime pas trop » est un avis plutôt négatif.",
  "correct": true,
  "explanation": "Moins fort que je déteste."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est positive ?",
  "options": [
    {
      "text": "C'est trop chaud",
      "correct": false
    },
    {
      "text": "Je n'aime pas trop",
      "correct": false
    },
    {
      "text": "C'est vraiment bon",
      "correct": true
    },
    {
      "text": "C'est un peu trop sucré",
      "correct": false
    }
  ],
  "explanation": "Vraiment bon."
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
      "left": "vraiment",
      "right": "positif fort"
    },
    {
      "left": "assez",
      "right": "suffisant"
    },
    {
      "left": "trop",
      "right": "excessif"
    },
    {
      "left": "pas mal",
      "right": "plutôt bien"
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
  "prompt": "Complétez :\nJe n'aime pas ___.",
  "answer": "trop"
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
    "assez",
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
  "word": "vraiment",
  "hint": "Pour renforcer : c'est … bon."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est assez de calme. (avis sur le lieu)",
  "correct_sentence": "C'est assez calme.",
  "explanation": "Assez + adjectif."
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
      "image_path": "/elearning/mfk-a1-m8/avis.svg",
      "word": "un avis"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/trop.svg",
      "word": "trop"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/assiette.svg",
      "word": "une assiette"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/robe.svg",
      "word": "une robe"
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
  "prompt": "Écrivez six avis : deux vraiment, deux trop, un assez, un j'aime bien."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux avis personnels."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon avis du jour',
    'PE',
    $c$Objectif
Écrire quatre avis.

Consigne
Imitez le mot d'Aline.

Support — Mot d'Aline
Aline Uwase
La soupe est vraiment bonne.
Le thé est un peu trop sucré.
L'atelier est assez calme.
La veste ? Je n'aime pas trop : trop chaude.
Sinon, j'aime bien le Seuil.
Aline
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline aime trop la veste.",
  "correct": false,
  "explanation": "Elle n'aime pas trop : trop chaude."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment Aline trouve-t-elle l'atelier ?",
  "options": [
    {
      "text": "Trop chaud",
      "correct": false
    },
    {
      "text": "Assez calme",
      "correct": true
    },
    {
      "text": "Ridicule",
      "correct": false
    },
    {
      "text": "Fermé",
      "correct": false
    }
  ],
  "explanation": "« assez calme »."
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
      "left": "soupe",
      "right": "vraiment bonne"
    },
    {
      "left": "thé",
      "right": "trop sucré"
    },
    {
      "left": "atelier",
      "right": "assez calme"
    },
    {
      "left": "veste",
      "right": "je n'aime pas trop"
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
  "prompt": "Complétez :\nLa soupe est vraiment ___.",
  "answer": "bonne"
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
    "bien",
    "le",
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
  "word": "calme",
  "hint": "Pas trop de bruit, à l'atelier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La soupe est vraiment bon.",
  "correct_sentence": "La soupe est vraiment bonne.",
  "explanation": "Soupe = elle : bonne."
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
      "image_path": "/elearning/mfk-a1-m8/avis.svg",
      "word": "un avis"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/assiette.svg",
      "word": "une assiette"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/veste.svg",
      "word": "une veste"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/trop.svg",
      "word": "trop"
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
  "prompt": "Écrivez cinq lignes : vraiment, trop, assez, je n'aime pas trop, j'aime bien."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot d'avis."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Trop, assez, vraiment',
    'EL',
    $c$Objectif
Retenir les mots pour un avis A1.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
positif : vraiment bon / j'aime bien / ce n'est pas mal / franchement original
degré : assez calme / trop chaud / un peu trop sucré
négatif : je n'aime pas trop
trop + adjectif : trop sucré, trop chaude
assez + adjectif : assez long, assez calme
trop de + nom : trop de sucre
Attention : trop chaude (accord). Vraiment bonne (accord).
Pas trop de + adjectif.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « trop de chaud » pour la veste.",
  "correct": false,
  "explanation": "Trop chaude (adjectif)."
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
      "text": "c'est trop de sucré",
      "correct": false
    },
    {
      "text": "c'est trop sucré",
      "correct": true
    },
    {
      "text": "c'est trop sucres",
      "correct": false
    },
    {
      "text": "c'est de trop sucré",
      "correct": false
    }
  ],
  "explanation": "Trop sucré."
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
      "left": "vraiment",
      "right": "renforce le positif"
    },
    {
      "left": "assez",
      "right": "suffit"
    },
    {
      "left": "trop",
      "right": "trop fort"
    },
    {
      "left": "j'aime bien",
      "right": "positif simple"
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
  "prompt": "Complétez :\nC'est un peu trop ___. (sucre, adjectif)",
  "answer": "sucré"
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
    "trop",
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
  "word": "assez",
  "hint": "Ni trop ni trop peu : ça suffit."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La veste est trop chaud.",
  "correct_sentence": "La veste est trop chaude.",
  "explanation": "Veste = elle : chaude."
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
      "image_path": "/elearning/mfk-a1-m8/trop.svg",
      "word": "trop"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/avis.svg",
      "word": "un avis"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/veste.svg",
      "word": "une veste"
    },
    {
      "image_path": "/elearning/mfk-a1-m8/the.svg",
      "word": "du thé"
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
  "prompt": "Recopiez la fiche. Écrivez quatre avis : vraiment, assez, trop, j'aime bien."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : vraiment bon, assez calme, trop chaud, un peu trop sucré, ce n'est pas mal, j'aime bien, je n'aime pas trop."
}$j$::jsonb,
    9
  );

END;
$$;
