/*
  Seed eLearning MFK — A2 — Petits gestes, grand quotidien

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a2-m6/
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
  v_module_title text := 'A2 — Petits gestes, grand quotidien';
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
      'Seed A2 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed A2 : enseignant % (%) — %', v_teacher_email, v_teacher_id, v_module_title;

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
      'Grande étape A2-6 : suivre des instructions du jour, rédiger une recette, lire un mode d''emploi, raconter une réussite, prendre soin de soi et enchaîner des actions — dans la cuisine de Félicie Ndayishimiye et sur le tableau de la cour, au Seuil des Sources (Rukiri-Nord).',
      'A2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape A2-6 : suivre des instructions du jour, rédiger une recette, lire un mode d''emploi, raconter une réussite, prendre soin de soi et enchaîner des actions — dans la cuisine de Félicie Ndayishimiye et sur le tableau de la cour, au Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'A2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Instructions du jour =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Instructions du jour'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Instructions du jour', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Tableau de Félicie',
    'CO',
    $c$Objectif
Repérer nous commençons, nous mangeons, nous essuyons, j'essaie / je paie.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Quels verbes change-t-on ?

Support — Cuisine ocre, tablier de Félicie
Aline : Lisez le tableau. Nous commençons à sept heures.
Félicie : Vous rangez les bols. Ensuite, nous rangeons la table.
Léa : J'essuie le banc. Nous essuyons aussi les tasses.
Patrick : J'essaie la recette verte. Nous essayons ensemble.
Hawa : Je paie les herbes au Marché des Lampions. Nous payons ce soir.
Joël : Nous avançons le banc trop près de l'eau.
Rose : On mange tôt. Nous mangeons sous le figuier.
Marc : Je place les paniers. Nous plaçons tout près de la Table des Sources.
Dieudonné : J'emploie le tablier ocre. Nous employons les nôtres aussi.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Félicie dit : nous rangeons la table.",
  "correct": true,
  "explanation": "Félicie : « nous rangeons la table. » — -ger : e devant ons."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est correcte pour commencer à la 1re personne du pluriel ?",
  "options": [
    {
      "text": "nous commencons",
      "correct": false
    },
    {
      "text": "nous commençons",
      "correct": true
    },
    {
      "text": "nous commençonsse",
      "correct": false
    },
    {
      "text": "nous commenceons",
      "correct": false
    }
  ],
  "explanation": "Devant o, c devient ç : nous commençons."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "nous commençons",
      "right": "-cer → ç"
    },
    {
      "left": "nous rangeons",
      "right": "-ger → geo"
    },
    {
      "left": "nous essuyons",
      "right": "-yer → yons"
    },
    {
      "left": "j'essaie / je paie",
      "right": "-ayer : ai ou ay"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ à sept heures. (commencer)",
  "answer": "commençons"
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
    "mangeons",
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
  "word": "essuyons",
  "hint": "Nous… les tasses : verbe essuyer à nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous commencons à sept heures.",
  "correct_sentence": "Nous commençons à sept heures.",
  "explanation": "Devant o, on écrit ç : commençons."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/verbe-cer.svg",
      "word": "commencer"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/verbe-ger.svg",
      "word": "manger"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/verbe-yer.svg",
      "word": "essuyer"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/tableau-conjug.svg",
      "word": "un tableau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez quatre formes : un -cer, un -ger, un -yer, un -ayer."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Nous commençons. Nous mangeons. Nous essuyons. J'essaie. Je paie."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Mot du matin',
    'CE',
    $c$Objectif
Lire des consignes du jour avec les verbes en -cer, -ger, -yer, -ayer.

Consigne
Lisez le mot épinglé au figuier, sans aller trop vite.

Support — Tableau de la cour, craie ocre
Mot du matin — Félicie Ndayishimiye
Nous commençons par l'eau froide. Nous plaçons les bols à gauche.
Nous mangeons après le marché, pas avant.
Nous rangeons les paniers. Nous partageons le pain de Mado.
J'essuie le banc. Vous essuyez les tasses de Rose.
J'essaie le sel de Noura. Vous essayez la recette de Joël.
Je paie Ibrahim pour les figues. Nous payons ensemble le soir.
Nous balayons la Salle des Herbes. Je balaie d'abord le seuil.
Merci. Félicie — cuisine du Seuil.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On mange avant le marché.",
  "correct": false,
  "explanation": "« Nous mangeons après le marché, pas avant. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui paie Ibrahim pour les figues ?",
  "options": [
    {
      "text": "Patrick",
      "correct": false
    },
    {
      "text": "Félicie (je paie)",
      "correct": true
    },
    {
      "text": "Solange",
      "correct": false
    },
    {
      "text": "Karim",
      "correct": false
    }
  ],
  "explanation": "« Je paie Ibrahim pour les figues. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "nous plaçons",
      "right": "les bols"
    },
    {
      "left": "nous partageons",
      "right": "le pain"
    },
    {
      "left": "vous essuyez",
      "right": "les tasses"
    },
    {
      "left": "nous balayons",
      "right": "la salle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ les paniers. (ranger)",
  "answer": "rangeons"
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
    "plaçons",
    "les",
    "bols",
    "à",
    "gauche",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "partageons",
  "hint": "Nous… le pain : verbe partager à nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous mangons après le marché, pas avant.",
  "correct_sentence": "Nous mangeons après le marché, pas avant.",
  "explanation": "Manger : nous mangeons (e devant ons)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/recette-felicie.svg",
      "word": "une recette"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/bol-essayer.svg",
      "word": "un bol"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/cuillere-reussir.svg",
      "word": "une cuillère"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/cahier-preposition.svg",
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
  "prompt": "Recopiez le mot et soulignez commençons, rangeons, essuyez, payons."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le mot de Félicie, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire nous commençons',
    'PO',
    $c$Objectif
Prononcer les formes nous et je des verbes en -cer, -ger, -yer, -ayer.

Consigne
Répétez les modèles, puis donnez deux consignes de cuisine.

Support — Modèles d'Aline
Nous commençons maintenant.
Nous avançons le banc.
Nous mangeons sous le figuier.
Nous rangeons les bols.
J'essuie. Nous essuyons.
J'essaie. Nous essayons.
Je paie. Nous payons.
Je balaie. Nous balayons.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit nous mangeons avec un e devant ons.",
  "correct": true,
  "explanation": "Pour garder le son [ʒ] : mangeons."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle paire est correcte ?",
  "options": [
    {
      "text": "j'essaie / nous essaiions",
      "correct": false
    },
    {
      "text": "j'essaye / nous essayons",
      "correct": true
    },
    {
      "text": "j'essai / nous essuyons",
      "correct": false
    },
    {
      "text": "j'essuye / nous essaions",
      "correct": false
    }
  ],
  "explanation": "Essayer : j'essaie ou j'essaye ; nous essayons."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "placer → nous",
      "right": "plaçons"
    },
    {
      "left": "changer → nous",
      "right": "changeons"
    },
    {
      "left": "nettoyer → nous",
      "right": "nettoyons"
    },
    {
      "left": "payer → je",
      "right": "paie ou paye"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ le banc. (avancer)",
  "answer": "avançons"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'essuie",
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
  "word": "balayons",
  "hint": "Nous… la salle : verbe balayer à nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous avanceons le banc.",
  "correct_sentence": "Nous avançons le banc.",
  "explanation": "Avancer : ç devant o."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/mode-emploi.svg",
      "word": "un mode d'emploi"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/si-imparfait.svg",
      "word": "une hypothèse"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/quelqu-un.svg",
      "word": "quelqu'un"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/boite-notice.svg",
      "word": "une boîte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Conjuguez commencer, manger, essuyer, payer au nous et au je."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux consignes à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mes consignes du jour',
    'PE',
    $c$Objectif
Écrire cinq consignes avec -cer, -ger, -yer, -ayer.

Consigne
Imitez la liste de Félicie.

Support — Liste de Félicie Ndayishimiye
Félicie Ndayishimiye
Nous commençons par laver les mains.
Nous plaçons les herbes à droite.
Nous mangeons après avoir rangé.
J'essuie la Table des Sources. Vous essuyez les tasses.
J'essaie le sel. Nous payons Mado ce soir.
Félicie
Cuisine du Seuil — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Félicie écrit nous plaçons les herbes à gauche.",
  "correct": false,
  "explanation": "« Nous plaçons les herbes à droite. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase utilise un verbe en -ger ?",
  "options": [
    {
      "text": "Nous commençons par laver",
      "correct": false
    },
    {
      "text": "Nous mangeons après avoir rangé",
      "correct": true
    },
    {
      "text": "J'essuie la Table",
      "correct": false
    },
    {
      "text": "Nous payons Mado",
      "correct": false
    }
  ],
  "explanation": "Manger → nous mangeons."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "commençons",
      "right": "laver les mains"
    },
    {
      "left": "plaçons",
      "right": "herbes à droite"
    },
    {
      "left": "mangeons",
      "right": "après avoir rangé"
    },
    {
      "left": "payons",
      "right": "Mado"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'___ le sel. (essayer, forme en ai)",
  "answer": "essaie"
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
    "commençons",
    "par",
    "laver",
    "les",
    "mains",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "plaçons",
  "hint": "Nous… les herbes : verbe placer à nous (avec ç)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous placeons les herbes à droite.",
  "correct_sentence": "Nous plaçons les herbes à droite.",
  "explanation": "Placer : ç devant o."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/accord-avoir.svg",
      "word": "un accord"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/assiette-reussie.svg",
      "word": "une assiette"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/tache-faite.svg",
      "word": "une tâche"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/sourire-hawa.svg",
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
  "prompt": "Imitez : cinq lignes, quatre familles de verbes."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre liste, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — -cer, -ger, -yer, -ayer',
    'EL',
    $c$Objectif
Retenir les changements d'orthographe à nous et à je.

Consigne
Apprenez la fiche.

Support — Fiche du carnet ocre
-cer : c → ç devant a / o. nous commençons, nous avançons, nous plaçons
-ger : on garde e devant a / o. nous mangeons, nous rangeons, nous partageons
-yer : y → i devant e muet. j'essuie, tu essuies ; nous essuyons (y reste)
essayer : j'essaie ou j'essaye ; nous essayons
payer / balayer : je paie ou je paye ; je balaie ou je balaye ; nous payons
employer / nettoyer : j'emploie, nous employons ; je nettoie, nous nettoyons
On n'écrit pas : nous commencons, nous mangeons sans e, nous essuions.
Au Seuil, Félicie écrit ces formes au tableau de la cour chaque matin.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut écrire j'essaie et j'essaye.",
  "correct": true,
  "explanation": "Les deux formes sont acceptées."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est fausse ?",
  "options": [
    {
      "text": "nous commençons",
      "correct": false
    },
    {
      "text": "nous mangeons",
      "correct": false
    },
    {
      "text": "nous essuyons",
      "correct": false
    },
    {
      "text": "nous commencons",
      "correct": true
    }
  ],
  "explanation": "Il manque la cédille : commençons."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "commencer",
      "right": "nous commençons"
    },
    {
      "left": "manger",
      "right": "nous mangeons"
    },
    {
      "left": "essuyer",
      "right": "j'essuie / nous essuyons"
    },
    {
      "left": "payer",
      "right": "je paie / nous payons"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ les tasses. (essuyer)",
  "answer": "essuyons"
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
    "paie",
    "les",
    "herbes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "cedille",
  "hint": "Le petit signe sous le c de commençons (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous essuions les tasses.",
  "correct_sentence": "Nous essuyons les tasses.",
  "explanation": "À nous, y reste : essuyons."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/pronoms-possessifs.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/miroir-soin.svg",
      "word": "un miroir"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/serviette-mienne.svg",
      "word": "une serviette"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/brosse-tienne.svg",
      "word": "une brosse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Faites un tableau : six verbes, je et nous."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre formes à vous."
}$j$::jsonb,
    9
  );

  -- ===== Une recette à rédiger =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une recette à rédiger'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une recette à rédiger', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Autour du bol',
    'CO',
    $c$Objectif
Repérer essayer de, éviter de, réussir à, continuer à, commencer à, s'arrêter de.

Consigne
Lisez le dialogue. Quel verbe va avec de ? Quel verbe va avec à ?

Support — Table des Sources, recette de Félicie
Félicie : Essayez de couper les herbes très fines.
Léa : J'évite de trop saler. Hawa a trop salé hier.
Patrick : Tu réussis à mélanger sans grumeaux ?
Aline : Continuez à tourner. Ne vous arrêtez pas de regarder le feu.
Marc : On commence à sentir le citron de Lila.
Joël : Je refuse de goûter trop tôt. J'attends.
Rose : J'accepte de noter les doses dans le Cahier du chemin.
Hawa : J'arrive à finir le potage. Je m'arrête de parler.
Yvette : Pensez à couvrir le bol. N'oubliez pas de le poser à gauche.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Réussir se construit avec à.",
  "correct": true,
  "explanation": "Patrick : « Tu réussis à mélanger… »"
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
      "text": "essayer à couper",
      "correct": false
    },
    {
      "text": "essayer de couper",
      "correct": true
    },
    {
      "text": "réussir de mélanger",
      "correct": false
    },
    {
      "text": "éviter à trop saler",
      "correct": false
    }
  ],
  "explanation": "Essayer de + infinitif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "essayer de",
      "right": "couper"
    },
    {
      "left": "éviter de",
      "right": "trop saler"
    },
    {
      "left": "réussir à",
      "right": "mélanger"
    },
    {
      "left": "s'arrêter de",
      "right": "parler"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nContinuez ___ tourner.",
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
    "Essayez",
    "de",
    "couper",
    "les",
    "herbes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "eviter",
  "hint": "Le verbe… de trop saler (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'essaie à couper les herbes.",
  "correct_sentence": "J'essaie de couper les herbes.",
  "explanation": "Essayer de + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/recette-felicie.svg",
      "word": "une recette"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/bol-essayer.svg",
      "word": "un bol"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/cuillere-reussir.svg",
      "word": "une cuillère"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/cahier-preposition.svg",
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
  "prompt": "Classez six verbes : + de ou + à."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : J'essaie de couper. J'évite de saler. Je réussis à mélanger. Je continue à tourner."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Recette du potage ocre',
    'CE',
    $c$Objectif
Lire une recette qui enchaîne les verbes prépositionnels.

Consigne
Lisez la recette, sans aller trop vite.

Support — Feuille de Félicie, Salle des Herbes
Potage ocre du Seuil — 4 bols
1. Commencez à laver les feuilles du Marché des Lampions.
2. Essayez de les ciseler sans les écraser.
3. Évitez de trop remplir le pot. Réussissez à laisser un doigt d'eau.
4. Continuez à tourner. Arrêtez-vous de tourner quand ça sent le citron.
5. Pensez à goûter. N'oubliez pas de poser le sel à droite.
6. Refusez de servir trop chaud. Acceptez de patienter deux minutes.
Félicie Ndayishimiye — cuisine du Seuil
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On doit remplir le pot jusqu'au bord.",
  "correct": false,
  "explanation": "« Évitez de trop remplir le pot. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quand s'arrête-t-on de tourner ?",
  "options": [
    {
      "text": "Quand l'eau bout seulement",
      "correct": false
    },
    {
      "text": "Quand ça sent le citron",
      "correct": true
    },
    {
      "text": "Avant de laver",
      "correct": false
    },
    {
      "text": "Chez Ibrahim",
      "correct": false
    }
  ],
  "explanation": "Point 4 de la recette."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "commencer à",
      "right": "laver"
    },
    {
      "left": "essayer de",
      "right": "ciseler"
    },
    {
      "left": "réussir à",
      "right": "laisser un doigt"
    },
    {
      "left": "penser à",
      "right": "goûter"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nArrêtez-vous ___ tourner quand ça sent le citron.",
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
    "Continuez",
    "à",
    "tourner",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ciseler",
  "hint": "Couper très fin, sans écraser les feuilles."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Réussissez de laisser un doigt d'eau.",
  "correct_sentence": "Réussissez à laisser un doigt d'eau.",
  "explanation": "Réussir à + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/verbe-ger.svg",
      "word": "manger"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/verbe-yer.svg",
      "word": "essuyer"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/tableau-conjug.svg",
      "word": "un tableau"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/recette-felicie.svg",
      "word": "une recette"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la recette et encadrez de / à après chaque verbe."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six points de la recette, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire de et à',
    'PO',
    $c$Objectif
Enchaîner à voix haute essayer de, éviter de, réussir à, continuer à.

Consigne
Répétez, puis parlez d'un geste de cuisine à vous.

Support — Modèles de Patrick
J'essaie de couper droit.
J'évite de brûler le fond.
Je réussis à mélanger.
Je continue à tourner.
Je commence à sentir le citron.
Je m'arrête de parler.
Je pense à couvrir.
J'oublie de goûter ? Non.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "S'arrêter se construit avec de.",
  "correct": true,
  "explanation": "S'arrêter de + infinitif."
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
      "text": "Je continue de tourner le feu trop",
      "correct": false
    },
    {
      "text": "Je continue à tourner",
      "correct": true
    },
    {
      "text": "Je réussis de mélanger",
      "correct": false
    },
    {
      "text": "J'évite à brûler",
      "correct": false
    }
  ],
  "explanation": "Continuer à + infinitif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "essayer / éviter / s'arrêter",
      "right": "+ de"
    },
    {
      "left": "réussir / continuer / commencer",
      "right": "+ à"
    },
    {
      "left": "penser",
      "right": "+ à"
    },
    {
      "left": "oublier / refuser / accepter",
      "right": "+ de"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe réussis ___ mélanger.",
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
    "m'arrête",
    "de",
    "parler",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "reussir",
  "hint": "Le verbe… à mélanger (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je continue de tourner sans pause ici.",
  "correct_sentence": "Je continue à tourner.",
  "explanation": "Continuer à + infinitif (sens « poursuivre »)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/avant-de.svg",
      "word": "avant de"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/apres-inf.svg",
      "word": "après"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/fleche-suite.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/horloge-actions.svg",
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
  "prompt": "Écrivez six phrases : trois + de, trois + à."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux phrases à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma recette courte',
    'PE',
    $c$Objectif
Écrire une recette de cinq lignes avec des verbes prépositionnels.

Consigne
Imitez la recette de Léa.

Support — Recette de Léa Niyonzima
Léa Niyonzima
J'essaie de couper les figues de Sami.
J'évite de trop sucrer. Je réussis à garder le goût.
Je continue à tourner. Je commence à voir une crème.
Je m'arrête de parler pour goûter.
Je pense à servir sous le figuier.
Léa
Table des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa sert à la Maison des Vents.",
  "correct": false,
  "explanation": "« Je pense à servir sous le figuier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que réussit Léa ?",
  "options": [
    {
      "text": "À trop sucrer",
      "correct": false
    },
    {
      "text": "À garder le goût",
      "correct": true
    },
    {
      "text": "À brûler",
      "correct": false
    },
    {
      "text": "À cacher le bol",
      "correct": false
    }
  ],
  "explanation": "« Je réussis à garder le goût. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "essaie de",
      "right": "couper"
    },
    {
      "left": "évite de",
      "right": "trop sucrer"
    },
    {
      "left": "réussit à",
      "right": "garder le goût"
    },
    {
      "left": "pense à",
      "right": "servir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe m'arrête ___ parler pour goûter.",
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
    "J'essaie",
    "de",
    "couper",
    "les",
    "figues",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "sucrer",
  "hint": "Léa évite de trop… le potage."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je réussis de garder le goût.",
  "correct_sentence": "Je réussis à garder le goût.",
  "explanation": "Réussir à."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/marche-herbes.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/panier-jour.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/eau-soin.svg",
      "word": "de l'eau"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/plante-balcon.svg",
      "word": "une plante"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : cinq lignes, au moins quatre verbes prépositionnels."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre recette, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Verbes + de / + à',
    'EL',
    $c$Objectif
Retenir les constructions : essayer de, éviter de, réussir à, continuer à…

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
+ de : essayer de, éviter de, s'arrêter de, oublier de, refuser de, accepter de
+ à : réussir à, continuer à, commencer à, arriver à, penser à, hésiter à
Sens : de souvent « se détacher / tenter » ; à souvent « se diriger vers l'action »
Attention : commencer à (pas commencer de, en français courant).
Continuer à + infinitif = poursuivre. Continuer de existe, plus rare ici : on retient à.
Ne pas dire : je réussis de, j'essaie à.
Dans la cuisine de Félicie : on essaie de goûter, on réussit à tourner.
Pensez à couvrir. N'oubliez pas de poser le sel.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je réussis de » à l'A2 du Seuil.",
  "correct": false,
  "explanation": "Réussir à."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Oublier » se construit avec…",
  "options": [
    {
      "text": "à",
      "correct": false
    },
    {
      "text": "de",
      "correct": true
    },
    {
      "text": "pour",
      "correct": false
    },
    {
      "text": "sur",
      "correct": false
    }
  ],
  "explanation": "Oublier de + infinitif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "essayer de",
      "right": "tenter"
    },
    {
      "left": "éviter de",
      "right": "ne pas faire"
    },
    {
      "left": "réussir à",
      "right": "y arriver"
    },
    {
      "left": "s'arrêter de",
      "right": "cesser"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nN'oubliez pas ___ poser le sel.",
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
    "commence",
    "à",
    "sentir",
    "le",
    "citron",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "oublier",
  "hint": "Le verbe… de poser le sel à droite."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je commence de laver les feuilles.",
  "correct_sentence": "Je commence à laver les feuilles.",
  "explanation": "Commencer à + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/eau-soin.svg",
      "word": "de l'eau"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/plante-balcon.svg",
      "word": "une plante"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/tablier-cuisine.svg",
      "word": "un tablier"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/liste-courses.svg",
      "word": "une liste"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Complétez un tableau : huit verbes, de ou à, un exemple chacun."
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

  -- ===== Un mode d'emploi =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un mode d''emploi'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un mode d''emploi', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La boîte des herbes',
    'CO',
    $c$Objectif
Comprendre si + imparfait → conditionnel, et quelqu'un / quelque chose / rien / personne / on.

Consigne
Lisez le dialogue. Que ferait-on si… ? Qui fait quoi ?

Support — Boîte ocre, Infirmerie des Herbes
Aline : Si on ouvrait trop vite, on casserait le couvercle.
Félicie : Si quelqu'un appelait, on attendrait. On ne répond pas les mains mouillées.
Léa : Il n'y a personne dans le couloir. Il n'y a rien dans la boîte ?
Patrick : Si, il y a quelque chose : le sachet de Noura.
Hawa : Si personne ne lisait la notice, on se tromperait de dose.
Joël : On ferme toujours. Si on oubliait, l'odeur partirait.
Rose : Quelqu'un a laissé une cuillère. Ce n'est rien, je range.
Marc : Si on avait le temps, on relirait chaque ligne.
Yvette : On est prudents. Si quelque chose clochait, on irait voir Solange.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "S'il n'y a personne dans le couloir, le couloir est vide.",
  "correct": true,
  "explanation": "Personne = aucun être."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que ferait-on si on ouvrait trop vite ?",
  "options": [
    {
      "text": "On gagnerait du temps",
      "correct": false
    },
    {
      "text": "On casserait le couvercle",
      "correct": true
    },
    {
      "text": "On paierait Ibrahim",
      "correct": false
    },
    {
      "text": "On irait à Val-des-Peupliers",
      "correct": false
    }
  ],
  "explanation": "Aline : « on casserait le couvercle. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si on ouvrait",
      "right": "on casserait"
    },
    {
      "left": "quelqu'un",
      "right": "une personne"
    },
    {
      "left": "rien",
      "right": "aucune chose"
    },
    {
      "left": "personne",
      "right": "aucun être"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nS'il n'y a ___ dans la boîte, elle est vide.",
  "answer": "rien"
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
    "quelqu'un",
    "appelait",
    "on",
    "attendrait",
    "."
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
  "hint": "On le casserait si on ouvrait trop vite."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si on ouvre trop vite, on casserait le couvercle.",
  "correct_sentence": "Si on ouvrait trop vite, on casserait le couvercle.",
  "explanation": "Si + imparfait → conditionnel."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/mode-emploi.svg",
      "word": "un mode d'emploi"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/si-imparfait.svg",
      "word": "une hypothèse"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/quelqu-un.svg",
      "word": "quelqu'un"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/boite-notice.svg",
      "word": "une boîte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez deux phrases si + imparfait et trois indéfinis."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Si on ouvrait trop vite, on casserait le couvercle. Il n'y a personne. Il y a quelque chose."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Notice de la boîte',
    'CE',
    $c$Objectif
Lire un mode d'emploi avec hypothèses et indéfinis.

Consigne
Lisez la notice, sans aller trop vite.

Support — Notice collée, Infirmerie des Herbes
Boîte des Herbes — mode d'emploi
1. On ouvre lentement. Si on forçait, on casserait le bois.
2. S'il n'y a plus rien, on va au Marché des Lampions.
3. Si quelqu'un d'autre a déjà mesuré, on ne recommence pas.
4. On ne laisse personne toucher le sachet de Noura sans gants.
5. Si quelque chose sentait trop fort, on aérerait la salle.
6. Questions : Yvette ou Lila Sow. On n'écrit rien au crayon sur le bois.
Seuil des Sources — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut écrire au crayon sur le bois.",
  "correct": false,
  "explanation": "« On n'écrit rien au crayon sur le bois. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que ferait-on si quelque chose sentait trop fort ?",
  "options": [
    {
      "text": "On fermerait",
      "correct": false
    },
    {
      "text": "On aérerait la salle",
      "correct": true
    },
    {
      "text": "On paierait",
      "correct": false
    },
    {
      "text": "On cacherait Yvette",
      "correct": false
    }
  ],
  "explanation": "Point 5."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si on forçait",
      "right": "on casserait"
    },
    {
      "left": "plus rien",
      "right": "boîte vide"
    },
    {
      "left": "quelqu'un d'autre",
      "right": "a déjà mesuré"
    },
    {
      "left": "personne",
      "right": "sans gants"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ne laisse ___ toucher le sachet sans gants.",
  "answer": "personne"
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
    "ouvre",
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
  "word": "aererait",
  "hint": "On… la salle si l'odeur était trop forte (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si on force, on casserait le bois.",
  "correct_sentence": "Si on forçait, on casserait le bois.",
  "explanation": "Les deux verbes suivent si + imparfait / conditionnel."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/tablier-cuisine.svg",
      "word": "un tablier"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/liste-courses.svg",
      "word": "une liste"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/verbe-cer.svg",
      "word": "commencer"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/verbe-ger.svg",
      "word": "manger"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez trois hypothèses et encadrez quelqu'un / rien / personne / on."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six points de la notice, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Si on ouvrait…',
    'PO',
    $c$Objectif
Former des hypothèses et utiliser les pronoms indéfinis à l'oral.

Consigne
Répétez, puis imaginez un geste de la cuisine.

Support — Modèles de Marc
Si on ouvrait trop vite, on casserait tout.
Si quelqu'un appelait, on attendrait.
S'il n'y avait rien, on irait au marché.
Si personne ne lisait, on se tromperait.
On ferme toujours.
Il y a quelque chose ici.
Ce n'est rien.
Il n'y a personne.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« On » peut vouloir dire « nous » dans la notice.",
  "correct": true,
  "explanation": "On ouvre = nous ouvrons."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase contient une hypothèse irréelle simple ?",
  "options": [
    {
      "text": "On ferme toujours",
      "correct": false
    },
    {
      "text": "Si on ouvrait trop vite, on casserait tout",
      "correct": true
    },
    {
      "text": "Il y a quelque chose ici",
      "correct": false
    },
    {
      "text": "Ce n'est rien",
      "correct": false
    }
  ],
  "explanation": "Si + imparfait + conditionnel."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si + imparfait",
      "right": "conditionnel"
    },
    {
      "left": "quelqu'un",
      "right": "une personne"
    },
    {
      "left": "quelque chose",
      "right": "une chose"
    },
    {
      "left": "on",
      "right": "nous / les gens"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi personne ne lisait, on se ___.",
  "answer": "tromperait"
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
    "rien",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "quelquun",
  "hint": "Une personne, pas personne : … (sans apostrophe)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si on aurait le temps, on relirait.",
  "correct_sentence": "Si on avait le temps, on relirait.",
  "explanation": "Après si : imparfait, pas conditionnel."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/accord-avoir.svg",
      "word": "un accord"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/assiette-reussie.svg",
      "word": "une assiette"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/tache-faite.svg",
      "word": "une tâche"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/sourire-hawa.svg",
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
  "prompt": "Écrivez quatre phrases si + imparfait et quatre avec un indéfini."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux hypothèses à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma notice',
    'PE',
    $c$Objectif
Écrire un court mode d'emploi avec si et des indéfinis.

Consigne
Imitez la notice de Hawa.

Support — Notice de Hawa Diallo
Hawa Diallo
On ouvre la boîte sans forcer.
Si on forçait, on casserait le bois.
S'il n'y a plus rien, on prévient Félicie.
On ne laisse personne tout seul avec le feu.
Si quelqu'un demandait de l'aide, on irait.
Ce n'est rien si on attend une minute.
Hawa
Infirmerie des Herbes
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa autorise à rester seul avec le feu.",
  "correct": false,
  "explanation": "« On ne laisse personne tout seul avec le feu. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait-on s'il n'y a plus rien ?",
  "options": [
    {
      "text": "On cache la boîte",
      "correct": false
    },
    {
      "text": "On prévient Félicie",
      "correct": true
    },
    {
      "text": "On part à Mwezi-Haut",
      "correct": false
    },
    {
      "text": "On paie Kévin",
      "correct": false
    }
  ],
  "explanation": "« on prévient Félicie. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si on forçait",
      "right": "on casserait"
    },
    {
      "left": "plus rien",
      "right": "prévenir Félicie"
    },
    {
      "left": "personne",
      "right": "pas seul au feu"
    },
    {
      "left": "quelqu'un",
      "right": "demanderait de l'aide"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi quelqu'un demandait de l'aide, on ___.",
  "answer": "irait"
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
    "ouvre",
    "la",
    "boîte",
    "sans",
    "forcer",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "forcer",
  "hint": "Si on… trop, le bois casse."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si on forcerait, on casserait le bois.",
  "correct_sentence": "Si on forçait, on casserait le bois.",
  "explanation": "Pas de conditionnel juste après si."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/pronoms-possessifs.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/miroir-soin.svg",
      "word": "un miroir"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/serviette-mienne.svg",
      "word": "une serviette"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/brosse-tienne.svg",
      "word": "une brosse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes, deux si, trois indéfinis."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre notice, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Si et les indéfinis',
    'EL',
    $c$Objectif
Retenir si + imparfait → conditionnel ; quelqu'un, quelque chose, rien, personne, on.

Consigne
Apprenez la fiche.

Support — Fiche de Lila Sow
Si + imparfait, conditionnel : Si on avait le temps, on relirait.
Jamais : si on aurait. (si + conditionnel = faute ici)
quelqu'un = une personne (affirmation)
quelque chose = une chose
rien = aucune chose (avec ne : il n'y a rien)
personne = aucun être (avec ne : je ne vois personne)
on = nous / quelqu'un / les gens
rien et personne : le verbe a ne…
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « si j'aurais » dans cette leçon.",
  "correct": false,
  "explanation": "Si + imparfait : si j'avais."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Je ne vois… » + aucun être =",
  "options": [
    {
      "text": "rien",
      "correct": false
    },
    {
      "text": "quelqu'un",
      "correct": false
    },
    {
      "text": "personne",
      "correct": true
    },
    {
      "text": "on",
      "correct": false
    }
  ],
  "explanation": "Je ne vois personne."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si + imparfait",
      "right": "condition"
    },
    {
      "left": "conditionnel",
      "right": "résultat imaginé"
    },
    {
      "left": "rien",
      "right": "chose nulle"
    },
    {
      "left": "personne",
      "right": "être nul"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ne vois ___. (aucun être)",
  "answer": "personne"
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
    "n'y",
    "a",
    "rien",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "imparfait",
  "hint": "Le temps après si dans cette hypothèse."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il n'y a pas personne dans le couloir.",
  "correct_sentence": "Il n'y a personne dans le couloir.",
  "explanation": "Personne suffit : ne… personne, pas ne… pas personne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/avant-de.svg",
      "word": "avant de"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/apres-inf.svg",
      "word": "après"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/fleche-suite.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/horloge-actions.svg",
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
  "prompt": "Transformez : On ouvre trop vite → Si on… / Il y a une personne → …"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et quatre transformations."
}$j$::jsonb,
    9
  );

  -- ===== Une réussite à raconter =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une réussite à raconter'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une réussite à raconter', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Les galettes de Hawa',
    'CO',
    $c$Objectif
Repérer l'accord du participe passé avec avoir quand le COD est avant le verbe.

Consigne
Lisez le dialogue. Qu'est-ce qui a été fait ? Où est le COD ?

Support — Cuisine, assiettes encore chaudes
Hawa : Je les ai faites, les galettes. Vous les avez vues ?
Félicie : La tasse que tu as cassée, je l'ai rangée.
Léa : Les herbes que j'ai coupées sentent bon.
Patrick : Les mots que j'ai écrits, Marc les a lus à Radio Figuier.
Aline : Quelle réussite ! Tu les as réussies, ces galettes.
Joël : Moi, j'ai préparé le thé. Je l'ai préparé trop fort.
Rose : Les figues que Sami a apportées, on les a partagées.
Marc : La lettre que j'ai envoyée à Solange est arrivée.
Noura : Bravo. Vous les avez bien faites.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa dit : je les ai faites.",
  "correct": true,
  "explanation": "COD les (galettes, fém. plur.) avant le verbe → faites."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi écrit-on « la tasse que tu as cassée » ?",
  "options": [
    {
      "text": "Parce que tasse est après le verbe",
      "correct": false
    },
    {
      "text": "Parce que le COD tasse (fém.) est avant (que)",
      "correct": true
    },
    {
      "text": "Parce que casser est un verbe en -ger",
      "correct": false
    },
    {
      "text": "Parce que Félicie est le sujet",
      "correct": false
    }
  ],
  "explanation": "COD placé avant → accord avec le COD."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je les ai faites",
      "right": "galettes / fém. plur."
    },
    {
      "left": "tasse que tu as cassée",
      "right": "fém. sing."
    },
    {
      "left": "herbes que j'ai coupées",
      "right": "fém. plur."
    },
    {
      "left": "j'ai préparé le thé",
      "right": "COD après → pas d'accord"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe les ai ___. (faire / galettes)",
  "answer": "faites"
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
    "les",
    "avez",
    "vues",
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
  "word": "galettes",
  "hint": "Hawa les a faites : des… de la cuisine."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je les ai fait, les galettes.",
  "correct_sentence": "Je les ai faites, les galettes.",
  "explanation": "Les = galettes, féminin pluriel → faites."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/accord-avoir.svg",
      "word": "un accord"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/assiette-reussie.svg",
      "word": "une assiette"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/tache-faite.svg",
      "word": "une tâche"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/sourire-hawa.svg",
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
  "prompt": "Notez trois accords (COD avant) et une phrase sans accord (COD après)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je les ai faites. La tasse que tu as cassée. Les herbes que j'ai coupées."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Mot de réussite',
    'CE',
    $c$Objectif
Lire un récit où l'accord avec avoir dépend de la place du COD.

Consigne
Lisez le mot, sans aller trop vite.

Support — Mot de Hawa, tableau de la cour
Amies, amis du Seuil,
Les galettes que j'ai préparées, Félicie les a goûtées.
La recette que Léa a copiée est dans le Cahier du chemin.
Les erreurs que j'ai commises, je les ai corrigées.
J'ai ouvert la fenêtre. (fenêtre après → ouvert, pas ouverte ici ? Attention : COD après = pas d'accord.)
La fenêtre, je l'ai ouverte ensuite.
Merci à celles que j'ai remerciées ce matin.
Hawa Diallo
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« J'ai ouvert la fenêtre » s'accorde.",
  "correct": false,
  "explanation": "COD après le verbe : pas d'accord. Puis : je l'ai ouverte."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase montre un accord au féminin pluriel ?",
  "options": [
    {
      "text": "J'ai ouvert la fenêtre",
      "correct": false
    },
    {
      "text": "Les galettes que j'ai préparées",
      "correct": true
    },
    {
      "text": "La recette que Léa a copiée",
      "correct": false
    },
    {
      "text": "Hawa Diallo",
      "correct": false
    }
  ],
  "explanation": "Galettes = fém. plur. avant le verbe."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "préparées",
      "right": "galettes"
    },
    {
      "left": "copiée",
      "right": "recette"
    },
    {
      "left": "corrigées",
      "right": "erreurs"
    },
    {
      "left": "ouverte",
      "right": "fenêtre / l'"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa fenêtre, je l'ai ___.",
  "answer": "ouverte"
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
    "les",
    "ai",
    "corrigées",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "preparees",
  "hint": "Les galettes que j'ai… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les galettes que j'ai préparé sont chaudes.",
  "correct_sentence": "Les galettes que j'ai préparées sont chaudes.",
  "explanation": "Que = galettes, fém. plur."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/pronoms-possessifs.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/miroir-soin.svg",
      "word": "un miroir"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/serviette-mienne.svg",
      "word": "une serviette"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/brosse-tienne.svg",
      "word": "une brosse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Soulignez chaque COD placé avant et l'accord du participe."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le mot de Hawa, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire je les ai faites',
    'PO',
    $c$Objectif
Accorder à l'oral le participe passé quand le COD est avant.

Consigne
Répétez, puis racontez une petite réussite.

Support — Modèles d'Aline
Je les ai faites.
Tu les as vues.
Il l'a cassée.
Nous les avons coupées.
Vous les avez lues.
Je l'ai ouverte.
J'ai préparé le thé.
Les lettres que j'ai écrites.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Si le COD est après, le participe avec avoir ne s'accorde pas.",
  "correct": true,
  "explanation": "J'ai préparé le thé."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase s'accorde ?",
  "options": [
    {
      "text": "J'ai préparé le thé",
      "correct": false
    },
    {
      "text": "J'ai ouvert la fenêtre",
      "correct": false
    },
    {
      "text": "Je l'ai ouverte",
      "correct": true
    },
    {
      "text": "J'ai écrit une lettre (lettre après)",
      "correct": false
    }
  ],
  "explanation": "L' = la fenêtre, avant le verbe."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "les (fém.)",
      "right": "faites / vues / coupées"
    },
    {
      "left": "l' (fém.)",
      "right": "cassée / ouverte"
    },
    {
      "left": "COD après",
      "right": "pas d'accord"
    },
    {
      "left": "que + nom fém.",
      "right": "accord"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes lettres que j'ai ___. (écrire)",
  "answer": "écrites"
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
    "l'ai",
    "ouverte",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ouvertes",
  "hint": "Des fenêtres : je les ai…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je l'ai ouvert, la fenêtre.",
  "correct_sentence": "Je l'ai ouverte, la fenêtre.",
  "explanation": "L' = fenêtre, féminin."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/marche-herbes.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/panier-jour.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/eau-soin.svg",
      "word": "de l'eau"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/plante-balcon.svg",
      "word": "une plante"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez cinq phrases : trois avec accord, deux sans."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis une réussite à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma réussite',
    'PE',
    $c$Objectif
Écrire un court récit avec des accords du participe passé.

Consigne
Imitez le récit de Rose.

Support — Récit de Rose Iradukunda
Rose Iradukunda
Les tisanes que j'ai préparées, Yvette les a bues.
La tasse que j'ai cassée, Félicie l'a remplacée.
Les doses que j'ai notées, Léa les a relues.
J'ai posé le plateau. Ensuite je l'ai posé trop vite ? Non : je l'ai posé, plateau = masc.
Les herbes, je les ai rincées.
Rose
Cuisine du Seuil
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose a cassé une tasse.",
  "correct": true,
  "explanation": "« La tasse que j'ai cassée. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi « posé » n'a pas de e ?",
  "options": [
    {
      "text": "Parce que Rose est le sujet",
      "correct": false
    },
    {
      "text": "Parce que plateau est masculin (l' = plateau)",
      "correct": true
    },
    {
      "text": "Parce que c'est un verbe en -cer",
      "correct": false
    },
    {
      "text": "Parce que Yvette boit",
      "correct": false
    }
  ],
  "explanation": "Accord avec le COD, pas avec le sujet."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "préparées",
      "right": "tisanes"
    },
    {
      "left": "cassée",
      "right": "tasse"
    },
    {
      "left": "notées",
      "right": "doses"
    },
    {
      "left": "rincées",
      "right": "herbes"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes herbes, je les ai ___.",
  "answer": "rincées"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Félicie",
    "l'a",
    "remplacée",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tisanes",
  "hint": "Yvette les a bues : des… d'herbes."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les tisanes que j'ai préparé, Yvette les a bu.",
  "correct_sentence": "Les tisanes que j'ai préparées, Yvette les a bues.",
  "explanation": "Tisanes : fém. plur. → préparées, bues."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/verbe-yer.svg",
      "word": "essuyer"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/tableau-conjug.svg",
      "word": "un tableau"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/recette-felicie.svg",
      "word": "une recette"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/bol-essayer.svg",
      "word": "un bol"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : cinq lignes, au moins trois accords visibles."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre récit, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Accord du PP avec avoir',
    'EL',
    $c$Objectif
Retenir : accord seulement si le COD est placé avant le verbe.

Consigne
Apprenez la fiche.

Support — Fiche de synthèse
Avec avoir : le participe s'accorde avec le COD si le COD est avant.
Je les ai faites. (les = galettes)
La tasse que j'ai cassée. (que = tasse)
Je l'ai ouverte. (l' = fenêtre)
Pas d'accord si le COD est après : J'ai fait les galettes. J'ai ouvert la fenêtre.
Pas d'accord avec le sujet : Hawa a réussi (pas réussie, même si Hawa est une femme).
Attention : les lettres que j'ai écrites ; les mots que j'ai lus ; les figues apportées.
Au Seuil : les galettes que j'ai faites ; la tasse que tu as cassée.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On accorde le participe avec le sujet quand l'auxiliaire est avoir.",
  "correct": false,
  "explanation": "Avec avoir : accord avec le COD avant, jamais avec le sujet."
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
      "text": "Hawa a réussie",
      "correct": false
    },
    {
      "text": "Hawa a réussi",
      "correct": true
    },
    {
      "text": "Hawa les a réussi, les galettes",
      "correct": false
    },
    {
      "text": "Hawa a faites les galettes",
      "correct": false
    }
  ],
  "explanation": "Sujet + avoir : pas d'accord. Les galettes : Hawa les a réussies."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "COD avant",
      "right": "accord"
    },
    {
      "left": "COD après",
      "right": "invariable"
    },
    {
      "left": "sujet féminin + avoir",
      "right": "pas d'accord"
    },
    {
      "left": "que = COD",
      "right": "regarder le nom avant que"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nHawa a ___. (réussir, pas de COD avant)",
  "answer": "réussi"
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
    "tasse",
    "que",
    "j'ai",
    "cassée",
    "."
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
  "hint": "Quand le COD est après, le participe reste…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Hawa a réussie les galettes.",
  "correct_sentence": "Hawa a réussi les galettes.",
  "explanation": "Avec avoir, pas d'accord avec le sujet si le COD est après."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/cuillere-reussir.svg",
      "word": "une cuillère"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/cahier-preposition.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/mode-emploi.svg",
      "word": "un mode d'emploi"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/si-imparfait.svg",
      "word": "une condition"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez : J'ai fait les galettes. → Je les… / J'ai cassé la tasse. → …"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et cinq transformations."
}$j$::jsonb,
    9
  );

  -- ===== Prendre soin de soi =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Prendre soin de soi'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Prendre soin de soi', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Serviettes à l''infirmerie',
    'CO',
    $c$Objectif
Repérer le mien, la tienne, les nôtres, les vôtres, le sien, les leurs.

Consigne
Lisez le dialogue. À qui appartient chaque objet ?

Support — Infirmerie des Herbes, bassine d'eau
Yvette : Prends la serviette. C'est la mienne, pas la tienne.
Hawa : La tienne est trop petite. La mienne sèche déjà.
Aline : Les brosses ? Les nôtres sont à gauche. Les vôtres sont à droite.
Patrick : Le peigne, c'est le sien, celui de Joël. Le mien est dans le sac.
Léa : Nos tasses ? Les nôtres. Les leurs sont celles de Mado et Sami.
Rose : Ton thé ou le mien ? Le tien est plus clair.
Marc : Vos gants ? Les vôtres. Les nôtres restent ici.
Félicie : Chacun range le sien. On ne mélange pas les nôtres et les leurs.
Benoît : J'ai pris le vôtre par erreur. Voici le mien.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Yvette dit que la serviette est la tienne.",
  "correct": false,
  "explanation": "« C'est la mienne, pas la tienne. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où sont les brosses du groupe d'Aline ?",
  "options": [
    {
      "text": "À droite",
      "correct": false
    },
    {
      "text": "À gauche",
      "correct": true
    },
    {
      "text": "Chez Ibrahim",
      "correct": false
    },
    {
      "text": "Sous le figuier",
      "correct": false
    }
  ],
  "explanation": "« Les nôtres sont à gauche. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "la mienne",
      "right": "serviette d'Yvette"
    },
    {
      "left": "les nôtres",
      "right": "brosses d'Aline"
    },
    {
      "left": "le sien",
      "right": "peigne de Joël"
    },
    {
      "left": "les leurs",
      "right": "tasses de Mado et Sami"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est la ___, pas la tienne.",
  "answer": "mienne"
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
    "nôtres",
    "sont",
    "à",
    "gauche",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "mienne",
  "hint": "La serviette d'Yvette : la…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le mienne, la serviette.",
  "correct_sentence": "C'est la mienne, la serviette.",
  "explanation": "Serviette est féminin : la mienne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/pronoms-possessifs.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/miroir-soin.svg",
      "word": "un miroir"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/serviette-mienne.svg",
      "word": "une serviette"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/brosse-tienne.svg",
      "word": "une brosse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez six possessifs entendus et leur propriétaire."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : C'est la mienne. La tienne est trop petite. Les nôtres sont à gauche. Les vôtres sont à droite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Affiche « chacun le sien »',
    'CE',
    $c$Objectif
Lire une affiche qui oppose mon / le mien, ton / le tien…

Consigne
Lisez l'affiche, sans aller trop vite.

Support — Affiche, Infirmerie des Herbes
Chacun range le sien
La serviette : la mienne / la tienne / la sienne
Les gants : les miens / les tiens / les siens
Le bol de soin : le nôtre (groupe du matin) / le vôtre (groupe du soir)
Les huiles : les nôtres restent. Les leurs partent avec Lila.
Ne prenez pas le mien pour le tien.
Questions : Yvette, Noura, Ibrahim.
Seuil des Sources
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Les huiles du groupe du matin restent.",
  "correct": true,
  "explanation": "« Les nôtres restent. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Le bol du groupe du soir, c'est…",
  "options": [
    {
      "text": "le nôtre",
      "correct": false
    },
    {
      "text": "le vôtre",
      "correct": true
    },
    {
      "text": "le mien",
      "correct": false
    },
    {
      "text": "les leurs",
      "correct": false
    }
  ],
  "explanation": "« le vôtre (groupe du soir) »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "la mienne",
      "right": "ma serviette"
    },
    {
      "left": "le tien",
      "right": "ton objet, masculin"
    },
    {
      "left": "le nôtre",
      "right": "notre bol, matin"
    },
    {
      "left": "les leurs",
      "right": "leurs huiles"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNe prenez pas le mien pour le ___.",
  "answer": "tien"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Chacun",
    "range",
    "le",
    "sien",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "serviette",
  "hint": "On range la sienne : un linge pour se sécher."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le bol de soin : la nôtre.",
  "correct_sentence": "Le bol de soin : le nôtre.",
  "explanation": "Bol est masculin : le nôtre."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/serviette-mienne.svg",
      "word": "une serviette"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/brosse-tienne.svg",
      "word": "une brosse"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/avant-de.svg",
      "word": "avant de"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/apres-inf.svg",
      "word": "après"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez l'affiche et ajoutez deux lignes : le mien / la tienne."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'affiche, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire le mien, la tienne',
    'PO',
    $c$Objectif
Remplacer mon sac, ta tasse… par un pronom possessif.

Consigne
Répétez, puis parlez d'objets de soin.

Support — Modèles de Léa
C'est le mien.
C'est la tienne.
Ce sont les nôtres.
Ce sont les vôtres.
C'est le sien.
Ce sont les leurs.
Le tien est plus clair.
La mienne sèche déjà.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Les nôtres » remplace « nos + nom pluriel ».",
  "correct": true,
  "explanation": "Nos brosses → les nôtres."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Ta serviette » devient…",
  "options": [
    {
      "text": "le tien",
      "correct": false
    },
    {
      "text": "la tienne",
      "correct": true
    },
    {
      "text": "les tiennes",
      "correct": false
    },
    {
      "text": "la vôtre",
      "correct": false
    }
  ],
  "explanation": "Serviette, féminin singulier : la tienne."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "mon / ma / mes",
      "right": "le mien / la mienne / les miens"
    },
    {
      "left": "ton / ta / tes",
      "right": "le tien / la tienne / les tiens"
    },
    {
      "left": "notre / nos",
      "right": "le nôtre / les nôtres"
    },
    {
      "left": "leur / leurs",
      "right": "le leur / les leurs"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTa serviette → la ___.",
  "answer": "tienne"
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
    "sien",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "votres",
  "hint": "Ce sont les… : à vous (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le tienne, ta tasse.",
  "correct_sentence": "C'est la tienne, ta tasse.",
  "explanation": "Tasse : féminin → la tienne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/fleche-suite.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/horloge-actions.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/marche-herbes.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/panier-jour.svg",
      "word": "un panier"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez huit groupes : mon thé, ta tasse, nos gants, vos huiles…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis quatre objets à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma liste de soin',
    'PE',
    $c$Objectif
Écrire une liste qui utilise les pronoms possessifs.

Consigne
Imitez la liste de Patrick.

Support — Liste de Patrick Habimana
Patrick Habimana
La serviette : la mienne. La tienne reste au crochet.
Les brosses : les nôtres. Les vôtres partent ce soir.
Le peigne de Joël : le sien. Le mien est dans le sac.
Les tasses de Mado et Sami : les leurs.
Ton thé est trop fort. Le mien est plus clair.
Patrick
Infirmerie des Herbes
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le peigne de Joël, c'est le mien.",
  "correct": false,
  "explanation": "« Le peigne de Joël : le sien. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel thé est plus clair ?",
  "options": [
    {
      "text": "Le tien",
      "correct": false
    },
    {
      "text": "Le mien (celui de Patrick)",
      "correct": true
    },
    {
      "text": "Le leur",
      "correct": false
    },
    {
      "text": "Le vôtre",
      "correct": false
    }
  ],
  "explanation": "« Le mien est plus clair. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "la mienne",
      "right": "serviette de Patrick"
    },
    {
      "left": "les nôtres",
      "right": "brosses du groupe"
    },
    {
      "left": "le sien",
      "right": "peigne de Joël"
    },
    {
      "left": "les leurs",
      "right": "tasses de Mado et Sami"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe peigne de Joël : le ___.",
  "answer": "sien"
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
    "tienne",
    "reste",
    "au",
    "crochet",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "crochet",
  "hint": "La tienne reste à cet objet du mur."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les tasses de Mado et Sami : les siens.",
  "correct_sentence": "Les tasses de Mado et Sami : les leurs.",
  "explanation": "À eux / à elles : les leurs."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/eau-soin.svg",
      "word": "de l'eau"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/plante-balcon.svg",
      "word": "une plante"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/tablier-cuisine.svg",
      "word": "un tablier"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/liste-courses.svg",
      "word": "une liste"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes, six possessifs différents."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre liste, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Pronoms possessifs',
    'EL',
    $c$Objectif
Retenir le mien, la tienne, les nôtres, les vôtres et l'accord.

Consigne
Apprenez la fiche.

Support — Fiche d'Yvette
Adjectif : mon / ton / son + nom. Pronom : le mien / le tien / le sien (sans le nom).
Féminin : la mienne, la tienne, la sienne, la nôtre, la vôtre, la leur
Pluriel : les miens / les miennes ; les nôtres ; les vôtres ; les leurs
nôtre / vôtre : accent circonflexe au pronom. Notre / votre (adjectifs) : pas d'accent.
Le mien = mon objet (masc.). La mienne = mon objet (fém.).
On ne dit pas : c'est mien. On dit : c'est le mien.
À l'infirmerie : la serviette, c'est la mienne ; les brosses, ce sont les nôtres.
Leur / leurs (adjectif) → le leur / les leurs (pronom).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « les notres » sans accent.",
  "correct": false,
  "explanation": "Pronom : les nôtres, avec accent."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est un pronom ?",
  "options": [
    {
      "text": "notre bol",
      "correct": false
    },
    {
      "text": "le nôtre",
      "correct": true
    },
    {
      "text": "nos gants",
      "correct": false
    },
    {
      "text": "votre thé",
      "correct": false
    }
  ],
  "explanation": "Le nôtre remplace le nom."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "mon bol",
      "right": "le mien"
    },
    {
      "left": "ta tasse",
      "right": "la tienne"
    },
    {
      "left": "nos brosses",
      "right": "les nôtres"
    },
    {
      "left": "leurs huiles",
      "right": "les leurs"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNotre bol → le ___.",
  "answer": "nôtre"
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
    "sienne",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "circonflexe",
  "hint": "L'accent de nôtre et de vôtre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est mien, ce peigne.",
  "correct_sentence": "C'est le mien, ce peigne.",
  "explanation": "Toujours article : le / la / les + pronom."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/quelqu-un.svg",
      "word": "quelqu'un"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/boite-notice.svg",
      "word": "une boîte"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/accord-avoir.svg",
      "word": "un accord"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/assiette-reussie.svg",
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
  "prompt": "Tableau complet : adjectif → pronom, six personnes, deux genres."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et huit pronoms."
}$j$::jsonb,
    9
  );

  -- ===== Une suite d'actions =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une suite d''actions'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une suite d''actions', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — L''ordre du matin',
    'CO',
    $c$Objectif
Repérer avant de / après + infinitif et les marqueurs d'abord, ensuite, puis, enfin.

Consigne
Lisez le dialogue. Dans quel ordre fait-on les gestes ?

Support — Cuisine, horloge de la Table des Sources
Félicie : Avant de couper, lavez-vous les mains.
Aline : Après ranger les bols, on essuie la table.
Léa : D'abord l'eau. Ensuite le feu. Puis le sel. Enfin le goût.
Patrick : Avant de goûter, on attend une minute.
Hawa : Après avoir servi, on s'assoit sous le figuier.
Joël : On ne parle pas avant de couvrir le pot.
Rose : Après balayer, nous ouvrons la fenêtre.
Marc : D'abord le marché. Ensuite la cuisine. Puis le repos.
Kévin : Avant de partir, signez le cahier. Après signer, on range le crayon.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On se lave les mains après avoir coupé.",
  "correct": false,
  "explanation": "Félicie : « Avant de couper, lavez-vous les mains. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel est l'ordre de Léa ?",
  "options": [
    {
      "text": "sel, feu, eau, goût",
      "correct": false
    },
    {
      "text": "eau, feu, sel, goût",
      "correct": true
    },
    {
      "text": "goût, eau, feu, sel",
      "correct": false
    },
    {
      "text": "feu, goût, sel, eau",
      "correct": false
    }
  ],
  "explanation": "D'abord l'eau. Ensuite le feu. Puis le sel. Enfin le goût."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avant de couper",
      "right": "laver les mains"
    },
    {
      "left": "après ranger",
      "right": "essuyer"
    },
    {
      "left": "d'abord / ensuite / puis / enfin",
      "right": "ordre"
    },
    {
      "left": "avant de partir",
      "right": "signer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ de couper, lavez-vous les mains.",
  "answer": "Avant"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Après",
    "ranger",
    "les",
    "bols",
    "on",
    "essuie",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "dabord",
  "hint": "Le premier marqueur de la liste de Léa (sans apostrophe)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avant couper, lavez-vous les mains.",
  "correct_sentence": "Avant de couper, lavez-vous les mains.",
  "explanation": "Avant de + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/avant-de.svg",
      "word": "avant de"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/apres-inf.svg",
      "word": "après"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/fleche-suite.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/horloge-actions.svg",
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
  "prompt": "Notez trois avant de, deux après, et la série d'abord… enfin."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Avant de couper, lavez-vous les mains. Après ranger, on essuie. D'abord l'eau, ensuite le feu."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Suite affichée',
    'CE',
    $c$Objectif
Lire une suite d'actions avec avant de, après, d'abord, ensuite.

Consigne
Lisez la suite, sans aller trop vite.

Support — Affiche du tableau de la cour
Suite du jour — cuisine et cour
1. Avant d'ouvrir le marché, compter les paniers.
2. Après revenir, poser l'eau à la Table des Sources.
3. D'abord laver. Ensuite ciseler. Puis tourner. Enfin goûter.
4. Avant de servir, prévenir Yvette à l'infirmerie.
5. Après avoir rangé, balayer la Salle des Herbes.
6. Avant de signer le cahier, relire. Après signer, accrocher le crayon.
Félicie et Aline
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On prévient Yvette après avoir servi.",
  "correct": false,
  "explanation": "« Avant de servir, prévenir Yvette. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait-on après être revenu ?",
  "options": [
    {
      "text": "Compter les paniers",
      "correct": false
    },
    {
      "text": "Poser l'eau à la Table des Sources",
      "correct": true
    },
    {
      "text": "Signer tout de suite",
      "correct": false
    },
    {
      "text": "Partir à Port de la Brise",
      "correct": false
    }
  ],
  "explanation": "Point 2."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avant d'ouvrir",
      "right": "compter"
    },
    {
      "left": "après revenir",
      "right": "poser l'eau"
    },
    {
      "left": "avant de servir",
      "right": "Yvette"
    },
    {
      "left": "après avoir rangé",
      "right": "balayer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAvant ___ servir, prévenir Yvette.",
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
    "D'abord",
    "laver",
    ".",
    "Ensuite",
    "ciseler",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ciseler",
  "hint": "La deuxième action après laver, dans le point 3."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Après de ranger, balayer la salle.",
  "correct_sentence": "Après avoir rangé, balayer la salle.",
  "explanation": "Après + infinitif (souvent avoir + PP) ; pas après de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/verbe-cer.svg",
      "word": "commencer"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/verbe-ger.svg",
      "word": "manger"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/verbe-yer.svg",
      "word": "essuyer"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/tableau-conjug.svg",
      "word": "un tableau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la suite et numérotez les actions de 1 à 8."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six points, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire avant de, après',
    'PO',
    $c$Objectif
Enchaîner des actions avec avant de, après, d'abord, ensuite, puis, enfin.

Consigne
Répétez, puis racontez votre matin.

Support — Modèles de Joël
Avant de couper, je lave.
Après ranger, j'essuie.
D'abord l'eau.
Ensuite le feu.
Puis le sel.
Enfin je goûte.
Avant de partir, je signe.
Après signer, je range.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Enfin » marque la dernière étape.",
  "correct": true,
  "explanation": "D'abord… ensuite… puis… enfin."
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
      "text": "avant couper",
      "correct": false
    },
    {
      "text": "avant de couper",
      "correct": true
    },
    {
      "text": "avant à couper",
      "correct": false
    },
    {
      "text": "après de couper",
      "correct": false
    }
  ],
  "explanation": "Avant de + infinitif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avant de",
      "right": "action pas encore faite"
    },
    {
      "left": "après + infinitif",
      "right": "action déjà faite"
    },
    {
      "left": "d'abord",
      "right": "première"
    },
    {
      "left": "enfin",
      "right": "dernière"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ ranger, j'essuie.",
  "answer": "Après"
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
    "de",
    "partir",
    "je",
    "signe",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ensuite",
  "hint": "Le marqueur après d'abord, avant puis."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avant à partir, je signe.",
  "correct_sentence": "Avant de partir, je signe.",
  "explanation": "Avant de, pas avant à."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/mode-emploi.svg",
      "word": "un mode d'emploi"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/si-imparfait.svg",
      "word": "une hypothèse"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/quelqu-un.svg",
      "word": "quelqu'un"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/boite-notice.svg",
      "word": "une boîte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez une suite de six gestes avec six marqueurs différents."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre matin."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma suite du jour',
    'PE',
    $c$Objectif
Écrire une suite d'actions avec avant de / après et des marqueurs.

Consigne
Imitez la suite de Marc.

Support — Suite de Marc Nkurunziza
Marc Nkurunziza
Avant de quitter la Maison des Vents, je bois de l'eau.
D'abord le banc. Ensuite le figuier. Puis la cuisine.
Après saluer Félicie, je lis le tableau.
Avant de goûter, j'attends.
Après avoir noté, j'accroche le crayon.
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
  "statement": "Marc boit de l'eau après avoir quitté la maison.",
  "correct": false,
  "explanation": "« Avant de quitter… je bois de l'eau. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait Marc après avoir salué Félicie ?",
  "options": [
    {
      "text": "Il part à Rive d'Orage",
      "correct": false
    },
    {
      "text": "Il lit le tableau",
      "correct": true
    },
    {
      "text": "Il paie Ibrahim",
      "correct": false
    },
    {
      "text": "Il ferme Radio Figuier",
      "correct": false
    }
  ],
  "explanation": "« Après saluer Félicie, je lis le tableau. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avant de quitter",
      "right": "boire"
    },
    {
      "left": "d'abord",
      "right": "le banc"
    },
    {
      "left": "après saluer",
      "right": "lire le tableau"
    },
    {
      "left": "après avoir noté",
      "right": "accrocher"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAvant ___ goûter, j'attends.",
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
    "Après",
    "saluer",
    "Félicie",
    "je",
    "lis",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "accroche",
  "hint": "Après avoir noté, il… le crayon."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avant quitter la maison, je bois.",
  "correct_sentence": "Avant de quitter la Maison des Vents, je bois de l'eau.",
  "explanation": "Avant de + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/tache-faite.svg",
      "word": "une tâche"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/sourire-hawa.svg",
      "word": "un sourire"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/pronoms-possessifs.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/miroir-soin.svg",
      "word": "un miroir"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes, avant de, après, d'abord, ensuite."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre suite, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Avant de, après, marqueurs',
    'EL',
    $c$Objectif
Retenir avant de + infinitif, après + infinitif, d'abord / ensuite / puis / enfin.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
Avant de + infinitif : Avant de couper, lavez. (l'action n'est pas encore faite)
Après + infinitif : Après ranger… / Après avoir rangé… (l'action est faite)
Pas : avant couper. Pas : après de ranger.
Marqueurs : d'abord, ensuite, puis, enfin. Aussi : puis, après cela, pour finir.
Avant d' + voyelle : avant d'ouvrir, avant d'essayer.
Même sujet pour avant de / après + infinitif. Si le sujet change : avant que (plus tard).
Suite type : d'abord l'eau, ensuite le feu, puis le sel, enfin le goût.
Après avoir signé, on accroche le crayon au tableau de la cour.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « avant d'ouvrir » avec d'.",
  "correct": true,
  "explanation": "Élision : de + o → d'."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série est dans le bon ordre habituel ?",
  "options": [
    {
      "text": "enfin / d'abord / puis",
      "correct": false
    },
    {
      "text": "d'abord / ensuite / puis / enfin",
      "correct": true
    },
    {
      "text": "puis / d'abord / enfin",
      "correct": false
    },
    {
      "text": "ensuite / enfin / d'abord",
      "correct": false
    }
  ],
  "explanation": "D'abord… ensuite… puis… enfin."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avant de",
      "right": "pas encore"
    },
    {
      "left": "après",
      "right": "déjà fait"
    },
    {
      "left": "d'abord",
      "right": "1"
    },
    {
      "left": "enfin",
      "right": "dernier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAvant ___ ouvrir, compter les paniers.",
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
    "Après",
    "avoir",
    "rangé",
    "on",
    "balaye",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "marqueurs",
  "hint": "D'abord, ensuite, puis, enfin : des… de temps."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avant ouvrir le marché, compter les paniers.",
  "correct_sentence": "Avant d'ouvrir le marché, compter les paniers.",
  "explanation": "Avant de / d' + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m6/recette-felicie.svg",
      "word": "une recette"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/bol-essayer.svg",
      "word": "un bol"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/cuillere-reussir.svg",
      "word": "une cuillère"
    },
    {
      "image_path": "/elearning/mfk-a2-m6/cahier-preposition.svg",
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
  "prompt": "Écrivez huit phrases : quatre avant de, quatre après."
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

END;
$$;
