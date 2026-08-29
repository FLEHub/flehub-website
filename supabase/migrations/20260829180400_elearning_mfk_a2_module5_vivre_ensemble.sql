/*
  Seed eLearning MFK — A2 — Vivre ensemble autrement

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a2-m5/
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
  v_module_title text := 'A2 — Vivre ensemble autrement';
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
      'Grande étape A2-5 : croiser des portraits, rapporter des paroles, dire d''accord ou pas, donner un avis, convaincre en douceur et situer un état d''esprit — dans la cour du Seuil des Sources (Rukiri-Nord), autour du figuier et de la table commune.',
      'A2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape A2-5 : croiser des portraits, rapporter des paroles, dire d''accord ou pas, donner un avis, convaincre en douceur et situer un état d''esprit — dans la cour du Seuil des Sources (Rukiri-Nord), autour du figuier et de la table commune.',
      cefr_level = 'A2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Portraits croisés =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Portraits croisés'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Portraits croisés', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — C''est Aline qui ouvre',
    'CO',
    $c$Objectif
Repérer c'est / ce sont + qui / que dans des portraits.

Consigne
Lisez le dialogue. Qui fait quoi ? Qui est mis en avant ?

Support — Cour du Seuil, banc des voisins
Patrick : C'est Aline qui ouvre la cour le matin.
Léa : Ce sont les voisins qui rangent les tasses.
Marc : C'est le figuier qui donne l'ombre à midi.
Hawa : C'est Léa que j'écoute quand on parle des règles.
Joël : Ce sont Kévin et Mado qui ferment le portail.
Rose : C'est Sami que Benoît photographie près du banc.
Karim : C'est Yvette qui tient le Cahier du chemin.
Lila : Ce sont les enfants qui arrosent trop vite.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick dit que c'est Aline qui ouvre la cour.",
  "correct": true,
  "explanation": "« C'est Aline qui ouvre la cour le matin. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que reprend « que » dans « C'est Léa que j'écoute » ?",
  "options": [
    {
      "text": "Le sujet",
      "correct": false
    },
    {
      "text": "Le complément d'objet",
      "correct": true
    },
    {
      "text": "Un lieu",
      "correct": false
    },
    {
      "text": "Un temps",
      "correct": false
    }
  ],
  "explanation": "J'écoute Léa → que = objet."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est Aline qui",
      "right": "sujet mis en avant"
    },
    {
      "left": "ce sont les voisins qui",
      "right": "pluriel"
    },
    {
      "left": "c'est Léa que",
      "right": "objet"
    },
    {
      "left": "c'est le figuier qui",
      "right": "la cour à midi"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ sont les voisins qui rangent les tasses.",
  "answer": "Ce"
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
    "Aline",
    "qui",
    "ouvre",
    "la",
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
  "word": "ouvre",
  "hint": "C'est Aline qui… la cour : elle commence la journée."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est les voisins qui rangent les tasses.",
  "correct_sentence": "Ce sont les voisins qui rangent les tasses.",
  "explanation": "Pluriel : ce sont, pas c'est."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/portrait-croise.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cest-relative.svg",
      "word": "une relative"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/deux-visages.svg",
      "word": "deux visages"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cadre-photo.svg",
      "word": "un cadre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez trois « c'est … qui » et un « c'est … que »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : C'est Aline qui ouvre. Ce sont les voisins qui rangent. C'est Léa que j'écoute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fiches portraits',
    'CE',
    $c$Objectif
Lire des portraits avec c'est / ce sont + relative.

Consigne
Lisez les fiches, sans aller trop vite.

Support — Mur de la Maison des Vents
Fiche Aline : C'est Aline qui rappelle les heures calmes.
Fiche Patrick : C'est Patrick que la cour écoute pour le figuier.
Fiche Rose : Ce sont Rose et Hawa qui dressent la Table des Sources.
Fiche Solange : C'est Solange Mukamana qui signe le cahier des règles.
Fiche enfants : Ce sont les enfants que Joël surveille près du puits.
Fiche arbre : C'est le figuier qui unit les voix le soir.
Règle : c'est + singulier. ce sont + pluriel.
qui = sujet. que = objet.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose et Hawa dressent la table.",
  "correct": true,
  "explanation": "« Ce sont Rose et Hawa qui dressent la Table des Sources. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui signe le cahier des règles ?",
  "options": [
    {
      "text": "Aline",
      "correct": false
    },
    {
      "text": "Patrick",
      "correct": false
    },
    {
      "text": "Solange",
      "correct": true
    },
    {
      "text": "Joël",
      "correct": false
    }
  ],
  "explanation": "Fiche Solange."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est Aline qui",
      "right": "heures calmes"
    },
    {
      "left": "c'est Patrick que",
      "right": "la cour écoute"
    },
    {
      "left": "ce sont Rose et Hawa qui",
      "right": "la table"
    },
    {
      "left": "c'est le figuier qui",
      "right": "les voix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est le figuier ___ unit les voix.",
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
    "Ce",
    "sont",
    "les",
    "enfants",
    "que",
    "Joël",
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
  "word": "rappelle",
  "hint": "C'est Aline qui… les heures : elle dit de nouveau la règle."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est Rose et Hawa qui dressent la table.",
  "correct_sentence": "Ce sont Rose et Hawa qui dressent la table.",
  "explanation": "Deux personnes → ce sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/bulle-indirect.svg",
      "word": "une bulle"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/oreille-dit.svg",
      "word": "une oreille"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cahier-on-dit.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/radio-echo.svg",
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
  "prompt": "Recopiez quatre fiches et encadrez qui / que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six fiches, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Mettre quelqu''un en avant',
    'PO',
    $c$Objectif
Faire un portrait oral avec c'est / ce sont + qui / que.

Consigne
Répétez, puis présentez un voisin de la cour.

Support — Modèles d'Aline
C'est moi qui range.
C'est toi qui parles.
C'est Léa que nous écoutons.
Ce sont eux qui ferment.
C'est le figuier qui protège.
Ce sont les tasses que je lave.
C'est Noura qui propose.
Ce sont les règles que l'on lit.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Ce sont eux qui ferment » met le groupe au pluriel.",
  "correct": true,
  "explanation": "Ce sont + pluriel + qui."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase utilise « que » pour un objet ?",
  "options": [
    {
      "text": "C'est moi qui range",
      "correct": false
    },
    {
      "text": "C'est Léa que nous écoutons",
      "correct": true
    },
    {
      "text": "C'est le figuier qui protège",
      "correct": false
    },
    {
      "text": "Ce sont eux qui ferment",
      "correct": false
    }
  ],
  "explanation": "Nous écoutons Léa → que."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est + singulier",
      "right": "une personne / une chose"
    },
    {
      "left": "ce sont + pluriel",
      "right": "plusieurs"
    },
    {
      "left": "qui",
      "right": "sujet"
    },
    {
      "left": "que",
      "right": "objet"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCe ___ les tasses que je lave.",
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
    "C'est",
    "toi",
    "qui",
    "parles",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "protege",
  "hint": "C'est le figuier qui… : il donne l'ombre (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est eux qui ferment le portail.",
  "correct_sentence": "Ce sont eux qui ferment le portail.",
  "explanation": "Eux = pluriel → ce sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/accord-ou.svg",
      "word": "un accord"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/desaccord-dont.svg",
      "word": "un désaccord"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/deux-avis.svg",
      "word": "deux avis"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/table-debat.svg",
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
  "prompt": "Écrivez six portraits : quatre qui, deux que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux portraits à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mes portraits de cour',
    'PE',
    $c$Objectif
Écrire des portraits croisés avec c'est / ce sont.

Consigne
Imitez la page de Marc.

Support — Page de Marc Nkurunziza
Marc Nkurunziza
C'est Aline qui ouvre les heures calmes.
Ce sont les voisins qui partagent la table.
C'est le figuier que nous protégeons.
C'est Hawa que j'écoute le soir.
Ce sont Kévin et Mado qui ferment.
C'est la cour qui nous rassemble.
Marc
Seuil des Sources — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc écrit que le figuier est protégé par le groupe.",
  "correct": true,
  "explanation": "« C'est le figuier que nous protégeons. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui ferme, d'après Marc ?",
  "options": [
    {
      "text": "Aline seule",
      "correct": false
    },
    {
      "text": "Kévin et Mado",
      "correct": true
    },
    {
      "text": "Solange",
      "correct": false
    },
    {
      "text": "Les tasses",
      "correct": false
    }
  ],
  "explanation": "« Ce sont Kévin et Mado qui ferment. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est Aline qui",
      "right": "heures calmes"
    },
    {
      "left": "ce sont les voisins qui",
      "right": "la table"
    },
    {
      "left": "c'est le figuier que",
      "right": "nous protégeons"
    },
    {
      "left": "c'est Hawa que",
      "right": "j'écoute"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est la cour ___ nous rassemble.",
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
    "C'est",
    "Hawa",
    "que",
    "j'écoute",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "rassemble",
  "hint": "C'est la cour qui nous… : elle met tout le monde ensemble."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est les voisins qui partagent la table.",
  "correct_sentence": "Ce sont les voisins qui partagent la table.",
  "explanation": "Voisins = pluriel → ce sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/main-avis.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/carnet-opinion.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/balance-pour.svg",
      "word": "pour"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/balance-contre.svg",
      "word": "contre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes avec c'est / ce sont et qui / que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez vos portraits, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — C''est, ce sont, qui, que',
    'EL',
    $c$Objectif
Retenir c'est / ce sont + proposition relative.

Consigne
Apprenez la fiche.

Support — Fiche des portraits
C'est + nom singulier + qui / que
Ce sont + nom pluriel + qui / que
qui = sujet : C'est Aline qui ouvre.
que = objet : C'est Léa que j'écoute. (qu' devant voyelle : qu'on)
On met en avant la personne ou la chose importante.
On ne dit pas : C'est les voisins qui…
On ne dit pas : C'est Aline que ouvre (ouvre a besoin d'un sujet : qui).
Accord : ce sont eux / ce sont elles.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « c'est les voisins qui ».",
  "correct": false,
  "explanation": "Pluriel : ce sont les voisins qui."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« C'est Aline … ouvre » se complète par…",
  "options": [
    {
      "text": "que",
      "correct": false
    },
    {
      "text": "qui",
      "correct": true
    },
    {
      "text": "dont",
      "correct": false
    },
    {
      "text": "où",
      "correct": false
    }
  ],
  "explanation": "Aline est sujet de ouvrir → qui."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est",
      "right": "singulier"
    },
    {
      "left": "ce sont",
      "right": "pluriel"
    },
    {
      "left": "qui",
      "right": "sujet"
    },
    {
      "left": "que / qu'",
      "right": "objet"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est Léa ___ j'écoute.",
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
    "Ce",
    "sont",
    "elles",
    "qui",
    "ferment",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "singulier",
  "hint": "C'est va avec un nom… : une seule personne."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est Aline que ouvre la cour.",
  "correct_sentence": "C'est Aline qui ouvre la cour.",
  "explanation": "Aline fait l'action → qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/celui-celle.svg",
      "word": "celui"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/fleche-demonstratif.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/trois-choix.svg",
      "word": "trois choix"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/panier-ceux.svg",
      "word": "un panier"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez six phrases en c'est / ce sont + relative."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six portraits."
}$j$::jsonb,
    9
  );

  -- ===== Ce qu'on m'a dit =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Ce qu''on m''a dit'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Ce qu''on m''a dit', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — On m''a dit que',
    'CO',
    $c$Objectif
Comprendre le discours indirect au présent : il dit que, elle demande si.

Consigne
Lisez le dialogue. Qui rapporte quelles paroles ?

Support — Banc sous le figuier
Léa : Patrick dit que le figuier a trop soif.
Aline : Hawa demande si on peut déplacer la table.
Marc : On m'a dit que les heures calmes commencent à vingt-deux heures.
Rose : Joël dit qu'il ferme le portail.
Karim : Solange demande où se trouve le cahier.
Mado : On m'a dit que Kévin arrose déjà.
Sami : Yvette dit que la cour reste ouverte.
Benoît : Noura demande si Ibrahim vient ce soir.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick dit que le figuier a trop soif.",
  "correct": true,
  "explanation": "Léa rapporte : « Patrick dit que… »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que demande Hawa, d'après Aline ?",
  "options": [
    {
      "text": "Si on peut déplacer la table",
      "correct": true
    },
    {
      "text": "Si le portail est fermé",
      "correct": false
    },
    {
      "text": "Où est Radio Figuier",
      "correct": false
    },
    {
      "text": "Quand part le minibus",
      "correct": false
    }
  ],
  "explanation": "« Hawa demande si on peut déplacer la table. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "dit que",
      "right": "affirmation rapportée"
    },
    {
      "left": "demande si",
      "right": "question oui / non"
    },
    {
      "left": "demande où",
      "right": "question de lieu"
    },
    {
      "left": "on m'a dit que",
      "right": "parole sans nom"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nHawa demande ___ on peut déplacer la table.",
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
    "Patrick",
    "dit",
    "que",
    "le",
    "figuier",
    "a",
    "soif",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "soif",
  "hint": "Le figuier a trop… : il manque d'eau."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Hawa demande que on peut déplacer la table.",
  "correct_sentence": "Hawa demande si on peut déplacer la table.",
  "explanation": "Question oui / non → demander si."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/horloge-en-train.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/futur-proche.svg",
      "word": "un futur"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/passe-recent.svg",
      "word": "un passé"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/nuage-esprit.svg",
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
  "prompt": "Notez deux « dit que », un « demande si », un « on m'a dit que »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il dit que. Elle demande si. On m'a dit que les heures calmes commencent."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Cahier des on-dit',
    'CE',
    $c$Objectif
Lire des paroles rapportées au présent.

Consigne
Lisez le cahier, sans aller trop vite.

Support — Cahier du chemin, page des échos
Échos de la cour — ce qu'on m'a dit
Aline dit que le silence aide le figuier.
Patrick demande si la table peut rester au milieu.
On m'a dit que Félicie Ndayishimiye arrive jeudi.
Rose dit qu'elle prépare un thé à la Table des Sources.
Karim demande quand Dieudonné passe à la Maison des Vents.
Lila Sow dit que Radio Figuier répète les règles le soir.
Attention : après que / si, le verbe reste au présent ici.
On ne change pas encore les temps (pas de « il a dit qu'il fermait »).
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Félicie arrive jeudi, d'après ce qu'on a dit.",
  "correct": true,
  "explanation": "« On m'a dit que Félicie Ndayishimiye arrive jeudi. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que prépare Rose ?",
  "options": [
    {
      "text": "Un micro",
      "correct": false
    },
    {
      "text": "Un thé",
      "correct": true
    },
    {
      "text": "Un tampon",
      "correct": false
    },
    {
      "text": "Un minibus",
      "correct": false
    }
  ],
  "explanation": "« Rose dit qu'elle prépare un thé. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Aline dit que",
      "right": "le silence"
    },
    {
      "left": "Patrick demande si",
      "right": "la table"
    },
    {
      "left": "Rose dit qu'elle",
      "right": "un thé"
    },
    {
      "left": "Karim demande quand",
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
  "prompt": "Complétez :\nAline dit ___ le silence aide le figuier.",
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
    "On",
    "m'a",
    "dit",
    "que",
    "Félicie",
    "arrive",
    "."
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
  "hint": "Aline dit que le… aide l'arbre : moins de bruit."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Patrick demande que la table peut rester au milieu.",
  "correct_sentence": "Patrick demande si la table peut rester au milieu.",
  "explanation": "Question → si, pas que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/cour-ensemble.svg",
      "word": "une cour"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/banc-voisins.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/affiche-vivre.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cle-partage.svg",
      "word": "une clé"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez et transformez deux phrases en discours direct."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six échos, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Rapporter une parole',
    'PO',
    $c$Objectif
Rapporter au présent : il dit que, elle demande si.

Consigne
Répétez, puis rapportez une phrase d'un voisin.

Support — Modèles de Léa
Il dit que c'est simple.
Elle demande si tu viens.
On m'a dit que c'est ouvert.
Il dit qu'il range.
Elle demande où tu vas.
On m'a dit que ça suffit.
Ils disent que la cour est calme.
Elle demande pourquoi on attend.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Après « demander », une question oui / non prend « si ».",
  "correct": true,
  "explanation": "Elle demande si tu viens."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase rapporte une question de lieu ?",
  "options": [
    {
      "text": "Il dit que c'est simple",
      "correct": false
    },
    {
      "text": "Elle demande où tu vas",
      "correct": true
    },
    {
      "text": "On m'a dit que ça suffit",
      "correct": false
    },
    {
      "text": "Ils disent que la cour est calme",
      "correct": false
    }
  ],
  "explanation": "Demander où."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "dire que",
      "right": "affirmation"
    },
    {
      "left": "demander si",
      "right": "oui / non"
    },
    {
      "left": "demander où",
      "right": "lieu"
    },
    {
      "left": "demander pourquoi",
      "right": "cause"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nElle demande ___ tu viens.",
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
    "dit",
    "qu'il",
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
  "word": "ouvert",
  "hint": "On m'a dit que c'est… : on peut entrer."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Elle demande que tu viens ce soir ici maintenant.",
  "correct_sentence": "Elle demande si tu viens.",
  "explanation": "Question oui / non → si."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/arbre-figuier.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/porte-ouverte.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/portrait-croise.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cest-relative.svg",
      "word": "une relative"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six rapports : deux que, deux si, un où, un pourquoi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux phrases rapportées à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon cahier d''échos',
    'PE',
    $c$Objectif
Écrire ce qu'on vous a dit, au présent.

Consigne
Imitez le cahier d'Hawa.

Support — Cahier de Hawa Diallo
Hawa Diallo
Aline dit que les heures calmes commencent tôt.
Patrick demande si j'arrose le figuier.
On m'a dit que la table reste au milieu.
Rose dit qu'elle prépare les tasses.
Joël demande où se range le seau.
On m'a dit que Sami arrive après le thé.
Hawa
Cour du Seuil
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël demande où se range le seau.",
  "correct": true,
  "explanation": "Avant-dernière ligne du cahier."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que dit-on de la table ?",
  "options": [
    {
      "text": "Elle part",
      "correct": false
    },
    {
      "text": "Elle reste au milieu",
      "correct": true
    },
    {
      "text": "Elle se casse",
      "correct": false
    },
    {
      "text": "Elle est vendue",
      "correct": false
    }
  ],
  "explanation": "« On m'a dit que la table reste au milieu. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Aline dit que",
      "right": "heures calmes"
    },
    {
      "left": "Patrick demande si",
      "right": "arroser"
    },
    {
      "left": "Rose dit qu'elle",
      "right": "tasses"
    },
    {
      "left": "Joël demande où",
      "right": "seau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPatrick demande ___ j'arrose le figuier.",
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
    "dit",
    "que",
    "ça",
    "commence",
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
  "word": "arroser",
  "hint": "Patrick demande si je… l'arbre : lui donner de l'eau."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On m'a dit si la table reste au milieu.",
  "correct_sentence": "On m'a dit que la table reste au milieu.",
  "explanation": "Dire + affirmation → que, pas si."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/cest-relative.svg",
      "word": "une relative"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/deux-visages.svg",
      "word": "deux visages"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cadre-photo.svg",
      "word": "un cadre"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/bulle-indirect.svg",
      "word": "une bulle"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes de paroles rapportées au présent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre cahier, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Discours indirect au présent',
    'EL',
    $c$Objectif
Retenir il dit que, elle demande si, on m'a dit que.

Consigne
Apprenez la fiche.

Support — Fiche des paroles
Direct : « Le figuier a soif. » → Il dit que le figuier a soif.
Direct : « Tu viens ? » → Elle demande si tu viens.
Direct : « Où est le cahier ? » → Il demande où est le cahier.
On m'a dit que + phrase au présent.
que / qu' (élision : dit qu'il).
demander si (pas demander que pour une question).
dire que (pas dire si pour une affirmation).
Ici, les verbes restent au présent : pas de changement de temps.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On transforme « Tu viens ? » par « elle demande que tu viens ».",
  "correct": false,
  "explanation": "Question → elle demande si tu viens."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Il dit … il range » s'écrit…",
  "options": [
    {
      "text": "dit que il",
      "correct": false
    },
    {
      "text": "dit qu'il",
      "correct": true
    },
    {
      "text": "dit si il",
      "correct": false
    },
    {
      "text": "dit qui il",
      "correct": false
    }
  ],
  "explanation": "Élision : qu'il."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "dire que",
      "right": "phrase déclarative"
    },
    {
      "left": "demander si",
      "right": "question fermée"
    },
    {
      "left": "demander où / quand",
      "right": "question ouverte"
    },
    {
      "left": "on m'a dit que",
      "right": "source vague"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl dit ___ le portail ferme.",
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
    "Elle",
    "demande",
    "si",
    "tu",
    "viens",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "present",
  "hint": "Ici le verbe rapporté reste au… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il dit si le figuier a soif.",
  "correct_sentence": "Il dit que le figuier a soif.",
  "explanation": "Affirmation → que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/oreille-dit.svg",
      "word": "une oreille"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cahier-on-dit.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/radio-echo.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/accord-ou.svg",
      "word": "un accord"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Passez six phrases du direct à l'indirect au présent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six transformations."
}$j$::jsonb,
    9
  );

  -- ===== D'accord, pas d'accord =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'D''accord, pas d''accord'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'D''accord, pas d''accord', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le lieu où l''on discute',
    'CO',
    $c$Objectif
Repérer où et dont dans un débat de voisins.

Consigne
Lisez le dialogue. Où ? Dont quoi ?

Support — Table des Sources, débat du soir
Aline : La cour où nous vivons doit rester calme.
Patrick : Le figuier dont les racines ont soif a besoin d'eau.
Léa : La raison dont on parle, c'est le bruit après vingt-deux heures.
Marc : Le banc où Sami s'assoit est trop près du portail.
Hawa : Le sujet dont Joël discute, c'est la table au milieu.
Rose : L'heure où tout s'arrête, c'est vingt-deux heures.
Karim : La règle dont Solange rappelle le texte est claire.
Noura : Le lieu où l'on se tait, c'est sous le figuier.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline parle de la cour où le groupe vit.",
  "correct": true,
  "explanation": "« La cour où nous vivons… »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Dont » dans « le figuier dont les racines » remplace…",
  "options": [
    {
      "text": "un lieu",
      "correct": false
    },
    {
      "text": "de + nom (les racines de)",
      "correct": true
    },
    {
      "text": "un temps",
      "correct": false
    },
    {
      "text": "un objet direct",
      "correct": false
    }
  ],
  "explanation": "Les racines du figuier → dont."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "où nous vivons",
      "right": "la cour"
    },
    {
      "left": "dont les racines",
      "right": "le figuier"
    },
    {
      "left": "dont on parle",
      "right": "la raison"
    },
    {
      "left": "où tout s'arrête",
      "right": "vingt-deux heures"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa cour ___ nous vivons doit rester calme.",
  "answer": "où"
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
    "sujet",
    "dont",
    "Joël",
    "discute",
    "."
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
  "hint": "Elles ont soif : la partie cachée de l'arbre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La cour dont nous vivons doit rester calme.",
  "correct_sentence": "La cour où nous vivons doit rester calme.",
  "explanation": "Vivre dans un lieu → où."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/desaccord-dont.svg",
      "word": "un désaccord"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/deux-avis.svg",
      "word": "deux avis"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/table-debat.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/main-avis.svg",
      "word": "une main"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez trois « où » et trois « dont »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : La cour où nous vivons. Le sujet dont on parle. L'heure où tout s'arrête."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Affiche du débat',
    'CE',
    $c$Objectif
Lire un texte de débat avec où et dont.

Consigne
Lisez l'affiche, sans aller trop vite.

Support — Affiche ocre, Maison des Vents
Débat — vivre sous le figuier
1. Le lieu où l'on dîne, c'est la Table des Sources.
2. La raison dont Aline parle, c'est le repos des enfants.
3. Le soir où Radio Figuier s'arrête, la cour écoute autrement.
4. Les règles dont nous avons besoin sont sur le cahier.
5. Le banc où Mado coud reste à l'ombre.
6. L'arbre dont l'ombre est douce n'est pas à nous seuls.
où = lieu ou moment. dont = de + nom / de + idée.
On parle de quelque chose → dont on parle.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Les règles dont le groupe a besoin sont sur le cahier.",
  "correct": true,
  "explanation": "Point 4 de l'affiche."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Mado coud-elle ?",
  "options": [
    {
      "text": "À la radio",
      "correct": false
    },
    {
      "text": "Au banc à l'ombre",
      "correct": true
    },
    {
      "text": "Au Bureau des Escales",
      "correct": false
    },
    {
      "text": "À Port de la Brise",
      "correct": false
    }
  ],
  "explanation": "« Le banc où Mado coud reste à l'ombre. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "où l'on dîne",
      "right": "table"
    },
    {
      "left": "dont Aline parle",
      "right": "repos"
    },
    {
      "left": "où Radio s'arrête",
      "right": "soir"
    },
    {
      "left": "dont l'ombre est douce",
      "right": "arbre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes règles ___ nous avons besoin sont sur le cahier.",
  "answer": "dont"
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
    "lieu",
    "où",
    "l'on",
    "dîne",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "besoin",
  "hint": "Les règles dont nous avons… : elles nous manquent si on les oublie."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les règles où nous avons besoin sont sur le cahier.",
  "correct_sentence": "Les règles dont nous avons besoin sont sur le cahier.",
  "explanation": "Avoir besoin de → dont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/carnet-opinion.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/balance-pour.svg",
      "word": "pour"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/balance-contre.svg",
      "word": "contre"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/celui-celle.svg",
      "word": "celui"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez et classez : où lieu, où moment, dont."
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
    'PO — Dire où et dont',
    'PO',
    $c$Objectif
Relier avec où (lieu / moment) et dont (de + nom).

Consigne
Répétez, puis parlez d'un désaccord de la cour.

Support — Modèles de Patrick
C'est le lieu où l'on parle.
C'est l'heure où l'on se tait.
C'est le sujet dont on discute.
C'est la raison dont je me souviens.
C'est l'arbre où l'ombre tombe.
C'est la règle dont Aline parle.
C'est la cour où je vis.
C'est l'ami dont j'écoute l'avis.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Dont » remplace souvent « de + nom ».",
  "correct": true,
  "explanation": "Parler de → dont on parle."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "On dit « le sujet … on discute » comment ?",
  "options": [
    {
      "text": "où",
      "correct": false
    },
    {
      "text": "que",
      "correct": false
    },
    {
      "text": "dont",
      "correct": true
    },
    {
      "text": "qui",
      "correct": false
    }
  ],
  "explanation": "Discuter de → dont."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "où",
      "right": "lieu ou moment"
    },
    {
      "left": "dont",
      "right": "de + nom"
    },
    {
      "left": "dont on parle",
      "right": "parler de"
    },
    {
      "left": "où je vis",
      "right": "vivre dans"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est le sujet ___ on discute.",
  "answer": "dont"
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
    "cour",
    "où",
    "je",
    "vis",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "discute",
  "hint": "Le sujet dont on… : on en parle, parfois sans être d'accord."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le sujet où on discute trop longtemps ici.",
  "correct_sentence": "C'est le sujet dont on discute.",
  "explanation": "Discuter de quelque chose → dont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/fleche-demonstratif.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/trois-choix.svg",
      "word": "trois choix"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/panier-ceux.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/horloge-en-train.svg",
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
  "prompt": "Écrivez huit relatives : quatre où, quatre dont."
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
    'PE — Ma note de débat',
    'PE',
    $c$Objectif
Écrire une note avec où et dont.

Consigne
Imitez la note de Léa.

Support — Note de Léa Niyonzima
Léa Niyonzima
La cour où nous dînons doit rester nette.
L'heure où le bruit s'arrête est vingt-deux heures.
Le figuier dont l'ombre nous unit a besoin d'eau.
La raison dont Patrick parle, c'est le repos.
Le banc où je couds reste à gauche.
La règle dont on a besoin est sur le mur.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa place le repos comme raison dont Patrick parle.",
  "correct": true,
  "explanation": "« La raison dont Patrick parle, c'est le repos. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle heure Léa écrit-elle ?",
  "options": [
    {
      "text": "Vingt heures",
      "correct": false
    },
    {
      "text": "Vingt-deux heures",
      "correct": true
    },
    {
      "text": "Midi",
      "correct": false
    },
    {
      "text": "Minuit",
      "correct": false
    }
  ],
  "explanation": "« L'heure où le bruit s'arrête est vingt-deux heures. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "où nous dînons",
      "right": "cour"
    },
    {
      "left": "où le bruit s'arrête",
      "right": "heure"
    },
    {
      "left": "dont l'ombre nous unit",
      "right": "figuier"
    },
    {
      "left": "dont on a besoin",
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
  "prompt": "Complétez :\nLe banc ___ je couds reste à gauche.",
  "answer": "où"
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
    "règle",
    "dont",
    "on",
    "a",
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
  "word": "ombre",
  "hint": "Le figuier dont l'… nous unit : le frais sous les feuilles."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La raison où Patrick parle c'est le repos.",
  "correct_sentence": "La raison dont Patrick parle c'est le repos.",
  "explanation": "Parler de la raison → dont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/futur-proche.svg",
      "word": "un futur"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/passe-recent.svg",
      "word": "un passé"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/nuage-esprit.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cour-ensemble.svg",
      "word": "une cour"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes avec où et dont."
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
    'EL — Relatifs où et dont',
    'EL',
    $c$Objectif
Retenir le lieu / le moment où et le nom dont.

Consigne
Apprenez la fiche.

Support — Fiche du débat
où = dans ce lieu / à ce moment
la cour où nous vivons / l'heure où l'on se tait
dont = de + nom (possession, thème, besoin)
l'arbre dont les feuilles… / le sujet dont on parle
avoir besoin de → dont on a besoin
parler de / se souvenir de / discuter de → dont
On ne dit pas : le lieu dont nous vivons.
On ne dit pas : le sujet où on discute.
Élision : l'heure où (pas d'élision de où).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « le lieu dont nous vivons ».",
  "correct": false,
  "explanation": "Vivre dans un lieu → où."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Avoir besoin de cette règle » → la règle…",
  "options": [
    {
      "text": "où on a besoin",
      "correct": false
    },
    {
      "text": "dont on a besoin",
      "correct": true
    },
    {
      "text": "que on a besoin",
      "correct": false
    },
    {
      "text": "qui on a besoin",
      "correct": false
    }
  ],
  "explanation": "De → dont."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "où",
      "right": "lieu / moment"
    },
    {
      "left": "dont",
      "right": "de + nom"
    },
    {
      "left": "parler de",
      "right": "dont on parle"
    },
    {
      "left": "vivre dans",
      "right": "où l'on vit"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est l'ami ___ j'écoute l'avis.",
  "answer": "dont"
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
    "l'heure",
    "où",
    "l'on",
    "se",
    "tait",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "moment",
  "hint": "Où sert aussi pour un… : l'heure où l'on se tait."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le sujet où je me souviens.",
  "correct_sentence": "C'est le sujet dont je me souviens.",
  "explanation": "Se souvenir de → dont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/banc-voisins.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/affiche-vivre.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cle-partage.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/arbre-figuier.svg",
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
  "prompt": "Complétez huit phrases : où ou dont."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et huit relatives."
}$j$::jsonb,
    9
  );

  -- ===== Vivre ensemble =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Vivre ensemble'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Vivre ensemble', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — À mon avis le figuier',
    'CO',
    $c$Objectif
Comprendre des avis : à mon avis, je trouve que, je ne suis pas d'accord.

Consigne
Lisez le dialogue. Qui est d'accord ? Qui ne l'est pas ?

Support — Cour, autour de la table
Aline : À mon avis, le figuier doit rester au centre.
Patrick : Je trouve que tu as raison.
Léa : Et toi, tu en penses quoi, Marc ?
Marc : Je ne suis pas d'accord. La table prend trop de place.
Hawa : Selon moi, on peut garder les deux.
Joël : Pour moi, les heures calmes sont trop tôt.
Rose : Je suis d'accord avec Aline.
Kévin : Moi, je pense que le portail doit rester ouvert.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc n'est pas d'accord avec Aline sur la place.",
  "correct": true,
  "explanation": "« Je ne suis pas d'accord. La table prend trop de place. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui demande l'avis de Marc ?",
  "options": [
    {
      "text": "Aline",
      "correct": false
    },
    {
      "text": "Léa",
      "correct": true
    },
    {
      "text": "Hawa",
      "correct": false
    },
    {
      "text": "Rose",
      "correct": false
    }
  ],
  "explanation": "« Et toi, tu en penses quoi, Marc ? »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "à mon avis",
      "right": "Aline"
    },
    {
      "left": "je trouve que",
      "right": "Patrick"
    },
    {
      "left": "tu en penses quoi",
      "right": "Léa à Marc"
    },
    {
      "left": "je ne suis pas d'accord",
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
  "prompt": "Complétez :\n___ mon avis, le figuier doit rester au centre.",
  "answer": "À"
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
    "trouve",
    "que",
    "tu",
    "as",
    "raison",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "raison",
  "hint": "Patrick trouve qu'Aline a… : il la suit."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ne suis pas d'accord que le figuier trop.",
  "correct_sentence": "Je ne suis pas d'accord.",
  "explanation": "D'accord se construit souvent seul, ou avec avec + nom."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/deux-visages.svg",
      "word": "deux visages"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cadre-photo.svg",
      "word": "un cadre"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/bulle-indirect.svg",
      "word": "une bulle"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/oreille-dit.svg",
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
  "prompt": "Notez deux accords et deux désaccords."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : À mon avis. Je trouve que. Et toi tu en penses quoi. Je ne suis pas d'accord."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Cartes d''avis',
    'CE',
    $c$Objectif
Lire des cartes pour demander et donner un avis.

Consigne
Lisez les cartes, sans aller trop vite.

Support — Cartes épinglées au figuier
Carte Aline : À mon avis, il faut moins de bruit après vingt-deux heures.
Carte Patrick : Je trouve que le seau doit rester près de l'arbre.
Carte Léa : Et vous, vous en pensez quoi du banc trop près du portail ?
Carte Marc : Je ne suis pas d'accord avec le déplacement de la table.
Carte Hawa : Selon moi, on peut essayer une semaine.
Carte Solange : Pour moi, les règles du cahier suffisent.
Il faut (toujours 3e personne) + infinitif.
Je trouve que + phrase. Être d'accord avec + quelqu'un.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Solange trouve que les règles du cahier suffisent.",
  "correct": true,
  "explanation": "Carte Solange : « Pour moi, les règles du cahier suffisent. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui propose d'essayer une semaine ?",
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
      "text": "Léa",
      "correct": false
    },
    {
      "text": "Aline",
      "correct": false
    }
  ],
  "explanation": "Carte Hawa."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "à mon avis",
      "right": "moins de bruit"
    },
    {
      "left": "je trouve que",
      "right": "le seau"
    },
    {
      "left": "vous en pensez quoi",
      "right": "le banc"
    },
    {
      "left": "selon moi",
      "right": "une semaine"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ne suis pas d'accord ___ le déplacement.",
  "answer": "avec"
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
    "moi",
    "on",
    "peut",
    "essayer",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "essayer",
  "hint": "Hawa propose d'… une semaine : faire le test."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je faut moins de bruit après vingt-deux heures.",
  "correct_sentence": "Il faut moins de bruit après vingt-deux heures.",
  "explanation": "Toujours il faut, jamais je faut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/cahier-on-dit.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/radio-echo.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/accord-ou.svg",
      "word": "un accord"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/desaccord-dont.svg",
      "word": "un désaccord"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez et ajoutez votre avis en une phrase."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six cartes, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire son avis',
    'PO',
    $c$Objectif
Demander et donner un avis à voix haute.

Consigne
Répétez, puis donnez votre avis sur la cour.

Support — Modèles d'Hawa
À mon avis, c'est juste.
Je trouve que c'est trop tôt.
Et toi, tu en penses quoi ?
Je suis d'accord.
Je ne suis pas d'accord.
Selon moi, on peut attendre.
Pour moi, la table reste.
Je pense que le figuier suffit.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Et toi, tu en penses quoi ? » sert à demander un avis.",
  "correct": true,
  "explanation": "Question d'opinion."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase exprime un désaccord ?",
  "options": [
    {
      "text": "Je suis d'accord",
      "correct": false
    },
    {
      "text": "Je ne suis pas d'accord",
      "correct": true
    },
    {
      "text": "À mon avis c'est juste",
      "correct": false
    },
    {
      "text": "Selon moi on peut attendre",
      "correct": false
    }
  ],
  "explanation": "Négation de être d'accord."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "à mon avis",
      "right": "opinion"
    },
    {
      "left": "je trouve que",
      "right": "jugement"
    },
    {
      "left": "tu en penses quoi",
      "right": "demande"
    },
    {
      "left": "d'accord / pas d'accord",
      "right": "position"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEt toi, tu ___ penses quoi ?",
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
    "Je",
    "ne",
    "suis",
    "pas",
    "d'accord",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "attente",
  "hint": "Selon moi on peut… : ne pas décider tout de suite. (nom)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je trouve ça que c'est trop tôt.",
  "correct_sentence": "Je trouve que c'est trop tôt.",
  "explanation": "Je trouve que + phrase, sans ça."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/deux-avis.svg",
      "word": "deux avis"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/table-debat.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/main-avis.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/carnet-opinion.svg",
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
  "prompt": "Écrivez huit phrases d'avis (demander / donner / accord / désaccord)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis votre avis sur le figuier."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon mot d''avis',
    'PE',
    $c$Objectif
Écrire un mot pour donner et demander un avis.

Consigne
Imitez le mot de Rose.

Support — Mot de Rose Iradukunda
Rose Iradukunda
À mon avis, le figuier doit garder l'eau le matin.
Je trouve que la table peut rester au milieu.
Et toi, tu en penses quoi, Patrick ?
Je ne suis pas d'accord avec un portail fermé trop tôt.
Selon moi, il faut écouter les enfants aussi.
Je suis d'accord avec les heures calmes.
Rose
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose n'est pas d'accord avec un portail fermé trop tôt.",
  "correct": true,
  "explanation": "Quatrième ligne du corps."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À qui Rose demande-t-elle son avis ?",
  "options": [
    {
      "text": "Aline",
      "correct": false
    },
    {
      "text": "Patrick",
      "correct": true
    },
    {
      "text": "Joël",
      "correct": false
    },
    {
      "text": "Solange",
      "correct": false
    }
  ],
  "explanation": "« Et toi, tu en penses quoi, Patrick ? »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "à mon avis",
      "right": "l'eau"
    },
    {
      "left": "je trouve que",
      "right": "la table"
    },
    {
      "left": "tu en penses quoi",
      "right": "Patrick"
    },
    {
      "left": "selon moi",
      "right": "les enfants"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe suis d'accord ___ les heures calmes.",
  "answer": "avec"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "À",
    "mon",
    "avis",
    "c'est",
    "juste",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "calmes",
  "hint": "Les heures… : moins de bruit le soir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis d'accord que les heures calmes trop.",
  "correct_sentence": "Je suis d'accord avec les heures calmes.",
  "explanation": "Être d'accord avec + nom."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/balance-pour.svg",
      "word": "pour"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/balance-contre.svg",
      "word": "contre"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/celui-celle.svg",
      "word": "celui"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/fleche-demonstratif.svg",
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
  "prompt": "Imitez : six lignes d'avis (avis, trouve que, demande, accord)."
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
    'EL — Structures d''avis',
    'EL',
    $c$Objectif
Retenir les formules pour demander et donner un avis.

Consigne
Apprenez la fiche.

Support — Fiche de la table
Donner : à mon avis / selon moi / pour moi / je pense que / je trouve que
Demander : et toi, tu en penses quoi ? / vous en pensez quoi ?
Position : je suis d'accord (avec + nom) / je ne suis pas d'accord
il faut + infinitif (il, toujours)
Je trouve que + phrase complète.
On ne dit pas : je faut. On ne dit pas : à mon avis que (sans verbe après, oui ; pas « que » obligatoire).
Politesse : je ne suis pas tout à fait d'accord.
en = de cela : tu en penses quoi (de cela).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Tu en penses quoi » : en reprend le sujet du débat.",
  "correct": true,
  "explanation": "En = de cela."
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
      "text": "je faut écouter",
      "correct": false
    },
    {
      "text": "il faut écouter",
      "correct": true
    },
    {
      "text": "tu faut écouter",
      "correct": false
    },
    {
      "text": "nous faut écouter",
      "correct": false
    }
  ],
  "explanation": "Toujours il faut."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "à mon avis",
      "right": "opinion personnelle"
    },
    {
      "left": "je trouve que",
      "right": "jugement + phrase"
    },
    {
      "left": "d'accord avec",
      "right": "soutien"
    },
    {
      "left": "tu en penses quoi",
      "right": "demande"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe trouve ___ c'est trop tôt.",
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
    "Pour",
    "moi",
    "la",
    "table",
    "reste",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "opinion",
  "hint": "À mon avis, selon moi : c'est une… personnelle."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je trouve de que c'est trop tôt.",
  "correct_sentence": "Je trouve que c'est trop tôt.",
  "explanation": "Trouver que, sans de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/trois-choix.svg",
      "word": "trois choix"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/panier-ceux.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/horloge-en-train.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/futur-proche.svg",
      "word": "un futur"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez un mini-dialogue de huit répliques d'avis."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six formules."
}$j$::jsonb,
    9
  );

  -- ===== Convaincre en douceur =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Convaincre en douceur'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Convaincre en douceur', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Celui du figuier',
    'CO',
    $c$Objectif
Comprendre celui, celle, ceux, celles pour désigner sans répéter.

Consigne
Lisez le dialogue. Celui de qui ? Celle qui… ?

Support — Ombre du figuier, choix de règles
Aline : Prenez celui de Patrick, le seau bleu.
Léa : Je préfère celle qui est près du banc, la règle courte.
Marc : Ceux que Joël a écrits sont plus clairs.
Hawa : Celles de Rose, les tasses, restent sur la table.
Patrick : Celui qui fuit, c'est le vieux seau.
Karim : Celle de Solange, la clé, ouvre encore.
Mado : Ceux du milieu, les bancs, gênent le passage.
Sami : Celles que nous lisons le soir suffisent.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline désigne le seau de Patrick par « celui de Patrick ».",
  "correct": true,
  "explanation": "Celui de + nom = le seau de Patrick."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Celles de Rose » reprend…",
  "options": [
    {
      "text": "Les seaux",
      "correct": false
    },
    {
      "text": "Les tasses",
      "correct": true
    },
    {
      "text": "Les bancs",
      "correct": false
    },
    {
      "text": "Les portails",
      "correct": false
    }
  ],
  "explanation": "Hawa : « Celles de Rose, les tasses ». "
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "celui de Patrick",
      "right": "le seau"
    },
    {
      "left": "celle qui est près",
      "right": "la règle"
    },
    {
      "left": "ceux que Joël a écrits",
      "right": "les textes"
    },
    {
      "left": "celles de Rose",
      "right": "sur la table"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPrenez ___ de Patrick, le seau bleu.",
  "answer": "celui"
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
    "celle",
    "qui",
    "est",
    "près",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "fuit",
  "hint": "Celui qui… : le vieux seau laisse partir l'eau."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Prenez celle de Patrick, le seau bleu.",
  "correct_sentence": "Prenez celui de Patrick, le seau bleu.",
  "explanation": "Seau est masculin : celui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/passe-recent.svg",
      "word": "un passé"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/nuage-esprit.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cour-ensemble.svg",
      "word": "une cour"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/banc-voisins.svg",
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
  "prompt": "Notez les quatre formes et le nom qu'elles évitent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Celui de Patrick. Celle qui est près. Ceux que Joël a écrits. Celles de Rose."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Liste de choix',
    'CE',
    $c$Objectif
Lire une liste qui utilise les pronoms démonstratifs.

Consigne
Lisez la liste, sans aller trop vite.

Support — Liste de Karim Bamba
Choix pour convaincre sans hausser la voix
1. Prenez celui du figuier, pas celui du portail.
2. Gardez celle qui est courte, pas celle qui est trop longue.
3. Lisez ceux que Solange a signés.
4. Rangez celles que les enfants ont laissées.
5. Celui-ci (près de moi) est plus léger que celui-là.
6. Celles-ci restent ; celles-là partent à la Maison des Vents.
celui / celle / ceux / celles + de + nom
+ qui (sujet) / + que (objet).
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On oppose celui du figuier et celui du portail.",
  "correct": true,
  "explanation": "Point 1 de la liste."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il lire, d'après le point 3 ?",
  "options": [
    {
      "text": "Ceux que Solange a signés",
      "correct": true
    },
    {
      "text": "Celles du portail",
      "correct": false
    },
    {
      "text": "Celui-là seulement",
      "correct": false
    },
    {
      "text": "Le seau de Marc",
      "correct": false
    }
  ],
  "explanation": "« Lisez ceux que Solange a signés. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "celui du figuier",
      "right": "pas du portail"
    },
    {
      "left": "celle qui est courte",
      "right": "règle"
    },
    {
      "left": "ceux que Solange a signés",
      "right": "textes"
    },
    {
      "left": "celles que les enfants ont laissées",
      "right": "affaires"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nGardez ___ qui est courte.",
  "answer": "celle"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Lisez",
    "ceux",
    "que",
    "Solange",
    "a",
    "signés",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "signes",
  "hint": "Ceux que Solange a… : elle a mis son nom (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lisez celles que Solange a signés.",
  "correct_sentence": "Lisez ceux que Solange a signés.",
  "explanation": "Textes / papiers masculins → ceux, participe signés."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/affiche-vivre.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cle-partage.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/arbre-figuier.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/porte-ouverte.svg",
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
  "prompt": "Recopiez et reliez chaque pronom à un nom."
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
    'PO — Désigner sans répéter',
    'PO',
    $c$Objectif
Utiliser celui / celle / ceux / celles à l'oral.

Consigne
Répétez, puis désignez un objet de la cour.

Support — Modèles d'Aline
Celui de Marc.
Celle de Léa.
Ceux du milieu.
Celles de la table.
Celui qui reste.
Celle que je lis.
Ceux que vous voulez.
Celles qui sont propres.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Celui qui » introduit un sujet.",
  "correct": true,
  "explanation": "Celui qui reste : qui = sujet."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pour « les tasses de la table », on dit…",
  "options": [
    {
      "text": "celui de la table",
      "correct": false
    },
    {
      "text": "celle de la table",
      "correct": false
    },
    {
      "text": "ceux de la table",
      "correct": false
    },
    {
      "text": "celles de la table",
      "correct": true
    }
  ],
  "explanation": "Tasses = féminin pluriel → celles."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "celui",
      "right": "masculin singulier"
    },
    {
      "left": "celle",
      "right": "féminin singulier"
    },
    {
      "left": "ceux",
      "right": "masculin pluriel"
    },
    {
      "left": "celles",
      "right": "féminin pluriel"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ que je lis est courte.",
  "answer": "Celle"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Celui",
    "qui",
    "reste",
    "est",
    "bleu",
    "."
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
  "hint": "Ceux du… : ni à gauche ni à droite, au centre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Celle de Marc est trop lourd, le seau.",
  "correct_sentence": "Celui de Marc est trop lourd.",
  "explanation": "Seau masculin → celui, lourd."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/porte-ouverte.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/portrait-croise.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cest-relative.svg",
      "word": "une relative"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/deux-visages.svg",
      "word": "deux visages"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit désignations : deux de chaque forme."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis trois désignations à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma proposition douce',
    'PE',
    $c$Objectif
Écrire une proposition qui désigne avec celui / celle / ceux / celles.

Consigne
Imitez la proposition de Patrick.

Support — Proposition de Patrick Habimana
Patrick Habimana
Gardons celui du figuier, le seau plein.
Laissons celle qui est courte, la règle du soir.
Lisons ceux qu'Aline a recopiés.
Rangeons celles de la Table des Sources.
Celui qui fuit peut partir à l'Atelier.
Celles que nous gardons suffisent pour demain.
Patrick
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick veut garder le seau du figuier.",
  "correct": true,
  "explanation": "« Gardons celui du figuier, le seau plein. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faire de la règle courte ?",
  "options": [
    {
      "text": "La jeter",
      "correct": false
    },
    {
      "text": "La laisser",
      "correct": true
    },
    {
      "text": "La vendre",
      "correct": false
    },
    {
      "text": "La cacher",
      "correct": false
    }
  ],
  "explanation": "« Laissons celle qui est courte. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "celui du figuier",
      "right": "seau"
    },
    {
      "left": "celle qui est courte",
      "right": "règle"
    },
    {
      "left": "ceux qu'Aline a recopiés",
      "right": "textes"
    },
    {
      "left": "celles de la table",
      "right": "tasses / affaires"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nRangeons ___ de la Table des Sources.",
  "answer": "celles"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Gardons",
    "celui",
    "du",
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
  "word": "recopies",
  "hint": "Ceux qu'Aline a… : elle a écrit une deuxième fois (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Gardons celle du figuier, le seau plein.",
  "correct_sentence": "Gardons celui du figuier, le seau plein.",
  "explanation": "Seau → celui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/cadre-photo.svg",
      "word": "un cadre"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/bulle-indirect.svg",
      "word": "une bulle"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/oreille-dit.svg",
      "word": "une oreille"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cahier-on-dit.svg",
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
  "prompt": "Imitez : six lignes avec les quatre pronoms."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre proposition, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Celui, celle, ceux, celles',
    'EL',
    $c$Objectif
Retenir les pronoms démonstratifs et leurs suites.

Consigne
Apprenez la fiche.

Support — Fiche pour convaincre
celui / celle / ceux / celles remplacent un nom déjà connu.
+ de + nom : celui de Patrick / celles de la table
+ qui : celui qui fuit (sujet)
+ que : ceux que j'ai lus (objet) — qu' devant voyelle
celui-ci / celui-là : proche / plus loin
Accord avec le nom remplacé, pas avec « de + nom » seul.
On ne dit pas : le celui de Patrick.
On ne dit pas : ceux de Rose pour des tasses (tasses → celles).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « le celui de Patrick ».",
  "correct": false,
  "explanation": "Pas d'article devant celui."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Que + elle a signés » après ceux s'écrit…",
  "options": [
    {
      "text": "ceux que elle",
      "correct": false
    },
    {
      "text": "ceux qu'elle",
      "correct": true
    },
    {
      "text": "ceux qui elle",
      "correct": false
    },
    {
      "text": "ceux quelle",
      "correct": false
    }
  ],
  "explanation": "Élision : qu'elle."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "celui de",
      "right": "possession / origine"
    },
    {
      "left": "celle qui",
      "right": "sujet fém."
    },
    {
      "left": "ceux que",
      "right": "objet masc. pl."
    },
    {
      "left": "celles-ci / celles-là",
      "right": "proche / loin"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nRangez ___ qu'elle a laissées.",
  "answer": "celles"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Prenez",
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
  "word": "article",
  "hint": "On ne met pas le ou la devant celui : pas d'…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Prenez le celui de Patrick.",
  "correct_sentence": "Prenez celui de Patrick.",
  "explanation": "Celui sans article."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/radio-echo.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/accord-ou.svg",
      "word": "un accord"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/desaccord-dont.svg",
      "word": "un désaccord"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/deux-avis.svg",
      "word": "deux avis"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Remplacez huit noms répétés par celui / celle / ceux / celles."
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

  -- ===== Un état d'esprit =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un état d''esprit'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un état d''esprit', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — On est en train de',
    'CO',
    $c$Objectif
Comprendre être en train de, aller + infinitif, venir de + infinitif.

Consigne
Lisez le dialogue. Qu'est-ce qui se passe maintenant, bientôt, juste avant ?

Support — Cour au réveil, Table des Sources
Aline : Je suis en train d'ouvrir le cahier.
Patrick : Léa va arroser le figuier.
Hawa : Marc vient de ranger les tasses.
Joël : Nous sommes en train de discuter des heures calmes.
Rose : Ils vont fermer le portail tout à l'heure.
Kévin : Je viens de parler à Yvette.
Mado : Sami est en train de coudre près du banc.
Lila : On va se retrouver à la table ce soir.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc vient de ranger : l'action est toute récente.",
  "correct": true,
  "explanation": "Venir de + infinitif = passé récent."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que va faire Léa ?",
  "options": [
    {
      "text": "Ouvrir le cahier",
      "correct": false
    },
    {
      "text": "Arroser le figuier",
      "correct": true
    },
    {
      "text": "Fermer le portail",
      "correct": false
    },
    {
      "text": "Coudre",
      "correct": false
    }
  ],
  "explanation": "« Léa va arroser le figuier. » — futur proche."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "être en train de",
      "right": "action en cours"
    },
    {
      "left": "aller + infinitif",
      "right": "futur proche"
    },
    {
      "left": "venir de + infinitif",
      "right": "passé récent"
    },
    {
      "left": "je viens de parler",
      "right": "à Yvette"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe suis en train ___ ouvrir le cahier.",
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
    "Léa",
    "va",
    "arroser",
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
  "word": "recent",
  "hint": "Venir de : l'action vient de se terminer, c'est… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis en train que j'ouvre le cahier.",
  "correct_sentence": "Je suis en train d'ouvrir le cahier.",
  "explanation": "Être en train de + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/table-debat.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/main-avis.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/carnet-opinion.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/balance-pour.svg",
      "word": "pour"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Classez six actions : en cours / tout à l'heure / à l'instant."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je suis en train d'ouvrir. Léa va arroser. Marc vient de ranger."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Tableau des moments',
    'CE',
    $c$Objectif
Lire un tableau d'états d'esprit et de temps proches.

Consigne
Lisez le tableau, sans aller trop vite.

Support — Tableau ocre, Salle des Herbes
Maintenant — être en train de
Aline est en train de lire le cahier.
Les voisins sont en train de déplacer un banc.
Tout à l'heure — aller + infinitif
Patrick va parler à Radio Figuier.
Nous allons essayer les heures calmes.
À l'instant — venir de + infinitif
Hawa vient d'éteindre la lanterne.
Joël et Rose viennent de signer.
Attention : je vais (futur proche) ≠ je serai (futur simple).
venir de ≠ venir à (lieu).
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa vient d'éteindre : c'est tout juste fait.",
  "correct": true,
  "explanation": "Venir de + infinitif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est au futur proche ?",
  "options": [
    {
      "text": "Aline est en train de lire",
      "correct": false
    },
    {
      "text": "Patrick va parler à Radio Figuier",
      "correct": true
    },
    {
      "text": "Hawa vient d'éteindre",
      "correct": false
    },
    {
      "text": "Joël et Rose viennent de signer",
      "correct": false
    }
  ],
  "explanation": "Aller + infinitif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en train de lire",
      "right": "maintenant"
    },
    {
      "left": "va parler",
      "right": "tout à l'heure"
    },
    {
      "left": "vient d'éteindre",
      "right": "à l'instant"
    },
    {
      "left": "allons essayer",
      "right": "nous"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ essayer les heures calmes.",
  "answer": "allons"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Hawa",
    "vient",
    "d'éteindre",
    "la",
    "lanterne",
    "."
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
  "hint": "Hawa vient de l'éteindre : la lumière de papier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Patrick va de parler à Radio Figuier.",
  "correct_sentence": "Patrick va parler à Radio Figuier.",
  "explanation": "Aller + infinitif, sans de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/balance-contre.svg",
      "word": "contre"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/celui-celle.svg",
      "word": "celui"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/fleche-demonstratif.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/trois-choix.svg",
      "word": "trois choix"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le tableau et ajoutez une phrase à vous dans chaque case."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le tableau, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire en cours, bientôt, à l''instant',
    'PO',
    $c$Objectif
Situer une action : en train de, aller, venir de.

Consigne
Répétez, puis parlez de votre matinée à la cour.

Support — Modèles de Marc
Je suis en train d'écouter.
Tu vas ranger.
Elle vient de partir.
Nous sommes en train de décider.
Vous allez signer.
Ils viennent d'arriver.
On va se taire.
Je viens de comprendre.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je viens de comprendre » place l'action juste avant maintenant.",
  "correct": true,
  "explanation": "Passé récent."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme marque une action en cours ?",
  "options": [
    {
      "text": "tu vas ranger",
      "correct": false
    },
    {
      "text": "je suis en train d'écouter",
      "correct": true
    },
    {
      "text": "elle vient de partir",
      "correct": false
    },
    {
      "text": "vous allez signer",
      "correct": false
    }
  ],
  "explanation": "Être en train de."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en train de",
      "right": "en cours"
    },
    {
      "left": "aller + inf.",
      "right": "proche avenir"
    },
    {
      "left": "venir de + inf.",
      "right": "proche passé"
    },
    {
      "left": "on va se taire",
      "right": "projet"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nElle vient ___ partir.",
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
    "en",
    "train",
    "d'écouter",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "decider",
  "hint": "Nous sommes en train de… : faire un choix (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis en train je écoute la cour trop.",
  "correct_sentence": "Je suis en train d'écouter.",
  "explanation": "De + infinitif (d' devant voyelle)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/panier-ceux.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/horloge-en-train.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/futur-proche.svg",
      "word": "un futur"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/passe-recent.svg",
      "word": "un passé"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez neuf phrases : trois de chaque structure."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis trois phrases à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon état du matin',
    'PE',
    $c$Objectif
Écrire un état d'esprit avec les trois structures.

Consigne
Imitez la page de Joël.

Support — Page de Joël Mugisha
Joël Mugisha
Je suis en train d'ouvrir le portail.
Léa va arroser le figuier dans un instant.
Hawa vient de poser les tasses.
Nous sommes en train de lire les règles.
Vous allez entendre Radio Figuier.
Ils viennent de quitter le banc.
Joël
Seuil des Sources — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa vient de poser les tasses.",
  "correct": true,
  "explanation": "Troisième ligne du corps."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que va faire Léa ?",
  "options": [
    {
      "text": "Ouvrir le portail",
      "correct": false
    },
    {
      "text": "Arroser le figuier",
      "correct": true
    },
    {
      "text": "Quitter le banc",
      "correct": false
    },
    {
      "text": "Poser les tasses",
      "correct": false
    }
  ],
  "explanation": "« Léa va arroser le figuier dans un instant. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je suis en train d'ouvrir",
      "right": "portail"
    },
    {
      "left": "Léa va arroser",
      "right": "figuier"
    },
    {
      "left": "Hawa vient de poser",
      "right": "tasses"
    },
    {
      "left": "ils viennent de quitter",
      "right": "banc"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous sommes en train ___ lire les règles.",
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
    "Vous",
    "allez",
    "entendre",
    "Radio",
    "Figuier",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "portail",
  "hint": "Joël est en train de l'ouvrir : la porte de la cour."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je viens à poser les tasses à l'instant trop vite.",
  "correct_sentence": "Je viens de poser les tasses.",
  "explanation": "Passé récent : venir de + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/nuage-esprit.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/cour-ensemble.svg",
      "word": "une cour"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/banc-voisins.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/affiche-vivre.svg",
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
  "prompt": "Imitez : six lignes, deux de chaque structure."
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
    'EL — En train, aller, venir de',
    'EL',
    $c$Objectif
Retenir présent continu, futur proche et passé récent.

Consigne
Apprenez la fiche.

Support — Fiche des états
être en train de + infinitif : action en cours
je suis / tu es / il est / nous sommes en train de…
aller + infinitif : futur proche (bientôt)
je vais / tu vas / il va / nous allons / vous allez / ils vont
venir de + infinitif : passé récent (à l'instant)
je viens / tu viens / il vient / nous venons de…
Élision : en train d'ouvrir / vient d'arriver
je serai (futur simple) ≠ je vais être (futur proche)
On ne dit pas : je suis en train que je…
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je serai » et « je vais être » disent exactement la même chose.",
  "correct": false,
  "explanation": "Serai = futur simple. Je vais être = futur proche, plus immédiat."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Venir de ranger » situe l'action…",
  "options": [
    {
      "text": "dans longtemps",
      "correct": false
    },
    {
      "text": "en ce moment exact et long",
      "correct": false
    },
    {
      "text": "juste avant maintenant",
      "correct": true
    },
    {
      "text": "jamais",
      "correct": false
    }
  ],
  "explanation": "Passé récent."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en train de",
      "right": "maintenant"
    },
    {
      "left": "aller + inf.",
      "right": "bientôt"
    },
    {
      "left": "venir de + inf.",
      "right": "à l'instant"
    },
    {
      "left": "d'",
      "right": "élision devant voyelle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ de comprendre. (venir)",
  "answer": "viens"
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
    "allons",
    "essayer",
    "demain",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "bientot",
  "hint": "Aller + infinitif : l'action aura lieu… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous venons à signer le cahier à l'instant.",
  "correct_sentence": "Nous venons de signer le cahier.",
  "explanation": "Venir de + infinitif, pas venir à."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m5/cle-partage.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/arbre-figuier.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/porte-ouverte.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-a2-m5/portrait-croise.svg",
      "word": "un portrait"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Conjuguez les trois structures à je / nous / ils."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et neuf formes."
}$j$::jsonb,
    9
  );

END;
$$;
