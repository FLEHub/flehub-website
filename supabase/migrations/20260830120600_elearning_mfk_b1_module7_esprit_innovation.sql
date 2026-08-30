/*
  Seed eLearning MFK — B1 — L'esprit d'innovation

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b1-m7/
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
  v_module_title text := 'B1 — L''esprit d''innovation';
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
      'Grande étape B1-7 : présenter un talent, expliquer une découverte, argumenter pas à pas, imaginer demain, tester un prototype et pitcher devant la cour — Lila, Dieudonné et Karim inventent la Lampe-Figue et le Filtre des Herbes sous le figuier, au Seuil des Sources (Rukiri-Nord).',
      'B1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B1-7 : présenter un talent, expliquer une découverte, argumenter pas à pas, imaginer demain, tester un prototype et pitcher devant la cour — Lila, Dieudonné et Karim inventent la Lampe-Figue et le Filtre des Herbes sous le figuier, au Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'B1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Des talents à découvrir =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Des talents à découvrir'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Des talents à découvrir', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Trois talents sous le figuier',
    'CO',
    $c$Objectif
Présenter une innovation et des jeunes talents ; relatifs composés.

Consigne
Lisez le dialogue. À qui, duquel, avec lequel : qui invente quoi ?

Support — Ombre du figuier, banc de test
Lila : Voici le projet auquel je pense depuis la saison sèche : une lanterne.
Karim : C'est l'idée à laquelle on revient chaque soir. On l'appelle Lampe-Figue.
Dieudonné : Voici l'arbre sous lequel on travaille, et l'outil avec lequel je coupe.
Aline : Les jeunes auxquels on s'adresse savent déjà mesurer.
Patrick : Le filtre duquel on parle nettoie l'eau de la rive.
Hawa : La rive de laquelle l'eau vient s'appelle encore Rive d'Orage.
Joël : Les outils desquels Dieudonné a besoin sont simples : fil, verre, tissu.
Rose : La lampe à laquelle Lila travaille charge au soleil.
Marc : Le banc sur lequel on pose le prototype est ocre.
Solange : Le dossier auquel le Bureau s'intéresse reste ouvert.
Mado : Les stands devant lesquels on expliquera sont au Marché des Lampions.
Sami : Le rythme avec lequel je soutiens l'atelier, c'est trois frappes.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le projet auquel Lila pense est une lanterne.",
  "correct": true,
  "explanation": "Lila : « le projet auquel je pense… une lanterne. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment appelle-t-on la lanterne ?",
  "options": [
    {
      "text": "Filtre des Herbes",
      "correct": false
    },
    {
      "text": "Lampe-Figue",
      "correct": true
    },
    {
      "text": "Feuille du Seuil",
      "correct": false
    },
    {
      "text": "Radio Figuier",
      "correct": false
    }
  ],
  "explanation": "Karim : « On l'appelle Lampe-Figue. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "auquel",
      "right": "projet / penser à"
    },
    {
      "left": "à laquelle",
      "right": "idée / revenir à"
    },
    {
      "left": "duquel",
      "right": "filtre / parler de"
    },
    {
      "left": "avec lequel",
      "right": "outil / couper"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVoici le projet ___ je pense depuis la saison sèche.",
  "answer": "auquel"
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
    "le",
    "filtre",
    "duquel",
    "on",
    "parle",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "auquel",
  "hint": "Penser à + projet masculin : le pronom…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voici le projet que je pense depuis la saison sèche.",
  "correct_sentence": "Voici le projet auquel je pense depuis la saison sèche.",
  "explanation": "Penser à → auquel."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/relatif-compose.svg",
      "word": "un relatif"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/jeune-talent.svg",
      "word": "un talent"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/presentation-inno.svg",
      "word": "une présentation"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/lampe-figue.svg",
      "word": "une lampe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez six relatifs composés et le verbe qui les appelle."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : le projet auquel je pense ; l'idée à laquelle on revient ; le filtre duquel on parle ; l'outil avec lequel je coupe."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Portraits inventeurs',
    'CE',
    $c$Objectif
Lire trois portraits de talents et leurs relatifs composés.

Consigne
Lisez les portraits, sans aller trop vite.

Support — Cahier du chemin, page ocre
Portrait Lila Sow
Voix de Radio Figuier. La lanterne à laquelle elle travaille s'appelle Lampe-Figue.
C'est le soleil grâce auquel le verre chauffe le petit fil.
Portrait Dieudonné
Atelier du Tissu. Les outils desquels il a besoin tiennent dans un sac.
C'est le figuier sous lequel il pose le banc de test.
Portrait Karim
Il note l'idée à laquelle le groupe revient. Il dessine le filtre duquel on parle.
Les jeunes auxquels Aline s'adresse peuvent répéter le schéma.
La rive de laquelle l'eau trouble arrive n'est pas loin.
Le dossier auquel Solange pense restera au Bureau des Escales.
Trois talents, deux objets : Lampe-Figue et Filtre des Herbes.
Seuil des Sources — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné range ses outils dans un coffre de pierre.",
  "correct": false,
  "explanation": "« tiennent dans un sac. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Grâce à quoi le verre de la lanterne chauffe-t-il le fil ?",
  "options": [
    {
      "text": "la rivière",
      "correct": false
    },
    {
      "text": "le soleil",
      "correct": true
    },
    {
      "text": "le tambour",
      "correct": false
    },
    {
      "text": "le marché",
      "correct": false
    }
  ],
  "explanation": "« le soleil grâce auquel le verre chauffe. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "à laquelle",
      "right": "lanterne / Lila"
    },
    {
      "left": "desquels",
      "right": "outils / Dieudonné"
    },
    {
      "left": "duquel",
      "right": "filtre / Karim"
    },
    {
      "left": "auxquels",
      "right": "jeunes / Aline"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes outils ___ il a besoin tiennent dans un sac.",
  "answer": "desquels"
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
    "le",
    "figuier",
    "sous",
    "lequel",
    "il",
    "pose",
    "le",
    "banc",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "desquels",
  "hint": "Avoir besoin de + outils pluriels."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les outils que Dieudonné a besoin tiennent dans un sac.",
  "correct_sentence": "Les outils desquels il a besoin tiennent dans un sac.",
  "explanation": "Avoir besoin de → desquels."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/jeune-talent.svg",
      "word": "un talent"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/presentation-inno.svg",
      "word": "une présentation"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/lampe-figue.svg",
      "word": "une lampe"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/expliquer-decouverte.svg",
      "word": "une explication"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez un portrait et encadrez les relatifs composés."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les trois portraits, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire auquel, duquel, avec lequel',
    'PO',
    $c$Objectif
Présenter un talent à l'oral avec des relatifs composés.

Consigne
Répétez, puis présentez un objet de la cour.

Support — Modèles d'Aline
Le projet auquel je pense est simple.
L'idée à laquelle on revient s'appelle Lampe-Figue.
Le filtre duquel on parle tient dans une calebasse.
La rive de laquelle l'eau vient est haute.
Les outils desquels il a besoin sont là.
Les jeunes auxquels on s'adresse écoutent.
L'outil avec lequel je coupe est net.
Le banc sur lequel on pose la lampe est stable.
C'est un talent de la cour.
Ce n'est pas un secret d'ailleurs.
On montre. On nomme. On relie.
On n'invente pas un pronom au hasard.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Parler de » appelle souvent duquel / de laquelle / desquels.",
  "correct": true,
  "explanation": "Le filtre duquel on parle."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Penser à un projet » → le projet…",
  "options": [
    {
      "text": "que je pense",
      "correct": false
    },
    {
      "text": "dont je pense à",
      "correct": false
    },
    {
      "text": "auquel je pense",
      "correct": true
    },
    {
      "text": "qui je pense",
      "correct": false
    }
  ],
  "explanation": "Penser à → auquel."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "penser à",
      "right": "auquel"
    },
    {
      "left": "parler de",
      "right": "duquel"
    },
    {
      "left": "avoir besoin de",
      "right": "desquels"
    },
    {
      "left": "couper avec",
      "right": "avec lequel"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'outil ___ lequel je coupe est net.",
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
    "Le",
    "projet",
    "auquel",
    "je",
    "pense",
    "est",
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
  "word": "laquelle",
  "hint": "Revenir à + idée féminin : à…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "L'idée que on revient chaque soir s'appelle Lampe-Figue.",
  "correct_sentence": "L'idée à laquelle on revient s'appelle Lampe-Figue.",
  "explanation": "Revenir à → à laquelle."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/presentation-inno.svg",
      "word": "une présentation"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/lampe-figue.svg",
      "word": "une lampe"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/expliquer-decouverte.svg",
      "word": "une explication"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/schema-simple.svg",
      "word": "un schéma"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit relatives : auquel, à laquelle, duquel, desquels, auxquels, avec lequel."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis deux portraits à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon portrait de talent',
    'PE',
    $c$Objectif
Écrire la présentation d'un talent et d'une innovation.

Consigne
Imitez le portrait de Karim, sans aller trop vite.

Support — Portrait de Karim, Cahier du chemin
Karim
Le projet auquel je m'accroche s'appelle Filtre des Herbes.
C'est l'eau de laquelle la cour a besoin après la crue.
L'idée à laquelle Lila m'a lié, c'est aussi la Lampe-Figue.
Les fils desquels Dieudonné a besoin passent dans le verre.
Les jeunes auxquels on montrera le schéma pourront répéter.
L'arbre sous lequel on teste reste le figuier du Seuil.
Je n'emprunte aucun nom d'ailleurs. Tout est né ici.
Karim
Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Karim emprunte un nom d'une ville lointaine.",
  "correct": false,
  "explanation": "« Je n'emprunte aucun nom d'ailleurs. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "De quoi la cour a-t-elle besoin après la crue ?",
  "options": [
    {
      "text": "d'un tambour",
      "correct": false
    },
    {
      "text": "de l'eau",
      "correct": true
    },
    {
      "text": "d'un titre",
      "correct": false
    },
    {
      "text": "d'une rumeur",
      "correct": false
    }
  ],
  "explanation": "« l'eau de laquelle la cour a besoin. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "auquel",
      "right": "projet / filtre"
    },
    {
      "left": "de laquelle",
      "right": "eau"
    },
    {
      "left": "desquels",
      "right": "fils"
    },
    {
      "left": "auxquels",
      "right": "jeunes"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe projet ___ je m'accroche s'appelle Filtre des Herbes.",
  "answer": "auquel"
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
    "est",
    "né",
    "ici",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "accroche",
  "hint": "Karim s'y… : le projet ne le lâche pas."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le projet que je m'accroche s'appelle Filtre des Herbes.",
  "correct_sentence": "Le projet auquel je m'accroche s'appelle Filtre des Herbes.",
  "explanation": "S'accrocher à → auquel."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/lampe-figue.svg",
      "word": "une lampe"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/expliquer-decouverte.svg",
      "word": "une explication"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/schema-simple.svg",
      "word": "un schéma"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/filtre-herbes.svg",
      "word": "un filtre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six relatives composées, deux objets du Seuil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre portrait, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Pronoms relatifs composés',
    'EL',
    $c$Objectif
Retenir auquel, à laquelle, duquel, de laquelle, desquels, auxquels, avec lequel.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
À + lequel
auquel (m.s.) à laquelle (f.s.) auxquels (m.p.) auxquelles (f.p.)
penser à, s'intéresser à, s'accrocher à, s'adresser à
De + lequel
duquel de laquelle desquels desquelles
parler de, avoir besoin de, venir de
Autres prépositions
avec lequel / avec laquelle ; sous lequel ; sur lequel ; grâce auquel
On n'écrit pas : le projet que je pense (penser à).
On n'écrit pas : les outils que j'ai besoin (besoin de).
Dont peut remplacer duquel parfois : le filtre dont on parle.
Au Seuil : Lampe-Figue, Filtre des Herbes, figuier, banc de test.
Relier le nom et la préposition du verbe : voilà le geste.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« S'adresser à » appelle auxquels / à laquelle, pas que.",
  "correct": true,
  "explanation": "Les jeunes auxquels on s'adresse."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Avoir besoin des outils » → les outils…",
  "options": [
    {
      "text": "que j'ai besoin",
      "correct": false
    },
    {
      "text": "dont j'ai besoin à",
      "correct": false
    },
    {
      "text": "desquels j'ai besoin",
      "correct": true
    },
    {
      "text": "à lesquels j'ai besoin",
      "correct": false
    }
  ],
  "explanation": "Besoin de → desquels."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "auquel",
      "right": "penser à"
    },
    {
      "left": "duquel",
      "right": "parler de"
    },
    {
      "left": "desquels",
      "right": "besoin de"
    },
    {
      "left": "avec lequel",
      "right": "couper avec"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes jeunes ___ on s'adresse écoutent.",
  "answer": "auxquels"
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
    "filtre",
    "dont",
    "on",
    "parle",
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
  "word": "preposition",
  "hint": "À, de, avec : elle appelle le composé (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les jeunes que on s'adresse écoutent sous le figuier.",
  "correct_sentence": "Les jeunes auxquels on s'adresse écoutent.",
  "explanation": "S'adresser à → auxquels."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/expliquer-decouverte.svg",
      "word": "une explication"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/schema-simple.svg",
      "word": "un schéma"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/filtre-herbes.svg",
      "word": "un filtre"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/main-prototype.svg",
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
  "prompt": "Tableau : verbe + préposition + relatif, huit lignes."
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

  -- ===== Expliquer une découverte =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Expliquer une découverte'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Expliquer une découverte', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — On appelle ça, cela permet de',
    'CO',
    $c$Objectif
Expliquer simplement une innovation.

Consigne
Lisez le dialogue. Comment dit-on le nom et l'usage ?

Support — Atelier sous le figuier
Karim : On appelle ça une Lampe-Figue. Ce n'est pas une étoile.
Lila : Cela permet de lire le Cahier du chemin après le crépuscule.
Dieudonné : On appelle ça un Filtre des Herbes. Le tissu retient le trouble.
Aline : Cela permet de verser une eau plus claire dans la calebasse.
Patrick : On n'appelle pas ça une machine d'ailleurs. C'est un prototype du Seuil.
Hawa : Cela permet de réduire la peur quand la rive est haute.
Joël : On appelle ça un banc de test. On y pose la lampe.
Rose : Cela permet de voir si le fil tient trois soirs.
Marc : Expliquer, c'est dire le nom, le geste, le bénéfice.
Solange : Cela permet au Bureau de comprendre sans dessin compliqué.
Mado : On appelle ça aussi une lanterne solaire, si l'on veut simple.
Sami : Cela permet de tenir une veillée sans crier au marché.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Karim dit que la Lampe-Figue est une étoile.",
  "correct": false,
  "explanation": "« Ce n'est pas une étoile. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que permet la Lampe-Figue, selon Lila ?",
  "options": [
    {
      "text": "de fermer Radio Figuier",
      "correct": false
    },
    {
      "text": "de lire après le crépuscule",
      "correct": true
    },
    {
      "text": "de vendre le figuier",
      "correct": false
    },
    {
      "text": "d'inventer une rumeur",
      "correct": false
    }
  ],
  "explanation": "« Cela permet de lire le Cahier du chemin après le crépuscule. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on appelle ça",
      "right": "donner le nom"
    },
    {
      "left": "cela permet de",
      "right": "dire l'usage"
    },
    {
      "left": "Lampe-Figue",
      "right": "lire le soir"
    },
    {
      "left": "Filtre des Herbes",
      "right": "eau plus claire"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ___ ça une Lampe-Figue.",
  "answer": "appelle"
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
    "permet",
    "de",
    "lire",
    "après",
    "le",
    "crépuscule",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "prototype",
  "hint": "Patrick : ce n'est pas une machine d'ailleurs, c'est un…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On appelle ça de lire après le crépuscule.",
  "correct_sentence": "Cela permet de lire le Cahier du chemin après le crépuscule.",
  "explanation": "On appelle ça + nom. Cela permet de + infinitif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/schema-simple.svg",
      "word": "un schéma"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/filtre-herbes.svg",
      "word": "un filtre"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/main-prototype.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/progression-chrono.svg",
      "word": "une progression"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez quatre « on appelle ça » et quatre « cela permet de »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On appelle ça une Lampe-Figue. Cela permet de lire après le crépuscule."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fiche découverte',
    'CE',
    $c$Objectif
Lire une explication simple des deux objets.

Consigne
Lisez la fiche, sans aller trop vite.

Support — Schéma de Karim, feuille ocre
Deux découvertes sous le figuier
1. On appelle ça Lampe-Figue.
Cela permet de garder une lueur sur le banc sans feu de paille.
Le verre, le fil, le soleil : trois gestes.
2. On appelle ça Filtre des Herbes.
Cela permet de retenir le trouble de la rive avant de boire.
Le tissu de Dieudonné, la calebasse, la patience : trois gestes.
Comment expliquer
On donne le nom. On montre. On dit cela permet de + verbe.
On évite les mots d'ailleurs. On reste au Seuil.
Aline : une phrase courte vaut mieux qu'un discours.
Lila : on peut le dire à Radio Figuier en une minute.
Solange : le Bureau comprend si le bénéfice est clair.
Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La Lampe-Figue sert à faire un feu de paille.",
  "correct": false,
  "explanation": "« sans feu de paille. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de gestes pour le filtre ?",
  "options": [
    {
      "text": "un",
      "correct": false
    },
    {
      "text": "deux",
      "correct": false
    },
    {
      "text": "trois",
      "correct": true
    },
    {
      "text": "dix",
      "correct": false
    }
  ],
  "explanation": "Tissu, calebasse, patience."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Lampe-Figue",
      "right": "lueur / banc"
    },
    {
      "left": "Filtre des Herbes",
      "right": "trouble / rive"
    },
    {
      "left": "on appelle ça",
      "right": "nom"
    },
    {
      "left": "cela permet de",
      "right": "usage"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCela permet de retenir le ___ de la rive.",
  "answer": "trouble"
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
    "donne",
    "le",
    "nom",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "calebasse",
  "hint": "On y verse l'eau après le tissu."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Cela permet ça Filtre des Herbes pour retenir le trouble.",
  "correct_sentence": "On appelle ça Filtre des Herbes. Cela permet de retenir le trouble.",
  "explanation": "Nom d'un côté, usage de l'autre."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/filtre-herbes.svg",
      "word": "un filtre"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/main-prototype.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/progression-chrono.svg",
      "word": "une progression"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/opinion-concept.svg",
      "word": "une opinion"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la fiche et ajoutez un troisième objet inventé au Seuil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les deux découvertes, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Expliquer en une minute',
    'PO',
    $c$Objectif
Présenter une innovation à l'oral avec on appelle ça / cela permet de.

Consigne
Répétez, puis expliquez un objet de la cour.

Support — Modèles de Lila
On appelle ça une Lampe-Figue.
Cela permet de lire le soir.
On appelle ça un Filtre des Herbes.
Cela permet de clarifier l'eau.
On montre le verre. On montre le tissu.
Le geste est simple. Le bénéfice est clair.
Ce n'est pas une étoile. Ce n'est pas une machine d'ailleurs.
C'est un prototype du Seuil.
Je dis le nom. Je dis l'usage. Je m'arrête.
Je n'ajoute pas de peur. Je n'ajoute pas de rumeur.
Une minute suffit.
Radio Figuier peut le reprendre.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila conseille d'ajouter une rumeur pour intéresser.",
  "correct": false,
  "explanation": "« Je n'ajoute pas de rumeur. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle durée Lila vise-t-elle ?",
  "options": [
    {
      "text": "huit minutes",
      "correct": false
    },
    {
      "text": "une heure",
      "correct": false
    },
    {
      "text": "une minute",
      "correct": true
    },
    {
      "text": "un jour",
      "correct": false
    }
  ],
  "explanation": "« Une minute suffit. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on appelle ça",
      "right": "nom"
    },
    {
      "left": "cela permet de",
      "right": "usage"
    },
    {
      "left": "prototype",
      "right": "Seuil"
    },
    {
      "left": "une minute",
      "right": "durée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCela permet de ___ l'eau.",
  "answer": "clarifier"
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
    "minute",
    "suffit",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "clarifier",
  "hint": "Le filtre le fait : rendre l'eau moins trouble."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On appelle ça de clarifier l'eau le soir sous le figuier.",
  "correct_sentence": "On appelle ça un Filtre des Herbes. Cela permet de clarifier l'eau.",
  "explanation": "On appelle ça + nom."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/main-prototype.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/progression-chrono.svg",
      "word": "une progression"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/opinion-concept.svg",
      "word": "une opinion"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/dabord-ensuite.svg",
      "word": "d'abord ensuite"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez deux explications d'une minute : nom, geste, bénéfice."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis une explication chronométrée."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma fiche d''innovation',
    'PE',
    $c$Objectif
Écrire une explication simple d'une découverte.

Consigne
Imitez la fiche de Dieudonné, sans aller trop vite.

Support — Fiche de Dieudonné, Atelier du Tissu
Dieudonné
On appelle ça une Lampe-Figue.
Cela permet de poser une lueur sur le banc de test.
On appelle ça aussi un Filtre des Herbes.
Cela permet de passer l'eau trouble à travers mon tissu ocre.
Je montre le fil. Je montre le verre. Je montre le soleil.
Je ne dis pas de mot d'ailleurs. Je reste sous le figuier.
Le bénéfice : lire, verser, moins craindre la nuit et la rive.
Dieudonné
Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné refuse de montrer le fil.",
  "correct": false,
  "explanation": "« Je montre le fil. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "De quelle couleur est le tissu du filtre ?",
  "options": [
    {
      "text": "bleu",
      "correct": false
    },
    {
      "text": "ocre",
      "correct": true
    },
    {
      "text": "noir",
      "correct": false
    },
    {
      "text": "blanc de neige",
      "correct": false
    }
  ],
  "explanation": "« mon tissu ocre. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Lampe-Figue",
      "right": "lueur / banc"
    },
    {
      "left": "Filtre des Herbes",
      "right": "tissu ocre"
    },
    {
      "left": "on appelle ça",
      "right": "nom"
    },
    {
      "left": "cela permet de",
      "right": "usage"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ___ ça une Lampe-Figue.",
  "answer": "appelle"
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
    "montre",
    "le",
    "verre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "benefice",
  "hint": "Lire, verser, moins craindre (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Cela permet ça une Lampe-Figue sur le banc de test.",
  "correct_sentence": "On appelle ça une Lampe-Figue. Cela permet de poser une lueur sur le banc.",
  "explanation": "Nom puis usage."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/progression-chrono.svg",
      "word": "une progression"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/opinion-concept.svg",
      "word": "une opinion"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/dabord-ensuite.svg",
      "word": "d'abord ensuite"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/cahier-argument.svg",
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
  "prompt": "Imitez : deux noms, deux usages, trois gestes, un bénéfice."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre fiche, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — On appelle ça / cela permet de',
    'EL',
    $c$Objectif
Retenir les formules pour présenter une innovation.

Consigne
Apprenez la fiche.

Support — Fiche courte
Donner le nom
On appelle ça + nom : On appelle ça une Lampe-Figue.
Présenter = dire le nom sans copier ailleurs.
Dire l'usage
Cela permet de + infinitif : Cela permet de lire le soir.
Cela permet de clarifier l'eau.
Montrer
Je montre le verre, le fil, le tissu.
Ordre utile : nom → geste → bénéfice.
On n'écrit pas : on appelle ça de lire.
On n'écrit pas : cela permet ça une lampe.
Une minute à Radio Figuier suffit.
Mots du Seuil seulement : figuier, rive, calebasse, banc de test.
Innovation = un geste nouveau pour un besoin de la cour.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« On appelle ça » est suivi d'un nom.",
  "correct": true,
  "explanation": "On appelle ça une Lampe-Figue."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Après « cela permet », on met…",
  "options": [
    {
      "text": "un adjectif seul",
      "correct": false
    },
    {
      "text": "de + infinitif",
      "correct": true
    },
    {
      "text": "un subjonctif obligatoire",
      "correct": false
    },
    {
      "text": "un passif",
      "correct": false
    }
  ],
  "explanation": "Cela permet de + verbe."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on appelle ça",
      "right": "nom"
    },
    {
      "left": "cela permet de",
      "right": "usage"
    },
    {
      "left": "je montre",
      "right": "geste"
    },
    {
      "left": "bénéfice",
      "right": "lire / verser"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCela permet ___ lire le soir.",
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
    "appelle",
    "ça",
    "une",
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
  "word": "innovation",
  "hint": "Un geste nouveau pour un besoin de la cour."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On appelle ça de lire le soir sous le figuier.",
  "correct_sentence": "On appelle ça une Lampe-Figue. Cela permet de lire le soir.",
  "explanation": "Nom ≠ usage."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/opinion-concept.svg",
      "word": "une opinion"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/dabord-ensuite.svg",
      "word": "d'abord ensuite"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/cahier-argument.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/doute-certitude.svg",
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
  "prompt": "Inventez quatre objets du Seuil : nom + cela permet de."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six phrases modèles."
}$j$::jsonb,
    9
  );

  -- ===== Argumenter pas à pas =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Argumenter pas à pas'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Argumenter pas à pas', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — D''abord la lampe, ensuite le filtre',
    'CO',
    $c$Objectif
Suivre un argument : concept, opinion, progression chronologique.

Consigne
Lisez le dialogue. Quels mots d'ordre entendez-vous ?

Support — Cahier d'argument, banc ocre
Karim : D'abord, le concept : une lueur sans feu de paille.
Lila : Ensuite, mon opinion : la cour en a besoin pour le Cahier du chemin.
Dieudonné : Par ailleurs, le filtre répond à la rive trouble.
Aline : En outre, les gestes restent simples : fil, verre, tissu.
Patrick : En conclusion, ce sont des talents de chez nous, pas d'ailleurs.
Hawa : D'abord j'écoute le concept. Ensuite je donne mon avis.
Joël : Par ailleurs, le banc de test est déjà là.
Rose : En outre, Radio Figuier peut expliquer en une minute.
Marc : En conclusion, je suis pour les deux prototypes.
Solange : D'abord le dossier. Ensuite la démonstration sous le figuier.
Mado : Par ailleurs, le marché voudra voir, pas seulement entendre.
Sami : En conclusion, je frapperai trois fois à l'ouverture du pitch.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick dit que les talents viennent d'ailleurs.",
  "correct": false,
  "explanation": "« des talents de chez nous, pas d'ailleurs. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel mot ouvre l'argument de Karim ?",
  "options": [
    {
      "text": "en conclusion",
      "correct": false
    },
    {
      "text": "par ailleurs",
      "correct": false
    },
    {
      "text": "d'abord",
      "correct": true
    },
    {
      "text": "ensuite",
      "correct": false
    }
  ],
  "explanation": "« D'abord, le concept… »"
}$j$::jsonb,
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
      "right": "concept"
    },
    {
      "left": "ensuite",
      "right": "opinion"
    },
    {
      "left": "par ailleurs / en outre",
      "right": "ajout"
    },
    {
      "left": "en conclusion",
      "right": "fermeture"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ , le concept : une lueur sans feu de paille.",
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
    "En",
    "conclusion",
    "je",
    "suis",
    "pour",
    "les",
    "deux",
    "prototypes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "concept",
  "hint": "Karim l'ouvre : l'idée avant l'opinion."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En conclusion le concept, d'abord je suis pour les deux prototypes.",
  "correct_sentence": "D'abord, le concept : une lueur sans feu de paille. En conclusion, ce sont des talents de chez nous.",
  "explanation": "On ouvre par d'abord, on ferme par en conclusion."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/dabord-ensuite.svg",
      "word": "d'abord ensuite"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/cahier-argument.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/doute-certitude.svg",
      "word": "un doute"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/futur-innovation.svg",
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
  "prompt": "Notez la chaîne : d'abord, ensuite, par ailleurs, en outre, en conclusion."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : D'abord le concept. Ensuite mon opinion. Par ailleurs le filtre. En outre les gestes. En conclusion, je suis pour."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Argument en cinq marches',
    'CE',
    $c$Objectif
Lire un texte qui progresse d'un concept à une conclusion.

Consigne
Lisez l'argument, sans aller trop vite.

Support — Feuille de Lila, Radio Figuier
Pourquoi soutenir la Lampe-Figue et le Filtre des Herbes
D'abord, le concept est clair : lueur solaire, eau plus nette.
Ensuite, mon opinion : la cour gagne deux gestes utiles, zéro mot d'ailleurs.
Par ailleurs, Dieudonné sait déjà couper et coudre.
En outre, Karim sait déjà dessiner le schéma pour Aline.
En conclusion, le Bureau des Escales peut ouvrir le dossier sans crainte.
On ne mélange pas concept et opinion : on les enchaîne.
On n'écrit pas tout d'un bloc : on marche.
Hawa relira à l'antenne si Lila le demande.
Mado pourra voir au marché après la démonstration.
Sami tiendra le temps : trois minutes, pas plus, plus tard.
Seuil des Sources — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila mélange concept et opinion dans la même marche.",
  "correct": false,
  "explanation": "« On ne mélange pas concept et opinion : on les enchaîne. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que sait déjà faire Karim, selon le texte ?",
  "options": [
    {
      "text": "tamponner le Bureau",
      "correct": false
    },
    {
      "text": "dessiner le schéma",
      "correct": true
    },
    {
      "text": "frapper le tambour",
      "correct": false
    },
    {
      "text": "tenir le marché",
      "correct": false
    }
  ],
  "explanation": "« Karim sait déjà dessiner le schéma. »"
}$j$::jsonb,
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
      "right": "concept clair"
    },
    {
      "left": "ensuite",
      "right": "opinion / cour"
    },
    {
      "left": "par ailleurs",
      "right": "Dieudonné"
    },
    {
      "left": "en conclusion",
      "right": "Bureau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ , Dieudonné sait déjà couper et coudre.",
  "answer": "Par ailleurs"
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
    "marche",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "enchaine",
  "hint": "Concept puis opinion : on les… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "D'abord mon opinion, en conclusion le concept n'est pas encore clair.",
  "correct_sentence": "D'abord, le concept est clair. Ensuite, mon opinion : la cour gagne deux gestes.",
  "explanation": "Concept avant opinion."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/cahier-argument.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/doute-certitude.svg",
      "word": "un doute"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/futur-innovation.svg",
      "word": "un futur"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/balance-pour-contre.svg",
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
  "prompt": "Recopiez les cinq marches et changez l'opinion."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'argument en marquant les liaisons, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Marcher dans l''argument',
    'PO',
    $c$Objectif
Enchaîner concept et opinion à l'oral.

Consigne
Répétez, puis argumentez pour un objet de la cour.

Support — Modèles de Marc
D'abord, le concept est simple.
Ensuite, je trouve cela utile.
Par ailleurs, on a déjà le banc.
En outre, on a déjà le tissu.
En conclusion, je soutiens le prototype.
D'abord j'écoute. Ensuite je parle.
Par ailleurs je montre. En outre je cite une source.
En conclusion je m'arrête.
Je ne recommence pas au milieu.
Je ne conclus pas deux fois.
Un pas, puis l'autre.
La cour suit si j'ordonne.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc conseille de conclure deux fois pour convaincre.",
  "correct": false,
  "explanation": "« Je ne conclus pas deux fois. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel mot ajoute un argument sans le conclure ?",
  "options": [
    {
      "text": "d'abord",
      "correct": false
    },
    {
      "text": "en conclusion",
      "correct": false
    },
    {
      "text": "par ailleurs",
      "correct": true
    },
    {
      "text": "stop",
      "correct": false
    }
  ],
  "explanation": "Par ailleurs / en outre = ajout."
}$j$::jsonb,
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
      "left": "ensuite",
      "right": "deuxième pas"
    },
    {
      "left": "par ailleurs",
      "right": "ajout"
    },
    {
      "left": "en conclusion",
      "right": "fermer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ , je soutiens le prototype.",
  "answer": "En conclusion"
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
    "le",
    "concept",
    "est",
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
  "word": "soutiens",
  "hint": "Marc le fait : il… le prototype."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En conclusion d'abord le concept est simple et ensuite je m'arrête déjà.",
  "correct_sentence": "D'abord, le concept est simple. En conclusion, je soutiens le prototype.",
  "explanation": "Un seul ouvre-marche, une seule conclusion."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/doute-certitude.svg",
      "word": "un doute"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/futur-innovation.svg",
      "word": "un futur"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/balance-pour-contre.svg",
      "word": "une balance"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/nuage-si.svg",
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
  "prompt": "Écrivez un argument de cinq phrases, une liaison chacune."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis un argument de cinq pas."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon argument en marches',
    'PE',
    $c$Objectif
Écrire un argument qui progresse du concept à la conclusion.

Consigne
Imitez l'argument de Rose, sans aller trop vite.

Support — Argument de Rose Iradukunda
Rose Iradukunda
D'abord, le concept : une lampe qui boit le soleil sous le figuier.
Ensuite, mon opinion : nous pourrons lire le Cahier du chemin plus tard.
Par ailleurs, le filtre protégera les tasses de Félicie.
En outre, aucun nom d'ailleurs n'est nécessaire.
En conclusion, je vote pour le test de demain.
Je sépare le concept et l'avis.
Je n'écris pas tout d'un souffle.
Rose
Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose vote contre le test.",
  "correct": false,
  "explanation": "« je vote pour le test de demain. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que protégera le filtre, selon Rose ?",
  "options": [
    {
      "text": "Radio Figuier",
      "correct": false
    },
    {
      "text": "les tasses de Félicie",
      "correct": true
    },
    {
      "text": "le tambour",
      "correct": false
    },
    {
      "text": "le Bureau",
      "correct": false
    }
  ],
  "explanation": "« le filtre protégera les tasses de Félicie. »"
}$j$::jsonb,
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
      "right": "concept / lampe"
    },
    {
      "left": "ensuite",
      "right": "opinion / cahier"
    },
    {
      "left": "par ailleurs",
      "right": "filtre / tasses"
    },
    {
      "left": "en conclusion",
      "right": "vote / test"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ , je vote pour le test de demain.",
  "answer": "En conclusion"
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
    "sépare",
    "le",
    "concept",
    "et",
    "l'avis",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "souffle",
  "hint": "Rose n'écrit pas tout d'un…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En conclusion le concept : une lampe, d'abord je vote contre.",
  "correct_sentence": "D'abord, le concept : une lampe qui boit le soleil. En conclusion, je vote pour le test.",
  "explanation": "Ordre des marches."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/futur-innovation.svg",
      "word": "un futur"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/balance-pour-contre.svg",
      "word": "une balance"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/nuage-si.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/prototype-figuier.svg",
      "word": "un prototype"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : cinq liaisons, concept distinct de l'opinion."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre argument, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — D''abord, ensuite, par ailleurs, en outre, en conclusion',
    'EL',
    $c$Objectif
Retenir la progression d'un argument.

Consigne
Apprenez la fiche.

Support — Fiche de progression
Ouvrir
D'abord : le concept, la définition, le geste.
Enchaîner
Ensuite : l'opinion, le premier avis.
Ajouter
Par ailleurs : un autre aspect (souvent une personne, un lieu).
En outre : encore un ajout, souvent un geste ou une preuve.
Fermer
En conclusion : le vote, la demande, l'arrêt.
On ne met pas en conclusion au début.
On ne met pas d'abord après avoir déjà conclu.
Concept ≠ opinion : on les marche, on ne les mélange pas.
Au Seuil : Lampe-Figue, Filtre des Herbes, banc de test, Bureau.
Cinq pas suffisent pour Radio Figuier.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« En outre » conclut l'argument.",
  "correct": false,
  "explanation": "En outre ajoute. En conclusion ferme."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où place-t-on le concept ?",
  "options": [
    {
      "text": "en conclusion",
      "correct": false
    },
    {
      "text": "d'abord",
      "correct": true
    },
    {
      "text": "nulle part",
      "correct": false
    },
    {
      "text": "après le vote",
      "correct": false
    }
  ],
  "explanation": "D'abord = ouvrir par le concept."
}$j$::jsonb,
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
      "right": "concept"
    },
    {
      "left": "ensuite",
      "right": "opinion"
    },
    {
      "left": "par ailleurs / en outre",
      "right": "ajout"
    },
    {
      "left": "en conclusion",
      "right": "vote"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ : le concept, la définition, le geste.",
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
    "Concept",
    "et",
    "opinion",
    "se",
    "marchent",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "progression",
  "hint": "D'abord… en conclusion : une…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En conclusion d'abord le concept et ensuite j'ajoute encore une conclusion.",
  "correct_sentence": "D'abord : le concept. En conclusion : le vote.",
  "explanation": "Une ouverture, une fermeture."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/balance-pour-contre.svg",
      "word": "une balance"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/nuage-si.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/prototype-figuier.svg",
      "word": "un prototype"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/atelier-lampe.svg",
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
  "prompt": "Rédigez une fiche personnelle de cinq marches sur un autre geste du Seuil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et un argument modèle."
}$j$::jsonb,
    9
  );

  -- ===== Imaginer demain =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Imaginer demain'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Imaginer demain', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Il se peut, je suis sûre',
    'CO',
    $c$Objectif
Parler du futur : pour, contre, doute et certitude.

Consigne
Lisez le dialogue. Indicatif ou subjonctif après ces formules ?

Support — Nuage et soleil, banc du figuier
Lila : Il est probable que la lampe tiendra trois soirs. (indicatif)
Karim : Il se peut que le fil casse dès la première nuit. (subjonctif)
Dieudonné : Il est possible que le tissu retienne trop d'eau. (subjonctif)
Aline : Je doute que le marché comprenne sans schéma. (subjonctif)
Patrick : Je suis sûr que le Bureau ouvrira le dossier. (indicatif)
Hawa : Je suis sûre que Radio Figuier expliquera sans crier. (indicatif)
Joël : Pour : on lira plus tard. Contre : on peut casser le verre.
Rose : Il est probable que Mado voudra une lanterne pour son stand.
Marc : Il se peut que Sami donne le tempo trop vite.
Solange : Je doute que l'on signe demain ; je suis sûre que l'on testera.
Mado : Pour le filtre, contre un essai trop près des tasses.
Sami : Il est possible que je frappe trop fort : je douterai moins après le test.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Après « il est probable que », Lila met le subjonctif.",
  "correct": false,
  "explanation": "« Il est probable que la lampe tiendra » — indicatif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle formule appelle le subjonctif ?",
  "options": [
    {
      "text": "il est probable que",
      "correct": false
    },
    {
      "text": "je suis sûr que",
      "correct": false
    },
    {
      "text": "il se peut que",
      "correct": true
    },
    {
      "text": "je suis sûre que",
      "correct": false
    }
  ],
  "explanation": "Il se peut que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il est probable que",
      "right": "indicatif"
    },
    {
      "left": "il se peut que / il est possible que",
      "right": "subjonctif"
    },
    {
      "left": "je doute que",
      "right": "subjonctif"
    },
    {
      "left": "je suis sûr(e) que",
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
  "prompt": "Complétez :\nIl se peut que le fil ___ dès la première nuit.",
  "answer": "casse"
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
    "sûr",
    "que",
    "le",
    "Bureau",
    "ouvrira",
    "le",
    "dossier",
    "."
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
  "hint": "Cette formule prend l'indicatif, pas le doute."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est probable que la lampe tienne trois soirs sans aucun test.",
  "correct_sentence": "Il est probable que la lampe tiendra trois soirs.",
  "explanation": "Il est probable que + indicatif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/nuage-si.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/prototype-figuier.svg",
      "word": "un prototype"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/atelier-lampe.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/fils-solaire.svg",
      "word": "un fil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Classez huit phrases : doute / certitude, mode employé."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Il est probable que… tiendra. Il se peut que… casse. Je doute que… comprenne. Je suis sûre que… expliquera."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Pour, contre, demain',
    'CE',
    $c$Objectif
Lire un débat sur l'avenir des deux prototypes.

Consigne
Lisez le débat, sans aller trop vite.

Support — Balance ocre, Salle des Herbes
Débat du figuier — imaginer demain
Pour la Lampe-Figue : il est probable que les veillées dureront un peu plus.
Je suis sûre que Léa notera mieux le Cahier du chemin.
Contre : il se peut que le verre se fêle. Il est possible que le fil brûle.
Je doute que l'on ait assez de verre pour tout le marché.
Pour le Filtre des Herbes : il est probable que Félicie versera plus tranquillement.
Je suis sûr que Yvette verra moins de ventres noués.
Contre : il se peut que le tissu sente trop les herbes.
Je doute que l'eau soit claire dès le premier passage.
En conclusion : on teste demain, on ne crie pas aujourd'hui.
Aline a noté pour et contre. Solange a gardé la feuille.
Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le débat conclut qu'on crie aujourd'hui sans tester.",
  "correct": false,
  "explanation": "« on teste demain, on ne crie pas aujourd'hui. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui, selon le texte, versera plus tranquillement ?",
  "options": [
    {
      "text": "Mado",
      "correct": false
    },
    {
      "text": "Sami",
      "correct": false
    },
    {
      "text": "Félicie",
      "correct": true
    },
    {
      "text": "Marc",
      "correct": false
    }
  ],
  "explanation": "« Il est probable que Félicie versera… »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il est probable que",
      "right": "veillées / Félicie"
    },
    {
      "left": "je suis sûre que",
      "right": "Léa"
    },
    {
      "left": "il se peut que",
      "right": "verre / tissu"
    },
    {
      "left": "je doute que",
      "right": "verre assez / eau claire"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe doute que l'on ___ assez de verre.",
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
    "teste",
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
  "word": "tranquillement",
  "hint": "Félicie versera ainsi, si le filtre tient."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est probable que les veillées durent un peu plus sans indicatif.",
  "correct_sentence": "Il est probable que les veillées dureront un peu plus.",
  "explanation": "Probable + indicatif futur."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/prototype-figuier.svg",
      "word": "un prototype"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/atelier-lampe.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/fils-solaire.svg",
      "word": "un fil"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/banc-test.svg",
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
  "prompt": "Recopiez pour et contre et ajoutez une phrase de chaque côté."
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
    'PO — Douter et être sûr',
    'PO',
    $c$Objectif
Dire le futur, le pour, le contre, le doute et la certitude.

Consigne
Répétez, puis donnez un pour et un contre.

Support — Modèles d'Hawa
Il est probable que la lampe tiendra.
Il se peut que le fil casse.
Il est possible que le tissu retienne trop.
Je doute que le marché attende.
Je suis sûre que Lila expliquera.
Je suis sûr que Dieudonné réparera.
Pour : on lira plus tard.
Contre : le verre peut fêler.
Demain, on testera.
On ne criera pas.
On mesurera. On notera.
Puis on décidera.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je doute que » est suivi du subjonctif.",
  "correct": true,
  "explanation": "Je doute que le marché attende."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Je suis sûre que Lila expliquera » : quel mode ?",
  "options": [
    {
      "text": "subjonctif",
      "correct": false
    },
    {
      "text": "impératif",
      "correct": false
    },
    {
      "text": "indicatif",
      "correct": true
    },
    {
      "text": "infinitif seul",
      "correct": false
    }
  ],
  "explanation": "Être sûr(e) que + indicatif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "probable",
      "right": "indicatif"
    },
    {
      "left": "se peut / possible",
      "right": "subjonctif"
    },
    {
      "left": "je doute que",
      "right": "subjonctif"
    },
    {
      "left": "je suis sûr(e) que",
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
  "prompt": "Complétez :\nJe doute que le marché ___.",
  "answer": "attende"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Demain",
    "on",
    "testera",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "certitude",
  "hint": "Je suis sûre que : c'est une…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis sûre que Lila explique demain à l'antenne.",
  "correct_sentence": "Je suis sûre que Lila expliquera demain à l'antenne.",
  "explanation": "Certitude sur demain : indicatif futur."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/atelier-lampe.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/fils-solaire.svg",
      "word": "un fil"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/banc-test.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/pitch-cour.svg",
      "word": "un pitch"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez dix phrases : 2 par formule de doute ou de certitude."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis un pour et un contre à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma balance de demain',
    'PE',
    $c$Objectif
Écrire pour et contre avec doute et certitude.

Consigne
Imitez la balance de Joël, sans aller trop vite.

Support — Balance de Joël Mugisha
Joël Mugisha
Il est probable que la Lampe-Figue m'aidera à ranger le soir.
Il se peut que je casse le verre si je cours.
Il est possible que le Filtre des Herbes change le goût de l'eau.
Je doute que je sache expliquer en une minute.
Je suis sûr que Dieudonné saura réparer.
Pour : moins de peur sous le figuier.
Contre : trop d'essais trop vite.
En conclusion, je viendrai au test, sans crier.
Joël
Cahier du chemin
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël refuse de venir au test.",
  "correct": false,
  "explanation": "« je viendrai au test, sans crier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que craint Joël s'il court ?",
  "options": [
    {
      "text": "le tambour",
      "correct": false
    },
    {
      "text": "de casser le verre",
      "correct": true
    },
    {
      "text": "la rumeur",
      "correct": false
    },
    {
      "text": "Solange",
      "correct": false
    }
  ],
  "explanation": "« Il se peut que je casse le verre si je cours. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il est probable que",
      "right": "l'aidera"
    },
    {
      "left": "il se peut que",
      "right": "casse"
    },
    {
      "left": "je doute que",
      "right": "sache"
    },
    {
      "left": "je suis sûr que",
      "right": "saura"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe doute que je ___ expliquer en une minute.",
  "answer": "sache"
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
    "viendrai",
    "au",
    "test",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ranger",
  "hint": "La lampe l'aidera à… le soir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est probable que la Lampe-Figue m'aide sans jamais tenir.",
  "correct_sentence": "Il est probable que la Lampe-Figue m'aidera à ranger le soir.",
  "explanation": "Probable + indicatif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/fils-solaire.svg",
      "word": "un fil"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/banc-test.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/pitch-cour.svg",
      "word": "un pitch"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/micro-lila.svg",
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
  "prompt": "Imitez : quatre formules, un pour, un contre, une conclusion."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre balance, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Doute, certitude, futur',
    'EL',
    $c$Objectif
Retenir les modes après les formules de doute et de certitude.

Consigne
Apprenez la fiche.

Support — Fiche des modes
Indicatif (souvent futur)
Il est probable que + indicatif : Il est probable que la lampe tiendra.
Je suis sûr que / je suis sûre que + indicatif : Je suis sûre que Lila expliquera.
Subjonctif
Il se peut que + subj. : Il se peut que le fil casse.
Il est possible que + subj. : Il est possible que le tissu retienne trop.
Je doute que + subj. : Je doute que le marché attende.
Pour / contre
On pose un bénéfice, on pose un risque, on conclut par un test.
On n'écrit pas : il est probable que la lampe tienne (au Seuil, on tient l'indicatif).
On n'écrit pas : je suis sûre que Lila explique demain (futur attendu).
Demain on testera. On ne criera pas.
Lampe-Figue et Filtre des Herbes : deux futurs à mesurer.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Il est possible que » prend le subjonctif.",
  "correct": true,
  "explanation": "Il est possible que le tissu retienne trop."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Il est probable que » + …",
  "options": [
    {
      "text": "subjonctif",
      "correct": false
    },
    {
      "text": "impératif",
      "correct": false
    },
    {
      "text": "indicatif",
      "correct": true
    },
    {
      "text": "infinitif forcé",
      "correct": false
    }
  ],
  "explanation": "Probable + indicatif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "probable / sûr(e)",
      "right": "indicatif"
    },
    {
      "left": "se peut / possible",
      "right": "subjonctif"
    },
    {
      "left": "douter",
      "right": "subjonctif"
    },
    {
      "left": "pour / contre",
      "right": "bénéfice / risque"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl est possible que le tissu ___ trop.",
  "answer": "retienne"
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
    "criera",
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
  "word": "subjonctif",
  "hint": "Se peut, possible, douter : ce mode-là."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est probable que le fil casse dès la première nuit.",
  "correct_sentence": "Il se peut que le fil casse dès la première nuit.",
  "explanation": "Le doute fort : il se peut que + subjonctif. Le probable : indicatif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/banc-test.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/pitch-cour.svg",
      "word": "un pitch"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/micro-lila.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/affiche-pitch.svg",
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
  "prompt": "Tableau : 6 formules, 6 exemples, mode indiqué."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et douze phrases (deux par formule)."
}$j$::jsonb,
    9
  );

  -- ===== Le prototype sous le figuier =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Le prototype sous le figuier'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Le prototype sous le figuier', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le soir du test',
    'CO',
    $c$Objectif
Suivre le test de la Lampe-Figue sous le figuier.

Consigne
Lisez le dialogue. Qu'est-ce qui tient ? Qu'est-ce qui doute encore ?

Support — Banc de test, fils solaires
Dieudonné : D'abord, je pose le verre. Ensuite, je tends le fil.
Lila : Il est probable que la lueur tienne jusqu'à la première étoile.
Karim : Il se peut que le fil glisse. Je le tiens.
Aline : Ce que je vois, c'est une lueur basse, nette.
Patrick : Le prototype auquel on tient ne fume pas.
Hawa : Cela permet de lire deux lignes du Cahier du chemin.
Joël : Je doute que cela suffise pour tout le marché. C'est déjà beaucoup pour le banc.
Rose : Je suis sûre que Léa notera l'heure.
Marc : Par ailleurs, le Filtre des Herbes attendra demain matin.
Solange : En conclusion, le dossier peut recevoir une première date.
Mado : Les stands auxquels on pensait attendront la Saison des Voix.
Sami : Je frappe une fois : le test est ouvert. Je frappe deux fois : on note.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le prototype fume beaucoup, selon Patrick.",
  "correct": false,
  "explanation": "« ne fume pas. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de lignes Hawa peut-elle lire ?",
  "options": [
    {
      "text": "vingt",
      "correct": false
    },
    {
      "text": "deux",
      "correct": true
    },
    {
      "text": "aucune",
      "correct": false
    },
    {
      "text": "cent",
      "correct": false
    }
  ],
  "explanation": "« lire deux lignes du Cahier du chemin. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'abord / ensuite",
      "right": "Dieudonné"
    },
    {
      "left": "il se peut que",
      "right": "fil / Karim"
    },
    {
      "left": "cela permet de",
      "right": "lire"
    },
    {
      "left": "en conclusion",
      "right": "Solange / date"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe prototype ___ on tient ne fume pas.",
  "answer": "auquel"
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
    "frappe",
    "une",
    "fois",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lueur",
  "hint": "Aline la voit : basse, nette."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le prototype que on tient ne fume pas sous le figuier.",
  "correct_sentence": "Le prototype auquel on tient ne fume pas.",
  "explanation": "Tenir à → auquel."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/pitch-cour.svg",
      "word": "un pitch"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/micro-lila.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/affiche-pitch.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/horloge-trois-minutes.svg",
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
  "prompt": "Notez le protocole : poser, tendre, lire, noter, dater."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez le test : Je pose le verre. Je tends le fil. Cela permet de lire deux lignes."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Compte rendu du test',
    'CE',
    $c$Objectif
Lire le compte rendu de la Lampe-Figue.

Consigne
Lisez le compte rendu, sans aller trop vite.

Support — Feuille de test, ombre du figuier
Compte rendu — Lampe-Figue, premier soir
D'abord, Dieudonné a posé le verre sur le banc de test.
Ensuite, Karim a tendu le fil. Il se peut que le fil ait glissé une fois.
Par ailleurs, Lila a lu deux lignes du Cahier du chemin à voix haute.
En outre, aucune fumée n'a été vue. Il a été confirmé que le prototype ne fume pas.
En conclusion, Solange a noté une date au Bureau des Escales.
Il est probable que l'on recommence demain avec le Filtre des Herbes.
Je doute que le marché reçoive une lanterne dès cette semaine.
Je suis sûre que la cour a compris le geste.
On appelle ça un test, pas une fête.
Cela permet de mesurer, pas de crier victoire.
Signé : Aline Uwase
Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "De la fumée a été vue pendant le test.",
  "correct": false,
  "explanation": "« aucune fumée n'a été vue. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a signé le compte rendu ?",
  "options": [
    {
      "text": "Lila",
      "correct": false
    },
    {
      "text": "Karim",
      "correct": false
    },
    {
      "text": "Aline",
      "correct": true
    },
    {
      "text": "Mado",
      "correct": false
    }
  ],
  "explanation": "« Signé : Aline Uwase. »"
}$j$::jsonb,
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
      "right": "verre / Dieudonné"
    },
    {
      "left": "ensuite",
      "right": "fil / Karim"
    },
    {
      "left": "par ailleurs",
      "right": "Lila / deux lignes"
    },
    {
      "left": "en conclusion",
      "right": "date / Solange"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn appelle ça un ___, pas une fête.",
  "answer": "test"
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
    "fumée",
    "n'a",
    "été",
    "vue",
    "."
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
  "hint": "Le test permet de…, pas de crier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est probable que l'on recommence demain et que le marché reçoive tout cette semaine.",
  "correct_sentence": "Il est probable que l'on recommence demain avec le Filtre des Herbes. Je doute que le marché reçoive une lanterne dès cette semaine.",
  "explanation": "Probable + indicatif. Doute + subjonctif : on ne les fond pas."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/micro-lila.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/affiche-pitch.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/horloge-trois-minutes.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/radio-figuier.svg",
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
  "prompt": "Recopiez le compte rendu et encadrez les liaisons."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le compte rendu, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire le test',
    'PO',
    $c$Objectif
Raconter un test de prototype à l'oral.

Consigne
Répétez, puis racontez un essai de la cour.

Support — Modèles de Karim
D'abord, on a posé le verre.
Ensuite, on a tendu le fil.
Il se peut que le fil ait glissé.
Il a été confirmé que rien n'a fumé.
Cela permet de lire deux lignes.
Je doute que cela éclaire tout le marché.
Je suis sûr que l'on reprendra demain.
En conclusion, le test tient.
On appelle ça une Lampe-Figue.
On ne crie pas victoire.
On note l'heure.
On range le fil.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Karim crie victoire à la fin du test.",
  "correct": false,
  "explanation": "« On ne crie pas victoire. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que range-t-on à la fin ?",
  "options": [
    {
      "text": "le marché",
      "correct": false
    },
    {
      "text": "le fil",
      "correct": true
    },
    {
      "text": "Radio Figuier",
      "correct": false
    },
    {
      "text": "le Bureau",
      "correct": false
    }
  ],
  "explanation": "« On range le fil. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'abord / ensuite",
      "right": "protocole"
    },
    {
      "left": "il se peut que",
      "right": "glissé"
    },
    {
      "left": "confirmé",
      "right": "pas de fumée"
    },
    {
      "left": "en conclusion",
      "right": "le test tient"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ne crie pas ___.",
  "answer": "victoire"
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
    "note",
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
  "word": "protocole",
  "hint": "Poser, tendre, lire, noter : un…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On crie victoire dès que le fil tient une seconde.",
  "correct_sentence": "On ne crie pas victoire. En conclusion, le test tient.",
  "explanation": "Mesurer d'abord, célébrer plus tard."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/affiche-pitch.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/horloge-trois-minutes.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/dieudonne-outil.svg",
      "word": "un outil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un test oral de dix phrases, cinq liaisons."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis votre compte rendu parlé."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon compte rendu de test',
    'PE',
    $c$Objectif
Écrire le test de la Lampe-Figue.

Consigne
Imitez le compte rendu de Léa, sans aller trop vite.

Support — Compte rendu de Léa Niyonzima
Léa Niyonzima
D'abord, Dieudonné a posé le verre sous le figuier.
Ensuite, Karim a tenu le fil. Il se peut qu'il ait tremblé.
Par ailleurs, Lila a lu deux lignes. Cela permet de voir l'usage.
En outre, il a été confirmé que le prototype ne fumait pas.
En conclusion, je suis sûre que nous reprendrons demain le Filtre des Herbes.
Je doute que le marché reçoive une lanterne dès ce soir.
On appelle ça un test. Ce n'est pas encore une fête.
Léa
Cahier du chemin
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa pense que le marché recevra une lanterne dès ce soir.",
  "correct": false,
  "explanation": "« Je doute que le marché reçoive une lanterne dès ce soir. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a lu deux lignes ?",
  "options": [
    {
      "text": "Léa",
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
      "text": "Solange",
      "correct": false
    }
  ],
  "explanation": "« Lila a lu deux lignes. »"
}$j$::jsonb,
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
      "right": "verre"
    },
    {
      "left": "ensuite",
      "right": "fil"
    },
    {
      "left": "par ailleurs",
      "right": "deux lignes"
    },
    {
      "left": "en conclusion",
      "right": "filtre demain"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn appelle ça un ___. Ce n'est pas encore une fête.",
  "answer": "test"
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
    "encore",
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
  "word": "tremble",
  "hint": "Il se peut que le fil l'ait fait."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis sûre que le marché reçoive une lanterne dès ce soir.",
  "correct_sentence": "Je doute que le marché reçoive une lanterne dès ce soir.",
  "explanation": "Le doute de Léa prend je doute que + subjonctif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/horloge-trois-minutes.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/dieudonne-outil.svg",
      "word": "un outil"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/karim-idea.svg",
      "word": "une idée"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : cinq liaisons, un doute, une certitude, un nom d'objet."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre compte rendu, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Dire un test de prototype',
    'EL',
    $c$Objectif
Retenir le lexique et les formules du test sous le figuier.

Consigne
Apprenez la fiche.

Support — Fiche du banc de test
Gestes : poser le verre, tendre le fil, lire deux lignes, noter l'heure, ranger.
Formules : on appelle ça un test, pas une fête.
Cela permet de mesurer, pas de crier victoire.
Il se peut que le fil glisse. Il a été confirmé que rien n'a fumé.
Relatif : le prototype auquel on tient ; le banc sur lequel on pose.
Progression : d'abord, ensuite, par ailleurs, en outre, en conclusion.
Doute : je doute que le marché reçoive tout. Je suis sûre que l'on reprendra.
Objets : Lampe-Figue, Filtre des Herbes, Cahier du chemin, Bureau des Escales.
On n'emprunte pas de nom d'ailleurs.
On date. On signe. On revient demain.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Un test, au Seuil, égale une fête.",
  "correct": false,
  "explanation": "On appelle ça un test, pas une fête."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait-on du fil à la fin ?",
  "options": [
    {
      "text": "on le vend",
      "correct": false
    },
    {
      "text": "on le range",
      "correct": true
    },
    {
      "text": "on le jette à la rive",
      "correct": false
    },
    {
      "text": "on l'oublie",
      "correct": false
    }
  ],
  "explanation": "Ranger le fil."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "poser / tendre",
      "right": "gestes"
    },
    {
      "left": "mesurer",
      "right": "but du test"
    },
    {
      "left": "auquel on tient",
      "right": "prototype"
    },
    {
      "left": "revenir demain",
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
  "prompt": "Complétez :\nCela permet de ___, pas de crier victoire.",
  "answer": "mesurer"
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
    "date",
    "on",
    "signe",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "prototype",
  "hint": "Lampe-Figue encore fragile : un…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On appelle ça une fête dès que deux lignes sont lues.",
  "correct_sentence": "On appelle ça un test, pas une fête.",
  "explanation": "Mesurer ≠ célébrer trop tôt."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/dieudonne-outil.svg",
      "word": "un outil"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/karim-idea.svg",
      "word": "une idée"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/feuille-brevet.svg",
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
  "prompt": "Checklist de test : 8 cases à cocher demain matin."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et le protocole complet."
}$j$::jsonb,
    9
  );

  -- ===== Pitcher devant la cour =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Pitcher devant la cour'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Pitcher devant la cour', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Trois minutes sous le figuier',
    'CO',
    $c$Objectif
Comprendre un oral de synthèse de trois minutes.

Consigne
Lisez le dialogue. Que doit contenir le pitch ?

Support — Affiche de pitch, cour du Seuil
Aline : Trois minutes. Pas une de plus. La cour est là.
Lila : D'abord je nomme. On appelle ça Lampe-Figue et Filtre des Herbes.
Karim : Ensuite je montre le schéma. Cela permet de voir le geste.
Dieudonné : Par ailleurs je tiens l'outil avec lequel j'ai coupé.
Patrick : En outre on dit pour et contre, sans cacher le verre qui peut fêler.
Hawa : En conclusion on demande le droit de continuer le test.
Joël : Ce qui compte, c'est une phrase nette, pas un cri.
Rose : C'est le bénéfice que la cour doit retenir : lire, verser.
Marc : Il est probable que Mado pose une question. Répondez, puis silence.
Solange : Je suis sûre que le Bureau notera si le temps est tenu.
Mado : Je doute que l'on tienne si l'on recommence le concept deux fois.
Sami : J'ouvrirai par trois frappes. Je fermerai par une.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline autorise quatre minutes si c'est beau.",
  "correct": false,
  "explanation": "« Trois minutes. Pas une de plus. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que doit retenir la cour, selon Rose ?",
  "options": [
    {
      "text": "un cri",
      "correct": false
    },
    {
      "text": "lire et verser",
      "correct": true
    },
    {
      "text": "une rumeur",
      "correct": false
    },
    {
      "text": "un tampon seul",
      "correct": false
    }
  ],
  "explanation": "« le bénéfice… : lire, verser. »"
}$j$::jsonb,
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
      "right": "nommer"
    },
    {
      "left": "ensuite",
      "right": "schéma"
    },
    {
      "left": "en conclusion",
      "right": "demander de continuer"
    },
    {
      "left": "trois minutes",
      "right": "durée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTrois minutes. Pas une de ___.",
  "answer": "plus"
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
    "qui",
    "compte",
    "c'est",
    "une",
    "phrase",
    "nette",
    "."
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
  "hint": "Oral court qui rassemble tout (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "D'abord je recommence le concept deux fois, ensuite je nomme enfin.",
  "correct_sentence": "D'abord je nomme. On appelle ça Lampe-Figue et Filtre des Herbes.",
  "explanation": "On ne recommence pas le concept."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/dieudonne-outil.svg",
      "word": "un outil"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/karim-idea.svg",
      "word": "une idée"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/feuille-brevet.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/soleil-invention.svg",
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
  "prompt": "Listez les cinq marches du pitch et la durée."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez le plan : nommer, montrer, outil, pour-contre, demander."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fiche pitch',
    'CE',
    $c$Objectif
Lire la fiche d'un oral de trois minutes.

Consigne
Lisez la fiche, sans aller trop vite.

Support — Fiche d'Aline, pupitre de la cour
Pitch de la cour — 3 minutes
0:00 Sami : trois frappes.
0:10 Lila : On appelle ça Lampe-Figue. Cela permet de lire le soir.
0:40 Karim : On appelle ça Filtre des Herbes. Cela permet de clarifier l'eau.
1:10 Dieudonné : l'outil avec lequel on a coupé ; le banc sur lequel on a testé.
1:40 Pour : lire, verser. Contre : le verre peut fêler ; le tissu peut sentir.
2:10 Doute et certitude : il se peut que le fil glisse ; je suis sûre que l'on saura réparer.
2:40 En conclusion : nous demandons de continuer sous le figuier.
3:00 Sami : une frappe. Silence.
Interdit : mot d'ailleurs, rumeur, dépasser le temps.
Autorisé : un schéma, un verre, un coupon de tissu.
Seuil des Sources — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut dépasser le temps si le schéma est beau.",
  "correct": false,
  "explanation": "« Interdit : … dépasser le temps. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui parle à 1:10 ?",
  "options": [
    {
      "text": "Lila",
      "correct": false
    },
    {
      "text": "Karim",
      "correct": false
    },
    {
      "text": "Dieudonné",
      "correct": true
    },
    {
      "text": "Sami",
      "correct": false
    }
  ],
  "explanation": "Dieudonné : l'outil, le banc."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "0:10",
      "right": "Lila / lampe"
    },
    {
      "left": "0:40",
      "right": "Karim / filtre"
    },
    {
      "left": "1:40",
      "right": "pour / contre"
    },
    {
      "left": "2:40",
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
  "prompt": "Complétez :\nInterdit : mot d'ailleurs, rumeur, ___ le temps.",
  "answer": "dépasser"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Silence",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "autorise",
  "hint": "Un schéma, un verre, un coupon : c'est…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Interdit : un schéma. Autorisé : dépasser le temps et une rumeur.",
  "correct_sentence": "Interdit : mot d'ailleurs, rumeur, dépasser le temps. Autorisé : un schéma, un verre, un coupon.",
  "explanation": "La fiche inverse serait fausse."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/karim-idea.svg",
      "word": "une idée"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/feuille-brevet.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/soleil-invention.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/coeur-talent.svg",
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
  "prompt": "Recopiez la fiche-temps et changez l'ordre pour/contre."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la fiche-temps, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Tenir trois minutes',
    'PO',
    $c$Objectif
Pitcher à l'oral : synthèse nette.

Consigne
Répétez le canevas, puis parlez trois minutes.

Support — Canevas de Lila
On appelle ça Lampe-Figue.
Cela permet de lire le soir.
On appelle ça Filtre des Herbes.
Cela permet de clarifier l'eau.
Voici l'outil avec lequel nous avons coupé.
Voici le banc sur lequel nous avons testé.
Pour : lire, verser. Contre : le verre peut fêler.
Il se peut que le fil glisse. Je suis sûre que l'on réparera.
En conclusion, nous demandons de continuer.
Merci à la cour. Merci à Sami.
Je m'arrête.
Le temps est tenu.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le canevas oublie le contre.",
  "correct": false,
  "explanation": "« Contre : le verre peut fêler. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase ferme le pitch ?",
  "options": [
    {
      "text": "On appelle ça Lampe-Figue",
      "correct": false
    },
    {
      "text": "Voici l'outil",
      "correct": false
    },
    {
      "text": "Nous demandons de continuer",
      "correct": true
    },
    {
      "text": "Sami ouvre",
      "correct": false
    }
  ],
  "explanation": "En conclusion : continuer."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on appelle ça",
      "right": "noms"
    },
    {
      "left": "cela permet de",
      "right": "usages"
    },
    {
      "left": "pour / contre",
      "right": "balance"
    },
    {
      "left": "en conclusion",
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
  "prompt": "Complétez :\nEn conclusion, nous demandons de ___.",
  "answer": "continuer"
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
    "temps",
    "est",
    "tenu",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "canevas",
  "hint": "La trame que Lila répète avant l'oral."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En conclusion on appelle ça encore deux fois le concept entier.",
  "correct_sentence": "En conclusion, nous demandons de continuer.",
  "explanation": "La conclusion demande, elle ne renomme pas tout."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/feuille-brevet.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/soleil-invention.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/coeur-talent.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/relatif-compose.svg",
      "word": "un relatif"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez votre canevas de douze phrases, chronométrable."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez un pitch de trois minutes, puis arrêtez-vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon pitch écrit',
    'PE',
    $c$Objectif
Écrire la synthèse orale de trois minutes.

Consigne
Imitez le pitch de Karim, sans aller trop vite.

Support — Pitch de Karim
Karim
On appelle ça Lampe-Figue. Cela permet de lire le Cahier du chemin.
On appelle ça Filtre des Herbes. Cela permet de verser une eau plus nette.
Voici l'arbre sous lequel nous testons, l'outil avec lequel Dieudonné coupe.
Pour : deux gestes utiles. Contre : le fil peut glisser, le verre peut fêler.
Il est probable que la cour comprendra. Il se peut que le marché attende.
Je suis sûr que nous saurons réparer. Je doute que l'on finisse ce soir.
En conclusion, nous demandons trois soirs de plus sous le figuier.
Karim
Seuil des Sources — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Karim demande trois soirs de plus.",
  "correct": true,
  "explanation": "« nous demandons trois soirs de plus. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel arbre est cité ?",
  "options": [
    {
      "text": "un peuplier d'ailleurs",
      "correct": false
    },
    {
      "text": "le figuier",
      "correct": true
    },
    {
      "text": "un pin",
      "correct": false
    },
    {
      "text": "aucun arbre",
      "correct": false
    }
  ],
  "explanation": "« l'arbre sous lequel nous testons » — le figuier du Seuil."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Lampe-Figue",
      "right": "lire"
    },
    {
      "left": "Filtre des Herbes",
      "right": "verser"
    },
    {
      "left": "pour / contre",
      "right": "gestes / risques"
    },
    {
      "left": "en conclusion",
      "right": "trois soirs"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous demandons trois soirs de ___.",
  "answer": "plus"
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
    "l'outil",
    "avec",
    "lequel",
    "Dieudonné",
    "coupe",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "comprendra",
  "hint": "Il est probable que la cour…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il est probable que la cour comprenne le schéma demain.",
  "correct_sentence": "Il est probable que la cour comprendra le schéma demain.",
  "explanation": "Il est probable que + indicatif."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/soleil-invention.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/coeur-talent.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/relatif-compose.svg",
      "word": "un relatif"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/jeune-talent.svg",
      "word": "un talent"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : noms, usages, relatif, pour-contre, doute, demande."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre pitch, chronométrez, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Synthèse de trois minutes',
    'EL',
    $c$Objectif
Retenir le canevas d'un pitch de la cour.

Consigne
Apprenez la fiche.

Support — Fiche pitch
Durée : trois minutes. Sami ouvre et ferme.
1. Nommer : on appelle ça… 2. Usage : cela permet de…
3. Relier : avec lequel, sous lequel, auquel
4. Balance : pour / contre
5. Modes : il se peut que + subj. ; je suis sûr(e) que + ind.
6. Conclusion : nous demandons de continuer
Interdit : mot d'ailleurs, rumeur, dépasser, recommencer le concept.
Autorisé : schéma, verre, tissu, une question de Mado, puis silence.
Ce qui compte, c'est une phrase nette.
C'est le bénéfice que la cour retient.
On n'écrit pas un roman. On marche.
Sous le figuier, le temps est une politesse.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut recommencer le concept si Mado n'a pas entendu.",
  "correct": false,
  "explanation": "Interdit : recommencer le concept."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui ouvre et ferme le temps ?",
  "options": [
    {
      "text": "Solange",
      "correct": false
    },
    {
      "text": "Sami",
      "correct": true
    },
    {
      "text": "Félicie",
      "correct": false
    },
    {
      "text": "Yvette",
      "correct": false
    }
  ],
  "explanation": "Sami : frappes."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "on appelle ça",
      "right": "nommer"
    },
    {
      "left": "cela permet de",
      "right": "usage"
    },
    {
      "left": "pour / contre",
      "right": "balance"
    },
    {
      "left": "nous demandons",
      "right": "conclusion"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSous le figuier, le temps est une ___.",
  "answer": "politesse"
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
    "n'écrit",
    "pas",
    "un",
    "roman",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "politesse",
  "hint": "Tenir le temps : une… sous le figuier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On recommence le concept si Mado n'a pas entendu la première minute.",
  "correct_sentence": "Interdit : recommencer le concept. Une question de Mado, puis silence.",
  "explanation": "On répond, on ne rejoue pas tout."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m7/coeur-talent.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/relatif-compose.svg",
      "word": "un relatif"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/jeune-talent.svg",
      "word": "un talent"
    },
    {
      "image_path": "/elearning/mfk-b1-m7/presentation-inno.svg",
      "word": "une présentation"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez votre charte personnelle de pitch en six articles."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et un pitch d'entraînement de trois minutes."
}$j$::jsonb,
    9
  );

END;
$$;
