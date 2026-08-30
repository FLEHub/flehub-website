/*
  Seed eLearning MFK — B1 — S'installer autrement

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b1-m2/
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
  v_module_title text := 'B1 — S''installer autrement';
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
      'Grande étape B1-2 : exprimer un sentiment, anticiper un souci de santé, remplir des papiers, nuancer des goûts, trouver un rythme et tisser un voisinage — au Pavillon du Saule et à la Maison des Vents (Rive-des-Saules, Val-des-Peupliers), avec l''Infirmerie des Herbes et le Bureau des Escales.',
      'B1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B1-2 : exprimer un sentiment, anticiper un souci de santé, remplir des papiers, nuancer des goûts, trouver un rythme et tisser un voisinage — au Pavillon du Saule et à la Maison des Vents (Rive-des-Saules, Val-des-Peupliers), avec l''Infirmerie des Herbes et le Bureau des Escales.',
      cefr_level = 'B1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Un souci du quotidien =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un souci du quotidien'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un souci du quotidien', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Une tasse, un bruit, un accord',
    'CO',
    $c$Objectif
Comprendre je suis content(e) que, j'ai peur que, il faut que, je veux que + subjonctif.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui a peur de quoi ? Qui veut quoi ?

Support — Cuisine du Pavillon du Saule, soir
Léa : J'ai peur que le voisin n'entende trop nos voix, ce soir, au Pavillon du Saule.
Patrick : Je suis content que tu en parles. Il faut que nous trouvions une solution.
Aline : Je veux que chacun range sa tasse. J'ai peur qu'on se plaigne encore.
Marc : Je suis content qu'Hawa soit rentrée. Il faut qu'elle se repose.
Hawa : J'ai peur que la tasse cassée n'agace Karim. Il faut que je m'excuse.
Joël : Je veux que tu parles à Karim, Léa. Il est juste, au fond.
Rose : Je suis contente que Félicie propose un thé. Ça calme.
Karim : J'ai peur que le bruit dure. Il faut que nous fermions la porte plus tôt.
Solange : Je suis contente que vous cherchiez un accord, pas une dispute.
Yvette : Il faut que tu viennes à l'infirmerie si tu as mal à la tête, Hawa.
Lila : Je veux que nous écrivions un mot au voisin, sans colère.
Dieudonné : Je suis content que le Pavillon reste ouvert. Il faut que l'on s'écoute.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick est content que Léa parle du bruit.",
  "correct": true,
  "explanation": "Patrick : « Je suis content que tu en parles. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que veut Aline ?",
  "options": [
    {
      "text": "Que Karim parte",
      "correct": false
    },
    {
      "text": "Que chacun range sa tasse",
      "correct": true
    },
    {
      "text": "Que Léa casse une tasse",
      "correct": false
    },
    {
      "text": "Que Hawa crie",
      "correct": false
    }
  ],
  "explanation": "Aline : « Je veux que chacun range sa tasse. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je suis content que",
      "right": "sentiment + subjonctif"
    },
    {
      "left": "j'ai peur que",
      "right": "crainte + subjonctif"
    },
    {
      "left": "il faut que",
      "right": "obligation + subjonctif"
    },
    {
      "left": "je veux que",
      "right": "volonté + subjonctif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut que nous ___ une solution. (trouver)",
  "answer": "trouvions"
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
    "fermions",
    "la",
    "porte",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "trouvions",
  "hint": "Il faut que nous… une solution : forme de trouver au subjonctif, nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut que nous trouvons une solution, dit Patrick sous le saule.",
  "correct_sentence": "Il faut que nous trouvions une solution, dit Patrick sous le saule.",
  "explanation": "Après il faut que : subjonctif, trouvions (pas trouvons)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/subjonctif-sentiment.svg",
      "word": "un sentiment"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/souci-quotidien.svg",
      "word": "un souci"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/voisin-bruit.svg",
      "word": "un voisin"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/tasse-cassee.svg",
      "word": "une tasse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez deux craintes, deux obligations et un souhait entendus."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : J'ai peur que le bruit dure. Je suis content que tu en parles. Il faut que nous trouvions une solution."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Mot collé à la porte',
    'CE',
    $c$Objectif
Lire un mot qui exprime sentiments et solutions au subjonctif.

Consigne
Lisez le mot, sans aller trop vite.

Support — Feuille ocre, porte du Pavillon du Saule
Pavillon du Saule — mot aux habitants
Je suis contente que vous soyez rentrés sans crier.
J'ai peur que le couloir reste trop bruyant après vingt-deux heures.
Il faut que chacun pose sa tasse dans le bac, pas sur le banc.
Je veux que Léa et Karim parlent demain, près du saule.
Il faut que nous évitions une dispute : un mot suffit.
Je suis content que Félicie prépare le thé de la Table des Sources.
J'ai peur qu'Hawa ne se plaigne de la tête, après la chute de la tasse.
Il faut que tu viennes me voir, Hawa, à l'Infirmerie des Herbes.
Solange Mukamana a écrit : je veux que le tampon attende le matin.
Karim Bamba : je suis content que l'on cherche un accord.
Lila Sow : il faut que le mot reste poli, même si l'on est fatigué.
Dieudonné : je veux que la porte reste ouverte le jour, fermée la nuit.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut crier dans le couloir après vingt-deux heures.",
  "correct": false,
  "explanation": "« J'ai peur que le couloir reste trop bruyant après vingt-deux heures. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Hawa doit-elle aller, d'après le mot ?",
  "options": [
    {
      "text": "Au Marché des Lampions",
      "correct": false
    },
    {
      "text": "À Radio Figuier",
      "correct": false
    },
    {
      "text": "À l'Infirmerie des Herbes",
      "correct": true
    },
    {
      "text": "À Val-des-Peupliers",
      "correct": false
    }
  ],
  "explanation": "« Il faut que tu viennes me voir, Hawa, à l'Infirmerie des Herbes. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "que vous soyez rentrés",
      "right": "contentement"
    },
    {
      "left": "que le couloir reste",
      "right": "crainte"
    },
    {
      "left": "que chacun pose",
      "right": "obligation"
    },
    {
      "left": "que Léa et Karim parlent",
      "right": "volonté"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe suis contente que vous ___ rentrés. (être)",
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
    "Il",
    "faut",
    "que",
    "tu",
    "viennes",
    "me",
    "voir",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "plaigne",
  "hint": "J'ai peur qu'Hawa se… de la tête : forme de se plaindre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis contente que vous êtes rentrés sans crier, au Pavillon.",
  "correct_sentence": "Je suis contente que vous soyez rentrés sans crier, au Pavillon.",
  "explanation": "Après je suis content(e) que : subjonctif, soyez."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/souci-quotidien.svg",
      "word": "un souci"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/voisin-bruit.svg",
      "word": "un voisin"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/tasse-cassee.svg",
      "word": "une tasse"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/infirmerie-herbes.svg",
      "word": "une infirmerie"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le mot et encadrez chaque que + verbe au subjonctif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le mot collé à la porte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire sa crainte, son souhait',
    'PO',
    $c$Objectif
Exprimer un sentiment ou une volonté avec le subjonctif présent.

Consigne
Répétez les modèles, puis parlez d'un souci du Pavillon.

Support — Modèles d'Aline, banc du saule
Je suis content que tu parles.
Je suis contente qu'il soit rentré.
J'ai peur que le bruit dure.
J'ai peur qu'on se plaigne.
Il faut que nous trouvions un accord.
Il faut que tu viennes tôt.
Je veux que chacun range.
Je veux que vous écriviez un mot.
Il faut que la porte soit fermée.
Je suis content que Félicie propose un thé.
J'ai peur qu'Hawa ait mal.
Je veux que l'on s'écoute.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Après « j'ai peur que », on emploie le subjonctif.",
  "correct": true,
  "explanation": "J'ai peur que le bruit dure / qu'on se plaigne."
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
      "text": "Il faut que tu viens tôt",
      "correct": false
    },
    {
      "text": "Il faut que tu viennes tôt",
      "correct": true
    },
    {
      "text": "Je faut que tu viennes tôt",
      "correct": false
    },
    {
      "text": "Il faut que tu vas tôt",
      "correct": false
    }
  ],
  "explanation": "Il faut que + subjonctif : tu viennes. Toujours il faut."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je suis content que",
      "right": "joie / soulagement"
    },
    {
      "left": "j'ai peur que",
      "right": "crainte"
    },
    {
      "left": "il faut que",
      "right": "nécessité"
    },
    {
      "left": "je veux que",
      "right": "souhait personnel"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'ai peur qu'on se ___. (se plaindre)",
  "answer": "plaigne"
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
    "veux",
    "que",
    "vous",
    "écriviez",
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
  "word": "cherchiez",
  "hint": "Je suis content que vous… un accord : forme de chercher, vous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai peur que le bruit dure trop, et il faut que tu vas t'excuser.",
  "correct_sentence": "J'ai peur que le bruit dure trop, et il faut que tu ailles t'excuser.",
  "explanation": "Aller au subjonctif : que tu ailles (pas tu vas)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/voisin-bruit.svg",
      "word": "un voisin"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/tasse-cassee.svg",
      "word": "une tasse"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/infirmerie-herbes.svg",
      "word": "une infirmerie"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/consequence-sante.svg",
      "word": "une conséquence"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases : deux de chaque structure (content / peur / faut / veux)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les douze modèles, puis deux phrases à vous sur un souci du quotidien."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon mot au voisin',
    'PE',
    $c$Objectif
Écrire un mot poli qui dit une crainte et une solution.

Consigne
Imitez le mot de Léa.

Support — Mot de Léa Niyonzima, enveloppe ocre
Léa Niyonzima
Pavillon du Saule — Rive-des-Saules
Karim, je suis contente que tu lises ce mot sans colère.
J'ai peur que nos voix aient gêné ta porte, hier soir.
Il faut que nous fermions plus tôt, je le sais.
Je veux que tu viennes boire un thé à la Table des Sources.
Je suis contente que Félicie soit d'accord pour le plateau.
Il faut que Hawa se repose : la tasse est tombée près d'elle.
J'ai peur qu'elle ait mal à la tête ; Yvette la verra.
Je veux que l'on trouve un horaire, pas une dispute.
Il faut que le couloir reste calme après vingt-deux heures.
Merci d'avance. Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa veut une dispute avec Karim.",
  "correct": false,
  "explanation": "« Je veux que l'on trouve un horaire, pas une dispute. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que propose Léa à Karim ?",
  "options": [
    {
      "text": "Partir à Val-des-Peupliers",
      "correct": false
    },
    {
      "text": "Crier dans le couloir",
      "correct": false
    },
    {
      "text": "Boire un thé à la Table des Sources",
      "correct": true
    },
    {
      "text": "Casser une tasse",
      "correct": false
    }
  ],
  "explanation": "« Je veux que tu viennes boire un thé à la Table des Sources. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "que tu lises",
      "right": "contentement"
    },
    {
      "left": "que nos voix aient gêné",
      "right": "crainte"
    },
    {
      "left": "que nous fermions",
      "right": "obligation"
    },
    {
      "left": "que tu viennes boire",
      "right": "invitation"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut que nous ___ plus tôt. (fermer)",
  "answer": "fermions"
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
    "que",
    "tu",
    "lises",
    "ce",
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
  "word": "fermions",
  "hint": "Il faut que nous… plus tôt : forme de fermer au subjonctif, nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis contente que tu lis ce mot sans colère, près du saule.",
  "correct_sentence": "Je suis contente que tu lises ce mot sans colère, près du saule.",
  "explanation": "Après je suis contente que : subjonctif, lises."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/tasse-cassee.svg",
      "word": "une tasse"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/infirmerie-herbes.svg",
      "word": "une infirmerie"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/consequence-sante.svg",
      "word": "une conséquence"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/thermometre-hawa.svg",
      "word": "un thermomètre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : dix lignes, au moins un content que, un peur que, deux il faut que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot au voisin, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Subjonctif des sentiments',
    'EL',
    $c$Objectif
Retenir le subjonctif après je suis content que, j'ai peur que, il faut que, je veux que.

Consigne
Apprenez la fiche.

Support — Fiche du Cahier du chemin
Sentiment / volonté / obligation + que → subjonctif présent.
Je suis content(e) que tu parles / qu'il soit rentré / que vous soyez calmes.
J'ai peur que le bruit dure / qu'on se plaigne / qu'elle ait mal.
Il faut que nous trouvions / que tu viennes / qu'il fasse silence.
Je veux que chacun range / que vous écriviez / qu'on s'écoute.
être : que je sois, que tu sois, qu'il soit, que nous soyons, que vous soyez, qu'ils soient
avoir : que j'aie, que tu aies, qu'il ait, que nous ayons
aller : que j'aille, que tu ailles, qu'il aille, que nous allions
faire : que je fasse, que nous fassions / venir : que tu viennes
Toujours : il faut (pas je faut, pas ils faut).
On ne dit pas : je suis content que tu viens. On dit : que tu viennes.
Ne explétif possible : j'ai peur qu'il ne tombe (soutenu).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je faut que tu viennes ».",
  "correct": false,
  "explanation": "Toujours il faut, 3e personne du singulier."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Aller » au subjonctif, tu :",
  "options": [
    {
      "text": "vas",
      "correct": false
    },
    {
      "text": "ailles",
      "correct": true
    },
    {
      "text": "iras",
      "correct": false
    },
    {
      "text": "allais",
      "correct": false
    }
  ],
  "explanation": "Que tu ailles."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "que tu sois",
      "right": "être"
    },
    {
      "left": "que tu ailles",
      "right": "aller"
    },
    {
      "left": "que nous fassions",
      "right": "faire"
    },
    {
      "left": "que tu viennes",
      "right": "venir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut que tu ___ prudent. (être)",
  "answer": "sois"
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
    "qu'il",
    "soit",
    "rentré",
    "."
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
  "hint": "Il faut que vous… calmes : forme d'être au subjonctif, vous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ils faut que vous soyez calmes après vingt-deux heures, au Pavillon.",
  "correct_sentence": "Il faut que vous soyez calmes après vingt-deux heures, au Pavillon.",
  "explanation": "Il faut reste au singulier : il faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/infirmerie-herbes.svg",
      "word": "une infirmerie"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/consequence-sante.svg",
      "word": "une conséquence"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/thermometre-hawa.svg",
      "word": "un thermomètre"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/conseil-yvette.svg",
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
  "prompt": "Tableau : six verbes (être, avoir, aller, faire, venir, trouver) au subjonctif tu / nous / il."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis six exemples à vous."
}$j$::jsonb,
    9
  );

  -- ===== Anticiper un problème de santé =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Anticiper un problème de santé'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Anticiper un problème de santé', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Hawa à l''Infirmerie des Herbes',
    'CO',
    $c$Objectif
Comprendre un souci de santé et les marqueurs de conséquence : donc, alors, si bien que, c'est pourquoi.

Consigne
Lisez le dialogue. Qu'est-ce qui entraîne quoi ?

Support — Infirmerie des Herbes, banc de Yvette
Yvette : Tu as de la fièvre, Hawa, donc tu restes ici jusqu'à midi.
Hawa : J'ai trop marché hier, alors j'ai mal à la gorge ce matin.
Léa : Elle n'a pas dormi, si bien que sa voix est cassée.
Patrick : C'est pourquoi nous avons prévenu Aline, à la Maison des Vents.
Marc : Le thermomètre monte, donc on n'envoie personne au Marché.
Joël : Tu tousses, alors tu bois la tisane de Yvette, sans discuter.
Rose : Hawa a glissé près de la tasse, si bien que le coude est marqué.
Aline : C'est pourquoi il faut de l'ombre et du silence, pas Radio Figuier.
Karim : Elle a trop porté le bac, donc le dos proteste.
Félicie : Je prépare un bouillon, alors tu manges lentement.
Lila : La fièvre tombe un peu, si bien que Yvette sourit enfin.
Dieudonné : C'est pourquoi on reporte la visite à Rive-des-Saules.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa doit rester à l'infirmerie jusqu'à midi.",
  "correct": true,
  "explanation": "Yvette : « donc tu restes ici jusqu'à midi. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi a-t-on prévenu Aline ?",
  "options": [
    {
      "text": "Parce que Karim est en colère",
      "correct": false
    },
    {
      "text": "Parce que Hawa n'a pas dormi et que sa voix est cassée",
      "correct": true
    },
    {
      "text": "Parce que le marché est fermé",
      "correct": false
    },
    {
      "text": "Parce que Dieudonné part",
      "correct": false
    }
  ],
  "explanation": "Léa : voix cassée. Patrick : « C'est pourquoi nous avons prévenu Aline. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "donc tu restes",
      "right": "fièvre → repos"
    },
    {
      "left": "alors j'ai mal",
      "right": "marche → gorge"
    },
    {
      "left": "si bien que sa voix",
      "right": "insomnie → voix cassée"
    },
    {
      "left": "c'est pourquoi",
      "right": "on a prévenu Aline"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTu as de la fièvre, ___ tu restes ici.",
  "answer": "donc"
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
    "tousses",
    "alors",
    "tu",
    "bois",
    "la",
    "tisane",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "fievre",
  "hint": "Hawa a trop chaud ; le thermomètre monte (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tu as de la fièvre, donc tu restes ici jusqu'à midi, et ils faut de l'ombre.",
  "correct_sentence": "Tu as de la fièvre, donc tu restes ici jusqu'à midi, et il faut de l'ombre.",
  "explanation": "Il faut au singulier, même avec plusieurs causes."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/consequence-sante.svg",
      "word": "une conséquence"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/thermometre-hawa.svg",
      "word": "un thermomètre"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/conseil-yvette.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/formulaire-admin.svg",
      "word": "un formulaire"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez quatre enchaînements : cause → donc / alors / si bien que / c'est pourquoi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Tu as de la fièvre, donc tu restes. Elle n'a pas dormi, si bien que sa voix est cassée. C'est pourquoi nous avons prévenu Aline."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fiche de Yvette Mukeshimana',
    'CE',
    $c$Objectif
Lire une fiche de santé qui enchaîne causes et conséquences.

Consigne
Lisez la fiche, sans aller trop vite.

Support — Cahier de l'Infirmerie des Herbes
Fiche Hawa Diallo — Pavillon du Saule
Température haute le matin, donc repos jusqu'à quatorze heures.
Toux sèche, alors tisane des herbes toutes les deux heures.
Peu de sommeil, si bien que la voix reste fragile.
C'est pourquoi Radio Figuier attendra : pas de micro aujourd'hui.
Le coude est marqué, donc on évite de porter le bac.
Elle a trop marché vers Rive-des-Saules, alors les pieds brûlent.
Yvette demande le silence, si bien que Joël ferme la porte.
C'est pourquoi Léa apporte le bouillon de Félicie, pas un plat épicé.
Si la fièvre monte encore, alors on prévient Solange au Bureau des Escales.
Hawa a soif, donc l'eau du Seuil reste à portée.
Elle sourit un peu, si bien que Marc range le thermomètre.
C'est pourquoi la visite à Val-des-Peupliers est reportée à jeudi.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa peut prendre le micro de Radio Figuier aujourd'hui.",
  "correct": false,
  "explanation": "« C'est pourquoi Radio Figuier attendra : pas de micro aujourd'hui. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que doit boire Hawa toutes les deux heures ?",
  "options": [
    {
      "text": "Un café trop fort",
      "correct": false
    },
    {
      "text": "La tisane des herbes",
      "correct": true
    },
    {
      "text": "Le thé du Marché seulement",
      "correct": false
    },
    {
      "text": "Rien du tout",
      "correct": false
    }
  ],
  "explanation": "« alors tisane des herbes toutes les deux heures. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "donc repos",
      "right": "température"
    },
    {
      "left": "alors tisane",
      "right": "toux"
    },
    {
      "left": "si bien que la voix",
      "right": "peu de sommeil"
    },
    {
      "left": "c'est pourquoi",
      "right": "pas de micro"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPeu de sommeil, si bien ___ la voix reste fragile.",
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
    "pourquoi",
    "la",
    "visite",
    "est",
    "reportée",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tisane",
  "hint": "Yvette la verse : infusion d'herbes de l'infirmerie."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Peu de sommeil, si bien que la voix reste fragile, donc ils faut le silence.",
  "correct_sentence": "Peu de sommeil, si bien que la voix reste fragile, donc il faut le silence.",
  "explanation": "Il faut : toujours 3e personne du singulier."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/thermometre-hawa.svg",
      "word": "un thermomètre"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/conseil-yvette.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/formulaire-admin.svg",
      "word": "un formulaire"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/imperatif-pronoms.svg",
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
  "prompt": "Recopiez la fiche et soulignez donc, alors, si bien que, c'est pourquoi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la fiche de Yvette, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire donc, alors, si bien que',
    'PO',
    $c$Objectif
Enchaîner un problème de santé et sa conséquence à voix haute.

Consigne
Répétez, puis parlez d'un petit mal du Seuil.

Support — Modèles de Yvette
Tu as de la fièvre, donc tu te reposes.
Tu tousses, alors tu bois.
Tu n'as pas dormi, si bien que ta voix casse.
C'est pourquoi on ferme la porte.
Le dos proteste, donc tu ne portes plus le bac.
Les pieds brûlent, alors tu t'assieds.
La fièvre tombe, si bien que je souris.
C'est pourquoi la visite attend.
Tu as soif, donc tu bois l'eau du Seuil.
Tu parles trop, alors tu te tais un peu.
Le silence aide, si bien que le mal recule.
C'est pourquoi Aline est prévenue.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Si bien que » introduit une conséquence, souvent plus forte.",
  "correct": true,
  "explanation": "Tu n'as pas dormi, si bien que ta voix casse."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel marqueur reprend toute une cause déjà dite ?",
  "options": [
    {
      "text": "donc",
      "correct": false
    },
    {
      "text": "alors",
      "correct": false
    },
    {
      "text": "si bien que",
      "correct": false
    },
    {
      "text": "c'est pourquoi",
      "correct": true
    }
  ],
  "explanation": "C'est pourquoi reprend l'idée précédente."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "donc",
      "right": "conséquence directe"
    },
    {
      "left": "alors",
      "right": "conséquence, parfois conseil"
    },
    {
      "left": "si bien que",
      "right": "conséquence intense"
    },
    {
      "left": "c'est pourquoi",
      "right": "reprise explicative"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTu n'as pas dormi, si bien ___ ta voix casse.",
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
    "Tu",
    "as",
    "de",
    "la",
    "fièvre",
    "donc",
    "tu",
    "te",
    "reposes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "alors",
  "hint": "Tu tousses trop, … tu te reposes : mot de conséquence."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tu n'as pas dormi, si bien ta voix casse, à l'infirmerie des Herbes.",
  "correct_sentence": "Tu n'as pas dormi, si bien que ta voix casse, à l'infirmerie des Herbes.",
  "explanation": "Si bien que : on garde que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/conseil-yvette.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/formulaire-admin.svg",
      "word": "un formulaire"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/imperatif-pronoms.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/discours-indirect.svg",
      "word": "un message"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases : deux donc, deux alors, deux si bien que, deux c'est pourquoi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les douze modèles, puis deux enchaînements à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma fiche santé',
    'PE',
    $c$Objectif
Écrire une courte fiche qui relie un mal et ses conséquences.

Consigne
Imitez la fiche de Patrick.

Support — Fiche de Patrick Habimana
Patrick Habimana
Maison des Vents — relais du Seuil
J'ai trop porté le bois, donc le dos me rappelle d'arrêter.
J'ai marché sans pause, alors les genoux chauffent.
Je n'ai pas bu, si bien que la tête tourne un peu.
C'est pourquoi je passe à l'Infirmerie des Herbes, comme Hawa.
Yvette a mesuré, donc je reste assis une heure.
Je tousse à peine, alors je prends la tisane quand même.
Le silence m'aide, si bien que je peux écrire ce mot.
C'est pourquoi je reporte le minibus vers Val-des-Peupliers.
Léa m'apporte de l'eau, donc je ne me lève pas.
Aline est prévenue, alors personne ne m'attend au Bureau.
Patrick
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick reporte le minibus vers Val-des-Peupliers.",
  "correct": true,
  "explanation": "« C'est pourquoi je reporte le minibus vers Val-des-Peupliers. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi Patrick passe-t-il à l'infirmerie ?",
  "options": [
    {
      "text": "Pour chercher un tampon",
      "correct": false
    },
    {
      "text": "Parce qu'il a trop porté, marché, et pas assez bu",
      "correct": true
    },
    {
      "text": "Pour crier après Karim",
      "correct": false
    },
    {
      "text": "Pour danser au marché",
      "correct": false
    }
  ],
  "explanation": "Les trois premières lignes : dos, genoux, tête → c'est pourquoi l'infirmerie."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "donc le dos",
      "right": "trop porté"
    },
    {
      "left": "alors les genoux",
      "right": "sans pause"
    },
    {
      "left": "si bien que la tête",
      "right": "pas bu"
    },
    {
      "left": "c'est pourquoi",
      "right": "infirmerie"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe n'ai pas bu, si bien que la tête ___.",
  "answer": "tourne"
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
    "pourquoi",
    "je",
    "reste",
    "assis",
    "une",
    "heure",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pourquoi",
  "hint": "C'est… Hawa reste : on explique le lien de cause."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai trop porté le bois, donc le dos me rappelle d'arrêter, et je suis content que Yvette est là.",
  "correct_sentence": "J'ai trop porté le bois, donc le dos me rappelle d'arrêter, et je suis content que Yvette soit là.",
  "explanation": "Je suis content que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/formulaire-admin.svg",
      "word": "un formulaire"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/imperatif-pronoms.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/discours-indirect.svg",
      "word": "un message"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/tampon-bureau.svg",
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
  "prompt": "Imitez : dix lignes, les quatre marqueurs de conséquence au moins une fois."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre fiche santé, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Marqueurs de conséquence',
    'EL',
    $c$Objectif
Retenir donc, alors, si bien que, c'est pourquoi.

Consigne
Apprenez la fiche.

Support — Fiche de Yvette
Conséquence : ce qui suit une cause.
donc : tu as de la fièvre, donc tu te reposes. (direct, souvent après une virgule)
alors : tu tousses, alors tu bois. (conséquence ou conseil immédiat)
si bien que + indicative : elle n'a pas dormi, si bien que sa voix casse.
c'est pourquoi + phrase : reprise de toute la cause. C'est pourquoi on ferme.
Ne pas confondre : parce que (cause) / donc (conséquence).
On ne dit pas : si bien ta voix casse. On dit : si bien que.
alors ≠ à l'heure (ce n'est pas un moment ici).
Lexique santé : fièvre, toux, gorge, tisane, thermomètre, repos, silence.
Il faut + infinitif : il faut se reposer (pas je faut).
Si l'on ajoute que : il faut que tu te reposes (subjonctif).
Phrase trop longue : on coupe, on garde un seul marqueur par lien.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Parce que » et « donc » disent la même chose.",
  "correct": false,
  "explanation": "Parce que = cause. Donc = conséquence."
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
      "text": "Si bien ta voix casse",
      "correct": false
    },
    {
      "text": "Si bien que ta voix casse",
      "correct": true
    },
    {
      "text": "Si bien de ta voix casse",
      "correct": false
    },
    {
      "text": "Si bien à ta voix casse",
      "correct": false
    }
  ],
  "explanation": "Si bien que + phrase."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "donc",
      "right": "lien court"
    },
    {
      "left": "alors",
      "right": "suite immédiate"
    },
    {
      "left": "si bien que",
      "right": "résultat fort"
    },
    {
      "left": "c'est pourquoi",
      "right": "explication reprise"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nElle n'a pas dormi, ___ bien que sa voix casse.",
  "answer": "si"
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
    "as",
    "de",
    "la",
    "fièvre",
    "donc",
    "tu",
    "te",
    "reposes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lien",
  "hint": "Donc, alors, si bien que : ils marquent un… de cause à effet."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Hawa tousse trop, parce que donc elle boit la tisane à l'infirmerie.",
  "correct_sentence": "Hawa tousse trop, donc elle boit la tisane à l'infirmerie.",
  "explanation": "Un seul marqueur : donc (conséquence), pas parce que donc."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/imperatif-pronoms.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/discours-indirect.svg",
      "word": "un message"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/tampon-bureau.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/negation-gouts.svg",
      "word": "un goût"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez un mini-tableau : quatre marqueurs, une phrase santé chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et quatre exemples de conséquence."
}$j$::jsonb,
    9
  );

  -- ===== Des papiers à remplir =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Des papiers à remplir'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Des papiers à remplir', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Au Bureau des Escales',
    'CO',
    $c$Objectif
Repérer l'impératif avec pronoms et le discours indirect : il m'a dit de, elle demande si.

Consigne
Lisez le dialogue. Qui dit de faire quoi ? Qui demande si… ?

Support — Guichet de Solange Mukamana, Val-des-Peupliers
Solange : Remplissez-le, le formulaire. Donnez-le-moi ensuite.
Karim : Apportez-les-moi, les photos. Ne les jetez pas.
Léa : Il m'a dit de signer ici, pas là-bas.
Patrick : Elle demande si j'ai une pièce ocre, pour le tampon.
Aline : Dites-lui la date. Répétez-la-lui, sans aller trop vite.
Marc : Solange m'a dit de photocopier la page, deux fois.
Hawa : Karim demande si je peux attendre jusqu'à midi.
Joël : Ne me le cachez pas, le tarif. Expliquez-le-nous.
Rose : On m'a dit de revenir jeudi, au Bureau des Escales.
Lila : Elle demande si le Pavillon du Saule est bien notre adresse.
Dieudonné : Donnez-les-leur, les copies, à Solange et à Karim.
Félicie : Il m'a dit de ne pas plier le papier encore humide.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Solange veut le formulaire après qu'on l'a rempli.",
  "correct": true,
  "explanation": "« Remplissez-le. Donnez-le-moi ensuite. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que signifie « Il m'a dit de signer ici » ?",
  "options": [
    {
      "text": "Il a signé à la place de Léa",
      "correct": false
    },
    {
      "text": "On a rapporté un ordre : signer ici",
      "correct": true
    },
    {
      "text": "Léa demande si elle signe",
      "correct": false
    },
    {
      "text": "Karim jette les photos",
      "correct": false
    }
  ],
  "explanation": "Discours indirect : dire de + infinitif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "donnez-le-moi",
      "right": "impératif + pronoms"
    },
    {
      "left": "ne les jetez pas",
      "right": "impératif négatif"
    },
    {
      "left": "il m'a dit de signer",
      "right": "ordre rapporté"
    },
    {
      "left": "elle demande si",
      "right": "question rapportée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl m'a dit ___ signer ici.",
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
    "Donnez-le-moi",
    "ensuite",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tampon",
  "hint": "Karim le pose sur le dossier, à l'encre ocre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Solange m'a dit que je signe ici, pas là-bas, au Bureau des Escales.",
  "correct_sentence": "Solange m'a dit de signer ici, pas là-bas, au Bureau des Escales.",
  "explanation": "Ordre rapporté : dire de + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/discours-indirect.svg",
      "word": "un message"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/tampon-bureau.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/negation-gouts.svg",
      "word": "un goût"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/deux-facon-vivre.svg",
      "word": "une façon"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez trois impératifs avec pronoms et deux paroles rapportées."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Donnez-le-moi. Apportez-les-moi. Il m'a dit de signer. Elle demande si j'ai une pièce."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Consigne du tampon ocre',
    'CE',
    $c$Objectif
Lire des formalités : impératif pronominal et paroles rapportées.

Consigne
Lisez la consigne, sans aller trop vite.

Support — Affiche du Bureau des Escales
Bureau des Escales — Val-des-Peupliers (ville inventée)
Remplissez-le à l'encre, le cadre du haut.
Apportez-les-nous, les deux photocopies, avant onze heures.
Ne les pliez pas. Donnez-les-moi à plat.
Solange Mukamana a dit de signer au bas, pas en marge.
Karim Bamba demande si l'adresse du Pavillon du Saule est complète.
Dites-lui votre nom. Épelez-le-lui si besoin.
On nous a dit de ne pas coller la photo trop tôt : le tampon d'abord.
Elle demande si Hawa peut attendre, à cause de l'infirmerie.
Rapportez-le-moi, le dossier, dès que Yvette aura signé le verso.
Ne me le rendez pas incomplet. Vérifiez-le avant.
Lila Sow a dit de garder une copie au Cahier du chemin.
Joël : on m'a demandé si le minibus Figuier 7 passait jeudi.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On colle la photo avant le tampon.",
  "correct": false,
  "explanation": "« Ne pas coller la photo trop tôt : le tampon d'abord. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui demande si l'adresse du Pavillon est complète ?",
  "options": [
    {
      "text": "Solange",
      "correct": false
    },
    {
      "text": "Yvette",
      "correct": false
    },
    {
      "text": "Karim Bamba",
      "correct": true
    },
    {
      "text": "Félicie",
      "correct": false
    }
  ],
  "explanation": "« Karim Bamba demande si l'adresse du Pavillon du Saule est complète. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "remplissez-le",
      "right": "cadre du haut"
    },
    {
      "left": "apportez-les-nous",
      "right": "photocopies"
    },
    {
      "left": "a dit de signer",
      "right": "Solange"
    },
    {
      "left": "demande si l'adresse",
      "right": "Karim"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nKarim demande ___ l'adresse est complète.",
  "answer": "si"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ne",
    "les",
    "pliez",
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
  "word": "photocopie",
  "hint": "Il en faut deux : une reproduction du papier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Karim demande est-ce que l'adresse du Pavillon est complète, ce matin.",
  "correct_sentence": "Karim demande si l'adresse du Pavillon est complète, ce matin.",
  "explanation": "Question rapportée : demander si (pas est-ce que après demander)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/tampon-bureau.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/negation-gouts.svg",
      "word": "un goût"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/deux-facon-vivre.svg",
      "word": "une façon"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/marche-lampions.svg",
      "word": "un marché"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez six consignes et transformez-en deux en discours indirect."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la consigne du tampon ocre, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Donnez-le-moi, il m''a dit de',
    'PO',
    $c$Objectif
Placer les pronoms à l'impératif et rapporter un ordre ou une question.

Consigne
Répétez, puis parlez d'une démarche à vous.

Support — Modèles de Solange
Remplissez-le.
Donnez-le-moi.
Apportez-les-nous.
Ne les jetez pas.
Dites-lui la date.
Répétez-la-lui.
Il m'a dit de signer.
Elle demande si j'ai une photo.
On m'a dit de revenir jeudi.
Ne me le cachez pas.
Expliquez-le-nous.
Il m'a dit de ne pas plier.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "À l'impératif affirmatif, le pronom se colle après le verbe.",
  "correct": true,
  "explanation": "Donnez-le-moi. Apportez-les-nous."
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
      "text": "Donnez-moi-le",
      "correct": false
    },
    {
      "text": "Donnez-le-moi",
      "correct": true
    },
    {
      "text": "Le donnez-moi",
      "correct": false
    },
    {
      "text": "Donnez moi le",
      "correct": false
    }
  ],
  "explanation": "COD (le) avant COI (moi) : donnez-le-moi."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "verbe-le-moi",
      "right": "impératif affirmatif"
    },
    {
      "left": "ne les + verbe pas",
      "right": "impératif négatif"
    },
    {
      "left": "dire de + infinitif",
      "right": "ordre rapporté"
    },
    {
      "left": "demander si + phrase",
      "right": "question rapportée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDonnez-___-moi. (le formulaire)",
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
    "m'a",
    "dit",
    "de",
    "signer",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "apportez",
  "hint": "…-les-moi : forme de apporter à l'impératif, vous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Donnez-moi-le ensuite, au guichet de Solange, sans attendre.",
  "correct_sentence": "Donnez-le-moi ensuite, au guichet de Solange, sans attendre.",
  "explanation": "À l'impératif : le avant moi."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/negation-gouts.svg",
      "word": "un goût"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/deux-facon-vivre.svg",
      "word": "une façon"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/marche-lampions.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/panier-nuance.svg",
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
  "prompt": "Écrivez six impératifs avec pronoms et quatre paroles rapportées."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les douze modèles, puis deux consignes à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma liste de formalités',
    'PE',
    $c$Objectif
Écrire des consignes et des paroles rapportées pour un dossier.

Consigne
Imitez la liste de Marc.

Support — Liste de Marc Nkurunziza
Marc Nkurunziza
Bureau des Escales — dossier Pavillon du Saule
Remplissez-le avant dix heures. Donnez-le-moi ensuite.
Apportez-les-nous, les photos. Ne les pliez pas.
Solange m'a dit de signer au bas, à l'encre ocre.
Karim demande si l'adresse de Rive-des-Saules est exacte.
Dites-lui mon nom. Épelez-le-lui, s'il lève le sourcil.
On m'a dit de photocopier la page de Yvette, le verso santé.
Elle demande si Hawa peut venir demain, pas aujourd'hui.
Rapportez-le-moi dès que le tampon est sec.
Ne me le rendez pas sans copie. Vérifiez-le.
Marc
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc dit de plier les photos.",
  "correct": false,
  "explanation": "« Ne les pliez pas. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que demande Karim, d'après Marc ?",
  "options": [
    {
      "text": "Si le thé est prêt",
      "correct": false
    },
    {
      "text": "Si l'adresse de Rive-des-Saules est exacte",
      "correct": true
    },
    {
      "text": "Si Dieudonné danse",
      "correct": false
    },
    {
      "text": "Si la radio joue",
      "correct": false
    }
  ],
  "explanation": "« Karim demande si l'adresse de Rive-des-Saules est exacte. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "remplissez-le",
      "right": "avant dix heures"
    },
    {
      "left": "a dit de signer",
      "right": "Solange"
    },
    {
      "left": "demande si l'adresse",
      "right": "Karim"
    },
    {
      "left": "a dit de photocopier",
      "right": "verso santé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSolange m'a dit ___ signer au bas.",
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
    "Ne",
    "les",
    "pliez",
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
  "word": "demander",
  "hint": "Elle veut savoir si : le verbe… si."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Karim demande si est-ce que l'adresse de Rive-des-Saules est exacte.",
  "correct_sentence": "Karim demande si l'adresse de Rive-des-Saules est exacte.",
  "explanation": "Une seule interrogation : demander si + phrase, sans est-ce que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/deux-facon-vivre.svg",
      "word": "une façon"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/marche-lampions.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/panier-nuance.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/rythme-jours.svg",
      "word": "un rythme"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : dix lignes, trois impératifs à pronoms et trois discours indirects."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre liste de formalités, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Impératif pronominal et discours indirect',
    'EL',
    $c$Objectif
Retenir l'ordre des pronoms et les structures il m'a dit de / elle demande si.

Consigne
Apprenez la fiche.

Support — Fiche de Solange
Impératif affirmatif : verbe-pronom-pronom. Donnez-le-moi. Apportez-les-nous.
Ordre : le / la / les avant moi / toi / lui / nous / vous / leur.
Traits d'union. Moi, toi (pas me, te) après le verbe : donne-le-moi.
Impératif négatif : pronoms avant le verbe. Ne le lui donnez pas. Ne les jetez pas.
Discours indirect — ordre : il m'a dit de + infinitif. Elle m'a dit de ne pas plier.
Discours indirect — question oui/non : elle demande si + indicative.
On ne dit pas : il m'a dit que je signe (ordre). On dit : il m'a dit de signer.
On ne dit pas : elle demande est-ce que. On dit : elle demande si.
Présent de report : on garde le présent si l'info reste vraie.
Attention : dites-lui (pas dites-le à lui, trop lourd ici).
Épelez-le-lui : le = le nom, lui = à Karim.
Toujours il faut : il faut signer (infinitif) / il faut que tu signes (subj.).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « donnez-moi-le ».",
  "correct": false,
  "explanation": "Donnez-le-moi : le avant moi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Elle m'a dit de revenir » rapporte…",
  "options": [
    {
      "text": "une question",
      "correct": false
    },
    {
      "text": "un ordre ou un conseil",
      "correct": true
    },
    {
      "text": "une comparaison",
      "correct": false
    },
    {
      "text": "un souhait sans verbe",
      "correct": false
    }
  ],
  "explanation": "Dire de + infinitif = ordre / conseil rapporté."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "donnez-le-moi",
      "right": "affirmatif"
    },
    {
      "left": "ne le lui donnez pas",
      "right": "négatif"
    },
    {
      "left": "dit de + inf.",
      "right": "ordre rapporté"
    },
    {
      "left": "demande si",
      "right": "question rapportée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNe ___ jetez pas. (les photos)",
  "answer": "les"
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
    "demande",
    "si",
    "j'ai",
    "une",
    "photo",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ordre",
  "hint": "Donnez-le-moi : le… des pronoms à l'impératif."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ne jetez-les pas trop vite, près du tampon ocre du bureau.",
  "correct_sentence": "Ne les jetez pas trop vite, près du tampon ocre du bureau.",
  "explanation": "À l'impératif négatif, le pronom passe avant le verbe."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/marche-lampions.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/panier-nuance.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/rythme-jours.svg",
      "word": "un rythme"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/horloge-habitude.svg",
      "word": "une habitude"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez : Donnez le dossier à Solange. / Karim : « Signez ! » / Solange : « Avez-vous une photo ? »"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six transformations."
}$j$::jsonb,
    9
  );

  -- ===== Goûts et façons de vivre =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Goûts et façons de vivre'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Goûts et façons de vivre', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Autour de la Table des Sources',
    'CO',
    $c$Objectif
Repérer ne… que, ne… plus, ne… jamais, ne… ni… ni, ne… pas encore, sans.

Consigne
Lisez le dialogue. Qui n'aime quoi ? Qui a changé ?

Support — Table des Sources, midi
Félicie : Je ne prends que du thé le matin, jamais de café trop fort.
Dieudonné : Moi, je ne me lève plus à l'aube : le Pavillon a changé mon rythme.
Léa : Je n'achète ni pain trop blanc ni friture, au Marché des Lampions.
Hawa : Je ne sors pas encore le soir : Yvette a dit d'attendre.
Patrick : Je range sans crier, et je n'invite plus d'inconnus dans le couloir.
Aline : Joël ne parle jamais trop fort après vingt-deux heures, maintenant.
Marc : Je n'écoute que Radio Figuier, pas d'autre antenne.
Rose : Je ne couds ni trop vite ni sans lumière, à l'Atelier du Tissu.
Karim : Je n'habite plus seul : le voisinage du saule m'a habitué aux voix.
Lila : Je ne suis pas encore inscrite à Val-des-Peupliers, le tampon attend.
Solange : On n'accepte que les dossiers complets, sans rature.
Yvette : Je ne sers ni plat épicé ni tisane froide, tant que la fièvre dure.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Félicie prend seulement du thé le matin.",
  "correct": true,
  "explanation": "« Je ne prends que du thé le matin. » Ne… que = seulement."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que signifie « je ne sors pas encore le soir », dit par Hawa ?",
  "options": [
    {
      "text": "Elle ne sortira jamais",
      "correct": false
    },
    {
      "text": "Elle sort déjà tous les soirs",
      "correct": false
    },
    {
      "text": "Pour l'instant, elle ne sort pas ; cela pourra changer",
      "correct": true
    },
    {
      "text": "Elle n'a plus de soir",
      "correct": false
    }
  ],
  "explanation": "Ne… pas encore = pas jusqu'à maintenant."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ne… que",
      "right": "seulement"
    },
    {
      "left": "ne… plus",
      "right": "cesser"
    },
    {
      "left": "ne… jamais",
      "right": "à aucun moment"
    },
    {
      "left": "ne… ni… ni",
      "right": "deux refus"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ne prends ___ du thé le matin.",
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
    "n'invite",
    "plus",
    "d'inconnus",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "jamais",
  "hint": "Ne parle… trop fort : à aucun moment."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ne prends que pas du thé le matin, à la Table des Sources.",
  "correct_sentence": "Je ne prends que du thé le matin, à la Table des Sources.",
  "explanation": "Ne… que suffit : pas de pas en plus."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/panier-nuance.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/rythme-jours.svg",
      "word": "un rythme"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/horloge-habitude.svg",
      "word": "une habitude"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/calendrier-changement.svg",
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
  "prompt": "Classez six phrases du dialogue selon la négation employée."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je ne prends que du thé. Je ne me lève plus à l'aube. Je n'achète ni pain ni friture. Je ne sors pas encore."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Cartes de façons de vivre',
    'CE',
    $c$Objectif
Lire des cartes qui nuancent des goûts et des habitudes.

Consigne
Lisez les cartes, sans aller trop vite.

Support — Cartes épinglées au figuier
Carte Félicie — Je ne cuisine que des herbes du Seuil, sans trop de sel.
Carte Dieudonné — Je ne travaille plus à la lumière trop tard : les yeux fatiguent.
Carte Léa — Je n'emporte ni radio ni tambour dans la chambre, pour Karim.
Carte Hawa — Je ne marche pas encore jusqu'à Rive-des-Saules : la gorge d'abord.
Carte Patrick — Je ne laisse jamais la tasse sur le banc, même vide.
Carte Aline — On n'ouvre le Pavillon qu'après le balayage, sans exception.
Carte Marc — Je n'enregistre plus trop fort : Radio Figuier a changé la règle.
Carte Rose — Je ne vends ni tissu trop lourd ni lanterne sans fil, au marché.
Carte Karim — Je n'accepte que les visites annoncées, jamais d'intrus.
Carte Lila — Je ne remplis pas encore le cadre « métier » : j'attends Solange.
Carte Yvette — On ne sert le bouillon que tiède, sans piment.
Carte Joël — Je ne répare plus la moto la nuit, si bien que le voisin dort.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline ouvre le Pavillon seulement après le balayage.",
  "correct": true,
  "explanation": "« On n'ouvre le Pavillon qu'après le balayage. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui ne marche pas encore jusqu'à Rive-des-Saules ?",
  "options": [
    {
      "text": "Dieudonné",
      "correct": false
    },
    {
      "text": "Hawa",
      "correct": true
    },
    {
      "text": "Karim",
      "correct": false
    },
    {
      "text": "Joël",
      "correct": false
    }
  ],
  "explanation": "Carte Hawa : « Je ne marche pas encore jusqu'à Rive-des-Saules. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ne… que des herbes",
      "right": "Félicie"
    },
    {
      "left": "ne… plus à la lumière",
      "right": "Dieudonné"
    },
    {
      "left": "ni radio ni tambour",
      "right": "Léa"
    },
    {
      "left": "pas encore jusqu'à",
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
  "prompt": "Complétez :\nJe ne laisse ___ la tasse sur le banc.",
  "answer": "jamais"
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
    "n'emporte",
    "ni",
    "radio",
    "ni",
    "tambour",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "seulement",
  "hint": "Ne… que du thé : rien d'autre, une idée de restriction."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je n'achète ni pain trop blanc ou friture, au Marché des Lampions.",
  "correct_sentence": "Je n'achète ni pain trop blanc ni friture, au Marché des Lampions.",
  "explanation": "Deux éléments refusés : ni… ni (pas ou)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/rythme-jours.svg",
      "word": "un rythme"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/horloge-habitude.svg",
      "word": "une habitude"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/calendrier-changement.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/banc-pause.svg",
      "word": "une pause"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez quatre cartes et ajoutez la vôtre avec une négation différente."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les douze cartes, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Nuancer un goût',
    'PO',
    $c$Objectif
Comparer et nuancer avec les négations complexes.

Consigne
Répétez, puis parlez de vos façons de vivre au Seuil.

Support — Modèles de Félicie
Je ne prends que du thé.
Je ne bois plus de café le soir.
Je ne crie jamais dans le couloir.
Je n'aime ni le bruit ni la friture.
Je ne sors pas encore tard.
Je range sans crier.
Je n'invite plus d'inconnus.
Je n'écoute que Radio Figuier.
Je ne couds jamais sans lumière.
Je n'habite plus seul.
Je ne suis pas encore inscrite.
On n'accepte que les dossiers complets.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Sans » peut nuancer une façon de faire, sans ne.",
  "correct": true,
  "explanation": "Je range sans crier. Sans + infinitif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase exprime une restriction (seulement) ?",
  "options": [
    {
      "text": "Je ne crie jamais",
      "correct": false
    },
    {
      "text": "Je ne prends que du thé",
      "correct": true
    },
    {
      "text": "Je n'aime ni le bruit ni la friture",
      "correct": false
    },
    {
      "text": "Je ne sors pas encore",
      "correct": false
    }
  ],
  "explanation": "Ne… que = seulement."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ne… que",
      "right": "restriction"
    },
    {
      "left": "ne… plus",
      "right": "changement"
    },
    {
      "left": "ne… pas encore",
      "right": "attente"
    },
    {
      "left": "sans + infinitif",
      "right": "manière"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe n'aime ___ le bruit ni la friture.",
  "answer": "ni"
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
    "range",
    "sans",
    "crier",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "encore",
  "hint": "Pas… : l'action n'a pas eu lieu jusqu'ici."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ne prends que du thé le matin, et je suis content que Félicie est d'accord.",
  "correct_sentence": "Je ne prends que du thé le matin, et je suis content que Félicie soit d'accord.",
  "explanation": "Je suis content que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/horloge-habitude.svg",
      "word": "une habitude"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/calendrier-changement.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/banc-pause.svg",
      "word": "une pause"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/voisinage-tisser.svg",
      "word": "un voisinage"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases, une pour chaque négation de la fiche."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les douze modèles, puis trois nuances à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma carte de goûts',
    'PE',
    $c$Objectif
Écrire une carte qui dit ce que l'on fait, ce que l'on ne fait plus, ce que l'on n'accepte pas.

Consigne
Imitez la carte de Rose.

Support — Carte de Rose Iradukunda
Rose Iradukunda
Atelier du Tissu — Pavillon du Saule
Je ne vends que des lanternes cousues ici, sans fil trop fragile.
Je ne travaille plus à minuit : le voisinage a besoin d'ombre.
Je n'accepte ni tissu trop lourd ni teinture trop vive, pour la veillée.
Je ne montre pas encore la cape ocre : Dieudonné la finit jeudi.
Je ne crie jamais quand une aiguille tombe, même si j'ai peur.
Je range sans bousculer les paniers du Marché des Lampions.
Léa n'emporte plus le tambour dans la chambre, c'est entendu.
Je ne suis pas encore à Val-des-Peupliers : le minibus attendra.
On n'ouvre l'atelier qu'après le thé de Félicie.
Rose
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose travaille encore à minuit.",
  "correct": false,
  "explanation": "« Je ne travaille plus à minuit. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que refuse Rose pour la veillée ?",
  "options": [
    {
      "text": "Le thé de Félicie",
      "correct": false
    },
    {
      "text": "Le voisinage",
      "correct": false
    },
    {
      "text": "Le tissu trop lourd et la teinture trop vive",
      "correct": true
    },
    {
      "text": "Les lanternes cousues ici",
      "correct": false
    }
  ],
  "explanation": "« Je n'accepte ni tissu trop lourd ni teinture trop vive. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ne… que des lanternes",
      "right": "restriction"
    },
    {
      "left": "ne… plus à minuit",
      "right": "changement"
    },
    {
      "left": "ni… ni",
      "right": "deux refus"
    },
    {
      "left": "pas encore la cape",
      "right": "attente"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ne travaille ___ à minuit.",
  "answer": "plus"
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
    "range",
    "sans",
    "bousculer",
    "les",
    "paniers",
    "."
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
  "hint": "Rose range sans bousculer les… du marché."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je n'accepte ni tissu trop lourd ni teinture trop vive, bien que la veillée est proche.",
  "correct_sentence": "Je n'accepte ni tissu trop lourd ni teinture trop vive, bien que la veillée soit proche.",
  "explanation": "Bien que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/calendrier-changement.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/banc-pause.svg",
      "word": "une pause"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/voisinage-tisser.svg",
      "word": "un voisinage"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/porte-ouverte.svg",
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
  "prompt": "Imitez : dix lignes, les six formes de négation au moins une fois."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre carte de goûts, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Négations pour nuancer',
    'EL',
    $c$Objectif
Retenir ne… que, ne… plus, ne… jamais, ne… ni… ni, ne… pas encore, sans.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
ne… que = seulement : je ne prends que du thé (pas de pas).
ne… plus = cesser : je ne me lève plus à l'aube.
ne… jamais = à aucun moment : je ne crie jamais.
ne… ni… ni = deux éléments refusés : je n'aime ni le bruit ni la friture.
ne… pas encore = jusqu'ici, non : je ne sors pas encore.
sans + infinitif (pas de ne) : je range sans crier.
Élision : n' devant voyelle (n'aime, n'invite, n'habite).
On ne dit pas : je ne prends que pas. On ne dit pas : ni… ou.
Place : ne + pronom + verbe + que / plus / jamais.
pas encore : pas et encore restent ensemble après le verbe.
Comparer : plus (changement) ≠ pas encore (attente) ≠ jamais (définitif).
Sans ≠ ne… pas : sans crier décrit la manière.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Ne… que » veut dire « jamais ».",
  "correct": false,
  "explanation": "Ne… que = seulement. Jamais = à aucun moment."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est une restriction ?",
  "options": [
    {
      "text": "Je ne crie jamais",
      "correct": false
    },
    {
      "text": "Je ne sors pas encore",
      "correct": false
    },
    {
      "text": "Je ne prends que du thé",
      "correct": true
    },
    {
      "text": "Je n'habite plus seul",
      "correct": false
    }
  ],
  "explanation": "Ne… que = seulement du thé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ne… que",
      "right": "seulement"
    },
    {
      "left": "ne… plus",
      "right": "ne… plus maintenant"
    },
    {
      "left": "ne… pas encore",
      "right": "pas jusqu'ici"
    },
    {
      "left": "sans + inf.",
      "right": "manière"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ne sors ___ encore le soir.",
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
    "ne",
    "prends",
    "que",
    "du",
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
  "word": "restriction",
  "hint": "Ne… que : une… , pas une interdiction totale."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ne prends que du thé le matin, sans de crier dans le couloir.",
  "correct_sentence": "Je ne prends que du thé le matin, sans crier dans le couloir.",
  "explanation": "Sans + infinitif, sans de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/banc-pause.svg",
      "word": "une pause"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/voisinage-tisser.svg",
      "word": "un voisinage"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/porte-ouverte.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/cle-partage.svg",
      "word": "une clé"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez six phrases affirmatives en six négations différentes."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six exemples nuancés."
}$j$::jsonb,
    9
  );

  -- ===== Trouver un rythme =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Trouver un rythme'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Trouver un rythme', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le fil des heures au Pavillon',
    'CO',
    $c$Objectif
Comprendre un échange sur les habitudes qui restent et celles qui changent.

Consigne
Lisez le dialogue. Qu'est-ce qui reste ? Qu'est-ce qui change ?

Support — Banc du Pavillon du Saule, aube
Aline : Je ne me lève plus à cinq heures, donc je suis moins tendue.
Léa : Je suis contente que tu dormes davantage. Il faut que le corps suive.
Patrick : Moi, je garde le thé de l'aube, je n'ai changé que l'heure du courrier.
Marc : J'ai trop enchaîné les dossiers, si bien que le Bureau m'a renvoyé au banc.
Hawa : Je ne marche pas encore jusqu'au marché, alors je m'arrête à l'infirmerie.
Joël : Il faut que nous trouvions une pause commune, pas chacun dans son coin.
Rose : Je ne couds plus le soir, c'est pourquoi la cape avance le matin.
Karim : J'ai peur que le nouveau rythme n'efface les visites. Je veux que l'on se voie.
Félicie : Je ne sers que midi et dix-neuf heures, sans plateau à minuit.
Dieudonné : Je n'allume plus l'atelier trop tard, si bien que Karim dort.
Lila : Solange a dit de dater le calendrier. Elle demande si jeudi reste libre.
Yvette : C'est pourquoi je coche repos, tisane, silence : un rythme, pas une course.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline se lève encore à cinq heures.",
  "correct": false,
  "explanation": "« Je ne me lève plus à cinq heures. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que veut Karim ?",
  "options": [
    {
      "text": "Que l'on cesse de se voir",
      "correct": false
    },
    {
      "text": "Que l'on se voie encore",
      "correct": true
    },
    {
      "text": "Que Radio Figuier joue la nuit",
      "correct": false
    },
    {
      "text": "Que Félicie serve à minuit",
      "correct": false
    }
  ],
  "explanation": "« Je veux que l'on se voie. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ne… plus à cinq heures",
      "right": "changement d'Aline"
    },
    {
      "left": "n'ai changé que l'heure",
      "right": "habitude de Patrick"
    },
    {
      "left": "pas encore jusqu'au marché",
      "right": "limite d'Hawa"
    },
    {
      "left": "a dit de dater",
      "right": "consigne de Solange"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe suis contente que tu ___ davantage. (dormir)",
  "answer": "dormes"
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
    "trouvions",
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
  "word": "rythme",
  "hint": "Le fil des heures, plus calme qu'avant."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis contente que tu dors davantage, au Pavillon du Saule.",
  "correct_sentence": "Je suis contente que tu dormes davantage, au Pavillon du Saule.",
  "explanation": "Dormir au subjonctif : que tu dormes."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/voisinage-tisser.svg",
      "word": "un voisinage"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/porte-ouverte.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/cle-partage.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/table-compromis.svg",
      "word": "un compromis"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Listez trois habitudes gardées et trois changements, avec le marqueur entendu."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je ne me lève plus à cinq heures, donc je suis moins tendue. Il faut que nous trouvions une pause. Je veux que l'on se voie."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Calendrier ocre de Lila',
    'CE',
    $c$Objectif
Lire un calendrier qui oppose routines et ajustements.

Consigne
Lisez le calendrier, sans aller trop vite.

Support — Feuille de Lila Sow, Cahier du chemin
Semaine au Pavillon du Saule
Lundi : thé à l'aube (habitude). Bureau des Escales à dix heures (changement).
Mardi : Hawa à l'infirmerie le matin, donc pas de marché. Silence jusqu'à midi.
Mercredi : Rose ne coud que le matin, si bien que le soir reste au voisinage.
Jeudi : Solange a dit de venir tamponner. Elle demande si Marc apporte les copies.
Vendredi : Joël ne répare plus la moto la nuit, c'est pourquoi Karim dort.
Samedi : Félicie ne sert ni minuit ni plateau froid. Table à dix-neuf heures.
Dimanche : pause commune sous le saule. Il faut que chacun pose son outil.
Je ne date pas encore Val-des-Peupliers : le minibus n'est pas sûr.
Aline n'ouvre plus à cinq heures, alors le couloir reste sombre plus longtemps.
Patrick n'a changé que l'heure du courrier : le thé, lui, n'a pas bougé.
Yvette : repos coché, sans exception, tant que la gorge d'Hawa grince.
Dieudonné : atelier éteint avant vingt-deux heures, pour que le Pavillon souffle.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le dimanche, chacun doit poser son outil.",
  "correct": true,
  "explanation": "« Il faut que chacun pose son outil. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel jour Rose ne coud-elle que le matin ?",
  "options": [
    {
      "text": "Lundi",
      "correct": false
    },
    {
      "text": "Mardi",
      "correct": false
    },
    {
      "text": "Mercredi",
      "correct": true
    },
    {
      "text": "Samedi",
      "correct": false
    }
  ],
  "explanation": "Mercredi : « Rose ne coud que le matin. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "thé à l'aube",
      "right": "habitude"
    },
    {
      "left": "Bureau à dix heures",
      "right": "changement"
    },
    {
      "left": "ne coud que le matin",
      "right": "restriction"
    },
    {
      "left": "a dit de venir",
      "right": "parole rapportée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut que chacun ___ son outil. (poser)",
  "answer": "pose"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Aline",
    "n'ouvre",
    "plus",
    "à",
    "cinq",
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
  "word": "habitude",
  "hint": "Un geste répété chaque matin, devenu naturel."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dieudonné éteint l'atelier avant vingt-deux heures, pour que le Pavillon souffle enfin et que Karim dort.",
  "correct_sentence": "Dieudonné éteint l'atelier avant vingt-deux heures, pour que le Pavillon souffle enfin et que Karim dorme.",
  "explanation": "Pour que + subjonctif : que Karim dorme."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/porte-ouverte.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/cle-partage.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/table-compromis.svg",
      "word": "un compromis"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/pavillon-saule.svg",
      "word": "un pavillon"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez trois jours : une habitude, un changement, une conséquence."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le calendrier ocre de Lila, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire ce qui reste, ce qui change',
    'PO',
    $c$Objectif
Synthétiser habitudes et changements avec les outils des séquences 1 à 4.

Consigne
Répétez, puis parlez de votre rythme au Seuil.

Support — Modèles de Patrick
Je garde le thé de l'aube.
Je n'ai changé que l'heure.
Je ne me lève plus à cinq heures, donc je suis moins tendu.
Il faut que nous trouvions une pause.
Je suis content que tu dormes.
J'ai peur que l'on s'oublie.
On m'a dit de dater le jeudi.
Elle demande si le banc est libre.
Je ne marche pas encore jusqu'au marché.
Je range sans courir.
C'est pourquoi le couloir reste calme.
Je veux que l'on se voie.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut mêler subjonctif, conséquence et négation pour parler d'un rythme.",
  "correct": true,
  "explanation": "Les modèles reprennent les outils des séquences précédentes."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase marque un changement d'habitude ?",
  "options": [
    {
      "text": "Je garde le thé de l'aube",
      "correct": false
    },
    {
      "text": "Je ne me lève plus à cinq heures",
      "correct": true
    },
    {
      "text": "Elle demande si le banc est libre",
      "correct": false
    },
    {
      "text": "Je range sans courir",
      "correct": false
    }
  ],
  "explanation": "Ne… plus = on ne le fait plus."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je garde",
      "right": "habitude"
    },
    {
      "left": "ne… plus",
      "right": "changement"
    },
    {
      "left": "n'ai changé que",
      "right": "petit ajustement"
    },
    {
      "left": "il faut que nous trouvions",
      "right": "objectif commun"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe n'ai changé ___ l'heure.",
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
    "veux",
    "que",
    "l'on",
    "se",
    "voie",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "changer",
  "hint": "On veut… d'horaire : ne plus faire comme avant."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut que nous trouvons une pause commune, sous le saule, avant midi.",
  "correct_sentence": "Il faut que nous trouvions une pause commune, sous le saule, avant midi.",
  "explanation": "Il faut que + subjonctif : trouvions."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/cle-partage.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/table-compromis.svg",
      "word": "un compromis"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/pavillon-saule.svg",
      "word": "un pavillon"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/cahier-chemin.svg",
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
  "prompt": "Écrivez dix phrases : cinq habitudes, cinq changements, en variant les structures."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les douze modèles, puis votre rythme en six phrases."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma page de rythme',
    'PE',
    $c$Objectif
Écrire une page qui dit ce que l'on garde, ce que l'on change, et pourquoi.

Consigne
Imitez la page de Joël.

Support — Page de Joël Mugisha
Joël Mugisha
Pavillon du Saule — Rive-des-Saules
Je ne répare plus la moto la nuit, donc Karim dort, et je suis content qu'il dorme.
On m'a dit de ranger les outils avant vingt-deux heures. Aline demande si c'est fait.
Je n'ai changé que l'heure, pas le plaisir de l'huile et du silence.
Je ne sors pas encore jusqu'à Val-des-Peupliers : Hawa d'abord, l'infirmerie ensuite.
Il faut que nous trouvions une pause le dimanche, sous le saule.
J'ai peur que le travail n'efface les thés de Félicie, alors je les note.
Je range sans crier. Je n'invite ni client ni passant après le repas.
C'est pourquoi le couloir reste une allée, pas un atelier.
Je veux que Léa vienne voir la moto le matin, pas le soir.
Joël
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël répare encore la moto la nuit.",
  "correct": false,
  "explanation": "« Je ne répare plus la moto la nuit. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que veut Joël ?",
  "options": [
    {
      "text": "Que Léa vienne le soir",
      "correct": false
    },
    {
      "text": "Que Léa vienne le matin",
      "correct": true
    },
    {
      "text": "Que Karim parte",
      "correct": false
    },
    {
      "text": "Que Félicie ferme la table",
      "correct": false
    }
  ],
  "explanation": "« Je veux que Léa vienne voir la moto le matin, pas le soir. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ne… plus la nuit",
      "right": "changement"
    },
    {
      "left": "n'ai changé que l'heure",
      "right": "restriction"
    },
    {
      "left": "a dit de ranger",
      "right": "consigne rapportée"
    },
    {
      "left": "il faut que nous trouvions",
      "right": "pause du dimanche"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe veux que Léa ___ voir la moto le matin. (venir)",
  "answer": "vienne"
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
    "répare",
    "plus",
    "la",
    "moto",
    "la",
    "nuit",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "calendrier",
  "hint": "Les jours marqués : lever, pause, infirmerie."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis content qu'il dort, après vingt-deux heures, au Pavillon du Saule.",
  "correct_sentence": "Je suis content qu'il dorme, après vingt-deux heures, au Pavillon du Saule.",
  "explanation": "Je suis content que + subjonctif : dorme."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/table-compromis.svg",
      "word": "un compromis"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/pavillon-saule.svg",
      "word": "un pavillon"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/cahier-chemin.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/affiche-regle.svg",
      "word": "une règle"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : dix lignes, habitude, changement, conséquence, un que + subjonctif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre page de rythme, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Synthèse habitudes et changement',
    'EL',
    $c$Objectif
Relier subjonctif, conséquence, discours indirect et négation pour parler d'un rythme.

Consigne
Apprenez la fiche.

Support — Fiche du banc
Garder une habitude : présent, parfois ne… que (je n'ai changé que l'heure).
Changer : ne… plus / c'est pourquoi / donc. Je ne me lève plus, donc je suis calme.
Limiter : ne… pas encore. Hawa ne marche pas encore jusqu'au marché.
Sentiment sur le rythme : je suis content que tu dormes / j'ai peur que l'on s'oublie.
Objectif commun : il faut que nous trouvions une pause. Je veux que l'on se voie.
Parole rapportée : on m'a dit de dater. Elle demande si jeudi reste libre.
Pour que + subjonctif (but, déjà utile) : pour que le Pavillon souffle.
Sans + infinitif : ranger sans courir.
Un seul il faut, toujours 3e personne.
Ne pas empiler trop de marqueurs dans la même phrase.
Le calendrier aide : un jour, une phrase, un outil.
On écrit le rythme pour le voisinage, pas pour se juger.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je n'ai changé que l'heure » signifie que presque tout reste.",
  "correct": true,
  "explanation": "Ne… que = seulement l'heure a changé."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle structure pose un objectif commun ?",
  "options": [
    {
      "text": "Je n'écoute que Radio Figuier",
      "correct": false
    },
    {
      "text": "Il faut que nous trouvions une pause",
      "correct": true
    },
    {
      "text": "Je range sans courir",
      "correct": false
    },
    {
      "text": "Elle demande si le banc est libre",
      "correct": false
    }
  ],
  "explanation": "Il faut que + subjonctif, nous."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ne… plus",
      "right": "changement"
    },
    {
      "left": "ne… que",
      "right": "petit écart"
    },
    {
      "left": "il faut que",
      "right": "but du groupe"
    },
    {
      "left": "dit de / demande si",
      "right": "échos des autres"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nHawa ne marche ___ encore jusqu'au marché.",
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
    "C'est",
    "pourquoi",
    "le",
    "couloir",
    "reste",
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
  "word": "synthese",
  "hint": "Cette séquence rassemble les outils déjà vus (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut que nous trouvions une pause, pour que chacun se repose et que Aline est là.",
  "correct_sentence": "Il faut que nous trouvions une pause, pour que chacun se repose et qu'Aline soit là.",
  "explanation": "Pour que + subjonctif : qu'Aline soit là."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/pavillon-saule.svg",
      "word": "un pavillon"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/cahier-chemin.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/affiche-regle.svg",
      "word": "une règle"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/oreille-plainte.svg",
      "word": "une oreille"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez un tableau : habitude / changement / outil grammatical / exemple."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et un rythme personnel en cinq phrases liées."
}$j$::jsonb,
    9
  );

  -- ===== Un voisinage à tisser =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un voisinage à tisser'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un voisinage à tisser', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La clé et la table',
    'CO',
    $c$Objectif
Comprendre une médiation : chacun cède un peu pour que le Pavillon tienne.

Consigne
Lisez le dialogue. Qui cède quoi ? Quel accord sort ?

Support — Table partagée, Pavillon du Saule
Aline : Il faut que chacun parle sans accuser. Je veux que l'on s'écoute.
Karim : J'ai peur que la clé circule trop. Je ne la prête plus à n'importe qui.
Léa : Je suis contente que tu le dises. On peut la poser ici, alors on la voit.
Patrick : Solange m'a dit de noter les allers. Elle demande si le cahier suffit.
Hawa : Je ne sors pas encore tard, donc je n'ai pas besoin de la clé la nuit.
Joël : Je n'entre ni par la fenêtre ni sans frapper. C'est déjà un geste.
Rose : Je ne couds plus après vingt-deux heures, si bien que le couloir se tait.
Marc : C'est pourquoi on range les outils à gauche, les tasses à droite.
Félicie : Je ne sers que deux plateaux. Sans troisième service, je tiens.
Dieudonné : Je veux que la porte reste ouverte le jour, fermée dès l'ombre.
Lila : On m'a dit de recopier l'accord. Je le donnerai au Bureau des Escales.
Yvette : Je suis contente que Hawa s'assoie. Il faut que le banc reste un banc, pas un atelier.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Karim ne veut plus prêter la clé à n'importe qui.",
  "correct": true,
  "explanation": "« Je ne la prête plus à n'importe qui. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Léa propose-t-elle de poser la clé ?",
  "options": [
    {
      "text": "Sous le figuier",
      "correct": false
    },
    {
      "text": "Ici, sur la table, pour qu'on la voie",
      "correct": true
    },
    {
      "text": "À Val-des-Peupliers",
      "correct": false
    },
    {
      "text": "Dans la moto de Joël",
      "correct": false
    }
  ],
  "explanation": "Léa : « On peut la poser ici, alors on la voit. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il faut que chacun parle",
      "right": "règle de médiation"
    },
    {
      "left": "ne la prête plus",
      "right": "limite de Karim"
    },
    {
      "left": "a dit de noter",
      "right": "trace écrite"
    },
    {
      "left": "porte ouverte le jour",
      "right": "compromis de Dieudonné"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe veux que l'on s'___. (s'écouter)",
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
    "Il",
    "faut",
    "que",
    "chacun",
    "parle",
    "sans",
    "accuser",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "partage",
  "hint": "La clé n'est plus à une seule personne : un…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut que chacun parle sans accuser, et je veux que l'on s'écoute pour que Karim est calme.",
  "correct_sentence": "Il faut que chacun parle sans accuser, et je veux que l'on s'écoute pour que Karim soit calme.",
  "explanation": "Pour que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/cahier-chemin.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/affiche-regle.svg",
      "word": "une règle"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/oreille-plainte.svg",
      "word": "une oreille"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/main-aide.svg",
      "word": "une main"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez trois concessions (qui cède quoi) et la phrase d'accord."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il faut que chacun parle sans accuser. Je ne la prête plus à n'importe qui. Je veux que la porte reste ouverte le jour."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Accord du Pavillon du Saule',
    'CE',
    $c$Objectif
Lire un compromis écrit : médiation entre habitants.

Consigne
Lisez l'accord, sans aller trop vite.

Support — Feuille signée, table du saule
Accord du Pavillon du Saule — Rive-des-Saules
1. Il faut que la clé reste sur la table le jour. Karim ne la prête plus dehors.
2. Léa a dit de frapper avant d'entrer. Joël demande si deux coups suffisent.
3. On n'ouvre plus l'atelier après vingt-deux heures, donc le couloir se tait.
4. Félicie ne sert que deux plateaux, sans service de minuit.
5. Hawa ne sort pas encore tard : Yvette garde le banc de l'infirmerie.
6. Dieudonné veut que la porte soit ouverte le jour, fermée dès l'ombre.
7. On range sans empiler les tasses sur les outils. Marc note la gauche et la droite.
8. Solange a dit de déposer une copie au Bureau des Escales, à Val-des-Peupliers.
9. Je suis contente que chacun signe, écrit Aline. J'ai peur qu'un oubli revienne.
10. C'est pourquoi le dimanche reste une pause commune, sous le saule.
11. On n'invite ni passant ni client la nuit.
12. Rose Iradukunda, Lila Sow, Patrick Habimana : signatures ocre.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'atelier peut rester ouvert après vingt-deux heures.",
  "correct": false,
  "explanation": "Point 3 : « On n'ouvre plus l'atelier après vingt-deux heures. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de plateaux Félicie sert-elle ?",
  "options": [
    {
      "text": "Un seul",
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
      "text": "Autant qu'on veut",
      "correct": false
    }
  ],
  "explanation": "« Félicie ne sert que deux plateaux. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "clé sur la table",
      "right": "compromis du jour"
    },
    {
      "left": "frapper avant",
      "right": "consigne de Léa"
    },
    {
      "left": "deux plateaux",
      "right": "limite de Félicie"
    },
    {
      "left": "copie au Bureau",
      "right": "trace chez Solange"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDieudonné veut que la porte ___ ouverte le jour. (être)",
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
    "On",
    "n'invite",
    "ni",
    "passant",
    "ni",
    "client",
    "la",
    "nuit",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "compromis",
  "hint": "Un accord où chacun cède un peu."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dieudonné veut que la porte est ouverte le jour, fermée dès l'ombre, au Pavillon.",
  "correct_sentence": "Dieudonné veut que la porte soit ouverte le jour, fermée dès l'ombre, au Pavillon.",
  "explanation": "Je veux que / il veut que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/affiche-regle.svg",
      "word": "une règle"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/oreille-plainte.svg",
      "word": "une oreille"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/main-aide.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/soleil-installe.svg",
      "word": "un soleil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez l'accord et marquez qui cède, qui gagne, à chaque point."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'accord du Pavillon du Saule, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Proposer un compromis',
    'PO',
    $c$Objectif
Mener une petite médiation à voix haute : dire sa limite, entendre l'autre, proposer.

Consigne
Répétez, puis jouez un accord pour une cour.

Support — Modèles d'Aline
Il faut que chacun parle.
Je veux que l'on s'écoute.
J'ai peur que la clé se perde.
Je ne la prête plus à n'importe qui.
On peut la poser ici, alors on la voit.
On m'a dit de noter les allers.
Elle demande si deux coups suffisent.
Je ne sors pas encore tard, donc je n'en ai pas besoin.
La porte reste ouverte le jour, fermée dès l'ombre.
Je ne sers que deux plateaux.
On n'invite ni passant ni client la nuit.
Je suis contente que chacun signe.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Un compromis nomme une limite et une contrepartie.",
  "correct": true,
  "explanation": "Clé sur la table le jour / pas prêtée dehors, par exemple."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase ouvre la médiation sans accuser ?",
  "options": [
    {
      "text": "C'est de ta faute",
      "correct": false
    },
    {
      "text": "Il faut que chacun parle",
      "correct": true
    },
    {
      "text": "Je ne te parle plus",
      "correct": false
    },
    {
      "text": "Sors d'ici",
      "correct": false
    }
  ],
  "explanation": "Aline : chacun parle, on s'écoute."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il faut que chacun",
      "right": "cadre"
    },
    {
      "left": "je ne… plus",
      "right": "limite"
    },
    {
      "left": "on peut… alors",
      "right": "proposition"
    },
    {
      "left": "je suis contente que",
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
  "prompt": "Complétez :\nJe suis contente que chacun ___. (signer)",
  "answer": "signe"
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
    "la",
    "poser",
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
  "word": "ecoute",
  "hint": "S'entendre : prêter l'… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis contente que chacun signe, bien que Karim a encore peur pour la clé.",
  "correct_sentence": "Je suis contente que chacun signe, bien que Karim ait encore peur pour la clé.",
  "explanation": "Bien que + subjonctif : ait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/oreille-plainte.svg",
      "word": "une oreille"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/main-aide.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/soleil-installe.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/subjonctif-sentiment.svg",
      "word": "un sentiment"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un mini-dialogue de médiation : six répliques, un accord final."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les douze modèles, puis un compromis à vous (clé, table ou horaire)."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon accord de voisinage',
    'PE',
    $c$Objectif
Écrire un court accord : limites, contreparties, signatures.

Consigne
Imitez l'accord de Lila.

Support — Accord de Lila Sow
Lila Sow
Pavillon du Saule — copie pour le Bureau des Escales
Il faut que la clé reste visible le jour. Karim ne la prête plus dehors.
Léa a dit de frapper deux fois. Joël demande si cela suffit : oui.
Je ne sors pas encore tard, donc je n'emprunte la clé qu'au matin.
On n'ouvre plus l'atelier après vingt-deux heures, si bien que le couloir se tait.
Félicie ne sert que deux plateaux, sans minuit. Dieudonné ferme dès l'ombre.
Je suis contente que Hawa s'assoie au banc : il faut que ce banc reste un banc.
On n'invite ni passant ni client la nuit.
C'est pourquoi le dimanche est une pause, sous le saule, à Rive-des-Saules.
Je veux que Solange tamponne cette copie. J'ai peur qu'on l'oublie.
Lila
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila emprunte la clé seulement le matin, pour l'instant.",
  "correct": true,
  "explanation": "« je n'emprunte la clé qu'au matin. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que veut Lila à la fin ?",
  "options": [
    {
      "text": "Que Karim parte",
      "correct": false
    },
    {
      "text": "Que Solange tamponne la copie",
      "correct": true
    },
    {
      "text": "Que Félicie serve à minuit",
      "correct": false
    },
    {
      "text": "Que l'atelier reste ouvert",
      "correct": false
    }
  ],
  "explanation": "« Je veux que Solange tamponne cette copie. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "clé visible le jour",
      "right": "contrepartie"
    },
    {
      "left": "ne la prête plus dehors",
      "right": "limite"
    },
    {
      "left": "n'emprunte que le matin",
      "right": "restriction"
    },
    {
      "left": "veut que Solange tamponne",
      "right": "trace officielle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe veux que Solange ___ cette copie. (tamponner)",
  "answer": "tamponne"
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
    "n'ouvre",
    "plus",
    "l'atelier",
    "après",
    "vingt-deux",
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
  "word": "voisinage",
  "hint": "Les gens de la porte à côté, au Pavillon."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je veux que Solange tamponne cette copie, afin que le Bureau a une trace.",
  "correct_sentence": "Je veux que Solange tamponne cette copie, afin que le Bureau ait une trace.",
  "explanation": "Afin que + subjonctif : ait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/main-aide.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/soleil-installe.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/subjonctif-sentiment.svg",
      "word": "un sentiment"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/souci-quotidien.svg",
      "word": "un souci"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : dix lignes d'accord, deux limites, deux contreparties, un que + subjonctif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre accord de voisinage, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Médier et conclure',
    'EL',
    $c$Objectif
Retenir les formes utiles pour un compromis au Pavillon.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, médiation
Cadre : il faut que chacun parle. Je veux que l'on s'écoute. Sans accuser.
Limite : je ne… plus / je ne… que / je n'accepte ni… ni.
Proposition : on peut…, alors… / c'est pourquoi…
But du compromis : pour que / afin que + subjonctif (pour que Karim soit calme).
Concession : bien que + subjonctif (bien qu'il ait peur).
Sentiment de clôture : je suis content(e) que chacun signe.
Crainte utile : j'ai peur qu'on l'oublie → d'où la copie au Bureau.
Paroles rapportées : X a dit de… / Y demande si…
La clé, la table, l'horaire : trois objets concrets valent mieux qu'un grand discours.
Toujours il faut (3e personne). Conditionnel plus tard : je serais d'accord si…
Un accord se recopie : Lila, Solange, tampon.
Le voisinage se tisse : petites phrases, signatures, silence partagé.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Pour que » et « afin que » se construisent avec l'indicatif.",
  "correct": false,
  "explanation": "Pour que / afin que + subjonctif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase pose un but de médiation ?",
  "options": [
    {
      "text": "Je ne la prête plus",
      "correct": false
    },
    {
      "text": "On n'invite ni passant ni client",
      "correct": false
    },
    {
      "text": "Pour que Karim soit calme",
      "correct": true
    },
    {
      "text": "Elle demande si deux coups suffisent",
      "correct": false
    }
  ],
  "explanation": "Pour que + subjonctif = but."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il faut que chacun",
      "right": "cadre"
    },
    {
      "left": "je ne… plus",
      "right": "limite"
    },
    {
      "left": "pour que + subj.",
      "right": "but"
    },
    {
      "left": "bien que + subj.",
      "right": "concession"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPour que Karim ___ calme. (être)",
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
    "Je",
    "veux",
    "que",
    "l'on",
    "s'écoute",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "mediation",
  "hint": "Aider deux parties à s'accorder (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On pose la clé sur la table, afin que chacun la voit pendant le jour.",
  "correct_sentence": "On pose la clé sur la table, afin que chacun la voie pendant le jour.",
  "explanation": "Afin que + subjonctif : voie (pas voit)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m2/soleil-installe.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/subjonctif-sentiment.svg",
      "word": "un sentiment"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/souci-quotidien.svg",
      "word": "un souci"
    },
    {
      "image_path": "/elearning/mfk-b1-m2/voisin-bruit.svg",
      "word": "un voisin"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez six formules types de médiation, une par ligne, à réemployer."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et un mini-accord inventé (quatre phrases)."
}$j$::jsonb,
    9
  );

END;
$$;
