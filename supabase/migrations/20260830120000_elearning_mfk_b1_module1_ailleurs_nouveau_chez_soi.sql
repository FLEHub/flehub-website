/*
  Seed eLearning MFK — B1 — Ailleurs, un nouveau chez-soi

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b1-m1/
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
  v_module_title text := 'B1 — Ailleurs, un nouveau chez-soi';
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
      'Grande étape B1-1 : choisir un lieu de vie, formuler un souhait, caractériser un quartier, raconter des souvenirs d''arrivée, comparer deux rives et écrire à ceux qui restent — Léa et Patrick envisagent de s''installer à Rive-des-Saules (Val-des-Peupliers), Aline les accompagne, le Pavillon du Saule ouvre ses clés, et les lettres reviennent vers le figuier du Seuil des Sources (Rukiri-Nord).',
      'B1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B1-1 : choisir un lieu de vie, formuler un souhait, caractériser un quartier, raconter des souvenirs d''arrivée, comparer deux rives et écrire à ceux qui restent — Léa et Patrick envisagent de s''installer à Rive-des-Saules (Val-des-Peupliers), Aline les accompagne, le Pavillon du Saule ouvre ses clés, et les lettres reviennent vers le figuier du Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'B1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Choisir un lieu de vie =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Choisir un lieu de vie'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Choisir un lieu de vie', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Songer à l''autre rive',
    'CO',
    $c$Objectif
Repérer les verbes prépositionnels d'expatriation et les mises en garde.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui s'installe où, et de quoi Aline met-elle en garde ?

Support — Table des Sources, cartes ocre
Aline : Vous songez à vous installer où, exactement, après l'escale ?
Léa : Je songe à Rive-des-Saules, un quartier de Val-des-Peupliers.
Patrick : Moi, je rêve d'un étage au Pavillon du Saule, près du pont.
Marc : Attention : s'installer à une ville n'est pas s'installer dans un quartier.
Hawa : Il faudra s'habituer au rythme du minibus Figuier 7, même là-bas.
Joël : Et s'adapter aux voisins : Noura, Ibrahim et Mado passent souvent.
Rose : Je vous mets en garde : ne dépendez pas trop d'un seul ami pour le loyer.
Solange : Comptez sur le Bureau des Escales pour les clés, pas sur le hasard.
Karim : Si vous vous éloignez du Seuil, tenez tout de même à vos habitudes du figuier.
Lila : Radio Figuier relayera vos nouvelles, si vous tenez à rester liés.
Yvette : Le jardin du saule est calme, mais le loyer dépend du nombre de chambres.
Aline : Notez : s'installer à / dans, s'habituer à, s'adapter à, dépendre de, rêver de, tenir à, songer à, s'éloigner de, compter sur.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose met Léa et Patrick en garde contre une trop grande dépendance à un seul ami.",
  "correct": true,
  "explanation": "Rose : « ne dépendez pas trop d'un seul ami pour le loyer. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Marc, quelle distinction faut-il faire ?",
  "options": [
    {
      "text": "S'habituer et s'adapter sont interdits",
      "correct": false
    },
    {
      "text": "S'installer à une ville n'est pas s'installer dans un quartier",
      "correct": true
    },
    {
      "text": "Le loyer ne dépend de rien",
      "correct": false
    },
    {
      "text": "Radio Figuier refuse les nouvelles",
      "correct": false
    }
  ],
  "explanation": "Marc oppose la ville et le quartier."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "s'installer dans",
      "right": "un quartier"
    },
    {
      "left": "dépendre de",
      "right": "un ami / le loyer"
    },
    {
      "left": "compter sur",
      "right": "le Bureau des Escales"
    },
    {
      "left": "s'éloigner de",
      "right": "le Seuil"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe songe ___ Rive-des-Saules.",
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
    "rêve",
    "d'un",
    "étage",
    "au",
    "Pavillon",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "installer",
  "hint": "Poser ses bagages pour longtemps, à une ville ou dans un quartier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Léa s'installe à le Pavillon du Saule, et elle compte sur Aline.",
  "correct_sentence": "Léa s'installe au Pavillon du Saule, et elle compte sur Aline.",
  "explanation": "À + le = au, devant Pavillon."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/criteres-quartier.svg",
      "word": "des critères"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/carte-rive-saules.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/valise-lea.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/clef-pavillon.svg",
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
  "prompt": "Notez cinq verbes prépositionnels entendus et leur complément (à / de / dans / sur)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je songe à Rive-des-Saules. Je m'installe au pavillon. Je compte sur Aline. Je tiens au figuier."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Critères et mises en garde',
    'CE',
    $c$Objectif
Lire une fiche de critères et des mises en garde pour un nouveau chez-soi.

Consigne
Lisez la fiche épinglée au figuier, sans aller trop vite.

Support — Fiche d'Aline Uwase, Salle des Herbes
Fiche — Choisir un lieu de vie (Rive-des-Saules / Seuil)
1. S'installer à Val-des-Peupliers : la ville inventée, le tampon, le minibus.
2. S'installer dans le quartier Rive-des-Saules : rues, pont, Pavillon du Saule.
3. S'habituer au silence différent : ici le figuier, là-bas le saule et l'eau.
4. S'adapter aux voisins (Noura, Ibrahim, Félicie) sans tout changer de soi.
5. Le loyer dépend du nombre de chambres ; ne dépendez pas d'un seul salaire.
6. Rêver d'un étage calme est légitime ; songer à partir n'est pas trahir.
7. Tenir à ses habitudes du Seuil : le thé, la radio, le banc ocre.
8. S'éloigner de Rukiri-Nord demande du courage ; compter sur Solange aide.
Mise en garde de Rose : n'idéalisez pas ailleurs. Mise en garde de Marc : lisez le règlement.
Karim Bamba : les clés se retirent au Bureau des Escales, jamais sous une pierre.
Lila Sow : si vous tenez à rester liés, envoyez un mot chaque jeudi.
Aline : un critère n'est pas un caprice ; une mise en garde n'est pas un refus.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Karim dit qu'on peut laisser les clés sous une pierre.",
  "correct": false,
  "explanation": "Karim : les clés se retirent au bureau, jamais sous une pierre."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui demande d'envoyer un mot chaque jeudi ?",
  "options": [
    {
      "text": "Rose",
      "correct": false
    },
    {
      "text": "Marc",
      "correct": false
    },
    {
      "text": "Lila Sow",
      "correct": true
    },
    {
      "text": "Félicie",
      "correct": false
    }
  ],
  "explanation": "Lila : « envoyez un mot chaque jeudi. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "s'habituer à",
      "right": "un silence différent"
    },
    {
      "left": "dépendre de",
      "right": "le nombre de chambres"
    },
    {
      "left": "tenir à",
      "right": "les habitudes du Seuil"
    },
    {
      "left": "compter sur",
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
  "prompt": "Complétez :\nLe loyer dépend ___ nombre de chambres.",
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
    "S'installer",
    "dans",
    "le",
    "quartier",
    "demande",
    "du",
    "courage",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "habituer",
  "hint": "Rendre normal un nouveau rythme, un autre silence."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il fautons s'habituer au minibus, même si le jardin reste calme.",
  "correct_sentence": "Il faut s'habituer au minibus, même si le jardin reste calme.",
  "explanation": "Toujours il faut, à la 3e personne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/carte-rive-saules.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/valise-lea.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/clef-pavillon.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/verbe-preposition.svg",
      "word": "un verbe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez quatre critères et deux mises en garde, puis ajoutez le vôtre."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les douze lignes de la fiche, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire s''installer, s''adapter, tenir à',
    'PO',
    $c$Objectif
Employer à l'oral les verbes prépositionnels d'un choix de vie.

Consigne
Répétez les modèles, puis parlez d'un lieu où vous songeriez à vous installer.

Support — Modèles d'Aline, banc du Seuil
Je m'installe à Val-des-Peupliers.
Je m'installe dans le quartier Rive-des-Saules.
Je m'habitue au bruit du pont.
Je m'adapte aux voisins du Pavillon du Saule.
Le loyer dépend du jardin, pas seulement des murs.
Je rêve d'un étage qui donne sur l'eau.
Je tiens à mes jeudis sous le figuier.
Je songe à partir sans tout quitter.
Je m'éloigne de Rukiri-Nord, mais je compte sur vous.
Aline nous met en garde : ailleurs n'efface pas ici.
Patrick : Je dépends encore du minibus Figuier 7.
Léa : Je tiens à écrire, même si je m'éloigne.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Dépendre » se construit avec de, pas avec à.",
  "correct": true,
  "explanation": "Dépendre de quelqu'un / de quelque chose."
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
      "text": "Je m'habitue de le pont",
      "correct": false
    },
    {
      "text": "Je tiens de mes jeudis",
      "correct": false
    },
    {
      "text": "Je m'installe dans le quartier",
      "correct": true
    },
    {
      "text": "Je compte à Solange",
      "correct": false
    }
  ],
  "explanation": "S'installer dans + quartier."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "s'habituer à",
      "right": "un bruit / un rythme"
    },
    {
      "left": "s'adapter à",
      "right": "des voisins"
    },
    {
      "left": "rêver de",
      "right": "un étage"
    },
    {
      "left": "mettre en garde",
      "right": "Aline"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe tiens ___ mes jeudis sous le figuier.",
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
    "compte",
    "sur",
    "vous",
    "même",
    "loin",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "dependre",
  "hint": "Avoir besoin de quelqu'un ou d'un loyer pour tenir. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je dépends à Aline pour les clés, et je tiens au figuier.",
  "correct_sentence": "Je dépends d'Aline pour les clés, et je tiens au figuier.",
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
      "image_path": "/elearning/mfk-b1-m1/valise-lea.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/clef-pavillon.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/verbe-preposition.svg",
      "word": "un verbe"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/lettre-polie.svg",
      "word": "une lettre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases : un verbe prépositionnel différent dans chacune."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis deux phrases à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma mise en garde',
    'PE',
    $c$Objectif
Écrire une courte mise en garde et un choix de lieu avec des verbes prépositionnels.

Consigne
Imitez la note de Léa Niyonzima.

Support — Note de Léa, enveloppe ocre
Léa Niyonzima — Seuil des Sources, Rukiri-Nord
Je songe à m'installer dans le quartier Rive-des-Saules.
Je m'installerai à Val-des-Peupliers, au Pavillon du Saule, si Karim accepte.
Je tiens à nos jeudis ; je ne m'éloignerai pas de vous dans mon cœur.
Je compte sur Aline et sur Solange pour les papiers.
Je vous mets en garde : ne rêvez pas d'un ailleurs sans loyer, sans voisins, sans règles.
Le calme dépend du pont autant que du jardin.
Je m'habituerai à l'eau ; Patrick s'adaptera au silence différent.
Noura et Ibrahim pourront nous aider, mais nous ne dépendrons pas d'eux seuls.
Je rêve d'un étage simple, pas d'un palais.
À bientôt sous le figuier, même si la valise part.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa dit qu'elle dépendra seulement de Noura et d'Ibrahim.",
  "correct": false,
  "explanation": "« nous ne dépendrons pas d'eux seuls. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que met Léa en garde de ne pas faire ?",
  "options": [
    {
      "text": "Écrire à Aline",
      "correct": false
    },
    {
      "text": "Rêver d'un ailleurs sans loyer ni règles",
      "correct": true
    },
    {
      "text": "Prendre le minibus",
      "correct": false
    },
    {
      "text": "Saluer Karim",
      "correct": false
    }
  ],
  "explanation": "Elle met en garde contre un ailleurs idéalisé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "songer à",
      "right": "s'installer"
    },
    {
      "left": "tenir à",
      "right": "les jeudis"
    },
    {
      "left": "mettre en garde",
      "right": "un ailleurs sans règles"
    },
    {
      "left": "s'habituer à",
      "right": "l'eau"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe compte ___ Aline et sur Solange.",
  "answer": "sur"
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
    "m'éloignerai",
    "pas",
    "de",
    "vous",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "eloigner",
  "hint": "Partir plus loin de la cour, sans couper le lien. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ne vous éloignez pas à vos amis, et comptez sur Rose.",
  "correct_sentence": "Ne vous éloignez pas de vos amis, et comptez sur Rose.",
  "explanation": "S'éloigner de, pas s'éloigner à."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/clef-pavillon.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/verbe-preposition.svg",
      "word": "un verbe"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/lettre-polie.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/souhait-conditionnel.svg",
      "word": "un souhait"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : dix lignes, cinq verbes prépositionnels, une mise en garde."
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
    'EL — Verbes prépositionnels d''expatriation',
    'EL',
    $c$Objectif
Retenir la préposition fixe de chaque verbe et la mise en garde.

Consigne
Apprenez la fiche.

Support — Fiche du carnet d'Aline
s'installer à + ville : s'installer à Val-des-Peupliers
s'installer dans + quartier / bâtiment : s'installer dans Rive-des-Saules / au pavillon (à + le)
s'habituer à + nom / infinitif : s'habituer au silence, s'habituer à marcher
s'adapter à : s'adapter aux voisins, à un règlement
dépendre de : le loyer dépend du jardin ; je dépends de vous (pas dépendre à)
rêver de : rêver d'un étage, rêver de rester
tenir à : tenir à une habitude, tenir à écrire (cela compte beaucoup)
songer à : songer à partir, songer à un étage (y penser longtemps)
s'éloigner de : s'éloigner du Seuil, de ses amis
compter sur : compter sur Solange, sur le minibus
Mettre en garde (contre un danger) : Aline nous met en garde.
Attention : à + le = au ; de + le = du. Bien que + subjonctif : bien que ce soit loin.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je dépends à mes amis ».",
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
  "question": "« Tenir à écrire » signifie surtout…",
  "options": [
    {
      "text": "refuser d'écrire",
      "correct": false
    },
    {
      "text": "trouver l'écriture importante",
      "correct": true
    },
    {
      "text": "dépendre du papier",
      "correct": false
    },
    {
      "text": "s'éloigner de la lettre",
      "correct": false
    }
  ],
  "explanation": "Tenir à = accorder de l'importance."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "s'habituer à",
      "right": "un nouveau rythme"
    },
    {
      "left": "dépendre de",
      "right": "un loyer / une personne"
    },
    {
      "left": "songer à",
      "right": "un départ possible"
    },
    {
      "left": "compter sur",
      "right": "une aide fiable"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn s'adapte ___ un règlement.",
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
    "Aline",
    "nous",
    "met",
    "en",
    "garde",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "adapter",
  "hint": "Changer un peu ses habitudes pour coller au lieu nouveau."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On s'habitue de un nouveau rythme, et on s'adapte au quartier.",
  "correct_sentence": "On s'habitue à un nouveau rythme, et on s'adapte au quartier.",
  "explanation": "S'habituer à, pas s'habituer de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/verbe-preposition.svg",
      "word": "un verbe"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/lettre-polie.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/souhait-conditionnel.svg",
      "word": "un souhait"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/demande-aline.svg",
      "word": "une demande"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Construisez neuf phrases, une par verbe de la fiche, avec la bonne préposition."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis trois mises en garde à vous."
}$j$::jsonb,
    9
  );

  -- ===== Formuler un souhait =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Formuler un souhait'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Formuler un souhait', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Pourriez-vous ouvrir le pavillon ?',
    'CO',
    $c$Objectif
Comprendre des souhaits et des demandes polies au conditionnel présent.

Consigne
Lisez le dialogue. Qui souhaite quoi, et qui formule une demande polie ?

Support — Seuil du Pavillon du Saule
Karim : Vous voudriez visiter avant de décider, c'est raisonnable.
Léa : J'aimerais un étage qui donne sur le jardin, pas sur l'allée.
Patrick : Pourriez-vous nous montrer la chambre du fond, s'il vous plaît ?
Aline : On devrait lire le règlement avant de rêver trop fort.
Hawa : Je voudrais que le loyer reste clair : pas de surprise jeudi.
Joël : Est-ce que vous pourriez répéter le jour des clés, Karim ?
Rose : J'aimerais que Léa ne parte pas trop vite ; on devrait en parler.
Solange : Nous voudrions un tampon lisible, pas une signature floue.
Noura : Si vous vouliez un voisinage calme, vous seriez bien ici, le soir.
Ibrahim : On devrait aussi demander à Félicie : elle tient le cahier des chambres.
Marc : Je voudrais rester prudent : un souhait n'est pas encore un contrat.
Karim : Très bien. Je pourrais vous ouvrir demain à huit heures, si cela vous va.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick emploie une demande polie avec « pourriez-vous ».",
  "correct": true,
  "explanation": "Patrick : « Pourriez-vous nous montrer la chambre du fond… »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui tient le cahier des chambres, d'après Ibrahim ?",
  "options": [
    {
      "text": "Solange",
      "correct": false
    },
    {
      "text": "Noura",
      "correct": false
    },
    {
      "text": "Félicie",
      "correct": true
    },
    {
      "text": "Joël",
      "correct": false
    }
  ],
  "explanation": "Ibrahim : « elle tient le cahier des chambres. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je voudrais",
      "right": "un loyer clair / de la prudence"
    },
    {
      "left": "j'aimerais",
      "right": "un étage sur le jardin"
    },
    {
      "left": "pourriez-vous",
      "right": "montrer / répéter"
    },
    {
      "left": "on devrait",
      "right": "lire le règlement"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___-vous nous montrer la chambre du fond ?",
  "answer": "Pourriez"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'aimerais",
    "un",
    "étage",
    "sur",
    "le",
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
  "word": "voudrais",
  "hint": "Souhait poli à la première personne, mode du possible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je voudrais un étage calme, et je ferrai le dossier dès demain.",
  "correct_sentence": "Je voudrais un étage calme, et je ferai le dossier dès demain.",
  "explanation": "Futur de faire : ferai, un seul r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/lettre-polie.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/souhait-conditionnel.svg",
      "word": "un souhait"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/demande-aline.svg",
      "word": "une demande"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/place-adjectif.svg",
      "word": "un adjectif"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez trois souhaits et deux demandes polies, avec le verbe au conditionnel."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je voudrais un étage calme. J'aimerais visiter. Pourriez-vous ouvrir ? On devrait lire le règlement."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Lettre de souhait à Karim',
    'CE',
    $c$Objectif
Lire une lettre polie qui formule des souhaits au conditionnel.

Consigne
Lisez la lettre, sans aller trop vite.

Support — Lettre de Léa à Karim Bamba
Val-des-Peupliers, quartier Rive-des-Saules
Cher Karim,
Nous aimerions visiter le Pavillon du Saule avant jeudi.
Je voudrais un étage simple, avec une fenêtre sur le jardin, si cela se peut.
Patrick voudrait clarifier le loyer : pourriez-vous l'indiquer par écrit ?
On devrait aussi savoir à quelle heure on retire les clés au Bureau des Escales.
Aline nous a dit qu'on devrait lire le règlement ; nous le ferons, bien sûr.
J'aimerais que Noura et Ibrahim soient prévenus : nous tiendrions à les saluer.
Pourriez-vous, s'il vous plaît, nous recevoir demain matin plutôt que le soir ?
Nous serions reconnaissants d'une réponse courte, même par Radio Figuier.
Recevez, je vous prie, nos salutations attentives.
Léa Niyonzima et Patrick Habimana
Copie : Aline Uwase — Seuil des Sources
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa demande une visite le soir plutôt que le matin.",
  "correct": false,
  "explanation": "Elle demande demain matin plutôt que le soir."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que voudrait Patrick, d'après la lettre ?",
  "options": [
    {
      "text": "Un tambour de Sami",
      "correct": false
    },
    {
      "text": "Le loyer indiqué par écrit",
      "correct": true
    },
    {
      "text": "Partir sans clés",
      "correct": false
    },
    {
      "text": "Fermer le jardin",
      "correct": false
    }
  ],
  "explanation": "« Patrick voudrait clarifier le loyer… par écrit. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "nous aimerions",
      "right": "visiter le pavillon"
    },
    {
      "left": "je voudrais",
      "right": "un étage simple"
    },
    {
      "left": "pourriez-vous",
      "right": "indiquer / recevoir"
    },
    {
      "left": "nous serions",
      "right": "reconnaissants"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ___ aussi savoir l'heure des clés. (devoir, cond.)",
  "answer": "devrait"
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
    "aimerions",
    "visiter",
    "le",
    "pavillon",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "aimerais",
  "hint": "Autre verbe de souhait, première personne, plus doux que vouloir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'aimerais visiter le jardin, et je pourai venir jeudi.",
  "correct_sentence": "J'aimerais visiter le jardin, et je pourrai venir jeudi.",
  "explanation": "Futur de pouvoir : pourrai, deux r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/souhait-conditionnel.svg",
      "word": "un souhait"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/demande-aline.svg",
      "word": "une demande"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/place-adjectif.svg",
      "word": "un adjectif"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/banc-hypothese.svg",
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
  "prompt": "Recopiez la lettre et soulignez tous les conditionnels."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la lettre de Léa à voix haute, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire je voudrais, pourriez-vous',
    'PO',
    $c$Objectif
Formuler à l'oral un souhait et une demande polie au conditionnel.

Consigne
Répétez, puis demandez poliment une information sur un logement.

Support — Modèles de Patrick et d'Aline
Je voudrais un étage calme.
J'aimerais visiter demain.
Pourriez-vous m'indiquer le loyer ?
On devrait lire le règlement d'abord.
Nous aimerions saluer Noura.
Est-ce que vous pourriez répéter l'heure ?
Je serais plus tranquille avec une clé de rechange.
On devrait aussi prévenir Félicie.
Aline : un souhait se dit sans exiger.
Karim : une demande polie laisse à l'autre le droit de dire non.
Hawa : « je veux » sonne trop sec ici ; « je voudrais » ouvre la porte.
Léa : « pourriez-vous » vaut mieux que « vous devez m'ouvrir ».
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Pourriez-vous » est plus poli que « vous devez ».",
  "correct": true,
  "explanation": "Léa oppose les deux formules."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase formule un conseil au conditionnel ?",
  "options": [
    {
      "text": "Je voudrais un étage calme",
      "correct": false
    },
    {
      "text": "Pourriez-vous m'indiquer le loyer",
      "correct": false
    },
    {
      "text": "On devrait lire le règlement d'abord",
      "correct": true
    },
    {
      "text": "J'ouvre la porte",
      "correct": false
    }
  ],
  "explanation": "On devrait = conseil, pas une exigence."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je voudrais",
      "right": "souhait"
    },
    {
      "left": "j'aimerais",
      "right": "souhait plus doux"
    },
    {
      "left": "pourriez-vous",
      "right": "demande polie"
    },
    {
      "left": "on devrait",
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
  "prompt": "Complétez :\nJe ___ plus tranquille avec une clé. (être, cond.)",
  "answer": "serais"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Pourriez-vous",
    "m'indiquer",
    "le",
    "loyer",
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
  "word": "pourriez",
  "hint": "Forme polie de pouvoir, adressée à vous, avant une demande."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Pourriez-vous m'indiquer le pavillon, et on devrais y aller tôt.",
  "correct_sentence": "Pourriez-vous m'indiquer le pavillon, et on devrait y aller tôt.",
  "explanation": "On devrait : base de devoir + ait, pas ais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/demande-aline.svg",
      "word": "une demande"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/place-adjectif.svg",
      "word": "un adjectif"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/banc-hypothese.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/conseil-marc.svg",
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
  "prompt": "Écrivez six répliques : deux je voudrais, deux j'aimerais, deux pourriez-vous."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis une demande polie à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma demande polie',
    'PE',
    $c$Objectif
Écrire une demande polie au conditionnel pour un logement.

Consigne
Imitez la demande de Patrick Habimana.

Support — Demande de Patrick, cahier bleu
Patrick Habimana — Seuil des Sources
Cher Karim,
Je voudrais clarifier trois points avant de poser ma valise.
J'aimerais visiter le Pavillon du Saule avec Léa, demain si possible.
Pourriez-vous nous indiquer le loyer, l'heure des clés et la règle du jardin ?
On devrait aussi savoir si Noura accepte un voisinage de passage.
Je serais reconnaissant d'une réponse courte, même un mot à Radio Figuier.
Nous tiendrions à saluer Félicie, qui tient le cahier des chambres.
Aline nous a conseillé de ne pas exiger : nous demandons, nous n'imposons pas.
Si vous pouviez ouvrir le matin, ce serait plus simple pour le minibus Figuier 7.
Merci d'avance, et à bientôt sous le saule ou sous le figuier.
Patrick
Copie : Léa Niyonzima, Aline Uwase
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick impose l'heure d'ouverture à Karim.",
  "correct": false,
  "explanation": "Il demande sans imposer ; Aline a conseillé de ne pas exiger."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Combien de points Patrick veut-il clarifier ?",
  "options": [
    {
      "text": "Un",
      "correct": false
    },
    {
      "text": "Deux",
      "correct": false
    },
    {
      "text": "Trois",
      "correct": true
    },
    {
      "text": "Dix",
      "correct": false
    }
  ],
  "explanation": "« clarifier trois points avant de poser ma valise. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je voudrais",
      "right": "clarifier"
    },
    {
      "left": "j'aimerais",
      "right": "visiter"
    },
    {
      "left": "pourriez-vous",
      "right": "indiquer trois infos"
    },
    {
      "left": "je serais",
      "right": "reconnaissant"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi vous pouviez ouvrir le matin, ce ___ plus simple.",
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
    "Je",
    "voudrais",
    "clarifier",
    "trois",
    "points",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "devrait",
  "hint": "On… lire le règlement : conseil, pas un ordre sec."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je serai reconnaissant si vous pouviez garder une chambre, et je tiendrais au jardin.",
  "correct_sentence": "Je serais reconnaissant si vous pouviez garder une chambre, et je tiendrais au jardin.",
  "explanation": "Conditionnel de être : serais, pas le futur serai."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/place-adjectif.svg",
      "word": "un adjectif"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/banc-hypothese.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/conseil-marc.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/jardin-saule.svg",
      "word": "un jardin"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : une demande de dix lignes, avec voudrais, aimerais, pourriez-vous, devrait."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre demande, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Conditionnel présent et politesse',
    'EL',
    $c$Objectif
Retenir la formation du conditionnel présent et son usage poli.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, conditionnel
Conditionnel présent = radical du futur + terminaisons de l'imparfait
je voudrais / tu voudrais / il voudrait / nous voudrions / vous voudriez / ils voudraient
j'aimerais, tu aimerais, il aimerait…
je pourrais, vous pourriez (demande polie : pourriez-vous + infinitif ?)
on devrait + infinitif : conseil souple
je serais (cond.) ≠ je serai (futur, un r après e, pas ais)
je ferais (cond.) ≠ je ferai (futur, un seul r)
je pourrais (cond.) ≠ je pourrai (futur, deux r)
Politesse : je voudrais > je veux ; pourriez-vous > vous devez
Un souhait n'est pas un contrat. On peut répondre non.
Attention : il faut (pas je faut). Bien que + subjonctif : bien que ce soit tôt.
Si + imparfait → conditionnel : si vous pouviez ouvrir, ce serait plus simple.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je serai » et « je serais » ont le même temps.",
  "correct": false,
  "explanation": "Serai = futur. Serais = conditionnel."
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
      "left": "je voudrais",
      "right": "souhait"
    },
    {
      "left": "pourriez-vous",
      "right": "demande polie"
    },
    {
      "left": "je serais",
      "right": "conditionnel de être"
    },
    {
      "left": "je ferai",
      "right": "futur de faire"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDemain, je ___ le dossier. (faire, futur)",
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
    "On",
    "devrait",
    "lire",
    "le",
    "règlement",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "souhait",
  "hint": "Ce qu'on aimerait obtenir, dit sans l'exiger."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous voudrions un étage, mais je faut demander à Karim.",
  "correct_sentence": "Nous voudrions un étage, mais il faut demander à Karim.",
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
      "image_path": "/elearning/mfk-b1-m1/banc-hypothese.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/conseil-marc.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/jardin-saule.svg",
      "word": "un jardin"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/pronom-ou.svg",
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
  "prompt": "Conjuguez vouloir, aimer, pouvoir, devoir, être et faire au conditionnel présent (je / nous / vous)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six formes : voudrais, aimerais, pourriez, devrait, serais, ferais."
}$j$::jsonb,
    9
  );

  -- ===== Un quartier à caractériser =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un quartier à caractériser'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un quartier à caractériser', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Un petit quartier calme',
    'CO',
    $c$Objectif
Repérer la place de l'adjectif, des conseils et une hypothèse (si + imparfait).

Consigne
Lisez le dialogue. Comment caractérise-t-on Rive-des-Saules ?

Support — Pont des Saules, fin d'après-midi
Marc : C'est un petit quartier calme, pas une grande ville bruyante.
Léa : Je vois un ancien pont et, plus loin, un pont ancien couvert de mousse.
Aline : Ancien avant le nom, c'est souvent « d'autrefois ». Après le nom, c'est l'âge réel.
Patrick : Si nous habitions ici, nous serions plus près de l'eau, moins près du figuier.
Hawa : Prenez un grand appartement lumineux plutôt qu'une petite chambre sombre.
Joël : Si j'avais une clé ce soir, je pourrais vous montrer le jardin du saule.
Rose : Évitez l'allée trop étroite à la tombée de la nuit ; restez sur le quai large.
Noura : Nous avons une jolie cour verte, et une maison haute derrière les peupliers.
Ibrahim : Si vous restiez trois mois, vous connaîtriez déjà tous les prénoms.
Félicie : Un jeune voisin silencieux vaut mieux qu'un vieux bruit gentil, parfois.
Dieudonné : Je conseillerais le premier étage : un bel étage clair, un escalier simple.
Yvette : Si le loyer était plus clair, davantage de gens du Seuil oseraient venir.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline dit qu'un ancien pont et un pont ancien veulent toujours dire la même chose.",
  "correct": false,
  "explanation": "Elle distingue « d'autrefois » et l'âge réel."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que conseillerait Dieudonné ?",
  "options": [
    {
      "text": "Le sous-sol sans fenêtre",
      "correct": false
    },
    {
      "text": "Le premier étage, un bel étage clair",
      "correct": true
    },
    {
      "text": "L'allée trop étroite la nuit",
      "correct": false
    },
    {
      "text": "Une petite chambre sombre",
      "correct": false
    }
  ],
  "explanation": "Dieudonné : « Je conseillerais le premier étage. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "petit / calme",
      "right": "quartier"
    },
    {
      "left": "ancien pont",
      "right": "d'autrefois"
    },
    {
      "left": "si nous habitions",
      "right": "nous serions"
    },
    {
      "left": "grand / lumineux",
      "right": "appartement"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est un ___ quartier calme.",
  "answer": "petit"
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
    "nous",
    "habitions",
    "ici",
    "nous",
    "serions",
    "près",
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
  "word": "ancien",
  "hint": "Adjectif d'âge : avant le nom, il dit souvent « d'autrefois »."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est un quartier petit calme, avec un ancien pont près du saule.",
  "correct_sentence": "C'est un petit quartier calme, avec un ancien pont près du saule.",
  "explanation": "Petit (taille) se place avant le nom."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/conseil-marc.svg",
      "word": "un conseil"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/jardin-saule.svg",
      "word": "un jardin"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/pronom-ou.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/pronom-dont.svg",
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
  "prompt": "Notez quatre adjectifs (place) et deux phrases en si + imparfait → conditionnel."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : C'est un petit quartier calme. Si nous habitions ici, nous serions plus près de l'eau."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Portrait de Rive-des-Saules',
    'CE',
    $c$Objectif
Lire un portrait de quartier et les conseils qui l'accompagnent.

Consigne
Lisez le portrait, sans aller trop vite.

Support — Feuille de Marc Nkurunziza
Rive-des-Saules — portrait pour ceux du Seuil
C'est un petit quartier calme, une longue allée verte, un vieux quai bas.
On y voit un ancien pont (celui d'autrefois, en bois) et un pont de pierre plus récent.
La jolie cour du Pavillon du Saule reste ouverte le matin ; le soir, Félicie ferme.
Conseil : choisissez un grand appartement clair plutôt qu'une chambre étroite.
Conseil : évitez l'allée trop sombre après vingt et une heures ; prenez le quai.
Si vous aviez une clé, vous pourriez entrer sans réveiller Noura.
Si le minibus Figuier 7 arrivait plus tôt, le trajet serait moins long.
Yvette note : une jeune voisine attentive, un haut peuplier, une eau verte.
Mado ajoute : ce n'est pas une grande ville froide ; c'est un quartier vivant, simplement.
Sami passerait avec son tambour le jeudi, si la cour était libre.
Marc : caractériser, c'est choisir l'adjectif et sa place, puis oser un si.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Félicie ferme la cour le matin et l'ouvre le soir.",
  "correct": false,
  "explanation": "La cour est ouverte le matin ; Félicie ferme le soir."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que feriez-vous si vous aviez une clé, d'après le texte ?",
  "options": [
    {
      "text": "Réveiller Noura",
      "correct": false
    },
    {
      "text": "Entrer sans réveiller Noura",
      "correct": true
    },
    {
      "text": "Fermer le pont",
      "correct": false
    },
    {
      "text": "Casser le tambour",
      "correct": false
    }
  ],
  "explanation": "« vous pourriez entrer sans réveiller Noura. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "petit / calme",
      "right": "quartier"
    },
    {
      "left": "ancien pont",
      "right": "en bois, d'autrefois"
    },
    {
      "left": "si vous aviez",
      "right": "vous pourriez"
    },
    {
      "left": "jeune / attentive",
      "right": "voisine"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi vous aviez une clé, vous ___ entrer. (pouvoir, cond.)",
  "answer": "pourriez"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Choisissez",
    "un",
    "grand",
    "appartement",
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
  "word": "calme",
  "hint": "Sans bruit, derrière le saule, un quartier…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si nous avions une clé, nous pourrons entrer, et le jardin resterait ouvert.",
  "correct_sentence": "Si nous avions une clé, nous pourrions entrer, et le jardin resterait ouvert.",
  "explanation": "Si + imparfait → conditionnel : pourrions, pas le futur pourrons."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/jardin-saule.svg",
      "word": "un jardin"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/pronom-ou.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/pronom-dont.svg",
      "word": "un souvenir"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/photo-arrivee.svg",
      "word": "une photo"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le portrait et encadrez six adjectifs ; notez leur place."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le portrait de Marc, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Conseiller et supposer',
    'PO',
    $c$Objectif
Donner un conseil et construire une hypothèse : si + imparfait → conditionnel.

Consigne
Répétez, puis conseillez un étage et imaginez « si vous habitiez là ».

Support — Modèles de Marc et d'Aline
C'est un petit quartier calme.
Prenez un bel étage clair.
Évitez l'allée trop étroite.
Si j'habitais là, je serais plus près de l'eau.
Si nous avions une clé, nous pourrions entrer.
Si le loyer était clair, davantage de gens viendraient.
Je conseillerais le premier étage.
Restez sur le large quai, le soir.
Aline : l'adjectif de taille, d'âge, de beauté se place souvent avant.
Patrick : calme, lumineux, sombre se placent souvent après.
Léa : un ancien pont n'est pas toujours un pont ancien.
Hawa : un conseil se dit à l'impératif ou avec « je conseillerais ».
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Après si, on met l'imparfait, et le résultat se met au conditionnel.",
  "correct": true,
  "explanation": "Si j'habitais là, je serais…"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est une hypothèse correcte ?",
  "options": [
    {
      "text": "Si j'habite là, je serais libre",
      "correct": false
    },
    {
      "text": "Si j'habitais là, je serais plus près de l'eau",
      "correct": true
    },
    {
      "text": "Si j'habitais là, je serai plus près",
      "correct": false
    },
    {
      "text": "Si j'aurais une clé, j'entre",
      "correct": false
    }
  ],
  "explanation": "Si + imparfait, puis conditionnel."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "petit / bel / ancien",
      "right": "souvent avant le nom"
    },
    {
      "left": "calme / lumineux",
      "right": "souvent après le nom"
    },
    {
      "left": "si + imparfait",
      "right": "conditionnel"
    },
    {
      "left": "je conseillerais",
      "right": "conseil souple"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi j'habitais là, je ___ plus près de l'eau. (être, cond.)",
  "answer": "serais"
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
    "conseillerais",
    "le",
    "premier",
    "étage",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "vivions",
  "hint": "Si nous… là : imparfait de vivre, après si."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si j'habitais là, je serai plus libre, et je tiendrais à ce banc.",
  "correct_sentence": "Si j'habitais là, je serais plus libre, et je tiendrais à ce banc.",
  "explanation": "Après si + imparfait : serais, pas le futur serai."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/pronom-ou.svg",
      "word": "un pronom"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/pronom-dont.svg",
      "word": "un souvenir"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/photo-arrivee.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/souvenir-pont.svg",
      "word": "un pont"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six conseils et quatre hypothèses (si + imparfait → conditionnel)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis deux hypothèses à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon portrait de quartier',
    'PE',
    $c$Objectif
Écrire un portrait avec la place de l'adjectif, un conseil et une hypothèse.

Consigne
Imitez le portrait de Hawa Diallo.

Support — Portrait de Hawa, cahier du chemin
Hawa Diallo — Rive-des-Saules vue depuis le pont
C'est un petit quartier calme, une jolie cour verte, un haut peuplier.
J'y vois un ancien pont de bois et une longue allée claire.
Je conseillerais un grand appartement lumineux, pas une chambre étroite.
Évitez l'allée trop sombre après vingt et une heures ; restez près de l'eau.
Si j'habitais au Pavillon du Saule, je serais plus près de Noura, moins près du figuier.
Si nous avions une clé de rechange, nous pourrions rentrer sans réveiller Félicie.
Mado dit que c'est un quartier vivant, simplement, pas une ville froide.
Sami passerait le jeudi, si la cour était libre.
Je tiens à ce portrait honnête : ailleurs n'est ni parfait ni triste.
Hawa
Copie pour Aline et pour le banc du Seuil
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa conseille une chambre étroite plutôt qu'un grand appartement.",
  "correct": false,
  "explanation": "Elle conseille un grand appartement lumineux."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que se passerait-il si Hawa habitait au pavillon ?",
  "options": [
    {
      "text": "Elle serait plus près de Noura",
      "correct": true
    },
    {
      "text": "Elle vendrait le figuier",
      "correct": false
    },
    {
      "text": "Elle fermerait le pont",
      "correct": false
    },
    {
      "text": "Elle quitterait le français",
      "correct": false
    }
  ],
  "explanation": "« je serais plus près de Noura, moins près du figuier. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "petit / jolie / haut",
      "right": "avant le nom"
    },
    {
      "left": "calme / verte / claire",
      "right": "après le nom"
    },
    {
      "left": "je conseillerais",
      "right": "un appartement"
    },
    {
      "left": "si j'habitais",
      "right": "je serais"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nÉvitez l'allée trop sombre ; restez près ___ l'eau.",
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
    "un",
    "petit",
    "quartier",
    "calme",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "conseil",
  "hint": "Recommandation de Marc ou d'Hawa pour choisir un étage."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Prenez un appartement grand lumineux, et restez près du pont.",
  "correct_sentence": "Prenez un grand appartement lumineux, et restez près du pont.",
  "explanation": "Grand (taille) se place avant le nom."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/pronom-dont.svg",
      "word": "un souvenir"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/photo-arrivee.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/souvenir-pont.svg",
      "word": "un pont"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/deux-rives.svg",
      "word": "deux rives"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : un portrait de dix lignes, trois adjectifs bien placés, un si, un conseil."
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
    'EL — Place de l''adjectif et si hypothétique',
    'EL',
    $c$Objectif
Retenir la place de l'adjectif et le système si + imparfait → conditionnel.

Consigne
Apprenez la fiche.

Support — Fiche de Marc, adjectifs et si
Souvent avant le nom (taille, âge, beauté, bon/mauvais) :
un petit quartier, un grand appartement, un bel étage, un ancien pont, une jolie cour
Souvent après le nom (couleur, forme, qualité « de nature ») :
un quartier calme, un appartement lumineux, une allée sombre, une eau verte
Sens qui change : un ancien pont (d'autrefois) / un pont ancien (très vieux)
un brave homme / un homme brave
Si + imparfait → conditionnel présent (hypothèse non réelle maintenant) :
Si j'habitais là, je serais plus libre.
Si nous avions une clé, nous pourrions entrer.
Pas : si j'aurais… Pas : si + imparfait → futur (je serai).
Conseils : impératif (prenez, évitez) ou conditionnel (je conseillerais).
À + le = au : au milieu du quartier, au Pavillon du Saule.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « si j'aurais une clé » dans cette hypothèse.",
  "correct": false,
  "explanation": "Si + imparfait : si j'avais, jamais si j'aurais ici."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Un ancien pont » veut dire surtout…",
  "options": [
    {
      "text": "un pont tout neuf",
      "correct": false
    },
    {
      "text": "un pont d'autrefois / qui n'est plus le pont actuel",
      "correct": true
    },
    {
      "text": "un pont sans eau",
      "correct": false
    },
    {
      "text": "un pont interdit",
      "correct": false
    }
  ],
  "explanation": "Ancien avant le nom : d'autrefois."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "petit / grand / bel",
      "right": "avant"
    },
    {
      "left": "calme / lumineux / sombre",
      "right": "après"
    },
    {
      "left": "si + imparfait",
      "right": "conditionnel"
    },
    {
      "left": "je conseillerais",
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
  "prompt": "Complétez :\nAu ___ du quartier, un petit café calme. (milieu)",
  "answer": "milieu"
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
    "j'avais",
    "une",
    "clé",
    "je",
    "pourrais",
    "entrer",
    "."
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
  "sentence_with_error": "On écrit à le milieu du quartier un petit café calme.",
  "correct_sentence": "On écrit au milieu du quartier un petit café calme.",
  "explanation": "À + le = au."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/photo-arrivee.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/souvenir-pont.svg",
      "word": "un pont"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/deux-rives.svg",
      "word": "deux rives"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/balance-choix.svg",
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
  "prompt": "Faites deux listes d'adjectifs (avant / après) et quatre phrases en si."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et quatre exemples : deux adjectifs, deux si."
}$j$::jsonb,
    9
  );

  -- ===== Souvenirs d'arrivée =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Souvenirs d''arrivée'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Souvenirs d''arrivée', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le jour où le minibus s''est arrêté',
    'CO',
    $c$Objectif
Comprendre où et dont dans des souvenirs d'arrivée.

Consigne
Lisez le dialogue. Quel est le lieu où l'on arrive, et de quoi se souvient-on ?

Support — Banc du Seuil, photos étalées
Léa : Le quartier où je suis descendue s'appelait déjà Rive-des-Saules.
Patrick : La ville dont je me souviens sentait l'eau et le bois mouillé.
Aline : Le jour où le minibus Figuier 7 s'est arrêté, Karim tenait deux clés.
Marc : Les gens dont nous parlons encore, c'est Noura, Ibrahim, Félicie.
Hawa : La raison dont Léa m'a parlé, c'était le silence différent, pas la fuite.
Joël : Le pavillon dont les fenêtres donnent sur le jardin m'a paru simple et juste.
Rose : L'allée où Sami a posé son tambour reste dans toutes les photos.
Solange : Le bureau où l'on tamponne, c'est celui des Escales, pas la Maison des Vents.
Mado : Je me souviens de la brume dont le pont était couvert, ce premier matin.
Yvette : L'heure où nous avons trop attendu nous a appris la patience.
Lila : Radio Figuier a gardé la voix dont Patrick riait encore, fatigué et content.
Aline : Où = lieu ou moment. Dont = de + nom (parler de, se souvenir de, possession).
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dont remplace souvent « de + nom » : se souvenir de, parler de.",
  "correct": true,
  "explanation": "Aline le rappelle en clôture."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "De quelle raison Léa a-t-elle parlé, d'après Hawa ?",
  "options": [
    {
      "text": "La fuite",
      "correct": false
    },
    {
      "text": "Le silence différent",
      "correct": true
    },
    {
      "text": "Un tambour cassé",
      "correct": false
    },
    {
      "text": "Un tampon perdu",
      "correct": false
    }
  ],
  "explanation": "Hawa : « le silence différent, pas la fuite. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le quartier où",
      "right": "Léa est descendue"
    },
    {
      "left": "la ville dont",
      "right": "Patrick se souvient"
    },
    {
      "left": "les gens dont",
      "right": "nous parlons"
    },
    {
      "left": "le jour où",
      "right": "le minibus s'est arrêté"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa ville ___ je me souviens sentait l'eau.",
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
    "quartier",
    "où",
    "je",
    "suis",
    "descendue",
    "était",
    "calme",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "souvenir",
  "hint": "Ce qui reste dans la mémoire après la première arrivée."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le quartier que je vis est calme, et la ville dont je me souviens reste verte.",
  "correct_sentence": "Le quartier où je vis est calme, et la ville dont je me souviens reste verte.",
  "explanation": "Vivre dans un lieu → où, pas que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/souvenir-pont.svg",
      "word": "un pont"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/deux-rives.svg",
      "word": "deux rives"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/balance-choix.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/cahier-comparaison.svg",
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
  "prompt": "Notez quatre relatives : deux avec où, deux avec dont."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Le quartier où je suis descendue. La ville dont je me souviens. Les gens dont nous parlons."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Carnet d''arrivée de Léa',
    'CE',
    $c$Objectif
Lire un carnet de souvenirs qui enchaîne où et dont.

Consigne
Lisez le carnet, sans aller trop vite.

Support — Carnet de Léa Niyonzima
Le quartier où je suis descendue sentait déjà le saule et l'eau.
La ville dont je me souviens n'était pas bruyante : Val-des-Peupliers, rive nord.
Le jour où Karim a tendu les clés, Patrick a trop ri, de fatigue et de soulagement.
Les gens dont nous parlons encore tiennent le cahier, le pont, le thé du matin.
La raison dont j'ai parlé à Hawa, c'était d'apprendre un autre silence, pas de fuir.
Le pavillon dont les fenêtres donnent sur le jardin a une chambre simple, ocre.
L'allée où Sami a posé son tambour reste sur la photo pliée dans mon sac.
Le bureau où Solange tamponne ouvre tôt ; la Maison des Vents, elle, reste au Seuil.
Je me souviens de la brume dont le pont était couvert, et de la voix de Lila.
L'heure où le minibus Figuier 7 a trop tardé nous a appris à attendre ensemble.
Mado, Yvette et Félicie : trois prénoms dont je n'oublie plus l'ordre.
Aline dira : où pour le lieu et le moment ; dont pour « de cela ».
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa dit qu'elle est descendue pour fuir le Seuil.",
  "correct": false,
  "explanation": "La raison : apprendre un autre silence, pas fuir."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Solange tamponne-t-elle, d'après le carnet ?",
  "options": [
    {
      "text": "À la Maison des Vents",
      "correct": false
    },
    {
      "text": "Au bureau des Escales",
      "correct": true
    },
    {
      "text": "Sous le figuier seulement",
      "correct": false
    },
    {
      "text": "Dans le minibus",
      "correct": false
    }
  ],
  "explanation": "« Le bureau où Solange tamponne ouvre tôt. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le quartier où",
      "right": "Léa est descendue"
    },
    {
      "left": "la ville dont",
      "right": "elle se souvient"
    },
    {
      "left": "la raison dont",
      "right": "elle a parlé à Hawa"
    },
    {
      "left": "l'allée où",
      "right": "Sami a posé son tambour"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes gens ___ nous parlons tiennent le cahier.",
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
    "jour",
    "où",
    "Karim",
    "a",
    "tendu",
    "les",
    "clés",
    "."
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
  "hint": "Pronom pour remplacer de + nom après un antécédent."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les gens que je parle sont restés au Seuil, et le pont où nous avons marché tient encore.",
  "correct_sentence": "Les gens dont je parle sont restés au Seuil, et le pont où nous avons marché tient encore.",
  "explanation": "Parler de quelqu'un → dont, pas que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/deux-rives.svg",
      "word": "deux rives"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/balance-choix.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/cahier-comparaison.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/minibus-figuier.svg",
      "word": "un minibus"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le carnet et encadrez où et dont ; indiquez ce qu'ils remplacent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le carnet de Léa, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire où et dont',
    'PO',
    $c$Objectif
Relier un souvenir avec où (lieu, moment) et dont (de + nom).

Consigne
Répétez, puis racontez une arrivée avec où et dont.

Support — Modèles d'Aline et de Patrick
C'est le quartier où je suis descendue.
C'est la ville dont je me souviens.
C'est le jour où le minibus s'est arrêté.
Ce sont les gens dont nous parlons.
C'est la raison dont Léa m'a parlé.
C'est le pavillon dont les fenêtres donnent sur le jardin.
C'est l'allée où Sami a joué.
C'est l'heure où nous avons trop attendu.
Aline : où = dans lequel / auquel moment.
Patrick : dont = de qui / de quoi / duquel.
Hawa : je me souviens de la ville → la ville dont je me souviens.
Joël : je parle des voisins → les voisins dont je parle.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Dont » peut exprimer une possession : le pavillon dont les fenêtres…",
  "correct": true,
  "explanation": "Dont = de + le pavillon."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Je me souviens de la ville » se relie comment ?",
  "options": [
    {
      "text": "la ville où je me souviens",
      "correct": false
    },
    {
      "text": "la ville que je me souviens",
      "correct": false
    },
    {
      "text": "la ville dont je me souviens",
      "correct": true
    },
    {
      "text": "la ville à qui je me souviens",
      "correct": false
    }
  ],
  "explanation": "Se souvenir de → dont."
}$j$::jsonb,
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
      "left": "se souvenir de",
      "right": "dont"
    },
    {
      "left": "parler de",
      "right": "dont"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est le pavillon ___ les fenêtres donnent sur le jardin.",
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
    "le",
    "jour",
    "où",
    "le",
    "minibus",
    "s'est",
    "arrêté",
    "."
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
  "hint": "Le secteur autour du pavillon, celui où l'on descend."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est la ville que je me souviens, et le jour où le minibus s'est arrêté.",
  "correct_sentence": "C'est la ville dont je me souviens, et le jour où le minibus s'est arrêté.",
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
      "image_path": "/elearning/mfk-b1-m1/balance-choix.svg",
      "word": "un choix"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/cahier-comparaison.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/minibus-figuier.svg",
      "word": "un minibus"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/lettre-restes.svg",
      "word": "une lettre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit relatives : quatre où, quatre dont (lieu, moment, souvenir, possession)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis deux souvenirs à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mes souvenirs d''arrivée',
    'PE',
    $c$Objectif
Écrire un souvenir d'arrivée avec où et dont.

Consigne
Imitez le souvenir de Patrick Habimana.

Support — Souvenir de Patrick, photo pliée
Patrick Habimana — première arrivée à Rive-des-Saules
Le quartier où le minibus m'a laissé sentait le bois mouillé.
La ville dont je me souviens encore, c'est Val-des-Peupliers sous la brume.
Le jour où Karim a ouvert le Pavillon du Saule, Léa a trop parlé, de joie.
Les gens dont je parle aujourd'hui — Noura, Ibrahim, Félicie — sont devenus des appuis.
Le pavillon dont les fenêtres donnent sur le jardin reste simple, et c'est assez.
L'allée où Sami a posé son tambour apparaît sur toutes les photos de Léa.
La raison dont Aline m'avait prévenu, c'était la fatigue, pas le regret.
Je tiens à cette page : ailleurs a un visage, des prénoms, une heure.
Patrick
Pour le figuier, quand nous rentrerons raconter.
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick dit que la raison dont Aline l'avait prévenu, c'était le regret.",
  "correct": false,
  "explanation": "« c'était la fatigue, pas le regret. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que donnent les fenêtres du pavillon ?",
  "options": [
    {
      "text": "Sur le marché",
      "correct": false
    },
    {
      "text": "Sur le jardin",
      "correct": true
    },
    {
      "text": "Sur Radio Figuier",
      "correct": false
    },
    {
      "text": "Sur Rukiri-Nord",
      "correct": false
    }
  ],
  "explanation": "« dont les fenêtres donnent sur le jardin. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le quartier où",
      "right": "le minibus l'a laissé"
    },
    {
      "left": "la ville dont",
      "right": "il se souvient"
    },
    {
      "left": "le pavillon dont",
      "right": "les fenêtres"
    },
    {
      "left": "la raison dont",
      "right": "Aline l'avait prévenu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'allée ___ Sami a posé son tambour est sur les photos.",
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
    "ville",
    "dont",
    "je",
    "me",
    "souviens",
    "reste",
    "sous",
    "la",
    "brume",
    "."
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
  "hint": "Le motif dont on parle : pourquoi l'on est parti ce jour-là."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le pavillon où les fenêtres donnent sur le jardin est calme, et les voisins dont je parle sont Noura et Ibrahim.",
  "correct_sentence": "Le pavillon dont les fenêtres donnent sur le jardin est calme, et les voisins dont je parle sont Noura et Ibrahim.",
  "explanation": "Possession (les fenêtres du pavillon) → dont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/cahier-comparaison.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/minibus-figuier.svg",
      "word": "un minibus"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/lettre-restes.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/enveloppe-patrick.svg",
      "word": "une enveloppe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : dix lignes de souvenir, trois où, trois dont."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre souvenir, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Pronoms où et dont',
    'EL',
    $c$Objectif
Retenir le choix entre où et dont, et les verbes qui appellent de.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, où et dont
où = lieu (dans lequel) ou moment (le jour où, l'heure où)
le quartier où je vis ; la ville où nous sommes descendus
le jour où le minibus s'est arrêté ; l'heure où nous avons attendu
dont = de + qui / de + quoi / de + lequel
se souvenir de → la ville dont je me souviens
parler de → les gens dont je parle
avoir besoin de → l'aide dont nous avons besoin
possession : le pavillon dont les fenêtres donnent sur le jardin
On ne dit pas : la ville que je me souviens.
On ne dit pas : les gens que je parle (parler à → à qui ; parler de → dont).
Élision : le jour où elle arrive (où ne s'élide pas). Dont non plus.
Attention : je me souviens de la ville (pas je me souviens la ville).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « le jour qu'elle arrive » pour un moment.",
  "correct": false,
  "explanation": "Le jour où elle arrive. Où ne s'élide pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Les fenêtres du pavillon » se relie par…",
  "options": [
    {
      "text": "le pavillon où les fenêtres",
      "correct": false
    },
    {
      "text": "le pavillon dont les fenêtres",
      "correct": true
    },
    {
      "text": "le pavillon que les fenêtres",
      "correct": false
    },
    {
      "text": "le pavillon à qui les fenêtres",
      "correct": false
    }
  ],
  "explanation": "Possession → dont."
}$j$::jsonb,
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
      "left": "se souvenir de",
      "right": "dont"
    },
    {
      "left": "avoir besoin de",
      "right": "dont"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe me souviens ___ la ville clairement.",
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
    "l'aide",
    "dont",
    "nous",
    "avons",
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
  "word": "souviens",
  "hint": "Je me… de la ville : verbe de mémoire construit avec de."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je me souviens la ville clairement, et le quartier où j'arrive reste ocre.",
  "correct_sentence": "Je me souviens de la ville clairement, et le quartier où j'arrive reste ocre.",
  "explanation": "Se souvenir de + nom."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/minibus-figuier.svg",
      "word": "un minibus"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/lettre-restes.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/enveloppe-patrick.svg",
      "word": "une enveloppe"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/table-sources.svg",
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
  "prompt": "Transformez six phrases simples en relatives : trois où, trois dont."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six relatives."
}$j$::jsonb,
    9
  );

  -- ===== Deux rives, un choix =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Deux rives, un choix'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Deux rives, un choix', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Seuil ou Rive-des-Saules',
    'CO',
    $c$Objectif
Comparer deux rives en réemployant verbes prépositionnels et conditionnel.

Consigne
Lisez le dialogue. Qui penche vers quelle rive, et à quelles conditions ?

Support — Table des Sources, deux cartes face à face
Aline : D'un côté le Seuil des Sources ; de l'autre Rive-des-Saules. On compare, on ne juge pas.
Léa : Si je m'installais au Pavillon du Saule, je m'habituerais à l'eau, je tiendrais quand même au figuier.
Patrick : Je songerais à rester ici si le loyer là-bas dépendait trop d'un seul ami.
Marc : Le Seuil est plus calme le matin ; Rive-des-Saules est plus proche du pont et du minibus.
Hawa : Je voudrais les deux : compter sur Rose ici, m'adapter à Noura là-bas.
Joël : Si nous nous éloignions trop, Radio Figuier relierait encore les voix.
Rose : Je vous mets en garde : un choix n'efface pas l'autre rive, il la déplace.
Solange : Au Bureau des Escales, on tamponne un départ ; on ne tamponne pas un oubli.
Karim : Pourriez-vous essayer trois semaines au pavillon, avant de décider pour de bon ?
Lila : On devrait écrire chaque jeudi, bien que ce soit loin, afin que personne n'idéalise.
Mado : Si j'avais à choisir ce soir, je rêverais encore du banc ocre, et du saule aussi.
Dieudonné : Tenir aux deux rives, ce n'est pas hésiter : c'est refuser de couper.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose dit qu'un choix efface complètement l'autre rive.",
  "correct": false,
  "explanation": "Rose : un choix déplace l'autre rive, il ne l'efface pas."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que propose Karim avant de décider pour de bon ?",
  "options": [
    {
      "text": "Vendre le figuier",
      "correct": false
    },
    {
      "text": "Essayer trois semaines au pavillon",
      "correct": true
    },
    {
      "text": "Couper Radio Figuier",
      "correct": false
    },
    {
      "text": "Oublier le Seuil",
      "correct": false
    }
  ],
  "explanation": "Karim : essayer trois semaines avant de décider."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si je m'installais",
      "right": "je m'habituerais"
    },
    {
      "left": "songer à rester",
      "right": "Patrick"
    },
    {
      "left": "compter sur / s'adapter à",
      "right": "Hawa"
    },
    {
      "left": "tenir aux deux rives",
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
  "prompt": "Complétez :\nSi je m'installais au pavillon, je ___ au figuier. (tenir, cond.)",
  "answer": "tiendrais"
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
    "écrire",
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
  "word": "rives",
  "hint": "Deux berges : le Seuil d'un côté, les Saules de l'autre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si nous partions, je serai moins seul, et Léa tiendrait au figuier.",
  "correct_sentence": "Si nous partions, je serais moins seul, et Léa tiendrait au figuier.",
  "explanation": "Si + imparfait → serais, pas le futur serai."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/lettre-restes.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/enveloppe-patrick.svg",
      "word": "une enveloppe"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/table-sources.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/radio-figuier.svg",
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
  "prompt": "Notez trois comparaisons et trois phrases qui mêlent prépositionnel + conditionnel."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Si je m'installais au pavillon, je tiendrais au figuier. On devrait écrire chaque jeudi."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Cahier de comparaison',
    'CE',
    $c$Objectif
Lire une synthèse qui compare le Seuil et Rive-des-Saules.

Consigne
Lisez le cahier, sans aller trop vite.

Support — Cahier de comparaison, page partagée
Deux rives — critères (Aline, Marc, Lila)
Seuil des Sources : plus calme à l'aube, figuier, Table des Sources, Maison des Vents.
Rive-des-Saules : plus proche de l'eau, Pavillon du Saule, pont, minibus Figuier 7.
S'installer au Seuil, c'est rester dans ce que l'on connaît ; s'installer dans Rive-des-Saules, c'est s'adapter.
On s'habitue à la brume du pont ; on s'habitue aussi à l'ombre du figuier.
Le loyer là-bas dépend du jardin ; ici, on dépend davantage des habitudes partagées.
Léa rêverait d'un étage simple si Karim acceptait ; Patrick songerait à rester s'il fallait choisir trop vite.
On devrait compter sur Solange pour les tampons, sur Rose pour les mises en garde.
Bien que ce soit loin, Lila relayera les voix : s'éloigner n'est pas se taire.
Si nous tenions aux deux rives, nous pourrions essayer trois semaines, puis écrire.
Dieudonné : un choix clair vaut mieux qu'un silence flou ; pourtant, tenir aux deux n'est pas une faute.
Yvette : pourriez-vous relire ces lignes avant de poser la valise ?
Hawa : je voudrais que personne n'idéalise ailleurs, ni ici.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le cahier dit que s'éloigner, c'est forcément se taire.",
  "correct": false,
  "explanation": "« s'éloigner n'est pas se taire. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "De quoi le loyer de Rive-des-Saules dépend-il, d'après le cahier ?",
  "options": [
    {
      "text": "Du tambour de Sami",
      "correct": false
    },
    {
      "text": "Du jardin",
      "correct": true
    },
    {
      "text": "De Radio Figuier seulement",
      "correct": false
    },
    {
      "text": "Du figuier",
      "correct": false
    }
  ],
  "explanation": "« Le loyer là-bas dépend du jardin. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus calme à l'aube",
      "right": "Seuil"
    },
    {
      "left": "plus proche de l'eau",
      "right": "Rive-des-Saules"
    },
    {
      "left": "compter sur",
      "right": "Solange / Rose"
    },
    {
      "left": "essayer trois semaines",
      "right": "tenir aux deux rives"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn s'habitue ___ la brume du pont.",
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
    "S'éloigner",
    "n'est",
    "pas",
    "se",
    "taire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "comparer",
  "hint": "Mettre deux lieux l'un en face de l'autre, sans les juger trop vite."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le Seuil est plus calme, en revanche on s'habitue de la brume, et on rêve encore du saule.",
  "correct_sentence": "Le Seuil est plus calme, en revanche on s'habitue à la brume, et on rêve encore du saule.",
  "explanation": "S'habituer à, pas s'habituer de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/enveloppe-patrick.svg",
      "word": "une enveloppe"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/table-sources.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/maison-vents.svg",
      "word": "une maison"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez le cahier et ajoutez deux critères à vous, un par rive."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le cahier de comparaison, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire le choix des deux rives',
    'PO',
    $c$Objectif
Réemployer à l'oral prépositionnels, conditionnel et comparaison.

Consigne
Répétez, puis dites vers quelle rive vous pencheriez, et pourquoi.

Support — Modèles de synthèse, Aline et Dieudonné
Si je m'installais là-bas, je m'habituerais à l'eau.
Je tiendrais au figuier, même loin.
Je songerais à rester si le loyer dépendait trop d'un ami.
On devrait essayer trois semaines.
Je voudrais les deux rives, sans en trahir une.
Pourriez-vous nous laisser le temps de comparer ?
Le Seuil est plus calme ; Rive-des-Saules est plus proche du pont.
Je compte sur vous pour les jeudis.
Je m'adapterais aux voisins, bien que ce soit nouveau.
Je ne m'éloignerais pas de vous dans les lettres.
Dieudonné : tenir aux deux rives, ce n'est pas hésiter.
Léa : un choix déplace, il n'efface pas.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La synthèse réemploie le conditionnel et les verbes à préposition.",
  "correct": true,
  "explanation": "Si je m'installais, je m'habituerais, je tiendrais…"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase mélange correctement hypothèse et prépositionnel ?",
  "options": [
    {
      "text": "Si je m'installe, je tiendrai de figuier",
      "correct": false
    },
    {
      "text": "Si je m'installais là-bas, je m'habituerais à l'eau",
      "correct": true
    },
    {
      "text": "Si j'aurais le loyer, je dépends",
      "correct": false
    },
    {
      "text": "Je songe de rester si je partirai",
      "correct": false
    }
  ],
  "explanation": "Si + imparfait → conditionnel + s'habituer à."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "s'installer / s'habituer",
      "right": "conditionnel"
    },
    {
      "left": "tenir à / songer à",
      "right": "lien et pensée"
    },
    {
      "left": "plus calme / plus proche",
      "right": "comparaison"
    },
    {
      "left": "compter sur",
      "right": "les jeudis"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe songe ___ rester si le loyer dépend trop d'un ami.",
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
    "tiendrais",
    "au",
    "figuier",
    "même",
    "loin",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "serais",
  "hint": "Forme de être au mode du souhait, pas au futur."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je songe de rester, mais je pourrais aussi m'installer au pavillon.",
  "correct_sentence": "Je songe à rester, mais je pourrais aussi m'installer au pavillon.",
  "explanation": "Songer à, pas songer de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/table-sources.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/maison-vents.svg",
      "word": "une maison"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/bureau-escales.svg",
      "word": "un bureau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases de synthèse : quatre si, deux comparatifs, deux prépositionnels."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six premiers modèles, puis votre choix de rive."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon choix entre deux rives',
    'PE',
    $c$Objectif
Écrire une synthèse personnelle : comparer, souhaiter, mettre en garde.

Consigne
Imitez la synthèse de Rose Iradukunda.

Support — Synthèse de Rose, encre ocre
Rose Iradukunda — aux deux rives, sans en couper une
Si Léa s'installait au Pavillon du Saule, elle s'adapterait à Noura, et elle tiendrait au figuier.
Patrick songerait à rester ici si le loyer là-bas dépendait trop d'un seul salaire.
Je voudrais qu'ils essaient trois semaines : on devrait comparer avant d'idéaliser.
Le Seuil est plus calme à l'aube ; Rive-des-Saules est plus proche de l'eau et du pont.
Je les mets en garde : ne vous éloignez pas de ceux qui restent, comptez sur Lila.
Pourriez-vous écrire chaque jeudi, bien que ce soit loin ?
Je rêverais d'un jeudi ici et d'un jeudi là-bas, si le minibus Figuier 7 le permettait.
Tenir aux deux rives n'est pas hésiter : c'est refuser d'effacer une cour.
Aline, Solange, Karim : nous comptons sur vous pour que le choix reste lisible.
Rose
Seuil des Sources — copie pour le banc et pour le saule
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose dit que tenir aux deux rives, c'est hésiter.",
  "correct": false,
  "explanation": "« Tenir aux deux rives n'est pas hésiter. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que voudrait Rose que Léa et Patrick fassent ?",
  "options": [
    {
      "text": "Couper Radio Figuier",
      "correct": false
    },
    {
      "text": "Essayer trois semaines avant d'idéaliser",
      "correct": true
    },
    {
      "text": "Vendre les clés",
      "correct": false
    },
    {
      "text": "Oublier Aline",
      "correct": false
    }
  ],
  "explanation": "« Je voudrais qu'ils essaient trois semaines. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si Léa s'installait",
      "right": "elle s'adapterait"
    },
    {
      "left": "plus calme / plus proche",
      "right": "Seuil / Rive-des-Saules"
    },
    {
      "left": "mettre en garde",
      "right": "ne pas s'éloigner des restants"
    },
    {
      "left": "compter sur",
      "right": "Lila / Aline"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPourriez-vous écrire chaque jeudi, bien que ce ___ loin ?",
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
    "Tenir",
    "aux",
    "deux",
    "rives",
    "n'est",
    "pas",
    "hésiter",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tiens",
  "hint": "Je… à ce figuier : ce lieu compte beaucoup pour moi."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien qu'elle est attachée au Seuil, Léa s'adapterait à Rive-des-Saules, et Patrick compterait sur Aline.",
  "correct_sentence": "Bien qu'elle soit attachée au Seuil, Léa s'adapterait à Rive-des-Saules, et Patrick compterait sur Aline.",
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
      "image_path": "/elearning/mfk-b1-m1/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/maison-vents.svg",
      "word": "une maison"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/bureau-escales.svg",
      "word": "un bureau"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/nuage-ailleurs.svg",
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
  "prompt": "Imitez : une synthèse de dix lignes, comparaison, si, prépositionnels, une mise en garde."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre synthèse, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Synthèse : prépositionnels et conditionnel',
    'EL',
    $c$Objectif
Relier les verbes prépositionnels, le conditionnel et les comparatifs du choix.

Consigne
Apprenez la fiche.

Support — Fiche de synthèse des deux rives
Réemploi 1 — verbes : s'installer à/dans, s'habituer à, s'adapter à,
dépendre de, rêver de, tenir à, songer à, s'éloigner de, compter sur
Réemploi 2 — conditionnel : je voudrais, j'aimerais, pourriez-vous, on devrait
Réemploi 3 — si + imparfait → conditionnel : si je m'installais, je m'habituerais
Réemploi 4 — comparaison : plus calme que, plus proche que, moins loin que
Ne pas confondre : je serai (futur) / je serais (cond.)
je ferai (futur, 1 r) / je ferais (cond.)
je pourrai (futur, 2 r) / je pourrais (cond.)
Bien que + subjonctif : bien que ce soit loin, bien qu'elle tienne au figuier
À + le = au : au Seuil, au pavillon, au milieu du pont
Un choix déplace une rive ; il n'efface pas l'autre.
Mettre en garde reste utile : ailleurs n'est pas un palais.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je ferai » s'écrit avec deux r.",
  "correct": false,
  "explanation": "Futur de faire : ferai, un seul r."
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
      "text": "je serai (cond.) / je serais (futur)",
      "correct": false
    },
    {
      "text": "je pourai (futur) / je pourrais (cond.)",
      "correct": false
    },
    {
      "text": "je ferai (futur) / je serais (cond.)",
      "correct": true
    },
    {
      "text": "je faut / nous faudrait",
      "correct": false
    }
  ],
  "explanation": "Ferai = futur. Serais = conditionnel."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si je m'installais",
      "right": "je m'habituerais"
    },
    {
      "left": "tenir à",
      "right": "un figuier / un jeudi"
    },
    {
      "left": "bien que",
      "right": "subjonctif"
    },
    {
      "left": "plus calme que",
      "right": "le Seuil à l'aube"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDemain, je ___ le choix. (faire, futur)",
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
    "Bien",
    "que",
    "ce",
    "soit",
    "loin",
    "nous",
    "écrirons",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "songer",
  "hint": "Y penser longtemps, sans décider encore, avant de partir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ferrai le choix demain, et je tiendrai à vous écrire.",
  "correct_sentence": "Je ferai le choix demain, et je tiendrai à vous écrire.",
  "explanation": "Futur de faire : ferai, un seul r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/maison-vents.svg",
      "word": "une maison"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/bureau-escales.svg",
      "word": "un bureau"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/nuage-ailleurs.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/soleil-chez-soi.svg",
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
  "prompt": "Rédigez un mini-tableau : cinq verbes, cinq conditionnels, deux si, deux comparatifs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et quatre phrases de réemploi."
}$j$::jsonb,
    9
  );

  -- ===== Écrire à ceux qui restent =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Écrire à ceux qui restent'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Écrire à ceux qui restent', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Préparer la lettre du jeudi',
    'CO',
    $c$Objectif
Comprendre comment on relie les deux rives par une lettre polie.

Consigne
Lisez le dialogue. À qui écrit-on, et quelles formules entend-on ?

Support — Cour du figuier, enveloppes ocre
Aline : Vous écrirez à ceux qui restent : Rose, Joël, Marc, Hawa, et à moi.
Léa : J'aimerais commencer par « Chers amis du figuier », pas par un « salut » trop sec.
Patrick : Pourriez-vous relire la formule de clôture ? Je voudrais rester poli sans être raide.
Rose : On devrait raconter le pavillon sans idéaliser : le loyer, Noura, la brume du pont.
Joël : Tenez à nous dire l'heure où le minibus arrive, et les gens dont vous parlez.
Hawa : Comptez sur Radio Figuier si la lettre tarde ; Lila relayera un mot court.
Solange : Veuillez dater : Seuil ou Val-des-Peupliers, afin que l'on sache d'où vous parlez.
Karim : Si vous vous installiez vraiment, vous nous mettriez en garde contre nos illusions.
Mado : Reliez les deux rives : un détail d'ici, un détail de là-bas, dans chaque paragraphe.
Sami : Je voudrais que vous n'oubliiez pas le tambour du jeudi, même loin.
Yvette : Recevez, je vous prie… ou Bien à vous, selon le degré de proximité.
Lila : Une lettre polie n'est pas froide : elle tient à la personne, elle ne compte pas les lignes.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa préfère « Chers amis du figuier » à un salut trop sec.",
  "correct": true,
  "explanation": "Première proposition de Léa."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que fera Lila si la lettre tarde, d'après Hawa ?",
  "options": [
    {
      "text": "Fermer le pavillon",
      "correct": false
    },
    {
      "text": "Relayer un mot court à la radio",
      "correct": true
    },
    {
      "text": "Cacher les enveloppes",
      "correct": false
    },
    {
      "text": "Interdire le jeudi",
      "correct": false
    }
  ],
  "explanation": "Hawa : Radio Figuier relayera un mot court."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "chers amis du figuier",
      "right": "ouverture"
    },
    {
      "left": "veuillez dater",
      "right": "Solange"
    },
    {
      "left": "reliez les deux rives",
      "right": "Mado"
    },
    {
      "left": "bien à vous",
      "right": "clôture proche"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVeuillez dater, afin que l'on sache ___ vous parlez.",
  "answer": "d'où"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Chers",
    "amis",
    "du",
    "figuier",
    "nous",
    "vous",
    "écrivons",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "enveloppe",
  "hint": "Papier ocre où l'on glisse la lettre pour ceux de la cour."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Veuillez agréer, chers amis, mes salutations, et je vous écrit depuis le pavillon.",
  "correct_sentence": "Veuillez agréer, chers amis, mes salutations, et je vous écris depuis le pavillon.",
  "explanation": "Présent : j'écris, pas je écrit."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/bureau-escales.svg",
      "word": "un bureau"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/nuage-ailleurs.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/soleil-chez-soi.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/figuier-racines.svg",
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
  "prompt": "Notez trois formules d'ouverture ou de clôture et deux conseils pour relier les rives."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Chers amis du figuier. Pourriez-vous relire la clôture ? Nous tenons à vous écrire chaque jeudi."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Lettre-modèle vers le figuier',
    'CE',
    $c$Objectif
Lire une lettre polie qui relie Rive-des-Saules et le Seuil.

Consigne
Lisez la lettre, sans aller trop vite.

Support — Lettre de Léa et Patrick aux amis du figuier
Val-des-Peupliers, Rive-des-Saules — jeudi
Chers amis du figuier,
Nous vous écrivons depuis le Pavillon du Saule, où le jardin sent déjà l'eau.
Nous aimerions que cette lettre tienne lieu de jeudi, bien que ce soit loin.
Le quartier dont nous commençons à nous souvenir s'appelle Rive-des-Saules ; le banc dont nous parlons encore, c'est le vôtre.
Si vous veniez trois jours, vous vous habitueriez au pont, et nous tiendrions à vous montrer Noura et Ibrahim.
Pourriez-vous dire à Solange que les tampons sont lisibles, et à Lila que nous comptons sur un mot radio si besoin ?
On devrait aussi rassurer Rose : nous ne nous éloignons pas de vous dans le cœur.
Patrick voudrait ajouter que le loyer dépend du jardin, pas d'un palais.
Recevez, chers amis, nos salutations fidèles. Bien à vous, sous le saule comme sous le figuier.
Léa Niyonzima et Patrick Habimana
Copie : Aline Uwase, Karim Bamba
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La lettre dit que le loyer dépend d'un palais.",
  "correct": false,
  "explanation": "Patrick : le loyer dépend du jardin, pas d'un palais."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que devrait-on dire à Rose, d'après la lettre ?",
  "options": [
    {
      "text": "Qu'ils vendent le figuier",
      "correct": false
    },
    {
      "text": "Qu'ils ne s'éloignent pas dans le cœur",
      "correct": true
    },
    {
      "text": "Que Radio Figuier ferme",
      "correct": false
    },
    {
      "text": "Que Karim refuse les clés",
      "correct": false
    }
  ],
  "explanation": "« nous ne nous éloignons pas de vous dans le cœur. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "chers amis du figuier",
      "right": "ouverture"
    },
    {
      "left": "le quartier dont",
      "right": "ils se souviennent"
    },
    {
      "left": "pourriez-vous dire",
      "right": "Solange / Lila"
    },
    {
      "left": "bien à vous",
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
  "prompt": "Complétez :\nNous aimerions que cette lettre tienne lieu de jeudi, bien que ce ___ loin.",
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
    "Nous",
    "vous",
    "écrivons",
    "depuis",
    "le",
    "pavillon",
    "."
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
  "hint": "Ouverture et clôture d'une lettre : veuillez, cordialement, bien à vous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous vous embrassons fort, et on compte à votre réponse sous le figuier.",
  "correct_sentence": "Nous vous embrassons fort, et on compte sur votre réponse sous le figuier.",
  "explanation": "Compter sur, pas compter à."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/nuage-ailleurs.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/soleil-chez-soi.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/figuier-racines.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/horloge-depart.svg",
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
  "prompt": "Recopiez la lettre et soulignez politesse, où/dont, et les deux rives."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la lettre-modèle, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire les formules de la lettre',
    'PO',
    $c$Objectif
Prononcer des formules de politesse et relier à l'oral les deux rives.

Consigne
Répétez, puis dictez une mini-lettre à un ami du figuier.

Support — Modèles de Lila et d'Aline
Chers amis du figuier,
Nous vous écrivons depuis l'autre rive.
Nous aimerions avoir de vos nouvelles.
Pourriez-vous lire cette lettre au banc, le jeudi ?
Nous tenons à vous rassurer : nous ne vous oublions pas.
Bien que ce soit loin, nous comptons sur vous.
Recevez, je vous prie, nos salutations fidèles.
Bien à vous.
Cordialement, si le ton est plus sage.
Aline : une formule n'est pas un masque ; elle protège le lien.
Patrick : relier, c'est un détail d'ici et un détail de là-bas.
Rose : on devrait finir par un prénom, pas par un silence.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Recevez, je vous prie » est une clôture plus formelle que « Bien à vous ».",
  "correct": true,
  "explanation": "Yvette et Lila distinguent les degrés de proximité."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle ouverture convient aux amis du figuier ?",
  "options": [
    {
      "text": "À qui de droit seulement",
      "correct": false
    },
    {
      "text": "Chers amis du figuier",
      "correct": true
    },
    {
      "text": "Urgent : partez",
      "correct": false
    },
    {
      "text": "Pas de formule",
      "correct": false
    }
  ],
  "explanation": "Ouverture choisie par Léa et reprise ici."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "chers amis",
      "right": "ouverture"
    },
    {
      "left": "nous aimerions",
      "right": "souhait"
    },
    {
      "left": "pourriez-vous",
      "right": "demande polie"
    },
    {
      "left": "bien à vous",
      "right": "clôture proche"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous tenons ___ vous rassurer.",
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
    "Recevez",
    "je",
    "vous",
    "prie",
    "nos",
    "salutations",
    "fidèles",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "relier",
  "hint": "Garder le lien entre les deux berges malgré la distance."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je vous prie d'agréer cette lettre, et je tiens de ce lien entre les deux rives.",
  "correct_sentence": "Je vous prie d'agréer cette lettre, et je tiens à ce lien entre les deux rives.",
  "explanation": "Tenir à un lien, pas tenir de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/soleil-chez-soi.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/figuier-racines.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/horloge-depart.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/criteres-quartier.svg",
      "word": "des critères"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six formules : deux ouvertures, deux demandes, deux clôtures."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premières formules, puis une mini-lettre à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma lettre à ceux qui restent',
    'PE',
    $c$Objectif
Écrire une lettre polie qui relie le Pavillon du Saule et le figuier.

Consigne
Imitez la lettre de Léa Niyonzima.

Support — Lettre de Léa, encre du jeudi
Val-des-Peupliers, Pavillon du Saule
Chers amis du figuier — Rose, Joël, Marc, Hawa, Aline,
Je vous écris afin que vous soyez rassurés : nous nous habituons à l'eau, et nous tenons à vous.
Le quartier où nous dormons s'appelle Rive-des-Saules ; la cour dont nous parlons le soir, c'est encore la vôtre.
J'aimerais que vous lisiez cette lettre au banc, le jeudi, même s'il bruine.
Pourriez-vous dire à Solange et à Lila que nous comptons sur un mot, lettre ou radio ?
Si vous veniez, vous vous adapteriez au pont, et Patrick voudrait vous montrer le jardin du saule.
On devrait aussi prévenir Félicie : trois chambres, un loyer qui dépend du jardin.
Bien que ce soit loin, nous ne nous éloignons pas de vous.
Recevez, chers amis, nos salutations fidèles. Bien à vous, des deux rives.
Léa Niyonzima
Patrick signe aussi, un peu trop vite, de joie.
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa demande qu'on lise la lettre au banc le jeudi.",
  "correct": true,
  "explanation": "« que vous lisiez cette lettre au banc, le jeudi. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "De quoi le loyer dépend-il, dans la lettre de Léa ?",
  "options": [
    {
      "text": "Du tambour",
      "correct": false
    },
    {
      "text": "Du jardin",
      "correct": true
    },
    {
      "text": "De Port-de-Brume",
      "correct": false
    },
    {
      "text": "D'un palais",
      "correct": false
    }
  ],
  "explanation": "« un loyer qui dépend du jardin. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "chers amis du figuier",
      "right": "ouverture"
    },
    {
      "left": "le quartier où",
      "right": "ils dorment"
    },
    {
      "left": "pourriez-vous dire",
      "right": "Solange et Lila"
    },
    {
      "left": "bien à vous",
      "right": "des deux rives"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe vous écris afin que vous ___ rassurés. (être, subj.)",
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
    "Bien",
    "que",
    "ce",
    "soit",
    "loin",
    "nous",
    "tenons",
    "à",
    "vous",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "figuier",
  "hint": "L'arbre de la cour : on écrit à ceux qui restent dessous."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Chers amis du figuier, je vous écris afin que vous soyez rassurés, et je m'habitue de l'odeur du saule.",
  "correct_sentence": "Chers amis du figuier, je vous écris afin que vous soyez rassurés, et je m'habitue à l'odeur du saule.",
  "explanation": "S'habituer à, pas s'habituer de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/figuier-racines.svg",
      "word": "un figuier"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/horloge-depart.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/criteres-quartier.svg",
      "word": "des critères"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/carte-rive-saules.svg",
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
  "prompt": "Imitez : une lettre de dix à douze lignes, polie, qui relie les deux rives."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre lettre, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Politesse de la lettre et lien des rives',
    'EL',
    $c$Objectif
Retenir les formules de lettre et les articulations qui relient deux lieux.

Consigne
Apprenez la fiche.

Support — Fiche de Lila, lettres du jeudi
Ouvertures : Chers amis, Chère Aline, Chers amis du figuier
Souhaits : nous aimerions, je voudrais que + subjonctif (je voudrais que vous soyez)
Demandes : pourriez-vous + infinitif ? ; je vous prie de…
Lien : afin que + subj. ; bien que + subj. ; même si + indicatif
Relier les rives : un détail d'ici + un détail de là-bas ; où / dont pour les souvenirs
Clôtures : Recevez, je vous prie, nos salutations ; Bien à vous ; Cordialement
Date et lieu : Val-des-Peupliers, Rive-des-Saules — jeudi / Seuil des Sources
À + le = au Seuil, au pavillon. De + le = du jardin, du figuier.
Ne pas écrire : je vous écrit. On écrit : je vous écris.
Compter sur une réponse, tenir à un lien, s'habituer à un silence nouveau.
Une lettre polie n'est pas froide : elle protège ceux qui restent et ceux qui partent.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « je vous écrit » à la première personne.",
  "correct": false,
  "explanation": "Je vous écris."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Afin que vous soyez rassurés » emploie…",
  "options": [
    {
      "text": "l'indicatif futur",
      "correct": false
    },
    {
      "text": "le subjonctif",
      "correct": true
    },
    {
      "text": "l'impératif seulement",
      "correct": false
    },
    {
      "text": "le passé composé",
      "correct": false
    }
  ],
  "explanation": "Afin que + subjonctif."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "chers amis",
      "right": "ouverture"
    },
    {
      "left": "afin que / bien que",
      "right": "subjonctif"
    },
    {
      "left": "pourriez-vous",
      "right": "demande"
    },
    {
      "left": "bien à vous",
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
  "prompt": "Complétez :\nJe vous ___ depuis le pavillon. (écrire, présent)",
  "answer": "écris"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Recevez",
    "je",
    "vous",
    "prie",
    "nos",
    "salutations",
    "."
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
  "hint": "Ton d'une lettre : formules pour ne pas brusquer ceux qui restent."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "À le Seuil, le figuier attend encore vos nouvelles, et nous relions les deux rives.",
  "correct_sentence": "Au Seuil, le figuier attend encore vos nouvelles, et nous relions les deux rives.",
  "explanation": "À + le = au."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b1-m1/horloge-depart.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/criteres-quartier.svg",
      "word": "des critères"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/carte-rive-saules.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-b1-m1/valise-lea.svg",
      "word": "une valise"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Rédigez un tableau : ouvertures, souhaits, demandes, liens (afin que / bien que), clôtures."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et une mini-lettre de cinq lignes."
}$j$::jsonb,
    9
  );

END;
$$;
