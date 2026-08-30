/*
  Seed eLearning MFK — B2 — Questions de société

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b2-m5/
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
  v_module_title text := 'B2 — Questions de société';
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
      'Grande étape B2-5 : analyser un enjeu à la voix passive, prendre position au subjonctif, décrire un fait culturel et politique inventé de la cour, nuancer une comparaison, enquêter à Rukiri-Nord et signer un éditorial pour le Cahier des racines — autour de l''eau, des heures calmes, des lanternes et de l''accès à la Salle des Herbes, au Seuil des Sources.',
      'B2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B2-5 : analyser un enjeu à la voix passive, prendre position au subjonctif, décrire un fait culturel et politique inventé de la cour, nuancer une comparaison, enquêter à Rukiri-Nord et signer un éditorial pour le Cahier des racines — autour de l''eau, des heures calmes, des lanternes et de l''accès à la Salle des Herbes, au Seuil des Sources.',
      cefr_level = 'B2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Un enjeu à analyser =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un enjeu à analyser'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un enjeu à analyser', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Ce qui a été décidé à la rivière',
    'CO',
    $c$Objectif
Repérer la voix passive qui met en valeur un élément (a été décidé, est porté par).

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Quel enjeu est mis en avant, et par qui la mesure est-elle portée ?

Support — Assemblée sous le figuier, seaux alignés
Aline : Un enjeu a été posé ce matin : l'eau de la rivière, pas le tambour, pas la lanterne.
Dieudonné : Il a été décidé que les seaux ne seraient remplis qu'entre six heures et huit heures.
Hawa : Cette mesure est portée par ceux qui marchent jusqu'à l'eau, pas par ceux qui commentent du banc.
Rose : La rivière a été protégée, dit-on ; or les heures, elles, ont été affichées trop haut, loin des yeux.
Marc : Ce qui a été voté n'est pas un caprice : c'est un partage. Le partage a été relaté dans le Cahier des racines.
Léa : Pourtant le texte a été rédigé sans les voix du soir. Qui a été consulté, au juste ?
Solange : Le tampon a été apposé au Bureau des Escales. Une décision tamponnée n'est pas encore une décision comprise.
Patrick : L'affiche a été collée au figuier ; elle est lue par les anciens, rarement par les enfants.
Lila : À Radio Figuier, le fait sera examiné ce soir : pas la colère, le chiffre de l'eau.
Joël : Les seaux communs ont été comptés. Trois manquent. Cela n'a pas été inventé.
Karim : Si l'eau est contestée par Noura, que l'on dise pourquoi, et que l'on nomme l'agent : contestée par qui ?
Yvette : Une règle portée par la cour tient mieux qu'une règle portée par un seul tampon.
Mado : Je retiens : on met en valeur ce qui a été fait à l'eau, pas qui a parlé le plus fort.
Aline : Notez le passif : a été décidé, est porté par, a été affiché, sera examiné. L'élément mis en avant devient sujet.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné dit qu'il a été décidé de remplir les seaux toute la journée.",
  "correct": false,
  "explanation": "Les seaux ne seraient remplis qu'entre six heures et huit heures."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Hawa, par qui la mesure est-elle portée ?",
  "options": [
    {
      "text": "Par Radio Figuier seulement",
      "correct": false
    },
    {
      "text": "Par ceux qui marchent jusqu'à l'eau",
      "correct": true
    },
    {
      "text": "Par un tampon sans voix",
      "correct": false
    },
    {
      "text": "Par les enfants du soir",
      "correct": false
    }
  ],
  "explanation": "Hawa : portée par ceux qui marchent jusqu'à l'eau."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il a été décidé",
      "right": "heures des seaux"
    },
    {
      "left": "est portée par",
      "right": "ceux qui marchent"
    },
    {
      "left": "a été relaté",
      "right": "Cahier des racines"
    },
    {
      "left": "sera examiné",
      "right": "Radio Figuier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCette mesure ___ portée par ceux qui marchent jusqu'à l'eau.",
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
    "Il",
    "a",
    "été",
    "décidé",
    "que",
    "les",
    "seaux",
    "auraient",
    "des",
    "heures",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "decide",
  "hint": "On l'a fait voter : un choix collectif, sans accent sur le verbe."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La mesure a été voter hier, et elle est portée par Hawa.",
  "correct_sentence": "La mesure a été votée hier, et elle est portée par Hawa.",
  "explanation": "Passif féminin : a été votée, accord avec mesure."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/voix-passive.svg",
      "word": "la voix passive"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/enjeu-societe.svg",
      "word": "un enjeu"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/banderole-rive.svg",
      "word": "une banderole"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/titre-une.svg",
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
  "prompt": "Notez quatre passifs et, pour chacun, l'élément mis en valeur (sujet)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il a été décidé que l'eau serait partagée. Cette mesure est portée par Hawa. La rivière a été protégée."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Feuille d''analyse : l''eau mise en sujet',
    'CE',
    $c$Objectif
Lire une analyse d'enjeu où le passif met la rivière et la mesure au premier plan.

Consigne
Lisez la feuille, sans aller trop vite.

Support — Feuille de Marc Nkurunziza, Cahier des racines
Enjeu — l'eau de la rivière (Rukiri-Nord, Seuil des Sources)
Ce qui a été décidé : un créneau unique, six heures-huit heures, pour les seaux communs.
Ce qui est mis en valeur : la rivière, pas le nom de celui qui parle le plus fort.
La mesure est portée par Dieudonné et Hawa ; elle est contestée par Noura, qui arrive après le minibus.
L'affiche a été collée trop haut : elle n'est pas lue par les enfants, à peine par Yvette.
Le chiffre des seaux a été vérifié : trois manquent ; cela n'a pas été inventé au marché.
Le tampon a été apposé par Solange. Un tampon n'est pas un argument ; il est seulement posé.
À Radio Figuier, le dossier sera examiné sans crier. Lila pèse ce qui a été vu à l'eau.
On relatera le partage, pas la rumeur d'une crue. La crue n'a pas été confirmée.
Question d'analyse : si l'on dit « Dieudonné a décidé », on met l'homme en avant ; si l'on dit « il a été décidé », on met la décision.
Aline : le passif n'efface pas l'agent ; il le recule, quand on veut éclairer l'enjeu.
Joël : une règle portée par la cour se tient ; une règle portée par un seul banc se fissure.
Mado : analyser, c'est choisir le sujet de la phrase autant que le fond.
Seuil des Sources — ne pas aller trop vite : l'eau n'attend pas le style, mais le style dit qui compte.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La feuille affirme que la crue a été confirmée.",
  "correct": false,
  "explanation": "« La crue n'a pas été confirmée. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi coller l'affiche trop haut pose-t-il problème ?",
  "options": [
    {
      "text": "Parce que Solange refuse le tampon",
      "correct": false
    },
    {
      "text": "Parce qu'elle n'est pas lue par les enfants",
      "correct": true
    },
    {
      "text": "Parce que la rivière a disparu",
      "correct": false
    },
    {
      "text": "Parce que Radio Figuier a fermé",
      "correct": false
    }
  ],
  "explanation": "« elle n'est pas lue par les enfants »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il a été décidé",
      "right": "un créneau unique"
    },
    {
      "left": "est portée par",
      "right": "Dieudonné et Hawa"
    },
    {
      "left": "est contestée par",
      "right": "Noura"
    },
    {
      "left": "sera examiné",
      "right": "le dossier à la radio"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'affiche ___ été collée trop haut.",
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
    "mesure",
    "est",
    "portée",
    "par",
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
  "word": "portee",
  "hint": "La mesure l'est par Hawa : participe du passif, sans accent."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les seaux ont été compté ce matin, et trois manquent encore.",
  "correct_sentence": "Les seaux ont été comptés ce matin, et trois manquent encore.",
  "explanation": "Passif pluriel : ont été comptés, accord avec seaux."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/enjeu-societe.svg",
      "word": "un enjeu"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/banderole-rive.svg",
      "word": "une banderole"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/titre-une.svg",
      "word": "un titre"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/subjonctif-opinion.svg",
      "word": "le subjonctif"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez l'analyse et encadrez chaque passif ; notez l'élément sujet."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la feuille de Marc, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire a été décidé, est porté par',
    'PO',
    $c$Objectif
Mettre un enjeu en valeur à l'oral en choisissant le sujet du passif.

Consigne
Répétez les modèles, puis reformulez un fait actif au passif pour éclairer l'eau.

Support — Modèles d'Aline et de Dieudonné
Il a été décidé que l'eau serait partagée.
Cette mesure est portée par la cour.
La rivière a été protégée dès l'aube.
L'affiche a été lue par Yvette, pas par les enfants.
Le tampon a été apposé au Bureau des Escales.
Les seaux ont été comptés.
Le dossier sera examiné ce soir.
Rien n'a été inventé au marché.
Une règle contestée par Noura doit encore être expliquée.
Ce qui a été voté n'efface pas ce qui a été oublié.
On met la rivière en sujet : la rivière a été ménagée.
On recule l'agent : par Hawa, par Solange, par l'assemblée.
Aline : le passif n'est pas un mensonge ; c'est un projecteur.
Marc : si l'agent compte, on le nomme après par.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Au passif, l'élément mis en valeur devient le sujet de la phrase.",
  "correct": true,
  "explanation": "Aline : le passif est un projecteur."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase met la rivière en valeur ?",
  "options": [
    {
      "text": "Dieudonné a protégé la rivière",
      "correct": false
    },
    {
      "text": "Hawa a parlé de la rivière",
      "correct": false
    },
    {
      "text": "La rivière a été protégée dès l'aube",
      "correct": true
    },
    {
      "text": "On a vu Dieudonné",
      "correct": false
    }
  ],
  "explanation": "La rivière est sujet du passif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il a été décidé",
      "right": "décision mise en sujet"
    },
    {
      "left": "est porté par",
      "right": "agent reculé"
    },
    {
      "left": "a été lue",
      "right": "affiche / Yvette"
    },
    {
      "left": "sera examiné",
      "right": "futur passif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes seaux ___ été comptés. (avoir)",
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
    "Cette",
    "mesure",
    "est",
    "portée",
    "par",
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
  "word": "affiche",
  "hint": "Papier collé au figuier, trop haut pour les enfants."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La rivière a été protéger dès l'aube, et le seau a été partagé.",
  "correct_sentence": "La rivière a été protégée dès l'aube, et le seau a été partagé.",
  "explanation": "Passif : été + protégée, pas l'infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/banderole-rive.svg",
      "word": "une banderole"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/titre-une.svg",
      "word": "un titre"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/subjonctif-opinion.svg",
      "word": "le subjonctif"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/prise-position.svg",
      "word": "une position"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez six phrases actives en passif ; soulignez le nouvel élément sujet."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis deux passifs à vous sur l'eau."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon analyse d''un enjeu',
    'PE',
    $c$Objectif
Écrire une analyse argumentative où le passif met en valeur l'eau et la mesure.

Consigne
Imitez l'analyse de Hawa Diallo, sans aller trop vite.

Support — Analyse de Hawa, Cahier des racines
Hawa Diallo — Seuil des Sources, Rukiri-Nord
Un enjeu a été posé, et il n'est pas mince : l'eau de la rivière, partagée ou gaspillée.
Il a été décidé qu'un créneau unique vaudrait pour les seaux communs. Cette décision est portée par ceux qui marchent.
Je mets la rivière en sujet : elle a été ménagée à l'aube, elle a été oubliée à midi, quand Noura arrive.
L'affiche a été collée trop haut ; elle n'est donc pas lue par tout le monde, et cela a été constaté par Yvette.
Le tampon a été apposé par Solange. Je ne le conteste pas ; je dis seulement qu'un tampon n'explique pas une soif.
Trois seaux ont été comptés manquants. Cela n'a pas été inventé au Marché des Lampions.
Si le dossier est examiné ce soir à Radio Figuier, qu'il le soit sans crier : le chiffre d'abord, la colère ensuite.
Une règle contestée par Noura n'est pas une règle nulle : elle est encore à expliquer, pas à jeter.
Je conclus : ce qui a été voté tient si ce qui a été oublié est nommé. Autrement, la mesure se fissure.
Hawa
Copie : Aline Uwase, Marc Nkurunziza, Bureau des Escales
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa dit qu'un tampon suffit à expliquer une soif.",
  "correct": false,
  "explanation": "« un tampon n'explique pas une soif. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que met Hawa en sujet pour éclairer l'enjeu ?",
  "options": [
    {
      "text": "Le tambour de Sami",
      "correct": false
    },
    {
      "text": "La rivière",
      "correct": true
    },
    {
      "text": "Le minibus Figuier 7",
      "correct": false
    },
    {
      "text": "Un palais",
      "correct": false
    }
  ],
  "explanation": "« Je mets la rivière en sujet. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il a été décidé",
      "right": "créneau unique"
    },
    {
      "left": "est portée par",
      "right": "ceux qui marchent"
    },
    {
      "left": "a été collée",
      "right": "affiche trop haute"
    },
    {
      "left": "n'a pas été inventé",
      "right": "les trois seaux"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTrois seaux ___ été comptés manquants.",
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
    "Un",
    "enjeu",
    "a",
    "été",
    "posé",
    "ce",
    "matin",
    "."
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
  "hint": "Règle votée pour l'eau : créneau, seaux, tampon."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La décision a été pris trop vite, et elle est encore portée par Hawa.",
  "correct_sentence": "La décision a été prise trop vite, et elle est encore portée par Hawa.",
  "explanation": "Accord : décision au féminin → prise."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/titre-une.svg",
      "word": "un titre"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/subjonctif-opinion.svg",
      "word": "le subjonctif"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/prise-position.svg",
      "word": "une position"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/micro-debat.svg",
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
  "prompt": "Imitez : quinze lignes argumentatives, six passifs, l'eau mise en sujet, un agent nommé par."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre analyse, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Voix passive pour mettre en valeur',
    'EL',
    $c$Objectif
Retenir formation, accord et choix du sujet au passif.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, passif d'analyse
Passif = être (conjugué) + participe passé.
Présent : la mesure est portée (par Hawa). PC : il a été décidé / la rivière a été protégée.
Futur : le dossier sera examiné. Agent : par + nom (facultatif).
On met en valeur l'élément devenu sujet : la rivière a été ménagée (l'eau, pas l'homme).
Impersonnel : il a été décidé que + indicatif. Il a été relaté que les seaux manquaient.
Accord du PP avec le sujet : la mesure a été votée ; les seaux ont été comptés ; l'affiche a été lue.
On ne dit pas : a été voter / a été protéger (infinitif). On ne dit pas : les seaux a été compté.
Actif → passif : Dieudonné a mesuré le niveau → le niveau a été mesuré (par Dieudonné).
Si l'agent compte politiquement, on le garde : contestée par Noura. S'il pèse trop, on le recule.
Le passif n'efface pas la responsabilité ; il choisit le projecteur.
À + le = au Bureau. De + le = du Cahier des racines.
Bien que la mesure soit contestée, elle a été tamponnée. (concession déjà connue)
Au Seuil : on analyse un enjeu, on ne crie pas un nom.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Au passif, le participe s'accorde avec le sujet.",
  "correct": true,
  "explanation": "La mesure a été votée ; les seaux ont été comptés."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Dieudonné a mesuré le niveau » au passif, c'est…",
  "options": [
    {
      "text": "Dieudonné a été mesuré par le niveau",
      "correct": false
    },
    {
      "text": "Le niveau a mesuré Dieudonné",
      "correct": false
    },
    {
      "text": "Le niveau a été mesuré par Dieudonné",
      "correct": true
    },
    {
      "text": "Le niveau est mesurer",
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
      "left": "par",
      "right": "agent"
    },
    {
      "left": "il a été décidé",
      "right": "impersonnel"
    },
    {
      "left": "a été votée",
      "right": "accord féminin"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'affiche a été ___ par Yvette. (lire)",
  "answer": "lue"
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
    "dossier",
    "sera",
    "examiné",
    "ce",
    "soir",
    "."
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
  "hint": "Celui par qui l'action est faite, reculé après par."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les heures ont été affiché trop haut, et l'eau a été ménagée.",
  "correct_sentence": "Les heures ont été affichées trop haut, et l'eau a été ménagée.",
  "explanation": "Heures au féminin pluriel → affichées."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/subjonctif-opinion.svg",
      "word": "le subjonctif"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/prise-position.svg",
      "word": "une position"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/micro-debat.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/balance-avis.svg",
      "word": "une balance"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau : huit actifs → huit passifs ; marquez l'élément mis en valeur."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six passifs : décidé, portée, protégée, lue, examinés, contestée."
}$j$::jsonb,
    9
  );

  -- ===== Prendre position =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Prendre position'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Prendre position', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Je veux que le soir reste tenable',
    'CO',
    $c$Objectif
Repérer le subjonctif de volonté, de doute, de sentiment, de but et de concession.

Consigne
Lisez le dialogue. Qui prend quelle position, et quel emploi du subjonctif entend-on ?

Support — Banc du figuier, après la veillée
Rose : Je veux que le tambour cesse après vingt et une heures. Les enfants doivent dormir.
Sami : Je doute que le silence soit une fête. Une veillée sans rythme n'est plus une veillée.
Aline : Je suis heureuse que la cour discute sans crier. Un avis n'est pas une injure.
Léa : Nous demandons que Radio Figuier baisse le micro, afin que la rive respire.
Patrick : Il faut que chacun parle, bien que la fatigue pèse déjà sur les paupières.
Marc : Je crains que cette règle ne casse la veillée. Craindre que : subjonctif, souvent avec ne explétif.
Hawa : Je souhaite que l'on trouve une heure, pas un interdit. Volonté n'est pas veto.
Joël : Quoique Sami tienne à son tambour, il peut frapper plus tôt. Concession.
Solange : J'exige que les heures calmes soient affichées au Bureau, pour que le tampon suive la voix.
Noura : Je ne suis pas sûre que vingt et une heures conviennent à ceux du minibus.
Lila : Il se peut que le soir tienne si l'on coupe seulement le dernier morceau.
Yvette : Je regrette que l'on oppose fête et sommeil. On peut vouloir les deux.
Dieudonné : Pour que les seaux de l'aube restent possibles, il faut que la cour dorme un peu.
Aline : Cinq emplois : volonté, doute, sentiment, but, concession. Tous appellent le subjonctif ici.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose emploie une volonté : je veux que le tambour cesse.",
  "correct": true,
  "explanation": "Rose : « Je veux que le tambour cesse après vingt et une heures. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel emploi illustre « bien que la fatigue pèse » ?",
  "options": [
    {
      "text": "le but",
      "correct": false
    },
    {
      "text": "le doute",
      "correct": false
    },
    {
      "text": "la concession",
      "correct": true
    },
    {
      "text": "le passif impersonnel",
      "correct": false
    }
  ],
  "explanation": "Bien que + subjonctif = concession."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je veux que / j'exige que",
      "right": "volonté"
    },
    {
      "left": "je doute que / il se peut que",
      "right": "doute"
    },
    {
      "left": "je suis heureuse que / je crains que",
      "right": "sentiment"
    },
    {
      "left": "afin que / pour que / bien que",
      "right": "but ou concession"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe veux que le tambour ___ après vingt et une heures. (cesser)",
  "answer": "cesse"
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
    "doute",
    "que",
    "le",
    "silence",
    "soit",
    "une",
    "fête",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "cesse",
  "hint": "Rose le veut pour le tambour : s'arrêter, au subjonctif."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je veux que le tambour cesse à l'heure dite, et il faut que chacun parlent sans crier.",
  "correct_sentence": "Je veux que le tambour cesse à l'heure dite, et il faut que chacun parle sans crier.",
  "explanation": "Chacun appelle le singulier : parle, pas parlent."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/prise-position.svg",
      "word": "une position"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/micro-debat.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/balance-avis.svg",
      "word": "une balance"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/fait-politique.svg",
      "word": "un fait politique"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Classez cinq répliques : volonté, doute, sentiment, but, concession."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je veux que le tambour cesse. Je doute que le silence soit une fête. Bien que la fatigue pèse, il faut que chacun parle."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Prises de position sur les heures calmes',
    'CE',
    $c$Objectif
Lire des avis où le subjonctif porte la volonté, le doute, le sentiment, le but et la concession.

Consigne
Lisez le recueil, sans aller trop vite.

Support — Recueil d'Aline, Salle des Herbes
Heures calmes — cinq voix, cinq emplois (Seuil des Sources)
Rose — volonté : je veux que le tambour cesse à vingt et une heures ; j'exige que l'affiche soit lisible.
Sami — doute : je doute que l'on puisse fêter sans rythme ; il n'est pas sûr que la cour accepte un silence plat.
Aline — sentiment : je suis heureuse que l'on discute ; je crains que la colère n'étouffe l'argument.
Léa et Patrick — but : nous parlons afin que la rive respire, pour que les enfants dorment, pour que l'aube des seaux reste possible.
Marc — concession : bien que la veillée soit précieuse, quoique Sami tienne à son tambour, une heure doit finir.
Solange ajoute : il faut que le Bureau tamponne ce que la voix a dit, afin que la règle ne flotte pas.
Noura : je ne suis pas certaine que vingt et une heures aillent à ceux du minibus Figuier 7.
Lila : il se peut que l'on coupe seulement le dernier morceau. Un doute n'est pas un refus.
Yvette : je regrette que l'on oppose fête et sommeil. On peut souhaiter que les deux tiennent.
Joël : encore que la cour soit lasse, elle peut voter sans crier.
Position n'est pas injure. Le subjonctif porte l'avis ; il ne le durcit pas.
Rukiri-Nord — veillée inventée de la cour, pas une fête d'ailleurs.
Aline : relisez chaque que, et nommez l'emploi avant de juger l'avis.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Yvette veut que l'on choisisse entre fête et sommeil, sans les deux.",
  "correct": false,
  "explanation": "Elle regrette qu'on les oppose ; on peut souhaiter que les deux tiennent."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle formule de Solange exprime un but ?",
  "options": [
    {
      "text": "je doute que l'on puisse fêter",
      "correct": false
    },
    {
      "text": "afin que la règle ne flotte pas",
      "correct": true
    },
    {
      "text": "je suis heureuse que l'on discute",
      "correct": false
    },
    {
      "text": "bien que la veillée soit précieuse",
      "correct": false
    }
  ],
  "explanation": "Afin que + subjonctif = but."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je veux que / j'exige que",
      "right": "Rose"
    },
    {
      "left": "je doute que",
      "right": "Sami"
    },
    {
      "left": "bien que / quoique",
      "right": "Marc"
    },
    {
      "left": "afin que / pour que",
      "right": "Léa / Solange"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nBien que la veillée ___ précieuse, une heure doit finir. (être)",
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
    "Il",
    "faut",
    "que",
    "le",
    "Bureau",
    "tamponne",
    "la",
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
  "word": "doute",
  "hint": "Sami l'exprime : il n'est pas sûr que le silence soit une fête."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que la veillée est précieuse, Sami tient encore à son tambour.",
  "correct_sentence": "Bien que la veillée soit précieuse, Sami tient encore à son tambour.",
  "explanation": "Bien que + subjonctif : soit, pas est."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/micro-debat.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/balance-avis.svg",
      "word": "une balance"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/fait-politique.svg",
      "word": "un fait politique"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/fait-culturel.svg",
      "word": "un fait culturel"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez cinq phrases, une par emploi, et soulignez le verbe au subjonctif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le recueil d'Aline, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire je veux que, je doute que, bien que',
    'PO',
    $c$Objectif
Prendre position à l'oral avec les cinq emplois du subjonctif.

Consigne
Répétez, puis donnez votre avis sur les heures calmes en variant les emplois.

Support — Modèles de Rose, Sami et Aline
Je veux que le soir reste tenable.
J'exige que l'affiche soit basse, lisible.
Je doute que le silence plaise à Sami.
Il se peut que l'on coupe seulement la fin.
Je suis heureuse que la cour discute.
Je crains que la colère n'étouffe l'argument.
Je regrette que l'on oppose fête et sommeil.
Nous parlons afin que la rive respire.
Il faut que chacun s'exprime.
Bien que la veillée soit précieuse, une heure finit.
Quoique Sami tienne au tambour, il peut frapper plus tôt.
Je souhaite que l'on trouve un créneau, pas un interdit.
Aline : le subjonctif porte l'avis ; le ton, lui, reste calme.
Patrick : une position se dit, elle ne s'impose pas au cri.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je crains que » se construit avec le subjonctif, souvent avec ne explétif.",
  "correct": true,
  "explanation": "Je crains que la colère n'étouffe l'argument."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase exprime une concession ?",
  "options": [
    {
      "text": "Je veux que le soir reste tenable",
      "correct": false
    },
    {
      "text": "Je doute que le silence plaise à Sami",
      "correct": false
    },
    {
      "text": "Bien que la veillée soit précieuse une heure finit",
      "correct": true
    },
    {
      "text": "J'exige que l'affiche soit basse",
      "correct": false
    }
  ],
  "explanation": "Bien que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je veux que",
      "right": "volonté"
    },
    {
      "left": "je doute que",
      "right": "doute"
    },
    {
      "left": "je crains que",
      "right": "sentiment"
    },
    {
      "left": "bien que",
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
  "prompt": "Complétez :\nAfin que la rive ___, nous baissons le micro. (respirer)",
  "answer": "respire"
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
    "souhaite",
    "que",
    "l'on",
    "trouve",
    "un",
    "créneau",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "crains",
  "hint": "Sentiment : j'ai peur que la colère n'étouffe l'argument."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je veux que le tambour cesse après l'heure dite, et je doute que le silence est une fête.",
  "correct_sentence": "Je veux que le tambour cesse après l'heure dite, et je doute que le silence soit une fête.",
  "explanation": "Douter que + subjonctif : soit, pas est."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/balance-avis.svg",
      "word": "une balance"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/fait-politique.svg",
      "word": "un fait politique"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/fait-culturel.svg",
      "word": "un fait culturel"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/urne-inventee.svg",
      "word": "une urne"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez dix phrases : deux par emploi (volonté, doute, sentiment, but, concession)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis deux positions à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma prise de position',
    'PE',
    $c$Objectif
Écrire un avis argumenté qui emploie les cinq familles du subjonctif.

Consigne
Imitez la position de Léa Niyonzima, sans aller trop vite.

Support — Position de Léa, enveloppe ocre
Léa Niyonzima — heures calmes, Seuil des Sources
Je veux que la veillée reste une fête, et j'exige que le dernier morceau cesse à vingt et une heures.
Je doute que Sami perde sa place si le tambour finit plus tôt ; il se peut que le rythme tienne mieux, plus court.
Je suis heureuse que la cour en discute sous le figuier. Je crains pourtant que la fatigue n'empêche d'écouter Noura.
Nous demandons que Radio Figuier baisse le micro, afin que la rive respire et pour que les enfants dorment.
Bien que la veillée soit précieuse, quoique Joël aime le bruit ami, une heure doit pouvoir finir sans injure.
Il faut que Solange tamponne ce que nous dirons, pour que la règle ne flotte pas d'un banc à l'autre.
Je regrette que l'on oppose sommeil et fête. Je souhaite que les deux tiennent, chacun à son temps.
Patrick ajoute : je ne suis pas sûr que vingt et une heures aillent à ceux du minibus ; encore que l'heure soit stricte, on peut l'ajuster.
Ma position n'est pas un cri : c'est un que, plusieurs fois, avec le mode qui convient.
Léa
Copie : Aline, Sami, Rose, Cahier des racines
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa veut supprimer la veillée pour imposer le silence toute la nuit.",
  "correct": false,
  "explanation": "Elle veut que la veillée reste une fête, et que le dernier morceau cesse à vingt et une heures."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que demande Léa à Radio Figuier ?",
  "options": [
    {
      "text": "Fermer l'antenne pour toujours",
      "correct": false
    },
    {
      "text": "Baisser le micro afin que la rive respire",
      "correct": true
    },
    {
      "text": "Interdire le figuier",
      "correct": false
    },
    {
      "text": "Changer Solange",
      "correct": false
    }
  ],
  "explanation": "« que Radio Figuier baisse le micro, afin que la rive respire »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je veux que / j'exige que",
      "right": "volonté"
    },
    {
      "left": "je doute que / il se peut que",
      "right": "doute"
    },
    {
      "left": "je crains que / je suis heureuse que",
      "right": "sentiment"
    },
    {
      "left": "afin que / bien que",
      "right": "but / concession"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nBien que la veillée ___ précieuse, une heure doit finir. (être)",
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
    "Il",
    "faut",
    "que",
    "Solange",
    "tamponne",
    "notre",
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
  "word": "veillee",
  "hint": "Fête du soir sous le figuier, sans accent, que Léa veut garder."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je souhaite que les deux tiennent chacun à son temps, et je veux que Radio Figuier baissent le micro.",
  "correct_sentence": "Je souhaite que les deux tiennent chacun à son temps, et je veux que Radio Figuier baisse le micro.",
  "explanation": "Radio Figuier, sujet singulier : baisse, pas baissent."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/fait-politique.svg",
      "word": "un fait politique"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/fait-culturel.svg",
      "word": "un fait culturel"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/urne-inventee.svg",
      "word": "une urne"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/salle-herbes.svg",
      "word": "la Salle des Herbes"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : quinze lignes, cinq emplois du subjonctif, une position claire sur les heures calmes."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre position, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Emplois du subjonctif pour l''avis',
    'EL',
    $c$Objectif
Retenir volonté, doute, sentiment, but et concession au subjonctif présent.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, subjonctif d'opinion
Volonté : vouloir / exiger / demander / souhaiter / il faut que + subj.
Je veux que tu parles. J'exige que l'affiche soit lisible. Il faut que chacun s'exprime.
Doute : douter que / il se peut que / il n'est pas sûr que / je ne suis pas certain(e) que + subj.
Je doute que le silence plaise. Il se peut que l'on coupe la fin.
Sentiment : être heureux que / craindre que / regretter que / être étonné que + subj.
Je crains que la colère n'étouffe l'argument. (ne explétif, pas une négation)
But : pour que / afin que + subj. (sujet différent). Pour + infinitif si même sujet.
Concession : bien que / quoique / encore que + subj. Pourtant / cependant + indicatif.
Formes : que je sois, que tu aies, qu'il fasse, que nous prenions, que vous puissiez, qu'ils aillent.
Cesser au subj. : que le tambour cesse. Tenir : quoiqu'il tienne. Aller : que l'heure aille.
On ne dit pas : je doute que le silence est… On dit : soit.
Après une volonté négative : je ne veux pas que tu cries (subj. quand même).
Prendre position, c'est choisir l'emploi, puis la forme, puis le ton.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Pourtant » se construit comme « bien que », avec le subjonctif.",
  "correct": false,
  "explanation": "Pourtant + indicatif. Bien que + subjonctif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Je crains que la colère n'étouffe » : le ne est…",
  "options": [
    {
      "text": "une négation obligatoire de tout l'avis",
      "correct": false
    },
    {
      "text": "un ne explétif, pas une négation",
      "correct": true
    },
    {
      "text": "une erreur à barrer toujours",
      "correct": false
    },
    {
      "text": "un passif",
      "correct": false
    }
  ],
  "explanation": "Ne explétif après craindre que."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "vouloir / exiger / il faut que",
      "right": "volonté"
    },
    {
      "left": "douter / il se peut que",
      "right": "doute"
    },
    {
      "left": "craindre / regretter",
      "right": "sentiment"
    },
    {
      "left": "bien que / afin que",
      "right": "concession / but"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut que chacun ___ . (s'exprimer)",
  "answer": "s'exprime"
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
    "veux",
    "pas",
    "que",
    "tu",
    "cries",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "exigent",
  "hint": "Ils… que l'affiche soit lisible : volonté forte, troisième personne."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je doute que le silence est plat, et je veux que tu parles sans crier.",
  "correct_sentence": "Je doute que le silence soit plat, et je veux que tu parles sans crier.",
  "explanation": "Douter que + subjonctif : soit, pas est."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/fait-culturel.svg",
      "word": "un fait culturel"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/urne-inventee.svg",
      "word": "une urne"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/salle-herbes.svg",
      "word": "la Salle des Herbes"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/alternative-subj.svg",
      "word": "une alternative"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Conjuguez être, avoir, faire, pouvoir, aller, cesser au subjonctif (il / nous / vous)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et cinq phrases, un emploi chacune."
}$j$::jsonb,
    9
  );

  -- ===== Fait culturel et politique =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Fait culturel et politique'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Fait culturel et politique', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La veillée comme fait de la cour',
    'CO',
    $c$Objectif
Décrire un fait inventé de la cour : assemblée, motion, veillée comme fait social.

Consigne
Lisez le dialogue. En quoi la veillée des lanternes est-elle à la fois culturelle et politique ?

Support — Cour du figuier, lanternes encore chaudes
Marc : Un fait culturel, ici, ce n'est pas une fête d'ailleurs : c'est la veillée des lanternes, inventée par la cour.
Aline : Un fait politique, ici, ce n'est pas un parti : c'est une motion votée sous le figuier, tamponnée au Bureau des Escales.
Rose : Hier, l'assemblée s'est tenue. Une motion a été lue : que les lanternes ne restent pas au bord de la rivière.
Sami : La veillée rassemble. C'est un fait social : on y vient, on y parle, on y laisse parfois trop d'huile.
Léa : Ce qui a été voté concerne le déchet, pas la fête. On peut aimer la veillée et refuser le gaspillage.
Patrick : Solange a noté : motion n°14, Cahier des racines. Un numéro n'est pas une loi d'État ; c'est une règle de cour.
Hawa : Certains ont levé la main. D'autres ont gardé le silence. Le silence aussi est un fait.
Joël : On décrit : qui, où, quand, quelle motion, quel geste. On n'invente pas un ministre.
Lila : Radio Figuier relatera la veillée comme un fait, pas comme une campagne.
Yvette : Les enfants ont appris à poser la lanterne dans le panier, pas dans l'herbe.
Dieudonné : L'huile au bord de l'eau a été vue. Cela a été dit sans crier.
Mado : Fait culturel : on se rassemble. Fait politique : on vote une limite.
Karim : La Salle des Herbes a servi à compter les lanternes. L'accès, lui, viendra plus tard.
Aline : Décrire, c'est tenir les deux : le rite et la règle, sans les fondre.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick dit que la motion n°14 est une loi d'État.",
  "correct": false,
  "explanation": "« Un numéro n'est pas une loi d'État ; c'est une règle de cour. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que demandait la motion lue à l'assemblée ?",
  "options": [
    {
      "text": "Interdire la veillée",
      "correct": false
    },
    {
      "text": "Que les lanternes ne restent pas au bord de la rivière",
      "correct": true
    },
    {
      "text": "Fermer Radio Figuier",
      "correct": false
    },
    {
      "text": "Changer le figuier",
      "correct": false
    }
  ],
  "explanation": "Rose : lanternes hors du bord de la rivière."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "fait culturel",
      "right": "veillée des lanternes"
    },
    {
      "left": "fait politique",
      "right": "motion tamponnée"
    },
    {
      "left": "assemblée",
      "right": "sous le figuier"
    },
    {
      "left": "Cahier des racines",
      "right": "motion n°14"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne motion a été ___ : que les lanternes ne restent pas au bord de l'eau. (lire)",
  "answer": "lue"
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
    "veillée",
    "rassemble",
    "la",
    "cour",
    "chaque",
    "jeudi",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "motion",
  "hint": "Texte voté sous le figuier, puis tamponné au Bureau."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La veillée a été décrit comme un fait social, et la motion a été lue sans crier.",
  "correct_sentence": "La veillée a été décrite comme un fait social, et la motion a été lue sans crier.",
  "explanation": "Accord : veillée féminin → décrite."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/urne-inventee.svg",
      "word": "une urne"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/salle-herbes.svg",
      "word": "la Salle des Herbes"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/alternative-subj.svg",
      "word": "une alternative"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/comparaison-nuance.svg",
      "word": "une comparaison"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez trois traits culturels et trois traits politiques de la veillée inventée."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : La veillée est un fait social. Une motion a été votée. On décrit le rite et la règle."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Compte rendu de l''assemblée',
    'CE',
    $c$Objectif
Lire le compte rendu d'un fait de cour : veillée, motion, tampon.

Consigne
Lisez le compte rendu, sans aller trop vite.

Support — Compte rendu de Lila Sow, Feuille du Seuil
Assemblée sous le figuier — jeudi, Seuil des Sources (Rukiri-Nord)
Fait culturel : la veillée des lanternes a eu lieu comme chaque saison sèche inventée de la cour. On s'y retrouve, on y parle bas, on y pose une flamme.
Fait politique : une motion a été proposée par Rose, relue par Marc, portée par une part de l'assemblée.
Texte : les lanternes éteintes seront déposées dans le panier ocre, non au bord de la rivière.
Qui a levé la main : Hawa, Dieudonné, Yvette, Joël, Léa. Qui s'est tu : Noura, d'abord, puis a demandé l'heure du panier.
Solange a tamponné la motion n°14 au Bureau des Escales. Un tampon de cour n'est pas un sceau d'État.
Sami a dit que la veillée restait une fête. Personne n'a demandé qu'elle disparaisse.
L'huile au bord de l'eau a été vue par Dieudonné. Le fait a été relaté, pas dramatisé.
Karim a noté que la Salle des Herbes avait servi à compter. L'accès à la salle n'était pas à l'ordre du jour.
Radio Figuier relayera ce compte rendu ce soir, sans slogan.
Aline : décrire un fait, c'est séparer le rite (on se rassemble) et la règle (on ne jette pas l'huile).
Mado : un silence dans l'assemblée est aussi un fait : il sera nommé, pas interprété trop vite.
Patrick : nous n'avons ni parti ni tribune ; nous avons un figuier, un cahier, un tampon.
Fin de compte rendu — ne pas confondre veillée et campagne.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Quelqu'un a demandé que la veillée disparaisse.",
  "correct": false,
  "explanation": "« Personne n'a demandé qu'elle disparaisse. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où les lanternes éteintes doivent-elles être déposées ?",
  "options": [
    {
      "text": "Au bord de la rivière",
      "correct": false
    },
    {
      "text": "Dans le panier ocre",
      "correct": true
    },
    {
      "text": "Sous le minibus",
      "correct": false
    },
    {
      "text": "À Radio Figuier seulement",
      "correct": false
    }
  ],
  "explanation": "« déposées dans le panier ocre, non au bord de la rivière. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "veillée des lanternes",
      "right": "fait culturel"
    },
    {
      "left": "motion n°14",
      "right": "fait politique de cour"
    },
    {
      "left": "panier ocre",
      "right": "lanternes éteintes"
    },
    {
      "left": "Bureau des Escales",
      "right": "tampon de Solange"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSolange a tamponné la motion ___ Bureau des Escales.",
  "answer": "au"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Personne",
    "n'a",
    "demandé",
    "que",
    "la",
    "veillée",
    "disparaisse",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "assemblee",
  "hint": "Réunion sous le figuier, sans accent, où l'on vote une règle."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La motion a été proposer par Rose, et elle a été relue par Marc.",
  "correct_sentence": "La motion a été proposée par Rose, et elle a été relue par Marc.",
  "explanation": "Passif : proposée, pas l'infinitif proposer."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/salle-herbes.svg",
      "word": "la Salle des Herbes"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/alternative-subj.svg",
      "word": "une alternative"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/comparaison-nuance.svg",
      "word": "une comparaison"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/enquete-rukiri.svg",
      "word": "une enquête"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le compte rendu et séparez en deux colonnes : rite / règle."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le compte rendu de Lila, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Décrire un fait de cour',
    'PO',
    $c$Objectif
Relater à l'oral un fait culturel et un fait politique inventés, sans les fondre.

Consigne
Répétez, puis décrivez la veillée et la motion en deux temps.

Support — Modèles de Marc et d'Aline
La veillée des lanternes est un fait culturel de la cour.
On s'y rassemble ; on y parle bas.
Une assemblée s'est tenue sous le figuier.
Une motion a été lue, puis tamponnée.
Le texte concerne les lanternes éteintes, pas la fête.
On dépose le reste dans le panier ocre.
Personne n'a demandé que la veillée disparaisse.
Un tampon de cour n'est pas un sceau d'État.
Le silence de Noura a été un fait ; il n'a pas été un vote.
Radio Figuier relatera sans slogan.
Le rite rassemble ; la règle limite un geste.
Nous n'avons ni parti ni tribune.
Aline : décrire, c'est nommer qui, où, quand, quel geste.
Marc : le politique, ici, tient dans une main levée.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut aimer la veillée et voter une limite sur l'huile.",
  "correct": true,
  "explanation": "Le rite et la règle ne s'excluent pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que n'est pas le tampon de Solange, d'après les modèles ?",
  "options": [
    {
      "text": "Un acte du Bureau des Escales",
      "correct": false
    },
    {
      "text": "Un sceau d'État",
      "correct": true
    },
    {
      "text": "La suite d'une motion",
      "correct": false
    },
    {
      "text": "Une marque de cour",
      "correct": false
    }
  ],
  "explanation": "« Un tampon de cour n'est pas un sceau d'État. »"
}$j$::jsonb,
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
      "right": "fait culturel"
    },
    {
      "left": "motion / assemblée",
      "right": "fait politique de cour"
    },
    {
      "left": "panier ocre",
      "right": "geste réglé"
    },
    {
      "left": "sans slogan",
      "right": "Radio Figuier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn dépose le reste ___ panier ocre.",
  "answer": "dans"
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
    "rite",
    "rassemble",
    "et",
    "la",
    "règle",
    "limite",
    "un",
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
  "word": "lanterne",
  "hint": "Flamme de la veillée, à poser dans le panier une fois éteinte."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Un tampon de cour n'est pas un sceau d'État, et une motion a été lu sous le figuier.",
  "correct_sentence": "Un tampon de cour n'est pas un sceau d'État, et une motion a été lue sous le figuier.",
  "explanation": "Motion féminin → lue."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/alternative-subj.svg",
      "word": "une alternative"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/comparaison-nuance.svg",
      "word": "une comparaison"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/enquete-rukiri.svg",
      "word": "une enquête"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/loupe-fait.svg",
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
  "prompt": "Écrivez huit phrases : quatre sur le rite, quatre sur la motion."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis votre description en deux temps."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon compte rendu de fait',
    'PE',
    $c$Objectif
Écrire le compte rendu argumenté d'un fait culturel et politique de la cour.

Consigne
Imitez le compte rendu de Patrick Habimana, sans aller trop vite.

Support — Compte rendu de Patrick, Cahier des racines
Patrick Habimana — veillée et motion n°14
Je décris un fait, non une campagne. La veillée des lanternes, inventée par la cour du Seuil, a rassemblé jeudi ceux qui vivent à Rukiri-Nord.
C'est un fait culturel : on y vient pour la flamme, pour la voix basse, pour Sami, pas pour un drapeau.
C'est aussi un fait politique de cour : une assemblée s'est tenue sous le figuier, une motion a été lue.
Rose a proposé que les lanternes éteintes aillent au panier ocre, non à la rivière. Marc a relu. Des mains se sont levées.
Personne n'a exigé que la fête disparaisse. On a limité un geste, on n'a pas tué un rite.
Solange a tamponné au Bureau des Escales. J'écris clairement : ce tampon n'est pas un sceau d'État ; c'est une mémoire de cour.
L'huile au bord de l'eau a été vue. Le fait a été nommé. Dieudonné n'a pas crié.
Noura s'est tue d'abord, puis a demandé l'heure du panier. Ce silence est un fait ; je ne lui prête pas d'intention.
Radio Figuier relatera sans slogan. Je souhaite que ce compte rendu tienne dans le Cahier des racines.
Patrick
Copie : Lila Sow, Aline Uwase, Solange
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick prête à Noura l'intention de saboter la motion.",
  "correct": false,
  "explanation": "« je ne lui prête pas d'intention. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que distingue Patrick dans son texte ?",
  "options": [
    {
      "text": "Un parti et une tribune",
      "correct": false
    },
    {
      "text": "Un rite et une règle",
      "correct": true
    },
    {
      "text": "Un palais et un minibus",
      "correct": false
    },
    {
      "text": "Une ville réelle et une autre",
      "correct": false
    }
  ],
  "explanation": "On a limité un geste, on n'a pas tué un rite."
}$j$::jsonb,
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
      "right": "fait culturel"
    },
    {
      "left": "motion n°14",
      "right": "fait politique de cour"
    },
    {
      "left": "panier ocre",
      "right": "limite d'un geste"
    },
    {
      "left": "tampon",
      "right": "mémoire de cour"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPersonne n'a exigé que la fête ___ . (disparaître)",
  "answer": "disparaisse"
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
    "limité",
    "un",
    "geste",
    "sans",
    "tuer",
    "un",
    "rite",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "gaspillage",
  "hint": "Huile et lanternes laissées au bord de l'eau, ce que la motion refuse."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Personne n'a exigé que la fête disparaisse, et l'huile au bord de l'eau a été vu.",
  "correct_sentence": "Personne n'a exigé que la fête disparaisse, et l'huile au bord de l'eau a été vue.",
  "explanation": "Huile féminin → vue."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/comparaison-nuance.svg",
      "word": "une comparaison"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/enquete-rukiri.svg",
      "word": "une enquête"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/loupe-fait.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/editorial-racines.svg",
      "word": "un éditorial"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : quinze lignes, rite et règle séparés, un passif, un que + subjonctif, pas de parti réel."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre compte rendu, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Décrire un fait culturel et politique',
    'EL',
    $c$Objectif
Retenir le vocabulaire de l'assemblée de cour et la séparation rite / règle.

Consigne
Apprenez la fiche.

Support — Fiche de Marc, faits de cour
Fait culturel (inventé) : un rite de la cour — veillée des lanternes, chants, voix basse.
Fait politique (inventé) : une règle votée — assemblée, motion, main levée, tampon au Bureau des Escales.
Fait social : on se rassemble ; le silence d'un banc est aussi un fait.
On décrit : qui, où, quand, quel geste, quel texte. On n'invente pas un État, un parti, un ministre.
Motion : texte proposé, lu, voté, tamponné. Numéro dans le Cahier des racines.
Assemblée : sous le figuier, pas une chambre réelle. Urne inventée si l'on compte les voix.
Passif utile : une motion a été lue ; l'huile a été vue ; le silence a été nommé.
Subjonctif utile : personne n'a demandé que la veillée disparaisse ; on a proposé que les restes aillent au panier.
Ne pas fondre : on peut aimer le rite et voter la règle.
Ne pas crier : Radio Figuier relatera sans slogan.
Vocabulaire : proposer, relire, voter, tamponner, relater, décrire, nommer.
À + le = au Bureau, au figuier. De + le = du Cahier.
Le politique, ici, tient dans une main levée, pas dans une tribune d'ailleurs.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Au Seuil, une motion tamponnée équivaut à une loi d'État.",
  "correct": false,
  "explanation": "C'est une règle de cour, une mémoire, pas un sceau d'État."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que doit-on séparer en décrivant la veillée ?",
  "options": [
    {
      "text": "Le sel et le sucre seulement",
      "correct": false
    },
    {
      "text": "Le rite et la règle",
      "correct": true
    },
    {
      "text": "Léa et Patrick",
      "correct": false
    },
    {
      "text": "L'eau et le minibus sans lien",
      "correct": false
    }
  ],
  "explanation": "Rite (rassembler) / règle (limiter un geste)."
}$j$::jsonb,
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
      "right": "rite"
    },
    {
      "left": "motion",
      "right": "règle votée"
    },
    {
      "left": "tampon",
      "right": "Bureau des Escales"
    },
    {
      "left": "sans slogan",
      "right": "relater"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn a proposé que les restes ___ au panier. (aller)",
  "answer": "aillent"
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
    "motion",
    "a",
    "été",
    "lue",
    "sous",
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
  "word": "relater",
  "hint": "Dire le fait vu, sans slogan et sans ministre inventé de trop."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On a proposé que les restes aillent au panier, et la veillée a été relater sans slogan.",
  "correct_sentence": "On a proposé que les restes aillent au panier, et la veillée a été relatée sans slogan.",
  "explanation": "Passif : relatée, pas l'infinitif relater."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/enquete-rukiri.svg",
      "word": "une enquête"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/loupe-fait.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/editorial-racines.svg",
      "word": "un éditorial"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/cahier-racines.svg",
      "word": "le Cahier des racines"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez un mini-lexique : dix mots de l'assemblée de cour, avec un exemple chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et une description en six phrases : trois rites, trois règles."
}$j$::jsonb,
    9
  );

  -- ===== Nuancer une comparaison =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Nuancer une comparaison'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Nuancer une comparaison', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Que ce soit l''aube ou le soir',
    'CO',
    $c$Objectif
Repérer le subjonctif d'alternative : que ce soit… ou…, plutôt que + subjonctif.

Consigne
Lisez le dialogue. Comment nuance-t-on l'accès à la Salle des Herbes ?

Support — Seuil de la Salle des Herbes, clé de Solange
Aline : Que ce soit l'aube ou le soir, la salle ne peut pas rester un secret de quelques-uns.
Solange : Je préfère une plage d'ouverture claire, plutôt que la clé circule sans trace.
Karim : Que la salle soit ouverte le matin ou qu'elle ferme à midi, il faut que l'heure soit écrite.
Léa : Plutôt que l'accès soit réservé aux seuls anciens, que l'on inscrive aussi ceux du minibus.
Patrick : Que ce soit Hawa ou Dieudonné, quiconque enseigne un geste utile devrait pouvoir réserver.
Rose : Je compare sans casser : la cour large vaut mieux, plutôt qu'un cercle étroit se reproduise.
Marc : Nuancer, ce n'est pas tout égaliser. Que ce soit l'eau ou la salle, chaque enjeu a sa mesure.
Noura : Plutôt qu'on décide sans nous, nous viendrons à l'assemblée, même tard.
Joël : Que les enfants passent ou que les anciens restent, le banc de la salle n'est pas une propriété.
Lila : Radio Figuier dira les deux heures, que ce soit jeudi ou dimanche.
Yvette : Je crains le tout ou rien. Que ce soit trop ouvert ou trop fermé, la cour perd.
Félicie : Plutôt que la salle serve de dépôt, qu'elle reste un lieu de parole.
Mado : Comparer A et B, puis choisir une voie, plutôt que l'on s'insulte.
Aline : Formules : que ce soit… ou… ; que… ou que… ; plutôt que + subjonctif.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Solange préfère que la clé circule sans trace.",
  "correct": false,
  "explanation": "Elle préfère une plage claire, plutôt que la clé circule sans trace."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que demande Léa, plutôt qu'un accès réservé aux anciens ?",
  "options": [
    {
      "text": "Fermer la salle pour toujours",
      "correct": false
    },
    {
      "text": "Inscrire aussi ceux du minibus",
      "correct": true
    },
    {
      "text": "Vendre la clé au marché",
      "correct": false
    },
    {
      "text": "Interdire Hawa",
      "correct": false
    }
  ],
  "explanation": "« que l'on inscrive aussi ceux du minibus »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "que ce soit l'aube ou le soir",
      "right": "alternative d'heure"
    },
    {
      "left": "plutôt que la clé circule",
      "right": "Solange"
    },
    {
      "left": "que… ou que…",
      "right": "Karim / Joël"
    },
    {
      "left": "plutôt qu'on décide sans nous",
      "right": "Noura"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nQue ce ___ l'aube ou le soir, la salle ne reste pas un secret.",
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
    "Que",
    "ce",
    "soit",
    "l'aube",
    "ou",
    "le",
    "soir",
    "la",
    "salle",
    "reste",
    "commune",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "plutot",
  "hint": "Lien d'alternative : … que la clé circule sans trace. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Que ce est l'aube ou le soir la salle reste commune, et je préfère une heure écrite plutôt que la clé circule sans trace.",
  "correct_sentence": "Que ce soit l'aube ou le soir la salle reste commune, et je préfère une heure écrite plutôt que la clé circule sans trace.",
  "explanation": "Que ce soit : subjonctif de être."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/loupe-fait.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/editorial-racines.svg",
      "word": "un éditorial"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/cahier-racines.svg",
      "word": "le Cahier des racines"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/plume-marc.svg",
      "word": "une plume"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez quatre alternatives : deux que ce soit… ou…, deux plutôt que + subj."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Que ce soit l'aube ou le soir, la salle reste commune. Plutôt que la clé circule sans trace, écrivons l'heure."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Note de nuance sur la Salle des Herbes',
    'CE',
    $c$Objectif
Lire une comparaison nuancée qui enchaîne que ce soit… ou… et plutôt que + subj.

Consigne
Lisez la note, sans aller trop vite.

Support — Note de Solange, Bureau des Escales
Accès à la Salle des Herbes — comparer sans casser
Que ce soit l'aube ou le soir, une heure écrite vaut mieux qu'un bruit de clé.
Que la salle ouvre le jeudi ou qu'elle ouvre le dimanche, l'inscription se fait au Bureau, pas sous une pierre.
Plutôt que l'accès soit réservé aux seuls anciens, j'inscrirai aussi ceux du minibus Figuier 7, à condition qu'ils signent.
Plutôt que la clé circule sans trace, elle restera dans le tiroir tamponné. On la retire, on la rend.
Que ce soit Hawa, Dieudonné ou Félicie, quiconque prépare un geste utile peut réserver une plage.
Je compare deux peurs : trop fermé, la cour étouffe ; trop ouvert, la salle devient un dépôt.
Plutôt que l'on s'insulte, que l'on vote une plage, une durée, un nom sur le cahier.
Noura a dit : plutôt qu'on décide sans nous, nous viendrons, même après le pont.
Marc nuance : que ce soit l'eau, les lanternes ou la salle, chaque enjeu a sa mesure ; on ne copie pas une règle sur l'autre.
Aline : nuancer une comparaison, c'est garder les deux termes visibles, puis choisir.
Yvette : je crains le tout ou rien. Que ce soit trop d'huile ou trop de silence, la cour perd.
Lila relayera les deux heures, que ce soit par la radio ou par l'affiche du figuier.
Solange — Rukiri-Nord. Ce texte n'est pas un décret d'ailleurs ; c'est une nuance de cour.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Solange accepte que la clé circule sans trace si l'on est pressé.",
  "correct": false,
  "explanation": "Plutôt que la clé circule sans trace, elle restera dans le tiroir tamponné."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fera Solange plutôt que de réserver la salle aux seuls anciens ?",
  "options": [
    {
      "text": "Fermer le Bureau",
      "correct": false
    },
    {
      "text": "Inscrire aussi ceux du minibus, s'ils signent",
      "correct": true
    },
    {
      "text": "Cacher la clé sous une pierre",
      "correct": false
    },
    {
      "text": "Interdire le jeudi",
      "correct": false
    }
  ],
  "explanation": "« j'inscrirai aussi ceux du minibus… à condition qu'ils signent »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "que ce soit l'aube ou le soir",
      "right": "heure écrite"
    },
    {
      "left": "plutôt que la clé circule",
      "right": "tiroir tamponné"
    },
    {
      "left": "que ce soit Hawa ou Félicie",
      "right": "quiconque utile"
    },
    {
      "left": "plutôt qu'on décide sans nous",
      "right": "Noura"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPlutôt que l'accès ___ réservé aux anciens, on inscrira d'autres voix. (être)",
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
    "Que",
    "ce",
    "soit",
    "le",
    "jeudi",
    "ou",
    "le",
    "dimanche",
    "on",
    "inscrit",
    "au",
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
  "word": "nuance",
  "hint": "Comparer deux peurs sans tout égaliser, puis choisir une plage."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Que ce soit l'aube ou le soir une heure écrite vaut mieux, et plutôt que la clé circulent sans trace elle restera au tiroir.",
  "correct_sentence": "Que ce soit l'aube ou le soir une heure écrite vaut mieux, et plutôt que la clé circule sans trace elle restera au tiroir.",
  "explanation": "La clé, singulier : circule."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/editorial-racines.svg",
      "word": "un éditorial"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/cahier-racines.svg",
      "word": "le Cahier des racines"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/plume-marc.svg",
      "word": "une plume"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/tampon-cour.svg",
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
  "prompt": "Recopiez la note et encadrez que ce soit / plutôt que + verbe au subjonctif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la note de Solange, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire que ce soit… ou…, plutôt que',
    'PO',
    $c$Objectif
Nuancer à l'oral une comparaison avec le subjonctif d'alternative.

Consigne
Répétez, puis comparez deux accès à la salle sans tomber dans le tout ou rien.

Support — Modèles d'Aline et de Noura
Que ce soit l'aube ou le soir, l'heure s'écrit.
Que ce soit jeudi ou dimanche, on inscrit au Bureau.
Que la salle ouvre tôt ou qu'elle ferme à midi, la clé se rend.
Plutôt que la clé circule sans trace, elle reste au tiroir.
Plutôt que l'accès soit réservé aux anciens, inscrivons ceux du minibus.
Plutôt qu'on décide sans nous, nous viendrons à l'assemblée.
Que ce soit Hawa ou Dieudonné, quiconque utile peut réserver.
Je compare trop fermé et trop ouvert : la cour perd dans les deux cas.
Nuancer, ce n'est pas tout égaliser.
Une plage vaut mieux qu'un secret.
Que ce soit l'eau ou la salle, chaque enjeu a sa mesure.
Aline : plutôt que + subjonctif met l'option refusée au mode de l'avis.
Noura : que… ou que… tient les deux portes ouvertes le temps de choisir.
Marc : le tout ou rien casse la comparaison.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Plutôt que la clé circule » emploie le subjonctif après plutôt que.",
  "correct": true,
  "explanation": "Circule : subjonctif (identique à l'indicatif ici, 3e pers.)."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est une alternative correcte ?",
  "options": [
    {
      "text": "Que ce est l'aube ou le soir",
      "correct": false
    },
    {
      "text": "Que ce soit l'aube ou le soir l'heure s'écrit",
      "correct": true
    },
    {
      "text": "Que ce sera l'aube ou le soir",
      "correct": false
    },
    {
      "text": "Plutôt que de la clé est circulé",
      "correct": false
    }
  ],
  "explanation": "Que ce soit A ou B."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "que ce soit… ou…",
      "right": "deux termes tenus"
    },
    {
      "left": "que… ou que…",
      "right": "deux phrases au subj."
    },
    {
      "left": "plutôt que + subj.",
      "right": "option refusée"
    },
    {
      "left": "nuancer",
      "right": "pas tout égaliser"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPlutôt qu'on ___ sans nous, nous viendrons. (décider)",
  "answer": "décide"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Que",
    "ce",
    "soit",
    "Hawa",
    "ou",
    "Dieudonné",
    "on",
    "peut",
    "réserver",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "alternative",
  "hint": "Deux voies tenues ensemble : aube ou soir, ouvert ou fermé."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Que ce soit l'aube ou le soir l'heure s'écrit, et plutôt que la clé circule sans trace elle restent au tiroir.",
  "correct_sentence": "Que ce soit l'aube ou le soir l'heure s'écrit, et plutôt que la clé circule sans trace elle reste au tiroir.",
  "explanation": "Elle (la clé) : reste, pas restent."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/cahier-racines.svg",
      "word": "le Cahier des racines"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/plume-marc.svg",
      "word": "une plume"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/tampon-cour.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/riviere-enjeu.svg",
      "word": "la rivière"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases : quatre que ce soit… ou…, quatre plutôt que + subj."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis deux nuances à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma comparaison nuancée',
    'PE',
    $c$Objectif
Écrire une comparaison argumentée avec que ce soit… ou… et plutôt que + subj.

Consigne
Imitez la note de Noura, sans aller trop vite.

Support — Note de Noura, Salle des Herbes
Noura — accès à la Salle des Herbes, vue depuis le minibus
Que ce soit l'aube ou le soir, je ne peux pas toujours arriver à l'heure des anciens.
Cela n'annule pas mon droit d'apprendre un geste.
Plutôt que l'accès soit réservé à ceux qui habitent tout près du figuier, que l'on inscrive aussi ceux du Figuier 7.
Que la salle ouvre le jeudi ou qu'elle ouvre le dimanche, l'heure doit être écrite au Bureau des Escales, pas soufflée d'un banc à l'autre.
Plutôt que la clé circule sans trace, Solange la garde ; on la retire, on la rend.
Je m'y plie, et je le dis sans rancune.
Je compare deux peurs : trop fermé, je reste sur le pont ; trop ouvert, la salle devient un dépôt.
Félicie a raison de craindre le dépôt ; j'ai raison de craindre le secret.
Plutôt qu'on décide sans nous, nous viendrons à l'assemblée, même tard, même fatigués.
Que ce soit Hawa ou Dieudonné qui enseigne, quiconque prépare un geste utile devrait pouvoir réserver une plage.
Nuancer, pour moi, ce n'est pas tout égaliser : c'est refuser le tout ou rien.
Noura
Copie : Solange, Aline, Karim, Cahier des racines
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Noura refuse de rendre la clé et veut qu'elle circule sans trace.",
  "correct": false,
  "explanation": "Elle se plie à la règle : on la retire, on la rend."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que refuse Noura, plutôt qu'un accès trop étroit ?",
  "options": [
    {
      "text": "Que l'on inscrive ceux du minibus",
      "correct": false
    },
    {
      "text": "Que l'accès soit réservé à ceux qui habitent tout près",
      "correct": true
    },
    {
      "text": "Que Solange tamponne",
      "correct": false
    },
    {
      "text": "Que Félicie parle",
      "correct": false
    }
  ],
  "explanation": "« Plutôt que l'accès soit réservé à ceux qui habitent tout près »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "que ce soit l'aube ou le soir",
      "right": "droit d'apprendre"
    },
    {
      "left": "plutôt que l'accès soit réservé",
      "right": "inscrire le minibus"
    },
    {
      "left": "plutôt que la clé circule",
      "right": "Solange la garde"
    },
    {
      "left": "plutôt qu'on décide sans nous",
      "right": "venir à l'assemblée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nQue la salle ___ le jeudi ou qu'elle ouvre le dimanche, l'heure s'écrit. (ouvrir)",
  "answer": "ouvre"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Nuancer",
    "ce",
    "n'est",
    "pas",
    "tout",
    "égaliser",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "inscrire",
  "hint": "Porter un nom sur le cahier du Bureau, pour une plage de salle."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Que ce soit l'aube ou le soir je viendrai, et plutôt que l'accès est réservé aux proches on inscrira le minibus.",
  "correct_sentence": "Que ce soit l'aube ou le soir je viendrai, et plutôt que l'accès soit réservé aux proches on inscrira le minibus.",
  "explanation": "Plutôt que + subjonctif : soit, pas est."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/plume-marc.svg",
      "word": "une plume"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/tampon-cour.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/riviere-enjeu.svg",
      "word": "la rivière"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/figuier-agora.svg",
      "word": "le figuier"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : quinze lignes, trois que ce soit… ou…, trois plutôt que + subj., une peur de trop fermé et une de trop ouvert."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre note, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Subjonctif d''alternative',
    'EL',
    $c$Objectif
Retenir que ce soit… ou…, que… ou que…, plutôt que + subjonctif.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, alternatives
Que ce soit A ou B + indicatif dans la suite, souvent :
Que ce soit l'aube ou le soir, l'heure s'écrit. (soit = subj. de être)
Que + phrase au subj. + ou que + phrase au subj. :
Que la salle ouvre tôt ou qu'elle ferme à midi, la clé se rend.
Plutôt que + subjonctif : option que l'on refuse, encore possible :
Plutôt que la clé circule sans trace, elle reste au tiroir.
Plutôt que l'accès soit réservé aux anciens, inscrivons les autres.
Plutôt qu'on décide sans nous, nous viendrons. (qu'on = que + on)
Fréquent aussi : plutôt que de + infinitif (même sujet) : plutôt que de crier, votons.
Ici on travaille le subjonctif d'alternative, plus marqué à l'oral soigné et à l'écrit.
Nuancer ≠ tout égaliser. On tient les deux termes, puis on choisit une mesure.
On ne dit pas : que ce est… / plutôt que l'accès est réservé (indicatif après plutôt que dans cet emploi).
Tout ou rien : à éviter. Que ce soit trop ouvert ou trop fermé, la cour perd.
À + le = au Bureau. De + le = du figuier.
Chaque enjeu (eau, lanternes, salle) a sa mesure : on ne copie pas une règle sur l'autre.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Que ce soit » emploie le subjonctif de être.",
  "correct": true,
  "explanation": "Soit = subjonctif, 3e personne."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle construction refuse une option au subjonctif ?",
  "options": [
    {
      "text": "parce que + indicatif seulement",
      "correct": false
    },
    {
      "text": "plutôt que la clé circule",
      "correct": true
    },
    {
      "text": "pendant que + imparfait seulement",
      "correct": false
    },
    {
      "text": "il y a + nom seulement",
      "correct": false
    }
  ],
  "explanation": "Plutôt que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "que ce soit A ou B",
      "right": "deux termes"
    },
    {
      "left": "que… ou que…",
      "right": "deux phrases"
    },
    {
      "left": "plutôt que + subj.",
      "right": "option refusée"
    },
    {
      "left": "plutôt que de + inf.",
      "right": "même sujet, fréquent"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nQue ce ___ trop ouvert ou trop fermé, la cour perd.",
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
    "Plutôt",
    "que",
    "la",
    "clé",
    "circule",
    "sans",
    "trace",
    "elle",
    "reste",
    "au",
    "tiroir",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "egaliser",
  "hint": "Nuancer n'est pas tout… : on choisit encore une mesure. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Que ce soit l'aube ou le soir l'heure s'écrit, et plutôt que l'accès est trop étroit on ouvrira une plage.",
  "correct_sentence": "Que ce soit l'aube ou le soir l'heure s'écrit, et plutôt que l'accès soit trop étroit on ouvrira une plage.",
  "explanation": "Plutôt que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/tampon-cour.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/riviere-enjeu.svg",
      "word": "la rivière"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/figuier-agora.svg",
      "word": "le figuier"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/groupe-citoyens.svg",
      "word": "des citoyens"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez six comparaisons sèches en alternatives (que ce soit / plutôt que + subj.)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six alternatives."
}$j$::jsonb,
    9
  );

  -- ===== Enquête à Rukiri-Nord =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Enquête à Rukiri-Nord'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Enquête à Rukiri-Nord', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Quatre voix pour une enquête',
    'CO',
    $c$Objectif
Relier passif, subjonctif et nuance dans une enquête de cour sur quatre enjeux.

Consigne
Lisez le dialogue. Quels faits ont été recueillis, et quelles positions s'entendent ?

Support — Table des Sources, carnets ouverts
Lila : L'enquête a été ouverte à Rukiri-Nord. Quatre enjeux, pas un slogan : eau, heures calmes, lanternes, salle.
Marc : Il a été entendu vingt voix sous le figuier. Rien n'a été inventé au marché.
Hawa : Que ce soit l'aube ou midi, l'eau manque à ceux qui arrivent tard. Je veux que le créneau soit expliqué, pas seulement tamponné.
Sami : Je doute que la veillée meure si le tambour finit plus tôt. Il se peut que le rythme tienne mieux, plus court.
Rose : Les lanternes ont été comptées. Douze sont encore au bord de l'eau. Cela a été vu par Dieudonné.
Solange : Plutôt que la clé de la salle circule sans trace, elle restera au Bureau. Bien que certains râlent, la trace protège.
Noura : Je suis heureuse que l'enquête nous nomme. Plutôt qu'on décide sans le minibus, que l'on inscrive nos heures.
Patrick : Une motion a été relue. Personne n'a demandé que la fête disparaisse.
Joël : Que ce soit trop d'huile ou trop de silence, la cour perd. Nuancer, ce n'est pas tout égaliser.
Yvette : Je crains que la fatigue n'empêche d'écouter la quatrième voix, celle de la salle.
Karim : Le dossier sera examiné à Radio Figuier. L'enquête est portée par Lila et Marc, pas par un cri.
Aline : On relie : passif pour le fait, subjonctif pour l'avis, alternative pour la nuance.
Mado : Un chiffre a été posé ; un souhait a été dit ; une peur a été nommée. C'est déjà une enquête.
Dieudonné : Si l'eau a été ménagée, que les heures le soient aussi pour ceux du pont.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Douze lanternes ont été vues encore au bord de l'eau.",
  "correct": true,
  "explanation": "Rose : « Douze sont encore au bord de l'eau. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Par qui l'enquête est-elle portée ?",
  "options": [
    {
      "text": "Par un cri du marché",
      "correct": false
    },
    {
      "text": "Par Lila et Marc",
      "correct": true
    },
    {
      "text": "Par un parti d'ailleurs",
      "correct": false
    },
    {
      "text": "Par le minibus vide",
      "correct": false
    }
  ],
  "explanation": "Karim : portée par Lila et Marc."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "l'enquête a été ouverte",
      "right": "passif de fait"
    },
    {
      "left": "je veux que / je doute que",
      "right": "avis au subj."
    },
    {
      "left": "que ce soit trop d'huile ou trop de silence",
      "right": "alternative"
    },
    {
      "left": "plutôt que la clé circule",
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
  "prompt": "Complétez :\nL'enquête ___ été ouverte à Rukiri-Nord.",
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
    "Rien",
    "n'a",
    "été",
    "inventé",
    "au",
    "marché",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "enquete",
  "hint": "Recueil de voix à Rukiri-Nord, sans accent, quatre enjeux."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "L'enquête a été ouverte sous le figuier, et vingt voix ont été entendu.",
  "correct_sentence": "L'enquête a été ouverte sous le figuier, et vingt voix ont été entendues.",
  "explanation": "Voix au féminin pluriel → entendues."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/riviere-enjeu.svg",
      "word": "la rivière"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/figuier-agora.svg",
      "word": "le figuier"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/groupe-citoyens.svg",
      "word": "des citoyens"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/affiche-societe.svg",
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
  "prompt": "Notez un passif, un subjonctif d'avis et une alternative pour chaque enjeu (eau, soir, lanternes, salle)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : L'enquête a été ouverte. Je veux que le créneau soit expliqué. Que ce soit trop d'huile ou trop de silence, la cour perd."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Synthèse d''enquête',
    'CE',
    $c$Objectif
Lire une synthèse qui relie faits passifs, avis au subjonctif et comparaisons nuancées.

Consigne
Lisez la synthèse, sans aller trop vite.

Support — Synthèse de Marc et Lila, Cahier des racines
Enquête à Rukiri-Nord — quatre enjeux, une cour
Eau. Il a été décidé un créneau d'aube.
La mesure est portée par Hawa et Dieudonné ; elle est contestée par Noura.
Que ce soit six heures ou huit heures, l'heure doit être lisible.
Plutôt que le créneau reste un secret de tampon, qu'il soit dit à la radio.
Heures calmes. Rose veut que le tambour cesse à vingt et une heures.
Sami doute que le silence soit une fête.
Bien que la veillée soit précieuse, une fin d'heure a été demandée.
Personne n'a exigé que la fête disparaisse.
Lanternes. Douze restes ont été vus au bord de l'eau. Une motion a été tamponnée : panier ocre, non rivière.
Le rite rassemble ; la règle limite un geste.
Salle des Herbes. Solange préfère une trace, plutôt que la clé circule.
Noura demande que ceux du minibus soient inscrits, que la salle ouvre jeudi ou qu'elle ouvre dimanche.
Méthode. Vingt voix ont été entendues. Rien n'a été inventé.
L'enquête est portée par la radio et le cahier, pas par un cri.
Aline : le passif pose le fait ; le subjonctif porte l'avis ; l'alternative empêche le tout ou rien.
Yvette : je crains que l'on n'oublie la quatrième voix.
Joël : que ce soit l'eau ou la salle, chaque mesure reste distincte.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La synthèse dit que quelqu'un a exigé la disparition de la veillée.",
  "correct": false,
  "explanation": "« Personne n'a exigé que la fête disparaisse. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de voix ont été entendues ?",
  "options": [
    {
      "text": "Deux",
      "correct": false
    },
    {
      "text": "Douze",
      "correct": false
    },
    {
      "text": "Vingt",
      "correct": true
    },
    {
      "text": "Cent",
      "correct": false
    }
  ],
  "explanation": "« Vingt voix ont été entendues. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "créneau d'aube",
      "right": "eau"
    },
    {
      "left": "vingt et une heures",
      "right": "heures calmes"
    },
    {
      "left": "panier ocre",
      "right": "lanternes"
    },
    {
      "left": "trace de clé",
      "right": "salle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPlutôt que le créneau reste un secret, qu'il ___ dit à la radio. (être)",
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
    "Vingt",
    "voix",
    "ont",
    "été",
    "entendues",
    "sous",
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
  "word": "synthese",
  "hint": "Texte qui relie quatre enjeux, sans accent, avant l'éditorial."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Vingt voix ont été entendues sous le figuier, et rien n'a été inventer au marché.",
  "correct_sentence": "Vingt voix ont été entendues sous le figuier, et rien n'a été inventé au marché.",
  "explanation": "Passif : inventé, pas l'infinitif inventer."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/figuier-agora.svg",
      "word": "le figuier"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/groupe-citoyens.svg",
      "word": "des citoyens"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/affiche-societe.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/radio-soir.svg",
      "word": "la radio"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la synthèse et marquez P (passif), S (subjonctif), A (alternative) dans la marge."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la synthèse d'enquête, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire les résultats sans crier',
    'PO',
    $c$Objectif
Restituer à l'oral l'enquête : faits au passif, avis au subjonctif, nuances.

Consigne
Répétez, puis présentez l'enquête en quatre points, sans slogan.

Support — Modèles de Lila et d'Aline
L'enquête a été ouverte à Rukiri-Nord.
Vingt voix ont été entendues.
L'eau : il a été décidé un créneau ; je veux qu'il soit expliqué.
Les heures calmes : je doute que la fête meure si le tambour finit plus tôt.
Les lanternes : douze restes ont été vus ; une motion a été tamponnée.
La salle : plutôt que la clé circule, elle reste au Bureau.
Que ce soit l'eau ou la salle, chaque mesure est distincte.
Bien que la veillée soit précieuse, une heure peut finir.
Personne n'a demandé que le rite disparaisse.
Nuancer, ce n'est pas tout égaliser.
Le dossier sera examiné à la radio.
Aline : on relie les outils, on ne les entasse pas.
Marc : un chiffre, un que, une alternative : déjà une enquête.
Karim : pas de parti, pas de tribune : un figuier, un cahier.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Les modèles refusent de fondre les quatre enjeux en un seul cri.",
  "correct": true,
  "explanation": "Chaque mesure reste distincte."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase mêle passif de fait et volonté au subjonctif ?",
  "options": [
    {
      "text": "Je crie plus fort que Sami",
      "correct": false
    },
    {
      "text": "Il a été décidé un créneau ; je veux qu'il soit expliqué",
      "correct": true
    },
    {
      "text": "On ferme tout",
      "correct": false
    },
    {
      "text": "Que ce est l'eau",
      "correct": false
    }
  ],
  "explanation": "Passé passif + je veux que + subj."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "a été ouverte / ont été entendues",
      "right": "faits"
    },
    {
      "left": "je veux que / je doute que",
      "right": "avis"
    },
    {
      "left": "plutôt que la clé circule",
      "right": "salle"
    },
    {
      "left": "que ce soit l'eau ou la salle",
      "right": "nuance"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nBien que la veillée ___ précieuse, une heure peut finir.",
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
    "dossier",
    "sera",
    "examiné",
    "à",
    "la",
    "radio",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "chiffre",
  "hint": "Donnée vue : vingt voix, douze lanternes, un créneau d'aube."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "L'enquête a été ouverte à Rukiri-Nord, et vingt voix ont été entendus trop vite.",
  "correct_sentence": "L'enquête a été ouverte à Rukiri-Nord, et vingt voix ont été entendues trop vite.",
  "explanation": "Voix féminin pluriel → entendues."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/groupe-citoyens.svg",
      "word": "des citoyens"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/affiche-societe.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/radio-soir.svg",
      "word": "la radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/nuage-doute.svg",
      "word": "un doute"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez douze phrases d'enquête : trois par enjeu, en mêlant passif et subjonctif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis votre restitution en quatre points."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon rapport d''enquête',
    'PE',
    $c$Objectif
Écrire un rapport argumenté qui relie les quatre enjeux sans les fondre.

Consigne
Imitez le rapport de Lila Sow, sans aller trop vite.

Support — Rapport de Lila, Radio Figuier
Lila Sow — enquête à Rukiri-Nord, pour le Cahier des racines
L'enquête a été ouverte sous le figuier.
Vingt voix ont été entendues.
Rien n'a été inventé au Marché des Lampions.
Eau. Il a été décidé un créneau d'aube.
Je veux que cette mesure soit expliquée à ceux du minibus, plutôt qu'elle reste un tampon muet.
Que ce soit six heures ou huit heures, l'heure doit être lue.
Heures calmes. Rose exige que le dernier morceau cesse.
Sami doute que le silence soit une fête.
Bien que la veillée soit précieuse, une fin d'heure a été demandée.
Personne n'a souhaité que le rite disparaisse.
Lanternes. Douze restes ont été vus. Une motion a été portée par Rose, relue par Marc, tamponnée par Solange.
Le rite rassemble ; la règle limite l'huile.
Salle. Plutôt que la clé circule sans trace, elle restera au Bureau.
Noura demande que ceux du pont soient inscrits, que la salle ouvre jeudi ou qu'elle ouvre dimanche.
Je crains que la fatigue n'efface la quatrième voix.
Que ce soit trop d'huile ou trop de silence, la cour perd.
Nuancer, ce n'est pas tout égaliser.
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila dit que l'enquête a inventé des voix au marché.",
  "correct": false,
  "explanation": "« Rien n'a été inventé au Marché des Lampions. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que craint Lila à la fin du rapport ?",
  "options": [
    {
      "text": "Que Solange perde le tampon",
      "correct": false
    },
    {
      "text": "Que la fatigue n'efface la quatrième voix",
      "correct": true
    },
    {
      "text": "Que la rivière disparaisse",
      "correct": false
    },
    {
      "text": "Que Radio Figuier change de nom",
      "correct": false
    }
  ],
  "explanation": "« Je crains que la fatigue n'efface la quatrième voix. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "créneau d'aube",
      "right": "eau"
    },
    {
      "left": "dernier morceau",
      "right": "heures calmes"
    },
    {
      "left": "douze restes",
      "right": "lanternes"
    },
    {
      "left": "clé au Bureau",
      "right": "salle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe crains que la fatigue n'___ la quatrième voix. (effacer)",
  "answer": "efface"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Rien",
    "n'a",
    "été",
    "inventé",
    "au",
    "marché",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "rapport",
  "hint": "Texte d'enquête : faits, avis, nuances, sans slogan d'antenne."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "L'enquête a été ouverte sous le figuier, et je veux que la mesure est expliquée au minibus.",
  "correct_sentence": "L'enquête a été ouverte sous le figuier, et je veux que la mesure soit expliquée au minibus.",
  "explanation": "Vouloir que + subjonctif : soit, pas est."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/affiche-societe.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/radio-soir.svg",
      "word": "la radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/nuage-doute.svg",
      "word": "un doute"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/soleil-position.svg",
      "word": "une prise de position"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : seize lignes, quatre enjeux, passifs, subjonctifs d'avis, une alternative, pas de slogan."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre rapport, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Relier passif, avis et alternative',
    'EL',
    $c$Objectif
Retenir comment une enquête de cour combine les outils des séquences 1 à 4.

Consigne
Apprenez la fiche.

Support — Fiche de synthèse d'enquête
Fait (S1) : passif pour mettre en valeur l'élément.
L'enquête a été ouverte. Vingt voix ont été entendues. Une motion a été tamponnée.
Avis (S2) : subjonctif de volonté, doute, sentiment, but, concession.
Je veux que… / je doute que… / je crains que… / afin que… / bien que…
Fait de cour (S3) : séparer rite et règle. Personne n'a demandé que la veillée disparaisse.
Nuance (S4) : que ce soit A ou B ; plutôt que + subjonctif.
Que ce soit l'eau ou la salle, la mesure reste distincte.
Plutôt que la clé circule, elle reste au Bureau.
On ne fond pas les quatre enjeux. On ne crie pas un parti. On ne copie pas une méthode d'ailleurs.
Accords : voix entendues ; restes vus ; mesure portée ; enquête ouverte.
Il faut (pas je faut). À + le = au Bureau, au figuier.
Ne explétif : je crains que la fatigue n'efface.
Éditorial demain : on argumentera ; aujourd'hui on relie les outils.
Une enquête tient si le chiffre et le que restent visibles tous les deux.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La fiche autorise à fondre eau, soir, lanternes et salle en un seul cri.",
  "correct": false,
  "explanation": "On ne fond pas les quatre enjeux."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel outil sert surtout à mettre un élément en valeur dans le fait ?",
  "options": [
    {
      "text": "le tout ou rien",
      "correct": false
    },
    {
      "text": "la voix passive",
      "correct": true
    },
    {
      "text": "un slogan d'antenne",
      "correct": false
    },
    {
      "text": "un sceau d'État",
      "correct": false
    }
  ],
  "explanation": "Passif = projecteur (S1)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "passif",
      "right": "fait mis en sujet"
    },
    {
      "left": "subjonctif",
      "right": "avis"
    },
    {
      "left": "que ce soit / plutôt que",
      "right": "nuance"
    },
    {
      "left": "rite / règle",
      "right": "fait de cour"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPlutôt que la clé ___, elle reste au Bureau. (circuler)",
  "answer": "circule"
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
    "ne",
    "fond",
    "pas",
    "les",
    "quatre",
    "enjeux",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "outils",
  "hint": "Passif, subjonctif, alternative : ce que l'enquête relie."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Vingt voix ont été entendues sous le figuier, et je doute que le silence est une fête.",
  "correct_sentence": "Vingt voix ont été entendues sous le figuier, et je doute que le silence soit une fête.",
  "explanation": "Douter que + subjonctif : soit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/radio-soir.svg",
      "word": "la radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/nuage-doute.svg",
      "word": "un doute"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/soleil-position.svg",
      "word": "une prise de position"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/main-vote.svg",
      "word": "un vote"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau à quatre colonnes (eau, soir, lanternes, salle) : un passif, un que, une alternative."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et une mini-enquête de huit phrases."
}$j$::jsonb,
    9
  );

  -- ===== Éditorial pour le Cahier des racines =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Éditorial pour le Cahier des racines'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Éditorial pour le Cahier des racines', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Préparer l''éditorial',
    'CO',
    $c$Objectif
Comprendre comment un éditorial de cour argumente sans crier, à partir de l'enquête.

Consigne
Lisez le dialogue. Quelles qualités d'un éditorial entend-on, et quels écueils ?

Support — Atelier du Cahier des racines, plume de Marc
Marc : Un éditorial n'est pas un cri. Il prend position, il s'appuie sur ce qui a été entendu, il nuance.
Aline : On veut que le lecteur tienne jusqu'au bout. On doute qu'un slogan suffise. On est heureux que l'enquête existe.
Lila : Que ce soit l'eau ou la salle, chaque paragraphe aura sa mesure. Plutôt que l'on mélange tout, on numérotera les enjeux.
Rose : Je souhaite que l'on nomme les agents : portée par, contestée par. Le passif sans par devient parfois un brouillard.
Solange : Il faut que le tampon reste à sa place : une mémoire, pas une preuve d'infaillibilité.
Patrick : Bien que nous soyons las, nous écrirons sans injure. Un éditorial qui insulte n'est plus un éditorial.
Léa : Afin que Noura se reconnaisse, on dira le minibus. Afin que Sami se reconnaisse, on dira la veillée.
Joël : Je crains que l'on n'oublie le chiffre : vingt voix, douze lanternes, un créneau.
Hawa : Plutôt que la conclusion soit un tout ou rien, qu'elle ouvre une assemblée.
Karim : Le Cahier des racines n'est pas une tribune d'État. C'est un cahier de cour, relié, ocre.
Yvette : On relatera ce qui a été vu. On argumentera ce que l'on veut. On séparera les deux.
Mado : Titre possible : « Ce qui a été décidé n'efface pas ce qui a été oublié. »
Dieudonné : Si l'eau est mise en sujet, que la soif le soit aussi.
Aline : Forme : thèse, faits au passif, avis au subjonctif, alternative, ouverture. Pas de parti réel.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc dit qu'un éditorial peut se contenter d'un cri.",
  "correct": false,
  "explanation": "« Un éditorial n'est pas un cri. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel titre Mado propose-t-elle ?",
  "options": [
    {
      "text": "Fermez la cour",
      "correct": false
    },
    {
      "text": "Ce qui a été décidé n'efface pas ce qui a été oublié",
      "correct": true
    },
    {
      "text": "Vive un parti d'ailleurs",
      "correct": false
    },
    {
      "text": "Silence total dès midi",
      "correct": false
    }
  ],
  "explanation": "Mado cite le titre ocre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "thèse + faits + avis",
      "right": "forme de l'éditorial"
    },
    {
      "left": "portée par / contestée par",
      "right": "nommer l'agent"
    },
    {
      "left": "que ce soit l'eau ou la salle",
      "right": "paragraphes distincts"
    },
    {
      "left": "Cahier des racines",
      "right": "cahier de cour"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn veut que le lecteur ___ jusqu'au bout. (tenir)",
  "answer": "tienne"
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
    "éditorial",
    "n'est",
    "pas",
    "un",
    "cri",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "editorial",
  "hint": "Texte d'avis argumenté pour le Cahier des racines, sans accent."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On veut que le lecteur tient jusqu'au bout, et on doute qu'un slogan suffise à la cour.",
  "correct_sentence": "On veut que le lecteur tienne jusqu'au bout, et on doute qu'un slogan suffise à la cour.",
  "explanation": "Vouloir que + subjonctif : tienne, pas tient."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/nuage-doute.svg",
      "word": "un doute"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/soleil-position.svg",
      "word": "une prise de position"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/main-vote.svg",
      "word": "un vote"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/feuille-edito.svg",
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
  "prompt": "Notez la forme de l'éditorial (cinq étapes) et deux écueils à éviter."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Un éditorial n'est pas un cri. Que ce soit l'eau ou la salle, chaque paragraphe aura sa mesure."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Éditorial-modèle du Cahier',
    'CE',
    $c$Objectif
Lire un éditorial argumentatif qui réemploie passif, subjonctif et alternatives.

Consigne
Lisez l'éditorial, sans aller trop vite.

Support — Cahier des racines, une du jeudi
Ce qui a été décidé n'efface pas ce qui a été oublié
L'enquête a été ouverte à Rukiri-Nord.
Vingt voix ont été entendues.
Nous voulons que ces voix restent visibles, plutôt qu'elles fondent dans un slogan.
Que ce soit l'eau, les heures calmes, les lanternes ou la salle, chaque enjeu a été nommé.
Il a été décidé un créneau d'aube : la mesure est portée par ceux qui marchent, et elle est contestée par ceux du minibus.
Nous demandons que l'heure soit expliquée, afin que Noura n'arrive plus devant un tampon muet.
Bien que la veillée soit précieuse, une fin d'heure a été demandée.
Nous doutons que Sami perde sa place si le tambour cesse plus tôt.
Personne n'a exigé que le rite disparaisse : on a limité l'huile, on n'a pas tué la flamme.
Douze restes ont été vus ; une motion a été tamponnée.
Plutôt que la clé de la Salle des Herbes circule sans trace, qu'elle reste au Bureau.
Plutôt que l'accès soit un secret d'anciens, que ceux du pont soient inscrits, que la salle ouvre jeudi ou qu'elle ouvre dimanche.
Nous craignons que la fatigue n'efface la quatrième voix.
Que ce soit trop d'huile ou trop de silence, la cour perd.
Nuancer, ce n'est pas tout égaliser ; c'est refuser le tout ou rien.
Le Cahier des racines n'est pas une tribune d'État. C'est une mémoire de cour.
Nous souhaitons que l'assemblée se tienne, pour que ce qui a été oublié soit enfin dit.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'éditorial affirme que le Cahier des racines est une tribune d'État.",
  "correct": false,
  "explanation": "« n'est pas une tribune d'État. C'est une mémoire de cour. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que demandent les rédacteurs pour l'eau ?",
  "options": [
    {
      "text": "Supprimer les seaux",
      "correct": false
    },
    {
      "text": "Que l'heure soit expliquée afin que Noura ne trouve plus un tampon muet",
      "correct": true
    },
    {
      "text": "Interdire Hawa",
      "correct": false
    },
    {
      "text": "Fermer la rivière",
      "correct": false
    }
  ],
  "explanation": "Expliquer l'heure, pas seulement tamponner."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "vingt voix ont été entendues",
      "right": "fait"
    },
    {
      "left": "nous voulons que / nous doutons que",
      "right": "avis"
    },
    {
      "left": "plutôt que la clé circule",
      "right": "salle"
    },
    {
      "left": "mémoire de cour",
      "right": "Cahier des racines"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous doutons que Sami ___ sa place. (perdre)",
  "answer": "perde"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Nuancer",
    "ce",
    "n'est",
    "pas",
    "tout",
    "égaliser",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "memoire",
  "hint": "Rôle du Cahier des racines, sans accent : garder les voix, pas crier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "L'enquête a été ouverte à Rukiri-Nord, et nous voulons que ces voix reste visibles.",
  "correct_sentence": "L'enquête a été ouverte à Rukiri-Nord, et nous voulons que ces voix restent visibles.",
  "explanation": "Voix au pluriel : restent."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/soleil-position.svg",
      "word": "une prise de position"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/main-vote.svg",
      "word": "un vote"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/feuille-edito.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/oreille-nuance.svg",
      "word": "une nuance"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez l'éditorial et soulignez passifs, subjonctifs et alternatives."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'éditorial-modèle, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire la thèse et l''ouverture',
    'PO',
    $c$Objectif
Prononcer thèse, arguments et ouverture d'un éditorial de cour.

Consigne
Répétez, puis formulez à l'oral votre thèse sur un des quatre enjeux.

Support — Modèles de Marc et d'Aline
Un éditorial n'est pas un cri.
Ce qui a été décidé n'efface pas ce qui a été oublié.
Nous voulons que les voix restent visibles.
Que ce soit l'eau ou la salle, chaque paragraphe a sa mesure.
Il a été entendu vingt voix.
Nous doutons qu'un slogan suffise.
Bien que nous soyons las, nous écrirons sans injure.
Afin que Noura se reconnaisse, nous dirons le minibus.
Plutôt que la conclusion soit un tout ou rien, qu'elle ouvre une assemblée.
Le Cahier des racines est une mémoire de cour.
Nous souhaitons que l'assemblée se tienne.
Aline : thèse d'abord, chiffre ensuite, que ensuite, ouverture enfin.
Léa : le ton reste calme ; le mode, lui, travaille.
Rose : nommer l'agent après par, pour que le passif ne devienne pas un brouillard.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'ouverture proposée est une assemblée, non un tout ou rien.",
  "correct": true,
  "explanation": "Plutôt que la conclusion soit un tout ou rien, qu'elle ouvre une assemblée."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase pose la thèse reprise au titre ?",
  "options": [
    {
      "text": "Fermez le figuier",
      "correct": false
    },
    {
      "text": "Ce qui a été décidé n'efface pas ce qui a été oublié",
      "correct": true
    },
    {
      "text": "Il n'y a plus d'eau nulle part ailleurs",
      "correct": false
    },
    {
      "text": "Sami doit partir",
      "correct": false
    }
  ],
  "explanation": "Thèse = titre de Mado, repris ici."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "thèse",
      "right": "décidé / oublié"
    },
    {
      "left": "fait",
      "right": "vingt voix"
    },
    {
      "left": "avis",
      "right": "nous voulons que"
    },
    {
      "left": "ouverture",
      "right": "assemblée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nBien que nous ___ las, nous écrirons sans injure. (être)",
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
    "Le",
    "Cahier",
    "des",
    "racines",
    "est",
    "une",
    "mémoire",
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
  "word": "these",
  "hint": "Phrase d'ouverture de l'éditorial, sans accent : ce que l'on soutient."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous voulons que les voix restent visibles, et nous doutons qu'un slogan suffit à tenir la cour.",
  "correct_sentence": "Nous voulons que les voix restent visibles, et nous doutons qu'un slogan suffise à tenir la cour.",
  "explanation": "Douter que + subjonctif : suffise."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/main-vote.svg",
      "word": "un vote"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/feuille-edito.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/oreille-nuance.svg",
      "word": "une nuance"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/voix-passive.svg",
      "word": "la voix passive"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez une thèse, trois arguments (un passif, un que, une alternative) et une ouverture."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis votre thèse."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon éditorial',
    'PE',
    $c$Objectif
Écrire un éditorial argumentatif pour le Cahier des racines.

Consigne
Imitez l'éditorial de Marc Nkurunziza, sans aller trop vite.

Support — Éditorial de Marc, encre ocre
Marc Nkurunziza — Cahier des racines, Seuil des Sources
Ce qui a été décidé n'efface pas ce qui a été oublié.
Voilà ma thèse, et je la tiens.
L'enquête a été ouverte. Vingt voix ont été entendues.
Je veux que ces voix restent dans le cahier, plutôt qu'elles se perdent dans un cri.
Que ce soit l'eau ou la salle, je refuse de tout fondre.
Il a été décidé un créneau : la mesure est portée par Hawa, contestée par Noura.
Je demande que l'heure soit dite à Radio Figuier, afin que le minibus ne se heurte plus à un tampon muet.
Bien que la veillée soit précieuse, je souhaite que le dernier morceau cesse.
Je doute que Sami disparaisse pour si peu.
Douze lanternes ont été vues au bord de l'eau ; une motion a été tamponnée.
On a limité un geste ; on n'a pas tué un rite.
Plutôt que la clé circule sans trace, qu'elle reste chez Solange.
Plutôt que l'accès soit un secret, que ceux du pont soient inscrits.
Je crains que la fatigue n'efface la quatrième voix.
Que ce soit trop d'huile ou trop de silence, la cour perd.
Nuancer n'est pas tout égaliser.
Je souhaite que l'assemblée se tienne sous le figuier, pour que ce qui a été oublié soit enfin nommé.
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc veut fondre eau et salle en un seul paragraphe de colère.",
  "correct": false,
  "explanation": "« je refuse de tout fondre. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle ouverture Marc souhaite-t-il ?",
  "options": [
    {
      "text": "Fermer le Cahier",
      "correct": false
    },
    {
      "text": "Que l'assemblée se tienne sous le figuier",
      "correct": true
    },
    {
      "text": "Interdire Noura",
      "correct": false
    },
    {
      "text": "Vendre Radio Figuier",
      "correct": false
    }
  ],
  "explanation": "« Je souhaite que l'assemblée se tienne sous le figuier. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "thèse",
      "right": "décidé / oublié"
    },
    {
      "left": "créneau / tampon muet",
      "right": "eau"
    },
    {
      "left": "motion / rite",
      "right": "lanternes"
    },
    {
      "left": "clé chez Solange",
      "right": "salle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe souhaite que l'assemblée se ___ sous le figuier. (tenir)",
  "answer": "tienne"
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
    "refuse",
    "de",
    "tout",
    "fondre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "argument",
  "hint": "Ce qui porte l'éditorial : un fait, un que, une nuance, une ouverture."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je veux que ces voix restent dans le cahier, et je doute que Sami disparaît pour si peu.",
  "correct_sentence": "Je veux que ces voix restent dans le cahier, et je doute que Sami disparaisse pour si peu.",
  "explanation": "Douter que + subjonctif : disparaisse."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/feuille-edito.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/oreille-nuance.svg",
      "word": "une nuance"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/voix-passive.svg",
      "word": "la voix passive"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/enjeu-societe.svg",
      "word": "un enjeu"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : seize à dix-huit lignes, thèse, quatre enjeux, passifs, subjonctifs, alternatives, ouverture d'assemblée."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre éditorial, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — L''éditorial de cour : outils et forme',
    'EL',
    $c$Objectif
Retenir la forme de l'éditorial et le réemploi des outils B2 de l'avis.

Consigne
Apprenez la fiche.

Support — Fiche de Lila, éditorial
Forme : titre-thèse ; faits (passif) ; avis (subjonctif) ; nuance (alternative) ; ouverture.
Thèse type : ce qui a été décidé n'efface pas ce qui a été oublié.
Faits : l'enquête a été ouverte ; vingt voix ont été entendues ; une motion a été tamponnée.
Avis : nous voulons que / nous doutons que / nous craignons que / afin que / bien que.
Nuance : que ce soit A ou B ; plutôt que + subj. Nuancer ≠ tout égaliser.
Ouverture : nous souhaitons que l'assemblée se tienne. Pas de tout ou rien.
Écueils : cri ; slogan ; parti réel ; sceau d'État prêté au tampon ; tout fondre.
Le Cahier des racines = mémoire de cour, pas tribune d'ailleurs.
Accords passif : voix entendues, restes vus, mesure portée, clé gardée.
Subj. utiles : tienne, soit, circule, disparaisse, soyons, perde, ouvre.
Il faut que le tampon reste une mémoire. (pas je faut)
À + le = au Cahier, au figuier, au Bureau.
Un éditorial tient si le lecteur entend encore les vingt voix à la dernière ligne.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La fiche présente le tampon du Bureau comme une preuve d'infaillibilité.",
  "correct": false,
  "explanation": "Écueil : sceau d'État prêté au tampon. Le tampon est une mémoire."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel est l'ordre proposé pour l'éditorial ?",
  "options": [
    {
      "text": "cri, injure, slogan, silence",
      "correct": false
    },
    {
      "text": "thèse, faits, avis, nuance, ouverture",
      "correct": true
    },
    {
      "text": "ouverture, puis rien",
      "correct": false
    },
    {
      "text": "faits seulement, sans avis",
      "correct": false
    }
  ],
  "explanation": "Thèse → faits → avis → nuance → ouverture."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "passif",
      "right": "faits"
    },
    {
      "left": "subjonctif",
      "right": "avis"
    },
    {
      "left": "que ce soit / plutôt que",
      "right": "nuance"
    },
    {
      "left": "assemblée",
      "right": "ouverture"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous souhaitons que l'assemblée se ___ . (tenir)",
  "answer": "tienne"
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
    "éditorial",
    "n'est",
    "pas",
    "un",
    "cri",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ouverture",
  "hint": "Fin de l'éditorial : convoquer l'assemblée, pas fermer tout."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous voulons que ces voix restent visibles, et nous doutons qu'un slogan suffit demain.",
  "correct_sentence": "Nous voulons que ces voix restent visibles, et nous doutons qu'un slogan suffise demain.",
  "explanation": "Douter que + subjonctif : suffise."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m5/oreille-nuance.svg",
      "word": "une nuance"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/voix-passive.svg",
      "word": "la voix passive"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/enjeu-societe.svg",
      "word": "un enjeu"
    },
    {
      "image_path": "/elearning/mfk-b2-m5/banderole-rive.svg",
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
  "prompt": "Rédigez un plan d'éditorial en cinq cases, avec une phrase modèle dans chacune."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et une mini-thèse de cinq phrases."
}$j$::jsonb,
    9
  );

END;
$$;
