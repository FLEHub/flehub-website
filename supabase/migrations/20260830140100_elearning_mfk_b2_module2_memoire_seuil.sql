/*
  Seed eLearning MFK — B2 — Mémoire du Seuil

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-b2-m2/
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
  v_module_title text := 'B2 — Mémoire du Seuil';
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
      'Grande étape B2-2 : former des hypothèses sur le passé, relier un métier à une société qui change, nommer des lieux d''enfance, comparer trois voix du récit, ouvrir les archives du Cahier du chemin et tenir une table ronde — « ce que le figuier a vu » — avec Sami, Mado, Dieudonné, Aline Uwase et Radio Figuier, au Seuil des Sources (Rukiri-Nord).',
      'B2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape B2-2 : former des hypothèses sur le passé, relier un métier à une société qui change, nommer des lieux d''enfance, comparer trois voix du récit, ouvrir les archives du Cahier du chemin et tenir une table ronde — « ce que le figuier a vu » — avec Sami, Mado, Dieudonné, Aline Uwase et Radio Figuier, au Seuil des Sources (Rukiri-Nord).',
      cefr_level = 'B2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Hypothèses sur le passé =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Hypothèses sur le passé'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Hypothèses sur le passé', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Si j''avais su, sous le figuier',
    'CO',
    $c$Objectif
Repérer si + plus-que-parfait et le conditionnel passé pour une hypothèse non réalisée.

Consigne
Lisez l'entretien (à écouter avec l'enseignant). Quelles actions n'ont pas eu lieu ?

Support — Entretien sous le figuier, photos ocre
Sami : Si j'avais su que le Cahier du chemin dormait si longtemps, j'aurais ouvert plus tôt.
Mado : Si nous avions écouté les anciens avant la pluie, nous aurions noté d'autres noms.
Aline Uwase : Attention : si + plus-que-parfait, ensuite le conditionnel passé. Pas « si j'aurais ».
Léa Niyonzima : Si j'avais su le pont si glissant, je serais restée trois jeudis de plus.
Patrick Habimana : Si tu m'avais prévenu, j'aurais porté la valise autrement, moins vite.
Marc Nkurunziza : Si Lila avait enregistré Sami à temps, Radio Figuier aurait une archive, pas seulement un écho.
Hawa Diallo : Si nous n'avions pas attendu, nous aurions perdu moins de voix.
Joël Mugisha : Si j'avais su le vent de ce soir-là, j'aurais accroché moins haut.
Rose Iradukunda : Si l'on m'avait dit le nom du premier lin, j'aurais cousu une pièce de plus, pour la cour.
Solange Mukamana : Si le tampon avait été posé, nous saurions la date. Là, nous hypothesons.
Karim Bamba : Si j'avais su qui payait l'huile, j'aurais moins crié sur le prix.
Lila Sow : Si j'avais tendu le micro plus tôt, j'aurais moins de regrets, plus de bandes.
Félicie : Si Dieudonné avait réparé la table avant, le cahier n'aurait pas glissé.
Yvette : Si nous avions nommé les dangers, quelqu'un se serait moins brûlé les doigts.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline accepte la tournure « si j'aurais su » comme correcte.",
  "correct": false,
  "explanation": "Aline : si + plus-que-parfait, ensuite le conditionnel passé. Pas « si j'aurais »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que dit Sami qu'il aurait fait, s'il avait su pour le cahier ?",
  "options": [
    {
      "text": "Il aurait fermé le figuier",
      "correct": false
    },
    {
      "text": "Il aurait ouvert plus tôt",
      "correct": true
    },
    {
      "text": "Il aurait vendu les photos",
      "correct": false
    },
    {
      "text": "Il aurait quitté Rukiri-Nord",
      "correct": false
    }
  ],
  "explanation": "Si j'avais su […], j'aurais ouvert plus tôt."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si j'avais su",
      "right": "plus-que-parfait"
    },
    {
      "left": "j'aurais ouvert",
      "right": "conditionnel passé"
    },
    {
      "left": "si nous avions écouté",
      "right": "hypothèse non réalisée"
    },
    {
      "left": "pas si j'aurais",
      "right": "erreur fréquente"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi j'avais su, j'___ ouvert plus tôt. (avoir, cond. passé)",
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
    "Si",
    "j'avais",
    "su",
    "j'aurais",
    "ouvert",
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
  "word": "hypothese",
  "hint": "Idée sur ce qui a pu se passer, sans preuve fermée. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si j'aurais su que le cahier dormait, j'aurais ouvert plus tôt, et Mado aurait noté les noms.",
  "correct_sentence": "Si j'avais su que le cahier dormait, j'aurais ouvert plus tôt, et Mado aurait noté les noms.",
  "explanation": "Si + plus-que-parfait : si j'avais su, pas si j'aurais su."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/hypothese-passe.svg",
      "word": "une hypothèse"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/si-pqp.svg",
      "word": "un plus-que-parfait"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/conditionnel-passe.svg",
      "word": "un conditionnel"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/photo-ancienne.svg",
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
  "prompt": "Relevez cinq phrases si + PQP et le conditionnel passé qui les suit."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Si j'avais su, j'aurais ouvert plus tôt. Si nous avions écouté, nous aurions noté."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Hypothèses sur une pluie oubliée',
    'CE',
    $c$Objectif
Lire un article qui forme des hypothèses précises sur un passé non prouvé.

Consigne
Lisez l'article de Mado, sans aller trop vite.

Support — Article de Mado, feuille pour le Cahier du chemin
On ne sait pas tout de la pluie qui a taché le premier cahier. On peut pourtant former des hypothèses avec soin.
Si Sami avait ouvert le coffre avant l'orage, les pages n'auraient pas gondolé.
Si Lila avait tendu le micro ce soir-là, Radio Figuier aurait une voix, pas seulement un écho.
Si Dieudonné avait calé la table, le bol de Félicie n'aurait pas versé sur l'encre.
Aline écrit : parler du passé avec précision, ce n'est pas inventer une légende.
C'est dire ce que l'on tient (un tampon manquant) et ce que l'on imagine (une date).
Marc ajoute que « si j'avais su » n'est pas un reproche : c'est une grammaire du regret utile.
Si nous avions noté qui payait l'huile, Karim crierait moins aujourd'hui.
Si Rose avait su le nom du premier lin, elle aurait cousu une pièce pour la cour, dit-elle.
Léa et Patrick, s'ils avaient su le pont si glissant, seraient restés un jeudi de plus.
Yvette nuance : si l'on avait nommé le danger, quelqu'un se serait moins brûlé.
Solange refuse les dates inventées : on forme une hypothèse, on n'imprime pas un faux tampon.
Joël, s'il avait su le vent, aurait accroché moins haut : voilà une hypothèse utile pour demain.
Nous relirons cet article lorsque nous aurons ouvert le coffre, pas avant d'avoir les mains propres.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Solange accepte d'imprimer un tampon avec une date inventée.",
  "correct": false,
  "explanation": "On forme une hypothèse, on n'imprime pas un faux tampon."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Aline, parler du passé avec précision, c'est…",
  "options": [
    {
      "text": "Inventer une légende complète",
      "correct": false
    },
    {
      "text": "Dire ce que l'on tient et ce que l'on imagine",
      "correct": true
    },
    {
      "text": "Se taire",
      "correct": false
    },
    {
      "text": "Corriger Sami seulement",
      "correct": false
    }
  ],
  "explanation": "Dire ce que l'on tient (tampon manquant) et ce que l'on imagine (une date)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si Sami avait ouvert",
      "right": "les pages n'auraient pas gondolé"
    },
    {
      "left": "si Lila avait tendu",
      "right": "une voix, pas un écho"
    },
    {
      "left": "si Dieudonné avait calé",
      "right": "l'encre sauvée"
    },
    {
      "left": "si Joël avait su le vent",
      "right": "moins haut"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi nous avions noté qui payait, Karim ___ moins aujourd'hui. (crier, cond.)",
  "answer": "crierait"
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
    "Sami",
    "avait",
    "ouvert",
    "les",
    "pages",
    "tiendraient",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "savais",
  "hint": "Imparfait de savoir, personne je, dans une hypothèse non réalisée."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si Lila aurait tendu le micro ce soir-là, Radio Figuier aurait une voix, et Sami parlerait encore.",
  "correct_sentence": "Si Lila avait tendu le micro ce soir-là, Radio Figuier aurait une voix, et Sami parlerait encore.",
  "explanation": "Si + plus-que-parfait : si Lila avait tendu, pas si Lila aurait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/si-pqp.svg",
      "word": "un plus-que-parfait"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/conditionnel-passe.svg",
      "word": "un conditionnel"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/photo-ancienne.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/metier-evolution.svg",
      "word": "un métier"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Soulignez six hypothèses et dites ce qui est tenu, ce qui est imaginé."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'article, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire si j''avais su, j''aurais',
    'PO',
    $c$Objectif
Prononcer des hypothèses non réalisées avec si + PQP et le conditionnel passé.

Consigne
Répétez les modèles, puis formulez trois regrets utiles du Seuil.

Support — Modèles d'Aline et de Sami, banc ocre
Si j'avais su, j'aurais ouvert plus tôt.
Si nous avions écouté, nous aurions noté les noms.
Si tu m'avais prévenu, j'aurais ralenti.
Si Lila avait enregistré, nous aurions une archive.
Si Dieudonné avait calé la table, le cahier n'aurait pas glissé.
Si j'avais su le vent, j'aurais accroché moins haut.
Si elle avait nommé le danger, quelqu'un se serait moins brûlé.
Si vous aviez tamponné, nous saurions la date.
Je serais resté un jeudi de plus si j'avais su le pont.
Nous n'aurions pas perdu ces voix si nous n'avions pas attendu.
Aline : jamais « si j'aurais su ».
Sami : le regret sert demain, pas seulement à se plaindre.
Mado : dites ce que vous tenez, puis ce que vous imaginez.
Lila : une hypothèse, une pause, le micro près de la bouche.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « si j'aurais su » à l'oral soigné du Seuil.",
  "correct": false,
  "explanation": "Aline : jamais « si j'aurais su ». On dit si j'avais su."
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
      "text": "Si j'aurais su, j'ouvrais",
      "correct": false
    },
    {
      "text": "Si j'avais su, j'aurais ouvert plus tôt",
      "correct": true
    },
    {
      "text": "Si je saurai, j'aurais ouvert",
      "correct": false
    },
    {
      "text": "Si j'aurais, j'avais ouvert",
      "correct": false
    }
  ],
  "explanation": "Si + PQP, conditionnel passé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si j'avais su",
      "right": "j'aurais ouvert"
    },
    {
      "left": "si nous avions écouté",
      "right": "nous aurions noté"
    },
    {
      "left": "si elle avait nommé",
      "right": "se serait moins brûlé"
    },
    {
      "left": "jamais",
      "right": "si j'aurais"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi tu m'avais prévenu, j'___ ralenti. (avoir, cond. passé)",
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
    "Si",
    "nous",
    "avions",
    "écouté",
    "nous",
    "aurions",
    "noté",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "aurions",
  "hint": "Conditionnel passé, personne nous, pour l'action qui n'a pas eu lieu."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si j'avais su le pont, je serai resté un jeudi de plus, et Léa aurait écrit.",
  "correct_sentence": "Si j'avais su le pont, je serais resté un jeudi de plus, et Léa aurait écrit.",
  "explanation": "Conditionnel passé avec être : je serais resté, pas je serai resté."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/conditionnel-passe.svg",
      "word": "un conditionnel"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/photo-ancienne.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/metier-evolution.svg",
      "word": "un métier"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/societe-change.svg",
      "word": "une société"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit phrases : si + PQP + conditionnel passé, sur la mémoire du Seuil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis trois regrets utiles à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mes hypothèses sur le coffre',
    'PE',
    $c$Objectif
Écrire un texte d'hypothèses précises avec si + PQP et le conditionnel passé.

Consigne
Imitez la note de Sami.

Support — Note de Sami, photo glissée dans le cahier
Sami — Seuil des Sources, Rukiri-Nord
Si j'avais su que le coffre du Cahier du chemin dormait sous la table, j'aurais appelé Dieudonné dès l'aube.
Si nous avions écouté les anciens avant la pluie, nous aurions plus de noms et moins de taches.
Si Lila avait tendu le micro ce soir-là, Radio Figuier aurait une archive, pas seulement un écho.
Je tiens ceci : le tampon manque. J'imagine ceci : une date juste après la grande pluie.
Si Karim avait su qui payait l'huile, il aurait moins crié, et nous aurions mieux pesé.
Si Rose avait entendu le nom du premier lin, elle aurait cousu une pièce pour la cour.
Léa, si elle avait su le pont, serait restée un jeudi ; Patrick aussi, je crois.
Aline a raison : ce n'est pas une légende. C'est une grammaire pour ne plus perdre.
Si j'avais ouvert plus tôt, j'aurais moins de regrets, plus de pages.
Voilà ce que je peux dire, sans faux tampon.
Sami
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Sami prétend connaître la date exacte et l'imprimer au tampon.",
  "correct": false,
  "explanation": "Il tient le tampon manquant ; il imagine une date. Pas de faux tampon."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que tiendra Sami, et qu'imagine-t-il ?",
  "options": [
    {
      "text": "Il tient une légende, il imagine un pont",
      "correct": false
    },
    {
      "text": "Il tient le tampon manquant, il imagine une date après la pluie",
      "correct": true
    },
    {
      "text": "Il ne tient rien",
      "correct": false
    },
    {
      "text": "Il tient Radio Figuier",
      "correct": false
    }
  ],
  "explanation": "Je tiens ceci : le tampon manque. J'imagine ceci : une date…"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si j'avais su",
      "right": "j'aurais appelé Dieudonné"
    },
    {
      "left": "si nous avions écouté",
      "right": "plus de noms"
    },
    {
      "left": "si Lila avait tendu",
      "right": "une archive"
    },
    {
      "left": "tenir / imaginer",
      "right": "tampon / date"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi Lila avait tendu le micro, Radio Figuier ___ une archive. (avoir, cond.)",
  "answer": "aurait"
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
    "tiens",
    "ceci",
    "le",
    "tampon",
    "manque",
    "."
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
  "hint": "Sentiment : on n'a pas agi, on imagine l'autre suite possible."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si j'aurais ouvert plus tôt, j'aurais moins de regrets, et le cahier serait plus lisible.",
  "correct_sentence": "Si j'avais ouvert plus tôt, j'aurais moins de regrets, et le cahier serait plus lisible.",
  "explanation": "Si + plus-que-parfait : si j'avais ouvert."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/photo-ancienne.svg",
      "word": "une photo"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/metier-evolution.svg",
      "word": "un métier"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/societe-change.svg",
      "word": "une société"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/atelier-avant.svg",
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
  "prompt": "Imitez : douze lignes, quatre si + PQP, une phrase « je tiens / j'imagine »."
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
    'EL — Si + plus-que-parfait, conditionnel passé',
    'EL',
    $c$Objectif
Retenir la construction des hypothèses sur un passé non réalisé.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline Uwase, photo ocre
Parler du passé avec précision : séparer ce que l'on tient et ce que l'on imagine.
Hypothèse non réalisée : Si + plus-que-parfait, + conditionnel passé.
Si j'avais su, j'aurais ouvert. Si nous avions écouté, nous aurions noté.
Si elle avait nommé le danger, quelqu'un se serait moins brûlé. (être + participe)
Formation du PQP : avoir / être à l'imparfait + participe (j'avais su, elle était partie).
Formation du conditionnel passé : avoir / être au conditionnel présent + participe (j'aurais ouvert, je serais resté).
Erreur fréquente : Si j'aurais su → Si j'avais su.
Ne pas mettre le conditionnel dans la proposition en si.
Je serai (futur réel) ≠ je serais (conditionnel) ≠ je serais resté (cond. passé, être).
Je ferai (1 r) ; je pourrai (2 r) ; il faut (3e pers.).
Le regret sert demain : Joël accrochera moins haut s'il a compris le vent.
Pas de faux tampon : on forme une hypothèse, on n'imprime pas une date inventée.
Cahier du chemin, Radio Figuier, table de Dieudonné : trois lieux pour vérifier.
Il faut un exemple tenu, un exemple imaginé, dans chaque texte.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le conditionnel se place dans la proposition introduite par si.",
  "correct": false,
  "explanation": "Jamais si j'aurais. Si + PQP ; le conditionnel est dans l'autre proposition."
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
      "text": "Si j'aurais su, j'avais ouvert",
      "correct": false
    },
    {
      "text": "Si j'avais su, j'aurais ouvert",
      "correct": true
    },
    {
      "text": "Si je saurai, j'ouvre",
      "correct": false
    },
    {
      "text": "Si j'aurais, j'aurais",
      "correct": false
    }
  ],
  "explanation": "Si + PQP + conditionnel passé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si + PQP",
      "right": "condition non réalisée"
    },
    {
      "left": "conditionnel passé",
      "right": "conséquence non advenue"
    },
    {
      "left": "je tiens",
      "right": "fait vérifiable"
    },
    {
      "left": "j'imagine",
      "right": "hypothèse"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi elle avait nommé le danger, quelqu'un se ___ moins brûlé. (être, cond. passé)",
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
    "Si",
    "j'avais",
    "su",
    "j'aurais",
    "ouvert",
    "."
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
  "hint": "Rapport : si ceci avait eu lieu, cela aurait suivi."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si nous avions écouté, nous aurions noté, et il fautons un exemple tenu dans chaque texte.",
  "correct_sentence": "Si nous avions écouté, nous aurions noté, et il faut un exemple tenu dans chaque texte.",
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
      "image_path": "/elearning/mfk-b2-m2/metier-evolution.svg",
      "word": "un métier"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/societe-change.svg",
      "word": "une société"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/atelier-avant.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/ligne-temps.svg",
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
  "prompt": "Conjuguez six verbes au PQP et au conditionnel passé ; écrivez quatre phrases si…"
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis cinq hypothèses correctes."
}$j$::jsonb,
    9
  );

  -- ===== Un métier, une société =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un métier, une société'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un métier, une société', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Trois métiers, une cour qui change',
    'CO',
    $c$Objectif
Comprendre comment l'on décrit un métier et son évolution sociale au Seuil.

Consigne
Lisez le débat. Qui fait quoi, et qu'est-ce qui a changé ?

Support — Débat à la Salle des Herbes, outils sur la table
Dieudonné : Autrefois je réparais seulement les bancs. Désormais je cale aussi le coffre du cahier : le métier a grossi.
Aline Uwase : J'accompagnais les arrivées. Aujourd'hui j'enseigne aussi à formuler un avis, pas seulement à trouver une clé.
Lila Sow : Radio Figuier n'est plus un écho du soir. C'est un métier : couper, garder, dater.
Marc Nkurunziza : Une société change quand un geste devient une responsabilité nommée.
Rose Iradukunda : Mon ourlet n'est plus un passe-temps : c'est un salaire, ou ce n'est pas un métier.
Karim Bamba : Si l'on n'avait pas dit « qui paie », ces métiers resteraient des faveurs.
Solange Mukamana : Le Bureau n'existe pas ici comme tampon d'État ; le Seuil tamponne autrement : par le cahier.
Hawa Diallo : Joël accroche ; Félicie sert ; Yvette veille. Trois métiers invisibles dès qu'on parle trop de « vocations ».
Léa Niyonzima : À Rive-des-Saules, on nomme autrement les mêmes gestes. Ce n'est pas plus noble.
Patrick Habimana : Si j'avais appris plus tôt le nom des outils, j'aurais moins gâché le bois.
Sami : Les anciens réparaient sans le dire. Nous, nous devons le dire, sinon la radio l'oublie.
Mado : Décrire un métier, c'est dire les gestes, les risques, les dettes, pas seulement le titre.
Félicie : Mon bol nourrit une société qui discute : sans lui, le débat s'écroule à midi.
Yvette : Un métier qui nie le danger n'est pas adulte, même s'il plaît.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné dit que son métier n'a pas changé : il répare seulement les bancs.",
  "correct": false,
  "explanation": "Désormais il cale aussi le coffre du cahier : le métier a grossi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Mado, décrire un métier, c'est surtout…",
  "options": [
    {
      "text": "Donner un titre trop beau",
      "correct": false
    },
    {
      "text": "Dire les gestes, les risques, les dettes",
      "correct": true
    },
    {
      "text": "Cacher qui paie",
      "correct": false
    },
    {
      "text": "Imiter Val-des-Peupliers",
      "correct": false
    }
  ],
  "explanation": "Gestes, risques, dettes, pas seulement le titre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Dieudonné",
      "right": "réparer, caler"
    },
    {
      "left": "Aline",
      "right": "accompagner, enseigner l'avis"
    },
    {
      "left": "Lila",
      "right": "couper, garder, dater"
    },
    {
      "left": "Rose",
      "right": "ourlet et salaire"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne société change quand un geste devient une ___ nommée.",
  "answer": "responsabilité"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Décrire",
    "un",
    "métier",
    "c'est",
    "dire",
    "les",
    "gestes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "metier",
  "hint": "Ensemble de gestes payés, pas seulement un titre. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si l'on n'avait pas dit qui paie, ces métiers resteraient des faveurs, et je ferrai encore semblant que c'est une vocation.",
  "correct_sentence": "Si l'on n'avait pas dit qui paie, ces métiers resteraient des faveurs, et je ferai encore semblant que c'est une vocation.",
  "explanation": "Futur de faire : je ferai, un seul r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/societe-change.svg",
      "word": "une société"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/atelier-avant.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/ligne-temps.svg",
      "word": "une ligne"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/passe-simple.svg",
      "word": "un passé"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez trois métiers, un geste chacun, et ce qui a changé dans la société du Seuil."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Autrefois je réparais les bancs. Désormais je cale aussi le coffre. C'est un métier."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Du geste au métier, du métier à la cour',
    'CE',
    $c$Objectif
Lire un article sur l'évolution sociale des métiers du Seuil.

Consigne
Lisez l'article de Marc, sans aller trop vite.

Support — Article de Marc Nkurunziza, ligne du temps ocre
Une société se lit à ses métiers, pas seulement à ses fêtes.
Dieudonné répare : autrefois un banc, désormais un coffre, une table, parfois un micro trop lâche.
Si l'on n'avait pas nommé ce geste, il serait resté une faveur, et Lila n'aurait personne à créditer.
Aline Uwase accompagne encore les arrivées ; elle enseigne aussi à tenir un avis sous le figuier.
Radio Figuier, sous Lila Sow, est devenu un métier d'écoute : couper les insultes, garder les doutes, dater les bandes.
Rose Iradukunda a imposé un salaire à l'ourlet : sans cela, la couture restait un « don » trop commode.
Félicie, Joël, Yvette tiennent des métiers que l'on oublie dès que l'on parle trop de vocation.
Karim a raison : une société qui ne dit pas qui paie ment sur ses métiers.
Sami rappelle que les anciens réparaient sans affiche ; nous, nous devons afficher, sinon l'archive saute.
À Rive-des-Saules, les mêmes gestes portent d'autres noms : ce n'est pas une noblesse, c'est une autre cour.
Léa écrit que partir n'efface pas ces dettes : on emporte le souvenir d'un métier, pas seulement d'un arbre.
Mado classe : titre, gestes, risques, dettes, évolution.
Solange refuse le faux tampon « métier officiel » : le Seuil nomme autrement, par le cahier.
Nous jugerons ces évolutions lorsque nous aurons écouté ceux qui ont les mains dessus, pas seulement ceux qui ont le micro.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'article dit qu'à Rive-des-Saules les mêmes gestes sont plus nobles.",
  "correct": false,
  "explanation": "Ce n'est pas une noblesse, c'est une autre cour."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que classe Mado pour décrire un métier ?",
  "options": [
    {
      "text": "Seulement le titre",
      "correct": false
    },
    {
      "text": "Titre, gestes, risques, dettes, évolution",
      "correct": true
    },
    {
      "text": "Seulement le salaire",
      "correct": false
    },
    {
      "text": "Seulement la vocation",
      "correct": false
    }
  ],
  "explanation": "Mado classe : titre, gestes, risques, dettes, évolution."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Dieudonné",
      "right": "banc, coffre, table"
    },
    {
      "left": "Aline",
      "right": "arrivées et avis"
    },
    {
      "left": "Lila",
      "right": "écoute datée"
    },
    {
      "left": "Rose",
      "right": "salaire de l'ourlet"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi l'on n'avait pas nommé ce geste, il ___ resté une faveur. (être, cond. passé)",
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
    "Une",
    "société",
    "se",
    "lit",
    "à",
    "ses",
    "métiers",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "societe",
  "hint": "Ensemble de dettes, de gestes et de noms, autour d'une cour. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Radio Figuier est devenu un métier d'écoute, et Lila serai prête demain à l'heure fixée pour dater les bandes.",
  "correct_sentence": "Radio Figuier est devenu un métier d'écoute, et Lila sera prête demain à l'heure fixée pour dater les bandes.",
  "explanation": "Futur réel : elle sera, pas serai (1re pers.) ni serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/atelier-avant.svg",
      "word": "un atelier"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/ligne-temps.svg",
      "word": "une ligne"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/passe-simple.svg",
      "word": "un passé"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/lieu-enfance.svg",
      "word": "un lieu"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Pour quatre métiers : titre, un geste, un risque, une évolution."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'article, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire un métier sans le décorer',
    'PO',
    $c$Objectif
Décrire à l'oral un métier du Seuil : gestes, risques, dettes, évolution.

Consigne
Répétez, puis présentez un métier en deux minutes, sans slogan.

Support — Modèles d'Aline, Dieudonné et Lila
Autrefois je réparais les bancs ; désormais je cale aussi le coffre.
J'accompagne les arrivées, et j'enseigne à tenir un avis.
Je coupe les insultes, je garde les doutes, je date les bandes.
Mon ourlet n'est un métier que s'il est payé.
Un geste devient une responsabilité dès qu'on le nomme.
Si l'on n'avait pas dit qui paie, cela resterait une faveur.
Les risques : le dos, la flamme, l'encre versée, la voix trop vite.
Les dettes : envers ceux qui ont réparé sans affiche.
À Rive-des-Saules, on nomme autrement ; ce n'est pas plus noble.
Décrire, ce n'est pas décorer.
Dieudonné : montrez l'outil, pas seulement le mot.
Aline : dites l'évolution en une phrase.
Lila : une phrase, une pause.
Mado : titre, gestes, risques, dettes.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Décrire un métier, d'après les modèles, c'est surtout le décorer.",
  "correct": false,
  "explanation": "Décrire, ce n'est pas décorer."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quand un geste devient-il une responsabilité ?",
  "options": [
    {
      "text": "Quand on le cache",
      "correct": false
    },
    {
      "text": "Dès qu'on le nomme",
      "correct": true
    },
    {
      "text": "Seulement à Val-des-Peupliers",
      "correct": false
    },
    {
      "text": "Jamais, par principe",
      "correct": false
    }
  ],
  "explanation": "Un geste devient une responsabilité dès qu'on le nomme."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "autrefois / désormais",
      "right": "évolution"
    },
    {
      "left": "gestes",
      "right": "réparer, caler, couper"
    },
    {
      "left": "risques",
      "right": "dos, flamme, encre"
    },
    {
      "left": "dettes",
      "right": "ceux sans affiche"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nMon ourlet n'est un métier que s'il est ___.",
  "answer": "payé"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Décrire",
    "ce",
    "n'est",
    "pas",
    "décorer",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "atelier",
  "hint": "Lieu où Dieudonné et Rose tiennent leurs outils, pas une vitrine."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si l'on n'avait pas nommé ce geste, il serait resté une faveur, et je pourai encore l'oublier demain.",
  "correct_sentence": "Si l'on n'avait pas nommé ce geste, il serait resté une faveur, et je pourrai encore l'oublier demain.",
  "explanation": "Futur de pouvoir : je pourrai, deux r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/ligne-temps.svg",
      "word": "une ligne"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/passe-simple.svg",
      "word": "un passé"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/lieu-enfance.svg",
      "word": "un lieu"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/preposition-lieu.svg",
      "word": "une préposition"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez un portrait oral de douze phrases : un métier, évolution, risques, dettes."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis votre portrait de deux minutes."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Portrait d''un métier du Seuil',
    'PE',
    $c$Objectif
Écrire le portrait argumenté d'un métier et de son évolution sociale.

Consigne
Imitez le portrait de Dieudonné.

Support — Portrait par Dieudonné, établi ocre
Dieudonné — Seuil des Sources, derrière la Salle des Herbes
Autrefois je réparais les bancs du figuier. Désormais je cale le coffre du Cahier du chemin, et parfois le pied du micro.
Si l'on n'avait pas nommé ces gestes, ils seraient restés des faveurs, et Radio Figuier n'aurait personne à créditer.
Aline enseigne à tenir un avis ; Lila date les bandes ; Rose impose un salaire à l'ourlet. Nous formons une société, pas une vitrine.
Les risques : le dos, l'encre versée, une table qui lâche sous le cahier.
Les dettes : envers ceux qui réparaient sans affiche, dit Sami.
À Rive-des-Saules, on dirait autrement ; ce n'est pas plus noble.
Karim demandera qui paie le bois : je répondrai, dès que j'aurai fini de caler.
Yvette veillera au dos. Félicie tiendra le bol de midi, sinon le métier s'écroule.
Je ne décore pas. Je décris.
Si j'avais appris plus tôt le nom de chaque outil, j'aurais moins gâché.
Voilà mon métier, ni trop fier, ni trop humble.
Dieudonné
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Dieudonné dit qu'à Rive-des-Saules les mêmes gestes sont plus nobles.",
  "correct": false,
  "explanation": "On dirait autrement ; ce n'est pas plus noble."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que répondra Dieudonné à Karim, et à quelle condition ?",
  "options": [
    {
      "text": "Il ne répondra jamais",
      "correct": false
    },
    {
      "text": "Il répondra dès qu'il aura fini de caler",
      "correct": true
    },
    {
      "text": "Il vendra le coffre",
      "correct": false
    },
    {
      "text": "Il partira au pavillon",
      "correct": false
    }
  ],
  "explanation": "Je répondrai, dès que j'aurai fini de caler."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "autrefois",
      "right": "les bancs"
    },
    {
      "left": "désormais",
      "right": "coffre et micro"
    },
    {
      "left": "risques",
      "right": "dos, encre, table"
    },
    {
      "left": "dettes",
      "right": "sans affiche"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDès que j'___ fini de caler, je répondrai. (avoir, FA)",
  "answer": "aurai"
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
    "décore",
    "pas",
    "je",
    "décris",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "evolution",
  "hint": "Changement d'un geste qui devient une responsabilité. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Dès que j'aurai fini de caler, je répondrai, et je serais prêt à l'heure réelle du jeudi.",
  "correct_sentence": "Dès que j'aurai fini de caler, je répondrai, et je serai prêt à l'heure réelle du jeudi.",
  "explanation": "Heure déjà fixée : je serai, pas je serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/passe-simple.svg",
      "word": "un passé"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/lieu-enfance.svg",
      "word": "un lieu"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/preposition-lieu.svg",
      "word": "une préposition"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/banc-souvenir.svg",
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
  "prompt": "Imitez : un portrait de douze lignes, évolution, risques, dettes, une hypothèse si + PQP."
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
    'EL — Décrire un métier, lire une société',
    'EL',
    $c$Objectif
Retenir le lexique et les structures pour un portrait de métier.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline et de Mado, ligne du temps
Décrire un métier : titre, gestes, outils, risques, dettes, évolution.
Autrefois + imparfait ; désormais / aujourd'hui + présent.
Un geste devient une responsabilité dès qu'on le nomme.
Si + PQP + conditionnel passé : si l'on n'avait pas nommé, cela serait resté une faveur.
Futur antérieur avant de répondre : dès que j'aurai fini de caler, je répondrai.
Métiers du Seuil : Dieudonné (réparer, caler), Aline (accompagner, enseigner l'avis), Lila / Radio (couper, garder, dater).
Autres gestes à nommer : Rose (ourlet payé), Félicie (bol), Joël (lanternes), Yvette (danger).
Société : qui paie, qui copie, qui oublie, qui archive.
Rive-des-Saules nomme autrement : ce n'est pas plus noble.
Décrire ≠ décorer. Titre ≠ vocation trop commode.
Je ferai (1 r) ; je pourrai (2 r) ; il faut (3e pers.) ; je serai / je serais.
Bien que le métier change, il faut dire les dettes.
Pas de faux tampon « officiel » : le Seuil nomme par le cahier.
Il faut un risque et une dette dans chaque portrait.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Un titre suffit à décrire un métier, selon la fiche.",
  "correct": false,
  "explanation": "Titre, gestes, outils, risques, dettes, évolution."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle opposition de temps structure l'évolution ?",
  "options": [
    {
      "text": "seulement le futur",
      "correct": false
    },
    {
      "text": "autrefois + imparfait / désormais + présent",
      "correct": true
    },
    {
      "text": "seulement le passé simple",
      "correct": false
    },
    {
      "text": "seulement le conditionnel",
      "correct": false
    }
  ],
  "explanation": "Autrefois je réparais ; désormais je cale."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "autrefois",
      "right": "imparfait"
    },
    {
      "left": "désormais",
      "right": "présent"
    },
    {
      "left": "si on n'avait pas nommé",
      "right": "faveur"
    },
    {
      "left": "dès que j'aurai fini",
      "right": "ensuite répondre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAutrefois je ___ les bancs ; désormais je cale le coffre. (réparer, imp.)",
  "answer": "réparais"
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
    "geste",
    "nommé",
    "devient",
    "une",
    "responsabilité",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "dettes",
  "hint": "Ce que l'on doit à ceux qui ont agi sans affiche."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que le métier change, il fautons dire les dettes, et Aline tient l'avis.",
  "correct_sentence": "Bien que le métier change, il faut dire les dettes, et Aline tient l'avis.",
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
      "image_path": "/elearning/mfk-b2-m2/lieu-enfance.svg",
      "word": "un lieu"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/preposition-lieu.svg",
      "word": "une préposition"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/banc-souvenir.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/raconter-histoire.svg",
      "word": "un récit"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau : six métiers du Seuil, un geste, un risque, une évolution chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis le portrait d'un métier en six phrases."
}$j$::jsonb,
    9
  );

  -- ===== Lieux d'enfance =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Lieux d''enfance'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Lieux d''enfance', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Au-delà du figuier, en contrebas du pont',
    'CO',
    $c$Objectif
Repérer les prépositions de lieu précises pour des lieux d'enfance.

Consigne
Lisez les souvenirs. Où se situent les lieux, les uns par rapport aux autres ?

Support — Souvenirs à la Table des Sources, carte de Rukiri-Nord
Sami : Au-delà du figuier, il y avait un sentier que les enfants n'avaient pas le droit de nommer trop fort.
Mado : En contrebas du futur pont — il n'était alors qu'une planche — nous posions les pieds dans l'eau.
Aline Uwase : À travers la cour, on courait jusqu'à la Salle des Herbes, sans regarder Lampe-Figue.
Léa Niyonzima : Le long de ce qui deviendrait Rive-des-Saules, ma grand-mère tenait une ombre, pas encore un pavillon.
Patrick Habimana : Vis-à-vis du banc ocre, un second banc, plus bas, servait aux plus jeunes.
Hawa Diallo : À proximité du Marché des Lampions — déjà bruyant — on vendait moins, on échangeait plus.
Joël Mugisha : En amont de la cour, le vent prenait les lanternes trop tôt. J'aurais dû le savoir.
Rose Iradukunda : Derrière la Salle des Herbes, un lin séchait : mon premier tissu, dit-elle, n'était pas encore un métier.
Karim Bamba : Au-delà des herbes, quelqu'un payait déjà l'huile, mais sans le dire.
Lila Sow : Radio Figuier n'existait pas. Il y avait une voix, à travers les feuilles, rien d'autre.
Félicie : En contrebas de la table, un bol plus petit : mon enfance tenait là.
Dieudonné : Autour du figuier, les racines faisaient des sièges. J'ai appris le bois là, pas ailleurs.
Yvette : À travers les flammes trop hautes, on voyait déjà le danger, si l'on acceptait de le nommer.
Marc Nkurunziza : Une préposition précise vaut une légende vague.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Sami situe le sentier interdit en contrebas du figuier.",
  "correct": false,
  "explanation": "Au-delà du figuier, il y avait un sentier."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Mado posait-elle les pieds, selon son souvenir ?",
  "options": [
    {
      "text": "Au-delà de Lampe-Figue seulement",
      "correct": false
    },
    {
      "text": "En contrebas du futur pont, dans l'eau",
      "correct": true
    },
    {
      "text": "Vis-à-vis de Radio Figuier",
      "correct": false
    },
    {
      "text": "À Val-des-Peupliers déjà",
      "correct": false
    }
  ],
  "explanation": "En contrebas du futur pont, dans l'eau."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "au-delà de",
      "right": "plus loin que"
    },
    {
      "left": "en contrebas de",
      "right": "plus bas que"
    },
    {
      "left": "à travers",
      "right": "en traversant"
    },
    {
      "left": "vis-à-vis de",
      "right": "en face de"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ du figuier, il y avait un sentier. (plus loin)",
  "answer": "Au-delà"
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
    "contrebas",
    "du",
    "pont",
    "nous",
    "posions",
    "les",
    "pieds",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "enfance",
  "hint": "Temps des premiers lieux, avant que les métiers aient un nom."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "À travers la cour on courait, et il fautons une préposition précise plutôt qu'une légende vague.",
  "correct_sentence": "À travers la cour on courait, et il faut une préposition précise plutôt qu'une légende vague.",
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
      "image_path": "/elearning/mfk-b2-m2/preposition-lieu.svg",
      "word": "une préposition"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/banc-souvenir.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/raconter-histoire.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/trois-voix.svg",
      "word": "trois voix"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Relevez six prépositions de lieu et le lieu qu'elles situent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Au-delà du figuier, un sentier. En contrebas du pont, l'eau. À travers la cour, on courait."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Ce que l''enfance prit et ce que nous vîmes',
    'CE',
    $c$Objectif
Comprendre un récit d'enfance au passé simple et situer les lieux.

Consigne
Lisez le récit de Sami, sans aller trop vite.

Support — Récit de Sami, archive du Cahier du chemin
Sami dit alors la vérité qu'il tenait, non celle qu'il imaginait.
Il prit la photo ocre, la posa vis-à-vis du banc, et nous vîmes enfin le sentier au-delà du figuier.
Elle — Mado — ouvrit le cahier ; l'encre parut plus claire en contrebas de la tache de pluie.
Nous fûmes saisis : à travers la cour, un second figuier, plus jeune, avait existé, puis disparu.
Il fallut un silence. Lila ne dit mot ; Aline, elle, reprit : « Situez, ne décorez pas. »
Karim vint plus tard ; il écrivit en marge le mot « huile », rien d'autre.
Les anciens parlèrent : en amont de la cour, le vent prit toujours les lanternes trop tôt.
Léa lut la ligne du pont ; Patrick, en contrebas, reconnut l'eau de ses pieds d'enfant.
Rose passa le doigt sur un lin dessiné : ce tissu-là, dit-elle, n'était pas encore un métier.
Dieudonné toucha une racine ; il fut, un instant, l'enfant qui apprit le bois.
Yvette nota le danger : à travers les flammes trop hautes, quelqu'un se brûla, jadis.
Félicie, elle, garda le petit bol : son enfance tenait encore là, à proximité de la table.
Joël vit, sur la photo, une lanterne trop haute, et il promit de moins haut.
Nous relûmes la page lorsque le soleil baissa ; le passé simple, ici, n'était pas une parure : il faisait voir.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le récit dit que Lila parla longuement pendant le silence.",
  "correct": false,
  "explanation": "Lila ne dit mot ; Aline reprit : « Situez, ne décorez pas. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que vîmes-nous, selon Sami, à travers la cour ?",
  "options": [
    {
      "text": "Radio Figuier déjà bâtie",
      "correct": false
    },
    {
      "text": "Un second figuier, plus jeune, puis disparu",
      "correct": true
    },
    {
      "text": "Le Pavillon du Saule",
      "correct": false
    },
    {
      "text": "Un tampon officiel",
      "correct": false
    }
  ],
  "explanation": "À travers la cour, un second figuier, plus jeune, avait existé, puis disparu."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "il prit / nous vîmes",
      "right": "passé simple"
    },
    {
      "left": "au-delà du figuier",
      "right": "le sentier"
    },
    {
      "left": "en contrebas de la tache",
      "right": "l'encre plus claire"
    },
    {
      "left": "à travers la cour",
      "right": "le second figuier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl ___ la photo ocre et la posa vis-à-vis du banc. (prendre, PS)",
  "answer": "prit"
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
    "vîmes",
    "enfin",
    "le",
    "sentier",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "contrebas",
  "hint": "Plus bas que le pont ou que la tache : l'eau, l'encre plus claire."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous vîmes le sentier au-delà du figuier, et Sami prit la photo, puis il fallutons un silence.",
  "correct_sentence": "Nous vîmes le sentier au-delà du figuier, et Sami prit la photo, puis il fallut un silence.",
  "explanation": "Passé simple de falloir : il fallut, invariable à la 3e personne."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/banc-souvenir.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/raconter-histoire.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/trois-voix.svg",
      "word": "trois voix"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/cahier-chemin.svg",
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
  "prompt": "Relevez huit passés simples et quatre prépositions de lieu, avec leur complément."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le récit, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire au-delà, en contrebas, à travers',
    'PO',
    $c$Objectif
Situer à l'oral des lieux d'enfance avec des prépositions précises.

Consigne
Répétez, puis décrivez trois lieux de votre enfance sans légende vague.

Support — Modèles d'Aline et de Sami, carte ocre
Au-delà du figuier, il y avait un sentier.
En contrebas du pont, nous posions les pieds dans l'eau.
À travers la cour, on courait jusqu'aux herbes.
Le long de la future rive, une ombre tenait lieu de pavillon.
Vis-à-vis du banc ocre, un banc plus bas servait aux plus jeunes.
À proximité du marché déjà bruyant, on échangeait plus qu'on ne vendait.
En amont de la cour, le vent prenait les lanternes.
Autour des racines, j'ai appris le bois.
Derrière la salle, un lin séchait.
Une préposition précise vaut une légende vague.
Sami : situez d'abord, racontez ensuite.
Mado : un lieu, une préposition, un geste.
Lila : une phrase, une pause.
Marc : ne décorez pas.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« En contrebas de » signifie plus loin, au même niveau.",
  "correct": false,
  "explanation": "En contrebas de = plus bas que (pont, tache, table)."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle préposition convient pour « en traversant l'espace » ?",
  "options": [
    {
      "text": "en contrebas de",
      "correct": false
    },
    {
      "text": "à travers",
      "correct": true
    },
    {
      "text": "vis-à-vis de seulement",
      "correct": false
    },
    {
      "text": "en amont de seulement",
      "correct": false
    }
  ],
  "explanation": "À travers la cour, à travers les feuilles, à travers les flammes."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "au-delà de",
      "right": "plus loin"
    },
    {
      "left": "en contrebas de",
      "right": "plus bas"
    },
    {
      "left": "à travers",
      "right": "en traversant"
    },
    {
      "left": "en amont de",
      "right": "plus haut / avant sur le cours"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ la cour, on courait jusqu'aux herbes.",
  "answer": "À travers"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Au-delà",
    "du",
    "figuier",
    "il",
    "y",
    "avait",
    "un",
    "sentier",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "traverse",
  "hint": "Action de passer d'un bord à l'autre d'une cour ou d'une flamme."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "En contrebas du pont nous posions les pieds, et je ferrai encore ce chemin demain à l'aube.",
  "correct_sentence": "En contrebas du pont nous posions les pieds, et je ferai encore ce chemin demain à l'aube.",
  "explanation": "Futur de faire : je ferai, un seul r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/raconter-histoire.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/trois-voix.svg",
      "word": "trois voix"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/cahier-chemin.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/archives-figuier.svg",
      "word": "des archives"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez dix phrases de lieu : au-delà, en contrebas, à travers, le long de, vis-à-vis."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis trois lieux d'enfance à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mes lieux d''enfance',
    'PE',
    $c$Objectif
Écrire un souvenir de lieux d'enfance avec prépositions précises.

Consigne
Imitez le souvenir de Mado.

Support — Souvenir de Mado, plume ocre
Mado — Rukiri-Nord, encore le Seuil
Au-delà du figuier, le sentier existait ; nous n'avions pas le droit de le nommer trop fort.
En contrebas de la planche — ce n'était pas encore un pont — je posais les pieds dans l'eau, et Léa riait.
À travers la cour, on courait jusqu'à la Salle des Herbes ; Lampe-Figue n'était qu'une lueur.
Vis-à-vis du banc des plus grands, notre banc plus bas servait de frontière.
À proximité des Lampions déjà bruyants, on échangeait des feuilles, on vendait peu.
Si j'avais su qu'un second figuier disparaîtrait, j'aurais dessiné plus tôt.
Dieudonné, autour des racines, apprenait le bois ; Rose, derrière la salle, un lin.
Yvette nommait déjà le danger à travers les flammes trop hautes.
Je tiens la photo. J'imagine l'heure. Je n'imprime pas de faux tampon.
Sami dit que situer, ce n'est pas décorer. Je le crois.
Voilà mes lieux, ni trop doux, ni trop nets.
Mado
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado imprime un tampon avec une heure inventée.",
  "correct": false,
  "explanation": "Je tiens la photo. J'imagine l'heure. Je n'imprime pas de faux tampon."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que ferait Mado, si elle avait su la disparition du second figuier ?",
  "options": [
    {
      "text": "Elle aurait fermé la cour",
      "correct": false
    },
    {
      "text": "Elle aurait dessiné plus tôt",
      "correct": true
    },
    {
      "text": "Elle aurait vendu la photo",
      "correct": false
    },
    {
      "text": "Elle aurait quitté le Seuil",
      "correct": false
    }
  ],
  "explanation": "Si j'avais su […], j'aurais dessiné plus tôt."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "au-delà du figuier",
      "right": "le sentier"
    },
    {
      "left": "en contrebas de la planche",
      "right": "l'eau"
    },
    {
      "left": "à travers la cour",
      "right": "la Salle des Herbes"
    },
    {
      "left": "vis-à-vis du banc",
      "right": "frontière"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEn contrebas de la planche, je posais les pieds ___ l'eau.",
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
    "Situer",
    "ce",
    "n'est",
    "pas",
    "décorer",
    "."
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
  "hint": "Image d'un lieu d'enfance, tenue par une photo ou une phrase."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si j'aurais su qu'un second figuier disparaîtrait, j'aurais dessiné plus tôt, et Sami aurait vu le croquis.",
  "correct_sentence": "Si j'avais su qu'un second figuier disparaîtrait, j'aurais dessiné plus tôt, et Sami aurait vu le croquis.",
  "explanation": "Si + plus-que-parfait : si j'avais su."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/trois-voix.svg",
      "word": "trois voix"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/cahier-chemin.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/archives-figuier.svg",
      "word": "des archives"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/table-ronde.svg",
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
  "prompt": "Imitez : douze lignes, cinq prépositions de lieu, une hypothèse si + PQP."
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
    'EL — Prépositions de lieu et passé simple lu',
    'EL',
    $c$Objectif
Retenir les prépositions précises et reconnaître le passé simple à la lecture.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, carte de Rukiri-Nord
Prépositions : au-delà de (plus loin), en contrebas de (plus bas), à travers (en traversant).
le long de, vis-à-vis de, à proximité de, en amont de, autour de, derrière.
Au-delà du figuier ; en contrebas du pont ; à travers la cour.
Une préposition précise vaut une légende vague.
Passé simple (à reconnaître en CE, pas à inventer partout) :
il dit / elle dit ; il prit / elle prit ; nous vîmes / ils virent ; il fut / nous fûmes.
il vint, elle ouvrit, il écrivit, il fallut, ils parlèrent, elle reprit, nous relûmes.
Il prit la photo ; nous vîmes le sentier ; il fallut un silence.
Le passé simple fait voir une action close ; l'imparfait décrit le décor (il y avait un sentier).
Si + PQP reste utile : si j'avais su, j'aurais dessiné.
Ne pas écrire il fallutons : il fallut.
Lieux d'enfance du Seuil : sentier, planche, racines, petit bol, lin derrière la salle.
Situez d'abord, racontez ensuite.
Il faut un lieu, une préposition, un geste.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Nous vîmes » est un imparfait de voir.",
  "correct": false,
  "explanation": "Nous vîmes : passé simple de voir, personne nous."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel est le passé simple de prendre, à la 3e personne du singulier ?",
  "options": [
    {
      "text": "il prenait",
      "correct": false
    },
    {
      "text": "il prit",
      "correct": true
    },
    {
      "text": "il a pris seulement",
      "correct": false
    },
    {
      "text": "il prendra",
      "correct": false
    }
  ],
  "explanation": "Il prit la photo."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "au-delà de",
      "right": "plus loin"
    },
    {
      "left": "en contrebas de",
      "right": "plus bas"
    },
    {
      "left": "à travers",
      "right": "en traversant"
    },
    {
      "left": "il prit / nous vîmes",
      "right": "passé simple"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ le sentier au-delà du figuier. (voir, PS)",
  "answer": "vîmes"
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
    "prit",
    "la",
    "photo",
    "ocre",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "vimes",
  "hint": "Passé simple de voir, personne nous, sans accent ici."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous vîmes le sentier, et il fallutons un silence avant qu'Aline reprît la parole.",
  "correct_sentence": "Nous vîmes le sentier, et il fallut un silence avant qu'Aline reprît la parole.",
  "explanation": "Il fallut, jamais fallutons."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/cahier-chemin.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/archives-figuier.svg",
      "word": "des archives"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/table-ronde.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/micro-memoire.svg",
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
  "prompt": "Tableau : six prépositions + exemple ; six passés simples relevés ou conjugués."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis six phrases de lieu et trois phrases au passé simple lu."
}$j$::jsonb,
    9
  );

  -- ===== Raconter l'histoire autrement =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Raconter l''histoire autrement'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Raconter l''histoire autrement', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Trois voix pour le même soir',
    'CO',
    $c$Objectif
Comparer un récit oral, une archive écrite et une bande radio.

Consigne
Lisez la confrontation. Que garde chaque voix, que perd-elle ?

Support — Confrontation sous le figuier, trois supports
Sami : À l'oral, je peux hésiter, répéter, montrer la photo. Je perds la date exacte.
Mado : L'archive du Cahier du chemin garde l'encre et la marge. Elle perd le souffle, le silence.
Lila Sow : La radio garde une voix datée. Elle perd le geste de la main sur la racine.
Aline Uwase : Raconter autrement, ce n'est pas se contredire : c'est changer d'outil.
Marc Nkurunziza : Si nous n'avions qu'une voix, nous prendrions une légende pour une preuve.
Léa Niyonzima : L'oral de Sami m'a fait voir le sentier ; l'archive m'a fait toucher la tache.
Patrick Habimana : La bande de Lila m'a fait entendre le vent. Sans elle, j'aurais trop vite conclu.
Hawa Diallo : Chaque voix a une dette : l'oral envers la date, l'écrit envers le souffle, la radio envers le geste.
Joël Mugisha : Je crois les trois, à condition de les nommer comme trois, pas comme une.
Rose Iradukunda : Une histoire cousue d'une seule voix laisse un ourlet trop serré.
Solange Mukamana : Pas de faux tampon pour unifier ce qui doit rester multiple.
Karim Bamba : Qui paie l'enregistrement ? Qui garde le cahier ? Ce sont déjà des choix de récit.
Félicie : Mon bol n'apparaît que dans l'oral de Sami. L'archive l'a oublié. C'est un argument.
Yvette : Le danger, lui, doit être dans les trois voix, sinon l'une des trois ment.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline dit que raconter autrement, c'est forcément se contredire.",
  "correct": false,
  "explanation": "Raconter autrement, ce n'est pas se contredire : c'est changer d'outil."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que perd la radio, selon Lila ?",
  "options": [
    {
      "text": "La voix datée",
      "correct": false
    },
    {
      "text": "Le geste de la main sur la racine",
      "correct": true
    },
    {
      "text": "Toute vérité",
      "correct": false
    },
    {
      "text": "Le vent",
      "correct": false
    }
  ],
  "explanation": "Elle perd le geste de la main sur la racine."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "récit oral",
      "right": "souffle, photo, pas de date"
    },
    {
      "left": "archive",
      "right": "encre, marge, pas de souffle"
    },
    {
      "left": "radio",
      "right": "voix datée, pas de geste"
    },
    {
      "left": "trois voix",
      "right": "pas une légende"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nRaconter autrement, c'est changer d'___, pas se contredire.",
  "answer": "outil"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Chaque",
    "voix",
    "a",
    "une",
    "dette",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "archive",
  "hint": "Page datée du cahier, qui garde l'encre et perd le souffle."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si nous n'avions qu'une voix, nous prendrions une légende pour une preuve, et il fautons les nommer comme trois.",
  "correct_sentence": "Si nous n'avions qu'une voix, nous prendrions une légende pour une preuve, et il faut les nommer comme trois.",
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
      "image_path": "/elearning/mfk-b2-m2/archives-figuier.svg",
      "word": "des archives"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/table-ronde.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/micro-memoire.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/lettre-grand-mere.svg",
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
  "prompt": "Pour oral, archive, radio : un gain, une perte, une dette."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : L'oral garde le souffle. L'archive garde l'encre. La radio garde une voix datée."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — La même pluie, trois récits',
    'CE',
    $c$Objectif
Lire un article qui compare trois versions du même événement.

Consigne
Lisez l'article de Marc, sans aller trop vite.

Support — Article de Marc, trois colonnes ocre
La pluie qui tacha le cahier existe désormais en trois récits, et c'est une richesse, non un scandale.
Sami dit — à l'oral, sous le figuier — qu'il prit trop tard la décision d'ouvrir le coffre.
L'archive, elle, n'écrit pas « trop tard » : elle montre une tache, une marge, un tampon manquant.
Radio Figuier, lorsque Lila eut tendu le micro, garda le vent et perdit la main de Dieudonné sur le bois.
Nous vîmes, en comparant, ce que chaque voix refuse de porter.
Si nous avions cru Sami seul, nous aurions une faute et peu de preuves.
Si nous avions cru l'archive seule, nous aurions une tache et peu de souffle.
Si nous avions cru la bande seule, nous aurions un vent et peu de table.
Aline conclut : raconter autrement, c'est assumer une dette, pas corriger les autres.
Félicie n'apparaît que dans l'oral : l'oubli du bol est déjà un choix de société.
Yvette exige que le danger — flamme, encre, dos — traverse les trois voix.
Solange refuse un tampon unique qui ferait « la » version.
Léa, à Rive-des-Saules, entendra surtout la radio ; elle devra venir pour l'archive.
Karim demandera qui paie la bande : c'est encore raconter, autrement.
Nous publierons les trois, lorsque nous aurons daté chacune, pas une synthèse trop lisse.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'article présente les trois récits comme un scandale à corriger.",
  "correct": false,
  "explanation": "Trois récits, et c'est une richesse, non un scandale."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que garde Radio Figuier, et que perd-elle, dans cet article ?",
  "options": [
    {
      "text": "Elle garde la table, elle perd le vent",
      "correct": false
    },
    {
      "text": "Elle garde le vent, elle perd la main de Dieudonné sur le bois",
      "correct": true
    },
    {
      "text": "Elle garde le bol, elle perd Sami",
      "correct": false
    },
    {
      "text": "Elle ne garde rien",
      "correct": false
    }
  ],
  "explanation": "Garda le vent et perdit la main de Dieudonné sur le bois."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "oral de Sami",
      "right": "« trop tard », peu de preuves"
    },
    {
      "left": "archive",
      "right": "tache, marge, tampon manquant"
    },
    {
      "left": "radio",
      "right": "vent, pas de table"
    },
    {
      "left": "trois voix",
      "right": "richesse, pas scandale"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi nous avions cru Sami seul, nous ___ une faute et peu de preuves. (avoir, cond. passé)",
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
    "Raconter",
    "autrement",
    "c'est",
    "assumer",
    "une",
    "dette",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "echo",
  "hint": "Ce qui reste d'une voix quand la bande ou le geste manque. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si nous aurions cru l'archive seule, nous aurions une tache et peu de souffle, et Léa l'entendrait de loin.",
  "correct_sentence": "Si nous avions cru l'archive seule, nous aurions une tache et peu de souffle, et Léa l'entendrait de loin.",
  "explanation": "Si + plus-que-parfait : si nous avions cru."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/table-ronde.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/micro-memoire.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/lettre-grand-mere.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/pont-hier.svg",
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
  "prompt": "Remplissez trois colonnes : oral / archive / radio — gain, perte, oubli."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez l'article, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire ce que chaque voix garde',
    'PO',
    $c$Objectif
Comparer à l'oral trois outils du récit : oral, archive, radio.

Consigne
Répétez, puis racontez le même fait de trois façons, en nommant l'outil.

Support — Modèles d'Aline, Sami et Lila
À l'oral, je peux montrer la photo ; je perds la date.
Dans l'archive, je garde l'encre ; je perds le souffle.
À la radio, je garde une voix datée ; je perds le geste.
Raconter autrement, ce n'est pas se contredire.
Chaque voix a une dette.
Si nous n'avions qu'une voix, nous prendrions une légende pour une preuve.
L'oubli du bol est déjà un choix.
Le danger doit traverser les trois voix.
Je crois les trois, à condition de les nommer comme trois.
Pas de tampon unique.
Sami : l'oral hésite, c'est permis.
Mado : l'écrit date, c'est une dette envers l'heure.
Lila : la bande se coupe, c'est un métier.
Marc : publiez les trois, pas une synthèse trop lisse.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On doit unifier les trois voix par un seul tampon, selon les modèles.",
  "correct": false,
  "explanation": "Pas de tampon unique. Publiez les trois."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que risque-t-on, si l'on n'a qu'une voix ?",
  "options": [
    {
      "text": "Rien",
      "correct": false
    },
    {
      "text": "Prendre une légende pour une preuve",
      "correct": true
    },
    {
      "text": "Gagner les trois dettes",
      "correct": false
    },
    {
      "text": "Mieux dater",
      "correct": false
    }
  ],
  "explanation": "Nous prendrions une légende pour une preuve."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "oral",
      "right": "photo, pas de date"
    },
    {
      "left": "archive",
      "right": "encre, pas de souffle"
    },
    {
      "left": "radio",
      "right": "voix datée, pas de geste"
    },
    {
      "left": "trois voix",
      "right": "richesse"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nChaque voix a une ___.",
  "answer": "dette"
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
    "tampon",
    "unique",
    "."
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
  "hint": "Ce que l'oral garde et que la page ne peut plus porter."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si nous n'avions qu'une voix, nous prendrions une légende pour une preuve, et je ferrai une synthèse trop lisse.",
  "correct_sentence": "Si nous n'avions qu'une voix, nous prendrions une légende pour une preuve, et je ferai une synthèse trop lisse.",
  "explanation": "Futur de faire : je ferai, un seul r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/micro-memoire.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/lettre-grand-mere.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/pont-hier.svg",
      "word": "un pont"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/figuier-racines.svg",
      "word": "des racines"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Racontez le même fait en trois blocs de quatre phrases : oral, archive, radio."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis vos trois versions d'un même fait."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — La même histoire, autrement',
    'PE',
    $c$Objectif
Réécrire un fait en trois voix : orale, archive, radio.

Consigne
Imitez la triple note de Léa Niyonzima.

Support — Triple note de Léa, Pavillon du Saule et figuier
Léa Niyonzima — trois voix, un même soir
Voix orale : Sami me dit — et je l'entends encore — qu'il prit trop tard le coffre ; sa main tremblait, la photo aussi.
Voix archive : « Tache. Marge. Tampon manquant. Bol non mentionné. » J'écris sec, je perds le tremblement.
Voix radio : Lila garda le vent ; on n'entend pas Dieudonné. Si j'avais eu seulement cette bande, j'aurais trop vite conclu.
Raconter autrement, ce n'est pas se contredire. C'est payer trois dettes.
Je tiens la tache. J'imagine l'heure. Je refuse un tampon unique.
À Rive-des-Saules, j'entendrai surtout l'antenne ; je devrai revenir pour le cahier.
Patrick, s'il n'avait entendu que moi, aurait une légende trop nette.
Yvette : que le danger passe dans les trois voix.
Félicie : que le bol, un jour, soit écrit.
Voilà mon essai, ni trop lisse, ni trop triple.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa veut un tampon unique pour unifier les trois voix.",
  "correct": false,
  "explanation": "Je refuse un tampon unique."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que risque Patrick, s'il n'entend que Léa ?",
  "options": [
    {
      "text": "Rien",
      "correct": false
    },
    {
      "text": "Une légende trop nette",
      "correct": true
    },
    {
      "text": "De perdre le pont",
      "correct": false
    },
    {
      "text": "De réparer le coffre",
      "correct": false
    }
  ],
  "explanation": "S'il n'avait entendu que moi, il aurait une légende trop nette."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "voix orale",
      "right": "tremblement, « trop tard »"
    },
    {
      "left": "voix archive",
      "right": "tache, marge, sec"
    },
    {
      "left": "voix radio",
      "right": "vent, pas Dieudonné"
    },
    {
      "left": "trois dettes",
      "right": "pas se contredire"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi j'avais eu seulement cette bande, j'___ trop vite conclu. (avoir, cond. passé)",
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
    "Je",
    "refuse",
    "un",
    "tampon",
    "unique",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "triple",
  "hint": "Trois voix pour un même soir, sans les fondre trop tôt."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si j'avais eu seulement cette bande, j'aurais trop vite conclu, et je serais à l'antenne demain à l'heure dite.",
  "correct_sentence": "Si j'avais eu seulement cette bande, j'aurais trop vite conclu, et je serai à l'antenne demain à l'heure dite.",
  "explanation": "Rendez-vous réel : je serai, pas je serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/lettre-grand-mere.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/pont-hier.svg",
      "word": "un pont"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/figuier-racines.svg",
      "word": "des racines"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/radio-echo.svg",
      "word": "un écho"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : trois blocs, un fait, gains et pertes, une phrase « je tiens / j'imagine »."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre triple note, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Oral, archive, radio : trois outils',
    'EL',
    $c$Objectif
Retenir ce que chaque voix garde, perd, et doit aux autres.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline, trois colonnes
Récit oral : souffle, hésitation, photo montrée, geste. Perd souvent la date.
Archive (Cahier du chemin) : encre, marge, tampon, heure. Perd le souffle et parfois un bol.
Radio Figuier : voix datée, vent, coupe professionnelle. Perd le geste, parfois la table.
Raconter autrement = changer d'outil, pas se contredire.
Chaque voix a une dette envers les deux autres.
Si + PQP : si nous n'avions qu'une voix, nous prendrions une légende pour une preuve.
Publier les trois, dater chacune, refuser le tampon unique.
Le danger (Yvette) doit traverser les trois voix.
L'oubli d'un métier (Félicie, Dieudonné) est déjà un choix de société.
Passé simple possible dans l'archive lue : il prit, nous vîmes, il dit.
Bien que les voix diffèrent, il faut les garder ensemble.
Je ferai trois versions (1 r) ; je pourrai les comparer (2 r).
Léa, loin, entendra surtout la radio : elle devra revenir pour le cahier.
Il faut nommer l'outil avant de raconter.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'oubli du bol dans l'archive n'est pas un choix, selon la fiche.",
  "correct": false,
  "explanation": "L'oubli d'un métier est déjà un choix de société."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que doit-on faire des trois voix ?",
  "options": [
    {
      "text": "N'en garder qu'une",
      "correct": false
    },
    {
      "text": "Les publier, les dater, refuser le tampon unique",
      "correct": true
    },
    {
      "text": "Les fondre en un slogan",
      "correct": false
    },
    {
      "text": "Les cacher à Léa",
      "correct": false
    }
  ],
  "explanation": "Publier les trois, dater chacune, refuser le tampon unique."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "oral",
      "right": "souffle, pas de date"
    },
    {
      "left": "archive",
      "right": "encre, pas de souffle"
    },
    {
      "left": "radio",
      "right": "voix datée, pas de geste"
    },
    {
      "left": "dette",
      "right": "envers les deux autres"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl faut nommer l'___ avant de raconter.",
  "answer": "outil"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Publier",
    "les",
    "trois",
    "dater",
    "chacune",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "outil",
  "hint": "Moyen de raconter : voix, page ou bande, chacun avec une perte."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que les voix diffèrent, il fautons les garder ensemble, et Léa reviendra pour le cahier.",
  "correct_sentence": "Bien que les voix diffèrent, il faut les garder ensemble, et Léa reviendra pour le cahier.",
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
      "image_path": "/elearning/mfk-b2-m2/pont-hier.svg",
      "word": "un pont"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/figuier-racines.svg",
      "word": "des racines"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/radio-echo.svg",
      "word": "un écho"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/carte-rukiri.svg",
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
  "prompt": "Tableau à trois colonnes : garde, perd, dette — oral, archive, radio."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis le même fait en trois phrases d'outils différents."
}$j$::jsonb,
    9
  );

  -- ===== Archives du Cahier du chemin =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Archives du Cahier du chemin'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Archives du Cahier du chemin', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Ouvrir le Cahier du chemin',
    'CO',
    $c$Objectif
Comprendre les gestes et les règles d'une archive vivante au Seuil.

Consigne
Lisez la séance d'ouverture. Qui a le droit d'écrire, de dater, de refuser ?

Support — Séance d'archives, table calée par Dieudonné
Solange Mukamana : On n'ouvre pas le Cahier du chemin comme on ouvre une valise. On date, on signe, on laisse une marge.
Sami : Si nous avions ouvert plus tôt, moins de pages auraient gondolé. C'est un regret utile, pas une honte.
Mado : J'écris à l'encre. Le crayon ment trop vite. La marge est pour le doute, pas pour la décoration.
Aline Uwase : Une archive n'appartient pas à celui qui parle le plus fort. Elle appartient à ceux qui pourront encore lire.
Lila Sow : Je peux déposer une bande. Je ne peux pas coller un slogan sur une page déjà sèche.
Marc Nkurunziza : Il fallut des règles : qui ajoute, qui relit, qui refuse un faux tampon.
Karim Bamba : Notez qui paie l'encre et l'huile. Sinon l'archive ment sur la société.
Rose Iradukunda : Je glisse un échantillon de lin, pas une publicité.
Léa Niyonzima : De Rive-des-Saules, j'enverrai une lettre. Elle devra entrer par la marge, pas par la une.
Patrick Habimana : Si j'avais su la règle de la marge, j'aurais moins écrit au milieu.
Hawa Diallo : Joël date les lanternes ; Félicie, un bol. Les gestes aussi s'archivent.
Dieudonné : La table tient. Sans cela, pas d'archive, seulement une pile.
Yvette : Notez les brûlures. Une archive adulte n'efface pas le danger.
Sami : Ce que le figuier a vu n'entre pas tout. Il entre ce que l'on peut encore vérifier, ou honnêtement imaginer.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Solange dit qu'on ouvre le cahier comme une valise, sans dater.",
  "correct": false,
  "explanation": "On n'ouvre pas le cahier comme une valise. On date, on signe, on laisse une marge."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À qui appartient l'archive, selon Aline ?",
  "options": [
    {
      "text": "À celui qui parle le plus fort",
      "correct": false
    },
    {
      "text": "À ceux qui pourront encore lire",
      "correct": true
    },
    {
      "text": "À Radio Figuier seulement",
      "correct": false
    },
    {
      "text": "Au Pavillon du Saule",
      "correct": false
    }
  ],
  "explanation": "Elle appartient à ceux qui pourront encore lire."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "dater / signer",
      "right": "règles d'ouverture"
    },
    {
      "left": "marge",
      "right": "le doute"
    },
    {
      "left": "encre",
      "right": "pas le crayon trop vite"
    },
    {
      "left": "faux tampon",
      "right": "refuser"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa marge est pour le ___, pas pour la décoration.",
  "answer": "doute"
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
    "on",
    "laisse",
    "une",
    "marge",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "chemin",
  "hint": "Nom du cahier : il mène d'une date à une autre, sans slogan."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si j'avais su la règle de la marge, j'aurais moins écrit au milieu, et je serai plus prudent si c'était à refaire.",
  "correct_sentence": "Si j'avais su la règle de la marge, j'aurais moins écrit au milieu, et je serais plus prudent si c'était à refaire.",
  "explanation": "Hypothèse non réelle : je serais, pas le futur je serai."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/figuier-racines.svg",
      "word": "des racines"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/radio-echo.svg",
      "word": "un écho"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/carte-rukiri.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/horloge-jadis.svg",
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
  "prompt": "Notez six règles d'archive entendues, et qui les prononce."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : On date, on signe, on laisse une marge. L'archive appartient à ceux qui pourront encore lire."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Feuillets du Cahier du chemin',
    'CE',
    $c$Objectif
Lire des extraits d'archives et en comprendre le statut (tenu / hypothesé).

Consigne
Lisez les feuillets, sans aller trop vite.

Support — Feuillets du Cahier du chemin, encre et marge
Feuillet 1. Sami écrivit : « Je tiens le tampon manquant. J'imagine une date après la pluie. »
Feuillet 2. Mado ajouta en marge : « Tache vérifiée. Bol de Félicie non mentionné dans la page sèche. »
Feuillet 3. Lila déposa : « Bande du vent. Dieudonné absent de l'écoute. Datée, signée. »
Il dit, plus bas, qu'une archive n'efface pas une autre voix : elle la cote.
Nous vîmes ensuite la main de Rose : un lin glissé, sans prix, avec un doute en marge sur le nom.
Karim vint et écrivit : « Huile : qui paie ? » — question, pas slogan.
Aline reprit : appartenir à ceux qui liront, c'est laisser de l'air, pas remplir.
Léa, de Rive-des-Saules, envoya une lettre : elle entra par la marge, comme convenu.
Yvette nota une brûlure ancienne ; Solange refusa un tampon trop neuf, trop sûr.
Dieudonné signa le calage de la table : sans ce geste, les feuillets glisseraient encore.
Joël data une lanterne trop haute : hypothèse utile pour demain, dit-il.
Hawa copia les règles : dater, signer, marger, séparer tenu et imaginé.
Patrick lut trop vite au milieu ; il promit la marge désormais.
Nous relûmes le tout lorsque le soleil baissa : l'archive était devenue une société, pas un tiroir.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Solange accepte un tampon trop neuf et trop sûr.",
  "correct": false,
  "explanation": "Solange refusa un tampon trop neuf, trop sûr."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment la lettre de Léa est-elle entrée dans le cahier ?",
  "options": [
    {
      "text": "Par la une, en slogan",
      "correct": false
    },
    {
      "text": "Par la marge, comme convenu",
      "correct": true
    },
    {
      "text": "Elle fut refusée",
      "correct": false
    },
    {
      "text": "Par Radio Figuier seulement",
      "correct": false
    }
  ],
  "explanation": "Elle entra par la marge, comme convenu."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "feuillet Sami",
      "right": "tenir / imaginer"
    },
    {
      "left": "marge de Mado",
      "right": "tache / bol oublié"
    },
    {
      "left": "bande de Lila",
      "right": "datée, signée"
    },
    {
      "left": "lettre de Léa",
      "right": "par la marge"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSami écrivit : je tiens le tampon manquant ; j'___ une date. (imaginer, prés.)",
  "answer": "imagine"
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
    "archive",
    "n'efface",
    "pas",
    "une",
    "autre",
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
  "word": "feuillet",
  "hint": "Page datée, signée, avec une marge pour le doute."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous vîmes la main de Rose, et il fallutons refuser un tampon trop sûr, trop neuf.",
  "correct_sentence": "Nous vîmes la main de Rose, et il fallut refuser un tampon trop sûr, trop neuf.",
  "explanation": "Passé simple : il fallut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/radio-echo.svg",
      "word": "un écho"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/carte-rukiri.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/horloge-jadis.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/groupe-anciens.svg",
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
  "prompt": "Pour quatre feuillets : ce qui est tenu, ce qui est imaginé, qui signe."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les feuillets, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire les règles de l''archive',
    'PO',
    $c$Objectif
Formuler à l'oral les gestes qui rendent une archive honnête.

Consigne
Répétez, puis dictez une règle d'archive et un exemple.

Support — Modèles de Solange et de Mado
On date, on signe, on laisse une marge.
La marge est pour le doute, pas pour la décoration.
J'écris à l'encre : le crayon ment trop vite.
Je sépare ce que je tiens et ce que j'imagine.
Je refuse un tampon trop neuf, trop sûr.
Une archive appartient à ceux qui pourront encore lire.
Je dépose une bande datée, je ne colle pas un slogan.
Notez qui paie l'encre et l'huile.
Les brûlures s'écrivent, elles ne s'effacent pas.
La lettre de loin entre par la marge, pas par la une.
Si j'avais su la règle, j'aurais moins écrit au milieu.
Solange : une règle, un exemple.
Mado : une phrase tenue, une phrase imaginée.
Dieudonné : d'abord la table, ensuite la page.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut coller un slogan sur une page déjà sèche, selon les modèles.",
  "correct": false,
  "explanation": "Je dépose une bande datée, je ne colle pas un slogan."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où entre la lettre de loin ?",
  "options": [
    {
      "text": "Par la une",
      "correct": false
    },
    {
      "text": "Par la marge",
      "correct": true
    },
    {
      "text": "Par Radio Figuier seulement",
      "correct": false
    },
    {
      "text": "Elle n'entre jamais",
      "correct": false
    }
  ],
  "explanation": "La lettre de loin entre par la marge, pas par la une."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "dater / signer",
      "right": "ouverture"
    },
    {
      "left": "marge",
      "right": "doute"
    },
    {
      "left": "encre",
      "right": "pas le crayon"
    },
    {
      "left": "tenu / imaginé",
      "right": "séparer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe refuse un tampon trop neuf, trop ___.",
  "answer": "sûr"
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
    "on",
    "laisse",
    "une",
    "marge",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "tampon",
  "hint": "Marque de date trop sûre que Solange refuse si elle est trop neuve."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On date on signe on laisse une marge, et je pourai encore écrire au milieu si je me presse.",
  "correct_sentence": "On date on signe on laisse une marge, et je pourrai encore écrire au milieu si je me presse.",
  "explanation": "Futur de pouvoir : je pourrai, deux r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/carte-rukiri.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/horloge-jadis.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/groupe-anciens.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/sami-recit.svg",
      "word": "un récit oral"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit règles d'archive, chacune en une phrase orale."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis deux règles à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma page pour le Cahier du chemin',
    'PE',
    $c$Objectif
Écrire une page d'archive : tenu, imaginé, daté, signé, marge.

Consigne
Imitez la page de Mado.

Support — Page de Mado, encre et marge
Mado — Cahier du chemin, Seuil des Sources
Je date : jeudi, après que Dieudonné a calé la table. Je signe. Je laisse une marge.
Je tiens : une tache de pluie, un tampon manquant, la bande du vent déposée par Lila.
J'imagine : une heure juste après l'orage, sans l'imprimer.
Si nous avions ouvert plus tôt, moins de pages auraient gondolé : regret utile.
Rose a glissé un lin, sans prix. Félicie n'apparaît pas encore : oubli à corriger, en marge.
Karim a écrit « qui paie l'huile ? » — question, pas slogan.
Léa entre par la marge, depuis Rive-des-Saules. Patrick promet de ne plus écrire au milieu.
Yvette note une brûlure. Solange refuse un tampon trop sûr.
Sami dit : ce que le figuier a vu n'entre pas tout ; entre ce que l'on peut vérifier.
Aline : cette page appartient à ceux qui pourront encore lire.
Voilà mon feuillet, ni trop plein, ni trop fier.
Mado
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Mado imprime l'heure imaginée au tampon.",
  "correct": false,
  "explanation": "J'imagine : une heure […] sans l'imprimer."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que dit Sami sur ce qui entre dans le cahier ?",
  "options": [
    {
      "text": "Tout ce que le figuier a vu",
      "correct": false
    },
    {
      "text": "Ce que l'on peut vérifier, pas tout",
      "correct": true
    },
    {
      "text": "Seulement les slogans",
      "correct": false
    },
    {
      "text": "Seulement les photos de Léa",
      "correct": false
    }
  ],
  "explanation": "N'entre pas tout ; entre ce que l'on peut vérifier."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je tiens",
      "right": "tache, tampon manquant, bande"
    },
    {
      "left": "j'imagine",
      "right": "une heure, sans imprimer"
    },
    {
      "left": "marge",
      "right": "Léa, oubli du bol"
    },
    {
      "left": "refus",
      "right": "tampon trop sûr"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi nous avions ouvert plus tôt, moins de pages ___ gondolé. (avoir, cond. passé)",
  "answer": "auraient"
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
    "date",
    "je",
    "signe",
    "je",
    "laisse",
    "une",
    "marge",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "marge",
  "hint": "Espace du doute, où entre la lettre de loin, pas le slogan."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je date je signe je laisse une marge, et je serais à la table demain à l'heure déjà fixée par Solange.",
  "correct_sentence": "Je date je signe je laisse une marge, et je serai à la table demain à l'heure déjà fixée par Solange.",
  "explanation": "Heure fixée : je serai, pas je serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/horloge-jadis.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/groupe-anciens.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/sami-recit.svg",
      "word": "un récit oral"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/mado-plume.svg",
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
  "prompt": "Imitez : une page datée, signée, tenue / imaginée, une marge, un refus."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre page d'archive, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Tenir une archive honnête',
    'EL',
    $c$Objectif
Retenir les gestes, la langue et les interdits du Cahier du chemin.

Consigne
Apprenez la fiche.

Support — Fiche de Solange, règles ocre
Ouvrir : dater, signer, laisser une marge.
Écrire à l'encre ; le crayon ment trop vite.
Séparer je tiens / j'imagine. Pas de faux tampon.
La marge : doute, lettre de loin, oubli à corriger (le bol).
Appartenir à ceux qui pourront encore lire : laisser de l'air.
Déposer une bande datée ≠ coller un slogan.
Noter qui paie l'encre et l'huile : l'archive dit aussi la société.
Noter les brûlures : une archive adulte n'efface pas le danger.
Si + PQP : si nous avions ouvert plus tôt, moins de pages auraient gondolé.
Passé simple lu : il dit, elle écrivit, nous vîmes, il fallut, Karim vint.
Bien que la page soit sèche, on peut encore marger.
Je ferai une copie (1 r) ; je pourrai relire (2 r) ; il faut une table calée.
Ce que le figuier a vu n'entre pas tout : entre ce que l'on vérifie.
Radio Figuier dépose, elle ne commande pas la une.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut encore ajouter une marge après que la page est sèche.",
  "correct": true,
  "explanation": "Bien que la page soit sèche, on peut encore marger."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quel couple doit rester séparé dans chaque feuillet ?",
  "options": [
    {
      "text": "soleil / lanterne seulement",
      "correct": false
    },
    {
      "text": "je tiens / j'imagine",
      "correct": true
    },
    {
      "text": "Rose / Félicie seulement",
      "correct": false
    },
    {
      "text": "pont / bol seulement",
      "correct": false
    }
  ],
  "explanation": "Séparer je tiens / j'imagine."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "dater / signer",
      "right": "ouverture"
    },
    {
      "left": "je tiens",
      "right": "vérifiable"
    },
    {
      "left": "j'imagine",
      "right": "hypothèse"
    },
    {
      "left": "marge",
      "right": "doute et lettre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nBien que la page ___ sèche, on peut encore marger. (être, subj.)",
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
    "Pas",
    "de",
    "faux",
    "tampon",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "encre",
  "hint": "Matière de la page honnête, plus lente que le crayon."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que la page soit sèche on peut encore marger, et il fautons une table calée.",
  "correct_sentence": "Bien que la page soit sèche on peut encore marger, et il faut une table calée.",
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
      "image_path": "/elearning/mfk-b2-m2/groupe-anciens.svg",
      "word": "un groupe"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/sami-recit.svg",
      "word": "un récit oral"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/mado-plume.svg",
      "word": "une plume"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/soleil-memoire.svg",
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
  "prompt": "Rédigez un règlement d'archive en dix phrases, avec deux exemples de langue."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis une mini-page datée de cinq lignes."
}$j$::jsonb,
    9
  );

  -- ===== Table ronde « ce que le figuier a vu » =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Table ronde « ce que le figuier a vu »'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Table ronde « ce que le figuier a vu »', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Ce que le figuier a vu',
    'CO',
    $c$Objectif
Suivre une table ronde qui synthétise hypothèses, métiers, lieux et voix.

Consigne
Lisez la table ronde. Qui synthétise, qui refuse la légende unique ?

Support — Table ronde sous le figuier, micro de Lila
Aline Uwase : D'une part nous tenons des gestes ; d'autre part nous imaginons des heures. Le figuier a vu les deux.
Sami : Ce qu'il a vu, ce n'est pas un slogan. C'est un sentier, une pluie, une table calée, un bol oublié.
Mado : En somme, l'archive n'a pas tout pris. Elle a pris ce que nous pouvions encore vérifier.
Lila Sow : Autrement dit, trois voix restent nécessaires : oral, cahier, bande.
Marc Nkurunziza : Certes une synthèse console ; toutefois elle ne doit pas devenir un tampon unique.
Dieudonné : Pour ma part, je témoigne du bois. Si je n'avais pas calé, vous n'auriez plus de pages.
Rose Iradukunda : Je concède que le lin n'est pas le centre. Néanmoins un métier oublié fausse la mémoire.
Félicie : Mon bol n'apparaissait nulle part. Désormais il est une dette, pas une décoration.
Léa Niyonzima : De l'autre rive, j'entends surtout la radio. Je dois encore le cahier.
Patrick Habimana : Si nous n'avions écouté qu'une voix, nous aurions une légende trop nette.
Karim Bamba : Reste que quelqu'un paie l'huile, l'encre, le micro. La mémoire a un prix.
Yvette : Le danger vu par l'arbre — flammes trop hautes — doit rester dans la synthèse.
Solange Mukamana : Je refuse le faux tampon « tout a été dit ».
Joël Mugisha : Quoi que l'on vote, j'accrocherai moins haut : le vent, le figuier l'a vu.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Solange accepte le tampon « tout a été dit » pour clore la table ronde.",
  "correct": false,
  "explanation": "Je refuse le faux tampon « tout a été dit »."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Lila, combien de voix restent nécessaires ?",
  "options": [
    {
      "text": "Une seule, la radio",
      "correct": false
    },
    {
      "text": "Trois : oral, cahier, bande",
      "correct": true
    },
    {
      "text": "Aucune",
      "correct": false
    },
    {
      "text": "Seulement l'archive",
      "correct": false
    }
  ],
  "explanation": "Trois voix restent nécessaires : oral, cahier, bande."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'une part / d'autre part",
      "right": "tenir / imaginer"
    },
    {
      "left": "en somme",
      "right": "l'archive n'a pas tout pris"
    },
    {
      "left": "certes / toutefois",
      "right": "synthèse ≠ tampon"
    },
    {
      "left": "reste que",
      "right": "la mémoire a un prix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi nous n'avions écouté qu'une voix, nous ___ une légende trop nette. (avoir, cond. passé)",
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
    "Je",
    "refuse",
    "le",
    "faux",
    "tampon",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "ronde",
  "hint": "Table où les voix tournent, sans qu'une seule referme le cercle."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si nous n'avions écouté qu'une voix, nous aurions une légende trop nette, et je ferrai une synthèse trop lisse.",
  "correct_sentence": "Si nous n'avions écouté qu'une voix, nous aurions une légende trop nette, et je ferai une synthèse trop lisse.",
  "explanation": "Futur de faire : je ferai, un seul r."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/sami-recit.svg",
      "word": "un récit oral"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/mado-plume.svg",
      "word": "une plume"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/soleil-memoire.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/nuage-si.svg",
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
  "prompt": "Relevez six prises de parole et l'argument que chacune apporte à la synthèse."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : D'une part nous tenons. D'autre part nous imaginons. En somme, l'archive n'a pas tout pris."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Compte rendu : ce que le figuier a vu',
    'CE',
    $c$Objectif
Lire le compte rendu argumenté de la table ronde.

Consigne
Lisez le compte rendu de Marc, sans aller trop vite.

Support — Compte rendu de Marc Nkurunziza, feuille pour le cahier
La table ronde ne chercha pas une légende : elle chercha une mémoire tenable.
Aline ouvrit : d'une part les gestes tenus, d'autre part les heures imaginées.
Sami dit alors que le figuier avait vu un sentier, une pluie, une table, un bol oublié — pas un slogan.
Mado conclut, en somme, que l'archive n'avait pas tout pris, et que c'était juste.
Lila exigea trois voix ; Marc concéda qu'une synthèse console, toutefois elle ne tamponne pas.
Dieudonné prit la parole : si je n'avais pas calé, vous n'auriez plus de pages. Nous vîmes l'outil, enfin.
Rose et Félicie rappelèrent les métiers oubliés ; Karim, le prix de l'huile et de l'encre.
Léa, de Rive-des-Saules, écrivit qu'elle entendait surtout la radio et qu'elle devait encore le cahier.
Patrick ajouta l'hypothèse : une seule voix aurait fait une légende trop nette.
Yvette imposa le danger ; Joël promit des lanternes moins hautes ; Solange refusa « tout a été dit ».
Hawa nota les absents trop vite nommés : une synthèse n'efface pas une marge.
Il fallut voter sur des gestes — caler, dater, relayer, payer — non sur un mythe.
Nous relûmes le compte rendu lorsque le soleil baissa : le figuier n'avait pas parlé, il avait porté.
Radio Figuier diffuserait ce texte dès que Lila aurait coupé les insultes, pas les doutes.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le compte rendu dit que l'on vota sur un mythe, non sur des gestes.",
  "correct": false,
  "explanation": "Il fallut voter sur des gestes […], non sur un mythe."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que promit Joël, à la fin de la table ronde ?",
  "options": [
    {
      "text": "De fermer le figuier",
      "correct": false
    },
    {
      "text": "Des lanternes moins hautes",
      "correct": true
    },
    {
      "text": "De vendre l'huile",
      "correct": false
    },
    {
      "text": "De taire Yvette",
      "correct": false
    }
  ],
  "explanation": "Joël promit des lanternes moins hautes."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Sami",
      "right": "sentier, pluie, table, bol"
    },
    {
      "left": "Dieudonné",
      "right": "caler ou plus de pages"
    },
    {
      "left": "Léa",
      "right": "radio d'abord, cahier encore"
    },
    {
      "left": "Solange",
      "right": "refus de « tout a été dit »"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDès que Lila ___ coupé les insultes, Radio Figuier diffuserait. (avoir, FA / cond. contexte)",
  "answer": "aurait"
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
    "fallut",
    "voter",
    "sur",
    "des",
    "gestes",
    "."
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
  "hint": "Ce que l'on tient et ce que l'on imagine, sans mythe unique. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il fallut voter sur des gestes, et bien que le figuier n'avait pas parlé il avait porté.",
  "correct_sentence": "Il fallut voter sur des gestes, et bien que le figuier n'ait pas parlé il avait porté.",
  "explanation": "Bien que + subjonctif : n'ait pas parlé, pas l'indicatif n'avait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/mado-plume.svg",
      "word": "une plume"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/soleil-memoire.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/nuage-si.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/feuille-archive.svg",
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
  "prompt": "Résumez la table ronde en huit lignes : quatre voix, deux refus, un vote."
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
    'PO — Dire la synthèse de la table ronde',
    'PO',
    $c$Objectif
Tenir à l'oral une synthèse : connecteurs, hypothèses, refus du mythe.

Consigne
Répétez, puis tenez deux minutes : « ce que le figuier a vu ».

Support — Modèles d'Aline, Sami et Marc
D'une part nous tenons des gestes ; d'autre part nous imaginons des heures.
En somme, l'archive n'a pas tout pris, et c'est juste.
Autrement dit, trois voix restent nécessaires.
Certes une synthèse console ; toutefois elle ne tamponne pas.
Reste que la mémoire a un prix : huile, encre, micro.
Si nous n'avions écouté qu'une voix, nous aurions une légende trop nette.
Je refuse le faux tampon « tout a été dit ».
Quoi que l'on vote, Joël accrochera moins haut.
Pour ma part, je témoigne du bois, du bol, du lin.
Le figuier n'a pas parlé : il a porté.
Aline : une phrase pour, une phrase contre, une phrase de synthèse.
Sami : nommez un geste vu, pas un devoir moral trop large.
Lila : une phrase, une pause.
Solange : gardez une marge, même à l'oral.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« En somme » sert ici à rouvrir trois dossiers oubliés.",
  "correct": false,
  "explanation": "En somme clôt : l'archive n'a pas tout pris, et c'est juste."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que dit-on du figuier, dans les modèles ?",
  "options": [
    {
      "text": "Qu'il a parlé clairement",
      "correct": false
    },
    {
      "text": "Qu'il n'a pas parlé : il a porté",
      "correct": true
    },
    {
      "text": "Qu'il a voté",
      "correct": false
    },
    {
      "text": "Qu'il faut le couper",
      "correct": false
    }
  ],
  "explanation": "Le figuier n'a pas parlé : il a porté."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'une part / d'autre part",
      "right": "tenir / imaginer"
    },
    {
      "left": "en somme",
      "right": "clôture juste"
    },
    {
      "left": "si + PQP",
      "right": "légende trop nette"
    },
    {
      "left": "je refuse",
      "right": "tampon unique"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe figuier n'a pas parlé : il a ___.",
  "answer": "porté"
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
    "le",
    "faux",
    "tampon",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "temoin",
  "hint": "Celui qui dit un geste vu, sans inventer un mythe. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Quoi que l'on vote, Joël accrochera moins haut, et je serais sous l'arbre demain à l'heure dite de la table.",
  "correct_sentence": "Quoi que l'on vote, Joël accrochera moins haut, et je serai sous l'arbre demain à l'heure dite de la table.",
  "explanation": "Rendez-vous réel : je serai, pas je serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/soleil-memoire.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/nuage-si.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/feuille-archive.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/hypothese-passe.svg",
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
  "prompt": "Écrivez une synthèse orale de douze phrases, avec six connecteurs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit premiers modèles, puis votre synthèse de deux minutes."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma motion : ce que le figuier a vu',
    'PE',
    $c$Objectif
Écrire une motion de synthèse pour clore la table ronde.

Consigne
Imitez la motion d'Aline Uwase.

Support — Motion d'Aline, banc du figuier
Aline Uwase — motion pour le Seuil des Sources
D'une part nous tenons : un sentier au-delà, une tache, une table calée, un ourlet payé, un bol trop longtemps oublié.
D'autre part nous imaginons des heures, sans faux tampon.
En somme, ce que le figuier a vu n'est pas un mythe : c'est une suite de gestes et de dettes.
Certes une synthèse console ; toutefois elle n'efface ni la marge de Mado, ni la bande de Lila, ni l'oral de Sami.
Si nous n'avions écouté qu'une voix, nous aurions trahi l'arbre en le faisant parler trop net.
Je propose : dater, caler, relayer, payer, garder trois voix, refuser « tout a été dit ».
Quoi que Léa entende d'abord de Rive-des-Saules, le cahier lui reste dû.
Yvette : le danger reste. Joël : moins haut. Karim : qui paie. Dieudonné : la table.
Pour ma part, j'enseignerai encore à séparer tenu et imaginé.
Je serai sous l'arbre jeudi, lorsque nous aurons signé cette motion.
Aline
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline veut faire parler le figuier d'une voix trop nette.",
  "correct": false,
  "explanation": "Une seule voix aurait trahi l'arbre en le faisant parler trop net."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que propose Aline, concrètement ?",
  "options": [
    {
      "text": "Un slogan unique",
      "correct": false
    },
    {
      "text": "Dater, caler, relayer, payer, garder trois voix, refuser la formule trop sûre",
      "correct": true
    },
    {
      "text": "Fermer Radio Figuier",
      "correct": false
    },
    {
      "text": "Vendre le cahier",
      "correct": false
    }
  ],
  "explanation": "Dater, caler, relayer, payer, garder trois voix, refuser « tout a été dit »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "d'une part",
      "right": "gestes tenus"
    },
    {
      "left": "d'autre part",
      "right": "heures imaginées"
    },
    {
      "left": "en somme",
      "right": "suite de gestes et de dettes"
    },
    {
      "left": "je propose",
      "right": "six verbes de motion"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLorsque nous ___ signé cette motion, je serai sous l'arbre. (avoir, FA)",
  "answer": "aurons"
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
    "un",
    "mythe",
    "."
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
  "hint": "Texte voté qui propose des gestes, pas un mythe."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lorsque nous aurons signé cette motion, je serais sous l'arbre jeudi, et Lila ouvrira le micro.",
  "correct_sentence": "Lorsque nous aurons signé cette motion, je serai sous l'arbre jeudi, et Lila ouvrira le micro.",
  "explanation": "Jeudi fixé : je serai, pas je serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-b2-m2/nuage-si.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/feuille-archive.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/hypothese-passe.svg",
      "word": "une hypothèse"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/si-pqp.svg",
      "word": "un plus-que-parfait"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : une motion de douze lignes, connecteurs, une hypothèse, six verbes de geste."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre motion, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Synthèse de mémoire sous le figuier',
    'EL',
    $c$Objectif
Retenir la langue de la table ronde : hypothèse, voix, motion.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline et de Marc, clôture ocre
Table ronde : d'une part / d'autre part ; en somme ; autrement dit ; certes / toutefois ; reste que.
Hypothèse : si + PQP + conditionnel passé (si nous n'avions écouté qu'une voix, nous aurions une légende).
Tenir / imaginer : séparés, toujours, même dans une motion.
Trois voix : oral, archive, radio — publier, dater, refuser le tampon unique.
Métiers dans la mémoire : Dieudonné, Aline, Lila, Rose, Félicie, Joël — les nommer.
Lieux : au-delà, en contrebas, à travers — situer avant de légender.
Passé simple lu dans les comptes rendus : il dit, elle prit, nous vîmes, il fallut.
Bien que le figuier n'ait pas parlé, il a porté (subjonctif après bien que).
Je serai jeudi (réel) / je serais (hypothèse) / j'aurais (cond. passé, avoir).
Je ferai (1 r) ; je pourrai (2 r) ; il faut (3e pers.).
Motion : proposer des gestes (dater, caler, relayer, payer), pas un mythe.
Ce que le figuier a vu : une suite, pas un slogan.
Radio Figuier diffuse après la coupe des insultes, pas des doutes.
Il faut une marge, même à la clôture.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La motion doit proposer un mythe plutôt que des gestes.",
  "correct": false,
  "explanation": "Proposer des gestes, pas un mythe."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle construction suit « bien que » dans la fiche ?",
  "options": [
    {
      "text": "l'indicatif seulement",
      "correct": false
    },
    {
      "text": "le subjonctif (n'ait pas parlé)",
      "correct": true
    },
    {
      "text": "l'impératif",
      "correct": false
    },
    {
      "text": "le futur antérieur seulement",
      "correct": false
    }
  ],
  "explanation": "Bien que le figuier n'ait pas parlé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "si + PQP",
      "right": "conditionnel passé"
    },
    {
      "left": "tenir / imaginer",
      "right": "séparer"
    },
    {
      "left": "trois voix",
      "right": "oral archive radio"
    },
    {
      "left": "motion",
      "right": "gestes, pas mythe"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nBien que le figuier n'___ pas parlé, il a porté. (avoir, subj.)",
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
    "une",
    "marge",
    "même",
    "à",
    "la",
    "clôture",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "cloture",
  "hint": "Fin de la table ronde, avec une marge encore ouverte. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Bien que le figuier n'ait pas parlé il a porté, et il fautons une marge même à la fin.",
  "correct_sentence": "Bien que le figuier n'ait pas parlé il a porté, et il faut une marge même à la fin.",
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
      "image_path": "/elearning/mfk-b2-m2/feuille-archive.svg",
      "word": "une feuille"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/hypothese-passe.svg",
      "word": "une hypothèse"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/si-pqp.svg",
      "word": "un plus-que-parfait"
    },
    {
      "image_path": "/elearning/mfk-b2-m2/conditionnel-passe.svg",
      "word": "un conditionnel"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau final : hypothèse, trois voix, prépositions, connecteurs de synthèse — un exemple chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis une motion de cinq phrases."
}$j$::jsonb,
    9
  );

END;
$$;
