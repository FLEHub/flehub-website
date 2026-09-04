/*
  Seed eLearning MFK — C2 — Parler nos français

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-c2-m2/
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
  v_module_title text := 'C2 — Parler nos français';
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
      'Seed C2 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed C2 : enseignant % (%) — %', v_teacher_email, v_teacher_id, v_module_title;

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
      'Grande étape C2-2 : réagir aux emprunts sans purisme de boutique, écrire une lettre ouverte sur les voix de la cour, comparer deux extraits de Mado, parler à voix haute, puis un concours d''éloquence sous le figuier — Aline Uwase distingue les registres, Karim Bamba emprunte sans s''excuser, Lila Sow tend le micro à celles qu''on n''entend pas.',
      'C2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape C2-2 : réagir aux emprunts sans purisme de boutique, écrire une lettre ouverte sur les voix de la cour, comparer deux extraits de Mado, parler à voix haute, puis un concours d''éloquence sous le figuier — Aline Uwase distingue les registres, Karim Bamba emprunte sans s''excuser, Lila Sow tend le micro à celles qu''on n''entend pas.',
      cefr_level = 'C2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Mots voyageurs =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Mots voyageurs'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Mots voyageurs', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Mots voyageurs',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Réagir aux emprunts et définir notre représentation du français au Seuil. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Mots voyageurs
Lila Sow : Radio Figuier. On parle trop vite de les mots voyageurs sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on chasse les emprunts comme une honte, une pureté qui n'a jamais existé sur la pente n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches.
Aline Uwase : Ce que l'on nomme emprunt, ici, n'est pas un slogan : mot venu d'ailleurs, parfois utile.
Patrick Habimana : Karim : encore que certains mots fatiguent, la chasse fatigue davantage.
Hawa Diallo : Aline distingue registre et police.
Joël Mugisha : Hawa emprunte, traduit, n'a pas à s'excuser.
Rose Iradukunda : Rose coud un mot d'ailleurs sur un lin d'ici.
Solange Mukamana : Lila tend le micro aux bouches réelles.
Karim Bamba : Sami joue avec un emprunt ; Yvette sourit.
Félicie Ndayishimiye : Un chiffre, une trace : Karim a listé huit emprunts utiles ; trois vaniteux ; zéro chasse aux bouches.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de parler juste, pas de parler « propre »
Yvette : Patrick refuse la boutique du pur.
Mado : Aline Uwase entend, dans « il faut parler pur », ceci qui n'est pas dit : parler pur veut souvent dire parler comme ceux qui n'ont pas eu à emprunter pour vivre
Sami : Autrement dit, une langue se décrit par ses voyages, pas par une vitrine trop nette
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un article : ce que nous empruntons, ce que nous refusons, sans tribunal
Nina Kayitesi : Marc : décrire une langue, c'est raconter ses voyages.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'émission trop sévère d'un côté, l'article de Karim de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Il faut parler pur, répète-t-on, avec cette innocence des vitrines qui n'ont jamais eu à négocier un prix.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une pureté qui n'a jamais existé sur la pente est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une pureté qui n'a jamais existé sur la pente n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Aline Uwase, que reste-t-il implicite dans « il faut parler pur » ?",
  "options": [
    {
      "text": "Que Karim chasse tous les emprunts",
      "correct": false
    },
    {
      "text": "Parler comme ceux qui n'ont pas eu à emprunter",
      "correct": true
    },
    {
      "text": "Que Aline a interdit le kinyarwanda",
      "correct": false
    },
    {
      "text": "Que Lila ne parle qu'un français de vitrine",
      "correct": false
    }
  ],
  "explanation": "parler pur veut souvent dire parler comme ceux qui n'ont pas eu à emprunter pour vivre"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "emprunt",
      "right": "mot venu d'ailleurs, parfois utile"
    },
    {
      "left": "purisme",
      "right": "exigence trop nette, souvent une police"
    },
    {
      "left": "représentation",
      "right": "image que l'on se fait d'une langue"
    },
    {
      "left": "oreille",
      "right": "juge du trop, distincte d'un tribunal"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAu registre soutenu, on dira ___ et non « c'est pas ouf ». (cela)",
  "answer": "cela"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Au",
    "registre",
    "soutenu",
    "on",
    "dira",
    "cela",
    "et",
    "non",
    "un",
    "mot",
    "trop",
    "large",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "emprunt",
  "hint": "mot venu d'ailleurs, parfois utile"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Au registre soutenu, on dira ça ouais, et Karim Bamba lit encore la motion.",
  "correct_sentence": "Au registre soutenu, on dira cela, et Karim Bamba lit encore la motion.",
  "explanation": "Soutenu : cela, pas ça ouais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m2/emprunt-langue.svg",
      "word": "emprunt langue"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/reine-refusee.svg",
      "word": "reine refusee"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/article-representation.svg",
      "word": "article representation"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/mot-voyageur.svg",
      "word": "mot voyageur"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « il faut parler pur » et la concession de Karim Bamba."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'émission trop sévère et l'article de Karim distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Pas de police des bouches',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Réagir aux emprunts et définir notre représentation du français au Seuil. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Pas de police des bouches », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Pas de police des bouches
On parle trop vite de les mots voyageurs sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on chasse les emprunts comme une honte, une pureté qui n'a jamais existé sur la pente n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches.
Ce que l'on nomme emprunt, ici, n'est pas un slogan : mot venu d'ailleurs, parfois utile.
Karim : encore que certains mots fatiguent, la chasse fatigue davantage.
Aline distingue registre et police.
Hawa emprunte, traduit, n'a pas à s'excuser.
Rose coud un mot d'ailleurs sur un lin d'ici.
Lila tend le micro aux bouches réelles.
Sami joue avec un emprunt ; Yvette sourit.
Un chiffre, une trace : Karim a listé huit emprunts utiles ; trois vaniteux ; zéro chasse aux bouches.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de parler juste, pas de parler « propre »
Patrick refuse la boutique du pur.
Aline Uwase entend, dans « il faut parler pur », ceci qui n'est pas dit : parler pur veut souvent dire parler comme ceux qui n'ont pas eu à emprunter pour vivre
Autrement dit, une langue se décrit par ses voyages, pas par une vitrine trop nette
La proposition qui reste debout est celle-ci : un article : ce que nous empruntons, ce que nous refusons, sans tribunal
Marc : décrire une langue, c'est raconter ses voyages.
Nous clôturons sans fusionner les voix : l'émission trop sévère d'un côté, l'article de Karim de l'autre, et le point où elles refusent de se ressembler.
Signé : Karim Bamba, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'émission trop sévère et l'article de Karim en une seule affiche.",
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
      "text": "Huit utiles, trois vaniteux, zéro chasse",
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
  "explanation": "Karim a listé huit emprunts utiles ; trois vaniteux ; zéro chasse aux bouches."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "emprunt",
      "right": "mot venu d'ailleurs, parfois utile"
    },
    {
      "left": "purisme",
      "right": "exigence trop nette, souvent une police"
    },
    {
      "left": "représentation",
      "right": "image que l'on se fait d'une langue"
    },
    {
      "left": "oreille",
      "right": "juge du trop, distincte d'un tribunal"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le tutoiement ___ possible sous le figuier, le micro de Lila vouvoie l'assemblée. (être, subj.)",
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
    "Encore",
    "que",
    "le",
    "tutoiement",
    "soit",
    "possible",
    "le",
    "micro",
    "vouvoie",
    "l'assemblée",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "purisme",
  "hint": "exigence trop nette, souvent une police"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La emprunt de trop vite n'aide personne, et Aline Uwase reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Aline Uwase reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m2/reine-refusee.svg",
      "word": "reine refusee"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/article-representation.svg",
      "word": "article representation"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/mot-voyageur.svg",
      "word": "mot voyageur"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/lettre-ouverte.svg",
      "word": "lettre ouverte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Pas de police des bouches » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Mots voyageurs : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : emprunts ; représentation d'une langue ; sans purisme de boutique.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on chasse les emprunts comme une honte, une pureté qui n'a jamais existé sur la pente n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches.
Ce que l'on nomme emprunt, ici, n'est pas un slogan : mot venu d'ailleurs, parfois utile.
Encore que l'on emprunte, une pureté qui n'a jamais existé sur la pente n'est pas un détail.
Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches.
Autrement dit, une langue se décrit par ses voyages, pas par une vitrine trop nette
Il ressort qu'un article : ce que nous empruntons, ce que nous refusons, sans tribunal
Aline distingue registre et police.
Lila tend le micro aux bouches réelles.
La proposition qui reste debout est celle-ci : un article : ce que nous empruntons, ce que nous refusons, sans tribunal
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'émission trop sévère d'un côté, l'article de Karim de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Karim Bamba transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Karim Bamba, et à quelle condition ?",
  "options": [
    {
      "text": "Karim Bamba n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "certains emprunts fatiguent l'oreille — à condition que l'on n'en fasse pas une police des bouches",
      "correct": true
    },
    {
      "text": "Karim Bamba abandonne il s'agit de parler juste, pas de parler « propre »",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'en fasse pas une police des bouches"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "emprunt",
      "right": "mot venu d'ailleurs, parfois utile"
    },
    {
      "left": "purisme",
      "right": "exigence trop nette, souvent une police"
    },
    {
      "left": "représentation",
      "right": "image que l'on se fait d'une langue"
    },
    {
      "left": "oreille",
      "right": "juge du trop, distincte d'un tribunal"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ le niveau, non la personne. (emprunter, subj.)",
  "answer": "emprunte"
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
    "emprunte",
    "le",
    "niveau",
    "non",
    "la",
    "personne",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "représentation",
  "hint": "image que l'on se fait d'une langue"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Karim Bamba écoute encore, et il fautons emprunter avant de crier.",
  "correct_sentence": "Karim Bamba écoute encore, et il faut emprunter avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m2/article-representation.svg",
      "word": "article representation"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/mot-voyageur.svg",
      "word": "mot voyageur"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/lettre-ouverte.svg",
      "word": "lettre ouverte"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/politique-linguistique.svg",
      "word": "politique linguistique"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur emprunts ; représentation d'une langue ; sans purisme de boutique, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'émission trop sévère et l'article de Karim distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Karim Bamba',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Réagir aux emprunts et définir notre représentation du français au Seuil. Point : emprunts ; représentation d'une langue ; sans purisme de boutique.

Consigne
Imitez le texte de Karim Bamba.

Support — Karim Bamba — Pas de police des bouches
Karim Bamba — Pas de police des bouches
On parle trop vite de les mots voyageurs sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on chasse les emprunts comme une honte, une pureté qui n'a jamais existé sur la pente n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches.
Ce que l'on nomme emprunt, ici, n'est pas un slogan : mot venu d'ailleurs, parfois utile.
Karim : encore que certains mots fatiguent, la chasse fatigue davantage.
Lila tend le micro aux bouches réelles.
Sami joue avec un emprunt ; Yvette sourit.
Patrick refuse la boutique du pur.
La proposition qui reste debout est celle-ci : un article : ce que nous empruntons, ce que nous refusons, sans tribunal
Marc : décrire une langue, c'est raconter ses voyages.
Nous clôturons sans fusionner les voix : l'émission trop sévère d'un côté, l'article de Karim de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on emprunte, une pureté qui n'a jamais existé sur la pente n'est pas un détail.
Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
une langue se décrit par ses voyages, pas par une vitrine trop nette
Karim Bamba, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un article : ce que nous empruntons, ce que nous refusons, sans tribunal",
  "correct": true,
  "explanation": "un article : ce que nous empruntons, ce que nous refusons, sans tribunal"
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
      "text": "un article : ce que nous empruntons, ce que nous refusons, sans tribunal",
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
  "explanation": "un article : ce que nous empruntons, ce que nous refusons, sans tribunal"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "emprunt",
      "right": "mot venu d'ailleurs, parfois utile"
    },
    {
      "left": "purisme",
      "right": "exigence trop nette, souvent une police"
    },
    {
      "left": "représentation",
      "right": "image que l'on se fait d'une langue"
    },
    {
      "left": "oreille",
      "right": "juge du trop, distincte d'un tribunal"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUn ___ n'est pas une trahison : c'est un choix de relation. (registre)",
  "answer": "registre"
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
    "registre",
    "n'est",
    "pas",
    "une",
    "trahison",
    "c'est",
    "un",
    "choix",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "oreille",
  "hint": "juge du trop, distincte d'un tribunal"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Karim Bamba est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Karim Bamba sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c2-m2/mot-voyageur.svg",
      "word": "mot voyageur"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/lettre-ouverte.svg",
      "word": "lettre ouverte"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/politique-linguistique.svg",
      "word": "politique linguistique"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/francophonies.svg",
      "word": "francophonies"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Karim Bamba : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — emprunts ; représentation d''une langue ; sans purisme de boutique',
    'EL',
    $c$Objectif
Maîtriser emprunts ; représentation d'une langue ; sans purisme de boutique au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — emprunts ; représentation d'une langue ; sans purisme de boutique
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on emprunte, une pureté qui n'a jamais existé sur la pente n'est pas un détail.
Karim Bamba concède que certains emprunts fatiguent l'oreille, pour autant que l'on n'en fasse pas une police des bouches.
Autrement dit, une langue se décrit par ses voyages, pas par une vitrine trop nette
Il ressort qu'un article : ce que nous empruntons, ce que nous refusons, sans tribunal
Piège : familier non signalé dans un discours d'assemblée
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme emprunt, ici, n'est pas un slogan : mot venu d'ailleurs, parfois utile.
Aline distingue registre et police.
Lila tend le micro aux bouches réelles.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au représentation pour de vrai genre, et Aline Uwase demande un registre plus net.
Correction : On va au représentation vraiment, et Aline Uwase demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le vouvoiement du micro peut coexister avec le tutoiement du banc.",
  "correct": true,
  "explanation": "Registres situés."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Changer de registre, c'est surtout…",
  "options": [
    {
      "text": "parler « faux »",
      "correct": false
    },
    {
      "text": "ajuster la relation et l'oreille",
      "correct": true
    },
    {
      "text": "oublier la grammaire",
      "correct": false
    },
    {
      "text": "interdire le figuier",
      "correct": false
    }
  ],
  "explanation": "Variation de registre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "emprunt",
      "right": "mot venu d'ailleurs, parfois utile"
    },
    {
      "left": "purisme",
      "right": "exigence trop nette, souvent une police"
    },
    {
      "left": "représentation",
      "right": "image que l'on se fait d'une langue"
    },
    {
      "left": "oreille",
      "right": "juge du trop, distincte d'un tribunal"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLoin de ___, adapter le discours c'est respecter l'oreille. (tricher)",
  "answer": "tricher"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Adapter",
    "le",
    "discours",
    "c'est",
    "respecter",
    "l'oreille",
    "."
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
  "sentence_with_error": "On va au représentation pour de vrai genre, et Aline Uwase demande un registre plus net.",
  "correct_sentence": "On va au représentation vraiment, et Aline Uwase demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m2/lettre-ouverte.svg",
      "word": "lettre ouverte"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/politique-linguistique.svg",
      "word": "politique linguistique"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/francophonies.svg",
      "word": "francophonies"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/carte-voix.svg",
      "word": "carte voix"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « emprunts ; représentation d'une langue ; sans purisme de boutique » et deux pièges commentés."
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

  -- ===== Politiques des voix =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Politiques des voix'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Politiques des voix', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Politiques des voix',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Analyser et écrire une lettre ouverte sur les voix de la cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Politiques des voix
Lila Sow : Radio Figuier. On parle trop vite de qui a droit au micro de Radio Figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on réduit les voix à un usage trop étroit, un micro qui n'ouvre qu'à une musique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Lila Sow concède que un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Aline Uwase : Ce que l'on nomme politique, ici, n'est pas un slogan : choix collectif sur les voix.
Patrick Habimana : Lila : il convient que l'on ouvre, encore que l'on traduise.
Hawa Diallo : Aline refuse l'effacement poli.
Joël Mugisha : Hawa écrit une phrase de la lettre en deux souffles.
Rose Iradukunda : Karim veut être compris, pas réduit.
Solange Mukamana : Solange signe.
Karim Bamba : Patrick relit le ton.
Félicie Ndayishimiye : Un chiffre, une trace : Lila a ouvert trois heures mixtes ; deux refus poliment notés ; une lettre signée par onze voix.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de politiques de cour, pas d'un État fantasmé
Yvette : Sami lit trop vite ; on le ralentit.
Mado : Aline Uwase entend, dans « une seule langue officielle de cour », ceci qui n'est pas dit : une seule langue officielle veut souvent dire une seule oreille légitime
Sami : Autrement dit, il convient que l'on ouvre le micro, encore que l'assemblée ait besoin d'un usage commun
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une lettre ouverte : heures, langues, droit d'être compris sans être effacé
Nina Kayitesi : Marc : une lettre ouverte nomme le micro, pas un empire.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le projet trop étroit d'un côté, la lettre ouverte de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Une seule langue officielle de cour : formule propre, comme le sont souvent les exclusions.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un micro qui n'ouvre qu'à une musique est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un micro qui n'ouvre qu'à une musique n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Aline Uwase, que reste-t-il implicite dans « une seule langue officielle de cour » ?",
  "options": [
    {
      "text": "Que Lila a fermé le français",
      "correct": false
    },
    {
      "text": "Une seule oreille légitime",
      "correct": true
    },
    {
      "text": "Que Aline exige une seule bouche",
      "correct": false
    },
    {
      "text": "Que les onze signatures sont fausses",
      "correct": false
    }
  ],
  "explanation": "une seule langue officielle veut souvent dire une seule oreille légitime"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "politique",
      "right": "choix collectif sur les voix"
    },
    {
      "left": "micro",
      "right": "accès à Radio Figuier"
    },
    {
      "left": "usage",
      "right": "pratique commune, pas une chasse"
    },
    {
      "left": "lettre",
      "right": "forme pour dénoncer un étroit"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ avant d'accélérer. (ouvrir, subj.)",
  "answer": "ouvre"
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
    "ouvre",
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
  "word": "politique",
  "hint": "choix collectif sur les voix"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il convient que l'on ouvrir trop tard, et Lila Sow refuse d'accélérer la pente.",
  "correct_sentence": "Il convient que l'on ouvre trop tard, et Lila Sow refuse d'accélérer la pente.",
  "explanation": "Il convient que + ouvre."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m2/politique-linguistique.svg",
      "word": "politique linguistique"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/francophonies.svg",
      "word": "francophonies"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/carte-voix.svg",
      "word": "carte voix"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/langage-social.svg",
      "word": "langage social"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « une seule langue officielle de cour » et la concession de Lila Sow."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le projet trop étroit et la lettre ouverte distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Plus d''une oreille',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Analyser et écrire une lettre ouverte sur les voix de la cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Plus d'une oreille », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Plus d'une oreille
On parle trop vite de qui a droit au micro de Radio Figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduit les voix à un usage trop étroit, un micro qui n'ouvre qu'à une musique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Ce que l'on nomme politique, ici, n'est pas un slogan : choix collectif sur les voix.
Lila : il convient que l'on ouvre, encore que l'on traduise.
Aline refuse l'effacement poli.
Hawa écrit une phrase de la lettre en deux souffles.
Karim veut être compris, pas réduit.
Solange signe.
Patrick relit le ton.
Un chiffre, une trace : Lila a ouvert trois heures mixtes ; deux refus poliment notés ; une lettre signée par onze voix.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de politiques de cour, pas d'un État fantasmé
Sami lit trop vite ; on le ralentit.
Aline Uwase entend, dans « une seule langue officielle de cour », ceci qui n'est pas dit : une seule langue officielle veut souvent dire une seule oreille légitime
Autrement dit, il convient que l'on ouvre le micro, encore que l'assemblée ait besoin d'un usage commun
La proposition qui reste debout est celle-ci : une lettre ouverte : heures, langues, droit d'être compris sans être effacé
Marc : une lettre ouverte nomme le micro, pas un empire.
Nous clôturons sans fusionner les voix : le projet trop étroit d'un côté, la lettre ouverte de l'autre, et le point où elles refusent de se ressembler.
Signé : Lila Sow, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le projet trop étroit et la lettre ouverte en une seule affiche.",
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
      "text": "Trois heures mixtes, deux refus, onze signatures",
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
  "explanation": "Lila a ouvert trois heures mixtes ; deux refus poliment notés ; une lettre signée par onze voix."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "politique",
      "right": "choix collectif sur les voix"
    },
    {
      "left": "micro",
      "right": "accès à Radio Figuier"
    },
    {
      "left": "usage",
      "right": "pratique commune, pas une chasse"
    },
    {
      "left": "lettre",
      "right": "forme pour dénoncer un étroit"
    }
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
  "word": "micro",
  "hint": "accès à Radio Figuier"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La politique de trop vite n'aide personne, et Aline Uwase reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Aline Uwase reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m2/francophonies.svg",
      "word": "francophonies"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/carte-voix.svg",
      "word": "carte voix"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/langage-social.svg",
      "word": "langage social"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/deux-extraits.svg",
      "word": "deux extraits"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Plus d'une oreille » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Politiques des voix : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : lettre ouverte ; politiques linguistiques inventées ; francophonies.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on réduit les voix à un usage trop étroit, un micro qui n'ouvre qu'à une musique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Ce que l'on nomme politique, ici, n'est pas un slogan : choix collectif sur les voix.
Encore que l'on ouvre, un micro qui n'ouvre qu'à une musique n'est pas un détail.
Lila Sow concède que un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Autrement dit, il convient que l'on ouvre le micro, encore que l'assemblée ait besoin d'un usage commun
Il ressort qu'une lettre ouverte : heures, langues, droit d'être compris sans être effacé
Aline refuse l'effacement poli.
Solange signe.
La proposition qui reste debout est celle-ci : une lettre ouverte : heures, langues, droit d'être compris sans être effacé
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le projet trop étroit d'un côté, la lettre ouverte de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Lila Sow transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Lila Sow concède que un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Lila Sow, et à quelle condition ?",
  "options": [
    {
      "text": "Lila Sow n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "un usage commun aide l'assemblée — à condition que l'on n'en fasse pas l'effacement des autres souffles",
      "correct": true
    },
    {
      "text": "Lila Sow abandonne il s'agit de politiques de cour, pas d'un État fantasmé",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'en fasse pas l'effacement des autres souffles"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "politique",
      "right": "choix collectif sur les voix"
    },
    {
      "left": "micro",
      "right": "accès à Radio Figuier"
    },
    {
      "left": "usage",
      "right": "pratique commune, pas une chasse"
    },
    {
      "left": "lettre",
      "right": "forme pour dénoncer un étroit"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous recommandons que la cour ___ un relais. (ouvrir, subj.)",
  "answer": "ouvre"
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
    "ouvre",
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
  "word": "usage",
  "hint": "pratique commune, pas une chasse"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lila Sow écoute encore, et il fautons ouvrir avant de crier.",
  "correct_sentence": "Lila Sow écoute encore, et il faut ouvrir avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m2/carte-voix.svg",
      "word": "carte voix"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/langage-social.svg",
      "word": "langage social"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/deux-extraits.svg",
      "word": "deux extraits"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/registre-classe.svg",
      "word": "registre classe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur lettre ouverte ; politiques linguistiques inventées ; francophonies, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le projet trop étroit et la lettre ouverte distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Lila Sow',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Analyser et écrire une lettre ouverte sur les voix de la cour. Point : lettre ouverte ; politiques linguistiques inventées ; francophonies.

Consigne
Imitez le texte de Lila Sow.

Support — Lila Sow — Plus d'une oreille
Lila Sow — Plus d'une oreille
On parle trop vite de qui a droit au micro de Radio Figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduit les voix à un usage trop étroit, un micro qui n'ouvre qu'à une musique n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Ce que l'on nomme politique, ici, n'est pas un slogan : choix collectif sur les voix.
Lila : il convient que l'on ouvre, encore que l'on traduise.
Solange signe.
Patrick relit le ton.
Sami lit trop vite ; on le ralentit.
La proposition qui reste debout est celle-ci : une lettre ouverte : heures, langues, droit d'être compris sans être effacé
Marc : une lettre ouverte nomme le micro, pas un empire.
Nous clôturons sans fusionner les voix : le projet trop étroit d'un côté, la lettre ouverte de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on ouvre, un micro qui n'ouvre qu'à une musique n'est pas un détail.
Lila Sow concède que un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il convient que l'on ouvre le micro, encore que l'assemblée ait besoin d'un usage commun
Lila Sow, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : une lettre ouverte : heures, langues, droit d'être compris sans être effacé",
  "correct": true,
  "explanation": "une lettre ouverte : heures, langues, droit d'être compris sans être effacé"
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
      "text": "une lettre ouverte : heures, langues, droit d'être compris sans être effacé",
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
  "explanation": "une lettre ouverte : heures, langues, droit d'être compris sans être effacé"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "politique",
      "right": "choix collectif sur les voix"
    },
    {
      "left": "micro",
      "right": "accès à Radio Figuier"
    },
    {
      "left": "usage",
      "right": "pratique commune, pas une chasse"
    },
    {
      "left": "lettre",
      "right": "forme pour dénoncer un étroit"
    }
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
  "word": "lettre",
  "hint": "forme pour dénoncer un étroit"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Lila Sow est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Lila Sow sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c2-m2/langage-social.svg",
      "word": "langage social"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/deux-extraits.svg",
      "word": "deux extraits"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/registre-classe.svg",
      "word": "registre classe"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/choisir-mot.svg",
      "word": "choisir mot"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Lila Sow : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — lettre ouverte ; politiques linguistiques inventées ; francophonies',
    'EL',
    $c$Objectif
Maîtriser lettre ouverte ; politiques linguistiques inventées ; francophonies au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — lettre ouverte ; politiques linguistiques inventées ; francophonies
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on ouvre, un micro qui n'ouvre qu'à une musique n'est pas un détail.
Lila Sow concède que un usage commun aide l'assemblée, pour autant que l'on n'en fasse pas l'effacement des autres souffles.
Autrement dit, il convient que l'on ouvre le micro, encore que l'assemblée ait besoin d'un usage commun
Il ressort qu'une lettre ouverte : heures, langues, droit d'être compris sans être effacé
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme politique, ici, n'est pas un slogan : choix collectif sur les voix.
Aline refuse l'effacement poli.
Solange signe.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au usage pour de vrai genre, et Aline Uwase demande un registre plus net.
Correction : On va au usage vraiment, et Aline Uwase demande un registre plus net.
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
      "left": "politique",
      "right": "choix collectif sur les voix"
    },
    {
      "left": "micro",
      "right": "accès à Radio Figuier"
    },
    {
      "left": "usage",
      "right": "pratique commune, pas une chasse"
    },
    {
      "left": "lettre",
      "right": "forme pour dénoncer un étroit"
    }
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
  "sentence_with_error": "On va au usage pour de vrai genre, et Aline Uwase demande un registre plus net.",
  "correct_sentence": "On va au usage vraiment, et Aline Uwase demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m2/deux-extraits.svg",
      "word": "deux extraits"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/registre-classe.svg",
      "word": "registre classe"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/choisir-mot.svg",
      "word": "choisir mot"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/voix-haute.svg",
      "word": "voix haute"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « lettre ouverte ; politiques linguistiques inventées ; francophonies » et deux pièges commentés."
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

  -- ===== Deux extraits deux oreilles =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Deux extraits deux oreilles'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Deux extraits deux oreilles', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Deux extraits deux oreilles',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Comparer deux extraits de Mado et commenter les choix d'écriture. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Deux extraits deux oreilles
Lila Sow : Radio Figuier. On parle trop vite de deux extraits trop éloignés pour n'être pas une politique, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on écrase l'hypotaxe au nom du peuple, un simple qui n'est que du mépris déguisé n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent.
Aline Uwase : Ce que l'on nomme extrait, ici, n'est pas un slogan : morceau comparé, avec un rythme.
Patrick Habimana : Mado : loin de s'opposer, les deux extraits se jugent à ce qu'ils excluent.
Hawa Diallo : Aline commente dont et auquel dans le noué.
Joël Mugisha : Sami aime la coupe.
Rose Iradukunda : Yvette la noue.
Solange Mukamana : Lila lira les deux, lentement.
Karim Bamba : Karim refuse le mot peuple collé.
Félicie Ndayishimiye : Un chiffre, une trace : Mado a posé deux pages ; Aline a noté six relatives ; Sami a préféré la courte, Yvette la nouée.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de voir le registre comme un choix, pas comme une nature
Yvette : Patrick : un choix d'écriture est une politique de l'oreille.
Mado : Aline Uwase entend, dans « il faut écrire simple », ceci qui n'est pas dit : écrire simple veut parfois dire n'embêtez pas ceux qui pourraient comprendre plus loin
Sami : Autrement dit, deux extraits : l'un coupe court, l'autre noue ; ni l'un ni l'autre n'est le peuple
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un commentaire : destinataires, rythme, ce que chaque choix exclut
Nina Kayitesi : Marc : commenter, c'est dire pour qui l'on coupe, pour qui l'on noue.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'extrait court d'un côté, l'extrait noué de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Il faut écrire simple, dit-on, souvent de très loin des bouches que l'on prétend servir.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un simple qui n'est que du mépris déguisé est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un simple qui n'est que du mépris déguisé n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Aline Uwase, que reste-t-il implicite dans « il faut écrire simple » ?",
  "options": [
    {
      "text": "Que Mado méprise le peuple",
      "correct": false
    },
    {
      "text": "N'embêtez pas ceux qui pourraient aller plus loin",
      "correct": true
    },
    {
      "text": "Que Aline interdit les phrases courtes",
      "correct": false
    },
    {
      "text": "Que Yvette n'a rien compris",
      "correct": false
    }
  ],
  "explanation": "écrire simple veut parfois dire n'embêtez pas ceux qui pourraient comprendre plus loin"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "extrait",
      "right": "morceau comparé, avec un rythme"
    },
    {
      "left": "hypotaxe",
      "right": "phrase nouée, légitime au C2"
    },
    {
      "left": "clarté",
      "right": "politesse, distincte d'un écrasement"
    },
    {
      "left": "destinataire",
      "right": "oreille visée par le choix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAu registre soutenu, on dira ___ et non « c'est pas ouf ». (cela)",
  "answer": "cela"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Au",
    "registre",
    "soutenu",
    "on",
    "dira",
    "cela",
    "et",
    "non",
    "un",
    "mot",
    "trop",
    "large",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "extrait",
  "hint": "morceau comparé, avec un rythme"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Au registre soutenu, on dira ça ouais, et Mado lit encore la motion.",
  "correct_sentence": "Au registre soutenu, on dira cela, et Mado lit encore la motion.",
  "explanation": "Soutenu : cela, pas ça ouais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m2/registre-classe.svg",
      "word": "registre classe"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/choisir-mot.svg",
      "word": "choisir mot"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/voix-haute.svg",
      "word": "voix haute"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/concours-eloquence.svg",
      "word": "concours eloquence"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « il faut écrire simple » et la concession de Mado."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'extrait court et l'extrait noué distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Ni l''un ni l''autre n''est le peuple',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comparer deux extraits de Mado et commenter les choix d'écriture. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Ni l'un ni l'autre n'est le peuple », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Ni l'un ni l'autre n'est le peuple
On parle trop vite de deux extraits trop éloignés pour n'être pas une politique, comme si le mot dispensait d'en examiner le prix.
Encore que l'on écrase l'hypotaxe au nom du peuple, un simple qui n'est que du mépris déguisé n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent.
Ce que l'on nomme extrait, ici, n'est pas un slogan : morceau comparé, avec un rythme.
Mado : loin de s'opposer, les deux extraits se jugent à ce qu'ils excluent.
Aline commente dont et auquel dans le noué.
Sami aime la coupe.
Yvette la noue.
Lila lira les deux, lentement.
Karim refuse le mot peuple collé.
Un chiffre, une trace : Mado a posé deux pages ; Aline a noté six relatives ; Sami a préféré la courte, Yvette la nouée.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de voir le registre comme un choix, pas comme une nature
Patrick : un choix d'écriture est une politique de l'oreille.
Aline Uwase entend, dans « il faut écrire simple », ceci qui n'est pas dit : écrire simple veut parfois dire n'embêtez pas ceux qui pourraient comprendre plus loin
Autrement dit, deux extraits : l'un coupe court, l'autre noue ; ni l'un ni l'autre n'est le peuple
La proposition qui reste debout est celle-ci : un commentaire : destinataires, rythme, ce que chaque choix exclut
Marc : commenter, c'est dire pour qui l'on coupe, pour qui l'on noue.
Nous clôturons sans fusionner les voix : l'extrait court d'un côté, l'extrait noué de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'extrait court et l'extrait noué en une seule affiche.",
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
      "text": "Deux pages, six relatives, deux préférences",
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
  "explanation": "Mado a posé deux pages ; Aline a noté six relatives ; Sami a préféré la courte, Yvette la nouée."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "extrait",
      "right": "morceau comparé, avec un rythme"
    },
    {
      "left": "hypotaxe",
      "right": "phrase nouée, légitime au C2"
    },
    {
      "left": "clarté",
      "right": "politesse, distincte d'un écrasement"
    },
    {
      "left": "destinataire",
      "right": "oreille visée par le choix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le tutoiement ___ possible sous le figuier, le micro de Lila vouvoie l'assemblée. (être, subj.)",
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
    "Encore",
    "que",
    "le",
    "tutoiement",
    "soit",
    "possible",
    "le",
    "micro",
    "vouvoie",
    "l'assemblée",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "hypotaxe",
  "hint": "phrase nouée, légitime au C2"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La extrait de trop vite n'aide personne, et Aline Uwase reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Aline Uwase reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m2/choisir-mot.svg",
      "word": "choisir mot"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/voix-haute.svg",
      "word": "voix haute"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/concours-eloquence.svg",
      "word": "concours eloquence"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/pupitre-aline.svg",
      "word": "pupitre aline"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Ni l'un ni l'autre n'est le peuple » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Deux extraits deux oreilles : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : registres sociaux ; comparer deux extraits ; choix d'écriture.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on écrase l'hypotaxe au nom du peuple, un simple qui n'est que du mépris déguisé n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent.
Ce que l'on nomme extrait, ici, n'est pas un slogan : morceau comparé, avec un rythme.
Encore que l'on compare, un simple qui n'est que du mépris déguisé n'est pas un détail.
Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent.
Autrement dit, deux extraits : l'un coupe court, l'autre noue ; ni l'un ni l'autre n'est le peuple
Il ressort qu'un commentaire : destinataires, rythme, ce que chaque choix exclut
Aline commente dont et auquel dans le noué.
Lila lira les deux, lentement.
La proposition qui reste debout est celle-ci : un commentaire : destinataires, rythme, ce que chaque choix exclut
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'extrait court d'un côté, l'extrait noué de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent."
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
      "text": "la clarté est une politesse — à condition que l'on n'interdise pas la phrase longue à celles qui la tiennent",
      "correct": true
    },
    {
      "text": "Mado abandonne il s'agit de voir le registre comme un choix, pas comme une nature",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'interdise pas la phrase longue à celles qui la tiennent"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "extrait",
      "right": "morceau comparé, avec un rythme"
    },
    {
      "left": "hypotaxe",
      "right": "phrase nouée, légitime au C2"
    },
    {
      "left": "clarté",
      "right": "politesse, distincte d'un écrasement"
    },
    {
      "left": "destinataire",
      "right": "oreille visée par le choix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ le niveau, non la personne. (comparer, subj.)",
  "answer": "compare"
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
    "compare",
    "le",
    "niveau",
    "non",
    "la",
    "personne",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "clarté",
  "hint": "politesse, distincte d'un écrasement"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Mado écoute encore, et il fautons comparer avant de crier.",
  "correct_sentence": "Mado écoute encore, et il faut comparer avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m2/voix-haute.svg",
      "word": "voix haute"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/concours-eloquence.svg",
      "word": "concours eloquence"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/pupitre-aline.svg",
      "word": "pupitre aline"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/souffle-phrase.svg",
      "word": "souffle phrase"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur registres sociaux ; comparer deux extraits ; choix d'écriture, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'extrait court et l'extrait noué distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Mado',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Comparer deux extraits de Mado et commenter les choix d'écriture. Point : registres sociaux ; comparer deux extraits ; choix d'écriture.

Consigne
Imitez le texte de Mado.

Support — Mado — Ni l'un ni l'autre n'est le peuple
Mado — Ni l'un ni l'autre n'est le peuple
On parle trop vite de deux extraits trop éloignés pour n'être pas une politique, comme si le mot dispensait d'en examiner le prix.
Encore que l'on écrase l'hypotaxe au nom du peuple, un simple qui n'est que du mépris déguisé n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent.
Ce que l'on nomme extrait, ici, n'est pas un slogan : morceau comparé, avec un rythme.
Mado : loin de s'opposer, les deux extraits se jugent à ce qu'ils excluent.
Lila lira les deux, lentement.
Karim refuse le mot peuple collé.
Patrick : un choix d'écriture est une politique de l'oreille.
La proposition qui reste debout est celle-ci : un commentaire : destinataires, rythme, ce que chaque choix exclut
Marc : commenter, c'est dire pour qui l'on coupe, pour qui l'on noue.
Nous clôturons sans fusionner les voix : l'extrait court d'un côté, l'extrait noué de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on compare, un simple qui n'est que du mépris déguisé n'est pas un détail.
Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
deux extraits : l'un coupe court, l'autre noue ; ni l'un ni l'autre n'est le peuple
Mado, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un commentaire : destinataires, rythme, ce que chaque choix exclut",
  "correct": true,
  "explanation": "un commentaire : destinataires, rythme, ce que chaque choix exclut"
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
      "text": "un commentaire : destinataires, rythme, ce que chaque choix exclut",
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
  "explanation": "un commentaire : destinataires, rythme, ce que chaque choix exclut"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "extrait",
      "right": "morceau comparé, avec un rythme"
    },
    {
      "left": "hypotaxe",
      "right": "phrase nouée, légitime au C2"
    },
    {
      "left": "clarté",
      "right": "politesse, distincte d'un écrasement"
    },
    {
      "left": "destinataire",
      "right": "oreille visée par le choix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUn ___ n'est pas une trahison : c'est un choix de relation. (registre)",
  "answer": "registre"
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
    "registre",
    "n'est",
    "pas",
    "une",
    "trahison",
    "c'est",
    "un",
    "choix",
    "."
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
  "hint": "oreille visée par le choix"
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
      "image_path": "/elearning/mfk-c2-m2/concours-eloquence.svg",
      "word": "concours eloquence"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/pupitre-aline.svg",
      "word": "pupitre aline"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/souffle-phrase.svg",
      "word": "souffle phrase"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/oral-rapport.svg",
      "word": "oral rapport"
    }
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
    'EL — registres sociaux ; comparer deux extraits ; choix d''écriture',
    'EL',
    $c$Objectif
Maîtriser registres sociaux ; comparer deux extraits ; choix d'écriture au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — registres sociaux ; comparer deux extraits ; choix d'écriture
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on compare, un simple qui n'est que du mépris déguisé n'est pas un détail.
Mado concède que la clarté est une politesse, pour autant que l'on n'interdise pas la phrase longue à celles qui la tiennent.
Autrement dit, deux extraits : l'un coupe court, l'autre noue ; ni l'un ni l'autre n'est le peuple
Il ressort qu'un commentaire : destinataires, rythme, ce que chaque choix exclut
Piège : familier non signalé dans un discours d'assemblée
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme extrait, ici, n'est pas un slogan : morceau comparé, avec un rythme.
Aline commente dont et auquel dans le noué.
Lila lira les deux, lentement.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au clarté pour de vrai genre, et Aline Uwase demande un registre plus net.
Correction : On va au clarté vraiment, et Aline Uwase demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le vouvoiement du micro peut coexister avec le tutoiement du banc.",
  "correct": true,
  "explanation": "Registres situés."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Changer de registre, c'est surtout…",
  "options": [
    {
      "text": "parler « faux »",
      "correct": false
    },
    {
      "text": "ajuster la relation et l'oreille",
      "correct": true
    },
    {
      "text": "oublier la grammaire",
      "correct": false
    },
    {
      "text": "interdire le figuier",
      "correct": false
    }
  ],
  "explanation": "Variation de registre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "extrait",
      "right": "morceau comparé, avec un rythme"
    },
    {
      "left": "hypotaxe",
      "right": "phrase nouée, légitime au C2"
    },
    {
      "left": "clarté",
      "right": "politesse, distincte d'un écrasement"
    },
    {
      "left": "destinataire",
      "right": "oreille visée par le choix"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLoin de ___, adapter le discours c'est respecter l'oreille. (tricher)",
  "answer": "tricher"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Adapter",
    "le",
    "discours",
    "c'est",
    "respecter",
    "l'oreille",
    "."
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
  "sentence_with_error": "On va au clarté pour de vrai genre, et Aline Uwase demande un registre plus net.",
  "correct_sentence": "On va au clarté vraiment, et Aline Uwase demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m2/pupitre-aline.svg",
      "word": "pupitre aline"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/souffle-phrase.svg",
      "word": "souffle phrase"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/oral-rapport.svg",
      "word": "oral rapport"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/essai-dire.svg",
      "word": "essai dire"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « registres sociaux ; comparer deux extraits ; choix d'écriture » et deux pièges commentés."
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

  -- ===== Le souffle sous le figuier =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Le souffle sous le figuier'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Le souffle sous le figuier', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le souffle sous le figuier',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Parler de notre rapport à l'oral et préparer un discours d'éloquence de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le souffle sous le figuier
Lila Sow : Radio Figuier. On parle trop vite de le concours d'éloquence sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace l'argument par le souffle trop sûr, une éloquence qui n'écoute plus n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire.
Aline Uwase : Ce que l'on nomme éloquence, ici, n'est pas un slogan : art de dire, avec un plan.
Patrick Habimana : Aline : il convient que l'on convainque, encore que l'on respire.
Hawa Diallo : Léa pose la concession avant le geste.
Joël Mugisha : Sami a trop de souffle, pas assez de selon.
Rose Iradukunda : Yvette parle bas, et l'on entend.
Solange Mukamana : Lila tend le micro sans le pousser.
Karim Bamba : Patrick refuse le ventre comme méthode.
Félicie Ndayishimiye : Un chiffre, une trace : Aline a chronométré quatre minutes ; un silence ; zéro ventre sans plan.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de convaincre une cour, pas de la submerger
Yvette : Rose écoute les mains de l'orateur.
Mado : Lila Sow entend, dans « parlez avec le ventre », ceci qui n'est pas dit : parlez avec le ventre dispense trop souvent d'avoir un plan
Sami : Autrement dit, l'art oratoire au Seuil, c'est un plan, un souffle, un silence, un destinataire
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un discours de quatre minutes : thèse, concession, implicite, geste
Nina Kayitesi : Marc : un concours d'éloquence au Seuil se juge à ce qu'il n'a pas écrasé.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'essai d'Aline sur l'oral d'un côté, le discours de Léa de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Parlez avec le ventre : conseil généreux, surtout quand le ventre n'a pas eu à lire le dossier.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une éloquence qui n'écoute plus est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une éloquence qui n'écoute plus n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Lila Sow, que reste-t-il implicite dans « parlez avec le ventre » ?",
  "options": [
    {
      "text": "Que Aline a parlé sans plan",
      "correct": false
    },
    {
      "text": "Dispenser d'un plan",
      "correct": true
    },
    {
      "text": "Que Léa a crié",
      "correct": false
    },
    {
      "text": "Que Lila a coupé tous les silences",
      "correct": false
    }
  ],
  "explanation": "parlez avec le ventre dispense trop souvent d'avoir un plan"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "éloquence",
      "right": "art de dire, avec un plan"
    },
    {
      "left": "souffle",
      "right": "rythme oral, pas un remplacement d'idée"
    },
    {
      "left": "discours",
      "right": "texte dit, destiné à une oreille"
    },
    {
      "left": "destinataire",
      "right": "cour visée, pas une foule abstraite"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAu registre soutenu, on dira ___ et non « c'est pas ouf ». (cela)",
  "answer": "cela"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Au",
    "registre",
    "soutenu",
    "on",
    "dira",
    "cela",
    "et",
    "non",
    "un",
    "mot",
    "trop",
    "large",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "éloquence",
  "hint": "art de dire, avec un plan"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Au registre soutenu, on dira ça ouais, et Aline Uwase lit encore la motion.",
  "correct_sentence": "Au registre soutenu, on dira cela, et Aline Uwase lit encore la motion.",
  "explanation": "Soutenu : cela, pas ça ouais."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m2/souffle-phrase.svg",
      "word": "souffle phrase"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/oral-rapport.svg",
      "word": "oral rapport"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/essai-dire.svg",
      "word": "essai dire"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/micro-langue.svg",
      "word": "micro langue"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « parlez avec le ventre » et la concession de Aline Uwase."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'essai d'Aline sur l'oral et le discours de Léa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Un plan, puis le souffle',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Parler de notre rapport à l'oral et préparer un discours d'éloquence de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Un plan, puis le souffle », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Un plan, puis le souffle
On parle trop vite de le concours d'éloquence sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'argument par le souffle trop sûr, une éloquence qui n'écoute plus n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire.
Ce que l'on nomme éloquence, ici, n'est pas un slogan : art de dire, avec un plan.
Aline : il convient que l'on convainque, encore que l'on respire.
Léa pose la concession avant le geste.
Sami a trop de souffle, pas assez de selon.
Yvette parle bas, et l'on entend.
Lila tend le micro sans le pousser.
Patrick refuse le ventre comme méthode.
Un chiffre, une trace : Aline a chronométré quatre minutes ; un silence ; zéro ventre sans plan.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de convaincre une cour, pas de la submerger
Rose écoute les mains de l'orateur.
Lila Sow entend, dans « parlez avec le ventre », ceci qui n'est pas dit : parlez avec le ventre dispense trop souvent d'avoir un plan
Autrement dit, l'art oratoire au Seuil, c'est un plan, un souffle, un silence, un destinataire
La proposition qui reste debout est celle-ci : un discours de quatre minutes : thèse, concession, implicite, geste
Marc : un concours d'éloquence au Seuil se juge à ce qu'il n'a pas écrasé.
Nous clôturons sans fusionner les voix : l'essai d'Aline sur l'oral d'un côté, le discours de Léa de l'autre, et le point où elles refusent de se ressembler.
Signé : Aline Uwase, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'essai d'Aline sur l'oral et le discours de Léa en une seule affiche.",
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
      "text": "Quatre minutes, un silence, zéro ventre sans plan",
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
  "explanation": "Aline a chronométré quatre minutes ; un silence ; zéro ventre sans plan."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "éloquence",
      "right": "art de dire, avec un plan"
    },
    {
      "left": "souffle",
      "right": "rythme oral, pas un remplacement d'idée"
    },
    {
      "left": "discours",
      "right": "texte dit, destiné à une oreille"
    },
    {
      "left": "destinataire",
      "right": "cour visée, pas une foule abstraite"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le tutoiement ___ possible sous le figuier, le micro de Lila vouvoie l'assemblée. (être, subj.)",
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
    "Encore",
    "que",
    "le",
    "tutoiement",
    "soit",
    "possible",
    "le",
    "micro",
    "vouvoie",
    "l'assemblée",
    "."
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
  "hint": "rythme oral, pas un remplacement d'idée"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La éloquence de trop vite n'aide personne, et Lila Sow reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Lila Sow reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m2/oral-rapport.svg",
      "word": "oral rapport"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/essai-dire.svg",
      "word": "essai dire"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/micro-langue.svg",
      "word": "micro langue"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/cahier-emprunts.svg",
      "word": "cahier emprunts"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Un plan, puis le souffle » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Le souffle sous le figuier : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : art oratoire ; rapport à l'oral ; souffle et hypotaxe.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace l'argument par le souffle trop sûr, une éloquence qui n'écoute plus n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire.
Ce que l'on nomme éloquence, ici, n'est pas un slogan : art de dire, avec un plan.
Encore que l'on convainque, une éloquence qui n'écoute plus n'est pas un détail.
Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire.
Autrement dit, l'art oratoire au Seuil, c'est un plan, un souffle, un silence, un destinataire
Il ressort qu'un discours de quatre minutes : thèse, concession, implicite, geste
Léa pose la concession avant le geste.
Lila tend le micro sans le pousser.
La proposition qui reste debout est celle-ci : un discours de quatre minutes : thèse, concession, implicite, geste
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'essai d'Aline sur l'oral d'un côté, le discours de Léa de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Aline Uwase transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Aline Uwase, et à quelle condition ?",
  "options": [
    {
      "text": "Aline Uwase n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "le souffle porte — à condition que l'on n'y voie pas le droit de n'avoir rien à dire",
      "correct": true
    },
    {
      "text": "Aline Uwase abandonne il s'agit de convaincre une cour, pas de la submerger",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y voie pas le droit de n'avoir rien à dire"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "éloquence",
      "right": "art de dire, avec un plan"
    },
    {
      "left": "souffle",
      "right": "rythme oral, pas un remplacement d'idée"
    },
    {
      "left": "discours",
      "right": "texte dit, destiné à une oreille"
    },
    {
      "left": "destinataire",
      "right": "cour visée, pas une foule abstraite"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ le niveau, non la personne. (convaincre, subj.)",
  "answer": "convainque"
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
    "convainque",
    "le",
    "niveau",
    "non",
    "la",
    "personne",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "discours",
  "hint": "texte dit, destiné à une oreille"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aline Uwase écoute encore, et il fautons convaincre avant de crier.",
  "correct_sentence": "Aline Uwase écoute encore, et il faut convaincre avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m2/essai-dire.svg",
      "word": "essai dire"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/micro-langue.svg",
      "word": "micro langue"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/cahier-emprunts.svg",
      "word": "cahier emprunts"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/banc-verbes.svg",
      "word": "banc verbes"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur art oratoire ; rapport à l'oral ; souffle et hypotaxe, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'essai d'Aline sur l'oral et le discours de Léa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Aline Uwase',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Parler de notre rapport à l'oral et préparer un discours d'éloquence de cour. Point : art oratoire ; rapport à l'oral ; souffle et hypotaxe.

Consigne
Imitez le texte de Aline Uwase.

Support — Aline Uwase — Un plan, puis le souffle
Aline Uwase — Un plan, puis le souffle
On parle trop vite de le concours d'éloquence sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'argument par le souffle trop sûr, une éloquence qui n'écoute plus n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire.
Ce que l'on nomme éloquence, ici, n'est pas un slogan : art de dire, avec un plan.
Aline : il convient que l'on convainque, encore que l'on respire.
Lila tend le micro sans le pousser.
Patrick refuse le ventre comme méthode.
Rose écoute les mains de l'orateur.
La proposition qui reste debout est celle-ci : un discours de quatre minutes : thèse, concession, implicite, geste
Marc : un concours d'éloquence au Seuil se juge à ce qu'il n'a pas écrasé.
Nous clôturons sans fusionner les voix : l'essai d'Aline sur l'oral d'un côté, le discours de Léa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on convainque, une éloquence qui n'écoute plus n'est pas un détail.
Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
l'art oratoire au Seuil, c'est un plan, un souffle, un silence, un destinataire
Aline Uwase, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un discours de quatre minutes : thèse, concession, implicite, geste",
  "correct": true,
  "explanation": "un discours de quatre minutes : thèse, concession, implicite, geste"
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
      "text": "un discours de quatre minutes : thèse, concession, implicite, geste",
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
  "explanation": "un discours de quatre minutes : thèse, concession, implicite, geste"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "éloquence",
      "right": "art de dire, avec un plan"
    },
    {
      "left": "souffle",
      "right": "rythme oral, pas un remplacement d'idée"
    },
    {
      "left": "discours",
      "right": "texte dit, destiné à une oreille"
    },
    {
      "left": "destinataire",
      "right": "cour visée, pas une foule abstraite"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUn ___ n'est pas une trahison : c'est un choix de relation. (registre)",
  "answer": "registre"
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
    "registre",
    "n'est",
    "pas",
    "une",
    "trahison",
    "c'est",
    "un",
    "choix",
    "."
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
  "hint": "cour visée, pas une foule abstraite"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Aline Uwase est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Aline Uwase sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c2-m2/micro-langue.svg",
      "word": "micro langue"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/cahier-emprunts.svg",
      "word": "cahier emprunts"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/banc-verbes.svg",
      "word": "banc verbes"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/oreille-accent.svg",
      "word": "oreille accent"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Aline Uwase : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — art oratoire ; rapport à l''oral ; souffle et hypotaxe',
    'EL',
    $c$Objectif
Maîtriser art oratoire ; rapport à l'oral ; souffle et hypotaxe au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — art oratoire ; rapport à l'oral ; souffle et hypotaxe
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on convainque, une éloquence qui n'écoute plus n'est pas un détail.
Aline Uwase concède que le souffle porte, pour autant que l'on n'y voie pas le droit de n'avoir rien à dire.
Autrement dit, l'art oratoire au Seuil, c'est un plan, un souffle, un silence, un destinataire
Il ressort qu'un discours de quatre minutes : thèse, concession, implicite, geste
Piège : familier non signalé dans un discours d'assemblée
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme éloquence, ici, n'est pas un slogan : art de dire, avec un plan.
Léa pose la concession avant le geste.
Lila tend le micro sans le pousser.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au discours pour de vrai genre, et Lila Sow demande un registre plus net.
Correction : On va au discours vraiment, et Lila Sow demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le vouvoiement du micro peut coexister avec le tutoiement du banc.",
  "correct": true,
  "explanation": "Registres situés."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Changer de registre, c'est surtout…",
  "options": [
    {
      "text": "parler « faux »",
      "correct": false
    },
    {
      "text": "ajuster la relation et l'oreille",
      "correct": true
    },
    {
      "text": "oublier la grammaire",
      "correct": false
    },
    {
      "text": "interdire le figuier",
      "correct": false
    }
  ],
  "explanation": "Variation de registre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "éloquence",
      "right": "art de dire, avec un plan"
    },
    {
      "left": "souffle",
      "right": "rythme oral, pas un remplacement d'idée"
    },
    {
      "left": "discours",
      "right": "texte dit, destiné à une oreille"
    },
    {
      "left": "destinataire",
      "right": "cour visée, pas une foule abstraite"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLoin de ___, adapter le discours c'est respecter l'oreille. (tricher)",
  "answer": "tricher"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Adapter",
    "le",
    "discours",
    "c'est",
    "respecter",
    "l'oreille",
    "."
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
  "sentence_with_error": "On va au discours pour de vrai genre, et Lila Sow demande un registre plus net.",
  "correct_sentence": "On va au discours vraiment, et Lila Sow demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m2/cahier-emprunts.svg",
      "word": "cahier emprunts"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/banc-verbes.svg",
      "word": "banc verbes"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/oreille-accent.svg",
      "word": "oreille accent"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/soleil-parler.svg",
      "word": "soleil parler"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « art oratoire ; rapport à l'oral ; souffle et hypotaxe » et deux pièges commentés."
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

  -- ===== Lettre ouverte aux voix =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Lettre ouverte aux voix'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Lettre ouverte aux voix', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Lettre ouverte aux voix',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Écrire une lettre ouverte qui dénonce un étroit linguistique de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Lettre ouverte aux voix
Lila Sow : Radio Figuier. On parle trop vite de la lettre sur le micro trop étroit, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on reporte l'ouverture des voix, un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage.
Aline Uwase : Ce que l'on nomme ouverture, ici, n'est pas un slogan : accès daté au micro.
Patrick Habimana : Hawa : nous demandons que le jeudi s'ouvre, encore que l'on traduise.
Hawa Diallo : Lila entend, rature ce n'est pas le moment.
Joël Mugisha : Aline corrige le subjonctif, garde la colère.
Rose Iradukunda : Karim signe.
Solange Mukamana : Solange aussi.
Karim Bamba : Patrick veut des exemples, les obtient.
Félicie Ndayishimiye : Un chiffre, une trace : Hawa a cité deux émissions trop étroites ; proposé un jeudi mixte ; obtenu neuf signatures.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'ouvrir des oreilles, pas de fermer le français
Yvette : Sami lit trop vite la lettre ; on le reprend.
Mado : Lila Sow entend, dans « ce n'est pas le moment », ceci qui n'est pas dit : ce n'est pas le moment veut dire votre bouche peut attendre
Sami : Autrement dit, nous demandons que le micro s'ouvre : le subjonctif ici est une politique
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une lettre : constat, exemples, heures datées, signatures
Nina Kayitesi : Marc : dénoncer un étroit, c'est dater une heure, pas crier une essence.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les deux émissions d'un côté, la lettre d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Ce n'est pas le moment : phrase de salon, d'une étonnante longévité.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un plus tard qui n'arrive jamais pour certaines bouches est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Lila Sow, que reste-t-il implicite dans « ce n'est pas le moment » ?",
  "options": [
    {
      "text": "Que Hawa a fermé Radio Figuier",
      "correct": false
    },
    {
      "text": "Votre bouche peut attendre",
      "correct": true
    },
    {
      "text": "Que Lila a refusé toute mixité",
      "correct": false
    },
    {
      "text": "Que les neuf signatures sont un chœur unique",
      "correct": false
    }
  ],
  "explanation": "ce n'est pas le moment veut dire votre bouche peut attendre"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ouverture",
      "right": "accès daté au micro"
    },
    {
      "left": "traduction",
      "right": "geste de cour, pas une excuse éternelle"
    },
    {
      "left": "signature",
      "right": "nom posé sous une demande"
    },
    {
      "left": "émission",
      "right": "heure d'antenne, trop parfois étroite"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ avant d'accélérer. (demander, subj.)",
  "answer": "demande"
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
    "demande",
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
  "word": "ouverture",
  "hint": "accès daté au micro"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il convient que l'on demander trop tard, et Hawa Diallo refuse d'accélérer la pente.",
  "correct_sentence": "Il convient que l'on demande trop tard, et Hawa Diallo refuse d'accélérer la pente.",
  "explanation": "Il convient que + demande."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m2/banc-verbes.svg",
      "word": "banc verbes"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/oreille-accent.svg",
      "word": "oreille accent"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/soleil-parler.svg",
      "word": "soleil parler"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/nuage-norme.svg",
      "word": "nuage norme"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « ce n'est pas le moment » et la concession de Hawa Diallo."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les deux émissions et la lettre d'Hawa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Dater le jeudi mixte',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Écrire une lettre ouverte qui dénonce un étroit linguistique de cour. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Dater le jeudi mixte », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Dater le jeudi mixte
On parle trop vite de la lettre sur le micro trop étroit, comme si le mot dispensait d'en examiner le prix.
Encore que l'on reporte l'ouverture des voix, un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage.
Ce que l'on nomme ouverture, ici, n'est pas un slogan : accès daté au micro.
Hawa : nous demandons que le jeudi s'ouvre, encore que l'on traduise.
Lila entend, rature ce n'est pas le moment.
Aline corrige le subjonctif, garde la colère.
Karim signe.
Solange aussi.
Patrick veut des exemples, les obtient.
Un chiffre, une trace : Hawa a cité deux émissions trop étroites ; proposé un jeudi mixte ; obtenu neuf signatures.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'ouvrir des oreilles, pas de fermer le français
Sami lit trop vite la lettre ; on le reprend.
Lila Sow entend, dans « ce n'est pas le moment », ceci qui n'est pas dit : ce n'est pas le moment veut dire votre bouche peut attendre
Autrement dit, nous demandons que le micro s'ouvre : le subjonctif ici est une politique
La proposition qui reste debout est celle-ci : une lettre : constat, exemples, heures datées, signatures
Marc : dénoncer un étroit, c'est dater une heure, pas crier une essence.
Nous clôturons sans fusionner les voix : les deux émissions d'un côté, la lettre d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Signé : Hawa Diallo, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les deux émissions et la lettre d'Hawa en une seule affiche.",
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
      "text": "Deux émissions citées, un jeudi mixte, neuf signatures",
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
  "explanation": "Hawa a cité deux émissions trop étroites ; proposé un jeudi mixte ; obtenu neuf signatures."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ouverture",
      "right": "accès daté au micro"
    },
    {
      "left": "traduction",
      "right": "geste de cour, pas une excuse éternelle"
    },
    {
      "left": "signature",
      "right": "nom posé sous une demande"
    },
    {
      "left": "émission",
      "right": "heure d'antenne, trop parfois étroite"
    }
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
  "word": "traduction",
  "hint": "geste de cour, pas une excuse éternelle"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La ouverture de trop vite n'aide personne, et Lila Sow reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Lila Sow reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m2/oreille-accent.svg",
      "word": "oreille accent"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/soleil-parler.svg",
      "word": "soleil parler"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/nuage-norme.svg",
      "word": "nuage norme"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/radio-francais.svg",
      "word": "radio francais"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Dater le jeudi mixte » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Lettre ouverte aux voix : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : dénoncer sans insulter ; hypotaxe ; nous demandons que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on reporte l'ouverture des voix, un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage.
Ce que l'on nomme ouverture, ici, n'est pas un slogan : accès daté au micro.
Encore que l'on demande, un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail.
Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage.
Autrement dit, nous demandons que le micro s'ouvre : le subjonctif ici est une politique
Il ressort qu'une lettre : constat, exemples, heures datées, signatures
Lila entend, rature ce n'est pas le moment.
Solange aussi.
La proposition qui reste debout est celle-ci : une lettre : constat, exemples, heures datées, signatures
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les deux émissions d'un côté, la lettre d'Hawa de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage."
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
      "text": "traduire prend du temps — à condition que l'on date des heures mixtes, pas un nuage",
      "correct": true
    },
    {
      "text": "Hawa Diallo abandonne il s'agit d'ouvrir des oreilles, pas de fermer le français",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on date des heures mixtes, pas un nuage"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ouverture",
      "right": "accès daté au micro"
    },
    {
      "left": "traduction",
      "right": "geste de cour, pas une excuse éternelle"
    },
    {
      "left": "signature",
      "right": "nom posé sous une demande"
    },
    {
      "left": "émission",
      "right": "heure d'antenne, trop parfois étroite"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous recommandons que la cour ___ un relais. (demander, subj.)",
  "answer": "demande"
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
    "demande",
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
  "word": "signature",
  "hint": "nom posé sous une demande"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Hawa Diallo écoute encore, et il fautons demander avant de crier.",
  "correct_sentence": "Hawa Diallo écoute encore, et il faut demander avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m2/soleil-parler.svg",
      "word": "soleil parler"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/nuage-norme.svg",
      "word": "nuage norme"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/radio-francais.svg",
      "word": "radio francais"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/feuille-ouverte.svg",
      "word": "feuille ouverte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur dénoncer sans insulter ; hypotaxe ; nous demandons que, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les deux émissions et la lettre d'Hawa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Hawa Diallo',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Écrire une lettre ouverte qui dénonce un étroit linguistique de cour. Point : dénoncer sans insulter ; hypotaxe ; nous demandons que.

Consigne
Imitez le texte de Hawa Diallo.

Support — Hawa Diallo — Dater le jeudi mixte
Hawa Diallo — Dater le jeudi mixte
On parle trop vite de la lettre sur le micro trop étroit, comme si le mot dispensait d'en examiner le prix.
Encore que l'on reporte l'ouverture des voix, un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage.
Ce que l'on nomme ouverture, ici, n'est pas un slogan : accès daté au micro.
Hawa : nous demandons que le jeudi s'ouvre, encore que l'on traduise.
Solange aussi.
Patrick veut des exemples, les obtient.
Sami lit trop vite la lettre ; on le reprend.
La proposition qui reste debout est celle-ci : une lettre : constat, exemples, heures datées, signatures
Marc : dénoncer un étroit, c'est dater une heure, pas crier une essence.
Nous clôturons sans fusionner les voix : les deux émissions d'un côté, la lettre d'Hawa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on demande, un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail.
Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
nous demandons que le micro s'ouvre : le subjonctif ici est une politique
Hawa Diallo, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : une lettre : constat, exemples, heures datées, signatures",
  "correct": true,
  "explanation": "une lettre : constat, exemples, heures datées, signatures"
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
      "text": "une lettre : constat, exemples, heures datées, signatures",
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
  "explanation": "une lettre : constat, exemples, heures datées, signatures"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ouverture",
      "right": "accès daté au micro"
    },
    {
      "left": "traduction",
      "right": "geste de cour, pas une excuse éternelle"
    },
    {
      "left": "signature",
      "right": "nom posé sous une demande"
    },
    {
      "left": "émission",
      "right": "heure d'antenne, trop parfois étroite"
    }
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
  "word": "émission",
  "hint": "heure d'antenne, trop parfois étroite"
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
      "image_path": "/elearning/mfk-c2-m2/nuage-norme.svg",
      "word": "nuage norme"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/radio-francais.svg",
      "word": "radio francais"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/feuille-ouverte.svg",
      "word": "feuille ouverte"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/groupe-orateurs.svg",
      "word": "groupe orateurs"
    }
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
    'EL — dénoncer sans insulter ; hypotaxe ; nous demandons que',
    'EL',
    $c$Objectif
Maîtriser dénoncer sans insulter ; hypotaxe ; nous demandons que au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — dénoncer sans insulter ; hypotaxe ; nous demandons que
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on demande, un plus tard qui n'arrive jamais pour certaines bouches n'est pas un détail.
Hawa Diallo concède que traduire prend du temps, pour autant que l'on date des heures mixtes, pas un nuage.
Autrement dit, nous demandons que le micro s'ouvre : le subjonctif ici est une politique
Il ressort qu'une lettre : constat, exemples, heures datées, signatures
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme ouverture, ici, n'est pas un slogan : accès daté au micro.
Lila entend, rature ce n'est pas le moment.
Solange aussi.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au signature pour de vrai genre, et Lila Sow demande un registre plus net.
Correction : On va au signature vraiment, et Lila Sow demande un registre plus net.
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
      "left": "ouverture",
      "right": "accès daté au micro"
    },
    {
      "left": "traduction",
      "right": "geste de cour, pas une excuse éternelle"
    },
    {
      "left": "signature",
      "right": "nom posé sous une demande"
    },
    {
      "left": "émission",
      "right": "heure d'antenne, trop parfois étroite"
    }
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
  "sentence_with_error": "On va au signature pour de vrai genre, et Lila Sow demande un registre plus net.",
  "correct_sentence": "On va au signature vraiment, et Lila Sow demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m2/radio-francais.svg",
      "word": "radio francais"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/feuille-ouverte.svg",
      "word": "feuille ouverte"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/groupe-orateurs.svg",
      "word": "groupe orateurs"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/balance-mots.svg",
      "word": "balance mots"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « dénoncer sans insulter ; hypotaxe ; nous demandons que » et deux pièges commentés."
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

  -- ===== Concours d'éloquence =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Concours d''éloquence'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Concours d''éloquence', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Concours d''éloquence',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Organiser et tenir un concours d'éloquence de cour, C2. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Concours d'éloquence
Lila Sow : Radio Figuier. On parle trop vite de le concours sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme la parole en trophée, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Léa Niyonzima concède que un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Aline Uwase : Ce que l'on nomme concours, ici, n'est pas un slogan : exercice oratoire, pas un trône.
Patrick Habimana : Léa : loin de gagner, j'ai concédé, et l'oreille a mieux tenu.
Hawa Diallo : Yvette parle bas, emporte le prix de la concession.
Joël Mugisha : Sami trop brillant, trop peu selon.
Rose Iradukunda : Aline refuse le roi.
Solange Mukamana : Lila n'annonce pas un vainqueur, elle annonce trois écoutes.
Karim Bamba : Patrick sourit.
Félicie Ndayishimiye : Un chiffre, une trace : Trois discours ; un prix de la concession à Yvette ; zéro roi.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'entraîner une cour, pas de couronner une bouche
Yvette : Rose écoute les mains.
Mado : Yvette entend, dans « le meilleur gagne », ceci qui n'est pas dit : le meilleur gagne oublie trop vite qui n'a pas eu le micro assez tôt
Sami : Autrement dit, loin de désigner un roi, le concours entraîne l'oreille à la concession
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : trois discours, un prix de la concession, zéro trophée trop lourd
Nina Kayitesi : Marc : un concours C2 se juge à ce qu'il a su ne pas écraser.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les trois discours d'un côté, le palmarès d'Aline de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Le meilleur gagne : on appréciera la modestie du critère.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un vainqueur trop sûr d'avoir eu raison tout seul est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Yvette, que reste-t-il implicite dans « le meilleur gagne » ?",
  "options": [
    {
      "text": "Que Léa s'est couronnée",
      "correct": false
    },
    {
      "text": "Qui n'a pas eu le micro assez tôt",
      "correct": true
    },
    {
      "text": "Que Yvette a été humiliée",
      "correct": false
    },
    {
      "text": "Que Aline a interdit les concessions",
      "correct": false
    }
  ],
  "explanation": "le meilleur gagne oublie trop vite qui n'a pas eu le micro assez tôt"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "concours",
      "right": "exercice oratoire, pas un trône"
    },
    {
      "left": "concession",
      "right": "mouvement valorisé, plus qu'un trophée"
    },
    {
      "left": "palmarès",
      "right": "liste légère, sans humiliation"
    },
    {
      "left": "oreille",
      "right": "juge véritable du concours"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl ne s'agirait ___ d'un détail, à entendre certains. (ne … que)",
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
    "Il",
    "ne",
    "s'agirait",
    "que",
    "d'un",
    "détail",
    "à",
    "entendre",
    "certains",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "concours",
  "hint": "exercice oratoire, pas un trône"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tant est que le bonheur s'industrialise, il se vend déjà, et Léa Niyonzima sourit trop large.",
  "correct_sentence": "Si tant est que le bonheur s'industrialise, il se vendrait déjà, et Léa Niyonzima sourit trop large.",
  "explanation": "Si tant est que + hypothese : se vendrait (irréel / doute)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m2/feuille-ouverte.svg",
      "word": "feuille ouverte"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/groupe-orateurs.svg",
      "word": "groupe orateurs"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/balance-mots.svg",
      "word": "balance mots"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/porte-voix.svg",
      "word": "porte voix"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « le meilleur gagne » et la concession de Léa Niyonzima."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les trois discours et le palmarès d'Aline distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le prix de la concession',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Organiser et tenir un concours d'éloquence de cour, C2. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le prix de la concession », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le prix de la concession
On parle trop vite de le concours sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme la parole en trophée, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Ce que l'on nomme concours, ici, n'est pas un slogan : exercice oratoire, pas un trône.
Léa : loin de gagner, j'ai concédé, et l'oreille a mieux tenu.
Yvette parle bas, emporte le prix de la concession.
Sami trop brillant, trop peu selon.
Aline refuse le roi.
Lila n'annonce pas un vainqueur, elle annonce trois écoutes.
Patrick sourit.
Un chiffre, une trace : Trois discours ; un prix de la concession à Yvette ; zéro roi.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'entraîner une cour, pas de couronner une bouche
Rose écoute les mains.
Yvette entend, dans « le meilleur gagne », ceci qui n'est pas dit : le meilleur gagne oublie trop vite qui n'a pas eu le micro assez tôt
Autrement dit, loin de désigner un roi, le concours entraîne l'oreille à la concession
La proposition qui reste debout est celle-ci : trois discours, un prix de la concession, zéro trophée trop lourd
Marc : un concours C2 se juge à ce qu'il a su ne pas écraser.
Nous clôturons sans fusionner les voix : les trois discours d'un côté, le palmarès d'Aline de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les trois discours et le palmarès d'Aline en une seule affiche.",
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
      "text": "Trois discours, un prix de concession, zéro roi",
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
  "explanation": "Trois discours ; un prix de la concession à Yvette ; zéro roi."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "concours",
      "right": "exercice oratoire, pas un trône"
    },
    {
      "left": "concession",
      "right": "mouvement valorisé, plus qu'un trophée"
    },
    {
      "left": "palmarès",
      "right": "liste légère, sans humiliation"
    },
    {
      "left": "oreille",
      "right": "juge véritable du concours"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLoin de ___ la cour, le sourire la fatigue. (rassurer)",
  "answer": "rassurer"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Loin",
    "de",
    "rassurer",
    "la",
    "cour",
    "le",
    "sourire",
    "la",
    "fatigue",
    "."
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
  "hint": "mouvement valorisé, plus qu'un trophée"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La concours de trop vite n'aide personne, et Yvette reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Yvette reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m2/groupe-orateurs.svg",
      "word": "groupe orateurs"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/balance-mots.svg",
      "word": "balance mots"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/porte-voix.svg",
      "word": "porte voix"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/coeur-langue.svg",
      "word": "coeur langue"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le prix de la concession » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Concours d''éloquence : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : prononcer un discours ; concession oratoire ; implicite assumé.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme la parole en trophée, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Ce que l'on nomme concours, ici, n'est pas un slogan : exercice oratoire, pas un trône.
Encore que l'on entraîne, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail.
Léa Niyonzima concède que un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Autrement dit, loin de désigner un roi, le concours entraîne l'oreille à la concession
Il ressort que trois discours, un prix de la concession, zéro trophée trop lourd
Yvette parle bas, emporte le prix de la concession.
Lila n'annonce pas un vainqueur, elle annonce trois écoutes.
La proposition qui reste debout est celle-ci : trois discours, un prix de la concession, zéro trophée trop lourd
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les trois discours d'un côté, le palmarès d'Aline de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Léa Niyonzima concède que un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation."
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
      "text": "un classement peut s'amuser — à condition que l'on n'en fasse pas une humiliation",
      "correct": true
    },
    {
      "text": "Léa Niyonzima abandonne il s'agit d'entraîner une cour, pas de couronner une bouche",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'en fasse pas une humiliation"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "concours",
      "right": "exercice oratoire, pas un trône"
    },
    {
      "left": "concession",
      "right": "mouvement valorisé, plus qu'un trophée"
    },
    {
      "left": "palmarès",
      "right": "liste légère, sans humiliation"
    },
    {
      "left": "oreille",
      "right": "juge véritable du concours"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nFût-ce à voix basse, Mado ___ le contraire de ce qu'on affiche. (dire)",
  "answer": "dit"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Fût-ce",
    "à",
    "voix",
    "basse",
    "Mado",
    "dit",
    "le",
    "contraire",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "palmarès",
  "hint": "liste légère, sans humiliation"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Léa Niyonzima écoute encore, et il fautons entraîner avant de crier.",
  "correct_sentence": "Léa Niyonzima écoute encore, et il faut entraîner avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m2/balance-mots.svg",
      "word": "balance mots"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/porte-voix.svg",
      "word": "porte voix"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/coeur-langue.svg",
      "word": "coeur langue"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/emprunt-langue.svg",
      "word": "emprunt langue"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur prononcer un discours ; concession oratoire ; implicite assumé, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les trois discours et le palmarès d'Aline distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Léa Niyonzima',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Organiser et tenir un concours d'éloquence de cour, C2. Point : prononcer un discours ; concession oratoire ; implicite assumé.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Le prix de la concession
Léa Niyonzima — Le prix de la concession
On parle trop vite de le concours sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme la parole en trophée, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Ce que l'on nomme concours, ici, n'est pas un slogan : exercice oratoire, pas un trône.
Léa : loin de gagner, j'ai concédé, et l'oreille a mieux tenu.
Lila n'annonce pas un vainqueur, elle annonce trois écoutes.
Patrick sourit.
Rose écoute les mains.
La proposition qui reste debout est celle-ci : trois discours, un prix de la concession, zéro trophée trop lourd
Marc : un concours C2 se juge à ce qu'il a su ne pas écraser.
Nous clôturons sans fusionner les voix : les trois discours d'un côté, le palmarès d'Aline de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on entraîne, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail.
Léa Niyonzima concède que un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
loin de désigner un roi, le concours entraîne l'oreille à la concession
Léa Niyonzima, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : trois discours, un prix de la concession, zéro trophée trop lourd",
  "correct": true,
  "explanation": "trois discours, un prix de la concession, zéro trophée trop lourd"
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
      "text": "trois discours, un prix de la concession, zéro trophée trop lourd",
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
  "explanation": "trois discours, un prix de la concession, zéro trophée trop lourd"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "concours",
      "right": "exercice oratoire, pas un trône"
    },
    {
      "left": "concession",
      "right": "mouvement valorisé, plus qu'un trophée"
    },
    {
      "left": "palmarès",
      "right": "liste légère, sans humiliation"
    },
    {
      "left": "oreille",
      "right": "juge véritable du concours"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi tant est que le bonheur s'___, il se vendrait déjà sous le figuier. (industrialiser)",
  "answer": "industrialise"
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
    "tant",
    "est",
    "que",
    "le",
    "bonheur",
    "s'industrialise",
    "il",
    "se",
    "vendrait",
    "déjà",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "oreille",
  "hint": "juge véritable du concours"
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
      "image_path": "/elearning/mfk-c2-m2/porte-voix.svg",
      "word": "porte voix"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/coeur-langue.svg",
      "word": "coeur langue"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/emprunt-langue.svg",
      "word": "emprunt langue"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/reine-refusee.svg",
      "word": "reine refusee"
    }
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
    'EL — prononcer un discours ; concession oratoire ; implicite assumé',
    'EL',
    $c$Objectif
Maîtriser prononcer un discours ; concession oratoire ; implicite assumé au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — prononcer un discours ; concession oratoire ; implicite assumé
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on entraîne, un vainqueur trop sûr d'avoir eu raison tout seul n'est pas un détail.
Léa Niyonzima concède que un classement peut s'amuser, pour autant que l'on n'en fasse pas une humiliation.
Autrement dit, loin de désigner un roi, le concours entraîne l'oreille à la concession
Il ressort que trois discours, un prix de la concession, zéro trophée trop lourd
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme concours, ici, n'est pas un slogan : exercice oratoire, pas un trône.
Yvette parle bas, emporte le prix de la concession.
Lila n'annonce pas un vainqueur, elle annonce trois écoutes.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au palmarès pour de vrai genre, et Yvette demande un registre plus net.
Correction : On va au palmarès vraiment, et Yvette demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "L'ironie peut dire le contraire de ce qu'elle affirme.",
  "correct": true,
  "explanation": "Antiphrase possible."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Il ne s'agirait que d'un détail » est souvent…",
  "options": [
    {
      "text": "une preuve que c'est un détail",
      "correct": false
    },
    {
      "text": "un sous-entendu, parfois ironique",
      "correct": true
    },
    {
      "text": "un passé simple",
      "correct": false
    },
    {
      "text": "un ordre",
      "correct": false
    }
  ],
  "explanation": "Understatement / ironie."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "concours",
      "right": "exercice oratoire, pas un trône"
    },
    {
      "left": "concession",
      "right": "mouvement valorisé, plus qu'un trophée"
    },
    {
      "left": "palmarès",
      "right": "liste légère, sans humiliation"
    },
    {
      "left": "oreille",
      "right": "juge véritable du concours"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nL'___ n'est pas un rire : c'est un écart entre le dit et le visé. (ironie)",
  "answer": "ironie"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "L'ironie",
    "n'est",
    "pas",
    "un",
    "rire",
    "c'est",
    "un",
    "écart",
    "."
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
  "sentence_with_error": "On va au palmarès pour de vrai genre, et Yvette demande un registre plus net.",
  "correct_sentence": "On va au palmarès vraiment, et Yvette demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m2/coeur-langue.svg",
      "word": "coeur langue"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/emprunt-langue.svg",
      "word": "emprunt langue"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/reine-refusee.svg",
      "word": "reine refusee"
    },
    {
      "image_path": "/elearning/mfk-c2-m2/article-representation.svg",
      "word": "article representation"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « prononcer un discours ; concession oratoire ; implicite assumé » et deux pièges commentés."
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
