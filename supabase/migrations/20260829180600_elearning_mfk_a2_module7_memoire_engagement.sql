/*
  Seed eLearning MFK — A2 — Mémoire et engagement

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a2-m7/
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
  v_module_title text := 'A2 — Mémoire et engagement';
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
      'Grande étape A2-7 : comprendre un récit aux trois temps du passé, raconter un souvenir, enchaîner des faits, défendre une cause, agir pour la nature et donner son avis — autour du figuier et de la petite rivière, avec le Cahier des racines, au Seuil des Sources (Rukiri-Nord).',
      'A2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape A2-7 : comprendre un récit aux trois temps du passé, raconter un souvenir, enchaîner des faits, défendre une cause, agir pour la nature et donner son avis — autour du figuier et de la petite rivière, avec le Cahier des racines, au Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'A2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Un récit à comprendre =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un récit à comprendre'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un récit à comprendre', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Sous le figuier d''avant',
    'CO',
    $c$Objectif
Distinguer passé composé, imparfait et plus-que-parfait dans un récit.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Quel temps pour quel fait ?

Support — Banc du Seuil, photo ocre
Aline : Le figuier était déjà là. On se retrouvait chaque soir.
Patrick : Un jour, la rivière a débordé. Elle avait déjà monté deux fois.
Léa : Nous avons tiré les bancs. Joël avait préparé des seaux.
Marc : Dieudonné cousait un tissu pour protéger le tronc. Il a fini à l'aube.
Hawa : Rose chantait. Puis elle a signé la première page.
Solange : Karim avait affiché un mot. Nous l'avons lu trop tard.
Lila : Il pleuvait. Nous avons quand même tenu le Cahier des racines.
Joël : J'avais oublié mon crayon. Léa m'en a prêté un.
Yvette : La cour sentait l'herbe. On a respiré, puis on a décidé.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le figuier était déjà là : c'est un imparfait de décor.",
  "correct": true,
  "explanation": "Aline pose le décor avec l'imparfait."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel fait est antérieur à « la rivière a débordé » ?",
  "options": [
    {
      "text": "On a respiré",
      "correct": false
    },
    {
      "text": "Elle avait déjà monté deux fois",
      "correct": true
    },
    {
      "text": "Rose a signé",
      "correct": false
    },
    {
      "text": "Léa a prêté un crayon",
      "correct": false
    }
  ],
  "explanation": "Plus-que-parfait : action déjà faite avant une autre au passé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "était / se retrouvait",
      "right": "imparfait, décor ou habitude"
    },
    {
      "left": "a débordé / avons tiré",
      "right": "passé composé, fait"
    },
    {
      "left": "avait monté / avait préparé",
      "right": "plus-que-parfait"
    },
    {
      "left": "pleuvait",
      "right": "arrière-plan"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJoël ___ préparé des seaux. (avoir, PQP)",
  "answer": "avait"
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
    "rivière",
    "a",
    "débordé",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "deborde",
  "hint": "La rivière l'a fait un jour (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Un jour, la rivière débordait tout d'un coup et c'est tout.",
  "correct_sentence": "Un jour, la rivière a débordé.",
  "explanation": "Fait soudain, daté : passé composé."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/recit-temps.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/trois-temps.svg",
      "word": "trois temps"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/cahier-memoire.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/photo-ancienne.svg",
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
  "prompt": "Classez neuf verbes du dialogue : PC / imparfait / PQP."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Le figuier était déjà là. La rivière a débordé. Elle avait déjà monté."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Page du Cahier des racines',
    'CE',
    $c$Objectif
Lire un récit qui mélange les trois temps du passé.

Consigne
Lisez la page, sans aller trop vite.

Support — Cahier des racines, première feuille
Page 1 — mémoire de la cour
Le figuier donnait déjà de l'ombre. Les enfants jouaient près de l'eau.
Un soir, le niveau a monté. La terre avait déjà glissé derrière l'Atelier du Tissu.
Nous avons formé une chaîne. Hawa avait apporté des lampions du marché.
Dieudonné a tendu le tissu. Il cousait encore quand Aline a crié.
On a sauvé les jeunes plants. On n'avait jamais vu une crue si rapide.
Solange a ouvert le Bureau des Escales. Karim y avait laissé la clé.
Nous avons décidé d'écrire. Le cahier s'est appelé Cahier des racines.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On avait déjà vu une crue aussi rapide.",
  "correct": false,
  "explanation": "« On n'avait jamais vu une crue si rapide. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui avait apporté des lampions ?",
  "options": [
    {
      "text": "Marc",
      "correct": false
    },
    {
      "text": "Hawa",
      "correct": true
    },
    {
      "text": "Kévin",
      "correct": false
    },
    {
      "text": "Ibrahim",
      "correct": false
    }
  ],
  "explanation": "« Hawa avait apporté des lampions. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "donnait / jouaient",
      "right": "imparfait"
    },
    {
      "left": "a monté / avons formé",
      "right": "passé composé"
    },
    {
      "left": "avait glissé / avait apporté",
      "right": "plus-que-parfait"
    },
    {
      "left": "cousait encore",
      "right": "action en cours"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nKarim y ___ laissé la clé.",
  "answer": "avait"
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
    "décidé",
    "d'écrire",
    "."
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
  "hint": "Hawa les avait apportés du marché."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Un soir, le niveau montait tout à coup comme un fait unique.",
  "correct_sentence": "Un soir, le niveau a monté.",
  "explanation": "Fait unique, daté : passé composé."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/souvenir-duree.svg",
      "word": "un souvenir"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/horloge-moment.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/banc-longtemps.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/lettre-passe.svg",
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
  "prompt": "Recopiez la page et coloriez PC / imparfait / PQP de trois couleurs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la page 1 du Cahier des racines, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire les trois temps',
    'PO',
    $c$Objectif
Raconter un même souvenir en choisissant PC, imparfait ou PQP.

Consigne
Répétez, puis parlez d'un soir sous le figuier.

Support — Modèles de Marc
Il pleuvait.
Le figuier était grand.
Nous nous retrouvions souvent.
Puis l'eau a monté.
Nous avons tiré les bancs.
Joël avait préparé des seaux.
J'avais oublié mon crayon.
Léa m'en a prêté un.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'imparfait sert surtout au décor et à l'habitude.",
  "correct": true,
  "explanation": "Il pleuvait. Nous nous retrouvions."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est au plus-que-parfait ?",
  "options": [
    {
      "text": "Il pleuvait",
      "correct": false
    },
    {
      "text": "L'eau a monté",
      "correct": false
    },
    {
      "text": "Joël avait préparé des seaux",
      "correct": true
    },
    {
      "text": "Léa m'en a prêté un",
      "correct": false
    }
  ],
  "explanation": "avait + participe : PQP."
}$j$::jsonb,
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
      "right": "décor / habitude"
    },
    {
      "left": "passé composé",
      "right": "fait achevé"
    },
    {
      "left": "plus-que-parfait",
      "right": "avant un autre passé"
    },
    {
      "left": "puis",
      "right": "bascule vers le PC"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'___ oublié mon crayon.",
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
    "Il",
    "pleuvait",
    "."
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
  "hint": "L'imparfait raconte aussi une… du soir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Joël a préparé des seaux avant que l'eau monte.",
  "correct_sentence": "Joël avait préparé des seaux avant que l'eau monte.",
  "explanation": "Fait déjà accompli avant un autre passé : PQP."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/suite-faits.svg",
      "word": "une suite"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/fleches-dates.svg",
      "word": "des flèches"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/calendrier-marqueurs.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/pont-temps.svg",
      "word": "un pont"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases : deux de chaque temps."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis un souvenir à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma page de mémoire',
    'PE',
    $c$Objectif
Écrire un récit court qui utilise les trois temps du passé.

Consigne
Imitez la page de Léa.

Support — Page de Léa Niyonzima
Léa Niyonzima
La cour était calme. Le figuier donnait de l'ombre.
Un soir, l'eau a touché le banc. Elle avait déjà reculé deux fois.
Nous avons porté les jeunes plants. Patrick avait ouvert le seau.
J'ai signé le Cahier des racines. Je n'avais jamais écrit si vite.
Dieudonné cousait encore. Il avait déjà tendu le premier coupon.
Léa
Seuil des Sources — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa avait déjà souvent écrit aussi vite.",
  "correct": false,
  "explanation": "« Je n'avais jamais écrit si vite. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel temps pour « Le figuier donnait de l'ombre » ?",
  "options": [
    {
      "text": "passé composé",
      "correct": false
    },
    {
      "text": "imparfait",
      "correct": true
    },
    {
      "text": "plus-que-parfait",
      "correct": false
    },
    {
      "text": "présent",
      "correct": false
    }
  ],
  "explanation": "Imparfait de décor."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "était / donnait",
      "right": "imparfait"
    },
    {
      "left": "a touché / avons porté",
      "right": "passé composé"
    },
    {
      "left": "avait reculé / avait ouvert",
      "right": "plus-que-parfait"
    },
    {
      "left": "n'avais jamais écrit",
      "right": "PQP + jamais"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPatrick ___ ouvert le seau.",
  "answer": "avait"
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
    "cour",
    "était",
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
  "word": "racines",
  "hint": "Le cahier porte ce nom : Cahier des…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Un soir, l'eau touchait le banc tout à coup une seule fois.",
  "correct_sentence": "Un soir, l'eau a touché le banc.",
  "explanation": "Fait unique : passé composé."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/cause-consequence.svg",
      "word": "une cause"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/affiche-cause.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/main-defense.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/arbre-proteger.svg",
      "word": "un arbre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes, les trois temps au moins une fois chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre page, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — PC, imparfait, PQP',
    'EL',
    $c$Objectif
Retenir le rôle de chaque temps dans un récit.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
Imparfait : décor, habitude, action en cours. Il pleuvait. On se retrouvait.
Passé composé : fait achevé, souvent daté ou soudain. L'eau a monté. Nous avons signé.
Plus-que-parfait : déjà fait avant un autre moment du passé. Il avait préparé. J'avais oublié.
Repères : un jour / soudain / puis → souvent PC.
déjà / jamais + PQP : On n'avait jamais vu. Elle avait déjà monté.
On ne raconte pas tout à l'imparfait si les faits avancent.
Exemple Seuil : Le figuier était là. Un soir, l'eau a monté. Joël avait préparé des seaux.
Le PQP se place souvent avant un PC dans la même histoire.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le plus-que-parfait se forme avec l'imparfait de avoir / être + participe.",
  "correct": true,
  "explanation": "avait préparé, était déjà parti."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Un jour » entraîne souvent…",
  "options": [
    {
      "text": "l'imparfait seulement",
      "correct": false
    },
    {
      "text": "le passé composé",
      "correct": true
    },
    {
      "text": "le futur",
      "correct": false
    },
    {
      "text": "l'impératif",
      "correct": false
    }
  ],
  "explanation": "Repère de fait : PC."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "décor",
      "right": "imparfait"
    },
    {
      "left": "fait",
      "right": "passé composé"
    },
    {
      "left": "avant-avant",
      "right": "plus-que-parfait"
    },
    {
      "left": "déjà / jamais",
      "right": "souvent PQP"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn n'___ jamais vu une crue si rapide.",
  "answer": "avait"
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
    "nous",
    "retrouvions",
    "souvent",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "anterieur",
  "hint": "Le PQP dit qu'un fait est… à un autre (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il a plu tout le temps, chaque soir, comme une habitude.",
  "correct_sentence": "Il pleuvait chaque soir.",
  "explanation": "Habitude : imparfait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/nature-agir.svg",
      "word": "la nature"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/preposition-a.svg",
      "word": "la préposition à"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/preposition-de.svg",
      "word": "la préposition de"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/seau-eau.svg",
      "word": "un seau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Réécrivez un mini-récit de six verbes en justifiant chaque temps."
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

  -- ===== Un souvenir à raconter =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un souvenir à raconter'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un souvenir à raconter', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Ce matin-là, longtemps',
    'CO',
    $c$Objectif
Opposer un moment précis et une durée : à huit heures / pendant / longtemps / depuis.

Consigne
Lisez le dialogue. Qu'est-ce qui dure ? Qu'est-ce qui arrive pile ?

Support — Banc longtemps occupé, horloge du Seuil
Rose : Ce matin-là, à huit heures, le figuier a craqué.
Aline : Pendant deux heures, nous avons tenu les seaux.
Patrick : Longtemps, les enfants ont joué près de l'eau. Puis, soudain, ça s'est tu.
Léa : Depuis lundi, on surveille. Ça fait trois jours.
Marc : Un instant, j'ai cru que le pont cédait. Ensuite toute la journée, on a parlé.
Hawa : À midi pile, Solange a ouvert le cahier. Elle est restée une heure.
Joël : Toute la semaine, Dieudonné a cousu. À l'aube, il a fini.
Lila : Il y a deux ans, la rivière était plus large. Pendant l'été, on nageait.
Mado : Soudain, Kévin a crié. Nous sommes restés silencieux longtemps.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« À huit heures » marque un moment précis.",
  "correct": true,
  "explanation": "Rose date le craquement."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle expression indique une durée ?",
  "options": [
    {
      "text": "ce matin-là",
      "correct": false
    },
    {
      "text": "à midi pile",
      "correct": false
    },
    {
      "text": "pendant deux heures",
      "correct": true
    },
    {
      "text": "soudain",
      "correct": false
    }
  ],
  "explanation": "Pendant + durée."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "à huit heures / à midi pile",
      "right": "moment"
    },
    {
      "left": "pendant deux heures",
      "right": "durée"
    },
    {
      "left": "longtemps / toute la semaine",
      "right": "durée large"
    },
    {
      "left": "soudain / un instant",
      "right": "point"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ deux heures, nous avons tenu les seaux.",
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
    "Ce",
    "matin-là",
    "le",
    "figuier",
    "a",
    "craqué",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "soudain",
  "hint": "L'adverbe de Kévin : tout d'un coup."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "À huit heures pendant, le figuier a craqué.",
  "correct_sentence": "Ce matin-là, à huit heures, le figuier a craqué.",
  "explanation": "À + heure = moment, pas une durée."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/souvenir-duree.svg",
      "word": "un souvenir"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/horloge-moment.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/banc-longtemps.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/lettre-passe.svg",
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
  "prompt": "Listez quatre moments précis et quatre durées du dialogue."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Ce matin-là, à huit heures, le figuier a craqué. Pendant deux heures, nous avons tenu les seaux."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Lettre de Rose',
    'CE',
    $c$Objectif
Lire un souvenir qui alterne points dans le temps et durées.

Consigne
Lisez la lettre, sans aller trop vite.

Support — Lettre de Rose Iradukunda
Chers amis du Seuil,
Il y a cinq ans, un après-midi, je me suis assise sous le figuier.
J'y suis restée longtemps. Toute la soirée, les lampions du marché brillaient.
À dix-sept heures précises, Aline a posé le premier seau.
Depuis ce jour, je reviens. Ça fait des mois que l'eau baisse.
Pendant l'hiver, la terre a glissé. En une nuit, le sentier a disparu.
Soudain, on a eu peur. Puis, pendant trois jours, on a reparlé.
Rose
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose s'est assise il y a cinq ans.",
  "correct": true,
  "explanation": "« Il y a cinq ans, un après-midi… »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quand Aline a-t-elle posé le premier seau ?",
  "options": [
    {
      "text": "Pendant l'hiver",
      "correct": false
    },
    {
      "text": "À dix-sept heures précises",
      "correct": true
    },
    {
      "text": "En une nuit",
      "correct": false
    },
    {
      "text": "Depuis lundi",
      "correct": false
    }
  ],
  "explanation": "Moment précis dans la lettre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il y a cinq ans",
      "right": "distance depuis aujourd'hui"
    },
    {
      "left": "longtemps / toute la soirée",
      "right": "durée"
    },
    {
      "left": "à dix-sept heures",
      "right": "heure pile"
    },
    {
      "left": "en une nuit",
      "right": "durée courte fermée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ ce jour, je reviens.",
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
    "J'y",
    "suis",
    "restée",
    "longtemps",
    "."
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
  "hint": "Ils brillaient toute la soirée au marché."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Depuis dix-sept heures précises Aline a posé le seau comme une durée.",
  "correct_sentence": "À dix-sept heures précises, Aline a posé le premier seau.",
  "explanation": "Heure pile : à, pas depuis."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/trois-temps.svg",
      "word": "trois temps"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/cahier-memoire.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/photo-ancienne.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/souvenir-duree.svg",
      "word": "un souvenir"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Encadrez les moments (à, soudain, il y a) et les durées (pendant, longtemps, depuis)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la lettre de Rose, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dater ou durer',
    'PO',
    $c$Objectif
Dire un souvenir en choisissant un point ou une durée.

Consigne
Répétez, puis racontez deux souvenirs : un moment, une durée.

Support — Modèles de Patrick
À huit heures, ça a craqué.
Ce matin-là, j'ai eu peur.
Soudain, Kévin a crié.
Pendant deux heures, nous avons tenu.
Longtemps, les enfants ont joué.
Toute la semaine, Dieudonné a cousu.
Depuis lundi, on surveille.
Ça fait trois jours.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Ça fait trois jours » exprime une durée jusqu'à maintenant.",
  "correct": true,
  "explanation": "Équivalent proche de depuis trois jours."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase date un instant ?",
  "options": [
    {
      "text": "Longtemps, les enfants ont joué",
      "correct": false
    },
    {
      "text": "À huit heures, ça a craqué",
      "correct": true
    },
    {
      "text": "Pendant deux heures, nous avons tenu",
      "correct": false
    },
    {
      "text": "Toute la semaine, il a cousu",
      "correct": false
    }
  ],
  "explanation": "À + heure."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "à / soudain / ce matin-là",
      "right": "point"
    },
    {
      "left": "pendant / longtemps / toute",
      "right": "durée"
    },
    {
      "left": "depuis / ça fait",
      "right": "durée qui continue"
    },
    {
      "left": "il y a",
      "right": "distance vers le passé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ lundi, on surveille.",
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
    "Soudain",
    "Kévin",
    "a",
    "crié",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "longtemps",
  "hint": "Les enfants ont joué… : une grande durée."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Pendant huit heures pile, ça a craqué une seconde.",
  "correct_sentence": "À huit heures, ça a craqué.",
  "explanation": "Un instant se date par à, pas par pendant."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/de-plus-en-plus.svg",
      "word": "de plus en plus"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/de-moins-en-moins.svg",
      "word": "de moins en moins"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/graphique-avis.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/micro-opinion.svg",
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
  "prompt": "Écrivez huit phrases : quatre points, quatre durées."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux souvenirs à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon souvenir',
    'PE',
    $c$Objectif
Écrire un souvenir qui oppose un moment précis et une durée.

Consigne
Imitez le souvenir de Joël.

Support — Souvenir de Joël Mugisha
Joël Mugisha
Ce soir-là, à dix-neuf heures, j'ai entendu la rivière.
J'ai écouté longtemps. Pendant une heure, l'eau a parlé plus fort.
Soudain, un bois a claqué. Ensuite toute la nuit, on a veillé.
Depuis ce soir-là, je range les seaux près du banc.
Ça fait des semaines que je reviens.
Joël
Rive de la petite rivière — Seuil
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël a entendu la rivière à dix-neuf heures.",
  "correct": true,
  "explanation": "« à dix-neuf heures, j'ai entendu la rivière. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle durée suit le claquement ?",
  "options": [
    {
      "text": "Une seconde seulement",
      "correct": false
    },
    {
      "text": "Toute la nuit",
      "correct": true
    },
    {
      "text": "Deux minutes à midi",
      "correct": false
    },
    {
      "text": "Il y a cinq ans",
      "correct": false
    }
  ],
  "explanation": "« Ensuite toute la nuit, on a veillé. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "à dix-neuf heures",
      "right": "moment"
    },
    {
      "left": "longtemps / pendant une heure",
      "right": "durée"
    },
    {
      "left": "soudain",
      "right": "point"
    },
    {
      "left": "depuis / ça fait",
      "right": "jusqu'à maintenant"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'ai écouté ___.",
  "answer": "longtemps"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Soudain",
    "un",
    "bois",
    "a",
    "claqué",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "veille",
  "hint": "On a… toute la nuit près de l'eau."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "À dix-neuf heures pendant, j'ai entendu la rivière.",
  "correct_sentence": "Ce soir-là, à dix-neuf heures, j'ai entendu la rivière.",
  "explanation": "L'heure pile n'est pas une durée."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/groupe-engagement.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/banderole.svg",
      "word": "une banderole"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/cahier-signatures.svg",
      "word": "des signatures"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/figuier-racines.svg",
      "word": "des racines"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes, deux moments, deux durées."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre souvenir, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Moment et durée',
    'EL',
    $c$Objectif
Retenir les outils pour dater un instant ou mesurer une durée.

Consigne
Apprenez la fiche.

Support — Fiche de Lila
Moment précis : à + heure ; ce matin-là ; un jour ; soudain ; à midi pile
Durée fermée : pendant deux heures ; en une nuit ; toute la semaine
Durée ouverte jusqu'à maintenant : depuis lundi ; ça fait trois jours
Distance : il y a cinq ans (on compte depuis aujourd'hui vers le passé)
Attention : depuis + début. Pendant + longueur. En + temps pour accomplir.
On ne dit pas : pendant huit heures pour un craquement d'une seconde.
Rose : ce matin-là, à huit heures (point). Pendant deux heures, on a tenu (durée).
Ça fait trois jours = depuis trois jours, jusqu'à maintenant.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il y a » et « depuis » veulent dire la même chose.",
  "correct": false,
  "explanation": "Il y a = distance. Depuis = ça continue."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Ça fait trois jours » est proche de…",
  "options": [
    {
      "text": "à trois heures",
      "correct": false
    },
    {
      "text": "depuis trois jours",
      "correct": true
    },
    {
      "text": "soudain",
      "correct": false
    },
    {
      "text": "en une nuit",
      "correct": false
    }
  ],
  "explanation": "Durée qui continue."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "à / soudain",
      "right": "point"
    },
    {
      "left": "pendant / toute",
      "right": "durée fermée"
    },
    {
      "left": "depuis / ça fait",
      "right": "durée ouverte"
    },
    {
      "left": "il y a",
      "right": "distance"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ trois jours qu'on surveille.",
  "answer": "Ça fait"
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
    "lundi",
    "on",
    "surveille",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "distance",
  "hint": "Il y a cinq ans : une… vers le passé."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Depuis deux heures, nous avons tenu les seaux et c'est fini hier.",
  "correct_sentence": "Pendant deux heures, nous avons tenu les seaux.",
  "explanation": "Action finie, longueur close : pendant."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/cahier-signatures.svg",
      "word": "des signatures"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/figuier-racines.svg",
      "word": "des racines"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/riviere-propre.svg",
      "word": "une rivière"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/soleil-memoire.svg",
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
  "prompt": "Complétez un tableau : six outils, un exemple souvenir chacun."
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

  -- ===== Une suite de faits =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une suite de faits'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une suite de faits', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La chaîne des jours',
    'CO',
    $c$Objectif
Suivre une suite : avant, après, pendant, depuis, jusqu'à, dès, lorsque, quand.

Consigne
Lisez le dialogue. Dans quel ordre les faits s'enchaînent-ils ?

Support — Calendrier ocre, pont des Herbes
Solange : Avant la crue, le sentier était large.
Karim : Après la crue, on a posé des planches.
Aline : Pendant la pluie, personne n'est sorti. Dès l'aube, on a repris.
Léa : Lorsque le cahier est arrivé, tout le monde s'est tu.
Patrick : On a signé jusqu'à vingt heures. Depuis ce jour, on relit.
Marc : Quand Hawa a parlé, on a écouté. Ensuite Benoît a répété.
Rose : Après avoir tendu le tissu, Dieudonné s'est assis.
Joël : Avant de partir, Noura a compté les seaux.
Yvette : Jusqu'au pont, l'eau était claire. Puis elle a changé.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On a signé jusqu'à vingt heures.",
  "correct": true,
  "explanation": "Patrick : limite de fin."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que s'est-il passé dès l'aube ?",
  "options": [
    {
      "text": "On a dormi",
      "correct": false
    },
    {
      "text": "On a repris",
      "correct": true
    },
    {
      "text": "On a fermé Radio Figuier",
      "correct": false
    },
    {
      "text": "On a vendu le figuier",
      "correct": false
    }
  ],
  "explanation": "Aline : « Dès l'aube, on a repris. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avant / après",
      "right": "ordre"
    },
    {
      "left": "pendant",
      "right": "en même temps"
    },
    {
      "left": "dès / lorsque / quand",
      "right": "point de départ"
    },
    {
      "left": "jusqu'à / depuis",
      "right": "limite / continuité"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ l'aube, on a repris.",
  "answer": "Dès"
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
    "cahier",
    "est",
    "arrivé",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "planches",
  "hint": "On les a posées après la crue."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dès que l'aube jusqu'à on a repris sans verbe juste.",
  "correct_sentence": "Dès l'aube, on a repris.",
  "explanation": "Dès + moment : dès l'aube."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/suite-faits.svg",
      "word": "une suite"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/fleches-dates.svg",
      "word": "des flèches"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/calendrier-marqueurs.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/pont-temps.svg",
      "word": "un pont"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez huit marqueurs et le fait qu'ils introduisent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Avant la crue. Après la crue. Pendant la pluie. Dès l'aube. Lorsque le cahier est arrivé."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Chronologie du cahier',
    'CE',
    $c$Objectif
Lire une chronologie dense en prépositions temporelles.

Consigne
Lisez la chronologie, sans aller trop vite.

Support — Feuille de Karim Bamba
Cahier des racines — suite des faits
1. Avant mars, le figuier n'avait pas de tuteur.
2. Dès le 3 mars, on a planté deux piquets.
3. Pendant quatre jours, Dieudonné a lié le tissu.
4. Lorsque la pluie a cessé, Léa a mesuré l'eau.
5. On a veillé jusqu'au vendredi. Depuis le samedi, le niveau baisse.
6. Après la réunion, Solange a tamponné la page. Quand elle a tamponné, on a applaudi.
Seuil des Sources
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le tuteur existait déjà avant mars.",
  "correct": false,
  "explanation": "« Avant mars, le figuier n'avait pas de tuteur. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de jours Dieudonné a-t-il lié le tissu ?",
  "options": [
    {
      "text": "Deux",
      "correct": false
    },
    {
      "text": "Quatre",
      "correct": true
    },
    {
      "text": "Dix",
      "correct": false
    },
    {
      "text": "Un",
      "correct": false
    }
  ],
  "explanation": "« Pendant quatre jours. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avant mars",
      "right": "pas de tuteur"
    },
    {
      "left": "dès le 3 mars",
      "right": "piquets"
    },
    {
      "left": "pendant quatre jours",
      "right": "tissu"
    },
    {
      "left": "depuis le samedi",
      "right": "niveau baisse"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn a veillé ___ vendredi.",
  "answer": "jusqu'au"
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
    "le",
    "3",
    "mars",
    "on",
    "a",
    "planté",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tuteur",
  "hint": "Le figuier n'en avait pas avant mars."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Depuis le 3 mars on a planté et c'est fini le 3 au matin seulement.",
  "correct_sentence": "Dès le 3 mars, on a planté deux piquets.",
  "explanation": "Dès = à partir de ce moment-là (démarrage)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/riviere-propre.svg",
      "word": "une rivière"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/soleil-memoire.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/recit-temps.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/trois-temps.svg",
      "word": "trois temps"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez et reliez chaque date ou durée à son fait."
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
    'PO — Enchaîner les faits',
    'PO',
    $c$Objectif
Oraliser une suite avec avant, après, pendant, dès, lorsque, jusqu'à.

Consigne
Répétez, puis racontez trois jours d'engagement.

Support — Modèles d'Aline
Avant la crue, le sentier était large.
Après la crue, on a posé des planches.
Pendant la pluie, on est restés.
Dès l'aube, on a repris.
Lorsque Hawa a parlé, on a écouté.
On a signé jusqu'à vingt heures.
Depuis ce jour, on relit.
Quand Solange a tamponné, on a applaudi.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Lorsque » et « quand » peuvent introduire le même type de fait.",
  "correct": true,
  "explanation": "Point dans la suite."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle préposition marque la limite de fin ?",
  "options": [
    {
      "text": "depuis",
      "correct": false
    },
    {
      "text": "dès",
      "correct": false
    },
    {
      "text": "jusqu'à",
      "correct": true
    },
    {
      "text": "avant",
      "correct": false
    }
  ],
  "explanation": "Jusqu'à vingt heures."
}$j$::jsonb,
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
      "right": "plus tôt"
    },
    {
      "left": "après",
      "right": "plus tard"
    },
    {
      "left": "dès",
      "right": "à partir de"
    },
    {
      "left": "jusqu'à",
      "right": "fin"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ ce jour, on relit.",
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
    "Quand",
    "Hawa",
    "a",
    "parlé",
    "on",
    "a",
    "écouté",
    "."
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
  "hint": "L'autre mot pour quand, plus posé."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Jusqu'à ce jour on relit encore maintenant sans depuis.",
  "correct_sentence": "Depuis ce jour, on relit.",
  "explanation": "Continuité jusqu'à maintenant : depuis."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/cause-consequence.svg",
      "word": "une cause"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/affiche-cause.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/main-defense.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/arbre-proteger.svg",
      "word": "un arbre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez une suite de huit faits avec huit marqueurs différents."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis trois jours à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma suite de faits',
    'PE',
    $c$Objectif
Écrire une chronologie avec prépositions et marqueurs temporels.

Consigne
Imitez la suite de Hawa.

Support — Suite de Hawa Diallo
Hawa Diallo
Avant la réunion, j'ai lu la page.
Dès huit heures, on s'est assis sous le figuier.
Pendant une heure, chacun a parlé.
Lorsque Marc a proposé le nom, on a choisi Cahier des racines.
On a écrit jusqu'à midi. Depuis midi, le cahier circule.
Après la pause, j'ai porté le seau jusqu'au pont.
Hawa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le cahier circule depuis midi.",
  "correct": true,
  "explanation": "« Depuis midi, le cahier circule. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a proposé le nom ?",
  "options": [
    {
      "text": "Léa",
      "correct": false
    },
    {
      "text": "Marc",
      "correct": true
    },
    {
      "text": "Karim",
      "correct": false
    },
    {
      "text": "Benoît",
      "correct": false
    }
  ],
  "explanation": "« Lorsque Marc a proposé le nom… »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avant la réunion",
      "right": "lire"
    },
    {
      "left": "dès huit heures",
      "right": "s'asseoir"
    },
    {
      "left": "lorsque Marc a proposé",
      "right": "choisir le nom"
    },
    {
      "left": "jusqu'à midi",
      "right": "écrire"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn a écrit ___ midi.",
  "answer": "jusqu'à"
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
    "huit",
    "heures",
    "on",
    "s'est",
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
  "word": "circule",
  "hint": "Depuis midi, le cahier… entre les mains."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avant de la réunion, j'ai lu la page.",
  "correct_sentence": "Avant la réunion, j'ai lu la page.",
  "explanation": "Avant + nom (sans de). Avant de + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/nature-agir.svg",
      "word": "la nature"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/preposition-a.svg",
      "word": "la préposition à"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/preposition-de.svg",
      "word": "la préposition de"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/seau-eau.svg",
      "word": "un seau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes, six marqueurs temporels."
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
    'EL — Prépositions et marqueurs',
    'EL',
    $c$Objectif
Retenir avant, après, pendant, depuis, jusqu'à, dès, lorsque, quand.

Consigne
Apprenez la fiche.

Support — Fiche de Solange
avant + nom : avant la crue. avant de + infinitif : avant de partir
après + nom / après + infinitif : après la crue, après avoir signé
pendant + durée : pendant la pluie, pendant quatre jours
depuis + début (ça continue) : depuis samedi
jusqu'à + fin : jusqu'à vingt heures, jusqu'au pont (à + le = au)
dès + moment de départ : dès l'aube, dès le 3 mars
lorsque / quand + fait : Lorsque le cahier est arrivé…
Ensuite / puis / enfin enchaînent sans préposition : ensuite Benoît a répété.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « avant de la réunion ».",
  "correct": false,
  "explanation": "Avant + nom, sans de."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Jusqu'à + le pont » donne…",
  "options": [
    {
      "text": "jusqu'à le pont",
      "correct": false
    },
    {
      "text": "jusqu'au pont",
      "correct": true
    },
    {
      "text": "jusqu'aux pont",
      "correct": false
    },
    {
      "text": "jusque le pont",
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
      "left": "avant + nom",
      "right": "sans de"
    },
    {
      "left": "avant de",
      "right": "infinitif"
    },
    {
      "left": "depuis",
      "right": "ça continue"
    },
    {
      "left": "dès",
      "right": "démarrage"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn a porté le seau ___ pont.",
  "answer": "jusqu'au"
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
    "la",
    "pluie",
    "on",
    "est",
    "restés",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "demarrage",
  "hint": "Dès marque un… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avant de mars, le figuier n'avait pas de tuteur.",
  "correct_sentence": "Avant mars, le figuier n'avait pas de tuteur.",
  "explanation": "Avant + nom de mois, sans de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/de-plus-en-plus.svg",
      "word": "de plus en plus"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/de-moins-en-moins.svg",
      "word": "de moins en moins"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/graphique-avis.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/micro-opinion.svg",
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
  "prompt": "Rédigez huit mini-phrases, une par outil de la fiche."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et huit exemples."
}$j$::jsonb,
    9
  );

  -- ===== Une cause à défendre =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une cause à défendre'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une cause à défendre', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Pourquoi le cahier',
    'CO',
    $c$Objectif
Repérer parce que, puisque, à cause de, donc, alors, c'est pourquoi.

Consigne
Lisez le dialogue. Qu'est-ce qui cause ? Qu'est-ce qui suit ?

Support — Réunion sous le figuier
Aline : On écrit parce que l'eau recule trop vite.
Patrick : Puisque tout le monde a vu la crue, on peut signer.
Léa : À cause des sacs trop lourds, la berge s'est cassée.
Marc : La terre a glissé, donc on plante des tuteurs.
Hawa : Il n'y a plus d'ombre au milieu, alors on protège le figuier.
Joël : C'est pourquoi le cahier s'appelle Cahier des racines.
Rose : Grâce aux lampions, on a veillé sans peur. (cause positive)
Solange : Karim a tamponné, donc la page est officielle ici, au Seuil.
Lila : On n'a pas assez d'eau claire, c'est pourquoi on agit.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Parce que » introduit une cause.",
  "correct": true,
  "explanation": "On écrit parce que l'eau recule."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle expression introduit une conséquence ?",
  "options": [
    {
      "text": "parce que",
      "correct": false
    },
    {
      "text": "puisque",
      "correct": false
    },
    {
      "text": "à cause de",
      "correct": false
    },
    {
      "text": "c'est pourquoi",
      "correct": true
    }
  ],
  "explanation": "C'est pourquoi + conséquence."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "parce que / puisque",
      "right": "cause + phrase"
    },
    {
      "left": "à cause de",
      "right": "cause + nom"
    },
    {
      "left": "donc / alors",
      "right": "conséquence"
    },
    {
      "left": "c'est pourquoi",
      "right": "conséquence soulignée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa terre a glissé, ___ on plante des tuteurs.",
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
    "On",
    "écrit",
    "parce",
    "que",
    "l'eau",
    "recule",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "berge",
  "hint": "Elle s'est cassée à cause des sacs."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On écrit à cause que l'eau recule.",
  "correct_sentence": "On écrit parce que l'eau recule trop vite.",
  "explanation": "Pas à cause que : parce que + phrase, à cause de + nom."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/cause-consequence.svg",
      "word": "une cause"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/affiche-cause.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/main-defense.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/arbre-proteger.svg",
      "word": "un arbre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez trois causes et trois conséquences du dialogue."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On écrit parce que l'eau recule. La terre a glissé, donc on plante. C'est pourquoi le cahier s'appelle ainsi."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Appel du Cahier des racines',
    'CE',
    $c$Objectif
Lire un appel qui enchaîne causes et conséquences.

Consigne
Lisez l'appel, sans aller trop vite.

Support — Affiche, tableau de la cour
Appel — Cahier des racines
Signez, puisque vous habitez le Seuil.
On agit parce que le figuier a craqué et parce que la rivière s'ensable.
À cause des plastiques du chemin, les nénuphars du lac vont moins bien.
La berge est fragile, donc on refuse les sacs trop lourds près de l'eau.
Il reste peu d'ombre, alors on arrose le soir.
C'est pourquoi nous demandons deux tuteurs et un seau commun.
Merci. Aline, Marc, Rose — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'appel demande deux tuteurs et un seau commun.",
  "correct": true,
  "explanation": "Dernière phrase de demande."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi les nénuphars vont-ils moins bien ?",
  "options": [
    {
      "text": "À cause de Radio Figuier",
      "correct": false
    },
    {
      "text": "À cause des plastiques du chemin",
      "correct": true
    },
    {
      "text": "Parce que Marc chante",
      "correct": false
    },
    {
      "text": "Puisque Yvette dort",
      "correct": false
    }
  ],
  "explanation": "« À cause des plastiques du chemin. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "puisque vous habitez",
      "right": "cause connue"
    },
    {
      "left": "parce que le figuier a craqué",
      "right": "cause"
    },
    {
      "left": "à cause des plastiques",
      "right": "cause + nom"
    },
    {
      "left": "c'est pourquoi nous demandons",
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
  "prompt": "Complétez :\nLa berge est fragile, ___ on refuse les sacs trop lourds.",
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
    "Signez",
    "puisque",
    "vous",
    "habitez",
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
  "word": "tuteurs",
  "hint": "On en demande deux pour le figuier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On agit à cause que le figuier a craqué.",
  "correct_sentence": "On agit parce que le figuier a craqué.",
  "explanation": "Parce que + phrase."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/nature-agir.svg",
      "word": "la nature"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/preposition-a.svg",
      "word": "la préposition à"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/preposition-de.svg",
      "word": "la préposition de"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/seau-eau.svg",
      "word": "un seau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Soulignez les causes en ocre et les conséquences en vert."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'appel, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire la cause, la suite',
    'PO',
    $c$Objectif
Enchaîner à voix haute une cause et une conséquence.

Consigne
Répétez, puis défendez une petite cause du Seuil.

Support — Modèles de Marc
On écrit parce que l'eau recule.
Puisque tout le monde a vu, on signe.
À cause des sacs, la berge casse.
Donc on plante des tuteurs.
Alors on protège le figuier.
C'est pourquoi le cahier existe.
Grâce aux lampions, on a veillé.
Il reste peu d'ombre, alors on arrose.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Grâce à » introduit une cause plutôt positive.",
  "correct": true,
  "explanation": "Grâce aux lampions ≠ à cause des sacs."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme demande un nom (pas une phrase) ?",
  "options": [
    {
      "text": "parce que",
      "correct": false
    },
    {
      "text": "puisque",
      "correct": false
    },
    {
      "text": "à cause de",
      "correct": true
    },
    {
      "text": "c'est pourquoi",
      "correct": false
    }
  ],
  "explanation": "À cause de + nom."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "parce que",
      "right": "cause nouvelle"
    },
    {
      "left": "puisque",
      "right": "cause déjà connue"
    },
    {
      "left": "donc / alors",
      "right": "conséquence simple"
    },
    {
      "left": "c'est pourquoi",
      "right": "conséquence forte"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ aux lampions, on a veillé.",
  "answer": "Grâce"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Alors",
    "on",
    "protège",
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
  "word": "puisque",
  "hint": "Cause déjà connue de tout le monde."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "À cause de l'eau recule, on écrit.",
  "correct_sentence": "On écrit parce que l'eau recule.",
  "explanation": "À cause de + nom. Parce que + phrase."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/groupe-engagement.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/banderole.svg",
      "word": "une banderole"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/cahier-signatures.svg",
      "word": "des signatures"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/figuier-racines.svg",
      "word": "des racines"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six paires cause → conséquence, outils différents."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis une cause à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon appel',
    'PE',
    $c$Objectif
Écrire un court appel avec causes et conséquences.

Consigne
Imitez l'appel de Rose.

Support — Appel de Rose Iradukunda
Rose Iradukunda
Je signe parce que le figuier m'a donné de l'ombre.
Puisque la rivière nous a sauvés l'été, on la défend.
À cause des plastiques, l'eau est moins claire.
La terre glisse, donc on pose deux tuteurs.
Alors on arrose le soir, près de la rive.
C'est pourquoi je porte le Cahier des racines jusqu'à la Table des Sources.
Rose
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose porte le cahier jusqu'à la Table des Sources.",
  "correct": true,
  "explanation": "Dernière phrase."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle cause utilise à cause de ?",
  "options": [
    {
      "text": "le figuier",
      "correct": false
    },
    {
      "text": "la rivière",
      "correct": false
    },
    {
      "text": "les plastiques",
      "correct": true
    },
    {
      "text": "les tuteurs",
      "correct": false
    }
  ],
  "explanation": "« À cause des plastiques. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "parce que le figuier",
      "right": "ombre"
    },
    {
      "left": "puisque la rivière",
      "right": "l'été"
    },
    {
      "left": "à cause des plastiques",
      "right": "eau moins claire"
    },
    {
      "left": "c'est pourquoi",
      "right": "porter le cahier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa terre glisse, ___ on pose deux tuteurs.",
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
    "Je",
    "signe",
    "parce",
    "que",
    "le",
    "figuier",
    "m'a",
    "donné",
    "de",
    "l'ombre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "plastiques",
  "hint": "À cause d'eux, l'eau est moins claire."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je signe à cause que le figuier donne de l'ombre.",
  "correct_sentence": "Je signe parce que le figuier m'a donné de l'ombre.",
  "explanation": "Parce que + phrase. À cause que n'existe pas."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/cahier-memoire.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/photo-ancienne.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/souvenir-duree.svg",
      "word": "un souvenir"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/horloge-moment.svg",
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
  "prompt": "Imitez : cinq lignes, trois causes, deux conséquences."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre appel, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Cause et conséquence',
    'EL',
    $c$Objectif
Retenir parce que, puisque, à cause de, grâce à, donc, alors, c'est pourquoi.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
Cause + phrase : parce que (info nouvelle), puisque (info déjà partagée)
Cause + nom : à cause de (négatif ou neutre), grâce à (positif)
Conséquence : donc, alors, c'est pourquoi
Place : cause d'abord ou conséquence d'abord. C'est pourquoi souvent en tête de phrase.
Pas : à cause que. Pas : grâce que.
Donc se place souvent après une virgule : La terre a glissé, donc on plante.
Au Seuil : on écrit parce que l'eau recule ; c'est pourquoi le cahier existe.
Alors est plus parlé ; c'est pourquoi est plus posé, bon pour un appel.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Puisque » présente souvent une cause que l'autre connaît déjà.",
  "correct": true,
  "explanation": "Puisque vous habitez le Seuil…"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle paire est juste ?",
  "options": [
    {
      "text": "à cause que + phrase",
      "correct": false
    },
    {
      "text": "à cause de + nom",
      "correct": true
    },
    {
      "text": "grâce que + nom",
      "correct": false
    },
    {
      "text": "parce de + nom",
      "correct": false
    }
  ],
  "explanation": "À cause de + nom."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "parce que",
      "right": "cause + phrase"
    },
    {
      "left": "à cause de",
      "right": "cause + nom"
    },
    {
      "left": "grâce à",
      "right": "cause positive"
    },
    {
      "left": "c'est pourquoi",
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
  "prompt": "Complétez :\nPas « à cause que » : on dit ___ que.",
  "answer": "parce"
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
    "cahier",
    "existe",
    "."
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
  "hint": "Donc, alors, c'est pourquoi : la… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Grâce que les lampions, on a veillé.",
  "correct_sentence": "Grâce aux lampions, on a veillé.",
  "explanation": "Grâce à + nom (à + les = aux)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/banc-longtemps.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/lettre-passe.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/suite-faits.svg",
      "word": "une suite"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/fleches-dates.svg",
      "word": "des flèches"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez six phrases : cause ↔ conséquence, outils différents."
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

  -- ===== Agir pour la nature =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Agir pour la nature'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Agir pour la nature', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Prêts à agir',
    'CO',
    $c$Objectif
Repérer facile à, content de, prêt à, fier de, et d'autres adj. + à / de.

Consigne
Lisez le dialogue. Quel adjectif va avec à ? Lequel va avec de ?

Support — Rive de la petite rivière
Aline : C'est facile à dire, plus difficile à faire.
Patrick : Je suis content de signer. Je suis prêt à porter les seaux.
Léa : Nous sommes fiers de ce figuier. Il est bon à protéger.
Marc : L'eau est difficile à filtrer. On est capables de patienter.
Hawa : Je suis heureuse de voir les nénuphars. Je suis sûre de revenir.
Joël : On est fatigués de ramasser les plastiques. Pourtant utiles à éviter.
Rose : Je suis ravie d'aider. Le sentier est long à réparer.
Dieudonné : Le tissu est simple à tendre. Je suis fier de le coudre ici.
Yvette : Soyez prêts à écouter Lila. Elle est certaine de la dose d'eau.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Content » se construit avec de.",
  "correct": true,
  "explanation": "Patrick : content de signer."
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
      "text": "prêt de porter",
      "correct": false
    },
    {
      "text": "prêt à porter",
      "correct": true
    },
    {
      "text": "fier à ce figuier",
      "correct": false
    },
    {
      "text": "facile de dire (sens « aisé »)",
      "correct": false
    }
  ],
  "explanation": "Prêt à + infinitif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "facile à / difficile à",
      "right": "infinitif"
    },
    {
      "left": "content de / fier de",
      "right": "nom ou infinitif"
    },
    {
      "left": "prêt à",
      "right": "action"
    },
    {
      "left": "capable de",
      "right": "pouvoir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe suis ___ à porter les seaux.",
  "answer": "prêt"
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
  "word": "nénuphars",
  "hint": "Hawa est heureuse de les voir au lac."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis prêt de porter les seaux.",
  "correct_sentence": "Je suis prêt à porter les seaux.",
  "explanation": "Prêt à + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/nature-agir.svg",
      "word": "la nature"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/preposition-a.svg",
      "word": "la préposition à"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/preposition-de.svg",
      "word": "la préposition de"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/seau-eau.svg",
      "word": "un seau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Classez huit adjectifs : + à ou + de."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : C'est facile à dire. Je suis content de signer. Je suis prêt à porter. Nous sommes fiers de ce figuier."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Mot d''action',
    'CE',
    $c$Objectif
Lire un mot d'engagement avec adjectifs + à / de.

Consigne
Lisez le mot, sans aller trop vite.

Support — Mot de Lila Sow
Amies, amis,
Le figuier est précieux à garder. L'eau est difficile à partager si on gaspille.
Soyez contents de peu : un seau, deux tuteurs.
Soyez prêts à venir à l'aube. Soyez fiers de vos signatures.
Le plastique est mauvais à laisser près de la rive.
Nous sommes heureux de vous lire. Nous sommes certains de tenir.
Le chemin est long à réparer, mais utile à marcher ensemble.
Lila — lac des Nénuphars / Seuil
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila dit que le plastique est bon à laisser près de l'eau.",
  "correct": false,
  "explanation": "« mauvais à laisser près de la rive. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "De quoi faut-il être fiers ?",
  "options": [
    {
      "text": "Des sacs lourds",
      "correct": false
    },
    {
      "text": "Des signatures",
      "correct": true
    },
    {
      "text": "Du gaspillage",
      "correct": false
    },
    {
      "text": "De Radio seulement",
      "correct": false
    }
  ],
  "explanation": "« fiers de vos signatures. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "précieux à",
      "right": "garder"
    },
    {
      "left": "contents de",
      "right": "peu"
    },
    {
      "left": "prêts à",
      "right": "venir"
    },
    {
      "left": "fiers de",
      "right": "signatures"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSoyez prêts ___ venir à l'aube.",
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
    "Le",
    "chemin",
    "est",
    "long",
    "à",
    "réparer",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "signatures",
  "hint": "Il faut en être fiers, dans le cahier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Soyez fiers à vos signatures.",
  "correct_sentence": "Soyez fiers de vos signatures.",
  "explanation": "Fier de + nom."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/preposition-de.svg",
      "word": "la préposition de"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/seau-eau.svg",
      "word": "un seau"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/de-plus-en-plus.svg",
      "word": "de plus en plus"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/de-moins-en-moins.svg",
      "word": "de moins en moins"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez et encadrez à / de après chaque adjectif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le mot de Lila, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire facile à, fier de',
    'PO',
    $c$Objectif
Enchaîner des adjectifs + à ou + de à propos de la nature.

Consigne
Répétez, puis parlez d'un geste pour le figuier.

Support — Modèles de Léa
C'est facile à dire.
C'est difficile à faire.
Je suis content de signer.
Je suis prêt à agir.
Nous sommes fiers de ce figuier.
Je suis capable de patienter.
Je suis fatigué de ramasser.
Je suis heureux de revenir.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Fatigué » se construit avec de.",
  "correct": true,
  "explanation": "Fatigué de + infinitif / nom."
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
      "text": "Je suis capable à patienter",
      "correct": false
    },
    {
      "text": "Je suis capable de patienter",
      "correct": true
    },
    {
      "text": "Je suis prêt de agir",
      "correct": false
    },
    {
      "text": "C'est facile de dire (sens A2 retenu : à)",
      "correct": false
    }
  ],
  "explanation": "Capable de."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "facile / difficile / long / prêt / utile",
      "right": "+ à"
    },
    {
      "left": "content / fier / capable / fatigué / heureux / sûr",
      "right": "+ de"
    },
    {
      "left": "prêt à",
      "right": "avenir proche"
    },
    {
      "left": "fier de",
      "right": "fierté"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous sommes fiers ___ ce figuier.",
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
    "prêt",
    "à",
    "agir",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "patienter",
  "hint": "Marc dit qu'on est capables de… près de l'eau."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est difficile de faire sur la rive.",
  "correct_sentence": "C'est difficile à faire sur la rive.",
  "explanation": "Difficile à + infinitif (qualité de l'action)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/graphique-avis.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/micro-opinion.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/groupe-engagement.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/banderole.svg",
      "word": "une banderole"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases : quatre + à, quatre + de."
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
    'PE — Mon mot pour la rive',
    'PE',
    $c$Objectif
Écrire un mot d'action avec adjectifs + à / de.

Consigne
Imitez le mot de Patrick.

Support — Mot de Patrick Habimana
Patrick Habimana
Je suis content de porter le seau.
Je suis prêt à revenir dès l'aube.
Le figuier est facile à aimer, plus difficile à sauver.
Nous sommes fiers de nos signatures.
Je suis capable de parler sans crier.
Le plastique est mauvais à jeter ici.
Patrick
Petite rivière — Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick est prêt à revenir dès l'aube.",
  "correct": true,
  "explanation": "Deuxième ligne."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qu'est-ce qui est difficile à sauver ?",
  "options": [
    {
      "text": "Le seau",
      "correct": false
    },
    {
      "text": "Le figuier",
      "correct": true
    },
    {
      "text": "Radio Figuier",
      "correct": false
    },
    {
      "text": "Le Bureau",
      "correct": false
    }
  ],
  "explanation": "« plus difficile à sauver. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "content de",
      "right": "porter"
    },
    {
      "left": "prêt à",
      "right": "revenir"
    },
    {
      "left": "fiers de",
      "right": "signatures"
    },
    {
      "left": "mauvais à",
      "right": "jeter"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe suis capable ___ parler sans crier.",
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
    "content",
    "de",
    "porter",
    "le",
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
  "word": "sauver",
  "hint": "Le figuier est plus difficile à…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis prêt de revenir dès l'aube.",
  "correct_sentence": "Je suis prêt à revenir dès l'aube.",
  "explanation": "Prêt à."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/cahier-signatures.svg",
      "word": "des signatures"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/figuier-racines.svg",
      "word": "des racines"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/riviere-propre.svg",
      "word": "une rivière"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/soleil-memoire.svg",
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
  "prompt": "Imitez : six lignes, trois + à, trois + de."
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
    'EL — Adjectif + à / de',
    'EL',
    $c$Objectif
Retenir facile à, content de, prêt à, fier de et les listes A2.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
+ à + infinitif : facile à, difficile à, long à, dur à, bon à, mauvais à, utile à, prêt à, précieux à
+ de + nom ou infinitif : content de, heureux de, ravi de, fier de, sûr de, certain de, capable de, fatigué de
Sens : à souvent « pour faire / vis-à-vis de l'action ». de souvent « à propos de / source du sentiment ».
Attention : prêt à (pas prêt de). fier de (pas fier à). capable de.
facile à dire ≠ je suis facile (la personne).
Exemples rive : prêt à porter les seaux ; fier de ce figuier ; content de signer.
Difficile à filtrer. Utile à marcher ensemble. Fatigué de ramasser les plastiques.
On retient ces listes pour Agir pour la nature, pas d'autres prépositions au hasard.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « fier à » devant un nom.",
  "correct": false,
  "explanation": "Fier de."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Utile » se construit souvent avec…",
  "options": [
    {
      "text": "de + infinitif",
      "correct": false
    },
    {
      "text": "à + infinitif",
      "correct": true
    },
    {
      "text": "sur + infinitif",
      "correct": false
    },
    {
      "text": "en + infinitif",
      "correct": false
    }
  ],
  "explanation": "Utile à marcher / utile à + inf."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "prêt",
      "right": "à"
    },
    {
      "left": "fier",
      "right": "de"
    },
    {
      "left": "facile",
      "right": "à"
    },
    {
      "left": "content",
      "right": "de"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est utile ___ marcher ensemble.",
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
    "suis",
    "sûr",
    "de",
    "revenir",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "sentiment",
  "hint": "Content, fier, heureux : un… + de."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous sommes capables à patienter.",
  "correct_sentence": "Nous sommes capables de patienter.",
  "explanation": "Capable de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/calendrier-marqueurs.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/pont-temps.svg",
      "word": "un pont"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/cause-consequence.svg",
      "word": "une cause"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/affiche-cause.svg",
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
  "prompt": "Tableau : dix adjectifs, préposition, un exemple nature."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et dix exemples."
}$j$::jsonb,
    9
  );

  -- ===== Donner son avis =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Donner son avis'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Donner son avis', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Autour du micro',
    'CO',
    $c$Objectif
Repérer de plus en plus et de moins en moins (adjectif, adverbe, de + nom).

Consigne
Lisez le dialogue. Qu'est-ce qui augmente ? Qu'est-ce qui diminue ?

Support — Micro de la cour, avis croisés
Marc : L'eau est de moins en moins claire. C'est visible.
Léa : Il y a de plus en plus de plastiques près du pont.
Aline : On est de plus en plus nombreux à signer. Tant mieux.
Patrick : Le figuier donne de moins en moins d'ombre au milieu.
Hawa : Je suis de plus en plus inquiète, et de moins en moins patiente.
Joël : On parle de plus en plus fort. On devrait parler plus doucement.
Rose : Il y a de moins en moins d'oiseaux le matin.
Solange : Les pages sont de plus en plus pleines. Le cahier avance.
Kévin : Moi, je suis de moins en moins d'accord avec les sacs lourds.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa voit de plus en plus de plastiques.",
  "correct": true,
  "explanation": "De plus en plus de + nom."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que dit Patrick du figuier ?",
  "options": [
    {
      "text": "De plus en plus d'ombre",
      "correct": false
    },
    {
      "text": "De moins en moins d'ombre au milieu",
      "correct": true
    },
    {
      "text": "Plus d'oiseaux",
      "correct": false
    },
    {
      "text": "Moins de signatures",
      "correct": false
    }
  ],
  "explanation": "« de moins en moins d'ombre »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "de plus en plus + adj.",
      "right": "inquiète / nombreux / pleines"
    },
    {
      "left": "de moins en moins + adj.",
      "right": "claire / patiente"
    },
    {
      "left": "de plus en plus de + nom",
      "right": "plastiques"
    },
    {
      "left": "de moins en moins de + nom",
      "right": "oiseaux / ombre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'eau est de moins en moins ___.",
  "answer": "claire"
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
    "de",
    "plus",
    "en",
    "plus",
    "de",
    "plastiques",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "plastiques",
  "hint": "Léa en voit de plus en plus près du pont."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il y a de plus en plus plastiques près du pont.",
  "correct_sentence": "Il y a de plus en plus de plastiques près du pont.",
  "explanation": "Devant un nom : de plus en plus de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/de-plus-en-plus.svg",
      "word": "de plus en plus"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/de-moins-en-moins.svg",
      "word": "de moins en moins"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/graphique-avis.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/micro-opinion.svg",
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
  "prompt": "Notez quatre « plus » et quatre « moins » avec ce qui change."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : L'eau est de moins en moins claire. Il y a de plus en plus de plastiques. On est de plus en plus nombreux."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Avis affichés',
    'CE',
    $c$Objectif
Lire des avis qui utilisent de plus en plus / de moins en moins.

Consigne
Lisez les avis, sans aller trop vite.

Support — Tableau de la cour, bandelettes
Avis 1 — Aline : On est de plus en plus attentifs à la rive.
Avis 2 — Patrick : Il y a de moins en moins d'eau en août.
Avis 3 — Rose : Les enfants sont de plus en plus curieux du cahier.
Avis 4 — Joël : Je marche de moins en moins vite près des nids.
Avis 5 — Hawa : De plus en plus de signatures, de moins en moins de doutes.
Avis 6 — Marc : Le soir, on discute de plus en plus longtemps.
Avis 7 — Solange : Les pages sont de plus en plus pleines.
Règle : adj. / adv. sans de ; nom avec de (d' devant voyelle).
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick parle d'une baisse d'eau en août.",
  "correct": true,
  "explanation": "« de moins en moins d'eau en août. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui marche de moins en moins vite ?",
  "options": [
    {
      "text": "Aline",
      "correct": false
    },
    {
      "text": "Rose",
      "correct": false
    },
    {
      "text": "Joël",
      "correct": true
    },
    {
      "text": "Marc",
      "correct": false
    }
  ],
  "explanation": "Avis 4."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "de plus en plus attentifs",
      "right": "Aline"
    },
    {
      "left": "de moins en moins d'eau",
      "right": "Patrick"
    },
    {
      "left": "de plus en plus curieux",
      "right": "Rose"
    },
    {
      "left": "de plus en plus longtemps",
      "right": "Marc"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDe plus en plus ___ signatures.",
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
    "On",
    "discute",
    "de",
    "plus",
    "en",
    "plus",
    "longtemps",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "curieux",
  "hint": "Les enfants le sont de plus en plus, devant le cahier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il y a de moins en moins eau en août.",
  "correct_sentence": "Il y a de moins en moins d'eau en août.",
  "explanation": "De + nom ; d' devant voyelle."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/recit-temps.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/trois-temps.svg",
      "word": "trois temps"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/cahier-memoire.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/photo-ancienne.svg",
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
  "prompt": "Recopiez deux avis et ajoutez le vôtre avec plus et moins."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six avis, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire plus, dire moins',
    'PO',
    $c$Objectif
Donner un avis avec de plus en plus / de moins en moins.

Consigne
Répétez, puis donnez votre avis sur la rive.

Support — Modèles d'Aline
C'est de plus en plus clair.
C'est de moins en moins simple.
Il y a de plus en plus de monde.
Il y a de moins en moins d'ombre.
Je suis de plus en plus convaincue.
On parle de moins en moins fort.
Les pages sont de plus en plus pleines.
Je suis de moins en moins d'accord.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Devant un adjectif, on n'ajoute pas de.",
  "correct": true,
  "explanation": "De plus en plus clair (pas de clair)."
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
      "text": "de plus en plus de clair",
      "correct": false
    },
    {
      "text": "de plus en plus clair",
      "correct": true
    },
    {
      "text": "de plus en plus clairs de",
      "correct": false
    },
    {
      "text": "plus en plus de clair",
      "correct": false
    }
  ],
  "explanation": "Adjectif : sans de."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "+ adjectif",
      "right": "sans de"
    },
    {
      "left": "+ adverbe",
      "right": "sans de"
    },
    {
      "left": "+ nom",
      "right": "de / d'"
    },
    {
      "left": "être d'accord",
      "right": "de moins en moins d'accord"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl y a de moins en moins ___ ombre.",
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
    "suis",
    "de",
    "plus",
    "en",
    "plus",
    "convaincue",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "convaincue",
  "hint": "Aline l'est de plus en plus, au féminin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il y a de plus en plus monde sous le figuier.",
  "correct_sentence": "Il y a de plus en plus de monde.",
  "explanation": "Nom : de plus en plus de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/suite-faits.svg",
      "word": "une suite"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/fleches-dates.svg",
      "word": "des flèches"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/calendrier-marqueurs.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/pont-temps.svg",
      "word": "un pont"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit avis : quatre plus, quatre moins, noms et adjectifs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis trois avis à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon avis',
    'PE',
    $c$Objectif
Écrire un avis structuré avec de plus en plus / de moins en moins.

Consigne
Imitez l'avis de Léa.

Support — Avis de Léa Niyonzima
Léa Niyonzima
Je trouve l'eau de moins en moins claire près du pont.
Il y a de plus en plus de signatures, et de moins en moins de doutes.
Nous sommes de plus en plus prêts à agir à l'aube.
Le figuier donne de moins en moins d'ombre au milieu, donc on arrose.
Je suis de plus en plus fière du Cahier des racines.
Léa
Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa a de plus en plus de doutes.",
  "correct": false,
  "explanation": "« de moins en moins de doutes. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "De quoi Léa est-elle de plus en plus fière ?",
  "options": [
    {
      "text": "Des sacs",
      "correct": false
    },
    {
      "text": "Du Cahier des racines",
      "correct": true
    },
    {
      "text": "De Radio seulement",
      "correct": false
    },
    {
      "text": "De Val-des-Peupliers",
      "correct": false
    }
  ],
  "explanation": "Dernière phrase avant la signature."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "de moins en moins claire",
      "right": "eau"
    },
    {
      "left": "de plus en plus de signatures",
      "right": "cahier"
    },
    {
      "left": "de plus en plus prêts",
      "right": "agir"
    },
    {
      "left": "de plus en plus fière",
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
  "prompt": "Complétez :\nJe suis de plus en plus ___ du Cahier des racines.",
  "answer": "fière"
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
    "de",
    "moins",
    "en",
    "moins",
    "de",
    "doutes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "doutes",
  "hint": "Il y en a de moins en moins, d'après Léa."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il y a de plus en plus signatures dans le cahier.",
  "correct_sentence": "Il y a de plus en plus de signatures.",
  "explanation": "Devant un nom : de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/main-defense.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/arbre-proteger.svg",
      "word": "un arbre"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/nature-agir.svg",
      "word": "la nature"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/preposition-a.svg",
      "word": "la préposition à"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : cinq lignes, plus et moins, un nom et un adjectif au moins."
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
    'EL — De plus en plus, de moins en moins',
    'EL',
    $c$Objectif
Retenir les trois constructions : adjectif, adverbe, de + nom.

Consigne
Apprenez la fiche.

Support — Fiche de Marc
de plus en plus + adjectif : de plus en plus clair / nombreux / fière
de moins en moins + adjectif : de moins en moins simple / patiente
+ adverbe : de plus en plus longtemps ; de moins en moins vite / fort
+ nom : de plus en plus de signatures ; de moins en moins d'eau (d' + voyelle)
Accord de l'adjectif : on est de plus en plus nombreux ; je suis de plus en plus fière.
On ne dit pas : de plus en plus de clair. On ne dit pas : de plus en plus signatures.
Sous le figuier : de plus en plus de signatures ; de moins en moins d'ombre au milieu.
Je suis de moins en moins d'accord avec les sacs trop lourds.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Devant un nom, il faut de (ou d').",
  "correct": true,
  "explanation": "De plus en plus de monde."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« De moins en moins d'eau » : pourquoi d' ?",
  "options": [
    {
      "text": "parce que moins est féminin",
      "correct": false
    },
    {
      "text": "devant une voyelle",
      "correct": true
    },
    {
      "text": "parce que c'est un verbe",
      "correct": false
    },
    {
      "text": "par hasard",
      "correct": false
    }
  ],
  "explanation": "De + eau → d'eau."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "+ adj.",
      "right": "sans de"
    },
    {
      "left": "+ adv.",
      "right": "sans de"
    },
    {
      "left": "+ nom",
      "right": "de / d'"
    },
    {
      "left": "accord",
      "right": "avec le sujet de l'adjectif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn parle de moins en moins ___. (intensité)",
  "answer": "fort"
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
    "pages",
    "sont",
    "de",
    "plus",
    "en",
    "plus",
    "pleines",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "nombreux",
  "hint": "On est de plus en plus… à signer."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis de plus en plus fier, écrit Léa.",
  "correct_sentence": "Je suis de plus en plus fière, écrit Léa.",
  "explanation": "Accord : fière avec Léa."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m7/souvenir-duree.svg",
      "word": "un souvenir"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/horloge-moment.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/banc-longtemps.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-a2-m7/lettre-passe.svg",
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
  "prompt": "Écrivez neuf phrases : trois adj., trois adv., trois noms."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et neuf exemples."
}$j$::jsonb,
    9
  );

END;
$$;
