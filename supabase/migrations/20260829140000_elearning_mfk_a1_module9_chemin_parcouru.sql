/*
  Seed eLearning MFK — Module 9 A1 « Retour sur le chemin parcouru »

  Même micro-monde que les Modules 3 à 8 : cour « Le Seuil des Sources », Rukiri-Nord.
  Cahier du chemin sous le figuier : bilan A1, ce que l'on sait faire, la suite.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a1-m9/
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
  v_module_title text := 'A1 — Retour sur le chemin parcouru';
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
      'Seed A1 Module 9 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed Module 9 : enseignant % (%)', v_teacher_email, v_teacher_id;

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
      'Grande étape 9 : relire le chemin A1 au Seuil des Sources — se présenter à nouveau, dire ce qu''on a appris, ce qu''on sait faire, ce qui a changé, la suite au futur, et laisser une page dans le Cahier du chemin (Rukiri-Nord).',
      'A1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape 9 : relire le chemin A1 au Seuil des Sources — se présenter à nouveau, dire ce qu''on a appris, ce qu''on sait faire, ce qui a changé, la suite au futur, et laisser une page dans le Cahier du chemin (Rukiri-Nord).',
      cefr_level = 'A1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Premiers pas =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Premiers pas'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Premiers pas', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — On se dit bonjour, encore',
    'CO',
    $c$Objectif
Reconnaître une présentation : je m'appelle, je suis, j'habite.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui est qui, au Seuil ?

Support — Cahier du chemin, banc du figuier
Patrick : On ouvre le cahier. Léa, tu te présentes ?
Léa : Je m'appelle Léa Niyonzima. J'habite à Rukiri-Nord. Je suis apprenante.
Noura : Moi, je m'appelle Noura Sarr. Je suis de passage. J'habite près du Port de la Brise.
Joël : Je m'appelle Joël. Je suis au Seuil tous les jours. C'est ma cour.
Aline : Bonjour. Je m'appelle Aline. Je suis formatrice. Bienvenue, encore.
Marc : Moi, c'est Marc. J'ai vingt-deux ans.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa habite à Rukiri-Nord.",
  "correct": true,
  "explanation": "Léa : « J'habite à Rukiri-Nord. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui est formatrice ?",
  "options": [
    {
      "text": "Léa",
      "correct": false
    },
    {
      "text": "Noura",
      "correct": false
    },
    {
      "text": "Aline",
      "correct": true
    },
    {
      "text": "Joël",
      "correct": false
    }
  ],
  "explanation": "Aline : « Je suis formatrice. »"
}$j$::jsonb,
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
      "right": "apprenante"
    },
    {
      "left": "Noura",
      "right": "de passage"
    },
    {
      "left": "Joël",
      "right": "tous les jours"
    },
    {
      "left": "Aline",
      "right": "formatrice"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe m'___ Léa.",
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
    "J'habite",
    "à",
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
  "word": "bonjour",
  "hint": "Le premier mot, pour saluer."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je m'appelle Léa. Je habite à Rukiri-Nord.",
  "correct_sentence": "Je m'appelle Léa. J'habite à Rukiri-Nord.",
  "explanation": "J'habite (élision)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/portrait.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/groupe.svg",
      "word": "le groupe"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/figuier.svg",
      "word": "le figuier"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/cahier.svg",
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
  "prompt": "Notez trois présentations : nom, lieu, rôle."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Bonjour. Je m'appelle… J'habite à… Je suis apprenant / apprenante. C'est le Seuil."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Page d''accueil du cahier',
    'CE',
    $c$Objectif
Lire des cartes d'identité inventées du Seuil.

Consigne
Lisez les cartes.

Support — Cahier du chemin
Léa Niyonzima — j'habite à Rukiri-Nord — je suis apprenante
Marc Nkurunziza — j'ai vingt-deux ans — je suis au Seuil
Noura Sarr — j'habite près du port — je suis de passage
Aline Uwase — je suis formatrice — bienvenue
Joël Mugisha — c'est ma cour — tous les jours
Règle : une phrase avec je m'appelle, une avec j'habite ou je suis.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc a vingt-deux ans.",
  "correct": true,
  "explanation": "Carte Marc : vingt-deux ans."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où habite Noura ?",
  "options": [
    {
      "text": "À Mwezi-Haut",
      "correct": false
    },
    {
      "text": "Près du port",
      "correct": true
    },
    {
      "text": "Sous le minibus",
      "correct": false
    },
    {
      "text": "À l'infirmerie",
      "correct": false
    }
  ],
  "explanation": "« près du port »."
}$j$::jsonb,
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
      "right": "Rukiri-Nord"
    },
    {
      "left": "Marc",
      "right": "vingt-deux ans"
    },
    {
      "left": "Noura",
      "right": "port"
    },
    {
      "left": "Joël",
      "right": "sa cour"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ formatrice.",
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
    "C'est",
    "ma",
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
  "word": "habite",
  "hint": "Le verbe pour dire où on vit, avec je : j'…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis apprenante. J'ai vingt-deux an.",
  "correct_sentence": "Je suis apprenante. J'ai vingt-deux ans.",
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
      "image_path": "/elearning/mfk-a1-m9/page.svg",
      "word": "une page"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/portrait.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/pierre.svg",
      "word": "une pierre"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/chemin.svg",
      "word": "un chemin"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez deux cartes. Ajoutez la vôtre : je m'appelle, j'habite, je suis."
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
    'PO — Se présenter encore',
    'PO',
    $c$Objectif
Se présenter clairement : je m'appelle, j'habite, je suis, j'ai … ans.

Consigne
Répétez, puis présentez-vous (vrai ou inventé).

Support — Modèles de Léa
Bonjour.
Je m'appelle Léa.
J'habite à Rukiri-Nord.
Je suis apprenante.
J'ai vingt et un ans.
C'est le Seuil des Sources.
Enchantée.
Au revoir.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Enchantée » s'accorde au féminin.",
  "correct": true,
  "explanation": "Léa = elle : enchantée."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase dit le lieu ?",
  "options": [
    {
      "text": "Je m'appelle Léa",
      "correct": false
    },
    {
      "text": "J'habite à Rukiri-Nord",
      "correct": true
    },
    {
      "text": "J'ai vingt et un ans",
      "correct": false
    },
    {
      "text": "Enchantée",
      "correct": false
    }
  ],
  "explanation": "J'habite à…"
}$j$::jsonb,
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
      "left": "j'habite",
      "right": "lieu"
    },
    {
      "left": "je suis",
      "right": "rôle"
    },
    {
      "left": "j'ai",
      "right": "âge"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'ai vingt et un ___.",
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
    "Je",
    "m'appelle",
    "Léa",
    "."
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
  "hint": "Je m'… : pour dire son nom."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis enchanté.",
  "correct_sentence": "Je suis enchantée.",
  "explanation": "Léa = elle : enchantée."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/groupe.svg",
      "word": "le groupe"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/portrait.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/merci.svg",
      "word": "merci"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/adieu.svg",
      "word": "au revoir"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases de présentation."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre présentation."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma carte du cahier',
    'PE',
    $c$Objectif
Écrire une carte de présentation.

Consigne
Imitez la carte de Noura.

Support — Carte de Noura
Noura Sarr
Bonjour.
Je m'appelle Noura Sarr.
J'habite près du Port de la Brise.
Je suis de passage au Seuil.
Enchantée.
Noura
Cahier du chemin
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Noura habite sous le figuier.",
  "correct": false,
  "explanation": "Près du Port de la Brise."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Noura est…",
  "options": [
    {
      "text": "Formatrice",
      "correct": false
    },
    {
      "text": "De passage",
      "correct": true
    },
    {
      "text": "Cuisinière",
      "correct": false
    },
    {
      "text": "À la moto seulement",
      "correct": false
    }
  ],
  "explanation": "« de passage au Seuil »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "nom",
      "right": "Noura Sarr"
    },
    {
      "left": "lieu",
      "right": "port"
    },
    {
      "left": "rôle",
      "right": "de passage"
    },
    {
      "left": "formule",
      "right": "enchantée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ de passage au Seuil.",
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
    "Bonjour",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "Noura",
  "hint": "Le prénom de Sarr, de passage."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je m'appelle Noura. J'habite près du port. Je suis enchanté.",
  "correct_sentence": "Je m'appelle Noura. J'habite près du port. Je suis enchantée.",
  "explanation": "Noura = elle : enchantée."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/cahier.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/page.svg",
      "word": "une page"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/chemin.svg",
      "word": "un chemin"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/portrait.svg",
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
  "prompt": "Écrivez cinq lignes : bonjour, je m'appelle, j'habite, je suis, enchanté(e)."
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
    'EL — Je m''appelle, j''habite, je suis',
    'EL',
    $c$Objectif
Retenir les formules de présentation A1.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
je m'appelle / tu t'appelles / il s'appelle
j'habite à / au / près de
je suis + rôle
j'ai … ans (pluriel)
enchanté / enchantée
bonjour / au revoir
Attention : j'habite (pas je habite). Ans au pluriel.
Enchantée au féminin.
Cahier du chemin : document inventé du Seuil.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « j'ai vingt ans » (sans s).",
  "correct": false,
  "explanation": "Ans, avec s."
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
      "text": "je habite",
      "correct": false
    },
    {
      "text": "j'habite",
      "correct": true
    },
    {
      "text": "je habites",
      "correct": false
    },
    {
      "text": "j'habiter",
      "correct": false
    }
  ],
  "explanation": "J'habite."
}$j$::jsonb,
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
      "right": "je m'appelle"
    },
    {
      "left": "habiter",
      "right": "j'habite"
    },
    {
      "left": "être",
      "right": "je suis"
    },
    {
      "left": "avoir",
      "right": "j'ai … ans"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTu t'___ comment ?",
  "answer": "appelles"
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
    "s'appelle",
    "Marc",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ans",
  "hint": "Après le nombre, pour l'âge, au pluriel."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tu t'appelle Léa.",
  "correct_sentence": "Tu t'appelles Léa.",
  "explanation": "Tu t'appelles (avec s)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/question.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/reponse.svg",
      "word": "une réponse"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/pas.svg",
      "word": "un pas"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/figuier.svg",
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
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : m'appelle, habite, suis, j'ai … ans."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : je m'appelle, j'habite, je suis, j'ai … ans, enchanté, enchantée, bonjour, au revoir."
}$j$::jsonb,
    9
  );

  -- ===== Ce que j'ai appris =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Ce que j''ai appris'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Ce que j''ai appris', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — On a ouvert le cahier',
    'CO',
    $c$Objectif
Comprendre un bilan au passé composé : j'ai appris, nous avons écouté.

Consigne
Qu'est-ce qu'ils ont fait ? Qui est arrivée ?

Support — Sous le figuier
Léa : J'ai appris beaucoup de mots. J'ai écouté Radio Figuier.
Marc : Nous avons lu le carnet de route. J'ai écrit une page.
Hawa : Je suis arrivée un lundi. J'ai choisi le Seuil.
Joël : Moi, j'ai travaillé à la moto. Je n'ai pas tout écrit.
Aline : Vous avez bien avancé. On a ouvert le Cahier du chemin.
Patrick : J'ai demandé l'heure. Ce n'est pas grave.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa a écouté Radio Figuier.",
  "correct": true,
  "explanation": "Léa : « J'ai écouté Radio Figuier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel jour Hawa est-elle arrivée ?",
  "options": [
    {
      "text": "Un samedi",
      "correct": false
    },
    {
      "text": "Un lundi",
      "correct": true
    },
    {
      "text": "Un dimanche",
      "correct": false
    },
    {
      "text": "Un vendredi",
      "correct": false
    }
  ],
  "explanation": "Hawa : « un lundi »."
}$j$::jsonb,
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
      "right": "mots et radio"
    },
    {
      "left": "Marc",
      "right": "lu et écrit"
    },
    {
      "left": "Hawa",
      "right": "arrivée lundi"
    },
    {
      "left": "Joël",
      "right": "moto"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'___ beaucoup de mots.",
  "answer": "ai appris"
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
    "le",
    "carnet",
    "."
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
  "sentence_with_error": "J'ai apprendre beaucoup de mots.",
  "correct_sentence": "J'ai appris beaucoup de mots.",
  "explanation": "Appris (participe), pas apprendre."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/apprendre.svg",
      "word": "apprendre"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/cahier.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/radio.svg",
      "word": "la radio"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/page.svg",
      "word": "une page"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez quatre actions au passé composé."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : J'ai appris. J'ai écouté. Nous avons lu. Je suis arrivée. J'ai écrit une page."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Liste du chemin',
    'CE',
    $c$Objectif
Lire une liste de choses apprises.

Consigne
Lisez la liste.

Support — Liste du Cahier du chemin
Cette saison, au Seuil
Léa — j'ai appris l'heure et le futur
Marc — j'ai lu le carnet, j'ai écrit
Hawa — je suis arrivée, j'ai choisi
Joël — j'ai travaillé, je n'ai pas tout noté
Aline — vous avez écouté, vous avez parlé
Rien n'est copié d'un examen. C'est notre liste.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël a tout noté.",
  "correct": false,
  "explanation": "« je n'ai pas tout noté »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qu'est-ce que Léa a appris, d'après la liste ?",
  "options": [
    {
      "text": "La moto seulement",
      "correct": false
    },
    {
      "text": "L'heure et le futur",
      "correct": true
    },
    {
      "text": "Un avion",
      "correct": false
    },
    {
      "text": "La neige",
      "correct": false
    }
  ],
  "explanation": "L'heure et le futur."
}$j$::jsonb,
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
      "right": "heure, futur"
    },
    {
      "left": "Marc",
      "right": "lu, écrit"
    },
    {
      "left": "Hawa",
      "right": "arrivée"
    },
    {
      "left": "Aline",
      "right": "écouté, parlé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ arrivée un lundi.",
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
    "écrit",
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
  "sentence_with_error": "Hawa a arrivée un lundi.",
  "correct_sentence": "Hawa est arrivée un lundi.",
  "explanation": "Arriver : être + arrivée."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/apprendre.svg",
      "word": "apprendre"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/page.svg",
      "word": "une page"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/radio.svg",
      "word": "la radio"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/bilan.svg",
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
  "prompt": "Recopiez trois lignes. Ajoutez : j'ai… / je suis…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la liste, un nom, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire j''ai appris, je suis arrivé(e)',
    'PO',
    $c$Objectif
Raconter ce qu'on a fait : passé composé.

Consigne
Répétez, puis dites deux choses apprises.

Support — Modèles de Marc
J'ai appris un mot.
J'ai écouté.
Nous avons lu.
J'ai écrit.
Je suis arrivé.
Elle est arrivée.
Je n'ai pas tout noté.
Vous avez bien avancé.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Elle est arrivée » s'accorde au féminin.",
  "correct": true,
  "explanation": "Être + arrivée."
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
      "text": "J'apprends",
      "correct": false
    },
    {
      "text": "Je vais apprendre",
      "correct": false
    },
    {
      "text": "J'ai appris",
      "correct": true
    },
    {
      "text": "J'apprendrai",
      "correct": false
    }
  ],
  "explanation": "J'ai appris."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avoir",
      "right": "j'ai écouté"
    },
    {
      "left": "être",
      "right": "je suis arrivé"
    },
    {
      "left": "négation",
      "right": "je n'ai pas"
    },
    {
      "left": "nous",
      "right": "avons lu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nElle est ___. (arriver, féminin)",
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
    "Vous",
    "avez",
    "bien",
    "avancé",
    "."
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
  "hint": "Le participe de écouter, après j'ai."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis arrivé.",
  "correct_sentence": "Je suis arrivée.",
  "explanation": "Hawa = elle : arrivée."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/arriver.svg",
      "word": "arriver"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/apprendre.svg",
      "word": "apprendre"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/cahier.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/page.svg",
      "word": "une page"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases au passé composé (quatre avoir, deux être)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux choses que vous avez apprises."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma liste d''appris',
    'PE',
    $c$Objectif
Écrire un mini-bilan au passé composé.

Consigne
Imitez la page de Léa.

Support — Page de Léa
Léa Niyonzima
J'ai appris l'heure. J'ai écouté la radio.
Je suis arrivée un lundi. J'ai choisi le Seuil.
Je n'ai pas tout écrit. J'ai avancé.
Léa
Cahier du chemin
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa a tout écrit.",
  "correct": false,
  "explanation": "« Je n'ai pas tout écrit. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel jour Léa est-elle arrivée ?",
  "options": [
    {
      "text": "Un dimanche",
      "correct": false
    },
    {
      "text": "Un lundi",
      "correct": true
    },
    {
      "text": "Un mercredi",
      "correct": false
    },
    {
      "text": "Un samedi",
      "correct": false
    }
  ],
  "explanation": "Un lundi."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "j'ai appris",
      "right": "l'heure"
    },
    {
      "left": "j'ai écouté",
      "right": "radio"
    },
    {
      "left": "je suis arrivée",
      "right": "lundi"
    },
    {
      "left": "j'ai choisi",
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
  "prompt": "Complétez :\nJ'ai ___ le Seuil.",
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
    "J'ai",
    "avancé",
    "."
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
  "hint": "Le participe, après j'ai, quand on a pris une option."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai écouté. Je suis arrivé.",
  "correct_sentence": "J'ai écouté. Je suis arrivée.",
  "explanation": "Léa = elle : arrivée."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/page.svg",
      "word": "une page"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/radio.svg",
      "word": "la radio"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/apprendre.svg",
      "word": "apprendre"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/bilan.svg",
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
  "prompt": "Écrivez cinq lignes : appris, écouté, arrivé(e), choisi, n'ai pas."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre page, calmement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Passé composé : avoir et être',
    'EL',
    $c$Objectif
Retenir j'ai + participe et je suis arrivé(e).

Consigne
Apprenez la fiche.

Support — Fiche de Patrick
avoir : j'ai écouté / lu / écrit / appris / choisi
être : je suis arrivé / elle est arrivée
négation : je n'ai pas tout noté
nous avons lu
vous avez avancé
Attention : appris (pas apprendre). Arrivée au féminin.
Pas elle a arrivée.
Cahier du chemin : inventé.
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
      "text": "elle a arrivée",
      "correct": false
    },
    {
      "text": "elle est arrivée",
      "correct": true
    },
    {
      "text": "elle est arrivé",
      "correct": false
    },
    {
      "text": "elle a arrivé",
      "correct": false
    }
  ],
  "explanation": "Elle est arrivée."
}$j$::jsonb,
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
      "left": "arriver",
      "right": "arrivé / arrivée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ lu le carnet.",
  "answer": "avons"
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
    "tout",
    "noté",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lu",
  "hint": "Le participe de lire, après j'ai / nous avons."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous avons lu. Vous a avancé.",
  "correct_sentence": "Nous avons lu. Vous avez avancé.",
  "explanation": "Vous avez."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/apprendre.svg",
      "word": "apprendre"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/cahier.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/arriver.svg",
      "word": "arriver"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/bilan.svg",
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
  "prompt": "Recopiez la fiche. Écrivez quatre passés composés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : j'ai appris, j'ai lu, j'ai écrit, je suis arrivé, elle est arrivée, nous avons lu."
}$j$::jsonb,
    9
  );

  -- ===== Je sais le faire =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Je sais le faire'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Je sais le faire', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Qu''est-ce qu''on sait faire ?',
    'CO',
    $c$Objectif
Comprendre je peux, je sais, on peut + infinitif.

Consigne
Qui peut faire quoi, maintenant ?

Support — Tour de parole
Aline : Maintenant, vous pouvez demander l'heure.
Léa : Je sais dire bonjour. Je peux lire un menu.
Hawa : On peut acheter au marché. Je sais compter.
Joël : Je peux réparer la moto. Je ne sais pas tout écrire.
Marc : On peut comparer deux thés. C'est simple.
Patrick : Il faut oser. On peut se tromper.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa sait dire bonjour.",
  "correct": true,
  "explanation": "Léa : « Je sais dire bonjour. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que peut faire Joël ?",
  "options": [
    {
      "text": "Tout écrire",
      "correct": false
    },
    {
      "text": "Réparer la moto",
      "correct": true
    },
    {
      "text": "Fermer le Seuil",
      "correct": false
    },
    {
      "text": "Voler",
      "correct": false
    }
  ],
  "explanation": "Joël : « réparer la moto »."
}$j$::jsonb,
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
      "right": "lire un menu"
    },
    {
      "left": "Hawa",
      "right": "compter"
    },
    {
      "left": "Joël",
      "right": "moto"
    },
    {
      "left": "Marc",
      "right": "comparer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ dire bonjour.",
  "answer": "sais"
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
    "demander",
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
  "word": "peux",
  "hint": "Je… + infinitif : c'est possible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je peux de lire un menu.",
  "correct_sentence": "Je peux lire un menu.",
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
      "image_path": "/elearning/mfk-a1-m9/pouvoir.svg",
      "word": "pouvoir"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/savoir.svg",
      "word": "savoir"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/question.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/table.svg",
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
  "prompt": "Notez quatre « je peux / je sais / on peut »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je sais dire bonjour. Je peux lire un menu. On peut demander. Je ne sais pas tout écrire."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Affiche « on peut »',
    'CE',
    $c$Objectif
Lire une affiche de savoir-faire du Seuil.

Consigne
Lisez l'affiche.

Support — Affiche ocre
Au Seuil, maintenant
on peut demander son chemin
on peut lire un menu
on peut acheter au marché
je sais dire l'heure
je peux parler un peu
il faut oser
Affiche inventée. Pas un diplôme réel.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'affiche dit qu'il faut oser.",
  "correct": true,
  "explanation": "« il faut oser »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que peut-on lire, d'après l'affiche ?",
  "options": [
    {
      "text": "Un avion",
      "correct": false
    },
    {
      "text": "Un menu",
      "correct": true
    },
    {
      "text": "Un code secret",
      "correct": false
    },
    {
      "text": "Une carte bancaire",
      "correct": false
    }
  ],
  "explanation": "Lire un menu."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "demander",
      "right": "chemin"
    },
    {
      "left": "lire",
      "right": "menu"
    },
    {
      "left": "acheter",
      "right": "marché"
    },
    {
      "left": "dire",
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
  "prompt": "Complétez :\nOn ___ acheter au marché.",
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
    "Il",
    "faut",
    "oser",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "savoir",
  "hint": "Je… + infinitif : c'est dans la tête."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On peuts lire un menu.",
  "correct_sentence": "On peut lire un menu.",
  "explanation": "On peut, sans s."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/savoir.svg",
      "word": "savoir"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/table.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/question.svg",
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
  "prompt": "Recopiez l'affiche. Ajoutez : je peux… / je sais…"
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
    'PO — Dire je peux, je sais, on peut',
    'PO',
    $c$Objectif
Parler de ses savoir-faire A1.

Consigne
Répétez, puis dites deux choses que vous savez faire.

Support — Modèles d'Hawa
Je peux parler.
Je sais compter.
On peut demander.
Je ne sais pas tout.
Je peux lire un peu.
On peut se tromper.
Il faut oser.
C'est possible.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il faut oser » reste à la 3e personne.",
  "correct": true,
  "explanation": "Toujours il faut."
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
      "text": "je peux de parler",
      "correct": false
    },
    {
      "text": "je peux parler",
      "correct": true
    },
    {
      "text": "je peux parle",
      "correct": false
    },
    {
      "text": "je peux parlé",
      "correct": false
    }
  ],
  "explanation": "Je peux + infinitif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je peux",
      "right": "possibilité"
    },
    {
      "left": "je sais",
      "right": "connaissance"
    },
    {
      "left": "on peut",
      "right": "le groupe"
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
  "prompt": "Complétez :\nJe ne ___ pas tout.",
  "answer": "sais"
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
    "possible",
    "."
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
  "hint": "Il faut… : ne pas avoir trop peur."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je faut oser.",
  "correct_sentence": "Il faut oser.",
  "explanation": "Toujours il faut, pas je faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/pouvoir.svg",
      "word": "pouvoir"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/savoir.svg",
      "word": "savoir"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/reponse.svg",
      "word": "une réponse"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/ensemble.svg",
      "word": "ensemble"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases : deux peux, deux sais, un on peut, un il faut."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux savoir-faire."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma liste « je peux »',
    'PE',
    $c$Objectif
Écrire ce qu'on sait faire.

Consigne
Imitez la liste de Marc.

Support — Liste de Marc
Marc Nkurunziza
Je sais lire un carnet.
Je peux comparer deux prix.
On peut demander à Rose.
Je ne sais pas tout.
Il faut oser.
Marc
Cahier du chemin
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc sait tout.",
  "correct": false,
  "explanation": "« Je ne sais pas tout. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que peut comparer Marc ?",
  "options": [
    {
      "text": "Deux avions",
      "correct": false
    },
    {
      "text": "Deux prix",
      "correct": true
    },
    {
      "text": "Deux infirmeries",
      "correct": false
    },
    {
      "text": "Deux mers",
      "correct": false
    }
  ],
  "explanation": "Deux prix."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je sais",
      "right": "lire"
    },
    {
      "left": "je peux",
      "right": "comparer"
    },
    {
      "left": "on peut",
      "right": "demander"
    },
    {
      "left": "il faut",
      "right": "oser"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn peut demander ___ Rose.",
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
    "peux",
    "comparer",
    "deux",
    "prix",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "peut",
  "hint": "On… + infinitif : le groupe, comme il."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On peut demander à Rose. Je sais de lire.",
  "correct_sentence": "On peut demander à Rose. Je sais lire.",
  "explanation": "Savoir + infinitif, sans de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/savoir.svg",
      "word": "savoir"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/page.svg",
      "word": "une page"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/pouvoir.svg",
      "word": "pouvoir"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez cinq lignes : sais, peux, on peut, ne sais pas, il faut."
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
    'EL — Pouvoir, savoir, il faut',
    'EL',
    $c$Objectif
Retenir je peux / je sais / on peut / il faut + infinitif.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
pouvoir : je peux / tu peux / on peut / nous pouvons
savoir : je sais / tu sais / il sait
il faut + infinitif (seulement il)
je ne sais pas tout
Attention : je peux (pas je peut). On peut (pas on peuts).
Pas je faut. Pas je peux de lire.
Infinitif après : parler, lire, demander.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je peut parler ».",
  "correct": false,
  "explanation": "Je peux."
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
      "text": "il fauts oser",
      "correct": false
    },
    {
      "text": "je faut oser",
      "correct": false
    },
    {
      "text": "il faut oser",
      "correct": true
    },
    {
      "text": "ils faut oser",
      "correct": false
    }
  ],
  "explanation": "Il faut oser."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je peux",
      "right": "pouvoir"
    },
    {
      "left": "je sais",
      "right": "savoir"
    },
    {
      "left": "on peut",
      "right": "on = il"
    },
    {
      "left": "il faut",
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
  "prompt": "Complétez :\nTu ___ compter. (savoir)",
  "answer": "sais"
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
    "pouvons",
    "demander",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pouvons",
  "hint": "Le verbe pouvoir, avec nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tu peux parler. Il sait de compter.",
  "correct_sentence": "Tu peux parler. Il sait compter.",
  "explanation": "Sait + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/pouvoir.svg",
      "word": "pouvoir"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/savoir.svg",
      "word": "savoir"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/question.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/ensemble.svg",
      "word": "ensemble"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : peux, sais, peut, faut."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : je peux, tu peux, on peut, je sais, tu sais, il faut oser, je ne sais pas tout."
}$j$::jsonb,
    9
  );

  -- ===== Ce qui a changé =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Ce qui a changé'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Ce qui a changé', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Avant, je ne savais pas',
    'CO',
    $c$Objectif
Comprendre un changement : avant + imparfait, maintenant + présent.

Consigne
Qu'est-ce qui a changé pour Léa ? Pour Joël ?

Support — Cahier ouvert
Léa : Avant, je ne savais pas demander. Maintenant, je demande.
Joël : Avant, j'étais toujours à la moto. Maintenant, je mange à table.
Hawa : Avant, j'avais peur. Maintenant, je parle un peu.
Patrick : On ne connaissait pas le figuier. Maintenant, on le connaît.
Aline : Vous étiez nouveaux. Maintenant, vous êtes du Seuil.
Marc : Avant, je voulais partir. Maintenant, je reste aujourd'hui.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Avant, Léa ne savait pas demander.",
  "correct": true,
  "explanation": "Léa : « je ne savais pas demander »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Joël mange-t-il maintenant ?",
  "options": [
    {
      "text": "Toujours à la moto",
      "correct": false
    },
    {
      "text": "À table",
      "correct": true
    },
    {
      "text": "Au port seulement",
      "correct": false
    },
    {
      "text": "Nulle part",
      "correct": false
    }
  ],
  "explanation": "Maintenant, à table."
}$j$::jsonb,
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
      "right": "demande"
    },
    {
      "left": "Joël",
      "right": "table"
    },
    {
      "left": "Hawa",
      "right": "parle"
    },
    {
      "left": "Marc",
      "right": "reste"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAvant, j'___ peur. (avoir)",
  "answer": "avais"
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
    "parle",
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
  "word": "savais",
  "hint": "Le verbe savoir, à l'imparfait, avec je."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avant je ne sais pas demander.",
  "correct_sentence": "Avant, je ne savais pas demander.",
  "explanation": "Avant : imparfait (savais)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/avant.svg",
      "word": "avant"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/maintenant.svg",
      "word": "maintenant"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/figuier.svg",
      "word": "le figuier"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/table.svg",
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
  "prompt": "Notez deux avant (imparfait) et deux maintenant (présent)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Avant, je ne savais pas. Maintenant, je demande. J'étais à la moto. Maintenant, je mange à table."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Deux colonnes',
    'CE',
    $c$Objectif
Lire un tableau avant / maintenant.

Consigne
Lisez le tableau.

Support — Tableau du cahier
Avant → maintenant
je ne savais pas → je demande
j'étais à la moto → je mange à table
j'avais peur → je parle
on ne connaissait pas → on connaît
vous étiez nouveaux → vous êtes du Seuil
je voulais partir → je reste aujourd'hui
Inventé pour le bilan. Pas une enquête réelle.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Maintenant, ils sont encore tous nouveaux, d'après le tableau.",
  "correct": false,
  "explanation": "Vous êtes du Seuil."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que voulait Marc, avant ?",
  "options": [
    {
      "text": "Rester",
      "correct": false
    },
    {
      "text": "Partir",
      "correct": true
    },
    {
      "text": "Chanter",
      "correct": false
    },
    {
      "text": "Fermer",
      "correct": false
    }
  ],
  "explanation": "Je voulais partir."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "savais pas",
      "right": "je demande"
    },
    {
      "left": "moto",
      "right": "table"
    },
    {
      "left": "peur",
      "right": "je parle"
    },
    {
      "left": "nouveaux",
      "right": "du Seuil"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVous ___ nouveaux. (être, avant)",
  "answer": "étiez"
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
    "connaît",
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
  "word": "peur",
  "hint": "Hawa l'avait, avant. Maintenant, elle parle."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Maintenant j'étais du Seuil.",
  "correct_sentence": "Maintenant je suis du Seuil.",
  "explanation": "Maintenant : présent."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/avant.svg",
      "word": "avant"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/maintenant.svg",
      "word": "maintenant"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/chemin.svg",
      "word": "un chemin"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/groupe.svg",
      "word": "le groupe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez trois lignes du tableau. Ajoutez la vôtre."
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
    'PO — Dire avant / maintenant',
    'PO',
    $c$Objectif
Parler d'un changement personnel.

Consigne
Répétez, puis dites un avant et un maintenant.

Support — Modèles d'Hawa
Avant, j'avais peur.
Maintenant, je parle.
Avant, je ne savais pas.
Maintenant, je sais un peu.
On ne connaissait pas le Seuil.
On le connaît.
Vous étiez nouveaux.
Vous êtes ici.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Vous étiez » est l'imparfait de être.",
  "correct": true,
  "explanation": "Vous étiez / vous êtes."
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
      "text": "J'avais peur",
      "correct": false
    },
    {
      "text": "Je ne savais pas",
      "correct": false
    },
    {
      "text": "Je parle",
      "correct": true
    },
    {
      "text": "Vous étiez nouveaux",
      "correct": false
    }
  ],
  "explanation": "Je parle."
}$j$::jsonb,
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
      "right": "imparfait"
    },
    {
      "left": "maintenant",
      "right": "présent"
    },
    {
      "left": "j'avais",
      "right": "peur"
    },
    {
      "left": "je sais",
      "right": "un peu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ___ le Seuil. (connaître, maintenant)",
  "answer": "connaît"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Avant",
    "j'avais",
    "peur",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "étiez",
  "hint": "Le verbe être, à l'imparfait, avec vous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On connaissait pas le Seuil. (négation)",
  "correct_sentence": "On ne connaissait pas le Seuil.",
  "explanation": "Ne… pas."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/avant.svg",
      "word": "avant"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/maintenant.svg",
      "word": "maintenant"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/portrait.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/content.svg",
      "word": "content"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases : trois avant, trois maintenant."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre changement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma colonne du changement',
    'PE',
    $c$Objectif
Écrire un avant / maintenant.

Consigne
Imitez la page de Joël.

Support — Page de Joël
Joël Mugisha
Avant, j'étais toujours à la moto. Je n'avais pas le midi à table.
Maintenant, je mange avec le groupe. Je suis content.
Avant, je ne savais pas dire « il faut ».
Maintenant, je le dis.
Joël
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël mangeait déjà à table, avant.",
  "correct": false,
  "explanation": "Avant : pas le midi à table."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que sait Joël dire, maintenant ?",
  "options": [
    {
      "text": "Au revoir seulement",
      "correct": false
    },
    {
      "text": "« Il faut »",
      "correct": true
    },
    {
      "text": "Rien",
      "correct": false
    },
    {
      "text": "Un poème long",
      "correct": false
    }
  ],
  "explanation": "« il faut »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avant, moto",
      "right": "j'étais"
    },
    {
      "left": "midi",
      "right": "je n'avais pas"
    },
    {
      "left": "maintenant",
      "right": "je mange"
    },
    {
      "left": "il faut",
      "right": "je le dis"
    }
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
  "answer": "content"
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
    "mange",
    "avec",
    "le",
    "groupe",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "groupe",
  "hint": "Les autres, autour de la table."
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
      "image_path": "/elearning/mfk-a1-m9/avant.svg",
      "word": "avant"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/maintenant.svg",
      "word": "maintenant"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/table.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/ensemble.svg",
      "word": "ensemble"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez cinq lignes : deux avant, deux maintenant, un je suis."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre page de changement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Imparfait et présent',
    'EL',
    $c$Objectif
Retenir avant + imparfait, maintenant + présent.

Consigne
Apprenez la fiche.

Support — Fiche de Patrick
imparfait : j'étais / j'avais / je savais / je voulais / on connaissait / vous étiez
présent : je suis / j'ai / je sais / je veux / on connaît / vous êtes
avant / maintenant
Attention : je savais (pas je sais au passé).
On connaît (présent, t final).
Pas maintenant j'étais.
Négation : ne… pas.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « maintenant j'étais ici ».",
  "correct": false,
  "explanation": "Maintenant je suis ici."
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
      "text": "je savais",
      "correct": true
    },
    {
      "text": "je saisais",
      "correct": false
    },
    {
      "text": "je savoir",
      "correct": false
    },
    {
      "text": "j'ai savais",
      "correct": false
    }
  ],
  "explanation": "Je savais."
}$j$::jsonb,
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
      "right": "je suis"
    },
    {
      "left": "j'avais",
      "right": "j'ai"
    },
    {
      "left": "je savais",
      "right": "je sais"
    },
    {
      "left": "vous étiez",
      "right": "vous êtes"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ___ le figuier. (connaître, avant)",
  "answer": "connaissait"
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
    "êtes",
    "du",
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
  "word": "connaît",
  "hint": "Le verbe pour un lieu déjà vu, au présent, avec on."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Maintenant on connaissait le figuier.",
  "correct_sentence": "Maintenant on connaît le figuier.",
  "explanation": "Maintenant : connaît."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/avant.svg",
      "word": "avant"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/maintenant.svg",
      "word": "maintenant"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/figuier.svg",
      "word": "le figuier"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/chemin.svg",
      "word": "un chemin"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la fiche. Écrivez quatre paires avant / maintenant."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : j'étais, je suis, j'avais, j'ai, je savais, je sais, vous étiez, vous êtes."
}$j$::jsonb,
    9
  );

  -- ===== La suite du chemin =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'La suite du chemin'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'La suite du chemin', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Demain, sous le figuier',
    'CO',
    $c$Objectif
Comprendre un projet : je serai, nous ferons, il faudra, je pourrai.

Consigne
Qui fera quoi demain ? Qu'est-ce qu'il faudra ?

Support — Dernière page ouverte
Aline : Demain, vous serez encore ici. Il faudra une page.
Léa : Je serai à l'heure. J'écrirai mon bilan.
Marc : Nous ferons un tour du Seuil. On pourra relire le cahier.
Joël : Je ne partirai pas. Je resterai à la moto, un peu.
Hawa : J'aurai mon carnet. Il faut un crayon.
Patrick : On pourra se tromper. Ce n'est pas grave.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa sera à l'heure.",
  "correct": true,
  "explanation": "Léa : « Je serai à l'heure. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que feront-ils, d'après Marc ?",
  "options": [
    {
      "text": "Un avion",
      "correct": false
    },
    {
      "text": "Un tour du Seuil",
      "correct": true
    },
    {
      "text": "La neige",
      "correct": false
    },
    {
      "text": "Rien",
      "correct": false
    }
  ],
  "explanation": "« Nous ferons un tour du Seuil. »"
}$j$::jsonb,
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
      "left": "Marc",
      "right": "tour du Seuil"
    },
    {
      "left": "Joël",
      "right": "restera"
    },
    {
      "left": "Hawa",
      "right": "carnet"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ à l'heure. (être)",
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
    "Il",
    "faudra",
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
  "word": "serai",
  "hint": "Le futur de être, avec je."
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
      "image_path": "/elearning/mfk-a1-m9/demain.svg",
      "word": "demain"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/fleche.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/cahier.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/lac.svg",
      "word": "un lac"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez trois futurs et un il faudra."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je serai à l'heure. Nous ferons un tour. On pourra relire. Il faudra une page. J'aurai mon carnet."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Promesses du cahier',
    'CE',
    $c$Objectif
Lire des projets au futur simple.

Consigne
Lisez les promesses.

Support — Promesses
Cahier du chemin — la suite
Léa — je serai précise. J'écrirai demain.
Marc — nous ferons le tour. On pourra relire.
Hawa — j'aurai un crayon. Il faut une ligne.
Joël — je ne partirai pas. Je resterai.
Aline — vous serez prêts. Il faudra oser.
Pas un contrat réel. Page inventée.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël partira demain, d'après sa promesse.",
  "correct": false,
  "explanation": "« je ne partirai pas »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faudra-t-il, d'après Aline ?",
  "options": [
    {
      "text": "Un avion",
      "correct": false
    },
    {
      "text": "Oser",
      "correct": true
    },
    {
      "text": "De la neige",
      "correct": false
    },
    {
      "text": "Fermer",
      "correct": false
    }
  ],
  "explanation": "Il faudra oser."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je serai",
      "right": "précise"
    },
    {
      "left": "nous ferons",
      "right": "le tour"
    },
    {
      "left": "j'aurai",
      "right": "crayon"
    },
    {
      "left": "vous serez",
      "right": "prêts"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ___ relire. (pouvoir)",
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
    "J'aurai",
    "un",
    "crayon",
    "."
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
  "sentence_with_error": "Nous ferons le tour. On poura relire.",
  "correct_sentence": "Nous ferons le tour. On pourra relire.",
  "explanation": "Pourra : deux r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/demain.svg",
      "word": "demain"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/boussole.svg",
      "word": "une boussole"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/valise.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/partir.svg",
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
  "prompt": "Recopiez trois promesses. Ajoutez : je serai… / il faudra…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les promesses, une ligne, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire je serai, il faudra',
    'PO',
    $c$Objectif
Parler de la suite : futur simple et il faut / il faudra.

Consigne
Répétez, puis promettez une chose.

Support — Modèles d'Aline
Je serai à l'heure.
Tu seras prêt.
Nous ferons le tour.
On pourra relire.
J'aurai une page.
Il faudra oser.
Il faut un crayon.
Je ne partirai pas.
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
  "explanation": "Toujours 3e personne."
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
      "text": "je serais-tu",
      "correct": false
    },
    {
      "text": "je suisrai",
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
      "left": "être",
      "right": "je serai"
    },
    {
      "left": "faire",
      "right": "nous ferons"
    },
    {
      "left": "pouvoir",
      "right": "on pourra"
    },
    {
      "left": "avoir",
      "right": "j'aurai"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTu ___ prêt. (être)",
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
    "Il",
    "faut",
    "un",
    "crayon",
    "."
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
  "hint": "On… relire : futur de pouvoir, deux r."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ferrai le tour demain.",
  "correct_sentence": "Je ferai le tour demain.",
  "explanation": "Faire : je ferai (un r)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/demain.svg",
      "word": "demain"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/fleche.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/partir.svg",
      "word": "partir"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/chemin.svg",
      "word": "un chemin"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases : serai, ferons, pourra, aurai, faudra, faut."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre promesse."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma promesse',
    'PE',
    $c$Objectif
Écrire une courte promesse au futur.

Consigne
Imitez la promesse d'Hawa.

Support — Promesse d'Hawa
Hawa Diallo
Demain, je serai au Seuil. J'écrirai une ligne.
Nous ferons le tour ensemble. On pourra rire.
Il faudra un crayon. Il faut oser.
Je ne partirai pas trop vite.
Hawa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa partira trop vite.",
  "correct": false,
  "explanation": "« Je ne partirai pas trop vite. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Avec qui Hawa fera-t-elle le tour ?",
  "options": [
    {
      "text": "Toute seule",
      "correct": false
    },
    {
      "text": "Ensemble",
      "correct": true
    },
    {
      "text": "Avec un avion",
      "correct": false
    },
    {
      "text": "Personne",
      "correct": false
    }
  ],
  "explanation": "« ensemble »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je serai",
      "right": "Seuil"
    },
    {
      "left": "j'écrirai",
      "right": "une ligne"
    },
    {
      "left": "nous ferons",
      "right": "le tour"
    },
    {
      "left": "il faudra",
      "right": "crayon"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl ___ oser.",
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
    "Nous",
    "ferons",
    "le",
    "tour",
    "ensemble",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ensemble",
  "hint": "Tous, pas tout seul."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Demain je serai au Seuil. Je faut un crayon.",
  "correct_sentence": "Demain je serai au Seuil. Il faut un crayon.",
  "explanation": "Il faut, pas je faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/demain.svg",
      "word": "demain"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/page.svg",
      "word": "une page"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/ensemble.svg",
      "word": "ensemble"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/boussole.svg",
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
  "prompt": "Écrivez cinq lignes : serai, écrirai, ferons, faudra, ne partirai pas."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre promesse, une phrase, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Futur : être, avoir, faire, pouvoir',
    'EL',
    $c$Objectif
Retenir je serai, j'aurai, je ferai, on pourra, il faudra.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
être : je serai / tu seras / vous serez
avoir : j'aurai / tu auras
faire : je ferai / nous ferons (un r)
pouvoir : je pourrai / on pourra (deux r)
falloir : il faut / il faudra (seulement il)
Attention : je serai (pas je sera). Je ferai (un r). Je pourrai (deux r).
Pas je faut. Pas on poura. Pas nous allerons (nous irons).
La suite du chemin : page inventée.
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
  "explanation": "Je ferai, un r."
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
      "text": "je poura",
      "correct": false
    },
    {
      "text": "je pourrai",
      "correct": true
    },
    {
      "text": "je pouvrai",
      "correct": false
    },
    {
      "text": "je peusrai",
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
      "left": "je serai",
      "right": "être"
    },
    {
      "left": "j'aurai",
      "right": "avoir"
    },
    {
      "left": "je ferai",
      "right": "faire"
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
  "prompt": "Complétez :\nVous ___ prêts. (être)",
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
    "On",
    "pourra",
    "relire",
    "."
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
  "sentence_with_error": "Vous sera prêts demain.",
  "correct_sentence": "Vous serez prêts demain.",
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
      "image_path": "/elearning/mfk-a1-m9/demain.svg",
      "word": "demain"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/fleche.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/boussole.svg",
      "word": "une boussole"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/chemin.svg",
      "word": "un chemin"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la fiche. Écrivez quatre futurs : serai, aurai, ferai, faudra."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : je serai, tu seras, j'aurai, je ferai, nous ferons, on pourra, il faudra, il faut oser."
}$j$::jsonb,
    9
  );

  -- ===== Une page pour la route =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une page pour la route'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une page pour la route', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Merci, le chemin',
    'CO',
    $c$Objectif
Comprendre un au revoir de bilan : merci, je suis content(e), nous raconterons.

Consigne
Qui dit merci ? Que racontera-t-on ?

Support — Dernier tour sous le figuier
Léa : Merci. Je suis contente. J'ai appris.
Noura : Merci à Aline, à Patrick. Nous raconterons le Seuil.
Joël : Moi, je suis content. Je resterai un peu.
Aline : Merci à vous. Vous avez bien marché.
Marc : À bientôt. On se verra ici.
Hawa : J'écrirai une dernière ligne. Au revoir.
Patrick : Le cahier restera sous le figuier.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa est contente.",
  "correct": true,
  "explanation": "Léa : « Je suis contente. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où restera le cahier ?",
  "options": [
    {
      "text": "Dans le minibus",
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
      "text": "À la mer",
      "correct": false
    }
  ],
  "explanation": "Patrick : « sous le figuier »."
}$j$::jsonb,
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
      "right": "contente"
    },
    {
      "left": "Noura",
      "right": "raconterons"
    },
    {
      "left": "Joël",
      "right": "resterai"
    },
    {
      "left": "Marc",
      "right": "à bientôt"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ le Seuil.",
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
    "Merci",
    "."
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
  "hint": "Le mot pour dire qu'on est reconnaissant."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis content.",
  "correct_sentence": "Je suis contente.",
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
      "image_path": "/elearning/mfk-a1-m9/merci.svg",
      "word": "merci"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/content.svg",
      "word": "content"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/adieu.svg",
      "word": "au revoir"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/figuier.svg",
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
  "prompt": "Notez qui est content(e), un merci, un à bientôt."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Merci. Je suis content / contente. Nous raconterons le Seuil. À bientôt. Au revoir."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Dernière page',
    'CE',
    $c$Objectif
Lire la dernière page du Cahier du chemin.

Consigne
Lisez la page.

Support — Dernière page
Cahier du chemin — Seuil des Sources
Merci à la cour.
Léa — je suis contente. J'ai appris.
Joël — je suis content. Je resterai.
Nous raconterons. On se verra.
À bientôt. Au revoir.
Le cahier restera sous le figuier.
Page inventée. Pas un diplôme.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le cahier partira avec Noura.",
  "correct": false,
  "explanation": "Il restera sous le figuier."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle formule de fin trouve-t-on ?",
  "options": [
    {
      "text": "Bonne année seulement",
      "correct": false
    },
    {
      "text": "À bientôt. Au revoir.",
      "correct": true
    },
    {
      "text": "Silence",
      "correct": false
    },
    {
      "text": "Fermé lundi",
      "correct": false
    }
  ],
  "explanation": "À bientôt. Au revoir."
}$j$::jsonb,
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
      "right": "contente"
    },
    {
      "left": "Joël",
      "right": "content"
    },
    {
      "left": "nous",
      "right": "raconterons"
    },
    {
      "left": "cahier",
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
  "prompt": "Complétez :\nÀ ___.",
  "answer": "bientôt"
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
    "revoir",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "bientôt",
  "hint": "À… : on se verra dans peu de temps."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous raconterons. On se vera.",
  "correct_sentence": "Nous raconterons. On se verra.",
  "explanation": "Verra (deux r), futur de voir."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/page.svg",
      "word": "une page"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/bilan.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/merci.svg",
      "word": "merci"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/cahier.svg",
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
  "prompt": "Recopiez la page. Ajoutez votre merci et un je suis content(e)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la dernière page, une ligne, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire merci, à bientôt',
    'PO',
    $c$Objectif
Clore le chemin : merci, je suis content(e), à bientôt.

Consigne
Répétez, puis dites votre fin de cahier.

Support — Modèles de Patrick
Merci.
Je suis content.
Je suis contente.
Nous raconterons.
On se verra.
À bientôt.
Au revoir.
Le cahier restera ici.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« On se verra » est au futur.",
  "correct": true,
  "explanation": "Voir : on se verra."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est correcte, pour Léa ?",
  "options": [
    {
      "text": "je suis content",
      "correct": false
    },
    {
      "text": "je suis contente",
      "correct": true
    },
    {
      "text": "je suis contents",
      "correct": false
    },
    {
      "text": "j'ai content",
      "correct": false
    }
  ],
  "explanation": "Contente."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "merci",
      "right": "reconnaissance"
    },
    {
      "left": "content",
      "right": "masculin"
    },
    {
      "left": "contente",
      "right": "féminin"
    },
    {
      "left": "à bientôt",
      "right": "on se verra"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn se ___.",
  "answer": "verra"
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
    "cahier",
    "restera",
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
  "word": "revoir",
  "hint": "Au… : pour partir, poliment."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "À bientôt. On se vera sous le figuier.",
  "correct_sentence": "À bientôt. On se verra sous le figuier.",
  "explanation": "Verra, deux r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/merci.svg",
      "word": "merci"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/adieu.svg",
      "word": "au revoir"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/ensemble.svg",
      "word": "ensemble"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/content.svg",
      "word": "content"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases de clôture."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre merci."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma dernière ligne',
    'PE',
    $c$Objectif
Écrire la dernière ligne du cahier.

Consigne
Imitez la page de Noura.

Support — Page de Noura
Noura Sarr
Merci au Seuil. Je suis contente.
J'ai appris. Nous raconterons le chemin.
À bientôt, sous le figuier.
Au revoir.
Noura
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Noura est fâchée.",
  "correct": false,
  "explanation": "« Je suis contente. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que raconteront-ils ?",
  "options": [
    {
      "text": "Un avion",
      "correct": false
    },
    {
      "text": "Le chemin",
      "correct": true
    },
    {
      "text": "Rien",
      "correct": false
    },
    {
      "text": "Un examen secret",
      "correct": false
    }
  ],
  "explanation": "Le chemin."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "merci",
      "right": "Seuil"
    },
    {
      "left": "contente",
      "right": "Noura"
    },
    {
      "left": "j'ai appris",
      "right": "bilan"
    },
    {
      "left": "à bientôt",
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
  "prompt": "Complétez :\nJe suis ___. (Noura)",
  "answer": "contente"
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
  "word": "ligne",
  "hint": "Une seule, la dernière, dans le cahier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Merci au Seuil. Je suis content.",
  "correct_sentence": "Merci au Seuil. Je suis contente.",
  "explanation": "Noura = elle : contente."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m9/page.svg",
      "word": "une page"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/merci.svg",
      "word": "merci"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/figuier.svg",
      "word": "le figuier"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/adieu.svg",
      "word": "au revoir"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez cinq lignes : merci, contente/content, j'ai appris, raconterons, à bientôt."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre dernière ligne, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Merci, content(e), on se verra',
    'EL',
    $c$Objectif
Retenir les formules de fin et l'accord de content(e).

Consigne
Apprenez la fiche, puis fermez le cahier.

Support — Fiche d'Aline
merci
je suis content / je suis contente
nous raconterons
on se verra (futur de voir, deux r)
à bientôt / au revoir
le cahier restera
Attention : contente au féminin.
On se verra (pas vera).
Nous raconterons (pas nous raconteront).
Cahier du chemin : inventé, sous le figuier.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « on se vera » (un r).",
  "correct": false,
  "explanation": "On se verra, deux r."
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
      "text": "nous raconterons",
      "correct": true
    },
    {
      "text": "nous raconteront",
      "correct": false
    },
    {
      "text": "nous raconteons",
      "correct": false
    },
    {
      "text": "nous raconter",
      "correct": false
    }
  ],
  "explanation": "Nous raconterons."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "merci",
      "right": "reconnaissance"
    },
    {
      "left": "content",
      "right": "il"
    },
    {
      "left": "contente",
      "right": "elle"
    },
    {
      "left": "à bientôt",
      "right": "futur proche du cœur"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ le Seuil.",
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
  "word": "restera",
  "hint": "Le futur de rester, pour le cahier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous raconterons le Seuil. Vous sera sous le figuier.",
  "correct_sentence": "Nous raconterons le Seuil. Vous serez sous le figuier.",
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
      "image_path": "/elearning/mfk-a1-m9/bilan.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/cahier.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/content.svg",
      "word": "content"
    },
    {
      "image_path": "/elearning/mfk-a1-m9/chemin.svg",
      "word": "un chemin"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : merci, contente/content, raconterons, à bientôt."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : merci, je suis content, je suis contente, nous raconterons, on se verra, à bientôt, au revoir."
}$j$::jsonb,
    9
  );

END;
$$;
