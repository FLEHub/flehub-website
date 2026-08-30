/*
  Seed eLearning MFK — B1 — Un monde de culture

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b1-m8/
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
  v_module_title text := 'B1 — Un monde de culture';
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
      'Grande étape B1-8 : écrire une critique enthousiaste, s''informer sur un parcours, réagir à une œuvre, dire pourquoi lire, tenir une soirée lecture et programmer une saison — Saison des Voix, tambour de Sami, pages de Mado, pièce « La cour n''oublie pas », au Seuil des Sources (Rukiri-Nord).',
      'B1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B1-8 : écrire une critique enthousiaste, s''informer sur un parcours, réagir à une œuvre, dire pourquoi lire, tenir une soirée lecture et programmer une saison — Saison des Voix, tambour de Sami, pages de Mado, pièce « La cour n''oublie pas », au Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'B1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Une critique enthousiaste =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une critique enthousiaste'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une critique enthousiaste', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le plus émouvant de la veillée',
    'CO',
    $c$Objectif
Présenter une œuvre et une critique positive ; superlatifs.

Consigne
Lisez le dialogue. Qu'est-ce qui est le plus, la meilleure, le moins ?

Support — Salle des Herbes, affiche ocre
Léa : « La cour n'oublie pas » est le spectacle le plus émouvant de la saison.
Marc : C'est la meilleure soirée que j'ai vécue sous le figuier.
Aline : Le moins attendu, c'est le silence après le tambour de Sami.
Patrick : Mado a lu la plus juste des pages du Cahier du chemin.
Hawa : Dieudonné a tissé le plus beau coupon pour le rideau.
Joël : Ce n'est pas le moins réussi : c'est le plus vivant.
Lila : Radio Figuier dira : la pièce la plus claire de la Saison des Voix.
Karim : Le moins long n'est pas le moins fort. Vingt minutes ont suffi.
Solange : La meilleure trace, c'est la feuille tamponnée au Bureau.
Rose : J'ai vu le moins attendu : Kévin a pleuré sans bruit.
Mado : La page la plus simple était la plus écoutée.
Sami : Le rythme le moins pressé a porté toute la cour.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Karim dit que vingt minutes n'ont pas suffi.",
  "correct": false,
  "explanation": "« Vingt minutes ont suffi. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Léa, quel spectacle est le plus émouvant ?",
  "options": [
    {
      "text": "un cri du marché",
      "correct": false
    },
    {
      "text": "« La cour n'oublie pas »",
      "correct": true
    },
    {
      "text": "un bulletin d'eau",
      "correct": false
    },
    {
      "text": "un tampon seul",
      "correct": false
    }
  ],
  "explanation": "Léa nomme la pièce inventée de la cour."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le plus émouvant",
      "right": "Léa / pièce"
    },
    {
      "left": "la meilleure soirée",
      "right": "Marc"
    },
    {
      "left": "le moins attendu",
      "right": "silence / Kévin"
    },
    {
      "left": "la plus juste",
      "right": "page / Mado"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est ___ meilleure soirée que j'ai vécue sous le figuier.",
  "answer": "la"
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
    "meilleure",
    "soirée",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "emouvant",
  "hint": "Léa : le plus… de la saison (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "« La cour n'oublie pas » est le spectacle le plus émouvante de la saison.",
  "correct_sentence": "« La cour n'oublie pas » est le spectacle le plus émouvant de la saison.",
  "explanation": "Spectacle est masculin : émouvant."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/superlatif-critique.svg",
      "word": "un superlatif"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/affiche-spectacle.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/oeuvre-enthousiasme.svg",
      "word": "une œuvre"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/etoile-soir.svg",
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
  "prompt": "Notez six superlatifs : trois plus, trois moins."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : le plus émouvant, la meilleure soirée, le moins attendu, la plus juste."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Critique de la première',
    'CE',
    $c$Objectif
Lire une critique positive d'une œuvre de la cour.

Consigne
Lisez la critique, sans aller trop vite.

Support — Feuille de Lila, Radio Figuier
Critique — « La cour n'oublie pas »
C'est la pièce la plus émouvante que la Saison des Voix ait ouverte.
Le moins attendu, c'est le rôle muet de Kévin : il a tenu le seau.
Sami a donné le rythme le plus juste : ni trop vite, ni trop sourd.
Mado a lu la meilleure page du Cahier du chemin, celle du figuier.
Dieudonné a tendu le rideau le moins lourd, le plus ocre.
On ne compare pas avec un titre d'ailleurs : on reste au Seuil.
La cour a offert le silence le plus dense après la dernière frappe.
Aline dit que c'est le moins long des spectacles, et le plus net.
Solange a tamponné : « première réussie ».
Je recommande cette œuvre à ceux qui écoutent vraiment.
Lila Sow
Saison des Voix — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Kévin a tenu un long discours.",
  "correct": false,
  "explanation": "« le rôle muet de Kévin : il a tenu le seau. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui a tendu le rideau ?",
  "options": [
    {
      "text": "Sami",
      "correct": false
    },
    {
      "text": "Mado",
      "correct": false
    },
    {
      "text": "Dieudonné",
      "correct": true
    },
    {
      "text": "Lila",
      "correct": false
    }
  ],
  "explanation": "« Dieudonné a tendu le rideau. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "la plus émouvante",
      "right": "pièce"
    },
    {
      "left": "le moins attendu",
      "right": "rôle muet"
    },
    {
      "left": "le plus juste",
      "right": "rythme / Sami"
    },
    {
      "left": "la meilleure page",
      "right": "Mado"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est la pièce la plus ___ que la saison ait ouverte.",
  "answer": "émouvante"
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
    "recommande",
    "cette",
    "œuvre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "recommande",
  "hint": "Lila le fait : elle… cette œuvre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est la pièce le plus émouvant que la saison ait ouverte.",
  "correct_sentence": "C'est la pièce la plus émouvante que la saison ait ouverte.",
  "explanation": "Pièce est féminin : la plus émouvante."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/affiche-spectacle.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/oeuvre-enthousiasme.svg",
      "word": "une œuvre"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/etoile-soir.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/parcours-artiste.svg",
      "word": "un parcours"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la critique et encadrez les superlatifs."
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
    'PO — Dire le plus, le moins, la meilleure',
    'PO',
    $c$Objectif
Présenter une œuvre à l'oral avec des superlatifs.

Consigne
Répétez, puis critiquez positivement un geste du Seuil.

Support — Modèles d'Aline
C'est le spectacle le plus émouvant.
C'est la meilleure soirée de la saison.
C'est le moins attendu.
C'est la page la plus juste.
C'est le rideau le moins lourd.
C'est le rythme le plus vivant.
C'est la voix la moins pressée.
C'est le silence le plus dense.
Je recommande cette œuvre.
Je ne compare pas avec ailleurs.
Je reste sous le figuier.
Je parle après avoir écouté.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Bon » au superlatif féminin, c'est « la meilleure ».",
  "correct": true,
  "explanation": "La meilleure soirée, la meilleure page."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Le moins attendu » exprime…",
  "options": [
    {
      "text": "le sommet positif de attendu",
      "correct": false
    },
    {
      "text": "le bas de l'échelle de attendu",
      "correct": true
    },
    {
      "text": "un passif",
      "correct": false
    },
    {
      "text": "un futur",
      "correct": false
    }
  ],
  "explanation": "Moins + adjectif = le plus bas degré."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le plus + adj.",
      "right": "sommet"
    },
    {
      "left": "le moins + adj.",
      "right": "degré bas"
    },
    {
      "left": "bon → le meilleur / la meilleure",
      "right": "irrégulier"
    },
    {
      "left": "je recommande",
      "right": "critique positive"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est ___ meilleure soirée de la saison.",
  "answer": "la"
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
    "recommande",
    "cette",
    "œuvre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "meilleure",
  "hint": "Bon, au sommet, au féminin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est la plus meilleure soirée de la saison sous le figuier.",
  "correct_sentence": "C'est la meilleure soirée de la saison.",
  "explanation": "Meilleure suffit : pas plus meilleure."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/oeuvre-enthousiasme.svg",
      "word": "une œuvre"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/etoile-soir.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/parcours-artiste.svg",
      "word": "un parcours"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/tambour-sami.svg",
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
  "prompt": "Écrivez huit superlatifs : 4 plus, 2 moins, 2 meilleur(e)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis une critique de huit phrases."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma critique enthousiaste',
    'PE',
    $c$Objectif
Écrire une courte critique positive.

Consigne
Imitez la critique de Hawa, sans aller trop vite.

Support — Critique de Hawa Diallo
Hawa Diallo
« La cour n'oublie pas » est la pièce la plus émouvante que j'ai entendue ici.
Le moins attendu, c'est le seau de Kévin : il n'a rien dit, la cour a compris.
Sami a tenu le rythme le plus juste. Mado a lu la meilleure page.
C'est la soirée la moins longue, et la plus nette.
Je ne cherche pas un titre d'ailleurs. Je reste au Seuil.
Je recommande cette œuvre à Radio Figuier, demain matin.
Le silence après la dernière frappe était le plus dense.
Hawa
Saison des Voix — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa cherche un titre d'ailleurs pour comparer.",
  "correct": false,
  "explanation": "« Je ne cherche pas un titre d'ailleurs. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui n'a rien dit ?",
  "options": [
    {
      "text": "Sami",
      "correct": false
    },
    {
      "text": "Mado",
      "correct": false
    },
    {
      "text": "Kévin",
      "correct": true
    },
    {
      "text": "Lila",
      "correct": false
    }
  ],
  "explanation": "« le seau de Kévin : il n'a rien dit. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "la plus émouvante",
      "right": "pièce"
    },
    {
      "left": "le moins attendu",
      "right": "seau / Kévin"
    },
    {
      "left": "le plus juste",
      "right": "Sami"
    },
    {
      "left": "la meilleure page",
      "right": "Mado"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ cette œuvre à Radio Figuier.",
  "answer": "recommande"
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
    "reste",
    "au",
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
  "word": "attendue",
  "hint": "Le moins… : le seau de Kévin (accord)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est la soirée le moins longue et le plus nette de la saison.",
  "correct_sentence": "C'est la soirée la moins longue, et la plus nette.",
  "explanation": "Soirée est féminin : la moins, la plus."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/etoile-soir.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/parcours-artiste.svg",
      "word": "un parcours"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/tambour-sami.svg",
      "word": "un tambour"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/scene-herbes.svg",
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
  "prompt": "Imitez : quatre superlatifs, un refus d'ailleurs, une recommandation."
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
    'EL — Superlatif de la critique',
    'EL',
    $c$Objectif
Retenir le plus, le moins, le meilleur / la meilleure.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
Superlatif de supériorité
le / la / les plus + adjectif : le plus émouvant, la plus nette
Superlatif d'infériorité
le / la / les moins + adjectif : le moins attendu, la moins longue
Irrégulier
bon → le meilleur / la meilleure / les meilleurs / les meilleures
Accord avec le nom : la pièce la plus émouvante ; le spectacle le plus émouvant
On n'écrit pas : la plus meilleure.
On n'écrit pas : le plus émouvante (si le nom est masculin).
Critique positive : je recommande ; c'est vivant ; c'est net.
On ne compare pas avec un titre d'ailleurs.
Œuvres du Seuil : « La cour n'oublie pas », Cahier du chemin, tambour de Sami.
Présenter une œuvre : titre, geste, effet sur la cour.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« La plus meilleure » est une forme correcte.",
  "correct": false,
  "explanation": "Meilleure suffit."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Une page juste » au sommet, c'est…",
  "options": [
    {
      "text": "la plus juste",
      "correct": true
    },
    {
      "text": "le plus juste",
      "correct": false
    },
    {
      "text": "la plus meilleure juste",
      "correct": false
    },
    {
      "text": "plus juste que juste",
      "correct": false
    }
  ],
  "explanation": "Page féminin : la plus juste."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le plus",
      "right": "sommet"
    },
    {
      "left": "le moins",
      "right": "degré bas"
    },
    {
      "left": "la meilleure",
      "right": "bon / fém."
    },
    {
      "left": "accord",
      "right": "avec le nom"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nBon → la ___ page.",
  "answer": "meilleure"
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
    "recommande",
    "cette",
    "œuvre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "irregulier",
  "hint": "Bon → meilleur : un superlatif… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est la plus meilleure page du Cahier du chemin.",
  "correct_sentence": "C'est la meilleure page du Cahier du chemin.",
  "explanation": "Pas de plus devant meilleure."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/parcours-artiste.svg",
      "word": "un parcours"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/tambour-sami.svg",
      "word": "un tambour"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/scene-herbes.svg",
      "word": "une scène"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/billet-vivant.svg",
      "word": "un billet"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau : 8 adjectifs au superlatif, accord noté."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et huit superlatifs."
}$j$::jsonb,
    9
  );

  -- ===== Spectacles et parcours =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Spectacles et parcours'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Spectacles et parcours', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Deux parcours, une saison',
    'CO',
    $c$Objectif
S'informer sur un parcours artistique et un spectacle vivant.

Consigne
Lisez le dialogue. Qui a suivi quel chemin ?

Support — Scène des Herbes, banc de Sami
Sami : Mon parcours ? Le marché, puis le figuier, puis la scène.
Mado : Le mien passe par les pages. J'écris, je rature, je lis.
Aline : Un spectacle vivant, ici, c'est un corps, un son, un silence.
Patrick : On s'informe : où, quand, combien de temps, qui joue.
Hawa : La Saison des Voix ouvre à la Salle des Herbes, à dix-huit heures.
Joël : Le parcours de Dieudonné, c'est le tissu : mesurer, couper, tendre.
Lila : Radio Figuier annoncera les horaires, pas une rumeur de salle pleine.
Karim : Le parcours de Kévin est le moins parlé : il porte le seau.
Solange : Le Bureau affiche le programme. On peut le relire.
Rose : Léa note les sièges. Marc note les lanternes.
Léa : Je m'informe avant d'entrer : durée, entrée libre, silence demandé.
Marc : Un parcours, ce n'est pas une liste d'ailleurs. C'est une suite de gestes.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'entrée de la Saison des Voix est payante et secrète.",
  "correct": false,
  "explanation": "Léa : entrée libre, silence demandé."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À quelle heure ouvre la saison, selon Hawa ?",
  "options": [
    {
      "text": "à midi",
      "correct": false
    },
    {
      "text": "à dix-huit heures",
      "correct": true
    },
    {
      "text": "à minuit",
      "correct": false
    },
    {
      "text": "à l'aube",
      "correct": false
    }
  ],
  "explanation": "« à dix-huit heures. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "parcours de Sami",
      "right": "marché / figuier / scène"
    },
    {
      "left": "parcours de Mado",
      "right": "écrire / raturer / lire"
    },
    {
      "left": "spectacle vivant",
      "right": "corps / son / silence"
    },
    {
      "left": "s'informer",
      "right": "où / quand / durée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUn spectacle ___, ici, c'est un corps, un son, un silence.",
  "answer": "vivant"
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
    "s'informe",
    "avant",
    "d'entrer",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "parcours",
  "hint": "Suite de gestes : marché, figuier, scène."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Un parcours, c'est une liste d'ailleurs copiée sur un titre inconnu.",
  "correct_sentence": "Un parcours, ce n'est pas une liste d'ailleurs. C'est une suite de gestes.",
  "explanation": "On reste au Seuil."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/tambour-sami.svg",
      "word": "un tambour"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/scene-herbes.svg",
      "word": "une scène"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/billet-vivant.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/double-pronom.svg",
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
  "prompt": "Notez trois parcours et trois infos pratiques."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : où, quand, combien de temps, qui joue. Entrée libre. Silence demandé."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Programme vivant',
    'CE',
    $c$Objectif
Lire un programme de spectacles et de parcours.

Consigne
Lisez le programme, sans aller trop vite.

Support — Affiche de saison, figuier
Saison des Voix — programme du Seuil
Mercredi 18 h — Salle des Herbes
« La cour n'oublie pas » — pièce vivante, vingt minutes.
Parcours Sami : trois frappes, un silence, une dernière frappe.
Parcours Mado : une page du Cahier du chemin, puis une autre.
Parcours Dieudonné : rideau ocre, coupon montré à la fin.
Jeudi 17 h — ombre du figuier
Cercle lecture. Entrée libre. Lanternes de la cour.
Vendredi 18 h — Marché des Lampions
Tambour et voix : Sami, puis une page de Mado sur un stand.
On s'informe au Bureau des Escales. Solange a les heures.
On n'invente pas une salle d'ailleurs.
Durée, lieu, geste : trois infos suffisent.
Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le cercle lecture a lieu le vendredi au marché.",
  "correct": false,
  "explanation": "Jeudi 17 h — ombre du figuier."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien dure la pièce ?",
  "options": [
    {
      "text": "deux heures",
      "correct": false
    },
    {
      "text": "vingt minutes",
      "correct": true
    },
    {
      "text": "huit minutes",
      "correct": false
    },
    {
      "text": "un jour",
      "correct": false
    }
  ],
  "explanation": "« vingt minutes. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "mercredi 18 h",
      "right": "pièce"
    },
    {
      "left": "jeudi 17 h",
      "right": "cercle lecture"
    },
    {
      "left": "vendredi 18 h",
      "right": "marché"
    },
    {
      "left": "Bureau",
      "right": "heures / Solange"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn s'informe au Bureau des ___.",
  "answer": "Escales"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Entrée",
    "libre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "programme",
  "hint": "Lieux, heures, gestes : le… de la saison."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Jeudi 17 h — Marché des Lampions, pièce de deux heures.",
  "correct_sentence": "Jeudi 17 h — ombre du figuier. Cercle lecture.",
  "explanation": "Le jeudi est le cercle, pas la pièce."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/scene-herbes.svg",
      "word": "une scène"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/billet-vivant.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/double-pronom.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/critique-reagir.svg",
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
  "prompt": "Recopiez le programme et ajoutez un samedi inventé au Seuil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le programme, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Demander un parcours',
    'PO',
    $c$Objectif
S'informer à l'oral sur un spectacle vivant.

Consigne
Répétez les questions, puis informez un camarade.

Support — Questions de Patrick
Où joue-t-on ce soir ?
À quelle heure est-ce que ça commence ?
Combien de temps cela dure-t-il ?
Qui frappe ? Qui lit ? Qui tend le rideau ?
Est-ce un spectacle vivant ?
L'entrée est-elle libre ?
Doit-on garder le silence ?
Quel est le parcours de Sami ?
Quel est le parcours de Mado ?
Où s'informer si j'arrive tard ?
Au Bureau des Escales.
Sous le figuier, à dix-huit heures.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick pose des questions pour s'informer, pas pour juger.",
  "correct": true,
  "explanation": "Où, quand, durée, qui."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où s'informer si l'on arrive tard ?",
  "options": [
    {
      "text": "dans une rumeur",
      "correct": false
    },
    {
      "text": "au Bureau des Escales",
      "correct": true
    },
    {
      "text": "sous l'eau",
      "correct": false
    },
    {
      "text": "nulle part",
      "correct": false
    }
  ],
  "explanation": "Solange a les heures."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "où / à quelle heure",
      "right": "lieu / temps"
    },
    {
      "left": "combien de temps",
      "right": "durée"
    },
    {
      "left": "qui",
      "right": "parcours"
    },
    {
      "left": "entrée libre / silence",
      "right": "consignes"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'entrée est-elle ___ ?",
  "answer": "libre"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Où",
    "joue-t-on",
    "ce",
    "soir",
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
  "word": "vivant",
  "hint": "Un spectacle… : corps, son, silence."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Où joue-t-on ce soir à quelle salle d'ailleurs payante ?",
  "correct_sentence": "Où joue-t-on ce soir ? Sous le figuier, à dix-huit heures.",
  "explanation": "On répond au Seuil."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/billet-vivant.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/double-pronom.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/critique-reagir.svg",
      "word": "une critique"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/livre-commente.svg",
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
  "prompt": "Écrivez dix questions d'information sur la saison."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les questions, puis deux réponses complètes."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma fiche parcours',
    'PE',
    $c$Objectif
Écrire une fiche d'information sur un parcours artistique.

Consigne
Imitez la fiche de Mado, sans aller trop vite.

Support — Fiche de Mado, Cahier du chemin
Mado
Parcours : j'écris sous le figuier, je rature à la Table des Sources, je lis à la Salle des Herbes.
Spectacle vivant du mercredi : « La cour n'oublie pas », vingt minutes.
Lieu : Salle des Herbes. Heure : dix-huit heures. Entrée libre.
Silence demandé après la dernière frappe de Sami.
On s'informe auprès de Solange si l'on arrive après le salut.
Je ne copie aucun programme d'ailleurs.
Mon geste : une page, puis une autre, sans courir.
Mado
Saison des Voix — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado court d'une page à l'autre.",
  "correct": false,
  "explanation": "« sans courir. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Mado rature-t-elle ?",
  "options": [
    {
      "text": "au Marché des Lampions",
      "correct": false
    },
    {
      "text": "à la Table des Sources",
      "correct": true
    },
    {
      "text": "sous l'eau",
      "correct": false
    },
    {
      "text": "au Bureau seulement",
      "correct": false
    }
  ],
  "explanation": "« je rature à la Table des Sources. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "écrire",
      "right": "figuier"
    },
    {
      "left": "raturer",
      "right": "Table des Sources"
    },
    {
      "left": "lire",
      "right": "Salle des Herbes"
    },
    {
      "left": "s'informer",
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
  "prompt": "Complétez :\nEntrée ___. Silence demandé.",
  "answer": "libre"
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
    "copie",
    "aucun",
    "programme",
    "d'ailleurs",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "rature",
  "hint": "Mado le fait à la Table : elle… une phrase."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lieu : une salle d'ailleurs. Heure : on verra. Entrée secrète.",
  "correct_sentence": "Lieu : Salle des Herbes. Heure : dix-huit heures. Entrée libre.",
  "explanation": "Une fiche informe vraiment."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/double-pronom.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/critique-reagir.svg",
      "word": "une critique"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/livre-commente.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/micro-avis.svg",
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
  "prompt": "Imitez : parcours en trois gestes, lieu, heure, consigne."
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
    'EL — S''informer sur un spectacle',
    'EL',
    $c$Objectif
Retenir les questions et le lexique du spectacle vivant.

Consigne
Apprenez la fiche.

Support — Fiche programme
Questions
Où ? À quelle heure ? Combien de temps ? Qui ?
L'entrée est-elle libre ? Doit-on garder le silence ?
Lexique : spectacle vivant = corps, son, silence, scène, rideau, frappe
parcours : une suite de gestes, pas une liste d'ailleurs
saison : plusieurs soirs reliés (Saison des Voix)
Infos : durée, lieu, heure, entrée, silence, où s'informer
Au Seuil : Salle des Herbes, figuier, Marché des Lampions, Bureau des Escales
On n'invente pas une salle lointaine.
On n'annonce pas une salle pleine comme une preuve.
Radio Figuier dit les heures. Solange les a sur feuille.
Un billet, ici, peut être une feuille ocre : entrée libre.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Un parcours est une liste copiée ailleurs.",
  "correct": false,
  "explanation": "Suite de gestes du Seuil."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que signifie « spectacle vivant » au Seuil ?",
  "options": [
    {
      "text": "un écran seulement",
      "correct": false
    },
    {
      "text": "un corps, un son, un silence",
      "correct": true
    },
    {
      "text": "une rumeur",
      "correct": false
    },
    {
      "text": "un tampon",
      "correct": false
    }
  ],
  "explanation": "Aline : corps, son, silence."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "où / quand",
      "right": "questions"
    },
    {
      "left": "vivant",
      "right": "corps / son"
    },
    {
      "left": "parcours",
      "right": "gestes"
    },
    {
      "left": "saison",
      "right": "plusieurs soirs"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUn ___ , ici, c'est une suite de gestes.",
  "answer": "parcours"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "L'entrée",
    "est-elle",
    "libre",
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
  "word": "silence",
  "hint": "Demandé après la dernière frappe."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On annonce une salle pleine d'ailleurs comme une preuve de qualité.",
  "correct_sentence": "On n'annonce pas une salle pleine comme une preuve. Radio Figuier dit les heures.",
  "explanation": "S'informer ≠ vanter une foule."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/critique-reagir.svg",
      "word": "une critique"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/livre-commente.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/micro-avis.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/interrogation-lire.svg",
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
  "prompt": "Rédigez six questions et six réponses sur un soir de saison."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et un dialogue d'information."
}$j$::jsonb,
    9
  );

  -- ===== Réagir à une œuvre =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Réagir à une œuvre'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Réagir à une œuvre', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Je le lui ai dit',
    'CO',
    $c$Objectif
Réagir à une critique ; double pronominalisation.

Consigne
Lisez le dialogue. Où vont le, la, les, lui, me, te ?

Support — Micro d'avis, banc de la cour
Léa : J'ai lu la critique de Lila. Je le lui ai dit : elle est juste.
Marc : On me l'a conseillée, cette pièce. J'y suis allé.
Aline : Je te les envoie, les deux pages de Mado.
Patrick : Ne me le répète pas : j'ai déjà entendu le seau de Kévin.
Hawa : Elle nous les a montrés, les coupons du rideau.
Joël : Je vous le promets : je garderai le silence.
Lila : Tu me l'as dit trop vite. Dis-le-moi plus lentement.
Karim : Je les lui ai rendus, les sièges, après la pièce.
Rose : On te l'a défendu, de crier. Tu as bien fait.
Solange : Je le leur ai lu, le programme, au Bureau.
Mado : Ne nous les cache pas, tes ratures : elles enseignent.
Sami : Je te le joue une fois, le rythme, pas deux.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick veut qu'on lui répète encore le seau de Kévin.",
  "correct": false,
  "explanation": "« Ne me le répète pas. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Je te les envoie » : les, c'est…",
  "options": [
    {
      "text": "Lila et Hawa",
      "correct": false
    },
    {
      "text": "les deux pages de Mado",
      "correct": true
    },
    {
      "text": "les tambours",
      "correct": false
    },
    {
      "text": "les tampons",
      "correct": false
    }
  ],
  "explanation": "Aline : les deux pages."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je le lui ai dit",
      "right": "critique / Lila"
    },
    {
      "left": "on me l'a conseillée",
      "right": "pièce"
    },
    {
      "left": "je te les envoie",
      "right": "pages"
    },
    {
      "left": "ne me le répète pas",
      "right": "Patrick"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ lui ai dit : elle est juste.",
  "answer": "le"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ne",
    "me",
    "le",
    "répète",
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
  "word": "promette",
  "hint": "Joël : je vous le… (silence)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je lui le ai dit : la critique est juste.",
  "correct_sentence": "Je le lui ai dit : elle est juste.",
  "explanation": "COD (le) avant COI (lui)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/livre-commente.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/micro-avis.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/interrogation-lire.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/importance-livres.svg",
      "word": "l'importance"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez six doubles pronoms et ce qu'ils remplacent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je le lui ai dit. On me l'a conseillé. Je te les envoie. Ne me le répète pas."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Réponses à la critique',
    'CE',
    $c$Objectif
Lire des réactions qui commentent une œuvre.

Consigne
Lisez les réactions, sans aller trop vite.

Support — Cahier des avis, Salle des Herbes
Réactions à la critique de Lila
Léa : Je le lui ai dit, à Lila : sa phrase sur le silence est la plus juste.
Marc : On me l'a conseillé, ce texte. Je le trouve net, pas cruel.
Aline : Je te les copie, tes doutes, Karim : ils aident la cour.
Patrick : Ne me le répète pas comme une rumeur. Dis-le comme un avis.
Hawa : Elle me l'a lu trop vite. Je le lui redemanderai demain.
Joël : Vous nous l'avez promis, le silence. Nous l'avons tenu.
Mado : Je les lui ai montrées, mes ratures. Elle n'a pas ri.
Sami : Je te le tiens, le tempo, si tu m'écoutes.
On réagit : on dit d'accord, pas d'accord, j'ajoute, je précise.
On ne déchire pas une critique. On lui répond.
Saison des Voix
Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado dit que Lila a ri des ratures.",
  "correct": false,
  "explanation": "« Elle n'a pas ri. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que trouve Marc du texte de Lila ?",
  "options": [
    {
      "text": "cruel",
      "correct": false
    },
    {
      "text": "net, pas cruel",
      "correct": true
    },
    {
      "text": "trop long",
      "correct": false
    },
    {
      "text": "faux",
      "correct": false
    }
  ],
  "explanation": "« net, pas cruel. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je le lui ai dit",
      "right": "Léa / Lila"
    },
    {
      "left": "on me l'a conseillé",
      "right": "Marc"
    },
    {
      "left": "ne me le répète pas",
      "right": "Patrick"
    },
    {
      "left": "je les lui ai montrées",
      "right": "ratures / Mado"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ne déchire pas une critique. On ___ répond.",
  "answer": "lui"
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
    "lui",
    "répond",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "reagir",
  "hint": "Dire d'accord ou pas : … à une œuvre (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je lui les ai montrées, mes ratures, trop tard le soir.",
  "correct_sentence": "Je les lui ai montrées, mes ratures.",
  "explanation": "Les (COD) avant lui (COI)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/micro-avis.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/interrogation-lire.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/importance-livres.svg",
      "word": "l'importance"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/cahier-chemin.svg",
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
  "prompt": "Recopiez quatre réactions et ajoutez la vôtre avec un double pronom."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les réactions, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Le lui, me le, te les',
    'PO',
    $c$Objectif
Placer deux pronoms à l'oral.

Consigne
Répétez, puis réagissez à une critique de la cour.

Support — Modèles d'Aline
Je le lui ai dit.
On me l'a conseillé.
Je te les envoie.
Ne me le répète pas.
Elle nous les a montrés.
Je vous le promets.
Dis-le-moi.
Je les lui ai rendus.
On te l'a défendu.
Je le leur ai lu.
Ne nous les cache pas.
Je te le joue.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "À l'impératif affirmatif, on dit souvent « dis-le-moi ».",
  "correct": true,
  "explanation": "Traits d'union : dis-le-moi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "L'ordre le plus fréquent devant le verbe conjugué, c'est…",
  "options": [
    {
      "text": "lui + le",
      "correct": false
    },
    {
      "text": "le / la / les puis lui / leur",
      "correct": true
    },
    {
      "text": "leur + les + me",
      "correct": false
    },
    {
      "text": "y + le + me",
      "correct": false
    }
  ],
  "explanation": "Je le lui ai dit. Je les lui ai rendus."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "me / te / nous / vous",
      "right": "avant le/la/les"
    },
    {
      "left": "le / la / les",
      "right": "avant lui / leur"
    },
    {
      "left": "ne… pas",
      "right": "entoure le groupe"
    },
    {
      "left": "dis-le-moi",
      "right": "impératif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ lui ai dit.",
  "answer": "le"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Dis-le-moi",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ordre",
  "hint": "Me, le, lui : un… à retenir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je lui le ai dit après la pièce sous le figuier.",
  "correct_sentence": "Je le lui ai dit après la pièce sous le figuier.",
  "explanation": "Le avant lui ; élision : je le lui ai."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/interrogation-lire.svg",
      "word": "une question"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/importance-livres.svg",
      "word": "l'importance"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/cahier-chemin.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/lecteur-mado.svg",
      "word": "un lecteur"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez huit phrases : deux noms → deux pronoms."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les douze modèles, puis quatre réactions à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma réaction',
    'PE',
    $c$Objectif
Écrire une réaction à une critique, avec doubles pronoms.

Consigne
Imitez la réaction de Rose, sans aller trop vite.

Support — Réaction de Rose Iradukunda
Rose Iradukunda
J'ai lu Lila. Je le lui ai dit : sa critique est la plus nette.
On me l'a conseillé, ce silence après le tambour. Je l'ai tenu.
Je te les envoie, Léa, mes deux phrases d'avis.
Ne me le répète pas comme une une : c'est un commentaire, pas une rumeur.
Elle nous les a montrées, les ratures de Mado. Je les trouve utiles.
Je vous le promets : je reviendrai jeudi au cercle.
C'est la réaction la plus calme que je sache écrire.
Rose
Saison des Voix — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose traite la critique comme une rumeur de une.",
  "correct": false,
  "explanation": "« c'est un commentaire, pas une rumeur. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À qui Rose envoie-t-elle ses deux phrases ?",
  "options": [
    {
      "text": "Lila",
      "correct": false
    },
    {
      "text": "Mado",
      "correct": false
    },
    {
      "text": "Léa",
      "correct": true
    },
    {
      "text": "Sami",
      "correct": false
    }
  ],
  "explanation": "« Je te les envoie, Léa. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je le lui ai dit",
      "right": "Lila"
    },
    {
      "left": "on me l'a conseillé",
      "right": "silence"
    },
    {
      "left": "je te les envoie",
      "right": "phrases / Léa"
    },
    {
      "left": "je vous le promets",
      "right": "cercle jeudi"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe te ___ envoie, Léa, mes deux phrases d'avis.",
  "answer": "les"
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
    "vous",
    "le",
    "promets",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "commentaire",
  "hint": "Pas une rumeur : un…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je lui le ai dit : sa critique est la plus nette.",
  "correct_sentence": "Je le lui ai dit : sa critique est la plus nette.",
  "explanation": "Le avant lui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/importance-livres.svg",
      "word": "l'importance"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/cahier-chemin.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/lecteur-mado.svg",
      "word": "un lecteur"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/soiree-lecture.svg",
      "word": "une soirée"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : cinq doubles pronoms, un accord, un refus de rumeur."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre réaction, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Double pronominalisation',
    'EL',
    $c$Objectif
Retenir l'ordre des pronoms pour réagir.

Consigne
Apprenez la fiche.

Support — Fiche des pronoms
Devant le verbe conjugué
me / te / nous / vous + le / la / les + lui / leur
Je le lui ai dit. On me l'a conseillé. Je te les envoie.
Négation : ne me le répète pas. Ne nous les cache pas.
Impératif : dis-le-moi. Envoie-les-lui. Montre-les-nous.
Accord : on me l'a conseillée (la pièce). Elle nous les a montrés (les coupons).
On n'écrit pas : je lui le ai dit. On n'écrit pas : je les te envoie.
Réagir : d'accord / pas d'accord / j'ajoute / je précise
On répond à une critique. On ne la déchire pas.
Au Seuil : Lila, Mado, Sami, la pièce, le Cahier du chemin.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je les te envoie » est l'ordre correct.",
  "correct": false,
  "explanation": "Je te les envoie."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Ne me le répète pas » place les pronoms…",
  "options": [
    {
      "text": "après pas",
      "correct": false
    },
    {
      "text": "entre ne et pas",
      "correct": true
    },
    {
      "text": "avant ne",
      "correct": false
    },
    {
      "text": "nulle part",
      "correct": false
    }
  ],
  "explanation": "Ne + pronoms + verbe + pas."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "me / te + le",
      "right": "avant lui"
    },
    {
      "left": "le + lui",
      "right": "COD puis COI"
    },
    {
      "left": "dis-le-moi",
      "right": "impératif"
    },
    {
      "left": "accord",
      "right": "avec le COD si avant"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe te ___ envoie.",
  "answer": "les"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ne",
    "nous",
    "les",
    "cache",
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
  "word": "pronoms",
  "hint": "Le, lui, me, te : ce sont des…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je les te envoie demain matin sous le figuier.",
  "correct_sentence": "Je te les envoie demain matin sous le figuier.",
  "explanation": "Te avant les."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/cahier-chemin.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/lecteur-mado.svg",
      "word": "un lecteur"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/soiree-lecture.svg",
      "word": "une soirée"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/lampe-page.svg",
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
  "prompt": "Fiche personnelle : 10 phrases, tous les schémas de la leçon."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et dix doubles pronoms."
}$j$::jsonb,
    9
  );

  -- ===== Pourquoi lire =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Pourquoi lire'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Pourquoi lire', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Qu''est-ce qui nous tient ?',
    'CO',
    $c$Objectif
Questionner l'importance des livres ; interrogation.

Consigne
Lisez le dialogue. Qu'est-ce qui / qu'est-ce que / inversion ?

Support — Banc des livres, ombre du figuier
Aline : Qu'est-ce qui tient la cour ensemble, le soir ?
Mado : Qu'est-ce que nous lisons, si ce n'est nos propres pages ?
Patrick : Avez-vous ouvert le Cahier du chemin cette semaine ?
Léa : Pourquoi lire, si l'on peut seulement écouter le tambour ?
Marc : Parce que la page garde ce que le son laisse filer.
Hawa : Qu'est-ce qui vous émeut dans « Le figuier n'oublie pas » ?
Joël : Qu'est-ce que Kévin a compris sans une phrase ?
Lila : Avez-vous entendu la lecture de Mado jusqu'au bout ?
Karim : Pourquoi lire à voix haute, sous le figuier ?
Solange : Pour que le Bureau n'ait pas que des tampons dans le dossier.
Rose : Qu'est-ce qui manque si personne n'ouvre un cahier ?
Sami : Le rythme. Mais le rythme seul n'écrit pas les noms.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc dit que la page est inutile si le tambour joue.",
  "correct": false,
  "explanation": "« la page garde ce que le son laisse filer. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Qu'est-ce qui tient la cour » : qui reprend…",
  "options": [
    {
      "text": "l'objet",
      "correct": false
    },
    {
      "text": "le sujet",
      "correct": true
    },
    {
      "text": "un lieu",
      "correct": false
    },
    {
      "text": "une heure",
      "correct": false
    }
  ],
  "explanation": "Qu'est-ce qui = sujet."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qu'est-ce qui",
      "right": "sujet"
    },
    {
      "left": "qu'est-ce que",
      "right": "objet"
    },
    {
      "left": "avez-vous",
      "right": "inversion"
    },
    {
      "left": "pourquoi lire",
      "right": "infinitif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___-vous ouvert le Cahier du chemin cette semaine ?",
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
    "Pourquoi",
    "lire",
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
  "word": "ensemble",
  "hint": "Aline : ce qui tient la cour…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Qu'est-ce que tient la cour ensemble le soir sous le figuier ?",
  "correct_sentence": "Qu'est-ce qui tient la cour ensemble, le soir ?",
  "explanation": "Sujet du verbe tenir → qu'est-ce qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/lecteur-mado.svg",
      "word": "un lecteur"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/soiree-lecture.svg",
      "word": "une soirée"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/lampe-page.svg",
      "word": "une lampe"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/cercle-voix.svg",
      "word": "un cercle"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Classez huit questions : qui / que / inversion / infinitif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Qu'est-ce qui tient la cour ? Qu'est-ce que nous lisons ? Avez-vous ouvert le cahier ? Pourquoi lire ?"
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Éloge de la page',
    'CE',
    $c$Objectif
Lire un texte sur l'importance des livres au Seuil.

Consigne
Lisez l'éloge, sans aller trop vite.

Support — Page de Mado, Cahier du chemin
Pourquoi lire au Seuil des Sources
Qu'est-ce qui reste après la frappe de Sami ? Une page peut le garder.
Qu'est-ce que nous devons aux anciens de la cour ? Des noms, des gestes.
Avez-vous vu « Le figuier n'oublie pas » ? Ce n'est pas un titre d'ailleurs.
C'est le livre inventé de la cour, relu chaque saison.
Pourquoi lire à voix haute ? Pour que Léa, Joël, Kévin entendent leur nom.
Pourquoi lire seul ? Pour raturer sans honte, à la Table des Sources.
Un livre, ici, n'est pas une vitrine. C'est un banc, une lampe, une mémoire.
Radio Figuier peut le dire. Elle ne remplace pas la page.
Solange range une copie au Bureau. La cour range l'autre sous le figuier.
Lisez. Relisez. Offrez une phrase, pas une rumeur.
Mado
Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Le figuier n'oublie pas » est présenté comme un titre d'ailleurs.",
  "correct": false,
  "explanation": "« Ce n'est pas un titre d'ailleurs. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi lire à voix haute, selon Mado ?",
  "options": [
    {
      "text": "pour remplacer Sami",
      "correct": false
    },
    {
      "text": "pour que des prénoms soient entendus",
      "correct": true
    },
    {
      "text": "pour faire une rumeur",
      "correct": false
    },
    {
      "text": "pour fermer le Bureau",
      "correct": false
    }
  ],
  "explanation": "« Pour que Léa, Joël, Kévin entendent leur nom. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qu'est-ce qui reste",
      "right": "après la frappe"
    },
    {
      "left": "qu'est-ce que nous devons",
      "right": "noms / gestes"
    },
    {
      "left": "avez-vous vu",
      "right": "le livre de la cour"
    },
    {
      "left": "pourquoi lire",
      "right": "voix haute / seul"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAvez-vous vu « Le figuier n'oublie ___ » ?",
  "answer": "pas"
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
    "."
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
  "hint": "La page est un banc, une lampe, une… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Qu'est-ce que reste après la frappe de Sami sous le figuier ?",
  "correct_sentence": "Qu'est-ce qui reste après la frappe de Sami ?",
  "explanation": "Rester → sujet : qu'est-ce qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/soiree-lecture.svg",
      "word": "une soirée"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/lampe-page.svg",
      "word": "une lampe"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/cercle-voix.svg",
      "word": "un cercle"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/banc-livre.svg",
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
  "prompt": "Recopiez quatre questions de l'éloge et répondez-y."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'éloge, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Poser la question juste',
    'PO',
    $c$Objectif
Interroger à l'oral : qui, que, inversion, infinitif.

Consigne
Répétez, puis debatez : pourquoi lire ?

Support — Modèles d'Aline
Qu'est-ce qui vous émeut ?
Qu'est-ce que vous gardez d'une page ?
Avez-vous relu le cahier ?
Pourquoi lire sous le figuier ?
Pourquoi lire à voix haute ?
Pourquoi lire seul ?
Qu'est-ce qui manque sans livre ?
Qu'est-ce que le tambour ne peut pas écrire ?
Avez-vous prêté votre page ?
Pourquoi offrir une phrase ?
Je lis pour garder les noms.
Nous lisons pour nous entendre.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Pourquoi lire » est une question à l'infinitif.",
  "correct": true,
  "explanation": "Infinitif : question générale."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pour l'objet « vous gardez une page », on demande…",
  "options": [
    {
      "text": "qu'est-ce qui vous gardez",
      "correct": false
    },
    {
      "text": "qu'est-ce que vous gardez",
      "correct": true
    },
    {
      "text": "avez-vous qui",
      "correct": false
    },
    {
      "text": "pourquoi que",
      "correct": false
    }
  ],
  "explanation": "Qu'est-ce que + sujet + verbe."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qu'est-ce qui",
      "right": "sujet"
    },
    {
      "left": "qu'est-ce que",
      "right": "objet"
    },
    {
      "left": "avez-vous",
      "right": "inversion"
    },
    {
      "left": "pourquoi + inf.",
      "right": "question large"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nQu'est-ce ___ vous émeut ?",
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
    "Avez-vous",
    "relu",
    "le",
    "cahier",
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
  "word": "debattre",
  "hint": "Pourquoi lire : on peut échanger des raisons, sans accent."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Qu'est-ce qui vous gardez d'une page sous le figuier ?",
  "correct_sentence": "Qu'est-ce que vous gardez d'une page ?",
  "explanation": "Garder + objet → qu'est-ce que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/lampe-page.svg",
      "word": "une lampe"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/cercle-voix.svg",
      "word": "un cercle"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/banc-livre.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/saison-culturelle.svg",
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
  "prompt": "Écrivez douze questions : 3 qui, 3 que, 3 inversions, 3 pourquoi + inf."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis un échange de huit répliques."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Pourquoi je lis',
    'PE',
    $c$Objectif
Écrire un texte qui justifie la lecture, avec des questions.

Consigne
Imitez le texte de Léa, sans aller trop vite.

Support — Texte de Léa Niyonzima
Léa Niyonzima
Qu'est-ce qui me tient, le soir ? Une phrase de Mado, parfois deux.
Qu'est-ce que je garde ? Les noms de la cour, pas une rumeur.
Avez-vous ouvert « Le figuier n'oublie pas » ? Je l'ai relu sous la lampe.
Pourquoi lire ? Pour que le tambour de Sami ne reste pas seul.
Pourquoi lire à voix haute ? Pour que Joël entende qu'on l'a vu.
Je n'emprunte pas un titre d'ailleurs. J'emprunte le Cahier du chemin.
La page garde ce que le son laisse filer.
Léa
Seuil des Sources — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa emprunte un titre d'ailleurs.",
  "correct": false,
  "explanation": "« Je n'emprunte pas un titre d'ailleurs. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pourquoi Léa lit-elle à voix haute ?",
  "options": [
    {
      "text": "pour fermer Radio Figuier",
      "correct": false
    },
    {
      "text": "pour que Joël entende qu'on l'a vu",
      "correct": true
    },
    {
      "text": "pour vendre le cahier",
      "correct": false
    },
    {
      "text": "pour remplacer Solange",
      "correct": false
    }
  ],
  "explanation": "« Pour que Joël entende qu'on l'a vu. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qu'est-ce qui me tient",
      "right": "phrase de Mado"
    },
    {
      "left": "qu'est-ce que je garde",
      "right": "noms"
    },
    {
      "left": "avez-vous ouvert",
      "right": "livre de la cour"
    },
    {
      "left": "pourquoi lire",
      "right": "tambour / Joël"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPourquoi ___ ? Pour que le tambour de Sami ne reste pas seul.",
  "answer": "lire"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'emprunte",
    "le",
    "Cahier",
    "du",
    "chemin",
    "."
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
  "hint": "Léa le refuse pour un titre d'ailleurs ; elle… le cahier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Qu'est-ce que me tient, le soir, sous la lampe du figuier ?",
  "correct_sentence": "Qu'est-ce qui me tient, le soir ?",
  "explanation": "Sujet → qu'est-ce qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/cercle-voix.svg",
      "word": "un cercle"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/banc-livre.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/saison-culturelle.svg",
      "word": "une saison"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/calendrier-voix.svg",
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
  "prompt": "Imitez : deux qui, deux que, une inversion, deux pourquoi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre texte, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Qu''est-ce qui, qu''est-ce que, inversion',
    'EL',
    $c$Objectif
Retenir les formes d'interrogation pour parler des livres.

Consigne
Apprenez la fiche.

Support — Fiche questions
Sujet
Qu'est-ce qui + verbe : Qu'est-ce qui vous émeut ?
Objet
Qu'est-ce que + sujet + verbe : Qu'est-ce que vous gardez ?
Inversion
Avez-vous ouvert le cahier ? L'entrée est-elle libre ?
Infinitif
Pourquoi lire ? Pourquoi lire à voix haute ? Pourquoi offrir une phrase ?
On n'écrit pas : qu'est-ce que tient la cour (sujet → qui).
On n'écrit pas : qu'est-ce qui vous gardez (objet → que).
Importance des livres au Seuil
garder les noms, relire « Le figuier n'oublie pas », raturer sans honte
Radio Figuier dit. La page garde.
Répondre : je lis pour… / nous lisons pour que + subjonctif.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Qu'est-ce qui » introduit le sujet.",
  "correct": true,
  "explanation": "Qu'est-ce qui vous émeut ?"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Avez-vous relu » est…",
  "options": [
    {
      "text": "un qu'est-ce qui",
      "correct": false
    },
    {
      "text": "une inversion",
      "correct": true
    },
    {
      "text": "un infinitif",
      "correct": false
    },
    {
      "text": "un passif",
      "correct": false
    }
  ],
  "explanation": "Inversion sujet-verbe."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qu'est-ce qui",
      "right": "sujet"
    },
    {
      "left": "qu'est-ce que",
      "right": "objet"
    },
    {
      "left": "avez-vous",
      "right": "inversion"
    },
    {
      "left": "pourquoi lire",
      "right": "infinitif"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nQu'est-ce ___ vous gardez ?",
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
    "Pourquoi",
    "lire",
    "à",
    "voix",
    "haute",
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
  "hint": "Avez-vous : une… du sujet."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Qu'est-ce qui vous gardez d'une page du Cahier du chemin ?",
  "correct_sentence": "Qu'est-ce que vous gardez d'une page ?",
  "explanation": "Objet → que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/banc-livre.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/saison-culturelle.svg",
      "word": "une saison"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/calendrier-voix.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/tissu-scene.svg",
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
  "prompt": "Inventez 12 questions sur « Le figuier n'oublie pas »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et douze questions."
}$j$::jsonb,
    9
  );

  -- ===== Soirée lecture =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Soirée lecture'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Soirée lecture', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Cercle sous le figuier',
    'CO',
    $c$Objectif
Suivre une soirée lecture et le rôle du Cahier du chemin.

Consigne
Lisez le dialogue. Qui lit ? Qui écoute ? Qui rature ?

Support — Cercle des voix, lampe-page
Mado : On s'assoit en cercle. La Lampe-Figue suffit pour une page.
Aline : Qu'est-ce qui ouvre ? Une frappe de Sami, puis le silence.
Léa : Je te les lis, tes ratures, si tu veux. Sinon je lis les miennes.
Patrick : Avez-vous apporté le Cahier du chemin ? Il est au milieu.
Hawa : On me l'a conseillé, ce cercle. Je le trouve le plus calme.
Joël : Ne me le répète pas trop vite. Lisez plus lentement.
Lila : Radio Figuier n'enregistre pas ce soir. C'est pour la cour seulement.
Karim : Pourquoi lire ici, et pas au marché ? Parce que le marché vend.
Rose : La meilleure page n'est pas la plus longue.
Solange : Je le leur ai dit aux absents : on relira demain à la Table.
Kévin : Je n'ai rien dit. J'ai tenu le seau des lanternes éteintes.
Sami : Une frappe pour ouvrir. Une frappe pour fermer. Rien entre les deux, sauf la page.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Radio Figuier enregistre toute la soirée.",
  "correct": false,
  "explanation": "Lila : « n'enregistre pas ce soir. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où est le Cahier du chemin, selon Patrick ?",
  "options": [
    {
      "text": "au Bureau",
      "correct": false
    },
    {
      "text": "au milieu du cercle",
      "correct": true
    },
    {
      "text": "sous l'eau",
      "correct": false
    },
    {
      "text": "au marché",
      "correct": false
    }
  ],
  "explanation": "« Il est au milieu. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "cercle",
      "right": "sous le figuier"
    },
    {
      "left": "Cahier du chemin",
      "right": "milieu"
    },
    {
      "left": "pas d'enregistrement",
      "right": "Lila"
    },
    {
      "left": "seau / lanternes",
      "right": "Kévin"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nRadio Figuier n'___ pas ce soir.",
  "answer": "enregistre"
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
    "au",
    "milieu",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "cercle",
  "hint": "On s'assoit ainsi sous le figuier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Radio Figuier enregistre ce soir pour le marché entier.",
  "correct_sentence": "Radio Figuier n'enregistre pas ce soir. C'est pour la cour seulement.",
  "explanation": "Le cercle est intime."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/saison-culturelle.svg",
      "word": "une saison"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/calendrier-voix.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/tissu-scene.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/danse-cour.svg",
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
  "prompt": "Notez le rituel : frappe, silence, page, frappe."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez le rituel du cercle, puis une page lue lentement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Règles du cercle',
    'CE',
    $c$Objectif
Lire les règles d'une soirée lecture.

Consigne
Lisez les règles, sans aller trop vite.

Support — Feuille du cercle, Cahier du chemin
Règles — soirée lecture sous le figuier
1. On s'assoit en cercle. Le cahier est au milieu.
2. Sami ouvre par une frappe. On se tait.
3. On lit une page, pas trois. La plus juste suffit.
4. On peut montrer ses ratures. On ne se moque pas.
5. Qu'est-ce qui est interdit ? La rumeur, le cri, l'enregistrement.
6. Qu'est-ce que l'on offre ? Une phrase, un silence, un prénom.
7. Avez-vous un doute ? Demandez après la page, pas pendant.
8. Pourquoi lire ici ? Pour que la cour s'entende sans micro.
9. Kévin peut tenir le seau sans parler. C'est un rôle.
10. Une frappe ferme. On range la Lampe-Figue.
Signé : Mado, Aline, Sami
Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On lit trois pages d'un trait.",
  "correct": false,
  "explanation": "« On lit une page, pas trois. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quand demande-t-on si l'on a un doute ?",
  "options": [
    {
      "text": "pendant la page",
      "correct": false
    },
    {
      "text": "après la page",
      "correct": true
    },
    {
      "text": "au marché",
      "correct": false
    },
    {
      "text": "jamais",
      "correct": false
    }
  ],
  "explanation": "« après la page, pas pendant. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "une page",
      "right": "pas trois"
    },
    {
      "left": "ratures",
      "right": "sans moquerie"
    },
    {
      "left": "interdit",
      "right": "rumeur / cri / enregistrement"
    },
    {
      "left": "Kévin",
      "right": "seau / rôle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn lit une page, pas ___.",
  "answer": "trois"
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
    "se",
    "moque",
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
  "word": "moquerie",
  "hint": "Interdite quand on montre les ratures."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On lit trois pages et on se moque des ratures pour rire.",
  "correct_sentence": "On lit une page, pas trois. On peut montrer ses ratures. On ne se moque pas.",
  "explanation": "Le cercle protège."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/calendrier-voix.svg",
      "word": "un calendrier"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/tissu-scene.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/danse-cour.svg",
      "word": "une danse"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/radio-culture.svg",
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
  "prompt": "Recopiez cinq règles et ajoutez-en une à vous."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les dix règles, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Tenir le cercle',
    'PO',
    $c$Objectif
Animer une soirée lecture à l'oral.

Consigne
Répétez les formules, puis animez un mini-cercle.

Support — Formules de Mado
Asseyez-vous. Le cahier est au milieu.
Sami, une frappe. Merci.
J'ouvre une page. Je la lis sans courir.
Je te les montre, mes ratures, si tu veux.
Ne me le coupe pas. Attends la fin.
Qu'est-ce qui vous reste ? Dites un mot.
Avez-vous un doute ? Après, pas pendant.
Pourquoi relire cette phrase ? Parce qu'elle tient.
Je vous le promets : on fermera à l'heure.
Une frappe. On range.
Merci à la cour.
Merci au figuier.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado autorise qu'on coupe la lecture.",
  "correct": false,
  "explanation": "« Ne me le coupe pas. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que demande Mado juste après la page ?",
  "options": [
    {
      "text": "une rumeur",
      "correct": false
    },
    {
      "text": "un mot de ce qui reste",
      "correct": true
    },
    {
      "text": "un enregistrement",
      "correct": false
    },
    {
      "text": "un cri",
      "correct": false
    }
  ],
  "explanation": "« Qu'est-ce qui vous reste ? Dites un mot. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "une frappe",
      "right": "ouvrir / fermer"
    },
    {
      "left": "sans courir",
      "right": "lire"
    },
    {
      "left": "après, pas pendant",
      "right": "doutes"
    },
    {
      "left": "un mot",
      "right": "reste"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNe me le ___ pas. Attends la fin.",
  "answer": "coupe"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Dites",
    "un",
    "mot",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "animer",
  "hint": "Tenir le cercle : … la soirée."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ne le me coupe pas dès la première ligne. Attends la fin.",
  "correct_sentence": "Ne me le coupe pas dès la première ligne. Attends la fin.",
  "explanation": "Ordre : me + le + verbe."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/tissu-scene.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/danse-cour.svg",
      "word": "une danse"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/radio-culture.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/couverture-conte.svg",
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
  "prompt": "Écrivez un canevas d'animation de douze phrases."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les formules, puis une ouverture et une fermeture."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma page pour le cercle',
    'PE',
    $c$Objectif
Écrire une page destinée à la soirée lecture.

Consigne
Imitez la page de Mado, sans aller trop vite.

Support — Page de Mado, Cahier du chemin
Mado
Sous le figuier, la cour n'oublie pas les noms.
Qu'est-ce qui reste quand Sami se tait ? Cette ligne.
Qu'est-ce que je rature ? La peur d'être trop simple.
Avez-vous entendu Kévin sans qu'il parle ? Moi, oui.
Pourquoi lire ceci à voix haute ? Pour que Joël se reconnaisse.
Je le vous promettrais trop fort : je vous le promets, simplement.
Une page, pas trois. La meilleure n'est pas la plus longue.
Mado
Soirée lecture — Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado veut lire trois pages.",
  "correct": false,
  "explanation": "« Une page, pas trois. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que rature Mado ?",
  "options": [
    {
      "text": "les noms de la cour",
      "correct": false
    },
    {
      "text": "la peur d'être trop simple",
      "correct": true
    },
    {
      "text": "le tambour",
      "correct": false
    },
    {
      "text": "le figuier",
      "correct": false
    }
  ],
  "explanation": "« La peur d'être trop simple. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qu'est-ce qui reste",
      "right": "cette ligne"
    },
    {
      "left": "qu'est-ce que je rature",
      "right": "peur"
    },
    {
      "left": "avez-vous entendu",
      "right": "Kévin"
    },
    {
      "left": "pourquoi lire",
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
  "prompt": "Complétez :\nUne page, pas ___.",
  "answer": "trois"
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
    "n'oublie",
    "pas",
    "les",
    "noms",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "reconnait",
  "hint": "Joël se… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je le vous promets trop fort sous le figuier ce soir.",
  "correct_sentence": "Je vous le promets trop fort sous le figuier ce soir.",
  "explanation": "Vous avant le."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/danse-cour.svg",
      "word": "une danse"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/radio-culture.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/couverture-conte.svg",
      "word": "une couverture"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/masque-invente.svg",
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
  "prompt": "Imitez : une page courte, deux questions, un superlatif, un pronom double."
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
    'EL — Tenir une soirée lecture',
    'EL',
    $c$Objectif
Retenir le rituel du cercle et du Cahier du chemin.

Consigne
Apprenez la fiche.

Support — Fiche du cercle
Rituel : cercle, cahier au milieu, frappe, page, mot, frappe
Objets : Cahier du chemin, Lampe-Figue, seau de Kévin, tambour de Sami
Interdit : rumeur, cri, moquerie, enregistrement, couper la voix
Autorisé : ratures, silence, un mot après, rôle muet
Langue : qu'est-ce qui vous reste ? Avez-vous un doute ? Pourquoi relire ?
Je te les montre. Ne me le coupe pas. Je vous le promets.
La meilleure page n'est pas la plus longue.
On lit pour la cour, pas pour une une.
Radio Figuier peut attendre au matin.
Sous le figuier, une page suffit.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le cercle autorise la moquerie si elle est douce.",
  "correct": false,
  "explanation": "Moquerie interdite."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où pose-t-on le cahier ?",
  "options": [
    {
      "text": "au marché",
      "correct": false
    },
    {
      "text": "au milieu",
      "correct": true
    },
    {
      "text": "sous l'eau",
      "correct": false
    },
    {
      "text": "au Bureau seulement",
      "correct": false
    }
  ],
  "explanation": "Au milieu du cercle."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "frappe",
      "right": "ouvrir / fermer"
    },
    {
      "left": "page",
      "right": "une, pas trois"
    },
    {
      "left": "interdit",
      "right": "rumeur / cri"
    },
    {
      "left": "autorisé",
      "right": "ratures / silence"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa meilleure page n'est pas la plus ___.",
  "answer": "longue"
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
    "page",
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
  "word": "rituel",
  "hint": "Cercle, frappe, page, frappe : un…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On pose le cahier au marché et on enregistre pour rire.",
  "correct_sentence": "Le cahier est au milieu. Enregistrement interdit.",
  "explanation": "Le cercle protège la page."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/radio-culture.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/couverture-conte.svg",
      "word": "une couverture"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/masque-invente.svg",
      "word": "un masque"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/pupitre-aline.svg",
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
  "prompt": "Charte personnelle du cercle : 8 articles."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et le rituel complet."
}$j$::jsonb,
    9
  );

  -- ===== Inventer une saison =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Inventer une saison'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Inventer une saison', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Programmer les voix',
    'CO',
    $c$Objectif
Inventer et ordonner une saison culturelle au Seuil.

Consigne
Lisez le dialogue. Qui programme quoi ?

Support — Calendrier des voix, tissu de scène
Aline : D'abord, on nomme la saison : Saison des Voix.
Lila : Ensuite, on place la pièce le mercredi : « La cour n'oublie pas ».
Mado : Par ailleurs, le jeudi reste au cercle lecture.
Sami : En outre, le vendredi porte le tambour au Marché des Lampions.
Karim : En conclusion, on garde un samedi blanc : il se peut que l'eau monte.
Patrick : Qu'est-ce qui manque ? Une danse de la cour, légère.
Rose : C'est Dieudonné que je vois pour le tissu de scène.
Hawa : Je vous le promets : Radio Figuier lira le calendrier, pas une rumeur.
Joël : Avez-vous pensé à Yvette ? Une pause d'herbes entre deux soirs.
Solange : Je le leur afficherai, aux portes du Bureau.
Léa : Pourquoi programmer ainsi ? Pour que personne n'oublie personne.
Marc : Le moins attendu, ce sera le seau de Kévin, chaque ouverture.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le samedi est déjà plein de spectacles.",
  "correct": false,
  "explanation": "Karim : samedi blanc, l'eau peut monter."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel jour la pièce est-elle placée ?",
  "options": [
    {
      "text": "jeudi",
      "correct": false
    },
    {
      "text": "vendredi",
      "correct": false
    },
    {
      "text": "mercredi",
      "correct": true
    },
    {
      "text": "samedi",
      "correct": false
    }
  ],
  "explanation": "Lila : mercredi."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "mercredi",
      "right": "pièce"
    },
    {
      "left": "jeudi",
      "right": "cercle"
    },
    {
      "left": "vendredi",
      "right": "tambour / marché"
    },
    {
      "left": "samedi",
      "right": "blanc / eau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nD'abord, on ___ la saison : Saison des Voix.",
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
    "On",
    "garde",
    "un",
    "samedi",
    "blanc",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "programmer",
  "hint": "Ordonner les soirs : … une saison."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "D'abord on place la pièce, ensuite on nomme la saison trop tard.",
  "correct_sentence": "D'abord, on nomme la saison : Saison des Voix. Ensuite, on place la pièce.",
  "explanation": "Nommer, puis placer."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/couverture-conte.svg",
      "word": "une couverture"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/masque-invente.svg",
      "word": "un masque"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/pupitre-aline.svg",
      "word": "un pupitre"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/figuier-theatre.svg",
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
  "prompt": "Dessinez la semaine : quatre soirs, un blanc, une raison."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez le calendrier : mercredi pièce, jeudi cercle, vendredi marché, samedi blanc."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Calendrier des Voix',
    'CE',
    $c$Objectif
Lire un programme de saison inventé par la cour.

Consigne
Lisez le calendrier, sans aller trop vite.

Support — Feuille saison, Bureau des Escales
Saison des Voix — calendrier
Mercredi — Salle des Herbes — 18 h
« La cour n'oublie pas », le spectacle le plus émouvant, vingt minutes.
Jeudi — figuier — 17 h
Cercle lecture, Cahier du chemin, Lampe-Figue. Une page, pas trois.
Vendredi — Marché des Lampions — 18 h
Tambour de Sami, page de Mado, coupon de Dieudonné.
Samedi — blanc : il se peut que la rive demande les bras.
Dimanche — Table des Sources : relecture à voix basse. Avez-vous noté les prénoms oubliés ?
Interdit : titre d'ailleurs, salle lointaine, une payante.
Autorisé : seau de Kévin, silence, droit de ne pas lire.
Signé : Aline, Lila, Mado, Sami, Solange — Rukiri-Nord
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le dimanche, on joue la pièce une seconde fois en courant.",
  "correct": false,
  "explanation": "Relecture à voix basse."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait-on le samedi, selon le calendrier ?",
  "options": [
    {
      "text": "on joue deux pièces",
      "correct": false
    },
    {
      "text": "on le garde blanc",
      "correct": true
    },
    {
      "text": "on enregistre",
      "correct": false
    },
    {
      "text": "on vend des titres d'ailleurs",
      "correct": false
    }
  ],
  "explanation": "Samedi — blanc."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "mercredi",
      "right": "pièce"
    },
    {
      "left": "jeudi",
      "right": "cercle"
    },
    {
      "left": "vendredi",
      "right": "marché"
    },
    {
      "left": "dimanche",
      "right": "prénoms / voix basse"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSamedi — ___.",
  "answer": "blanc"
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
    "page",
    "pas",
    "trois",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "calendrier",
  "hint": "La feuille qui range les soirs de la saison."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Interdit : seau de Kévin. Autorisé : titre d'ailleurs et salle lointaine.",
  "correct_sentence": "Interdit : titre d'ailleurs, salle lointaine, une payante. Autorisé : seau de Kévin, silence.",
  "explanation": "La saison reste au Seuil."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/masque-invente.svg",
      "word": "un masque"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/pupitre-aline.svg",
      "word": "un pupitre"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/figuier-theatre.svg",
      "word": "un théâtre"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/soleil-saison.svg",
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
  "prompt": "Recopiez le calendrier et inventez un lundi de clôture."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le calendrier, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Présenter la saison',
    'PO',
    $c$Objectif
Présenter oralement un programme culturel.

Consigne
Répétez, puis présentez votre semaine de voix.

Support — Modèles de Lila
Voici la Saison des Voix.
Ce qui ouvre, c'est la pièce de mercredi.
C'est le cercle que nous plaçons le jeudi.
Ce que le vendredi porte, c'est le tambour au marché.
Pourquoi garder le samedi blanc ? À cause de la rive.
Avez-vous une danse à proposer ? Dites-le-nous.
Je vous le lis, le calendrier, une fois.
Ne me le faites pas crier. C'est une saison, pas une rumeur.
La meilleure soirée sera celle où Kévin tiendra le seau.
Le moins attendu sera un silence juste.
Nous demandons votre oreille, pas votre argent.
Merci à la cour.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila demande de l'argent à l'entrée.",
  "correct": false,
  "explanation": "« votre oreille, pas votre argent. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que porte le vendredi, selon Lila ?",
  "options": [
    {
      "text": "un tampon",
      "correct": false
    },
    {
      "text": "le tambour au marché",
      "correct": true
    },
    {
      "text": "une crue",
      "correct": false
    },
    {
      "text": "un examen",
      "correct": false
    }
  ],
  "explanation": "« le tambour au marché. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ce qui ouvre",
      "right": "pièce"
    },
    {
      "left": "c'est le cercle que",
      "right": "jeudi"
    },
    {
      "left": "samedi blanc",
      "right": "rive"
    },
    {
      "left": "oreille / pas argent",
      "right": "éthique"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous demandons votre ___, pas votre argent.",
  "answer": "oreille"
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
    "la",
    "Saison",
    "des",
    "Voix",
    "."
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
  "hint": "Une danse : Avez-vous une danse à… ?"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous demandons votre argent, pas votre oreille, dès l'affiche.",
  "correct_sentence": "Nous demandons votre oreille, pas votre argent.",
  "explanation": "Saison gratuite de la cour."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/pupitre-aline.svg",
      "word": "un pupitre"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/figuier-theatre.svg",
      "word": "un théâtre"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/soleil-saison.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/superlatif-critique.svg",
      "word": "un superlatif"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez une présentation orale de dix phrases."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les modèles, puis votre présentation de saison."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma saison écrite',
    'PE',
    $c$Objectif
Écrire le programme d'une saison culturelle inventée.

Consigne
Imitez le programme de Karim, sans aller trop vite.

Support — Programme de Karim
Karim
Saison des Voix — ma proposition
D'abord, mercredi : « La cour n'oublie pas », le plus émouvant.
Ensuite, jeudi : cercle, Cahier du chemin, une page.
Par ailleurs, vendredi : Sami au marché, Mado, Dieudonné.
En outre, samedi blanc : il se peut que l'eau monte.
En conclusion, dimanche : qu'est-ce qui a manqué ? On le note.
Avez-vous mieux ? Dites-le-moi. Je vous les copie, les heures.
Je ne prends aucun titre d'ailleurs. Je reste au Seuil.
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
  "statement": "Karim prend un titre d'ailleurs pour le mercredi.",
  "correct": false,
  "explanation": "« Je ne prends aucun titre d'ailleurs. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fait Karim si quelqu'un a mieux ?",
  "options": [
    {
      "text": "il refuse",
      "correct": false
    },
    {
      "text": "il copie les heures pour la personne",
      "correct": true
    },
    {
      "text": "il ferme la saison",
      "correct": false
    },
    {
      "text": "il part",
      "correct": false
    }
  ],
  "explanation": "« Dites-le-moi. Je vous les copie, les heures. »"
}$j$::jsonb,
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
      "right": "pièce"
    },
    {
      "left": "ensuite",
      "right": "cercle"
    },
    {
      "left": "par ailleurs",
      "right": "marché"
    },
    {
      "left": "en conclusion",
      "right": "dimanche / manqué"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDites-le-moi. Je vous ___ copie, les heures.",
  "answer": "les"
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
    "reste",
    "au",
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
  "word": "proposition",
  "hint": "Karim l'écrit : sa… de saison."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dites-moi-le. Je les vous copie, les heures, trop vite.",
  "correct_sentence": "Dites-le-moi. Je vous les copie, les heures.",
  "explanation": "Impératif : dis-le-moi. Vous avant les."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/figuier-theatre.svg",
      "word": "un théâtre"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/soleil-saison.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/superlatif-critique.svg",
      "word": "un superlatif"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/affiche-spectacle.svg",
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
  "prompt": "Imitez : cinq marches, une question, un double pronom, un refus d'ailleurs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre programme, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Inventer une saison',
    'EL',
    $c$Objectif
Retenir comment programmer la Saison des Voix.

Consigne
Apprenez la fiche.

Support — Fiche de saison
Nommer : Saison des Voix — un nom du Seuil, pas d'ailleurs.
Placer : d'abord / ensuite / par ailleurs / en outre / en conclusion
Œuvres : « La cour n'oublie pas » ; « Le figuier n'oublie pas » ; Cahier du chemin
Gestes : pièce, cercle, tambour, tissu, seau, silence
Questions : qu'est-ce qui manque ? Avez-vous mieux ? Pourquoi ce jour-là ?
Pronoms : dites-le-moi. Je vous les copie. Nous demandons votre oreille.
Superlatif : le plus émouvant, la meilleure soirée, le moins attendu
Interdit : titre lointain, salle lointaine, une payante, rumeur de salle pleine
Un samedi blanc est une politesse faite à la rive.
La saison sert la cour, pas l'inverse.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Un samedi blanc est un oubli honteux.",
  "correct": false,
  "explanation": "C'est une politesse faite à la rive."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel nom de saison est celui du Seuil ?",
  "options": [
    {
      "text": "un nom d'ailleurs",
      "correct": false
    },
    {
      "text": "Saison des Voix",
      "correct": true
    },
    {
      "text": "un titre payant",
      "correct": false
    },
    {
      "text": "une rumeur",
      "correct": false
    }
  ],
  "explanation": "Saison des Voix."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "nommer",
      "right": "Saison des Voix"
    },
    {
      "left": "placer",
      "right": "marches"
    },
    {
      "left": "samedi blanc",
      "right": "rive"
    },
    {
      "left": "oreille",
      "right": "pas d'argent"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa saison sert la ___, pas l'inverse.",
  "answer": "cour"
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
    "sert",
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
  "word": "politesse",
  "hint": "Le samedi blanc : une… faite à la rive."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Un samedi blanc est une politesse fait à la rive.",
  "correct_sentence": "Un samedi blanc est une politesse faite à la rive.",
  "explanation": "Politesse : participe féminin faite."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m8/soleil-saison.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/superlatif-critique.svg",
      "word": "un superlatif"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/affiche-spectacle.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-b1-m8/oeuvre-enthousiasme.svg",
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
  "prompt": "Rédigez la charte de votre saison : 8 articles, 4 soirs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et votre calendrier parlé."
}$j$::jsonb,
    9
  );

END;
$$;
