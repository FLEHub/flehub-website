/*
  Seed eLearning MFK — B2 — Modèles éducatifs

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b2-m8/
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
  v_module_title text := 'B2 — Modèles éducatifs';
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
      'Grande étape B2-8 : formuler un objectif, commenter des résultats, discuter l''utilité d''un tampon de cour, comparer deux modèles, lire le bilan d''Aline et signer un manifeste — l''Atelier d''Aline et l''école de la cour s''inventent sous le figuier, le Cahier du chemin tient lieu de journal, au Seuil des Sources (Rukiri-Nord).',
      'B2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B2-8 : formuler un objectif, commenter des résultats, discuter l''utilité d''un tampon de cour, comparer deux modèles, lire le bilan d''Aline et signer un manifeste — l''Atelier d''Aline et l''école de la cour s''inventent sous le figuier, le Cahier du chemin tient lieu de journal, au Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'B2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Objectifs et expériences novatrices =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Objectifs et expériences novatrices'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Objectifs et expériences novatrices', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Un atelier qui puisse tenir',
    'CO',
    $c$Objectif
Repérer les relatives de souhait ou de but (qui puisse, afin que) et le subjonctif de l'opinion.

Consigne
Lisez le dialogue. Quels objectifs Aline pose-t-elle, et comment doute-t-elle ?

Support — Atelier d'Aline, pupitre sous le figuier
Aline : Je cherche un atelier qui puisse tenir sans titre d'ailleurs, afin que chacun ose une page.
Patrick : Je ne pense pas que le Cahier du chemin soit un diplôme ; il est essentiel que ce soit un journal.
Léa : Il est essentiel que Joël trouve un relais qui puisse durer trois minutes, afin que l'oreille se repose.
Marc : Je ne pense pas qu'une expérience novatrice consiste à crier plus fort ; elle consiste à oser un geste.
Dieudonné : Un coupon qui puisse se tendre sans se déchirer, afin que l'apprenti voie un geste fini.
Lila : Je ne pense pas que l'antenne remplace l'atelier ; il est essentiel que les deux portes restent ouvertes.
Joël : Aline veut une heure qui puisse se noter, afin que Solange tamponne une feuille lisible.
Rose : Je ne pense pas que l'on apprenne trop vite ; il est essentiel que l'on recommence sans honte.
Hawa : Un banc qui puisse accueillir ceux qui doutent, afin que personne n'idéalise un modèle.
Karim : Il est essentiel que le Bureau des Escales lise la page, encore que le tampon ne fasse pas le geste.
Félicie : Je ne pense pas que le thé soit un détail : c'est une pause qui puisse tenir le groupe.
Mado : J'écrirai un objectif qui puisse se relire demain, afin que le Cahier reste honnête.
Yvette : Aline : relatives de but, qui puisse / afin que ; opinion : je ne pense pas que, il est essentiel que — subjonctif.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick pense que le Cahier du chemin est déjà un diplôme.",
  "correct": false,
  "explanation": "Il ne pense pas que ce soit un diplôme ; c'est un journal."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que cherche Aline, d'après la première réplique ?",
  "options": [
    {
      "text": "Un titre d'ailleurs",
      "correct": false
    },
    {
      "text": "Un atelier qui puisse tenir, afin que chacun ose une page",
      "correct": true
    },
    {
      "text": "Une école lointaine",
      "correct": false
    },
    {
      "text": "Un verdict trop vite signé",
      "correct": false
    }
  ],
  "explanation": "Aline : atelier qui puisse tenir, afin que chacun ose."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui puisse",
      "right": "relative de but"
    },
    {
      "left": "afin que",
      "right": "but + subjonctif"
    },
    {
      "left": "je ne pense pas que",
      "right": "opinion + subj."
    },
    {
      "left": "il est essentiel que",
      "right": "nécessité + subj."
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe cherche un atelier ___ puisse tenir sans titre d'ailleurs.",
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
    "Il",
    "est",
    "essentiel",
    "que",
    "ce",
    "soit",
    "un",
    "journal",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "puisse",
  "hint": "Subjonctif de pouvoir, dans une relative de but : un atelier qui…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ne pense pas que le Cahier est un diplôme, et il est essentiel que ce soit un journal.",
  "correct_sentence": "Je ne pense pas que le Cahier soit un diplôme, et il est essentiel que ce soit un journal.",
  "explanation": "Je ne pense pas que + subjonctif : soit, pas est."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/objectif-relatif.svg",
      "word": "un objectif"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/subjonctif-opinion.svg",
      "word": "un subjonctif"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/atelier-aline.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/cahier-eleve.svg",
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
  "prompt": "Notez quatre relatives (qui puisse / afin que) et quatre opinions au subjonctif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Un atelier qui puisse tenir. Afin que chacun ose. Je ne pense pas que ce soit un diplôme. Il est essentiel que les portes restent ouvertes."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Objectifs de l''Atelier d''Aline',
    'CE',
    $c$Objectif
Lire une page d'objectifs qui enchaîne relatives de but et subjonctif d'opinion.

Consigne
Lisez la page, sans aller trop vite.

Support — Page d'Aline Uwase, Atelier d'Aline
Objectifs — Atelier d'Aline, saison sèche
Je cherche un atelier qui puisse tenir sous le figuier, afin que personne n'emprunte un modèle d'ailleurs.
Je ne pense pas que le Cahier du chemin soit un diplôme ; il est essentiel que ce soit un journal de gestes tenus.
Léa veut un relais qui puisse durer trois minutes, afin que l'oreille de Joël se repose.
Dieudonné demande un coupon qui puisse se tendre sans se déchirer, afin que l'apprenti voie un geste fini.
Je ne pense pas qu'une expérience novatrice consiste à crier plus fort ; il est essentiel qu'elle ose un geste simple.
Lila écrit qu'il est essentiel que les deux portes restent ouvertes, afin que Patrick compare sans trahir.
Karim rappelle qu'un tampon qui puisse se lire ne fait pas le geste ; Solange en convient.
Hawa souhaite un banc qui puisse accueillir ceux qui doutent, afin que l'on n'idéalise pas trop vite.
Rose : je ne pense pas que l'on apprenne sans recommencer ; il est essentiel que la honte reste dehors.
Mado notera un objectif qui puisse se relire demain, afin que la page reste honnête.
Félicie : une pause qui puisse tenir le groupe n'est pas un détail.
Yvette : ces lignes n'inventent pas une école lointaine ; elles tiennent l'Atelier d'Aline.
Aline Uwase — Seuil des Sources, Rukiri-Nord
Copie au Cahier du chemin
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline présente le Cahier du chemin comme un diplôme officiel.",
  "correct": false,
  "explanation": "Elle ne pense pas que ce soit un diplôme ; c'est un journal."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que veut Léa, d'après la page ?",
  "options": [
    {
      "text": "Un relais sans fin",
      "correct": false
    },
    {
      "text": "Un relais qui puisse durer trois minutes",
      "correct": true
    },
    {
      "text": "Fermer l'atelier",
      "correct": false
    },
    {
      "text": "Un titre d'ailleurs",
      "correct": false
    }
  ],
  "explanation": "« un relais qui puisse durer trois minutes. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "atelier qui puisse",
      "right": "tenir sous le figuier"
    },
    {
      "left": "afin que",
      "right": "personne n'emprunte"
    },
    {
      "left": "je ne pense pas que",
      "right": "le Cahier soit un diplôme"
    },
    {
      "left": "il est essentiel que",
      "right": "les portes restent ouvertes"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl est essentiel que ce ___ un journal. (être, subj.)",
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
    "Afin",
    "que",
    "chacun",
    "ose",
    "une",
    "page",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "essentiel",
  "hint": "Il est… que : nécessité d'opinion, suivie du subjonctif."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est essentiel que les portes restent ouvertes, et je ne pense pas que l'on apprend trop vite.",
  "correct_sentence": "Il est essentiel que les portes restent ouvertes, et je ne pense pas que l'on apprenne trop vite.",
  "explanation": "Je ne pense pas que + subjonctif : apprenne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/subjonctif-opinion.svg",
      "word": "un subjonctif"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/atelier-aline.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/cahier-eleve.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/expliquer-resultat.svg",
      "word": "un résultat"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la page et encadrez qui puisse, afin que, je ne pense pas que, il est essentiel que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la page d'objectifs, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire qui puisse, je ne pense pas que',
    'PO',
    $c$Objectif
Formuler à l'oral un objectif (relative de but) et une opinion au subjonctif.

Consigne
Répétez, puis posez un objectif pour l'Atelier d'Aline et une opinion nuancée.

Support — Modèles d'Aline et de Patrick
Je cherche un atelier qui puisse tenir.
Afin que chacun ose une page.
Je ne pense pas que ce soit un diplôme.
Il est essentiel que ce soit un journal.
Un relais qui puisse durer trois minutes.
Afin que l'oreille se repose.
Je ne pense pas que l'on crie plus fort.
Il est essentiel que les deux portes restent ouvertes.
Un banc qui puisse accueillir ceux qui doutent.
Afin que personne n'idéalise.
Je ne pense pas que l'on apprenne sans recommencer.
Il est essentiel que la honte reste dehors.
Aline : le subjonctif porte le souhait et le doute.
Léa : un objectif se dit sans titre d'ailleurs.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Après « je ne pense pas que » et « il est essentiel que », on met le subjonctif.",
  "correct": true,
  "explanation": "Les modèles le montrent."
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
      "text": "Je ne pense pas que c'est un diplôme",
      "correct": false
    },
    {
      "text": "Je ne pense pas que ce soit un diplôme",
      "correct": true
    },
    {
      "text": "Il est essentiel que c'est un journal",
      "correct": false
    },
    {
      "text": "Un atelier qui peut afin que on ose",
      "correct": false
    }
  ],
  "explanation": "Je ne pense pas que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui puisse",
      "right": "but dans la relative"
    },
    {
      "left": "afin que",
      "right": "but + subj."
    },
    {
      "left": "je ne pense pas que",
      "right": "doute"
    },
    {
      "left": "il est essentiel que",
      "right": "nécessité"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ne pense pas que l'on ___ trop vite. (apprendre, subj.)",
  "answer": "apprenne"
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
    "atelier",
    "qui",
    "puisse",
    "tenir",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "objectif",
  "hint": "Ce que l'Atelier d'Aline vise : un geste, une page, pas un titre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je cherche un atelier qui peut tenir sans titre, et afin que chacun ose une page.",
  "correct_sentence": "Je cherche un atelier qui puisse tenir sans titre, et afin que chacun ose une page.",
  "explanation": "Relative de but : qui puisse, pas qui peut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/atelier-aline.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/cahier-eleve.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/expliquer-resultat.svg",
      "word": "un résultat"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/graphique-notes.svg",
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
  "prompt": "Écrivez huit phrases : deux qui puisse, deux afin que, deux je ne pense pas que, deux il est essentiel que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis un objectif et une opinion à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mes objectifs d''atelier',
    'PE',
    $c$Objectif
Écrire une page d'objectifs avec relatives de but et subjonctif d'opinion.

Consigne
Imitez la page de Patrick Habimana, sans aller trop vite.

Support — Page de Patrick Habimana
Patrick Habimana — objectifs pour l'Atelier d'Aline
Je cherche un matin qui puisse tenir à l'atelier, afin que je voie un coupon fini avant le thé.
Je ne pense pas que le Cahier du chemin soit un diplôme ; il est essentiel que j'y note les gestes, même fragiles.
Léa veut un relais qui puisse durer trois minutes, afin que Joël apprenne à couper sans honte.
Je ne pense pas qu'il faille crier plus fort pour innover ; il est essentiel qu'on ose un geste simple.
Dieudonné demande un fil qui puisse se tendre, afin que l'apprenti-tissu voie la fin du sac.
Lila écrit qu'il est essentiel que les deux portes restent ouvertes, afin que je compare sans trahir.
Hawa souhaite un banc qui puisse accueillir mon doute, afin que je n'idéalise ni l'atelier ni l'antenne.
Rose : je ne pense pas que l'on apprenne trop vite ; il est essentiel que je recommence.
Mado notera cette page, afin qu'elle puisse se relire demain.
Aline, je vous la tends : ce n'est pas un titre d'ailleurs, c'est un objectif de cour.
Patrick
Seuil des Sources — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick écrit qu'il faut crier plus fort pour innover.",
  "correct": false,
  "explanation": "Il ne pense pas qu'il faille crier plus fort."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que Patrick ne pense-t-il pas que le Cahier soit ?",
  "options": [
    {
      "text": "Un journal",
      "correct": false
    },
    {
      "text": "Un diplôme",
      "correct": true
    },
    {
      "text": "Une page",
      "correct": false
    },
    {
      "text": "Un banc",
      "correct": false
    }
  ],
  "explanation": "« Je ne pense pas que le Cahier du chemin soit un diplôme. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "un matin qui puisse",
      "right": "tenir à l'atelier"
    },
    {
      "left": "afin que",
      "right": "je voie un coupon fini"
    },
    {
      "left": "je ne pense pas que",
      "right": "ce soit un diplôme"
    },
    {
      "left": "il est essentiel que",
      "right": "j'y note les gestes"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ne pense pas qu'il ___ crier plus fort. (falloir, subj.)",
  "answer": "faille"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Afin",
    "que",
    "je",
    "compare",
    "sans",
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
  "word": "pense",
  "hint": "Je ne… pas que : opinion négative, puis le subjonctif."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est essentiel que j'y note les gestes, et je ne pense pas que le Cahier est un diplôme.",
  "correct_sentence": "Il est essentiel que j'y note les gestes, et je ne pense pas que le Cahier soit un diplôme.",
  "explanation": "Je ne pense pas que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/cahier-eleve.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/expliquer-resultat.svg",
      "word": "un résultat"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/graphique-notes.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/commentaire.svg",
      "word": "un commentaire"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : douze à quinze lignes, trois qui puisse / afin que, deux je ne pense pas que, deux il est essentiel que."
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
    'EL — Relatives de but et subjonctif d''opinion',
    'EL',
    $c$Objectif
Retenir qui puisse, afin que, je ne pense pas que, il est essentiel que.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, souhait et opinion
Relative de but : un atelier qui puisse tenir ; un relais qui puisse durer ; un banc qui puisse accueillir.
Afin que + subjonctif : afin que chacun ose, afin que l'oreille se repose, afin que la page reste honnête.
Je ne pense pas que + subjonctif : je ne pense pas que ce soit un diplôme ; je ne pense pas que l'on apprenne trop vite.
Il est essentiel que + subjonctif : il est essentiel que ce soit un journal ; il est essentiel que les portes restent ouvertes.
Je pense que + indicatif (opinion positive) ≠ je ne pense pas que + subjonctif.
Il faut que + subjonctif : il faut que tu notes ; il n'est pas correct d'écrire je faut.
Qui puisse = subjonctif de pouvoir (but, souhait), pas qui peut (simple fait).
On n'emprunte pas un nom d'école d'ailleurs. On dit Atelier d'Aline, Cahier du chemin, école de la cour.
Attention : soit / apprenne / faille / restent / ose.
À + le = au Cahier, à l'atelier. De + le = du figuier.
Un objectif se dit ; il ne se crie pas.
On vise un geste de cour, non un titre emprunté.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Après « je pense que », on met en général l'indicatif ; après « je ne pense pas que », le subjonctif.",
  "correct": true,
  "explanation": "Opposition rappelée dans la fiche."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Un atelier qui puisse tenir » emploie puisse parce que…",
  "options": [
    {
      "text": "c'est un simple fait déjà vrai",
      "correct": false
    },
    {
      "text": "c'est un but / un souhait dans la relative",
      "correct": true
    },
    {
      "text": "c'est un passé composé",
      "correct": false
    },
    {
      "text": "c'est une litote",
      "correct": false
    }
  ],
  "explanation": "Relative de but."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui puisse",
      "right": "relative de but"
    },
    {
      "left": "afin que",
      "right": "but"
    },
    {
      "left": "je ne pense pas que",
      "right": "subj."
    },
    {
      "left": "je pense que",
      "right": "indicatif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAfin que chacun ___ une page. (oser, subj.)",
  "answer": "ose"
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
    "essentiel",
    "que",
    "les",
    "portes",
    "restent",
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
  "word": "relative",
  "hint": "Une… de but : un atelier qui puisse tenir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je pense pas que ce soit un diplôme, et il est essentiel que ce soit un journal.",
  "correct_sentence": "Je ne pense pas que ce soit un diplôme, et il est essentiel que ce soit un journal.",
  "explanation": "Négation : je ne pense pas, avec ne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/expliquer-resultat.svg",
      "word": "un résultat"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/graphique-notes.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/commentaire.svg",
      "word": "un commentaire"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/loupe-chiffre.svg",
      "word": "une loupe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez six phrases : trois relatives de but, trois opinions au subjonctif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six phrases, une par formule."
}$j$::jsonb,
    9
  );

  -- ===== Expliquer et commenter des résultats =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Expliquer et commenter des résultats'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Expliquer et commenter des résultats', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Chiffres sous le figuier',
    'CO',
    $c$Objectif
Comprendre et commenter des résultats inventés de l'Atelier d'Aline.

Consigne
Lisez le dialogue. Quels chiffres entend-on, et comment les commente-t-on ?

Support — Atelier d'Aline, graphique ocre
Aline : Vingt-quatre apprenants se sont inscrits au Cahier du chemin, cette saison sèche.
Patrick : Dix-huit ont tenu au moins huit pages : cela montre que le journal tient, pour trois sur quatre.
Léa : Douze ont osé un relais de trois minutes, soit la moitié ; on constate que l'oreille s'ouvre, sans crier.
Marc : Neuf ont mesuré un coupon à l'atelier : ces chiffres indiquent qu'un geste de main reste plus rare qu'une page.
Dieudonné : Six ont tenu l'antenne un jeudi, un quart seulement ; cela n'empêche pas de continuer.
Lila : Trois ont demandé un second essai ; ces chiffres montrent qu'on ose recommencer, et c'est déjà beaucoup.
Joël : Deux n'ont pas ouvert le cahier ; je ne pense pas que ce soit un échec, encore qu'il faille les relancer.
Rose : Zéro n'est parti sans mot : il est essentiel que l'on commente cela, afin que personne n'idéalise le silence.
Hawa : Dix-huit sur vingt-quatre, c'est soixante-quinze pour cent ; on peut toutefois noter que six pages manquent encore.
Karim : Ces résultats n'inventent pas une école d'ailleurs ; ils commentent l'Atelier d'Aline.
Solange : Un tampon sur une feuille lisible n'ajoute rien si le chiffre n'est pas compris.
Félicie : On constate que le thé a tenu le groupe : ce n'est pas un chiffre, c'est une pause.
Mado : J'écrirai : cela montre que, on constate que, ces chiffres indiquent que — sans enfler.
Aline : Commenter, ce n'est pas juger trop vite ; c'est relier un nombre à un geste.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dix-huit apprenants sur vingt-quatre ont tenu au moins huit pages.",
  "correct": true,
  "explanation": "Patrick : trois sur quatre."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que montrent les trois seconds essais, selon Lila ?",
  "options": [
    {
      "text": "Que tout le monde a réussi du premier coup",
      "correct": false
    },
    {
      "text": "Qu'on ose recommencer",
      "correct": true
    },
    {
      "text": "Que l'atelier ferme",
      "correct": false
    },
    {
      "text": "Qu'il faut un titre d'ailleurs",
      "correct": false
    }
  ],
  "explanation": "Lila : on ose recommencer."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "18 / 24",
      "right": "huit pages / 75 %"
    },
    {
      "left": "12 / 24",
      "right": "relais / la moitié"
    },
    {
      "left": "9 / 24",
      "right": "coupon mesuré"
    },
    {
      "left": "6 / 24",
      "right": "antenne un jeudi"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCela ___ que le journal tient, pour trois sur quatre.",
  "answer": "montre"
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
    "constate",
    "que",
    "l'oreille",
    "s'ouvre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "chiffres",
  "hint": "Nombres de l'Atelier d'Aline : pages, relais, coupons, jeudis."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ces chiffres indiquent que un geste de main reste plus rare, et la moitié a osé le relais.",
  "correct_sentence": "Ces chiffres indiquent qu'un geste de main reste plus rare, et la moitié a osé le relais.",
  "explanation": "Que + un s'élide : qu'un."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/graphique-notes.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/commentaire.svg",
      "word": "un commentaire"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/loupe-chiffre.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/diplome-probabilite.svg",
      "word": "un diplôme"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez six chiffres et, pour chacun, la formule de commentaire entendue."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Vingt-quatre inscrits. Dix-huit pages tenues. Cela montre que. On constate que. Ces chiffres indiquent que."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Bulletin de l''Atelier d''Aline',
    'CE',
    $c$Objectif
Lire un bulletin qui explique et commente des résultats inventés.

Consigne
Lisez le bulletin, sans aller trop vite.

Support — Bulletin d'Aline Uwase
Bulletin — Atelier d'Aline, saison sèche (chiffres inventés)
Vingt-quatre apprenants se sont inscrits au Cahier du chemin.
Dix-huit ont tenu au moins huit pages, soit trois sur quatre : cela montre que le journal tient.
Douze ont osé un relais de trois minutes, la moitié : on constate que l'oreille s'ouvre, encore que le silence coûte.
Neuf ont mesuré un coupon à l'atelier : ces chiffres indiquent qu'un geste de main reste plus rare qu'une page.
Six ont tenu l'antenne un jeudi, un quart : cela n'empêche pas de continuer, afin que le jeudi reste une porte.
Trois ont demandé un second essai : ces résultats montrent qu'on ose recommencer, et c'est déjà beaucoup.
Deux n'ont pas ouvert le cahier ; je ne pense pas que ce soit un échec, encore qu'il faille les relancer.
Zéro n'est parti sans mot : il est essentiel que l'on commente ce silence, afin que personne ne l'idéalise.
Hawa note : dix-huit sur vingt-quatre, soixante-quinze pour cent ; on peut toutefois rappeler que six pages manquent.
Karim : ces chiffres n'appartiennent à aucune école d'ailleurs ; ils commentent la cour.
Solange : un tampon n'explique rien si le nombre n'est pas lu.
Mado recopiera ce bulletin au Cahier du chemin, afin qu'il puisse se relire.
Commenter, ce n'est pas juger trop vite : c'est relier un nombre à un geste du Seuil.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Deux apprenants n'ont pas ouvert le cahier, et Aline y voit déjà un échec définitif.",
  "correct": false,
  "explanation": "Elle ne pense pas que ce soit un échec."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien ont mesuré un coupon à l'atelier ?",
  "options": [
    {
      "text": "Vingt-quatre",
      "correct": false
    },
    {
      "text": "Dix-huit",
      "correct": false
    },
    {
      "text": "Neuf",
      "correct": true
    },
    {
      "text": "Trois",
      "correct": false
    }
  ],
  "explanation": "« Neuf ont mesuré un coupon. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cela montre que",
      "right": "le journal tient"
    },
    {
      "left": "on constate que",
      "right": "l'oreille s'ouvre"
    },
    {
      "left": "ces chiffres indiquent",
      "right": "geste de main plus rare"
    },
    {
      "left": "ces résultats montrent",
      "right": "on ose recommencer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ___ que l'oreille s'ouvre, encore que le silence coûte.",
  "answer": "constate"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Cela",
    "montre",
    "que",
    "le",
    "journal",
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
  "word": "resultat",
  "hint": "Ce que le bulletin commente, sans enfler. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ces chiffres indiquent que le geste reste rare, et on constate l'oreille s'ouvre trop vite.",
  "correct_sentence": "Ces chiffres indiquent que le geste reste rare, et on constate que l'oreille s'ouvre trop vite.",
  "explanation": "On constate que + phrase."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/commentaire.svg",
      "word": "un commentaire"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/loupe-chiffre.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/diplome-probabilite.svg",
      "word": "un diplôme"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/subjonctif-probable.svg",
      "word": "une probabilité"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le bulletin et soulignez toutes les formules de commentaire ; recopiez les huit chiffres."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le bulletin, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire cela montre que',
    'PO',
    $c$Objectif
Commenter à l'oral un chiffre de l'Atelier d'Aline.

Consigne
Répétez, puis commentez deux chiffres : un qui rassure, un qui reste fragile.

Support — Modèles d'Aline et de Hawa
Vingt-quatre se sont inscrits.
Dix-huit ont tenu huit pages.
Cela montre que le journal tient.
On constate que l'oreille s'ouvre.
Ces chiffres indiquent qu'un geste de main reste rare.
Ces résultats montrent qu'on ose recommencer.
La moitié a osé le relais.
Un quart a tenu l'antenne.
Je ne pense pas que deux silences soient un échec.
Il est essentiel que l'on relance.
On peut toutefois noter que six pages manquent.
Commenter n'est pas juger trop vite.
Relier un nombre à un geste.
Aline : sans enfler, sans idéaliser.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Commenter un chiffre, c'est le relier à un geste, non le juger trop vite.",
  "correct": true,
  "explanation": "Aline le rappelle."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle formule introduit un commentaire de résultat ?",
  "options": [
    {
      "text": "Je faut que",
      "correct": false
    },
    {
      "text": "Cela montre que",
      "correct": true
    },
    {
      "text": "Bonjour seulement",
      "correct": false
    },
    {
      "text": "Un titre d'ailleurs",
      "correct": false
    }
  ],
  "explanation": "Cela montre que."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cela montre que",
      "right": "le journal tient"
    },
    {
      "left": "on constate que",
      "right": "l'oreille s'ouvre"
    },
    {
      "left": "ces chiffres indiquent",
      "right": "geste rare"
    },
    {
      "left": "un quart",
      "right": "antenne un jeudi"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCes chiffres ___ qu'un geste de main reste rare. (indiquer, présent)",
  "answer": "indiquent"
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
    "moitié",
    "a",
    "osé",
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
  "word": "commente",
  "hint": "On… un nombre : on le relie à un geste, on ne l'enfle pas."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Cela montre le journal tient déjà, et on constate que l'oreille s'ouvre.",
  "correct_sentence": "Cela montre que le journal tient déjà, et on constate que l'oreille s'ouvre.",
  "explanation": "Cela montre que + phrase."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/loupe-chiffre.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/diplome-probabilite.svg",
      "word": "un diplôme"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/subjonctif-probable.svg",
      "word": "une probabilité"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/question-utilite.svg",
      "word": "une question"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit commentaires : deux par formule (montre, constate, indiquent, résultats montrent)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis deux commentaires à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon commentaire de résultats',
    'PE',
    $c$Objectif
Écrire un commentaire argumenté des chiffres de l'Atelier d'Aline.

Consigne
Imitez le commentaire de Marc Nkurunziza, sans aller trop vite.

Support — Commentaire de Marc Nkurunziza
Marc Nkurunziza — lire les chiffres sans les enfler
Vingt-quatre inscrits au Cahier du chemin : cela montre que l'Atelier d'Aline attire, encore que deux n'aient pas ouvert la page.
Dix-huit ont tenu huit pages, trois sur quatre : on constate que le journal tient, et il est essentiel que les six autres soient relancés.
Douze ont osé le relais, la moitié : ces chiffres indiquent que l'oreille s'ouvre, sans nier que le silence coûte.
Neuf ont mesuré un coupon : je ne pense pas que ce soit peu ; un geste de main demande plus de temps qu'une phrase.
Six jeudis tenus, un quart : on peut toutefois continuer, afin que la porte de Lila reste une porte.
Trois seconds essais : ces résultats montrent qu'on ose recommencer, et c'est déjà beaucoup.
Zéro n'est parti sans mot : il est essentiel que l'on commente ce silence, afin que personne ne l'idéalise.
Ces nombres n'appartiennent à aucune école d'ailleurs ; ils commentent la cour.
Solange : un tampon n'explique rien si le chiffre n'est pas lu.
Je tends cette page à Aline, afin qu'elle puisse la relire au pupitre.
Marc
Cahier du chemin — Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc juge que neuf coupons mesurés, c'est forcément trop peu pour continuer.",
  "correct": false,
  "explanation": "Il ne pense pas que ce soit peu."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que montrent les trois seconds essais, selon Marc ?",
  "options": [
    {
      "text": "Un échec définitif",
      "correct": false
    },
    {
      "text": "Qu'on ose recommencer",
      "correct": true
    },
    {
      "text": "La fermeture de l'atelier",
      "correct": false
    },
    {
      "text": "Un titre d'ailleurs",
      "correct": false
    }
  ],
  "explanation": "« on ose recommencer. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cela montre que",
      "right": "l'atelier attire"
    },
    {
      "left": "on constate que",
      "right": "le journal tient"
    },
    {
      "left": "ces chiffres indiquent",
      "right": "l'oreille s'ouvre"
    },
    {
      "left": "ces résultats montrent",
      "right": "on ose recommencer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl est essentiel que l'on ___ ce silence. (commenter, subj.)",
  "answer": "commente"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Commenter",
    "n'est",
    "pas",
    "juger",
    "trop",
    "vite",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "indique",
  "hint": "Ces chiffres… que : un verbe pour relier le nombre au geste."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ces résultats montrent qu'on ose recommencer, et je ne pense pas que neuf coupons est trop peu.",
  "correct_sentence": "Ces résultats montrent qu'on ose recommencer, et je ne pense pas que neuf coupons soient trop peu.",
  "explanation": "Je ne pense pas que + subjonctif : soient."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/diplome-probabilite.svg",
      "word": "un diplôme"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/subjonctif-probable.svg",
      "word": "une probabilité"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/question-utilite.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/tampon-diplome.svg",
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
  "prompt": "Imitez : quinze lignes, les huit chiffres, quatre formules de commentaire, une opinion au subjonctif."
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
    'EL — Commenter un chiffre',
    'EL',
    $c$Objectif
Retenir les formules qui expliquent un résultat sans l'enfler.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, résultats
Formules : cela montre que ; on constate que ; ces chiffres indiquent que ; ces résultats montrent que.
Fractions inventées de l'Atelier d'Aline : 18/24 = 3/4 = 75 % ; 12/24 = 1/2 ; 6/24 = 1/4.
On relie le nombre à un geste : pages tenues, relais osé, coupon mesuré, jeudi tenu, second essai.
On n'enfle pas. On n'idéalise pas le silence. Zéro départ sans mot se commente, il ne se célèbre pas trop vite.
Je ne pense pas que deux cahiers fermés soient un échec. Il est essentiel que l'on relance.
Encore qu'il faille relancer, on peut toutefois continuer.
Élision : qu'un geste, qu'on ose, qu'elle puisse.
Cela montre que + phrase (pas : cela montre le journal tient).
On constate que + phrase (pas : on constate l'oreille s'ouvre, sans que).
Ces chiffres n'appartiennent à aucune école d'ailleurs.
Attention : indiquent (ils), montre (cela). Accord du verbe avec le sujet.
Commenter un nombre, c'est le relier à un geste du Seuil.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « cela montre le journal tient » sans que.",
  "correct": false,
  "explanation": "Cela montre que + phrase."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "18 sur 24, dans le bulletin, égale…",
  "options": [
    {
      "text": "un quart",
      "correct": false
    },
    {
      "text": "trois sur quatre",
      "correct": true
    },
    {
      "text": "la moitié",
      "correct": false
    },
    {
      "text": "zéro",
      "correct": false
    }
  ],
  "explanation": "Trois sur quatre, soixante-quinze pour cent."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cela montre que",
      "right": "commentaire"
    },
    {
      "left": "18 / 24",
      "right": "trois sur quatre"
    },
    {
      "left": "12 / 24",
      "right": "la moitié"
    },
    {
      "left": "6 / 24",
      "right": "un quart"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCes chiffres ___ qu'un geste de main reste rare. (indiquer)",
  "answer": "indiquent"
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
    "n'enfle",
    "pas",
    "les",
    "nombres",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pourcent",
  "hint": "Dix-huit sur vingt-quatre : soixante-quinze… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Cela montrent que le journal tient, et on constate que l'oreille s'ouvre.",
  "correct_sentence": "Cela montre que le journal tient, et on constate que l'oreille s'ouvre.",
  "explanation": "Cela : verbe au singulier, montre."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/subjonctif-probable.svg",
      "word": "une probabilité"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/question-utilite.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/tampon-diplome.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/initiative-educ.svg",
      "word": "une initiative"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez un tableau : chiffre, fraction, formule de commentaire, geste relié."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et quatre commentaires, un par formule."
}$j$::jsonb,
    9
  );

  -- ===== L'utilité des diplômes =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'L''utilité des diplômes'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'L''utilité des diplômes', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Tampon ou geste ?',
    'CO',
    $c$Objectif
Repérer le subjonctif de probabilité (il est peu probable que, il se peut que, il n'est pas sûr que).

Consigne
Lisez le dialogue. Le tampon de cour est-il utile, et qui en doute ?

Support — Bureau des Escales / banc du figuier
Aline : Solange propose un tampon de cour, une feuille de tenue. Est-ce utile ?
Patrick : Il est peu probable que ce tampon remplace un geste tenu ; il se peut toutefois qu'il rassure.
Léa : Il n'est pas sûr que tout le monde en ait besoin ; Joël, lui, demande encore la page.
Marc : Il se peut que la feuille de tenue aide Karim à lire ; il est peu probable qu'elle fasse le coupon.
Dieudonné : Je ne pense pas qu'un tampon couse mieux qu'une main ; il n'est pas sûr qu'on doive le refuser.
Lila : Il est peu probable que Radio Figuier exige un titre d'ailleurs ; il se peut qu'une heure tenue suffise.
Joël : Il n'est pas sûr que je comprenne l'utilité demain ; il se peut que je la voie après trois relais.
Rose : Il est peu probable que l'on apprenne pour le tampon ; on apprend pour le geste, afin que le sac tienne.
Hawa : Il se peut que le Cahier du chemin vaille mieux qu'une feuille trop vite tamponnée.
Karim : Sans nier que le tampon compte au Bureau, il n'est pas sûr qu'il compte sous le figuier.
Solange : Je tamponnerai ce qui est lisible ; il est peu probable que je tamponne une rumeur.
Félicie : Il se peut que le thé discute mieux l'utilité qu'un long discours.
Mado : J'écrirai ces doutes, afin qu'ils puissent se relire : il n'est pas sûr, il se peut, il est peu probable.
Aline : Probabilité faible ou doute : subjonctif. On n'emprunte aucun diplôme d'ailleurs.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline rappelle qu'on n'emprunte aucun diplôme d'ailleurs.",
  "correct": true,
  "explanation": "Dernière réplique."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que Patrick dit-il qu'il est peu probable ?",
  "options": [
    {
      "text": "Que le thé soit versé",
      "correct": false
    },
    {
      "text": "Que le tampon remplace un geste tenu",
      "correct": true
    },
    {
      "text": "Que Solange sache lire",
      "correct": false
    },
    {
      "text": "Que le figuier tombe",
      "correct": false
    }
  ],
  "explanation": "« Il est peu probable que ce tampon remplace un geste tenu. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il est peu probable que",
      "right": "le tampon remplace le geste"
    },
    {
      "left": "il se peut que",
      "right": "la feuille rassure / aide"
    },
    {
      "left": "il n'est pas sûr que",
      "right": "tout le monde en ait besoin"
    },
    {
      "left": "Cahier du chemin",
      "right": "vaut mieux parfois"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl est peu probable que ce tampon ___ un geste. (remplacer, subj.)",
  "answer": "remplace"
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
    "se",
    "peut",
    "que",
    "la",
    "feuille",
    "rassure",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "probable",
  "hint": "Il est peu… que : doute fort, puis le subjonctif."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est peu probable que le tampon remplacera le geste, et il se peut que la feuille rassure.",
  "correct_sentence": "Il est peu probable que le tampon remplace le geste, et il se peut que la feuille rassure.",
  "explanation": "Il est peu probable que + subjonctif : remplace, pas le futur."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/question-utilite.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/tampon-diplome.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/initiative-educ.svg",
      "word": "une initiative"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/negation-ni.svg",
      "word": "une négation"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez six phrases de probabilité et ce qu'elles disent du tampon, de la feuille ou du Cahier."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il est peu probable que le tampon remplace le geste. Il se peut que la feuille rassure. Il n'est pas sûr que tout le monde en ait besoin."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Débat sur le tampon de cour',
    'CE',
    $c$Objectif
Lire un débat argumenté sur l'utilité d'un tampon inventé, sans diplôme d'ailleurs.

Consigne
Lisez le débat, sans aller trop vite.

Support — Débat noté par Mado
Débat — utilité du tampon de cour (feuille de tenue)
Aline ouvre : Solange propose un tampon de cour. Nous n'empruntons aucun diplôme d'ailleurs.
Patrick : il est peu probable que ce tampon remplace un geste tenu ; il se peut toutefois qu'il rassure ceux qui doutent.
Léa : il n'est pas sûr que Joël en ait besoin demain ; il se peut qu'une heure tenue suffise à Lila.
Marc : ces chiffres de l'atelier indiquent que neuf coupons valent déjà plus qu'une feuille trop vite tamponnée.
Dieudonné : je ne pense pas qu'un tampon couse ; il n'est pas sûr qu'on doive pourtant le refuser.
Lila : il est peu probable que l'antenne exige un titre ; il se peut qu'un relais de trois minutes parle assez.
Karim, sans nier que le Bureau aime une page lisible, doute qu'elle compte autant sous le figuier.
Solange : je tamponnerai ce qui est lisible ; il est peu probable que je tamponne une rumeur.
Hawa : il se peut que le Cahier du chemin vaille mieux ; il n'est pas sûr que le tampon soit inutile pour autant.
Rose : on apprend pour le geste, afin que le sac tienne, non pour l'encre du Bureau.
Félicie : il se peut que le thé discute mieux l'utilité qu'un verdict trop net.
Yvette : il est essentiel que l'on doute ici, afin que personne n'idéalise un tampon.
Conclusion provisoire : le tampon peut accompagner ; il est peu probable qu'il remplace. Le Cahier reste le journal.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La conclusion dit qu'il est peu probable que le tampon remplace le geste.",
  "correct": true,
  "explanation": "« il peut accompagner ; il est peu probable qu'il remplace. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que tamponnera Solange, d'après le débat ?",
  "options": [
    {
      "text": "Une rumeur",
      "correct": false
    },
    {
      "text": "Ce qui est lisible",
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
  "explanation": "« je tamponnerai ce qui est lisible. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "peu probable que",
      "right": "remplace le geste"
    },
    {
      "left": "il se peut que",
      "right": "rassure / suffise / vaille"
    },
    {
      "left": "il n'est pas sûr que",
      "right": "Joël en ait besoin"
    },
    {
      "left": "Cahier du chemin",
      "right": "journal, pas diplôme"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl n'est pas sûr que Joël en ___ besoin. (avoir, subj.)",
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
    "Le",
    "Cahier",
    "reste",
    "le",
    "journal",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "diplome",
  "hint": "Mot qu'on n'emprunte pas ailleurs : ici on dit tampon de cour. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il se peut que la feuille rassure, et il n'est pas sûr que tout le monde a besoin du tampon.",
  "correct_sentence": "Il se peut que la feuille rassure, et il n'est pas sûr que tout le monde ait besoin du tampon.",
  "explanation": "Il n'est pas sûr que + subjonctif : ait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/tampon-diplome.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/initiative-educ.svg",
      "word": "une initiative"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/negation-ni.svg",
      "word": "une négation"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/difference-modele.svg",
      "word": "une différence"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le débat et encadrez peu probable / il se peut / il n'est pas sûr ; indiquez le verbe au subjonctif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le débat, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire il se peut, il n''est pas sûr',
    'PO',
    $c$Objectif
Exprimer à l'oral une probabilité ou un doute sur l'utilité d'un tampon de cour.

Consigne
Répétez, puis doutez à voix haute : tampon, feuille, Cahier.

Support — Modèles d'Aline et de Solange
Il est peu probable que le tampon remplace le geste.
Il se peut que la feuille rassure.
Il n'est pas sûr que tout le monde en ait besoin.
Il se peut qu'une heure tenue suffise.
Il est peu probable que l'antenne exige un titre.
Il n'est pas sûr qu'on doive refuser le tampon.
Il se peut que le Cahier vaille mieux.
Il est peu probable que je tamponne une rumeur.
On apprend pour le geste, non pour l'encre.
Le tampon peut accompagner, rarement remplacer.
Je ne pense pas qu'un tampon couse.
Il est essentiel que l'on doute ici.
Aline : subjonctif après le doute.
Patrick : le Cahier reste le journal.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Les trois formules de probabilité appellent le subjonctif.",
  "correct": true,
  "explanation": "Aline : subjonctif après le doute."
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
      "text": "Il est peu probable que le tampon remplacera",
      "correct": false
    },
    {
      "text": "Il se peut que la feuille rassure",
      "correct": true
    },
    {
      "text": "Il n'est pas sûr que tout le monde a besoin",
      "correct": false
    },
    {
      "text": "Il se peut la feuille rassure",
      "correct": false
    }
  ],
  "explanation": "Il se peut que + subjonctif (rassure)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "peu probable que",
      "right": "doute fort"
    },
    {
      "left": "il se peut que",
      "right": "possibilité"
    },
    {
      "left": "il n'est pas sûr que",
      "right": "incertitude"
    },
    {
      "left": "Cahier",
      "right": "journal"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl se peut que le Cahier ___ mieux. (valoir, subj.)",
  "answer": "vaille"
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
    "apprend",
    "pour",
    "le",
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
  "word": "rassure",
  "hint": "Il se peut que la feuille… ceux qui doutent."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il se peut que le Cahier vaut mieux, et il est peu probable que le tampon remplace le geste.",
  "correct_sentence": "Il se peut que le Cahier vaille mieux, et il est peu probable que le tampon remplace le geste.",
  "explanation": "Il se peut que + subjonctif : vaille."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/initiative-educ.svg",
      "word": "une initiative"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/negation-ni.svg",
      "word": "une négation"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/difference-modele.svg",
      "word": "une différence"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/deux-ecoles.svg",
      "word": "deux modèles"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez neuf phrases : trois par formule de probabilité, sur tampon / feuille / Cahier."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis trois doutes à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon avis sur le tampon',
    'PE',
    $c$Objectif
Écrire un avis argumenté sur l'utilité du tampon de cour.

Consigne
Imitez l'avis de Rose Iradukunda, sans aller trop vite.

Support — Avis de Rose Iradukunda
Rose Iradukunda — tampon de cour, geste, Cahier
Il est peu probable que le tampon de Solange remplace un coupon tendu ; il se peut toutefois qu'il rassure Patrick.
Il n'est pas sûr que Joël en ait besoin demain ; il se peut qu'une heure tenue à l'antenne lui suffise.
Je ne pense pas qu'un tampon couse mieux qu'une main ; il n'est pas sûr pourtant qu'on doive le refuser.
Lila : il est peu probable que Radio Figuier exige un titre d'ailleurs ; Aline en convient.
Ces chiffres de l'atelier indiquent que neuf gestes tenus parlent déjà, encore que six pages manquent.
Il se peut que le Cahier du chemin vaille mieux qu'une feuille trop vite tamponnée.
Sans nier que le Bureau aime une page lisible, il n'est pas sûr qu'elle compte autant sous le figuier.
On apprend pour le geste, afin que le sac tienne, non pour l'encre.
Le tampon peut accompagner ; il est peu probable qu'il remplace. Le Cahier reste le journal.
Il est essentiel que l'on doute ici, afin que personne n'idéalise un tampon.
Rose
Copie : Aline Uwase, Solange — Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose conclut que le tampon remplace déjà le geste.",
  "correct": false,
  "explanation": "Il peut accompagner ; il est peu probable qu'il remplace."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que Rose ne pense-t-elle pas qu'un tampon fasse ?",
  "options": [
    {
      "text": "Rassurer parfois",
      "correct": false
    },
    {
      "text": "Coudre mieux qu'une main",
      "correct": true
    },
    {
      "text": "Accompagner",
      "correct": false
    },
    {
      "text": "Rester lisible",
      "correct": false
    }
  ],
  "explanation": "« Je ne pense pas qu'un tampon couse mieux qu'une main. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "peu probable que",
      "right": "remplace un coupon"
    },
    {
      "left": "il se peut que",
      "right": "rassure / vaille"
    },
    {
      "left": "il n'est pas sûr que",
      "right": "Joël en ait besoin"
    },
    {
      "left": "Cahier",
      "right": "reste le journal"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl n'est pas sûr qu'on ___ le refuser. (devoir, subj.)",
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
    "Le",
    "Cahier",
    "reste",
    "le",
    "journal",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "utilite",
  "hint": "On discute l'… du tampon, pas celle d'un titre d'ailleurs. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est peu probable que le tampon remplace le geste, et il n'est pas sûr que Joël en a besoin demain.",
  "correct_sentence": "Il est peu probable que le tampon remplace le geste, et il n'est pas sûr que Joël en ait besoin demain.",
  "explanation": "Il n'est pas sûr que + subjonctif : ait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/negation-ni.svg",
      "word": "une négation"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/difference-modele.svg",
      "word": "une différence"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/deux-ecoles.svg",
      "word": "deux modèles"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/bilan-pedago.svg",
      "word": "un bilan"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : douze à quinze lignes, les trois formules de probabilité, tampon / feuille / Cahier, pas de diplôme d'ailleurs."
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
    'EL — Subjonctif de probabilité',
    'EL',
    $c$Objectif
Retenir il est peu probable que, il se peut que, il n'est pas sûr que.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, probabilité
Il est peu probable que + subjonctif : doute fort (il est peu probable que le tampon remplace).
Il se peut que + subjonctif : possibilité (il se peut que la feuille rassure ; il se peut qu'il vaille).
Il n'est pas sûr que + subjonctif : incertitude (il n'est pas sûr que tout le monde ait besoin ; qu'on doive).
Contrast : il est probable que + indicatif (certitude relative) ≠ il est peu probable que + subjonctif.
Verbes fréquents au subj. : remplace, rassure, ait, doive, vaille, suffise, couse.
On n'écrit pas : il est peu probable que le tampon remplacera. On n'écrit pas : il se peut que le Cahier vaut.
Tampon de cour, feuille de tenue : inventés au Seuil. Pas de diplôme d'ailleurs.
Le Cahier du chemin reste le journal d'apprentissage.
Le tampon peut accompagner ; il est peu probable qu'il remplace.
Attention : il faut que (pas je faut). À + le = au Bureau. Qu'on / qu'il / qu'elle.
Douter ici est une compétence ; idéaliser un tampon n'en est pas une.
Le Cahier du chemin reste le journal ; le tampon n'est qu'un accompagnement.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il est probable que » et « il est peu probable que » prennent le même mode.",
  "correct": false,
  "explanation": "Probable + indicatif ; peu probable + subjonctif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme suit « il se peut que le Cahier » ?",
  "options": [
    {
      "text": "vaut",
      "correct": false
    },
    {
      "text": "vaille",
      "correct": true
    },
    {
      "text": "vaudra",
      "correct": false
    },
    {
      "text": "valait seulement",
      "correct": false
    }
  ],
  "explanation": "Subjonctif de valoir : vaille."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "peu probable que",
      "right": "subj. / doute fort"
    },
    {
      "left": "il se peut que",
      "right": "subj. / possibilité"
    },
    {
      "left": "il n'est pas sûr que",
      "right": "subj. / incertitude"
    },
    {
      "left": "il est probable que",
      "right": "indicatif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl se peut qu'une heure tenue ___ . (suffire, subj.)",
  "answer": "suffise"
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
    "tampon",
    "peut",
    "accompagner",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "doute",
  "hint": "Il n'est pas sûr, il se peut, peu probable : trois portes du…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est peu probable que le tampon remplacera le geste, et le Cahier reste le journal.",
  "correct_sentence": "Il est peu probable que le tampon remplace le geste, et le Cahier reste le journal.",
  "explanation": "Peu probable que + subjonctif, pas le futur."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/difference-modele.svg",
      "word": "une différence"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/deux-ecoles.svg",
      "word": "deux modèles"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/bilan-pedago.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/projet-cour.svg",
      "word": "un projet"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Conjuguez remplacer, avoir, devoir, valoir au subjonctif après les trois formules."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six phrases, deux par formule."
}$j$::jsonb,
    9
  );

  -- ===== Une initiative, des différences =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une initiative, des différences'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une initiative, des différences', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Ni l''atelier ni l''antenne seuls',
    'CO',
    $c$Objectif
Repérer ne… ni… ni… et comparer deux modèles inventés : atelier sous le figuier et stage à Radio Figuier.

Consigne
Lisez le dialogue. En quoi les deux modèles diffèrent-ils, et que refuse-t-on ?

Support — Deux bancs face à face, figuier et antenne
Aline : Nous comparons deux initiatives : l'atelier sous le figuier, le stage à Radio Figuier. Ni l'un ni l'autre n'est une école d'ailleurs.
Dieudonné : Mon modèle n'est ni un titre ni un palais ni une course : on mesure, on tend, on voit un geste fini.
Lila : Le stage n'est ni une scène ni un cri ni un relais sans fin : on écoute, on coupe à trois minutes.
Patrick : Je n'ai ni diplômé d'ailleurs ni tampon trop vite posé ni verdict : j'essaie les deux portes.
Léa : L'atelier forme les mains ; l'antenne forme l'oreille. Ni les mains ni l'oreille ne suffisent seules.
Marc : On ne compare ni pour trahir ni pour idéaliser ni pour juger trop vite : on décrit une différence.
Joël : Je n'ai ni la maîtrise du fil ni celle du micro, ni la honte de recommencer.
Rose : L'atelier n'est ni plus noble ni plus petit ; le stage n'est ni plus brillant ni plus faible.
Hawa : Cette initiative n'emprunte ni un nom lointain ni un règlement d'ailleurs ni une ville.
Karim : Solange ne tamponnera ni une rumeur ni une page illisible ni un titre emprunté.
Félicie : On ne décide ni trop tôt ni sans thé ni sans avoir entendu les deux voix.
Mado : J'écrirai : ne… ni… ni… ; deux modèles ; une différence, pas une guerre.
Yvette : Il est essentiel que l'on tienne les deux, afin que personne n'en ferme une.
Aline : Ne… ni… ni… nie plus d'un élément. Les deux modèles restent inventés, sous le figuier et à l'antenne.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline dit que ni l'atelier ni le stage n'est une école d'ailleurs.",
  "correct": true,
  "explanation": "Première réplique."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que forme surtout l'atelier, selon Léa ?",
  "options": [
    {
      "text": "L'oreille seulement",
      "correct": false
    },
    {
      "text": "Les mains",
      "correct": true
    },
    {
      "text": "Un titre d'ailleurs",
      "correct": false
    },
    {
      "text": "Un verdict",
      "correct": false
    }
  ],
  "explanation": "Léa : l'atelier forme les mains ; l'antenne, l'oreille."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "atelier sous le figuier",
      "right": "mesurer / tendre / mains"
    },
    {
      "left": "stage à Radio Figuier",
      "right": "écouter / trois minutes / oreille"
    },
    {
      "left": "ne… ni… ni…",
      "right": "plus d'un élément nié"
    },
    {
      "left": "ni pour trahir ni pour idéaliser",
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
  "prompt": "Complétez :\nNi l'un ___ l'autre n'est une école d'ailleurs.",
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
    "L'atelier",
    "forme",
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
  "word": "modele",
  "hint": "Atelier ou stage : un… inventé de la cour. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je n'ai ni titre d'ailleurs ou tampon trop vite posé, et j'essaie les deux portes.",
  "correct_sentence": "Je n'ai ni titre d'ailleurs ni tampon trop vite posé, et j'essaie les deux portes.",
  "explanation": "Ne… ni… ni… : on reprend ni, pas ou."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/deux-ecoles.svg",
      "word": "deux modèles"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/bilan-pedago.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/projet-cour.svg",
      "word": "un projet"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/banc-lecon.svg",
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
  "prompt": "Notez quatre différences et quatre phrases en ne… ni… ni… entendues."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Ni l'un ni l'autre n'est une école d'ailleurs. L'atelier forme les mains. L'antenne forme l'oreille. On ne compare ni pour trahir ni pour idéaliser."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Deux modèles, une cour',
    'CE',
    $c$Objectif
Lire une comparaison argumentée des deux initiatives inventées.

Consigne
Lisez la comparaison, sans aller trop vite.

Support — Feuille de Hawa Diallo
Deux modèles — atelier sous le figuier / stage à Radio Figuier
L'atelier de Dieudonné n'est ni un palais ni une course ni un titre : on mesure, on tend, on voit un geste fini.
Le stage chez Lila n'est ni une scène ni un cri ni un relais sans fin : on écoute, on coupe à trois minutes, on pose le casque.
Patrick n'a ni diplôme d'ailleurs ni verdict : il essaie les deux portes, afin de comparer sans trahir.
Léa : l'atelier forme les mains ; l'antenne forme l'oreille. Ni les mains ni l'oreille ne suffisent seules.
Marc : on ne compare ni pour idéaliser ni pour juger trop vite ni pour fermer une porte.
Joël n'a ni la maîtrise du fil ni celle du micro, ni la honte de recommencer : c'est déjà une compétence.
Rose : l'atelier n'est ni plus noble ni plus petit ; le stage n'est ni plus brillant ni plus faible.
Cette initiative n'emprunte ni un nom lointain ni un règlement d'ailleurs ni une ville.
Solange ne tamponnera ni une rumeur ni une page illisible.
On ne décide ni trop tôt ni sans thé ni sans avoir entendu les deux voix.
Il est peu probable que l'un remplace l'autre ; il se peut que les deux tiennent le Seuil.
Il n'est pas sûr que Patrick doive choisir ce soir ; il est essentiel que les portes restent ouvertes.
Ces lignes n'inventent ni une école lointaine ni une guerre : elles décrivent une différence de la cour.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La feuille dit qu'il faut fermer une des deux portes ce soir.",
  "correct": false,
  "explanation": "Il est essentiel que les portes restent ouvertes."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que le stage chez Lila n'est-il pas, d'après la feuille ?",
  "options": [
    {
      "text": "Une oreille",
      "correct": false
    },
    {
      "text": "Une scène, un cri, un relais sans fin",
      "correct": true
    },
    {
      "text": "Un relais de trois minutes",
      "correct": false
    },
    {
      "text": "Un casque posé",
      "correct": false
    }
  ],
  "explanation": "« ni une scène ni un cri ni un relais sans fin. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "atelier",
      "right": "mains / coupon / geste fini"
    },
    {
      "left": "stage radio",
      "right": "oreille / trois minutes"
    },
    {
      "left": "ni… ni… ni…",
      "right": "palais / course / titre"
    },
    {
      "left": "portes ouvertes",
      "right": "essentiel"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNi les mains ___ l'oreille ne suffisent seules.",
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
    "On",
    "compare",
    "sans",
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
  "word": "difference",
  "hint": "Ce que l'on décrit entre les deux modèles, sans guerre. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On ne compare pas ni pour idéaliser ni pour juger trop vite, et les portes restent ouvertes.",
  "correct_sentence": "On ne compare ni pour idéaliser ni pour juger trop vite, et les portes restent ouvertes.",
  "explanation": "Ne… ni… ni… : pas de pas devant ni."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/bilan-pedago.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/projet-cour.svg",
      "word": "un projet"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/banc-lecon.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/livre-ouvert.svg",
      "word": "un livre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la feuille et dressez deux colonnes : atelier / stage ; encadrez ne… ni… ni…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la comparaison, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire ne… ni… ni… et comparer',
    'PO',
    $c$Objectif
Comparer à l'oral les deux modèles avec ne… ni… ni…

Consigne
Répétez, puis dites trois différences et une phrase en ni… ni… ni…

Support — Modèles d'Aline, de Dieudonné et de Lila
Ni l'un ni l'autre n'est une école d'ailleurs.
L'atelier n'est ni un palais ni une course.
Le stage n'est ni une scène ni un cri.
L'atelier forme les mains.
L'antenne forme l'oreille.
Ni les mains ni l'oreille ne suffisent seules.
On ne compare ni pour trahir ni pour idéaliser.
Je n'ai ni titre ni verdict ni honte de recommencer.
L'atelier n'est ni plus noble ni plus petit.
Le stage n'est ni plus brillant ni plus faible.
Il est essentiel que les portes restent ouvertes.
On ne décide ni trop tôt ni sans thé.
Dieudonné : un geste fini.
Lila : trois minutes, un casque posé.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Ne… ni… ni… permet de nier plus d'un élément dans la même phrase.",
  "correct": true,
  "explanation": "Aline l'a rappelé."
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
      "text": "Je n'ai pas ni titre ni verdict",
      "correct": false
    },
    {
      "text": "Je n'ai ni titre ni verdict ni honte",
      "correct": true
    },
    {
      "text": "Je n'ai ni titre ou verdict",
      "correct": false
    },
    {
      "text": "Ni l'un ou l'autre n'est une école",
      "correct": false
    }
  ],
  "explanation": "Je n'ai ni… ni… ni…"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "atelier",
      "right": "mains / geste fini"
    },
    {
      "left": "stage",
      "right": "oreille / trois minutes"
    },
    {
      "left": "ne… ni… ni…",
      "right": "plus d'un élément"
    },
    {
      "left": "portes ouvertes",
      "right": "les deux modèles"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ne compare ___ pour trahir ni pour idéaliser.",
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
    "Ni",
    "les",
    "mains",
    "ni",
    "l'oreille",
    "ne",
    "suffisent",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "initiative",
  "hint": "Les deux modèles de la cour : une… éducative, pas une guerre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ni l'un ou l'autre n'est une école d'ailleurs, et les portes restent ouvertes.",
  "correct_sentence": "Ni l'un ni l'autre n'est une école d'ailleurs, et les portes restent ouvertes.",
  "explanation": "Ni l'un ni l'autre, pas ni l'un ou l'autre."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/projet-cour.svg",
      "word": "un projet"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/banc-lecon.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/livre-ouvert.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/radio-classe.svg",
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
  "prompt": "Écrivez six phrases en ne… ni… ni… et quatre comparaisons atelier / stage."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis une comparaison à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma comparaison de modèles',
    'PE',
    $c$Objectif
Écrire une comparaison argumentée des deux initiatives, avec ne… ni… ni…

Consigne
Imitez la comparaison de Joël Mugisha, sans aller trop vite.

Support — Comparaison de Joël Mugisha
Joël Mugisha — deux modèles, sans en fermer un
L'atelier sous le figuier n'est ni un palais ni une course ni un titre : Dieudonné mesure, tend, montre un geste fini.
Le stage à Radio Figuier n'est ni une scène ni un cri ni un relais sans fin : Lila écoute, coupe à trois minutes, pose le casque.
Je n'ai ni la maîtrise du fil ni celle du micro, ni la honte de recommencer.
Léa dit que l'atelier forme les mains et que l'antenne forme l'oreille ; ni les unes ni l'autre ne suffisent seules.
On ne compare ni pour trahir ni pour idéaliser ni pour juger trop vite.
Patrick n'a ni diplôme d'ailleurs ni verdict : il essaie les deux portes, afin de voir.
Cette initiative n'emprunte ni un nom lointain ni un règlement d'ailleurs.
Il est peu probable que l'un remplace l'autre ; il se peut que les deux tiennent le Seuil.
Il n'est pas sûr que je doive choisir ce soir ; il est essentiel que les portes restent ouvertes.
On ne décide ni trop tôt ni sans thé ni sans avoir entendu Aline.
Joël
Cahier du chemin — Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël a honte de recommencer, et il le dit comme une faute.",
  "correct": false,
  "explanation": "Il n'a ni… ni la honte de recommencer."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que Patrick n'a-t-il pas, d'après Joël ?",
  "options": [
    {
      "text": "Deux portes à essayer",
      "correct": false
    },
    {
      "text": "Ni diplôme d'ailleurs ni verdict",
      "correct": true
    },
    {
      "text": "Le thé de Félicie",
      "correct": false
    },
    {
      "text": "Le Cahier du chemin",
      "correct": false
    }
  ],
  "explanation": "« ni diplôme d'ailleurs ni verdict. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "atelier",
      "right": "geste fini / mains"
    },
    {
      "left": "stage",
      "right": "trois minutes / oreille"
    },
    {
      "left": "ni… ni… ni…",
      "right": "palais / course / titre"
    },
    {
      "left": "portes ouvertes",
      "right": "essentiel"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ne décide ___ trop tôt ni sans thé.",
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
    "Les",
    "portes",
    "restent",
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
  "word": "ecole",
  "hint": "Ni l'un ni l'autre n'est une… d'ailleurs. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je n'ai pas ni la maîtrise du fil ni celle du micro, et je recommence sans honte.",
  "correct_sentence": "Je n'ai ni la maîtrise du fil ni celle du micro, et je recommence sans honte.",
  "explanation": "Ne… ni… : pas de pas devant ni."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/banc-lecon.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/livre-ouvert.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/radio-classe.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/groupe-apprenants.svg",
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
  "prompt": "Imitez : quinze lignes, trois ne… ni… ni…, deux différences claires, une probabilité, un essentiel que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre comparaison, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Ne… ni… ni… et comparaison de modèles',
    'EL',
    $c$Objectif
Retenir la négation multiple et les axes de comparaison des deux initiatives.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, ni et différences
Ne… ni… ni… : on nie plus d'un élément (je n'ai ni titre ni verdict ni honte).
Ni l'un ni l'autre + ne + verbe : ni l'un ni l'autre n'est une école d'ailleurs.
Pas : je n'ai pas ni. Pas : ni l'un ou l'autre. Pas : ni… ou…
Atelier sous le figuier : mesurer, tendre, geste fini, mains, silence des mains.
Stage à Radio Figuier : écouter, couper à trois minutes, casque, oreille, silence de l'antenne.
Comparer : plus / moins / ni plus noble ni plus petit. On décrit une différence, on ne fait pas une guerre.
On ne compare ni pour trahir ni pour idéaliser ni pour fermer une porte.
Réemploi : il est peu probable que l'un remplace l'autre ; il se peut que les deux tiennent ; il est essentiel que les portes restent ouvertes.
Aucun nom d'école d'ailleurs, aucune ville lointaine.
Attention : accord (ni les mains ni l'oreille ne suffisent). À + le = au figuier, à l'antenne.
Une initiative de cour se dit avec des gestes, pas avec un titre emprunté.
Les deux modèles restent ouverts : figuier le matin, antenne le jeudi.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je n'ai pas ni titre ni verdict ».",
  "correct": false,
  "explanation": "Je n'ai ni titre ni verdict."
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
      "text": "Ni l'un ou l'autre n'est",
      "correct": false
    },
    {
      "text": "Ni l'un ni l'autre n'est une école d'ailleurs",
      "correct": true
    },
    {
      "text": "Je n'ai pas ni titre",
      "correct": false
    },
    {
      "text": "Ni titre ou verdict",
      "correct": false
    }
  ],
  "explanation": "Ni l'un ni l'autre n'est."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ne… ni… ni…",
      "right": "plus d'un élément"
    },
    {
      "left": "atelier",
      "right": "mains / geste fini"
    },
    {
      "left": "stage",
      "right": "oreille / trois minutes"
    },
    {
      "left": "ni pour trahir ni pour idéaliser",
      "right": "comparer juste"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNi l'un ni l'autre ___ une école d'ailleurs. (être, présent)",
  "answer": "n'est"
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
    "une",
    "différence",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "comparer",
  "hint": "Mettre les deux modèles face à face, sans en fermer un."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ni les mains ni l'oreille suffit seules, et les portes restent ouvertes.",
  "correct_sentence": "Ni les mains ni l'oreille ne suffisent seules, et les portes restent ouvertes.",
  "explanation": "Sujets coordonnés par ni : verbe au pluriel, suffisent, avec ne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/livre-ouvert.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/radio-classe.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/groupe-apprenants.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/pupitre-aline.svg",
      "word": "un pupitre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Faites deux listes (atelier / stage) et six phrases en ne… ni… ni…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six phrases : trois ni, trois comparaisons."
}$j$::jsonb,
    9
  );

  -- ===== Bilan pédagogique d'Aline =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Bilan pédagogique d''Aline'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Bilan pédagogique d''Aline', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Ce que la saison a tenu',
    'CO',
    $c$Objectif
Suivre le bilan pédagogique d'Aline et réemployer but, chiffres, doute et comparaison.

Consigne
Lisez le bilan parlé. Qu'est-ce qui a tenu, et qu'est-ce qui reste fragile ?

Support — Pupitre d'Aline, Cahier du chemin ouvert
Aline : Je cherche un bilan qui puisse se relire, afin que personne n'enfle la saison.
Patrick : Cela montre que dix-huit pages ont tenu ; je ne pense pas que deux cahiers fermés soient un échec.
Léa : On constate que la moitié a osé le relais ; il est essentiel que Joël recommence sans honte.
Marc : Ces chiffres indiquent qu'un geste de main reste plus rare ; encore qu'il faille continuer.
Dieudonné : Il est peu probable que le tampon remplace le coupon ; il se peut que le journal suffise.
Lila : Ni l'atelier ni l'antenne n'a fermé ; il n'est pas sûr que Patrick doive choisir ce soir.
Joël : Je n'ai ni la maîtrise ni la honte ; un bilan qui puisse dire cela, c'est déjà beaucoup.
Rose : On ne compare ni pour trahir ni pour idéaliser : les deux modèles ont tenu le Seuil.
Hawa : Soixante-quinze pour cent de pages, un quart de jeudis : on peut toutefois relancer les six manquantes.
Karim : Solange n'a tamponné ni rumeur ni page illisible : cela aussi se commente.
Félicie : Il se peut que le thé ait tenu le groupe plus qu'un discours.
Mado : J'écrirai le bilan afin qu'il puisse rester honnête, sans titre d'ailleurs.
Yvette : Je ne pense pas qu'un bilan soit un verdict ; il est essentiel qu'il reste une page du Cahier.
Aline : Objectifs, chiffres, doute, différences : quatre portes du bilan, pas un mur.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline présente le bilan comme un verdict définitif.",
  "correct": false,
  "explanation": "Yvette et Aline : ce n'est pas un verdict."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que montrent les dix-huit pages, selon Patrick ?",
  "options": [
    {
      "text": "Un échec",
      "correct": false
    },
    {
      "text": "Que le journal a tenu",
      "correct": true
    },
    {
      "text": "La fermeture de l'antenne",
      "correct": false
    },
    {
      "text": "Un diplôme d'ailleurs",
      "correct": false
    }
  ],
  "explanation": "« dix-huit pages ont tenu. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui puisse se relire",
      "right": "bilan / but"
    },
    {
      "left": "cela montre que",
      "right": "18 pages"
    },
    {
      "left": "peu probable que",
      "right": "tampon remplace"
    },
    {
      "left": "ni l'atelier ni l'antenne",
      "right": "n'a fermé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ne pense pas qu'un bilan ___ un verdict. (être, subj.)",
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
    "Un",
    "bilan",
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
  "word": "bilan",
  "hint": "Page d'Aline : ce qui a tenu, ce qui reste fragile, sans enfler."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ne pense pas qu'un bilan est un verdict, et il est essentiel qu'il reste une page du Cahier.",
  "correct_sentence": "Je ne pense pas qu'un bilan soit un verdict, et il est essentiel qu'il reste une page du Cahier.",
  "explanation": "Je ne pense pas que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/radio-classe.svg",
      "word": "un pupitre"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/groupe-apprenants.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/pupitre-aline.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/soleil-apprendre.svg",
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
  "prompt": "Notez quatre réussites et quatre fragilités du bilan, avec la formule qui les porte."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Un bilan qui puisse se relire. Cela montre que dix-huit pages ont tenu. Ni l'atelier ni l'antenne n'a fermé. Un bilan n'est pas un verdict."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Bilan pédagogique d''Aline',
    'CE',
    $c$Objectif
Lire le bilan argumenté de la saison à l'Atelier d'Aline.

Consigne
Lisez le bilan, sans aller trop vite.

Support — Bilan d'Aline Uwase
Bilan pédagogique — Atelier d'Aline, saison sèche
Je cherche un bilan qui puisse se relire demain, afin que personne n'enfle ce que la cour a tenu.
Vingt-quatre inscrits, dix-huit pages : cela montre que le Cahier du chemin tient, pour trois sur quatre.
Douze relais, neuf coupons, six jeudis : on constate que l'oreille s'ouvre plus vite que la main, encore qu'il faille continuer.
Trois seconds essais : ces résultats montrent qu'on ose recommencer ; je ne pense pas que deux cahiers fermés soient un échec.
Il est peu probable que le tampon de cour remplace un geste ; il se peut que le journal suffise ; il n'est pas sûr que Patrick doive choisir ce soir.
Ni l'atelier sous le figuier ni le stage à Radio Figuier n'a fermé : on ne compare ni pour trahir ni pour idéaliser.
L'atelier n'est ni un palais ni une course ; le stage n'est ni une scène ni un cri. Les mains et l'oreille se répondent.
Solange n'a tamponné ni rumeur ni page illisible ; Karim l'a lu sans enfler.
Il est essentiel que les six pages manquantes soient relancées, afin que le silence ne s'installe pas.
Il se peut que le thé de Félicie ait tenu le groupe plus qu'un discours : ce n'est pas rien.
Ce bilan n'emprunte ni un nom d'école d'ailleurs ni un verdict. C'est une page du Cahier du chemin.
Aline Uwase — formatrice, Seuil des Sources
Copie : Dieudonné, Lila, Patrick, Mado
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline écrit que l'oreille s'ouvre plus vite que la main.",
  "correct": true,
  "explanation": "« l'oreille s'ouvre plus vite que la main. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que Aline ne pense-t-elle pas que deux cahiers fermés soient ?",
  "options": [
    {
      "text": "Une page",
      "correct": false
    },
    {
      "text": "Un échec",
      "correct": true
    },
    {
      "text": "Un relais",
      "correct": false
    },
    {
      "text": "Un thé",
      "correct": false
    }
  ],
  "explanation": "« je ne pense pas que deux cahiers fermés soient un échec. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "18 / 24",
      "right": "le journal tient"
    },
    {
      "left": "oreille / main",
      "right": "s'ouvre plus vite"
    },
    {
      "left": "tampon",
      "right": "peu probable qu'il remplace"
    },
    {
      "left": "ni atelier ni stage",
      "right": "n'a fermé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl est essentiel que les six pages ___ relancées. (être, subj.)",
  "answer": "soient"
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
    "bilan",
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
  "word": "pedagogie",
  "hint": "Travail d'Aline : objectifs, gestes, doutes, sans titre d'ailleurs. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est essentiel que les six pages sont relancées, et le Cahier reste le journal.",
  "correct_sentence": "Il est essentiel que les six pages soient relancées, et le Cahier reste le journal.",
  "explanation": "Il est essentiel que + subjonctif : soient."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/groupe-apprenants.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/pupitre-aline.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/soleil-apprendre.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/nuage-doute.svg",
      "word": "un figuier"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le bilan et classez : but, chiffre, doute, ni… ni, essentiel."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le bilan d'Aline, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire le bilan de la saison',
    'PO',
    $c$Objectif
Réemployer à l'oral les formules du module pour un bilan honnête.

Consigne
Répétez, puis dites ce qui a tenu et ce qui reste à relancer.

Support — Modèles d'Aline et de Mado
Un bilan qui puisse se relire.
Afin que personne n'enfle.
Cela montre que le journal tient.
On constate que l'oreille s'ouvre.
Je ne pense pas que deux silences soient un échec.
Il est essentiel que l'on relance.
Il est peu probable que le tampon remplace.
Il se peut que le journal suffise.
Ni l'atelier ni l'antenne n'a fermé.
On ne compare ni pour trahir ni pour idéaliser.
Un bilan n'est pas un verdict.
Les mains et l'oreille se répondent.
Aline : quatre portes, pas un mur.
Patrick : j'essaierai encore les deux.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le bilan réemploie but, commentaire, doute et comparaison.",
  "correct": true,
  "explanation": "Aline : quatre portes."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase dit correctement le doute sur le tampon ?",
  "options": [
    {
      "text": "Il est peu probable que le tampon remplacera",
      "correct": false
    },
    {
      "text": "Il est peu probable que le tampon remplace",
      "correct": true
    },
    {
      "text": "Il se peut le journal suffire",
      "correct": false
    },
    {
      "text": "Je n'ai pas ni atelier ni antenne",
      "correct": false
    }
  ],
  "explanation": "Peu probable que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui puisse",
      "right": "bilan relisible"
    },
    {
      "left": "cela montre que",
      "right": "journal"
    },
    {
      "left": "peu probable que",
      "right": "tampon"
    },
    {
      "left": "ni… ni…",
      "right": "atelier / antenne"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNi l'atelier ni l'antenne ___ fermé.",
  "answer": "n'a"
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
    "bilan",
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
  "word": "relancer",
  "hint": "Ce qu'il faut faire des six pages manquantes, sans juger trop vite."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ni l'atelier ni l'antenne n'ont fermé uniquement la cour, et le bilan reste une page.",
  "correct_sentence": "Ni l'atelier ni l'antenne n'a fermé uniquement la cour, et le bilan reste une page.",
  "explanation": "Ni l'un ni l'autre + verbe au singulier ici : n'a fermé."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/pupitre-aline.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/soleil-apprendre.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/nuage-doute.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/feuille-projet.svg",
      "word": "une craie"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un oral de bilan en dix phrases : deux par porte (but, chiffre, doute, ni, essentiel)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis votre bilan en une minute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon bilan de saison',
    'PE',
    $c$Objectif
Écrire un bilan pédagogique argumenté, à la manière d'Aline.

Consigne
Imitez le bilan de Léa Niyonzima, sans aller trop vite.

Support — Bilan de Léa Niyonzima
Léa Niyonzima — bilan d'une oreille, pour Aline
Je cherche un bilan qui puisse se relire, afin que je n'enfle ni le relais ni le silence de Joël.
Cela montre que douze voix ont osé trois minutes ; on constate que l'oreille s'ouvre, encore que la main reste plus rare.
Je ne pense pas que deux cahiers fermés soient un échec ; il est essentiel que Mado les relance, afin qu'ils puissent s'ouvrir.
Il est peu probable que le tampon de Solange remplace un geste ; il se peut que le Cahier suffise ; il n'est pas sûr que Patrick doive choisir.
Ni l'atelier ni l'antenne n'a fermé : on ne compare ni pour trahir ni pour idéaliser.
L'atelier n'est ni un palais ni une course ; le stage n'est ni une scène ni un cri.
Dieudonné a dit qu'un geste fini valait mieux qu'un titre ; Lila a demandé si trois minutes tenaient : on me l'a confirmé.
Il se peut que le thé ait tenu le groupe ; ce n'est pas rien.
Ce bilan n'emprunte ni un nom d'école d'ailleurs ni un verdict. C'est une page du Cahier du chemin.
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
  "statement": "Léa emprunte un nom d'école d'ailleurs pour signer son bilan.",
  "correct": false,
  "explanation": "« n'emprunte ni un nom d'école d'ailleurs ni un verdict. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que Dieudonné a-t-il dit, d'après Léa ?",
  "options": [
    {
      "text": "Qu'un titre valait mieux qu'un geste",
      "correct": false
    },
    {
      "text": "Qu'un geste fini valait mieux qu'un titre",
      "correct": true
    },
    {
      "text": "Qu'il fallait fermer l'antenne",
      "correct": false
    },
    {
      "text": "Que le thé était interdit",
      "correct": false
    }
  ],
  "explanation": "« un geste fini valait mieux qu'un titre. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui puisse se relire",
      "right": "bilan"
    },
    {
      "left": "cela montre que",
      "right": "douze voix"
    },
    {
      "left": "ni atelier ni antenne",
      "right": "n'a fermé"
    },
    {
      "left": "Cahier du chemin",
      "right": "page, pas verdict"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl n'est pas sûr que Patrick ___ choisir. (devoir, subj.)",
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
    "Ce",
    "n'est",
    "pas",
    "rien",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "saison",
  "hint": "Période sèche de l'Atelier d'Aline, celle que le bilan relit."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ne pense pas que deux cahiers fermés sont un échec, et il est essentiel que Mado les relance.",
  "correct_sentence": "Je ne pense pas que deux cahiers fermés soient un échec, et il est essentiel que Mado les relance.",
  "explanation": "Je ne pense pas que + subjonctif : soient."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/soleil-apprendre.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/nuage-doute.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/feuille-projet.svg",
      "word": "une craie"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/figuier-ecole.svg",
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
  "prompt": "Imitez : quinze lignes, but, chiffres, trois doutes, ne… ni… ni…, pas de verdict."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre bilan, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Langue du bilan pédagogique',
    'EL',
    $c$Objectif
Relier dans un même texte but, commentaire, probabilité et comparaison.

Consigne
Apprenez la fiche.

Support — Fiche de synthèse du bilan
Réemploi 1 — but : un bilan qui puisse se relire ; afin que personne n'enfle.
Réemploi 2 — opinion : je ne pense pas que ce soit un échec ; il est essentiel que l'on relance.
Réemploi 3 — chiffres : cela montre que ; on constate que ; ces chiffres indiquent que.
Réemploi 4 — probabilité : peu probable que ; il se peut que ; il n'est pas sûr que.
Réemploi 5 — ni… ni… : ni l'atelier ni l'antenne ; on ne compare ni pour trahir ni pour idéaliser.
Un bilan n'est pas un verdict. Le Cahier du chemin en est le lieu, pas un diplôme d'ailleurs.
Modes : subjonctif après but, opinion négative, essentiel, peu probable, il se peut, il n'est pas sûr.
Indicatif après cela montre que, on constate que, je pense que.
Ni l'un ni l'autre n'a / n'est. Pas : je n'ai pas ni.
Attention : soient / doive / faille / puisse. Il faut (pas je faut).
La formatrice signe Aline Uwase. Les portes restent ouvertes.
Un bilan honnête relie les chiffres aux gestes, sans en faire un verdict.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Cela montre que » prend le subjonctif.",
  "correct": false,
  "explanation": "Indicatif après cela montre que."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série est correcte pour le bilan ?",
  "options": [
    {
      "text": "qui peut (but) / je n'ai pas ni / peu probable que remplacera",
      "correct": false
    },
    {
      "text": "qui puisse / je ne pense pas que ce soit / ni l'atelier ni l'antenne",
      "correct": true
    },
    {
      "text": "afin que on ose sans subj. / cela montrent / ni l'un ou l'autre",
      "correct": false
    },
    {
      "text": "il est essentiel que c'est / je faut relancer / un verdict obligatoire",
      "correct": false
    }
  ],
  "explanation": "Puisse, soit, ni… ni…"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui puisse / afin que",
      "right": "but"
    },
    {
      "left": "cela montre que",
      "right": "indicatif"
    },
    {
      "left": "peu probable que",
      "right": "subjonctif"
    },
    {
      "left": "ni… ni…",
      "right": "deux modèles"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAfin que personne ___ la saison. (enfler, subj.)",
  "answer": "n'enfle"
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
    "portes",
    "restent",
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
  "word": "formatrice",
  "hint": "Rôle d'Aline à l'Atelier : elle forme, elle ne juge pas trop vite."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Cela montrent que le journal tient, et il est essentiel que l'on relance les six pages.",
  "correct_sentence": "Cela montre que le journal tient, et il est essentiel que l'on relance les six pages.",
  "explanation": "Cela : singulier, montre."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/nuage-doute.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/feuille-projet.svg",
      "word": "une craie"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/figuier-ecole.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/main-craie.svg",
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
  "prompt": "Rédigez un tableau : cinq réemplois, un exemple tiré du bilan d'Aline."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et cinq phrases, une par réemploi."
}$j$::jsonb,
    9
  );

  -- ===== Projet d'école de la cour =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Projet d''école de la cour'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Projet d''école de la cour', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Manifeste sous le figuier',
    'CO',
    $c$Objectif
Comprendre un projet d'école de la cour et les formules d'un manifeste éducatif.

Consigne
Lisez le dialogue. Quels articles du manifeste entend-on ?

Support — Cour du figuier, feuille de manifeste
Aline : Nous signerons un manifeste pour l'école de la cour. Elle n'est ni une école d'ailleurs ni un palais.
Patrick : Je cherche une école qui puisse tenir sous le figuier, afin que le Cahier du chemin reste le journal.
Léa : Il est essentiel que les deux portes restent ouvertes, encore que chacun tienne à son banc.
Marc : Il est peu probable qu'un tampon remplace un geste ; il se peut que la page suffise.
Dieudonné : L'école de la cour n'est ni un titre ni une course : on mesure, on tend, on voit.
Lila : Ni scène ni cri : un stage d'oreille, trois minutes, un casque posé.
Joël : Je ne pense pas que l'on apprenne trop vite ; on ne décide ni trop tôt ni sans thé.
Rose : On ne compare ni pour trahir ni pour idéaliser ; les mains et l'oreille se répondent.
Hawa : Cela montre que la saison a tenu ; on constate qu'il reste six pages à relancer.
Karim : Solange ne tamponnera ni rumeur ni page illisible ; le Bureau lit, il ne gouverne pas l'école.
Félicie : Il se peut que le thé soit déjà une leçon ; ce n'est pas rien.
Mado : J'écrirai le manifeste afin qu'il puisse se relire, sans nom d'ailleurs.
Yvette : Un manifeste n'est pas un verdict ; c'est une promesse de cour.
Aline : École de la cour : inventée ici. Atelier d'Aline, Cahier du chemin, deux portes, pas de ville lointaine.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline situe l'école de la cour ici, sans ville lointaine.",
  "correct": true,
  "explanation": "Dernière réplique."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que Patrick cherche-t-il ?",
  "options": [
    {
      "text": "Une école d'ailleurs",
      "correct": false
    },
    {
      "text": "Une école qui puisse tenir sous le figuier",
      "correct": true
    },
    {
      "text": "Un palais",
      "correct": false
    },
    {
      "text": "Un verdict",
      "correct": false
    }
  ],
  "explanation": "« une école qui puisse tenir sous le figuier. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "école de la cour",
      "right": "inventée ici"
    },
    {
      "left": "qui puisse tenir",
      "right": "sous le figuier"
    },
    {
      "left": "deux portes",
      "right": "atelier / antenne"
    },
    {
      "left": "Cahier du chemin",
      "right": "journal"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'école de la cour n'est ___ une école d'ailleurs ni un palais.",
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
    "Un",
    "manifeste",
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
  "word": "manifeste",
  "hint": "Texte promis sous le figuier : articles d'une école inventée."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je cherche une école qui peut tenir sous le figuier, et afin que le Cahier reste le journal.",
  "correct_sentence": "Je cherche une école qui puisse tenir sous le figuier, et afin que le Cahier reste le journal.",
  "explanation": "Relative de but : qui puisse."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/feuille-projet.svg",
      "word": "une craie"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/figuier-ecole.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/main-craie.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/horloge-cours.svg",
      "word": "un objectif"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez six articles du manifeste et la formule (but, ni, doute, chiffre) qui les porte."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Une école qui puisse tenir sous le figuier. Ni une école d'ailleurs ni un palais. Le Cahier reste le journal. Un manifeste n'est pas un verdict."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Manifeste de l''école de la cour',
    'CE',
    $c$Objectif
Lire le manifeste éducatif argumenté du Seuil.

Consigne
Lisez le manifeste, sans aller trop vite.

Support — Manifeste — école de la cour
Manifeste pour l'école de la cour — Seuil des Sources
Nous cherchons une école qui puisse tenir sous le figuier, afin que personne n'emprunte un nom d'ailleurs.
Elle n'est ni un palais ni une course ni un titre : elle est l'Atelier d'Aline le matin, Radio Figuier le jeudi.
Il est essentiel que les deux portes restent ouvertes, encore que chacun tienne à son banc.
Le Cahier du chemin est le journal : nous ne pensons pas qu'il soit un diplôme ; il est peu probable qu'un tampon le remplace.
Il se peut que la feuille de tenue rassure ; il n'est pas sûr que tout le monde en ait besoin.
Cela montre que dix-huit pages ont tenu ; on constate que l'oreille s'ouvre ; ces chiffres indiquent que la main demande plus de temps.
On ne compare ni pour trahir ni pour idéaliser : l'atelier forme les mains, le stage forme l'oreille.
On ne décide ni trop tôt ni sans thé ni sans avoir entendu les deux voix.
Solange ne tamponnera ni rumeur ni page illisible ; le Bureau lit, il ne gouverne pas l'école.
Il est essentiel que l'on ose recommencer, afin que la honte reste dehors.
Ce manifeste n'est pas un verdict : c'est une promesse de cour, relisible demain.
Signataires : Aline Uwase, Dieudonné Hakizimana, Lila Sow, Patrick Habimana, Mado
École de la cour — Rukiri-Nord
Aucune ville lointaine, aucun nom emprunté.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le manifeste présente le Cahier du chemin comme un diplôme.",
  "correct": false,
  "explanation": "« nous ne pensons pas qu'il soit un diplôme. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que le Bureau fait-il, selon le manifeste ?",
  "options": [
    {
      "text": "Il gouverne l'école",
      "correct": false
    },
    {
      "text": "Il lit, il ne gouverne pas l'école",
      "correct": true
    },
    {
      "text": "Il ferme les portes",
      "correct": false
    },
    {
      "text": "Il impose un titre d'ailleurs",
      "correct": false
    }
  ],
  "explanation": "« le Bureau lit, il ne gouverne pas l'école. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui puisse tenir",
      "right": "sous le figuier"
    },
    {
      "left": "ni palais ni course ni titre",
      "right": "école de la cour"
    },
    {
      "left": "Cahier",
      "right": "journal, pas diplôme"
    },
    {
      "left": "deux portes",
      "right": "atelier / jeudi radio"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ne pensons pas qu'il ___ un diplôme. (être, subj.)",
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
    "C'est",
    "une",
    "promesse",
    "de",
    "cour",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "promesse",
  "hint": "Le manifeste en est une : tenir l'école de la cour demain."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous ne pensons pas qu'il est un diplôme, et le Cahier reste le journal.",
  "correct_sentence": "Nous ne pensons pas qu'il soit un diplôme, et le Cahier reste le journal.",
  "explanation": "Ne penser pas que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/figuier-ecole.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/main-craie.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/horloge-cours.svg",
      "word": "un objectif"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/coeur-transmission.svg",
      "word": "un subjonctif"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le manifeste et soulignez but, ni… ni, doute, chiffres, essentiel."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le manifeste, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire un article du manifeste',
    'PO',
    $c$Objectif
Prononcer un article de l'école de la cour avec les formules du module.

Consigne
Répétez, puis proposez un article à vous, sans nom d'ailleurs.

Support — Modèles d'Aline et de Patrick
Une école qui puisse tenir sous le figuier.
Afin que le Cahier reste le journal.
Elle n'est ni un palais ni une course ni un titre.
Il est essentiel que les deux portes restent ouvertes.
Nous ne pensons pas que ce soit un diplôme.
Il est peu probable qu'un tampon remplace un geste.
On ne compare ni pour trahir ni pour idéaliser.
On ne décide ni trop tôt ni sans thé.
Cela montre que la saison a tenu.
Un manifeste n'est pas un verdict.
C'est une promesse de cour.
Dieudonné : un geste fini.
Lila : trois minutes, une oreille.
Aline : inventée ici, relisible demain.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Un article du manifeste peut mêler but, négation multiple et doute.",
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
  "question": "Quelle phrase ouvre correctement le manifeste ?",
  "options": [
    {
      "text": "Une école qui peut tenir afin que le Cahier est le journal",
      "correct": false
    },
    {
      "text": "Une école qui puisse tenir sous le figuier",
      "correct": true
    },
    {
      "text": "Une école d'ailleurs seulement",
      "correct": false
    },
    {
      "text": "Un verdict obligatoire ce soir",
      "correct": false
    }
  ],
  "explanation": "Qui puisse + lieu inventé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui puisse",
      "right": "tenir sous le figuier"
    },
    {
      "left": "ni… ni… ni…",
      "right": "palais / course / titre"
    },
    {
      "left": "pas un diplôme",
      "right": "Cahier / journal"
    },
    {
      "left": "promesse de cour",
      "right": "manifeste"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUn manifeste n'est pas un ___ .",
  "answer": "verdict"
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
    "promesse",
    "de",
    "cour",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "cour",
  "hint": "École de la… : le lieu inventé, sous le figuier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est essentiel que les deux portes restent ouvertes, et nous ne pensons pas que ce est un diplôme.",
  "correct_sentence": "Il est essentiel que les deux portes restent ouvertes, et nous ne pensons pas que ce soit un diplôme.",
  "explanation": "Ne penser pas que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/main-craie.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/horloge-cours.svg",
      "word": "un objectif"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/coeur-transmission.svg",
      "word": "un subjonctif"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/objectif-relatif.svg",
      "word": "un atelier"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six articles oraux : but, ni… ni, essentiel, doute, chiffre, promesse."
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
    'PE — Mon manifeste éducatif',
    'PE',
    $c$Objectif
Écrire un manifeste pour l'école de la cour, argumenté et local.

Consigne
Imitez le manifeste de Patrick Habimana, sans aller trop vite.

Support — Manifeste de Patrick Habimana
Patrick Habimana — pour l'école de la cour
Je cherche une école qui puisse tenir sous le figuier, afin que le Cahier du chemin reste mon journal, non un diplôme.
Elle n'est ni un palais ni une course ni un titre d'ailleurs : elle est l'atelier de Dieudonné le matin, l'antenne de Lila le jeudi.
Il est essentiel que les deux portes restent ouvertes, encore que je doive un jour choisir un banc.
Je ne pense pas qu'un tampon remplace un geste ; il est peu probable qu'il couse ; il se peut toutefois qu'il rassure.
Il n'est pas sûr que j'en aie besoin demain ; il se peut qu'une page tenue suffise.
Cela montre que la saison a attiré vingt-quatre voix ; on constate que dix-huit pages ont tenu ; ces chiffres indiquent qu'il reste à relancer.
On ne compare ni pour trahir ni pour idéaliser : les mains et l'oreille se répondent.
On ne décide ni trop tôt ni sans thé ni sans avoir entendu Aline.
Ce manifeste n'est pas un verdict : c'est une promesse de cour, relisible au Cahier.
Aucune ville lointaine, aucun nom emprunté. École de la cour, Seuil des Sources.
Patrick
Copie : Aline Uwase, Mado
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick veut que le Cahier devienne un diplôme.",
  "correct": false,
  "explanation": "Il reste son journal, non un diplôme."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où l'école de Patrick se tient-elle le jeudi ?",
  "options": [
    {
      "text": "Dans un palais",
      "correct": false
    },
    {
      "text": "À l'antenne de Lila",
      "correct": true
    },
    {
      "text": "Dans une ville lointaine",
      "correct": false
    },
    {
      "text": "Au Bureau seulement",
      "correct": false
    }
  ],
  "explanation": "« l'antenne de Lila le jeudi. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui puisse tenir",
      "right": "sous le figuier"
    },
    {
      "left": "ni palais ni course ni titre",
      "right": "école de la cour"
    },
    {
      "left": "tampon",
      "right": "peu probable qu'il remplace"
    },
    {
      "left": "promesse de cour",
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
  "prompt": "Complétez :\nEncore que je ___ un jour choisir un banc. (devoir, subj.)",
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
    "C'est",
    "une",
    "promesse",
    "de",
    "cour",
    "."
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
  "hint": "Arbre sous lequel l'école de la cour peut tenir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ne pense pas qu'un tampon remplace un geste, et il se peut que une page tenue suffise.",
  "correct_sentence": "Je ne pense pas qu'un tampon remplace un geste, et il se peut qu'une page tenue suffise.",
  "explanation": "Que + une s'élide : qu'une."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m8/horloge-cours.svg",
      "word": "un objectif"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/coeur-transmission.svg",
      "word": "un subjonctif"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/objectif-relatif.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/subjonctif-opinion.svg",
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
  "prompt": "Imitez : un manifeste de quinze à dix-huit lignes, école de la cour, toutes les formules du module."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre manifeste, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Langue du manifeste éducatif',
    'EL',
    $c$Objectif
Retenir les formules qui portent l'école de la cour.

Consigne
Apprenez la fiche.

Support — Fiche de clôture, école de la cour
L'école de la cour est inventée au Seuil : Atelier d'Aline, Radio Figuier, Cahier du chemin.
Relative de but : une école qui puisse tenir. Afin que + subj. : afin que le journal reste.
Opinion : je ne pense pas que ce soit un diplôme ; il est essentiel que les portes restent ouvertes.
Chiffres : cela montre que ; on constate que ; ces chiffres indiquent que.
Probabilité : peu probable que ; il se peut que ; il n'est pas sûr que — subjonctif.
Ne… ni… ni… : ni palais ni course ni titre ; on ne compare ni pour trahir ni pour idéaliser.
Un manifeste n'est pas un verdict ; c'est une promesse de cour.
Pas de ville lointaine, pas de nom emprunté, pas de diplôme d'ailleurs.
Tampon de cour et feuille de tenue peuvent accompagner ; ils ne remplacent pas le geste.
Attention : puisse / soit / doive / ait / vaille / soient. Il faut (pas je faut).
À + le = au Seuil, au Cahier. Qu'une / qu'il / qu'on.
On signe après le thé, on relit demain.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le manifeste accepte un nom d'école d'ailleurs.",
  "correct": false,
  "explanation": "Pas de nom emprunté, pas de ville lointaine."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série porte correctement le manifeste ?",
  "options": [
    {
      "text": "qui peut (but) / je n'ai pas ni / peu probable que remplacera",
      "correct": false
    },
    {
      "text": "qui puisse / ni palais ni titre / il se peut que la page suffise",
      "correct": true
    },
    {
      "text": "afin que c'est / cela montrent / ni l'un ou l'autre",
      "correct": false
    },
    {
      "text": "je faut / un verdict / une ville lointaine",
      "correct": false
    }
  ],
  "explanation": "Puisse, ni… ni, il se peut que + subj."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "école de la cour",
      "right": "inventée au Seuil"
    },
    {
      "left": "Cahier du chemin",
      "right": "journal"
    },
    {
      "left": "deux portes",
      "right": "atelier / radio"
    },
    {
      "left": "promesse",
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
  "prompt": "Complétez :\nUne école ___ puisse tenir sous le figuier.",
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
    "On",
    "signe",
    "après",
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
  "word": "inventee",
  "hint": "L'école de la cour est… ici, pas ailleurs. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "À le Seuil on signe le manifeste après le thé, et le Cahier reste le journal.",
  "correct_sentence": "Au Seuil on signe le manifeste après le thé, et le Cahier reste le journal.",
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
      "image_path": "/elearning/mfk-b2-m8/coeur-transmission.svg",
      "word": "un subjonctif"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/objectif-relatif.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/subjonctif-opinion.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b2-m8/atelier-aline.svg",
      "word": "un résultat"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez un tableau final : dix articles possibles du manifeste, chacun avec un point de langue."
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
