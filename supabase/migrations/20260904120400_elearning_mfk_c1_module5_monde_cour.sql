/*
  Seed eLearning MFK — C1 — Le monde de la cour

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-c1-m5/
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
  v_module_title text := 'C1 — Le monde de la cour';
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
      'Seed C1 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed C1 : enseignant % (%) — %', v_teacher_email, v_teacher_id, v_module_title;

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
      'Grande étape C1-5 : expliquer le message d''un chant de cour inventé, écrire la biographie d''une voix engagée, accueillir sans slogan, comparer deux âges et deux registres, puis croiser poème et chronique — Solange Mukamana a parlé trop tôt pour trop de portes, Mado écrit sans crier, Sami glisse un humour qui n''écrase personne, Aline Uwase distingue les registres.',
      'C1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape C1-5 : expliquer le message d''un chant de cour inventé, écrire la biographie d''une voix engagée, accueillir sans slogan, comparer deux âges et deux registres, puis croiser poème et chronique — Solange Mukamana a parlé trop tôt pour trop de portes, Mado écrit sans crier, Sami glisse un humour qui n''écrase personne, Aline Uwase distingue les registres.',
      cefr_level = 'C1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Chant de la cour =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Chant de la cour'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Chant de la cour', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Chant de la cour',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Expliquer le message d'un chant de cour inventé, y compris ce qu'il ne dit pas. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Chant de la cour
Lila Sow : Radio Figuier. On parle trop vite de le chant inventé de la cour, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on réduise le chant à un air, un refrain trop clair pour n'être pas une porte fermée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer.
Aline Uwase : Ce que l'on nomme refrain, ici, n'est pas un slogan : retour d'un chant, parfois une porte.
Patrick Habimana : Sami : le refrain dit colline, et l'on entend trop vite panorama.
Hawa Diallo : Solange entend une porte.
Joël Mugisha : Mado écrit que la métaphore n'est pas un ornement.
Rose Iradukunda : Aline : expliquer un chant, c'est risquer d'être trop clair, et il le faut parfois.
Solange Mukamana : Léa refuse le mot verlan collé pour faire vrai.
Karim Bamba : Lila jouera l'air, puis le silence.
Félicie Ndayishimiye : Un chiffre, une trace : Sami a changé un mot ; Lila a reçu trois lectures opposées ; zéro clip trop lisse retenu.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'entendre le chant comme une parole de cour, pas comme un décor
Yvette : Yvette : c'est juste une chanson est déjà une politique.
Mado : Solange Mukamana entend, dans « c'est juste une chanson », ceci qui n'est pas dit : c'est juste une chanson permet de ne pas entendre qui reste derrière la colline
Sami : Autrement dit, un chant engagé n'a pas besoin de slogan : l'implicite fait le travail, encore faut-il le lire
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : expliquer le message : qui parle, qui n'est pas nommé, quel geste le refrain demande
Nina Kayitesi : Marc : le message, c'est aussi qui n'a pas le micro.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les paroles inventées de Sami d'un côté, l'article de Mado sur le refrain de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un refrain trop clair pour n'être pas une porte fermée est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un refrain trop clair pour n'être pas une porte fermée n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Solange Mukamana, que reste-t-il implicite dans « c'est juste une chanson » ?",
  "options": [
    {
      "text": "Que Sami a copié une affiche",
      "correct": false
    },
    {
      "text": "Ne pas entendre qui reste derrière la colline",
      "correct": true
    },
    {
      "text": "Que Solange interdit le chant",
      "correct": false
    },
    {
      "text": "Que le refrain nomme tous les noms",
      "correct": false
    }
  ],
  "explanation": "c'est juste une chanson permet de ne pas entendre qui reste derrière la colline"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "refrain",
      "right": "retour d'un chant, parfois une porte"
    },
    {
      "left": "implicite",
      "right": "non-dit qui travaille le message"
    },
    {
      "left": "métaphore",
      "right": "image qui dit autrement"
    },
    {
      "left": "message",
      "right": "ce que le chant fait, au-delà de l'air"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAu registre soutenu, on dira ___ et non « c'est pas ouf ». (cela)",
  "answer": "cela"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Au",
    "registre",
    "soutenu",
    "on",
    "dira",
    "cela",
    "et",
    "non",
    "un",
    "mot",
    "trop",
    "large",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "refrain",
  "hint": "retour d'un chant, parfois une porte"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Au registre soutenu, on dira ça ouais, et Sami lit encore la motion.",
  "correct_sentence": "Au registre soutenu, on dira cela, et Sami lit encore la motion.",
  "explanation": "Soutenu : cela, pas ça ouais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m5/chant-cour.svg",
      "word": "chant cour"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/verlan-doux.svg",
      "word": "verlan doux"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/clip-invente.svg",
      "word": "clip invente"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/message-chanson.svg",
      "word": "message chanson"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « c'est juste une chanson » et la concession de Sami."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les paroles inventées de Sami et l'article de Mado sur le refrain distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le refrain n''est pas un décor',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Expliquer le message d'un chant de cour inventé, y compris ce qu'il ne dit pas. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le refrain n'est pas un décor », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le refrain n'est pas un décor
On parle trop vite de le chant inventé de la cour, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise le chant à un air, un refrain trop clair pour n'être pas une porte fermée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer.
Ce que l'on nomme refrain, ici, n'est pas un slogan : retour d'un chant, parfois une porte.
Sami : le refrain dit colline, et l'on entend trop vite panorama.
Solange entend une porte.
Mado écrit que la métaphore n'est pas un ornement.
Aline : expliquer un chant, c'est risquer d'être trop clair, et il le faut parfois.
Léa refuse le mot verlan collé pour faire vrai.
Lila jouera l'air, puis le silence.
Un chiffre, une trace : Sami a changé un mot ; Lila a reçu trois lectures opposées ; zéro clip trop lisse retenu.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'entendre le chant comme une parole de cour, pas comme un décor
Yvette : c'est juste une chanson est déjà une politique.
Solange Mukamana entend, dans « c'est juste une chanson », ceci qui n'est pas dit : c'est juste une chanson permet de ne pas entendre qui reste derrière la colline
Autrement dit, un chant engagé n'a pas besoin de slogan : l'implicite fait le travail, encore faut-il le lire
La proposition qui reste debout est celle-ci : expliquer le message : qui parle, qui n'est pas nommé, quel geste le refrain demande
Marc : le message, c'est aussi qui n'a pas le micro.
Nous clôturons sans fusionner les voix : les paroles inventées de Sami d'un côté, l'article de Mado sur le refrain de l'autre, et le point où elles refusent de se ressembler.
Signé : Sami, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les paroles inventées de Sami et l'article de Mado sur le refrain en une seule affiche.",
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
      "text": "Un mot changé, trois lectures, zéro clip trop lisse",
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
  "explanation": "Sami a changé un mot ; Lila a reçu trois lectures opposées ; zéro clip trop lisse retenu."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "refrain",
      "right": "retour d'un chant, parfois une porte"
    },
    {
      "left": "implicite",
      "right": "non-dit qui travaille le message"
    },
    {
      "left": "métaphore",
      "right": "image qui dit autrement"
    },
    {
      "left": "message",
      "right": "ce que le chant fait, au-delà de l'air"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le tutoiement ___ possible sous le figuier, le micro de Lila vouvoie l'assemblée. (être, subj.)",
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
    "tutoiement",
    "soit",
    "possible",
    "le",
    "micro",
    "vouvoie",
    "l'assemblée",
    "."
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
  "hint": "non-dit qui travaille le message"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La refrain de trop vite n'aide personne, et Solange Mukamana reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m5/verlan-doux.svg",
      "word": "verlan doux"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/clip-invente.svg",
      "word": "clip invente"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/message-chanson.svg",
      "word": "message chanson"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/biographie-engagee.svg",
      "word": "biographie engagee"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le refrain n'est pas un décor » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Chant de la cour : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : expliquer un implicite ; métaphore ; message d'un chant inventé.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on réduise le chant à un air, un refrain trop clair pour n'être pas une porte fermée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer.
Ce que l'on nomme refrain, ici, n'est pas un slogan : retour d'un chant, parfois une porte.
Encore que l'on explique, un refrain trop clair pour n'être pas une porte fermée n'est pas un détail.
Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer.
Autrement dit, un chant engagé n'a pas besoin de slogan : l'implicite fait le travail, encore faut-il le lire
Il ressort qu'expliquer le message : qui parle, qui n'est pas nommé, quel geste le refrain demande
Solange entend une porte.
Léa refuse le mot verlan collé pour faire vrai.
La proposition qui reste debout est celle-ci : expliquer le message : qui parle, qui n'est pas nommé, quel geste le refrain demande
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les paroles inventées de Sami d'un côté, l'article de Mado sur le refrain de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer."
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
      "text": "on peut aimer l'air sans tout décoder — à condition que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer",
      "correct": true
    },
    {
      "text": "Sami abandonne il s'agit d'entendre le chant comme une parole de cour, pas comme un décor",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "refrain",
      "right": "retour d'un chant, parfois une porte"
    },
    {
      "left": "implicite",
      "right": "non-dit qui travaille le message"
    },
    {
      "left": "métaphore",
      "right": "image qui dit autrement"
    },
    {
      "left": "message",
      "right": "ce que le chant fait, au-delà de l'air"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ le niveau, non la personne. (expliquer, subj.)",
  "answer": "explique"
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
    "explique",
    "le",
    "niveau",
    "non",
    "la",
    "personne",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "métaphore",
  "hint": "image qui dit autrement"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Sami écoute encore, et il fautons expliquer avant de crier.",
  "correct_sentence": "Sami écoute encore, et il faut expliquer avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m5/clip-invente.svg",
      "word": "clip invente"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/message-chanson.svg",
      "word": "message chanson"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/biographie-engagee.svg",
      "word": "biographie engagee"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/discours-solange.svg",
      "word": "discours solange"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur expliquer un implicite ; métaphore ; message d'un chant inventé, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les paroles inventées de Sami et l'article de Mado sur le refrain distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Sami',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Expliquer le message d'un chant de cour inventé, y compris ce qu'il ne dit pas. Point : expliquer un implicite ; métaphore ; message d'un chant inventé.

Consigne
Imitez le texte de Sami.

Support — Sami — Le refrain n'est pas un décor
Sami — Le refrain n'est pas un décor
On parle trop vite de le chant inventé de la cour, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise le chant à un air, un refrain trop clair pour n'être pas une porte fermée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer.
Ce que l'on nomme refrain, ici, n'est pas un slogan : retour d'un chant, parfois une porte.
Sami : le refrain dit colline, et l'on entend trop vite panorama.
Léa refuse le mot verlan collé pour faire vrai.
Lila jouera l'air, puis le silence.
Yvette : c'est juste une chanson est déjà une politique.
La proposition qui reste debout est celle-ci : expliquer le message : qui parle, qui n'est pas nommé, quel geste le refrain demande
Marc : le message, c'est aussi qui n'a pas le micro.
Nous clôturons sans fusionner les voix : les paroles inventées de Sami d'un côté, l'article de Mado sur le refrain de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on explique, un refrain trop clair pour n'être pas une porte fermée n'est pas un détail.
Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
un chant engagé n'a pas besoin de slogan : l'implicite fait le travail, encore faut-il le lire
Sami, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : expliquer le message : qui parle, qui n'est pas nommé, quel geste le refrain demande",
  "correct": true,
  "explanation": "expliquer le message : qui parle, qui n'est pas nommé, quel geste le refrain demande"
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
      "text": "expliquer le message : qui parle, qui n'est pas nommé, quel geste le refrain demande",
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
  "explanation": "expliquer le message : qui parle, qui n'est pas nommé, quel geste le refrain demande"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "refrain",
      "right": "retour d'un chant, parfois une porte"
    },
    {
      "left": "implicite",
      "right": "non-dit qui travaille le message"
    },
    {
      "left": "métaphore",
      "right": "image qui dit autrement"
    },
    {
      "left": "message",
      "right": "ce que le chant fait, au-delà de l'air"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUn ___ n'est pas une trahison : c'est un choix de relation. (registre)",
  "answer": "registre"
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
    "registre",
    "n'est",
    "pas",
    "une",
    "trahison",
    "c'est",
    "un",
    "choix",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "message",
  "hint": "ce que le chant fait, au-delà de l'air"
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
      "image_path": "/elearning/mfk-c1-m5/message-chanson.svg",
      "word": "message chanson"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/biographie-engagee.svg",
      "word": "biographie engagee"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/discours-solange.svg",
      "word": "discours solange"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/necrologie-douce.svg",
      "word": "necrologie douce"
    }
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
    'EL — expliquer un implicite ; métaphore ; message d''un chant inventé',
    'EL',
    $c$Objectif
Maîtriser expliquer un implicite ; métaphore ; message d'un chant inventé au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — expliquer un implicite ; métaphore ; message d'un chant inventé
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on explique, un refrain trop clair pour n'être pas une porte fermée n'est pas un détail.
Sami concède que on peut aimer l'air sans tout décoder, pour autant que l'on n'interdise pas à ceux qui habitent le refrain de l'expliquer.
Autrement dit, un chant engagé n'a pas besoin de slogan : l'implicite fait le travail, encore faut-il le lire
Il ressort qu'expliquer le message : qui parle, qui n'est pas nommé, quel geste le refrain demande
Piège : familier non signalé dans un discours d'assemblée
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme refrain, ici, n'est pas un slogan : retour d'un chant, parfois une porte.
Solange entend une porte.
Léa refuse le mot verlan collé pour faire vrai.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au métaphore pour de vrai genre, et Solange Mukamana demande un registre plus net.
Correction : On va au métaphore vraiment, et Solange Mukamana demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le vouvoiement du micro peut coexister avec le tutoiement du banc.",
  "correct": true,
  "explanation": "Registres situés."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Changer de registre, c'est surtout…",
  "options": [
    {
      "text": "parler « faux »",
      "correct": false
    },
    {
      "text": "ajuster la relation et l'oreille",
      "correct": true
    },
    {
      "text": "oublier la grammaire",
      "correct": false
    },
    {
      "text": "interdire le figuier",
      "correct": false
    }
  ],
  "explanation": "Variation de registre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "refrain",
      "right": "retour d'un chant, parfois une porte"
    },
    {
      "left": "implicite",
      "right": "non-dit qui travaille le message"
    },
    {
      "left": "métaphore",
      "right": "image qui dit autrement"
    },
    {
      "left": "message",
      "right": "ce que le chant fait, au-delà de l'air"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLoin de ___, adapter le discours c'est respecter l'oreille. (tricher)",
  "answer": "tricher"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Adapter",
    "le",
    "discours",
    "c'est",
    "respecter",
    "l'oreille",
    "."
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
  "sentence_with_error": "On va au métaphore pour de vrai genre, et Solange Mukamana demande un registre plus net.",
  "correct_sentence": "On va au métaphore vraiment, et Solange Mukamana demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m5/biographie-engagee.svg",
      "word": "biographie engagee"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/discours-solange.svg",
      "word": "discours solange"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/necrologie-douce.svg",
      "word": "necrologie douce"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/portrait-voix.svg",
      "word": "portrait voix"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « expliquer un implicite ; métaphore ; message d'un chant inventé » et deux pièges commentés."
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

  -- ===== Biographie engagée =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Biographie engagée'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Biographie engagée', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Biographie engagée',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Résumer un discours et écrire la biographie d'une voix engagée de la cour. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Biographie engagée
Lila Sow : Radio Figuier. On parle trop vite de la biographie de Solange Mukamana, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme Solange en statue, une nécrologie trop douce de son vivant n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Aline Uwase : Ce que l'on nomme biographie, ici, n'est pas un slogan : récit d'une vie, sans statue.
Patrick Habimana : Il fut un temps où Solange parlait trop tôt pour trop de portes.
Hawa Diallo : Elle avait déjà exigé la rampe quand on la disait trop pressée.
Joël Mugisha : Mado résume le discours sans le sucrer.
Rose Iradukunda : Aline : le plus-que-parfait dit l'antériorité d'une lutte, pas le mythe.
Solange Mukamana : Patrick refuse exceptionnelle : trop commode.
Karim Bamba : Lila lira la bio si Solange la signe.
Félicie Ndayishimiye : Un chiffre, une trace : Solange a ouvert quatre portes ; Mado a raturé six adjectifs trop grands ; un discours lu deux fois.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'écrire une vie qui reste une vie, pas un exemple impossible
Yvette : Yvette se reconnaît dans une porte, pas dans une couronne.
Mado : Solange Mukamana entend, dans « une femme exceptionnelle », ceci qui n'est pas dit : exceptionnelle permet de ne pas rendre ordinaires les droits qu'elle a exigés
Sami : Autrement dit, une biographie engagée relie les faits aux luttes, sans hagiographie
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : deux pages : dates, discours, ce qu'elle a refusé qu'on dise d'elle
Nina Kayitesi : Marc : selon le discours, il ressort que l'honneur véritable, c'est la date d'une rampe.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le discours de Solange sous le figuier d'un côté, la biographie raturée de Mado de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une nécrologie trop douce de son vivant est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une nécrologie trop douce de son vivant n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Solange Mukamana, que reste-t-il implicite dans « une femme exceptionnelle » ?",
  "options": [
    {
      "text": "Que Solange a demandé une statue",
      "correct": false
    },
    {
      "text": "Ne pas rendre ordinaires les droits exigés",
      "correct": true
    },
    {
      "text": "Que Mado a inventé les portes",
      "correct": false
    },
    {
      "text": "Que le discours n'a jamais eu lieu",
      "correct": false
    }
  ],
  "explanation": "exceptionnelle permet de ne pas rendre ordinaires les droits qu'elle a exigés"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "biographie",
      "right": "récit d'une vie, sans statue"
    },
    {
      "left": "discours",
      "right": "parole publique à résumer"
    },
    {
      "left": "lutte",
      "right": "geste répété, plus qu'un adjectif"
    },
    {
      "left": "hagiographie",
      "right": "vie trop sainte pour rester vraie"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSelon Mado, il ___ que deux documents s'opposent. (ressortir)",
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
    "Mado",
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
  "word": "biographie",
  "hint": "récit d'une vie, sans statue"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Selon Mado, il ressort que les deux textes est d'accord, et Lila coupe le micro.",
  "correct_sentence": "Selon Mado, il ressort que les deux textes sont d'accord, et Lila coupe le micro.",
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
      "image_path": "/elearning/mfk-c1-m5/discours-solange.svg",
      "word": "discours solange"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/necrologie-douce.svg",
      "word": "necrologie douce"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/portrait-voix.svg",
      "word": "portrait voix"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/terre-accueil.svg",
      "word": "terre accueil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « une femme exceptionnelle » et la concession de Mado."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le discours de Solange sous le figuier et la biographie raturée de Mado distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Pas une statue',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Résumer un discours et écrire la biographie d'une voix engagée de la cour. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Pas une statue », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Pas une statue
On parle trop vite de la biographie de Solange Mukamana, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme Solange en statue, une nécrologie trop douce de son vivant n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Ce que l'on nomme biographie, ici, n'est pas un slogan : récit d'une vie, sans statue.
Il fut un temps où Solange parlait trop tôt pour trop de portes.
Elle avait déjà exigé la rampe quand on la disait trop pressée.
Mado résume le discours sans le sucrer.
Aline : le plus-que-parfait dit l'antériorité d'une lutte, pas le mythe.
Patrick refuse exceptionnelle : trop commode.
Lila lira la bio si Solange la signe.
Un chiffre, une trace : Solange a ouvert quatre portes ; Mado a raturé six adjectifs trop grands ; un discours lu deux fois.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'écrire une vie qui reste une vie, pas un exemple impossible
Yvette se reconnaît dans une porte, pas dans une couronne.
Solange Mukamana entend, dans « une femme exceptionnelle », ceci qui n'est pas dit : exceptionnelle permet de ne pas rendre ordinaires les droits qu'elle a exigés
Autrement dit, une biographie engagée relie les faits aux luttes, sans hagiographie
La proposition qui reste debout est celle-ci : deux pages : dates, discours, ce qu'elle a refusé qu'on dise d'elle
Marc : selon le discours, il ressort que l'honneur véritable, c'est la date d'une rampe.
Nous clôturons sans fusionner les voix : le discours de Solange sous le figuier d'un côté, la biographie raturée de Mado de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le discours de Solange sous le figuier et la biographie raturée de Mado en une seule affiche.",
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
      "text": "Quatre portes, six adjectifs raturés, un discours relu",
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
  "explanation": "Solange a ouvert quatre portes ; Mado a raturé six adjectifs trop grands ; un discours lu deux fois."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "biographie",
      "right": "récit d'une vie, sans statue"
    },
    {
      "left": "discours",
      "right": "parole publique à résumer"
    },
    {
      "left": "lutte",
      "right": "geste répété, plus qu'un adjectif"
    },
    {
      "left": "hagiographie",
      "right": "vie trop sainte pour rester vraie"
    }
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
  "word": "discours",
  "hint": "parole publique à résumer"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La biographie de trop vite n'aide personne, et Solange Mukamana reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m5/necrologie-douce.svg",
      "word": "necrologie douce"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/portrait-voix.svg",
      "word": "portrait voix"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/terre-accueil.svg",
      "word": "terre accueil"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/poeme-rive.svg",
      "word": "poeme rive"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Pas une statue » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Biographie engagée : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : plus-que-parfait ; il fut un temps ; résumé d'un discours.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme Solange en statue, une nécrologie trop douce de son vivant n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Ce que l'on nomme biographie, ici, n'est pas un slogan : récit d'une vie, sans statue.
Encore que l'on raconte, une nécrologie trop douce de son vivant n'est pas un détail.
Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Autrement dit, une biographie engagée relie les faits aux luttes, sans hagiographie
Il ressort que deux pages : dates, discours, ce qu'elle a refusé qu'on dise d'elle
Elle avait déjà exigé la rampe quand on la disait trop pressée.
Patrick refuse exceptionnelle : trop commode.
La proposition qui reste debout est celle-ci : deux pages : dates, discours, ce qu'elle a refusé qu'on dise d'elle
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le discours de Solange sous le figuier d'un côté, la biographie raturée de Mado de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes."
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
      "text": "honorer peut être juste — à condition que l'on raconte les portes, pas seulement les couronnes",
      "correct": true
    },
    {
      "text": "Mado abandonne il s'agit d'écrire une vie qui reste une vie, pas un exemple impossible",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on raconte les portes, pas seulement les couronnes"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "biographie",
      "right": "récit d'une vie, sans statue"
    },
    {
      "left": "discours",
      "right": "parole publique à résumer"
    },
    {
      "left": "lutte",
      "right": "geste répété, plus qu'un adjectif"
    },
    {
      "left": "hagiographie",
      "right": "vie trop sainte pour rester vraie"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl appert que biographie n'est pas un slogan.",
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
  "word": "lutte",
  "hint": "geste répété, plus qu'un adjectif"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Mado écoute encore, et il fautons raconter avant de crier.",
  "correct_sentence": "Mado écoute encore, et il faut raconter avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m5/portrait-voix.svg",
      "word": "portrait voix"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/terre-accueil.svg",
      "word": "terre accueil"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/poeme-rive.svg",
      "word": "poeme rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/chronique-humor.svg",
      "word": "chronique humor"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur plus-que-parfait ; il fut un temps ; résumé d'un discours, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le discours de Solange sous le figuier et la biographie raturée de Mado distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Mado',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Résumer un discours et écrire la biographie d'une voix engagée de la cour. Point : plus-que-parfait ; il fut un temps ; résumé d'un discours.

Consigne
Imitez le texte de Mado.

Support — Mado — Pas une statue
Mado — Pas une statue
On parle trop vite de la biographie de Solange Mukamana, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme Solange en statue, une nécrologie trop douce de son vivant n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Ce que l'on nomme biographie, ici, n'est pas un slogan : récit d'une vie, sans statue.
Il fut un temps où Solange parlait trop tôt pour trop de portes.
Patrick refuse exceptionnelle : trop commode.
Lila lira la bio si Solange la signe.
Yvette se reconnaît dans une porte, pas dans une couronne.
La proposition qui reste debout est celle-ci : deux pages : dates, discours, ce qu'elle a refusé qu'on dise d'elle
Marc : selon le discours, il ressort que l'honneur véritable, c'est la date d'une rampe.
Nous clôturons sans fusionner les voix : le discours de Solange sous le figuier d'un côté, la biographie raturée de Mado de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on raconte, une nécrologie trop douce de son vivant n'est pas un détail.
Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
une biographie engagée relie les faits aux luttes, sans hagiographie
Mado, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : deux pages : dates, discours, ce qu'elle a refusé qu'on dise d'elle",
  "correct": true,
  "explanation": "deux pages : dates, discours, ce qu'elle a refusé qu'on dise d'elle"
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
      "text": "deux pages : dates, discours, ce qu'elle a refusé qu'on dise d'elle",
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
  "explanation": "deux pages : dates, discours, ce qu'elle a refusé qu'on dise d'elle"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "biographie",
      "right": "récit d'une vie, sans statue"
    },
    {
      "left": "discours",
      "right": "parole publique à résumer"
    },
    {
      "left": "lutte",
      "right": "geste répété, plus qu'un adjectif"
    },
    {
      "left": "hagiographie",
      "right": "vie trop sainte pour rester vraie"
    }
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
  "word": "hagiographie",
  "hint": "vie trop sainte pour rester vraie"
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
      "image_path": "/elearning/mfk-c1-m5/terre-accueil.svg",
      "word": "terre accueil"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/poeme-rive.svg",
      "word": "poeme rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/chronique-humor.svg",
      "word": "chronique humor"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/valise-ouverte.svg",
      "word": "valise ouverte"
    }
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
    'EL — plus-que-parfait ; il fut un temps ; résumé d''un discours',
    'EL',
    $c$Objectif
Maîtriser plus-que-parfait ; il fut un temps ; résumé d'un discours au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — plus-que-parfait ; il fut un temps ; résumé d'un discours
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on raconte, une nécrologie trop douce de son vivant n'est pas un détail.
Mado concède que honorer peut être juste, pour autant que l'on raconte les portes, pas seulement les couronnes.
Autrement dit, une biographie engagée relie les faits aux luttes, sans hagiographie
Il ressort que deux pages : dates, discours, ce qu'elle a refusé qu'on dise d'elle
Piège : fusionner les sources au lieu de les attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme biographie, ici, n'est pas un slogan : récit d'une vie, sans statue.
Elle avait déjà exigé la rampe quand on la disait trop pressée.
Patrick refuse exceptionnelle : trop commode.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au lutte pour de vrai genre, et Solange Mukamana demande un registre plus net.
Correction : On va au lutte vraiment, et Solange Mukamana demande un registre plus net.
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
      "left": "biographie",
      "right": "récit d'une vie, sans statue"
    },
    {
      "left": "discours",
      "right": "parole publique à résumer"
    },
    {
      "left": "lutte",
      "right": "geste répété, plus qu'un adjectif"
    },
    {
      "left": "hagiographie",
      "right": "vie trop sainte pour rester vraie"
    }
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
  "sentence_with_error": "On va au lutte pour de vrai genre, et Solange Mukamana demande un registre plus net.",
  "correct_sentence": "On va au lutte vraiment, et Solange Mukamana demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m5/poeme-rive.svg",
      "word": "poeme rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/chronique-humor.svg",
      "word": "chronique humor"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/valise-ouverte.svg",
      "word": "valise ouverte"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/ages-vie.svg",
      "word": "ages vie"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « plus-que-parfait ; il fut un temps ; résumé d'un discours » et deux pièges commentés."
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

  -- ===== Le sourire n'est pas un lit =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Le sourire n''est pas un lit'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Le sourire n''est pas un lit', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le sourire n''est pas un lit',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Comprendre une chronique d'accueil et écrire un poème sans slogan. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le sourire n'est pas un lit
Lila Sow : Radio Figuier. On parle trop vite de l'accueil à Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on tienne lieu de lit et de papiers, un sourire trop large à la porte du Pavillon n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Hawa Diallo concède que un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Aline Uwase : Ce que l'on nomme accueil, ici, n'est pas un slogan : geste concret, distinct d'un mot.
Patrick Habimana : Hawa : il ne s'agirait que d'un détail, le lit, à entendre certains sourires.
Hawa Diallo : Loin de rassurer, le mot hospitaliers fatigue quand la clé manque.
Joël Mugisha : Mado écrit une chronique où le sourire trébuche, sans écraser personne.
Rose Iradukunda : Aline : l'humour ici n'est pas une arme contre ceux qui arrivent.
Solange Mukamana : Patrick pose un banc.
Karim Bamba : Rose coud un ourlet trop large pour une valise trop pleine.
Félicie Ndayishimiye : Un chiffre, une trace : Hawa a reçu trois valises ; deux clés ; un sourire sans banc. Mado en a fait huit vers.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'accueillir des personnes, pas d'illustrer une vertu
Yvette : Lila lira le poème lentement.
Mado : Dieudonné Hakizimana entend, dans « nous sommes hospitaliers », ceci qui n'est pas dit : nous sommes hospitaliers se dit trop souvent à ceux à qui l'on n'a rien donné
Sami : Autrement dit, le poème peut dire l'accueil mieux qu'une affiche, s'il nomme la clé
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une chronique d'humour sans mépris, puis un poème qui tient dans la poche
Nina Kayitesi : Marc : une terre d'accueil se mesure aux clés, pas aux phrases.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : la chronique de Mado d'un côté, le poème d'Hawa de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un sourire trop large à la porte du Pavillon est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un sourire trop large à la porte du Pavillon n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Dieudonné Hakizimana, que reste-t-il implicite dans « nous sommes hospitaliers » ?",
  "options": [
    {
      "text": "Que Hawa a fermé le Pavillon",
      "correct": false
    },
    {
      "text": "Rien donné, mot doux offert",
      "correct": true
    },
    {
      "text": "Que Mado se moque des valises",
      "correct": false
    },
    {
      "text": "Que Dieudonné refuse les clés",
      "correct": false
    }
  ],
  "explanation": "nous sommes hospitaliers se dit trop souvent à ceux à qui l'on n'a rien donné"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accueil",
      "right": "geste concret, distinct d'un mot"
    },
    {
      "left": "chronique",
      "right": "texte court, parfois humoristique"
    },
    {
      "left": "poème",
      "right": "forme brève qui peut nommer la clé"
    },
    {
      "left": "hospitalité",
      "right": "pratique, pas une affiche"
    }
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
  "word": "accueil",
  "hint": "geste concret, distinct d'un mot"
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
      "image_path": "/elearning/mfk-c1-m5/chronique-humor.svg",
      "word": "chronique humor"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/valise-ouverte.svg",
      "word": "valise ouverte"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/ages-vie.svg",
      "word": "ages vie"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/deux-generations.svg",
      "word": "deux generations"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « nous sommes hospitaliers » et la concession de Hawa Diallo."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez la chronique de Mado et le poème d'Hawa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le sourire n''est pas un lit',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comprendre une chronique d'accueil et écrire un poème sans slogan. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le sourire n'est pas un lit », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le sourire n'est pas un lit
On parle trop vite de l'accueil à Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu de lit et de papiers, un sourire trop large à la porte du Pavillon n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Ce que l'on nomme accueil, ici, n'est pas un slogan : geste concret, distinct d'un mot.
Hawa : il ne s'agirait que d'un détail, le lit, à entendre certains sourires.
Loin de rassurer, le mot hospitaliers fatigue quand la clé manque.
Mado écrit une chronique où le sourire trébuche, sans écraser personne.
Aline : l'humour ici n'est pas une arme contre ceux qui arrivent.
Patrick pose un banc.
Rose coud un ourlet trop large pour une valise trop pleine.
Un chiffre, une trace : Hawa a reçu trois valises ; deux clés ; un sourire sans banc. Mado en a fait huit vers.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'accueillir des personnes, pas d'illustrer une vertu
Lila lira le poème lentement.
Dieudonné Hakizimana entend, dans « nous sommes hospitaliers », ceci qui n'est pas dit : nous sommes hospitaliers se dit trop souvent à ceux à qui l'on n'a rien donné
Autrement dit, le poème peut dire l'accueil mieux qu'une affiche, s'il nomme la clé
La proposition qui reste debout est celle-ci : une chronique d'humour sans mépris, puis un poème qui tient dans la poche
Marc : une terre d'accueil se mesure aux clés, pas aux phrases.
Nous clôturons sans fusionner les voix : la chronique de Mado d'un côté, le poème d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Signé : Hawa Diallo, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner la chronique de Mado et le poème d'Hawa en une seule affiche.",
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
      "text": "Trois valises, deux clés, un sourire sans banc",
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
  "explanation": "Hawa a reçu trois valises ; deux clés ; un sourire sans banc. Mado en a fait huit vers."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accueil",
      "right": "geste concret, distinct d'un mot"
    },
    {
      "left": "chronique",
      "right": "texte court, parfois humoristique"
    },
    {
      "left": "poème",
      "right": "forme brève qui peut nommer la clé"
    },
    {
      "left": "hospitalité",
      "right": "pratique, pas une affiche"
    }
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
  "word": "chronique",
  "hint": "texte court, parfois humoristique"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La accueil de trop vite n'aide personne, et Dieudonné Hakizimana reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m5/valise-ouverte.svg",
      "word": "valise ouverte"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/ages-vie.svg",
      "word": "ages vie"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/deux-generations.svg",
      "word": "deux generations"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/registre-soutenu.svg",
      "word": "registre soutenu"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le sourire n'est pas un lit » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Le sourire n''est pas un lit : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : humour et sous-entendu ; écrire un poème ; chronique.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on tienne lieu de lit et de papiers, un sourire trop large à la porte du Pavillon n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Ce que l'on nomme accueil, ici, n'est pas un slogan : geste concret, distinct d'un mot.
Encore que l'on accueille, un sourire trop large à la porte du Pavillon n'est pas un détail.
Hawa Diallo concède que un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Autrement dit, le poème peut dire l'accueil mieux qu'une affiche, s'il nomme la clé
Il ressort qu'une chronique d'humour sans mépris, puis un poème qui tient dans la poche
Loin de rassurer, le mot hospitaliers fatigue quand la clé manque.
Patrick pose un banc.
La proposition qui reste debout est celle-ci : une chronique d'humour sans mépris, puis un poème qui tient dans la poche
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : la chronique de Mado d'un côté, le poème d'Hawa de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Hawa Diallo concède que un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure."
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
      "text": "un mot doux peut ouvrir — à condition que l'on pose ensuite un lit, une clé, une heure",
      "correct": true
    },
    {
      "text": "Hawa Diallo abandonne il s'agit d'accueillir des personnes, pas d'illustrer une vertu",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on pose ensuite un lit, une clé, une heure"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accueil",
      "right": "geste concret, distinct d'un mot"
    },
    {
      "left": "chronique",
      "right": "texte court, parfois humoristique"
    },
    {
      "left": "poème",
      "right": "forme brève qui peut nommer la clé"
    },
    {
      "left": "hospitalité",
      "right": "pratique, pas une affiche"
    }
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
  "word": "poème",
  "hint": "forme brève qui peut nommer la clé"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Hawa Diallo écoute encore, et il fautons accueillir avant de crier.",
  "correct_sentence": "Hawa Diallo écoute encore, et il faut accueillir avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m5/ages-vie.svg",
      "word": "ages vie"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/deux-generations.svg",
      "word": "deux generations"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/registre-soutenu.svg",
      "word": "registre soutenu"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/banc-anciens.svg",
      "word": "banc anciens"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur humour et sous-entendu ; écrire un poème ; chronique, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez la chronique de Mado et le poème d'Hawa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Hawa Diallo',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Comprendre une chronique d'accueil et écrire un poème sans slogan. Point : humour et sous-entendu ; écrire un poème ; chronique.

Consigne
Imitez le texte de Hawa Diallo.

Support — Hawa Diallo — Le sourire n'est pas un lit
Hawa Diallo — Le sourire n'est pas un lit
On parle trop vite de l'accueil à Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Encore que l'on tienne lieu de lit et de papiers, un sourire trop large à la porte du Pavillon n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Ce que l'on nomme accueil, ici, n'est pas un slogan : geste concret, distinct d'un mot.
Hawa : il ne s'agirait que d'un détail, le lit, à entendre certains sourires.
Patrick pose un banc.
Rose coud un ourlet trop large pour une valise trop pleine.
Lila lira le poème lentement.
La proposition qui reste debout est celle-ci : une chronique d'humour sans mépris, puis un poème qui tient dans la poche
Marc : une terre d'accueil se mesure aux clés, pas aux phrases.
Nous clôturons sans fusionner les voix : la chronique de Mado d'un côté, le poème d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on accueille, un sourire trop large à la porte du Pavillon n'est pas un détail.
Hawa Diallo concède que un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
le poème peut dire l'accueil mieux qu'une affiche, s'il nomme la clé
Hawa Diallo, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : une chronique d'humour sans mépris, puis un poème qui tient dans la poche",
  "correct": true,
  "explanation": "une chronique d'humour sans mépris, puis un poème qui tient dans la poche"
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
      "text": "une chronique d'humour sans mépris, puis un poème qui tient dans la poche",
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
  "explanation": "une chronique d'humour sans mépris, puis un poème qui tient dans la poche"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accueil",
      "right": "geste concret, distinct d'un mot"
    },
    {
      "left": "chronique",
      "right": "texte court, parfois humoristique"
    },
    {
      "left": "poème",
      "right": "forme brève qui peut nommer la clé"
    },
    {
      "left": "hospitalité",
      "right": "pratique, pas une affiche"
    }
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
  "word": "hospitalité",
  "hint": "pratique, pas une affiche"
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
      "image_path": "/elearning/mfk-c1-m5/deux-generations.svg",
      "word": "deux generations"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/registre-soutenu.svg",
      "word": "registre soutenu"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/banc-anciens.svg",
      "word": "banc anciens"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/comparaison-ages.svg",
      "word": "comparaison ages"
    }
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
    'EL — humour et sous-entendu ; écrire un poème ; chronique',
    'EL',
    $c$Objectif
Maîtriser humour et sous-entendu ; écrire un poème ; chronique au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — humour et sous-entendu ; écrire un poème ; chronique
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on accueille, un sourire trop large à la porte du Pavillon n'est pas un détail.
Hawa Diallo concède que un mot doux peut ouvrir, pour autant que l'on pose ensuite un lit, une clé, une heure.
Autrement dit, le poème peut dire l'accueil mieux qu'une affiche, s'il nomme la clé
Il ressort qu'une chronique d'humour sans mépris, puis un poème qui tient dans la poche
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme accueil, ici, n'est pas un slogan : geste concret, distinct d'un mot.
Loin de rassurer, le mot hospitaliers fatigue quand la clé manque.
Patrick pose un banc.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au poème pour de vrai genre, et Dieudonné Hakizimana demande un registre plus net.
Correction : On va au poème vraiment, et Dieudonné Hakizimana demande un registre plus net.
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
      "left": "accueil",
      "right": "geste concret, distinct d'un mot"
    },
    {
      "left": "chronique",
      "right": "texte court, parfois humoristique"
    },
    {
      "left": "poème",
      "right": "forme brève qui peut nommer la clé"
    },
    {
      "left": "hospitalité",
      "right": "pratique, pas une affiche"
    }
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
  "sentence_with_error": "On va au poème pour de vrai genre, et Dieudonné Hakizimana demande un registre plus net.",
  "correct_sentence": "On va au poème vraiment, et Dieudonné Hakizimana demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m5/registre-soutenu.svg",
      "word": "registre soutenu"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/banc-anciens.svg",
      "word": "banc anciens"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/comparaison-ages.svg",
      "word": "comparaison ages"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/sketch-sami.svg",
      "word": "sketch sami"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « humour et sous-entendu ; écrire un poème ; chronique » et deux pièges commentés."
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

  -- ===== Deux vitesses une cour =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Deux vitesses une cour'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Deux vitesses une cour', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Deux vitesses une cour',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Comparer deux générations et adapter le registre sans mépris. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Deux vitesses une cour
Lila Sow : Radio Figuier. On parle trop vite de deux âges sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on ferme l'oreille aux plus jeunes ou aux plus vieux, un sketch trop sûr de ses cibles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs.
Aline Uwase : Ce que l'on nomme génération, ici, n'est pas un slogan : âge d'une parole, pas une armée.
Patrick Habimana : Yvette : de mon temps, on disait cela, et ce n'était pas toujours mieux.
Hawa Diallo : Sami tutole trop vite le micro ; Aline lui rappelle l'oreille de l'assemblée.
Joël Mugisha : Alors que les lanternes pèsent pareil, les récits d'effort divergent.
Rose Iradukunda : Patrick refuse le sketch qui écrase.
Solange Mukamana : Mado rature trois vannes.
Karim Bamba : Lila vouvoie, puis explique pourquoi.
Félicie Ndayishimiye : Un chiffre, une trace : Yvette vouvoie Lila au micro ; tutole Sami au banc ; Sami inverse parfois, et l'on en parle.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la cour tienne deux vitesses de parole sans humiliation
Yvette : Joël se tait : le fer n'a pas d'âge, dit-il.
Mado : Sami entend, dans « de mon temps », ceci qui n'est pas dit : de mon temps veut souvent dire le vôtre ne compte pas
Sami : Autrement dit, comparer des âges, c'est croiser des registres, pas couronner une génération
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un dialogue : Yvette et Sami, deux registres, une cour commune
Nina Kayitesi : Marc : adapter le registre, c'est respecter l'oreille, pas trahir.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le portrait d'Yvette par Mado d'un côté, le sketch trop dur de Sami, raturé de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un sketch trop sûr de ses cibles est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un sketch trop sûr de ses cibles n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Sami, que reste-t-il implicite dans « de mon temps » ?",
  "options": [
    {
      "text": "Que Yvette interdit Sami",
      "correct": false
    },
    {
      "text": "Votre temps ne compte pas",
      "correct": true
    },
    {
      "text": "Que Sami a humilié Yvette à l'antenne",
      "correct": false
    },
    {
      "text": "Que Lila refuse les deux registres",
      "correct": false
    }
  ],
  "explanation": "de mon temps veut souvent dire le vôtre ne compte pas"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "génération",
      "right": "âge d'une parole, pas une armée"
    },
    {
      "left": "registre",
      "right": "niveau de langue choisi"
    },
    {
      "left": "tutoiement",
      "right": "proximité, pas un droit automatique"
    },
    {
      "left": "vouvoiement",
      "right": "distance parfois respectueuse au micro"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAu registre soutenu, on dira ___ et non « c'est pas ouf ». (cela)",
  "answer": "cela"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Au",
    "registre",
    "soutenu",
    "on",
    "dira",
    "cela",
    "et",
    "non",
    "un",
    "mot",
    "trop",
    "large",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "génération",
  "hint": "âge d'une parole, pas une armée"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Au registre soutenu, on dira ça ouais, et Yvette lit encore la motion.",
  "correct_sentence": "Au registre soutenu, on dira cela, et Yvette lit encore la motion.",
  "explanation": "Soutenu : cela, pas ça ouais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m5/banc-anciens.svg",
      "word": "banc anciens"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/comparaison-ages.svg",
      "word": "comparaison ages"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/sketch-sami.svg",
      "word": "sketch sami"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/micro-monde.svg",
      "word": "micro monde"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « de mon temps » et la concession de Yvette."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le portrait d'Yvette par Mado et le sketch trop dur de Sami, raturé distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Deux vitesses, une cour',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comparer deux générations et adapter le registre sans mépris. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Deux vitesses, une cour », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Deux vitesses, une cour
On parle trop vite de deux âges sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on ferme l'oreille aux plus jeunes ou aux plus vieux, un sketch trop sûr de ses cibles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs.
Ce que l'on nomme génération, ici, n'est pas un slogan : âge d'une parole, pas une armée.
Yvette : de mon temps, on disait cela, et ce n'était pas toujours mieux.
Sami tutole trop vite le micro ; Aline lui rappelle l'oreille de l'assemblée.
Alors que les lanternes pèsent pareil, les récits d'effort divergent.
Patrick refuse le sketch qui écrase.
Mado rature trois vannes.
Lila vouvoie, puis explique pourquoi.
Un chiffre, une trace : Yvette vouvoie Lila au micro ; tutole Sami au banc ; Sami inverse parfois, et l'on en parle.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la cour tienne deux vitesses de parole sans humiliation
Joël se tait : le fer n'a pas d'âge, dit-il.
Sami entend, dans « de mon temps », ceci qui n'est pas dit : de mon temps veut souvent dire le vôtre ne compte pas
Autrement dit, comparer des âges, c'est croiser des registres, pas couronner une génération
La proposition qui reste debout est celle-ci : un dialogue : Yvette et Sami, deux registres, une cour commune
Marc : adapter le registre, c'est respecter l'oreille, pas trahir.
Nous clôturons sans fusionner les voix : le portrait d'Yvette par Mado d'un côté, le sketch trop dur de Sami, raturé de l'autre, et le point où elles refusent de se ressembler.
Signé : Yvette, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le portrait d'Yvette par Mado et le sketch trop dur de Sami, raturé en une seule affiche.",
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
      "text": "Vouvoiement au micro, tutoiement au banc, un écart discuté",
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
  "explanation": "Yvette vouvoie Lila au micro ; tutole Sami au banc ; Sami inverse parfois, et l'on en parle."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "génération",
      "right": "âge d'une parole, pas une armée"
    },
    {
      "left": "registre",
      "right": "niveau de langue choisi"
    },
    {
      "left": "tutoiement",
      "right": "proximité, pas un droit automatique"
    },
    {
      "left": "vouvoiement",
      "right": "distance parfois respectueuse au micro"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le tutoiement ___ possible sous le figuier, le micro de Lila vouvoie l'assemblée. (être, subj.)",
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
    "tutoiement",
    "soit",
    "possible",
    "le",
    "micro",
    "vouvoie",
    "l'assemblée",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "registre",
  "hint": "niveau de langue choisi"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La génération de trop vite n'aide personne, et Sami reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Sami reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m5/comparaison-ages.svg",
      "word": "comparaison ages"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/sketch-sami.svg",
      "word": "sketch sami"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/micro-monde.svg",
      "word": "micro monde"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/cahier-combats.svg",
      "word": "cahier combats"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Deux vitesses, une cour » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Deux vitesses une cour : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : registres selon l'interlocuteur ; tutoiement / vouvoiement ; alors que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on ferme l'oreille aux plus jeunes ou aux plus vieux, un sketch trop sûr de ses cibles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs.
Ce que l'on nomme génération, ici, n'est pas un slogan : âge d'une parole, pas une armée.
Encore que l'on adapte, un sketch trop sûr de ses cibles n'est pas un détail.
Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs.
Autrement dit, comparer des âges, c'est croiser des registres, pas couronner une génération
Il ressort qu'un dialogue : Yvette et Sami, deux registres, une cour commune
Sami tutole trop vite le micro ; Aline lui rappelle l'oreille de l'assemblée.
Mado rature trois vannes.
La proposition qui reste debout est celle-ci : un dialogue : Yvette et Sami, deux registres, une cour commune
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le portrait d'Yvette par Mado d'un côté, le sketch trop dur de Sami, raturé de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs."
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
      "text": "les habitudes changent — à condition que l'on n'en fasse pas une guerre de bancs",
      "correct": true
    },
    {
      "text": "Yvette abandonne il s'agit que la cour tienne deux vitesses de parole sans humiliation",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'en fasse pas une guerre de bancs"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "génération",
      "right": "âge d'une parole, pas une armée"
    },
    {
      "left": "registre",
      "right": "niveau de langue choisi"
    },
    {
      "left": "tutoiement",
      "right": "proximité, pas un droit automatique"
    },
    {
      "left": "vouvoiement",
      "right": "distance parfois respectueuse au micro"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ le niveau, non la personne. (adapter, subj.)",
  "answer": "adapte"
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
    "adapte",
    "le",
    "niveau",
    "non",
    "la",
    "personne",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tutoiement",
  "hint": "proximité, pas un droit automatique"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Yvette écoute encore, et il fautons adapter avant de crier.",
  "correct_sentence": "Yvette écoute encore, et il faut adapter avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m5/sketch-sami.svg",
      "word": "sketch sami"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/micro-monde.svg",
      "word": "micro monde"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/cahier-combats.svg",
      "word": "cahier combats"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/feminisme-cour.svg",
      "word": "feminisme cour"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur registres selon l'interlocuteur ; tutoiement / vouvoiement ; alors que, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le portrait d'Yvette par Mado et le sketch trop dur de Sami, raturé distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Yvette',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Comparer deux générations et adapter le registre sans mépris. Point : registres selon l'interlocuteur ; tutoiement / vouvoiement ; alors que.

Consigne
Imitez le texte de Yvette.

Support — Yvette — Deux vitesses, une cour
Yvette — Deux vitesses, une cour
On parle trop vite de deux âges sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on ferme l'oreille aux plus jeunes ou aux plus vieux, un sketch trop sûr de ses cibles n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs.
Ce que l'on nomme génération, ici, n'est pas un slogan : âge d'une parole, pas une armée.
Yvette : de mon temps, on disait cela, et ce n'était pas toujours mieux.
Mado rature trois vannes.
Lila vouvoie, puis explique pourquoi.
Joël se tait : le fer n'a pas d'âge, dit-il.
La proposition qui reste debout est celle-ci : un dialogue : Yvette et Sami, deux registres, une cour commune
Marc : adapter le registre, c'est respecter l'oreille, pas trahir.
Nous clôturons sans fusionner les voix : le portrait d'Yvette par Mado d'un côté, le sketch trop dur de Sami, raturé de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on adapte, un sketch trop sûr de ses cibles n'est pas un détail.
Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
comparer des âges, c'est croiser des registres, pas couronner une génération
Yvette, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un dialogue : Yvette et Sami, deux registres, une cour commune",
  "correct": true,
  "explanation": "un dialogue : Yvette et Sami, deux registres, une cour commune"
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
      "text": "un dialogue : Yvette et Sami, deux registres, une cour commune",
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
  "explanation": "un dialogue : Yvette et Sami, deux registres, une cour commune"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "génération",
      "right": "âge d'une parole, pas une armée"
    },
    {
      "left": "registre",
      "right": "niveau de langue choisi"
    },
    {
      "left": "tutoiement",
      "right": "proximité, pas un droit automatique"
    },
    {
      "left": "vouvoiement",
      "right": "distance parfois respectueuse au micro"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUn ___ n'est pas une trahison : c'est un choix de relation. (registre)",
  "answer": "registre"
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
    "registre",
    "n'est",
    "pas",
    "une",
    "trahison",
    "c'est",
    "un",
    "choix",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "vouvoiement",
  "hint": "distance parfois respectueuse au micro"
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
      "image_path": "/elearning/mfk-c1-m5/micro-monde.svg",
      "word": "micro monde"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/cahier-combats.svg",
      "word": "cahier combats"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/feminisme-cour.svg",
      "word": "feminisme cour"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/main-egale.svg",
      "word": "main egale"
    }
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
    'EL — registres selon l''interlocuteur ; tutoiement / vouvoiement ; alors que',
    'EL',
    $c$Objectif
Maîtriser registres selon l'interlocuteur ; tutoiement / vouvoiement ; alors que au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — registres selon l'interlocuteur ; tutoiement / vouvoiement ; alors que
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on adapte, un sketch trop sûr de ses cibles n'est pas un détail.
Yvette concède que les habitudes changent, pour autant que l'on n'en fasse pas une guerre de bancs.
Autrement dit, comparer des âges, c'est croiser des registres, pas couronner une génération
Il ressort qu'un dialogue : Yvette et Sami, deux registres, une cour commune
Piège : familier non signalé dans un discours d'assemblée
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme génération, ici, n'est pas un slogan : âge d'une parole, pas une armée.
Sami tutole trop vite le micro ; Aline lui rappelle l'oreille de l'assemblée.
Mado rature trois vannes.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au tutoiement pour de vrai genre, et Sami demande un registre plus net.
Correction : On va au tutoiement vraiment, et Sami demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le vouvoiement du micro peut coexister avec le tutoiement du banc.",
  "correct": true,
  "explanation": "Registres situés."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Changer de registre, c'est surtout…",
  "options": [
    {
      "text": "parler « faux »",
      "correct": false
    },
    {
      "text": "ajuster la relation et l'oreille",
      "correct": true
    },
    {
      "text": "oublier la grammaire",
      "correct": false
    },
    {
      "text": "interdire le figuier",
      "correct": false
    }
  ],
  "explanation": "Variation de registre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "génération",
      "right": "âge d'une parole, pas une armée"
    },
    {
      "left": "registre",
      "right": "niveau de langue choisi"
    },
    {
      "left": "tutoiement",
      "right": "proximité, pas un droit automatique"
    },
    {
      "left": "vouvoiement",
      "right": "distance parfois respectueuse au micro"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLoin de ___, adapter le discours c'est respecter l'oreille. (tricher)",
  "answer": "tricher"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Adapter",
    "le",
    "discours",
    "c'est",
    "respecter",
    "l'oreille",
    "."
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
  "sentence_with_error": "On va au tutoiement pour de vrai genre, et Sami demande un registre plus net.",
  "correct_sentence": "On va au tutoiement vraiment, et Sami demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m5/cahier-combats.svg",
      "word": "cahier combats"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/feminisme-cour.svg",
      "word": "feminisme cour"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/main-egale.svg",
      "word": "main egale"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/affiche-accueil.svg",
      "word": "affiche accueil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « registres selon l'interlocuteur ; tutoiement / vouvoiement ; alors que » et deux pièges commentés."
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

  -- ===== Poème et chronique =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Poème et chronique'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Poème et chronique', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Poème et chronique',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Croiser un poème et une chronique pour dire le monde de la cour. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Poème et chronique
Lila Sow : Radio Figuier. On parle trop vite de le cahier des combats, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on sépare trop net la gravité et le rire, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Aline Uwase : Ce que l'on nomme diptyque, ici, n'est pas un slogan : deux volets d'un même propos.
Patrick Habimana : Mado : loin de s'opposer, le vers et la chronique se prêtent la date.
Hawa Diallo : Il ne s'agirait que d'un détail, le genre, à entendre ceux qui ont peur du mélange.
Joël Mugisha : Sami pose un rythme entre les deux.
Rose Iradukunda : Aline accepte le mélange si l'implicite tient.
Solange Mukamana : Solange se reconnaît dans la chronique, Léa dans le vers.
Karim Bamba : Patrick a peur du désordre ; il relit, il cède.
Félicie Ndayishimiye : Un chiffre, une trace : Mado a publié les deux le même jeudi ; Lila a lu l'un, puis l'autre ; trois auditeurs ont entendu le même implicite.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de garder plusieurs langues pour un même monde
Yvette : Lila : deux lectures, une oreille.
Mado : Lila Sow entend, dans « il faut choisir un genre », ceci qui n'est pas dit : choisir un genre veut parfois dire ne sois pas trop vivant
Sami : Autrement dit, la chronique peut porter un vers, le poème une date : le Seuil n'est pas une anthologie trop sage
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un diptyque : huit vers, une chronique, un même non-dit
Nina Kayitesi : Marc : le monde de la cour n'a pas un seul ton, et c'est tant mieux.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le poème de Mado d'un côté, sa chronique du même jeudi de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une cour qui n'aurait droit qu'à un seul ton est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une cour qui n'aurait droit qu'à un seul ton n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Lila Sow, que reste-t-il implicite dans « il faut choisir un genre » ?",
  "options": [
    {
      "text": "Que Mado a volé le chant de Sami",
      "correct": false
    },
    {
      "text": "Ne sois pas trop vivant",
      "correct": true
    },
    {
      "text": "Que Lila n'a lu qu'un genre",
      "correct": false
    },
    {
      "text": "Que le jeudi interdit les vers",
      "correct": false
    }
  ],
  "explanation": "choisir un genre veut parfois dire ne sois pas trop vivant"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "diptyque",
      "right": "deux volets d'un même propos"
    },
    {
      "left": "vers",
      "right": "unité du poème"
    },
    {
      "left": "ton",
      "right": "couleur de la voix, pas une cage"
    },
    {
      "left": "non-dit",
      "right": "charge que les deux textes partagent"
    }
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
  "word": "diptyque",
  "hint": "deux volets d'un même propos"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tant est que le bonheur s'industrialise, il se vend déjà, et Mado sourit trop large.",
  "correct_sentence": "Si tant est que le bonheur s'industrialise, il se vendrait déjà, et Mado sourit trop large.",
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
      "image_path": "/elearning/mfk-c1-m5/feminisme-cour.svg",
      "word": "feminisme cour"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/main-egale.svg",
      "word": "main egale"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/affiche-accueil.svg",
      "word": "affiche accueil"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/lampe-veille.svg",
      "word": "lampe veille"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « il faut choisir un genre » et la concession de Mado."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le poème de Mado et sa chronique du même jeudi distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Deux formes, un non-dit',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Croiser un poème et une chronique pour dire le monde de la cour. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Deux formes, un non-dit », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Deux formes, un non-dit
On parle trop vite de le cahier des combats, comme si le mot dispensait d'en examiner le prix.
Encore que l'on sépare trop net la gravité et le rire, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Ce que l'on nomme diptyque, ici, n'est pas un slogan : deux volets d'un même propos.
Mado : loin de s'opposer, le vers et la chronique se prêtent la date.
Il ne s'agirait que d'un détail, le genre, à entendre ceux qui ont peur du mélange.
Sami pose un rythme entre les deux.
Aline accepte le mélange si l'implicite tient.
Solange se reconnaît dans la chronique, Léa dans le vers.
Patrick a peur du désordre ; il relit, il cède.
Un chiffre, une trace : Mado a publié les deux le même jeudi ; Lila a lu l'un, puis l'autre ; trois auditeurs ont entendu le même implicite.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de garder plusieurs langues pour un même monde
Lila : deux lectures, une oreille.
Lila Sow entend, dans « il faut choisir un genre », ceci qui n'est pas dit : choisir un genre veut parfois dire ne sois pas trop vivant
Autrement dit, la chronique peut porter un vers, le poème une date : le Seuil n'est pas une anthologie trop sage
La proposition qui reste debout est celle-ci : un diptyque : huit vers, une chronique, un même non-dit
Marc : le monde de la cour n'a pas un seul ton, et c'est tant mieux.
Nous clôturons sans fusionner les voix : le poème de Mado d'un côté, sa chronique du même jeudi de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le poème de Mado et sa chronique du même jeudi en une seule affiche.",
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
      "text": "Un jeudi, deux formes, un même implicite",
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
  "explanation": "Mado a publié les deux le même jeudi ; Lila a lu l'un, puis l'autre ; trois auditeurs ont entendu le même implicite."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "diptyque",
      "right": "deux volets d'un même propos"
    },
    {
      "left": "vers",
      "right": "unité du poème"
    },
    {
      "left": "ton",
      "right": "couleur de la voix, pas une cage"
    },
    {
      "left": "non-dit",
      "right": "charge que les deux textes partagent"
    }
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
  "word": "vers",
  "hint": "unité du poème"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La diptyque de trop vite n'aide personne, et Lila Sow reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Lila Sow reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m5/main-egale.svg",
      "word": "main egale"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/affiche-accueil.svg",
      "word": "affiche accueil"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/lampe-veille.svg",
      "word": "lampe veille"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/radio-ages.svg",
      "word": "radio ages"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Deux formes, un non-dit » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Poème et chronique : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : croiser deux genres ; implicite ; humour sans mépris.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on sépare trop net la gravité et le rire, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Ce que l'on nomme diptyque, ici, n'est pas un slogan : deux volets d'un même propos.
Encore que l'on croise, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail.
Mado concède que un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Autrement dit, la chronique peut porter un vers, le poème une date : le Seuil n'est pas une anthologie trop sage
Il ressort qu'un diptyque : huit vers, une chronique, un même non-dit
Il ne s'agirait que d'un détail, le genre, à entendre ceux qui ont peur du mélange.
Solange se reconnaît dans la chronique, Léa dans le vers.
La proposition qui reste debout est celle-ci : un diptyque : huit vers, une chronique, un même non-dit
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le poème de Mado d'un côté, sa chronique du même jeudi de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Mado concède que un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet."
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
      "text": "un genre aide à tenir une forme — à condition que l'on puisse passer de l'un à l'autre sans trahir le sujet",
      "correct": true
    },
    {
      "text": "Mado abandonne il s'agit de garder plusieurs langues pour un même monde",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on puisse passer de l'un à l'autre sans trahir le sujet"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "diptyque",
      "right": "deux volets d'un même propos"
    },
    {
      "left": "vers",
      "right": "unité du poème"
    },
    {
      "left": "ton",
      "right": "couleur de la voix, pas une cage"
    },
    {
      "left": "non-dit",
      "right": "charge que les deux textes partagent"
    }
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
  "word": "ton",
  "hint": "couleur de la voix, pas une cage"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Mado écoute encore, et il fautons croiser avant de crier.",
  "correct_sentence": "Mado écoute encore, et il faut croiser avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m5/affiche-accueil.svg",
      "word": "affiche accueil"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/lampe-veille.svg",
      "word": "lampe veille"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/radio-ages.svg",
      "word": "radio ages"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/soleil-lutte.svg",
      "word": "soleil lutte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur croiser deux genres ; implicite ; humour sans mépris, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le poème de Mado et sa chronique du même jeudi distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Mado',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Croiser un poème et une chronique pour dire le monde de la cour. Point : croiser deux genres ; implicite ; humour sans mépris.

Consigne
Imitez le texte de Mado.

Support — Mado — Deux formes, un non-dit
Mado — Deux formes, un non-dit
On parle trop vite de le cahier des combats, comme si le mot dispensait d'en examiner le prix.
Encore que l'on sépare trop net la gravité et le rire, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Ce que l'on nomme diptyque, ici, n'est pas un slogan : deux volets d'un même propos.
Mado : loin de s'opposer, le vers et la chronique se prêtent la date.
Solange se reconnaît dans la chronique, Léa dans le vers.
Patrick a peur du désordre ; il relit, il cède.
Lila : deux lectures, une oreille.
La proposition qui reste debout est celle-ci : un diptyque : huit vers, une chronique, un même non-dit
Marc : le monde de la cour n'a pas un seul ton, et c'est tant mieux.
Nous clôturons sans fusionner les voix : le poème de Mado d'un côté, sa chronique du même jeudi de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on croise, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail.
Mado concède que un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
la chronique peut porter un vers, le poème une date : le Seuil n'est pas une anthologie trop sage
Mado, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un diptyque : huit vers, une chronique, un même non-dit",
  "correct": true,
  "explanation": "un diptyque : huit vers, une chronique, un même non-dit"
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
      "text": "un diptyque : huit vers, une chronique, un même non-dit",
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
  "explanation": "un diptyque : huit vers, une chronique, un même non-dit"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "diptyque",
      "right": "deux volets d'un même propos"
    },
    {
      "left": "vers",
      "right": "unité du poème"
    },
    {
      "left": "ton",
      "right": "couleur de la voix, pas une cage"
    },
    {
      "left": "non-dit",
      "right": "charge que les deux textes partagent"
    }
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
  "word": "non-dit",
  "hint": "charge que les deux textes partagent"
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
      "image_path": "/elearning/mfk-c1-m5/lampe-veille.svg",
      "word": "lampe veille"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/radio-ages.svg",
      "word": "radio ages"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/soleil-lutte.svg",
      "word": "soleil lutte"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/nuage-frontiere.svg",
      "word": "nuage frontiere"
    }
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
    'EL — croiser deux genres ; implicite ; humour sans mépris',
    'EL',
    $c$Objectif
Maîtriser croiser deux genres ; implicite ; humour sans mépris au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — croiser deux genres ; implicite ; humour sans mépris
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on croise, une cour qui n'aurait droit qu'à un seul ton n'est pas un détail.
Mado concède que un genre aide à tenir une forme, pour autant que l'on puisse passer de l'un à l'autre sans trahir le sujet.
Autrement dit, la chronique peut porter un vers, le poème une date : le Seuil n'est pas une anthologie trop sage
Il ressort qu'un diptyque : huit vers, une chronique, un même non-dit
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme diptyque, ici, n'est pas un slogan : deux volets d'un même propos.
Il ne s'agirait que d'un détail, le genre, à entendre ceux qui ont peur du mélange.
Solange se reconnaît dans la chronique, Léa dans le vers.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au ton pour de vrai genre, et Lila Sow demande un registre plus net.
Correction : On va au ton vraiment, et Lila Sow demande un registre plus net.
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
      "left": "diptyque",
      "right": "deux volets d'un même propos"
    },
    {
      "left": "vers",
      "right": "unité du poème"
    },
    {
      "left": "ton",
      "right": "couleur de la voix, pas une cage"
    },
    {
      "left": "non-dit",
      "right": "charge que les deux textes partagent"
    }
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
  "sentence_with_error": "On va au ton pour de vrai genre, et Lila Sow demande un registre plus net.",
  "correct_sentence": "On va au ton vraiment, et Lila Sow demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m5/radio-ages.svg",
      "word": "radio ages"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/soleil-lutte.svg",
      "word": "soleil lutte"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/nuage-frontiere.svg",
      "word": "nuage frontiere"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/feuille-poeme.svg",
      "word": "feuille poeme"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « croiser deux genres ; implicite ; humour sans mépris » et deux pièges commentés."
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

  -- ===== Comparaison de générations =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Comparaison de générations'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Comparaison de générations', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Comparaison de générations',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Comparer deux modes de vie d'âges différents sans couronner l'un des deux. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Comparaison de générations
Lila Sow : Radio Figuier. On parle trop vite de la comparaison Yvette / Sami, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on gagne le débat par la nostalgie, une synthèse qui n'est qu'un vainqueur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Aline Uwase : Ce que l'on nomme comparaison, ici, n'est pas un slogan : mise en regard, sans podium.
Patrick Habimana : Selon Yvette, les soirs étaient plus lents ; d'après Sami, ils étaient plus muets pour certains.
Hawa Diallo : Il ressort que les lanternes pèsent autant.
Joël Mugisha : Alors que l'un veut le silence, l'autre veut le micro, la cour a besoin des deux.
Rose Iradukunda : Aline : à mesure que l'on compare, on découvre les non-dits.
Solange Mukamana : Mado rature mieux avant.
Karim Bamba : Lila lira les deux colonnes.
Félicie Ndayishimiye : Un chiffre, une trace : Patrick a dressé deux colonnes ; six points communs ; zéro vainqueur.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la comparaison serve la cour, pas une hiérarchie d'âges
Yvette : Joël : le fer n'a pas de nostalgie.
Mado : Yvette entend, dans « c'était mieux avant », ceci qui n'est pas dit : c'était mieux avant efface trop souvent qui n'avait pas la parole
Sami : Autrement dit, à mesure que la cour change, comparer n'est pas classer
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une synthèse : deux emplois du temps, deux peurs, un banc commun
Nina Kayitesi : Marc : une synthèse sans vainqueur est déjà un geste politique.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les deux emplois du temps d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une synthèse qui n'est qu'un vainqueur est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une synthèse qui n'est qu'un vainqueur n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Yvette, que reste-t-il implicite dans « c'était mieux avant » ?",
  "options": [
    {
      "text": "Que Patrick a déclaré Sami vainqueur",
      "correct": false
    },
    {
      "text": "Qui n'avait pas la parole",
      "correct": true
    },
    {
      "text": "Que Yvette a interdit les colonnes",
      "correct": false
    },
    {
      "text": "Que les heures calmes n'ont jamais existé",
      "correct": false
    }
  ],
  "explanation": "c'était mieux avant efface trop souvent qui n'avait pas la parole"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "comparaison",
      "right": "mise en regard, sans podium"
    },
    {
      "left": "nostalgie",
      "right": "regret, parfois une arme"
    },
    {
      "left": "synthèse",
      "right": "texte qui retient sans couronner"
    },
    {
      "left": "emploi",
      "right": "temps d'une journée, à croiser"
    }
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
  "word": "comparaison",
  "hint": "mise en regard, sans podium"
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
      "image_path": "/elearning/mfk-c1-m5/soleil-lutte.svg",
      "word": "soleil lutte"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/nuage-frontiere.svg",
      "word": "nuage frontiere"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/feuille-poeme.svg",
      "word": "feuille poeme"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/groupe-voix.svg",
      "word": "groupe voix"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « c'était mieux avant » et la concession de Patrick Habimana."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les deux emplois du temps et la synthèse de Patrick distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Zéro vainqueur',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comparer deux modes de vie d'âges différents sans couronner l'un des deux. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Zéro vainqueur », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Zéro vainqueur
On parle trop vite de la comparaison Yvette / Sami, comme si le mot dispensait d'en examiner le prix.
Encore que l'on gagne le débat par la nostalgie, une synthèse qui n'est qu'un vainqueur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Ce que l'on nomme comparaison, ici, n'est pas un slogan : mise en regard, sans podium.
Selon Yvette, les soirs étaient plus lents ; d'après Sami, ils étaient plus muets pour certains.
Il ressort que les lanternes pèsent autant.
Alors que l'un veut le silence, l'autre veut le micro, la cour a besoin des deux.
Aline : à mesure que l'on compare, on découvre les non-dits.
Mado rature mieux avant.
Lila lira les deux colonnes.
Un chiffre, une trace : Patrick a dressé deux colonnes ; six points communs ; zéro vainqueur.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la comparaison serve la cour, pas une hiérarchie d'âges
Joël : le fer n'a pas de nostalgie.
Yvette entend, dans « c'était mieux avant », ceci qui n'est pas dit : c'était mieux avant efface trop souvent qui n'avait pas la parole
Autrement dit, à mesure que la cour change, comparer n'est pas classer
La proposition qui reste debout est celle-ci : une synthèse : deux emplois du temps, deux peurs, un banc commun
Marc : une synthèse sans vainqueur est déjà un geste politique.
Nous clôturons sans fusionner les voix : les deux emplois du temps d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
Signé : Patrick Habimana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les deux emplois du temps et la synthèse de Patrick en une seule affiche.",
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
      "text": "Deux colonnes, six communs, zéro vainqueur",
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
  "explanation": "Patrick a dressé deux colonnes ; six points communs ; zéro vainqueur."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "comparaison",
      "right": "mise en regard, sans podium"
    },
    {
      "left": "nostalgie",
      "right": "regret, parfois une arme"
    },
    {
      "left": "synthèse",
      "right": "texte qui retient sans couronner"
    },
    {
      "left": "emploi",
      "right": "temps d'une journée, à croiser"
    }
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
  "word": "nostalgie",
  "hint": "regret, parfois une arme"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La comparaison de trop vite n'aide personne, et Yvette reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m5/nuage-frontiere.svg",
      "word": "nuage frontiere"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/feuille-poeme.svg",
      "word": "feuille poeme"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/groupe-voix.svg",
      "word": "groupe voix"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/coeur-monde.svg",
      "word": "coeur monde"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Zéro vainqueur » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Comparaison de générations : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : alors que / tandis que / à mesure que ; synthèse.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on gagne le débat par la nostalgie, une synthèse qui n'est qu'un vainqueur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Ce que l'on nomme comparaison, ici, n'est pas un slogan : mise en regard, sans podium.
Encore que l'on compare, une synthèse qui n'est qu'un vainqueur n'est pas un détail.
Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Autrement dit, à mesure que la cour change, comparer n'est pas classer
Il ressort qu'une synthèse : deux emplois du temps, deux peurs, un banc commun
Il ressort que les lanternes pèsent autant.
Mado rature mieux avant.
La proposition qui reste debout est celle-ci : une synthèse : deux emplois du temps, deux peurs, un banc commun
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les deux emplois du temps d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient."
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
      "text": "certaines heures calmes d'autrefois manquent — à condition que l'on dise aussi ce que les heures calmes cachaient",
      "correct": true
    },
    {
      "text": "Patrick Habimana abandonne il s'agit que la comparaison serve la cour, pas une hiérarchie d'âges",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on dise aussi ce que les heures calmes cachaient"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "comparaison",
      "right": "mise en regard, sans podium"
    },
    {
      "left": "nostalgie",
      "right": "regret, parfois une arme"
    },
    {
      "left": "synthèse",
      "right": "texte qui retient sans couronner"
    },
    {
      "left": "emploi",
      "right": "temps d'une journée, à croiser"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl appert que comparaison n'est pas un slogan.",
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
  "word": "synthèse",
  "hint": "texte qui retient sans couronner"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Patrick Habimana écoute encore, et il fautons comparer avant de crier.",
  "correct_sentence": "Patrick Habimana écoute encore, et il faut comparer avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m5/feuille-poeme.svg",
      "word": "feuille poeme"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/groupe-voix.svg",
      "word": "groupe voix"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/coeur-monde.svg",
      "word": "coeur monde"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/chant-cour.svg",
      "word": "chant cour"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur alors que / tandis que / à mesure que ; synthèse, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les deux emplois du temps et la synthèse de Patrick distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Patrick Habimana',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Comparer deux modes de vie d'âges différents sans couronner l'un des deux. Point : alors que / tandis que / à mesure que ; synthèse.

Consigne
Imitez le texte de Patrick Habimana.

Support — Patrick Habimana — Zéro vainqueur
Patrick Habimana — Zéro vainqueur
On parle trop vite de la comparaison Yvette / Sami, comme si le mot dispensait d'en examiner le prix.
Encore que l'on gagne le débat par la nostalgie, une synthèse qui n'est qu'un vainqueur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Ce que l'on nomme comparaison, ici, n'est pas un slogan : mise en regard, sans podium.
Selon Yvette, les soirs étaient plus lents ; d'après Sami, ils étaient plus muets pour certains.
Mado rature mieux avant.
Lila lira les deux colonnes.
Joël : le fer n'a pas de nostalgie.
La proposition qui reste debout est celle-ci : une synthèse : deux emplois du temps, deux peurs, un banc commun
Marc : une synthèse sans vainqueur est déjà un geste politique.
Nous clôturons sans fusionner les voix : les deux emplois du temps d'un côté, la synthèse de Patrick de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on compare, une synthèse qui n'est qu'un vainqueur n'est pas un détail.
Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
à mesure que la cour change, comparer n'est pas classer
Patrick Habimana, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : une synthèse : deux emplois du temps, deux peurs, un banc commun",
  "correct": true,
  "explanation": "une synthèse : deux emplois du temps, deux peurs, un banc commun"
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
      "text": "une synthèse : deux emplois du temps, deux peurs, un banc commun",
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
  "explanation": "une synthèse : deux emplois du temps, deux peurs, un banc commun"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "comparaison",
      "right": "mise en regard, sans podium"
    },
    {
      "left": "nostalgie",
      "right": "regret, parfois une arme"
    },
    {
      "left": "synthèse",
      "right": "texte qui retient sans couronner"
    },
    {
      "left": "emploi",
      "right": "temps d'une journée, à croiser"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ les deux sources, on ne les fusionne pas. (comparer, subj.)",
  "answer": "compare"
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
    "compare",
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
  "word": "emploi",
  "hint": "temps d'une journée, à croiser"
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
      "image_path": "/elearning/mfk-c1-m5/groupe-voix.svg",
      "word": "groupe voix"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/coeur-monde.svg",
      "word": "coeur monde"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/chant-cour.svg",
      "word": "chant cour"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/verlan-doux.svg",
      "word": "verlan doux"
    }
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
    'EL — alors que / tandis que / à mesure que ; synthèse',
    'EL',
    $c$Objectif
Maîtriser alors que / tandis que / à mesure que ; synthèse au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — alors que / tandis que / à mesure que ; synthèse
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on compare, une synthèse qui n'est qu'un vainqueur n'est pas un détail.
Patrick Habimana concède que certaines heures calmes d'autrefois manquent, pour autant que l'on dise aussi ce que les heures calmes cachaient.
Autrement dit, à mesure que la cour change, comparer n'est pas classer
Il ressort qu'une synthèse : deux emplois du temps, deux peurs, un banc commun
Piège : fusionner les sources au lieu de les attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme comparaison, ici, n'est pas un slogan : mise en regard, sans podium.
Il ressort que les lanternes pèsent autant.
Mado rature mieux avant.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au synthèse pour de vrai genre, et Yvette demande un registre plus net.
Correction : On va au synthèse vraiment, et Yvette demande un registre plus net.
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
      "left": "comparaison",
      "right": "mise en regard, sans podium"
    },
    {
      "left": "nostalgie",
      "right": "regret, parfois une arme"
    },
    {
      "left": "synthèse",
      "right": "texte qui retient sans couronner"
    },
    {
      "left": "emploi",
      "right": "temps d'une journée, à croiser"
    }
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
  "sentence_with_error": "On va au synthèse pour de vrai genre, et Yvette demande un registre plus net.",
  "correct_sentence": "On va au synthèse vraiment, et Yvette demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m5/coeur-monde.svg",
      "word": "coeur monde"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/chant-cour.svg",
      "word": "chant cour"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/verlan-doux.svg",
      "word": "verlan doux"
    },
    {
      "image_path": "/elearning/mfk-c1-m5/clip-invente.svg",
      "word": "clip invente"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « alors que / tandis que / à mesure que ; synthèse » et deux pièges commentés."
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
