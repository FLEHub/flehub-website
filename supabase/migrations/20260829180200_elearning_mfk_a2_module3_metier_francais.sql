/*
  Seed eLearning MFK — A2 — Un métier en français

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a2-m3/
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
  v_module_title text := 'A2 — Un métier en français';
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
      'Grande étape A2-3 : lire une offre, se présenter, proposer un service, oser un choix, raconter un parcours et répondre avec assurance — à l''Atelier du Tissu et à Radio Figuier, avec Aline, Patrick, Joël, Dieudonné et Lila Sow.',
      'A2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape A2-3 : lire une offre, se présenter, proposer un service, oser un choix, raconter un parcours et répondre avec assurance — à l''Atelier du Tissu et à Radio Figuier, avec Aline, Patrick, Joël, Dieudonné et Lila Sow.',
      cefr_level = 'A2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Une offre à saisir =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une offre à saisir'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une offre à saisir', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Deux offres à la Table',
    'CO',
    $c$Objectif
Repérer le vocabulaire des compétences et des qualités.

Consigne
Lisez le dialogue. Quelles qualités chaque offre demande-t-elle ?

Support — Table des Sources, feuilles ocre
Dieudonné : À l'Atelier du Tissu, il me faut quelqu'un de soigneux et patient.
Lila : À Radio Figuier, je cherche une voix claire, ponctuelle, à l'écoute.
Patrick : Moi, je suis organisé. Je peux tenir l'accueil de la cour.
Joël : Je suis souriant, mais je ne suis pas encore autonome.
Aline : Une qualité, c'est ce que vous êtes. Une compétence, c'est ce que vous savez faire.
Hawa : L'accueil demande d'être fiable et poli.
Rose : L'atelier demande de mesurer le tissu, de plier, de noter les commandes.
Marc : La radio demande de lire un texte, de régler le micro, de respecter l'heure.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné cherche quelqu'un de soigneux et patient.",
  "correct": true,
  "explanation": "Première réplique de Dieudonné."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Aline, une compétence, c'est…",
  "options": [
    {
      "text": "ce que vous êtes",
      "correct": false
    },
    {
      "text": "ce que vous savez faire",
      "correct": true
    },
    {
      "text": "un défaut",
      "correct": false
    },
    {
      "text": "un horaire",
      "correct": false
    }
  ],
  "explanation": "Qualité = être. Compétence = savoir faire."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "soigneux / patient",
      "right": "atelier"
    },
    {
      "left": "ponctuelle / à l'écoute",
      "right": "radio"
    },
    {
      "left": "organisé",
      "right": "Patrick"
    },
    {
      "left": "souriant",
      "right": "Joël"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne ___ , c'est ce que vous êtes.",
  "answer": "qualité"
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
    "organisé",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "patient",
  "hint": "Dieudonné le demande : on attend sans s'énerver."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Une compétence, c'est ce que vous êtes seulement.",
  "correct_sentence": "Une compétence, c'est ce que vous savez faire.",
  "explanation": "Être = qualité. Savoir faire = compétence."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/offre-atelier.svg",
      "word": "une offre"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/cv-patrick.svg",
      "word": "un CV"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/qualite-equipe.svg",
      "word": "une qualité"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/competence-accueil.svg",
      "word": "une compétence"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez quatre qualités et quatre compétences entendues."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je suis organisé. Je suis ponctuel. Je sais tenir l'accueil. Je sais régler le micro."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Annonces épinglées',
    'CE',
    $c$Objectif
Lire deux offres et extraire qualités et compétences.

Consigne
Lisez les annonces, sans aller trop vite.

Support — Mur de la cour, tampons ocre
Offre 1 — Atelier du Tissu (Dieudonné Hakizimana)
Qualités : soigneux, calme, fiable.
Compétences : couper droit, plier un coupon, noter une commande.
Horaires : chaque matin, accueil des commandes.
Offre 2 — Radio Figuier (Lila Sow)
Qualités : ponctuel, clair, à l'écoute de l'équipe.
Compétences : lire un texte, régler le micro, annoncer l'heure.
Offre 3 — Accueil de la cour (Aline Uwase)
Qualités : souriant, poli, autonome.
Compétences : indiquer un lieu, tenir le cahier, appeler l'infirmerie.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'accueil de la cour demande d'être souriant et poli.",
  "correct": true,
  "explanation": "Offre 3 — qualités : souriant, poli, autonome."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui signe l'offre de la radio ?",
  "options": [
    {
      "text": "Dieudonné",
      "correct": false
    },
    {
      "text": "Aline",
      "correct": false
    },
    {
      "text": "Lila Sow",
      "correct": true
    },
    {
      "text": "Patrick",
      "correct": false
    }
  ],
  "explanation": "Offre 2 — Lila Sow."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "couper / plier / noter",
      "right": "atelier"
    },
    {
      "left": "lire / régler / annoncer",
      "right": "radio"
    },
    {
      "left": "indiquer / tenir / appeler",
      "right": "accueil"
    },
    {
      "left": "fiable / ponctuel / autonome",
      "right": "qualités"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'atelier demande quelqu'un de ___. (calme aussi)",
  "answer": "soigneux"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Lire",
    "un",
    "texte",
    "régler",
    "le",
    "micro",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "fiable",
  "hint": "On peut compter sur cette personne : elle est…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Radio Figuier cherche quelqu'un de ponctuelle et clair.",
  "correct_sentence": "Radio Figuier cherche quelqu'un de ponctuel et clair.",
  "explanation": "Quelqu'un est masculin : ponctuel, clair."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/cv-patrick.svg",
      "word": "un CV"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/qualite-equipe.svg",
      "word": "une qualité"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/competence-accueil.svg",
      "word": "une compétence"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/badge-presente.svg",
      "word": "un badge"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez une offre et ajoutez une qualité à vous."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les trois offres, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire une qualité, une compétence',
    'PO',
    $c$Objectif
Présenter ce que l'on est et ce que l'on sait faire.

Consigne
Répétez, puis parlez d'un poste inventé de la cour.

Support — Modèles d'Aline
Je suis ponctuel.
Je suis à l'écoute.
Je suis autonome.
Je sais tenir l'accueil.
Je sais plier un coupon.
Je sais lire un texte à voix haute.
Je ne suis pas encore très patient, mais j'apprends.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je sais + infinitif » introduit une compétence.",
  "correct": true,
  "explanation": "Je sais tenir, plier, lire."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase dit une qualité ?",
  "options": [
    {
      "text": "Je sais régler le micro",
      "correct": false
    },
    {
      "text": "Je suis fiable",
      "correct": true
    },
    {
      "text": "Je note une commande",
      "correct": false
    },
    {
      "text": "J'appelle l'infirmerie",
      "correct": false
    }
  ],
  "explanation": "Être + adjectif = qualité."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je suis",
      "right": "qualité"
    },
    {
      "left": "je sais + inf.",
      "right": "compétence"
    },
    {
      "left": "ponctuel",
      "right": "à l'heure"
    },
    {
      "left": "autonome",
      "right": "sans aide constante"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ tenir l'accueil. (compétence)",
  "answer": "sais"
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
    "à",
    "l'écoute",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "autonome",
  "hint": "On travaille sans demander de l'aide à chaque pas."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis savoir tenir l'accueil.",
  "correct_sentence": "Je sais tenir l'accueil.",
  "explanation": "Compétence : je sais + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/qualite-equipe.svg",
      "word": "une qualité"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/competence-accueil.svg",
      "word": "une compétence"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/badge-presente.svg",
      "word": "un badge"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/articulateur.svg",
      "word": "un mot de liaison"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases : trois je suis, trois je sais."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis votre mini-portrait."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mes notes d''offre',
    'PE',
    $c$Objectif
Écrire des notes sur une offre : qualités et compétences.

Consigne
Imitez les notes de Patrick.

Support — Notes de Patrick Habimana
Patrick Habimana
Offre : accueil de la cour, sous le figuier.
Qualités demandées : souriant, poli, fiable.
Compétences : indiquer un lieu, tenir le cahier, appeler Yvette à l'infirmerie.
Je suis organisé. Je sais lire un horaire.
Je ne suis pas encore autonome le soir, mais je suis ponctuel le matin.
Patrick
Table des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick dit qu'il est déjà autonome le soir.",
  "correct": false,
  "explanation": "« Je ne suis pas encore autonome le soir. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui faut-il appeler à l'infirmerie ?",
  "options": [
    {
      "text": "Lila",
      "correct": false
    },
    {
      "text": "Dieudonné",
      "correct": false
    },
    {
      "text": "Yvette",
      "correct": true
    },
    {
      "text": "Karim",
      "correct": false
    }
  ],
  "explanation": "« appeler Yvette à l'infirmerie »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "souriant / poli / fiable",
      "right": "qualités"
    },
    {
      "left": "indiquer / tenir / appeler",
      "right": "compétences"
    },
    {
      "left": "organisé",
      "right": "Patrick"
    },
    {
      "left": "ponctuel le matin",
      "right": "force"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe suis ___. Je sais lire un horaire.",
  "answer": "organisé"
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
    "sais",
    "lire",
    "un",
    "horaire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "souriant",
  "hint": "Visage ouvert à l'accueil : une qualité de la cour."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis organisé et je suis savoir l'horaire.",
  "correct_sentence": "Je suis organisé. Je sais lire un horaire.",
  "explanation": "Qualité : je suis. Compétence : je sais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/competence-accueil.svg",
      "word": "une compétence"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/badge-presente.svg",
      "word": "un badge"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/articulateur.svg",
      "word": "un mot de liaison"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/micro-radio.svg",
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
  "prompt": "Imitez : six lignes, trois qualités, trois compétences."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez vos notes, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Qualités et compétences',
    'EL',
    $c$Objectif
Retenir le lexique pour lire une offre et se décrire.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
Qualité (être) : ponctuel, fiable, souriant, patient, organisé,
autonome, poli, soigneux, calme, à l'écoute, clair.
Accord : une personne ponctuelle / un collègue ponctuel.
Compétence (savoir faire) : je sais + infinitif.
tenir l'accueil, plier un coupon, régler le micro, lire un texte,
indiquer un lieu, noter une commande, respecter l'heure.
On ne dit pas : je suis savoir. On dit : je sais.
Postes inventés ici : accueil de la cour, atelier du tissu, radio locale.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je suis savoir plier ».",
  "correct": false,
  "explanation": "Je sais plier."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Ponctuel » veut dire…",
  "options": [
    {
      "text": "toujours en retard",
      "correct": false
    },
    {
      "text": "à l'heure",
      "correct": true
    },
    {
      "text": "très fort",
      "correct": false
    },
    {
      "text": "sans sourire",
      "correct": false
    }
  ],
  "explanation": "À l'heure."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qualité",
      "right": "je suis"
    },
    {
      "left": "compétence",
      "right": "je sais"
    },
    {
      "left": "fiable",
      "right": "on peut compter"
    },
    {
      "left": "autonome",
      "right": "sans aide constante"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne collègue ___ arrive à l'heure. (ponctuel, fém.)",
  "answer": "ponctuelle"
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
    "sais",
    "plier",
    "un",
    "coupon",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ponctuel",
  "hint": "Jamais en retard : un collègue… le matin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Elle est ponctuel à Radio Figuier.",
  "correct_sentence": "Elle est ponctuelle à Radio Figuier.",
  "explanation": "Féminin : ponctuelle."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/badge-presente.svg",
      "word": "un badge"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/articulateur.svg",
      "word": "un mot de liaison"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/micro-radio.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/carte-visite.svg",
      "word": "une carte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Faites deux colonnes de dix mots : qualités / compétences."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six phrases je suis / je sais."
}$j$::jsonb,
    9
  );

  -- ===== Se présenter professionnellement =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Se présenter professionnellement'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Se présenter professionnellement', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Coach d''Aline',
    'CO',
    $c$Objectif
Repérer les articulateurs dans une présentation orale.

Consigne
Lisez le dialogue. Quel mot relie quelle idée ?

Support — Salle des Herbes, chaises en cercle
Aline : D'abord, dites votre nom et le poste visé.
Patrick : D'abord, je m'appelle Patrick. Ensuite, je vise l'accueil.
Joël : Puis je parlerai de l'atelier. Enfin, je poserai une question.
Léa : Cependant, Joël parle trop vite. Donc il doit respirer.
Hawa : En effet, Lila l'a dit à la radio. Par exemple, une pause après chaque idée.
Marc : D'abord le cadre, ensuite les preuves, puis une qualité, enfin un merci.
Aline : Donc vous reliez : d'abord, ensuite, puis, enfin, cependant, donc, en effet, par exemple.
Rose : Cependant n'est pas un « et ». C'est un « mais » plus posé.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Cependant » sert à ajouter la même idée, comme « et ».",
  "correct": false,
  "explanation": "Rose : c'est un « mais » plus posé."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel mot ouvre souvent la présentation ?",
  "options": [
    {
      "text": "enfin",
      "correct": false
    },
    {
      "text": "cependant",
      "correct": false
    },
    {
      "text": "d'abord",
      "correct": true
    },
    {
      "text": "en effet",
      "correct": false
    }
  ],
  "explanation": "D'abord = première étape."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'abord",
      "right": "première idée"
    },
    {
      "left": "ensuite / puis",
      "right": "suite"
    },
    {
      "left": "enfin",
      "right": "dernière étape"
    },
    {
      "left": "cependant",
      "right": "opposition"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ , je m'appelle Patrick.",
  "answer": "D'abord"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ensuite",
    "je",
    "vise",
    "l'accueil",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ensuite",
  "hint": "Après d'abord : la deuxième étape, le mot…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "D'abord je m'appelle. Cependant je vise l'accueil sans contraste.",
  "correct_sentence": "D'abord je m'appelle. Ensuite je vise l'accueil.",
  "explanation": "Ensuite = suite. Cependant = opposition."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/articulateur.svg",
      "word": "un mot de liaison"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/micro-radio.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/carte-visite.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/service-propose.svg",
      "word": "un service"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez les huit articulateurs et un exemple pour chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : D'abord je me présente. Ensuite je vise l'accueil. Enfin je remercie."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Cartes de présentation',
    'CE',
    $c$Objectif
Lire des présentations structurées par des articulateurs.

Consigne
Lisez les cartes, sans aller trop vite.

Support — Cartes ocre, Bureau des Escales
Carte Joël — D'abord, je m'appelle Joël Mugisha. Ensuite, je vise l'atelier.
Puis j'explique que je sais plier. Enfin, je remercie Dieudonné.
Carte Patrick — D'abord l'accueil. Cependant, je peux aider à la radio le jeudi.
Donc je reste souple. En effet, Aline l'a conseillé.
Carte Léa — Par exemple, je peux indiquer la Salle des Herbes.
Puis je tiens le cahier. Enfin, je cède la place.
Rappel : donc = conclusion. En effet = on confirme. Par exemple = on illustre.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick refuse d'aider à la radio.",
  "correct": false,
  "explanation": "« Cependant, je peux aider à la radio le jeudi. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel mot illustre une idée ?",
  "options": [
    {
      "text": "donc",
      "correct": false
    },
    {
      "text": "en effet",
      "correct": false
    },
    {
      "text": "par exemple",
      "correct": true
    },
    {
      "text": "cependant",
      "correct": false
    }
  ],
  "explanation": "Par exemple = illustration."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'abord / ensuite / puis / enfin",
      "right": "ordre"
    },
    {
      "left": "cependant",
      "right": "contraste"
    },
    {
      "left": "donc",
      "right": "conclusion"
    },
    {
      "left": "en effet",
      "right": "confirmation"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ je reste souple. (conclusion)",
  "answer": "Donc"
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
    "exemple",
    "je",
    "peux",
    "indiquer",
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
  "word": "cependant",
  "hint": "Opposition posée : un « mais » de présentation."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Enfin je m'appelle Joël, d'abord je remercie.",
  "correct_sentence": "D'abord je m'appelle Joël. Enfin je remercie.",
  "explanation": "D'abord ouvre. Enfin ferme."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/micro-radio.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/carte-visite.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/service-propose.svg",
      "word": "un service"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/horloge-adverbe.svg",
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
  "prompt": "Recopiez une carte et changez deux articulateurs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les trois cartes, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Relier les idées',
    'PO',
    $c$Objectif
Enchaîner une présentation avec des mots de liaison.

Consigne
Répétez, puis présentez-vous en une minute.

Support — Modèles de Patrick
D'abord, je me présente.
Ensuite, je parle du poste.
Puis je donne un exemple.
Enfin, je remercie.
Cependant, je manque d'expérience le soir.
Donc j'apprends encore.
En effet, Aline m'aide.
Par exemple, je tiens déjà le cahier du matin.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Donc » tire une conclusion.",
  "correct": true,
  "explanation": "Donc j'apprends encore."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel mot confirme ce qui précède ?",
  "options": [
    {
      "text": "cependant",
      "correct": false
    },
    {
      "text": "en effet",
      "correct": true
    },
    {
      "text": "puis",
      "correct": false
    },
    {
      "text": "d'abord",
      "correct": false
    }
  ],
  "explanation": "En effet = confirmation."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'abord",
      "right": "ouvrir"
    },
    {
      "left": "puis",
      "right": "continuer"
    },
    {
      "left": "enfin",
      "right": "fermer"
    },
    {
      "left": "par exemple",
      "right": "illustrer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ , je remercie. (dernier mot d'ordre)",
  "answer": "Enfin"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Donc",
    "j'apprends",
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
  "word": "enfin",
  "hint": "Dernier mot de la série d'abord-ensuite-puis-…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "D'abord je remercie et enfin je me présente.",
  "correct_sentence": "D'abord je me présente. Enfin je remercie.",
  "explanation": "L'ordre des articulateurs suit l'ordre des idées."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/carte-visite.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/service-propose.svg",
      "word": "un service"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/horloge-adverbe.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/panier-lentement.svg",
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
  "prompt": "Écrivez une présentation de huit lignes, un articulateur par ligne."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis votre minute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma présentation écrite',
    'PE',
    $c$Objectif
Écrire une présentation professionnelle reliée.

Consigne
Imitez la présentation de Joël.

Support — Présentation de Joël Mugisha
Joël Mugisha
D'abord, je m'appelle Joël et je vise l'Atelier du Tissu.
Ensuite, je dis mes qualités : souriant, soigneux.
Puis je parle d'une compétence : je sais plier un coupon.
Cependant, je ne suis pas encore très rapide.
Donc je demande un essai le matin.
En effet, Dieudonné accepte les essais courts.
Par exemple, je peux ranger les coupons une heure.
Enfin, je vous remercie.
Joël
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël dit qu'il est déjà très rapide.",
  "correct": false,
  "explanation": "« Cependant, je ne suis pas encore très rapide. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel mot introduit l'opposition chez Joël ?",
  "options": [
    {
      "text": "donc",
      "correct": false
    },
    {
      "text": "ensuite",
      "correct": false
    },
    {
      "text": "cependant",
      "correct": true
    },
    {
      "text": "enfin",
      "correct": false
    }
  ],
  "explanation": "Cependant + manque de vitesse."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'abord",
      "right": "nom et poste"
    },
    {
      "left": "ensuite",
      "right": "qualités"
    },
    {
      "left": "cependant",
      "right": "limite"
    },
    {
      "left": "par exemple",
      "right": "ranger"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ , je vous remercie.",
  "answer": "Enfin"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Cependant",
    "je",
    "ne",
    "suis",
    "pas",
    "encore",
    "rapide",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "rapide",
  "hint": "Joël ne l'est pas encore : trop lent sur les coupons."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "D'abord je remercie. Enfin je m'appelle Joël.",
  "correct_sentence": "D'abord je m'appelle Joël. Enfin je vous remercie.",
  "explanation": "Ouverture puis clôture."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/service-propose.svg",
      "word": "un service"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/horloge-adverbe.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/panier-lentement.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/clef-soigneusement.svg",
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
  "prompt": "Imitez : huit lignes, au moins six articulateurs différents."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre présentation, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Articulateurs',
    'EL',
    $c$Objectif
Retenir d'abord, ensuite, puis, enfin, cependant, donc, en effet, par exemple.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
Ordre : d'abord → ensuite → puis → enfin
Opposition : cependant (plus posé que mais)
Conclusion : donc
Confirmation : en effet
Illustration : par exemple
D'abord s'écrit avec une apostrophe. Pas : dabord.
On ne commence pas tout par et. On varie.
Place : souvent en tête de phrase, suivis d'une virgule à l'écrit soigné.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« En effet » sert surtout à s'opposer.",
  "correct": false,
  "explanation": "En effet confirme. Cependant oppose."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série est dans le bon ordre ?",
  "options": [
    {
      "text": "enfin, d'abord, puis",
      "correct": false
    },
    {
      "text": "d'abord, ensuite, puis, enfin",
      "correct": true
    },
    {
      "text": "donc, d'abord, cependant",
      "correct": false
    },
    {
      "text": "par exemple, enfin, d'abord",
      "correct": false
    }
  ],
  "explanation": "D'abord… enfin."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'abord",
      "right": "1"
    },
    {
      "left": "ensuite / puis",
      "right": "2-3"
    },
    {
      "left": "enfin",
      "right": "4"
    },
    {
      "left": "donc",
      "right": "alors"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ , Aline l'a conseillé. (confirmation)",
  "answer": "En effet"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "D'abord",
    "je",
    "me",
    "présente",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "exemple",
  "hint": "Par… : on illustre une idée par un cas."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dabord je parle ensuite je finis sans apostrophe.",
  "correct_sentence": "D'abord je parle. Ensuite je finis.",
  "explanation": "D'abord, avec apostrophe."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/horloge-adverbe.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/panier-lentement.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/clef-soigneusement.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/carrefour-si.svg",
      "word": "un carrefour"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit mini-phrases, une par articulateur."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et une présentation reliée de trente secondes."
}$j$::jsonb,
    9
  );

  -- ===== Proposer un service =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Proposer un service'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Proposer un service', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Comment on s''y prend',
    'CO',
    $c$Objectif
Repérer les adverbes en -ment et les formes irrégulières.

Consigne
Lisez le dialogue. Comment chaque personne travaille-t-elle ?

Support — Atelier du Tissu, table longue
Dieudonné : Pliez lentement. Ne tirez pas trop vite sur le coupon.
Lila : À la radio, parlez vraiment clairement. Les auditeurs écoutent bien.
Patrick : Je peux mieux indiquer la cour si j'ai le plan.
Joël : Je range gentiment les chutes. Ibrahim m'a aidé énormément.
Aline : Notez précisément l'heure. Noura arrive soigneusement à l'heure.
Hawa : Félicie coupe facilement le pain, mais le tissu, c'est autre chose.
Rose : Poliment, on dit « je peux vous aider » plutôt que « donne-moi ça ».
Marc : Bien et mieux ne prennent pas -ment.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné demande de plier lentement.",
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
  "question": "Quel adverbe n'est pas formé avec -ment ?",
  "options": [
    {
      "text": "lentement",
      "correct": false
    },
    {
      "text": "vraiment",
      "correct": false
    },
    {
      "text": "mieux",
      "correct": true
    },
    {
      "text": "précisément",
      "correct": false
    }
  ],
  "explanation": "Bien / mieux : formes courtes."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lentement",
      "right": "sans précipitation"
    },
    {
      "left": "gentiment",
      "right": "avec gentillesse"
    },
    {
      "left": "énormément",
      "right": "beaucoup"
    },
    {
      "left": "précisément",
      "right": "avec exactitude"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPliez ___. Ne tirez pas trop vite.",
  "answer": "lentement"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Parlez",
    "vraiment",
    "clairement",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lentement",
  "hint": "Dieudonné : pliez sans précipiter, adverbe de lent."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je range gentillement les chutes.",
  "correct_sentence": "Je range gentiment les chutes.",
  "explanation": "Gentil → gentiment (pas gentillement)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/panier-lentement.svg",
      "word": "un panier"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/clef-soigneusement.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/carrefour-si.svg",
      "word": "un carrefour"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/deux-chemins.svg",
      "word": "un chemin"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Listez huit adverbes entendus et l'adjectif (s'il existe)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Pliez lentement. Parlez vraiment clairement. Je range gentiment. Notez précisément."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Cartes de service',
    'CE',
    $c$Objectif
Lire des propositions de service riches en adverbes.

Consigne
Lisez les cartes, sans aller trop vite.

Support — Panier ocre, Atelier du Tissu
Carte Dieudonné — Nous coupons soigneusement. Nous livrons lentement si le tissu est fragile.
Carte Lila — Nous lisons vraiment le texte avant l'antenne. Nous parlons clairement.
Carte Patrick — J'indique bien la cour. Je peux mieux le faire avec un plan.
Carte Joël — Je plie gentiment. J'ai appris énormément cette semaine.
Carte Aline — Marquez précisément le nom. Merci de frapper poliment à la porte.
Irréguliers utiles : gentiment, énormément, précisément. Aussi : bien, mieux.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick dit qu'il indique mal la cour.",
  "correct": false,
  "explanation": "« J'indique bien la cour. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a appris énormément cette semaine ?",
  "options": [
    {
      "text": "Lila",
      "correct": false
    },
    {
      "text": "Patrick",
      "correct": false
    },
    {
      "text": "Joël",
      "correct": true
    },
    {
      "text": "Aline",
      "correct": false
    }
  ],
  "explanation": "Carte Joël."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "soigneusement / lentement",
      "right": "tissu"
    },
    {
      "left": "vraiment / clairement",
      "right": "radio"
    },
    {
      "left": "bien / mieux",
      "right": "accueil"
    },
    {
      "left": "gentiment / énormément",
      "right": "Joël"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nMarquez ___ le nom. (exactitude)",
  "answer": "précisément"
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
    "parlons",
    "clairement",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "clairement",
  "hint": "Lila : une voix nette, sans brouillard."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous livrons lent si le tissu est fragile.",
  "correct_sentence": "Nous livrons lentement si le tissu est fragile.",
  "explanation": "Adverbe : lentement."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/clef-soigneusement.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/carrefour-si.svg",
      "word": "un carrefour"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/deux-chemins.svg",
      "word": "un chemin"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/choix-joel.svg",
      "word": "un choix"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez deux cartes et soulignez chaque adverbe."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les cinq cartes, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire comment on fait',
    'PO',
    $c$Objectif
Modifier un verbe avec un adverbe en -ment (ou bien / mieux).

Consigne
Répétez, puis proposez un service de la cour.

Support — Modèles de Lila
Je parle lentement.
Je lis vraiment le texte.
Je m'exprime bien.
Je peux mieux expliquer.
Je réponds gentiment.
J'écoute énormément.
Je note précisément.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'adverbe se place souvent après le verbe conjugué au présent.",
  "correct": true,
  "explanation": "Je parle lentement. Je note précisément."
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
      "text": "gentillement",
      "correct": false
    },
    {
      "text": "gentiment",
      "correct": true
    },
    {
      "text": "gentilement",
      "correct": false
    },
    {
      "text": "gentilment",
      "correct": false
    }
  ],
  "explanation": "Gentil → gentiment."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lent → lentement",
      "right": "e + ment"
    },
    {
      "left": "clair → clairement",
      "right": "-ement"
    },
    {
      "left": "gentil → gentiment",
      "right": "irrégulier"
    },
    {
      "left": "bien / mieux",
      "right": "sans -ment"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe réponds ___. (avec gentillesse)",
  "answer": "gentiment"
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
    "note",
    "précisément",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "vraiment",
  "hint": "Pas un peu : je lis… le texte, pour de bon."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je m'exprime bienment à l'antenne.",
  "correct_sentence": "Je m'exprime bien à l'antenne.",
  "explanation": "Bien, pas bienment."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/carrefour-si.svg",
      "word": "un carrefour"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/deux-chemins.svg",
      "word": "un chemin"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/choix-joel.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/nuage-hypothese.svg",
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
  "prompt": "Écrivez sept phrases, un adverbe différent à chaque ligne."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les sept modèles, puis un service à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma carte de service',
    'PE',
    $c$Objectif
Écrire une proposition de service avec des adverbes.

Consigne
Imitez la carte de Lila.

Support — Carte de Lila Sow
Lila Sow — Radio Figuier
Nous préparons vraiment le texte.
Nous parlons lentement, puis plus clairement.
Nous accueillons gentiment les voix du Seuil.
Joël nous a aidés énormément sur les horaires.
Notez précisément votre prénom avant l'antenne.
Vous pouvez mieux vous entendre si le micro est près.
Lila
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila demande d'écrire le prénom n'importe comment.",
  "correct": false,
  "explanation": "« Notez précisément votre prénom. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a aidé énormément sur les horaires ?",
  "options": [
    {
      "text": "Patrick",
      "correct": false
    },
    {
      "text": "Dieudonné",
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
  "explanation": "« Joël nous a aidés énormément. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "vraiment",
      "right": "préparer"
    },
    {
      "left": "lentement / clairement",
      "right": "parler"
    },
    {
      "left": "gentiment",
      "right": "accueillir"
    },
    {
      "left": "précisément",
      "right": "prénom"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVous pouvez ___ vous entendre si le micro est près.",
  "answer": "mieux"
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
    "parlons",
    "lentement",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "énormément",
  "hint": "Joël a beaucoup aidé : adverbe d'énorme."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous parlons lent et claire à l'antenne.",
  "correct_sentence": "Nous parlons lentement, puis plus clairement.",
  "explanation": "Adverbes : lentement, clairement."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/deux-chemins.svg",
      "word": "un chemin"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/choix-joel.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/nuage-hypothese.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/ligne-temps.svg",
      "word": "une ligne"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes, cinq adverbes différents."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre carte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Adverbes en -ment',
    'EL',
    $c$Objectif
Retenir la formation des adverbes et les irréguliers utiles.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
Souvent : adjectif féminin + ment.
lent → lente → lentement. clair → claire → clairement.
vrai → vraie → vraiment. poli → polie → poliment.
facile → facilement (déjà en -e).
Irréguliers : gentil → gentiment (pas gentillement)
énorme → énormément. précis → précisément.
bien et mieux : pas de -ment. On ne dit pas plus bien : on dit mieux.
Place fréquente : après le verbe. Aux temps composés : souvent avant le participe
(nous avons vraiment lu) ou après, selon le rythme.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On forme « gentillement » à partir de gentil.",
  "correct": false,
  "explanation": "Gentiment."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Le comparatif de « bien », c'est…",
  "options": [
    {
      "text": "plus bien",
      "correct": false
    },
    {
      "text": "bienment",
      "correct": false
    },
    {
      "text": "mieux",
      "correct": true
    },
    {
      "text": "meilleurment",
      "correct": false
    }
  ],
  "explanation": "Mieux."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lentement",
      "right": "lent"
    },
    {
      "left": "gentiment",
      "right": "gentil"
    },
    {
      "left": "énormément",
      "right": "énorme"
    },
    {
      "left": "mieux",
      "right": "bien"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nGentil → ___.",
  "answer": "gentiment"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Notez",
    "précisément",
    "l'heure",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "précisément",
  "hint": "Sans à-peu-près : adverbe de précis, avec deux accents."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il travaille plus bien que moi à l'atelier.",
  "correct_sentence": "Il travaille mieux que moi à l'atelier.",
  "explanation": "Mieux remplace plus bien."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/choix-joel.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/nuage-hypothese.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/ligne-temps.svg",
      "word": "une ligne"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/plus-que-parfait.svg",
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
  "prompt": "Formez dix adverbes et signalez les irréguliers."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six adverbes en phrase."
}$j$::jsonb,
    9
  );

  -- ===== Oser un choix =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Oser un choix'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Oser un choix', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Deux chemins, une décision',
    'CO',
    $c$Objectif
Comprendre l'hypothèse : si + présent, et la suite au présent, au futur ou à l'impératif.

Consigne
Lisez le dialogue. Que se passe-t-il si… ?

Support — Carrefour derrière l'atelier
Aline : Si tu postules à l'atelier, tu apprends le tissu.
Dieudonné : Si tu viens le matin, tu auras un essai.
Lila : Si Joël choisit la radio, il sera à l'antenne jeudi.
Patrick : Si j'ai une question, je demande. Si tu hésites, appelle Aline.
Joël : Si elle accepte, je ferai le tour de l'atelier.
Hawa : Si vous choisissez l'accueil, vous serez sous le figuier.
Marc : Si on part trop tard, on rate Lila.
Rose : Si tu peux, reste jusqu'à midi.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Si Joël choisit la radio, il sera à l'antenne jeudi.",
  "correct": true,
  "explanation": "Lila : futur après si + présent."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle suite est à l'impératif ?",
  "options": [
    {
      "text": "tu apprends le tissu",
      "correct": false
    },
    {
      "text": "tu auras un essai",
      "correct": false
    },
    {
      "text": "appelle Aline",
      "correct": true
    },
    {
      "text": "il sera à l'antenne",
      "correct": false
    }
  ],
  "explanation": "Si tu hésites, appelle Aline."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si + présent → présent",
      "right": "habitude / règle"
    },
    {
      "left": "si + présent → futur",
      "right": "conséquence plus tard"
    },
    {
      "left": "si + présent → impératif",
      "right": "conseil"
    },
    {
      "left": "si tu peux, reste",
      "right": "ordre doux"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi tu viens le matin, tu ___ un essai. (avoir, futur)",
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
    "Si",
    "tu",
    "hésites",
    "appelle",
    "Aline",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "postules",
  "hint": "Si tu… à l'atelier : tu déposes ta candidature."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tu postulera, tu apprends le tissu.",
  "correct_sentence": "Si tu postules, tu apprends le tissu.",
  "explanation": "Après si : présent (pas futur)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/nuage-hypothese.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/ligne-temps.svg",
      "word": "une ligne"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/plus-que-parfait.svg",
      "word": "un souvenir"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/ancien-poste.svg",
      "word": "un poste"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez trois si… présent, deux si… futur, un si… impératif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Si tu postules, tu apprends. Si tu viens, tu auras un essai. Si tu hésites, appelle."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Billets de carrefour',
    'CE',
    $c$Objectif
Lire des conseils hypothétiques avec si.

Consigne
Lisez les billets, sans aller trop vite.

Support — Billets d'Aline, pince ocre
Billet 1 — Si vous arrivez à l'heure, Dieudonné ouvre l'atelier.
Billet 2 — Si Patrick choisit l'accueil, il sera près du figuier.
Billet 3 — Si Joël a le trac, qu'il respire. S'il peut, qu'il répète.
Billet 4 — Si Lila dit oui, vous ferez une voix d'essai.
Billet 5 — Si on manque de coupon, on attend. Si on peut, on prévient.
Attention : après si, pas de futur. On dit si tu viens, pas si tu viendras.
Je ferai (un r). Je pourrai (deux r). Je serai (pas je sera).
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « si tu viendras » dans ces billets.",
  "correct": false,
  "explanation": "« après si, pas de futur »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Si Lila dit oui, que se passera-t-il ?",
  "options": [
    {
      "text": "L'atelier ferme",
      "correct": false
    },
    {
      "text": "Une voix d'essai",
      "correct": true
    },
    {
      "text": "On manque de coupon",
      "correct": false
    },
    {
      "text": "Patrick part",
      "correct": false
    }
  ],
  "explanation": "« vous ferez une voix d'essai »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si vous arrivez",
      "right": "présent → présent"
    },
    {
      "left": "si Patrick choisit",
      "right": "présent → futur"
    },
    {
      "left": "s'il peut",
      "right": "impératif / conseil"
    },
    {
      "left": "si Lila dit oui",
      "right": "vous ferez"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi Lila dit oui, vous ___ une voix d'essai. (faire, futur)",
  "answer": "ferez"
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
    "vous",
    "arrivez",
    "à",
    "l'heure",
    "il",
    "ouvre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ferez",
  "hint": "Vous… une voix : futur de faire, vous, un seul r."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tu viendras le matin, tu auras un essai.",
  "correct_sentence": "Si tu viens le matin, tu auras un essai.",
  "explanation": "Si + présent, pas si + futur."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/ligne-temps.svg",
      "word": "une ligne"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/plus-que-parfait.svg",
      "word": "un souvenir"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/ancien-poste.svg",
      "word": "un poste"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/nouveau-badge.svg",
      "word": "un badge"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Réécrivez trois billets en changeant la conséquence (présent / futur / impératif)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les cinq billets, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire si… alors',
    'PO',
    $c$Objectif
Construire une hypothèse réaliste à l'oral.

Consigne
Répétez, puis choisissez un poste à voix haute.

Support — Modèles de Joël
Si je postule, j'apprends.
Si je viens tôt, j'aurai un essai.
Si tu hésites, demande.
Si elle accepte, je ferai le tour.
Si nous choisissons la radio, nous serons à l'antenne.
Si vous pouvez, restez.
Si on part tard, on rate Lila.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je ferai » s'écrit avec un seul r.",
  "correct": true,
  "explanation": "Faire au futur : je ferai."
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
      "text": "Si je posterai, j'apprends",
      "correct": false
    },
    {
      "text": "Si je postule, j'apprendrai",
      "correct": true
    },
    {
      "text": "Si je postulais demain sûr",
      "correct": false
    },
    {
      "text": "Si je sera pris",
      "correct": false
    }
  ],
  "explanation": "Si + présent, conséquence au futur possible."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si + présent",
      "right": "condition"
    },
    {
      "left": "présent",
      "right": "règle"
    },
    {
      "left": "futur",
      "right": "plus tard"
    },
    {
      "left": "impératif",
      "right": "conseil"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi elle accepte, je ___ le tour. (faire, futur)",
  "answer": "ferai"
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
    "tu",
    "hésites",
    "demande",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ferai",
  "hint": "Je… le tour : futur de faire, je, un seul r."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si elle accepte, je fera le tour.",
  "correct_sentence": "Si elle accepte, je ferai le tour.",
  "explanation": "Je ferai (un r, terminaison -ai)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/plus-que-parfait.svg",
      "word": "un souvenir"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/ancien-poste.svg",
      "word": "un poste"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/nouveau-badge.svg",
      "word": "un badge"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/question-formelle.svg",
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
  "prompt": "Écrivez six hypothèses : deux présent, deux futur, deux impératif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis votre choix oral."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon billet de choix',
    'PE',
    $c$Objectif
Écrire un choix avec des phrases en si.

Consigne
Imitez le billet d'Aline.

Support — Billet d'Aline Uwase
Aline Uwase
Si tu postules à l'atelier, tu apprends le tissu.
Si tu viens le matin, tu auras un essai chez Dieudonné.
Si tu choisis la radio, tu seras avec Lila.
Si tu as une question, demande.
Si Joël vient, je pourrai l'aider.
Si vous pouvez, restez jusqu'à midi.
Aline
Carrefour de la cour
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline écrit « je pourra » avec un seul r.",
  "correct": false,
  "explanation": "« je pourrai l'aider » : deux r."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faire si on a une question ?",
  "options": [
    {
      "text": "Partir",
      "correct": false
    },
    {
      "text": "Demander",
      "correct": true
    },
    {
      "text": "Se taire",
      "correct": false
    },
    {
      "text": "Couper le tissu",
      "correct": false
    }
  ],
  "explanation": "« Si tu as une question, demande. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si tu postules",
      "right": "tu apprends"
    },
    {
      "left": "si tu viens",
      "right": "tu auras"
    },
    {
      "left": "si tu as une question",
      "right": "demande"
    },
    {
      "left": "si Joël vient",
      "right": "je pourrai"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi Joël vient, je ___ l'aider. (pouvoir, futur)",
  "answer": "pourrai"
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
    "tu",
    "as",
    "une",
    "question",
    "demande",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pourrai",
  "hint": "Je… aider : futur de pouvoir, deux r, je."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tu choisis la radio, tu sera avec Lila.",
  "correct_sentence": "Si tu choisis la radio, tu seras avec Lila.",
  "explanation": "Tu seras (pas tu sera)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/ancien-poste.svg",
      "word": "un poste"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/nouveau-badge.svg",
      "word": "un badge"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/question-formelle.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/reponse-assurance.svg",
      "word": "une réponse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes en si, les trois suites (présent, futur, impératif)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre billet, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Si + présent',
    'EL',
    $c$Objectif
Retenir les trois suites possibles après si + présent.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
Si + présent, + présent : règle, habitude.
Si tu postules, tu apprends.
Si + présent, + futur : conséquence plus tard.
Si tu viens, tu auras un essai. Si elle accepte, je ferai le tour.
Si + présent, + impératif : conseil.
Si tu hésites, appelle. Si vous pouvez, restez.
Jamais : si tu viendras. Le futur est dans l'autre partie.
Futurs utiles : je serai, tu seras ; je ferai (1 r) ; je pourrai (2 r).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On met le futur juste après si : si tu viendras.",
  "correct": false,
  "explanation": "Si + présent seulement, dans ce système."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Pouvoir » au futur, je…",
  "options": [
    {
      "text": "je pourai",
      "correct": false
    },
    {
      "text": "je pourrai",
      "correct": true
    },
    {
      "text": "je pourra",
      "correct": false
    },
    {
      "text": "je peuxrai",
      "correct": false
    }
  ],
  "explanation": "Je pourrai, deux r."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si + présent + présent",
      "right": "règle"
    },
    {
      "left": "si + présent + futur",
      "right": "plus tard"
    },
    {
      "left": "si + présent + impératif",
      "right": "conseil"
    },
    {
      "left": "je ferai",
      "right": "un r"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi tu viens, tu ___ un essai. (avoir, futur)",
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
    "Si",
    "vous",
    "pouvez",
    "restez",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "auras",
  "hint": "Tu… un essai : futur d'avoir, tu."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si je pourrai venir, j'apprends le tissu.",
  "correct_sentence": "Si je peux venir, j'apprendrai le tissu.",
  "explanation": "Pas de futur dans la partie si."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/nouveau-badge.svg",
      "word": "un badge"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/question-formelle.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/reponse-assurance.svg",
      "word": "une réponse"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/liste-indefinis.svg",
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
  "prompt": "Complétez un tableau : six si, trois colonnes de suites."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six hypothèses."
}$j$::jsonb,
    9
  );

  -- ===== Un parcours à raconter =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un parcours à raconter'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un parcours à raconter', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Avant l''entretien',
    'CO',
    $c$Objectif
Comprendre le plus-que-parfait : un passé déjà fini avant un autre passé.

Consigne
Lisez le dialogue. Qu'est-ce qui s'était passé avant ?

Support — Banc près de l'atelier
Patrick : Avant l'essai, j'avais déjà tenu l'accueil trois matins.
Joël : Moi, j'avais plié des coupons chez Dieudonné, l'an dernier.
Aline : Léa est arrivée, mais elle avait préparé ses phrases la veille.
Lila : Nous avions écouté l'émission avant de postuler.
Hawa : Tu avais fini le cahier quand Marc l'a demandé.
Rose : Ils avaient postulé trop tard : la place était prise.
Dieudonné : J'avais ouvert l'atelier avant que le groupe n'arrive.
Marc : Elle s'était présentée clairement : Aline l'avait aidée.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick avait déjà tenu l'accueil avant l'essai.",
  "correct": true,
  "explanation": "Plus-que-parfait : j'avais déjà tenu."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quand Léa a-t-elle préparé ses phrases ?",
  "options": [
    {
      "text": "Après l'arrivée",
      "correct": false
    },
    {
      "text": "La veille",
      "correct": true
    },
    {
      "text": "Pendant l'essai",
      "correct": false
    },
    {
      "text": "Jamais",
      "correct": false
    }
  ],
  "explanation": "Elle avait préparé ses phrases la veille."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "j'avais tenu",
      "right": "avant l'essai"
    },
    {
      "left": "j'avais plié",
      "right": "l'an dernier"
    },
    {
      "left": "elle avait préparé",
      "right": "la veille"
    },
    {
      "left": "nous avions écouté",
      "right": "avant de postuler"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'___ déjà tenu l'accueil trois matins.",
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
    "Nous",
    "avions",
    "écouté",
    "l'émission",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "avions",
  "hint": "Nous… écouté : auxiliaire avoir à l'imparfait, nous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai déjà tenu l'accueil avant que l'essai commence.",
  "correct_sentence": "J'avais déjà tenu l'accueil avant l'essai.",
  "explanation": "Passé avant un autre passé → plus-que-parfait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/question-formelle.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/reponse-assurance.svg",
      "word": "une réponse"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/liste-indefinis.svg",
      "word": "une liste"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/porte-entretien.svg",
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
  "prompt": "Notez cinq actions déjà finies avant une autre."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : J'avais déjà tenu l'accueil. Elle avait préparé ses phrases. Nous avions écouté."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Extraits de parcours',
    'CE',
    $c$Objectif
Lire des extraits de CV racontés au plus-que-parfait.

Consigne
Lisez les extraits, sans aller trop vite.

Support — Cahier de notes, Table des Sources
Extrait Patrick — Quand Aline m'a appelé, j'avais rangé le cahier de la cour.
Extrait Joël — Dieudonné m'a repris parce que j'avais oublié un pli.
Extrait Léa — Avant Radio Figuier, j'avais lu trois textes à voix haute.
Extrait Hawa — Nous étions prêts : nous avions répété avec Noura.
Extrait Ibrahim — Certains étaient partis ; ils avaient fini trop tôt.
Forme : avoir (ou être) à l'imparfait + participe passé.
j'avais travaillé / elle était déjà partie / nous nous étions présentés.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël avait oublié un pli avant que Dieudonné le reprenne.",
  "correct": true,
  "explanation": "« j'avais oublié un pli »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui avait répété avec Noura ?",
  "options": [
    {
      "text": "Patrick seul",
      "correct": false
    },
    {
      "text": "Léa seule",
      "correct": false
    },
    {
      "text": "Hawa et son groupe",
      "correct": true
    },
    {
      "text": "Ibrahim seul",
      "correct": false
    }
  ],
  "explanation": "Extrait Hawa : nous avions répété."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "j'avais rangé",
      "right": "Patrick"
    },
    {
      "left": "j'avais oublié",
      "right": "Joël"
    },
    {
      "left": "j'avais lu",
      "right": "Léa"
    },
    {
      "left": "nous avions répété",
      "right": "Hawa"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nElle ___ déjà partie. (être, imparfait)",
  "answer": "était"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'avais",
    "rangé",
    "le",
    "cahier",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "oublié",
  "hint": "Joël l'avait… : un pli manquait, avant la reprise."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quand Aline m'a appelé, j'ai rangé le cahier juste avant dans ma tête.",
  "correct_sentence": "Quand Aline m'a appelé, j'avais rangé le cahier.",
  "explanation": "L'action est déjà finie : plus-que-parfait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/reponse-assurance.svg",
      "word": "une réponse"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/liste-indefinis.svg",
      "word": "une liste"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/porte-entretien.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/atelier-tissu.svg",
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
  "prompt": "Recopiez deux extraits et encadrez l'auxiliaire à l'imparfait."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les cinq extraits, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire j''avais + participe',
    'PO',
    $c$Objectif
Raconter un avant-passé à l'oral.

Consigne
Répétez, puis parlez d'un geste déjà fait avant aujourd'hui.

Support — Modèles de Patrick
J'avais travaillé.
Tu avais fini.
Elle avait postulé.
Nous avions appris.
Vous aviez écouté.
Ils avaient attendu.
Je m'étais présenté.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le plus-que-parfait = imparfait de l'auxiliaire + participe.",
  "correct": true,
  "explanation": "J'avais travaillé. Elle était partie."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est un plus-que-parfait ?",
  "options": [
    {
      "text": "j'ai travaillé",
      "correct": false
    },
    {
      "text": "je travaillais",
      "correct": false
    },
    {
      "text": "j'avais travaillé",
      "correct": true
    },
    {
      "text": "je travaillerai",
      "correct": false
    }
  ],
  "explanation": "J'avais + PP."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "j'avais",
      "right": "je"
    },
    {
      "left": "nous avions",
      "right": "nous"
    },
    {
      "left": "elle était partie",
      "right": "être"
    },
    {
      "left": "je m'étais présenté",
      "right": "pronominal"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTu ___ fini avant midi.",
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
    "Elle",
    "avait",
    "postulé",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "travaillé",
  "hint": "Patrick l'avait déjà… : un travail avant l'essai."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous avons appris avant de postuler, c'était plus tôt que postuler.",
  "correct_sentence": "Nous avions appris avant de postuler.",
  "explanation": "Avant un autre passé : avions + PP."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/liste-indefinis.svg",
      "word": "une liste"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/porte-entretien.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/atelier-tissu.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/table-sources-pro.svg",
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
  "prompt": "Écrivez six plus-que-parfaits, personnes différentes."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les sept modèles, puis deux phrases à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon parcours d''avant',
    'PE',
    $c$Objectif
Écrire un parcours avec le plus-que-parfait.

Consigne
Imitez le parcours de Patrick.

Support — Parcours de Patrick Habimana
Patrick Habimana
Avant l'essai, j'avais déjà tenu l'accueil trois matins.
J'avais rangé le cahier quand Aline m'a appelé.
Nous avions écouté Radio Figuier la veille.
Joël m'avait prêté un plan de la cour.
Je m'étais présenté poliment.
Je n'avais pas encore vu l'atelier de l'intérieur.
Patrick
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick avait déjà vu tout l'atelier.",
  "correct": false,
  "explanation": "« Je n'avais pas encore vu l'atelier de l'intérieur. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui avait prêté un plan ?",
  "options": [
    {
      "text": "Aline",
      "correct": false
    },
    {
      "text": "Lila",
      "correct": false
    },
    {
      "text": "Joël",
      "correct": true
    },
    {
      "text": "Dieudonné",
      "correct": false
    }
  ],
  "explanation": "« Joël m'avait prêté un plan. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "j'avais tenu",
      "right": "accueil"
    },
    {
      "left": "j'avais rangé",
      "right": "cahier"
    },
    {
      "left": "nous avions écouté",
      "right": "radio"
    },
    {
      "left": "je m'étais présenté",
      "right": "poliment"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJoël m'___ prêté un plan.",
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
    "Je",
    "m'étais",
    "présenté",
    "poliment",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "prêté",
  "hint": "Joël l'avait… : le plan de la cour, avant l'essai."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avant l'essai, j'ai déjà tenu l'accueil depuis trois matins passés.",
  "correct_sentence": "Avant l'essai, j'avais déjà tenu l'accueil trois matins.",
  "explanation": "Plus-que-parfait pour l'avant-passé."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/porte-entretien.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/atelier-tissu.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/table-sources-pro.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/cahier-notes.svg",
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
  "prompt": "Imitez : six lignes, au moins cinq plus-que-parfaits."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre parcours, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Plus-que-parfait',
    'EL',
    $c$Objectif
Retenir la forme et l'emploi du plus-que-parfait.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
Plus-que-parfait = un passé déjà fini avant un autre passé.
Forme : avoir à l'imparfait + PP. j'avais, tu avais, il/elle avait,
nous avions, vous aviez, ils/elles avaient + participe.
Avec être : j'étais allé(e), elle était déjà partie.
Pronominal : je m'étais présenté(e).
Emploi : avant l'essai, la veille, quand + PC (l'autre action).
On ne remplace pas toujours le PC par le PQP : il faut un « avant ».
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« J'avais » + participe forme le plus-que-parfait.",
  "correct": true,
  "explanation": "J'avais travaillé."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Aller » au plus-que-parfait, Léa :",
  "options": [
    {
      "text": "elle a allé",
      "correct": false
    },
    {
      "text": "elle allait",
      "correct": false
    },
    {
      "text": "elle était allée",
      "correct": true
    },
    {
      "text": "elle sera allée",
      "correct": false
    }
  ],
  "explanation": "Être à l'imparfait + allée."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "j'avais + PP",
      "right": "avoir"
    },
    {
      "left": "j'étais allé(e)",
      "right": "être"
    },
    {
      "left": "la veille",
      "right": "indice"
    },
    {
      "left": "avant l'essai",
      "right": "emploi"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ appris le texte avant l'antenne.",
  "answer": "avions"
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
    "était",
    "déjà",
    "partie",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "partie",
  "hint": "Elle était déjà… : être + PP, féminin, avant les autres."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Léa a été allée avant l'entretien trop tôt.",
  "correct_sentence": "Léa était déjà allée à l'atelier avant l'entretien.",
  "explanation": "Plus-que-parfait avec être : était allée."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/atelier-tissu.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/table-sources-pro.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/cahier-notes.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/tampon-ok.svg",
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
  "prompt": "Conjuguez cinq verbes au PQP (je / elle / nous) avec un indice de temps."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et cinq phrases d'avant-passé."
}$j$::jsonb,
    9
  );

  -- ===== Répondre avec assurance =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Répondre avec assurance'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Répondre avec assurance', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Questions d''entretien',
    'CO',
    $c$Objectif
Repérer est-ce que, l'inversion, et les adjectifs indéfinis.

Consigne
Lisez le dialogue. Comment pose-t-on les questions ?

Support — Porte de l'atelier, essai du matin
Dieudonné : Est-ce que vous avez déjà plié un coupon ?
Lila : Avez-vous un exemple précis ?
Aline : Travaillez-vous chaque matin ?
Patrick : Puis-je poser une question ? Tout le monde écoute-t-il ?
Joël : Plusieurs ateliers ouvrent-ils le jeudi ?
Hawa : Certains jours, aucun bus ne passe. Est-ce que c'est vrai ?
Rose : Qu'avez-vous appris à l'accueil ?
Marc : Aucune expérience n'est trop petite, dit Aline.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Avez-vous un exemple » est une inversion.",
  "correct": true,
  "explanation": "Verbe + sujet : avez-vous."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel mot veut dire « pas une seule » au féminin ?",
  "options": [
    {
      "text": "chaque",
      "correct": false
    },
    {
      "text": "plusieurs",
      "correct": false
    },
    {
      "text": "certains",
      "correct": false
    },
    {
      "text": "aucune",
      "correct": true
    }
  ],
  "explanation": "Aucune expérience."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "est-ce que",
      "right": "question posée"
    },
    {
      "left": "avez-vous",
      "right": "inversion"
    },
    {
      "left": "chaque matin",
      "right": "tous les matins"
    },
    {
      "left": "aucun / aucune",
      "right": "zéro"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ -vous un exemple précis ?",
  "answer": "Avez"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Est-ce",
    "que",
    "vous",
    "avez",
    "déjà",
    "plié",
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
  "word": "chaque",
  "hint": "Aline : … matin, sans exception, à la même heure."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avez vous un exemple précis ?",
  "correct_sentence": "Avez-vous un exemple précis ?",
  "explanation": "Inversion : trait d'union."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/table-sources-pro.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/cahier-notes.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/tampon-ok.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/main-poignee.svg",
      "word": "une poignée"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez trois questions formelles et quatre indéfinis."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Est-ce que vous avez déjà plié ? Avez-vous un exemple ? Travaillez-vous chaque matin ?"
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fiche d''entretien',
    'CE',
    $c$Objectif
Lire une fiche de questions et d'indéfinis.

Consigne
Lisez la fiche, sans aller trop vite.

Support — Fiche de Dieudonné Hakizimana
Entretien — Atelier du Tissu / relais Radio Figuier
1. Est-ce que vous connaissez le Seuil ?
2. Pouvez-vous rester toute la matinée ?
3. Qu'avez-vous déjà fait à l'accueil ?
4. Chaque commande a un nom. Avez-vous noté le vôtre ?
5. Plusieurs coupons attendent. Certains sont fragiles.
6. Aucun retard n'est acceptable après la troisième fois.
7. Tout le monde signe le cahier.
Lila ajoute : Écoutez-vous vraiment les consignes ?
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On tolère tous les retards sans limite.",
  "correct": false,
  "explanation": "« Aucun retard n'est acceptable après la troisième fois. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui doit signer le cahier ?",
  "options": [
    {
      "text": "Patrick seulement",
      "correct": false
    },
    {
      "text": "Tout le monde",
      "correct": true
    },
    {
      "text": "Certains invités",
      "correct": false
    },
    {
      "text": "Aucun stagiaire",
      "correct": false
    }
  ],
  "explanation": "« Tout le monde signe le cahier. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "est-ce que vous connaissez",
      "right": "forme longue"
    },
    {
      "left": "pouvez-vous",
      "right": "inversion"
    },
    {
      "left": "plusieurs / certains",
      "right": "une partie"
    },
    {
      "left": "aucun retard",
      "right": "zéro"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ le monde signe le cahier.",
  "answer": "Tout"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Pouvez-vous",
    "rester",
    "toute",
    "la",
    "matinée",
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
  "word": "plusieurs",
  "hint": "Pas un seul coupon : … coupons attendent sur la table."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aucun retard sont acceptables le lundi.",
  "correct_sentence": "Aucun retard n'est acceptable.",
  "explanation": "Aucun + nom singulier + ne… (accord au singulier)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/cahier-notes.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/tampon-ok.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/main-poignee.svg",
      "word": "une poignée"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/etoile-qualite.svg",
      "word": "une étoile"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la fiche et transformez deux est-ce que en inversion."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les sept points, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Questionner et préciser',
    'PO',
    $c$Objectif
Poser une question formelle et utiliser un indéfini.

Consigne
Répétez, puis jouez deux minutes d'entretien.

Support — Modèles d'Aline
Est-ce que vous êtes prêt ?
Avez-vous un exemple ?
Travaillez-vous chaque matin ?
Puis-je entrer ?
Plusieurs personnes attendent.
Certains jours, c'est calme.
Aucun bus ne passe.
Tout le monde écoute.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Puis-je » est une inversion polie de je peux.",
  "correct": true,
  "explanation": "Puis-je entrer ?"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle question utilise est-ce que ?",
  "options": [
    {
      "text": "Avez-vous un exemple",
      "correct": false
    },
    {
      "text": "Est-ce que vous êtes prêt",
      "correct": true
    },
    {
      "text": "Puis-je entrer",
      "correct": false
    },
    {
      "text": "Travaillez-vous chaque matin",
      "correct": false
    }
  ],
  "explanation": "Est-ce que + sujet + verbe."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "est-ce que",
      "right": "forme claire"
    },
    {
      "left": "inversion",
      "right": "verbe-sujet"
    },
    {
      "left": "chaque / tout",
      "right": "totalité"
    },
    {
      "left": "plusieurs / certains / aucun",
      "right": "quantité"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ -je entrer ?",
  "answer": "Puis"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Aucun",
    "bus",
    "ne",
    "passe",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "certains",
  "hint": "Pas tous les jours : … jours seulement, c'est calme."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Est-ce que travaillez-vous chaque matin ?",
  "correct_sentence": "Est-ce que vous travaillez chaque matin ?",
  "explanation": "On choisit est-ce que OU l'inversion, pas les deux."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/tampon-ok.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/main-poignee.svg",
      "word": "une poignée"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/etoile-qualite.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/offre-atelier.svg",
      "word": "une offre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez quatre questions (2 est-ce que, 2 inversions) et quatre indéfinis."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis trois questions à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma feuille d''entretien',
    'PE',
    $c$Objectif
Écrire des questions formelles et des réponses avec des indéfinis.

Consigne
Imitez la feuille de Dieudonné.

Support — Feuille de Dieudonné Hakizimana
Dieudonné Hakizimana
Est-ce que vous connaissez l'atelier ?
Avez-vous déjà plié un coupon ?
Travaillez-vous chaque matin ?
Plusieurs commandes attendent. Certains tissus sont fragiles.
Aucun outil ne sort sans note.
Tout le monde range avant midi.
Puis-je compter sur vous ?
Dieudonné
Atelier du Tissu
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné autorise de sortir les outils sans note.",
  "correct": false,
  "explanation": "« Aucun outil ne sort sans note. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle question est une inversion avec je ?",
  "options": [
    {
      "text": "Est-ce que vous connaissez l'atelier",
      "correct": false
    },
    {
      "text": "Avez-vous déjà plié un coupon",
      "correct": false
    },
    {
      "text": "Puis-je compter sur vous",
      "correct": true
    },
    {
      "text": "Tout le monde range",
      "correct": false
    }
  ],
  "explanation": "Puis-je…"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "est-ce que vous connaissez",
      "right": "atelier"
    },
    {
      "left": "avez-vous déjà plié",
      "right": "coupon"
    },
    {
      "left": "chaque matin",
      "right": "rythme"
    },
    {
      "left": "aucun outil",
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
  "prompt": "Complétez :\n___ outil ne sort sans note.",
  "answer": "Aucun"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Avez-vous",
    "déjà",
    "plié",
    "un",
    "coupon",
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
  "word": "aucun",
  "hint": "Zéro outil dehors : … outil ne sort sans note."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Est-ce que avez-vous déjà plié un coupon ?",
  "correct_sentence": "Avez-vous déjà plié un coupon ?",
  "explanation": "Pas d'est-ce que + inversion ensemble."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/main-poignee.svg",
      "word": "une poignée"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/etoile-qualite.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/offre-atelier.svg",
      "word": "une offre"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/cv-patrick.svg",
      "word": "un CV"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : sept lignes, trois questions formelles, trois indéfinis."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre feuille, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Questions et indéfinis',
    'EL',
    $c$Objectif
Retenir est-ce que, l'inversion simple, et chaque / tout / plusieurs / certains / aucun.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
Question formelle :
est-ce que + sujet + verbe : Est-ce que vous êtes prêt ?
inversion : verbe + sujet : Avez-vous un exemple ? Travaillez-vous ?
Puis-je (pas peux-je, peu usité). Qu'avez-vous appris ?
On n'empile pas : est-ce que avez-vous… (incorrect).
Indéfinis : chaque (singulier) ; tout / toute / tous / toutes ;
plusieurs (pluriel) ; certains / certaines ; aucun / aucune + ne.
Chaque matin. Tout le monde. Plusieurs ateliers.
Certains jours. Aucun retard. Aucune expérience n'est inutile.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut dire « est-ce que avez-vous ».",
  "correct": false,
  "explanation": "Une seule forme à la fois."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Aucun » s'accorde comment avec « expérience » ?",
  "options": [
    {
      "text": "aucun expérience",
      "correct": false
    },
    {
      "text": "aucune expérience",
      "correct": true
    },
    {
      "text": "aucuns expériences",
      "correct": false
    },
    {
      "text": "aucune expériences",
      "correct": false
    }
  ],
  "explanation": "Aucune + nom féminin singulier."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "est-ce que",
      "right": "forme longue"
    },
    {
      "left": "inversion",
      "right": "forme courte"
    },
    {
      "left": "chaque / tout",
      "right": "totalité"
    },
    {
      "left": "aucun / aucune",
      "right": "zéro + ne"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ expérience n'est inutile. (zéro, fém.)",
  "answer": "Aucune"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Travaillez-vous",
    "chaque",
    "matin",
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
  "hint": "Avez-vous : le verbe passe devant le sujet, cette…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aucun expériences ne sont inutiles.",
  "correct_sentence": "Aucune expérience n'est inutile.",
  "explanation": "Aucune + singulier. Ne… pas de pluriel ici."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m3/etoile-qualite.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/offre-atelier.svg",
      "word": "une offre"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/cv-patrick.svg",
      "word": "un CV"
    },
    {
      "image_path": "/elearning/mfk-a2-m3/qualite-equipe.svg",
      "word": "une qualité"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez six questions formelles et une phrase pour chaque indéfini."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis un mini-entretien de six répliques."
}$j$::jsonb,
    9
  );

END;
$$;
