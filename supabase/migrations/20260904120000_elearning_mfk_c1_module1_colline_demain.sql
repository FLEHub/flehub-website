/*
  Seed eLearning MFK — C1 — La colline de demain

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-c1-m1/
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
  v_module_title text := 'C1 — La colline de demain';
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
      'Grande étape C1-1 : rendre compte de deux regards sur la colline, synthétiser l''habitat partagé du Pavillon du Saule, recommander une mobilité sans écraser la pente, décrire une Rukiri-Nord imaginaire, puis signer un compte-rendu 2040 — Nina Kayitesi déroule des plans sous le figuier, Marc Nkurunziza refuse qu''un parking se nomme progrès, Léa Niyonzima concède la densité si l''on en discute, et Radio Figuier (Rukiri-Nord) enregistre ce que l''on tait lorsqu''on dit moderniser.',
      'C1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape C1-1 : rendre compte de deux regards sur la colline, synthétiser l''habitat partagé du Pavillon du Saule, recommander une mobilité sans écraser la pente, décrire une Rukiri-Nord imaginaire, puis signer un compte-rendu 2040 — Nina Kayitesi déroule des plans sous le figuier, Marc Nkurunziza refuse qu''un parking se nomme progrès, Léa Niyonzima concède la densité si l''on en discute, et Radio Figuier (Rukiri-Nord) enregistre ce que l''on tait lorsqu''on dit moderniser.',
      cefr_level = 'C1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== La colline future =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'La colline future'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'La colline future', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La colline future',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Rendre compte de deux regards sur la colline future sans les fusionner. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — La colline future
Lila Sow : Radio Figuier. On parle trop vite de la colline de demain, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on promette des lanternes plus hautes, le parking projeté à la racine du figuier n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Léa Niyonzima concède que la densification peut protéger les jardins, pour autant que l'on en discute avant les camions.
Aline Uwase : Ce que l'on nomme urbanisme, ici, n'est pas un slogan : organisation raisonnée de l'espace habité.
Patrick Habimana : Nina Kayitesi déroule un calque : la friche n'est pas un vide, c'est une mémoire en attente de verbe.
Hawa Diallo : Patrick refuse qu'on accélère la pente au nom d'un urbanisme qui n'aurait d'urbain que la vitesse.
Joël Mugisha : Joël rappelle que porter les lanternes n'est pas habiter : l'une éclaire, l'autre reste.
Rose Iradukunda : Rose coupe un tissu ocre et dit que le plan, s'il n'habille personne, n'est qu'une affiche.
Solange Mukamana : Solange demande qui paiera la rampe, car une colline sans rampe n'accueille que ceux qui montent vite.
Karim Bamba : Félicie pose le bol : on ne mange pas un plan, on mange ce que la pente laisse pousser.
Félicie Ndayishimiye : Un chiffre, une trace : Karim compte trois files de camions, zéro banc nouveau, une ombre de moins à midi.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de garder une colline habitable, non une affiche lumineuse
Yvette : Dieudonné réparera l'escalier une fois que l'on aura nommé s'il reste un escalier.
Mado : Hawa Diallo entend, dans « colline de demain », ceci qui n'est pas dit : l'effacement possible du mot figuier n'est pas un accident de vocabulaire
Sami : Autrement dit, la densification n'est un abri que si elle cesse d'être un parking habillé de mots
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : garder deux voix dans le compte-rendu et une rampe avant les lanternes nouvelles
Nina Kayitesi : Marc Nkurunziza : un compte-rendu n'est pas une victoire, c'est une hospitalité faite aux désaccords.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le calque de Nina Kayitesi d'un côté, la tribune de Marc Nkurunziza de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "le parking projeté à la racine du figuier est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que le parking projeté à la racine du figuier n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Hawa Diallo, que reste-t-il implicite dans « colline de demain » ?",
  "options": [
    {
      "text": "Que les lanternes seront plus basses dès demain",
      "correct": false
    },
    {
      "text": "L'effacement possible du mot figuier",
      "correct": true
    },
    {
      "text": "Que Nina refuse tout calque par principe",
      "correct": false
    },
    {
      "text": "Que Félicie fermera le Marché des Herbes",
      "correct": false
    }
  ],
  "explanation": "l'effacement possible du mot figuier n'est pas un accident de vocabulaire"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "urbanisme",
      "right": "organisation raisonnée de l'espace habité"
    },
    {
      "left": "densification",
      "right": "processus qui resserre l'habitat"
    },
    {
      "left": "mixité",
      "right": "cohabitation d'usages et de voix"
    },
    {
      "left": "friche",
      "right": "terrain en attente, non un vide"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ , le parking projeté à la racine du figuier n'est pas un détail. (promettre, subj.)",
  "answer": "promette"
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
    "promette",
    "la",
    "lumière",
    "urbanisme",
    "n'est",
    "pas",
    "un",
    "détail",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "urbanisme",
  "hint": "organisation raisonnée de l'espace habité"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Encore que l'on promettre trop vite, le parking projeté à la racine du figuier n'est pas un détail, et Léa Niyonzima écoute.",
  "correct_sentence": "Encore que l'on promette trop vite, le parking projeté à la racine du figuier n'est pas un détail, et Léa Niyonzima écoute.",
  "explanation": "Après encore que : promette."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m1/urbanisme-colline.svg",
      "word": "urbanisme colline"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/densite-jardins.svg",
      "word": "densite jardins"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/mixite-rive.svg",
      "word": "mixite rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/friche-figuier.svg",
      "word": "friche figuier"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « colline de demain » et la concession de Léa Niyonzima."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le calque de Nina Kayitesi et la tribune de Marc Nkurunziza distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Ce que le plan ne dit pas',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rendre compte de deux regards sur la colline future sans les fusionner. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Ce que le plan ne dit pas », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Ce que le plan ne dit pas
On parle trop vite de la colline de demain, comme si le mot dispensait d'en examiner le prix.
Encore que l'on promette des lanternes plus hautes, le parking projeté à la racine du figuier n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que la densification peut protéger les jardins, pour autant que l'on en discute avant les camions.
Ce que l'on nomme urbanisme, ici, n'est pas un slogan : organisation raisonnée de l'espace habité.
Nina Kayitesi déroule un calque : la friche n'est pas un vide, c'est une mémoire en attente de verbe.
Patrick refuse qu'on accélère la pente au nom d'un urbanisme qui n'aurait d'urbain que la vitesse.
Joël rappelle que porter les lanternes n'est pas habiter : l'une éclaire, l'autre reste.
Rose coupe un tissu ocre et dit que le plan, s'il n'habille personne, n'est qu'une affiche.
Solange demande qui paiera la rampe, car une colline sans rampe n'accueille que ceux qui montent vite.
Félicie pose le bol : on ne mange pas un plan, on mange ce que la pente laisse pousser.
Un chiffre, une trace : Karim compte trois files de camions, zéro banc nouveau, une ombre de moins à midi.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de garder une colline habitable, non une affiche lumineuse
Dieudonné réparera l'escalier une fois que l'on aura nommé s'il reste un escalier.
Hawa Diallo entend, dans « colline de demain », ceci qui n'est pas dit : l'effacement possible du mot figuier n'est pas un accident de vocabulaire
Autrement dit, la densification n'est un abri que si elle cesse d'être un parking habillé de mots
La proposition qui reste debout est celle-ci : garder deux voix dans le compte-rendu et une rampe avant les lanternes nouvelles
Marc Nkurunziza : un compte-rendu n'est pas une victoire, c'est une hospitalité faite aux désaccords.
Nous clôturons sans fusionner les voix : le calque de Nina Kayitesi d'un côté, la tribune de Marc Nkurunziza de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le calque de Nina Kayitesi et la tribune de Marc Nkurunziza en une seule affiche.",
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
      "text": "Trois files de camions, zéro banc, une ombre de moins",
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
  "explanation": "Karim compte trois files de camions, zéro banc nouveau, une ombre de moins à midi."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "urbanisme",
      "right": "organisation raisonnée de l'espace habité"
    },
    {
      "left": "densification",
      "right": "processus qui resserre l'habitat"
    },
    {
      "left": "mixité",
      "right": "cohabitation d'usages et de voix"
    },
    {
      "left": "friche",
      "right": "terrain en attente, non un vide"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa ___ n'est un abri que si l'on en parle vraiment. (urbanisme déjà nom ou verbe à nominaliser)",
  "answer": "densification"
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
    "densification",
    "n'est",
    "un",
    "abri",
    "que",
    "si",
    "l'on",
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
  "word": "densification",
  "hint": "processus qui resserre l'habitat"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La urbanisme de trop vite n'aide personne, et Hawa Diallo reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Hawa Diallo reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m1/densite-jardins.svg",
      "word": "densite jardins"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/mixite-rive.svg",
      "word": "mixite rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/friche-figuier.svg",
      "word": "friche figuier"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/logement-partage.svg",
      "word": "logement partage"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Ce que le plan ne dit pas » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — La colline future : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : nominalisation ; encore que / pour autant que + subjonctif.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on promette des lanternes plus hautes, le parking projeté à la racine du figuier n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que la densification peut protéger les jardins, pour autant que l'on en discute avant les camions.
Ce que l'on nomme urbanisme, ici, n'est pas un slogan : organisation raisonnée de l'espace habité.
Encore que l'on promette, le parking projeté à la racine du figuier n'est pas un détail.
Léa Niyonzima concède que la densification peut protéger les jardins, pour autant que l'on en discute avant les camions.
Autrement dit, la densification n'est un abri que si elle cesse d'être un parking habillé de mots
Il ressort que garder deux voix dans le compte-rendu et une rampe avant les lanternes nouvelles
Patrick refuse qu'on accélère la pente au nom d'un urbanisme qui n'aurait d'urbain que la vitesse.
Solange demande qui paiera la rampe, car une colline sans rampe n'accueille que ceux qui montent vite.
La proposition qui reste debout est celle-ci : garder deux voix dans le compte-rendu et une rampe avant les lanternes nouvelles
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le calque de Nina Kayitesi d'un côté, la tribune de Marc Nkurunziza de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Léa Niyonzima transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Léa Niyonzima concède que la densification peut protéger les jardins, pour autant que l'on en discute avant les camions."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Léa Niyonzima, et à quelle condition ?",
  "options": [
    {
      "text": "Léa Niyonzima n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "la densification peut protéger les jardins — à condition que l'on en discute avant les camions",
      "correct": true
    },
    {
      "text": "Léa Niyonzima abandonne il s'agit de garder une colline habitable, non une affiche lumineuse",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on en discute avant les camions"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "urbanisme",
      "right": "organisation raisonnée de l'espace habité"
    },
    {
      "left": "densification",
      "right": "processus qui resserre l'habitat"
    },
    {
      "left": "mixité",
      "right": "cohabitation d'usages et de voix"
    },
    {
      "left": "friche",
      "right": "terrain en attente, non un vide"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPour autant que l'on ___ , Léa concède un point. (promettre, subj.)",
  "answer": "promette"
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
    "concède",
    "le",
    "point",
    "je",
    "n'abandonne",
    "pas",
    "friche",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "mixité",
  "hint": "cohabitation d'usages et de voix"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Léa Niyonzima écoute encore, et il fautons promettre avant de crier.",
  "correct_sentence": "Léa Niyonzima écoute encore, et il faut promettre avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m1/mixite-rive.svg",
      "word": "mixite rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/friche-figuier.svg",
      "word": "friche figuier"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/logement-partage.svg",
      "word": "logement partage"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/cle-pavillon.svg",
      "word": "cle pavillon"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur nominalisation ; encore que / pour autant que + subjonctif, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le calque de Nina Kayitesi et la tribune de Marc Nkurunziza distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Léa Niyonzima',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Rendre compte de deux regards sur la colline future sans les fusionner. Point : nominalisation ; encore que / pour autant que + subjonctif.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Ce que le plan ne dit pas
Léa Niyonzima — Ce que le plan ne dit pas
On parle trop vite de la colline de demain, comme si le mot dispensait d'en examiner le prix.
Encore que l'on promette des lanternes plus hautes, le parking projeté à la racine du figuier n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que la densification peut protéger les jardins, pour autant que l'on en discute avant les camions.
Ce que l'on nomme urbanisme, ici, n'est pas un slogan : organisation raisonnée de l'espace habité.
Nina Kayitesi déroule un calque : la friche n'est pas un vide, c'est une mémoire en attente de verbe.
Solange demande qui paiera la rampe, car une colline sans rampe n'accueille que ceux qui montent vite.
Félicie pose le bol : on ne mange pas un plan, on mange ce que la pente laisse pousser.
Dieudonné réparera l'escalier une fois que l'on aura nommé s'il reste un escalier.
La proposition qui reste debout est celle-ci : garder deux voix dans le compte-rendu et une rampe avant les lanternes nouvelles
Marc Nkurunziza : un compte-rendu n'est pas une victoire, c'est une hospitalité faite aux désaccords.
Nous clôturons sans fusionner les voix : le calque de Nina Kayitesi d'un côté, la tribune de Marc Nkurunziza de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on promette, le parking projeté à la racine du figuier n'est pas un détail.
Léa Niyonzima concède que la densification peut protéger les jardins, pour autant que l'on en discute avant les camions.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
la densification n'est un abri que si elle cesse d'être un parking habillé de mots
Léa Niyonzima, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : garder deux voix dans le compte-rendu et une rampe avant les lanternes nouvelles",
  "correct": true,
  "explanation": "garder deux voix dans le compte-rendu et une rampe avant les lanternes nouvelles"
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
      "text": "garder deux voix dans le compte-rendu et une rampe avant les lanternes nouvelles",
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
  "explanation": "garder deux voix dans le compte-rendu et une rampe avant les lanternes nouvelles"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "urbanisme",
      "right": "organisation raisonnée de l'espace habité"
    },
    {
      "left": "densification",
      "right": "processus qui resserre l'habitat"
    },
    {
      "left": "mixité",
      "right": "cohabitation d'usages et de voix"
    },
    {
      "left": "friche",
      "right": "terrain en attente, non un vide"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl ___ que deux voix valent mieux qu'une affiche. (ressortir)",
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
    "Un",
    "compte-rendu",
    "n'est",
    "pas",
    "une",
    "fusion",
    "des",
    "deux",
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
  "word": "friche",
  "hint": "terrain en attente, non un vide"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Léa Niyonzima est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Léa Niyonzima sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c1-m1/friche-figuier.svg",
      "word": "friche figuier"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/logement-partage.svg",
      "word": "logement partage"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/cle-pavillon.svg",
      "word": "cle pavillon"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/cour-fermee.svg",
      "word": "cour fermee"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Léa Niyonzima : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — nominalisation ; encore que / pour autant que + subjonctif',
    'EL',
    $c$Objectif
Maîtriser nominalisation ; encore que / pour autant que + subjonctif au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — nominalisation ; encore que / pour autant que + subjonctif
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on promette, le parking projeté à la racine du figuier n'est pas un détail.
Léa Niyonzima concède que la densification peut protéger les jardins, pour autant que l'on en discute avant les camions.
Autrement dit, la densification n'est un abri que si elle cesse d'être un parking habillé de mots
Il ressort que garder deux voix dans le compte-rendu et une rampe avant les lanternes nouvelles
Piège : indicatif après encore que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme urbanisme, ici, n'est pas un slogan : organisation raisonnée de l'espace habité.
Patrick refuse qu'on accélère la pente au nom d'un urbanisme qui n'aurait d'urbain que la vitesse.
Solange demande qui paiera la rampe, car une colline sans rampe n'accueille que ceux qui montent vite.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au mixité pour de vrai genre, et Hawa Diallo demande un registre plus net.
Correction : On va au mixité vraiment, et Hawa Diallo demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Après encore que, l'indicatif suffit pour une concession réelle.",
  "correct": false,
  "explanation": "Subjonctif."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle construction marque une concession réelle au subjonctif ?",
  "options": [
    {
      "text": "parce que + indicatif seulement",
      "correct": false
    },
    {
      "text": "encore que / pour autant que + subjonctif",
      "correct": true
    },
    {
      "text": "afin de + infinitif uniquement",
      "correct": false
    },
    {
      "text": "depuis que interdit toute concession",
      "correct": false
    }
  ],
  "explanation": "Encore que / pour autant que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "urbanisme",
      "right": "organisation raisonnée de l'espace habité"
    },
    {
      "left": "densification",
      "right": "processus qui resserre l'habitat"
    },
    {
      "left": "mixité",
      "right": "cohabitation d'usages et de voix"
    },
    {
      "left": "friche",
      "right": "terrain en attente, non un vide"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn dira la ___ plutôt qu'un slogan. (nom de densification)",
  "answer": "mixité"
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
    "autant",
    "que",
    "l'on",
    "promette",
    "Léa",
    "concède",
    "."
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
  "sentence_with_error": "On va au mixité pour de vrai genre, et Hawa Diallo demande un registre plus net.",
  "correct_sentence": "On va au mixité vraiment, et Hawa Diallo demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m1/logement-partage.svg",
      "word": "logement partage"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/cle-pavillon.svg",
      "word": "cle pavillon"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/cour-fermee.svg",
      "word": "cour fermee"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/lit-commun.svg",
      "word": "lit commun"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « nominalisation ; encore que / pour autant que + subjonctif » et deux pièges commentés."
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

  -- ===== Habiter autrement =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Habiter autrement'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Habiter autrement', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Habiter autrement',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Dégager l'essentiel de deux documents sur l'habitat partagé et en rédiger la synthèse. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Habiter autrement
Lila Sow : Radio Figuier. On parle trop vite de l'habitat partagé du Pavillon du Saule, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on garantisse une serrure pour chacun, la cour fermée à clé dès dix-neuf heures n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Hawa Diallo concède que partager le toit peut alléger les loyers inventés du Pavillon, pour autant que l'on nomme les heures de silence autant que les heures de soupe.
Aline Uwase : Ce que l'on nomme synthèse, ici, n'est pas un slogan : texte qui retient l'essentiel de plusieurs sources.
Patrick Habimana : Dieudonné habite le Pavillon : il répare, il n'écoute pas les conversations comme un loyer.
Hawa Diallo : Lila a enregistré une chronique où le mot famille revient trop souvent pour ne pas cacher une peur.
Joël Mugisha : Patrick demande ce à quoi l'on s'engage quand on pose son sac : la vaisselle, ou le silence ?
Rose Iradukunda : Aline insiste : la relative ce dont nous avons besoin n'est pas un ornement, c'est le noyau.
Solange Mukamana : Karim refuse qu'on appelle solidarité le fait de tout entendre à travers la planche.
Karim Bamba : Félicie apporte la soupe et sort : elle n'est pas une preuve que le toit suffit.
Félicie Ndayishimiye : Un chiffre, une trace : Yvette note quatre lits, deux clés, une soupe à vingt heures, zéro banc pour écrire.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de pouvoir rentrer sans demander pardon d'exister
Yvette : Sami dit qu'il aime le bruit ; Yvette répond qu'aimer le bruit n'est pas une loi.
Mado : Rose Iradukunda entend, dans « toit commun », ceci qui n'est pas dit : ceux qui disent famille élargie veulent parfois dire plus de témoins et moins de portes
Sami : Autrement dit, un toit commun n'est pas une famille : c'est un contrat de souffle et d'ombre
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : écrire une synthèse qui retienne loyers, heures calmes et ce dont personne ne veut parler : la clé
Nina Kayitesi : Marc : synthétiser, ce n'est pas couper les aspérités jusqu'à ce que tout le monde ait l'air d'accord.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : la chronique de Lila Sow d'un côté, l'entretien écrit de Dieudonné Hakizimana de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "la cour fermée à clé dès dix-neuf heures est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que la cour fermée à clé dès dix-neuf heures n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Rose Iradukunda, que reste-t-il implicite dans « toit commun » ?",
  "options": [
    {
      "text": "Que Lila interdira la soupe",
      "correct": false
    },
    {
      "text": "Plus de témoins, moins de portes",
      "correct": true
    },
    {
      "text": "Que Dieudonné veut vendre le Pavillon",
      "correct": false
    },
    {
      "text": "Que le silence est une punition inventée par Karim",
      "correct": false
    }
  ],
  "explanation": "ceux qui disent famille élargie veulent parfois dire plus de témoins et moins de portes"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "synthèse",
      "right": "texte qui retient l'essentiel de plusieurs sources"
    },
    {
      "left": "habitat",
      "right": "manière d'habiter, plus large que le toit"
    },
    {
      "left": "silence",
      "right": "heure nommée pour ne pas s'écraser"
    },
    {
      "left": "clé",
      "right": "droit de fermer, pas seulement d'ouvrir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVoici ce ___ nous avons besoin pour tenir. (dont)",
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
    "Voici",
    "ce",
    "dont",
    "nous",
    "avons",
    "besoin",
    "sous",
    "clé",
    "."
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
  "hint": "texte qui retient l'essentiel de plusieurs sources"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voici ce que nous avons besoin pour l'habitat partagé du Pavillon du Saule, et Hawa Diallo écrit encore.",
  "correct_sentence": "Voici ce dont nous avons besoin pour l'habitat partagé du Pavillon du Saule, et Hawa Diallo écrit encore.",
  "explanation": "Besoin se construit avec de : ce dont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m1/cle-pavillon.svg",
      "word": "cle pavillon"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/cour-fermee.svg",
      "word": "cour fermee"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/lit-commun.svg",
      "word": "lit commun"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/mobilite-douce.svg",
      "word": "mobilite douce"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « toit commun » et la concession de Hawa Diallo."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez la chronique de Lila Sow et l'entretien écrit de Dieudonné Hakizimana distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — La clé et la soupe',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Dégager l'essentiel de deux documents sur l'habitat partagé et en rédiger la synthèse. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « La clé et la soupe », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La clé et la soupe
On parle trop vite de l'habitat partagé du Pavillon du Saule, comme si le mot dispensait d'en examiner le prix.
Encore que l'on garantisse une serrure pour chacun, la cour fermée à clé dès dix-neuf heures n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que partager le toit peut alléger les loyers inventés du Pavillon, pour autant que l'on nomme les heures de silence autant que les heures de soupe.
Ce que l'on nomme synthèse, ici, n'est pas un slogan : texte qui retient l'essentiel de plusieurs sources.
Dieudonné habite le Pavillon : il répare, il n'écoute pas les conversations comme un loyer.
Lila a enregistré une chronique où le mot famille revient trop souvent pour ne pas cacher une peur.
Patrick demande ce à quoi l'on s'engage quand on pose son sac : la vaisselle, ou le silence ?
Aline insiste : la relative ce dont nous avons besoin n'est pas un ornement, c'est le noyau.
Karim refuse qu'on appelle solidarité le fait de tout entendre à travers la planche.
Félicie apporte la soupe et sort : elle n'est pas une preuve que le toit suffit.
Un chiffre, une trace : Yvette note quatre lits, deux clés, une soupe à vingt heures, zéro banc pour écrire.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de pouvoir rentrer sans demander pardon d'exister
Sami dit qu'il aime le bruit ; Yvette répond qu'aimer le bruit n'est pas une loi.
Rose Iradukunda entend, dans « toit commun », ceci qui n'est pas dit : ceux qui disent famille élargie veulent parfois dire plus de témoins et moins de portes
Autrement dit, un toit commun n'est pas une famille : c'est un contrat de souffle et d'ombre
La proposition qui reste debout est celle-ci : écrire une synthèse qui retienne loyers, heures calmes et ce dont personne ne veut parler : la clé
Marc : synthétiser, ce n'est pas couper les aspérités jusqu'à ce que tout le monde ait l'air d'accord.
Nous clôturons sans fusionner les voix : la chronique de Lila Sow d'un côté, l'entretien écrit de Dieudonné Hakizimana de l'autre, et le point où elles refusent de se ressembler.
Signé : Hawa Diallo, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner la chronique de Lila Sow et l'entretien écrit de Dieudonné Hakizimana en une seule affiche.",
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
      "text": "Quatre lits, deux clés, une soupe, zéro banc d'écriture",
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
  "explanation": "Yvette note quatre lits, deux clés, une soupe à vingt heures, zéro banc pour écrire."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "synthèse",
      "right": "texte qui retient l'essentiel de plusieurs sources"
    },
    {
      "left": "habitat",
      "right": "manière d'habiter, plus large que le toit"
    },
    {
      "left": "silence",
      "right": "heure nommée pour ne pas s'écraser"
    },
    {
      "left": "clé",
      "right": "droit de fermer, pas seulement d'ouvrir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVoilà ce ___ l'on s'engage en signant. (à quoi)",
  "answer": "à quoi"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Voilà",
    "ce",
    "à",
    "quoi",
    "l'on",
    "s'engage",
    "en",
    "signant",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "habitat",
  "hint": "manière d'habiter, plus large que le toit"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La synthèse de trop vite n'aide personne, et Rose Iradukunda reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Rose Iradukunda reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m1/cour-fermee.svg",
      "word": "cour fermee"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/lit-commun.svg",
      "word": "lit commun"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/mobilite-douce.svg",
      "word": "mobilite douce"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/trottoir-herbe.svg",
      "word": "trottoir herbe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « La clé et la soupe » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Habiter autrement : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : synthèse ; ce dont / ce à quoi ; relatives complexes.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on garantisse une serrure pour chacun, la cour fermée à clé dès dix-neuf heures n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que partager le toit peut alléger les loyers inventés du Pavillon, pour autant que l'on nomme les heures de silence autant que les heures de soupe.
Ce que l'on nomme synthèse, ici, n'est pas un slogan : texte qui retient l'essentiel de plusieurs sources.
Encore que l'on nomme, la cour fermée à clé dès dix-neuf heures n'est pas un détail.
Hawa Diallo concède que partager le toit peut alléger les loyers inventés du Pavillon, pour autant que l'on nomme les heures de silence autant que les heures de soupe.
Autrement dit, un toit commun n'est pas une famille : c'est un contrat de souffle et d'ombre
Il ressort qu'écrire une synthèse qui retienne loyers, heures calmes et ce dont personne ne veut parler : la clé
Lila a enregistré une chronique où le mot famille revient trop souvent pour ne pas cacher une peur.
Karim refuse qu'on appelle solidarité le fait de tout entendre à travers la planche.
La proposition qui reste debout est celle-ci : écrire une synthèse qui retienne loyers, heures calmes et ce dont personne ne veut parler : la clé
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : la chronique de Lila Sow d'un côté, l'entretien écrit de Dieudonné Hakizimana de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Hawa Diallo concède que partager le toit peut alléger les loyers inventés du Pavillon, pour autant que l'on nomme les heures de silence autant que les heures de soupe."
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
      "text": "partager le toit peut alléger les loyers inventés du Pavillon — à condition que l'on nomme les heures de silence autant que les heures de soupe",
      "correct": true
    },
    {
      "text": "Hawa Diallo abandonne il s'agit de pouvoir rentrer sans demander pardon d'exister",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on nomme les heures de silence autant que les heures de soupe"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "synthèse",
      "right": "texte qui retient l'essentiel de plusieurs sources"
    },
    {
      "left": "habitat",
      "right": "manière d'habiter, plus large que le toit"
    },
    {
      "left": "silence",
      "right": "heure nommée pour ne pas s'écraser"
    },
    {
      "left": "clé",
      "right": "droit de fermer, pas seulement d'ouvrir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa ___ retient deux sources sans les fusionner. (synthétiser → nom)",
  "answer": "synthèse"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Synthétiser",
    "n'est",
    "pas",
    "couper",
    "les",
    "aspérités",
    "des",
    "sources",
    "."
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
  "hint": "heure nommée pour ne pas s'écraser"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Hawa Diallo écoute encore, et il fautons nommer avant de crier.",
  "correct_sentence": "Hawa Diallo écoute encore, et il faut nommer avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m1/lit-commun.svg",
      "word": "lit commun"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/mobilite-douce.svg",
      "word": "mobilite douce"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/trottoir-herbe.svg",
      "word": "trottoir herbe"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/camion-pente.svg",
      "word": "camion pente"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur synthèse ; ce dont / ce à quoi ; relatives complexes, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez la chronique de Lila Sow et l'entretien écrit de Dieudonné Hakizimana distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Hawa Diallo',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Dégager l'essentiel de deux documents sur l'habitat partagé et en rédiger la synthèse. Point : synthèse ; ce dont / ce à quoi ; relatives complexes.

Consigne
Imitez le texte de Hawa Diallo.

Support — Hawa Diallo — La clé et la soupe
Hawa Diallo — La clé et la soupe
On parle trop vite de l'habitat partagé du Pavillon du Saule, comme si le mot dispensait d'en examiner le prix.
Encore que l'on garantisse une serrure pour chacun, la cour fermée à clé dès dix-neuf heures n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que partager le toit peut alléger les loyers inventés du Pavillon, pour autant que l'on nomme les heures de silence autant que les heures de soupe.
Ce que l'on nomme synthèse, ici, n'est pas un slogan : texte qui retient l'essentiel de plusieurs sources.
Dieudonné habite le Pavillon : il répare, il n'écoute pas les conversations comme un loyer.
Karim refuse qu'on appelle solidarité le fait de tout entendre à travers la planche.
Félicie apporte la soupe et sort : elle n'est pas une preuve que le toit suffit.
Sami dit qu'il aime le bruit ; Yvette répond qu'aimer le bruit n'est pas une loi.
La proposition qui reste debout est celle-ci : écrire une synthèse qui retienne loyers, heures calmes et ce dont personne ne veut parler : la clé
Marc : synthétiser, ce n'est pas couper les aspérités jusqu'à ce que tout le monde ait l'air d'accord.
Nous clôturons sans fusionner les voix : la chronique de Lila Sow d'un côté, l'entretien écrit de Dieudonné Hakizimana de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on nomme, la cour fermée à clé dès dix-neuf heures n'est pas un détail.
Hawa Diallo concède que partager le toit peut alléger les loyers inventés du Pavillon, pour autant que l'on nomme les heures de silence autant que les heures de soupe.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
un toit commun n'est pas une famille : c'est un contrat de souffle et d'ombre
Hawa Diallo, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : écrire une synthèse qui retienne loyers, heures calmes et ce dont personne ne veut parler : la clé",
  "correct": true,
  "explanation": "écrire une synthèse qui retienne loyers, heures calmes et ce dont personne ne veut parler : la clé"
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
      "text": "écrire une synthèse qui retienne loyers, heures calmes et ce dont personne ne veut parler : la clé",
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
  "explanation": "écrire une synthèse qui retienne loyers, heures calmes et ce dont personne ne veut parler : la clé"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "synthèse",
      "right": "texte qui retient l'essentiel de plusieurs sources"
    },
    {
      "left": "habitat",
      "right": "manière d'habiter, plus large que le toit"
    },
    {
      "left": "silence",
      "right": "heure nommée pour ne pas s'écraser"
    },
    {
      "left": "clé",
      "right": "droit de fermer, pas seulement d'ouvrir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl n'est pas vrai que cela ___ un slogan. (être, subj.)",
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
    "Hawa",
    "concède",
    "le",
    "partage",
    "pour",
    "autant",
    "que",
    "l'on",
    "nomme",
    "les",
    "règles",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "clé",
  "hint": "droit de fermer, pas seulement d'ouvrir"
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
      "image_path": "/elearning/mfk-c1-m1/mobilite-douce.svg",
      "word": "mobilite douce"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/trottoir-herbe.svg",
      "word": "trottoir herbe"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/camion-pente.svg",
      "word": "camion pente"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/relais-lanterne.svg",
      "word": "relais lanterne"
    }
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
    'EL — synthèse ; ce dont / ce à quoi ; relatives complexes',
    'EL',
    $c$Objectif
Maîtriser synthèse ; ce dont / ce à quoi ; relatives complexes au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — synthèse ; ce dont / ce à quoi ; relatives complexes
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on nomme, la cour fermée à clé dès dix-neuf heures n'est pas un détail.
Hawa Diallo concède que partager le toit peut alléger les loyers inventés du Pavillon, pour autant que l'on nomme les heures de silence autant que les heures de soupe.
Autrement dit, un toit commun n'est pas une famille : c'est un contrat de souffle et d'ombre
Il ressort qu'écrire une synthèse qui retienne loyers, heures calmes et ce dont personne ne veut parler : la clé
Piège : ce que + besoin au lieu de ce dont
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme synthèse, ici, n'est pas un slogan : texte qui retient l'essentiel de plusieurs sources.
Lila a enregistré une chronique où le mot famille revient trop souvent pour ne pas cacher une peur.
Karim refuse qu'on appelle solidarité le fait de tout entendre à travers la planche.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au silence pour de vrai genre, et Rose Iradukunda demande un registre plus net.
Correction : On va au silence vraiment, et Rose Iradukunda demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Ce dont nous avons besoin » évite le calque « ce que besoin ».",
  "correct": true,
  "explanation": "Construction de besoin."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle relative est juste pour le besoin ?",
  "options": [
    {
      "text": "ce que nous avons besoin",
      "correct": false
    },
    {
      "text": "ce dont nous avons besoin",
      "correct": true
    },
    {
      "text": "ce qui nous avons besoin",
      "correct": false
    },
    {
      "text": "dont que nous avons besoin",
      "correct": false
    }
  ],
  "explanation": "Besoin + de → ce dont."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "synthèse",
      "right": "texte qui retient l'essentiel de plusieurs sources"
    },
    {
      "left": "habitat",
      "right": "manière d'habiter, plus large que le toit"
    },
    {
      "left": "silence",
      "right": "heure nommée pour ne pas s'écraser"
    },
    {
      "left": "clé",
      "right": "droit de fermer, pas seulement d'ouvrir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPour autant que l'on ___ les règles, le partage tient. (nommer, subj.)",
  "answer": "nomme"
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
    "clé",
    "n'est",
    "pas",
    "un",
    "luxe",
    "c'est",
    "un",
    "droit",
    "de",
    "fermer",
    "."
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
  "sentence_with_error": "On va au silence pour de vrai genre, et Rose Iradukunda demande un registre plus net.",
  "correct_sentence": "On va au silence vraiment, et Rose Iradukunda demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m1/trottoir-herbe.svg",
      "word": "trottoir herbe"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/camion-pente.svg",
      "word": "camion pente"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/relais-lanterne.svg",
      "word": "relais lanterne"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/ville-fantastique.svg",
      "word": "ville fantastique"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « synthèse ; ce dont / ce à quoi ; relatives complexes » et deux pièges commentés."
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

  -- ===== Circuler à Rukiri-Nord =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Circuler à Rukiri-Nord'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Circuler à Rukiri-Nord', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Circuler à Rukiri-Nord',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Faire des recommandations pour une mobilité qui n'écrase pas la pente. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Circuler à Rukiri-Nord
Lila Sow : Radio Figuier. On parle trop vite de la mobilité sur la pente de Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on élargisse la route des camions, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Patrick Habimana concède que un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Aline Uwase : Ce que l'on nomme mobilité, ici, n'est pas un slogan : façon de se déplacer, pas seulement de rouler.
Patrick Habimana : Nina dessine un trait trop droit : la pente, elle, n'est pas droite.
Hawa Diallo : Joël dit qu'un camion n'a pas d'oreilles pour un « attention ».
Joël Mugisha : Léa propose un relais sous le saule, non un klaxon de plus.
Rose Iradukunda : Karim chiffre les minutes gagnées et refuse de les nommer un bonheur.
Solange Mukamana : Solange demande qui portera les jarres si le trottoir disparaît.
Karim Bamba : Dieudonné réparerait bien la rampe, pour autant qu'on la finance.
Félicie Ndayishimiye : Un chiffre, une trace : Joël a compté dix-huit lanternes, deux pauses, zéro place pour croiser un enfant.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de descendre vivant, pas seulement plus vite
Yvette : Sami court ; Yvette rappelle qu'un enfant n'est pas un obstacle.
Mado : Joël Mugisha entend, dans « fluidifier la colline », ceci qui n'est pas dit : fluidifier veut souvent dire faire passer les camions avant les genoux
Sami : Autrement dit, recommander, ce n'est pas crier : c'est dire ce qu'il convient de faire, et pour qui
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe
Nina Kayitesi : Marc : il convient que l'on nomme les genoux dans la motion, pas seulement les roues.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'émission de Radio Figuier d'un côté, la note de Nina Kayitesi sur la pente de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "le trottoir trop étroit pour Joël et les lanternes est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que le trottoir trop étroit pour Joël et les lanternes n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Joël Mugisha, que reste-t-il implicite dans « fluidifier la colline » ?",
  "options": [
    {
      "text": "Que Joël vendra les lanternes",
      "correct": false
    },
    {
      "text": "Les camions avant les genoux",
      "correct": true
    },
    {
      "text": "Que Nina veut interdire toute marche",
      "correct": false
    },
    {
      "text": "Que le figuier sera déplacé en bas",
      "correct": false
    }
  ],
  "explanation": "fluidifier veut souvent dire faire passer les camions avant les genoux"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "mobilité",
      "right": "façon de se déplacer, pas seulement de rouler"
    },
    {
      "left": "trottoir",
      "right": "bande où l'on peut croiser sans supplier"
    },
    {
      "left": "relais",
      "right": "pause humaine pour les lanternes"
    },
    {
      "left": "recommandation",
      "right": "avis argumenté, distinct d'un ordre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ avant d'accélérer. (ralentir, subj.)",
  "answer": "ralentisse"
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
    "ralentisse",
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
  "word": "mobilité",
  "hint": "façon de se déplacer, pas seulement de rouler"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il convient que l'on ralentir trop tard, et Patrick Habimana refuse d'accélérer la pente.",
  "correct_sentence": "Il convient que l'on ralentisse trop tard, et Patrick Habimana refuse d'accélérer la pente.",
  "explanation": "Il convient que + ralentisse."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m1/camion-pente.svg",
      "word": "camion pente"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/relais-lanterne.svg",
      "word": "relais lanterne"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/ville-fantastique.svg",
      "word": "ville fantastique"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/plan-2040.svg",
      "word": "plan 2040"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « fluidifier la colline » et la concession de Patrick Habimana."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'émission de Radio Figuier et la note de Nina Kayitesi sur la pente distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — La pente n''est pas une piste',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Faire des recommandations pour une mobilité qui n'écrase pas la pente. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « La pente n'est pas une piste », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La pente n'est pas une piste
On parle trop vite de la mobilité sur la pente de Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Encore que l'on élargisse la route des camions, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Ce que l'on nomme mobilité, ici, n'est pas un slogan : façon de se déplacer, pas seulement de rouler.
Nina dessine un trait trop droit : la pente, elle, n'est pas droite.
Joël dit qu'un camion n'a pas d'oreilles pour un « attention ».
Léa propose un relais sous le saule, non un klaxon de plus.
Karim chiffre les minutes gagnées et refuse de les nommer un bonheur.
Solange demande qui portera les jarres si le trottoir disparaît.
Dieudonné réparerait bien la rampe, pour autant qu'on la finance.
Un chiffre, une trace : Joël a compté dix-huit lanternes, deux pauses, zéro place pour croiser un enfant.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de descendre vivant, pas seulement plus vite
Sami court ; Yvette rappelle qu'un enfant n'est pas un obstacle.
Joël Mugisha entend, dans « fluidifier la colline », ceci qui n'est pas dit : fluidifier veut souvent dire faire passer les camions avant les genoux
Autrement dit, recommander, ce n'est pas crier : c'est dire ce qu'il convient de faire, et pour qui
La proposition qui reste debout est celle-ci : un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe
Marc : il convient que l'on nomme les genoux dans la motion, pas seulement les roues.
Nous clôturons sans fusionner les voix : l'émission de Radio Figuier d'un côté, la note de Nina Kayitesi sur la pente de l'autre, et le point où elles refusent de se ressembler.
Signé : Patrick Habimana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'émission de Radio Figuier et la note de Nina Kayitesi sur la pente en une seule affiche.",
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
      "text": "Dix-huit lanternes, deux pauses, zéro croisement d'enfant",
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
  "explanation": "Joël a compté dix-huit lanternes, deux pauses, zéro place pour croiser un enfant."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "mobilité",
      "right": "façon de se déplacer, pas seulement de rouler"
    },
    {
      "left": "trottoir",
      "right": "bande où l'on peut croiser sans supplier"
    },
    {
      "left": "relais",
      "right": "pause humaine pour les lanternes"
    },
    {
      "left": "recommandation",
      "right": "avis argumenté, distinct d'un ordre"
    }
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
  "word": "trottoir",
  "hint": "bande où l'on peut croiser sans supplier"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La mobilité de trop vite n'aide personne, et Joël Mugisha reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Joël Mugisha reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m1/relais-lanterne.svg",
      "word": "relais lanterne"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/ville-fantastique.svg",
      "word": "ville fantastique"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/plan-2040.svg",
      "word": "plan 2040"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/tour-ombre.svg",
      "word": "tour ombre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « La pente n'est pas une piste » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Circuler à Rukiri-Nord : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : il convient que / il s'agit de ; recommandations.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on élargisse la route des camions, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Ce que l'on nomme mobilité, ici, n'est pas un slogan : façon de se déplacer, pas seulement de rouler.
Encore que l'on ralentisse, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail.
Patrick Habimana concède que un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Autrement dit, recommander, ce n'est pas crier : c'est dire ce qu'il convient de faire, et pour qui
Il ressort qu'un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe
Joël dit qu'un camion n'a pas d'oreilles pour un « attention ».
Solange demande qui portera les jarres si le trottoir disparaît.
La proposition qui reste debout est celle-ci : un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'émission de Radio Figuier d'un côté, la note de Nina Kayitesi sur la pente de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Patrick Habimana concède que un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite."
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
      "text": "un relais de lanternes peut aider le soir — à condition que l'on n'y voie pas le droit de rouler plus vite",
      "correct": true
    },
    {
      "text": "Patrick Habimana abandonne il s'agit de descendre vivant, pas seulement plus vite",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y voie pas le droit de rouler plus vite"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "mobilité",
      "right": "façon de se déplacer, pas seulement de rouler"
    },
    {
      "left": "trottoir",
      "right": "bande où l'on peut croiser sans supplier"
    },
    {
      "left": "relais",
      "right": "pause humaine pour les lanternes"
    },
    {
      "left": "recommandation",
      "right": "avis argumenté, distinct d'un ordre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous recommandons que la cour ___ un relais. (ralentir, subj.)",
  "answer": "ralentisse"
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
    "ralentisse",
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
  "word": "relais",
  "hint": "pause humaine pour les lanternes"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Patrick Habimana écoute encore, et il fautons ralentir avant de crier.",
  "correct_sentence": "Patrick Habimana écoute encore, et il faut ralentir avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m1/ville-fantastique.svg",
      "word": "ville fantastique"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/plan-2040.svg",
      "word": "plan 2040"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/tour-ombre.svg",
      "word": "tour ombre"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/riviere-inventee.svg",
      "word": "riviere inventee"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur il convient que / il s'agit de ; recommandations, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'émission de Radio Figuier et la note de Nina Kayitesi sur la pente distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Patrick Habimana',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Faire des recommandations pour une mobilité qui n'écrase pas la pente. Point : il convient que / il s'agit de ; recommandations.

Consigne
Imitez le texte de Patrick Habimana.

Support — Patrick Habimana — La pente n'est pas une piste
Patrick Habimana — La pente n'est pas une piste
On parle trop vite de la mobilité sur la pente de Rukiri-Nord, comme si le mot dispensait d'en examiner le prix.
Encore que l'on élargisse la route des camions, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Patrick Habimana concède que un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Ce que l'on nomme mobilité, ici, n'est pas un slogan : façon de se déplacer, pas seulement de rouler.
Nina dessine un trait trop droit : la pente, elle, n'est pas droite.
Solange demande qui portera les jarres si le trottoir disparaît.
Dieudonné réparerait bien la rampe, pour autant qu'on la finance.
Sami court ; Yvette rappelle qu'un enfant n'est pas un obstacle.
La proposition qui reste debout est celle-ci : un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe
Marc : il convient que l'on nomme les genoux dans la motion, pas seulement les roues.
Nous clôturons sans fusionner les voix : l'émission de Radio Figuier d'un côté, la note de Nina Kayitesi sur la pente de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on ralentisse, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail.
Patrick Habimana concède que un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
recommander, ce n'est pas crier : c'est dire ce qu'il convient de faire, et pour qui
Patrick Habimana, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe",
  "correct": true,
  "explanation": "un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe"
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
      "text": "un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe",
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
  "explanation": "un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "mobilité",
      "right": "façon de se déplacer, pas seulement de rouler"
    },
    {
      "left": "trottoir",
      "right": "bande où l'on peut croiser sans supplier"
    },
    {
      "left": "relais",
      "right": "pause humaine pour les lanternes"
    },
    {
      "left": "recommandation",
      "right": "avis argumenté, distinct d'un ordre"
    }
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
  "word": "recommandation",
  "hint": "avis argumenté, distinct d'un ordre"
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
      "image_path": "/elearning/mfk-c1-m1/plan-2040.svg",
      "word": "plan 2040"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/tour-ombre.svg",
      "word": "tour ombre"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/riviere-inventee.svg",
      "word": "riviere inventee"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/recommandation-banc.svg",
      "word": "recommandation banc"
    }
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
    'EL — il convient que / il s''agit de ; recommandations',
    'EL',
    $c$Objectif
Maîtriser il convient que / il s'agit de ; recommandations au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — il convient que / il s'agit de ; recommandations
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on ralentisse, le trottoir trop étroit pour Joël et les lanternes n'est pas un détail.
Patrick Habimana concède que un relais de lanternes peut aider le soir, pour autant que l'on n'y voie pas le droit de rouler plus vite.
Autrement dit, recommander, ce n'est pas crier : c'est dire ce qu'il convient de faire, et pour qui
Il ressort qu'un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme mobilité, ici, n'est pas un slogan : façon de se déplacer, pas seulement de rouler.
Joël dit qu'un camion n'a pas d'oreilles pour un « attention ».
Solange demande qui portera les jarres si le trottoir disparaît.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au relais pour de vrai genre, et Joël Mugisha demande un registre plus net.
Correction : On va au relais vraiment, et Joël Mugisha demande un registre plus net.
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
      "left": "mobilité",
      "right": "façon de se déplacer, pas seulement de rouler"
    },
    {
      "left": "trottoir",
      "right": "bande où l'on peut croiser sans supplier"
    },
    {
      "left": "relais",
      "right": "pause humaine pour les lanternes"
    },
    {
      "left": "recommandation",
      "right": "avis argumenté, distinct d'un ordre"
    }
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
  "sentence_with_error": "On va au relais pour de vrai genre, et Joël Mugisha demande un registre plus net.",
  "correct_sentence": "On va au relais vraiment, et Joël Mugisha demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m1/tour-ombre.svg",
      "word": "tour ombre"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/riviere-inventee.svg",
      "word": "riviere inventee"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/recommandation-banc.svg",
      "word": "recommandation banc"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/motion-colline.svg",
      "word": "motion colline"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « il convient que / il s'agit de ; recommandations » et deux pièges commentés."
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

  -- ===== Midi sans ombre =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Midi sans ombre'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Midi sans ombre', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Midi sans ombre',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Décrire une Rukiri-Nord imaginaire pour faire entendre une peur vraie. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Midi sans ombre
Lila Sow : Radio Figuier. On parle trop vite de une Rukiri-Nord trop lisse, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface toute ombre sous le figuier, une tour qui avalerait midi n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que inventer peut aider à voir ce que le plan cache, pour autant que l'on n'oublie pas que le cauchemar parle du présent.
Aline Uwase : Ce que l'on nomme hypotypose, ici, n'est pas un slogan : description qui donne à voir, souvent au conditionnel.
Patrick Habimana : Mado écrit : la rivière prendrait une voix pour demander où l'on a mis ses roseaux.
Hawa Diallo : On dirait que les lanternes marcheraient toutes seules, fatiguées d'être portées.
Joël Mugisha : Si le figuier pouvait tousser, il tousserait la poussière des camions.
Rose Iradukunda : Aline : le conditionnel ici n'est pas une politesse, c'est une peinture.
Solange Mukamana : Patrick a peur des récits trop beaux : ils habillent souvent une coupe.
Karim Bamba : Rose coud une ombre trop large, exprès, pour le texte.
Félicie Ndayishimiye : Un chiffre, une trace : Dans le récit de Mado, midi n'a plus d'ombre à compter : zéro, dit-elle, et c'est déjà trop.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de reconnaître la peur avant qu'elle ne s'appelle progrès
Yvette : Joël n'aime pas les tours : elles n'ont pas de relais.
Mado : Sami entend, dans « ville parfaite », ceci qui n'est pas dit : la ville trop nette est souvent une ville où l'on n'a plus le droit de s'asseoir
Sami : Autrement dit, le fantastique ici n'est pas une évasion : c'est une loupe
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : écrire la colline comme si les racines parlaient, puis revenir au banc réel
Nina Kayitesi : Lila lira l'extrait à voix basse, comme si la colline écoutait.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'extrait inventé de Mado d'un côté, la photo de la pente prise par Léa de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une tour qui avalerait midi est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une tour qui avalerait midi n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Sami, que reste-t-il implicite dans « ville parfaite » ?",
  "options": [
    {
      "text": "Que Mado veut construire la tour",
      "correct": false
    },
    {
      "text": "Plus le droit de s'asseoir",
      "correct": true
    },
    {
      "text": "Que Léa refuse toute fiction",
      "correct": false
    },
    {
      "text": "Que Sami a mesuré midi avec une règle",
      "correct": false
    }
  ],
  "explanation": "la ville trop nette est souvent une ville où l'on n'a plus le droit de s'asseoir"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "hypotypose",
      "right": "description qui donne à voir, souvent au conditionnel"
    },
    {
      "left": "ombre",
      "right": "abri de midi, pas un défaut du plan"
    },
    {
      "left": "tour",
      "right": "verticale trop sûre d'elle"
    },
    {
      "left": "racine",
      "right": "mémoire du sol, plus ancienne que l'affiche"
    }
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
  "word": "hypotypose",
  "hint": "description qui donne à voir, souvent au conditionnel"
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
      "image_path": "/elearning/mfk-c1-m1/riviere-inventee.svg",
      "word": "riviere inventee"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/recommandation-banc.svg",
      "word": "recommandation banc"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/motion-colline.svg",
      "word": "motion colline"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/carte-rukiri.svg",
      "word": "carte rukiri"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « ville parfaite » et la concession de Mado."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'extrait inventé de Mado et la photo de la pente prise par Léa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Midi sans ombre',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Décrire une Rukiri-Nord imaginaire pour faire entendre une peur vraie. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Midi sans ombre », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Midi sans ombre
On parle trop vite de une Rukiri-Nord trop lisse, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface toute ombre sous le figuier, une tour qui avalerait midi n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que inventer peut aider à voir ce que le plan cache, pour autant que l'on n'oublie pas que le cauchemar parle du présent.
Ce que l'on nomme hypotypose, ici, n'est pas un slogan : description qui donne à voir, souvent au conditionnel.
Mado écrit : la rivière prendrait une voix pour demander où l'on a mis ses roseaux.
On dirait que les lanternes marcheraient toutes seules, fatiguées d'être portées.
Si le figuier pouvait tousser, il tousserait la poussière des camions.
Aline : le conditionnel ici n'est pas une politesse, c'est une peinture.
Patrick a peur des récits trop beaux : ils habillent souvent une coupe.
Rose coud une ombre trop large, exprès, pour le texte.
Un chiffre, une trace : Dans le récit de Mado, midi n'a plus d'ombre à compter : zéro, dit-elle, et c'est déjà trop.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de reconnaître la peur avant qu'elle ne s'appelle progrès
Joël n'aime pas les tours : elles n'ont pas de relais.
Sami entend, dans « ville parfaite », ceci qui n'est pas dit : la ville trop nette est souvent une ville où l'on n'a plus le droit de s'asseoir
Autrement dit, le fantastique ici n'est pas une évasion : c'est une loupe
La proposition qui reste debout est celle-ci : écrire la colline comme si les racines parlaient, puis revenir au banc réel
Lila lira l'extrait à voix basse, comme si la colline écoutait.
Nous clôturons sans fusionner les voix : l'extrait inventé de Mado d'un côté, la photo de la pente prise par Léa de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'extrait inventé de Mado et la photo de la pente prise par Léa en une seule affiche.",
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
      "text": "Midi sans ombre, zéro abri",
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
  "explanation": "Dans le récit de Mado, midi n'a plus d'ombre à compter : zéro, dit-elle, et c'est déjà trop."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "hypotypose",
      "right": "description qui donne à voir, souvent au conditionnel"
    },
    {
      "left": "ombre",
      "right": "abri de midi, pas un défaut du plan"
    },
    {
      "left": "tour",
      "right": "verticale trop sûre d'elle"
    },
    {
      "left": "racine",
      "right": "mémoire du sol, plus ancienne que l'affiche"
    }
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
  "word": "ombre",
  "hint": "abri de midi, pas un défaut du plan"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La hypotypose de trop vite n'aide personne, et Sami reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m1/recommandation-banc.svg",
      "word": "recommandation banc"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/motion-colline.svg",
      "word": "motion colline"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/carte-rukiri.svg",
      "word": "carte rukiri"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/assemblee-demain.svg",
      "word": "assemblee demain"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Midi sans ombre » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Midi sans ombre : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : conditionnel d'hypotypose ; comme si ; on dirait que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on efface toute ombre sous le figuier, une tour qui avalerait midi n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que inventer peut aider à voir ce que le plan cache, pour autant que l'on n'oublie pas que le cauchemar parle du présent.
Ce que l'on nomme hypotypose, ici, n'est pas un slogan : description qui donne à voir, souvent au conditionnel.
Encore que l'on invente, une tour qui avalerait midi n'est pas un détail.
Mado concède que inventer peut aider à voir ce que le plan cache, pour autant que l'on n'oublie pas que le cauchemar parle du présent.
Autrement dit, le fantastique ici n'est pas une évasion : c'est une loupe
Il ressort qu'écrire la colline comme si les racines parlaient, puis revenir au banc réel
On dirait que les lanternes marcheraient toutes seules, fatiguées d'être portées.
Patrick a peur des récits trop beaux : ils habillent souvent une coupe.
La proposition qui reste debout est celle-ci : écrire la colline comme si les racines parlaient, puis revenir au banc réel
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'extrait inventé de Mado d'un côté, la photo de la pente prise par Léa de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Mado concède que inventer peut aider à voir ce que le plan cache, pour autant que l'on n'oublie pas que le cauchemar parle du présent."
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
      "text": "inventer peut aider à voir ce que le plan cache — à condition que l'on n'oublie pas que le cauchemar parle du présent",
      "correct": true
    },
    {
      "text": "Mado abandonne il s'agit de reconnaître la peur avant qu'elle ne s'appelle progrès",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'oublie pas que le cauchemar parle du présent"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "hypotypose",
      "right": "description qui donne à voir, souvent au conditionnel"
    },
    {
      "left": "ombre",
      "right": "abri de midi, pas un défaut du plan"
    },
    {
      "left": "tour",
      "right": "verticale trop sûre d'elle"
    },
    {
      "left": "racine",
      "right": "mémoire du sol, plus ancienne que l'affiche"
    }
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
  "word": "tour",
  "hint": "verticale trop sûre d'elle"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Mado écoute encore, et il fautons inventer avant de crier.",
  "correct_sentence": "Mado écoute encore, et il faut inventer avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m1/motion-colline.svg",
      "word": "motion colline"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/carte-rukiri.svg",
      "word": "carte rukiri"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/assemblee-demain.svg",
      "word": "assemblee demain"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/compte-rendu.svg",
      "word": "compte rendu"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur conditionnel d'hypotypose ; comme si ; on dirait que, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'extrait inventé de Mado et la photo de la pente prise par Léa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Mado',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Décrire une Rukiri-Nord imaginaire pour faire entendre une peur vraie. Point : conditionnel d'hypotypose ; comme si ; on dirait que.

Consigne
Imitez le texte de Mado.

Support — Mado — Midi sans ombre
Mado — Midi sans ombre
On parle trop vite de une Rukiri-Nord trop lisse, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface toute ombre sous le figuier, une tour qui avalerait midi n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que inventer peut aider à voir ce que le plan cache, pour autant que l'on n'oublie pas que le cauchemar parle du présent.
Ce que l'on nomme hypotypose, ici, n'est pas un slogan : description qui donne à voir, souvent au conditionnel.
Mado écrit : la rivière prendrait une voix pour demander où l'on a mis ses roseaux.
Patrick a peur des récits trop beaux : ils habillent souvent une coupe.
Rose coud une ombre trop large, exprès, pour le texte.
Joël n'aime pas les tours : elles n'ont pas de relais.
La proposition qui reste debout est celle-ci : écrire la colline comme si les racines parlaient, puis revenir au banc réel
Lila lira l'extrait à voix basse, comme si la colline écoutait.
Nous clôturons sans fusionner les voix : l'extrait inventé de Mado d'un côté, la photo de la pente prise par Léa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on invente, une tour qui avalerait midi n'est pas un détail.
Mado concède que inventer peut aider à voir ce que le plan cache, pour autant que l'on n'oublie pas que le cauchemar parle du présent.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
le fantastique ici n'est pas une évasion : c'est une loupe
Mado, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : écrire la colline comme si les racines parlaient, puis revenir au banc réel",
  "correct": true,
  "explanation": "écrire la colline comme si les racines parlaient, puis revenir au banc réel"
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
      "text": "écrire la colline comme si les racines parlaient, puis revenir au banc réel",
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
  "explanation": "écrire la colline comme si les racines parlaient, puis revenir au banc réel"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "hypotypose",
      "right": "description qui donne à voir, souvent au conditionnel"
    },
    {
      "left": "ombre",
      "right": "abri de midi, pas un défaut du plan"
    },
    {
      "left": "tour",
      "right": "verticale trop sûre d'elle"
    },
    {
      "left": "racine",
      "right": "mémoire du sol, plus ancienne que l'affiche"
    }
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
  "word": "racine",
  "hint": "mémoire du sol, plus ancienne que l'affiche"
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
      "image_path": "/elearning/mfk-c1-m1/carte-rukiri.svg",
      "word": "carte rukiri"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/assemblee-demain.svg",
      "word": "assemblee demain"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/compte-rendu.svg",
      "word": "compte rendu"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/deux-documents.svg",
      "word": "deux documents"
    }
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
    'EL — conditionnel d''hypotypose ; comme si ; on dirait que',
    'EL',
    $c$Objectif
Maîtriser conditionnel d'hypotypose ; comme si ; on dirait que au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — conditionnel d'hypotypose ; comme si ; on dirait que
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on invente, une tour qui avalerait midi n'est pas un détail.
Mado concède que inventer peut aider à voir ce que le plan cache, pour autant que l'on n'oublie pas que le cauchemar parle du présent.
Autrement dit, le fantastique ici n'est pas une évasion : c'est une loupe
Il ressort qu'écrire la colline comme si les racines parlaient, puis revenir au banc réel
Piège : indicatif plat là où le conditionnel peint
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme hypotypose, ici, n'est pas un slogan : description qui donne à voir, souvent au conditionnel.
On dirait que les lanternes marcheraient toutes seules, fatiguées d'être portées.
Patrick a peur des récits trop beaux : ils habillent souvent une coupe.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au tour pour de vrai genre, et Sami demande un registre plus net.
Correction : On va au tour vraiment, et Sami demande un registre plus net.
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
      "left": "hypotypose",
      "right": "description qui donne à voir, souvent au conditionnel"
    },
    {
      "left": "ombre",
      "right": "abri de midi, pas un défaut du plan"
    },
    {
      "left": "tour",
      "right": "verticale trop sûre d'elle"
    },
    {
      "left": "racine",
      "right": "mémoire du sol, plus ancienne que l'affiche"
    }
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
  "answer": "hypotypose"
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
  "sentence_with_error": "On va au tour pour de vrai genre, et Sami demande un registre plus net.",
  "correct_sentence": "On va au tour vraiment, et Sami demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m1/assemblee-demain.svg",
      "word": "assemblee demain"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/compte-rendu.svg",
      "word": "compte rendu"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/deux-documents.svg",
      "word": "deux documents"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/micro-lila.svg",
      "word": "micro lila"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « conditionnel d'hypotypose ; comme si ; on dirait que » et deux pièges commentés."
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

  -- ===== Recommandations pour la colline =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Recommandations pour la colline'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Recommandations pour la colline', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Recommandations pour la colline',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Transformer l'analyse en motion claire pour l'assemblée sous le figuier. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Recommandations pour la colline
Lila Sow : Radio Figuier. On parle trop vite de la motion de la colline, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on signe trop vite une motion trop lisse, une action sans destinataires nommés n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé.
Aline Uwase : Ce que l'on nomme motion, ici, n'est pas un slogan : texte voté, plus précis qu'un cri.
Patrick Habimana : Solange lit trop vite ; Aline lui demande de nommer qui portera la rampe.
Hawa Diallo : Karim veut un calendrier, non une émotion.
Joël Mugisha : Léa rappelle la clé du Pavillon : la colline n'est pas qu'une route.
Rose Iradukunda : Joël demande un relais écrit, pas promis.
Solange Mukamana : Nina accepte de corriger le calque si la motion le force.
Karim Bamba : Dieudonné dit qu'il peut commencer jeudi, pour autant qu'on paie le fer.
Félicie Ndayishimiye : Un chiffre, une trace : Le banc a recensé onze voix pour la rampe, quatre abstentions, zéro pour le parking du figuier.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la motion puisse se relire dans un an sans honte
Yvette : Yvette : une motion sans date est un oubli poli.
Mado : Karim Bamba entend, dans « passer à l'action », ceci qui n'est pas dit : passer à l'action peut servir à ne plus entendre ceux qui marchent lentement
Sami : Autrement dit, une recommandation nomme qui fait, qui paie, qui peut refuser
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : trois gestes datés : rampe, relais, heures de camions, signés par le Bureau des Escales
Nina Kayitesi : Marc clôt : en vue de l'hivernage, il convient que l'on vote les trois gestes, pas l'affiche.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les notes d'assemblée d'Aline d'un côté, le brouillon de Solange de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une action sans destinataires nommés est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une action sans destinataires nommés n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Karim Bamba, que reste-t-il implicite dans « passer à l'action » ?",
  "options": [
    {
      "text": "Que Karim a déjà bétonné le figuier",
      "correct": false
    },
    {
      "text": "Ne plus entendre ceux qui marchent lentement",
      "correct": true
    },
    {
      "text": "Que Solange refuse tout vote",
      "correct": false
    },
    {
      "text": "Que le Bureau des Escales n'existe plus",
      "correct": false
    }
  ],
  "explanation": "passer à l'action peut servir à ne plus entendre ceux qui marchent lentement"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "motion",
      "right": "texte voté, plus précis qu'un cri"
    },
    {
      "left": "destinataire",
      "right": "personne nommée pour un geste"
    },
    {
      "left": "rampe",
      "right": "pente habitable pour qui ne court pas"
    },
    {
      "left": "assemblée",
      "right": "lieu où l'on vote après avoir entendu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ avant d'accélérer. (signer, subj.)",
  "answer": "signe"
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
    "signe",
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
  "word": "motion",
  "hint": "texte voté, plus précis qu'un cri"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il convient que l'on signer trop tard, et Solange Mukamana refuse d'accélérer la pente.",
  "correct_sentence": "Il convient que l'on signe trop tard, et Solange Mukamana refuse d'accélérer la pente.",
  "explanation": "Il convient que + signe."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m1/compte-rendu.svg",
      "word": "compte rendu"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/deux-documents.svg",
      "word": "deux documents"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/micro-lila.svg",
      "word": "micro lila"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/cahier-racines.svg",
      "word": "cahier racines"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « passer à l'action » et la concession de Solange Mukamana."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les notes d'assemblée d'Aline et le brouillon de Solange distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Trois gestes, pas un slogan',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Transformer l'analyse en motion claire pour l'assemblée sous le figuier. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Trois gestes, pas un slogan », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Trois gestes, pas un slogan
On parle trop vite de la motion de la colline, comme si le mot dispensait d'en examiner le prix.
Encore que l'on signe trop vite une motion trop lisse, une action sans destinataires nommés n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé.
Ce que l'on nomme motion, ici, n'est pas un slogan : texte voté, plus précis qu'un cri.
Solange lit trop vite ; Aline lui demande de nommer qui portera la rampe.
Karim veut un calendrier, non une émotion.
Léa rappelle la clé du Pavillon : la colline n'est pas qu'une route.
Joël demande un relais écrit, pas promis.
Nina accepte de corriger le calque si la motion le force.
Dieudonné dit qu'il peut commencer jeudi, pour autant qu'on paie le fer.
Un chiffre, une trace : Le banc a recensé onze voix pour la rampe, quatre abstentions, zéro pour le parking du figuier.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la motion puisse se relire dans un an sans honte
Yvette : une motion sans date est un oubli poli.
Karim Bamba entend, dans « passer à l'action », ceci qui n'est pas dit : passer à l'action peut servir à ne plus entendre ceux qui marchent lentement
Autrement dit, une recommandation nomme qui fait, qui paie, qui peut refuser
La proposition qui reste debout est celle-ci : trois gestes datés : rampe, relais, heures de camions, signés par le Bureau des Escales
Marc clôt : en vue de l'hivernage, il convient que l'on vote les trois gestes, pas l'affiche.
Nous clôturons sans fusionner les voix : les notes d'assemblée d'Aline d'un côté, le brouillon de Solange de l'autre, et le point où elles refusent de se ressembler.
Signé : Solange Mukamana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les notes d'assemblée d'Aline et le brouillon de Solange en une seule affiche.",
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
      "text": "Onze voix pour la rampe, zéro pour le parking",
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
  "explanation": "Le banc a recensé onze voix pour la rampe, quatre abstentions, zéro pour le parking du figuier."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "motion",
      "right": "texte voté, plus précis qu'un cri"
    },
    {
      "left": "destinataire",
      "right": "personne nommée pour un geste"
    },
    {
      "left": "rampe",
      "right": "pente habitable pour qui ne court pas"
    },
    {
      "left": "assemblée",
      "right": "lieu où l'on vote après avoir entendu"
    }
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
  "word": "destinataire",
  "hint": "personne nommée pour un geste"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La motion de trop vite n'aide personne, et Karim Bamba reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m1/deux-documents.svg",
      "word": "deux documents"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/micro-lila.svg",
      "word": "micro lila"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/cahier-racines.svg",
      "word": "cahier racines"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/parking-refuse.svg",
      "word": "parking refuse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Trois gestes, pas un slogan » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Recommandations pour la colline : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : connecteurs de recommandation ; il convient que ; en vue de.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on signe trop vite une motion trop lisse, une action sans destinataires nommés n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé.
Ce que l'on nomme motion, ici, n'est pas un slogan : texte voté, plus précis qu'un cri.
Encore que l'on signe, une action sans destinataires nommés n'est pas un détail.
Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé.
Autrement dit, une recommandation nomme qui fait, qui paie, qui peut refuser
Il ressort que trois gestes datés : rampe, relais, heures de camions, signés par le Bureau des Escales
Karim veut un calendrier, non une émotion.
Nina accepte de corriger le calque si la motion le force.
La proposition qui reste debout est celle-ci : trois gestes datés : rampe, relais, heures de camions, signés par le Bureau des Escales
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les notes d'assemblée d'Aline d'un côté, le brouillon de Solange de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé."
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
      "text": "il faut parfois voter avant la saison des pluies — à condition que l'on ait entendu la rampe, le trottoir et la clé",
      "correct": true
    },
    {
      "text": "Solange Mukamana abandonne il s'agit que la motion puisse se relire dans un an sans honte",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on ait entendu la rampe, le trottoir et la clé"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "motion",
      "right": "texte voté, plus précis qu'un cri"
    },
    {
      "left": "destinataire",
      "right": "personne nommée pour un geste"
    },
    {
      "left": "rampe",
      "right": "pente habitable pour qui ne court pas"
    },
    {
      "left": "assemblée",
      "right": "lieu où l'on vote après avoir entendu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous recommandons que la cour ___ un relais. (signer, subj.)",
  "answer": "signe"
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
    "signe",
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
  "word": "rampe",
  "hint": "pente habitable pour qui ne court pas"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Solange Mukamana écoute encore, et il fautons signer avant de crier.",
  "correct_sentence": "Solange Mukamana écoute encore, et il faut signer avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m1/micro-lila.svg",
      "word": "micro lila"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/cahier-racines.svg",
      "word": "cahier racines"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/parking-refuse.svg",
      "word": "parking refuse"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/saule-abri.svg",
      "word": "saule abri"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur connecteurs de recommandation ; il convient que ; en vue de, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les notes d'assemblée d'Aline et le brouillon de Solange distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Solange Mukamana',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Transformer l'analyse en motion claire pour l'assemblée sous le figuier. Point : connecteurs de recommandation ; il convient que ; en vue de.

Consigne
Imitez le texte de Solange Mukamana.

Support — Solange Mukamana — Trois gestes, pas un slogan
Solange Mukamana — Trois gestes, pas un slogan
On parle trop vite de la motion de la colline, comme si le mot dispensait d'en examiner le prix.
Encore que l'on signe trop vite une motion trop lisse, une action sans destinataires nommés n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé.
Ce que l'on nomme motion, ici, n'est pas un slogan : texte voté, plus précis qu'un cri.
Solange lit trop vite ; Aline lui demande de nommer qui portera la rampe.
Nina accepte de corriger le calque si la motion le force.
Dieudonné dit qu'il peut commencer jeudi, pour autant qu'on paie le fer.
Yvette : une motion sans date est un oubli poli.
La proposition qui reste debout est celle-ci : trois gestes datés : rampe, relais, heures de camions, signés par le Bureau des Escales
Marc clôt : en vue de l'hivernage, il convient que l'on vote les trois gestes, pas l'affiche.
Nous clôturons sans fusionner les voix : les notes d'assemblée d'Aline d'un côté, le brouillon de Solange de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on signe, une action sans destinataires nommés n'est pas un détail.
Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
une recommandation nomme qui fait, qui paie, qui peut refuser
Solange Mukamana, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : trois gestes datés : rampe, relais, heures de camions, signés par le Bureau des Escales",
  "correct": true,
  "explanation": "trois gestes datés : rampe, relais, heures de camions, signés par le Bureau des Escales"
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
      "text": "trois gestes datés : rampe, relais, heures de camions, signés par le Bureau des Escales",
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
  "explanation": "trois gestes datés : rampe, relais, heures de camions, signés par le Bureau des Escales"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "motion",
      "right": "texte voté, plus précis qu'un cri"
    },
    {
      "left": "destinataire",
      "right": "personne nommée pour un geste"
    },
    {
      "left": "rampe",
      "right": "pente habitable pour qui ne court pas"
    },
    {
      "left": "assemblée",
      "right": "lieu où l'on vote après avoir entendu"
    }
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
  "word": "assemblée",
  "hint": "lieu où l'on vote après avoir entendu"
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
      "image_path": "/elearning/mfk-c1-m1/cahier-racines.svg",
      "word": "cahier racines"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/parking-refuse.svg",
      "word": "parking refuse"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/saule-abri.svg",
      "word": "saule abri"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/escalier-pente.svg",
      "word": "escalier pente"
    }
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
    'EL — connecteurs de recommandation ; il convient que ; en vue de',
    'EL',
    $c$Objectif
Maîtriser connecteurs de recommandation ; il convient que ; en vue de au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — connecteurs de recommandation ; il convient que ; en vue de
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on signe, une action sans destinataires nommés n'est pas un détail.
Solange Mukamana concède que il faut parfois voter avant la saison des pluies, pour autant que l'on ait entendu la rampe, le trottoir et la clé.
Autrement dit, une recommandation nomme qui fait, qui paie, qui peut refuser
Il ressort que trois gestes datés : rampe, relais, heures de camions, signés par le Bureau des Escales
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme motion, ici, n'est pas un slogan : texte voté, plus précis qu'un cri.
Karim veut un calendrier, non une émotion.
Nina accepte de corriger le calque si la motion le force.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au rampe pour de vrai genre, et Karim Bamba demande un registre plus net.
Correction : On va au rampe vraiment, et Karim Bamba demande un registre plus net.
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
      "left": "motion",
      "right": "texte voté, plus précis qu'un cri"
    },
    {
      "left": "destinataire",
      "right": "personne nommée pour un geste"
    },
    {
      "left": "rampe",
      "right": "pente habitable pour qui ne court pas"
    },
    {
      "left": "assemblée",
      "right": "lieu où l'on vote après avoir entendu"
    }
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
  "sentence_with_error": "On va au rampe pour de vrai genre, et Karim Bamba demande un registre plus net.",
  "correct_sentence": "On va au rampe vraiment, et Karim Bamba demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m1/parking-refuse.svg",
      "word": "parking refuse"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/saule-abri.svg",
      "word": "saule abri"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/escalier-pente.svg",
      "word": "escalier pente"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/toit-partage.svg",
      "word": "toit partage"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « connecteurs de recommandation ; il convient que ; en vue de » et deux pièges commentés."
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

  -- ===== Compte-rendu 2040 =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Compte-rendu 2040'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Compte-rendu 2040', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Compte-rendu 2040',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Rendre compte oralement de deux documents sur la colline, horizon inventé 2040. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Compte-rendu 2040
Lila Sow : Radio Figuier. On parle trop vite de un horizon 2040 sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on annonce une colline sans files, un horizon qui n'a plus de bancs n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Aline Uwase : Ce que l'on nomme horizon, ici, n'est pas un slogan : projection, pas une excuse.
Patrick Habimana : Selon Nina, 2040 n'est qu'un calque pour forcer la rampe dès cette saison.
Hawa Diallo : D'après Marc, un horizon sans bancs n'est pas un avenir, c'est un oubli.
Joël Mugisha : Il ressort que les deux documents s'opposent sur la tour, pas sur la soif d'ombre.
Rose Iradukunda : Aline : on n'écrit pas « tout le monde pense », on écrit selon qui.
Solange Mukamana : Hawa refuse qu'on date 2040 pour ne plus dater les camions.
Karim Bamba : Joël demande si, en 2040, quelqu'un portera encore les lanternes.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a chronométré : quatre minutes, deux noms de sources, zéro slogan « ville parfaite ».
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que 2040 n'efface pas Joël sous les lanternes de 2026
Yvette : Mado glisse une phrase au conditionnel, puis rature : ce n'est plus le moment du fantastique.
Mado : Nina Kayitesi entend, dans « Rukiri-Nord 2040 », ceci qui n'est pas dit : 2040 sert parfois à ne plus devoir répondre des camions d'aujourd'hui
Sami : Autrement dit, le compte-rendu attribue : selon Nina ceci, d'après Marc cela, il ressort que la rampe précède la tour
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un oral de quatre minutes : deux sources, un désaccord, un geste 2026 qui rend 2040 habitable
Nina Kayitesi : Lila : le compte-rendu se clôt sur un geste, pas sur un nuage.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le calque annoté « 2040 » d'un côté, la chronique de Marc pour Radio Figuier de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un horizon qui n'a plus de bancs est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un horizon qui n'a plus de bancs n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Nina Kayitesi, que reste-t-il implicite dans « Rukiri-Nord 2040 » ?",
  "options": [
    {
      "text": "Que Nina a déjà vécu 2040",
      "correct": false
    },
    {
      "text": "Ne plus répondre des camions d'aujourd'hui",
      "correct": true
    },
    {
      "text": "Que Marc interdit toute projection",
      "correct": false
    },
    {
      "text": "Que Lila n'enregistre plus après 2026",
      "correct": false
    }
  ],
  "explanation": "2040 sert parfois à ne plus devoir répondre des camions d'aujourd'hui"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "horizon",
      "right": "projection, pas une excuse"
    },
    {
      "left": "attribution",
      "right": "selon / d'après, pour ne pas fusionner"
    },
    {
      "left": "geste",
      "right": "action datée, plus courte qu'un rêve"
    },
    {
      "left": "source",
      "right": "document nommé dans le compte-rendu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSelon Marc, il ___ que deux documents s'opposent. (ressortir)",
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
    "Marc",
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
  "word": "horizon",
  "hint": "projection, pas une excuse"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Selon Marc Nkurunziza, il ressort que les deux textes est d'accord, et Lila coupe le micro.",
  "correct_sentence": "Selon Marc Nkurunziza, il ressort que les deux textes sont d'accord, et Lila coupe le micro.",
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
      "image_path": "/elearning/mfk-c1-m1/saule-abri.svg",
      "word": "saule abri"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/escalier-pente.svg",
      "word": "escalier pente"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/toit-partage.svg",
      "word": "toit partage"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/horizon-ocre.svg",
      "word": "horizon ocre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « Rukiri-Nord 2040 » et la concession de Marc Nkurunziza."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le calque annoté « 2040 » et la chronique de Marc pour Radio Figuier distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — 2040 sans effacer 2026',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rendre compte oralement de deux documents sur la colline, horizon inventé 2040. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « 2040 sans effacer 2026 », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — 2040 sans effacer 2026
On parle trop vite de un horizon 2040 sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on annonce une colline sans files, un horizon qui n'a plus de bancs n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Ce que l'on nomme horizon, ici, n'est pas un slogan : projection, pas une excuse.
Selon Nina, 2040 n'est qu'un calque pour forcer la rampe dès cette saison.
D'après Marc, un horizon sans bancs n'est pas un avenir, c'est un oubli.
Il ressort que les deux documents s'opposent sur la tour, pas sur la soif d'ombre.
Aline : on n'écrit pas « tout le monde pense », on écrit selon qui.
Hawa refuse qu'on date 2040 pour ne plus dater les camions.
Joël demande si, en 2040, quelqu'un portera encore les lanternes.
Un chiffre, une trace : Léa a chronométré : quatre minutes, deux noms de sources, zéro slogan « ville parfaite ».
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que 2040 n'efface pas Joël sous les lanternes de 2026
Mado glisse une phrase au conditionnel, puis rature : ce n'est plus le moment du fantastique.
Nina Kayitesi entend, dans « Rukiri-Nord 2040 », ceci qui n'est pas dit : 2040 sert parfois à ne plus devoir répondre des camions d'aujourd'hui
Autrement dit, le compte-rendu attribue : selon Nina ceci, d'après Marc cela, il ressort que la rampe précède la tour
La proposition qui reste debout est celle-ci : un oral de quatre minutes : deux sources, un désaccord, un geste 2026 qui rend 2040 habitable
Lila : le compte-rendu se clôt sur un geste, pas sur un nuage.
Nous clôturons sans fusionner les voix : le calque annoté « 2040 » d'un côté, la chronique de Marc pour Radio Figuier de l'autre, et le point où elles refusent de se ressembler.
Signé : Marc Nkurunziza, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le calque annoté « 2040 » et la chronique de Marc pour Radio Figuier en une seule affiche.",
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
      "text": "Quatre minutes, deux sources, zéro slogan",
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
  "explanation": "Léa a chronométré : quatre minutes, deux noms de sources, zéro slogan « ville parfaite »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "horizon",
      "right": "projection, pas une excuse"
    },
    {
      "left": "attribution",
      "right": "selon / d'après, pour ne pas fusionner"
    },
    {
      "left": "geste",
      "right": "action datée, plus courte qu'un rêve"
    },
    {
      "left": "source",
      "right": "document nommé dans le compte-rendu"
    }
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
  "word": "attribution",
  "hint": "selon / d'après, pour ne pas fusionner"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La horizon de trop vite n'aide personne, et Nina Kayitesi reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m1/escalier-pente.svg",
      "word": "escalier pente"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/toit-partage.svg",
      "word": "toit partage"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/horizon-ocre.svg",
      "word": "horizon ocre"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/coeur-seuil.svg",
      "word": "coeur seuil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « 2040 sans effacer 2026 » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Compte-rendu 2040 : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : selon / d'après / il ressort que ; attribution des sources.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on annonce une colline sans files, un horizon qui n'a plus de bancs n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Ce que l'on nomme horizon, ici, n'est pas un slogan : projection, pas une excuse.
Encore que l'on attribue, un horizon qui n'a plus de bancs n'est pas un détail.
Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Autrement dit, le compte-rendu attribue : selon Nina ceci, d'après Marc cela, il ressort que la rampe précède la tour
Il ressort qu'un oral de quatre minutes : deux sources, un désaccord, un geste 2026 qui rend 2040 habitable
D'après Marc, un horizon sans bancs n'est pas un avenir, c'est un oubli.
Hawa refuse qu'on date 2040 pour ne plus dater les camions.
La proposition qui reste debout est celle-ci : un oral de quatre minutes : deux sources, un désaccord, un geste 2026 qui rend 2040 habitable
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le calque annoté « 2040 » d'un côté, la chronique de Marc pour Radio Figuier de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Marc Nkurunziza transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Marc Nkurunziza, et à quelle condition ?",
  "options": [
    {
      "text": "Marc Nkurunziza n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "se projeter peut aider à choisir un geste dès cette saison — à condition que l'on n'efface pas les noms de 2026 dans la projection",
      "correct": true
    },
    {
      "text": "Marc Nkurunziza abandonne il s'agit que 2040 n'efface pas Joël sous les lanternes de 2026",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'efface pas les noms de 2026 dans la projection"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "horizon",
      "right": "projection, pas une excuse"
    },
    {
      "left": "attribution",
      "right": "selon / d'après, pour ne pas fusionner"
    },
    {
      "left": "geste",
      "right": "action datée, plus courte qu'un rêve"
    },
    {
      "left": "source",
      "right": "document nommé dans le compte-rendu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl appert que horizon n'est pas un slogan.",
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
  "word": "geste",
  "hint": "action datée, plus courte qu'un rêve"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Marc Nkurunziza écoute encore, et il fautons attribuer avant de crier.",
  "correct_sentence": "Marc Nkurunziza écoute encore, et il faut attribuer avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m1/toit-partage.svg",
      "word": "toit partage"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/horizon-ocre.svg",
      "word": "horizon ocre"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/coeur-seuil.svg",
      "word": "coeur seuil"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/urbanisme-colline.svg",
      "word": "urbanisme colline"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur selon / d'après / il ressort que ; attribution des sources, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le calque annoté « 2040 » et la chronique de Marc pour Radio Figuier distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Marc Nkurunziza',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Rendre compte oralement de deux documents sur la colline, horizon inventé 2040. Point : selon / d'après / il ressort que ; attribution des sources.

Consigne
Imitez le texte de Marc Nkurunziza.

Support — Marc Nkurunziza — 2040 sans effacer 2026
Marc Nkurunziza — 2040 sans effacer 2026
On parle trop vite de un horizon 2040 sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on annonce une colline sans files, un horizon qui n'a plus de bancs n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Ce que l'on nomme horizon, ici, n'est pas un slogan : projection, pas une excuse.
Selon Nina, 2040 n'est qu'un calque pour forcer la rampe dès cette saison.
Hawa refuse qu'on date 2040 pour ne plus dater les camions.
Joël demande si, en 2040, quelqu'un portera encore les lanternes.
Mado glisse une phrase au conditionnel, puis rature : ce n'est plus le moment du fantastique.
La proposition qui reste debout est celle-ci : un oral de quatre minutes : deux sources, un désaccord, un geste 2026 qui rend 2040 habitable
Lila : le compte-rendu se clôt sur un geste, pas sur un nuage.
Nous clôturons sans fusionner les voix : le calque annoté « 2040 » d'un côté, la chronique de Marc pour Radio Figuier de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on attribue, un horizon qui n'a plus de bancs n'est pas un détail.
Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
le compte-rendu attribue : selon Nina ceci, d'après Marc cela, il ressort que la rampe précède la tour
Marc Nkurunziza, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un oral de quatre minutes : deux sources, un désaccord, un geste 2026 qui rend 2040 habitable",
  "correct": true,
  "explanation": "un oral de quatre minutes : deux sources, un désaccord, un geste 2026 qui rend 2040 habitable"
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
      "text": "un oral de quatre minutes : deux sources, un désaccord, un geste 2026 qui rend 2040 habitable",
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
  "explanation": "un oral de quatre minutes : deux sources, un désaccord, un geste 2026 qui rend 2040 habitable"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "horizon",
      "right": "projection, pas une excuse"
    },
    {
      "left": "attribution",
      "right": "selon / d'après, pour ne pas fusionner"
    },
    {
      "left": "geste",
      "right": "action datée, plus courte qu'un rêve"
    },
    {
      "left": "source",
      "right": "document nommé dans le compte-rendu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ les deux sources, on ne les fusionne pas. (attribuer, subj.)",
  "answer": "attribue"
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
    "attribue",
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
  "word": "source",
  "hint": "document nommé dans le compte-rendu"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Marc Nkurunziza est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Marc Nkurunziza sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c1-m1/horizon-ocre.svg",
      "word": "horizon ocre"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/coeur-seuil.svg",
      "word": "coeur seuil"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/urbanisme-colline.svg",
      "word": "urbanisme colline"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/densite-jardins.svg",
      "word": "densite jardins"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Marc Nkurunziza : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — selon / d''après / il ressort que ; attribution des sources',
    'EL',
    $c$Objectif
Maîtriser selon / d'après / il ressort que ; attribution des sources au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — selon / d'après / il ressort que ; attribution des sources
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on attribue, un horizon qui n'a plus de bancs n'est pas un détail.
Marc Nkurunziza concède que se projeter peut aider à choisir un geste dès cette saison, pour autant que l'on n'efface pas les noms de 2026 dans la projection.
Autrement dit, le compte-rendu attribue : selon Nina ceci, d'après Marc cela, il ressort que la rampe précède la tour
Il ressort qu'un oral de quatre minutes : deux sources, un désaccord, un geste 2026 qui rend 2040 habitable
Piège : fusionner les sources au lieu de les attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme horizon, ici, n'est pas un slogan : projection, pas une excuse.
D'après Marc, un horizon sans bancs n'est pas un avenir, c'est un oubli.
Hawa refuse qu'on date 2040 pour ne plus dater les camions.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au geste pour de vrai genre, et Nina Kayitesi demande un registre plus net.
Correction : On va au geste vraiment, et Nina Kayitesi demande un registre plus net.
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
      "left": "horizon",
      "right": "projection, pas une excuse"
    },
    {
      "left": "attribution",
      "right": "selon / d'après, pour ne pas fusionner"
    },
    {
      "left": "geste",
      "right": "action datée, plus courte qu'un rêve"
    },
    {
      "left": "source",
      "right": "document nommé dans le compte-rendu"
    }
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
  "sentence_with_error": "On va au geste pour de vrai genre, et Nina Kayitesi demande un registre plus net.",
  "correct_sentence": "On va au geste vraiment, et Nina Kayitesi demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m1/coeur-seuil.svg",
      "word": "coeur seuil"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/urbanisme-colline.svg",
      "word": "urbanisme colline"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/densite-jardins.svg",
      "word": "densite jardins"
    },
    {
      "image_path": "/elearning/mfk-c1-m1/mixite-rive.svg",
      "word": "mixite rive"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « selon / d'après / il ressort que ; attribution des sources » et deux pièges commentés."
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
