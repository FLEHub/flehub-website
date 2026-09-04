/*
  Seed eLearning MFK — C2 — Cultures croisées

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-c2-m5/
  Module laissé en brouillon (published = false).
  Aucune table nouvelle. Idempotent. Éditable via « Gérer le contenu ».
  A1 / A2 / B1 / B2 inchangés.
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
  v_module_title text := 'C2 — Cultures croisées';
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
      'Seed C2 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed C2 : enseignant % (%) — %', v_teacher_email, v_teacher_id, v_module_title;

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
      'Grande étape C2-5 : écrire en implicite sur l''accès à la Salle des Herbes, expliquer un rire, débattre d''un tissu trop vite porté, raconter une expérience détaillée, puis un article et un débat — Rose Iradukunda refuse qu''on lui prenne le lin comme décor, Hawa Diallo raconte sans ethnologiser, Sami fait rire sans écraser.',
      'C2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape C2-5 : écrire en implicite sur l''accès à la Salle des Herbes, expliquer un rire, débattre d''un tissu trop vite porté, raconter une expérience détaillée, puis un article et un débat — Rose Iradukunda refuse qu''on lui prenne le lin comme décor, Hawa Diallo raconte sans ethnologiser, Sami fait rire sans écraser.',
      cefr_level = 'C2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Culture partagée =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Culture partagée'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Culture partagée', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Culture partagée',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Rédiger un article qui exprime implicitement une position sur l'accès à la Salle. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Culture partagée
Lila Sow : Radio Figuier. On parle trop vite de l'accès trop cher à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on dispense d'ouvrir vraiment la porte, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Hawa Diallo concède que un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Aline Uwase : Ce que l'on nomme accessibilité, ici, n'est pas un slogan : possibilité réelle d'entrer.
Patrick Habimana : Hawa : il ne s'agirait que d'un détail, le tarif, à entendre l'affiche.
Hawa Diallo : Loin d'ouvrir, le mot généreux fermait plus net.
Joël Mugisha : Rose coud trop près de la porte.
Rose Iradukunda : Aline : l'implicite se justifie par l'écart.
Solange Mukamana : Joël n'entre pas sous la pluie.
Karim Bamba : Lila lira sans coller un slogan contraire.
Félicie Ndayishimiye : Un chiffre, une trace : Hawa a cité le tarif ; la rampe absente ; le mot généreux ; zéro cri.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une position, pas d'une affiche contraire
Yvette : Patrick veut les faits.
Mado : Rose Iradukunda entend, dans « la culture est à tout le monde », ceci qui n'est pas dit : à tout le monde, sans rampe ni tarif, est une invitation à se taire
Sami : Autrement dit, l'article ne criera pas : il décrira la porte, le tarif, le mot, et l'écart fera le travail
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un article implicite : faits, écart, zéro slogan retourné
Nina Kayitesi : Marc : une position C2 peut ne pas crier, elle doit se lire.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'affiche trop généreuse d'un côté, l'article d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : La culture est à tout le monde : on vérifiera, par politesse, le tarif et la rampe.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un billet trop haut pour Hawa, un mot trop généreux est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Rose Iradukunda, que reste-t-il implicite dans « la culture est à tout le monde » ?",
  "options": [
    {
      "text": "Que Hawa a crié dans l'article",
      "correct": false
    },
    {
      "text": "Une invitation à se taire",
      "correct": true
    },
    {
      "text": "Que Rose a fermé la Salle",
      "correct": false
    },
    {
      "text": "Que le tarif n'est pas cité",
      "correct": false
    }
  ],
  "explanation": "à tout le monde, sans rampe ni tarif, est une invitation à se taire"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accessibilité",
      "right": "possibilité réelle d'entrer"
    },
    {
      "left": "tarif",
      "right": "prix du billet, trop parfois haut"
    },
    {
      "left": "implicite",
      "right": "position non criée, lisible"
    },
    {
      "left": "écart",
      "right": "distance entre le mot et la porte"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl ne s'agirait ___ d'un détail, à entendre certains. (ne … que)",
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
    "Il",
    "ne",
    "s'agirait",
    "que",
    "d'un",
    "détail",
    "à",
    "entendre",
    "certains",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "accessibilité",
  "hint": "possibilité réelle d'entrer"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tant est que le bonheur s'industrialise, il se vend déjà, et Hawa Diallo sourit trop large.",
  "correct_sentence": "Si tant est que le bonheur s'industrialise, il se vendrait déjà, et Hawa Diallo sourit trop large.",
  "explanation": "Si tant est que + hypothese : se vendrait (irréel / doute)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/culture-partagee.svg",
      "word": "culture partagee"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/acces-salle.svg",
      "word": "acces salle"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/article-implicite.svg",
      "word": "article implicite"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/billet-doux.svg",
      "word": "billet doux"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « la culture est à tout le monde » et la concession de Hawa Diallo."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'affiche trop généreuse et l'article d'Hawa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le mot, la porte, l''écart',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rédiger un article qui exprime implicitement une position sur l'accès à la Salle. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le mot, la porte, l'écart », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le mot, la porte, l'écart
On parle trop vite de l'accès trop cher à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on dispense d'ouvrir vraiment la porte, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Ce que l'on nomme accessibilité, ici, n'est pas un slogan : possibilité réelle d'entrer.
Hawa : il ne s'agirait que d'un détail, le tarif, à entendre l'affiche.
Loin d'ouvrir, le mot généreux fermait plus net.
Rose coud trop près de la porte.
Aline : l'implicite se justifie par l'écart.
Joël n'entre pas sous la pluie.
Lila lira sans coller un slogan contraire.
Un chiffre, une trace : Hawa a cité le tarif ; la rampe absente ; le mot généreux ; zéro cri.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une position, pas d'une affiche contraire
Patrick veut les faits.
Rose Iradukunda entend, dans « la culture est à tout le monde », ceci qui n'est pas dit : à tout le monde, sans rampe ni tarif, est une invitation à se taire
Autrement dit, l'article ne criera pas : il décrira la porte, le tarif, le mot, et l'écart fera le travail
La proposition qui reste debout est celle-ci : un article implicite : faits, écart, zéro slogan retourné
Marc : une position C2 peut ne pas crier, elle doit se lire.
Nous clôturons sans fusionner les voix : l'affiche trop généreuse d'un côté, l'article d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Signé : Hawa Diallo, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'affiche trop généreuse et l'article d'Hawa en une seule affiche.",
  "correct": true,
  "explanation": "La clôture garde deux voix et le point où elles ne se ressemblent pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il retenir du fait ou du chiffre avancé ?",
  "options": [
    {
      "text": "Rien n'est chiffré, tout est slogan",
      "correct": false
    },
    {
      "text": "Tarif, rampe absente, mot généreux, zéro cri",
      "correct": true
    },
    {
      "text": "Le chiffre annule la concession",
      "correct": false
    },
    {
      "text": "Le micro interdit les traces",
      "correct": false
    }
  ],
  "explanation": "Hawa a cité le tarif ; la rampe absente ; le mot généreux ; zéro cri."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accessibilité",
      "right": "possibilité réelle d'entrer"
    },
    {
      "left": "tarif",
      "right": "prix du billet, trop parfois haut"
    },
    {
      "left": "implicite",
      "right": "position non criée, lisible"
    },
    {
      "left": "écart",
      "right": "distance entre le mot et la porte"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLoin de ___ la cour, le sourire la fatigue. (rassurer)",
  "answer": "rassurer"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Loin",
    "de",
    "rassurer",
    "la",
    "cour",
    "le",
    "sourire",
    "la",
    "fatigue",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tarif",
  "hint": "prix du billet, trop parfois haut"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La accessibilité de trop vite n'aide personne, et Rose Iradukunda reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Rose Iradukunda reprend le fil.",
  "explanation": "Éviter une construction calquée ; préférer un nom d'action juste (précipitation)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/acces-salle.svg",
      "word": "acces salle"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/article-implicite.svg",
      "word": "article implicite"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/billet-doux.svg",
      "word": "billet doux"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/frontieres-rire.svg",
      "word": "frontieres rire"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le mot, la porte, l'écart » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Culture partagée : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : implicite ; accessibilité ; position non criée.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on dispense d'ouvrir vraiment la porte, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Ce que l'on nomme accessibilité, ici, n'est pas un slogan : possibilité réelle d'entrer.
Encore que l'on ouvre, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail.
Hawa Diallo concède que un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Autrement dit, l'article ne criera pas : il décrira la porte, le tarif, le mot, et l'écart fera le travail
Il ressort qu'un article implicite : faits, écart, zéro slogan retourné
Loin d'ouvrir, le mot généreux fermait plus net.
Joël n'entre pas sous la pluie.
La proposition qui reste debout est celle-ci : un article implicite : faits, écart, zéro slogan retourné
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'affiche trop généreuse d'un côté, l'article d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa Diallo transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Hawa Diallo concède que un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Hawa Diallo, et à quelle condition ?",
  "options": [
    {
      "text": "Hawa Diallo n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "un mot généreux peut précéder un geste — à condition que l'on baisse ensuite le billet, ou l'on cesse le mot",
      "correct": true
    },
    {
      "text": "Hawa Diallo abandonne il s'agit d'une position, pas d'une affiche contraire",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on baisse ensuite le billet, ou l'on cesse le mot"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accessibilité",
      "right": "possibilité réelle d'entrer"
    },
    {
      "left": "tarif",
      "right": "prix du billet, trop parfois haut"
    },
    {
      "left": "implicite",
      "right": "position non criée, lisible"
    },
    {
      "left": "écart",
      "right": "distance entre le mot et la porte"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nFût-ce à voix basse, Mado ___ le contraire de ce qu'on affiche. (dire)",
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
    "Fût-ce",
    "à",
    "voix",
    "basse",
    "Mado",
    "dit",
    "le",
    "contraire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "implicite",
  "hint": "position non criée, lisible"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Hawa Diallo écoute encore, et il fautons ouvrir avant de crier.",
  "correct_sentence": "Hawa Diallo écoute encore, et il faut ouvrir avant de crier.",
  "explanation": "Toujours il faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/article-implicite.svg",
      "word": "article implicite"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/billet-doux.svg",
      "word": "billet doux"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/frontieres-rire.svg",
      "word": "frontieres rire"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/scene-comique.svg",
      "word": "scene comique"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur implicite ; accessibilité ; position non criée, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'affiche trop généreuse et l'article d'Hawa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Hawa Diallo',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Rédiger un article qui exprime implicitement une position sur l'accès à la Salle. Point : implicite ; accessibilité ; position non criée.

Consigne
Imitez le texte de Hawa Diallo.

Support — Hawa Diallo — Le mot, la porte, l'écart
Hawa Diallo — Le mot, la porte, l'écart
On parle trop vite de l'accès trop cher à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on dispense d'ouvrir vraiment la porte, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Ce que l'on nomme accessibilité, ici, n'est pas un slogan : possibilité réelle d'entrer.
Hawa : il ne s'agirait que d'un détail, le tarif, à entendre l'affiche.
Joël n'entre pas sous la pluie.
Lila lira sans coller un slogan contraire.
Patrick veut les faits.
La proposition qui reste debout est celle-ci : un article implicite : faits, écart, zéro slogan retourné
Marc : une position C2 peut ne pas crier, elle doit se lire.
Nous clôturons sans fusionner les voix : l'affiche trop généreuse d'un côté, l'article d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on ouvre, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail.
Hawa Diallo concède que un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
l'article ne criera pas : il décrira la porte, le tarif, le mot, et l'écart fera le travail
Hawa Diallo, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un article implicite : faits, écart, zéro slogan retourné",
  "correct": true,
  "explanation": "un article implicite : faits, écart, zéro slogan retourné"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle proposition reste debout à la fin ?",
  "options": [
    {
      "text": "Fusionner les deux documents en une affiche",
      "correct": false
    },
    {
      "text": "un article implicite : faits, écart, zéro slogan retourné",
      "correct": true
    },
    {
      "text": "Interdire toute nominalisation",
      "correct": false
    },
    {
      "text": "Couper le micro de Lila",
      "correct": false
    }
  ],
  "explanation": "un article implicite : faits, écart, zéro slogan retourné"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accessibilité",
      "right": "possibilité réelle d'entrer"
    },
    {
      "left": "tarif",
      "right": "prix du billet, trop parfois haut"
    },
    {
      "left": "implicite",
      "right": "position non criée, lisible"
    },
    {
      "left": "écart",
      "right": "distance entre le mot et la porte"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi tant est que le bonheur s'___, il se vendrait déjà sous le figuier. (industrialiser)",
  "answer": "industrialise"
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
    "tant",
    "est",
    "que",
    "le",
    "bonheur",
    "s'industrialise",
    "il",
    "se",
    "vendrait",
    "déjà",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "écart",
  "hint": "distance entre le mot et la porte"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Hawa Diallo est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Hawa Diallo sont clairs, et Lila garde le micro ouvert.",
  "explanation": "Accord : les arguments sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/billet-doux.svg",
      "word": "billet doux"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/frontieres-rire.svg",
      "word": "frontieres rire"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/scene-comique.svg",
      "word": "scene comique"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/humour-seuil.svg",
      "word": "humour seuil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Hawa Diallo : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — implicite ; accessibilité ; position non criée',
    'EL',
    $c$Objectif
Maîtriser implicite ; accessibilité ; position non criée au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — implicite ; accessibilité ; position non criée
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on ouvre, un billet trop haut pour Hawa, un mot trop généreux n'est pas un détail.
Hawa Diallo concède que un mot généreux peut précéder un geste, pour autant que l'on baisse ensuite le billet, ou l'on cesse le mot.
Autrement dit, l'article ne criera pas : il décrira la porte, le tarif, le mot, et l'écart fera le travail
Il ressort qu'un article implicite : faits, écart, zéro slogan retourné
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme accessibilité, ici, n'est pas un slogan : possibilité réelle d'entrer.
Loin d'ouvrir, le mot généreux fermait plus net.
Joël n'entre pas sous la pluie.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au implicite pour de vrai genre, et Rose Iradukunda demande un registre plus net.
Correction : On va au implicite vraiment, et Rose Iradukunda demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'ironie peut dire le contraire de ce qu'elle affirme.",
  "correct": true,
  "explanation": "Antiphrase possible."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Il ne s'agirait que d'un détail » est souvent…",
  "options": [
    {
      "text": "une preuve que c'est un détail",
      "correct": false
    },
    {
      "text": "un sous-entendu, parfois ironique",
      "correct": true
    },
    {
      "text": "un passé simple",
      "correct": false
    },
    {
      "text": "un ordre",
      "correct": false
    }
  ],
  "explanation": "Understatement / ironie."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accessibilité",
      "right": "possibilité réelle d'entrer"
    },
    {
      "left": "tarif",
      "right": "prix du billet, trop parfois haut"
    },
    {
      "left": "implicite",
      "right": "position non criée, lisible"
    },
    {
      "left": "écart",
      "right": "distance entre le mot et la porte"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'___ n'est pas un rire : c'est un écart entre le dit et le visé. (ironie)",
  "answer": "ironie"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "L'ironie",
    "n'est",
    "pas",
    "un",
    "rire",
    "c'est",
    "un",
    "écart",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "collocation",
  "hint": "Précision du discours, sans nommer le mot-cible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On va au implicite pour de vrai genre, et Rose Iradukunda demande un registre plus net.",
  "correct_sentence": "On va au implicite vraiment, et Rose Iradukunda demande un registre plus net.",
  "explanation": "Registre : éviter le marqueur trop oral « genre » dans un écrit soutenu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/frontieres-rire.svg",
      "word": "frontieres rire"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/scene-comique.svg",
      "word": "scene comique"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/humour-seuil.svg",
      "word": "humour seuil"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/masque-rire.svg",
      "word": "masque rire"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « implicite ; accessibilité ; position non criée » et deux pièges commentés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre phrases justes au registre demandé."
}$j$::jsonb,
    9
  );

  -- ===== Qui paie le rire =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Qui paie le rire'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Qui paie le rire', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Qui paie le rire',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Expliquer une scène comique de cour sans en faire une recette, ni un procès. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Qui paie le rire
Lila Sow : Radio Figuier. On parle trop vite de un sketch trop sûr de ses cibles, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on tienne lieu de droit de blesser, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Sami concède que un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Aline Uwase : Ce que l'on nomme ressort, ici, n'est pas un slogan : mécanisme comique, à expliquer.
Patrick Habimana : Sami : loin de tout permettre, l'humour se juge à la cible.
Hawa Diallo : Hawa n'a pas ri, et le non compte.
Joël Mugisha : Aline explique le quiproquo sans recette.
Rose Iradukunda : Lila n'enregistrera pas la version trop dure.
Solange Mukamana : Yvette rit du quiproquo, pas de la bouche trop seule.
Karim Bamba : Patrick refuse le succès comme preuve.
Félicie Ndayishimiye : Un chiffre, une trace : Sami a raturé une cible ; gardé un quiproquo ; Yvette a ri ; Hawa non, et c'est noté.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de rire avec une cour, pas contre une bouche trop seule
Yvette : Mado note le ressort.
Mado : Hawa Diallo entend, dans « c'est de l'humour », ceci qui n'est pas dit : c'est de l'humour arrive trop souvent après le geste qui a déjà fait mal
Sami : Autrement dit, expliquer un ressort, c'est dire qui paie le rire, et si le succès n'est qu'un confort
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une explication : quiproquo, cible, limite, version raturée
Nina Kayitesi : Marc : une scène comique C2 a une limite, ou n'est qu'un confort.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le sketch trop dur d'un côté, la version raturée de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : C'est de l'humour : on reconnaît le sauf-conduit de ceux qui n'ont pas à essuyer.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un rire qui n'a plus d'oreille pour Hawa est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un rire qui n'a plus d'oreille pour Hawa n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Hawa Diallo, que reste-t-il implicite dans « c'est de l'humour » ?",
  "options": [
    {
      "text": "Que Sami a humilié Hawa à l'antenne",
      "correct": false
    },
    {
      "text": "Après le geste qui a déjà fait mal",
      "correct": true
    },
    {
      "text": "Que Yvette a interdit le rire",
      "correct": false
    },
    {
      "text": "Que le quiproquo a disparu",
      "correct": false
    }
  ],
  "explanation": "c'est de l'humour arrive trop souvent après le geste qui a déjà fait mal"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ressort",
      "right": "mécanisme comique, à expliquer"
    },
    {
      "left": "cible",
      "right": "personne visée, trop souvent la même"
    },
    {
      "left": "quiproquo",
      "right": "malentendu comique, parfois juste"
    },
    {
      "left": "succès",
      "right": "rire facile, pas une preuve morale"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl ne s'agirait ___ d'un détail, à entendre certains. (ne … que)",
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
    "Il",
    "ne",
    "s'agirait",
    "que",
    "d'un",
    "détail",
    "à",
    "entendre",
    "certains",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ressort",
  "hint": "mécanisme comique, à expliquer"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tant est que le bonheur s'industrialise, il se vend déjà, et Sami sourit trop large.",
  "correct_sentence": "Si tant est que le bonheur s'industrialise, il se vendrait déjà, et Sami sourit trop large.",
  "explanation": "Si tant est que + hypothese : se vendrait (irréel / doute)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/scene-comique.svg",
      "word": "scene comique"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/humour-seuil.svg",
      "word": "humour seuil"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/masque-rire.svg",
      "word": "masque rire"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/porteurs-identite.svg",
      "word": "porteurs identite"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « c'est de l'humour » et la concession de Sami."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le sketch trop dur et la version raturée distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Qui paie le rire',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Expliquer une scène comique de cour sans en faire une recette, ni un procès. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Qui paie le rire », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Qui paie le rire
On parle trop vite de un sketch trop sûr de ses cibles, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu de droit de blesser, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Ce que l'on nomme ressort, ici, n'est pas un slogan : mécanisme comique, à expliquer.
Sami : loin de tout permettre, l'humour se juge à la cible.
Hawa n'a pas ri, et le non compte.
Aline explique le quiproquo sans recette.
Lila n'enregistrera pas la version trop dure.
Yvette rit du quiproquo, pas de la bouche trop seule.
Patrick refuse le succès comme preuve.
Un chiffre, une trace : Sami a raturé une cible ; gardé un quiproquo ; Yvette a ri ; Hawa non, et c'est noté.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de rire avec une cour, pas contre une bouche trop seule
Mado note le ressort.
Hawa Diallo entend, dans « c'est de l'humour », ceci qui n'est pas dit : c'est de l'humour arrive trop souvent après le geste qui a déjà fait mal
Autrement dit, expliquer un ressort, c'est dire qui paie le rire, et si le succès n'est qu'un confort
La proposition qui reste debout est celle-ci : une explication : quiproquo, cible, limite, version raturée
Marc : une scène comique C2 a une limite, ou n'est qu'un confort.
Nous clôturons sans fusionner les voix : le sketch trop dur d'un côté, la version raturée de l'autre, et le point où elles refusent de se ressembler.
Signé : Sami, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le sketch trop dur et la version raturée en une seule affiche.",
  "correct": true,
  "explanation": "La clôture garde deux voix et le point où elles ne se ressemblent pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il retenir du fait ou du chiffre avancé ?",
  "options": [
    {
      "text": "Rien n'est chiffré, tout est slogan",
      "correct": false
    },
    {
      "text": "Une cible raturée, un quiproquo, un rire, un non",
      "correct": true
    },
    {
      "text": "Le chiffre annule la concession",
      "correct": false
    },
    {
      "text": "Le micro interdit les traces",
      "correct": false
    }
  ],
  "explanation": "Sami a raturé une cible ; gardé un quiproquo ; Yvette a ri ; Hawa non, et c'est noté."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ressort",
      "right": "mécanisme comique, à expliquer"
    },
    {
      "left": "cible",
      "right": "personne visée, trop souvent la même"
    },
    {
      "left": "quiproquo",
      "right": "malentendu comique, parfois juste"
    },
    {
      "left": "succès",
      "right": "rire facile, pas une preuve morale"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLoin de ___ la cour, le sourire la fatigue. (rassurer)",
  "answer": "rassurer"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Loin",
    "de",
    "rassurer",
    "la",
    "cour",
    "le",
    "sourire",
    "la",
    "fatigue",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "cible",
  "hint": "personne visée, trop souvent la même"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La ressort de trop vite n'aide personne, et Hawa Diallo reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Hawa Diallo reprend le fil.",
  "explanation": "Éviter une construction calquée ; préférer un nom d'action juste (précipitation)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/humour-seuil.svg",
      "word": "humour seuil"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/masque-rire.svg",
      "word": "masque rire"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/porteurs-identite.svg",
      "word": "porteurs identite"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/debat-emprunt.svg",
      "word": "debat emprunt"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Qui paie le rire » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Qui paie le rire : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : ressorts comiques ; humour ; succès trop facile.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on tienne lieu de droit de blesser, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Ce que l'on nomme ressort, ici, n'est pas un slogan : mécanisme comique, à expliquer.
Encore que l'on rature, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail.
Sami concède que un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Autrement dit, expliquer un ressort, c'est dire qui paie le rire, et si le succès n'est qu'un confort
Il ressort qu'une explication : quiproquo, cible, limite, version raturée
Hawa n'a pas ri, et le non compte.
Yvette rit du quiproquo, pas de la bouche trop seule.
La proposition qui reste debout est celle-ci : une explication : quiproquo, cible, limite, version raturée
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le sketch trop dur d'un côté, la version raturée de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Sami transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Sami concède que un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Sami, et à quelle condition ?",
  "options": [
    {
      "text": "Sami n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "un sketch peut dénoncer — à condition que l'on n'y visse pas toujours le même visage",
      "correct": true
    },
    {
      "text": "Sami abandonne il s'agit de rire avec une cour, pas contre une bouche trop seule",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y visse pas toujours le même visage"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ressort",
      "right": "mécanisme comique, à expliquer"
    },
    {
      "left": "cible",
      "right": "personne visée, trop souvent la même"
    },
    {
      "left": "quiproquo",
      "right": "malentendu comique, parfois juste"
    },
    {
      "left": "succès",
      "right": "rire facile, pas une preuve morale"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nFût-ce à voix basse, Mado ___ le contraire de ce qu'on affiche. (dire)",
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
    "Fût-ce",
    "à",
    "voix",
    "basse",
    "Mado",
    "dit",
    "le",
    "contraire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "quiproquo",
  "hint": "malentendu comique, parfois juste"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Sami écoute encore, et il fautons raturer avant de crier.",
  "correct_sentence": "Sami écoute encore, et il faut raturer avant de crier.",
  "explanation": "Toujours il faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/masque-rire.svg",
      "word": "masque rire"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/porteurs-identite.svg",
      "word": "porteurs identite"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/debat-emprunt.svg",
      "word": "debat emprunt"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/tendance-peau.svg",
      "word": "tendance peau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur ressorts comiques ; humour ; succès trop facile, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le sketch trop dur et la version raturée distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Sami',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Expliquer une scène comique de cour sans en faire une recette, ni un procès. Point : ressorts comiques ; humour ; succès trop facile.

Consigne
Imitez le texte de Sami.

Support — Sami — Qui paie le rire
Sami — Qui paie le rire
On parle trop vite de un sketch trop sûr de ses cibles, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu de droit de blesser, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Ce que l'on nomme ressort, ici, n'est pas un slogan : mécanisme comique, à expliquer.
Sami : loin de tout permettre, l'humour se juge à la cible.
Yvette rit du quiproquo, pas de la bouche trop seule.
Patrick refuse le succès comme preuve.
Mado note le ressort.
La proposition qui reste debout est celle-ci : une explication : quiproquo, cible, limite, version raturée
Marc : une scène comique C2 a une limite, ou n'est qu'un confort.
Nous clôturons sans fusionner les voix : le sketch trop dur d'un côté, la version raturée de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on rature, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail.
Sami concède que un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
expliquer un ressort, c'est dire qui paie le rire, et si le succès n'est qu'un confort
Sami, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : une explication : quiproquo, cible, limite, version raturée",
  "correct": true,
  "explanation": "une explication : quiproquo, cible, limite, version raturée"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle proposition reste debout à la fin ?",
  "options": [
    {
      "text": "Fusionner les deux documents en une affiche",
      "correct": false
    },
    {
      "text": "une explication : quiproquo, cible, limite, version raturée",
      "correct": true
    },
    {
      "text": "Interdire toute nominalisation",
      "correct": false
    },
    {
      "text": "Couper le micro de Lila",
      "correct": false
    }
  ],
  "explanation": "une explication : quiproquo, cible, limite, version raturée"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ressort",
      "right": "mécanisme comique, à expliquer"
    },
    {
      "left": "cible",
      "right": "personne visée, trop souvent la même"
    },
    {
      "left": "quiproquo",
      "right": "malentendu comique, parfois juste"
    },
    {
      "left": "succès",
      "right": "rire facile, pas une preuve morale"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi tant est que le bonheur s'___, il se vendrait déjà sous le figuier. (industrialiser)",
  "answer": "industrialise"
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
    "tant",
    "est",
    "que",
    "le",
    "bonheur",
    "s'industrialise",
    "il",
    "se",
    "vendrait",
    "déjà",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "succès",
  "hint": "rire facile, pas une preuve morale"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Sami est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Sami sont clairs, et Lila garde le micro ouvert.",
  "explanation": "Accord : les arguments sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/porteurs-identite.svg",
      "word": "porteurs identite"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/debat-emprunt.svg",
      "word": "debat emprunt"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/tendance-peau.svg",
      "word": "tendance peau"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/tissu-signe.svg",
      "word": "tissu signe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Sami : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — ressorts comiques ; humour ; succès trop facile',
    'EL',
    $c$Objectif
Maîtriser ressorts comiques ; humour ; succès trop facile au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — ressorts comiques ; humour ; succès trop facile
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on rature, un rire qui n'a plus d'oreille pour Hawa n'est pas un détail.
Sami concède que un sketch peut dénoncer, pour autant que l'on n'y visse pas toujours le même visage.
Autrement dit, expliquer un ressort, c'est dire qui paie le rire, et si le succès n'est qu'un confort
Il ressort qu'une explication : quiproquo, cible, limite, version raturée
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme ressort, ici, n'est pas un slogan : mécanisme comique, à expliquer.
Hawa n'a pas ri, et le non compte.
Yvette rit du quiproquo, pas de la bouche trop seule.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au quiproquo pour de vrai genre, et Hawa Diallo demande un registre plus net.
Correction : On va au quiproquo vraiment, et Hawa Diallo demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'ironie peut dire le contraire de ce qu'elle affirme.",
  "correct": true,
  "explanation": "Antiphrase possible."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Il ne s'agirait que d'un détail » est souvent…",
  "options": [
    {
      "text": "une preuve que c'est un détail",
      "correct": false
    },
    {
      "text": "un sous-entendu, parfois ironique",
      "correct": true
    },
    {
      "text": "un passé simple",
      "correct": false
    },
    {
      "text": "un ordre",
      "correct": false
    }
  ],
  "explanation": "Understatement / ironie."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ressort",
      "right": "mécanisme comique, à expliquer"
    },
    {
      "left": "cible",
      "right": "personne visée, trop souvent la même"
    },
    {
      "left": "quiproquo",
      "right": "malentendu comique, parfois juste"
    },
    {
      "left": "succès",
      "right": "rire facile, pas une preuve morale"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'___ n'est pas un rire : c'est un écart entre le dit et le visé. (ironie)",
  "answer": "ironie"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "L'ironie",
    "n'est",
    "pas",
    "un",
    "rire",
    "c'est",
    "un",
    "écart",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "collocation",
  "hint": "Précision du discours, sans nommer le mot-cible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On va au quiproquo pour de vrai genre, et Hawa Diallo demande un registre plus net.",
  "correct_sentence": "On va au quiproquo vraiment, et Hawa Diallo demande un registre plus net.",
  "explanation": "Registre : éviter le marqueur trop oral « genre » dans un écrit soutenu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/debat-emprunt.svg",
      "word": "debat emprunt"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/tendance-peau.svg",
      "word": "tendance peau"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/tissu-signe.svg",
      "word": "tissu signe"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/recit-interculturel.svg",
      "word": "recit interculturel"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « ressorts comiques ; humour ; succès trop facile » et deux pièges commentés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre phrases justes au registre demandé."
}$j$::jsonb,
    9
  );

  -- ===== Le lin trop vite porté =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Le lin trop vite porté'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Le lin trop vite porté', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le lin trop vite porté',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Débattre d'un lin trop vite porté comme décor, sans procès d'intention plat. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le lin trop vite porté
Lila Sow : Radio Figuier. On parle trop vite de un lin de Rose trop vite copié, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on dispense de demander à Rose, une tendance qui vide un signe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas.
Aline Uwase : Ce que l'on nomme signe, ici, n'est pas un slogan : motif chargé, distinct d'un décor.
Patrick Habimana : Rose : du fait que le lin plaît, si bien que l'on copie, il ne s'ensuit pas un droit.
Hawa Diallo : Léa ouvre le débat, pas le procès plat.
Joël Mugisha : Aline exige la permission comme mot.
Rose Iradukunda : Karim parle de prix.
Solange Mukamana : Sami avait porté trop vite ; il retire.
Karim Bamba : Lila n'adoucira pas.
Félicie Ndayishimiye : Un chiffre, une trace : Rose a vu six copies trop nettes ; zéro demande ; un hommage trop tardif.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'un signe, pas d'une mode d'affiche
Yvette : Patrick refuse hommage comme sauf-conduit.
Mado : Léa Niyonzima entend, dans « c'est un hommage », ceci qui n'est pas dit : hommage trop vite dit évite le prix, la source, la permission
Sami : Autrement dit, du fait que le lin circule, il ne s'ensuit pas qu'il soit un décor libre
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un débat : inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)
Nina Kayitesi : Marc : un débat C2 nomme le vide, pas seulement l'intention.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les copies trop nettes d'un côté, la prise de parole de Rose de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : C'est un hommage : on vérifiera s'il a traversé, par hasard, une caisse.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une tendance qui vide un signe est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une tendance qui vide un signe n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Léa Niyonzima, que reste-t-il implicite dans « c'est un hommage » ?",
  "options": [
    {
      "text": "Que Rose interdit toute inspiration",
      "correct": false
    },
    {
      "text": "Éviter le prix, la source, la permission",
      "correct": true
    },
    {
      "text": "Que Léa a vendu les copies",
      "correct": false
    },
    {
      "text": "Que l'hommage était daté avant les copies",
      "correct": false
    }
  ],
  "explanation": "hommage trop vite dit évite le prix, la source, la permission"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "signe",
      "right": "motif chargé, distinct d'un décor"
    },
    {
      "left": "inspiration",
      "right": "emprunt avoué, parfois juste"
    },
    {
      "left": "permission",
      "right": "demande à Rose, trop souvent sautée"
    },
    {
      "left": "tendance",
      "right": "mode qui peut vider un motif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDu fait que le prix ___, la colère n'est pas un caprice. (flamber)",
  "answer": "flambe"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Du",
    "fait",
    "que",
    "le",
    "prix",
    "flambe",
    "la",
    "colère",
    "n'est",
    "pas",
    "un",
    "caprice",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "signe",
  "hint": "motif chargé, distinct d'un décor"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Du fait que le prix flambent, Rose Iradukunda refuse d'appeler cela un caprice, et Oscar écoute.",
  "correct_sentence": "Du fait que le prix flambe, Rose Iradukunda refuse d'appeler cela un caprice, et Oscar écoute.",
  "explanation": "Le prix flambe, singulier."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/tendance-peau.svg",
      "word": "tendance peau"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/tissu-signe.svg",
      "word": "tissu signe"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/recit-interculturel.svg",
      "word": "recit interculturel"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/difference-fine.svg",
      "word": "difference fine"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « c'est un hommage » et la concession de Rose Iradukunda."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les copies trop nettes et la prise de parole de Rose distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Un signe n''est pas un décor',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Débattre d'un lin trop vite porté comme décor, sans procès d'intention plat. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Un signe n'est pas un décor », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Un signe n'est pas un décor
On parle trop vite de un lin de Rose trop vite copié, comme si le mot dispensait d'en examiner le prix.
Encore que l'on dispense de demander à Rose, une tendance qui vide un signe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas.
Ce que l'on nomme signe, ici, n'est pas un slogan : motif chargé, distinct d'un décor.
Rose : du fait que le lin plaît, si bien que l'on copie, il ne s'ensuit pas un droit.
Léa ouvre le débat, pas le procès plat.
Aline exige la permission comme mot.
Karim parle de prix.
Sami avait porté trop vite ; il retire.
Lila n'adoucira pas.
Un chiffre, une trace : Rose a vu six copies trop nettes ; zéro demande ; un hommage trop tardif.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'un signe, pas d'une mode d'affiche
Patrick refuse hommage comme sauf-conduit.
Léa Niyonzima entend, dans « c'est un hommage », ceci qui n'est pas dit : hommage trop vite dit évite le prix, la source, la permission
Autrement dit, du fait que le lin circule, il ne s'ensuit pas qu'il soit un décor libre
La proposition qui reste debout est celle-ci : un débat : inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)
Marc : un débat C2 nomme le vide, pas seulement l'intention.
Nous clôturons sans fusionner les voix : les copies trop nettes d'un côté, la prise de parole de Rose de l'autre, et le point où elles refusent de se ressembler.
Signé : Rose Iradukunda, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les copies trop nettes et la prise de parole de Rose en une seule affiche.",
  "correct": true,
  "explanation": "La clôture garde deux voix et le point où elles ne se ressemblent pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il retenir du fait ou du chiffre avancé ?",
  "options": [
    {
      "text": "Rien n'est chiffré, tout est slogan",
      "correct": false
    },
    {
      "text": "Six copies, zéro demande, hommage trop tardif",
      "correct": true
    },
    {
      "text": "Le chiffre annule la concession",
      "correct": false
    },
    {
      "text": "Le micro interdit les traces",
      "correct": false
    }
  ],
  "explanation": "Rose a vu six copies trop nettes ; zéro demande ; un hommage trop tardif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "signe",
      "right": "motif chargé, distinct d'un décor"
    },
    {
      "left": "inspiration",
      "right": "emprunt avoué, parfois juste"
    },
    {
      "left": "permission",
      "right": "demande à Rose, trop souvent sautée"
    },
    {
      "left": "tendance",
      "right": "mode qui peut vider un motif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi bien que les jardiniers ___ la rive. (quitter, fut. ou prés.)",
  "answer": "quittent"
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
    "bien",
    "que",
    "les",
    "jardiniers",
    "quittent",
    "la",
    "rive",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "inspiration",
  "hint": "emprunt avoué, parfois juste"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La signe de trop vite n'aide personne, et Léa Niyonzima reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Léa Niyonzima reprend le fil.",
  "explanation": "Éviter une construction calquée ; préférer un nom d'action juste (précipitation)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/tissu-signe.svg",
      "word": "tissu signe"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/recit-interculturel.svg",
      "word": "recit interculturel"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/difference-fine.svg",
      "word": "difference fine"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/passe-detaille.svg",
      "word": "passe detaille"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Un signe n'est pas un décor » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Le lin trop vite porté : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : débat ; appropriation ; tendance trop vite portée.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on dispense de demander à Rose, une tendance qui vide un signe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas.
Ce que l'on nomme signe, ici, n'est pas un slogan : motif chargé, distinct d'un décor.
Encore que l'on demande, une tendance qui vide un signe n'est pas un détail.
Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas.
Autrement dit, du fait que le lin circule, il ne s'ensuit pas qu'il soit un décor libre
Il ressort qu'un débat : inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)
Léa ouvre le débat, pas le procès plat.
Sami avait porté trop vite ; il retire.
La proposition qui reste debout est celle-ci : un débat : inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les copies trop nettes d'un côté, la prise de parole de Rose de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose Iradukunda transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Rose Iradukunda, et à quelle condition ?",
  "options": [
    {
      "text": "Rose Iradukunda n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "s'inspirer peut être juste — à condition que l'on nomme, l'on demande, l'on ne vide pas",
      "correct": true
    },
    {
      "text": "Rose Iradukunda abandonne il s'agit d'un signe, pas d'une mode d'affiche",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on nomme, l'on demande, l'on ne vide pas"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "signe",
      "right": "motif chargé, distinct d'un décor"
    },
    {
      "left": "inspiration",
      "right": "emprunt avoué, parfois juste"
    },
    {
      "left": "permission",
      "right": "demande à Rose, trop souvent sautée"
    },
    {
      "left": "tendance",
      "right": "mode qui peut vider un motif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le marché ___ ouvert, la terre n'est pas payée. (être, subj.)",
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
    "Encore",
    "que",
    "le",
    "marché",
    "soit",
    "ouvert",
    "la",
    "terre",
    "n'est",
    "pas",
    "payée",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "permission",
  "hint": "demande à Rose, trop souvent sautée"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Rose Iradukunda écoute encore, et il fautons demander avant de crier.",
  "correct_sentence": "Rose Iradukunda écoute encore, et il faut demander avant de crier.",
  "explanation": "Toujours il faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/recit-interculturel.svg",
      "word": "recit interculturel"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/difference-fine.svg",
      "word": "difference fine"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/passe-detaille.svg",
      "word": "passe detaille"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/valise-langue.svg",
      "word": "valise langue"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur débat ; appropriation ; tendance trop vite portée, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les copies trop nettes et la prise de parole de Rose distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Rose Iradukunda',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Débattre d'un lin trop vite porté comme décor, sans procès d'intention plat. Point : débat ; appropriation ; tendance trop vite portée.

Consigne
Imitez le texte de Rose Iradukunda.

Support — Rose Iradukunda — Un signe n'est pas un décor
Rose Iradukunda — Un signe n'est pas un décor
On parle trop vite de un lin de Rose trop vite copié, comme si le mot dispensait d'en examiner le prix.
Encore que l'on dispense de demander à Rose, une tendance qui vide un signe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas.
Ce que l'on nomme signe, ici, n'est pas un slogan : motif chargé, distinct d'un décor.
Rose : du fait que le lin plaît, si bien que l'on copie, il ne s'ensuit pas un droit.
Sami avait porté trop vite ; il retire.
Lila n'adoucira pas.
Patrick refuse hommage comme sauf-conduit.
La proposition qui reste debout est celle-ci : un débat : inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)
Marc : un débat C2 nomme le vide, pas seulement l'intention.
Nous clôturons sans fusionner les voix : les copies trop nettes d'un côté, la prise de parole de Rose de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on demande, une tendance qui vide un signe n'est pas un détail.
Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
du fait que le lin circule, il ne s'ensuit pas qu'il soit un décor libre
Rose Iradukunda, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un débat : inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)",
  "correct": true,
  "explanation": "un débat : inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle proposition reste debout à la fin ?",
  "options": [
    {
      "text": "Fusionner les deux documents en une affiche",
      "correct": false
    },
    {
      "text": "un débat : inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)",
      "correct": true
    },
    {
      "text": "Interdire toute nominalisation",
      "correct": false
    },
    {
      "text": "Couper le micro de Lila",
      "correct": false
    }
  ],
  "explanation": "un débat : inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "signe",
      "right": "motif chargé, distinct d'un décor"
    },
    {
      "left": "inspiration",
      "right": "emprunt avoué, parfois juste"
    },
    {
      "left": "permission",
      "right": "demande à Rose, trop souvent sautée"
    },
    {
      "left": "tendance",
      "right": "mode qui peut vider un motif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl s'ensuit une ___ des files, non un silence. (nominalisation de allonger)",
  "answer": "allongement"
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
    "fait",
    "de",
    "société",
    "se",
    "commente",
    "il",
    "ne",
    "se",
    "crie",
    "pas",
    "seulement",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tendance",
  "hint": "mode qui peut vider un motif"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Rose Iradukunda est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Rose Iradukunda sont clairs, et Lila garde le micro ouvert.",
  "explanation": "Accord : les arguments sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/difference-fine.svg",
      "word": "difference fine"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/passe-detaille.svg",
      "word": "passe detaille"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/valise-langue.svg",
      "word": "valise langue"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/position-implicite.svg",
      "word": "position implicite"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Rose Iradukunda : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — débat ; appropriation ; tendance trop vite portée',
    'EL',
    $c$Objectif
Maîtriser débat ; appropriation ; tendance trop vite portée au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — débat ; appropriation ; tendance trop vite portée
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on demande, une tendance qui vide un signe n'est pas un détail.
Rose Iradukunda concède que s'inspirer peut être juste, pour autant que l'on nomme, l'on demande, l'on ne vide pas.
Autrement dit, du fait que le lin circule, il ne s'ensuit pas qu'il soit un décor libre
Il ressort qu'un débat : inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)
Piège : confusion cause / concession
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme signe, ici, n'est pas un slogan : motif chargé, distinct d'un décor.
Léa ouvre le débat, pas le procès plat.
Sami avait porté trop vite ; il retire.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au permission pour de vrai genre, et Léa Niyonzima demande un registre plus net.
Correction : On va au permission vraiment, et Léa Niyonzima demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Si bien que » introduit une conséquence.",
  "correct": true,
  "explanation": "Conséquence."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Du fait que » introduit…",
  "options": [
    {
      "text": "une concession",
      "correct": false
    },
    {
      "text": "une cause",
      "correct": true
    },
    {
      "text": "un but",
      "correct": false
    },
    {
      "text": "une hypotypose",
      "correct": false
    }
  ],
  "explanation": "Cause."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "signe",
      "right": "motif chargé, distinct d'un décor"
    },
    {
      "left": "inspiration",
      "right": "emprunt avoué, parfois juste"
    },
    {
      "left": "permission",
      "right": "demande à Rose, trop souvent sautée"
    },
    {
      "left": "tendance",
      "right": "mode qui peut vider un motif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn impute la hausse à inspiration, non au bol. (mot de la séquence)",
  "answer": "inspiration"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Rose",
    "impute",
    "la",
    "hausse",
    "à",
    "inspiration",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "collocation",
  "hint": "Précision du discours, sans nommer le mot-cible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On va au permission pour de vrai genre, et Léa Niyonzima demande un registre plus net.",
  "correct_sentence": "On va au permission vraiment, et Léa Niyonzima demande un registre plus net.",
  "explanation": "Registre : éviter le marqueur trop oral « genre » dans un écrit soutenu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/passe-detaille.svg",
      "word": "passe detaille"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/valise-langue.svg",
      "word": "valise langue"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/position-implicite.svg",
      "word": "position implicite"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/initiative-cour.svg",
      "word": "initiative cour"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « débat ; appropriation ; tendance trop vite portée » et deux pièges commentés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre phrases justes au registre demandé."
}$j$::jsonb,
    9
  );

  -- ===== Récit interculturel =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Récit interculturel'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Récit interculturel', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Récit interculturel',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Raconter une expérience interculturelle au Seuil, détaillée, sans figer l'autre. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Récit interculturel
Lila Sow : Radio Figuier. On parle trop vite de les premiers mois d'Hawa au Pavillon, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on fige Hawa en exemple, un récit trop typique pour rester une vie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Aline Uwase : Ce que l'on nomme malentendu, ici, n'est pas un slogan : écart de lecture, corrigeable.
Patrick Habimana : Hawa avait déjà posé la valise quand on lui a dit chez eux.
Hawa Diallo : Dieudonné avait cru bien faire avec le thé trop tôt.
Joël Mugisha : Il ressort deux corrections, pas une leçon.
Rose Iradukunda : Aline refuse l'ethnologie de banc.
Solange Mukamana : Lila n'adoucira pas le eux.
Karim Bamba : Rose coud un ourlet trop large encore.
Félicie Ndayishimiye : Un chiffre, une trace : Hawa a daté onze semaines ; trois malentendus ; deux corrections ; zéro essence.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une personne, pas d'une vitrine culturelle
Yvette : Patrick veut les onze semaines.
Mado : Dieudonné Hakizimana entend, dans « chez eux c'est comme ça », ceci qui n'est pas dit : chez eux c'est comme ça évite de dire chez nous aussi, et moi
Sami : Autrement dit, selon Hawa, la clé manquait ; d'après Dieudonné, le thé était trop tôt ; il ressort une vie, pas un type
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un récit : dates, gestes, malentendus, corrections, zéro chez eux trop large
Nina Kayitesi : Marc : un récit C2 se juge à ce qu'il n'a pas figé.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les notes trop typiques d'un voisin d'un côté, le récit d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Chez eux c'est comme ça : on admirera la géographie, si commode, du eux.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un récit trop typique pour rester une vie est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un récit trop typique pour rester une vie n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Dieudonné Hakizimana, que reste-t-il implicite dans « chez eux c'est comme ça » ?",
  "options": [
    {
      "text": "Que Hawa a figé Dieudonné",
      "correct": false
    },
    {
      "text": "Éviter le moi, figer le eux",
      "correct": true
    },
    {
      "text": "Que le récit n'a pas de dates",
      "correct": false
    },
    {
      "text": "Que chez eux a été gardé comme titre",
      "correct": false
    }
  ],
  "explanation": "chez eux c'est comme ça évite de dire chez nous aussi, et moi"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "malentendu",
      "right": "écart de lecture, corrigeable"
    },
    {
      "left": "essence",
      "right": "figement, à refuser"
    },
    {
      "left": "récit",
      "right": "suite datée, détaillée"
    },
    {
      "left": "correction",
      "right": "geste qui défait le type"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSelon Hawa, il ___ que deux documents s'opposent. (ressortir)",
  "answer": "ressort"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Selon",
    "Hawa",
    "il",
    "ressort",
    "que",
    "deux",
    "documents",
    "s'opposent",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "malentendu",
  "hint": "écart de lecture, corrigeable"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Selon Hawa Diallo, il ressort que les deux textes est d'accord, et Lila coupe le micro.",
  "correct_sentence": "Selon Hawa Diallo, il ressort que les deux textes sont d'accord, et Lila coupe le micro.",
  "explanation": "Accord : les deux textes sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/valise-langue.svg",
      "word": "valise langue"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/position-implicite.svg",
      "word": "position implicite"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/initiative-cour.svg",
      "word": "initiative cour"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/micro-cultures.svg",
      "word": "micro cultures"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « chez eux c'est comme ça » et la concession de Hawa Diallo."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les notes trop typiques d'un voisin et le récit d'Hawa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Une vie, pas un type',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Raconter une expérience interculturelle au Seuil, détaillée, sans figer l'autre. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Une vie, pas un type », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Une vie, pas un type
On parle trop vite de les premiers mois d'Hawa au Pavillon, comme si le mot dispensait d'en examiner le prix.
Encore que l'on fige Hawa en exemple, un récit trop typique pour rester une vie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Ce que l'on nomme malentendu, ici, n'est pas un slogan : écart de lecture, corrigeable.
Hawa avait déjà posé la valise quand on lui a dit chez eux.
Dieudonné avait cru bien faire avec le thé trop tôt.
Il ressort deux corrections, pas une leçon.
Aline refuse l'ethnologie de banc.
Lila n'adoucira pas le eux.
Rose coud un ourlet trop large encore.
Un chiffre, une trace : Hawa a daté onze semaines ; trois malentendus ; deux corrections ; zéro essence.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une personne, pas d'une vitrine culturelle
Patrick veut les onze semaines.
Dieudonné Hakizimana entend, dans « chez eux c'est comme ça », ceci qui n'est pas dit : chez eux c'est comme ça évite de dire chez nous aussi, et moi
Autrement dit, selon Hawa, la clé manquait ; d'après Dieudonné, le thé était trop tôt ; il ressort une vie, pas un type
La proposition qui reste debout est celle-ci : un récit : dates, gestes, malentendus, corrections, zéro chez eux trop large
Marc : un récit C2 se juge à ce qu'il n'a pas figé.
Nous clôturons sans fusionner les voix : les notes trop typiques d'un voisin d'un côté, le récit d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Signé : Hawa Diallo, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les notes trop typiques d'un voisin et le récit d'Hawa en une seule affiche.",
  "correct": true,
  "explanation": "La clôture garde deux voix et le point où elles ne se ressemblent pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il retenir du fait ou du chiffre avancé ?",
  "options": [
    {
      "text": "Rien n'est chiffré, tout est slogan",
      "correct": false
    },
    {
      "text": "Onze semaines, trois malentendus, deux corrections",
      "correct": true
    },
    {
      "text": "Le chiffre annule la concession",
      "correct": false
    },
    {
      "text": "Le micro interdit les traces",
      "correct": false
    }
  ],
  "explanation": "Hawa a daté onze semaines ; trois malentendus ; deux corrections ; zéro essence."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "malentendu",
      "right": "écart de lecture, corrigeable"
    },
    {
      "left": "essence",
      "right": "figement, à refuser"
    },
    {
      "left": "récit",
      "right": "suite datée, détaillée"
    },
    {
      "left": "correction",
      "right": "geste qui défait le type"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nD'après le second texte, on ___ une rampe avant les lanternes. (exiger, cond. atténué)",
  "answer": "exigerait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "D'après",
    "le",
    "second",
    "texte",
    "on",
    "exigerait",
    "une",
    "rampe",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "essence",
  "hint": "figement, à refuser"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La malentendu de trop vite n'aide personne, et Dieudonné Hakizimana reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Dieudonné Hakizimana reprend le fil.",
  "explanation": "Éviter une construction calquée ; préférer un nom d'action juste (précipitation)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/position-implicite.svg",
      "word": "position implicite"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/initiative-cour.svg",
      "word": "initiative cour"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/micro-cultures.svg",
      "word": "micro cultures"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/cahier-croise.svg",
      "word": "cahier croise"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Une vie, pas un type » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Récit interculturel : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : récit détaillé au passé ; différences ; sans ethnologiser.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on fige Hawa en exemple, un récit trop typique pour rester une vie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Ce que l'on nomme malentendu, ici, n'est pas un slogan : écart de lecture, corrigeable.
Encore que l'on raconte, un récit trop typique pour rester une vie n'est pas un détail.
Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Autrement dit, selon Hawa, la clé manquait ; d'après Dieudonné, le thé était trop tôt ; il ressort une vie, pas un type
Il ressort qu'un récit : dates, gestes, malentendus, corrections, zéro chez eux trop large
Dieudonné avait cru bien faire avec le thé trop tôt.
Lila n'adoucira pas le eux.
La proposition qui reste debout est celle-ci : un récit : dates, gestes, malentendus, corrections, zéro chez eux trop large
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les notes trop typiques d'un voisin d'un côté, le récit d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa Diallo transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Hawa Diallo, et à quelle condition ?",
  "options": [
    {
      "text": "Hawa Diallo n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "nommer des différences aide — à condition que l'on n'en fasse pas une essence, ni une leçon de cour",
      "correct": true
    },
    {
      "text": "Hawa Diallo abandonne il s'agit d'une personne, pas d'une vitrine culturelle",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'en fasse pas une essence, ni une leçon de cour"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "malentendu",
      "right": "écart de lecture, corrigeable"
    },
    {
      "left": "essence",
      "right": "figement, à refuser"
    },
    {
      "left": "récit",
      "right": "suite datée, détaillée"
    },
    {
      "left": "correction",
      "right": "geste qui défait le type"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl appert que malentendu n'est pas un slogan.",
  "answer": "appert"
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
    "compte-rendu",
    "n'est",
    "pas",
    "une",
    "fusion",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "récit",
  "hint": "suite datée, détaillée"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Hawa Diallo écoute encore, et il fautons raconter avant de crier.",
  "correct_sentence": "Hawa Diallo écoute encore, et il faut raconter avant de crier.",
  "explanation": "Toujours il faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/initiative-cour.svg",
      "word": "initiative cour"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/micro-cultures.svg",
      "word": "micro cultures"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/cahier-croise.svg",
      "word": "cahier croise"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/pavillon-fete.svg",
      "word": "pavillon fete"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur récit détaillé au passé ; différences ; sans ethnologiser, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les notes trop typiques d'un voisin et le récit d'Hawa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Hawa Diallo',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Raconter une expérience interculturelle au Seuil, détaillée, sans figer l'autre. Point : récit détaillé au passé ; différences ; sans ethnologiser.

Consigne
Imitez le texte de Hawa Diallo.

Support — Hawa Diallo — Une vie, pas un type
Hawa Diallo — Une vie, pas un type
On parle trop vite de les premiers mois d'Hawa au Pavillon, comme si le mot dispensait d'en examiner le prix.
Encore que l'on fige Hawa en exemple, un récit trop typique pour rester une vie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Ce que l'on nomme malentendu, ici, n'est pas un slogan : écart de lecture, corrigeable.
Hawa avait déjà posé la valise quand on lui a dit chez eux.
Lila n'adoucira pas le eux.
Rose coud un ourlet trop large encore.
Patrick veut les onze semaines.
La proposition qui reste debout est celle-ci : un récit : dates, gestes, malentendus, corrections, zéro chez eux trop large
Marc : un récit C2 se juge à ce qu'il n'a pas figé.
Nous clôturons sans fusionner les voix : les notes trop typiques d'un voisin d'un côté, le récit d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on raconte, un récit trop typique pour rester une vie n'est pas un détail.
Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
selon Hawa, la clé manquait ; d'après Dieudonné, le thé était trop tôt ; il ressort une vie, pas un type
Hawa Diallo, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un récit : dates, gestes, malentendus, corrections, zéro chez eux trop large",
  "correct": true,
  "explanation": "un récit : dates, gestes, malentendus, corrections, zéro chez eux trop large"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle proposition reste debout à la fin ?",
  "options": [
    {
      "text": "Fusionner les deux documents en une affiche",
      "correct": false
    },
    {
      "text": "un récit : dates, gestes, malentendus, corrections, zéro chez eux trop large",
      "correct": true
    },
    {
      "text": "Interdire toute nominalisation",
      "correct": false
    },
    {
      "text": "Couper le micro de Lila",
      "correct": false
    }
  ],
  "explanation": "un récit : dates, gestes, malentendus, corrections, zéro chez eux trop large"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "malentendu",
      "right": "écart de lecture, corrigeable"
    },
    {
      "left": "essence",
      "right": "figement, à refuser"
    },
    {
      "left": "récit",
      "right": "suite datée, détaillée"
    },
    {
      "left": "correction",
      "right": "geste qui défait le type"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ les deux sources, on ne les fusionne pas. (raconter, subj.)",
  "answer": "raconte"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Encore",
    "que",
    "l'on",
    "raconte",
    "les",
    "sources",
    "on",
    "ne",
    "les",
    "fusionne",
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
  "word": "correction",
  "hint": "geste qui défait le type"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Hawa Diallo est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Hawa Diallo sont clairs, et Lila garde le micro ouvert.",
  "explanation": "Accord : les arguments sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/micro-cultures.svg",
      "word": "micro cultures"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/cahier-croise.svg",
      "word": "cahier croise"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/pavillon-fete.svg",
      "word": "pavillon fete"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/soleil-partage.svg",
      "word": "soleil partage"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Hawa Diallo : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — récit détaillé au passé ; différences ; sans ethnologiser',
    'EL',
    $c$Objectif
Maîtriser récit détaillé au passé ; différences ; sans ethnologiser au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — récit détaillé au passé ; différences ; sans ethnologiser
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on raconte, un récit trop typique pour rester une vie n'est pas un détail.
Hawa Diallo concède que nommer des différences aide, pour autant que l'on n'en fasse pas une essence, ni une leçon de cour.
Autrement dit, selon Hawa, la clé manquait ; d'après Dieudonné, le thé était trop tôt ; il ressort une vie, pas un type
Il ressort qu'un récit : dates, gestes, malentendus, corrections, zéro chez eux trop large
Piège : fusionner les sources au lieu de les attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme malentendu, ici, n'est pas un slogan : écart de lecture, corrigeable.
Dieudonné avait cru bien faire avec le thé trop tôt.
Lila n'adoucira pas le eux.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au récit pour de vrai genre, et Dieudonné Hakizimana demande un registre plus net.
Correction : On va au récit vraiment, et Dieudonné Hakizimana demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Selon X » permet d'attribuer sans fusionner.",
  "correct": true,
  "explanation": "Compte-rendu."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pour attribuer une idée à une source, on privilégie…",
  "options": [
    {
      "text": "je pense que sans source",
      "correct": false
    },
    {
      "text": "selon / d'après / il ressort que",
      "correct": true
    },
    {
      "text": "il fautons",
      "correct": false
    },
    {
      "text": "un slogan",
      "correct": false
    }
  ],
  "explanation": "Marqueurs de compte-rendu."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "malentendu",
      "right": "écart de lecture, corrigeable"
    },
    {
      "left": "essence",
      "right": "figement, à refuser"
    },
    {
      "left": "récit",
      "right": "suite datée, détaillée"
    },
    {
      "left": "correction",
      "right": "geste qui défait le type"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe compte-rendu ___ les désaccords, il ne les gomme pas. (accueillir)",
  "answer": "accueille"
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
    "appert",
    "que",
    "le",
    "slogan",
    "ne",
    "tient",
    "pas",
    "lieu",
    "de",
    "plan",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "collocation",
  "hint": "Précision du discours, sans nommer le mot-cible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On va au récit pour de vrai genre, et Dieudonné Hakizimana demande un registre plus net.",
  "correct_sentence": "On va au récit vraiment, et Dieudonné Hakizimana demande un registre plus net.",
  "explanation": "Registre : éviter le marqueur trop oral « genre » dans un écrit soutenu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/cahier-croise.svg",
      "word": "cahier croise"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/pavillon-fete.svg",
      "word": "pavillon fete"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/soleil-partage.svg",
      "word": "soleil partage"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/nuage-quiproquo.svg",
      "word": "nuage quiproquo"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « récit détaillé au passé ; différences ; sans ethnologiser » et deux pièges commentés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre phrases justes au registre demandé."
}$j$::jsonb,
    9
  );

  -- ===== Article implicite =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Article implicite'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Article implicite', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Article implicite',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Tenir l'article implicite jusqu'au bout, sans retomber dans le cri. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Article implicite
Lila Sow : Radio Figuier. On parle trop vite de la seconde version de l'article d'Hawa, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on force le cri au nom de la clarté, une clarté qui n'est qu'un slogan contraire n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Aline Uwase : Ce que l'on nomme composition, ici, n'est pas un slogan : arrangement des faits, lisible.
Patrick Habimana : Aline : loin de manquer de courage, l'article se lisait.
Hawa Diallo : Hawa garde le tarif.
Joël Mugisha : Lila n'ajoute pas un cri.
Rose Iradukunda : Patrick relit l'écart.
Solange Mukamana : Rose entend la porte.
Karim Bamba : Sami voulait plus net ; il relit, il cède.
Félicie Ndayishimiye : Un chiffre, une trace : Aline a justifié l'écart ; Hawa a gardé le tarif ; zéro cri ajouté.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une maîtrise de registre, pas d'un manque de courage
Yvette : Mado aime la composition.
Mado : Hawa Diallo entend, dans « il faut le dire clairement », ceci qui n'est pas dit : clairement veut parfois dire criez comme nous
Sami : Autrement dit, l'implicite C2 n'est pas un flou : c'est une composition de faits dont la conclusion se lit
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire
Nina Kayitesi : Marc : un implicite C2 se justifie, il ne se dilue pas.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : la demande de crier d'un côté, l'article gardé de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Il faut le dire clairement : on notera que clairement, ici, signifie souvent plus fort que moi.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une clarté qui n'est qu'un slogan contraire est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une clarté qui n'est qu'un slogan contraire n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Hawa Diallo, que reste-t-il implicite dans « il faut le dire clairement » ?",
  "options": [
    {
      "text": "Que Aline a exigé le cri",
      "correct": false
    },
    {
      "text": "Criez comme nous",
      "correct": true
    },
    {
      "text": "Que Hawa a ajouté un slogan contraire",
      "correct": false
    },
    {
      "text": "Que l'écart n'a pas été justifié",
      "correct": false
    }
  ],
  "explanation": "clairement veut parfois dire criez comme nous"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "composition",
      "right": "arrangement des faits, lisible"
    },
    {
      "left": "conclusion",
      "right": "sens qui se lit, non crié"
    },
    {
      "left": "clarté",
      "right": "qualité, parfois un prétexte à crier"
    },
    {
      "left": "courage",
      "right": "distinct du volume de la voix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl ne s'agirait ___ d'un détail, à entendre certains. (ne … que)",
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
    "Il",
    "ne",
    "s'agirait",
    "que",
    "d'un",
    "détail",
    "à",
    "entendre",
    "certains",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "composition",
  "hint": "arrangement des faits, lisible"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tant est que le bonheur s'industrialise, il se vend déjà, et Aline Uwase sourit trop large.",
  "correct_sentence": "Si tant est que le bonheur s'industrialise, il se vendrait déjà, et Aline Uwase sourit trop large.",
  "explanation": "Si tant est que + hypothese : se vendrait (irréel / doute)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/pavillon-fete.svg",
      "word": "pavillon fete"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/soleil-partage.svg",
      "word": "soleil partage"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/nuage-quiproquo.svg",
      "word": "nuage quiproquo"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/feuille-debat.svg",
      "word": "feuille debat"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « il faut le dire clairement » et la concession de Aline Uwase."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez la demande de crier et l'article gardé distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — La conclusion se lit',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Tenir l'article implicite jusqu'au bout, sans retomber dans le cri. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « La conclusion se lit », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La conclusion se lit
On parle trop vite de la seconde version de l'article d'Hawa, comme si le mot dispensait d'en examiner le prix.
Encore que l'on force le cri au nom de la clarté, une clarté qui n'est qu'un slogan contraire n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Ce que l'on nomme composition, ici, n'est pas un slogan : arrangement des faits, lisible.
Aline : loin de manquer de courage, l'article se lisait.
Hawa garde le tarif.
Lila n'ajoute pas un cri.
Patrick relit l'écart.
Rose entend la porte.
Sami voulait plus net ; il relit, il cède.
Un chiffre, une trace : Aline a justifié l'écart ; Hawa a gardé le tarif ; zéro cri ajouté.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une maîtrise de registre, pas d'un manque de courage
Mado aime la composition.
Hawa Diallo entend, dans « il faut le dire clairement », ceci qui n'est pas dit : clairement veut parfois dire criez comme nous
Autrement dit, l'implicite C2 n'est pas un flou : c'est une composition de faits dont la conclusion se lit
La proposition qui reste debout est celle-ci : garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire
Marc : un implicite C2 se justifie, il ne se dilue pas.
Nous clôturons sans fusionner les voix : la demande de crier d'un côté, l'article gardé de l'autre, et le point où elles refusent de se ressembler.
Signé : Aline Uwase, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner la demande de crier et l'article gardé en une seule affiche.",
  "correct": true,
  "explanation": "La clôture garde deux voix et le point où elles ne se ressemblent pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il retenir du fait ou du chiffre avancé ?",
  "options": [
    {
      "text": "Rien n'est chiffré, tout est slogan",
      "correct": false
    },
    {
      "text": "Écart justifié, tarif gardé, zéro cri",
      "correct": true
    },
    {
      "text": "Le chiffre annule la concession",
      "correct": false
    },
    {
      "text": "Le micro interdit les traces",
      "correct": false
    }
  ],
  "explanation": "Aline a justifié l'écart ; Hawa a gardé le tarif ; zéro cri ajouté."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "composition",
      "right": "arrangement des faits, lisible"
    },
    {
      "left": "conclusion",
      "right": "sens qui se lit, non crié"
    },
    {
      "left": "clarté",
      "right": "qualité, parfois un prétexte à crier"
    },
    {
      "left": "courage",
      "right": "distinct du volume de la voix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLoin de ___ la cour, le sourire la fatigue. (rassurer)",
  "answer": "rassurer"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Loin",
    "de",
    "rassurer",
    "la",
    "cour",
    "le",
    "sourire",
    "la",
    "fatigue",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "conclusion",
  "hint": "sens qui se lit, non crié"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La composition de trop vite n'aide personne, et Hawa Diallo reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Hawa Diallo reprend le fil.",
  "explanation": "Éviter une construction calquée ; préférer un nom d'action juste (précipitation)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/soleil-partage.svg",
      "word": "soleil partage"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/nuage-quiproquo.svg",
      "word": "nuage quiproquo"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/feuille-debat.svg",
      "word": "feuille debat"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/radio-rire.svg",
      "word": "radio rire"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « La conclusion se lit » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Article implicite : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : écrire en sous-entendu ; faits ; écart.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on force le cri au nom de la clarté, une clarté qui n'est qu'un slogan contraire n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Ce que l'on nomme composition, ici, n'est pas un slogan : arrangement des faits, lisible.
Encore que l'on justifie, une clarté qui n'est qu'un slogan contraire n'est pas un détail.
Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Autrement dit, l'implicite C2 n'est pas un flou : c'est une composition de faits dont la conclusion se lit
Il ressort que garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire
Hawa garde le tarif.
Rose entend la porte.
La proposition qui reste debout est celle-ci : garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : la demande de crier d'un côté, l'article gardé de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline Uwase transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Aline Uwase, et à quelle condition ?",
  "options": [
    {
      "text": "Aline Uwase n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "la clarté est souvent juste — à condition que l'on n'y perde l'écart qui faisait le travail",
      "correct": true
    },
    {
      "text": "Aline Uwase abandonne il s'agit d'une maîtrise de registre, pas d'un manque de courage",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y perde l'écart qui faisait le travail"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "composition",
      "right": "arrangement des faits, lisible"
    },
    {
      "left": "conclusion",
      "right": "sens qui se lit, non crié"
    },
    {
      "left": "clarté",
      "right": "qualité, parfois un prétexte à crier"
    },
    {
      "left": "courage",
      "right": "distinct du volume de la voix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nFût-ce à voix basse, Mado ___ le contraire de ce qu'on affiche. (dire)",
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
    "Fût-ce",
    "à",
    "voix",
    "basse",
    "Mado",
    "dit",
    "le",
    "contraire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "clarté",
  "hint": "qualité, parfois un prétexte à crier"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aline Uwase écoute encore, et il fautons justifier avant de crier.",
  "correct_sentence": "Aline Uwase écoute encore, et il faut justifier avant de crier.",
  "explanation": "Toujours il faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/nuage-quiproquo.svg",
      "word": "nuage quiproquo"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/feuille-debat.svg",
      "word": "feuille debat"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/radio-rire.svg",
      "word": "radio rire"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/groupe-invites.svg",
      "word": "groupe invites"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur écrire en sous-entendu ; faits ; écart, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez la demande de crier et l'article gardé distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Aline Uwase',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Tenir l'article implicite jusqu'au bout, sans retomber dans le cri. Point : écrire en sous-entendu ; faits ; écart.

Consigne
Imitez le texte de Aline Uwase.

Support — Aline Uwase — La conclusion se lit
Aline Uwase — La conclusion se lit
On parle trop vite de la seconde version de l'article d'Hawa, comme si le mot dispensait d'en examiner le prix.
Encore que l'on force le cri au nom de la clarté, une clarté qui n'est qu'un slogan contraire n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Ce que l'on nomme composition, ici, n'est pas un slogan : arrangement des faits, lisible.
Aline : loin de manquer de courage, l'article se lisait.
Rose entend la porte.
Sami voulait plus net ; il relit, il cède.
Mado aime la composition.
La proposition qui reste debout est celle-ci : garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire
Marc : un implicite C2 se justifie, il ne se dilue pas.
Nous clôturons sans fusionner les voix : la demande de crier d'un côté, l'article gardé de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on justifie, une clarté qui n'est qu'un slogan contraire n'est pas un détail.
Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
l'implicite C2 n'est pas un flou : c'est une composition de faits dont la conclusion se lit
Aline Uwase, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire",
  "correct": true,
  "explanation": "garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle proposition reste debout à la fin ?",
  "options": [
    {
      "text": "Fusionner les deux documents en une affiche",
      "correct": false
    },
    {
      "text": "garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire",
      "correct": true
    },
    {
      "text": "Interdire toute nominalisation",
      "correct": false
    },
    {
      "text": "Couper le micro de Lila",
      "correct": false
    }
  ],
  "explanation": "garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "composition",
      "right": "arrangement des faits, lisible"
    },
    {
      "left": "conclusion",
      "right": "sens qui se lit, non crié"
    },
    {
      "left": "clarté",
      "right": "qualité, parfois un prétexte à crier"
    },
    {
      "left": "courage",
      "right": "distinct du volume de la voix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi tant est que le bonheur s'___, il se vendrait déjà sous le figuier. (industrialiser)",
  "answer": "industrialise"
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
    "tant",
    "est",
    "que",
    "le",
    "bonheur",
    "s'industrialise",
    "il",
    "se",
    "vendrait",
    "déjà",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "courage",
  "hint": "distinct du volume de la voix"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Aline Uwase est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Aline Uwase sont clairs, et Lila garde le micro ouvert.",
  "explanation": "Accord : les arguments sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/feuille-debat.svg",
      "word": "feuille debat"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/radio-rire.svg",
      "word": "radio rire"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/groupe-invites.svg",
      "word": "groupe invites"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/main-tissu.svg",
      "word": "main tissu"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Aline Uwase : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — écrire en sous-entendu ; faits ; écart',
    'EL',
    $c$Objectif
Maîtriser écrire en sous-entendu ; faits ; écart au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — écrire en sous-entendu ; faits ; écart
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on justifie, une clarté qui n'est qu'un slogan contraire n'est pas un détail.
Aline Uwase concède que la clarté est souvent juste, pour autant que l'on n'y perde l'écart qui faisait le travail.
Autrement dit, l'implicite C2 n'est pas un flou : c'est une composition de faits dont la conclusion se lit
Il ressort que garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme composition, ici, n'est pas un slogan : arrangement des faits, lisible.
Hawa garde le tarif.
Rose entend la porte.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au clarté pour de vrai genre, et Hawa Diallo demande un registre plus net.
Correction : On va au clarté vraiment, et Hawa Diallo demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'ironie peut dire le contraire de ce qu'elle affirme.",
  "correct": true,
  "explanation": "Antiphrase possible."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Il ne s'agirait que d'un détail » est souvent…",
  "options": [
    {
      "text": "une preuve que c'est un détail",
      "correct": false
    },
    {
      "text": "un sous-entendu, parfois ironique",
      "correct": true
    },
    {
      "text": "un passé simple",
      "correct": false
    },
    {
      "text": "un ordre",
      "correct": false
    }
  ],
  "explanation": "Understatement / ironie."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "composition",
      "right": "arrangement des faits, lisible"
    },
    {
      "left": "conclusion",
      "right": "sens qui se lit, non crié"
    },
    {
      "left": "clarté",
      "right": "qualité, parfois un prétexte à crier"
    },
    {
      "left": "courage",
      "right": "distinct du volume de la voix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'___ n'est pas un rire : c'est un écart entre le dit et le visé. (ironie)",
  "answer": "ironie"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "L'ironie",
    "n'est",
    "pas",
    "un",
    "rire",
    "c'est",
    "un",
    "écart",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "collocation",
  "hint": "Précision du discours, sans nommer le mot-cible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On va au clarté pour de vrai genre, et Hawa Diallo demande un registre plus net.",
  "correct_sentence": "On va au clarté vraiment, et Hawa Diallo demande un registre plus net.",
  "explanation": "Registre : éviter le marqueur trop oral « genre » dans un écrit soutenu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/radio-rire.svg",
      "word": "radio rire"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/groupe-invites.svg",
      "word": "groupe invites"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/main-tissu.svg",
      "word": "main tissu"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/porte-fete.svg",
      "word": "porte fete"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « écrire en sous-entendu ; faits ; écart » et deux pièges commentés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre phrases justes au registre demandé."
}$j$::jsonb,
    9
  );

  -- ===== Débat de la cour =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Débat de la cour'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Débat de la cour', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Débat de la cour',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Tenir un débat sur un sujet polémique de cour, avec règles C2. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Débat de la cour
Lila Sow : Radio Figuier. On parle trop vite de le débat sous le figuier, après les copies et le rire, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme le débat en combat, une synthèse trop lisse après trop de bruit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Patrick Habimana concède que un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Aline Uwase : Ce que l'on nomme débat, ici, n'est pas un slogan : échange réglé, distinct d'un combat.
Patrick Habimana : Patrick : il convient que l'on débatte, encore que l'on refuse l'arène.
Hawa Diallo : Rose concède l'inspiration, pas le vide.
Joël Mugisha : Sami concède la cible.
Rose Iradukunda : Hawa concède le mot généreux, pas le tarif.
Solange Mukamana : Aline chronomètre.
Karim Bamba : Lila n'annonce pas de vainqueur.
Félicie Ndayishimiye : Un chiffre, une trace : Trois tours ; trois concessions ; une synthèse sans vainqueur.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une cour qui pense, pas d'une arène
Yvette : Yvette écoute.
Mado : Rose Iradukunda entend, dans « que le meilleur gagne », ceci qui n'est pas dit : le meilleur gagne est déjà une politique du micro
Sami : Autrement dit, il convient que l'on débatte, encore que l'on synthétise sans vainqueur
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un débat : Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi
Nina Kayitesi : Marc : une synthèse C2 se juge à ce qu'elle n'a pas couronné.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les prises de parole d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Que le meilleur gagne : on aimerait, par curiosité, le critère du meilleur.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une synthèse trop lisse après trop de bruit est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une synthèse trop lisse après trop de bruit n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Rose Iradukunda, que reste-t-il implicite dans « que le meilleur gagne » ?",
  "options": [
    {
      "text": "Que Patrick a désigné un roi",
      "correct": false
    },
    {
      "text": "Une politique du micro",
      "correct": true
    },
    {
      "text": "Que Rose a quitté sans concession",
      "correct": false
    },
    {
      "text": "Que Hawa a été humiliée",
      "correct": false
    }
  ],
  "explanation": "le meilleur gagne est déjà une politique du micro"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "débat",
      "right": "échange réglé, distinct d'un combat"
    },
    {
      "left": "polémique",
      "right": "sujet vif, à tenir"
    },
    {
      "left": "règle",
      "right": "temps, concession, non-humiliation"
    },
    {
      "left": "arène",
      "right": "forme à refuser sous le figuier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ avant d'accélérer. (débattre, subj.)",
  "answer": "débatte"
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
    "convient",
    "que",
    "l'on",
    "débatte",
    "avant",
    "d'accélérer",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "débat",
  "hint": "échange réglé, distinct d'un combat"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il convient que l'on débattre trop tard, et Patrick Habimana refuse d'accélérer la pente.",
  "correct_sentence": "Il convient que l'on débatte trop tard, et Patrick Habimana refuse d'accélérer la pente.",
  "explanation": "Il convient que + débatte."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/groupe-invites.svg",
      "word": "groupe invites"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/main-tissu.svg",
      "word": "main tissu"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/porte-fete.svg",
      "word": "porte fete"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/lampe-accueil.svg",
      "word": "lampe accueil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « que le meilleur gagne » et la concession de Patrick Habimana."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les prises de parole et la synthèse de Patrick distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Zéro roi au banc',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Tenir un débat sur un sujet polémique de cour, avec règles C2. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Zéro roi au banc », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Zéro roi au banc
On parle trop vite de le débat sous le figuier, après les copies et le rire, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le débat en combat, une synthèse trop lisse après trop de bruit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Ce que l'on nomme débat, ici, n'est pas un slogan : échange réglé, distinct d'un combat.
Patrick : il convient que l'on débatte, encore que l'on refuse l'arène.
Rose concède l'inspiration, pas le vide.
Sami concède la cible.
Hawa concède le mot généreux, pas le tarif.
Aline chronomètre.
Lila n'annonce pas de vainqueur.
Un chiffre, une trace : Trois tours ; trois concessions ; une synthèse sans vainqueur.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une cour qui pense, pas d'une arène
Yvette écoute.
Rose Iradukunda entend, dans « que le meilleur gagne », ceci qui n'est pas dit : le meilleur gagne est déjà une politique du micro
Autrement dit, il convient que l'on débatte, encore que l'on synthétise sans vainqueur
La proposition qui reste debout est celle-ci : un débat : Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi
Marc : une synthèse C2 se juge à ce qu'elle n'a pas couronné.
Nous clôturons sans fusionner les voix : les prises de parole d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
Signé : Patrick Habimana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les prises de parole et la synthèse de Patrick en une seule affiche.",
  "correct": true,
  "explanation": "La clôture garde deux voix et le point où elles ne se ressemblent pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il retenir du fait ou du chiffre avancé ?",
  "options": [
    {
      "text": "Rien n'est chiffré, tout est slogan",
      "correct": false
    },
    {
      "text": "Trois tours, trois concessions, zéro vainqueur",
      "correct": true
    },
    {
      "text": "Le chiffre annule la concession",
      "correct": false
    },
    {
      "text": "Le micro interdit les traces",
      "correct": false
    }
  ],
  "explanation": "Trois tours ; trois concessions ; une synthèse sans vainqueur."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "débat",
      "right": "échange réglé, distinct d'un combat"
    },
    {
      "left": "polémique",
      "right": "sujet vif, à tenir"
    },
    {
      "left": "règle",
      "right": "temps, concession, non-humiliation"
    },
    {
      "left": "arène",
      "right": "forme à refuser sous le figuier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl s'agit de ___ la pente, non de la nier. (nommer)",
  "answer": "nommer"
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
    "s'agit",
    "de",
    "nommer",
    "la",
    "pente",
    "non",
    "de",
    "la",
    "nier",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "polémique",
  "hint": "sujet vif, à tenir"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La débat de trop vite n'aide personne, et Rose Iradukunda reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Rose Iradukunda reprend le fil.",
  "explanation": "Éviter une construction calquée ; préférer un nom d'action juste (précipitation)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/main-tissu.svg",
      "word": "main tissu"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/porte-fete.svg",
      "word": "porte fete"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/lampe-accueil.svg",
      "word": "lampe accueil"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/coeur-croise.svg",
      "word": "coeur croise"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Zéro roi au banc » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Débat de la cour : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : débat contradictoire ; polémique ; synthèse.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme le débat en combat, une synthèse trop lisse après trop de bruit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Ce que l'on nomme débat, ici, n'est pas un slogan : échange réglé, distinct d'un combat.
Encore que l'on débatte, une synthèse trop lisse après trop de bruit n'est pas un détail.
Patrick Habimana concède que un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Autrement dit, il convient que l'on débatte, encore que l'on synthétise sans vainqueur
Il ressort qu'un débat : Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi
Rose concède l'inspiration, pas le vide.
Aline chronomètre.
La proposition qui reste debout est celle-ci : un débat : Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les prises de parole d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
Aline : gardez le souffle après la concession, pas avant la thèse.
Patrick : le registre soutenu n'interdit pas la clarté.
Lila : le micro n'aime ni le slogan ni le silence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick Habimana transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Patrick Habimana concède que un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Patrick Habimana, et à quelle condition ?",
  "options": [
    {
      "text": "Patrick Habimana n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "un désaccord vif éclaire — à condition que l'on impose concession, temps, zéro humiliation",
      "correct": true
    },
    {
      "text": "Patrick Habimana abandonne il s'agit d'une cour qui pense, pas d'une arène",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on impose concession, temps, zéro humiliation"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "débat",
      "right": "échange réglé, distinct d'un combat"
    },
    {
      "left": "polémique",
      "right": "sujet vif, à tenir"
    },
    {
      "left": "règle",
      "right": "temps, concession, non-humiliation"
    },
    {
      "left": "arène",
      "right": "forme à refuser sous le figuier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous recommandons que la cour ___ un relais. (débattre, subj.)",
  "answer": "débatte"
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
    "recommandons",
    "que",
    "la",
    "cour",
    "débatte",
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
  "word": "règle",
  "hint": "temps, concession, non-humiliation"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Patrick Habimana écoute encore, et il fautons débattre avant de crier.",
  "correct_sentence": "Patrick Habimana écoute encore, et il faut débattre avant de crier.",
  "explanation": "Toujours il faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/porte-fete.svg",
      "word": "porte fete"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/lampe-accueil.svg",
      "word": "lampe accueil"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/coeur-croise.svg",
      "word": "coeur croise"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/culture-partagee.svg",
      "word": "culture partagee"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur débat contradictoire ; polémique ; synthèse, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les prises de parole et la synthèse de Patrick distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Patrick Habimana',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Tenir un débat sur un sujet polémique de cour, avec règles C2. Point : débat contradictoire ; polémique ; synthèse.

Consigne
Imitez le texte de Patrick Habimana.

Support — Patrick Habimana — Zéro roi au banc
Patrick Habimana — Zéro roi au banc
On parle trop vite de le débat sous le figuier, après les copies et le rire, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le débat en combat, une synthèse trop lisse après trop de bruit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Ce que l'on nomme débat, ici, n'est pas un slogan : échange réglé, distinct d'un combat.
Patrick : il convient que l'on débatte, encore que l'on refuse l'arène.
Aline chronomètre.
Lila n'annonce pas de vainqueur.
Yvette écoute.
La proposition qui reste debout est celle-ci : un débat : Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi
Marc : une synthèse C2 se juge à ce qu'elle n'a pas couronné.
Nous clôturons sans fusionner les voix : les prises de parole d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on débatte, une synthèse trop lisse après trop de bruit n'est pas un détail.
Patrick Habimana concède que un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il convient que l'on débatte, encore que l'on synthétise sans vainqueur
Patrick Habimana, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un débat : Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi",
  "correct": true,
  "explanation": "un débat : Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle proposition reste debout à la fin ?",
  "options": [
    {
      "text": "Fusionner les deux documents en une affiche",
      "correct": false
    },
    {
      "text": "un débat : Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi",
      "correct": true
    },
    {
      "text": "Interdire toute nominalisation",
      "correct": false
    },
    {
      "text": "Couper le micro de Lila",
      "correct": false
    }
  ],
  "explanation": "un débat : Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "débat",
      "right": "échange réglé, distinct d'un combat"
    },
    {
      "left": "polémique",
      "right": "sujet vif, à tenir"
    },
    {
      "left": "règle",
      "right": "temps, concession, non-humiliation"
    },
    {
      "left": "arène",
      "right": "forme à refuser sous le figuier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le camion ___ utile, il n'a pas tous les droits. (être, subj.)",
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
    "Une",
    "recommandation",
    "n'est",
    "pas",
    "un",
    "ordre",
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
  "word": "arène",
  "hint": "forme à refuser sous le figuier"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Patrick Habimana est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Patrick Habimana sont clairs, et Lila garde le micro ouvert.",
  "explanation": "Accord : les arguments sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/lampe-accueil.svg",
      "word": "lampe accueil"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/coeur-croise.svg",
      "word": "coeur croise"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/culture-partagee.svg",
      "word": "culture partagee"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/acces-salle.svg",
      "word": "acces salle"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Patrick Habimana : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — débat contradictoire ; polémique ; synthèse',
    'EL',
    $c$Objectif
Maîtriser débat contradictoire ; polémique ; synthèse au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — débat contradictoire ; polémique ; synthèse
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on débatte, une synthèse trop lisse après trop de bruit n'est pas un détail.
Patrick Habimana concède que un désaccord vif éclaire, pour autant que l'on impose concession, temps, zéro humiliation.
Autrement dit, il convient que l'on débatte, encore que l'on synthétise sans vainqueur
Il ressort qu'un débat : Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme débat, ici, n'est pas un slogan : échange réglé, distinct d'un combat.
Rose concède l'inspiration, pas le vide.
Aline chronomètre.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au règle pour de vrai genre, et Rose Iradukunda demande un registre plus net.
Correction : On va au règle vraiment, et Rose Iradukunda demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il convient que » se construit avec le subjonctif.",
  "correct": true,
  "explanation": "Volonté / opportunité."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Après « il convient que », quel mode ?",
  "options": [
    {
      "text": "indicatif seulement",
      "correct": false
    },
    {
      "text": "subjonctif",
      "correct": true
    },
    {
      "text": "impératif uniquement",
      "correct": false
    },
    {
      "text": "conditionnel passé obligatoire",
      "correct": false
    }
  ],
  "explanation": "Il convient que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "débat",
      "right": "échange réglé, distinct d'un combat"
    },
    {
      "left": "polémique",
      "right": "sujet vif, à tenir"
    },
    {
      "left": "règle",
      "right": "temps, concession, non-humiliation"
    },
    {
      "left": "arène",
      "right": "forme à refuser sous le figuier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn procédera à une ___ des heures, non à un slogan. (nominalisation de revoir)",
  "answer": "révision"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Encore",
    "que",
    "le",
    "camion",
    "soit",
    "utile",
    "il",
    "n'a",
    "pas",
    "tous",
    "les",
    "droits",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "collocation",
  "hint": "Précision du discours, sans nommer le mot-cible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On va au règle pour de vrai genre, et Rose Iradukunda demande un registre plus net.",
  "correct_sentence": "On va au règle vraiment, et Rose Iradukunda demande un registre plus net.",
  "explanation": "Registre : éviter le marqueur trop oral « genre » dans un écrit soutenu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m5/coeur-croise.svg",
      "word": "coeur croise"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/culture-partagee.svg",
      "word": "culture partagee"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/acces-salle.svg",
      "word": "acces salle"
    },
    {
      "image_path": "/elearning/mfk-c2-m5/article-implicite.svg",
      "word": "article implicite"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « débat contradictoire ; polémique ; synthèse » et deux pièges commentés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre phrases justes au registre demandé."
}$j$::jsonb,
    9
  );

END;
$$;
