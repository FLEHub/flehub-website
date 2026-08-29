/*
  Seed eLearning MFK — A2 — Escale en France

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a2-m1/
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
  v_module_title text := 'A2 — Escale en France';
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
      'Grande étape A2-1 : comparer des séjours, faire des démarches, organiser un déplacement, trouver un logement, situer un lieu et suivre un itinéraire — sous le figuier du Seuil des Sources (Rukiri-Nord), avec une escale inventée à Val-des-Peupliers.',
      'A2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape A2-1 : comparer des séjours, faire des démarches, organiser un déplacement, trouver un logement, situer un lieu et suivre un itinéraire — sous le figuier du Seuil des Sources (Rukiri-Nord), avec une escale inventée à Val-des-Peupliers.',
      cefr_level = 'A2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Comparer des séjours =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Comparer des séjours'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Comparer des séjours', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Deux séjours sous le figuier',
    'CO',
    $c$Objectif
Comprendre une comparaison de séjours : plus… que, moins… que, aussi… que.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui compare quoi ?

Support — Banc du Seuil, carnet de Léa
Léa : Mon séjour à Mwezi-Haut était plus calme que celui de Patrick.
Patrick : C'est vrai. Le mien était moins calme, mais plus vivant.
Aline : Le stage à Val-des-Peupliers est aussi long que celui de l'an dernier.
Marc : L'Auberge des Figues est plus proche que la Maison des Vents.
Hawa : Moi, je trouve le lac des Nénuphars moins cher que Port de la Brise.
Joël : Le minibus Figuier 7 est aussi pratique que la Moto-Figuier.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa dit que Mwezi-Haut était plus calme que le séjour de Patrick.",
  "correct": true,
  "explanation": "Léa : « plus calme que celui de Patrick. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Marc, quel lieu est plus proche ?",
  "options": [
    {
      "text": "La Maison des Vents",
      "correct": false
    },
    {
      "text": "L'Auberge des Figues",
      "correct": true
    },
    {
      "text": "Port de la Brise",
      "correct": false
    },
    {
      "text": "Le Bureau des Escales",
      "correct": false
    }
  ],
  "explanation": "Marc : « L'Auberge des Figues est plus proche que la Maison des Vents. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus calme que",
      "right": "Léa / Mwezi-Haut"
    },
    {
      "left": "moins calme",
      "right": "Patrick"
    },
    {
      "left": "aussi long que",
      "right": "Aline / le stage"
    },
    {
      "left": "moins cher que",
      "right": "Hawa / le lac"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe stage est ___ long que celui de l'an dernier.",
  "answer": "aussi"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "L'Auberge",
    "est",
    "plus",
    "proche",
    "que",
    "la",
    "Maison",
    "."
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
  "hint": "Un séjour sans bruit, plus… que l'autre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le lac est plus cher que Port de la Brise, d'après Hawa.",
  "correct_sentence": "Le lac est moins cher que Port de la Brise, d'après Hawa.",
  "explanation": "Hawa dit moins cher, pas plus cher."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/comparatif-sejours.svg",
      "word": "comparer"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/valise-aline.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/billet-escale.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/carte-valpeupliers.svg",
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
  "prompt": "Notez trois comparaisons entendues (plus / moins / aussi)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Mon séjour était plus calme. Le tien était moins cher. Le stage est aussi long."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fiches de comparaison',
    'CE',
    $c$Objectif
Lire des fiches qui comparent deux séjours.

Consigne
Lisez les fiches épinglées au figuier, sans aller trop vite.

Support — Tableau ocre, Salle des Herbes
Fiche Léa — Mwezi-Haut : plus haut, moins bruyant, aussi vert que le Seuil.
Fiche Patrick — Val-des-Peupliers : plus de cours, moins de silence, aussi loin que Port de la Brise.
Fiche Rose — Île de Sable-Rouge : plus chaude que Rive d'Orage, moins chère que l'Auberge.
Fiche Solange Mukamana — Bureau des Escales : les dossiers sont plus clairs que l'an dernier.
Règle : plus + adj + que / moins + adj + que / aussi + adj + que.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose écrit que l'île est moins chère que l'Auberge.",
  "correct": true,
  "explanation": "Fiche Rose : « moins chère que l'Auberge. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui parle de dossiers plus clairs ?",
  "options": [
    {
      "text": "Léa",
      "correct": false
    },
    {
      "text": "Patrick",
      "correct": false
    },
    {
      "text": "Rose",
      "correct": false
    },
    {
      "text": "Solange",
      "correct": true
    }
  ],
  "explanation": "Fiche Solange, Bureau des Escales."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus haut",
      "right": "Léa"
    },
    {
      "left": "plus de cours",
      "right": "Patrick"
    },
    {
      "left": "plus chaude",
      "right": "Rose"
    },
    {
      "left": "plus clairs",
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
  "prompt": "Complétez :\nMwezi-Haut est ___ bruyant que la ville.",
  "answer": "moins"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Val-des-Peupliers",
    "est",
    "aussi",
    "loin",
    "que",
    "Port",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "moins",
  "hint": "Le contraire de plus, devant un adjectif."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "L'île est plus chère que l'Auberge, écrit Rose.",
  "correct_sentence": "L'île est moins chère que l'Auberge, écrit Rose.",
  "explanation": "Rose écrit moins chère."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/bureau-escales.svg",
      "word": "un bureau"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/formulaire-y.svg",
      "word": "un formulaire"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/enveloppe-en.svg",
      "word": "une enveloppe"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/affiche-demarche.svg",
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
  "prompt": "Recopiez une fiche et ajoutez une comparaison à vous."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les quatre fiches à voix haute, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire plus, moins, aussi',
    'PO',
    $c$Objectif
Comparer deux lieux ou deux séjours à voix haute.

Consigne
Répétez les modèles, puis comparez deux lieux du Seuil.

Support — Modèles d'Aline
Le Seuil est plus calme que le marché.
Le marché est moins calme que le Seuil.
La Table des Sources est aussi ouverte que l'infirmerie.
Mon sac est plus léger que celui de Marc.
Ta chambre sera moins chère que l'auberge.
Ce stage est aussi utile que le précédent.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Aussi » sert à dire que deux choses sont égales.",
  "correct": true,
  "explanation": "Aussi + adjectif + que = égalité."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase marque une égalité ?",
  "options": [
    {
      "text": "plus calme que",
      "correct": false
    },
    {
      "text": "moins cher que",
      "correct": false
    },
    {
      "text": "aussi utile que",
      "correct": true
    },
    {
      "text": "meilleur que",
      "correct": false
    }
  ],
  "explanation": "Aussi + adjectif + que."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus… que",
      "right": "supériorité"
    },
    {
      "left": "moins… que",
      "right": "infériorité"
    },
    {
      "left": "aussi… que",
      "right": "égalité"
    },
    {
      "left": "celui de Marc",
      "right": "le sac de Marc"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa Table est ___ ouverte que l'infirmerie.",
  "answer": "aussi"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Mon",
    "sac",
    "est",
    "plus",
    "léger",
    "que",
    "le",
    "tien",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "aussi",
  "hint": "Pour dire une égalité : … grand que."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le Seuil est plus calme que le marché n'est.",
  "correct_sentence": "Le Seuil est plus calme que le marché.",
  "explanation": "Après que, on reprend le nom, sans n'est ici."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/minibus-figuier.svg",
      "word": "un minibus"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/sac-marc.svg",
      "word": "un sac"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/horaire-train.svg",
      "word": "un horaire"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/plan-quai.svg",
      "word": "un plan"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six comparaisons : deux plus, deux moins, deux aussi."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six modèles, puis deux comparaisons à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma fiche de séjour',
    'PE',
    $c$Objectif
Écrire une courte fiche qui compare deux séjours.

Consigne
Imitez la fiche de Patrick.

Support — Fiche de Patrick, Cahier du chemin
Patrick Habimana
Mon séjour à Val-des-Peupliers sera plus long que celui de Léa.
Il sera moins cher que l'Auberge des Figues.
Les cours seront aussi denses que ceux d'Aline.
Je prendrai un sac plus léger que l'an dernier.
Patrick
Seuil des Sources — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick écrit que son séjour sera plus court que celui de Léa.",
  "correct": false,
  "explanation": "« sera plus long que celui de Léa. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que compare Patrick avec l'Auberge ?",
  "options": [
    {
      "text": "La durée",
      "correct": false
    },
    {
      "text": "Le prix",
      "correct": true
    },
    {
      "text": "La couleur",
      "correct": false
    },
    {
      "text": "Le silence",
      "correct": false
    }
  ],
  "explanation": "« moins cher que l'Auberge »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus long",
      "right": "Léa"
    },
    {
      "left": "moins cher",
      "right": "l'Auberge"
    },
    {
      "left": "aussi denses",
      "right": "les cours d'Aline"
    },
    {
      "left": "plus léger",
      "right": "le sac"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes cours seront ___ denses que ceux d'Aline.",
  "answer": "aussi"
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
    "sera",
    "moins",
    "cher",
    "que",
    "l'Auberge",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "leger",
  "hint": "Plus… que l'an dernier : un sac qui pèse peu. (sans accent)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Mon séjour sera plus longue que celui de Léa.",
  "correct_sentence": "Mon séjour sera plus long que celui de Léa.",
  "explanation": "Séjour est masculin : long, pas longue."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/annonce-chambre.svg",
      "word": "une annonce"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/cle-logement.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/regle-colocation.svg",
      "word": "une règle"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/fenetre-cour.svg",
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
  "prompt": "Imitez : cinq lignes, trois comparatifs différents."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre fiche, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Plus, moins, aussi',
    'EL',
    $c$Objectif
Retenir la forme des comparatifs d'égalité et d'inégalité.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
plus + adjectif + que : plus calme que
moins + adjectif + que : moins cher que
aussi + adjectif + que : aussi long que
Accord : un séjour plus long / une auberge plus proche / des cours plus denses
celui / celle / ceux / celles pour éviter de répéter : celui de Patrick
Attention : bon → meilleur (pas plus bon). Petit → plus petit (ou moindre, rare).
Ne pas dire : plus bien. On dit mieux.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « plus bon » pour comparer deux plats.",
  "correct": false,
  "explanation": "On dit meilleur, pas plus bon."
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
      "text": "plus bien",
      "correct": false
    },
    {
      "text": "mieux",
      "correct": true
    },
    {
      "text": "plus bonnement",
      "correct": false
    },
    {
      "text": "aussi bien que pas",
      "correct": false
    }
  ],
  "explanation": "Mieux remplace plus bien."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plus… que",
      "right": "supériorité"
    },
    {
      "left": "moins… que",
      "right": "infériorité"
    },
    {
      "left": "aussi… que",
      "right": "égalité"
    },
    {
      "left": "meilleur",
      "right": "comparatif de bon"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCe thé est ___ que l'autre. (bon)",
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
    "Cette",
    "chambre",
    "est",
    "plus",
    "proche",
    "que",
    "l'autre",
    "."
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
  "hint": "Le comparatif de bon, pas « plus bon »."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ce stage est plus bon que l'autre.",
  "correct_sentence": "Ce stage est meilleur que l'autre.",
  "explanation": "Bon → meilleur."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/maison-vents.svg",
      "word": "une maison"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/jardin-haut.svg",
      "word": "un jardin"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/escalier-gauche.svg",
      "word": "un escalier"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/banc-dessous.svg",
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
  "prompt": "Conjuguez cinq adjectifs au comparatif (plus / moins / aussi / meilleur)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis trois exemples à vous."
}$j$::jsonb,
    9
  );

  -- ===== Premières démarches =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Premières démarches'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Premières démarches', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Au Bureau des Escales',
    'CO',
    $c$Objectif
Repérer les pronoms y et en dans des démarches.

Consigne
Lisez le dialogue. Où va-t-on ? De quoi parle-t-on ?

Support — Guichet de Solange Mukamana
Solange : Vous avez les papiers ? J'y pense depuis hier.
Léa : Oui. J'en ai trois : une photo, une lettre, un tampon.
Patrick : On y va demain matin, au Bureau des Escales.
Aline : N'y allez pas trop tard. On y reste une heure.
Marc : J'en parle à Radio Figuier ce soir.
Hawa : Moi, j'en prends une copie. J'y retourne jeudi.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa a trois papiers.",
  "correct": true,
  "explanation": "Léa : « J'en ai trois. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que remplace « y » dans « On y va demain » ?",
  "options": [
    {
      "text": "Les papiers",
      "correct": false
    },
    {
      "text": "Le Bureau des Escales",
      "correct": true
    },
    {
      "text": "Radio Figuier",
      "correct": false
    },
    {
      "text": "La copie",
      "correct": false
    }
  ],
  "explanation": "Y = au Bureau des Escales (lieu)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "j'y pense",
      "right": "à la démarche"
    },
    {
      "left": "j'en ai trois",
      "right": "des papiers"
    },
    {
      "left": "on y va",
      "right": "au bureau"
    },
    {
      "left": "j'en parle",
      "right": "de la démarche"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nN'___ allez pas trop tard.",
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
    "J'en",
    "prends",
    "une",
    "copie",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "pense",
  "hint": "J'y… depuis hier : avoir dans la tête."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'y ai trois papiers.",
  "correct_sentence": "J'en ai trois papiers.",
  "explanation": "En remplace de + nom (des papiers)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/bureau-escales.svg",
      "word": "un bureau"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/formulaire-y.svg",
      "word": "un formulaire"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/enveloppe-en.svg",
      "word": "une enveloppe"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/affiche-demarche.svg",
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
  "prompt": "Notez deux phrases avec y et deux avec en."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : J'y pense. J'en ai trois. On y va demain. J'en parle ce soir."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Mot du bureau',
    'CE',
    $c$Objectif
Lire un mot officiel qui utilise y et en.

Consigne
Lisez le mot, sans aller trop vite.

Support — Mot de Solange, tampon ocre
Bureau des Escales — Val-des-Peupliers (ville inventée)
Chers voyageurs du Seuil,
Pensez-y avant jeudi. Apportez-en deux copies.
On y reçoit le matin seulement.
N'en parlez pas trop vite autour de vous : les places sont limitées.
Vous y trouverez Karim Bamba, au deuxième bureau.
Solange Mukamana
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On reçoit toute la journée au bureau.",
  "correct": false,
  "explanation": "« On y reçoit le matin seulement. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui se trouve au deuxième bureau ?",
  "options": [
    {
      "text": "Aline",
      "correct": false
    },
    {
      "text": "Karim Bamba",
      "correct": true
    },
    {
      "text": "Joël",
      "correct": false
    },
    {
      "text": "Rose",
      "correct": false
    }
  ],
  "explanation": "« Vous y trouverez Karim Bamba. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "pensez-y",
      "right": "à la démarche"
    },
    {
      "left": "apportez-en",
      "right": "des copies"
    },
    {
      "left": "on y reçoit",
      "right": "au bureau"
    },
    {
      "left": "n'en parlez pas",
      "right": "de l'offre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nApportez-___ deux copies.",
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
    "y",
    "reçoit",
    "le",
    "matin",
    "seulement",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "copies",
  "hint": "Il en faut deux, pour le dossier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Pensez-en avant jeudi.",
  "correct_sentence": "Pensez-y avant jeudi.",
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
      "image_path": "/elearning/mfk-a2-m1/valise-aline.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/billet-escale.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/carte-valpeupliers.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/bureau-escales.svg",
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
  "prompt": "Recopiez le mot et soulignez y et en."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le mot de Solange, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire y et en',
    'PO',
    $c$Objectif
Remplacer un lieu ou une quantité par y ou en.

Consigne
Répétez, puis parlez d'une démarche à vous.

Support — Modèles de Patrick
J'y vais demain.
Tu y penses ?
Nous en parlons ce soir.
J'en ai assez.
N'y restez pas trop longtemps.
Elle en prend deux.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Y » remplace souvent un lieu introduit par à, chez, dans.",
  "correct": true,
  "explanation": "Aller à / penser à → y."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase utilise en pour une quantité ?",
  "options": [
    {
      "text": "J'y vais",
      "correct": false
    },
    {
      "text": "Tu y penses",
      "correct": false
    },
    {
      "text": "J'en ai assez",
      "correct": true
    },
    {
      "text": "N'y restez pas",
      "correct": false
    }
  ],
  "explanation": "En = de cela / une quantité."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "y",
      "right": "à ce lieu / à cela"
    },
    {
      "left": "en",
      "right": "de cela / une quantité"
    },
    {
      "left": "j'y vais",
      "right": "au bureau"
    },
    {
      "left": "j'en ai",
      "right": "des copies"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ parlons ce soir.",
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
    "N'y",
    "restez",
    "pas",
    "trop",
    "longtemps",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "assez",
  "hint": "J'en ai… : la quantité suffit."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je vais y demain au bureau.",
  "correct_sentence": "J'y vais demain au bureau.",
  "explanation": "Y se place avant le verbe conjugué."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/panneau-qui.svg",
      "word": "un panneau"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/fleche-que.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/carnet-itineraire.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/pont-riviere.svg",
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
  "prompt": "Écrivez quatre phrases : deux y, deux en."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six modèles, puis deux phrases à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma liste de démarches',
    'PE',
    $c$Objectif
Écrire une liste de démarches avec y et en.

Consigne
Imitez la liste de Léa.

Support — Liste de Léa, enveloppe ocre
Léa Niyonzima
J'y vais lundi, au Bureau des Escales.
J'en apporte deux photos.
J'y pense chaque soir.
J'en parle à Aline.
N'oubliez pas le tampon.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa apporte deux photos.",
  "correct": true,
  "explanation": "« J'en apporte deux photos. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À qui Léa en parle-t-elle ?",
  "options": [
    {
      "text": "Marc",
      "correct": false
    },
    {
      "text": "Aline",
      "correct": true
    },
    {
      "text": "Karim",
      "correct": false
    },
    {
      "text": "Hawa",
      "correct": false
    }
  ],
  "explanation": "« J'en parle à Aline. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "j'y vais",
      "right": "lundi"
    },
    {
      "left": "j'en apporte",
      "right": "photos"
    },
    {
      "left": "j'y pense",
      "right": "chaque soir"
    },
    {
      "left": "j'en parle",
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
  "prompt": "Complétez :\nJ'___ apporte deux photos.",
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
    "chaque",
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
  "word": "tampon",
  "hint": "Il ne faut pas l'oublier sur le dossier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "N'en oubliez pas le tampon au bureau.",
  "correct_sentence": "N'oubliez pas le tampon au bureau.",
  "explanation": "Oublier quelque chose : n'oubliez pas (pas n'en oubliez pas ici)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/table-sources.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/cahier-chemin.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/horloge-depart.svg",
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
  "prompt": "Imitez : cinq lignes avec y et en."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre liste, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Pronoms y et en',
    'EL',
    $c$Objectif
Retenir la place et le sens de y et en.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
Y remplace : à + lieu / à + chose (penser à, aller à, rester à).
En remplace : de + nom / une quantité (parler de, avoir de, prendre de).
Place : y / en avant le verbe : j'y vais, j'en parle.
À l'impératif affirmatif : vas-y, prends-en. Négatif : n'y va pas, n'en prends pas.
Attention : j'y (élision). Pas : je y.
Ne pas confondre : j'en ai (quantité) / j'y suis (lieu).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « je y vais ».",
  "correct": false,
  "explanation": "Élision : j'y vais."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Parler de la démarche » se remplace par…",
  "options": [
    {
      "text": "y parler",
      "correct": false
    },
    {
      "text": "en parler",
      "correct": true
    },
    {
      "text": "le parler",
      "correct": false
    },
    {
      "text": "lui parler",
      "correct": false
    }
  ],
  "explanation": "Parler de → en parler."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "aller à",
      "right": "y aller"
    },
    {
      "left": "penser à",
      "right": "y penser"
    },
    {
      "left": "parler de",
      "right": "en parler"
    },
    {
      "left": "avoir des copies",
      "right": "en avoir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___-y ! (impératif de aller, tu)",
  "answer": "Vas"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "N'en",
    "prends",
    "pas",
    "trop",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "endroit",
  "hint": "Y remplace souvent un… (un lieu)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je y pense depuis hier.",
  "correct_sentence": "J'y pense depuis hier.",
  "explanation": "Élision : j'y."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/cahier-chemin.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/horloge-depart.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/nuage-pluie.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/soleil-arrivee.svg",
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
  "prompt": "Transformez : Je vais au bureau. / J'ai deux photos. / Je parle de cela."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et trois transformations."
}$j$::jsonb,
    9
  );

  -- ===== Organiser un déplacement =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Organiser un déplacement'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Organiser un déplacement', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Qui prépare le trajet',
    'CO',
    $c$Objectif
Comprendre qui / à qui on donne, on dit, on montre (COD / COI).

Consigne
Lisez le dialogue. Qui fait quoi à qui ?

Support — Table des Sources, cartes étalées
Marc : Je le prépare, le trajet. Je te le montre.
Léa : Tu me le donnes ce soir ?
Aline : Je lui explique l'horaire. Je le lui répète.
Patrick : Nous les prenons, les billets. On vous les laisse.
Hawa : Je leur écris un mot, à Solange et à Karim.
Joël : Ne me le dis pas trop vite : j'écoute.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc montre le trajet à Léa.",
  "correct": true,
  "explanation": "« Je te le montre. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que signifie « Je le lui répète » ?",
  "options": [
    {
      "text": "Aline répète l'horaire à Patrick",
      "correct": false
    },
    {
      "text": "Aline répète l'horaire à Léa (lui = Léa ou Patrick)",
      "correct": true
    },
    {
      "text": "Aline répète les billets",
      "correct": false
    },
    {
      "text": "Joël répète un mot",
      "correct": false
    }
  ],
  "explanation": "Le = l'horaire (COD). Lui = à la personne (COI)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le / les",
      "right": "COD chose"
    },
    {
      "left": "me / te / nous / vous",
      "right": "COI personne"
    },
    {
      "left": "lui / leur",
      "right": "à lui / à eux"
    },
    {
      "left": "je leur écris",
      "right": "à Solange et Karim"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ le montre. (à toi)",
  "answer": "te"
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
    "le",
    "lui",
    "répète",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "horaire",
  "hint": "Aline le lui explique : les heures du trajet."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je lui le répète.",
  "correct_sentence": "Je le lui répète.",
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
      "image_path": "/elearning/mfk-a2-m1/minibus-figuier.svg",
      "word": "un minibus"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/sac-marc.svg",
      "word": "un sac"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/horaire-train.svg",
      "word": "un horaire"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/plan-quai.svg",
      "word": "un plan"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez qui donne quoi à qui."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je te le montre. Je le lui répète. On vous les laisse."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Billets et messages',
    'CE',
    $c$Objectif
Lire des messages qui enchaînent COD et COI.

Consigne
Lisez les messages, sans aller trop vite.

Support — Cahier du chemin, page ocre
Message de Marc : Je les ai pris, les billets. Je te les apporte.
Message d'Aline : Explique-lui le quai. Répète-le-lui.
Message de Hawa : Écris-leur. Ne leur dis pas le prix trop haut.
Message de Lila Sow : Je vous les envoie, les horaires. Lisez-les.
Ordre : me/te/nous/vous/lui/leur + le/la/les… sauf le lui / le leur.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila envoie les horaires.",
  "correct": true,
  "explanation": "« Je vous les envoie, les horaires. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle consigne d'Aline est correcte ?",
  "options": [
    {
      "text": "Explique-le-lui le quai",
      "correct": false
    },
    {
      "text": "Explique-lui le quai",
      "correct": true
    },
    {
      "text": "Lui explique le",
      "correct": false
    },
    {
      "text": "Explique le lui quai",
      "correct": false
    }
  ],
  "explanation": "Impératif : explique-lui + COD nominal."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je te les apporte",
      "right": "billets → toi"
    },
    {
      "left": "répète-le-lui",
      "right": "horaire → lui"
    },
    {
      "left": "ne leur dis pas",
      "right": "à eux"
    },
    {
      "left": "je vous les envoie",
      "right": "horaires → vous"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe te ___ apporte. (les billets)",
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
    "les",
    "envoie",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "quai",
  "hint": "Aline veut qu'on lui explique ce bord de voie."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Répète-lui-le.",
  "correct_sentence": "Répète-le-lui.",
  "explanation": "À l'impératif : le avant lui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/nuage-pluie.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/soleil-arrivee.svg",
      "word": "un soleil"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/comparatif-sejours.svg",
      "word": "comparer"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/valise-aline.svg",
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
  "prompt": "Réécrivez deux messages en remplaçant les noms par des pronoms."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les quatre messages, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Le, la, lui, leur',
    'PO',
    $c$Objectif
Placer COD et COI dans une phrase orale.

Consigne
Répétez, puis parlez d'un trajet à organiser.

Support — Modèles de Marc
Je le prépare.
Je te le donne.
Je le lui explique.
Nous vous les laissons.
Je leur écris.
Ne me le cache pas.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Lui » et « leur » sont des COI.",
  "correct": true,
  "explanation": "À lui / à eux → lui / leur."
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
      "text": "Je lui le donne",
      "correct": false
    },
    {
      "text": "Je le lui donne",
      "correct": true
    },
    {
      "text": "Je donne le lui",
      "correct": false
    },
    {
      "text": "Je le donne lui",
      "correct": false
    }
  ],
  "explanation": "Je le lui donne."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le / la / les",
      "right": "COD"
    },
    {
      "left": "lui / leur",
      "right": "COI"
    },
    {
      "left": "me / te",
      "right": "COI (ou COD)"
    },
    {
      "left": "ne me le cache pas",
      "right": "ordre : ne + pronoms + verbe"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ lui explique. (le trajet)",
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
  "word": "cache",
  "hint": "Ne me le… pas : garder l'info pour soi."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous les vous laissons.",
  "correct_sentence": "Nous vous les laissons.",
  "explanation": "vous avant les."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/annonce-chambre.svg",
      "word": "une annonce"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/cle-logement.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/regle-colocation.svg",
      "word": "une règle"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/fenetre-cour.svg",
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
  "prompt": "Écrivez cinq phrases avec deux pronoms."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six modèles, puis deux phrases à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon plan de trajet',
    'PE',
    $c$Objectif
Écrire un plan de déplacement avec des pronoms.

Consigne
Imitez le plan de Hawa.

Support — Plan de Hawa Diallo
Hawa Diallo
Je le prépare, le trajet vers Val-des-Peupliers.
Je te le montre demain.
Je le lui envoie, à Solange.
Nous vous les donnons, les copies.
Ne me les oubliez pas.
Hawa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa envoie le trajet à Solange.",
  "correct": true,
  "explanation": "« Je le lui envoie, à Solange. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que donne le groupe ?",
  "options": [
    {
      "text": "Les valises",
      "correct": false
    },
    {
      "text": "Les copies",
      "correct": true
    },
    {
      "text": "Les clés",
      "correct": false
    },
    {
      "text": "Les tasses",
      "correct": false
    }
  ],
  "explanation": "« Nous vous les donnons, les copies. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "je le prépare",
      "right": "trajet"
    },
    {
      "left": "je te le montre",
      "right": "à toi"
    },
    {
      "left": "je le lui envoie",
      "right": "Solange"
    },
    {
      "left": "nous vous les donnons",
      "right": "copies"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe le ___ envoie, à Solange.",
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
    "Je",
    "te",
    "le",
    "montre",
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
  "word": "copies",
  "hint": "On vous les donne : des… du dossier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ne me les oublie pas les copies.",
  "correct_sentence": "Ne me les oubliez pas.",
  "explanation": "Impératif vous + pronoms, sans répéter le nom."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/maison-vents.svg",
      "word": "une maison"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/jardin-haut.svg",
      "word": "un jardin"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/escalier-gauche.svg",
      "word": "un escalier"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/banc-dessous.svg",
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
  "prompt": "Imitez : un plan de cinq lignes avec pronoms."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre plan, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — COD et COI, synthèse',
    'EL',
    $c$Objectif
Retenir l'ordre des pronoms et les verbes à COI.

Consigne
Apprenez la fiche.

Support — Fiche de synthèse
COD : me te le la nous vous les (l' devant voyelle)
COI : me te lui nous vous leur
Ordre fréquent : me/te/nous/vous + le/la/les
mais : le/la/les + lui/leur → je le lui dis
Verbes à COI : parler à, donner à, écrire à, expliquer à, envoyer à
Verbes à COD : préparer, montrer, prendre, laisser, cacher
Attention : je lui parle (pas je le parle, pour une personne).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je le parle » pour « je parle à Marc ».",
  "correct": false,
  "explanation": "Parler à → je lui parle."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle série est dans le bon ordre ?",
  "options": [
    {
      "text": "lui le",
      "correct": false
    },
    {
      "text": "le lui",
      "correct": true
    },
    {
      "text": "les vous",
      "correct": false
    },
    {
      "text": "leur les je",
      "correct": false
    }
  ],
  "explanation": "le lui."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "donner à",
      "right": "COI"
    },
    {
      "left": "préparer",
      "right": "COD"
    },
    {
      "left": "je le lui dis",
      "right": "ordre"
    },
    {
      "left": "je lui parle",
      "right": "personne"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ parle. (à Aline)",
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
    "Je",
    "le",
    "leur",
    "envoie",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "expliquer",
  "hint": "Un verbe à COI : … à quelqu'un l'horaire."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je le parle à Marc.",
  "correct_sentence": "Je lui parle.",
  "explanation": "Parler à une personne → lui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/panneau-qui.svg",
      "word": "un panneau"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/fleche-que.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/carnet-itineraire.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/pont-riviere.svg",
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
  "prompt": "Classez six verbes : COD, COI, ou les deux."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et quatre exemples."
}$j$::jsonb,
    9
  );

  -- ===== Trouver un logement =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Trouver un logement'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Trouver un logement', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Annonce à la Maison des Vents',
    'CO',
    $c$Objectif
Comprendre des consignes pour un logement : impératif, il faut, ne… jamais / plus / rien.

Consigne
Lisez le dialogue. Quelles règles entend-on ?

Support — Cour de la Maison des Vents
Karim : Lisez l'annonce. Appelez le matin.
Aline : Il faut montrer une pièce. Vous devez arriver avant vingt et une heures.
Léa : Ne faites jamais de bruit après vingt-deux heures.
Patrick : N'apportez plus de valise trop grande.
Rose : Ne laissez rien dans le couloir.
Joël : Demandez la clé. Ne la perdez pas.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut faire du bruit après vingt-deux heures.",
  "correct": false,
  "explanation": "Léa : « Ne faites jamais de bruit après vingt-deux heures. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quand faut-il arriver, d'après Aline ?",
  "options": [
    {
      "text": "Après minuit",
      "correct": false
    },
    {
      "text": "Avant vingt et une heures",
      "correct": true
    },
    {
      "text": "À midi seulement",
      "correct": false
    },
    {
      "text": "Le dimanche",
      "correct": false
    }
  ],
  "explanation": "« Vous devez arriver avant vingt et une heures. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lisez / appelez",
      "right": "impératif"
    },
    {
      "left": "il faut montrer",
      "right": "obligation"
    },
    {
      "left": "ne… jamais",
      "right": "à aucun moment"
    },
    {
      "left": "ne… rien",
      "right": "aucune chose"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNe laissez ___ dans le couloir.",
  "answer": "rien"
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
    "montrer",
    "une",
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
  "word": "jamais",
  "hint": "Ne faites… de bruit : à aucun moment."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Vous devez d'arriver avant vingt et une heures.",
  "correct_sentence": "Vous devez arriver avant vingt et une heures.",
  "explanation": "Devoir + infinitif, sans de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/annonce-chambre.svg",
      "word": "une annonce"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/cle-logement.svg",
      "word": "une clé"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/regle-colocation.svg",
      "word": "une règle"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/fenetre-cour.svg",
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
  "prompt": "Listez trois obligations et deux interdictions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Lisez l'annonce. Il faut montrer une pièce. Ne laissez rien dans le couloir."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Règlement de colocation',
    'CE',
    $c$Objectif
Lire un règlement avec impératif et négation renforcée.

Consigne
Lisez le règlement, sans aller trop vite.

Support — Feuille épinglée, Maison des Vents
Règlement — chambres du Seuil / relais de Val-des-Peupliers
1. Arrivez avant vingt et une heures. Il faut signer le cahier.
2. Ne fumez jamais dans la cour.
3. N'invitez plus d'inconnus sans prévenir Aline.
4. Ne jetez rien par la fenêtre.
5. Vous devez ranger le banc. Il ne faut pas laisser les tasses.
6. Demandez, n'exigez pas.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On peut fumer dans la cour.",
  "correct": false,
  "explanation": "« Ne fumez jamais dans la cour. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que faut-il signer ?",
  "options": [
    {
      "text": "Un contrat de ville",
      "correct": false
    },
    {
      "text": "Le cahier",
      "correct": true
    },
    {
      "text": "Un passeport",
      "correct": false
    },
    {
      "text": "Une carte bleue",
      "correct": false
    }
  ],
  "explanation": "« Il faut signer le cahier. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "arrivez",
      "right": "avant 21 h"
    },
    {
      "left": "ne… jamais",
      "right": "fumer"
    },
    {
      "left": "n'invitez plus",
      "right": "sans prévenir"
    },
    {
      "left": "ne… rien",
      "right": "par la fenêtre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl ne faut ___ laisser les tasses.",
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
    "Ne",
    "fumez",
    "jamais",
    "dans",
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
  "word": "ranger",
  "hint": "Vous devez… le banc : tout remettre en place."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut de signer le cahier.",
  "correct_sentence": "Il faut signer le cahier.",
  "explanation": "Il faut + infinitif, sans de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/maison-vents.svg",
      "word": "une maison"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/jardin-haut.svg",
      "word": "un jardin"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/escalier-gauche.svg",
      "word": "un escalier"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/banc-dessous.svg",
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
  "prompt": "Recopiez le règlement et ajoutez une règle à vous."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six points, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Conseiller et interdire',
    'PO',
    $c$Objectif
Donner des consignes : impératif, devoir, il faut, ne… jamais / plus / rien.

Consigne
Répétez, puis donnez des règles pour une chambre.

Support — Modèles d'Aline
Appelez le matin.
Vous devez arriver tôt.
Il faut demander la clé.
Ne faites jamais de bruit.
N'apportez plus ce sac trop grand.
Ne laissez rien ici.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'impératif peut servir à conseiller.",
  "correct": true,
  "explanation": "Appelez, demandez, rangez…"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle négation signifie « à aucun moment » ?",
  "options": [
    {
      "text": "ne… plus",
      "correct": false
    },
    {
      "text": "ne… jamais",
      "correct": true
    },
    {
      "text": "ne… rien",
      "correct": false
    },
    {
      "text": "ne… personne",
      "correct": false
    }
  ],
  "explanation": "Jamais = à aucun moment."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "devoir + infinitif",
      "right": "obligation"
    },
    {
      "left": "il faut + infinitif",
      "right": "obligation"
    },
    {
      "left": "ne… plus",
      "right": "cesser"
    },
    {
      "left": "ne… rien",
      "right": "aucune chose"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVous ___ arriver tôt.",
  "answer": "devez"
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
    "demander",
    "la",
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
  "word": "devez",
  "hint": "Vous… arriver tôt : forme de devoir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut que demander la clé.",
  "correct_sentence": "Il faut demander la clé.",
  "explanation": "Ici : il faut + infinitif (le subjonctif vient plus tard)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/table-sources.svg",
      "word": "une table"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/cahier-chemin.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/horloge-depart.svg",
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
  "prompt": "Écrivez six consignes : deux impératifs, deux il faut, deux négations."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six modèles, puis trois règles à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon mot au logement',
    'PE',
    $c$Objectif
Écrire un mot de règles pour une colocation.

Consigne
Imitez le mot de Rose.

Support — Mot de Rose Iradukunda
Rose Iradukunda
Arrivez avant vingt et une heures.
Il faut signer le cahier. Vous devez ranger la tasse.
Ne faites jamais de bruit tard.
N'oubliez plus la clé.
Ne laissez rien sous le banc.
Rose
Maison des Vents — relais du Seuil
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose demande de laisser les affaires sous le banc.",
  "correct": false,
  "explanation": "« Ne laissez rien sous le banc. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase utilise devoir ?",
  "options": [
    {
      "text": "Arrivez avant vingt et une heures",
      "correct": false
    },
    {
      "text": "Vous devez ranger la tasse",
      "correct": true
    },
    {
      "text": "Ne faites jamais de bruit",
      "correct": false
    },
    {
      "text": "Rose",
      "correct": false
    }
  ],
  "explanation": "« Vous devez ranger la tasse. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "arrivez",
      "right": "impératif"
    },
    {
      "left": "il faut signer",
      "right": "cahier"
    },
    {
      "left": "vous devez ranger",
      "right": "tasse"
    },
    {
      "left": "ne… jamais",
      "right": "bruit"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nN'oubliez ___ la clé.",
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
    "Ne",
    "laissez",
    "rien",
    "sous",
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
  "word": "signer",
  "hint": "Il faut… le cahier à l'arrivée."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ne faites jamais de bruits tard le soir.",
  "correct_sentence": "Ne faites jamais de bruit tard le soir.",
  "explanation": "Bruit au singulier dans cette règle."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/billet-escale.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/carte-valpeupliers.svg",
      "word": "une carte"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/bureau-escales.svg",
      "word": "un bureau"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/formulaire-y.svg",
      "word": "un formulaire"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes de règlement."
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
    'EL — Impératif, devoir, négation',
    'EL',
    $c$Objectif
Retenir l'impératif, devoir / il faut, ne… jamais / plus / rien / personne.

Consigne
Apprenez la fiche.

Support — Fiche de la Maison des Vents
Impératif : arrive / arrivez ; demande / demandez ; lis / lisez
devoir + infinitif : vous devez arriver
il faut + infinitif : il faut signer (toujours il)
Négation renforcée :
ne… pas / ne… plus (cesser) / ne… jamais (aucun moment)
ne… rien (aucune chose) / ne… personne (aucun être)
Place : Ne faites jamais. Ne laissez rien. N'invitez plus.
Attention : il faut (pas je faut). Devoir : je dois, tu dois, il doit, nous devons.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Ne… plus » veut dire « à aucun moment ».",
  "correct": false,
  "explanation": "Plus = cesser. Jamais = à aucun moment."
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
      "text": "je faut signer",
      "correct": false
    },
    {
      "text": "il faut signer",
      "correct": true
    },
    {
      "text": "tu faut signer",
      "correct": false
    },
    {
      "text": "nous faut signer",
      "correct": false
    }
  ],
  "explanation": "Toujours il faut."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ne… plus",
      "right": "cesser"
    },
    {
      "left": "ne… jamais",
      "right": "aucun moment"
    },
    {
      "left": "ne… rien",
      "right": "aucune chose"
    },
    {
      "left": "ne… personne",
      "right": "aucun être"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ ranger le banc. (devoir)",
  "answer": "devons"
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
    "devez",
    "arriver",
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
  "word": "personne",
  "hint": "Ne… ici : aucun être humain dans le couloir."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je dois d'arriver avant vingt et une heures.",
  "correct_sentence": "Je dois arriver avant vingt et une heures.",
  "explanation": "Devoir + infinitif, sans de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/enveloppe-en.svg",
      "word": "une enveloppe"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/affiche-demarche.svg",
      "word": "une affiche"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/minibus-figuier.svg",
      "word": "un minibus"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/sac-marc.svg",
      "word": "un sac"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Complétez un tableau : impératif tu/vous, devoir, quatre négations."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et quatre exemples."
}$j$::jsonb,
    9
  );

  -- ===== Un lieu pas comme les autres =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un lieu pas comme les autres'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un lieu pas comme les autres', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Visite de la Maison des Vents',
    'CO',
    $c$Objectif
Repérer où se trouvent les choses : ici, là-bas, dehors, au-dessus, à gauche…

Consigne
Lisez le dialogue. Où est chaque lieu ?

Support — Seuil de la Maison des Vents
Karim : Entrez. Ici, c'est l'accueil. Là-bas, c'est le jardin.
Léa : Le puits est dehors, derrière la cuisine.
Marc : La chambre est en haut, au-dessus de la salle.
Hawa : Le banc est en bas, à gauche de l'escalier.
Aline : Posez les sacs ici, tout près. Pas là-bas, trop loin.
Patrick : On se retrouve dehors, au milieu de la cour.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le puits est à l'intérieur, devant la cuisine.",
  "correct": false,
  "explanation": "Léa : « dehors, derrière la cuisine. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où est la chambre ?",
  "options": [
    {
      "text": "En bas, à gauche",
      "correct": false
    },
    {
      "text": "En haut, au-dessus de la salle",
      "correct": true
    },
    {
      "text": "Dehors, derrière",
      "correct": false
    },
    {
      "text": "Au milieu du puits",
      "correct": false
    }
  ],
  "explanation": "Marc : « en haut, au-dessus de la salle. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ici",
      "right": "accueil"
    },
    {
      "left": "là-bas",
      "right": "jardin"
    },
    {
      "left": "dehors / derrière",
      "right": "puits"
    },
    {
      "left": "en haut / au-dessus",
      "right": "chambre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe banc est en bas, ___ gauche de l'escalier.",
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
    "se",
    "retrouve",
    "dehors",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "dehors",
  "hint": "Pas à l'intérieur : dans la cour, …"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La chambre est en bas, au-dessus de la salle.",
  "correct_sentence": "La chambre est en haut, au-dessus de la salle.",
  "explanation": "Au-dessus va avec en haut."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/maison-vents.svg",
      "word": "une maison"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/jardin-haut.svg",
      "word": "un jardin"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/escalier-gauche.svg",
      "word": "un escalier"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/banc-dessous.svg",
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
  "prompt": "Placez cinq objets du dialogue avec un adverbe de lieu."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Ici c'est l'accueil. Là-bas c'est le jardin. Le puits est dehors."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Plan annoté',
    'CE',
    $c$Objectif
Lire un plan avec des locutions de lieu.

Consigne
Lisez la légende, sans aller trop vite.

Support — Plan de Lila Sow
Maison des Vents — légende
Accueil : ici, juste à l'entrée.
Jardin : là-bas, tout au fond.
Puits : dehors, derrière la cuisine, tout près du muret.
Chambre ocre : en haut, au-dessus de la Salle des Herbes.
Banc : en bas, à droite de l'escalier, au milieu des pots.
Attention : tout près ≠ trop loin. En haut ≠ en bas.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le jardin est tout au fond.",
  "correct": true,
  "explanation": "« là-bas, tout au fond. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Le banc est…",
  "options": [
    {
      "text": "à gauche du puits",
      "correct": false
    },
    {
      "text": "à droite de l'escalier",
      "correct": true
    },
    {
      "text": "au-dessus de l'accueil",
      "correct": false
    },
    {
      "text": "derrière Lila",
      "correct": false
    }
  ],
  "explanation": "« à droite de l'escalier »."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "juste à l'entrée",
      "right": "accueil"
    },
    {
      "left": "tout au fond",
      "right": "jardin"
    },
    {
      "left": "tout près du muret",
      "right": "puits"
    },
    {
      "left": "au milieu des pots",
      "right": "banc"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa chambre est en haut, ___-dessus de la salle.",
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
    "Le",
    "jardin",
    "est",
    "là-bas",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "entree",
  "hint": "L'accueil est juste à l'… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le puits est dedans, derrière la cuisine.",
  "correct_sentence": "Le puits est dehors, derrière la cuisine.",
  "explanation": "Derrière la cuisine = dehors."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/escalier-gauche.svg",
      "word": "un escalier"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/banc-dessous.svg",
      "word": "un banc"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/panneau-qui.svg",
      "word": "un panneau"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/fleche-que.svg",
      "word": "une flèche"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Redessinez le plan en cinq phrases de lieu."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez la légende, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Situer un lieu',
    'PO',
    $c$Objectif
Situer des objets avec des adverbes et locutions.

Consigne
Répétez, puis décrivez la cour du Seuil.

Support — Modèles de Karim
C'est ici.
C'est là-bas.
Le puits est dehors.
La salle est en bas.
La chambre est au-dessus.
Le banc est à gauche, tout près.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Tout près » est le contraire de « trop loin ».",
  "correct": true,
  "explanation": "Distance courte vs longue."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle locution indique une position haute ?",
  "options": [
    {
      "text": "en bas",
      "correct": false
    },
    {
      "text": "au-dessus",
      "correct": true
    },
    {
      "text": "derrière",
      "correct": false
    },
    {
      "text": "au milieu",
      "correct": false
    }
  ],
  "explanation": "Au-dessus = plus haut."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ici / là-bas",
      "right": "proche / distant"
    },
    {
      "left": "dehors / dedans",
      "right": "extérieur / intérieur"
    },
    {
      "left": "en haut / en bas",
      "right": "vertical"
    },
    {
      "left": "à gauche / à droite",
      "right": "horizontal"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe banc est ___ près.",
  "answer": "tout"
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
    "chambre",
    "est",
    "au-dessus",
    "."
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
  "hint": "Le contraire de à droite."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le banc est à le gauche.",
  "correct_sentence": "Le banc est à gauche.",
  "explanation": "À gauche, sans article."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/carnet-itineraire.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/pont-riviere.svg",
      "word": "un pont"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/radio-figuier.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/table-sources.svg",
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
  "prompt": "Décrivez six lieux avec six locutions différentes."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six modèles, puis la cour du Seuil."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon plan de lieu',
    'PE',
    $c$Objectif
Écrire un plan court avec des locutions de lieu.

Consigne
Imitez le plan de Marc.

Support — Plan de Marc Nkurunziza
Marc Nkurunziza
Ici, c'est l'accueil. Là-bas, le jardin.
Le puits est dehors, derrière la cuisine.
Ma chambre est en haut, au-dessus de la salle.
Le banc est en bas, à gauche, tout près.
On se retrouve au milieu de la cour.
Marc
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc se retrouve au milieu de la cour.",
  "correct": true,
  "explanation": "Dernière ligne du plan."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où Marc place-t-il sa chambre ?",
  "options": [
    {
      "text": "Dehors",
      "correct": false
    },
    {
      "text": "En haut",
      "correct": true
    },
    {
      "text": "Au puits",
      "correct": false
    },
    {
      "text": "À droite du marché",
      "correct": false
    }
  ],
  "explanation": "« en haut, au-dessus de la salle. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ici",
      "right": "accueil"
    },
    {
      "left": "là-bas",
      "right": "jardin"
    },
    {
      "left": "dehors",
      "right": "puits"
    },
    {
      "left": "en haut",
      "right": "chambre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn se retrouve ___ milieu de la cour.",
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
    "Le",
    "puits",
    "est",
    "dehors",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "milieu",
  "hint": "Au… de la cour : ni à gauche ni à droite."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ma chambre est en haut, au-dessous de la salle.",
  "correct_sentence": "Ma chambre est en haut, au-dessus de la salle.",
  "explanation": "Au-dessus = plus haut. Au-dessous = plus bas."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/cahier-chemin.svg",
      "word": "un cahier"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/horloge-depart.svg",
      "word": "une horloge"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/nuage-pluie.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/soleil-arrivee.svg",
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
  "prompt": "Imitez : six lignes de plan."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre plan, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Adverbes et locutions de lieu',
    'EL',
    $c$Objectif
Retenir ici, là-bas, dehors, en haut, au-dessus, à gauche, tout près…

Consigne
Apprenez la fiche.

Support — Fiche de Lila
Adverbes : ici, là, là-bas, dehors, dedans, partout, loin, près
Locutions : en haut / en bas ; à gauche / à droite ; au-dessus / au-dessous
devant / derrière ; à côté de ; au milieu de ; tout près de ; tout au fond
Contractions : à + le = au (au milieu). De + le = du (près du muret).
Attention : au-dessus (accent et trait). Pas : au dessus.
À gauche (pas à le gauche).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « au dessus » en deux mots, sans trait.",
  "correct": false,
  "explanation": "Au-dessus, avec un trait d'union."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« À + le milieu » donne…",
  "options": [
    {
      "text": "à le milieu",
      "correct": false
    },
    {
      "text": "au milieu",
      "correct": true
    },
    {
      "text": "aux milieu",
      "correct": false
    },
    {
      "text": "du milieu",
      "correct": false
    }
  ],
  "explanation": "À + le = au."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ici",
      "right": "proche de moi"
    },
    {
      "left": "là-bas",
      "right": "plus loin"
    },
    {
      "left": "au-dessus",
      "right": "plus haut"
    },
    {
      "left": "au-dessous",
      "right": "plus bas"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe banc est ___ côté de l'escalier.",
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
    "C'est",
    "tout",
    "au",
    "fond",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "derriere",
  "hint": "Le contraire de devant (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Posez les sacs à le milieu de la cour.",
  "correct_sentence": "Posez les sacs au milieu de la cour.",
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
      "image_path": "/elearning/mfk-a2-m1/horaire-train.svg",
      "word": "un horaire"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/plan-quai.svg",
      "word": "un plan"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/annonce-chambre.svg",
      "word": "une annonce"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/cle-logement.svg",
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
  "prompt": "Faites une liste de douze mots de lieu, avec un exemple chacun."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six exemples."
}$j$::jsonb,
    9
  );

  -- ===== Suivre un itinéraire =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Suivre un itinéraire'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Suivre un itinéraire', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le chemin que Marc indique',
    'CO',
    $c$Objectif
Comprendre un itinéraire avec qui, que, à qui, avec qui.

Consigne
Lisez le dialogue. Qui fait le chemin ? Que voit-on ?

Support — Départ sous le figuier
Marc : Prenez le sentier qui descend vers le pont.
Léa : Le pont que tu décris, c'est celui des Herbes ?
Aline : La personne à qui vous demandez, c'est Solange.
Patrick : Le guide avec qui on marche, c'est Karim.
Hawa : Les panneaux qui sont ocre montrent la droite.
Joël : La rue que vous suivez va jusqu'au Bureau des Escales.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le sentier qui descend va vers le pont.",
  "correct": true,
  "explanation": "Marc : « le sentier qui descend vers le pont. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À qui faut-il demander, d'après Aline ?",
  "options": [
    {
      "text": "Karim",
      "correct": false
    },
    {
      "text": "Solange",
      "correct": true
    },
    {
      "text": "Joël",
      "correct": false
    },
    {
      "text": "Rose",
      "correct": false
    }
  ],
  "explanation": "« La personne à qui vous demandez, c'est Solange. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui descend",
      "right": "sentier / sujet"
    },
    {
      "left": "que tu décris",
      "right": "pont / COD"
    },
    {
      "left": "à qui vous demandez",
      "right": "Solange"
    },
    {
      "left": "avec qui on marche",
      "right": "Karim"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe guide ___ qui on marche, c'est Karim.",
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
    "Prenez",
    "le",
    "sentier",
    "qui",
    "descend",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "sentier",
  "hint": "Le petit chemin qui descend vers le pont."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Le pont qui tu décris est loin.",
  "correct_sentence": "Le pont que tu décris est loin.",
  "explanation": "Que = COD. Qui = sujet."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/panneau-qui.svg",
      "word": "un panneau"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/fleche-que.svg",
      "word": "une flèche"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/carnet-itineraire.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/pont-riviere.svg",
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
  "prompt": "Notez quatre relatives : qui, que, à qui, avec qui."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Le sentier qui descend. Le pont que tu décris. La personne à qui vous demandez."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Itinéraire écrit',
    'CE',
    $c$Objectif
Lire un itinéraire avec des relatifs.

Consigne
Lisez la feuille, sans aller trop vite.

Support — Feuille de Karim Bamba
Itinéraire Seuil → Bureau des Escales
1. Suivez le mur qui borde le figuier.
2. Traversez le pont que les enfants appellent « pont des Herbes ».
3. Demandez à la femme à qui Solange a laissé la clé : c'est Yvette.
4. Marchez avec le groupe avec qui Patrick part à huit heures.
5. Les flèches qui sont peintes en ocre tournent à droite.
6. La place que vous voyez alors, c'est le Bureau.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Yvette est la femme à qui Solange a laissé la clé.",
  "correct": true,
  "explanation": "Point 3 de l'itinéraire."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que font les flèches ocre ?",
  "options": [
    {
      "text": "Elles montent",
      "correct": false
    },
    {
      "text": "Elles tournent à droite",
      "correct": true
    },
    {
      "text": "Elles s'arrêtent",
      "correct": false
    },
    {
      "text": "Elles cachent le pont",
      "correct": false
    }
  ],
  "explanation": "« tournent à droite. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui borde",
      "right": "mur"
    },
    {
      "left": "que les enfants appellent",
      "right": "pont"
    },
    {
      "left": "à qui Solange a laissé",
      "right": "Yvette"
    },
    {
      "left": "avec qui Patrick part",
      "right": "groupe"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSuivez le mur ___ borde le figuier.",
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
    "Traversez",
    "le",
    "pont",
    "que",
    "vous",
    "voyez",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "fleches",
  "hint": "Elles sont ocre et tournent (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La place qui vous voyez alors, c'est le Bureau.",
  "correct_sentence": "La place que vous voyez alors, c'est le Bureau.",
  "explanation": "Vous voyez la place → que (COD)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/comparatif-sejours.svg",
      "word": "comparer"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/valise-aline.svg",
      "word": "une valise"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/billet-escale.svg",
      "word": "un billet"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/carte-valpeupliers.svg",
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
  "prompt": "Recopiez l'itinéraire et encadrez les relatifs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six points, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Relier avec qui et que',
    'PO',
    $c$Objectif
Relier deux informations : qui, que, à qui, avec qui.

Consigne
Répétez, puis décrivez un chemin du Seuil.

Support — Modèles d'Aline
C'est le sentier qui descend.
C'est le pont que je connais.
C'est la personne à qui je demande.
C'est le guide avec qui nous marchons.
Ce sont les panneaux qui tournent.
C'est la rue que vous suivez.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Qui » est sujet de la relative.",
  "correct": true,
  "explanation": "Le sentier qui descend : qui = le sentier."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "On dit « la personne… je demande » comment ?",
  "options": [
    {
      "text": "qui",
      "correct": false
    },
    {
      "text": "que",
      "correct": false
    },
    {
      "text": "à qui",
      "correct": true
    },
    {
      "text": "dont",
      "correct": false
    }
  ],
  "explanation": "Demander à quelqu'un → à qui."
}$j$::jsonb,
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
      "right": "COD"
    },
    {
      "left": "à qui",
      "right": "COI"
    },
    {
      "left": "avec qui",
      "right": "accompagnement"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est le pont ___ je connais.",
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
    "le",
    "guide",
    "avec",
    "qui",
    "nous",
    "marchons",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "connais",
  "hint": "Le pont que je… : j'ai déjà vu ce pont."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est la personne que je demande l'heure.",
  "correct_sentence": "C'est la personne à qui je demande l'heure.",
  "explanation": "Demander à → à qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/minibus-figuier.svg",
      "word": "un minibus"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/sac-marc.svg",
      "word": "un sac"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/horaire-train.svg",
      "word": "un horaire"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/plan-quai.svg",
      "word": "un plan"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six relatives : deux de chaque type (qui / que / à qui / avec qui : mélangez)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les six modèles, puis un itinéraire à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon itinéraire',
    'PE',
    $c$Objectif
Écrire un itinéraire avec des pronoms relatifs.

Consigne
Imitez l'itinéraire de Léa.

Support — Itinéraire de Léa Niyonzima
Léa Niyonzima
Suivez le sentier qui part du figuier.
Traversez le pont que Marc a décrit.
Demandez à la personne à qui Aline a écrit.
Marchez avec le groupe avec qui Patrick part.
La place que vous voyez, c'est le Bureau des Escales.
Léa
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa part du figuier.",
  "correct": true,
  "explanation": "« le sentier qui part du figuier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Avec qui Léa dit-elle de marcher ?",
  "options": [
    {
      "text": "Le groupe de Patrick",
      "correct": true
    },
    {
      "text": "Karim seul",
      "correct": false
    },
    {
      "text": "Rose",
      "correct": false
    },
    {
      "text": "Les enfants du pont",
      "correct": false
    }
  ],
  "explanation": "« le groupe avec qui Patrick part. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "qui part",
      "right": "sentier"
    },
    {
      "left": "que Marc a décrit",
      "right": "pont"
    },
    {
      "left": "à qui Aline a écrit",
      "right": "personne"
    },
    {
      "left": "avec qui Patrick part",
      "right": "groupe"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa place ___ vous voyez, c'est le Bureau.",
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
    "Suivez",
    "le",
    "sentier",
    "qui",
    "part",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "decrit",
  "hint": "Le pont que Marc a… (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Demandez à la personne qui Aline a écrit.",
  "correct_sentence": "Demandez à la personne à qui Aline a écrit.",
  "explanation": "Écrire à quelqu'un → à qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/regle-colocation.svg",
      "word": "une règle"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/fenetre-cour.svg",
      "word": "une fenêtre"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/maison-vents.svg",
      "word": "une maison"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/jardin-haut.svg",
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
  "prompt": "Imitez : cinq phrases d'itinéraire avec relatifs."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre itinéraire, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Qui, que, à qui, avec qui',
    'EL',
    $c$Objectif
Retenir le choix du pronom relatif.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
qui = sujet : le sentier qui descend
que = COD : le pont que je vois (qu' devant voyelle : que + il → qu'il)
à qui = COI personne : la femme à qui je parle
avec qui = accompagnement : le guide avec qui je marche
On ne dit pas : le pont qui je vois.
On ne dit pas : la personne que je parle (parler à → à qui).
Élision : le chemin qu'elle indique.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « le pont qui je vois ».",
  "correct": false,
  "explanation": "Je vois le pont → que."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Que + elle » s'écrit…",
  "options": [
    {
      "text": "que elle",
      "correct": false
    },
    {
      "text": "qu'elle",
      "correct": true
    },
    {
      "text": "qui elle",
      "correct": false
    },
    {
      "text": "quel elle",
      "correct": false
    }
  ],
  "explanation": "Élision : qu'elle."
}$j$::jsonb,
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
      "left": "que / qu'",
      "right": "COD"
    },
    {
      "left": "à qui",
      "right": "parler à"
    },
    {
      "left": "avec qui",
      "right": "marcher avec"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe chemin ___ elle indique est ocre.",
  "answer": "qu'"
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
    "femme",
    "à",
    "qui",
    "je",
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
  "word": "sujet",
  "hint": "Qui remplace le… de la relative."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le guide que je marche.",
  "correct_sentence": "C'est le guide avec qui je marche.",
  "explanation": "Marcher avec → avec qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m1/bureau-escales.svg",
      "word": "un bureau"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/formulaire-y.svg",
      "word": "un formulaire"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/enveloppe-en.svg",
      "word": "une enveloppe"
    },
    {
      "image_path": "/elearning/mfk-a2-m1/affiche-demarche.svg",
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
  "prompt": "Transformez six phrases simples en relatives."
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

END;
$$;
