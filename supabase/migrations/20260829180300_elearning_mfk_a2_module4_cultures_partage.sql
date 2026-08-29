/*
  Seed eLearning MFK — A2 — Cultures en partage

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a2-m4/
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
  v_module_title text := 'A2 — Cultures en partage';
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
      'Grande étape A2-4 : préciser avec des adverbes, raconter un événement, mener une enquête, faire une appréciation, demander des explications et formuler des souhaits — pendant la fête des cultures partagées au Seuil des Sources (Rukiri-Nord), entre lanternes et Radio Figuier.',
      'A2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape A2-4 : préciser avec des adverbes, raconter un événement, mener une enquête, faire une appréciation, demander des explications et formuler des souhaits — pendant la fête des cultures partagées au Seuil des Sources (Rukiri-Nord), entre lanternes et Radio Figuier.',
      cefr_level = 'A2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Précisions et nuances =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Précisions et nuances'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Précisions et nuances', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Lanternes déjà prêtes',
    'CO',
    $c$Objectif
Repérer la place des adverbes : souvent, déjà, encore, bien, beaucoup.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Où se place chaque adverbe ?

Support — Banc du figuier, veille de fête
Aline : J'écoute souvent Radio Figuier avant la veillée.
Patrick : Moi, j'ai déjà préparé les lanternes ocre.
Léa : Rose chante encore sous le figuier.
Marc : Le Marché des Lampions s'ouvre bien ce soir.
Hawa : Les enfants aiment beaucoup le cortège.
Joël : Lila Sow explique souvent le chant du figuier.
Karim : Nous avons déjà tendu les tissus à l'Atelier.
Kévin : On danse encore près de la Table des Sources.
Mado : J'ai bien compris l'horaire de la soirée.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Patrick a déjà préparé les lanternes.",
  "correct": true,
  "explanation": "Patrick : « j'ai déjà préparé les lanternes ocre. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Où se place « déjà » dans la phrase de Patrick ?",
  "options": [
    {
      "text": "Avant avoir",
      "correct": false
    },
    {
      "text": "Entre l'auxiliaire et le participe",
      "correct": true
    },
    {
      "text": "Après le participe",
      "correct": false
    },
    {
      "text": "Avant le sujet",
      "correct": false
    }
  ],
  "explanation": "J'ai déjà préparé : adverbe après l'auxiliaire."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "écoute souvent",
      "right": "après le verbe conjugué"
    },
    {
      "left": "ai déjà préparé",
      "right": "après l'auxiliaire"
    },
    {
      "left": "chante encore",
      "right": "action qui continue"
    },
    {
      "left": "aiment beaucoup",
      "right": "intensité après le verbe"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJ'ai ___ préparé les lanternes.",
  "answer": "déjà"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'écoute",
    "souvent",
    "Radio",
    "Figuier",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "souvent",
  "hint": "Adverbe : plusieurs fois, pas une seule."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je souvent écoute Radio Figuier.",
  "correct_sentence": "J'écoute souvent Radio Figuier.",
  "explanation": "L'adverbe se place après le verbe conjugué."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/nuance-adverbe.svg",
      "word": "un adverbe"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/phrase-place.svg",
      "word": "une phrase"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/fete-sources.svg",
      "word": "une fête"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/lanterne-soir.svg",
      "word": "une lanterne"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez cinq adverbes et le verbe qu'ils précisent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : J'écoute souvent. J'ai déjà préparé. Rose chante encore. Ils aiment beaucoup."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Programme annoté',
    'CE',
    $c$Objectif
Lire un programme où les adverbes précisent les actions.

Consigne
Lisez le programme épinglé, sans aller trop vite.

Support — Feuille ocre, Salle des Herbes
Veillée des lanternes — Seuil des Sources
On allume souvent les lampions après dix-huit heures.
Lila Sow a déjà relu le conte du tissu partagé.
Le cortège avance encore vers le Marché des Lampions.
Radio Figuier explique bien les danses des trois rives.
Les visiteurs goûtent beaucoup le bol des sources.
Karim a bien tendu la banderole près du figuier.
Rose chante encore deux refrains.
Attention : beaucoup après le verbe. Très devant un adjectif.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Lila a déjà relu le conte.",
  "correct": true,
  "explanation": "« Lila Sow a déjà relu le conte du tissu partagé. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que font les visiteurs avec le bol des sources ?",
  "options": [
    {
      "text": "Ils le cachent",
      "correct": false
    },
    {
      "text": "Ils le goûtent beaucoup",
      "correct": true
    },
    {
      "text": "Ils le vendent",
      "correct": false
    },
    {
      "text": "Ils le cassent",
      "correct": false
    }
  ],
  "explanation": "« Les visiteurs goûtent beaucoup le bol des sources. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "allume souvent",
      "right": "lampions"
    },
    {
      "left": "a déjà relu",
      "right": "conte"
    },
    {
      "left": "explique bien",
      "right": "Radio Figuier"
    },
    {
      "left": "goûtent beaucoup",
      "right": "bol des sources"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nRose chante ___ deux refrains.",
  "answer": "encore"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Karim",
    "a",
    "bien",
    "tendu",
    "la",
    "banderole",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "encore",
  "hint": "L'action n'est pas finie : elle continue."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les visiteurs beaucoup goûtent le bol.",
  "correct_sentence": "Les visiteurs goûtent beaucoup le bol.",
  "explanation": "Beaucoup se place après le verbe conjugué."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/ce-qui.svg",
      "word": "ce qui"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/ce-que.svg",
      "word": "ce que"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/recit-evenement.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/micro-temoin.svg",
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
  "prompt": "Recopiez quatre phrases et soulignez l'adverbe."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez le programme à voix haute, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Placer l''adverbe',
    'PO',
    $c$Objectif
Dire une phrase avec l'adverbe à la bonne place.

Consigne
Répétez les modèles, puis précisez une action de la fête.

Support — Modèles d'Aline
Je danse souvent.
Tu as déjà allumé.
Elle écoute encore.
Nous chantons bien.
Vous aimez beaucoup.
Ils ont bien compris.
On prépare encore les tissus.
J'ai déjà vu le cortège.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Avec un temps composé, l'adverbe se place souvent après l'auxiliaire.",
  "correct": true,
  "explanation": "J'ai déjà vu. Ils ont bien compris."
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
      "text": "Je déjà ai vu",
      "correct": false
    },
    {
      "text": "J'ai déjà vu",
      "correct": true
    },
    {
      "text": "J'ai vu déjà le cortège trop",
      "correct": false
    },
    {
      "text": "Déjà je ai vu",
      "correct": false
    }
  ],
  "explanation": "Auxiliaire + adverbe + participe."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "souvent",
      "right": "habitude"
    },
    {
      "left": "déjà",
      "right": "avant ce moment"
    },
    {
      "left": "encore",
      "right": "pas fini"
    },
    {
      "left": "beaucoup",
      "right": "intensité"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVous aimez ___ la danse.",
  "answer": "beaucoup"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ils",
    "ont",
    "bien",
    "compris",
    "."
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
  "hint": "Adverbe d'intensité : un grand nombre ou très fort."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous bien chantons sous le figuier.",
  "correct_sentence": "Nous chantons bien sous le figuier.",
  "explanation": "Bien se place après le verbe conjugué."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/enquete-lequel.svg",
      "word": "une enquête"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/quatre-affiches.svg",
      "word": "des affiches"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/loupe-question.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/carnet-enquete.svg",
      "word": "un carnet"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases : souvent, déjà, encore, bien, beaucoup, trop."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux phrases à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon carnet de veillée',
    'PE',
    $c$Objectif
Écrire un carnet qui place correctement les adverbes.

Consigne
Imitez le carnet de Léa.

Support — Carnet de Léa Niyonzima
Léa Niyonzima
J'écoute souvent le chant du figuier.
J'ai déjà cousu un tissu à l'Atelier.
Rose chante encore près de Radio Figuier.
Le cortège avance bien vers le marché.
Les enfants aiment beaucoup les lanternes.
Nous avons déjà préparé le bol des sources.
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
  "statement": "Léa a déjà cousu un tissu.",
  "correct": true,
  "explanation": "« J'ai déjà cousu un tissu à l'Atelier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que font les enfants, d'après Léa ?",
  "options": [
    {
      "text": "Ils dorment",
      "correct": false
    },
    {
      "text": "Ils aiment beaucoup les lanternes",
      "correct": true
    },
    {
      "text": "Ils ferment le marché",
      "correct": false
    },
    {
      "text": "Ils cachent le bol",
      "correct": false
    }
  ],
  "explanation": "« Les enfants aiment beaucoup les lanternes. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "écoute souvent",
      "right": "chant"
    },
    {
      "left": "ai déjà cousu",
      "right": "tissu"
    },
    {
      "left": "chante encore",
      "right": "Rose"
    },
    {
      "left": "aiment beaucoup",
      "right": "lanternes"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe cortège avance ___ vers le marché.",
  "answer": "bien"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'écoute",
    "souvent",
    "le",
    "chant",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lanternes",
  "hint": "On les allume le soir : des lumières en papier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "J'ai cousu déjà un tissu pour la veillée.",
  "correct_sentence": "J'ai déjà cousu un tissu pour la veillée.",
  "explanation": "Déjà se place après l'auxiliaire."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/podium-superlatif.svg",
      "word": "un podium"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/etoile-meilleur.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/avis-hawa.svg",
      "word": "un avis"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/tasse-plus.svg",
      "word": "une tasse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes avec cinq adverbes différents."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre carnet, une phrase, une pause, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Place de l''adverbe',
    'EL',
    $c$Objectif
Retenir où placer souvent, déjà, encore, bien, beaucoup.

Consigne
Apprenez la fiche.

Support — Fiche du Cahier du chemin
Après le verbe conjugué : je danse souvent / elle écoute encore.
Après l'auxiliaire, avant le participe : j'ai déjà vu / nous avons bien compris.
beaucoup : après le verbe (ils aiment beaucoup) ou beaucoup de + nom.
très : devant un adjectif (très beau), pas après le verbe seul.
trop : trop vite, trop tard — après le verbe ou devant l'adjectif.
On ne dit pas : je souvent danse.
On ne dit pas : j'ai vu déjà (place faible) — on préfère j'ai déjà vu.
bien ≠ bon : on chante bien / un bon chant.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « je souvent danse ».",
  "correct": false,
  "explanation": "L'adverbe se place après le verbe : je danse souvent."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase place bien l'adverbe ?",
  "options": [
    {
      "text": "Ils beaucoup aiment",
      "correct": false
    },
    {
      "text": "Ils aiment beaucoup",
      "correct": true
    },
    {
      "text": "Beaucoup ils aiment le",
      "correct": false
    },
    {
      "text": "Ils aiment le beaucoup cortège",
      "correct": false
    }
  ],
  "explanation": "Verbe + beaucoup."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "souvent",
      "right": "habitude"
    },
    {
      "left": "déjà",
      "right": "fait avant"
    },
    {
      "left": "encore",
      "right": "continuité"
    },
    {
      "left": "bien",
      "right": "manière"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous avons ___ compris l'horaire.",
  "answer": "bien"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Elle",
    "écoute",
    "encore",
    "Radio",
    "Figuier",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "maniere",
  "hint": "Bien précise la… de l'action (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ce chant est beaucoup beau.",
  "correct_sentence": "Ce chant est très beau.",
  "explanation": "Très + adjectif. Beaucoup + verbe."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/inversion-question.svg",
      "word": "une inversion"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/pupitre-aline.svg",
      "word": "un pupitre"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/point-interrogation.svg",
      "word": "un point"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/salle-herbes.svg",
      "word": "une salle"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Placez cinq adverbes dans cinq phrases au présent et au passé composé."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche, puis quatre exemples à vous."
}$j$::jsonb,
    9
  );

  -- ===== Un événement à raconter =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un événement à raconter'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un événement à raconter', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Ce qui a brillé',
    'CO',
    $c$Objectif
Comprendre la mise en relief : ce qui / ce que … c'est.

Consigne
Lisez le dialogue. Qu'est-ce qu'on met en avant ?

Support — Micro de Radio Figuier, soir de fête
Marc : Ce qui m'a plu, c'est le cortège des lampions.
Hawa : Ce que Patrick raconte, c'est la danse des trois rives.
Aline : Ce qui est beau, c'est le tissu partagé.
Léa : Ce que j'ai vu, c'est le figuier tout éclairé.
Joël : Ce qui étonne Kévin, c'est le silence après le chant.
Rose : Ce que Lila lit, c'est le conte du bol des sources.
Karim : Ce qui reste, c'est la lumière ocre.
Mado : Ce que nous gardons, c'est cette soirée.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc met en relief le cortège.",
  "correct": true,
  "explanation": "« Ce qui m'a plu, c'est le cortège des lampions. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Dans « Ce que j'ai vu », que remplace « ce que » ?",
  "options": [
    {
      "text": "Le sujet",
      "correct": false
    },
    {
      "text": "Le complément d'objet",
      "correct": true
    },
    {
      "text": "Un lieu",
      "correct": false
    },
    {
      "text": "Un adverbe",
      "correct": false
    }
  ],
  "explanation": "Ce que + sujet + verbe : l'objet est mis en relief."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ce qui m'a plu",
      "right": "sujet de plaire"
    },
    {
      "left": "ce que Patrick raconte",
      "right": "objet de raconter"
    },
    {
      "left": "ce qui est beau",
      "right": "le tissu"
    },
    {
      "left": "ce que j'ai vu",
      "right": "le figuier"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ qui m'a plu, c'est le cortège.",
  "answer": "Ce"
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
    "est",
    "beau",
    "c'est",
    "le",
    "tissu",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "cortège",
  "hint": "La file de lampions qui avance (avec accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ce que m'a plu, c'est le cortège.",
  "correct_sentence": "Ce qui m'a plu, c'est le cortège.",
  "explanation": "Le sujet de plaire → ce qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/souhait-conditionnel.svg",
      "word": "un souhait"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/lettre-conseil.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/nuage-si.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/main-aide.svg",
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
  "prompt": "Notez trois « ce qui » et deux « ce que » entendus."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Ce qui m'a plu c'est le cortège. Ce que j'ai vu c'est le figuier."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Carnet de témoins',
    'CE',
    $c$Objectif
Lire des mises en relief dans un carnet de fête.

Consigne
Lisez le carnet, sans aller trop vite.

Support — Cahier du chemin, page ocre
Témoins — Veillée des lanternes
Hawa : Ce qui éclaire la cour, c'est le figuier.
Patrick : Ce que Rose chante, c'est le refrain des trois rives.
Solange Mukamana : Ce qui manque encore, c'est un banc près du micro.
Karim : Ce que le marché propose, c'est l'échange des carnets.
Lila Sow : Ce qui unit les voix, c'est Radio Figuier.
Joël : Ce que Sami photographie, c'est la danse.
Règle : ce qui = sujet. ce que = objet (qu' devant voyelle).
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Solange dit qu'il manque un banc.",
  "correct": true,
  "explanation": "« Ce qui manque encore, c'est un banc près du micro. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que photographie Sami, d'après Joël ?",
  "options": [
    {
      "text": "Le banc",
      "correct": false
    },
    {
      "text": "La danse",
      "correct": true
    },
    {
      "text": "Le bol",
      "correct": false
    },
    {
      "text": "Le tampon",
      "correct": false
    }
  ],
  "explanation": "« Ce que Sami photographie, c'est la danse. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ce qui éclaire",
      "right": "le figuier"
    },
    {
      "left": "ce que Rose chante",
      "right": "le refrain"
    },
    {
      "left": "ce qui unit",
      "right": "Radio Figuier"
    },
    {
      "left": "ce que Sami photographie",
      "right": "la danse"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCe ___ Rose chante, c'est le refrain.",
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
    "Ce",
    "qui",
    "éclaire",
    "la",
    "cour",
    "c'est",
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
  "word": "refrain",
  "hint": "Ce que Rose chante : la partie qui revient."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ce qui Rose chante, c'est le refrain.",
  "correct_sentence": "Ce que Rose chante, c'est le refrain.",
  "explanation": "Rose chante quelque chose → ce que (objet)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/danse-cultures.svg",
      "word": "une danse"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/tissu-partage.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/livre-conte.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/radio-soir.svg",
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
  "prompt": "Recopiez le carnet et encadrez ce qui / ce que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six témoignages, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Mettre en relief',
    'PO',
    $c$Objectif
Raconter un événement avec ce qui / ce que … c'est.

Consigne
Répétez, puis racontez un moment de la fête.

Support — Modèles de Marc
Ce qui m'étonne, c'est le silence.
Ce que j'aime, c'est la danse.
Ce qui reste, c'est la lumière.
Ce que tu racontes, c'est vrai.
Ce qui est simple, c'est d'écouter.
Ce que nous gardons, c'est le chant.
Ce qui brille, c'est la lanterne.
Ce que Hawa lit, c'est le conte.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Ce qui » introduit le sujet de la relative.",
  "correct": true,
  "explanation": "Ce qui brille : qui = sujet de briller."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "On dit « … j'aime, c'est la danse » comment ?",
  "options": [
    {
      "text": "Ce qui",
      "correct": false
    },
    {
      "text": "Ce que",
      "correct": true
    },
    {
      "text": "Ce dont",
      "correct": false
    },
    {
      "text": "Ce où",
      "correct": false
    }
  ],
  "explanation": "J'aime quelque chose → ce que."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ce qui",
      "right": "sujet"
    },
    {
      "left": "ce que",
      "right": "objet"
    },
    {
      "left": "c'est",
      "right": "mise en relief"
    },
    {
      "left": "ce qu'",
      "right": "devant voyelle"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCe ___ j'aime, c'est la danse.",
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
    "Ce",
    "qui",
    "brille",
    "c'est",
    "la",
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
  "word": "silence",
  "hint": "Ce qui étonne : plus aucun bruit après le chant."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ce que brille, c'est la lanterne.",
  "correct_sentence": "Ce qui brille, c'est la lanterne.",
  "explanation": "La lanterne brille → sujet → ce qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/marche-lampions.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/cour-fete.svg",
      "word": "une cour"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/nuance-adverbe.svg",
      "word": "un adverbe"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/phrase-place.svg",
      "word": "une phrase"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six mises en relief : trois ce qui, trois ce que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux phrases à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon récit de soirée',
    'PE',
    $c$Objectif
Écrire un récit court avec ce qui / ce que … c'est.

Consigne
Imitez le récit de Hawa.

Support — Récit de Hawa Diallo
Hawa Diallo
Ce qui a ouvert la soirée, c'est Radio Figuier.
Ce que Patrick a tendu, c'est la banderole ocre.
Ce qui m'a touchée, c'est le chant du figuier.
Ce que les enfants ont suivi, c'est le cortège.
Ce qui reste ce matin, c'est une lanterne.
Ce que je raconte, c'est cette veillée.
Hawa
Marché des Lampions — Seuil des Sources
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa dit que Radio Figuier a ouvert la soirée.",
  "correct": true,
  "explanation": "« Ce qui a ouvert la soirée, c'est Radio Figuier. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qu'est-ce qui reste ce matin ?",
  "options": [
    {
      "text": "Un banc",
      "correct": false
    },
    {
      "text": "Une lanterne",
      "correct": true
    },
    {
      "text": "Un tampon",
      "correct": false
    },
    {
      "text": "Un minibus",
      "correct": false
    }
  ],
  "explanation": "« Ce qui reste ce matin, c'est une lanterne. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ce qui a ouvert",
      "right": "Radio Figuier"
    },
    {
      "left": "ce que Patrick a tendu",
      "right": "banderole"
    },
    {
      "left": "ce qui m'a touchée",
      "right": "chant"
    },
    {
      "left": "ce que les enfants ont suivi",
      "right": "cortège"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCe ___ je raconte, c'est cette veillée.",
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
    "Ce",
    "qui",
    "reste",
    "c'est",
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
  "word": "banderole",
  "hint": "Ce que Patrick a tendu : une longue bande de tissu."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ce qui Patrick a tendu, c'est la banderole.",
  "correct_sentence": "Ce que Patrick a tendu, c'est la banderole.",
  "explanation": "Patrick a tendu quelque chose → ce que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/fete-sources.svg",
      "word": "une fête"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/lanterne-soir.svg",
      "word": "une lanterne"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/ce-qui.svg",
      "word": "ce qui"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/ce-que.svg",
      "word": "ce que"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes avec ce qui et ce que."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre récit, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Ce qui, ce que, c''est',
    'EL',
    $c$Objectif
Retenir la mise en relief avec ce qui et ce que.

Consigne
Apprenez la fiche.

Support — Fiche de Lila Sow
Ce qui + verbe : le sujet est mis en avant.
Ce qui m'étonne, c'est le silence.
Ce que + sujet + verbe : l'objet est mis en avant.
Ce que je vois, c'est la danse.
Élision : ce qu'elle raconte / ce qu'on garde.
On referme souvent avec c'est + nom (ou infinitif).
On ne dit pas : ce que m'étonne.
On ne dit pas : ce qui je vois.
Attention : ce qui / ce que (pas se qui).
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On écrit « ce que m'étonne ».",
  "correct": false,
  "explanation": "Étonner a un sujet : ce qui m'étonne."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Ce que + elle » s'écrit…",
  "options": [
    {
      "text": "ce que elle",
      "correct": false
    },
    {
      "text": "ce qu'elle",
      "correct": true
    },
    {
      "text": "ce qui elle",
      "correct": false
    },
    {
      "text": "ce quelle",
      "correct": false
    }
  ],
  "explanation": "Élision : ce qu'elle."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ce qui",
      "right": "sujet"
    },
    {
      "left": "ce que",
      "right": "objet"
    },
    {
      "left": "ce qu'",
      "right": "élision"
    },
    {
      "left": "c'est",
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
  "prompt": "Complétez :\nCe ___ elle raconte est vrai.",
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
    "Ce",
    "que",
    "je",
    "vois",
    "c'est",
    "la",
    "danse",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "objet",
  "hint": "Ce que reprend le… du verbe voir ou aimer."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Ce qui je vois, c'est la danse.",
  "correct_sentence": "Ce que je vois, c'est la danse.",
  "explanation": "Je vois quelque chose → ce que."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/recit-evenement.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/micro-temoin.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/enquete-lequel.svg",
      "word": "une enquête"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/quatre-affiches.svg",
      "word": "des affiches"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez six phrases simples en ce qui / ce que … c'est."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six mises en relief."
}$j$::jsonb,
    9
  );

  -- ===== Une enquête à mener =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une enquête à mener'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une enquête à mener', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Quel stand reste ouvert',
    'CO',
    $c$Objectif
Comprendre lequel, laquelle, lesquels, lesquelles dans une enquête.

Consigne
Lisez le dialogue. On choisit parmi quoi ?

Support — Marché des Lampions, quatre affiches
Léa : Lequel de ces stands reste ouvert après vingt heures ?
Sami : Laquelle de ces danses commence près du figuier ?
Benoît : Lesquels de ces tissus viennent de l'Atelier ?
Yvette Mukeshimana : Lesquelles de ces lanternes sont déjà allumées ?
Noura Sarr : Lequel de ces micros appartient à Radio Figuier ?
Ibrahim Tchami : Laquelle de ces voix explique le conte ?
Aline : Parmi ces carnets, lesquels sont complets ?
Patrick : Parmi ces tasses, lesquelles sont pour le bol des sources ?
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Léa demande quel stand reste ouvert.",
  "correct": true,
  "explanation": "« Lequel de ces stands reste ouvert… »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Yvette parle de lanternes. Quel pronom utilise-t-elle ?",
  "options": [
    {
      "text": "Lequel",
      "correct": false
    },
    {
      "text": "Laquelle",
      "correct": false
    },
    {
      "text": "Lesquels",
      "correct": false
    },
    {
      "text": "Lesquelles",
      "correct": true
    }
  ],
  "explanation": "Lanternes = féminin pluriel → lesquelles."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lequel",
      "right": "stand / micro — masc. sing."
    },
    {
      "left": "laquelle",
      "right": "danse / voix — fém. sing."
    },
    {
      "left": "lesquels",
      "right": "tissus / carnets — masc. pl."
    },
    {
      "left": "lesquelles",
      "right": "lanternes / tasses — fém. pl."
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ de ces stands reste ouvert ?",
  "answer": "Lequel"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Laquelle",
    "de",
    "ces",
    "danses",
    "commence",
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
  "word": "stand",
  "hint": "Un petit lieu du marché : on y vend ou on y montre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Laquelle de ces stands reste ouvert ?",
  "correct_sentence": "Lequel de ces stands reste ouvert ?",
  "explanation": "Stand est masculin : lequel."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/loupe-question.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/carnet-enquete.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/podium-superlatif.svg",
      "word": "un podium"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/etoile-meilleur.svg",
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
  "prompt": "Notez les quatre formes et le nom qu'elles reprennent."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Lequel de ces stands ? Laquelle de ces danses ? Lesquelles de ces lanternes ?"
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Fiche d''enquête',
    'CE',
    $c$Objectif
Lire une fiche d'enquête avec lequel / laquelle / lesquels / lesquelles.

Consigne
Lisez la fiche, sans aller trop vite.

Support — Carnet d'enquête, Bureau des Escales
Enquête — fête des cultures partagées
1. Lequel de ces horaires est le bon pour Radio Figuier ?
2. Laquelle de ces salles accueille le conte : Salle des Herbes ou Maison des Vents ?
3. Lesquels de ces guides connaissent le Marché des Lampions : Karim ou Ibrahim ?
4. Lesquelles de ces règles restent affichées près du figuier ?
5. Parmi ces lanternes, lesquelles doivent encore brûler ?
6. Lequel de ces prénoms manque sur la liste : Félicie ou Dieudonné ?
Accord : on reprend le genre et le nombre du nom.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La fiche demande laquelle des salles accueille le conte.",
  "correct": true,
  "explanation": "Point 2 : Salle des Herbes ou Maison des Vents."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pour « règles », quelle forme est correcte ?",
  "options": [
    {
      "text": "lequel",
      "correct": false
    },
    {
      "text": "laquelle",
      "correct": false
    },
    {
      "text": "lesquels",
      "correct": false
    },
    {
      "text": "lesquelles",
      "correct": true
    }
  ],
  "explanation": "Règles = féminin pluriel."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lequel / horaires",
      "right": "masculin singulier"
    },
    {
      "left": "laquelle / salles",
      "right": "féminin singulier"
    },
    {
      "left": "lesquels / guides",
      "right": "masculin pluriel"
    },
    {
      "left": "lesquelles / règles",
      "right": "féminin pluriel"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ de ces salles accueille le conte ?",
  "answer": "Laquelle"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Lesquelles",
    "de",
    "ces",
    "règles",
    "restent",
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
  "word": "guides",
  "hint": "Karim ou Ibrahim : ceux qui montrent le chemin."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lesquels de ces règles restent affichées ?",
  "correct_sentence": "Lesquelles de ces règles restent affichées ?",
  "explanation": "Règle est féminin : lesquelles."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/avis-hawa.svg",
      "word": "un avis"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/tasse-plus.svg",
      "word": "une tasse"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/inversion-question.svg",
      "word": "une inversion"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/pupitre-aline.svg",
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
  "prompt": "Recopiez la fiche et accordez quatre pronoms à blanc."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six questions, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Choisir parmi plusieurs',
    'PO',
    $c$Objectif
Poser une question avec lequel / laquelle / lesquels / lesquelles.

Consigne
Répétez, puis enquêtez sur un objet de la cour.

Support — Modèles d'Aline
Lequel choisis-tu ?
Laquelle préfères-tu ?
Lesquels restent ouverts ?
Lesquelles sont allumées ?
Lequel de ces chants ?
Laquelle de ces voix ?
Lesquels de ces bancs ?
Lesquelles de ces tasses ?
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Lesquels » est masculin pluriel.",
  "correct": true,
  "explanation": "Lesquels = ceux-là, parmi un groupe masculin."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pour « voix » (féminin), on dit…",
  "options": [
    {
      "text": "lequel",
      "correct": false
    },
    {
      "text": "laquelle",
      "correct": true
    },
    {
      "text": "lesquels",
      "correct": false
    },
    {
      "text": "lequelles",
      "correct": false
    }
  ],
  "explanation": "Une voix → laquelle."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lequel",
      "right": "celui"
    },
    {
      "left": "laquelle",
      "right": "celle"
    },
    {
      "left": "lesquels",
      "right": "ceux"
    },
    {
      "left": "lesquelles",
      "right": "celles"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ de ces chants écoutes-tu ?",
  "answer": "Lequel"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Lesquels",
    "restent",
    "ouverts",
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
  "word": "choisis",
  "hint": "Lequel…-tu : tu prends l'un parmi d'autres."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lesquelles de ces bancs restent ?",
  "correct_sentence": "Lesquels de ces bancs restent ?",
  "explanation": "Banc est masculin : lesquels."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/point-interrogation.svg",
      "word": "un point"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/salle-herbes.svg",
      "word": "une salle"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/souhait-conditionnel.svg",
      "word": "un souhait"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/lettre-conseil.svg",
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
  "prompt": "Écrivez huit questions : deux de chaque forme."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis deux questions à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma feuille d''enquête',
    'PE',
    $c$Objectif
Écrire une courte enquête avec les quatre formes.

Consigne
Imitez la feuille de Yvette.

Support — Feuille de Yvette Mukeshimana
Yvette Mukeshimana
Lequel de ces micros marche encore ?
Laquelle de ces danses commence à vingt heures ?
Lesquels de ces tissus sont pour l'échange ?
Lesquelles de ces lanternes restent près du figuier ?
Parmi ces voix, laquelle explique le conte ?
Parmi ces stands, lesquels ferment les derniers ?
Yvette
Marché des Lampions
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Yvette demande lesquels des tissus sont pour l'échange.",
  "correct": true,
  "explanation": "Troisième question de la feuille."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle question porte sur les lanternes ?",
  "options": [
    {
      "text": "Lequel de ces micros",
      "correct": false
    },
    {
      "text": "Lesquelles de ces lanternes restent",
      "correct": true
    },
    {
      "text": "Lesquels de ces tissus",
      "correct": false
    },
    {
      "text": "Laquelle explique le conte",
      "correct": false
    }
  ],
  "explanation": "« Lesquelles de ces lanternes restent près du figuier ? »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lequel",
      "right": "micros"
    },
    {
      "left": "laquelle",
      "right": "danses / voix"
    },
    {
      "left": "lesquels",
      "right": "tissus / stands"
    },
    {
      "left": "lesquelles",
      "right": "lanternes"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nParmi ces voix, ___ explique le conte ?",
  "answer": "laquelle"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Lequel",
    "de",
    "ces",
    "micros",
    "marche",
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
  "word": "lanternes",
  "hint": "Elles restent près du figuier : des lumières de papier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Parmi ces voix, lequel explique le conte ?",
  "correct_sentence": "Parmi ces voix, laquelle explique le conte ?",
  "explanation": "Voix est féminin : laquelle."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/nuage-si.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/main-aide.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/danse-cultures.svg",
      "word": "une danse"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/tissu-partage.svg",
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
  "prompt": "Imitez : six questions d'enquête avec les quatre formes."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre feuille, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Lequel et ses accords',
    'EL',
    $c$Objectif
Retenir l'accord de lequel, laquelle, lesquels, lesquelles.

Consigne
Apprenez la fiche.

Support — Fiche d'enquête
lequel → un nom masculin singulier (le stand, le micro)
laquelle → un nom féminin singulier (la danse, la voix)
lesquels → un nom masculin pluriel (les tissus, les bancs)
lesquelles → un nom féminin pluriel (les lanternes, les tasses)
Souvent : lequel de ces + nom pluriel.
On ne dit pas : lequel danse (sans nom ou idée de choix).
Après une préposition : de lequel / à laquelle (niveau plus tard).
Ici : forme simple + de ces.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Lesquelles » reprend un nom féminin pluriel.",
  "correct": true,
  "explanation": "Les lanternes → lesquelles."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Tissu » au pluriel se reprend par…",
  "options": [
    {
      "text": "laquelle",
      "correct": false
    },
    {
      "text": "lesquels",
      "correct": true
    },
    {
      "text": "lesquelles",
      "correct": false
    },
    {
      "text": "lequel",
      "correct": false
    }
  ],
  "explanation": "Tissus = masculin pluriel → lesquels."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "lequel",
      "right": "masculin singulier"
    },
    {
      "left": "laquelle",
      "right": "féminin singulier"
    },
    {
      "left": "lesquels",
      "right": "masculin pluriel"
    },
    {
      "left": "lesquelles",
      "right": "féminin pluriel"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ de ces tasses sont propres ?",
  "answer": "Lesquelles"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Laquelle",
    "de",
    "ces",
    "voix",
    "parle",
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
  "word": "pluriel",
  "hint": "Lesquels et lesquelles vont avec un nom en…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lesquelles de ces tissus sont pour l'échange ?",
  "correct_sentence": "Lesquels de ces tissus sont pour l'échange ?",
  "explanation": "Tissu est masculin."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/livre-conte.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/radio-soir.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/marche-lampions.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/cour-fete.svg",
      "word": "une cour"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Accordez lequel dans huit mini-questions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et huit questions accordées."
}$j$::jsonb,
    9
  );

  -- ===== Faire une appréciation =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Faire une appréciation'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Faire une appréciation', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le plus beau cortège',
    'CO',
    $c$Objectif
Comprendre le superlatif : le plus, le moins, le meilleur.

Consigne
Lisez le dialogue. Qui dit le plus / le moins / le meilleur ?

Support — Table des Sources, fin de veillée
Rose : C'est le plus beau cortège de la saison.
Joël : La danse des trois rives est la plus vivante.
Hawa : Le bol des sources est le moins cher du marché.
Solange : Radio Figuier a le meilleur micro ce soir.
Félicie Ndayishimiye : C'est la moins longue des veillées.
Dieudonné Hakizimana : Les lanternes ocre sont les plus claires.
Lila : Le conte de Lila n'est pas le moins écouté.
Marc : C'est le meilleur moment sous le figuier.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Hawa dit que le bol est le moins cher.",
  "correct": true,
  "explanation": "« le moins cher du marché. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Solange, qu'est-ce qui est le meilleur ?",
  "options": [
    {
      "text": "Le bol",
      "correct": false
    },
    {
      "text": "Le micro de Radio Figuier",
      "correct": true
    },
    {
      "text": "Le banc",
      "correct": false
    },
    {
      "text": "Le tampon",
      "correct": false
    }
  ],
  "explanation": "« Radio Figuier a le meilleur micro ce soir. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le plus beau",
      "right": "cortège"
    },
    {
      "left": "la plus vivante",
      "right": "danse"
    },
    {
      "left": "le moins cher",
      "right": "bol"
    },
    {
      "left": "le meilleur",
      "right": "micro / moment"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est ___ plus beau cortège de la saison.",
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
    "C'est",
    "le",
    "meilleur",
    "moment",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "vivante",
  "hint": "La danse la plus… : pleine d'énergie."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le plus bon micro ce soir.",
  "correct_sentence": "C'est le meilleur micro ce soir.",
  "explanation": "Bon → le meilleur, pas le plus bon."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/phrase-place.svg",
      "word": "une phrase"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/fete-sources.svg",
      "word": "une fête"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/lanterne-soir.svg",
      "word": "une lanterne"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/ce-qui.svg",
      "word": "ce qui"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Notez trois superlatifs de supériorité et un de infériorité."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : C'est le plus beau. C'est la moins chère. C'est le meilleur moment."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Avis affichés',
    'CE',
    $c$Objectif
Lire des avis au superlatif.

Consigne
Lisez les avis, sans aller trop vite.

Support — Mur ocre, Atelier du Tissu
Avis de Rose : le chant du figuier est le plus doux de la cour.
Avis de Joël : la lanterne de Mado est la moins haute.
Avis d'Hawa : c'est le meilleur échange de carnets depuis l'an dernier.
Avis de Solange : les stands du fond sont les moins bruyants.
Avis de Félicie : c'est la plus claire des explications.
Avis de Dieudonné : les tissus jaunes sont les plus légers.
Règle : le / la / les + plus / moins + adjectif.
bon → le meilleur / la meilleure. Bien → le mieux.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël dit que la lanterne de Mado est la moins haute.",
  "correct": true,
  "explanation": "Avis de Joël."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Qui parle du meilleur échange de carnets ?",
  "options": [
    {
      "text": "Rose",
      "correct": false
    },
    {
      "text": "Hawa",
      "correct": true
    },
    {
      "text": "Solange",
      "correct": false
    },
    {
      "text": "Félicie",
      "correct": false
    }
  ],
  "explanation": "Avis d'Hawa."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le plus doux",
      "right": "chant"
    },
    {
      "left": "la moins haute",
      "right": "lanterne"
    },
    {
      "left": "le meilleur",
      "right": "échange"
    },
    {
      "left": "les plus légers",
      "right": "tissus"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLes stands du fond sont les ___ bruyants.",
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
    "C'est",
    "la",
    "plus",
    "claire",
    "des",
    "explications",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "doux",
  "hint": "Le chant le plus… : sans dureté, agréable à l'oreille."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le plus mieux des chants.",
  "correct_sentence": "C'est le mieux des chants.",
  "explanation": "Bien → le mieux, pas le plus mieux."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/ce-que.svg",
      "word": "ce que"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/recit-evenement.svg",
      "word": "un récit"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/micro-temoin.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/enquete-lequel.svg",
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
  "prompt": "Recopiez trois avis et changez plus en moins (ou l'inverse)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six avis, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire le plus et le moins',
    'PO',
    $c$Objectif
Faire une appréciation au superlatif.

Consigne
Répétez, puis jugez un moment de la fête.

Support — Modèles de Rose
C'est le plus intéressant.
C'est la moins chère.
C'est le meilleur conte.
C'est la meilleure danse.
Ce sont les plus clairs.
Ce sont les moins longs.
C'est le mieux expliqué.
C'est la plus simple des règles.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Le meilleur » est le superlatif de bon.",
  "correct": true,
  "explanation": "Bon → meilleur → le meilleur."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme va avec « danse » (féminin) ?",
  "options": [
    {
      "text": "le plus vivant",
      "correct": false
    },
    {
      "text": "la plus vivante",
      "correct": true
    },
    {
      "text": "les plus vivant",
      "correct": false
    },
    {
      "text": "le meilleure",
      "correct": false
    }
  ],
  "explanation": "La plus + adjectif au féminin."
}$j$::jsonb,
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
      "right": "supériorité masc."
    },
    {
      "left": "la moins",
      "right": "infériorité fém."
    },
    {
      "left": "le meilleur",
      "right": "de bon"
    },
    {
      "left": "le mieux",
      "right": "de bien"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est ___ moins chère.",
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
    "le",
    "plus",
    "intéressant",
    "."
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
  "hint": "Superlatif de bon : pas « le plus bon »."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est le plus intéressante des contes.",
  "correct_sentence": "C'est le plus intéressant des contes.",
  "explanation": "Conte est masculin : intéressant."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/quatre-affiches.svg",
      "word": "des affiches"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/loupe-question.svg",
      "word": "une loupe"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/carnet-enquete.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/podium-superlatif.svg",
      "word": "un podium"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez huit superlatifs : plus, moins, meilleur, mieux."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis trois avis à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mon avis de fête',
    'PE',
    $c$Objectif
Écrire un avis avec des superlatifs.

Consigne
Imitez l'avis de Joël.

Support — Avis de Joël Mugisha
Joël Mugisha
Le cortège est le plus beau de la saison.
La veillée est la moins chère du Seuil.
Radio Figuier a le meilleur micro.
La danse de Rose est la plus vivante.
Les lanternes ocre sont les moins lourdes.
C'est le meilleur soir sous le figuier.
Joël
Marché des Lampions
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Joël trouve la veillée la moins chère.",
  "correct": true,
  "explanation": "« La veillée est la moins chère du Seuil. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle danse Joël juge-t-il la plus vivante ?",
  "options": [
    {
      "text": "Celle de Marc",
      "correct": false
    },
    {
      "text": "Celle de Rose",
      "correct": true
    },
    {
      "text": "Celle de Sami",
      "correct": false
    },
    {
      "text": "Celle de Karim",
      "correct": false
    }
  ],
  "explanation": "« La danse de Rose est la plus vivante. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "le plus beau",
      "right": "cortège"
    },
    {
      "left": "la moins chère",
      "right": "veillée"
    },
    {
      "left": "le meilleur",
      "right": "micro / soir"
    },
    {
      "left": "la plus vivante",
      "right": "danse"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nRadio Figuier a ___ meilleur micro.",
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
    "C'est",
    "le",
    "meilleur",
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
  "word": "lourd",
  "hint": "Les lanternes sont les moins… : elles pèsent peu. (masc.)"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La veillée est le moins chère du Seuil.",
  "correct_sentence": "La veillée est la moins chère du Seuil.",
  "explanation": "Veillée est féminin : la moins."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/etoile-meilleur.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/avis-hawa.svg",
      "word": "un avis"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/tasse-plus.svg",
      "word": "une tasse"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/inversion-question.svg",
      "word": "une inversion"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez : six lignes avec le plus, le moins et le meilleur."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez votre avis, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Superlatif',
    'EL',
    $c$Objectif
Retenir le plus, le moins, le meilleur, le mieux.

Consigne
Apprenez la fiche.

Support — Fiche d'appréciation
le / la / les + plus + adjectif : le plus intéressant
le / la / les + moins + adjectif : la moins chère
Accord de l'adjectif : le plus beau / la plus belle / les plus clairs
bon → le meilleur / la meilleure / les meilleurs / les meilleures
bien → le mieux (invariable en genre)
De + groupe : le plus doux de la cour / du marché
On ne dit pas : le plus bon. On ne dit pas : le plus mieux.
Après c'est : C'est le plus simple.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "On dit « le plus bon » pour un micro.",
  "correct": false,
  "explanation": "On dit le meilleur."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Le superlatif de « bien » est…",
  "options": [
    {
      "text": "le plus bien",
      "correct": false
    },
    {
      "text": "le mieux",
      "correct": true
    },
    {
      "text": "le meilleur bien",
      "correct": false
    },
    {
      "text": "la plus bien",
      "correct": false
    }
  ],
  "explanation": "Bien → le mieux."
}$j$::jsonb,
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
      "right": "supériorité"
    },
    {
      "left": "le moins",
      "right": "infériorité"
    },
    {
      "left": "le meilleur",
      "right": "de bon"
    },
    {
      "left": "le mieux",
      "right": "de bien"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nC'est ___ meilleure danse.",
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
    "moins",
    "chère",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "accord",
  "hint": "L'adjectif change : le plus beau / la plus belle. C'est l'…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "C'est les plus beau cortège.",
  "correct_sentence": "C'est le plus beau cortège.",
  "explanation": "Cortège singulier : le plus beau."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/pupitre-aline.svg",
      "word": "un pupitre"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/point-interrogation.svg",
      "word": "un point"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/salle-herbes.svg",
      "word": "une salle"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/souhait-conditionnel.svg",
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
  "prompt": "Conjuguez cinq adjectifs au superlatif (plus / moins / meilleur)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et cinq exemples."
}$j$::jsonb,
    9
  );

  -- ===== Demander des explications =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Demander des explications'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Demander des explications', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Pouvez-vous expliquer',
    'CO',
    $c$Objectif
Comprendre des questions formelles à l'inversion.

Consigne
Lisez le dialogue. Quelles questions sont inversées ?

Support — Pupitre de la Salle des Herbes
Aline : Avez-vous entendu le chant du figuier ?
Patrick : Pouvez-vous expliquer la danse des trois rives ?
Karim : Quel est le thème de Radio Figuier ce soir ?
Solange : Savez-vous où se tient l'échange des carnets ?
Noura : Faut-il allumer toutes les lanternes ?
Lila : Qu'est-ce qui a changé depuis hier ?
Marc : Est-ce que le marché ferme à vingt-deux heures ?
Hawa : Où se trouve le micro, s'il vous plaît ?
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Aline pose une question inversée : Avez-vous…",
  "correct": true,
  "explanation": "Inversion sujet-verbe : avez-vous."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle question n'est pas une inversion ?",
  "options": [
    {
      "text": "Avez-vous entendu",
      "correct": false
    },
    {
      "text": "Pouvez-vous expliquer",
      "correct": false
    },
    {
      "text": "Est-ce que le marché ferme",
      "correct": true
    },
    {
      "text": "Quel est le thème",
      "correct": false
    }
  ],
  "explanation": "Est-ce que + ordre normal. Quel est = inversion de est-il."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avez-vous",
      "right": "inversion de avoir"
    },
    {
      "left": "pouvez-vous",
      "right": "demande polie"
    },
    {
      "left": "quel est",
      "right": "identification"
    },
    {
      "left": "est-ce que",
      "right": "forme non inversée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___-vous expliquer la danse ?",
  "answer": "Pouvez"
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
    "entendu",
    "le",
    "chant",
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
  "word": "expliquer",
  "hint": "Pouvez-vous… : rendre clair pour l'autre."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Pouvez vous expliquer la danse ?",
  "correct_sentence": "Pouvez-vous expliquer la danse ?",
  "explanation": "Inversion : trait d'union entre verbe et sujet."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/lettre-conseil.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/nuage-si.svg",
      "word": "un nuage"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/main-aide.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/danse-cultures.svg",
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
  "prompt": "Classez les questions : inversion / est-ce que / qu'est-ce qui."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Avez-vous entendu ? Pouvez-vous expliquer ? Quel est le thème ?"
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Questions du soir',
    'CE',
    $c$Objectif
Lire des questions formelles et leurs variantes.

Consigne
Lisez la feuille, sans aller trop vite.

Support — Feuille de Solange Mukamana
Questions pour les guides — Veillée
1. Avez-vous préparé le micro de Radio Figuier ?
2. Pouvez-vous indiquer la Salle des Herbes ?
3. Quel est l'horaire du cortège ?
4. Savez-vous pourquoi le figuier reste ouvert ?
5. Faut-il signer le Cahier du chemin ?
6. Qu'est-ce qui manque encore sur la table ?
Variante simple : Est-ce que vous avez préparé le micro ?
Inversion = plus formelle. Qu'est-ce qui = sujet inconnu.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La feuille oppose inversion et « est-ce que ».",
  "correct": true,
  "explanation": "Variante du point 1."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme sert à un sujet inconnu ?",
  "options": [
    {
      "text": "Avez-vous",
      "correct": false
    },
    {
      "text": "Pouvez-vous",
      "correct": false
    },
    {
      "text": "Qu'est-ce qui",
      "correct": true
    },
    {
      "text": "Quel est",
      "correct": false
    }
  ],
  "explanation": "Qu'est-ce qui a changé / manque."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avez-vous préparé",
      "right": "inversion"
    },
    {
      "left": "est-ce que vous avez",
      "right": "forme longue"
    },
    {
      "left": "quel est",
      "right": "lequel parmi"
    },
    {
      "left": "qu'est-ce qui",
      "right": "sujet"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___ est l'horaire du cortège ?",
  "answer": "Quel"
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
    "indiquer",
    "la",
    "salle",
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
  "word": "horaire",
  "hint": "Quel est l'… : l'heure du cortège."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Avez vous préparé le micro ?",
  "correct_sentence": "Avez-vous préparé le micro ?",
  "explanation": "Trait d'union obligatoire à l'inversion."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/tissu-partage.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/livre-conte.svg",
      "word": "un livre"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/radio-soir.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/marche-lampions.svg",
      "word": "un marché"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Transformez trois « est-ce que » en inversions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six questions, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Inverser pour demander',
    'PO',
    $c$Objectif
Poser une question formelle à l'inversion.

Consigne
Répétez, puis demandez une explication sur la fête.

Support — Modèles de Karim
Avez-vous le temps ?
Pouvez-vous répéter ?
Quel est votre rôle ?
Savez-vous l'heure ?
Faut-il rester ?
Où va le cortège ?
Que dit Radio Figuier ?
Pourquoi le silence ?
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Faut-il » est l'inversion de « il faut ».",
  "correct": true,
  "explanation": "Il faut → faut-il."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle inversion est correcte ?",
  "options": [
    {
      "text": "Vous avez le temps",
      "correct": false
    },
    {
      "text": "Avez-vous le temps",
      "correct": true
    },
    {
      "text": "Avez vous le temps",
      "correct": false
    },
    {
      "text": "Le temps avez-vous trop",
      "correct": false
    }
  ],
  "explanation": "Verbe-sujet avec trait d'union."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avez-vous",
      "right": "avoir"
    },
    {
      "left": "pouvez-vous",
      "right": "pouvoir"
    },
    {
      "left": "faut-il",
      "right": "il faut"
    },
    {
      "left": "quel est",
      "right": "être"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___-il rester près du figuier ?",
  "answer": "Faut"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Quel",
    "est",
    "votre",
    "rôle",
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
  "word": "repete",
  "hint": "Pouvez-vous… : dire une deuxième fois (sans accent)."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il faut-il rester près du figuier ?",
  "correct_sentence": "Faut-il rester près du figuier ?",
  "explanation": "On n'empile pas il et l'inversion."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/cour-fete.svg",
      "word": "une cour"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/nuance-adverbe.svg",
      "word": "un adverbe"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/phrase-place.svg",
      "word": "une phrase"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/fete-sources.svg",
      "word": "une fête"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six questions inversées (avoir, pouvoir, être, falloir)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis trois questions à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Mes questions aux guides',
    'PE',
    $c$Objectif
Écrire des questions formelles pour une explication.

Consigne
Imitez la liste de Noura.

Support — Liste de Noura Sarr
Noura Sarr
Avez-vous ouvert l'Atelier du Tissu ?
Pouvez-vous expliquer le chant du figuier ?
Quel est le sens du bol des sources ?
Savez-vous où se range le micro ?
Faut-il éteindre les lanternes à minuit ?
Qu'est-ce qui reste à préparer ?
Noura
Salle des Herbes
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Noura demande s'il faut éteindre les lanternes à minuit.",
  "correct": true,
  "explanation": "« Faut-il éteindre les lanternes à minuit ? »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle question utilise « quel est » ?",
  "options": [
    {
      "text": "Avez-vous ouvert l'Atelier",
      "correct": false
    },
    {
      "text": "Quel est le sens du bol des sources",
      "correct": true
    },
    {
      "text": "Faut-il éteindre",
      "correct": false
    },
    {
      "text": "Qu'est-ce qui reste",
      "correct": false
    }
  ],
  "explanation": "Identification : quel est le sens."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "avez-vous",
      "right": "ouvrir"
    },
    {
      "left": "pouvez-vous",
      "right": "expliquer"
    },
    {
      "left": "quel est",
      "right": "le sens"
    },
    {
      "left": "faut-il",
      "right": "éteindre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___-vous expliquer le chant ?",
  "answer": "Pouvez"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Faut-il",
    "éteindre",
    "les",
    "lanternes",
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
  "word": "minuit",
  "hint": "L'heure où les lanternes s'éteignent : douze heures."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Pouvez expliquer-vous le chant du figuier ?",
  "correct_sentence": "Pouvez-vous expliquer le chant du figuier ?",
  "explanation": "Le sujet inversé se colle au premier verbe."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/lanterne-soir.svg",
      "word": "une lanterne"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/ce-qui.svg",
      "word": "ce qui"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/ce-que.svg",
      "word": "ce que"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/recit-evenement.svg",
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
  "prompt": "Imitez : six questions formelles dont deux inversions et un qu'est-ce qui."
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
    'EL — Inversion et autres questions',
    'EL',
    $c$Objectif
Retenir l'interrogation inversée et ses voisines.

Consigne
Apprenez la fiche.

Support — Fiche du pupitre
Inversion : verbe + trait d'union + sujet.
Avez-vous… ? Pouvez-vous… ? Savez-vous… ? Faut-il… ?
Quel est… ? Quelle est… ? Où va… ? Que dit… ?
Est-ce que + phrase normale : plus simple, moins formel.
Qu'est-ce qui + verbe : le sujet est inconnu.
Qu'est-ce que + sujet + verbe : l'objet est inconnu.
Trait d'union obligatoire. Pas : Avez vous.
Devant voyelle, t euphonique parfois : Y a-t-il… ?
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Est-ce que » est plus formel que l'inversion.",
  "correct": false,
  "explanation": "L'inversion est plus formelle."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Il faut » à la forme inversée donne…",
  "options": [
    {
      "text": "Il faut-il",
      "correct": false
    },
    {
      "text": "Faut-il",
      "correct": true
    },
    {
      "text": "Faut il",
      "correct": false
    },
    {
      "text": "Est-ce faut",
      "correct": false
    }
  ],
  "explanation": "Faut-il."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "inversion",
      "right": "forme polie / formelle"
    },
    {
      "left": "est-ce que",
      "right": "forme simple"
    },
    {
      "left": "qu'est-ce qui",
      "right": "sujet inconnu"
    },
    {
      "left": "qu'est-ce que",
      "right": "objet inconnu"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\n___-ce qui a changé ?",
  "answer": "Qu'est"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Savez-vous",
    "où",
    "se",
    "tient",
    "l'échange",
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
  "word": "formel",
  "hint": "L'inversion convient à un ton… : poli, officiel."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Qu'est-ce que a changé depuis hier ?",
  "correct_sentence": "Qu'est-ce qui a changé depuis hier ?",
  "explanation": "Le sujet de changer → qu'est-ce qui."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/micro-temoin.svg",
      "word": "un micro"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/enquete-lequel.svg",
      "word": "une enquête"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/quatre-affiches.svg",
      "word": "des affiches"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/loupe-question.svg",
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
  "prompt": "Passez six questions de est-ce que à l'inversion."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et six questions inversées."
}$j$::jsonb,
    9
  );

  -- ===== Souhaits et conseils =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Souhaits et conseils'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Souhaits et conseils', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — On pourrait allumer',
    'CO',
    $c$Objectif
Comprendre des souhaits et conseils au conditionnel présent.

Consigne
Lisez le dialogue. Qui souhaite ? Qui conseille ?

Support — Fin de veillée, cour du figuier
Léa : Je voudrais encore une lanterne.
Marc : Tu devrais te reposer un peu.
Hawa : On pourrait ranger les tissus demain.
Joël : Nous pourrions aider Rose à plier les banderoles.
Rose : Je partirais plus tôt si le cortège se termine.
Kévin : Elle aimerait relire le conte à Radio Figuier.
Aline : Vous devriez remercier Lila Sow.
Patrick : Ils pourraient laisser une lumière pour la nuit.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Marc conseille à Léa de se reposer.",
  "correct": true,
  "explanation": "« Tu devrais te reposer un peu. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle phrase est un souhait de Léa ?",
  "options": [
    {
      "text": "Tu devrais te reposer",
      "correct": false
    },
    {
      "text": "Je voudrais encore une lanterne",
      "correct": true
    },
    {
      "text": "Vous devriez remercier",
      "correct": false
    },
    {
      "text": "Ils pourraient laisser",
      "correct": false
    }
  ],
  "explanation": "Je voudrais = souhait."
}$j$::jsonb,
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
      "left": "tu devrais",
      "right": "conseil"
    },
    {
      "left": "on pourrait",
      "right": "proposition"
    },
    {
      "left": "je partirais",
      "right": "condition / projection"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ___ ranger les tissus demain.",
  "answer": "pourrait"
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
    "encore",
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
  "word": "reposer",
  "hint": "Tu devrais te… : arrêter un moment, souffler."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je voudrais d'une lanterne encore s'il te plaît beaucoup.",
  "correct_sentence": "Je voudrais encore une lanterne.",
  "explanation": "Vouloir au conditionnel + nom, sans de ici."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/carnet-enquete.svg",
      "word": "un carnet"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/podium-superlatif.svg",
      "word": "un podium"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/etoile-meilleur.svg",
      "word": "une étoile"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/avis-hawa.svg",
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
  "prompt": "Classez : deux souhaits, deux conseils, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez : Je voudrais. Tu devrais. On pourrait. Nous pourrions. Je partirais."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Lettres de conseil',
    'CE',
    $c$Objectif
Lire des souhaits et conseils au conditionnel.

Consigne
Lisez les lettres, sans aller trop vite.

Support — Lettres accrochées au figuier
Lettre de Léa : Je voudrais garder une lanterne pour Mwezi-Haut.
Lettre de Marc : Tu devrais écrire à Radio Figuier demain.
Lettre d'Hawa : On pourrait ouvrir l'Atelier plus tôt.
Lettre de Joël : Nous pourrions inviter Ibrahim Tchami au prochain chant.
Lettre de Rose : Je serais prête à raconter encore.
Lettre de Kévin : Vous devriez laisser le marché propre.
Forme : radical du futur + ais / ais / ait / ions / iez / aient.
je serai (futur) ≠ je serais (conditionnel).
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose écrit « je serais prête » au conditionnel.",
  "correct": true,
  "explanation": "Serais = conditionnel. Serai = futur."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est le futur, pas le conditionnel ?",
  "options": [
    {
      "text": "je voudrais",
      "correct": false
    },
    {
      "text": "tu devrais",
      "correct": false
    },
    {
      "text": "je serai",
      "correct": true
    },
    {
      "text": "on pourrait",
      "correct": false
    }
  ],
  "explanation": "Je serai = futur. Je serais = conditionnel."
}$j$::jsonb,
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
      "right": "Léa"
    },
    {
      "left": "tu devrais",
      "right": "Marc"
    },
    {
      "left": "on pourrait",
      "right": "Hawa"
    },
    {
      "left": "je serais",
      "right": "Rose"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ inviter Ibrahim. (pouvoir)",
  "answer": "pourrions"
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
    "devrais",
    "écrire",
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
  "word": "serais",
  "hint": "Conditionnel de être, 1re personne : pas le futur serai."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je serai prête à raconter encore si on me le demandait hier.",
  "correct_sentence": "Je serais prête à raconter encore.",
  "explanation": "Souhait / hypothèse → conditionnel serais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/tasse-plus.svg",
      "word": "une tasse"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/inversion-question.svg",
      "word": "une inversion"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/pupitre-aline.svg",
      "word": "un pupitre"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/point-interrogation.svg",
      "word": "un point"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Recopiez et soulignez toutes les formes en -ais / -ions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Lisez les six lettres, sans aller trop vite."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Souhaiter et conseiller',
    'PO',
    $c$Objectif
Dire un souhait ou un conseil au conditionnel présent.

Consigne
Répétez, puis conseillez un voisin de la fête.

Support — Modèles d'Aline
Je voudrais danser.
Tu devrais écouter.
On pourrait aider.
Nous pourrions rester.
Je partirais plus tôt.
Elle aimerait raconter.
Vous devriez remercier.
Ils pourraient allumer.
$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Nous pourrions » est le conditionnel de pouvoir.",
  "correct": true,
  "explanation": "Pouvoir → je pourrais / nous pourrions."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle forme est correcte pour « je / partir » au conditionnel ?",
  "options": [
    {
      "text": "je partirai",
      "correct": false
    },
    {
      "text": "je partirais",
      "correct": true
    },
    {
      "text": "je partis",
      "correct": false
    },
    {
      "text": "je partirais-tu",
      "correct": false
    }
  ],
  "explanation": "Infinitif + ais : je partirais."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "voudrais",
      "right": "vouloir"
    },
    {
      "left": "devrais",
      "right": "devoir"
    },
    {
      "left": "pourrait",
      "right": "pouvoir"
    },
    {
      "left": "partirais",
      "right": "partir"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJe ___ plus tôt. (partir)",
  "answer": "partirais"
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
    "pourrions",
    "rester",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "aimerait",
  "hint": "Elle… raconter : conditionnel de aimer."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je partirai plus tôt si le cortège se termine maintenant peut-être.",
  "correct_sentence": "Je partirais plus tôt.",
  "explanation": "Conseil / hypothèse → partirais, pas le futur partirai."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/salle-herbes.svg",
      "word": "une salle"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/souhait-conditionnel.svg",
      "word": "un souhait"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/lettre-conseil.svg",
      "word": "une lettre"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/nuage-si.svg",
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
  "prompt": "Écrivez huit conditionnels : deux de chaque verbe (vouloir devoir pouvoir aimer)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez les huit modèles, puis trois conseils à vous."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Ma lettre de souhaits',
    'PE',
    $c$Objectif
Écrire une lettre de souhaits et de conseils.

Consigne
Imitez la lettre de Rose.

Support — Lettre de Rose Iradukunda
Rose Iradukunda
Je voudrais remercier Radio Figuier.
Tu devrais garder une lanterne pour Lila.
On pourrait replier les tissus demain matin.
Nous pourrions écrire un mot à Solange.
Je partirais après le dernier chant.
Vous devriez laisser la cour nette.
Rose
Seuil des Sources — Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Rose voudrait remercier Radio Figuier.",
  "correct": true,
  "explanation": "Première ligne du corps de la lettre."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "À qui pourrait-on écrire un mot ?",
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
      "text": "Sami",
      "correct": false
    },
    {
      "text": "Benoît",
      "correct": false
    }
  ],
  "explanation": "« Nous pourrions écrire un mot à Solange. »"
}$j$::jsonb,
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
      "right": "remercier"
    },
    {
      "left": "tu devrais",
      "right": "garder"
    },
    {
      "left": "on pourrait",
      "right": "replier"
    },
    {
      "left": "je partirais",
      "right": "après le chant"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVous ___ laisser la cour nette.",
  "answer": "devriez"
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
    "replier",
    "les",
    "tissus",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "remercier",
  "hint": "Je voudrais… : dire merci à Radio Figuier."
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Nous pourrions d'écrire un mot à Solange.",
  "correct_sentence": "Nous pourrions écrire un mot à Solange.",
  "explanation": "Pouvoir + infinitif, sans de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/main-aide.svg",
      "word": "une main"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/danse-cultures.svg",
      "word": "une danse"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/tissu-partage.svg",
      "word": "un tissu"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/livre-conte.svg",
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
  "prompt": "Imitez : six lignes au conditionnel (souhait, conseil, proposition)."
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
    'EL — Conditionnel présent',
    'EL',
    $c$Objectif
Retenir la formation et les emplois du conditionnel présent.

Consigne
Apprenez la fiche.

Support — Fiche des souhaits
Formation : radical du futur + ais ais ait ions iez aient
je voudrais / tu devrais / il pourrait / nous pourrions
je partirais / elle aimerait / vous devriez / ils pourraient
Futur : je serai / je partirai / nous pourrons
Conditionnel : je serais / je partirais / nous pourrions
Emplois : souhait (je voudrais), conseil (tu devrais), proposition (on pourrait)
Politesse : je voudrais un thé (plus doux que je veux).
On ne dit pas : je voudrais de danser — je voudrais danser.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Je serai » est un conditionnel.",
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
  "question": "Quelle série est au conditionnel ?",
  "options": [
    {
      "text": "je serai nous pourrons",
      "correct": false
    },
    {
      "text": "je serais nous pourrions",
      "correct": true
    },
    {
      "text": "je suis nous pouvons",
      "correct": false
    },
    {
      "text": "je serai nous pourrions",
      "correct": false
    }
  ],
  "explanation": "ais / ions = conditionnel."
}$j$::jsonb,
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
      "left": "tu devrais",
      "right": "conseil"
    },
    {
      "left": "on pourrait",
      "right": "proposition"
    },
    {
      "left": "je serais",
      "right": "être au conditionnel"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous ___ rester. (pouvoir)",
  "answer": "pourrions"
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
    "partirais",
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
  "word": "politesse",
  "hint": "Je voudrais est plus doux : c'est de la…"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je voudrais de danser encore une fois ce soir.",
  "correct_sentence": "Je voudrais danser encore une fois ce soir.",
  "explanation": "Vouloir + infinitif, sans de."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-a2-m4/radio-soir.svg",
      "word": "une radio"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/marche-lampions.svg",
      "word": "un marché"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/cour-fete.svg",
      "word": "une cour"
    },
    {
      "image_path": "/elearning/mfk-a2-m4/nuance-adverbe.svg",
      "word": "un adverbe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Conjuguez vouloir, devoir, pouvoir et partir au conditionnel (je / nous)."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez la fiche et huit formes (je / nous)."
}$j$::jsonb,
    9
  );

END;
$$;
