/*
  Seed eLearning MFK — C2 — Révolutions de la rive

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-c2-m6/
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
  v_module_title text := 'C2 — Révolutions de la rive';
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
      'Grande étape C2-6 : exposer des hypothèses de crue, répondre aux doutes trop commodes, proposer des mesures de cour, mettre en scène un personnage de roman, puis un compte-rendu et un programme — Oscar Niyitegeka lit la terre, Nina Kayitesi refuse le déni poli, Félicie Ndayishimiye change un geste sans se vanter.',
      'C2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape C2-6 : exposer des hypothèses de crue, répondre aux doutes trop commodes, proposer des mesures de cour, mettre en scène un personnage de roman, puis un compte-rendu et un programme — Oscar Niyitegeka lit la terre, Nina Kayitesi refuse le déni poli, Félicie Ndayishimiye change un geste sans se vanter.',
      cefr_level = 'C2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== La crue trop tôt =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'La crue trop tôt'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'La crue trop tôt', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La crue trop tôt',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Faire des hypothèses sur une crue inventée et exposer des conséquences. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — La crue trop tôt
Lila Sow : Radio Figuier. On parle trop vite de la crue trop tôt de la rive, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on reporte l'hypothèse à plus tard, un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer.
Aline Uwase : Ce que l'on nomme crue, ici, n'est pas un slogan : montée d'eau trop tôt, mesurée.
Patrick Habimana : Oscar : la part de terre trop tôt mouillée s'établit à ce que le saule sait déjà.
Hawa Diallo : Nina dessine la conséquence.
Joël Mugisha : Aline : l'hypothèse n'est pas une panique.
Rose Iradukunda : Félicie entend la terre.
Solange Mukamana : Lila n'adoucira pas.
Karim Bamba : Karim chiffre sans sentence.
Félicie Ndayishimiye : Un chiffre, une trace : Oscar a mesuré deux crues trop tôt ; trois jardins plus bas ; une ombre de moins.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une rive, pas d'un spectacle de fin du monde
Yvette : Joël demande le relais.
Mado : Nina Kayitesi entend, dans « on verra bien », ceci qui n'est pas dit : on verra bien est la phrase de ceux dont le jardin n'est pas le premier mouillé
Sami : Autrement dit, s'il montait encore, le saule perdrait ; il se peut que l'on ait encore un relais
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un compte-rendu oral : hypothèses, conséquences, un geste de rive
Nina Kayitesi : Marc : un compte-rendu climat de cour nomme le jardin, pas la planète abstraite.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les mesures d'Oscar d'un côté, l'émission trop calme de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : On verra bien : futur d'une sérénité qui n'habite pas le premier jardin.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un plus tard qui n'a pas d'ombre à midi déjà trop blanc est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Nina Kayitesi, que reste-t-il implicite dans « on verra bien » ?",
  "options": [
    {
      "text": "Que Oscar a inventé les mesures",
      "correct": false
    },
    {
      "text": "Le jardin n'est pas le premier mouillé",
      "correct": true
    },
    {
      "text": "Que Nina refuse toute hypothèse",
      "correct": false
    },
    {
      "text": "Que le saule a déjà disparu dans le rapport",
      "correct": false
    }
  ],
  "explanation": "on verra bien est la phrase de ceux dont le jardin n'est pas le premier mouillé"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "crue",
      "right": "montée d'eau trop tôt, mesurée"
    },
    {
      "left": "hypothèse",
      "right": "si…, à exposer sans excuse"
    },
    {
      "left": "biodiversité",
      "right": "vies de la rive, pas un décor"
    },
    {
      "left": "conséquence",
      "right": "effet nommé, distinct d'un spectacle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa part de bols trop salés s'___ à près d'un tiers. (établir)",
  "answer": "établit"
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
    "part",
    "de",
    "bols",
    "trop",
    "salés",
    "s'établit",
    "à",
    "près",
    "d'un",
    "tiers",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "crue",
  "hint": "montée d'eau trop tôt, mesurée"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La part de bols trop salés s'établissent à un tiers, et Oscar Niyitegeka refuse d'en faire une morale.",
  "correct_sentence": "La part de bols trop salés s'établit à un tiers, et Oscar Niyitegeka refuse d'en faire une morale.",
  "explanation": "La part … s'établit (singulier)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m6/rapport-alarmant.svg",
      "word": "rapport alarmant"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/biodiversite-rive.svg",
      "word": "biodiversite rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/hypothese-climat.svg",
      "word": "hypothese climat"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/graphique-crue.svg",
      "word": "graphique crue"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « on verra bien » et la concession de Oscar Niyitegeka."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les mesures d'Oscar et l'émission trop calme distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le jardin mouillé d''abord',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Faire des hypothèses sur une crue inventée et exposer des conséquences. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le jardin mouillé d'abord », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le jardin mouillé d'abord
On parle trop vite de la crue trop tôt de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on reporte l'hypothèse à plus tard, un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer.
Ce que l'on nomme crue, ici, n'est pas un slogan : montée d'eau trop tôt, mesurée.
Oscar : la part de terre trop tôt mouillée s'établit à ce que le saule sait déjà.
Nina dessine la conséquence.
Aline : l'hypothèse n'est pas une panique.
Félicie entend la terre.
Lila n'adoucira pas.
Karim chiffre sans sentence.
Un chiffre, une trace : Oscar a mesuré deux crues trop tôt ; trois jardins plus bas ; une ombre de moins.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une rive, pas d'un spectacle de fin du monde
Joël demande le relais.
Nina Kayitesi entend, dans « on verra bien », ceci qui n'est pas dit : on verra bien est la phrase de ceux dont le jardin n'est pas le premier mouillé
Autrement dit, s'il montait encore, le saule perdrait ; il se peut que l'on ait encore un relais
La proposition qui reste debout est celle-ci : un compte-rendu oral : hypothèses, conséquences, un geste de rive
Marc : un compte-rendu climat de cour nomme le jardin, pas la planète abstraite.
Nous clôturons sans fusionner les voix : les mesures d'Oscar d'un côté, l'émission trop calme de l'autre, et le point où elles refusent de se ressembler.
Signé : Oscar Niyitegeka, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les mesures d'Oscar et l'émission trop calme en une seule affiche.",
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
      "text": "Deux crues trop tôt, trois jardins plus bas",
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
  "explanation": "Oscar a mesuré deux crues trop tôt ; trois jardins plus bas ; une ombre de moins."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "crue",
      "right": "montée d'eau trop tôt, mesurée"
    },
    {
      "left": "hypothèse",
      "right": "si…, à exposer sans excuse"
    },
    {
      "left": "biodiversité",
      "right": "vies de la rive, pas un décor"
    },
    {
      "left": "conséquence",
      "right": "effet nommé, distinct d'un spectacle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCes chiffres ___ une peur, ils ne la prouvent pas à eux seuls. (illustrer)",
  "answer": "illustrent"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ces",
    "chiffres",
    "illustrent",
    "une",
    "peur",
    "ils",
    "ne",
    "la",
    "prouvent",
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
  "word": "hypothèse",
  "hint": "si…, à exposer sans excuse"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La crue de trop vite n'aide personne, et Nina Kayitesi reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Nina Kayitesi reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m6/biodiversite-rive.svg",
      "word": "biodiversite rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/hypothese-climat.svg",
      "word": "hypothese climat"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/graphique-crue.svg",
      "word": "graphique crue"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/consensus-argument.svg",
      "word": "consensus argument"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le jardin mouillé d'abord » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — La crue trop tôt : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : hypothèses ; conséquences ; biodiversité de rive.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on reporte l'hypothèse à plus tard, un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer.
Ce que l'on nomme crue, ici, n'est pas un slogan : montée d'eau trop tôt, mesurée.
Encore que l'on expose, un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail.
Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer.
Autrement dit, s'il montait encore, le saule perdrait ; il se peut que l'on ait encore un relais
Il ressort qu'un compte-rendu oral : hypothèses, conséquences, un geste de rive
Nina dessine la conséquence.
Lila n'adoucira pas.
La proposition qui reste debout est celle-ci : un compte-rendu oral : hypothèses, conséquences, un geste de rive
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les mesures d'Oscar d'un côté, l'émission trop calme de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Oscar Niyitegeka transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Oscar Niyitegeka, et à quelle condition ?",
  "options": [
    {
      "text": "Oscar Niyitegeka n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "l'incertitude existe — à condition que l'on n'en fasse pas une excuse pour ne pas exposer",
      "correct": true
    },
    {
      "text": "Oscar Niyitegeka abandonne il s'agit d'une rive, pas d'un spectacle de fin du monde",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'en fasse pas une excuse pour ne pas exposer"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "crue",
      "right": "montée d'eau trop tôt, mesurée"
    },
    {
      "left": "hypothèse",
      "right": "si…, à exposer sans excuse"
    },
    {
      "left": "biodiversité",
      "right": "vies de la rive, pas un décor"
    },
    {
      "left": "conséquence",
      "right": "effet nommé, distinct d'un spectacle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAlors que le sel ___, le jardin tient encore. (monter)",
  "answer": "monte"
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
    "que",
    "le",
    "sel",
    "monte",
    "le",
    "jardin",
    "tient",
    "encore",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "biodiversité",
  "hint": "vies de la rive, pas un décor"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Oscar Niyitegeka écoute encore, et il fautons exposer avant de crier.",
  "correct_sentence": "Oscar Niyitegeka écoute encore, et il faut exposer avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m6/hypothese-climat.svg",
      "word": "hypothese climat"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/graphique-crue.svg",
      "word": "graphique crue"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/consensus-argument.svg",
      "word": "consensus argument"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/reponse-doute.svg",
      "word": "reponse doute"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur hypothèses ; conséquences ; biodiversité de rive, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les mesures d'Oscar et l'émission trop calme distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Oscar Niyitegeka',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Faire des hypothèses sur une crue inventée et exposer des conséquences. Point : hypothèses ; conséquences ; biodiversité de rive.

Consigne
Imitez le texte de Oscar Niyitegeka.

Support — Oscar Niyitegeka — Le jardin mouillé d'abord
Oscar Niyitegeka — Le jardin mouillé d'abord
On parle trop vite de la crue trop tôt de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on reporte l'hypothèse à plus tard, un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer.
Ce que l'on nomme crue, ici, n'est pas un slogan : montée d'eau trop tôt, mesurée.
Oscar : la part de terre trop tôt mouillée s'établit à ce que le saule sait déjà.
Lila n'adoucira pas.
Karim chiffre sans sentence.
Joël demande le relais.
La proposition qui reste debout est celle-ci : un compte-rendu oral : hypothèses, conséquences, un geste de rive
Marc : un compte-rendu climat de cour nomme le jardin, pas la planète abstraite.
Nous clôturons sans fusionner les voix : les mesures d'Oscar d'un côté, l'émission trop calme de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on expose, un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail.
Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
s'il montait encore, le saule perdrait ; il se peut que l'on ait encore un relais
Oscar Niyitegeka, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un compte-rendu oral : hypothèses, conséquences, un geste de rive",
  "correct": true,
  "explanation": "un compte-rendu oral : hypothèses, conséquences, un geste de rive"
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
      "text": "un compte-rendu oral : hypothèses, conséquences, un geste de rive",
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
  "explanation": "un compte-rendu oral : hypothèses, conséquences, un geste de rive"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "crue",
      "right": "montée d'eau trop tôt, mesurée"
    },
    {
      "left": "hypothèse",
      "right": "si…, à exposer sans excuse"
    },
    {
      "left": "biodiversité",
      "right": "vies de la rive, pas un décor"
    },
    {
      "left": "conséquence",
      "right": "effet nommé, distinct d'un spectacle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl conviendrait que l'on ___ sans crier. (exposer, subj.)",
  "answer": "expose"
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
    "conviendrait",
    "que",
    "l'on",
    "expose",
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
  "word": "conséquence",
  "hint": "effet nommé, distinct d'un spectacle"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Oscar Niyitegeka est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Oscar Niyitegeka sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c2-m6/graphique-crue.svg",
      "word": "graphique crue"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/consensus-argument.svg",
      "word": "consensus argument"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/reponse-doute.svg",
      "word": "reponse doute"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/article-preuve.svg",
      "word": "article preuve"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Oscar Niyitegeka : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — hypothèses ; conséquences ; biodiversité de rive',
    'EL',
    $c$Objectif
Maîtriser hypothèses ; conséquences ; biodiversité de rive au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — hypothèses ; conséquences ; biodiversité de rive
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on expose, un plus tard qui n'a pas d'ombre à midi déjà trop blanc n'est pas un détail.
Oscar Niyitegeka concède que l'incertitude existe, pour autant que l'on n'en fasse pas une excuse pour ne pas exposer.
Autrement dit, s'il montait encore, le saule perdrait ; il se peut que l'on ait encore un relais
Il ressort qu'un compte-rendu oral : hypothèses, conséquences, un geste de rive
Piège : prendre un pourcentage pour une preuve morale
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme crue, ici, n'est pas un slogan : montée d'eau trop tôt, mesurée.
Nina dessine la conséquence.
Lila n'adoucira pas.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au biodiversité pour de vrai genre, et Nina Kayitesi demande un registre plus net.
Correction : On va au biodiversité vraiment, et Nina Kayitesi demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Un chiffre peut illustrer sans conclure à lui seul.",
  "correct": true,
  "explanation": "Prudence énonciative."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment introduire un chiffre sans en faire une sentence ?",
  "options": [
    {
      "text": "s'établir à / illustrer / alors que",
      "correct": true
    },
    {
      "text": "c'est vrai parce que chiffre",
      "correct": false
    },
    {
      "text": "le micro interdit les nombres",
      "correct": false
    },
    {
      "text": "on crie le pourcentage",
      "correct": false
    }
  ],
  "explanation": "Langue des données : s'établir à, illustrer, opposer."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "crue",
      "right": "montée d'eau trop tôt, mesurée"
    },
    {
      "left": "hypothèse",
      "right": "si…, à exposer sans excuse"
    },
    {
      "left": "biodiversité",
      "right": "vies de la rive, pas un décor"
    },
    {
      "left": "conséquence",
      "right": "effet nommé, distinct d'un spectacle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne ___ n'est pas une sentence. (statistique)",
  "answer": "statistique"
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
    "statistique",
    "n'est",
    "pas",
    "une",
    "sentence",
    "."
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
  "sentence_with_error": "On va au biodiversité pour de vrai genre, et Nina Kayitesi demande un registre plus net.",
  "correct_sentence": "On va au biodiversité vraiment, et Nina Kayitesi demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m6/consensus-argument.svg",
      "word": "consensus argument"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/reponse-doute.svg",
      "word": "reponse doute"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/article-preuve.svg",
      "word": "article preuve"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/loupe-chiffre.svg",
      "word": "loupe chiffre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « hypothèses ; conséquences ; biodiversité de rive » et deux pièges commentés."
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

  -- ===== Consensus trop commode =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Consensus trop commode'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Consensus trop commode', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Consensus trop commode',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Rédiger un article qui répond aux doutes trop commodes, sans mépris. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Consensus trop commode
Lila Sow : Radio Figuier. On parle trop vite de le déni poli sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme la mesure en caprice d'Oscar, un doute qui n'a pas visité la rive n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive.
Aline Uwase : Ce que l'on nomme déni, ici, n'est pas un slogan : refus poli de voir, distinct du doute.
Patrick Habimana : Nina : loin de crier, j'aligne.
Hawa Diallo : Karim avait dit pas si grave ; il a vu le jardin.
Joël Mugisha : Oscar n'humilie pas.
Rose Iradukunda : Aline distingue doute et déni.
Solange Mukamana : Lila lira l'article.
Karim Bamba : Félicie pose le bol après la visite.
Félicie Ndayishimiye : Un chiffre, une trace : Nina a emmené trois sceptiques à la rive ; deux ont changé de phrase ; un a gardé pas si grave.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'argumenter, pas d'humilier un doute
Yvette : Patrick veut la stratégie, pas l'insulte.
Mado : Karim Bamba entend, dans « ce n'est pas si grave », ceci qui n'est pas dit : pas si grave veut dire pas chez moi d'abord
Sami : Autrement dit, loin de convaincre par le cri, l'article aligne mesures, visite, conséquence
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un article : doute légitime vs déni poli, preuves de cour, geste
Nina Kayitesi : Marc : répondre au déni poli, c'est une rhétorique, pas une guerre.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les phrases trop calmes du banc d'un côté, l'article de Nina de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Ce n'est pas si grave : on aimerait connaître l'adresse du pas si.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un doute qui n'a pas visité la rive est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un doute qui n'a pas visité la rive n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Karim Bamba, que reste-t-il implicite dans « ce n'est pas si grave » ?",
  "options": [
    {
      "text": "Que Nina a humilié Karim",
      "correct": false
    },
    {
      "text": "Pas chez moi d'abord",
      "correct": true
    },
    {
      "text": "Que Oscar a refusé les visites",
      "correct": false
    },
    {
      "text": "Que les trois sceptiques n'ont pas vu la rive",
      "correct": false
    }
  ],
  "explanation": "pas si grave veut dire pas chez moi d'abord"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "déni",
      "right": "refus poli de voir, distinct du doute"
    },
    {
      "left": "preuve",
      "right": "mesure, visite, pas un cri"
    },
    {
      "left": "sceptique",
      "right": "personne à emmener, pas à humilier"
    },
    {
      "left": "visite",
      "right": "geste argumentatif, aller à la rive"
    }
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
  "word": "déni",
  "hint": "refus poli de voir, distinct du doute"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tant est que le bonheur s'industrialise, il se vend déjà, et Nina Kayitesi sourit trop large.",
  "correct_sentence": "Si tant est que le bonheur s'industrialise, il se vendrait déjà, et Nina Kayitesi sourit trop large.",
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
      "image_path": "/elearning/mfk-c2-m6/reponse-doute.svg",
      "word": "reponse doute"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/article-preuve.svg",
      "word": "article preuve"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/loupe-chiffre.svg",
      "word": "loupe chiffre"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/mesures-politiques.svg",
      "word": "mesures politiques"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « ce n'est pas si grave » et la concession de Nina Kayitesi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les phrases trop calmes du banc et l'article de Nina distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Douter après la rive',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rédiger un article qui répond aux doutes trop commodes, sans mépris. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Douter après la rive », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Douter après la rive
On parle trop vite de le déni poli sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme la mesure en caprice d'Oscar, un doute qui n'a pas visité la rive n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive.
Ce que l'on nomme déni, ici, n'est pas un slogan : refus poli de voir, distinct du doute.
Nina : loin de crier, j'aligne.
Karim avait dit pas si grave ; il a vu le jardin.
Oscar n'humilie pas.
Aline distingue doute et déni.
Lila lira l'article.
Félicie pose le bol après la visite.
Un chiffre, une trace : Nina a emmené trois sceptiques à la rive ; deux ont changé de phrase ; un a gardé pas si grave.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'argumenter, pas d'humilier un doute
Patrick veut la stratégie, pas l'insulte.
Karim Bamba entend, dans « ce n'est pas si grave », ceci qui n'est pas dit : pas si grave veut dire pas chez moi d'abord
Autrement dit, loin de convaincre par le cri, l'article aligne mesures, visite, conséquence
La proposition qui reste debout est celle-ci : un article : doute légitime vs déni poli, preuves de cour, geste
Marc : répondre au déni poli, c'est une rhétorique, pas une guerre.
Nous clôturons sans fusionner les voix : les phrases trop calmes du banc d'un côté, l'article de Nina de l'autre, et le point où elles refusent de se ressembler.
Signé : Nina Kayitesi, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les phrases trop calmes du banc et l'article de Nina en une seule affiche.",
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
      "text": "Trois visites, deux phrases changées, un déni gardé",
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
  "explanation": "Nina a emmené trois sceptiques à la rive ; deux ont changé de phrase ; un a gardé pas si grave."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "déni",
      "right": "refus poli de voir, distinct du doute"
    },
    {
      "left": "preuve",
      "right": "mesure, visite, pas un cri"
    },
    {
      "left": "sceptique",
      "right": "personne à emmener, pas à humilier"
    },
    {
      "left": "visite",
      "right": "geste argumentatif, aller à la rive"
    }
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
  "word": "preuve",
  "hint": "mesure, visite, pas un cri"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La déni de trop vite n'aide personne, et Karim Bamba reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Karim Bamba reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m6/article-preuve.svg",
      "word": "article preuve"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/loupe-chiffre.svg",
      "word": "loupe chiffre"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/mesures-politiques.svg",
      "word": "mesures politiques"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/programme-rive.svg",
      "word": "programme rive"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Douter après la rive » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Consensus trop commode : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : stratégie argumentative ; répondre au déni poli.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme la mesure en caprice d'Oscar, un doute qui n'a pas visité la rive n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive.
Ce que l'on nomme déni, ici, n'est pas un slogan : refus poli de voir, distinct du doute.
Encore que l'on réponde, un doute qui n'a pas visité la rive n'est pas un détail.
Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive.
Autrement dit, loin de convaincre par le cri, l'article aligne mesures, visite, conséquence
Il ressort qu'un article : doute légitime vs déni poli, preuves de cour, geste
Karim avait dit pas si grave ; il a vu le jardin.
Lila lira l'article.
La proposition qui reste debout est celle-ci : un article : doute légitime vs déni poli, preuves de cour, geste
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les phrases trop calmes du banc d'un côté, l'article de Nina de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Nina Kayitesi transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Nina Kayitesi, et à quelle condition ?",
  "options": [
    {
      "text": "Nina Kayitesi n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "douter peut être une méthode — à condition que l'on doute après la rive, pas à la place de la rive",
      "correct": true
    },
    {
      "text": "Nina Kayitesi abandonne il s'agit d'argumenter, pas d'humilier un doute",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on doute après la rive, pas à la place de la rive"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "déni",
      "right": "refus poli de voir, distinct du doute"
    },
    {
      "left": "preuve",
      "right": "mesure, visite, pas un cri"
    },
    {
      "left": "sceptique",
      "right": "personne à emmener, pas à humilier"
    },
    {
      "left": "visite",
      "right": "geste argumentatif, aller à la rive"
    }
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
  "word": "sceptique",
  "hint": "personne à emmener, pas à humilier"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nina Kayitesi écoute encore, et il fautons répondre avant de crier.",
  "correct_sentence": "Nina Kayitesi écoute encore, et il faut répondre avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m6/loupe-chiffre.svg",
      "word": "loupe chiffre"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/mesures-politiques.svg",
      "word": "mesures politiques"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/programme-rive.svg",
      "word": "programme rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/conference-eau.svg",
      "word": "conference eau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur stratégie argumentative ; répondre au déni poli, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les phrases trop calmes du banc et l'article de Nina distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Nina Kayitesi',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Rédiger un article qui répond aux doutes trop commodes, sans mépris. Point : stratégie argumentative ; répondre au déni poli.

Consigne
Imitez le texte de Nina Kayitesi.

Support — Nina Kayitesi — Douter après la rive
Nina Kayitesi — Douter après la rive
On parle trop vite de le déni poli sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme la mesure en caprice d'Oscar, un doute qui n'a pas visité la rive n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive.
Ce que l'on nomme déni, ici, n'est pas un slogan : refus poli de voir, distinct du doute.
Nina : loin de crier, j'aligne.
Lila lira l'article.
Félicie pose le bol après la visite.
Patrick veut la stratégie, pas l'insulte.
La proposition qui reste debout est celle-ci : un article : doute légitime vs déni poli, preuves de cour, geste
Marc : répondre au déni poli, c'est une rhétorique, pas une guerre.
Nous clôturons sans fusionner les voix : les phrases trop calmes du banc d'un côté, l'article de Nina de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on réponde, un doute qui n'a pas visité la rive n'est pas un détail.
Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
loin de convaincre par le cri, l'article aligne mesures, visite, conséquence
Nina Kayitesi, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un article : doute légitime vs déni poli, preuves de cour, geste",
  "correct": true,
  "explanation": "un article : doute légitime vs déni poli, preuves de cour, geste"
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
      "text": "un article : doute légitime vs déni poli, preuves de cour, geste",
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
  "explanation": "un article : doute légitime vs déni poli, preuves de cour, geste"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "déni",
      "right": "refus poli de voir, distinct du doute"
    },
    {
      "left": "preuve",
      "right": "mesure, visite, pas un cri"
    },
    {
      "left": "sceptique",
      "right": "personne à emmener, pas à humilier"
    },
    {
      "left": "visite",
      "right": "geste argumentatif, aller à la rive"
    }
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
  "word": "visite",
  "hint": "geste argumentatif, aller à la rive"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Nina Kayitesi est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Nina Kayitesi sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c2-m6/mesures-politiques.svg",
      "word": "mesures politiques"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/programme-rive.svg",
      "word": "programme rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/conference-eau.svg",
      "word": "conference eau"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/urne-vert.svg",
      "word": "urne vert"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Nina Kayitesi : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — stratégie argumentative ; répondre au déni poli',
    'EL',
    $c$Objectif
Maîtriser stratégie argumentative ; répondre au déni poli au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — stratégie argumentative ; répondre au déni poli
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on réponde, un doute qui n'a pas visité la rive n'est pas un détail.
Nina Kayitesi concède que douter peut être une méthode, pour autant que l'on doute après la rive, pas à la place de la rive.
Autrement dit, loin de convaincre par le cri, l'article aligne mesures, visite, conséquence
Il ressort qu'un article : doute légitime vs déni poli, preuves de cour, geste
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme déni, ici, n'est pas un slogan : refus poli de voir, distinct du doute.
Karim avait dit pas si grave ; il a vu le jardin.
Lila lira l'article.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au sceptique pour de vrai genre, et Karim Bamba demande un registre plus net.
Correction : On va au sceptique vraiment, et Karim Bamba demande un registre plus net.
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
      "left": "déni",
      "right": "refus poli de voir, distinct du doute"
    },
    {
      "left": "preuve",
      "right": "mesure, visite, pas un cri"
    },
    {
      "left": "sceptique",
      "right": "personne à emmener, pas à humilier"
    },
    {
      "left": "visite",
      "right": "geste argumentatif, aller à la rive"
    }
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
  "sentence_with_error": "On va au sceptique pour de vrai genre, et Karim Bamba demande un registre plus net.",
  "correct_sentence": "On va au sceptique vraiment, et Karim Bamba demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m6/programme-rive.svg",
      "word": "programme rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/conference-eau.svg",
      "word": "conference eau"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/urne-vert.svg",
      "word": "urne vert"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/echos-logiques.svg",
      "word": "echos logiques"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « stratégie argumentative ; répondre au déni poli » et deux pièges commentés."
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

  -- ===== Mesures pour la rive =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Mesures pour la rive'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Mesures pour la rive', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Mesures pour la rive',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Proposer des mesures écologiques de cour, datées, finançables. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Mesures pour la rive
Lila Sow : Radio Figuier. On parle trop vite de un programme trop lyrique de la rive, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface le jardin d'Oscar sous un mot trop grand, un programme sans destinataire ni fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Solange Mukamana concède que un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Aline Uwase : Ce que l'on nomme mesure, ici, n'est pas un slogan : geste politique daté, finançable.
Patrick Habimana : Solange : il convient que l'on vote le compost, encore que l'hymne plaise.
Hawa Diallo : Oscar entend son jardin.
Joël Mugisha : Karim chiffre le fer.
Rose Iradukunda : Nina dessine la rampe de crue.
Solange Mukamana : Aline rature planète.
Karim Bamba : Lila lira le programme.
Félicie Ndayishimiye : Un chiffre, une trace : Solange a raturé planète ; gardé compost, relais, heures ; daté deux jeudis.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une politique de rive, pas d'un hymne
Yvette : Joël peut porter.
Mado : Oscar Niyitegeka entend, dans « sauvons la planète », ceci qui n'est pas dit : sauvons la planète permet de ne pas nommer le jeudi et le fer
Sami : Autrement dit, il convient que l'on vote trois mesures, encore que l'on n'ait pas de planète à mettre dans une motion
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un programme de cour : trois mesures, deux dates, un financement inventé du Bureau
Nina Kayitesi : Marc : des mesures C2 ont un destinataire, ou ne sont qu'un nuage.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le brouillon trop lyrique d'un côté, le programme retenu de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Sauvons la planète : on vérifiera si le jeudi, plus modeste, a survécu à la phrase.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un programme sans destinataire ni fer est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un programme sans destinataire ni fer n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Oscar Niyitegeka, que reste-t-il implicite dans « sauvons la planète » ?",
  "options": [
    {
      "text": "Que Solange a gardé sauvons la planète",
      "correct": false
    },
    {
      "text": "Ne pas nommer le jeudi et le fer",
      "correct": true
    },
    {
      "text": "Que Oscar a refusé le compost",
      "correct": false
    },
    {
      "text": "Que le Bureau n'a pas de jeudi",
      "correct": false
    }
  ],
  "explanation": "sauvons la planète permet de ne pas nommer le jeudi et le fer"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "mesure",
      "right": "geste politique daté, finançable"
    },
    {
      "left": "programme",
      "right": "ensemble de mesures, relisible"
    },
    {
      "left": "financement",
      "right": "qui paie le fer, nommé"
    },
    {
      "left": "compost",
      "right": "geste de cour, trop concret pour l'hymne"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ avant d'accélérer. (voter, subj.)",
  "answer": "vote"
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
    "vote",
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
  "word": "mesure",
  "hint": "geste politique daté, finançable"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il convient que l'on voter trop tard, et Solange Mukamana refuse d'accélérer la pente.",
  "correct_sentence": "Il convient que l'on vote trop tard, et Solange Mukamana refuse d'accélérer la pente.",
  "explanation": "Il convient que + vote."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m6/conference-eau.svg",
      "word": "conference eau"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/urne-vert.svg",
      "word": "urne vert"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/echos-logiques.svg",
      "word": "echos logiques"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/personnage-roman.svg",
      "word": "personnage roman"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « sauvons la planète » et la concession de Solange Mukamana."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le brouillon trop lyrique et le programme retenu distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Trois mesures, pas un hymne',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Proposer des mesures écologiques de cour, datées, finançables. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Trois mesures, pas un hymne », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Trois mesures, pas un hymne
On parle trop vite de un programme trop lyrique de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface le jardin d'Oscar sous un mot trop grand, un programme sans destinataire ni fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Ce que l'on nomme mesure, ici, n'est pas un slogan : geste politique daté, finançable.
Solange : il convient que l'on vote le compost, encore que l'hymne plaise.
Oscar entend son jardin.
Karim chiffre le fer.
Nina dessine la rampe de crue.
Aline rature planète.
Lila lira le programme.
Un chiffre, une trace : Solange a raturé planète ; gardé compost, relais, heures ; daté deux jeudis.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une politique de rive, pas d'un hymne
Joël peut porter.
Oscar Niyitegeka entend, dans « sauvons la planète », ceci qui n'est pas dit : sauvons la planète permet de ne pas nommer le jeudi et le fer
Autrement dit, il convient que l'on vote trois mesures, encore que l'on n'ait pas de planète à mettre dans une motion
La proposition qui reste debout est celle-ci : un programme de cour : trois mesures, deux dates, un financement inventé du Bureau
Marc : des mesures C2 ont un destinataire, ou ne sont qu'un nuage.
Nous clôturons sans fusionner les voix : le brouillon trop lyrique d'un côté, le programme retenu de l'autre, et le point où elles refusent de se ressembler.
Signé : Solange Mukamana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le brouillon trop lyrique et le programme retenu en une seule affiche.",
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
      "text": "Planète raturée, trois gestes, deux jeudis",
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
  "explanation": "Solange a raturé planète ; gardé compost, relais, heures ; daté deux jeudis."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "mesure",
      "right": "geste politique daté, finançable"
    },
    {
      "left": "programme",
      "right": "ensemble de mesures, relisible"
    },
    {
      "left": "financement",
      "right": "qui paie le fer, nommé"
    },
    {
      "left": "compost",
      "right": "geste de cour, trop concret pour l'hymne"
    }
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
  "word": "programme",
  "hint": "ensemble de mesures, relisible"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La mesure de trop vite n'aide personne, et Oscar Niyitegeka reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Oscar Niyitegeka reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m6/urne-vert.svg",
      "word": "urne vert"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/echos-logiques.svg",
      "word": "echos logiques"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/personnage-roman.svg",
      "word": "personnage roman"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/geste-quotidien.svg",
      "word": "geste quotidien"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Trois mesures, pas un hymne » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Mesures pour la rive : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : programme ; mesures politiques de cour ; il convient que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on efface le jardin d'Oscar sous un mot trop grand, un programme sans destinataire ni fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Ce que l'on nomme mesure, ici, n'est pas un slogan : geste politique daté, finançable.
Encore que l'on vote, un programme sans destinataire ni fer n'est pas un détail.
Solange Mukamana concède que un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Autrement dit, il convient que l'on vote trois mesures, encore que l'on n'ait pas de planète à mettre dans une motion
Il ressort qu'un programme de cour : trois mesures, deux dates, un financement inventé du Bureau
Oscar entend son jardin.
Aline rature planète.
La proposition qui reste debout est celle-ci : un programme de cour : trois mesures, deux dates, un financement inventé du Bureau
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le brouillon trop lyrique d'un côté, le programme retenu de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Solange Mukamana concède que un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue."
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
      "text": "un mot large peut rassembler — à condition que l'on date ensuite relais, compost, heures de camion, rampe de crue",
      "correct": true
    },
    {
      "text": "Solange Mukamana abandonne il s'agit d'une politique de rive, pas d'un hymne",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on date ensuite relais, compost, heures de camion, rampe de crue"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "mesure",
      "right": "geste politique daté, finançable"
    },
    {
      "left": "programme",
      "right": "ensemble de mesures, relisible"
    },
    {
      "left": "financement",
      "right": "qui paie le fer, nommé"
    },
    {
      "left": "compost",
      "right": "geste de cour, trop concret pour l'hymne"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous recommandons que la cour ___ un relais. (voter, subj.)",
  "answer": "vote"
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
    "vote",
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
  "word": "financement",
  "hint": "qui paie le fer, nommé"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Solange Mukamana écoute encore, et il fautons voter avant de crier.",
  "correct_sentence": "Solange Mukamana écoute encore, et il faut voter avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m6/echos-logiques.svg",
      "word": "echos logiques"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/personnage-roman.svg",
      "word": "personnage roman"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/geste-quotidien.svg",
      "word": "geste quotidien"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/mode-ethique.svg",
      "word": "mode ethique"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur programme ; mesures politiques de cour ; il convient que, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le brouillon trop lyrique et le programme retenu distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Solange Mukamana',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Proposer des mesures écologiques de cour, datées, finançables. Point : programme ; mesures politiques de cour ; il convient que.

Consigne
Imitez le texte de Solange Mukamana.

Support — Solange Mukamana — Trois mesures, pas un hymne
Solange Mukamana — Trois mesures, pas un hymne
On parle trop vite de un programme trop lyrique de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface le jardin d'Oscar sous un mot trop grand, un programme sans destinataire ni fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Ce que l'on nomme mesure, ici, n'est pas un slogan : geste politique daté, finançable.
Solange : il convient que l'on vote le compost, encore que l'hymne plaise.
Aline rature planète.
Lila lira le programme.
Joël peut porter.
La proposition qui reste debout est celle-ci : un programme de cour : trois mesures, deux dates, un financement inventé du Bureau
Marc : des mesures C2 ont un destinataire, ou ne sont qu'un nuage.
Nous clôturons sans fusionner les voix : le brouillon trop lyrique d'un côté, le programme retenu de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on vote, un programme sans destinataire ni fer n'est pas un détail.
Solange Mukamana concède que un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il convient que l'on vote trois mesures, encore que l'on n'ait pas de planète à mettre dans une motion
Solange Mukamana, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un programme de cour : trois mesures, deux dates, un financement inventé du Bureau",
  "correct": true,
  "explanation": "un programme de cour : trois mesures, deux dates, un financement inventé du Bureau"
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
      "text": "un programme de cour : trois mesures, deux dates, un financement inventé du Bureau",
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
  "explanation": "un programme de cour : trois mesures, deux dates, un financement inventé du Bureau"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "mesure",
      "right": "geste politique daté, finançable"
    },
    {
      "left": "programme",
      "right": "ensemble de mesures, relisible"
    },
    {
      "left": "financement",
      "right": "qui paie le fer, nommé"
    },
    {
      "left": "compost",
      "right": "geste de cour, trop concret pour l'hymne"
    }
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
  "word": "compost",
  "hint": "geste de cour, trop concret pour l'hymne"
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
      "image_path": "/elearning/mfk-c2-m6/personnage-roman.svg",
      "word": "personnage roman"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/geste-quotidien.svg",
      "word": "geste quotidien"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/mode-ethique.svg",
      "word": "mode ethique"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/compte-rendu-climat.svg",
      "word": "compte rendu climat"
    }
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
    'EL — programme ; mesures politiques de cour ; il convient que',
    'EL',
    $c$Objectif
Maîtriser programme ; mesures politiques de cour ; il convient que au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — programme ; mesures politiques de cour ; il convient que
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on vote, un programme sans destinataire ni fer n'est pas un détail.
Solange Mukamana concède que un mot large peut rassembler, pour autant que l'on date ensuite relais, compost, heures de camion, rampe de crue.
Autrement dit, il convient que l'on vote trois mesures, encore que l'on n'ait pas de planète à mettre dans une motion
Il ressort qu'un programme de cour : trois mesures, deux dates, un financement inventé du Bureau
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme mesure, ici, n'est pas un slogan : geste politique daté, finançable.
Oscar entend son jardin.
Aline rature planète.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au financement pour de vrai genre, et Oscar Niyitegeka demande un registre plus net.
Correction : On va au financement vraiment, et Oscar Niyitegeka demande un registre plus net.
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
      "left": "mesure",
      "right": "geste politique daté, finançable"
    },
    {
      "left": "programme",
      "right": "ensemble de mesures, relisible"
    },
    {
      "left": "financement",
      "right": "qui paie le fer, nommé"
    },
    {
      "left": "compost",
      "right": "geste de cour, trop concret pour l'hymne"
    }
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
  "sentence_with_error": "On va au financement pour de vrai genre, et Oscar Niyitegeka demande un registre plus net.",
  "correct_sentence": "On va au financement vraiment, et Oscar Niyitegeka demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m6/geste-quotidien.svg",
      "word": "geste quotidien"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/mode-ethique.svg",
      "word": "mode ethique"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/compte-rendu-climat.svg",
      "word": "compte rendu climat"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/alternative-rurale.svg",
      "word": "alternative rurale"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « programme ; mesures politiques de cour ; il convient que » et deux pièges commentés."
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

  -- ===== Un personnage de rive =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un personnage de rive'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un personnage de rive', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Un personnage de rive',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Encourager des gestes et étudier un personnage de roman qui défend une rive. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Un personnage de rive
Lila Sow : Radio Figuier. On parle trop vite de un personnage trop exemplaire de Mado, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme le geste en consigne de vitrine, un personnage qui n'aurait plus de contradiction n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Aline Uwase : Ce que l'on nomme personnage, ici, n'est pas un slogan : être de roman, avec une fonction.
Patrick Habimana : Mado : on dirait qu'elle douterait encore, et l'on la croirait.
Hawa Diallo : Félicie refuse d'être une sainte.
Joël Mugisha : Aline : la fonction d'un personnage n'est pas l'affiche.
Rose Iradukunda : Oscar veut de la terre sous l'ongle.
Solange Mukamana : Lila n'adoucira pas.
Karim Bamba : Sami aime trop l'exemple ; on le complique.
Félicie Ndayishimiye : Un chiffre, une trace : Mado a laissé le bol trop vite ; gardé le compost ; refusé la sainte.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une fonction dans un roman, pas d'une mascotte
Yvette : Patrick relit la contradiction.
Mado : Félicie Ndayishimiye entend, dans « soyez écolos », ceci qui n'est pas dit : soyez écolos est une affiche, pas une fonction romanesque
Sami : Autrement dit, on dirait qu'elle porterait encore, tout en doutant, et ce doute la rendrait croyable
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un personnage : un geste, une contradiction, une rive, zéro sainteté
Nina Kayitesi : Marc : encourager un geste, au C2, ce n'est pas ordonner une vitrine.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le brouillon trop saint d'un côté, le personnage retenu de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Soyez écolos : impératif d'une vitrine, rarement d'un roman.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un personnage qui n'aurait plus de contradiction est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un personnage qui n'aurait plus de contradiction n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Félicie Ndayishimiye, que reste-t-il implicite dans « soyez écolos » ?",
  "options": [
    {
      "text": "Que Mado a écrit une sainte",
      "correct": false
    },
    {
      "text": "Une affiche, pas une fonction romanesque",
      "correct": true
    },
    {
      "text": "Que Félicie est réduite à une mascotte",
      "correct": false
    },
    {
      "text": "Que le compost a disparu",
      "correct": false
    }
  ],
  "explanation": "soyez écolos est une affiche, pas une fonction romanesque"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "personnage",
      "right": "être de roman, avec une fonction"
    },
    {
      "left": "geste",
      "right": "action quotidienne, distincte d'une affiche"
    },
    {
      "left": "contradiction",
      "right": "doute qui rend croyable"
    },
    {
      "left": "éthique",
      "right": "choix, pas une vitrine de mode"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn dirait que la rivière ___ une voix. (prendre, cond.)",
  "answer": "prendrait"
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
    "dirait",
    "que",
    "la",
    "rivière",
    "prendrait",
    "une",
    "voix",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "personnage",
  "hint": "être de roman, avec une fonction"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On dirait que la rivière prend une voix demain soir, et Mado écrit encore.",
  "correct_sentence": "On dirait que la rivière prendrait une voix demain soir, et Mado écrit encore.",
  "explanation": "Hypotypose : conditionnel prendrait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m6/mode-ethique.svg",
      "word": "mode ethique"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/compte-rendu-climat.svg",
      "word": "compte rendu climat"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/alternative-rurale.svg",
      "word": "alternative rurale"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/micro-rive.svg",
      "word": "micro rive"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « soyez écolos » et la concession de Mado."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le brouillon trop saint et le personnage retenu distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Une contradiction, pas une sainte',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Encourager des gestes et étudier un personnage de roman qui défend une rive. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Une contradiction, pas une sainte », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Une contradiction, pas une sainte
On parle trop vite de un personnage trop exemplaire de Mado, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le geste en consigne de vitrine, un personnage qui n'aurait plus de contradiction n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Ce que l'on nomme personnage, ici, n'est pas un slogan : être de roman, avec une fonction.
Mado : on dirait qu'elle douterait encore, et l'on la croirait.
Félicie refuse d'être une sainte.
Aline : la fonction d'un personnage n'est pas l'affiche.
Oscar veut de la terre sous l'ongle.
Lila n'adoucira pas.
Sami aime trop l'exemple ; on le complique.
Un chiffre, une trace : Mado a laissé le bol trop vite ; gardé le compost ; refusé la sainte.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une fonction dans un roman, pas d'une mascotte
Patrick relit la contradiction.
Félicie Ndayishimiye entend, dans « soyez écolos », ceci qui n'est pas dit : soyez écolos est une affiche, pas une fonction romanesque
Autrement dit, on dirait qu'elle porterait encore, tout en doutant, et ce doute la rendrait croyable
La proposition qui reste debout est celle-ci : un personnage : un geste, une contradiction, une rive, zéro sainteté
Marc : encourager un geste, au C2, ce n'est pas ordonner une vitrine.
Nous clôturons sans fusionner les voix : le brouillon trop saint d'un côté, le personnage retenu de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le brouillon trop saint et le personnage retenu en une seule affiche.",
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
      "text": "Bol trop vite, compost gardé, sainte refusée",
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
  "explanation": "Mado a laissé le bol trop vite ; gardé le compost ; refusé la sainte."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "personnage",
      "right": "être de roman, avec une fonction"
    },
    {
      "left": "geste",
      "right": "action quotidienne, distincte d'une affiche"
    },
    {
      "left": "contradiction",
      "right": "doute qui rend croyable"
    },
    {
      "left": "éthique",
      "right": "choix, pas une vitrine de mode"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi la colline ___ parler, elle parlerait des racines. (pouvoir, imp.)",
  "answer": "pouvait"
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
    "la",
    "colline",
    "pouvait",
    "parler",
    "elle",
    "parlerait",
    "des",
    "racines",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "geste",
  "hint": "action quotidienne, distincte d'une affiche"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La personnage de trop vite n'aide personne, et Félicie Ndayishimiye reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Félicie Ndayishimiye reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m6/compte-rendu-climat.svg",
      "word": "compte rendu climat"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/alternative-rurale.svg",
      "word": "alternative rurale"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/micro-rive.svg",
      "word": "micro rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/cahier-crue.svg",
      "word": "cahier crue"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Une contradiction, pas une sainte » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Un personnage de rive : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : gestes quotidiens ; personnage de roman ; mode et éthique inventées.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme le geste en consigne de vitrine, un personnage qui n'aurait plus de contradiction n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Ce que l'on nomme personnage, ici, n'est pas un slogan : être de roman, avec une fonction.
Encore que l'on laisse, un personnage qui n'aurait plus de contradiction n'est pas un détail.
Mado concède que un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Autrement dit, on dirait qu'elle porterait encore, tout en doutant, et ce doute la rendrait croyable
Il ressort qu'un personnage : un geste, une contradiction, une rive, zéro sainteté
Félicie refuse d'être une sainte.
Lila n'adoucira pas.
La proposition qui reste debout est celle-ci : un personnage : un geste, une contradiction, une rive, zéro sainteté
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le brouillon trop saint d'un côté, le personnage retenu de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Mado transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Mado concède que un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Mado, et à quelle condition ?",
  "options": [
    {
      "text": "Mado n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "un exemple peut entraîner — à condition que l'on laisse au personnage une fatigue, un doute, un bol trop vite",
      "correct": true
    },
    {
      "text": "Mado abandonne il s'agit d'une fonction dans un roman, pas d'une mascotte",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on laisse au personnage une fatigue, un doute, un bol trop vite"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "personnage",
      "right": "être de roman, avec une fonction"
    },
    {
      "left": "geste",
      "right": "action quotidienne, distincte d'une affiche"
    },
    {
      "left": "contradiction",
      "right": "doute qui rend croyable"
    },
    {
      "left": "éthique",
      "right": "choix, pas une vitrine de mode"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne tour ___ l'ombre jusqu'au saule. (avaler, cond.)",
  "answer": "avalerait"
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
    "tour",
    "avalerait",
    "l'ombre",
    "jusqu'au",
    "saule",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "contradiction",
  "hint": "doute qui rend croyable"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Mado écoute encore, et il fautons laisser avant de crier.",
  "correct_sentence": "Mado écoute encore, et il faut laisser avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m6/alternative-rurale.svg",
      "word": "alternative rurale"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/micro-rive.svg",
      "word": "micro rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/cahier-crue.svg",
      "word": "cahier crue"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/saule-racine.svg",
      "word": "saule racine"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur gestes quotidiens ; personnage de roman ; mode et éthique inventées, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le brouillon trop saint et le personnage retenu distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Mado',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Encourager des gestes et étudier un personnage de roman qui défend une rive. Point : gestes quotidiens ; personnage de roman ; mode et éthique inventées.

Consigne
Imitez le texte de Mado.

Support — Mado — Une contradiction, pas une sainte
Mado — Une contradiction, pas une sainte
On parle trop vite de un personnage trop exemplaire de Mado, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le geste en consigne de vitrine, un personnage qui n'aurait plus de contradiction n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Ce que l'on nomme personnage, ici, n'est pas un slogan : être de roman, avec une fonction.
Mado : on dirait qu'elle douterait encore, et l'on la croirait.
Lila n'adoucira pas.
Sami aime trop l'exemple ; on le complique.
Patrick relit la contradiction.
La proposition qui reste debout est celle-ci : un personnage : un geste, une contradiction, une rive, zéro sainteté
Marc : encourager un geste, au C2, ce n'est pas ordonner une vitrine.
Nous clôturons sans fusionner les voix : le brouillon trop saint d'un côté, le personnage retenu de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on laisse, un personnage qui n'aurait plus de contradiction n'est pas un détail.
Mado concède que un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
on dirait qu'elle porterait encore, tout en doutant, et ce doute la rendrait croyable
Mado, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un personnage : un geste, une contradiction, une rive, zéro sainteté",
  "correct": true,
  "explanation": "un personnage : un geste, une contradiction, une rive, zéro sainteté"
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
      "text": "un personnage : un geste, une contradiction, une rive, zéro sainteté",
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
  "explanation": "un personnage : un geste, une contradiction, une rive, zéro sainteté"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "personnage",
      "right": "être de roman, avec une fonction"
    },
    {
      "left": "geste",
      "right": "action quotidienne, distincte d'une affiche"
    },
    {
      "left": "contradiction",
      "right": "doute qui rend croyable"
    },
    {
      "left": "éthique",
      "right": "choix, pas une vitrine de mode"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le récit ___ inventé, il dit une peur vraie. (être, subj.)",
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
    "Le",
    "conditionnel",
    "ici",
    "n'est",
    "pas",
    "un",
    "rêve",
    "creux",
    "c'est",
    "une",
    "hypotypose",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "éthique",
  "hint": "choix, pas une vitrine de mode"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Mado est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Mado sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c2-m6/micro-rive.svg",
      "word": "micro rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/cahier-crue.svg",
      "word": "cahier crue"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/saule-racine.svg",
      "word": "saule racine"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/soleil-secheresse.svg",
      "word": "soleil secheresse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Mado : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — gestes quotidiens ; personnage de roman ; mode et éthique inventées',
    'EL',
    $c$Objectif
Maîtriser gestes quotidiens ; personnage de roman ; mode et éthique inventées au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — gestes quotidiens ; personnage de roman ; mode et éthique inventées
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on laisse, un personnage qui n'aurait plus de contradiction n'est pas un détail.
Mado concède que un exemple peut entraîner, pour autant que l'on laisse au personnage une fatigue, un doute, un bol trop vite.
Autrement dit, on dirait qu'elle porterait encore, tout en doutant, et ce doute la rendrait croyable
Il ressort qu'un personnage : un geste, une contradiction, une rive, zéro sainteté
Piège : indicatif plat là où le conditionnel peint
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme personnage, ici, n'est pas un slogan : être de roman, avec une fonction.
Félicie refuse d'être une sainte.
Lila n'adoucira pas.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au contradiction pour de vrai genre, et Félicie Ndayishimiye demande un registre plus net.
Correction : On va au contradiction vraiment, et Félicie Ndayishimiye demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le conditionnel peut peindre un comme si, pas seulement une politesse.",
  "correct": true,
  "explanation": "Hypotypose."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Dans une description fantastique, le conditionnel sert surtout à…",
  "options": [
    {
      "text": "donner un ordre",
      "correct": false
    },
    {
      "text": "peindre une hypotypose, un comme si",
      "correct": true
    },
    {
      "text": "marquer un passé antérieur",
      "correct": false
    },
    {
      "text": "interdire la métaphore",
      "correct": false
    }
  ],
  "explanation": "Conditionnel d'imagination / hypotypose."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "personnage",
      "right": "être de roman, avec une fonction"
    },
    {
      "left": "geste",
      "right": "action quotidienne, distincte d'une affiche"
    },
    {
      "left": "contradiction",
      "right": "doute qui rend croyable"
    },
    {
      "left": "éthique",
      "right": "choix, pas une vitrine de mode"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'___ du plan n'empêche pas d'écrire le cauchemar. (urbanisme déjà donné)",
  "answer": "personnage"
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
    "récit",
    "soit",
    "inventé",
    "il",
    "dit",
    "une",
    "peur",
    "vraie",
    "."
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
  "sentence_with_error": "On va au contradiction pour de vrai genre, et Félicie Ndayishimiye demande un registre plus net.",
  "correct_sentence": "On va au contradiction vraiment, et Félicie Ndayishimiye demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m6/cahier-crue.svg",
      "word": "cahier crue"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/saule-racine.svg",
      "word": "saule racine"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/soleil-secheresse.svg",
      "word": "soleil secheresse"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/nuage-crue.svg",
      "word": "nuage crue"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « gestes quotidiens ; personnage de roman ; mode et éthique inventées » et deux pièges commentés."
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

  -- ===== Compte-rendu climat =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Compte-rendu climat'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Compte-rendu climat', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Compte-rendu climat',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Faire le compte-rendu oral des conséquences, à partir des séquences précédentes. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Compte-rendu climat
Lila Sow : Radio Figuier. On parle trop vite de ce que la cour peut déjà dire de la rive, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on noye l'oreille sous trop de fin du monde, un oral trop vaste pour une cour n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Aline Uwase : Ce que l'on nomme ampleur, ici, n'est pas un slogan : échelle, à borner pour l'oreille.
Patrick Habimana : Nina : selon Oscar, la crue trop tôt ; d'après Solange, trois mesures.
Hawa Diallo : Il ressort un jardin, pas un spectacle.
Joël Mugisha : Aline chronomètre.
Rose Iradukunda : Lila n'ajoute pas de musique.
Solange Mukamana : Karim veut un chiffre, le reçoit.
Karim Bamba : Félicie écoute.
Félicie Ndayishimiye : Un chiffre, une trace : Nina a parlé 3 min 50 ; cité Oscar et Solange ; zéro fin du monde.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'informer une cour, pas de la sidérer
Yvette : Joël entend le relais.
Mado : Oscar Niyitegeka entend, dans « il faut tout dire », ceci qui n'est pas dit : tout dire est souvent le contraire d'un compte-rendu
Sami : Autrement dit, selon Oscar la crue ; d'après Nina le déni ; il ressort trois mesures et un jardin
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un oral : quatre minutes, deux sources, une conséquence, un geste
Nina Kayitesi : Marc : un compte-rendu C2 se juge à ce qu'il a su borner.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les rapports de la rive d'un côté, l'oral de Nina de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Il faut tout dire : programme d'une honnêteté qui n'a pas d'oreille en face.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un oral trop vaste pour une cour est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un oral trop vaste pour une cour n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Oscar Niyitegeka, que reste-t-il implicite dans « il faut tout dire » ?",
  "options": [
    {
      "text": "Que Nina a parlé d'une fin du monde",
      "correct": false
    },
    {
      "text": "Le contraire d'un compte-rendu",
      "correct": true
    },
    {
      "text": "Que Oscar n'a pas été cité",
      "correct": false
    },
    {
      "text": "Que l'oral a duré une heure",
      "correct": false
    }
  ],
  "explanation": "tout dire est souvent le contraire d'un compte-rendu"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ampleur",
      "right": "échelle, à borner pour l'oreille"
    },
    {
      "left": "sidération",
      "right": "effet à refuser dans l'oral"
    },
    {
      "left": "source",
      "right": "Oscar, Solange, nommés"
    },
    {
      "left": "geste",
      "right": "suite concrète du compte-rendu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSelon Nina, il ___ que deux documents s'opposent. (ressortir)",
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
    "Nina",
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
  "word": "ampleur",
  "hint": "échelle, à borner pour l'oreille"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Selon Nina Kayitesi, il ressort que les deux textes est d'accord, et Lila coupe le micro.",
  "correct_sentence": "Selon Nina Kayitesi, il ressort que les deux textes sont d'accord, et Lila coupe le micro.",
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
      "image_path": "/elearning/mfk-c2-m6/saule-racine.svg",
      "word": "saule racine"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/soleil-secheresse.svg",
      "word": "soleil secheresse"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/nuage-crue.svg",
      "word": "nuage crue"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/feuille-programme.svg",
      "word": "feuille programme"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « il faut tout dire » et la concession de Nina Kayitesi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les rapports de la rive et l'oral de Nina distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Quatre minutes, pas le monde entier',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Faire le compte-rendu oral des conséquences, à partir des séquences précédentes. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Quatre minutes, pas le monde entier », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Quatre minutes, pas le monde entier
On parle trop vite de ce que la cour peut déjà dire de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on noye l'oreille sous trop de fin du monde, un oral trop vaste pour une cour n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Ce que l'on nomme ampleur, ici, n'est pas un slogan : échelle, à borner pour l'oreille.
Nina : selon Oscar, la crue trop tôt ; d'après Solange, trois mesures.
Il ressort un jardin, pas un spectacle.
Aline chronomètre.
Lila n'ajoute pas de musique.
Karim veut un chiffre, le reçoit.
Félicie écoute.
Un chiffre, une trace : Nina a parlé 3 min 50 ; cité Oscar et Solange ; zéro fin du monde.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'informer une cour, pas de la sidérer
Joël entend le relais.
Oscar Niyitegeka entend, dans « il faut tout dire », ceci qui n'est pas dit : tout dire est souvent le contraire d'un compte-rendu
Autrement dit, selon Oscar la crue ; d'après Nina le déni ; il ressort trois mesures et un jardin
La proposition qui reste debout est celle-ci : un oral : quatre minutes, deux sources, une conséquence, un geste
Marc : un compte-rendu C2 se juge à ce qu'il a su borner.
Nous clôturons sans fusionner les voix : les rapports de la rive d'un côté, l'oral de Nina de l'autre, et le point où elles refusent de se ressembler.
Signé : Nina Kayitesi, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les rapports de la rive et l'oral de Nina en une seule affiche.",
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
      "text": "Presque quatre minutes, deux sources, zéro fin du monde",
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
  "explanation": "Nina a parlé 3 min 50 ; cité Oscar et Solange ; zéro fin du monde."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ampleur",
      "right": "échelle, à borner pour l'oreille"
    },
    {
      "left": "sidération",
      "right": "effet à refuser dans l'oral"
    },
    {
      "left": "source",
      "right": "Oscar, Solange, nommés"
    },
    {
      "left": "geste",
      "right": "suite concrète du compte-rendu"
    }
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
  "word": "sidération",
  "hint": "effet à refuser dans l'oral"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La ampleur de trop vite n'aide personne, et Oscar Niyitegeka reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Oscar Niyitegeka reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m6/soleil-secheresse.svg",
      "word": "soleil secheresse"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/nuage-crue.svg",
      "word": "nuage crue"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/feuille-programme.svg",
      "word": "feuille programme"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/radio-climat.svg",
      "word": "radio climat"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Quatre minutes, pas le monde entier » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Compte-rendu climat : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : oral de synthèse ; conséquences ; sans spectacle.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on noye l'oreille sous trop de fin du monde, un oral trop vaste pour une cour n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Ce que l'on nomme ampleur, ici, n'est pas un slogan : échelle, à borner pour l'oreille.
Encore que l'on borne, un oral trop vaste pour une cour n'est pas un détail.
Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Autrement dit, selon Oscar la crue ; d'après Nina le déni ; il ressort trois mesures et un jardin
Il ressort qu'un oral : quatre minutes, deux sources, une conséquence, un geste
Il ressort un jardin, pas un spectacle.
Karim veut un chiffre, le reçoit.
La proposition qui reste debout est celle-ci : un oral : quatre minutes, deux sources, une conséquence, un geste
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les rapports de la rive d'un côté, l'oral de Nina de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Nina Kayitesi transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Nina Kayitesi, et à quelle condition ?",
  "options": [
    {
      "text": "Nina Kayitesi n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "l'ampleur existe — à condition que l'on tienne quatre minutes : crue, déni, mesures, geste",
      "correct": true
    },
    {
      "text": "Nina Kayitesi abandonne il s'agit d'informer une cour, pas de la sidérer",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on tienne quatre minutes : crue, déni, mesures, geste"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ampleur",
      "right": "échelle, à borner pour l'oreille"
    },
    {
      "left": "sidération",
      "right": "effet à refuser dans l'oral"
    },
    {
      "left": "source",
      "right": "Oscar, Solange, nommés"
    },
    {
      "left": "geste",
      "right": "suite concrète du compte-rendu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl appert que ampleur n'est pas un slogan.",
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
  "word": "source",
  "hint": "Oscar, Solange, nommés"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nina Kayitesi écoute encore, et il fautons borner avant de crier.",
  "correct_sentence": "Nina Kayitesi écoute encore, et il faut borner avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m6/nuage-crue.svg",
      "word": "nuage crue"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/feuille-programme.svg",
      "word": "feuille programme"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/radio-climat.svg",
      "word": "radio climat"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/groupe-rive.svg",
      "word": "groupe rive"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur oral de synthèse ; conséquences ; sans spectacle, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les rapports de la rive et l'oral de Nina distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Nina Kayitesi',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Faire le compte-rendu oral des conséquences, à partir des séquences précédentes. Point : oral de synthèse ; conséquences ; sans spectacle.

Consigne
Imitez le texte de Nina Kayitesi.

Support — Nina Kayitesi — Quatre minutes, pas le monde entier
Nina Kayitesi — Quatre minutes, pas le monde entier
On parle trop vite de ce que la cour peut déjà dire de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on noye l'oreille sous trop de fin du monde, un oral trop vaste pour une cour n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Ce que l'on nomme ampleur, ici, n'est pas un slogan : échelle, à borner pour l'oreille.
Nina : selon Oscar, la crue trop tôt ; d'après Solange, trois mesures.
Karim veut un chiffre, le reçoit.
Félicie écoute.
Joël entend le relais.
La proposition qui reste debout est celle-ci : un oral : quatre minutes, deux sources, une conséquence, un geste
Marc : un compte-rendu C2 se juge à ce qu'il a su borner.
Nous clôturons sans fusionner les voix : les rapports de la rive d'un côté, l'oral de Nina de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on borne, un oral trop vaste pour une cour n'est pas un détail.
Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
selon Oscar la crue ; d'après Nina le déni ; il ressort trois mesures et un jardin
Nina Kayitesi, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un oral : quatre minutes, deux sources, une conséquence, un geste",
  "correct": true,
  "explanation": "un oral : quatre minutes, deux sources, une conséquence, un geste"
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
      "text": "un oral : quatre minutes, deux sources, une conséquence, un geste",
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
  "explanation": "un oral : quatre minutes, deux sources, une conséquence, un geste"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ampleur",
      "right": "échelle, à borner pour l'oreille"
    },
    {
      "left": "sidération",
      "right": "effet à refuser dans l'oral"
    },
    {
      "left": "source",
      "right": "Oscar, Solange, nommés"
    },
    {
      "left": "geste",
      "right": "suite concrète du compte-rendu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ les deux sources, on ne les fusionne pas. (borner, subj.)",
  "answer": "borne"
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
    "borne",
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
  "word": "geste",
  "hint": "suite concrète du compte-rendu"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Nina Kayitesi est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Nina Kayitesi sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c2-m6/feuille-programme.svg",
      "word": "feuille programme"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/radio-climat.svg",
      "word": "radio climat"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/groupe-rive.svg",
      "word": "groupe rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/main-terre-humide.svg",
      "word": "main terre humide"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Nina Kayitesi : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — oral de synthèse ; conséquences ; sans spectacle',
    'EL',
    $c$Objectif
Maîtriser oral de synthèse ; conséquences ; sans spectacle au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — oral de synthèse ; conséquences ; sans spectacle
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on borne, un oral trop vaste pour une cour n'est pas un détail.
Nina Kayitesi concède que l'ampleur existe, pour autant que l'on tienne quatre minutes : crue, déni, mesures, geste.
Autrement dit, selon Oscar la crue ; d'après Nina le déni ; il ressort trois mesures et un jardin
Il ressort qu'un oral : quatre minutes, deux sources, une conséquence, un geste
Piège : fusionner les sources au lieu de les attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme ampleur, ici, n'est pas un slogan : échelle, à borner pour l'oreille.
Il ressort un jardin, pas un spectacle.
Karim veut un chiffre, le reçoit.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au source pour de vrai genre, et Oscar Niyitegeka demande un registre plus net.
Correction : On va au source vraiment, et Oscar Niyitegeka demande un registre plus net.
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
      "left": "ampleur",
      "right": "échelle, à borner pour l'oreille"
    },
    {
      "left": "sidération",
      "right": "effet à refuser dans l'oral"
    },
    {
      "left": "source",
      "right": "Oscar, Solange, nommés"
    },
    {
      "left": "geste",
      "right": "suite concrète du compte-rendu"
    }
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
  "sentence_with_error": "On va au source pour de vrai genre, et Oscar Niyitegeka demande un registre plus net.",
  "correct_sentence": "On va au source vraiment, et Oscar Niyitegeka demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m6/radio-climat.svg",
      "word": "radio climat"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/groupe-rive.svg",
      "word": "groupe rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/main-terre-humide.svg",
      "word": "main terre humide"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/porte-jardin.svg",
      "word": "porte jardin"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « oral de synthèse ; conséquences ; sans spectacle » et deux pièges commentés."
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

  -- ===== Programme et personnage =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Programme et personnage'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Programme et personnage', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Programme et personnage',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Tenir ensemble un programme de rive et un personnage de roman, tâche finale C2-6. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Programme et personnage
Lila Sow : Radio Figuier. On parle trop vite de ce que le module laisse à la cour, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on clôt trop tôt ce qui n'a pas encore de jeudi, une fierté d'avoir parlé, sans fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte.
Aline Uwase : Ce que l'on nomme clôture, ici, n'est pas un slogan : fin de module, pas un job trop vite dit.
Patrick Habimana : Aline : il convient que l'on laisse une date, encore que l'on ait parlé longtemps.
Hawa Diallo : Mado refuse la sainte.
Joël Mugisha : Oscar tient le compost.
Rose Iradukunda : Nina tient la rampe de crue.
Solange Mukamana : Solange tient les jeudis.
Karim Bamba : Lila ouvrira la revue.
Félicie Ndayishimiye : Un chiffre, une trace : Aline a daté la revue ; Mado a gardé le doute du personnage ; Oscar a le compost.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que C2-6 n'ait pas été seulement un exercice de style
Yvette : Félicie pose le bol.
Mado : Mado entend, dans « on a fait le job », ceci qui n'est pas dit : on a fait le job est la phrase de ceux qui n'auront pas à essuyer la prochaine crue
Sami : Autrement dit, il s'agit de laisser un programme et un personnage, relisibles, imparfaits, datés
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un texte final : quatre mesures, un personnage contradictoire, une revue sous le figuier
Nina Kayitesi : Marc : une tâche finale C2 se juge au fer qu'elle n'a pas oublié.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le programme et le roman d'un côté, la clôture d'Aline de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : On a fait le job : on aimerait savoir qui, au juste, essuiera encore.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une fierté d'avoir parlé, sans fer est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une fierté d'avoir parlé, sans fer n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Mado, que reste-t-il implicite dans « on a fait le job » ?",
  "options": [
    {
      "text": "Que Aline a dit on a fait le job",
      "correct": false
    },
    {
      "text": "Pas à essuyer la prochaine crue",
      "correct": true
    },
    {
      "text": "Que Mado a écrit une sainte à la fin",
      "correct": false
    },
    {
      "text": "Que Oscar n'a plus de compost",
      "correct": false
    }
  ],
  "explanation": "on a fait le job est la phrase de ceux qui n'auront pas à essuyer la prochaine crue"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "clôture",
      "right": "fin de module, pas un job trop vite dit"
    },
    {
      "left": "revue",
      "right": "rendez-vous daté sous le figuier"
    },
    {
      "left": "imparfait",
      "right": "qualité d'un programme réel"
    },
    {
      "left": "style",
      "right": "exercice, insuffisant sans fer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ avant d'accélérer. (laisser, subj.)",
  "answer": "laisse"
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
    "laisse",
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
  "word": "clôture",
  "hint": "fin de module, pas un job trop vite dit"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il convient que l'on laisser trop tard, et Aline Uwase refuse d'accélérer la pente.",
  "correct_sentence": "Il convient que l'on laisse trop tard, et Aline Uwase refuse d'accélérer la pente.",
  "explanation": "Il convient que + laisse."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m6/groupe-rive.svg",
      "word": "groupe rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/main-terre-humide.svg",
      "word": "main terre humide"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/porte-jardin.svg",
      "word": "porte jardin"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/lampe-veille-eau.svg",
      "word": "lampe veille eau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « on a fait le job » et la concession de Aline Uwase."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le programme et le roman et la clôture d'Aline distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Daté, imparfait, relisible',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Tenir ensemble un programme de rive et un personnage de roman, tâche finale C2-6. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Daté, imparfait, relisible », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Daté, imparfait, relisible
On parle trop vite de ce que le module laisse à la cour, comme si le mot dispensait d'en examiner le prix.
Encore que l'on clôt trop tôt ce qui n'a pas encore de jeudi, une fierté d'avoir parlé, sans fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte.
Ce que l'on nomme clôture, ici, n'est pas un slogan : fin de module, pas un job trop vite dit.
Aline : il convient que l'on laisse une date, encore que l'on ait parlé longtemps.
Mado refuse la sainte.
Oscar tient le compost.
Nina tient la rampe de crue.
Solange tient les jeudis.
Lila ouvrira la revue.
Un chiffre, une trace : Aline a daté la revue ; Mado a gardé le doute du personnage ; Oscar a le compost.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que C2-6 n'ait pas été seulement un exercice de style
Félicie pose le bol.
Mado entend, dans « on a fait le job », ceci qui n'est pas dit : on a fait le job est la phrase de ceux qui n'auront pas à essuyer la prochaine crue
Autrement dit, il s'agit de laisser un programme et un personnage, relisibles, imparfaits, datés
La proposition qui reste debout est celle-ci : un texte final : quatre mesures, un personnage contradictoire, une revue sous le figuier
Marc : une tâche finale C2 se juge au fer qu'elle n'a pas oublié.
Nous clôturons sans fusionner les voix : le programme et le roman d'un côté, la clôture d'Aline de l'autre, et le point où elles refusent de se ressembler.
Signé : Aline Uwase, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le programme et le roman et la clôture d'Aline en une seule affiche.",
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
      "text": "Revue datée, doute gardé, compost nommé",
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
  "explanation": "Aline a daté la revue ; Mado a gardé le doute du personnage ; Oscar a le compost."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "clôture",
      "right": "fin de module, pas un job trop vite dit"
    },
    {
      "left": "revue",
      "right": "rendez-vous daté sous le figuier"
    },
    {
      "left": "imparfait",
      "right": "qualité d'un programme réel"
    },
    {
      "left": "style",
      "right": "exercice, insuffisant sans fer"
    }
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
  "word": "revue",
  "hint": "rendez-vous daté sous le figuier"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La clôture de trop vite n'aide personne, et Mado reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Mado reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m6/main-terre-humide.svg",
      "word": "main terre humide"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/porte-jardin.svg",
      "word": "porte jardin"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/lampe-veille-eau.svg",
      "word": "lampe veille eau"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/coeur-rive.svg",
      "word": "coeur rive"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Daté, imparfait, relisible » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Programme et personnage : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : synthèse finale ; programme ; roman.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on clôt trop tôt ce qui n'a pas encore de jeudi, une fierté d'avoir parlé, sans fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte.
Ce que l'on nomme clôture, ici, n'est pas un slogan : fin de module, pas un job trop vite dit.
Encore que l'on laisse, une fierté d'avoir parlé, sans fer n'est pas un détail.
Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte.
Autrement dit, il s'agit de laisser un programme et un personnage, relisibles, imparfaits, datés
Il ressort qu'un texte final : quatre mesures, un personnage contradictoire, une revue sous le figuier
Mado refuse la sainte.
Solange tient les jeudis.
La proposition qui reste debout est celle-ci : un texte final : quatre mesures, un personnage contradictoire, une revue sous le figuier
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le programme et le roman d'un côté, la clôture d'Aline de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte."
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
      "text": "parler était nécessaire — à condition que l'on date encore compost, relais, visite des sceptiques, rature de la sainte",
      "correct": true
    },
    {
      "text": "Aline Uwase abandonne il s'agit que C2-6 n'ait pas été seulement un exercice de style",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on date encore compost, relais, visite des sceptiques, rature de la sainte"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "clôture",
      "right": "fin de module, pas un job trop vite dit"
    },
    {
      "left": "revue",
      "right": "rendez-vous daté sous le figuier"
    },
    {
      "left": "imparfait",
      "right": "qualité d'un programme réel"
    },
    {
      "left": "style",
      "right": "exercice, insuffisant sans fer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous recommandons que la cour ___ un relais. (laisser, subj.)",
  "answer": "laisse"
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
    "laisse",
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
  "word": "imparfait",
  "hint": "qualité d'un programme réel"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aline Uwase écoute encore, et il fautons laisser avant de crier.",
  "correct_sentence": "Aline Uwase écoute encore, et il faut laisser avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m6/porte-jardin.svg",
      "word": "porte jardin"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/lampe-veille-eau.svg",
      "word": "lampe veille eau"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/coeur-rive.svg",
      "word": "coeur rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/rapport-alarmant.svg",
      "word": "rapport alarmant"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur synthèse finale ; programme ; roman, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le programme et le roman et la clôture d'Aline distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Aline Uwase',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Tenir ensemble un programme de rive et un personnage de roman, tâche finale C2-6. Point : synthèse finale ; programme ; roman.

Consigne
Imitez le texte de Aline Uwase.

Support — Aline Uwase — Daté, imparfait, relisible
Aline Uwase — Daté, imparfait, relisible
On parle trop vite de ce que le module laisse à la cour, comme si le mot dispensait d'en examiner le prix.
Encore que l'on clôt trop tôt ce qui n'a pas encore de jeudi, une fierté d'avoir parlé, sans fer n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte.
Ce que l'on nomme clôture, ici, n'est pas un slogan : fin de module, pas un job trop vite dit.
Aline : il convient que l'on laisse une date, encore que l'on ait parlé longtemps.
Solange tient les jeudis.
Lila ouvrira la revue.
Félicie pose le bol.
La proposition qui reste debout est celle-ci : un texte final : quatre mesures, un personnage contradictoire, une revue sous le figuier
Marc : une tâche finale C2 se juge au fer qu'elle n'a pas oublié.
Nous clôturons sans fusionner les voix : le programme et le roman d'un côté, la clôture d'Aline de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on laisse, une fierté d'avoir parlé, sans fer n'est pas un détail.
Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il s'agit de laisser un programme et un personnage, relisibles, imparfaits, datés
Aline Uwase, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un texte final : quatre mesures, un personnage contradictoire, une revue sous le figuier",
  "correct": true,
  "explanation": "un texte final : quatre mesures, un personnage contradictoire, une revue sous le figuier"
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
      "text": "un texte final : quatre mesures, un personnage contradictoire, une revue sous le figuier",
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
  "explanation": "un texte final : quatre mesures, un personnage contradictoire, une revue sous le figuier"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "clôture",
      "right": "fin de module, pas un job trop vite dit"
    },
    {
      "left": "revue",
      "right": "rendez-vous daté sous le figuier"
    },
    {
      "left": "imparfait",
      "right": "qualité d'un programme réel"
    },
    {
      "left": "style",
      "right": "exercice, insuffisant sans fer"
    }
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
  "word": "style",
  "hint": "exercice, insuffisant sans fer"
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
      "image_path": "/elearning/mfk-c2-m6/lampe-veille-eau.svg",
      "word": "lampe veille eau"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/coeur-rive.svg",
      "word": "coeur rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/rapport-alarmant.svg",
      "word": "rapport alarmant"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/biodiversite-rive.svg",
      "word": "biodiversite rive"
    }
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
    'EL — synthèse finale ; programme ; roman',
    'EL',
    $c$Objectif
Maîtriser synthèse finale ; programme ; roman au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — synthèse finale ; programme ; roman
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on laisse, une fierté d'avoir parlé, sans fer n'est pas un détail.
Aline Uwase concède que parler était nécessaire, pour autant que l'on date encore compost, relais, visite des sceptiques, rature de la sainte.
Autrement dit, il s'agit de laisser un programme et un personnage, relisibles, imparfaits, datés
Il ressort qu'un texte final : quatre mesures, un personnage contradictoire, une revue sous le figuier
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme clôture, ici, n'est pas un slogan : fin de module, pas un job trop vite dit.
Mado refuse la sainte.
Solange tient les jeudis.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au imparfait pour de vrai genre, et Mado demande un registre plus net.
Correction : On va au imparfait vraiment, et Mado demande un registre plus net.
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
      "left": "clôture",
      "right": "fin de module, pas un job trop vite dit"
    },
    {
      "left": "revue",
      "right": "rendez-vous daté sous le figuier"
    },
    {
      "left": "imparfait",
      "right": "qualité d'un programme réel"
    },
    {
      "left": "style",
      "right": "exercice, insuffisant sans fer"
    }
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
  "sentence_with_error": "On va au imparfait pour de vrai genre, et Mado demande un registre plus net.",
  "correct_sentence": "On va au imparfait vraiment, et Mado demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m6/coeur-rive.svg",
      "word": "coeur rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/rapport-alarmant.svg",
      "word": "rapport alarmant"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/biodiversite-rive.svg",
      "word": "biodiversite rive"
    },
    {
      "image_path": "/elearning/mfk-c2-m6/hypothese-climat.svg",
      "word": "hypothese climat"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « synthèse finale ; programme ; roman » et deux pièges commentés."
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
