/*
  Seed eLearning MFK — C1 — Corps visibles

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-c1-m4/
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
  v_module_title text := 'C1 — Corps visibles';
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
      'Grande étape C1-4 : commenter une tendance du regard sous le figuier, dénoncer ce que la cour rend invisible, lire le langage des gestes, interpréter une œuvre inventée de Rose, écrire un manifeste, enregistrer un audioguide — Léa Niyonzima refuse qu''un corps soit un décor, Sami pose le tambour, Joël Mugisha parle de la rampe trop tardive, et le Seuil apprend à voir sans exposer.',
      'C1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape C1-4 : commenter une tendance du regard sous le figuier, dénoncer ce que la cour rend invisible, lire le langage des gestes, interpréter une œuvre inventée de Rose, écrire un manifeste, enregistrer un audioguide — Léa Niyonzima refuse qu''un corps soit un décor, Sami pose le tambour, Joël Mugisha parle de la rampe trop tardive, et le Seuil apprend à voir sans exposer.',
      cefr_level = 'C1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Image de soi sous le figuier =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Image de soi sous le figuier'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Image de soi sous le figuier', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Image de soi sous le figuier',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Commenter une tendance du regard sans répéter les mots d'un fil. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Image de soi sous le figuier
Lila Sow : Radio Figuier. On parle trop vite de le regard que la cour porte sur les corps, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme le corps en vitrine du fil, un compliment qui mesure trop n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Léa Niyonzima concède que un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Aline Uwase : Ce que l'on nomme regard, ici, n'est pas un slogan : manière de voir, parfois une mesure.
Patrick Habimana : Léa : on dirait que le fil n'aime que les midis sans ombre.
Hawa Diallo : Rose coud un col trop large, exprès, pour que le corps respire.
Joël Mugisha : Sami pose un portrait et le retire : trop de commentaires.
Rose Iradukunda : Aline distingue le registre du banc et celui du fil.
Solange Mukamana : Hawa refuse le compliment qui pèse.
Karim Bamba : Joël ne se photographie pas portant les lanternes : ce n'est pas un spectacle.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a vu six portraits trop semblables au fil inventé de la cour, un seul où l'ombre n'était pas gommée.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de se voir sans se mettre en vitrine
Yvette : Lila n'ouvrira pas une émission de notes.
Mado : Rose Iradukunda entend, dans « sois toi-même », ceci qui n'est pas dit : sois toi-même arrive souvent après une liste de ce que toi-même devrait être
Sami : Autrement dit, commenter une tendance, c'est nommer qui gagne à ce que l'on se compare
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un billet pour le Cahier du chemin : tendance, implicite, geste de ne pas mesurer
Nina Kayitesi : Marc : commenter, ce n'est pas noter.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les portraits trop nets du fil de la cour d'un côté, le billet de Léa de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un compliment qui mesure trop est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un compliment qui mesure trop n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Rose Iradukunda, que reste-t-il implicite dans « sois toi-même » ?",
  "options": [
    {
      "text": "Que Léa interdit les portraits",
      "correct": false
    },
    {
      "text": "Une liste déguisée en liberté",
      "correct": true
    },
    {
      "text": "Que Rose ne coud plus",
      "correct": false
    },
    {
      "text": "Que le figuier mesure les visages",
      "correct": false
    }
  ],
  "explanation": "sois toi-même arrive souvent après une liste de ce que toi-même devrait être"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "regard",
      "right": "manière de voir, parfois une mesure"
    },
    {
      "left": "portrait",
      "right": "image, trop souvent une note"
    },
    {
      "left": "tendance",
      "right": "mode du regard, à commenter"
    },
    {
      "left": "vitrine",
      "right": "exposition, distincte d'une présence"
    }
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
  "word": "regard",
  "hint": "manière de voir, parfois une mesure"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Au registre soutenu, on dira ça ouais, et Léa Niyonzima lit encore la motion.",
  "correct_sentence": "Au registre soutenu, on dira cela, et Léa Niyonzima lit encore la motion.",
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
      "image_path": "/elearning/mfk-c1-m4/image-de-soi.svg",
      "word": "image de soi"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/miroir-cour.svg",
      "word": "miroir cour"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/fil-portrait.svg",
      "word": "fil portrait"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/regard-croise.svg",
      "word": "regard croise"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « sois toi-même » et la concession de Léa Niyonzima."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les portraits trop nets du fil de la cour et le billet de Léa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Toi-même, après la liste',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Commenter une tendance du regard sans répéter les mots d'un fil. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Toi-même, après la liste », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Toi-même, après la liste
On parle trop vite de le regard que la cour porte sur les corps, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le corps en vitrine du fil, un compliment qui mesure trop n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Ce que l'on nomme regard, ici, n'est pas un slogan : manière de voir, parfois une mesure.
Léa : on dirait que le fil n'aime que les midis sans ombre.
Rose coud un col trop large, exprès, pour que le corps respire.
Sami pose un portrait et le retire : trop de commentaires.
Aline distingue le registre du banc et celui du fil.
Hawa refuse le compliment qui pèse.
Joël ne se photographie pas portant les lanternes : ce n'est pas un spectacle.
Un chiffre, une trace : Léa a vu six portraits trop semblables au fil inventé de la cour, un seul où l'ombre n'était pas gommée.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de se voir sans se mettre en vitrine
Lila n'ouvrira pas une émission de notes.
Rose Iradukunda entend, dans « sois toi-même », ceci qui n'est pas dit : sois toi-même arrive souvent après une liste de ce que toi-même devrait être
Autrement dit, commenter une tendance, c'est nommer qui gagne à ce que l'on se compare
La proposition qui reste debout est celle-ci : un billet pour le Cahier du chemin : tendance, implicite, geste de ne pas mesurer
Marc : commenter, ce n'est pas noter.
Nous clôturons sans fusionner les voix : les portraits trop nets du fil de la cour d'un côté, le billet de Léa de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les portraits trop nets du fil de la cour et le billet de Léa en une seule affiche.",
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
      "text": "Six portraits trop semblables, une ombre gardée",
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
  "explanation": "Léa a vu six portraits trop semblables au fil inventé de la cour, un seul où l'ombre n'était pas gommée."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "regard",
      "right": "manière de voir, parfois une mesure"
    },
    {
      "left": "portrait",
      "right": "image, trop souvent une note"
    },
    {
      "left": "tendance",
      "right": "mode du regard, à commenter"
    },
    {
      "left": "vitrine",
      "right": "exposition, distincte d'une présence"
    }
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
  "word": "portrait",
  "hint": "image, trop souvent une note"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La regard de trop vite n'aide personne, et Rose Iradukunda reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m4/miroir-cour.svg",
      "word": "miroir cour"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/fil-portrait.svg",
      "word": "fil portrait"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/regard-croise.svg",
      "word": "regard croise"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/visible-invisible.svg",
      "word": "visible invisible"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Toi-même, après la liste » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Image de soi sous le figuier : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : commenter une tendance ; on dirait que ; registre du regard.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme le corps en vitrine du fil, un compliment qui mesure trop n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Ce que l'on nomme regard, ici, n'est pas un slogan : manière de voir, parfois une mesure.
Encore que l'on commente, un compliment qui mesure trop n'est pas un détail.
Léa Niyonzima concède que un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Autrement dit, commenter une tendance, c'est nommer qui gagne à ce que l'on se compare
Il ressort qu'un billet pour le Cahier du chemin : tendance, implicite, geste de ne pas mesurer
Rose coud un col trop large, exprès, pour que le corps respire.
Hawa refuse le compliment qui pèse.
La proposition qui reste debout est celle-ci : un billet pour le Cahier du chemin : tendance, implicite, geste de ne pas mesurer
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les portraits trop nets du fil de la cour d'un côté, le billet de Léa de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Léa Niyonzima concède que un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité."
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
      "text": "un portrait peut réjouir — à condition que l'on n'y lise pas une note de conformité",
      "correct": true
    },
    {
      "text": "Léa Niyonzima abandonne il s'agit de se voir sans se mettre en vitrine",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y lise pas une note de conformité"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "regard",
      "right": "manière de voir, parfois une mesure"
    },
    {
      "left": "portrait",
      "right": "image, trop souvent une note"
    },
    {
      "left": "tendance",
      "right": "mode du regard, à commenter"
    },
    {
      "left": "vitrine",
      "right": "exposition, distincte d'une présence"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ le niveau, non la personne. (commenter, subj.)",
  "answer": "commente"
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
    "commente",
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
  "word": "tendance",
  "hint": "mode du regard, à commenter"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Léa Niyonzima écoute encore, et il fautons commenter avant de crier.",
  "correct_sentence": "Léa Niyonzima écoute encore, et il faut commenter avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m4/fil-portrait.svg",
      "word": "fil portrait"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/regard-croise.svg",
      "word": "regard croise"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/visible-invisible.svg",
      "word": "visible invisible"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/rampe-herbes.svg",
      "word": "rampe herbes"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur commenter une tendance ; on dirait que ; registre du regard, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les portraits trop nets du fil de la cour et le billet de Léa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Léa Niyonzima',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Commenter une tendance du regard sans répéter les mots d'un fil. Point : commenter une tendance ; on dirait que ; registre du regard.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Toi-même, après la liste
Léa Niyonzima — Toi-même, après la liste
On parle trop vite de le regard que la cour porte sur les corps, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le corps en vitrine du fil, un compliment qui mesure trop n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Ce que l'on nomme regard, ici, n'est pas un slogan : manière de voir, parfois une mesure.
Léa : on dirait que le fil n'aime que les midis sans ombre.
Hawa refuse le compliment qui pèse.
Joël ne se photographie pas portant les lanternes : ce n'est pas un spectacle.
Lila n'ouvrira pas une émission de notes.
La proposition qui reste debout est celle-ci : un billet pour le Cahier du chemin : tendance, implicite, geste de ne pas mesurer
Marc : commenter, ce n'est pas noter.
Nous clôturons sans fusionner les voix : les portraits trop nets du fil de la cour d'un côté, le billet de Léa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on commente, un compliment qui mesure trop n'est pas un détail.
Léa Niyonzima concède que un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
commenter une tendance, c'est nommer qui gagne à ce que l'on se compare
Léa Niyonzima, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un billet pour le Cahier du chemin : tendance, implicite, geste de ne pas mesurer",
  "correct": true,
  "explanation": "un billet pour le Cahier du chemin : tendance, implicite, geste de ne pas mesurer"
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
      "text": "un billet pour le Cahier du chemin : tendance, implicite, geste de ne pas mesurer",
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
  "explanation": "un billet pour le Cahier du chemin : tendance, implicite, geste de ne pas mesurer"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "regard",
      "right": "manière de voir, parfois une mesure"
    },
    {
      "left": "portrait",
      "right": "image, trop souvent une note"
    },
    {
      "left": "tendance",
      "right": "mode du regard, à commenter"
    },
    {
      "left": "vitrine",
      "right": "exposition, distincte d'une présence"
    }
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
  "word": "vitrine",
  "hint": "exposition, distincte d'une présence"
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
      "image_path": "/elearning/mfk-c1-m4/regard-croise.svg",
      "word": "regard croise"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/visible-invisible.svg",
      "word": "visible invisible"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/rampe-herbes.svg",
      "word": "rampe herbes"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/manifeste-seuil.svg",
      "word": "manifeste seuil"
    }
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
    'EL — commenter une tendance ; on dirait que ; registre du regard',
    'EL',
    $c$Objectif
Maîtriser commenter une tendance ; on dirait que ; registre du regard au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — commenter une tendance ; on dirait que ; registre du regard
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on commente, un compliment qui mesure trop n'est pas un détail.
Léa Niyonzima concède que un portrait peut réjouir, pour autant que l'on n'y lise pas une note de conformité.
Autrement dit, commenter une tendance, c'est nommer qui gagne à ce que l'on se compare
Il ressort qu'un billet pour le Cahier du chemin : tendance, implicite, geste de ne pas mesurer
Piège : familier non signalé dans un discours d'assemblée
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme regard, ici, n'est pas un slogan : manière de voir, parfois une mesure.
Rose coud un col trop large, exprès, pour que le corps respire.
Hawa refuse le compliment qui pèse.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au tendance pour de vrai genre, et Rose Iradukunda demande un registre plus net.
Correction : On va au tendance vraiment, et Rose Iradukunda demande un registre plus net.
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
      "left": "regard",
      "right": "manière de voir, parfois une mesure"
    },
    {
      "left": "portrait",
      "right": "image, trop souvent une note"
    },
    {
      "left": "tendance",
      "right": "mode du regard, à commenter"
    },
    {
      "left": "vitrine",
      "right": "exposition, distincte d'une présence"
    }
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
  "sentence_with_error": "On va au tendance pour de vrai genre, et Rose Iradukunda demande un registre plus net.",
  "correct_sentence": "On va au tendance vraiment, et Rose Iradukunda demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m4/visible-invisible.svg",
      "word": "visible invisible"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/rampe-herbes.svg",
      "word": "rampe herbes"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/manifeste-seuil.svg",
      "word": "manifeste seuil"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/chaise-acces.svg",
      "word": "chaise acces"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « commenter une tendance ; on dirait que ; registre du regard » et deux pièges commentés."
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

  -- ===== La planche n'est pas une rampe =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'La planche n''est pas une rampe'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'La planche n''est pas une rampe', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La planche n''est pas une rampe',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Dénoncer ce que la cour rend invisible, notamment l'accès. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — La planche n'est pas une rampe
Lila Sow : Radio Figuier. On parle trop vite de ce que la cour ne voit pas, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on mette la rampe à plus tard, une assemblée sans place pour Joël le jour de la pluie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice.
Aline Uwase : Ce que l'on nomme inégalité, ici, n'est pas un slogan : écart d'accès rendu normal par l'habitude.
Patrick Habimana : Joël : il n'est que trop évident que la pluie choisit qui parle.
Hawa Diallo : Solange a honte de la planche, et la honte n'est pas une rampe.
Joël Mugisha : Léa écrit le manifeste au nom de ceux qui n'ont pas pu monter.
Rose Iradukunda : Dieudonné peut souder, il demande une date.
Solange Mukamana : Karim chiffre le fer, refuse le mot bientôt.
Karim Bamba : Aline : la relative dont on se passe trop souvent, c'est ceux pour qui la cour se ferme.
Félicie Ndayishimiye : Un chiffre, une trace : Joël a manqué trois assemblées de pluie ; la planche a glissé huit fois ; zéro date de rampe.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la cour soit une cour, pas un club de ceux qui montent vite
Yvette : Lila lira le manifeste sans musique héroïque.
Mado : Solange Mukamana entend, dans « on s'adapte », ceci qui n'est pas dit : on s'adapte veut dire c'est à toi de disparaître quand il pleut
Sami : Autrement dit, dénoncer, ce n'est pas insulter : c'est rendre visible une inégalité que l'habitude a rendue normale
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un manifeste : rampe, heures, bancs, signatures du Bureau des Escales
Nina Kayitesi : Marc : dénoncer une inégalité, c'est rendre le banc habitable.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le manifeste de Joël et de Léa d'un côté, les minutes trop vagues de l'assemblée de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une assemblée sans place pour Joël le jour de la pluie est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une assemblée sans place pour Joël le jour de la pluie n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Solange Mukamana, que reste-t-il implicite dans « on s'adapte » ?",
  "options": [
    {
      "text": "Que Joël refuse toute assemblée",
      "correct": false
    },
    {
      "text": "Disparaître quand il pleut",
      "correct": true
    },
    {
      "text": "Que Solange a volé la planche",
      "correct": false
    },
    {
      "text": "Que la pluie est une excuse de Marc",
      "correct": false
    }
  ],
  "explanation": "on s'adapte veut dire c'est à toi de disparaître quand il pleut"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "inégalité",
      "right": "écart d'accès rendu normal par l'habitude"
    },
    {
      "left": "rampe",
      "right": "accès réel, distinct d'une planche"
    },
    {
      "left": "manifeste",
      "right": "texte qui dénonce et exige"
    },
    {
      "left": "accès",
      "right": "possibilité d'entrer, pas une faveur"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nDu fait que le prix ___, la colère n'est pas un caprice. (flamber)",
  "answer": "flambe"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Du",
    "fait",
    "que",
    "le",
    "prix",
    "flambe",
    "la",
    "colère",
    "n'est",
    "pas",
    "un",
    "caprice",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "inégalité",
  "hint": "écart d'accès rendu normal par l'habitude"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Du fait que le prix flambent, Joël Mugisha refuse d'appeler cela un caprice, et Oscar écoute.",
  "correct_sentence": "Du fait que le prix flambe, Joël Mugisha refuse d'appeler cela un caprice, et Oscar écoute.",
  "explanation": "Le prix flambe, singulier."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m4/rampe-herbes.svg",
      "word": "rampe herbes"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/manifeste-seuil.svg",
      "word": "manifeste seuil"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/chaise-acces.svg",
      "word": "chaise acces"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/langage-corps.svg",
      "word": "langage corps"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « on s'adapte » et la concession de Joël Mugisha."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le manifeste de Joël et de Léa et les minutes trop vagues de l'assemblée distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — La planche n''est pas une rampe',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Dénoncer ce que la cour rend invisible, notamment l'accès. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « La planche n'est pas une rampe », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La planche n'est pas une rampe
On parle trop vite de ce que la cour ne voit pas, comme si le mot dispensait d'en examiner le prix.
Encore que l'on mette la rampe à plus tard, une assemblée sans place pour Joël le jour de la pluie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice.
Ce que l'on nomme inégalité, ici, n'est pas un slogan : écart d'accès rendu normal par l'habitude.
Joël : il n'est que trop évident que la pluie choisit qui parle.
Solange a honte de la planche, et la honte n'est pas une rampe.
Léa écrit le manifeste au nom de ceux qui n'ont pas pu monter.
Dieudonné peut souder, il demande une date.
Karim chiffre le fer, refuse le mot bientôt.
Aline : la relative dont on se passe trop souvent, c'est ceux pour qui la cour se ferme.
Un chiffre, une trace : Joël a manqué trois assemblées de pluie ; la planche a glissé huit fois ; zéro date de rampe.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la cour soit une cour, pas un club de ceux qui montent vite
Lila lira le manifeste sans musique héroïque.
Solange Mukamana entend, dans « on s'adapte », ceci qui n'est pas dit : on s'adapte veut dire c'est à toi de disparaître quand il pleut
Autrement dit, dénoncer, ce n'est pas insulter : c'est rendre visible une inégalité que l'habitude a rendue normale
La proposition qui reste debout est celle-ci : un manifeste : rampe, heures, bancs, signatures du Bureau des Escales
Marc : dénoncer une inégalité, c'est rendre le banc habitable.
Nous clôturons sans fusionner les voix : le manifeste de Joël et de Léa d'un côté, les minutes trop vagues de l'assemblée de l'autre, et le point où elles refusent de se ressembler.
Signé : Joël Mugisha, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le manifeste de Joël et de Léa et les minutes trop vagues de l'assemblée en une seule affiche.",
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
      "text": "Trois assemblées manquées, huit glissades, zéro date",
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
  "explanation": "Joël a manqué trois assemblées de pluie ; la planche a glissé huit fois ; zéro date de rampe."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "inégalité",
      "right": "écart d'accès rendu normal par l'habitude"
    },
    {
      "left": "rampe",
      "right": "accès réel, distinct d'une planche"
    },
    {
      "left": "manifeste",
      "right": "texte qui dénonce et exige"
    },
    {
      "left": "accès",
      "right": "possibilité d'entrer, pas une faveur"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSi bien que les jardiniers ___ la rive. (quitter, fut. ou prés.)",
  "answer": "quittent"
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
    "bien",
    "que",
    "les",
    "jardiniers",
    "quittent",
    "la",
    "rive",
    "."
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
  "hint": "accès réel, distinct d'une planche"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La inégalité de trop vite n'aide personne, et Solange Mukamana reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Solange Mukamana reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m4/manifeste-seuil.svg",
      "word": "manifeste seuil"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/chaise-acces.svg",
      "word": "chaise acces"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/langage-corps.svg",
      "word": "langage corps"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/geste-silence.svg",
      "word": "geste silence"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « La planche n'est pas une rampe » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — La planche n''est pas une rampe : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : dénoncer une inégalité ; relatives complexes ; il n'est que trop.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on mette la rampe à plus tard, une assemblée sans place pour Joël le jour de la pluie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice.
Ce que l'on nomme inégalité, ici, n'est pas un slogan : écart d'accès rendu normal par l'habitude.
Encore que l'on dénonce, une assemblée sans place pour Joël le jour de la pluie n'est pas un détail.
Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice.
Autrement dit, dénoncer, ce n'est pas insulter : c'est rendre visible une inégalité que l'habitude a rendue normale
Il ressort qu'un manifeste : rampe, heures, bancs, signatures du Bureau des Escales
Solange a honte de la planche, et la honte n'est pas une rampe.
Karim chiffre le fer, refuse le mot bientôt.
La proposition qui reste debout est celle-ci : un manifeste : rampe, heures, bancs, signatures du Bureau des Escales
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le manifeste de Joël et de Léa d'un côté, les minutes trop vagues de l'assemblée de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Joël Mugisha transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Joël Mugisha, et à quelle condition ?",
  "options": [
    {
      "text": "Joël Mugisha n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "la cour a déjà posé une planche — à condition que l'on n'appelle pas planche une rampe, ni patience une justice",
      "correct": true
    },
    {
      "text": "Joël Mugisha abandonne il s'agit que la cour soit une cour, pas un club de ceux qui montent vite",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'appelle pas planche une rampe, ni patience une justice"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "inégalité",
      "right": "écart d'accès rendu normal par l'habitude"
    },
    {
      "left": "rampe",
      "right": "accès réel, distinct d'une planche"
    },
    {
      "left": "manifeste",
      "right": "texte qui dénonce et exige"
    },
    {
      "left": "accès",
      "right": "possibilité d'entrer, pas une faveur"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que le marché ___ ouvert, la terre n'est pas payée. (être, subj.)",
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
    "marché",
    "soit",
    "ouvert",
    "la",
    "terre",
    "n'est",
    "pas",
    "payée",
    "."
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
  "hint": "texte qui dénonce et exige"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Joël Mugisha écoute encore, et il fautons dénoncer avant de crier.",
  "correct_sentence": "Joël Mugisha écoute encore, et il faut dénoncer avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m4/chaise-acces.svg",
      "word": "chaise acces"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/langage-corps.svg",
      "word": "langage corps"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/geste-silence.svg",
      "word": "geste silence"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/idiome-main.svg",
      "word": "idiome main"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur dénoncer une inégalité ; relatives complexes ; il n'est que trop, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le manifeste de Joël et de Léa et les minutes trop vagues de l'assemblée distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Joël Mugisha',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Dénoncer ce que la cour rend invisible, notamment l'accès. Point : dénoncer une inégalité ; relatives complexes ; il n'est que trop.

Consigne
Imitez le texte de Joël Mugisha.

Support — Joël Mugisha — La planche n'est pas une rampe
Joël Mugisha — La planche n'est pas une rampe
On parle trop vite de ce que la cour ne voit pas, comme si le mot dispensait d'en examiner le prix.
Encore que l'on mette la rampe à plus tard, une assemblée sans place pour Joël le jour de la pluie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice.
Ce que l'on nomme inégalité, ici, n'est pas un slogan : écart d'accès rendu normal par l'habitude.
Joël : il n'est que trop évident que la pluie choisit qui parle.
Karim chiffre le fer, refuse le mot bientôt.
Aline : la relative dont on se passe trop souvent, c'est ceux pour qui la cour se ferme.
Lila lira le manifeste sans musique héroïque.
La proposition qui reste debout est celle-ci : un manifeste : rampe, heures, bancs, signatures du Bureau des Escales
Marc : dénoncer une inégalité, c'est rendre le banc habitable.
Nous clôturons sans fusionner les voix : le manifeste de Joël et de Léa d'un côté, les minutes trop vagues de l'assemblée de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on dénonce, une assemblée sans place pour Joël le jour de la pluie n'est pas un détail.
Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
dénoncer, ce n'est pas insulter : c'est rendre visible une inégalité que l'habitude a rendue normale
Joël Mugisha, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un manifeste : rampe, heures, bancs, signatures du Bureau des Escales",
  "correct": true,
  "explanation": "un manifeste : rampe, heures, bancs, signatures du Bureau des Escales"
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
      "text": "un manifeste : rampe, heures, bancs, signatures du Bureau des Escales",
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
  "explanation": "un manifeste : rampe, heures, bancs, signatures du Bureau des Escales"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "inégalité",
      "right": "écart d'accès rendu normal par l'habitude"
    },
    {
      "left": "rampe",
      "right": "accès réel, distinct d'une planche"
    },
    {
      "left": "manifeste",
      "right": "texte qui dénonce et exige"
    },
    {
      "left": "accès",
      "right": "possibilité d'entrer, pas une faveur"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl s'ensuit une ___ des files, non un silence. (nominalisation de allonger)",
  "answer": "allongement"
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
    "fait",
    "de",
    "société",
    "se",
    "commente",
    "il",
    "ne",
    "se",
    "crie",
    "pas",
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
  "word": "accès",
  "hint": "possibilité d'entrer, pas une faveur"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Joël Mugisha est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Joël Mugisha sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c1-m4/langage-corps.svg",
      "word": "langage corps"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/geste-silence.svg",
      "word": "geste silence"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/idiome-main.svg",
      "word": "idiome main"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/epaule-dite.svg",
      "word": "epaule dite"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Joël Mugisha : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — dénoncer une inégalité ; relatives complexes ; il n''est que trop',
    'EL',
    $c$Objectif
Maîtriser dénoncer une inégalité ; relatives complexes ; il n'est que trop au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — dénoncer une inégalité ; relatives complexes ; il n'est que trop
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on dénonce, une assemblée sans place pour Joël le jour de la pluie n'est pas un détail.
Joël Mugisha concède que la cour a déjà posé une planche, pour autant que l'on n'appelle pas planche une rampe, ni patience une justice.
Autrement dit, dénoncer, ce n'est pas insulter : c'est rendre visible une inégalité que l'habitude a rendue normale
Il ressort qu'un manifeste : rampe, heures, bancs, signatures du Bureau des Escales
Piège : confusion cause / concession
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme inégalité, ici, n'est pas un slogan : écart d'accès rendu normal par l'habitude.
Solange a honte de la planche, et la honte n'est pas une rampe.
Karim chiffre le fer, refuse le mot bientôt.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au manifeste pour de vrai genre, et Solange Mukamana demande un registre plus net.
Correction : On va au manifeste vraiment, et Solange Mukamana demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Si bien que » introduit une conséquence.",
  "correct": true,
  "explanation": "Conséquence."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "« Du fait que » introduit…",
  "options": [
    {
      "text": "une concession",
      "correct": false
    },
    {
      "text": "une cause",
      "correct": true
    },
    {
      "text": "un but",
      "correct": false
    },
    {
      "text": "une hypotypose",
      "correct": false
    }
  ],
  "explanation": "Cause."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "inégalité",
      "right": "écart d'accès rendu normal par l'habitude"
    },
    {
      "left": "rampe",
      "right": "accès réel, distinct d'une planche"
    },
    {
      "left": "manifeste",
      "right": "texte qui dénonce et exige"
    },
    {
      "left": "accès",
      "right": "possibilité d'entrer, pas une faveur"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn impute la hausse à rampe, non au bol. (mot de la séquence)",
  "answer": "rampe"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Joël",
    "impute",
    "la",
    "hausse",
    "à",
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
  "sentence_with_error": "On va au manifeste pour de vrai genre, et Solange Mukamana demande un registre plus net.",
  "correct_sentence": "On va au manifeste vraiment, et Solange Mukamana demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m4/geste-silence.svg",
      "word": "geste silence"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/idiome-main.svg",
      "word": "idiome main"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/epaule-dite.svg",
      "word": "epaule dite"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/oeuvre-animee.svg",
      "word": "oeuvre animee"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « dénoncer une inégalité ; relatives complexes ; il n'est que trop » et deux pièges commentés."
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

  -- ===== Les épaules ne sont pas un verdict =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Les épaules ne sont pas un verdict'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Les épaules ne sont pas un verdict', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Les épaules ne sont pas un verdict',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Interpréter la gestuelle de la cour et des idiomes, sans les prendre pour des preuves. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Les épaules ne sont pas un verdict
Lila Sow : Radio Figuier. On parle trop vite de les gestes sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on fasse d'un haussement d'épaules un verdict, une lecture trop sûre des mains de Rose n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Sami concède que un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Aline Uwase : Ce que l'on nomme geste, ici, n'est pas un slogan : mouvement à interpréter, non à juger trop vite.
Patrick Habimana : Sami : j'ai les mots dans les mains, et ce n'est pas une preuve contre Rose.
Hawa Diallo : Rose tourne les talons pour coudre, non pour fuir un procès.
Joël Mugisha : Aline explique avoir les bras cassés : fatigue, pas anatomie.
Rose Iradukunda : Léa filme trop près ; Patrick lui demande de reculer.
Solange Mukamana : Hawa dit qu'un silence n'est pas un aveu.
Karim Bamba : Joël porte les lanternes : ses épaules parlent de fer, pas de honte.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a noté cinq épaules trop vite lues, deux silences, un tambour de Sami qui n'était pas une colère.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de lire le corps comme un texte, avec des hypothèses, pas des sentences
Yvette : Lila : interpréter, c'est proposer, c'est laisser corriger.
Mado : Rose Iradukunda entend, dans « le corps ne ment pas », ceci qui n'est pas dit : le corps ne ment pas est souvent une excuse pour ne plus écouter les mots
Sami : Autrement dit, un idiome (avoir les bras cassés, tourner les talons) décrit une relation, pas une anatomie
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot
Nina Kayitesi : Marc : le corps ne ment pas est un slogan trop sûr pour une cour.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les notes de Léa sur les gestes d'un côté, le slam inventé de Sami de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une lecture trop sûre des mains de Rose est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une lecture trop sûre des mains de Rose n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Rose Iradukunda, que reste-t-il implicite dans « le corps ne ment pas » ?",
  "options": [
    {
      "text": "Que Rose a avoué par les mains",
      "correct": false
    },
    {
      "text": "Cesser d'écouter les mots",
      "correct": true
    },
    {
      "text": "Que Sami accuse Léa",
      "correct": false
    },
    {
      "text": "Que le tambour est interdit",
      "correct": false
    }
  ],
  "explanation": "le corps ne ment pas est souvent une excuse pour ne plus écouter les mots"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "geste",
      "right": "mouvement à interpréter, non à juger trop vite"
    },
    {
      "left": "idiome",
      "right": "expression figée, souvent corporelle"
    },
    {
      "left": "épaule",
      "right": "signe possible de doute, pas une preuve"
    },
    {
      "left": "slam",
      "right": "parole rythmée de Sami, inventée"
    }
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
  "word": "geste",
  "hint": "mouvement à interpréter, non à juger trop vite"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Au registre soutenu, on dira ça ouais, et Sami lit encore la motion.",
  "correct_sentence": "Au registre soutenu, on dira cela, et Sami lit encore la motion.",
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
      "image_path": "/elearning/mfk-c1-m4/idiome-main.svg",
      "word": "idiome main"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/epaule-dite.svg",
      "word": "epaule dite"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/oeuvre-animee.svg",
      "word": "oeuvre animee"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/audioguide-rose.svg",
      "word": "audioguide rose"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « le corps ne ment pas » et la concession de Sami."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les notes de Léa sur les gestes et le slam inventé de Sami distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Les épaules ne sont pas un verdict',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Interpréter la gestuelle de la cour et des idiomes, sans les prendre pour des preuves. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Les épaules ne sont pas un verdict », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Les épaules ne sont pas un verdict
On parle trop vite de les gestes sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on fasse d'un haussement d'épaules un verdict, une lecture trop sûre des mains de Rose n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Ce que l'on nomme geste, ici, n'est pas un slogan : mouvement à interpréter, non à juger trop vite.
Sami : j'ai les mots dans les mains, et ce n'est pas une preuve contre Rose.
Rose tourne les talons pour coudre, non pour fuir un procès.
Aline explique avoir les bras cassés : fatigue, pas anatomie.
Léa filme trop près ; Patrick lui demande de reculer.
Hawa dit qu'un silence n'est pas un aveu.
Joël porte les lanternes : ses épaules parlent de fer, pas de honte.
Un chiffre, une trace : Léa a noté cinq épaules trop vite lues, deux silences, un tambour de Sami qui n'était pas une colère.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de lire le corps comme un texte, avec des hypothèses, pas des sentences
Lila : interpréter, c'est proposer, c'est laisser corriger.
Rose Iradukunda entend, dans « le corps ne ment pas », ceci qui n'est pas dit : le corps ne ment pas est souvent une excuse pour ne plus écouter les mots
Autrement dit, un idiome (avoir les bras cassés, tourner les talons) décrit une relation, pas une anatomie
La proposition qui reste debout est celle-ci : interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot
Marc : le corps ne ment pas est un slogan trop sûr pour une cour.
Nous clôturons sans fusionner les voix : les notes de Léa sur les gestes d'un côté, le slam inventé de Sami de l'autre, et le point où elles refusent de se ressembler.
Signé : Sami, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les notes de Léa sur les gestes et le slam inventé de Sami en une seule affiche.",
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
      "text": "Cinq épaules trop lues, un tambour qui n'était pas une colère",
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
  "explanation": "Léa a noté cinq épaules trop vite lues, deux silences, un tambour de Sami qui n'était pas une colère."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "geste",
      "right": "mouvement à interpréter, non à juger trop vite"
    },
    {
      "left": "idiome",
      "right": "expression figée, souvent corporelle"
    },
    {
      "left": "épaule",
      "right": "signe possible de doute, pas une preuve"
    },
    {
      "left": "slam",
      "right": "parole rythmée de Sami, inventée"
    }
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
  "word": "idiome",
  "hint": "expression figée, souvent corporelle"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La geste de trop vite n'aide personne, et Rose Iradukunda reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m4/epaule-dite.svg",
      "word": "epaule dite"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/oeuvre-animee.svg",
      "word": "oeuvre animee"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/audioguide-rose.svg",
      "word": "audioguide rose"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/toile-ocre.svg",
      "word": "toile ocre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Les épaules ne sont pas un verdict » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Les épaules ne sont pas un verdict : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : idiomes corporels ; ne pas les calquer ; interpréter un geste.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on fasse d'un haussement d'épaules un verdict, une lecture trop sûre des mains de Rose n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Ce que l'on nomme geste, ici, n'est pas un slogan : mouvement à interpréter, non à juger trop vite.
Encore que l'on interprète, une lecture trop sûre des mains de Rose n'est pas un détail.
Sami concède que un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Autrement dit, un idiome (avoir les bras cassés, tourner les talons) décrit une relation, pas une anatomie
Il ressort qu'interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot
Rose tourne les talons pour coudre, non pour fuir un procès.
Hawa dit qu'un silence n'est pas un aveu.
La proposition qui reste debout est celle-ci : interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les notes de Léa sur les gestes d'un côté, le slam inventé de Sami de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Sami transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Sami concède que un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Sami, et à quelle condition ?",
  "options": [
    {
      "text": "Sami n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "un geste peut dire ce que la bouche retient — à condition que l'on n'y lise pas un tribunal",
      "correct": true
    },
    {
      "text": "Sami abandonne il s'agit de lire le corps comme un texte, avec des hypothèses, pas des sentences",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y lise pas un tribunal"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "geste",
      "right": "mouvement à interpréter, non à juger trop vite"
    },
    {
      "left": "idiome",
      "right": "expression figée, souvent corporelle"
    },
    {
      "left": "épaule",
      "right": "signe possible de doute, pas une preuve"
    },
    {
      "left": "slam",
      "right": "parole rythmée de Sami, inventée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ le niveau, non la personne. (interpréter, subj.)",
  "answer": "interprète"
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
    "interprète",
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
  "word": "épaule",
  "hint": "signe possible de doute, pas une preuve"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Sami écoute encore, et il fautons interpréter avant de crier.",
  "correct_sentence": "Sami écoute encore, et il faut interpréter avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m4/oeuvre-animee.svg",
      "word": "oeuvre animee"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/audioguide-rose.svg",
      "word": "audioguide rose"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/toile-ocre.svg",
      "word": "toile ocre"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/atelier-corps.svg",
      "word": "atelier corps"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur idiomes corporels ; ne pas les calquer ; interpréter un geste, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les notes de Léa sur les gestes et le slam inventé de Sami distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Sami',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Interpréter la gestuelle de la cour et des idiomes, sans les prendre pour des preuves. Point : idiomes corporels ; ne pas les calquer ; interpréter un geste.

Consigne
Imitez le texte de Sami.

Support — Sami — Les épaules ne sont pas un verdict
Sami — Les épaules ne sont pas un verdict
On parle trop vite de les gestes sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on fasse d'un haussement d'épaules un verdict, une lecture trop sûre des mains de Rose n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Sami concède que un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Ce que l'on nomme geste, ici, n'est pas un slogan : mouvement à interpréter, non à juger trop vite.
Sami : j'ai les mots dans les mains, et ce n'est pas une preuve contre Rose.
Hawa dit qu'un silence n'est pas un aveu.
Joël porte les lanternes : ses épaules parlent de fer, pas de honte.
Lila : interpréter, c'est proposer, c'est laisser corriger.
La proposition qui reste debout est celle-ci : interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot
Marc : le corps ne ment pas est un slogan trop sûr pour une cour.
Nous clôturons sans fusionner les voix : les notes de Léa sur les gestes d'un côté, le slam inventé de Sami de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on interprète, une lecture trop sûre des mains de Rose n'est pas un détail.
Sami concède que un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
un idiome (avoir les bras cassés, tourner les talons) décrit une relation, pas une anatomie
Sami, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot",
  "correct": true,
  "explanation": "interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot"
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
      "text": "interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot",
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
  "explanation": "interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "geste",
      "right": "mouvement à interpréter, non à juger trop vite"
    },
    {
      "left": "idiome",
      "right": "expression figée, souvent corporelle"
    },
    {
      "left": "épaule",
      "right": "signe possible de doute, pas une preuve"
    },
    {
      "left": "slam",
      "right": "parole rythmée de Sami, inventée"
    }
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
  "word": "slam",
  "hint": "parole rythmée de Sami, inventée"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Sami est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Sami sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c1-m4/audioguide-rose.svg",
      "word": "audioguide rose"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/toile-ocre.svg",
      "word": "toile ocre"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/atelier-corps.svg",
      "word": "atelier corps"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/tendance-commentee.svg",
      "word": "tendance commentee"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Sami : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — idiomes corporels ; ne pas les calquer ; interpréter un geste',
    'EL',
    $c$Objectif
Maîtriser idiomes corporels ; ne pas les calquer ; interpréter un geste au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — idiomes corporels ; ne pas les calquer ; interpréter un geste
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on interprète, une lecture trop sûre des mains de Rose n'est pas un détail.
Sami concède que un geste peut dire ce que la bouche retient, pour autant que l'on n'y lise pas un tribunal.
Autrement dit, un idiome (avoir les bras cassés, tourner les talons) décrit une relation, pas une anatomie
Il ressort qu'interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot
Piège : familier non signalé dans un discours d'assemblée
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme geste, ici, n'est pas un slogan : mouvement à interpréter, non à juger trop vite.
Rose tourne les talons pour coudre, non pour fuir un procès.
Hawa dit qu'un silence n'est pas un aveu.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au épaule pour de vrai genre, et Rose Iradukunda demande un registre plus net.
Correction : On va au épaule vraiment, et Rose Iradukunda demande un registre plus net.
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
      "left": "geste",
      "right": "mouvement à interpréter, non à juger trop vite"
    },
    {
      "left": "idiome",
      "right": "expression figée, souvent corporelle"
    },
    {
      "left": "épaule",
      "right": "signe possible de doute, pas une preuve"
    },
    {
      "left": "slam",
      "right": "parole rythmée de Sami, inventée"
    }
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
  "sentence_with_error": "On va au épaule pour de vrai genre, et Rose Iradukunda demande un registre plus net.",
  "correct_sentence": "On va au épaule vraiment, et Rose Iradukunda demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m4/toile-ocre.svg",
      "word": "toile ocre"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/atelier-corps.svg",
      "word": "atelier corps"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/tendance-commentee.svg",
      "word": "tendance commentee"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/blog-invente.svg",
      "word": "blog invente"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « idiomes corporels ; ne pas les calquer ; interpréter un geste » et deux pièges commentés."
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

  -- ===== Le lin tient le geste =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Le lin tient le geste'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Le lin tient le geste', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le lin tient le geste',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Analyser une œuvre inventée de Rose pour un audioguide. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le lin tient le geste
Lila Sow : Radio Figuier. On parle trop vite de l'œuvre de Rose à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace l'analyse par l'admiration muette, une toile dont on ne dit que le prix n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste.
Aline Uwase : Ce que l'on nomme œuvre, ici, n'est pas un slogan : travail de Rose, à décrire sans le posséder.
Patrick Habimana : On dirait que le lin marcherait si l'on cessait de le clouer du regard.
Hawa Diallo : Rose : je n'ai pas animé un corps, j'ai donné une ombre à une couture.
Joël Mugisha : Léa choisit le présent : la pièce avance, l'ocre retient.
Rose Iradukunda : Aline refuse le jargon d'école trop loin du fil.
Solange Mukamana : Sami veut frapper le tambour trop près ; Rose dit non.
Karim Bamba : Patrick décrit les onze pièces sans les compter comme un exploit.
Félicie Ndayishimiye : Un chiffre, une trace : Rose a cousu onze pièces d'ocre ; Léa a écrit trois hypothèses ; zéro prix annoncé au banc.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'interpréter sans posséder l'œuvre par le jargon
Yvette : Lila enregistrera l'audioguide dans la salle vide, d'abord.
Mado : Léa Niyonzima entend, dans « c'est beau point », ceci qui n'est pas dit : c'est beau point permet de ne pas voir le corps trop réel que Rose a cousu
Sami : Autrement dit, décrire, c'est choisir un angle : couture, ombre, regard, pas un mot magique
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un audioguide de trois minutes : matériaux, geste, hypothèse, silence
Nina Kayitesi : Marc : analyser une œuvre, c'est proposer, c'est se taire à temps.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'œuvre de Rose d'un côté, le brouillon d'audioguide de Léa de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une toile dont on ne dit que le prix est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une toile dont on ne dit que le prix n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Léa Niyonzima, que reste-t-il implicite dans « c'est beau point » ?",
  "options": [
    {
      "text": "Que Rose a vendu l'œuvre aux Lampions",
      "correct": false
    },
    {
      "text": "Ne pas voir le corps trop réel",
      "correct": true
    },
    {
      "text": "Que Léa a cousu à sa place",
      "correct": false
    },
    {
      "text": "Que le lin est un slogan",
      "correct": false
    }
  ],
  "explanation": "c'est beau point permet de ne pas voir le corps trop réel que Rose a cousu"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "œuvre",
      "right": "travail de Rose, à décrire sans le posséder"
    },
    {
      "left": "audioguide",
      "right": "parole de visite, courte et honnête"
    },
    {
      "left": "lin",
      "right": "matériau ocre, plus parlant qu'un prix"
    },
    {
      "left": "hypothèse",
      "right": "lecture proposée, corrigeable"
    }
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
  "word": "œuvre",
  "hint": "travail de Rose, à décrire sans le posséder"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On dirait que la rivière prend une voix demain soir, et Rose Iradukunda écrit encore.",
  "correct_sentence": "On dirait que la rivière prendrait une voix demain soir, et Rose Iradukunda écrit encore.",
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
      "image_path": "/elearning/mfk-c1-m4/atelier-corps.svg",
      "word": "atelier corps"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/tendance-commentee.svg",
      "word": "tendance commentee"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/blog-invente.svg",
      "word": "blog invente"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/micro-corps.svg",
      "word": "micro corps"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « c'est beau point » et la concession de Rose Iradukunda."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'œuvre de Rose et le brouillon d'audioguide de Léa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le lin tient le geste',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Analyser une œuvre inventée de Rose pour un audioguide. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le lin tient le geste », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le lin tient le geste
On parle trop vite de l'œuvre de Rose à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'analyse par l'admiration muette, une toile dont on ne dit que le prix n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste.
Ce que l'on nomme œuvre, ici, n'est pas un slogan : travail de Rose, à décrire sans le posséder.
On dirait que le lin marcherait si l'on cessait de le clouer du regard.
Rose : je n'ai pas animé un corps, j'ai donné une ombre à une couture.
Léa choisit le présent : la pièce avance, l'ocre retient.
Aline refuse le jargon d'école trop loin du fil.
Sami veut frapper le tambour trop près ; Rose dit non.
Patrick décrit les onze pièces sans les compter comme un exploit.
Un chiffre, une trace : Rose a cousu onze pièces d'ocre ; Léa a écrit trois hypothèses ; zéro prix annoncé au banc.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'interpréter sans posséder l'œuvre par le jargon
Lila enregistrera l'audioguide dans la salle vide, d'abord.
Léa Niyonzima entend, dans « c'est beau point », ceci qui n'est pas dit : c'est beau point permet de ne pas voir le corps trop réel que Rose a cousu
Autrement dit, décrire, c'est choisir un angle : couture, ombre, regard, pas un mot magique
La proposition qui reste debout est celle-ci : un audioguide de trois minutes : matériaux, geste, hypothèse, silence
Marc : analyser une œuvre, c'est proposer, c'est se taire à temps.
Nous clôturons sans fusionner les voix : l'œuvre de Rose d'un côté, le brouillon d'audioguide de Léa de l'autre, et le point où elles refusent de se ressembler.
Signé : Rose Iradukunda, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'œuvre de Rose et le brouillon d'audioguide de Léa en une seule affiche.",
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
      "text": "Onze pièces d'ocre, trois hypothèses, zéro prix au banc",
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
  "explanation": "Rose a cousu onze pièces d'ocre ; Léa a écrit trois hypothèses ; zéro prix annoncé au banc."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "œuvre",
      "right": "travail de Rose, à décrire sans le posséder"
    },
    {
      "left": "audioguide",
      "right": "parole de visite, courte et honnête"
    },
    {
      "left": "lin",
      "right": "matériau ocre, plus parlant qu'un prix"
    },
    {
      "left": "hypothèse",
      "right": "lecture proposée, corrigeable"
    }
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
  "word": "audioguide",
  "hint": "parole de visite, courte et honnête"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La œuvre de trop vite n'aide personne, et Léa Niyonzima reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Léa Niyonzima reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m4/tendance-commentee.svg",
      "word": "tendance commentee"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/blog-invente.svg",
      "word": "blog invente"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/micro-corps.svg",
      "word": "micro corps"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/balance-norme.svg",
      "word": "balance norme"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le lin tient le geste » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Le lin tient le geste : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : décrire une œuvre ; présent de reportage ; métaphore contrôlée.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace l'analyse par l'admiration muette, une toile dont on ne dit que le prix n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste.
Ce que l'on nomme œuvre, ici, n'est pas un slogan : travail de Rose, à décrire sans le posséder.
Encore que l'on décrive, une toile dont on ne dit que le prix n'est pas un détail.
Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste.
Autrement dit, décrire, c'est choisir un angle : couture, ombre, regard, pas un mot magique
Il ressort qu'un audioguide de trois minutes : matériaux, geste, hypothèse, silence
Rose : je n'ai pas animé un corps, j'ai donné une ombre à une couture.
Sami veut frapper le tambour trop près ; Rose dit non.
La proposition qui reste debout est celle-ci : un audioguide de trois minutes : matériaux, geste, hypothèse, silence
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'œuvre de Rose d'un côté, le brouillon d'audioguide de Léa de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Rose Iradukunda transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Rose Iradukunda, et à quelle condition ?",
  "options": [
    {
      "text": "Rose Iradukunda n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "l'admiration a sa place — à condition que l'on dise aussi comment le lin tient le geste",
      "correct": true
    },
    {
      "text": "Rose Iradukunda abandonne il s'agit d'interpréter sans posséder l'œuvre par le jargon",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on dise aussi comment le lin tient le geste"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "œuvre",
      "right": "travail de Rose, à décrire sans le posséder"
    },
    {
      "left": "audioguide",
      "right": "parole de visite, courte et honnête"
    },
    {
      "left": "lin",
      "right": "matériau ocre, plus parlant qu'un prix"
    },
    {
      "left": "hypothèse",
      "right": "lecture proposée, corrigeable"
    }
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
  "word": "lin",
  "hint": "matériau ocre, plus parlant qu'un prix"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Rose Iradukunda écoute encore, et il fautons décrire avant de crier.",
  "correct_sentence": "Rose Iradukunda écoute encore, et il faut décrire avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m4/blog-invente.svg",
      "word": "blog invente"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/micro-corps.svg",
      "word": "micro corps"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/balance-norme.svg",
      "word": "balance norme"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/slam-banc.svg",
      "word": "slam banc"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur décrire une œuvre ; présent de reportage ; métaphore contrôlée, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'œuvre de Rose et le brouillon d'audioguide de Léa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Rose Iradukunda',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Analyser une œuvre inventée de Rose pour un audioguide. Point : décrire une œuvre ; présent de reportage ; métaphore contrôlée.

Consigne
Imitez le texte de Rose Iradukunda.

Support — Rose Iradukunda — Le lin tient le geste
Rose Iradukunda — Le lin tient le geste
On parle trop vite de l'œuvre de Rose à la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'analyse par l'admiration muette, une toile dont on ne dit que le prix n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste.
Ce que l'on nomme œuvre, ici, n'est pas un slogan : travail de Rose, à décrire sans le posséder.
On dirait que le lin marcherait si l'on cessait de le clouer du regard.
Sami veut frapper le tambour trop près ; Rose dit non.
Patrick décrit les onze pièces sans les compter comme un exploit.
Lila enregistrera l'audioguide dans la salle vide, d'abord.
La proposition qui reste debout est celle-ci : un audioguide de trois minutes : matériaux, geste, hypothèse, silence
Marc : analyser une œuvre, c'est proposer, c'est se taire à temps.
Nous clôturons sans fusionner les voix : l'œuvre de Rose d'un côté, le brouillon d'audioguide de Léa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on décrive, une toile dont on ne dit que le prix n'est pas un détail.
Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
décrire, c'est choisir un angle : couture, ombre, regard, pas un mot magique
Rose Iradukunda, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un audioguide de trois minutes : matériaux, geste, hypothèse, silence",
  "correct": true,
  "explanation": "un audioguide de trois minutes : matériaux, geste, hypothèse, silence"
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
      "text": "un audioguide de trois minutes : matériaux, geste, hypothèse, silence",
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
  "explanation": "un audioguide de trois minutes : matériaux, geste, hypothèse, silence"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "œuvre",
      "right": "travail de Rose, à décrire sans le posséder"
    },
    {
      "left": "audioguide",
      "right": "parole de visite, courte et honnête"
    },
    {
      "left": "lin",
      "right": "matériau ocre, plus parlant qu'un prix"
    },
    {
      "left": "hypothèse",
      "right": "lecture proposée, corrigeable"
    }
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
  "word": "hypothèse",
  "hint": "lecture proposée, corrigeable"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Rose Iradukunda est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Rose Iradukunda sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c1-m4/micro-corps.svg",
      "word": "micro corps"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/balance-norme.svg",
      "word": "balance norme"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/slam-banc.svg",
      "word": "slam banc"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/voix-lea.svg",
      "word": "voix lea"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Rose Iradukunda : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — décrire une œuvre ; présent de reportage ; métaphore contrôlée',
    'EL',
    $c$Objectif
Maîtriser décrire une œuvre ; présent de reportage ; métaphore contrôlée au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — décrire une œuvre ; présent de reportage ; métaphore contrôlée
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on décrive, une toile dont on ne dit que le prix n'est pas un détail.
Rose Iradukunda concède que l'admiration a sa place, pour autant que l'on dise aussi comment le lin tient le geste.
Autrement dit, décrire, c'est choisir un angle : couture, ombre, regard, pas un mot magique
Il ressort qu'un audioguide de trois minutes : matériaux, geste, hypothèse, silence
Piège : indicatif plat là où le conditionnel peint
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme œuvre, ici, n'est pas un slogan : travail de Rose, à décrire sans le posséder.
Rose : je n'ai pas animé un corps, j'ai donné une ombre à une couture.
Sami veut frapper le tambour trop près ; Rose dit non.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au lin pour de vrai genre, et Léa Niyonzima demande un registre plus net.
Correction : On va au lin vraiment, et Léa Niyonzima demande un registre plus net.
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
      "left": "œuvre",
      "right": "travail de Rose, à décrire sans le posséder"
    },
    {
      "left": "audioguide",
      "right": "parole de visite, courte et honnête"
    },
    {
      "left": "lin",
      "right": "matériau ocre, plus parlant qu'un prix"
    },
    {
      "left": "hypothèse",
      "right": "lecture proposée, corrigeable"
    }
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
  "answer": "œuvre"
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
  "sentence_with_error": "On va au lin pour de vrai genre, et Léa Niyonzima demande un registre plus net.",
  "correct_sentence": "On va au lin vraiment, et Léa Niyonzima demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m4/balance-norme.svg",
      "word": "balance norme"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/slam-banc.svg",
      "word": "slam banc"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/voix-lea.svg",
      "word": "voix lea"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/tambour-sami.svg",
      "word": "tambour sami"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « décrire une œuvre ; présent de reportage ; métaphore contrôlée » et deux pièges commentés."
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

  -- ===== Manifeste de la rampe =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Manifeste de la rampe'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Manifeste de la rampe', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Manifeste de la rampe',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Écrire un manifeste qui exige sans insulter, et qui nomme des gestes. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Manifeste de la rampe
Lila Sow : Radio Figuier. On parle trop vite de le manifeste pour la rampe, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on réduise le manifeste à un cri, un assez sans destinataire ni date n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Joël Mugisha concède que un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Aline Uwase : Ce que l'on nomme manifeste, ici, n'est pas un slogan : texte d'exigence argumentée.
Patrick Habimana : Joël : nous exigeons que la rampe soit posée avant les pluies, non après les excuses.
Hawa Diallo : Il convient que l'on nomme Dieudonné et le fer.
Joël Mugisha : Solange rature les insultes, garde la colère.
Rose Iradukunda : Aline corrige le subjonctif, pas le fond.
Solange Mukamana : Léa ajoute les bancs.
Karim Bamba : Lila lira le manifeste à l'antenne, lentement.
Félicie Ndayishimiye : Un chiffre, une trace : Vingt-deux signatures ; une date proposée ; zéro insulte dans le texte retenu.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le manifeste puisse se relire sans honte quand la rampe sera là
Yvette : Yvette signe ; Sami aussi, sans grimace.
Mado : Karim Bamba entend, dans « assez », ceci qui n'est pas dit : assez tout seul laisse à la cour le loisir de n'avoir rien entendu
Sami : Autrement dit, nous exigeons que la rampe soit datée : le subjonctif ici est une volonté, pas une décoration
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un manifeste signé : rampe, bancs, pluie, fer, jeudi
Nina Kayitesi : Marc : une injonction sans date est un assez qui s'évapore.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le manifeste d'un côté, les ratures de Solange et d'Aline de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un assez sans destinataire ni date est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un assez sans destinataire ni date n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Karim Bamba, que reste-t-il implicite dans « assez » ?",
  "options": [
    {
      "text": "Que Joël a insulté l'assemblée",
      "correct": false
    },
    {
      "text": "N'avoir rien entendu",
      "correct": true
    },
    {
      "text": "Que Karim a refusé toute date",
      "correct": false
    },
    {
      "text": "Que Solange a caché les signatures",
      "correct": false
    }
  ],
  "explanation": "assez tout seul laisse à la cour le loisir de n'avoir rien entendu"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "manifeste",
      "right": "texte d'exigence argumentée"
    },
    {
      "left": "exigence",
      "right": "volonté nommée, avec subjonctif"
    },
    {
      "left": "signature",
      "right": "nom posé, pas un like"
    },
    {
      "left": "date",
      "right": "jour du fer, plus précis qu'assez"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ avant d'accélérer. (exiger, subj.)",
  "answer": "exige"
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
    "exige",
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
  "word": "manifeste",
  "hint": "texte d'exigence argumentée"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il convient que l'on exiger trop tard, et Joël Mugisha refuse d'accélérer la pente.",
  "correct_sentence": "Il convient que l'on exige trop tard, et Joël Mugisha refuse d'accélérer la pente.",
  "explanation": "Il convient que + exige."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m4/slam-banc.svg",
      "word": "slam banc"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/voix-lea.svg",
      "word": "voix lea"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/tambour-sami.svg",
      "word": "tambour sami"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/ombre-danse.svg",
      "word": "ombre danse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « assez » et la concession de Joël Mugisha."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le manifeste et les ratures de Solange et d'Aline distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Assez, puis la date',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Écrire un manifeste qui exige sans insulter, et qui nomme des gestes. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Assez, puis la date », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Assez, puis la date
On parle trop vite de le manifeste pour la rampe, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise le manifeste à un cri, un assez sans destinataire ni date n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède que un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Ce que l'on nomme manifeste, ici, n'est pas un slogan : texte d'exigence argumentée.
Joël : nous exigeons que la rampe soit posée avant les pluies, non après les excuses.
Il convient que l'on nomme Dieudonné et le fer.
Solange rature les insultes, garde la colère.
Aline corrige le subjonctif, pas le fond.
Léa ajoute les bancs.
Lila lira le manifeste à l'antenne, lentement.
Un chiffre, une trace : Vingt-deux signatures ; une date proposée ; zéro insulte dans le texte retenu.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le manifeste puisse se relire sans honte quand la rampe sera là
Yvette signe ; Sami aussi, sans grimace.
Karim Bamba entend, dans « assez », ceci qui n'est pas dit : assez tout seul laisse à la cour le loisir de n'avoir rien entendu
Autrement dit, nous exigeons que la rampe soit datée : le subjonctif ici est une volonté, pas une décoration
La proposition qui reste debout est celle-ci : un manifeste signé : rampe, bancs, pluie, fer, jeudi
Marc : une injonction sans date est un assez qui s'évapore.
Nous clôturons sans fusionner les voix : le manifeste d'un côté, les ratures de Solange et d'Aline de l'autre, et le point où elles refusent de se ressembler.
Signé : Joël Mugisha, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le manifeste et les ratures de Solange et d'Aline en une seule affiche.",
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
      "text": "Vingt-deux signatures, une date, zéro insulte",
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
  "explanation": "Vingt-deux signatures ; une date proposée ; zéro insulte dans le texte retenu."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "manifeste",
      "right": "texte d'exigence argumentée"
    },
    {
      "left": "exigence",
      "right": "volonté nommée, avec subjonctif"
    },
    {
      "left": "signature",
      "right": "nom posé, pas un like"
    },
    {
      "left": "date",
      "right": "jour du fer, plus précis qu'assez"
    }
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
  "word": "exigence",
  "hint": "volonté nommée, avec subjonctif"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La manifeste de trop vite n'aide personne, et Karim Bamba reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m4/voix-lea.svg",
      "word": "voix lea"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/tambour-sami.svg",
      "word": "tambour sami"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/ombre-danse.svg",
      "word": "ombre danse"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/cadre-portrait.svg",
      "word": "cadre portrait"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Assez, puis la date » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Manifeste de la rampe : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : injonction vs subjonctif de volonté ; nous exigeons que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on réduise le manifeste à un cri, un assez sans destinataire ni date n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède que un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Ce que l'on nomme manifeste, ici, n'est pas un slogan : texte d'exigence argumentée.
Encore que l'on exige, un assez sans destinataire ni date n'est pas un détail.
Joël Mugisha concède que un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Autrement dit, nous exigeons que la rampe soit datée : le subjonctif ici est une volonté, pas une décoration
Il ressort qu'un manifeste signé : rampe, bancs, pluie, fer, jeudi
Il convient que l'on nomme Dieudonné et le fer.
Léa ajoute les bancs.
La proposition qui reste debout est celle-ci : un manifeste signé : rampe, bancs, pluie, fer, jeudi
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le manifeste d'un côté, les ratures de Solange et d'Aline de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Joël Mugisha transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Joël Mugisha concède que un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Joël Mugisha, et à quelle condition ?",
  "options": [
    {
      "text": "Joël Mugisha n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "un cri ouvre parfois l'oreille — à condition que l'on écrive ensuite qui, quand, quoi",
      "correct": true
    },
    {
      "text": "Joël Mugisha abandonne il s'agit que le manifeste puisse se relire sans honte quand la rampe sera là",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on écrive ensuite qui, quand, quoi"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "manifeste",
      "right": "texte d'exigence argumentée"
    },
    {
      "left": "exigence",
      "right": "volonté nommée, avec subjonctif"
    },
    {
      "left": "signature",
      "right": "nom posé, pas un like"
    },
    {
      "left": "date",
      "right": "jour du fer, plus précis qu'assez"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous recommandons que la cour ___ un relais. (exiger, subj.)",
  "answer": "exige"
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
    "exige",
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
  "hint": "nom posé, pas un like"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Joël Mugisha écoute encore, et il fautons exiger avant de crier.",
  "correct_sentence": "Joël Mugisha écoute encore, et il faut exiger avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m4/tambour-sami.svg",
      "word": "tambour sami"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/ombre-danse.svg",
      "word": "ombre danse"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/cadre-portrait.svg",
      "word": "cadre portrait"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/soleil-peau.svg",
      "word": "soleil peau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur injonction vs subjonctif de volonté ; nous exigeons que, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le manifeste et les ratures de Solange et d'Aline distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Joël Mugisha',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Écrire un manifeste qui exige sans insulter, et qui nomme des gestes. Point : injonction vs subjonctif de volonté ; nous exigeons que.

Consigne
Imitez le texte de Joël Mugisha.

Support — Joël Mugisha — Assez, puis la date
Joël Mugisha — Assez, puis la date
On parle trop vite de le manifeste pour la rampe, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise le manifeste à un cri, un assez sans destinataire ni date n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède que un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Ce que l'on nomme manifeste, ici, n'est pas un slogan : texte d'exigence argumentée.
Joël : nous exigeons que la rampe soit posée avant les pluies, non après les excuses.
Léa ajoute les bancs.
Lila lira le manifeste à l'antenne, lentement.
Yvette signe ; Sami aussi, sans grimace.
La proposition qui reste debout est celle-ci : un manifeste signé : rampe, bancs, pluie, fer, jeudi
Marc : une injonction sans date est un assez qui s'évapore.
Nous clôturons sans fusionner les voix : le manifeste d'un côté, les ratures de Solange et d'Aline de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on exige, un assez sans destinataire ni date n'est pas un détail.
Joël Mugisha concède que un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
nous exigeons que la rampe soit datée : le subjonctif ici est une volonté, pas une décoration
Joël Mugisha, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un manifeste signé : rampe, bancs, pluie, fer, jeudi",
  "correct": true,
  "explanation": "un manifeste signé : rampe, bancs, pluie, fer, jeudi"
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
      "text": "un manifeste signé : rampe, bancs, pluie, fer, jeudi",
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
  "explanation": "un manifeste signé : rampe, bancs, pluie, fer, jeudi"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "manifeste",
      "right": "texte d'exigence argumentée"
    },
    {
      "left": "exigence",
      "right": "volonté nommée, avec subjonctif"
    },
    {
      "left": "signature",
      "right": "nom posé, pas un like"
    },
    {
      "left": "date",
      "right": "jour du fer, plus précis qu'assez"
    }
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
  "word": "date",
  "hint": "jour du fer, plus précis qu'assez"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Joël Mugisha est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Joël Mugisha sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c1-m4/ombre-danse.svg",
      "word": "ombre danse"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/cadre-portrait.svg",
      "word": "cadre portrait"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/soleil-peau.svg",
      "word": "soleil peau"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/nuage-regard.svg",
      "word": "nuage regard"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Joël Mugisha : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — injonction vs subjonctif de volonté ; nous exigeons que',
    'EL',
    $c$Objectif
Maîtriser injonction vs subjonctif de volonté ; nous exigeons que au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — injonction vs subjonctif de volonté ; nous exigeons que
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on exige, un assez sans destinataire ni date n'est pas un détail.
Joël Mugisha concède que un cri ouvre parfois l'oreille, pour autant que l'on écrive ensuite qui, quand, quoi.
Autrement dit, nous exigeons que la rampe soit datée : le subjonctif ici est une volonté, pas une décoration
Il ressort qu'un manifeste signé : rampe, bancs, pluie, fer, jeudi
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme manifeste, ici, n'est pas un slogan : texte d'exigence argumentée.
Il convient que l'on nomme Dieudonné et le fer.
Léa ajoute les bancs.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au signature pour de vrai genre, et Karim Bamba demande un registre plus net.
Correction : On va au signature vraiment, et Karim Bamba demande un registre plus net.
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
      "left": "manifeste",
      "right": "texte d'exigence argumentée"
    },
    {
      "left": "exigence",
      "right": "volonté nommée, avec subjonctif"
    },
    {
      "left": "signature",
      "right": "nom posé, pas un like"
    },
    {
      "left": "date",
      "right": "jour du fer, plus précis qu'assez"
    }
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
  "sentence_with_error": "On va au signature pour de vrai genre, et Karim Bamba demande un registre plus net.",
  "correct_sentence": "On va au signature vraiment, et Karim Bamba demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m4/cadre-portrait.svg",
      "word": "cadre portrait"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/soleil-peau.svg",
      "word": "soleil peau"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/nuage-regard.svg",
      "word": "nuage regard"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/feuille-manifeste.svg",
      "word": "feuille manifeste"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « injonction vs subjonctif de volonté ; nous exigeons que » et deux pièges commentés."
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

  -- ===== Audioguide de Rose =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Audioguide de Rose'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Audioguide de Rose', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Audioguide de Rose',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Enregistrer un audioguide qui guide sans posséder l'œuvre. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Audioguide de Rose
Lila Sow : Radio Figuier. On parle trop vite de l'audioguide de la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on force l'admiration, un vous trop sûr de ce que l'œil doit sentir n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Léa Niyonzima concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer.
Aline Uwase : Ce que l'on nomme guide, ici, n'est pas un slogan : voix qui propose un regard.
Patrick Habimana : Léa : vous pouvez vous tenir à gauche, là où le lin prend l'ombre.
Hawa Diallo : On dirait qu'une couture avance ; il se peut que ce soit seulement votre pas.
Joël Mugisha : Rose a demandé que l'on coupe vous allez aimer.
Rose Iradukunda : Aline : la deuxième personne n'est pas un ordre.
Solange Mukamana : Sami chuchote trop près du micro ; Lila recule.
Karim Bamba : Patrick aime le silence de huit secondes.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a chronométré 2 min 50 ; un silence de huit secondes ; zéro vous allez aimer.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'accompagner le regard, pas de le remplacer
Yvette : Joël écoutera assis, si le banc est là.
Mado : Rose Iradukunda entend, dans « vous allez aimer », ceci qui n'est pas dit : vous allez aimer est déjà une petite violence polie
Sami : Autrement dit, vous pouvez voir, on dirait que, il se peut que : le guide propose, il n'assigne pas
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : trois minutes : matériaux, une hypothèse, un silence, une sortie
Nina Kayitesi : Marc : un audioguide est une hospitalité, pas une leçon de goût.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le script d'audioguide d'un côté, les remarques de Rose de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un vous trop sûr de ce que l'œil doit sentir est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un vous trop sûr de ce que l'œil doit sentir n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Rose Iradukunda, que reste-t-il implicite dans « vous allez aimer » ?",
  "options": [
    {
      "text": "Que Léa force l'admiration",
      "correct": false
    },
    {
      "text": "Une violence polie",
      "correct": true
    },
    {
      "text": "Que Rose a interdit l'écoute",
      "correct": false
    },
    {
      "text": "Que le silence est une panne",
      "correct": false
    }
  ],
  "explanation": "vous allez aimer est déjà une petite violence polie"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "guide",
      "right": "voix qui propose un regard"
    },
    {
      "left": "auditeur",
      "right": "personne libre de ne pas aimer"
    },
    {
      "left": "silence",
      "right": "temps laissé à l'œil"
    },
    {
      "left": "script",
      "right": "texte lu, raturé avec Rose"
    }
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
  "word": "guide",
  "hint": "voix qui propose un regard"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On dirait que la rivière prend une voix demain soir, et Léa Niyonzima écrit encore.",
  "correct_sentence": "On dirait que la rivière prendrait une voix demain soir, et Léa Niyonzima écrit encore.",
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
      "image_path": "/elearning/mfk-c1-m4/soleil-peau.svg",
      "word": "soleil peau"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/nuage-regard.svg",
      "word": "nuage regard"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/feuille-manifeste.svg",
      "word": "feuille manifeste"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/radio-geste.svg",
      "word": "radio geste"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « vous allez aimer » et la concession de Léa Niyonzima."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le script d'audioguide et les remarques de Rose distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Vous pouvez voir',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Enregistrer un audioguide qui guide sans posséder l'œuvre. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Vous pouvez voir », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Vous pouvez voir
On parle trop vite de l'audioguide de la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on force l'admiration, un vous trop sûr de ce que l'œil doit sentir n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer.
Ce que l'on nomme guide, ici, n'est pas un slogan : voix qui propose un regard.
Léa : vous pouvez vous tenir à gauche, là où le lin prend l'ombre.
On dirait qu'une couture avance ; il se peut que ce soit seulement votre pas.
Rose a demandé que l'on coupe vous allez aimer.
Aline : la deuxième personne n'est pas un ordre.
Sami chuchote trop près du micro ; Lila recule.
Patrick aime le silence de huit secondes.
Un chiffre, une trace : Léa a chronométré 2 min 50 ; un silence de huit secondes ; zéro vous allez aimer.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'accompagner le regard, pas de le remplacer
Joël écoutera assis, si le banc est là.
Rose Iradukunda entend, dans « vous allez aimer », ceci qui n'est pas dit : vous allez aimer est déjà une petite violence polie
Autrement dit, vous pouvez voir, on dirait que, il se peut que : le guide propose, il n'assigne pas
La proposition qui reste debout est celle-ci : trois minutes : matériaux, une hypothèse, un silence, une sortie
Marc : un audioguide est une hospitalité, pas une leçon de goût.
Nous clôturons sans fusionner les voix : le script d'audioguide d'un côté, les remarques de Rose de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le script d'audioguide et les remarques de Rose en une seule affiche.",
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
      "text": "Deux minutes cinquante, un silence, zéro injonction d'aimer",
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
  "explanation": "Léa a chronométré 2 min 50 ; un silence de huit secondes ; zéro vous allez aimer."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "guide",
      "right": "voix qui propose un regard"
    },
    {
      "left": "auditeur",
      "right": "personne libre de ne pas aimer"
    },
    {
      "left": "silence",
      "right": "temps laissé à l'œil"
    },
    {
      "left": "script",
      "right": "texte lu, raturé avec Rose"
    }
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
  "word": "auditeur",
  "hint": "personne libre de ne pas aimer"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La guide de trop vite n'aide personne, et Rose Iradukunda reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m4/nuage-regard.svg",
      "word": "nuage regard"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/feuille-manifeste.svg",
      "word": "feuille manifeste"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/radio-geste.svg",
      "word": "radio geste"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/coeur-visible.svg",
      "word": "coeur visible"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Vous pouvez voir » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Audioguide de Rose : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : deuxième personne de guide ; hypotaxe ; hypothèse signalée.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on force l'admiration, un vous trop sûr de ce que l'œil doit sentir n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer.
Ce que l'on nomme guide, ici, n'est pas un slogan : voix qui propose un regard.
Encore que l'on guide, un vous trop sûr de ce que l'œil doit sentir n'est pas un détail.
Léa Niyonzima concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer.
Autrement dit, vous pouvez voir, on dirait que, il se peut que : le guide propose, il n'assigne pas
Il ressort que trois minutes : matériaux, une hypothèse, un silence, une sortie
On dirait qu'une couture avance ; il se peut que ce soit seulement votre pas.
Sami chuchote trop près du micro ; Lila recule.
La proposition qui reste debout est celle-ci : trois minutes : matériaux, une hypothèse, un silence, une sortie
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le script d'audioguide d'un côté, les remarques de Rose de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Léa Niyonzima concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer."
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
      "text": "guider peut aider à voir — à condition que l'on laisse à l'auditeur le droit de ne pas aimer",
      "correct": true
    },
    {
      "text": "Léa Niyonzima abandonne il s'agit d'accompagner le regard, pas de le remplacer",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on laisse à l'auditeur le droit de ne pas aimer"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "guide",
      "right": "voix qui propose un regard"
    },
    {
      "left": "auditeur",
      "right": "personne libre de ne pas aimer"
    },
    {
      "left": "silence",
      "right": "temps laissé à l'œil"
    },
    {
      "left": "script",
      "right": "texte lu, raturé avec Rose"
    }
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
  "word": "silence",
  "hint": "temps laissé à l'œil"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Léa Niyonzima écoute encore, et il fautons guider avant de crier.",
  "correct_sentence": "Léa Niyonzima écoute encore, et il faut guider avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m4/feuille-manifeste.svg",
      "word": "feuille manifeste"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/radio-geste.svg",
      "word": "radio geste"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/coeur-visible.svg",
      "word": "coeur visible"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/image-de-soi.svg",
      "word": "image de soi"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur deuxième personne de guide ; hypotaxe ; hypothèse signalée, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le script d'audioguide et les remarques de Rose distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Léa Niyonzima',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Enregistrer un audioguide qui guide sans posséder l'œuvre. Point : deuxième personne de guide ; hypotaxe ; hypothèse signalée.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Vous pouvez voir
Léa Niyonzima — Vous pouvez voir
On parle trop vite de l'audioguide de la Salle des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on force l'admiration, un vous trop sûr de ce que l'œil doit sentir n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer.
Ce que l'on nomme guide, ici, n'est pas un slogan : voix qui propose un regard.
Léa : vous pouvez vous tenir à gauche, là où le lin prend l'ombre.
Sami chuchote trop près du micro ; Lila recule.
Patrick aime le silence de huit secondes.
Joël écoutera assis, si le banc est là.
La proposition qui reste debout est celle-ci : trois minutes : matériaux, une hypothèse, un silence, une sortie
Marc : un audioguide est une hospitalité, pas une leçon de goût.
Nous clôturons sans fusionner les voix : le script d'audioguide d'un côté, les remarques de Rose de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on guide, un vous trop sûr de ce que l'œil doit sentir n'est pas un détail.
Léa Niyonzima concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
vous pouvez voir, on dirait que, il se peut que : le guide propose, il n'assigne pas
Léa Niyonzima, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : trois minutes : matériaux, une hypothèse, un silence, une sortie",
  "correct": true,
  "explanation": "trois minutes : matériaux, une hypothèse, un silence, une sortie"
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
      "text": "trois minutes : matériaux, une hypothèse, un silence, une sortie",
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
  "explanation": "trois minutes : matériaux, une hypothèse, un silence, une sortie"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "guide",
      "right": "voix qui propose un regard"
    },
    {
      "left": "auditeur",
      "right": "personne libre de ne pas aimer"
    },
    {
      "left": "silence",
      "right": "temps laissé à l'œil"
    },
    {
      "left": "script",
      "right": "texte lu, raturé avec Rose"
    }
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
  "word": "script",
  "hint": "texte lu, raturé avec Rose"
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
      "image_path": "/elearning/mfk-c1-m4/radio-geste.svg",
      "word": "radio geste"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/coeur-visible.svg",
      "word": "coeur visible"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/image-de-soi.svg",
      "word": "image de soi"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/miroir-cour.svg",
      "word": "miroir cour"
    }
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
    'EL — deuxième personne de guide ; hypotaxe ; hypothèse signalée',
    'EL',
    $c$Objectif
Maîtriser deuxième personne de guide ; hypotaxe ; hypothèse signalée au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — deuxième personne de guide ; hypotaxe ; hypothèse signalée
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on guide, un vous trop sûr de ce que l'œil doit sentir n'est pas un détail.
Léa Niyonzima concède que guider peut aider à voir, pour autant que l'on laisse à l'auditeur le droit de ne pas aimer.
Autrement dit, vous pouvez voir, on dirait que, il se peut que : le guide propose, il n'assigne pas
Il ressort que trois minutes : matériaux, une hypothèse, un silence, une sortie
Piège : indicatif plat là où le conditionnel peint
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme guide, ici, n'est pas un slogan : voix qui propose un regard.
On dirait qu'une couture avance ; il se peut que ce soit seulement votre pas.
Sami chuchote trop près du micro ; Lila recule.
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
      "left": "guide",
      "right": "voix qui propose un regard"
    },
    {
      "left": "auditeur",
      "right": "personne libre de ne pas aimer"
    },
    {
      "left": "silence",
      "right": "temps laissé à l'œil"
    },
    {
      "left": "script",
      "right": "texte lu, raturé avec Rose"
    }
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
  "answer": "guide"
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
      "image_path": "/elearning/mfk-c1-m4/coeur-visible.svg",
      "word": "coeur visible"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/image-de-soi.svg",
      "word": "image de soi"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/miroir-cour.svg",
      "word": "miroir cour"
    },
    {
      "image_path": "/elearning/mfk-c1-m4/fil-portrait.svg",
      "word": "fil portrait"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « deuxième personne de guide ; hypotaxe ; hypothèse signalée » et deux pièges commentés."
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
