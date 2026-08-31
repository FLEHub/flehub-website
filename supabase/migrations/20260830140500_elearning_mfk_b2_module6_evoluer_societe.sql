/*
  Seed eLearning MFK — B2 — Faire évoluer la société

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b2-m6/
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
  v_module_title text := 'B2 — Faire évoluer la société';
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
      'Grande étape B2-6 : dresser un bilan sous condition, formuler une prise de conscience et des recommandations, engager une action citoyenne avec les indéfinis, dénoncer et proposer par des locutions, siéger à l''assemblée sous le figuier et déposer une motion formelle au Bureau des Escales — pour que l''eau, les heures calmes, les lanternes et la Salle des Herbes évoluent au Seuil des Sources (Rukiri-Nord).',
      'B2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B2-6 : dresser un bilan sous condition, formuler une prise de conscience et des recommandations, engager une action citoyenne avec les indéfinis, dénoncer et proposer par des locutions, siéger à l''assemblée sous le figuier et déposer une motion formelle au Bureau des Escales — pour que l''eau, les heures calmes, les lanternes et la Salle des Herbes évoluent au Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'B2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Dresser un bilan =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Dresser un bilan'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Dresser un bilan', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Si l''eau revient, à condition que…',
    'CO',
    $c$Objectif
Repérer les conditions d'un bilan : si, à condition que + subj., pourvu que, à moins que, en cas de.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). À quelles conditions le bilan de la cour tient-il ?

Support — Table des Sources, graphique ocre
Aline : Dressons le bilan. Si l'eau a été ménagée à l'aube, le soir reste à expliquer.
Dieudonné : Le chiffre tient, à condition que les seaux manquants soient retrouvés.
Hawa : Pourvu que Noura trouve encore de l'eau après le minibus, le créneau pourra s'élargir d'une demi-heure.
Rose : À moins que la rivière ne baisse encore, nous n'ouvrirons pas un second créneau cette semaine.
Solange : En cas de pénurie, le Bureau tamponnera une file, pas une rumeur.
Marc : Si nous avions écouté Noura plus tôt, le bilan serait moins boiteux d'un côté.
Léa : Le soir tient, à condition que le tambour cesse à l'heure dite.
Sami : Pourvu que la veillée reste une fête, j'accepte de frapper plus court.
Patrick : À moins que Solange ne refuse le tampon, la motion des lanternes reste valable.
Karim : En cas de clé perdue, on n'ouvre pas la Salle des Herbes avec une pierre.
Lila : Si l'enquête a été entendue, le bilan doit la citer, pas la fondre.
Joël : À condition que chacun signe, le graphique des seaux pourra être affiché au figuier.
Yvette : Pourvu que la fatigue ne décide pas à notre place, nous finirons ce bilan.
Mado : En cas de désaccord, on reconvoque l'assemblée, on n'invente pas un chef.
Aline : Cinq outils : si + indicatif ou imparfait ; à condition que / pourvu que / à moins que + subj. ; en cas de + nom.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose n'ouvrira un second créneau que si la rivière ne baisse pas.",
  "correct": true,
  "explanation": "« À moins que la rivière ne baisse encore, nous n'ouvrirons pas un second créneau. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que tamponnera Solange en cas de pénurie ?",
  "options": [
    {
      "text": "Une rumeur du marché",
      "correct": false
    },
    {
      "text": "Une file",
      "correct": true
    },
    {
      "text": "Un sceau d'État",
      "correct": false
    },
    {
      "text": "Un interdiction du figuier",
      "correct": false
    }
  ],
  "explanation": "« le Bureau tamponnera une file, pas une rumeur. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si l'eau a été ménagée",
      "right": "le soir reste à expliquer"
    },
    {
      "left": "à condition que",
      "right": "seaux retrouvés / tambour / signatures"
    },
    {
      "left": "pourvu que",
      "right": "Noura / veillée / fatigue"
    },
    {
      "left": "à moins que / en cas de",
      "right": "rivière / tampon / pénurie / clé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe chiffre tient, à condition que les seaux manquants ___ retrouvés. (être)",
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
    "En",
    "cas",
    "de",
    "pénurie",
    "le",
    "Bureau",
    "tamponnera",
    "une",
    "file",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pourvu",
  "hint": "Lien de condition optimiste : … que la veillée reste une fête."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le chiffre tient à condition que les seaux sont retrouvés, et le graphique pourra être affiché.",
  "correct_sentence": "Le chiffre tient à condition que les seaux soient retrouvés, et le graphique pourra être affiché.",
  "explanation": "À condition que + subjonctif : soient, pas sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/bilan-condition.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/si-imparfait.svg",
      "word": "une condition"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/assemblee-figuier.svg",
      "word": "une assemblée"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/graphique-bilan.svg",
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
  "prompt": "Notez cinq conditions du bilan, une par outil (si, à condition que, pourvu que, à moins que, en cas de)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Si l'eau a été ménagée, le soir reste à expliquer. À condition que les seaux soient retrouvés. En cas de pénurie, on tamponne une file."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Bilan conditionnel de la cour',
    'CE',
    $c$Objectif
Lire un bilan qui articule si, à condition que, pourvu que, à moins que et en cas de.

Consigne
Lisez le bilan, sans aller trop vite.

Support — Bilan de Marc Nkurunziza, Cahier des racines
Bilan — ce qui tient, à quelles conditions (Seuil des Sources)
Eau. Si le créneau d'aube a été respecté quatre matins sur sept, le niveau a tenu.
Le bilan reste juste, à condition que les trois seaux manquants soient nommés, non cachés.
Pourvu que Noura trouve encore de quoi remplir après le Figuier 7, Hawa accepte d'ouvrir une demi-heure de plus.
À moins que la rivière ne baisse, nous n'inventerons pas un second créneau cette semaine.
En cas de pénurie, Solange tamponnera une file au Bureau des Escales.
Si nous avions écouté le pont plus tôt, cette file serait déjà écrite.
Heures calmes. Le soir s'améliore, à condition que le dernier morceau cesse.
Pourvu que la veillée reste une fête, Sami frappe plus court.
À moins que la fatigue ne gagne, l'assemblée pourra revoir l'heure.
Lanternes. Douze restes ont été vus. Si le panier ocre est utilisé, l'huile n'atteint plus l'eau.
En cas de récidive, la motion n°14 sera relue, non criée.
Salle. La clé tient, à condition qu'elle rentre au tiroir.
Pourvu que ceux du minibus soient inscrits, l'accès cessera d'être un secret.
En cas de clé perdue, on n'ouvre pas avec une pierre.
Aline : un bilan sans condition est un vœu. Un bilan avec cinq outils est une carte.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa refuse toute demi-heure de plus, même si Noura trouve de l'eau.",
  "correct": false,
  "explanation": "Pourvu que Noura trouve encore de quoi remplir, Hawa accepte d'ouvrir une demi-heure de plus."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fera-t-on en cas de clé perdue ?",
  "options": [
    {
      "text": "Ouvrir avec une pierre",
      "correct": false
    },
    {
      "text": "Ne pas ouvrir avec une pierre",
      "correct": true
    },
    {
      "text": "Vendre la salle",
      "correct": false
    },
    {
      "text": "Couper Radio Figuier",
      "correct": false
    }
  ],
  "explanation": "« on n'ouvre pas avec une pierre. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si le créneau a été respecté",
      "right": "le niveau a tenu"
    },
    {
      "left": "à condition que",
      "right": "seaux nommés / tambour / clé"
    },
    {
      "left": "pourvu que",
      "right": "Noura / veillée / minibus"
    },
    {
      "left": "en cas de",
      "right": "pénurie / récidive / clé perdue"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nÀ moins que la rivière ne ___, nous n'ouvrirons pas un second créneau. (baisser)",
  "answer": "baisse"
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
    "sans",
    "condition",
    "est",
    "un",
    "vœu",
    "."
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
  "hint": "Texte qui dit ce qui tient, et à quelles conditions cela tient."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le soir s'améliore à condition que le dernier morceau cesse, et pourvu que la veillée restera une fête.",
  "correct_sentence": "Le soir s'améliore à condition que le dernier morceau cesse, et pourvu que la veillée reste une fête.",
  "explanation": "Pourvu que + subjonctif : reste, pas le futur restera."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/si-imparfait.svg",
      "word": "une condition"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/assemblee-figuier.svg",
      "word": "une assemblée"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/graphique-bilan.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/conditionnel-conseil.svg",
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
  "prompt": "Recopiez le bilan et encadrez si / à condition que / pourvu que / à moins que / en cas de."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le bilan de Marc, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire les conditions du bilan',
    'PO',
    $c$Objectif
Formuler à l'oral un bilan sous condition, en variant les cinq outils.

Consigne
Répétez, puis dressez le bilan d'un enjeu avec au moins trois conditions.

Support — Modèles d'Aline et de Dieudonné
Si l'eau a été ménagée, le soir reste à expliquer.
Le chiffre tient, à condition que les seaux soient nommés.
Pourvu que Noura trouve encore de l'eau, on ouvrira une demi-heure.
À moins que la rivière ne baisse, pas de second créneau.
En cas de pénurie, on tamponne une file.
Si nous avions écouté plus tôt, le bilan serait moins boiteux.
Le soir tient, à condition que le tambour cesse.
Pourvu que la veillée reste une fête, Sami frappe plus court.
À moins que Solange ne refuse, la motion reste valable.
En cas de clé perdue, on n'ouvre pas avec une pierre.
Si chacun signe, le graphique ira au figuier.
Aline : à condition que et pourvu que + subjonctif. En cas de + nom.
Marc : si + imparfait ouvre une hypothèse ; si + présent ouvre un réel possible.
Rose : à moins que prend souvent un ne explétif.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« En cas de » est suivi d'un nom, non d'un subjonctif.",
  "correct": true,
  "explanation": "En cas de pénurie / de clé perdue / de récidive."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase emploie correctement à moins que ?",
  "options": [
    {
      "text": "À moins que la rivière baisse pas",
      "correct": false
    },
    {
      "text": "À moins que la rivière ne baisse",
      "correct": true
    },
    {
      "text": "À moins que la rivière baissera",
      "correct": false
    },
    {
      "text": "À moins de que la rivière est",
      "correct": false
    }
  ],
  "explanation": "À moins que + ne explétif + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si + présent / PC",
      "right": "réel possible"
    },
    {
      "left": "si + imparfait",
      "right": "hypothèse"
    },
    {
      "left": "à condition que / pourvu que",
      "right": "subjonctif"
    },
    {
      "left": "en cas de",
      "right": "nom"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPourvu que la veillée ___ une fête, Sami frappe plus court. (rester)",
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
    "En",
    "cas",
    "de",
    "clé",
    "perdue",
    "on",
    "n'ouvre",
    "pas",
    "avec",
    "une",
    "pierre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "condition",
  "hint": "Lien sans lequel le bilan n'est qu'un vœu : si, pourvu que, en cas de."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "À moins que la rivière baisse encore, le Bureau tamponnera une file en cas de pénurie.",
  "correct_sentence": "À moins que la rivière ne baisse encore, le Bureau tamponnera une file en cas de pénurie.",
  "explanation": "À moins que + ne explétif + subjonctif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/assemblee-figuier.svg",
      "word": "une assemblée"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/graphique-bilan.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/conditionnel-conseil.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/regret-passe.svg",
      "word": "un regret"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez dix phrases de bilan : deux par outil de condition."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis un bilan à vous en trois conditions."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon bilan sous condition',
    'PE',
    $c$Objectif
Écrire un bilan argumenté qui pose ce qui tient et à quelles conditions.

Consigne
Imitez le bilan de Hawa Diallo, sans aller trop vite.

Support — Bilan de Hawa, Cahier des racines
Hawa Diallo — bilan de l'eau, et des autres voix
Si le créneau d'aube a été respecté, la rivière a tenu.
Je le dis sans triomphe : le bilan reste juste, à condition que les trois seaux manquants soient nommés.
Pourvu que Noura trouve encore de quoi remplir après le minibus, j'accepte d'ouvrir une demi-heure.
À moins que la rivière ne baisse, je n'inventerai pas un second créneau cette semaine.
En cas de pénurie, que Solange tamponne une file, non une rumeur.
Si nous avions écouté le pont plus tôt, cette file serait déjà sur l'affiche.
Le soir n'est pas mon enjeu premier, mais le bilan de la cour le contient.
Il tient, à condition que le tambour cesse à l'heure.
Pourvu que la veillée reste une fête, Sami peut frapper plus court.
Les lanternes : si le panier ocre est utilisé, l'huile n'atteint plus l'eau.
En cas de récidive, la motion sera relue.
La salle : la clé tient, à condition qu'elle rentre.
Pourvu que ceux du minibus soient inscrits, l'accès cessera d'être un secret.
Un bilan sans condition est un vœu.
Le mien en a cinq, et je les tiens.
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa invente un second créneau dès cette semaine, quoi qu'il arrive à la rivière.",
  "correct": false,
  "explanation": "À moins que la rivière ne baisse, elle n'inventera pas un second créneau."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que demande Hawa en cas de pénurie ?",
  "options": [
    {
      "text": "Une rumeur au marché",
      "correct": false
    },
    {
      "text": "Une file tamponnée par Solange",
      "correct": true
    },
    {
      "text": "La fermeture du figuier",
      "correct": false
    },
    {
      "text": "Un sceau d'État",
      "correct": false
    }
  ],
  "explanation": "« que Solange tamponne une file, non une rumeur. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si le créneau a été respecté",
      "right": "la rivière a tenu"
    },
    {
      "left": "à condition que",
      "right": "seaux / tambour / clé"
    },
    {
      "left": "pourvu que",
      "right": "Noura / veillée / minibus"
    },
    {
      "left": "en cas de",
      "right": "pénurie / récidive"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi nous avions écouté plus tôt, cette file ___ déjà sur l'affiche. (être, cond.)",
  "answer": "serait"
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
    "sans",
    "condition",
    "est",
    "un",
    "vœu",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "penurie",
  "hint": "Manque d'eau : en cas de… on tamponne une file. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le bilan reste juste à condition que les seaux sont nommés, et pourvu que Noura trouve encore de l'eau.",
  "correct_sentence": "Le bilan reste juste à condition que les seaux soient nommés, et pourvu que Noura trouve encore de l'eau.",
  "explanation": "À condition que + subjonctif : soient, pas sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/graphique-bilan.svg",
      "word": "un graphique"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/conditionnel-conseil.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/regret-passe.svg",
      "word": "un regret"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/recommandation.svg",
      "word": "une recommandation"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : quinze lignes de bilan, les cinq outils de condition, deux enjeux au moins."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre bilan, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Condition : si, pourvu que, en cas de',
    'EL',
    $c$Objectif
Retenir les cinq outils de condition et le mode qui les suit.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, conditions du bilan
Si + présent / passé composé → futur ou présent (réel possible) :
Si l'eau a été ménagée, le soir reste à expliquer. Si chacun signe, le graphique ira au figuier.
Si + imparfait → conditionnel (hypothèse) : si nous avions écouté, le bilan serait moins boiteux.
Si + plus-que-parfait → conditionnel passé (regret d'hypothèse) : si nous avions parlé, nous aurions évité la file.
À condition que + subjonctif : le chiffre tient, à condition que les seaux soient nommés.
Pourvu que + subjonctif (condition + souhait) : pourvu que Noura trouve de l'eau.
À moins que + (ne explétif) + subjonctif : à moins que la rivière ne baisse.
En cas de + nom : en cas de pénurie, de clé perdue, de récidive, de désaccord.
On ne dit pas : à condition que les seaux sont… On ne dit pas : en cas que + phrase (on dit au cas où + cond., ou en cas de + nom).
Au cas où + conditionnel : au cas où la rivière baisserait, Solange ouvrirait une file.
Il faut (pas je faut). À + le = au Bureau, au figuier.
Un bilan sans condition est un vœu ; un bilan conditionné est une carte pour agir.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Pourvu que » se construit avec l'indicatif, comme « si ».",
  "correct": false,
  "explanation": "Pourvu que + subjonctif. Si + indicatif (ou imparfait)."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle suite est correcte après « en cas de » ?",
  "options": [
    {
      "text": "en cas de que l'eau baisse",
      "correct": false
    },
    {
      "text": "en cas de pénurie",
      "correct": true
    },
    {
      "text": "en cas de soient les seaux",
      "correct": false
    },
    {
      "text": "en cas de à moins que",
      "correct": false
    }
  ],
  "explanation": "En cas de + nom."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si + PC / présent",
      "right": "réel possible"
    },
    {
      "left": "si + imparfait",
      "right": "conditionnel"
    },
    {
      "left": "à condition que / pourvu que / à moins que",
      "right": "subjonctif"
    },
    {
      "left": "en cas de",
      "right": "nom"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nÀ condition que les seaux ___ nommés, le bilan reste juste. (être)",
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
    "Pourvu",
    "que",
    "Noura",
    "trouve",
    "de",
    "l'eau",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "hypothese",
  "hint": "Si + imparfait, puis le mode du possible. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le chiffre tient à condition que les seaux soient nommés, et en cas que pénurie on tamponne une file.",
  "correct_sentence": "Le chiffre tient à condition que les seaux soient nommés, et en cas de pénurie on tamponne une file.",
  "explanation": "En cas de + nom, pas en cas que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/conditionnel-conseil.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/regret-passe.svg",
      "word": "un regret"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/recommandation.svg",
      "word": "une recommandation"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/main-conscience.svg",
      "word": "une conscience"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau : cinq outils, le mode qui suit, deux exemples chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et cinq phrases, un outil chacune."
}$j$::jsonb,
    9
  );

  -- ===== Prise de conscience et recommandations =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Prise de conscience et recommandations'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Prise de conscience et recommandations', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — On pourrait, j''aurais dû',
    'CO',
    $c$Objectif
Repérer le conditionnel d'atténuation et le conditionnel passé de regret.

Consigne
Lisez le dialogue. Quelles recommandations s'entendent, et quels regrets ?

Support — Banc du figuier, après le bilan
Aline : On pourrait élargir le créneau d'une demi-heure, sans casser l'aube.
Hawa : Il faudrait que Noura soit prévenue la veille, pas au moment du seau vide.
Rose : Je suggérerais de baisser le micro plus tôt. Vous feriez mieux d'écrire l'heure, Lila.
Sami : J'aurais dû finir le morceau avant vingt et une heures. Je le dis sans théâtre.
Léa : Nous n'aurions pas dû laisser douze lanternes au bord de l'eau. Il aurait fallu le panier dès le premier jeudi.
Patrick : On devrait relire la motion avant de crier. Un conditionnel atténue ; il n'efface pas le fait.
Solange : J'aurais dû tamponner la file dès la première soif du pont. Voilà mon regret.
Dieudonné : Il vaudrait mieux compter les seaux à deux, plutôt que de les croire rangés.
Noura : Vous pourriez afficher l'heure à hauteur d'enfant. Ce n'est pas un ordre ; c'est une recommandation.
Marc : Nous aurions dû écouter le silence de Noura comme un fait, pas comme un aveu.
Joël : On pourrait convoquer l'assemblée sans attendre l'orage.
Yvette : Je recommanderais une pause entre le tambour et le micro. La cour respirerait.
Karim : Il aurait fallu que la clé rentre le soir même. J'aurais dû la réclamer.
Lila : Atténuer, c'est on pourrait / il faudrait / je suggérerais. Regretter, c'est j'aurais dû / nous n'aurions pas dû / il aurait fallu.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Sami formule un regret au conditionnel passé : j'aurais dû finir plus tôt.",
  "correct": true,
  "explanation": "Sami : « J'aurais dû finir le morceau avant vingt et une heures. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que suggérerait Rose à Lila ?",
  "options": [
    {
      "text": "Fermer Radio Figuier",
      "correct": false
    },
    {
      "text": "Écrire l'heure / baisser le micro plus tôt",
      "correct": true
    },
    {
      "text": "Interdire Hawa",
      "correct": false
    },
    {
      "text": "Cacher les seaux",
      "correct": false
    }
  ],
  "explanation": "Je suggérerais de baisser le micro ; vous feriez mieux d'écrire l'heure."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on pourrait / il faudrait",
      "right": "atténuation"
    },
    {
      "left": "je suggérerais / vous feriez mieux",
      "right": "recommandation polie"
    },
    {
      "left": "j'aurais dû",
      "right": "regret personnel"
    },
    {
      "left": "nous n'aurions pas dû / il aurait fallu",
      "right": "regret collectif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'___ dû finir le morceau avant vingt et une heures. (avoir, cond. passé)",
  "answer": "aurais"
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
    "élargir",
    "le",
    "créneau",
    "d'une",
    "demi-heure",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "regret",
  "hint": "Ce que Sami et Solange portent : j'aurais dû, trop tard pour l'aube."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'aurais du finir le morceau plus tôt, et on pourrait encore élargir le créneau.",
  "correct_sentence": "J'aurais dû finir le morceau plus tôt, et on pourrait encore élargir le créneau.",
  "explanation": "Dû (devoir) prend l'accent ; du est l'article."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/regret-passe.svg",
      "word": "un regret"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/recommandation.svg",
      "word": "une recommandation"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/main-conscience.svg",
      "word": "une conscience"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/action-citoyenne.svg",
      "word": "une action"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Classez six répliques : atténuation d'un côté, regret de l'autre."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On pourrait élargir le créneau. Il faudrait que Noura soit prévenue. J'aurais dû finir plus tôt."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Carnet de conscience',
    'CE',
    $c$Objectif
Lire des recommandations atténuées et des regrets au conditionnel passé.

Consigne
Lisez le carnet, sans aller trop vite.

Support — Carnet d'Aline Uwase, Salle des Herbes
Prise de conscience — recommandations et regrets (Seuil)
On pourrait élargir l'eau d'une demi-heure, à condition que l'aube tienne. Il faudrait que Noura soit prévenue la veille.
Je suggérerais d'afficher l'heure à hauteur d'enfant. Vous feriez mieux de ne pas coller l'affiche trop haut : cela a déjà été vu.
Sami écrit : j'aurais dû cesser plus tôt. Léa et Patrick : nous n'aurions pas dû laisser l'huile à la rivière. Il aurait fallu le panier dès le premier jeudi.
Solange : j'aurais dû tamponner la file dès la première soif du pont. Dieudonné : il vaudrait mieux compter les seaux à deux.
Marc : nous aurions dû entendre le silence de Noura comme un fait. Joël : on pourrait convoquer l'assemblée sans attendre l'orage.
Yvette recommanderait une pause entre le tambour et le micro. La cour respirerait, et Radio Figuier n'aurait pas à crier par-dessus.
Karim : il aurait fallu que la clé rentre le soir même. J'aurais dû la réclamer, plutôt que de croire le tiroir plein.
Atténuation : on pourrait, il faudrait, je suggérerais, vous feriez mieux, il vaudrait mieux, on devrait.
Regret : j'aurais dû + infinitif ; nous n'aurions pas dû ; il aurait fallu (que + subj.).
Une recommandation n'est pas un ordre. Un regret n'est pas une injure.
Pour que la cour évolue, il faut que le conditionnel reste un outil, pas un rideau.
Rukiri-Nord — conscience de cour, pas confession d'ailleurs.
Lila lira trois regrets et trois recommandations ce soir, sans théâtre.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le carnet présente la recommandation comme un ordre sec.",
  "correct": false,
  "explanation": "« Une recommandation n'est pas un ordre. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel regret Solange écrit-elle ?",
  "options": [
    {
      "text": "Avoir trop chanté",
      "correct": false
    },
    {
      "text": "N'avoir pas tamponné la file dès la première soif du pont",
      "correct": true
    },
    {
      "text": "Avoir vendu la clé",
      "correct": false
    },
    {
      "text": "Avoir fermé le figuier",
      "correct": false
    }
  ],
  "explanation": "« j'aurais dû tamponner la file dès la première soif du pont. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on pourrait / il faudrait",
      "right": "eau / Noura"
    },
    {
      "left": "je suggérerais / vous feriez mieux",
      "right": "affiche"
    },
    {
      "left": "j'aurais dû",
      "right": "Sami / Solange / Karim"
    },
    {
      "left": "nous n'aurions pas dû",
      "right": "huile à la rivière"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous n'___ pas dû laisser l'huile à la rivière.",
  "answer": "aurions"
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
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "conscience",
  "hint": "Moment où la cour voit ce qu'elle aurait dû faire plus tôt."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On pourrait élargir le créneau d'une demi-heure, et j'aurais du tamponner la file plus tôt.",
  "correct_sentence": "On pourrait élargir le créneau d'une demi-heure, et j'aurais dû tamponner la file plus tôt.",
  "explanation": "Dû de devoir, avec accent, au conditionnel passé."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/recommandation.svg",
      "word": "une recommandation"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/main-conscience.svg",
      "word": "une conscience"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/action-citoyenne.svg",
      "word": "une action"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/indefinis.svg",
      "word": "un indéfini"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez trois recommandations et trois regrets ; soulignez les conditionnels."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le carnet d'Aline, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire on pourrait, j''aurais dû',
    'PO',
    $c$Objectif
Recommander avec le conditionnel d'atténuation et avouer un regret au passé.

Consigne
Répétez, puis formulez deux recommandations et deux regrets sur la cour.

Support — Modèles de Sami, Solange et Aline
On pourrait élargir le créneau.
Il faudrait que Noura soit prévenue.
Je suggérerais de baisser le micro.
Vous feriez mieux d'écrire l'heure.
Il vaudrait mieux compter les seaux à deux.
On devrait relire la motion avant de crier.
J'aurais dû finir plus tôt.
Nous n'aurions pas dû laisser l'huile à l'eau.
Il aurait fallu le panier dès le premier jeudi.
J'aurais dû tamponner la file plus tôt.
Nous aurions dû entendre le silence de Noura.
Il aurait fallu que la clé rentre le soir même.
Aline : le conditionnel présent atténue l'ordre. Le conditionnel passé porte le regret.
Patrick : j'aurais dû + infinitif. Il aurait fallu que + subjonctif.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« J'aurais dû » se construit avec un infinitif, non avec un subjonctif direct.",
  "correct": true,
  "explanation": "J'aurais dû finir / tamponner / réclamer."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est un regret au conditionnel passé ?",
  "options": [
    {
      "text": "On pourrait élargir le créneau",
      "correct": false
    },
    {
      "text": "Je suggérerais de baisser le micro",
      "correct": false
    },
    {
      "text": "J'aurais dû finir plus tôt",
      "correct": true
    },
    {
      "text": "Il faut de l'eau",
      "correct": false
    }
  ],
  "explanation": "J'aurais dû + infinitif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on pourrait / on devrait",
      "right": "atténuation"
    },
    {
      "left": "il faudrait que",
      "right": "atténuation + subj."
    },
    {
      "left": "j'aurais dû",
      "right": "regret + inf."
    },
    {
      "left": "il aurait fallu que",
      "right": "regret + subj."
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl aurait fallu que la clé ___ le soir même. (rentrer)",
  "answer": "rentre"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'aurais",
    "dû",
    "tamponner",
    "la",
    "file",
    "plus",
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
  "word": "recommander",
  "hint": "Dire on pourrait, il faudrait, sans transformer l'avis en ordre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On pourrait élargir le créneau demain, et j'aurais dus finir le morceau plus tôt.",
  "correct_sentence": "On pourrait élargir le créneau demain, et j'aurais dû finir le morceau plus tôt.",
  "explanation": "Dû reste invariable ici : j'aurais dû + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/main-conscience.svg",
      "word": "une conscience"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/action-citoyenne.svg",
      "word": "une action"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/indefinis.svg",
      "word": "un indéfini"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/petition-solange.svg",
      "word": "une pétition"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez dix phrases : cinq atténuations, cinq regrets (dont un il aurait fallu que)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis deux recommandations et un regret à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mes recommandations et mes regrets',
    'PE',
    $c$Objectif
Écrire une prise de conscience : recommandations atténuées et regrets au passé.

Consigne
Imitez la page de Sami, sans aller trop vite.

Support — Page de Sami, Cahier des racines
Sami — conscience, après la veillée
J'aurais dû finir le morceau avant vingt et une heures.
Je le dis sans théâtre, et je le tiens.
Nous n'aurions pas dû laisser l'huile au bord de l'eau.
Il aurait fallu le panier ocre dès le premier jeudi, plutôt que de croire l'herbe assez propre.
On pourrait garder la veillée et raccourcir la fin.
Il faudrait que Radio Figuier baisse le micro avant le dernier rythme, afin que la rive respire.
Je suggérerais une pause entre le tambour et la parole.
Vous feriez mieux d'écrire l'heure à hauteur d'enfant, Lila : Yvette l'a déjà dit.
Il vaudrait mieux que Rose et moi parlions avant l'assemblée, à condition que personne n'en fasse un duel.
On devrait relire la motion n°14 sans crier.
Un conditionnel atténue ; il n'efface pas les douze lanternes qui ont été vues.
Solange, j'entends ton regret : tu aurais dû tamponner la file plus tôt.
Moi, j'aurais dû écouter Noura comme un fait.
Pour que la cour évolue, il faut que nos « on pourrait » deviennent des gestes, pourvu que l'aube des seaux tienne encore.
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Sami refuse d'avouer le moindre regret sur l'heure du tambour.",
  "correct": false,
  "explanation": "Première phrase : j'aurais dû finir avant vingt et une heures."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle recommandation Sami adresse-t-il à Lila ?",
  "options": [
    {
      "text": "Fermer l'antenne",
      "correct": false
    },
    {
      "text": "Écrire l'heure à hauteur d'enfant",
      "correct": true
    },
    {
      "text": "Interdire Rose",
      "correct": false
    },
    {
      "text": "Cacher le panier",
      "correct": false
    }
  ],
  "explanation": "« Vous feriez mieux d'écrire l'heure à hauteur d'enfant, Lila. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "j'aurais dû finir",
      "right": "regret du tambour"
    },
    {
      "left": "nous n'aurions pas dû",
      "right": "huile"
    },
    {
      "left": "on pourrait / il faudrait",
      "right": "veillée et micro"
    },
    {
      "left": "vous feriez mieux",
      "right": "heure à hauteur d'enfant"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl aurait fallu le panier ___ le premier jeudi.",
  "answer": "dès"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'aurais",
    "dû",
    "écouter",
    "Noura",
    "comme",
    "un",
    "fait",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "atténuer",
  "hint": "Rendre l'ordre plus souple : on pourrait, je suggérerais."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On pourrait garder la veillée, et nous n'aurions pas dûs laisser l'huile à l'eau.",
  "correct_sentence": "On pourrait garder la veillée, et nous n'aurions pas dû laisser l'huile à l'eau.",
  "explanation": "Dû invariable devant un infinitif : pas dûs."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/action-citoyenne.svg",
      "word": "une action"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/indefinis.svg",
      "word": "un indéfini"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/petition-solange.svg",
      "word": "une pétition"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/seau-commun.svg",
      "word": "un seau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : quinze lignes, trois atténuations, trois regrets, un pour que ou pourvu que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre page, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Conditionnel d''atténuation et de regret',
    'EL',
    $c$Objectif
Retenir les formes du conditionnel présent (conseil) et du conditionnel passé (regret).

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, conditionnels citoyens
Atténuation (conditionnel présent) :
on pourrait + inf. ; on devrait + inf. ; je suggérerais de + inf.
il faudrait + inf. / il faudrait que + subj. ; il vaudrait mieux que + subj.
vous feriez mieux de + inf. ; je recommanderais + nom / de + inf.
Regret (conditionnel passé) :
j'aurais dû / tu aurais dû / nous aurions dû + infinitif
nous n'aurions pas dû + inf. (regret d'une action faite)
il aurait fallu + inf. / il aurait fallu que + subj.
j'aurais voulu que + subj. (souhait trop tard)
Dû (devoir) s'écrit avec accent, invariable devant l'infinitif : j'aurais dû parler, nous aurions dû écouter.
On ne dit pas : j'aurais du parler (article). On ne dit pas : j'aurais dus parler (accord fautif).
Futur ≠ cond. : je pourrai (futur, 2 r) / je pourrais (cond.). je ferai / je ferais. je serai / je serais.
Une recommandation n'est pas un ordre. Un regret n'est pas une injure.
Pour que la cour évolue, le conditionnel doit devenir un geste, à condition que l'on signe encore.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On accorde « dû » au pluriel devant un infinitif : nous aurions dûs.",
  "correct": false,
  "explanation": "Dû reste invariable devant l'infinitif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est le futur de pouvoir ?",
  "options": [
    {
      "text": "je pourai",
      "correct": false
    },
    {
      "text": "je pourrais",
      "correct": false
    },
    {
      "text": "je pourrai",
      "correct": true
    },
    {
      "text": "je pouvrai",
      "correct": false
    }
  ],
  "explanation": "Futur : je pourrai (deux r). Conditionnel : je pourrais."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on pourrait / je suggérerais",
      "right": "atténuation"
    },
    {
      "left": "il faudrait que",
      "right": "atténuation + subj."
    },
    {
      "left": "j'aurais dû",
      "right": "regret + inf."
    },
    {
      "left": "il aurait fallu que",
      "right": "regret + subj."
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDemain, je ___ relire la motion. (pouvoir, futur)",
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
    "J'aurais",
    "dû",
    "tamponner",
    "la",
    "file",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "fallu",
  "hint": "Il aurait… que la clé rentre : regret impersonnel."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On pourrait convoquer l'assemblée, et je pourai proposer une pause demain.",
  "correct_sentence": "On pourrait convoquer l'assemblée, et je pourrai proposer une pause demain.",
  "explanation": "Futur de pouvoir : pourrai, deux r, sans ais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/indefinis.svg",
      "word": "un indéfini"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/petition-solange.svg",
      "word": "une pétition"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/seau-commun.svg",
      "word": "un seau"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/locution-prep.svg",
      "word": "une locution"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Conjuguez pouvoir, devoir, falloir (il), suggérer au cond. présent et au cond. passé (je / nous)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six formes : pourrait, faudrait, suggérerais, aurais dû, n'aurions pas dû, aurait fallu."
}$j$::jsonb,
    9
  );

  -- ===== Action citoyenne =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Action citoyenne'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Action citoyenne', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Quiconque signe, chacun porte',
    'CO',
    $c$Objectif
Repérer adjectifs et pronoms indéfinis dans une action de cour.

Consigne
Lisez le dialogue. Qui peut agir, et avec quels indéfinis le dit-on ?

Support — Cour du figuier, cahier de signatures
Solange : Quiconque signe la feuille peut porter un seau demain à l'aube. Quiconque : une personne, n'importe laquelle.
Hawa : Chacun prendra son tour. Chacune, si l'on parle des voix de Noura et d'Yvette, aussi.
Rose : N'importe quel jeudi convient pour compter les lanternes, pourvu que le panier soit là.
Léa : Certains doutent encore. Certaines voix du pont n'ont pas été inscrites. Il faut que toutes le soient.
Patrick : Plusieurs ont déjà porté l'huile jusqu'au compost. Tout le monde n'était pas là, mais plusieurs, oui.
Joël : Tout geste utile compte. Toute excuse trop longue recule l'action. Tous les seaux manquants ont un nom.
Aline : On laisse d'aucuns au bord du dictionnaire : c'est rare, littéraire ; ici l'on dit certains.
Noura : Quiconque arrive par le minibus a le droit d'inscrire une plage à la Salle des Herbes.
Karim : N'importe quelle clé trouvée se rend au Bureau, pas à n'importe qui dans l'herbe.
Lila : Plusieurs écouteront l'antenne ; chacun pourra répondre par un mot, pas par un cri.
Mado : Tout n'est pas urgent. Certaines tâches attendent le jeudi ; d'autres, l'aube.
Dieudonné : Chacun selon ses forces : l'un compte, l'autre porte, un troisième signe.
Yvette : N'importe quel enfant peut lire l'affiche, si elle est assez basse.
Marc : L'action citoyenne, ici, ce n'est pas une foule sans visage : c'est quiconque, chacun, plusieurs, tout — nommé.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Solange réserve la feuille aux seuls anciens, à l'exclusion de quiconque d'autre.",
  "correct": false,
  "explanation": "« Quiconque signe la feuille peut porter un seau. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que dit Aline de « d'aucuns » ?",
  "options": [
    {
      "text": "C'est le mot obligatoire du Seuil",
      "correct": false
    },
    {
      "text": "C'est rare et littéraire ; ici l'on dit certains",
      "correct": true
    },
    {
      "text": "Cela remplace toujours chacun",
      "correct": false
    },
    {
      "text": "Cela interdit de signer",
      "correct": false
    }
  ],
  "explanation": "Aline : on préfère certains."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "quiconque",
      "right": "n'importe quelle personne"
    },
    {
      "left": "chacun / chacune",
      "right": "tour à tour"
    },
    {
      "left": "n'importe quel / quelle",
      "right": "jeudi / clé / enfant"
    },
    {
      "left": "certains / plusieurs / tout",
      "right": "part ou totalité"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ signe la feuille peut porter un seau demain.",
  "answer": "Quiconque"
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
    "prendra",
    "son",
    "tour",
    "à",
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
  "word": "quiconque",
  "hint": "N'importe quelle personne : celle qui signe, celle du minibus."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quiconque signent la feuille peut porter un seau, et chacun prendra son tour.",
  "correct_sentence": "Quiconque signe la feuille peut porter un seau, et chacun prendra son tour.",
  "explanation": "Quiconque appelle la 3e personne du singulier : signe, pas signent."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/petition-solange.svg",
      "word": "une pétition"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/seau-commun.svg",
      "word": "un seau"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/locution-prep.svg",
      "word": "une locution"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/accord-cod.svg",
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
  "prompt": "Notez six indéfinis entendus et la personne ou le geste qu'ils désignent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Quiconque signe peut porter un seau. Chacun prendra son tour. N'importe quel jeudi convient. Certains doutent encore."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Appel à signer',
    'CE',
    $c$Objectif
Lire un appel citoyen qui enchaîne quiconque, chacun, n'importe quel, certains, plusieurs, tout.

Consigne
Lisez l'appel, sans aller trop vite.

Support — Appel de Solange, Bureau des Escales
Appel — action de cour, signatures au figuier
Quiconque habite Rukiri-Nord, quiconque passe par le Seuil, peut signer. On ne demande pas un titre ; on demande un nom lisible.
Chacun portera, une fois au moins, un seau ou une lanterne éteinte jusqu'au panier. Chacune qui enseigne un geste, Hawa ou Félicie, pourra réserver la salle.
N'importe quel jeudi convient pour compter. N'importe quelle affiche trop haute sera recollée plus bas. N'importe quel enfant doit pouvoir la lire.
Certains doutent que le créneau tienne. Certaines voix du pont n'ont pas encore été inscrites : il faut que toutes le soient, plutôt qu'on décide sans elles.
Plusieurs ont déjà porté l'huile au compost. Plusieurs écouteront Lila ce soir. Ce n'est pas tout le monde ; c'est déjà une action.
Tout geste utile compte. Toute excuse trop longue recule le jeudi. Tous les seaux manquants ont un nom. Toutes les heures s'écrivent au Bureau.
On n'emploiera pas d'aucuns : le mot est rare ; ici l'on dit certains, et cela suffit.
Quiconque trouve une clé la rend, pas à n'importe qui. Karim l'a rappelé.
Marc : l'action citoyenne a des visages. L'indéfini n'efface pas le prénom ; il ouvre la porte.
Aline : quiconque + 3e pers. du singulier. Chacun + singulier. Plusieurs + pluriel.
Seuil des Sources — signer, c'est déjà faire évoluer, pourvu que l'on revienne demain.
Solange — tampon à côté, pas à la place de la signature.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'appel exige un titre officiel avant toute signature.",
  "correct": false,
  "explanation": "« On ne demande pas un titre ; on demande un nom lisible. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que doivent faire tous les seaux manquants, d'après l'appel ?",
  "options": [
    {
      "text": "Disparaître du bilan",
      "correct": false
    },
    {
      "text": "Avoir un nom",
      "correct": true
    },
    {
      "text": "Servir de tambour",
      "correct": false
    },
    {
      "text": "Aller sous une pierre",
      "correct": false
    }
  ],
  "explanation": "« Tous les seaux manquants ont un nom. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "quiconque",
      "right": "habite / passe / trouve une clé"
    },
    {
      "left": "chacun / chacune",
      "right": "porter / réserver"
    },
    {
      "left": "n'importe quel",
      "right": "jeudi / affiche / enfant"
    },
    {
      "left": "certains / plusieurs / tout",
      "right": "doute / compost / geste"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ geste utile compte.",
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
    "Plusieurs",
    "ont",
    "déjà",
    "porté",
    "l'huile",
    "au",
    "compost",
    "."
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
  "hint": "Un à un, son tour de seau : pronom singulier de l'action."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quiconque habitent Rukiri-Nord peut signer, et chacun portera un seau une fois.",
  "correct_sentence": "Quiconque habite Rukiri-Nord peut signer, et chacun portera un seau une fois.",
  "explanation": "Quiconque + 3e pers. singulier : habite."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/seau-commun.svg",
      "word": "un seau"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/locution-prep.svg",
      "word": "une locution"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/accord-cod.svg",
      "word": "un accord"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/denoncer.svg",
      "word": "une dénonciation"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez l'appel et encadrez tous les indéfinis ; notez le verbe qui suit."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'appel de Solange, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire quiconque, chacun, plusieurs',
    'PO',
    $c$Objectif
Employer à l'oral les indéfinis pour lancer une action sans fermer la porte.

Consigne
Répétez, puis lancez un appel : qui peut signer, qui porte, qui doute encore.

Support — Modèles de Solange et d'Aline
Quiconque signe peut porter un seau.
Chacun prendra son tour.
Chacune pourra réserver la salle.
N'importe quel jeudi convient.
N'importe quelle affiche trop haute sera recollée.
Certains doutent encore.
Plusieurs ont déjà porté l'huile.
Tout geste utile compte.
Toute excuse trop longue recule l'action.
Tous les seaux manquants ont un nom.
Quiconque trouve une clé la rend.
Pas à n'importe qui, dans l'herbe.
Aline : quiconque + il (signe, habite, trouve).
Marc : certains / plusieurs ouvrent une part ; tout ouvre le total.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« N'importe qui » et « n'importe quel » se construisent de la même façon.",
  "correct": false,
  "explanation": "N'importe qui = pronom. N'importe quel + nom (jeudi, affiche, enfant)."
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
      "text": "Quiconque signent demain",
      "correct": false
    },
    {
      "text": "Quiconque signe peut porter un seau",
      "correct": true
    },
    {
      "text": "Chacun prennent leur tour",
      "correct": false
    },
    {
      "text": "Tout les geste compte",
      "correct": false
    }
  ],
  "explanation": "Quiconque + 3e pers. singulier."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "quiconque",
      "right": "3e pers. singulier"
    },
    {
      "left": "chacun / chacune",
      "right": "un à un"
    },
    {
      "left": "n'importe quel + nom",
      "right": "jeudi / affiche"
    },
    {
      "left": "plusieurs / certains",
      "right": "une part"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nN'importe ___ jeudi convient pour compter.",
  "answer": "quel"
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
    "geste",
    "utile",
    "compte",
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
  "word": "plusieurs",
  "hint": "Plus d'un, pas tous : ceux qui ont déjà porté l'huile."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Chacun prendra son tour à l'aube, et n'importe quels jeudi convient pour compter.",
  "correct_sentence": "Chacun prendra son tour à l'aube, et n'importe quel jeudi convient pour compter.",
  "explanation": "N'importe quel + nom singulier : quel jeudi."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/locution-prep.svg",
      "word": "une locution"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/accord-cod.svg",
      "word": "un accord"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/denoncer.svg",
      "word": "une dénonciation"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/solution-rive.svg",
      "word": "une solution"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez douze phrases : deux par indéfini (quiconque, chacun, n'importe quel, certains, plusieurs, tout)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis un appel à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon appel citoyen',
    'PE',
    $c$Objectif
Écrire un appel à l'action qui emploie les indéfinis sans effacer les prénoms.

Consigne
Imitez l'appel de Rose Iradukunda, sans aller trop vite.

Support — Appel de Rose, feuille ocre
Rose Iradukunda — quiconque veut que la cour évolue
Quiconque habite le Seuil, quiconque descend du Figuier 7, peut signer cette feuille.
Je ne demande pas un titre ; je demande un nom.
Chacun portera, une fois, un seau ou une lanterne éteinte.
Chacune qui sait un geste, Hawa ou Félicie, pourra ouvrir une plage à la salle, à condition que Solange inscrive l'heure.
N'importe quel jeudi convient pour compter les restes.
N'importe quelle affiche trop haute sera recollée : n'importe quel enfant doit pouvoir la lire.
Certains doutent encore, et c'est un fait, non une injure.
Certaines voix du pont n'ont pas été inscrites : il faut que toutes le soient, plutôt qu'on décide sans elles.
Plusieurs ont déjà marché jusqu'au compost.
Ce n'est pas tout le monde ; c'est déjà trop précieux pour le taire.
Tout geste utile compte.
Toute excuse trop longue recule le jeudi.
Tous les seaux manquants ont un nom, et je le rappellerai.
Quiconque trouve une clé la rend au Bureau, pas à n'importe qui.
D'aucuns diraient autrement ; ici l'on dit certains, et l'on avance.
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose refuse les signatures de ceux du minibus.",
  "correct": false,
  "explanation": "« quiconque descend du Figuier 7 peut signer. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que deviennent les affiches trop hautes, d'après Rose ?",
  "options": [
    {
      "text": "Elles sont brûlées",
      "correct": false
    },
    {
      "text": "Elles sont recollées plus bas",
      "correct": true
    },
    {
      "text": "Elles vont à la rivière",
      "correct": false
    },
    {
      "text": "Elles remplacent le tampon",
      "correct": false
    }
  ],
  "explanation": "« N'importe quelle affiche trop haute sera recollée. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "quiconque",
      "right": "Seuil / minibus / clé"
    },
    {
      "left": "chacun / chacune",
      "right": "seau / salle"
    },
    {
      "left": "n'importe quel",
      "right": "jeudi / affiche / enfant"
    },
    {
      "left": "certains / plusieurs / tout",
      "right": "doute / compost / geste"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut que ___ les voix du pont soient inscrites.",
  "answer": "toutes"
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
    "trouve",
    "une",
    "clé",
    "la",
    "rend",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "signer",
  "hint": "Porter son nom sur la feuille ocre, premier geste de l'action."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Certains doute encore sous le figuier, et plusieurs ont déjà porté l'huile.",
  "correct_sentence": "Certains doutent encore sous le figuier, et plusieurs ont déjà porté l'huile.",
  "explanation": "Certains + verbe au pluriel : doutent."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/accord-cod.svg",
      "word": "un accord"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/denoncer.svg",
      "word": "une dénonciation"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/solution-rive.svg",
      "word": "une solution"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/motion-bureau.svg",
      "word": "une motion"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : quinze lignes, six indéfinis, un prénom au moins, pas de d'aucuns obligatoire."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre appel, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Adjectifs et pronoms indéfinis',
    'EL',
    $c$Objectif
Retenir accords et constructions de quiconque, chacun, n'importe quel, certains, plusieurs, tout.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, indéfinis citoyens
Quiconque = n'importe quelle personne. Toujours 3e pers. singulier :
Quiconque signe / habite / trouve. On ne dit pas : quiconque signent.
Chacun (m.) / chacune (f.) : singulier. Chacun prendra son tour. Chacune pourra réserver.
N'importe qui (pronom) / n'importe quel + nom : n'importe quel jeudi, n'importe quelle affiche, n'importe quels seaux, n'importe quelles heures.
N'importe qui ≠ n'importe quel. Pas à n'importe qui (personne). N'importe quelle clé (objet).
Certains / certaines : pluriel. Certains doutent. Certaines voix n'ont pas été inscrites.
Plusieurs : pluriel, une part (plus d'un, pas tous). Plusieurs ont porté l'huile.
Tout + nom singulier : tout geste. Toute excuse. Tous les seaux. Toutes les heures.
Tout le monde = singulier (tout le monde est là). Tous = pluriel.
D'aucuns : rare, littéraire (= certains). Au Seuil, on dit certains. On peut le reconnaître, on ne l'exige pas.
L'indéfini ouvre la porte ; il n'efface pas le prénom. Quiconque s'appelle encore Noura, Sami, Yvette.
À + le = au Bureau. De + le = du pont.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Tout le monde » se construit au pluriel : tout le monde sont là.",
  "correct": false,
  "explanation": "Tout le monde est là : singulier."
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
      "text": "quiconque signent / chacun prennent",
      "correct": false
    },
    {
      "text": "quiconque signe / chacun prendra / certains doutent",
      "correct": true
    },
    {
      "text": "n'importe qui jeudi / tout les geste",
      "correct": false
    },
    {
      "text": "d'aucuns obligatoire partout",
      "correct": false
    }
  ],
  "explanation": "Singulier pour quiconque et chacun ; pluriel pour certains."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "quiconque",
      "right": "3e pers. singulier"
    },
    {
      "left": "chacun / chacune",
      "right": "un à un"
    },
    {
      "left": "n'importe quel + nom",
      "right": "choix ouvert"
    },
    {
      "left": "certains / plusieurs",
      "right": "une part"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTout le monde ___ déjà là. (être)",
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
    "N'importe",
    "quel",
    "enfant",
    "peut",
    "lire",
    "l'affiche",
    "."
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
  "hint": "Classe de mots : quiconque, chacun, plusieurs, tout. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tout le monde sont déjà sous le figuier, et chacun prendra son tour.",
  "correct_sentence": "Tout le monde est déjà sous le figuier, et chacun prendra son tour.",
  "explanation": "Tout le monde + 3e pers. singulier : est."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/denoncer.svg",
      "word": "une dénonciation"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/solution-rive.svg",
      "word": "une solution"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/motion-bureau.svg",
      "word": "une motion"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/tampon-motion.svg",
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
  "prompt": "Tableau d'accords : quiconque, chacun, n'importe quel(le)(s), certains, plusieurs, tout/toute/tous/toutes."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six phrases, un indéfini chacune."
}$j$::jsonb,
    9
  );

  -- ===== Dénoncer et proposer =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Dénoncer et proposer'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Dénoncer et proposer', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Les mesures que nous avons prises',
    'CO',
    $c$Objectif
Repérer les locutions prépositionnelles et l'accord du participe avec le COD antéposé.

Consigne
Lisez le dialogue. Que dénonce-t-on, que propose-t-on, et quels accords entend-on ?

Support — Assemblée naissante, affiche au figuier
Marc : Il faut s'attaquer au gaspillage des lanternes, non aux personnes qui ont fêté.
Aline : Veillons à ce que le panier soit là. Veiller à une heure écrite, veiller à ce que Noura soit prévenue.
Rose : Cette motion aboutira à une règle de cour, à condition que Solange tamponne.
Hawa : Tout cela dépend encore du niveau de la rivière, et du minibus, et de notre mémoire.
Léa : Les mesures que nous avons prises restent fragiles. Prises s'accorde avec mesures, COD avant.
Patrick : La file que Solange a tamponnée n'est pas une rumeur. Tamponnée, féminin, parce que file est avant.
Joël : Les lanternes que nous avons éteintes iront au panier. Éteintes : COD lanternes, avant, féminin pluriel.
Solange : Les voix que j'ai entendues au Bureau n'étaient pas un cri. Entendues, accord.
Karim : Les clés que nous avons rendues ne circulent plus dans l'herbe. Rendues.
Noura : Je dénonce le tampon muet, et je propose une heure dite à la radio. Dénoncer n'est pas insulter.
Dieudonné : On s'attaque à l'huile, on veille au chiffre, on aboutit à une file, on dépend de l'eau.
Lila : Les recommandations que vous avez formulées, je les lirai sans théâtre. Formulées, COD avant.
Yvette : La pause que nous avons demandée entre tambour et micro n'est pas un caprice.
Mado : Accorder le participe, c'est encore une manière de ne pas effacer ce qui a été fait par qui.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc dit qu'il faut s'attaquer aux personnes qui ont fêté.",
  "correct": false,
  "explanation": "« s'attaquer au gaspillage… non aux personnes »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi écrit-on « les mesures que nous avons prises » ?",
  "options": [
    {
      "text": "Parce que nous est pluriel seulement",
      "correct": false
    },
    {
      "text": "Parce que mesures, COD, est placé avant le verbe",
      "correct": true
    },
    {
      "text": "Parce que pris ne s'accorde jamais",
      "correct": false
    },
    {
      "text": "Parce que c'est un passif avec être",
      "correct": false
    }
  ],
  "explanation": "Avoir + PP : accord avec le COD si le COD est avant."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "s'attaquer à",
      "right": "gaspillage / huile"
    },
    {
      "left": "veiller à / à ce que",
      "right": "panier / heure / Noura"
    },
    {
      "left": "aboutir à",
      "right": "règle / file"
    },
    {
      "left": "dépendre de",
      "right": "rivière / minibus / mémoire"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes mesures que nous avons ___ restent fragiles. (prendre)",
  "answer": "prises"
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
    "s'attaquer",
    "au",
    "gaspillage",
    "des",
    "lanternes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "mesures",
  "hint": "Décisions déjà prises : créneau, panier, file, clé au tiroir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les mesures que nous avons pris restent fragiles, et la file que Solange a tamponnée n'est pas une rumeur.",
  "correct_sentence": "Les mesures que nous avons prises restent fragiles, et la file que Solange a tamponnée n'est pas une rumeur.",
  "explanation": "Mesures, COD avant, féminin pluriel → prises."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/solution-rive.svg",
      "word": "une solution"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/motion-bureau.svg",
      "word": "une motion"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/tampon-motion.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/lettre-officielle.svg",
      "word": "une lettre officielle"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez quatre locutions et quatre accords COD avant (mot + participe)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il faut s'attaquer au gaspillage. Veillons à ce que le panier soit là. Les mesures que nous avons prises restent fragiles."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Dénoncer le geste, proposer la règle',
    'CE',
    $c$Objectif
Lire un texte qui dénonce sans insulter et propose avec locutions et accords.

Consigne
Lisez la tribune, sans aller trop vite.

Support — Tribune de Léa Niyonzima, Cahier des racines
Dénoncer et proposer — sans injure (Rukiri-Nord)
Nous nous attaquons au gaspillage, non à Sami. Nous nous attaquons au tampon muet, non à Solange. La personne n'est pas le geste.
Veillons à l'heure écrite. Veillons à ce que Noura soit prévenue. Veiller à + nom ; veiller à ce que + subjonctif.
Cette assemblée aboutira à une motion formelle, à condition que chacun signe. Aboutir à un texte, pas à un cri.
Tout dépend encore de la rivière, du minibus, de notre mémoire. On ne dit pas dépendre à.
Les mesures que nous avons prises (créneau, panier, file) restent fragiles. Les lanternes que nous avons éteintes trop tard ont marqué l'eau.
La pause que nous avons demandée n'a pas encore été tenue. Les voix que Lila a relues à l'antenne n'étaient pas un slogan.
Les clés que Karim a rendues ne circulent plus. La plage que Félicie a réservée tiendra, pourvu que l'heure rentre au cahier.
Je dénonce le tout ou rien. Je propose une demi-heure de plus à l'eau, une fin d'heure au tambour, une affiche plus basse.
Les recommandations que vous avez formulées, je les reprends : on pourrait, il faudrait, j'aurais dû — et maintenant un geste.
Aline : COD avant + avoir → accord. Les mesures que nous avons prises. Sans COD avant : nous avons pris des mesures (pas d'accord).
Patrick : s'attaquer à, veiller à, aboutir à, dépendre de. Quatre liens, un seul enjeu à la fois.
Seuil des Sources — dénoncer un geste, proposer une règle, accorder ce que l'on a déjà fait.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa s'attaque à Solange en personne, non au tampon muet.",
  "correct": false,
  "explanation": "« au tampon muet, non à Solange. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quand n'accorde-t-on pas le participe avec avoir, d'après Aline ?",
  "options": [
    {
      "text": "Toujours, jamais d'accord",
      "correct": false
    },
    {
      "text": "Quand le COD est après : nous avons pris des mesures",
      "correct": true
    },
    {
      "text": "Quand le sujet est féminin seulement",
      "correct": false
    },
    {
      "text": "Quand on emploie veiller à",
      "correct": false
    }
  ],
  "explanation": "Sans COD avant, pas d'accord : pris."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "s'attaquer à",
      "right": "gaspillage / tampon muet"
    },
    {
      "left": "veiller à ce que",
      "right": "Noura prévenue"
    },
    {
      "left": "aboutir à",
      "right": "motion formelle"
    },
    {
      "left": "les mesures que nous avons prises",
      "right": "COD avant"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes lanternes que nous avons ___ trop tard ont marqué l'eau. (éteindre)",
  "answer": "éteintes"
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
    "dépend",
    "encore",
    "de",
    "la",
    "rivière",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "denoncer",
  "hint": "Nommer le geste nuisible, sans insulter la personne. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les lanternes que nous avons eteint trop tard ont marqué l'eau, et le panier attend encore.",
  "correct_sentence": "Les lanternes que nous avons éteintes trop tard ont marqué l'eau, et le panier attend encore.",
  "explanation": "Lanternes, COD avant, féminin pluriel → éteintes."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/motion-bureau.svg",
      "word": "une motion"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/tampon-motion.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/lettre-officielle.svg",
      "word": "une lettre officielle"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/porte-escales.svg",
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
  "prompt": "Recopiez la tribune ; encadrez les locutions et les participes accordés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la tribune de Léa, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire s''attaquer à, les mesures que…',
    'PO',
    $c$Objectif
Dénoncer et proposer à l'oral avec les locutions, et accorder le PP du COD avant.

Consigne
Répétez, puis dénoncez un geste et proposez une règle, avec un accord audible.

Support — Modèles de Marc, Léa et Aline
Nous nous attaquons au gaspillage, non aux personnes.
Veillons à l'heure écrite.
Veillons à ce que Noura soit prévenue.
Cette assemblée aboutira à une motion.
Tout dépend encore de la rivière.
Les mesures que nous avons prises restent fragiles.
Les lanternes que nous avons éteintes iront au panier.
La file que Solange a tamponnée n'est pas une rumeur.
Les voix que j'ai entendues n'étaient pas un cri.
Les clés que nous avons rendues ne circulent plus.
La pause que nous avons demandée n'est pas un caprice.
Nous avons pris des mesures : pas d'accord, COD après.
Aline : entendre le e, le s, le es du participe, c'est déjà soigner le fait.
Patrick : dépendre de, pas dépendre à. Aboutir à, pas aboutir de.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Nous avons pris des mesures » n'accorde pas le participe, car le COD est après.",
  "correct": true,
  "explanation": "COD après → pris. COD avant → prises."
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
      "text": "Nous dépendons à la rivière",
      "correct": false
    },
    {
      "text": "Nous aboutissons de une motion",
      "correct": false
    },
    {
      "text": "Les mesures que nous avons prises restent fragiles",
      "correct": true
    },
    {
      "text": "Nous nous attaquons de le gaspillage",
      "correct": false
    }
  ],
  "explanation": "S'attaquer à ; aboutir à ; dépendre de ; prises, COD avant."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "s'attaquer à",
      "right": "un geste, pas une personne"
    },
    {
      "left": "veiller à / à ce que",
      "right": "nom / subjonctif"
    },
    {
      "left": "aboutir à / dépendre de",
      "right": "résultat / source"
    },
    {
      "left": "COD avant",
      "right": "accord du PP"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous dépendons encore ___ la rivière.",
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
    "La",
    "file",
    "que",
    "Solange",
    "a",
    "tamponnée",
    "n'est",
    "pas",
    "une",
    "rumeur",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "accorder",
  "hint": "Faire porter au participe le genre et le nombre du COD placé avant."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous dépendons à la rivière encore cette semaine, et les mesures que nous avons prises restent fragiles.",
  "correct_sentence": "Nous dépendons de la rivière encore cette semaine, et les mesures que nous avons prises restent fragiles.",
  "explanation": "Dépendre de, pas dépendre à."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/tampon-motion.svg",
      "word": "un tampon"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/lettre-officielle.svg",
      "word": "une lettre officielle"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/porte-escales.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/compost-cour.svg",
      "word": "le compost"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases : quatre locutions, quatre accords COD avant."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis une dénonciation et une proposition à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma tribune : dénoncer et proposer',
    'PE',
    $c$Objectif
Écrire une tribune qui dénonce un geste, propose une règle, accorde les participes.

Consigne
Imitez la tribune de Patrick Habimana, sans aller trop vite.

Support — Tribune de Patrick, encre du jeudi
Patrick Habimana — dénoncer le geste, proposer la règle
Nous nous attaquons à l'huile laissée au bord de l'eau, non à ceux qui ont fêté.
Nous nous attaquons au tampon muet, non à Solange.
Veillons à l'affiche basse.
Veillons à ce que ceux du minibus soient inscrits.
Cette page aboutira à une motion, à condition que quiconque signe encore.
Tout dépend de la rivière, du pont, de notre mémoire : je ne dépends pas d'un cri.
Les mesures que nous avons prises — créneau, panier, file — restent fragiles.
Les lanternes que nous avons éteintes trop tard ont marqué l'eau, et je le nomme.
La pause que nous avons demandée n'a pas encore été tenue.
Les voix que Lila a relues n'étaient pas un slogan.
Les clés que Karim a rendues ne circulent plus.
Je dénonce le tout ou rien.
Je propose une demi-heure pour Noura, une fin d'heure pour Sami, une trace pour la clé.
Les recommandations que vous avez formulées, je les reprends, et j'aurais dû les dire plus tôt.
Pour que la cour évolue, il faut que ce que nous avons écrit soit aussi ce que nous faisons.
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick s'attaque à Solange en personne plutôt qu'au tampon muet.",
  "correct": false,
  "explanation": "« au tampon muet, non à Solange. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "De quoi dépend encore la page de Patrick ?",
  "options": [
    {
      "text": "D'un cri seulement",
      "correct": false
    },
    {
      "text": "De la rivière, du pont, de la mémoire",
      "correct": true
    },
    {
      "text": "D'un parti d'ailleurs",
      "correct": false
    },
    {
      "text": "D'une pierre sous le figuier",
      "correct": false
    }
  ],
  "explanation": "« Tout dépend de la rivière, du pont, de notre mémoire. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "s'attaquer à",
      "right": "huile / tampon muet"
    },
    {
      "left": "veiller à ce que",
      "right": "minibus inscrit"
    },
    {
      "left": "aboutir à",
      "right": "motion"
    },
    {
      "left": "mesures prises / lanternes éteintes",
      "right": "accord COD avant"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes clés que Karim a ___ ne circulent plus. (rendre)",
  "answer": "rendues"
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
    "dénonce",
    "le",
    "tout",
    "ou",
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
  "word": "proposer",
  "hint": "Après avoir nommé le geste : avancer une règle, une demi-heure, une trace."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les voix que Lila a relu n'étaient pas un slogan, et les clés que Karim a rendues ne circulent plus.",
  "correct_sentence": "Les voix que Lila a relues n'étaient pas un slogan, et les clés que Karim a rendues ne circulent plus.",
  "explanation": "Voix, COD avant, féminin pluriel → relues."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/lettre-officielle.svg",
      "word": "une lettre officielle"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/porte-escales.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/compost-cour.svg",
      "word": "le compost"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/arbre-proteger.svg",
      "word": "un arbre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : quinze lignes, quatre locutions, quatre accords COD avant, une dénonciation, une proposition."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre tribune, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Locutions et accord du participe',
    'EL',
    $c$Objectif
Retenir s'attaquer à, veiller à, aboutir à, dépendre de, et l'accord du PP avec COD avant.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, locutions et accords
Locutions / verbes prépositionnels
s'attaquer à + nom (un geste, un problème, pas d'abord une personne)
veiller à + nom ; veiller à ce que + subjonctif
aboutir à + résultat (une motion, une file, une règle)
dépendre de + source (l'eau, le tampon, la mémoire) — pas dépendre à
Accord du participe passé avec avoir
COD avant le verbe → accord avec le COD :
les mesures que nous avons prises ; la file que j'ai tamponnée ; les lanternes que vous avez éteintes
les voix que Lila a relues ; les clés que nous avons rendues ; la pause que nous avons demandée
COD après → pas d'accord : nous avons pris des mesures ; Solange a tamponné une file
Être + PP (passif, déjà vu) : accord avec le sujet. Ici, le projecteur est le COD avant.
On ne dit pas : les mesures que nous avons pris (oubli de l'accord).
On ne dit pas : s'attaquer de / veiller de / aboutir de / dépendre à.
Dénoncer le geste, proposer la règle : deux mouvements, un seul ton calme.
À + le = au gaspillage, au Bureau. De + le = du pont, du minibus.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « nous dépendons à la rivière ».",
  "correct": false,
  "explanation": "Dépendre de, jamais dépendre à."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Solange a tamponné une file » : pourquoi pas d'accord ?",
  "options": [
    {
      "text": "Parce que Solange est un prénom",
      "correct": false
    },
    {
      "text": "Parce que le COD une file est après le verbe",
      "correct": true
    },
    {
      "text": "Parce que tamponner n'a jamais de participe",
      "correct": false
    },
    {
      "text": "Parce que c'est un subjonctif",
      "correct": false
    }
  ],
  "explanation": "COD après → tamponné, invariable ici."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "s'attaquer à",
      "right": "un geste"
    },
    {
      "left": "veiller à ce que",
      "right": "subjonctif"
    },
    {
      "left": "aboutir à / dépendre de",
      "right": "résultat / source"
    },
    {
      "left": "COD avant",
      "right": "prises / éteintes / relues"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous avons ___ des mesures dès l'aube. (prendre, COD après)",
  "answer": "pris"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Veillons",
    "à",
    "ce",
    "que",
    "Noura",
    "soit",
    "prévenue",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "locution",
  "hint": "Groupe figé : s'attaquer à, veiller à, aboutir à, dépendre de."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous nous attaquons de le gaspillage depuis jeudi, et les mesures que nous avons prises restent fragiles.",
  "correct_sentence": "Nous nous attaquons au gaspillage depuis jeudi, et les mesures que nous avons prises restent fragiles.",
  "explanation": "S'attaquer à (+ au devant le)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/porte-escales.svg",
      "word": "une porte"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/compost-cour.svg",
      "word": "le compost"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/arbre-proteger.svg",
      "word": "un arbre"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/groupe-agir.svg",
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
  "prompt": "Transformez six phrases (COD après → COD avant) et accordez le participe."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six accords : prises, tamponnée, éteintes, relues, rendues, demandée."
}$j$::jsonb,
    9
  );

  -- ===== Assemblée sous le figuier =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Assemblée sous le figuier'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Assemblée sous le figuier', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La cour se réunit pour évoluer',
    'CO',
    $c$Objectif
Réemployer conditions, recommandations, indéfinis et locutions dans le débat d'assemblée.

Consigne
Lisez le dialogue. Quelles conditions, quels regrets et quelles propositions s'entendent ?

Support — Assemblée sous le figuier, urne inventée
Aline : Si chacun s'exprime, à condition que l'on ne crie pas, cette assemblée aboutira à une motion.
Solange : Quiconque a signé peut parler. En cas de débordement, je lève le tampon, je ne lève pas la voix.
Hawa : On pourrait ouvrir une demi-heure, pourvu que l'aube tienne. J'aurais dû le dire dès la première soif du pont.
Sami : J'aurais dû cesser plus tôt. Je veillerai à l'heure, à moins que l'orage n'interrompe la veillée.
Rose : Nous nous attaquons à l'huile, non aux fêtards. Les mesures que nous avons prises tiennent, si le panier est là.
Noura : Certains n'ont pas été inscrits. Il faudrait que toutes les voix du minibus le soient, plutôt qu'on décide sans nous.
Léa : Plusieurs ont déjà porté. Tout geste compte. Cette page aboutira à un texte formel, demain, au Bureau.
Patrick : Les lanternes que nous avons éteintes trop tard, je les nomme encore. Nous n'aurions pas dû attendre douze restes.
Marc : Que ce soit l'eau ou la salle, chaque article de la motion restera distinct. Nuancer n'est pas tout égaliser.
Joël : En cas de désaccord, on vote. On ne dépend pas d'un chef inventé.
Lila : Je lirai ce qui aura été dit, sans slogan. Veillons à ce que le chiffre reste visible : vingt voix, trois seaux, douze lanternes.
Yvette : N'importe quel enfant doit comprendre l'affiche. Vous feriez mieux de la recoller ce soir.
Karim : Les clés que nous avons rendues restent au tiroir. Quiconque en trouve une la ramène.
Dieudonné : Pourvu que la rivière ne baisse, le bilan que nous avons dressé tiendra jusqu'à jeudi.
Mado : Dénoncer, recommander, conditionner, signer : c'est déjà faire évoluer la cour.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose s'attaque aux personnes qui ont fêté, non à l'huile.",
  "correct": false,
  "explanation": "« Nous nous attaquons à l'huile, non aux fêtards. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fera Solange en cas de débordement ?",
  "options": [
    {
      "text": "Crier plus fort",
      "correct": false
    },
    {
      "text": "Lever le tampon, non la voix",
      "correct": true
    },
    {
      "text": "Fermer la rivière",
      "correct": false
    },
    {
      "text": "Annuler toutes les signatures",
      "correct": false
    }
  ],
  "explanation": "« je lève le tampon, je ne lève pas la voix. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si / à condition que / pourvu que / en cas de",
      "right": "conditions"
    },
    {
      "left": "on pourrait / j'aurais dû / il faudrait",
      "right": "recommandation et regret"
    },
    {
      "left": "quiconque / chacun / certains / plusieurs / tout",
      "right": "indéfinis"
    },
    {
      "left": "s'attaquer à / aboutir à / veiller à",
      "right": "locutions"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes mesures que nous avons ___ tiennent si le panier est là.",
  "answer": "prises"
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
    "signé",
    "peut",
    "parler",
    "."
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
  "hint": "Réunion sous le figuier, sans accent, pour aboutir à une motion."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les mesures que nous avons pris tiennent encore, et quiconque a signé peut parler.",
  "correct_sentence": "Les mesures que nous avons prises tiennent encore, et quiconque a signé peut parler.",
  "explanation": "Mesures, COD avant → prises."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/compost-cour.svg",
      "word": "le compost"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/arbre-proteger.svg",
      "word": "un arbre"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/groupe-agir.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/micro-appel.svg",
      "word": "un appel"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez une condition, une recommandation, un indéfini et une locution par enjeu."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Si chacun s'exprime, cette assemblée aboutira à une motion. Quiconque a signé peut parler. J'aurais dû le dire plus tôt."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Procès-verbal de l''assemblée',
    'CE',
    $c$Objectif
Lire le procès-verbal qui relie bilan conditionnel, regrets, indéfinis et propositions.

Consigne
Lisez le procès-verbal, sans aller trop vite.

Support — Procès-verbal d'Aline, Cahier des racines
Assemblée sous le figuier — procès-verbal (Rukiri-Nord)
Ouverture. Quiconque avait signé a pu parler.
Chacun a eu la parole une fois.
En cas de débordement, Solange a levé le tampon, non la voix.
Eau. On pourrait ouvrir une demi-heure, à condition que l'aube tienne, pourvu que Noura soit prévenue.
Hawa : j'aurais dû le proposer plus tôt.
À moins que la rivière ne baisse, pas de second créneau. En cas de pénurie, une file.
Heures calmes. Sami : j'aurais dû cesser plus tôt. Il veillera à l'heure.
Rose ne s'attaque pas aux fêtards ; elle s'attaque à l'huile du dernier morceau trop long.
Lanternes. Les mesures que nous avons prises tiennent si le panier est là.
Les lanternes que nous avons éteintes trop tard ont été nommées.
Plusieurs ont déjà porté jusqu'au compost. Tout geste compte.
Salle. Certains n'étaient pas inscrits. Il faudrait que toutes les voix du minibus le soient.
Les clés que nous avons rendues restent au tiroir. Quiconque en trouve une la ramène.
Méthode. Que ce soit l'eau ou la salle, chaque article restera distinct.
Cette assemblée aboutira à une motion formelle au Bureau des Escales.
Nous ne dépendons pas d'un chef. Nous dépendons de l'eau, de la mémoire, des signatures.
Lila lira le chiffre : vingt voix, trois seaux, douze lanternes.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le procès-verbal dit que la cour dépend d'un chef inventé.",
  "correct": false,
  "explanation": "« Nous ne dépendons pas d'un chef. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel chiffre Lila doit-elle lire ?",
  "options": [
    {
      "text": "Un seul seau, zéro voix",
      "correct": false
    },
    {
      "text": "Vingt voix, trois seaux, douze lanternes",
      "correct": true
    },
    {
      "text": "Cent lanternes seulement",
      "correct": false
    },
    {
      "text": "Aucune signature",
      "correct": false
    }
  ],
  "explanation": "Vingt / trois / douze."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "demi-heure / file",
      "right": "eau"
    },
    {
      "left": "j'aurais dû cesser",
      "right": "Sami"
    },
    {
      "left": "panier / compost",
      "right": "lanternes"
    },
    {
      "left": "voix du minibus / clés rendues",
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
  "prompt": "Complétez :\nCette assemblée aboutira ___ une motion formelle.",
  "answer": "à"
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
    "ne",
    "dépendons",
    "pas",
    "d'un",
    "chef",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "verbal",
  "hint": "Procès-… : mémoire écrite de ce qui a été dit sous le figuier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Cette assemblée aboutira à une motion formelle, et nous ne dépendons pas à un chef inventé.",
  "correct_sentence": "Cette assemblée aboutira à une motion formelle, et nous ne dépendons pas d'un chef inventé.",
  "explanation": "Dépendre de, pas dépendre à."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/arbre-proteger.svg",
      "word": "un arbre"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/groupe-agir.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/micro-appel.svg",
      "word": "un appel"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/banderole-demain.svg",
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
  "prompt": "Recopiez le PV et marquez C (condition), R (regret), I (indéfini), L (locution)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le procès-verbal, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire le débat de l''assemblée',
    'PO',
    $c$Objectif
Prendre la parole à l'assemblée en réemployant les outils des séquences 1 à 4.

Consigne
Répétez, puis prenez la parole une minute : condition, recommandation, indéfini, locution.

Support — Modèles d'assemblée, Aline et Marc
Si chacun s'exprime, nous aboutirons à une motion.
À condition que l'on ne crie pas, Solange gardera le tampon baissé.
Quiconque a signé peut parler.
On pourrait ouvrir une demi-heure, pourvu que l'aube tienne.
J'aurais dû le dire plus tôt.
Nous nous attaquons à l'huile, non aux personnes.
Les mesures que nous avons prises tiennent encore.
Certains n'ont pas été inscrits ; il faudrait qu'ils le soient.
Plusieurs ont déjà porté ; tout geste compte.
En cas de désaccord, on vote.
Nous ne dépendons pas d'un chef.
Veillons à ce que le chiffre reste visible.
Aline : une prise de parole tient quatre outils, pas un cri.
Marc : dénoncer le geste, proposer l'article, conditionner la suite.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Les modèles autorisent à dépendre d'un chef inventé.",
  "correct": false,
  "explanation": "« Nous ne dépendons pas d'un chef. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase mêle indéfini et permission de parler ?",
  "options": [
    {
      "text": "Fermez le figuier",
      "correct": false
    },
    {
      "text": "Quiconque a signé peut parler",
      "correct": true
    },
    {
      "text": "Je faut crier",
      "correct": false
    },
    {
      "text": "On dépend à un chef",
      "correct": false
    }
  ],
  "explanation": "Quiconque + 3e pers. + permission."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si / à condition que / pourvu que",
      "right": "conditions"
    },
    {
      "left": "on pourrait / j'aurais dû",
      "right": "atténuation / regret"
    },
    {
      "left": "quiconque / certains / plusieurs",
      "right": "indéfinis"
    },
    {
      "left": "s'attaquer à / veiller à / aboutir à",
      "right": "locutions"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVeillons à ce que le chiffre ___ visible. (rester)",
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
    "Nous",
    "nous",
    "attaquons",
    "à",
    "l'huile",
    "non",
    "aux",
    "personnes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "debattre",
  "hint": "Parler sous le figuier, sans accent, pour aboutir à un article."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quiconque a signé peut parler sous le figuier, et certains n'a pas encore été inscrits.",
  "correct_sentence": "Quiconque a signé peut parler sous le figuier, et certains n'ont pas encore été inscrits.",
  "explanation": "Certains + pluriel : n'ont, pas n'a."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/groupe-agir.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/micro-appel.svg",
      "word": "un appel"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/banderole-demain.svg",
      "word": "une banderole"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/cahier-signatures.svg",
      "word": "des signatures"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez une prise de parole de douze phrases : trois conditions, deux regrets, trois indéfinis, quatre locutions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis votre minute d'assemblée."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma prise de parole sous le figuier',
    'PE',
    $c$Objectif
Écrire une intervention d'assemblée qui réemploie les outils des quatre séquences.

Consigne
Imitez l'intervention de Noura, sans aller trop vite.

Support — Intervention de Noura, assemblée
Noura — prise de parole, assemblée sous le figuier
Si chacun s'exprime, à condition que l'on ne me parle pas par-dessus, je dirai le pont.
Quiconque descend du Figuier 7 a le droit d'être inscrit.
On pourrait ouvrir une demi-heure, pourvu que Hawa tienne l'aube.
J'aurais dû le demander dès la première soif, et Solange aurait dû tamponner une file plus tôt.
À moins que la rivière ne baisse, je n'exige pas un second créneau.
En cas de pénurie, que l'on tamponne une file, non une rumeur.
Nous nous attaquons au tampon muet, non à Solange.
Veillons à ce que l'heure soit dite à la radio.
Cette assemblée aboutira à une motion, si chacun signe encore.
Les mesures que nous avons prises restent fragiles tant que certaines voix du pont n'ont pas été inscrites.
Il faudrait que toutes le soient, plutôt qu'on décide sans nous.
Plusieurs ont déjà porté l'huile. Tout geste compte.
Les clés que nous avons rendues doivent rester au tiroir : quiconque en trouve une la ramène.
Je ne dépends pas d'un chef.
Je dépends de l'eau, du minibus, de votre mémoire.
Que ce soit l'eau ou la salle, chaque article restera distinct.
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Noura exige un second créneau dès cette semaine, quoi qu'il arrive à la rivière.",
  "correct": false,
  "explanation": "À moins que la rivière ne baisse, elle n'exige pas un second créneau."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À quoi Noura dit-elle que l'assemblée s'attaque ?",
  "options": [
    {
      "text": "À Solange en personne",
      "correct": false
    },
    {
      "text": "Au tampon muet, non à Solange",
      "correct": true
    },
    {
      "text": "Au figuier",
      "correct": false
    },
    {
      "text": "Au minibus",
      "correct": false
    }
  ],
  "explanation": "« au tampon muet, non à Solange. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si / à condition que / pourvu que / en cas de",
      "right": "conditions"
    },
    {
      "left": "on pourrait / j'aurais dû",
      "right": "recommandation / regret"
    },
    {
      "left": "quiconque / certaines / plusieurs / tout",
      "right": "indéfinis"
    },
    {
      "left": "s'attaquer à / veiller à / aboutir à / dépendre de",
      "right": "locutions"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes mesures que nous avons ___ restent fragiles.",
  "answer": "prises"
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
    "dépends",
    "pas",
    "d'un",
    "chef",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "intervention",
  "hint": "Prise de parole sous le figuier, avant la motion du Bureau."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous nous attaquons au tampon muet non à Solange, et je dépends encore à votre mémoire.",
  "correct_sentence": "Nous nous attaquons au tampon muet non à Solange, et je dépends encore de votre mémoire.",
  "explanation": "Dépendre de, pas dépendre à."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/micro-appel.svg",
      "word": "un appel"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/banderole-demain.svg",
      "word": "une banderole"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/cahier-signatures.svg",
      "word": "des signatures"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/soleil-agir.svg",
      "word": "un soleil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : seize lignes d'assemblée, conditions, regrets, indéfinis, locutions, un accord COD avant."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre intervention, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Synthèse d''assemblée : quatre boîtes à outils',
    'EL',
    $c$Objectif
Relier condition, conditionnel, indéfinis et locutions pour une prise de parole.

Consigne
Apprenez la fiche.

Support — Fiche de synthèse sous le figuier
Boîte 1 — condition (S1)
si + indicatif / imparfait ; à condition que / pourvu que / à moins que + subj. ; en cas de + nom
Boîte 2 — conscience (S2)
on pourrait, il faudrait, je suggérerais ; j'aurais dû, nous n'aurions pas dû, il aurait fallu
Boîte 3 — indéfinis (S3)
quiconque (+ singulier) ; chacun / chacune ; n'importe quel + nom ; certains ; plusieurs ; tout / tous
Boîte 4 — dénoncer / proposer (S4)
s'attaquer à (le geste) ; veiller à / à ce que ; aboutir à ; dépendre de
Accord : les mesures que nous avons prises ; les lanternes que nous avons éteintes
Que ce soit l'eau ou la salle, chaque article reste distinct. Nuancer ≠ tout égaliser.
On ne dépend pas d'un chef. On aboutit à une motion, pourvu que chacun signe.
Dû invariable devant l'infinitif. Quiconque signe, pas quiconque signent.
Il faut (pas je faut). À + le = au Bureau, au figuier.
Une assemblée tient si les quatre boîtes restent visibles dans la même voix.
Demain : le texte formel au Bureau des Escales.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La fiche autorise « je faut » à l'assemblée.",
  "correct": false,
  "explanation": "Toujours il faut."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle locution introduit le résultat attendu de l'assemblée ?",
  "options": [
    {
      "text": "dépendre à",
      "correct": false
    },
    {
      "text": "aboutir à une motion",
      "correct": true
    },
    {
      "text": "s'attaquer de",
      "correct": false
    },
    {
      "text": "veiller de",
      "correct": false
    }
  ],
  "explanation": "Aboutir à + résultat."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si / pourvu que / en cas de",
      "right": "condition"
    },
    {
      "left": "on pourrait / j'aurais dû",
      "right": "conseil / regret"
    },
    {
      "left": "quiconque / chacun / plusieurs",
      "right": "indéfinis"
    },
    {
      "left": "s'attaquer à / aboutir à",
      "right": "geste / résultat"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCette assemblée aboutira ___ une motion, pourvu que chacun signe.",
  "answer": "à"
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
    "signe",
    "peut",
    "parler",
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
  "word": "boites",
  "hint": "Quatre ensembles d'outils pour une même voix. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quiconque signent encore peut parler, et nous aboutirons à une motion demain.",
  "correct_sentence": "Quiconque signe encore peut parler, et nous aboutirons à une motion demain.",
  "explanation": "Quiconque + 3e pers. singulier : signe."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/banderole-demain.svg",
      "word": "une banderole"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/cahier-signatures.svg",
      "word": "des signatures"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/soleil-agir.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/nuage-si.svg",
      "word": "une hypothèse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau à quatre boîtes : deux phrases modèles dans chacune, prêtes pour l'assemblée."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et une prise de parole de huit phrases, deux par boîte."
}$j$::jsonb,
    9
  );

  -- ===== Motion au Bureau des Escales =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Motion au Bureau des Escales'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Motion au Bureau des Escales', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Préparer le texte formel',
    'CO',
    $c$Objectif
Comprendre les formules d'une motion de cour destinée au Bureau des Escales.

Consigne
Lisez le dialogue. Quelles formules formelles entend-on, et que doit contenir la motion ?

Support — Seuil du Bureau des Escales, plume et tampon
Solange : Une motion formelle n'est pas un cri. Elle s'adresse au Bureau, elle date, elle article, elle signe.
Aline : On écrira : « Le Seuil des Sources, réuni en assemblée sous le figuier, demande que… » Demander que + subjonctif.
Marc : Chaque article commencera par un verbe d'action : ouvrir, cesser, déposer, inscrire, tamponner.
Rose : Il faut s'attaquer aux gestes, non aux noms. Article 1 : l'eau. Article 2 : le soir. Article 3 : les lanternes. Article 4 : la salle.
Hawa : On posera les conditions : à condition que l'aube tienne ; pourvu que Noura soit prévenue ; en cas de pénurie, une file.
Léa : Les mesures que nous avons prises seront rappelées au passé, accordées : prises, éteintes, rendues, tamponnée.
Patrick : Formules : Vu l'enquête ; considérant que vingt voix ont été entendues ; demandons qu'il soit décidé…
Karim : Clôture : « Fait au Seuil des Sources, Rukiri-Nord. » Puis les signatures. Quiconque a parlé peut signer.
Lila : On pourrait atténuer l'article 2 : « il est recommandé que le tambour cesse », plutôt qu'une interdiction sèche.
Joël : À moins que Solange n'exige un article de trop, quatre articles suffisent. Nuancer, ce n'est pas tout fondre.
Yvette : Veuillez agréer, au Bureau, cette motion. Ce n'est pas une lettre d'amour ; c'est une politesse de cour.
Noura : Je veillerai à ce que le minibus apparaisse dans l'article 4. J'aurais dû le demander plus tôt, je le demande aujourd'hui.
Dieudonné : En cas de rejet, on reconvoque. On ne dépend pas d'un silence.
Mado : Titre : Motion n°15 — faire évoluer la cour. Numéro suivant la n°14 des lanternes.
Aline : Formel : vu, considérant, demande que, article, fait à, signatures. Calme : pas de parti, pas de sceau d'État.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Solange dit qu'une motion formelle peut se contenter d'un cri.",
  "correct": false,
  "explanation": "« Une motion formelle n'est pas un cri. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien d'articles Rose veut-elle, et sur quels enjeux ?",
  "options": [
    {
      "text": "Un seul article sur le tambour",
      "correct": false
    },
    {
      "text": "Quatre articles : eau, soir, lanternes, salle",
      "correct": true
    },
    {
      "text": "Dix articles sur un parti",
      "correct": false
    },
    {
      "text": "Aucun article, seulement un slogan",
      "correct": false
    }
  ],
  "explanation": "Eau, soir, lanternes, salle."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "vu / considérant / demande que",
      "right": "formules"
    },
    {
      "left": "article 1 à 4",
      "right": "eau / soir / lanternes / salle"
    },
    {
      "left": "fait au Seuil",
      "right": "clôture"
    },
    {
      "left": "quiconque a parlé",
      "right": "peut signer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe Seuil demande que l'heure ___ dite à la radio. (être)",
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
    "motion",
    "formelle",
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
  "word": "formules",
  "hint": "Vu, considérant, demande que, fait à : ossature du texte officiel."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le Seuil demande que l'heure soit dite à la radio, et quiconque a parlé peuvent signer demain.",
  "correct_sentence": "Le Seuil demande que l'heure soit dite à la radio, et quiconque a parlé peut signer demain.",
  "explanation": "Quiconque + 3e pers. singulier : peut, pas peuvent."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/cahier-signatures.svg",
      "word": "des signatures"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/soleil-agir.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/nuage-si.svg",
      "word": "une hypothèse"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/feuille-motion.svg",
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
  "prompt": "Notez six formules formelles et les quatre articles prévus."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Le Seuil des Sources, réuni en assemblée, demande que l'heure soit dite. Fait au Seuil des Sources, Rukiri-Nord."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Motion-modèle n°15',
    'CE',
    $c$Objectif
Lire une motion formelle qui articule conditions, recommandations et mesures déjà prises.

Consigne
Lisez la motion, sans aller trop vite.

Support — Motion n°15, Bureau des Escales
Motion n°15 — Faire évoluer la cour
Vu l'enquête menée à Rukiri-Nord, considérant que vingt voix ont été entendues, considérant les mesures que nous avons prises,
le Seuil des Sources, réuni en assemblée sous le figuier, demande :
Article 1 — Eau. Qu'une demi-heure supplémentaire soit ouverte, à condition que l'aube tienne, pourvu que ceux du minibus soient prévenus. En cas de pénurie, qu'une file soit tamponnée, non une rumeur. À moins que la rivière ne baisse, pas de second créneau.
Article 2 — Heures calmes. Qu'il soit recommandé que le dernier morceau cesse à vingt et une heures. On pourrait garder la veillée. Personne n'exige que le rite disparaisse.
Article 3 — Lanternes. Que les restes soient déposés dans le panier ocre. Les lanternes que nous avons éteintes trop tard ont marqué l'eau ; nous nous attaquons à l'huile, non aux personnes.
Article 4 — Salle des Herbes. Que quiconque utile puisse inscrire une plage. Que les clés que nous avons rendues restent au tiroir. Veillons à ce que n'importe quel enfant lise l'affiche.
Il aurait fallu certaines de ces lignes plus tôt. Nous les demandons aujourd'hui, afin que la cour évolue.
Fait au Seuil des Sources, Rukiri-Nord.
Signatures : quiconque a parlé à l'assemblée. Tampon : Solange, Bureau des Escales.
Cette motion n'est pas un décret d'État. C'est un texte de cour, formel et calme.
Copie : Cahier des racines, Radio Figuier.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'article 2 exige que la veillée disparaisse.",
  "correct": false,
  "explanation": "« Personne n'exige que le rite disparaisse. » On pourrait garder la veillée."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que prévoit l'article 1 en cas de pénurie ?",
  "options": [
    {
      "text": "Un second créneau immédiat",
      "correct": false
    },
    {
      "text": "Une file tamponnée, non une rumeur",
      "correct": true
    },
    {
      "text": "La fermeture du figuier",
      "correct": false
    },
    {
      "text": "Un sceau d'État",
      "correct": false
    }
  ],
  "explanation": "File tamponnée, pas de rumeur."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "article 1",
      "right": "demi-heure / file"
    },
    {
      "left": "article 2",
      "right": "recommandation d'heure"
    },
    {
      "left": "article 3",
      "right": "panier / huile"
    },
    {
      "left": "article 4",
      "right": "plage / clés / affiche"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe Seuil demande qu'une demi-heure supplémentaire ___ ouverte. (être)",
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
    "Fait",
    "au",
    "Seuil",
    "des",
    "Sources",
    "Rukiri-Nord",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "articles",
  "hint": "Quatre parties de la motion : eau, soir, lanternes, salle."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le Seuil demande qu'une demi-heure soit ouverte, et les lanternes que nous avons eteint iront au panier.",
  "correct_sentence": "Le Seuil demande qu'une demi-heure soit ouverte, et les lanternes que nous avons éteintes iront au panier.",
  "explanation": "Lanternes, COD avant → éteintes."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/soleil-agir.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/nuage-si.svg",
      "word": "une hypothèse"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/feuille-motion.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/coeur-citoyen.svg",
      "word": "un cœur citoyen"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la motion et soulignez formules, conditions, accords et indéfinis."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la motion-modèle, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire les formules de la motion',
    'PO',
    $c$Objectif
Prononcer à l'oral les formules formelles et les quatre articles.

Consigne
Répétez, puis dictez un article formel sur l'enjeu de votre choix.

Support — Modèles de Solange et d'Aline
Vu l'enquête menée à Rukiri-Nord,
considérant que vingt voix ont été entendues,
le Seuil des Sources demande que l'heure soit dite.
Article 1 : qu'une demi-heure soit ouverte, à condition que l'aube tienne.
Article 2 : qu'il soit recommandé que le tambour cesse.
Article 3 : que les restes soient déposés dans le panier.
Article 4 : que quiconque utile puisse inscrire une plage.
Fait au Seuil des Sources, Rukiri-Nord.
Veuillez agréer cette motion, au Bureau des Escales.
Nous nous attaquons aux gestes, non aux noms.
Les mesures que nous avons prises sont rappelées.
Quiconque a parlé peut signer.
Aline : le formel n'est pas froid ; il protège la cour d'un cri.
Solange : un tampon suit une signature, il ne la remplace pas.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La clôture « Fait au Seuil des Sources » date et situe le texte.",
  "correct": true,
  "explanation": "Formule de clôture de cour."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle ouverture est formelle ?",
  "options": [
    {
      "text": "Salut les amis on crie",
      "correct": false
    },
    {
      "text": "Vu l'enquête menée à Rukiri-Nord",
      "correct": true
    },
    {
      "text": "Je faut un tampon",
      "correct": false
    },
    {
      "text": "Pas de titre",
      "correct": false
    }
  ],
  "explanation": "Vu + considérant + demande que."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "vu / considérant",
      "right": "ouverture"
    },
    {
      "left": "demande que / qu'il soit",
      "right": "articles au subj."
    },
    {
      "left": "fait au Seuil",
      "right": "clôture"
    },
    {
      "left": "veuillez agréer",
      "right": "politesse de Bureau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVeuillez ___ cette motion au Bureau. (agréer)",
  "answer": "agréer"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Fait",
    "au",
    "Seuil",
    "des",
    "Sources",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tamponner",
  "hint": "Marquer la motion au Bureau, après les signatures, sans crier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le Seuil demande que l'heure est dite demain, et veuillez agréer cette motion au Bureau.",
  "correct_sentence": "Le Seuil demande que l'heure soit dite demain, et veuillez agréer cette motion au Bureau.",
  "explanation": "Demander que + subjonctif : soit, pas est."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/nuage-si.svg",
      "word": "une hypothèse"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/feuille-motion.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/coeur-citoyen.svg",
      "word": "un cœur citoyen"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/bilan-condition.svg",
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
  "prompt": "Écrivez les formules d'ouverture et de clôture, puis quatre articles d'une ligne."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les formules vu / considérant / demande que / fait au Seuil, puis un article à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma motion au Bureau',
    'PE',
    $c$Objectif
Écrire une motion formelle de cour, datée, articulée, signée.

Consigne
Imitez la motion de Marc Nkurunziza, sans aller trop vite.

Support — Motion de Marc, pour Solange
Motion n°15 — Faire évoluer la cour (version Marc)
Vu l'enquête ouverte à Rukiri-Nord, considérant que vingt voix ont été entendues, considérant les mesures que nous avons prises,
le Seuil des Sources, réuni sous le figuier, demande :
Article 1. Qu'une demi-heure soit ouverte à l'eau, à condition que l'aube tienne, pourvu que Noura soit prévenue.
En cas de pénurie, qu'une file soit tamponnée. À moins que la rivière ne baisse, pas de second créneau.
Article 2. Qu'il soit recommandé que le dernier morceau cesse à vingt et une heures.
J'aurais dû l'écrire plus tôt ; je l'écris aujourd'hui. On pourrait garder la veillée.
Article 3. Que les restes soient portés au panier ocre.
Nous nous attaquons à l'huile, non aux personnes.
Les lanternes que nous avons éteintes trop tard ont été nommées.
Article 4. Que quiconque utile inscrive une plage à la Salle des Herbes.
Que les clés que nous avons rendues restent au tiroir.
Veillons à ce que n'importe quel enfant lise l'affiche.
Cette assemblée aboutira à ce texte, si chacun signe.
Nous ne dépendons pas d'un chef ; nous dépendons de l'eau et de la mémoire.
Fait au Seuil des Sources, Rukiri-Nord.
Veuillez agréer, au Bureau des Escales, cette motion de cour.
Elle n'est pas un décret d'État.
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc présente la motion comme un décret d'État.",
  "correct": false,
  "explanation": "« Elle n'est pas un décret d'État. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que rappelle Marc à l'article 2, au conditionnel passé ?",
  "options": [
    {
      "text": "Qu'il aurait dû l'écrire plus tôt",
      "correct": true
    },
    {
      "text": "Qu'il vendra le figuier",
      "correct": false
    },
    {
      "text": "Qu'il interdira Hawa",
      "correct": false
    },
    {
      "text": "Qu'il cassera le tampon",
      "correct": false
    }
  ],
  "explanation": "« J'aurais dû l'écrire plus tôt ; je l'écris aujourd'hui. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "vu / considérant",
      "right": "ouverture"
    },
    {
      "left": "articles 1 à 4",
      "right": "eau / soir / lanternes / salle"
    },
    {
      "left": "fait au Seuil",
      "right": "clôture"
    },
    {
      "left": "veuillez agréer",
      "right": "Bureau des Escales"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nFait ___ Seuil des Sources, Rukiri-Nord.",
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
    "Veuillez",
    "agréer",
    "cette",
    "motion",
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
  "word": "officielle",
  "hint": "Qualité du texte : daté, articulé, signé, tamponné, sans cri."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le Seuil demande qu'une demi-heure soit ouverte, et les mesures que nous avons pris seront rappelées.",
  "correct_sentence": "Le Seuil demande qu'une demi-heure soit ouverte, et les mesures que nous avons prises seront rappelées.",
  "explanation": "Mesures, COD avant → prises."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/feuille-motion.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/coeur-citoyen.svg",
      "word": "un cœur citoyen"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/bilan-condition.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/si-imparfait.svg",
      "word": "une condition"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : motion formelle de seize lignes, vu / considérant / quatre articles / fait à / signatures."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre motion, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Motion formelle : ossature et réemploi',
    'EL',
    $c$Objectif
Retenir l'ossature du texte formel et le réemploi des outils pour faire évoluer la cour.

Consigne
Apprenez la fiche.

Support — Fiche de Solange, motion au Bureau
Ossature
Titre + numéro (Motion n°15). Vu + fait. Considérant que + indicatif (vingt voix ont été entendues).
Le Seuil demande que / qu'il soit + subjonctif. Articles numérotés, un enjeu chacun.
Fait à + lieu. Signatures. Tampon du Bureau des Escales. Veuillez agréer…
Réemploi
Condition : à condition que, pourvu que, à moins que, en cas de, si.
Atténuation / regret : on pourrait, il est recommandé que, j'aurais dû.
Indéfinis : quiconque, chacun, n'importe quel, certains, plusieurs, tout.
Locutions : s'attaquer à, veiller à ce que, aboutir à, dépendre de.
Accord : les mesures que nous avons prises ; les clés que nous avons rendues.
Formel ≠ froid. Formel ≠ décret d'État. Formel = calme + lisible + signé.
On ne fond pas les quatre articles. On ne crie pas un parti. On ne dit pas je faut.
À + le = au Bureau, au Seuil. De + le = du Cahier des racines.
Faire évoluer la société, ici, c'est faire évoluer la cour : eau, soir, lanternes, salle.
Si chacun signe, pourvu que Solange tamponne, le texte tiendra jusqu'à la prochaine assemblée.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La fiche confond motion de cour et décret d'État.",
  "correct": false,
  "explanation": "Formel ≠ décret d'État. Formel = calme + lisible + signé."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel ordre d'ossature est proposé ?",
  "options": [
    {
      "text": "cri, injure, silence",
      "correct": false
    },
    {
      "text": "titre, vu, considérant, demande que, articles, fait à, signatures",
      "correct": true
    },
    {
      "text": "signatures d'abord, puis rien",
      "correct": false
    },
    {
      "text": "un seul slogan sans article",
      "correct": false
    }
  ],
  "explanation": "Ossature de la fiche."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "vu / considérant",
      "right": "ouverture"
    },
    {
      "left": "demande que + subj.",
      "right": "corps"
    },
    {
      "left": "articles distincts",
      "right": "quatre enjeux"
    },
    {
      "left": "fait à / signatures / tampon",
      "right": "clôture"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe Seuil demande qu'il ___ recommandé de cesser à l'heure. (être)",
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
    "Fait",
    "au",
    "Seuil",
    "des",
    "Sources",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ossature",
  "hint": "Squelette du texte formel : vu, articles, fait à, signatures."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le Seuil demande que l'heure soit dite, et nous dépendons encore à un silence du Bureau.",
  "correct_sentence": "Le Seuil demande que l'heure soit dite, et nous dépendons encore d'un silence du Bureau.",
  "explanation": "Dépendre de, pas dépendre à."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m6/coeur-citoyen.svg",
      "word": "un cœur citoyen"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/bilan-condition.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/si-imparfait.svg",
      "word": "une condition"
    },
    {
      "image_path": "/elearning/mfk-b2-m6/assemblee-figuier.svg",
      "word": "une assemblée"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez l'ossature vide (titre, vu, considérant, quatre articles, fait à) avec une phrase modèle chacune."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et une mini-motion de six phrases formelles."
}$j$::jsonb,
    9
  );

END;
$$;
