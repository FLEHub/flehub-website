/*
  Seed eLearning MFK — B2 — Tendances du Seuil

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b2-m1/
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
  v_module_title text := 'B2 — Tendances du Seuil';
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
      'Grande étape B2-1 : analyser une mode, interroger une consommation, opposer des vacances, introduire un texte explicatif, débattre sous le figuier et signer une chronique pour Radio Figuier — Rose Iradukunda coupe un tissu à la Salle des Herbes, Félicie compare le Marché des Lampions au Marché des Herbes, Lila Sow tend le micro, et le Seuil des Sources (Rukiri-Nord) discute de ce qui passe et de ce qui reste.',
      'B2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B2-1 : analyser une mode, interroger une consommation, opposer des vacances, introduire un texte explicatif, débattre sous le figuier et signer une chronique pour Radio Figuier — Rose Iradukunda coupe un tissu à la Salle des Herbes, Félicie compare le Marché des Lampions au Marché des Herbes, Lila Sow tend le micro, et le Seuil des Sources (Rukiri-Nord) discute de ce qui passe et de ce qui reste.',
      cefr_level = 'B2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Mode et apparence =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Mode et apparence'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Mode et apparence', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Un tissu convaincant, des lanternes fatiguantes',
    'CO',
    $c$Objectif
Distinguer participe présent et adjectif verbal ; repérer le participe composé d'antériorité.

Consigne
Lisez l'entretien (à écouter avec l'enseignant). Qui parle d'une action, qui parle d'une qualité ?

Support — Entretien sous le figuier, lanternes du soir
Lila Sow : Rose, votre tissu convainc-t-il encore, ou convainc-t-il trop ?
Rose Iradukunda : Ayant fini l'ourlet ce matin, je peux dire : le tissu est convaincant, pas seulement convainquant les passants.
Aline Uwase : Attention : convainquant décrit l'action ; convaincant, la qualité. Les deux ne s'écrivent pas pareil.
Patrick Habimana : Ces lanternes sont fatigantes à porter, alors que les coudre n'est pas fatiguant si l'on s'arrête.
Léa Niyonzima : Étant partie avant midi, Hawa n'a pas vu le premier essayage. Antériorité : elle était déjà loin.
Marc Nkurunziza : Une mode provocante n'est pas une mode provoquant un scandale : l'une juge, l'autre agit.
Hawa Diallo : Je trouve les arguments de Rose convaincants. J'entends le c, pas le qu.
Joël Mugisha : Ayant choisi le lin ocre, elle refuse le plastique brillant du Marché des Lampions.
Solange Mukamana : Une coupe naviguant entre deux rives reste plus intéressante qu'un modèle trop navigant, trop sage.
Karim Bamba : Analysons : qui porte, qui vend, qui copie. Une tendance n'est pas un ordre.
Félicie : Les lanternes du figuier éclairent le tissu ; le tissu n'éclaire pas forcément les lanternes.
Dieudonné : Moi, je répare. Une couture fatiguant les doigts n'est pas forcément une mode fatigante à voir.
Yvette : Lila, gardez le micro : le Seuil a besoin d'un avis, pas d'un défilé muet.
Mado : Sami dira ce soir si le lin convainc les anciens autant que les plus jeunes.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose emploie « convaincant » pour la qualité du tissu, et « convainquant » pour l'action sur les passants.",
  "correct": true,
  "explanation": "Rose oppose la qualité (convaincant) et l'action (convainquant les passants)."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Aline, quelle distinction faut-il retenir ?",
  "options": [
    {
      "text": "Les deux formes s'écrivent toujours pareil",
      "correct": false
    },
    {
      "text": "Convainquant décrit l'action, convaincant la qualité",
      "correct": true
    },
    {
      "text": "Le participe composé est interdit sous le figuier",
      "correct": false
    },
    {
      "text": "Fatigant et fatiguant n'existent pas",
      "correct": false
    }
  ],
  "explanation": "Aline : convainquant = action ; convaincant = qualité."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "convainquant",
      "right": "action, invariable"
    },
    {
      "left": "convaincant",
      "right": "qualité, accord"
    },
    {
      "left": "ayant fini",
      "right": "antériorité, avoir"
    },
    {
      "left": "étant partie",
      "right": "antériorité, être"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAyant ___ l'ourlet, Rose peut parler. (finir)",
  "answer": "fini"
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
    "tissu",
    "est",
    "convaincant",
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
  "word": "convaincant",
  "hint": "Adjectif : un argument qui emporte l'adhésion, avec un c."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ayant fini l'ourlet, Rose rangea le lin, et cette coupe est convainquant.",
  "correct_sentence": "Ayant fini l'ourlet, Rose rangea le lin, et cette coupe est convaincante.",
  "explanation": "Adjectif verbal : convaincant s'accorde (convaincante)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/mode-apparence.svg",
      "word": "une mode"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/participe-present.svg",
      "word": "un participe"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/adjectif-verbal.svg",
      "word": "un adjectif"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/tissu-tendance.svg",
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
  "prompt": "Relevez trois participes présents et trois adjectifs verbaux, puis une forme ayant / étant + participe."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Ayant fini l'ourlet, je range. Le tissu est convaincant. Les lanternes sont fatigantes."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Analyser une mode au Seuil',
    'CE',
    $c$Objectif
Lire un article qui analyse une tendance (tissu, lanternes) et les formes en -ant.

Consigne
Lisez l'article épinglé à la Salle des Herbes, sans aller trop vite.

Support — Article de Mado, Cahier du chemin
Analyser une mode, ce n'est pas l'adorer.
Rose Iradukunda coupe, à la Salle des Herbes, un lin ocre qui traverse le Seuil des Sources.
Ayant fini trois ourlets avant l'aube, elle a pu comparer le tissu aux lanternes du soir.
Ces lanternes, fatiguant les bras de Joël, restent pourtant moins fatigantes à regarder qu'un plastique trop brillant.
Une mode convainquant les passants du Marché des Lampions n'est pas forcément une mode convaincante pour Karim.
Il faut distinguer l'action (participe présent, invariable) et la qualité (adjectif verbal, accordé).
Étant rentrée de Rive-des-Saules, Léa a noté : le même lin paraît plus calme sous le figuier qu'au Pavillon du Saule.
Marc écrit que le Seuil n'importe pas une tendance : il la discute.
Solange ajoute qu'une coupe provocante peut rester juste, si elle ne cherche pas seulement à provoquer.
Lila Sow relira ce texte à Radio Figuier : analyser, ce n'est pas condamner.
Félicie, elle, regarde les mains : une couture fatiguant les doigts mérite un salaire, pas seulement un compliment.
Yvette rappelle qu'une lanterne n'est pas un bijou ; c'est un outil de soirée, un signal.
Sami, plus prudent, demande : qui copie qui, et pour quel marché ?
Nous tiendrons ce débat jeudi, ayant lu ce cahier, pas en le feuilletant trop vite.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'article dit qu'analyser une mode, c'est l'adorer.",
  "correct": false,
  "explanation": "Première ligne : analyser, ce n'est pas l'adorer."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que rappelle Yvette au sujet des lanternes ?",
  "options": [
    {
      "text": "Qu'elles valent un bijou de Lampe-Figue",
      "correct": false
    },
    {
      "text": "Qu'elles sont interdites sous le figuier",
      "correct": false
    },
    {
      "text": "Qu'une lanterne est un outil de soirée, un signal",
      "correct": true
    },
    {
      "text": "Que Rose refuse toutes les lanternes",
      "correct": false
    }
  ],
  "explanation": "Yvette : une lanterne n'est pas un bijou ; c'est un outil, un signal."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "fatiguant les bras",
      "right": "participe présent"
    },
    {
      "left": "moins fatigantes",
      "right": "adjectif verbal"
    },
    {
      "left": "étant rentrée",
      "right": "antériorité, être"
    },
    {
      "left": "ayant lu",
      "right": "antériorité, avoir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne mode ___ les passants n'est pas forcément convaincante. (convaincre, p. présent)",
  "answer": "convainquant"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ayant",
    "fini",
    "trois",
    "ourlets",
    "elle",
    "compare",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "fatiguant",
  "hint": "Participe : une couture qui lasse les bras, avec un u."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les lanternes sont fatiguantes à regarder, et Joël les porte encore.",
  "correct_sentence": "Les lanternes sont fatigantes à regarder, et Joël les porte encore.",
  "explanation": "Adjectif verbal : fatigant, sans u ; fatiguant est le participe."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/participe-present.svg",
      "word": "un participe"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/adjectif-verbal.svg",
      "word": "un adjectif"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/tissu-tendance.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/assiette-futur.svg",
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
  "prompt": "Soulignez cinq formes en -ant et classez-les : action ou qualité."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'article, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire ayant fini, étant partie, convaincant',
    'PO',
    $c$Objectif
Prononcer le participe composé et opposer à l'oral action et qualité.

Consigne
Répétez les modèles, puis analysez une mode que vous voyez au Seuil.

Support — Modèles d'Aline et de Rose, banc du figuier
Ayant fini l'ourlet, je range les ciseaux.
Étant partie tôt, Hawa n'a pas vu l'essayage.
Ce tissu est convaincant : il emporte l'adhésion.
Cette coupe, convainquant les passants, reste simple.
Les lanternes sont fatigantes à porter le soir.
Porter les lanternes, fatiguant les bras, demande un relais.
Une mode provocante n'est pas forcément une mode provoquant la colère.
Ayant choisi le lin, Rose refuse le plastique.
Étant rentrée, Léa compare les deux rives.
Il faut un avis, pas un silence.
Je serai prête jeudi, ayant relu mes notes.
Patrick : le participe présent ne s'accorde pas.
Rose : l'adjectif verbal, lui, s'accorde.
Lila : gardez ces phrases pour le micro, clairement.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le participe présent s'accorde avec le nom comme un adjectif.",
  "correct": false,
  "explanation": "Patrick : le participe présent ne s'accorde pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase marque l'antériorité avec être ?",
  "options": [
    {
      "text": "Ce tissu est convaincant",
      "correct": false
    },
    {
      "text": "Ayant fini l'ourlet, je range",
      "correct": false
    },
    {
      "text": "Étant partie tôt, Hawa n'a pas vu l'essayage",
      "correct": true
    },
    {
      "text": "Les lanternes sont fatigantes",
      "correct": false
    }
  ],
  "explanation": "Étant partie : être + participe, action déjà faite."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ayant fini",
      "right": "j'ai déjà fini"
    },
    {
      "left": "étant partie",
      "right": "elle était déjà partie"
    },
    {
      "left": "convaincant",
      "right": "qualité"
    },
    {
      "left": "convainquant",
      "right": "action"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nÉtant ___ tôt, Hawa n'a pas vu l'essayage. (partir, fém.)",
  "answer": "partie"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ayant",
    "choisi",
    "le",
    "lin",
    "Rose",
    "refuse",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ayant",
  "hint": "Forme en -ant de avoir, suivie d'un participe, pour l'avant."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Étant parti trop tôt, Hawa a manqué l'essayage, et le lin reste ocre.",
  "correct_sentence": "Étant partie trop tôt, Hawa a manqué l'essayage, et le lin reste ocre.",
  "explanation": "Avec être, le participe s'accorde : Hawa → partie."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/adjectif-verbal.svg",
      "word": "un adjectif"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/tissu-tendance.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/assiette-futur.svg",
      "word": "une assiette"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/consommation.svg",
      "word": "une consommation"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases : trois ayant / étant + participe, trois oppositions action / qualité."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis deux analyses à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon analyse d''une mode',
    'PE',
    $c$Objectif
Écrire une courte analyse de tendance avec participes et adjectifs verbaux.

Consigne
Imitez la note de Rose Iradukunda.

Support — Note de Rose, Salle des Herbes
Rose Iradukunda — Seuil des Sources, Rukiri-Nord
Ayant fini l'ourlet du lin ocre, je peux comparer sans me hâter.
Cette coupe est convaincante pour le jeudi, pas seulement convainquant les passants du Marché des Lampions.
Les lanternes, fatiguant les bras de Joël, restent moins fatigantes à voir qu'un plastique trop lisse.
Étant rentrée de Val-des-Peupliers, Léa m'a dit que le même tissu change de voix sous le saule.
Je refuse une mode provocante qui ne ferait que provoquer, sans habiller personne.
Il faut un salaire pour les doigts, pas seulement un compliment pour l'œil.
Karim demandera qui copie qui ; j'aurai déjà noté trois réponses.
Je serai au banc, ayant relu ces lignes, si Lila ouvre le micro.
Une tendance n'est pas un ordre : on l'analyse, on ne l'obéit pas.
Félicie apportera un bol ; Dieudonné un relais pour les lanternes.
Voilà mon avis, ni trop doux, ni trop dur.
Rose
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose écrit qu'une tendance est un ordre auquel on obéit.",
  "correct": false,
  "explanation": "« Une tendance n'est pas un ordre : on l'analyse, on ne l'obéit pas. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que refuse Rose ?",
  "options": [
    {
      "text": "Le lin ocre",
      "correct": false
    },
    {
      "text": "Une mode provocante qui ne ferait que provoquer",
      "correct": true
    },
    {
      "text": "Le bol de Félicie",
      "correct": false
    },
    {
      "text": "Le micro de Lila",
      "correct": false
    }
  ],
  "explanation": "Elle refuse une mode qui provoque sans habiller."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ayant fini",
      "right": "pouvoir comparer"
    },
    {
      "left": "convaincante",
      "right": "qualité de la coupe"
    },
    {
      "left": "fatiguant les bras",
      "right": "action"
    },
    {
      "left": "étant rentrée",
      "right": "Léa"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCette coupe est ___ pour le jeudi. (convaincant, fém.)",
  "answer": "convaincante"
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
    "tendance",
    "n'est",
    "pas",
    "un",
    "ordre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lanternes",
  "hint": "Lumières de papier accrochées le soir au Seuil."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je serais au banc jeudi dès que j'aurai relu ces lignes, et Lila ouvrira le micro.",
  "correct_sentence": "Je serai au banc jeudi dès que j'aurai relu ces lignes, et Lila ouvrira le micro.",
  "explanation": "Futur réel : je serai, pas le conditionnel je serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/tissu-tendance.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/assiette-futur.svg",
      "word": "une assiette"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/consommation.svg",
      "word": "une consommation"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/marche-herbes.svg",
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
  "prompt": "Imitez : douze lignes, deux formes ayant / étant, deux paires action / qualité."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre analyse, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Participe présent, adjectif verbal, ayant fini',
    'EL',
    $c$Objectif
Retenir l'orthographe, l'accord et l'antériorité des formes en -ant.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline Uwase, banc ocre
Participe présent : invariable, valeur de verbe (action).
nous convainquons → convainquant ; nous fatiguons → fatiguant ; nous provoquons → provoquant.
Adjectif verbal : s'accorde, valeur de qualité ; parfois autre orthographe.
convaincant(e)(s), fatigant(e)(s), provocant(e)(s), différent(e)(s).
Une mode convainquant les passants / un argument convaincant.
Une couture fatiguant les bras / une soirée fatigante.
Participe composé (antériorité) : ayant + participe passé (avoir) ; étant + participe passé (être).
Ayant fini l'ourlet, Rose range. Étant partie, Hawa n'a rien vu.
Ayant / étant se placent souvent en tête, suivis d'une virgule.
Ne pas écrire : cette mode est convainquant (accord manquant).
Ne pas écrire : les lanternes sont fatiguantes (u du verbe, ici c'est l'adjectif).
Analyser une mode : qui porte, qui vend, qui copie, qui paie les mains.
Tissu de Rose, lanternes du figuier, Salle des Herbes : le Seuil discute, il n'obéit pas.
Il faut un exemple de chaque forme, pas seulement une liste morte.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'adjectif verbal reste toujours invariable.",
  "correct": false,
  "explanation": "L'adjectif verbal s'accorde ; le participe présent, lui, est invariable."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme marque l'antériorité avec avoir ?",
  "options": [
    {
      "text": "étant partie",
      "correct": false
    },
    {
      "text": "convaincant",
      "correct": false
    },
    {
      "text": "ayant fini",
      "correct": true
    },
    {
      "text": "fatigantes",
      "correct": false
    }
  ],
  "explanation": "Ayant + participe passé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "convainquant",
      "right": "nous convainquons"
    },
    {
      "left": "convaincant",
      "right": "qualité, accord"
    },
    {
      "left": "ayant fini",
      "right": "antériorité avoir"
    },
    {
      "left": "étant partie",
      "right": "antériorité être"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne soirée ___ n'est pas une couture fatiguant les bras. (fatigant, fém.)",
  "answer": "fatigante"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ayant",
    "fini",
    "l'ourlet",
    "Rose",
    "range",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ourlets",
  "hint": "Bords de vêtement que l'on coud pour achever une pièce."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il fautons distinguer l'action et la qualité, et Rose a déjà fini l'ourlet.",
  "correct_sentence": "Il faut distinguer l'action et la qualité, et Rose a déjà fini l'ourlet.",
  "explanation": "Toujours il faut, à la 3e personne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/assiette-futur.svg",
      "word": "une assiette"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/consommation.svg",
      "word": "une consommation"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/marche-herbes.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/horloge-anterieur.svg",
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
  "prompt": "Dressez un tableau : six paires participe / adjectif, plus quatre phrases ayant / étant."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre phrases d'analyse."
}$j$::jsonb,
    9
  );

  -- ===== Tendance alimentaire =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Tendance alimentaire'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Tendance alimentaire', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le bol de Félicie, deux marchés',
    'CO',
    $c$Objectif
Repérer le futur antérieur et les arguments sur la consommation.

Consigne
Lisez le débat (à écouter avec l'enseignant). Quand l'action sera-t-elle déjà finie ?

Support — Débat à la Table des Sources, bols ocre
Félicie : Quand j'aurai fini ce bol, je le laverai moi-même. Pas de pile pour plus tard.
Karim Bamba : Dès que le Marché des Lampions aura fermé, le Marché des Herbes ouvrira encore une heure.
Aline Uwase : Une fois que vous aurez comparé les prix, vous parlerez de goût, pas seulement d'argent.
Léa Niyonzima : Je mangerai sous le figuier quand Patrick aura choisi les feuilles, pas avant.
Patrick Habimana : Si je prends trop vite, je n'aurai rien compris au bol. Il faut du temps.
Marc Nkurunziza : Contrairement au plastique des Lampions, les herbes se nomment, se pèsent, se discutent.
Hawa Diallo : Lorsque nous aurons goûté les deux marchés, nous pourrons voter, pas seulement crier.
Joël Mugisha : Je ferai la file aux Herbes dès que j'aurai posé les lanternes.
Rose Iradukunda : Une consommation convaincante n'est pas une consommation qui convainc par le bruit.
Solange Mukamana : Lila, quand tu auras enregistré ces voix, tu couperas les insultes, pas les doutes.
Lila Sow : Radio Figuier relayera le débat lorsque Félicie aura parlé jusqu'au fond du bol.
Dieudonné : Moi, je réparerai la table une fois que vous aurez fini de taper dessus.
Yvette : Il faut un prix juste. Quand le Seuil aura payé les mains, il pourra parler de tendance.
Sami : Les anciens diront, après que nous aurons écouté, si le bol ressemble encore à celui d'autrefois.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Félicie lavera le bol avant de l'avoir fini.",
  "correct": false,
  "explanation": "Quand j'aurai fini ce bol, je le laverai : d'abord finir, ensuite laver."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fera Karim dès que le Marché des Lampions aura fermé ?",
  "options": [
    {
      "text": "Il fermera aussi le Marché des Herbes",
      "correct": false
    },
    {
      "text": "Le Marché des Herbes ouvrira encore une heure",
      "correct": true
    },
    {
      "text": "Il interdira les bols",
      "correct": false
    },
    {
      "text": "Il partira à Val-des-Peupliers",
      "correct": false
    }
  ],
  "explanation": "Karim : le Marché des Herbes ouvrira encore une heure."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "quand j'aurai fini",
      "right": "ensuite je laverai"
    },
    {
      "left": "dès que … aura fermé",
      "right": "l'autre marché continue"
    },
    {
      "left": "une fois que vous aurez comparé",
      "right": "ensuite le goût"
    },
    {
      "left": "lorsque nous aurons goûté",
      "right": "ensuite voter"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nQuand j'___ fini ce bol, je le laverai. (avoir, FA)",
  "answer": "aurai"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Quand",
    "j'aurai",
    "fini",
    "je",
    "laverai",
    "le",
    "bol",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "consommation",
  "hint": "Façon d'acheter et de manger, discutée aux deux marchés."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quand j'aurai fini le bol, je le laverai, et je ferrai la file aux Herbes.",
  "correct_sentence": "Quand j'aurai fini le bol, je le laverai, et je ferai la file aux Herbes.",
  "explanation": "Futur de faire : je ferai, un seul r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/consommation.svg",
      "word": "une consommation"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/marche-herbes.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/horloge-anterieur.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/vacances-seuil.svg",
      "word": "des vacances"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez cinq futur antérieurs et l'action qui vient après chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Quand j'aurai fini ce bol, je le laverai. Dès que le marché aura fermé, je rentrerai."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Manger après avoir choisi',
    'CE',
    $c$Objectif
Lire un article sur la consommation au Seuil et le futur antérieur.

Consigne
Lisez la chronique du Marché des Herbes, sans aller trop vite.

Support — Chronique de Lila Sow, Radio Figuier
On ne parle pas d'un bol comme on parle d'une mode : on l'épuise, ou on le respecte.
Félicie sert, chaque matin, un plat dont le nom change selon les bottes du Marché des Herbes.
Ce marché-là n'existe sur aucune carte officielle : le Seuil l'a inventé, entre le figuier et la Salle des Herbes.
Le Marché des Lampions, lui, brille plus tôt et ferme plus vite ; il vend aussi des feuilles, mais trop emballées.
Quand les Lampions auront fermé, les Herbes auront encore des voix, des balances, des doutes.
Il faut avoir comparé les deux files avant de crier à la trahison.
Dès que le Seuil aura payé le juste prix, il pourra parler de « tendance alimentaire » sans rougir.
Une fois que vous aurez goûté le bol, vous direz s'il console ou s'il montre.
Marc Nkurunziza écrit que consommer, ce n'est pas collectionner des assiettes.
Aline rappelle le futur antérieur : l'action sera déjà faite quand l'autre commencera.
Joël, lorsqu'il aura posé la dernière lanterne, s'assiéra ; pas avant.
Léa et Patrick iront à Rive-des-Saules seulement quand ils auront laissé un mot à Félicie.
Yvette note les estomacs sensibles : une tendance n'excuse pas une indigestion.
Nous jugerons jeudi, lorsque nous aurons fini d'écouter, pas lorsque nous aurons fini de nous interrompre.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le Marché des Herbes figure sur les cartes officielles de Rukiri-Nord.",
  "correct": false,
  "explanation": "Le Seuil l'a inventé ; il n'existe sur aucune carte officielle."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quand Joël s'assiéra-t-il, selon la chronique ?",
  "options": [
    {
      "text": "Avant d'avoir posé les lanternes",
      "correct": false
    },
    {
      "text": "Lorsqu'il aura posé la dernière lanterne",
      "correct": true
    },
    {
      "text": "Seulement à Val-des-Peupliers",
      "correct": false
    },
    {
      "text": "Jamais, par principe",
      "correct": false
    }
  ],
  "explanation": "Lorsqu'il aura posé la dernière lanterne, il s'assiéra ; pas avant."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "quand … auront fermé",
      "right": "les Herbes continuent"
    },
    {
      "left": "dès que … aura payé",
      "right": "ensuite parler"
    },
    {
      "left": "une fois que vous aurez goûté",
      "right": "ensuite dire"
    },
    {
      "left": "lorsque nous aurons fini",
      "right": "ensuite juger"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDès que le Seuil ___ payé le juste prix, il pourra parler. (avoir, FA)",
  "answer": "aura"
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
    "fois",
    "que",
    "vous",
    "aurez",
    "goûté",
    "parlez",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "herbes",
  "hint": "Végétaux du marché inventé, pas seulement ceux du jardin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quand je finirai le bol, je le laverai déjà, et Félicie rangera les cuillères.",
  "correct_sentence": "Quand j'aurai fini le bol, je le laverai déjà, et Félicie rangera les cuillères.",
  "explanation": "Antériorité au futur : quand j'aurai fini, pas quand je finirai."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/marche-herbes.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/horloge-anterieur.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/vacances-seuil.svg",
      "word": "des vacances"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/opposition.svg",
      "word": "une opposition"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez quatre phrases au futur antérieur et dites l'action qui suit."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la chronique, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire quand j''aurai fini',
    'PO',
    $c$Objectif
Employer à l'oral le futur antérieur avec quand, dès que, une fois que, lorsque.

Consigne
Répétez, puis parlez d'un repas que vous ne commencerez qu'après un choix.

Support — Modèles de Félicie et d'Aline
Quand j'aurai fini ce bol, je le laverai.
Dès que le marché aura fermé, je rentrerai sous le figuier.
Une fois que tu auras goûté, tu diras le vrai, pas le poli.
Lorsque nous aurons comparé les deux files, nous voterons.
Après que vous aurez payé, vous pourrez critiquer le prix.
Je n'ouvrirai pas l'assiette avant d'avoir choisi.
Nous serons calmes lorsque la balance aura parlé.
Tu auras compris le bol seulement quand tu l'auras fini.
Ils partiront à Rive-des-Saules dès qu'ils auront laissé un mot.
Je ferai la file aux Herbes, pas aux Lampions trop vite.
Je pourrai juger seulement lorsque j'aurai écouté Yvette.
Félicie : le futur antérieur, c'est « déjà fait » dans le futur.
Aline : pas de pile pour plus tard, pas de jugement trop tôt.
Lila : dites-le au micro, une phrase, une pause.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Quand j'aurai fini » place la fin du bol avant le lavage.",
  "correct": true,
  "explanation": "Futur antérieur : action déjà accomplie avant l'autre."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est au futur antérieur ?",
  "options": [
    {
      "text": "Je lave le bol",
      "correct": false
    },
    {
      "text": "Je laverai le bol",
      "correct": false
    },
    {
      "text": "Quand j'aurai fini ce bol, je le laverai",
      "correct": true
    },
    {
      "text": "J'ai fini ce bol",
      "correct": false
    }
  ],
  "explanation": "J'aurai fini = avoir au futur + participe."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "quand j'aurai fini",
      "right": "ensuite laver"
    },
    {
      "left": "dès que … aura fermé",
      "right": "ensuite rentrer"
    },
    {
      "left": "une fois que tu auras goûté",
      "right": "ensuite dire"
    },
    {
      "left": "lorsque nous aurons comparé",
      "right": "ensuite voter"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne fois que tu ___ goûté, tu diras le vrai. (avoir, FA)",
  "answer": "auras"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Dès",
    "que",
    "le",
    "marché",
    "aura",
    "fermé",
    "je",
    "rentrerai",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "aurons",
  "hint": "Forme de avoir au futur, personne nous, avant un participe."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lorsque nous aurons comparé les files, nous pourai voter sans crier.",
  "correct_sentence": "Lorsque nous aurons comparé les files, nous pourrons voter sans crier.",
  "explanation": "Futur de pouvoir : nous pourrons, deux r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/horloge-anterieur.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/vacances-seuil.svg",
      "word": "des vacances"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/opposition.svg",
      "word": "une opposition"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/concession.svg",
      "word": "une concession"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases : quand / dès que / une fois que / lorsque + futur antérieur."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis deux phrases à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma note de consommation',
    'PE',
    $c$Objectif
Écrire une note argumentée sur un bol, deux marchés et le futur antérieur.

Consigne
Imitez la note de Félicie.

Support — Note de Félicie, Marché des Herbes
Félicie — Seuil des Sources, derrière la Salle des Herbes
Quand j'aurai fini de servir, je m'assiérai. Pas avant, pas sur le comptoir des Lampions.
Le Marché des Herbes n'a pas de tampon officiel ; il a des balances et des noms.
Dès que les Lampions auront fermé leur bruit, nos feuilles parleront plus clairement.
Une fois que vous aurez goûté le bol, vous direz s'il console ou s'il montre trop.
Il faut un prix qui tienne les mains, pas seulement l'œil.
Je ferai la soupe de jeudi lorsque Léa aura laissé son mot pour Rive-des-Saules.
Patrick aura compris le goût seulement quand il aura fini, lentement.
Yvette veillera : une tendance n'excuse pas une indigestion.
Lila, quand tu auras coupé les insultes, tu pourras garder les doutes.
Karim demandera qui invente le marché ; je répondrai : ceux qui pèsent.
Je serai là, ayant déjà lavé le bol, si le Seuil veut encore un avis.
Félicie
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Félicie s'assiéra avant d'avoir fini de servir.",
  "correct": false,
  "explanation": "Quand j'aurai fini de servir, je m'assiérai. Pas avant."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que répondra Félicie à Karim, qui demande qui invente le marché ?",
  "options": [
    {
      "text": "Radio Figuier seulement",
      "correct": false
    },
    {
      "text": "Ceux qui pèsent",
      "correct": true
    },
    {
      "text": "Val-des-Peupliers",
      "correct": false
    },
    {
      "text": "Personne",
      "correct": false
    }
  ],
  "explanation": "« je répondrai : ceux qui pèsent. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "quand j'aurai fini",
      "right": "ensuite s'asseoir"
    },
    {
      "left": "dès que … auront fermé",
      "right": "les feuilles parlent"
    },
    {
      "left": "une fois que vous aurez goûté",
      "right": "ensuite dire"
    },
    {
      "left": "lorsque Léa aura laissé",
      "right": "ensuite la soupe"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ferai la soupe lorsque Léa ___ laissé son mot. (avoir, FA)",
  "answer": "aura"
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
    "serai",
    "là",
    "ayant",
    "déjà",
    "lavé",
    "le",
    "bol",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lampions",
  "hint": "Lumières du marché du soir, plus emballées que les feuilles."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dès que les Lampions auront fermé, je pourai parler plus clairement, et le bol attendra.",
  "correct_sentence": "Dès que les Lampions auront fermé, je pourrai parler plus clairement, et le bol attendra.",
  "explanation": "Futur de pouvoir : je pourrai, deux r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/vacances-seuil.svg",
      "word": "des vacances"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/opposition.svg",
      "word": "une opposition"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/concession.svg",
      "word": "une concession"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/valise-commentaire.svg",
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
  "prompt": "Imitez : douze lignes, quatre futur antérieurs, un avis sur les deux marchés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre note, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Futur antérieur et consommation',
    'EL',
    $c$Objectif
Retenir la formation et les emplois du futur antérieur.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, horloge de la Salle des Herbes
Futur antérieur = avoir / être au futur + participe passé.
j'aurai fini, tu auras goûté, elle aura fermé, nous aurons comparé, vous aurez payé, ils auront voté.
Avec être : je serai rentrée, nous serons partis (accord).
Emplois : action déjà accomplie dans le futur, souvent après quand, dès que, une fois que, lorsque, après que.
Quand j'aurai fini le bol, je le laverai. (d'abord finir, ensuite laver)
Ne pas dire : quand je finirai le bol, je le laverai déjà — on veut l'antériorité.
Ne pas confondre je serai (futur) et je serais (conditionnel).
Ne pas écrire je ferrai (un r : je ferai) ni je pourai (deux r : je pourrai).
Consommation au Seuil : Marché des Herbes (inventé, balances, noms) / Marché des Lampions (bruit, emballages).
Bol de Félicie : servir, goûter, laver, payer les mains.
Une tendance alimentaire n'excuse pas un prix injuste ni une indigestion.
Il faut avoir comparé avant de crier.
Radio Figuier relayera lorsque Lila aura coupé les insultes, pas les doutes.
Le futur antérieur sert l'argument : on ne juge pas trop tôt.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On forme le futur antérieur avec avoir ou être au futur, plus un participe passé.",
  "correct": true,
  "explanation": "j'aurai fini / je serai rentrée."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est correcte pour un futur réel ?",
  "options": [
    {
      "text": "je serais prêt demain",
      "correct": false
    },
    {
      "text": "je serai prêt demain",
      "correct": true
    },
    {
      "text": "je suis prêt demain uniquement",
      "correct": false
    },
    {
      "text": "je serais été prêt",
      "correct": false
    }
  ],
  "explanation": "Futur de être : je serai."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "quand j'aurai fini",
      "right": "ensuite une autre action"
    },
    {
      "left": "je serai",
      "right": "futur"
    },
    {
      "left": "je serais",
      "right": "conditionnel"
    },
    {
      "left": "je ferai / je pourrai",
      "right": "1 r / 2 r"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ comparé les deux files avant de voter. (avoir, FA)",
  "answer": "aurons"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Quand",
    "j'aurai",
    "fini",
    "je",
    "jugerai",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "horloge",
  "hint": "Objet qui rappelle qu'une action sera déjà faite avant l'autre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quand j'aurai fini le bol je le laverai, et je serais prêt pour le jeudi réel.",
  "correct_sentence": "Quand j'aurai fini le bol je le laverai, et je serai prêt pour le jeudi réel.",
  "explanation": "Projet réel : je serai, pas je serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/opposition.svg",
      "word": "une opposition"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/concession.svg",
      "word": "une concession"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/valise-commentaire.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/conjonction-temps.svg",
      "word": "une conjonction"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Conjuguez six verbes au futur antérieur et écrivez quatre phrases avec quand / dès que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis cinq phrases au futur antérieur."
}$j$::jsonb,
    9
  );

  -- ===== Vacances et pratiques sociales =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Vacances et pratiques sociales'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Vacances et pratiques sociales', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Partir ou rester, pourtant le jeudi',
    'CO',
    $c$Objectif
Repérer opposition (alors que, tandis que, contrairement à) et concession (bien que, pourtant, néanmoins, quoi que).

Consigne
Lisez le débat. Qui oppose deux pratiques, qui concède sans céder ?

Support — Débat sous le figuier, valises à peine fermées
Léa Niyonzima : Alors que Patrick rêve déjà de Rive-des-Saules, moi je tiens encore au banc ocre.
Patrick Habimana : Tandis que tu comptes les jeudis, je compte les jours de pont et d'eau.
Aline Uwase : Contrairement à une fuite, des vacances se préparent : dates, clés, mots.
Marc Nkurunziza : Bien que ce soit tentant, partir n'efface pas le Seuil ; ça le déplace.
Hawa Diallo : Quoi que vous décidiez, Radio Figuier reliera les voix.
Joël Mugisha : Pourtant les lanternes auront besoin d'un relais, même en août.
Rose Iradukunda : Néanmoins je coudrai : les vacances des uns sont le travail des autres.
Solange Mukamana : On peut aimer Val-des-Peupliers tout en refusant d'idéaliser le Pavillon du Saule.
Karim Bamba : Alors que le Marché des Lampions s'emballe, le figuier reste un rythme.
Lila Sow : Bien qu'il fasse chaud, nous enregistrerons le matin, pas à midi.
Félicie : Je resterai. Pourtant je ne juge pas ceux qui plient une valise.
Dieudonné : Tandis que certains partent, je répare les bancs : concession n'est pas défaite.
Yvette : Contrairement aux affiches trop gaies, un repos se mérite, il ne s'achète pas en trois mots.
Sami : Quoi que le Seuil invente comme « tendance des vacances », les anciens demanderont qui garde la cour.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc dit que partir efface complètement le Seuil.",
  "correct": false,
  "explanation": "Bien que ce soit tentant, partir n'efface pas le Seuil ; ça le déplace."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle conjonction de concession emploie Hawa ?",
  "options": [
    {
      "text": "alors que",
      "correct": false
    },
    {
      "text": "tandis que",
      "correct": false
    },
    {
      "text": "contrairement à",
      "correct": false
    },
    {
      "text": "quoi que",
      "correct": true
    }
  ],
  "explanation": "Hawa : Quoi que vous décidiez…"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "alors que / tandis que",
      "right": "opposition"
    },
    {
      "left": "contrairement à",
      "right": "opposition nominale"
    },
    {
      "left": "bien que / quoi que",
      "right": "concession + subjonctif"
    },
    {
      "left": "pourtant / néanmoins",
      "right": "concession, indicatif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nBien que ce ___ tentant, partir n'efface pas le Seuil. (être, subj.)",
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
    "Quoi",
    "que",
    "vous",
    "décidiez",
    "nous",
    "relierons",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "opposition",
  "hint": "Rapport entre deux pratiques qui ne vont pas ensemble."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que ce est tentant, partir n'efface pas le Seuil, et Léa tient au banc.",
  "correct_sentence": "Bien que ce soit tentant, partir n'efface pas le Seuil, et Léa tient au banc.",
  "explanation": "Bien que + subjonctif : soit, pas est."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/concession.svg",
      "word": "une concession"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/valise-commentaire.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/conjonction-temps.svg",
      "word": "une conjonction"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/texte-explicatif.svg",
      "word": "un texte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Relevez quatre oppositions et quatre concessions, avec le mot-outil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Alors que tu pars, je reste. Bien que ce soit loin, nous tiendrons au jeudi."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Vacances du Seuil, pratiques en débat',
    'CE',
    $c$Objectif
Lire un article qui oppose et concède des pratiques de repos.

Consigne
Lisez l'édito de Marc, sans aller trop vite.

Support — Édito de Marc Nkurunziza, feuille ocre
On appelle « vacances » un départ, alors que certains se reposent sans quitter Rukiri-Nord.
Tandis que Léa plie une chemise pour le Pavillon du Saule, Félicie allonge le temps du bol.
Contrairement aux affiches trop lisses, un repos se discute : qui garde la cour, qui paie les lanternes.
Bien que Val-des-Peupliers promette l'eau et le pont, le Seuil ne devient pas une erreur.
Pourtant l'envie de partir n'est pas une trahison ; elle est une hypothèse.
Néanmoins Joël demandera un relais : les vacances des uns sont le travail des autres.
Quoi que l'on choisisse, il faut un mot sous le figuier, pas un silence habillé de soleil.
Aline écrit que s'opposer, ce n'est pas se quereller : c'est nommer deux pratiques.
Karim ajoute qu'une tendance de voyage se vend trop vite au Marché des Lampions.
Lila tiendra le micro le matin, bien qu'il fasse déjà chaud.
Rose coudra, alors que d'autres nageront ; les deux gestes peuvent rester justes.
Sami, plus lent, rappelle les anciens : on partait moins, on racontait plus.
Yvette nuance : un estomac fatigué n'a pas les mêmes vacances qu'un dos reposé.
Nous lirons cet édito jeudi, ayant déjà entendu les deux rives, pas une seule.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'édito dit que l'envie de partir est forcément une trahison.",
  "correct": false,
  "explanation": "Pourtant l'envie de partir n'est pas une trahison ; elle est une hypothèse."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que demandera Joël, selon Marc ?",
  "options": [
    {
      "text": "La fermeture du figuier",
      "correct": false
    },
    {
      "text": "Un relais, parce que les vacances des uns sont le travail des autres",
      "correct": true
    },
    {
      "text": "Que Félicie parte",
      "correct": false
    },
    {
      "text": "Que Radio Figuier se taise",
      "correct": false
    }
  ],
  "explanation": "Néanmoins Joël demandera un relais."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "alors que / tandis que",
      "right": "deux pratiques en même temps"
    },
    {
      "left": "contrairement à",
      "right": "les affiches trop lisses"
    },
    {
      "left": "bien que",
      "right": "Val-des-Peupliers / le Seuil"
    },
    {
      "left": "quoi que",
      "right": "il faut un mot"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nQuoi que l'on ___, il faut un mot sous le figuier. (choisir, subj.)",
  "answer": "choisisse"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Pourtant",
    "partir",
    "n'est",
    "pas",
    "une",
    "trahison",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "concession",
  "hint": "Rapport : on admet un fait sans renoncer à son avis."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien qu'il fait déjà chaud, Lila tiendra le micro le matin, et Joël cherchera un relais.",
  "correct_sentence": "Bien qu'il fasse déjà chaud, Lila tiendra le micro le matin, et Joël cherchera un relais.",
  "explanation": "Bien que + subjonctif : fasse, pas fait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/valise-commentaire.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/conjonction-temps.svg",
      "word": "une conjonction"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/texte-explicatif.svg",
      "word": "un texte"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/fleche-quand.svg",
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
  "prompt": "Classez huit connecteurs du texte : opposition ou concession."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'édito, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire alors que, bien que, néanmoins',
    'PO',
    $c$Objectif
Enchaîner à l'oral opposition et concession sur les vacances du Seuil.

Consigne
Répétez les modèles, puis défendez un choix : partir ou rester.

Support — Modèles d'Aline, valise et banc
Alors que tu plies la valise, je tiens au banc.
Tandis que le pont attire, le figuier retient.
Contrairement à une fuite, des vacances se préparent.
Bien que ce soit loin, nous écrirons le jeudi.
Quoi que vous décidiez, laissez un mot.
Pourtant je ne juge pas ceux qui partent.
Néanmoins il faut un relais pour les lanternes.
On peut aimer l'eau tout en refusant d'idéaliser le pavillon.
Je partirai trois jours, alors que Rose coudra encore.
Je resterai, bien que l'eau me tente.
Hawa : concession, ce n'est pas abandonner son avis.
Marc : opposition, ce n'est pas insulter.
Lila : une phrase d'opposition, une phrase de concession, puis le micro.
Sami : les anciens opposaient moins, ils concédaient plus lentement.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Bien que » se construit avec le subjonctif.",
  "correct": true,
  "explanation": "Bien que ce soit loin ; quoi que vous décidiez."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est une opposition, pas une concession ?",
  "options": [
    {
      "text": "Bien que ce soit loin, nous écrirons",
      "correct": false
    },
    {
      "text": "Pourtant je ne juge pas",
      "correct": false
    },
    {
      "text": "Néanmoins il faut un relais",
      "correct": false
    },
    {
      "text": "Alors que tu plies la valise, je tiens au banc",
      "correct": true
    }
  ],
  "explanation": "Alors que oppose deux pratiques simultanées."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "alors que",
      "right": "opposition"
    },
    {
      "left": "bien que",
      "right": "concession + subj."
    },
    {
      "left": "pourtant",
      "right": "concession, indicatif"
    },
    {
      "left": "contrairement à",
      "right": "opposition + nom"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nContrairement ___ une fuite, des vacances se préparent.",
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
    "Bien",
    "que",
    "ce",
    "soit",
    "loin",
    "nous",
    "écrirons",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "neanmoins",
  "hint": "Connecteur de concession, sans accent ici, proche de pourtant."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quoi que vous décidez ce soir, laissez un mot, et Joël cherchera un relais.",
  "correct_sentence": "Quoi que vous décidiez ce soir, laissez un mot, et Joël cherchera un relais.",
  "explanation": "Quoi que + subjonctif : décidiez."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/conjonction-temps.svg",
      "word": "une conjonction"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/texte-explicatif.svg",
      "word": "un texte"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/fleche-quand.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/cahier-analyse.svg",
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
  "prompt": "Écrivez dix phrases : cinq oppositions, cinq concessions, sur partir / rester."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis votre choix argumenté."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon commentaire de vacances',
    'PE',
    $c$Objectif
Écrire un commentaire qui oppose deux pratiques et concède sans céder.

Consigne
Imitez le commentaire de Léa Niyonzima.

Support — Commentaire de Léa, enveloppe pour le figuier
Léa Niyonzima — vers Rive-des-Saules, encore au Seuil
Alors que Patrick compte déjà les planches du pont, je compte encore les jeudis.
Tandis que la valise se ferme, le banc ocre reste ouvert : les deux gestes existent.
Contrairement aux affiches du Marché des Lampions, je n'achète pas un repos en trois mots.
Bien que Val-des-Peupliers me tente, je refuse d'appeler le Seuil une erreur.
Pourtant je partirai trois jours : concession n'est pas oubli.
Néanmoins Joël aura un relais, et Félicie un mot, avant midi.
Quoi que Sami raconte des anciens, nous avons droit à une eau différente, sans trahir.
Je serai au Pavillon du Saule lorsque j'aurai laissé cette feuille sous le figuier.
Rose coudra, alors que je marcherai : je ne jugerai pas son lin, qu'elle ne juge pas mon pont.
Lila pourra lire ceci le matin, bien qu'il fasse chaud.
Voilà mon avis, ni trop léger, ni trop fidèle.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa appelle le Seuil une erreur parce qu'elle part.",
  "correct": false,
  "explanation": "Bien que Val-des-Peupliers me tente, je refuse d'appeler le Seuil une erreur."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de jours Léa part-elle, et à quelle condition pour Joël ?",
  "options": [
    {
      "text": "Un mois, sans relais",
      "correct": false
    },
    {
      "text": "Trois jours, et Joël aura un relais",
      "correct": true
    },
    {
      "text": "Elle ne part jamais",
      "correct": false
    },
    {
      "text": "Elle part seulement si Rose ferme l'atelier",
      "correct": false
    }
  ],
  "explanation": "Pourtant je partirai trois jours […] Joël aura un relais."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "alors que",
      "right": "Patrick / jeudis"
    },
    {
      "left": "contrairement à",
      "right": "les affiches"
    },
    {
      "left": "bien que",
      "right": "Val-des-Peupliers"
    },
    {
      "left": "néanmoins",
      "right": "un relais"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLila pourra lire ceci, bien qu'il ___ chaud. (faire, subj.)",
  "answer": "fasse"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Pourtant",
    "je",
    "partirai",
    "trois",
    "jours",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "quoique",
  "hint": "Conjonction de concession en un mot, suivie du subjonctif."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que Val-des-Peupliers me tente, je serais au pavillon dès que j'aurai laissé cette feuille : c'est un projet réel.",
  "correct_sentence": "Bien que Val-des-Peupliers me tente, je serai au pavillon dès que j'aurai laissé cette feuille : c'est un projet réel.",
  "explanation": "Projet réel : je serai, pas je serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/texte-explicatif.svg",
      "word": "un texte"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/fleche-quand.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/cahier-analyse.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/debat-tendances.svg",
      "word": "un débat"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : douze lignes, trois oppositions, trois concessions, un relais nommé."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre commentaire, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Opposition et concession',
    'EL',
    $c$Objectif
Retenir les outils pour opposer deux faits et concéder sans abandonner.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, valise et banc
Opposition : deux faits qui ne vont pas dans le même sens, souvent en même temps.
alors que + indicatif ; tandis que + indicatif ; contrairement à + nom.
Alors que tu pars, je reste. Tandis que l'eau attire, le figuier retient.
Contrairement à une fuite, des vacances se préparent.
Concession : on admet un obstacle, on maintient l'avis.
bien que / quoique / quoi que + subjonctif.
Bien qu'il fasse chaud, nous enregistrons. Quoi que vous décidiez, laissez un mot.
pourtant, néanmoins, toutefois + indicatif (souvent après une virgule, ou en tête).
Pourtant je ne juge pas. Néanmoins il faut un relais.
même si + indicatif (concession plus orale).
Ne pas écrire : bien que c'est loin → bien que ce soit loin.
Vacances au Seuil : partir à Rive-des-Saules / rester, garder la cour, payer les lanternes.
Les vacances des uns sont le travail des autres : Rose, Joël, Félicie, Dieudonné.
Il faut nommer la pratique, pas insulter la personne.
Une tendance de voyage se discute, elle ne s'obéit pas.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Contrairement à » se construit avec un nom, pas avec une proposition complète.",
  "correct": true,
  "explanation": "Contrairement à une fuite, contrairement aux affiches."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série demande le subjonctif ?",
  "options": [
    {
      "text": "alors que, tandis que",
      "correct": false
    },
    {
      "text": "pourtant, néanmoins",
      "correct": false
    },
    {
      "text": "bien que, quoique, quoi que",
      "correct": true
    },
    {
      "text": "contrairement à seulement",
      "correct": false
    }
  ],
  "explanation": "Bien que / quoique / quoi que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "alors que / tandis que",
      "right": "indicatif"
    },
    {
      "left": "bien que / quoi que",
      "right": "subjonctif"
    },
    {
      "left": "pourtant / néanmoins",
      "right": "indicatif"
    },
    {
      "left": "contrairement à",
      "right": "nom"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAlors que tu ___, je reste au banc. (partir, ind.)",
  "answer": "pars"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Néanmoins",
    "il",
    "faut",
    "un",
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
  "word": "tandis",
  "hint": "Conjonction : pendant que, parfois pour opposer deux faits."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que c'est loin, nous écrirons le jeudi, et Joël aura son relais.",
  "correct_sentence": "Bien que ce soit loin, nous écrirons le jeudi, et Joël aura son relais.",
  "explanation": "Bien que + subjonctif : ce soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/fleche-quand.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/cahier-analyse.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/debat-tendances.svg",
      "word": "un débat"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/table-figuier.svg",
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
  "prompt": "Rédigez un tableau : outils d'opposition / de concession, mode, un exemple chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis six phrases : trois oppositions, trois concessions."
}$j$::jsonb,
    9
  );

  -- ===== Introduire un texte explicatif =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Introduire un texte explicatif'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Introduire un texte explicatif', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Quand le texte commence à expliquer',
    'CO',
    $c$Objectif
Repérer les conjonctions de temps qui ordonnent un texte explicatif.

Consigne
Lisez le briefing. Dans quel ordre Lila veut-elle les étapes ?

Support — Briefing à Radio Figuier, horloge du studio
Lila Sow : Un texte explicatif n'est pas un récit d'aventure. Il fait comprendre un processus.
Aline Uwase : Lorsque le jeudi commence, on dit d'abord de quoi l'on parle, ensuite comment cela marche.
Marc Nkurunziza : Dès que le titre a nommé l'objet — lanternes, bol, tissu — les étapes peuvent suivre.
Rose Iradukunda : Une fois que l'on a décrit le geste, on peut en donner la raison.
Patrick Habimana : Tandis que tu expliques le « comment », évite déjà le « trop beau ».
Hawa Diallo : Aussi longtemps que les étapes manquent, l'auditeur doute, et il a raison.
Joël Mugisha : Quand j'aurai accroché la première lanterne, vous pourrez dire « ensuite ».
Léa Niyonzima : Après que Félicie a nommé les herbes, on comprend le bol ; avant, on devine.
Solange Mukamana : Jusqu'à ce que le Cahier du chemin soit ouvert, on n'invente pas une archive.
Karim Bamba : Introduire, c'est cadrer : lieu, objet, public. Pas un slogan.
Félicie : Aussi longtemps que le prix reste flou, l'explication du plat reste incomplète.
Dieudonné : Lorsque la table est stable, les voix portent. J'explique avec les mains.
Yvette : Dès que l'on promet trop, l'explication devient une publicité. Attention.
Sami : Les anciens expliquaient aussi longtemps que l'enfant tenait encore assis, pas plus.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila dit qu'un texte explicatif est d'abord un récit d'aventure.",
  "correct": false,
  "explanation": "Un texte explicatif n'est pas un récit d'aventure. Il fait comprendre un processus."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il faire, selon Marc, dès que le titre a nommé l'objet ?",
  "options": [
    {
      "text": "Couper le micro",
      "correct": false
    },
    {
      "text": "Laisser les étapes suivre",
      "correct": true
    },
    {
      "text": "Raconter une légende seulement",
      "correct": false
    },
    {
      "text": "Interdire les conjonctions",
      "correct": false
    }
  ],
  "explanation": "Dès que le titre a nommé l'objet, les étapes peuvent suivre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lorsque",
      "right": "cadre temporel soutenu"
    },
    {
      "left": "dès que",
      "right": "immédiatement après"
    },
    {
      "left": "une fois que",
      "right": "après achèvement"
    },
    {
      "left": "aussi longtemps que",
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
  "prompt": "Complétez :\n___ le jeudi commence, on dit d'abord de quoi l'on parle.",
  "answer": "Lorsque"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Dès",
    "que",
    "le",
    "titre",
    "nomme",
    "l'objet",
    "expliquez",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lorsque",
  "hint": "Conjonction de temps plus soutenue que quand."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi longtemps que les étapes manquent l'auditeur doute, et il fautons un ordre clair.",
  "correct_sentence": "Aussi longtemps que les étapes manquent l'auditeur doute, et il faut un ordre clair.",
  "explanation": "Toujours il faut, à la 3e personne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/cahier-analyse.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/debat-tendances.svg",
      "word": "un débat"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/table-figuier.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/micro-chronique.svg",
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
  "prompt": "Notez cinq conjonctions de temps et l'étape qu'elles introduisent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Lorsque le jeudi commence, on cadre. Dès que le titre nomme, on explique."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Comment le Seuil allume ses lanternes',
    'CE',
    $c$Objectif
Lire un texte explicatif ordonné par des conjonctions de temps.

Consigne
Lisez le texte de Joël, sans aller trop vite.

Support — Texte explicatif de Joël Mugisha, Salle des Herbes
Comment le Seuil allume-t-il ses lanternes, le jeudi ?
Lorsque le soleil baisse derrière Rukiri-Nord, Joël sort les armatures de Lampe-Figue, rien d'autre.
Dès que Dieudonné a vérifié le fil, on peut parler de lumière, pas avant.
Une fois que Rose a glissé le papier ocre, la lanterne a une peau ; elle n'est plus un cercle vide.
Tandis que Karim pèse l'huile à la balance du Marché des Herbes, Lila prépare le micro : deux gestes, un même soir.
Aussi longtemps que le vent trop sec agite le figuier, on n'accroche pas trop haut.
Après que Félicie a posé le bol du relais, ceux qui portent peuvent s'arrêter sans honte.
Quand la première lanterne brûle, le Cahier du chemin s'ouvre : on note l'heure, pas un slogan.
Jusqu'à ce que Sami ait dit le nom des anciens, on n'appelle pas cela une fête, seulement une veille.
Aline cadre : objet (lanterne), lieu (cour), public (ceux qui restent et ceux qui passent).
Marc ajoute qu'expliquer, c'est refuser le « c'est magique » trop vite.
Léa, étant rentrée, compare : à Rive-des-Saules, le pont éclaire autrement ; ici, ce sont des mains.
Yvette rappelle qu'une flamme n'est pas un jouet : l'explication inclut le danger.
Nous relirons ces étapes jeudi, lorsque nous aurons fini d'écouter, pas lorsque nous aurons fini de nous presser.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On accroche les lanternes très haut même si le vent trop sec agite le figuier.",
  "correct": false,
  "explanation": "Aussi longtemps que le vent trop sec agite le figuier, on n'accroche pas trop haut."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait-on dès que Dieudonné a vérifié le fil ?",
  "options": [
    {
      "text": "On ferme Radio Figuier",
      "correct": false
    },
    {
      "text": "On peut parler de lumière, pas avant",
      "correct": true
    },
    {
      "text": "On vend les lanternes aux Lampions",
      "correct": false
    },
    {
      "text": "On part au Pavillon du Saule",
      "correct": false
    }
  ],
  "explanation": "Dès que Dieudonné a vérifié le fil, on peut parler de lumière."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lorsque le soleil baisse",
      "right": "sortir les armatures"
    },
    {
      "left": "dès que le fil est vérifié",
      "right": "parler de lumière"
    },
    {
      "left": "une fois que le papier est glissé",
      "right": "la lanterne a une peau"
    },
    {
      "left": "aussi longtemps que le vent",
      "right": "ne pas trop haut"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne fois que Rose ___ glissé le papier, la lanterne a une peau. (avoir)",
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
    "Lorsque",
    "le",
    "soleil",
    "baisse",
    "Joël",
    "sort",
    "les",
    "armatures",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "explicatif",
  "hint": "Texte qui fait comprendre un processus, pas une aventure."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lorsque le soleil baisse Joël sort les armatures, et il ferra la file trop vite s'il se presse.",
  "correct_sentence": "Lorsque le soleil baisse Joël sort les armatures, et il fera la file trop vite s'il se presse.",
  "explanation": "Futur de faire : il fera, un seul r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/debat-tendances.svg",
      "word": "un débat"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/table-figuier.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/micro-chronique.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/radio-figuier.svg",
      "word": "une radio"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Numérotez les étapes du texte et recopiez la conjonction qui les ouvre."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte explicatif, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire lorsque, dès que, une fois que',
    'PO',
    $c$Objectif
Ordonner à l'oral un processus avec des conjonctions de temps.

Consigne
Répétez, puis expliquez un geste du Seuil en six étapes.

Support — Modèles d'Aline et de Lila, studio
Lorsque le jeudi commence, on cadre l'objet.
Dès que le titre a nommé, les étapes suivent.
Une fois que le geste est décrit, on en donne la raison.
Tandis que l'un explique le comment, l'autre prépare le micro.
Aussi longtemps que les étapes manquent, on ne conclut pas.
Quand la première lanterne brûle, on note l'heure.
Après que le fil a été vérifié, on parle de lumière.
Jusqu'à ce que Sami ait dit les noms, on n'appelle pas cela une fête.
Je commencerai lorsque j'aurai ouvert le cahier.
Vous comprendrez dès que j'aurai montré les mains.
Nous arrêterons aussi longtemps que le vent sera trop sec.
Lila : une conjonction par étape, pas trois dans la même phrase.
Marc : expliquer, ce n'est pas décorer.
Aline : le public doit pouvoir refaire le geste.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Aussi longtemps que » exprime une durée, pas un instant.",
  "correct": true,
  "explanation": "Aussi longtemps que les étapes manquent / que le vent est trop sec."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle conjonction convient pour « immédiatement après » ?",
  "options": [
    {
      "text": "aussi longtemps que",
      "correct": false
    },
    {
      "text": "dès que",
      "correct": true
    },
    {
      "text": "tandis que seulement",
      "correct": false
    },
    {
      "text": "contrairement à",
      "correct": false
    }
  ],
  "explanation": "Dès que = dès l'instant où."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lorsque",
      "right": "cadre"
    },
    {
      "left": "dès que",
      "right": "juste après"
    },
    {
      "left": "une fois que",
      "right": "après l'achèvement"
    },
    {
      "left": "tandis que",
      "right": "simultanéité"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAussi longtemps que les étapes ___, on ne conclut pas. (manquer)",
  "answer": "manquent"
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
    "fois",
    "que",
    "le",
    "geste",
    "est",
    "décrit",
    "expliquez",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "aussitot",
  "hint": "Mot : … que, pour une action qui suit sans délai. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dès que le titre aura nommé l'objet, je ferrai suivre les étapes, et Lila coupera les slogans.",
  "correct_sentence": "Dès que le titre aura nommé l'objet, je ferai suivre les étapes, et Lila coupera les slogans.",
  "explanation": "Futur de faire : je ferai, un seul r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/table-figuier.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/micro-chronique.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/rose-couture.svg",
      "word": "une couture"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Expliquez un geste en huit phrases, chacune ouverte par une conjonction différente."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis votre processus en six étapes."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon texte explicatif',
    'PE',
    $c$Objectif
Écrire un texte explicatif cadré et ordonné par le temps.

Consigne
Imitez le texte de Solange Mukamana.

Support — Texte de Solange, Cahier du chemin
Solange Mukamana — Comment on ouvre le Cahier du chemin, le jeudi
Lorsque le soleil a assez baissé, on pose le cahier sur la table du figuier, pas par terre.
Dès que Karim a essuyé la poussière, Aline dit l'objet : ce que l'on veut comprendre ce soir.
Une fois que le titre est dit, on n'ajoute pas un slogan. On enchaîne les gestes.
Tandis que Lila règle le micro, Marc numérote les étapes à voix haute, pour que chacun suive.
Aussi longtemps que Sami n'a pas confirmé un nom d'ancien, on n'écrit pas ce nom.
Après que Rose a décrit un ourlet, on peut expliquer pourquoi le lin tient.
Quand Félicie a nommé une herbe, le bol cesse d'être un mystère.
Jusqu'à ce que Dieudonné ait dit « la table tient », on n'y pose pas le cahier trop lourd.
Je serai la gardienne de l'ordre : expliquer, c'est permettre de refaire, pas d'admirer.
Yvette ajoutera le danger s'il y a flamme ou couteau.
Voilà un cadre, ni trop sec, ni trop paré.
Solange
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Solange veut qu'on ajoute un slogan dès que le titre est dit.",
  "correct": false,
  "explanation": "Une fois que le titre est dit, on n'ajoute pas un slogan."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Aussi longtemps que Sami n'a pas confirmé un nom, que fait-on ?",
  "options": [
    {
      "text": "On l'écrit quand même",
      "correct": false
    },
    {
      "text": "On n'écrit pas ce nom",
      "correct": true
    },
    {
      "text": "On ferme Radio Figuier",
      "correct": false
    },
    {
      "text": "On part au pavillon",
      "correct": false
    }
  ],
  "explanation": "Aussi longtemps que Sami n'a pas confirmé, on n'écrit pas ce nom."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lorsque",
      "right": "poser le cahier"
    },
    {
      "left": "dès que",
      "right": "dire l'objet"
    },
    {
      "left": "une fois que",
      "right": "pas de slogan"
    },
    {
      "left": "aussi longtemps que",
      "right": "pas de nom douteux"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLorsque le soleil a assez ___, on pose le cahier. (baisser)",
  "answer": "baissé"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Expliquer",
    "c'est",
    "permettre",
    "de",
    "refaire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "processus",
  "hint": "Suite d'étapes expliquées dans un texte clair."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lorsque j'aurai ouvert le cahier, je serais la gardienne de l'ordre, et Marc numérotera.",
  "correct_sentence": "Lorsque j'aurai ouvert le cahier, je serai la gardienne de l'ordre, et Marc numérotera.",
  "explanation": "Projet réel : je serai, pas je serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/micro-chronique.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/rose-couture.svg",
      "word": "une couture"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/felicie-bol.svg",
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
  "prompt": "Imitez : un processus en douze lignes, cinq conjonctions de temps différentes."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre texte explicatif, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Conjonctions de temps pour expliquer',
    'EL',
    $c$Objectif
Retenir les conjonctions qui ordonnent un texte explicatif.

Consigne
Apprenez la fiche.

Support — Fiche de Lila, studio de Radio Figuier
lorsque + indicatif : cadre, souvent plus soutenu que quand.
dès que + indicatif : immédiatement après (dès que le fil est vérifié).
une fois que + indicatif : après l'achèvement (une fois que le titre est dit).
tandis que + indicatif : simultanément (parfois aussi opposition).
aussi longtemps que + indicatif : durée, limite (aussi longtemps que le vent est sec).
quand : plus courant ; après que + indicatif ; jusqu'à ce que + subjonctif.
Introduire un texte explicatif : 1) nommer l'objet 2) cadrer lieu et public 3) ordonner les étapes 4) donner la raison 5) inclure le danger s'il y en a.
Ce n'est pas un récit d'aventure, ni une publicité, ni un slogan.
Objets du Seuil à expliquer : lanternes, bol, ourlet, ouverture du Cahier du chemin.
Futur antérieur possible : je commencerai lorsque j'aurai ouvert le cahier.
Ne pas entasser trois conjonctions dans la même phrase.
Le public doit pouvoir refaire le geste.
Radio Figuier : une phrase, une pause, pas trop vite.
Il faut un ordre, pas une magie.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Jusqu'à ce que » se construit avec le subjonctif.",
  "correct": true,
  "explanation": "Jusqu'à ce que Sami ait dit les noms / que Dieudonné ait dit que la table tient."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel est le premier geste pour introduire un texte explicatif, selon la fiche ?",
  "options": [
    {
      "text": "Conclure",
      "correct": false
    },
    {
      "text": "Nommer l'objet",
      "correct": true
    },
    {
      "text": "Vendre le geste",
      "correct": false
    },
    {
      "text": "Couper les doutes",
      "correct": false
    }
  ],
  "explanation": "1) nommer l'objet, puis cadrer, puis ordonner."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lorsque",
      "right": "cadre"
    },
    {
      "left": "dès que",
      "right": "juste après"
    },
    {
      "left": "aussi longtemps que",
      "right": "durée"
    },
    {
      "left": "jusqu'à ce que",
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
  "prompt": "Complétez :\nJusqu'à ce que Sami ___ dit les noms, on attend. (avoir, subj.)",
  "answer": "ait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Dès",
    "que",
    "le",
    "fil",
    "est",
    "vérifié",
    "expliquez",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "chronologie",
  "hint": "Ordre des étapes dans le temps, pour faire comprendre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi longtemps que le vent est trop sec on attend, et il fautons un ordre des étapes.",
  "correct_sentence": "Aussi longtemps que le vent est trop sec on attend, et il faut un ordre des étapes.",
  "explanation": "Toujours il faut, à la 3e personne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/rose-couture.svg",
      "word": "une couture"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/felicie-bol.svg",
      "word": "un bol"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/lanterne-soir.svg",
      "word": "une lanterne"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Pour cinq conjonctions : construction, valeur, une phrase explicative."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis un mini-texte explicatif de six lignes."
}$j$::jsonb,
    9
  );

  -- ===== Débattre des tendances =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Débattre des tendances'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Débattre des tendances', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Pour et contre, sous le figuier',
    'CO',
    $c$Objectif
Suivre une synthèse orale qui reprend mode, bol, vacances et explication.

Consigne
Lisez la table ronde. Qui synthétise, qui refuse le slogan ?

Support — Table ronde sous le figuier, jeudi
Aline Uwase : D'une part le lin de Rose convainc ; d'autre part les lanternes fatiguent les bras. On tient les deux.
Marc Nkurunziza : En revanche, appeler tout cela « tendance » trop vite, c'est vendre avant d'avoir compris.
Lila Sow : Autrement dit : analyser, expliquer, puis débattre. Pas l'inverse.
Léa Niyonzima : Je concède que le pont attire, néanmoins le jeudi reste un argument.
Patrick Habimana : Certes le bol de Félicie console ; toutefois il ne remplace pas un salaire juste.
Hawa Diallo : D'un côté les Lampions brillent ; de l'autre les Herbes nomment. Je penche vers les noms.
Joël Mugisha : Pour ma part, je relayerai les lanternes, quoi que l'on vote sur les vacances.
Rose Iradukunda : Ayant fini trois ourlets, je peux dire : une mode n'est pas un ordre.
Solange Mukamana : En somme, le Seuil n'obéit pas ; il compare.
Karim Bamba : Reste que quelqu'un paie : les mains, l'huile, le micro.
Félicie : Je synthétise par un bol : quand vous aurez fini de crier, vous goûterez.
Dieudonné : La table tient. C'est déjà un argument.
Yvette : Attention aux estomacs et aux flammes : un débat n'efface pas un danger.
Sami : Les anciens diraient : ce que le figuier a vu, ce n'est pas un slogan. C'est une suite de gestes.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Solange conclut que le Seuil obéit aux tendances dès qu'elles brillent.",
  "correct": false,
  "explanation": "En somme, le Seuil n'obéit pas ; il compare."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Dans quel ordre Lila veut-elle les opérations ?",
  "options": [
    {
      "text": "Débattre, puis expliquer, puis analyser",
      "correct": false
    },
    {
      "text": "Vendre, puis voter",
      "correct": false
    },
    {
      "text": "Analyser, expliquer, puis débattre",
      "correct": true
    },
    {
      "text": "Crier, puis goûter",
      "correct": false
    }
  ],
  "explanation": "Analyser, expliquer, puis débattre. Pas l'inverse."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'une part / d'autre part",
      "right": "deux plateaux"
    },
    {
      "left": "en revanche",
      "right": "opposition forte"
    },
    {
      "left": "certes / toutefois",
      "right": "concession puis maintien"
    },
    {
      "left": "en somme",
      "right": "synthèse"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nD'une part le lin convainc ; d'___ part les lanternes fatiguent.",
  "answer": "autre"
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
    "somme",
    "le",
    "Seuil",
    "compare",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tendances",
  "hint": "Modes et habitudes qui circulent sous l'arbre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Certes le bol console, toutefois il ne remplace pas un salaire, et je serais trop vite d'accord si je cède au slogan réel de jeudi.",
  "correct_sentence": "Certes le bol console, toutefois il ne remplace pas un salaire, et je serai trop vite d'accord si je cède au slogan réel de jeudi.",
  "explanation": "Projet réel de jeudi : je serai, pas le conditionnel je serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/rose-couture.svg",
      "word": "une couture"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/felicie-bol.svg",
      "word": "un bol"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/lanterne-soir.svg",
      "word": "une lanterne"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/banc-avis.svg",
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
  "prompt": "Relevez six connecteurs de débat et l'argument qu'ils portent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : D'une part le lin convainc. D'autre part les lanternes fatiguent. En somme, le Seuil compare."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Synthèse des tendances du Seuil',
    'CE',
    $c$Objectif
Lire une synthèse argumentée qui relie les quatre premières séquences.

Consigne
Lisez la synthèse de Mado, sans aller trop vite.

Support — Synthèse de Mado, feuille pour le figuier
Quatre dossiers, une cour : voilà la semaine du Seuil des Sources.
D'une part, le tissu de Rose, convaincant pour les uns, convainquant les passants pour les autres, a forcé une grammaire : action ou qualité.
D'autre part, le bol de Félicie a forcé un temps : on jugera quand on aura fini, pas avant.
En revanche, les vacances ont opposé deux pratiques : partir vers Rive-des-Saules, rester et relayer.
Néanmoins personne n'a obtenu le droit d'insulter l'autre rive.
Le texte explicatif des lanternes a rappelé l'ordre : lorsque, dès que, une fois que, aussi longtemps que.
Autrement dit, une tendance n'est pas un orage : on peut l'analyser, l'expliquer, la débattre.
Certes le Marché des Lampions brille ; toutefois le Marché des Herbes nomme et pèse.
Karim a raison sur un point : quelqu'un paie, toujours.
Lila refuse le slogan ; Sami refuse l'oubli des anciens ; Yvette refuse le danger nié.
Ayant entendu les uns et les autres, Aline propose de voter sur des gestes, pas sur des mots à la mode.
Joël relayera quoi que l'on décide des valises.
Nous publierons cette synthèse à Radio Figuier lorsque nous aurons coupé les insultes, pas les doutes.
Le figuier, lui, n'a pas voté : il a porté les lanternes.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La synthèse dit qu'on peut voter sur des mots à la mode plutôt que sur des gestes.",
  "correct": false,
  "explanation": "Aline propose de voter sur des gestes, pas sur des mots à la mode."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que refuse Lila, dans cette synthèse ?",
  "options": [
    {
      "text": "Le bol",
      "correct": false
    },
    {
      "text": "Le slogan",
      "correct": true
    },
    {
      "text": "Le relais de Joël",
      "correct": false
    },
    {
      "text": "Le Cahier du chemin",
      "correct": false
    }
  ],
  "explanation": "Lila refuse le slogan."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'une part / d'autre part",
      "right": "tissu / bol"
    },
    {
      "left": "en revanche",
      "right": "vacances"
    },
    {
      "left": "certes / toutefois",
      "right": "deux marchés"
    },
    {
      "left": "autrement dit",
      "right": "analyser expliquer débattre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous publierons lorsque nous ___ coupé les insultes. (avoir, FA)",
  "answer": "aurons"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Autrement",
    "dit",
    "une",
    "tendance",
    "s'analyse",
    "."
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
  "hint": "Texte court qui rassemble les avis pour et contre. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Certes les Lampions brillent, toutefois les Herbes pèsent, et bien que ce est utile on garde les deux.",
  "correct_sentence": "Certes les Lampions brillent, toutefois les Herbes pèsent, et bien que ce soit utile on garde les deux.",
  "explanation": "Bien que + subjonctif : ce soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/felicie-bol.svg",
      "word": "un bol"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/lanterne-soir.svg",
      "word": "une lanterne"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/banc-avis.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/graphique-mode.svg",
      "word": "un graphique"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Résumez en huit lignes les quatre dossiers, avec quatre connecteurs de débat."
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
    'PO — Dire d''une part, en somme, toutefois',
    'PO',
    $c$Objectif
Mener à l'oral une synthèse courte avec les connecteurs de débat.

Consigne
Répétez, puis tenez un avis de deux minutes sous le figuier.

Support — Modèles d'Aline, table du jeudi
D'une part je reconnais le lin ; d'autre part je vois les bras fatigués.
En revanche je refuse le mot « tendance » trop tôt.
Certes le pont attire ; toutefois le jeudi reste un argument.
Néanmoins il faut un relais et un prix juste.
Autrement dit, on analyse avant de voter.
Pour ma part, je penche vers les noms du Marché des Herbes.
En somme, le Seuil compare, il n'obéit pas.
Reste que quelqu'un paie les mains.
Quoi que l'on décide, Joël relayera.
Je concède l'envie de partir, je maintiens le mot sous l'arbre.
Lila : une phrase pour, une phrase contre, une phrase de synthèse.
Marc : pas de slogan.
Karim : nommez qui paie.
Sami : nommez ce que le figuier a déjà vu.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« En somme » sert à ouvrir le débat, pas à le clore.",
  "correct": false,
  "explanation": "En somme clôt : le Seuil compare, il n'obéit pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel couple introduit deux plateaux équilibrés ?",
  "options": [
    {
      "text": "en somme / reste que",
      "correct": false
    },
    {
      "text": "d'une part / d'autre part",
      "correct": true
    },
    {
      "text": "quoi que / lorsque",
      "correct": false
    },
    {
      "text": "ayant fini / étant partie",
      "correct": false
    }
  ],
  "explanation": "D'une part / d'autre part."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'une part",
      "right": "premier plateau"
    },
    {
      "left": "en revanche",
      "right": "opposition"
    },
    {
      "left": "certes / toutefois",
      "right": "concession"
    },
    {
      "left": "en somme",
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
  "prompt": "Complétez :\nCertes le pont attire ; ___ le jeudi reste un argument.",
  "answer": "toutefois"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Pour",
    "ma",
    "part",
    "je",
    "penche",
    "vers",
    "les",
    "noms",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "balance",
  "hint": "Image du pour et du contre, deux plateaux."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En somme le Seuil compare, et je ferrai le relais des lanternes dès que j'aurai fini mon avis.",
  "correct_sentence": "En somme le Seuil compare, et je ferai le relais des lanternes dès que j'aurai fini mon avis.",
  "explanation": "Futur de faire : je ferai, un seul r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/lanterne-soir.svg",
      "word": "une lanterne"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/banc-avis.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/graphique-mode.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/nuage-habitude.svg",
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
  "prompt": "Écrivez un avis oral de douze phrases, avec six connecteurs de débat."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis votre synthèse de deux minutes."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma synthèse sous le figuier',
    'PE',
    $c$Objectif
Écrire une synthèse argumentée des tendances discutées au Seuil.

Consigne
Imitez la synthèse d'Aline Uwase.

Support — Synthèse d'Aline, banc ocre
Aline Uwase — Seuil des Sources, Rukiri-Nord
D'une part le lin de Rose est convaincant ; d'autre part les lanternes, fatiguant les bras, exigent un relais.
En revanche je refuse d'appeler cela une « loi » du jeudi.
Certes Félicie console par le bol ; toutefois le prix des herbes reste un argument, pas un détail.
Néanmoins Léa peut partir trois jours, bien que le banc se vide un peu.
Autrement dit : on oppose, on concède, on n'insulte pas.
Quand nous aurons fini d'écouter Karim — qui paie ? — nous pourrons voter sur des gestes.
Quoi que Sami rappelle des anciens, le Seuil d'aujourd'hui a droit à un micro, pas à un silence pieux.
Pour ma part, je penche vers le Marché des Herbes, ayant comparé les emballages des Lampions.
En somme, une tendance s'analyse, s'explique, se débat. Elle ne s'obéit pas.
Je serai là jeudi, et Lila coupera les slogans.
Aline
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline accepte d'appeler les habitudes du jeudi une « loi ».",
  "correct": false,
  "explanation": "En revanche je refuse d'appeler cela une « loi » du jeudi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Vers quel marché Aline penche-t-elle, et après quoi ?",
  "options": [
    {
      "text": "Les Lampions, sans comparer",
      "correct": false
    },
    {
      "text": "Le Marché des Herbes, ayant comparé les emballages",
      "correct": true
    },
    {
      "text": "Aucun marché",
      "correct": false
    },
    {
      "text": "Seulement Lampe-Figue",
      "correct": false
    }
  ],
  "explanation": "Pour ma part, je penche vers le Marché des Herbes, ayant comparé…"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'une part / d'autre part",
      "right": "lin / lanternes"
    },
    {
      "left": "certes / toutefois",
      "right": "bol / prix"
    },
    {
      "left": "autrement dit",
      "right": "opposer concéder"
    },
    {
      "left": "en somme",
      "right": "analyser expliquer débattre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEn somme, une tendance s'analyse : elle ne s'___ pas. (obéir)",
  "answer": "obéit"
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
    "refuse",
    "d'appeler",
    "cela",
    "une",
    "loi",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "argument",
  "hint": "Preuve ou raison avancée pour emporter l'adhésion, au débat."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quand nous aurons fini d'écouter Karim, nous pourai voter sur des gestes, et Lila coupera les slogans.",
  "correct_sentence": "Quand nous aurons fini d'écouter Karim, nous pourrons voter sur des gestes, et Lila coupera les slogans.",
  "explanation": "Futur de pouvoir : nous pourrons, deux r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/banc-avis.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/graphique-mode.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/nuage-habitude.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/soleil-saison.svg",
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
  "prompt": "Imitez : une synthèse de douze lignes, six connecteurs, un avis clair."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre synthèse, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Outils de la synthèse sous le figuier',
    'EL',
    $c$Objectif
Retenir les connecteurs qui organisent un débat et une synthèse.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline et de Marc, table du jeudi
D'une part … d'autre part … : deux plateaux, sans écraser l'un.
En revanche : opposition plus nette après un premier argument.
Certes … toutefois / néanmoins : on concède, puis on maintient.
Autrement dit : on reformule, on clarifie, on refuse le slogan.
Pour ma part : on assume un avis, sans parler pour tout le Seuil.
En somme / en résumé : on clôt, on ne rouvre pas trois dossiers.
Reste que : on rappelle un fait qui résiste (qui paie ?).
Quoi que + subj. : concession large (quoi que l'on décide).
Ayant + participe : antériorité pour légitimer un avis (ayant comparé).
Quand nous aurons fini : futur antérieur avant le vote.
Ne pas écrire je serais pour un jeudi déjà fixé → je serai.
Ne pas écrire je ferrai / je pourai → je ferai / je pourrai.
Synthèse du Seuil : mode, bol, vacances, texte explicatif, puis débat.
Le figuier porte les lanternes ; il ne vote pas.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Reste que » sert surtout à reformuler un slogan.",
  "correct": false,
  "explanation": "Reste que rappelle un fait qui résiste, par exemple qui paie."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel connecteur clôt la synthèse ?",
  "options": [
    {
      "text": "d'une part",
      "correct": false
    },
    {
      "text": "en somme",
      "correct": true
    },
    {
      "text": "certes",
      "correct": false
    },
    {
      "text": "tandis que",
      "correct": false
    }
  ],
  "explanation": "En somme / en résumé ferment."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'une part / d'autre part",
      "right": "deux plateaux"
    },
    {
      "left": "certes / toutefois",
      "right": "concession"
    },
    {
      "left": "autrement dit",
      "right": "reformulation"
    },
    {
      "left": "en somme",
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
  "prompt": "Complétez :\nAutrement ___ : on analyse avant de voter.",
  "answer": "dit"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Reste",
    "que",
    "quelqu'un",
    "paie",
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
  "word": "debat",
  "hint": "Échange d'avis sous l'arbre, pour et contre. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En somme le Seuil compare, et il fautons un relais avant le vote de jeudi.",
  "correct_sentence": "En somme le Seuil compare, et il faut un relais avant le vote de jeudi.",
  "explanation": "Toujours il faut, à la 3e personne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/graphique-mode.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/nuage-habitude.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/soleil-saison.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/feuille-edito.svg",
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
  "prompt": "Tableau : huit connecteurs, valeur, un exemple chacun tiré du Seuil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis une mini-synthèse de huit lignes."
}$j$::jsonb,
    9
  );

  -- ===== Une chronique pour Radio Figuier =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une chronique pour Radio Figuier'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une chronique pour Radio Figuier', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Préparer la chronique du jeudi',
    'CO',
    $c$Objectif
Suivre la préparation d'une chronique argumentée pour Radio Figuier.

Consigne
Lisez la réunion de rédaction. Quelles parties Lila exige-t-elle ?

Support — Réunion à Radio Figuier, micro encore froid
Lila Sow : Une chronique n'est pas un cri. Elle a un fait, un angle, une concession, une proposition.
Marc Nkurunziza : J'ouvrirai sur le lin de Rose, pas sur un slogan. Le fait d'abord.
Aline Uwase : Ensuite l'angle : qui paie les mains, qui copie, qui porte.
Léa Niyonzima : Je concéderai l'envie du pont, néanmoins je défendrai le jeudi.
Patrick Habimana : Attention au ton : argumenter, ce n'est pas humilier Rive-des-Saules.
Hawa Diallo : Dès que tu auras nommé les deux marchés, tu pourras juger, pas avant.
Joël Mugisha : Pour ma part, une minute sur le relais des lanternes, rien de plus.
Rose Iradukunda : Ayant fini l'ourlet, je peux parler du tissu sans le vendre.
Solange Mukamana : Le Cahier du chemin notera l'heure de diffusion, pas les applaudissements.
Karim Bamba : Reste que le prix des herbes doit apparaître, autrement la chronique ment.
Félicie : Je passerai au micro lorsque j'aurai lavé le bol. Un fait simple.
Dieudonné : Si la table grince, on l'entendra. Réparez avant, ou expliquez.
Yvette : Incluez le danger : flamme, estomac, dos. Une chronique adulte.
Sami : Terminez par ce que le figuier a vu, pas par ce qu'il « devrait » aimer.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila dit qu'une chronique peut se contenter d'un cri, sans concession.",
  "correct": false,
  "explanation": "Une chronique n'est pas un cri. Elle a un fait, un angle, une concession, une proposition."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que doit faire Hawa avant de juger les marchés ?",
  "options": [
    {
      "text": "Couper le micro",
      "correct": false
    },
    {
      "text": "Les nommer tous les deux",
      "correct": true
    },
    {
      "text": "Partir au pavillon",
      "correct": false
    },
    {
      "text": "Interdire les herbes",
      "correct": false
    }
  ],
  "explanation": "Dès que tu auras nommé les deux marchés, tu pourras juger, pas avant."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "fait",
      "right": "ouvrir sans slogan"
    },
    {
      "left": "angle",
      "right": "qui paie, qui copie"
    },
    {
      "left": "concession",
      "right": "l'envie du pont"
    },
    {
      "left": "proposition",
      "right": "relais, prix, danger"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne chronique a un fait, un angle, une concession, une ___.",
  "answer": "proposition"
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
    "chronique",
    "n'est",
    "pas",
    "un",
    "cri",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "chronique",
  "hint": "Genre régulier, à l'antenne du Seuil, plus argumenté qu'un cri."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dès que tu auras nommé les deux marchés, tu pourai juger, et Karim rappellera le prix.",
  "correct_sentence": "Dès que tu auras nommé les deux marchés, tu pourras juger, et Karim rappellera le prix.",
  "explanation": "Futur de pouvoir : tu pourras, deux r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/nuage-habitude.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/soleil-saison.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/feuille-edito.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/balance-pour-contre.svg",
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
  "prompt": "Notez les quatre parties exigées par Lila et un exemple pour chacune."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Une chronique a un fait, un angle, une concession, une proposition."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Chronique : ce que le jeudi refuse',
    'CE',
    $c$Objectif
Lire une chronique argumentée diffusée à Radio Figuier.

Consigne
Lisez la chronique de Marc, sans aller trop vite.

Support — Chronique de Marc Nkurunziza, antenne du Seuil
Ce jeudi, le Seuil des Sources n'a pas acheté une tendance : il l'a interrogée.
Le fait d'abord : Rose a fini trois ourlets ; Joël a accroché des lanternes ; Félicie a servi un bol nommé.
L'angle ensuite : qui copie le lin, qui pèse les herbes, qui relais les bras, qui paie.
Je concède que Rive-des-Saules et le Pavillon du Saule attirent : l'eau n'est pas une faute.
Néanmoins un départ de trois jours n'autorise pas à traiter le figuier de musée.
Contrairement aux affiches du Marché des Lampions, une chronique nomme les prix.
Bien que le Marché des Herbes soit inventé, il a des balances, donc une honnêteté.
Quand nous aurons fini d'écouter Yvette — flammes, estomacs — nous pourrons parler de fête.
Autrement dit, argumenter, c'est tenir un fait, une concession et une proposition dans la même voix.
Je propose : un relais pour les lanternes, un juste prix pour les mains, un mot sous l'arbre avant toute valise.
Lila coupera les insultes ; elle gardera les doutes. C'est déjà une éthique.
Sami rappellera les anciens, non pour fermer le micro, pour l'empêcher de trop vite.
Ayant comparé les deux rives, Léa et Patrick peuvent partir sans nous trahir, si le jeudi reste un rendez-vous.
Voilà ce que Radio Figuier peut dire, sans crier, sans vendre, sans obéir.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La chronique affirme que le Seuil a acheté une tendance sans l'interroger.",
  "correct": false,
  "explanation": "Le Seuil n'a pas acheté une tendance : il l'a interrogée."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle proposition concrète Marc avance-t-il ?",
  "options": [
    {
      "text": "Fermer le Marché des Herbes",
      "correct": false
    },
    {
      "text": "Un relais, un juste prix, un mot avant toute valise",
      "correct": true
    },
    {
      "text": "Interdire Rive-des-Saules",
      "correct": false
    },
    {
      "text": "Remplacer Lila par un slogan",
      "correct": false
    }
  ],
  "explanation": "Un relais pour les lanternes, un juste prix pour les mains, un mot sous l'arbre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le fait",
      "right": "ourlets, lanternes, bol"
    },
    {
      "left": "l'angle",
      "right": "qui paie, qui copie"
    },
    {
      "left": "la concession",
      "right": "l'eau n'est pas une faute"
    },
    {
      "left": "la proposition",
      "right": "relais, prix, mot"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nBien que le Marché des Herbes ___ inventé, il a des balances. (être, subj.)",
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
    "Argumenter",
    "c'est",
    "tenir",
    "un",
    "fait",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "editorial",
  "hint": "Article d'opinion signé, plus argumenté qu'un fait divers. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quand nous aurons fini d'écouter Yvette, nous pourrons parler de fête, et je serais à l'antenne à l'heure fixée.",
  "correct_sentence": "Quand nous aurons fini d'écouter Yvette, nous pourrons parler de fête, et je serai à l'antenne à l'heure fixée.",
  "explanation": "Heure déjà fixée : je serai, pas je serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/soleil-saison.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/feuille-edito.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/balance-pour-contre.svg",
      "word": "une balance"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/coeur-seuil.svg",
      "word": "un cœur"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Repérez fait, angle, concession, proposition, et recopiez une phrase pour chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la chronique, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire une chronique à l''antenne',
    'PO',
    $c$Objectif
Prononcer une chronique courte : fait, angle, concession, proposition.

Consigne
Répétez les modèles, puis tenez une chronique d'une minute.

Support — Modèles de Lila Sow, studio
Le fait d'abord : Rose a fini l'ourlet, Joël a accroché, Félicie a servi.
L'angle ensuite : qui paie les mains, qui copie le lin.
Je concède que le pont attire.
Néanmoins le jeudi reste un rendez-vous, pas un musée.
Contrairement aux affiches, je nomme les prix.
Bien que le marché des plantes soit inventé, il pèse.
Quand j'aurai nommé les deux files, je jugerai.
Autrement dit, une chronique n'est pas un cri.
Je propose un relais, un juste prix, un mot sous l'arbre.
Pour ma part, je refuse le slogan.
En somme, le Seuil interroge, il n'achète pas trop vite.
Lila : une phrase, une pause, le micro près de la bouche.
Marc : tenez l'ordre des quatre parties.
Aline : le public doit pouvoir vous contredire, donc soyez clairs.
Sami : finissez par un geste vu, pas par un devoir moral trop large.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila demande de parler sans pause, pour remplir l'antenne.",
  "correct": false,
  "explanation": "Une phrase, une pause, le micro près de la bouche."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Dans quel ordre les modèles placent-ils les parties ?",
  "options": [
    {
      "text": "Proposition, cri, fait",
      "correct": false
    },
    {
      "text": "Fait, angle, concession, proposition",
      "correct": true
    },
    {
      "text": "Slogan, vote, silence",
      "correct": false
    },
    {
      "text": "Concession seulement",
      "correct": false
    }
  ],
  "explanation": "Fait d'abord, angle, concession, proposition."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le fait",
      "right": "ourlet, lanterne, bol"
    },
    {
      "left": "l'angle",
      "right": "qui paie"
    },
    {
      "left": "néanmoins",
      "right": "le jeudi reste"
    },
    {
      "left": "je propose",
      "right": "relais, prix, mot"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nContrairement ___ affiches, je nomme les prix.",
  "answer": "aux"
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
    "chronique",
    "n'est",
    "pas",
    "un",
    "cri",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "micro",
  "hint": "Objet du studio de Lila, pour prendre la voix sans crier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quand j'aurai nommé les deux files, je jugerai, et je ferrai une pause après chaque phrase.",
  "correct_sentence": "Quand j'aurai nommé les deux files, je jugerai, et je ferai une pause après chaque phrase.",
  "explanation": "Futur de faire : je ferai, un seul r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/feuille-edito.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/balance-pour-contre.svg",
      "word": "une balance"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/coeur-seuil.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/mode-apparence.svg",
      "word": "une mode"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez une chronique orale de dix phrases, dans l'ordre des quatre parties."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis votre chronique d'une minute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma chronique pour Radio Figuier',
    'PE',
    $c$Objectif
Écrire une chronique argumentée destinée à l'antenne du Seuil.

Consigne
Imitez la chronique de Lila Sow.

Support — Chronique de Lila, papier du studio
Lila Sow — Radio Figuier, Seuil des Sources
Le fait : ce jeudi, le lin ocre a convaincu plus d'oreilles que d'yeux ; les lanternes ont fatigué plus de bras que de regards.
L'angle : une tendance qui n'a pas de prix n'a pas de vérité. Karim a raison de demander qui paie.
Je concède que Val-des-Peupliers et le Pavillon du Saule offrent une eau que le figuier ne donne pas.
Néanmoins partir n'autorise pas à traiter nos jeudis de folklore.
Bien que le Marché des Herbes soit inventé, il nomme ce qu'il vend ; les Lampions, trop souvent, emballent.
Quand j'aurai coupé les insultes de l'enregistrement, je garderai les doutes : c'est mon métier.
Autrement dit, une chronique tient un fait, une concession et une proposition dans la même voix.
Je propose : un relais écrit pour Joël, un tarif dit à voix haute pour Félicie, un mot sous l'arbre avant toute valise.
Pour ma part, je refuse le slogan « soyez à la mode » : soyez précis.
En somme, le Seuil interroge ce qui passe, et il protège ce qui reste.
Vous m'entendrez demain, sans crier.
Lila
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila dit que son métier est de couper les doutes et de garder les insultes.",
  "correct": false,
  "explanation": "Elle coupera les insultes et gardera les doutes."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelles trois propositions concrètes Lila avance-t-elle ?",
  "options": [
    {
      "text": "Fermer le figuier, vendre le lin, taire Karim",
      "correct": false
    },
    {
      "text": "Un relais pour Joël, un tarif pour Félicie, un mot avant la valise",
      "correct": true
    },
    {
      "text": "Partir tous à Rive-des-Saules",
      "correct": false
    },
    {
      "text": "Remplacer le bol par un slogan",
      "correct": false
    }
  ],
  "explanation": "Relais écrit, tarif à voix haute, mot sous l'arbre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le fait",
      "right": "lin et lanternes"
    },
    {
      "left": "l'angle",
      "right": "pas de prix, pas de vérité"
    },
    {
      "left": "la concession",
      "right": "l'eau de l'autre rive"
    },
    {
      "left": "la proposition",
      "right": "relais, tarif, mot"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nBien que le Marché des Herbes ___ inventé, il nomme ce qu'il vend. (être, subj.)",
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
    "refuse",
    "le",
    "slogan",
    "soyez",
    "précis",
    "."
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
  "hint": "Arbre de la cour, témoin des débats du jeudi."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quand j'aurai coupé les insultes, je garderai les doutes, et je serais à l'antenne demain à l'heure dite.",
  "correct_sentence": "Quand j'aurai coupé les insultes, je garderai les doutes, et je serai à l'antenne demain à l'heure dite.",
  "explanation": "Rendez-vous réel : je serai, pas je serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/balance-pour-contre.svg",
      "word": "une balance"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/coeur-seuil.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/mode-apparence.svg",
      "word": "une mode"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/participe-present.svg",
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
  "prompt": "Imitez : une chronique de douze à quatorze lignes, quatre parties visibles."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre chronique, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Tenir une chronique argumentée',
    'EL',
    $c$Objectif
Retenir la structure et la langue d'une chronique pour Radio Figuier.

Consigne
Apprenez la fiche.

Support — Fiche de Lila et d'Aline, studio
Structure : fait → angle → concession → proposition → clôture.
Fait : concret, daté, sans slogan (ourlet, bol, lanterne, heure).
Angle : question qui oriente (qui paie ? qui copie ? qui relais ?).
Concession : bien que / certes / je concède que — puis néanmoins / toutefois.
Proposition : un geste possible (relais, tarif dit, mot sous l'arbre).
Clôture : en somme / autrement dit / pour ma part — une phrase nette.
Langue : futur antérieur avant le jugement (quand j'aurai nommé, je jugerai).
Participe composé pour légitimer (ayant comparé, ayant fini).
Opposition et concession : alors que, contrairement à, bien que + subj.
Je serai à l'antenne (futur réel) / je serais (hypothèse).
Je ferai (1 r) ; je pourrai (2 r) ; il faut (3e pers.).
Ton : une phrase, une pause ; pas d'insulte ; garder les doutes.
Public du Seuil : ceux qui restent, ceux qui partent, ceux qui paient.
Radio Figuier n'obéit pas à une mode : elle l'interroge.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition d'une chronique doit rester un slogan sans geste.",
  "correct": false,
  "explanation": "Proposition : un geste possible (relais, tarif, mot)."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel est l'ordre de la structure retenue ?",
  "options": [
    {
      "text": "Slogan, vote, silence",
      "correct": false
    },
    {
      "text": "Fait, angle, concession, proposition, clôture",
      "correct": true
    },
    {
      "text": "Clôture, fait, cri",
      "correct": false
    },
    {
      "text": "Angle seulement",
      "correct": false
    }
  ],
  "explanation": "Fait → angle → concession → proposition → clôture."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "fait",
      "right": "concret, daté"
    },
    {
      "left": "angle",
      "right": "qui paie / qui copie"
    },
    {
      "left": "concession",
      "right": "bien que / certes"
    },
    {
      "left": "proposition",
      "right": "un geste possible"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nQuand j'aurai nommé les deux files, je ___. (juger, futur)",
  "answer": "jugerai"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Radio",
    "Figuier",
    "interroge",
    "une",
    "mode",
    "."
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
  "hint": "Lieu d'où Lila diffuse, sans crier, une voix argumentée."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je serai à l'antenne demain, et il fautons une pause après chaque phrase argumentée.",
  "correct_sentence": "Je serai à l'antenne demain, et il faut une pause après chaque phrase argumentée.",
  "explanation": "Toujours il faut, à la 3e personne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m1/coeur-seuil.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/mode-apparence.svg",
      "word": "une mode"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/participe-present.svg",
      "word": "un participe"
    },
    {
      "image_path": "/elearning/mfk-b2-m1/adjectif-verbal.svg",
      "word": "un adjectif"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez un plan de chronique : cinq parties, deux exemples de langue chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis une chronique de cinq phrases."
}$j$::jsonb,
    9
  );

END;
$$;
