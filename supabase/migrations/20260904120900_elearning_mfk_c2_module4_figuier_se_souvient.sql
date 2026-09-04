/*
  Seed eLearning MFK — C2 — Ce que le figuier se souvient

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-c2-m4/
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
  v_module_title text := 'C2 — Ce que le figuier se souvient';
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
      'Grande étape C2-4 : défendre un support pédagogique, écrire un éditorial sur des pactes de rive, analyser un discours de veillée, dresser le plan d''une plaidoirie inventée, puis un essai et une chronique — Yvette nomme sans crier, Patrick Habimana refuse l''oubli poli, le Bureau des Escales n''est pas un tribunal d''État, c''est une cour.',
      'C2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape C2-4 : défendre un support pédagogique, écrire un éditorial sur des pactes de rive, analyser un discours de veillée, dresser le plan d''une plaidoirie inventée, puis un essai et une chronique — Yvette nomme sans crier, Patrick Habimana refuse l''oubli poli, le Bureau des Escales n''est pas un tribunal d''État, c''est une cour.',
      cefr_level = 'C2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Le tableau de la cour =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Le tableau de la cour'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Le tableau de la cour', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le tableau de la cour',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Démontrer l'intérêt d'un support inventé pour enseigner une mémoire de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le tableau de la cour
Lila Sow : Radio Figuier. On parle trop vite de un support trop controversé d'Aline, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on tienne le craie pour une vérité sans source, une pédagogie qui n'avoue pas ses angles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Aline Uwase concède que un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Aline Uwase : Ce que l'on nomme support, ici, n'est pas un slogan : outil pédagogique, avec un angle.
Patrick Habimana : Selon Aline, le tableau aide à déduire ; d'après Patrick, il aide trop.
Hawa Diallo : Il ressort que l'intérêt existe, et l'angle mort aussi.
Joël Mugisha : Yvette se souvient autrement.
Rose Iradukunda : Lila n'enregistrera pas une leçon trop sûre.
Solange Mukamana : Solange demande les sources de la craie.
Karim Bamba : Sami déduit trop vite ; on le ralentit.
Félicie Ndayishimiye : Un chiffre, une trace : Aline a montré deux supports ; six déductions ; deux angles morts nommés.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'enseigner une mémoire, pas une obéissance
Yvette : Mado glisse une ironie sur la craie.
Mado : Patrick Habimana entend, dans « au tableau on ne discute pas », ceci qui n'est pas dit : on ne discute pas veut dire la craie a déjà choisi pour vous
Sami : Autrement dit, il ressort qu'un support se juge à ce qu'il permet de déduire, et à ce qu'il empêche de voir
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un essai : intérêt, angle mort, usage sous le figuier
Nina Kayitesi : Marc : un essai pédagogique avoue ses angles.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le support d'Aline d'un côté, la critique de Patrick de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Au tableau on ne discute pas : on reconnaît la sérénité des vérités qui n'ont pas à se sourcer.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une pédagogie qui n'avoue pas ses angles est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une pédagogie qui n'avoue pas ses angles n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Patrick Habimana, que reste-t-il implicite dans « au tableau on ne discute pas » ?",
  "options": [
    {
      "text": "Que Aline interdit la discussion",
      "correct": false
    },
    {
      "text": "La craie a déjà choisi",
      "correct": true
    },
    {
      "text": "Que Patrick a brûlé le tableau",
      "correct": false
    },
    {
      "text": "Que les angles morts n'ont pas été nommés",
      "correct": false
    }
  ],
  "explanation": "on ne discute pas veut dire la craie a déjà choisi pour vous"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "support",
      "right": "outil pédagogique, avec un angle"
    },
    {
      "left": "déduction",
      "right": "enchaînement justifié à partir du tableau"
    },
    {
      "left": "angle",
      "right": "part d'ombre d'un outil"
    },
    {
      "left": "essai",
      "right": "texte argumenté sur un intérêt pédagogique"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSelon Aline, il ___ que deux documents s'opposent. (ressortir)",
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
    "Aline",
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
  "word": "support",
  "hint": "outil pédagogique, avec un angle"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Selon Aline Uwase, il ressort que les deux textes est d'accord, et Lila coupe le micro.",
  "correct_sentence": "Selon Aline Uwase, il ressort que les deux textes sont d'accord, et Lila coupe le micro.",
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
      "image_path": "/elearning/mfk-c2-m4/tableau-pedago.svg",
      "word": "tableau pedago"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/essai-support.svg",
      "word": "essai support"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/raisonnement-deductif.svg",
      "word": "raisonnement deductif"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/craie-memoire.svg",
      "word": "craie memoire"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « au tableau on ne discute pas » et la concession de Aline Uwase."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le support d'Aline et la critique de Patrick distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — La craie a un angle',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Démontrer l'intérêt d'un support inventé pour enseigner une mémoire de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « La craie a un angle », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La craie a un angle
On parle trop vite de un support trop controversé d'Aline, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne le craie pour une vérité sans source, une pédagogie qui n'avoue pas ses angles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Ce que l'on nomme support, ici, n'est pas un slogan : outil pédagogique, avec un angle.
Selon Aline, le tableau aide à déduire ; d'après Patrick, il aide trop.
Il ressort que l'intérêt existe, et l'angle mort aussi.
Yvette se souvient autrement.
Lila n'enregistrera pas une leçon trop sûre.
Solange demande les sources de la craie.
Sami déduit trop vite ; on le ralentit.
Un chiffre, une trace : Aline a montré deux supports ; six déductions ; deux angles morts nommés.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'enseigner une mémoire, pas une obéissance
Mado glisse une ironie sur la craie.
Patrick Habimana entend, dans « au tableau on ne discute pas », ceci qui n'est pas dit : on ne discute pas veut dire la craie a déjà choisi pour vous
Autrement dit, il ressort qu'un support se juge à ce qu'il permet de déduire, et à ce qu'il empêche de voir
La proposition qui reste debout est celle-ci : un essai : intérêt, angle mort, usage sous le figuier
Marc : un essai pédagogique avoue ses angles.
Nous clôturons sans fusionner les voix : le support d'Aline d'un côté, la critique de Patrick de l'autre, et le point où elles refusent de se ressembler.
Signé : Aline Uwase, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le support d'Aline et la critique de Patrick en une seule affiche.",
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
      "text": "Deux supports, six déductions, deux angles morts",
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
  "explanation": "Aline a montré deux supports ; six déductions ; deux angles morts nommés."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "support",
      "right": "outil pédagogique, avec un angle"
    },
    {
      "left": "déduction",
      "right": "enchaînement justifié à partir du tableau"
    },
    {
      "left": "angle",
      "right": "part d'ombre d'un outil"
    },
    {
      "left": "essai",
      "right": "texte argumenté sur un intérêt pédagogique"
    }
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
  "word": "déduction",
  "hint": "enchaînement justifié à partir du tableau"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La support de trop vite n'aide personne, et Patrick Habimana reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Patrick Habimana reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m4/essai-support.svg",
      "word": "essai support"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/raisonnement-deductif.svg",
      "word": "raisonnement deductif"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/craie-memoire.svg",
      "word": "craie memoire"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/editorial-accords.svg",
      "word": "editorial accords"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « La craie a un angle » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Le tableau de la cour : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : raisonnement déductif ; intérêt d'un support pédagogique.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on tienne le craie pour une vérité sans source, une pédagogie qui n'avoue pas ses angles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Ce que l'on nomme support, ici, n'est pas un slogan : outil pédagogique, avec un angle.
Encore que l'on démontre, une pédagogie qui n'avoue pas ses angles n'est pas un détail.
Aline Uwase concède que un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Autrement dit, il ressort qu'un support se juge à ce qu'il permet de déduire, et à ce qu'il empêche de voir
Il ressort qu'un essai : intérêt, angle mort, usage sous le figuier
Il ressort que l'intérêt existe, et l'angle mort aussi.
Solange demande les sources de la craie.
La proposition qui reste debout est celle-ci : un essai : intérêt, angle mort, usage sous le figuier
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le support d'Aline d'un côté, la critique de Patrick de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Aline Uwase concède que un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre."
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
      "text": "un tableau fixe l'attention — à condition que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre",
      "correct": true
    },
    {
      "text": "Aline Uwase abandonne il s'agit d'enseigner une mémoire, pas une obéissance",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "support",
      "right": "outil pédagogique, avec un angle"
    },
    {
      "left": "déduction",
      "right": "enchaînement justifié à partir du tableau"
    },
    {
      "left": "angle",
      "right": "part d'ombre d'un outil"
    },
    {
      "left": "essai",
      "right": "texte argumenté sur un intérêt pédagogique"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl appert que support n'est pas un slogan.",
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
  "word": "angle",
  "hint": "part d'ombre d'un outil"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aline Uwase écoute encore, et il fautons démontrer avant de crier.",
  "correct_sentence": "Aline Uwase écoute encore, et il faut démontrer avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m4/raisonnement-deductif.svg",
      "word": "raisonnement deductif"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/craie-memoire.svg",
      "word": "craie memoire"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/editorial-accords.svg",
      "word": "editorial accords"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/plan-chrono.svg",
      "word": "plan chrono"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur raisonnement déductif ; intérêt d'un support pédagogique, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le support d'Aline et la critique de Patrick distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Aline Uwase',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Démontrer l'intérêt d'un support inventé pour enseigner une mémoire de cour. Point : raisonnement déductif ; intérêt d'un support pédagogique.

Consigne
Imitez le texte de Aline Uwase.

Support — Aline Uwase — La craie a un angle
Aline Uwase — La craie a un angle
On parle trop vite de un support trop controversé d'Aline, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne le craie pour une vérité sans source, une pédagogie qui n'avoue pas ses angles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Ce que l'on nomme support, ici, n'est pas un slogan : outil pédagogique, avec un angle.
Selon Aline, le tableau aide à déduire ; d'après Patrick, il aide trop.
Solange demande les sources de la craie.
Sami déduit trop vite ; on le ralentit.
Mado glisse une ironie sur la craie.
La proposition qui reste debout est celle-ci : un essai : intérêt, angle mort, usage sous le figuier
Marc : un essai pédagogique avoue ses angles.
Nous clôturons sans fusionner les voix : le support d'Aline d'un côté, la critique de Patrick de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on démontre, une pédagogie qui n'avoue pas ses angles n'est pas un détail.
Aline Uwase concède que un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il ressort qu'un support se juge à ce qu'il permet de déduire, et à ce qu'il empêche de voir
Aline Uwase, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un essai : intérêt, angle mort, usage sous le figuier",
  "correct": true,
  "explanation": "un essai : intérêt, angle mort, usage sous le figuier"
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
      "text": "un essai : intérêt, angle mort, usage sous le figuier",
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
  "explanation": "un essai : intérêt, angle mort, usage sous le figuier"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "support",
      "right": "outil pédagogique, avec un angle"
    },
    {
      "left": "déduction",
      "right": "enchaînement justifié à partir du tableau"
    },
    {
      "left": "angle",
      "right": "part d'ombre d'un outil"
    },
    {
      "left": "essai",
      "right": "texte argumenté sur un intérêt pédagogique"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ les deux sources, on ne les fusionne pas. (démontrer, subj.)",
  "answer": "démontre"
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
    "démontre",
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
  "word": "essai",
  "hint": "texte argumenté sur un intérêt pédagogique"
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
      "image_path": "/elearning/mfk-c2-m4/craie-memoire.svg",
      "word": "craie memoire"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/editorial-accords.svg",
      "word": "editorial accords"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/plan-chrono.svg",
      "word": "plan chrono"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/assemblee-rive.svg",
      "word": "assemblee rive"
    }
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
    'EL — raisonnement déductif ; intérêt d''un support pédagogique',
    'EL',
    $c$Objectif
Maîtriser raisonnement déductif ; intérêt d'un support pédagogique au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — raisonnement déductif ; intérêt d'un support pédagogique
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on démontre, une pédagogie qui n'avoue pas ses angles n'est pas un détail.
Aline Uwase concède que un tableau fixe l'attention, pour autant que l'on y lise aussi ce qu'il éclaire trop, ce qu'il laisse dans l'ombre.
Autrement dit, il ressort qu'un support se juge à ce qu'il permet de déduire, et à ce qu'il empêche de voir
Il ressort qu'un essai : intérêt, angle mort, usage sous le figuier
Piège : fusionner les sources au lieu de les attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme support, ici, n'est pas un slogan : outil pédagogique, avec un angle.
Il ressort que l'intérêt existe, et l'angle mort aussi.
Solange demande les sources de la craie.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au angle pour de vrai genre, et Patrick Habimana demande un registre plus net.
Correction : On va au angle vraiment, et Patrick Habimana demande un registre plus net.
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
      "left": "support",
      "right": "outil pédagogique, avec un angle"
    },
    {
      "left": "déduction",
      "right": "enchaînement justifié à partir du tableau"
    },
    {
      "left": "angle",
      "right": "part d'ombre d'un outil"
    },
    {
      "left": "essai",
      "right": "texte argumenté sur un intérêt pédagogique"
    }
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
  "sentence_with_error": "On va au angle pour de vrai genre, et Patrick Habimana demande un registre plus net.",
  "correct_sentence": "On va au angle vraiment, et Patrick Habimana demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m4/editorial-accords.svg",
      "word": "editorial accords"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/plan-chrono.svg",
      "word": "plan chrono"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/assemblee-rive.svg",
      "word": "assemblee rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/carte-pactes.svg",
      "word": "carte pactes"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « raisonnement déductif ; intérêt d'un support pédagogique » et deux pièges commentés."
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

  -- ===== Éditorial des pactes =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Éditorial des pactes'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Éditorial des pactes', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Éditorial des pactes',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Rédiger un éditorial sur des pactes de cour, sans copier un traité réel. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Éditorial des pactes
Lila Sow : Radio Figuier. On parle trop vite de les pactes de la rive, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface les désaccords datés, un éditorial trop lyrique pour être historique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Marc Nkurunziza concède que un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Aline Uwase : Ce que l'on nomme pacte, ici, n'est pas un slogan : accord daté de cour, avec cessions.
Patrick Habimana : Marc : selon les minutes, le premier jeudi a cédé une heure ; le deuxième une rampe ; le troisième un silence.
Hawa Diallo : D'après Solange, l'hymne arrivait trop tôt.
Joël Mugisha : Il ressort qu'un pacte se raconte, il ne se chante pas.
Rose Iradukunda : Aline veut la chronologie.
Solange Mukamana : Lila lira l'éditorial sans fanfare.
Karim Bamba : Patrick refuse la carte trop grande.
Félicie Ndayishimiye : Un chiffre, une trace : Marc a daté trois jeudis ; nommé Solange et Joël ; raturé l'union trop large.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'accords de cour, pas d'une carte d'États
Yvette : Yvette se souvient du troisième jeudi.
Mado : Solange Mukamana entend, dans « l'union fait la force », ceci qui n'est pas dit : l'union fait la force dispense trop souvent de dire qui a porté
Sami : Autrement dit, un éditorial C2 a un plan chronologique, des noms, une ironie contre le lyrique trop facile
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un éditorial : trois dates inventées de cour, un pacte, une rampe
Nina Kayitesi : Nina : un accord de rive n'est pas un empire.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les minutes trop lyriques d'un côté, l'éditorial de Marc de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : L'union fait la force : on aimerait connaître le nom de ceux qui, dans l'union, portent.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un éditorial trop lyrique pour être historique est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un éditorial trop lyrique pour être historique n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Solange Mukamana, que reste-t-il implicite dans « l'union fait la force » ?",
  "options": [
    {
      "text": "Que Marc a écrit un hymne sans dates",
      "correct": false
    },
    {
      "text": "Qui a porté",
      "correct": true
    },
    {
      "text": "Que Solange a disparu du texte",
      "correct": false
    },
    {
      "text": "Que Joël n'a pas de rampe dans le pacte",
      "correct": false
    }
  ],
  "explanation": "l'union fait la force dispense trop souvent de dire qui a porté"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "pacte",
      "right": "accord daté de cour, avec cessions"
    },
    {
      "left": "éditorial",
      "right": "texte d'opinion sourcé"
    },
    {
      "left": "chronologie",
      "right": "ordre des faits, plus qu'un hymne"
    },
    {
      "left": "cession",
      "right": "ce que l'on a lâché pour signer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSelon Marc, il ___ que deux documents s'opposent. (ressortir)",
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
    "Marc",
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
  "word": "pacte",
  "hint": "accord daté de cour, avec cessions"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Selon Marc Nkurunziza, il ressort que les deux textes est d'accord, et Lila coupe le micro.",
  "correct_sentence": "Selon Marc Nkurunziza, il ressort que les deux textes sont d'accord, et Lila coupe le micro.",
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
      "image_path": "/elearning/mfk-c2-m4/plan-chrono.svg",
      "word": "plan chrono"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/assemblee-rive.svg",
      "word": "assemblee rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/carte-pactes.svg",
      "word": "carte pactes"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/souvenons-nous.svg",
      "word": "souvenons nous"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « l'union fait la force » et la concession de Marc Nkurunziza."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les minutes trop lyriques et l'éditorial de Marc distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Des dates, pas un hymne',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rédiger un éditorial sur des pactes de cour, sans copier un traité réel. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Des dates, pas un hymne », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Des dates, pas un hymne
On parle trop vite de les pactes de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface les désaccords datés, un éditorial trop lyrique pour être historique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Ce que l'on nomme pacte, ici, n'est pas un slogan : accord daté de cour, avec cessions.
Marc : selon les minutes, le premier jeudi a cédé une heure ; le deuxième une rampe ; le troisième un silence.
D'après Solange, l'hymne arrivait trop tôt.
Il ressort qu'un pacte se raconte, il ne se chante pas.
Aline veut la chronologie.
Lila lira l'éditorial sans fanfare.
Patrick refuse la carte trop grande.
Un chiffre, une trace : Marc a daté trois jeudis ; nommé Solange et Joël ; raturé l'union trop large.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'accords de cour, pas d'une carte d'États
Yvette se souvient du troisième jeudi.
Solange Mukamana entend, dans « l'union fait la force », ceci qui n'est pas dit : l'union fait la force dispense trop souvent de dire qui a porté
Autrement dit, un éditorial C2 a un plan chronologique, des noms, une ironie contre le lyrique trop facile
La proposition qui reste debout est celle-ci : un éditorial : trois dates inventées de cour, un pacte, une rampe
Nina : un accord de rive n'est pas un empire.
Nous clôturons sans fusionner les voix : les minutes trop lyriques d'un côté, l'éditorial de Marc de l'autre, et le point où elles refusent de se ressembler.
Signé : Marc Nkurunziza, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les minutes trop lyriques et l'éditorial de Marc en une seule affiche.",
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
      "text": "Trois jeudis, deux noms, union raturée",
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
  "explanation": "Marc a daté trois jeudis ; nommé Solange et Joël ; raturé l'union trop large."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "pacte",
      "right": "accord daté de cour, avec cessions"
    },
    {
      "left": "éditorial",
      "right": "texte d'opinion sourcé"
    },
    {
      "left": "chronologie",
      "right": "ordre des faits, plus qu'un hymne"
    },
    {
      "left": "cession",
      "right": "ce que l'on a lâché pour signer"
    }
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
  "word": "éditorial",
  "hint": "texte d'opinion sourcé"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La pacte de trop vite n'aide personne, et Solange Mukamana reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Solange Mukamana reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m4/assemblee-rive.svg",
      "word": "assemblee rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/carte-pactes.svg",
      "word": "carte pactes"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/souvenons-nous.svg",
      "word": "souvenons nous"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/discours-officiel.svg",
      "word": "discours officiel"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Des dates, pas un hymne » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Éditorial des pactes : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : plan chronologique ; éditorial ; accords de rive inventés.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on efface les désaccords datés, un éditorial trop lyrique pour être historique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Ce que l'on nomme pacte, ici, n'est pas un slogan : accord daté de cour, avec cessions.
Encore que l'on date, un éditorial trop lyrique pour être historique n'est pas un détail.
Marc Nkurunziza concède que un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Autrement dit, un éditorial C2 a un plan chronologique, des noms, une ironie contre le lyrique trop facile
Il ressort qu'un éditorial : trois dates inventées de cour, un pacte, une rampe
D'après Solange, l'hymne arrivait trop tôt.
Lila lira l'éditorial sans fanfare.
La proposition qui reste debout est celle-ci : un éditorial : trois dates inventées de cour, un pacte, une rampe
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les minutes trop lyriques d'un côté, l'éditorial de Marc de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Marc Nkurunziza transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Marc Nkurunziza concède que un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Marc Nkurunziza, et à quelle condition ?",
  "options": [
    {
      "text": "Marc Nkurunziza n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "un pacte peut protéger — à condition que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe",
      "correct": true
    },
    {
      "text": "Marc Nkurunziza abandonne il s'agit d'accords de cour, pas d'une carte d'États",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "pacte",
      "right": "accord daté de cour, avec cessions"
    },
    {
      "left": "éditorial",
      "right": "texte d'opinion sourcé"
    },
    {
      "left": "chronologie",
      "right": "ordre des faits, plus qu'un hymne"
    },
    {
      "left": "cession",
      "right": "ce que l'on a lâché pour signer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl appert que pacte n'est pas un slogan.",
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
  "word": "chronologie",
  "hint": "ordre des faits, plus qu'un hymne"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Marc Nkurunziza écoute encore, et il fautons dater avant de crier.",
  "correct_sentence": "Marc Nkurunziza écoute encore, et il faut dater avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m4/carte-pactes.svg",
      "word": "carte pactes"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/souvenons-nous.svg",
      "word": "souvenons nous"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/discours-officiel.svg",
      "word": "discours officiel"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/chronique-guerre.svg",
      "word": "chronique guerre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur plan chronologique ; éditorial ; accords de rive inventés, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les minutes trop lyriques et l'éditorial de Marc distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Marc Nkurunziza',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Rédiger un éditorial sur des pactes de cour, sans copier un traité réel. Point : plan chronologique ; éditorial ; accords de rive inventés.

Consigne
Imitez le texte de Marc Nkurunziza.

Support — Marc Nkurunziza — Des dates, pas un hymne
Marc Nkurunziza — Des dates, pas un hymne
On parle trop vite de les pactes de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface les désaccords datés, un éditorial trop lyrique pour être historique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Ce que l'on nomme pacte, ici, n'est pas un slogan : accord daté de cour, avec cessions.
Marc : selon les minutes, le premier jeudi a cédé une heure ; le deuxième une rampe ; le troisième un silence.
Lila lira l'éditorial sans fanfare.
Patrick refuse la carte trop grande.
Yvette se souvient du troisième jeudi.
La proposition qui reste debout est celle-ci : un éditorial : trois dates inventées de cour, un pacte, une rampe
Nina : un accord de rive n'est pas un empire.
Nous clôturons sans fusionner les voix : les minutes trop lyriques d'un côté, l'éditorial de Marc de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on date, un éditorial trop lyrique pour être historique n'est pas un détail.
Marc Nkurunziza concède que un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
un éditorial C2 a un plan chronologique, des noms, une ironie contre le lyrique trop facile
Marc Nkurunziza, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un éditorial : trois dates inventées de cour, un pacte, une rampe",
  "correct": true,
  "explanation": "un éditorial : trois dates inventées de cour, un pacte, une rampe"
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
      "text": "un éditorial : trois dates inventées de cour, un pacte, une rampe",
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
  "explanation": "un éditorial : trois dates inventées de cour, un pacte, une rampe"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "pacte",
      "right": "accord daté de cour, avec cessions"
    },
    {
      "left": "éditorial",
      "right": "texte d'opinion sourcé"
    },
    {
      "left": "chronologie",
      "right": "ordre des faits, plus qu'un hymne"
    },
    {
      "left": "cession",
      "right": "ce que l'on a lâché pour signer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ les deux sources, on ne les fusionne pas. (dater, subj.)",
  "answer": "date"
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
    "date",
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
  "word": "cession",
  "hint": "ce que l'on a lâché pour signer"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Marc Nkurunziza est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Marc Nkurunziza sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c2-m4/souvenons-nous.svg",
      "word": "souvenons nous"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/discours-officiel.svg",
      "word": "discours officiel"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/chronique-guerre.svg",
      "word": "chronique guerre"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/veillee-noms.svg",
      "word": "veillee noms"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Marc Nkurunziza : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — plan chronologique ; éditorial ; accords de rive inventés',
    'EL',
    $c$Objectif
Maîtriser plan chronologique ; éditorial ; accords de rive inventés au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — plan chronologique ; éditorial ; accords de rive inventés
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on date, un éditorial trop lyrique pour être historique n'est pas un détail.
Marc Nkurunziza concède que un pacte peut protéger, pour autant que l'on raconte dans quel ordre, qui a cédé, qui a gagné une rampe.
Autrement dit, un éditorial C2 a un plan chronologique, des noms, une ironie contre le lyrique trop facile
Il ressort qu'un éditorial : trois dates inventées de cour, un pacte, une rampe
Piège : fusionner les sources au lieu de les attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme pacte, ici, n'est pas un slogan : accord daté de cour, avec cessions.
D'après Solange, l'hymne arrivait trop tôt.
Lila lira l'éditorial sans fanfare.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au chronologie pour de vrai genre, et Solange Mukamana demande un registre plus net.
Correction : On va au chronologie vraiment, et Solange Mukamana demande un registre plus net.
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
      "left": "pacte",
      "right": "accord daté de cour, avec cessions"
    },
    {
      "left": "éditorial",
      "right": "texte d'opinion sourcé"
    },
    {
      "left": "chronologie",
      "right": "ordre des faits, plus qu'un hymne"
    },
    {
      "left": "cession",
      "right": "ce que l'on a lâché pour signer"
    }
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
  "sentence_with_error": "On va au chronologie pour de vrai genre, et Solange Mukamana demande un registre plus net.",
  "correct_sentence": "On va au chronologie vraiment, et Solange Mukamana demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m4/discours-officiel.svg",
      "word": "discours officiel"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/chronique-guerre.svg",
      "word": "chronique guerre"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/veillee-noms.svg",
      "word": "veillee noms"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/plaidoirie-cour.svg",
      "word": "plaidoirie cour"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « plan chronologique ; éditorial ; accords de rive inventés » et deux pièges commentés."
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

  -- ===== Les noms avant la formule =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Les noms avant la formule'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Les noms avant la formule', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Les noms avant la formule',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Analyser un discours de veillée et enregistrer une chronique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Les noms avant la formule
Lila Sow : Radio Figuier. On parle trop vite de la veillée sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on tienne lieu de travail de mémoire, une formule trop lisse pour les noms trop précis n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Yvette concède que une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Aline Uwase : Ce que l'on nomme veillée, ici, n'est pas un slogan : temps de mémoire, avec des noms.
Patrick Habimana : Yvette : loin de rassembler, le slogan trop tôt dispersait les noms.
Hawa Diallo : Patrick refuse l'oubli poli.
Joël Mugisha : Aline analyse le discours : qui parle, pour qui, ce qu'il évite.
Rose Iradukunda : Lila ralentit.
Solange Mukamana : Solange pose une lanterne, pas une formule.
Karim Bamba : Sami se tait, pour une fois juste.
Félicie Ndayishimiye : Un chiffre, une trace : Yvette a nommé sept personnes ; Lila a gardé un silence ; le slogan trop lisse a été reculé.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de se souvenir, pas de se donner le change
Yvette : Mado écrit les sept prénoms.
Mado : Patrick Habimana entend, dans « plus jamais ça », ceci qui n'est pas dit : plus jamais ça trop seul permet de ne plus nommer
Sami : Autrement dit, une chronique C2 ralentit le slogan, rend les noms, refuse l'oubli poli
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un discours lu, une chronique : noms, silence, ce que le slogan évitait
Nina Kayitesi : Marc : une chronique de mémoire se juge à ce qu'elle n'a pas lissé.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le discours trop lisse d'un côté, la chronique d'Yvette de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Plus jamais ça : on notera la commodité d'un ça qui n'a plus à porter de prénom.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une formule trop lisse pour les noms trop précis est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une formule trop lisse pour les noms trop précis n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Patrick Habimana, que reste-t-il implicite dans « plus jamais ça » ?",
  "options": [
    {
      "text": "Que Yvette a refusé les noms",
      "correct": false
    },
    {
      "text": "Ne plus nommer",
      "correct": true
    },
    {
      "text": "Que Patrick a crié le slogan",
      "correct": false
    },
    {
      "text": "Que Lila a coupé tous les silences",
      "correct": false
    }
  ],
  "explanation": "plus jamais ça trop seul permet de ne plus nommer"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "veillée",
      "right": "temps de mémoire, avec des noms"
    },
    {
      "left": "discours",
      "right": "parole publique à analyser"
    },
    {
      "left": "chronique",
      "right": "texte parlé, plus lent qu'un slogan"
    },
    {
      "left": "oubli",
      "right": "politesse trop commode"
    }
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
  "word": "veillée",
  "hint": "temps de mémoire, avec des noms"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tant est que le bonheur s'industrialise, il se vend déjà, et Yvette sourit trop large.",
  "correct_sentence": "Si tant est que le bonheur s'industrialise, il se vendrait déjà, et Yvette sourit trop large.",
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
      "image_path": "/elearning/mfk-c2-m4/chronique-guerre.svg",
      "word": "chronique guerre"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/veillee-noms.svg",
      "word": "veillee noms"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/plaidoirie-cour.svg",
      "word": "plaidoirie cour"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/contexte-opinion.svg",
      "word": "contexte opinion"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « plus jamais ça » et la concession de Yvette."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le discours trop lisse et la chronique d'Yvette distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Les noms avant la formule',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Analyser un discours de veillée et enregistrer une chronique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Les noms avant la formule », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Les noms avant la formule
On parle trop vite de la veillée sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu de travail de mémoire, une formule trop lisse pour les noms trop précis n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Yvette concède que une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Ce que l'on nomme veillée, ici, n'est pas un slogan : temps de mémoire, avec des noms.
Yvette : loin de rassembler, le slogan trop tôt dispersait les noms.
Patrick refuse l'oubli poli.
Aline analyse le discours : qui parle, pour qui, ce qu'il évite.
Lila ralentit.
Solange pose une lanterne, pas une formule.
Sami se tait, pour une fois juste.
Un chiffre, une trace : Yvette a nommé sept personnes ; Lila a gardé un silence ; le slogan trop lisse a été reculé.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de se souvenir, pas de se donner le change
Mado écrit les sept prénoms.
Patrick Habimana entend, dans « plus jamais ça », ceci qui n'est pas dit : plus jamais ça trop seul permet de ne plus nommer
Autrement dit, une chronique C2 ralentit le slogan, rend les noms, refuse l'oubli poli
La proposition qui reste debout est celle-ci : un discours lu, une chronique : noms, silence, ce que le slogan évitait
Marc : une chronique de mémoire se juge à ce qu'elle n'a pas lissé.
Nous clôturons sans fusionner les voix : le discours trop lisse d'un côté, la chronique d'Yvette de l'autre, et le point où elles refusent de se ressembler.
Signé : Yvette, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le discours trop lisse et la chronique d'Yvette en une seule affiche.",
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
      "text": "Sept noms, un silence, slogan reculé",
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
  "explanation": "Yvette a nommé sept personnes ; Lila a gardé un silence ; le slogan trop lisse a été reculé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "veillée",
      "right": "temps de mémoire, avec des noms"
    },
    {
      "left": "discours",
      "right": "parole publique à analyser"
    },
    {
      "left": "chronique",
      "right": "texte parlé, plus lent qu'un slogan"
    },
    {
      "left": "oubli",
      "right": "politesse trop commode"
    }
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
  "word": "discours",
  "hint": "parole publique à analyser"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La veillée de trop vite n'aide personne, et Patrick Habimana reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Patrick Habimana reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m4/veillee-noms.svg",
      "word": "veillee noms"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/plaidoirie-cour.svg",
      "word": "plaidoirie cour"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/contexte-opinion.svg",
      "word": "contexte opinion"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/plan-avocat.svg",
      "word": "plan avocat"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Les noms avant la formule » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Les noms avant la formule : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : analyse d'un discours ; chronique de veillée ; mémoire.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on tienne lieu de travail de mémoire, une formule trop lisse pour les noms trop précis n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Yvette concède que une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Ce que l'on nomme veillée, ici, n'est pas un slogan : temps de mémoire, avec des noms.
Encore que l'on nomme, une formule trop lisse pour les noms trop précis n'est pas un détail.
Yvette concède que une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Autrement dit, une chronique C2 ralentit le slogan, rend les noms, refuse l'oubli poli
Il ressort qu'un discours lu, une chronique : noms, silence, ce que le slogan évitait
Patrick refuse l'oubli poli.
Solange pose une lanterne, pas une formule.
La proposition qui reste debout est celle-ci : un discours lu, une chronique : noms, silence, ce que le slogan évitait
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le discours trop lisse d'un côté, la chronique d'Yvette de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Yvette transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Yvette concède que une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Yvette, et à quelle condition ?",
  "options": [
    {
      "text": "Yvette n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "une formule peut rassembler — à condition que l'on dise ensuite qui, quand, comment l'on veille",
      "correct": true
    },
    {
      "text": "Yvette abandonne il s'agit de se souvenir, pas de se donner le change",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on dise ensuite qui, quand, comment l'on veille"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "veillée",
      "right": "temps de mémoire, avec des noms"
    },
    {
      "left": "discours",
      "right": "parole publique à analyser"
    },
    {
      "left": "chronique",
      "right": "texte parlé, plus lent qu'un slogan"
    },
    {
      "left": "oubli",
      "right": "politesse trop commode"
    }
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
  "word": "chronique",
  "hint": "texte parlé, plus lent qu'un slogan"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Yvette écoute encore, et il fautons nommer avant de crier.",
  "correct_sentence": "Yvette écoute encore, et il faut nommer avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m4/plaidoirie-cour.svg",
      "word": "plaidoirie cour"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/contexte-opinion.svg",
      "word": "contexte opinion"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/plan-avocat.svg",
      "word": "plan avocat"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/balance-justice.svg",
      "word": "balance justice"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur analyse d'un discours ; chronique de veillée ; mémoire, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le discours trop lisse et la chronique d'Yvette distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Yvette',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Analyser un discours de veillée et enregistrer une chronique. Point : analyse d'un discours ; chronique de veillée ; mémoire.

Consigne
Imitez le texte de Yvette.

Support — Yvette — Les noms avant la formule
Yvette — Les noms avant la formule
On parle trop vite de la veillée sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu de travail de mémoire, une formule trop lisse pour les noms trop précis n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Yvette concède que une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Ce que l'on nomme veillée, ici, n'est pas un slogan : temps de mémoire, avec des noms.
Yvette : loin de rassembler, le slogan trop tôt dispersait les noms.
Solange pose une lanterne, pas une formule.
Sami se tait, pour une fois juste.
Mado écrit les sept prénoms.
La proposition qui reste debout est celle-ci : un discours lu, une chronique : noms, silence, ce que le slogan évitait
Marc : une chronique de mémoire se juge à ce qu'elle n'a pas lissé.
Nous clôturons sans fusionner les voix : le discours trop lisse d'un côté, la chronique d'Yvette de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on nomme, une formule trop lisse pour les noms trop précis n'est pas un détail.
Yvette concède que une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
une chronique C2 ralentit le slogan, rend les noms, refuse l'oubli poli
Yvette, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un discours lu, une chronique : noms, silence, ce que le slogan évitait",
  "correct": true,
  "explanation": "un discours lu, une chronique : noms, silence, ce que le slogan évitait"
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
      "text": "un discours lu, une chronique : noms, silence, ce que le slogan évitait",
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
  "explanation": "un discours lu, une chronique : noms, silence, ce que le slogan évitait"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "veillée",
      "right": "temps de mémoire, avec des noms"
    },
    {
      "left": "discours",
      "right": "parole publique à analyser"
    },
    {
      "left": "chronique",
      "right": "texte parlé, plus lent qu'un slogan"
    },
    {
      "left": "oubli",
      "right": "politesse trop commode"
    }
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
  "word": "oubli",
  "hint": "politesse trop commode"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Yvette est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Yvette sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c2-m4/contexte-opinion.svg",
      "word": "contexte opinion"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/plan-avocat.svg",
      "word": "plan avocat"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/balance-justice.svg",
      "word": "balance justice"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/histoire-memoire.svg",
      "word": "histoire memoire"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Yvette : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — analyse d''un discours ; chronique de veillée ; mémoire',
    'EL',
    $c$Objectif
Maîtriser analyse d'un discours ; chronique de veillée ; mémoire au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — analyse d'un discours ; chronique de veillée ; mémoire
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on nomme, une formule trop lisse pour les noms trop précis n'est pas un détail.
Yvette concède que une formule peut rassembler, pour autant que l'on dise ensuite qui, quand, comment l'on veille.
Autrement dit, une chronique C2 ralentit le slogan, rend les noms, refuse l'oubli poli
Il ressort qu'un discours lu, une chronique : noms, silence, ce que le slogan évitait
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme veillée, ici, n'est pas un slogan : temps de mémoire, avec des noms.
Patrick refuse l'oubli poli.
Solange pose une lanterne, pas une formule.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au chronique pour de vrai genre, et Patrick Habimana demande un registre plus net.
Correction : On va au chronique vraiment, et Patrick Habimana demande un registre plus net.
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
      "left": "veillée",
      "right": "temps de mémoire, avec des noms"
    },
    {
      "left": "discours",
      "right": "parole publique à analyser"
    },
    {
      "left": "chronique",
      "right": "texte parlé, plus lent qu'un slogan"
    },
    {
      "left": "oubli",
      "right": "politesse trop commode"
    }
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
  "sentence_with_error": "On va au chronique pour de vrai genre, et Patrick Habimana demande un registre plus net.",
  "correct_sentence": "On va au chronique vraiment, et Patrick Habimana demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m4/plan-avocat.svg",
      "word": "plan avocat"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/balance-justice.svg",
      "word": "balance justice"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/histoire-memoire.svg",
      "word": "histoire memoire"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/cahier-racines-vieux.svg",
      "word": "cahier racines vieux"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « analyse d'un discours ; chronique de veillée ; mémoire » et deux pièges commentés."
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

  -- ===== Plaidoirie sous le figuier =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Plaidoirie sous le figuier'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Plaidoirie sous le figuier', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Plaidoirie sous le figuier',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Analyser et rédiger le plan d'une plaidoirie inventée, sans procès d'État. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Plaidoirie sous le figuier
Lila Sow : Radio Figuier. On parle trop vite de une plaidoirie au Bureau des Escales, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace le plan par la rumeur, un contexte trop bruyant pour une introduction nette n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande.
Aline Uwase : Ce que l'on nomme plaidoirie, ici, n'est pas un slogan : discours de demande, avec un plan.
Patrick Habimana : Solange : il convient que l'on introduise les faits, encore que le fil ait déjà crié.
Hawa Diallo : Marc place la rumeur en note.
Joël Mugisha : Aline veut les textes de cour.
Rose Iradukunda : Lila n'enregistrera pas un spectacle.
Solange Mukamana : Patrick chronomètre l'introduction.
Karim Bamba : Yvette écoute comme si les noms étaient là.
Félicie Ndayishimiye : Un chiffre, une trace : Solange a tenu quatre parties ; reculé la rumeur en note ; lu l'introduction en trois minutes.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une justice de cour, pas d'un spectacle
Yvette : Dieudonné tient la porte.
Mado : Marc Nkurunziza entend, dans « l'opinion a déjà jugé », ceci qui n'est pas dit : l'opinion a déjà jugé invite à n'avoir plus de plan
Sami : Autrement dit, il convient que l'introduction nomme le contexte sans s'y noyer
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un plan : faits, textes, contexte, demande ; puis l'introduction lue
Nina Kayitesi : Léa : une plaidoirie C2 a un plan, ou n'est qu'un bruit.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le bruit du fil d'un côté, le plan de Solange de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : L'opinion a déjà jugé : on appréciera la modestie de ceux qui n'ont pas à ouvrir un dossier.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un contexte trop bruyant pour une introduction nette est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un contexte trop bruyant pour une introduction nette n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Marc Nkurunziza, que reste-t-il implicite dans « l'opinion a déjà jugé » ?",
  "options": [
    {
      "text": "Que Solange a commencé par la rumeur",
      "correct": false
    },
    {
      "text": "N'avoir plus de plan",
      "correct": true
    },
    {
      "text": "Que Marc a jugé avant le plan",
      "correct": false
    },
    {
      "text": "Que le Bureau est un État",
      "correct": false
    }
  ],
  "explanation": "l'opinion a déjà jugé invite à n'avoir plus de plan"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plaidoirie",
      "right": "discours de demande, avec un plan"
    },
    {
      "left": "contexte",
      "right": "bruit autour, à nommer sans s'y noyer"
    },
    {
      "left": "introduction",
      "right": "ouverture, trois minutes ici"
    },
    {
      "left": "demande",
      "right": "ce que l'on exige du Bureau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ avant d'accélérer. (introduire, subj.)",
  "answer": "introduise"
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
    "introduise",
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
  "word": "plaidoirie",
  "hint": "discours de demande, avec un plan"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il convient que l'on introduire trop tard, et Solange Mukamana refuse d'accélérer la pente.",
  "correct_sentence": "Il convient que l'on introduise trop tard, et Solange Mukamana refuse d'accélérer la pente.",
  "explanation": "Il convient que + introduise."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m4/balance-justice.svg",
      "word": "balance justice"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/histoire-memoire.svg",
      "word": "histoire memoire"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/cahier-racines-vieux.svg",
      "word": "cahier racines vieux"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/micro-hier.svg",
      "word": "micro hier"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « l'opinion a déjà jugé » et la concession de Solange Mukamana."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le bruit du fil et le plan de Solange distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — La rumeur en note, pas en tête',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Analyser et rédiger le plan d'une plaidoirie inventée, sans procès d'État. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « La rumeur en note, pas en tête », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La rumeur en note, pas en tête
On parle trop vite de une plaidoirie au Bureau des Escales, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le plan par la rumeur, un contexte trop bruyant pour une introduction nette n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande.
Ce que l'on nomme plaidoirie, ici, n'est pas un slogan : discours de demande, avec un plan.
Solange : il convient que l'on introduise les faits, encore que le fil ait déjà crié.
Marc place la rumeur en note.
Aline veut les textes de cour.
Lila n'enregistrera pas un spectacle.
Patrick chronomètre l'introduction.
Yvette écoute comme si les noms étaient là.
Un chiffre, une trace : Solange a tenu quatre parties ; reculé la rumeur en note ; lu l'introduction en trois minutes.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une justice de cour, pas d'un spectacle
Dieudonné tient la porte.
Marc Nkurunziza entend, dans « l'opinion a déjà jugé », ceci qui n'est pas dit : l'opinion a déjà jugé invite à n'avoir plus de plan
Autrement dit, il convient que l'introduction nomme le contexte sans s'y noyer
La proposition qui reste debout est celle-ci : un plan : faits, textes, contexte, demande ; puis l'introduction lue
Léa : une plaidoirie C2 a un plan, ou n'est qu'un bruit.
Nous clôturons sans fusionner les voix : le bruit du fil d'un côté, le plan de Solange de l'autre, et le point où elles refusent de se ressembler.
Signé : Solange Mukamana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le bruit du fil et le plan de Solange en une seule affiche.",
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
      "text": "Quatre parties, rumeur en note, trois minutes",
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
  "explanation": "Solange a tenu quatre parties ; reculé la rumeur en note ; lu l'introduction en trois minutes."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plaidoirie",
      "right": "discours de demande, avec un plan"
    },
    {
      "left": "contexte",
      "right": "bruit autour, à nommer sans s'y noyer"
    },
    {
      "left": "introduction",
      "right": "ouverture, trois minutes ici"
    },
    {
      "left": "demande",
      "right": "ce que l'on exige du Bureau"
    }
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
  "word": "contexte",
  "hint": "bruit autour, à nommer sans s'y noyer"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La plaidoirie de trop vite n'aide personne, et Marc Nkurunziza reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Marc Nkurunziza reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m4/histoire-memoire.svg",
      "word": "histoire memoire"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/cahier-racines-vieux.svg",
      "word": "cahier racines vieux"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/micro-hier.svg",
      "word": "micro hier"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/urne-parole.svg",
      "word": "urne parole"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « La rumeur en note, pas en tête » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Plaidoirie sous le figuier : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : plan d'une plaidoirie ; contexte et opinion ; justice de cour.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace le plan par la rumeur, un contexte trop bruyant pour une introduction nette n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande.
Ce que l'on nomme plaidoirie, ici, n'est pas un slogan : discours de demande, avec un plan.
Encore que l'on introduise, un contexte trop bruyant pour une introduction nette n'est pas un détail.
Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande.
Autrement dit, il convient que l'introduction nomme le contexte sans s'y noyer
Il ressort qu'un plan : faits, textes, contexte, demande ; puis l'introduction lue
Marc place la rumeur en note.
Patrick chronomètre l'introduction.
La proposition qui reste debout est celle-ci : un plan : faits, textes, contexte, demande ; puis l'introduction lue
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le bruit du fil d'un côté, le plan de Solange de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Solange Mukamana transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Solange Mukamana, et à quelle condition ?",
  "options": [
    {
      "text": "Solange Mukamana n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "l'opinion pèse — à condition que l'on commence pourtant par les faits, les textes de cour, la demande",
      "correct": true
    },
    {
      "text": "Solange Mukamana abandonne il s'agit d'une justice de cour, pas d'un spectacle",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on commence pourtant par les faits, les textes de cour, la demande"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plaidoirie",
      "right": "discours de demande, avec un plan"
    },
    {
      "left": "contexte",
      "right": "bruit autour, à nommer sans s'y noyer"
    },
    {
      "left": "introduction",
      "right": "ouverture, trois minutes ici"
    },
    {
      "left": "demande",
      "right": "ce que l'on exige du Bureau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous recommandons que la cour ___ un relais. (introduire, subj.)",
  "answer": "introduise"
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
    "introduise",
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
  "word": "introduction",
  "hint": "ouverture, trois minutes ici"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Solange Mukamana écoute encore, et il fautons introduire avant de crier.",
  "correct_sentence": "Solange Mukamana écoute encore, et il faut introduire avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m4/cahier-racines-vieux.svg",
      "word": "cahier racines vieux"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/micro-hier.svg",
      "word": "micro hier"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/urne-parole.svg",
      "word": "urne parole"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/figuier-archive.svg",
      "word": "figuier archive"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur plan d'une plaidoirie ; contexte et opinion ; justice de cour, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le bruit du fil et le plan de Solange distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Solange Mukamana',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Analyser et rédiger le plan d'une plaidoirie inventée, sans procès d'État. Point : plan d'une plaidoirie ; contexte et opinion ; justice de cour.

Consigne
Imitez le texte de Solange Mukamana.

Support — Solange Mukamana — La rumeur en note, pas en tête
Solange Mukamana — La rumeur en note, pas en tête
On parle trop vite de une plaidoirie au Bureau des Escales, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le plan par la rumeur, un contexte trop bruyant pour une introduction nette n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande.
Ce que l'on nomme plaidoirie, ici, n'est pas un slogan : discours de demande, avec un plan.
Solange : il convient que l'on introduise les faits, encore que le fil ait déjà crié.
Patrick chronomètre l'introduction.
Yvette écoute comme si les noms étaient là.
Dieudonné tient la porte.
La proposition qui reste debout est celle-ci : un plan : faits, textes, contexte, demande ; puis l'introduction lue
Léa : une plaidoirie C2 a un plan, ou n'est qu'un bruit.
Nous clôturons sans fusionner les voix : le bruit du fil d'un côté, le plan de Solange de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on introduise, un contexte trop bruyant pour une introduction nette n'est pas un détail.
Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il convient que l'introduction nomme le contexte sans s'y noyer
Solange Mukamana, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un plan : faits, textes, contexte, demande ; puis l'introduction lue",
  "correct": true,
  "explanation": "un plan : faits, textes, contexte, demande ; puis l'introduction lue"
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
      "text": "un plan : faits, textes, contexte, demande ; puis l'introduction lue",
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
  "explanation": "un plan : faits, textes, contexte, demande ; puis l'introduction lue"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plaidoirie",
      "right": "discours de demande, avec un plan"
    },
    {
      "left": "contexte",
      "right": "bruit autour, à nommer sans s'y noyer"
    },
    {
      "left": "introduction",
      "right": "ouverture, trois minutes ici"
    },
    {
      "left": "demande",
      "right": "ce que l'on exige du Bureau"
    }
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
  "word": "demande",
  "hint": "ce que l'on exige du Bureau"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Solange Mukamana est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Solange Mukamana sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c2-m4/micro-hier.svg",
      "word": "micro hier"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/urne-parole.svg",
      "word": "urne parole"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/figuier-archive.svg",
      "word": "figuier archive"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/soleil-deuil.svg",
      "word": "soleil deuil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Solange Mukamana : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — plan d''une plaidoirie ; contexte et opinion ; justice de cour',
    'EL',
    $c$Objectif
Maîtriser plan d'une plaidoirie ; contexte et opinion ; justice de cour au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — plan d'une plaidoirie ; contexte et opinion ; justice de cour
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on introduise, un contexte trop bruyant pour une introduction nette n'est pas un détail.
Solange Mukamana concède que l'opinion pèse, pour autant que l'on commence pourtant par les faits, les textes de cour, la demande.
Autrement dit, il convient que l'introduction nomme le contexte sans s'y noyer
Il ressort qu'un plan : faits, textes, contexte, demande ; puis l'introduction lue
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme plaidoirie, ici, n'est pas un slogan : discours de demande, avec un plan.
Marc place la rumeur en note.
Patrick chronomètre l'introduction.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au introduction pour de vrai genre, et Marc Nkurunziza demande un registre plus net.
Correction : On va au introduction vraiment, et Marc Nkurunziza demande un registre plus net.
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
      "left": "plaidoirie",
      "right": "discours de demande, avec un plan"
    },
    {
      "left": "contexte",
      "right": "bruit autour, à nommer sans s'y noyer"
    },
    {
      "left": "introduction",
      "right": "ouverture, trois minutes ici"
    },
    {
      "left": "demande",
      "right": "ce que l'on exige du Bureau"
    }
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
  "sentence_with_error": "On va au introduction pour de vrai genre, et Marc Nkurunziza demande un registre plus net.",
  "correct_sentence": "On va au introduction vraiment, et Marc Nkurunziza demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m4/urne-parole.svg",
      "word": "urne parole"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/figuier-archive.svg",
      "word": "figuier archive"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/soleil-deuil.svg",
      "word": "soleil deuil"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/nuage-oubli.svg",
      "word": "nuage oubli"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « plan d'une plaidoirie ; contexte et opinion ; justice de cour » et deux pièges commentés."
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

  -- ===== Essai du support =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Essai du support'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Essai du support', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Essai du support',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Rédiger l'essai promis : intérêt d'un support pour une mémoire de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Essai du support
Lila Sow : Radio Figuier. On parle trop vite de l'essai d'Aline relu par la cour, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on dispense de l'angle mort, un donc trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Aline Uwase : Ce que l'on nomme intérêt, ici, n'est pas un slogan : ce que le support permet, à démontrer.
Patrick Habimana : Patrick : selon le tableau, l'on déduit plus vite ; d'après Yvette, l'on nomme moins.
Hawa Diallo : Il ressort qu'un essai tient les deux.
Joël Mugisha : Aline accepte l'angle.
Rose Iradukunda : Lila lira lentement.
Solange Mukamana : Solange veut l'usage concret.
Karim Bamba : Sami s'ennuie d'un tampon.
Félicie Ndayishimiye : Un chiffre, une trace : Patrick a gardé l'intérêt ; nommé l'angle ; proposé un usage ; refusé le donc.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'un essai, pas d'un tampon
Yvette : Mado glisse une phrase sur le donc.
Mado : Aline Uwase entend, dans « c'est pédagogique donc c'est bien », ceci qui n'est pas dit : donc c'est bien évite l'essai véritable
Sami : Autrement dit, selon le support, on déduit ; d'après les noms, on doute ; il ressort qu'il faut les deux
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un essai de vingt lignes : intérêt, angle, usage, limite
Nina Kayitesi : Marc : un essai C2 se relit, il ne se tamponne pas.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le brouillon trop sûr d'un côté, l'essai de Patrick de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : C'est pédagogique donc c'est bien : syllogisme dont on aimerait voir la mineure.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un donc trop généreux est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un donc trop généreux n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Aline Uwase, que reste-t-il implicite dans « c'est pédagogique donc c'est bien » ?",
  "options": [
    {
      "text": "Que Patrick a refusé tout support",
      "correct": false
    },
    {
      "text": "Éviter l'essai véritable",
      "correct": true
    },
    {
      "text": "Que Aline a exigé le donc",
      "correct": false
    },
    {
      "text": "Que les noms n'apparaissent pas dans l'essai",
      "correct": false
    }
  ],
  "explanation": "donc c'est bien évite l'essai véritable"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "intérêt",
      "right": "ce que le support permet, à démontrer"
    },
    {
      "left": "limite",
      "right": "ce qu'il empêche de voir"
    },
    {
      "left": "usage",
      "right": "manière de s'en servir sous le figuier"
    },
    {
      "left": "tampon",
      "right": "approbation trop vite donnée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSelon Patrick, il ___ que deux documents s'opposent. (ressortir)",
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
    "Patrick",
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
  "word": "intérêt",
  "hint": "ce que le support permet, à démontrer"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Selon Patrick Habimana, il ressort que les deux textes est d'accord, et Lila coupe le micro.",
  "correct_sentence": "Selon Patrick Habimana, il ressort que les deux textes sont d'accord, et Lila coupe le micro.",
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
      "image_path": "/elearning/mfk-c2-m4/figuier-archive.svg",
      "word": "figuier archive"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/soleil-deuil.svg",
      "word": "soleil deuil"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/nuage-oubli.svg",
      "word": "nuage oubli"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/feuille-plaidoirie.svg",
      "word": "feuille plaidoirie"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « c'est pédagogique donc c'est bien » et la concession de Patrick Habimana."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le brouillon trop sûr et l'essai de Patrick distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le donc n''est pas un essai',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rédiger l'essai promis : intérêt d'un support pour une mémoire de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le donc n'est pas un essai », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le donc n'est pas un essai
On parle trop vite de l'essai d'Aline relu par la cour, comme si le mot dispensait d'en examiner le prix.
Encore que l'on dispense de l'angle mort, un donc trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Ce que l'on nomme intérêt, ici, n'est pas un slogan : ce que le support permet, à démontrer.
Patrick : selon le tableau, l'on déduit plus vite ; d'après Yvette, l'on nomme moins.
Il ressort qu'un essai tient les deux.
Aline accepte l'angle.
Lila lira lentement.
Solange veut l'usage concret.
Sami s'ennuie d'un tampon.
Un chiffre, une trace : Patrick a gardé l'intérêt ; nommé l'angle ; proposé un usage ; refusé le donc.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'un essai, pas d'un tampon
Mado glisse une phrase sur le donc.
Aline Uwase entend, dans « c'est pédagogique donc c'est bien », ceci qui n'est pas dit : donc c'est bien évite l'essai véritable
Autrement dit, selon le support, on déduit ; d'après les noms, on doute ; il ressort qu'il faut les deux
La proposition qui reste debout est celle-ci : un essai de vingt lignes : intérêt, angle, usage, limite
Marc : un essai C2 se relit, il ne se tamponne pas.
Nous clôturons sans fusionner les voix : le brouillon trop sûr d'un côté, l'essai de Patrick de l'autre, et le point où elles refusent de se ressembler.
Signé : Patrick Habimana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le brouillon trop sûr et l'essai de Patrick en une seule affiche.",
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
      "text": "Intérêt, angle, usage, donc refusé",
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
  "explanation": "Patrick a gardé l'intérêt ; nommé l'angle ; proposé un usage ; refusé le donc."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "intérêt",
      "right": "ce que le support permet, à démontrer"
    },
    {
      "left": "limite",
      "right": "ce qu'il empêche de voir"
    },
    {
      "left": "usage",
      "right": "manière de s'en servir sous le figuier"
    },
    {
      "left": "tampon",
      "right": "approbation trop vite donnée"
    }
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
  "word": "limite",
  "hint": "ce qu'il empêche de voir"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La intérêt de trop vite n'aide personne, et Aline Uwase reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Aline Uwase reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m4/soleil-deuil.svg",
      "word": "soleil deuil"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/nuage-oubli.svg",
      "word": "nuage oubli"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/feuille-plaidoirie.svg",
      "word": "feuille plaidoirie"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/radio-memoire.svg",
      "word": "radio memoire"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le donc n'est pas un essai » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Essai du support : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : essai argumenté ; déduction ; pédagogie de mémoire.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on dispense de l'angle mort, un donc trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Ce que l'on nomme intérêt, ici, n'est pas un slogan : ce que le support permet, à démontrer.
Encore que l'on examine, un donc trop généreux n'est pas un détail.
Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Autrement dit, selon le support, on déduit ; d'après les noms, on doute ; il ressort qu'il faut les deux
Il ressort qu'un essai de vingt lignes : intérêt, angle, usage, limite
Il ressort qu'un essai tient les deux.
Solange veut l'usage concret.
La proposition qui reste debout est celle-ci : un essai de vingt lignes : intérêt, angle, usage, limite
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le brouillon trop sûr d'un côté, l'essai de Patrick de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms."
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
      "text": "pédagogique peut être une qualité — à condition que l'on examine encore ce que le support fait aux noms",
      "correct": true
    },
    {
      "text": "Patrick Habimana abandonne il s'agit d'un essai, pas d'un tampon",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on examine encore ce que le support fait aux noms"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "intérêt",
      "right": "ce que le support permet, à démontrer"
    },
    {
      "left": "limite",
      "right": "ce qu'il empêche de voir"
    },
    {
      "left": "usage",
      "right": "manière de s'en servir sous le figuier"
    },
    {
      "left": "tampon",
      "right": "approbation trop vite donnée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl appert que intérêt n'est pas un slogan.",
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
  "word": "usage",
  "hint": "manière de s'en servir sous le figuier"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Patrick Habimana écoute encore, et il fautons examiner avant de crier.",
  "correct_sentence": "Patrick Habimana écoute encore, et il faut examiner avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m4/nuage-oubli.svg",
      "word": "nuage oubli"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/feuille-plaidoirie.svg",
      "word": "feuille plaidoirie"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/radio-memoire.svg",
      "word": "radio memoire"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/groupe-anciens-soir.svg",
      "word": "groupe anciens soir"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur essai argumenté ; déduction ; pédagogie de mémoire, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le brouillon trop sûr et l'essai de Patrick distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Patrick Habimana',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Rédiger l'essai promis : intérêt d'un support pour une mémoire de cour. Point : essai argumenté ; déduction ; pédagogie de mémoire.

Consigne
Imitez le texte de Patrick Habimana.

Support — Patrick Habimana — Le donc n'est pas un essai
Patrick Habimana — Le donc n'est pas un essai
On parle trop vite de l'essai d'Aline relu par la cour, comme si le mot dispensait d'en examiner le prix.
Encore que l'on dispense de l'angle mort, un donc trop généreux n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Ce que l'on nomme intérêt, ici, n'est pas un slogan : ce que le support permet, à démontrer.
Patrick : selon le tableau, l'on déduit plus vite ; d'après Yvette, l'on nomme moins.
Solange veut l'usage concret.
Sami s'ennuie d'un tampon.
Mado glisse une phrase sur le donc.
La proposition qui reste debout est celle-ci : un essai de vingt lignes : intérêt, angle, usage, limite
Marc : un essai C2 se relit, il ne se tamponne pas.
Nous clôturons sans fusionner les voix : le brouillon trop sûr d'un côté, l'essai de Patrick de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on examine, un donc trop généreux n'est pas un détail.
Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
selon le support, on déduit ; d'après les noms, on doute ; il ressort qu'il faut les deux
Patrick Habimana, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un essai de vingt lignes : intérêt, angle, usage, limite",
  "correct": true,
  "explanation": "un essai de vingt lignes : intérêt, angle, usage, limite"
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
      "text": "un essai de vingt lignes : intérêt, angle, usage, limite",
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
  "explanation": "un essai de vingt lignes : intérêt, angle, usage, limite"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "intérêt",
      "right": "ce que le support permet, à démontrer"
    },
    {
      "left": "limite",
      "right": "ce qu'il empêche de voir"
    },
    {
      "left": "usage",
      "right": "manière de s'en servir sous le figuier"
    },
    {
      "left": "tampon",
      "right": "approbation trop vite donnée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ les deux sources, on ne les fusionne pas. (examiner, subj.)",
  "answer": "examine"
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
    "examine",
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
  "word": "tampon",
  "hint": "approbation trop vite donnée"
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
      "image_path": "/elearning/mfk-c2-m4/feuille-plaidoirie.svg",
      "word": "feuille plaidoirie"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/radio-memoire.svg",
      "word": "radio memoire"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/groupe-anciens-soir.svg",
      "word": "groupe anciens soir"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/main-craie.svg",
      "word": "main craie"
    }
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
    'EL — essai argumenté ; déduction ; pédagogie de mémoire',
    'EL',
    $c$Objectif
Maîtriser essai argumenté ; déduction ; pédagogie de mémoire au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — essai argumenté ; déduction ; pédagogie de mémoire
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on examine, un donc trop généreux n'est pas un détail.
Patrick Habimana concède que pédagogique peut être une qualité, pour autant que l'on examine encore ce que le support fait aux noms.
Autrement dit, selon le support, on déduit ; d'après les noms, on doute ; il ressort qu'il faut les deux
Il ressort qu'un essai de vingt lignes : intérêt, angle, usage, limite
Piège : fusionner les sources au lieu de les attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme intérêt, ici, n'est pas un slogan : ce que le support permet, à démontrer.
Il ressort qu'un essai tient les deux.
Solange veut l'usage concret.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au usage pour de vrai genre, et Aline Uwase demande un registre plus net.
Correction : On va au usage vraiment, et Aline Uwase demande un registre plus net.
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
      "left": "intérêt",
      "right": "ce que le support permet, à démontrer"
    },
    {
      "left": "limite",
      "right": "ce qu'il empêche de voir"
    },
    {
      "left": "usage",
      "right": "manière de s'en servir sous le figuier"
    },
    {
      "left": "tampon",
      "right": "approbation trop vite donnée"
    }
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
  "sentence_with_error": "On va au usage pour de vrai genre, et Aline Uwase demande un registre plus net.",
  "correct_sentence": "On va au usage vraiment, et Aline Uwase demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m4/radio-memoire.svg",
      "word": "radio memoire"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/groupe-anciens-soir.svg",
      "word": "groupe anciens soir"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/main-craie.svg",
      "word": "main craie"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/porte-archives.svg",
      "word": "porte archives"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « essai argumenté ; déduction ; pédagogie de mémoire » et deux pièges commentés."
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

  -- ===== Chronique de veillée =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Chronique de veillée'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Chronique de veillée', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Chronique de veillée',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Enregistrer la chronique finale de mémoire, C2. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Chronique de veillée
Lila Sow : Radio Figuier. On parle trop vite de la chronique que Lila n'adoucira pas, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme la veillée en décor, un bel qui n'a plus de prénoms n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Lila Sow concède que une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Aline Uwase : Ce que l'on nomme cérémonie, ici, n'est pas un slogan : forme, trop vite dite belle.
Patrick Habimana : Lila : loin d'adoucir, j'ai coupé le bel.
Hawa Diallo : Yvette entend les prénoms.
Joël Mugisha : Aline accepte le silence.
Rose Iradukunda : Patrick refuse la fête.
Solange Mukamana : Sami se tait encore.
Karim Bamba : Mado écrit juste.
Félicie Ndayishimiye : Un chiffre, une trace : Lila a lu sept noms ; gardé huit secondes ; coupé belle cérémonie.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une voix de radio qui ne se donne pas le change
Yvette : Solange pose la lanterne.
Mado : Yvette entend, dans « une belle cérémonie », ceci qui n'est pas dit : belle cérémonie est déjà un oubli poli
Sami : Autrement dit, loin d'être belle, la veillée fut juste, ce qui est autre chose, et plus difficile
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une chronique de quatre minutes : noms, un silence, un refus du bel
Nina Kayitesi : Marc : une chronique C2 se juge à ce qu'elle n'a pas trop poli.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le rush trop soigné d'un côté, la chronique retenue de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Une belle cérémonie : on reconnaît le compliment de ceux qui n'avaient personne à nommer.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un bel qui n'a plus de prénoms est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un bel qui n'a plus de prénoms n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Yvette, que reste-t-il implicite dans « une belle cérémonie » ?",
  "options": [
    {
      "text": "Que Lila a gardé belle cérémonie",
      "correct": false
    },
    {
      "text": "Un oubli poli",
      "correct": true
    },
    {
      "text": "Que Yvette a exigé une fête",
      "correct": false
    },
    {
      "text": "Que les sept noms ont disparu",
      "correct": false
    }
  ],
  "explanation": "belle cérémonie est déjà un oubli poli"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cérémonie",
      "right": "forme, trop vite dite belle"
    },
    {
      "left": "prénom",
      "right": "nom propre, travail de mémoire"
    },
    {
      "left": "rush",
      "right": "enregistrement brut, à raturer"
    },
    {
      "left": "justesse",
      "right": "qualité distincte de la beauté d'affiche"
    }
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
  "word": "cérémonie",
  "hint": "forme, trop vite dite belle"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tant est que le bonheur s'industrialise, il se vend déjà, et Lila Sow sourit trop large.",
  "correct_sentence": "Si tant est que le bonheur s'industrialise, il se vendrait déjà, et Lila Sow sourit trop large.",
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
      "image_path": "/elearning/mfk-c2-m4/groupe-anciens-soir.svg",
      "word": "groupe anciens soir"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/main-craie.svg",
      "word": "main craie"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/porte-archives.svg",
      "word": "porte archives"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/lampe-veillee.svg",
      "word": "lampe veillee"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « une belle cérémonie » et la concession de Lila Sow."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le rush trop soigné et la chronique retenue distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Juste, pas belle',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Enregistrer la chronique finale de mémoire, C2. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Juste, pas belle », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Juste, pas belle
On parle trop vite de la chronique que Lila n'adoucira pas, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme la veillée en décor, un bel qui n'a plus de prénoms n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Ce que l'on nomme cérémonie, ici, n'est pas un slogan : forme, trop vite dite belle.
Lila : loin d'adoucir, j'ai coupé le bel.
Yvette entend les prénoms.
Aline accepte le silence.
Patrick refuse la fête.
Sami se tait encore.
Mado écrit juste.
Un chiffre, une trace : Lila a lu sept noms ; gardé huit secondes ; coupé belle cérémonie.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une voix de radio qui ne se donne pas le change
Solange pose la lanterne.
Yvette entend, dans « une belle cérémonie », ceci qui n'est pas dit : belle cérémonie est déjà un oubli poli
Autrement dit, loin d'être belle, la veillée fut juste, ce qui est autre chose, et plus difficile
La proposition qui reste debout est celle-ci : une chronique de quatre minutes : noms, un silence, un refus du bel
Marc : une chronique C2 se juge à ce qu'elle n'a pas trop poli.
Nous clôturons sans fusionner les voix : le rush trop soigné d'un côté, la chronique retenue de l'autre, et le point où elles refusent de se ressembler.
Signé : Lila Sow, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le rush trop soigné et la chronique retenue en une seule affiche.",
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
      "text": "Sept noms, huit secondes, bel coupé",
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
  "explanation": "Lila a lu sept noms ; gardé huit secondes ; coupé belle cérémonie."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cérémonie",
      "right": "forme, trop vite dite belle"
    },
    {
      "left": "prénom",
      "right": "nom propre, travail de mémoire"
    },
    {
      "left": "rush",
      "right": "enregistrement brut, à raturer"
    },
    {
      "left": "justesse",
      "right": "qualité distincte de la beauté d'affiche"
    }
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
  "word": "prénom",
  "hint": "nom propre, travail de mémoire"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La cérémonie de trop vite n'aide personne, et Yvette reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Yvette reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m4/main-craie.svg",
      "word": "main craie"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/porte-archives.svg",
      "word": "porte archives"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/lampe-veillee.svg",
      "word": "lampe veillee"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/coeur-souvenir.svg",
      "word": "coeur souvenir"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Juste, pas belle » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Chronique de veillée : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : voix de chronique ; noms ; silence.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme la veillée en décor, un bel qui n'a plus de prénoms n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Ce que l'on nomme cérémonie, ici, n'est pas un slogan : forme, trop vite dite belle.
Encore que l'on adoucisse, un bel qui n'a plus de prénoms n'est pas un détail.
Lila Sow concède que une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Autrement dit, loin d'être belle, la veillée fut juste, ce qui est autre chose, et plus difficile
Il ressort qu'une chronique de quatre minutes : noms, un silence, un refus du bel
Yvette entend les prénoms.
Sami se tait encore.
La proposition qui reste debout est celle-ci : une chronique de quatre minutes : noms, un silence, un refus du bel
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le rush trop soigné d'un côté, la chronique retenue de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Lila Sow transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Lila Sow concède que une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Lila Sow, et à quelle condition ?",
  "options": [
    {
      "text": "Lila Sow n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "une forme soignée aide l'oreille — à condition que l'on n'y lise pas une fête",
      "correct": true
    },
    {
      "text": "Lila Sow abandonne il s'agit d'une voix de radio qui ne se donne pas le change",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y lise pas une fête"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cérémonie",
      "right": "forme, trop vite dite belle"
    },
    {
      "left": "prénom",
      "right": "nom propre, travail de mémoire"
    },
    {
      "left": "rush",
      "right": "enregistrement brut, à raturer"
    },
    {
      "left": "justesse",
      "right": "qualité distincte de la beauté d'affiche"
    }
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
  "word": "rush",
  "hint": "enregistrement brut, à raturer"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lila Sow écoute encore, et il fautons adoucir avant de crier.",
  "correct_sentence": "Lila Sow écoute encore, et il faut adoucir avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m4/porte-archives.svg",
      "word": "porte archives"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/lampe-veillee.svg",
      "word": "lampe veillee"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/coeur-souvenir.svg",
      "word": "coeur souvenir"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/tableau-pedago.svg",
      "word": "tableau pedago"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur voix de chronique ; noms ; silence, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le rush trop soigné et la chronique retenue distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Lila Sow',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Enregistrer la chronique finale de mémoire, C2. Point : voix de chronique ; noms ; silence.

Consigne
Imitez le texte de Lila Sow.

Support — Lila Sow — Juste, pas belle
Lila Sow — Juste, pas belle
On parle trop vite de la chronique que Lila n'adoucira pas, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme la veillée en décor, un bel qui n'a plus de prénoms n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Ce que l'on nomme cérémonie, ici, n'est pas un slogan : forme, trop vite dite belle.
Lila : loin d'adoucir, j'ai coupé le bel.
Sami se tait encore.
Mado écrit juste.
Solange pose la lanterne.
La proposition qui reste debout est celle-ci : une chronique de quatre minutes : noms, un silence, un refus du bel
Marc : une chronique C2 se juge à ce qu'elle n'a pas trop poli.
Nous clôturons sans fusionner les voix : le rush trop soigné d'un côté, la chronique retenue de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on adoucisse, un bel qui n'a plus de prénoms n'est pas un détail.
Lila Sow concède que une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
loin d'être belle, la veillée fut juste, ce qui est autre chose, et plus difficile
Lila Sow, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : une chronique de quatre minutes : noms, un silence, un refus du bel",
  "correct": true,
  "explanation": "une chronique de quatre minutes : noms, un silence, un refus du bel"
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
      "text": "une chronique de quatre minutes : noms, un silence, un refus du bel",
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
  "explanation": "une chronique de quatre minutes : noms, un silence, un refus du bel"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cérémonie",
      "right": "forme, trop vite dite belle"
    },
    {
      "left": "prénom",
      "right": "nom propre, travail de mémoire"
    },
    {
      "left": "rush",
      "right": "enregistrement brut, à raturer"
    },
    {
      "left": "justesse",
      "right": "qualité distincte de la beauté d'affiche"
    }
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
  "word": "justesse",
  "hint": "qualité distincte de la beauté d'affiche"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Lila Sow est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Lila Sow sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c2-m4/lampe-veillee.svg",
      "word": "lampe veillee"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/coeur-souvenir.svg",
      "word": "coeur souvenir"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/tableau-pedago.svg",
      "word": "tableau pedago"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/essai-support.svg",
      "word": "essai support"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Lila Sow : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — voix de chronique ; noms ; silence',
    'EL',
    $c$Objectif
Maîtriser voix de chronique ; noms ; silence au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — voix de chronique ; noms ; silence
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on adoucisse, un bel qui n'a plus de prénoms n'est pas un détail.
Lila Sow concède que une forme soignée aide l'oreille, pour autant que l'on n'y lise pas une fête.
Autrement dit, loin d'être belle, la veillée fut juste, ce qui est autre chose, et plus difficile
Il ressort qu'une chronique de quatre minutes : noms, un silence, un refus du bel
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme cérémonie, ici, n'est pas un slogan : forme, trop vite dite belle.
Yvette entend les prénoms.
Sami se tait encore.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au rush pour de vrai genre, et Yvette demande un registre plus net.
Correction : On va au rush vraiment, et Yvette demande un registre plus net.
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
      "left": "cérémonie",
      "right": "forme, trop vite dite belle"
    },
    {
      "left": "prénom",
      "right": "nom propre, travail de mémoire"
    },
    {
      "left": "rush",
      "right": "enregistrement brut, à raturer"
    },
    {
      "left": "justesse",
      "right": "qualité distincte de la beauté d'affiche"
    }
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
  "sentence_with_error": "On va au rush pour de vrai genre, et Yvette demande un registre plus net.",
  "correct_sentence": "On va au rush vraiment, et Yvette demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m4/coeur-souvenir.svg",
      "word": "coeur souvenir"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/tableau-pedago.svg",
      "word": "tableau pedago"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/essai-support.svg",
      "word": "essai support"
    },
    {
      "image_path": "/elearning/mfk-c2-m4/raisonnement-deductif.svg",
      "word": "raisonnement deductif"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « voix de chronique ; noms ; silence » et deux pièges commentés."
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
