/*
  Seed eLearning MFK — B2 — Une culture commune

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b2-m3/
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
  v_module_title text := 'B2 — Une culture commune';
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
      'Grande étape B2-3 : comparer et résumer des œuvres inventées, débattre et dresser des portraits (Mado, Sami, Aline), poser un problème culturel et des solutions, parler d''une tendance et d''une création, puis rédiger une critique et un manifeste — Saison des Voix, pièce « La cour n''oublie pas », livre « Le figuier n''oublie pas », Veillée des lampions et tambour de Sami, au Seuil des Sources (Rukiri-Nord).',
      'B2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B2-3 : comparer et résumer des œuvres inventées, débattre et dresser des portraits (Mado, Sami, Aline), poser un problème culturel et des solutions, parler d''une tendance et d''une création, puis rédiger une critique et un manifeste — Saison des Voix, pièce « La cour n''oublie pas », livre « Le figuier n''oublie pas », Veillée des lampions et tambour de Sami, au Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'B2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Préférences et résumés =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Préférences et résumés'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Préférences et résumés', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Plus juste que spectaculaire',
    'CO',
    $c$Objectif
Repérer comparatifs et superlatifs ; suivre un avis argumenté sur deux œuvres inventées.

Consigne
Lisez le dialogue. Quelle œuvre préfère-t-on, et selon quels critères ?

Support — Table des Sources, avant la Saison des Voix
Aline : Cette année, la Saison des Voix ouvre sur deux œuvres : la pièce « La cour n'oublie pas » et le livre de Mado, « Le figuier n'oublie pas ».
Léa : La pièce m'a paru plus vive que le livre, mais le livre est plus dense que la pièce.
Patrick : Je trouve le tambour de Sami aussi présent que les répliques. Ce n'est pas un décor : c'est un personnage.
Marc : Attention aux formules paresseuses : on ne dit pas « plus bon ». On dit « meilleur ». Le meilleur acte, ce n'est pas le plus bruyant.
Hawa : Pour moi, le livre est moins spectaculaire que la pièce, et c'est précisément ce que je préfère.
Joël : Radio Figuier a lu le résumé le plus court. Trop court : on n'entendait plus le doute de la cour.
Rose : Le tissu ocre de la scène est aussi soigné que les phrases de Mado. L'œil compte autant que l'oreille.
Solange : Le public le plus attentif n'était pas le plus nombreux. Quelques bancs suffisent, si l'on écoute vraiment.
Karim : Je résumerais ainsi : une cour qui refuse d'oublier, un figuier qui garde les noms.
Lila : Le mieux, ce n'est pas d'applaudir plus fort. C'est de pouvoir raconter l'œuvre le lendemain, sans trahir.
Mado : Si l'on me demande mon avis, le livre n'est pas « plus bien » écrit : il est autrement écrit. Mieux, parfois ; moins clair, parfois.
Sami : Trois frappes valent mieux qu'un discours trop long. Le silence, lui, est le plus difficile à tenir.
Dieudonné : La mise en scène la moins chargée laisse voir le figuier. C'est mon critère.
Yvette : Donnez votre avis, mais justifiez-le. « J'aime » ne suffit plus à ce niveau.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc refuse la formule « plus bon » et rappelle « meilleur ».",
  "correct": true,
  "explanation": "Marc : on ne dit pas « plus bon ». On dit « meilleur »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Hawa, le livre est…",
  "options": [
    {
      "text": "plus spectaculaire que la pièce",
      "correct": false
    },
    {
      "text": "moins spectaculaire que la pièce",
      "correct": true
    },
    {
      "text": "aussi bruyant que le marché",
      "correct": false
    },
    {
      "text": "le plus vide de la saison",
      "correct": false
    }
  ],
  "explanation": "Hawa : « moins spectaculaire que la pièce »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus vive que",
      "right": "la pièce / le livre"
    },
    {
      "left": "aussi présent que",
      "right": "le tambour / les répliques"
    },
    {
      "left": "le plus attentif",
      "right": "le public des bancs"
    },
    {
      "left": "mieux",
      "right": "trois frappes / un long discours"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ne dit pas « plus bon » : on dit ___.",
  "answer": "meilleur"
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
    "livre",
    "est",
    "plus",
    "dense",
    "que",
    "la",
    "pièce",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "meilleur",
  "hint": "Forme attendue à la place de « plus bon », pour un acte ou un livre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le livre plus bon de la saison, et la cour en discute encore sous le figuier.",
  "correct_sentence": "C'est le meilleur livre de la saison, et la cour en discute encore sous le figuier.",
  "explanation": "Meilleur remplace plus bon."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/comparatif-oeuvre.svg",
      "word": "une comparaison"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/superlatif-avis.svg",
      "word": "un avis"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/resume-piece.svg",
      "word": "un résumé"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/etoile-saison.svg",
      "word": "une saison"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez quatre comparaisons entendues et l'avis que vous défendriez, avec un critère."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : La pièce est plus vive que le livre. Le livre est plus dense. Le mieux, c'est de pouvoir raconter."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Deux résumés, un avis',
    'CE',
    $c$Objectif
Lire des résumés d'œuvres inventées et un avis justifié (comparatifs, superlatifs).

Consigne
Lisez la fiche de la Saison des Voix, sans aller trop vite.

Support — Fiche d'Aline, Salle des Herbes
Saison des Voix — deux œuvres à tenir ensemble
1. Pièce « La cour n'oublie pas » : sous le figuier, une assemblée refuse d'effacer un nom. Le tambour de Sami scande les silences. La mise en scène est plus nue que celle de l'an passé.
2. Livre « Le figuier n'oublie pas » (Mado) : les mêmes faits, autrement. Moins de gestes, plus de phrases. Le chapitre le plus dur n'est pas le plus long.
3. Résumer, ce n'est pas tout raconter. C'est garder le conflit, le lieu, le geste qui reste.
4. La pièce est plus collective que le livre ; le livre est plus intérieur que la pièce.
5. Le public le moins nombreux, jeudi, a été le plus précis dans les questions.
6. Avis d'Aline : le meilleur critère n'est pas le bruit des lampions. C'est la phrase que l'on peut encore dire le lendemain.
7. Avis de Lila : Radio Figuier lira le résumé le plus court le matin, le plus complet le soir.
8. Ne dites pas « plus bien » : dites « mieux ». Ne dites pas « plus bon » : dites « meilleur ».
9. Comparer n'est pas classer pour humilier. C'est éclairer une préférence.
10. Karim : aussi fidèle l'une que l'autre, si l'on accepte deux langages.
11. Rose : le tissu de scène est aussi éloquent qu'une réplique, parfois mieux.
12. Solange : le tampon du Bureau n'évalue pas une œuvre. Il date une saison.
13. Donnez votre avis en trois mouvements : ce que l'œuvre fait, ce qu'elle refuse, ce qu'elle vous laisse.
14. Rukiri-Nord — à relire avant le débat du banc.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Résumer, d'après la fiche, consiste à tout raconter.",
  "correct": false,
  "explanation": "« Résumer, ce n'est pas tout raconter. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel est le meilleur critère, selon Aline ?",
  "options": [
    {
      "text": "Le bruit des lampions",
      "correct": false
    },
    {
      "text": "La phrase que l'on peut encore dire le lendemain",
      "correct": true
    },
    {
      "text": "Le nombre de spectateurs",
      "correct": false
    },
    {
      "text": "La longueur du chapitre",
      "correct": false
    }
  ],
  "explanation": "Aline : pas le bruit des lampions, mais la phrase du lendemain."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus collective",
      "right": "la pièce"
    },
    {
      "left": "plus intérieur",
      "right": "le livre"
    },
    {
      "left": "mieux",
      "right": "à la place de « plus bien »"
    },
    {
      "left": "aussi fidèle",
      "right": "les deux œuvres / Karim"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNe dites pas « plus bien » : dites ___.",
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
    "La",
    "pièce",
    "est",
    "plus",
    "collective",
    "que",
    "le",
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
  "word": "resume",
  "hint": "Texte court qui garde le conflit et le geste, sans tout déplier. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Cette mise en scène est plus bien pensée que l'an passé, et le public l'a dit sans hausser le ton.",
  "correct_sentence": "Cette mise en scène est mieux pensée que l'an passé, et le public l'a dit sans hausser le ton.",
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
      "image_path": "/elearning/mfk-b2-m3/superlatif-avis.svg",
      "word": "un avis"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/resume-piece.svg",
      "word": "un résumé"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/etoile-saison.svg",
      "word": "une saison"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/portrait-relatif.svg",
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
  "prompt": "Recopiez les deux résumés en six lignes chacun, puis ajoutez votre avis en trois phrases."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la fiche à voix haute, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire plus, moins, le mieux',
    'PO',
    $c$Objectif
Employer à l'oral comparatifs et superlatifs pour un avis culturel.

Consigne
Répétez les modèles, puis donnez votre avis sur une œuvre de la Saison des Voix.

Support — Modèles d'Aline et de Lila, banc du figuier
La pièce est plus vive que le livre.
Le livre est moins spectaculaire que la pièce.
Le tambour est aussi présent que les répliques.
C'est le meilleur acte, pas le plus long.
Le public le plus attentif n'était pas le plus nombreux.
Je préfère le livre, parce qu'il est plus intérieur.
Je résumerais en une phrase : la cour refuse d'oublier.
Le mieux, c'est de pouvoir raconter sans trahir.
Cette scène est mieux tenue que la précédente.
Lila : un avis sans critère n'est qu'un bruit.
Marc : « j'aime » ouvre ; « parce que » tient.
Mado : comparez les langages, pas les personnes.
Sami : trois frappes valent mieux qu'un commentaire trop sûr.
Yvette : le superlatif n'est pas une couronne. C'est une responsabilité.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Le mieux » porte sur une manière, pas sur un nom de qualité.",
  "correct": true,
  "explanation": "Le mieux = ce qui est préférable comme façon de faire."
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
      "text": "C'est le plus bon acte",
      "correct": false
    },
    {
      "text": "C'est le meilleur acte, pas le plus long",
      "correct": true
    },
    {
      "text": "C'est le meilleur acte, pas le plus bon",
      "correct": false
    },
    {
      "text": "C'est le plus bien acte",
      "correct": false
    }
  ],
  "explanation": "Meilleur + nom ; plus long reste régulier."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus vive que",
      "right": "comparatif d'infériorité inverse"
    },
    {
      "left": "aussi présent que",
      "right": "égalité"
    },
    {
      "left": "le plus attentif",
      "right": "superlatif"
    },
    {
      "left": "mieux tenue",
      "right": "adverbe / manière"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est le ___ acte, pas le plus long.",
  "answer": "meilleur"
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
    "le",
    "livre",
    "parce",
    "qu'il",
    "est",
    "plus",
    "intérieur",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "mieux",
  "hint": "Adverbe attendu à la place de « plus bien », pour une scène tenue."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le public le plus nombreux n'était pas le plus attentif, et c'est le plus bon critère pour moi.",
  "correct_sentence": "Le public le plus nombreux n'était pas le plus attentif, et c'est le meilleur critère pour moi.",
  "explanation": "Meilleur devant critère, pas plus bon."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/resume-piece.svg",
      "word": "un résumé"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/etoile-saison.svg",
      "word": "une saison"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/portrait-relatif.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/debat-culture.svg",
      "word": "un débat"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases : deux plus, deux moins, deux aussi, un superlatif, un mieux."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis un avis de quatre phrases à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon résumé argumenté',
    'PE',
    $c$Objectif
Écrire le résumé d'une œuvre inventée et un avis justifié (comparatifs, superlatifs).

Consigne
Imitez la note de Léa Niyonzima, sans aller trop vite.

Support — Note de Léa, cahier de la Saison
Léa Niyonzima — Seuil des Sources, Rukiri-Nord
Je résume d'abord « La cour n'oublie pas » : une assemblée refuse d'effacer un nom, et le tambour de Sami tient le silence comme on tient une corde.
Le livre de Mado, « Le figuier n'oublie pas », reprend le même nœud, mais il est plus intérieur que la pièce, moins spectaculaire, parfois mieux.
Je ne dirai pas que l'un est plus bon : le meilleur, pour moi, dépend du critère. Si je cherche le geste, je choisis la pièce ; si je cherche la phrase qui reste, je choisis le livre.
La mise en scène de cette saison est plus nue que celle de l'an passé, et c'est précisément ce qui la rend plus juste.
Le public le plus attentif n'était pas le plus nombreux. Quelques bancs ont suffi.
Mon avis : le mieux n'est pas de classer. C'est de pouvoir raconter les deux œuvres sans les confondre.
Aussi fidèle l'une que l'autre, si l'on accepte deux langages.
Je tiens à ce que Radio Figuier lise un résumé court le matin, un avis le soir, jamais l'inverse.
Si l'on me demande un superlatif, je dirai : le public le plus juste n'était pas le plus nombreux.
Comparer n'est pas humilier. Un avis sans critère n'est qu'un bruit, Aline l'a dit, et je le répète.
À relire avant le débat.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa classe les deux œuvres pour en humilier une.",
  "correct": false,
  "explanation": "« le mieux n'est pas de classer. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Si Léa cherche la phrase qui reste, que choisit-elle ?",
  "options": [
    {
      "text": "Le marché seulement",
      "correct": false
    },
    {
      "text": "Le livre de Mado",
      "correct": true
    },
    {
      "text": "Le tampon de Solange",
      "correct": false
    },
    {
      "text": "Le plus long acte",
      "correct": false
    }
  ],
  "explanation": "« si je cherche la phrase qui reste, je choisis le livre. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus intérieur",
      "right": "le livre / la pièce"
    },
    {
      "left": "plus nue",
      "right": "la mise en scène"
    },
    {
      "left": "le plus attentif",
      "right": "le public"
    },
    {
      "left": "aussi fidèle",
      "right": "deux langages"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ne dirai pas que l'un est plus bon : je dirai le ___.",
  "answer": "meilleur"
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
    "mieux",
    "n'est",
    "pas",
    "de",
    "classer",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "densite",
  "hint": "Qualité d'un livre plus chargé de phrases que de gestes. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je trouve le livre plus bon que la pièce, et je peux pourtant raconter les deux sans les confondre.",
  "correct_sentence": "Je trouve le livre meilleur que la pièce, et je peux pourtant raconter les deux sans les confondre.",
  "explanation": "Meilleur, pas plus bon."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/etoile-saison.svg",
      "word": "une saison"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/portrait-relatif.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/debat-culture.svg",
      "word": "un débat"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/pupitre-aline.svg",
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
  "prompt": "Imitez : douze à quinze lignes, un résumé, un avis, trois comparatifs, un superlatif."
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
    'EL — Comparatifs et superlatifs de l''avis',
    'EL',
    $c$Objectif
Retenir les formes régulières et les irréguliers meilleur / mieux pour un jugement culturel.

Consigne
Apprenez la fiche.

Support — Fiche du carnet d'Aline
Comparatif : plus + adj. + que / moins + adj. + que / aussi + adj. + que
plus vive que, moins spectaculaire que, aussi présent que
Superlatif : le / la / les + plus / moins + adj. : le plus attentif, la moins chargée
Irréguliers (à ne pas rater) :
bon → meilleur / le meilleur (jamais plus bon / le plus bon)
bien → mieux / le mieux (jamais plus bien / le plus bien)
petit → plus petit ou moindre (moindre : registre plus soutenu)
Mieux porte sur une manière : cette scène est mieux tenue.
Meilleur porte sur un nom : le meilleur acte, le meilleur critère.
Résumer : garder le conflit, le lieu, le geste ; ne pas tout déplier.
Donner son avis : ce que l'œuvre fait + ce qu'elle refuse + ce qu'elle laisse.
Comparer n'est pas humilier. Le superlatif engage : on doit pouvoir le justifier.
Attention : de plus en plus / de moins en moins (évolution, pas un duel).
Bien que + subjonctif : bien que ce soit moins clair, je tiens au livre.
À + le = au résumé ; de + le = du public.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut dire « le plus bon acte » au Seuil.",
  "correct": false,
  "explanation": "On dit le meilleur acte."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Cette scène est mieux tenue » emploie…",
  "options": [
    {
      "text": "un adjectif irrégulier",
      "correct": false
    },
    {
      "text": "un adverbe de manière",
      "correct": true
    },
    {
      "text": "un superlatif de petit",
      "correct": false
    },
    {
      "text": "un partitif",
      "correct": false
    }
  ],
  "explanation": "Mieux = adverbe (manière)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus / moins / aussi … que",
      "right": "comparatif"
    },
    {
      "left": "le plus / le moins",
      "right": "superlatif"
    },
    {
      "left": "meilleur",
      "right": "à la place de plus bon"
    },
    {
      "left": "mieux",
      "right": "à la place de plus bien"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCette scène est ___ tenue que la précédente.",
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
    "Le",
    "meilleur",
    "critère",
    "n'est",
    "pas",
    "le",
    "bruit",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "egalite",
  "hint": "Rapport aussi… que : ni plus, ni moins. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est la mise en scène le plus nue de la saison, et le figuier s'en trouve plus lisible.",
  "correct_sentence": "C'est la mise en scène la plus nue de la saison, et le figuier s'en trouve plus lisible.",
  "explanation": "Accord : la plus nue, avec mise en scène."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/portrait-relatif.svg",
      "word": "un portrait"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/debat-culture.svg",
      "word": "un débat"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/pupitre-aline.svg",
      "word": "un pupitre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/cadre-personnage.svg",
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
  "prompt": "Construisez dix phrases : quatre comparatifs, trois superlatifs, deux mieux, un meilleur."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis six formes : plus que, moins que, aussi que, le plus, meilleur, mieux."
}$j$::jsonb,
    9
  );

  -- ===== Débattre et portraits =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Débattre et portraits'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Débattre et portraits', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Celles et ceux dont on parle',
    'CO',
    $c$Objectif
Suivre un débat et des portraits ; pronoms relatifs pour éviter les répétitions.

Consigne
Lisez le dialogue. Qui est Mado, Sami, Aline, et quels relatifs relient les phrases ?

Support — Pupitre d'Aline, cercle des voix
Aline : Évitons de répéter les noms. Disons : Mado, qui a écrit « Le figuier n'oublie pas », tient le banc du soir.
Léa : C'est le livre que j'ai relu deux fois, celui dont les phrases restent après le thé.
Patrick : La cour où l'on joue « La cour n'oublie pas » n'est pas un théâtre fermé. C'est le Seuil.
Marc : Sami, à qui l'on doit les trois frappes, n'explique jamais trop. Le tambour dont il se sert suffit.
Hawa : Aline, avec laquelle on prépare la saison, refuse les portraits trop lisses.
Joël : Le pupitre sur lequel elle pose le cahier est le même que jeudi dernier.
Rose : Les tissus auxquels je pense pour le portrait de Mado sont ocre, pas d'apparat.
Solange : Le dossier duquel le Bureau garde une copie, c'est la fiche des voix, pas une biographie officielle.
Karim : Débattre, ce n'est pas vaincre. C'est relier les faits dont on n'est pas sûr.
Lila : Radio Figuier présentera trois portraits : celle qui écrit, celui qui frappe, celle qui tient le pupitre.
Mado : Le figuier sous lequel j'écris n'est pas une métaphore. C'est un arbre, et il a des racines.
Sami : Les soirs pendant lesquels on se tait valent ceux pendant lesquels on parle.
Dieudonné : Le masque auquel on a renoncé cette saison laisse voir les visages.
Yvette : Un portrait qui n'admet aucune ombre n'est pas un portrait. C'est une affiche.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline accepte les portraits trop lisses, d'après Hawa.",
  "correct": false,
  "explanation": "Hawa : Aline « refuse les portraits trop lisses »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que présentera Radio Figuier, selon Lila ?",
  "options": [
    {
      "text": "Un concours de clameurs",
      "correct": false
    },
    {
      "text": "Trois portraits : celle qui écrit, celui qui frappe, celle qui tient le pupitre",
      "correct": true
    },
    {
      "text": "Un tampon sans noms",
      "correct": false
    },
    {
      "text": "La fermeture du figuier",
      "correct": false
    }
  ],
  "explanation": "Lila : trois portraits, trois rôles."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui",
      "right": "Mado / sujet"
    },
    {
      "left": "dont",
      "right": "les phrases / le tambour"
    },
    {
      "left": "où",
      "right": "la cour / le Seuil"
    },
    {
      "left": "auquel / duquel",
      "right": "tissus / dossier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est le livre ___ les phrases restent après le thé.",
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
    "Mado",
    "qui",
    "a",
    "écrit",
    "le",
    "livre",
    "tient",
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
  "word": "dont",
  "hint": "Relatif pour parler de quelque chose, à la place d'un de répété."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voici le livre que je parle encore ce soir, et le banc où nous l'avons ouvert reste ocre.",
  "correct_sentence": "Voici le livre dont je parle encore ce soir, et le banc où nous l'avons ouvert reste ocre.",
  "explanation": "Parler de → dont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/debat-culture.svg",
      "word": "un débat"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/pupitre-aline.svg",
      "word": "un pupitre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/cadre-personnage.svg",
      "word": "un cadre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/mise-en-relief.svg",
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
  "prompt": "Notez six relatifs entendus et le nom qu'ils reprennent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Mado qui a écrit. Le livre que j'ai relu. Celui dont les phrases restent. La cour où l'on joue."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Trois portraits du Seuil',
    'CE',
    $c$Objectif
Lire des portraits liés par des relatifs (qui, que, dont, où, lequel, auquel, duquel).

Consigne
Lisez les portraits, sans aller trop vite.

Support — Cahier des voix, Table des Sources
Portraits — Saison des Voix (inventés, Seuil des Sources)
Mado : celle qui écrit « Le figuier n'oublie pas ». Le livre qu'elle relit à voix basse n'est jamais tout à fait le même. Les ratures dont elle s'occupe valent les phrases qu'elle garde. La cour où elle s'assoit n'attend pas une héroïne : elle attend une voix juste.
Sami Niyonteze : celui à qui l'on doit les trois frappes. Le tambour dont il se sert n'accompagne pas : il discute. Les soirs pendant lesquels il se tait pèsent autant que ceux pendant lesquels il joue. Le rythme auquel la pièce se fie vient de lui, pas d'un orchestre d'ailleurs.
Aline Uwase : celle avec laquelle on tient la saison. Le pupitre sur lequel elle pose le cahier n'est pas un trône. Les débats auxquels elle invite restent ouverts. Le dossier duquel le Bureau garde une copie porte des dates, pas des couronnes.
Ce qui relie les trois, c'est le refus de l'affiche trop lisse.
Léa : un portrait qui n'admet aucune ombre n'éclaire personne.
Patrick : la personne de laquelle on parle trop vite devient un masque.
Rose : les tissus auxquels je pense pour Mado sont ocre, comme la terre du Seuil.
Karim : débattre des portraits, c'est déjà les corriger.
Lila : on lira ces lignes au fil de Radio Figuier, sans musique d'apparat.
Karim : débattre d'un portrait, c'est déjà refuser l'affiche.
Yvette : un relatif bien choisi évite la répétition ; il n'invente pas une légende.
Rukiri-Nord — à ne pas coller au marché comme une étiquette.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le tambour de Sami, d'après le texte, se contente d'accompagner.",
  "correct": false,
  "explanation": "« n'accompagne pas : il discute. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que porte le dossier duquel le Bureau garde une copie ?",
  "options": [
    {
      "text": "Des couronnes",
      "correct": false
    },
    {
      "text": "Des dates, pas des couronnes",
      "correct": true
    },
    {
      "text": "Les ratures de Mado seulement",
      "correct": false
    },
    {
      "text": "Un orchestre d'ailleurs",
      "correct": false
    }
  ],
  "explanation": "« porte des dates, pas des couronnes. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui",
      "right": "celle / celui — sujet"
    },
    {
      "left": "dont",
      "right": "ratures / tambour"
    },
    {
      "left": "auquel",
      "right": "rythme / débats"
    },
    {
      "left": "duquel",
      "right": "dossier / Bureau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe tambour ___ Sami se sert n'accompagne pas.",
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
    "La",
    "cour",
    "où",
    "elle",
    "s'assoit",
    "attend",
    "une",
    "voix",
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
  "word": "portrait",
  "hint": "Texte qui dessine une personne du Seuil sans en faire une affiche."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voici le dossier que le Bureau garde une copie, et les dates y restent plus utiles que les couronnes.",
  "correct_sentence": "Voici le dossier duquel le Bureau garde une copie, et les dates y restent plus utiles que les couronnes.",
  "explanation": "Garder une copie de → duquel."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/pupitre-aline.svg",
      "word": "un pupitre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/cadre-personnage.svg",
      "word": "un cadre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/mise-en-relief.svg",
      "word": "un relief"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/probleme-culturel.svg",
      "word": "un problème"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez un portrait et soulignez tous les relatifs. Ajoutez deux phrases à vous."
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
    'PO — Dire qui, que, dont, où, lequel',
    'PO',
    $c$Objectif
Employer à l'oral les relatifs pour relier un débat et un portrait, sans répéter.

Consigne
Répétez, puis dressez le portrait d'une personne du Seuil.

Support — Modèles de Marc et d'Aline
Mado, qui écrit, tient le banc du soir.
Le livre que j'ai relu reste ouvert.
Le tambour dont Sami se sert discute.
La cour où l'on joue n'est pas fermée.
Le pupitre sur lequel Aline pose le cahier est simple.
Les débats auxquels elle invite restent ouverts.
Le dossier duquel le Bureau garde une copie porte des dates.
Celle à qui l'on doit la saison refuse l'affiche.
Patrick : répéter le nom à chaque phrase fatigue l'oreille.
Léa : un relatif bien placé tient lieu de politesse.
Hawa : « dont » reprend un de ; « que » reprend un objet direct.
Joël : « où » peut être un lieu ou un moment.
Rose : « lequel » s'accorde et suit souvent une préposition.
Yvette : débattre, c'est choisir le relatif juste, pas le plus savant.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Dont » reprend souvent une construction avec de.",
  "correct": true,
  "explanation": "Hawa : dont reprend un de."
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
      "text": "Le livre que je parle",
      "correct": false
    },
    {
      "text": "Le livre dont je parle",
      "correct": true
    },
    {
      "text": "Le livre où je parle de lui seulement",
      "correct": false
    },
    {
      "text": "Le livre lequel je parle",
      "correct": false
    }
  ],
  "explanation": "Parler de → dont."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui",
      "right": "sujet"
    },
    {
      "left": "que",
      "right": "objet direct"
    },
    {
      "left": "dont",
      "right": "reprise de de"
    },
    {
      "left": "auquel / duquel",
      "right": "à + lequel / de + lequel"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes débats ___ elle invite restent ouverts.",
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
    "tambour",
    "dont",
    "Sami",
    "se",
    "sert",
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
  "word": "relatif",
  "hint": "Mot qui reprend un nom déjà dit, pour éviter de le répéter."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voici le débat que je pense depuis jeudi, et Aline en garde encore le fil sous le figuier.",
  "correct_sentence": "Voici le débat auquel je pense depuis jeudi, et Aline en garde encore le fil sous le figuier.",
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
      "image_path": "/elearning/mfk-b2-m3/cadre-personnage.svg",
      "word": "un cadre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/mise-en-relief.svg",
      "word": "un relief"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/probleme-culturel.svg",
      "word": "un problème"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/solution-cour.svg",
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
  "prompt": "Écrivez sept phrases : qui, que, dont, où, lequel, auquel, duquel — un portrait en fil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis un portrait de six phrases à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon portrait du Seuil',
    'PE',
    $c$Objectif
Écrire le portrait argumenté d'une personnalité inventée, avec des relatifs variés.

Consigne
Imitez le portrait de Sami par Patrick Habimana, sans aller trop vite.

Support — Portrait de Sami, cahier bleu
Patrick Habimana — Seuil des Sources
Sami Niyonteze, qui ouvre la pièce par trois frappes, n'est pas un décor que l'on range après la saison.
Le tambour dont il se sert discute avec les répliques ; la cour où il s'installe n'a pas besoin d'estrade.
Les soirs pendant lesquels il se tait pèsent autant que ceux pendant lesquels il joue, et c'est précisément ce que j'admire.
Le rythme auquel « La cour n'oublie pas » se fie vient de lui. Le silence duquel on parle trop vite, lui, le tient vraiment.
Je ne ferai pas de lui une affiche. Un portrait qui n'admet aucune ombre n'éclaire personne.
Aline, avec laquelle il prépare les entrées, refuse aussi le lisse. Mado, dont les phrases restent, l'écoute plus qu'elle ne le commente.
Ce que je retiens : une personne à qui l'on doit un tempo, pas une légende.
Si Radio Figuier lit ce texte, qu'on le lise lentement. Le mieux n'est pas d'en faire plus.
La cour où il s'installe n'a pas besoin d'estrade, je l'ai dit, et je le redis : un portrait trop lisse n'éclaire personne.
Je tiens à l'ombre autant qu'aux trois frappes. Sans elle, Sami deviendrait un masque.
Patrick
Copie : Aline Uwase, Lila Sow
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick veut faire de Sami une affiche de saison.",
  "correct": false,
  "explanation": "« Je ne ferai pas de lui une affiche. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "D'où vient le rythme auquel la pièce se fie, selon Patrick ?",
  "options": [
    {
      "text": "D'un orchestre d'ailleurs",
      "correct": false
    },
    {
      "text": "De Sami",
      "correct": true
    },
    {
      "text": "Du tampon de Solange",
      "correct": false
    },
    {
      "text": "Du marché seulement",
      "correct": false
    }
  ],
  "explanation": "« Le rythme auquel la pièce se fie vient de lui. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui",
      "right": "Sami / sujet"
    },
    {
      "left": "dont",
      "right": "tambour / phrases de Mado"
    },
    {
      "left": "auquel",
      "right": "rythme / se fier à"
    },
    {
      "left": "duquel",
      "right": "silence / parler de"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe tambour ___ il se sert discute avec les répliques.",
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
    "Je",
    "ne",
    "ferai",
    "pas",
    "de",
    "lui",
    "une",
    "affiche",
    "."
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
  "hint": "Ce que Sami tient parfois mieux qu'une phrase trop sûre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voici le rythme que la pièce se fie trop vite, et Sami le reprend encore sous le figuier.",
  "correct_sentence": "Voici le rythme auquel la pièce se fie trop vite, et Sami le reprend encore sous le figuier.",
  "explanation": "Se fier à → auquel."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/mise-en-relief.svg",
      "word": "un relief"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/probleme-culturel.svg",
      "word": "un problème"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/solution-cour.svg",
      "word": "une solution"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/scene-herbes.svg",
      "word": "une scène"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : douze à quinze lignes, un portrait, au moins cinq relatifs différents."
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
    'EL — Relatifs pour ne pas répéter',
    'EL',
    $c$Objectif
Retenir qui, que, dont, où, lequel, auquel, duquel et leurs constructions.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, relatifs
qui = sujet : Mado qui écrit ; Sami qui frappe
que = objet direct : le livre que j'ai relu ; le portrait que l'on refuse
dont = de + nom : le livre dont je parle ; le tambour dont il se sert ; les phrases dont elle s'occupe
où = lieu ou moment : la cour où l'on joue ; le soir où l'on se tait
lequel / laquelle / lesquels / lesquelles : après préposition, accord
sur lequel, pendant lesquels, avec laquelle
auquel = à + lequel ; auxquels / à laquelle / auxquelles
duquel = de + lequel (plus lourd que dont ; utile après nom déjà précisé)
à qui / de qui : souvent pour une personne (plus naturel que auquel / duquel)
Éviter : le livre que je parle (parler de → dont)
Éviter : le débat que je pense (penser à → auquel)
Un relatif bien choisi évite la répétition sans devenir un masque savant.
Portrait : faits + ombre + lien à la cour. Pas d'affiche.
Bien que + subj. : bien que ce soit incomplet, le portrait tient.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Dont » et « que » sont interchangeables après parler.",
  "correct": false,
  "explanation": "Parler de → dont. Que ne reprend pas de."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Les débats auxquels elle invite » vient de…",
  "options": [
    {
      "text": "inviter de",
      "correct": false
    },
    {
      "text": "inviter à",
      "correct": true
    },
    {
      "text": "inviter sur",
      "correct": false
    },
    {
      "text": "inviter dont",
      "correct": false
    }
  ],
  "explanation": "Inviter à → auxquels."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui",
      "right": "sujet"
    },
    {
      "left": "que",
      "right": "objet direct"
    },
    {
      "left": "dont",
      "right": "reprise de de"
    },
    {
      "left": "auquel / duquel",
      "right": "à + lequel / de + lequel"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVoici le livre ___ je parle encore ce soir.",
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
    "La",
    "cour",
    "où",
    "l'on",
    "joue",
    "n'est",
    "pas",
    "fermée",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lequel",
  "hint": "Relatif qui s'accorde et suit souvent une préposition."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les tissus que je pense pour le portrait sont ocre, et Rose les a tendus avant le débat.",
  "correct_sentence": "Les tissus auxquels je pense pour le portrait sont ocre, et Rose les a tendus avant le débat.",
  "explanation": "Penser à → auxquels."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/probleme-culturel.svg",
      "word": "un problème"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/solution-cour.svg",
      "word": "une solution"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/scene-herbes.svg",
      "word": "une scène"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/pronoms-en-y.svg",
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
  "prompt": "Tableau : qui / que / dont / où / lequel / auquel / duquel — une phrase chacun, portrait compris."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et sept relatives, une par forme."
}$j$::jsonb,
    9
  );

  -- ===== Problème culturel, solutions =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Problème culturel, solutions'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Problème culturel, solutions', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — C''est la veillée qui se presse',
    'CO',
    $c$Objectif
Repérer la mise en relief et un problème culturel inventé, avec des solutions de cour.

Consigne
Lisez le dialogue. Quel est le problème, et qui propose quoi ?

Support — Avant la Veillée des lampions, Salle des Herbes
Aline : Ce qui nous inquiète, c'est la vitesse. Ce n'est pas le tambour. C'est la veillée qui se presse.
Léa : C'est le cortège que l'on a trop chargé. Les lampions avancent plus vite que les phrases.
Patrick : Ce que je refuse, c'est de transformer une spécificité du Seuil en spectacle pour passer.
Marc : C'est Sami qui devrait poser le tempo, pas le marché. C'est le silence que l'on a oublié.
Hawa : Le problème, ce n'est pas la fête. C'est la fête qui n'ose plus s'arrêter.
Joël : C'est une solution simple que je propose : moins de lampions, plus de bancs.
Rose : C'est le tissu que l'on montre trop tôt. Qu'on le déplie après la troisième frappe.
Solange : Ce qui manque, c'est une règle écrite. Le Bureau peut dater un créneau, pas inventer une âme.
Karim : C'est nous qui tenons la cour. Si l'on cède au trop-vite, ce n'est plus une veillée, c'est une file.
Lila : Radio Figuier ne relayera pas un défilé. C'est la voix que l'on gardera, pas le compte des lampions.
Mado : Ce que le livre a déjà dit, c'est ceci : une cour qui oublie son rythme s'oublie.
Sami : Trois frappes. C'est moi qui les dois. Si l'on parle par-dessus, je m'arrête.
Dieudonné : C'est l'entrée par les Herbes qui calme. L'autre porte pousse déjà trop.
Yvette : Un problème culturel n'est pas une honte. C'est une question à tenir ensemble.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline dit que le tambour est la cause principale de l'inquiétude.",
  "correct": false,
  "explanation": "« Ce n'est pas le tambour. C'est la veillée qui se presse. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle solution Joël propose-t-il ?",
  "options": [
    {
      "text": "Plus de lampions, moins de bancs",
      "correct": false
    },
    {
      "text": "Moins de lampions, plus de bancs",
      "correct": true
    },
    {
      "text": "Fermer Radio Figuier",
      "correct": false
    },
    {
      "text": "Interdire le tambour",
      "correct": false
    }
  ],
  "explanation": "Joël : moins de lampions, plus de bancs."
}$j$::jsonb,
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
      "right": "Sami / nous / la veillée"
    },
    {
      "left": "c'est… que",
      "right": "le cortège / le silence / le tissu"
    },
    {
      "left": "ce qui… c'est",
      "right": "la vitesse / une règle"
    },
    {
      "left": "ce que… c'est",
      "right": "le refus / la phrase du livre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est Sami ___ devrait poser le tempo.",
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
    "la",
    "veillée",
    "qui",
    "se",
    "presse",
    "."
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
  "hint": "Tour c'est… qui / que : on met en avant un élément de la phrase."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le silence qui on a oublié trop vite, et Sami refuse de frapper par-dessus le cortège.",
  "correct_sentence": "C'est le silence que l'on a oublié trop vite, et Sami refuse de frapper par-dessus le cortège.",
  "explanation": "Objet : c'est… que, pas qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/solution-cour.svg",
      "word": "une solution"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/scene-herbes.svg",
      "word": "une scène"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/pronoms-en-y.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/registre-familier.svg",
      "word": "un registre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez le problème, trois mises en relief et deux solutions entendues."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : C'est la veillée qui se presse. Ce qui nous inquiète, c'est la vitesse. C'est Sami qui pose le tempo."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Spécificité et solutions',
    'CE',
    $c$Objectif
Lire un texte argumenté sur une spécificité culturelle inventée et des solutions.

Consigne
Lisez le texte de la cour, sans aller trop vite.

Support — Note de la cour, Veillée des lampions
Note — Une spécificité à ne pas vider
Ce qui fait la Veillée des lampions, ce n'est pas le nombre de lumières. C'est le moment où le cortège s'arrête pour le tambour de Sami.
Le problème, cette saison, c'est que l'on avance trop vite. On dirait une file, plus une veille.
C'est le marché qui pousse, parfois sans le vouloir. C'est nous qui cédons, parfois sans le voir.
Solutions proposées (à débattre, pas à imposer) :
1. C'est Sami qui ouvre et qui ferme. Trois frappes. Pas de phrase par-dessus.
2. C'est le tissu de Rose que l'on déplie après la troisième frappe, pas avant.
3. Ce qui manque, c'est un banc de silence : moins de lampions sur ce côté, plus d'écoute.
4. C'est l'entrée par la Salle des Herbes qui calme ; l'autre porte, on la garde pour la fin.
5. Radio Figuier relayera la voix, pas le compte. Ce que l'on garde, c'est une phrase, pas un total.
Mado rappelle : une cour qui oublie son rythme s'oublie.
Aline : un problème culturel n'est pas une honte. C'est une question.
Karim : si l'on refuse toute règle, ce n'est plus une spécificité, c'est un caprice.
Solange datera le créneau. Elle n'inventera pas l'âme.
Rukiri-Nord — à lire avant d'allumer le premier lampion.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On doit déplier le tissu de Rose avant la troisième frappe.",
  "correct": false,
  "explanation": "Après la troisième frappe, pas avant."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que relayera Radio Figuier, d'après la note ?",
  "options": [
    {
      "text": "Le compte des lampions",
      "correct": false
    },
    {
      "text": "La voix, pas le compte",
      "correct": true
    },
    {
      "text": "Un orchestre d'ailleurs",
      "correct": false
    },
    {
      "text": "La fermeture du Bureau",
      "correct": false
    }
  ],
  "explanation": "« relayera la voix, pas le compte. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ce qui fait la veillée",
      "right": "l'arrêt pour le tambour"
    },
    {
      "left": "c'est Sami qui",
      "right": "ouvre et ferme"
    },
    {
      "left": "ce qui manque",
      "right": "un banc de silence"
    },
    {
      "left": "ce que l'on garde",
      "right": "une phrase"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est l'entrée par les Herbes ___ calme.",
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
    "qui",
    "nous",
    "inquiète",
    "c'est",
    "la",
    "vitesse",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "veillée",
  "hint": "Soir de lampions et de tambour, à ne pas vider en file. (sans accent sur le premier e)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est nous que tenons encore la cour, et le cortège devra s'arrêter pour les trois frappes.",
  "correct_sentence": "C'est nous qui tenons encore la cour, et le cortège devra s'arrêter pour les trois frappes.",
  "explanation": "Sujet : c'est… qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/scene-herbes.svg",
      "word": "une scène"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/pronoms-en-y.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/registre-familier.svg",
      "word": "un registre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/processus-creation.svg",
      "word": "une création"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le problème en deux phrases et les cinq solutions. Ajoutez la vôtre en mise en relief."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la note, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire c''est… qui, ce qui… c''est',
    'PO',
    $c$Objectif
Mettre en relief à l'oral un problème culturel et une solution.

Consigne
Répétez, puis posez un problème du Seuil et une solution, avec c'est… / ce qui…

Support — Modèles d'Aline et de Karim
C'est la veillée qui se presse.
C'est le silence que l'on a oublié.
C'est Sami qui pose le tempo.
C'est nous qui tenons la cour.
Ce qui nous inquiète, c'est la vitesse.
Ce que je refuse, c'est le spectacle pour passer.
Ce qui manque, c'est un banc de silence.
Ce que l'on garde, c'est une phrase.
Aline : on met en avant ce qui compte, pas ce qui brille.
Marc : qui pour le sujet, que pour l'objet.
Léa : ce qui = sujet ; ce que = objet.
Joël : une solution se dit aussi en relief, sinon elle se perd.
Rose : c'est le tissu que l'on déplie trop tôt.
Yvette : le relief n'est pas un cri. C'est une précision.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Ce qui » reprend un sujet, « ce que » un objet.",
  "correct": true,
  "explanation": "Léa : ce qui = sujet ; ce que = objet."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase met en relief un sujet ?",
  "options": [
    {
      "text": "C'est le silence que l'on a oublié",
      "correct": false
    },
    {
      "text": "C'est Sami qui pose le tempo",
      "correct": true
    },
    {
      "text": "Ce que je refuse c'est le spectacle",
      "correct": false
    },
    {
      "text": "On a oublié le silence",
      "correct": false
    }
  ],
  "explanation": "C'est Sami qui : Sami est sujet de poser."
}$j$::jsonb,
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
      "right": "sujet mis en avant"
    },
    {
      "left": "c'est… que",
      "right": "objet mis en avant"
    },
    {
      "left": "ce qui… c'est",
      "right": "sujet neutre"
    },
    {
      "left": "ce que… c'est",
      "right": "objet neutre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCe ___ je refuse, c'est le spectacle pour passer.",
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
    "C'est",
    "nous",
    "qui",
    "tenons",
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
  "word": "solution",
  "hint": "Réponse concrète à un problème de rythme, de tissu ou de porte."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ce que nous inquiète encore, c'est la vitesse, et Sami refuse de frapper dans le bruit.",
  "correct_sentence": "Ce qui nous inquiète encore, c'est la vitesse, et Sami refuse de frapper dans le bruit.",
  "explanation": "Sujet de inquiéter : ce qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/pronoms-en-y.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/registre-familier.svg",
      "word": "un registre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/processus-creation.svg",
      "word": "une création"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/tissu-rose.svg",
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
  "prompt": "Écrivez huit mises en relief : quatre c'est… qui/que, quatre ce qui/ce que… c'est."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis un problème et une solution à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon problème, mes solutions',
    'PE',
    $c$Objectif
Écrire un texte argumenté : spécificité culturelle, problème, solutions, mise en relief.

Consigne
Imitez la note de Hawa, sans aller trop vite.

Support — Note de Hawa, Salle des Herbes
Hawa — Seuil des Sources, avant la veillée
Ce qui me tient éveillée, ce n'est pas le nombre de lampions. C'est la peur de vider une spécificité : l'arrêt pour le tambour de Sami.
Le problème, cette saison, c'est que le cortège avance comme une file. C'est le marché qui pousse ; c'est nous qui cédons.
Je n'accuse personne. J'accuse un rythme. Une cour qui oublie de s'arrêter s'oublie, Mado l'a déjà écrit.
Solutions que je défends, sans les imposer :
C'est Sami qui ouvre et qui ferme. Trois frappes. Pas de phrase par-dessus.
C'est le tissu de Rose que l'on déplie après, pas avant.
Ce qui manque, c'est un banc de silence du côté des Herbes.
C'est l'entrée calme que Dieudonné a dite : par la Salle, pas par l'autre porte.
Ce que Radio Figuier doit garder, c'est une voix, pas un total.
Si l'on refuse toute règle, ce n'est plus une spécificité, c'est un caprice. Si l'on règle tout, ce n'est plus une veillée, c'est un tampon.
Je tiens le milieu. C'est ce milieu que je propose à la cour.
Hawa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa accuse nommément le marché et refuse toute règle.",
  "correct": false,
  "explanation": "Elle n'accuse pas une personne ; elle refuse l'excès des deux côtés."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que propose Hawa du côté des Herbes ?",
  "options": [
    {
      "text": "Plus de lampions",
      "correct": false
    },
    {
      "text": "Un banc de silence",
      "correct": true
    },
    {
      "text": "Fermer Sami",
      "correct": false
    },
    {
      "text": "Un total à la radio",
      "correct": false
    }
  ],
  "explanation": "« un banc de silence du côté des Herbes. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ce qui me tient",
      "right": "la peur de vider"
    },
    {
      "left": "c'est Sami qui",
      "right": "ouvre et ferme"
    },
    {
      "left": "c'est le tissu que",
      "right": "l'on déplie après"
    },
    {
      "left": "ce que la radio doit",
      "right": "une voix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est le tissu de Rose ___ l'on déplie après.",
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
    "C'est",
    "Sami",
    "qui",
    "ouvre",
    "et",
    "qui",
    "ferme",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "specifique",
  "hint": "Ce qui n'appartient qu'à cette cour, à ne pas vider. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le cortège qui l'on a trop chargé cette saison, et les lampions avancent plus vite que les phrases.",
  "correct_sentence": "C'est le cortège que l'on a trop chargé cette saison, et les lampions avancent plus vite que les phrases.",
  "explanation": "Objet : c'est… que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/registre-familier.svg",
      "word": "un registre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/processus-creation.svg",
      "word": "une création"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/tissu-rose.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/manifeste-seuil.svg",
      "word": "un manifeste"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : treize à seize lignes, un problème, trois solutions, au moins six mises en relief."
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
    'EL — Mise en relief du problème',
    'EL',
    $c$Objectif
Retenir c'est… qui / que et ce qui / ce que… c'est pour argumenter.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, mise en relief
C'est + X + qui + verbe : X est sujet
C'est Sami qui pose le tempo. C'est nous qui tenons la cour. C'est la veillée qui se presse.
C'est + X + que + sujet + verbe : X est objet
C'est le silence que l'on a oublié. C'est le tissu que l'on déplie trop tôt.
Ce qui + verbe, c'est… : le sujet n'est pas encore nommé
Ce qui nous inquiète, c'est la vitesse. Ce qui manque, c'est un banc.
Ce que + sujet + verbe, c'est… : l'objet n'est pas encore nommé
Ce que je refuse, c'est le spectacle. Ce que l'on garde, c'est une phrase.
Qui / que : même logique que le relatif. Sujet / objet.
On peut renforcer : c'est bien… qui/que ; ce n'est pas X, c'est Y.
Problème culturel : nommer une spécificité, un dérèglement, des solutions discutables.
Éviter : c'est le silence qui on a oublié (objet → que).
Éviter : ce que nous inquiète (sujet → ce qui).
Bien que + subj. : bien que ce soit une fête, elle peut se vider.
À + le = au tambour ; de + le = du cortège.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« C'est le silence que l'on a oublié » met en relief un objet.",
  "correct": true,
  "explanation": "Que + on a oublié : silence = objet."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est fautive ?",
  "options": [
    {
      "text": "C'est Sami qui ouvre",
      "correct": false
    },
    {
      "text": "Ce qui manque c'est un banc",
      "correct": false
    },
    {
      "text": "C'est le silence qui on a oublié",
      "correct": true
    },
    {
      "text": "Ce que je refuse c'est le spectacle",
      "correct": false
    }
  ],
  "explanation": "Objet : que, pas qui."
}$j$::jsonb,
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
      "right": "sujet"
    },
    {
      "left": "c'est… que",
      "right": "objet"
    },
    {
      "left": "ce qui… c'est",
      "right": "sujet neutre"
    },
    {
      "left": "ce que… c'est",
      "right": "objet neutre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCe ___ manque, c'est un banc de silence.",
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
    "que",
    "je",
    "refuse",
    "c'est",
    "le",
    "spectacle",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "probleme",
  "hint": "Question culturelle à tenir ensemble, sans en faire une honte. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est nous que ouvrons encore la veillée, et Sami attend trois secondes de silence avant de frapper.",
  "correct_sentence": "C'est nous qui ouvrons encore la veillée, et Sami attend trois secondes de silence avant de frapper.",
  "explanation": "Sujet : c'est… qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/processus-creation.svg",
      "word": "une création"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/tissu-rose.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/manifeste-seuil.svg",
      "word": "un manifeste"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/bilan-voix.svg",
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
  "prompt": "Rédigez un mini-tableau : huit phrases, deux par tour de relief, sur la veillée."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six mises en relief, voix posée."
}$j$::jsonb,
    9
  );

  -- ===== Tendance et création =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Tendance et création'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Tendance et création', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — On en parle, on y pense',
    'CO',
    $c$Objectif
Repérer en / y et le passage d'un registre standard à un registre familier.

Consigne
Lisez le dialogue. De quoi parle-t-on, à quoi pense-t-on, et quel ton choisit-on ?

Support — Atelier de Rose, tissu ocre
Rose : On en parle depuis trois jeudis, de cette tendance : moins d'apparat, plus de couture visible.
Aline : J'y pense aussi. Créer, ce n'est pas empiler. C'est oser enlever.
Léa : Moi, j'en ai assez des masques trop chargés. J'y reviendrai, à la pièce, si le tissu reste simple.
Patrick : Standard : cela n'est pas négligeable. Familier : c'est pas mal. Les deux disent une valeur, pas le même salon.
Marc : On y va trop vite, parfois, quand on dit « on » à la place d'un « nous » assumé. Ici, on peut. Devant le Bureau, nous préférons « nous ».
Hawa : Sami en a assez, des commentaires par-dessus les frappes. Il y est pour quelque chose, dans le calme de la scène.
Joël : J'y suis favorable, à cette création-là. J'en doute encore, du masque.
Karim : Le processus : on coupe, on essaie, on en retire une couche, on y revient le lendemain.
Lila : À l'antenne, je dirai « nous en discuterons ». Sous le figuier, je peux dire « on en parle ».
Mado : J'y vois une éthique : ne pas vendre une tendance comme une obligation.
Dieudonné : On s'y habitue, à la simplicité. On n'en revient pas, une fois qu'on l'a goûtée.
Yvette : Un chouïa plus sombre, si vous voulez un mot inventé et doux. Moi je reste à « un peu ». C'est plus clair.
Félicie : C'est pas mal, ce tissu. Cela n'est pas négligeable, pour une saison entière.
Sami : J'en ai fini, des discours. J'y vais, aux trois frappes.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick distingue « cela n'est pas négligeable » et « c'est pas mal ».",
  "correct": true,
  "explanation": "L'un est plus standard, l'autre plus familier."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Devant le Bureau, que préfère Marc ?",
  "options": [
    {
      "text": "Uniquement « on »",
      "correct": false
    },
    {
      "text": "« Nous » plutôt que « on »",
      "correct": true
    },
    {
      "text": "Le mot chouïa seulement",
      "correct": false
    },
    {
      "text": "Le silence total",
      "correct": false
    }
  ],
  "explanation": "Marc : devant le Bureau, nous préférons « nous »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en parler",
      "right": "de la tendance"
    },
    {
      "left": "y penser",
      "right": "à la création"
    },
    {
      "left": "c'est pas mal",
      "right": "registre familier"
    },
    {
      "left": "cela n'est pas négligeable",
      "right": "registre standard"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ___ parle depuis trois jeudis.",
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
    "J'y",
    "pense",
    "aussi",
    "depuis",
    "trois",
    "jeudis",
    "."
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
  "hint": "Ton d'une phrase : standard sous le Bureau, plus familier sous l'arbre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On y parle depuis trop longtemps de cette tendance, et Rose refuse encore l'apparat.",
  "correct_sentence": "On en parle depuis trop longtemps de cette tendance, et Rose refuse encore l'apparat.",
  "explanation": "Parler de → en."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/tissu-rose.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/manifeste-seuil.svg",
      "word": "un manifeste"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/bilan-voix.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/livre-mado.svg",
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
  "prompt": "Notez six en / y et deux paires de registre (familier / standard)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On en parle. J'y pense. C'est pas mal. Cela n'est pas négligeable."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Processus d''une création',
    'CE',
    $c$Objectif
Lire un texte sur une tendance et un processus de création (en / y, registres).

Consigne
Lisez la chronique de Lila, sans aller trop vite.

Support — Chronique de Radio Figuier, atelier ocre
Chronique — Une tendance n'est pas un ordre
On en parle au Seuil : une création plus nue, un tissu qui assume ses coutures.
Rose Iradukunda y travaille depuis la saison sèche. Elle en retire une couche, puis y revient le lendemain.
Le processus n'a rien d'un secret d'ailleurs. On coupe, on essaie, on en doute, on y croit un peu plus.
Registre : sous le figuier, « c'est pas mal » suffit. Devant le Bureau, « cela n'est pas négligeable » protège le sérieux du geste.
On et nous : on crée ensemble, le soir ; nous signerons, le matin, si Solange le demande.
Yvette a proposé « un chouïa plus sombre ». Rose a répondu « un peu plus sombre ». Les deux se comprennent ; le second se relit mieux.
Mado y voit une éthique : ne pas vendre une tendance comme une obligation.
Sami en a assez des commentaires qui recouvrent les frappes. Il y est pour beaucoup, dans le calme obtenu.
Léa : j'y suis favorable. Patrick : j'en doute encore, du masque, pas du tissu.
Ce que la chronique refuse, c'est le snobisme. On peut aimer une création sans en faire une loi.
Aline : une tendance se discute. On n'y obéit pas comme à un tampon.
Rukiri-Nord — à relire avant d'ouvrir l'atelier aux voisins.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado veut que la tendance devienne une obligation pour toute la cour.",
  "correct": false,
  "explanation": "Elle refuse de vendre une tendance comme une obligation."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que répond Rose à « un chouïa plus sombre » ?",
  "options": [
    {
      "text": "Un orchestre",
      "correct": false
    },
    {
      "text": "Un peu plus sombre",
      "correct": true
    },
    {
      "text": "Un tampon",
      "correct": false
    },
    {
      "text": "Un silence interdit",
      "correct": false
    }
  ],
  "explanation": "Rose choisit « un peu », plus lisible."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en parler / en retirer",
      "right": "de la tendance / une couche"
    },
    {
      "left": "y travailler / y revenir",
      "right": "à l'atelier / le lendemain"
    },
    {
      "left": "c'est pas mal",
      "right": "sous le figuier"
    },
    {
      "left": "cela n'est pas négligeable",
      "right": "devant le Bureau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nRose ___ travaille depuis la saison sèche.",
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
    "au",
    "Seuil",
    "depuis",
    "trois",
    "jeudis",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tendance",
  "hint": "Goût d'une saison, à discuter, sans en faire une loi pour la cour."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous y doutons encore du masque, et Rose continue d'en retirer une couche chaque soir.",
  "correct_sentence": "Nous en doutons encore du masque, et Rose continue d'en retirer une couche chaque soir.",
  "explanation": "Douter de → en."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/manifeste-seuil.svg",
      "word": "un manifeste"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/bilan-voix.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/livre-mado.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/tambour-sami.svg",
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
  "prompt": "Recopiez le processus en cinq étapes et deux phrases de registre différent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la chronique, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire en, y, et le ton juste',
    'PO',
    $c$Objectif
Employer en / y à l'oral et glisser d'un registre à l'autre sans se tromper de lieu.

Consigne
Répétez, puis parlez d'une création : vous en dites, vous y pensez, vous choisissez le ton.

Support — Modèles de Rose et de Marc
On en parle depuis jeudi.
J'y pense chaque soir.
J'en retire une couche.
On y revient le lendemain.
J'y suis favorable.
J'en doute encore.
C'est pas mal. (familier, banc)
Cela n'est pas négligeable. (standard, Bureau)
Nous en discuterons demain. (plus posé)
On s'y habitue.
Aline : en = de cela ; y = à cela / là.
Léa : j'y vais, à l'atelier ; j'en viens, de l'idée.
Patrick : le ton suit le lieu. Le figuier n'est pas le Bureau.
Yvette : « un peu » se relit mieux qu'un mot trop privé.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« En » reprend souvent un complément introduit par de.",
  "correct": true,
  "explanation": "Aline : en = de cela."
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
      "text": "On y parle de cette tendance",
      "correct": false
    },
    {
      "text": "On en parle de cette tendance",
      "correct": true
    },
    {
      "text": "On y doute du masque",
      "correct": false
    },
    {
      "text": "J'en pense à la création",
      "correct": false
    }
  ],
  "explanation": "Parler de → en. (On en parle.)"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en parler",
      "right": "de cela"
    },
    {
      "left": "y penser",
      "right": "à cela"
    },
    {
      "left": "c'est pas mal",
      "right": "familier"
    },
    {
      "left": "nous en discuterons",
      "right": "plus standard"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'___ suis favorable à cette création.",
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
    "s'y",
    "habitue",
    "à",
    "la",
    "simplicité",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "creation",
  "hint": "Geste de couper d'essayer et d'enlever, sans copie d'ailleurs. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'en pense encore à cette création, et Rose y revient chaque matin avec un tissu plus nu.",
  "correct_sentence": "J'y pense encore à cette création, et Rose y revient chaque matin avec un tissu plus nu.",
  "explanation": "Penser à → y."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/bilan-voix.svg",
      "word": "un bilan"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/livre-mado.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/tambour-sami.svg",
      "word": "un tambour"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/masque-invente.svg",
      "word": "un masque"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez dix phrases : cinq en, cinq y, dont deux familières et deux standard."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les dix premiers modèles, puis trois phrases à vous, deux tons."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma note de création',
    'PE',
    $c$Objectif
Écrire un texte sur une tendance et un processus, avec en / y et deux registres.

Consigne
Imitez la note de Rose Iradukunda, sans aller trop vite.

Support — Note de Rose, atelier ocre
Rose Iradukunda — Seuil des Sources
On en parle trop comme d'une mode. J'y vois plutôt un processus : enlever, essayer, y revenir.
J'en retire une couche chaque soir. Le tissu dont la saison a besoin n'a pas à cacher ses coutures.
Sous le figuier, je peux dire : c'est pas mal. Devant Solange, je dirai : cela n'est pas négligeable. Le geste est le même ; le salon change.
Nous signerons le matin, si le Bureau le demande. Le soir, on crée, on se trompe, on en rit un peu.
Yvette a soufflé « un chouïa plus sombre ». J'ai répondu « un peu ». J'y tiens : une création se relit.
Mado y voit une éthique, et j'en suis d'accord : une tendance n'est pas un ordre.
Sami en a assez des phrases par-dessus les frappes. J'y fais attention, au moment où le tissu entre.
Ce que je refuse, c'est le snobisme. On peut aimer sans en faire une loi, et l'on peut douter sans tout casser.
Si Léa y est favorable et que Patrick en doute encore, tant mieux : la création respire.
On s'y habitue, à la simplicité. On n'en revient pas, une fois qu'on l'a goûtée.
Devant le Bureau je dirai « nous ». Sous le figuier je peux encore dire « on ». Le ton suit le lieu.
Rose
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose veut que toute la cour obéisse à la tendance comme à un tampon.",
  "correct": false,
  "explanation": "« une tendance n'est pas un ordre. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que répond Rose au « chouïa » d'Yvette ?",
  "options": [
    {
      "text": "Un orchestre",
      "correct": false
    },
    {
      "text": "Un peu",
      "correct": true
    },
    {
      "text": "Un masque obligatoire",
      "correct": false
    },
    {
      "text": "Un refus du Bureau",
      "correct": false
    }
  ],
  "explanation": "« J'ai répondu « un peu ». »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en parler / en retirer",
      "right": "mode / couche"
    },
    {
      "left": "y voir / y revenir",
      "right": "processus / lendemain"
    },
    {
      "left": "c'est pas mal",
      "right": "figuier"
    },
    {
      "left": "cela n'est pas négligeable",
      "right": "Solange / Bureau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'___ suis d'accord : une tendance n'est pas un ordre.",
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
    "On",
    "peut",
    "aimer",
    "sans",
    "en",
    "faire",
    "une",
    "loi",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "couture",
  "hint": "Ligne visible sur le tissu ocre, que Rose refuse désormais de cacher."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On y rit encore de nos essais trop chargés, et le tissu plus nu tient mieux sous la lampe.",
  "correct_sentence": "On en rit encore de nos essais trop chargés, et le tissu plus nu tient mieux sous la lampe.",
  "explanation": "Rire de → en."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/livre-mado.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/tambour-sami.svg",
      "word": "un tambour"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/masque-invente.svg",
      "word": "un masque"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/micro-avis.svg",
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
  "prompt": "Imitez : douze à quinze lignes, en / y, une phrase familière, une phrase standard."
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
    'EL — En, y et les registres',
    'EL',
    $c$Objectif
Retenir en / y et le choix d'un ton (on / nous, familier / standard).

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, pronoms et tons
en reprend de + nom / de cela : en parler, en douter, en retirer, en rire, en avoir assez
y reprend à + nom / là : y penser, y revenir, y être favorable, s'y habituer, y voir, y aller
Élision : j'y pense, j'en doute, on s'y habitue
Pièges : parler de → en (pas y) ; penser à → y (pas en) ; douter de → en
Registre familier (banc, figuier) : c'est pas mal ; on en parle ; un peu
Registre standard (Bureau, antenne posée) : cela n'est pas négligeable ; nous en discuterons
On : fréquent à l'oral, collectif souple. Nous : plus assumé, plus officiel.
Un mot trop privé (chouïa) peut se comprendre ; « un peu » se relit mieux.
Le ton suit le lieu. Le figuier n'est pas le Bureau. L'antenne n'est pas le marché.
Création : processus (couper, essayer, enlever, y revenir), pas copie d'ailleurs.
Tendance : se discute. On n'y obéit pas comme à un tampon.
Attention : y / en se placent avant le verbe, sauf à l'impératif affirmatif (parles-en, vas-y).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Penser à » se reprend par en.",
  "correct": false,
  "explanation": "Penser à → y."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle reprise est juste pour « douter du masque » ?",
  "options": [
    {
      "text": "y douter",
      "correct": false
    },
    {
      "text": "en douter",
      "correct": true
    },
    {
      "text": "le douter à",
      "correct": false
    },
    {
      "text": "dont douter y",
      "correct": false
    }
  ],
  "explanation": "Douter de → en."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "en",
      "right": "de cela"
    },
    {
      "left": "y",
      "right": "à cela / là"
    },
    {
      "left": "c'est pas mal",
      "right": "familier"
    },
    {
      "left": "nous en discuterons",
      "right": "standard"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nParler de la tendance → on ___ parle.",
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
    "J'y",
    "suis",
    "favorable",
    "sans",
    "en",
    "faire",
    "une",
    "loi",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "processus",
  "hint": "Suite d'essais : couper, enlever, revenir, sans secret d'apparat."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Vas-y : parles-y demain au Bureau, et Rose apportera le tissu plus nu.",
  "correct_sentence": "Vas-y : parles-en demain au Bureau, et Rose apportera le tissu plus nu.",
  "explanation": "Parler de → en (parles-en)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/tambour-sami.svg",
      "word": "un tambour"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/masque-invente.svg",
      "word": "un masque"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/micro-avis.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/cahier-critique.svg",
      "word": "une critique"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau en / y : huit verbes, une phrase chacun, plus deux paires de registre."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis : j'en parle, j'y pense, parles-en, vas-y, c'est pas mal, cela n'est pas négligeable."
}$j$::jsonb,
    9
  );

  -- ===== Bilan de la Saison des Voix =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Bilan de la Saison des Voix'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Bilan de la Saison des Voix', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Une saison à juger',
    'CO',
    $c$Objectif
Suivre un bilan critique : qualités, limites, critères, sans slogan.

Consigne
Lisez le dialogue. Qu'est-ce qui a tenu, qu'est-ce qui a manqué ?

Support — Après la dernière frappe, banc du figuier
Aline : Une critique n'est pas une insulte. C'est un bilan qui ose le « mais ».
Léa : La saison a été plus juste que bruyante. Le meilleur soir, ce n'est pas le plus plein.
Patrick : Ce que je retiens, c'est le livre de Mado. Ce qui m'a manqué, c'est du temps entre les œuvres.
Marc : La pièce dont on parle encore a tenu. Le cortège, lui, a trop glissé vers la file.
Hawa : J'y vois une réussite inégale, et c'est déjà beaucoup. On n'en fera pas une légende lisse.
Joël : C'est le tambour qui a sauvé deux soirs trop pressés. C'est nous qui avons trop parlé par-dessus.
Rose : Le tissu a mieux tenu que les commentaires. J'en suis plutôt fière, sans en faire une loi.
Solange : Le Bureau date. Il ne note pas. Une critique n'a pas besoin d'un tampon pour exister.
Karim : Or, sans public, pas de saison. Toutefois, un public n'excuse pas la vitesse.
Lila : À l'antenne, je dirai : cela n'est pas négligeable. Sous l'arbre, je peux dire : c'est pas mal, et c'est déjà rare.
Mado : Une critique qui n'admet que l'éloge n'est pas une critique. C'est une affiche de plus.
Sami : Trois soirs ont tenu. Un soir a glissé. Je n'en dirai pas plus long que ça.
Dieudonné : L'entrée des Herbes a calmé. L'autre porte a poussé. On y reviendra.
Yvette : Le mieux, pour un bilan, c'est une phrase juste, pas un classement.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado considère qu'un éloge sans réserve suffit à faire une critique.",
  "correct": false,
  "explanation": "« Une critique qui n'admet que l'éloge n'est pas une critique. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Patrick, qu'est-ce qui a manqué ?",
  "options": [
    {
      "text": "Le tampon de Solange",
      "correct": false
    },
    {
      "text": "Du temps entre les œuvres",
      "correct": true
    },
    {
      "text": "Le tambour de Sami",
      "correct": false
    },
    {
      "text": "Le tissu de Rose",
      "correct": false
    }
  ],
  "explanation": "« du temps entre les œuvres. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus juste que bruyante",
      "right": "la saison"
    },
    {
      "left": "ce que je retiens",
      "right": "le livre"
    },
    {
      "left": "c'est le tambour qui",
      "right": "a sauvé deux soirs"
    },
    {
      "left": "toutefois",
      "right": "le public n'excuse pas la vitesse"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne critique n'est pas une insulte. C'est un bilan qui ose le « ___ ».",
  "answer": "mais"
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
    "saison",
    "a",
    "été",
    "plus",
    "juste",
    "que",
    "bruyante",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "critique",
  "hint": "Bilan qui ose un mais, sans devenir une affiche ni une insulte."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le meilleur soir de la saison et c'est aussi le plus bon public que j'aie vu sous le figuier.",
  "correct_sentence": "C'est le meilleur soir de la saison et c'est aussi le meilleur public que j'aie vu sous le figuier.",
  "explanation": "Meilleur, pas plus bon."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/masque-invente.svg",
      "word": "un masque"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/micro-avis.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/cahier-critique.svg",
      "word": "une critique"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/danse-cour.svg",
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
  "prompt": "Notez trois qualités, deux limites et le critère que vous garderiez pour une critique."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Une critique ose le mais. Ce que je retiens, c'est le livre. Ce qui a manqué, c'est du temps."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Critique de saison',
    'CE',
    $c$Objectif
Lire une critique argumentée de la Saison des Voix (inventée).

Consigne
Lisez la critique de Lila, sans aller trop vite.

Support — Feuille du soir, Radio Figuier
Critique — Saison des Voix, Seuil des Sources
On en attendait une fête. On y a trouvé, plus souvent, une écoute. Cela n'est pas négligeable.
La pièce « La cour n'oublie pas », que la cour a jouée sous le figuier, a été plus nue que l'an passé. C'est Sami qui en a tenu le tempo. Le meilleur acte n'était pas le plus long.
Le livre de Mado, dont les phrases restent, a moins besoin de lampions. Ce qui lui va le mieux, c'est le banc, pas le cortège.
Toutefois, le cortège a trop glissé vers la file. C'est la veillée que l'on a pressée, pas le tambour. On y reviendra.
Rose : le tissu a mieux tenu que certains commentaires. On peut en parler sans en faire une loi.
Aline a refusé l'affiche lisse. Karim a rappelé qu'un public n'excuse pas la vitesse. Solange a daté, sans noter.
Ce que cette critique refuse, c'est le classement humiliant. Ce qu'elle propose, c'est un critère : la phrase que l'on peut encore dire le lendemain.
Réussite inégale, donc. Le mieux n'est pas de crier au chef-d'œuvre. C'est de pouvoir raconter sans trahir.
Sami : trois soirs ont tenu, un soir a glissé. On peut le dire sans insulter personne.
Dieudonné : l'entrée des Herbes a calmé ; l'autre porte a poussé. On y reviendra.
Yvette : une critique qui n'admet que l'éloge n'est pas une critique. C'est une affiche de plus.
Rukiri-Nord — à lire une fois, puis à discuter, jamais à coller comme un tampon.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La critique affirme que le cortège a trop glissé vers la file.",
  "correct": true,
  "explanation": "« le cortège a trop glissé vers la file. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel critère la critique propose-t-elle ?",
  "options": [
    {
      "text": "Le nombre de lampions",
      "correct": false
    },
    {
      "text": "La phrase que l'on peut encore dire le lendemain",
      "correct": true
    },
    {
      "text": "Le tampon du Bureau",
      "correct": false
    },
    {
      "text": "La longueur du meilleur acte",
      "correct": false
    }
  ],
  "explanation": "Le critère du lendemain, déjà posé par Aline."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus nue",
      "right": "la pièce / l'an passé"
    },
    {
      "left": "dont les phrases restent",
      "right": "le livre de Mado"
    },
    {
      "left": "toutefois",
      "right": "la file du cortège"
    },
    {
      "left": "réussite inégale",
      "right": "bilan sans légende"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est Sami ___ en a tenu le tempo.",
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
    "peut",
    "en",
    "parler",
    "sans",
    "en",
    "faire",
    "une",
    "loi",
    "."
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
  "hint": "Regard d'après-saison : ce qui a tenu, ce qui a glissé, un critère."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voici la saison dont je pense encore ce soir, et Lila en relira la critique à l'antenne.",
  "correct_sentence": "Voici la saison à laquelle je pense encore ce soir, et Lila en relira la critique à l'antenne.",
  "explanation": "Penser à → à laquelle."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/micro-avis.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/cahier-critique.svg",
      "word": "une critique"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/danse-cour.svg",
      "word": "une danse"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/radio-culture.svg",
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
  "prompt": "Recopiez la critique et marquez éloge, limite, critère. Ajoutez deux phrases à vous."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la critique, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire une critique juste',
    'PO',
    $c$Objectif
Formuler à l'oral un bilan : qualité, limite, critère, ton mesuré.

Consigne
Répétez, puis critiquez une œuvre de la saison sans slogan.

Support — Modèles d'Aline et de Mado
La saison a été plus juste que bruyante.
Ce que je retiens, c'est le livre.
Ce qui m'a manqué, c'est du temps.
C'est le tambour qui a tenu deux soirs.
Toutefois, le cortège a trop glissé.
Cela n'est pas négligeable.
C'est pas mal, et c'est déjà rare.
Une critique ose le « mais ».
Le mieux n'est pas de crier au chef-d'œuvre.
Aline : un éloge sans réserve n'éclaire rien.
Marc : un critère se dit en une phrase.
Léa : on en parle, on n'y met pas de couronne.
Patrick : je préfère inégale et vraie à lisse et fausse.
Yvette : finissez par ce que vous garderez.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline soutient qu'un éloge sans réserve n'éclaire rien.",
  "correct": true,
  "explanation": "Un éloge plat n'est pas une critique."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase ouvre une limite ?",
  "options": [
    {
      "text": "Cela n'est pas négligeable",
      "correct": false
    },
    {
      "text": "Toutefois le cortège a trop glissé",
      "correct": true
    },
    {
      "text": "C'est le tambour qui a tenu",
      "correct": false
    },
    {
      "text": "Le livre que j'ai relu",
      "correct": false
    }
  ],
  "explanation": "Toutefois introduit la réserve."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ce que je retiens",
      "right": "qualité"
    },
    {
      "left": "ce qui m'a manqué",
      "right": "limite"
    },
    {
      "left": "toutefois",
      "right": "réserve"
    },
    {
      "left": "le mieux",
      "right": "refus du slogan"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne critique ose le « ___ ».",
  "answer": "mais"
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
    "n'est",
    "pas",
    "négligeable",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "reserve",
  "hint": "Le mais d'une critique, sans lequel l'éloge devient une affiche. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La saison a été plus juste que bruyante, et c'est le plus bon soir que nous ayons tenu sous l'arbre.",
  "correct_sentence": "La saison a été plus juste que bruyante, et c'est le meilleur soir que nous ayons tenu sous l'arbre.",
  "explanation": "Meilleur soir, pas plus bon."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/cahier-critique.svg",
      "word": "une critique"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/danse-cour.svg",
      "word": "une danse"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/radio-culture.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/figuier-theatre.svg",
      "word": "un théâtre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez une critique orale en huit phrases : deux qualités, deux limites, un critère, une conclusion."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les neuf premiers modèles, puis votre bilan en une minute."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma critique de saison',
    'PE',
    $c$Objectif
Écrire une critique argumentée de la Saison des Voix (inventée).

Consigne
Imitez la critique de Marc, sans aller trop vite.

Support — Critique de Marc, cahier ocre
Marc — Seuil des Sources, après la dernière frappe
Une critique n'est pas une insulte. J'en écris une, donc, avec un « mais ».
La Saison des Voix a été plus juste que bruyante. La pièce que la cour a tenue sous le figuier, plus nue que l'an passé, a trouvé son tempo : c'est Sami qui l'a posé, et c'est nous qui l'avons parfois recouvert.
Le livre dont les phrases restent — « Le figuier n'oublie pas » — m'a paru moins spectaculaire et mieux. Ce que je retiens, c'est une cour qui refuse d'oublier.
Ce qui m'a manqué, c'est du temps entre les œuvres. Toutefois, le cortège a trop glissé vers la file : c'est la veillée que l'on a pressée, pas le tambour.
Rose : le tissu a mieux tenu que certains commentaires. On peut en parler sans en faire une loi.
Cela n'est pas négligeable. Sous l'arbre, je peux même dire : c'est pas mal, et c'est déjà rare.
Je refuse le classement humiliant. Le critère que je garde, c'est la phrase que l'on peut encore dire le lendemain.
Réussite inégale, donc. Le mieux n'est pas de crier au chef-d'œuvre. C'est de pouvoir raconter sans trahir.
Aline a refusé l'affiche. Solange a daté, sans noter. J'y vois assez de dignité pour une cour.
On en parlera encore au fil. On n'y mettra pas de couronne. Une saison se relit, elle ne se décerne pas.
Si Lila lit ceci à l'antenne, qu'elle garde le « mais ». Sans lui, je n'ai rien écrit.
Marc
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc refuse le classement humiliant.",
  "correct": true,
  "explanation": "« Je refuse le classement humiliant. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel critère Marc garde-t-il ?",
  "options": [
    {
      "text": "Le nombre de lampions",
      "correct": false
    },
    {
      "text": "La phrase que l'on peut encore dire le lendemain",
      "correct": true
    },
    {
      "text": "Le tampon du Bureau",
      "correct": false
    },
    {
      "text": "Le plus long acte",
      "correct": false
    }
  ],
  "explanation": "Le critère du lendemain."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus juste que bruyante",
      "right": "la saison"
    },
    {
      "left": "ce que je retiens",
      "right": "une cour qui refuse d'oublier"
    },
    {
      "left": "toutefois",
      "right": "la file du cortège"
    },
    {
      "left": "réussite inégale",
      "right": "bilan sans chef-d'œuvre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe mieux n'est pas de crier au ___.",
  "answer": "chef-d'œuvre"
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
    "critique",
    "n'est",
    "pas",
    "une",
    "insulte",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "inegale",
  "hint": "Réussite vraie, sans légende lisse. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est la veillée qui l'on a pressée trop vite, et le tambour n'y est pour rien.",
  "correct_sentence": "C'est la veillée que l'on a pressée trop vite, et le tambour n'y est pour rien.",
  "explanation": "Objet : c'est… que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/danse-cour.svg",
      "word": "une danse"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/radio-culture.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/figuier-theatre.svg",
      "word": "un théâtre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/calendrier-voix.svg",
      "word": "un calendrier"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : treize à seize lignes, éloge, limite, critère, un toutefois, un mieux."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre critique, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Tenir une critique',
    'EL',
    $c$Objectif
Retenir la structure d'une critique : qualité, limite, critère, ton mesuré.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, critique de saison
Critique = bilan qui ose le « mais ». Ni insulte, ni affiche.
Mouvements : ce que l'œuvre / la saison a fait ; ce qu'elle a manqué ; le critère ; la conclusion.
Outils déjà vus :
comparatif / superlatif : plus juste que bruyante ; le meilleur soir
relatifs : la pièce que… ; le livre dont… ; la cour où…
mise en relief : c'est Sami qui ; ce que je retiens, c'est ; ce qui m'a manqué, c'est
en / y : on en parle ; on y reviendra
Connecteur de réserve : toutefois. Conclusion mesurée : donc ; le mieux n'est pas…
Registre : cela n'est pas négligeable (antenne) ; c'est pas mal (banc)
Éviter le classement humiliant. Préférer « réussite inégale » à « chef-d'œuvre ».
Critère utile au Seuil : la phrase que l'on peut encore dire le lendemain.
Le Bureau date. Il ne note pas. Une critique n'a pas besoin d'un tampon.
Bien que + subj. : bien que ce soit inégal, la saison tient.
Attention : meilleur / mieux ; dont après parler de ; c'est… qui / que.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Une critique, d'après la fiche, peut se limiter à un éloge sans réserve.",
  "correct": false,
  "explanation": "Elle ose le « mais ». Un éloge plat n'éclaire rien."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel connecteur ouvre surtout une réserve ?",
  "options": [
    {
      "text": "donc seulement",
      "correct": false
    },
    {
      "text": "toutefois",
      "correct": true
    },
    {
      "text": "en avant",
      "correct": false
    },
    {
      "text": "tampon",
      "correct": false
    }
  ],
  "explanation": "Toutefois = réserve."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ce que je retiens",
      "right": "qualité"
    },
    {
      "left": "ce qui m'a manqué",
      "right": "limite"
    },
    {
      "left": "toutefois",
      "right": "réserve"
    },
    {
      "left": "le mieux n'est pas",
      "right": "refus du slogan"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne critique ose le « ___ ».",
  "answer": "mais"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Réussite",
    "inégale",
    "donc",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "critere",
  "hint": "Phrase qui justifie un avis, par exemple celle du lendemain. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voici la saison que je parle encore ce soir, et Lila en relira le bilan à l'antenne demain.",
  "correct_sentence": "Voici la saison dont je parle encore ce soir, et Lila en relira le bilan à l'antenne demain.",
  "explanation": "Parler de → dont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/radio-culture.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/figuier-theatre.svg",
      "word": "un théâtre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/calendrier-voix.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/soleil-oeuvre.svg",
      "word": "une œuvre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez un plan de critique en cinq mouvements, avec un exemple de phrase pour chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis une mini-critique de six phrases."
}$j$::jsonb,
    9
  );

  -- ===== Manifeste culturel du Seuil =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Manifeste culturel du Seuil'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Manifeste culturel du Seuil', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Nous ne vendons pas une cour',
    'CO',
    $c$Objectif
Suivre l'élaboration d'un manifeste : thèses, concessions, engagements.

Consigne
Lisez le dialogue. Quelles phrases deviendraient des articles ?

Support — Assemblée sous le figuier, après la saison
Aline : Un manifeste n'est pas une affiche. C'est un texte qui engage, et qui admet un « toutefois ».
Mado : Nous affirmons que la cour n'oublie pas. C'est le titre que l'on se doit, pas un slogan de marché.
Sami : Nous affirmons que trois frappes valent mieux qu'un défilé. C'est le tempo que nous défendons.
Léa : Ce que nous refusons, c'est de vendre une spécificité. Ce que nous proposons, c'est de la tenir.
Patrick : Article possible : la saison la plus juste n'est pas la plus pleine.
Marc : Or, sans public, pas de saison. Toutefois, un public n'excuse pas la vitesse. Les deux phrases doivent rester.
Hawa : Nous en parlerons au fil de Radio Figuier. Nous n'y obéirons pas comme à une mode.
Joël : C'est nous qui tenons le Seuil. C'est le figuier sous lequel on s'assemble, pas une estrade d'ailleurs.
Rose : Le tissu dont on se sert n'a pas à cacher ses coutures. J'en fais un article, si l'on veut.
Solange : Le Bureau date un manifeste. Il ne le note pas. Il n'en est pas le maître.
Karim : Ainsi, chaque article dira un fait, une limite, un geste. Pas une couronne.
Lila : À l'antenne, registre posé. Sous l'arbre, on peut dire : c'est pas mal, et cela suffit à nous lier.
Dieudonné : Nous y reviendrons chaque saison. Un manifeste qui ne se relit pas n'est qu'un papier.
Yvette : Le mieux, c'est une phrase que l'enfant du Seuil pourra encore comprendre.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline dit qu'un manifeste est une affiche de plus.",
  "correct": false,
  "explanation": "« Un manifeste n'est pas une affiche. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que refuse Léa, dans le dialogue ?",
  "options": [
    {
      "text": "Les trois frappes",
      "correct": false
    },
    {
      "text": "De vendre une spécificité",
      "correct": true
    },
    {
      "text": "Le tissu de Rose",
      "correct": false
    },
    {
      "text": "Le tampon de Solange",
      "correct": false
    }
  ],
  "explanation": "Léa : refuser de vendre une spécificité."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "nous affirmons",
      "right": "la cour n'oublie pas"
    },
    {
      "left": "ce que nous refusons",
      "right": "vendre une spécificité"
    },
    {
      "left": "or / toutefois",
      "right": "public / vitesse"
    },
    {
      "left": "ainsi",
      "right": "fait + limite + geste"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUn manifeste n'est pas une ___.",
  "answer": "affiche"
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
    "nous",
    "qui",
    "tenons",
    "le",
    "Seuil",
    "."
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
  "hint": "Texte qui engage une cour, avec des articles et un toutefois."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voici le manifeste que je pense depuis la dernière frappe, et Aline en relira les articles demain.",
  "correct_sentence": "Voici le manifeste auquel je pense depuis la dernière frappe, et Aline en relira les articles demain.",
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
      "image_path": "/elearning/mfk-b2-m3/figuier-theatre.svg",
      "word": "un théâtre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/calendrier-voix.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/soleil-oeuvre.svg",
      "word": "une œuvre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/balance-gouts.svg",
      "word": "un goût"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez quatre articles possibles et la concession (or / toutefois) entendue."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Nous affirmons que la cour n'oublie pas. Ce que nous refusons, c'est de vendre. Toutefois, un public n'excuse pas la vitesse."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Premier jet du manifeste',
    'CE',
    $c$Objectif
Lire un manifeste culturel argumenté (articles, concessions, engagements).

Consigne
Lisez le manifeste, sans aller trop vite.

Support — Feuille du Seuil, Table des Sources
Manifeste culturel du Seuil des Sources — premier jet
Nous, assemblés sous le figuier, affirmons que la cour n'oublie pas.
Nous affirmons que la Saison des Voix n'est pas un défilé. C'est une écoute que l'on tient ensemble.
Article 1. La saison la plus juste n'est pas la plus pleine. Le meilleur soir n'est pas le plus bruyant.
Article 2. C'est Sami qui pose le tempo de la veillée. Trois frappes. Pas de phrase par-dessus.
Article 3. Le livre dont les phrases restent, la pièce que l'on joue, le tissu auquel Rose travaille : deux langages, une cour.
Article 4. Or, sans public, pas de saison. Toutefois, un public n'excuse pas la vitesse.
Article 5. Une tendance se discute. On n'y obéit pas comme à un tampon. On en parle, on n'en fait pas une loi.
Article 6. Une critique ose le « mais ». Un manifeste aussi. Nous refusons l'affiche lisse.
Article 7. Radio Figuier relayera la voix, pas le compte. Le Bureau daté, sans noter.
Ce que nous proposons, c'est de relire ce texte chaque saison. Ce qui nous lie, c'est une phrase juste, pas une couronne.
Ainsi, nous nous engageons à tenir le milieu : assez de règle pour ne pas vider, assez de souffle pour ne pas geler.
Rukiri-Nord — à discuter, à corriger, à signer sans faste.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'article 4 concède le besoin d'un public tout en refusant la vitesse.",
  "correct": true,
  "explanation": "Or… Toutefois… : les deux phrases restent."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que relayera Radio Figuier, selon l'article 7 ?",
  "options": [
    {
      "text": "Le compte des lampions",
      "correct": false
    },
    {
      "text": "La voix, pas le compte",
      "correct": true
    },
    {
      "text": "Un classement des œuvres",
      "correct": false
    },
    {
      "text": "Une couronne",
      "correct": false
    }
  ],
  "explanation": "La voix, pas le compte."
}$j$::jsonb,
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
      "right": "juste ≠ pleine"
    },
    {
      "left": "article 2",
      "right": "tempo de Sami"
    },
    {
      "left": "article 4",
      "right": "or / toutefois"
    },
    {
      "left": "article 6",
      "right": "le mais de la critique"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne tendance se discute. On n'___ obéit pas comme à un tampon.",
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
    "Nous",
    "refusons",
    "l'affiche",
    "lisse",
    "."
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
  "hint": "Phrase numérotée d'un manifeste : un fait, une limite, un geste."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est nous que tenons encore le Seuil, et le manifeste le dira sans faste demain matin.",
  "correct_sentence": "C'est nous qui tenons encore le Seuil, et le manifeste le dira sans faste demain matin.",
  "explanation": "Sujet : c'est… qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/calendrier-voix.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/soleil-oeuvre.svg",
      "word": "une œuvre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/balance-gouts.svg",
      "word": "un goût"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/coeur-commun.svg",
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
  "prompt": "Recopiez trois articles et ajoutez le vôtre, avec une concession."
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
    'PO — Dire un article, tenir un toutefois',
    'PO',
    $c$Objectif
Argumenter à l'oral : thèse, concession, engagement, ton de manifeste.

Consigne
Répétez, puis proposez deux articles et une concession.

Support — Modèles d'Aline et de Karim
Nous affirmons que la cour n'oublie pas.
Nous refusons de vendre une spécificité.
C'est nous qui tenons le Seuil.
Ce que nous proposons, c'est de tenir une écoute.
Or, sans public, pas de saison.
Toutefois, un public n'excuse pas la vitesse.
Ainsi, nous relirons ce texte chaque saison.
Le mieux, c'est une phrase juste.
Cela n'est pas négligeable.
Aline : un article dit un fait, une limite, un geste.
Marc : la concession n'affaiblit pas. Elle rend honnête.
Léa : on en parlera au fil. On n'y obéira pas comme à une mode.
Mado : signez sans faste. Un manifeste trop brillant se vide.
Yvette : finissez par ce que l'enfant du Seuil comprendra.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc dit que la concession rend le texte plus honnête.",
  "correct": true,
  "explanation": "Elle n'affaiblit pas : elle rend honnête."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel couple pose la concession du public et de la vitesse ?",
  "options": [
    {
      "text": "donc / ainsi seulement",
      "correct": false
    },
    {
      "text": "or / toutefois",
      "correct": true
    },
    {
      "text": "en / y seulement",
      "correct": false
    },
    {
      "text": "qui / que seulement",
      "correct": false
    }
  ],
  "explanation": "Or… Toutefois…"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "nous affirmons",
      "right": "thèse"
    },
    {
      "left": "nous refusons",
      "right": "refus"
    },
    {
      "left": "or / toutefois",
      "right": "concession"
    },
    {
      "left": "ainsi",
      "right": "engagement"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___, un public n'excuse pas la vitesse.",
  "answer": "Toutefois"
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
    "affirmons",
    "que",
    "la",
    "cour",
    "n'oublie",
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
  "word": "concession",
  "hint": "Mouvement or / toutefois : on admet un fait sans céder sur l'essentiel."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous en obéirons pas comme à une mode, et le manifeste le dira dès demain sous le figuier.",
  "correct_sentence": "Nous n'y obéirons pas comme à une mode, et le manifeste le dira dès demain sous le figuier.",
  "explanation": "Obéir à → y."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/soleil-oeuvre.svg",
      "word": "une œuvre"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/balance-gouts.svg",
      "word": "un goût"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/coeur-commun.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/comparatif-oeuvre.svg",
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
  "prompt": "Écrivez six articles oraux : thèse, refus, relief, or, toutefois, ainsi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les neuf premiers modèles, puis deux articles à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon manifeste du Seuil',
    'PE',
    $c$Objectif
Écrire un texte argumenté : manifeste culturel, articles, concessions, engagements.

Consigne
Imitez le manifeste de Mado, sans aller trop vite.

Support — Manifeste de Mado, encre du figuier
Mado — Seuil des Sources, Rukiri-Nord
Nous, qui écrivons et qui frappons et qui tenons le pupitre, affirmons que la cour n'oublie pas.
Un manifeste n'est pas une affiche. C'est un texte dont on se sert, et auquel on revient.
Nous affirmons que la Saison des Voix est une écoute, non un défilé. La saison la plus juste n'est pas la plus pleine.
C'est Sami qui pose le tempo. C'est Rose dont le tissu assume ses coutures. C'est Aline avec laquelle on refuse le lisse.
Ce que nous refusons, c'est de vendre une spécificité. Ce que nous proposons, c'est de la tenir : veillée, tambour, livre, pièce.
Or, sans public, pas de saison. Toutefois, un public n'excuse pas la vitesse. Les deux phrases restent, ou le texte ment.
Nous en parlerons au fil de Radio Figuier. Nous n'y obéirons pas comme à une mode. Une tendance se discute ; on n'en fait pas une loi.
Ainsi, nous nous engageons à relire ces lignes chaque saison, à oser le « mais » d'une critique, à préférer une phrase juste à une couronne.
Le Bureau date. Il ne note pas. Le mieux, c'est ce qu'un enfant du Seuil pourra encore comprendre.
Je signe sans faste. Que la cour corrige.
Mado
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado accepte qu'on vende la spécificité du Seuil si le public le demande.",
  "correct": false,
  "explanation": "Elle refuse de vendre une spécificité."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que restera-t-il si l'on retire l'une des deux phrases « or / toutefois » ?",
  "options": [
    {
      "text": "Un texte plus vrai",
      "correct": false
    },
    {
      "text": "Un texte qui ment",
      "correct": true
    },
    {
      "text": "Un tampon plus clair",
      "correct": false
    },
    {
      "text": "Un défilé plus beau",
      "correct": false
    }
  ],
  "explanation": "« Les deux phrases restent, ou le texte ment. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "nous affirmons",
      "right": "écoute, non défilé"
    },
    {
      "left": "ce que nous refusons",
      "right": "vendre"
    },
    {
      "left": "or / toutefois",
      "right": "public / vitesse"
    },
    {
      "left": "ainsi",
      "right": "relire chaque saison"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous n'___ obéirons pas comme à une mode.",
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
    "Un",
    "manifeste",
    "n'est",
    "pas",
    "une",
    "affiche",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "engagement",
  "hint": "Promesse écrite : relire, oser le mais, préférer une phrase juste."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous affirmons que la cour n'oublie pas, et c'est le plus bon article que nous ayons osé signer.",
  "correct_sentence": "Nous affirmons que la cour n'oublie pas, et c'est le meilleur article que nous ayons osé signer.",
  "explanation": "Meilleur article, pas plus bon."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/balance-gouts.svg",
      "word": "un goût"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/coeur-commun.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/comparatif-oeuvre.svg",
      "word": "une comparaison"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/superlatif-avis.svg",
      "word": "un avis"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : quatorze à dix-huit lignes, au moins cinq articles, une concession, un ainsi."
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
    'EL — Texte argumenté du manifeste',
    'EL',
    $c$Objectif
Retenir la charpente d'un texte argumenté : thèse, concession, engagement.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, manifeste
Manifeste = texte qui engage une communauté. Pas une affiche. Pas un tampon.
Charpente : nous affirmons / nous refusons / nous proposons / nous nous engageons
Concession honnête : or… ; toutefois… (les deux restent, ou le texte ment)
Conséquence : ainsi ; par conséquent (plus tard). Conclusion mesurée : le mieux, c'est…
Reprendre les outils du module :
comparatifs : la plus juste n'est pas la plus pleine
relatifs : le livre dont… ; la pièce que… ; le figuier sous lequel…
relief : c'est nous qui ; ce que nous refusons, c'est
en / y : en parler, n'y obéir pas
Registre : antenne posée pour signer ; familier permis pour lier, pas pour vider.
Articles courts : un fait, une limite, un geste.
Relire chaque saison. Un manifeste qui ne se relit pas n'est qu'un papier.
Éviter : plus bon, le livre que je parle, c'est… qui + objet, penser à → dont.
Bien que + subj. : bien que ce soit incomplet, nous signons.
À + le = au Seuil ; de + le = du figuier.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Un manifeste, d'après la fiche, peut se passer de concession.",
  "correct": false,
  "explanation": "Sans or / toutefois, le texte risque de mentir."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série ouvre surtout la charpente ?",
  "options": [
    {
      "text": "plus / moins / aussi seulement",
      "correct": false
    },
    {
      "text": "nous affirmons / refusons / proposons / engageons",
      "correct": true
    },
    {
      "text": "chouïa / c'est pas mal seulement",
      "correct": false
    },
    {
      "text": "tampon / date / note",
      "correct": false
    }
  ],
  "explanation": "Les quatre verbes d'engagement."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "nous affirmons",
      "right": "thèse"
    },
    {
      "left": "or / toutefois",
      "right": "concession"
    },
    {
      "left": "ainsi",
      "right": "conséquence"
    },
    {
      "left": "nous nous engageons",
      "right": "promesse"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUn manifeste qui ne se ___ pas n'est qu'un papier.",
  "answer": "relit"
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
    "engageons",
    "à",
    "tenir",
    "une",
    "écoute",
    "."
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
  "hint": "Phrase que l'on affirme d'abord, avant la concession. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous affirmons que la cour n'oublie pas, et c'est le plus bon article que nous ayons écrit.",
  "correct_sentence": "Nous affirmons que la cour n'oublie pas, et c'est le meilleur article que nous ayons écrit.",
  "explanation": "Meilleur article, pas plus bon."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m3/coeur-commun.svg",
      "word": "un cœur"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/comparatif-oeuvre.svg",
      "word": "une comparaison"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/superlatif-avis.svg",
      "word": "un avis"
    },
    {
      "image_path": "/elearning/mfk-b2-m3/resume-piece.svg",
      "word": "un résumé"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez un plan de manifeste : quatre verbes d'engagement, deux concessions, trois articles."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et cinq phrases : nous affirmons, nous refusons, or, toutefois, ainsi."
}$j$::jsonb,
    9
  );

END;
$$;
