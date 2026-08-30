/*
  Seed eLearning MFK — B2 — Agir au travail

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b2-m7/
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
  v_module_title text := 'B2 — Agir au travail';
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
      'Seed B2 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed B2 : enseignant % (%) — %', v_teacher_email, v_teacher_id, v_module_title;

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
      'Grande étape B2-7 : rapporter des pratiques, nommer des compétences, transmettre une consigne, nuancer un métier, croiser un entretien et signer une charte — Patrick compare l''Atelier du Tissu de Dieudonné et Radio Figuier (Lila, Léa, Marc, Joël), Aline forme, au Seuil des Sources (Rukiri-Nord).',
      'B2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B2-7 : rapporter des pratiques, nommer des compétences, transmettre une consigne, nuancer un métier, croiser un entretien et signer une charte — Patrick compare l''Atelier du Tissu de Dieudonné et Radio Figuier (Lila, Léa, Marc, Joël), Aline forme, au Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'B2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Pratiques et parcours =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Pratiques et parcours'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Pratiques et parcours', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Ce qu''on a dit du poste',
    'CO',
    $c$Objectif
Repérer le discours indirect au présent et au passé (il a dit qu'il partirait, elle a demandé si, on m'a assuré que).

Consigne
Lisez le dialogue. Qui rapporte quoi, au présent ou au passé ?

Support — Table des Sources, feuilles de parcours
Aline : Patrick, rappelez ce que Dieudonné a dit de l'atelier, et ce que Lila dit encore de l'antenne.
Patrick : Dieudonné a dit qu'il partirait à l'aube, et qu'il tendrait le premier coupon avant le thé.
Léa : Lila dit qu'elle ouvre le relais à sept heures, et elle demande si le casque de Joël est déjà posé.
Marc : On m'a assuré que le banc resterait libre, encore que la cour soit déjà bruyante.
Joël : Dieudonné m'a demandé si je savais mesurer un coupon ; j'ai répondu que j'apprendrais sans trop vite.
Rose : Il a dit qu'il ne coudrait pas un sac trop large, car un fond trop faible fatigue toute l'équipe.
Hawa : Lila dit qu'un relais trop long fatigue l'oreille, et elle a demandé si l'on pouvait couper à trois minutes.
Karim : On m'a assuré que Solange tamponnerait la feuille, pourvu que l'heure tenue soit écrite clairement.
Solange : Aline a dit qu'il faudrait relire le parcours avant de choisir, et non pas signer trop tôt.
Félicie : Patrick a demandé s'il pouvait essayer les deux lieux ; Aline a dit que ce serait plus juste.
Mado : On m'a assuré que le Cahier du chemin garderait ces paroles, afin que personne ne les déforme demain.
Yvette : Dieudonné dit encore qu'il ouvre à qui sait attendre ; Lila dit qu'elle ouvre à qui sait écouter.
Aline : Notez : au présent, il dit qu'il partira ; au passé, il a dit qu'il partirait. Elle a demandé si. On m'a assuré que.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Au passé, le futur de la parole devient un conditionnel : il a dit qu'il partirait.",
  "correct": true,
  "explanation": "Aline clôt sur ce glissement de temps."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que Dieudonné a-t-il dit de son départ, d'après Patrick ?",
  "options": [
    {
      "text": "Qu'il resterait sous le figuier toute la journée",
      "correct": false
    },
    {
      "text": "Qu'il partirait à l'aube et tendrait le coupon avant le thé",
      "correct": true
    },
    {
      "text": "Qu'il fermerait l'atelier sans prévenir",
      "correct": false
    },
    {
      "text": "Qu'il vendrait les casques de Joël",
      "correct": false
    }
  ],
  "explanation": "Patrick : « il partirait à l'aube… tendrait le premier coupon. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il a dit que",
      "right": "il partirait"
    },
    {
      "left": "elle a demandé si",
      "right": "le casque est posé"
    },
    {
      "left": "on m'a assuré que",
      "right": "le banc resterait libre"
    },
    {
      "left": "Lila dit que",
      "right": "elle ouvre à sept heures"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDieudonné a dit qu'il ___ à l'aube. (partir, cond.)",
  "answer": "partirait"
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
    "m'a",
    "assuré",
    "que",
    "le",
    "banc",
    "resterait",
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
  "word": "partirait",
  "hint": "Conditionnel de partir, après un verbe de parole au passé."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il a dit qu'il partira à l'aube, et on m'a assuré que le banc resterait libre.",
  "correct_sentence": "Il a dit qu'il partirait à l'aube, et on m'a assuré que le banc resterait libre.",
  "explanation": "Discours indirect au passé : le futur devient conditionnel."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/discours-indirect.svg",
      "word": "un discours"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/parcours-pro.svg",
      "word": "un parcours"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/choix-vie.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/cv-croise.svg",
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
  "prompt": "Notez quatre paroles au présent et quatre au passé, avec le temps du verbe rapporté."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il a dit qu'il partirait. Elle a demandé si le casque était prêt. On m'a assuré que le banc resterait libre."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Compte rendu de parcours',
    'CE',
    $c$Objectif
Lire un compte rendu qui enchaîne discours indirect présent et passé.

Consigne
Lisez le compte rendu, sans aller trop vite.

Support — Feuille de Patrick Habimana
Compte rendu — paroles rapportées (Patrick Habimana)
Dieudonné a dit qu'il partirait à l'aube, et qu'un coupon mal mesuré ferait perdre une heure à tout l'atelier.
Lila dit encore qu'elle ouvre le relais à sept heures, et elle demande si Joël a posé le casque sans le jeter.
On m'a assuré que le banc resterait libre ; toutefois Félicie a demandé si la Table des Sources n'était pas déjà prise.
Aline a dit qu'il faudrait relire mon parcours avant de choisir, car un métier n'est pas un caprice.
Joël m'a demandé si je savais tenir trois minutes sans trop parler ; j'ai répondu que j'apprendrais.
Rose a dit qu'elle tendrait le tissu, encore que le fil soit court, pour que le sac tienne.
Karim a assuré que Solange tamponnerait la feuille, pourvu que l'heure soit écrite clairement.
Marc a dit que Radio Figuier n'était pas une scène : c'est une oreille, et l'on y entre en écoutant.
Hawa a demandé si l'on pouvait essayer l'atelier un matin et l'antenne un jeudi, afin de comparer sans idéaliser.
Mado a noté ces paroles au Cahier du chemin, afin que personne ne les déforme demain.
Yvette a dit qu'un choix trop vite signé fatigue plus qu'un essai honnête.
Je retiens : au présent, on dit que / on demande si ; au passé, on a dit que / on a demandé si, et le futur devient conditionnel.
Copie : Aline Uwase — Atelier d'Aline
Seuil des Sources — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc dit que Radio Figuier est une scène où l'on parle d'abord.",
  "correct": false,
  "explanation": "Marc : ce n'est pas une scène, c'est une oreille."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faudrait-il faire, selon Aline, avant de choisir ?",
  "options": [
    {
      "text": "Signer trop tôt",
      "correct": false
    },
    {
      "text": "Relire le parcours",
      "correct": true
    },
    {
      "text": "Fermer l'atelier",
      "correct": false
    },
    {
      "text": "Jeter le casque",
      "correct": false
    }
  ],
  "explanation": "« Aline a dit qu'il faudrait relire mon parcours. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Dieudonné a dit que",
      "right": "il partirait à l'aube"
    },
    {
      "left": "Lila dit que",
      "right": "elle ouvre à sept heures"
    },
    {
      "left": "Joël a demandé si",
      "right": "tenir trois minutes"
    },
    {
      "left": "on m'a assuré que",
      "right": "le banc resterait libre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJoël m'a demandé ___ je savais tenir trois minutes.",
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
    "Aline",
    "a",
    "dit",
    "qu'il",
    "faudrait",
    "relire",
    "le",
    "parcours",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "assure",
  "hint": "On m'a… que : verbe pour garantir une parole. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Elle a demandé que le casque était prêt, et Lila dit qu'elle ouvre à sept heures.",
  "correct_sentence": "Elle a demandé si le casque était prêt, et Lila dit qu'elle ouvre à sept heures.",
  "explanation": "Une question rapportée se construit avec si, pas avec que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/parcours-pro.svg",
      "word": "un parcours"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/choix-vie.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/cv-croise.svg",
      "word": "un curriculum"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/competence-pro.svg",
      "word": "une compétence"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le compte rendu et soulignez tous les verbes rapportés ; indiquez présent ou passé."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le compte rendu, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire il a dit que, elle a demandé si',
    'PO',
    $c$Objectif
Rapporter à l'oral une pratique de travail au présent et au passé.

Consigne
Répétez les modèles, puis rapportez deux paroles d'atelier et deux d'antenne.

Support — Modèles d'Aline et de Patrick
Il dit qu'il partira à l'aube.
Il a dit qu'il partirait à l'aube.
Elle demande si le casque est posé.
Elle a demandé si le casque était posé.
On m'assure que le banc restera libre.
On m'a assuré que le banc resterait libre.
Dieudonné m'a dit de mesurer avant de couper.
Lila m'a demandé de couper à trois minutes.
Aline a dit qu'il faudrait relire le parcours.
Joël a répondu qu'il apprendrait.
Marc dit que l'antenne n'est pas une scène.
Rose a dit qu'elle tendrait le tissu.
Hawa a demandé si l'on pouvait essayer les deux lieux.
Je rapporte sans crier, et je change le temps quand le verbe introducteur est au passé.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Quand le verbe introducteur est au passé, le futur de la parole devient un conditionnel.",
  "correct": true,
  "explanation": "Il a dit qu'il partirait."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est un discours indirect au passé correct ?",
  "options": [
    {
      "text": "Il a dit qu'il partira à l'aube",
      "correct": false
    },
    {
      "text": "Il a dit qu'il partirait à l'aube",
      "correct": true
    },
    {
      "text": "Il a dit si il partirait à l'aube",
      "correct": false
    },
    {
      "text": "Il a dit de il partirait à l'aube",
      "correct": false
    }
  ],
  "explanation": "Passé + que + conditionnel."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il dit que",
      "right": "présent / futur"
    },
    {
      "left": "il a dit que",
      "right": "imparfait / conditionnel"
    },
    {
      "left": "demander si",
      "right": "question rapportée"
    },
    {
      "left": "dire de",
      "right": "ordre / conseil rapporté"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLila m'a demandé ___ couper à trois minutes.",
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
    "Elle",
    "a",
    "demandé",
    "si",
    "le",
    "casque",
    "était",
    "posé",
    "."
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
  "hint": "Verbe pour rapporter une question : elle a… si."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dieudonné m'a dit que mesurer avant de couper, et Lila a demandé si l'heure tenait.",
  "correct_sentence": "Dieudonné m'a dit de mesurer avant de couper, et Lila a demandé si l'heure tenait.",
  "explanation": "Un ordre rapporté : dire de + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/choix-vie.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/cv-croise.svg",
      "word": "un curriculum"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/competence-pro.svg",
      "word": "une compétence"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/badge-savoir.svg",
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
  "prompt": "Écrivez huit phrases : quatre au présent (dit que / demande si), quatre au passé."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis deux paroles rapportées à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon compte rendu de pratiques',
    'PE',
    $c$Objectif
Écrire un compte rendu de parcours en discours indirect présent et passé.

Consigne
Imitez le compte rendu de Léa Niyonzima, sans aller trop vite.

Support — Compte rendu de Léa Niyonzima
Léa Niyonzima — pratiques entendues sous le figuier
Dieudonné a dit qu'il ouvrirait l'Atelier du Tissu dès l'aube, et qu'il faudrait mesurer avant de couper.
Lila dit qu'elle tient le relais à sept heures, et elle demande si Marc a déjà réglé le casque de Joël.
On m'a assuré que Patrick pourrait essayer les deux lieux, encore que le temps soit court.
Aline a dit qu'un parcours se raconte sans se vanter, et elle m'a demandé de noter les heures tenues.
Joël a répondu qu'il apprendrait à couper à trois minutes, car un relais trop long fatigue l'oreille.
Rose a dit qu'elle tendrait le coupon, pourvu que le fil tienne jusqu'au soir.
Karim a assuré que Solange tamponnerait la feuille si l'heure était lisible.
Marc dit que Radio Figuier n'est pas une scène ; c'est une oreille, et l'on y entre en écoutant.
Hawa a demandé si l'on pouvait comparer sans idéaliser : un matin à l'atelier, un jeudi à l'antenne.
Mado a noté ces paroles au Cahier du chemin, afin que le choix de Patrick reste clair.
Je retiens : on dit que, on a dit que, on demande si, on a demandé si, on m'a assuré que.
Léa
Copie : Aline Uwase — Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa écrit que Marc présente Radio Figuier comme une scène.",
  "correct": false,
  "explanation": "« n'est pas une scène ; c'est une oreille. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que Dieudonné a-t-il dit qu'il faudrait faire avant de couper ?",
  "options": [
    {
      "text": "Signer trop tôt",
      "correct": false
    },
    {
      "text": "Mesurer",
      "correct": true
    },
    {
      "text": "Jeter le fil",
      "correct": false
    },
    {
      "text": "Fermer l'antenne",
      "correct": false
    }
  ],
  "explanation": "« il faudrait mesurer avant de couper. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Dieudonné a dit que",
      "right": "il ouvrirait à l'aube"
    },
    {
      "left": "Lila dit que",
      "right": "elle tient le relais"
    },
    {
      "left": "on m'a assuré que",
      "right": "Patrick pourrait essayer"
    },
    {
      "left": "Aline a demandé de",
      "right": "noter les heures"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn m'a assuré que Patrick ___ essayer les deux lieux. (pouvoir, cond.)",
  "answer": "pourrait"
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
    "dit",
    "qu'elle",
    "tient",
    "le",
    "relais",
    "."
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
  "hint": "Ce que Patrick relit avant de choisir un métier, pas un caprice."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On m'a assuré si le banc resterait libre, et Dieudonné a dit qu'il ouvrirait à l'aube.",
  "correct_sentence": "On m'a assuré que le banc resterait libre, et Dieudonné a dit qu'il ouvrirait à l'aube.",
  "explanation": "Assurer se construit avec que, pas avec si."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/cv-croise.svg",
      "word": "un curriculum"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/competence-pro.svg",
      "word": "une compétence"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/badge-savoir.svg",
      "word": "un badge"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/atelier-tissu.svg",
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
  "prompt": "Imitez : douze à quinze lignes, trois « a dit que », deux « a demandé si », un « on m'a assuré que »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre compte rendu, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Discours indirect présent et passé',
    'EL',
    $c$Objectif
Retenir les glissements de temps et les introducteurs que / si / de.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, discours rapporté
Présent : il dit qu'il part / qu'il partira ; elle demande si le banc est libre ; on assure que l'heure tiendra.
Passé : il a dit qu'il partait / qu'il partirait ; elle a demandé si le banc était libre ; on m'a assuré que l'heure tiendrait.
Glissements : présent → imparfait ; futur → conditionnel ; passé composé → plus-que-parfait.
Question : demander si + indicatif (pas demander que pour une question fermée).
Ordre / conseil : dire de + infinitif ; demander de + infinitif.
On m'a assuré que + indicatif (pas assurer si).
Il a dit qu'il faudrait + infinitif : nécessité rapportée.
Encore que + subjonctif : encore que la cour soit bruyante.
Bien que + subjonctif : bien que l'heure soit courte.
Attention : il faut (pas je faut). À + le = au : au Seuil, au parcours.
Un métier se raconte ; on ne le crie pas. Le Cahier du chemin garde les paroles.
On rapporte pour clarifier une pratique, non pour enfler une rumeur.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « elle a demandé que le casque était prêt » pour une question fermée.",
  "correct": false,
  "explanation": "Demander si + indicatif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Il a dit qu'il partira » doit devenir, au passé…",
  "options": [
    {
      "text": "il a dit qu'il part",
      "correct": false
    },
    {
      "text": "il a dit qu'il partirait",
      "correct": true
    },
    {
      "text": "il a dit si il partira",
      "correct": false
    },
    {
      "text": "il a dit de il partira",
      "correct": false
    }
  ],
  "explanation": "Futur → conditionnel."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "futur →",
      "right": "conditionnel"
    },
    {
      "left": "présent →",
      "right": "imparfait"
    },
    {
      "left": "demander si",
      "right": "question"
    },
    {
      "left": "dire de",
      "right": "ordre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nElle a demandé ___ le casque était posé.",
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
    "Il",
    "a",
    "dit",
    "qu'il",
    "partirait",
    "à",
    "l'aube",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "indirect",
  "hint": "Discours… : on rapporte sans citer les paroles telles quelles."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il a dit qu'il faudra relire le parcours, et Aline a demandé si l'heure tenait.",
  "correct_sentence": "Il a dit qu'il faudrait relire le parcours, et Aline a demandé si l'heure tenait.",
  "explanation": "Nécessité rapportée au passé : il faudrait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/competence-pro.svg",
      "word": "une compétence"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/badge-savoir.svg",
      "word": "un badge"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/atelier-tissu.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/antenne-stage.svg",
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
  "prompt": "Transformez six phrases directes en indirect : trois au présent, trois au passé."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six phrases : dit que, a dit que, demande si, a demandé si, assure que, on m'a assuré que."
}$j$::jsonb,
    9
  );

  -- ===== Identifier des compétences =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Identifier des compétences'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Identifier des compétences', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Savoir-faire sous le figuier',
    'CO',
    $c$Objectif
Repérer et nommer des compétences professionnelles inventées du Seuil.

Consigne
Lisez le dialogue. Qui sait faire quoi, et comment le dit-on ?

Support — Atelier du Tissu / seuil de Radio Figuier
Dieudonné : Un teneur de coupon sait mesurer avant de couper ; il est capable de tendre sans déchirer.
Lila : Un relais du matin maîtrise le silence : il a l'habitude de poser le casque avant de parler.
Patrick : Je sais porter un seau, mais je ne maîtrise pas encore le fil ocre.
Léa : Joël est capable de tenir trois minutes ; il n'a pas encore l'habitude de couper pile.
Marc : Savoir écouter n'est pas connaître le nom de tous les outils : ce sont deux compétences.
Aline : On décrit un savoir-faire avec savoir + infinitif, être capable de, maîtriser, avoir l'habitude de.
Rose : Je sais recoudre un fond trop faible ; je ne me vante pas, je le montre.
Hawa : Solange a l'habitude de tamponner une feuille lisible, pas une page trop vite signée.
Karim : Un apprenti-tissu apprend à plier ; un preneur de son apprend à ne pas jeter le casque.
Félicie : Être capable de dresser la table à l'heure, cela compte autant qu'un long discours.
Mado : Le Cahier du chemin note les gestes tenus, pas les titres d'ailleurs.
Yvette : Patrick pourra dire : je sais, je suis capable de, je commence à maîtriser.
Joël : Je ne maîtrise pas encore l'antenne ; j'ai toutefois l'habitude d'écouter jusqu'au bout.
Aline : Une compétence du Seuil se montre ; elle ne s'emprunte pas à une ville lointaine.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc distingue savoir écouter et connaître le nom des outils.",
  "correct": true,
  "explanation": "Marc : ce sont deux compétences."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que sait faire un teneur de coupon, selon Dieudonné ?",
  "options": [
    {
      "text": "Crier plus fort que Lila",
      "correct": false
    },
    {
      "text": "Mesurer avant de couper et tendre sans déchirer",
      "correct": true
    },
    {
      "text": "Tamponner le Bureau des Escales",
      "correct": false
    },
    {
      "text": "Vendre un casque",
      "correct": false
    }
  ],
  "explanation": "Dieudonné : mesurer avant de couper ; tendre sans déchirer."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "savoir + infinitif",
      "right": "mesurer / porter"
    },
    {
      "left": "être capable de",
      "right": "tenir trois minutes"
    },
    {
      "left": "maîtriser",
      "right": "le silence / le fil"
    },
    {
      "left": "avoir l'habitude de",
      "right": "poser le casque"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUn teneur de coupon ___ mesurer avant de couper.",
  "answer": "sait"
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
    "est",
    "capable",
    "de",
    "tenir",
    "trois",
    "minutes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "maitriser",
  "hint": "Tenir un geste jusqu'au bout, sans trop d'erreurs. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis capable à tenir trois minutes, et j'ai l'habitude de poser le casque.",
  "correct_sentence": "Je suis capable de tenir trois minutes, et j'ai l'habitude de poser le casque.",
  "explanation": "Être capable de, pas capable à."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/badge-savoir.svg",
      "word": "un badge"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/atelier-tissu.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/antenne-stage.svg",
      "word": "une antenne"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/double-pronom.svg",
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
  "prompt": "Notez huit compétences entendues, avec le verbe qui les introduit (savoir / capable / maîtriser / habitude)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je sais mesurer. Je suis capable de tendre. Je maîtrise le silence. J'ai l'habitude de poser le casque."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fiche des savoir-faire du Seuil',
    'CE',
    $c$Objectif
Lire une fiche qui décrit des compétences locales, sans titres d'ailleurs.

Consigne
Lisez la fiche, sans aller trop vite.

Support — Fiche d'Aline Uwase, savoir-faire
Fiche — compétences du Seuil (Atelier du Tissu / Radio Figuier)
1. Teneur de coupon : savoir mesurer, être capable de tendre sans déchirer, maîtriser le fil ocre.
2. Apprenti-tissu : avoir l'habitude de plier trois sacs avant de parler d'un quatrième.
3. Relais du matin : maîtriser le silence, savoir couper à trois minutes, poser le casque avant la voix.
4. Preneur de son : être capable de régler le casque de Joël sans le jeter, avoir l'habitude d'écouter.
5. Chroniqueur de cour : savoir relater un geste tenu, pas une rumeur ; Aline relit la page.
6. Tamponneur au Bureau des Escales : Solange a l'habitude d'exiger une heure lisible.
7. Dresseuse de table : Félicie est capable de tenir l'heure du thé sans crier.
8. Teneur du Cahier du chemin : Mado sait noter un savoir-faire sans l'enfler.
Patrick : je sais porter un seau ; je commence à maîtriser le coupon ; je n'ai pas encore l'habitude du micro.
Léa : Joël est capable de tenir trois minutes ; il ne maîtrise pas encore la coupe pile.
Marc : connaître le nom d'un outil n'est pas savoir s'en servir.
Aline : une compétence se décrit au Seuil, jamais avec un titre emprunté à une école d'ailleurs.
Dieudonné : montrer un sac fini vaut mieux que dire « je connais tout ».
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick dit qu'il maîtrise déjà complètement le micro.",
  "correct": false,
  "explanation": "Il n'a pas encore l'habitude du micro."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que exige Solange, d'après la fiche ?",
  "options": [
    {
      "text": "Un titre d'ailleurs",
      "correct": false
    },
    {
      "text": "Une heure lisible",
      "correct": true
    },
    {
      "text": "Un casque jeté",
      "correct": false
    },
    {
      "text": "Un sac trop large",
      "correct": false
    }
  ],
  "explanation": "« exiger une heure lisible. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "teneur de coupon",
      "right": "mesurer / tendre"
    },
    {
      "left": "relais du matin",
      "right": "silence / trois minutes"
    },
    {
      "left": "preneur de son",
      "right": "régler le casque"
    },
    {
      "left": "Patrick",
      "right": "seau / coupon / pas encore le micro"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJoël est capable ___ tenir trois minutes.",
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
    "sais",
    "porter",
    "un",
    "seau",
    "."
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
  "hint": "Savoir-faire montré, pas un titre emprunté. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je connais mesurer un coupon, et j'ai l'habitude de plier trois sacs.",
  "correct_sentence": "Je sais mesurer un coupon, et j'ai l'habitude de plier trois sacs.",
  "explanation": "Savoir + infinitif pour un geste ; connaître s'emploie avec un nom."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/atelier-tissu.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/antenne-stage.svg",
      "word": "une antenne"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/double-pronom.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/figure-style.svg",
      "word": "une figure"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez six métiers inventés et, pour chacun, un savoir-faire avec le bon verbe."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la fiche des savoir-faire, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire je sais, je maîtrise, je suis capable de',
    'PO',
    $c$Objectif
Décrire à l'oral ses savoir-faire avec les verbes du Seuil.

Consigne
Répétez, puis dites trois compétences tenues et une que vous commencez.

Support — Modèles de Dieudonné et de Lila
Je sais mesurer un coupon.
Je suis capable de tendre sans déchirer.
Je maîtrise le fil ocre, pas encore le micro.
J'ai l'habitude de poser le casque avant de parler.
Je commence à maîtriser trois minutes.
Je ne connais pas tous les outils, mais je sais m'en servir.
Un teneur de coupon montre un geste, il ne le crie pas.
Un relais du matin sait se taire.
Je suis capable d'écouter jusqu'au bout.
J'ai l'habitude de relire la page avec Aline.
Patrick : je sais porter un seau.
Léa : Joël est capable de tenir l'heure.
Marc : connaître un nom n'est pas savoir faire.
Aline : décrivez, ne vous vantez pas.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Connaître le nom d'un outil » n'équivaut pas à « savoir s'en servir ».",
  "correct": true,
  "explanation": "Marc et la fiche le rappellent."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase décrit correctement un savoir-faire ?",
  "options": [
    {
      "text": "Je suis capable à couper",
      "correct": false
    },
    {
      "text": "Je connais mesurer",
      "correct": false
    },
    {
      "text": "Je sais mesurer un coupon",
      "correct": true
    },
    {
      "text": "J'ai l'habitude à poser le casque",
      "correct": false
    }
  ],
  "explanation": "Savoir + infinitif."
}$j$::jsonb,
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
      "right": "geste + infinitif"
    },
    {
      "left": "je suis capable de",
      "right": "possibilité réelle"
    },
    {
      "left": "je maîtrise",
      "right": "geste tenu"
    },
    {
      "left": "j'ai l'habitude de",
      "right": "geste répété"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'ai l'habitude ___ poser le casque avant de parler.",
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
    "maîtrise",
    "le",
    "fil",
    "ocre",
    "."
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
  "hint": "Geste répété : j'ai l'… de poser le casque."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai l'habitude à poser le casque, et je commence à maîtriser trois minutes.",
  "correct_sentence": "J'ai l'habitude de poser le casque, et je commence à maîtriser trois minutes.",
  "explanation": "Avoir l'habitude de, pas habitude à."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/antenne-stage.svg",
      "word": "une antenne"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/double-pronom.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/figure-style.svg",
      "word": "une figure"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/reunion-cour.svg",
      "word": "une réunion"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez dix phrases : trois je sais, trois capable de, deux je maîtrise, deux habitude de."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis trois compétences à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma fiche de compétences',
    'PE',
    $c$Objectif
Écrire une fiche de savoir-faire professionnels du Seuil.

Consigne
Imitez la fiche de Joël Mugisha, sans aller trop vite.

Support — Fiche de Joël Mugisha
Joël Mugisha — savoir-faire tenus, savoir-faire commencés
Je sais porter un seau jusqu'à la rive, et je suis capable de le poser sans le verser.
Je n'ai pas encore l'habitude du micro : je commence à maîtriser trois minutes, pas davantage.
Dieudonné dit qu'un apprenti-tissu sait plier avant de couper ; je plie, je ne me vante pas.
Lila dit qu'un relais du matin maîtrise le silence ; je suis capable de me taire jusqu'au signal.
Patrick sait mesurer un coupon plus vite que moi ; je sais toutefois recoudre un fond trop faible.
Rose a l'habitude de tendre le fil ocre ; je l'observe, puis je répète le geste.
Aline m'a demandé de nommer quatre compétences sans emprunter un titre d'ailleurs.
Je connais le nom du casque, mais je ne maîtrise pas encore le réglage : Léa m'aide.
Solange a l'habitude d'exiger une heure lisible ; je suis capable d'écrire l'heure sans rature.
Le Cahier du chemin notera ces gestes, afin que mon parcours reste clair.
Joël
Copie : Aline Uwase, Dieudonné Hakizimana, Lila Sow
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël dit qu'il maîtrise déjà complètement le réglage du casque.",
  "correct": false,
  "explanation": "Il ne maîtrise pas encore le réglage ; Léa l'aide."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle compétence Joël commence-t-il seulement ?",
  "options": [
    {
      "text": "Porter un seau",
      "correct": false
    },
    {
      "text": "Tenir trois minutes au micro",
      "correct": true
    },
    {
      "text": "Recoudre un fond",
      "correct": false
    },
    {
      "text": "Écrire l'heure",
      "correct": false
    }
  ],
  "explanation": "« je commence à maîtriser trois minutes, pas davantage. »"
}$j$::jsonb,
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
      "right": "porter / recoudre"
    },
    {
      "left": "je suis capable de",
      "right": "poser / me taire"
    },
    {
      "left": "je commence à maîtriser",
      "right": "trois minutes"
    },
    {
      "left": "j'ai l'habitude de",
      "right": "pas encore le micro"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe n'ai pas encore l'habitude ___ micro.",
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
    "sais",
    "plier",
    "avant",
    "de",
    "couper",
    "."
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
  "hint": "Verbe suivi de l'infinitif pour un geste qu'on tient."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis capable de mesurer un coupon, et je connais tendre le fil sans déchirer.",
  "correct_sentence": "Je suis capable de mesurer un coupon, et je sais tendre le fil sans déchirer.",
  "explanation": "Savoir + infinitif, pas connaître + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/double-pronom.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/figure-style.svg",
      "word": "une figure"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/reunion-cour.svg",
      "word": "une réunion"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/carnet-pro.svg",
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
  "prompt": "Imitez : une fiche de douze lignes, quatre verbes de compétence, deux métiers inventés du Seuil."
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
    'EL — Verbes pour décrire un savoir-faire',
    'EL',
    $c$Objectif
Retenir savoir, être capable de, maîtriser, avoir l'habitude de, et l'écart avec connaître.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, compétences
savoir + infinitif : je sais mesurer, tu sais écouter, il sait couper (un geste).
connaître + nom : je connais l'outil, je connais Lila (une personne, un objet). On ne dit pas je connais mesurer.
être capable de + infinitif : je suis capable de tenir trois minutes (possibilité réelle).
maîtriser + nom : je maîtrise le fil, le silence, l'heure (un geste tenu, pas commencé).
avoir l'habitude de + infinitif : j'ai l'habitude de poser le casque (répétition).
commencer à + infinitif : je commence à maîtriser (geste encore fragile).
Métiers inventés du Seuil : teneur de coupon, apprenti-tissu, relais du matin, preneur de son, chroniqueur de cour, tamponneur, dresseuse de table, teneur du Cahier.
On ne nomme pas une école d'ailleurs. On montre un geste.
Attention : capable de (pas capable à) ; habitude de (pas habitude à).
À + le = au : au Seuil, au micro. De + le = du : du casque, du fil.
Une compétence se décrit ; elle ne s'emprunte pas.
On montre un geste tenu ; on n'emprunte pas un titre lointain.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je connais mesurer un coupon ».",
  "correct": false,
  "explanation": "Je sais mesurer. Connaître + nom."
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
      "text": "Je suis capable à tendre",
      "correct": false
    },
    {
      "text": "J'ai l'habitude à écouter",
      "correct": false
    },
    {
      "text": "Je sais mesurer un coupon",
      "correct": true
    },
    {
      "text": "Je connais couper le fil",
      "correct": false
    }
  ],
  "explanation": "Savoir + infinitif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "savoir",
      "right": "infinitif / geste"
    },
    {
      "left": "connaître",
      "right": "nom / personne"
    },
    {
      "left": "capable de",
      "right": "possibilité"
    },
    {
      "left": "habitude de",
      "right": "répétition"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ le silence à l'antenne, pas encore le fil. (maîtriser, présent)",
  "answer": "maîtrise"
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
    "capable",
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
  "word": "capable",
  "hint": "Être… de : on peut vraiment faire le geste, aujourd'hui."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis capable à écouter jusqu'au bout, et je sais poser le casque.",
  "correct_sentence": "Je suis capable d'écouter jusqu'au bout, et je sais poser le casque.",
  "explanation": "Capable de / d' + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/figure-style.svg",
      "word": "une figure"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/reunion-cour.svg",
      "word": "une réunion"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/carnet-pro.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/nuance-avis.svg",
      "word": "une nuance"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Construisez deux colonnes : savoir / connaître, puis six phrases de compétences du Seuil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six phrases, une par verbe de la fiche."
}$j$::jsonb,
    9
  );

  -- ===== Communiquer au travail =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Communiquer au travail'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Communiquer au travail', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Je le lui ai transmis',
    'CO',
    $c$Objectif
Repérer la double pronominalisation et quelques figures inventées (figuier, tissu, radio).

Consigne
Lisez le dialogue. Où sont les deux pronoms, et quelles figures entend-on ?

Support — Réunion de cour, carnet professionnel
Aline : Patrick, le coupon, à Dieudonné : tu le lui as transmis ?
Patrick : Je le lui ai transmis à l'aube, et on me l'a confirmé avant le thé.
Léa : Lila m'a dit la durée : elle me l'a répétée, claire comme un coupon bien coupé.
Marc : Le figuier est une antenne : il tient les voix sans les crier. Ce n'est pas rien.
Joël : Dieudonné m'a montré les ciseaux ; il me les a prêtés, et je les lui ai rendus.
Rose : On nous l'a dit sans brusquer : le fil trop tendu casse, comme une phrase trop vite dite.
Hawa : Je te le confirmerai jeudi, encore que l'heure soit courte.
Karim : Solange leur a tamponné la feuille : elle la leur a remise, lisible.
Félicie : Ce n'est pas le plus faible des relais, que de poser le casque avant de parler. Litote d'Aline.
Mado : La métaphore douce tient : l'atelier est une phrase qu'on tend, la radio une oreille qu'on ouvre.
Yvette : Tu me l'as expliqué ; je le leur dirai sans enfler.
Dieudonné : Ne me le jetez pas, ce coupon : tendez-le-moi, simplement.
Lila : On me l'a confirmé : trois minutes, pas davantage.
Aline : Ordre : me / te / nous / vous, puis le / la / les, puis lui / leur. Ensuite l'auxiliaire.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc emploie une métaphore : le figuier est une antenne.",
  "correct": true,
  "explanation": "Marc le dit clairement."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel est l'ordre des pronoms rappelé par Aline ?",
  "options": [
    {
      "text": "lui / le / me",
      "correct": false
    },
    {
      "text": "me-te-nous-vous, puis le-la-les, puis lui-leur",
      "correct": true
    },
    {
      "text": "les / leur / me seulement",
      "correct": false
    },
    {
      "text": "l'auxiliaire d'abord, puis rien",
      "correct": false
    }
  ],
  "explanation": "Aline clôt sur cet ordre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je le lui ai transmis",
      "right": "coupon à Dieudonné"
    },
    {
      "left": "on me l'a confirmé",
      "right": "durée / trois minutes"
    },
    {
      "left": "métaphore",
      "right": "le figuier est une antenne"
    },
    {
      "left": "comparaison",
      "right": "clair comme un coupon"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ lui ai transmis à l'aube. (le coupon)",
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
    "On",
    "me",
    "l'a",
    "confirmé",
    "avant",
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
  "word": "transmis",
  "hint": "Passé de transmettre : ce qu'on a fait du coupon à Dieudonné."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je lui le ai transmis à l'aube, et on me l'a confirmé avant le thé.",
  "correct_sentence": "Je le lui ai transmis à l'aube, et on me l'a confirmé avant le thé.",
  "explanation": "Le (COD) se place avant lui (COI)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/reunion-cour.svg",
      "word": "une réunion"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/carnet-pro.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/nuance-avis.svg",
      "word": "une nuance"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/metier-argument.svg",
      "word": "un métier"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez quatre doubles pronoms et trois figures (métaphore, comparaison, litote)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je le lui ai transmis. On me l'a confirmé. Je te les ai rendus. Clair comme un coupon bien coupé."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Consignes et figures du carnet',
    'CE',
    $c$Objectif
Lire un carnet de consignes avec doubles pronoms et figures de la cour.

Consigne
Lisez le carnet, sans aller trop vite.

Support — Carnet professionnel de Marc Nkurunziza
Carnet — transmettre sans brusquer
Patrick a tendu le coupon : il le lui a transmis à Dieudonné, et on me l'a confirmé avant le thé.
Léa a réglé le casque : elle me l'a passé, puis Joël le lui a rendu sans le jeter.
Solange a tamponné la feuille : elle la leur a remise, lisible comme un fil bien tendu.
Aline nous l'a dit : le figuier est une antenne, pas un tambour ; ce n'est pas rien que de s'y taire.
Dieudonné m'a prêté les ciseaux : il me les a confiés, et je les lui ai rendus avant midi.
Lila te le confirmera : trois minutes, encore que le sujet soit vaste.
Rose compare sans enfler : une consigne trop vite dite casse, comme un fil trop tiré.
Hawa emploie la litote d'Aline : ce n'est pas le plus faible des relais, que de poser le casque d'abord.
Mado note au Cahier : l'atelier est une phrase qu'on tend ; la radio est une oreille qu'on ouvre.
Yvette me l'a expliqué ; je le leur dirai jeudi, sans crier.
Ordre retenu : me / te / nous / vous + le / la / les + lui / leur, puis l'auxiliaire.
On ne dit pas je lui le. On ne dit pas on l'a me confirmé.
Une figure douce éclaire ; elle ne remplace pas la consigne.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le carnet interdit « je lui le » et « on l'a me confirmé ».",
  "correct": true,
  "explanation": "Les deux interdits sont écrits en clair."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle métaphore Aline a-t-elle dite, d'après le carnet ?",
  "options": [
    {
      "text": "Le figuier est un tambour",
      "correct": false
    },
    {
      "text": "Le figuier est une antenne",
      "correct": true
    },
    {
      "text": "L'atelier est un minibus",
      "correct": false
    },
    {
      "text": "La radio est un palais",
      "correct": false
    }
  ],
  "explanation": "« le figuier est une antenne, pas un tambour. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il le lui a transmis",
      "right": "coupon / Dieudonné"
    },
    {
      "left": "elle la leur a remise",
      "right": "feuille / Solange"
    },
    {
      "left": "clair comme un fil",
      "right": "comparaison"
    },
    {
      "left": "ce n'est pas rien",
      "right": "litote"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nElle ___ leur a remise, lisible. (la feuille)",
  "answer": "la"
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
    "lui",
    "ai",
    "rendus",
    "avant",
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
  "word": "metaphore",
  "hint": "Le figuier est une antenne : une… douce. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On l'a me confirmé avant le thé, et Patrick le lui a transmis à l'aube.",
  "correct_sentence": "On me l'a confirmé avant le thé, et Patrick le lui a transmis à l'aube.",
  "explanation": "Me se place avant le, tous deux avant l'auxiliaire."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/carnet-pro.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/nuance-avis.svg",
      "word": "une nuance"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/metier-argument.svg",
      "word": "un métier"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/charte-travail.svg",
      "word": "une charte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le carnet et encadrez tous les groupes de deux pronoms ; nommez trois figures."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le carnet, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire je le lui / on me l''a',
    'PO',
    $c$Objectif
Placer deux pronoms et oser une figure douce autour du figuier, du tissu ou de la radio.

Consigne
Répétez, puis transmettez une consigne avec deux pronoms et une comparaison.

Support — Modèles de Lila et de Dieudonné
Je le lui ai transmis.
On me l'a confirmé.
Je te les ai montrés.
Elle nous l'a expliqué.
Tu le leur as dit.
Je les lui ai rendus.
Tendez-le-moi, simplement.
Ne me le jetez pas.
Le figuier est une antenne.
Clair comme un coupon bien coupé.
Ce n'est pas rien que de se taire.
L'atelier est une phrase qu'on tend.
La radio est une oreille qu'on ouvre.
Aline : deux pronoms, puis l'auxiliaire ; une figure, pas un cri.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "À l'impératif affirmatif, les pronoms se placent après le verbe : tendez-le-moi.",
  "correct": true,
  "explanation": "Dieudonné : tendez-le-moi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase place correctement les deux pronoms ?",
  "options": [
    {
      "text": "Je lui le ai transmis",
      "correct": false
    },
    {
      "text": "Je le lui ai transmis",
      "correct": true
    },
    {
      "text": "Je ai le lui transmis",
      "correct": false
    },
    {
      "text": "Le je lui ai transmis",
      "correct": false
    }
  ],
  "explanation": "Je + le + lui + ai transmis."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je le lui",
      "right": "COD + COI 3e"
    },
    {
      "left": "on me l'",
      "right": "me + le"
    },
    {
      "left": "tendez-le-moi",
      "right": "impératif affirmatif"
    },
    {
      "left": "ce n'est pas rien",
      "right": "litote"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTu ___ leur as dit sans crier. (le message)",
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
    "Elle",
    "nous",
    "l'a",
    "expliqué",
    "calmement",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "litote",
  "hint": "Ce n'est pas rien : une figure qui diminue pour mieux dire."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je lui les ai rendus avant midi, et on me l'a confirmé au thé.",
  "correct_sentence": "Je les lui ai rendus avant midi, et on me l'a confirmé au thé.",
  "explanation": "Les (COD) avant lui (COI)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/nuance-avis.svg",
      "word": "une nuance"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/metier-argument.svg",
      "word": "un métier"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/charte-travail.svg",
      "word": "une charte"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/table-sources-pro.svg",
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
  "prompt": "Écrivez huit phrases à deux pronoms et trois figures (une métaphore, une comparaison, une litote)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis une consigne et une figure à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma consigne transmise',
    'PE',
    $c$Objectif
Écrire une consigne de travail avec doubles pronoms et figures de la cour.

Consigne
Imitez la consigne de Rose Iradukunda, sans aller trop vite.

Support — Consigne de Rose Iradukunda
Rose Iradukunda — transmettre le coupon et l'heure
Patrick m'a tendu le coupon : je le lui ai remis à Dieudonné, et on me l'a confirmé avant le thé.
Lila m'avait dit la durée : je te la répète, claire comme un fil bien coupé.
Le figuier est une antenne : il tient nos voix sans les jeter. Ce n'est pas rien.
Joël m'a prêté les ciseaux ; je les lui ai rendus, encore que l'heure fût déjà courte.
Solange a tamponné la feuille : elle la leur a donnée, lisible, sans rature.
Aline nous l'a expliqué : une consigne trop vite criée casse, comme un tissu trop tiré.
Je le leur dirai jeudi : trois minutes à l'antenne, un sac fini à l'atelier, pas davantage.
Ne me le jetez pas, ce carnet : tendez-le-moi, simplement, sous le figuier.
L'atelier est une phrase qu'on tend ; la radio est une oreille qu'on ouvre.
Je retiens l'ordre : me / te / nous / vous, le / la / les, lui / leur.
Rose
Copie : Aline, Dieudonné, Lila — Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose emploie la comparaison « claire comme un fil bien coupé ».",
  "correct": true,
  "explanation": "Deuxième phrase de la consigne."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que Rose a-t-elle fait des ciseaux de Joël ?",
  "options": [
    {
      "text": "Elle les a jetés",
      "correct": false
    },
    {
      "text": "Elle les lui a rendus",
      "correct": true
    },
    {
      "text": "Elle les a vendus",
      "correct": false
    },
    {
      "text": "Elle les a cachés au Bureau",
      "correct": false
    }
  ],
  "explanation": "« je les lui ai rendus. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je le lui ai remis",
      "right": "coupon / Dieudonné"
    },
    {
      "left": "on me l'a confirmé",
      "right": "avant le thé"
    },
    {
      "left": "le figuier est une antenne",
      "right": "métaphore"
    },
    {
      "left": "comme un tissu trop tiré",
      "right": "comparaison"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNe me ___ jetez pas, ce carnet. (le)",
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
    "Tendez-le-moi",
    "simplement",
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
  "word": "confirme",
  "hint": "On me l'a… : on a garanti la durée avant le thé. (sans accent final)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aline nous l'a expliqué calmement, et une consigne trop vite criée casse comme un tissus trop tiré.",
  "correct_sentence": "Aline nous l'a expliqué calmement, et une consigne trop vite criée casse comme un tissu trop tiré.",
  "explanation": "Tissu s'écrit sans s final au singulier."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/metier-argument.svg",
      "word": "un métier"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/charte-travail.svg",
      "word": "une charte"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/table-sources-pro.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/entretien-croise.svg",
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
  "prompt": "Imitez : douze lignes, quatre doubles pronoms, une métaphore, une comparaison, une litote."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre consigne, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Doubles pronoms et figures douces',
    'EL',
    $c$Objectif
Retenir l'ordre des pronoms et trois figures inventées de la cour.

Consigne
Apprenez la fiche.

Support — Fiche de Lila, pronoms et figures
Ordre à l'indicatif : me / te / se / nous / vous + le / la / les + lui / leur + verbe.
Je le lui ai transmis. On me l'a confirmé. Elle nous les a montrés.
Pas : je lui le. Pas : on l'a me confirmé.
Impératif affirmatif : verbe-le-moi (tendez-le-moi). Impératif négatif : ne me le jetez pas.
Accord du participe : COD avant → je les lui ai rendus ; je me l'a répétée (durée, fém.).
Métaphore douce : le figuier est une antenne ; l'atelier est une phrase qu'on tend ; la radio est une oreille.
Comparaison : clair comme un coupon bien coupé ; cassé comme un fil trop tiré.
Litote : ce n'est pas rien ; ce n'est pas le plus faible des relais.
Ces figures s'inventent autour du figuier, du tissu, de la radio : pas ailleurs.
Attention : à + le = au. Il faut (pas je faut).
Une figure éclaire une consigne ; elle ne la remplace pas.
On transmet sous le figuier : deux pronoms, une image douce, pas un cri.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "À l'impératif négatif, les pronoms restent avant le verbe : ne me le jetez pas.",
  "correct": true,
  "explanation": "Fiche : impératif négatif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Le figuier est une antenne » est…",
  "options": [
    {
      "text": "une litote",
      "correct": false
    },
    {
      "text": "une métaphore",
      "correct": true
    },
    {
      "text": "une question rapportée",
      "correct": false
    },
    {
      "text": "un superlatif",
      "correct": false
    }
  ],
  "explanation": "On dit que c'est, sans comme."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je le lui",
      "right": "COD + lui"
    },
    {
      "left": "tendez-le-moi",
      "right": "impératif +"
    },
    {
      "left": "ne me le jetez pas",
      "right": "impératif −"
    },
    {
      "left": "ce n'est pas rien",
      "right": "litote"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTendez-___-moi, simplement. (le coupon)",
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
    "Ce",
    "n'est",
    "pas",
    "rien",
    "que",
    "de",
    "se",
    "taire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pronoms",
  "hint": "Le, lui, me, te : on en place souvent deux, dans un ordre fixe."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je lui le confirmerai jeudi, et le figuier restera notre antenne.",
  "correct_sentence": "Je le lui confirmerai jeudi, et le figuier restera notre antenne.",
  "explanation": "Le avant lui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/charte-travail.svg",
      "word": "une charte"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/table-sources-pro.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/entretien-croise.svg",
      "word": "un entretien"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/porte-essai.svg",
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
  "prompt": "Conjuguez transmettre et confirmer au PC avec deux pronoms (je / on / elle) et inventez trois figures."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, six doubles pronoms et trois figures."
}$j$::jsonb,
    9
  );

  -- ===== Métier et point de vue =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Métier et point de vue'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Métier et point de vue', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Nuancer sans trahir',
    'CO',
    $c$Objectif
Repérer les expressions qui nuancent un avis sur un métier (il me semble que, on peut toutefois, sans nier que, encore que + subj.).

Consigne
Lisez le dialogue. Qui nuance quoi, et avec quelle formule ?

Support — Banc du Seuil, avis croisés
Aline : Un métier se discute ; on ne le cloue pas. Nuancez.
Patrick : Il me semble que l'atelier me convient davantage, encore que l'antenne m'attire.
Léa : On peut toutefois reconnaître que Joël tient déjà trois minutes, sans nier que le silence lui coûte.
Marc : Sans nier que Radio Figuier ouvre une oreille, il me semble que l'atelier forme plus les mains.
Dieudonné : Encore que le fil soit court, on peut toutefois finir un sac honnête.
Lila : Il me semble que Patrick gagnerait à essayer les deux, encore qu'il doive choisir un matin.
Joël : On peut toutefois dire que je commence, sans nier que je tremble encore au signal.
Rose : Encore que le coupon soit simple, ce n'est pas un métier moindre.
Hawa : Il me semble que comparer n'est pas trahir, encore que chacun tienne à son lieu.
Karim : Sans nier que le tampon compte, on peut toutefois préférer un geste tenu.
Solange : Encore que la feuille soit lisible, il me semble qu'il manque une heure.
Félicie : On peut toutefois boire le thé avant de décider, sans nier que le temps presse.
Mado : J'écrirai ces nuances au Cahier, afin que l'avis reste un avis, pas un verdict.
Aline : Il me semble que / on peut toutefois / sans nier que / encore que + subjonctif : quatre portes, pas un mur.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Encore que se construit avec le subjonctif : encore que le fil soit court.",
  "correct": true,
  "explanation": "Dieudonné et Aline le montrent."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que semble-t-il à Patrick, d'après le dialogue ?",
  "options": [
    {
      "text": "Que l'antenne lui convient davantage",
      "correct": false
    },
    {
      "text": "Que l'atelier lui convient davantage, encore que l'antenne l'attire",
      "correct": true
    },
    {
      "text": "Qu'il faut fermer l'atelier",
      "correct": false
    },
    {
      "text": "Que Solange refuse toute feuille",
      "correct": false
    }
  ],
  "explanation": "Patrick : atelier davantage, antenne qui attire encore."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il me semble que",
      "right": "avis prudent"
    },
    {
      "left": "on peut toutefois",
      "right": "concession souple"
    },
    {
      "left": "sans nier que",
      "right": "on admet un fait"
    },
    {
      "left": "encore que",
      "right": "subjonctif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le fil ___ court, on peut finir un sac. (être, subj.)",
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
    "me",
    "semble",
    "que",
    "l'atelier",
    "me",
    "convient",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "toutefois",
  "hint": "On peut… : on admet, puis on ajoute un autre avis."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Encore que le fil est court, on peut toutefois finir un sac honnête.",
  "correct_sentence": "Encore que le fil soit court, on peut toutefois finir un sac honnête.",
  "explanation": "Encore que + subjonctif : soit, pas est."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/table-sources-pro.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/entretien-croise.svg",
      "word": "un entretien"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/porte-essai.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/dieudonne-outil.svg",
      "word": "un outil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez quatre formules de nuance et, pour chacune, l'avis qu'elle porte."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il me semble que l'atelier me convient. On peut toutefois essayer l'antenne. Sans nier que le silence coûte. Encore que le fil soit court."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Avis nuancé sur deux métiers',
    'CE',
    $c$Objectif
Lire un avis argumenté qui refuse le verdict trop net.

Consigne
Lisez l'avis, sans aller trop vite.

Support — Avis de Marc Nkurunziza
Avis — Atelier du Tissu et Radio Figuier, sans verdict
Il me semble que l'atelier forme davantage les mains, encore que l'antenne forme l'oreille.
On peut toutefois reconnaître que Lila tient un relais juste, sans nier que Dieudonné tient un sac fini.
Sans nier que Patrick rêve du micro, il me semble qu'il gagne à mesurer un coupon avant de parler trop vite.
Encore que Joël tremble au signal, on peut toutefois dire qu'il tient déjà trois minutes.
Léa écrit que Radio Figuier n'est pas une scène ; je le crois, encore que certains y parlent trop fort.
Hawa ajoute : comparer n'est pas trahir, encore que chacun tienne à son banc.
Karim, sans nier que le tampon de Solange compte, préfère toutefois un geste tenu à une feuille trop vite signée.
Félicie rappelle qu'on peut toutefois boire le thé avant de décider, encore que le temps presse.
Mado notera cet avis au Cahier du chemin : un point de vue n'est pas une sentence.
Aline nous a dit qu'il faudrait nuancer, afin que personne n'idéalise un métier.
Yvette : encore que le fil soit simple, ce n'est pas un métier moindre.
Je conclus, sans crier : il me semble juste d'essayer les deux lieux, encore que le choix doive un jour se poser.
Marc
Seuil des Sources — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc conclut qu'il faut choisir ce soir, sans essayer.",
  "correct": false,
  "explanation": "Il semble juste d'essayer les deux lieux."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que gagne Patrick à faire, selon Marc, avant de parler trop vite ?",
  "options": [
    {
      "text": "Fermer Radio Figuier",
      "correct": false
    },
    {
      "text": "Mesurer un coupon",
      "correct": true
    },
    {
      "text": "Jeter le casque",
      "correct": false
    },
    {
      "text": "Refuser le thé",
      "correct": false
    }
  ],
  "explanation": "« mesurer un coupon avant de parler trop vite. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il me semble que",
      "right": "l'atelier forme les mains"
    },
    {
      "left": "on peut toutefois",
      "right": "reconnaître le relais de Lila"
    },
    {
      "left": "sans nier que",
      "right": "Patrick rêve du micro"
    },
    {
      "left": "encore que",
      "right": "Joël tremble / le fil soit simple"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSans ___ que Patrick rêve du micro, il gagne à mesurer.",
  "answer": "nier"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Comparer",
    "n'est",
    "pas",
    "trahir",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "semble",
  "hint": "Il me… que : on avance un avis sans le clouer."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Encore que chacun tient à son banc, on peut toutefois comparer sans trahir.",
  "correct_sentence": "Encore que chacun tienne à son banc, on peut toutefois comparer sans trahir.",
  "explanation": "Encore que + subjonctif : tienne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/entretien-croise.svg",
      "word": "un entretien"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/porte-essai.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/dieudonne-outil.svg",
      "word": "un outil"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/casque-joel.svg",
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
  "prompt": "Recopiez l'avis et encadrez les quatre formules ; ajoutez deux nuances à vous."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'avis de Marc, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire il me semble, encore que',
    'PO',
    $c$Objectif
Nuancer à l'oral un point de vue sur un métier du Seuil.

Consigne
Répétez, puis donnez un avis nuancé sur l'atelier ou l'antenne.

Support — Modèles d'Aline et de Patrick
Il me semble que l'atelier me convient.
On peut toutefois essayer l'antenne.
Sans nier que le silence coûte, Joël tient trois minutes.
Encore que le fil soit court, le sac peut tenir.
Il me semble juste de comparer.
On peut toutefois boire le thé avant de décider.
Sans nier que le tampon compte, je préfère un geste tenu.
Encore que je tremble, je commence.
Un avis n'est pas un verdict.
Comparer n'est pas trahir.
Aline : quatre portes, pas un mur.
Léa : Radio Figuier n'est pas une scène.
Dieudonné : encore que le coupon soit simple, le geste compte.
Lila : on peut toutefois couper à trois minutes.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Les quatre formules servent à nuancer, non à imposer un verdict.",
  "correct": true,
  "explanation": "Aline : quatre portes, pas un mur."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase emploie correctement encore que ?",
  "options": [
    {
      "text": "Encore que le fil est court",
      "correct": false
    },
    {
      "text": "Encore que le fil soit court le sac peut tenir",
      "correct": true
    },
    {
      "text": "Encore que le fil sera court",
      "correct": false
    },
    {
      "text": "Encore que le fil a été court seulement",
      "correct": false
    }
  ],
  "explanation": "Encore que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il me semble que",
      "right": "indicatif"
    },
    {
      "left": "on peut toutefois",
      "right": "infinitif / phrase"
    },
    {
      "left": "sans nier que",
      "right": "on admet"
    },
    {
      "left": "encore que",
      "right": "subjonctif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl me ___ que l'atelier me convient.",
  "answer": "semble"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Sans",
    "nier",
    "que",
    "le",
    "silence",
    "coûte",
    "Joël",
    "tient",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "nuance",
  "hint": "Avis prudent : on admet, on oppose, on ne cloue pas."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il me semble que l'atelier me convient, et encore que je dois choisir un matin j'essaierai l'antenne.",
  "correct_sentence": "Il me semble que l'atelier me convient, et encore que je doive choisir un matin j'essaierai l'antenne.",
  "explanation": "Encore que + subjonctif : doive, pas dois."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/porte-essai.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/dieudonne-outil.svg",
      "word": "un outil"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/casque-joel.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/main-poignee.svg",
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
  "prompt": "Écrivez huit avis : deux par formule (semble, toutefois, sans nier, encore que)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis votre avis nuancé."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon point de vue nuancé',
    'PE',
    $c$Objectif
Écrire un avis argumenté sur un métier du Seuil, avec les quatre formules.

Consigne
Imitez l'avis de Patrick Habimana, sans aller trop vite.

Support — Avis de Patrick Habimana
Patrick Habimana — point de vue, sans verdict
Il me semble que l'Atelier du Tissu me convient davantage, encore que Radio Figuier m'attire le jeudi.
On peut toutefois reconnaître que Lila tient un relais juste, sans nier que Dieudonné tient un sac que je voudrais savoir finir.
Sans nier que je rêve du micro, il me semble que je gagne à mesurer un coupon avant de parler trop vite.
Encore que Joël tremble au signal, on peut toutefois dire qu'il m'apprend le silence.
Aline a dit qu'un avis n'était pas une sentence ; je la crois, encore que le choix doive un jour se poser.
Hawa rappelle que comparer n'est pas trahir ; je le note au Cahier du chemin.
Karim, sans nier que le tampon de Solange compte, préfère toutefois un geste tenu.
Félicie dit qu'on peut toutefois boire le thé avant de décider, encore que le temps presse.
Léa : la radio n'est pas une scène. Dieudonné : le coupon n'est pas un métier moindre.
Je conclus : il me semble juste d'essayer les deux lieux, encore que je doive choisir un matin.
Patrick
Copie : Aline Uwase — Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick refuse d'essayer Radio Figuier.",
  "correct": false,
  "explanation": "Il semble juste d'essayer les deux lieux."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que gagne Patrick à faire, selon lui, avant de parler trop vite ?",
  "options": [
    {
      "text": "Fermer l'atelier",
      "correct": false
    },
    {
      "text": "Mesurer un coupon",
      "correct": true
    },
    {
      "text": "Jeter le Cahier",
      "correct": false
    },
    {
      "text": "Crier plus fort",
      "correct": false
    }
  ],
  "explanation": "« mesurer un coupon avant de parler trop vite. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il me semble que",
      "right": "l'atelier davantage"
    },
    {
      "left": "on peut toutefois",
      "right": "reconnaître le relais"
    },
    {
      "left": "sans nier que",
      "right": "rêve du micro"
    },
    {
      "left": "encore que",
      "right": "Joël tremble / je doive choisir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que je ___ choisir un matin. (devoir, subj.)",
  "answer": "doive"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Comparer",
    "n'est",
    "pas",
    "trahir",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "metier",
  "hint": "Atelier ou antenne : un… du Seuil, pas un titre d'ailleurs. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il me semble que l'atelier me convient, et encore que je dois choisir un matin j'essaierai les deux.",
  "correct_sentence": "Il me semble que l'atelier me convient, et encore que je doive choisir un matin j'essaierai les deux.",
  "explanation": "Encore que + subjonctif : doive."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/dieudonne-outil.svg",
      "word": "un outil"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/casque-joel.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/main-poignee.svg",
      "word": "une poignée"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/horloge-poste.svg",
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
  "prompt": "Imitez : douze à quinze lignes, les quatre formules, un métier inventé, pas de verdict sec."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre avis, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Formules pour nuancer un avis',
    'EL',
    $c$Objectif
Retenir il me semble que, on peut toutefois, sans nier que, encore que + subjonctif.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, nuances
il me semble que + indicatif : avis prudent (il me semble que l'atelier convient).
on peut toutefois + infinitif / phrase : on ajoute un autre côté (on peut toutefois essayer).
sans nier que + indicatif : on admet un fait avant d'opposer (sans nier que le silence coûte).
encore que + subjonctif : concession (encore que le fil soit court, encore que je doive choisir).
Ne pas écrire : encore que le fil est. Ne pas écrire : encore que je dois.
Un avis n'est pas un verdict. Comparer n'est pas trahir.
Réemploi possible : il a dit qu'il faudrait nuancer ; on m'a assuré que l'essai resterait possible.
Je le lui dirai sans crier. On me l'a confirmé : quatre portes, pas un mur.
Attention : il faut nuancer (pas je faut). Bien que / encore que + subj.
À + le = au métier, au Seuil. De + le = du micro, du coupon.
Les métiers du Seuil se discutent sous le figuier, pas avec un titre emprunté.
Un point de vue se nuance ; il ne se cloue pas en verdict.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Encore que je dois choisir » est la forme correcte.",
  "correct": false,
  "explanation": "Encore que je doive choisir."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle formule appelle le subjonctif ?",
  "options": [
    {
      "text": "il me semble que",
      "correct": false
    },
    {
      "text": "sans nier que",
      "correct": false
    },
    {
      "text": "encore que",
      "correct": true
    },
    {
      "text": "on peut toutefois",
      "correct": false
    }
  ],
  "explanation": "Encore que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il me semble que",
      "right": "indicatif"
    },
    {
      "left": "on peut toutefois",
      "right": "autre côté"
    },
    {
      "left": "sans nier que",
      "right": "on admet"
    },
    {
      "left": "encore que",
      "right": "subjonctif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le temps ___ , on peut boire le thé. (presser, subj.)",
  "answer": "presse"
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
    "avis",
    "n'est",
    "pas",
    "un",
    "verdict",
    "."
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
  "hint": "… que + subjonctif : on concède, puis on tient l'avis."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Sans nier que le tampon compte, encore que la feuille est lisible il manque une heure.",
  "correct_sentence": "Sans nier que le tampon compte, encore que la feuille soit lisible il manque une heure.",
  "explanation": "Encore que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/casque-joel.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/main-poignee.svg",
      "word": "une poignée"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/horloge-poste.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/feuille-charte.svg",
      "word": "une feuille"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez un mini-tableau : formule, mode, exemple d'atelier, exemple d'antenne."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et quatre phrases, une par formule."
}$j$::jsonb,
    9
  );

  -- ===== Entretien croisé Atelier / Radio =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Entretien croisé Atelier / Radio'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Entretien croisé Atelier / Radio', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Deux portes, un matin',
    'CO',
    $c$Objectif
Suivre un entretien croisé et réemployer discours indirect, compétences, pronoms et nuances.

Consigne
Lisez l'entretien. Que demande-t-on à Patrick, et que rapporte-t-il ?

Support — Atelier du Tissu puis Radio Figuier
Aline : Patrick, Dieudonné vous recevra d'abord ; Lila ensuite. Je le leur ai dit.
Dieudonné : On m'a assuré que vous saviez mesurer. Montrez-le-moi, sans trop parler.
Patrick : Il me semble que je sais plier ; je commence à maîtriser le coupon, encore que le fil me résiste.
Lila : Léa m'a demandé si vous teniez trois minutes. Joël me l'a confirmé, toutefois sans nier que vous tremblez.
Marc : Encore que l'antenne soit une oreille, on peut toutefois demander un geste d'atelier : cela rassure.
Joël : Dieudonné a dit qu'il ouvrirait à qui sait attendre ; vous avez attendu, c'est déjà une compétence.
Rose : Je le lui ai transmis, le carnet : les heures tenues, pas un titre d'ailleurs.
Hawa : Sans nier que le micro attire, il me semble plus juste d'essayer les deux portes le même matin.
Karim : Solange a demandé si la feuille serait lisible ; on me l'a confirmé pour midi.
Félicie : On peut toutefois boire le thé entre les deux portes, encore que le temps presse.
Mado : J'écrirai : il a dit qu'il essaierait ; elle a demandé s'il savait se taire ; on m'a assuré que le banc resterait libre.
Yvette : Ce n'est pas rien, que de croiser les deux lieux sans idéaliser.
Aline : Je vous le redis : un entretien croisé n'est pas un verdict. Nuancez, transmettez, rappelez.
Patrick : Je le vous redis ? — Aline : Je vous le redis. L'ordre tient aussi ici.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline corrige « je le vous redis » en « je vous le redis ».",
  "correct": true,
  "explanation": "Dernier échange."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que Dieudonné demande-t-il à Patrick de montrer ?",
  "options": [
    {
      "text": "Un titre d'ailleurs",
      "correct": false
    },
    {
      "text": "Qu'il sait mesurer, sans trop parler",
      "correct": true
    },
    {
      "text": "Qu'il sait crier",
      "correct": false
    },
    {
      "text": "Qu'il refuse le thé",
      "correct": false
    }
  ],
  "explanation": "« vous saviez mesurer. Montrez-le-moi. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je le leur ai dit",
      "right": "Aline aux deux portes"
    },
    {
      "left": "on me l'a confirmé",
      "right": "trois minutes / feuille"
    },
    {
      "left": "il me semble que",
      "right": "je sais plier"
    },
    {
      "left": "encore que",
      "right": "le fil me résiste"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ le redis : un entretien n'est pas un verdict. (vous)",
  "answer": "vous"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Montrez-le-moi",
    "sans",
    "trop",
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
  "word": "entretien",
  "hint": "Croisé : une porte à l'atelier, une porte à l'antenne, le même matin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je le vous redis calmement, et Dieudonné a dit qu'il ouvrirait à qui sait attendre.",
  "correct_sentence": "Je vous le redis calmement, et Dieudonné a dit qu'il ouvrirait à qui sait attendre.",
  "explanation": "Vous (COI) avant le (COD)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/main-poignee.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/horloge-poste.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/feuille-charte.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/etoile-competence.svg",
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
  "prompt": "Notez trois questions rapportées, deux doubles pronoms et deux nuances de l'entretien."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On m'a assuré que vous saviez mesurer. Je vous le redis. Encore que le fil me résiste, je commence."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Feuille d''entretien croisé',
    'CE',
    $c$Objectif
Lire la feuille qui croise les deux portes et les paroles rapportées.

Consigne
Lisez la feuille, sans aller trop vite.

Support — Feuille d'Aline Uwase, entretien croisé
Feuille — Patrick Habimana, deux portes le même matin
Dieudonné a dit qu'il ouvrirait à qui saurait attendre ; Patrick a attendu, puis il lui a montré un coupon mesuré.
Lila a demandé si Patrick tenait trois minutes ; Joël me l'a confirmé, encore que le silence lui coûte.
On m'a assuré que le banc resterait libre entre les deux portes ; Félicie a toutefois demandé si le thé n'était pas déjà versé.
Patrick : il me semble que je sais plier ; je commence à maîtriser le fil, sans nier que le micro m'attire.
Aline lui a dit de ne pas idéaliser : un entretien croisé n'est pas un verdict.
Rose le lui a transmis, le carnet : heures tenues, pas un titre emprunté.
Marc : encore que l'antenne soit une oreille, on peut toutefois demander un geste d'atelier.
Hawa : comparer n'est pas trahir ; Léa : la radio n'est pas une scène.
Karim a assuré que Solange tamponnerait la feuille à midi, pourvu qu'elle soit lisible.
Mado notera au Cahier du chemin : il a dit qu'il essaierait les deux ; on me l'a confirmé.
Yvette : ce n'est pas rien, que de croiser sans crier.
Je vous le redis : nuancez, transmettez, rappelez les compétences sans les enfler.
Aline Uwase — Atelier d'Aline
Seuil des Sources — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La feuille présente l'entretien croisé comme un verdict définitif.",
  "correct": false,
  "explanation": "« n'est pas un verdict. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a confirmé que Patrick tenait trois minutes ?",
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
      "text": "Karim",
      "correct": false
    },
    {
      "text": "Félicie",
      "correct": false
    }
  ],
  "explanation": "« Joël me l'a confirmé. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Dieudonné a dit que",
      "right": "il ouvrirait à qui attend"
    },
    {
      "left": "Lila a demandé si",
      "right": "trois minutes"
    },
    {
      "left": "il me semble que",
      "right": "je sais plier"
    },
    {
      "left": "je vous le redis",
      "right": "nuancez"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nRose ___ lui a transmis, le carnet.",
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
    "Un",
    "entretien",
    "croisé",
    "n'est",
    "pas",
    "un",
    "verdict",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "croise",
  "hint": "Entretien… : les deux portes le même matin. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lila a demandé que Patrick tenait trois minutes, et Joël me l'a confirmé.",
  "correct_sentence": "Lila a demandé si Patrick tenait trois minutes, et Joël me l'a confirmé.",
  "explanation": "Question rapportée : demander si."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/horloge-poste.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/feuille-charte.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/etoile-competence.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/radio-travail.svg",
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
  "prompt": "Recopiez la feuille et classez : discours indirect, compétence, pronom, nuance."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la feuille d'entretien, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire l''entretien croisé',
    'PO',
    $c$Objectif
Réemployer à l'oral les outils des quatre premières séquences, à deux portes.

Consigne
Répétez, puis jouez deux minutes d'entretien : une question, une compétence, une nuance.

Support — Modèles d'Aline, de Dieudonné et de Lila
On m'a assuré que vous saviez mesurer.
Montrez-le-moi, sans trop parler.
Il me semble que je sais plier.
Encore que le fil me résiste, je commence.
Elle a demandé si vous teniez trois minutes.
Joël me l'a confirmé.
Sans nier que le micro attire, j'essaie l'atelier.
On peut toutefois boire le thé entre les deux portes.
Je vous le redis : ce n'est pas un verdict.
Dieudonné a dit qu'il ouvrirait à qui attend.
Comparer n'est pas trahir.
Je le lui ai transmis, le carnet.
Ce n'est pas rien, que de croiser les deux lieux.
Aline : transmettez, nuancez, rappelez.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'entretien croisé réemploie les quatre outils : rapporter, nommer, transmettre, nuancer.",
  "correct": true,
  "explanation": "C'est le but de la séquence extra."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle réplique transmet une consigne avec deux pronoms ?",
  "options": [
    {
      "text": "Il me semble que je sais plier",
      "correct": false
    },
    {
      "text": "Montrez-le-moi sans trop parler",
      "correct": true
    },
    {
      "text": "Comparer n'est pas trahir",
      "correct": false
    },
    {
      "text": "Encore que le fil me résiste",
      "correct": false
    }
  ],
  "explanation": "Montrez-le-moi : impératif + le + moi."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on m'a assuré que",
      "right": "vous saviez mesurer"
    },
    {
      "left": "montrez-le-moi",
      "right": "deux pronoms"
    },
    {
      "left": "encore que",
      "right": "le fil me résiste"
    },
    {
      "left": "je vous le redis",
      "right": "pas un verdict"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSans nier que le micro attire, j'___ l'atelier. (essayer, présent)",
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
    "Comparer",
    "n'est",
    "pas",
    "trahir",
    "."
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
  "hint": "Première porte : le lieu où Dieudonné tend le coupon."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je le vous redis sans crier, et on m'a assuré que le banc resterait libre.",
  "correct_sentence": "Je vous le redis sans crier, et on m'a assuré que le banc resterait libre.",
  "explanation": "Vous avant le."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/feuille-charte.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/etoile-competence.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/radio-travail.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/nuage-choix.svg",
      "word": "des collègues"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un mini-dialogue de dix répliques : deux portes, discours indirect, un double pronom, une nuance."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis deux minutes d'entretien à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon compte d''entretien croisé',
    'PE',
    $c$Objectif
Écrire le compte rendu argumenté d'un entretien à deux portes.

Consigne
Imitez le compte de Hawa Diallo, sans aller trop vite.

Support — Compte de Hawa Diallo
Hawa Diallo — Patrick entre deux portes, le même matin
Dieudonné a dit qu'il ouvrirait à qui saurait attendre ; Patrick a attendu, puis il le lui a montré, le coupon mesuré.
Lila a demandé si Patrick tenait trois minutes ; Joël me l'a confirmé, encore que le silence lui coûte.
On m'a assuré que le banc resterait libre entre les deux portes ; Félicie a toutefois versé le thé.
Il me semble que Patrick sait plier, sans nier que le micro l'attire encore.
Aline lui a dit de ne pas idéaliser : un entretien croisé n'est pas un verdict, ce n'est pas rien que de l'écrire.
Rose le lui a transmis, le carnet : heures tenues, pas un titre d'ailleurs.
Marc : encore que l'antenne soit une oreille, on peut toutefois demander un geste d'atelier.
Léa : la radio n'est pas une scène. Dieudonné : le coupon n'est pas un métier moindre.
Karim a assuré que Solange tamponnerait la feuille à midi, pourvu qu'elle soit lisible.
Je vous le redis : comparer n'est pas trahir ; Patrick essaiera les deux, encore qu'il doive choisir un jour.
Hawa
Cahier du chemin — Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa dit que comparer, c'est trahir l'un des deux lieux.",
  "correct": false,
  "explanation": "« comparer n'est pas trahir. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que Rose a-t-elle transmis ?",
  "options": [
    {
      "text": "Un titre d'ailleurs",
      "correct": false
    },
    {
      "text": "Le carnet des heures tenues",
      "correct": true
    },
    {
      "text": "Un casque jeté",
      "correct": false
    },
    {
      "text": "Une sentence",
      "correct": false
    }
  ],
  "explanation": "« le carnet : heures tenues. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il a dit que",
      "right": "il ouvrirait"
    },
    {
      "left": "elle a demandé si",
      "right": "trois minutes"
    },
    {
      "left": "il me semble que",
      "right": "Patrick sait plier"
    },
    {
      "left": "je vous le redis",
      "right": "comparer n'est pas trahir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore qu'il ___ choisir un jour. (devoir, subj.)",
  "answer": "doive"
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
    "entretien",
    "croisé",
    "n'est",
    "pas",
    "un",
    "verdict",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "essai",
  "hint": "Les deux portes le même matin : un… , pas une sentence."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On m'a assuré si le banc resterait libre, et Félicie a toutefois versé le thé.",
  "correct_sentence": "On m'a assuré que le banc resterait libre, et Félicie a toutefois versé le thé.",
  "explanation": "Assurer que, pas assurer si."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/etoile-competence.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/radio-travail.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/nuage-choix.svg",
      "word": "des collègues"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/soleil-equipe.svg",
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
  "prompt": "Imitez : quinze lignes, deux portes, discours indirect, compétences, un double pronom, deux nuances."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre compte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Synthèse de l''entretien croisé',
    'EL',
    $c$Objectif
Relier discours indirect, compétences, doubles pronoms et nuances dans un même oral.

Consigne
Apprenez la fiche.

Support — Fiche de synthèse, deux portes
Réemploi 1 — rapporter : il a dit qu'il ouvrirait ; elle a demandé si ; on m'a assuré que.
Réemploi 2 — compétences : je sais plier ; je suis capable d'attendre ; je commence à maîtriser le fil.
Réemploi 3 — pronoms : je le lui ai transmis ; on me l'a confirmé ; montrez-le-moi ; je vous le redis.
Réemploi 4 — nuances : il me semble que ; on peut toutefois ; sans nier que ; encore que + subj.
Deux portes : Atelier du Tissu (Dieudonné) le matin, Radio Figuier (Lila, Léa, Marc, Joël) ensuite.
Un entretien croisé n'est pas un verdict. Comparer n'est pas trahir.
Ordre : me / te / nous / vous + le / la / les + lui / leur. Pas : je le vous.
Futur rapporté au passé → conditionnel : il a dit qu'il essaierait.
Encore que le silence lui coûte, Joël me l'a confirmé.
Attention : assurer que (pas si) ; demander si (question) ; dire de (ordre).
Il faut nuancer (pas je faut). À + le = au Seuil, aux deux portes.
Le Cahier du chemin garde les heures tenues, pas un titre d'ailleurs.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je le vous redis » dans l'ordre correct.",
  "correct": false,
  "explanation": "Je vous le redis."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série relie correctement les quatre réemplois ?",
  "options": [
    {
      "text": "je faut / je lui le / encore que est / assurer si",
      "correct": false
    },
    {
      "text": "il a dit qu'il essaierait / je sais plier / je vous le redis / encore que + subj.",
      "correct": true
    },
    {
      "text": "il a dit qu'il essayera seulement / je connais plier / je le vous / encore que + indicatif",
      "correct": false
    },
    {
      "text": "demander que (question) / capable à / tendez moi le / verdict obligatoire",
      "correct": false
    }
  ],
  "explanation": "Les quatre outils de la séquence, correctement formés."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il a dit que",
      "right": "conditionnel"
    },
    {
      "left": "je sais / capable de",
      "right": "compétence"
    },
    {
      "left": "je vous le redis",
      "right": "deux pronoms"
    },
    {
      "left": "encore que",
      "right": "subjonctif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ le redis : ce n'est pas un verdict.",
  "answer": "vous"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Comparer",
    "n'est",
    "pas",
    "trahir",
    "."
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
  "hint": "Fiche qui relie les quatre outils des deux portes. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il a dit qu'il essayera les deux portes, et Aline a demandé si le banc était libre.",
  "correct_sentence": "Il a dit qu'il essaierait les deux portes, et Aline a demandé si le banc était libre.",
  "explanation": "Discours indirect au passé : futur → conditionnel."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/radio-travail.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/nuage-choix.svg",
      "word": "des collègues"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/soleil-equipe.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/groupe-collegues.svg",
      "word": "une balance"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez un tableau : quatre réemplois, un exemple atelier, un exemple antenne."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et quatre phrases, une par réemploi."
}$j$::jsonb,
    9
  );

  -- ===== Charte du travail au Seuil =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Charte du travail au Seuil'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Charte du travail au Seuil', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Articles sous le figuier',
    'CO',
    $c$Objectif
Comprendre une charte inventée du travail au Seuil, et les formules qui la portent.

Consigne
Lisez le dialogue. Quels articles entend-on, et qui les défend ?

Support — Table des Sources, feuille de charte
Aline : Nous écrirons une charte, pas un règlement d'ailleurs. Elle tiendra atelier et antenne.
Dieudonné : Article premier : on a dit qu'il faudrait mesurer avant de couper, et on me l'a confirmé.
Lila : Article deux : encore que le sujet soit vaste, on coupe à trois minutes ; ce n'est pas rien.
Patrick : Il me semble que l'article trois devrait dire : un entretien n'est pas un verdict.
Léa : On peut toutefois ajouter qu'un relais du matin maîtrise le silence, sans nier que l'atelier forme les mains.
Marc : Je vous le redis : le figuier est une antenne, pas un tambour. Article quatre, métaphore douce.
Joël : On m'a assuré que Solange tamponnerait seulement une feuille lisible. Article cinq.
Rose : Sans nier que le fil casse, on peut toutefois recoudre : article six, compétence de réparation.
Hawa : Article sept : comparer n'est pas trahir ; encore que chacun tienne à sa porte, on croise.
Karim : Dieudonné a dit qu'il ouvrirait à qui saurait attendre ; cela devient un article, pas une rumeur.
Solange : Je la leur remettrai, la charte, quand les heures seront tenues. Je vous le promets.
Félicie : On peut toutefois boire le thé avant de signer, encore que le temps presse.
Mado : Le Cahier du chemin gardera la charte, afin que personne ne l'enfle demain.
Yvette : Ce n'est pas le plus faible des textes, qu'une charte écrite sous le figuier.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline refuse d'emprunter un règlement d'ailleurs.",
  "correct": true,
  "explanation": "« pas un règlement d'ailleurs. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que dit l'article deux, d'après Lila ?",
  "options": [
    {
      "text": "On parle sans limite",
      "correct": false
    },
    {
      "text": "On coupe à trois minutes, encore que le sujet soit vaste",
      "correct": true
    },
    {
      "text": "On jette le casque",
      "correct": false
    },
    {
      "text": "On ferme l'atelier",
      "correct": false
    }
  ],
  "explanation": "Lila : coupe à trois minutes."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "article premier",
      "right": "mesurer avant de couper"
    },
    {
      "left": "article deux",
      "right": "trois minutes"
    },
    {
      "left": "article trois",
      "right": "pas un verdict"
    },
    {
      "left": "article quatre",
      "right": "figuier / antenne"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ leur remettrai, la charte, quand les heures seront tenues.",
  "answer": "la"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Comparer",
    "n'est",
    "pas",
    "trahir",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "charte",
  "hint": "Texte commun du Seuil : articles d'atelier et d'antenne, pas un règlement d'ailleurs."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Encore que le sujet est vaste on coupe à trois minutes, et on me l'a confirmé.",
  "correct_sentence": "Encore que le sujet soit vaste on coupe à trois minutes, et on me l'a confirmé.",
  "explanation": "Encore que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/nuage-choix.svg",
      "word": "des collègues"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/soleil-equipe.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/groupe-collegues.svg",
      "word": "une balance"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/tampon-ok.svg",
      "word": "un discours"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez six articles entendus et la formule (indirect, pronom, nuance ou figure) qui les porte."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On a dit qu'il faudrait mesurer. Encore que le sujet soit vaste on coupe. Je vous le redis : ce n'est pas un verdict."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Charte du travail au Seuil',
    'CE',
    $c$Objectif
Lire la charte argumentée qui lie l'atelier et l'antenne.

Consigne
Lisez la charte, sans aller trop vite.

Support — Charte du travail au Seuil des Sources
Charte du travail au Seuil — feuille commune
Article 1. Dieudonné a dit qu'il faudrait mesurer avant de couper ; on me l'a confirmé : un geste tenu vaut mieux qu'un titre.
Article 2. Encore que le sujet soit vaste, Lila coupe à trois minutes ; un relais du matin maîtrise le silence.
Article 3. Il me semble juste d'écrire qu'un entretien n'est pas un verdict, encore que le choix doive un jour se poser.
Article 4. Le figuier est une antenne, pas un tambour : on y transmet, on n'y crie pas. Ce n'est pas rien.
Article 5. Solange tamponne seulement une feuille lisible ; Karim a assuré qu'elle la leur remettrait à midi.
Article 6. Sans nier que le fil casse, on peut toutefois recoudre : Rose tient cette compétence.
Article 7. Comparer n'est pas trahir : on croise atelier et radio, encore que chacun tienne à sa porte.
Article 8. On a demandé si les heures étaient tenues ; Mado les note au Cahier du chemin, afin que personne ne les déforme.
Article 9. Je vous le redis : savoir + infinitif, être capable de, commencer à maîtriser — on décrit, on ne se vante pas.
Article 10. On peut toutefois boire le thé avant de signer, encore que le temps presse ; Félicie dresse la table.
Aline Uwase, formatrice — Atelier d'Aline
Dieudonné Hakizimana, Lila Sow, Patrick Habimana
Seuil des Sources — Rukiri-Nord
Cette charte n'emprunte aucun règlement d'ailleurs.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'article 5 dit que Solange tamponne n'importe quelle feuille, même illisible.",
  "correct": false,
  "explanation": "Elle tamponne seulement une feuille lisible."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que note Mado à l'article 8 ?",
  "options": [
    {
      "text": "Des titres d'ailleurs",
      "correct": false
    },
    {
      "text": "Les heures tenues au Cahier du chemin",
      "correct": true
    },
    {
      "text": "Les rumeurs de la rive",
      "correct": false
    },
    {
      "text": "Un verdict définitif",
      "correct": false
    }
  ],
  "explanation": "« Mado les note au Cahier du chemin. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "article 1",
      "right": "mesurer avant de couper"
    },
    {
      "left": "article 3",
      "right": "pas un verdict"
    },
    {
      "left": "article 4",
      "right": "figuier / antenne"
    },
    {
      "left": "article 7",
      "right": "comparer n'est pas trahir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le choix ___ un jour se poser. (devoir, subj.)",
  "answer": "doive"
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
    "entretien",
    "n'est",
    "pas",
    "un",
    "verdict",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "devoir",
  "hint": "Article 1 : on a dit qu'il faudrait… mesurer. Un… du geste."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On a demandé que les heures étaient tenues, et Mado les note au Cahier du chemin.",
  "correct_sentence": "On a demandé si les heures étaient tenues, et Mado les note au Cahier du chemin.",
  "explanation": "Question rapportée : demander si."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/soleil-equipe.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/groupe-collegues.svg",
      "word": "une balance"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/tampon-ok.svg",
      "word": "un discours"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/balance-pratique.svg",
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
  "prompt": "Recopiez cinq articles et, pour chacun, le point de langue qu'il réemploie."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la charte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire un article de charte',
    'PO',
    $c$Objectif
Prononcer un article en réemployant les formules du module.

Consigne
Répétez, puis proposez un article à vous, nuancé, sans titre d'ailleurs.

Support — Modèles d'Aline et de Solange
On a dit qu'il faudrait mesurer avant de couper.
Encore que le sujet soit vaste, on coupe à trois minutes.
Il me semble qu'un entretien n'est pas un verdict.
Je vous le redis : le figuier est une antenne.
On me l'a confirmé : feuille lisible seulement.
Sans nier que le fil casse, on peut toutefois recoudre.
Comparer n'est pas trahir.
Je la leur remettrai, la charte, à midi.
On peut toutefois boire le thé avant de signer.
Ce n'est pas rien, qu'une charte sous le figuier.
Dieudonné : un geste tenu vaut mieux qu'un titre.
Lila : un relais maîtrise le silence.
Patrick : j'essaierai les deux portes.
Aline : on décrit, on ne se vante pas.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Un article de charte peut réemployer le discours indirect et la nuance.",
  "correct": true,
  "explanation": "Les modèles le font."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est une métaphore douce de la charte ?",
  "options": [
    {
      "text": "On coupe à trois minutes",
      "correct": false
    },
    {
      "text": "Le figuier est une antenne",
      "correct": true
    },
    {
      "text": "Feuille lisible seulement",
      "correct": false
    },
    {
      "text": "Boire le thé avant de signer",
      "correct": false
    }
  ],
  "explanation": "Le figuier est une antenne."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il faudrait mesurer",
      "right": "article 1"
    },
    {
      "left": "trois minutes",
      "right": "article 2"
    },
    {
      "left": "pas un verdict",
      "right": "article 3"
    },
    {
      "left": "figuier / antenne",
      "right": "article 4"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ leur remettrai, la charte, à midi.",
  "answer": "la"
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
    "décrit",
    "on",
    "ne",
    "se",
    "vante",
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
  "word": "equipe",
  "hint": "Atelier et antenne ensemble, sous le figuier. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je le leur remettrai la charte à midi, et on me l'a confirmé pour la feuille lisible.",
  "correct_sentence": "Je la leur remettrai la charte à midi, et on me l'a confirmé pour la feuille lisible.",
  "explanation": "La charte est féminin : la leur."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/groupe-collegues.svg",
      "word": "une balance"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/tampon-ok.svg",
      "word": "un discours"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/balance-pratique.svg",
      "word": "un parcours"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/discours-indirect.svg",
      "word": "un choix"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six articles oraux : un par formule (dit que, encore que, semble, le lui, toutefois, litote)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis un article à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon article de charte',
    'PE',
    $c$Objectif
Écrire un article argumenté pour la charte du travail au Seuil.

Consigne
Imitez l'article de Léa Niyonzima, sans aller trop vite.

Support — Article de Léa Niyonzima
Léa Niyonzima — pour la charte du Seuil
Il me semble juste d'écrire qu'un relais du matin n'est pas une scène, encore que la voix porte jusqu'au banc.
On m'a assuré que Lila couperait à trois minutes ; je le lui ai confirmé, claire comme un coupon bien tendu.
Sans nier que l'atelier forme les mains, on peut toutefois reconnaître que l'antenne forme l'oreille : comparer n'est pas trahir.
Dieudonné a dit qu'il ouvrirait à qui saurait attendre ; Aline a demandé si nous savions décrire une compétence sans nous vanter.
Je vous le redis : le figuier est une antenne, pas un tambour. Ce n'est pas rien que de s'y taire avant de parler.
Solange tamponnera seulement une feuille lisible ; Karim a assuré qu'elle la leur remettrait à midi.
Encore que Patrick doive choisir un jour, un entretien croisé n'est pas un verdict.
Rose tient la réparation : sans nier que le fil casse, on peut toutefois recoudre.
Mado notera cet article au Cahier du chemin, afin que personne ne l'enfle.
On peut toutefois boire le thé avant de signer, encore que le temps presse.
Léa
Copie : Aline Uwase, Lila Sow, Dieudonné Hakizimana
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa écrit que Radio Figuier est une scène.",
  "correct": false,
  "explanation": "« un relais du matin n'est pas une scène. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que Solange tamponnera-t-elle, d'après Léa ?",
  "options": [
    {
      "text": "N'importe quelle rumeur",
      "correct": false
    },
    {
      "text": "Seulement une feuille lisible",
      "correct": true
    },
    {
      "text": "Un titre d'ailleurs",
      "correct": false
    },
    {
      "text": "Un casque cassé",
      "correct": false
    }
  ],
  "explanation": "« seulement une feuille lisible. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il me semble que",
      "right": "pas une scène"
    },
    {
      "left": "je le lui ai confirmé",
      "right": "trois minutes / Lila"
    },
    {
      "left": "comparer n'est pas trahir",
      "right": "mains / oreille"
    },
    {
      "left": "pas un verdict",
      "right": "entretien croisé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que Patrick ___ choisir un jour. (devoir, subj.)",
  "answer": "doive"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Comparer",
    "n'est",
    "pas",
    "trahir",
    "."
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
  "hint": "Solange le pose sur une feuille lisible, jamais sur une rumeur."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je le lui ai confirmé la durée, et encore que Patrick doit choisir un jour l'entretien n'est pas un verdict.",
  "correct_sentence": "Je le lui ai confirmé la durée, et encore que Patrick doive choisir un jour l'entretien n'est pas un verdict.",
  "explanation": "Encore que + subjonctif : doive."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m7/tampon-ok.svg",
      "word": "un discours"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/balance-pratique.svg",
      "word": "un parcours"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/discours-indirect.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/parcours-pro.svg",
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
  "prompt": "Imitez : un article de douze à quinze lignes, charte locale, quatre outils du module."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre article, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Langue de la charte du Seuil',
    'EL',
    $c$Objectif
Retenir les formules qui portent une charte de travail argumentée.

Consigne
Apprenez la fiche.

Support — Fiche de clôture, charte
Une charte du Seuil réemploie : discours indirect, compétences, doubles pronoms, nuances, figures douces.
Il a dit qu'il faudrait + infinitif. Elle a demandé si + indicatif. On m'a assuré que + indicatif.
Je le lui ai transmis. On me l'a confirmé. Je vous le redis. Je la leur remettrai.
Il me semble que + indicatif. On peut toutefois. Sans nier que. Encore que + subjonctif.
Métaphore : le figuier est une antenne. Comparaison : clair comme un coupon. Litote : ce n'est pas rien.
Savoir + infinitif ; être capable de ; maîtriser ; avoir l'habitude de. Pas : je connais mesurer.
Métiers inventés seulement : teneur de coupon, relais du matin, preneur de son, tamponneur, teneur du Cahier.
Pas de règlement d'ailleurs, pas de titre emprunté, pas de ville lointaine.
Un entretien n'est pas un verdict. Comparer n'est pas trahir.
Attention : il faut (pas je faut). À + le = au Seuil. Encore que soit / doive / tienne.
Le Cahier du chemin garde la charte. On signe après le thé, pas trop vite.
Une charte locale relie l'atelier et l'antenne, sans règlement d'ailleurs.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La charte accepte un titre emprunté à une école d'ailleurs.",
  "correct": false,
  "explanation": "Pas de titre emprunté, pas de ville lointaine."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série est correcte pour la charte ?",
  "options": [
    {
      "text": "je faut / je lui le / encore que est",
      "correct": false
    },
    {
      "text": "il faudrait / je vous le redis / encore que soit",
      "correct": true
    },
    {
      "text": "assurer si / je connais mesurer / je le vous",
      "correct": false
    },
    {
      "text": "demander que (question) / capable à / verdict obligatoire",
      "correct": false
    }
  ],
  "explanation": "Il faudrait, je vous le redis, encore que soit."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il a dit qu'il faudrait",
      "right": "nécessité rapportée"
    },
    {
      "left": "je vous le redis",
      "right": "deux pronoms"
    },
    {
      "left": "encore que + subj.",
      "right": "concession"
    },
    {
      "left": "Cahier du chemin",
      "right": "garde la charte"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn m'a assuré ___ Solange tamponnerait une feuille lisible.",
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
    "figuier",
    "est",
    "une",
    "antenne",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pratique",
  "hint": "Geste tenu à l'atelier ou à l'antenne, plus sûr qu'un titre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "À le Seuil on signe la charte après le thé, et on me l'a confirmé.",
  "correct_sentence": "Au Seuil on signe la charte après le thé, et on me l'a confirmé.",
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
      "image_path": "/elearning/mfk-b2-m7/balance-pratique.svg",
      "word": "un parcours"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/discours-indirect.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/parcours-pro.svg",
      "word": "un curriculum"
    },
    {
      "image_path": "/elearning/mfk-b2-m7/choix-vie.svg",
      "word": "une compétence"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez un tableau final : dix articles possibles, chacun avec un point de langue du module."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et cinq articles, chacun avec une formule différente."
}$j$::jsonb,
    9
  );

END;
$$;
