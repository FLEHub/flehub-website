/*
  # Seed eLearning MFK — Module 1 A1 « Premiers repères » (v3)

  Annule le seed v1. Un module par grande étape.
  Module 1 : 4 séquences × 5 leçons × 10 exercices (tous les types).
  Personnages et documents originaux (kiosque « La Colline », Kimisagara).
  Aucune table nouvelle. Idempotent.
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
  v_module_title text := 'A1 — Premiers repères';
BEGIN
  DELETE FROM elearning_sequences
  WHERE title = 'Séquence 1 — Premiers repères';

  DELETE FROM elearning_modules m
  WHERE m.title = 'A1 — Parcours MFK'
    AND NOT EXISTS (
      SELECT 1 FROM elearning_sequences s WHERE s.module_id = m.id
    );

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
      'Seed A1 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed Module 1 : enseignant % (%)', v_teacher_email, v_teacher_id;

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
      'Grande étape 1 : saluer et se présenter, se compter, situer le monde en français, vivre l''atelier du kiosque La Colline (Kimisagara).',
      'A1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape 1 : saluer et se présenter, se compter, situer le monde en français, vivre l''atelier du kiosque La Colline (Kimisagara).',
      cefr_level = 'A1',
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Bienvenue en français =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Bienvenue en français'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Bienvenue en français', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Un « bonjour » sous le auvent',
    'CO',
    $c$Objectif
Comprendre un premier contact au kiosque : bonjour / salut, vous / tu, je m'appelle, c'est, au revoir.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui vouvoie ? Qui tutoie ? Comment s'appelle chacun ?

Support — Sous l'auvent de « La Colline » (Kimisagara)
Didier (au comptoir) : Bonjour, monsieur.
Yvan : Bonjour. C'est le kiosque « La Colline » ?
Didier : Oui. Je m'appelle Didier. Et vous ?
Yvan : Je m'appelle Yvan Bizimana. Enchanté.
Inès (arrive avec un carton de livres) : Bonjour, monsieur Bizimana. Je m'appelle Inès Kalisa. C'est notre rendez-vous de français.
Sonia (sur le muret) : Salut Yvan ! Moi c'est Sonia. À plus tard ?
Yvan : Salut Sonia. Merci. Au revoir, monsieur Didier.
Didier : Au revoir. À bientôt.$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Yvan arrive au kiosque « La Colline ».",
  "correct": true,
  "explanation": "Yvan demande : « C'est le kiosque La Colline ? » Didier répond oui."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment Sonia salue-t-elle Yvan ?",
  "options": [
    {
      "text": "Bonjour, monsieur.",
      "correct": false
    },
    {
      "text": "Salut Yvan !",
      "correct": true
    },
    {
      "text": "Au revoir.",
      "correct": false
    },
    {
      "text": "S'il vous plaît.",
      "correct": false
    }
  ],
  "explanation": "Sonia dit « Salut Yvan ! » : c'est le tutoiement. Didier dit « Bonjour, monsieur » : vouvoiement."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Bonjour, monsieur.",
      "right": "vous"
    },
    {
      "left": "Salut Yvan !",
      "right": "tu"
    },
    {
      "left": "Enchanté.",
      "right": "faire connaissance"
    },
    {
      "left": "Au revoir.",
      "right": "partir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez (forme de s'appeler) :\nJe ___ Yvan Bizimana.",
  "answer": "m'appelle"
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
    "Inès",
    "Kalisa"
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
  "hint": "On dit ce mot sous l'auvent, pour saluer avec vous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je s'appelle Yvan.",
  "correct_sentence": "Je m'appelle Yvan.",
  "explanation": "Je → je m'appelle. Il / elle → il / elle s'appelle."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/bonjour.svg",
      "word": "bonjour"
    },
    {
      "image_path": "/elearning/mfk-a1/salut.svg",
      "word": "salut"
    },
    {
      "image_path": "/elearning/mfk-a1/aurevoir.svg",
      "word": "au revoir"
    },
    {
      "image_path": "/elearning/mfk-a1/merci.svg",
      "word": "merci"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez les quatre prénoms entendus. Qui dit « vous » ? Qui dit « tu » ?"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez le début : Bonjour. C'est le kiosque La Colline ? Je m'appelle … Enchanté."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le papier scotché au volet',
    'CE',
    $c$Objectif
Lire un avis de quartier : salutations, je m'appelle, c'est, vouvoiement.

Consigne
Lisez l'avis scotché au volet du kiosque, puis le mot glissé sous le sachet de café.

Support — Avis au volet (stylo bleu, papier ligné)
Mardi-français — kiosque La Colline
Kimisagara, près du terrain
Bonjour,
Je m'appelle Inès Kalisa. C'est un rendez-vous gratuit.
Vous êtes nouveau ? Bienvenue.
À bientôt,
Inès

Mot sous le sachet (Didier)
Bonjour monsieur Bizimana,
C'est Didier. Le carton d'Inès est derrière le comptoir.
Merci. Au revoir.$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'avis est écrit par Sonia.",
  "correct": false,
  "explanation": "L'avis est signé Inès. Sonia n'écrit pas ici."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où se trouve le kiosque ?",
  "options": [
    {
      "text": "À l'aéroport",
      "correct": false
    },
    {
      "text": "Kimisagara, près du terrain",
      "correct": true
    },
    {
      "text": "À l'hôtel",
      "correct": false
    },
    {
      "text": "En salle 2",
      "correct": false
    }
  ],
  "explanation": "L'avis : « Kimisagara, près du terrain »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Bonjour,",
      "right": "saluer à l'écrit"
    },
    {
      "left": "Je m'appelle Inès Kalisa.",
      "right": "se présenter"
    },
    {
      "left": "C'est un rendez-vous gratuit.",
      "right": "c'est + info"
    },
    {
      "left": "Au revoir.",
      "right": "terminer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez (deux mots) :\n___ un rendez-vous gratuit.",
  "answer": "C'est"
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
    "Inès",
    "Kalisa"
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
  "hint": "Didier l'écrit à la fin du mot sous le sachet."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est je Inès.",
  "correct_sentence": "Je m'appelle Inès.",
  "explanation": "Pour le nom : je m'appelle. C'est + un lieu ou une chose : c'est le kiosque."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/bonjour.svg",
      "word": "bonjour"
    },
    {
      "image_path": "/elearning/mfk-a1/salut.svg",
      "word": "salut"
    },
    {
      "image_path": "/elearning/mfk-a1/aurevoir.svg",
      "word": "au revoir"
    },
    {
      "image_path": "/elearning/mfk-a1/merci.svg",
      "word": "merci"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez une phrase de l'avis avec « je m'appelle » et une phrase avec « c'est »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez à voix haute l'avis d'Inès, du « Bonjour » jusqu'à « À bientôt »."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Saluer au kiosque',
    'PO',
    $c$Objectif
Saluer (tu / vous), dire je m'appelle, c'est, prendre congé — à l'oral.

Consigne
Les dix exercices. Puis enregistrez-vous comme sous l'auvent.

Modèles
Vous (Didier, première fois) : Bonjour, monsieur. Je m'appelle Yvan. Enchanté.
Tu (Sonia) : Salut ! Moi c'est Sonia. Et toi ?
C'est : C'est le kiosque. C'est Inès.$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « Salut, monsieur Didier » pour être poli avec un inconnu.",
  "correct": false,
  "explanation": "Avec un inconnu au comptoir : Bonjour, monsieur. Salut = tu."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est au vouvoiement ?",
  "options": [
    {
      "text": "Salut !",
      "correct": false
    },
    {
      "text": "Et toi ?",
      "correct": false
    },
    {
      "text": "Bonjour, monsieur.",
      "correct": true
    },
    {
      "text": "À plus tard ?",
      "correct": false
    }
  ],
  "explanation": "« Bonjour, monsieur » = vous. « Salut » / « toi » = tu."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Bonjour, madame.",
      "right": "vous"
    },
    {
      "left": "Salut !",
      "right": "tu"
    },
    {
      "left": "Comment vous appelez-vous ?",
      "right": "vous"
    },
    {
      "left": "Et toi ?",
      "right": "tu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nMoi ___ Sonia.",
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
    "Bonjour",
    "je",
    "m'appelle",
    "Yvan"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "salut",
  "hint": "Sonia le dit à Yvan, sur le muret."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Salut, monsieur Didier, et toi ?",
  "correct_sentence": "Bonjour, monsieur Didier.",
  "explanation": "On ne mélange pas salut/toi et monsieur."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/bonjour.svg",
      "word": "bonjour"
    },
    {
      "image_path": "/elearning/mfk-a1/salut.svg",
      "word": "salut"
    },
    {
      "image_path": "/elearning/mfk-a1/aurevoir.svg",
      "word": "au revoir"
    },
    {
      "image_path": "/elearning/mfk-a1/merci.svg",
      "word": "merci"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez deux mini-répliques : une avec vous (Didier), une avec tu (Sonia)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez 20 secondes.\n1) Bonjour, monsieur. Je m'appelle … Enchanté.\n2) Salut ! Moi c'est … Et toi ?\n3) Au revoir. À bientôt."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Trois lignes dans le cahier d''Inès',
    'PE',
    $c$Objectif
Écrire une mini-présentation : saluer, je m'appelle, c'est, prendre congé.

Consigne
Inès tend son cahier d'émargement. Écrivez comme Yvan.

Modèle (page du cahier)
Bonjour,
Je m'appelle Yvan Bizimana.
C'est mon premier mardi à La Colline.
À bientôt.$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le modèle utilise « je m'appelle » pour le nom.",
  "correct": true,
  "explanation": "Yvan écrit : Je m'appelle Yvan Bizimana."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase termine le modèle ?",
  "options": [
    {
      "text": "Salut toi",
      "correct": false
    },
    {
      "text": "À bientôt.",
      "correct": true
    },
    {
      "text": "Écoutez.",
      "correct": false
    },
    {
      "text": "J'ai vingt ans.",
      "correct": false
    }
  ],
  "explanation": "Le modèle se termine par « À bientôt. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Bonjour,",
      "right": "ouvrir"
    },
    {
      "left": "Je m'appelle Yvan.",
      "right": "le nom"
    },
    {
      "left": "C'est mon premier mardi.",
      "right": "c'est + info"
    },
    {
      "left": "À bientôt.",
      "right": "fermer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez (un mot) :\nJe m'___ Yvan Bizimana.",
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
    "C'est",
    "mon",
    "premier",
    "mardi"
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
  "hint": "On l'écrit souvent après le nom, avec Enchanté."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je m'appelle c'est Yvan.",
  "correct_sentence": "Je m'appelle Yvan.",
  "explanation": "On ne met pas c'est et je m'appelle ensemble pour le nom."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/bonjour.svg",
      "word": "bonjour"
    },
    {
      "image_path": "/elearning/mfk-a1/salut.svg",
      "word": "salut"
    },
    {
      "image_path": "/elearning/mfk-a1/aurevoir.svg",
      "word": "au revoir"
    },
    {
      "image_path": "/elearning/mfk-a1/merci.svg",
      "word": "merci"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez 3 phrases dans le cahier : Bonjour / Je m'appelle … / À bientôt."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez à voix haute votre texte du cahier."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — s''appeler, tu / vous, c''est',
    'EL',
    $c$Objectif
Fixer le point de langue : formules de politesse, tu / vous, s'appeler, c'est.

Consigne
Fiche du kiosque, puis les dix exercices.

Fiche — derrière le comptoir

1. Saluer / partir
vous : Bonjour, monsieur / madame. Au revoir. À bientôt.
tu : Salut. À plus.
Enchanté / Enchantée. Merci.

2. s'appeler
je m'appelle • tu t'appelles • il / elle s'appelle
nous nous appelons • vous vous appelez • ils / elles s'appellent

3. c'est + nom
C'est Yvan. C'est le kiosque. C'est Inès.

4. tu / vous
Voisine du même âge → tu. Comptoir, première fois → vous.$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Avec je, on dit je s'appelle.",
  "correct": false,
  "explanation": "Avec je : je m'appelle. Avec il / elle : il / elle s'appelle."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Complétez : Je ___ Yvan.",
  "options": [
    {
      "text": "m'appelle",
      "correct": true
    },
    {
      "text": "s'appelle",
      "correct": false
    },
    {
      "text": "t'appelles",
      "correct": false
    },
    {
      "text": "appelez",
      "correct": false
    }
  ],
  "explanation": "Je m'appelle."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je",
      "right": "m'appelle"
    },
    {
      "left": "tu",
      "right": "t'appelles"
    },
    {
      "left": "elle",
      "right": "s'appelle"
    },
    {
      "left": "vous",
      "right": "vous appelez"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez (deux mots) :\n___ le kiosque La Colline.",
  "answer": "C'est"
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
    "vous",
    "appelez",
    "comment"
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
  "hint": "Formule vous, sous l'auvent."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je s'appelle Sonia.",
  "correct_sentence": "Je m'appelle Sonia.",
  "explanation": "Je → m'appelle."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/bonjour.svg",
      "word": "bonjour"
    },
    {
      "image_path": "/elearning/mfk-a1/salut.svg",
      "word": "salut"
    },
    {
      "image_path": "/elearning/mfk-a1/aurevoir.svg",
      "word": "au revoir"
    },
    {
      "image_path": "/elearning/mfk-a1/merci.svg",
      "word": "merci"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez le tableau je / tu / elle / vous de s'appeler."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites à voix haute : je m'appelle, tu t'appelles, elle s'appelle, vous vous appelez."
}$j$::jsonb,
    9
  );

  -- ===== Se compter et s'organiser =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Se compter et s''organiser'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Se compter et s''organiser', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Combien sous l''auvent ?',
    'CO',
    $c$Objectif
Comprendre les nombres 0–20, j'ai … ans, c'est + jour.

Consigne
Lisez. Quel jour ? Quels âges ? Combien de personnes ?

Support — Mardi 16 h, table pliante
Inès : On est quel jour, Yvan ?
Yvan : C'est mardi.
Inès : Oui. Le petit atelier écrit : c'est lundi prochain, ici.
Sonia : Tu as quel âge ?
Yvan : J'ai dix-huit ans. Et toi ?
Sonia : J'ai dix-neuf ans.
Noël (arrive) : J'ai huit ans !
Didier : Nous sommes quatre à la table. Un, deux, trois, quatre. Le carton : dix livres. Yvan, tu as quel numéro sur l'étiquette ? Vingt.
Yvan : Vingt. Merci.$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aujourd'hui, c'est lundi.",
  "correct": false,
  "explanation": "Yvan dit : « C'est mardi. » Lundi = le prochain atelier écrit."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel âge a Yvan ?",
  "options": [
    {
      "text": "Huit ans",
      "correct": false
    },
    {
      "text": "Dix ans",
      "correct": false
    },
    {
      "text": "Dix-huit ans",
      "correct": true
    },
    {
      "text": "Vingt ans",
      "correct": false
    }
  ],
  "explanation": "Yvan : « J'ai dix-huit ans. » Vingt = le numéro d'étiquette."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Yvan",
      "right": "dix-huit ans"
    },
    {
      "left": "Sonia",
      "right": "dix-neuf ans"
    },
    {
      "left": "Noël",
      "right": "huit ans"
    },
    {
      "left": "étiquette",
      "right": "vingt"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez le jour d'aujourd'hui :\nC'est ___.",
  "answer": "mardi"
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
    "dix-huit",
    "ans"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lundi",
  "hint": "Jour du prochain atelier écrit, dit Inès."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis dix-huit ans.",
  "correct_sentence": "J'ai dix-huit ans.",
  "explanation": "L'âge : avoir, pas être."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/un.svg",
      "word": "un"
    },
    {
      "image_path": "/elearning/mfk-a1/dix.svg",
      "word": "dix"
    },
    {
      "image_path": "/elearning/mfk-a1/vingt.svg",
      "word": "vingt"
    },
    {
      "image_path": "/elearning/mfk-a1/lundi.svg",
      "word": "lundi"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez : le jour d'aujourd'hui, le jour du prochain atelier, l'âge de Noël."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : C'est mardi. J'ai … ans. Nous sommes quatre."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le cahier d''émargement d''Inès',
    'CE',
    $c$Objectif
Lire une liste : jours, nombres 0–20, âges.

Consigne
Lisez la page du cahier collée près de la caisse.

Support — Cahier d'émargement (page 3)
La Colline — Kimisagara
Aujourd'hui : c'est mardi
Prochain écrit : c'est lundi
À la table : 4
Livres dans le carton : 10

Noms — âge
Yvan Bizimana — 18 ans
Sonia Mukeshimana — 19 ans
Noël Iradukunda — 8 ans
Étiquette Yvan : 20

Note d'Inès
C'est mardi. Quatre personnes. Dix livres. Lundi : atelier crayon.$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Il y a vingt personnes à la table.",
  "correct": false,
  "explanation": "À la table : 4. 20 = l'étiquette de Yvan."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel jour est le prochain atelier écrit ?",
  "options": [
    {
      "text": "Mardi",
      "correct": false
    },
    {
      "text": "Lundi",
      "correct": true
    },
    {
      "text": "Dimanche",
      "correct": false
    },
    {
      "text": "Vendredi",
      "correct": false
    }
  ],
  "explanation": "Cahier : « Prochain écrit : c'est lundi »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "8",
      "right": "huit"
    },
    {
      "left": "10",
      "right": "dix"
    },
    {
      "left": "18",
      "right": "dix-huit"
    },
    {
      "left": "20",
      "right": "vingt"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nProchain écrit : c'est ___.",
  "answer": "lundi"
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
    "mardi"
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
  "hint": "Numéro sur l'étiquette de Yvan."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Noël a vingt ans.",
  "correct_sentence": "Noël a huit ans.",
  "explanation": "Cahier : Noël Iradukunda — 8 ans."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/un.svg",
      "word": "un"
    },
    {
      "image_path": "/elearning/mfk-a1/dix.svg",
      "word": "dix"
    },
    {
      "image_path": "/elearning/mfk-a1/vingt.svg",
      "word": "vingt"
    },
    {
      "image_path": "/elearning/mfk-a1/lundi.svg",
      "word": "lundi"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez une ligne avec un âge et la phrase « c'est lundi »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la note d'Inès à voix haute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire le jour et l''âge',
    'PO',
    $c$Objectif
Dire les nombres 0–20, j'ai … ans, c'est + jour.

Consigne
Modèles sous l'auvent, puis oral.

Modèles
J'ai dix-huit ans. Tu as quel âge ?
C'est mardi. C'est lundi prochain.
Nous sommes quatre.
un deux trois … dix … vingt

Jours : lundi mardi mercredi jeudi vendredi samedi dimanche$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je suis lundi » pour le jour.",
  "correct": false,
  "explanation": "On dit : c'est lundi. L'âge : j'ai … ans."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle question pour l'âge ?",
  "options": [
    {
      "text": "On est quel jour ?",
      "correct": false
    },
    {
      "text": "Tu as quel âge ?",
      "correct": true
    },
    {
      "text": "C'est qui ?",
      "correct": false
    },
    {
      "text": "D'où viens-tu ?",
      "correct": false
    }
  ],
  "explanation": "Tu as quel âge ?"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Tu as quel âge ?",
      "right": "J'ai dix-huit ans."
    },
    {
      "left": "On est quel jour ?",
      "right": "C'est mardi."
    },
    {
      "left": "Vous êtes combien ?",
      "right": "Nous sommes quatre."
    },
    {
      "left": "C'est quel numéro ?",
      "right": "Vingt."
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez le verbe :\nJ'___ dix-neuf ans.",
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
    "C'est",
    "lundi",
    "prochain"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "mardi",
  "hint": "Jour d'aujourd'hui au kiosque."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est j'ai mardi.",
  "correct_sentence": "C'est mardi.",
  "explanation": "Jour : c'est + jour. Âge : j'ai + nombre + ans."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/un.svg",
      "word": "un"
    },
    {
      "image_path": "/elearning/mfk-a1/dix.svg",
      "word": "dix"
    },
    {
      "image_path": "/elearning/mfk-a1/vingt.svg",
      "word": "vingt"
    },
    {
      "image_path": "/elearning/mfk-a1/lundi.svg",
      "word": "lundi"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez : votre âge (j'ai … ans) et un jour (c'est …)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Bonjour, je m'appelle … J'ai … ans. Aujourd'hui c'est … Le prochain atelier : c'est lundi."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — L''étiquette collée au gobelet',
    'PE',
    $c$Objectif
Écrire nombres, âge et jour sur une petite étiquette.

Consigne
Inès donne des gobelets. Complétez comme Sonia.

Modèle
Sonia Mukeshimana
J'ai dix-neuf ans.
C'est mardi.
Prochain écrit : c'est lundi.
N° 10 (gobelet).$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Sonia écrit son âge avec « j'ai ».",
  "correct": true,
  "explanation": "J'ai dix-neuf ans."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment écrit-on 19 en lettres dans le modèle ?",
  "options": [
    {
      "text": "neuf",
      "correct": false
    },
    {
      "text": "dix-neuf",
      "correct": true
    },
    {
      "text": "vingt",
      "correct": false
    },
    {
      "text": "huit",
      "correct": false
    }
  ],
  "explanation": "dix-neuf."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lundi",
      "right": "un jour"
    },
    {
      "left": "dix-neuf",
      "right": "un âge"
    },
    {
      "left": "dix",
      "right": "un numéro de gobelet"
    },
    {
      "left": "mardi",
      "right": "aujourd'hui au kiosque"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est ___. (aujourd'hui, d'après le modèle)",
  "answer": "mardi"
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
    "dix-neuf",
    "ans"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "huit",
  "hint": "Âge de Noël, en lettres."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai lundi ans.",
  "correct_sentence": "C'est lundi.",
  "explanation": "Lundi n'est pas un âge."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/un.svg",
      "word": "un"
    },
    {
      "image_path": "/elearning/mfk-a1/dix.svg",
      "word": "dix"
    },
    {
      "image_path": "/elearning/mfk-a1/vingt.svg",
      "word": "vingt"
    },
    {
      "image_path": "/elearning/mfk-a1/lundi.svg",
      "word": "lundi"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez votre étiquette : prénom, j'ai … ans, c'est … (un jour)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre étiquette à voix haute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Nombres 0–20, j''ai … ans, c''est lundi',
    'EL',
    $c$Objectif
Fixer : nombres 0–20, avoir + âge, jours, c'est + jour.

Consigne
Fiche collée dans le carton à livres.

Fiche
0 zéro  1 un  2 deux  3 trois  4 quatre  5 cinq
6 six  7 sept  8 huit  9 neuf  10 dix
11 onze  12 douze  13 treize  14 quatorze  15 quinze
16 seize  17 dix-sept  18 dix-huit  19 dix-neuf  20 vingt

J'ai vingt ans. Tu as quel âge ?
C'est lundi. C'est mardi. On est quel jour ?
lundi mardi mercredi jeudi vendredi samedi dimanche
Nous sommes quatre.$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "18 s'écrit « huit ».",
  "correct": false,
  "explanation": "8 = huit. 18 = dix-huit."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment écrit-on 20 en lettres ?",
  "options": [
    {
      "text": "douze",
      "correct": false
    },
    {
      "text": "dix",
      "correct": false
    },
    {
      "text": "vingt",
      "correct": true
    },
    {
      "text": "dix-neuf",
      "correct": false
    }
  ],
  "explanation": "20 = vingt."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "8",
      "right": "huit"
    },
    {
      "left": "10",
      "right": "dix"
    },
    {
      "left": "18",
      "right": "dix-huit"
    },
    {
      "left": "19",
      "right": "dix-neuf"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est ___. (premier jour de la semaine scolaire)",
  "answer": "lundi"
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
    "vingt",
    "ans"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lundi",
  "hint": "c'est + jour, premier jour scolaire."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis vingt ans.",
  "correct_sentence": "J'ai vingt ans.",
  "explanation": "Âge = avoir."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/un.svg",
      "word": "un"
    },
    {
      "image_path": "/elearning/mfk-a1/dix.svg",
      "word": "dix"
    },
    {
      "image_path": "/elearning/mfk-a1/vingt.svg",
      "word": "vingt"
    },
    {
      "image_path": "/elearning/mfk-a1/lundi.svg",
      "word": "lundi"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez en lettres : 8, 10, 18, 20, et la phrase « c'est lundi »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Comptez de un à vingt, puis dites : c'est lundi. J'ai … ans."
}$j$::jsonb,
    9
  );

  -- ===== Le monde en français =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Le monde en français'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Le monde en français', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — D''où venez-vous, autour de la table ?',
    'CO',
    $c$Objectif
Comprendre pays, nationalité (être), d'où, je parle, de / du / en.

Consigne
Lisez. D'où vient chacun ? Quelle langue ?

Support — Après le thé sucré
Sonia : Yvan, d'où viens-tu ?
Yvan : Je viens du Rwanda. Je suis rwandais. Je parle kinyarwanda et un peu français.
Sonia : Je viens du Burundi. Je suis burundaise. Je parle kirundi.
Didier : Je viens de la RDC, de Goma. Je suis congolais. Je parle swahili et français.
Inès : Moi, je vis au Rwanda, à Kigali. Je suis rwandaise.
Noël : J'ai une tante en France. Elle est française. Elle parle français.
Yvan : En classe, on parle français, ici sous l'auvent aussi.$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Yvan est français.",
  "correct": false,
  "explanation": "Yvan vient du Rwanda. Il est rwandais. La tante de Noël est française."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "D'où vient Didier ?",
  "options": [
    {
      "text": "Du Rwanda",
      "correct": false
    },
    {
      "text": "Du Burundi",
      "correct": false
    },
    {
      "text": "De la RDC",
      "correct": true
    },
    {
      "text": "De France",
      "correct": false
    }
  ],
  "explanation": "Didier : « Je viens de la RDC, de Goma. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Rwanda",
      "right": "rwandais / rwandaise"
    },
    {
      "left": "Burundi",
      "right": "burundais / burundaise"
    },
    {
      "left": "France",
      "right": "français / française"
    },
    {
      "left": "RDC",
      "right": "congolais / congolaise"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez (un mot) :\nJe viens ___ Rwanda.",
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
    "viens",
    "du",
    "Burundi"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "rwanda",
  "hint": "Pays de Yvan et d'Inès."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis rwandaise. Je viens de Rwanda.",
  "correct_sentence": "Je suis rwandaise. Je viens du Rwanda.",
  "explanation": "du Rwanda = de + le. de France, du Burundi, de la RDC."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/rwanda.svg",
      "word": "Rwanda"
    },
    {
      "image_path": "/elearning/mfk-a1/burundi.svg",
      "word": "Burundi"
    },
    {
      "image_path": "/elearning/mfk-a1/france.svg",
      "word": "France"
    },
    {
      "image_path": "/elearning/mfk-a1/rdc.svg",
      "word": "RDC"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Pour chaque personne, notez : pays + nationalité + une langue."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : Je viens de / du / de la … Je suis … Je parle …"
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Les cartes pégées au carton',
    'CE',
    $c$Objectif
Lire des cartes : pays, nationalité, langue.

Consigne
Quatre cartes scotchées sur le carton à livres.

Support
Carte Yvan — Kigali
Pays : Rwanda
Nationalité : rwandais
Langues : kinyarwanda, français
Je viens du Rwanda.

Carte Sonia
Pays : Burundi
Nationalité : burundaise
Langues : kirundi, français
Je viens du Burundi.

Carte Didier
Pays : RDC (Goma)
Nationalité : congolais
Langues : swahili, français
Je viens de la RDC.

Billet de Noël
Ma tante vit en France. Elle est française. Elle parle français.$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Sonia est burundaise.",
  "correct": true,
  "explanation": "Carte Sonia : nationalité burundaise."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui vit en France d'après les papiers ?",
  "options": [
    {
      "text": "Yvan",
      "correct": false
    },
    {
      "text": "Didier",
      "correct": false
    },
    {
      "text": "La tante de Noël",
      "correct": true
    },
    {
      "text": "Inès",
      "correct": false
    }
  ],
  "explanation": "Billet : « Ma tante vit en France. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Je viens du Rwanda.",
      "right": "Yvan"
    },
    {
      "left": "Je viens du Burundi.",
      "right": "Sonia"
    },
    {
      "left": "Je viens de la RDC.",
      "right": "Didier"
    },
    {
      "left": "Elle vit en France.",
      "right": "la tante"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez (féminin) :\nSonia est ___.",
  "answer": "burundaise"
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
    "parle",
    "français"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "france",
  "hint": "Pays de la tante de Noël."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Didier est congolaise.",
  "correct_sentence": "Didier est congolais.",
  "explanation": "Didier = masculin : congolais. Féminin : congolaise."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/rwanda.svg",
      "word": "Rwanda"
    },
    {
      "image_path": "/elearning/mfk-a1/burundi.svg",
      "word": "Burundi"
    },
    {
      "image_path": "/elearning/mfk-a1/france.svg",
      "word": "France"
    },
    {
      "image_path": "/elearning/mfk-a1/rdc.svg",
      "word": "RDC"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez une phrase avec du, une avec de la, une avec en."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la carte de Sonia à voix haute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire d''où on vient',
    'PO',
    $c$Objectif
Dire pays, nationalité (accord), langues, de / du / en.

Consigne
Modèles autour de la table, puis oral.

Modèles
Je viens du Rwanda. Je suis rwandais.
Je viens de France. Je suis française.
Je vis au Rwanda. Je vis en France.
Je parle français et kinyarwanda.
D'où viens-tu ?$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je vis du France ».",
  "correct": false,
  "explanation": "Vivre : en France, au Rwanda. Venir : de France, du Rwanda."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase a une nationalité au féminin ?",
  "options": [
    {
      "text": "Je suis rwandais.",
      "correct": false
    },
    {
      "text": "Je suis congolais.",
      "correct": false
    },
    {
      "text": "Je suis burundaise.",
      "correct": true
    },
    {
      "text": "Je suis français.",
      "correct": false
    }
  ],
  "explanation": "burundaise = féminin."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Je viens du Rwanda.",
      "right": "le pays"
    },
    {
      "left": "Je suis rwandaise.",
      "right": "la nationalité"
    },
    {
      "left": "Je parle kirundi.",
      "right": "la langue"
    },
    {
      "left": "D'où viens-tu ?",
      "right": "la question"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez le verbe :\nJe ___ rwandais.",
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
    "viens",
    "de",
    "la",
    "RDC"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "parle",
  "hint": "Je parle français."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je vis du Rwanda.",
  "correct_sentence": "Je vis au Rwanda.",
  "explanation": "Venir du Rwanda / vivre au Rwanda. Venir de France / vivre en France."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/rwanda.svg",
      "word": "Rwanda"
    },
    {
      "image_path": "/elearning/mfk-a1/burundi.svg",
      "word": "Burundi"
    },
    {
      "image_path": "/elearning/mfk-a1/france.svg",
      "word": "France"
    },
    {
      "image_path": "/elearning/mfk-a1/rdc.svg",
      "word": "RDC"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez vos 3 phrases : je viens… / je suis… / je parle…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je m'appelle … Je viens de/du/de la … Je suis … Je parle …"
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma carte pour le carton',
    'PE',
    $c$Objectif
Écrire une carte : je viens, je suis (accord), je parle.

Consigne
Comme Yvan, sur un bristol.

Modèle
Je m'appelle Yvan Bizimana.
Je viens du Rwanda.
Je suis rwandais.
Je parle kinyarwanda et français.$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le modèle sépare le pays (je viens) et la nationalité (je suis).",
  "correct": true,
  "explanation": "Je viens du Rwanda. Je suis rwandais."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle préposition avec Rwanda après « je viens » ?",
  "options": [
    {
      "text": "en",
      "correct": false
    },
    {
      "text": "à",
      "correct": false
    },
    {
      "text": "du",
      "correct": true
    },
    {
      "text": "de la",
      "correct": false
    }
  ],
  "explanation": "Je viens du Rwanda."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "de France",
      "right": "venir"
    },
    {
      "left": "du Burundi",
      "right": "venir"
    },
    {
      "left": "en France",
      "right": "vivre"
    },
    {
      "left": "au Rwanda",
      "right": "vivre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe viens ___ France.",
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
    "suis",
    "rwandais"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "goma",
  "hint": "Ville de Didier, en RDC. (on accepte la graphie du mot)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis Rwanda.",
  "correct_sentence": "Je suis rwandais.",
  "explanation": "Le pays : le Rwanda. La nationalité : rwandais / rwandaise."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/rwanda.svg",
      "word": "Rwanda"
    },
    {
      "image_path": "/elearning/mfk-a1/burundi.svg",
      "word": "Burundi"
    },
    {
      "image_path": "/elearning/mfk-a1/france.svg",
      "word": "France"
    },
    {
      "image_path": "/elearning/mfk-a1/rdc.svg",
      "word": "RDC"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez votre bristol : 4 phrases (m'appelle, viens, suis, parle)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre bristol à voix haute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — être, nationalités, de / du / en',
    'EL',
    $c$Objectif
Fixer : être, nationalités (accord), d'où, je parle, de / du / de la / en / au.

Consigne
Fiche au dos du carton.

Fiche
je suis  tu es  il / elle est
nous sommes  vous êtes  ils / elles sont

rwandais / rwandaise
burundais / burundaise
français / française
congolais / congolaise

Je viens de France. Je vis en France.
Je viens du Rwanda. Je vis au Rwanda.
Je viens du Burundi. Je vis au Burundi.
Je viens de la RDC.

Je parle français. Tu parles quelle langue ?$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« française » est le féminin de « français ».",
  "correct": true,
  "explanation": "français / française."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "La tante de Noël est une femme. On dit : elle est ___.",
  "options": [
    {
      "text": "français",
      "correct": false
    },
    {
      "text": "française",
      "correct": true
    },
    {
      "text": "France",
      "correct": false
    },
    {
      "text": "françaises",
      "correct": false
    }
  ],
  "explanation": "Féminin : française."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "de France",
      "right": "venir + pays féminin sans article"
    },
    {
      "left": "du Rwanda",
      "right": "venir + le pays"
    },
    {
      "left": "de la RDC",
      "right": "venir + la"
    },
    {
      "left": "en France",
      "right": "vivre + en"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe vis ___ Rwanda.",
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
    "parle",
    "kinyarwanda"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "burundi",
  "hint": "Pays de Sonia."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je viens de la Rwanda.",
  "correct_sentence": "Je viens du Rwanda.",
  "explanation": "le Rwanda → du. la RDC → de la. la France → de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/rwanda.svg",
      "word": "Rwanda"
    },
    {
      "image_path": "/elearning/mfk-a1/burundi.svg",
      "word": "Burundi"
    },
    {
      "image_path": "/elearning/mfk-a1/france.svg",
      "word": "France"
    },
    {
      "image_path": "/elearning/mfk-a1/rdc.svg",
      "word": "RDC"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez 4 nationalités au masculin et au féminin."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : je suis, tu es, elle est. Puis : je viens du Rwanda. Je vis au Rwanda."
}$j$::jsonb,
    9
  );

  -- ===== Vivre en classe =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Vivre en classe'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Vivre en classe', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Inès lance l''atelier',
    'CO',
    $c$Objectif
Comprendre les consignes (impératif) et les objets (un / une).

Consigne
Lisez l'atelier sous l'auvent. Que dit Inès ? Que répond Yvan ?

Support — Table pliante, 16 h 20
Inès : Asseyez-vous. Écoutez. Ouvrez le cahier.
Yvan : Pardon, Inès. Je ne comprends pas. Répétez, s'il vous plaît.
Inès : Écoutez. Répétez : « kiosque ».
Tous : Kiosque.
Inès : Très bien. Fermez le cahier. Prenez un stylo. C'est un stylo. C'est une chaise.
Sonia : Inès, comment dit-on ça ? (elle montre un livre)
Inès : Un livre. Merci Sonia. Yvan, épelez « Colline ».
Yvan : C-O-L-L-I-N-E. Merci.$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Yvan comprend tout tout de suite.",
  "correct": false,
  "explanation": "Yvan : « Je ne comprends pas. Répétez, s'il vous plaît. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que prend-on après « fermez le cahier » ?",
  "options": [
    {
      "text": "Une porte",
      "correct": false
    },
    {
      "text": "Un stylo",
      "correct": true
    },
    {
      "text": "Un bus",
      "correct": false
    },
    {
      "text": "Un gobelet de soda",
      "correct": false
    }
  ],
  "explanation": "Inès : « Prenez un stylo. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Écoutez.",
      "right": "on entend"
    },
    {
      "left": "Répétez.",
      "right": "on dit encore"
    },
    {
      "left": "Ouvrez le cahier.",
      "right": "on ouvre"
    },
    {
      "left": "Je ne comprends pas.",
      "right": "on a besoin d'aide"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez l'article :\nC'est ___ stylo.",
  "answer": "un"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ouvrez",
    "le",
    "cahier"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "livre",
  "hint": "Sonia le montre : un livre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est un chaise.",
  "correct_sentence": "C'est une chaise.",
  "explanation": "une chaise (féminin). un stylo, un livre, un cahier."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1/stylo.svg",
      "word": "un stylo"
    },
    {
      "image_path": "/elearning/mfk-a1/chaise.svg",
      "word": "une chaise"
    },
    {
      "image_path": "/elearning/mfk-a1/cahier.svg",
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
  "prompt": "Listez 4 consignes entendues et 3 objets (avec un / une)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Répétez les consignes d'Inès, puis : Je ne comprends pas. Répétez, s'il vous plaît."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — La feuille coincée sous le sucrier',
    'CE',
    $c$Objectif
Lire consignes et liste d'objets (un / une).

Consigne
Feuille d'Inès, coincée sous le sucrier du kiosque.

Support
Atelier Colline — consignes
Écoutez. Répétez. Ouvrez le cahier. Fermez le cahier.
Asseyez-vous. Prenez un stylo.
Je ne comprends pas. Comment dit-on … ? Répétez, s'il vous plaît.

Sur la table
un livre • un cahier • un stylo • un sac
une chaise • une table • une boîte • une affiche

Mot du jour
Aujourd'hui : ouvrez le cahier, page 2. C'est un cahier, pas un livre.$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « un chaise » sur la feuille.",
  "correct": false,
  "explanation": "Liste : une chaise. un cahier, un stylo."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle page ouvre-t-on ?",
  "options": [
    {
      "text": "Page 1",
      "correct": false
    },
    {
      "text": "Page 2",
      "correct": true
    },
    {
      "text": "Page 10",
      "correct": false
    },
    {
      "text": "Page 20",
      "correct": false
    }
  ],
  "explanation": "Mot du jour : page 2."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "un livre",
      "right": "masculin"
    },
    {
      "left": "un stylo",
      "right": "masculin"
    },
    {
      "left": "une chaise",
      "right": "féminin"
    },
    {
      "left": "une affiche",
      "right": "féminin"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est ___ cahier.",
  "answer": "un"
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
    "ne",
    "comprends",
    "pas"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "stylo",
  "hint": "On le prend : un stylo."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ouvrez une cahier.",
  "correct_sentence": "Ouvrez le cahier.",
  "explanation": "le cahier (déjà connu sur la table). Article une + mot féminin : une chaise."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1/stylo.svg",
      "word": "un stylo"
    },
    {
      "image_path": "/elearning/mfk-a1/chaise.svg",
      "word": "une chaise"
    },
    {
      "image_path": "/elearning/mfk-a1/cahier.svg",
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
  "prompt": "Recopiez 3 consignes et 2 objets (un … / une …)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le bloc « consignes » à voix haute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Demander sous l''auvent',
    'PO',
    $c$Objectif
Dire l'impératif, je ne comprends pas, comment dit-on… ?

Consigne
Phrases utiles de l'atelier, puis oral.

Modèles
Écoutez. Répétez. Ouvrez le cahier.
Je ne comprends pas.
Répétez, s'il vous plaît.
Comment dit-on « book » en français ?
C'est un livre. C'est une chaise.$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Répétez » veut dire « partez ».",
  "correct": false,
  "explanation": "Répétez = dire encore. Au revoir = partir."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pour demander un mot, on dit :",
  "options": [
    {
      "text": "Asseyez-vous.",
      "correct": false
    },
    {
      "text": "Comment dit-on … ?",
      "correct": true
    },
    {
      "text": "J'ai huit ans.",
      "correct": false
    },
    {
      "text": "Je viens du Rwanda.",
      "correct": false
    }
  ],
  "explanation": "Comment dit-on … en français ?"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Écoutez.",
      "right": "Inès parle"
    },
    {
      "left": "Répétez, s'il vous plaît.",
      "right": "je n'ai pas entendu"
    },
    {
      "left": "Je ne comprends pas.",
      "right": "c'est difficile"
    },
    {
      "left": "Comment dit-on … ?",
      "right": "je cherche le mot"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est ___ chaise.",
  "answer": "une"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Répétez",
    "s'il",
    "vous",
    "plaît"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "cahier",
  "hint": "Ouvrez le cahier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ne comprends.",
  "correct_sentence": "Je ne comprends pas.",
  "explanation": "Négation : ne … pas."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1/stylo.svg",
      "word": "un stylo"
    },
    {
      "image_path": "/elearning/mfk-a1/chaise.svg",
      "word": "une chaise"
    },
    {
      "image_path": "/elearning/mfk-a1/cahier.svg",
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
  "prompt": "Écrivez 2 consignes et 1 demande d'aide (je ne comprends pas / comment dit-on)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Pardon, Inès. Je ne comprends pas. Répétez, s'il vous plaît. Comment dit-on … ?"
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — La liste pour Didier',
    'PE',
    $c$Objectif
Écrire consignes et objets (un / une) pour le comptoir.

Consigne
Didier veut la liste. Écrivez comme Inès.

Modèle
Écoutez. Répétez.
Ouvrez le cahier.
C'est un stylo. C'est une chaise.
Je ne comprends pas.$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le modèle mélange un et une selon l'objet.",
  "correct": true,
  "explanation": "un stylo / une chaise."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel article devant « stylo » ?",
  "options": [
    {
      "text": "une",
      "correct": false
    },
    {
      "text": "un",
      "correct": true
    },
    {
      "text": "le jour",
      "correct": false
    },
    {
      "text": "du",
      "correct": false
    }
  ],
  "explanation": "un stylo."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Écoutez.",
      "right": "consigne"
    },
    {
      "left": "un livre",
      "right": "objet masculin"
    },
    {
      "left": "une table",
      "right": "objet féminin"
    },
    {
      "left": "Je ne comprends pas.",
      "right": "aide"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPrenez ___ livre.",
  "answer": "un"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Fermez",
    "le",
    "cahier"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "table",
  "hint": "C'est une table (la table pliante)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est une stylo.",
  "correct_sentence": "C'est un stylo.",
  "explanation": "stylo = masculin : un."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1/stylo.svg",
      "word": "un stylo"
    },
    {
      "image_path": "/elearning/mfk-a1/chaise.svg",
      "word": "une chaise"
    },
    {
      "image_path": "/elearning/mfk-a1/cahier.svg",
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
  "prompt": "Écrivez 4 lignes pour Didier : 1 consigne, un …, une …, je ne comprends pas."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre liste à Didier, à voix haute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Impératif, un / une, je ne comprends pas',
    'EL',
    $c$Objectif
Fixer : impératif de l'atelier, un / une, phrases utiles.

Consigne
Fiche dans la boîte à craies du kiosque.

Fiche
Écoutez. Répétez. Ouvrez. Fermez. Asseyez-vous. Prenez. Épelez.

un livre, un cahier, un stylo, un sac
une chaise, une table, une boîte, une affiche
C'est un livre. C'est une chaise.

Je ne comprends pas.
Répétez, s'il vous plaît.
Comment dit-on … en français ?
Pardon, Inès / Didier.

Je comprends. → Je ne comprends pas.$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« une » va avec un nom féminin, comme chaise.",
  "correct": true,
  "explanation": "une chaise, une table, une affiche."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Inès veut que le groupe dise encore le mot. Elle dit :",
  "options": [
    {
      "text": "Asseyez-vous.",
      "correct": false
    },
    {
      "text": "Répétez.",
      "correct": true
    },
    {
      "text": "Au revoir.",
      "correct": false
    },
    {
      "text": "J'ai huit ans.",
      "correct": false
    }
  ],
  "explanation": "Répétez."
}$j$::jsonb,
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
      "right": "livre / cahier / stylo"
    },
    {
      "left": "une",
      "right": "chaise / table / affiche"
    },
    {
      "left": "Écoutez",
      "right": "impératif"
    },
    {
      "left": "pas",
      "right": "négation avec ne"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ne comprends ___.",
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
    "Comment",
    "dit-on",
    "ça"
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "stylo",
  "hint": "C'est un stylo. Objet masculin de la table."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ne comprends.",
  "correct_sentence": "Je ne comprends pas.",
  "explanation": "ne … pas."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1/livre.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a1/stylo.svg",
      "word": "un stylo"
    },
    {
      "image_path": "/elearning/mfk-a1/chaise.svg",
      "word": "une chaise"
    },
    {
      "image_path": "/elearning/mfk-a1/cahier.svg",
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
  "prompt": "Écrivez 4 impératifs et 4 objets avec un ou une."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites les consignes de la fiche, puis : je ne comprends pas. Répétez, s'il vous plaît."
}$j$::jsonb,
    9
  );

  RAISE NOTICE 'Seed Module 1 terminé (module %)', v_module_id;
END;
$$;
