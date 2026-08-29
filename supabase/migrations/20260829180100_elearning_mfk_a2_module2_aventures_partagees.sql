/*
  Seed eLearning MFK — A2 — Aventures partagées

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a2-m2/
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
  v_module_title text := 'A2 — Aventures partagées';
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
      'Grande étape A2-2 : raconter une expérience, poser des règles, partager des émotions, mettre en relief un week-end, nommer l''aventure et dater un parcours — après les préparatifs, sous le figuier du Seuil des Sources (Rukiri-Nord), vers Mwezi-Haut et la Maison des Vents.',
      'A2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape A2-2 : raconter une expérience, poser des règles, partager des émotions, mettre en relief un week-end, nommer l''aventure et dater un parcours — après les préparatifs, sous le figuier du Seuil des Sources (Rukiri-Nord), vers Mwezi-Haut et la Maison des Vents.',
      cefr_level = 'A2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Une expérience à raconter =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une expérience à raconter'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une expérience à raconter', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Retours sous le figuier',
    'CO',
    $c$Objectif
Repérer l'accord du participe passé avec être : allé(e), parti(e), resté(e).

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui est allé où ?

Support — Banc du Seuil, soirée ocre
Léa : Hier, je suis allée jusqu'au premier virage de Mwezi-Haut.
Patrick : Moi, je suis parti avant l'aube, avec le minibus Figuier 7.
Rose : Hawa et moi, nous sommes parties ensemble, vers le lac des Nénuphars.
Hawa : C'est vrai. Nous sommes restées une heure au bord de l'eau.
Marc : Je suis resté sous le figuier : j'avais le Cahier du chemin.
Solange : Je suis née près de Rive d'Orage, mais je suis devenue guide ici.
Joël : Léa est revenue tard. Kévin est tombé sur une racine, sans gravité.
Aline : Notez : elle est allée, elles sont parties, il est tombé.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose et Hawa sont parties ensemble vers le lac.",
  "correct": true,
  "explanation": "Rose : « nous sommes parties ensemble, vers le lac ». "
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui est resté sous le figuier ?",
  "options": [
    {
      "text": "Patrick",
      "correct": false
    },
    {
      "text": "Marc",
      "correct": true
    },
    {
      "text": "Joël",
      "correct": false
    },
    {
      "text": "Kévin",
      "correct": false
    }
  ],
  "explanation": "Marc : « Je suis resté sous le figuier. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je suis allée",
      "right": "Léa"
    },
    {
      "left": "je suis parti",
      "right": "Patrick"
    },
    {
      "left": "nous sommes parties",
      "right": "Rose et Hawa"
    },
    {
      "left": "il est tombé",
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
  "prompt": "Complétez :\nLéa est ___ tard. (revenir, fém.)",
  "answer": "revenue"
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
    "sommes",
    "parties",
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
  "word": "allée",
  "hint": "Léa est… jusqu'au virage : participe féminin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Rose et Hawa sont partis ensemble vers le lac.",
  "correct_sentence": "Rose et Hawa sont parties ensemble vers le lac.",
  "explanation": "Deux femmes : parties, avec e et s."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/recit-lea.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/valise-ouverte.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/photo-souvenir.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/accord-etre.svg",
      "word": "un accord"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez quatre participes entendus et leur sujet (il / elle / elles)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je suis allée. Nous sommes parties. Il est tombé. Je suis resté."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Cartes du Cahier du chemin',
    'CE',
    $c$Objectif
Lire des récits courts et vérifier l'accord avec être.

Consigne
Lisez les cartes épinglées au figuier, sans aller trop vite.

Support — Cahier du chemin, page mauve
Carte Léa — Je suis allée à Mwezi-Haut. Je suis revenue avant la nuit.
Carte Patrick — Je suis parti tôt. Je ne suis pas resté au camp.
Carte Rose et Hawa — Nous sommes nées ici, près du Seuil. Nous sommes devenues amies sur le sentier.
Carte Kévin — Je suis tombé, puis je suis resté assis près d'un arbre.
Carte Solange — J'étais partie à Rive d'Orage ; je suis devenue guide à la Maison des Vents.
Règle : avec être, le participe s'accorde avec le sujet.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick est resté au camp.",
  "correct": false,
  "explanation": "Carte Patrick : « Je ne suis pas resté au camp. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui écrit « nous sommes devenues amies » ?",
  "options": [
    {
      "text": "Léa",
      "correct": false
    },
    {
      "text": "Patrick",
      "correct": false
    },
    {
      "text": "Rose et Hawa",
      "correct": true
    },
    {
      "text": "Kévin",
      "correct": false
    }
  ],
  "explanation": "Carte Rose et Hawa."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "allée / revenue",
      "right": "Léa"
    },
    {
      "left": "parti",
      "right": "Patrick"
    },
    {
      "left": "nées / devenues",
      "right": "Rose et Hawa"
    },
    {
      "left": "tombé",
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
  "prompt": "Complétez :\nNous sommes ___ amies sur le sentier.",
  "answer": "devenues"
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
    "tombé",
    "puis",
    "je",
    "suis",
    "resté",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "nées",
  "hint": "Rose et Hawa : nous sommes… ici, près du Seuil."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous sommes devenu amies sur le sentier.",
  "correct_sentence": "Nous sommes devenues amies sur le sentier.",
  "explanation": "Sujet féminin pluriel : devenues."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/valise-ouverte.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/photo-souvenir.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/accord-etre.svg",
      "word": "un accord"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/affiche-regle.svg",
      "word": "une affiche"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez deux cartes et soulignez chaque accord."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les cinq cartes à voix haute, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire je suis allé(e)',
    'PO',
    $c$Objectif
Accorder le participe à l'oral selon le sujet.

Consigne
Répétez les modèles, puis racontez une sortie du Seuil.

Support — Modèles d'Aline
Je suis allé au lac. / Je suis allée au lac.
Tu es parti tôt. / Tu es partie tôt.
Il est resté. / Elle est restée.
Nous sommes revenus. / Nous sommes revenues.
Elles sont parties.
Il est tombé. / Elle est tombée.
Je suis né ici. / Je suis née ici.
Il est devenu guide. / Elle est devenue guide.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Après être, le participe s'accorde avec le sujet.",
  "correct": true,
  "explanation": "Elle est restée, elles sont parties."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme va avec « Léa et Rose » ?",
  "options": [
    {
      "text": "sont parti",
      "correct": false
    },
    {
      "text": "sont partie",
      "correct": false
    },
    {
      "text": "sont parties",
      "correct": true
    },
    {
      "text": "est parties",
      "correct": false
    }
  ],
  "explanation": "Elles sont parties."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "allé / allée",
      "right": "masculin / féminin"
    },
    {
      "left": "parti / partie",
      "right": "un / une personne"
    },
    {
      "left": "resté / restée",
      "right": "accord du sujet"
    },
    {
      "left": "elles sont parties",
      "right": "féminin pluriel"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nElle est ___ sous le figuier. (rester)",
  "answer": "restée"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Elles",
    "sont",
    "parties",
    "vers",
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
  "word": "tombée",
  "hint": "Hawa est… : elle a perdu l'équilibre, féminin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Léa est allé jusqu'au virage.",
  "correct_sentence": "Léa est allée jusqu'au virage.",
  "explanation": "Léa : féminin, allée."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/photo-souvenir.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/accord-etre.svg",
      "word": "un accord"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/affiche-regle.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/panneau-interdit.svg",
      "word": "un panneau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases : trois masculines, trois féminines, avec être."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis deux phrases à vous (un homme, une femme)."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon récit d''étape',
    'PE',
    $c$Objectif
Écrire un court récit avec des participes accordés.

Consigne
Imitez le récit de Rose.

Support — Récit de Rose Iradukunda
Rose Iradukunda
Je suis partie à l'aube vers le lac des Nénuphars.
Hawa est restée près de moi : nous sommes allées sans courir.
Solange est devenue notre guide pour une heure.
Kévin est tombé, puis il est revenu vers le groupe.
Je suis née ici, et je suis revenue plus calme.
Rose
Seuil des Sources — après Mwezi-Haut
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose dit qu'elle est née ailleurs.",
  "correct": false,
  "explanation": "« Je suis née ici. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui est devenue guide pour une heure ?",
  "options": [
    {
      "text": "Hawa",
      "correct": false
    },
    {
      "text": "Rose",
      "correct": false
    },
    {
      "text": "Solange",
      "correct": true
    },
    {
      "text": "Léa",
      "correct": false
    }
  ],
  "explanation": "« Solange est devenue notre guide. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je suis partie",
      "right": "Rose"
    },
    {
      "left": "nous sommes allées",
      "right": "Rose et Hawa"
    },
    {
      "left": "est devenue",
      "right": "Solange"
    },
    {
      "left": "est tombé",
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
  "prompt": "Complétez :\nJe suis ___ ici. (naître, fém.)",
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
    "Nous",
    "sommes",
    "allées",
    "sans",
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
  "word": "revenue",
  "hint": "Rose est… plus calme : elle est rentrée."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Hawa est resté près de moi.",
  "correct_sentence": "Hawa est restée près de moi.",
  "explanation": "Hawa : féminin, restée."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/accord-etre.svg",
      "word": "un accord"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/affiche-regle.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/panneau-interdit.svg",
      "word": "un panneau"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/conseil-aline.svg",
      "word": "un conseil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes, quatre verbes différents avec être."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre récit, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Accord avec être',
    'EL',
    $c$Objectif
Retenir l'accord du participe passé conjugué avec être.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
Avec être, le participe s'accorde avec le sujet.
allé / allée / allés / allées
parti / partie / partis / parties
resté / restée / restés / restées
né / née / nés / nées
devenu / devenue / devenus / devenues
revenu / revenue / revenus / revenues
tombé / tombée / tombés / tombées
Elles sont parties. (pas : elles sont parti)
Attention : je suis allé (homme) / je suis allée (femme).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « elles sont parti » sans e ni s.",
  "correct": false,
  "explanation": "Elles sont parties."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est correcte pour Rose ?",
  "options": [
    {
      "text": "est allé",
      "correct": false
    },
    {
      "text": "est allée",
      "correct": true
    },
    {
      "text": "sont allé",
      "correct": false
    },
    {
      "text": "est allés",
      "correct": false
    }
  ],
  "explanation": "Rose : elle est allée."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "être + PP",
      "right": "accord avec le sujet"
    },
    {
      "left": "elles sont parties",
      "right": "fém. pluriel"
    },
    {
      "left": "il est devenu",
      "right": "masc. singulier"
    },
    {
      "left": "je suis née",
      "right": "femme qui parle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nElles sont ___ vers le lac. (partir)",
  "answer": "parties"
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
    "allée",
    "à",
    "Mwezi-Haut",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "devenue",
  "hint": "Solange est… guide : elle a changé de rôle."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Elles sont parti trop tôt.",
  "correct_sentence": "Elles sont parties trop tôt.",
  "explanation": "Féminin pluriel : parties."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/affiche-regle.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/panneau-interdit.svg",
      "word": "un panneau"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/conseil-aline.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/carnet-subjonctif.svg",
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
  "prompt": "Conjuguez sept verbes avec être au féminin et au masculin."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre exemples à vous."
}$j$::jsonb,
    9
  );

  -- ===== Règles et conseils =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Règles et conseils'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Règles et conseils', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Avant la montée',
    'CO',
    $c$Objectif
Comprendre il faut que + subjonctif et les interdictions.

Consigne
Lisez le dialogue. Quelles règles Aline et Karim donnent-ils ?

Support — Seuil de la Maison des Vents
Aline : Il faut que vous partiez avant huit heures.
Karim : Il est important que tu sois prudent sur les pierres.
Patrick : Je veux que Léa revienne avant la nuit.
Léa : Il faut que nous fassions une pause à l'ombre.
Hawa : Il est interdit de courir près du ravin.
Joël : Défense de laisser un sac sur le sentier.
Rose : Il faut qu'il prenne de l'eau, Kévin.
Marc : Je veux que vous restiez ensemble.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On a le droit de courir près du ravin.",
  "correct": false,
  "explanation": "Hawa : « Il est interdit de courir près du ravin. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que veut Patrick ?",
  "options": [
    {
      "text": "Que Léa reste au camp",
      "correct": false
    },
    {
      "text": "Que Léa revienne avant la nuit",
      "correct": true
    },
    {
      "text": "Que Karim parte seul",
      "correct": false
    },
    {
      "text": "Que Joël coure",
      "correct": false
    }
  ],
  "explanation": "« Je veux que Léa revienne avant la nuit. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il faut que vous partiez",
      "right": "obligation"
    },
    {
      "left": "il est important que tu sois",
      "right": "conseil + subj."
    },
    {
      "left": "il est interdit de",
      "right": "interdiction"
    },
    {
      "left": "défense de",
      "right": "interdiction courte"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut que nous ___ une pause. (faire)",
  "answer": "fassions"
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
    "que",
    "tu",
    "sois",
    "prudent",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "fassions",
  "hint": "Il faut que nous… une pause : subjonctif de faire."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut que vous partez avant huit heures.",
  "correct_sentence": "Il faut que vous partiez avant huit heures.",
  "explanation": "Après il faut que : subjonctif, partiez."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/panneau-interdit.svg",
      "word": "un panneau"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/conseil-aline.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/carnet-subjonctif.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/cahier-emotions.svg",
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
  "prompt": "Notez deux obligations avec que et deux interdictions avec de."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il faut que tu sois prudent. Il est interdit de courir. Défense de laisser un sac."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Affiche de la Maison des Vents',
    'CE',
    $c$Objectif
Lire des règles : subjonctif introductif et interdictions.

Consigne
Lisez l'affiche, sans aller trop vite.

Support — Panneau ocre, cour intérieure
Maison des Vents — consignes de sortie
1. Il faut que chacun parte avec une gourde.
2. Il est important que vous soyez à l'heure au banc.
3. Je veux que le groupe fasse silence près des nids.
4. Il est interdit de cueillir les herbes de Solange.
5. Défense de fumer sous le figuier.
6. Il faut qu'Aline sache qui reste à l'infirmerie.
Karim Bamba — relais du Seuil
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut cueillir les herbes de Solange.",
  "correct": false,
  "explanation": "« Il est interdit de cueillir les herbes de Solange. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui doit savoir qui reste à l'infirmerie ?",
  "options": [
    {
      "text": "Karim",
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
      "text": "Lila",
      "correct": false
    }
  ],
  "explanation": "« Il faut qu'Aline sache qui reste. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il faut que chacun parte",
      "right": "gourde"
    },
    {
      "left": "que vous soyez",
      "right": "à l'heure"
    },
    {
      "left": "interdit de cueillir",
      "right": "herbes"
    },
    {
      "left": "défense de fumer",
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
  "prompt": "Complétez :\nIl est important que vous ___ à l'heure. (être)",
  "answer": "soyez"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Défense",
    "de",
    "fumer",
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
  "word": "soyez",
  "hint": "Il est important que vous… à l'heure : subjonctif d'être."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut que Aline sait qui reste.",
  "correct_sentence": "Il faut qu'Aline sache qui reste.",
  "explanation": "Savoir au subjonctif : sache. Élision : qu'Aline."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/conseil-aline.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/carnet-subjonctif.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/cahier-emotions.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/pluie-imparfait.svg",
      "word": "la pluie"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez l'affiche et encadrez que + verbe au subjonctif."
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
    'PO — Il faut que, défense de',
    'PO',
    $c$Objectif
Donner un conseil avec le subjonctif et une interdiction avec de.

Consigne
Répétez, puis donnez des règles pour une sortie.

Support — Modèles d'Aline
Il faut que tu partes tôt.
Il faut qu'il soit prudent.
Il faut que nous fassions une pause.
Il est important que vous restiez ensemble.
Je veux que Léa revienne.
Il est interdit de courir.
Défense de laisser un sac.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Après « il faut que », on emploie le subjonctif.",
  "correct": true,
  "explanation": "Il faut que tu partes, que tu sois, que nous fassions."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est une interdiction ?",
  "options": [
    {
      "text": "Il faut que tu partes",
      "correct": false
    },
    {
      "text": "Je veux que Léa revienne",
      "correct": false
    },
    {
      "text": "Il est interdit de courir",
      "correct": true
    },
    {
      "text": "Il est important que vous restiez",
      "correct": false
    }
  ],
  "explanation": "Interdit de + infinitif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il faut que + subj.",
      "right": "obligation personnelle"
    },
    {
      "left": "il est interdit de + inf.",
      "right": "interdiction"
    },
    {
      "left": "défense de + inf.",
      "right": "panneau court"
    },
    {
      "left": "je veux que",
      "right": "souhait + subj."
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut qu'il ___ prudent. (être)",
  "answer": "soit"
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
    "interdit",
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
  "word": "partiez",
  "hint": "Il faut que vous… tôt : subjonctif de partir, vous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut que nous faisons une pause.",
  "correct_sentence": "Il faut que nous fassions une pause.",
  "explanation": "Faire au subjonctif : fassions."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/carnet-subjonctif.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/cahier-emotions.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/pluie-imparfait.svg",
      "word": "la pluie"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/rire-pc.svg",
      "word": "un rire"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez quatre il faut que et deux défense de / interdit de."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les sept modèles, puis deux règles à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon mot de consignes',
    'PE',
    $c$Objectif
Écrire des consignes avec subjonctif et interdiction.

Consigne
Imitez le mot d'Aline.

Support — Mot d'Aline Uwase
Aline Uwase
Il faut que vous partiez ensemble.
Il est important que tu sois à l'heure au banc.
Je veux que Kévin prenne sa gourde.
Il est interdit de courir près du ravin.
Défense de laisser un sac sur le sentier.
Il faut que nous fassions silence près des nids.
Aline
Maison des Vents
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline veut que Kévin oublie sa gourde.",
  "correct": false,
  "explanation": "« Je veux que Kévin prenne sa gourde. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase utilise le subjonctif de faire ?",
  "options": [
    {
      "text": "Il faut que vous partiez ensemble",
      "correct": false
    },
    {
      "text": "Il faut que nous fassions silence",
      "correct": true
    },
    {
      "text": "Défense de laisser un sac",
      "correct": false
    },
    {
      "text": "Aline",
      "correct": false
    }
  ],
  "explanation": "Fassions = subjonctif de faire."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "que vous partiez",
      "right": "ensemble"
    },
    {
      "left": "que tu sois",
      "right": "à l'heure"
    },
    {
      "left": "interdit de courir",
      "right": "ravin"
    },
    {
      "left": "défense de laisser",
      "right": "sac"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe veux que Kévin ___ sa gourde. (prendre)",
  "answer": "prenne"
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
    "que",
    "nous",
    "fassions",
    "silence",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "prenne",
  "hint": "Je veux que Kévin… sa gourde : subjonctif de prendre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est interdit que courir près du ravin.",
  "correct_sentence": "Il est interdit de courir près du ravin.",
  "explanation": "Interdit de + infinitif (pas que)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/cahier-emotions.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/pluie-imparfait.svg",
      "word": "la pluie"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/rire-pc.svg",
      "word": "un rire"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/banc-souvenir.svg",
      "word": "un banc"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes, trois que + subj. et deux interdictions."
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
    'EL — Subjonctif et interdiction',
    'EL',
    $c$Objectif
Retenir il faut que / je veux que + subj. et interdit de / défense de.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
Après il faut que, il est important que, je veux que → subjonctif.
être : que je sois, que tu sois, qu'il soit, que nous soyons, que vous soyez
faire : que je fasse, que nous fassions
partir : que je parte, que vous partiez
prendre : que je prenne
savoir : qu'elle sache
Interdiction : il est interdit de + infinitif / défense de + infinitif
On ne dit pas : il faut que tu pars. On dit : il faut que tu partes.
Toujours : il faut (pas je faut).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je faut que tu partes ».",
  "correct": false,
  "explanation": "Toujours il faut."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Faire » au subjonctif, nous :",
  "options": [
    {
      "text": "faisons",
      "correct": false
    },
    {
      "text": "fassions",
      "correct": true
    },
    {
      "text": "ferons",
      "correct": false
    },
    {
      "text": "faisions",
      "correct": false
    }
  ],
  "explanation": "Que nous fassions."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il faut que",
      "right": "subjonctif"
    },
    {
      "left": "il est interdit de",
      "right": "infinitif"
    },
    {
      "left": "que tu sois",
      "right": "être"
    },
    {
      "left": "que nous fassions",
      "right": "faire"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut que tu ___ tôt. (partir)",
  "answer": "partes"
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
    "qu'il",
    "soit",
    "prudent",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "sois",
  "hint": "Il faut que tu… prudent : subjonctif d'être, tu."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je faut que vous restiez ensemble.",
  "correct_sentence": "Il faut que vous restiez ensemble.",
  "explanation": "Toujours il faut, 3e personne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/pluie-imparfait.svg",
      "word": "la pluie"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/rire-pc.svg",
      "word": "un rire"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/banc-souvenir.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/week-end-theme.svg",
      "word": "un week-end"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Complétez un tableau : six verbes au subjonctif (tu / nous / il)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et cinq exemples."
}$j$::jsonb,
    9
  );

  -- ===== Émotions et souvenirs =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Émotions et souvenirs'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Émotions et souvenirs', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Sous la pluie, puis le rire',
    'CO',
    $c$Objectif
Distinguer l'arrière-plan (imparfait) et l'événement (passé composé).

Consigne
Lisez le dialogue. Qu'est-ce qui durait ? Qu'est-ce qui est arrivé ?

Support — Figuier, après l'averse
Léa : Il pleuvait fort. Soudain, Patrick a glissé, puis il a ri.
Hawa : Nous marchions vers le lac quand le soleil est revenu.
Marc : J'étais fatigué, alors je me suis assis sur le banc.
Rose : Kévin avait peur, mais il a continué.
Joël : Mado racontait une histoire. Tout le monde a écouté.
Aline : L'imparfait peint le décor. Le passé composé dit le fait.
Karim : Il faisait froid. Nous avons allumé le feu de camp.
Solange : Je me sentais légère. J'ai pris une photo.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il pleuvait » décrit un décor, pas un coup d'action unique.",
  "correct": true,
  "explanation": "Imparfait = arrière-plan."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel verbe raconte l'événement soudain ?",
  "options": [
    {
      "text": "pleuvait",
      "correct": false
    },
    {
      "text": "marchions",
      "correct": false
    },
    {
      "text": "a glissé",
      "correct": true
    },
    {
      "text": "faisait",
      "correct": false
    }
  ],
  "explanation": "Patrick a glissé : passé composé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il pleuvait",
      "right": "imparfait / décor"
    },
    {
      "left": "il a glissé",
      "right": "passé composé / fait"
    },
    {
      "left": "nous marchions",
      "right": "en cours"
    },
    {
      "left": "le soleil est revenu",
      "right": "changement"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl ___ fort. Soudain, Patrick a glissé. (pleuvoir)",
  "answer": "pleuvait"
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
    "marchions",
    "quand",
    "le",
    "soleil",
    "est",
    "revenu",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pleuvait",
  "hint": "Le ciel versait de l'eau : décor à l'imparfait."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il a plu fort et soudain Patrick glissait.",
  "correct_sentence": "Il pleuvait fort. Soudain, Patrick a glissé.",
  "explanation": "Décor à l'imparfait, événement au passé composé."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/rire-pc.svg",
      "word": "un rire"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/banc-souvenir.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/week-end-theme.svg",
      "word": "un week-end"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/cest-qui.svg",
      "word": "c'est qui"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Classez six verbes du dialogue : imparfait ou passé composé."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il pleuvait. Soudain, il a glissé. Nous marchions. Le soleil est revenu."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Pages d''émotions',
    'CE',
    $c$Objectif
Lire des souvenirs qui mêlent imparfait et passé composé.

Consigne
Lisez les pages, sans aller trop vite.

Support — Cahier mauve, Salle des Herbes
Page Léa — Le vent soufflait. J'ai vu l'Île de Sable-Rouge au loin.
Page Patrick — Nous étions silencieux. Puis Joël a chanté trop fort, et nous avons ri.
Page Hawa — J'avais froid aux mains. Rose m'a prêté ses gants.
Page Marc — La tente claquait. Sami a calé un piquet.
Page Yvette — Les lampions du marché brillaient. J'ai acheté une ficelle ocre.
Rappel : habitude / décor / émotion → imparfait. Fait unique → passé composé.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa a vu l'île pendant que le vent soufflait.",
  "correct": true,
  "explanation": "Soufflait (décor) + j'ai vu (fait)."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a calé un piquet ?",
  "options": [
    {
      "text": "Patrick",
      "correct": false
    },
    {
      "text": "Joël",
      "correct": false
    },
    {
      "text": "Sami",
      "correct": true
    },
    {
      "text": "Yvette",
      "correct": false
    }
  ],
  "explanation": "Page Marc : « Sami a calé un piquet. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le vent soufflait",
      "right": "imparfait"
    },
    {
      "left": "j'ai vu l'île",
      "right": "passé composé"
    },
    {
      "left": "nous avons ri",
      "right": "événement"
    },
    {
      "left": "les lampions brillaient",
      "right": "décor"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'___ froid aux mains. Rose m'a prêté ses gants.",
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
    "Joël",
    "a",
    "chanté",
    "et",
    "nous",
    "avons",
    "ri",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "soufflait",
  "hint": "Le vent… : décor long, pas un seul coup."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le vent a soufflé tout le temps et j'ai vu rien.",
  "correct_sentence": "Le vent soufflait tout le temps et je n'ai rien vu.",
  "explanation": "Décor à l'imparfait ; ne… rien au passé composé."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/banc-souvenir.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/week-end-theme.svg",
      "word": "un week-end"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/cest-qui.svg",
      "word": "c'est qui"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/cest-que.svg",
      "word": "c'est que"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez une page et ajoutez une phrase à l'imparfait, une au PC."
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
    'PO — Raconter un souvenir',
    'PO',
    $c$Objectif
Enchaîner un décor à l'imparfait et un fait au passé composé.

Consigne
Répétez, puis racontez deux minutes sous le figuier.

Support — Modèles de Marc
Il pleuvait.
Nous marchions.
J'étais fatigué.
Soudain, Léa a ri.
Le soleil est revenu.
Nous avons allumé le feu.
Kévin avait peur, mais il a continué.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Soudain » annonce souvent un passé composé.",
  "correct": true,
  "explanation": "Un événement entre dans le décor."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase peint une émotion durable ?",
  "options": [
    {
      "text": "Léa a ri",
      "correct": false
    },
    {
      "text": "Le soleil est revenu",
      "correct": false
    },
    {
      "text": "J'étais fatigué",
      "correct": true
    },
    {
      "text": "Nous avons allumé",
      "correct": false
    }
  ],
  "explanation": "Imparfait pour l'état."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "imparfait",
      "right": "décor / émotion / habitude"
    },
    {
      "left": "passé composé",
      "right": "fait / changement"
    },
    {
      "left": "soudain",
      "right": "bascule"
    },
    {
      "left": "quand + PC",
      "right": "interruption"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSoudain, Léa ___ ri.",
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
    "J'étais",
    "fatigué",
    "alors",
    "je",
    "me",
    "suis",
    "assis",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "fatigué",
  "hint": "Marc l'était : état long, avant de s'asseoir. (avec accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous avons marché quand le soleil revenait soudain.",
  "correct_sentence": "Nous marchions quand le soleil est revenu.",
  "explanation": "Action en cours à l'imparfait, interruption au PC."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/week-end-theme.svg",
      "word": "un week-end"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/cest-qui.svg",
      "word": "c'est qui"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/cest-que.svg",
      "word": "c'est que"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/tente-figuier.svg",
      "word": "une tente"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un souvenir de six lignes : trois imparfaits, trois PC."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis un souvenir à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma page de souvenir',
    'PE',
    $c$Objectif
Écrire un souvenir avec les deux temps du récit.

Consigne
Imitez la page de Léa.

Support — Page de Léa Niyonzima
Léa Niyonzima
Il pleuvait sur le sentier de Mwezi-Haut.
Nous marchions sans parler.
J'avais les pieds mouillés.
Soudain, Patrick a glissé et tout le monde a ri.
Le soleil est revenu près du lac.
Je me suis sentie légère.
Léa
Sous le figuier — soir
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa écrit que le groupe parlait beaucoup.",
  "correct": false,
  "explanation": "« Nous marchions sans parler. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel verbe est au passé composé ?",
  "options": [
    {
      "text": "pleuvait",
      "correct": false
    },
    {
      "text": "marchions",
      "correct": false
    },
    {
      "text": "a glissé",
      "correct": true
    },
    {
      "text": "avais",
      "correct": false
    }
  ],
  "explanation": "Patrick a glissé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il pleuvait",
      "right": "décor"
    },
    {
      "left": "nous marchions",
      "right": "action en cours"
    },
    {
      "left": "a glissé / a ri",
      "right": "faits"
    },
    {
      "left": "je me suis sentie",
      "right": "changement"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe me suis ___ légère. (sentir, fém.)",
  "answer": "sentie"
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
    "soleil",
    "est",
    "revenu",
    "près",
    "du",
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
  "word": "glissé",
  "hint": "Patrick a… : un fait soudain sur les pierres."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je me suis senti légère.",
  "correct_sentence": "Je me suis sentie légère.",
  "explanation": "Léa : accord du participe avec le sujet féminin (pronominal)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/cest-qui.svg",
      "word": "c'est qui"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/cest-que.svg",
      "word": "c'est que"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/tente-figuier.svg",
      "word": "une tente"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/carte-genre.svg",
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
  "prompt": "Imitez : six lignes, décor à l'imparfait, deux faits au PC."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre page, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Passé composé et imparfait',
    'EL',
    $c$Objectif
Retenir quand raconter au PC et quand peindre à l'imparfait.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
Imparfait : décor, émotion, habitude, action en cours.
Il pleuvait. Nous marchions. J'avais peur. Mado racontait.
Passé composé : fait, changement, événement unique.
Il a glissé. Nous avons ri. Le soleil est revenu.
Souvent : imparfait + quand / soudain + passé composé.
Attention : j'étais (état) ≠ j'ai été (un moment vécu comme un fait).
Accord : je me suis sentie (féminin) / je me suis senti (masculin).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'imparfait sert surtout à lister des faits soudains.",
  "correct": false,
  "explanation": "L'imparfait peint le décor. Le PC dit le fait."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Nous marchions quand… » continue souvent par…",
  "options": [
    {
      "text": "il pleuvait encore",
      "correct": false
    },
    {
      "text": "le soleil est revenu",
      "correct": true
    },
    {
      "text": "j'étais fatigué",
      "correct": false
    },
    {
      "text": "Mado racontait",
      "correct": false
    }
  ],
  "explanation": "Quand + événement au PC."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "imparfait",
      "right": "décor"
    },
    {
      "left": "passé composé",
      "right": "fait"
    },
    {
      "left": "soudain",
      "right": "bascule"
    },
    {
      "left": "habitude",
      "right": "imparfait"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ quand Patrick a glissé. (marcher)",
  "answer": "marchions"
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
    "pleuvait",
    ".",
    "Soudain",
    "il",
    "a",
    "ri",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "décor",
  "hint": "L'imparfait peint le… : le temps, le lieu, l'émotion."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Hier il a pleuvait et nous avons marché longtemps le décor.",
  "correct_sentence": "Hier il pleuvait et nous avons marché longtemps.",
  "explanation": "Un seul auxiliaire : pleuvait (imparfait) / avons marché (PC)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/cest-que.svg",
      "word": "c'est que"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/tente-figuier.svg",
      "word": "une tente"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/carte-genre.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/sac-masculin.svg",
      "word": "un sac"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez cinq paires : décor (imp.) + fait (PC)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et trois souvenirs courts."
}$j$::jsonb,
    9
  );

  -- ===== Un week-end à thème =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un week-end à thème'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un week-end à thème', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Qui a fait le week-end',
    'CO',
    $c$Objectif
Repérer la mise en relief : c'est… qui (sujet), c'est… que (COD).

Consigne
Lisez le dialogue. Qui met quoi en avant ?

Support — Cour de la Maison des Vents
Aline : C'est Léa qui a préparé le feu de camp.
Patrick : C'est le sentier que Marc a choisi, pas la route.
Hawa : C'est Rose qui a tendu la tente sous le figuier.
Joël : C'est la chanson que Mado a chantée, près des lampions.
Karim : Ce sont Patrick et moi qui avons porté l'eau.
Solange : C'est l'heure que vous avez oubliée, pas le lieu.
Léa : C'est Aline qui donne le thème : « vents et récits ».
Marc : C'est ce week-end que je garderai.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "C'est Léa qui a préparé le feu.",
  "correct": true,
  "explanation": "Aline met Léa en relief (sujet)."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que met Patrick en relief ?",
  "options": [
    {
      "text": "La route",
      "correct": false
    },
    {
      "text": "Le sentier",
      "correct": true
    },
    {
      "text": "La tente",
      "correct": false
    },
    {
      "text": "L'eau",
      "correct": false
    }
  ],
  "explanation": "« C'est le sentier que Marc a choisi. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est Léa qui",
      "right": "sujet mis en relief"
    },
    {
      "left": "c'est le sentier que",
      "right": "COD mis en relief"
    },
    {
      "left": "ce sont Patrick et moi qui",
      "right": "pluriel"
    },
    {
      "left": "c'est l'heure que",
      "right": "chose oubliée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est Léa ___ a préparé le feu.",
  "answer": "qui"
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
    "sentier",
    "que",
    "Marc",
    "a",
    "choisi",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "relief",
  "hint": "C'est… qui / que : on met un mot en…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est Léa que a préparé le feu.",
  "correct_sentence": "C'est Léa qui a préparé le feu.",
  "explanation": "Sujet → qui. COD → que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/tente-figuier.svg",
      "word": "une tente"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/carte-genre.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/sac-masculin.svg",
      "word": "un sac"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/boussole-feminine.svg",
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
  "prompt": "Notez trois c'est… qui et deux c'est… que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : C'est Léa qui a préparé le feu. C'est le sentier que Marc a choisi."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Programme du week-end',
    'CE',
    $c$Objectif
Lire un programme qui insiste avec c'est… qui / que.

Consigne
Lisez le programme, sans aller trop vite.

Support — Feuille mauve, Table des Sources
Week-end à thème — Maison des Vents
C'est Karim qui ouvre le samedi à neuf heures.
C'est la Salle des Herbes que nous gardons pour les récits.
C'est Félicie qui prépare la table, pas l'atelier.
C'est le silence que je demande après vingt-deux heures. (Aline)
Ce sont Hawa et Rose qui tiennent le feu.
C'est Mwezi-Haut que le dimanche réserve, si le ciel est clair.
Lila Sow — Radio Figuier annoncera : c'est ce thème que nous suivons.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Félicie prépare l'atelier, d'après le programme.",
  "correct": false,
  "explanation": "« C'est Félicie qui prépare la table, pas l'atelier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui ouvre le samedi ?",
  "options": [
    {
      "text": "Aline",
      "correct": false
    },
    {
      "text": "Karim",
      "correct": true
    },
    {
      "text": "Lila",
      "correct": false
    },
    {
      "text": "Félicie",
      "correct": false
    }
  ],
  "explanation": "« C'est Karim qui ouvre le samedi. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est Karim qui",
      "right": "ouvre"
    },
    {
      "left": "c'est la salle que",
      "right": "récits"
    },
    {
      "left": "ce sont Hawa et Rose qui",
      "right": "feu"
    },
    {
      "left": "c'est Mwezi-Haut que",
      "right": "dimanche"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est la Salle des Herbes ___ nous gardons.",
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
    "Karim",
    "qui",
    "ouvre",
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
  "word": "theme",
  "hint": "Week-end à… : vents et récits (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est la Salle des Herbes qui nous gardons.",
  "correct_sentence": "C'est la Salle des Herbes que nous gardons.",
  "explanation": "Nous gardons la salle → que (COD)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/carte-genre.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/sac-masculin.svg",
      "word": "un sac"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/boussole-feminine.svg",
      "word": "une boussole"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/liste-noms.svg",
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
  "prompt": "Réécrivez trois lignes en enlevant puis en remettant c'est… qui / que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le programme, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Insister avec c''est',
    'PO',
    $c$Objectif
Mettre un nom en relief à l'oral.

Consigne
Répétez, puis insistez sur un moment du week-end.

Support — Modèles de Karim
C'est Léa qui prépare.
C'est Patrick qui porte l'eau.
C'est le sentier que nous prenons.
C'est la tente que Rose a tendue.
Ce sont eux qui chantent.
C'est ce week-end que je garde.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Qui » reprend le sujet mis en avant.",
  "correct": true,
  "explanation": "C'est Léa qui prépare : Léa = sujet."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "On dit « C'est la tente… Rose a tendue » comment ?",
  "options": [
    {
      "text": "qui",
      "correct": false
    },
    {
      "text": "que",
      "correct": true
    },
    {
      "text": "dont",
      "correct": false
    },
    {
      "text": "où",
      "correct": false
    }
  ],
  "explanation": "Rose a tendu la tente → que."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est… qui",
      "right": "sujet"
    },
    {
      "left": "c'est… que",
      "right": "COD"
    },
    {
      "left": "ce sont… qui",
      "right": "plusieurs personnes"
    },
    {
      "left": "c'est ce week-end que",
      "right": "moment"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCe sont eux ___ chantent.",
  "answer": "qui"
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
    "tente",
    "que",
    "Rose",
    "a",
    "tendue",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tendue",
  "hint": "Rose a… la toile : participe accordé avec tente."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est eux qui chantent.",
  "correct_sentence": "Ce sont eux qui chantent.",
  "explanation": "Pluriel : ce sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/sac-masculin.svg",
      "word": "un sac"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/boussole-feminine.svg",
      "word": "une boussole"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/liste-noms.svg",
      "word": "une liste"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/fil-parcours.svg",
      "word": "un fil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six mises en relief : trois qui, trois que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six modèles, puis deux phrases à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon billet de week-end',
    'PE',
    $c$Objectif
Écrire un billet qui insiste avec c'est… qui / que.

Consigne
Imitez le billet de Marc.

Support — Billet de Marc Nkurunziza
Marc Nkurunziza
C'est Léa qui a préparé le feu.
C'est le sentier que j'ai choisi.
C'est Aline qui a donné le thème.
Ce sont Hawa et Rose qui ont tenu la tente.
C'est ce silence que je garde, après les chansons.
C'est la Maison des Vents que nous quitterons lundi.
Marc
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc dit que Joël a choisi le sentier.",
  "correct": false,
  "explanation": "« C'est le sentier que j'ai choisi. » (Marc)"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a donné le thème ?",
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
      "text": "Karim",
      "correct": false
    },
    {
      "text": "Lila",
      "correct": false
    }
  ],
  "explanation": "« C'est Aline qui a donné le thème. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est Léa qui",
      "right": "feu"
    },
    {
      "left": "c'est le sentier que",
      "right": "choix de Marc"
    },
    {
      "left": "ce sont Hawa et Rose qui",
      "right": "tente"
    },
    {
      "left": "c'est ce silence que",
      "right": "souvenir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est Aline ___ a donné le thème.",
  "answer": "qui"
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
    "ce",
    "silence",
    "que",
    "je",
    "garde",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "quitterons",
  "hint": "Nous… la maison lundi : futur de quitter."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ce sont Hawa et Rose que ont tenu la tente.",
  "correct_sentence": "Ce sont Hawa et Rose qui ont tenu la tente.",
  "explanation": "Elles font l'action → qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/boussole-feminine.svg",
      "word": "une boussole"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/liste-noms.svg",
      "word": "une liste"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/fil-parcours.svg",
      "word": "un fil"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/horloge-depuis.svg",
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
  "prompt": "Imitez : six lignes, trois qui et trois que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre billet, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — C''est… qui, c''est… que',
    'EL',
    $c$Objectif
Retenir la mise en relief du sujet et du complément.

Consigne
Apprenez la fiche.

Support — Fiche de Lila
C'est + nom + qui + verbe : on insiste sur le sujet.
C'est Léa qui prépare. Ce sont Patrick et Joël qui portent.
C'est + nom + que + sujet + verbe : on insiste sur le COD.
C'est le sentier que Marc a choisi.
Élision : c'est l'heure qu'ils ont oubliée.
Pluriel des personnes : ce sont… qui (pas c'est eux qui, à l'écrit soigné).
Ne pas dire : c'est Léa que prépare.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « c'est Léa que prépare » pour le sujet.",
  "correct": false,
  "explanation": "Sujet → qui."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Marc a choisi le sentier » devient…",
  "options": [
    {
      "text": "C'est Marc que a choisi le sentier",
      "correct": false
    },
    {
      "text": "C'est le sentier que Marc a choisi",
      "correct": true
    },
    {
      "text": "C'est le sentier qui Marc a choisi",
      "correct": false
    },
    {
      "text": "C'est Marc que le sentier",
      "correct": false
    }
  ],
  "explanation": "COD le sentier → c'est le sentier que…"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est… qui",
      "right": "sujet"
    },
    {
      "left": "c'est… que",
      "right": "COD"
    },
    {
      "left": "ce sont… qui",
      "right": "plusieurs"
    },
    {
      "left": "qu'ils",
      "right": "élision de que"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est l'heure ___ ils ont oubliée.",
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
    "Ce",
    "sont",
    "eux",
    "qui",
    "chantent",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "sujet",
  "hint": "C'est Léa qui : on insiste sur le… de la phrase."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le sentier qui Marc a choisi.",
  "correct_sentence": "C'est le sentier que Marc a choisi.",
  "explanation": "Marc a choisi le sentier → que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/liste-noms.svg",
      "word": "une liste"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/fil-parcours.svg",
      "word": "un fil"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/horloge-depuis.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/calendrier-pendant.svg",
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
  "prompt": "Transformez six phrases simples en c'est… qui ou c'est… que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six mises en relief."
}$j$::jsonb,
    9
  );

  -- ===== Partir à l'aventure =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Partir à l''aventure'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Partir à l''aventure', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Que met-on dans le sac',
    'CO',
    $c$Objectif
Repérer le genre : un/une, le/la, et quelques exceptions.

Consigne
Lisez le dialogue. Un ou une ? Le ou la ?

Support — Départ vers Mwezi-Haut
Hawa : Je prends une image du Seuil, pour le moral.
Patrick : Moi, un arbre dessiné par Marc, plié dans le cahier.
Léa : Une aventure commence au premier pas. Un voyage, c'est plus long.
Joël : La boussole est dans le sac. Le sentier part derrière la tente.
Rose : Une carte, un journal, une photo, un récit : je mélange.
Kévin : La chaussure gauche est trop large. Le feu ? On l'allumera plus tard.
Aline : Attention : une image, un arbre, une aventure, un voyage.
Benoît : J'apporte une lampe. Noura garde le groupe sur la liste.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « un image » pour une photo du Seuil.",
  "correct": false,
  "explanation": "Hawa : « une image ». Image est féminin."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel mot est masculin parmi ces exceptions utiles ?",
  "options": [
    {
      "text": "image",
      "correct": false
    },
    {
      "text": "aventure",
      "correct": false
    },
    {
      "text": "arbre",
      "correct": true
    },
    {
      "text": "tente",
      "correct": false
    }
  ],
  "explanation": "Un arbre. Une image, une aventure, une tente."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "une image",
      "right": "féminin"
    },
    {
      "left": "un arbre",
      "right": "masculin"
    },
    {
      "left": "une aventure",
      "right": "féminin"
    },
    {
      "left": "un voyage",
      "right": "masculin"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe prends ___ image du Seuil.",
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
    "Une",
    "aventure",
    "commence",
    "au",
    "premier",
    "pas",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "image",
  "hint": "Hawa en prend une : un dessin ou une photo du Seuil."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je prends un image du Seuil.",
  "correct_sentence": "Je prends une image du Seuil.",
  "explanation": "Image est féminin : une image."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/fil-parcours.svg",
      "word": "un fil"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/horloge-depuis.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/calendrier-pendant.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/fleche-dans.svg",
      "word": "une flèche"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Listez huit noms du dialogue avec un/une ou le/la."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : une image, un arbre, une aventure, un voyage, la boussole, le sac."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Liste pour Mwezi-Haut',
    'CE',
    $c$Objectif
Lire une liste et corriger le genre des noms.

Consigne
Lisez la liste, sans aller trop vite.

Support — Liste de Benoît Habumuremyi
À prendre — montée vers Mwezi-Haut
une tente, un sac, une boussole, un sentier (sur la carte)
une image du figuier, un arbre pour l'ombre (point de rendez-vous)
une aventure courte, pas un voyage de trois semaines
une carte, un journal, une photo, un récit
une chaussure de rechange, un feu déjà prévu (pierre noire)
une lampe, un groupe de six, la gourde, le cahier
Benoît — vu par Aline : genres vérifiés.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La liste parle d'un voyage de trois semaines.",
  "correct": false,
  "explanation": "« une aventure courte, pas un voyage de trois semaines »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel objet est féminin ?",
  "options": [
    {
      "text": "un sac",
      "correct": false
    },
    {
      "text": "un journal",
      "correct": false
    },
    {
      "text": "une boussole",
      "correct": true
    },
    {
      "text": "un récit",
      "correct": false
    }
  ],
  "explanation": "Une boussole."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "une tente / une boussole",
      "right": "féminin"
    },
    {
      "left": "un sac / un sentier",
      "right": "masculin"
    },
    {
      "left": "une photo / une lampe",
      "right": "féminin"
    },
    {
      "left": "un journal / un feu",
      "right": "masculin"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ arbre marque le rendez-vous.",
  "answer": "Un"
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
    "boussole",
    "est",
    "dans",
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
  "word": "boussole",
  "hint": "Elle indique le nord, dans le sac de Joël."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je mets un boussole dans la sac.",
  "correct_sentence": "Je mets une boussole dans le sac.",
  "explanation": "Une boussole (fém.). Le sac (masc.)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/horloge-depuis.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/calendrier-pendant.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/fleche-dans.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/groupe-amis.svg",
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
  "prompt": "Recopiez la liste en deux colonnes : masculin / féminin."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la liste complète, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire un ou une',
    'PO',
    $c$Objectif
Nommer le matériel avec le bon genre.

Consigne
Répétez, puis préparez à voix haute le sac du groupe.

Support — Modèles d'Hawa
C'est une image.
C'est un arbre.
C'est une aventure.
C'est un voyage.
Voici la boussole.
Voici le sentier.
J'oublie la tente. Je n'oublie pas le journal.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Voyage » est masculin : un voyage, le voyage.",
  "correct": true,
  "explanation": "Contrairement à une aventure."
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
      "text": "un image / une arbre",
      "correct": false
    },
    {
      "text": "une image / un arbre",
      "correct": true
    },
    {
      "text": "une image / une arbre",
      "correct": false
    },
    {
      "text": "un image / un arbre",
      "correct": false
    }
  ],
  "explanation": "Une image, un arbre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "une / la",
      "right": "féminin"
    },
    {
      "left": "un / le",
      "right": "masculin"
    },
    {
      "left": "au = à + le",
      "right": "au sentier"
    },
    {
      "left": "de + le = du",
      "right": "près du feu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVoici ___ sentier. (masc.)",
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
    "C'est",
    "une",
    "aventure",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "voyage",
  "hint": "Plus long qu'une aventure : un… vers Port de la Brise."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On se retrouve à le sentier derrière la tente.",
  "correct_sentence": "On se retrouve au sentier derrière la tente.",
  "explanation": "À + le = au."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/calendrier-pendant.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/fleche-dans.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/groupe-amis.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/feu-camp.svg",
      "word": "un feu"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Nommez dix objets de l'aventure avec un/une ou le/la."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis votre sac (six noms)."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma liste d''aventure',
    'PE',
    $c$Objectif
Écrire une liste de matériel avec les bons genres.

Consigne
Imitez la liste d'Hawa.

Support — Liste de Hawa Diallo
Hawa Diallo
Je prends une image du Seuil et un arbre dessiné par Marc.
C'est une aventure, pas un voyage.
La boussole reste dans le sac.
Une carte, un journal, une photo, un récit.
J'allume le feu près de la tente.
Hawa
Vers Mwezi-Haut
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa dit que c'est un long voyage.",
  "correct": false,
  "explanation": "« C'est une aventure, pas un voyage. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où reste la boussole ?",
  "options": [
    {
      "text": "Dans la tente",
      "correct": false
    },
    {
      "text": "Dans le sac",
      "correct": true
    },
    {
      "text": "Sur l'arbre",
      "correct": false
    },
    {
      "text": "Au lac",
      "correct": false
    }
  ],
  "explanation": "« La boussole reste dans le sac. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "une image / un arbre",
      "right": "exceptions utiles"
    },
    {
      "left": "une aventure / un voyage",
      "right": "durée différente"
    },
    {
      "left": "la boussole / le sac",
      "right": "objets"
    },
    {
      "left": "le feu / la tente",
      "right": "camp"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est ___ aventure, pas un voyage.",
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
    "La",
    "boussole",
    "reste",
    "dans",
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
  "word": "tente",
  "hint": "Toile dressée sous le figuier : une…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je prends un aventure et une voyage.",
  "correct_sentence": "Je prends une aventure et un voyage.",
  "explanation": "Une aventure, un voyage."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/fleche-dans.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/groupe-amis.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/feu-camp.svg",
      "word": "un feu"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/carte-mwezi.svg",
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
  "prompt": "Imitez : six lignes, huit noms avec le bon article."
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
    'EL — Genre des noms',
    'EL',
    $c$Objectif
Retenir un/une, le/la et quelques exceptions utiles.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
Masculin : un / le. Féminin : une / la.
Exceptions utiles : une image, un arbre, une aventure, un voyage.
Autres du sac : une tente, un sac, une boussole, un sentier.
une carte, un journal, une photo, un récit.
une chaussure, un feu, une lampe, un groupe.
Contractions : à + le = au (au sentier). de + le = du (près du feu).
On ne dit pas : un image, une arbre, à le sentier.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Arbre » est féminin.",
  "correct": false,
  "explanation": "Un arbre, le arbre → l'arbre."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« À + le sentier » s'écrit…",
  "options": [
    {
      "text": "à le sentier",
      "correct": false
    },
    {
      "text": "au sentier",
      "correct": true
    },
    {
      "text": "aux sentier",
      "correct": false
    },
    {
      "text": "du sentier",
      "correct": false
    }
  ],
  "explanation": "À + le = au."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "une image",
      "right": "fém. malgré -age parfois masc."
    },
    {
      "left": "un arbre",
      "right": "masc."
    },
    {
      "left": "une aventure",
      "right": "fém."
    },
    {
      "left": "un voyage",
      "right": "masc."
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous marchons ___ sentier ocre. (à + le)",
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
    "C'est",
    "un",
    "arbre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "arbre",
  "hint": "Grand végétal : un… donne de l'ombre au rendez-vous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Posez la lampe à le milieu du camp.",
  "correct_sentence": "Posez la lampe au milieu du camp.",
  "explanation": "À + le = au."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/groupe-amis.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/feu-camp.svg",
      "word": "un feu"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/carte-mwezi.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/journal-aventure.svg",
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
  "prompt": "Faites deux listes de douze noms : masculin / féminin, avec un exemple."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et les quatre exceptions."
}$j$::jsonb,
    9
  );

  -- ===== Le fil de mon parcours =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Le fil de mon parcours'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Le fil de mon parcours', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Quand tout s''est enchaîné',
    'CO',
    $c$Objectif
Repérer il y a, pendant, depuis et dans sur une ligne de temps.

Consigne
Lisez le dialogue. Quel marqueur pour quel moment ?

Support — Banc du figuier, bilan
Léa : Il y a trois jours, nous sommes arrivés à la Maison des Vents.
Patrick : Pendant le week-end, il a plu, puis le ciel s'est ouvert.
Hawa : Depuis vendredi, je dors sous la tente.
Joël : Dans deux jours, nous irons jusqu'à Mwezi-Haut.
Marc : Il y a une heure, Kévin est tombé ; maintenant il va bien.
Aline : Pendant trois heures, vous avez marché sans pause trop longue.
Rose : Depuis ce matin, le groupe prépare les sacs.
Solange : Dans une semaine, le minibus Figuier 7 reviendra.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Depuis vendredi » veut dire que Hawa dort encore sous la tente.",
  "correct": true,
  "explanation": "Depuis = début dans le passé, action encore vraie."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel marqueur annonce un projet futur ?",
  "options": [
    {
      "text": "il y a trois jours",
      "correct": false
    },
    {
      "text": "pendant le week-end",
      "correct": false
    },
    {
      "text": "depuis vendredi",
      "correct": false
    },
    {
      "text": "dans deux jours",
      "correct": true
    }
  ],
  "explanation": "Dans + durée = plus tard."
}$j$::jsonb,
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
      "right": "il y a X : c'était il y a…"
    },
    {
      "left": "pendant",
      "right": "durée terminée"
    },
    {
      "left": "depuis",
      "right": "ça continue"
    },
    {
      "left": "dans",
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
  "prompt": "Complétez :\n___ deux jours, nous irons à Mwezi-Haut.",
  "answer": "Dans"
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
    "trois",
    "jours",
    "nous",
    "sommes",
    "arrivés",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "depuis",
  "hint": "Hawa dort encore sous la toile : … vendredi."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dans trois jours, nous sommes arrivés à la Maison.",
  "correct_sentence": "Il y a trois jours, nous sommes arrivés à la Maison.",
  "explanation": "Fait passé révolu → il y a. Dans = futur."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/feu-camp.svg",
      "word": "un feu"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/carte-mwezi.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/journal-aventure.svg",
      "word": "un journal"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/chaussure-marche.svg",
      "word": "une chaussure"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Classez huit phrases : il y a / pendant / depuis / dans."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il y a trois jours. Pendant le week-end. Depuis vendredi. Dans deux jours."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fil du Cahier',
    'CE',
    $c$Objectif
Lire une frise de temps avec les quatre marqueurs.

Consigne
Lisez la frise, sans aller trop vite.

Support — Frise de Solange Mukamana
Fil du parcours — Seuil des Sources
Il y a dix jours : arrivée dans la cour, sous le figuier.
Pendant les trois premiers soirs : récits à la Table des Sources.
Depuis lundi : Radio Figuier enregistre les voix du groupe.
Dans quatre jours : montée vers Mwezi-Haut, si le ciel reste clair.
Il y a une nuit : feu de camp, chaussures près de la lampe.
Pendant une heure : silence demandé par Aline.
Ibrahim a ajouté : depuis l'aube, le minibus attend au Port de la Brise.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Radio Figuier a déjà arrêté d'enregistrer.",
  "correct": false,
  "explanation": "« Depuis lundi : Radio Figuier enregistre » (ça continue)."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quand aura lieu la montée vers Mwezi-Haut ?",
  "options": [
    {
      "text": "Il y a dix jours",
      "correct": false
    },
    {
      "text": "Pendant les soirs",
      "correct": false
    },
    {
      "text": "Depuis lundi",
      "correct": false
    },
    {
      "text": "Dans quatre jours",
      "correct": true
    }
  ],
  "explanation": "Futur : dans quatre jours."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il y a dix jours",
      "right": "arrivée"
    },
    {
      "left": "pendant les soirs",
      "right": "récits"
    },
    {
      "left": "depuis lundi",
      "right": "radio"
    },
    {
      "left": "dans quatre jours",
      "right": "montée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ lundi, la radio enregistre les voix.",
  "answer": "Depuis"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Pendant",
    "une",
    "heure",
    "Aline",
    "a",
    "demandé",
    "silence",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pendant",
  "hint": "Durée close : … une heure, puis le silence a cessé."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Depuis quatre jours, nous irons à Mwezi-Haut.",
  "correct_sentence": "Dans quatre jours, nous irons à Mwezi-Haut.",
  "explanation": "Projet futur → dans. Depuis = déjà commencé."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/carte-mwezi.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/journal-aventure.svg",
      "word": "un journal"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/chaussure-marche.svg",
      "word": "une chaussure"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/lampe-soir.svg",
      "word": "une lampe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la frise et ajoutez une ligne avec chaque marqueur."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la frise complète, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dater avec quatre mots',
    'PO',
    $c$Objectif
Situer un fait : il y a, pendant, depuis, dans.

Consigne
Répétez, puis datez votre semaine au Seuil.

Support — Modèles d'Aline
Il y a deux jours, nous sommes partis.
Pendant le week-end, il a plu.
Depuis vendredi, je marche.
Dans une semaine, je reviendrai.
Il y a une heure, le groupe a ri.
Pendant trois heures, nous avons grimpé.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il y a » regarde vers le passé révolu.",
  "correct": true,
  "explanation": "Il y a deux jours = two days ago."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase dit qu'une action continue ?",
  "options": [
    {
      "text": "Il y a deux jours, nous sommes partis",
      "correct": false
    },
    {
      "text": "Pendant le week-end, il a plu",
      "correct": false
    },
    {
      "text": "Depuis vendredi, je marche",
      "correct": true
    },
    {
      "text": "Dans une semaine, je reviendrai",
      "correct": false
    }
  ],
  "explanation": "Depuis + présent (souvent)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il y a + durée",
      "right": "passé révolu"
    },
    {
      "left": "pendant + durée",
      "right": "durée close"
    },
    {
      "left": "depuis + moment",
      "right": "encore vrai"
    },
    {
      "left": "dans + durée",
      "right": "futur"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ vendredi, je marche.",
  "answer": "Depuis"
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
    "une",
    "semaine",
    "je",
    "reviendrai",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "reviendrai",
  "hint": "Dans une semaine je… : futur de revenir, un r après i."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il y a une semaine, je reviendrai au Seuil.",
  "correct_sentence": "Dans une semaine, je reviendrai au Seuil.",
  "explanation": "Futur → dans. Il y a = déjà passé."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/journal-aventure.svg",
      "word": "un journal"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/chaussure-marche.svg",
      "word": "une chaussure"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/lampe-soir.svg",
      "word": "une lampe"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/recit-lea.svg",
      "word": "un récit"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases : deux de chaque marqueur."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six modèles, puis votre frise orale."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Le fil de ma semaine',
    'PE',
    $c$Objectif
Écrire une frise personnelle avec les quatre marqueurs.

Consigne
Imitez le fil de Joël.

Support — Fil de Joël Mugisha
Joël Mugisha
Il y a cinq jours, j'ai quitté Val-des-Peupliers.
Pendant le week-end, j'ai dormi à la Maison des Vents.
Depuis samedi, je prépare la montée.
Dans trois jours, je serai sur le sentier de Mwezi-Haut.
Il y a une heure, Léa a rangé les lampes.
Pendant une nuit, le vent a parlé dans les figues.
Joël
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël écrit « je sera » pour le futur.",
  "correct": false,
  "explanation": "« je serai sur le sentier » : futur en -ai."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait Joël depuis samedi ?",
  "options": [
    {
      "text": "Il dort encore à Val-des-Peupliers",
      "correct": false
    },
    {
      "text": "Il prépare la montée",
      "correct": true
    },
    {
      "text": "Il quitte le Seuil",
      "correct": false
    },
    {
      "text": "Il éteint Radio Figuier",
      "correct": false
    }
  ],
  "explanation": "« Depuis samedi, je prépare la montée. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il y a cinq jours",
      "right": "départ"
    },
    {
      "left": "pendant le week-end",
      "right": "Maison des Vents"
    },
    {
      "left": "depuis samedi",
      "right": "prépare"
    },
    {
      "left": "dans trois jours",
      "right": "sentier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDans trois jours, je ___ sur le sentier. (être, futur)",
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
    "Depuis",
    "samedi",
    "je",
    "prépare",
    "la",
    "montée",
    "."
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
  "hint": "Dans trois jours je… là-haut : futur d'être, je."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dans trois jours, je sera sur le sentier.",
  "correct_sentence": "Dans trois jours, je serai sur le sentier.",
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
      "image_path": "/elearning/mfk-a2-m2/chaussure-marche.svg",
      "word": "une chaussure"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/lampe-soir.svg",
      "word": "une lampe"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/recit-lea.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/valise-ouverte.svg",
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
  "prompt": "Imitez : six lignes, les quatre marqueurs au moins une fois."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre fil, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Il y a, pendant, depuis, dans',
    'EL',
    $c$Objectif
Retenir les quatre marqueurs de temps.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
Il y a + durée : le fait est fini, on compte en arrière.
Il y a trois jours, nous sommes arrivés.
Pendant + durée (ou pendant le week-end) : durée close.
Pendant trois heures, nous avons marché.
Depuis + moment / durée : ça a commencé, c'est encore vrai.
Depuis vendredi, je dors ici. (présent)
Dans + durée : plus tard.
Dans deux jours, nous irons à Mwezi-Haut.
Ne pas inverser : il y a ≠ dans.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Dans deux jours » parle d'un fait déjà fini.",
  "correct": false,
  "explanation": "Dans = futur."
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
      "text": "Dans trois jours, nous sommes arrivés",
      "correct": false
    },
    {
      "text": "Il y a trois jours, nous sommes arrivés",
      "correct": true
    },
    {
      "text": "Depuis trois jours, nous irons",
      "correct": false
    },
    {
      "text": "Pendant demain, nous marchons",
      "correct": false
    }
  ],
  "explanation": "Passé révolu → il y a."
}$j$::jsonb,
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
      "right": "en arrière"
    },
    {
      "left": "pendant",
      "right": "durée close"
    },
    {
      "left": "depuis",
      "right": "encore vrai"
    },
    {
      "left": "dans",
      "right": "en avant"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ trois heures, nous avons marché. (durée close)",
  "answer": "Pendant"
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
    "une",
    "heure",
    "il",
    "est",
    "tombé",
    "."
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
  "hint": "Il y a, pendant, depuis, dans : quatre… de temps."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Depuis deux jours, nous irons jusqu'au lac.",
  "correct_sentence": "Dans deux jours, nous irons jusqu'au lac.",
  "explanation": "Futur → dans."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m2/lampe-soir.svg",
      "word": "une lampe"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/recit-lea.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/valise-ouverte.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-a2-m2/photo-souvenir.svg",
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
  "prompt": "Rédigez une mini-frise de votre mois avec les quatre mots."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et quatre exemples contrastés."
}$j$::jsonb,
    9
  );

END;
$$;
