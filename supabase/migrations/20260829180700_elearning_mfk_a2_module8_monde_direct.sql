/*
  Seed eLearning MFK — A2 — Le monde en direct

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a2-m8/
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
  v_module_title text := 'A2 — Le monde en direct';
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
      'Grande étape A2-8 : raconter un fait à la voix passive, nominaliser une info, réagir avec le gérondif, suggérer au conditionnel, espérer au subjonctif et parler d''un livre avec on — depuis le studio de Radio Figuier, émission « Le monde en direct », au Seuil des Sources (Rukiri-Nord).',
      'A2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape A2-8 : raconter un fait à la voix passive, nominaliser une info, réagir avec le gérondif, suggérer au conditionnel, espérer au subjonctif et parler d''un livre avec on — depuis le studio de Radio Figuier, émission « Le monde en direct », au Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'A2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Un fait à raconter =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un fait à raconter'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un fait à raconter', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Ouverture d''antenne',
    'CO',
    $c$Objectif
Repérer le passif : être + participe (a été + PP) et le complément d'agent par.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui fait ? Qu'est-ce qui est fait ?

Support — Studio de Radio Figuier, casque de Léa
Léa : Bonjour. Ici Radio Figuier, « Le monde en direct ».
Marc : Le pont des Herbes a été réparé hier. Il a été consolidé par Dieudonné.
Aline : La nouvelle a été lue à sept heures. Elle a été reprise par Hawa.
Patrick : Deux tuteurs ont été plantés. Ils ont été choisis par Rose.
Joël : Le micro a été testé. Il n'a pas encore été rangé.
Hawa : Une page a été tamponnée au Bureau des Escales. Elle a été signée par Solange.
Karim : Le bulletin a été écrit ce matin. Il sera relu avant l'antenne.
Lila : Rien n'a été inventé : chaque fait a été vérifié.
Yvette : L'infirmerie a été ouverte plus tôt. Elle a été préparée par Noura.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le pont a été réparé : le pont est l'objet du verbe, pas l'auteur.",
  "correct": true,
  "explanation": "Passif : on met en avant le fait, pas forcément l'auteur."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Par qui les tuteurs ont-ils été choisis ?",
  "options": [
    {
      "text": "Marc",
      "correct": false
    },
    {
      "text": "Rose",
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
  "explanation": "Patrick : « choisis par Rose. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "a été réparé",
      "right": "le pont"
    },
    {
      "left": "a été lue",
      "right": "la nouvelle"
    },
    {
      "left": "ont été plantés",
      "right": "deux tuteurs"
    },
    {
      "left": "par Dieudonné",
      "right": "agent"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe pont des Herbes ___ été réparé hier.",
  "answer": "a"
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
    "nouvelle",
    "a",
    "été",
    "lue",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "repare",
  "hint": "Le pont l'a été hier (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le pont a réparé hier par Dieudonné.",
  "correct_sentence": "Le pont a été réparé hier par Dieudonné.",
  "explanation": "Passif : être + participe."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/voix-passive.svg",
      "word": "la voix passive"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/journal-fait.svg",
      "word": "un journal"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/micro-info.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/titre-une.svg",
      "word": "un titre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez cinq passifs et, s'il y en a, l'agent (par…)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Le pont a été réparé. La nouvelle a été lue. Deux tuteurs ont été plantés."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Feuille de une',
    'CE',
    $c$Objectif
Lire un bulletin local entièrement au passif.

Consigne
Lisez la feuille, sans aller trop vite.

Support — Feuille de une, Radio Figuier
Le monde en direct — bulletin du Seuil
Le marché des Lampions a été ouvert à l'aube. Il a été tenu par Mado et Sami.
Une barque a été trouvée près du lac des Nénuphars. Elle a été ramenée par Benoît.
Le Cahier des racines a été relu. Trois noms ont été ajoutés.
L'Atelier du Tissu a été visité. Un coupon ocre a été offert par Dieudonné.
Aucune rumeur n'a été confirmée. Chaque phrase a été pesée.
Prochaine émission : le fait sera raconté de nouveau à midi.
Studio Figuier — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La barque a été ramenée par Benoît.",
  "correct": true,
  "explanation": "Deuxième fait du bulletin."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qu'est-ce qui a été offert par Dieudonné ?",
  "options": [
    {
      "text": "Une barque",
      "correct": false
    },
    {
      "text": "Un coupon ocre",
      "correct": true
    },
    {
      "text": "Un micro",
      "correct": false
    },
    {
      "text": "Un tuteur",
      "correct": false
    }
  ],
  "explanation": "« Un coupon ocre a été offert. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "a été ouvert",
      "right": "marché"
    },
    {
      "left": "a été trouvée",
      "right": "barque"
    },
    {
      "left": "ont été ajoutés",
      "right": "trois noms"
    },
    {
      "left": "a été pesée",
      "right": "chaque phrase"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTrois noms ont ___ ajoutés.",
  "answer": "été"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Aucune",
    "rumeur",
    "n'a",
    "été",
    "confirmée",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "barque",
  "hint": "Elle a été trouvée près du lac."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Une barque a trouvé près du lac par Benoît.",
  "correct_sentence": "Une barque a été trouvée près du lac des Nénuphars.",
  "explanation": "Passif féminin : a été trouvée."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/nominalisation.svg",
      "word": "une nominalisation"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/mots-noms.svg",
      "word": "des mots"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/cahier-info.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/antenne-radio.svg",
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
  "prompt": "Recopiez le bulletin et encadrez été + participe."
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
    'PO — Dire a été + participe',
    'PO',
    $c$Objectif
Passer de l'actif au passif à l'oral.

Consigne
Répétez, puis transformez deux faits du Seuil.

Support — Modèles de Marc
Le pont a été réparé.
La nouvelle a été lue.
Les tuteurs ont été plantés.
Le micro a été testé.
La page a été signée.
Rien n'a été inventé.
Le fait sera raconté.
Il a été consolidé par Dieudonné.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Au passif, le participe s'accorde avec le sujet.",
  "correct": true,
  "explanation": "La nouvelle a été lue. Les tuteurs ont été plantés."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Dieudonné a réparé le pont » au passif, c'est…",
  "options": [
    {
      "text": "Dieudonné a été réparé par le pont",
      "correct": false
    },
    {
      "text": "Le pont a été réparé par Dieudonné",
      "correct": true
    },
    {
      "text": "Le pont a réparé Dieudonné",
      "correct": false
    },
    {
      "text": "Le pont est réparer",
      "correct": false
    }
  ],
  "explanation": "Objet → sujet. Agent : par."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "être + PP",
      "right": "passif"
    },
    {
      "left": "par + nom",
      "right": "agent"
    },
    {
      "left": "accord",
      "right": "avec le sujet"
    },
    {
      "left": "sera raconté",
      "right": "passif futur"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes tuteurs ___ été plantés.",
  "answer": "ont"
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
    "micro",
    "a",
    "été",
    "testé",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "agent",
  "hint": "Le complément introduit par par."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La nouvelle a été lu à sept heures.",
  "correct_sentence": "La nouvelle a été lue à sept heures.",
  "explanation": "Sujet féminin : lue."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/gerondif.svg",
      "word": "le gérondif"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/deux-actions.svg",
      "word": "deux actions"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/velo-en-parlant.svg",
      "word": "un vélo"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/main-reagir.svg",
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
  "prompt": "Transformez six phrases actives en passif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux transformations."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon fait du jour',
    'PE',
    $c$Objectif
Écrire un mini-bulletin au passif.

Consigne
Imitez le fait de Hawa.

Support — Fait de Hawa Diallo
Hawa Diallo
Ce matin, la Table des Sources a été nettoyée.
Deux seaux ont été remplis. Ils ont été posés par Joël.
La nouvelle a été lue à Radio Figuier. Elle a été notée par Léa.
Rien n'a été oublié. Le cahier a été refermé.
Le bulletin a été relu une dernière fois avant l'antenne.
Hawa
Émission « Le monde en direct »
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Les seaux ont été posés par Léa.",
  "correct": false,
  "explanation": "« Ils ont été posés par Joël. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a noté la nouvelle ?",
  "options": [
    {
      "text": "Marc",
      "correct": false
    },
    {
      "text": "Léa",
      "correct": true
    },
    {
      "text": "Karim",
      "correct": false
    },
    {
      "text": "Mado",
      "correct": false
    }
  ],
  "explanation": "« notée par Léa. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "a été nettoyée",
      "right": "Table des Sources"
    },
    {
      "left": "ont été remplis",
      "right": "seaux"
    },
    {
      "left": "a été lue",
      "right": "nouvelle"
    },
    {
      "left": "a été refermé",
      "right": "cahier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nRien n'___ été oublié.",
  "answer": "a"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Deux",
    "seaux",
    "ont",
    "été",
    "remplis",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "nettoyee",
  "hint": "La table l'a été ce matin (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La Table des Sources a été nettoyé.",
  "correct_sentence": "La Table des Sources a été nettoyée.",
  "explanation": "Table : féminin → nettoyée."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/suggestion.svg",
      "word": "une suggestion"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/bulle-conditionnel.svg",
      "word": "une bulle"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/carnet-proposer.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/table-idees.svg",
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
  "prompt": "Imitez : cinq phrases au passif, un agent au moins."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre fait, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Forme passive',
    'EL',
    $c$Objectif
Retenir être + participe, l'accord, et par + agent.

Consigne
Apprenez la fiche.

Support — Fiche du studio
Actif : Dieudonné a réparé le pont.
Passif : Le pont a été réparé (par Dieudonné).
Temps : a été + PP (passé). est + PP (présent). sera + PP (futur).
Accord du PP avec le sujet : la nouvelle a été lue ; les noms ont été ajoutés.
Agent facultatif : par + personne. Sans agent : Le pont a été réparé.
On choisit le passif pour mettre le fait en avant, comme à la radio.
Pas : le pont a réparé (si le pont n'est pas l'auteur).
Au Seuil : la nouvelle a été lue ; deux tuteurs ont été plantés par Rose.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'agent est obligatoire au passif.",
  "correct": false,
  "explanation": "On peut dire : Le pont a été réparé."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est un passif au passé ?",
  "options": [
    {
      "text": "a réparé",
      "correct": false
    },
    {
      "text": "a été réparé",
      "correct": true
    },
    {
      "text": "répare",
      "correct": false
    },
    {
      "text": "va réparer",
      "correct": false
    }
  ],
  "explanation": "A été + PP."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "être + PP",
      "right": "passif"
    },
    {
      "left": "par",
      "right": "agent"
    },
    {
      "left": "accord",
      "right": "sujet"
    },
    {
      "left": "sans agent",
      "right": "fait seul"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe fait ___ raconté à midi. (futur passif)",
  "answer": "sera"
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
    "pont",
    "a",
    "été",
    "réparé",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "passif",
  "hint": "La voix qui met le fait en sujet."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Deux tuteurs a été planté.",
  "correct_sentence": "Deux tuteurs ont été plantés.",
  "explanation": "Pluriel : ont été plantés."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/subjonctif-espoir.svg",
      "word": "le subjonctif"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/monde-meilleur.svg",
      "word": "un monde"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/coeur-il-faut.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/nuage-souhait.svg",
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
  "prompt": "Tableau : six verbes, actif / passif, accord."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six passifs."
}$j$::jsonb,
    9
  );

  -- ===== Info du jour =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Info du jour'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Info du jour', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Des verbes, des noms',
    'CO',
    $c$Objectif
Repérer la nominalisation : décider → la décision, annoncer → l'annonce…

Consigne
Lisez le dialogue. Quel nom vient de quel verbe ?

Support — Salle des Herbes, carnets ouverts
Léa : On a décidé d'ouvrir plus tôt. Voici la décision.
Marc : Patrick a proposé un titre. J'aime la proposition.
Aline : Solange a annoncé l'heure. L'annonce est au tableau.
Hawa : On protège le figuier. La protection continue.
Joël : Rose a choisi le micro bleu. Le choix est clair.
Karim : Ils ont ouvert le studio. L'ouverture était calme.
Lila : On a fermé la fenêtre. La fermeture a réduit le vent.
Yvette : Marc a présenté les faits. Sa présentation était nette.
Ibrahim : On informe le Seuil. L'information passe à huit heures.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Décider donne le nom décision.",
  "correct": true,
  "explanation": "Léa : voici la décision."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel nom correspond à choisir ?",
  "options": [
    {
      "text": "la chose",
      "correct": false
    },
    {
      "text": "le choix",
      "correct": true
    },
    {
      "text": "la choisie",
      "correct": false
    },
    {
      "text": "le choisiement",
      "correct": false
    }
  ],
  "explanation": "Choisir → le choix."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "décider",
      "right": "la décision"
    },
    {
      "left": "proposer",
      "right": "la proposition"
    },
    {
      "left": "protéger",
      "right": "la protection"
    },
    {
      "left": "ouvrir / fermer",
      "right": "l'ouverture / la fermeture"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn a décidé → voici la ___.",
  "answer": "décision"
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
    "choix",
    "est",
    "clair",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "annonce",
  "hint": "Solange l'a faite : l'… de l'heure."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On a décidé : voici le décider du matin.",
  "correct_sentence": "On a décidé d'ouvrir plus tôt. Voici la décision.",
  "explanation": "Le nom, c'est la décision."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/nominalisation.svg",
      "word": "une nominalisation"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/mots-noms.svg",
      "word": "des mots"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/cahier-info.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/antenne-radio.svg",
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
  "prompt": "Notez huit couples verbe → nom entendus."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On a décidé. Voici la décision. On protège. La protection continue. Rose a choisi. Le choix est clair."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fil d''infos',
    'CE',
    $c$Objectif
Lire un fil où chaque verbe est repris par un nom.

Consigne
Lisez le fil, sans aller trop vite.

Support — Cahier d'infos, Radio Figuier
Fil du matin
1. Décider d'avancer l'émission → la décision d'Aline.
2. Proposer un invité (Dieudonné) → la proposition de Marc.
3. Annoncer le vent à Rive d'Orage → l'annonce de Lila.
4. Protéger les jeunes plants → la protection de Joël.
5. Arriver de Mwezi-Haut → l'arrivée de Karim.
6. Présenter le bulletin → la présentation de Léa.
7. Informer la Maison des Vents → l'information de Solange.
Aucun nom n'est copié d'ailleurs : tout est né au Seuil.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'arrivée concerne Karim, venu de Mwezi-Haut.",
  "correct": true,
  "explanation": "Point 5."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À qui appartient la proposition ?",
  "options": [
    {
      "text": "Aline",
      "correct": false
    },
    {
      "text": "Marc",
      "correct": true
    },
    {
      "text": "Joël",
      "correct": false
    },
    {
      "text": "Yvette",
      "correct": false
    }
  ],
  "explanation": "« la proposition de Marc. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "décider",
      "right": "décision"
    },
    {
      "left": "arriver",
      "right": "arrivée"
    },
    {
      "left": "présenter",
      "right": "présentation"
    },
    {
      "left": "informer",
      "right": "information"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nProtéger → la ___.",
  "answer": "protection"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "L'annonce",
    "de",
    "Lila",
    "parle",
    "du",
    "vent",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "arrivee",
  "hint": "Le nom de arriver (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Décider d'avancer : voici le décision.",
  "correct_sentence": "Décider d'avancer l'émission → la décision d'Aline.",
  "explanation": "Décision est féminin : la."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/journal-fait.svg",
      "word": "un journal"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/micro-info.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/titre-une.svg",
      "word": "un titre"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/nominalisation.svg",
      "word": "une nominalisation"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le fil et ajoutez deux couples verbe → nom."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les sept points du fil, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire le nom du verbe',
    'PO',
    $c$Objectif
Remplacer un verbe d'action par son nom à l'oral.

Consigne
Répétez, puis nominalisez deux infos à vous.

Support — Modèles de Léa
On a décidé. C'est la décision.
Il a proposé. C'est la proposition.
Elle a annoncé. C'est l'annonce.
Nous protégeons. C'est la protection.
Vous avez choisi. C'est le choix.
Ils ont ouvert. C'est l'ouverture.
J'ai fermé. C'est la fermeture.
Tu as informé. C'est l'information.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Beaucoup de noms en -tion viennent d'un verbe.",
  "correct": true,
  "explanation": "Décision, proposition, protection, information."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Ouvrir » donne…",
  "options": [
    {
      "text": "l'ouvert",
      "correct": false
    },
    {
      "text": "l'ouverture",
      "correct": true
    },
    {
      "text": "l'ouvrance",
      "correct": false
    },
    {
      "text": "le ouvrir",
      "correct": false
    }
  ],
  "explanation": "L'ouverture."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "-er → souvent -tion",
      "right": "décider / décision"
    },
    {
      "left": "choisir",
      "right": "le choix"
    },
    {
      "left": "arriver",
      "right": "l'arrivée"
    },
    {
      "left": "fermer",
      "right": "la fermeture"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIls ont ouvert → c'est l'___.",
  "answer": "ouverture"
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
    "proposition",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "fermeture",
  "hint": "Le nom qui suit : j'ai fermé."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Vous avez choisi : c'est la choisement.",
  "correct_sentence": "Vous avez choisi. C'est le choix.",
  "explanation": "Choisir → le choix."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/livre-on.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/pronom-on.svg",
      "word": "le pronom on"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/lecteur-marc.svg",
      "word": "un lecteur"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/couverture-conte.svg",
      "word": "une couverture"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases : verbe, puis nom."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux nominalisations."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon fil d''infos',
    'PE',
    $c$Objectif
Écrire un fil d'infos qui nominalise chaque verbe.

Consigne
Imitez le fil de Patrick.

Support — Fil de Patrick Habimana
Patrick Habimana
J'ai décidé de parler du pont : voici ma décision.
Marc a proposé l'ordre des faits : sa proposition est juste.
Léa a annoncé l'heure : l'annonce a circulé.
On protège encore la rive : la protection continue.
J'ai choisi un mot simple : le choix aide les auditeurs.
Patrick
Radio Figuier
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick a choisi un mot compliqué.",
  "correct": false,
  "explanation": "« un mot simple : le choix aide… »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel nom reprend « j'ai décidé » ?",
  "options": [
    {
      "text": "la proposition",
      "correct": false
    },
    {
      "text": "la décision",
      "correct": true
    },
    {
      "text": "l'ouverture",
      "correct": false
    },
    {
      "text": "le choix",
      "correct": false
    }
  ],
  "explanation": "« voici ma décision. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "décidé",
      "right": "décision"
    },
    {
      "left": "proposé",
      "right": "proposition"
    },
    {
      "left": "annoncé",
      "right": "annonce"
    },
    {
      "left": "choisi",
      "right": "choix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn protège encore la rive : la ___ continue.",
  "answer": "protection"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Voici",
    "ma",
    "décision",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "auditeurs",
  "hint": "Le choix simple les aide, à la radio."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai décidé : voici mon décider.",
  "correct_sentence": "J'ai décidé de parler du pont : voici ma décision.",
  "explanation": "Nom : la décision."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/studio-radio.svg",
      "word": "un studio"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/carte-direct.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/horloge-journal.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/feuille-une.svg",
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
  "prompt": "Imitez : cinq lignes, cinq nominalisations."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre fil, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Nominalisation',
    'EL',
    $c$Objectif
Retenir comment passer du verbe au nom.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
Verbe → nom
décider → la décision ; proposer → la proposition ; présenter → la présentation
annoncer → l'annonce ; informer → l'information
protéger → la protection ; choisir → le choix
ouvrir → l'ouverture ; fermer → la fermeture ; arriver → l'arrivée
Souvent : -er → -tion / -sion. Parfois un nom court : le choix, l'annonce.
Article : la / l' / le. On ne laisse pas le verbe tel quel comme nom.
À Radio Figuier : décider → la décision ; informer → l'information du matin.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Tous les noms viennent d'un verbe en -tion.",
  "correct": false,
  "explanation": "Le choix, l'annonce : d'autres formes."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Arriver » donne…",
  "options": [
    {
      "text": "l'arrivage seulement",
      "correct": false
    },
    {
      "text": "l'arrivée",
      "correct": true
    },
    {
      "text": "le arriver",
      "correct": false
    },
    {
      "text": "l'arrivé",
      "correct": false
    }
  ],
  "explanation": "L'arrivée."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "décider",
      "right": "décision"
    },
    {
      "left": "choisir",
      "right": "choix"
    },
    {
      "left": "ouvrir",
      "right": "ouverture"
    },
    {
      "left": "annoncer",
      "right": "annonce"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nInformer → l'___.",
  "answer": "information"
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
    "l'ouverture",
    "du",
    "studio",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "suffixe",
  "hint": "Souvent -tion : un… du verbe."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Protéger le figuier : voici le protéger du Seuil.",
  "correct_sentence": "On protège le figuier. Voici la protection.",
  "explanation": "Nom : la protection."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/horloge-journal.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/feuille-une.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/casque-lea.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/fenetre-monde.svg",
      "word": "une fenêtre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Listez douze verbes d'info et leur nom."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et douze couples."
}$j$::jsonb,
    9
  );

  -- ===== Réagir avec justesse =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Réagir avec justesse'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Réagir avec justesse', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — En parlant, en écoutant',
    'CO',
    $c$Objectif
Repérer le gérondif : en + participe présent (en marchant, en écoutant).

Consigne
Lisez le dialogue. Quelles actions se font en même temps ?

Support — Couloir du studio, casques à la main
Léa : En ouvrant l'antenne, souriez. En parlant, regardez le voyant ocre.
Marc : J'ai compris en écoutant Hawa. J'ai noté en relisant le fil.
Aline : En marchant vers le micro, on respire. En respirant, on pose la voix.
Patrick : Joël est tombé en courant. Il a réagi en riant, pas en criant.
Rose : En signant, elle a regardé Rose… non : Hawa a regardé Rose en signant.
Karim : On informe en précisant la source. On corrige en restant calmes.
Lila : Tout en écoutant, j'ai préparé l'eau. Deux actions ensemble.
Yvette : En fermant la porte, baissez la voix. En partant, rangez le casque.
Noura : Je me suis trompée en lisant trop vite. J'ai rattrapé en répétant.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le gérondif commence par en + forme en -ant.",
  "correct": true,
  "explanation": "En ouvrant, en parlant, en écoutant."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment Joël a-t-il réagi ?",
  "options": [
    {
      "text": "En criant",
      "correct": false
    },
    {
      "text": "En riant",
      "correct": true
    },
    {
      "text": "En dormant",
      "correct": false
    },
    {
      "text": "En payant",
      "correct": false
    }
  ],
  "explanation": "« en riant, pas en criant. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en ouvrant",
      "right": "sourire"
    },
    {
      "left": "en écoutant",
      "right": "comprendre"
    },
    {
      "left": "en courant",
      "right": "tomber"
    },
    {
      "left": "en répétant",
      "right": "rattraper"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'ai compris ___ écoutant Hawa.",
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
    "En",
    "parlant",
    "regardez",
    "le",
    "voyant",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "voyant",
  "hint": "Le petit feu ocre du studio."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai compris à écouter Hawa.",
  "correct_sentence": "J'ai compris en écoutant Hawa.",
  "explanation": "Gérondif : en + -ant."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/gerondif.svg",
      "word": "le gérondif"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/deux-actions.svg",
      "word": "deux actions"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/velo-en-parlant.svg",
      "word": "un vélo"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/main-reagir.svg",
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
  "prompt": "Notez six gérondifs et l'action principale à côté."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : En ouvrant l'antenne, souriez. J'ai compris en écoutant. En marchant, on respire."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Consignes d''antenne',
    'CE',
    $c$Objectif
Lire des consignes construites avec le gérondif.

Consigne
Lisez les consignes, sans aller trop vite.

Support — Feuille collée, studio Figuier
Consignes — réagir avec justesse
1. En arrivant, saluez. En partant, remerciez.
2. En lisant un nom, articulez. En hésitant, respirez.
3. On ne corrige pas en humiliant. On précise en restant doux.
4. En entendant une rumeur, vérifiez. En doutant, dites-le.
5. Tout en écoutant l'invité, notez un mot-clé.
6. En fermant l'émission, rappelez le Cahier du chemin.
Léa et Marc — Radio Figuier
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut corriger en humiliant, d'après la feuille.",
  "correct": false,
  "explanation": "« On ne corrige pas en humiliant. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait-on en doutant ?",
  "options": [
    {
      "text": "On cache",
      "correct": false
    },
    {
      "text": "On le dit",
      "correct": true
    },
    {
      "text": "On rit seulement",
      "correct": false
    },
    {
      "text": "On ferme le pont",
      "correct": false
    }
  ],
  "explanation": "« En doutant, dites-le. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en arrivant",
      "right": "saluer"
    },
    {
      "left": "en hésitant",
      "right": "respirer"
    },
    {
      "left": "en doutant",
      "right": "dire"
    },
    {
      "left": "en fermant",
      "right": "rappeler le cahier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTout ___ écoutant l'invité, notez un mot-clé.",
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
    "En",
    "hésitant",
    "respirez",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "articulez",
  "hint": "On le fait en lisant un nom."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En arriver, saluez.",
  "correct_sentence": "En arrivant, saluez.",
  "explanation": "Gérondif : en + -ant, pas l'infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/casque-lea.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/fenetre-monde.svg",
      "word": "une fenêtre"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/voix-passive.svg",
      "word": "la voix passive"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/journal-fait.svg",
      "word": "un journal"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez et transformez deux consignes en « on + gérondif »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six consignes, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire en + -ant',
    'PO',
    $c$Objectif
Réagir à l'oral en enchaînant deux actions avec le gérondif.

Consigne
Répétez, puis racontez deux gestes faits en même temps.

Support — Modèles de Marc
En ouvrant, je souris.
En parlant, je regarde le voyant.
J'ai compris en écoutant.
Il est tombé en courant.
On informe en précisant.
On corrige en restant calmes.
Tout en écoutant, je note.
En partant, je range.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Tout en » insiste sur la simultanéité.",
  "correct": true,
  "explanation": "Tout en écoutant, je note."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est un gérondif ?",
  "options": [
    {
      "text": "pour écouter",
      "correct": false
    },
    {
      "text": "en écoutant",
      "correct": true
    },
    {
      "text": "à écouter",
      "correct": false
    },
    {
      "text": "d'écouter",
      "correct": false
    }
  ],
  "explanation": "En + -ant."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en + -ant",
      "right": "gérondif"
    },
    {
      "left": "simultanéité",
      "right": "en même temps"
    },
    {
      "left": "manière",
      "right": "en précisant / en riant"
    },
    {
      "left": "tout en",
      "right": "deux actions ensemble"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl est tombé ___ courant.",
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
    "Tout",
    "en",
    "écoutant",
    "je",
    "note",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "simultane",
  "hint": "Deux actions en même temps (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai compris pour écoutant Hawa.",
  "correct_sentence": "J'ai compris en écoutant Hawa.",
  "explanation": "Pas pour + -ant. En + -ant."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/suggestion.svg",
      "word": "une suggestion"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/bulle-conditionnel.svg",
      "word": "une bulle"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/carnet-proposer.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/table-idees.svg",
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
  "prompt": "Écrivez huit phrases au gérondif : quatre manières, quatre simultanées."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux réactions à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mes réactions',
    'PE',
    $c$Objectif
Écrire des réactions justes avec le gérondif.

Consigne
Imitez la liste de Rose.

Support — Réactions de Rose Iradukunda
Rose Iradukunda
En entendant une rumeur, je vérifie.
En parlant au micro, je regarde Léa.
J'ai compris le vent en écoutant Lila.
On corrige en restant doux, jamais en humiliant.
Tout en notant, je respire.
En fermant, je remercie les auditeurs du Seuil.
Rose
Radio Figuier
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose humilie quand elle corrige.",
  "correct": false,
  "explanation": "« jamais en humiliant. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment Rose a-t-elle compris le vent ?",
  "options": [
    {
      "text": "En criant",
      "correct": false
    },
    {
      "text": "En écoutant Lila",
      "correct": true
    },
    {
      "text": "En courant",
      "correct": false
    },
    {
      "text": "En payant",
      "correct": false
    }
  ],
  "explanation": "« en écoutant Lila. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en entendant",
      "right": "vérifier"
    },
    {
      "left": "en parlant",
      "right": "regarder Léa"
    },
    {
      "left": "en écoutant",
      "right": "comprendre"
    },
    {
      "left": "en fermant",
      "right": "remercier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTout ___ notant, je respire.",
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
    "En",
    "entendant",
    "une",
    "rumeur",
    "je",
    "vérifie",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "rumeur",
  "hint": "En l'entendant, Rose vérifie."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En entendre une rumeur, je vérifie.",
  "correct_sentence": "En entendant une rumeur, je vérifie.",
  "explanation": "Entendant, pas entendre."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/subjonctif-espoir.svg",
      "word": "le subjonctif"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/monde-meilleur.svg",
      "word": "un monde"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/coeur-il-faut.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/nuage-souhait.svg",
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
  "prompt": "Imitez : six lignes, six gérondifs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez vos réactions, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Le gérondif',
    'EL',
    $c$Objectif
Retenir en + -ant : simultanéité, manière, et quelques orthographes.

Consigne
Apprenez la fiche.

Support — Fiche de Léa
Gérondif = en + participe présent
parler → en parlant ; écouter → en écoutant ; ouvrir → en ouvrant
Verbes en -ger : en mangeant (e garde). -cer : en commençant (ç).
Sens 1 : en même temps. Sens 2 : manière (en précisant, en riant).
tout en + -ant : deux actions ensemble, parfois un léger contraste.
Ne pas confondre : pour + infinitif (but) et en + -ant (manière / temps).
Un seul sujet : En partant, rangez (vous partez et vous rangez).
Studio : en ouvrant l'antenne, souriez ; j'ai compris en écoutant Hawa.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Pour écouter » est un gérondif.",
  "correct": false,
  "explanation": "Pour + infinitif = but. Gérondif = en écoutant."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Commencer » au gérondif s'écrit…",
  "options": [
    {
      "text": "en commencant",
      "correct": false
    },
    {
      "text": "en commençant",
      "correct": true
    },
    {
      "text": "en commencent",
      "correct": false
    },
    {
      "text": "en commencer",
      "correct": false
    }
  ],
  "explanation": "Ç devant a : commençant."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en + -ant",
      "right": "forme"
    },
    {
      "left": "pour + inf.",
      "right": "but"
    },
    {
      "left": "tout en",
      "right": "ensemble"
    },
    {
      "left": "un sujet",
      "right": "même personne"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPour le but on dit pour + infinitif ; pour la manière : ___ + -ant.",
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
    "En",
    "commençant",
    "souriez",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "maniere",
  "hint": "En précisant, en riant : le sens… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En commencant l'antenne, souriez.",
  "correct_sentence": "En commençant l'antenne, souriez.",
  "explanation": "Commencer : ç devant a."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/livre-on.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/pronom-on.svg",
      "word": "le pronom on"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/lecteur-marc.svg",
      "word": "un lecteur"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/couverture-conte.svg",
      "word": "une couverture"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Conjuguez huit verbes au gérondif avec une phrase chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et huit gérondifs."
}$j$::jsonb,
    9
  );

  -- ===== Des suggestions à faire =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Des suggestions à faire'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Des suggestions à faire', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Autour de la table d''idées',
    'CO',
    $c$Objectif
Repérer le conditionnel de suggestion : je suggérerais de, on pourrait, je proposerais de.

Consigne
Lisez le dialogue. Quelles idées sont des suggestions, pas des ordres ?

Support — Table des idées, studio
Marc : Je suggérerais de commencer par le pont. On pourrait attendre Hawa.
Léa : Je proposerais de lire le titre deux fois. Tu devrais articuler.
Aline : Il vaudrait mieux vérifier chez Solange. On devrait noter l'heure.
Patrick : Je te conseillerais de baisser le micro. On pourrait sourire davantage.
Hawa : Et si on invitait Dieudonné ? Je suggérerais de lui laisser trois minutes.
Joël : On pourrait parler plus lentement. Je proposerais de couper les rumeurs.
Rose : J'aimerais qu'on respire. On devrait remercier Yvette.
Karim : Je ne donnerais pas un ordre. Je suggérerais seulement.
Lila : On pourrait ouvrir la fenêtre. Il vaudrait mieux éviter le vent trop fort.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je suggérerais de » est plus doux qu'un impératif.",
  "correct": true,
  "explanation": "Suggestion au conditionnel."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que propose Léa pour le titre ?",
  "options": [
    {
      "text": "De le cacher",
      "correct": false
    },
    {
      "text": "De le lire deux fois",
      "correct": true
    },
    {
      "text": "De le vendre",
      "correct": false
    },
    {
      "text": "De le crier",
      "correct": false
    }
  ],
  "explanation": "« Je proposerais de lire le titre deux fois. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je suggérerais de",
      "right": "commencer / lui laisser"
    },
    {
      "left": "on pourrait",
      "right": "attendre / sourire / parler"
    },
    {
      "left": "je proposerais de",
      "right": "lire / couper"
    },
    {
      "left": "il vaudrait mieux",
      "right": "vérifier / éviter"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe suggérerais ___ commencer par le pont.",
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
    "pourrait",
    "attendre",
    "Hawa",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "suggérerais",
  "hint": "Marc le dit pour commencer par le pont."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suggérerais à commencer par le pont.",
  "correct_sentence": "Je suggérerais de commencer par le pont.",
  "explanation": "Suggérer de + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/suggestion.svg",
      "word": "une suggestion"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/bulle-conditionnel.svg",
      "word": "une bulle"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/carnet-proposer.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/table-idees.svg",
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
  "prompt": "Listez six suggestions et l'outil (pourrait / suggérerais / vaudrait)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je suggérerais de commencer par le pont. On pourrait attendre Hawa. Je proposerais de lire le titre deux fois."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Carnet de propositions',
    'CE',
    $c$Objectif
Lire un carnet de suggestions au conditionnel.

Consigne
Lisez le carnet, sans aller trop vite.

Support — Carnet de Marc Nkurunziza
Propositions — émission de midi
1. Je suggérerais de laisser un silence après chaque fait.
2. On pourrait inviter Lila pour le vent de Rive d'Orage.
3. Je proposerais de répéter les noms propres une fois.
4. Il vaudrait mieux ne pas crier « urgent » sans preuve.
5. Tu devrais regarder Léa avant d'ouvrir le micro.
6. On devrait remercier le Bureau des Escales.
Rien n'est un ordre. Tout est une idée, au Seuil.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le carnet autorise à crier « urgent » sans preuve.",
  "correct": false,
  "explanation": "« Il vaudrait mieux ne pas crier « urgent » sans preuve. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui pourrait-on inviter pour le vent ?",
  "options": [
    {
      "text": "Ibrahim",
      "correct": false
    },
    {
      "text": "Lila",
      "correct": true
    },
    {
      "text": "Kévin",
      "correct": false
    },
    {
      "text": "Mado",
      "correct": false
    }
  ],
  "explanation": "Point 2."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "suggérerais de",
      "right": "silence"
    },
    {
      "left": "pourrait",
      "right": "inviter Lila"
    },
    {
      "left": "proposerais de",
      "right": "répéter les noms"
    },
    {
      "left": "vaudrait mieux",
      "right": "pas « urgent »"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe proposerais ___ répéter les noms propres.",
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
    "devrait",
    "remercier",
    "le",
    "Bureau",
    "."
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
  "hint": "Marc en suggérerait un après chaque fait."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je proposerais à répéter les noms propres.",
  "correct_sentence": "Je proposerais de répéter les noms propres une fois.",
  "explanation": "Proposer de + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/subjonctif-espoir.svg",
      "word": "le subjonctif"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/monde-meilleur.svg",
      "word": "un monde"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/coeur-il-faut.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/nuage-souhait.svg",
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
  "prompt": "Recopiez trois propositions et ajoutez la vôtre au conditionnel."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six propositions, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire on pourrait',
    'PO',
    $c$Objectif
Faire des suggestions polies au conditionnel.

Consigne
Répétez, puis proposez deux idées pour l'émission.

Support — Modèles d'Aline
Je suggérerais de commencer tôt.
On pourrait attendre une minute.
Je proposerais de sourire.
Il vaudrait mieux vérifier.
Tu devrais articuler.
On devrait remercier.
J'aimerais ouvrir plus tard.
Et si on invitait Dieudonné ?
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Et si on + imparfait » sert aussi à proposer.",
  "correct": true,
  "explanation": "Et si on invitait…"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est une suggestion, pas un ordre sec ?",
  "options": [
    {
      "text": "Commence !",
      "correct": false
    },
    {
      "text": "Je suggérerais de commencer tôt",
      "correct": true
    },
    {
      "text": "Tu commences maintenant point",
      "correct": false
    },
    {
      "text": "Il faut silence immédiat seulement",
      "correct": false
    }
  ],
  "explanation": "Conditionnel + de."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "suggérer de / proposer de",
      "right": "+ infinitif"
    },
    {
      "left": "on pourrait / on devrait",
      "right": "conditionnel"
    },
    {
      "left": "il vaudrait mieux",
      "right": "comparaison douce"
    },
    {
      "left": "et si on",
      "right": "imparfait"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ___ attendre une minute.",
  "answer": "pourrait"
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
    "vaudrait",
    "mieux",
    "vérifier",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "vaudrait",
  "hint": "Il… mieux vérifier chez Solange."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suggérerais commencer tôt sans de.",
  "correct_sentence": "Je suggérerais de commencer tôt.",
  "explanation": "Suggérer de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/studio-radio.svg",
      "word": "un studio"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/carte-direct.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/horloge-journal.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/feuille-une.svg",
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
  "prompt": "Écrivez huit suggestions, outils différents."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux idées à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mes suggestions',
    'PE',
    $c$Objectif
Écrire un carnet de suggestions au conditionnel.

Consigne
Imitez le carnet de Léa.

Support — Carnet de Léa Niyonzima
Léa Niyonzima
Je suggérerais de respirer avant le premier mot.
On pourrait laisser Dieudonné présenter le tissu.
Je proposerais de lire le titre « Le monde en direct » sans le crier.
Il vaudrait mieux noter l'heure sur le cahier.
On devrait remercier ceux qui écoutent sous le figuier.
Léa
Studio Figuier
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa veut qu'on crie le titre.",
  "correct": false,
  "explanation": "« sans le crier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que pourrait-on laisser faire à Dieudonné ?",
  "options": [
    {
      "text": "Fermer la radio",
      "correct": false
    },
    {
      "text": "Présenter le tissu",
      "correct": true
    },
    {
      "text": "Casser le micro",
      "correct": false
    },
    {
      "text": "Vendre le pont",
      "correct": false
    }
  ],
  "explanation": "« présenter le tissu. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "suggérerais de",
      "right": "respirer"
    },
    {
      "left": "pourrait",
      "right": "Dieudonné"
    },
    {
      "left": "proposerais de",
      "right": "lire le titre"
    },
    {
      "left": "devrait",
      "right": "remercier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn devrait remercier ceux qui écoutent sous le ___.",
  "answer": "figuier"
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
    "suggérerais",
    "de",
    "respirer",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "respirer",
  "hint": "Léa le suggérerait avant le premier mot."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je proposerais à lire le titre sans le crier.",
  "correct_sentence": "Je proposerais de lire le titre « Le monde en direct » sans le crier.",
  "explanation": "Proposer de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/micro-info.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/titre-une.svg",
      "word": "un titre"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/nominalisation.svg",
      "word": "une nominalisation"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/mots-noms.svg",
      "word": "des mots"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : cinq suggestions, cinq outils ou formes."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre carnet, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Conditionnel de suggestion',
    'EL',
    $c$Objectif
Retenir je suggérerais de, on pourrait, je proposerais de, il vaudrait mieux.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
Conditionnel présent : je suggérerais, on pourrait, je proposerais, tu devrais
suggérer de + infinitif ; proposer de + infinitif
on pourrait / on devrait + infinitif (sans de)
il vaudrait mieux + infinitif
et si on + imparfait : Et si on invitait… ?
Plus poli que l'impératif : on suggère, on n'ordonne pas.
Attention : je suggérerais de (pas à). Je proposerais de (pas à).
Autour de la table : on pourrait attendre Hawa ; il vaudrait mieux vérifier.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« On pourrait » se construit sans de.",
  "correct": true,
  "explanation": "On pourrait attendre. (pouvoir + inf.)"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série est correcte ?",
  "options": [
    {
      "text": "suggérer à / proposer à + inf.",
      "correct": false
    },
    {
      "text": "suggérer de / proposer de + inf.",
      "correct": true
    },
    {
      "text": "suggérer pour / proposer pour + inf. seulement",
      "correct": false
    },
    {
      "text": "suggérer en / proposer en + inf.",
      "correct": false
    }
  ],
  "explanation": "De + infinitif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "suggérer / proposer",
      "right": "de + inf."
    },
    {
      "left": "pouvoir / devoir",
      "right": "inf. direct"
    },
    {
      "left": "valoir mieux",
      "right": "inf. direct"
    },
    {
      "left": "et si on",
      "right": "imparfait"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEt si on ___ Dieudonné ? (inviter, imparfait)",
  "answer": "invitait"
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
    "pourrait",
    "sourire",
    "davantage",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "poli",
  "hint": "Le conditionnel est plus… que l'impératif."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On pourrait de attendre Hawa.",
  "correct_sentence": "On pourrait attendre Hawa.",
  "explanation": "Pouvoir + infinitif, sans de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/cahier-info.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/antenne-radio.svg",
      "word": "une antenne"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/gerondif.svg",
      "word": "le gérondif"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/deux-actions.svg",
      "word": "deux actions"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez six impératifs en suggestions au conditionnel."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six suggestions."
}$j$::jsonb,
    9
  );

  -- ===== Espérer un monde meilleur =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Espérer un monde meilleur'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Espérer un monde meilleur', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Souhaits d''antenne',
    'CO',
    $c$Objectif
Repérer le subjonctif après il faut que, je veux que, pour que, avant que.

Consigne
Lisez le dialogue. Quel verbe change après que ?

Support — Studio, voyant ocre allumé
Léa : Il faut que le Seuil soit entendu. Il faut que chacun ait sa phrase.
Marc : Je veux que l'eau reste claire. Je veux que vous fassiez attention.
Aline : On parle pour que les enfants puissent comprendre. Pour que rien ne se perde.
Patrick : Avant que l'émission finisse, remercions. Avant qu'on parte, rangeons.
Hawa : Il faut que Joël vienne. Je veux qu'il prenne le micro une minute.
Rose : Il faut que nous soyons justes. Pour que l'info aille jusqu'à Mwezi-Haut.
Karim : Je veux que Solange sache l'heure. Il faut qu'elle puisse tamponner.
Lila : Avant que le vent tourne, disons Rive d'Orage.
Yvette : Il faut que Noura soit prête. Pour que l'infirmerie ouvre à temps.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Après il faut que, le verbe n'est pas à l'indicatif.",
  "correct": true,
  "explanation": "Il faut que le Seuil soit entendu. (subjonctif de être)"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme de faire apparaît après je veux que ?",
  "options": [
    {
      "text": "faites",
      "correct": false
    },
    {
      "text": "fassiez",
      "correct": true
    },
    {
      "text": "feriez",
      "correct": false
    },
    {
      "text": "faisiez à l'indicatif",
      "correct": false
    }
  ],
  "explanation": "Je veux que vous fassiez attention."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il faut que",
      "right": "soit / ait / vienne"
    },
    {
      "left": "je veux que",
      "right": "reste / fassiez / sache"
    },
    {
      "left": "pour que",
      "right": "puissent / aille / ouvre"
    },
    {
      "left": "avant que",
      "right": "finisse / parte / tourne"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut que le Seuil ___ entendu.",
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
    "Je",
    "veux",
    "que",
    "l'eau",
    "reste",
    "claire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "fassiez",
  "hint": "Je veux que vous… attention : subjonctif de faire."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut que le Seuil est entendu.",
  "correct_sentence": "Il faut que le Seuil soit entendu.",
  "explanation": "Être au subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/subjonctif-espoir.svg",
      "word": "le subjonctif"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/monde-meilleur.svg",
      "word": "un monde"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/coeur-il-faut.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/nuage-souhait.svg",
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
  "prompt": "Notez huit subjonctifs et le mot qui les déclenche (il faut que…)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il faut que le Seuil soit entendu. Je veux que vous fassiez attention. Pour que les enfants puissent comprendre."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Mot d''espoir',
    'CE',
    $c$Objectif
Lire un mot qui enchaîne il faut que, je veux que, pour que, avant que.

Consigne
Lisez le mot, sans aller trop vite.

Support — Mot de Lila Sow, antenne
Chers auditeurs du Seuil,
Il faut que la rivière reste vivante. Il faut que chacun pacifie sa voix.
Je veux que le figuier ait encore de l'ombre dans dix ans.
On informe pour que personne ne se trompe. Pour que l'espoir aille plus loin.
Avant que la nuit tombe, allumez un lampion au Marché, si vous le pouvez.
Il faut que nous fassions simple. Je veux que vous soyez là demain.
Lila
« Le monde en direct » — Radio Figuier
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila veut que le figuier ait encore de l'ombre dans dix ans.",
  "correct": true,
  "explanation": "Subjonctif de avoir : ait."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il faire avant que la nuit tombe ?",
  "options": [
    {
      "text": "Fermer le pont",
      "correct": false
    },
    {
      "text": "Allumer un lampion au marché",
      "correct": true
    },
    {
      "text": "Crier",
      "correct": false
    },
    {
      "text": "Partir à Val-des-Peupliers",
      "correct": false
    }
  ],
  "explanation": "« allumez un lampion au Marché »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il faut que… reste / pacifie",
      "right": "subjonctif"
    },
    {
      "left": "je veux que… ait / soyez",
      "right": "souhait"
    },
    {
      "left": "pour que… trompe / aille",
      "right": "but"
    },
    {
      "left": "avant que… tombe",
      "right": "antériorité"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe veux que le figuier ___ encore de l'ombre.",
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
    "Il",
    "faut",
    "que",
    "nous",
    "fassions",
    "simple",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pacifie",
  "hint": "Il faut que chacun… sa voix."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je veux que le figuier a encore de l'ombre.",
  "correct_sentence": "Je veux que le figuier ait encore de l'ombre dans dix ans.",
  "explanation": "Avoir au subjonctif : ait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/coeur-il-faut.svg",
      "word": "un monde"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/nuage-souhait.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/livre-on.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/pronom-on.svg",
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
  "prompt": "Encadrez que + subjonctif et le déclencheur."
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
    'PO — Dire il faut que',
    'PO',
    $c$Objectif
Former des souhaits et des buts au subjonctif.

Consigne
Répétez, puis exprimez deux espoirs pour le Seuil.

Support — Modèles de Marc
Il faut que ce soit clair.
Il faut que tu aies le temps.
Je veux que vous fassiez simple.
Je veux qu'il vienne.
Pour que l'info aille loin.
Pour que nous puissions signer.
Avant que ça finisse.
Avant qu'on parte.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le subjonctif de aller à la 3e personne est aille.",
  "correct": true,
  "explanation": "Pour que l'info aille loin."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Il faut que tu… le temps » (avoir) =",
  "options": [
    {
      "text": "as",
      "correct": false
    },
    {
      "text": "aies",
      "correct": true
    },
    {
      "text": "auras",
      "correct": false
    },
    {
      "text": "avais",
      "correct": false
    }
  ],
  "explanation": "Aies : subjonctif de avoir."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "être",
      "right": "soit / soyez / soyons"
    },
    {
      "left": "avoir",
      "right": "ait / aies / ayons"
    },
    {
      "left": "faire",
      "right": "fasse / fassiez / fassions"
    },
    {
      "left": "aller / pouvoir / venir",
      "right": "aille / puisse / vienne"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPour que l'info ___ loin.",
  "answer": "aille"
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
    "ce",
    "soit",
    "clair",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "vienne",
  "hint": "Je veux qu'il… : subjonctif de venir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut que tu as le temps.",
  "correct_sentence": "Il faut que tu aies le temps.",
  "explanation": "Avoir : aies."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/lecteur-marc.svg",
      "word": "un lecteur"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/couverture-conte.svg",
      "word": "une couverture"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/studio-radio.svg",
      "word": "un studio"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/carte-direct.svg",
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
  "prompt": "Écrivez huit phrases : deux de chaque déclencheur."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux espoirs à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon mot d''espoir',
    'PE',
    $c$Objectif
Écrire un mot d'espoir avec le subjonctif.

Consigne
Imitez le mot de Hawa.

Support — Mot de Hawa Diallo
Hawa Diallo
Il faut que le Seuil soit écouté jusqu'à Port de la Brise.
Je veux que nous fassions attention aux mots.
On parle pour que les enfants puissent répéter.
Avant que l'émission finisse, je souhaite que Marc remercie la cour.
Il faut que l'eau reste claire. Je veux que vous soyez fiers.
Hawa
Radio Figuier — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa veut que Marc remercie la cour avant la fin.",
  "correct": true,
  "explanation": "« Avant que l'émission finisse… Marc remercie » — souhait dans la phrase."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Jusqu'où Hawa veut-elle que le Seuil soit écouté ?",
  "options": [
    {
      "text": "Val-des-Peupliers seulement",
      "correct": false
    },
    {
      "text": "Port de la Brise",
      "correct": true
    },
    {
      "text": "Mwezi-Haut seulement",
      "correct": false
    },
    {
      "text": "Rive d'Orage seulement",
      "correct": false
    }
  ],
  "explanation": "« jusqu'à Port de la Brise. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il faut que… soit",
      "right": "écouté"
    },
    {
      "left": "je veux que… fassions",
      "right": "attention"
    },
    {
      "left": "pour que… puissent",
      "right": "répéter"
    },
    {
      "left": "avant que… finisse",
      "right": "remercier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe veux que vous ___ fiers.",
  "answer": "soyez"
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
    "l'eau",
    "reste",
    "claire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "soyez",
  "hint": "Je veux que vous… fiers : subjonctif de être."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut que le Seuil est écouté jusqu'au port.",
  "correct_sentence": "Il faut que le Seuil soit écouté jusqu'à Port de la Brise.",
  "explanation": "Soit, pas est."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/horloge-journal.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/feuille-une.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/casque-lea.svg",
      "word": "un casque"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/fenetre-monde.svg",
      "word": "une fenêtre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : cinq lignes, quatre déclencheurs de subjonctif."
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
    'EL — Le subjonctif présent',
    'EL',
    $c$Objectif
Retenir il faut que, je veux que, pour que, avant que, et les formes fréquentes.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
Déclencheurs A2 : il faut que, je veux que, pour que, avant que
(« J'espère que » : plutôt indicatif. Ici on retient les quatre ci-dessus.)
être : que je sois, tu sois, il soit, nous soyons, vous soyez, ils soient
avoir : que j'aie, tu aies, il ait, nous ayons, vous ayez, ils aient
faire : que je fasse… nous fassions, vous fassiez
aller : que j'aille, il aille ; pouvoir : que je puisse ; venir : qu'il vienne
prendre : qu'il prenne ; savoir : qu'elle sache
Avant que + subjonctif. Pour que + subjonctif.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« J'espère que » prend surtout l'indicatif, pas le subjonctif de cette fiche.",
  "correct": true,
  "explanation": "On réserve le subjonctif à il faut que, je veux que, pour que, avant que."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Il faut que nous… » (être) =",
  "options": [
    {
      "text": "sommes",
      "correct": false
    },
    {
      "text": "soyons",
      "correct": true
    },
    {
      "text": "serions",
      "correct": false
    },
    {
      "text": "étions",
      "correct": false
    }
  ],
  "explanation": "Soyons."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il faut que",
      "right": "nécessité"
    },
    {
      "left": "je veux que",
      "right": "volonté"
    },
    {
      "left": "pour que",
      "right": "but"
    },
    {
      "left": "avant que",
      "right": "avant un fait"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut que nous ___ justes. (être)",
  "answer": "soyons"
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
    "que",
    "rien",
    "ne",
    "se",
    "perde",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "declencheurs",
  "hint": "Il faut que, je veux que : des… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Pour que les enfants peuvent comprendre.",
  "correct_sentence": "On parle pour que les enfants puissent comprendre.",
  "explanation": "Pouvoir au subjonctif : puissent."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/velo-en-parlant.svg",
      "word": "un vélo"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/main-reagir.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/suggestion.svg",
      "word": "une suggestion"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/bulle-conditionnel.svg",
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
  "prompt": "Tableau : huit verbes irréguliers au subjonctif, une phrase chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et huit formes."
}$j$::jsonb,
    9
  );

  -- ===== Parler d'un livre =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Parler d''un livre'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Parler d''un livre', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Autour de « Le figuier n''oublie pas »',
    'CO',
    $c$Objectif
Repérer on = nous, on = quelqu'un, on = les gens, dans un échange sur un livre.

Consigne
Lisez le dialogue. Qui est « on » à chaque fois ?

Support — Table des Sources, couverture ocre
Léa : On a lu « Le figuier n'oublie pas », le cahier du Chemin. On = nous, l'équipe.
Marc : On raconte qu'un arbre garde les voix. On = les gens, on dit que…
Aline : On a sonné à la porte du studio. On = quelqu'un, on ne sait pas qui.
Patrick : Dans le livre, on marche jusqu'à la rive. On = le lecteur, tout le monde.
Hawa : On aime ce titre. On n'oublie pas le Seuil. On = nous encore.
Joël : Si on ouvre la page 3, on voit un banc. On = n'importe qui.
Rose : On ne prête pas ce livre sans le noter. On = règle, les gens du Seuil.
Karim : On m'a dit que Lila l'avait copié à la main. On = quelqu'un.
Benoît : On finit par l'antenne. On = nous, Léa et Marc.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« On a sonné » désigne une personne non nommée.",
  "correct": true,
  "explanation": "Aline : quelqu'un."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Dans « On raconte qu'un arbre garde les voix », on =",
  "options": [
    {
      "text": "seulement Léa",
      "correct": false
    },
    {
      "text": "les gens / la rumeur",
      "correct": true
    },
    {
      "text": "le pont",
      "correct": false
    },
    {
      "text": "Dieudonné seul",
      "correct": false
    }
  ],
  "explanation": "On dit que… = les gens."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on a lu",
      "right": "nous, l'équipe"
    },
    {
      "left": "on raconte",
      "right": "les gens"
    },
    {
      "left": "on a sonné",
      "right": "quelqu'un"
    },
    {
      "left": "si on ouvre",
      "right": "n'importe qui"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ a sonné à la porte du studio.",
  "answer": "On"
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
    "aime",
    "ce",
    "titre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "rumeur",
  "hint": "On raconte… : la voix des gens."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On a lus le livre sous le figuier.",
  "correct_sentence": "On a lu le livre sous le figuier.",
  "explanation": "On + verbe au singulier : on a lu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/livre-on.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/pronom-on.svg",
      "word": "le pronom on"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/lecteur-marc.svg",
      "word": "un lecteur"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/couverture-conte.svg",
      "word": "une couverture"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Classez neuf « on » : nous / quelqu'un / les gens."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On a lu ce livre. On raconte qu'un arbre garde les voix. On a sonné à la porte."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Note de lecture',
    'CE',
    $c$Objectif
Lire une note où on change de sens selon la phrase.

Consigne
Lisez la note, sans aller trop vite.

Support — Note de Marc, Cahier du chemin
Note — « Le figuier n'oublie pas » (titre inventé au Seuil)
On entre dans le récit par la cour. (on = le lecteur)
On dit que l'arbre répond aux enfants. (on = les gens)
Un soir, on frappe : c'est une voix sans nom. (on = quelqu'un)
On a choisi ce livre pour l'émission. (on = nous, Radio Figuier)
On ne révèle pas la dernière page. (on = règle collective)
Si on relit, on entend mieux le vent de Rive d'Orage.
Marc Nkurunziza
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La dernière page est racontée en détail dans la note.",
  "correct": false,
  "explanation": "« On ne révèle pas la dernière page. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« On a choisi ce livre » : on =",
  "options": [
    {
      "text": "un inconnu dans la rue",
      "correct": false
    },
    {
      "text": "nous, Radio Figuier",
      "correct": true
    },
    {
      "text": "seulement Yvette",
      "correct": false
    },
    {
      "text": "les oiseaux",
      "correct": false
    }
  ],
  "explanation": "Marc parle de l'équipe."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on entre",
      "right": "lecteur"
    },
    {
      "left": "on dit que",
      "right": "les gens"
    },
    {
      "left": "on frappe",
      "right": "quelqu'un"
    },
    {
      "left": "on a choisi",
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
  "prompt": "Complétez :\n___ ne révèle pas la dernière page.",
  "answer": "On"
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
    "on",
    "relit",
    "on",
    "entend",
    "mieux",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "derniere",
  "hint": "On ne révèle pas cette page (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On ont choisi ce livre pour l'émission.",
  "correct_sentence": "On a choisi ce livre pour l'émission.",
  "explanation": "On + 3e personne du singulier."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/voix-passive.svg",
      "word": "la voix passive"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/journal-fait.svg",
      "word": "un journal"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/micro-info.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/titre-une.svg",
      "word": "un titre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez et écrivez entre parenthèses le sens de chaque on."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la note de Marc, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire on',
    'PO',
    $c$Objectif
Utiliser on pour nous, pour quelqu'un, pour les gens.

Consigne
Répétez, puis parlez du livre avec trois on différents.

Support — Modèles de Léa
On a lu ce livre.
On aime ce titre.
On raconte que l'arbre entend.
On a sonné.
On ne prête pas sans noter.
Si on ouvre la page 3, on voit un banc.
On finit à l'antenne.
On dit souvent ça, au Seuil.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le verbe après on est au singulier.",
  "correct": true,
  "explanation": "On a lu. On aime. On raconte."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase, ici, vaut surtout « quelqu'un » ?",
  "options": [
    {
      "text": "On a lu ce livre",
      "correct": false
    },
    {
      "text": "On aime ce titre",
      "correct": false
    },
    {
      "text": "On a sonné",
      "correct": true
    },
    {
      "text": "On finit à l'antenne",
      "correct": false
    }
  ],
  "explanation": "On a sonné = une personne non nommée."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on = nous",
      "right": "on a lu / on finit"
    },
    {
      "left": "on = les gens",
      "right": "on raconte / on dit"
    },
    {
      "left": "on = quelqu'un",
      "right": "on a sonné"
    },
    {
      "left": "on + verbe",
      "right": "3e singulier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ dit souvent ça, au Seuil.",
  "answer": "On"
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
    "a",
    "sonné",
    "."
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
  "hint": "Après on, le verbe est au…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On sommes d'accord : on ont lu le livre.",
  "correct_sentence": "On est d'accord. On a lu le livre.",
  "explanation": "On + est / on + a, jamais sommes / ont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/gerondif.svg",
      "word": "le gérondif"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/deux-actions.svg",
      "word": "deux actions"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/velo-en-parlant.svg",
      "word": "un vélo"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/main-reagir.svg",
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
  "prompt": "Écrivez neuf phrases : trois nous, trois gens, trois quelqu'un."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis trois on à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma note de livre',
    'PE',
    $c$Objectif
Écrire une note de lecture qui joue sur les trois sens de on.

Consigne
Imitez la note de Patrick.

Support — Note de Patrick Habimana
Patrick Habimana
On a lu « Le figuier n'oublie pas » sous le figuier. (nous)
On dit que la dernière phrase revient comme un vent. (les gens)
Un matin, on a laissé une feuille dans le livre. (quelqu'un)
Si on relit à voix haute, on entend la cour. (n'importe qui / nous)
On n'emprunte pas le livre sans le Cahier du chemin. (règle)
Patrick
Émission « Le monde en direct »
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick dit qu'on emprunte le livre sans rien noter.",
  "correct": false,
  "explanation": "« On n'emprunte pas le livre sans le Cahier du chemin. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où a-t-on lu le livre, selon Patrick ?",
  "options": [
    {
      "text": "À Port de la Brise",
      "correct": false
    },
    {
      "text": "Sous le figuier",
      "correct": true
    },
    {
      "text": "À l'Auberge seulement",
      "correct": false
    },
    {
      "text": "Chez Ibrahim",
      "correct": false
    }
  ],
  "explanation": "« sous le figuier. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on a lu",
      "right": "nous"
    },
    {
      "left": "on dit que",
      "right": "les gens"
    },
    {
      "left": "on a laissé",
      "right": "quelqu'un"
    },
    {
      "left": "on n'emprunte pas",
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
  "prompt": "Complétez :\nSi ___ relit à voix haute, on entend la cour.",
  "answer": "on"
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
    "a",
    "lu",
    "ce",
    "livre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "emprunte",
  "hint": "On ne… pas le livre sans le cahier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On ont lu ce livre sous le figuier.",
  "correct_sentence": "On a lu « Le figuier n'oublie pas » sous le figuier.",
  "explanation": "On a, pas on ont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/carnet-proposer.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/table-idees.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/subjonctif-espoir.svg",
      "word": "le subjonctif"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/monde-meilleur.svg",
      "word": "un monde"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : cinq lignes, les trois sens de on au moins une fois."
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
    'EL — Le pronom on',
    'EL',
    $c$Objectif
Retenir les trois valeurs de on et l'accord du verbe.

Consigne
Apprenez la fiche.

Support — Fiche du Cahier du chemin
On + verbe à la 3e personne du singulier : on a, on est, on lit, on dit
1. on = nous (parlé, radio, groupe) : On a lu. On finit à l'antenne.
2. on = quelqu'un (identité cachée) : On a sonné. On a laissé une feuille.
3. on = les gens / tout le monde : On dit que… On raconte que…
Participe : on est allé (accord possible au sens nous, avancé). Ici : on a lu (invariable avec avoir si pas de COD avant).
On n'écrit pas : on sommes, on ont, on allons.
Élision : l'on (rare, après si, que : si l'on relit) — possible, pas obligatoire.
Livre du Seuil : on a lu « Le figuier n'oublie pas » ; on dit que l'arbre entend.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « on allons » quand on veut dire nous.",
  "correct": false,
  "explanation": "On va. (singulier)"
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
      "text": "on sont d'accord",
      "correct": false
    },
    {
      "text": "on est d'accord",
      "correct": true
    },
    {
      "text": "on sommes d'accord",
      "correct": false
    },
    {
      "text": "on ont lu",
      "correct": false
    }
  ],
  "explanation": "On est."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on = nous",
      "right": "groupe qui parle"
    },
    {
      "left": "on = quelqu'un",
      "right": "inconnu"
    },
    {
      "left": "on = les gens",
      "right": "on dit que"
    },
    {
      "left": "verbe",
      "right": "3e singulier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ___ d'accord. (être)",
  "answer": "est"
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
    "dit",
    "que",
    "l'arbre",
    "entend",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "identite",
  "hint": "Quand on = quelqu'un, l'… est cachée (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On allons finir par l'antenne.",
  "correct_sentence": "On finit à l'antenne. / On va finir à l'antenne.",
  "explanation": "On + 3e singulier."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m8/nominalisation.svg",
      "word": "une nominalisation"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/mots-noms.svg",
      "word": "des mots"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/cahier-info.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m8/antenne-radio.svg",
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
  "prompt": "Écrivez douze phrases : quatre par valeur de on."
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
