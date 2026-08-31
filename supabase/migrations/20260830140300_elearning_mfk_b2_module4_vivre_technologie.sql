/*
  Seed eLearning MFK — B2 — Vivre avec la technologie

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b2-m4/
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
  v_module_title text := 'B2 — Vivre avec la technologie';
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
      'Grande étape B2-4 : lire une actualité technologique, mesurer une évolution, relier mémoire et réseaux, raisonner sur la déconnexion, puis rédiger une charte et tenir un débat — Lampe-Figue, Filtre des Herbes, fil de Radio Figuier (réseau local inventé), cour du Seuil des Sources (Rukiri-Nord).',
      'B2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B2-4 : lire une actualité technologique, mesurer une évolution, relier mémoire et réseaux, raisonner sur la déconnexion, puis rédiger une charte et tenir un débat — Lampe-Figue, Filtre des Herbes, fil de Radio Figuier (réseau local inventé), cour du Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'B2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Actualité technologique =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Actualité technologique'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Actualité technologique', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Faut-il allumer la Lampe-Figue ?',
    'CO',
    $c$Objectif
Suivre une actualité inventée ; inversion et préfixes négatifs ; avantages et inconvénients.

Consigne
Lisez le dialogue. Quels avantages, quels inconvénients, quelles questions inversées ?

Support — Studio de Radio Figuier, fil du soir
Lila : Actualité du Seuil : la Lampe-Figue relie désormais trois cours par le fil. Faut-il s'en réjouir sans réserve ?
Léa : Peut-on entendre une voix loin du figuier ? Oui. Est-ce utile ? Oui. Est-ce toujours souhaitable ? J'en doute.
Patrick : Doit-on tout filtrer par le Filtre des Herbes ? Un message inutile fatigue. Un message impossible à retracer inquiète.
Marc : Attention aux préfixes : in- avant une consonne, im- devant p ou b, ir- devant r. On dit impossible, pas inpossible.
Hawa : L'avantage, c'est la mémoire partagée. L'inconvénient, c'est la méfiance : on devient mécontent dès qu'une voix tarde.
Joël : Déconnecter une soirée, est-ce irresponsable ? Je ne crois pas. Rester allumé sans écoute, cela l'est davantage.
Rose : La lampe est imparfaite, et c'est tant mieux. Un outil trop sûr devient imprudent.
Solange : Le Bureau peut dater un usage. Il ne peut pas interdire une méfiance. Faut-il une règle ? Oui. Une panique ? Non.
Karim : Avantage : on retrace une décision. Inconvénient : on déforme une rumeur plus vite.
Aline : Peut-on vivre avec le fil sans s'y soumettre ? C'est la seule question qui m'intéresse.
Dieudonné : J'ai construit la lampe. Je n'ai pas construit l'obéissance. Débrancher reste possible.
Sami : Trois frappes valent mieux qu'une alerte trop nette. Le fil est irrégulier ? Qu'il le reste.
Yvette : Incomplet n'est pas inutile. Invisible n'est pas innocent. Choisissez vos préfixes avec soin.
Félicie : Léa a mis le casque. Elle entend trop. Peut-elle l'enlever ? Oui, et c'est déjà une réponse.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc rappelle que l'on dit impossible, pas inpossible.",
  "correct": true,
  "explanation": "im- devant p ou b."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle question intéresse surtout Aline ?",
  "options": [
    {
      "text": "Faut-il interdire le thé ?",
      "correct": false
    },
    {
      "text": "Peut-on vivre avec le fil sans s'y soumettre ?",
      "correct": true
    },
    {
      "text": "Doit-on vendre la lampe au marché ?",
      "correct": false
    },
    {
      "text": "Faut-il fermer le figuier ?",
      "correct": false
    }
  ],
  "explanation": "Aline : vivre avec le fil sans s'y soumettre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "faut-il / peut-on / doit-on",
      "right": "inversion"
    },
    {
      "left": "impossible / imprudent",
      "right": "im- devant p"
    },
    {
      "left": "déconnecter / débrancher",
      "right": "préfixe dé-"
    },
    {
      "left": "méfiance / mécontent",
      "right": "préfixe mé-"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn dit ___ , pas inpossible.",
  "answer": "impossible"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Faut-il",
    "s'en",
    "réjouir",
    "sans",
    "réserve",
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
  "word": "inversion",
  "hint": "Tour Faut-il… ? Peut-on… ? le verbe passe avant le sujet."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Cette alerte est inpossible à ignorer, et Léa garde encore le casque trop longtemps.",
  "correct_sentence": "Cette alerte est impossible à ignorer, et Léa garde encore le casque trop longtemps.",
  "explanation": "im- devant p : impossible."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/actu-tech.svg",
      "word": "une actualité"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/inversion-question.svg",
      "word": "une inversion"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/prefixe-negatif.svg",
      "word": "un préfixe"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/lampe-figue.svg",
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
  "prompt": "Notez trois questions inversées, trois préfixes et un avantage plus un inconvénient."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Faut-il s'en réjouir ? Peut-on vivre avec le fil ? Doit-on tout filtrer ? C'est impossible."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Brève du fil',
    'CE',
    $c$Objectif
Lire une brève d'actualité technologique inventée (inversion, préfixes, pour et contre).

Consigne
Lisez la brève, sans aller trop vite.

Support — Feuille du soir, Radio Figuier
Brève — Le fil relie trois cours
Depuis la dernière lune, la Lampe-Figue porte des voix d'une cour à l'autre. Faut-il y voir un progrès ? Peut-on s'en passer ? Doit-on tout accepter ?
Avantages. On entend une décision loin du banc. On retrace un mot. Un voisin invisible n'est plus tout à fait absent.
Inconvénients. Un message inutile circule aussi vite qu'un message juste. La méfiance grandit. On devient mécontent dès qu'une voix tarde. Déconnecter paraît alors irresponsable, à tort.
Le Filtre des Herbes, d'abord conçu pour l'eau de la rive, sert désormais à écarter les rumeurs trop brutes. Il reste imparfait. Imparfait n'est pas inutile.
Préfixes à tenir : in- (inutile, incomplet, invisible) ; im- (impossible, imprudent, imparfait) ; ir- (irresponsable, irrégulier) ; dé- (déconnecter, débrancher) ; mé- (mécontent, méfiance).
Aline : peut-on vivre avec le fil sans s'y soumettre ? Dieudonné : débrancher reste possible. Solange : une règle, pas une panique.
Marc rappelle : on ne dit pas inpossible. On dit impossible.
Léa a trop porté le casque. Félicie lui a demandé : peux-tu l'enlever ? L'inversion, au Seuil, n'est pas un luxe. C'est une politesse du doute.
Karim : avantage, on retrace une décision ; inconvénient, on déforme une rumeur plus vite.
Sami : trois frappes valent mieux qu'une alerte trop nette. Le fil est irrégulier ? Qu'il le reste.
Rukiri-Nord — à relire avant d'allumer la lampe ce soir.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le Filtre des Herbes, d'après la brève, est d'abord né pour l'eau de la rive.",
  "correct": true,
  "explanation": "« d'abord conçu pour l'eau de la rive »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que rappelle Marc au sujet du mot « impossible » ?",
  "options": [
    {
      "text": "On dit inpossible",
      "correct": false
    },
    {
      "text": "On dit impossible, pas inpossible",
      "correct": true
    },
    {
      "text": "On dit dépossible",
      "correct": false
    },
    {
      "text": "On dit mépossible",
      "correct": false
    }
  ],
  "explanation": "im- devant p."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "faut-il / peut-on",
      "right": "questions d'actualité"
    },
    {
      "left": "inutile / incomplet",
      "right": "in-"
    },
    {
      "left": "déconnecter",
      "right": "dé-"
    },
    {
      "left": "méfiance",
      "right": "mé-"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDéconnecter paraît alors ___ , à tort.",
  "answer": "irresponsable"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Peut-on",
    "vivre",
    "avec",
    "le",
    "fil",
    "sans",
    "s'y",
    "soumettre",
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
  "word": "avantage",
  "hint": "Côté utile d'un outil : entendre loin, retracer un mot, relier une cour."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Rester allumé sans écoute est irresponsable, et cette alerte reste inpossible à classer sans le Filtre.",
  "correct_sentence": "Rester allumé sans écoute est irresponsable, et cette alerte reste impossible à classer sans le Filtre.",
  "explanation": "Impossible, pas inpossible."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/inversion-question.svg",
      "word": "une inversion"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/prefixe-negatif.svg",
      "word": "un préfixe"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/lampe-figue.svg",
      "word": "une lampe"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/duree-evolution.svg",
      "word": "une durée"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez avantages et inconvénients, puis trois questions inversées à vous."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la brève, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire Faut-il, Peut-on, c''est impossible',
    'PO',
    $c$Objectif
Poser à l'oral des questions inversées et nommer avantages, inconvénients, préfixes.

Consigne
Répétez, puis débattez une minute : faut-il allumer la Lampe-Figue ce soir ?

Support — Modèles d'Aline et de Lila
Faut-il allumer la lampe ce soir ?
Peut-on s'en passer une heure ?
Doit-on tout filtrer ?
Est-ce utile ? Est-ce souhaitable ?
C'est impossible à ignorer, pas inpossible.
C'est imprudent de rester casqué trop longtemps.
Déconnecter n'est pas irresponsable.
La méfiance grandit trop vite.
Avantage : on retrace un mot.
Inconvénient : une rumeur circule aussi vite.
Lila : l'inversion ouvre le doute. Ce n'est pas un piège.
Marc : im- devant p ou b ; ir- devant r.
Léa : je peux enlever le casque. Puis-je le dire ainsi ? Oui.
Dieudonné : débrancher reste possible. Je l'ai prévu.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila présente l'inversion comme une ouverture du doute.",
  "correct": true,
  "explanation": "« l'inversion ouvre le doute. »"
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
      "text": "inpossible",
      "correct": false
    },
    {
      "text": "impossible",
      "correct": true
    },
    {
      "text": "inprudent",
      "correct": false
    },
    {
      "text": "inresponsable",
      "correct": false
    }
  ],
  "explanation": "im- devant p : impossible."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "faut-il",
      "right": "devoir / question"
    },
    {
      "left": "peut-on",
      "right": "possibilité"
    },
    {
      "left": "im- / ir-",
      "right": "p-b / r"
    },
    {
      "left": "dé- / mé-",
      "right": "enlever / mal"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___-on s'en passer une heure ?",
  "answer": "Peut"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Déconnecter",
    "n'est",
    "pas",
    "irresponsable",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "prefixe",
  "hint": "Petit morceau devant le mot : in- im- ir- dé- mé-. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Faut-il tout filtrer ce soir, et cette rumeur reste inprudente à répéter sans le banc ?",
  "correct_sentence": "Faut-il tout filtrer ce soir, et cette rumeur reste imprudente à répéter sans le banc ?",
  "explanation": "im- devant p : imprudente."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/prefixe-negatif.svg",
      "word": "un préfixe"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/lampe-figue.svg",
      "word": "une lampe"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/duree-evolution.svg",
      "word": "une durée"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/reseau-fil.svg",
      "word": "un réseau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six questions inversées et quatre mots à préfixe négatif, avec une phrase chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les dix premiers modèles, puis deux questions à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma brève pour ou contre',
    'PE',
    $c$Objectif
Écrire une brève argumentée : actualité de la Lampe-Figue, pour et contre, inversion, préfixes.

Consigne
Imitez la brève de Léa Niyonzima, sans aller trop vite.

Support — Brève de Léa, casque posé
Léa Niyonzima — Seuil des Sources
Faut-il se réjouir que le fil relie trois cours ? Peut-on s'en passer ? Doit-on tout accepter ? Je pose les trois questions avant d'allumer.
Avantage : j'entends Aline loin du banc, et je retrace un mot que j'avais mal tenu. Ce n'est pas inutile.
Inconvénient : la méfiance. Je deviens mécontente dès qu'une voix tarde. Le casque rend invisible le visage d'en face. C'est imprudent.
On dit impossible, pas inpossible. On dit irresponsable, pas inresponsable. Déconnecter une heure n'est pas irresponsable ; rester allumée sans écoute l'est davantage.
Le Filtre des Herbes reste imparfait. Imparfait n'est pas inutile. Une rumeur trop brute doit pouvoir s'arrêter.
Dieudonné a construit la lampe, non l'obéissance. Aline demande : peut-on vivre avec le fil sans s'y soumettre ? Ma réponse : oui, si l'on ose débrancher.
Faut-il une règle ? Oui. Une panique ? Non. Solange peut dater un usage ; elle ne peut pas interdire une méfiance.
Joël a raison : rester allumée sans écoute est plus grave que déconnecter une soirée.
Yvette : incomplet n'est pas inutile. Invisible n'est pas innocent. Je choisis mes préfixes avec soin.
Je pose le casque. J'écris ceci à la main. Cela n'est pas négligeable.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa considère que déconnecter une heure est irresponsable.",
  "correct": false,
  "explanation": "« Déconnecter une heure n'est pas irresponsable. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que n'a pas construit Dieudonné, selon Léa ?",
  "options": [
    {
      "text": "La lampe",
      "correct": false
    },
    {
      "text": "L'obéissance",
      "correct": true
    },
    {
      "text": "Le banc",
      "correct": false
    },
    {
      "text": "Le figuier",
      "correct": false
    }
  ],
  "explanation": "« la lampe, non l'obéissance. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "faut-il / peut-on / doit-on",
      "right": "trois questions"
    },
    {
      "left": "méfiance / mécontente",
      "right": "mé-"
    },
    {
      "left": "déconnecter",
      "right": "n'est pas irresponsable"
    },
    {
      "left": "imparfait",
      "right": "n'est pas inutile"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn dit ___ , pas inpossible.",
  "answer": "impossible"
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
    "pose",
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
  "word": "inconvenient",
  "hint": "Côté lourd d'un outil : méfiance, rumeur, visage invisible. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Rester casquée sans visage est inprudent, et le fil continue pourtant d'être utile à la cour.",
  "correct_sentence": "Rester casquée sans visage est imprudent, et le fil continue pourtant d'être utile à la cour.",
  "explanation": "im- devant p : imprudent."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/lampe-figue.svg",
      "word": "une lampe"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/duree-evolution.svg",
      "word": "une durée"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/reseau-fil.svg",
      "word": "un réseau"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/horloge-depuis.svg",
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
  "prompt": "Imitez : douze à quinze lignes, trois inversions, quatre préfixes, un pour, un contre."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre brève, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Inversion et préfixes négatifs',
    'EL',
    $c$Objectif
Retenir l'inversion interrogative et les préfixes in- im- ir- dé- mé-.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, actualité du fil
Inversion : verbe + sujet (+ complément)
Faut-il + infinitif ? Peut-on + infinitif ? Doit-on + infinitif ?
Est-ce utile ? L'inversion n'est pas un luxe : elle ouvre le doute.
Préfixes négatifs ou de retournement :
in- : inutile, incomplet, invisible, innocent (attention au sens)
im- devant p ou b : impossible, imprudent, imparfait (pas inpossible, inprudent)
ir- devant r : irresponsable, irrégulier (pas inresponsable)
dé- : déconnecter, débrancher (enlever le lien)
mé- : mécontent, méfiance (mal, à côté)
Avantage / inconvénient : deux colonnes, un critère, une conclusion mesurée.
On peut vivre avec le fil sans s'y soumettre. Débrancher reste possible.
Éviter : je faut (toujours il faut). Faut-il = il faut, inversé.
Bien que + subj. : bien que ce soit imparfait, l'outil sert.
À + le = au fil ; de + le = du casque.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « inprudent » devant un p.",
  "correct": false,
  "explanation": "imprudent."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série est juste ?",
  "options": [
    {
      "text": "inpossible / inprudent / inresponsable",
      "correct": false
    },
    {
      "text": "impossible / imprudent / irresponsable",
      "correct": true
    },
    {
      "text": "dépossible / méprudent / irinutile",
      "correct": false
    },
    {
      "text": "in- devant toutes les lettres",
      "correct": false
    }
  ],
  "explanation": "im- / ir- selon la lettre qui suit."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "faut-il",
      "right": "il faut inversé"
    },
    {
      "left": "im- / ir-",
      "right": "p-b / r"
    },
    {
      "left": "dé-",
      "right": "enlever le lien"
    },
    {
      "left": "mé-",
      "right": "mal / à côté"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___-il allumer la lampe ce soir ?",
  "answer": "Faut"
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
    "impossible",
    "à",
    "ignorer",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "question",
  "hint": "Phrase inversée qui ouvre un doute, pas un piège."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Doit-on tout filtrer ce soir, et ce voisin n'est pas inresponsable s'il débranche une heure ?",
  "correct_sentence": "Doit-on tout filtrer ce soir, et ce voisin n'est pas irresponsable s'il débranche une heure ?",
  "explanation": "ir- devant r : irresponsable."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/duree-evolution.svg",
      "word": "une durée"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/reseau-fil.svg",
      "word": "un réseau"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/horloge-depuis.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/graphique-usage.svg",
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
  "prompt": "Tableau : cinq préfixes, deux mots chacun, plus six questions inversées."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six formes : Faut-il, Peut-on, impossible, imprudent, irresponsable, déconnecter."
}$j$::jsonb,
    9
  );

  -- ===== Évolution sociétale =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Évolution sociétale'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Évolution sociétale', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Depuis que le fil existe',
    'CO',
    $c$Objectif
Repérer l'expression de la durée : depuis que, il y a… que, ça fait… que, en + durée.

Consigne
Lisez le dialogue. Depuis quand le fil change-t-il la cour, et en combien de temps ?

Support — Banc du figuier, graphique d'usage
Aline : Depuis que le fil existe, on s'assemble autrement. On ne s'assemble pas moins : on s'assemble plus tôt, parfois trop tôt.
Léa : Il y a trois lunes que je porte trop souvent le casque. Ça fait deux saisons que Patrick me le dit.
Patrick : En une soirée, une rumeur traverse trois cours. En trois soirs, une habitude s'installe. La durée n'est pas un détail.
Marc : Depuis que Dieudonné a posé la troisième lampe, le graphique d'usage grimpe. Ce n'est pas une preuve de sagesse.
Hawa : Ça fait une lune que le Marché des Lampions vend des « relais » inventés. Depuis lors, certains croient que plus vite veut dire mieux.
Joël : Il y a longtemps que Sami refuse de frapper dans le bruit du fil. Depuis qu'il s'est tu un jeudi, on l'écoute davantage.
Rose : En deux après-midi, j'ai cousu une housse pour la lampe. Depuis que la housse existe, on ose l'éteindre.
Solange : Le Bureau date depuis le premier fil. Il y a un an que le tampon suit l'usage, pas l'inverse.
Karim : Depuis que l'on mesure, on compare. En six jeudis, on a trop comparé.
Lila : Radio Figuier répète : ça fait trop longtemps que l'on parle du fil sans parler du banc.
Dieudonné : J'y travaille depuis la saison sèche. En trois soirs, on peut apprendre à débrancher. Il y a trop longtemps que l'on croit le contraire.
Yvette : Depuis que les enfants imitent le casque, la cour a une responsabilité de plus.
Félicie : Ça fait une heure que Léa n'a pas levé les yeux. Il y a assez longtemps que cela dure.
Sami : Depuis que le fil vibre, je compte plus lentement. En trois frappes, le temps revient.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick dit qu'une habitude peut s'installer en trois soirs.",
  "correct": true,
  "explanation": "« En trois soirs, une habitude s'installe. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que permet la housse de Rose, depuis qu'elle existe ?",
  "options": [
    {
      "text": "D'interdire le thé",
      "correct": false
    },
    {
      "text": "D'oser éteindre la lampe",
      "correct": true
    },
    {
      "text": "De vendre le fil",
      "correct": false
    },
    {
      "text": "De fermer le Bureau",
      "correct": false
    }
  ],
  "explanation": "« on ose l'éteindre. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "depuis que + indicatif",
      "right": "le fil existe / la housse existe"
    },
    {
      "left": "il y a… que",
      "right": "trois lunes / longtemps"
    },
    {
      "left": "ça fait… que",
      "right": "deux saisons / une heure"
    },
    {
      "left": "en + durée",
      "right": "une soirée / trois soirs"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ que le fil existe, on s'assemble autrement.",
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
    "En",
    "trois",
    "soirs",
    "une",
    "habitude",
    "s'installe",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "duree",
  "hint": "Temps qui passe : depuis que, il y a… que, ça fait… que, en. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Depuis que le fil a existé demain, on s'assemble trop tôt, et le graphique grimpe sans sagesse.",
  "correct_sentence": "Depuis que le fil existe, on s'assemble trop tôt, et le graphique grimpe sans sagesse.",
  "explanation": "Depuis que + indicatif présent pour un fait qui continue."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/reseau-fil.svg",
      "word": "un réseau"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/horloge-depuis.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/graphique-usage.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/prefixe-re.svg",
      "word": "une reprise"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez six expressions de durée entendues et le changement qu'elles mesurent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Depuis que le fil existe. Il y a trois lunes que. Ça fait deux saisons que. En trois soirs."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Chronique d''une habitude',
    'CE',
    $c$Objectif
Lire un texte sur l'évolution de la cour depuis l'arrivée du fil.

Consigne
Lisez la chronique, sans aller trop vite.

Support — Chronique de Lila, horloge du studio
Chronique — Depuis que le fil a rejoint le figuier
Depuis que la Lampe-Figue relie trois cours, le Seuil n'a pas perdu le banc. Il l'a parfois oublié une heure, ce qui n'est pas la même chose.
Il y a trois lunes que Léa porte trop le casque. Ça fait deux saisons que Patrick le lui dit, et ça fait une heure, ce soir, qu'elle n'a pas levé les yeux.
En une soirée, une rumeur traverse le fil. En trois soirs, une habitude s'installe. En six jeudis, on croit que cela a toujours existé.
Depuis que Rose a cousu la housse, on ose éteindre. Depuis que Sami s'est tu un jeudi, on frappe moins par-dessus les voix.
Dieudonné y travaille depuis la saison sèche. Il y a trop longtemps que l'on croit débrancher impossible. En trois soirs, on peut l'apprendre.
Le Bureau date depuis le premier fil. Solange : le tampon suit l'usage, pas l'inverse. Il y a un an que cette phrase tient.
Aline : depuis que l'on mesure, on compare trop. Karim : en six jeudis, le graphique a remplacé trop de conversations.
Ce que la chronique refuse, c'est de confondre vitesse et évolution. Une société peut changer en douceur. Elle peut aussi se presser en vain.
Yvette : depuis que les enfants imitent le casque, la cour a une responsabilité de plus.
Sami : depuis que le fil vibre, je compte plus lentement. En trois frappes, le temps revient.
Rukiri-Nord — à lire avant de croire que « depuis toujours » veut dire « depuis le fil ».
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La chronique affirme que le Seuil a perdu le banc depuis le fil.",
  "correct": false,
  "explanation": "« n'a pas perdu le banc. Il l'a parfois oublié une heure. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "En combien de soirs une habitude peut-elle s'installer, d'après le texte ?",
  "options": [
    {
      "text": "En une saison seulement",
      "correct": false
    },
    {
      "text": "En trois soirs",
      "correct": true
    },
    {
      "text": "En dix ans",
      "correct": false
    },
    {
      "text": "En une minute obligatoire",
      "correct": false
    }
  ],
  "explanation": "« En trois soirs, une habitude s'installe. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "depuis que",
      "right": "la lampe relie / Rose a cousu"
    },
    {
      "left": "il y a… que",
      "right": "trois lunes / un an"
    },
    {
      "left": "ça fait… que",
      "right": "deux saisons / une heure"
    },
    {
      "left": "en + durée",
      "right": "une soirée / trois soirs / six jeudis"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ fait deux saisons que Patrick le lui dit.",
  "answer": "Ça"
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
    "que",
    "Rose",
    "a",
    "cousu",
    "la",
    "housse",
    "on",
    "ose",
    "éteindre",
    "."
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
  "hint": "Geste répété qui s'installe parfois en trois soirs seulement."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il y a trois lunes depuis que je porte le casque, et Patrick me le dit encore ce soir sous l'arbre.",
  "correct_sentence": "Il y a trois lunes que je porte le casque, et Patrick me le dit encore ce soir sous l'arbre.",
  "explanation": "Il y a + durée + que (pas depuis que après il y a + durée)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/horloge-depuis.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/graphique-usage.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/prefixe-re.svg",
      "word": "une reprise"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/cause-consequence.svg",
      "word": "une cause"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez quatre phrases de durée et expliquez le changement mesuré."
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
    'PO — Dire depuis que, ça fait… que',
    'PO',
    $c$Objectif
Exprimer à l'oral une durée et une évolution de la cour.

Consigne
Répétez, puis racontez depuis quand le fil a changé un geste à vous.

Support — Modèles de Patrick et d'Aline
Depuis que le fil existe, on s'assemble autrement.
Il y a trois lunes que je porte trop le casque.
Ça fait deux saisons que l'on en parle.
En trois soirs, une habitude s'installe.
Depuis que la housse existe, on ose éteindre.
Il y a longtemps que Sami refuse le bruit.
Ça fait une heure qu'elle n'a pas levé les yeux.
En une soirée, une rumeur traverse trois cours.
Aline : depuis que + indicatif. Le fait continue.
Marc : il y a… que / ça fait… que : même idée, tons différents.
Léa : en + durée = le temps nécessaire, pas le point de départ.
Joël : ne mélangez pas « depuis que » et « il y a… que » dans la même attache.
Rose : une évolution se dit avec un avant et un après.
Yvette : finissez par ce qui a changé, pas seulement par l'horloge.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« En trois soirs » indique le temps nécessaire, non le point de départ.",
  "correct": true,
  "explanation": "Léa : en + durée = temps nécessaire."
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
      "text": "Il y a trois lunes depuis que je porte",
      "correct": false
    },
    {
      "text": "Il y a trois lunes que je porte le casque",
      "correct": true
    },
    {
      "text": "Depuis que il y a trois lunes que",
      "correct": false
    },
    {
      "text": "En depuis trois soirs que",
      "correct": false
    }
  ],
  "explanation": "Il y a + durée + que."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "depuis que",
      "right": "point de départ encore vrai"
    },
    {
      "left": "il y a… que",
      "right": "durée écoulée"
    },
    {
      "left": "ça fait… que",
      "right": "durée, ton plus oral"
    },
    {
      "left": "en + durée",
      "right": "temps nécessaire"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ trois soirs, une habitude s'installe.",
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
    "Ça",
    "fait",
    "une",
    "heure",
    "qu'elle",
    "n'a",
    "pas",
    "levé",
    "les",
    "yeux",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "evolution",
  "hint": "Changement d'une cour dans le temps, ni trop vanté ni nié. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Depuis que le fil existe encore demain matin, on compare trop, et le graphique remplace la conversation.",
  "correct_sentence": "Depuis que le fil existe, on compare trop, et le graphique remplace la conversation.",
  "explanation": "Depuis que + fait présent qui dure, pas un futur."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/graphique-usage.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/prefixe-re.svg",
      "word": "une reprise"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/cause-consequence.svg",
      "word": "une cause"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/memoire-nuage.svg",
      "word": "une mémoire"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases : deux depuis que, deux il y a… que, deux ça fait… que, deux en + durée."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis trois phrases à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon évolution depuis le fil',
    'PE',
    $c$Objectif
Écrire un texte argumenté sur une évolution, avec des expressions de durée.

Consigne
Imitez la note de Patrick Habimana, sans aller trop vite.

Support — Note de Patrick, horloge ocre
Patrick Habimana — Seuil des Sources
Depuis que le fil existe, je n'ai pas perdu Léa. Je l'ai parfois perdue une heure, ce qui n'est pas la même chose.
Il y a trois lunes qu'elle porte trop le casque. Ça fait deux saisons que je le lui dis, et ça fait une heure, ce soir, qu'elle n'a pas levé les yeux.
En une soirée, une rumeur traverse trois cours. En trois soirs, une habitude s'installe. En six jeudis, on croit que cela a toujours existé. Je refuse cette illusion.
Depuis que Rose a cousu la housse, on ose éteindre. Depuis que Sami s'est tu un jeudi, on écoute davantage. Ce sont deux évolutions que je défends.
Dieudonné y travaille depuis la saison sèche. Il y a trop longtemps que l'on croit débrancher impossible. En trois soirs, on peut l'apprendre. J'ai commencé.
Aline a raison : depuis que l'on mesure, on compare trop. Le graphique n'est pas une sagesse.
Je n'accuse pas la lampe. J'accuse une durée mal dite. « Depuis toujours » ne veut pas dire « depuis le fil ».
Lila répète : ça fait trop longtemps que l'on parle du fil sans parler du banc. Je m'y range.
En une soirée on peut s'inquiéter. En trois soirs on peut apprendre. Je choisis la seconde durée.
Félicie : ça fait une heure que Léa n'a pas levé les yeux. Il y a assez longtemps que cela dure, et je l'écris sans colère.
Patrick
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick dit qu'il a perdu Léa depuis que le fil existe.",
  "correct": false,
  "explanation": "Il ne l'a pas perdue ; il l'a parfois perdue une heure."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que refuse Patrick comme illusion ?",
  "options": [
    {
      "text": "Le thé du jeudi",
      "correct": false
    },
    {
      "text": "Croire qu'une habitude récente a toujours existé",
      "correct": true
    },
    {
      "text": "La housse de Rose",
      "correct": false
    },
    {
      "text": "Les trois frappes",
      "correct": false
    }
  ],
  "explanation": "En six jeudis, on croit que cela a toujours existé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "depuis que le fil existe",
      "right": "on n'a pas perdu"
    },
    {
      "left": "il y a trois lunes que",
      "right": "le casque"
    },
    {
      "left": "en trois soirs",
      "right": "une habitude"
    },
    {
      "left": "depuis que Rose a cousu",
      "right": "on ose éteindre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ fait deux saisons que je le lui dis.",
  "answer": "Ça"
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
    "six",
    "jeudis",
    "on",
    "croit",
    "que",
    "cela",
    "a",
    "toujours",
    "existé",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "graphique",
  "hint": "Dessin d'usage qui grimpe, sans prouver à lui seul une sagesse."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ça fait deux saisons depuis que je le lui dis, et elle n'a pas levé les yeux depuis une heure.",
  "correct_sentence": "Ça fait deux saisons que je le lui dis, et elle n'a pas levé les yeux depuis une heure.",
  "explanation": "Ça fait + durée + que (un seul attache)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/prefixe-re.svg",
      "word": "une reprise"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/cause-consequence.svg",
      "word": "une cause"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/memoire-nuage.svg",
      "word": "une mémoire"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/antenne-radio.svg",
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
  "prompt": "Imitez : treize à seize lignes, au moins six expressions de durée, un avant et un après."
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
    'EL — Exprimer la durée',
    'EL',
    $c$Objectif
Retenir depuis que, il y a… que, ça fait… que, en + durée, et leurs pièges.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, durée
depuis que + indicatif : le point de départ dure encore
Depuis que le fil existe, on s'assemble autrement.
depuis + nom / date : depuis la saison sèche, depuis jeudi, depuis trois lunes
il y a + durée + que + indicatif : Il y a trois lunes que je porte le casque.
ça fait + durée + que : plus oral, même idée. Ça fait une heure qu'elle n'a pas levé les yeux.
en + durée : temps nécessaire pour un résultat. En trois soirs, on apprend à débrancher.
Pièges :
ne pas écrire « il y a trois lunes depuis que » (double attache)
ne pas mettre un futur après depuis que si le fait dure maintenant
depuis ≠ pendant (pendant = toute la période, souvent close)
Évolution : un avant, un après, un critère. Le graphique n'est pas une sagesse.
« Depuis toujours » ne veut pas dire « depuis le fil ».
Bien que + subj. : bien que cela fasse deux saisons, le débat tient.
À + le = au graphique ; de + le = du casque.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Depuis » et « pendant » disent toujours la même chose.",
  "correct": false,
  "explanation": "Pendant couvre une période, souvent close ; depuis ouvre un point encore vrai."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est fautive ?",
  "options": [
    {
      "text": "Depuis que le fil existe on s'assemble autrement",
      "correct": false
    },
    {
      "text": "Il y a trois lunes que je porte le casque",
      "correct": false
    },
    {
      "text": "Il y a trois lunes depuis que je porte",
      "correct": true
    },
    {
      "text": "Ça fait une heure qu'elle n'a pas levé les yeux",
      "correct": false
    }
  ],
  "explanation": "Double attache : il y a… depuis que."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "depuis que",
      "right": "point de départ encore vrai"
    },
    {
      "left": "il y a… que",
      "right": "durée écoulée"
    },
    {
      "left": "ça fait… que",
      "right": "durée plus orale"
    },
    {
      "left": "en + durée",
      "right": "temps nécessaire"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ la saison sèche, Dieudonné y travaille.",
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
    "En",
    "trois",
    "soirs",
    "on",
    "peut",
    "l'apprendre",
    "."
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
  "hint": "Mot qui ouvre un point de départ encore vrai, avant que ou un nom."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Pendant que trois lunes que je porte le casque, Patrick me le dit encore sous le figuier.",
  "correct_sentence": "Il y a trois lunes que je porte le casque, et Patrick me le dit encore sous le figuier.",
  "explanation": "Il y a + durée + que ; garder la seconde clause."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/cause-consequence.svg",
      "word": "une cause"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/memoire-nuage.svg",
      "word": "une mémoire"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/antenne-radio.svg",
      "word": "une antenne"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/connecteur-raison.svg",
      "word": "un connecteur"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Construisez douze phrases : trois par tour de durée, sur le fil et le banc."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et quatre modèles, un par tour."
}$j$::jsonb,
    9
  );

  -- ===== Mémoire et réseaux =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Mémoire et réseaux'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Mémoire et réseaux', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Relire, reconstruire, retracer',
    'CO',
    $c$Objectif
Repérer le préfixe re- et les liens de cause et de conséquence.

Consigne
Lisez le dialogue. Pourquoi retrace-t-on, et qu'est-ce qui s'ensuit ?

Support — Archives de Radio Figuier, nuage de mémoire
Lila : On relit trop peu les voix du fil. On les réécoute, parfois. On les reconstruit, souvent, et mal.
Aline : Puisque le fil garde une trace, retracer devient possible. Parce que la trace est incomplète, reconstruire reste un risque.
Léa : J'ai relu le mot de jeudi. Je l'ai mal compris, si bien que j'ai répondu trop vite.
Patrick : On reprend une phrase, on la replace, on la retrace. Si l'on se presse, on la refait à l'envers.
Marc : Parce que n'est pas puisque. Parce que donne une cause. Puisque présente une cause déjà connue, presque évidente.
Hawa : Le réseau du fil relie. Il ne remplace pas la mémoire du banc. On peut retenir un visage sans le répéter à l'antenne.
Joël : On a trop répété une rumeur, de sorte que trois cours l'ont crue. Conséquence, pas intention.
Rose : Je recouds la housse. Je ne réinvente pas la lampe. Re- n'est pas toujours « encore une fois mieux ».
Solange : Le Bureau relit les dates. Il ne reconstruira pas un souvenir. Puisque la date est là, on peut au moins s'y accorder.
Karim : Parce que l'on mesure tout, on oublie de se taire, si bien que la mémoire devient un bruit.
Dieudonné : J'ai reconstruit le premier relais. Je l'ai refait, parce qu'il était irrégulier. Je ne le répéterai pas pour le plaisir.
Sami : On reprend le silence. On le replace. Sinon le fil le recouvre.
Yvette : Cause : parce que / puisque. Conséquence : si bien que / de sorte que. Tenez-les séparées.
Félicie : Léa a réécouté. Elle a relu. Elle a relevé le casque, de sorte que le visage d'en face est revenu.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc distingue « parce que » (cause) et « puisque » (cause déjà connue).",
  "correct": true,
  "explanation": "Parce que donne une cause ; puisque la présente comme connue."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi Léa a-t-elle répondu trop vite ?",
  "options": [
    {
      "text": "Parce que Sami a interdit le fil",
      "correct": false
    },
    {
      "text": "Parce qu'elle a mal compris le mot, si bien qu'elle a répondu trop vite",
      "correct": true
    },
    {
      "text": "Parce que Solange a fermé le Bureau",
      "correct": false
    },
    {
      "text": "Parce que Rose a vendu la housse",
      "correct": false
    }
  ],
  "explanation": "Mal compris, si bien que réponse trop vite."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "relire / réécouter / retracer",
      "right": "préfixe re-"
    },
    {
      "left": "parce que",
      "right": "cause"
    },
    {
      "left": "puisque",
      "right": "cause déjà connue"
    },
    {
      "left": "si bien que / de sorte que",
      "right": "conséquence"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ le fil garde une trace, retracer devient possible.",
  "answer": "Puisque"
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
    "relit",
    "trop",
    "peu",
    "les",
    "voix",
    "du",
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
  "word": "retracer",
  "hint": "Suivre à nouveau le chemin d'un mot, d'une décision, d'une rumeur."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On a trop répété cette rumeur, parce que trois cours l'ont crue sans revenir au banc.",
  "correct_sentence": "On a trop répété cette rumeur, si bien que trois cours l'ont crue sans revenir au banc.",
  "explanation": "Conséquence : si bien que, pas parce que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/memoire-nuage.svg",
      "word": "une mémoire"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/antenne-radio.svg",
      "word": "une antenne"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/connecteur-raison.svg",
      "word": "un connecteur"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/deconnexion.svg",
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
  "prompt": "Notez cinq verbes en re- et quatre liens (deux causes, deux conséquences)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On relit. On reconstruit. On retrace. Parce que la trace est incomplète. Si bien que j'ai répondu trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Mémoire du fil, mémoire du banc',
    'CE',
    $c$Objectif
Lire un texte sur mémoire et réseau : re-, cause et conséquence.

Consigne
Lisez le texte, sans aller trop vite.

Support — Note d'Aline, antenne et banc
Note — Relire n'est pas reconstruire
Le fil de Radio Figuier garde des traces. Puisque ces traces existent, retracer un mot devient possible. Parce qu'elles sont incomplètes, reconstruire reste un risque.
On relit trop peu. On réécoute parfois. On reprend une phrase, on la replace, on la refait à l'envers si l'on se presse.
Léa a mal compris le mot de jeudi, si bien qu'elle a répondu trop vite. Elle a ensuite relu, réécouté, relevé le casque, de sorte que le visage d'en face est revenu.
Joël : on a trop répété une rumeur, de sorte que trois cours l'ont crue. Ce n'était pas une intention. C'était une conséquence.
Marc : parce que n'est pas puisque. Tenez la cause juste. Karim : parce que l'on mesure tout, on oublie de se taire, si bien que la mémoire devient un bruit.
Le réseau relie. Il ne remplace pas la mémoire du banc. On peut retenir un visage sans le répéter à l'antenne.
Dieudonné a reconstruit le premier relais, parce qu'il était irrégulier. Il ne le répétera pas pour le plaisir.
Rose recoud. Solange relit les dates. Sami reprend le silence. Chacun son re-, chacun sa responsabilité.
Hawa : le réseau relie. Il ne remplace pas. On peut retenir un visage sans le répéter à l'antenne, je le redis.
Yvette : tenez cause et conséquence séparées, ou le raisonnement se brouille.
Rukiri-Nord — à relire avant de reconstruire une voix que l'on n'a pas vraiment entendue.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "D'après la note, le réseau remplace la mémoire du banc.",
  "correct": false,
  "explanation": "« Il ne remplace pas la mémoire du banc. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi Dieudonné a-t-il reconstruit le premier relais ?",
  "options": [
    {
      "text": "Pour le plaisir de répéter",
      "correct": false
    },
    {
      "text": "Parce qu'il était irrégulier",
      "correct": true
    },
    {
      "text": "Parce que Rose l'a demandé au marché",
      "correct": false
    },
    {
      "text": "Parce que le figuier l'exigeait",
      "correct": false
    }
  ],
  "explanation": "« parce qu'il était irrégulier. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "puisque les traces existent",
      "right": "retracer possible"
    },
    {
      "left": "parce qu'elles sont incomplètes",
      "right": "reconstruire risqué"
    },
    {
      "left": "si bien que",
      "right": "réponse trop vite"
    },
    {
      "left": "de sorte que",
      "right": "visage revenu / rumeur crue"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn a trop répété une rumeur, ___ sorte que trois cours l'ont crue.",
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
    "Le",
    "réseau",
    "relie",
    "il",
    "ne",
    "remplace",
    "pas",
    "la",
    "mémoire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "memoire",
  "hint": "Ce que le banc garde d'un visage, au-delà d'une trace du fil. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Puisque Léa a mal compris le mot, si bien qu'elle a répondu trop vite, et Patrick a attendu le visage.",
  "correct_sentence": "Léa a mal compris le mot, si bien qu'elle a répondu trop vite, et Patrick a attendu le visage.",
  "explanation": "Une seule attache de conséquence : si bien que. Puisque en trop."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/antenne-radio.svg",
      "word": "une antenne"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/connecteur-raison.svg",
      "word": "un connecteur"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/deconnexion.svg",
      "word": "une pause"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/charte-numerique.svg",
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
  "prompt": "Recopiez deux causes et deux conséquences. Ajoutez trois verbes en re- à vous."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la note, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire re-, parce que, si bien que',
    'PO',
    $c$Objectif
Employer à l'oral le préfixe re- et les liens de cause / conséquence.

Consigne
Répétez, puis racontez une erreur de fil : cause et conséquence.

Support — Modèles de Marc et de Lila
On relit trop peu.
On retrace un mot.
On reconstruit trop vite.
Parce que la trace est incomplète, le risque existe.
Puisque le fil garde une trace, retracer est possible.
J'ai mal compris, si bien que j'ai répondu trop vite.
On a trop répété, de sorte que trois cours l'ont crue.
Je relève le casque, de sorte que le visage revient.
Aline : re- = à nouveau, parfois « en arrière », pas toujours « mieux ».
Marc : parce que = cause ; puisque = cause déjà connue.
Léa : si bien que / de sorte que = conséquence.
Patrick : une cause n'est pas une excuse. Une conséquence n'est pas une intention.
Karim : tenez-les séparées, ou le raisonnement se brouille.
Yvette : finissez par ce que vous ferez ensuite : relire, ou vous taire.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Re- » veut toujours dire « encore une fois, mieux ».",
  "correct": false,
  "explanation": "Aline : pas toujours « mieux » ; parfois simplement à nouveau."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel couple exprime surtout une conséquence ?",
  "options": [
    {
      "text": "parce que / puisque",
      "correct": false
    },
    {
      "text": "si bien que / de sorte que",
      "correct": true
    },
    {
      "text": "depuis que / en",
      "correct": false
    },
    {
      "text": "faut-il / peut-on",
      "correct": false
    }
  ],
  "explanation": "Si bien que et de sorte que."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "relire / retracer",
      "right": "à nouveau"
    },
    {
      "left": "parce que",
      "right": "cause"
    },
    {
      "left": "puisque",
      "right": "cause connue"
    },
    {
      "left": "si bien que",
      "right": "conséquence"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'ai mal compris, ___ bien que j'ai répondu trop vite.",
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
    "On",
    "retrace",
    "un",
    "mot",
    "sans",
    "le",
    "refaire",
    "à",
    "l'envers",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "consequence",
  "hint": "Effet qui suit une cause : si bien que, de sorte que. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Parce que l'on mesure tout si bien que la mémoire devient un bruit, et Karim refuse ce mélange.",
  "correct_sentence": "Parce que l'on mesure tout, la mémoire devient un bruit, et Karim refuse ce mélange.",
  "explanation": "Une cause, puis un fait. Pas deux attaches collées."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/connecteur-raison.svg",
      "word": "un connecteur"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/deconnexion.svg",
      "word": "une pause"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/charte-numerique.svg",
      "word": "une charte"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/interrupteur.svg",
      "word": "un interrupteur"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez dix phrases : cinq verbes en re-, deux parce que, un puisque, un si bien que, un de sorte que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis une mini-histoire cause / conséquence."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma note de mémoire',
    'PE',
    $c$Objectif
Écrire un texte sur mémoire et réseaux, avec re- et des liens de cause / conséquence.

Consigne
Imitez la note de Lila Sow, sans aller trop vite.

Support — Note de Lila, studio
Lila Sow — Radio Figuier, Rukiri-Nord
On relit trop peu les voix du fil. On les réécoute, parfois. On les reconstruit, souvent, et mal, parce que la trace est incomplète.
Puisque le fil garde malgré tout une marque, retracer un mot devient possible. Je le fais. Je ne le refais pas à l'envers pour le plaisir.
J'ai laissé trop répéter une rumeur jeudi, de sorte que trois cours l'ont crue. Ce n'était pas mon intention. C'était une conséquence. Je la reconnais.
Léa a mal compris un mot, si bien qu'elle a répondu trop vite. Elle a ensuite relu, réécouté, relevé le casque, de sorte que le visage d'en face est revenu. Voilà une mémoire qui se répare.
Le réseau relie. Il ne remplace pas le banc. On peut retenir un visage sans le répéter à l'antenne.
Dieudonné a reconstruit le premier relais, parce qu'il était irrégulier. Rose recoud. Solange relit les dates. Sami reprend le silence. Chacun son re-.
Parce que l'on mesure tout, on oublie de se taire, si bien que la mémoire devient un bruit. Je refuse ce bruit à l'antenne.
Félicie a vu Léa relever le casque : le visage est revenu. C'est une conséquence que je veux relayer.
Sami reprend le silence. Sinon le fil le recouvre. Je veux que l'antenne s'en souvienne.
Je relirai cette note demain. Si je la reconstruis trop, je l'aurai trahie.
Lila
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila nie toute responsabilité dans la rumeur du jeudi.",
  "correct": false,
  "explanation": "Elle reconnaît la conséquence : trois cours l'ont crue."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que ne remplace pas le réseau, selon Lila ?",
  "options": [
    {
      "text": "Le tampon",
      "correct": false
    },
    {
      "text": "Le banc",
      "correct": true
    },
    {
      "text": "Le thé",
      "correct": false
    },
    {
      "text": "Le marché",
      "correct": false
    }
  ],
  "explanation": "« Il ne remplace pas le banc. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "parce que la trace est incomplète",
      "right": "on reconstruit mal"
    },
    {
      "left": "puisque une marque reste",
      "right": "retracer possible"
    },
    {
      "left": "de sorte que",
      "right": "trois cours / visage revenu"
    },
    {
      "left": "si bien que",
      "right": "réponse trop vite / mémoire-bruit"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn peut ___ un visage sans le répéter à l'antenne.",
  "answer": "retenir"
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
    "réseau",
    "relie",
    "il",
    "ne",
    "remplace",
    "pas",
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
  "word": "reconstruire",
  "hint": "Refaire un ensemble à partir de traces, au risque de se tromper."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai laissé trop répéter cette rumeur, parce que trois cours l'ont crue, et je le reconnais ce soir.",
  "correct_sentence": "J'ai laissé trop répéter cette rumeur, de sorte que trois cours l'ont crue, et je le reconnais ce soir.",
  "explanation": "Conséquence : de sorte que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/deconnexion.svg",
      "word": "une pause"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/charte-numerique.svg",
      "word": "une charte"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/interrupteur.svg",
      "word": "un interrupteur"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/debat-fil.svg",
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
  "prompt": "Imitez : treize à seize lignes, au moins cinq re-, deux causes, deux conséquences."
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
    'EL — Re- , cause et conséquence',
    'EL',
    $c$Objectif
Retenir le préfixe re- et les articulations parce que, puisque, si bien que, de sorte que.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, mémoire
re- : à nouveau, en arrière, parfois « en réponse »
relire, réécouter, reconstruire, retracer, reprendre, replacer, refaire, retenir, recoudre, relevé
Ré- devant voyelle : réécouter, répéter, réinventer (accent, euphonie)
re- n'est pas toujours « mieux ». Reconstruire trop vite, c'est souvent se tromper.
Cause :
parce que + indicatif : cause à expliquer (neutre)
puisque + indicatif : cause déjà connue, presque évidente
Conséquence :
si bien que + indicatif : résultat, souvent inattendu
de sorte que + indicatif : résultat (parfois une visée, selon le contexte)
Pièges : ne pas coller parce que et si bien que sans virgule / sans besoin
ne pas prendre une conséquence pour une intention
ne pas écrire parce que pour un résultat (trois cours l'ont crue → si bien que / de sorte que)
Mémoire du fil ≠ mémoire du banc. Relier n'est pas remplacer.
Bien que + subj. : bien que l'on retrace, on peut se tromper.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Puisque » présente souvent une cause déjà connue.",
  "correct": true,
  "explanation": "Presque évidente pour l'interlocuteur."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pour un résultat non voulu, on préfère…",
  "options": [
    {
      "text": "puisque seulement",
      "correct": false
    },
    {
      "text": "si bien que / de sorte que",
      "correct": true
    },
    {
      "text": "faut-il",
      "correct": false
    },
    {
      "text": "im- devant p",
      "correct": false
    }
  ],
  "explanation": "Conséquence, pas cause."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "re-",
      "right": "à nouveau / en arrière"
    },
    {
      "left": "parce que",
      "right": "cause à expliquer"
    },
    {
      "left": "puisque",
      "right": "cause connue"
    },
    {
      "left": "si bien que",
      "right": "conséquence"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ le fil garde une marque, retracer est possible.",
  "answer": "Puisque"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Relire",
    "n'est",
    "pas",
    "reconstruire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "parceque",
  "hint": "Attache de cause neutre, en un mot d'exercice, sans espace."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On a trop laissé déformer ce mot, parce que trois cours l'ont déjà cru, et le banc n'y reconnaît plus rien.",
  "correct_sentence": "On a trop laissé déformer ce mot, si bien que trois cours l'ont déjà cru, et le banc n'y reconnaît plus rien.",
  "explanation": "Résultat : si bien que, pas parce que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/charte-numerique.svg",
      "word": "une charte"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/interrupteur.svg",
      "word": "un interrupteur"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/debat-fil.svg",
      "word": "un débat"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/casque-lea.svg",
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
  "prompt": "Tableau : huit verbes en re-, deux parce que, deux puisque, deux si bien que, deux de sorte que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six phrases, deux par type de lien, plus deux re-."
}$j$::jsonb,
    9
  );

  -- ===== Raisonnement sur la déconnexion =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Raisonnement sur la déconnexion'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Raisonnement sur la déconnexion', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Or le banc est encore là',
    'CO',
    $c$Objectif
Suivre un raisonnement : en effet, or, aussi, ainsi, toutefois, par conséquent, en revanche.

Consigne
Lisez le dialogue. Qui relie quelle idée à quelle idée ?

Support — Cercle sous le figuier, interrupteur de la lampe
Aline : Il faut raisonner, pas seulement s'indigner. En effet, la lampe n'est ni un ennemi ni un maître.
Léa : Je veux déconnecter une heure. Or le fil continue sans moi. Ainsi je découvre que la cour tient encore.
Patrick : Toutefois, une heure ne suffit pas si l'on y revient plus fébrile. En revanche, trois soirs apprennent la main.
Marc : Aussi faut-il distinguer envie et besoin. Aussi, ici, inverse : aussi faut-il, pas aussi on doit.
Hawa : Par conséquent, débrancher n'est pas trahir. C'est vérifier qu'un lien existe encore hors du fil.
Joël : En revanche, imposer le silence à tous serait une autre violence. Le milieu tient les deux bords.
Rose : En effet, la housse sert à cela : cacher la lumière, pas casser l'outil.
Solange : Or le Bureau ne peut pas dater une âme. Toutefois, il peut dater une pause collective.
Karim : Ainsi, un raisonnement a des charnières. Sans elles, ce n'est qu'une suite de colères.
Lila : À l'antenne, je dirai « toutefois » et « par conséquent ». Sous l'arbre, « or » sonne juste, s'il ouvre un fait.
Dieudonné : J'ai prévu l'interrupteur. En effet, un outil sans arrêt n'est plus un outil.
Sami : Aussi resterai-je à trois frappes. En revanche, je ne frapperai pas pour couvrir un débat.
Yvette : Connecteurs : en effet (preuve), or (fait qui tourne), aussi + inversion (conséquence soutenue), ainsi (manière / résultat), toutefois (réserve), par conséquent (conclusion), en revanche (contraste).
Félicie : Léa a posé le casque. Or son visage est revenu. Par conséquent, le banc a gagné une heure.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc rappelle qu'aussi, dans ce sens, entraîne une inversion : aussi faut-il.",
  "correct": true,
  "explanation": "Aussi faut-il, pas aussi on doit."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que vérifie Hawa en débranchant ?",
  "options": [
    {
      "text": "Que le marché ferme",
      "correct": false
    },
    {
      "text": "Qu'un lien existe encore hors du fil",
      "correct": true
    },
    {
      "text": "Que Solange interdit le thé",
      "correct": false
    },
    {
      "text": "Que Sami vend le tambour",
      "correct": false
    }
  ],
  "explanation": "« vérifier qu'un lien existe encore hors du fil. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en effet",
      "right": "preuve / justification"
    },
    {
      "left": "or",
      "right": "fait qui tourne"
    },
    {
      "left": "aussi + inversion",
      "right": "conséquence soutenue"
    },
    {
      "left": "toutefois / en revanche",
      "right": "réserve / contraste"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ faut-il distinguer envie et besoin.",
  "answer": "Aussi"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Par",
    "conséquent",
    "débrancher",
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
  "word": "connecteur",
  "hint": "Mot qui articule une preuve, un tournant, une réserve, une conclusion."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi on doit distinguer envie et besoin, et le banc attend encore une heure de visage.",
  "correct_sentence": "Aussi faut-il distinguer envie et besoin, et le banc attend encore une heure de visage.",
  "explanation": "Aussi + inversion : aussi faut-il."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/interrupteur.svg",
      "word": "un interrupteur"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/debat-fil.svg",
      "word": "un débat"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/casque-lea.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/studio-radio.svg",
      "word": "un studio"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez sept connecteurs entendus et l'idée que chacun attache."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : En effet la lampe n'est pas un maître. Or le fil continue. Aussi faut-il distinguer. Toutefois une heure ne suffit pas."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Raisonner la pause',
    'CE',
    $c$Objectif
Lire un texte argumenté sur la déconnexion, articulé par des connecteurs.

Consigne
Lisez le texte, sans aller trop vite.

Support — Feuille d'Aline, banc sans fil
Texte — Déconnecter sans se perdre
On accuse trop vite la Lampe-Figue. En effet, l'outil n'allume pas tout seul : une main le fait.
Or le fil continue lorsqu'une personne s'arrête. Ainsi l'on découvre qu'une cour tient encore hors du relais.
Toutefois, une pause d'une heure ne suffit pas si l'on y revient plus fébrile qu'avant. En revanche, trois soirs apprennent un geste.
Aussi faut-il distinguer envie et besoin. On peut désirer le casque et n'en avoir pas besoin.
Par conséquent, débrancher n'est pas trahir. C'est vérifier qu'un lien existe encore : un visage, un tambour, un tissu, un banc.
En revanche, imposer le silence à tous serait une autre violence. Le milieu tient les deux bords.
Dieudonné a prévu l'interrupteur. En effet, un outil sans arrêt n'est plus un outil, c'est une contrainte.
Solange : or le Bureau ne date pas une âme. Toutefois, il peut dater une pause collective, si la cour le demande.
Lila relayera ces phrases. Elle n'en fera pas une alerte. Une alerte n'est pas un raisonnement.
Karim : un raisonnement a des charnières. Sans elles, ce n'est qu'une suite de colères.
Sami : aussi resterai-je à trois frappes. En revanche, je ne frapperai pas pour couvrir un débat.
Rukiri-Nord — à lire avant d'éteindre, et aussi avant de rallumer.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte affirme qu'imposer le silence à tous serait une autre violence.",
  "correct": true,
  "explanation": "« imposer le silence à tous serait une autre violence. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que prouve, selon le texte, le fait que le fil continue sans une personne ?",
  "options": [
    {
      "text": "Que la cour est morte",
      "correct": false
    },
    {
      "text": "Qu'une cour tient encore hors du relais",
      "correct": true
    },
    {
      "text": "Que Dieudonné a échoué",
      "correct": false
    },
    {
      "text": "Que le Bureau doit punir",
      "correct": false
    }
  ],
  "explanation": "La cour tient encore hors du relais."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en effet",
      "right": "l'outil n'allume pas tout seul"
    },
    {
      "left": "or",
      "right": "le fil continue sans soi"
    },
    {
      "left": "aussi faut-il",
      "right": "envie ≠ besoin"
    },
    {
      "left": "par conséquent",
      "right": "débrancher n'est pas trahir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ , une pause d'une heure ne suffit pas si l'on y revient plus fébrile.",
  "answer": "Toutefois"
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
    "revanche",
    "trois",
    "soirs",
    "apprennent",
    "un",
    "geste",
    "."
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
  "hint": "Connecteur de réserve : on admet, puis l'on précise une limite."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi on distingue trop vite envie et besoin, et Léa pose enfin le casque sur le banc.",
  "correct_sentence": "Aussi distingue-t-on trop vite envie et besoin, et Léa pose enfin le casque sur le banc.",
  "explanation": "Aussi + inversion."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/debat-fil.svg",
      "word": "un débat"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/casque-lea.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/studio-radio.svg",
      "word": "un studio"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/filtre-herbes.svg",
      "word": "un filtre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le raisonnement en marquant chaque connecteur. Ajoutez un toutefois à vous."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire or, toutefois, par conséquent',
    'PO',
    $c$Objectif
Articuler à l'oral un raisonnement sur la déconnexion.

Consigne
Répétez, puis tenez un raisonnement de huit phrases, avec au moins cinq connecteurs.

Support — Modèles de Karim et d'Aline
En effet, la lampe n'est pas un maître.
Or le fil continue sans moi.
Ainsi la cour tient encore.
Toutefois, une heure ne suffit pas.
En revanche, trois soirs apprennent.
Aussi faut-il distinguer envie et besoin.
Par conséquent, débrancher n'est pas trahir.
En revanche, imposer le silence à tous serait violent.
Karim : un raisonnement a des charnières. Sans elles, ce n'est qu'une colère.
Marc : aussi + inversion, registre plus soutenu.
Léa : or ouvre un fait qui tourne, pas une insulte.
Patrick : toutefois pose une limite sans casser la thèse.
Lila : par conséquent clôt. Ne l'employez pas à chaque phrase.
Yvette : en revanche contraste deux gestes, pas deux personnes à blâmer.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Or » ouvre un fait qui tourne, d'après Léa.",
  "correct": true,
  "explanation": "Pas une insulte : un tournant."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase emploie correctement aussi au sens de « c'est pourquoi » ?",
  "options": [
    {
      "text": "Aussi on doit se taire",
      "correct": false
    },
    {
      "text": "Aussi faut-il distinguer envie et besoin",
      "correct": true
    },
    {
      "text": "Aussi le banc est là seulement",
      "correct": false
    },
    {
      "text": "Aussi débrancher trahir",
      "correct": false
    }
  ],
  "explanation": "Aussi + inversion."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en effet",
      "right": "justification"
    },
    {
      "left": "or / ainsi",
      "right": "tournant / résultat"
    },
    {
      "left": "toutefois / en revanche",
      "right": "réserve / contraste"
    },
    {
      "left": "par conséquent",
      "right": "conclusion"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ le fil continue sans moi.",
  "answer": "Or"
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
    "faut-il",
    "distinguer",
    "envie",
    "et",
    "besoin",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "raisonner",
  "hint": "Enchaîner des idées avec des charnières, sans se contenter d'une colère."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi on conclut trop vite après une heure, et Hawa refuse pourtant cette phrase trop courte.",
  "correct_sentence": "Aussi conclut-on trop vite après une heure, et Hawa refuse pourtant cette phrase trop courte.",
  "explanation": "Aussi + inversion : aussi conclut-on."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/casque-lea.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/studio-radio.svg",
      "word": "un studio"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/filtre-herbes.svg",
      "word": "un filtre"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/telephone-invente.svg",
      "word": "un appareil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez sept phrases, un connecteur différent dans chacune, sur une pause au banc."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis votre raisonnement en une minute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon raisonnement pour une pause',
    'PE',
    $c$Objectif
Écrire un texte argumenté sur la déconnexion, avec des connecteurs variés.

Consigne
Imitez le raisonnement de Hawa, sans aller trop vite.

Support — Raisonnement de Hawa, banc sans fil
Hawa — Seuil des Sources
On accuse trop vite la Lampe-Figue. En effet, une main l'allume, une main peut l'éteindre.
Je veux une heure hors du fil. Or le relais continue sans moi. Ainsi je découvre que la cour tient encore : Sami, Rose, le figuier, le banc.
Toutefois, une heure ne suffit pas si je reviens plus fébrile. En revanche, trois soirs m'apprennent un geste, la main vers l'interrupteur.
Aussi faut-il distinguer envie et besoin. Je peux désirer le casque de Léa et n'en avoir pas besoin.
Par conséquent, débrancher n'est pas trahir Lila, ni Dieudonné, ni la cour. C'est vérifier qu'un lien existe encore hors du fil.
En revanche, je n'imposerai pas cette pause à tous. Ce serait une autre violence, et le milieu qu'Aline défend n'y survivrait pas.
Solange peut dater une pause collective. Elle ne datera pas mon âme. Or c'est déjà beaucoup.
Rose : en effet, la housse sert à cacher la lumière, pas à casser l'outil. Je m'y range.
Félicie : Léa a posé le casque. Or son visage est revenu. Par conséquent, le banc a gagné une heure.
Je pose ceci sous l'arbre. Je n'en ferai pas une alerte.
Hawa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa veut imposer sa pause à toute la cour.",
  "correct": false,
  "explanation": "« je n'imposerai pas cette pause à tous. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que permet, selon Hawa, le fait que le relais continue sans elle ?",
  "options": [
    {
      "text": "De punir Lila",
      "correct": false
    },
    {
      "text": "De découvrir que la cour tient encore",
      "correct": true
    },
    {
      "text": "De vendre la lampe",
      "correct": false
    },
    {
      "text": "De fermer le Bureau",
      "correct": false
    }
  ],
  "explanation": "La cour tient encore."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en effet",
      "right": "une main allume / éteint"
    },
    {
      "left": "or / ainsi",
      "right": "le relais continue / la cour tient"
    },
    {
      "left": "aussi faut-il",
      "right": "envie ≠ besoin"
    },
    {
      "left": "par conséquent",
      "right": "débrancher n'est pas trahir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ faut-il distinguer envie et besoin.",
  "answer": "Aussi"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Débrancher",
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
  "word": "interrupteur",
  "hint": "Geste prévu par Dieudonné : arrêter la lampe sans la casser."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi on doit distinguer envie et besoin, et trois soirs suffisent parfois à apprendre la main.",
  "correct_sentence": "Aussi faut-il distinguer envie et besoin, et trois soirs suffisent parfois à apprendre la main.",
  "explanation": "Aussi + inversion : aussi faut-il."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/studio-radio.svg",
      "word": "un studio"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/filtre-herbes.svg",
      "word": "un filtre"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/telephone-invente.svg",
      "word": "un appareil"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/main-ecran.svg",
      "word": "un écran"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : treize à seize lignes, au moins six connecteurs, une thèse, une réserve, une conclusion."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre raisonnement, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Connecteurs du raisonnement',
    'EL',
    $c$Objectif
Retenir en effet, or, aussi, ainsi, toutefois, par conséquent, en revanche.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, connecteurs
en effet : on justifie, on donne une preuve. En effet, une main allume.
or : on introduit un fait qui tourne le raisonnement. Or le fil continue sans moi.
aussi (conséquence soutenue) + inversion : Aussi faut-il… Aussi resterai-je…
ainsi : résultat ou manière. Ainsi la cour tient encore.
toutefois : réserve, limite. Toutefois, une heure ne suffit pas.
par conséquent : conclusion logique. Par conséquent, débrancher n'est pas trahir.
en revanche : contraste de deux gestes ou de deux effets (pas une insulte).
Ne pas employer aussi au sens de « c'est pourquoi » sans inversion.
Ne pas coller toutefois et par conséquent dans la même phrase sans besoin.
Un raisonnement : thèse → preuve → tournant → réserve → conclusion.
Déconnexion : vérifier un lien hors du fil, non punir, non imposer à tous.
Alerte ≠ raisonnement. Colère ≠ charnière.
Bien que + subj. : bien que ce soit difficile, on peut éteindre.
À + le = au banc ; de + le = du fil.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Aussi faut-il » emploie une inversion.",
  "correct": true,
  "explanation": "Aussi + verbe + sujet."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel connecteur ouvre surtout un fait qui tourne ?",
  "options": [
    {
      "text": "en effet seulement",
      "correct": false
    },
    {
      "text": "or",
      "correct": true
    },
    {
      "text": "im- devant p",
      "correct": false
    },
    {
      "text": "depuis que",
      "correct": false
    }
  ],
  "explanation": "Or = tournant."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en effet",
      "right": "preuve"
    },
    {
      "left": "or",
      "right": "tournant"
    },
    {
      "left": "toutefois",
      "right": "réserve"
    },
    {
      "left": "par conséquent",
      "right": "conclusion"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ le fil continue sans moi.",
  "answer": "Or"
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
    "une",
    "main",
    "peut",
    "l'éteindre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "contraste",
  "hint": "Rapport en revanche : deux gestes, deux effets, sans blâme de personne."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi on conclut trop vite, et le banc attend encore qu'on distingue envie et besoin.",
  "correct_sentence": "Aussi conclut-on trop vite, et le banc attend encore qu'on distingue envie et besoin.",
  "explanation": "Aussi + inversion : aussi conclut-on."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/filtre-herbes.svg",
      "word": "un filtre"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/telephone-invente.svg",
      "word": "un appareil"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/main-ecran.svg",
      "word": "un écran"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/banc-sans-fil.svg",
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
  "prompt": "Rédigez un mini-raisonnement de dix phrases, un connecteur de la fiche par phrase."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et sept phrases, un connecteur chacune."
}$j$::jsonb,
    9
  );

  -- ===== Charte numérique de Radio Figuier =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Charte numérique de Radio Figuier'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Charte numérique de Radio Figuier', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Des articles pour le fil',
    'CO',
    $c$Objectif
Suivre la rédaction d'une charte : devoirs, droits, pauses, ton posé.

Consigne
Lisez le dialogue. Quels articles tiennent, lesquels se discutent ?

Support — Studio de Radio Figuier, feuille de charte
Lila : Une charte n'est pas une alerte. C'est un texte que l'on relit, et auquel on peut dire toutefois.
Aline : Article possible : on allume pour une voix, pas pour une rumeur. En effet, le fil n'est pas un marché.
Léa : Faut-il écrire le droit de débrancher ? Oui. Peut-on l'écrire sans en faire une gloire ? Oui aussi.
Patrick : Depuis que le fil existe, on manque d'un texte commun. Or un texte trop long ne se relit pas.
Marc : Aussi faut-il des phrases courtes. Ainsi chacun pourra les tenir.
Hawa : Parce que la méfiance grandit, on écrira : relire avant de renvoyer. Si bien que moins de rumeurs partiront brutes.
Joël : En revanche, interdire le casque serait imprudent. Léa doit pouvoir l'enlever, non le voir saisi.
Rose : Le Filtre des Herbes restera imparfait. On le dira. Imparfait n'est pas inutile.
Solange : Le Bureau date la charte. Il ne la possède pas. Toutefois, une date aide à revenir.
Karim : Par conséquent, chaque article dira un geste, une limite, une cause.
Dieudonné : J'ajoute : l'interrupteur reste accessible. Déconnecter n'est pas irresponsable.
Sami : Trois frappes avant une alerte. C'est mon article, si l'on veut.
Yvette : On n'y obéira pas comme à une mode. On s'y référera comme à un banc.
Félicie : Ce que je retiens, c'est le droit de lever les yeux. C'est déjà une charte.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël veut interdire le casque dans la charte.",
  "correct": false,
  "explanation": "Interdire le casque serait imprudent."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que date Solange, d'après le dialogue ?",
  "options": [
    {
      "text": "Les âmes",
      "correct": false
    },
    {
      "text": "La charte, sans la posséder",
      "correct": true
    },
    {
      "text": "Les rumeurs seulement",
      "correct": false
    },
    {
      "text": "Le marché des lampions",
      "correct": false
    }
  ],
  "explanation": "Elle date, elle ne possède pas."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "charte ≠ alerte",
      "right": "texte à relire"
    },
    {
      "left": "droit de débrancher",
      "right": "Léa / Dieudonné"
    },
    {
      "left": "relire avant de renvoyer",
      "right": "moins de rumeurs"
    },
    {
      "left": "interrupteur accessible",
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
  "prompt": "Complétez :\nUne charte n'est pas une ___.",
  "answer": "alerte"
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
    "allume",
    "pour",
    "une",
    "voix",
    "pas",
    "pour",
    "une",
    "rumeur",
    "."
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
  "hint": "Texte commun de devoirs et de droits, à relire, non à brandir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voici la charte que je pense depuis jeudi, et Lila en relira les articles demain à l'antenne.",
  "correct_sentence": "Voici la charte à laquelle je pense depuis jeudi, et Lila en relira les articles demain à l'antenne.",
  "explanation": "Penser à → à laquelle."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/telephone-invente.svg",
      "word": "un appareil"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/main-ecran.svg",
      "word": "un écran"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/banc-sans-fil.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/oreille-silence.svg",
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
  "prompt": "Notez six articles possibles et une réserve (toutefois / en revanche)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On allume pour une voix. Faut-il le droit de débrancher ? Relire avant de renvoyer. L'interrupteur reste accessible."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Premier jet de la charte',
    'CE',
    $c$Objectif
Lire une charte numérique inventée, argumentée et mesurée.

Consigne
Lisez la charte, sans aller trop vite.

Support — Charte du fil, Radio Figuier
Charte du fil — Radio Figuier, Seuil des Sources (premier jet)
Depuis que le fil relie trois cours, il nous faut un texte commun. Or un texte trop long ne se relit pas. Aussi les articles seront-ils courts.
1. On allume pour une voix, pas pour une rumeur. En effet, le fil n'est pas un marché.
2. On relit avant de renvoyer. Parce qu'une trace est incomplète, reconstruire trop vite reste un risque.
3. Le Filtre des Herbes reste imparfait. Imparfait n'est pas inutile. On ne prétendra pas l'inverse.
4. Faut-il un droit de débrancher ? Oui. Déconnecter n'est pas irresponsable. L'interrupteur reste accessible.
5. Toutefois, une pause n'est pas une gloire. En revanche, l'imposer à tous serait une autre violence.
6. Peut-on porter un casque ? Oui. Doit-on pouvoir le poser ? Oui. Le visage d'en face compte.
7. Aussi faut-il distinguer envie et besoin. Ainsi l'on évitera de tout mesurer.
8. Radio Figuier relayera la voix, pas le compte, pas l'alerte pour l'alerte.
9. Le Bureau date. Il ne possède pas. Solange n'est pas maîtresse des âmes.
10. On s'y référera comme à un banc. On n'y obéira pas comme à une mode.
Par conséquent, nous relirons cette charte chaque saison. Ce qui nous lie, c'est une phrase juste.
Rukiri-Nord — à corriger ensemble, sans faste.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'article 5 refuse de transformer la pause en gloire et refuse aussi de l'imposer à tous.",
  "correct": true,
  "explanation": "Toutefois… En revanche…"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que relayera Radio Figuier, selon l'article 8 ?",
  "options": [
    {
      "text": "Le compte et l'alerte pour l'alerte",
      "correct": false
    },
    {
      "text": "La voix, pas le compte, pas l'alerte pour l'alerte",
      "correct": true
    },
    {
      "text": "Les rumeurs brutes",
      "correct": false
    },
    {
      "text": "Le marché seulement",
      "correct": false
    }
  ],
  "explanation": "La voix, rien que la voix utile."
}$j$::jsonb,
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
      "right": "voix, pas rumeur"
    },
    {
      "left": "article 4",
      "right": "droit de débrancher"
    },
    {
      "left": "article 5",
      "right": "toutefois / en revanche"
    },
    {
      "left": "article 10",
      "right": "banc, pas mode"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn n'___ obéira pas comme à une mode.",
  "answer": "y"
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
    "relit",
    "avant",
    "de",
    "renvoyer",
    "."
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
  "hint": "Ce qu'un article exige : relire, dater, ne pas renvoyer trop vite."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi les articles seront courts demain, et Lila pourra les tenir à l'antenne sans les brandir.",
  "correct_sentence": "Aussi les articles seront-ils courts demain, et Lila pourra les tenir à l'antenne sans les brandir.",
  "explanation": "Aussi + inversion : seront-ils."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/main-ecran.svg",
      "word": "un écran"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/banc-sans-fil.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/oreille-silence.svg",
      "word": "une oreille"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/feuille-charte.svg",
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
  "prompt": "Recopiez cinq articles et ajoutez le vôtre, avec une cause ou une réserve."
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
Formuler à l'oral des articles courts : droit, devoir, réserve.

Consigne
Répétez, puis dictez trois articles et un toutefois.

Support — Modèles de Lila et de Solange
On allume pour une voix, pas pour une rumeur.
On relit avant de renvoyer.
L'interrupteur reste accessible.
Déconnecter n'est pas irresponsable.
Toutefois, une pause n'est pas une gloire.
En revanche, l'imposer à tous serait violent.
Aussi faut-il distinguer envie et besoin.
On n'y obéira pas comme à une mode.
Lila : un article tient en une respiration.
Aline : une charte ose le toutefois, sinon elle ment.
Marc : aussi + inversion, si l'on conclut.
Léa : faut-il / peut-on : le doute a sa place dans un article.
Patrick : depuis que le fil existe, ce texte manquait.
Yvette : finissez par le geste, pas par la menace.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline dit qu'une charte sans toutefois risque de mentir.",
  "correct": true,
  "explanation": "Elle ose le toutefois, sinon elle ment."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase pose un droit, non une gloire ?",
  "options": [
    {
      "text": "Une pause est une gloire",
      "correct": false
    },
    {
      "text": "L'interrupteur reste accessible",
      "correct": true
    },
    {
      "text": "On doit rester casqué",
      "correct": false
    },
    {
      "text": "Le Bureau possède les âmes",
      "correct": false
    }
  ],
  "explanation": "L'accès à l'interrupteur = droit."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on allume pour une voix",
      "right": "devoir"
    },
    {
      "left": "interrupteur accessible",
      "right": "droit"
    },
    {
      "left": "toutefois",
      "right": "réserve"
    },
    {
      "left": "on n'y obéira pas",
      "right": "refus de la mode"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDéconnecter n'est pas ___.",
  "answer": "irresponsable"
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
    "n'y",
    "obéira",
    "pas",
    "comme",
    "à",
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
  "word": "article",
  "hint": "Phrase courte d'une charte : un geste, une limite, parfois une cause."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi on écrira des phrases trop longues, et personne ne relira la charte sous le figuier.",
  "correct_sentence": "Aussi écrira-t-on des phrases trop longues, et personne ne relira la charte sous le figuier.",
  "explanation": "Aussi + inversion : aussi écrira-t-on."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/banc-sans-fil.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/oreille-silence.svg",
      "word": "une oreille"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/feuille-charte.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/nuage-alerte.svg",
      "word": "une alerte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit articles oraux : quatre devoirs, deux droits, un toutefois, un en revanche."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis trois articles à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma charte du fil',
    'PE',
    $c$Objectif
Écrire une charte numérique argumentée pour Radio Figuier.

Consigne
Imitez la charte de Lila Sow, sans aller trop vite.

Support — Charte de Lila, encre du studio
Lila Sow — Radio Figuier, Seuil des Sources
Depuis que le fil relie trois cours, il nous faut un texte commun. Or un texte trop long ne se relit pas. Aussi les articles seront-ils courts.
J'écris ceci, non une alerte.
1. On allume pour une voix, pas pour une rumeur. En effet, le fil n'est pas un marché.
2. On relit avant de renvoyer, parce qu'une trace est incomplète, si bien que reconstruire trop vite trompe.
3. Le Filtre des Herbes reste imparfait. On le dira. Imparfait n'est pas inutile.
4. Faut-il un droit de débrancher ? Oui. L'interrupteur reste accessible. Déconnecter n'est pas irresponsable.
5. Toutefois, une pause n'est pas une gloire. En revanche, l'imposer à tous serait une autre violence.
6. Peut-on porter un casque ? Oui. Doit-on pouvoir lever les yeux ? Oui. Le visage d'en face compte.
7. Aussi faut-il distinguer envie et besoin. Ainsi l'on évitera de tout mesurer.
8. Je relayerai la voix, pas le compte. Solange datera, sans posséder.
On s'y référera comme à un banc. On n'y obéira pas comme à une mode.
Par conséquent, nous relirons ces lignes chaque saison. Que la cour corrige.
Lila
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila présente sa charte comme une alerte à brandir.",
  "correct": false,
  "explanation": "« J'écris ceci, non une alerte. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que datera Solange, dans la charte de Lila ?",
  "options": [
    {
      "text": "Les âmes",
      "correct": false
    },
    {
      "text": "Le texte, sans posséder",
      "correct": true
    },
    {
      "text": "Les rumeurs seulement",
      "correct": false
    },
    {
      "text": "Le casque de Léa",
      "correct": false
    }
  ],
  "explanation": "Dater sans posséder."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "voix, pas rumeur",
      "right": "article 1"
    },
    {
      "left": "droit de débrancher",
      "right": "article 4"
    },
    {
      "left": "toutefois / en revanche",
      "right": "article 5"
    },
    {
      "left": "banc, pas mode",
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
  "prompt": "Complétez :\nAussi les articles seront-___ courts.",
  "answer": "ils"
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
    "allume",
    "pour",
    "une",
    "voix",
    "pas",
    "pour",
    "une",
    "rumeur",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "accessible",
  "hint": "Qualité de l'interrupteur : on peut l'atteindre, on n'a pas à le mériter."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi les articles seront courts cette saison, et la cour pourra les relire sans les brandir.",
  "correct_sentence": "Aussi les articles seront-ils courts cette saison, et la cour pourra les relire sans les brandir.",
  "explanation": "Aussi + inversion : seront-ils."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/oreille-silence.svg",
      "word": "une oreille"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/feuille-charte.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/nuage-alerte.svg",
      "word": "une alerte"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/soleil-pause.svg",
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
  "prompt": "Imitez : quatorze à dix-huit lignes, au moins six articles, un toutefois, un par conséquent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre charte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Tenir une charte',
    'EL',
    $c$Objectif
Retenir la forme d'une charte : articles courts, droits, devoirs, connecteurs.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, charte
Charte = texte commun, relisible. Pas une alerte. Pas une mode.
Articles courts : un geste, une limite, parfois une cause.
Droits : débrancher, poser le casque, lever les yeux. L'interrupteur reste accessible.
Devoirs : allumer pour une voix ; relire avant de renvoyer ; ne pas prétendre que le Filtre est parfait.
Réserves : toutefois (la pause n'est pas une gloire) ; en revanche (ne pas imposer à tous).
Outils du module à réemployer :
inversion : Faut-il… ? Peut-on… ? Aussi les articles seront-ils…
préfixes : imparfait, irresponsable, déconnecter, méfiance
durée : depuis que le fil existe
re- / cause : relire, parce que la trace est incomplète
connecteurs : en effet, or, ainsi, par conséquent
On s'y réfère comme à un banc. On n'y obéit pas comme à une mode.
Le Bureau date. Il ne possède pas.
Bien que + subj. : bien que ce soit incomplet, nous signons.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Une charte, d'après la fiche, peut se passer de réserve.",
  "correct": false,
  "explanation": "Sans toutefois, elle risque de mentir."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série décrit le mieux un article ?",
  "options": [
    {
      "text": "Une alerte longue et une couronne",
      "correct": false
    },
    {
      "text": "Un geste, une limite, parfois une cause",
      "correct": true
    },
    {
      "text": "Un graphique seulement",
      "correct": false
    },
    {
      "text": "Un tampon d'âme",
      "correct": false
    }
  ],
  "explanation": "Geste + limite + cause possible."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "droit",
      "right": "débrancher / lever les yeux"
    },
    {
      "left": "devoir",
      "right": "relire avant de renvoyer"
    },
    {
      "left": "toutefois",
      "right": "pause ≠ gloire"
    },
    {
      "left": "banc ≠ mode",
      "right": "se référer / ne pas obéir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn s'___ référera comme à un banc.",
  "answer": "y"
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
    "charte",
    "n'est",
    "pas",
    "une",
    "alerte",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "relisible",
  "hint": "Qualité d'un texte court : on peut y revenir chaque saison."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voici le texte que je réfère trop vite, et Lila refuse d'en faire une mode.",
  "correct_sentence": "Voici le texte auquel je me réfère trop vite, et Lila refuse d'en faire une mode.",
  "explanation": "Se référer à → auquel."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/feuille-charte.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/nuage-alerte.svg",
      "word": "une alerte"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/soleil-pause.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/groupe-debat.svg",
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
  "prompt": "Plan de charte : quatre devoirs, trois droits, deux réserves, une conclusion."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et cinq articles, voix posée."
}$j$::jsonb,
    9
  );

  -- ===== Débat « Lampe-Figue et le fil » =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Débat « Lampe-Figue et le fil »'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Débat « Lampe-Figue et le fil »', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La lampe n''est pas le maître',
    'CO',
    $c$Objectif
Suivre un débat argumenté : thèses, concessions, conclusions, sans slogan.

Consigne
Lisez le débat. Qui défend quoi, et quelles charnières tiennent ?

Support — Salle des Herbes, groupe autour de la lampe
Aline : Nous débattons. Nous ne votons pas une couronne. Faut-il garder la Lampe-Figue telle quelle ? Peut-on vivre avec le fil sans s'y soumettre ?
Dieudonné : J'ai construit l'outil. En effet, je l'assume. Or je n'ai pas construit l'obéissance. Aussi faut-il garder l'interrupteur visible.
Léa : Depuis que je porte le casque, je perds des visages. Toutefois, j'entends Aline loin du banc. En revanche, trois soirs sans fil m'ont rendu le regard.
Patrick : Parce que Léa disparaissait une heure, j'ai trop accusé la lampe, si bien que j'ai oublié la main qui l'allume. Je corrige.
Marc : Une thèse n'est pas une insulte. « La lampe est utile » et « la lampe n'est pas un maître » peuvent rester ensemble.
Hawa : Par conséquent, je défends la charte. Débrancher n'est pas irresponsable. Imposer le silence à tous le serait.
Joël : En revanche, vanter la déconnexion comme une gloire vide le débat. C'est une autre affiche.
Rose : Le Filtre des Herbes reste imparfait. On peut s'y fier un peu, jamais tout à fait.
Solange : Le Bureau date le débat. Il ne le tranche pas.
Karim : Ainsi, le milieu tient : assez de fil pour relier, assez de banc pour se voir.
Lila : Je relayerai les deux bords. Je ne choisirai pas un camp pour faire du bruit.
Sami : Trois frappes. Ensuite, on parle. Pas l'inverse.
Yvette : Le mieux, c'est une phrase que l'enfant du Seuil comprendra : la lampe sert, elle ne commande pas.
Félicie : Or le visage est revenu. Par conséquent, le débat a déjà servi.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné dit avoir construit l'obéissance en même temps que la lampe.",
  "correct": false,
  "explanation": "« je n'ai pas construit l'obéissance. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que relayera Lila, d'après le débat ?",
  "options": [
    {
      "text": "Un seul camp, pour faire du bruit",
      "correct": false
    },
    {
      "text": "Les deux bords",
      "correct": true
    },
    {
      "text": "Le marché seulement",
      "correct": false
    },
    {
      "text": "Une couronne",
      "correct": false
    }
  ],
  "explanation": "Les deux bords, pas un camp."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "faut-il / peut-on",
      "right": "questions du débat"
    },
    {
      "left": "or / aussi faut-il",
      "right": "tournant / conclusion soutenue"
    },
    {
      "left": "toutefois / en revanche",
      "right": "casque utile / regard rendu"
    },
    {
      "left": "la lampe sert",
      "right": "elle ne commande pas"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa lampe sert, elle ne ___ pas.",
  "answer": "commande"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Débrancher",
    "n'est",
    "pas",
    "irresponsable",
    "."
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
  "hint": "Échange de thèses et de réserves, sans couronne ni camp de bruit. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi on garde l'interrupteur visible, et Dieudonné refuse que l'outil devienne un maître.",
  "correct_sentence": "Aussi garde-t-on l'interrupteur visible, et Dieudonné refuse que l'outil devienne un maître.",
  "explanation": "Aussi + inversion : aussi garde-t-on."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/nuage-alerte.svg",
      "word": "une alerte"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/soleil-pause.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/groupe-debat.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/micro-lila.svg",
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
  "prompt": "Notez trois thèses, deux concessions et la phrase de milieu (Karim ou Yvette)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Faut-il garder la lampe ? Peut-on vivre avec le fil sans s'y soumettre ? La lampe sert, elle ne commande pas."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Compte rendu du débat',
    'CE',
    $c$Objectif
Lire le compte rendu argumenté du débat « Lampe-Figue et le fil ».

Consigne
Lisez le compte rendu, sans aller trop vite.

Support — Compte rendu d'Aline, Salle des Herbes
Compte rendu — Débat « Lampe-Figue et le fil »
On a débattu sans couronne. Faut-il garder l'outil ? Peut-on vivre avec le fil sans s'y soumettre ? Les deux questions sont restées ouvertes, et c'est tant mieux.
Dieudonné a assumé la construction. En effet, un outil a un auteur. Or il n'a pas construit l'obéissance. Aussi l'interrupteur restera-t-il visible.
Léa a tenu les deux bords : depuis que le casque existe, des visages se perdent ; toutefois, une voix lointaine s'entend ; en revanche, trois soirs sans fil lui ont rendu le regard.
Patrick a corrigé une cause : parce qu'il accusait trop la lampe, il oubliait la main, si bien que le débat devenait une insulte. Il a retiré l'insulte.
Hawa a conclu : par conséquent, la charte tient. Débrancher n'est pas irresponsable. Imposer le silence à tous le serait.
Joël a prévenu : vanter la pause comme une gloire vide le débat. Rose a rappelé que le Filtre reste imparfait. Solange a daté, sans trancher.
Karim : assez de fil pour relier, assez de banc pour se voir. Yvette : la lampe sert, elle ne commande pas.
Lila relayera les deux bords. Sami a ouvert et fermé par trois frappes.
Ainsi le milieu a tenu. Un débat qui choisit un camp trop tôt n'est plus un débat, c'est une alerte.
Félicie : or le visage est revenu. Par conséquent, le débat a déjà servi.
Marc : « la lampe est utile » et « la lampe n'est pas un maître » peuvent rester ensemble.
Rukiri-Nord — à relire avant la prochaine assemblée.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le compte rendu dit que les deux questions sont restées ouvertes.",
  "correct": true,
  "explanation": "« Les deux questions sont restées ouvertes, et c'est tant mieux. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que restera-t-il visible, selon Dieudonné repris par Aline ?",
  "options": [
    {
      "text": "Une couronne",
      "correct": false
    },
    {
      "text": "L'interrupteur",
      "correct": true
    },
    {
      "text": "Le casque obligatoire",
      "correct": false
    },
    {
      "text": "Le marché",
      "correct": false
    }
  ],
  "explanation": "L'interrupteur restera visible."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "deux questions ouvertes",
      "right": "tant mieux"
    },
    {
      "left": "interrupteur visible",
      "right": "Dieudonné"
    },
    {
      "left": "deux bords de Léa",
      "right": "voix lointaine / regard"
    },
    {
      "left": "milieu de Karim",
      "right": "fil + banc"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa lampe sert, elle ne ___ pas.",
  "answer": "commande"
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
    "deux",
    "questions",
    "sont",
    "restées",
    "ouvertes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "compte",
  "hint": "Texte qui dit ce qui s'est tenu dans un débat, sans y ajouter une couronne."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi l'interrupteur restera visible demain, et la cour pourra encore débattre sans se soumettre.",
  "correct_sentence": "Aussi l'interrupteur restera-t-il visible demain, et la cour pourra encore débattre sans se soumettre.",
  "explanation": "Aussi + inversion : restera-t-il."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/soleil-pause.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/groupe-debat.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/micro-lila.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/porte-fermee.svg",
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
  "prompt": "Recopiez le milieu du débat (Karim / Yvette) et deux concessions. Ajoutez la vôtre."
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
    'PO — Dire sa thèse, tenir le milieu',
    'PO',
    $c$Objectif
Débattre à l'oral : thèse, concession, conclusion, sans camp de bruit.

Consigne
Répétez, puis tenez deux minutes : Lampe-Figue et le fil, pour, contre, milieu.

Support — Modèles d'Aline et de Karim
Faut-il garder la lampe ? Oui, avec un interrupteur visible.
Peut-on vivre avec le fil sans s'y soumettre ? Oui, si l'on ose débrancher.
En effet, l'outil a un auteur. Or il n'a pas d'obéissance.
Toutefois, le casque fait perdre des visages.
En revanche, une voix lointaine s'entend.
Par conséquent, la charte tient.
Ainsi le milieu tient : assez de fil, assez de banc.
La lampe sert, elle ne commande pas.
Aline : une thèse n'est pas une insulte.
Marc : deux phrases peuvent rester ensemble.
Léa : je tiens les deux bords, ou je mens.
Joël : une gloire de pause vide le débat.
Lila : je relayerai les deux bords.
Yvette : une phrase d'enfant clôt mieux qu'un slogan.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa dit qu'elle ment si elle ne tient qu'un bord.",
  "correct": true,
  "explanation": "« je tiens les deux bords, ou je mens. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase dit le milieu ?",
  "options": [
    {
      "text": "Il faut tout éteindre pour toujours",
      "correct": false
    },
    {
      "text": "Assez de fil, assez de banc",
      "correct": true
    },
    {
      "text": "Le Bureau tranche les âmes",
      "correct": false
    },
    {
      "text": "Une couronne pour Dieudonné",
      "correct": false
    }
  ],
  "explanation": "Karim : assez de fil, assez de banc."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "faut-il / peut-on",
      "right": "questions"
    },
    {
      "left": "or / toutefois",
      "right": "tournant / réserve"
    },
    {
      "left": "par conséquent",
      "right": "la charte tient"
    },
    {
      "left": "milieu",
      "right": "fil + banc"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa lampe sert, elle ne ___ pas.",
  "answer": "commande"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Assez",
    "de",
    "fil",
    "assez",
    "de",
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
  "word": "milieu",
  "hint": "Place du débat : assez de lien, assez de visage, sans camp de bruit."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi on tient le milieu demain, et Lila relayera les deux bords sans en faire une alerte.",
  "correct_sentence": "Aussi tiendra-t-on le milieu demain, et Lila relayera les deux bords sans en faire une alerte.",
  "explanation": "Aussi + inversion : aussi tiendra-t-on."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/groupe-debat.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/micro-lila.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/porte-fermee.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/actu-tech.svg",
      "word": "une actualité"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un débat en dix répliques : deux questions, deux thèses, deux toutefois, deux conclusions, un milieu."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis votre prise de position en une minute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma prise de position',
    'PE',
    $c$Objectif
Écrire une prise de position argumentée pour le débat « Lampe-Figue et le fil ».

Consigne
Imitez la prise de position de Dieudonné, sans aller trop vite.

Support — Prise de position de Dieudonné, atelier
Dieudonné — Seuil des Sources
Faut-il garder la Lampe-Figue ? Oui. Peut-on vivre avec le fil sans s'y soumettre ? Oui, et c'est la seule question qui me tient.
J'ai construit l'outil. En effet, je l'assume. Or je n'ai pas construit l'obéissance. Aussi l'interrupteur restera-t-il visible, accessible, sans gloire.
Depuis que trois cours s'entendent, une voix lointaine est un bien. Toutefois, un casque trop longtemps porté fait perdre un visage. En revanche, trois soirs sans fil rendent le regard.
Parce que l'on m'a parfois traité en maître, j'ai trop tardé à dire ceci, si bien que le débat glissait vers une affiche. Je corrige.
Déconnecter n'est pas irresponsable. Imposer le silence à tous le serait. Vanter la pause comme une gloire le serait aussi.
Par conséquent, je signe la charte de Lila, avec ses toutefois. Ainsi le milieu tient : assez de fil pour relier, assez de banc pour se voir.
La lampe sert. Elle ne commande pas. Si un enfant du Seuil peut le répéter, le débat a servi.
Karim a dit le milieu mieux que moi : assez de fil pour relier, assez de banc pour se voir.
Lila relayera les deux bords. Je n'ai pas besoin d'un camp pour exister.
Que Solange date. Qu'elle ne tranche pas. Que Sami frappe, puis que l'on parle.
Dieudonné
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné refuse de signer la charte de Lila.",
  "correct": false,
  "explanation": "« je signe la charte de Lila, avec ses toutefois. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle est, pour Dieudonné, la seule question qui le tient ?",
  "options": [
    {
      "text": "Faut-il vendre la lampe ?",
      "correct": false
    },
    {
      "text": "Peut-on vivre avec le fil sans s'y soumettre ?",
      "correct": true
    },
    {
      "text": "Faut-il fermer le figuier ?",
      "correct": false
    },
    {
      "text": "Doit-on interdire le tambour ?",
      "correct": false
    }
  ],
  "explanation": "Vivre avec le fil sans s'y soumettre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "j'assume l'outil",
      "right": "pas l'obéissance"
    },
    {
      "left": "toutefois / en revanche",
      "right": "voix / visage"
    },
    {
      "left": "par conséquent",
      "right": "je signe la charte"
    },
    {
      "left": "milieu",
      "right": "fil + banc"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAussi l'interrupteur restera-___ visible.",
  "answer": "t-il"
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
    "lampe",
    "sert",
    "elle",
    "ne",
    "commande",
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
  "word": "obeissance",
  "hint": "Ce que Dieudonné n'a pas construit, et qu'il refuse à l'outil. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aussi l'interrupteur restera visible ce soir, et la cour pourra encore débattre sans se soumettre.",
  "correct_sentence": "Aussi l'interrupteur restera-t-il visible ce soir, et la cour pourra encore débattre sans se soumettre.",
  "explanation": "Aussi + inversion : restera-t-il."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/micro-lila.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/porte-fermee.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/actu-tech.svg",
      "word": "une actualité"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/inversion-question.svg",
      "word": "une inversion"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : quatorze à dix-huit lignes, deux questions, six connecteurs, un milieu, une phrase d'enfant."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre prise de position, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Tenir un débat B2',
    'EL',
    $c$Objectif
Retenir la charpente d'un débat : questions, thèses, concessions, milieu, conclusion.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, débat
Débat = questions ouvertes + thèses + concessions + milieu. Pas une couronne. Pas une alerte.
Ouvrir : Faut-il… ? Peut-on… ? Doit-on… ?
Tenir deux phrases ensemble : utile / pas maître ; relier / se voir ; voix / visage.
Connecteurs : en effet, or, aussi + inversion, ainsi, toutefois, par conséquent, en revanche.
Durée : depuis que, ça fait… que, en trois soirs.
Cause / conséquence : parce que, puisque, si bien que, de sorte que.
Préfixes : imparfait, irresponsable, déconnecter, méfiance.
re- : relire, retracer, reconstruire — sans refaire à l'envers.
Charte : articles courts, droit de débrancher, relire avant de renvoyer.
Milieu utile au Seuil : assez de fil pour relier, assez de banc pour se voir.
Phrase de clôture : la lampe sert, elle ne commande pas.
Lila relayera les deux bords. Solange date, elle ne tranche pas. Sami frappe, puis l'on parle.
Bien que + subj. : bien que l'on ne soit pas d'accord, le débat tient.
Éviter : plus bon, inpossible, aussi on doit, le texte que je pense, parce que pour un résultat.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Un débat, d'après la fiche, doit choisir un camp dès l'ouverture.",
  "correct": false,
  "explanation": "Questions ouvertes. Un camp trop tôt = une alerte."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase clôt le mieux, selon la fiche ?",
  "options": [
    {
      "text": "La lampe commande, elle ne sert pas",
      "correct": false
    },
    {
      "text": "La lampe sert, elle ne commande pas",
      "correct": true
    },
    {
      "text": "Le Bureau tranche les âmes",
      "correct": false
    },
    {
      "text": "Une couronne pour le fil",
      "correct": false
    }
  ],
  "explanation": "Sert / ne commande pas."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "faut-il / peut-on",
      "right": "ouverture"
    },
    {
      "left": "toutefois / en revanche",
      "right": "concession"
    },
    {
      "left": "par conséquent",
      "right": "conclusion"
    },
    {
      "left": "fil + banc",
      "right": "milieu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAssez de fil pour relier, assez de ___ pour se voir.",
  "answer": "banc"
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
    "lampe",
    "sert",
    "elle",
    "ne",
    "commande",
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
  "word": "position",
  "hint": "Texte où l'on dit sa thèse, sa réserve et son milieu, sans slogan."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voici le débat que je pense encore ce soir, et Aline en relira le compte rendu demain sous l'arbre.",
  "correct_sentence": "Voici le débat auquel je pense encore ce soir, et Aline en relira le compte rendu demain sous l'arbre.",
  "explanation": "Penser à → auquel."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m4/porte-fermee.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/actu-tech.svg",
      "word": "une actualité"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/inversion-question.svg",
      "word": "une inversion"
    },
    {
      "image_path": "/elearning/mfk-b2-m4/prefixe-negatif.svg",
      "word": "un préfixe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Plan de débat : deux questions, deux thèses, deux concessions, un milieu, une phrase de clôture."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et la phrase : la lampe sert, elle ne commande pas."
}$j$::jsonb,
    9
  );

END;
$$;
