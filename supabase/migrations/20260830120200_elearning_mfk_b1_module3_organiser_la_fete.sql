/*
  Seed eLearning MFK — B1 — Organiser la fête

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b1-m3/
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
  v_module_title text := 'B1 — Organiser la fête';
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
      'Grande étape B1-3 : proposer une sortie, convaincre un groupe, comparer des fêtes et des coutumes, observer les comportements, préparer concrètement puis faire le bilan — Veillée des Lampions au Marché des Lampions et à la Salle des Herbes, avec le tambour de Sami Niyonteze et le tissu de Rose Iradukunda.',
      'B1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B1-3 : proposer une sortie, convaincre un groupe, comparer des fêtes et des coutumes, observer les comportements, préparer concrètement puis faire le bilan — Veillée des Lampions au Marché des Lampions et à la Salle des Herbes, avec le tambour de Sami Niyonteze et le tissu de Rose Iradukunda.',
      cefr_level = 'B1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Proposer une sortie =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Proposer une sortie'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Proposer une sortie', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Une veillée à proposer',
    'CO',
    $c$Objectif
Comprendre un conseil (tu devrais, si j'étais toi, à ta place) et la mise en relief c'est… qui / que.

Consigne
Lisez le dialogue. Qui conseille Joël ? Sur quoi insiste-t-on ?

Support — Banc du figuier, avant-veille
Léa : Tu devrais venir à la Veillée des Lampions, Joël. C'est Sami qui joue du tambour.
Patrick : Si j'étais toi, je laisserais la moto une soirée. C'est la fête que tout le Seuil attend.
Aline : À ta place, je dirais oui tout de suite. C'est Rose qui a cousu les tissus ocre.
Marc : Tu devrais écouter Radio Figuier : c'est Lila qui a lu l'affiche ce matin.
Hawa : Si j'étais toi, je prendrais un ticket tôt. C'est le cortège que je ne veux pas manquer.
Joël : Je serais plus calme si je savais l'heure. C'est l'horaire qui me bloque.
Karim : À ta place, je demanderais à Solange. C'est elle qui garde les places du banc.
Rose : Tu devrais voir le tissu avant. C'est la cape que Dieudonné a tendue.
Félicie : Si j'étais toi, je viendrais dîner d'abord. C'est la Table des Sources qui ouvre le soir.
Sami : C'est vous qui donnez le rythme, pas seulement le tambour.
Lila : À ta place, Joël, je ne resterais pas sous le capot. C'est la veillée que la cour prépare.
Dieudonné : Tu devrais entrer par la Salle des Herbes. C'est le seuil que j'ai décoré.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "C'est Sami qui joue du tambour, d'après Léa.",
  "correct": true,
  "explanation": "Léa : « C'est Sami qui joue du tambour. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que dit Patrick à Joël ?",
  "options": [
    {
      "text": "Tu dois vendre la moto",
      "correct": false
    },
    {
      "text": "Si j'étais toi, je laisserais la moto une soirée",
      "correct": true
    },
    {
      "text": "C'est Joël qui joue du tambour",
      "correct": false
    },
    {
      "text": "À ta place, je partirais à Val-des-Peupliers",
      "correct": false
    }
  ],
  "explanation": "Patrick : « Si j'étais toi, je laisserais la moto une soirée. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "tu devrais",
      "right": "conseil direct"
    },
    {
      "left": "si j'étais toi",
      "right": "conseil par identification"
    },
    {
      "left": "à ta place",
      "right": "même idée, autre formule"
    },
    {
      "left": "c'est… qui / que",
      "right": "mise en relief"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi j'étais toi, je ___ la moto une soirée. (laisser)",
  "answer": "laisserais"
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
    "devrais",
    "venir",
    "à",
    "la",
    "veillée",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "devrais",
  "hint": "Tu… y aller : conseil, conditionnel de devoir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si j'étais toi, je serai plus calme demain soir, à la Salle des Herbes.",
  "correct_sentence": "Si j'étais toi, je serais plus calme demain soir, à la Salle des Herbes.",
  "explanation": "Après si + imparfait : conditionnel, serais (pas serai)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/sortie-proposee.svg",
      "word": "une sortie"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/affiche-conseil.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/mise-en-relief.svg",
      "word": "un relief"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/lanterne-invitation.svg",
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
  "prompt": "Notez trois conseils et trois mises en relief (qui / que)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Tu devrais venir. Si j'étais toi, je laisserais la moto. À ta place, je dirais oui. C'est Sami qui joue."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Affiche collée au figuier',
    'CE',
    $c$Objectif
Lire une affiche qui conseille et met en relief les rôles.

Consigne
Lisez l'affiche, sans aller trop vite.

Support — Affiche ocre, Marché des Lampions
Veillée des Lampions — Salle des Herbes
Tu devrais arriver avant dix-neuf heures : c'est Félicie qui ouvre la table.
Si j'étais toi, je prendrais le minibus Figuier 7, pas la moto trop tard.
À ta place, j'écouterais Lila Sow : c'est elle qui lit le programme à Radio Figuier.
C'est Sami Niyonteze qui donne le premier coup de tambour.
C'est le tissu de Rose Iradukunda que l'on tend au fond de la salle.
C'est Dieudonné qui a fixé les lanternes, pas n'importe qui.
Tu devrais garder un siège pour Hawa : Yvette a dit qu'elle viendrait si la gorge le permettait.
Si j'étais toi, je n'inviterais pas trop de monde d'un coup : le banc est étroit.
À ta place, je remercierais Karim : c'est lui qui a cédé la clé du local.
C'est la cour du Seuil qui invite, pas une enseigne de passage.
Joël, tu devrais juste poser une clé : c'est l'outil que tu peux laisser.
Solange Mukamana : les places du premier rang, c'est le Bureau des Escales qui les note.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "C'est Dieudonné qui a fixé les lanternes.",
  "correct": true,
  "explanation": "« C'est Dieudonné qui a fixé les lanternes, pas n'importe qui. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui lit le programme à Radio Figuier ?",
  "options": [
    {
      "text": "Rose",
      "correct": false
    },
    {
      "text": "Sami",
      "correct": false
    },
    {
      "text": "Lila Sow",
      "correct": true
    },
    {
      "text": "Joël",
      "correct": false
    }
  ],
  "explanation": "« c'est elle qui lit le programme à Radio Figuier » (Lila Sow)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "tu devrais arriver",
      "right": "avant 19 h"
    },
    {
      "left": "si j'étais toi",
      "right": "minibus Figuier 7"
    },
    {
      "left": "c'est Sami qui",
      "right": "tambour"
    },
    {
      "left": "c'est le tissu que",
      "right": "Rose"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nÀ ta place, j'___ Lila Sow. (écouter)",
  "answer": "écouterais"
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
    "Sami",
    "qui",
    "donne",
    "le",
    "premier",
    "coup",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "place",
  "hint": "À ta… je partirais plus tôt : on se met dans la situation de l'autre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est Rose que a cousu les tissus ocre, pour la Salle des Herbes.",
  "correct_sentence": "C'est Rose qui a cousu les tissus ocre, pour la Salle des Herbes.",
  "explanation": "Rose = sujet du verbe coudre → c'est… qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/affiche-conseil.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/mise-en-relief.svg",
      "word": "un relief"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/lanterne-invitation.svg",
      "word": "une lanterne"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/but-groupe.svg",
      "word": "un but"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez l'affiche et encadrez tu devrais / si j'étais toi / c'est… qui / que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'affiche collée au figuier, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Conseiller et mettre en relief',
    'PO',
    $c$Objectif
Donner un conseil et insister sur un élément avec c'est… qui / que.

Consigne
Répétez, puis conseillez un camarade pour une sortie du Seuil.

Support — Modèles de Marc
Tu devrais venir.
Tu devrais écouter Lila.
Si j'étais toi, je partirais tôt.
Si j'étais toi, je serais plus calme.
À ta place, je dirais oui.
À ta place, je ne resterais pas ici.
C'est Sami qui joue.
C'est Léa qui a proposé.
C'est la veillée que nous préparons.
C'est le tissu que Rose a cousu.
C'est vous qui donnez le rythme.
Je serais d'accord, si l'horaire était clair.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je serais » est un conditionnel, pas un futur.",
  "correct": true,
  "explanation": "Si j'étais toi, je serais plus calme. Futur : je serai."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase met en relief le COD ?",
  "options": [
    {
      "text": "C'est Sami qui joue",
      "correct": false
    },
    {
      "text": "C'est la veillée que nous préparons",
      "correct": true
    },
    {
      "text": "Tu devrais venir",
      "correct": false
    },
    {
      "text": "À ta place, je dirais oui",
      "correct": false
    }
  ],
  "explanation": "Que = COD (la veillée). Qui = sujet."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "tu devrais + inf.",
      "right": "conseil"
    },
    {
      "left": "si + imparfait",
      "right": "conditionnel ensuite"
    },
    {
      "left": "c'est… qui",
      "right": "sujet en relief"
    },
    {
      "left": "c'est… que",
      "right": "COD en relief"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi j'étais toi, je ___ plus calme. (être)",
  "answer": "serais"
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
    "la",
    "veillée",
    "que",
    "nous",
    "préparons",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "serais",
  "hint": "Si j'étais toi, je… plus calme : conditionnel d'être."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "À ta place, je resterai sous le capot pendant toute la veillée, Joël.",
  "correct_sentence": "À ta place, je resterais sous le capot pendant toute la veillée, Joël.",
  "explanation": "Conseil irréel : conditionnel resterais, pas futur resterai."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/mise-en-relief.svg",
      "word": "un relief"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/lanterne-invitation.svg",
      "word": "une lanterne"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/but-groupe.svg",
      "word": "un but"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/pour-que.svg",
      "word": "un souhait"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six conseils (deux de chaque formule) et quatre mises en relief."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les douze modèles, puis deux conseils à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon mot d''invitation',
    'PE',
    $c$Objectif
Écrire un mot qui conseille et met en relief les rôles de la veillée.

Consigne
Imitez le mot d'Hawa.

Support — Mot d'Hawa Diallo
Hawa Diallo
Infirmerie des Herbes — vers la Salle des Herbes
Joël, tu devrais venir, même une heure. C'est Sami qui ouvre au tambour.
Si j'étais toi, je prendrais le minibus, pas la moto trop tard.
À ta place, je garderais un siège près de Yvette, au cas où.
C'est Rose qui a cousu le tissu ocre. C'est ce tissu que l'on verra au fond.
C'est Léa qui a proposé la sortie, pas moi : je transmets.
Tu devrais écouter Lila à Radio Figuier : c'est elle qui lit l'horaire.
Je serais plus rassurée si tu disais oui avant midi.
C'est la cour du Seuil que l'on invite, à Rive-des-Saules comme à Val-des-Peupliers.
Hawa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa dit que c'est elle qui a proposé la sortie.",
  "correct": false,
  "explanation": "« C'est Léa qui a proposé la sortie, pas moi. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel conseil Hawa donne-t-elle sur le transport ?",
  "options": [
    {
      "text": "Prendre la moto tard",
      "correct": false
    },
    {
      "text": "Marcher jusqu'à Val-des-Peupliers",
      "correct": false
    },
    {
      "text": "Prendre le minibus, pas la moto trop tard",
      "correct": true
    },
    {
      "text": "Rester à l'infirmerie",
      "correct": false
    }
  ],
  "explanation": "« Si j'étais toi, je prendrais le minibus, pas la moto trop tard. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "tu devrais venir",
      "right": "conseil"
    },
    {
      "left": "si j'étais toi",
      "right": "minibus"
    },
    {
      "left": "c'est Sami qui",
      "right": "tambour"
    },
    {
      "left": "c'est Léa qui",
      "right": "proposition"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ plus rassurée si tu disais oui. (être)",
  "answer": "serais"
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
    "Rose",
    "qui",
    "a",
    "cousu",
    "le",
    "tissu",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "relief",
  "hint": "C'est Léa qui : on met un mot en…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si j'étais toi, je prendrai le minibus, pas la moto trop tard, Joël.",
  "correct_sentence": "Si j'étais toi, je prendrais le minibus, pas la moto trop tard, Joël.",
  "explanation": "Si + imparfait → conditionnel : prendrais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/lanterne-invitation.svg",
      "word": "une lanterne"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/but-groupe.svg",
      "word": "un but"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/pour-que.svg",
      "word": "un souhait"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/ticket-veillee.svg",
      "word": "un ticket"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : dix lignes, trois formules de conseil et trois c'est… qui / que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot d'invitation, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Conseil et mise en relief',
    'EL',
    $c$Objectif
Retenir tu devrais, si j'étais toi, à ta place, et c'est… qui / que.

Consigne
Apprenez la fiche.

Support — Fiche de Lila
Conseil : tu devrais + infinitif. Tu devrais venir. Vous devriez écouter.
Si + imparfait, conditionnel : si j'étais toi, je partirais / je serais plus calme.
À ta place, je + conditionnel : à ta place, je dirais oui / je ne resterais pas.
Futur je serai ≠ conditionnel je serais. Conseil irréel : serais.
C'est + nom + qui + verbe : c'est Sami qui joue (sujet en relief).
C'est + nom + que + sujet + verbe : c'est la veillée que nous préparons (COD).
Ce sont + pluriel + qui : ce sont les lanternes qui éclairent.
On ne dit pas : c'est Rose que a cousu. On dit : c'est Rose qui a cousu.
Accord : si j'étais (imparfait d'être). Pas : si je serais.
Le conseil reste poli : tu devrais, pas tu dois trop sec ici.
On peut combiner : tu devrais venir, c'est Sami qui joue.
Toujours il faut (si l'on ajoute une obligation) : il faut que tu viennes.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « si je serais toi ».",
  "correct": false,
  "explanation": "Si + imparfait : si j'étais toi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est un conditionnel ?",
  "options": [
    {
      "text": "je serai",
      "correct": false
    },
    {
      "text": "je serais",
      "correct": true
    },
    {
      "text": "je suis",
      "correct": false
    },
    {
      "text": "j'étais",
      "correct": false
    }
  ],
  "explanation": "Je serais = conditionnel. Je serai = futur."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "tu devrais",
      "right": "devoir au conditionnel"
    },
    {
      "left": "si j'étais toi",
      "right": "imparfait + conseil"
    },
    {
      "left": "c'est… qui",
      "right": "sujet"
    },
    {
      "left": "c'est… que",
      "right": "COD"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est la veillée ___ nous préparons.",
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
    "Si",
    "j'étais",
    "toi",
    "je",
    "partirais",
    "tôt",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "etais",
  "hint": "Si j'… toi : imparfait après si (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si je serais toi, je partirais tôt à la Salle des Herbes, Joël.",
  "correct_sentence": "Si j'étais toi, je partirais tôt à la Salle des Herbes, Joël.",
  "explanation": "Après si : imparfait étais, pas conditionnel serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/but-groupe.svg",
      "word": "un but"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/pour-que.svg",
      "word": "un souhait"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/ticket-veillee.svg",
      "word": "un ticket"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/micro-convaincre.svg",
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
  "prompt": "Tableau : trois conseils, deux qui, deux que, une phrase je serais."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six exemples (trois conseils, trois mises en relief)."
}$j$::jsonb,
    9
  );

  -- ===== Convaincre le groupe =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Convaincre le groupe'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Convaincre le groupe', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Convaincre sous le figuier',
    'CO',
    $c$Objectif
Repérer le but : pour, afin de, pour que, afin que, de façon à — et l'info sur la veillée.

Consigne
Lisez le dialogue. Pourquoi organise-t-on la fête ? Qui informe ?

Support — Cour du Seuil, réunion courte
Marc : On se réunit pour danser, pas pour se disputer.
Léa : Afin de réunir Rive-des-Saules et Val-des-Peupliers, on ouvre la Salle des Herbes.
Aline : Je parle pour que Sami puisse jouer au milieu, pas dans un coin.
Patrick : Afin que Rose accroche le tissu, Dieudonné tient l'échelle.
Hawa : On range de façon à laisser un passage, pour les lanternes.
Lila : Radio Figuier informe : la veillée commence à vingt heures, entrée libre.
Karim : Je cède la clé pour que le local reste accessible, pas fermé à double tour.
Joël : Je viens afin de voir, pas afin de réparer la moto.
Félicie : Je cuisine pour que chacun mange un peu, même tard.
Sami : Frappez le tambour de façon à appeler, pas à couvrir les voix.
Solange : Le Bureau des Escales affiche l'heure afin que personne n'arrive à minuit.
Yvette : Hawa s'assoit près de moi pour que je surveille la gorge, sans ruminer.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'entrée de la veillée est libre, d'après Lila.",
  "correct": true,
  "explanation": "Lila : « entrée libre. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi Aline parle-t-elle ?",
  "options": [
    {
      "text": "Pour fermer la salle",
      "correct": false
    },
    {
      "text": "Pour que Sami puisse jouer au milieu",
      "correct": true
    },
    {
      "text": "Afin de vendre des tickets",
      "correct": false
    },
    {
      "text": "Pour réparer la moto",
      "correct": false
    }
  ],
  "explanation": "Aline : « pour que Sami puisse jouer au milieu. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "pour danser",
      "right": "but + infinitif"
    },
    {
      "left": "afin de réunir",
      "right": "but + infinitif"
    },
    {
      "left": "pour que Sami puisse",
      "right": "but + subjonctif"
    },
    {
      "left": "de façon à laisser",
      "right": "but / manière"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe parle pour que Sami ___ jouer au milieu. (pouvoir)",
  "answer": "puisse"
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
    "se",
    "réunit",
    "pour",
    "danser",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "afin",
  "hint": "… de réunir le groupe : but, souvent suivi de de."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je parle pour que Sami peut jouer au milieu, pas dans un coin, sous le figuier.",
  "correct_sentence": "Je parle pour que Sami puisse jouer au milieu, pas dans un coin, sous le figuier.",
  "explanation": "Pour que + subjonctif : puisse (pas peut)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/pour-que.svg",
      "word": "un souhait"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/ticket-veillee.svg",
      "word": "un ticket"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/micro-convaincre.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/coutume-famille.svg",
      "word": "une coutume"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez deux buts à l'infinitif et deux buts au subjonctif, plus une info d'horaire."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On se réunit pour danser. Afin de réunir les rives. Pour que Sami puisse jouer. Radio Figuier informe : vingt heures."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Annonce de Radio Figuier',
    'CE',
    $c$Objectif
Lire une annonce d'événement qui enchaîne buts et informations.

Consigne
Lisez l'annonce, sans aller trop vite.

Support — Feuille de Lila Sow, studio
Radio Figuier — annonce de la Veillée des Lampions
On allume les lanternes pour éclairer la Salle des Herbes, pas la route entière.
Afin de laisser passer le cortège, le Marché des Lampions range les étals à dix-neuf heures.
Aline parle pour que chacun entende Sami Niyonteze au tambour.
Dieudonné tient l'échelle afin que Rose accroche le tissu ocre sans tomber.
On ouvre de façon à accueillir Rive-des-Saules et Val-des-Peupliers.
Horaire : vingt heures. Entrée libre. Bancs limités : Karim cède la clé du local.
Félicie Ndayishimiye cuisine pour que personne ne reste le ventre vide.
Yvette s'installe près d'Hawa afin que la gorge ne force pas.
Solange Mukamana affiche au Bureau des Escales, pour informer les retardataires.
Joël Mugisha vient afin de voir, de façon à ne pas rater le premier coup.
C'est Léa qui a proposé, pour que la cour se retrouve autrement.
On éteint à minuit, afin que le Pavillon du Saule retrouve le silence.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le marché range les étals à dix-neuf heures pour laisser passer le cortège.",
  "correct": true,
  "explanation": "« Afin de laisser passer le cortège, le Marché… range les étals à dix-neuf heures. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À quelle heure commence la veillée ?",
  "options": [
    {
      "text": "Dix-neuf heures",
      "correct": false
    },
    {
      "text": "Vingt heures",
      "correct": true
    },
    {
      "text": "Minuit",
      "correct": false
    },
    {
      "text": "Midi",
      "correct": false
    }
  ],
  "explanation": "« Horaire : vingt heures. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "pour éclairer",
      "right": "lanternes"
    },
    {
      "left": "afin de laisser passer",
      "right": "cortège"
    },
    {
      "left": "pour que chacun entende",
      "right": "tambour"
    },
    {
      "left": "afin que Rose accroche",
      "right": "tissu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAline parle pour que chacun ___ Sami. (entendre)",
  "answer": "entende"
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
    "ouvre",
    "de",
    "façon",
    "à",
    "accueillir",
    "."
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
  "hint": "Pour que Sami… jouer : subjonctif de pouvoir, il."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dieudonné tient l'échelle afin que Rose accroche le tissu ocre et qu'elle ne tombe pas, pour que tout le monde voit.",
  "correct_sentence": "Dieudonné tient l'échelle afin que Rose accroche le tissu ocre et qu'elle ne tombe pas, pour que tout le monde voie.",
  "explanation": "Pour que + subjonctif : voie (pas voit)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/ticket-veillee.svg",
      "word": "un ticket"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/micro-convaincre.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/coutume-famille.svg",
      "word": "une coutume"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/pronoms-en-y.svg",
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
  "prompt": "Recopiez l'annonce et classez : infinitif (pour / afin de / de façon à) vs subjonctif (pour que / afin que)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'annonce de Radio Figuier, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire pour, afin que',
    'PO',
    $c$Objectif
Exprimer un but et informer sur un événement à voix haute.

Consigne
Répétez, puis convainquez le groupe pour une fête du Seuil.

Support — Modèles d'Aline
On se réunit pour danser.
Afin de réunir les deux rives, on ouvre la salle.
Je parle pour que Sami puisse jouer.
Dieudonné tient l'échelle afin que Rose accroche.
On range de façon à laisser un passage.
La veillée commence à vingt heures.
L'entrée est libre.
Je cède la clé pour que le local reste ouvert.
Je cuisine pour que chacun mange.
On affiche afin que personne n'arrive trop tard.
On éteint à minuit, afin que le silence revienne.
Joël vient afin de voir.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Pour / afin de + infinitif ; pour que / afin que + subjonctif.",
  "correct": true,
  "explanation": "Même sujet → infinitif. Changement de sujet → que + subj."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase exige le subjonctif ?",
  "options": [
    {
      "text": "On se réunit pour danser",
      "correct": false
    },
    {
      "text": "Afin de réunir les deux rives, on ouvre",
      "correct": false
    },
    {
      "text": "Je parle pour que Sami puisse jouer",
      "correct": true
    },
    {
      "text": "On range de façon à laisser un passage",
      "correct": false
    }
  ],
  "explanation": "Pour que + subjonctif (sujet différent : je / Sami)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "pour + inf.",
      "right": "même élan, verbe simple"
    },
    {
      "left": "afin de + inf.",
      "right": "but un peu plus formel"
    },
    {
      "left": "pour que + subj.",
      "right": "autre sujet"
    },
    {
      "left": "de façon à + inf.",
      "right": "but et manière"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn affiche afin que personne n'___ trop tard. (arriver)",
  "answer": "arrive"
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
    "parle",
    "pour",
    "que",
    "Sami",
    "puisse",
    "jouer",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "facon",
  "hint": "De… à : but et manière (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je cède la clé pour que le local reste ouvert, afin que Karim peut partir tôt.",
  "correct_sentence": "Je cède la clé pour que le local reste ouvert, afin que Karim puisse partir tôt.",
  "explanation": "Afin que + subjonctif : puisse."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/micro-convaincre.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/coutume-famille.svg",
      "word": "une coutume"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/pronoms-en-y.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/opposition-concession.svg",
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
  "prompt": "Écrivez dix phrases de but : cinq infinitifs, cinq pour que / afin que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les douze modèles, puis une mini-annonce d'événement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon mot pour convaincre',
    'PE',
    $c$Objectif
Écrire un mot qui informe et donne des buts pour rallier le groupe.

Consigne
Imitez le mot de Léa.

Support — Mot de Léa Niyonzima
Léa Niyonzima
Cahier du chemin — Veillée des Lampions
On allume pour éclairer la Salle des Herbes, pas toute la rive.
Afin de réunir Rive-des-Saules et Val-des-Peupliers, venez dès vingt heures.
Je propose cette sortie pour que Sami puisse jouer au milieu.
Dieudonné tiendra l'échelle afin que Rose accroche le tissu sans danger.
On range de façon à laisser un passage aux lanternes.
Lila informera à Radio Figuier : entrée libre, bancs limités.
Karim cède la clé pour que le local reste accessible.
Félicie cuisine afin que chacun mange un peu, même tard.
On éteint à minuit, pour que le Pavillon retrouve le silence.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'entrée est payante, d'après Léa.",
  "correct": false,
  "explanation": "« entrée libre, bancs limités. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi Léa propose-t-elle la sortie ?",
  "options": [
    {
      "text": "Pour fermer Radio Figuier",
      "correct": false
    },
    {
      "text": "Pour que Sami puisse jouer au milieu",
      "correct": true
    },
    {
      "text": "Afin de vendre la moto de Joël",
      "correct": false
    },
    {
      "text": "Pour que Yvette parte",
      "correct": false
    }
  ],
  "explanation": "« pour que Sami puisse jouer au milieu. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "pour éclairer",
      "right": "lanternes"
    },
    {
      "left": "afin de réunir",
      "right": "les deux rives"
    },
    {
      "left": "pour que Sami puisse",
      "right": "tambour au milieu"
    },
    {
      "left": "afin que Rose accroche",
      "right": "tissu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nKarim cède la clé pour que le local ___ accessible. (rester)",
  "answer": "reste"
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
    "éclairer",
    "la",
    "salle",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "veillee",
  "hint": "La nuit des lampions, à la Salle des Herbes (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je propose cette sortie pour que Sami peut jouer au milieu, sous le figuier.",
  "correct_sentence": "Je propose cette sortie pour que Sami puisse jouer au milieu, sous le figuier.",
  "explanation": "Pour que + subjonctif : puisse."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/coutume-famille.svg",
      "word": "une coutume"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/pronoms-en-y.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/opposition-concession.svg",
      "word": "une opposition"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/danse-sources.svg",
      "word": "une danse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : dix lignes, quatre buts différents et deux infos (heure, entrée)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot pour convaincre, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Exprimer le but',
    'EL',
    $c$Objectif
Retenir pour, afin de, pour que, afin que, de façon à.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
Même sujet → infinitif : on allume pour éclairer. Afin de réunir, on ouvre.
De façon à + infinitif : on range de façon à laisser un passage.
Sujet différent → pour que / afin que + subjonctif.
Je parle pour que Sami puisse jouer. Dieudonné tient afin que Rose accroche.
Pouvoir au subjonctif : que je puisse, que tu puisses, qu'il puisse, que nous puissions.
Voir : que je voie, qu'il voie. Rester : qu'il reste. Entendre : qu'il entende.
Afin que personne n'arrive : ne explétif possible après personne.
Informer : horaire, lieu, entrée, qui fait quoi (c'est X qui…).
On ne dit pas : pour que Sami peut. On dit : pour que Sami puisse.
pour ≠ pour que : pour + nom ou infinitif ; pour que + phrase au subj.
afin de / afin que : plus soutenu, même logique.
Toujours il faut, si obligation : il faut que tu viennes pour que ça tienne.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Pour que » se construit avec l'infinitif.",
  "correct": false,
  "explanation": "Pour que + subjonctif. Pour + infinitif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Pouvoir » au subjonctif, il :",
  "options": [
    {
      "text": "peut",
      "correct": false
    },
    {
      "text": "pourra",
      "correct": false
    },
    {
      "text": "puisse",
      "correct": true
    },
    {
      "text": "pouvait",
      "correct": false
    }
  ],
  "explanation": "Qu'il puisse."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "pour / afin de",
      "right": "infinitif"
    },
    {
      "left": "pour que / afin que",
      "right": "subjonctif"
    },
    {
      "left": "de façon à",
      "right": "infinitif"
    },
    {
      "left": "sujet différent",
      "right": "que + subj."
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe parle pour que Sami ___ jouer. (pouvoir)",
  "answer": "puisse"
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
    "de",
    "réunir",
    "les",
    "deux",
    "rives",
    "."
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
  "hint": "Pour, afin de, pour que : on exprime un…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On ouvre la salle afin que tout le monde peut entrer, dès vingt heures.",
  "correct_sentence": "On ouvre la salle afin que tout le monde puisse entrer, dès vingt heures.",
  "explanation": "Afin que + subjonctif : puisse."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/pronoms-en-y.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/opposition-concession.svg",
      "word": "une opposition"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/danse-sources.svg",
      "word": "une danse"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/demonstratif-soiree.svg",
      "word": "un démonstratif"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez : On ouvre. On veut que Sami joue. / Rose accroche. Dieudonné aide."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six buts (trois inf., trois subj.)."
}$j$::jsonb,
    9
  );

  -- ===== Fêtes et coutumes =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Fêtes et coutumes'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Fêtes et coutumes', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Coutumes sous les lanternes',
    'CO',
    $c$Objectif
Comprendre des différences culturelles : en / y, négation, alors que, tandis que, bien que, pourtant.

Consigne
Lisez le dialogue. Qui fait quoi autrement ?

Support — Salle des Herbes, avant le cortège
Rose : Chez nous, on y va en famille, et on en parle dès l'aube.
Hawa : Chez moi, on n'allume jamais trop tôt, alors que Rose a déjà tendu le tissu.
Sami : Je n'en joue qu'après le silence, tandis que Kévin frappe trop vite.
Aline : Bien que la salle soit petite, on y tient tous, pourtant personne ne s'assoit n'importe où.
Patrick : Je n'y suis pas retourné l'an dernier, j'en avais assez ; cette année j'y vais.
Léa : On n'invite ni vendeur ni passant trop pressé, alors que le marché, lui, reste ouvert.
Marc : Yvette n'en sert plus de plat épicé, bien qu'Hawa aille mieux.
Joël : Je n'y connais rien, pourtant je reste.
Félicie : Je n'en prépare que deux plateaux, tandis que Dieudonné en veut trois.
Karim : Bien que j'aie cédé la clé, je n'y entre pas sans frapper.
Lila : Radio Figuier en parle, on y écoute ; pourtant le tambour n'a pas besoin d'antenne.
Dieudonné : On n'y danse pas encore : Sami n'a pas levé les baguettes.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa allume toujours très tôt, comme Rose.",
  "correct": false,
  "explanation": "Hawa : « on n'allume jamais trop tôt, alors que Rose a déjà tendu le tissu. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que dit Aline sur la salle ?",
  "options": [
    {
      "text": "Elle est trop grande",
      "correct": false
    },
    {
      "text": "Bien qu'elle soit petite, on y tient tous",
      "correct": true
    },
    {
      "text": "Personne n'y entre",
      "correct": false
    },
    {
      "text": "On n'y danse jamais",
      "correct": false
    }
  ],
  "explanation": "« Bien que la salle soit petite, on y tient tous. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on y va",
      "right": "à la fête / à la salle"
    },
    {
      "left": "on en parle",
      "right": "de la coutume"
    },
    {
      "left": "alors que / tandis que",
      "right": "opposition"
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
  "prompt": "Complétez :\nBien que la salle ___ petite, on y tient. (être)",
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
    "n'allume",
    "jamais",
    "trop",
    "tôt",
    "."
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
  "hint": "… que : opposition, deux actions en même temps."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que la salle est petite, on y tient tous, pourtant personne ne s'assoit n'importe où.",
  "correct_sentence": "Bien que la salle soit petite, on y tient tous, pourtant personne ne s'assoit n'importe où.",
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
      "image_path": "/elearning/mfk-b1-m3/opposition-concession.svg",
      "word": "une opposition"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/danse-sources.svg",
      "word": "une danse"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/demonstratif-soiree.svg",
      "word": "un démonstratif"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/indefini-chacun.svg",
      "word": "chacun"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez un en, un y, une opposition et une concession entendus."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On y va en famille. On en parle dès l'aube. Alors que Rose a déjà tendu. Bien que la salle soit petite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Cartes de fêtes',
    'CE',
    $c$Objectif
Lire des cartes qui comparent des coutumes familiales.

Consigne
Lisez les cartes, sans aller trop vite.

Support — Cartes épinglées, Salle des Herbes
Carte Rose — On y tend le tissu ocre. On n'en coupe jamais trop. Alors que Hawa attend la nuit.
Carte Hawa — Chez nous on n'allume qu'après le repas, tandis que le Seuil allume dès l'ombre.
Carte Sami — Je n'y frappe qu'après le silence. Bien que les enfants bougent, j'attends.
Carte Aline — On y tient tous, pourtant le banc reste étroit. On n'invite ni trop tôt ni trop fort.
Carte Patrick — J'en parle à Radio Figuier. Je n'y étais pas l'an dernier.
Carte Léa — On n'y danse pas encore. On en discute d'abord, alors que Joël voudrait déjà tourner.
Carte Marc — Bien que Lila y soit, le micro attend Sami. On n'en enregistre que le refrain.
Carte Félicie — Je n'en sers que deux. Tandis que Dieudonné en voudrait davantage.
Carte Karim — Je n'y entre pas sans frapper, bien que j'aie la clé.
Carte Yvette — Hawa n'y reste pas trop debout. Pourtant elle sourit.
Carte Lila — On en informe dès midi. On y écoute à dix-neuf heures trente.
Carte Dieudonné — On n'y accroche rien sans fil. Alors que le vent de Rive-des-Saules insiste.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Chez Hawa, on n'allume qu'après le repas.",
  "correct": true,
  "explanation": "Carte Hawa : « on n'allume qu'après le repas. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quand Sami frappe-t-il, d'après sa carte ?",
  "options": [
    {
      "text": "Dès que les enfants bougent",
      "correct": false
    },
    {
      "text": "Seulement après le silence",
      "correct": true
    },
    {
      "text": "Pendant le repas",
      "correct": false
    },
    {
      "text": "Jamais",
      "correct": false
    }
  ],
  "explanation": "« Je n'y frappe qu'après le silence. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on y tend",
      "right": "tissu / salle"
    },
    {
      "left": "n'en coupe jamais",
      "right": "tissu"
    },
    {
      "left": "tandis que le Seuil",
      "right": "opposition d'heures"
    },
    {
      "left": "bien que j'aie la clé",
      "right": "concession de Karim"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nBien que j'___ la clé, je n'y entre pas sans frapper. (avoir)",
  "answer": "aie"
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
    "n'allume",
    "qu'après",
    "le",
    "repas",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "coutume",
  "hint": "Usage d'une famille, transmis, pas une loi."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que les enfants bougent trop, Sami attend le silence, et il faut que tout le monde est prêt.",
  "correct_sentence": "Bien que les enfants bougent trop, Sami attend le silence, et il faut que tout le monde soit prêt.",
  "explanation": "Il faut que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/danse-sources.svg",
      "word": "une danse"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/demonstratif-soiree.svg",
      "word": "un démonstratif"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/indefini-chacun.svg",
      "word": "chacun"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/comportement-banc.svg",
      "word": "un geste"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez quatre cartes et soulignez en, y, alors que / tandis que, bien que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les douze cartes de fêtes, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Opposer, concéder, reprendre en et y',
    'PO',
    $c$Objectif
Comparer deux coutumes : en / y, négation, opposition, concession.

Consigne
Répétez, puis parlez d'une fête de votre cour.

Support — Modèles de Rose
On y va en famille.
On en parle dès l'aube.
On n'allume jamais trop tôt.
On n'en joue qu'après le silence.
Alors que Rose a déjà tendu, Hawa attend.
Tandis que Kévin frappe, Sami attend.
Bien que la salle soit petite, on y tient.
Pourtant personne ne s'assoit n'importe où.
Je n'y entre pas sans frapper.
Je n'en prépare que deux.
On n'y danse pas encore.
On n'invite ni trop tôt ni trop fort.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Pourtant » se construit souvent sans que, contrairement à « bien que ».",
  "correct": true,
  "explanation": "Pourtant + phrase à l'indicatif. Bien que + subjonctif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase contient une concession au subjonctif ?",
  "options": [
    {
      "text": "Alors que Rose a déjà tendu",
      "correct": false
    },
    {
      "text": "Pourtant personne ne s'assoit n'importe où",
      "correct": false
    },
    {
      "text": "Bien que la salle soit petite",
      "correct": true
    },
    {
      "text": "Tandis que Kévin frappe",
      "correct": false
    }
  ],
  "explanation": "Bien que + subjonctif : soit."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "y",
      "right": "à ce lieu / à cela"
    },
    {
      "left": "en",
      "right": "de cela / une quantité"
    },
    {
      "left": "alors que / tandis que",
      "right": "opposition"
    },
    {
      "left": "bien que",
      "right": "concession + subj."
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ___ parle dès l'aube. (de la fête)",
  "answer": "en"
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
    "la",
    "salle",
    "soit",
    "petite",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pourtant",
  "hint": "Opposition : l'idée contraire, souvent après une virgule."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On y va en famille, et on en parle dès l'aube, bien que Sami est fatigué.",
  "correct_sentence": "On y va en famille, et on en parle dès l'aube, bien que Sami soit fatigué.",
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
      "image_path": "/elearning/mfk-b1-m3/demonstratif-soiree.svg",
      "word": "un démonstratif"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/indefini-chacun.svg",
      "word": "chacun"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/comportement-banc.svg",
      "word": "un geste"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/tasse-celui.svg",
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
  "prompt": "Écrivez huit phrases : deux en, deux y, deux oppositions, deux bien que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les douze modèles, puis une comparaison de deux coutumes."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma carte de coutume',
    'PE',
    $c$Objectif
Écrire une carte qui compare deux façons de fêter.

Consigne
Imitez la carte de Sami.

Support — Carte de Sami Niyonteze
Sami Niyonteze
Tambour — Veillée des Lampions
Chez moi, on n'y frappe qu'après le silence. On en parle peu, on écoute.
Alors que Kévin voudrait déjà danser, j'attends que la salle se taise.
Tandis que Radio Figuier en dit long, le tambour n'y va qu'une fois prêt.
Bien que les enfants bougent, je ne commence pas. Pourtant je souris.
Je n'invite ni précipitation ni micro trop près.
On n'y danse pas encore : Léa l'a dit, et j'y consens.
Je n'en joue jamais trop fort pour couvrir Félicie.
Rose a tendu le tissu ; j'y pense, je n'y touche pas.
Sami
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Sami frappe dès que les enfants bougent.",
  "correct": false,
  "explanation": "« Bien que les enfants bougent, je ne commence pas. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que refuse Sami près du tambour ?",
  "options": [
    {
      "text": "Le tissu de Rose",
      "correct": false
    },
    {
      "text": "La précipitation et le micro trop près",
      "correct": true
    },
    {
      "text": "Le silence",
      "correct": false
    },
    {
      "text": "Léa",
      "correct": false
    }
  ],
  "explanation": "« Je n'invite ni précipitation ni micro trop près. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "n'y frappe qu'après",
      "right": "restriction + y"
    },
    {
      "left": "alors que Kévin",
      "right": "opposition"
    },
    {
      "left": "bien que les enfants",
      "right": "concession"
    },
    {
      "left": "ni… ni",
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
  "prompt": "Complétez :\nOn n'y frappe ___ après le silence.",
  "answer": "qu'"
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
    "n'en",
    "joue",
    "jamais",
    "trop",
    "fort",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "silence",
  "hint": "Sami attend ce calme avant le premier coup."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tandis que Radio Figuier en dit long, le tambour n'y va qu'une fois prêt, bien que je suis patient.",
  "correct_sentence": "Tandis que Radio Figuier en dit long, le tambour n'y va qu'une fois prêt, bien que je sois patient.",
  "explanation": "Bien que + subjonctif : sois."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/indefini-chacun.svg",
      "word": "chacun"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/comportement-banc.svg",
      "word": "un geste"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/tasse-celui.svg",
      "word": "une tasse"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/preparer-veillee.svg",
      "word": "une liste"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : dix lignes, en, y, une opposition, un bien que, une négation ni… ni."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre carte de coutume, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — En, y, opposition, concession',
    'EL',
    $c$Objectif
Retenir en / y, les négations utiles, alors que / tandis que / bien que / pourtant.

Consigne
Apprenez la fiche.

Support — Fiche de Patrick
Y = à ce lieu / à cela : on y va, j'y pense, on y tient, je n'y entre pas.
En = de cela / une quantité : on en parle, j'en joue, je n'en prépare que deux.
Négation : ne… jamais / plus / que / pas encore / ni… ni / sans.
Opposition (indicatif) : alors que, tandis que. Même cadre, deux tableaux.
Concession : bien que + subjonctif. Bien que la salle soit petite. Bien que j'aie la clé.
Pourtant + indicative : pourtant je reste. Pas de que.
On ne dit pas : bien que la salle est. On dit : bien que la salle soit.
alors que ≠ à l'heure (ce n'est pas un moment ici).
en / y se placent avant le verbe : j'en parle, j'y vais. Impératif : vas-y, parles-en.
Après bien que : être → soit / sois / soyons ; avoir → aie / ait / ayons.
Pour lier à la fête : on y danse, on en parle, bien qu'il fasse chaud.
Il faut que + subj. reste disponible : il faut que le silence soit là.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Tandis que » demande le subjonctif.",
  "correct": false,
  "explanation": "Tandis que + indicatif. Bien que + subjonctif."
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
      "text": "Bien que la salle est petite",
      "correct": false
    },
    {
      "text": "Bien que la salle soit petite",
      "correct": true
    },
    {
      "text": "Bien que la salle sera petite",
      "correct": false
    },
    {
      "text": "Bien que la salle être petite",
      "correct": false
    }
  ],
  "explanation": "Bien que + subjonctif : soit."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "y",
      "right": "à / dans ce lieu"
    },
    {
      "left": "en",
      "right": "de cela"
    },
    {
      "left": "alors que",
      "right": "opposition"
    },
    {
      "left": "bien que",
      "right": "concession + subj."
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe n'___ entre pas sans frapper. (à la salle)",
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
    "en",
    "parle",
    "dès",
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
  "word": "concession",
  "hint": "Bien que : on admet un fait, puis on oppose."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On y tient tous, pourtant le banc reste étroit, bien que Karim a cédé la clé.",
  "correct_sentence": "On y tient tous, pourtant le banc reste étroit, bien que Karim ait cédé la clé.",
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
      "image_path": "/elearning/mfk-b1-m3/comportement-banc.svg",
      "word": "un geste"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/tasse-celui.svg",
      "word": "une tasse"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/preparer-veillee.svg",
      "word": "une liste"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/liste-taches.svg",
      "word": "une tâche"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez : Je vais à la salle. / Je parle de la fête. / La salle est petite, on tient."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six exemples (en, y, opposition, concession)."
}$j$::jsonb,
    9
  );

  -- ===== Autour de la soirée =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Autour de la soirée'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Autour de la soirée', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Celle-ci, ceux-là, chacun',
    'CO',
    $c$Objectif
Repérer les démonstratifs (celui-ci / celui-là, celle, ceux) et les indéfinis (chacun, n'importe qui, plusieurs, quiconque).

Consigne
Lisez le dialogue. De qui, de quoi parle-t-on ?

Support — Salle des Herbes, lanternes allumées
Léa : Celle-ci, la lanterne près du tambour, est à Rose. Celle-là, au fond, est à Dieudonné.
Patrick : Celui de Sami, le siège, reste libre. Celui-là, près de la porte, est à Karim.
Aline : Ceux qui dansent déjà, ce sont Joël et Kévin. Celles de Félicie, les tasses, sont chaudes.
Marc : Chacun range sa place. N'importe qui ne prend pas le micro.
Hawa : Plusieurs ont salué Yvette. Quiconque a mal s'assoit, sans discuter.
Rose : Je préfère celui-ci, le fil ocre, pas celui-là trop pâle.
Sami : Celle que Léa a choisie éclaire juste. Celles du marché clignotent trop.
Karim : Ceux du premier banc, Solange les a notés. Chacun montre son nom.
Lila : N'importe qui peut écouter Radio Figuier. Quiconque parle au micro passe par moi.
Félicie : Plusieurs ont déjà mangé. Celle-ci, la louche, reste à la table.
Joël : Je prends celui-là, le plus loin, pour ne pas gêner.
Dieudonné : Chacun tient une lanterne. N'importe qui n'accroche pas sans moi.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La lanterne près du tambour est à Rose.",
  "correct": true,
  "explanation": "Léa : « Celle-ci, la lanterne près du tambour, est à Rose. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui peut parler au micro, d'après Lila ?",
  "options": [
    {
      "text": "N'importe qui, sans prévenir",
      "correct": false
    },
    {
      "text": "Quiconque, mais en passant par Lila",
      "correct": true
    },
    {
      "text": "Seulement Sami",
      "correct": false
    },
    {
      "text": "Personne",
      "correct": false
    }
  ],
  "explanation": "« Quiconque parle au micro passe par moi. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "celui-ci / celle-ci",
      "right": "le plus proche"
    },
    {
      "left": "celui-là / celle-là",
      "right": "plus loin"
    },
    {
      "left": "chacun",
      "right": "tous, un par un"
    },
    {
      "left": "n'importe qui",
      "right": "une personne non choisie"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ range sa place. (tous, un par un)",
  "answer": "Chacun"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Chacun",
    "range",
    "sa",
    "place",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "celui",
  "hint": "…-ci : le plus proche, un démonstratif."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ceux qui dansent déjà, c'est Joël et Kévin, près de la Salle des Herbes.",
  "correct_sentence": "Ceux qui dansent déjà, ce sont Joël et Kévin, près de la Salle des Herbes.",
  "explanation": "Pluriel : ce sont (pas c'est) devant Joël et Kévin."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/tasse-celui.svg",
      "word": "une tasse"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/preparer-veillee.svg",
      "word": "une liste"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/liste-taches.svg",
      "word": "une tâche"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/salle-herbes.svg",
      "word": "une salle"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Listez quatre démonstratifs et quatre indéfinis entendus, avec ce qu'ils reprennent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Celle-ci est à Rose. Celui-là est à Karim. Chacun range sa place. N'importe qui ne prend pas le micro."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Consignes de soirée',
    'CE',
    $c$Objectif
Lire des consignes qui opposent celui-ci / celui-là et encadrent chacun / quiconque.

Consigne
Lisez les consignes, sans aller trop vite.

Support — Feuille d'Aline, entrée de la salle
Salle des Herbes — autour de la soirée
Prenez celle-ci, la lanterne stable. Laissez celle-là, trop fragile, au panier.
Celui de Sami ne se déplace pas. Celui-là, près de Yvette, reste un siège de repos.
Ceux qui portent le tissu passent à gauche. Celles de Rose, les épingles, restent dans la boîte.
Chacun salue en entrant. N'importe qui n'ouvre pas le local : Karim seulement, ou Dieudonné.
Plusieurs peuvent aider Félicie. Quiconque a les mains sales se lave au bac du Seuil.
Celle que Lila tient, la feuille d'horaire, ne se froisse pas.
Ceux du Bureau des Escales, Solange les a listés : pas de place fantôme.
Chacun tient sa tasse. Celle-ci se range ; celle-là, fêlée, se pose à part.
N'importe qui n'invite pas un passant. Quiconque entre a été nommé.
Plusieurs ont déjà un ticket ocre. Celui de Joël est resté sous le capot : il en cherche un autre.
Hawa s'assoit : celle de Yvette, la place, n'est pas un passage.
Dieudonné : ceux-ci, les crochets, oui ; ceux-là, trop fins, non.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "N'importe qui peut ouvrir le local.",
  "correct": false,
  "explanation": "« N'importe qui n'ouvre pas le local : Karim seulement, ou Dieudonné. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait quiconque a les mains sales ?",
  "options": [
    {
      "text": "Prend le micro",
      "correct": false
    },
    {
      "text": "Se lave au bac du Seuil",
      "correct": true
    },
    {
      "text": "Danse au milieu",
      "correct": false
    },
    {
      "text": "Ouvre le local",
      "correct": false
    }
  ],
  "explanation": "« Quiconque a les mains sales se lave au bac du Seuil. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "celle-ci stable",
      "right": "à prendre"
    },
    {
      "left": "celle-là fragile",
      "right": "au panier"
    },
    {
      "left": "chacun salue",
      "right": "entrée"
    },
    {
      "left": "quiconque a les mains",
      "right": "bac du Seuil"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ salue en entrant.",
  "answer": "Chacun"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "N'importe",
    "qui",
    "n'ouvre",
    "pas",
    "le",
    "local",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "chacun",
  "hint": "Toutes les personnes, une par une."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ceux qui portent le tissu passent à gauche, et il faut que chacun saluent en entrant.",
  "correct_sentence": "Ceux qui portent le tissu passent à gauche, et il faut que chacun salue en entrant.",
  "explanation": "Chacun = un par un, verbe au singulier : salue. Subjonctif identique ici."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/preparer-veillee.svg",
      "word": "une liste"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/liste-taches.svg",
      "word": "une tâche"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/salle-herbes.svg",
      "word": "une salle"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/marche-lampions.svg",
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
  "prompt": "Recopiez six consignes et reliez chaque démonstratif ou indéfini à son nom."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les consignes de soirée, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Celui-ci, chacun, quiconque',
    'PO',
    $c$Objectif
Désigner et généraliser : démonstratifs et indéfinis à l'oral.

Consigne
Répétez, puis décrivez la salle pendant une fête.

Support — Modèles de Léa
Celle-ci est à Rose.
Celle-là est à Dieudonné.
Celui de Sami reste libre.
Ceux qui dansent, ce sont Joël et Kévin.
Chacun range sa place.
N'importe qui ne prend pas le micro.
Plusieurs ont salué Yvette.
Quiconque a mal s'assoit.
Je préfère celui-ci, pas celui-là.
Celles de Félicie sont chaudes.
Ceux-ci, les crochets, oui.
Quiconque entre a été nommé.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« N'importe qui » et « quiconque » ne se placent pas toujours dans les mêmes phrases.",
  "correct": true,
  "explanation": "N'importe qui souvent avec restriction (ne… pas). Quiconque = toute personne qui."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est correcte au pluriel ?",
  "options": [
    {
      "text": "C'est Joël et Kévin qui dansent déjà",
      "correct": false
    },
    {
      "text": "Ce sont Joël et Kévin qui dansent déjà",
      "correct": true
    },
    {
      "text": "C'est ceux qui dansent déjà Joël",
      "correct": false
    },
    {
      "text": "Ce Joël et Kévin dansent",
      "correct": false
    }
  ],
  "explanation": "Ce sont + pluriel de personnes."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "celui-ci",
      "right": "proche"
    },
    {
      "left": "celui-là",
      "right": "éloigné"
    },
    {
      "left": "chacun",
      "right": "distribution"
    },
    {
      "left": "quiconque",
      "right": "toute personne qui"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe préfère celui-___, pas celui-là.",
  "answer": "ci"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Quiconque",
    "a",
    "mal",
    "s'assoit",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "quiconque",
  "hint": "Toute personne, un indéfini large."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Chacun rangent sa place avant la danse, près des lanternes ocre.",
  "correct_sentence": "Chacun range sa place avant la danse, près des lanternes ocre.",
  "explanation": "Chacun : verbe au singulier."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/liste-taches.svg",
      "word": "une tâche"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/salle-herbes.svg",
      "word": "une salle"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/marche-lampions.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/apres-fete.svg",
      "word": "un lendemain"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases : quatre démonstratifs, quatre indéfinis."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les douze modèles, puis décrivez quatre objets de la salle."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma note de soirée',
    'PE',
    $c$Objectif
Écrire une note qui désigne (celui-ci / celle-là) et encadre les comportements (chacun, quiconque).

Consigne
Imitez la note de Karim.

Support — Note de Karim Bamba
Karim Bamba
Local de la Salle des Herbes
Celle-ci, la clé du jour, reste sur la table. Celle-là, la clé de nuit, ne sort pas.
Celui de Sami, le siège, ne se déplace pas. Celui-là, près de Yvette, est un repos.
Chacun frappe avant d'entrer. N'importe qui n'emprunte pas le local.
Plusieurs ont déjà rendu une lanterne. Quiconque casse un crochet me prévient.
Ceux qui portent le tissu passent à gauche. Celles de Rose restent dans la boîte.
Je préfère ceux-ci, les crochets larges, pas ceux-là trop fins.
Chacune des tasses de Félicie revient à la table. Celle fêlée se pose à part.
Quiconque parle au micro passe par Lila. Ce n'est pas n'importe qui.
Karim
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La clé de nuit peut sortir, d'après Karim.",
  "correct": false,
  "explanation": "« Celle-là, la clé de nuit, ne sort pas. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui doit prévenir Karim si un crochet casse ?",
  "options": [
    {
      "text": "Seulement Dieudonné",
      "correct": false
    },
    {
      "text": "N'importe qui sans le dire",
      "correct": false
    },
    {
      "text": "Quiconque casse un crochet",
      "correct": true
    },
    {
      "text": "Personne",
      "correct": false
    }
  ],
  "explanation": "« Quiconque casse un crochet me prévient. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "celle-ci / celle-là",
      "right": "deux clés"
    },
    {
      "left": "chacun frappe",
      "right": "entrée"
    },
    {
      "left": "n'importe qui n'emprunte pas",
      "right": "restriction"
    },
    {
      "left": "quiconque casse",
      "right": "prévenir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ frappe avant d'entrer.",
  "answer": "Chacun"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Celle-ci",
    "reste",
    "sur",
    "la",
    "table",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "plusieurs",
  "hint": "Plus d'un, pas tous forcément."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Chacun frappent avant d'entrer, afin que le local reste en ordre, ce soir.",
  "correct_sentence": "Chacun frappe avant d'entrer, afin que le local reste en ordre, ce soir.",
  "explanation": "Chacun : singulier, frappe. Afin que + subjonctif : reste (identique à l'indicatif ici)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/salle-herbes.svg",
      "word": "une salle"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/marche-lampions.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/apres-fete.svg",
      "word": "un lendemain"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/remerciement.svg",
      "word": "un merci"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : dix lignes, trois démonstratifs et trois indéfinis au moins."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre note de soirée, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Démonstratifs et indéfinis',
    'EL',
    $c$Objectif
Retenir celui-ci / celui-là / celle / ceux et chacun, n'importe qui, plusieurs, quiconque.

Consigne
Apprenez la fiche.

Support — Fiche de Marc
Démonstratifs : celui, celle, ceux, celles. + -ci (proche) / -là (loin).
Celui de Sami = le siège de Sami. Celle-ci = cette lanterne-ci.
Ceux qui + verbe : ceux qui dansent. Celles que Rose a cousues.
Ce sont + pluriel de personnes. C'est + singulier (c'est Sami qui…).
Chacun / chacune : un par un, verbe au singulier. Chacun range. Chacune revient.
N'importe qui : une personne non choisie. Souvent avec ne… pas pour limiter.
Plusieurs : plus d'un, quantité vague. Plusieurs ont salué.
Quiconque = toute personne qui. Quiconque a mal s'assoit. Un peu soutenu.
On ne dit pas : chacun rangent. On ne dit pas : c'est Joël et Kévin (on dit ce sont).
celui sans article : pas le celui.
N'importe qui ≠ quiconque : le premier est flou ; le second pose une condition.
Pour la soirée : désigner (celle-ci) puis encadrer (chacun, quiconque).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « le celui de Sami ».",
  "correct": false,
  "explanation": "Celui de Sami, sans article devant celui."
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
      "text": "Chacun rangent",
      "correct": false
    },
    {
      "text": "Chacun range",
      "correct": true
    },
    {
      "text": "Chacun ranger",
      "correct": false
    },
    {
      "text": "Chacun as range",
      "correct": false
    }
  ],
  "explanation": "Chacun + verbe singulier."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "celui-ci",
      "right": "proche"
    },
    {
      "left": "celui-là",
      "right": "loin"
    },
    {
      "left": "chacun",
      "right": "un par un"
    },
    {
      "left": "quiconque",
      "right": "toute personne qui"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCe ___ Joël et Kévin qui dansent. (être au pluriel)",
  "answer": "sont"
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
    "préfère",
    "celui-ci",
    "pas",
    "celui-là",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "indefini",
  "hint": "Chacun, n'importe qui : un… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est Joël et Kévin qui dansent déjà, près du tambour de Sami, ce soir.",
  "correct_sentence": "Ce sont Joël et Kévin qui dansent déjà, près du tambour de Sami, ce soir.",
  "explanation": "Deux personnes : ce sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/marche-lampions.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/apres-fete.svg",
      "word": "un lendemain"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/remerciement.svg",
      "word": "un merci"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/photo-groupe.svg",
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
  "prompt": "Remplacez : cette lanterne-ci / ces sièges-là / toutes les personnes une à une / toute personne qui a mal."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et huit exemples (quatre démonstratifs, quatre indéfinis)."
}$j$::jsonb,
    9
  );

  -- ===== Préparer la veillée =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Préparer la veillée'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Préparer la veillée', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La liste avant vingt heures',
    'CO',
    $c$Objectif
Comprendre une organisation concrète qui reprend conseil, but, rôles et objets.

Consigne
Lisez le dialogue. Qui fait quoi, pour que la veillée tienne ?

Support — Salle des Herbes, après-midi
Aline : Tu devrais cocher la liste, Léa. C'est toi qui as proposé : tu suis.
Léa : Si j'étais toi, Joël, je porterais les bancs. C'est le passage que l'on doit garder.
Rose : J'apporte celui-ci, le tissu ocre, afin que Dieudonné l'accroche sans chercher.
Sami : Je n'y frappe qu'après le silence, pour que chacun entende le premier coup.
Félicie : Je ne sers que deux plateaux, de façon à tenir jusqu'à minuit.
Karim : Celle-ci, la clé, reste sur la table. N'importe qui ne l'emprunte pas.
Lila : Radio Figuier informe pour que Val-des-Peupliers n'arrive pas à vingt et une heures.
Hawa : Yvette a dit de m'asseoir. Plusieurs peuvent m'apporter de l'eau, pas n'importe quel verre.
Marc : C'est le micro que tu poses là, Lila, pas celui-là trop près du tambour.
Dieudonné : Quiconque monte à l'échelle me prévient. Je tiens afin que Rose ne tombe pas.
Patrick : On range sans crier, bien que le temps soit court.
Solange : Le Bureau note ceux du premier rang, pour que personne n'invente une place.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "C'est Léa qui a proposé, donc elle suit la liste, d'après Aline.",
  "correct": true,
  "explanation": "Aline : « C'est toi qui as proposé : tu suis. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait Sami, et pourquoi ?",
  "options": [
    {
      "text": "Il frappe tout de suite pour couvrir les voix",
      "correct": false
    },
    {
      "text": "Il n'y frappe qu'après le silence, pour que chacun entende",
      "correct": true
    },
    {
      "text": "Il range les tasses",
      "correct": false
    },
    {
      "text": "Il prend la clé",
      "correct": false
    }
  ],
  "explanation": "Sami : « Je n'y frappe qu'après le silence, pour que chacun entende. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "tu devrais cocher",
      "right": "conseil à Léa"
    },
    {
      "left": "afin que Dieudonné l'accroche",
      "right": "but du tissu"
    },
    {
      "left": "celle-ci, la clé",
      "right": "démonstratif concret"
    },
    {
      "left": "quiconque monte",
      "right": "règle d'échelle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'apporte le tissu afin que Dieudonné l'___. (accrocher)",
  "answer": "accroche"
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
    "devrais",
    "cocher",
    "la",
    "liste",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "taches",
  "hint": "Liste des… : ce qu'il faut faire (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je n'y frappe qu'après le silence, pour que chacun entend le premier coup, dans la salle.",
  "correct_sentence": "Je n'y frappe qu'après le silence, pour que chacun entende le premier coup, dans la salle.",
  "explanation": "Pour que + subjonctif : entende."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/apres-fete.svg",
      "word": "un lendemain"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/remerciement.svg",
      "word": "un merci"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/photo-groupe.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/balai-lendemain.svg",
      "word": "un balai"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Dressez la liste des rôles : nom, objet, but (pour / pour que)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Tu devrais cocher la liste. J'apporte celui-ci afin que Dieudonné l'accroche. Quiconque monte à l'échelle me prévient."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Liste de tâches ocre',
    'CE',
    $c$Objectif
Lire une liste d'organisation qui synthétise les outils du module.

Consigne
Lisez la liste, sans aller trop vite.

Support — Cahier du chemin, page Veillée
Liste — Veillée des Lampions, Salle des Herbes
1. Léa coche. C'est elle qui a proposé. Tu devrais tout relire avant dix-neuf heures.
2. Joël porte les bancs afin de garder le passage. Si j'étais toi, j'en mettrais deux de côté.
3. Rose : celui-ci, le tissu. Dieudonné accroche pour que la salle ait un fond ocre.
4. Sami n'y frappe qu'après le silence. Bien que les enfants bougent, on attend.
5. Félicie ne sert que deux plateaux, sans troisième service.
6. Karim : celle-ci sur la table. N'importe qui n'ouvre pas. Quiconque emprunte signe.
7. Lila informe à Radio Figuier, de façon à prévenir Rive-des-Saules et Val-des-Peupliers.
8. Yvette a dit de garder un siège. Hawa s'y assoit. Plusieurs apportent de l'eau.
9. Marc pose celui-ci, le micro, pas celui-là trop près. C'est Lila qui parle d'abord.
10. Solange note ceux du premier rang, afin que personne n'invente une place.
11. On range sans crier. On n'invite ni passant ni vendeur trop pressé.
12. On éteint à minuit pour que le Pavillon du Saule retrouve le calme.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On éteint à minuit pour que le Pavillon retrouve le calme.",
  "correct": true,
  "explanation": "Point 12 de la liste."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui doit signer s'il emprunte, d'après le point 6 ?",
  "options": [
    {
      "text": "N'importe qui, sans trace",
      "correct": false
    },
    {
      "text": "Quiconque emprunte",
      "correct": true
    },
    {
      "text": "Seulement Rose",
      "correct": false
    },
    {
      "text": "Personne",
      "correct": false
    }
  ],
  "explanation": "« Quiconque emprunte signe. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est elle qui a proposé",
      "right": "Léa"
    },
    {
      "left": "celui-ci, le tissu",
      "right": "Rose"
    },
    {
      "left": "celle-ci sur la table",
      "right": "clé / Karim"
    },
    {
      "left": "ceux du premier rang",
      "right": "Solange"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDieudonné accroche pour que la salle ___ un fond ocre. (avoir)",
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
    "On",
    "éteint",
    "à",
    "minuit",
    "pour",
    "que",
    "le",
    "Pavillon",
    "retrouve",
    "le",
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
  "word": "tambour",
  "hint": "Sami le porte : instrument de la veillée."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dieudonné accroche pour que la salle a un fond ocre, dès dix-neuf heures.",
  "correct_sentence": "Dieudonné accroche pour que la salle ait un fond ocre, dès dix-neuf heures.",
  "explanation": "Pour que + subjonctif : ait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/remerciement.svg",
      "word": "un merci"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/photo-groupe.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/balai-lendemain.svg",
      "word": "un balai"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/radio-figuier.svg",
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
  "prompt": "Recopiez la liste et marquez conseil / but / démonstratif / indéfini."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la liste de tâches ocre, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Répartir les tâches',
    'PO',
    $c$Objectif
Organiser à voix haute : qui fait quoi, avec quel objet, dans quel but.

Consigne
Répétez, puis répartissez une veillée inventée.

Support — Modèles d'Aline
Tu devrais cocher la liste.
C'est Léa qui suit.
J'apporte celui-ci, le tissu.
Dieudonné accroche afin que le fond tienne.
Sami n'y frappe qu'après le silence.
Chacun range sa place.
N'importe qui n'ouvre pas le local.
Quiconque monte me prévient.
On informe pour que les rives arrivent à l'heure.
On ne sert que deux plateaux.
On range sans crier.
On éteint à minuit, pour que le silence revienne.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Une bonne liste mêle personnes, objets et buts.",
  "correct": true,
  "explanation": "Qui / quoi / pour que…"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase pose un but au subjonctif ?",
  "options": [
    {
      "text": "Tu devrais cocher la liste",
      "correct": false
    },
    {
      "text": "On ne sert que deux plateaux",
      "correct": false
    },
    {
      "text": "On informe pour que les rives arrivent à l'heure",
      "correct": true
    },
    {
      "text": "On range sans crier",
      "correct": false
    }
  ],
  "explanation": "Pour que les rives arrivent : subjonctif (identique à l'indicatif pour -er, 3e pers. pl.)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "tu devrais",
      "right": "lancer la tâche"
    },
    {
      "left": "celui-ci",
      "right": "désigner l'objet"
    },
    {
      "left": "afin que / pour que",
      "right": "but"
    },
    {
      "left": "chacun / quiconque",
      "right": "règle collective"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nQuiconque monte me ___. (prévenir)",
  "answer": "prévient"
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
    "Léa",
    "qui",
    "suit",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tissu",
  "hint": "Rose l'apporte : étoffe ocre de l'atelier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On informe pour que les rives arrivent à l'heure, et il faut que Lila lit l'annonce.",
  "correct_sentence": "On informe pour que les rives arrivent à l'heure, et il faut que Lila lise l'annonce.",
  "explanation": "Il faut que + subjonctif : lise."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/photo-groupe.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/balai-lendemain.svg",
      "word": "un balai"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/figuier-fete.svg",
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
  "prompt": "Écrivez une liste orale de dix tâches, une phrase chacune."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les douze modèles, puis votre répartition (six rôles)."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma liste de veillée',
    'PE',
    $c$Objectif
Écrire une liste concrète : rôles, objets, buts, règles.

Consigne
Imitez la liste de Dieudonné.

Support — Liste de Dieudonné Hakizimana
Dieudonné Hakizimana
Atelier du Tissu — Salle des Herbes
Tu devrais me passer celui-ci, le crochet large, pas celui-là trop fin.
C'est Rose qui tient le tissu. Je monte afin qu'elle n'ait pas à grimper.
Quiconque s'approche de l'échelle me prévient. N'importe qui n'y grimpe pas.
Sami n'y frappe qu'après le silence, pour que chacun entende.
Félicie ne sert que deux plateaux. Je n'en demande plus un troisième.
Karim laisse celle-ci, la clé, sur la table. Je ferme dès l'ombre.
Lila informe à Radio Figuier, de façon à ce que Val-des-Peupliers parte à temps.
On range sans crier, bien que le temps soit court.
On éteint à minuit pour que le Pavillon du Saule souffle.
Dieudonné
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné veut que Rose grimpe à sa place.",
  "correct": false,
  "explanation": "« Je monte afin qu'elle n'ait pas à grimper. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel crochet Dieudonné demande-t-il ?",
  "options": [
    {
      "text": "Celui-là trop fin",
      "correct": false
    },
    {
      "text": "Celui-ci, le crochet large",
      "correct": true
    },
    {
      "text": "N'importe lequel",
      "correct": false
    },
    {
      "text": "Celui de Sami",
      "correct": false
    }
  ],
  "explanation": "« celui-ci, le crochet large, pas celui-là trop fin. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "celui-ci / celui-là",
      "right": "deux crochets"
    },
    {
      "left": "afin qu'elle n'ait pas",
      "right": "but de sécurité"
    },
    {
      "left": "quiconque s'approche",
      "right": "règle d'échelle"
    },
    {
      "left": "pour que chacun entende",
      "right": "but du silence"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe monte afin qu'elle n'___ pas à grimper. (avoir)",
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
    "Je",
    "monte",
    "afin",
    "qu'elle",
    "n'ait",
    "pas",
    "à",
    "grimper",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lanterne",
  "hint": "Lumière de papier, prête pour le cortège."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je monte afin qu'elle n'a pas à grimper, près du fond ocre de la salle.",
  "correct_sentence": "Je monte afin qu'elle n'ait pas à grimper, près du fond ocre de la salle.",
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
      "image_path": "/elearning/mfk-b1-m3/balai-lendemain.svg",
      "word": "un balai"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/figuier-fete.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/rose-tissu.svg",
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
  "prompt": "Imitez : dix lignes, un conseil, deux buts, deux démonstratifs, un indéfini."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre liste de veillée, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Synthèse d''organisation',
    'EL',
    $c$Objectif
Relier conseil, mise en relief, but, démonstratifs et indéfinis pour une liste efficace.

Consigne
Apprenez la fiche.

Support — Fiche de la Salle des Herbes
Lancer : tu devrais / si j'étais toi / à ta place + conditionnel (je serais, je porterais).
Désigner le responsable : c'est Léa qui / c'est le micro que.
Désigner l'objet : celui-ci, celle-là, ceux du premier rang.
But, même sujet : pour / afin de / de façon à + infinitif.
But, autre sujet : pour que / afin que + subjonctif (puisse, ait, entende, voie).
Règle collective : chacun + singulier ; n'importe qui + souvent ne… pas ; quiconque + condition.
Concession du stress : bien que le temps soit court, on range sans crier.
Informer : horaire, entrée, qui parle (Radio Figuier, Lila).
Un seul il faut : il faut que tu coches / il faut cocher.
Ne pas empiler trop d'outils dans la même phrase.
La liste se lit à voix haute, une tâche, une pause.
Après minuit : autre séquence, le bilan.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« De façon à ce que » se construit avec le subjonctif.",
  "correct": true,
  "explanation": "De façon à + inf. ; de façon à ce que + subj. (Lila, Val-des-Peupliers)."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série va avec un changement de sujet ?",
  "options": [
    {
      "text": "pour, afin de, de façon à",
      "correct": false
    },
    {
      "text": "pour que, afin que",
      "correct": true
    },
    {
      "text": "tu devrais, à ta place",
      "correct": false
    },
    {
      "text": "celui-ci, celle-là",
      "correct": false
    }
  ],
  "explanation": "Pour que / afin que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est… qui",
      "right": "rôle"
    },
    {
      "left": "celui-ci",
      "right": "objet"
    },
    {
      "left": "pour que + subj.",
      "right": "but"
    },
    {
      "left": "chacun / quiconque",
      "right": "règle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est Léa ___ a proposé.",
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
  "word": "organisation",
  "hint": "Répartir les rôles, les heures, les objets."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On éteint à minuit pour que le Pavillon retrouve le calme, et je serai d'accord si Joël aidait.",
  "correct_sentence": "On éteint à minuit pour que le Pavillon retrouve le calme, et je serais d'accord si Joël aidait.",
  "explanation": "Si + imparfait → conditionnel serais, pas futur serai."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/figuier-fete.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/rose-tissu.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/sami-tambour.svg",
      "word": "un tambour"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau : tâche / qui / objet / but / outil grammatical."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et une mini-liste de cinq tâches liées."
}$j$::jsonb,
    9
  );

  -- ===== Après la fête =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Après la fête'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Après la fête', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le lendemain sous le figuier',
    'CO',
    $c$Objectif
Comprendre un bilan oral : raconter, remercier, évaluer.

Consigne
Lisez le dialogue. Qu'est-ce qui a marché ? Que reste-t-il à faire ?

Support — Cour du Seuil, matin ocre
Léa : C'est Sami qui a tenu le silence, donc le premier coup a porté. Merci à lui.
Patrick : Si j'étais Joël, je serais fier : tu as porté les bancs afin que le passage reste.
Aline : Bien que la salle ait été petite, on y a tenu. Pourtant deux tasses se sont fêlées.
Rose : Celle-ci, la cape, a tenu. Celle-là, trop fine, non. Merci à Dieudonné.
Hawa : Yvette m'a dit de m'asseoir. Je suis contente qu'elle ait veillé. Plusieurs m'ont saluée.
Marc : Lila a informé pour que Val-des-Peupliers arrive à l'heure. Quiconque était perdu l'a entendue.
Karim : N'importe qui n'a pas pris la clé. Chacun a signé. C'est pourquoi le local est intact.
Félicie : Je n'en ai servi que deux, si bien que rien n'a manqué. Merci à ceux qui ont rangé.
Joël : Tu devrais garder cette heure-là, Sami. C'est le rythme que la cour a aimé.
Sami : J'en joue encore dans la tête. Je n'y retournerais pas sans vous.
Solange : Le Bureau remercie. Il faut que Lila dépose le bilan, afin que l'on s'en souvienne.
Dieudonné : On balaie pour que le figuier reste une cour, pas une salle trop tard.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Deux tasses se sont fêlées, malgré une salle qui a tenu.",
  "correct": true,
  "explanation": "Aline : « Bien que la salle ait été petite, on y a tenu. Pourtant deux tasses se sont fêlées. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que doit faire Lila, d'après Solange ?",
  "options": [
    {
      "text": "Rejouer du tambour",
      "correct": false
    },
    {
      "text": "Déposer le bilan, afin que l'on s'en souvienne",
      "correct": true
    },
    {
      "text": "Vendre des tickets",
      "correct": false
    },
    {
      "text": "Ouvrir le local la nuit",
      "correct": false
    }
  ],
  "explanation": "« Il faut que Lila dépose le bilan, afin que l'on s'en souvienne. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est Sami qui a tenu",
      "right": "récit en relief"
    },
    {
      "left": "merci à Dieudonné",
      "right": "remerciement"
    },
    {
      "left": "bien que la salle ait été",
      "right": "concession au passé"
    },
    {
      "left": "il faut que Lila dépose",
      "right": "bilan à écrire"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut que Lila ___ le bilan. (déposer)",
  "answer": "dépose"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Merci",
    "à",
    "ceux",
    "qui",
    "ont",
    "rangé",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "balai",
  "hint": "On l'attrape le matin : pour la cour, après la danse."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que la salle a été petite, on y a tenu, pourtant deux tasses se sont fêlées.",
  "correct_sentence": "Bien que la salle ait été petite, on y a tenu, pourtant deux tasses se sont fêlées.",
  "explanation": "Bien que + subjonctif passé : ait été."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/figuier-fete.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/rose-tissu.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/sami-tambour.svg",
      "word": "un tambour"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/horloge-soir.svg",
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
  "prompt": "Notez un succès, un regret, deux mercis et une tâche du lendemain."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : C'est Sami qui a tenu le silence. Merci à Dieudonné. Bien que la salle ait été petite, on y a tenu. Il faut que Lila dépose le bilan."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Bilan collé au figuier',
    'CE',
    $c$Objectif
Lire un bilan écrit : récit, remerciements, suite.

Consigne
Lisez le bilan, sans aller trop vite.

Support — Feuille de Lila Sow, Radio Figuier
Bilan — Veillée des Lampions
C'est Léa qui avait proposé. C'est la cour que l'on a retrouvée, pas une foule inconnue.
Sami n'y a frappé qu'après le silence, si bien que chacun a entendu. Merci à lui.
Rose a tendu celui-ci, le tissu ocre. Dieudonné a tenu l'échelle afin qu'elle n'ait pas à monter.
Félicie n'en a servi que deux. Pourtant personne n'est resté le ventre vide.
Bien que la salle ait été étroite, on y a dansé. Alors que Joël doutait, il a porté les bancs.
Karim : n'importe qui n'a pas pris la clé. Quiconque entrait signait. Le local est intact.
Hawa s'est assise : je suis contente qu'Yvette ait veillé. Plusieurs l'ont saluée.
On a éteint à minuit pour que le Pavillon du Saule retrouve le calme.
Il faut que nous balayions avant midi. Solange a dit de déposer cette feuille au Bureau.
On n'invite plus de cortège sans liste, c'est pourquoi celle de Léa restera au Cahier du chemin.
Merci à Radio Figuier, à Rive-des-Saules, à Val-des-Peupliers.
Lila Sow — lendemain ocre
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Personne n'est resté le ventre vide, même avec deux plateaux.",
  "correct": true,
  "explanation": "« Félicie n'en a servi que deux. Pourtant personne n'est resté le ventre vide. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il faire avant midi ?",
  "options": [
    {
      "text": "Rejouer",
      "correct": false
    },
    {
      "text": "Balayer",
      "correct": true
    },
    {
      "text": "Ouvrir le marché",
      "correct": false
    },
    {
      "text": "Partir à moto",
      "correct": false
    }
  ],
  "explanation": "« Il faut que nous balayions avant midi. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est Léa qui avait proposé",
      "right": "origine"
    },
    {
      "left": "merci à lui",
      "right": "Sami"
    },
    {
      "left": "afin qu'elle n'ait pas",
      "right": "Rose / échelle"
    },
    {
      "left": "il faut que nous balayions",
      "right": "lendemain"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut que nous ___ avant midi. (balayer)",
  "answer": "balayions"
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
    "balayions",
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
  "word": "bilan",
  "hint": "On reprend ce qui a marché, ce qui reste."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut que nous balayons avant midi, afin que la cour soit nette, sous le figuier.",
  "correct_sentence": "Il faut que nous balayions avant midi, afin que la cour soit nette, sous le figuier.",
  "explanation": "Balayer au subjonctif, nous : balayions (pas balayons)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/rose-tissu.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/sami-tambour.svg",
      "word": "un tambour"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/horloge-soir.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/coeur-fete.svg",
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
  "prompt": "Recopiez le bilan : soulignez un récit, un merci, un but, une suite."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le bilan collé au figuier, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Raconter, remercier, conclure',
    'PO',
    $c$Objectif
Faire un bilan oral : mise en relief au passé, merci, suite au subjonctif.

Consigne
Répétez, puis racontez une fête du Seuil.

Support — Modèles de Léa
C'est Sami qui a tenu le silence.
C'est la cour que l'on a retrouvée.
Merci à Rose.
Merci à ceux qui ont rangé.
Bien que la salle ait été petite, on y a tenu.
Pourtant deux tasses se sont fêlées.
Je suis contente qu'Yvette ait veillé.
Il faut que nous balayions.
On a éteint pour que le silence revienne.
Je n'en servirais plus trois, si j'étais Félicie.
Tu devrais garder cette heure-là.
Quiconque voudra relire passera au Cahier du chemin.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le bilan mêle passé (récit) et subjonctif (suite).",
  "correct": true,
  "explanation": "A tenu / ait été / il faut que nous balayions."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase remercie un groupe ?",
  "options": [
    {
      "text": "C'est Sami qui a tenu le silence",
      "correct": false
    },
    {
      "text": "Merci à ceux qui ont rangé",
      "correct": true
    },
    {
      "text": "Il faut que nous balayions",
      "correct": false
    },
    {
      "text": "Pourtant deux tasses se sont fêlées",
      "correct": false
    }
  ],
  "explanation": "Merci à ceux qui…"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est… qui a",
      "right": "récit en relief"
    },
    {
      "left": "merci à",
      "right": "gratitude"
    },
    {
      "left": "bien que + subj. passé",
      "right": "concession"
    },
    {
      "left": "il faut que nous balayions",
      "right": "suite"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe suis contente qu'Yvette ___ veillé. (avoir)",
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
    "Merci",
    "à",
    "Rose",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "remercier",
  "hint": "Dire sa gratitude à Rose, à Sami, à Félicie."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis contente qu'Yvette a veillé, toute la soirée, près d'Hawa.",
  "correct_sentence": "Je suis contente qu'Yvette ait veillé, toute la soirée, près d'Hawa.",
  "explanation": "Je suis content(e) que + subjonctif : ait veillé."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/sami-tambour.svg",
      "word": "un tambour"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/horloge-soir.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/coeur-fete.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/sortie-proposee.svg",
      "word": "une sortie"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un bilan oral de dix phrases : trois récits, trois mercis, deux regrets, deux suites."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les douze modèles, puis votre bilan en six phrases."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon mot de remerciement',
    'PE',
    $c$Objectif
Écrire un mot qui raconte, remercie et propose une suite.

Consigne
Imitez le mot de Rose.

Support — Mot de Rose Iradukunda
Rose Iradukunda
Atelier du Tissu — lendemain de veillée
C'est Sami qui a tenu le silence, donc le tissu a pu se voir. Merci à lui.
C'est Dieudonné qui a tenu l'échelle, afin que je n'aie pas à monter. Merci.
Bien que la salle ait été petite, celle-ci, la cape, a tenu. Celle-là, non.
Je suis contente que Léa ait proposé. J'ai peur que l'on oublie la liste : il faut qu'on la recopie.
Chacun a rangé. N'importe qui n'a pas emporté un crochet. Quiconque en trouve un me le rend.
Félicie n'en a servi que deux, pourtant la table a suffi. Merci à ceux qui ont lavé.
On a éteint pour que le Pavillon souffle. Il faut que nous balayions avant midi.
Si j'étais Lila, je serais fière de l'annonce : Val-des-Peupliers est arrivé à l'heure.
Rose
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose veut que l'on recopie la liste, de peur qu'on l'oublie.",
  "correct": true,
  "explanation": "« J'ai peur que l'on oublie la liste : il faut qu'on la recopie. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "De qui Rose serait-elle fière, si elle était à sa place ?",
  "options": [
    {
      "text": "Joël",
      "correct": false
    },
    {
      "text": "Karim",
      "correct": false
    },
    {
      "text": "Lila",
      "correct": true
    },
    {
      "text": "Yvette",
      "correct": false
    }
  ],
  "explanation": "« Si j'étais Lila, je serais fière de l'annonce. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est Sami qui",
      "right": "récit"
    },
    {
      "left": "merci à lui",
      "right": "tambour"
    },
    {
      "left": "afin que je n'aie pas",
      "right": "échelle"
    },
    {
      "left": "il faut que nous balayions",
      "right": "suite"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi j'étais Lila, je ___ fière de l'annonce. (être)",
  "answer": "serais"
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
    "qu'on",
    "la",
    "recopie",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lendemain",
  "hint": "Le jour après la veillée, le balai à la main."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si j'étais Lila, je serai fière de l'annonce, car Val-des-Peupliers est arrivé à l'heure.",
  "correct_sentence": "Si j'étais Lila, je serais fière de l'annonce, car Val-des-Peupliers est arrivé à l'heure.",
  "explanation": "Si + imparfait → conditionnel : serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/horloge-soir.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/coeur-fete.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/sortie-proposee.svg",
      "word": "une sortie"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/affiche-conseil.svg",
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
  "prompt": "Imitez : dix lignes, un récit en relief, deux mercis, un que + subj., un je serais."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot de remerciement, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Raconter, remercier, boucler',
    'EL',
    $c$Objectif
Retenir les formes du bilan : relief au passé, subjonctif passé, merci, suite.

Consigne
Apprenez la fiche.

Support — Fiche du lendemain
Raconter : c'est X qui a + participe. C'est la cour que l'on a retrouvée.
Remercier : merci à + nom. Merci à ceux qui ont rangé. On peut nommer l'objet (le silence, l'échelle).
Concession au passé : bien que la salle ait été petite (avoir : ait été).
Sentiment au passé : je suis content(e) qu'elle ait veillé / que Léa ait proposé.
Suite : il faut que nous balayions / qu'on recopie. Pour que le Pavillon souffle.
Conditionnel de bilan : si j'étais Lila, je serais fière. Pas : je serai.
Y / en au passé : on y a tenu, je n'en ai servi que deux, j'en joue encore dans la tête.
Indéfinis : chacun a rangé ; n'importe qui n'a pas pris la clé ; quiconque voudra relire.
Un bilan tient sur une feuille : succès, limite, merci, tâche.
Toujours il faut, 3e personne.
On dépose au Bureau des Escales, afin que l'on s'en souvienne.
Le figuier redevient une cour : on balaie, on remercie, on note.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Bien que la salle ait été petite » est un subjonctif passé.",
  "correct": true,
  "explanation": "Ait été = avoir au subjonctif + été."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est un conditionnel de bilan ?",
  "options": [
    {
      "text": "Je serai fière demain sans condition",
      "correct": false
    },
    {
      "text": "Si j'étais Lila, je serais fière",
      "correct": true
    },
    {
      "text": "Je suis fière",
      "correct": false
    },
    {
      "text": "Il faut que je sois fière",
      "correct": false
    }
  ],
  "explanation": "Si + imparfait + conditionnel."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est… qui a",
      "right": "récit"
    },
    {
      "left": "merci à",
      "right": "gratitude"
    },
    {
      "left": "ait été / ait veillé",
      "right": "subjonctif passé"
    },
    {
      "left": "il faut que nous balayions",
      "right": "suite"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nBien que la salle ___ été petite. (avoir)",
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
    "C'est",
    "Sami",
    "qui",
    "a",
    "tenu",
    "le",
    "silence",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "souvenir",
  "hint": "Ce qui reste dans la tête, et sur la photo."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis contente que Léa a proposé la veillée, et que Sami a tenu le silence.",
  "correct_sentence": "Je suis contente que Léa ait proposé la veillée, et que Sami ait tenu le silence.",
  "explanation": "Je suis content(e) que + subjonctif : ait proposé, ait tenu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m3/coeur-fete.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/sortie-proposee.svg",
      "word": "une sortie"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/affiche-conseil.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-b1-m3/mise-en-relief.svg",
      "word": "un relief"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez six formules de bilan réutilisables (récit, merci, concession, suite)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et un bilan personnel en cinq phrases liées."
}$j$::jsonb,
    9
  );

END;
$$;
