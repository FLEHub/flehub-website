/*
  Seed eLearning MFK — Module 3 A1 « S'orienter et s'installer »

  Cour d'accueil inventée « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a1-m3/
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
  v_module_title text := 'A1 — S''orienter et s''installer';
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
      'Seed A1 Module 3 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed Module 3 : enseignant % (%)', v_teacher_email, v_teacher_id;

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
      'Grande étape 3 : se repérer dans un quartier inventé (Rukiri-Nord), suivre un guide, prendre le minibus du week-end, demander son chemin, trouver une chambre et lire la route — cour d''accueil « Le Seuil des Sources ».',
      'A1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape 3 : se repérer dans un quartier inventé (Rukiri-Nord), suivre un guide, prendre le minibus du week-end, demander son chemin, trouver une chambre et lire la route — cour d''accueil « Le Seuil des Sources ».',
      cefr_level = 'A1',
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Explorer une nouvelle ville =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Explorer une nouvelle ville'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Explorer une nouvelle ville', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La carte peinte sous le figuier',
    'CO',
    $c$Objectif
Comprendre un premier repérage : c'est, il y a, où est, près de, en face de.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Quels lieux Aline montre-t-elle ? Qu'est-ce qui est près du Seuil ?

Support — Sous le figuier, cour « Le Seuil des Sources » (Rukiri-Nord)
Aline : Bienvenue, Léa. C'est la cour du Seuil. Il y a une carte sur le mur.
Léa : Merci. Où est le marché ?
Aline : Le marché « Les Trois Paniers », c'est près d'ici. Tout droit, puis à gauche.
Léa : Et la pharmacie ?
Aline : La pharmacie « Feuille Verte » est en face du parc. Ce n'est pas loin.
Léa : Il y a une banque ?
Aline : Oui. La Caisse du Figuier est à côté de la fontaine.
Léa : Parfait. Je regarde la carte.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline montre une carte sur le mur de la cour.",
  "correct": true,
  "explanation": "Aline dit : « Il y a une carte sur le mur. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où est le marché « Les Trois Paniers » ?",
  "options": [
    {
      "text": "Loin de l'aéroport",
      "correct": false
    },
    {
      "text": "Près du Seuil",
      "correct": true
    },
    {
      "text": "Derrière la banque",
      "correct": false
    },
    {
      "text": "Dans le bus",
      "correct": false
    }
  ],
  "explanation": "Aline : « C'est près d'ici. »"
}$j$::jsonb,
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
      "right": "présenter un lieu"
    },
    {
      "left": "il y a",
      "right": "signaler une chose"
    },
    {
      "left": "près de",
      "right": "pas loin"
    },
    {
      "left": "en face de",
      "right": "de l'autre côté"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa pharmacie est ___ face du parc.",
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
    "Où",
    "est",
    "le",
    "marché",
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
  "word": "carte",
  "hint": "Elle est peinte sur le mur de la cour."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il a une banque à côté de la fontaine.",
  "correct_sentence": "Il y a une banque à côté de la fontaine.",
  "explanation": "On dit « il y a » pour signaler un lieu, pas « il a »."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/carte.svg",
      "word": "la carte"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/pharmacie.svg",
      "word": "la pharmacie"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/fontaine.svg",
      "word": "la fontaine"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez trois lieux entendus. Écrivez une phrase avec « près de » et une phrase avec « en face de »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : C'est la cour du Seuil. Où est le marché ? C'est près d'ici. La pharmacie est en face du parc."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le plan glissé sous la porte',
    'CE',
    $c$Objectif
Lire un petit plan de quartier : c'est, il y a, près de, loin de, à côté de.

Consigne
Lisez le papier glissé sous la porte du Seuil, puis répondez.

Support — Plan du Seuil (encre brune, papier crème)
Rukiri-Nord — cour Le Seuil des Sources
C'est notre mur-carte.
Il y a :
1. le marché Les Trois Paniers — près de la cour
2. le parc Jardin des Sources — en face de la pharmacie
3. la pharmacie Feuille Verte — à côté de la rue des Mimosas
4. la Caisse du Figuier — loin du pont des Herbes
Bienvenue.
Aline Uwase
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le pont des Herbes est près de la Caisse du Figuier.",
  "correct": false,
  "explanation": "Le texte dit : la Caisse est loin du pont."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qu'est-ce qui est près de la cour ?",
  "options": [
    {
      "text": "Le pont des Herbes",
      "correct": false
    },
    {
      "text": "Le marché Les Trois Paniers",
      "correct": true
    },
    {
      "text": "L'aéroport",
      "correct": false
    },
    {
      "text": "La plage",
      "correct": false
    }
  ],
  "explanation": "Le plan : « le marché… — près de la cour »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "marché",
      "right": "près de la cour"
    },
    {
      "left": "parc",
      "right": "en face de la pharmacie"
    },
    {
      "left": "pharmacie",
      "right": "à côté de la rue des Mimosas"
    },
    {
      "left": "banque",
      "right": "loin du pont"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl ___ un marché près de la cour.",
  "answer": "y a"
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
    "notre",
    "mur-carte",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "marché",
  "hint": "On y trouve des paniers, près de la cour."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La pharmacie est a côté de la rue.",
  "correct_sentence": "La pharmacie est à côté de la rue.",
  "explanation": "La préposition s'écrit « à » (accent)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/parc.svg",
      "word": "le parc"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/pharmacie.svg",
      "word": "la pharmacie"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/banque.svg",
      "word": "la banque"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la liste des quatre lieux. Ajoutez « près » ou « loin » pour chacun, d'après le plan."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez à voix haute le plan, de « Rukiri-Nord » jusqu'à la signature d'Aline."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire où c''est',
    'PO',
    $c$Objectif
Dire où se trouve un lieu : c'est, il y a, près de, loin de, à côté de, en face de.

Consigne
Répétez les modèles, puis changez le lieu.

Support — Phrases d'Aline, sous le figuier
C'est le marché.
Il y a une pharmacie.
Où est la banque ?
C'est près de la cour.
C'est loin du pont.
C'est à côté de la fontaine.
C'est en face du parc.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« C'est loin du pont » veut dire : le pont n'est pas près.",
  "correct": true,
  "explanation": "Loin = pas près."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle question pose-t-on pour un lieu ?",
  "options": [
    {
      "text": "Qui est-ce ?",
      "correct": false
    },
    {
      "text": "Où est la banque ?",
      "correct": true
    },
    {
      "text": "Combien ça coûte ?",
      "correct": false
    },
    {
      "text": "Quel âge as-tu ?",
      "correct": false
    }
  ],
  "explanation": "Pour un lieu, on demande « Où est… ? »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "près de",
      "right": "proche"
    },
    {
      "left": "loin de",
      "right": "pas proche"
    },
    {
      "left": "à côté de",
      "right": "juste à côté"
    },
    {
      "left": "en face de",
      "right": "vis-à-vis"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ est la fontaine ?",
  "answer": "Où"
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
    "près",
    "de",
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
  "word": "fontaine",
  "hint": "Elle est dans la cour, à côté de la banque."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est près de le pont.",
  "correct_sentence": "C'est près du pont.",
  "explanation": "De + le → du."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/fontaine.svg",
      "word": "la fontaine"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/parc.svg",
      "word": "le parc"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/banque.svg",
      "word": "la banque"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/pont.svg",
      "word": "le pont"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez quatre phrases : c'est / il y a / près de / en face de. Utilisez les lieux du Seuil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les sept phrases modèles, lentement, en regardant la carte."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Quatre phrases pour Léa',
    'PE',
    $c$Objectif
Écrire un mini-repérage avec c'est, il y a et une préposition de lieu.

Consigne
Observez le modèle, puis écrivez quatre phrases pour aider Léa.

Support — Modèle d'Aline (carnet crème)
Léa,
C'est Rukiri-Nord.
Il y a un marché près de la cour.
La pharmacie est en face du parc.
La banque est à côté de la fontaine.
Aline
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le modèle commence par « C'est Rukiri-Nord. »",
  "correct": true,
  "explanation": "Première phrase du carnet."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de phrases Aline écrit-elle après le prénom ?",
  "options": [
    {
      "text": "Deux",
      "correct": false
    },
    {
      "text": "Trois",
      "correct": false
    },
    {
      "text": "Quatre",
      "correct": true
    },
    {
      "text": "Six",
      "correct": false
    }
  ],
  "explanation": "Quatre phrases : c'est / il y a / pharmacie / banque."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "C'est Rukiri-Nord.",
      "right": "présenter le quartier"
    },
    {
      "left": "Il y a un marché",
      "right": "signaler un lieu"
    },
    {
      "left": "en face du parc",
      "right": "vis-à-vis"
    },
    {
      "left": "à côté de la fontaine",
      "right": "juste à côté"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl y a un marché près ___ la cour.",
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
    "banque",
    "est",
    "à",
    "côté",
    "de",
    "la",
    "fontaine",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "quartier",
  "hint": "Rukiri-Nord est un… inventé autour du Seuil."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il y a une marché près de la cour.",
  "correct_sentence": "Il y a un marché près de la cour.",
  "explanation": "Marché est masculin : un marché."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/rue.svg",
      "word": "la rue"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/pharmacie.svg",
      "word": "la pharmacie"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/figuier.svg",
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
  "prompt": "Écrivez quatre phrases pour Léa : 1) C'est… 2) Il y a… 3) … est en face de… 4) … est à côté de…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre texte à voix haute, comme un message pour Léa."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — C''est, il y a, près et loin',
    'EL',
    $c$Objectif
Retenir c'est / il y a et les prépositions de lieu A1.

Consigne
Lisez la fiche, puis faites les exercices.

Support — Fiche du Seuil (point de langue)
C'est + un lieu : C'est le marché.
Il y a + un lieu : Il y a une pharmacie.
Où est + le / la + lieu ?
près de / loin de
à côté de / en face de
de + le → du : près du pont
Attention : on ne dit pas « il a une banque » pour un lieu.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « il y a une pharmacie » pour signaler un lieu.",
  "correct": true,
  "explanation": "Il y a = présence d'un lieu."
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
      "text": "C'est près de le parc",
      "correct": false
    },
    {
      "text": "C'est près du parc",
      "correct": true
    },
    {
      "text": "C'est près de les parc",
      "correct": false
    },
    {
      "text": "C'est près le parc",
      "correct": false
    }
  ],
  "explanation": "De + le → du."
}$j$::jsonb,
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
      "right": "identification"
    },
    {
      "left": "il y a",
      "right": "présence"
    },
    {
      "left": "où est",
      "right": "question de lieu"
    },
    {
      "left": "du",
      "right": "de + le"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est près ___ parc.",
  "answer": "du"
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
    "y",
    "a",
    "une",
    "pharmacie",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "près",
  "hint": "Le contraire de loin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Où es le marché ?",
  "correct_sentence": "Où est le marché ?",
  "explanation": "Le verbe être à la 3e personne : est."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/carte.svg",
      "word": "la carte"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/parc.svg",
      "word": "le parc"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/pont.svg",
      "word": "le pont"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la fiche. Ajoutez deux exemples personnels avec « à côté de » et « loin de »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Épelez et dites : c'est — il y a — où est — près de — loin de — à côté de — en face de."
}$j$::jsonb,
    9
  );

  -- ===== Suivre un guide =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Suivre un guide'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Suivre un guide', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Patrick mène jusqu''aux paniers',
    'CO',
    $c$Objectif
Comprendre un itinéraire à l'impératif : allez, tournez, prenez, continuez, à gauche, à droite, tout droit.

Consigne
Suivez la voix de Patrick. Dans quel ordre vient chaque direction ?

Support — Rue des Mimosas, vers le marché
Patrick : Vous êtes prête, Léa ? Allez tout droit jusqu'au figuier.
Léa : Oui. Ensuite ?
Patrick : Tournez à gauche. Prenez la petite rue.
Léa : Celle avec la peinture orange ?
Patrick : Oui. Continuez jusqu'au deuxième arbre. Puis tournez à droite.
Léa : Et le marché ?
Patrick : C'est là. Les Trois Paniers. Bravo.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick dit d'abord : « Allez tout droit. »",
  "correct": true,
  "explanation": "Première consigne, jusqu'au figuier."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Après le figuier, Léa doit…",
  "options": [
    {
      "text": "Tourner à gauche",
      "correct": true
    },
    {
      "text": "Prendre le bus",
      "correct": false
    },
    {
      "text": "S'arrêter tout de suite",
      "correct": false
    },
    {
      "text": "Revenir au Seuil",
      "correct": false
    }
  ],
  "explanation": "Patrick : « Tournez à gauche. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Allez",
      "right": "marcher"
    },
    {
      "left": "Tournez",
      "right": "changer de direction"
    },
    {
      "left": "Prenez",
      "right": "choisir une rue"
    },
    {
      "left": "Continuez",
      "right": "ne pas s'arrêter"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAllez tout ___.",
  "answer": "droit"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Tournez",
    "à",
    "gauche",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "gauche",
  "hint": "Patrick dit de tourner de ce côté après le figuier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Tournez à le gauche.",
  "correct_sentence": "Tournez à gauche.",
  "explanation": "On dit « à gauche », sans article."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/guide.svg",
      "word": "le guide"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/tout-droit.svg",
      "word": "tout droit"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/gauche.svg",
      "word": "à gauche"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/droite.svg",
      "word": "à droite"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez l'itinéraire en quatre verbes : allez / tournez / prenez / continuez."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez l'itinéraire : Allez tout droit. Tournez à gauche. Prenez la petite rue. Continuez. Tournez à droite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Les flèches sur le papier plié',
    'CE',
    $c$Objectif
Lire un itinéraire écrit avec l'impératif et les directions.

Consigne
Lisez le papier que Patrick glisse dans la poche de Léa.

Support — Papier plié (flèches au crayon)
Pour Léa — marché Les Trois Paniers
1. Allez tout droit jusqu'au figuier.
2. Tournez à gauche.
3. Prenez la rue orange.
4. Continuez jusqu'au deuxième arbre.
5. Tournez à droite.
C'est le marché.
Patrick Habimana
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La rue orange vient après « tournez à gauche ».",
  "correct": true,
  "explanation": "Étape 3, après l'étape 2."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Jusqu'où Léa continue-t-elle ?",
  "options": [
    {
      "text": "Jusqu'au pont",
      "correct": false
    },
    {
      "text": "Jusqu'au deuxième arbre",
      "correct": true
    },
    {
      "text": "Jusqu'à la banque",
      "correct": false
    },
    {
      "text": "Jusqu'au Seuil",
      "correct": false
    }
  ],
  "explanation": "Le papier : « Continuez jusqu'au deuxième arbre. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "1",
      "right": "tout droit"
    },
    {
      "left": "2",
      "right": "à gauche"
    },
    {
      "left": "5",
      "right": "à droite"
    },
    {
      "left": "marché",
      "right": "arrivée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPrenez la rue ___.",
  "answer": "orange"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Allez",
    "tout",
    "droit",
    "jusqu'au",
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
  "word": "droite",
  "hint": "Dernière flèche avant le marché."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Continuez jusqu'a le deuxième arbre.",
  "correct_sentence": "Continuez jusqu'au deuxième arbre.",
  "explanation": "Jusqu'à + le → jusqu'au."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/figuier.svg",
      "word": "le figuier"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/rue.svg",
      "word": "la rue"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/affiche.svg",
      "word": "l'affiche"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez les cinq étapes. Soulignez les verbes à l'impératif."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le papier de Patrick, numéro par numéro, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Donner le chemin',
    'PO',
    $c$Objectif
Donner un chemin court à l'impératif (vous).

Consigne
Répétez, puis guidez un camarade jusqu'à la fontaine.

Support — Modèles de Patrick
Allez tout droit.
Tournez à gauche.
Tournez à droite.
Prenez la deuxième rue.
Continuez jusqu'à la fontaine.
Arrêtez-vous ici.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Arrêtez-vous ici » est un impératif avec vous.",
  "correct": true,
  "explanation": "Arrêtez-vous = vous, avec un trait d'union."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel verbe manque : « ___ la deuxième rue. » ?",
  "options": [
    {
      "text": "Mangez",
      "correct": false
    },
    {
      "text": "Prenez",
      "correct": true
    },
    {
      "text": "Dormez",
      "correct": false
    },
    {
      "text": "Chantez",
      "correct": false
    }
  ],
  "explanation": "Pour une rue, on dit « Prenez… »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "tout droit",
      "right": "devant soi"
    },
    {
      "left": "à gauche",
      "right": "côté gauche"
    },
    {
      "left": "à droite",
      "right": "côté droit"
    },
    {
      "left": "jusqu'à",
      "right": "limite"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nTournez à ___.",
  "answer": "gauche"
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
    "la",
    "deuxième",
    "rue",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tournez",
  "hint": "Verbe pour changer de direction."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Allez toute droite.",
  "correct_sentence": "Allez tout droit.",
  "explanation": "L'adverbe s'écrit « tout droit » (sans e à tout, sans e à droit)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/tout-droit.svg",
      "word": "tout droit"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/gauche.svg",
      "word": "à gauche"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/droite.svg",
      "word": "à droite"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/fontaine.svg",
      "word": "la fontaine"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un chemin de cinq phrases pour aller du Seuil à la fontaine."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six phrases modèles, puis votre chemin personnel."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Un itinéraire pour Hawa',
    'PE',
    $c$Objectif
Écrire un itinéraire clair avec l'impératif et les directions.

Consigne
Aidez Hawa à rejoindre le Jardin des Sources. Imitez le modèle.

Support — Modèle (verso du papier plié)
Hawa,
Allez tout droit jusqu'à la porte du Seuil.
Tournez à droite.
Prenez la rue des Mimosas.
Continuez jusqu'au parc.
C'est le Jardin des Sources.
Patrick
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le modèle s'adresse à Hawa.",
  "correct": true,
  "explanation": "Première ligne : « Hawa, »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle est la dernière phrase avant la signature ?",
  "options": [
    {
      "text": "C'est le Jardin des Sources.",
      "correct": true
    },
    {
      "text": "C'est le marché.",
      "correct": false
    },
    {
      "text": "C'est la banque.",
      "correct": false
    },
    {
      "text": "C'est loin.",
      "correct": false
    }
  ],
  "explanation": "Le texte se termine par le nom du parc."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Allez",
      "right": "partir en avant"
    },
    {
      "left": "Tournez",
      "right": "changer de côté"
    },
    {
      "left": "Prenez",
      "right": "choisir la rue"
    },
    {
      "left": "Continuez",
      "right": "garder la direction"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPrenez la rue ___ Mimosas.",
  "answer": "des"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Tournez",
    "à",
    "droite",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "mimosas",
  "hint": "Nom de la rue près du Seuil."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Allez tout droit jusqu'à le porte.",
  "correct_sentence": "Allez tout droit jusqu'à la porte.",
  "explanation": "Porte est féminin : la porte."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/porte.svg",
      "word": "la porte"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/rue.svg",
      "word": "la rue"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/parc.svg",
      "word": "le parc"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/guide.svg",
      "word": "le guide"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un itinéraire de cinq lignes pour Hawa : allez / tournez / prenez / continuez / c'est…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre itinéraire comme Patrick : lentement, une phrase, une pause."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Impératif et flèches',
    'EL',
    $c$Objectif
Retenir l'impératif de politesse et les mots de direction.

Consigne
Apprenez la fiche, puis entraînez-vous.

Support — Fiche de Patrick
Pour guider (vous) :
allez — tournez — prenez — continuez — arrêtez-vous
à gauche / à droite / tout droit
le premier / le deuxième
jusqu'à + le → jusqu'au
jusqu'à + la → jusqu'à la
On ne dit pas « tournez à le gauche ».
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Arrêtez-vous » prend un trait d'union.",
  "correct": true,
  "explanation": "Impératif + vous : arrêtez-vous."
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
      "text": "Tournez à le droite",
      "correct": false
    },
    {
      "text": "Tournez à droite",
      "correct": true
    },
    {
      "text": "Tournez de droite",
      "correct": false
    },
    {
      "text": "Tournez le droite",
      "correct": false
    }
  ],
  "explanation": "À gauche / à droite, sans article."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "allez",
      "right": "marcher en avant"
    },
    {
      "left": "tournez",
      "right": "changer de côté"
    },
    {
      "left": "prenez",
      "right": "choisir une voie"
    },
    {
      "left": "continuez",
      "right": "poursuivre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nContinuez jusqu'___ figuier.",
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
    "Arrêtez-vous",
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
  "word": "prenez",
  "hint": "Verbe pour choisir une rue."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Prenez le deuxième rues.",
  "correct_sentence": "Prenez la deuxième rue.",
  "explanation": "Rue est féminin : la deuxième rue."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/gauche.svg",
      "word": "à gauche"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/droite.svg",
      "word": "à droite"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/tout-droit.svg",
      "word": "tout droit"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/figuier.svg",
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
  "prompt": "Recopiez la fiche. Inventez deux phrases avec « le premier » et « le deuxième »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites la liste des verbes, puis : à gauche, à droite, tout droit, jusqu'au, jusqu'à la."
}$j$::jsonb,
    9
  );

  -- ===== Se déplacer en week-end =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Se déplacer en week-end'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Se déplacer en week-end', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le tableau de Marc, samedi matin',
    'CO',
    $c$Objectif
Comprendre un départ de week-end : le minibus, à + heure, aller à, samedi.

Consigne
Écoutez Marc devant le tableau. Qui part, à quelle heure, vers où ?

Support — Arrêt « Figuier 7 », samedi
Marc : Bonjour. C'est le minibus Figuier 7. On va au Jardin des Sources.
Léa : Bonjour. Vous partez à quelle heure ?
Marc : À huit heures, samedi. Pas le dimanche.
Hawa : Je viens du Seuil, à pied. Il y a de la place ?
Marc : Oui. Après le jardin, on va au pont des Herbes.
Léa : Je n'ai pas de vélo. Je prends le minibus.
Marc : Très bien. À samedi, à huit heures.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le minibus circule le dimanche.",
  "correct": false,
  "explanation": "Marc : « Pas le dimanche. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À quelle heure part le Figuier 7 ?",
  "options": [
    {
      "text": "À six heures",
      "correct": false
    },
    {
      "text": "À huit heures",
      "correct": true
    },
    {
      "text": "À midi",
      "correct": false
    },
    {
      "text": "À vingt heures",
      "correct": false
    }
  ],
  "explanation": "Marc répète : à huit heures, samedi."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "minibus",
      "right": "Figuier 7"
    },
    {
      "left": "à pied",
      "right": "depuis le Seuil"
    },
    {
      "left": "samedi",
      "right": "jour de départ"
    },
    {
      "left": "huit heures",
      "right": "heure"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn part ___ huit heures.",
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
    "Je",
    "prends",
    "le",
    "minibus",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "samedi",
  "hint": "Jour du départ, pas dimanche."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je vas au Jardin des Sources.",
  "correct_sentence": "Je vais au Jardin des Sources.",
  "explanation": "Je vais (aller). Pas « je vas »."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/minibus.svg",
      "word": "le minibus"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/arret.svg",
      "word": "l'arrêt"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/horloge.svg",
      "word": "l'heure"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/a-pied.svg",
      "word": "à pied"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez : le véhicule, le jour, l'heure, deux destinations."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : C'est le minibus Figuier 7. On part à huit heures, samedi. Je viens du Seuil à pied."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — La craie du week-end',
    'CE',
    $c$Objectif
Lire un tableau d'horaires simple : jours, heures, destinations.

Consigne
Lisez le tableau à la craie, puis répondez.

Support — Tableau de l'arrêt Figuier 7
Minibus Figuier 7 — week-end
Samedi
8 h 00 — Seuil → Jardin des Sources
8 h 20 — Jardin → Pont des Herbes
Retour 16 h 00 — Pont → Seuil
Dimanche : pas de minibus
À pied : 15 minutes jusqu'au jardin
Vélo : 8 minutes
Marc Nkurunziza
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le retour est à seize heures.",
  "correct": true,
  "explanation": "« Retour 16 h 00 — Pont → Seuil »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de minutes à pied jusqu'au jardin ?",
  "options": [
    {
      "text": "5",
      "correct": false
    },
    {
      "text": "8",
      "correct": false
    },
    {
      "text": "15",
      "correct": true
    },
    {
      "text": "60",
      "correct": false
    }
  ],
  "explanation": "Le tableau : « À pied : 15 minutes »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "8 h 00",
      "right": "vers le jardin"
    },
    {
      "left": "8 h 20",
      "right": "vers le pont"
    },
    {
      "left": "16 h 00",
      "right": "retour au Seuil"
    },
    {
      "left": "dimanche",
      "right": "pas de minibus"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDimanche : pas de ___.",
  "answer": "minibus"
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
    "vais",
    "au",
    "jardin",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "vélo",
  "hint": "Huit minutes, d'après le tableau."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je viens à le Seuil.",
  "correct_sentence": "Je viens du Seuil.",
  "explanation": "Venir de + le → du. On vient du Seuil."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/minibus.svg",
      "word": "le minibus"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/velo.svg",
      "word": "le vélo"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/a-pied.svg",
      "word": "à pied"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/horloge.svg",
      "word": "l'heure"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le tableau. Ajoutez une phrase : « Je vais à… à … heures. »"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le tableau à voix haute, ligne par ligne."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire comment on y va',
    'PO',
    $c$Objectif
Dire le moyen, le jour et l'heure : je vais à, je viens de, je prends, à pied.

Consigne
Répétez, puis parlez de votre samedi.

Support — Modèles de Marc
Je prends le minibus.
Je vais au jardin.
Je viens du Seuil.
Je vais à pied.
Je prends le vélo.
On part à huit heures.
Le dimanche, je reste ici.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je viens du Seuil » indique l'origine.",
  "correct": true,
  "explanation": "Venir de = d'où on arrive."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase dit le moyen de transport ?",
  "options": [
    {
      "text": "Je m'appelle Marc.",
      "correct": false
    },
    {
      "text": "Je prends le minibus.",
      "correct": true
    },
    {
      "text": "C'est samedi.",
      "correct": false
    },
    {
      "text": "Il y a une carte.",
      "correct": false
    }
  ],
  "explanation": "Prendre + le minibus / le vélo / le bus."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je vais à",
      "right": "destination"
    },
    {
      "left": "je viens de",
      "right": "origine"
    },
    {
      "left": "je prends",
      "right": "moyen"
    },
    {
      "left": "à huit heures",
      "right": "moment"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe vais ___ pied.",
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
    "On",
    "part",
    "à",
    "huit",
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
  "word": "minibus",
  "hint": "Le véhicule de Marc, le samedi."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je prends le vélo à pied.",
  "correct_sentence": "Je vais à pied.",
  "explanation": "À pied = sans véhicule. On ne « prend » pas le vélo à pied."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/bus.svg",
      "word": "le bus"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/minibus.svg",
      "word": "le minibus"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/velo.svg",
      "word": "le vélo"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/a-pied.svg",
      "word": "à pied"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez trois phrases : je prends / je vais à / je viens de. Indiquez un jour et une heure."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les sept phrases modèles, puis votre samedi à Rukiri-Nord."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mot à une amie, vendredi soir',
    'PE',
    $c$Objectif
Écrire un court message de déplacement : jour, heure, moyen, lieu.

Consigne
Imitez le mot de Léa. Changez l'heure ou le moyen.

Support — Mot de Léa (papier du Seuil)
Hawa,
Samedi, je prends le minibus.
Je vais au Jardin des Sources à huit heures.
Je viens du Seuil.
Tu viens à vélo ?
À demain.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa propose le samedi.",
  "correct": true,
  "explanation": "Première information : samedi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Léa demande à Hawa si elle vient…",
  "options": [
    {
      "text": "en avion",
      "correct": false
    },
    {
      "text": "à vélo",
      "correct": true
    },
    {
      "text": "en bateau",
      "correct": false
    },
    {
      "text": "à cheval",
      "correct": false
    }
  ],
  "explanation": "« Tu viens à vélo ? »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Samedi",
      "right": "jour"
    },
    {
      "left": "huit heures",
      "right": "heure"
    },
    {
      "left": "minibus",
      "right": "moyen"
    },
    {
      "left": "Jardin des Sources",
      "right": "lieu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe vais ___ Jardin des Sources.",
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
    "Tu",
    "viens",
    "à",
    "vélo",
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
  "word": "demain",
  "hint": "Léa écrit : à… (le jour d'après)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je vas au jardin à huit heures.",
  "correct_sentence": "Je vais au jardin à huit heures.",
  "explanation": "Aller : je vais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/minibus.svg",
      "word": "le minibus"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/velo.svg",
      "word": "le vélo"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/parc.svg",
      "word": "le parc"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/horloge.svg",
      "word": "l'heure"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un mot de cinq lignes à un camarade : jour, moyen, lieu, heure, une question."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot comme un message oral, clairement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Aller, venir, à + heure',
    'EL',
    $c$Objectif
Retenir aller à / venir de, les transports et à + heure.

Consigne
Étudiez la fiche du week-end.

Support — Fiche de Marc
Je vais à + lieu : je vais au jardin / à Rukiri-Nord
Je viens de + lieu : je viens du Seuil
Je prends le bus / le minibus / le vélo
Je vais à pied
à + heure : à huit heures
samedi / dimanche
aller : je vais, tu vas, il va, nous allons, vous allez, ils vont
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« À pied » s'écrit avec un accent sur le à.",
  "correct": true,
  "explanation": "à pied = préposition à."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle conjugaison est correcte ?",
  "options": [
    {
      "text": "je vas",
      "correct": false
    },
    {
      "text": "je vais",
      "correct": true
    },
    {
      "text": "je aller",
      "correct": false
    },
    {
      "text": "je va",
      "correct": false
    }
  ],
  "explanation": "Aller est irrégulier : je vais."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je vais",
      "right": "destination"
    },
    {
      "left": "je viens",
      "right": "origine"
    },
    {
      "left": "je prends",
      "right": "transport"
    },
    {
      "left": "à huit heures",
      "right": "horaire"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe viens ___ Seuil.",
  "answer": "du"
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
    "au",
    "pont",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "allons",
  "hint": "Nous… (verbe aller)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On part a huit heures.",
  "correct_sentence": "On part à huit heures.",
  "explanation": "La préposition de l'heure s'écrit « à »."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/bus.svg",
      "word": "le bus"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/minibus.svg",
      "word": "le minibus"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/velo.svg",
      "word": "le vélo"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/horloge.svg",
      "word": "l'heure"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Conjuguez « aller » au présent. Écrivez deux phrases : je vais à / je viens de."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites la conjugaison d'aller, puis : je prends le minibus à huit heures, samedi."
}$j$::jsonb,
    9
  );

  -- ===== Aller vers l'autre =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Aller vers l''autre'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Aller vers l''autre', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Léa interroge Hawa près de la fontaine',
    'CO',
    $c$Objectif
Comprendre une demande de chemin polie : excusez-moi, pour aller à, pouvez-vous, merci.

Consigne
Qui aide ? Quel lieu Léa cherche-t-elle ? C'est près ou loin ?

Support — Près de la fontaine du Seuil
Léa : Excusez-moi, madame. Pour aller à la pharmacie Feuille Verte ?
Hawa : Oui. Je peux vous aider. C'est près. Cinq minutes à pied.
Léa : Pouvez-vous répéter, s'il vous plaît ?
Hawa : Tout droit, puis en face du parc. Ce n'est pas loin.
Léa : Merci beaucoup.
Hawa : De rien. Bonne route.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa dit que la pharmacie est loin.",
  "correct": false,
  "explanation": "Hawa : « C'est près. Cinq minutes. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment Léa commence-t-elle ?",
  "options": [
    {
      "text": "Hé, toi !",
      "correct": false
    },
    {
      "text": "Excusez-moi, madame.",
      "correct": true
    },
    {
      "text": "Donnez la carte.",
      "correct": false
    },
    {
      "text": "C'est où ?",
      "correct": false
    }
  ],
  "explanation": "Formule de politesse : Excusez-moi, madame."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Excusez-moi",
      "right": "attirer l'attention"
    },
    {
      "left": "Pour aller à… ?",
      "right": "demander le chemin"
    },
    {
      "left": "Pouvez-vous",
      "right": "demander de l'aide"
    },
    {
      "left": "De rien",
      "right": "répondre à merci"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nMerci beaucoup. — ___ rien.",
  "answer": "De"
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
    "m'aider",
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
  "word": "merci",
  "hint": "Léa le dit à la fin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Excuse-moi, madame.",
  "correct_sentence": "Excusez-moi, madame.",
  "explanation": "Avec madame, on vouvoie : excusez-moi."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/fontaine.svg",
      "word": "la fontaine"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/pharmacie.svg",
      "word": "la pharmacie"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/a-pied.svg",
      "word": "à pied"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/parc.svg",
      "word": "le parc"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez les formules de politesse du dialogue (au moins quatre)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Excusez-moi, madame. Pour aller à la pharmacie ? Pouvez-vous m'aider ? Merci beaucoup. De rien."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Deux messages sur le papier du figuier',
    'CE',
    $c$Objectif
Lire un échange écrit pour demander et indiquer un chemin.

Consigne
Lisez les deux messages épinglés sur le figuier.

Support — Billets épinglés
Léa → Hawa
Excusez-moi. Pour aller à la Caisse du Figuier ?
Pouvez-vous m'aider ? Merci.

Hawa → Léa
Oui. C'est près de la fontaine.
Ce n'est pas loin. Cinq minutes.
De rien. À tout à l'heure.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa refuse d'aider Léa.",
  "correct": false,
  "explanation": "Hawa répond « Oui » et donne le chemin."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où est la Caisse du Figuier, d'après Hawa ?",
  "options": [
    {
      "text": "Loin du pont seulement",
      "correct": false
    },
    {
      "text": "Près de la fontaine",
      "correct": true
    },
    {
      "text": "Dans le minibus",
      "correct": false
    },
    {
      "text": "À l'aéroport",
      "correct": false
    }
  ],
  "explanation": "Hawa : « C'est près de la fontaine. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Pour aller à",
      "right": "question"
    },
    {
      "left": "près de",
      "right": "réponse de lieu"
    },
    {
      "left": "cinq minutes",
      "right": "durée"
    },
    {
      "left": "À tout à l'heure",
      "right": "plus tard"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCe n'est pas ___.",
  "answer": "loin"
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
    "près",
    "de",
    "la",
    "fontaine",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "aider",
  "hint": "Léa demande : pouvez-vous m'… ?"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Pouvez vous m'aider ?",
  "correct_sentence": "Pouvez-vous m'aider ?",
  "explanation": "Question avec vous : trait d'union."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/affiche.svg",
      "word": "l'affiche"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/banque.svg",
      "word": "la banque"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/fontaine.svg",
      "word": "la fontaine"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/figuier.svg",
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
  "prompt": "Recopiez l'échange. Ajoutez une question « Pour aller à… ? » vers un autre lieu."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les deux billets : d'abord Léa, puis Hawa."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Demander et remercier',
    'PO',
    $c$Objectif
Demander son chemin et remercier, au vouvoiement.

Consigne
Répétez les modèles. Changez le lieu.

Support — Modèles près de la fontaine
Excusez-moi, monsieur.
Excusez-moi, madame.
Pour aller au marché, s'il vous plaît ?
Pouvez-vous m'aider ?
C'est près ou loin ?
Merci beaucoup.
De rien.
Bonne route.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Bonne route » se dit après l'aide.",
  "correct": true,
  "explanation": "Formule de clôture, comme Hawa."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle question demande la distance ?",
  "options": [
    {
      "text": "Comment vous appelez-vous ?",
      "correct": false
    },
    {
      "text": "C'est près ou loin ?",
      "correct": true
    },
    {
      "text": "Quel jour sommes-nous ?",
      "correct": false
    },
    {
      "text": "Vous prenez le vélo ?",
      "correct": false
    }
  ],
  "explanation": "Près ou loin = distance simple."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Excusez-moi",
      "right": "politesse"
    },
    {
      "left": "s'il vous plaît",
      "right": "demande"
    },
    {
      "left": "Merci beaucoup",
      "right": "remerciement"
    },
    {
      "left": "De rien",
      "right": "réponse"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPour aller ___ marché ?",
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
    "C'est",
    "près",
    "ou",
    "loin",
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
  "word": "excusez",
  "hint": "Premier mot pour arrêter quelqu'un poliment (vous)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Merci beaucoup. — De rien pas.",
  "correct_sentence": "Merci beaucoup. — De rien.",
  "explanation": "La réponse courte est « De rien. »"
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/guide.svg",
      "word": "le guide"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/a-pied.svg",
      "word": "à pied"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/carte.svg",
      "word": "la carte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un mini-dialogue de six répliques : demander le pont des Herbes."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit phrases modèles, puis votre dialogue."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Un mot collé pour un inconnu',
    'PE',
    $c$Objectif
Écrire une demande de chemin courte et polie.

Consigne
Rédigez un mot à épingler près de la porte. Suivez le modèle de Léa.

Support — Modèle
Bonjour,
Excusez-moi.
Pour aller au pont des Herbes, s'il vous plaît ?
C'est près ou loin ?
Merci beaucoup.
Léa Niyonzima
Le Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa oublie de dire merci dans le modèle.",
  "correct": false,
  "explanation": "Le modèle contient « Merci beaucoup. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel lieu Léa cherche-t-elle dans le modèle ?",
  "options": [
    {
      "text": "La pharmacie",
      "correct": false
    },
    {
      "text": "Le pont des Herbes",
      "correct": true
    },
    {
      "text": "La Caisse",
      "correct": false
    },
    {
      "text": "Le minibus",
      "correct": false
    }
  ],
  "explanation": "« Pour aller au pont des Herbes »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Bonjour",
      "right": "ouverture"
    },
    {
      "left": "Excusez-moi",
      "right": "politesse"
    },
    {
      "left": "Pour aller à",
      "right": "objet"
    },
    {
      "left": "Merci beaucoup",
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
  "prompt": "Complétez :\nPour aller ___ pont des Herbes ?",
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
    "C'est",
    "près",
    "ou",
    "loin",
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
  "word": "beaucoup",
  "hint": "Merci…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Pour aller à le pont, s'il vous plaît ?",
  "correct_sentence": "Pour aller au pont, s'il vous plaît ?",
  "explanation": "À + le → au."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/porte.svg",
      "word": "la porte"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/pont.svg",
      "word": "le pont"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/affiche.svg",
      "word": "l'affiche"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/valise.svg",
      "word": "la valise"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez votre mot (six lignes) pour aller à la pharmacie ou au marché. Signez."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot à voix haute, comme si vous parliez à un inconnu."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Formules pour le chemin',
    'EL',
    $c$Objectif
Mémoriser les formules pour demander son chemin (A1, vouvoiement).

Consigne
Apprenez, puis variez le lieu.

Support — Fiche d'Hawa
Excusez-moi, monsieur / madame.
Pour aller à + lieu ?
Pour aller au + lieu masculin (au pont, au marché)
Pouvez-vous m'aider ?
s'il vous plaît
C'est près. / C'est loin. / Cinq minutes.
Merci beaucoup. — De rien.
Bonne route.
Attention : excusez-moi (vous), pas « excuse-moi » avec un inconnu.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Avec un inconnu, on dit « excusez-moi ».",
  "correct": true,
  "explanation": "Vouvoiement de politesse."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle question est complète ?",
  "options": [
    {
      "text": "Aller pharmacie ?",
      "correct": false
    },
    {
      "text": "Pour aller à la pharmacie, s'il vous plaît ?",
      "correct": true
    },
    {
      "text": "Pharmacie maintenant.",
      "correct": false
    },
    {
      "text": "Tu sais pharmacie ?",
      "correct": false
    }
  ],
  "explanation": "Pour aller à + lieu + s'il vous plaît."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "au marché",
      "right": "à + le"
    },
    {
      "left": "à la pharmacie",
      "right": "à + la"
    },
    {
      "left": "près",
      "right": "courte distance"
    },
    {
      "left": "loin",
      "right": "longue distance"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPouvez-___ m'aider ?",
  "answer": "vous"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Excusez-moi",
    "madame",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pouvez",
  "hint": "Verbe pouvoir, pour demander poliment."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Pour aller à la marché ?",
  "correct_sentence": "Pour aller au marché ?",
  "explanation": "Marché est masculin : au marché."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/pharmacie.svg",
      "word": "la pharmacie"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/marche.svg",
      "word": "le marché"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/pont.svg",
      "word": "le pont"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/guide.svg",
      "word": "le guide"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la fiche. Transformez « Pour aller à… » vers trois lieux du quartier."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites toutes les formules de la fiche, lentement."
}$j$::jsonb,
    9
  );

  -- ===== Trouver un toit =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Trouver un toit'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Trouver un toit', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Devant le tableau de liège',
    'CO',
    $c$Objectif
Comprendre une offre de chambre : il y a, c'est libre, le loyer, cuisine, douche.

Consigne
Écoutez Aline et Hawa. Qu'est-ce qu'il y a dans la chambre ? Quel est le loyer ?

Support — Tableau de liège, cour du Seuil
Hawa : Aline, je cherche un toit. Il y a une chambre ?
Aline : Oui. Maison Karekezi. C'est libre. Il y a un lit, une cuisine et une douche.
Hawa : Il n'y a pas de salon ?
Aline : Non, pas de salon. Mais c'est calme.
Hawa : Combien ça coûte ?
Aline : Le loyer est petit. La clé est ici, près de l'affiche.
Hawa : Merci. Je regarde.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La chambre de la maison Karekezi est occupée.",
  "correct": false,
  "explanation": "Aline : « C'est libre. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que n'y a-t-il pas ?",
  "options": [
    {
      "text": "Un lit",
      "correct": false
    },
    {
      "text": "Une cuisine",
      "correct": false
    },
    {
      "text": "Une douche",
      "correct": false
    },
    {
      "text": "Un salon",
      "correct": true
    }
  ],
  "explanation": "Aline : « Pas de salon. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "c'est libre",
      "right": "on peut prendre"
    },
    {
      "left": "c'est occupé",
      "right": "déjà pris"
    },
    {
      "left": "le loyer",
      "right": "le prix"
    },
    {
      "left": "la clé",
      "right": "pour ouvrir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCombien ça ___ ?",
  "answer": "coûte"
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
    "y",
    "a",
    "un",
    "lit",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "loyer",
  "hint": "Hawa demande le prix : le…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il n'a pas de salon.",
  "correct_sentence": "Il n'y a pas de salon.",
  "explanation": "Négation d'un lieu : il n'y a pas."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/chambre.svg",
      "word": "une chambre"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/lit.svg",
      "word": "un lit"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/cuisine.svg",
      "word": "une cuisine"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/cle.svg",
      "word": "la clé"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Listez ce qu'il y a et ce qu'il n'y a pas. Notez la question sur le prix."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je cherche un toit. C'est libre ? Il y a une douche ? Combien ça coûte ?"
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — L''annonce Maison Karekezi',
    'CE',
    $c$Objectif
Lire une annonce de chambre simple.

Consigne
Lisez l'annonce épinglée, puis répondez.

Support — Annonce (carton crème)
Chambre — Maison Karekezi
Rukiri-Nord, près du Seuil
C'est libre.
Il y a : un lit, une cuisine, une douche.
Il n'y a pas de salon.
Loyer : petit, à payer le samedi.
Clé au Seuil des Sources, chez Aline.
On peut venir voir aujourd'hui.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On paie le loyer le samedi.",
  "correct": true,
  "explanation": "L'annonce : « à payer le samedi »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où prend-on la clé ?",
  "options": [
    {
      "text": "Au pont des Herbes",
      "correct": false
    },
    {
      "text": "Au Seuil des Sources, chez Aline",
      "correct": true
    },
    {
      "text": "Dans le minibus",
      "correct": false
    },
    {
      "text": "À la banque",
      "correct": false
    }
  ],
  "explanation": "« Clé au Seuil des Sources, chez Aline. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "libre",
      "right": "disponible"
    },
    {
      "left": "lit",
      "right": "pour dormir"
    },
    {
      "left": "douche",
      "right": "pour se laver"
    },
    {
      "left": "loyer",
      "right": "à payer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl n'y a pas ___ salon.",
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
    "C'est",
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
  "word": "chambre",
  "hint": "Ce que Hawa cherche."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il y a une lit et une cuisine.",
  "correct_sentence": "Il y a un lit et une cuisine.",
  "explanation": "Lit est masculin : un lit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/toit.svg",
      "word": "un toit"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/chambre.svg",
      "word": "une chambre"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/douche.svg",
      "word": "une douche"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/loyer.svg",
      "word": "le loyer"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez l'annonce en trois phrases : lieu / il y a / loyer."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'annonce complète, lentement, comme Aline au tableau."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Parler d''une chambre',
    'PO',
    $c$Objectif
Poser des questions sur un logement et décrire une chambre.

Consigne
Répétez, puis jouez Aline / Hawa.

Support — Modèles au tableau de liège
Je cherche une chambre.
C'est libre ou occupé ?
Il y a une cuisine ?
Il y a une douche ?
Il n'y a pas de salon.
Combien ça coûte ?
Le loyer est petit.
Voici la clé.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Voici la clé » sert à donner la clé.",
  "correct": true,
  "explanation": "Voici = présentation de l'objet."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle question porte sur le prix ?",
  "options": [
    {
      "text": "C'est loin ?",
      "correct": false
    },
    {
      "text": "Combien ça coûte ?",
      "correct": true
    },
    {
      "text": "Où est le parc ?",
      "correct": false
    },
    {
      "text": "Vous allez à pied ?",
      "correct": false
    }
  ],
  "explanation": "Combien ça coûte ? = prix / loyer."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "libre",
      "right": "oui, disponible"
    },
    {
      "left": "occupé",
      "right": "non, pris"
    },
    {
      "left": "cuisine",
      "right": "pour cuisiner"
    },
    {
      "left": "douche",
      "right": "pour l'eau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est libre ou ___ ?",
  "answer": "occupé"
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
    "cherche",
    "une",
    "chambre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "occupé",
  "hint": "Le contraire de libre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Combien ça coûtent ?",
  "correct_sentence": "Combien ça coûte ?",
  "explanation": "Ça = singulier → coûte."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/chambre.svg",
      "word": "une chambre"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/cuisine.svg",
      "word": "une cuisine"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/douche.svg",
      "word": "une douche"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/cle.svg",
      "word": "la clé"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six questions / phrases pour visiter Maison Karekezi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit phrases modèles, puis une visite inventée."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mot d''intérêt pour la chambre',
    'PE',
    $c$Objectif
Écrire un court mot pour réserver ou visiter une chambre.

Consigne
Imitez le mot d'Hawa. Changez un détail (jour ou question).

Support — Mot d'Hawa
Aline,
Je cherche un toit.
La chambre de la maison Karekezi m'intéresse.
C'est libre ? Il y a une douche ?
Je peux venir samedi ?
Merci.
Hawa Diallo
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa veut venir le samedi.",
  "correct": true,
  "explanation": "« Je peux venir samedi ? »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel logement Hawa nomme-t-elle ?",
  "options": [
    {
      "text": "Maison Karekezi",
      "correct": true
    },
    {
      "text": "Hôtel du Pont",
      "correct": false
    },
    {
      "text": "Chambre Figuier 7",
      "correct": false
    },
    {
      "text": "Parc des Sources",
      "correct": false
    }
  ],
  "explanation": "Le mot : maison Karekezi."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Je cherche",
      "right": "besoin"
    },
    {
      "left": "m'intéresse",
      "right": "envie"
    },
    {
      "left": "C'est libre ?",
      "right": "disponibilité"
    },
    {
      "left": "Je peux venir",
      "right": "visite"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa chambre m'___.",
  "answer": "intéresse"
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
    "peux",
    "venir",
    "samedi",
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
  "word": "intéresse",
  "hint": "Hawa dit : la chambre m'…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je cherches un toit.",
  "correct_sentence": "Je cherche un toit.",
  "explanation": "Je cherche (sans s)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/toit.svg",
      "word": "un toit"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/chambre.svg",
      "word": "une chambre"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/cle.svg",
      "word": "la clé"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/affiche.svg",
      "word": "l'affiche"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un mot de six lignes pour Aline : chercher, nommer la maison, deux questions, un jour, merci."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre mot, comme si Aline était devant le tableau."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Il y a, libre, loyer',
    'EL',
    $c$Objectif
Retenir le vocabulaire du logement et il y a / il n'y a pas.

Consigne
Apprenez la fiche, puis décrivez une chambre.

Support — Fiche d'Aline
une chambre / un lit / une cuisine / une douche / un toit
il y a + un / une
il n'y a pas de + nom
c'est libre / c'est occupé
Combien ça coûte ?
le loyer / la clé
Attention : un lit (masculin), une chambre (féminin).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « il n'y a pas de salon ».",
  "correct": true,
  "explanation": "Négation : il n'y a pas de + nom."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel article va avec « lit » ?",
  "options": [
    {
      "text": "une",
      "correct": false
    },
    {
      "text": "un",
      "correct": true
    },
    {
      "text": "des le",
      "correct": false
    },
    {
      "text": "la",
      "correct": false
    }
  ],
  "explanation": "Un lit (masculin)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il y a",
      "right": "présence"
    },
    {
      "left": "il n'y a pas",
      "right": "absence"
    },
    {
      "left": "libre",
      "right": "disponible"
    },
    {
      "left": "occupé",
      "right": "pris"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl n'y a pas ___ cuisine.",
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
    "C'est",
    "occupé",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "douche",
  "hint": "Pour se laver, dans l'annonce."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est une occupé.",
  "correct_sentence": "C'est occupé.",
  "explanation": "Occupé est un adjectif : c'est occupé."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/lit.svg",
      "word": "un lit"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/cuisine.svg",
      "word": "une cuisine"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/douche.svg",
      "word": "une douche"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/loyer.svg",
      "word": "le loyer"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la fiche. Décrivez une chambre inventée en cinq phrases."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites : il y a / il n'y a pas / c'est libre / c'est occupé / combien ça coûte ?"
}$j$::jsonb,
    9
  );

  -- ===== Sur la route =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Sur la route'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Sur la route', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Joël explique le Pont des Herbes',
    'CO',
    $c$Objectif
Comprendre un trajet : avant, après, attention, lentement, moto, à pied.

Consigne
Écoutez Joël. Que faut-il faire avant le pont ? Après le pont ?

Support — Sous le figuier, casque à la main
Joël : Je prends la moto. C'est le service Moto-Figuier.
Léa : On prend la route de Rukiri-Nord ?
Joël : Oui. Attention avant le pont des Herbes : allez lentement.
Léa : Et après le pont ?
Joël : Après le pont, c'est calme. On va au jardin. À pied, c'est long.
Léa : Pas de voiture aujourd'hui ?
Joël : Non. Juste la moto. Vous êtes prête ?
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël dit d'aller vite avant le pont.",
  "correct": false,
  "explanation": "Il dit : « allez lentement. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel service Joël nomme-t-il ?",
  "options": [
    {
      "text": "Bus 12",
      "correct": false
    },
    {
      "text": "Moto-Figuier",
      "correct": true
    },
    {
      "text": "Taxi-Lac",
      "correct": false
    },
    {
      "text": "Minibus 3",
      "correct": false
    }
  ],
  "explanation": "« C'est le service Moto-Figuier. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avant le pont",
      "right": "juste avant"
    },
    {
      "left": "après le pont",
      "right": "une fois passé"
    },
    {
      "left": "lentement",
      "right": "pas vite"
    },
    {
      "left": "attention",
      "right": "prudence"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAttention ___ le pont.",
  "answer": "avant"
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
    "prend",
    "la",
    "route",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pont",
  "hint": "Joël parle du… des Herbes."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Allez lente.",
  "correct_sentence": "Allez lentement.",
  "explanation": "L'adverbe est « lentement »."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/moto.svg",
      "word": "la moto"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/pont.svg",
      "word": "le pont"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/a-pied.svg",
      "word": "à pied"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/figuier.svg",
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
  "prompt": "Notez : le moyen, un conseil avant le pont, une info après le pont."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On prend la route de Rukiri-Nord. Attention avant le pont. Allez lentement. Après le pont, c'est calme."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — L''ardoise de la route',
    'CE',
    $c$Objectif
Lire un avis de route : avant / après, attention, moyens.

Consigne
Lisez l'ardoise accrochée près de la porte.

Support — Ardoise Moto-Figuier
Route de Rukiri-Nord
On prend la moto. Pas de voiture aujourd'hui.
Avant le pont des Herbes : attention, lentement.
Après le pont : le jardin est à droite.
À pied : c'est long.
Vélo : possible, mais lentement aussi.
Joël Mugisha
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Après le pont, le jardin est à gauche.",
  "correct": false,
  "explanation": "L'ardoise : « le jardin est à droite. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel moyen n'est pas disponible aujourd'hui ?",
  "options": [
    {
      "text": "La moto",
      "correct": false
    },
    {
      "text": "À pied",
      "correct": false
    },
    {
      "text": "Le vélo",
      "correct": false
    },
    {
      "text": "La voiture",
      "correct": true
    }
  ],
  "explanation": "« Pas de voiture aujourd'hui. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avant le pont",
      "right": "attention"
    },
    {
      "left": "après le pont",
      "right": "jardin à droite"
    },
    {
      "left": "à pied",
      "right": "c'est long"
    },
    {
      "left": "vélo",
      "right": "lentement aussi"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAprès le pont : le jardin est à ___.",
  "answer": "droite"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Pas",
    "de",
    "voiture",
    "aujourd'hui",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "attention",
  "hint": "Mot écrit avant le pont, pour la prudence."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On prends la route de Rukiri-Nord.",
  "correct_sentence": "On prend la route de Rukiri-Nord.",
  "explanation": "On prend (comme il/elle)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/moto.svg",
      "word": "la moto"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/velo.svg",
      "word": "le vélo"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/pont.svg",
      "word": "le pont"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/porte.svg",
      "word": "la porte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez l'ardoise en quatre phrases courtes (moyen, avant, après, à pied)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'ardoise à voix haute, comme un avis aux voyageurs."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire la route',
    'PO',
    $c$Objectif
Donner un conseil de route simple : avant / après, attention, lentement.

Consigne
Répétez, puis guidez jusqu'au pont.

Support — Modèles de Joël
On prend la route de Rukiri-Nord.
Je prends la moto.
Attention.
Allez lentement.
Avant le pont, c'est étroit.
Après le pont, tournez à droite.
À pied, c'est long.
Bonne route.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« C'est étroit » décrit la route avant le pont.",
  "correct": true,
  "explanation": "Modèle : avant le pont, c'est étroit."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel adverbe dit « pas vite » ?",
  "options": [
    {
      "text": "beaucoup",
      "correct": false
    },
    {
      "text": "lentement",
      "correct": true
    },
    {
      "text": "demain",
      "correct": false
    },
    {
      "text": "ici",
      "correct": false
    }
  ],
  "explanation": "Lentement = pas vite."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avant",
      "right": "plus tôt sur la route"
    },
    {
      "left": "après",
      "right": "plus tard sur la route"
    },
    {
      "left": "attention",
      "right": "soyez prudent"
    },
    {
      "left": "Bonne route",
      "right": "souhait"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAllez ___.",
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
    "Tournez",
    "à",
    "droite",
    "après",
    "le",
    "pont",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "route",
  "hint": "On prend la… de Rukiri-Nord."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avant le pont, allez lent.",
  "correct_sentence": "Avant le pont, allez lentement.",
  "explanation": "Après un verbe, on utilise l'adverbe « lentement »."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/moto.svg",
      "word": "la moto"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/pont.svg",
      "word": "le pont"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/droite.svg",
      "word": "à droite"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/a-pied.svg",
      "word": "à pied"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases pour un camarade qui va au pont (moyen, avant, après, conseil)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit phrases, puis votre propre conseil de route."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Trois conseils sur un carton',
    'PE',
    $c$Objectif
Écrire trois conseils de route clairs, au présent.

Consigne
Rédigez un carton pour les nouveaux, d'après le modèle de Joël.

Support — Modèle
Voyageurs,
On prend la route de Rukiri-Nord.
1. Attention avant le pont.
2. Allez lentement.
3. Après le pont, le jardin est à droite.
Bonne route.
Joël
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le modèle contient trois conseils numérotés.",
  "correct": true,
  "explanation": "1, 2 et 3 dans le carton."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où est le jardin, d'après le modèle ?",
  "options": [
    {
      "text": "À gauche avant le pont",
      "correct": false
    },
    {
      "text": "À droite après le pont",
      "correct": true
    },
    {
      "text": "Dans le minibus",
      "correct": false
    },
    {
      "text": "Sous le figuier seulement",
      "correct": false
    }
  ],
  "explanation": "« Après le pont, le jardin est à droite. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Attention",
      "right": "conseil 1"
    },
    {
      "left": "lentement",
      "right": "conseil 2"
    },
    {
      "left": "à droite",
      "right": "conseil 3"
    },
    {
      "left": "Bonne route",
      "right": "souhait final"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAprès le pont, le jardin est à ___.",
  "answer": "droite"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Attention",
    "avant",
    "le",
    "pont",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "voyageurs",
  "hint": "Premier mot du carton, au pluriel."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On prend la route à Rukiri-Nord.",
  "correct_sentence": "On prend la route de Rukiri-Nord.",
  "explanation": "On dit « la route de » + lieu."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/affiche.svg",
      "word": "l'affiche"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/pont.svg",
      "word": "le pont"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/parc.svg",
      "word": "le parc"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/moto.svg",
      "word": "la moto"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un carton : une ouverture, trois conseils (avant / lentement / après), une clôture."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre carton comme un avis affiché près de la porte."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Avant, après, attention',
    'EL',
    $c$Objectif
Retenir avant / après, les moyens et les conseils de route.

Consigne
Étudiez la fiche de Joël.

Support — Fiche route
On prend la route de + lieu
Je prends la moto / le vélo
Je vais à pied
avant + le / la + lieu
après + le / la + lieu
attention
lentement (adverbe)
Bonne route
Attention : on prend (pas « on prends »).
Allez lentement (pas « allez lent »).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Lentement » est un adverbe.",
  "correct": true,
  "explanation": "Il précise le verbe : allez lentement."
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
      "text": "On prends la moto",
      "correct": false
    },
    {
      "text": "On prend la moto",
      "correct": true
    },
    {
      "text": "On prendre la moto",
      "correct": false
    },
    {
      "text": "On prenez la moto",
      "correct": false
    }
  ],
  "explanation": "On = il/elle → prend."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avant",
      "right": "plus tôt"
    },
    {
      "left": "après",
      "right": "plus tard"
    },
    {
      "left": "à pied",
      "right": "sans véhicule"
    },
    {
      "left": "la moto",
      "right": "Moto-Figuier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn prend la route ___ Rukiri-Nord.",
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
    "vais",
    "à",
    "pied",
    "."
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
  "hint": "Adverbe : pas vite."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Après le pont, c'est à le droite.",
  "correct_sentence": "Après le pont, c'est à droite.",
  "explanation": "À droite, sans article."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a1-m3/moto.svg",
      "word": "la moto"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/velo.svg",
      "word": "le vélo"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/a-pied.svg",
      "word": "à pied"
    },
    {
      "image_path": "/elearning/mfk-a1-m3/pont.svg",
      "word": "le pont"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez la fiche. Écrivez quatre phrases : moto / à pied / avant / après."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Dites la fiche : on prend, avant, après, attention, lentement, bonne route."
}$j$::jsonb,
    9
  );

END;
$$;
